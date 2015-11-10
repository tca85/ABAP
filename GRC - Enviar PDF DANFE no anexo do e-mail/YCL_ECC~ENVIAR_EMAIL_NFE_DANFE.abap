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
* ACTHIAGO  02.09.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD enviar_email_nfe_danfe.

*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
  TYPES:
    BEGIN OF ty_nfe                           ,
      id        TYPE /xnfe/outnfehd-id        ,
      docnum    TYPE /xnfe/outnfehd-docnum    ,
      logsys    TYPE /xnfe/outnfehd-logsys    ,
      xmlstring TYPE /xnfe/outnfexml-xmlstring,
    END OF ty_nfe                             ,

    BEGIN OF ty_binary                        ,
      content TYPE ssfdata                    ,
    END OF ty_binary                          .

*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_pdf_danfe   TYPE STANDARD TABLE OF ty_binary,
    t_nfe         TYPE STANDARD TABLE OF ty_nfe   ,
    t_corpo_email TYPE                   bcsy_text,
    t_pdf_binario TYPE                   solix_tab,
    t_xml_binario TYPE                   solix_tab.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_binary_tab LIKE LINE OF t_pdf_danfe,
    w_nfe        LIKE LINE OF t_nfe.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    sent_to_all         TYPE os_boolean ,
    main_text           TYPE bcsy_text  ,
    size                TYPE so_obj_len ,
    v_msg_erro          TYPE string     ,
    vl_string           TYPE string     ,
    v_output_length     TYPE i          ,
    v_nome_rfc_ecc      TYPE rs38l-name ,
    v_rfc_destination   TYPE bdbapidst  ,
    lp_pdf_size         TYPE so_obj_len ,
    pdf_xstring         TYPE xstring    ,
    i_pdf               TYPE xstring    ,
    v_tamanho_anexo_ecc TYPE i          ,
    v_tamanho_anexo     TYPE sood-objlen,
    v_nome_anexo        TYPE sood-objdes,
    v_qtd_linhas_pdf    TYPE i VALUE 0  ,
    prc_line_len        TYPE i VALUE 0  ,
    prc_bin_filesize    TYPE i VALUE 0  .

*----------------------------------------------------------------------*
* Variáveis tipo referência
*----------------------------------------------------------------------*
  DATA:
    o_bcs               TYPE REF TO cl_bcs                       ,
    o_document_bcs      TYPE REF TO cl_document_bcs              ,
    o_sapuser_bcs       TYPE REF TO cl_sapuser_bcs               ,
    o_recipient_bcs     TYPE REF TO if_recipient_bcs             ,
    o_abap_conv_in_ce   TYPE REF TO cl_abap_conv_in_ce           ,
    o_cx_bcs            TYPE REF TO cx_bcs                       ,
    o_parameter_invalid TYPE REF TO cx_parameter_invalid_range   ,
    o_codepage_convert  TYPE REF TO cx_sy_codepage_converter_init,
    o_cx_send_req_bcs   TYPE REF TO cx_send_req_bcs              ,
    o_cx_document_bcs   TYPE REF TO cx_document_bcs              ,
    o_cx_ecc            TYPE REF TO ycx_ecc                      .

*----------------------------------------------------------------------*
* Field-Symbols
*----------------------------------------------------------------------*
  FIELD-SYMBOLS:
    <linha>   TYPE any,
    <l_xline> TYPE x  .

*----------------------------------------------------------------------*
* Contantes
*----------------------------------------------------------------------*
  CONSTANTS:
    c_rfc_ecc   TYPE rs38l-name  VALUE 'YGRC_ANEXA_DANFE_EMAIL',
    c_utf_8     TYPE abap_encod  VALUE 'UTF-8'                 ,
    c_anexo_xml TYPE c LENGTH 03 VALUE 'xml'                   ,
    c_anexo_pdf TYPE c LENGTH 03 VALUE 'pdf'                   .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  IF  im_chave_acesso IS INITIAL
   OR im_email_destinatario IS INITIAL.
    EXIT.
  ENDIF.

  APPEND 'Corpo do e-mail!' TO t_corpo_email.
  APPEND INITIAL LINE TO t_corpo_email      .
  APPEND 'Linha 2'          TO t_corpo_email.
  APPEND 'Linha 3'          TO t_corpo_email.

