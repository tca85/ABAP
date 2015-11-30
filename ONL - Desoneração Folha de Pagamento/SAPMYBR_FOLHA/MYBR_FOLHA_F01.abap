*&---------------------------------------------------------------------*
*&  Include           MYBR_FOLHA_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  f_verificar_data_informada
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_verificar_data_informada.
  DATA: vl_qtd_dias TYPE i.

  FREE r_data.

  IF ybr_folha_1000-dt_doc_de IS NOT INITIAL.
    wl_data-option = 'EQ'                    . " Equal
    wl_data-sign   = 'I'                     . " Include
    wl_data-low    = ybr_folha_1000-dt_doc_de.
    APPEND wl_data TO r_data                 .
  ELSE.
    CHECK ok_code = 'BTN_BUSCA_DADOS'.
    MESSAGE 'Informe a data inicial'(015) TYPE 'E'.
  ENDIF.

  IF ybr_folha_1000-dt_doc_ate IS NOT INITIAL.
    CALL FUNCTION 'HR_99S_INTERVAL_BETWEEN_DATES'
      EXPORTING
        begda = ybr_folha_1000-dt_doc_de
        endda = ybr_folha_1000-dt_doc_ate
      IMPORTING
        days  = vl_qtd_dias.

    IF vl_qtd_dias < 0.
      MESSAGE 'Data até do documento possui um valor inválido'(002)
      TYPE 'E'.
    ELSE.
      IF vl_qtd_dias > 31.
        MESSAGE 'Período informado não pode ser superior a 1 mês'(003)
        TYPE 'E'.
      ELSE.
        FREE r_data.
        wl_data-sign   = 'I'                      . " Include
        wl_data-option = 'BT'                     . " Between
        wl_data-low    = ybr_folha_1000-dt_doc_de .
        wl_data-high   = ybr_folha_1000-dt_doc_ate.
        APPEND wl_data TO r_data                  .
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_verificar_data_informada

*&---------------------------------------------------------------------*
*&      Form  f_verificar_inss_empresa
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_verificar_inss_empresa.
  CASE ok_code.
    WHEN 'BACK' OR 'LEAVE' OR 'CANCEL' OR 'BTN_NOVO'
         OR 'BTN_ALV_VEND_TOT' OR 'BTN_ALV_REVEND'.
      EXIT.
    WHEN 'BTN_WEB_INSS'.
      PERFORM f_obter_webservice_inss_rh.
  ENDCASE.

  IF ybr_folha_1000-inss_emp IS INITIAL.
    MESSAGE 'Informe o valor do INSS parte empresa'(004)
    TYPE 'E'.
  ELSE.
    vl_inss_emp = ybr_folha_1000-inss_emp.
  ENDIF.
ENDFORM.                    " f_verificar_inss_empresa

*&---------------------------------------------------------------------*
*&      Form  f_buscar_dados
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_buscar_dados.
  READ TABLE tl_botoes
  INTO wl_botoes
  WITH KEY busc = 'X'.

  IF sy-subrc = 0.
    EXIT.
  ENDIF.

  PERFORM: f_limpar_variaveis_e_tabelas  ,
           f_selecionar_cfop             ,
           f_selecionar_ncm              ,
           f_selecionar_notas_autorizadas,
           f_selecionar_itens_notas      .

  IF tl_j_1bnflin IS NOT INITIAL.
    PERFORM: f_progress_indicator      ,
             f_selecionar_impostos_item,
             f_selecionar_textos       ,
             f_preparar_tab_final      .

    wl_botoes-busc = 'X'         .
    APPEND wl_botoes TO tl_botoes.

*   Carrega a tela 1001 com os dados do Brasil Maior
    vl_tela = c_tela_br_maior.
  ELSE.
    MESSAGE 'Nenhum registro encontrado.'(005)
    TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF. " IF tl_j_1bnflin IS NOT INITIAL.
ENDFORM.                    " f_buscar_dados

*&---------------------------------------------------------------------*
*&      Form  f_limpar_variaveis_e_tabelas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_limpar_variaveis_e_tabelas.
  FREE: tl_j_1bnfdoc, tl_j_1bnflin, tl_j_1bnfstx, tl_j_1bnfnad, tl_lfa1,
        tl_transport, tl_kna1, tl_makt, tl_t023, tl_botoes, tl_sped,
        tl_cfop, tl_ncm, tl_resultado, tl_alv_vend_tot, tl_alv_ncm_det,
        tl_alv_revendas, tl_alv_rev_tot, tl_alv_notas, tl_fcode,
        tl_notas_outros, tl_notas_vendas.

  CLEAR: wl_j_1bnfdoc, wl_j_1bnflin, wl_j_1bnfstx, wl_j_1bnfnad, wl_lfa1,
         wl_transport, wl_kna1, wl_makt, wl_t023, wl_botoes, wl_sped, wl_cfop,
         wl_ncm, wl_nota, wl_data, wl_cfop_range, wl_ncm_range,
         wl_alv_vend_tot, wl_alv_ncm_det, wl_alv_revendas, wl_alv_rev_tot,
         wl_alv_notas, wl_resultado, wl_fcode.

  CLEAR: vl_titulo, vl_inss_emp, vl_total_vendas, vl_brmaior,
         vl_total_revendas_outros.

  CLEAR: ybr_folha_1000-inss_pagar    ,
         ybr_folha_1000-inss_emp      ,
         ybr_folha_1000-tot_cont_prev ,
         ybr_folha_1000-ganho         ,
         ybr_folha_1000-ganho_perc    .
ENDFORM.                    "f_limpar_variaveis_e_tabelas

*&---------------------------------------------------------------------*
*&      Form  f_selecionar_cfop
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_selecionar_cfop.

* Seleciona os CFOPs cadastrados
  SELECT mandt cfop tipo
   FROM ybr_folha_cfop
   INTO TABLE tl_cfop.

  LOOP AT tl_cfop INTO wl_cfop.
    IF wl_cfop-tipo = c_cfop_vendas.
      wl_cfop_range-sign   = 'I'           .
      wl_cfop_range-option = 'EQ'          .
      wl_cfop_range-low    = wl_cfop-cfop  .
      APPEND wl_cfop_range TO r_cfop_vendas.
    ELSE.
      wl_cfop_range-sign   = 'I'           .
      wl_cfop_range-option = 'EQ'          .
      wl_cfop_range-low    = wl_cfop-cfop  .
      APPEND wl_cfop_range TO r_cfop_outros.
    ENDIF.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM: r_cfop_vendas,
                                   r_cfop_outros.
ENDFORM.                    "f_selecionar_cfop

*&---------------------------------------------------------------------*
*&      Form  f_selecionar_ncm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_selecionar_ncm.

* Seleciona os NCMs cadastrados
  SELECT mandt bukrs steuc
   FROM ybr_folha_ncm
   INTO TABLE tl_ncm
   WHERE bukrs = ybr_folha_1000-empresa.

  LOOP AT tl_ncm INTO wl_ncm.
    wl_ncm_range-sign   = 'I'         .
    wl_ncm_range-option = 'EQ'        .
    wl_ncm_range-low    = wl_ncm-steuc.
    APPEND wl_ncm_range TO r_ncm      .
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM r_ncm.
ENDFORM.                    "f_selecionar_ncm

*&---------------------------------------------------------------------*
*&      Form  f_selecionar_notas_autorizadas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_selecionar_notas_autorizadas.
* Seleciona as notas fiscais de saída que foram autorizadas
* de acordo com a empresa, data e os CFOPs cadastrados na YBR_FOLHA_CFOP

* Notas fiscais de Vendas
  SELECT nota~docnum nota~nfnum  nota~series nota~parid  nota~bukrs
         nota~branch nota~pstdat nota~nftype nota~printd nota~cancel
         nota~direct nota~nfenum nota~model  nota~inco1  item~cfop
   INTO TABLE tl_j_1bnfdoc_vendas
   FROM j_1bnfdoc AS nota
    INNER JOIN j_1bnflin AS item ON nota~docnum = item~docnum
    WHERE nota~bukrs = ybr_folha_1000-empresa
      AND nota~direct  EQ c_mvto_saida      " 2
      AND nota~docdat  IN r_data
      AND nota~docstat EQ c_autorizada      " 1
      AND nota~code    EQ c_stat_autorizado " 100 / Autorizado o uso da NF-e
      AND item~cfop    IN r_cfop_vendas.                    " Tipo 1

