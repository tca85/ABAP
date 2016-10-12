*----------------------------------------------------------------------*
*                       xxxxxxxxxxxxxxxxx                              *
*----------------------------------------------------------------------*
* Programa : YSDR0017                                                  *
* Transação: YSDR0017                                                  *
* Descrição: Modificação em massa do local de expedição de ordens      *
*            de venda através dos ítens                                *
* Tipo     : Relatório ALV                                             *
* Módulo   : SD                                                        *
* Funcional: xxxxxxxxxxxx                                              *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  25.03.2015  #96253  - Desenvolvimento inicial              *
*----------------------------------------------------------------------*
REPORT ysdr0017 NO STANDARD PAGE HEADING.

*----------------------------------------------------------------------*
*       CLASS lcx_local_exception  DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcx_local_exception DEFINITION
INHERITING FROM cx_static_check.
  PUBLIC SECTION.
    DATA msg_erro TYPE string.

    METHODS constructor
      IMPORTING text TYPE string.
ENDCLASS.                    "lcx_local_exception DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.

*--------------------------------------------------------------
* Sessão Pública
*--------------------------------------------------------------
  PUBLIC SECTION.

*--------------------------------------------------------------
*   Atributos públicos
*--------------------------------------------------------------
    TYPES:
     BEGIN OF ty_ordem_venda,
       vbeln TYPE vbak-vbeln, " Documento de vendas
       erdat TYPE vbak-erdat, " Data de criação do registro
       auart TYPE vbak-auart,
       posnr TYPE vbap-posnr, " Item do documento de vendas
       matnr TYPE vbap-matnr, " Nº do material
       vstel TYPE vbap-vstel, " Local de expedição/local de recebimento de mercadoria
     END OF ty_ordem_venda  .

    TYPES:
      tp_ordem_venda TYPE STANDARD TABLE OF ty_ordem_venda WITH DEFAULT KEY.

    TYPES:
      r_vbeln TYPE RANGE OF vbap-vbeln, " Documento de vendas
      r_auart TYPE RANGE OF VBAK-AUART,
      r_erdat TYPE RANGE OF vbap-erdat, " Data de criação do registro
      r_vstel TYPE RANGE OF vbap-vstel, " Local de expedição/local de recebimento de mercadoria
      r_matnr TYPE RANGE OF VBAP-MATNR.

*--------------------------------------------------------------
*   Métodos públicos
*--------------------------------------------------------------
    METHODS:
      set_ordens_venda
        IMPORTING im_ordem_venda     TYPE r_vbeln
                  im_data_criacao    TYPE r_erdat
                  im_local_expedicao TYPE r_vstel
                  im_tipo            TYPE r_auart
                  im_matnr           TYPE r_matnr
          RAISING lcx_local_exception,

      exibir_ordens_venda_itens
        RAISING lcx_local_exception,

      set_t_ordem_venda
        IMPORTING im_t_ordem_venda TYPE tp_ordem_venda,

      get_t_ordem_venda
        RETURNING value(ex_t_ordem_venda) TYPE tp_ordem_venda.

*--------------------------------------------------------------
* Sessão privada
*--------------------------------------------------------------
  PRIVATE SECTION.

*--------------------------------------------------------------
*   Atributos privados
*--------------------------------------------------------------
    TYPES:
      BEGIN OF ty_log_bapi   ,
        vbeln TYPE vbap-vbeln, " Documento de vendas
        posnr TYPE vbap-posnr, " Item do documento de vendas
        type  TYPE bapi_mtype, " Ctg.mens.: S sucesso, E erro, W aviso, I inform., A cancel.
        msg   TYPE bapi_msg  , " Texto de mensagem
      END OF ty_log_bapi     .

    DATA:
      t_ordem_venda TYPE STANDARD TABLE OF ty_ordem_venda,
      t_log_bapi    TYPE STANDARD TABLE OF ty_log_bapi   .

    TYPES:
      tp_log_bapi TYPE STANDARD TABLE OF ty_log_bapi WITH DEFAULT KEY.

    DATA
      o_salv_table TYPE REF TO cl_salv_table.

    CONSTANTS:
      c_btn_selecionar_linhas TYPE salv_de_function VALUE 'SEL_OVS'.

