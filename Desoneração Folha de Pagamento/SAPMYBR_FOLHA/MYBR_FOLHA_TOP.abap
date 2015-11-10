*&---------------------------------------------------------------------*
*& Include MYBR_FOLHA_TOP
*&---------------------------------------------------------------------*

PROGRAM sapmybr_folha.

TABLES: ybr_folha_1000. " Brasil Maior - Desoneração Folha (Tela de Seleção)

*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_j_1bnfdoc         , " Cabeçalho da nota fiscal
   docnum  TYPE j_1bnfdoc-docnum, " Nº documento
   nfnum   TYPE j_1bnfdoc-nfnum , " Nº nota fiscal
   series  TYPE j_1bnfdoc-series, " Série
   parid   TYPE j_1bnfdoc-parid , " Identificação do parceiro (cliente, fornecedor, loc.negócio)
   bukrs   TYPE j_1bnfdoc-bukrs , " Empresa
   branch  TYPE j_1bnfdoc-branch, " Local de negócios
   pstdat  TYPE j_1bnfdoc-pstdat, " Data de lançamento
   nftype  TYPE j_1bnfdoc-nftype, " Ctg.de nota fiscal
   printd  TYPE j_1bnfdoc-printd, " Imprimida
   cancel  TYPE j_1bnfdoc-cancel, " Estornado
   direct  TYPE j_1bnfdoc-direct, " Direção do movimento de mercadorias
   nfenum  TYPE j_1bnfdoc-nfenum, " Nº NF-e de nove posições
   model   TYPE j_1bnfdoc-model , " Modelo da nota fiscal
   inco1   TYPE j_1bnfdoc-inco1 , " Incoterms parte 1
   cfop    TYPE j_1bnflin-cfop  , " CFOP
   tp_cfop TYPE c LENGTH 01     , " Tipo do CFOP (V) vendas (O) outros
  END OF ty_j_1bnfdoc           ,

  BEGIN OF ty_j_1bnflin         , " Partidas individuais da nota fiscal
   docnum  TYPE j_1bnflin-docnum, " Nº documento
   itmnum  TYPE j_1bnflin-itmnum, " Nº item do documento
   matkl   TYPE j_1bnflin-matkl , " Grupo de mercadorias
   matnr   TYPE j_1bnflin-matnr , " Nº do material
   maktx   TYPE j_1bnflin-maktx , " Texto breve de material
   nbm     TYPE j_1bnflin-nbm   , " Código de controle p/imposto sobre consumo em com.exterior
   menge   TYPE j_1bnflin-menge , " Quantidade
   netwr   TYPE j_1bnflin-netwr , " Valor líquido
   netpr   TYPE j_1bnflin-netpr , " Preço líquido
   nfpri   TYPE j_1bnflin-nfpri , " Preço líquido incluindo impostos
   netdis  TYPE j_1bnflin-netdis, " Montante líquido da redução em moeda do documento
   nfnett  TYPE j_1bnflin-nfnett, " valor líquido/frete/seguro/despesas/desconto
   cfop    TYPE j_1bnflin-cfop  , " Código CFOP e extensão
   taxsi4  TYPE j_1bnflin-taxsi4, " Situação de imposto COFINS
   taxsi5  TYPE j_1bnflin-taxsi5, " Situação de imposto PIS
   tp_cfop TYPE c LENGTH 01     , " Tipo do CFOP (V) vendas (O) outros
  END OF ty_j_1bnflin           ,

  BEGIN OF ty_j_1bnfstx         , " Nota fiscal: imposto por item
   docnum  TYPE j_1bnfstx-docnum, " Nº documento
   itmnum  TYPE j_1bnfstx-itmnum, " Nº item do documento
   rate    TYPE j_1bnfstx-rate  , " Taxa de imposto
   taxtyp  TYPE j_1bnfstx-taxtyp, " Tipo de imposto
   taxval  TYPE j_1bnfstx-taxval, " Valor fiscal
   base    TYPE j_1bnfstx-base  , " Montante básico
   excbas  TYPE j_1bnfstx-excbas, " Montante básico excluído
   othbas  TYPE j_1bnfstx-othbas, " Outro montante básico
  END OF ty_j_1bnfstx           ,

  BEGIN OF ty_j_1bnfnad         , " Parceiros nota fiscal
   docnum  TYPE j_1bnfnad-docnum, " Nº documento
   parvw   TYPE j_1bnfnad-parvw , " Nota fiscal função parceiro
   parid   TYPE j_1bnfnad-parid , " Identificação do parceiro (cliente, fornecedor, loc.negócio)
  END OF ty_j_1bnfnad           ,

  BEGIN OF ty_lfa1              , " Mestre de fornecedores (parte geral)
   lifnr   TYPE lfa1-lifnr      , " Nº conta do fornecedor
   name1   TYPE lfa1-name1      ,                           " Nome 1
   regio   TYPE lfa1-regio      , " Região (país, estado, província, condado)
  END OF ty_lfa1                ,

  BEGIN OF ty_kna1              , " Mestre de clientes (parte geral)
   kunnr   TYPE kna1-kunnr      , " Nº cliente 1
   name1   TYPE kna1-name1      ,                           " Nome 1
   regio   TYPE kna1-regio      , " Região (país, estado, província, condado)
  END OF ty_kna1                ,

  BEGIN OF ty_makt              , " Textos breves de material
   matnr   TYPE makt-matnr      , " Nº do material
   spras   TYPE makt-spras      , " Código de idioma
   maktx   TYPE makt-maktx      , " Texto breve de material
   maktg   TYPE makt-maktg      , " Texto breve de material em letras maiúsculas p/matchcodes
  END OF ty_makt                ,

  BEGIN OF ty_t023              , " Denominações para grupos de mercadoria
   matkl   TYPE t023t-matkl     , " Grupo de mercadorias
   wgbez60 TYPE t023t-wgbez60   , " Texto descritivo para denominação do grupo de mercadorias
  END OF ty_t023                ,

  BEGIN OF ty_botoes            , " Pushbuttons da tela de seleção
   busc    TYPE c LENGTH 01     , " Buscar Dados
   calc    TYPE c LENGTH 01     , " Calcular
   salv    TYPE c LENGTH 01     , " Salvar
   impr    TYPE c LENGTH 01     , " Imprimir
   sped    TYPE c LENGTH 01     , " SPED
   novo    TYPE c LENGTH 01     , " Limpar campos
   webs    TYPE c LENGTH 01     , " WebService com valor do INSS do RH
  END OF ty_botoes              ,

  BEGIN OF ty_sped              , " Arquivo TXT para o SPED
   fixo    TYPE c LENGTH 16     , " Dados fixos
   ncm     TYPE string          , " NCM
   sep1    TYPE c LENGTH 01     , " Separador
   valor   TYPE string          , " Valor
   sep2    TYPE c LENGTH 02     , " Separador 2
  END OF ty_sped                .

