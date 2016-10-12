  METHOD add_bapiret1.

    DATA: lv_msgtxt TYPE string.
*          lv_inx TYPE sy-tabix.
    FIELD-SYMBOLS: <fs_message> TYPE bapiret1.

    IF is_message IS SUPPLIED.
*   Single message provided.
      ASSIGN is_message TO <fs_message>.

      CALL METHOD me->system_to_text_msg
        EXPORTING
          iv_internal  = iv_internal
          is_message   = <fs_message>
        RECEIVING
          rv_has_error = rv_has_error.
*      Multiple Messages Provided
    ELSEIF it_messages IS SUPPLIED.
      LOOP AT it_messages ASSIGNING <fs_message>.
        CALL METHOD me->system_to_text_msg
          EXPORTING
            iv_internal  = iv_internal
            is_message   = <fs_message>
          RECEIVING
            rv_has_error = rv_has_error.
      ENDLOOP.
      UNASSIGN <fs_message>.
    ENDIF.

  ENDMETHOD.                    "add_bapiret1