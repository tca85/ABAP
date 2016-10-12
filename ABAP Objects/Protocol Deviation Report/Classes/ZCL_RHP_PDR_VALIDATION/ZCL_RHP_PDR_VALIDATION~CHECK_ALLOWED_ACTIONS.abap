*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Check allowed actions                                   *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   12.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD check_allowed_actions.

  DATA:
    lv_count   TYPE sy-tabix,
    lv_message TYPE string  .                               "#EC NEEDED

  IF me->lv_action IS NOT INITIAL.
    SELECT COUNT( DISTINCT zzr_hp_actid )
      FROM zzr_hp_pdr_act
      INTO lv_count
      WHERE zzr_hp_actid = me->lv_action.

    IF lv_count IS INITIAL.
      MESSAGE e040(zpdr) INTO lv_message. " You filled an invalid action
      me->lo_log->add_sys_message( abap_false ).
    ENDIF.

  ELSE.
    MESSAGE e001(zpdr) INTO lv_message. " You must choose the action
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

ENDMETHOD.
