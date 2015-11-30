*----------------------------------------------------------------------*
***INCLUDE LYNQMO01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_2001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_2001 OUTPUT.
  SET PF-STATUS 'P_SELECT'.
  SET TITLEBAR 'T0120'.
ENDMODULE.                             " STATUS_2001  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_2001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_2001 OUTPUT.

  LOOP AT g_partner_tab WHERE NOT parvw IS INITIAL.

    CALL FUNCTION 'PM_PARTNER_ROLL_TEXT'
      EXPORTING
        parvw    = g_partner_tab-parvw
        language = sy-langu
      IMPORTING
        vtext    = g_partner_tab-vtext.


    CALL FUNCTION 'PM_PARTNER_READ'
      EXPORTING
        parvw                  = g_partner_tab-parvw
        parnr                  = g_partner_tab-parnr
      IMPORTING
        diadr_wa               = diadr
      EXCEPTIONS
        no_valid_parnr         = 1
        no_valid_parnr_today   = 2
        no_authority           = 3
        parvw_and_nrart_inital = 4
        OTHERS                 = 5.
    IF sy-subrc <> 0.
      CLEAR diadr.
    ELSE.
      MOVE diadr-name_list TO g_partner_tab-name_list.
    ENDIF.

    MODIFY g_partner_tab.

  ENDLOOP.

ENDMODULE.                             " INIT_2001  OUTPUT
