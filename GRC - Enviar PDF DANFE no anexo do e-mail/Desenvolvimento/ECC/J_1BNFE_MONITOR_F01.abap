*----------------------------------------------------------------------*
***INCLUDE J_1BNFE_MONITOR_F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  set_screen_status_100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_screen_status_100 .

*  DATA: lv_mix_doc type flag.              "1661137 CT-e "2000504
  CLEAR it_fcode.
* Determine action buttons that should not be displayed.

* Enable action "Delete Log Entries"?
  IF gf_log_entries_exist IS INITIAL OR
     gf_authorization_nfe_85 IS INITIAL.
    wa_fcode = c_fcode_delete_log.
    APPEND wa_fcode TO it_fcode.
  ENDIF.
* Enable action "Request Cancellation"?
  IF gf_authorization_nfe_85 IS INITIAL.
    wa_fcode = c_fcode_req_cancel.
    APPEND wa_fcode TO it_fcode.
  ENDIF.
* Enable action "Contingency"?
  IF gf_authorization_nfe_35 IS INITIAL.
    wa_fcode = c_fcode_conting.
    APPEND wa_fcode TO it_fcode.
  ENDIF.
** Enable action "Number NF-e"?                 "1630675
  IF gf_authorization_nfe_35 IS INITIAL.                    "1630675
    wa_fcode = c_fcode_set_num.                             "1630675
    APPEND wa_fcode TO it_fcode.                            "1630675
  ENDIF.                                                    "1630675
* Enable action "Contingency Reset"?
  IF gf_authorization_nfe_35 IS INITIAL.
    wa_fcode = c_fcode_conting_rs.
    APPEND wa_fcode TO it_fcode.
  ENDIF.
* Enable action "Send NF-e"?
  IF gf_authorization_nfe_35 IS INITIAL.
    wa_fcode = c_fcode_send_nfe.
    APPEND wa_fcode TO it_fcode.
  ENDIF.
* Enable event actions ?                           "1575364
  IF gf_authorization_nfe_02 IS INITIAL.                    "1575364
    wa_fcode = c_fcode_create_cce.                          "1575364
    APPEND wa_fcode TO it_fcode.                            "1575364
    wa_fcode = c_fcode_display_cce.                         "1575364
    APPEND wa_fcode TO it_fcode.                            "1575364
    wa_fcode = c_fcode_resend_cce.                          "1575364
    APPEND wa_fcode TO it_fcode.                            "1575364
  ENDIF.                                                    "1575364


* Enable actions "Maintaine Contingency Centrally"?
  IF gf_authorization_nfe_85 IS INITIAL.
    wa_fcode = c_fcode_cont_region.
    APPEND wa_fcode TO it_fcode.
    wa_fcode = c_fcode_cont_branch.
    APPEND wa_fcode TO it_fcode.
* Enable action "Reset rejected NF-e"?              "1439285
    wa_fcode = c_fcode_res_reject.                          "1439285
    APPEND wa_fcode TO it_fcode.                            "1439285
** Enable action "Number NF-e"?                      "1439285
*    wa_fcode = c_fcode_set_num.                     "1439285
*    APPEND wa_fcode TO it_fcode.                    "1439285
* Enable action "Request Cancellation again"?       "1439285
    wa_fcode = c_fcode_req_again.                           "1439285
    APPEND wa_fcode TO it_fcode.                            "1439285
* Enable action "Resend NF-e"?                      "1439285
    wa_fcode = c_fcode_resend_nfe.                          "1439285
    APPEND wa_fcode TO it_fcode.                            "1439285
* Enable action " Accept Cancellation Rejection"?  "1439285
    wa_fcode = c_fcode_accept_rej.                          "1439285
    APPEND wa_fcode TO it_fcode.                            "1439285
* Enable action "Cancel Source Doc."?               " 1517982 1671343
    wa_fcode = c_fcode_sync_cancel.                 " 1517982 1671343
    APPEND wa_fcode TO it_fcode.                            " 1517982
* Enable action "Cancel Prior to Auth"?             " 1671343
    wa_fcode = c_fcode_cancel_pa.                           " 1671343
    APPEND wa_fcode TO it_fcode.                            " 1671343
  ENDIF.

** Enable action "Print NF-e"?                      "1723841
  IF gf_authorization_nfe_35 IS INITIAL                     "1723841
  AND gf_authorization_nfe_aa IS INITIAL.                   "1723841
    wa_fcode = c_fcode_print_nfe.                           "1723841
    APPEND wa_fcode TO it_fcode.                            "1723841
  ENDIF.                                                    "1723841
  IF gf_authorization_nfe_35 IS INITIAL                     "1723841
  AND print = c_x.                                          "1723841
    wa_fcode = c_fcode_print_nfe.                           "1723841
    APPEND wa_fcode TO it_fcode.                            "1723841
  ENDIF.                                                    "1723841
  IF gf_authorization_nfe_aa IS INITIAL                     "1723841
  AND reprint = c_x.                                        "1723841
    wa_fcode = c_fcode_print_nfe.                           "1723841
    APPEND wa_fcode TO it_fcode.                            "1723841
  ENDIF.                                                    "1723841

