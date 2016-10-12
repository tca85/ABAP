*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obter valor total da comissão                             *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  29.09.2014  #***** - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_T_VBAK       TYPE TP_VBAK
*--> IMPORTING IM_R_KSCHL	     TYPE R_KSCHL
*<-- CHANGING  EX_T_KONV_TOTAL TYPE TP_KONV_TOTAL

METHOD get_val_total_comissao.

*----------------------------------------------------------------------*
* Tabelas Internas                                                     *
*----------------------------------------------------------------------*
  DATA:
    t_konv TYPE STANDARD TABLE OF ty_konv.

*----------------------------------------------------------------------*
* Work-Areas / Field-Symbols                                           *
*----------------------------------------------------------------------*
  DATA:
    w_konv_total LIKE LINE OF ex_t_konv_total.

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro TYPE t100-text,
    v_indice   TYPE sy-tabix .

*----------------------------------------------------------------------*
* Início                                                               *
*----------------------------------------------------------------------*
  IF im_t_vbak IS INITIAL.
    MESSAGE e001(zsdr033) INTO v_msg_erro.
    RAISE EXCEPTION TYPE zcx_comissao_vendas EXPORTING mensagem = v_msg_erro.
  ENDIF.

  SELECT knumv " Nº condição do documento
         kposn " Nº item ao qual se aplicam as condições
         kschl " Tipo de condição
         kbetr " Montante ou porcentagem da condição
         kwert " Valor condição
  FROM konv    " Condições (dados de operação)
  INTO TABLE t_konv
  FOR ALL ENTRIES IN im_t_vbak
   WHERE knumv EQ im_t_vbak-knumv
     AND kschl IN im_r_kschl.

  LOOP AT t_konv ASSIGNING FIELD-SYMBOL(<f_w_konv>).
    w_konv_total-knumv = <f_w_konv>-knumv    . " Nº condição do documento
    w_konv_total-kschl = <f_w_konv>-kschl    . " Tipo de condição
    w_konv_total-kwert = <f_w_konv>-kwert    . " Valor condição
    COLLECT w_konv_total INTO ex_t_konv_total.
  ENDLOOP.

ENDMETHOD.
