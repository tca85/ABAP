*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Submit Protocol Deviation Report                        *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD submit_pdr.

  me->read_pdr( IMPORTING ev_pdr_id         = ev_pdr_id
                          es_project_detail = es_project_detail
                          es_control        = es_control
                          es_description    = es_description
                          es_impact         = es_impact
                          es_type           = es_type
                          et_history        = et_history ).

  IF me->ls_control IS INITIAL.
    me->create_pdr( IMPORTING ev_pdr_id         = ev_pdr_id
                              es_project_detail = es_project_detail
                              es_control        = es_control
                              es_description    = es_description
                              es_impact         = es_impact
                              es_type           = es_type
                              et_history        = et_history ).

  ELSE.
    me->update_pdr( IMPORTING ev_pdr_id         = ev_pdr_id
                              es_project_detail = es_project_detail
                              es_control        = es_control
                              es_description    = es_description
                              es_impact         = es_impact
                              es_type           = es_type
                              et_history        = et_history ).
  ENDIF.

ENDMETHOD.
