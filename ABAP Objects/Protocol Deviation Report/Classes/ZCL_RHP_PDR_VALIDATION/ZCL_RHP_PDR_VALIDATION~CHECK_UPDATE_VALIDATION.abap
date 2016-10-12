*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Check update validations                                *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   12.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD check_update_validation.
  DATA:
     lv_message TYPE string.                                "#EC NEEDED

  IF me->lv_hpr_pdr_id IS INITIAL.
    MESSAGE e043(zpdr) INTO lv_message. " You must fill the Protocol Deviation Report Id
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

  me->check_key_validation( ).
  me->check_control_validation( ).
  me->check_type_validation( ).
  me->check_impact_validation( ).
  me->check_description_validation( ).

ENDMETHOD.