*----------------------------------------------------------------------*
* Tabelas internas                                                     *
*----------------------------------------------------------------------*
DATA:
  tl_j_1bnfdoc        TYPE STANDARD TABLE OF ty_j_1bnfdoc    , " Cabeçalho da nota fiscal
  tl_j_1bnfdoc_vendas TYPE STANDARD TABLE OF ty_j_1bnfdoc    , " Cabeçalho da nota fiscal
  tl_j_1bnfdoc_outros TYPE STANDARD TABLE OF ty_j_1bnfdoc    , " Cabeçalho da nota fiscal
  tl_j_1bnflin        TYPE STANDARD TABLE OF ty_j_1bnflin    , " Item da nota fiscal
  tl_j_1bnflin_vendas TYPE STANDARD TABLE OF ty_j_1bnflin    , " Item da nota fiscal
  tl_j_1bnflin_outros TYPE STANDARD TABLE OF ty_j_1bnflin    , " Item da nota fiscal
  tl_j_1bnfstx        TYPE STANDARD TABLE OF ty_j_1bnfstx    , " Nota fiscal: imposto por item
  tl_j_1bnfnad        TYPE STANDARD TABLE OF ty_j_1bnfnad    , " Parceiros nota fiscal
  tl_lfa1             TYPE STANDARD TABLE OF ty_lfa1         , " Fornecedores
  tl_transport        TYPE STANDARD TABLE OF ty_lfa1         , " Transportadora
  tl_kna1             TYPE STANDARD TABLE OF ty_kna1         , " Clientes
  tl_makt             TYPE STANDARD TABLE OF ty_makt         , " Textos breves de material
  tl_t023             TYPE STANDARD TABLE OF ty_t023         , " Denominações para grupos de mercadoria
  tl_botoes           TYPE STANDARD TABLE OF ty_botoes       , " Pushbuttons da tela de seleção
  tl_sped             TYPE STANDARD TABLE OF ty_sped         , " Arquivo TXT para o SPED
  tl_notas_vendas     TYPE STANDARD TABLE OF yalv_doc_ncm    , " Detalhe das notas de vendas
  tl_notas_outros     TYPE STANDARD TABLE OF yalv_doc_ncm    , " Detalhe das notas de revendas/outros
  tl_fcode            TYPE STANDARD TABLE OF sy-ucomm        , " Excluir botões da PF-STATUS
  tl_cfop             TYPE STANDARD TABLE OF ybr_folha_cfop  , " Desoneração Folha - CFOP
  tl_ncm              TYPE STANDARD TABLE OF ybr_folha_ncm   , " NCMs permitidos
  tl_resultado        TYPE STANDARD TABLE OF ybr_folha_result, " Resultados (Smartform)
  tl_alv_vend_tot     TYPE STANDARD TABLE OF yalv_vendtot    , " Totais por NCM
  tl_alv_ncm_det      TYPE STANDARD TABLE OF yalv_vendtot    , " Detalhes do NCM
  tl_alv_revendas     TYPE STANDARD TABLE OF yalv_vendtot    , " Revendas e outros
  tl_alv_rev_tot      TYPE STANDARD TABLE OF yalv_vendtot    , " Total por revendas
  tl_alv_notas        TYPE STANDARD TABLE OF yalv_doc_ncm    . " Notas que compoem soma

