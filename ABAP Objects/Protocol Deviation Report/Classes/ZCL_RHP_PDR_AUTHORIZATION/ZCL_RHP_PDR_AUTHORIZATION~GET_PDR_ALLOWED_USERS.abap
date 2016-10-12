*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Get allowed users (Applicant, Supervisor, ORE, REB)     *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   11.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD get_pdr_allowed_users.

  SELECT * FROM zzr_hp_pdr_usert
    INTO TABLE et_pdr_users.

ENDMETHOD.
