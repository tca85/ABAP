  METHOD transfer_exc_to_syst.
    DATA: lr_msg TYPE REF TO if_t100_message.

    TRY.
        lr_msg ?= ir_exception.
*     Transfers exception message to SYST structure.
        CALL METHOD cl_message_helper=>set_msg_vars_for_if_t100_msg
          EXPORTING
            text = lr_msg.
      CATCH cx_sy_move_cast_error.
*     Do nothing if exception doesn't have linked message.
        CLEAR lr_msg.
    ENDTRY.

  ENDMETHOD.                    "transfer_exc_to_syst