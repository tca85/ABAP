*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_POLITICA_COMERCIAL                                    *
* Método   : SET_CHAVE_A961                                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Inserir dados da tabela A961                              *
*            EscrVendas/GrpClients/Grupo mat.                          *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.06.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD set_chave_a961.
*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_961 TYPE STANDARD TABLE OF y961.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_961 LIKE LINE OF t_961.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_data_inicial TYPE sy-datum         ,
    v_data_final   TYPE sy-datum         ,
    v_varkey       TYPE bapicondct-varkey,
    v_montante     TYPE bapicurext       .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  APPEND LINES OF im_t_961 TO t_961.

  SORT t_961 BY escr_vendas grupo_cli grupo_mat ASCENDING.

* EscrVendas/GrpClients/Grupo mat.
  LOOP AT t_961 INTO w_961.
    CLEAR: v_data_inicial, v_data_final, v_montante, v_varkey.

    v_data_inicial = me->converter_data( w_961-data1 )       .
    v_data_final   = me->converter_data( w_961-data2 )       .
    v_montante     = me->converter_montante( w_961-montante ).

    CONCATENATE w_961-escr_vendas " Escritório de vendas
                w_961-grupo_cli   " Grupo de clientes
                w_961-grupo_mat   " Grupo de materiais
           INTO v_varkey
           RESPECTING BLANKS.

    me->set_politica_comercial( im_id_modificacao = w_961-id
                                im_data_inicial   = v_data_inicial
                                im_data_final     = v_data_final
                                im_montante       = v_montante
                                im_tab_condicao   = me->c_961
                                im_varkey         = v_varkey
                                im_cond_pgto      = w_961-cond_pagto
                                im_indice_item    = sy-tabix ).
  ENDLOOP. " LOOP AT t_961 INTO w_961.

ENDMETHOD.
