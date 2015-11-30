*----------------------------------------------------------------------*
* Programa : ZPSE                                                      *
* Transação: SM37 (Job)                                                *
* Descrição: Job para verificar quais certificados PSE da STRUST estão *
*            para vencer e enviar e-mail para o responsável cadastrado *
*            na tabela ZPSE_VCTO.                                      *
*            O prazo de início para envio dos e-mails e e-mail do      *
*            responsável que deve receber a notificação deve ser       *
*            cadastrado nessa tabela também.                           *
*            O programa foi baseado no report SSF_ALERT_CERTEXPIRE     *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  04.04.2014  #76347 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

REPORT zpse NO STANDARD PAGE HEADING.

TYPE-POOLS: abap.

*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_pse                    ,
    applic   TYPE strustssl-applic   ,
    descript TYPE strustsslt-descript,
    context  TYPE psecontext         ,
    dtvenc   TYPE sy-datum           ,
    avencer  TYPE c                  ,
    email    TYPE zpse_vcto-email    ,
  END OF ty_pse                      .

*----------------------------------------------------------------------*
* Tabelas internas                                                     *
*----------------------------------------------------------------------*
DATA:
  tg_pse      TYPE STANDARD TABLE OF ty_pse   ,
  tg_vcto_pse TYPE STANDARD TABLE OF zpse_vcto.

*----------------------------------------------------------------------*
* Work Areas                                                           *
*----------------------------------------------------------------------*
DATA:
  wg_pse      LIKE LINE OF tg_pse     ,
  wg_vcto_pse LIKE LINE OF tg_vcto_pse.

*----------------------------------------------------------------------*
* Inicio                                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM: f_obter_lista_pse      ,
           f_verificar_data_vencto,
           f_enviar_email         .

*&---------------------------------------------------------------------*
*&      Form  f_obter_lista_pse
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_obter_lista_pse.
  DATA:
    tl_pse_sslc     TYPE TABLE OF ty_pse        ,
    tl_pse_wsse     TYPE TABLE OF ty_pse        ,
    tl_pse_ssfa     TYPE TABLE OF ty_pse        ,
    tl_pse_desc     TYPE TABLE OF ty_pse        ,
    tl_apptab       TYPE TABLE OF ssfapplict    ,
    tl_pse          TYPE TABLE OF ty_pse        ,
    tl_pse_ssls     TYPE TABLE OF ty_pse        ,
    tl_pse_smim     TYPE TABLE OF ty_pse        ,
    wl_pse          TYPE          ty_pse        ,
    wl_pse_d        TYPE          ty_pse        ,
    wl_apptab       TYPE          ssfapplict    ,
    vl_last_context TYPE          ty_pse-context,
    vl_ssflib_rc    TYPE          i             .

