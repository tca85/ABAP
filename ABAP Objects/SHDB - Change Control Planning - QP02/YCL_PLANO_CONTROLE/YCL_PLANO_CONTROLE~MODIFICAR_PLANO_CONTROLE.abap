*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* Método   : MODIFICAR_PLANO_CONTROLE                                  *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Modificar plano de controle (batch input da QP02)         *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  21.01.2016  #142490 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD modificar_plano_controle.
*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
     t_bdc_msg      TYPE tab_bdcmsgcoll                   ,
     t_alv_log_qp02 TYPE STANDARD TABLE OF ty_alv_log_qp02.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
     w_bdc_msg                  LIKE LINE OF t_bdc_msg           ,
     w_alv_log_qp02             LIKE LINE OF t_alv_log_qp02      ,
     w_material_qp02            TYPE ty_material_qp02            ,
     w_lista_tarefa_qp02        TYPE ty_lista_tarefas_qp02       ,
     w_operacao_qp02            TYPE ty_operacoes_qp02           ,
     w_caracteristica_ctrl_qp02 TYPE ty_caracteristicas_ctrl_qp02.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
     v_indice_lista_tarefas   TYPE sy-tabix      ,
     v_indice_operacoes       TYPE sy-tabix      ,
     v_indice_caracteristicas TYPE sy-tabix      ,
     v_msg_erro               TYPE string        ,
     v_erro_shdb              TYPE sy-subrc      ,
     v_numero_char            TYPE c LENGTH 16   ,
     v_minbe                  LIKE v_numero_char ,
     v_tabix                  TYPE sy-tabix      ,
     v_ind(3)                 TYPE n             ,
     v_campo(40)              TYPE c             ,
     v_prim_vez               TYPE c             ,
     v_cont_tarefas           TYPE i             .

*----------------------------------------------------------------------*
* Variáveis tipo referência
*----------------------------------------------------------------------*
  DATA:
     o_bdc TYPE REF TO ycl_bdc.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  me->parse_excel_qp02( im_nome_arquivo ).

  LOOP AT me->t_materiais_qp02 INTO w_material_qp02.

    READ TABLE me->t_lista_tarefas_qp02
    TRANSPORTING NO FIELDS
    WITH KEY matnr = w_material_qp02-matnr
             werks = w_material_qp02-werks.

    IF sy-subrc = 0.
      v_indice_lista_tarefas = sy-tabix.

*     Batch input para modificar o plano de controle (QP02)
      o_bdc = ycl_bdc=>s_instantiate( im_bdc_mode = im_opcao_batch
                                      im_bdc_type = 'CT'
                                      im_tcode    = 'QP02' ).

*     Modificar plano de controle - 1ª tela
      o_bdc->add_screen( im_repid = 'SAPLCPDI'     im_dynnr = '8010'                ).
      o_bdc->add_field( im_fld    = 'RC27M-MATNR'  im_val   = w_material_qp02-matnr ). " Material
      o_bdc->add_field( im_fld    = 'RC27M-WERKS'  im_val   = w_material_qp02-werks ). " Centro
      o_bdc->add_field( im_fld    = 'BDC_OKCODE'   im_val   = '/00'                 ).
    ELSE.
      CONTINUE.
    ENDIF.

    CLEAR v_cont_tarefas.

    LOOP AT me->t_lista_tarefas_qp02 INTO w_lista_tarefa_qp02 FROM v_indice_lista_tarefas.

*     Salvar o ponteiro
      v_tabix = sy-tabix.
      ADD 1 TO v_cont_tarefas.

      IF w_lista_tarefa_qp02-matnr <> w_material_qp02-matnr
         OR w_lista_tarefa_qp02-werks <> w_material_qp02-werks.
        EXIT.
      ENDIF.

*     Antes de processar uma nova tarefa, a tarefa anterior deve ser finalizad
*      IF sy-tabix > 1.
      IF v_cont_tarefas > 1.
**     Plano de controle Modif.: Síntese da lista de tarefas
        o_bdc->add_screen( im_repid = 'SAPLCPDI'        im_dynnr = '1200'                      ).
        o_bdc->add_field( im_fld    = 'BDC_OKCODE'      im_val   = '=MALO'                      ). " --> Desmarcar tudo

        o_bdc->add_screen( im_repid = 'SAPLCPDI'        im_dynnr = '1200'                      ).
        o_bdc->add_field( im_fld    = 'RC27X-ENTRY_ACT' im_val   = w_lista_tarefa_qp02-plnal   ). " Entrada
        o_bdc->add_field( im_fld    = 'BDC_OKCODE'      im_val   = '=MALO'                      ). " --> Desmarcar tudo
      ENDIF.

