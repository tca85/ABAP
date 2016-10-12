  METHOD save.

* Method-Local Data Declarations:
    DATA: lt_log_handles TYPE bal_t_logh.

* Save the application log:
    APPEND me->mv_log_handle TO lt_log_handles.

    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_in_update_task = abap_false
        i_t_log_handle   = lt_log_handles
      EXCEPTIONS
        OTHERS           = 0.

    CHECK iv_refresh = abap_true.
    CALL FUNCTION 'BAL_LOG_REFRESH'
      EXPORTING
        i_log_handle = me->mv_log_handle
      EXCEPTIONS
        OTHERS       = 0.

  ENDMETHOD.                    "save