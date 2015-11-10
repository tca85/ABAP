REPORT yxmlemail NO STANDARD PAGE HEADING.

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

DATA:
  t_binary_tab    TYPE STANDARD TABLE OF ty_binary,
  t_nfe           TYPE STANDARD TABLE OF ty_nfe   ,
  t_corpo_email   TYPE                   bcsy_text,
  t_anexo_binario TYPE                   solix_tab.

DATA:
  w_binary_tab LIKE LINE OF t_binary_tab,
  w_nfe        LIKE LINE OF t_nfe.

DATA:
  sent_to_all        TYPE os_boolean ,
  main_text          TYPE bcsy_text  ,
  size               TYPE so_obj_len ,
  v_msg_erro         TYPE string     ,
  vl_string          TYPE string     ,
  v_output_length    TYPE i          ,
  vl_nome_rfc_ecc    TYPE rs38l-name ,
  vl_rfc_destination TYPE bdbapidst  ,
  lp_pdf_size        TYPE so_obj_len ,
  pdf_xstring        TYPE xstring    ,
  pdf_content        TYPE solix_tab  ,
  i_pdf              TYPE xstring    ,
  vl_input_length    TYPE i          ,
  v_tamanho_anexo    TYPE sood-objlen,
  v_nome_anexo       TYPE sood-objdes,
  prc_lines          TYPE i VALUE 0,
  prc_line_len       TYPE i VALUE 0,
  prc_bin_filesize   TYPE i VALUE 0.

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
  o_ecc               TYPE REF TO ycl_ecc                      ,
  o_cx_ecc            TYPE REF TO ycx_ecc                      .

FIELD-SYMBOLS:
  <f>       TYPE any,
  <l_xline> TYPE x.

CONSTANTS:
  c_rfc_ecc   TYPE rs38l-name  VALUE 'YGRC_ANEXA_DANFE_EMAIL',
  c_utf_8     TYPE abap_encod  VALUE 'UTF-8'                 ,
  c_anexo_xml TYPE c LENGTH 03 VALUE 'xml'                   ,
  c_anexo_pdf TYPE c LENGTH 03 VALUE 'pdf'                   .

PARAMETERS:
  p_id     TYPE /xnfe/id,
  p_e_mail TYPE adr6-smtp_addr.

INITIALIZATION.
  p_id     = '35150853162095002400551000004348371808167596'.
  p_e_mail = 'thiago.alves@ache.com.br'.

START-OF-SELECTION.

  CREATE OBJECT o_ecc TYPE ycl_ecc.

  APPEND 'Corpo do e-mail!' TO t_corpo_email.
  APPEND 'Linha 2'          TO t_corpo_email.
  APPEND 'Linha 3'          TO t_corpo_email.


  SELECT nfe~id
         nfe~docnum
         nfe~logsys
         xml~xmlstring
   FROM /xnfe/outnfehd AS nfe
   INNER JOIN /xnfe/outnfexml AS xml
           ON nfe~guid = xml~guid
   INTO TABLE t_nfe
   WHERE id = p_id.

  LOOP AT t_nfe INTO w_nfe.

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


    TRY.
        o_bcs = cl_bcs=>create_persistent( ).

      CATCH cx_send_req_bcs.
    ENDTRY.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = w_nfe-xmlstring
      IMPORTING
        output_length = v_output_length
      TABLES
        binary_tab    = t_anexo_binario.

    CONCATENATE 'NFe - ' w_nfe-id INTO v_nome_anexo.

    v_tamanho_anexo = v_output_length.

    TRY.
        o_document_bcs = cl_document_bcs=>create_document( i_type    = 'RAW'
                                                           i_text    = t_corpo_email
                                                           i_length  = '12'
                                                           i_subject = 'Envio do XML e PDF' ).

        o_document_bcs->add_attachment( i_attachment_type    = c_anexo_xml
                                        i_attachment_subject = v_nome_anexo
                                        i_att_content_hex    = t_anexo_binario
                                        i_attachment_size    = v_tamanho_anexo ).

      CATCH cx_document_bcs INTO o_cx_document_bcs.
        v_msg_erro = o_cx_document_bcs->get_text( ).
    ENDTRY.

*-------------------------------------------------------------------------------------------
*-------------------------------------------------------------------------------------------
*-------------------------------------------------------------------------------------------
*-------------------------------------------------------------------------------------------
*-------------------------------------------------------------------------------------------

    TRY.
        o_ecc->testar_rfc_destination( EXPORTING im_sistema_logico  = w_nfe-logsys          " Sistema lógico
                                                 im_nome_rfc_ecc    = c_rfc_ecc             " RFC criado no ECC
                                       CHANGING  ex_nome_rfc_ecc    = vl_nome_rfc_ecc       " Confirmação da RFC encontrada
                                                 ex_rfc_destination = vl_rfc_destination ). " Nome da RFC Destination
      CATCH ycx_ecc INTO o_cx_ecc.
        v_msg_erro = o_cx_ecc->msg.
    ENDTRY.


    IF vl_nome_rfc_ecc IS NOT INITIAL.
*     Chamar função YGRC_ANEXA_DANFE_EMAIL no ECC para carregar DANFE em binario
      CALL FUNCTION vl_nome_rfc_ecc
        DESTINATION vl_rfc_destination
        EXPORTING
          i_docnum   = w_nfe-docnum
          e_bin_size = vl_input_length
        IMPORTING
          e_pdf_data = t_binary_tab.
    ENDIF.

    DESCRIBE TABLE t_binary_tab
    LINES prc_lines.

    LOOP AT t_binary_tab ASSIGNING <f>.
      DESCRIBE FIELD <f> LENGTH prc_line_len IN BYTE MODE.
    ENDLOOP.

    vl_input_length = prc_lines * prc_line_len.

    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        input_length = vl_input_length
      IMPORTING
        buffer       = i_pdf
      TABLES
        binary_tab   = t_binary_tab
      EXCEPTIONS
        failed       = 1
        OTHERS       = 2.

    IF sy-subrc <> 0.

    ENDIF.

    CALL METHOD cl_document_bcs=>xstring_to_solix
      EXPORTING
        ip_xstring = i_pdf
      RECEIVING
        rt_solix   = pdf_content.

*   Adiciona o arquivo PDF como anexo do e-mail
    o_document_bcs->add_attachment( i_attachment_type    = c_anexo_pdf
                                    i_attachment_subject = v_nome_anexo
                                    i_att_content_hex    = pdf_content
                                    i_attachment_size    = v_tamanho_anexo ).

    o_bcs->set_document( o_document_bcs ).

    TRY.
        o_sapuser_bcs = cl_sapuser_bcs=>create( sy-uname ).

      CATCH cx_address_bcs.
    ENDTRY.

    TRY.
        o_bcs->set_sender( o_sapuser_bcs ).

        o_recipient_bcs = cl_cam_address_bcs=>create_internet_address( p_e_mail ).

        o_bcs->add_recipient( i_recipient = o_recipient_bcs
                              i_express   = abap_true ).

        o_bcs->set_send_immediately( abap_true ).

        o_bcs->send( EXPORTING i_with_error_screen = abap_true
                     RECEIVING result              = sent_to_all ).

        COMMIT WORK.

      CATCH cx_send_req_bcs INTO o_cx_send_req_bcs.
        v_msg_erro = o_cx_send_req_bcs->get_text( ).
        EXIT.
    ENDTRY.
  ENDLOOP.