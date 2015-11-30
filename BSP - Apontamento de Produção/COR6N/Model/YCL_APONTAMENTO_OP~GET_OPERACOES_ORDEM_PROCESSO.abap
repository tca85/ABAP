*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : GET_OPERACOES_ORDEM_PROCESSO                              *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obter cabeçalho e operações da ordem de processo          *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*<-- RETURNING VALUE( EX_T_OPERACAO )	TYPE TP_OPERACAO

METHOD get_operacoes_ordem_processo.

  DATA v_msg_erro TYPE string.

  ex_t_operacao = me->t_operacao.

  IF ex_t_operacao IS INITIAL.
*   Não foram encontradas operações
    MESSAGE e009(yapo) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.