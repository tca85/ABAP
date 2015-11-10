REPORT z101 NO STANDARD PAGE HEADING.

DATA: t_bapicondct  TYPE STANDARD TABLE OF bapicondct,
      t_bapicondhd  TYPE STANDARD TABLE OF bapicondhd,
      t_bapicondit  TYPE STANDARD TABLE OF bapicondit,
      t_bapicondqs  TYPE STANDARD TABLE OF bapicondqs,
      t_bapicondvs  TYPE STANDARD TABLE OF bapicondvs,
      t_bapiret2    TYPE STANDARD TABLE OF bapiret2,
      w_bapiret2    TYPE bapiret2,
      w_bapicondct  TYPE bapicondct,
      w_bapicondhd  TYPE bapicondhd,
      w_bapicondit  TYPE bapicondit,
      t_bapiknumhs  TYPE STANDARD TABLE OF bapiknumhs,
      t_mem_initial TYPE STANDARD TABLE OF cnd_mem_initial.

DATA: t_963 TYPE STANDARD TABLE OF y963,
      w_963 LIKE LINE OF t_963.

*------------------------------------------------------------------------
*---> exemplo de teste que o Denilson me passou
w_963-escr_vendas = '5500'      .
w_963-cliente     = '0000100923'.
w_963-grupo_mat   = '10'        .
w_963-montante    = '75,00'     .
w_963-data1       = '01.03.2015'.
w_963-data2       = '31.03.2015'.
w_963-cond_pagto  = 'Y029'      .
APPEND w_963 TO t_963           .
*------------------------------------------------------------------------


DATA: v_funcao_operacao TYPE msgfn.

*EscrVendas/Cliente/Grupo mat.
LOOP AT t_963 INTO w_963.

* formatar os campos abaixo
  w_963-data1    = '20150401'.
  w_963-data2    = '20150431'.
  w_963-montante = '75.00'   .

*  v_funcao_operacao = '009'.
  v_funcao_operacao = '004'.

  CLEAR w_bapicondct.
  w_bapicondct-operation  = v_funcao_operacao  . " Original: primeira mensagem para operação
  w_bapicondct-applicatio = 'V'                . " Aplicação
  w_bapicondct-cond_type  = 'YDEC'             . " Tipo de condição
  w_bapicondct-table_no   = '963'              . " Tabela de condições
  w_bapicondct-cond_usage = 'A'                . " Utilização da tabela de condições
  w_bapicondct-cond_no    = '$000000001'       . " Nº registro de condição
  w_bapicondct-valid_from = w_963-data1        . " Data início validade
  w_bapicondct-valid_to   = w_963-data2        . " Data de validade final

  CONCATENATE w_963-escr_vendas                " Escritório de vendas
              w_963-cliente                    " Nº cliente
              w_963-grupo_mat                  " Grupo de condições material
         INTO w_bapicondct-varkey.

  APPEND w_bapicondct TO t_bapicondct.

  CLEAR w_bapicondhd                           .
  w_bapicondhd-operation  = v_funcao_operacao  . " Função
  w_bapicondhd-applicatio = 'V'                . " Aplicação
  w_bapicondhd-cond_type  = 'YDEC'             . " Tipo de condição
  w_bapicondhd-table_no   = '963'              . " Tabela de condições
  w_bapicondhd-cond_usage = 'A'                . " Utilização da tabela de condições
  w_bapicondhd-cond_no    = '$000000001'       . " Nº registro de condição
  w_bapicondhd-created_by = sy-uname           . " Nome do responsável que adicionou o objeto
  w_bapicondhd-creat_date = sy-datum           . " Data de criação do registro
  w_bapicondhd-varkey     = w_bapicondct-varkey. " Chave variável
  w_bapicondhd-valid_from = w_963-data1        . " Data início validade
  w_bapicondhd-valid_to   = w_963-data2        . " Data de validade final
  APPEND w_bapicondhd TO t_bapicondhd          .

  CLEAR w_bapicondit                           .
  w_bapicondit-operation  = v_funcao_operacao  . " Função
  w_bapicondit-applicatio = 'V'                . " Aplicação
  w_bapicondit-cond_type  = 'YDEC'             . " Tipo de condição
  w_bapicondit-cond_no    = '$000000001'       . " Nº registro de condição
  w_bapicondit-scaletype  = 'A'                . " Tipo de escala
  w_bapicondit-scalebasin = 'B'                . " Código: base de cálculo
  w_bapicondit-calctypcon = 'B'                . " Regra de cálculo de condição
  w_bapicondit-cond_count = sy-tabix           . " Nº seqüencial da condição
  w_bapicondit-cond_value = w_963-montante     . " Montante em moeda para BAPIs (com 9 casas decimais)
  w_bapicondit-condcurr   = 'BRL'              . " Unidade de condição (moeda ou porcentagem)
  w_bapicondit-pmnttrms	  =	w_963-cond_pagto   . " Chave de condições de pagamento

  w_bapicondit-scale_qty  = w_bapicondit-scale_qty + 1. " Base de escala da condição - quantidade
  w_bapicondit-cond_p_unt = 1.                          " Unidade de preço da condição

  APPEND w_bapicondit TO t_bapicondit.
ENDLOOP.

*EscrVendas/Cliente/Grupo mat.
IF t_963 IS NOT INITIAL.
  CALL FUNCTION 'BAPI_PRICES_CONDITIONS'
    TABLES
      ti_bapicondct  = t_bapicondct
      ti_bapicondhd  = t_bapicondhd
      ti_bapicondit  = t_bapicondit
      ti_bapicondqs  = t_bapicondqs
      ti_bapicondvs  = t_bapicondvs
      to_bapiret2    = t_bapiret2
      to_bapiknumhs  = t_bapiknumhs
      to_mem_initial = t_mem_initial
    EXCEPTIONS
      update_error   = 1
      OTHERS         = 2.

  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

    LOOP AT t_bapiret2 INTO w_bapiret2.
      WRITE: w_bapiret2-message.
    ENDLOOP.
  ENDIF.

ENDIF.