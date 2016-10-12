  METHOD add_message.

* Method-Local Data Declarations:
    DATA: ls_message LIKE LINE OF me->mt_messages.

* Define the log message metadata:
    ls_message-msgty = iv_msg_type.
    ls_message-msgid = iv_msg_id.
    ls_message-msgno = iv_msg_no.
    ls_message-msgv1 = iv_msg_v1.
    ls_message-msgv2 = iv_msg_v2.
    ls_message-msgv3 = iv_msg_v3.
    ls_message-msgv4 = iv_msg_v4.

* Add message into message table.
    APPEND ls_message TO me->mt_messages.

* Create the log message:
    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle = me->mv_log_handle
        i_s_msg      = ls_message
      EXCEPTIONS
        OTHERS       = 0.

  ENDMETHOD.                    "add_message