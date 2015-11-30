PRIVATE SECTION.

  METHODS get_rfc_cte
    IMPORTING
      !im_id_cte          TYPE /xnfe/cteid
    CHANGING
      !ex_nome_rfc        TYPE rs38l-name
      !ex_rfc_destination TYPE bdbapidst
    RAISING
      ycx_gko .
  METHODS get_rfc_nfe
    IMPORTING
      !im_id_nfe          TYPE /xnfe/id
    CHANGING
      !ex_nome_rfc        TYPE rs38l-name
      !ex_rfc_destination TYPE bdbapidst
    RAISING
      ycx_gko .
  METHODS get_tags_cte
    IMPORTING
      !im_xml             TYPE xstring
      !im_cteid           TYPE /xnfe/inctehd-cteid
      !im_t_nfe_cte       TYPE /xnfe/inctenfe_t
    RETURNING
      VALUE(ex_t_rfc_cte) TYPE tp_rfc_cte .
  METHODS get_tags_nfe
    IMPORTING
      !im_xml_nfe      TYPE xstring
    RETURNING
      VALUE(t_rfc_nfe) TYPE tp_rfc_nfe
    RAISING
      ycx_gko .
  METHODS testar_rfc_destination
    IMPORTING
      !im_sistema_logico  TYPE logsys
      !im_nome_rfc_ecc    TYPE rs38l-name
    CHANGING
      !ex_nome_rfc_ecc    TYPE rs38l-name
      !ex_rfc_destination TYPE bdbapidst
    RAISING
      ycx_gko .
  METHODS verificar_cte_contra_cnpj_empresa
    IMPORTING
      !im_cnpj TYPE /xnfe/cte_cnpj_dest
    RAISING
      ycx_gko .
  METHODS xml_parser
    IMPORTING
      !im_xml         TYPE xstring
      !im_raiz        TYPE string
      !im_filho_raiz  TYPE string
      !im_sub_no      TYPE string OPTIONAL
    RETURNING
      VALUE(ex_t_xml) TYPE tp_xml .