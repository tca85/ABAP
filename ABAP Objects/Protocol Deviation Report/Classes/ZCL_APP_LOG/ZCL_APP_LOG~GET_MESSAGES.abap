  METHOD get_messages.

    et_messages[] = me->mt_messages[].
    IF iv_excl_internal = abap_true.
*   Remove all internal messages.
      DELETE et_messages WHERE msgno >= gc_symsgno_900.
    ENDIF. " iv_excl_internal

  ENDMETHOD.                                "get_messages