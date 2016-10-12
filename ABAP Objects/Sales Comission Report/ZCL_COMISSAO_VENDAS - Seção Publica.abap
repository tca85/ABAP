CLASS zcl_comissao_vendas DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_comissao             ,
                     lifnr TYPE vbpa-lifnr   , " Nº conta do fornecedor
                     pernr TYPE vbpa-pernr   , " Nº da pessoa
                     name1 TYPE lfa1-name1   , " Nome 1
                     vbeln TYPE vbak-vbeln   , " Documento de vendas
                     erdat TYPE vbak-erdat   , " Data de criação do registro
                     bstnk TYPE vbak-bstnk   , " Nº pedido do cliente
                     zterm TYPE vbkd-zterm   , " Chave de condições de pagamento
                     vkorg TYPE vbak-vkorg   , " Organização de vendas
                     vtweg TYPE vbak-vtweg   , " Canal de distribuição
                     spart TYPE vbak-spart   , " Setor de atividade
                     netwr TYPE vbak-netwr   , " Valor líquido da ordem na moeda do documento
                     vcom  TYPE zsde_vlcom   , " Valor total da comissão
                     vcomp TYPE zsde_vlcomp  , " Valor Compensar
                     vcopd TYPE zsde_vlcompd , " Valor compensado
                     conf  TYPE zsde_conf    , " Confirmar
                    END OF ty_comissao .
    TYPES:
      BEGIN OF ty_aprov_comissao       ,
                    status TYPE zsde_status  , " Status
                    nrg    TYPE zsdt033i-nrg , " Número de registro
                    erdat  TYPE vbak-erdat   , " Data de criação do registro
                    lifnr  TYPE vbpa-lifnr   , " Nº conta do fornecedor
                    name1  TYPE lfa1-name1   , " Nome 1
                    pernr  TYPE vbpa-pernr   , " Nº da pessoa
                    name2  TYPE lfa1-name1   , " Nome 1
                    vcom   TYPE zsde_vlcom   , " Valor total da comissão
                    vcomp  TYPE zsde_vlcomp  , " Valor Compensar
                    vlpag  TYPE zsde_vlpagar , " Valor a pagar
                    bstnk  TYPE vbak-bstnk   , " Nº pedido do cliente
                    conf   TYPE ZSDE_SEL     , " Selecionar
             END OF ty_aprov_comissao .
    TYPES:
      BEGIN OF ty_bapiret2      .
            INCLUDE TYPE bapiret2    .
    TYPES: END OF ty_bapiret2 .
    TYPES:
      tp_comissao       TYPE STANDARD TABLE OF ty_comissao       WITH DEFAULT KEY .
    TYPES:
      tp_aprov_comissao TYPE STANDARD TABLE OF ty_aprov_comissao WITH DEFAULT KEY .
    TYPES:
      tp_bapiret2       TYPE STANDARD TABLE OF ty_bapiret2 WITH DEFAULT KEY .
    TYPES:
      r_vbeln TYPE RANGE OF vbak-vbeln .
    TYPES:
      r_lifnr TYPE RANGE OF vbpa-lifnr .
    TYPES:
      r_pernr TYPE RANGE OF vbpa-pernr .
    TYPES:
      r_erdat TYPE RANGE OF vbak-erdat .
    TYPES:
      r_vkorg TYPE RANGE OF vbak-vkorg .
    TYPES:
      r_vtweg TYPE RANGE OF vbak-vtweg .
    TYPES:
      r_spart TYPE RANGE OF vbak-spart .
    TYPES:
      r_vkbur TYPE RANGE OF vbak-vkbur .
    TYPES:
      r_nrg TYPE RANGE OF zsdt033i-nrg .

    METHODS get_comissao_fornecedor
      IMPORTING
        !im_vbeln TYPE r_vbeln
        !im_lifnr TYPE r_lifnr
        !im_erdat TYPE r_erdat
        !im_vkorg TYPE r_vkorg
        !im_vtweg TYPE r_vtweg
        !im_spart TYPE r_spart
        !im_vkbur TYPE r_vkbur
      RETURNING
        VALUE(ex_t_comissao) TYPE tp_comissao
      RAISING
        zcx_comissao_vendas .
    METHODS get_comissao_funcionario
      IMPORTING
        !im_vbeln TYPE r_vbeln
        !im_pernr TYPE r_pernr
        !im_erdat TYPE r_erdat
        !im_vkorg TYPE r_vkorg
        !im_vtweg TYPE r_vtweg
        !im_spart TYPE r_spart
        !im_vkbur TYPE r_vkbur
      RETURNING
        VALUE(ex_t_comissao) TYPE tp_comissao
      RAISING
        zcx_comissao_vendas .
    METHODS get_comissao_pendente
      IMPORTING
        !im_r_nrg TYPE r_nrg
        !im_r_lifnr TYPE r_lifnr
        !im_r_pernr TYPE r_pernr
        !im_r_erdat TYPE r_erdat
      RETURNING
        VALUE(ex_t_aprov_com) TYPE tp_aprov_comissao
      RAISING
        zcx_comissao_vendas .
    METHODS set_comissao
      CHANGING
        !im_t_comissao TYPE tp_comissao
      RAISING
        zcx_comissao_vendas .
    METHODS efetivar_comissao
      CHANGING
        !ex_t_aprov_comissao TYPE tp_aprov_comissao
        !ex_t_bapiret2 TYPE tp_bapiret2
      RAISING
        zcx_comissao_vendas .
    METHODS eliminar_comissao
      CHANGING
        !ex_t_aprov_comissao TYPE tp_aprov_comissao
      RAISING
        zcx_comissao_vendas .
    METHODS exibir_rel_comissao_vendas
      IMPORTING
        !im_nr_registro TYPE zsde_nrg OPTIONAL
      CHANGING
        !im_t_comissao TYPE tp_comissao OPTIONAL
        !im_t_aprov_comissao TYPE tp_aprov_comissao OPTIONAL
      RAISING
        zcx_comissao_vendas .