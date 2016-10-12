*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Check if Human Protocol exists                          *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   12.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD check_human_protocol.
  DATA:
    lv_message TYPE string.                                 "#EC NEEDED

  SELECT SINGLE zzr_hp_id zzr_hpr_num zzr_hpr_ver zzr_hpr_sub_ver
    FROM zzr_hp_hpr_head
    INTO is_human_protocol
    WHERE zzr_hp_id       = me->lv_hpr_id
      AND zzr_hpr_num     = me->lv_hpr_num
      AND zzr_hpr_ver     = me->lv_hpr_ver
      AND zzr_hpr_sub_ver = me->lv_hpr_sub_ver.

  IF is_human_protocol IS INITIAL.
    MESSAGE e042(zpdr) INTO lv_message. " Human Protocol not found
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

ENDMETHOD.
