*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Get control table                                       *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD get_control_table.
  DATA:
    lv_message TYPE string.                                 "#EC NEEDED

  IF me->ls_key_fields IS NOT INITIAL.
    SELECT SINGLE * FROM zzr_hp_pdr_ctrl
      INTO es_control
      WHERE zzr_hp_id        = me->ls_key_fields-zzr_hp_id
        AND zzr_hpr_num      = me->ls_key_fields-zzr_hpr_num
        AND zzr_hpr_ver      = me->ls_key_fields-zzr_hpr_ver
        AND zzr_hpr_sub_ver  = me->ls_key_fields-zzr_hpr_sub_ver
        AND zzr_hpr_pdr_id   = me->ls_key_fields-zzr_hpr_pdr_id.
  ENDIF.

  IF es_control IS INITIAL.
    MESSAGE e027(zpdr) INTO lv_message. " Protocol Deviation Report not found
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

ENDMETHOD.
