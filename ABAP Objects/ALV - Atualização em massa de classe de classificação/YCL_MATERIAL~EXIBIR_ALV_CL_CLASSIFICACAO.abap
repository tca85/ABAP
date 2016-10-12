*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* Método   : EXIBIR_ALV_CL_CLASSIFICACAO                               *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Inibir campos do search help (f4) das características     *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  25.11.2015  #135533 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD exibir_alv_cl_classificacao.

*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
     t_alv_retorno     TYPE STANDARD TABLE OF ty_alv_cl_classif,
     t_alv_retorno_aux TYPE STANDARD TABLE OF ty_alv_cl_classif.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro TYPE string.

*----------------------------------------------------------------------*
* Variáveis tipo referência
*----------------------------------------------------------------------*
  DATA:
    o_salv_table          TYPE REF TO cl_salv_table         ,
    o_salv_functions_list TYPE REF TO cl_salv_functions_list,
    o_salv_columns        TYPE REF TO cl_salv_columns       ,
    o_salv_column_table   TYPE REF TO cl_salv_column_table  ,
    o_salv_selections     TYPE REF TO cl_salv_selections    ,
    o_salv_msg            TYPE REF TO cx_salv_msg           ,
    o_salv_not_found      TYPE REF TO cx_salv_not_found     .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  IF t_alv_cl_class IS INITIAL.
    RETURN.
  ENDIF.

  APPEND LINES OF t_alv_cl_class TO t_alv_retorno.

  APPEND LINES OF t_alv_retorno TO t_alv_retorno_aux.
  SORT t_alv_retorno_aux BY erro ASCENDING.
  DELETE t_alv_retorno_aux WHERE erro IS INITIAL.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = o_salv_table
                              CHANGING t_table       = t_alv_retorno ).

    CATCH cx_salv_msg INTO o_salv_msg.
      v_msg_erro = o_salv_msg->get_text( ).
      MESSAGE v_msg_erro TYPE 'S' DISPLAY LIKE 'E'.
  ENDTRY.

  o_salv_columns = o_salv_table->get_columns( ).
  o_salv_columns->set_optimize( abap_true ).

  o_salv_functions_list = o_salv_table->get_functions( ).
  o_salv_functions_list->set_default( abap_true ).

  o_salv_selections = o_salv_table->get_selections( ).
  o_salv_selections->set_selection_mode( if_salv_c_selection_mode=>cell ).

  IF t_alv_retorno_aux IS INITIAL.
    TRY.
        o_salv_column_table ?= o_salv_columns->get_column( 'ERRO' ).

        o_salv_column_table->set_visible( if_salv_c_bool_sap=>false ).

      CATCH cx_salv_not_found INTO o_salv_not_found.
        v_msg_erro = o_salv_not_found->get_text( ).
    ENDTRY.
  ENDIF.

  o_salv_table->display( ).

ENDMETHOD.