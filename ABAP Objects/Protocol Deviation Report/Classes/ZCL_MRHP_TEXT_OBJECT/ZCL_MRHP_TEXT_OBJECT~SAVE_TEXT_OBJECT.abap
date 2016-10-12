*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Save text object                                        *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD save_text_object.
  DATA:
     lt_lines TYPE STANDARD TABLE OF tline.

  DATA:
     lv_error_message TYPE string.                          "#EC NEEDED

  lt_lines = me->convert_string_to_tline( iv_message ).

  IF lt_lines IS INITIAL.
    RETURN.
  ENDIF.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      client   = sy-mandt
      header   = is_header
    TABLES
      lines    = lt_lines
    EXCEPTIONS
      id       = 1
      language = 2
      name     = 3
      object   = 4
      OTHERS   = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
       INTO lv_error_message.

    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

ENDMETHOD.
