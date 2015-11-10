FUNCTION z_busca_email.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_CHAVE) TYPE  /XNFE/ID OPTIONAL
*"  EXPORTING
*"     VALUE(EMAIL) TYPE  STRING
*"----------------------------------------------------------------------

  DATA: lv_nfe_exists TYPE abap_bool,
        lv_guid       TYPE /xnfe/guid_16.

  DATA: ls_nfehd   TYPE /xnfe/outnfehd,
        ls_nfehist TYPE /xnfe/outhist,
        lt_nfehist TYPE /xnfe/outhist_t.

  DATA: lv_rfcdest TYPE rfcdes-rfcdest,
        lv_docnum  TYPE /xnfe/docnum,
        lv_logsys  TYPE logsys.

  DATA: c_sendbuy1 TYPE /xnfe/proc_step VALUE 'SENDBUYR',
        c_sendbuy2 TYPE /xnfe/proc_step VALUE 'NFOB2BBU',
        c_sendbuy3 TYPE /xnfe/proc_step VALUE 'NFEB2BBU',
        c_sendcar1 TYPE /xnfe/proc_step VALUE 'SENDCARR',
        c_sendcar2 TYPE /xnfe/proc_step VALUE 'NFOB2BCA',
        c_sendcar3 TYPE /xnfe/proc_step VALUE 'NFEB2BCA'.

  CALL FUNCTION '/XNFE/OUTNFE_EXISTS'
    EXPORTING
      iv_nfeid      = i_chave
    IMPORTING
      ev_nfe_exists = lv_nfe_exists
      ev_guid       = lv_guid.

  IF lv_nfe_exists = abap_true.

    CALL FUNCTION '/XNFE/OUTNFE_READ'
      EXPORTING
        iv_guid            = lv_guid
        with_enqueue       = space
      IMPORTING
        es_nfehd           = ls_nfehd
        et_hist            = lt_nfehist
      EXCEPTIONS
        nfe_does_not_exist = 1
        nfe_locked         = 2
        technical_error    = 3
        OTHERS             = 4.

    CHECK sy-subrc = 0.

    lv_logsys = ls_nfehd-logsys.
    lv_docnum = ls_nfehd-docnum.
  ELSE.
    CALL FUNCTION '/XNFE/OBNFE_EXISTS'
      EXPORTING
        iv_nfeid      = i_chave
      IMPORTING
        ev_nfe_exists = lv_nfe_exists
        ev_guid       = lv_guid.

    IF sy-subrc <> 0.
      SELECT SINGLE logsys docnum
        INTO ( lv_logsys, lv_docnum )
        FROM /xnfe/nfehd
       WHERE id = i_chave.

      IF sy-subrc NE 0.
        SELECT SINGLE logsys docnum
          INTO ( lv_logsys, lv_docnum )
          FROM /xnfe/outnfehd
         WHERE id = i_chave.

        "CHECK sy-subrc EQ 0.
      ENDIF.

      CALL FUNCTION '/XNFE/OBNFE_READ'
        EXPORTING
          iv_guid  = lv_guid
          iv_nfeid = i_chave
*         WITH_ENQUEUE             = 'X'
        IMPORTING
*         ET_HDSTA =
          et_hist  = lt_nfehist
*         EV_HISTCOUNT             =
*         ET_SYMSG =
*          EXCEPTIONS
*         NFE_DOES_NOT_EXIST       = 1
*         OTHERS   = 2
        .
      CHECK sy-subrc = 0.
    ENDIF.
  ENDIF.
* Determinar sistema da chamada da RFC
  CALL FUNCTION '/XNFE/READ_RFC_DESTINATION'
    EXPORTING
      iv_logsys     = lv_logsys
    IMPORTING
      ev_rfcdest    = lv_rfcdest
    EXCEPTIONS
      no_dest_found = 1.

  SORT lt_nfehist BY histcount DESCENDING.

  LOOP AT lt_nfehist INTO ls_nfehist.
    CASE ls_nfehist-procstep.
      WHEN c_sendbuy1 OR c_sendbuy2 OR c_sendbuy3.
*     Chamar Função no ECC para carregar E-mail
*        CALL FUNCTION 'YNFEIN0001'
*          DESTINATION lv_rfcdest
*          EXPORTING
*            docnum  = lv_docnum
*            buyer   = abap_true
*            carrier = abap_false
*          IMPORTING
*            e_mail  = email.

        EXIT.

      WHEN c_sendcar1 OR c_sendcar2 OR c_sendcar3.
*     Chamar Função no ECC para carregar E-mail
        CALL FUNCTION 'YNFEIN0001'
          DESTINATION lv_rfcdest
          EXPORTING
            docnum  = lv_docnum
            buyer   = abap_false
            carrier = abap_true
          IMPORTING
            e_mail  = email.
        EXIT.
    ENDCASE.
  ENDLOOP.

ENDFUNCTION.