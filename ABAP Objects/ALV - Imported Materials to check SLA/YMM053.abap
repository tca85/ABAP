REPORT ymm053 NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
* Programa...: YMM053                                                  *
* Transação..: YMM053                                                  *
* Descrição..: Relatório de importados para a medição de SLA           *
* Tipo.......: ALV                                                     *
* Módulo.....: MM                                                      *
* ABAP.......: Thiago Cordeiro Alves                                   *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  14.03.2016  #139877 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS lcx_static_check DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcx_static_check DEFINITION INHERITING FROM cx_static_check FINAL.
  PUBLIC SECTION.
    DATA msg_erro TYPE string.

    METHODS constructor
      IMPORTING texto TYPE string.
ENDCLASS.                    "lcx_static_check  DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_alv DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_alv DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES:
      r_matnr TYPE RANGE OF ekpo-matnr,
      r_aedat TYPE RANGE OF ekko-aedat,
      r_budat TYPE RANGE OF ekbe-budat,
      r_eindt TYPE RANGE OF eket-eindt,
      r_bwart TYPE RANGE OF ekbe-bwart.

    METHODS: pesquisar_materiais_importados
      IMPORTING im_matnr TYPE r_matnr
                im_aedat TYPE r_aedat
                im_budat TYPE r_budat
                im_eindt TYPE r_eindt
                im_bwart TYPE r_bwart
      RAISING   lcx_static_check.

    METHODS: exibir_relatorio_alv
      RAISING lcx_static_check.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_alv        ,
        ebeln TYPE ekko-ebeln, " Nº do documento de compras
        aedat TYPE ekko-aedat, " Data de criação do registro
        lifnr TYPE lfa1-lifnr, " Nº conta do fornecedor
        name1 TYPE lfa1-name1, " Nome do fornecedor
        ebelp TYPE ekbe-ebelp, " Nº item do documento de compra
        menge TYPE ekbe-menge, " Quantidade
        bpmng TYPE ekbe-bpmng, " Quantidade na unidade do preço do pedido
        bwart TYPE ekbe-bwart, " Tipo de movimento (administração de estoques)
        belnr TYPE ekbe-belnr, " Nº documento de material
        budat TYPE ekbe-budat, " Data de lançamento no documento
        dmbtr TYPE ekbe-dmbtr, " Montante em moeda interna
        hswae TYPE ekbe-hswae, " Chave de moeda interna
        meins TYPE ekpo-meins, " Unidade de medida do pedido
        bprme TYPE ekpo-bprme, " Unidade do preço do pedido
        matnr TYPE ekpo-matnr, " Nº do material
        txz01 TYPE ekpo-txz01, " Texto breve
        werks TYPE ekpo-werks, " Centro
        netpr TYPE ekpo-netpr, " Preço líquido no documento de compra na moeda do documento
        waers TYPE ekko-waers, " Código da moeda
        banfn TYPE eban-banfn, " Nº requisição de compra
        bnfpo TYPE eban-bnfpo, " Nº do item da requisição de compra
        lfdat TYPE eban-lfdat, " Data de remessa do item
        badat TYPE eban-badat, " Data da solicitação
        eindt TYPE eket-eindt, " Data de remessa do item
        plifz TYPE marc-plifz, " Prazo de entrega previsto em dias
      END OF ty_alv          .

    DATA:
      t_alv TYPE STANDARD TABLE OF ty_alv.

    DATA:
      o_salv_table TYPE REF TO cl_salv_table. " Basis Class for Simple Tables

    CONSTANTS:
      c_docto_compras TYPE lvc_fname VALUE 'EBELN',
      c_me23n         TYPE sy-tcode  VALUE 'ME23N'.

    METHODS: modificar_pfstatus_alv
      CHANGING salv_functions_list TYPE REF TO cl_salv_functions_list.

    METHODS: modificar_layout_alv
      CHANGING salv_layout TYPE REF TO cl_salv_layout.

    METHODS: modificar_colunas_alv
      CHANGING salv_columns_table TYPE REF TO cl_salv_columns_table
      RAISING  lcx_static_check.

    METHODS: on_link_click FOR EVENT link_click OF cl_salv_events_table
      IMPORTING row column.

