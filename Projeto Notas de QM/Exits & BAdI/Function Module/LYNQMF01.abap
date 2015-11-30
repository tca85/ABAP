*----------------------------------------------------------------------*
***INCLUDE LYNQMF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_limpar_tabelas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_limpar_tabelas.
  FREE: rqm07           ,
        qnqmasm0        ,
        diadrp          ,
        g_adrnr         ,
        g_persnr        ,
        g_partner_tab   ,
        g_bescheid_manum,
        g_reply_type    ,
        l_tfill         ,
        g_ihpa          ,
        t_destinatario  .
ENDFORM.                               " f_limpar_tabelas

*&---------------------------------------------------------------------*
*&      Form  f_sel_parceiros
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM f_sel_parceiros.
  IF NOT viqmel-adrnr IS INITIAL.
    DATA: l_address_selection LIKE addr1_sel.

    MOVE viqmel-adrnr TO l_address_selection-addrnumber.

    CALL FUNCTION 'ADDR_GET'
      EXPORTING
        address_selection = l_address_selection
      IMPORTING
        sadr              = sadr
      EXCEPTIONS
        parameter_error   = 1
        address_not_exist = 2
        version_not_exist = 3
        internal_error    = 4
        OTHERS            = 5.

    IF sy-subrc = 0.
      CLEAR g_partner_tab.
      MOVE text-spa   TO g_partner_tab-vtext.
      MOVE sadr-adrnr TO g_partner_tab-parnr.
      MOVE sadr-name1 TO g_partner_tab-name_list.
      APPEND g_partner_tab.
    ENDIF.

  ENDIF.

  LOOP AT g_ihpa.
    CLEAR g_partner_tab.
    MOVE-CORRESPONDING g_ihpa TO g_partner_tab.
    APPEND g_partner_tab.
  ENDLOOP.

  DESCRIBE TABLE g_partner_tab LINES l_tfill.

  IF l_tfill > 1.
    MOVE l_tfill TO partner-lines.

*   Enviar RDF: selecionar parceiros
    CALL SCREEN 2001 STARTING AT 1  1 .

  ELSEIF l_tfill = 1.
    READ TABLE g_partner_tab INDEX 1.
    MOVE-CORRESPONDING g_partner_tab TO act_partner.
  ENDIF.

  MOVE c_x TO g_only_once.
ENDFORM.                               " f_sel_parceiros

