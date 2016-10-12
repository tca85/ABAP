PRIVATE SECTION.

  TYPES:
    BEGIN OF ty_key_fields,
      zzr_hp_id       TYPE zzrhpid,
      zzr_hpr_num     TYPE zzrhprnum,
      zzr_hpr_ver     TYPE zzrhprver,
      zzr_hpr_sub_ver TYPE zzrhprsubver,
      zzr_hpr_pdr_id  TYPE zzrhprpdrid,
    END OF ty_key_fields .
  TYPES:
    BEGIN OF ty_snro,
      id TYPE n LENGTH 8,
    END OF ty_snro .
  TYPES:
    BEGIN OF t_ris_roles,
     ris_role TYPE hr_mcshort,
     object_type TYPE otype,
     object_id TYPE hrobjid,
   END OF t_ris_roles .
  TYPES:
    tt_pdr_role TYPE STANDARD TABLE OF zzr_hp_pdr_role WITH DEFAULT KEY .
  TYPES:
    tt_pdr_users TYPE STANDARD TABLE OF zzr_hp_pdr_usert WITH DEFAULT KEY .
  TYPES:
    tt_pdr_auth TYPE STANDARD TABLE OF zzr_hp_pdr_auth WITH DEFAULT KEY .
  TYPES:
    tt_tline TYPE STANDARD TABLE OF tline WITH DEFAULT KEY .

  CONSTANTS lc_slg1_object TYPE balobj_d VALUE 'ZMRHP'.     "#EC NOTEXT
  CONSTANTS lc_slg1_subobject TYPE balsubobj VALUE 'ZMRHP_SUB'. "#EC NOTEXT
  CONSTANTS lc_snro_hist_id TYPE inri-object VALUE 'ZPDRHISTID'. "#EC NOTEXT
  CONSTANTS lc_snro_pdr_id TYPE inri-object VALUE 'ZPDRID'. "#EC NOTEXT
  DATA lo_log TYPE REF TO zcl_app_log .
  DATA lo_pdr_validation TYPE REF TO zcl_rhp_pdr_validation .
  DATA lo_pdr_authentication TYPE REF TO zcl_rhp_pdr_authorization .
  DATA lo_text_object TYPE REF TO zcl_mrhp_text_object .
  DATA ls_control TYPE zzr_hp_pdr_ctrl_in_s .
  DATA ls_description TYPE zzr_hp_pdr_desc_in_s .
  DATA ls_impact TYPE zzr_hp_pdr_imp_in_s .
  DATA ls_key_fields TYPE ty_key_fields .
  DATA ls_pdr_save TYPE zrhp_s_hpr_pdr_save_struct .
  DATA ls_project_details TYPE zrhp_s_protocol .
  DATA ls_type TYPE zzr_hp_pdr_type_in_s .
  CLASS zcl_rhp_pdr_authorization DEFINITION LOAD .
  DATA ls_user_authorizations TYPE zcl_rhp_pdr_authorization=>t_usr_authorization .
  DATA lv_action TYPE zzrhpactid .
  DATA lv_hpr_id TYPE zzrhpid .
  DATA lv_hpr_num TYPE zzrhprnum .
  DATA lv_hpr_pdr_id TYPE zzrhprpdrid .
  DATA lv_hpr_sub_ver TYPE zzrhprsubver .
  DATA lv_hpr_ver TYPE zzrhprver .
  DATA lv_sap_username TYPE sy-uname .

  METHODS check_mandatory_fields .
  METHODS complete_number_zeros_left
    IMPORTING
      !iv_number TYPE clike
    EXPORTING
      value(ev_converted) TYPE clike .
  METHODS create_history_id
    RETURNING
      value(ro_snro) TYPE ty_snro-id .
  METHODS create_number_range_object
    IMPORTING
      !iv_snro_object TYPE inri-object
    RETURNING
      value(ro_snro) TYPE ty_snro-id .
  METHODS create_pdr
    EXPORTING
      !ev_pdr_id TYPE zzrhprpdrid
      !es_project_detail TYPE zzr_hp_pdr_prj_details_s
      !es_control TYPE zzr_hp_pdr_ctrl
      !es_description TYPE zzr_hp_pdr_desc_s
      !es_impact TYPE zzr_hp_pdr_imp_s
      !es_type TYPE zzr_hp_pdr_type_s
      !et_history TYPE zzr_hp_pdr_hist_t .
  METHODS create_pdr_id
    RETURNING
      value(ro_snro) TYPE ty_snro-id .
  METHODS delete_pdr .
  METHODS fill_key_fields .
  METHODS get_control_table
    RETURNING
      value(es_control) TYPE zzr_hp_pdr_ctrl .
  METHODS get_description_table
    RETURNING
      value(es_description) TYPE zzr_hp_pdr_desc_s .
  METHODS get_deviation_type_table
    RETURNING
      value(es_type) TYPE zzr_hp_pdr_type_s .
  METHODS get_domain_value_text
    IMPORTING
      !iv_domname TYPE dd01l-domname
      !iv_domvalue TYPE any
    RETURNING
      value(ev_value) TYPE dd07t-ddtext .
  METHODS get_history_table
    RETURNING
      value(et_history) TYPE zzr_hp_pdr_hist_t .
  METHODS get_human_protocol_details
    RETURNING
      value(es_protocol) TYPE zrhp_s_protocol .
  METHODS get_impact_table
    RETURNING
      value(es_impact) TYPE zzr_hp_pdr_imp_s .
  METHODS get_project_details
    RETURNING
      value(es_project_detail) TYPE zzr_hp_pdr_prj_details_s .
  METHODS get_user_authorization
    IMPORTING
      !iv_sap_username TYPE sy-uname
    RETURNING
      value(es_user_auth) LIKE ls_user_authorizations .
  METHODS read_message_text
    IMPORTING
      !iv_app_object TYPE tdobject
    RETURNING
      value(ev_message) TYPE string .
  METHODS read_pdr
    EXPORTING
      !ev_pdr_id TYPE zzrhprpdrid
      !es_project_detail TYPE zzr_hp_pdr_prj_details_s
      !es_control TYPE zzr_hp_pdr_ctrl
      !es_description TYPE zzr_hp_pdr_desc_s
      !es_impact TYPE zzr_hp_pdr_imp_s
      !es_type TYPE zzr_hp_pdr_type_s
      !et_history TYPE zzr_hp_pdr_hist_t .
  METHODS save_message_text
    IMPORTING
      !iv_message TYPE string
      !iv_app_object TYPE tdobject .
  METHODS start_application_log .
  METHODS submit_pdr
    EXPORTING
      !ev_pdr_id TYPE zzrhprpdrid
      !es_project_detail TYPE zzr_hp_pdr_prj_details_s
      !es_control TYPE zzr_hp_pdr_ctrl
      !es_description TYPE zzr_hp_pdr_desc_s
      !es_impact TYPE zzr_hp_pdr_imp_s
      !es_type TYPE zzr_hp_pdr_type_s
      !et_history TYPE zzr_hp_pdr_hist_t .
  METHODS update_pdr
    EXPORTING
      !ev_pdr_id TYPE zzrhprpdrid
      !es_project_detail TYPE zzr_hp_pdr_prj_details_s
      !es_control TYPE zzr_hp_pdr_ctrl
      !es_description TYPE zzr_hp_pdr_desc_s
      !es_impact TYPE zzr_hp_pdr_imp_s
      !es_type TYPE zzr_hp_pdr_type_s
      !et_history TYPE zzr_hp_pdr_hist_t .
  METHODS update_pdr_viewed_action
    EXPORTING
      !ev_pdr_id TYPE zzrhprpdrid
      !es_project_detail TYPE zzr_hp_pdr_prj_details_s
      !es_control TYPE zzr_hp_pdr_ctrl
      !es_description TYPE zzr_hp_pdr_desc_s
      !es_impact TYPE zzr_hp_pdr_imp_s
      !es_type TYPE zzr_hp_pdr_type_s
      !et_history TYPE zzr_hp_pdr_hist_t .