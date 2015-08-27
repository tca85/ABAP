REPORT yst03n NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
* Programa...: YST03N                                                  *
* Transação..: YST03N                                                  *
* Descrição..: Lista de transações utilizadas durante mês              *
* Tipo.......: ALV                                                     *
* ABAP.......: Thiago Cordeiro Alves                                   *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  20.08.2015  #117354 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_alv                     ,
    user  TYPE swncuname              , " Nome do usuário
    type  TYPE subc                   , " Tipo do programa
    title TYPE progname               , " Nome do programa
    mes   TYPE /bi0/scalmonth-calmonth,
  END OF ty_alv                       .

*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
DATA:
   t_alv     TYPE STANDARD TABLE OF ty_alv          ,
   t_acessos TYPE STANDARD TABLE OF swncaggusertcode.

*----------------------------------------------------------------------*
* Work-areas
*----------------------------------------------------------------------*
DATA:
   w_alv        LIKE LINE OF t_alv    ,
   w_acessos    LIKE LINE OF t_acessos,
   w_msg_erro   TYPE bal_s_msg        ,
   w_layout_key TYPE salv_s_layout_key.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
DATA:
   v_msg_erro TYPE string.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
DATA:
   v_periodo TYPE d        ,
   v_usuario TYPE swncuname.

*----------------------------------------------------------------------*
* Variáveis tipo referência
*----------------------------------------------------------------------*
DATA:
   o_salv_table         TYPE REF TO cl_salv_table         , " Basis Class for Simple Tables
   o_salv_functions     TYPE REF TO cl_salv_functions_list, " Generic and User-Defined Functions in List-Type Tables
   o_salv_sorts         TYPE REF TO cl_salv_sorts         , " All Sort Objects
   o_cl_salv_layout     TYPE REF TO cl_salv_layout        , " Settings for Layout
   o_cx_salv_msg        TYPE REF TO cx_salv_msg           , " ALV: General Error Class with Message
   o_cx_salv_not_found  TYPE REF TO cx_salv_not_found     , " ALV: General Error Class (Checked During Syntax Check)
   o_cx_salv_existing   TYPE REF TO cx_salv_existing      , " ALV: General Error Class (Checked During Syntax Check)
   o_cx_salv_data_error TYPE REF TO cx_salv_data_error    . " ALV: General Error Class (Checked During Syntax Check)

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
CONSTANTS:
   c_variante_default TYPE slis_vari VALUE 'DEFAULT'.

*----------------------------------------------------------------------*
* Tela de seleção
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t001.
SELECT-OPTIONS: s_usr  FOR v_usuario                    . " Usuário
PARAMETERS:     p_mes  TYPE /bi0/scalmonth-calmonth     , " Mês
                p_tipo TYPE subc OBLIGATORY             . " Tipo do programa
SELECTION-SCREEN END OF BLOCK b1                        .

*----------------------------------------------------------------------*
* Process Before Output
*----------------------------------------------------------------------*
INITIALIZATION.
  t001 = 'Critérios de seleção'.

  p_mes = sy-datum.
  p_tipo = 'T'.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
START-OF-SELECTION.

  CONCATENATE p_mes '01' INTO v_periodo.

  CALL FUNCTION 'SWNC_COLLECTOR_GET_AGGREGATES'
    EXPORTING
      component     = 'TOTAL'
      periodtype    = 'M'
      periodstrt    = v_periodo
    TABLES
      usertcode     = t_acessos
    EXCEPTIONS
      error_message = 1
      no_data_found = 1
      OTHERS        = 2.

  LOOP AT s_usr.
*    DELETE T_

  ENDLOOP.

  LOOP AT t_acessos INTO w_acessos WHERE tasktype = '01'.

    IF w_acessos-entry_id+72 = p_tipo.

      IF s_usr IS INITIAL.
        w_alv-user  = w_acessos-account     .
        w_alv-type  = w_acessos-entry_id+72 .
        w_alv-title = w_acessos-entry_id(40).
        w_alv-mes   = p_mes                 .
        APPEND w_alv TO t_alv               .
      ELSE.
        READ TABLE s_usr
        TRANSPORTING NO FIELDS
        WITH KEY low = w_acessos-account.

        IF sy-subrc = 0.
          w_alv-user  = w_acessos-account     .
          w_alv-type  = w_acessos-entry_id+72 .
          w_alv-title = w_acessos-entry_id(40).
          w_alv-mes   = p_mes                 .
          APPEND w_alv TO t_alv               .
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF t_alv IS INITIAL.
    MESSAGE 'Dados não encontrados' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = o_salv_table
                               CHANGING t_table      = t_alv ).

    CATCH cx_salv_msg INTO o_cx_salv_msg.
      w_msg_erro = o_cx_salv_msg->get_message( ).
  ENDTRY.

  TRY.
*     Exibe todos os botões da PF-Status
      o_salv_functions = o_salv_table->get_functions( ).
      o_salv_functions->set_all( abap_true )           .

*     Permite que o usuário salve uma variante do layout
      o_cl_salv_layout = o_salv_table->get_layout( ).

      w_layout_key-report = sy-repid.

      o_cl_salv_layout->set_key( w_layout_key )                                .
      o_cl_salv_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
      o_cl_salv_layout->set_default( abap_true )                               .
      o_cl_salv_layout->set_initial_layout( c_variante_default )               .

      o_salv_sorts = o_salv_table->get_sorts( ).

    CATCH cx_salv_not_found INTO o_cx_salv_not_found.
      w_msg_erro = o_cx_salv_not_found->get_message( ).

    CATCH cx_salv_existing INTO o_cx_salv_existing.
      w_msg_erro = o_cx_salv_existing->get_message( ).

    CATCH cx_salv_data_error INTO o_cx_salv_data_error.
      w_msg_erro = o_cx_salv_data_error->get_message( ).
  ENDTRY.

  IF w_msg_erro IS NOT INITIAL.
    CONCATENATE w_msg_erro-msgv1
                w_msg_erro-msgv2
                w_msg_erro-msgv3
                w_msg_erro-msgv4
           INTO v_msg_erro SEPARATED BY space.

    MESSAGE v_msg_erro TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.

  ELSE.
    SORT t_alv BY user type title ASCENDING.

    o_salv_table->display( ).
  ENDIF.