*     Plano de controle Modif.: Síntese da lista de tarefas
      o_bdc->add_screen( im_repid = 'SAPLCPDI'          im_dynnr = '1200'                      ).
      o_bdc->add_field( im_fld    = 'RC27X-ENTRY_ACT'   im_val   = w_lista_tarefa_qp02-plnal   ). " Entrada
      o_bdc->add_field( im_fld    = 'RC27X-FLG_SEL(01)' im_val   = abap_true                   ). " Seleciona o nro de grupo
      o_bdc->add_field( im_fld    = 'BDC_OKCODE'        im_val   = '/00'                       ). " --> informa nro do grupo

*     Plano de controle Modif.: Síntese da lista de tarefas
      o_bdc->add_screen( im_repid = 'SAPLCPDI'        im_dynnr = '1200'                        ).
      o_bdc->add_field( im_fld    = 'RC27X-ENTRY_ACT' im_val   = w_lista_tarefa_qp02-plnal     ). " Entrada
      o_bdc->add_field( im_fld    = 'BDC_OKCODE'      im_val   = '=ALD1'                       ). " --> ir para o cabeçalho

*     A partir da 3a. linha somente o status será modificado para Z1 (BLOQUEADO).
*      IF v_tabix > 2.
      IF v_cont_tarefas > 2.
*     Modificar Plano de controle: detalhe do cabeçalho
        o_bdc->add_screen( im_repid = 'SAPLCPDA'        im_dynnr = '1200'                        ).
        o_bdc->add_field( im_fld    = 'PLKOD-STATU'     im_val   = w_lista_tarefa_qp02-statu     ). " Status do Plano
        o_bdc->add_field( im_fld    = 'BDC_OKCODE'      im_val   = '=BACK'                       ). " Voltar
        CONTINUE.
      ENDIF.

*     Modificar Plano de controle: detalhe do cabeçalho
      o_bdc->add_screen( im_repid = 'SAPLCPDA'        im_dynnr = '1200'                        ).
      o_bdc->add_field( im_fld    = 'PLKOD-QDYNHEAD'  im_val   = w_lista_tarefa_qp02-qdynhead  ). " Entrada
      o_bdc->add_field( im_fld    = 'PLKOD-QDYNREGEL' im_val   = w_lista_tarefa_qp02-qdynregel ). " Regra de controle dinâmico
      o_bdc->add_field( im_fld    = 'BDC_OKCODE'      im_val   = '=VOUE'                       ). " --> vai para "Operações"

      READ TABLE me->t_operacoes_qp02
      TRANSPORTING NO FIELDS
      WITH KEY matnr = w_lista_tarefa_qp02-matnr
               werks = w_lista_tarefa_qp02-werks
               plnal = w_lista_tarefa_qp02-plnal.

      IF sy-subrc = 0.
        v_indice_operacoes = sy-tabix.
      ELSE.
        CONTINUE.
      ENDIF.

      LOOP AT me->t_operacoes_qp02 INTO w_operacao_qp02 FROM v_indice_operacoes.
        IF w_operacao_qp02-matnr <> w_lista_tarefa_qp02-matnr     " Material
          OR w_operacao_qp02-werks <> w_lista_tarefa_qp02-werks  " Centro
          OR w_operacao_qp02-plnal <> w_lista_tarefa_qp02-plnal. " Numerador de grupos
          EXIT.
        ENDIF.

*       Limpar a linha marcada pelo processamento da operação anterior.
        IF sy-tabix > 1.
*       Plano de controle Modif.: síntese de operações
          o_bdc->add_screen( im_repid = 'SAPLCPDI'      im_dynnr = '1400'                ).
          o_bdc->add_field( im_fld     = 'BDC_OKCODE'   im_val   = 'MALO'                ). " --> Desmarcar tudo
        ENDIF.

*       Plano de controle Modif.: síntese de operações
        o_bdc->add_screen( im_repid = 'SAPLCPDI'        im_dynnr = '1400'                ).
        o_bdc->add_field( im_fld    = 'BDC_OKCODE'      im_val   = 'OSEA'                ). " --> pesquisar