*--------------------------------------------------------------
*   Métodos privados
*--------------------------------------------------------------
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function,

      get_linhas_selecionadas
        RAISING lcx_local_exception,

      set_local_expedicao
        IMPORTING im_t_ordem_venda   TYPE tp_ordem_venda
                  im_local_expedicao TYPE vbap-vstel
         RAISING lcx_local_exception,

      set_log_bapi
        IMPORTING im_w_log_bapi TYPE ty_log_bapi,

      get_log_bapi
        RETURNING value(ex_t_log_bapi) TYPE tp_log_bapi,

      exibir_log_bapi
        RAISING lcx_local_exception,

      atualizar_ordens_venda_itens
        RAISING lcx_local_exception.

ENDCLASS.                    "lcl_handle_events DEFINITION

*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_tela_selecao,
    vbeln TYPE vbap-vbeln , " Documento de vendas
    auart TYPE vbak-auart ,
    matnr type vbap-matnr ,
    erdat TYPE vbap-erdat , " Data de criação do registro
    vstel TYPE vbap-vstel , " Local de expedição/local de recebimento de mercadoria
  END OF ty_tela_selecao  .

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
DATA:
   w_tela_selecao TYPE ty_tela_selecao.

*----------------------------------------------------------------------*
* Tela de seleção
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE txt1. " Critério de seleção
SELECT-OPTIONS: s_vbeln FOR w_tela_selecao-vbeln        , " Ordem de vendas
                s_auart FOR w_tela_selecao-auart        , " Tipo Vendas
                s_erdat FOR w_tela_selecao-erdat        , " Data de criação
                s_matnr FOR w_tela_selecao-matnr        ,
                s_vstel FOR w_tela_selecao-vstel        . " Local de expedição
SELECTION-SCREEN END OF BLOCK a1                        .

*----------------------------------------------------------------------*
* Inicialização                                                        *
*----------------------------------------------------------------------*
INITIALIZATION.
  txt1 = 'Critério de seleção'(001).                        "#EC NOTEXT

*----------------------------------------------------------------------*
* START-OF-SELECTION                                                   *
*----------------------------------------------------------------------*
START-OF-SELECTION.

  TRY.
      DATA:
        o_relatorio          TYPE REF TO lcl_handle_events  ,
        o_cx_local_exception TYPE REF TO lcx_local_exception,
        o_cx_root            TYPE REF TO cx_root            ,
        v_msg_erro           TYPE string                    .

      CREATE OBJECT o_relatorio.

*     Seleciona as ordens de venda com seus ítens
      o_relatorio->set_ordens_venda( im_ordem_venda     = s_vbeln[]
                                     im_data_criacao    = s_erdat[]
                                     im_local_expedicao = s_vstel[]
                                     im_tipo            = s_auart[]
                                     im_matnr           = s_matnr[] ).

*     Exibe o relatório ALV para que o usuáro selecione as OVs e ítens
*     para alterar o local de expedição
      o_relatorio->exibir_ordens_venda_itens( ).

    CATCH lcx_local_exception INTO o_cx_local_exception.
      v_msg_erro = o_cx_local_exception->msg_erro.
      MESSAGE v_msg_erro TYPE 'S' DISPLAY LIKE 'E'.         "#EC NOTEXT

    CATCH cx_root INTO o_cx_root.
      v_msg_erro = o_cx_root->get_longtext( ).
      MESSAGE v_msg_erro TYPE 'S' DISPLAY LIKE 'E'.         "#EC NOTEXT
  ENDTRY.

*----------------------------------------------------------------------*
*       CLASS lcx_local_exception IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcx_local_exception IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    msg_erro = text.
  ENDMETHOD.                    "CONSTRUCTOR
ENDCLASS.                    "lcx_local_exception IMPLEMENTATION

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.

*&---------------------------------------------------------------------*
*&      Method  set_ordens_venda
*&---------------------------------------------------------------------*
* --> IMPORTING im_ordem_venda     TYPE r_vbeln
* --> IMPORTING im_data_criacao    TYPE r_erdat
* --> IMPORTING im_local_expedicao TYPE r_vstel
* <-- RAISING   lcx_local_exception
*----------------------------------------------------------------------*
  METHOD set_ordens_venda.
    DATA: t_ordem_venda TYPE STANDARD TABLE OF ty_ordem_venda.

