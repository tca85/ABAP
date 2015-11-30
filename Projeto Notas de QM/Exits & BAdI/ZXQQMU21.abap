*&---------------------------------------------------------------------*
*&  Include           ZXQQMU21
*&---------------------------------------------------------------------*
FIELD-SYMBOLS : <l_ebene> TYPE ANY.

IF i_viqmel-rbnr = 'ZQM01'.
  ASSIGN ('(SAPMIWO0)VIQMFE-OTGRP') TO <l_ebene>.
  IF sy-subrc EQ 0.
    IF i_ebene = 'OT'.
      MOVE i_codegruppe TO e_codegruppe.
    ELSE.
      MOVE <l_ebene> TO e_codegruppe.
    ENDIF.
  ENDIF.
ENDIF.