DATA:
  tl_fieldcat TYPE lvc_t_fcat,
  wl_fieldcat TYPE lvc_s_fcat.

*----------------------------------------------------------------------*
* Ranges                                                               *
*----------------------------------------------------------------------*
DATA:
  r_data        TYPE RANGE OF sy-datum           ,
  r_cfop_vendas TYPE RANGE OF ybr_folha_cfop-cfop,
  r_cfop_outros TYPE RANGE OF ybr_folha_cfop-cfop,
  r_ncm         TYPE RANGE OF ybr_folha_ncm-steuc.

*----------------------------------------------------------------------*
* Work Areas                                                           *
*----------------------------------------------------------------------*
DATA:
  wl_j_1bnfdoc        LIKE LINE OF tl_j_1bnfdoc       ,
  wl_j_1bnfdoc_vendas LIKE LINE OF tl_j_1bnfdoc_vendas,
  wl_j_1bnfdoc_outros LIKE LINE OF tl_j_1bnfdoc_outros,
  wl_j_1bnflin        LIKE LINE OF tl_j_1bnflin       ,
  wl_j_1bnflin_vendas LIKE LINE OF tl_j_1bnflin_vendas,
  wl_j_1bnflin_outros LIKE LINE OF tl_j_1bnflin_outros,
  wl_j_1bnfstx        LIKE LINE OF tl_j_1bnfstx       ,
  wl_j_1bnfnad        LIKE LINE OF tl_j_1bnfnad       ,
  wl_lfa1             LIKE LINE OF tl_lfa1            ,
  wl_transport        LIKE LINE OF tl_transport       ,
  wl_kna1             LIKE LINE OF tl_kna1            ,
  wl_makt             LIKE LINE OF tl_makt            ,
  wl_t023             LIKE LINE OF tl_t023            ,
  wl_botoes           LIKE LINE OF tl_botoes          ,
  wl_sped             LIKE LINE OF tl_sped            ,
  wl_cfop             LIKE LINE OF tl_cfop            ,
  wl_ncm              LIKE LINE OF tl_ncm             ,
  wl_nota             LIKE LINE OF tl_notas_outros    ,
  wl_fcode            LIKE LINE OF tl_fcode           ,
  wl_data             LIKE LINE OF r_data             ,
  wl_cfop_range       LIKE LINE OF r_cfop_vendas      ,
  wl_ncm_range        LIKE LINE OF r_ncm              ,
  wl_alv_vend_tot     LIKE LINE OF tl_alv_vend_tot    ,
  wl_alv_ncm_det      LIKE LINE OF tl_alv_vend_tot    ,
  wl_alv_revendas     LIKE LINE OF tl_alv_revendas    ,
  wl_alv_rev_tot      LIKE LINE OF tl_alv_rev_tot     ,
  wl_alv_notas        LIKE LINE OF tl_alv_notas       ,
  wl_resultado        LIKE LINE OF tl_resultado       .

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
DATA:
  ok_code                  TYPE sy-ucomm             ,
  vl_titulo                TYPE lvc_s_layo-grid_title,
  vl_inss_emp              TYPE j_1bnflin-netwr      ,
  vl_total_vendas          TYPE j_1bnflin-netwr      ,
  vl_brmaior               TYPE j_1bnflin-netwr      ,
  vl_total_revendas_outros TYPE j_1bnflin-netwr      .

* Inicialmente não mostra a tela de dados do Brasil Maior
DATA:
  vl_tela         TYPE sy-dynnr VALUE 1002 ,
  vl_tela_alv     TYPE sy-dynnr            .