* Notas fiscais de Revendas/Outros
  SELECT nota~docnum nota~nfnum  nota~series nota~parid  nota~bukrs
         nota~branch nota~pstdat nota~nftype nota~printd nota~cancel
         nota~direct nota~nfenum nota~model  nota~inco1  item~cfop
   INTO TABLE tl_j_1bnfdoc_outros
   FROM j_1bnfdoc AS nota
    INNER JOIN j_1bnflin AS item ON nota~docnum = item~docnum
    WHERE nota~bukrs = ybr_folha_1000-empresa
      AND nota~direct  EQ c_mvto_saida      " 2
      AND nota~docdat  IN r_data
      AND nota~docstat EQ c_autorizada      " 1
      AND nota~code    EQ c_stat_autorizado " 100 / Autorizado o uso da NF-e
      AND item~cfop    IN r_cfop_outros.                    " Tipo 2

  SORT: tl_j_1bnfdoc_vendas BY docnum ASCENDING,
        tl_j_1bnfdoc_outros BY docnum ASCENDING.

  DELETE ADJACENT DUPLICATES FROM: tl_j_1bnfdoc_vendas COMPARING docnum,
                                   tl_j_1bnfdoc_outros COMPARING docnum.

ENDFORM.                    "f_selecionar_notas_autorizadas

*&---------------------------------------------------------------------*
*&      Form  f_selecionar_itens_notas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_selecionar_itens_notas.
* Item da nota fiscal de acordo com o CFOP e NCM cadastrados
* nas tabelas ybr_folha_cfop e ybr_folha_ncm

* Itens das Notas Fiscais de Vendas
  IF tl_j_1bnfdoc_vendas IS NOT INITIAL.
    SELECT docnum itmnum matkl matnr maktx nbm menge netwr
           netpr nfpri netdis nfnett cfop taxsi4 taxsi5
     FROM j_1bnflin
     INTO TABLE tl_j_1bnflin_vendas
      FOR ALL ENTRIES IN tl_j_1bnfdoc_vendas
       WHERE docnum EQ tl_j_1bnfdoc_vendas-docnum
         AND cfop   IN r_cfop_vendas.
*         AND nbm    IN r_ncm.

*   Tratamento para evitar dump devido ao range de NCM possuir 5.000 registros
    DELETE tl_j_1bnflin_vendas
     WHERE nbm NOT IN r_ncm.
  ENDIF.

* Itens das Notas Fiscais de Revendas/Outros
  IF tl_j_1bnfdoc_outros IS NOT INITIAL.
    SELECT docnum itmnum matkl matnr maktx nbm menge netwr
           netpr nfpri netdis nfnett cfop taxsi4 taxsi5
     FROM j_1bnflin
     INTO TABLE tl_j_1bnflin_outros
      FOR ALL ENTRIES IN tl_j_1bnfdoc_outros
       WHERE docnum EQ tl_j_1bnfdoc_outros-docnum
         AND cfop   IN r_cfop_outros.
  ENDIF.

  SORT: tl_j_1bnflin_vendas BY docnum itmnum ASCENDING,
        tl_j_1bnflin_outros BY docnum itmnum ASCENDING.

  DELETE ADJACENT DUPLICATES FROM: tl_j_1bnflin_vendas COMPARING ALL FIELDS,
                                   tl_j_1bnflin_outros COMPARING ALL FIELDS.

  LOOP AT tl_j_1bnflin_vendas INTO wl_j_1bnflin_vendas.
    wl_j_1bnflin_vendas-tp_cfop = c_cfop_vendas.
    APPEND wl_j_1bnflin_vendas TO tl_j_1bnflin.

    READ TABLE  tl_j_1bnfdoc_vendas
    INTO wl_j_1bnfdoc_vendas
    WITH KEY docnum = wl_j_1bnflin_vendas-docnum.

    IF sy-subrc = 0.
      wl_j_1bnfdoc_vendas-tp_cfop = c_cfop_vendas.
      APPEND wl_j_1bnfdoc_vendas TO tl_j_1bnfdoc.
    ENDIF.
  ENDLOOP.

  LOOP AT tl_j_1bnflin_outros INTO wl_j_1bnflin_outros.
    wl_j_1bnflin_outros-tp_cfop = c_cfop_outros.
    APPEND wl_j_1bnflin_outros TO tl_j_1bnflin.

    READ TABLE  tl_j_1bnfdoc_outros
    INTO wl_j_1bnfdoc_outros
    WITH KEY docnum = wl_j_1bnflin_outros-docnum.

    IF sy-subrc = 0.
      wl_j_1bnfdoc_outros-tp_cfop = c_cfop_outros.
      APPEND wl_j_1bnfdoc_outros TO tl_j_1bnfdoc.
    ENDIF.
  ENDLOOP.

  SORT tl_j_1bnfdoc BY docnum.
  DELETE ADJACENT DUPLICATES FROM tl_j_1bnfdoc COMPARING ALL FIELDS.
  SORT tl_j_1bnfdoc BY docnum ASCENDING.

ENDFORM.                    "f_selecionar_itens_notas

*&---------------------------------------------------------------------*
*&      Form  f_progress_indicator
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_progress_indicator.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = 'Aguarde, processando...'(006)
    EXCEPTIONS
      OTHERS = 1.
ENDFORM.                    "f_progress_indicator

*&---------------------------------------------------------------------*
*&      Form  f_selecionar_impostos_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_selecionar_impostos_item.

* Imposto por item
  SELECT docnum itmnum rate taxtyp taxval base excbas othbas
   FROM j_1bnfstx
   INTO TABLE tl_j_1bnfstx
    FOR ALL ENTRIES IN tl_j_1bnflin
    WHERE docnum = tl_j_1bnflin-docnum
      AND itmnum = tl_j_1bnflin-itmnum.
ENDFORM.                    "f_selecionar_impostos_item

*&---------------------------------------------------------------------*
*&      Form  f_selecionar_textos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_selecionar_textos.

* Nome do parceiro da nota fiscal
  SELECT docnum parvw parid
   FROM j_1bnfnad
   INTO TABLE tl_j_1bnfnad
    FOR ALL ENTRIES IN tl_j_1bnfdoc
    WHERE docnum = tl_j_1bnfdoc-docnum
      AND parvw IN (c_transportadora,  "SP
                    c_transp_aereo).   "CA

* Nome do fornecedor
  SELECT lifnr name1 regio
   FROM lfa1
   INTO TABLE tl_lfa1
    FOR ALL ENTRIES IN tl_j_1bnfdoc
    WHERE lifnr = tl_j_1bnfdoc-parid.

* Nome do cliente
  SELECT kunnr name1 regio
   FROM kna1
   INTO TABLE tl_kna1
    FOR ALL ENTRIES IN tl_j_1bnfdoc
    WHERE kunnr = tl_j_1bnfdoc-parid.

* Nome da transportadora
  SELECT lifnr name1 regio
   FROM lfa1
   INTO TABLE tl_transport
    FOR ALL ENTRIES IN tl_j_1bnfnad
    WHERE lifnr = tl_j_1bnfnad-parid.

* Nome do material
  SELECT matnr spras maktx maktg
   FROM makt
   INTO TABLE tl_makt
    FOR ALL ENTRIES IN tl_j_1bnflin
    WHERE matnr = tl_j_1bnflin-matnr
      AND spras = c_pt_br. " PT

* Nome do grupo de mercadoria
  SELECT matkl wgbez60
   FROM t023t
   INTO TABLE tl_t023
    FOR ALL ENTRIES IN tl_j_1bnflin
    WHERE matkl = tl_j_1bnflin-matkl.
ENDFORM.                    "f_selecionar_textos

