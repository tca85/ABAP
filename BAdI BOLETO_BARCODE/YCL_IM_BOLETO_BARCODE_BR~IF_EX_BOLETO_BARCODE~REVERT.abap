METHOD if_ex_boleto_barcode~revert .
*
**  break mdachristian.

  DATA:
    lv_converted_barcode(38) TYPE c,
    lv_bin_barcode(200) TYPE c,
    lv_barcode_length TYPE i,
    lv_stored_length TYPE i,
    lv_difference TYPE i,
    lv_barcode_char(48) TYPE c.

* Check if barcode in ESR fields was stored in converted form
  IF iv_esrpz IS INITIAL.

*   Barcode was stored unconverted.
*   Old functionality (standard before Note 784748)
    CALL FUNCTION 'CONVERT_TO_BARCODE'
      EXPORTING
        esrre   = iv_esrre
        esrnr   = iv_esrnr
        dmbtr   = iv_dmbtr
      IMPORTING
        barcode = ev_reverted_barcode.

    EXIT.

  ENDIF.

* Concatenate two ESR number fields to converted barcode
  CONCATENATE iv_esrnr iv_esrre INTO lv_converted_barcode.

* Convert from number with base mc_base to binary number
  CALL METHOD shorter_to_bin
    EXPORTING
      iv_converted      = lv_converted_barcode
    IMPORTING
      ev_bin            = lv_bin_barcode
    EXCEPTIONS
      conversion_failed = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Revert binary representation of each decimal digit to barcode
  CALL METHOD bin_to_dec
    EXPORTING
      iv_bin            = lv_bin_barcode
    IMPORTING
      ev_dec            = lv_barcode_char
    EXCEPTIONS
      conversion_failed = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Check for and delete leading zeros
  lv_stored_length = iv_esrpz.
  SHIFT lv_barcode_char LEFT DELETING LEADING space.
  lv_barcode_length = STRLEN( lv_barcode_char ).

  lv_difference = lv_barcode_length - lv_stored_length.

  IF lv_difference > 0.
    SHIFT lv_barcode_char BY lv_difference PLACES.
  ENDIF.

  ev_reverted_barcode = lv_barcode_char.

ENDMETHOD.