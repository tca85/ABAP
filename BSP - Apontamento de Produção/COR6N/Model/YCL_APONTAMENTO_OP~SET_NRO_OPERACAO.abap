*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                     *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : SET_NRO_OPERACAO                                          *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Preenche e valida o número da operação da o.p             *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_NRO_OPERACAO          TYPE AFVC-VORNR
*<-- RETURNING VALUE( EX_NRO_OPERACAO )	TYPE AFVC-VORNR

METHOD set_nro_operacao.

  DATA: v_msg_erro TYPE string.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = ex_nro_operacao
    IMPORTING
      output = ex_nro_operacao.

* Remove textos e caracteres especiais para evitar SQL Injection
  REPLACE ALL OCCURRENCES OF REGEX '[^\d]' IN ex_nro_operacao WITH space.

  IF ex_nro_operacao IS INITIAL.
*   Número de operação & é inválido
    MESSAGE e011(yapo) WITH ex_nro_operacao INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.