ENDCLASS.                    "lcl_alv DEFINITION

*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_screen     ,
    eindt TYPE eket-eindt, " Data de remessa do item
    aedat TYPE ekko-aedat, " Data de criação do registro
    budat TYPE ekbe-budat, " Data de lançamento no documento
    bwart TYPE ekbe-bwart, " Tipo de movimento (administração de estoques)
    matnr TYPE ekpo-matnr, " Nº do material
  END OF ty_screen       .

*----------------------------------------------------------------------*
* Variáveis tipo referência
*----------------------------------------------------------------------*
DATA:
  o_alv          TYPE REF TO lcl_alv         ,              "#EC NEEDED
  o_static_check TYPE REF TO lcx_static_check.              "#EC NEEDED

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
DATA:
   w_screen TYPE ty_screen.

*----------------------------------------------------------------------*
* Tela de seleção
*----------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE t001.
SELECT-OPTIONS: s_matnr FOR w_screen-matnr               , " Nº do material
                s_aedat FOR w_screen-aedat               , " Data de criação do registro
                s_budat FOR w_screen-budat               , " Data de lançamento no documento
                s_eindt FOR w_screen-eindt               , " Data de remessa do item
                s_bwart FOR w_screen-bwart               . " Tipo de movimento (administração de estoques)
SELECTION-SCREEN: END OF BLOCK b1                        .

*----------------------------------------------------------------------*
* PBO
*----------------------------------------------------------------------*
INITIALIZATION.
  t001 = 'Critérios de seleção'.                            "#EC NOTEXT

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
START-OF-SELECTION.

  CREATE OBJECT o_alv TYPE lcl_alv.

  TRY.
      o_alv->pesquisar_materiais_importados( im_matnr = s_matnr[]
                                             im_aedat = s_aedat[]
                                             im_budat = s_budat[]
                                             im_eindt = s_eindt[]
                                             im_bwart = s_bwart[] ).

      o_alv->exibir_relatorio_alv( ).

    CATCH lcx_static_check INTO o_static_check.
      MESSAGE o_static_check->msg_erro TYPE 'S' DISPLAY LIKE 'E'. "#EC NOTEXT
  ENDTRY.

