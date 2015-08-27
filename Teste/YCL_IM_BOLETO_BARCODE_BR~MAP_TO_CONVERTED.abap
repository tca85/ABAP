METHOD map_to_converted .

  DATA:
    lv_len TYPE i,
    lv_binstring(10) TYPE c,
    ls_bintoshorter TYPE mty_bintoshorter.


  lv_binstring = iv_binstring.
  lv_len = STRLEN( iv_binstring ).

  WHILE lv_len < mv_basedigits.

    CONCATENATE '0' lv_binstring INTO lv_binstring.
    lv_len = lv_len + 1.

  ENDWHILE.

  READ TABLE mt_bintoshorter INTO ls_bintoshorter
    WITH KEY bin_digits = lv_binstring.

  IF sy-subrc = 0.
    rv_converted = ls_bintoshorter-con_digit.
  ENDIF.

ENDMETHOD.