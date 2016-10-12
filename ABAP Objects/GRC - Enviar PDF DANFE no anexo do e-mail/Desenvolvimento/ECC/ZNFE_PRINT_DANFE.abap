*&---------------------------------------------------------------------*
*& Report    YYPCL_PRINT_DANFE                                         *
*&---------------------------------------------------------------------*
*&  Print of DANFE by SmartForm                                        *
*&  Should be used together with Message Control (NAST)                *
*&  Basically, a copy of J_1BNFPR                                      *
*&---------------------------------------------------------------------*
REPORT  yypcl_print_danfe MESSAGE-ID 8b.
*======================================================================*
*  TABLES, INCLUDES, STRUCTURES, DATAS, ...                            *
*======================================================================*

*----------------------------------------------------------------------*
*  TABLES                                                              *
*----------------------------------------------------------------------*
* tables ---------------------------------------------------------------
TABLES: j_1bnfdoc,
        vbrk,                          " billing document header
        bkpf,                          " financial document header
        j_1bnfe_event,
        j_1bnfe_cce,
        ynfe_transporte,
* Ajuste - 28.03.2011 - Walmir Olgas - DANFE - Inicio
*        konv,
* Ajuste - 28.03.2011 - Walmir Olgas - DANFE - Fim
        j_1bnfe_active,
        j_1b_nfe_access_key.
*----------------------------------------------------------------------*
*  INCLUDES                                                            *
*----------------------------------------------------------------------*
* INCLUDE for General Table Descriptions for Print Programs ------------
INCLUDE rvadtabl.
INCLUDE znfe_j_1bnfpr_printinc.

*----------------------------------------------------------------------*
*  STRUCTURES                                                          *
*----------------------------------------------------------------------*
* Nota Fiscal header structure -----------------------------------------
DATA: BEGIN OF wk_header.
        INCLUDE STRUCTURE j_1bnfdoc.
DATA: END OF wk_header.

* Nota Fiscal header structure - add. segment --------------------------
DATA: BEGIN OF wk_header_add.
        INCLUDE STRUCTURE j_1bindoc.
DATA: END OF wk_header_add.

* Nota Fiscal partner structure ----------------------------------------
DATA: BEGIN OF wk_partner OCCURS 0.
        INCLUDE STRUCTURE j_1bnfnad.
DATA: END OF wk_partner.

* Nota Fiscal item structure -------------------------------------------
DATA: BEGIN OF wk_item OCCURS 0.
        INCLUDE STRUCTURE j_1bnflin.
DATA: END OF wk_item.

* Nota Fiscal item structure - add. segment ----------------------------
DATA: BEGIN OF wk_item_add OCCURS 0.
        INCLUDE STRUCTURE j_1binlin.
DATA: END OF wk_item_add.

* Nota Fiscal item tax structure ---------------------------------------
DATA: BEGIN OF wk_item_tax OCCURS 0.
        INCLUDE STRUCTURE j_1bnfstx.
DATA: END OF wk_item_tax.

* Nota Fiscal header message structure ---------------------------------
DATA: BEGIN OF wk_header_msg OCCURS 0.
        INCLUDE STRUCTURE j_1bnfftx.
DATA: END OF wk_header_msg.

* Nota Fiscal reference to header message structure -------------------
DATA: BEGIN OF wk_refer_msg OCCURS 0.
        INCLUDE STRUCTURE j_1bnfref.
DATA: END OF wk_refer_msg.

* auxiliar structure for vbrk key (used to update FI) ------------------
DATA: BEGIN OF key_vbrk,
        vbeln LIKE vbrk-vbeln,
      END OF key_vbrk.

DATA: my_destination LIKE j_1binnad,
      my_issuer      LIKE j_1binnad,
      my_carrier     LIKE j_1binnad,
      my_items       LIKE j_1bprnfli OCCURS 0 WITH HEADER LINE.

DATA: fm_name        TYPE rs38l_fnam.

DATA: BEGIN OF inter_total_table OCCURS 0,
        matorg    LIKE j_1bprnfli-matorg,
        taxsit    LIKE j_1bprnfli-taxsit,
        icmsrate  LIKE j_1bprnfli-icmsrate,
        condensed TYPE c,
        nfnett    LIKE j_1bprnfli-nfnett,
      END OF inter_total_table.

*---data for SmartForms---*
DATA: output_options TYPE ssfcompop. " transfer printer to SM
DATA: control_parameters TYPE ssfctrlop.

* Tabela para dados da fatura (SMARTFORMS).
DATA: w_danfe  TYPE znfedanfe_header.

*----------------------------------------------------------------------*
*  DATA AND CONSTANTS                                                 *
*----------------------------------------------------------------------*
DATA: wk_docnum     TYPE j_1bnfdoc-docnum,
      retcode       TYPE sy-subrc,
      xscreen,
      wk_xblnr      TYPE bkpf-xblnr,
      subrc_upd_bi  TYPE sy-subrc.
DATA: bi_subrc      TYPE sy-subrc,
      fi_subrc      TYPE sy-subrc.

CLASS cl_exithandler DEFINITION LOAD.

DATA: gs_nfeactive TYPE        j_1bnfe_active,
      lr_badi      TYPE REF TO zif_ex_nfe.

DATA v_docnum_pdf  TYPE j_1bnfdoc-docnum.
DATA v_seqnum      TYPE j_1bnfe_event-seqnum.
DATA v_vbeln       TYPE likp-vbeln.

* Ajuste - 28.03.2011 - Walmir Olgas - DANFE - Inicio
*DATA: gv_knumv LIKE vbrk-knumv,
*      gv_kwert LIKE konv-kwert,
*      gv_fkart LIKE vbrk-fkart,
*      gv_vkorg LIKE vbrk-vkorg.
* Ajuste - 28.03.2011 - Walmir Olgas - DANFE - Fim

*======================================================================*
*  PROGRAM                                                             *
*======================================================================*

*&---------------------------------------------------------------------*
*&       FORM ENTRY  (MAIN FORM)                                       *
*&---------------------------------------------------------------------*
*       Form for Message Control                                       *
*----------------------------------------------------------------------*
FORM entry USING return_code us_screen.

  CLEAR: retcode.
  xscreen = us_screen.

  DATA: v_sform TYPE tdsfname.

  SELECT SINGLE sform
         INTO v_sform
         FROM tnapr
         WHERE kschl EQ 'NF01'
           AND kappl EQ 'NF'
           AND nacha EQ '1'.

  IF sy-subrc EQ 0.
    IF NOT v_sform IS INITIAL.
      tnapr-sform = v_sform.
      CLEAR tnapr-funcname.
      CLEAR tnapr-fonam.
    ENDIF.
  ENDIF.

  IF lr_badi IS INITIAL.

    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
        exit_name                     = 'ZNFE'
      CHANGING
        instance                      = lr_badi
      EXCEPTIONS
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        OTHERS                        = 9.

    IF sy-subrc <> 0.                                       "#EC NEEDED
    ENDIF.

  ENDIF.

  PERFORM smart_sub_printing.

* main -----------------------------------------------------------------

* check retcode (return code) ------------------------------------------
  IF retcode NE 0.
    return_code = 1.
  ELSE.
    return_code = 0.
  ENDIF.

ENDFORM.                               " ENTRY

*&---------------------------------------------------------------------*
*&       FORM ENTRY  (MAIN FORM)                                       *
*&---------------------------------------------------------------------*
*       Form for Message Control                                       *
*----------------------------------------------------------------------*
FORM entry_pdf USING docnum.

  CLEAR: v_docnum_pdf, v_seqnum.

  CLEAR: retcode.
