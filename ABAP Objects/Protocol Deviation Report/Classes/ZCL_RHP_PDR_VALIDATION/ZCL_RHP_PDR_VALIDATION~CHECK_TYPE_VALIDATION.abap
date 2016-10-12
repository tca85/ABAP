*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Check deviation type validation                         *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   12.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD check_type_validation.
  DATA:
    lv_message TYPE string.                                 "#EC NEEDED

  IF me->ls_pdr_save-iv_pdr_deviation_type_x IS INITIAL.
    RETURN.
  ENDIF.

  IF me->ls_type IS INITIAL.
    MESSAGE e012(zpdr) INTO lv_message. " You must select the deviation type
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

  IF me->ls_type-zzr_hpr_chng_other IS NOT INITIAL                 " Other reason
    AND me->ls_type-zzr_hpr_chng_other_desc IS INITIAL.            " Other reason description


    MESSAGE e013(zpdr) INTO lv_message. " You must provide the other reason description
    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

ENDMETHOD.
