*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Create a new Protocol Deviation Report                  *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD create_pdr.
*----------------------------------------------------------------------*
* Variables
*----------------------------------------------------------------------*
  DATA:
     lv_message TYPE string.                                "#EC NEEDED

*----------------------------------------------------------------------*
* Structures / Work-Areas
*----------------------------------------------------------------------*
  DATA:
     ls_control     TYPE zzr_hp_pdr_ctrl  ,
     ls_description TYPE zzr_hp_pdr_desc  ,
     ls_impact      TYPE zzr_hp_pdr_imp   ,
     ls_type        TYPE zzr_hp_pdr_type  ,
     ls_history     TYPE zzr_hp_pdr_hist  ,
     ls_created_by  TYPE zzr_hp_created_by.

*----------------------------------------------------------------------*
* Begin
*----------------------------------------------------------------------*

  ev_pdr_id = me->create_pdr_id( ).

  IF me->lo_log IS BOUND AND me->lo_log->has_error( abap_false ) = abap_true.
    RETURN.
  ELSE.
    me->lv_hpr_pdr_id = ev_pdr_id. " Protocol Deviation Report ID
  ENDIF.

  ls_history-zzr_hpr_seq_no = me->create_history_id( ).

  IF me->lo_log IS BOUND AND me->lo_log->has_error( abap_false ) = abap_true.
    RETURN.
  ENDIF.

* Must do that again in order to update the PDR id
  me->fill_key_fields( ).

  ls_created_by-zzr_hpr_pdr_created_by    = me->ls_user_authorizations-username.
  ls_created_by-zzr_hpr_pdr_created_pernr = me->ls_user_authorizations-pernr   .
  ls_created_by-zzr_hpr_pdr_created_date  = sy-datum                           .
  ls_created_by-zzr_hpr_pdr_created_time  = sy-uzeit                           .

  MOVE-CORRESPONDING:
      me->ls_control     TO ls_control    ,
      me->ls_description TO ls_description,
      me->ls_impact      TO ls_impact     ,
      me->ls_type        TO ls_type       .

  MOVE-CORRESPONDING:
      me->ls_key_fields TO ls_control    ,
      me->ls_key_fields TO ls_description,
      me->ls_key_fields TO ls_impact     ,
      me->ls_key_fields TO ls_type       ,
      me->ls_key_fields TO ls_history    .

  MOVE-CORRESPONDING:
      ls_created_by TO ls_control    ,
      ls_created_by TO ls_description,
      ls_created_by TO ls_impact     ,
      ls_created_by TO ls_type       ,
      ls_created_by TO ls_history    .

  ls_control-zzr_hp_ris_num = me->ls_project_details-zzr_hp_ris_num. " RIS Protocol Number
  ls_control-zzr_hp_actid   = me->lv_action                        .
  MODIFY zzr_hp_pdr_ctrl FROM ls_control                           .

  IF me->ls_pdr_save-iv_pdr_desc_x IS NOT INITIAL.
    MODIFY zzr_hp_pdr_desc FROM ls_description.
  ENDIF.

  IF me->ls_pdr_save-iv_pdr_impact_x IS NOT INITIAL.
    MODIFY zzr_hp_pdr_imp FROM ls_impact.
  ENDIF.

  IF me->ls_pdr_save-iv_pdr_deviation_type_x IS NOT INITIAL.
    MODIFY zzr_hp_pdr_type FROM ls_type.
  ENDIF.

  IF ls_history IS NOT INITIAL.
    ls_history-zzr_hp_actid = me->lv_action.
    MODIFY zzr_hp_pdr_hist FROM ls_history .
  ENDIF.

  me->read_pdr( IMPORTING ev_pdr_id         = ev_pdr_id
                          es_project_detail = es_project_detail
                          es_control        = es_control
                          es_description    = es_description
                          es_impact         = es_impact
                          es_type           = es_type
                          et_history        = et_history ).

  IF me->lo_log IS BOUND AND me->lo_log->has_error( abap_false ) = abap_false.
    IF me->lv_action = me->lc_submit.
      MESSAGE s044(zpdr) INTO lv_message WITH me->lv_hpr_pdr_id. " PDR & successfully created
    ELSEIF me->lv_action = me->lc_create.
      MESSAGE s030(zpdr) INTO lv_message WITH me->lv_hpr_pdr_id. " PDR & successfully saved
    ENDIF.

    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

ENDMETHOD.