* Aviso de vencimento de certificado PSE da STRUST
  SELECT * FROM zpse_vcto
    INTO TABLE tg_vcto_pse.

  wl_pse-context  = 'PROG'.
  wl_pse-applic   = '<SYST>'.
  APPEND wl_pse TO tl_pse.

  wl_pse-context  = 'PROG'.
  wl_pse-applic   = '<SNCS>'.
  APPEND wl_pse TO tl_pse.

  SELECT applic   FROM strustssls
    INTO CORRESPONDING FIELDS OF TABLE tl_pse_ssls.

  LOOP AT tl_pse_ssls INTO wl_pse.
    wl_pse-context = 'SSLS'.
    MODIFY tl_pse_ssls FROM wl_pse.
  ENDLOOP.

  SELECT applic   FROM strustssl
    INTO CORRESPONDING FIELDS OF TABLE tl_pse_sslc.

  LOOP AT tl_pse_sslc INTO wl_pse.
    wl_pse-context = 'SSLC'.
    MODIFY tl_pse_sslc FROM wl_pse.
  ENDLOOP.

  SELECT applic   FROM strustwsse
    INTO CORRESPONDING FIELDS OF TABLE tl_pse_wsse.

  LOOP AT tl_pse_wsse INTO wl_pse.
    wl_pse-context = 'WSSE'.
    MODIFY tl_pse_wsse FROM wl_pse.
  ENDLOOP.

  SELECT applic   FROM strustsmim
    INTO CORRESPONDING FIELDS OF TABLE tl_pse_smim.

  LOOP AT tl_pse_smim INTO wl_pse.
    wl_pse-context = 'SMIM'.
    MODIFY tl_pse_smim FROM wl_pse.
  ENDLOOP.

  SELECT applic   FROM ssfargs CLIENT SPECIFIED      "#EC CI_BUFFCLIENT
    INTO CORRESPONDING FIELDS OF TABLE tl_pse_ssfa.

  LOOP AT tl_pse_ssfa INTO wl_pse.
    wl_pse-context = 'SSFA'.
    MODIFY tl_pse_ssfa FROM wl_pse.
  ENDLOOP.

  APPEND LINES OF tl_pse_ssls TO tl_pse.
  APPEND LINES OF tl_pse_sslc TO tl_pse.
  APPEND LINES OF tl_pse_wsse TO tl_pse.
  APPEND LINES OF tl_pse_smim TO tl_pse.
  APPEND LINES OF tl_pse_ssfa TO tl_pse.

  SORT tl_pse BY context.

  LOOP AT tl_pse INTO wl_pse.
    IF vl_last_context = wl_pse-context. CONTINUE. ENDIF.

    CALL FUNCTION 'SSFP_GET_APPINFO'
      EXPORTING
        context         = wl_pse-context
        language        = sy-langu
      IMPORTING
        ssflib_as       = vl_ssflib_rc
      TABLES
        applictab       = tl_apptab
      EXCEPTIONS
        invalid_context = 1
        OTHERS          = 2.

    IF sy-subrc = 0.
      CASE vl_ssflib_rc.

        WHEN 0.

          LOOP AT tl_apptab INTO wl_apptab.
            IF wl_pse-context = 'PROG' AND wl_apptab-applic = '<SSLS>'.
              CONTINUE.
            ENDIF.

            IF wl_pse-context = 'SSLS'.
              MESSAGE s088(trust) WITH wl_apptab-descript INTO wl_apptab-descript.
            ENDIF.

            IF wl_pse-context = 'SMIM'.
              MESSAGE s128(trust) WITH wl_apptab-descript INTO wl_apptab-descript.
            ENDIF.

            wl_pse_d-context  = wl_pse-context.
            wl_pse_d-applic   = wl_apptab-applic.
            wl_pse_d-descript = wl_apptab-descript.

            IF wl_pse_d-descript IS INITIAL.
              wl_pse_d-descript = wl_apptab-applic.
            ENDIF.

            APPEND wl_pse_d TO tl_pse_desc.
          ENDLOOP.

        WHEN 1.

          LOOP AT tl_apptab INTO wl_apptab.
            IF wl_pse-context = 'PROG' AND wl_apptab-applic = '<SYST>'
               AND wl_pse-context <> 'SSLC'.
              wl_pse_d-context  = wl_pse-context.
              wl_pse_d-applic   = wl_apptab-applic.
              wl_pse_d-descript = wl_apptab-descript.

              IF wl_pse_d-descript IS INITIAL.
                wl_pse_d-descript = wl_apptab-applic.
              ENDIF.

              APPEND wl_pse_d TO tl_pse_desc.
            ENDIF.
          ENDLOOP.
      ENDCASE.
    ENDIF.

    vl_last_context = wl_pse-context.

  ENDLOOP.

  tg_pse = tl_pse_desc.

ENDFORM.                    "f_obter_lista_pse

*&---------------------------------------------------------------------*
*&      Form  f_verificar_data_vencto
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_verificar_data_vencto.
  DATA:
    vl_certificado TYPE xstring     ,
    vl_existe_pse  TYPE abap_bool   ,
    vl_indice      TYPE sy-tabix    ,
    vl_assunto     TYPE c LENGTH 512,
    vl_emissor     TYPE c LENGTH 512,
    vl_valido_ate  TYPE c LENGTH 15 ,
    vl_dt_vcto     TYPE d           ,
    vl_dif_dias    TYPE i           ,
    tl_lista_pse   TYPE ssfbintab   .

  LOOP AT tg_pse INTO wg_pse.
    vl_indice = sy-tabix.

    PERFORM f_verificar_pse
      USING wg_pse-context
            wg_pse-applic
      CHANGING vl_existe_pse.

    IF vl_existe_pse = abap_true.
      CALL FUNCTION 'SSFP_GET_PSEINFO'
        EXPORTING
          context           = wg_pse-context
          applic            = wg_pse-applic
          accept_no_cert    = 'X'
        IMPORTING
          certificate       = vl_certificado
          certificatelist   = tl_lista_pse
        EXCEPTIONS
          ssf_no_ssflib     = 1
          ssf_krn_error     = 2
          ssf_invalid_par   = 3
          ssf_unknown_error = 4
          OTHERS            = 5.

      IF sy-subrc = 0.
        CLEAR: vl_assunto, vl_emissor, vl_valido_ate,
               vl_dt_vcto, vl_dif_dias.

        CALL FUNCTION 'SSFC_PARSE_CERTIFICATE'
          EXPORTING
            certificate         = vl_certificado
          IMPORTING
            subject             = vl_assunto
            issuer              = vl_emissor
            validto             = vl_valido_ate
          EXCEPTIONS
            ssf_krn_error       = 1
            ssf_krn_nomemory    = 2
            ssf_krn_nossflib    = 3
            ssf_krn_invalid_par = 4
            OTHERS              = 5.

        IF sy-subrc = 0.
          vl_dt_vcto = vl_valido_ate(8).
          wg_pse-dtvenc = vl_dt_vcto.

          vl_dif_dias = vl_dt_vcto - sy-datum.

          CLEAR wg_vcto_pse.
          READ TABLE tg_vcto_pse
          INTO wg_vcto_pse
          WITH KEY applic = wg_pse-applic.

          IF vl_dif_dias < wg_vcto_pse-dias.
            wg_pse-avencer = 'X'         .
            wg_pse-email   = wg_vcto_pse-email.
          ENDIF.

          MODIFY tg_pse FROM wg_pse INDEX vl_indice.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f_verificar_pse
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_verificar_pse
  USING i_context        TYPE c  "PROG, SSFA, SSLS, SSLC or WSSE
        i_applic         TYPE c  "<SYST>, <FILE> or table entry
  CHANGING e_pse_exists  TYPE abap_bool.

  DATA:
    l_filename TYPE ssfpsename,
    l_fullpath TYPE c LENGTH 1024.

  CLEAR e_pse_exists.

