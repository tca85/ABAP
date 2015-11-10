*----------------------------------------------------------------------*
*       CLASS YCL_GRC  DEFINITIO
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS ycl_grc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

*"* public components of class YCL_GRC
*"* do not include other source files here!!!
  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_destinatario,
            email TYPE ad_smtpadr ,
          END OF ty_destinatario .
    TYPES:
      tp_destinatario TYPE STANDARD TABLE OF ty_destinatario WITH DEFAULT KEY .

    METHODS enviar_email_xml_danfe
      IMPORTING
        !im_nro_documento TYPE j_1bdocnum
      RETURNING
        value(rt_qtd_email_enviado) TYPE sy-tabix
      RAISING
        ycx_grc .
    METHODS get_chave_acesso
      IMPORTING
        !im_nro_documento TYPE j_1bdocnum
      RETURNING
        value(rt_chave_acesso) TYPE j_1b_nfe_access_key_dtel44
      RAISING
        ycx_grc .
    METHODS get_danfe
      IMPORTING
        !im_nro_documento TYPE j_1bdocnum
      RETURNING
        value(rt_t_danfe) TYPE solix_tab .
    METHODS get_destinatario_email_nfe
      IMPORTING
        !im_nro_documento TYPE j_1bdocnum
        !im_comprador TYPE c OPTIONAL
        !im_transportadora TYPE c OPTIONAL
      RETURNING
        value(rt_t_destinatario) TYPE tp_destinatario
      RAISING
        ycx_grc .
    METHODS get_nro_pedido_cliente
      IMPORTING
        !im_nro_documento TYPE j_1bdocnum
      RETURNING
        value(rt_nro_pedido) TYPE char15 .