*&---------------------------------------------------------------------*
*&      Form  f_buscar_detalhes_parceiro
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM f_buscar_detalhes_parceiro.
  DATA: l_nrart     LIKE tpar-nrart.
  DATA: l_addr3_val LIKE addr3_val.
  DATA: l_parnr     LIKE knvk-parnr.
  DATA: l_knvk      LIKE knvk.
  DATA: l_street    LIKE lfa1-stras.
  DATA: h_user_tmp  LIKE usr01-bname.
  DATA: h_strlen    LIKE sy-subrc.
  DATA: ls_hrmr_rep TYPE hrmr_rep,
        lv_parnr    TYPE ihpa-parnr,
        lv_pe_pernr TYPE hrmr_rep-person_no.

  IF NOT act_partner-parvw IS INITIAL.
    IF act_partner-adrnr  IS INITIAL.
      CALL FUNCTION 'PM_PARTNER_READ_MASTER_DATA'
        EXPORTING
          parvw     = act_partner-parvw
          parnr     = act_partner-parnr
        IMPORTING
          e_nrart   = l_nrart
          adrnr_sd  = g_adrnr
          parnr_exp = lv_parnr
        EXCEPTIONS
          OTHERS    = 0.

      CALL FUNCTION 'PM_PARTNER_READ'
        EXPORTING
          parvw     = act_partner-parvw
          parnr     = act_partner-parnr
        IMPORTING
          diadrp_wa = diadrp
        EXCEPTIONS
          OTHERS    = 0.

      IF l_nrart EQ 'US'.

        CALL FUNCTION 'PM_PARTNER_LENGTH'
          EXPORTING
            parnr_imp     = act_partner-parnr
            parvw         = act_partner-parvw
            nrart         = l_nrart
          IMPORTING
            parnr_exp     = act_partner-parnr
          EXCEPTIONS
            invalid_parvw = 1.
        IF sy-subrc <> 0.
          RAISE no_valid_parnr.
        ENDIF.

        h_user_tmp = act_partner-parnr.

        DO.
          CALL FUNCTION 'SUSR_USER_ADDRESS_READ'
            EXPORTING
              user_name              = h_user_tmp
            IMPORTING
              user_address           = l_addr3_val
            EXCEPTIONS
              user_address_not_found = 1
              OTHERS                 = 2.

          IF sy-subrc = 0 OR act_partner-parnr CN ' 0123456789'.
            MOVE l_addr3_val-addrnumber TO g_adrnr.
            MOVE l_addr3_val-persnumber TO g_persnr.
            EXIT.
          ENDIF.

          h_strlen = STRLEN( h_user_tmp ).
          IF h_strlen < 12.
            SHIFT h_user_tmp RIGHT.
            h_user_tmp(1) = '0'.
          ELSE.
            sy-subrc = 1.
            EXIT.
          ENDIF.
        ENDDO.

      ELSEIF l_nrart EQ 'AP'.
        MOVE act_partner-parnr+2(10) TO l_parnr.

        CALL FUNCTION 'KNVK_SINGLE_READ'
          EXPORTING
            i_parnr         = l_parnr
          IMPORTING
            o_knvk          = l_knvk
          EXCEPTIONS
            not_found       = 1
            parameter_error = 2
            OTHERS          = 3.
        IF sy-subrc = 0.

          CALL FUNCTION 'KNA1_READ_SINGLE'
            EXPORTING
              id_kunnr            = l_knvk-kunnr
            IMPORTING
              es_kna1             = kna1
            EXCEPTIONS
              not_found           = 1
              input_not_specified = 2
              OTHERS              = 3.

          IF sy-subrc = 0.
            MOVE kna1-adrnr   TO g_adrnr.
            MOVE l_knvk-prsnr TO g_persnr.
          ENDIF.
        ENDIF.
      ENDIF.

      IF g_partner_tab-adrnr IS NOT INITIAL.
        g_adrnr = g_partner_tab-adrnr.
      ENDIF.

      IF l_nrart EQ 'PE' AND lv_parnr IS NOT INITIAL.
        MOVE lv_parnr TO lv_pe_pernr .

        CALL FUNCTION 'HR_REPRESENTANT_GET_DATA'
          EXPORTING
            p_pernr           = lv_pe_pernr
            p_private_address = 'X'
          IMPORTING
            p_hrmr_rep        = ls_hrmr_rep
          EXCEPTIONS
            pernr_not_found   = 2
            no_authorization  = 5
            parea_not_found   = 3
            address_not_found = 2.
        IF sy-subrc = 0 .

          MOVE ls_hrmr_rep-smtpadr TO rqm07-emailadr.
        ENDIF.
      ENDIF.

      MOVE diadrp-country      TO rqm07-land.
      MOVE diadrp-fax_number   TO rqm07-faxnr.
      MOVE diadrp-title        TO lfa1-anred.
      MOVE diadrp-name1        TO lfa1-name1.
      MOVE diadrp-name2        TO lfa1-name2.

      CONCATENATE diadrp-street diadrp-house_num1 INTO l_street
        SEPARATED BY ' '.
      MOVE l_street            TO lfa1-stras.

      MOVE diadrp-po_box       TO lfa1-pfach.
      MOVE diadrp-city1        TO lfa1-ort01.
      MOVE diadrp-post_code1   TO lfa1-pstlz.
      MOVE diadrp-city2        TO lfa1-pfort.
      MOVE diadrp-post_code2   TO lfa1-pstl2.
      MOVE diadrp-country      TO lfa1-land1.
      MOVE diadrp-region       TO lfa1-regio.
      MOVE diadrp-langu        TO lfa1-spras.
    ELSE.
      DATA: l_address_selection LIKE addr1_sel.

      MOVE act_partner-adrnr TO l_address_selection-addrnumber.

      CALL FUNCTION 'ADDR_GET'
        EXPORTING
          address_selection = l_address_selection
        IMPORTING
          sadr              = sadr
        EXCEPTIONS
          parameter_error   = 1
          address_not_exist = 2
          version_not_exist = 3
          internal_error    = 4
          OTHERS            = 5.

      IF sy-subrc = 0.
        MOVE sadr-adrnr     TO g_adrnr.
        MOVE sadr-land1     TO rqm07-land.
        MOVE sadr-telfx     TO rqm07-faxnr.
        MOVE-CORRESPONDING sadr TO lfa1.
      ENDIF.
    ENDIF.
  ELSE.
    MOVE sadr-adrnr     TO g_adrnr.
    MOVE sadr-land1     TO rqm07-land.
    MOVE sadr-telfx     TO rqm07-faxnr.
    MOVE-CORRESPONDING sadr TO lfa1.
  ENDIF.

  IF NOT lfa1-spras IS INITIAL.
    MOVE lfa1-spras TO g_langu.
  ELSE.
    MOVE sy-langu TO g_langu.
  ENDIF.