*   Documento de vendas: dados de item
*    SELECT vbeln " Documento de vendas
*           erdat " Data de criação do registro
*           posnr " Item do documento de vendas
*           matnr " Nº do material
*           vstel " Local de expedição/local de recebimento de mercadoria
*    FROM vbap
*    INTO TABLE t_ordem_venda
*    WHERE vbeln IN im_ordem_venda
*    AND erdat IN im_data_criacao
*    AND vstel IN im_local_expedicao.

    SELECT  a~vbeln " Documento de vendas
            a~erdat " Data de criação do registro
            a~auart " tipo doc vendas
            b~posnr " Item do documento de vendas
            b~matnr " Nº do material
            b~vstel " Local de expedição/local de recebimento de mercadoria
      FROM vbak AS a
      INNER JOIN vbap AS b
      ON a~vbeln = b~vbeln
      into TABLE t_ordem_venda
      WHERE
            a~vbeln   IN im_ordem_venda
        AND a~erdat   IN im_data_criacao
        AND b~vstel   IN im_local_expedicao
        AND a~auart   IN im_TIPO
        AND b~matnr   IN im_matnr.

      IF t_ordem_venda IS INITIAL.
        RAISE EXCEPTION TYPE lcx_local_exception
        EXPORTING text = 'Não foram encontradas ordens de venda para o critério informado'. "#EC NOTEXT
      ENDIF.

      SORT t_ordem_venda BY vbeln erdat posnr ASCENDING.

*   Grava a tabela no atributo t_ordem_venda
      me->set_t_ordem_venda( t_ordem_venda ).

    ENDMETHOD.                    "set_ordens_venda

*&---------------------------------------------------------------------*
*&      Method  exibir_ordens_venda_itens
*----------------------------------------------------------------------*
* <-- RAISING lcx_local_exception.
*----------------------------------------------------------------------*
    METHOD exibir_ordens_venda_itens.
      DATA:
         o_salv_events_table   TYPE REF TO cl_salv_events_table  ,
         o_salv_selections     TYPE REF TO cl_salv_selections    ,
         o_salv_functions_list TYPE REF TO cl_salv_functions_list,
         o_salv_columns        TYPE REF TO cl_salv_columns       ,
         o_salv_msg            TYPE REF TO cx_salv_msg           ,
         o_handle_events       TYPE REF TO lcl_handle_events     ,
         v_msg_erro            TYPE string                       .

*   Instancia a classe cl_salv_table e cria o fieldcatalog da tabela interna
*   obs: não funciona se não for o atributo diretamente acessado... me->t_ordem_venda
      TRY.
          cl_salv_table=>factory( IMPORTING r_salv_table = me->o_salv_table
                                   CHANGING t_table      = me->t_ordem_venda ).

        CATCH cx_salv_msg INTO o_salv_msg.
          v_msg_erro = o_salv_msg->get_text( ).

          RAISE EXCEPTION TYPE lcx_local_exception
          EXPORTING text = v_msg_erro.
      ENDTRY.

*   Define a barra de botões (Status GUI) customizada STATUS1000
      me->o_salv_table->set_screen_status( pfstatus      =  'STATUS1000'
                                           report        =  sy-repid
                                           set_functions = me->o_salv_table->c_functions_all ).

*   Define as colunas do ALV como otimizadas, para se ajustarem ao tamanho dos dados
      o_salv_columns = me->o_salv_table->get_columns( ).
      o_salv_columns->set_optimize( abap_true ).

      o_salv_events_table = me->o_salv_table->get_event( ).

*   Associa o evento User_Command ao ALV
      SET HANDLER me->on_user_command FOR o_salv_events_table.

*   Define o tipo de seleção das linhas do ALV
      o_salv_selections = o_salv_table->get_selections( ).
      o_salv_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).

*   Exibe o relatório ALV
      o_salv_table->display( ).
    ENDMETHOD.                    "exibir_ordens_venda_itens

*&---------------------------------------------------------------------*
*&      Method  set_t_ordem_venda
*&---------------------------------------------------------------------*
* --> IMPORTING im_t_ordem_venda  TYPE tp_ordem_venda.
*----------------------------------------------------------------------*
    METHOD set_t_ordem_venda.
      me->t_ordem_venda = im_t_ordem_venda.
    ENDMETHOD.                    "set_t_ordem_venda

*&---------------------------------------------------------------------*
*&      Method  get_t_ordem_venda
*&---------------------------------------------------------------------*
* <-- RETURNING ex_t_ordem_venda TYPE tp_ordem_venda.
*----------------------------------------------------------------------*
    METHOD get_t_ordem_venda.
      ex_t_ordem_venda = me->t_ordem_venda.
    ENDMETHOD.                    "set_t_ordem_venda
