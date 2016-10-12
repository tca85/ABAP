*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Complete number with zeros left                         *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD complete_number_zeros_left.

  CALL 'CONVERSION_EXIT_ALPHA_INPUT' ID 'INPUT'  FIELD iv_number
                                     ID 'OUTPUT' FIELD ev_converted.

ENDMETHOD.