*&---------------------------------------------------------------------*
*&      Form  f_preparar_tab_final
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_preparar_tab_final.
  DATA: tl_header_add TYPE STANDARD TABLE OF j_1bindoc WITH HEADER LINE,
        tl_partner    TYPE STANDARD TABLE OF j_1bnfnad WITH HEADER LINE,
        tl_item       TYPE STANDARD TABLE OF j_1bnflin WITH HEADER LINE,
        tl_item_add   TYPE STANDARD TABLE OF j_1binlin WITH HEADER LINE,
        tl_item_tax   TYPE STANDARD TABLE OF j_1bnfstx WITH HEADER LINE,
        tl_header_msg TYPE STANDARD TABLE OF j_1bnfftx WITH HEADER LINE,
        tl_refer_msg  TYPE STANDARD TABLE OF j_1bnfref WITH HEADER LINE.

  DATA: wl_j_1baj TYPE j_1baj   ,
        wl_header TYPE j_1bnfdoc.

  DATA: vl_indice_item      TYPE sy-tabix             ,
        vl_indice_imp       TYPE sy-tabix             ,
        vl_perc_desoneracao TYPE ybr_folha_param-valor,
        vl_desconto         TYPE j_1bnflin-netwr      ,
        vl_remove_icms      TYPE i                    ,
        vl_nf_num           TYPE c LENGTH 12          .

* Percentual de desconto da desoneração
  SELECT SINGLE valor
    FROM ybr_folha_param
    INTO (vl_perc_desoneracao)
    WHERE param = c_percentual_desonr " PERCEDESO
      AND bukrs = ybr_folha_1000-empresa.

* Converter o campo texto para moeda
  CALL FUNCTION 'CHAR_FLTP_CONVERSION'
    EXPORTING
      string = vl_perc_desoneracao
    IMPORTING
      flstr  = vl_desconto
    EXCEPTIONS
      OTHERS = 5.

  vl_desconto = vl_desconto / 100.

* Verifica se deve excluir o ICMS
  SELECT COUNT( DISTINCT param )
    FROM ybr_folha_param
    INTO (vl_remove_icms)
    WHERE bukrs = ybr_folha_1000-empresa
      AND param = c_excluir_icms. " EXCICMS

  SORT: tl_j_1bnfdoc BY docnum,
        tl_j_1bnflin BY docnum.

  LOOP AT tl_j_1bnfdoc INTO wl_j_1bnfdoc.

    CLEAR wl_nota.
    READ TABLE tl_j_1bnflin
    TRANSPORTING NO FIELDS
    WITH KEY docnum = wl_j_1bnfdoc-docnum
    BINARY SEARCH.

    vl_indice_item = sy-tabix.

    LOOP AT tl_j_1bnflin INTO wl_j_1bnflin FROM vl_indice_item.
      IF wl_j_1bnflin-docnum NE wl_j_1bnfdoc-docnum.
        EXIT.
      ENDIF.

      FREE: tl_header_add, tl_partner, tl_item, tl_item_add,
            tl_item_tax, tl_header_msg, tl_refer_msg.

      CLEAR: wl_header, vl_nf_num.

      IF wl_j_1bnfdoc-nfnum IS NOT INITIAL.
        CONCATENATE wl_j_1bnfdoc-nfnum
                    wl_j_1bnfdoc-series
               INTO vl_nf_num.
      ELSE.
        CONCATENATE wl_j_1bnfdoc-nfenum
                    wl_j_1bnfdoc-series
               INTO vl_nf_num.
      ENDIF.

      wl_nota-docnum = wl_j_1bnfdoc-docnum. " Nº Interno NF
      wl_nota-itmnum = wl_j_1bnflin-itmnum. " Item NF
      wl_nota-nnf    = vl_nf_num          . " Nº NF
      wl_nota-model  = wl_j_1bnfdoc-model . " Modelo
      wl_nota-direct = wl_j_1bnfdoc-direct. " Ent/Sai
      wl_nota-parid  = wl_j_1bnfdoc-parid . " Código Cliente/Fornecedor
      wl_nota-bukrs  = wl_j_1bnfdoc-bukrs . " Empresa
      wl_nota-branch = wl_j_1bnfdoc-branch. " Filial
      wl_nota-cfop   = wl_j_1bnflin-cfop  . " CFOP
      wl_nota-taxsi4 = wl_j_1bnflin-taxsi4. " CST COFINS
      wl_nota-taxsi5 = wl_j_1bnflin-taxsi5. " CST PIS
      wl_nota-matnr  = wl_j_1bnflin-matnr . " Nº do material
      wl_nota-nbm    = wl_j_1bnflin-nbm   . " Código de controle (NCM)
      wl_nota-menge  = wl_j_1bnflin-menge . " Quantidade
      wl_nota-netpr  = wl_j_1bnflin-netpr . " Preço líquido
      wl_nota-netwr  = wl_j_1bnflin-netwr . " Valor líquido
      wl_nota-pstdat = wl_j_1bnfdoc-pstdat. " Dt. Emissão
      wl_nota-inco1  = wl_j_1bnfdoc-inco1 . " CIF/FOB
      wl_nota-nfnett = wl_j_1bnflin-nfnett. " Total

*---------------------------------------------------------------------*
*     Seleciona o nome da transportadora                              *
*---------------------------------------------------------------------*
      CLEAR wl_j_1bnfnad.
      READ TABLE tl_j_1bnfnad
      INTO wl_j_1bnfnad
      WITH KEY docnum = wl_j_1bnfdoc-docnum.

      IF sy-subrc = 0.
        CLEAR wl_transport.
        READ TABLE tl_transport
        INTO wl_transport
        WITH KEY lifnr = wl_j_1bnfnad-parid. " " Identificação do parceiro

        IF sy-subrc = 0.
          wl_nota-transp = wl_transport-name1. " Transportadora
        ENDIF.
      ENDIF.

*---------------------------------------------------------------------*
*     Seleciona o nome do fornecedor / cliente                        *
*---------------------------------------------------------------------*
      CLEAR wl_lfa1.
      READ TABLE tl_lfa1
      INTO wl_lfa1
      WITH KEY lifnr = wl_j_1bnfdoc-parid.

      IF sy-subrc = 0.
        wl_nota-name1 = wl_lfa1-name1. " Desc. Fornecedor
        wl_nota-regio = wl_lfa1-regio. " Estado
      ELSE.
        CLEAR wl_kna1.
        READ TABLE tl_kna1
        INTO wl_kna1
        WITH KEY kunnr = wl_j_1bnfdoc-parid.

        IF sy-subrc = 0.
          wl_nota-name1 = wl_kna1-name1. " Desc. Cliente
          wl_nota-regio = wl_kna1-regio. " Estado
        ENDIF.
      ENDIF.

*---------------------------------------------------------------------*
*     Seleciona o nome do item                                        *
*---------------------------------------------------------------------*
      CLEAR wl_makt.
      READ TABLE tl_makt
      INTO wl_makt
      WITH KEY matnr = wl_j_1bnflin-matnr.

      IF sy-subrc = 0.
        wl_nota-maktx = wl_makt-maktx. " Descrição do material
      ENDIF.

