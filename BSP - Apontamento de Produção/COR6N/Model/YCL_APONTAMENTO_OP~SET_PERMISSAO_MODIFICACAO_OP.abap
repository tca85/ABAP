*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                     *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : SET_PERMISSAO_MODIFICACAO_OP                              *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Preenche as operações e permissões de modificações        *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD set_permissao_modificacao_op.
*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
  TYPES:
    BEGIN OF ty_afru       ,
      aufnr TYPE afru-aufnr,
      vornr TYPE afru-vornr,
      rmzhl TYPE afru-rmzhl,
    END OF ty_afru         .

*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_afru     TYPE STANDARD TABLE OF ty_afru       ,
    t_operacao TYPE STANDARD TABLE OF ty_operacao_op.

*----------------------------------------------------------------------*
* Work Areas
*----------------------------------------------------------------------*
  DATA:
    w_afru      TYPE ty_afru       ,
    w_permissao TYPE ty_permissao  ,
    w_operacao  TYPE ty_operacao_op.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_indice      TYPE sy-tabix,
    v_operacao    TYPE vornr   ,
    v_confirmacao TYPE co_rmzhl,
    v_msg_erro    TYPE string  .

*----------------------------------------------------------------------*
* Objetos
*----------------------------------------------------------------------*
  DATA:
    o_cx_apo TYPE REF TO ycx_apo.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  TRY.
      t_operacao = get_operacoes_ordem_processo( ).

      SORT t_operacao BY operacao confirmacao ASCENDING.

    CATCH ycx_apo INTO o_cx_apo.
      v_msg_erro = o_cx_apo->msg.
      RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDTRY.

  CLEAR w_operacao.
  READ TABLE t_operacao
  INTO w_operacao
  INDEX 1.

* Obtém a operação atual que será apontada
  SELECT SINGLE MAX( vornr )                                "#EC *
   FROM afru
   INTO v_operacao
   WHERE aufnr = w_operacao-ordem_processo
     AND stokz = space
     AND stzhl = '00000000'.

  IF v_operacao IS NOT INITIAL.
*   Obtém o maior numerador da confirmação das operações (T-CODE CORT)
    SELECT SINGLE MAX( rmzhl )                              "#EC *
     FROM afru
     INTO v_confirmacao
     WHERE aufnr = w_operacao-ordem_processo
       AND vornr = v_operacao
       AND stokz = space
       AND stzhl = '00000000'.

*   Obtém o último apontamento (maior operação e última confirmação)
    SELECT aufnr vornr rmzhl
     FROM afru
     INTO TABLE t_afru
     WHERE aufnr = w_operacao-ordem_processo
       AND vornr = v_operacao
       AND rmzhl = v_confirmacao
       AND stokz = space
       AND stzhl = '00000000'.
  ENDIF.

* Verifica se ainda não foi criado nenhum apontamento
  IF t_afru IS INITIAL.
    CLEAR w_operacao.
    READ TABLE t_operacao
    INTO w_operacao
    INDEX 1.

    IF sy-subrc = 0.
      CLEAR w_afru.
      w_afru-aufnr = w_operacao-ordem_processo.
      w_afru-vornr = w_operacao-operacao      .
      w_afru-rmzhl = space                    .
      APPEND w_afru TO t_afru                 .
    ENDIF.
  ENDIF.

* Obtém a permissões do usuário e atribui para os campos
  LOOP AT t_afru INTO w_afru.

    CLEAR w_operacao.
    READ TABLE t_operacao
    INTO w_operacao
    WITH KEY operacao    = w_afru-vornr
             confirmacao = w_afru-rmzhl.

    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    CLEAR w_permissao.

    w_permissao = me->get_permissoes_usuario( im_usuario = sy-uname
                                              im_recurso = w_operacao-recurso
                                              im_centro  = w_operacao-centro ).

    IF w_permissao-estornar IS NOT INITIAL.
      w_operacao-estornar_apto = c_estornar_apto.
    ELSE.
      CLEAR w_operacao-estornar_apto.
    ENDIF.

*   Atualiza o campo estornar_apto da tabela interna
    MODIFY t_operacao
     FROM w_operacao
     TRANSPORTING estornar_apto
     WHERE operacao = w_afru-vornr.

    IF w_permissao-parcial IS NOT INITIAL.
      w_operacao-apto_parcial = c_apto_parcial.
    ENDIF.

    IF w_permissao-final IS NOT INITIAL.
      w_operacao-apto_final = c_apto_final.
    ENDIF.

    IF w_permissao-parcial IS NOT INITIAL
      OR w_permissao-final IS NOT INITIAL.

      IF w_afru-rmzhl IS NOT INITIAL.
**       Adiciona uma sequência ao contador de confirmações. Essa será a que o usuário estará apontando
*        w_operacao-confirmacao   = w_operacao-confirmacao + 1.
*        w_operacao-estornar_apto = space                     .
*        w_operacao-status_apto   = space                     .
*        w_operacao-hr_apo        = '0,00'                    .
*        w_operacao-qtd_boa       = '0,000'                   .
*        APPEND w_operacao TO t_operacao                      .
      ELSE.

        LOOP AT t_operacao INTO w_operacao WHERE operacao = w_afru-vornr.
          v_indice = sy-tabix.

          IF w_permissao-parcial IS NOT INITIAL.
            w_operacao-apto_parcial = c_apto_parcial.
          ENDIF.

          IF w_permissao-final IS NOT INITIAL.
            w_operacao-apto_final = c_apto_final.
          ENDIF.

          w_operacao-confirmacao   = 1    .
          w_operacao-estornar_apto = space.
          w_operacao-status_apto   = space.
          MODIFY t_operacao FROM w_operacao INDEX v_indice.
        ENDLOOP.
      ENDIF.

    ENDIF.

  ENDLOOP. " LOOP AT t_afru INTO w_afru.

  LOOP AT t_operacao INTO w_operacao.
    v_indice = sy-tabix.

    CLEAR w_permissao.

    w_permissao = me->get_permissoes_usuario( im_usuario = sy-uname
                                              im_recurso = w_operacao-recurso
                                              im_centro  = w_operacao-centro ).

*   Verifica se tem permissão de visualizar as outras fases/recursos
    IF w_permissao-visualizar IS INITIAL.

      IF  w_permissao-parcial IS INITIAL
        AND w_permissao-final IS INITIAL.

        DELETE t_operacao INDEX v_indice.
      ENDIF.

    ENDIF.
  ENDLOOP.

  TRY.
*     Preenche/atualiza a tabela com as operações
      me->set_t_operacao( t_operacao ).

    CATCH ycx_apo INTO o_cx_apo.
      v_msg_erro = o_cx_apo->msg.
      RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDTRY.

ENDMETHOD.