*  XSCREEN = US_SCREEN.
  v_docnum_pdf  = docnum.

  DATA: v_sform TYPE tdsfname.

  SELECT SINGLE sform
         INTO v_sform
         FROM tnapr
         WHERE kschl EQ 'NF01'
           AND kappl EQ 'NF'
           AND nacha EQ '1'.

  IF sy-subrc EQ 0.
    IF NOT v_sform IS INITIAL.
      tnapr-sform = v_sform.
      CLEAR tnapr-funcname.
      CLEAR tnapr-fonam.
    ENDIF.
  ENDIF.

  IF lr_badi IS INITIAL.

    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
        exit_name                     = 'ZNFE'
      CHANGING
        instance                      = lr_badi
      EXCEPTIONS
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        OTHERS                        = 9.

    IF sy-subrc <> 0.                                       "#EC NEEDED
    ENDIF.

  ENDIF.

  PERFORM smart_sub_printing.

** main -----------------------------------------------------------------
*
** check retcode (return code) ------------------------------------------
*  IF RETCODE NE 0.
*    RETURN_CODE = 1.
*  ELSE.
*    RETURN_CODE = 0.
*  ENDIF.

ENDFORM.                               " ENTRY

*&---------------------------------------------------------------------*
*&       FORM ENTRY  (MAIN FORM)                                       *
*&---------------------------------------------------------------------*
*       Form for Message Control                                       *
*----------------------------------------------------------------------*
FORM entry_pdf_cce USING docnum seqnum.

  CLEAR: v_docnum_pdf, v_seqnum.

  CLEAR: retcode.
*  XSCREEN = US_SCREEN.
  v_docnum_pdf  = docnum.
  v_seqnum      = seqnum.

  DATA: v_sform TYPE tdsfname.

  SELECT SINGLE sform
         INTO v_sform
         FROM tnapr
         WHERE kschl EQ 'NF01'
           AND kappl EQ 'NF'
           AND nacha EQ '1'.

  IF sy-subrc EQ 0.
    IF NOT v_sform IS INITIAL.
      tnapr-sform = v_sform.
      CLEAR tnapr-funcname.
      CLEAR tnapr-fonam.
    ENDIF.
  ENDIF.

  IF lr_badi IS INITIAL.

    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
        exit_name                     = 'ZNFE'
      CHANGING
        instance                      = lr_badi
      EXCEPTIONS
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        OTHERS                        = 9.

    IF sy-subrc <> 0.                                       "#EC NEEDED
    ENDIF.

  ENDIF.

  PERFORM smart_sub_printing.

** main -----------------------------------------------------------------
*
** check retcode (return code) ------------------------------------------
*  IF RETCODE NE 0.
*    RETURN_CODE = 1.
*  ELSE.
*    RETURN_CODE = 0.
*  ENDIF.

ENDFORM.                               " ENTRY
*&---------------------------------------------------------------------*
*&      Form  NOTA_FISCAL_READ
*&---------------------------------------------------------------------*
*       Read the Nota Fiscal based in the key giving by Message        *
*       Control.                                                       *
*----------------------------------------------------------------------*
FORM nota_fiscal_read .

  IF v_docnum_pdf IS INITIAL.
    MOVE nast-objky TO wk_docnum.
  ELSE.
    MOVE v_docnum_pdf TO wk_docnum.
  ENDIF.

  CALL FUNCTION 'J_1B_NF_DOCUMENT_READ'
    EXPORTING
      doc_number         = wk_docnum
    IMPORTING
      doc_header         = wk_header
    TABLES
      doc_partner        = wk_partner
      doc_item           = wk_item
      doc_item_tax       = wk_item_tax
      doc_header_msg     = wk_header_msg
      doc_refer_msg      = wk_refer_msg
    EXCEPTIONS
      document_not_found = 1
      docum_lock         = 2
      OTHERS             = 3.

* check the sy-subrc ---------------------------------------------------
  PERFORM check_error.

  CALL FUNCTION 'J_1B_NF_VALUE_DETERMINATION'
    EXPORTING
      nf_header   = wk_header
    IMPORTING
      ext_header  = wk_header_add
    TABLES
      nf_item     = wk_item
      nf_item_tax = wk_item_tax
      ext_item    = wk_item_add.

ENDFORM.                               " NOTA_FISCAL_READ
*&---------------------------------------------------------------------*
*&      Form  NOTA_FISCAL_NUMBER
*&---------------------------------------------------------------------*
*       Get the next Nota Fiscal number                                *
*----------------------------------------------------------------------*
FORM nota_fiscal_number.

  CALL FUNCTION 'J_1B_NF_NUMBER_GET_NEXT'
    EXPORTING
      bukrs                         = wk_header-bukrs
      branch                        = wk_header-branch
      form                          = wk_header-form
      headerdata                    = wk_header
    IMPORTING
      nf_number                     = wk_header-nfnum
    EXCEPTIONS
      print_number_not_found        = 1
      interval_not_found            = 2
      number_range_not_internal     = 3
      object_not_found              = 4
      other_problems_with_numbering = 5
      OTHERS                        = 6.

  PERFORM check_error.

ENDFORM.                               " NOTA_FISCAL_NUMBER

*&---------------------------------------------------------------------*
*&      Form  NOTA_FISCAL_UPDATE
*&---------------------------------------------------------------------*
*       Update NF date and number                                      *
*----------------------------------------------------------------------*
FORM nota_fiscal_update.

  wk_header-printd = 'X'.

  UPDATE j_1bnfdoc SET printd = wk_header-printd
                       follow = wk_header-follow
                 WHERE docnum = wk_header-docnum.

  IF sy-subrc <> 0.
    retcode = sy-subrc.
    syst-msgid = '8B'.
    syst-msgno = '107'.
    syst-msgty = 'E'.
    syst-msgv1 = wk_header-docnum.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                               " NOTA_FISCAL_UPDATE
*&---------------------------------------------------------------------*
*&      Form  CHECK_ERROR
*&---------------------------------------------------------------------*
*       Check return code                                              *
*----------------------------------------------------------------------*
FORM check_error.

  IF sy-subrc <> 0.
    retcode = sy-subrc.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                               " CHECK_ERROR
*&---------------------------------------------------------------------*
*&      Form  PROTOCOL_UPDATE
*&---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.        *
*----------------------------------------------------------------------*
FORM protocol_update.

  CHECK xscreen = space.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.                               " PROTOCOL_UPDATE
*&---------------------------------------------------------------------*
*&      Form  FINANCIAL_DOC_UPDATE
*&---------------------------------------------------------------------*
*       Update the sales document and Financial document with the      *
*       Nota Fiscal number and the Nota Fiscal with the financial      *
*       document                                                       *
*----------------------------------------------------------------------*
FORM financial_doc_update.

  SORT wk_item.
  READ TABLE wk_item INDEX 1.

  CALL FUNCTION 'J_1B_NF_NUMBER_CONDENSE'
    EXPORTING
      nf_number  = wk_header-nfnum
      series     = wk_header-series
      subseries  = wk_header-subser
      nf_number9 = wk_header-nfenum
    IMPORTING
      ref_number = wk_xblnr
    EXCEPTIONS
      OTHERS     = 1.

* get the type of the document and update the documents ----------------
  CASE wk_item-reftyp.

    WHEN 'BI'.
      MOVE wk_item-refkey TO key_vbrk.
      PERFORM read_bi_document.
      CLEAR bkpf.
      IF NOT vbrk IS INITIAL.          " if find VBRK (Billing document)
        PERFORM get_fi_number.
      ENDIF.
      IF bkpf-belnr IS INITIAL.        " there is not FI document
        IF NOT vbrk IS INITIAL.        " if find VBRK (Billing document)
          PERFORM update_bi_document.
        ENDIF.
      ELSE.                            " there is FI document
        PERFORM update_bi_document.
        IF  subrc_upd_bi IS INITIAL.   " update in billing ok.
          PERFORM update_fi_nf_document
                    USING bkpf-bukrs bkpf-belnr bkpf-gjahr.
          PERFORM update_bsid_nf_document
                  USING bkpf-bukrs bkpf-belnr bkpf-gjahr.
        ENDIF.
      ENDIF.

    WHEN OTHERS.  " for MD or <space> that means writer.
      wk_header-follow = 'X'.

  ENDCASE.

