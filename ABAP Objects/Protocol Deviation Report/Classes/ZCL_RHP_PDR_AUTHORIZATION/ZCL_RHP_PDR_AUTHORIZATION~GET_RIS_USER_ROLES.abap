*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Get RIS user roles                                      *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   11.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD get_ris_user_roles.
*----------------------------------------------------------------------*
* Types
*----------------------------------------------------------------------*
  TYPES:
    BEGIN OF t_roles             ,
      ris_role    TYPE hr_mcshort,
      object_type TYPE otype     ,
      object_id   TYPE hrobjid   ,
    END OF t_roles               ,

    BEGIN OF t_unit_list         ,
      obj_id TYPE hrobjid        ,
      stext TYPE stext           ,
    END OF t_unit_list           .

*----------------------------------------------------------------------*
* Internal Tables
*----------------------------------------------------------------------*
  DATA:
     lt_unit_list TYPE STANDARD TABLE OF t_unit_list,
     lt_ris_roles TYPE STANDARD TABLE OF t_ris_roles.

*----------------------------------------------------------------------*
* Structures / Work-Areas
*----------------------------------------------------------------------*
  DATA:
     s_ris_roles  TYPE t_ris_roles,
     s_roles_unit TYPE t_ris_roles,
     s_unit_list  TYPE t_unit_list.

*----------------------------------------------------------------------*
* Variables
*----------------------------------------------------------------------*
  DATA:
     lv_rfc_name        TYPE rs38l-name,
     lv_rfc_destination TYPE bdbapidst ,
     lv_msg_error       TYPE string    ,
     lv_exception_name  TYPE string    ,
     lv_rfc_exists      TYPE boolean   .

*----------------------------------------------------------------------*
* Begin
*----------------------------------------------------------------------*

  lv_rfc_destination = zcl_rap_constants=>rfc_destination.
  lv_rfc_name        = me->lc_rfc_user_roles             . " Z_RAA_READ_SEC_DETAILS

  lv_rfc_exists = me->lo_pdr_validation->check_rfc( iv_destination = lv_rfc_destination
                                                    iv_rfc_name    = lv_rfc_name ).

  IF lv_rfc_exists = abap_false.
    RETURN.
  ENDIF.

* Remote Function Call to SAP ECC (FIS) - Z_RAA_READ_SEC_DETAILS
  CALL FUNCTION lv_rfc_name
    DESTINATION lv_rfc_destination
    EXPORTING
      userid                = iv_sap_username
    IMPORTING
      personnelnumber       = ev_pernr
      ris_roles             = et_ris_roles
    EXCEPTIONS
      no_personnel_found    = 1
      system_failure        = 2
      communication_failure = 3
      resource_failure      = 4
      OTHERS                = 5.

  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        lv_exception_name = 'no_personnel_number'.          "#EC NOTEXT
      WHEN 2.
        lv_exception_name = 'system_failure'.               "#EC NOTEXT
      WHEN 3.
        lv_exception_name = 'communication_failure'.        "#EC NOTEXT
      WHEN 4.
        lv_exception_name = 'resource_failure'.             "#EC NOTEXT
      WHEN OTHERS.
        lv_exception_name = 'unhlandled exception'.         "#EC NOTEXT
    ENDCASE.

    MESSAGE e045(zpdr) INTO lv_msg_error WITH lv_exception_name. " Error getting user roles: &
    me->lo_log->add_sys_message( abap_false ).
    RETURN.
  ENDIF.

  IF et_ris_roles IS INITIAL.
    MESSAGE e046(zpdr) INTO lv_msg_error WITH lv_exception_name. " User doesn't have RIS roles
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

ENDMETHOD.
