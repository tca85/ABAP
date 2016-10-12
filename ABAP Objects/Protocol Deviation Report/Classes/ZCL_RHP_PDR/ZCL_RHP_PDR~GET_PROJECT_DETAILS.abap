*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Get project details such as Applicant and Supervisor    *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD get_project_details.

* The attribute was filled in get_human_protocol_details method called on Constructor
* in order to provide the RIS Protocol Number when you create/submit a PDR

  es_project_detail-zzr_hp_id                 = me->lv_hpr_id                          . " Human Protocol ID
  es_project_detail-zzr_hp_title              = me->ls_project_details-zzr_hp_title    . " Human Protocol Title
  es_project_detail-zzr_hpr_pdr_prj_app_name  = me->ls_project_details-zzr_appl_name   . " Applicant Name
  es_project_detail-zzr_hpr_pdr_prj_app_dep   = me->ls_project_details-zzr_appl_dept_nm. " Applicant Department
  es_project_detail-zzr_hpr_pdr_prj_app_phone = me->ls_project_details-zzr_appl_tele   . " Applicant Phone
  es_project_detail-zzr_hpr_pdr_prj_app_email = me->ls_project_details-zzr_appl_email  . " Applicant Email
  es_project_detail-zzr_hpr_pdr_prj_sup_name  = me->ls_project_details-zzr_sup_name    . " Supervisor Name
  es_project_detail-zzr_hpr_pdr_prj_sup_dep   = me->ls_project_details-zzr_sup_dept_nm . " Supervisor Department
  es_project_detail-zzr_hpr_pdr_prj_sup_phone = me->ls_project_details-zzr_sup_tele    . " Supervisor Phone
  es_project_detail-zzr_hpr_pdr_prj_sup_email = me->ls_project_details-zzr_sup_email   . " Supervisor E-mail

ENDMETHOD.
