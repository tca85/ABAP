CLASS ycl_gko DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_tag_emit_cte           ,
        cnpj    TYPE /xnfe/cte_cnpj_emit , " CNPJ do emissor do CT-e
        ie      TYPE c LENGTH 14         , " Inscrição Estadual do Emitente
        xnome   TYPE /xnfe/cte_xnome_emit, " CT-e: nome da empresa emitente CT-e
        xfant   TYPE /xnfe/cte_xfant     , " Nome Fantasia
        xlgr    TYPE /xnfe/cte_xlgr      , " Logradouro
        nro     TYPE /xnfe/cte_nro       , " Número
        xbairro TYPE /xnfe/cte_xbairro   , " Bairro
        cmun    TYPE /xnfe/cte_cmunemi   , " Código da cidade (emissor)
        xmun    TYPE /xnfe/cte_xmunemi   , " Nome da cidade (emissor)
        cep     TYPE n LENGTH 08         , " CEP
        uf      TYPE /xnfe/cte_ufemi     , " Unidade da Federação (UF) do emissor do CT-e
        fone    TYPE n LENGTH 14         , " Número do Telefone
      END OF ty_tag_emit_cte .
    TYPES:
      BEGIN OF ty_rfc_cte.
    TYPES: cte TYPE /xnfe/cteid,
           nfe TYPE /xnfe/id.
            INCLUDE TYPE ty_tag_emit_cte.
    TYPES: gko_integ TYPE c LENGTH 01.
    TYPES: END OF ty_rfc_cte .
    TYPES:
      BEGIN OF ty_rfc_nfe              ,
        nfe       TYPE /xnfe/id        , " Chave de acesso da NF-e
        nfenum    TYPE c LENGTH 09     , " NFenum
        pesol	    TYPE ntgew           , " Peso líquido
        pesob	    TYPE brgew           , " Peso bruto
        gko_integ TYPE c LENGTH 01     , " Integrado no GKO
      END OF ty_rfc_nfe .
    TYPES:
      BEGIN OF ty_xml    ,
        tag   TYPE string,
        valor TYPE string,
      END OF ty_xml .
    TYPES:
      tp_tag_emit_cte TYPE STANDARD TABLE OF ty_tag_emit_cte WITH DEFAULT KEY ,
      tp_nfe_cte      TYPE STANDARD TABLE OF /xnfe/inctenfe_t WITH DEFAULT KEY ,
      tp_rfc_cte      TYPE STANDARD TABLE OF ty_rfc_cte WITH DEFAULT KEY .
    TYPES:
      tp_xml TYPE STANDARD TABLE OF ty_xml WITH DEFAULT KEY .
    TYPES:
      tp_rfc_nfe TYPE STANDARD TABLE OF ty_rfc_nfe WITH DEFAULT KEY .

    METHODS gravar_tabela_ecc_cte
      IMPORTING
        !im_cte TYPE /xnfe/cte_104cte_proc
      RAISING
        ycx_gko .
    METHODS gravar_tabela_ecc_nfe
      IMPORTING
        !im_xml_nfe TYPE xstring
      RAISING
        ycx_gko .