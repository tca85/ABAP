  METHOD has_error.
    READ TABLE me->mt_messages
          WITH KEY msgty = gc_msgty_e
  TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      rv_has_error = abap_true.
    ENDIF.


  ENDMETHOD.                    "has_error