*----------------------------------------------------------------------*
*       CLASS ZCL_RHP_PDR DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS zcl_rhp_pdr DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS lc_access_under_supervisor TYPE zzrhpactid VALUE 'AS'. "#EC NOTEXT
    CONSTANTS lc_create TYPE zzrhpactid VALUE 'CR'.         "#EC NOTEXT
    CONSTANTS lc_delete TYPE zzrhpactid VALUE 'DE'.         "#EC NOTEXT
    CONSTANTS lc_full_access TYPE zzrhpactid VALUE 'FA'.    "#EC NOTEXT
    CONSTANTS lc_read TYPE zzrhpactid VALUE 'RE'.           "#EC NOTEXT
    CONSTANTS lc_submit TYPE zzrhpactid VALUE 'SB'.         "#EC NOTEXT
    CONSTANTS lc_update TYPE zzrhpactid VALUE 'UP'.         "#EC NOTEXT
    CONSTANTS lc_user_applicant TYPE zzrhpuserid VALUE '1'. "#EC NOTEXT
    CONSTANTS lc_user_ore_director TYPE zzrhpuserid VALUE '4'. "#EC NOTEXT
    CONSTANTS lc_user_ore_manager TYPE zzrhpuserid VALUE '3'. "#EC NOTEXT
    CONSTANTS lc_user_reb_member TYPE zzrhpuserid VALUE '5'. "#EC NOTEXT
    CONSTANTS lc_user_supervisor TYPE zzrhpuserid VALUE '2'. "#EC NOTEXT
    CONSTANTS lc_viewed_by_ore TYPE zzrhpactid VALUE 'VO'.  "#EC NOTEXT
    CONSTANTS lc_viewed_by_supervisor TYPE zzrhpactid VALUE 'VS'. "#EC NOTEXT

    METHODS call_action
      EXPORTING
        !ev_pdr_id TYPE zzrhpid
        !es_project_detail TYPE zzr_hp_pdr_prj_details_s
        !es_control TYPE zzr_hp_pdr_ctrl
        !es_description TYPE zzr_hp_pdr_desc_s
        !es_impact TYPE zzr_hp_pdr_imp_s
        !es_type TYPE zzr_hp_pdr_type_s
        !et_history TYPE zzr_hp_pdr_hist_t
        !et_return_messages TYPE bapiret2_t
      RAISING
        zcx_rhp_pdr .
    METHODS constructor
      IMPORTING
        !iv_hpr_id TYPE zzrhpid OPTIONAL
        !iv_hpr_num TYPE zzrhprnum
        !iv_hpr_ver TYPE zzrhprver
        !iv_hpr_sub_ver TYPE zzrhprsubver
        !iv_hpr_pdr_id TYPE zzrhprpdrid
        !iv_action TYPE zzrhpactid
        !is_pdr_save TYPE zrhp_s_hpr_pdr_save_struct
        !is_control TYPE zzr_hp_pdr_ctrl_in_s
        !is_description TYPE zzr_hp_pdr_desc_in_s
        !is_impact TYPE zzr_hp_pdr_imp_in_s
        !is_type TYPE zzr_hp_pdr_type_in_s
      RAISING
        zcx_rhp_pdr .