*&---------------------------------------------------------------------*
*&      Method  on_user_command
*&---------------------------------------------------------------------*
* --> IMPORTING e_salv_function TYPE salv_de_function
*----------------------------------------------------------------------*
    METHOD on_user_command.

      TRY.
          DATA:
             o_cx_local_exception TYPE REF TO lcx_local_exception,
             v_msg_erro           TYPE string                    .

          CASE e_salv_function.
            WHEN c_btn_selecionar_linhas. " SEL_OVS
              me->get_linhas_selecionadas( ).
              me->exibir_log_bapi( ).
              me->atualizar_ordens_venda_itens( ).
          ENDCASE.

        CATCH lcx_local_exception INTO o_cx_local_exception.
          v_msg_erro = o_cx_local_exception->msg_erro.
          MESSAGE v_msg_erro TYPE 'S' DISPLAY LIKE 'E'.     "#EC NOTEXT
      ENDTRY.

    ENDMETHOD.                    "on_user_command

*&---------------------------------------------------------------------*
*&      Method  get_linhas_selecionadas
*&---------------------------------------------------------------------*
* <-- RAISING lcx_local_exception.
*----------------------------------------------------------------------*
    METHOD get_linhas_selecionadas.

      DATA:
        o_salv_selections   TYPE REF TO cl_salv_selections       ,
        t_linha_selecionada TYPE salv_t_row                      ,
        t_ordem_venda_selec LIKE me->t_ordem_venda               ,
        w_ordem_venda_selec LIKE LINE OF t_ordem_venda_selec     ,
        t_ordem_venda       TYPE STANDARD TABLE OF ty_ordem_venda,
        w_linha_selecionada LIKE LINE OF t_linha_selecionada     ,
        w_ordem_venda       LIKE LINE OF me->t_ordem_venda       .

      t_ordem_venda = get_t_ordem_venda( ).

      o_salv_selections = me->o_salv_table->get_selections( ).

*   Obtém o índice das linhas selecionadas no ALV
      t_linha_selecionada = o_salv_selections->get_selected_rows( ).

      LOOP AT t_linha_selecionada INTO w_linha_selecionada.
        CLEAR w_ordem_venda.

        READ TABLE t_ordem_venda
        INTO w_ordem_venda
        INDEX w_linha_selecionada.

        IF sy-subrc = 0.
          APPEND w_ordem_venda TO t_ordem_venda_selec.
        ENDIF.
      ENDLOOP.

      LOOP AT t_ordem_venda_selec INTO w_ordem_venda_selec.
        READ TABLE t_ordem_venda
        INTO w_ordem_venda
        WITH KEY vbeln = w_ordem_venda_selec-vbeln
                 posnr = w_ordem_venda_selec-posnr.

        IF sy-subrc = 0.
          DELETE t_ordem_venda INDEX sy-tabix.
        ENDIF.
      ENDLOOP.

      me->set_t_ordem_venda( t_ordem_venda ).

      IF t_ordem_venda_selec IS NOT INITIAL.
        DATA:
          t_local_expedicao TYPE TABLE OF sval,
          w_local_expedicao TYPE sval         ,
          v_local_expedicao TYPE vbap-vstel   .

        w_local_expedicao-tabname   = 'VBAP'         .      "#EC NOTEXT
        w_local_expedicao-fieldname = 'VSTEL'        .      "#EC NOTEXT
        APPEND w_local_expedicao TO t_local_expedicao.

        CALL FUNCTION 'POPUP_GET_VALUES'
          EXPORTING
            popup_title     = 'Informe o novo local de expedição'(002) "#EC NOTEXT
          TABLES
            fields          = t_local_expedicao
          EXCEPTIONS
            error_in_fields = 1
            OTHERS          = 2.

        READ TABLE t_local_expedicao
        INTO w_local_expedicao
        WITH KEY fieldname = 'VSTEL'.                       "#EC NOTEXT

        IF sy-subrc = 0.
          v_local_expedicao = w_local_expedicao-value.

          IF v_local_expedicao IS INITIAL.
            RAISE EXCEPTION TYPE lcx_local_exception
             EXPORTING text = 'Informe o local de expedição'. "#EC NOTEXT
          ELSE.
            DATA v_qtd_registros TYPE i.

            SELECT COUNT( DISTINCT vstel )
             FROM tvst
             INTO v_qtd_registros
             WHERE vstel = v_local_expedicao.

            IF v_qtd_registros = 0.
              RAISE EXCEPTION TYPE lcx_local_exception
               EXPORTING text = 'Local de expedição inválido'. "#EC NOTEXT
            ENDIF.

          ENDIF.

          SORT t_ordem_venda_selec BY vbeln ASCENDING.

          me->set_local_expedicao( EXPORTING im_t_ordem_venda   = t_ordem_venda_selec
                                             im_local_expedicao = v_local_expedicao   ).
        ENDIF.

      ENDIF.

    ENDMETHOD.                    "get_linhas_selecionadas

