*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Check create validations                                *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   12.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD check_create_validation.

  me->check_key_validation( ).
  me->check_control_validation( ).
  me->check_type_validation( ).
  me->check_impact_validation( ).
  me->check_description_validation( ).

ENDMETHOD.
