*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                   *
*----------------------------------------------------------------------*
* Classe   : YCL_POLITICA_COMERCIAL                                    *
* Método   : SET_CHAVE_A972                                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Inserir dados da tabela A972                              *
*            EscrVendas/Região/Material                                *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.06.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD set_chave_a972.
*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
     t_972 TYPE STANDARD TABLE OF y972.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
     w_972 LIKE LINE OF t_972.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
     v_data_inicial TYPE sy-datum         ,
     v_data_final   TYPE sy-datum         ,
     v_material     TYPE mara-matnr       ,
     v_varkey       TYPE bapicondct-varkey,
     v_montante     TYPE bapicurext       .
*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  APPEND LINES OF im_t_972 TO t_972.

  SORT t_972 BY escr_vendas regiao material ASCENDING.

* EscrVendas/Região/Material
  LOOP AT t_972 INTO w_972.
    CLEAR: v_data_inicial, v_data_final, v_montante, v_material.

    v_data_inicial = me->converter_data( w_972-data1 )       .
    v_data_final   = me->converter_data( w_972-data2 )       .
    v_montante     = me->converter_montante( w_972-montante ).
    v_material     = me->converter_material( w_972-material ).

    CONCATENATE w_972-escr_vendas " Escritório de vendas
                w_972-regiao      " Região
                v_material        " Nro do material
           INTO v_varkey
           RESPECTING BLANKS.

    me->set_politica_comercial( im_id_modificacao = w_972-id
                                im_data_inicial   = v_data_inicial
                                im_data_final     = v_data_final
                                im_montante       = v_montante
                                im_tab_condicao   = me->c_972
                                im_varkey         = v_varkey
                                im_cond_pgto      = w_972-cond_pagto
                                im_indice_item    = sy-tabix ).

  ENDLOOP. " LOOP AT t_972 INTO w_972.

ENDMETHOD.
