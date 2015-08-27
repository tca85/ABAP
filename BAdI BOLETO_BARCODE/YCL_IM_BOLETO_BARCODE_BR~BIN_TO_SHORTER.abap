METHOD bin_to_shorter .

  DATA:
    lv_conlen TYPE i,
    lv_len TYPE i,
    lv_rest TYPE i,
    lv_con_digit(1) TYPE c,
    lv_binstring(10) TYPE c,
    lv_index TYPE i.


  CLEAR ev_converted.
  DESCRIBE FIELD ev_converted LENGTH lv_conlen IN CHARACTER MODE.
  lv_len = STRLEN( iv_bin ).
  lv_rest = lv_len MOD mv_basedigits.

* Devide number of binary digits by number of bits of conversion base.
* For example, if conversion base is 32 (2**5), devide by 5.
  lv_len = lv_len DIV mv_basedigits.

  IF lv_len > lv_conlen.
*   Replace this by MESSAGE ... RAISING ... later:
    RAISE conversion_failed.
  ENDIF.

* Process each 5 bits of iv_bin
  lv_index =  STRLEN( iv_bin ).
  DO lv_len TIMES.

    lv_index = lv_index - mv_basedigits.
    lv_binstring = iv_bin+lv_index(mv_basedigits).

*   Convert each 5 bits of iv_bin to one digit of ev_converted
    lv_con_digit = map_to_converted( lv_binstring ).

    CONCATENATE lv_con_digit ev_converted INTO ev_converted.

  ENDDO.

  IF lv_index > 0.
    lv_binstring = iv_bin(lv_index).

*   Convert each 5 bits of iv_bin to one digit of ev_converted
    lv_con_digit = map_to_converted( lv_binstring ).
    CONCATENATE lv_con_digit ev_converted INTO ev_converted.

  ENDIF.

ENDMETHOD.