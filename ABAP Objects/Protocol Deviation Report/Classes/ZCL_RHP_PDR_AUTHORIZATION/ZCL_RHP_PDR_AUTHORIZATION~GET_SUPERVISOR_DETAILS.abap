*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Get Supervisor/Process Investigator details             *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   11.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD get_supervisor_details.

*----------------------------------------------------------------------*
* Structures
*----------------------------------------------------------------------*
  TYPES:
    BEGIN OF t_adm_unit,
      orgeh         TYPE orgeh  ,
      orgeh_text    TYPE char255,
      campus        TYPE char3  ,
      fac_division  TYPE hrobjid,
      fac_div_text  TYPE char255,
    END OF t_adm_unit           .

  TYPES:
    BEGIN OF t_oth_apt      ,
      other_appts TYPE sbttx,
    END OF t_oth_apt        .

*----------------------------------------------------------------------*
* Variables
*----------------------------------------------------------------------*
  DATA:
     lv_personnel_number  TYPE pernr_d   ,                  "#EC NEEDED
     lv_app_type          TYPE char1     ,                  "#EC NEEDED
     lv_utorid            TYPE zzrutorid ,                  "#EC NEEDED
     lv_name              TYPE pad_cname ,                  "#EC NEEDED
     lv_telephone         TYPE ad_tlnmbr1,                  "#EC NEEDED
     lv_email             TYPE ad_smtpadr,                  "#EC NEEDED
     lv_apt_status        TYPE text30    ,                  "#EC NEEDED
     lv_apt_end_date      TYPE datum     ,                  "#EC NEEDED
     lv_rank              TYPE text30    ,                  "#EC NEEDED
     lv_pri_org_unit      TYPE hrobjid   ,                  "#EC NEEDED
     lv_pri_org_unit_desc TYPE string    ,                  "#EC NEEDED
     lv_msg_error         TYPE string    ,                  "#EC NEEDED
     lv_exception_name    TYPE string    ,
     lv_rfc_name          TYPE rs38l-name,
     lv_rfc_destination   TYPE bdbapidst ,
     lv_rfc_exists        TYPE boolean   .

*----------------------------------------------------------------------*
* Internal Tables
*----------------------------------------------------------------------*
  DATA:
     lt_adm_units   TYPE t_adm_unit,                        "#EC NEEDED
     lt_other_appts TYPE t_oth_apt .                        "#EC NEEDED

*----------------------------------------------------------------------*
* Begin
*----------------------------------------------------------------------*

*  IF me->lt_user_authorizations-zzr_hp_userid = 1.
*
*  ENDIF.


  lv_rfc_destination = zcl_rap_constants=>rfc_destination.
  lv_rfc_name        = me->lc_rfc_project_details        . " Z_RHP_READ_HR_APPT_INFO

  lv_rfc_exists = me->lo_pdr_validation->check_rfc( iv_destination = lv_rfc_destination
                                                    iv_rfc_name    = lv_rfc_name ).

  IF lv_rfc_exists = abap_false.
    RETURN.
  ENDIF.

* Remote Function Call to SAP ECC (FIS) - Z_RHP_READ_HR_APPT_INFO
  CALL FUNCTION lv_rfc_name
    DESTINATION lv_rfc_destination
    EXPORTING
      userid                    = iv_sap_username
    IMPORTING
      personnelnumber           = lv_personnel_number
      app_type                  = lv_app_type
      utorid                    = lv_utorid
      name                      = lv_name
      telephone_no              = lv_telephone
      email_address             = lv_email
      appointment_status        = lv_apt_status
      appointment_end_date      = lv_apt_end_date
      rank                      = lv_rank
      primary_org_unit          = lv_pri_org_unit
      primary_org_unit_descr    = lv_pri_org_unit_desc
      administrative_units      = lt_adm_units
      other_appts               = lt_other_appts
    EXCEPTIONS
      no_personnel_number       = 1
      person_does_not_exist     = 2
      missing_input_information = 3
      future_date_not_allowed   = 4
      system_failure            = 5
      communication_failure     = 6
      resource_failure          = 7
      OTHERS                    = 8.

  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        lv_exception_name = 'no_personnel_number'.          "#EC NOTEXT
      WHEN 2.
        lv_exception_name = 'person_does_not_exist'.        "#EC NOTEXT
      WHEN 3.
        lv_exception_name = 'missing_input_information'.    "#EC NOTEXT
      WHEN 4.
        lv_exception_name = 'future_date_not_allowed'.      "#EC NOTEXT
      WHEN 5.
        lv_exception_name = 'system_failure'.               "#EC NOTEXT
      WHEN 6.
        lv_exception_name = 'communication_failure'.        "#EC NOTEXT
      WHEN 7.
        lv_exception_name = 'resource_failure'.             "#EC NOTEXT
      WHEN OTHERS.
        lv_exception_name = 'unhlandled exception'.         "#EC NOTEXT
    ENDCASE.

    MESSAGE e035(zpdr) INTO lv_msg_error WITH lv_exception_name. " Error getting user supervisor: &
    me->lo_log->add_sys_message( abap_false ).
    RETURN.
  ENDIF.

ENDMETHOD.
