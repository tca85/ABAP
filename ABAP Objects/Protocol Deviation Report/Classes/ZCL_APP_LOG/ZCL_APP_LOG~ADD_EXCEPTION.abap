  METHOD add_exception.

* Method-Local Data Declarations:
    DATA: ls_exception TYPE bal_s_exc,
          lr_msg TYPE REF TO if_t100_message,
          ls_msg_handle TYPE  balmsghndl,
          ls_message LIKE LINE OF me->mt_messages.

* Fill in the exception details:
    ls_exception-msgty     = gc_msgty_e.
    ls_exception-exception = ir_exception.
    ls_exception-detlevel  = gc_ballevel_4.   "Medium Detail Level
    ls_exception-probclass = gc_balprobcl_3.   " Important

* Add the exception to the log:
    CALL FUNCTION 'BAL_LOG_EXCEPTION_ADD'
      EXPORTING
        i_log_handle   = me->mv_log_handle
        i_s_exc        = ls_exception
      IMPORTING
        e_s_msg_handle = ls_msg_handle
      EXCEPTIONS
        OTHERS         = 0.
* Retrieve exception message from log.
    CALL FUNCTION 'BAL_LOG_MSG_READ'
      EXPORTING
        i_s_msg_handle = ls_msg_handle
      IMPORTING
        e_s_msg        = ls_message
      EXCEPTIONS
        OTHERS         = 0.

* Retrieve message linked to exception.
    TRY.
        lr_msg ?= ir_exception.
*     Transfers exception message to SYST structure.
        CALL METHOD cl_message_helper=>set_msg_vars_for_if_t100_msg
          EXPORTING
            text = lr_msg.
        MOVE-CORRESPONDING sy TO ls_message.
        IF ls_message-msgty IS INITIAL.
          ls_message-msgty = gc_msgty_e.
        ENDIF.
        "Add message to message list.
        APPEND ls_message TO me->mt_messages.
      CATCH cx_sy_move_cast_error.
*     Do nothing if exception doesn't have linked message.
        "Add message to message list.
        APPEND ls_message TO me->mt_messages.
    ENDTRY.

  ENDMETHOD.                    "add_exception