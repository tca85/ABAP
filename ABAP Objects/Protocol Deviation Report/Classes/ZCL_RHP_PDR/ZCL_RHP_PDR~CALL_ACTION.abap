*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Check which option was choosen (Create, Submit, Read...)*
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD call_action.
*----------------------------------------------------------------------*
* Variables type ref.
*----------------------------------------------------------------------*
  DATA:
     lo_cx_pdr TYPE REF TO zcx_rhp_pdr.                     "#EC NEEDED

*----------------------------------------------------------------------*
* Begin
*----------------------------------------------------------------------*
  IF me->lo_log IS BOUND AND me->lo_log->has_error( abap_false ) = abap_true.
    et_return_messages = me->lo_log->get_messages_bapiret2( ).
    me->lo_log->save( ).
    RETURN.
  ENDIF.

  me->fill_key_fields( ).

  TRY.
      CASE me->lv_action.
        WHEN me->lc_create.
          me->create_pdr( IMPORTING ev_pdr_id         = ev_pdr_id
                                    es_project_detail = es_project_detail
                                    es_control        = es_control
                                    es_description    = es_description
                                    es_impact         = es_impact
                                    es_type           = es_type
                                    et_history        = et_history ).

        WHEN me->lc_submit.
          me->submit_pdr( IMPORTING ev_pdr_id         = ev_pdr_id
                                    es_project_detail = es_project_detail
                                    es_control        = es_control
                                    es_description    = es_description
                                    es_impact         = es_impact
                                    es_type           = es_type
                                    et_history        = et_history ).

        WHEN me->lc_read.
          me->read_pdr( IMPORTING ev_pdr_id         = ev_pdr_id
                                  es_project_detail = es_project_detail
                                  es_control        = es_control
                                  es_description    = es_description
                                  es_impact         = es_impact
                                  es_type           = es_type
                                  et_history        = et_history ).

        WHEN me->lc_update.
          me->update_pdr( IMPORTING ev_pdr_id         = ev_pdr_id
                                    es_project_detail = es_project_detail
                                    es_control        = es_control
                                    es_description    = es_description
                                    es_impact         = es_impact
                                    es_type           = es_type
                                    et_history        = et_history ).

        WHEN me->lc_viewed_by_ore OR me->lc_viewed_by_supervisor.

          me->update_pdr_viewed_action( IMPORTING ev_pdr_id         = ev_pdr_id
                                                  es_project_detail = es_project_detail
                                                  es_control        = es_control
                                                  es_description    = es_description
                                                  es_impact         = es_impact
                                                  es_type           = es_type
                                                  et_history        = et_history ).

        WHEN me->lc_delete.
          me->delete_pdr( ).

      ENDCASE.

    CATCH zcx_rhp_pdr INTO lo_cx_pdr.
      me->lo_log->add_sys_message( abap_false ).
  ENDTRY.

* Application Log Class
  IF me->lo_log IS BOUND.
    et_return_messages = me->lo_log->get_messages_bapiret2( ).
    me->lo_log->save( ).
  ENDIF.

ENDMETHOD.