ENDFORM.                               " FINANCIAL_DOC_UPDATE

*&---------------------------------------------------------------------*
*&      Form  READ_BI_DOCUMENT
*&---------------------------------------------------------------------*
*       This form read the billing document                            *
*----------------------------------------------------------------------*
FORM read_bi_document.

  SELECT SINGLE * FROM  vbrk
         WHERE  vbeln       = key_vbrk-vbeln.

  IF sy-subrc <> 0.
    CLEAR vbrk.
  ENDIF.

ENDFORM.                               " READ_BI_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  READ_FI_DOCUMENT
*&---------------------------------------------------------------------*
*       read the fi_document                                           *
*----------------------------------------------------------------------*
FORM read_fi_document USING xbukrs xbelnr xgjahr.

  SELECT SINGLE * FROM  bkpf
         WHERE  bukrs       = xbukrs
         AND    belnr       = xbelnr
         AND    gjahr       = xgjahr.

  IF sy-subrc <> 0.
    CLEAR bkpf.
  ENDIF.

ENDFORM.                               " READ_FI_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  UPDATE_BI_DOCUMENT
*&---------------------------------------------------------------------*
*       Update billing document                                        *
*----------------------------------------------------------------------*
FORM update_bi_document.

  IF bi_subrc = 0.                     " billing not lock

    UPDATE vbrk SET xblnr = wk_xblnr
                WHERE  vbeln = key_vbrk-vbeln.

    PERFORM check_error.

    subrc_upd_bi = sy-subrc.

    CALL FUNCTION 'DEQUEUE_EVVBRKE'
      EXPORTING
        mandt  = sy-mandt
        vbeln  = key_vbrk-vbeln
      EXCEPTIONS
        OTHERS = 1.

  ELSE.                                " billing lock

    subrc_upd_bi = sy-subrc.

  ENDIF.

ENDFORM.                               " UPDATE_BI_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  UPDATE_FI_NF_DOCUMENT
*&---------------------------------------------------------------------*
*       Update financial and nota fiscal document                      *
*----------------------------------------------------------------------*
FORM update_fi_nf_document USING xbukrs xbelnr xgjahr.

  IF fi_subrc = 0.                     " billing not lock

    UPDATE bkpf SET xblnr = wk_xblnr
                WHERE  bukrs       = xbukrs
                AND    belnr       = xbelnr
                AND    gjahr       = xgjahr.

    PERFORM check_error.

    wk_header-follow = 'X'.

  ENDIF.

ENDFORM.                               " UPDATE_FI_NF_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  GET_FI_NUMBER
*&---------------------------------------------------------------------*
*       Read financial document via Billing document number            *
*----------------------------------------------------------------------*
FORM get_fi_number.

  SELECT SINGLE * FROM  bkpf
         WHERE  bukrs = vbrk-bukrs
         AND    awtyp = 'VBRK'
         AND    awkey = key_vbrk-vbeln.

  IF sy-subrc <> 0.
    CLEAR bkpf.
  ENDIF.

ENDFORM.                               " GET_FI_NUMBER


*&---------------------------------------------------------------------*
*&      Form  UPDATE_BSID_NF_DOCUMENT
*&---------------------------------------------------------------------*
*  update table BSID with external Nota Fiscal number - KI3K050466
*  change 23.01.97
*  Change 28.06.2000:
*  update also BSIS if G/L account with line item display exists
*  Change 09.08.2000: if cust account already cleared
*    (e.g. credit card sales) update BSAD instead of BSID
*----------------------------------------------------------------------*
FORM update_bsid_nf_document USING xbukrs xbelnr xgjahr.

  TABLES: bseg,
          bsid,
          bsis,
          bsad.

  SELECT * FROM bseg WHERE bukrs = xbukrs
                       AND belnr = xbelnr
                       AND gjahr = xgjahr
                       AND ( koart = 'D' OR koart = 'S' ).
    IF sy-subrc = '0'.
      IF bseg-koart = 'D'.
        IF NOT bseg-augbl IS INITIAL.  " account cleared --> update BSAD
          UPDATE bsad SET xblnr = wk_xblnr
                    WHERE bukrs = bseg-bukrs
                      AND kunnr = bseg-kunnr
                      AND umsks = bseg-umsks
                      AND umskz = bseg-umskz
                      AND augdt = bseg-augdt
                      AND augbl = bseg-augbl
                      AND zuonr = bseg-zuonr
                      AND gjahr = bseg-gjahr
                      AND belnr = bseg-belnr
                      AND buzei = bseg-buzei.

        ELSE.   " open item --> update BSID
* Customer account --> update BSID
          UPDATE bsid SET xblnr = wk_xblnr
                    WHERE bukrs = bseg-bukrs
                      AND kunnr = bseg-kunnr
                      AND umsks = bseg-umsks
                      AND umskz = bseg-umskz
                      AND augdt = bseg-augdt
                      AND augbl = bseg-augbl
                      AND zuonr = bseg-zuonr
                      AND gjahr = bseg-gjahr
                      AND belnr = bseg-belnr
                      AND buzei = bseg-buzei.
          IF sy-subrc EQ 0.
            CALL FUNCTION 'OPEN_FI_PERFORM_00005010_P'
              EXPORTING
                i_chgtype     = 'U'
                i_origin      = 'J_1BNFPR UPDATE_BSID_NF_DOCUMENT'
                i_tabname     = 'BSID'
                i_where_bukrs = bseg-bukrs
                i_where_kunnr = bseg-kunnr
                i_where_umsks = bseg-umsks
                i_where_umskz = bseg-umskz
                i_where_augdt = bseg-augdt
                i_where_augbl = bseg-augbl
                i_where_zuonr = bseg-zuonr
                i_where_gjahr = bseg-gjahr
                i_where_belnr = bseg-belnr
                i_where_buzei = bseg-buzei
              EXCEPTIONS
                OTHERS        = 1.
            IF sy-subrc NE 0.
              MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ELSE.
            PERFORM check_error.                            " 793934
          ENDIF. " BSID update ok
        ENDIF. " Clearing status: BSID or BSAD
      ENDIF.  " Debitor Accounts, Note 793934

* Always try to udate BSIS, regardless of account type (Note 793934)

*  G/L account --> try to update BSIS
      UPDATE bsis SET xblnr = wk_xblnr
                WHERE bukrs = bseg-bukrs
                  AND gjahr = bseg-gjahr
                  AND belnr = bseg-belnr
                  AND buzei = bseg-buzei.
* Update only possible for G/L accounts with line item display
*   --> Print NF even for update failure in bsis
      CLEAR sy-subrc.
    ENDIF. " Reading BSEG
  ENDSELECT.

* perform unlocking of the fi document only after the update of BSID,
* because this table must also be locked during update - the following
* call function was before in the form update_fi_nf_document.

  CALL FUNCTION 'DEQUEUE_EFBKPF'
    EXPORTING
      bukrs  = xbukrs
      belnr  = xbelnr
      gjahr  = xgjahr
    EXCEPTIONS
      OTHERS = 1.

ENDFORM.                               " UPDATE_BSID_NF_DOCUMENT

*---------------------------------------------------------------------*
*       FORM ENQUEUE_BI_FI                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM enqueue_bi_fi.

  CLEAR bi_subrc.

