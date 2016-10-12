private section.

  methods GET_VAL_COMPENSADO_FINANCEIRO
    changing
      !IM_T_COMISSAO type TP_COMISSAO
    raising
      ZCX_COMISSAO_VENDAS .
  methods GET_TIPO_CONDICAO_PARCEIRO
    importing
      !IM_TIPO_PARCEIRO type FEHGR
    changing
      !EX_R_KSCHL type R_KSCHL
      !EX_R_PARVW type R_PARVW
      !EX_T_COND_PARC type TP_COND_PARC
    raising
      ZCX_COMISSAO_VENDAS .
  methods GET_VAL_TOTAL_COMISSAO
    importing
      !IM_T_VBAK type TP_VBAK
      !IM_R_KSCHL type R_KSCHL
    changing
      !EX_T_KONV_TOTAL type TP_KONV_TOTAL
    raising
      ZCX_COMISSAO_VENDAS .
  methods CRIAR_PEDIDO_COMPRAS
    importing
      !IM_APROV_COMISSAO type TY_APROV_COMISSAO
    changing
      !EX_NRO_PEDIDO type VBAK-BSTNK
      !EX_T_BAPIRET2 type TP_BAPIRET2 .