  METHOD system_to_text_msg.
    DATA : lv_msgtxt TYPE string.

    FIELD-SYMBOLS <fs_message> TYPE bapiret1.

    ASSIGN is_message TO <fs_message>.

*   For internal messages, transform and add text message.
    IF iv_internal = abap_true.
*     Transform system message into text message.
      MESSAGE ID <fs_message>-id TYPE <fs_message>-type NUMBER
  <fs_message>-number
            WITH <fs_message>-message_v1 <fs_message>-message_v2
  <fs_message>-message_v3 <fs_message>-message_v4
            INTO lv_msgtxt.
*     Add message to log.
      me->add_text( EXPORTING iv_text = lv_msgtxt
                          iv_msg_type = <fs_message>-type
                          iv_internal = iv_internal ).
    ELSE.
*      Add original message to log.
      me->add_message( EXPORTING iv_msg_type = <fs_message>-type
                                 iv_msg_id   = <fs_message>-id
                                 iv_msg_no   = <fs_message>-number
                                 iv_msg_v1   = <fs_message>-message_v1
                                 iv_msg_v2   = <fs_message>-message_v2
                                 iv_msg_v3   = <fs_message>-message_v3
                                iv_msg_v4   = <fs_message>-message_v4 ).
    ENDIF. " iv_internal.
*   Check if any error occured.
    IF <fs_message>-type = gc_msgty_e
    OR <fs_message>-type = gc_msgty_a
    OR <fs_message>-type = gc_msgty_x.
      rv_has_error = abap_true.
    ENDIF.

  ENDMETHOD.                    "SYSTEM_TO_TEXT_MSG