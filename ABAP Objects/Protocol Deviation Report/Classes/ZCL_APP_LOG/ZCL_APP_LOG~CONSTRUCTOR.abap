  METHOD constructor.
*

* Method-Local Data Declarations:
    DATA: ls_log_header TYPE bal_s_log.

* If it doesn't exist in the table, we need to create it;
* First, fill in the log header details:
    ls_log_header-object     = iv_object.
    ls_log_header-subobject  = iv_subobject.
    ls_log_header-extnumber  = iv_extnumber.
    ls_log_header-aldate     = sy-datum.
    ls_log_header-altime     = sy-uzeit.
    ls_log_header-aluser     = sy-uname.
    ls_log_header-altcode    = sy-tcode.
    ls_log_header-alprog     = sy-repid.
    ls_log_header-aldate_del = sy-datum + gc_aldate_del_30. " Expires

* Try to create the log instance:
    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log      = ls_log_header
      IMPORTING
        e_log_handle = me->mv_log_handle
      EXCEPTIONS
        OTHERS       = 0.
  ENDMETHOD.                    "constructor