METHOD bin_to_dec .

  DATA:
    lv_declen TYPE i,
    lv_len TYPE i,
    ls_dectobin TYPE mty_dectobin,
    lv_binstring(4) TYPE c,
    lv_index TYPE i.


  CLEAR ev_dec.
  DESCRIBE FIELD ev_dec LENGTH lv_declen IN CHARACTER MODE.
  lv_len = STRLEN( iv_bin ).

* Devide number of binary digits by 4.
  lv_len = lv_len DIV 4.

  IF lv_len > lv_declen.
*   Replace this by MESSAGE ... RAISING ... later:
    RAISE conversion_failed.
  ENDIF.

* Process each 4 bits of iv_bin
  lv_index = STRLEN( iv_bin ).
  DO lv_len TIMES.

    lv_index = lv_index - 4.
    lv_binstring = iv_bin+lv_index(4).

*   Convert each 4 bits of iv_bin to one digit of ev_dec
    READ TABLE mt_dectobin INTO ls_dectobin
      WITH KEY bin_digits = lv_binstring.

    CONCATENATE ls_dectobin-dec_digit ev_dec INTO ev_dec.

  ENDDO.


ENDMETHOD.