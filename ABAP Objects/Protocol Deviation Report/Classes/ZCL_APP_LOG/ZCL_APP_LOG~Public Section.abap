*----------------------------------------------------------------------*
*       CLASS ZCL_APP_LOG DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS zcl_app_log DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
*"* public components of class ZCL_APP_LOG
*"* do not include other source files here!!!
    TYPE-POOLS abap .

    TYPES:
      tt_bdcmsgcoll TYPE STANDARD TABLE OF bdcmsgcoll .
    TYPES:
      tt_bapiret1 TYPE STANDARD TABLE OF bapiret1 .

    CONSTANTS gc_msgty_a TYPE msgty VALUE 'A'.              "#EC NOTEXT
    CONSTANTS gc_msgty_e TYPE msgty VALUE 'E'.              "#EC NOTEXT
    CONSTANTS gc_msgty_i TYPE msgty VALUE 'I'.              "#EC NOTEXT
    CONSTANTS gc_msgty_s TYPE msgty VALUE 'S'.              "#EC NOTEXT
    CONSTANTS gc_msgty_w TYPE msgty VALUE 'W'.              "#EC NOTEXT
    CONSTANTS gc_msgty_x TYPE msgty VALUE 'X'.              "#EC NOTEXT
    CONSTANTS gc_ballevel_4 TYPE ballevel VALUE 4.          "#EC NOTEXT
    CONSTANTS gc_balprobcl_3 TYPE balprobcl VALUE 3.        "#EC NOTEXT
    CONSTANTS gc_balprobcl_4 TYPE balprobcl VALUE '4'.      "#EC NOTEXT
    CONSTANTS gc_symsgno_000 TYPE symsgno VALUE '000'.      "#EC NOTEXT
    CONSTANTS gc_symsgno_900 TYPE symsgno VALUE '900'.      "#EC NOTEXT
    CONSTANTS gc_symsgno_002 TYPE symsgno VALUE '002'.      "#EC NOTEXT
    CONSTANTS gc_char01_placeholder TYPE char01 VALUE '&'.  "#EC NOTEXT
    CONSTANTS gc_symsgid_app_log TYPE symsgid VALUE 'ZFI_APP_LOG'. "#EC NOTEXT  "#EC
    CONSTANTS:
      gc_char02_separator TYPE c LENGTH 2 VALUE '; '.       "#EC NOTEXT
    CONSTANTS gc_aldate_del_30 TYPE i VALUE 30.             "#EC NOTEXT

    METHODS add_bapiret1
      IMPORTING
        !is_message TYPE bapiret1 OPTIONAL
        !it_messages TYPE tt_bapiret1 OPTIONAL
        value(iv_internal) TYPE abap_bool DEFAULT 'X'
      RETURNING
        value(rv_has_error) TYPE abap_bool .
    METHODS add_bapiret2
      IMPORTING
        !is_message TYPE bapiret2 OPTIONAL
        !it_messages TYPE bapiret2_tab OPTIONAL
        !iv_internal TYPE abap_bool DEFAULT 'X'
      RETURNING
        value(rv_has_error) TYPE abap_bool .
    METHODS add_exception
      IMPORTING
        !ir_exception TYPE REF TO cx_root .
    METHODS add_message
      IMPORTING
        !iv_msg_type TYPE symsgty
        !iv_msg_id TYPE symsgid
        !iv_msg_no TYPE symsgno
        !iv_msg_v1 TYPE any OPTIONAL
        !iv_msg_v2 TYPE any OPTIONAL
        !iv_msg_v3 TYPE any OPTIONAL
        !iv_msg_v4 TYPE any OPTIONAL .
    METHODS add_sys_message
      IMPORTING
        value(iv_internal) TYPE abap_bool DEFAULT 'X' .
    METHODS add_text
      IMPORTING
        !iv_text TYPE clike
        value(iv_msg_type) TYPE symsgty
        value(iv_internal) TYPE abap_bool DEFAULT 'X'
        !iv_msgv1 TYPE string OPTIONAL
        !iv_msgv2 TYPE string OPTIONAL
        !iv_msgv3 TYPE string OPTIONAL
        !iv_msgv4 TYPE string OPTIONAL .
    METHODS clear_messages .
    CLASS-METHODS get_log
      IMPORTING
        value(iv_object) TYPE balobj_d
        value(iv_subobject) TYPE balsubobj OPTIONAL
        value(iv_extnumber) TYPE balnrext OPTIONAL
      RETURNING
        value(rr_log) TYPE REF TO zcl_app_log .
    METHODS get_messages
      IMPORTING
        value(iv_excl_internal) TYPE abap_bool DEFAULT 'X'
      EXPORTING
        !et_messages TYPE ztt_bal_msg .
    METHODS get_messages_astext
      IMPORTING
        value(iv_excl_internal) TYPE abap_bool DEFAULT 'X'
      RETURNING
        value(rv_msgtxt) TYPE string .
    METHODS save
      IMPORTING
        !iv_refresh TYPE abap_bool DEFAULT 'X' .
    METHODS add_bdc_message
      IMPORTING
        !is_message TYPE bdcmsgcoll OPTIONAL
        !it_messages TYPE tt_bdcmsgcoll OPTIONAL
        value(iv_internal) TYPE abap_bool DEFAULT 'X' .
    METHODS has_error
      IMPORTING
        value(iv_excl_internal) TYPE abap_bool DEFAULT 'X'
      RETURNING
        value(rv_has_error) TYPE abap_bool .
    METHODS transfer_exc_to_syst
      IMPORTING
        !ir_exception TYPE REF TO cx_root .
    METHODS get_log_handle
      RETURNING
        value(rv_log_handle) TYPE balloghndl .
    METHODS display_log .