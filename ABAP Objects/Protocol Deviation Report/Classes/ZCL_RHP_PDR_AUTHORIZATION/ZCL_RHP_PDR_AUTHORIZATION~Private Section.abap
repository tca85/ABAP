PRIVATE SECTION.

  TYPES:
    BEGIN OF t_ris_roles,
      ris_role TYPE hr_mcshort,
      object_type TYPE otype,
      object_id TYPE hrobjid,
    END OF t_ris_roles .
  TYPES:
    tt_ris_roles TYPE TABLE OF t_ris_roles WITH DEFAULT KEY .
  TYPES:
    tt_pdr_users TYPE STANDARD TABLE OF zzr_hp_pdr_usert WITH DEFAULT KEY .
  TYPES:
    tt_pdr_role TYPE STANDARD TABLE OF zzr_hp_pdr_role WITH DEFAULT KEY .

  CONSTANTS lc_rfc_project_details TYPE rs38l-name VALUE 'Z_RHP_READ_HR_APPT_INFO'. "#EC NOTEXT
  DATA lc_rfc_user_roles TYPE rs38l-name VALUE 'Z_RAA_READ_SEC_DETAILS'. "#EC NOTEXT
  DATA lo_log TYPE REF TO zcl_app_log .
  DATA lo_pdr_validation TYPE REF TO zcl_rhp_pdr_validation .

  METHODS get_action_description
    IMPORTING
      !iv_action TYPE zzrhpactid
    RETURNING
      value(ev_action_dsc) TYPE zzrhpactdsc .
  METHODS get_logged_user
    IMPORTING
      !iv_sap_username TYPE sy-uname
    RETURNING
      value(es_user_details) TYPE t_usr_authorization .
  METHODS get_pdr_allowed_users
    RETURNING
      value(et_pdr_users) TYPE tt_pdr_users .
  METHODS get_pdr_user_roles
    RETURNING
      value(et_pdr_role) TYPE tt_pdr_role .
  METHODS get_ris_user_roles
    IMPORTING
      !iv_sap_username TYPE sy-uname
    EXPORTING
      !et_ris_roles TYPE tt_ris_roles
      !ev_pernr TYPE ess_emp-employeenumber .
  METHODS get_supervisor_details
    IMPORTING
      !iv_sap_username TYPE sy-uname .