*----------------------------------------------------------------------*
* Objetos                                                              *
*----------------------------------------------------------------------*
DATA:
  obj_container TYPE REF TO cl_gui_custom_container,
  obj_alv_grid  TYPE REF TO cl_gui_alv_grid        .

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
CONSTANTS:
  c_tela_br_maior     TYPE sy-dynnr            VALUE '1001'             ,
  c_tela_vazia        TYPE sy-dynnr            VALUE '1002'             ,
  c_tela_alv_vendas   TYPE sy-dynnr            VALUE '1010'             ,
  c_tela_alv_revendas TYPE sy-dynnr            VALUE '1020'             ,
  c_tela_alv_nfs      TYPE sy-dynnr            VALUE '1011'             ,
  c_pt_br             TYPE t002-laiso          VALUE 'PT'               ,
  c_mvto_saida        TYPE j_1bnfdoc-direct    VALUE '2'                ,
  c_autorizada        TYPE j_1bnfdoc-docstat   VALUE '1'                ,
  c_stat_autorizado   TYPE j_1bstscode-code    VALUE '100'              , " Autorizado o uso da NF-e
  c_transportadora    TYPE j_1bad-parvw        VALUE 'SP'               ,
  c_transp_aereo      TYPE j_1bad-parvw        VALUE 'CA'               ,
  c_grupo_pis         TYPE j_1baj-taxgrp       VALUE 'PIS'              ,
  c_grupo_ipi         TYPE j_1baj-taxgrp       VALUE 'IPI'              ,
  c_grupo_cofins      TYPE j_1baj-taxgrp       VALUE 'COFI'             ,
  c_grupo_icms        TYPE j_1baj-taxgrp       VALUE 'ICMS'             ,
  c_grupo_icms_st     TYPE j_1baj-taxgrp       VALUE 'ICST'             ,
  c_icms_zn_franca    TYPE j_1baj-taxtyp       VALUE 'ICZF'             , " ICMS desconto Zona Franca
  c_cfop_vendas       TYPE ybr_folha_cfop-tipo VALUE '1'                ,
  c_cfop_outros       TYPE ybr_folha_cfop-tipo VALUE '2'                ,
  c_desabilitar_campo TYPE c LENGTH 01         VALUE '0'                ,
  c_habilitar_campo   TYPE c LENGTH 01         VALUE '1'                ,
  c_sim               TYPE c LENGTH 01         VALUE '1'                ,
  c_excluir_icms      TYPE c LENGTH 07         VALUE 'EXCICMS'          ,
  c_percentual_desonr TYPE c LENGTH 09         VALUE 'PERCEDESO'        ,
  c_host              TYPE c LENGTH 04         VALUE 'HOST'             ,
  c_service           TYPE c LENGTH 07         VALUE 'SERVICE'          ,
  c_scheme            TYPE c LENGTH 06         VALUE 'SCHEME'           ,
  c_proxy_host        TYPE c LENGTH 10         VALUE 'PROXY_HOST'       ,
  c_proxy_serv        TYPE c LENGTH 10         VALUE 'PROXY_SERV'       ,
  c_scheme_htt        TYPE c LENGTH 10         VALUE 'SCHEME_HTT'       ,
  c_ssl_id            TYPE c LENGTH 06         VALUE 'SSL_ID'           ,
  c_http              TYPE i                   VALUE 1                  ,
  c_j1b3n             TYPE tstc-tcode          VALUE 'J1B3N'            ,
  c_hotspot_ncm       TYPE dd03p-fieldname     VALUE 'NCM'              ,
  c_hotspot_docnum    TYPE dd03p-fieldname     VALUE 'DOCNUM'           ,
  c_impressora_local  TYPE tsp03-padest        VALUE 'LOCL'             ,
  c_disp_saida_impres TYPE ssfctrlop-device    VALUE 'PRINTER'          ,
  c_alv_vend_tot      TYPE ddobjname           VALUE 'YALV_VENDTOT'     ,
  c_alv_notas_fiscais TYPE ddobjname           VALUE 'YALV_DOC_NCM'     ,
  c_cont_alv_vend_tot TYPE scrfname            VALUE 'CONT_ALV_VEND_TOT',
  c_cont_alv_ncm_det  TYPE scrfname            VALUE 'CONT_ALV_NCM_DET' ,
  c_cont_alv_revend   TYPE scrfname            VALUE 'CONT_ALV_REVEND'  ,
  c_smartform_folha   TYPE tdsfname            VALUE 'YBR_FOLHA'        .