*----------------------------------------------------------------------*
*       CLASS lcl_alv IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_alv IMPLEMENTATION.
*&---------------------------------------------------------------------*
*&      METHOD  pesquisar_materiais_importados
*&---------------------------------------------------------------------*
*&        IMPORTING im_matnr TYPE r_matnr
*&                  im_aedat TYPE r_aedat
*&                  im_budat TYPE r_budat
*&                  im_eindt TYPE r_eindt
*&                  im_bwart TYPE r_bwart
*&        RAISING   lcx_static_check.
*&---------------------------------------------------------------------*
  METHOD pesquisar_materiais_importados.
    SELECT ekko~ebeln ekko~aedat lfa1~lifnr lfa1~name1
           ekbe~ebelp ekpo~menge ekbe~bpmng ekbe~bwart
           ekbe~belnr ekbe~budat ekbe~dmbtr ekbe~hswae
           ekpo~meins ekpo~bprme ekpo~matnr ekpo~txz01
           ekpo~werks ekpo~netpr ekko~waers eban~banfn
           eban~bnfpo eban~lfdat eban~badat eket~eindt
           marc~plifz
    FROM ekko
      INNER JOIN lfa1 ON lfa1~lifnr = ekko~lifnr " Nº conta do fornecedor
      INNER JOIN ekbe ON ekbe~ebeln = ekko~ebeln " Nº do documento de compras
      INNER JOIN ekpo ON ekpo~ebeln = ekbe~ebeln " Nº do documento de compras
                     AND ekpo~ebelp = ekbe~ebelp " Nº item do documento de compra
      INNER JOIN eket ON eket~ebeln = ekbe~ebeln " Nº do documento de compras
                     AND eket~ebelp = ekbe~ebelp " Nº item do documento de compra
      INNER JOIN eban ON eban~banfn = ekpo~banfn " Nº requisição de compra
                     AND eban~bnfpo = ekpo~bnfpo " Nº do item da requisição de compra
      INNER JOIN marc ON marc~matnr = ekpo~matnr " Nº do material
                     AND marc~werks = ekpo~werks " Centro
      INTO TABLE me->t_alv
      WHERE ekpo~matnr IN im_matnr               " Nº do material
        AND ekko~aedat IN im_aedat               " Data de criação do registro
        AND ekbe~budat IN im_budat               " Data de lançamento no documento
        AND eket~eindt IN im_eindt               " Data de remessa do item
        AND ekbe~bwart IN im_bwart.              " Tipo de movimento (administração de estoques)

    IF me->t_alv IS INITIAL.
      RAISE EXCEPTION TYPE lcx_static_check EXPORTING texto = 'Dados não encontrados'. "#EC NOTEXT
    ELSE.
      SORT me->t_alv BY matnr bwart aedat ASCENDING.
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*&      METHOD  exibir_relatorio_alv
*&---------------------------------------------------------------------*
*&        RAISING lcx_static_check
*&---------------------------------------------------------------------*
  METHOD exibir_relatorio_alv.
    DATA:
      o_salv_functions_list TYPE REF TO cl_salv_functions_list, " Generic and User-Defined Functions in List-Type Tables
      o_salv_layout         TYPE REF TO cl_salv_layout        , " Settings for Layout
      o_salv_columns_table  TYPE REF TO cl_salv_columns_table , " Columns in Simple, Two-Dimensional Tables
      o_salv_events_table   TYPE REF TO cl_salv_events_table  , " Events in Simple, Two-Dimensional Tables
      o_cx_salv_msg         TYPE REF TO cx_salv_msg           , " ALV: General Error Class with Message
      o_static_check        TYPE REF TO lcx_static_check      . " Exception

    DATA:
      v_msg_erro TYPE string   , " Erro
      w_msg_erro TYPE bal_s_msg. " Log de aplicação: dados de uma mensagem

    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = o_salv_table
                                 CHANGING t_table      = me->t_alv ).

      CATCH cx_salv_msg INTO o_cx_salv_msg.
        w_msg_erro = o_cx_salv_msg->get_message( ).

        CONCATENATE w_msg_erro-msgv1
                    w_msg_erro-msgv2
                    w_msg_erro-msgv3
                    w_msg_erro-msgv4
               INTO v_msg_erro SEPARATED BY space.

        RAISE EXCEPTION TYPE lcx_static_check EXPORTING texto = v_msg_erro.
    ENDTRY.

    me->modificar_pfstatus_alv( CHANGING salv_functions_list = o_salv_functions_list ).

    me->modificar_layout_alv( CHANGING salv_layout = o_salv_layout ).

    TRY.
        me->modificar_colunas_alv( CHANGING salv_columns_table = o_salv_columns_table ).

      CATCH lcx_static_check INTO o_static_check.
        RAISE EXCEPTION TYPE lcx_static_check EXPORTING texto = o_static_check->msg_erro.
    ENDTRY.

    o_salv_events_table = o_salv_table->get_event( ).

    SET HANDLER me->on_link_click FOR o_salv_events_table.

    o_salv_table->display( ).

  ENDMETHOD.

*&---------------------------------------------------------------------*
*&      METHOD  modificar_pfstatus_alv
*&---------------------------------------------------------------------*
*&        CHANGING salv_functions_list TYPE REF TO cl_salv_functions_list
*&---------------------------------------------------------------------*
  METHOD modificar_pfstatus_alv.
    salv_functions_list = o_salv_table->get_functions( ).
    salv_functions_list->set_all( abap_true )          .
  ENDMETHOD.

