*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_POLITICA_COMERCIAL                                    *
* Método   : SET_CHAVE_A969                                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Inserir dados da tabela A969                              *
*            EscrVendas/Região/Grupo mat.                              *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.06.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD set_chave_a969.
*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_969 TYPE STANDARD TABLE OF y969.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_969 LIKE LINE OF t_969.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_data_inicial TYPE sy-datum         ,
    v_data_final   TYPE sy-datum         ,
    v_montante     TYPE bapicurext       ,
    v_varkey       TYPE bapicondct-varkey.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  APPEND LINES OF im_t_969 TO t_969.

  SORT t_969 BY escr_vendas regiao grupo_mat ASCENDING.

* EscrVendas/Região/Grupo mat.
  LOOP AT t_969 INTO w_969.
    CLEAR: v_data_inicial, v_data_final, v_montante, v_varkey.

    v_data_inicial = me->converter_data( w_969-data1 )       .
    v_data_final   = me->converter_data( w_969-data2 )       .
    v_montante     = me->converter_montante( w_969-montante ).

    CONCATENATE w_969-escr_vendas " Escritório de vendas
                w_969-regiao      " Região
                w_969-grupo_mat   " Grupo de materiais
           INTO v_varkey
           RESPECTING BLANKS.

    me->set_politica_comercial( im_id_modificacao = w_969-id
                                im_data_inicial   = v_data_inicial
                                im_data_final     = v_data_final
                                im_montante       = v_montante
                                im_tab_condicao   = me->c_969
                                im_varkey         = v_varkey
                                im_cond_pgto      = w_969-cond_pagto
                                im_indice_item    = sy-tabix ).
  ENDLOOP. " LOOP AT t_969 INTO w_969.

ENDMETHOD.
