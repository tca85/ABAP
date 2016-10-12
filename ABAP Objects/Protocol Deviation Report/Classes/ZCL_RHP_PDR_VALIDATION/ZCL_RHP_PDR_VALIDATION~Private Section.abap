PRIVATE SECTION.

  TYPES:
    BEGIN OF t_human_protocol                            ,
      zzr_hp_id       TYPE zzr_hp_hpr_head-zzr_hp_id      ,
      zzr_hpr_num     TYPE zzr_hp_hpr_head-zzr_hpr_num    ,
      zzr_hpr_ver     TYPE zzr_hp_hpr_head-zzr_hpr_ver    ,
      zzr_hpr_sub_ver TYPE zzr_hp_hpr_head-zzr_hpr_sub_ver,
    END OF t_human_protocol .

  DATA lo_log TYPE REF TO zcl_app_log .
  DATA ls_control TYPE zzr_hp_pdr_ctrl_in_s .
  DATA ls_description TYPE zzr_hp_pdr_desc_in_s .
  DATA ls_pdr_save TYPE zrhp_s_hpr_pdr_save_struct .
  DATA ls_type TYPE zzr_hp_pdr_type_in_s .
  DATA lv_action TYPE zzrhpactid .
  DATA lv_hpr_id TYPE zzrhpid .
  DATA lv_hpr_num TYPE zzrhprnum .
  DATA lv_hpr_pdr_id TYPE zzrhprpdrid .
  DATA lv_hpr_sub_ver TYPE zzrhprsubver .
  DATA lv_hpr_ver TYPE zzrhprver .

  METHODS check_allowed_actions .
  METHODS check_control_validation .
  METHODS check_create_validation .
  METHODS check_delete_validation .
  METHODS check_description_validation .
  METHODS check_human_protocol
    RETURNING
      value(is_human_protocol) TYPE t_human_protocol .
  METHODS check_impact_validation .
  METHODS check_key_validation .
  CLASS zcl_rhp_pdr_authorization DEFINITION LOAD .
  METHODS check_pdr_ownership
    IMPORTING
      !iv_hpr_id TYPE zzrhpid
      !iv_hpr_num TYPE zzrhprnum
      !iv_hpr_version TYPE zzrhprver
      !iv_hpr_sub_ver TYPE zzrhprsubver
      !iv_hpr_pdr_id TYPE zzrhprpdrid
      !es_user_details TYPE zcl_rhp_pdr_authorization=>t_usr_authorization .
  METHODS check_read_validation .
  METHODS check_type_validation .
  METHODS check_update_validation .