*       Procurar operações / suboperações
        o_bdc->add_screen( im_repid = 'SAPLCP02'        im_dynnr = '1010'                ).
        o_bdc->add_field( im_fld    = 'RC27H-VORNR'     im_val   = w_operacao_qp02-vornr ). " Nº da operação
        o_bdc->add_field( im_fld    = 'BDC_OKCODE'      im_val   = '/00'                 ). " OK

*       Plano de controle Modif.: síntese de operações
        o_bdc->add_screen( im_repid = 'SAPLCPDI'        im_dynnr = '1400'                ).
        o_bdc->add_field( im_fld    = 'RC27X-FLG_SEL(01)' im_val   = abap_true           ). " Seleciona a linha da operação
        o_bdc->add_field( im_fld    = 'BDC_OKCODE'      im_val   = '/00'                 ). " --> seleciona a linha

*       Plano de controle Modif.: síntese de operações
        o_bdc->add_screen( im_repid = 'SAPLCPDI'        im_dynnr = '1400'                ).
        o_bdc->add_field( im_fld    = 'BDC_OKCODE'      im_val   = '=QMUE'               ). " --> vai para "Característica de controle"

*       Características de controle da operação
        READ TABLE me->t_caracteristicas_ctrl_qp02
        TRANSPORTING NO FIELDS
        WITH KEY matnr = w_operacao_qp02-matnr
                 werks = w_operacao_qp02-werks
                 plnal = w_operacao_qp02-plnal
                 vornr = w_operacao_qp02-vornr.

        IF sy-subrc = 0.
          v_indice_caracteristicas = sy-tabix.
        ELSE.
          CONTINUE.
        ENDIF.

*       Inicializar a flag e o índexador
        v_prim_vez = abap_true.
        CLEAR v_ind.

        LOOP AT me->t_caracteristicas_ctrl_qp02 INTO w_caracteristica_ctrl_qp02 FROM v_indice_caracteristicas.
          IF   w_caracteristica_ctrl_qp02-matnr <> w_operacao_qp02-matnr  " Material
            OR w_caracteristica_ctrl_qp02-werks <> w_operacao_qp02-werks  " Centro
            OR w_caracteristica_ctrl_qp02-plnal <> w_operacao_qp02-plnal  " Numerador de grupos
            OR w_caracteristica_ctrl_qp02-vornr <> w_operacao_qp02-vornr. " Nº operação
            EXIT.
          ENDIF.

          w_caracteristica_ctrl_qp02-merknr = w_caracteristica_ctrl_qp02-merknr / 10.
          ADD 1 TO v_ind.

*         Montar a tela somente uma vez.
          IF v_prim_vez IS NOT INITIAL.
*         Modificar Plano de controle: síntese de características
            o_bdc->add_screen( im_repid = 'SAPLQPAA'        im_dynnr = '0150'                            ).
            CLEAR v_prim_vez.
          ENDIF.
*          o_bdc->add_field( im_fld    = 'RQPAS-ENTRY_ACT' im_val   = w_caracteristica_ctrl_qp02-merknr ). " Nro da característica
          CONCATENATE 'PLMKB-QDYNREGEL(' v_ind  ')' INTO v_campo.
          o_bdc->add_field( im_fld    = v_campo           im_val  = w_caracteristica_ctrl_qp02-qdynregel                      ). " Regra ctrl.dinâmico

          IF w_caracteristica_ctrl_qp02-toleranzun IS NOT INITIAL.
            CONCATENATE 'QFLTP-TOLERANZUN(' v_ind  ')' INTO v_campo.
            o_bdc->add_field( im_fld    = v_campo          im_val  = w_caracteristica_ctrl_qp02-toleranzun ). " Valor limite inferior
          ENDIF.
          IF w_caracteristica_ctrl_qp02-toleranzob IS NOT INITIAL.
            CONCATENATE 'QFLTP-TOLERANZOB(' v_ind  ')' INTO v_campo.
            o_bdc->add_field( im_fld    = v_campo           im_val  = w_caracteristica_ctrl_qp02-toleranzob ). " Valor limite superior
          ENDIF.
          IF w_caracteristica_ctrl_qp02-masseinhsw IS NOT INITIAL.
            CONCATENATE 'RQPAS-MASSEINHSW(' v_ind  ')' INTO v_campo.
            o_bdc->add_field( im_fld    = v_campo           im_val  = w_caracteristica_ctrl_qp02-masseinhsw ). " Unidade de medida
          ENDIF.

