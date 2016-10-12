*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Constructor                                             *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD constructor.

  me->complete_number_zeros_left( EXPORTING iv_number    = iv_hpr_id
                                  IMPORTING ev_converted = me->lv_hpr_id ).

  me->complete_number_zeros_left( EXPORTING iv_number    = iv_hpr_num
                                  IMPORTING ev_converted = me->lv_hpr_num ).

  me->complete_number_zeros_left( EXPORTING iv_number    = iv_hpr_ver
                                  IMPORTING ev_converted = me->lv_hpr_ver ).

  me->complete_number_zeros_left( EXPORTING iv_number    = iv_hpr_sub_ver
                                  IMPORTING ev_converted = me->lv_hpr_sub_ver ).

  me->complete_number_zeros_left( EXPORTING iv_number    = iv_hpr_pdr_id
                                  IMPORTING ev_converted = me->lv_hpr_pdr_id ).

  me->lv_action       = iv_action     . " Create, Submit, Read, Update....
  me->ls_pdr_save     = is_pdr_save   . " Protocol Deviation Report Save Structure
  me->ls_control      = is_control    . " Control
  me->ls_type         = is_type       . " Type
  me->ls_impact       = is_impact     . " Impact
  me->ls_description  = is_description. " Description
  me->lv_sap_username = sy-uname      . " SAP Username

  TRANSLATE me->lv_action TO UPPER CASE.

*************************************************************
****************** test, only user with RIS roles ***********
  me->lv_sap_username = 'AMSRIS01'. " SAP Username
*************************************************************

  me->start_application_log( ).

  me->check_mandatory_fields( ).

  IF me->lo_log IS BOUND AND me->lo_log->has_error( abap_false ) = abap_true.
    RETURN.
  ENDIF.

  me->ls_user_authorizations = me->get_user_authorization( me->lv_sap_username ).

  IF me->ls_user_authorizations-actionid IS NOT INITIAL.
    me->lo_pdr_validation->check_hp_authorization( iv_hpr_id       = me->lv_hpr_id
                                                   iv_hpr_num      = me->lv_hpr_num
                                                   iv_hpr_version  = me->lv_hpr_ver
                                                   iv_hpr_sub_ver  = me->lv_hpr_sub_ver
                                                   iv_hpr_pdr_id   = me->lv_hpr_pdr_id
                                                   es_user_details = me->ls_user_authorizations ).

    me->ls_project_details = me->get_human_protocol_details( ).
  ELSE.
    RETURN.
  ENDIF.

ENDMETHOD.
