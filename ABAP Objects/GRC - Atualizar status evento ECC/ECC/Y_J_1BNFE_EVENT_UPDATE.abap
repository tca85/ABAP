FUNCTION y_j_1bnfe_event_update.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IM_DOCNUM) TYPE  J_1BNFDOC-DOCNUM
*"     VALUE(IM_DOCSTAT) TYPE  J_1BNFEDOCSTATUS
*"     VALUE(IM_STATUSCOD) TYPE  J_1BSTATUSCODE
*"     VALUE(IM_UPDATE_TASK) TYPE  CHAR1 OPTIONAL
*"  EXCEPTIONS
*"      NFE_NAO_ENCONTRADA
*"----------------------------------------------------------------------

*-----------------------------------------------------------------------
* Variáveis
*-----------------------------------------------------------------------
  DATA:
     v_modo_execucao TYPE c LENGTH 01.

  DATA:
     w_evento TYPE j_1bnfe_event.

  CONSTANTS:
     c_modo_atualizacao TYPE c LENGTH 01 VALUE 'U'.

*-----------------------------------------------------------------------
* Início
*-----------------------------------------------------------------------
  SELECT SINGLE * FROM j_1bnfe_event
    INTO w_evento
    WHERE docnum = im_docnum.

  IF w_evento IS INITIAL.
    RAISE nfe_nao_encontrada.
  ENDIF.

  v_modo_execucao = c_modo_atualizacao.
  w_evento-docsta = im_docstat        . " NF-e: status do documento
  w_evento-code   = im_statuscod      . " NF-e: código de status

  IF im_update_task IS INITIAL.
    CALL FUNCTION 'J_1BNFE_EVENT_UPDATE'
      EXPORTING
        is_event_common = w_evento
        iv_updmode      = v_modo_execucao.
  ELSE.
    CALL FUNCTION 'J_1BNFE_EVENT_UPDATE'
      IN UPDATE TASK
      EXPORTING
        is_event_common = w_evento
        iv_updmode      = v_modo_execucao.
  ENDIF.

ENDFUNCTION.
