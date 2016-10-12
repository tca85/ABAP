*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Constructor                                             *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   12.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD constructor.
  me->lo_log         = io_log        .
  me->ls_control     = is_control    .
  me->ls_description = is_description.
  me->ls_pdr_save    = is_pdr_save   .
  me->ls_type        = is_type       .
  me->lv_action      = iv_action     .
  me->lv_hpr_id      = iv_hpr_id     .
  me->lv_hpr_num     = iv_hpr_num    .
  me->lv_hpr_pdr_id  = iv_hpr_pdr_id .
  me->lv_hpr_sub_ver = iv_hpr_sub_ver.
  me->lv_hpr_ver     = iv_hpr_ver    .

ENDMETHOD.