* sort the wk_item to get the first item
  SORT wk_item.
  READ TABLE wk_item INDEX 1.

  CHECK wk_item-reftyp = 'BI'.
  MOVE wk_item-refkey TO key_vbrk.

  PERFORM read_bi_document.

  IF NOT vbrk IS INITIAL.              "call via SD
    CALL FUNCTION 'ENQUEUE_EVVBRKE'
      EXPORTING
        mandt          = sy-mandt
        vbeln          = key_vbrk-vbeln
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.

    bi_subrc = sy-subrc.
    PERFORM check_error.
    IF bi_subrc = 0.                   "BI document not locked
      CLEAR bkpf.
      PERFORM get_fi_number.
      IF NOT bkpf-belnr IS INITIAL.
        CALL FUNCTION 'ENQUEUE_EFBKPF'
          EXPORTING
            bukrs          = bkpf-bukrs
            belnr          = bkpf-belnr
            gjahr          = bkpf-gjahr
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.

        fi_subrc = sy-subrc.
        PERFORM check_error.
        IF fi_subrc <> 0.     "FI lock not successful -> release BI lock
          CALL FUNCTION 'DEQUEUE_EVVBRKE'
            EXPORTING
              mandt  = sy-mandt
              vbeln  = key_vbrk-vbeln
            EXCEPTIONS
              OTHERS = 1.
          PERFORM check_error.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                               " ENQUEUE_BI_FI
*&---------------------------------------------------------------------*
*&      Form  check_nf_canceled
*&---------------------------------------------------------------------*
*       allow print of NF only when NF is not canceled
*----------------------------------------------------------------------*
FORM check_nf_canceled.
  DATA: lv_dummy  TYPE c.

  IF NOT wk_header-cancel IS INITIAL AND wk_header-nfnum IS INITIAL.
    sy-subrc = 1.
    MESSAGE ID '8B'
            TYPE 'E'
            NUMBER '678'
            WITH wk_header-docnum
            INTO lv_dummy.

    PERFORM check_error.
    IF sy-batch IS INITIAL.                " corr. of note 442570
      MESSAGE e678 WITH wk_header-docnum.
    ENDIF.                                 " corr. of note 442570
  ENDIF.
ENDFORM.                    " check_nf_canceled
*&---------------------------------------------------------------------*
*&      Form  check_nfe_authorized
*&---------------------------------------------------------------------*
FORM check_nfe_authorized.
  DATA: lv_dummy  TYPE c,
        lv_subrc  TYPE sy-subrc,
        obj_ref   TYPE REF TO if_ex_cl_nfe_print.

  CLEAR gs_nfeactive.

* only NFes
  CHECK wk_header-nfe = 'X'.

  SELECT SINGLE * FROM j_1bnfe_active INTO gs_nfeactive
  WHERE docnum = wk_header-docnum.

  IF NOT sy-subrc IS INITIAL.
    MESSAGE e012 WITH wk_header-docnum.
  ENDIF.

  IF gs_nfeactive-code IS INITIAL.

    COMMIT WORK AND WAIT.
    WAIT UP TO 3 SECONDS.

    SELECT SINGLE * FROM j_1bnfe_active INTO gs_nfeactive
    WHERE docnum = wk_header-docnum.

    IF NOT sy-subrc IS INITIAL.
      MESSAGE e012 WITH wk_header-docnum.
    ENDIF.

  ENDIF.

  j_1bnfe_active = gs_nfeactive.

* don't print NF-e when ...
* ... rejected docsta = 2
* ... denied   docsta = 3
* ... switches manual to contingency
  IF gs_nfeactive-conting_s = 'X'
  OR gs_nfeactive-docsta    = '2'
  OR gs_nfeactive-docsta    = '3'.

    lv_subrc = 1.

  ELSE.

*-- don´t print not authorized NFes

    IF  wk_header-authcod IS INITIAL    "Nfe is not authorized
    AND wk_header-conting IS INITIAL.   "and not in contingency
      lv_subrc = 1.
    ENDIF.
  ENDIF.

*-- BADI for reset subrc
*-- When subrc is 0 NFes can be printed without aauthorization code

  IF obj_ref IS INITIAL.

    CALL METHOD cl_exithandler=>get_instance       " #EC CI_BADI_GETINST
      EXPORTING
        exit_name                     = 'CL_NFE_PRINT'
        null_instance_accepted        = seex_false
      CHANGING
        instance                      = obj_ref
      EXCEPTIONS
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        OTHERS                        = 9.

    IF sy-subrc IS INITIAL.
*- nothing to do
    ENDIF.

  ENDIF.

  IF obj_ref IS BOUND.
    CALL METHOD obj_ref->reset_subrc
      EXPORTING
        is_nfdoc = wk_header
      CHANGING
        ch_subrc = lv_subrc.
  ENDIF.

  sy-subrc = lv_subrc.

  IF sy-subrc IS NOT INITIAL.
    IF gs_nfeactive-conting_s = 'X'.
      MESSAGE ID 'J1B_NFE'
              TYPE 'E'
              NUMBER '040'
              WITH wk_header-docnum
              INTO lv_dummy.
    ELSE.
      MESSAGE ID 'J1B_NFE'
              TYPE 'E'
              NUMBER '039'
              WITH wk_header-docnum
              INTO lv_dummy.
    ENDIF.
    IF sy-batch IS INITIAL.
      PERFORM check_error.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    gs_nfeactive-printd = 'X'.
  ENDIF.

ENDFORM.                    " check_nfe_authorized
*&---------------------------------------------------------------------*
*&      Form  active_update
*&---------------------------------------------------------------------*
FORM active_update .

ENDFORM.                    " active_update
*&--------------------------------------------------------------------*
*&      Form  smart_sub_printing
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM smart_sub_printing.

  IF NOT v_seqnum IS INITIAL.
    tnapr-sform = 'YSD_CCE'.
  ENDIF.

  DATA:   tax_types LIKE j_1baj OCCURS 30 WITH HEADER LINE.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = tnapr-sform
    IMPORTING
      fm_name            = fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2.

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  REFRESH: my_items.

* read the Nota Fiscal
  PERFORM nota_fiscal_read.            " read nota fiscal

* allow print of NF only when NF is not canceled
  PERFORM check_nf_canceled.   " check nota fiscal canceled,442570

* number and update the Nota Fiscal
  CHECK retcode IS INITIAL.

* The NFe to be printed must have an authorization code
  IF wk_header-nfe = 'X'.

*   The NFe to be printed must have an authorization code
    PERFORM check_nfe_authorized.
    CHECK retcode IS INITIAL.

  ENDIF.

* Ajuste - 28.03.2011 - Walmir Olgas - DANFE - Inicio
*  PERFORM ajusta_valor_total.
* Ajuste - 28.03.2011 - Walmir Olgas - DANFE - Fim

* for NFe the DANFE is printed. Numbering has already taken place
* before sending teh XML document to SEFAZ.
* Billing document is updated for NFe with the 9 digit NFe number
  IF wk_header-entrad = 'X' OR  "update only entradas or outgoing NF
     wk_header-direct  = '2'.
    IF wk_header-printd IS INITIAL AND " not printed.
       wk_header-nfnum IS INITIAL  AND " without NF number
       nast-nacha = '1'.               " sent to printer

      PERFORM enqueue_bi_fi.
      CHECK retcode IS INITIAL.