*---------------------------------------------------------------------*
*     Seleciona os impostos do item                                   *
*---------------------------------------------------------------------*
      READ TABLE tl_j_1bnfstx
      TRANSPORTING NO FIELDS
      WITH KEY docnum = wl_j_1bnflin-docnum
               itmnum = wl_j_1bnflin-itmnum
      BINARY SEARCH.

      vl_indice_imp = sy-tabix.

      LOOP AT tl_j_1bnfstx INTO wl_j_1bnfstx FROM vl_indice_imp.
        IF    wl_j_1bnfstx-docnum NE wl_j_1bnflin-docnum
          AND wl_j_1bnfstx-itmnum NE wl_j_1bnflin-itmnum.
          EXIT.
        ENDIF.

        CLEAR wl_j_1baj.

        CALL FUNCTION 'J_1BAJ_READ'
          EXPORTING
            taxtype  = wl_j_1bnfstx-taxtyp
          IMPORTING
            e_j_1baj = wl_j_1baj
          EXCEPTIONS
            OTHERS   = 3.

        CASE wl_j_1baj-taxgrp. " Grupo de imposto
          WHEN c_grupo_pis. " PIS
            wl_nota-rate1   = wl_j_1bnfstx-rate  . " Aliquota PIS
            wl_nota-taxval1 = wl_j_1bnfstx-taxval. " Valor do PIS
            wl_nota-base1   = wl_j_1bnfstx-base  . " Valor Base PIS
            wl_nota-excbas1 = wl_j_1bnfstx-excbas. " Base Excl.PIS
            wl_nota-othbas1 = wl_j_1bnfstx-othbas. " Outra Base PIS

          WHEN c_grupo_cofins. " COFI
            wl_nota-rate2   = wl_j_1bnfstx-rate  . " Alíquota COFINS
            wl_nota-taxval2 = wl_j_1bnfstx-taxval. " Valor da COFINS
            wl_nota-base2   = wl_j_1bnfstx-base  . " Valor Base COFINS
            wl_nota-excbas2 = wl_j_1bnfstx-excbas. " Base Excl.COFINS
            wl_nota-othbas2 = wl_j_1bnfstx-othbas. " Outra Base COFINS

          WHEN c_grupo_ipi. " IPI
            wl_nota-rate3   = wl_j_1bnfstx-rate  . " Alíquota IPI
            wl_nota-taxval3 = wl_j_1bnfstx-taxval. " Valor da IPI
            wl_nota-base3   = wl_j_1bnfstx-base  . " Valor Base IPI
            wl_nota-excbas3 = wl_j_1bnfstx-excbas. " Base Excl.IPI
            wl_nota-othbas3 = wl_j_1bnfstx-othbas. " Outra Base IPI

          WHEN c_grupo_icms. " ICMS
            IF wl_j_1bnfstx-taxtyp = c_icms_zn_franca. " ICZF
              wl_nota-rate6   = wl_j_1bnfstx-rate  . " Alíquota ICMS ZF
              wl_nota-taxval6 = wl_j_1bnfstx-taxval. " Valor da ICMS ZF
              wl_nota-base6   = wl_j_1bnfstx-base  . " Valor da ICMS ZF
              wl_nota-excbas6 = wl_j_1bnfstx-excbas. " Base Excl.ICMS ZF
              wl_nota-othbas6 = wl_j_1bnfstx-othbas. " Outra Base ICMS ZF
            ELSE.
              wl_nota-rate4   = wl_j_1bnfstx-rate  . " Alíquota ICMS
              wl_nota-taxval4 = wl_j_1bnfstx-taxval. " Valor da ICMS
              wl_nota-base4   = wl_j_1bnfstx-base  . " Valor Base ICMS
              wl_nota-excbas4 = wl_j_1bnfstx-excbas. " Base Excl.ICMS
              wl_nota-othbas4 = wl_j_1bnfstx-othbas. " Outra Base.ICMS
            ENDIF.

          WHEN c_grupo_icms_st. " ICST
            wl_nota-rate5   = wl_j_1bnfstx-rate  . " Aliquota ICMS ST
            wl_nota-taxval5 = wl_j_1bnfstx-taxval. " Valor da ICMS ZF
            wl_nota-base5   = wl_j_1bnfstx-base  . " Valor Base ICMS ZF
            wl_nota-excbas5 = wl_j_1bnfstx-excbas. " Base Excl.ICMS ZF
            wl_nota-othbas5 = wl_j_1bnfstx-othbas. " Outra Base ICMS ZF
        ENDCASE. " CASE wl_j_1baj-taxgrp.
      ENDLOOP. " LOOP AT tl_j_1bnfstx INTO wl_j_1bnfstx

*---------------------------------------------------------------------*
*     Verifica o tipo de CFOP e NCM do item                           *
*---------------------------------------------------------------------*

      CLEAR wl_cfop.
      READ TABLE tl_cfop
      INTO wl_cfop
      WITH KEY cfop = wl_nota-cfop.

      CLEAR wl_ncm.
      READ TABLE tl_ncm
      INTO wl_ncm
      WITH KEY steuc = wl_j_1bnflin-nbm.

      IF wl_j_1bnflin-tp_cfop = c_cfop_vendas. " 1 = c_cfop_vendas.
        CHECK wl_ncm-steuc(10) = wl_j_1bnflin-nbm(10).


*       Se existir o parâmetro EXCICMS na YBR_FOLHA_PARAM deverá excluir
*       o ICMS no cálculo do Brasil Maior
        IF vl_remove_icms = 0. " Não encontrou na tabela
          wl_alv_vend_tot-brmaior = wl_j_1bnflin-netwr  + " Valor Total
                                    wl_j_1bnflin-netdis - " Desconto
                                    wl_nota-taxval4.      " ICMS
        ELSE.
          wl_alv_vend_tot-brmaior = wl_j_1bnflin-netwr + " Valor Total
                                    wl_j_1bnflin-netdis. " Desconto
        ENDIF.

        READ TABLE tl_notas_vendas
        TRANSPORTING NO FIELDS
        WITH KEY docnum = wl_j_1bnfdoc-docnum
                 itmnum = wl_j_1bnflin-itmnum
                 nbm    = wl_j_1bnflin-nbm
                 cfop   = wl_j_1bnflin-cfop.

*       Se a nota não existir na tabela, insere
        IF sy-subrc <> 0.
          wl_alv_vend_tot-bukrs    = wl_nota-bukrs                        .
          wl_alv_vend_tot-ncm      = wl_nota-nbm                          .
          wl_alv_vend_tot-vlrcontr = wl_alv_vend_tot-brmaior * vl_desconto.
          COLLECT wl_alv_vend_tot INTO tl_alv_vend_tot.

          vl_total_vendas = vl_total_vendas + wl_alv_vend_tot-brmaior.

          wl_alv_ncm_det-bukrs    = wl_alv_vend_tot-bukrs   .
          wl_alv_ncm_det-ncm      = wl_alv_vend_tot-ncm     .
          wl_alv_ncm_det-brmaior  = wl_alv_vend_tot-brmaior .
          wl_alv_ncm_det-vlrcontr = wl_alv_vend_tot-vlrcontr.
          APPEND wl_alv_ncm_det TO tl_alv_ncm_det           .

          wl_nota-brmaior  = wl_alv_vend_tot-brmaior      . " Valor Brasil Maior
          wl_nota-vlrcontr = wl_nota-brmaior * vl_desconto. " Valor Contribuição
          APPEND wl_nota TO tl_notas_vendas.
        ENDIF.

      ELSEIF wl_j_1bnflin-tp_cfop = c_cfop_outros. " 2

*       Verifica se o CFOP além do tipo 'Revenda/Outros'
*       é de 'Vendas' também
        CLEAR wl_cfop.
        READ TABLE tl_cfop
        INTO wl_cfop
        WITH KEY cfop = wl_nota-cfop
                 tipo = c_cfop_vendas. " 1

*       Se o CFOP for dos dois tipos e o NCM estiver diferente, sai da rotina
        IF sy-subrc = 0.
          CHECK wl_ncm-steuc(10) <> wl_j_1bnflin-nbm(10).
        ENDIF.

        IF vl_remove_icms = 0. " Não encontrou na tabela
          wl_alv_rev_tot-brmaior = wl_j_1bnflin-netwr  + " Valor Total
                                   wl_j_1bnflin-netdis - " Desconto
                                   wl_nota-taxval4.      " ICMS
        ELSE.
          wl_alv_rev_tot-brmaior = wl_j_1bnflin-netwr + " Valor Total
                                   wl_j_1bnflin-netdis. " Desconto
        ENDIF.

        READ TABLE tl_notas_outros
        TRANSPORTING NO FIELDS
        WITH KEY docnum = wl_j_1bnfdoc-docnum
                 itmnum = wl_j_1bnflin-itmnum
                 nbm    = wl_j_1bnflin-nbm
                 cfop   = wl_j_1bnflin-cfop.

