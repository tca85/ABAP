*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                     *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : SET_OPERACOES_ORDEM_PROCESSO                              *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Preenche as operações das fases e status da o.p - COR3    *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_ORDEM_PROCESSO  TYPE AFKO-AUFNR OPTIONAL

METHOD set_operacoes_ordem_processo.
*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
  TYPES:
    BEGIN OF ty_menor_fase ,
      aufnr TYPE afru-aufnr, " Nº ordem
      vornr TYPE afru-vornr, " Nº operação
    END OF ty_menor_fase   ,

    BEGIN OF ty_afru       ,
      aufnr TYPE afru-aufnr, " Nº ordem
      aufpl TYPE afru-aufpl, " Seqüência
      rueck TYPE afru-rueck, " Nº confirmação da operação
      vornr TYPE afru-vornr, " Nº operação
      rmzhl TYPE afru-rmzhl, " Numerador da confirmação
      ism01 TYPE afru-ism01, " APO tp. preparação
      ism02 TYPE afru-ism02, " APO tp.maquina
      ism03 TYPE afru-ism03, " Custo HH preparação
      ism04 TYPE afru-ism04, " Custo HH máquina
      lmnga TYPE afru-lmnga, " Qtd.boa a ser confirmada atualmente
      xmnga TYPE afru-xmnga, " Refugo a ser confirmado neste momento
      smeng TYPE afru-smeng, " Quantidade operação
      aueru TYPE afru-aueru, " Confirmação parcial/final
    END OF ty_afru         .

*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_afru           TYPE STANDARD TABLE OF ty_afru          ,
    t_fase           TYPE STANDARD TABLE OF bapi_order_phase ,
    t_menor_fase     TYPE STANDARD TABLE OF ty_menor_fase    ,
    t_operacao       TYPE STANDARD TABLE OF ty_operacao_op   ,
    t_total_operacao TYPE STANDARD TABLE OF ty_total_operacao.

*----------------------------------------------------------------------*
* Work Areas
*----------------------------------------------------------------------*
  DATA:
    w_caufv          TYPE ty_caufv                , " Visão dos cabeçalhos de ordens PCP/RK
    w_afru           LIKE LINE OF t_afru          , " Confirmações de ordens
    w_menor_fase     LIKE LINE OF t_menor_fase    ,
    w_operacao       LIKE LINE OF t_operacao      ,
    w_total_operacao LIKE LINE OF t_total_operacao,
    w_opcao_selecao  TYPE bapi_pi_order_objects   ,
    w_retorno_bapi   TYPE bapiret2                ,         "#EC NEEDED
    w_fase           LIKE LINE OF t_fase          .

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_hr_apo             TYPE p DECIMALS 2               ,
    v_hr_hh              TYPE p DECIMALS 2               ,
    v_hr_apo_txt         TYPE ty_operacao_op-hr_apo      ,
    v_hr_hh_txt          TYPE ty_operacao_op-hr_hh       ,
    v_quantidade_boa     TYPE ty_operacao_op-qtd_boa     ,
    v_nro_ordem_processo TYPE bapi_order_key-order_number,
    v_indice             TYPE sy-tabix                   ,
    v_msg_erro           TYPE string                     .

*----------------------------------------------------------------------*
* Objetos
*----------------------------------------------------------------------*
  DATA:
    o_cx_apo TYPE REF TO ycx_apo.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  IF im_ordem_processo IS INITIAL.
*   Informe a ordem de processo
    MESSAGE e007(yapo) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDIF.

* Visão dos cabeçalhos de ordens PCP/RK
  SELECT SINGLE aufnr aufpl bukrs werks
                gsber auart gamng gmein igmng
   FROM caufv
   INTO w_caufv
    WHERE aufnr = im_ordem_processo
      AND autyp = me->c_ordem_processo.

  IF w_caufv IS INITIAL.
*   Ordem de processo não encontrada
    MESSAGE e001(yapo) WITH im_ordem_processo INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDIF.

* Confirmações de ordens
  SELECT aufnr aufpl rueck vornr rmzhl
         ism01 ism02 ism03 ism04 lmnga
         xmnga smeng aueru
   FROM afru
   INTO TABLE t_afru
   WHERE aufnr = w_caufv-aufnr
     AND stokz = space        " Código 'documento foi estornado'
     AND stzhl = '00000000'.  " Numerador de confirmação da confirmação estornada "#EC NOTEXT

  v_nro_ordem_processo   = w_caufv-aufnr.
  w_opcao_selecao-phases = abap_true    .

