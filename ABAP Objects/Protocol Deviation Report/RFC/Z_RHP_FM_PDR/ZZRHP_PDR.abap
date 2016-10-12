*&---------------------------------------------------------------------*
*&  Include           ZZRHP_PDR
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*                       University of Toronto                          *
*----------------------------------------------------------------------*
* Project    : RAISE MRHP - My Research Human Protocols                *
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Protocol Deviation Report                               *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   15.07.2016   First development                            *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Variables type ref.
*----------------------------------------------------------------------*
  DATA:
    lo_pdr    TYPE REF TO zcl_rhp_pdr,
    lo_cx_pdr TYPE REF TO zcx_rhp_pdr.

*----------------------------------------------------------------------*
* Begin
*----------------------------------------------------------------------*

  TRY.
      CREATE OBJECT lo_pdr TYPE zcl_rhp_pdr
        EXPORTING
          iv_hpr_id      = iv_hpr_id
          iv_hpr_num     = iv_hpr_num
          iv_hpr_ver     = iv_hpr_ver
          iv_hpr_sub_ver = iv_hpr_sub_ver
          iv_hpr_pdr_id  = iv_hpr_pdr_id
          iv_action      = iv_action
          is_pdr_save    = is_pdr_save
          is_control     = is_control
          is_description = is_description
          is_impact      = is_impact
          is_type        = is_type.

      lo_pdr->call_action( IMPORTING ev_pdr_id          = ev_pdr_id
                                     es_project_detail  = es_project_detail
                                     es_control         = es_control
                                     es_description     = es_description
                                     es_impact          = es_impact
                                     es_type            = es_type
                                     et_history         = et_history
                                     et_return_messages = et_return_messages ).

    CATCH zcx_rhp_pdr INTO lo_cx_pdr.
      RAISE unhandled_exception.
  ENDTRY.