*&---------------------------------------------------------------------*
*&      Method  set_local_expedicao
*&---------------------------------------------------------------------*
* --> IMPORTING im_t_ordem_venda   TYPE lcl_ysdr0017=>tp_ordem_venda
* --> IMPORTING im_local_expedicao TYPE vbap-vstel.
* <-- RAISING lcx_local_exception.
*----------------------------------------------------------------------*
    METHOD set_local_expedicao.
      TYPES:
        BEGIN OF ty_ov         ,
          vbeln TYPE vbap-vbeln,
        END OF ty_ov           .

      DATA:
        t_retorno_bapi          TYPE STANDARD TABLE OF bapiret2  ,
        t_retorno_bapi_aux      TYPE STANDARD TABLE OF bapiret2  ,
        t_item_ordem_venda      TYPE STANDARD TABLE OF bapisditm ,
        t_item_x_ordem_venda    TYPE STANDARD TABLE OF bapisditmx,
        t_ov                    TYPE STANDARD TABLE OF ty_ov     ,
        w_ordem_venda           LIKE LINE OF im_t_ordem_venda    ,
        w_ov                    LIKE LINE OF t_ov                ,
        w_item_ordem_venda      LIKE LINE OF t_item_ordem_venda  ,
        w_item_x_ordem_venda    LIKE LINE OF t_item_x_ordem_venda,
        w_retorno_bapi          LIKE LINE OF t_retorno_bapi      ,
        w_log_bapi              TYPE ty_log_bapi                 ,
        w_cabecalho_ordem_venda TYPE bapisdh1x                   ,
        v_ordem_venda           TYPE bapivbeln-vbeln             ,
        v_indice_vbap           TYPE sy-tabix                    .

      CONSTANTS:
        c_update TYPE updkz VALUE 'U'.

      LOOP AT im_t_ordem_venda INTO w_ordem_venda.
        CLEAR w_ov.
        w_ov-vbeln = w_ordem_venda-vbeln.
        APPEND w_ov TO t_ov.
      ENDLOOP.

      SORT t_ov BY vbeln ASCENDING.

      DELETE ADJACENT DUPLICATES FROM t_ov.

      LOOP AT t_ov INTO w_ov.
        FREE: t_retorno_bapi, t_item_ordem_venda, t_item_x_ordem_venda,
              v_ordem_venda, w_cabecalho_ordem_venda.

        READ TABLE im_t_ordem_venda
        TRANSPORTING NO FIELDS
        WITH KEY vbeln = w_ov-vbeln
        BINARY SEARCH.

        IF sy-subrc = 0.
          v_indice_vbap = sy-tabix.
        ELSE.
          CONTINUE.
        ENDIF.

        LOOP AT im_t_ordem_venda INTO w_ordem_venda FROM v_indice_vbap.
          IF w_ordem_venda-vbeln <> w_ov-vbeln.
            EXIT.
          ENDIF.

          CLEAR: w_item_ordem_venda, w_item_x_ordem_venda.

          w_item_ordem_venda-itm_number = w_ordem_venda-posnr  . " Item do documento de vendas
          w_item_ordem_venda-ship_point = im_local_expedicao   . " Local de expedição/local de recebimento de mercadoria
          APPEND w_item_ordem_venda TO t_item_ordem_venda      .

          w_item_x_ordem_venda-itm_number = w_ordem_venda-posnr. " Item do documento de vendas
          w_item_x_ordem_venda-updateflag = abap_true          . " Código de atualização
          w_item_x_ordem_venda-ship_point = abap_true          . " Campo modificado
          APPEND w_item_x_ordem_venda TO t_item_x_ordem_venda  .
        ENDLOOP.

        v_ordem_venda = w_ordem_venda-vbeln.
        w_cabecalho_ordem_venda-updateflag = c_update.

        CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
          EXPORTING
            salesdocument    = v_ordem_venda
            order_header_inx = w_cabecalho_ordem_venda
          TABLES
            return           = t_retorno_bapi
            order_item_in    = t_item_ordem_venda
            order_item_inx   = t_item_x_ordem_venda.

        APPEND LINES OF t_retorno_bapi TO t_retorno_bapi_aux.

        READ TABLE t_retorno_bapi
        INTO w_retorno_bapi
        WITH KEY type = 'E'.

        IF sy-subrc = 0.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
            IMPORTING
              return = w_retorno_bapi.

        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait   = abap_true
            IMPORTING
              return = w_retorno_bapi.
        ENDIF.

        LOOP AT t_retorno_bapi INTO w_retorno_bapi.
          CLEAR w_log_bapi.

          w_log_bapi-vbeln = w_ordem_venda-vbeln      .
          w_log_bapi-posnr = w_retorno_bapi-message_v2.
          w_log_bapi-type  = w_retorno_bapi-type      .
          w_log_bapi-msg   = w_retorno_bapi-message   .

          me->set_log_bapi( w_log_bapi ).

        ENDLOOP.

      ENDLOOP.

    ENDMETHOD.                    "set_local_expedicao