* get NF number only for "normal NFs" NFe has already the number
      IF wk_header-nfe IS INITIAL.
        PERFORM nota_fiscal_number.      " get the next number
      ENDIF.

      IF retcode IS INITIAL.
        PERFORM financial_doc_update.    " update in database
        PERFORM nota_fiscal_update.      " update in database
        IF NOT gs_nfeactive IS INITIAL.
          PERFORM active_update ON COMMIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF retcode IS INITIAL.
  ELSE.
    MESSAGE a114 WITH '01' 'J_1BNFNUMB'.
  ENDIF.

*----------------------------------------------------------------------*
*    read tax types into internal buffer table                         *
*----------------------------------------------------------------------*
  SELECT * FROM j_1baj INTO TABLE tax_types ORDER BY PRIMARY KEY.

  CLEAR  w_danfe.
  CLEAR: w_danfe-issuer,
         w_danfe-destination,
         w_danfe-carrier,
         w_danfe-nota_fiscal,
         w_danfe-others,
         w_danfe-nfe,
         w_danfe-observ1,
         w_danfe-observ2,
         w_danfe-item,
         w_danfe-invoice.

*----------------------------------------------------------------------*
*    fill header data into communication structure                     *
*----------------------------------------------------------------------*
  MOVE-CORRESPONDING wk_header TO w_danfe-nota_fiscal.

  SELECT SINGLE *
         FROM j_1bnfe_active
         INTO w_danfe-nfe
         WHERE docnum EQ wk_header-docnum.

*---> determine CFOP length, extension and deafulttext from version
*---> table
  PERFORM get_cfop_length_smart  USING wk_header-bukrs
                                 wk_header-branch
                                 wk_header-pstdat
                        CHANGING cfop_version     " BOI note 593218
                                 cfop_length
                                 extension_length
                                 defaulttext
                                 issuer_region.

  MOVE cfop_length TO w_danfe-nota_fiscal-cfop_len.
*... fill header CFOP .................................................*

  DATA: BEGIN OF wk_cfop OCCURS 0,
    key(6)           TYPE c,
    char6(6)         TYPE c,
    dupl_text_indic  TYPE c,
    text(50)         TYPE c.
  DATA: END OF wk_cfop.
  DATA: help_cfop(6)    TYPE c,
        default_cfop(6) TYPE c,
        lv_tabix        TYPE sytabix,
        v_cfop          TYPE j_1bnflin-cfop.


  LOOP AT wk_item.
    CONCATENATE wk_item-cfop(3) '0' wk_item-cfop+4(2) INTO v_cfop.
*    wk_item-cfop = v_cfop.
    WRITE wk_item-cfop  TO help_cfop.
    help_cfop = help_cfop(cfop_length).
    CASE extension_length.
      WHEN 1.
        IF ( wk_item-cfop+1(3) = '991' OR wk_item-cfop+1(3) = '999' )
                                             AND issuer_region = 'SP'.
          CONCATENATE help_cfop '.' wk_item-cfop+3(1) INTO help_cfop.
        ENDIF.
      WHEN 2.
        IF wk_item-cfop+1(2) = '99' AND issuer_region = 'SC'.
          CONCATENATE help_cfop '.' wk_item-cfop+3(2) INTO help_cfop.
        ENDIF.
    ENDCASE.

    READ TABLE wk_cfop WITH KEY key = help_cfop.
    lv_tabix = sy-tabix.
    IF sy-subrc <> 0.  " new CFOP on this NF: append this CFOP to list
      wk_cfop-char6  =  wk_item-cfop.
      wk_cfop-key    =  help_cfop.

      SELECT SINGLE * FROM j_1bagnt   WHERE spras   = sy-langu
                                        AND version = cfop_version
                                        AND cfop    = wk_item-cfop.
      IF sy-subrc = 0.
        wk_cfop-text = j_1bagnt-cfotxt.
        APPEND wk_cfop.
      ELSE.
        encoded_cfop = wk_item-cfop.
        IF encoded_cfop(1) CA                    " BOI note 593218-470
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ[-<>=!?]'.
          WRITE wk_item-cfop  TO encoded_cfop.
          REPLACE '/' IN encoded_cfop WITH ' '.
          CONDENSE encoded_cfop NO-GAPS.
        ELSE.
          PERFORM encoding_cfop_smart CHANGING encoded_cfop.
        ENDIF.                                   " EOI note 593218-470
*PERFORM ENCODING_CFOP_SMART CHANGING ENCODED_CFOP." note 593218-470
        SELECT SINGLE * FROM j_1bagnt WHERE spras = nast-spras
                                          AND version = cfop_version
                                          AND cfop    = encoded_cfop.
        IF sy-subrc = 0.
          wk_cfop-text = j_1bagnt-cfotxt.
          APPEND wk_cfop.
        ENDIF.
      ENDIF.
    ELSE. " CFOP already on list; however, could be rel. to other text
      IF wk_cfop-char6 <> wk_item-cfop AND
                                  wk_cfop-dupl_text_indic IS INITIAL.
        default_cfop      = wk_item-cfop.
        default_cfop+4(2) = defaulttext.
        SELECT SINGLE * FROM j_1bagnt WHERE spras   = nast-spras
                                        AND version = cfop_version
                                        AND cfop    = default_cfop.
        IF sy-subrc = 0.
          wk_cfop-text = j_1bagnt-cfotxt.
          wk_cfop-dupl_text_indic = 'X'.
          MODIFY wk_cfop INDEX lv_tabix.
        ELSE.
          encoded_cfop = default_cfop.
          PERFORM encoding_cfop_smart CHANGING encoded_cfop.
          SELECT SINGLE * FROM j_1bagnt WHERE spras = nast-spras
                                          AND version = cfop_version
                                          AND cfop    = encoded_cfop.
          IF sy-subrc = 0.
            wk_cfop-text = j_1bagnt-cfotxt.
            wk_cfop-dupl_text_indic = 'X'.
            MODIFY wk_cfop INDEX lv_tabix.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE wk_cfop LINES cfop_lines.
  IF cfop_lines > 1.
    SORT wk_cfop.
    DELETE ADJACENT DUPLICATES FROM wk_cfop COMPARING key.
    LOOP AT wk_cfop.
      CONCATENATE w_danfe-nota_fiscal-cfop_text
                  '/'
                  wk_cfop-key wk_cfop-text
                  INTO w_danfe-nota_fiscal-cfop_text.
      IF w_danfe-nota_fiscal-cfop_text(1) EQ '/'.
        SHIFT w_danfe-nota_fiscal-cfop_text LEFT BY 1 PLACES.
      ENDIF.
    ENDLOOP.
  ELSEIF cfop_lines = 1.      " NF with items that all have one CFOP
    MOVE wk_cfop-key  TO w_danfe-nota_fiscal-cfop.
    MOVE wk_cfop-text TO w_danfe-nota_fiscal-cfop_text.
  ENDIF.                                             " BOI note 593218

*----------------------------------------------------------------------*
*    determine issuer and destination (only for test)                  *
*----------------------------------------------------------------------*
  IF wk_header-direct = '1'   AND
     wk_header-entrad = ' '.
    issuer-partner_type      = wk_header-partyp.
    issuer-partner_id        = wk_header-parid.
    issuer-partner_function  = wk_header-parvw.
    destination-partner_type = 'B'.
    destination-partner_id   = wk_header-bukrs.
    destination-partner_id+4 = wk_header-branch.
  ELSE.
    issuer-partner_type          = 'B'.
    issuer-partner_id            = wk_header-bukrs.
    issuer-partner_id+4          = wk_header-branch.
    destination-partner_type     = wk_header-partyp.
    destination-partner_id       = wk_header-parid.
    destination-partner_function = wk_header-parvw.
  ENDIF.