*          o_bdc->add_field( im_fld    = 'BDC_OKCODE'      im_val   = '/00'                             ). " --> posiciona na linha

*         Modificar Plano de controle: síntese de características
*          o_bdc->add_screen( im_repid = 'SAPLQPAA'        im_dynnr = '0150'                            ).
*          o_bdc->add_field( im_fld    = 'RQPAS-SEL_FLG(01)' im_val = abap_true                         ). " Seleciona a linha
*          o_bdc->add_field( im_fld    = 'BDC_OKCODE'      im_val   = '=QMNM'                           ). " --> botão Dds.quant


*** qualitativo: altera a aba   Amostra
*** quantitativo altera as abas Amostra e Dds.quantitativos

*** começar batch input direto pela aba amostras


**         Modificar Plano de controle: dados de característica quantitativos
*          o_bdc->add_screen( im_repid = 'SAPLQPAA'   im_dynnr     = '0160'                                                    ).
*          o_bdc->add_field( im_fld    = 'BDC_SUBSCR' im_val       = 'SAPLQPAA                                0154SC_PLMK_DET' ). " aba 'Amostra'
*          o_bdc->add_field( im_fld    = 'PLMKB-QDYNREGEL' im_val  = w_caracteristica_ctrl_qp02-qdynregel                      ). " Regra ctrl.dinâmico
*          o_bdc->add_field( im_fld    = 'BDC_OKCODE' im_val       = '=QMBW'                                                   ). " --> volta para a síntese de características

        ENDLOOP. " características de controle da operação

        o_bdc->add_field( im_fld    = 'BDC_OKCODE' im_val       = '=QMBW'                                                   ). " --> volta para a síntese de características

      ENDLOOP. " operações da lista de tarefas

*     Plano de controle Modif.: síntese de operações
      o_bdc->add_screen( im_repid = 'SAPLCPDI'        im_dynnr = '1400'                ).
      o_bdc->add_field( im_fld    = 'BDC_OKCODE'      im_val   = '=BACK'                           ). " --> botão Voltar

*     Detalhe o cabaeçalho
      o_bdc->add_screen( im_repid = 'SAPLCPDA'        im_dynnr = '1200'                ).
      o_bdc->add_field( im_fld    = 'BDC_OKCODE'      im_val   = '=BACK'                           ). " --> botão Voltar

    ENDLOOP. " lista de tarefas

*   Ao término do processamento da última tarefa, salvar.
    o_bdc->add_field( im_fld    = 'BDC_OKCODE'      im_val   = '=BU'                           ). " --> botão Voltar

    FREE t_bdc_msg.

    o_bdc->process( IMPORTING ex_subrc    = v_erro_shdb
                              ex_messages = t_bdc_msg ).
    o_bdc->clear_bdc_data( ).

    o_bdc->s_free_instance( ).
break flalex.
    FREE o_bdc.

*    IF v_erro_shdb IS NOT INITIAL.
*     Retorna a mensagem de erro do Batch Input
    LOOP AT t_bdc_msg INTO w_bdc_msg WHERE msgtyp <> 'W'.
      CLEAR: w_alv_log_qp02                    .
      w_alv_log_qp02-matnr = w_material_qp02-matnr.

      MESSAGE ID w_bdc_msg-msgid
            TYPE w_bdc_msg-msgtyp
          NUMBER w_bdc_msg-msgnr
            WITH w_bdc_msg-msgv1
                 w_bdc_msg-msgv2
                 w_bdc_msg-msgv3
                 w_bdc_msg-msgv4
            INTO w_alv_log_qp02-msg_erro.

*       Dados de batch input para tela & não existentes
      IF w_bdc_msg-msgid = '00' AND w_bdc_msg-msgnr = '344'.

      ENDIF.

      APPEND w_alv_log_qp02 TO t_alv_log_qp02.
    ENDLOOP.
*    ENDIF.

  ENDLOOP. " materiais

  IF t_alv_log_qp02 IS NOT INITIAL.
    APPEND LINES OF t_alv_log_qp02 TO me->t_alv_log_qp02.
  ENDIF.

ENDMETHOD.
