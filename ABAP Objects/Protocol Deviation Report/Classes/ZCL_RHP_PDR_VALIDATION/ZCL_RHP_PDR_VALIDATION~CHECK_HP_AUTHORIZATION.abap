*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Check Human Protocol authorization                      *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   15.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD check_hp_authorization.
  DATA:
    ls_human_protocol      TYPE zzr_hp_protocol ,
    ls_human_protocol_head TYPE t_human_protocol,
    lv_message             TYPE string          .           "#EC NEEDED

  ls_human_protocol_head = me->check_human_protocol( ).

  IF ls_human_protocol_head IS INITIAL.
    RETURN.
  ENDIF.

  SELECT SINGLE * FROM zzr_hp_protocol
   INTO ls_human_protocol
    WHERE zzr_hp_id = ls_human_protocol_head-zzr_hp_id. " Human Protocol Id

  IF ls_human_protocol IS INITIAL.
    MESSAGE e042(zpdr) INTO lv_message. " Human Protocol details not found
    me->lo_log->add_sys_message( abap_false ).
    RETURN.
  ENDIF.

* Check if user has right to choosen action
  CASE es_user_details-actionid.
    WHEN zcl_rhp_pdr=>lc_full_access.
      RETURN.

    WHEN zcl_rhp_pdr=>lc_access_under_supervisor.
*......... check access under user supervisor <<<<<<<<<<<<<<<<<<<<<<<<<

    WHEN zcl_rhp_pdr=>lc_create
      OR zcl_rhp_pdr=>lc_read
      OR zcl_rhp_pdr=>lc_update
      OR zcl_rhp_pdr=>lc_submit.

      IF ls_human_protocol-zzr_create_user <> es_user_details-username.
        MESSAGE e051(zpdr) INTO lv_message WITH es_user_details-username. " This Human Protocol was not created by user &
        me->lo_log->add_sys_message( abap_false ).
        RETURN.
      ENDIF.

      me->check_pdr_ownership( iv_hpr_id       = iv_hpr_id
                               iv_hpr_num      = iv_hpr_num
                               iv_hpr_version  = iv_hpr_version
                               iv_hpr_sub_ver  = iv_hpr_sub_ver
                               iv_hpr_pdr_id   = iv_hpr_pdr_id
                               es_user_details = es_user_details ).

    WHEN zcl_rhp_pdr=>lc_viewed_by_ore.
      IF  es_user_details-userid <> zcl_rhp_pdr=>lc_user_ore_manager
       OR es_user_details-userid <> zcl_rhp_pdr=>lc_user_ore_director.

        MESSAGE e052(zpdr) INTO lv_message WITH es_user_details-username. " The user & is not ORE and can't change status
        me->lo_log->add_sys_message( abap_false ).
        RETURN.
      ENDIF.

    WHEN zcl_rhp_pdr=>lc_viewed_by_supervisor.
      IF es_user_details-userid <> zcl_rhp_pdr=>lc_user_supervisor.
        MESSAGE e053(zpdr) INTO lv_message WITH es_user_details-username. " The user & is not Supervisor and can't change status
        me->lo_log->add_sys_message( abap_false ).
        RETURN.
      ENDIF.

  ENDCASE.

ENDMETHOD.
