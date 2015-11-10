*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_POLITICA_COMERCIAL                                    *
* Método   : SET_CHAVE_A968                                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Inserir dados da tabela A968                              *
*            EscrVendas/GrpClients/Grupo mat./Material                 *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.06.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD set_chave_a968.
*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_968 TYPE STANDARD TABLE OF y968.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_968 LIKE LINE OF t_968.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_data_inicial TYPE sy-datum         ,
    v_data_final   TYPE sy-datum         ,
    v_material     TYPE mara-matnr       ,
    v_montante     TYPE bapicurext       ,
    v_varkey       TYPE bapicondct-varkey.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  APPEND LINES OF im_t_968 TO t_968.

  SORT t_968 BY escr_vendas grupo_cli grupo_mat material ASCENDING.

* EscrVendas/GrpClients/Grupo mat./Material
  LOOP AT t_968 INTO w_968.
    CLEAR: v_data_inicial, v_data_final, v_montante, v_material, v_varkey.

    v_data_inicial = me->converter_data( w_968-data1 )       .
    v_data_final   = me->converter_data( w_968-data2 )       .
    v_montante     = me->converter_montante( w_968-montante ).
    v_material     = me->converter_material( w_968-material ).

    CONCATENATE w_968-escr_vendas " Escritório de vendas
                w_968-grupo_cli   " Grupo de clientes
                w_968-grupo_mat   " Grupo de materiais
                v_material        " Nro do material
           INTO v_varkey
           RESPECTING BLANKS.

    me->set_politica_comercial( im_id_modificacao = w_968-id
                                im_data_inicial   = v_data_inicial
                                im_data_final     = v_data_final
                                im_montante       = v_montante
                                im_tab_condicao   = me->c_968
                                im_varkey         = v_varkey
                                im_cond_pgto      = w_968-cond_pagto
                                im_indice_item    = sy-tabix ).
  ENDLOOP. " LOOP AT t_968 INTO w_968.

ENDMETHOD.
