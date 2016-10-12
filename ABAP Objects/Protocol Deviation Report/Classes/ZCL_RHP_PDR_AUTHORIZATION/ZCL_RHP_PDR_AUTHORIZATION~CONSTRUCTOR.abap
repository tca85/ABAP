*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Constructor                                             *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   11.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD constructor.
  me->lo_log            = io_log           .
  me->lo_pdr_validation = io_pdr_validation.
ENDMETHOD.
