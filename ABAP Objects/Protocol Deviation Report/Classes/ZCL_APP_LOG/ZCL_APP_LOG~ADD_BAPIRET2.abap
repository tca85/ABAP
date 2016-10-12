  METHOD add_bapiret2.

    DATA: ls_message TYPE bapiret1,
          lv_inx TYPE sy-tabix.
    FIELD-SYMBOLS: <fs_message2> TYPE bapiret2.

    IF is_message IS SUPPLIED.
*   Single message provided.
      ASSIGN is_message TO <fs_message2>.
    ELSEIF it_messages IS SUPPLIED.
*   Multiple messages provided.
      lv_inx = 1.
    ENDIF.

    DO.
      IF lv_inx > 0.
        READ TABLE it_messages INDEX lv_inx ASSIGNING <fs_message2>.
        IF sy-subrc = 0.
          lv_inx = lv_inx + 1.
        ENDIF.
      ENDIF.
      IF <fs_message2> IS NOT ASSIGNED.
*     No more message, exit loop.
        EXIT.
      ENDIF.
*   Move message fields to target structure.
      MOVE-CORRESPONDING <fs_message2> TO ls_message.
      UNASSIGN <fs_message2>.
*   Add message of type BAPIRET1.
      IF me->add_bapiret1( is_message = ls_message iv_internal =
iv_internal ) = abap_true.
        rv_has_error = abap_true.
      ENDIF.
    ENDDO.

  ENDMETHOD.                    "add_bapiret2