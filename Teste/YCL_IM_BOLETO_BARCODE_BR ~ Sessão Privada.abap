*"* private components of class CL_IM_BOLETO_BARCODE_BR
*"* do not include other source files here!!!
PRIVATE SECTION.

  TYPES:
    BEGIN OF mty_dectobin,
    dec_digit(1) TYPE c,
    bin_digits(4) TYPE c,
    END OF mty_dectobin .
  TYPES:
    BEGIN OF mty_bintoshorter,
      bin_digits(10) TYPE c,
      con_digit(1) TYPE c,
    END OF mty_bintoshorter .

  CONSTANTS mc_base TYPE i VALUE 32.                        "#EC NOTEXT
  DATA mv_basedigits TYPE i .
  DATA:
    mt_dectobin TYPE SORTED TABLE OF mty_dectobin
    WITH UNIQUE KEY dec_digit .
  DATA:
    mt_bintoshorter TYPE SORTED TABLE OF mty_bintoshorter
    WITH UNIQUE KEY bin_digits .

  METHODS map_to_converted
    IMPORTING
      !iv_binstring TYPE c
    RETURNING
      value(rv_converted) TYPE char1 .
  METHODS bin_to_shorter
    IMPORTING
      !iv_bin TYPE c
    EXPORTING
      !ev_converted TYPE c
    EXCEPTIONS
      conversion_failed .
  METHODS dec_to_bin
    IMPORTING
      !iv_dec TYPE c
    EXPORTING
      !ev_bin TYPE c
    EXCEPTIONS
      conversion_failed .
  METHODS split
    IMPORTING
      !iv_code TYPE c
    EXPORTING
      !ev_esrre TYPE esrre
      !ev_esrnr TYPE esrnr .
  METHODS shorter_to_bin
    IMPORTING
      !iv_converted TYPE c
    EXPORTING
      !ev_bin TYPE c
    EXCEPTIONS
      conversion_failed .
  METHODS bin_to_dec
    IMPORTING
      !iv_bin TYPE c
    EXPORTING
      !ev_dec TYPE c
    EXCEPTIONS
      conversion_failed .