*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Eliminar a comissão                                       *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  15.10.2014  #***** - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD eliminar_comissao.

*----------------------------------------------------------------------*
* Tabelas Internas                                                     *
*----------------------------------------------------------------------*
  DATA:
    t_aprov_comissao_aux TYPE STANDARD TABLE OF ty_aprov_comissao,
    t_cv_cabecalho       TYPE STANDARD TABLE OF zsdt033c         ,
    t_cv_item            TYPE STANDARD TABLE OF zsdt033i         ,
    t_cv_item_aux        TYPE STANDARD TABLE OF zsdt033i         ,
    t_retorno_bapi       TYPE STANDARD TABLE OF bapiret2         .

*----------------------------------------------------------------------*
* Work-Areas / Field-Symbols                                           *
*----------------------------------------------------------------------*
  DATA:
    w_aprov_comissao     LIKE LINE OF ex_t_aprov_comissao ,
    w_aprov_comissao_aux LIKE LINE OF t_aprov_comissao_aux,
    w_cv_item            LIKE LINE OF t_cv_item           ,
    w_cv_item_aux        LIKE LINE OF t_cv_item_aux       .

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
  DATA:
    v_sequencia   TYPE n LENGTH 10    ,
    v_return_code TYPE inri-returncode,
    v_msg_erro    TYPE t100-text      ,
    v_indice      TYPE sy-tabix       ,
    v_resposta    TYPE c LENGTH 01    .

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
  CONSTANTS:
    c_range_cv  TYPE inri-object    VALUE 'ZSD_COM',
    c_nro_range TYPE inri-nrrangenr VALUE '01'     .

*----------------------------------------------------------------------*
* Início                                                               *
*----------------------------------------------------------------------*

  APPEND LINES OF ex_t_aprov_comissao TO t_aprov_comissao_aux.
  SORT t_aprov_comissao_aux BY conf ASCENDING.

* Exclui as notas que não foram selecionadas (checkbox 'Confirmar')
  DELETE t_aprov_comissao_aux WHERE conf IS INITIAL.

  DELETE t_aprov_comissao_aux WHERE status = icon_checked.

  IF t_aprov_comissao_aux IS INITIAL.
*   Selecione as notas antes de eliminar
    MESSAGE i008(zsdr033) INTO v_msg_erro.
    RAISE EXCEPTION TYPE zcx_comissao_vendas EXPORTING mensagem = v_msg_erro.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question = 'Deseja eliminar as comissões selecionadas?'
      text_button_1 = 'Sim'(001)
      text_button_2 = 'Não'(002)
    IMPORTING
      answer        = v_resposta
    EXCEPTIONS
      OTHERS        = 2.

  IF v_resposta = 1.
    LOOP AT t_aprov_comissao_aux INTO w_aprov_comissao_aux.
      DELETE FROM zsdt033c WHERE nrg = w_aprov_comissao_aux-nrg.
      DELETE FROM zsdt033i WHERE nrg = w_aprov_comissao_aux-nrg.
    ENDLOOP.

    DELETE ex_t_aprov_comissao WHERE conf IS NOT INITIAL.

  ENDIF.

ENDMETHOD.
