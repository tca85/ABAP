*----------------------------------------------------------------------*
*       CLASS ZCL_RHP_PDR_VALIDATION DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS zcl_rhp_pdr_validation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS zcl_rhp_pdr_authorization DEFINITION LOAD .
    METHODS check_hp_authorization
      IMPORTING
        !iv_hpr_id TYPE zzrhpid
        !iv_hpr_num TYPE zzrhprnum
        !iv_hpr_version TYPE zzrhprver
        !iv_hpr_sub_ver TYPE zzrhprsubver
        !iv_hpr_pdr_id TYPE zzrhprpdrid
        !es_user_details TYPE zcl_rhp_pdr_authorization=>t_usr_authorization .
    METHODS check_mandatory_fields .
    METHODS check_rfc
      IMPORTING
        !iv_destination TYPE bdbapidst
        !iv_rfc_name TYPE rs38l-name
      RETURNING
        value(ev_exist) TYPE boolean .
    METHODS constructor
      IMPORTING
        !io_log TYPE REF TO zcl_app_log
        !is_control TYPE zzr_hp_pdr_ctrl_in_s
        !is_description TYPE zzr_hp_pdr_desc_in_s
        !is_pdr_save TYPE zrhp_s_hpr_pdr_save_struct
        !is_type TYPE zzr_hp_pdr_type_in_s
        !iv_action TYPE zzrhpactid
        !iv_hpr_id TYPE zzrhpid
        !iv_hpr_num TYPE zzrhprnum
        !iv_hpr_pdr_id TYPE zzrhprpdrid
        !iv_hpr_sub_ver TYPE zzrhprsubver
        !iv_hpr_ver TYPE zzrhprver .