** >> BEGIN >> Commented by note 2000504
*  LOOP at it_nfe_alv into wa_nfe_alv                "1661137 CT-e
*       where model <> gc_cte_model.                 "1661137 CT-e
*     lv_mix_doc = c_x.                              "1661137 CT-e
*  ENDLOOP.                                          "1661137 CT-e
*
** Disable functions if only CT-es are selected      "1661137 CT-e
*  IF NOT it_nfe_alv[] IS INITIAL AND                "1661137 CT-e
*         lv_mix_doc IS INITIAL.                     "1661137 CT-e
** Disable NF-e events (CC-e)                        "1661137 CT-e
*    wa_fcode = c_fcode_create_cce.                  "1661137 CT-e
*    APPEND wa_fcode TO it_fcode.                    "1661137 CT-e
*    wa_fcode = c_fcode_display_cce.                 "1661137 CT-e
*    APPEND wa_fcode TO it_fcode.                    "1661137 CT-e
*    wa_fcode = c_fcode_resend_cce.                  "1661137 CT-e
*    APPEND wa_fcode TO it_fcode.                    "1661137 CT-e
**** Disable 'Cancel Prior to Authorization' "1661137 CT-e 1763565
**   wa_fcode = c_fcode_cancel_pa.           "1661137 CT-e 1763565
**   APPEND wa_fcode TO it_fcode.            "1661137 CT-e 1763565
*  ENDIF.                                            "1661137 CT-e
** << END << Commented by note 2000504
* Set screen status
  IF it_fcode IS INITIAL.
    SET PF-STATUS 'SCREEN_100'.
  ELSE.
    SET PF-STATUS 'SCREEN_100' EXCLUDING it_fcode.
  ENDIF.
ENHANCEMENT-POINT YPDF_EDOCS SPOTS YPDF.

  DATA v_chave  TYPE c LENGTH 44.
  CASE sy-ucomm.
    WHEN 'PDF'.
      LOOP AT it_alv_selection INTO wa_alv_selection WHERE code = c_100.
        PERFORM entry_pdf IN PROGRAM znfe_print_danfe USING wa_alv_selection-docnum.
      ENDLOOP.
    WHEN 'CC-E'.
      LOOP AT it_alv_selection INTO wa_alv_selection WHERE code = c_100.
        CALL FUNCTION 'YCCE'
          EXPORTING
            docnum = wa_alv_selection-docnum.
      ENDLOOP.

    WHEN 'B2B'.

* Thiago Alves - #109075 - 07.10.2015 - Início
*      LOOP AT it_alv_selection INTO wa_alv_selection WHERE code = c_100.
*        CLEAR v_chave.
*
*        CONCATENATE wa_alv_selection-regio
*                    wa_alv_selection-nfyear
*                    wa_alv_selection-nfmonth
*                    wa_alv_selection-stcd1
*                    wa_alv_selection-model
*                    wa_alv_selection-serie
*                    wa_alv_selection-nfnum9
*                    wa_alv_selection-docnum9
*                    wa_alv_selection-cdv
*               INTO v_chave.
*
*        CALL FUNCTION 'YNFEIN_RESEND_MAIL_B2B'
*          DESTINATION 'NFE_IN'
*          EXPORTING
*            i_nfeid     = v_chave
*            iv_scenario = 'BUYER'.
*      ENDLOOP.

      DATA:
         v_qtd_aux             TYPE sy-tabix,
         v_msg_popup           TYPE string  ,
         v_qtd_emails_enviados TYPE sy-tabix,
         v_qtd_emails_string   TYPE string  .

      LOOP AT it_alv_selection INTO wa_alv_selection WHERE code = c_100.

        CALL FUNCTION 'YGRC_ENVIAR_XML_NFE'
          EXPORTING
            docnum              = wa_alv_selection-docnum
          IMPORTING
            qtd_emails_enviados = v_qtd_aux
          EXCEPTIONS
            erro_envio          = 1
            OTHERS              = 2.

        IF sy-subrc = 0.
          v_qtd_emails_enviados = v_qtd_emails_enviados + v_qtd_aux.
        ENDIF.

      ENDLOOP.

      IF v_qtd_emails_enviados IS INITIAL.
        v_msg_popup = 'Nenhum e-mail com XML da NF-e foi enviado'.
      ELSEIF v_qtd_emails_enviados = 1.
        v_msg_popup = '& e-mail com XML da NF-e foi enviado'.
      ELSEIF v_qtd_emails_enviados > 1.
        v_msg_popup = '& e-mails com XML da NF-e foram enviados'.
      ENDIF.

      v_qtd_emails_string = v_qtd_emails_enviados.

      CONDENSE v_qtd_emails_string NO-GAPS.
      REPLACE '&' INTO v_msg_popup WITH v_qtd_emails_string.

      MESSAGE v_msg_popup TYPE 'I'.
* Thiago Alves - #109075 - 07.10.2015 - Fim

  ENDCASE.

ENDFORM.                    " set_screen_status_100