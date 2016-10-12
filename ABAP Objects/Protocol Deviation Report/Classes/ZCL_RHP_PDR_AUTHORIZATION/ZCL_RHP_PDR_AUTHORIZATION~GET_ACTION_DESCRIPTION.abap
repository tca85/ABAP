*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Get Action description                                  *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   11.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD get_action_description.

  SELECT SINGLE zzr_hp_actdsc
   FROM zzr_hp_pdr_actt
   INTO ev_action_dsc
    WHERE zzr_hp_actid = iv_action.

ENDMETHOD.