* Obtém a lista de operações da COR3
  CALL FUNCTION 'BAPI_PROCORD_GET_DETAIL'
    EXPORTING
      number        = v_nro_ordem_processo
      order_objects = w_opcao_selecao
    IMPORTING
      return        = w_retorno_bapi
    TABLES
      phase         = t_fase.

  SORT t_fase BY superior_operation ASCENDING.
  DELETE t_fase WHERE superior_operation IS INITIAL.

  SORT t_fase BY control_recipe_destination ASCENDING.
  DELETE t_fase WHERE control_recipe_destination <> me->c_folha_pi.

  IF t_fase IS INITIAL.
*   Não foram encontradas operações
    MESSAGE e009(yapo) WITH im_ordem_processo INTO v_msg_erro. "#EC *
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDIF.

  SORT t_fase BY operation_number ASCENDING.

  CLEAR w_fase.
  READ TABLE t_fase
  INTO w_fase
  INDEX 1.

* Salva o número da menor fase/operação que ainda não foi apontada
  IF sy-subrc = 0.
    w_menor_fase-aufnr = w_caufv-aufnr          .
    w_menor_fase-vornr = w_fase-operation_number.
    APPEND w_menor_fase TO t_menor_fase         .
  ENDIF.

  SORT:
     t_fase BY routing_no operation_number DESCENDING,
     t_afru BY aufnr aufpl vornr           DESCENDING.

* Operação da ordem
  LOOP AT t_fase INTO w_fase.
    CLEAR: v_indice, w_operacao, w_total_operacao.

*   Confirmações de ordens
    READ TABLE t_afru
    TRANSPORTING NO FIELDS
    WITH KEY aufnr = w_caufv-aufnr
             aufpl = w_fase-routing_no
             vornr = w_fase-operation_number.

    IF sy-subrc = 0.
      v_indice = sy-tabix.

      LOOP AT t_afru INTO w_afru FROM v_indice.
        IF w_afru-vornr <> w_fase-operation_number.
          EXIT.
        ENDIF.

        CLEAR: w_operacao, v_hr_apo, v_hr_hh,
               v_hr_apo_txt, v_hr_hh_txt, v_quantidade_boa.

        CALL FUNCTION 'YNQM_CONVERT_FIRSTCHAR_TOUPPER'
          EXPORTING
            input_string  = w_fase-description
          IMPORTING
            output_string = w_operacao-fase.

*       Apontamento final realizado
        IF w_afru-aueru = abap_true.
          w_operacao-status_apto = c_apto_total.
        ELSE.
          w_operacao-status_apto = c_apto_parcial.
        ENDIF.

*       Horas APO = APO tp. preparação + APO tp.maquina
        v_hr_apo = w_afru-ism01 + w_afru-ism02.

        WRITE v_hr_apo TO v_hr_apo_txt                .
        SHIFT v_hr_apo_txt RIGHT DELETING TRAILING '.'.
        CONDENSE v_hr_apo_txt NO-GAPS                 .

*       Horas HH = Custo HH preparação + Custo HH máquina
        v_hr_hh = w_afru-ism03 + w_afru-ism04.

        WRITE v_hr_hh TO v_hr_hh_txt                 .
        SHIFT v_hr_hh_txt RIGHT DELETING TRAILING '.'.
        CONDENSE v_hr_hh_txt NO-GAPS                 .

        WRITE w_afru-lmnga TO v_quantidade_boa            . "#EC UOM_IN_MES
        SHIFT v_quantidade_boa RIGHT DELETING TRAILING '.'.
        CONDENSE v_quantidade_boa NO-GAPS                 .

        w_operacao-ordem_processo = w_afru-aufnr            . " Ordem de processo
        w_operacao-centro         = w_fase-prod_plant       . " Centro
        w_operacao-operacao       = w_afru-vornr            . " Fase
        w_operacao-confirmacao    = w_afru-rmzhl            . " Contador (Apontamento T-code CORT)
        w_operacao-recurso        = w_fase-resource         . " Recurso
