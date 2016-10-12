*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_POLITICA_COMERCIAL                                    *
* Método   : SET_CHAVE_A960                                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Inserir dados da tabela A960                              *
*            EscrVendas/Cliente/Material                               *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.06.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD set_chave_a960.
*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_960 TYPE STANDARD TABLE OF y960.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_960 LIKE LINE OF t_960.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_data_inicial TYPE sy-datum         ,
    v_data_final   TYPE sy-datum         ,
    v_cliente      TYPE kna1-kunnr       ,
    v_material     TYPE mara-matnr       ,
    v_varkey       TYPE bapicondct-varkey,
    v_montante     TYPE bapicurext       .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  APPEND LINES OF im_t_960 TO t_960.

  SORT t_960 BY escr_vendas cliente material ASCENDING.

* EscrVendas/Cliente/Material/Tipo ped.
  LOOP AT t_960 INTO w_960.
    CLEAR: v_data_inicial, v_data_final, v_montante,
           v_material, v_varkey.

    v_data_inicial = me->converter_data( w_960-data1 )       .
    v_data_final   = me->converter_data( w_960-data2 )       .
    v_montante     = me->converter_montante( w_960-montante ).
    v_cliente      = me->converter_cliente( w_960-cliente )  .
    v_material     = me->converter_material( w_960-material ).

    CONCATENATE w_960-escr_vendas " Escritório de vendas
                v_cliente         " Nº cliente
                v_material        " Nº material
           INTO v_varkey
           RESPECTING BLANKS.

    me->set_politica_comercial( im_id_modificacao = w_960-id
                                im_data_inicial   = v_data_inicial
                                im_data_final     = v_data_final
                                im_montante       = v_montante
                                im_tab_condicao   = me->c_960
                                im_varkey         = v_varkey
                                im_cond_pgto      = w_960-cond_pagto
                                im_indice_item    = sy-tabix ).

  ENDLOOP. " LOOP AT t_960 INTO w_960.

ENDMETHOD.
