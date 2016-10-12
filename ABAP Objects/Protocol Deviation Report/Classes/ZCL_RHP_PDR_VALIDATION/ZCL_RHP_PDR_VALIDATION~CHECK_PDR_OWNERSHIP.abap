*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Check PDR ownership                                     *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   12.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD check_pdr_ownership.

  DATA:
    ls_protocol_deviation_report TYPE zzr_hp_pdr_ctrl,
    lv_message                   TYPE string         .

  IF iv_hpr_pdr_id IS INITIAL.
    RETURN.
  ENDIF.

  SELECT SINGLE * FROM zzr_hp_pdr_ctrl
   INTO ls_protocol_deviation_report
    WHERE zzr_hp_id       = iv_hpr_id
      AND zzr_hpr_num     = iv_hpr_num
      AND zzr_hpr_ver     = iv_hpr_version
      AND zzr_hpr_sub_ver = iv_hpr_sub_ver
      AND zzr_hpr_pdr_id  = iv_hpr_pdr_id.

  IF ls_protocol_deviation_report IS INITIAL.
    MESSAGE e042(zpdr) INTO lv_message. " Human Protocol details not found
    me->lo_log->add_sys_message( abap_false ).
    RETURN.
  ENDIF.

  IF ls_protocol_deviation_report-zzr_hpr_pdr_created_by <> es_user_details-username.
    MESSAGE e049(zpdr) INTO lv_message. " Protocol Deviation Report was not created by this user
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

ENDMETHOD.
