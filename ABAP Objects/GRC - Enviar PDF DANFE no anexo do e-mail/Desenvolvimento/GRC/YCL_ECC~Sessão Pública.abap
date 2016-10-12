CLASS ycl_ecc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_nfe                            ,
        id        TYPE /xnfe/outnfehd-id        ,
        docnum    TYPE /xnfe/outnfehd-docnum    ,
        logsys    TYPE /xnfe/outnfehd-logsys    ,
        serie     TYPE /xnfe/outnfehd-serie     ,
        nnf       TYPE /xnfe/outnfehd-nnf       ,
        cnpj_dest TYPE /xnfe/outnfehd-cnpj_dest ,
        cpf_dest  TYPE /xnfe/outnfehd-cpf_dest  ,
        emit      TYPE /xnfe/outnfehd-xnome_emit,
        dhemi     TYPE /xnfe/outnfehd-dhemi     ,
        xmlstring TYPE /xnfe/outnfexml-xmlstring,
      END OF ty_nfe .
    TYPES:
      BEGIN OF ty_alv                           ,
        emit         TYPE /xnfe/outnfehd-xnome_emit,
        docnum       TYPE /xnfe/outnfehd-docnum    ,
        nnf          TYPE /xnfe/outnfehd-nnf       ,
        serie        TYPE /xnfe/outnfehd-serie     ,
        id           TYPE /xnfe/outnfehd-id        ,
        cnpj_dest    TYPE /xnfe/outnfehd-cnpj_dest ,
        cpf_dest     TYPE /xnfe/outnfehd-cpf_dest  ,
        dhemi        TYPE /xnfe/outnfehd-dhemi     ,
        remetente    TYPE yemailde                 ,
        destinatario TYPE yemailpara               ,
      END OF ty_alv .
    TYPES:
      tp_nfe TYPE STANDARD TABLE OF ty_nfe WITH DEFAULT KEY .
    TYPES:
      tp_alv TYPE STANDARD TABLE OF ty_alv WITH DEFAULT KEY .
    TYPES:
      tp_corpo_email TYPE STANDARD TABLE OF soli   WITH DEFAULT KEY .
    TYPES:
      r_id_nfe TYPE RANGE OF /xnfe/id .
    TYPES:
      r_nro_nfe TYPE RANGE OF /xnfe/outnfehd-nnf .
    TYPES:
      r_docnum TYPE RANGE OF /xnfe/outnfehd-docnum .
    TYPES:
      r_emissao TYPE RANGE OF sy-datum .
    TYPES:
      r_cnpj_dest TYPE RANGE OF /xnfe/outnfehd-cnpj_dest .
    TYPES:
      r_cpf_dest TYPE RANGE OF /xnfe/outnfehd-cpf_dest .

    METHODS atualizar_status_nfe_ecc
      IMPORTING
        !w_nfe TYPE ty_nfe .
    METHODS enviar_email_nfe_danfe
      IMPORTING
        !im_email_adicional         TYPE adr6-smtp_addr OPTIONAL
        !im_t_pdf_binario           TYPE solix_tab OPTIONAL
        !im_t_destinatario          TYPE ynfe_ct_destino OPTIONAL
        !im_nro_pedido              TYPE bstkd OPTIONAL
        !im_recebedor               TYPE char1 OPTIONAL
        !im_transportadora          TYPE char1 OPTIONAL
      RETURNING
        VALUE(rt_qtd_email_enviado) TYPE sy-tabix
      RAISING
        ycx_ecc .
    METHODS get_alv_nfe
      RETURNING
        VALUE(ex_t_alv) TYPE tp_alv .
    METHODS get_xml_nfe
      IMPORTING
        !im_chave_acesso TYPE /xnfe/id OPTIONAL
        !im_id_nfe       TYPE r_id_nfe OPTIONAL
        !im_nro_nfe      TYPE r_nro_nfe OPTIONAL
        !im_docnum       TYPE r_docnum OPTIONAL
        !im_emissao      TYPE r_emissao OPTIONAL
        !im_cnpj_dest    TYPE r_cnpj_dest OPTIONAL
        !im_cpf_dest     TYPE r_cpf_dest OPTIONAL
      RAISING
        ycx_ecc .
    METHODS testar_rfc_destination
      IMPORTING
        !im_sistema_logico  TYPE logsys
        !im_nome_rfc_ecc    TYPE rs38l-name
      CHANGING
        !ex_nome_rfc_ecc    TYPE rs38l-name
        !ex_rfc_destination TYPE bdbapidst
      RAISING
        ycx_ecc .