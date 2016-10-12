*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Get human protocol details                              *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD get_human_protocol_details.
  DATA:
    lv_message TYPE string.                                 "#EC NEEDED

  IF me->lv_hpr_id IS NOT INITIAL.
    SELECT SINGLE * FROM zzr_hp_protocol
     INTO CORRESPONDING FIELDS OF es_protocol
      WHERE zzr_hp_id = me->lv_hpr_id.       " Human Protocol Id

  ENDIF.

  IF es_protocol IS NOT INITIAL.
    es_protocol-zzr_hp_status_t = me->get_domain_value_text( iv_domname  = 'ZZRHPSTATUS'
                                                             iv_domvalue = es_protocol-zzr_hp_status ).
  ELSE.
    MESSAGE e042(zpdr) INTO lv_message. " Human Protocol details not found
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

ENDMETHOD.
