*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Check control validation                                *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   12.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD check_control_validation.
  DATA:
    lv_message TYPE string.                                 "#EC NEEDED

  IF me->ls_pdr_save-iv_pdr_control_x IS INITIAL.
    RETURN.
  ENDIF.

  IF me->ls_control-zzr_hpr_pdr_date IS INITIAL.
    MESSAGE e025(zpdr) INTO lv_message. " You must fill the Protocol Deviation Date
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

  IF me->ls_control-zzr_hpr_pdr_date_disc IS INITIAL.
    MESSAGE e026(zpdr) INTO lv_message. " You must fill the date that the deviation was discovered
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

ENDMETHOD.
