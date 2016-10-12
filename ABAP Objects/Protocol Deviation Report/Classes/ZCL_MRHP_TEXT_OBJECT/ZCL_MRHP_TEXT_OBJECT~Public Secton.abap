*----------------------------------------------------------------------*
*       CLASS ZCL_MRHP_TEXT_OBJECT DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS zcl_mrhp_text_object DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      tt_tline TYPE STANDARD TABLE OF tline WITH DEFAULT KEY .

    METHODS constructor
      IMPORTING
        !io_app_log TYPE REF TO zcl_app_log .
    METHODS convert_string_to_tline
      IMPORTING
        !iv_message TYPE string
      RETURNING
        value(et_tline) TYPE tt_tline .
    METHODS convert_tline_to_string
      IMPORTING
        !it_tline TYPE tt_tline
      RETURNING
        value(ex_message) TYPE string .
    METHODS read_text_object
      IMPORTING
        !is_header TYPE thead
      RETURNING
        value(ev_message) TYPE string .
    METHODS save_text_object
      IMPORTING
        !iv_message TYPE string
        !is_header TYPE thead .