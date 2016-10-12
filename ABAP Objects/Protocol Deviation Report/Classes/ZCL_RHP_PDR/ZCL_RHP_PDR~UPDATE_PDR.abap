*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Update PDR                                              *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD update_pdr.
*----------------------------------------------------------------------*
* Structures / Work-Areas
*----------------------------------------------------------------------*
  DATA:
     ls_control     TYPE zzr_hp_pdr_ctrl  ,
     ls_description TYPE zzr_hp_pdr_desc  ,
     ls_impact      TYPE zzr_hp_pdr_imp   ,
     ls_type        TYPE zzr_hp_pdr_type  ,
     ls_history     TYPE zzr_hp_pdr_hist  ,
     ls_created_by  TYPE zzr_hp_created_by,
     ls_changed_by  TYPE zzr_hp_changed_by.

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

  IF ls_control-zzr_hp_actid = me->lc_submit.
    MESSAGE e050(zpdr) INTO lv_message. " Protocol Deviation Report has already been submited
    me->lo_log->add_sys_message( abap_false ).
    RETURN.
  ENDIF.

  ls_created_by-zzr_hpr_pdr_created_by    = ls_control-zzr_hpr_pdr_created_by   .
  ls_created_by-zzr_hpr_pdr_created_pernr = ls_control-zzr_hpr_pdr_created_pernr.
  ls_created_by-zzr_hpr_pdr_created_date  = ls_control-zzr_hpr_pdr_created_date .
  ls_created_by-zzr_hpr_pdr_created_time  = ls_control-zzr_hpr_pdr_created_time .

  ls_changed_by-zzr_hpr_pdr_changed_by    = me->ls_user_authorizations-username.
  ls_changed_by-zzr_hpr_pdr_changed_pernr = me->ls_user_authorizations-pernr   .
  ls_changed_by-zzr_hpr_pdr_changed_date  = sy-datum                           .
  ls_changed_by-zzr_hpr_pdr_changed_time  = sy-uzeit                           .

  IF me->ls_pdr_save-iv_pdr_control_x IS NOT INITIAL.
    MOVE-CORRESPONDING:
     me->ls_control TO ls_control,
     ls_changed_by  TO ls_control,
     ls_created_by  TO ls_control.

    ls_control-zzr_hp_actid = me->lv_action.

    MODIFY zzr_hp_pdr_ctrl FROM ls_control.
  ENDIF.

  IF me->ls_pdr_save-iv_pdr_desc_x IS NOT INITIAL.
    SELECT SINGLE * FROM zzr_hp_pdr_desc
       INTO ls_description
      WHERE zzr_hp_id       = me->ls_key_fields-zzr_hp_id
        AND zzr_hpr_num     = me->ls_key_fields-zzr_hpr_num
        AND zzr_hpr_ver     = me->ls_key_fields-zzr_hpr_ver
        AND zzr_hpr_sub_ver = me->ls_key_fields-zzr_hpr_sub_ver
        AND zzr_hpr_pdr_id  = me->ls_key_fields-zzr_hpr_pdr_id.

    MOVE-CORRESPONDING:
     me->ls_description TO ls_description,
     ls_changed_by      TO ls_description,
     ls_created_by      TO ls_description.

    MODIFY zzr_hp_pdr_desc FROM ls_description.
  ENDIF.

  IF me->ls_pdr_save-iv_pdr_impact_x IS NOT INITIAL.
    SELECT SINGLE * FROM zzr_hp_pdr_imp
       INTO ls_impact
      WHERE zzr_hp_id       = me->ls_key_fields-zzr_hp_id
        AND zzr_hpr_num     = me->ls_key_fields-zzr_hpr_num
        AND zzr_hpr_ver     = me->ls_key_fields-zzr_hpr_ver
        AND zzr_hpr_sub_ver = me->ls_key_fields-zzr_hpr_sub_ver
        AND zzr_hpr_pdr_id  = me->ls_key_fields-zzr_hpr_pdr_id.

    MOVE-CORRESPONDING:
     me->ls_impact TO ls_impact,
     ls_changed_by TO ls_impact,
     ls_created_by TO ls_impact.

    MODIFY zzr_hp_pdr_imp FROM ls_impact.
  ENDIF.

  IF me->ls_pdr_save-iv_pdr_deviation_type_x IS NOT INITIAL.
    SELECT SINGLE * FROM zzr_hp_pdr_type
       INTO ls_type
      WHERE zzr_hp_id       = me->ls_key_fields-zzr_hp_id
        AND zzr_hpr_num     = me->ls_key_fields-zzr_hpr_num
        AND zzr_hpr_ver     = me->ls_key_fields-zzr_hpr_ver
        AND zzr_hpr_sub_ver = me->ls_key_fields-zzr_hpr_sub_ver
        AND zzr_hpr_pdr_id  = me->ls_key_fields-zzr_hpr_pdr_id.

    MOVE-CORRESPONDING:
     me->ls_type   TO ls_type,
     ls_changed_by TO ls_type,
     ls_created_by TO ls_type.

    MODIFY zzr_hp_pdr_type FROM ls_type.
  ENDIF.

  ls_history-zzr_hpr_seq_no = me->create_history_id( ).
  ls_history-zzr_hp_actid   = me->lv_action.

  MOVE-CORRESPONDING:
    me->ls_key_fields TO ls_history,
    ls_changed_by     TO ls_history,
    ls_created_by     TO ls_history.

  IF ls_history IS NOT INITIAL.
    MODIFY zzr_hp_pdr_hist FROM ls_history.
  ENDIF.

  me->read_pdr( IMPORTING ev_pdr_id         = ev_pdr_id
                          es_project_detail = es_project_detail
                          es_control        = es_control
                          es_description    = es_description
                          es_impact         = es_impact
                          es_type           = es_type
                          et_history        = et_history ).

  IF me->lo_log IS BOUND AND me->lo_log->has_error( abap_false ) = abap_false.

    IF ls_control-zzr_hp_actid = me->lc_submit.
      MESSAGE s044(zpdr) INTO lv_message WITH me->lv_hpr_pdr_id. " PDR & successfully created
      me->lo_log->add_sys_message( abap_false ).
    ELSE.
      MESSAGE s033(zpdr) INTO lv_message WITH me->lv_hpr_pdr_id. " PDR & successfully updated
      me->lo_log->add_sys_message( abap_false ).
    ENDIF.

  ENDIF.

ENDMETHOD.
