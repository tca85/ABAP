*"* private components of class YCL_GRC
*"* do not include other source files here!!!
PRIVATE SECTION.

  METHODS enviar_dados_grc
    IMPORTING
      !im_chave_acesso TYPE j_1b_nfe_access_key_dtel44
      !im_t_destinatario TYPE tp_destinatario
      !im_t_pdf_danfe TYPE solix_tab
      !im_nro_pedido TYPE bstkd
    RETURNING
      value(rt_qtd_email_enviado) TYPE sy-tabix
    RAISING
      ycx_grc .