*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Check if all mandatory information were filled          *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD check_mandatory_fields.

  IF me->lo_log IS BOUND.
    CREATE OBJECT me->lo_pdr_validation TYPE zcl_rhp_pdr_validation
      EXPORTING
        io_log         = me->lo_log
        is_control     = me->ls_control
        is_description = me->ls_description
        is_pdr_save    = me->ls_pdr_save
        is_type        = me->ls_type
        iv_action      = me->lv_action
        iv_hpr_id      = me->lv_hpr_id
        iv_hpr_num     = me->lv_hpr_num
        iv_hpr_pdr_id  = me->lv_hpr_pdr_id
        iv_hpr_sub_ver = me->lv_hpr_sub_ver
        iv_hpr_ver     = me->lv_hpr_ver.

    me->lo_pdr_validation->check_mandatory_fields( ).
  ENDIF.

ENDMETHOD.