*----------------------------------------------------------------------*
*    read branch data (issuer)                                         *
*----------------------------------------------------------------------*

  CLEAR j_1binnad.

  CALL FUNCTION 'J_1B_NF_PARTNER_READ'
    EXPORTING
      partner_type           = issuer-partner_type
      partner_id             = issuer-partner_id
      partner_function       = issuer-partner_function
      doc_number             = wk_header-docnum
      obj_item               = wk_item
    IMPORTING
      parnad                 = j_1binnad
    EXCEPTIONS
      partner_not_found      = 1
      partner_type_not_found = 2
      OTHERS                 = 3.
  MOVE-CORRESPONDING j_1binnad TO w_danfe-issuer.

*... check the sy-subrc ...............................................*
  PERFORM check_error.
  CHECK retcode IS INITIAL.

*----------------------------------------------------------------------*
*    read destination data                                             *
*----------------------------------------------------------------------*

  CLEAR j_1binnad.

  CALL FUNCTION 'J_1B_NF_PARTNER_READ'
    EXPORTING
      partner_type           = destination-partner_type
      partner_id             = destination-partner_id
      partner_function       = destination-partner_function
      doc_number             = wk_header-docnum
      obj_item               = wk_item
    IMPORTING
      parnad                 = j_1binnad
    EXCEPTIONS
      partner_not_found      = 1
      partner_type_not_found = 2
      OTHERS                 = 3.
  MOVE-CORRESPONDING j_1binnad TO w_danfe-destination.

  SELECT SINGLE state_insc FROM j_1bstast
    INTO w_danfe-issuer-state_insc
   WHERE bukrs   = wk_header-bukrs
     AND branch  = wk_header-branch
     AND txreg   = w_danfe-destination-regio.

*----------------------------------------------------------------------*
*    read fatura data if the Nota Fiscal is a Nota Fiscal Fatura       *
*----------------------------------------------------------------------*

  DATA: v_loops TYPE i,
        v_linha TYPE i,
        v_index TYPE i.

  CLEAR v_linha.

  DATA v_parcelas  TYPE string.
  DATA v_zfbdt     TYPE bseg-zfbdt.
  DATA v_dtformat  TYPE string.
  DATA v_valor     TYPE string.
  DATA v_cont      TYPE n LENGTH 3.

  READ TABLE wk_item INDEX 1.
  IF sy-subrc = 0.
    SELECT SINGLE * FROM t052 WHERE zterm = wk_header-zterm.
    IF sy-subrc = 0.
      IF t052-ztag1 = 0 AND t052-ztag2 = 0 AND t052-ztag3 = 0 AND t052-xsplt <> 'X'.
        w_danfe-invoice_new = 'A vista'.
      ELSE.
        w_danfe-invoice_new = 'A prazo'.
      ENDIF.
    ENDIF.

    IF wk_item-reftyp = 'BI'.

      MOVE wk_item-refkey TO key_vbrk.

      PERFORM read_bi_document.

      CLEAR bkpf.
      IF NOT vbrk IS INITIAL.          " if find VBRK (Billing document)
        PERFORM get_fi_number.
      ENDIF.

      IF NOT bkpf-belnr IS INITIAL.        " there is not FI document

        SELECT * FROM bseg
                WHERE bukrs = bkpf-bukrs
                  AND belnr = bkpf-belnr
                  AND gjahr = bkpf-gjahr
                  AND koart = 'D'.

          ADD 1 TO v_cont.

          CALL FUNCTION 'J_1B_FI_NETDUE'
            EXPORTING
              zfbdt   = bseg-zfbdt
              zbd1t   = bseg-zbd1t
              zbd2t   = bseg-zbd2t
              zbd3t   = bseg-zbd3t
            IMPORTING
              duedate = v_zfbdt.

          IF v_zfbdt <> '00000000'.
            CONCATENATE v_zfbdt+6(2) '/' v_zfbdt+4(2) '/'  v_zfbdt(4) INTO v_dtformat.
            IF bseg-pswsl <> 'BRL'.
              v_valor = bseg-dmbtr.
            ELSE.
              v_valor = bseg-wrbtr.
            ENDIF.
            CONCATENATE v_parcelas 'Parcela.: ' v_cont ' Vence em.: ' v_dtformat ' R$.: ' v_valor INTO v_parcelas SEPARATED BY space.
          ENDIF.
        ENDSELECT.
      ENDIF.                               " there is FI document
    ENDIF.
  ENDIF.

  CLEAR j_1bprnffa.
  APPEND j_1bprnffa TO w_danfe-invoice.
  CONCATENATE w_danfe-invoice_new v_parcelas INTO w_danfe-invoice_new SEPARATED BY space.

  IF w_danfe-invoice_new = 'A vista' OR w_danfe-invoice_new = 'A prazo'.
    w_danfe-invoice_new = '.'.
  ENDIF.
*----------------------------------------------------------------------*
*    read carrier data                                                 *
*----------------------------------------------------------------------*

  IF wk_header-doctyp NE '2'.          "no carrier for Complementars

    READ TABLE wk_partner WITH KEY docnum = wk_header-docnum
                                   parvw  = 'SP'.
    IF sy-subrc <> 0.
      READ TABLE wk_partner WITH KEY docnum = wk_header-docnum
                                     parvw  = 'CA'.
    ENDIF.

    IF sy-subrc = 0.

      CLEAR j_1binnad.
      CALL FUNCTION 'J_1B_NF_PARTNER_READ'
        EXPORTING
          partner_type           = wk_partner-partyp
          partner_id             = wk_partner-parid
          partner_function       = wk_partner-parvw
          doc_number             = wk_header-docnum
        IMPORTING
          parnad                 = j_1binnad
        EXCEPTIONS
          partner_not_found      = 1
          partner_type_not_found = 2
          OTHERS                 = 3.
      MOVE-CORRESPONDING j_1binnad TO w_danfe-carrier.
    ENDIF.

  ENDIF.          "no carrier for Complementars



*----------------------------------------------------------------------*
*    read reference NF                                                 *
*----------------------------------------------------------------------*
  IF w_danfe-nota_fiscal-docref <> space.
    SELECT SINGLE * FROM j_1bnfdoc INTO *j_1bnfdoc
             WHERE docnum = w_danfe-nota_fiscal-docref.
    w_danfe-nota_fiscal-nf_docref = *j_1bnfdoc-nfnum.
    w_danfe-nota_fiscal-nf_serref = *j_1bnfdoc-series.
    w_danfe-nota_fiscal-nf_subref = *j_1bnfdoc-subser.
    w_danfe-nota_fiscal-nf_datref = *j_1bnfdoc-docdat.
  ENDIF.

*----------------------------------------------------------------------*
*    get information about form                                        *
*----------------------------------------------------------------------*

  DATA: print_conf TYPE j_1bb2.

  CALL FUNCTION 'J_1BNF_GET_PRINT_CONF'
    EXPORTING
      headerdata = wk_header
    IMPORTING
      print_conf = print_conf
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.

  PERFORM check_error.
  CHECK retcode IS INITIAL.

*----------------------------------------------------------------------*
*    write texts to TEXTS window                                       *
*----------------------------------------------------------------------*

  DATA: w_line TYPE tline.

  istart = print_conf-totlih.                       " note note 743361

  IF wk_header-land1 <> 'BR' AND wk_header-direct = '1'.
    DELETE ADJACENT DUPLICATES FROM wk_header_msg COMPARING seqnum.
  ENDIF.

  LOOP AT wk_header_msg.
    w_line-tdline = wk_header_msg-message.
    IF sy-index LT istart.
      IF sy-index EQ 1.
        w_danfe-observ1 = wk_header_msg-message.
      ELSE.
        CONCATENATE w_danfe-observ1
                    cl_abap_char_utilities=>cr_lf
                    wk_header_msg-message
                    INTO w_danfe-observ1.
      ENDIF.
      APPEND w_line TO w_danfe-text1.
    ELSE.
      IF sy-index EQ istart.
        w_danfe-observ2 = wk_header_msg-message.
      ELSE.
        CONCATENATE w_danfe-observ2
                    cl_abap_char_utilities=>cr_lf
                    wk_header_msg-message
                    INTO w_danfe-observ2.
      ENDIF.
      APPEND w_line TO w_danfe-text2.
    ENDIF.
  ENDLOOP.


