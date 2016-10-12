*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Delete the PDR                                          *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD delete_pdr.
  DATA:
     lv_count   TYPE sy-tabix,
     lv_message TYPE string  .                              "#EC NEEDED

  SELECT COUNT( DISTINCT zzr_hpr_pdr_id )
    FROM zzr_hp_pdr_ctrl
    INTO lv_count
    WHERE zzr_hp_id       = me->ls_key_fields-zzr_hp_id
      AND zzr_hpr_num     = me->ls_key_fields-zzr_hpr_num
      AND zzr_hpr_ver     = me->ls_key_fields-zzr_hpr_ver
      AND zzr_hpr_sub_ver = me->ls_key_fields-zzr_hpr_sub_ver
      AND zzr_hpr_pdr_id  = me->ls_key_fields-zzr_hpr_pdr_id.

  IF lv_count IS INITIAL.
    MESSAGE e027(zpdr) INTO lv_message. " Protocol Deviation Report not found
    me->lo_log->add_sys_message( abap_false ).
    RETURN.
  ENDIF.

  DELETE FROM zzr_hp_pdr_ctrl
    WHERE zzr_hp_id       = me->ls_key_fields-zzr_hp_id
      AND zzr_hpr_num     = me->ls_key_fields-zzr_hpr_num
      AND zzr_hpr_ver     = me->ls_key_fields-zzr_hpr_ver
      AND zzr_hpr_sub_ver = me->ls_key_fields-zzr_hpr_sub_ver
      AND zzr_hpr_pdr_id  = me->ls_key_fields-zzr_hpr_pdr_id.

  DELETE FROM zzr_hp_pdr_desc
    WHERE zzr_hp_id       = me->ls_key_fields-zzr_hp_id
      AND zzr_hpr_num     = me->ls_key_fields-zzr_hpr_num
      AND zzr_hpr_ver     = me->ls_key_fields-zzr_hpr_ver
      AND zzr_hpr_sub_ver = me->ls_key_fields-zzr_hpr_sub_ver
      AND zzr_hpr_pdr_id  = me->ls_key_fields-zzr_hpr_pdr_id.

  DELETE FROM zzr_hp_pdr_imp
    WHERE zzr_hp_id       = me->ls_key_fields-zzr_hp_id
      AND zzr_hpr_num     = me->ls_key_fields-zzr_hpr_num
      AND zzr_hpr_ver     = me->ls_key_fields-zzr_hpr_ver
      AND zzr_hpr_sub_ver = me->ls_key_fields-zzr_hpr_sub_ver
      AND zzr_hpr_pdr_id  = me->ls_key_fields-zzr_hpr_pdr_id.

  DELETE FROM zzr_hp_pdr_type
    WHERE zzr_hp_id       = me->ls_key_fields-zzr_hp_id
      AND zzr_hpr_num     = me->ls_key_fields-zzr_hpr_num
      AND zzr_hpr_ver     = me->ls_key_fields-zzr_hpr_ver
      AND zzr_hpr_sub_ver = me->ls_key_fields-zzr_hpr_sub_ver
      AND zzr_hpr_pdr_id  = me->ls_key_fields-zzr_hpr_pdr_id.

  DELETE FROM zzr_hp_pdr_hist
    WHERE zzr_hp_id       = me->ls_key_fields-zzr_hp_id
      AND zzr_hpr_num     = me->ls_key_fields-zzr_hpr_num
      AND zzr_hpr_ver     = me->ls_key_fields-zzr_hpr_ver
      AND zzr_hpr_sub_ver = me->ls_key_fields-zzr_hpr_sub_ver
      AND zzr_hpr_pdr_id  = me->ls_key_fields-zzr_hpr_pdr_id.

  IF me->lo_log IS BOUND AND me->lo_log->has_error( abap_false ) = abap_false.
    MESSAGE s032(zpdr) INTO lv_message WITH me->lv_hpr_pdr_id. " PDR & successfully deleted
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

ENDMETHOD.
