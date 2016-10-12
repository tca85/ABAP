*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Check if all mandatory information were filled          *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   12.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD check_mandatory_fields.

  me->check_allowed_actions( ).

  CASE me->lv_action.
    WHEN zcl_rhp_pdr=>lc_create OR zcl_rhp_pdr=>lc_submit.
      me->check_create_validation( ).

    WHEN zcl_rhp_pdr=>lc_read.
      me->check_read_validation( ).

    WHEN zcl_rhp_pdr=>lc_update.
      me->check_update_validation( ).

    WHEN zcl_rhp_pdr=>lc_delete.
      me->check_delete_validation( ).

  ENDCASE.

ENDMETHOD.
