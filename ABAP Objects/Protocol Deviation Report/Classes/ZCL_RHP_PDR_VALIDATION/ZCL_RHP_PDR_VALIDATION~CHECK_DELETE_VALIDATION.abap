*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Check delete validations                                *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   12.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD check_delete_validation.

  DATA:
     lv_message TYPE string.                                "#EC NEEDED

  IF me->lv_hpr_id IS INITIAL.
    MESSAGE e007(zpdr) INTO lv_message. " You must fill the Human Protocol ID
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

  IF me->lv_hpr_num IS INITIAL.
    MESSAGE e010(zpdr) INTO lv_message. " You must fill the Human Protocol Number
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

  IF me->lv_hpr_pdr_id IS INITIAL.
    MESSAGE e043(zpdr) INTO lv_message. " You must fill the Protocol Deviation Report Id
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

ENDMETHOD.
