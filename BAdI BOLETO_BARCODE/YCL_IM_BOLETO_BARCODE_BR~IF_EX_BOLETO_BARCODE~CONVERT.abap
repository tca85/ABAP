METHOD if_ex_boleto_barcode~convert.
  DATA:
    lv_bin_barcode(200) TYPE c,
    lv_converted_barcode(38) TYPE c,
    lv_barcode_char(47) TYPE c,
    lv_barcode_length TYPE i.

* Validate barcode screen field
  CALL METHOD if_ex_boleto_barcode~validate
    EXPORTING
      iv_barcode       = iv_barcode
      is_bseg          = is_bseg
    EXCEPTIONS
      validation_error = 1.

  IF sy-subrc <> 0.
*   Validation error. Message to be issued in validate method.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  lv_barcode_char = iv_barcode.
  SHIFT lv_barcode_char LEFT DELETING LEADING space.
  lv_barcode_length = STRLEN( lv_barcode_char ).

* Convert barcode to binary representation of each decimal digit
  CALL METHOD dec_to_bin
    EXPORTING
      iv_dec            = iv_barcode
    IMPORTING
      ev_bin            = lv_bin_barcode
    EXCEPTIONS
      conversion_failed = 1.

  IF sy-subrc <> 0.
*   Conversion error. Message issued in method.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Convert binary barcode to 32'-system representation
  CALL METHOD bin_to_shorter
    EXPORTING
      iv_bin            = lv_bin_barcode
    IMPORTING
      ev_converted      = lv_converted_barcode
    EXCEPTIONS
      conversion_failed = 1.
  IF sy-subrc <> 0.
*   Conversion error. Message issued in method.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Split into two ESR fields
  CALL METHOD split
    EXPORTING
      iv_code  = lv_converted_barcode
    IMPORTING
      ev_esrre = ev_esrre
      ev_esrnr = ev_esrnr.

* Set ESR check digit to the length of the initial barcode entered in
* the AP invoice screen to indicate that barcode is converted and
* to keep the initial length to prevent unnecessar leading zeros being
* added
  ev_esrpz = lv_barcode_length.

ENDMETHOD.