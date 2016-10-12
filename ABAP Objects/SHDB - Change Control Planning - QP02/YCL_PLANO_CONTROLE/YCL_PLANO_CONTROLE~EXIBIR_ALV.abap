*----------------------------------------------------------------------*
* Classe   : YCL_PLANO_CONTROLE                                        *
* Método   : EXIBIR_ALV                                                *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Exibe o relatório ALV                                     *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.07.2015  #111437 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD exibir_alv.
*----------------------------------------------------------------------*
* Objetos
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
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
     w_msg_erro   TYPE bal_s_msg        ,
     w_layout_key TYPE salv_s_layout_key.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
     v_msg_erro TYPE string.

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
  CONSTANTS:
     c_variante_default TYPE slis_vari   VALUE 'DEFAULT'.


*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  IF t_alv IS INITIAL.
    EXIT.
  ENDIF.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = o_salv_table
                               CHANGING t_table      = t_alv ).

    CATCH cx_salv_msg INTO o_cx_salv_msg.
      w_msg_erro = o_cx_salv_msg->get_message( ).
  ENDTRY.

*   Exibe todos os botões da PF-Status
  o_salv_functions = o_salv_table->get_functions( ).
  o_salv_functions->set_all( abap_true )          .

* Permite que o usuário salve uma variante do layout
  o_cl_salv_layout = o_salv_table->get_layout( ).

  w_layout_key-report = sy-repid.

  o_cl_salv_layout->set_key( w_layout_key )                                .
  o_cl_salv_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
  o_cl_salv_layout->set_default( abap_true )                               .
  o_cl_salv_layout->set_initial_layout( c_variante_default )               .

  o_salv_sorts = o_salv_table->get_sorts( ).

  TRY.
      o_salv_sorts->add_sort( columnname = 'PLNNR'
                              subtotal   = if_salv_c_bool_sap=>true ).

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

    RAISE EXCEPTION TYPE ycx_plano_controle EXPORTING msg = v_msg_erro.
  ENDIF.

  o_salv_table->display( ).

ENDMETHOD.
