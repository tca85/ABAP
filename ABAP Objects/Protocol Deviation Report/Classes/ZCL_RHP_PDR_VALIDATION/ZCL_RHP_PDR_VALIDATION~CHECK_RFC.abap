*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Check RFC destination & if function exists              *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   12.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD check_rfc.
*----------------------------------------------------------------------*
* Variables
*----------------------------------------------------------------------*
  DATA:
    lv_msg_error      TYPE string         ,                 "#EC NEEDED
    lv_exception_name TYPE string         ,
    lv_group          TYPE rs38l-area     ,                 "#EC NEEDED
    lv_include        TYPE rs38l-include  ,                 "#EC NEEDED
    lv_namespace      TYPE rs38l-namespace,                 "#EC NEEDED
    lv_str_area       TYPE rs38l-str_area .                 "#EC NEEDED

*----------------------------------------------------------------------*
* Begin
*----------------------------------------------------------------------*

  CALL FUNCTION 'RFC_PING'
    DESTINATION iv_destination
    EXCEPTIONS
      system_failure        = 1
      communication_failure = 2
      resource_failure      = 3
      OTHERS                = 4.

  IF sy-subrc <> 0.
    MESSAGE e036(zpdr) INTO lv_msg_error WITH iv_destination. " RFC ping error with destination &
    me->lo_log->add_sys_message( abap_false ).
    RETURN.
  ENDIF.

  CALL FUNCTION 'FUNCTION_EXISTS'
    DESTINATION iv_destination
    EXPORTING
      funcname              = iv_rfc_name
    IMPORTING
      group                 = lv_group
      include               = lv_include
      namespace             = lv_namespace
      str_area              = lv_str_area
    EXCEPTIONS
      function_not_exist    = 1
      system_failure        = 2
      communication_failure = 3
      resource_failure      = 4
      OTHERS                = 5.

  IF sy-subrc <> 0.
    MESSAGE e037(zpdr) INTO lv_msg_error WITH iv_rfc_name iv_destination. " Function & does not exist in destination &
    me->lo_log->add_sys_message( abap_false ).
    RETURN.
  ENDIF.

  ev_exist = abap_true.

ENDMETHOD.
