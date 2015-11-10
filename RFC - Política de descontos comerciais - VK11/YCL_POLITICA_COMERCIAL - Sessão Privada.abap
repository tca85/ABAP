*"* private components of class YCL_POLITICA_COMERCIAL
*"* do not include other source files here!!!
PRIVATE SECTION.

  DATA t_msg_retorno TYPE yct_mensagens .
  CONSTANTS c_aplicacao_sd TYPE t681a-kappl VALUE 'V'.      "#EC NOTEXT
  CONSTANTS c_funcao_modificacao TYPE msgfn VALUE '004'.    "#EC NOTEXT
  CONSTANTS c_funcao_eliminacao TYPE msgfn VALUE '003'.     "#EC NOTEXT
  CONSTANTS c_desc_comercial TYPE t685-kschl VALUE 'YDEC'.  "#EC NOTEXT
  CONSTANTS c_determinacao_preco TYPE t681v-kvewe VALUE 'A'. "#EC NOTEXT
  CONSTANTS c_br_real TYPE tcurc-waers VALUE 'BRL'.         "#EC NOTEXT
  CONSTANTS c_unidade_condicao TYPE tcurc-waers VALUE '%'.  "#EC NOTEXT
  CONSTANTS c_percentual TYPE krech VALUE 'A'.              "#EC NOTEXT
  CONSTANTS c_946 TYPE t681-kotabnr VALUE 946.              "#EC NOTEXT
  CONSTANTS c_947 TYPE t681-kotabnr VALUE 947.              "#EC NOTEXT
  CONSTANTS c_960 TYPE t681-kotabnr VALUE 960.              "#EC NOTEXT
  CONSTANTS c_963 TYPE t681-kotabnr VALUE 963.              "#EC NOTEXT
  CONSTANTS c_972 TYPE t681-kotabnr VALUE 972.              "#EC NOTEXT
  CONSTANTS c_962 TYPE t681-kotabnr VALUE 962.              "#EC NOTEXT
  CONSTANTS c_968 TYPE t681-kotabnr VALUE 968.              "#EC NOTEXT
  CONSTANTS c_961 TYPE t681-kotabnr VALUE 961.              "#EC NOTEXT
  CONSTANTS c_969 TYPE t681-kotabnr VALUE 969.              "#EC NOTEXT
  CLASS-DATA politica_comercial TYPE REF TO ycl_politica_comercial .

  METHODS converter_cliente
    IMPORTING
      !im_cliente TYPE char10
    RETURNING
      value(ex_cliente) TYPE kna1-kunnr .
  METHODS converter_data
    IMPORTING
      !im_data TYPE char10
    RETURNING
      value(ex_data) TYPE sy-datum
    RAISING
      ycx_pc .
  METHODS converter_material
    IMPORTING
      !im_material TYPE char18
    RETURNING
      value(ex_material) TYPE mara-matnr
    RAISING
      ycx_pc .
  METHODS converter_montante
    IMPORTING
      !im_montante TYPE char13
    RETURNING
      value(ex_montante) TYPE bapicurext
    RAISING
      ycx_pc .
  METHODS set_msg_retorno
    IMPORTING
      !im_id_modificacao TYPE y946-id
      !im_t_retorno_bapi TYPE tp_retorno_bapi
    RAISING
      ycx_pc .
  METHODS set_politica_comercial
    IMPORTING
      !im_id_modificacao TYPE y946-id
      !im_data_inicial TYPE sy-datum
      !im_data_final TYPE sy-datum
      !im_montante TYPE bapicurext
      !im_tab_condicao TYPE kotabnr
      !im_varkey TYPE bapicondct-varkey
      !im_cond_pgto TYPE dzterm
      !im_indice_item TYPE sy-tabix .