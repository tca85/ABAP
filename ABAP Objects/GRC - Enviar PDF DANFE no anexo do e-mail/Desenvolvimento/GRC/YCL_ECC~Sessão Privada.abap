PRIVATE SECTION.

  DATA t_nfe TYPE tp_nfe .
  DATA t_alv TYPE tp_alv .

  METHODS atualizar_nro_pedido_compra
    IMPORTING
      !xped  TYPE bstkd OPTIONAL
    CHANGING
      !w_nfe TYPE ty_nfe .
  METHODS get_corpo_email_nfe
    IMPORTING
      !w_nfe               TYPE ty_nfe
    RETURNING
      VALUE(t_corpo_email) TYPE tp_corpo_email .
  METHODS get_danfe_nfe
    IMPORTING
      !w_nfe               TYPE ty_nfe
    RETURNING
      VALUE(t_pdf_binario) TYPE solix_tab .
  METHODS get_email_destinatario
    IMPORTING
      !w_nfe                TYPE ty_nfe
      !im_email_adicional   TYPE adr6-smtp_addr OPTIONAL
      !im_recebedor         TYPE char1 OPTIONAL
      !im_transportadora    TYPE char1 OPTIONAL
    RETURNING
      VALUE(t_destinatario) TYPE ynfe_ct_destino .
  METHODS get_email_remetente
    IMPORTING
      !im_chave_acesso TYPE /xnfe/id OPTIONAL
    RETURNING
      VALUE(ex_email)  TYPE adr6-smtp_addr .