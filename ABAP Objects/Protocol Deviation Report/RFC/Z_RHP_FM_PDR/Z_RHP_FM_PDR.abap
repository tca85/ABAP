FUNCTION z_rhp_fm_pdr.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_HPR_ID) TYPE  ZZRHPID OPTIONAL
*"     VALUE(IV_HPR_NUM) TYPE  ZZRHPRNUM OPTIONAL
*"     VALUE(IV_HPR_VER) TYPE  ZZRHPRVER OPTIONAL
*"     VALUE(IV_HPR_SUB_VER) TYPE  ZZRHPRSUBVER OPTIONAL
*"     VALUE(IV_HPR_PDR_ID) TYPE  ZZRHPRPDRID OPTIONAL
*"     VALUE(IV_ACTION) TYPE  ZZRHPACTID OPTIONAL
*"     VALUE(IS_PDR_SAVE) TYPE  ZRHP_S_HPR_PDR_SAVE_STRUCT OPTIONAL
*"     VALUE(IS_CONTROL) TYPE  ZZR_HP_PDR_CTRL_IN_S OPTIONAL
*"     VALUE(IS_DESCRIPTION) TYPE  ZZR_HP_PDR_DESC_IN_S OPTIONAL
*"     VALUE(IS_IMPACT) TYPE  ZZR_HP_PDR_IMP_IN_S OPTIONAL
*"     VALUE(IS_TYPE) TYPE  ZZR_HP_PDR_TYPE_IN_S OPTIONAL
*"  EXPORTING
*"     VALUE(EV_PDR_ID) TYPE  ZZRHPID
*"     VALUE(ES_PROJECT_DETAIL) TYPE  ZZR_HP_PDR_PRJ_DETAILS_S
*"     VALUE(ES_CONTROL) TYPE  ZZR_HP_PDR_CTRL
*"     VALUE(ES_DESCRIPTION) TYPE  ZZR_HP_PDR_DESC_S
*"     VALUE(ES_IMPACT) TYPE  ZZR_HP_PDR_IMP_S
*"     VALUE(ES_TYPE) TYPE  ZZR_HP_PDR_TYPE_S
*"     VALUE(ET_HISTORY) TYPE  ZZR_HP_PDR_HIST_T
*"     VALUE(ET_RETURN_MESSAGES) TYPE  BAPIRET2_T
*"  EXCEPTIONS
*"      UNHANDLED_EXCEPTION
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Protocol Deviation Report (Create, Read, Submit, Update)*
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   15.07.2016   First development                            *
*----------------------------------------------------------------------*

  INCLUDE zzrhp_pdr.

ENDFUNCTION.
