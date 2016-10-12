*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Get user authorization table                            *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   11.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD get_user_authorization.
  DATA:
     lv_message            TYPE string             ,        "#EC NEEDED
     lv_action_description TYPE zzrhpactdsc        ,
     ls_authorization      TYPE zzr_hp_pdr_auth    ,
     ls_usr_details        TYPE t_usr_authorization.

  ls_usr_details        = me->get_logged_user( iv_sap_username ).
  lv_action_description = me->get_action_description( iv_action_id ).

  IF ls_usr_details IS INITIAL.
    RETURN.
  ENDIF.

  SELECT SINGLE * FROM zzr_hp_pdr_auth
    INTO ls_authorization
     WHERE zzr_hp_userid = ls_usr_details-userid
       AND zzr_hp_actid  = zcl_rhp_pdr=>lc_full_access.

  lv_action_description = me->get_action_description( zcl_rhp_pdr=>lc_full_access ).

  IF ls_authorization IS INITIAL.
    SELECT SINGLE * FROM zzr_hp_pdr_auth
      INTO ls_authorization
       WHERE zzr_hp_userid = ls_usr_details-userid
         AND zzr_hp_actid  = iv_action_id.
  ENDIF.

  MOVE-CORRESPONDING ls_usr_details TO es_user_details.
  es_user_details-actionid  = ls_authorization-zzr_hp_actid.
  es_user_details-actiondsc = lv_action_description        .

  IF ls_authorization-zzr_hp_actid IS INITIAL.
    MESSAGE e048(zpdr) INTO lv_message WITH ls_usr_details-username
                                            ls_usr_details-userdsc
                                            lv_action_description. " The user & with role & has no authorization to & PDR

    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

ENDMETHOD.
