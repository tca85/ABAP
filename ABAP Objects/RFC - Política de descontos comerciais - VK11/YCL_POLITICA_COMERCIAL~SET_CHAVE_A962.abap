*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_POLITICA_COMERCIAL                                    *
* Método   : SET_CHAVE_A962                                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Inserir dados da tabela A962                              *
*            EscrVendas/Material                                       *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.06.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD set_chave_a962.
*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_962 TYPE STANDARD TABLE OF y962.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_962 LIKE LINE OF t_962.

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
  APPEND LINES OF im_t_962 TO t_962.

  SORT t_962 BY escr_vendas material ASCENDING.

* EscrVendas/Material
  LOOP AT t_962 INTO w_962.
    CLEAR: v_data_inicial, v_data_final, v_montante, v_material, v_varkey.

    v_data_inicial = me->converter_data( w_962-data1 )       .
    v_data_final   = me->converter_data( w_962-data2 )       .
    v_montante     = me->converter_montante( w_962-montante ).
    v_material     = me->converter_material( w_962-material ).

    CONCATENATE w_962-escr_vendas  " Escritório de vendas
                v_material         " Nro do material
           INTO v_varkey
           RESPECTING BLANKS.

    me->set_politica_comercial( im_id_modificacao = w_962-id
                                im_data_inicial   = v_data_inicial
                                im_data_final     = v_data_final
                                im_montante       = v_montante
                                im_tab_condicao   = me->c_962
                                im_varkey         = v_varkey
                                im_cond_pgto      = w_962-cond_pagto
                                im_indice_item    = sy-tabix ).
  ENDLOOP. " LOOP AT t_962 INTO w_962.

ENDMETHOD.
