*----------------------------------------------------------------------*
*       CLASS ZCL_RHP_PDR_AUTHORIZATION DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS zcl_rhp_pdr_authorization DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF t_usr_authorization ,
          username  TYPE sy-uname    ,
          pernr     TYPE pernr_d       ,
          userid    TYPE zzrhpuserid ,
          userdsc   TYPE zzrhpuserdsc,
          actionid  TYPE zzrhpactid  ,
          actiondsc TYPE zzrhpactdsc ,
        END OF t_usr_authorization .

    METHODS constructor
      IMPORTING
        !io_log TYPE REF TO zcl_app_log
        !io_pdr_validation TYPE REF TO zcl_rhp_pdr_validation .
    METHODS get_user_authorization
      IMPORTING
        !iv_sap_username TYPE sy-uname
        !iv_action_id TYPE zzrhpactid
      RETURNING
        value(es_user_details) TYPE t_usr_authorization .