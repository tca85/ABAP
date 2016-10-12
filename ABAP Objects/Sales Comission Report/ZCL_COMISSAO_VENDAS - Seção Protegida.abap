PROTECTED SECTION.

  TYPES:
*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
    BEGIN OF ty_vbak           ,
     vbeln TYPE vbak-vbeln    , " Documento de vendas
     erdat TYPE vbak-erdat    , " Data de criação do registro
     vkorg TYPE vbak-vkorg    , " Organização de vendas
     vtweg TYPE vbak-vtweg    , " Canal de distribuição
     spart TYPE vbak-spart    , " Setor de atividade
     vkbur TYPE vbak-vkbur    , " Escritório de vendas
     knumv TYPE vbak-knumv    , " Nº condição do documento
     netwr TYPE vbak-netwr    , " Valor líquido da ordem
     bstnk TYPE vbak-bstnk    , " Nº pedido do cliente
   END OF ty_vbak .
  TYPES:
    BEGIN OF ty_vbpa           ,
     vbeln TYPE vbpa-vbeln    , " Nº documento de vendas e distribuição
     lifnr TYPE vbpa-lifnr    , " Nº conta do fornecedor
     pernr TYPE vbpa-pernr    , " Nº pessoal
     parvw TYPE vbpa-parvw    , " Função do parceiro
   END OF ty_vbpa .
  TYPES:
    BEGIN OF ty_vbkd           ,
     vbeln TYPE vbkd-vbeln    , " Nº documento de vendas e distribuição
     zterm TYPE vbkd-zterm    , " Chave de condições de pagamento
   END OF ty_vbkd .
  TYPES:
    BEGIN OF ty_vbfa           ,
     vbelv   TYPE vbfa-vbelv  , " Documento de vendas e distribuição precedente
     vbeln   TYPE vbfa-vbeln  , " Nº documento de vendas e distribuição
     vbtyp_n TYPE vbfa-vbtyp_n, " Categoria de documento SD subseqüente
     vbtyp_v TYPE vbfa-vbtyp_v, " Ctg.documento de venda e distribuição (SD) precedente
   END OF ty_vbfa .
  TYPES:
    BEGIN OF ty_bseg           ,
     vbeln TYPE bseg-vbeln    , " Nº documento de vendas e distribuição
     buzei TYPE bseg-buzei    , " Nº linha de lançamento no documento contábil
     augbl TYPE bseg-augbl    , " Nº documento de compensação
     koart TYPE bseg-koart    , " Tipo de conta
     parc  TYPE sy-tabix      , " Quantidade de parcelas
   END OF ty_bseg .
  TYPES:
    BEGIN OF ty_konv           ,
     knumv TYPE konv-knumv    , " Nº condição do documento
     kposn TYPE konv-kposn    , " Nº item ao qual se aplicam as condições
     kschl TYPE konv-kschl    , " Tipo de condição
     kbetr TYPE konv-kbetr    , " Montante ou porcentagem da condição
     kwert TYPE konv-kwert    , " Valor condição
   END OF ty_konv .
  TYPES:
    BEGIN OF ty_konv_total     ,
     knumv TYPE konv-knumv    , " Nº condição do documento
     kschl TYPE konv-kschl    , " Tipo de condição
     kwert TYPE konv-kwert    , " Valor condição
   END OF ty_konv_total .
  TYPES:
    BEGIN OF ty_lfa1           ,
     lifnr TYPE lfa1-lifnr    , " Nº conta do fornecedor
     name1 TYPE lfa1-name1    , " Descrição
   END OF ty_lfa1 .
  TYPES:
    BEGIN OF ty_pa0001        ,
     pernr TYPE pa0001-pernr  , " Nº pessoal
     sname TYPE pa0001-sname  , " Nome do empregado (ordenável, SOBRENOME NOME)
   END OF ty_pa0001 .
  TYPES:
    BEGIN OF ty_cond_parc    ,
        kschl TYPE kschl      , " Tipo de condição
        parvw TYPE parvw      , " Parceiro
        fehgr TYPE fehgr      , " Esquema de dados
      END OF ty_cond_parc .
  TYPES:
    r_parvw TYPE RANGE OF parvw .
  TYPES:
    r_kschl TYPE RANGE OF kschl .
  TYPES:
    tp_vbak       TYPE STANDARD TABLE OF ty_vbak       WITH DEFAULT KEY .
  TYPES:
    tp_konv_total TYPE STANDARD TABLE OF ty_konv_total WITH DEFAULT KEY .
  TYPES:
    tp_cond_parc TYPE STANDARD TABLE OF ty_cond_parc WITH DEFAULT KEY .

  CONSTANTS c_rep_externo TYPE tvuv-fehgr VALUE '08'.       "#EC NOTEXT
  CONSTANTS c_rep_interno TYPE tvuv-fehgr VALUE '09'.       "#EC NOTEXT
  CONSTANTS c_fatura TYPE vbtyp VALUE 'M'.                  "#EC NOTEXT
  CONSTANTS c_ordem TYPE vbtyp VALUE 'C'.                   "#EC NOTEXT
  CONSTANTS c_conta_cliente TYPE vbtyp VALUE 'D'.           "#EC NOTEXT