ENDFORM.                               " f_buscar_detalhes_parceiro

*&---------------------------------------------------------------------*
*&      Form  f_retornar_email_parceiro
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM f_retornar_email_parceiro.
  CLEAR g_adsmtp.  REFRESH g_adsmtp.
  CLEAR g_adrml.   REFRESH g_adrml.
  CLEAR g_adfax.   REFRESH g_adfax.

  IF NOT g_persnr IS INITIAL.
    CALL FUNCTION 'ADDR_PERS_COMP_GET_COMPLETE'
      EXPORTING
        addrnumber        = g_adrnr
        persnumber        = g_persnr
      IMPORTING
        addr3_complete    = g_addr3_complete
      EXCEPTIONS
        parameter_error   = 1
        address_not_exist = 2
        person_not_exist  = 3
        internal_error    = 4
        OTHERS            = 5.

    IF sy-subrc = 0.
      LOOP AT g_addr3_complete-addr3_tab
        INTO g_addr3.
      ENDLOOP.

      LOOP AT g_addr3_complete-adsmtp_tab INTO g_adsmtp.
        IF NOT g_adsmtp-adsmtp-flgdefault IS INITIAL.
          MOVE g_adsmtp-adsmtp-smtp_addr TO rqm07-emailadr.
        ENDIF.
        APPEND g_adsmtp.
      ENDLOOP.

      LOOP AT g_addr3_complete-adrml_tab INTO g_adrml.
        IF NOT g_adrml-adrml-flgdefault IS INITIAL.
          MOVE g_adrml-adrml-uname      TO rqm07-internadr.
        ENDIF.
        APPEND g_adrml.
      ENDLOOP.

      LOOP AT g_addr3_complete-adfax_tab INTO g_adfax.
        IF NOT g_adfax-adfax-flgdefault IS INITIAL.
          MOVE g_adfax-adfax-country    TO rqm07-land.
          MOVE g_adfax-adfax-faxnr_call TO rqm07-faxnr.
        ENDIF.
        APPEND g_adfax.
      ENDLOOP.
    ENDIF.

    CLEAR: rqm07-intern, rqm07-email, rqm07-fax, rqm07-ausdruck.

    CASE g_addr3-data-deflt_comm.
      WHEN 'INT'.
        MOVE c_x TO rqm07-email.
      WHEN 'RML'.
        MOVE c_x TO rqm07-intern.
      WHEN 'FAX'.
        MOVE c_x TO rqm07-fax.
      WHEN OTHERS.
        MOVE c_x TO rqm07-ausdruck.
    ENDCASE.
  ELSE.
    CALL FUNCTION 'ADDR_GET_COMPLETE'
      EXPORTING
        addrnumber        = g_adrnr
      IMPORTING
        addr1_complete    = g_addr1_complete
      EXCEPTIONS
        parameter_error   = 1
        address_not_exist = 2
        internal_error    = 3
        OTHERS            = 4.

    IF sy-subrc = 0.
      LOOP AT g_addr1_complete-addr1_tab
        INTO g_addr1.
      ENDLOOP.

      LOOP AT g_addr1_complete-adsmtp_tab INTO g_adsmtp.
        IF NOT g_adsmtp-adsmtp-flgdefault IS INITIAL.
          MOVE g_adsmtp-adsmtp-smtp_addr TO rqm07-emailadr.
        ENDIF.
        APPEND g_adsmtp.
      ENDLOOP.

      LOOP AT g_addr1_complete-adrml_tab INTO g_adrml.
        IF NOT g_adrml-adrml-flgdefault IS INITIAL.
          MOVE g_adrml-adrml-uname      TO rqm07-internadr.
        ENDIF.
        APPEND g_adrml.
      ENDLOOP.

      LOOP AT g_addr1_complete-adfax_tab INTO g_adfax.
        IF NOT g_adfax-adfax-flgdefault IS INITIAL.
          MOVE g_adfax-adfax-country    TO rqm07-land.
          MOVE g_adfax-adfax-faxnr_call TO rqm07-faxnr.
        ENDIF.
        APPEND g_adfax.
      ENDLOOP.
    ENDIF.

    CLEAR: rqm07-intern, rqm07-email, rqm07-fax, rqm07-ausdruck.

    CASE g_addr1-data-deflt_comm.
      WHEN 'INT'.
        MOVE c_x TO rqm07-email.
      WHEN 'RML'.
        MOVE c_x TO rqm07-intern.
      WHEN 'FAX'.
        MOVE c_x TO rqm07-fax.
      WHEN OTHERS.
        MOVE c_x TO rqm07-ausdruck.
    ENDCASE.
  ENDIF.

  w_destinatario-parvw     = act_partner-parvw        .
  w_destinatario-parnr     = act_partner-parnr        .
  w_destinatario-vtext     = act_partner-vtext        .
  w_destinatario-name_list = act_partner-name_list    .
  w_destinatario-emailadr  = g_adsmtp-adsmtp-smtp_addr.

  APPEND w_destinatario TO t_destinatario.
