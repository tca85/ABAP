PRIVATE SECTION.

*"* private components of class ZCL_APP_LOG
*"* do not include other source files here!!!
  DATA mv_log_handle TYPE balloghndl .
  CLASS-DATA st_logs TYPE ztt_app_log .
  DATA mt_messages TYPE ztt_bal_msg .

  METHODS constructor
    IMPORTING
      !iv_object TYPE balobj_d
      !iv_subobject TYPE balsubobj OPTIONAL
      !iv_extnumber TYPE balnrext OPTIONAL .
  METHODS system_to_text_msg
    IMPORTING
      !iv_internal TYPE abap_bool DEFAULT 'X'
      !is_message TYPE bapiret1
    RETURNING
      value(rv_has_error) TYPE abap_bool .