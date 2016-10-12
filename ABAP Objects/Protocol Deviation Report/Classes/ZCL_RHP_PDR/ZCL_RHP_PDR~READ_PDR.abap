*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Read Protocol Deviation Report                          *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD read_pdr.
  es_control = me->get_control_table( ).

  IF es_control IS NOT INITIAL.
    ev_pdr_id      = me->ls_key_fields-zzr_hpr_pdr_id.
    es_description = me->get_description_table( )    .
    es_impact      = me->get_impact_table( )         .
    es_type        = me->get_deviation_type_table( ) .
    et_history     = me->get_history_table( )        .
  ENDIF.

  es_project_detail = me->get_project_details( ).

ENDMETHOD.