ENDFORM.                               " f_retornar_email_parceiro

*&---------------------------------------------------------------------*
*&      Form  f_verif_parc_sem_email
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_verif_parc_sem_email.
  DATA: v_resposta      TYPE c     ,
        v_qtd_sem_email TYPE i     ,
        v_qtd_destinat  TYPE i     ,
        v_parceiro      TYPE string,
        v_erro          TYPE string.

* Verifica se existe um ou mais parceiros sem e-mail cadastrado
  LOOP AT t_destinatario INTO w_destinatario
     WHERE emailadr IS INITIAL.

    v_qtd_sem_email = v_qtd_sem_email + 1.

    SHIFT w_destinatario-parnr LEFT DELETING LEADING '0'.

    IF v_qtd_sem_email = 1.
      v_parceiro = w_destinatario-parnr.
    ELSE.
      CONCATENATE w_destinatario-parnr
                  ','
                  v_parceiro
             INTO v_parceiro.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE t_destinatario LINES v_qtd_destinat.

  IF v_qtd_sem_email = v_qtd_destinat.
    MESSAGE 'Nenhum parceiro possui e-mail cadastrado' TYPE 'I'.
    RAISE action_stopped.
    EXIT.
  ELSEIF v_qtd_sem_email IS NOT INITIAL.

    IF v_qtd_sem_email = 1.
      v_erro = 'O parceiro & está sem e-mail cadastrado. Deseja continuar?'.
    ELSE.
      v_erro = 'Os parceiros & estão sem e-mail cadastrado. Deseja continuar?'.
    ENDIF.

    REPLACE '&' WITH v_parceiro INTO v_erro.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Relatório de Desvio de Fornecedor'
        text_question         = v_erro
        text_button_1         = 'Sim'
        text_button_2         = 'Não'
        display_cancel_button = ' '
      IMPORTING
        answer                = v_resposta.

    IF v_resposta <> 1. " sim
      RAISE action_stopped.
      EXIT.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_verif_parc_sem_email
