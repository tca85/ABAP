*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* Método   : EXIBIR_TABELA_COMO_SEARCH_HELP                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Exibir tabela como search help                            *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  16.09.2015  #121646 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD exibir_tabela_como_search_help.
*----------------------------------------------------------------------*
* Variáveis tipo referência
*----------------------------------------------------------------------*
  DATA:
    o_salv_table_f4       TYPE REF TO cl_salv_table         ,
    o_salv_functions_list TYPE REF TO cl_salv_functions_list,
    o_salv_columns        TYPE REF TO cl_salv_columns       ,
    o_salv_column_table   TYPE REF TO cl_salv_column_table  ,
    o_salv_selections     TYPE REF TO cl_salv_selections    ,
    o_salv_msg            TYPE REF TO cx_salv_msg           ,
    o_salv_not_found      TYPE REF TO cx_salv_not_found     .

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro TYPE string.                                 "#EC NEEDED

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_campo_alv TYPE ty_campo_alv.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = o_salv_table_f4
                               CHANGING t_table      = im_tabela ).

    CATCH cx_salv_msg INTO o_salv_msg.
      v_msg_erro = o_salv_msg->get_text( ).
  ENDTRY.

  o_salv_functions_list = o_salv_table_f4->get_functions( ).
  o_salv_functions_list->set_default( abap_true ).

* Seleciona somente 1 linha
  o_salv_selections = o_salv_table_f4->get_selections( ).
  o_salv_selections->set_selection_mode( if_salv_c_selection_mode=>single ).

  o_salv_columns = o_salv_table_f4->get_columns( ).
  o_salv_columns->set_optimize( abap_true ).

  LOOP AT im_t_campo_alv INTO w_campo_alv.
    TRY.
        o_salv_column_table ?= o_salv_columns->get_column( w_campo_alv-nome ).

        o_salv_column_table->set_visible( if_salv_c_bool_sap=>false ).

      CATCH cx_salv_not_found INTO o_salv_not_found.
        v_msg_erro = o_salv_not_found->get_text( ).
    ENDTRY.
  ENDLOOP.

  o_salv_table_f4->set_screen_popup( start_column = 50
                                     end_column   = 130
                                     start_line   = 3
                                     end_line     = 20 ).

  o_salv_table_f4->display( ).

  ex_linhas_selecionadas = o_salv_selections->get_selected_rows( ).

ENDMETHOD.