*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_POLITICA_COMERCIAL                                    *
* Método   : SET_CHAVE_A963                                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Inserir dados da tabela A963                              *
*            EscrVendas/Cliente/Grupo mat.                             *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.06.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD set_chave_a963.
*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
     t_963 TYPE STANDARD TABLE OF y963.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
     w_963 LIKE LINE OF im_t_963.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_data_inicial TYPE sy-datum         ,
    v_data_final   TYPE sy-datum         ,
    v_cliente      TYPE kna1-kunnr       ,
    v_montante     TYPE bapicurext       ,
    v_varkey       TYPE bapicondct-varkey.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  APPEND LINES OF im_t_963 TO t_963.

  SORT t_963 BY escr_vendas cliente grupo_mat ASCENDING.

* EscrVendas/Cliente/Grupo mat.
  LOOP AT t_963 INTO w_963.
    CLEAR: v_data_inicial, v_data_final, v_montante, v_cliente, v_varkey.

    v_data_inicial = me->converter_data( w_963-data1 ).
    v_data_final   = me->converter_data( w_963-data2 ).
    v_montante     = me->converter_montante( w_963-montante ).
    v_cliente      = me->converter_cliente( w_963-cliente ).

    CONCATENATE w_963-escr_vendas " Escritório de vendas
                v_cliente         " Nº cliente
                w_963-grupo_mat   " Grupo de condições material
           INTO v_varkey
           RESPECTING BLANKS.

    me->set_politica_comercial( im_id_modificacao = w_963-id
                                im_data_inicial   = v_data_inicial
                                im_data_final     = v_data_final
                                im_montante       = v_montante
                                im_tab_condicao   = me->c_963
                                im_varkey         = v_varkey
                                im_cond_pgto      = w_963-cond_pagto
                                im_indice_item    = sy-tabix ).
  ENDLOOP. " t_963 INTO w_963

ENDMETHOD.