*&---------------------------------------------------------------------*
*&      Method  set_log_bapi
*&---------------------------------------------------------------------*
* --> IMPORTING im_w_log_bapi TYPE ty_log_bapi.
*----------------------------------------------------------------------*
    METHOD set_log_bapi.
      IF im_w_log_bapi IS NOT INITIAL.
        APPEND im_w_log_bapi TO me->t_log_bapi.
      ENDIF.
    ENDMETHOD.                    "set_log_bapi

*&---------------------------------------------------------------------*
*&      Method  get_log_bapi
*&---------------------------------------------------------------------*
* <-- RETURNING ex_t_log_bapi TYPE tp_log_bapi.
*----------------------------------------------------------------------*
    METHOD get_log_bapi.
      ex_t_log_bapi = me->t_log_bapi.
    ENDMETHOD.                    "get_log_bapi

*&---------------------------------------------------------------------*
*&      Method  exibir_log_bapi
*&---------------------------------------------------------------------*
* <-- RAISING lcx_local_exception.
*----------------------------------------------------------------------*
    METHOD exibir_log_bapi.
      DATA:
         t_log_bapi            TYPE STANDARD TABLE OF ty_log_bapi,
         o_salv_table_log_bapi TYPE REF TO cl_salv_table         ,
         o_salv_msg            TYPE REF TO cx_salv_msg           ,
         v_msg_erro            TYPE string                       .

      t_log_bapi = me->get_log_bapi( ).

      IF t_log_bapi IS INITIAL.
        RAISE EXCEPTION TYPE lcx_local_exception
         EXPORTING text = 'Não foram gerados logs de alteração das ordens de venda'.
      ENDIF.

*   Instancia a classe cl_salv_table e cria o fieldcatalog da tabela interna
      TRY.
          cl_salv_table=>factory( IMPORTING r_salv_table = o_salv_table_log_bapi
                                   CHANGING t_table      = t_log_bapi ).

        CATCH cx_salv_msg INTO o_salv_msg.
          v_msg_erro = o_salv_msg->get_text( ).

          RAISE EXCEPTION TYPE lcx_local_exception
            EXPORTING text = v_msg_erro.
      ENDTRY.

*   Exibe o relatório ALV com detalhes do log da BAPI
      o_salv_table_log_bapi->display( ).

    ENDMETHOD.                    "exibir_log_bapi

*&---------------------------------------------------------------------*
*&      Method  atualizar_ordens_venda_itens
*&---------------------------------------------------------------------*
* <-- RAISING lcx_local_exception.
*----------------------------------------------------------------------*
    METHOD atualizar_ordens_venda_itens.
      DATA:
         t_ordem_venda TYPE STANDARD TABLE OF ty_ordem_venda.

      t_ordem_venda = me->get_t_ordem_venda( ).

      IF t_ordem_venda IS INITIAL.
        LEAVE TO SCREEN 0.
      ELSE.
        me->o_salv_table->refresh( refresh_mode = if_salv_c_refresh=>full ).
      ENDIF.

    ENDMETHOD.                    "atualizar_ordens_venda_itens

  ENDCLASS.                    "lcl_handle_events IMPLEMENTATION