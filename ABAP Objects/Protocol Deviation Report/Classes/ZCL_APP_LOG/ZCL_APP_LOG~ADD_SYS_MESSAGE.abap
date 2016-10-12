  METHOD add_sys_message.

    DATA: lv_msgtxt TYPE string.

    CHECK sy-msgty IS NOT INITIAL. " Make sure this is a valid system

* For internal messages, transform and add text message.
    IF iv_internal = abap_true.
*   Transform system message into text message.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_msgtxt.
*   Add message to log.
      me->add_text( EXPORTING iv_text     = lv_msgtxt
                          iv_msg_type = sy-msgty
                          iv_internal = iv_internal ).
    ELSE.
*   Add original message to log.
      me->add_message( EXPORTING iv_msg_type = sy-msgty
                                 iv_msg_id   = sy-msgid
                                 iv_msg_no   = sy-msgno
                                 iv_msg_v1   = sy-msgv1
                                 iv_msg_v2   = sy-msgv2
                                 iv_msg_v3   = sy-msgv3
                                 iv_msg_v4   = sy-msgv4 ).
    ENDIF. " iv_internal.

  ENDMETHOD.                    "add_sys_message