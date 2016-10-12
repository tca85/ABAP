*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Convert string message to TLINE table                   *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD convert_string_to_tline.

  DATA:
      ls_tline         TYPE tline,
      lv_number_copied TYPE i    ,
      lv_n2copy        TYPE i    ,
      lv_string_length TYPE i    .

  CONSTANTS:
      lc_fixlen   TYPE tdline   VALUE '132',
      lc_tdformat	TYPE tdformat VALUE '*'  .

  IF iv_message IS INITIAL.
    RETURN.
  ENDIF.

  lv_string_length = strlen( iv_message ).

  WHILE lv_number_copied < lv_string_length.

    IF lv_number_copied + lc_fixlen < lv_string_length.
      lv_n2copy = lc_fixlen.
    ELSE.
      lv_n2copy = lv_string_length - lv_number_copied.
    ENDIF.

    ls_tline-tdformat = lc_tdformat.
    ls_tline-tdline   = iv_message+lv_number_copied(lv_n2copy).

    APPEND ls_tline TO et_tline.

    lv_number_copied = lv_number_copied + lv_n2copy.
  ENDWHILE.

ENDMETHOD.