*&---------------------------------------------------------------------*
*&      METHOD  modificar_layout_alv
*&---------------------------------------------------------------------*
*&        CHANGING salv_layout TYPE REF TO cl_salv_layout
*&---------------------------------------------------------------------*
  METHOD modificar_layout_alv.
    DATA:
      w_layout_key TYPE salv_s_layout_key. " Layout chave

    CONSTANTS:
      c_variante_default TYPE slis_vari VALUE 'DEFAULT'.

    salv_layout = o_salv_table->get_layout( ).

    w_layout_key-report = sy-repid.

    salv_layout->set_key( w_layout_key )                                .
    salv_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
    salv_layout->set_default( abap_true )                               .
    salv_layout->set_initial_layout( c_variante_default )               .
  ENDMETHOD.

*&---------------------------------------------------------------------*
*&      METHOD  modificar_colunas_alv
*&---------------------------------------------------------------------*
*&        CHANGING salv_columns_table TYPE REF TO cl_salv_columns_table
*&        RAISING lcx_static_check
*&---------------------------------------------------------------------*
  METHOD modificar_colunas_alv.
    DATA:
      o_salv_column_table  TYPE REF TO cl_salv_column_table, " Column Description of Simple, Two-Dimensional Tables
      o_cx_salv_not_found  TYPE REF TO cx_salv_not_found   , " ALV: General Error Class (Checked During Syntax Check)
      o_cx_salv_data_error TYPE REF TO cx_salv_data_error  . " ALV: General Error Class (Checked During Syntax Check)

    DATA:
      v_msg_erro TYPE string.

    salv_columns_table = o_salv_table->get_columns( ).
    salv_columns_table->set_optimize( abap_true )    .

    TRY.
*       Nº do documento de compras
        o_salv_column_table ?= salv_columns_table->get_column( me->c_docto_compras ).

        o_salv_column_table->set_cell_type( if_salv_c_cell_type=>hotspot ).

      CATCH cx_salv_not_found INTO o_cx_salv_not_found.
        v_msg_erro = o_cx_salv_not_found->get_text( ).
        RAISE EXCEPTION TYPE lcx_static_check EXPORTING texto = v_msg_erro.

      CATCH cx_salv_data_error INTO o_cx_salv_data_error.
        v_msg_erro = o_cx_salv_data_error->get_text( ).
        RAISE EXCEPTION TYPE lcx_static_check EXPORTING texto = v_msg_erro.
    ENDTRY.

    TRY.
*       Data de remessa do item
        o_salv_column_table ?= salv_columns_table->get_column('LFDAT').

        o_salv_column_table->set_short_text('Dt Rem. RC'   ). "#EC NOTEXT
        o_salv_column_table->set_long_text('Data Rem. RC'  ). "#EC NOTEXT
        o_salv_column_table->set_medium_text('Data Rem. RC'). "#EC NOTEXT

      CATCH cx_salv_not_found INTO o_cx_salv_not_found.
        v_msg_erro = o_cx_salv_not_found->get_text( ).
        RAISE EXCEPTION TYPE lcx_static_check EXPORTING texto = v_msg_erro.
    ENDTRY.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*&      METHOD  on_link_click
*&---------------------------------------------------------------------*
*&        FOR EVENT link_click OF cl_salv_events_table
*&          IMPORTING row    TYPE SALV_DE_ROW
*&                    column TYPE SALV_DE_COLUMN
*&---------------------------------------------------------------------*
  METHOD on_link_click.
    DATA:
       w_alv LIKE LINE OF me->t_alv.

    READ TABLE me->t_alv
    INTO w_alv
    INDEX row.

    IF w_alv IS INITIAL.
      RETURN.
    ENDIF.

    CASE column.
      WHEN me->c_docto_compras.
        SET PARAMETER ID 'BES' FIELD w_alv-ebeln.
        CALL TRANSACTION me->c_me23n.
    ENDCASE.

  ENDMETHOD.                    "on_link_click

ENDCLASS.                    "lcl_alv IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcx_static_check IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcx_static_check IMPLEMENTATION.

*&---------------------------------------------------------------------*
*&      METHOD  constructor
*&---------------------------------------------------------------------*
*&        IMPORTING texto TYPE string.
*&---------------------------------------------------------------------*
  METHOD constructor.
    super->constructor( ).
    me->msg_erro = texto.
  ENDMETHOD.
ENDCLASS.
