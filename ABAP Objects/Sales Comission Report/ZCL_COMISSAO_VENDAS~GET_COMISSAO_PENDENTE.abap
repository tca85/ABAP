*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obter comissão do fornecedor                              *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  16.10.2014  #***** - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_R_NRG	      TYPE R_NRG
*--> IMPORTING IM_R_LIFNR	    TYPE R_LIFNR
*--> IMPORTING IM_R_PERNR	    TYPE R_PERNR
*--> IMPORTING IM_R_ERDAT	    TYPE R_ERDAT
*<-- RETURNING EX_T_APROV_COM TYPE TP_APROV_COMISSAO

METHOD get_comissao_pendente.
  INCLUDE: <icon>.

*----------------------------------------------------------------------*
* Tabelas Internas                                                     *
*----------------------------------------------------------------------*
  DATA:
    t_cv_cabec TYPE STANDARD TABLE OF zsdt033c,
    t_cv_item  TYPE STANDARD TABLE OF zsdt033i.

*----------------------------------------------------------------------*
* Tabelas Internas                                                     *
*----------------------------------------------------------------------*
  DATA:
    w_cv_cabec  LIKE LINE OF t_cv_cabec    ,
    w_cv_item   LIKE LINE OF t_cv_item     ,
    w_aprov_com LIKE LINE OF ex_t_aprov_com.

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro TYPE t100-text,
    v_indice   TYPE sy-tabix .

*----------------------------------------------------------------------*
* Início                                                               *
*----------------------------------------------------------------------*
* Comissão de Vendas - Cabeçalho
  SELECT * FROM zsdt033c
   INTO TABLE t_cv_cabec
   WHERE nrg    IN im_r_nrg
     AND erdat1 IN im_r_erdat
     AND lifnr  IN im_r_lifnr.

* Comissão de Vendas - Ítem
  SELECT * FROM zsdt033i
   INTO TABLE t_cv_item
   FOR ALL ENTRIES IN t_cv_cabec
   WHERE nrg = t_cv_cabec-nrg.

* Exclui as notas que já tem pedido criado (foram aprovadas)
  LOOP AT t_cv_cabec INTO w_cv_cabec.
    v_indice = sy-tabix.

    READ TABLE t_cv_item
    TRANSPORTING NO FIELDS
    WITH KEY nrg = w_cv_cabec-nrg.

    IF sy-subrc <> 0.
      DELETE t_cv_cabec INDEX v_indice.
    ENDIF.
  ENDLOOP.

  LOOP AT t_cv_cabec INTO w_cv_cabec.
    CLEAR w_aprov_com.

    w_aprov_com-status = icon_incomplete  . " Status
    w_aprov_com-nrg    = w_cv_cabec-nrg   . " Número de registro
    w_aprov_com-erdat  = w_cv_cabec-erdat1. " Data de criação do registro
    w_aprov_com-lifnr  = w_cv_cabec-lifnr . " Nº conta do fornecedor

    SELECT SINGLE name1
     FROM lfa1
     INTO w_aprov_com-name1
     WHERE lifnr = w_cv_cabec-lifnr.

    w_aprov_com-pernr = w_cv_cabec-pernr. " Nº da pessoa

    SELECT SINGLE sname
     FROM pa0001
     INTO w_aprov_com-name2
     WHERE pernr = w_aprov_com-pernr.

*   Valor total da comissão
    SELECT SUM( vcom )
     FROM zsdt033i
     INTO w_aprov_com-vcom " Valor total da comissão
     WHERE nrg = w_cv_cabec-nrg.

*   Valor a pagar
    SELECT SUM( vcopd )
     FROM zsdt033i
     INTO w_aprov_com-vlpag " Valor a pagar
     WHERE nrg = w_cv_cabec-nrg.

*   Valor à compensar
    SELECT SUM( vcomp )
     FROM zsdt033i
     INTO w_aprov_com-vcomp " Valor à compensar
     WHERE nrg = w_cv_cabec-nrg.

    CLEAR w_cv_item.

    READ TABLE t_cv_item
    INTO w_cv_item
    WITH KEY nrg = w_cv_cabec-nrg.

    IF sy-subrc = 0.
      w_aprov_com-bstnk = w_cv_item-ebeln.
    ENDIF.

    APPEND w_aprov_com TO ex_t_aprov_com.
  ENDLOOP.

  IF ex_t_aprov_com IS INITIAL.
    MESSAGE e001(zsdr033) INTO v_msg_erro.
    RAISE EXCEPTION TYPE zcx_comissao_vendas EXPORTING mensagem = v_msg_erro.
  ENDIF.

ENDMETHOD.
