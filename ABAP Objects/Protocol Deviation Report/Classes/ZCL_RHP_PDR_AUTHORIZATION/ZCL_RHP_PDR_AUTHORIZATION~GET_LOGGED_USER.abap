*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Get logged user                                         *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   11.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD get_logged_user.
*----------------------------------------------------------------------*
* Internal Tables
*----------------------------------------------------------------------*
  DATA:
    lt_ris_roles TYPE tt_ris_roles,
    lt_pdr_users TYPE tt_pdr_users,
    lt_pdr_roles TYPE tt_pdr_role .

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    ls_ris_role LIKE LINE OF lt_ris_roles,
    ls_pdr_user LIKE LINE OF lt_pdr_users,
    ls_pdr_role LIKE LINE OF lt_pdr_roles.

*----------------------------------------------------------------------*
* Variables
*----------------------------------------------------------------------*
  DATA:
    lv_pernr     TYPE ess_emp-employeenumber,
    lv_msg_error TYPE string                .

*----------------------------------------------------------------------*
* Begin
*----------------------------------------------------------------------*

  me->get_ris_user_roles( EXPORTING iv_sap_username = iv_sap_username
                          IMPORTING et_ris_roles    = lt_ris_roles
                                    ev_pernr        = lv_pernr ).

  lt_pdr_users = me->get_pdr_allowed_users( ).
  lt_pdr_roles = me->get_pdr_user_roles( )   .

  LOOP AT lt_ris_roles INTO ls_ris_role.
    READ TABLE lt_pdr_roles
    INTO ls_pdr_role
    WITH KEY zzr_hp_ris_role = ls_ris_role-ris_role.

    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    READ TABLE lt_pdr_users
    INTO ls_pdr_user
    WITH KEY zzr_hp_userid = ls_pdr_role-zzr_hp_userid.

    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    es_user_details-username = iv_sap_username           .
    es_user_details-pernr    = lv_pernr                  .
    es_user_details-userid   = ls_pdr_user-zzr_hp_userid .
    es_user_details-userdsc  = ls_pdr_user-zzr_hp_userdsc.
  ENDLOOP.

  IF es_user_details IS INITIAL.
    MESSAGE e047(zpdr) INTO lv_msg_error. " User doesn't have RIS permission
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

ENDMETHOD.
