*----------------------------------------------------------------------*
* Classe   : YCL_PLANO_CONTROLE                                        *
* Método   : EXIBIR_ALV_LOG_QP02                                       *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Exibe o relatório ALV dos logs do batch input da QP02     *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.01.2016  #142490 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD exibir_alv_log_qp02.
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

  IF me->t_alv_log_qp02 IS INITIAL.
    RETURN.
  ENDIF.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = o_salv_table
                              CHANGING t_table       = me->t_alv_log_qp02 ).

    CATCH cx_salv_msg INTO o_salv_msg.
      v_msg_erro = o_salv_msg->get_text( ).
      MESSAGE v_msg_erro TYPE 'S' DISPLAY LIKE 'E'.
  ENDTRY.

  o_salv_columns = o_salv_table->get_columns( ).
  o_salv_columns->set_optimize( abap_true ).

  o_salv_functions_list = o_salv_table->get_functions( ).
  o_salv_functions_list->set_all( abap_true ).

  o_salv_selections = o_salv_table->get_selections( ).
  o_salv_selections->set_selection_mode( if_salv_c_selection_mode=>cell ).

  o_salv_table->display( ).

ENDMETHOD.
