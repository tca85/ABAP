*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                     *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : SET_W_APONTAMENTO                                         *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Preenche e valida os campos obrigatórios que podem ser    *
*            informados, ou alterados de alguma forma (JavaScript) pelo*
*            usuário na página web (view apontar.htm)                  *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_W_APONTAMENTO	TYPE TY_APONTAMENTO

METHOD set_w_apontamento.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    o_cx_apo      TYPE REF TO ycx_apo,
    w_permissao   TYPE ty_permissao  ,                      "#EC NEEDED
    w_apontamento TYPE ty_apontamento,
    v_roteiro     TYPE caufv-aufpl   ,
    v_operacao    TYPE afvc-vornr    ,
    v_msg_erro    TYPE string        .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  TRY.
      w_apontamento-ordem_processo = im_w_tela_apto-ordem_processo.
      w_apontamento-centro         = im_w_tela_apto-centro        .
      w_apontamento-nro_operacao   = im_w_tela_apto-nro_operacao  .
      w_apontamento-recurso        = im_w_tela_apto-recurso       .
      w_apontamento-fase           = im_w_tela_apto-fase          .

      set_ordem_processo( im_ordem_processo = w_apontamento-ordem_processo ).
      set_centro( CHANGING ex_centro = w_apontamento-centro ).
      set_nro_operacao( CHANGING ex_nro_operacao = w_apontamento-nro_operacao ).
      set_recurso( CHANGING ex_recurso = w_apontamento-recurso ).

*     Verifica se ninguém alterou o conteúdo (html) da view Apontar
      w_permissao = get_permissoes_usuario( im_usuario = sy-uname
                                            im_recurso = w_apontamento-recurso
                                            im_centro  = w_apontamento-centro ).

      w_apontamento-ordem_processo = get_ordem_processo( ).

*     Visão dos cabeçalhos de ordens PCP/RK
      SELECT SINGLE aufpl
       FROM caufv
       INTO v_roteiro
        WHERE aufnr = w_apontamento-ordem_processo
          AND autyp = me->c_ordem_processo
          AND werks = w_apontamento-centro.

      IF v_roteiro IS NOT INITIAL.
*       Operação da ordem
        SELECT SINGLE vornr                                 "#EC *
         FROM afvc
         INTO v_operacao
         WHERE aufpl = v_roteiro      " Nº de roteiro
           AND lek04 = space          " sem atividade restante
           AND phseq = me->c_folha_pi " Destinatário da receita de controle
           AND vornr = w_apontamento-nro_operacao.
      ENDIF.

      IF v_operacao IS INITIAL.
*       Ordem de processo & do centro & não possui a operação &
        MESSAGE e023(yapo) WITH w_apontamento-ordem_processo
                                w_apontamento-centro
                                w_apontamento-nro_operacao
                           INTO v_msg_erro.
        RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
      ENDIF.

*     Atualiza o atributo da classe w_apontamento com os valores validados
      CLEAR me->w_apontamento                                                               .
      me->w_apontamento-ordem_processo = w_apontamento-ordem_processo                       . " Ordem de processo
      me->w_apontamento-centro         = w_apontamento-centro                               . " Centro
      me->w_apontamento-nro_operacao   = w_apontamento-nro_operacao                         . " Número da operação
      me->w_apontamento-fase           = w_apontamento-fase                                 . " Txt.breve operação
      me->w_apontamento-recurso        = w_apontamento-recurso                              . " Recurso
      me->w_apontamento-hr_apo_tp_prep = converter_char_qty( im_w_tela_apto-hr_apo_tp_prep ). " APO Tp. preparação
      me->w_apontamento-hr_apo_tp_maq  = converter_char_qty( im_w_tela_apto-hr_apo_tp_maq  ). " APO Tp. maquina
      me->w_apontamento-hr_hh_tp_prep  = converter_char_qty( im_w_tela_apto-hr_hh_tp_prep  ). " Custo HH Tp. preparação
      me->w_apontamento-hr_hh_tp_maq   = converter_char_qty( im_w_tela_apto-hr_hh_tp_maq   ). " Custo HH Tp. maquina
      me->w_apontamento-qtd_boa        = converter_char_qty( im_w_tela_apto-qtd_boa        ). " Quantidade boa
      me->w_apontamento-refugo         = converter_char_qty( im_w_tela_apto-refugo         ). " Refugo

    CATCH ycx_apo INTO o_cx_apo.
      v_msg_erro = o_cx_apo->msg.
      RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDTRY.

ENDMETHOD.