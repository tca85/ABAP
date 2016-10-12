*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Fill key fields                                         *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD fill_key_fields.

  me->ls_key_fields-zzr_hp_id       = me->lv_hpr_id     . " Human Protocol ID
  me->ls_key_fields-zzr_hpr_num     = me->lv_hpr_num    . " Human Protocol Number
  me->ls_key_fields-zzr_hpr_ver     = me->lv_hpr_ver    . " Human Protocol Version
  me->ls_key_fields-zzr_hpr_sub_ver = me->lv_hpr_sub_ver. " Human Protocol Sub Version
  me->ls_key_fields-zzr_hpr_pdr_id  = me->lv_hpr_pdr_id . " Protocol Deviation Report ID

ENDMETHOD.
