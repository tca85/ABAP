*----------------------------------------------------------------------*
* Classe   : YCL_GKO                                                   *
* Método   : VERIFICAR_CTE_CONTRA_CNPJ_EMPRESA                         *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Verifica se é um CT-e emitido contra o CNPJ do Aché       *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  01.07.2015  #108147 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD VERIFICAR_CTE_CONTRA_CNPJ_EMPRESA.
*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_qtd_registros TYPE sy-tabix,
    v_msg_erro      TYPE string  .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

* Verifica se é um CT-e contra a empresa
  SELECT COUNT( DISTINCT cnpj )
   FROM /xnfe/tcnpj
   INTO v_qtd_registros
   WHERE cnpj = im_cnpj.

  IF v_qtd_registros IS INITIAL.
*   Não é um CT-e contra o Aché
    MESSAGE e001(ygko) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_gko EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.