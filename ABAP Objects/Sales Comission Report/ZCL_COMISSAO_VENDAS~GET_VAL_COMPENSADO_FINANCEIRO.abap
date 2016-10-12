*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obter valor compensado no financeiro                      *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  14.10.2014  #***** - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> CHANGING IM_T_COMISSAO TYPE TP_COMISSAO

METHOD get_val_compensado_financeiro.

*----------------------------------------------------------------------*
* Tabelas Internas                                                     *
*----------------------------------------------------------------------*
  DATA:
    t_bseg          TYPE STANDARD TABLE OF ty_bseg ,
    t_bseg_aux      TYPE STANDARD TABLE OF ty_bseg ,
    t_vbfa          TYPE STANDARD TABLE OF ty_vbfa ,
    t_comissao_item TYPE STANDARD TABLE OF zsdt033i.

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro           TYPE t100-text  ,
    v_qtd_parcelas       TYPE i          ,
    v_qtd_parcelas_pagas TYPE i          ,
    v_indice             TYPE sy-tabix   ,
    v_vl_tot_compensar   TYPE zsde_vlcomp.

*----------------------------------------------------------------------*
* Início                                                               *
*----------------------------------------------------------------------*
  IF im_t_comissao IS INITIAL.
    EXIT.
  ENDIF.

  SELECT vbelv   " Documento de vendas e distribuição precedente
         vbeln   " Nº documento de vendas e distribuição
         vbtyp_n " Categoria de documento SD subseqüente
         vbtyp_v " Ctg.documento de venda e distribuição (SD) precedente
  FROM vbfa      " Fluxo de documentos de vendas e distribuição
  INTO TABLE t_vbfa
   FOR ALL ENTRIES IN im_t_comissao
   WHERE vbelv   = im_t_comissao-vbeln
     AND vbtyp_n = me->c_fatura " M
     AND vbtyp_v = me->c_ordem. " C

  IF t_vbfa IS NOT INITIAL.
    SORT t_vbfa BY vbeln ASCENDING.

    SELECT vbeln " Nº documento de vendas e distribuição
           buzei " Nº linha de lançamento no documento contábil
           augbl " Nº documento de compensação
           koart " Tipo de conta
    FROM bseg    " Segmento do documento contabilidade financeira
    INTO TABLE t_bseg
    FOR ALL ENTRIES IN t_vbfa
    WHERE vbeln = t_vbfa-vbeln
      AND koart = me->c_conta_cliente. " D
  ENDIF.

  SORT t_bseg BY augbl ASCENDING.
  APPEND LINES OF t_bseg TO t_bseg_aux.

* Notas que o valor já foi compensado
  DELETE t_bseg_aux WHERE augbl IS INITIAL.

  IF t_bseg_aux IS NOT INITIAL.
    SELECT * FROM zsdt033i " Comissão de Vendas - Item
    INTO TABLE t_comissao_item
    FOR ALL ENTRIES IN t_bseg_aux
     WHERE augbl = t_bseg_aux-augbl. " Nº documento de compensação
  ENDIF.

  SORT:
     t_bseg          BY augbl ASCENDING,
     t_comissao_item BY augbl ASCENDING.

* Verificar se a parcela já foi paga ao representante
  LOOP AT t_bseg ASSIGNING FIELD-SYMBOL(<f_w_bseg>).
    v_indice = sy-tabix.

    READ TABLE t_comissao_item
    ASSIGNING FIELD-SYMBOL(<f_w_comissao_item>)
    WITH KEY augbl = <f_w_bseg>-augbl
    BINARY SEARCH.

    IF sy-subrc = 0.
      DELETE t_bseg INDEX v_indice.
    ELSE.

      CLEAR v_qtd_parcelas.

*     Quantidade de parcelas que ainda faltam serem pagas
      SELECT COUNT( * )
       FROM bseg
       INTO v_qtd_parcelas
       WHERE vbeln = <f_w_bseg>-vbeln
         AND augbl <> space.

      <f_w_bseg>-parc = v_qtd_parcelas.
      MODIFY t_bseg FROM <f_w_bseg> INDEX v_indice.
    ENDIF.
  ENDLOOP.

  SORT:
    im_t_comissao BY vbeln ASCENDING,
    t_vbfa        BY vbelv ASCENDING,
    t_bseg        BY vbeln ASCENDING.

  LOOP AT im_t_comissao ASSIGNING FIELD-SYMBOL(<f_w_comissao>).
    v_indice = sy-tabix.

    READ TABLE t_vbfa
    ASSIGNING FIELD-SYMBOL(<f_w_vbfa>)
    WITH KEY vbelv = <f_w_comissao>-vbeln
    BINARY SEARCH.

    IF sy-subrc = 0.
      READ TABLE t_bseg
      ASSIGNING <f_w_bseg>
      WITH KEY vbeln = <f_w_vbfa>-vbeln
      BINARY SEARCH.

      IF sy-subrc = 0.
        IF <f_w_bseg>-parc IS INITIAL.
          CLEAR <f_w_comissao>-vcomp.
          MODIFY im_t_comissao FROM <f_w_comissao> INDEX v_indice.
        ELSE.

*         Quantidade total de parcelas
          SELECT COUNT( * )
           FROM bseg
           INTO v_qtd_parcelas
           WHERE vbeln = <f_w_bseg>-vbeln.

          CHECK sy-subrc = 0.

          v_vl_tot_compensar = <f_w_comissao>-vcom / v_qtd_parcelas.

          v_qtd_parcelas = v_qtd_parcelas - <f_w_bseg>-parc.

*         Verifica se só tem 1 parcela
          IF v_qtd_parcelas IS INITIAL.
            <f_w_comissao>-vcomp = ( <f_w_comissao>-vcom  / <f_w_bseg>-parc ).
          ELSE.

*           Subtrai o valor da parcela já paga
            DO v_qtd_parcelas TIMES.
*             Valor Compensar = ( Valor total da comissão - Valor já pago ) /  Quantidade de parcelas que faltam serem pagas
              <f_w_comissao>-vcomp = ( <f_w_comissao>-vcom  - v_vl_tot_compensar ) / <f_w_bseg>-parc.
            ENDDO.
          ENDIF.

*         Quantidade total de parcelas pagas
          SELECT COUNT( * )
           FROM bseg
           INTO v_qtd_parcelas_pagas
           WHERE vbeln = <f_w_bseg>-vbeln
             AND augbl <> space.

          IF sy-subrc = 0.
*           Valor compensado
            <f_w_comissao>-vcopd = v_vl_tot_compensar * v_qtd_parcelas_pagas.
          ENDIF.

          MODIFY im_t_comissao FROM <f_w_comissao> INDEX v_indice.
        ENDIF.
      ENDIF.
*   Se não encontrar parcelas, elimina da exibição (ALV)
    ELSE.
      DELETE im_t_comissao INDEX v_indice.
    ENDIF.
  ENDLOOP.

  IF im_t_comissao IS INITIAL.
    MESSAGE e001(zsdr033) INTO v_msg_erro.
    RAISE EXCEPTION TYPE zcx_comissao_vendas EXPORTING mensagem = v_msg_erro.
  ENDIF.

ENDMETHOD.
