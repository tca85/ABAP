*----------------------------------------------------------------------*
* Project    : RAISE MRHP - My Research Human Protocols                *
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Get domain value text                                   *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD get_domain_value_text.
  DATA: lv_domvalue TYPE dd07v-domvalue_l.

  lv_domvalue = iv_domvalue.

  CALL FUNCTION 'STF4_GET_DOMAIN_VALUE_TEXT'
    EXPORTING
      iv_domname      = iv_domname
      iv_value        = lv_domvalue
    IMPORTING
      ev_value_text   = ev_value
    EXCEPTIONS                                              "#EC FB_RC
      value_not_found = 1
      OTHERS          = 2.

ENDMETHOD.