*        w_operacao-hr_apo         = v_hr_apo_txt            . " Horas APO
        w_operacao-hr_apo         = w_afru-ism03            . " Horas APO
        w_operacao-hr_hh          = v_hr_hh_txt             . " Horas HH
        w_operacao-qtd_boa        = v_quantidade_boa        . " Quantidade boa
        APPEND w_operacao TO t_operacao                     .

        w_total_operacao-ordem_processo = w_afru-aufnr      . " Ordem de processo
        w_total_operacao-centro         = w_fase-prod_plant . " Centro
        w_total_operacao-operacao       = w_afru-vornr      . " Operação
        w_total_operacao-fase           = w_operacao-fase   . " Fase
        w_total_operacao-recurso        = w_operacao-recurso. " Recurso
        w_total_operacao-hr_apo_tp_prep = w_afru-ism01      . " APO Tp. preparação
        w_total_operacao-hr_apo_tp_maq  = w_afru-ism02      . " APO Tp. maquina
        w_total_operacao-hr_hh_tp_prep  = w_afru-ism03      . " Custo HH Tp. preparação
        w_total_operacao-hr_hh_tp_maq   = w_afru-ism04      . " Custo HH Tp. maquina
        w_total_operacao-qtd_apontada   = w_afru-lmnga      . " Quantidade boa
        w_total_operacao-refugo         = w_afru-xmnga      . " Refugo
        COLLECT w_total_operacao INTO t_total_operacao      .
      ENDLOOP.

*----------------------------------------------------------------------*
*   Não possui ainda nenhuma confirmação de apontamento para a fase
*----------------------------------------------------------------------*
    ELSE.
      CLEAR: w_operacao, w_total_operacao.

*     Obtém o número da menor fase/operação que ainda não foi apontada
      CLEAR w_menor_fase.
      READ TABLE t_menor_fase
      INTO w_menor_fase
      WITH KEY vornr = w_fase-operation_number.

      IF sy-subrc = 0.
*       Descrição da fase
        CLEAR: w_fase.
        READ TABLE t_fase
        INTO w_fase
        WITH KEY operation_number = w_menor_fase-vornr.

        IF sy-subrc = 0.
          CALL FUNCTION 'YNQM_CONVERT_FIRSTCHAR_TOUPPER'
            EXPORTING
              input_string  = w_fase-description
            IMPORTING
              output_string = w_operacao-fase.

          w_operacao-ordem_processo = w_caufv-aufnr                . " Ordem de processo
          w_operacao-centro         = w_fase-prod_plant            . " Centro
          w_operacao-operacao       = w_fase-operation_number      . " Operação
          w_operacao-recurso        = w_fase-resource              . " Recurso
          w_operacao-status_apto    = c_sem_apto                   . " Status do apontamento
          w_operacao-confirmacao    = 1                            . " Nro da confirmação (CORT)
          w_operacao-hr_apo         = space                        . " Horas APO
          w_operacao-hr_hh          = space                        . " Horas HH
          w_operacao-qtd_boa        = space                        . " Quantidade boa
          APPEND w_operacao TO t_operacao                          .

          w_total_operacao-ordem_processo = w_caufv-aufnr          . " Ordem de processo
          w_total_operacao-centro         = w_fase-prod_plant      . " Centro
          w_total_operacao-operacao       = w_fase-operation_number. " Fase
          w_total_operacao-fase           = w_operacao-fase        . " Recurso
          w_total_operacao-recurso        = w_fase-resource        .  " Recurso
          w_total_operacao-hr_apo_tp_prep = space                  . " APO Tp. preparação
          w_total_operacao-hr_apo_tp_maq  = space                  . " APO Tp. maquina
          w_total_operacao-hr_hh_tp_prep  = space                  . " Custo HH Tp. preparação
          w_total_operacao-hr_hh_tp_maq   = space                  . " Custo HH Tp. maquina
          w_total_operacao-qtd_boa        = space                  . " Quantidade boa
          w_total_operacao-refugo         = space                  . " Refugo
          COLLECT w_total_operacao INTO t_total_operacao           .
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP. " LOOP AT t_afvc INTO w_afvc.

  TRY.
*     Preenche/atualiza a tabela com as operações
      me->set_t_operacao( t_operacao ).
      me->set_total_operacao( t_total_operacao ).

    CATCH ycx_apo INTO o_cx_apo.
      v_msg_erro = o_cx_apo->msg.
      RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDTRY.

ENDMETHOD.