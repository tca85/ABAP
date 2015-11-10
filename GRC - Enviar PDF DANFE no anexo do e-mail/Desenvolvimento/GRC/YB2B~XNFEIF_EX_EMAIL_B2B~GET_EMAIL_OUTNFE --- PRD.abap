  method /XNFE/IF_EX_EMAIL_B2B~GET_EMAIL_OUTNFE.

  DATA: lv_rfcdest TYPE rfcdes-rfcdest,
        lv_logsys  TYPE LOGSYS,
        lv_stcd1   type c LENGTH 14,
        lv_stcd2   type c LENGTH 11.

* Determinar sistema da chamada da RFC
  CALL FUNCTION '/XNFE/READ_RFC_DESTINATION'
    EXPORTING
      iv_logsys     = is_outnfehd-logsys
    IMPORTING
      ev_rfcdest    = lv_rfcdest
    EXCEPTIONS
      no_dest_found = 1.

*  IF iv_scenario = 'BUYER'.
*     lv_stcd1 = is_outnfehd-cnpj_dest.
*     lv_stcd2 = is_outnfehd-cpf_dest.
*  ELSE.
*     lv_stcd1 = is_outnfehd-cnpj_transp.
*     lv_stcd2 = is_outnfehd-cpf_transp.
*  ENDIF.
*
** Chamar Função no ECC para carregar E-mail
*  CALL FUNCTION 'YNFEIN1001'
*      DESTINATION lv_rfcdest
*       EXPORTING
*         i_stcd1 = lv_stcd1
*         i_stcd2 = lv_stcd2
*       IMPORTING
*         e_mail  = ev_commparam.

      CALL FUNCTION 'Z_BUSCA_EMAIL'
       EXPORTING
         i_chave       = is_outnfehd-id
       IMPORTING
         email         = ev_commparam.

endmethod.
