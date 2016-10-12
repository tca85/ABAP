*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Get user authorization table                            *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD get_user_authorization.

  CREATE OBJECT me->lo_pdr_authentication TYPE zcl_rhp_pdr_authorization
    EXPORTING
      io_log            = me->lo_log
      io_pdr_validation = me->lo_pdr_validation.

  es_user_auth = me->lo_pdr_authentication->get_user_authorization( iv_sap_username = iv_sap_username
                                                                    iv_action_id    = me->lv_action ).

ENDMETHOD.
