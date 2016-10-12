*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Convert TLINE table to string message                   *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD convert_tline_to_string.
  DATA:
     lt_tdline TYPE STANDARD TABLE OF tdline.

  DATA:
     ls_textline LIKE LINE OF it_tline ,
     ls_tdline   LIKE LINE OF lt_tdline.

  LOOP AT it_tline INTO ls_textline.
    ls_tdline = ls_textline-tdline.
    APPEND ls_tdline TO lt_tdline.
  ENDLOOP.

  CALL FUNCTION 'SWA_STRING_FROM_TABLE'
    EXPORTING
      character_table            = lt_tdline
    IMPORTING
      character_string           = ex_message
    EXCEPTIONS
      no_flat_charlike_structure = 1
      OTHERS                     = 2.

ENDMETHOD.