*       Se a nota não existir na tabela, insere
        IF sy-subrc <> 0.
          wl_alv_rev_tot-bukrs    = wl_nota-bukrs                       .
          wl_alv_rev_tot-ncm      = wl_nota-nbm                         .
          wl_alv_rev_tot-vlrcontr = wl_alv_rev_tot-brmaior * vl_desconto.
          COLLECT wl_alv_rev_tot INTO tl_alv_rev_tot                    .

          wl_alv_revendas-bukrs    = wl_alv_rev_tot-bukrs   .
          wl_alv_revendas-ncm      = wl_alv_rev_tot-ncm     .
          wl_alv_revendas-brmaior  = wl_alv_rev_tot-brmaior .
          wl_alv_revendas-vlrcontr = wl_alv_rev_tot-vlrcontr.
          APPEND wl_alv_revendas TO tl_alv_revendas         .

          vl_total_revendas_outros = vl_total_revendas_outros + wl_alv_rev_tot-brmaior.

          wl_nota-brmaior  = wl_alv_rev_tot-brmaior       .  " Valor Brasil Maior
          wl_nota-vlrcontr = wl_nota-brmaior * vl_desconto.  " Valor Contribuição
          APPEND wl_nota TO tl_notas_outros.
        ENDIF.

      ENDIF.

    ENDLOOP. " LOOP AT tl_j_1bnflin INTO wl_j_1bnflin FROM vl_indice.
  ENDLOOP. "  LOOP AT tl_j_1bnfdoc INTO wl_j_1bnfdoc.

  vl_brmaior = vl_total_vendas * vl_desconto.

  ybr_folha_1000-vend_totais = vl_total_vendas         .
  ybr_folha_1000-revend_outr = vl_total_revendas_outros.
  ybr_folha_1000-br_maior_pg = vl_brmaior              .

  SORT: tl_notas_vendas BY nbm docnum itmnum ASCENDING,
        tl_notas_outros BY nbm docnum itmnum ASCENDING.

  DELETE ADJACENT DUPLICATES FROM:
          tl_notas_vendas COMPARING ALL FIELDS,
          tl_notas_outros COMPARING ALL FIELDS.
ENDFORM.                    "f_preparar_tab_final

*&---------------------------------------------------------------------*
*&      Form  f_exibir_alv_total_ncm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_exibir_alv_total_ncm.
  CLEAR: vl_titulo, vl_tela_alv.

  vl_titulo = 'Total de vendas por código de controle (NCM)'(019).

  IF tl_alv_vend_tot IS NOT INITIAL.
    SORT tl_alv_vend_tot BY ncm ASCENDING.

*   Exclui o botão 'Novo' da barra de status
    wl_fcode = 'BTN_NOVO'.
    APPEND wl_fcode TO tl_fcode.

    PERFORM f_montar_fieldcatalog
     TABLES tl_fieldcat
      USING wl_fieldcat
            c_alv_vend_tot " YALV_VENDTOT
            'X'.

    PERFORM f_montar_alv
      USING obj_container
            obj_alv_grid
            c_cont_alv_vend_tot " CONT_ALV_VEND_TOT
            tl_fieldcat
            tl_alv_vend_tot
            vl_titulo
            space.

    vl_tela_alv = c_tela_alv_vendas.

*   Total por código de controle (NCM)
    CALL SCREEN vl_tela_alv.

  ELSE.
    MESSAGE 'Não há total de vendas por NCM'(016) TYPE 'W'.

  ENDIF.
ENDFORM.                    "f_exibir_alv_total_ncm

*&---------------------------------------------------------------------*
*&      Form  f_exibir_alv_total_revendas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_exibir_alv_total_revendas.
  CLEAR: vl_titulo, vl_tela_alv.

  vl_titulo = 'Total de revendas/outros por código de controle (NCM)'(018).

  IF tl_alv_rev_tot IS NOT INITIAL.
    SORT tl_alv_rev_tot BY ncm ASCENDING.

*   Exclui o botão 'Novo' da barra de status
    wl_fcode = 'BTN_NOVO'.
    APPEND wl_fcode TO tl_fcode.

    PERFORM f_montar_fieldcatalog
     TABLES tl_fieldcat
      USING wl_fieldcat
            c_alv_vend_tot " YALV_VENDTOT
            'X'.

    PERFORM f_montar_alv
      USING obj_container
            obj_alv_grid
            c_cont_alv_revend " CONT_ALV_REVEND
            tl_fieldcat
            tl_alv_rev_tot
            vl_titulo
            space.

    vl_tela_alv = c_tela_alv_revendas.

*   Total por revenda/outros
    CALL SCREEN vl_tela_alv.

  ELSE.
    MESSAGE 'Não há total de revendas/outros por NCM'(017) TYPE 'W'.
  ENDIF.
ENDFORM.                    "f_exibir_alv_total_revendas

*&---------------------------------------------------------------------*
*&      Form  event_hotspot_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ROW      text
*      -->P_COLUMN   text
*----------------------------------------------------------------------*
FORM event_hotspot_click
 USING p_row    TYPE lvc_s_row
       p_column TYPE lvc_s_col.

  CASE p_column.
    WHEN c_hotspot_ncm.

*     Total de vendas por NCM
      IF vl_tela_alv = c_tela_alv_vendas.
        CLEAR wl_alv_vend_tot.
        READ TABLE tl_alv_vend_tot
        INTO wl_alv_vend_tot
        INDEX p_row-index.

*       Exibe todas notas com impostos de acordo com o NCM selecionado
        PERFORM f_exibir_alv_todas_notas
         TABLES tl_notas_vendas
         USING wl_alv_vend_tot-ncm.

*     Total de revendas/outros por NCM
      ELSEIF vl_tela_alv = c_tela_alv_revendas.
        CLEAR wl_alv_rev_tot.
        READ TABLE tl_alv_rev_tot
        INTO wl_alv_rev_tot
        INDEX p_row-index.

*       Exibe todas notas com impostos de acordo com o NCM selecionado
        PERFORM f_exibir_alv_todas_notas
         TABLES tl_notas_outros
         USING wl_alv_rev_tot-ncm.
      ENDIF.

    WHEN c_hotspot_docnum.
      CLEAR wl_alv_notas.
      READ TABLE tl_alv_notas
      INTO wl_alv_notas
      INDEX p_row-index.

      PERFORM f_exibir_nota_fiscal
       USING wl_alv_notas-docnum.
  ENDCASE.
ENDFORM.                    "event_hotspot_click

*&---------------------------------------------------------------------*
*&      Form  f_exibir_alv_todas_notas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TODAS_NOTAS  text
*      -->YALV_DOC_NCM   text
*      -->P_NCM          text
*----------------------------------------------------------------------*
FORM f_exibir_alv_todas_notas
 TABLES p_todas_notas STRUCTURE yalv_doc_ncm
  USING p_ncm TYPE yalv_vendtot-ncm.

  DATA: vl_linha_ncm TYPE sy-tabix.

  FREE: tl_alv_notas, wl_alv_notas.

  CLEAR: vl_titulo.
  vl_titulo = 'Notas fiscais com todos impostos de acordo com o NCM'(020).

  SORT p_todas_notas BY nbm ASCENDING.

  tl_alv_notas[] = p_todas_notas[].
  DELETE tl_alv_notas WHERE nbm NE p_ncm.

  CHECK tl_alv_notas IS NOT INITIAL.

  SORT tl_alv_notas BY docnum itmnum nnf ASCENDING.

  PERFORM f_montar_fieldcatalog
   TABLES tl_fieldcat
    USING wl_fieldcat
          c_alv_notas_fiscais
          'X'.

  PERFORM f_montar_alv
    USING obj_container
          obj_alv_grid
          c_cont_alv_ncm_det " CONT_ALV_NCM_DET
          tl_fieldcat
          tl_alv_notas
          vl_titulo
          space.

* Notas fiscais com todos impostos de acordo com o NCM
  CALL SCREEN c_tela_alv_nfs.
ENDFORM.                    "f_exibir_alv_todas_notas

