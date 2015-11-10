*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_ECC                                                   *
* Método   : ENVIAR_EMAIL_NFE_DANFE                                    *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Enviar e-mail com XML e DANFE em anexo                    *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  09.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD enviar_email_nfe_danfe.
*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_nfe          TYPE STANDARD TABLE OF ty_nfe      ,
    t_nfe_b2b      TYPE STANDARD TABLE OF znfe_b2b    ,
    t_destinatario TYPE STANDARD TABLE OF ynfe_destino.

  DATA:
    t_corpo_email TYPE bcsy_text,
    t_pdf_binario TYPE solix_tab,
    t_xml_binario TYPE solix_tab.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_nfe          TYPE ty_nfe      ,
    w_nfe_b2b      TYPE znfe_b2b    ,
    w_alv          TYPE ty_alv      ,
    w_destinatario TYPE ynfe_destino.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro            TYPE string        ,
    v_data                TYPE string        ,              "#EC NEEDED
    v_email_destinatario  TYPE string        ,
    v_tamanho_anexo_ecc   TYPE i             ,
    v_output_length       TYPE i             ,
    v_qtd_emails_enviados TYPE sy-tabix      ,
    v_email_remetente     TYPE adr6-smtp_addr,
    v_tamanho_anexo       TYPE sood-objlen   ,
    v_nome_anexo          TYPE sood-objdes   ,
    v_assunto_email       TYPE so_obj_des    .

*----------------------------------------------------------------------*
* Variáveis tipo referência
*----------------------------------------------------------------------*
  DATA:
    o_bcs               TYPE REF TO cl_bcs                       ,
    o_document_bcs      TYPE REF TO cl_document_bcs              ,
    o_sender_bcs        TYPE REF TO if_sender_bcs                ,
    o_recipient_bcs     TYPE REF TO if_recipient_bcs             ,
    o_abap_conv_in_ce   TYPE REF TO cl_abap_conv_in_ce           ,
    o_parameter_invalid TYPE REF TO cx_parameter_invalid_range   ,
    o_codepage_convert  TYPE REF TO cx_sy_codepage_converter_init,
    o_cx_send_req_bcs   TYPE REF TO cx_send_req_bcs              ,
    o_cx_document_bcs   TYPE REF TO cx_document_bcs              ,
    o_cx_address_bcs    TYPE REF TO cx_address_bcs               .

*----------------------------------------------------------------------*
* Contantes
*----------------------------------------------------------------------*
  CONSTANTS:
    c_utf_8     TYPE abap_encod  VALUE 'UTF-8',
    c_raw       TYPE tsotd-objtp VALUE 'RAW'  ,
    c_anexo_xml TYPE c LENGTH 03 VALUE 'xml'  ,
    c_anexo_pdf TYPE c LENGTH 03 VALUE 'pdf'  .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

* Nenhuma NF-e encontrada
  IF me->t_nfe IS INITIAL.
    MESSAGE e011(yecc) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_ecc EXPORTING msg = v_msg_erro.
  ENDIF.

  LOOP AT me->t_nfe INTO w_nfe.
    FREE:
       o_bcs, o_sender_bcs, o_recipient_bcs, v_msg_erro, v_email_destinatario,
       v_tamanho_anexo, t_xml_binario, t_corpo_email, t_destinatario, w_alv,
       v_email_remetente, v_output_length, v_assunto_email, v_nome_anexo.

    w_alv-emit      = w_nfe-emit     . " CNPJ do emissor
    w_alv-docnum    = w_nfe-docnum   . " Nº do documento NF-e
    w_alv-nnf       = w_nfe-nnf      . " Nº de NF-e de 9 posições
    w_alv-serie     = w_nfe-serie    . " Série
    w_alv-id        = w_nfe-id       . " Chave primária como GUID em formato 'RAW'
    w_alv-cnpj_dest = w_nfe-cnpj_dest. " CNPJ do destinatário
    w_alv-dhemi     = w_nfe-dhemi    . " Data/hora da emissão em UTC

    IF im_t_destinatario IS NOT INITIAL.
      APPEND LINES OF im_t_destinatario TO t_destinatario.

    ELSE.
*     Busca o e-mail do destinatário
      t_destinatario = me->get_email_destinatario( w_nfe              = w_nfe
                                                   im_email_adicional = im_email_adicional
                                                   im_recebedor       = im_recebedor
                                                   im_transportadora  = im_transportadora ).
    ENDIF.

    IF t_destinatario IS INITIAL.
      APPEND w_alv TO me->t_alv.

      CONTINUE.
    ENDIF.

    TRY.
        cl_abap_conv_in_ce=>create( EXPORTING encoding = c_utf_8
                                              input    = w_nfe-xmlstring
                                    RECEIVING conv     = o_abap_conv_in_ce ).

        o_abap_conv_in_ce->read( IMPORTING data = v_data ).

      CATCH cx_parameter_invalid_range INTO o_parameter_invalid.
        v_msg_erro = o_parameter_invalid->get_text( ).

      CATCH cx_sy_codepage_converter_init INTO o_codepage_convert.
        v_msg_erro = o_codepage_convert->get_text( ).
    ENDTRY.

