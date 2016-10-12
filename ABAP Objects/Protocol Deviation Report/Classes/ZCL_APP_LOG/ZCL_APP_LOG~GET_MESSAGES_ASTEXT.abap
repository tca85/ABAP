  METHOD get_messages_astext.

    DATA: ls_message LIKE LINE OF me->mt_messages,
          lv_msgtxt TYPE string.

    LOOP AT me->mt_messages INTO ls_message.
      IF iv_excl_internal = abap_true.
*     Filter out internal messages.
        CHECK ls_message-msgno < gc_symsgno_900.
      ENDIF. " iv_excl_internal.
*   Get message text.
      MESSAGE ID ls_message-msgid TYPE ls_message-msgty NUMBER
ls_message-msgno
            WITH ls_message-msgv1 ls_message-msgv2 ls_message-msgv3
ls_message-msgv4
            INTO lv_msgtxt.
      IF rv_msgtxt IS INITIAL.
        rv_msgtxt = lv_msgtxt.
      ELSE.
        CONCATENATE rv_msgtxt lv_msgtxt INTO rv_msgtxt SEPARATED BY
gc_char02_separator.
      ENDIF.
    ENDLOOP. " it_messages.

  ENDMETHOD.                    "get_messages_astext