*&---------------------------------------------------------------------*
*&      Form  f_exibir_nota_fiscal
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DOCNUM   text
*----------------------------------------------------------------------*
FORM f_exibir_nota_fiscal
  USING p_docnum TYPE yalv_doc_ncm-docnum.

  SET PARAMETER ID 'JEF' FIELD p_docnum.
  CALL TRANSACTION c_j1b3n AND SKIP FIRST SCREEN.
ENDFORM.                    "f_exibir_nota_fiscal

*&---------------------------------------------------------------------*
*&      Form  f_montar_fieldcatalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TL_FCAT   text
*      -->P_WL_FCAT   text
*      -->P_STRUCTURE text
*      -->P_HOSTPOT   text
*----------------------------------------------------------------------*
FORM f_montar_fieldcatalog
  TABLES p_tl_fcat   TYPE lvc_t_fcat
   USING p_wl_fcat   TYPE lvc_s_fcat
         p_structure TYPE ddobjname
         p_hostpot   TYPE c .

  DATA: tl_campos TYPE STANDARD TABLE OF dd03p,
        wl_campos LIKE LINE OF tl_campos      .

  DATA: vl_campo       TYPE rollname       ,
        vl_nome_coluna TYPE dd04t-scrtext_m.

  CONSTANTS:
    c_versao_ativa TYPE ddobjstate VALUE 'A'.

  FREE: p_tl_fcat, p_wl_fcat.

* Obtém o nome dos campos da estrutura da SE11
  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name          = p_structure
      state         = c_versao_ativa
    TABLES
      dd03p_tab     = tl_campos
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  LOOP AT tl_campos INTO wl_campos.
    vl_campo = wl_campos-rollname.

*   Seleciona a descrição média do elemento de dados
    SELECT SINGLE scrtext_m
    FROM  dd04t
    INTO (vl_nome_coluna)
     WHERE rollname  = vl_campo
      AND ddlanguage = c_pt_br
      AND as4local   = c_versao_ativa.

    MOVE-CORRESPONDING wl_campos TO p_wl_fcat.
    p_wl_fcat-coltext = vl_nome_coluna.

    IF p_hostpot IS NOT INITIAL
      AND wl_campos-fieldname = c_hotspot_ncm
       OR wl_campos-fieldname = c_hotspot_docnum.
      p_wl_fcat-hotspot = 'X'.
    ENDIF.

    IF wl_campos-fieldname = 'BRMAIOR'.
      p_wl_fcat-do_sum = 'X'.
    ENDIF.

    APPEND p_wl_fcat TO p_tl_fcat.
    CLEAR p_wl_fcat.
  ENDLOOP.
ENDFORM.                    "f_montar_fieldcatalog

*&---------------------------------------------------------------------*
*&      Form  f_montar_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONTAINER text
*      -->P_ALV_GRID  text
*      -->P_NOME_CONT text
*      -->P_FIELDCAT  text
*      -->P_TL_ALV    text
*      -->P_TITULO    text
*      -->P_TOOLBAR   text
*----------------------------------------------------------------------*
FORM f_montar_alv
 USING p_container  TYPE REF TO cl_gui_custom_container
       p_alv_grid   TYPE REF TO cl_gui_alv_grid
       p_nome_cont  TYPE scrfname
       p_fieldcat   TYPE lvc_t_fcat
       p_tl_alv     TYPE STANDARD TABLE
       p_titulo     TYPE lvc_s_layo-grid_title
       p_no_toolbar TYPE c.

  IF p_container IS NOT INITIAL.
    p_container->free( ).
  ENDIF.

  CREATE OBJECT p_container
    EXPORTING
      container_name              = p_nome_cont
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

* Cria uma instância da classe cl_gui_alv_grid no custom container
* inserido no layout da tela
  CREATE OBJECT p_alv_grid
    EXPORTING
      i_parent          = p_container
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.

* Atribui os métodos da classe local lcl_evento_alv à do ALV
  DATA: o_evt TYPE REF TO lcl_evento_alv.
  CREATE OBJECT o_evt.
  SET HANDLER o_evt->hotspot_click FOR p_alv_grid.

  DATA: wl_alv_layout TYPE lvc_s_layo.
  wl_alv_layout-zebra      = 'X'     . " Zebrado
  wl_alv_layout-cwidth_opt = 'X'     . " Otimizar largura da coluna
  wl_alv_layout-grid_title = p_titulo. " Titulo do ALV

* Exclui os botões da barra de tarefas do ALV (Exportar p/ Excel)
  IF p_no_toolbar IS NOT INITIAL.
    wl_alv_layout-no_toolbar = p_no_toolbar.
  ENDIF.

  CALL METHOD p_alv_grid->set_table_for_first_display
    EXPORTING
      is_layout                     = wl_alv_layout
    CHANGING
      it_outtab                     = p_tl_alv
      it_fieldcatalog               = p_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  p_alv_grid->refresh_table_display( ).
ENDFORM.                    "f_montar_alv

*&---------------------------------------------------------------------*
*&      Form  f_calcular_inss_pagar
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_calcular_inss_pagar.
  DATA: vl_inss_pagar TYPE j_1bnflin-netwr,
        vl_tot_cont   TYPE j_1bnflin-netwr,
        vl_ganho      TYPE j_1bnflin-netwr,
        vl_percentual TYPE p DECIMALS 6   ,
        vl_ganho_perc TYPE j_1bnflin-netwr,
        vl_exception  TYPE string         .

  DATA: o_ex TYPE REF TO cx_root.

  TRY.
      vl_percentual = ( vl_total_revendas_outros /
                      ( vl_total_vendas + vl_total_revendas_outros ) ).

*     INSS a pagar
      vl_inss_pagar = vl_inss_emp * vl_percentual.

*     Total de Contribuição Previdenciária
      vl_tot_cont = vl_brmaior + vl_inss_pagar.

*     Ganho (INSS Parte Empresa - Total de Contribuição Previdenciária)
      vl_ganho = vl_inss_emp - vl_tot_cont.

*     Percentual de ganho
      vl_ganho_perc = ( ( vl_tot_cont /  vl_inss_emp ) - 1 ) * 100.

      ybr_folha_1000-inss_emp      = vl_inss_emp  .
      ybr_folha_1000-inss_pagar    = vl_inss_pagar.
      ybr_folha_1000-tot_cont_prev = vl_tot_cont  .
      ybr_folha_1000-ganho         = vl_ganho     .
      ybr_folha_1000-ganho_perc    = vl_ganho_perc.

      wl_botoes-calc = 'X'                   .
      MODIFY tl_botoes FROM wl_botoes INDEX 1.

    CATCH cx_root INTO o_ex.
      vl_exception = o_ex->get_text( ).

      MESSAGE vl_exception TYPE 'E'.
  ENDTRY.
ENDFORM.                    "f_calcular_inss_pagar

*&---------------------------------------------------------------------*
*&      Form  f_salvar_resultados
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_salvar_resultados.
  READ TABLE tl_botoes
  INTO wl_botoes
  WITH KEY calc = 'X'.

  IF sy-subrc <> 0.
    MESSAGE 'Realize o cálculo antes de salvar'(007)
    TYPE 'S' DISPLAY LIKE 'E'.
  ELSE.
    CLEAR wl_resultado.

    MOVE-CORRESPONDING ybr_folha_1000 TO wl_resultado.
    wl_resultado-mandt = sy-mandt.

*   Verifica se o valor do INSS foi obtido pelo WebService do RH
    READ TABLE tl_botoes
    INTO wl_botoes
    WITH KEY webs = 'X'.

    IF sy-subrc = 0.
      wl_resultado-webservice = 'X'.
    ENDIF.

    APPEND wl_resultado TO tl_resultado.
    MODIFY ybr_folha_result FROM TABLE tl_resultado.

    wl_botoes-salv = 'X'                   .
    MODIFY tl_botoes FROM wl_botoes INDEX 1.

    MESSAGE 'Dados salvos com sucesso na tabela YBR_FOLHA_RESULT'(014)
    TYPE 'S'.
  ENDIF.
ENDFORM.                    "f_salvar_resultados

