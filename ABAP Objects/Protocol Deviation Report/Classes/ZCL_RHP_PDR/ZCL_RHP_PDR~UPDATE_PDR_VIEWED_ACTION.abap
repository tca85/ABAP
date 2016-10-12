*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Update PDR viewed action                                *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD update_pdr_viewed_action.
*----------------------------------------------------------------------*
* Structures / Work-Areas
*----------------------------------------------------------------------*
  DATA:
     ls_control TYPE zzr_hp_pdr_ctrl.

*----------------------------------------------------------------------*
* Variables
*----------------------------------------------------------------------*
  DATA:
     lv_message TYPE string.                                "#EC NEEDED

*----------------------------------------------------------------------*
* Begin
*----------------------------------------------------------------------*

  SELECT SINGLE * FROM zzr_hp_pdr_ctrl
    INTO ls_control
    WHERE zzr_hp_id       = me->ls_key_fields-zzr_hp_id
      AND zzr_hpr_num     = me->ls_key_fields-zzr_hpr_num
      AND zzr_hpr_ver     = me->ls_key_fields-zzr_hpr_ver
      AND zzr_hpr_sub_ver = me->ls_key_fields-zzr_hpr_sub_ver
      AND zzr_hpr_pdr_id  = me->ls_key_fields-zzr_hpr_pdr_id.

  IF ls_control IS INITIAL.
    MESSAGE e027(zpdr) INTO lv_message. " Protocol Deviation Report not found
    me->lo_log->add_sys_message( abap_false ).
    RETURN.
  ENDIF.

  ls_control-zzr_hp_actid             = me->lv_action      .
  ls_control-zzr_hpr_pdr_changed_by   = me->lv_sap_username.
  ls_control-zzr_hpr_pdr_changed_date = sy-datum           .
  ls_control-zzr_hpr_pdr_changed_time = sy-uzeit           .
  MODIFY zzr_hp_pdr_ctrl FROM ls_control                   .

  me->read_pdr( IMPORTING ev_pdr_id         = ev_pdr_id
                          es_project_detail = es_project_detail
                          es_control        = es_control
                          es_description    = es_description
                          es_impact         = es_impact
                          es_type           = es_type
                          et_history        = et_history ).

  IF me->lo_log IS BOUND AND me->lo_log->has_error( abap_false ) = abap_false.
    MESSAGE s033(zpdr) INTO lv_message WITH me->lv_hpr_pdr_id. " PDR & successfully updated
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

ENDMETHOD.
