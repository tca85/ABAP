*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Get deviation type table                                *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD get_deviation_type_table.

  IF me->ls_key_fields IS NOT INITIAL.
    SELECT SINGLE * FROM zzr_hp_pdr_type
      INTO CORRESPONDING FIELDS OF es_type
      WHERE zzr_hp_id       = me->ls_key_fields-zzr_hp_id
        AND zzr_hpr_num     = me->ls_key_fields-zzr_hpr_num
        AND zzr_hpr_ver     = me->ls_key_fields-zzr_hpr_ver
        AND zzr_hpr_sub_ver = me->ls_key_fields-zzr_hpr_sub_ver
        AND zzr_hpr_pdr_id  = me->ls_key_fields-zzr_hpr_pdr_id.
  ENDIF.

ENDMETHOD.