* Obtém o XML da NF-e
  SELECT nfe~id
         nfe~docnum
         nfe~logsys
         xml~xmlstring
   FROM /xnfe/outnfehd AS nfe
   INNER JOIN /xnfe/outnfexml AS xml ON nfe~guid = xml~guid
   INTO TABLE t_nfe
   WHERE id = im_chave_acesso.


  LOOP AT t_nfe INTO w_nfe.
    FREE:
       o_bcs, v_msg_erro, v_output_length, v_tamanho_anexo, t_xml_binario, t_corpo_email,
       v_nome_rfc_ecc, v_rfc_destination, t_pdf_danfe.

    TRY.
        o_bcs = cl_bcs=>create_persistent( ).

      CATCH cx_send_req_bcs INTO o_cx_send_req_bcs.
        v_msg_erro = o_cx_send_req_bcs->get_text( ).
    ENDTRY.

    TRY.
        cl_abap_conv_in_ce=>create( EXPORTING encoding = c_utf_8
                                              input    = w_nfe-xmlstring
                                    RECEIVING conv     = o_abap_conv_in_ce ).

        o_abap_conv_in_ce->read( IMPORTING data = vl_string ).

      CATCH cx_parameter_invalid_range INTO o_parameter_invalid.
        v_msg_erro = o_parameter_invalid->get_text( ).

      CATCH cx_sy_codepage_converter_init INTO o_codepage_convert.
        v_msg_erro = o_codepage_convert->get_text( ).
    ENDTRY.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = w_nfe-xmlstring
      IMPORTING
        output_length = v_output_length
      TABLES
        binary_tab    = t_xml_binario.

    TRY.
        CONCATENATE 'NFe - ' w_nfe-id INTO v_nome_anexo.

        o_document_bcs = cl_document_bcs=>create_document( i_type    = 'RAW'
                                                           i_text    = t_corpo_email
                                                           i_subject = 'Envio do XML e PDF' ).

        v_tamanho_anexo = v_output_length.

        o_document_bcs->add_attachment( i_attachment_type    = c_anexo_xml
                                        i_attachment_subject = v_nome_anexo
                                        i_att_content_hex    = t_xml_binario
                                        i_attachment_size    = v_tamanho_anexo ).

      CATCH cx_document_bcs INTO o_cx_document_bcs.
        v_msg_erro = o_cx_document_bcs->get_text( ).
    ENDTRY.

    TRY.
        me->testar_rfc_destination( EXPORTING im_sistema_logico  = w_nfe-logsys          " Sistema lógico
                                              im_nome_rfc_ecc    = c_rfc_ecc             " RFC criado no ECC
                                    CHANGING  ex_nome_rfc_ecc    = v_nome_rfc_ecc       " Confirmação da RFC encontrada
                                              ex_rfc_destination = v_rfc_destination ). " Nome da RFC Destination
      CATCH ycx_ecc INTO o_cx_ecc.
        v_msg_erro = o_cx_ecc->msg.
    ENDTRY.

    IF v_nome_rfc_ecc IS NOT INITIAL.
*     Chamar função YGRC_ANEXA_DANFE_EMAIL no ECC para carregar DANFE em binario
      CALL FUNCTION v_nome_rfc_ecc
        DESTINATION v_rfc_destination
        EXPORTING
          i_docnum   = w_nfe-docnum
        IMPORTING
          e_pdf_data = t_pdf_danfe
          e_bin_size = v_tamanho_anexo_ecc.
    ENDIF.

    IF t_pdf_danfe IS NOT INITIAL.
      CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
        EXPORTING
          input_length = v_tamanho_anexo_ecc
        IMPORTING
          buffer       = i_pdf
        TABLES
          binary_tab   = t_pdf_danfe
        EXCEPTIONS
          failed       = 1
          OTHERS       = 2.

      IF sy-subrc = 0.
        cl_document_bcs=>xstring_to_solix( EXPORTING ip_xstring = i_pdf
                                           RECEIVING rt_solix   = t_pdf_binario ).
      ENDIF.

      TRY.
          v_tamanho_anexo = v_tamanho_anexo_ecc.

          o_document_bcs->add_attachment( i_attachment_type    = c_anexo_pdf
                                          i_attachment_subject = v_nome_anexo
                                          i_att_content_hex    = t_pdf_binario
                                          i_attachment_size    = v_tamanho_anexo ).

        CATCH cx_document_bcs INTO o_cx_document_bcs.
          v_msg_erro = o_cx_document_bcs->get_text( ).
      ENDTRY.
    ENDIF.

    TRY.
        o_bcs->set_document( o_document_bcs ).

      CATCH cx_send_req_bcs.

    ENDTRY.

    TRY.
        o_sapuser_bcs = cl_sapuser_bcs=>create( sy-uname ).

      CATCH cx_address_bcs.
    ENDTRY.

    TRY.
        o_bcs->set_sender( o_sapuser_bcs ).

        o_recipient_bcs = cl_cam_address_bcs=>create_internet_address( im_email_destinatario ).

        o_bcs->add_recipient( i_recipient = o_recipient_bcs
                              i_express   = abap_true ).

        o_bcs->set_send_immediately( abap_true ).

        o_bcs->send( ).

        COMMIT WORK.

      CATCH cx_send_req_bcs INTO o_cx_send_req_bcs.
        v_msg_erro = o_cx_send_req_bcs->get_text( ).
        EXIT.
    ENDTRY.
  ENDLOOP.

ENDMETHOD.