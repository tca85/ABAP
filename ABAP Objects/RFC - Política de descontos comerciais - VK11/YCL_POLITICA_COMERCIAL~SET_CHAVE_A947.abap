*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_POLITICA_COMERCIAL                                    *
* Método   : SET_CHAVE_A947                                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Inserir dados da tabela A947                              *
*            EscrVendas/Cliente/Material/Tipo ped.                     *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.06.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD set_chave_a947.
*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_947 TYPE STANDARD TABLE OF y947.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_947 LIKE LINE OF t_947.

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
  APPEND LINES OF im_t_947 TO t_947.

  SORT t_947 BY escr_vendas cliente material tipo_ped ASCENDING.

* EscrVendas/Cliente/Material/Tipo ped.
  LOOP AT t_947 INTO w_947.
    CLEAR: v_data_inicial, v_data_final, v_montante,
           v_cliente, v_material, v_varkey.

    v_data_inicial = me->converter_data( w_947-data1 )       .
    v_data_final   = me->converter_data( w_947-data2 )       .
    v_montante     = me->converter_montante( w_947-montante ).
    v_cliente      = me->converter_cliente( w_947-cliente )  .
    v_material     = me->converter_material( w_947-material ).

    CONCATENATE w_947-escr_vendas " Escritório de vendas
                v_cliente         " Nº cliente
                v_material        " Nº material
                w_947-tipo_ped    " Tipo do pedido
          INTO v_varkey
          RESPECTING BLANKS.

    me->set_politica_comercial( im_id_modificacao = w_947-id
                                im_data_inicial   = v_data_inicial
                                im_data_final     = v_data_final
                                im_montante       = v_montante
                                im_tab_condicao   = me->c_947
                                im_varkey         = v_varkey
                                im_cond_pgto      = w_947-cond_pagto
                                im_indice_item    = sy-tabix ).
  ENDLOOP. " LOOP AT t_947 INTO w_947.

ENDMETHOD.
