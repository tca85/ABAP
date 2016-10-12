*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Check description validations                           *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   12.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD check_description_validation.
  DATA:
    lv_message TYPE string.                                 "#EC NEEDED

  IF me->ls_pdr_save-iv_pdr_desc_x IS INITIAL.
    RETURN.
  ENDIF.

  IF me->ls_description IS INITIAL.
    MESSAGE e018(zpdr) INTO lv_message. " You must fill the Description & Follow-up information
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

  IF me->ls_description-zzr_hpr_prev_meas IS INITIAL.
    MESSAGE e020(zpdr) INTO lv_message. " You must describe which measures will be taken
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

  IF me->ls_description-zzr_hpr_assess_risk IS INITIAL.
    MESSAGE e022(zpdr) INTO lv_message. " You must describe if change overall assessment of the risk
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

  IF me->ls_description-zzr_hpr_inf_stud IS INITIAL                " Inform study participants (please explain below)
    AND me->ls_description-zzr_hpr_rev_form IS INITIAL             " Revised consent/assent forms (please explain below)
    AND me->ls_description-zzr_hpr_fup_other IS INITIAL            " Other, please specify below
    AND me->ls_description-zzr_hpr_fup_no_act IS INITIAL.          " No action required

    MESSAGE e023(zpdr) INTO lv_message. " You must select the follow-up action which you recommend
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

  IF ( me->ls_description-zzr_hpr_inf_stud IS NOT INITIAL          " Inform study participants (please explain below)
    OR me->ls_description-zzr_hpr_rev_form IS NOT INITIAL          " Revised consent/assent forms (please explain below)
    OR me->ls_description-zzr_hpr_fup_other IS NOT INITIAL         " Other, please specify below
    OR me->ls_description-zzr_hpr_fup_no_act IS NOT INITIAL )      " No action required
    AND me->ls_description-zzr_hpr_fup_reason IS INITIAL.          " Reason of follow-up recommendation choosen

    MESSAGE e024(zpdr) INTO lv_message. " You must describe the reason of the follow-up action which you recommended
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

ENDMETHOD.
