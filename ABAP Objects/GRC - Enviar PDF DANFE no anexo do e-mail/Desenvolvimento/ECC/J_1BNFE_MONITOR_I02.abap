*----------------------------------------------------------------------*
***INCLUDE J_1BNFE_MONITOR_I02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  user_command_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CLEAR gv_refresh.                                         "1620092
  CASE ok_code.
    WHEN 'SELECT'.
*   Select/de-select present row
      PERFORM row_selection.
    WHEN 'REFRESH'.
*   Update content of ALV Grid
      gv_refresh = 'X'.                                     "1620092
      PERFORM grid_refresh.
    WHEN 'NF_WRITER'.
*   Display selected NF-e in NF writer
      PERFORM display_nfe USING c_100.
    WHEN 'REQ_CANCEL'.
*   Call outbound FB to request authorization for NF-e cancellation
      PERFORM request_cancellation.
    WHEN 'REQ_AGAIN'.                                       "1161951
*   Call outbound FB to request author. to cancel NF-e again   "1161951
      PERFORM request_cancellation_again.                   "1161951
    WHEN 'CONTING'.
*   Continue processing under contingency
      PERFORM contingency.
    WHEN 'CONTING_RS'.
*   Reset contingency for selected NF-e
      PERFORM contingency_reset.
    WHEN 'RES_REJECT'.                                      "1248320
*   Rest NF-e rejected from SEFAZ or with validation error     "1248320
      PERFORM reset_rejected_nfe.                           "1248320
    WHEN 'RESEND_NFE'.
*   Resend NF-e request (authorization, cancellation, skipping)
      PERFORM send_nfe_again.
    WHEN 'SEND_NFE'.
*   Send NF-e to SEFAZ
      PERFORM send_nfe.
    WHEN 'SET_NUM'.                                         "1265172
*   Determine NF-e number and Send NF-e to SEFAZ               "1265172
      PERFORM set_nfe_number.                               "1265172
    WHEN 'DELETE_LOG'.
*   Delete error-log entries for selected NF-e
      PERFORM delete_error_log.
    WHEN 'ACCEPT_REJ'.
*   Set SCS to '8' - "Rejection of cancellation request accepte"
      PERFORM set_scs_to_8.
    WHEN 'SYNC_CANCL'.                                      " 1517982
*   Synchronize Cancellation Status with GRC if Cancellation allowed      " 1517982
      PERFORM synchronize_cancellation.                     " 1517982
    WHEN c_fcode_cancel_pa.                                 "1566913
*   Cancel NF-e prior to Authorization                                    "1566913
      PERFORM cancel_prior_auth.                            "1566913
    WHEN 'FIRST_PAGE'.
      PERFORM grid_scroll USING c_100.
    WHEN 'NEXT_PAGE'.
      PERFORM grid_scroll USING c_100.
    WHEN 'PREV_PAGE'.
      PERFORM grid_scroll USING c_100.
    WHEN 'LAST_PAGE'.
      PERFORM grid_scroll USING c_100.
    WHEN 'C_REGION'.
*   Maintain contingency settings per region
      PERFORM contingency_central USING 'REGION'.
    WHEN 'C_BUPLA'.
*   Maintain contingency settings per business place (branch)
      PERFORM contingency_central USING 'BUPLA'.
    WHEN 'CHECK_MS'.
*   Check connection to messaging system
      PERFORM check_connection.
* begin note 1485877
    WHEN 'GAP_NUM'.
*   Open view J_1BNFENUMCHECKV to see what is the last checked NF-e number
      PERFORM open_gapview.
    WHEN 'GAP_REP'.
*   Run report J_1BNFECHECKNUMBERRANGES, to check gaps and to requests skipping
      SUBMIT j_1bnfechecknumberranges
         VIA SELECTION-SCREEN
             WITH so_bukrs-low EQ bukrs-low                 "#EC *
             WITH so_branc-low EQ bupla-low                 "#EC *
         AND RETURN.
    WHEN 'GAP_MONI'.
*   Open the selection for showing the gaps (table J_1BNFENUMGAP).
      SUBMIT j_1bnfe_gapmonitor
         VIA SELECTION-SCREEN
             WITH so_bukrs  IN bukrs                       "#EC SUB_PAR
             WITH so_bupla  IN bupla                       "#EC SUB_PAR
             WITH so_date0  IN date0                       "#EC SUB_PAR
             WITH so_form   IN form                        "#EC SUB_PAR
         AND RETURN.
*end note 1485877
    WHEN 'CCE'.                                             "1575364
      lv_mode = gc_cce_create.                              "1575364
      PERFORM correction_letter USING lv_mode.              "1575364
    WHEN 'RESEND_CCE'.                                      "1575364
      lv_mode = gc_cce_resend.                              "1575364
      PERFORM correction_letter USING lv_mode.              "1575364
    WHEN 'CCED'.                                            "1575364
      PERFORM correction_letter_display.                    "1575364
    WHEN 'PRINT_NFE'.                                       "1723841
      PERFORM request_print.                                "1723841
  ENDCASE.
  CLEAR ok_code.

ENHANCEMENT-POINT YPDF_EDOCS_2 SPOTS YPDF_2.

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
ENDMODULE.                 " user_command_0100  INPUT