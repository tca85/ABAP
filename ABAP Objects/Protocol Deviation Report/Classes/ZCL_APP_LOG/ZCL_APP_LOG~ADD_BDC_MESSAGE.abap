  METHOD add_bdc_message.

    DATA: lv_msgtxt TYPE string,
          lv_msg_no TYPE symsgno,
          lv_inx TYPE sy-tabix.
    FIELD-SYMBOLS: <fs_message> TYPE bdcmsgcoll.

    IF is_message IS SUPPLIED.
*   Single message provided.
      ASSIGN is_message TO <fs_message>.
    ELSEIF it_messages IS SUPPLIED.
      lv_inx = 1.
    ENDIF.

    DO. " loop required in case of multiple messages.

      IF lv_inx > 0.
        READ TABLE it_messages INDEX lv_inx ASSIGNING <fs_message>.
        IF sy-subrc = 0.
          lv_inx = lv_inx + 1.
        ENDIF.
      ENDIF.
      IF <fs_message> IS NOT ASSIGNED.
*     No more message, exit loop.
        EXIT.
      ENDIF.

*   For internal messages, transform and add text message.
      IF iv_internal = abap_true.
*     Transform system message into text message.
        MESSAGE ID <fs_message>-msgid TYPE <fs_message>-msgtyp NUMBER
<fs_message>-msgnr
              WITH <fs_message>-msgv1 <fs_message>-msgv2
<fs_message>-msgv3 <fs_message>-msgv4
              INTO lv_msgtxt.
*     Add message to log.
        me->add_text( EXPORTING iv_text = lv_msgtxt
                                iv_msg_type = <fs_message>-msgtyp
                                iv_internal = iv_internal ).
      ELSE.
*     Add original message to log.
        lv_msg_no = <fs_message>-msgnr.
        me->add_message( EXPORTING iv_msg_type = <fs_message>-msgtyp
                                   iv_msg_id   = <fs_message>-msgid
                                   iv_msg_no   = lv_msg_no
                                   iv_msg_v1   = <fs_message>-msgv1
                                   iv_msg_v2   = <fs_message>-msgv2
                                   iv_msg_v3   = <fs_message>-msgv3
                                   iv_msg_v4   = <fs_message>-msgv4 ).
      ENDIF. " iv_internal.

      UNASSIGN <fs_message>.

    ENDDO.

  ENDMETHOD.                    "add_bdc_message