*&---------------------------------------------------------------------*
*&      Form  f_imprimir_dados_gerados
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_imprimir_dados_gerados.
  READ TABLE tl_botoes
  INTO wl_botoes
  WITH KEY salv = 'X'.

  IF sy-subrc <> 0.
    MESSAGE 'Salve as informações antes de imprimir o relatório'(008)
    TYPE 'S' DISPLAY LIKE 'E'.
  ELSE.
    DATA:
      tl_res_aux LIKE yalv_brmaior OCCURS 0  WITH HEADER LINE,
      tl_mes     LIKE t247         OCCURS 12 WITH HEADER LINE.

    DATA:
      wl_control_parameters TYPE ssfctrlop,
      wl_output_options     TYPE ssfcompop.

    DATA:
      vl_nome_funcao   TYPE rs38l_fnam               ,
      vl_vend_revend   TYPE j_1bnflin-netwr          ,
      vl_perc_vend_tot TYPE j_1bnflin-netwr          ,
      vl_perc_revendas TYPE j_1bnflin-netwr          ,
      vl_mes_apuracao  TYPE yalv_brmaior-mes_apuracao.

*   Obter o nome da função do Smartform 'YBR_FOLHA'
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = c_smartform_folha "YBR_FOLHA
      IMPORTING
        fm_name            = vl_nome_funcao
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.

    CHECK vl_nome_funcao IS NOT INITIAL.

    CALL FUNCTION 'MONTH_NAMES_GET'
      EXPORTING
        language              = sy-langu
      TABLES
        month_names           = tl_mes
      EXCEPTIONS
        month_names_not_found = 1
        OTHERS                = 2.

*   Obtém o nome do mês para exibir no SmartForm
    READ TABLE tl_mes
    WITH KEY mnr = ybr_folha_1000-dt_doc_de+4(2).

    IF sy-subrc = 0.
      CONCATENATE tl_mes-ltx
                  ybr_folha_1000-dt_doc_de(4)
             INTO vl_mes_apuracao SEPARATED BY '/'.
    ENDIF.

    vl_vend_revend   = vl_total_vendas + vl_total_revendas_outros         .
    vl_perc_vend_tot = ( vl_total_vendas * 100 ) / vl_vend_revend         .
    vl_perc_revendas = ( vl_total_revendas_outros * 100 ) / vl_vend_revend.

    wl_control_parameters-device    = c_disp_saida_impres. " PRINTER
    wl_control_parameters-no_dialog = 'X'                .
    wl_control_parameters-preview   = 'X'                .

    wl_output_options-tddest  = c_impressora_local. " LOCL
    wl_output_options-tdimmed = 'X'               .

    LOOP AT tl_resultado INTO wl_resultado.
      MOVE-CORRESPONDING wl_resultado TO tl_res_aux.

      tl_res_aux-mes_apuracao  = vl_mes_apuracao .
      tl_res_aux-tot_vend_rev  = vl_vend_revend  .
      tl_res_aux-perc_vend_tot = vl_perc_vend_tot.
      tl_res_aux-perc_revend   = vl_perc_revendas.

      APPEND tl_res_aux.
    ENDLOOP.

*   Chamar a função /1BCDWB/SF00000033 para carregar o
*   SmartForm 'YBR_FOLHA'
    CALL FUNCTION vl_nome_funcao " /1BCDWB/SF00000033
    EXPORTING
        control_parameters = wl_control_parameters
        output_options     = wl_output_options
        user_settings      = 'X'
      TABLES
        resultado          = tl_res_aux
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    wl_botoes-impr        = 'X'.
    MODIFY tl_botoes FROM wl_botoes INDEX 1.
  ENDIF.
ENDFORM.                    "f_imprimir_dados_gerados

*&---------------------------------------------------------------------*
*&      Form  f_gerar_sped
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_gerar_sped.
  READ TABLE tl_botoes
  INTO wl_botoes
  WITH KEY impr = 'X'.

  IF sy-subrc <> 0.
    MESSAGE 'Imprima o relatório antes de gerar o SPED'(009)
    TYPE 'S' DISPLAY LIKE 'E'.
  ELSE.
    DATA:
      tl_filetable TYPE filetable,
      vl_filename  TYPE string   ,
      vl_rc        TYPE i        .

    LOOP AT tl_alv_vend_tot INTO wl_alv_vend_tot.
      wl_sped-fixo  = '|P110||00000003|'      .
      wl_sped-sep1  = '|'                     .
      wl_sped-ncm   = wl_alv_vend_tot-ncm     .
      wl_sped-valor = wl_alv_vend_tot-vlrcontr.
      wl_sped-sep2 = '||'                     .

*     Remover espaços dos campos
      CONDENSE: wl_sped-ncm   NO-GAPS,
                wl_sped-valor NO-GAPS.

      APPEND wl_sped TO tl_sped.
    ENDLOOP.

*  Janela para salvar o arquivo com extensão txt e com o nome fixo
    CALL METHOD cl_gui_frontend_services=>file_open_dialog
      EXPORTING
        default_extension = 'txt'
        default_filename  = 'SPED_Desoneracao.txt'
        file_filter       = '.txt'
      CHANGING
        file_table        = tl_filetable
        rc                = vl_rc.

    READ TABLE tl_filetable
    INTO vl_filename
    INDEX 1.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename = vl_filename
        filetype = 'ASC'
      CHANGING
        data_tab = tl_sped
      EXCEPTIONS
        OTHERS   = 24.

    wl_botoes-sped = 'X'                   .
    MODIFY tl_botoes FROM wl_botoes INDEX 1.
  ENDIF.
ENDFORM.                    "f_gerar_sped

*&---------------------------------------------------------------------*
*&      Form  f_novo_periodo_empresa
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_novo_periodo_empresa.
  DATA: vl_resposta TYPE c.

  READ TABLE tl_botoes
  INTO wl_botoes
  WITH KEY salv = 'X'
           sped = space.

* Se já mandou salvar, pergunta se quer finalizar o processo
  IF sy-subrc = 0.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Desoneração Folha Pagto'(010)
        text_question         = 'Deseja sair sem finalizar o processo todo?'(011)
        text_button_1         = 'Sim'(012)
        text_button_2         = 'Não'(013)
        display_cancel_button = ' '
      IMPORTING
        answer                = vl_resposta.

    IF vl_resposta = c_sim.
      FREE tl_botoes.

      wl_botoes-novo = 'X'         .
      APPEND wl_botoes TO tl_botoes.
    ELSE.
      CLEAR wl_botoes-novo.
      MODIFY tl_botoes FROM wl_botoes INDEX 1.
    ENDIF.
  ELSE.

*   Se ainda não mandou salvar, limpa a tela
    FREE tl_botoes.

    wl_botoes-novo = 'X'         .
    APPEND wl_botoes TO tl_botoes.
  ENDIF.
ENDFORM.                    "f_novo_periodo_empresa

*&---------------------------------------------------------------------*
*&      Form  f_bloquear_campos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_bloquear_campos.
  READ TABLE tl_botoes
  INTO wl_botoes
  INDEX 1.

* Desabilita os campos empresa, data do documento
* e o botão Buscar Dados
  IF wl_botoes-busc IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'GR0'.
        screen-input = c_desabilitar_campo.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Desabilita o botão Calcular
  IF wl_botoes-calc IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'GR1'.
        screen-input = c_desabilitar_campo.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Desabilita o botão 'Salvar'
  IF wl_botoes-salv IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'GR2'.
        screen-input = c_desabilitar_campo.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Desabilita o botão 'Imprimir'
  IF wl_botoes-impr IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'GR3'.
        screen-input = c_desabilitar_campo.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Desabilita o botão 'SPED'
  IF wl_botoes-sped IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'GR4'.
        screen-input = c_desabilitar_campo.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "f_bloquear_campos

