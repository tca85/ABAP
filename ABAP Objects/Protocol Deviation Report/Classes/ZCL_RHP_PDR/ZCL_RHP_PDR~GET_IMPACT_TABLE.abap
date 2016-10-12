*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Get impact table                                        *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD get_impact_table.

  IF me->ls_key_fields IS NOT INITIAL.
    SELECT SINGLE * FROM zzr_hp_pdr_imp
      INTO CORRESPONDING FIELDS OF es_impact
      WHERE zzr_hp_id       = me->ls_key_fields-zzr_hp_id
        AND zzr_hpr_num     = me->ls_key_fields-zzr_hpr_num
        AND zzr_hpr_ver     = me->ls_key_fields-zzr_hpr_ver
        AND zzr_hpr_sub_ver = me->ls_key_fields-zzr_hpr_sub_ver
        AND zzr_hpr_pdr_id  = me->ls_key_fields-zzr_hpr_pdr_id.
  ENDIF.

ENDMETHOD.
