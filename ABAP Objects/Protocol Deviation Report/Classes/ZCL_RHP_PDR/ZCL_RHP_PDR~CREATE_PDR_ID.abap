*----------------------------------------------------------------------*
*                       University of Toronto                          *
*----------------------------------------------------------------------*
* Project    : RAISE MRHP - My Research Human Protocols                *
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Create a new PDR ID (Number Range Object / SNRO)        *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD create_pdr_id.

  ro_snro = me->create_number_range_object( me->lc_snro_pdr_id ).

ENDMETHOD.