*   Atualiza a tag <xPed>
*   Se im_nro_pedido estiver vazio, procura no ECC
*   senão, altera o valor dentro da tag dentro do xstring do XML
    me->atualizar_nro_pedido_compra( EXPORTING xped  = im_nro_pedido
                                      CHANGING w_nfe = w_nfe ).

*   Assunto:
    CONCATENATE 'NFE - ' w_nfe-id INTO v_assunto_email RESPECTING BLANKS.

*   Corpo do e-mail
    t_corpo_email = me->get_corpo_email_nfe( w_nfe ).

*   Converte o Xstring do XML em binário para anexar ao e-mail
    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = w_nfe-xmlstring
      IMPORTING
        output_length = v_output_length
      TABLES
        binary_tab    = t_xml_binario.

    TRY.
        o_document_bcs = cl_document_bcs=>create_document( i_type    = c_raw
                                                           i_text    = t_corpo_email
                                                           i_subject = v_assunto_email ).

        IF t_xml_binario IS NOT INITIAL.
          v_tamanho_anexo = v_output_length.

          CONCATENATE 'NFe - ' w_nfe-id INTO v_nome_anexo RESPECTING BLANKS. "#EC NOTEXT

          o_document_bcs->add_attachment( i_attachment_type    = c_anexo_xml
                                          i_attachment_subject = v_nome_anexo
                                          i_att_content_hex    = t_xml_binario
                                          i_attachment_size    = v_tamanho_anexo ).
        ENDIF.

*       Se  CPF do destinatário estiver preenchido, envia o PDF da DANFE em anexo
        IF w_nfe-cpf_dest IS NOT INITIAL.
*
          IF im_t_pdf_binario IS INITIAL.
            t_pdf_binario = me->get_danfe_nfe( w_nfe ).
          ELSE.
            t_pdf_binario = im_t_pdf_binario.
          ENDIF.

          IF t_pdf_binario IS NOT INITIAL.
            v_tamanho_anexo = v_tamanho_anexo_ecc.

            CONCATENATE 'DANFE - ' w_nfe-nnf INTO v_nome_anexo RESPECTING BLANKS. "#EC NOTEXT

            o_document_bcs->add_attachment( i_attachment_type    = c_anexo_pdf
                                            i_attachment_subject = v_nome_anexo
                                            i_att_content_hex    = t_pdf_binario
                                            i_attachment_size    = v_tamanho_anexo ).
          ENDIF.
        ENDIF.

      CATCH cx_document_bcs INTO o_cx_document_bcs.
        v_msg_erro = o_cx_document_bcs->get_text( ).
    ENDTRY.

    TRY.
        o_bcs = cl_bcs=>create_persistent( ).

        o_bcs->set_document( o_document_bcs ).

      CATCH cx_send_req_bcs INTO o_cx_send_req_bcs.
        v_msg_erro = o_cx_send_req_bcs->get_text( ).
    ENDTRY.

*   Configura o e-mail remetente e os destinatários
    TRY.
        v_email_remetente = me->get_email_remetente( w_nfe-id ).

        o_sender_bcs = cl_cam_address_bcs=>create_internet_address( v_email_remetente ).

        LOOP AT t_destinatario INTO w_destinatario.
          CONCATENATE w_destinatario-email
                      v_email_destinatario
                 INTO v_email_destinatario SEPARATED BY ';'.

          o_recipient_bcs = cl_cam_address_bcs=>create_internet_address( w_destinatario-email ).

          o_bcs->add_recipient( i_recipient = o_recipient_bcs
                                i_express   = abap_true ).
        ENDLOOP.

      CATCH cx_address_bcs INTO o_cx_address_bcs.
        v_msg_erro = o_cx_address_bcs->get_text( ).
    ENDTRY.

    TRY.
        w_alv-remetente    = v_email_remetente   .
        w_alv-destinatario = v_email_destinatario.
        APPEND w_alv TO me->t_alv                .

        o_bcs->set_sender( o_sender_bcs ).

        o_bcs->set_send_immediately( abap_true ).

*       Envia o e-mail
        o_bcs->send( ).

        COMMIT WORK.

        v_qtd_emails_enviados = v_qtd_emails_enviados + 1.

*       Salva a chave de aceso da NF-e para atualizar o status B2B do monitor depois
        CLEAR w_nfe_b2b              .
        w_nfe_b2b-id = w_nfe-id      .
        APPEND w_nfe_b2b TO t_nfe_b2b.

      CATCH cx_send_req_bcs INTO o_cx_send_req_bcs.
        v_msg_erro = o_cx_send_req_bcs->get_text( ).
    ENDTRY.

  ENDLOOP.

  IF t_nfe_b2b IS NOT INITIAL.
    MODIFY znfe_b2b FROM TABLE t_nfe_b2b.
  ENDIF.

  rt_qtd_email_enviado = v_qtd_emails_enviados.

ENDMETHOD.