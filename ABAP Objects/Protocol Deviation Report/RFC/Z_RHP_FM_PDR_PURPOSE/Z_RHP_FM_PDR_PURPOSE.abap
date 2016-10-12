FUNCTION z_rhp_fm_pdr_purpose.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(IV_TEXT) TYPE  STRING
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Return the OTR text about PDR purpose                   *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   11.07.2016   First development                            *
*----------------------------------------------------------------------*
  DATA:
    lo_sotr TYPE REF TO cl_sotr.

  CONSTANTS:
    lc_sotr_pdr     TYPE sotr_alias VALUE 'ZRHP/PDR',
    lc_lang_english TYPE spras      VALUE 'E'       .

  CREATE OBJECT lo_sotr TYPE cl_sotr
    EXPORTING
      i_langu = lc_lang_english.

  lo_sotr->get_string_by_alias( EXPORTING i_alias = lc_sotr_pdr
                                IMPORTING e_text  = iv_text ).

ENDFUNCTION.
