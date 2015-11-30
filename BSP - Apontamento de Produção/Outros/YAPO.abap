REPORT yapo NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
*                 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                   *
*----------------------------------------------------------------------*
* Programa...: YAPO                                                    *
* Transação..: YAPO                                                    *
* Descrição..: Carregar Apontamento de ordens de processo (BSP)        *
* Tipo.......: Report                                                  *
* Módulo.....: PP/APO                                                  *
* ABAP.......: Thiago Cordeiro Alves                                   *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  19.08.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
DATA:
   v_url          TYPE string       ,
   v_nome_app_bsp TYPE string       ,
   v_url_browser  TYPE c LENGTH 4096,
   v_pagina       TYPE string       ,
   t_parametros   TYPE tihttpnvp    .

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
CONSTANTS:
  c_apontamento_producao TYPE o2appl-applname VALUE 'YAPO'.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------
START-OF-SELECTION.

* Nome de uma aplicação BSP
  SELECT SINGLE applname
   FROM o2appl
   INTO v_nome_app_bsp
   WHERE applname = c_apontamento_producao.

  IF v_nome_app_bsp IS INITIAL.
    MESSAGE 'Aplicação BSP não existe no ambiente' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  cl_http_ext_webapp=>create_url_for_bsp_application( EXPORTING bsp_application      = v_nome_app_bsp
                                                                bsp_start_page       = v_pagina
                                                                bsp_start_parameters = t_parametros
                                                      IMPORTING abs_url              = v_url ).

  v_url_browser = v_url.

  CALL FUNCTION 'CALL_BROWSER'
    EXPORTING
      url                    = v_url_browser
    EXCEPTIONS
      frontend_not_supported = 1
      frontend_error         = 2
      prog_not_found         = 3
      no_batch               = 4
      unspecified_error      = 5
      OTHERS                 = 6.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.