*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                     *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : SET_ORDEM_PROCESSO                                        *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Preenche a ordem de processo informada                    *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_ORDEM_PROCESSO  TYPE CAUFV-AUFNR

METHOD set_ordem_processo.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro TYPE string,
    v_qtd_reg  TYPE i     .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = im_ordem_processo
    IMPORTING
      output = me->ordem_processo.

* Remove textos e caracteres especiais para evitar SQL Injection
  REPLACE ALL OCCURRENCES OF REGEX '[^\d]' IN me->ordem_processo WITH space.

  IF me->ordem_processo IS INITIAL.
*   Informe a ordem de processo
    MESSAGE e007(yapo) INTO v_msg_erro.                     "#EC *
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDIF.

* Visão dos cabeçalhos de ordens PCP/RK
  SELECT COUNT( DISTINCT aufnr )
   FROM caufv
   INTO v_qtd_reg
   WHERE aufnr = me->ordem_processo
     AND autyp = me->c_ordem_processo. "40

  IF v_qtd_reg = 0.
*   Ordem de processo & não encontrada
    MESSAGE e001(yapo) WITH im_ordem_processo INTO v_msg_erro. "#EC *
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.