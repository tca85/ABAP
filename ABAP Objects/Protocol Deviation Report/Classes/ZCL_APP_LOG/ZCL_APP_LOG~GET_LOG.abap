  METHOD get_log.

* Method-Local Data Declarations:
    FIELD-SYMBOLS: <fs_log> LIKE LINE OF zcl_app_log=>st_logs.

* This class acts as a singleton; Thus, first check to see if
* a logger instance exists for the object/subobject:
    READ TABLE zcl_app_log=>st_logs ASSIGNING <fs_log>
      WITH KEY object = iv_object
               subobject = iv_subobject
               extnumber = iv_extnumber.
    IF sy-subrc = 0.
      rr_log = <fs_log>-log.
      RETURN.
    ENDIF.

* If we don't have an instance in context, create one:
    CREATE OBJECT rr_log
      EXPORTING
        iv_object    = iv_object
        iv_subobject = iv_subobject
        iv_extnumber = iv_extnumber.

* Store the logger instance in context:
    APPEND INITIAL LINE TO zcl_app_log=>st_logs ASSIGNING <fs_log>.
    <fs_log>-object = iv_object.
    <fs_log>-subobject = iv_subobject.
    <fs_log>-extnumber = iv_extnumber.
    <fs_log>-log = rr_log.

  ENDMETHOD.                    "get_log