* Uderson Fermino - 16.03.2015 - INICIO, textos notas
* §  --> ULF - Adição de textos adicioais
  DATA: BEGIN OF t_textos OCCURS 0.
          INCLUDE STRUCTURE ynfe_textos.
  DATA: END OF t_textos.

  DATA: wa_textos     TYPE ynfe_textos.

  SELECT * FROM ynfe_textos INTO TABLE t_textos WHERE docnum = wk_header-docnum.
  IF sy-subrc = 0.

    LOOP AT t_textos INTO wa_textos.
      CONCATENATE wa_textos-field1 wa_textos-field2 wa_textos-field3 wa_textos-field4 INTO w_line-tdline SEPARATED BY space.
      IF wa_textos-field1 = 'Desconto de Repasse:        0.00'.
        CLEAR w_line-tdline.
      ENDIF.

      IF NOT w_line-tdline IS INITIAL.
        APPEND w_line TO w_danfe-text1.
      ENDIF.
    ENDLOOP.

  ENDIF.

* Uderson Fermino - 16.03.2015 - FIM

* §  --> ULF - Adição de textos adicioais para produtos aplicado ao convenio 32/14
  DATA: ls_branch    TYPE j_1bbranch,
        ls_sadr      TYPE sadr,
        lv_cgc       TYPE j_1bcgc,
        ls_addr1_val TYPE addr1_val,
        ls_innad     TYPE j_1binnad,
        ls_j_1bstast TYPE j_1bstast.

  DATA: tb_ysdt0003  TYPE TABLE OF ysdt0003.
  DATA: w_t001w      TYPE t001w.

  DATA: BEGIN OF t_vbrk,
            vbeln TYPE vbrk-vbeln,
            fkart TYPE vbrk-fkart,
            kunag TYPE vbrk-kunag,
            bupla TYPE vbrk-bupla,
            bukrs TYPE vbrk-bukrs,
            vkorg TYPE vbrk-vkorg,
            vtweg TYPE vbrk-vtweg,
            knumv TYPE vbrk-knumv,
            bstnk TYPE vbrk-bstnk_vf,
         END OF t_vbrk.

  DATA: BEGIN OF t_kwert OCCURS 0,
          kwert TYPE konv-kwert,
          kposn TYPE konv-kposn,
          kschl TYPE konv-kschl,
        END OF t_kwert.

  DATA:   w_kwert TYPE konv-kwert,
          w_kwertz TYPE konv-kwert,
          w_kwertd TYPE konv-kwert,
          w_kwert1(13) TYPE c,
          w_kwertc(13) TYPE c,
          w_kwerte(13) TYPE c,
          w_sepa(3)    TYPE c.

  CLEAR w_line-tdline.

* §  Se encotar o produto parametrizado, seleciona dados do faturamento
  SELECT SINGLE knumv INTO t_vbrk-knumv FROM vbrk
  WHERE vbeln EQ wk_item-refkey(10).

  IF sy-subrc EQ 0.
*   §BUSCA VALORES RELACIOANDOS AO DESCONTO DO CONVENIO 32/14
    CLEAR: t_kwert, t_kwert[], w_kwert, w_kwert1.
    SELECT kwert kposn kschl FROM konv
      INTO TABLE t_kwert
      WHERE knumv = t_vbrk-knumv
        AND kschl = 'YC32'.

    IF sy-subrc = 0.
      LOOP AT t_kwert.
        w_kwert = w_kwert + t_kwert-kwert.
      ENDLOOP.
      CLEAR: w_kwert1.
      IF w_kwert < 0.
        w_kwert1 = w_kwert * ( - 1 ).
      ELSE.
        w_kwert1 = w_kwert.
      ENDIF.
      IF NOT w_kwert1 IS INITIAL.
        CONDENSE w_kwert1 NO-GAPS.
        w_kwertc = w_kwert1.
      ENDIF.
    ENDIF.

*§ BUSCA VALORES RELACIOANDOS AO DESCONTO DO CONVENIO 32/14
    CLEAR: t_kwert, t_kwert[], w_kwert, w_kwert1.
    SELECT kwert kposn kschl FROM konv
      INTO TABLE t_kwert
      WHERE knumv = t_vbrk-knumv
        AND ( kschl = 'YDEC' OR kschl = 'ZITE') .

    IF sy-subrc = 0.
      LOOP AT t_kwert.
        IF t_kwert-kschl = 'ZITE'.
          w_kwertz = w_kwertz + t_kwert-kwert.
        ENDIF.

        IF t_kwert-kschl = 'YDEC'.
          w_kwertd = w_kwertd + t_kwert-kwert.
        ENDIF.

        IF w_kwertz <> 0.
          w_kwert =  w_kwertz.
        ELSE .
          w_kwert =  w_kwertd.
        ENDIF.

      ENDLOOP.
      CLEAR: w_kwert1.
      IF w_kwert < 0.
        w_kwert1 = w_kwert * ( - 1 ).
      ELSE.
        w_kwert1 = w_kwert.
      ENDIF.
      IF NOT w_kwert1 IS INITIAL.
        CONDENSE w_kwert1 NO-GAPS.
        w_kwerte = w_kwert1.
      ENDIF.
    ENDIF.

    IF w_kwertd <> space AND w_kwerte <> '0.00'.
      CONCATENATE: 'Desc.Comercial: R$ ' w_kwerte INTO w_line-tdline SEPARATED BY space.
      w_sepa = ' |'.
    ENDIF.

    IF w_kwertc <> space AND w_kwertc <> '0.00'.
      CONCATENATE: w_line-tdline  w_sepa 'Desc. ICMS Conv.32/14: R$' w_kwertc INTO w_line-tdline SEPARATED BY space.
    ENDIF.

    IF w_line-tdline <> space .
      APPEND w_line TO w_danfe-text1.
    ENDIF.
  ENDIF.
* Inclusão - GRM/PLAUT - 04/09/2008 - Fim

*... fill items ......................................................*

  LOOP AT wk_item.

    READ TABLE wk_item_add WITH KEY docnum = wk_item-docnum
                              itmnum = wk_item-itmnum.

    CLEAR j_1bprnfli.
    MOVE-CORRESPONDING wk_item TO j_1bprnfli.
    MOVE-CORRESPONDING wk_item_add TO j_1bprnfli.

