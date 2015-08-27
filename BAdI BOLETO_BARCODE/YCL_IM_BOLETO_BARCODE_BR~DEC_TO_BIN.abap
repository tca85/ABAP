METHOD dec_to_bin .

* tsjafdçlkfdsçlkfdsçlkfdsa

* Convert each decimal digit of iv_dec to binary representation
* and create a binary string

  DATA:
    lv_binlen TYPE i,
    lv_len TYPE i,
    lv_index TYPE i,
    lv_char(1) TYPE c,
    ls_dectobin TYPE mty_dectobin.



  CLEAR ev_bin.
  DESCRIBE FIELD ev_bin LENGTH lv_binlen IN CHARACTER MODE.
  lv_len = STRLEN( iv_dec ).

  lv_binlen = lv_binlen DIV 4.
  IF lv_binlen < lv_len.
*   Replace this by MESSAGE ... RAISING ... later:
    RAISE conversion_failed.
  ENDIF.

  DO lv_len TIMES.

    lv_char = iv_dec+lv_index(1).

    READ TABLE mt_dectobin INTO ls_dectobin
      WITH KEY dec_digit = lv_char.

    CONCATENATE ev_bin ls_dectobin-bin_digits INTO ev_bin.

    ADD 1 TO lv_index.

  ENDDO.

ENDMETHOD.