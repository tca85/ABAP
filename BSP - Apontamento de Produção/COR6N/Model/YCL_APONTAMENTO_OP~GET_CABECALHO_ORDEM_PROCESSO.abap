*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : GET_CABECALHO_ORDEM_PROCESSO                              *
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

*<-- RETURNING VALUE( EX_W_CABECALHO_OP )  TYPE TY_CABECALHO_OP

METHOD get_cabecalho_ordem_processo.

  DATA v_msg_erro TYPE string.

  ex_w_cabecalho_op = me->w_cabecalho_op.

  IF ex_w_cabecalho_op IS INITIAL.
*   Não foram encontradas operações
    MESSAGE e009(yapo) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.