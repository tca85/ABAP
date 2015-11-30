REPORT ynfe_atualizar_status_b2b NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
*                 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                   *
*----------------------------------------------------------------------*
* Programa...: YNFE_ATUALIZAR_STATUS_B2B                               *
* Transação..: YNFE_ATUALIZAR_B2B                                      *
* Descrição..: Atualizar status B2B das NF-e enviadas                  *
* Tipo.......: ALV                                                     *
* Módulo.....: GRC                                                     *
* ABAP.......: Thiago Cordeiro Alves                                   *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  09.10.2015  #125643 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
DATA:
  t_nfe_b2b TYPE STANDARD TABLE OF znfe_b2b      ,
  t_nfe     TYPE STANDARD TABLE OF /xnfe/outnfehd.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
DATA:
  w_nfe_b2b LIKE LINE OF t_nfe_b2b,
  w_nfe     LIKE LINE OF t_nfe    .

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
CONSTANTS:
  c_processo_concluido TYPE /xnfe/outnfe_actstat VALUE '99',
  c_status_ok          TYPE /xnfe/out_stepstatus VALUE '01'.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
DATA:
  v_indice TYPE sy-tabix.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
START-OF-SELECTION.

  SELECT * FROM znfe_b2b
   INTO TABLE t_nfe_b2b.

  IF t_nfe_b2b IS NOT INITIAL.
    SELECT * FROM /xnfe/outnfehd
     INTO TABLE t_nfe
     FOR ALL ENTRIES IN t_nfe_b2b
     WHERE id = t_nfe_b2b-id.
  ENDIF.

  LOOP AT t_nfe INTO w_nfe.
    v_indice = sy-tabix.

    w_nfe-b2b_actstat      = c_processo_concluido. " Status global
    w_nfe-b2b_last_step_st = c_status_ok         . " Saída - status da etapa do processo

    MODIFY t_nfe FROM w_nfe INDEX v_indice.
  ENDLOOP.

  IF t_nfe IS NOT INITIAL.
    MODIFY /xnfe/outnfehd FROM TABLE t_nfe.
  ENDIF.

* Limpa a tabela
  DELETE FROM znfe_b2b.