*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : GET_ORDEM_PROCESSO                                        *
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

*<-- RETURNING VALUE( EX_ORDEM_PROCESSO )	TYPE AFKO-AUFNR

METHOD get_ordem_processo.

  DATA v_msg_erro TYPE string.

  ex_ordem_processo = me->ordem_processo.

  IF ex_ordem_processo IS INITIAL.
*   Informe a ordem de processo
    MESSAGE e007(yapo) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.