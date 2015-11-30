*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : GET_DETALHES_FOLHA_TEMPOS                                 *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obtém os detalhes da folha de tempos - COR6N              *
*            Retorna os mesmos campos que seriam exibidos na transação *
*            COR6N caso o usuário entrasse com a ordem de processo e   *
*            fase, para que ele informe o restante dos valores da      *
*            confirmação da folha de tempos para ordem de processo     *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD get_detalhes_folha_tempos.

*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
    t_operacao       TYPE STANDARD TABLE OF ty_operacao_op   ,
    t_total_operacao TYPE STANDARD TABLE OF ty_total_operacao.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_operacao       LIKE LINE OF t_operacao      ,
    w_total_operacao LIKE LINE OF t_total_operacao.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro       TYPE string    ,
    v_ordem_processo TYPE afko-aufnr.

*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
  DATA:
    o_cx_apo TYPE REF TO ycx_apo.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  TRY.
      me->set_ordem_processo( im_ordem_processo ).

      v_ordem_processo = me->get_ordem_processo( ).

      me->set_operacoes_ordem_processo( v_ordem_processo ).

      t_operacao       = me->get_operacoes_ordem_processo( ).
      t_total_operacao = me->get_total_operacao( ).

      SORT t_operacao BY confirmacao DESCENDING.

*     Seleciona a operação que será apontada
      CLEAR w_operacao.
      READ TABLE t_operacao
      INTO w_operacao
      INDEX 1.

      IF sy-subrc = 0.
        CLEAR w_total_operacao.
        READ TABLE t_total_operacao
        INTO w_total_operacao
        WITH KEY ordem_processo = w_operacao-ordem_processo
                 centro         = w_operacao-centro
                 operacao       = w_operacao-operacao
                 fase           = w_operacao-fase.

        IF sy-subrc = 0.
          ex_w_apontamento-ordem_processo = w_total_operacao-ordem_processo. " Ordem de processo
          ex_w_apontamento-centro         = w_total_operacao-centro        . " Centro
          ex_w_apontamento-nro_operacao   = w_total_operacao-operacao      . " Número da operação
          ex_w_apontamento-fase           = w_total_operacao-fase          . " Txt.breve operação
          ex_w_apontamento-recurso        = w_total_operacao-recurso       . " Recurso
          ex_w_apontamento-dsc_recurso    = w_total_operacao-dsc_recurso   . " Descrição Recurso
          ex_w_apontamento-material       = w_total_operacao-material      . " Material
          ex_w_apontamento-dsc_material   = w_total_operacao-dsc_material  . " Descrição do material
          ex_w_apontamento-qtd_planejada  = w_total_operacao-qtd_planejada . " Quantidade planejada
          ex_w_apontamento-unidade_medida = w_total_operacao-unidade_medida. " Unidade de medida
          ex_w_apontamento-hr_apo_tp_prep = w_total_operacao-hr_apo_tp_prep. " APO Tp. preparação
          ex_w_apontamento-hr_apo_tp_maq  = w_total_operacao-hr_apo_tp_maq . " APO Tp. maquina
          ex_w_apontamento-hr_hh_tp_prep  = w_total_operacao-hr_hh_tp_prep . " Custo HH Tp. preparação
          ex_w_apontamento-hr_hh_tp_maq   = w_total_operacao-hr_hh_tp_maq  . " Custo HH Tp. maquina
          ex_w_apontamento-qtd_apontada   = w_total_operacao-qtd_apontada  . " Quantidade boa apontada
          ex_w_apontamento-refugo         = w_total_operacao-refugo        . " Refugo

          IF im_confirmacao_final IS NOT INITIAL.
            ex_w_apontamento-qtd_boa = w_total_operacao-qtd_boa. " Quantidade boa

          ELSEIF im_confirmacao_parcial IS NOT INITIAL.
            CLEAR ex_w_apontamento-qtd_boa.
          ENDIF.

          SHIFT ex_w_apontamento-ordem_processo LEFT DELETING LEADING '0'.
        ENDIF.
      ENDIF.

    CATCH ycx_apo INTO o_cx_apo.
      v_msg_erro = o_cx_apo->msg.
      RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDTRY.

ENDMETHOD.