*&---------------------------------------------------------------------*
*&      Form  f_desbloquear_campos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_desbloquear_campos.
* Se o usuário clicou no botão 'Novo', desbloqueia todos campos
  READ TABLE tl_botoes
  TRANSPORTING NO FIELDS
  WITH KEY novo = 'X'.

  IF sy-subrc = 0.
    LOOP AT SCREEN.
      CASE screen-group1.
        WHEN 'GR0' OR 'GR1' OR 'GR2' OR 'GR3' OR 'GR4'.
          screen-input = c_habilitar_campo.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.

    PERFORM: f_limpar_variaveis_e_tabelas.

    CLEAR: ybr_folha_1000-dt_doc_de,
           ybr_folha_1000-dt_doc_ate.

    vl_tela = c_tela_vazia.
  ENDIF.
ENDFORM.                    "f_desbloquear_campos

*&---------------------------------------------------------------------*
*&      Form  f_obter_webservice_inss_rh
*&---------------------------------------------------------------------*
*       ResumoINSS_EmpresaPorPeriodo
*----------------------------------------------------------------------*
FORM f_obter_webservice_inss_rh.
  DATA: tl_parametros TYPE STANDARD TABLE OF ybr_folha_param,
        wl_parametros LIKE LINE OF tl_parametros            .

  DATA: ex          TYPE REF TO cx_root        ,
        http_client TYPE REF TO if_http_client ,
        xml         TYPE REF TO cl_xml_document,
        node        TYPE REF TO if_ixml_node   .

  DATA: vl_host          TYPE string    ,
        vl_service       TYPE string    ,
        vl_proxy_host    TYPE string    ,
        vl_proxy_service TYPE string    ,
        vl_scheme        TYPE i         ,
        vl_periodo       TYPE c LENGTH 6,
        vl_empresa       TYPE c LENGTH 2,
        vl_ssl_id        TYPE ssfapplssl,
        vl_exception     TYPE string    ,
        v_retorno        TYPE string    ,
        v_string         TYPE string    ,
        v_soap           TYPE string    ,
        v_tamanho        TYPE string    ,
        v_tamanhoi       TYPE i         ,
        vl_resumoinss    TYPE string    .

  CLEAR wl_botoes.
  READ TABLE tl_botoes
  INTO wl_botoes
  WITH KEY webs = 'X'.

  IF sy-subrc = 0.
    EXIT.
  ENDIF.

  IF ybr_folha_1000-inss_emp IS NOT INITIAL.
    MESSAGE 'INSS já foi informado pelo usuário. ' &
            'Realize uma nova pesquisa para obter o valor pelo sistema de RH'
    TYPE 'E'.
    EXIT.
  ENDIF.

* Seleciona os parâmetros cadastrados para a chamada do WebService
  SELECT mandt bukrs param valor
    FROM ybr_folha_param
    INTO TABLE tl_parametros
    WHERE bukrs = ybr_folha_1000-empresa.

  LOOP AT tl_parametros INTO wl_parametros.
    CASE wl_parametros-param.
      WHEN c_host. " HOST
        vl_host          = wl_parametros-valor.
      WHEN c_service.
        vl_service       = wl_parametros-valor.
      WHEN c_proxy_host.
        vl_proxy_host    = wl_parametros-valor.
      WHEN c_proxy_serv.
        vl_proxy_service = wl_parametros-valor.
      WHEN c_scheme.
        vl_scheme        = wl_parametros-valor.
    ENDCASE.
  ENDLOOP.

  TRY.
*     Instância a interface IF_HTTP_Client, (HTTP Client Abstraction)
      CALL METHOD cl_http_client=>create
        EXPORTING
          host               = vl_host          " gruwebdev-01
          service            = vl_service       " 80
          proxy_host         = vl_proxy_host    " ''
          proxy_service      = vl_proxy_service " ''
          scheme             = vl_scheme        " 1
        IMPORTING
          client             = http_client
        EXCEPTIONS
          argument_not_found = 1
          plugin_not_active  = 2
          internal_error     = 3
          OTHERS             = 4.

      IF sy-subrc = 0.
*       Define o método de comunicação
        CALL METHOD http_client->request->set_header_field
          EXPORTING
            name  = '~request_method'
            value = 'POST'.

*       Define o tipo de protocolo
        CALL METHOD http_client->request->set_header_field
          EXPORTING
            name  = '~server_protocol'
            value = 'HTTP/1.1'.

*       Define o caminho do WebService
        CALL METHOD http_client->request->set_header_field
          EXPORTING
            name  = '~request_uri'
            value = '/RecursosHumanos/FichaFinanceira.asmx'.

        CALL METHOD http_client->request->set_header_field
          EXPORTING
            name  = 'SOAPAction'
            value = 'http://tempuri.org/ResumoINSS_EmpresaPorPeriodo'.

*       Define o formato do XML
        CALL METHOD http_client->request->set_header_field
          EXPORTING
            name  = 'Content-Type'
            value = 'text/xml; charset=utf-8'.

        vl_empresa = ybr_folha_1000-empresa+2(2).   "50

        CONCATENATE ybr_folha_1000-dt_doc_de+0(4)
                    ybr_folha_1000-dt_doc_de+4(2)
               INTO vl_periodo.

        CONCATENATE
         '<?xml version="1.0" encoding="utf-8"?>'
         '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
         '<soap:Body>'
         '<ResumoINSS_EmpresaPorPeriodo xmlns="http://tempuri.org/">'
         '  <codEmpresa>'vl_empresa'</codEmpresa>'
         '  <periodo>'vl_periodo'</periodo>'
         '</ResumoINSS_EmpresaPorPeriodo>'
         '</soap:Body>'
         '</soap:Envelope>'
         INTO v_soap.

        v_tamanho = STRLEN( v_soap ).

*       Define tamanho do conteúdo do XML
        CALL METHOD http_client->request->set_header_field
          EXPORTING
            name  = 'Content-Length'
            value = v_tamanho.

        v_tamanhoi = v_tamanho.

        CALL METHOD http_client->request->set_cdata
          EXPORTING
            data   = v_soap
            offset = 0
            length = v_tamanhoi.

*       Envia os dados para o WebService
        CALL METHOD http_client->send
          EXPORTING
            timeout                    = 1000
          EXCEPTIONS
            http_communication_failure = 1
            http_invalid_state         = 2.

*       Obtém o retorno do Webservice
        CALL METHOD http_client->receive
          EXCEPTIONS
            http_communication_failure = 1
            http_invalid_state         = 2
            http_processing_failed     = 3.

        CLEAR v_retorno.
        v_retorno = http_client->response->get_cdata( ).

*       Fecha a conexão
        CALL METHOD http_client->close
          EXCEPTIONS
            http_invalid_state = 1
            OTHERS             = 2.

        IF v_retorno IS NOT INITIAL.
          CREATE OBJECT xml.

          CALL METHOD xml->parse_string
            EXPORTING
              stream  = v_retorno
            RECEIVING
              retcode = v_tamanhoi.

*         Procura o nó 'ResumoINSS_EmpresaPorPeriodoResult'
          CALL METHOD xml->find_node
            EXPORTING
              name = 'ResumoINSS_EmpresaPorPeriodoResult'
            RECEIVING
              node = node.

          DATA: vl_inss TYPE string.

*        Obtém o valor armazenado
          CALL METHOD node->get_value
            RECEIVING
              rval = vl_inss.

          ybr_folha_1000-inss_emp = vl_inss.
        ENDIF.

        IF ybr_folha_1000-inss_emp IS NOT INITIAL.
          vl_inss_emp = ybr_folha_1000-inss_emp.

*         Identifica que o valor do INSS foi obtido pelo WebService RH
          wl_botoes-webs = 'X'.
          MODIFY tl_botoes FROM wl_botoes INDEX 1.

          PERFORM f_calcular_inss_pagar.

        ELSE.
          MESSAGE 'Não há dados para o período informado'(022) TYPE 'E'.
        ENDIF.

      ELSE.
        MESSAGE 'Falha de comunicação para obter o valor do INSS através do sistema de RH'(021)
           TYPE 'E'.
        CLEAR ok_code.
      ENDIF.

    CATCH cx_root INTO ex.
      vl_exception = ex->get_text( ).
      MESSAGE vl_exception TYPE 'E'.
  ENDTRY.
ENDFORM.                    "f_obter_webservice_inss_rh