*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_POLITICA_COMERCIAL                                    *
* Método   : SET_CHAVE_A946                                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Inserir dados da tabela A946                              *
*            EscrVendas/Cliente/Material/Lote/Tipo ped.                *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.06.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD set_chave_a946.
*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_946 TYPE STANDARD TABLE OF y946.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_946 LIKE LINE OF t_946.

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
  APPEND LINES OF im_t_946 TO t_946.

  SORT t_946 BY escr_vendas cliente material lote tipo_ped ASCENDING.

* EscrVendas/Cliente/Material/Lote/Tipo ped.
  LOOP AT t_946 INTO w_946.
    CLEAR: v_data_inicial, v_data_final, v_montante,
           v_cliente, v_material, v_varkey.

    v_data_inicial = me->converter_data( w_946-data1 )       .
    v_data_final   = me->converter_data( w_946-data2 )       .
    v_montante     = me->converter_montante( w_946-montante ).
    v_cliente      = me->converter_cliente( w_946-cliente )  .
    v_material     = me->converter_material( w_946-material ).

    CONCATENATE w_946-escr_vendas " Escritório de vendas
                v_cliente         " Nº cliente
                v_material        " Nº material
                w_946-lote        " Nº do lote
                w_946-tipo_ped    " Tipo do pedido
           INTO v_varkey
           RESPECTING BLANKS.

    me->set_politica_comercial( im_id_modificacao = w_946-id
                                im_data_inicial   = v_data_inicial
                                im_data_final     = v_data_final
                                im_montante       = v_montante
                                im_tab_condicao   = me->c_946
                                im_varkey         = v_varkey
                                im_cond_pgto      = w_946-cond_pagto
                                im_indice_item    = sy-tabix ).
  ENDLOOP. " LOOP AT t_946 INTO w_946.

ENDMETHOD.
