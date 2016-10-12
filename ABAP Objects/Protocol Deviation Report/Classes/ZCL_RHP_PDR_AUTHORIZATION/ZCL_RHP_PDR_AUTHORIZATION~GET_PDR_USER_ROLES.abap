*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Get PDR user roles                                      *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   11.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD get_pdr_user_roles.

  SELECT * FROM zzr_hp_pdr_role
    INTO TABLE et_pdr_role.

ENDMETHOD.
