*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Initialize Application Log (SLG1)                       *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD start_application_log.

  DATA: lv_slg1_id TYPE balnrext.

  CONCATENATE 'Protocol Deviation Report'(001)
              me->lv_hpr_id
              me->lv_hpr_num
              me->lv_hpr_ver
              me->lv_hpr_sub_ver
              me->lv_hpr_pdr_id
              me->lv_action
         INTO lv_slg1_id
    SEPARATED BY '|'.

  IF me->lo_log IS NOT BOUND.
    me->lo_log = zcl_app_log=>get_log( iv_object     = me->lc_slg1_object    " ZMRHP
                                       iv_subobject  = me->lc_slg1_subobject " ZMRHP_SUB
                                       iv_extnumber  = lv_slg1_id ).
  ENDIF.

ENDMETHOD.