*... fill text reference ..............................................*

    LOOP AT wk_refer_msg WHERE itmnum = wk_item-itmnum.
      REPLACE '  ' WITH wk_refer_msg-seqnum INTO j_1bprnfli-text_ref.
      REPLACE ' '  WITH ','                 INTO j_1bprnfli-text_ref.
    ENDLOOP.
    REPLACE ', ' WITH '  ' INTO j_1bprnfli-text_ref.

    READ TABLE wk_item_tax WITH KEY docnum = wk_item-docnum
                                    itmnum = wk_item-itmnum
                                    taxtyp = 'ICZF'.
    IF sy-subrc = 0.
      CLEAR j_1bprnfli-icmsrate.
    ENDIF.

    APPEND j_1bprnfli TO w_danfe-item.

  ENDLOOP.

  CHECK retcode IS INITIAL.

  MOVE-CORRESPONDING wk_header_add TO w_danfe-nota_fiscal.

  IF NOT lr_badi IS INITIAL.
    CALL METHOD lr_badi->filling_danfe
      CHANGING
        danfe = w_danfe.
  ENDIF.

  IF wk_header-inco1 = 'FOB'.
    w_danfe-others-freight = '1'.
  ELSEIF wk_header-inco1 = 'CIF'.
    w_danfe-others-freight = '0'.
  ENDIF.

  IF wk_header-direct = '2'.
    CASE wk_header-bukrs.
      WHEN '0050'.
        w_danfe-others-brand_vol = 'ACHE'.
      WHEN '0051'.
        w_danfe-others-brand_vol = 'ACHE'.
      WHEN '0080'.
        w_danfe-others-brand_vol = 'BIOSINTETICA'.
    ENDCASE.
  ENDIF.

  READ TABLE wk_item INDEX 1.
  IF sy-subrc = 0.

    SELECT SINGLE vbelv FROM vbfa INTO v_vbeln
     WHERE vbeln = wk_item-refkey(10)
       AND vbtyp_n = 'M'
       AND vbtyp_v = 'J'.

    IF sy-subrc = 0.
      SELECT SINGLE * FROM ynfe_transporte WHERE vbeln = v_vbeln.
      IF sy-subrc = 0.
        w_danfe-nota_fiscal-shpunt = ynfe_transporte-especie.
        w_danfe-nota_fiscal-brgew  = ynfe_transporte-brgew.
        w_danfe-nota_fiscal-ntgew  = ynfe_transporte-ntgew.
      ENDIF.
    ENDIF.

  ENDIF.

  IF NOT v_seqnum IS INITIAL.
    SELECT SINGLE * FROM j_1bnfe_event WHERE docnum = wk_header-docnum AND seqnum = v_seqnum.
    IF sy-subrc = 0.
      w_danfe-nfe-authcod   = j_1bnfe_event-authcod.
      "W_DANFE-NFE-AUTHDATE
      "W_DANFE-NFE-AUTHTIME
      SELECT SINGLE * FROM j_1bnfe_cce WHERE docnum = wk_header-docnum  AND seqnum = v_seqnum.
      IF sy-subrc = 0.
        w_danfe-text_cce = j_1bnfe_cce-text.
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM call_smartform.

ENDFORM.                        "smart_sub_printing

*&---------------------------------------------------------------------
*&      Form  GET_CFOP_LENGTH_SMART
*&---------------------------------------------------------------------
*       text
*----------------------------------------------------------------------
FORM get_cfop_length_smart USING    p_bukrs
                                    p_branch
                                    p_pstdat
                           CHANGING p_version         " note 593218
                                    p_clength
                                    p_elength
                                    p_text
                                    p_region.         " note 593218

  DATA: lv_adress   TYPE addr1_val.

  CALL FUNCTION 'J_1BREAD_BRANCH_DATA'
    EXPORTING
      bukrs             = p_bukrs
      branch            = p_branch
    IMPORTING
      address1          = lv_adress
    EXCEPTIONS
      branch_not_found  = 1
      address_not_found = 2
      company_not_found = 3
      OTHERS            = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  p_region = lv_adress-region.                   " note 593218

  CALL FUNCTION 'J_1B_CFOP_GET_VERSION'
    EXPORTING
      region            = lv_adress-region
      date              = p_pstdat
    IMPORTING
      version           = p_version        " note 593218
      extension         = p_elength
      cfoplength        = p_clength
      txtdef            = p_text
    EXCEPTIONS
      date_missing      = 1
      version_not_found = 2
      OTHERS            = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                             " GET_CFOP_LENGTH_SMART

*&---------------------------------------------------------------------
*&      Form  ENCODING_CFOP_SMART
*&---------------------------------------------------------------------
*       encode the CFOP
*      51234   =>  51234
*      5123A   =>  5123A
*      512345  =>  512345
*      51234A  =>  51234A
*      5123B4  =>  5123B4
*      5123BA  =>  5123BA
*----------------------------------------------------------------------
FORM encoding_cfop_smart  CHANGING p_cfop.

  DATA: len(1) TYPE n,
        helpstring(60) TYPE c,
        d TYPE i.

  helpstring =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ[-<>=!?]'.

  len = STRLEN( p_cfop ).
  IF len = 6.
    CASE p_cfop(1).
      WHEN 1. d = 0.
      WHEN 2. d = 1.
      WHEN 3. d = 2.
      WHEN 5. d = 3.
      WHEN 6. d = 4.
      WHEN 7. d = 5.
    ENDCASE.
    d = d * 10 + p_cfop+1(1).
    SHIFT helpstring BY d PLACES.
    MOVE helpstring(1) TO p_cfop(1).
    p_cfop+1(4) = p_cfop+2(4).
    CLEAR p_cfop+5(1).
  ENDIF.

ENDFORM.                    " ENCODING_CFOP_SMART
*&--------------------------------------------------------------------*
*&      Form  call_smartform
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM call_smartform.

  DATA  lt_otfdata        TYPE ssfcrescl.
  DATA  v_abapon          TYPE c.
  DATA: lv_subject TYPE tdtitle,
        v_net TYPE j_1bprnfhd-nfnet.

  IF w_danfe-nota_fiscal-nfdis < 0.
    w_danfe-nota_fiscal-nfdis = w_danfe-nota_fiscal-nfdis * ( -1 ).
  ENDIF.

  IF v_docnum_pdf IS INITIAL.
    output_options-tdimmed       = nast-dimme.
    output_options-tddest        = nast-ldest.
    control_parameters-no_dialog = 'X'.
    v_abapon = abap_off.
  ELSE.
    output_options-tdnoprev      = abap_on.
    control_parameters-no_dialog = abap_on.
    control_parameters-getotf    = abap_on.
    v_abapon = abap_on.
  ENDIF.

  CALL FUNCTION fm_name
    EXPORTING
      control_parameters = control_parameters
      output_options     = output_options
      user_settings      = ''
      nota_fiscal        = w_danfe
    IMPORTING
      job_output_info    = lt_otfdata
    EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      OTHERS             = 5.

  IF sy-subrc <> 0.

  ELSE.

*-->INI Inclusão emissão DANFE junto com XML por email - 27.08.2015 - #109075
    EXPORT lt_otfdata-otfdata TO MEMORY ID 'TAB_OTF'.

    IF sy-ucomm NE 'PDF'.
      CLEAR v_docnum_pdf.
    ENDIF.
*<--FIM Inclusão emissão DANFE junto com XML por email - 27.08.2015 - #109075

    IF NOT v_docnum_pdf IS INITIAL.

      CALL FUNCTION 'SSFCOMP_PDF_PREVIEW'
        EXPORTING
          i_otf = lt_otfdata-otfdata[].

    ENDIF.
  ENDIF.

ENDFORM.                    "call_smartform

*&---------------------------------------------------------------------*
*&      Form  AJUSTA_VALOR_TOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ajusta_valor_total.

*  CLEAR: gv_fkart,
*         gv_vkorg,
*         gv_knumv.
*
*  SELECT SINGLE fkart vkorg knumv FROM vbrk INTO (gv_fkart, gv_vkorg, gv_knumv)
*    WHERE vbeln EQ key_vbrk-vbeln.
*
*  IF gv_fkart EQ 'YBOR' AND gv_vkorg EQ '0051'.
*    CLEAR gv_kwert.
*
*    SELECT SINGLE kwert FROM konv INTO gv_kwert
*      WHERE knumv EQ gv_knumv
*        AND kschl EQ 'ZICS'.
*
*    IF sy-subrc EQ 0 and gv_kwert > 0.
*      wk_header-nftot = wk_header-nftot + gv_kwert.
*    ENDIF.
*  ENDIF.

ENDFORM.                    " AJUSTA_VALOR_TOTAL