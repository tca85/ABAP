METHOD shorter_to_bin .

* Convert each digit of iv_converted to binary representation
* and create a binary string

  DATA:
    lv_binlen TYPE i,
    lv_len TYPE i,
    lv_index TYPE i,
    lv_char(1) TYPE c,
    ls_bintoshorter TYPE mty_bintoshorter.


  CLEAR ev_bin.
  DESCRIBE FIELD ev_bin LENGTH lv_binlen IN CHARACTER MODE.
  lv_len = STRLEN( iv_converted ).

  lv_binlen = lv_binlen DIV mv_basedigits.
  IF lv_binlen < lv_len.
*   Replace this by MESSAGE ... RAISING ... later:
    RAISE conversion_failed.
  ENDIF.

  DO lv_len TIMES.

    lv_char = iv_converted+lv_index(1).

    READ TABLE mt_bintoshorter INTO ls_bintoshorter
      WITH KEY con_digit = lv_char.

    CONCATENATE ev_bin ls_bintoshorter-bin_digits INTO ev_bin.

    ADD 1 TO lv_index.

  ENDDO.

ENDMETHOD.