* Retorna o nome do arquivo do PSE
  CALL FUNCTION 'SSFPSE_FILENAME'
    EXPORTING
      context       = i_context
      applic        = i_applic
    IMPORTING
      psename       = l_filename
    EXCEPTIONS
      pse_not_found = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  PERFORM f_criar_nomearquivo_pse
   USING l_filename
   CHANGING l_fullpath.

* Verifica se o arquivo existe
  OPEN DATASET l_fullpath FOR INPUT IN BINARY MODE.

  IF sy-subrc = 0.
    e_pse_exists = abap_true.
    CLOSE DATASET l_fullpath.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f_criar_nomearquivo_pse
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->i_psename  text
*      <--e_psefilename  text
*----------------------------------------------------------------------*
FORM f_criar_nomearquivo_pse
  USING i_psename         TYPE ssfpsename
  CHANGING e_psefilename  TYPE c.

  CALL 'C_SAPGPARAM' ID 'NAME'    FIELD 'DIR_INSTANCE'    "#EC CI_CCALL
                     ID 'VALUE'   FIELD e_psefilename.

  CALL 'BUILD_DS_SPEC' ID 'PATH'     FIELD e_psefilename  "#EC CI_CCALL
                       ID 'FILENAME' FIELD 'sec'
                       ID 'OPSYS'    FIELD sy-opsys
                       ID 'RESULT'   FIELD e_psefilename.

  CALL 'BUILD_DS_SPEC' ID 'PATH'     FIELD e_psefilename  "#EC CI_CCALL
                       ID 'FILENAME' FIELD i_psename
                       ID 'OPSYS'    FIELD sy-opsys
                       ID 'RESULT'   FIELD e_psefilename.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f_enviar_email
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_enviar_email.
  DATA:
    vl_assunto_email  TYPE so_obj_des    ,
    vl_e_mail_usuario TYPE adr6-smtp_addr,
    vl_dt_vcto_txt    TYPE c LENGTH 10   ,
    vl_erro           TYPE string        .

  DATA:
    tl_corpo_email TYPE         bcsy_text,
    wl_corpo_email LIKE LINE OF tl_corpo_email.

  DATA:
    o_bcs       TYPE REF TO cl_bcs          ,
    o_doc_bcs   TYPE REF TO cl_document_bcs ,
    o_recipient TYPE REF TO if_recipient_bcs,
    o_sender    TYPE REF TO if_sender_bcs   ,
    o_excp      TYPE REF TO cx_bcs          .

  CONSTANTS:
    c_raw TYPE c LENGTH 03 VALUE 'RAW'.

  DELETE tg_pse WHERE avencer IS INITIAL.

  LOOP AT tg_pse INTO wg_pse.
    CLEAR: wl_corpo_email, vl_dt_vcto_txt.
    FREE: tl_corpo_email.

*   Assunto do e-mail
    vl_assunto_email = 'SAP - Certificado Expirando'.
    REPLACE '&' WITH sy-sysid(3) INTO vl_assunto_email.

*   E-mail do usuário responsável que receberá a notificação
    vl_e_mail_usuario = wg_pse-email.

    WRITE wg_pse-dtvenc TO vl_dt_vcto_txt DD/MM/YYYY.

    CONCATENATE 'O certificado: ' wg_pse-applic '-' wg_pse-descript
                'será expirado no dia' vl_dt_vcto_txt
          INTO wl_corpo_email SEPARATED BY space.
    APPEND wl_corpo_email TO tl_corpo_email.

    TRY.
        o_bcs = cl_bcs=>create_persistent( ).
        o_sender = cl_sapuser_bcs=>create( sy-uname ).

        o_recipient = cl_cam_address_bcs=>create_internet_address( vl_e_mail_usuario ).

        o_doc_bcs = cl_document_bcs=>create_document(
                             i_type    = c_raw
                             i_text    = tl_corpo_email
                             i_subject = vl_assunto_email ).

        o_bcs->set_sender( i_sender = o_sender ).
        o_bcs->add_recipient( i_recipient = o_recipient ).
        o_bcs->set_document( i_document = o_doc_bcs ).
        o_bcs->set_send_immediately( 'X' ).
        o_bcs->send( ).

        COMMIT WORK.

      CATCH cx_bcs INTO o_excp.
        vl_erro = o_excp->get_text( ).
        MESSAGE vl_erro TYPE 'E'.
    ENDTRY.
  ENDLOOP.

ENDFORM.