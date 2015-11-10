*----------------------------------------------------------------------*
***INCLUDE LYNQMI01 .
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   INCLUDE LQM06I20                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  EXIT_2001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_2001 INPUT.

  save_ok_code = ok_code.
  CLEAR ok_code.

  CASE save_ok_code.

    WHEN 'ABBR'.

      LOOP AT g_reply_type WHERE manum = wqmsm-manum
                              OR manum = g_bescheid_manum.
        g_reply_type-g_langtext = ' '.
        CLEAR g_reply_type.
        DELETE g_reply_type.

      ENDLOOP.

      MESSAGE s170(qm).
      RAISE action_stopped.
  ENDCASE.

ENDMODULE.                             " EXIT_2001  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2001 INPUT.

  save_ok_code = ok_code.
  CLEAR ok_code.

  CASE save_ok_code.

    WHEN 'ENT1'.
      CLEAR ok_code.

      LOOP AT g_partner_tab WHERE mark = 'X'.
        MOVE-CORRESPONDING g_partner_tab TO act_partner.
        SET SCREEN 0.
        LEAVE SCREEN.
      ENDLOOP.

    WHEN 'ABBR'.

      CLEAR ok_code.

      MESSAGE s170(qm).
      RAISE action_stopped.

  ENDCASE.

ENDMODULE.                             " USER_COMMAND_2001  INPUT

*&---------------------------------------------------------------------*
*&      Module  MODIFY_TAB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_tab INPUT.
  MODIFY g_partner_tab INDEX partner-current_line.
ENDMODULE.                             " MODIFY_TAB  INPUT
