*----------------------------------------------------------------------*
*                       ACHÉ LABORATÓRIOS                              *
*----------------------------------------------------------------------*
* Programa : YNQM_REPORT                                               *
* Transação: YNQM_REPORT                                               *
* Descrição: Relatório de avaliação de fornecedores de acordo com      *
*            a qualidade do recebimento para premiações do Aché        *
* Tipo     : Relatório ALV                                             *
* Módulo   : QM                                                        *
* Projeto  : Notas de QM (Não-conformidade no recebimento físico)      *
* Funcional: Meire Vicente Casale                                      *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  11.10.2013  #63782 - Desenvolvimento inicial               *
* ACTHIAGO  12.12.2013  #63782 - Inclusão de memory id nos sel-options *
* ACTHIAGO  27.01.2014  #63782 - Inclusão dos campos Especificação,    *
*                                Resposta à RDF, Suporte Técnico,      *
*                                Pontuação Qualidade e Qtd Notas QM    *
* ACTHIAGO  31.12.2013  #63782 - Tratamento para Notas de QM sem lote  *
*----------------------------------------------------------------------*

REPORT ynqm_report NO STANDARD PAGE HEADING.

TYPE-POOLS: icon.

TABLES: marc, " Dados de centro para material
        mara, " Dados gerais de material
        lfa1. " Mestre de fornecedores (parte geral)

*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_fornecedor_lote     ,
   lifnr      TYPE qals-lifnr     , " Nº conta do fornecedor
   werk       TYPE qals-werk      , " Centro
   hersteller TYPE qals-hersteller, " Nº fabricante
   matnr      TYPE qals-matnr     , " Nº do material
   qtd_lotes  TYPE i              , " Quantidade de lotes
  END OF ty_fornecedor_lote       ,

  BEGIN OF ty_lotes_objetos       ,
   lifnr      TYPE qals-lifnr     , " Nº conta do fornecedor
   werk       TYPE qals-werk      , " Centro
   hersteller TYPE qals-hersteller, " Nº fabricante
   matnr      TYPE qals-matnr     , " Nº do material
   objnr      TYPE qals-objnr     , " Nº objeto
   prueflos   TYPE qals-prueflos  , " Nº do lote de controle
   charg      TYPE qals-charg     , " Nº do lote
  END OF ty_lotes_objetos         ,

  BEGIN OF ty_lote_ctr_validos    ,
   lifnr      TYPE qals-lifnr     , " Nº conta do fornecedor
   werk       TYPE qals-werk      , " Centro
   hersteller TYPE qals-hersteller, " Nº fabricante
   matnr      TYPE qals-matnr     , " Nº do material
   prueflos   TYPE qals-prueflos  , " Nº do lote de controle
   charg      TYPE qals-charg     , " Nº do lote
  END OF ty_lote_ctr_validos      ,

  BEGIN OF ty_charg               ,
   lifnr      TYPE qals-lifnr     , " Nº conta do fornecedor
   werk       TYPE qals-werk      , " Centro
   hersteller TYPE qals-hersteller, " Nº fabricante
   matnr      TYPE qals-matnr     , " Nº do material
   charg      TYPE qals-charg     , " Nº do lote
  END OF ty_charg                 ,

  BEGIN OF ty_forn_nota_qm                           ,
   qmnum        TYPE qmel-qmnum                      , " Nº da nota
   qmart        TYPE qmel-qmart                      , " Tipo de nota
   erdat        TYPE qmel-erdat                      , " Data de criação do registro
   matnr        TYPE qmel-matnr                      , " Nº do material
   objnr        TYPE qmel-objnr                      , " Nº objeto para administração de status
   lifnum       TYPE qmel-lifnum                     , " Nº conta do fornecedor
   mawerk       TYPE qmel-mawerk                     , " Centro para material
   hersteller   TYPE qmel-hersteller                 , " Nº fabricante
   yypto_espec  TYPE yalv_nqm_avaliacao-pto_espec    , " Pontuação da Especificação
   yypto_rdf    TYPE yalv_nqm_avaliacao-pto_rdf      , " Pontuação da RDF
   yypto_suptec TYPE yalv_nqm_avaliacao-pto_suptec   , " Pontuação do Suporte Técnico
  END OF ty_forn_nota_qm                             ,

  BEGIN OF ty_qtd_nota_qm                            ,
   matnr        TYPE qmel-matnr                      , " Nº do material
   lifnum       TYPE qmel-lifnum                     , " Nº conta do fornecedor
   mawerk       TYPE qmel-mawerk                     , " Centro para material
   hersteller   TYPE qmel-hersteller                 , " Nº fabricante
   qtd_nqm      TYPE i                               , " Quantidade de notas de QM
   yypto_espec  TYPE yalv_nqm_avaliacao-pto_espec    , " Pontuação da Especificação
   yypto_rdf    TYPE yalv_nqm_avaliacao-pto_rdf      , " Pontuação da RDF
   yypto_suptec TYPE yalv_nqm_avaliacao-pto_suptec   , " Pontuação do Suporte Técnico
   pto_qa       TYPE yalv_nqm_avaliacao-pto_qualidade, " Pontuação de Qualidade
  END OF ty_qtd_nota_qm                              ,

  BEGIN OF ty_alv_nota_qm         ,
   qmnum      TYPE qmel-qmnum     , " Nº da nota
   erdat      TYPE qmel-erdat     , " Data de criação do registro
   matnr      TYPE qmel-matnr     , " Nº do material
   lifnum     TYPE qmel-lifnum    , " Nº conta do fornecedor
   mawerk     TYPE qmel-mawerk    , " Centro para material
   hersteller TYPE qmel-hersteller, " Nº fabricante
  END OF ty_alv_nota_qm           ,

  BEGIN OF ty_forn_periodo        ,
   lifnr      TYPE qals-lifnr     , " Nº conta do fornecedor
   werk       TYPE qals-werk      , " Centro
   hersteller TYPE qals-hersteller, " Nº fabricante
   matnr      TYPE qals-matnr     , " Nº do materia
   mtart      TYPE mara-mtart     , " Tipo de material
  END OF ty_forn_periodo          ,

  BEGIN OF ty_alv_lotes           ,
   lifnr      TYPE qals-lifnr     , " Nº conta do fornecedor
   werk       TYPE qals-werk      , " Centro
   hersteller TYPE qals-hersteller, " Nº fabricante
   matnr      TYPE qals-matnr     , " Nº do material
   charg      TYPE qals-charg     , " Número do lote
   prueflos   TYPE qals-prueflos  , " Nº lote de controle
  END OF ty_alv_lotes             ,

  BEGIN OF ty_centro              ,
   werks      TYPE t001w-werks    , " Centro
   name1      TYPE t001w-name1    , " Nome do centro
  END OF ty_centro                ,

  BEGIN OF ty_fornecedor          ,
   lifnr      TYPE lfa1-lifnr     , " Nº conta do fornecedor
   name1      TYPE lfa1-name1     , " Nome do fornecedor
  END OF ty_fornecedor            ,

  BEGIN OF ty_fabricante          ,
   lifnr      TYPE lfa1-lifnr     , " Nº conta do fabricante
   name1      TYPE lfa1-name1     , " Nome do fabricante
  END OF ty_fabricante            ,

  BEGIN OF ty_material            ,
   matnr      TYPE makt-matnr     , " Nº do material
   maktx      TYPE makt-maktx     , " Texto breve de material
  END OF ty_material              ,

  BEGIN OF ty_justificativa       , " Justificativas separadas por fornecedor/centro
   lifnr      TYPE lfa1-lifnr     , " Nº conta do fornecedor
   werks      TYPE t001w-werks    , " Centro
   value      TYPE tline-tdline   , " Linha de texto
  END OF ty_justificativa         ,

  BEGIN OF ty_val_popup           , " Justificativa (opcional) da pontuação
   value      TYPE tline-tdline   , " Linha de texto
  END OF ty_val_popup             .

*----------------------------------------------------------------------*
* Tabelas internas                                                     *
*----------------------------------------------------------------------*
DATA:
  t_alv_pontuacao     TYPE STANDARD TABLE OF yalv_nqm_preenche_pto, " Nota QM : ALV - Preenche pontuação dos fornecedores
  t_alv_avaliacao     TYPE STANDARD TABLE OF yalv_nqm_avaliacao   , " Nota QM : ALV - Avaliar pontuação dos fornecedores
  t_pontuacao_compras TYPE STANDARD TABLE OF ytnqm_pontuacao      , " Nota QM : Pontuação de Fornecedores
  t_alv_lotes         TYPE STANDARD TABLE OF ty_alv_lotes         , " ALV com detalhe dos lotes de controle selecionados
  t_alv_nota_qm       TYPE STANDARD TABLE OF ty_alv_nota_qm       , " ALV com detalhes das notas de QM selecionadas
  t_forn_com_lote     TYPE STANDARD TABLE OF ty_fornecedor_lote   , " Fornecedores que possuem lotes
  t_forn_subcontrat   TYPE STANDARD TABLE OF ty_fornecedor_lote   , " Fornecedores com subcontratação
  t_forn_nota_qm      TYPE STANDARD TABLE OF ty_forn_nota_qm      , " Fornecedores com Notas de QM
  t_nqm_sem_lote      TYPE STANDARD TABLE OF ty_forn_nota_qm      , " Fornecedores com notas de QM sem lotes
  t_qtd_nota_qm       TYPE STANDARD TABLE OF ty_qtd_nota_qm       , " Quantidade de Notas de QM por fornecedor/fabricante/material/centro
  t_qtd_nqm_sem_lote  TYPE STANDARD TABLE OF ty_qtd_nota_qm       , " Quantidade de Notas de QM sem lote
  t_lotes_objetos     TYPE STANDARD TABLE OF ty_lotes_objetos     , " Lotes e nº dos objetos
  t_qtd_lotes_validos TYPE STANDARD TABLE OF ty_lote_ctr_validos  , " QTD de lotes válidos
  t_charg_validos     TYPE STANDARD TABLE OF ty_charg             , " Lotes válidos
  t_forn_periodo      TYPE STANDARD TABLE OF ty_forn_periodo      , " Fornecedores com entrada no período selecionado
  t_centro            TYPE STANDARD TABLE OF ty_centro            , " Nome do centro
  t_fornecedor        TYPE STANDARD TABLE OF ty_fornecedor        , " Nome do forcendor
  t_fabricante        TYPE STANDARD TABLE OF ty_fabricante        , " Nome do fabricante
  t_material          TYPE STANDARD TABLE OF ty_material          , " Nome do material
  t_justificativa     TYPE STANDARD TABLE OF ty_justificativa     , " Justificativas separadas por fornecedor/centro
  t_val_popup         TYPE STANDARD TABLE OF ty_val_popup         , " Justificativa (opcional) da pontuação
  t_fcode             TYPE STANDARD TABLE OF sy-ucomm             . " Botões da barra de status (pf-status)

DATA:
  t_fieldcat TYPE lvc_t_fcat,
  w_fieldcat TYPE lvc_s_fcat.

*----------------------------------------------------------------------*
* Ranges                                                               *
*----------------------------------------------------------------------*
DATA:
  r_periodo_aval  TYPE RANGE OF sy-datum,
  r_periodo_atual TYPE RANGE OF sy-datum,
  r_periodo_anter TYPE RANGE OF sy-datum.

*----------------------------------------------------------------------*
* Work Areas                                                           *
*----------------------------------------------------------------------*
DATA:
  w_alv_pontuacao     LIKE LINE OF t_alv_pontuacao    ,
  w_alv_avaliacao     LIKE LINE OF t_alv_avaliacao    ,
  w_pontuacao_compras LIKE LINE OF t_pontuacao_compras,
  w_alv_lotes         LIKE LINE OF t_alv_lotes        ,
  w_alv_nota_qm       LIKE LINE OF t_alv_nota_qm      ,
  w_lotes_objetos     LIKE LINE OF t_lotes_objetos    ,
  w_qtd_lotes_validos LIKE LINE OF t_qtd_lotes_validos,
  w_charg_validos     LIKE LINE OF t_charg_validos    ,
  w_forn_com_lote     LIKE LINE OF t_forn_com_lote    ,
  w_forn_nota_qm      LIKE LINE OF t_forn_nota_qm     ,
  w_nqm_sem_lote      LIKE LINE OF t_nqm_sem_lote     ,
  w_qtd_nota_qm       LIKE LINE OF t_qtd_nota_qm      ,
  w_qtd_nqm_sem_lote  LIKE LINE OF t_qtd_nqm_sem_lote ,
  w_centro            LIKE LINE OF t_centro           ,
  w_fornecedor        LIKE LINE OF t_fornecedor       ,
  w_fabricante        LIKE LINE OF t_fabricante       ,
  w_material          LIKE LINE OF t_material         ,
  w_justificativa     LIKE LINE OF t_justificativa    ,
  w_val_popup         LIKE LINE OF t_val_popup        ,
  w_periodo           LIKE LINE OF r_periodo_atual    .

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
DATA:
  ok_code           TYPE sy-ucomm   ,
  v_indice          TYPE sy-tabix   ,
  vl_qtd_registros  TYPE i          ,
  v_periodo_selec   TYPE c LENGTH 20,
  v_pontuacao_salva TYPE c LENGTH 01,
  v_contem_periodo  TYPE c LENGTH 01.

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
CONSTANTS:
  c_container_alv     TYPE scrfname        VALUE 'CONT_ALV'             ,
  c_tabela_alv_pont   TYPE ddobjname       VALUE 'YALV_NQM_PREENCHE_PTO',
  c_tabela_alv_avalia TYPE ddobjname       VALUE 'YALV_NQM_AVALIACAO'   ,
  c_nota_qm           TYPE tq80-qmart      VALUE 'Z1'                   ,
  c_tela_alv          TYPE sy-dynnr        VALUE '1001'                 ,
  c_entrada_pedido    TYPE tq30-art        VALUE '01'                   ,
  c_entrada_mercad    TYPE tq31-herkunft   VALUE '01'                   ,
  c_lote_reprovado    TYPE qpcd-code       VALUE '03'                   ,
  c_lote_estornado    TYPE tj02t-istat     VALUE 'I0224'                ,
  c_marc_eliminacao   TYPE tj02t-istat     VALUE 'I0076'                ,
  c_campo_search_help TYPE dd03l-fieldname VALUE 'F0001'                ,
  c_f4_preco          TYPE dd03l-fieldname VALUE 'PRECO'                ,
  c_f4_pontual        TYPE dd03l-fieldname VALUE 'PONTUAL'              ,
  c_f4_relac          TYPE dd03l-fieldname VALUE 'RELAC'                ,
  c_hotspot_justif    TYPE dd03l-fieldname VALUE 'JUSTIF'               ,
  c_hotspot_fornec    TYPE dd03l-fieldname VALUE 'LIFNR'                ,
  c_hotspot_fabric    TYPE dd03l-fieldname VALUE 'HERSTELLER'           ,
  c_hotspot_material  TYPE dd03l-fieldname VALUE 'MATNR'                ,
  c_hotspot_lote_ctrl TYPE dd03l-fieldname VALUE 'PRUEFLOS'             ,
  c_hotspot_qmnum     TYPE dd03l-fieldname VALUE 'QMNUM'                ,
  c_hotspot_qtd_lotes TYPE dd03l-fieldname VALUE 'QTD_LOTES'            ,
  c_hotspot_qtd_nqm   TYPE dd03l-fieldname VALUE 'QTD_NQM'              ,
  c_preco             TYPE dd07l-domname   VALUE 'YPRECO'               ,
  c_pontual           TYPE dd07l-domname   VALUE 'YPONTUAL'             ,
  c_relac             TYPE dd07l-domname   VALUE 'YRELAC'               ,
  c_materia_prima     TYPE t134-mtart      VALUE 'ROH'                  ,
  c_coluna            TYPE tline-tdformat  VALUE '*'                    ,
  c_objeto            TYPE thead-tdobject  VALUE 'ZQM_PONTOS'           ,
  c_id_texto          TYPE thead-tdid      VALUE 'ZQM'                  ,
  c_xk03              TYPE tstc-tcode      VALUE 'XK03'                 ,
  c_mm03              TYPE tstc-tcode      VALUE 'MM03'                 ,
  c_qa03              TYPE tstc-tcode      VALUE 'QA03'                 ,
  c_qm03              TYPE tstc-tcode      VALUE 'QM03'                 ,
  c_btn_salvar        TYPE sy-ucomm        VALUE 'SAVE'                 ,
  c_btn_back          TYPE sy-ucomm        VALUE 'BACK'                 ,
  c_btn_exit          TYPE sy-ucomm        VALUE 'EXIT'                 ,
  c_btn_cancel        TYPE sy-ucomm        VALUE 'CANCEL'               ,
  c_qtd_linhas_log    TYPE i               VALUE 5                      ,
  c_qtd_lin_log_exib  TYPE i               VALUE 8                      ,
  c_sim               TYPE c LENGTH 01     VALUE '1'                    ,
  c_desabilitar_campo TYPE c LENGTH 01     VALUE '0'                    ,
  c_habilitar_campo   TYPE c LENGTH 01     VALUE '1'                    ,
  c_search_help_domin TYPE c LENGTH 01     VALUE 'S'                    ,
  c_bom_relac         TYPE c LENGTH 01     VALUE  '1'                   ,
  c_sem_destaque      TYPE c LENGTH 01     VALUE  '0'                   ,
  c_chk_endereco_xk03 TYPE c LENGTH 08     VALUE '/110'                 ,
  c_icone_sem_justifc TYPE c LENGTH 04     VALUE '@SR@'                 ,
  c_icone_editar      TYPE c LENGTH 04     VALUE '@0O@'                 ,
  c_icone_visualizar  TYPE c LENGTH 04     VALUE '@0P@'                 .

*----------------------------------------------------------------------*
* Objetos                                                              *
*----------------------------------------------------------------------*
DATA:
  obj_container TYPE REF TO cl_gui_custom_container,
  obj_alv_grid  TYPE REF TO cl_gui_alv_grid        .

*----------------------------------------------------------------------*
*       CLASS lcl_evento_alv DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_evento_alv DEFINITION.
  PUBLIC SECTION.
    METHODS: hotspot_click
     FOR EVENT hotspot_click OF cl_gui_alv_grid
     IMPORTING e_row_id
               e_column_id
               es_row_no.

    METHODS: onf4
     FOR EVENT onf4 OF cl_gui_alv_grid
     IMPORTING e_fieldname
               es_row_no
               er_event_data.

    METHODS: data_changed " register_edit_event
     FOR EVENT data_changed OF cl_gui_alv_grid
     IMPORTING er_data_changed.
ENDCLASS.                    "lcl_evento_alv DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_salv_eventos DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_salv_eventos DEFINITION.
  PUBLIC SECTION.
    METHODS: on_link_click
        FOR EVENT link_click OF cl_salv_events_table
          IMPORTING row
                    column.
ENDCLASS.                    "lcl_salv_eventos DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_evento_alv IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_evento_alv IMPLEMENTATION.
  METHOD hotspot_click.
    PERFORM event_hotspot_click
      USING e_row_id
            e_column_id.
  ENDMETHOD.                    "hotspot_click

  METHOD onf4.
    PERFORM event_onf4
      USING e_fieldname
            es_row_no
            er_event_data.
  ENDMETHOD.                    "handle_on_f4

  METHOD data_changed.
    PERFORM event_data_changed
     USING er_data_changed.
  ENDMETHOD.                    "event_data_changed
ENDCLASS.                    "lcl_evento_alv IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcl_salv_eventos IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_salv_eventos IMPLEMENTATION.
  METHOD on_link_click.
    PERFORM event_link_click
      USING row
            column.
  ENDMETHOD.                    "on_link_click

ENDCLASS.                    "lcl_salv_eventos IMPLEMENTATION

*----------------------------------------------------------------------*
* Tela de seleção                                                      *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t001            . " Tipo do relatório
PARAMETERS: p_pont RADIOBUTTON GROUP a USER-COMMAND rusr            , " Inserir pontuação
            p_forn RADIOBUTTON GROUP a DEFAULT 'X'                  . " Avaliação Fornecedor
SELECTION-SCREEN END OF BLOCK b1                                    .

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE t002            . " Critérios de seleção
SELECT-OPTIONS: s_lifnr FOR lfa1-lifnr MODIF ID z1                  , " Fornecedor
                s_werks FOR marc-werks MODIF ID z1                  , " Centro
                s_matnr FOR marc-matnr MODIF ID z2                  , " Material
                s_mtart FOR mara-mtart MODIF ID z1                  , " Tipo de material
                s_data  FOR sy-datum   MODIF ID z2                  . " Período .
SELECTION-SCREEN END OF BLOCK b2                                    .

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE t003            . " Período
PARAMETERS: p_per1 RADIOBUTTON GROUP b MODIF ID z3 USER-COMMAND rusr, " Janeiro - Março
            p_per2 RADIOBUTTON GROUP b MODIF ID z3                  , " Abril   - Junho
            p_per3 RADIOBUTTON GROUP b MODIF ID z3                  , " Julho   - Setembro
            p_per4 RADIOBUTTON GROUP b MODIF ID z3                  . " Outubro - Dezembro
SELECTION-SCREEN END OF BLOCK b3                                    .

*----------------------------------------------------------------------*
* MODULE status_1001 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE status_1001 OUTPUT.
  SET PF-STATUS 'S1001' EXCLUDING t_fcode.

* Relatório de avaliação de fornecedores
  SET TITLEBAR 'T1001'.
ENDMODULE.                                           "status_0001 OUTPUT

*----------------------------------------------------------------------*
* MODULE user_command_0001 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE user_command_1001 INPUT.
  CASE ok_code.
    WHEN c_btn_back
      OR c_btn_exit
      OR c_btn_cancel.
      LEAVE TO SCREEN 0.
    WHEN c_btn_salvar. " SAVE
      PERFORM f_salvar_pontuacao.
  ENDCASE.
ENDMODULE. "user_command_1001 INPUT

*----------------------------------------------------------------------*
* Inicialização                                                        *
*----------------------------------------------------------------------*
INITIALIZATION.
  s_mtart-low = c_materia_prima. " ROH
  APPEND s_mtart.

  IMPORT w_notas_qm-lifnum TO s_lifnr-low
         w_notas_qm-matnr  TO s_matnr-low
   FROM MEMORY ID 'GNC_NQM'.

  IF s_lifnr-low IS NOT INITIAL.
    APPEND s_lifnr.
  ENDIF.

  IF s_matnr-low IS NOT INITIAL.
    APPEND s_matnr.
  ENDIF.

  FREE MEMORY ID 'GNC_NQM'.

  t001 = 'Tipo do relatório'(001)   .
  t002 = 'Critérios de seleção'(002).
  t003 = 'Período'(014)             .

*----------------------------------------------------------------------*
* 'PBO' da selection-screen                                            *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_verificar_autorizacao.

*----------------------------------------------------------------------*
* Inicio                                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  DATA: v_nome_relatorio TYPE lvc_s_layo-grid_title.

  CASE 'X'.
    WHEN p_pont. " Pontuação Compras
      v_nome_relatorio = 'Relatório para inserir a pontuação de Compras'.
      PERFORM f_preencher_pontuacao.
    WHEN p_forn. " Avaliação Fornecedor
      v_nome_relatorio = 'Relatório de avaliação de fornecedores'.
      PERFORM f_avaliar_fornecedor.
  ENDCASE.

*&---------------------------------------------------------------------*
*&      Form  f_verificar_autorizacao
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_verificar_autorizacao.
  IF p_pont IS NOT INITIAL. " Pontuação Compras

*   Verifica se o usuário pode inserir a pontuação (SU21)
    AUTHORITY-CHECK OBJECT 'YQM' ID 'ACTVT' FIELD '01'.

    IF sy-subrc <> 0.
      MESSAGE 'Usuário sem permissão para inserir a pontuação'(009)
      TYPE 'S' DISPLAY LIKE 'E'.

      LOOP AT SCREEN.
        IF screen-group1   = 'Z1'
          OR screen-group1 = 'Z2'
          OR screen-group1 = 'Z3'.
          screen-active = c_desabilitar_campo.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ELSE.
      LOOP AT SCREEN.
        IF screen-group1 = 'Z2'.
          screen-active = c_desabilitar_campo.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'Z1' OR screen-group1 = 'Z2'.
        screen-active = c_habilitar_campo.
        MODIFY SCREEN.
      ELSEIF screen-group1 = 'Z3'.
        screen-active = c_desabilitar_campo.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "f_verificar_autorizacao

*&---------------------------------------------------------------------*
*&      Form  f_preencher_pontuacao
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_preencher_pontuacao.
  PERFORM f_verificar_periodo.

  CHECK v_contem_periodo IS INITIAL.

  PERFORM f_sel_fornecedores.

  IF t_alv_pontuacao IS NOT INITIAL.
    LOOP AT t_alv_pontuacao INTO w_alv_pontuacao
       WHERE justif <> c_icone_visualizar.

      w_alv_pontuacao-justif = c_icone_editar.
      MODIFY t_alv_pontuacao FROM w_alv_pontuacao INDEX sy-tabix.
    ENDLOOP.

    PERFORM f_montar_fieldcatalog
     TABLES t_fieldcat
      USING w_fieldcat
            c_tabela_alv_pont " YALV_NQM_PREENCHE_PTO
            'X'.              " Possui campos editáveis

    PERFORM f_montar_alv
      USING obj_container
            obj_alv_grid
            c_container_alv " CONT_ALV
            t_fieldcat
            t_alv_pontuacao
            v_nome_relatorio
            space.          " Exibir/Inibir barra de tarefas

*   ALV - Pontuação/Avaliação de Fornecedores
    CALL SCREEN c_tela_alv.                                 " 1001
  ELSE.
    MESSAGE 'Dados não encontrados'(003)
    TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.                    "f_preencher_pontuacao

*&---------------------------------------------------------------------*
*&      Form  f_avaliar_fornecedor
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_avaliar_fornecedor.
  IF s_data IS INITIAL.
    MESSAGE 'Informe o período!'(015) TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ELSE.
    PERFORM f_montar_periodo.
  ENDIF.

  PERFORM: f_sel_forn_com_lotes       ,
           f_sel_forn_com_notas_qm    ,
           f_sel_nqm_sem_lote_controle,
           f_sel_detalhes_fornecedor  ,
           f_montar_alv_for_aval      .

  IF t_alv_avaliacao IS NOT INITIAL.
*   Exclui o botão 'Salvar pontuações' da barra de status
    APPEND c_btn_salvar TO t_fcode.

    SORT t_alv_avaliacao BY fornec werks ASCENDING.

    PERFORM f_montar_fieldcatalog
     TABLES t_fieldcat
      USING w_fieldcat
            c_tabela_alv_avalia " YALV_NQM_AVALIACAO
            space.              " Não possui campos editáveis

    PERFORM f_montar_alv
      USING obj_container
            obj_alv_grid
            c_container_alv " CONT_ALV
            t_fieldcat
            t_alv_avaliacao
            v_nome_relatorio
            space.          " Exibir/Inibir barra de tarefas

*   ALV - Pontuação/Avaliação de Fornecedores
    CALL SCREEN c_tela_alv.                                 " 1001
  ELSE.
    MESSAGE 'Dados não encontrados'(003)
    TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.                    "f_avaliar_fornecedor

*&---------------------------------------------------------------------*
*&      Form  f_montar_range_periodo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_montar_periodo.
  IF s_data-low IS NOT INITIAL.
    FREE r_periodo_aval.
    w_periodo-sign   = 'I'            .
    w_periodo-option = 'EQ'           .
    w_periodo-low    = s_data-low     .
    APPEND w_periodo TO r_periodo_aval.
  ENDIF.

  IF s_data-low IS NOT INITIAL
    AND s_data-high IS NOT INITIAL.
    FREE r_periodo_aval.
    w_periodo-sign   = 'I'            .
    w_periodo-option = 'BT'           .
    w_periodo-low    = s_data-low     .
    w_periodo-high   = s_data-high    .
    APPEND w_periodo TO r_periodo_aval.
  ENDIF.
ENDFORM.                    "f_montar_range_periodo

*&---------------------------------------------------------------------*
*&      Form  f_verificar_periodo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_verificar_periodo.
  DATA: v_dt_atual_ini TYPE sy-datum,
        v_dt_atual_fim TYPE sy-datum,
        v_dt_ant_ini   TYPE sy-datum,
        v_dt_ant_fim   TYPE sy-datum.

  CLEAR v_periodo_selec.

  CASE 'X'.
    WHEN p_per1. " Janeiro - Março
      v_periodo_selec = 'Janeiro - Março'.

      CONCATENATE: sy-datum+0(4) '01' '01' INTO v_dt_atual_ini,
                   sy-datum+0(4) '03' '01' INTO v_dt_atual_fim.

    WHEN p_per2. " Abril - Junho
      v_periodo_selec = 'Abril - Junho'.

      CONCATENATE: sy-datum+0(4) '04' '01' INTO v_dt_atual_ini,
                   sy-datum+0(4) '06' '01' INTO v_dt_atual_fim.

      CONCATENATE: sy-datum+0(4) '01' '01' INTO v_dt_ant_ini,
                   sy-datum+0(4) '03' '01' INTO v_dt_ant_fim.

    WHEN p_per3. " Julho - Setembro
      v_periodo_selec = 'Julho - Setembro'.

      CONCATENATE: sy-datum+0(4) '07' '01' INTO v_dt_atual_ini,
                   sy-datum+0(4) '09' '01' INTO v_dt_atual_fim.

      CONCATENATE: sy-datum+0(4) '04' '01' INTO v_dt_ant_ini,
                   sy-datum+0(4) '06' '01' INTO v_dt_ant_fim.

    WHEN p_per4. " Outubro - Dezembro
      v_periodo_selec = 'Outubro - Dezembro'.

      CONCATENATE: sy-datum+0(4) '10' '01' INTO v_dt_atual_ini,
                   sy-datum+0(4) '12' '01' INTO v_dt_atual_fim.

      CONCATENATE: sy-datum+0(4) '07' '01' INTO v_dt_ant_ini,
                   sy-datum+0(4) '09' '01' INTO v_dt_ant_fim.
  ENDCASE.

* Verifica qual o último dia do mês do período superior
  CALL FUNCTION 'FKK_LAST_DAY_OF_MONTH'
    EXPORTING
      day_in            = v_dt_atual_fim
    IMPORTING
      last_day_of_month = v_dt_atual_fim
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

* Verifica qual o último dia do mês do período anterior
  CALL FUNCTION 'FKK_LAST_DAY_OF_MONTH'
    EXPORTING
      day_in            = v_dt_ant_fim
    IMPORTING
      last_day_of_month = v_dt_ant_fim
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  FREE r_periodo_atual.
  w_periodo-sign   = 'I'             . " Include
  w_periodo-option = 'BT'            . " Between
  w_periodo-low    = v_dt_atual_ini  .
  w_periodo-high   = v_dt_atual_fim  .
  APPEND w_periodo TO r_periodo_atual.

  FREE r_periodo_anter.
  w_periodo-sign   = 'I'             . " Include
  w_periodo-option = 'BT'            . " Between
  w_periodo-low    = v_dt_ant_ini    .
  w_periodo-high   = v_dt_ant_fim    .
  APPEND w_periodo TO r_periodo_anter.

* Verifica se o período anterior já foi cadastrado para
* pelo menos 1 fornecedor caso não esteja no 1º período (Janeiro - Março)
  IF p_per1 IS INITIAL.
    SELECT COUNT( DISTINCT lifnr )
      FROM ytnqm_pontuacao
      INTO (vl_qtd_registros)
      WHERE data_ini IN r_periodo_anter
        AND data_fim IN r_periodo_anter.

    IF vl_qtd_registros = 0.
      MESSAGE 'Não houve inserção ou modificação de pontuações no período anterior'(018)
      TYPE 'S' DISPLAY LIKE 'E'.
      v_contem_periodo = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_verificar_periodo

*&---------------------------------------------------------------------*
*&      Form  f_sel_fornecedores
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_sel_fornecedores.
  DATA: v_resposta TYPE c.

  IF s_lifnr IS INITIAL.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Relatório de Avaliação de Fornecedores'(010)
        text_question         = 'Deseja selecionar todos fornecedores?'(011)
        text_button_1         = 'Sim'(012)
        text_button_2         = 'Não'(013)
        display_cancel_button = ' '
      IMPORTING
        answer                = v_resposta.
  ELSE.
    v_resposta = c_sim.
  ENDIF.

  CHECK v_resposta = c_sim.

* Seleciona os fornecedores de acordo com o período e tipo de material
  SELECT qals~lifnr                           " Nº conta do fornecedor
         qals~werk                            " Centro
         qals~hersteller                      " Nº fabricante
         qals~matnr                           " Nº do material
         mara~mtart                           " Tipo de material
   FROM qals
   INNER JOIN mara ON mara~matnr = qals~matnr
   INTO TABLE t_forn_periodo
    WHERE qals~lifnr      IN s_lifnr          " Nº conta do fornecedor
      AND qals~werk       IN s_werks          " Centro
      AND mara~mtart      IN s_mtart          " Tipo de material
      AND qals~enstehdat  IN r_periodo_atual  " Data de criação do lote
      AND qals~charg      <> space            " Número do lote
      AND qals~art        = c_entrada_pedido  " Tipo de controle
      AND herkunft        = c_entrada_mercad. " Origem do lote de controle

  SORT t_forn_periodo.
  DELETE ADJACENT DUPLICATES FROM t_forn_periodo.

  CHECK t_forn_periodo IS NOT INITIAL.

* Seleciona os fornecedores e os respectivos centros
  SELECT lfb1~lifnr                          " Nº conta do fornecedor
         lfa1~name1 AS fornec                " Nome do fornecedor
         t001w~werks                         " Centro
         t001w~name1 AS centro               " Nome do centro
    FROM lfb1
    INNER JOIN lfa1  ON lfa1~lifnr  = lfb1~lifnr
    INNER JOIN t001w ON t001w~werks = lfb1~bukrs
    INTO TABLE t_alv_pontuacao
    FOR ALL ENTRIES IN t_forn_periodo
    WHERE lfb1~lifnr  = t_forn_periodo-lifnr " Fornecedor
      AND t001w~werks = t_forn_periodo-werk  " Centro
      AND lfa1~loevm <> 'X'.                 " Marcação central para eliminação do registro mestre

  SORT t_alv_pontuacao BY lifnr werks ASCENDING.

  DATA v_data_fim TYPE ytnqm_pontuacao-data_fim.

* Seleciona as últimas pontuações cadastradas dos fornecedores
  LOOP AT t_alv_pontuacao INTO w_alv_pontuacao.
    SELECT MAX( data_fim )
     FROM ytnqm_pontuacao
     INTO v_data_fim
     WHERE lifnr = w_alv_pontuacao-lifnr
       AND werks = w_alv_pontuacao-werks.

    IF v_data_fim IS NOT INITIAL.
      SELECT mandt lifnr werks data_ini data_fim preco pontual relac
            justif data_atu usuario
       FROM ytnqm_pontuacao
       APPENDING TABLE t_pontuacao_compras
       WHERE lifnr    = w_alv_pontuacao-lifnr
         AND werks    = w_alv_pontuacao-werks
         AND data_fim = v_data_fim.
    ENDIF.
  ENDLOOP.

* Ordena as pontuações para saber qual é que tem o maior mês
* e deletar a do menor mês
  SORT t_pontuacao_compras BY lifnr werks data_ini DESCENDING.

  DELETE ADJACENT DUPLICATES FROM t_pontuacao_compras
                        COMPARING lifnr werks.

  LOOP AT t_pontuacao_compras INTO w_pontuacao_compras.
    READ TABLE t_alv_pontuacao
    TRANSPORTING NO FIELDS
    WITH KEY lifnr = w_pontuacao_compras-lifnr
             werks = w_pontuacao_compras-werks.

    v_indice = sy-tabix.

    LOOP AT t_alv_pontuacao INTO w_alv_pontuacao FROM v_indice.
      IF w_alv_pontuacao-lifnr <> w_pontuacao_compras-lifnr.
        EXIT.
      ELSEIF w_alv_pontuacao-lifnr = w_pontuacao_compras-lifnr
         AND w_alv_pontuacao-werks <> w_pontuacao_compras-werks.
        EXIT.
      ELSE.
        w_alv_pontuacao-preco   = w_pontuacao_compras-preco  .
        w_alv_pontuacao-pontual = w_pontuacao_compras-pontual.
        w_alv_pontuacao-relac   = w_pontuacao_compras-relac  .

        IF w_pontuacao_compras-justif IS NOT INITIAL.
          w_alv_pontuacao-justif = c_icone_visualizar.
        ENDIF.

        MODIFY t_alv_pontuacao FROM w_alv_pontuacao INDEX v_indice.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM t_alv_pontuacao.
ENDFORM.                    "f_sel_fornecedores

*&---------------------------------------------------------------------*
*&      Form  f_exibir_lotes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ROW          text
*      -->P_FORNEC       text
*      -->P_CENTRO       text
*      -->P_FABRIC       text
*      -->P_MATNR        text
*----------------------------------------------------------------------*
FORM f_exibir_lotes
  USING p_row    TYPE lvc_s_row
        p_fornec TYPE yalv_nqm_avaliacao-lifnr
        p_centro TYPE yalv_nqm_avaliacao-werks
        p_fabric TYPE yalv_nqm_avaliacao-hersteller
        p_matnr  TYPE yalv_nqm_avaliacao-matnr.

  FREE t_alv_lotes.

  PERFORM f_verificar_qtd_lotes.

  DATA: t_lote_valido_item_sel TYPE STANDARD TABLE OF ty_lote_ctr_validos.

  SORT t_qtd_lotes_validos.

  LOOP AT t_qtd_lotes_validos INTO w_qtd_lotes_validos
                               WHERE lifnr      = p_fornec
                                 AND werk       = p_centro
                                 AND hersteller = p_fabric
                                 AND matnr      = p_matnr.
    APPEND w_qtd_lotes_validos TO t_lote_valido_item_sel.
  ENDLOOP.

  CHECK t_lote_valido_item_sel IS NOT INITIAL.

* Seleciona todos os lotes de acordo com range de datas
  SELECT qals~lifnr                                           " Nº conta do fornecedor
         qals~werk                                            " Centro
         qals~hersteller                                      " Nº fabricante
         qals~matnr                                           " Nº do material
         qals~charg                                           " Número do lote
         qals~prueflos                                        " Nº lote de controle
   FROM qals
   INNER JOIN mara ON mara~matnr = qals~matnr
   INTO TABLE t_alv_lotes
    FOR ALL ENTRIES IN t_lote_valido_item_sel
    WHERE qals~lifnr      = t_lote_valido_item_sel-lifnr      " Nº conta do fornecedor
      AND qals~werk       = t_lote_valido_item_sel-werk       " Centro
      AND qals~matnr      = t_lote_valido_item_sel-matnr      " Nº do material
      AND mara~mtart      IN s_mtart                          " Tipo de material
      AND qals~enstehdat  IN r_periodo_aval                   " Data de criação do lote
      AND qals~hersteller = t_lote_valido_item_sel-hersteller " Fabricante deve existir
      AND qals~charg      = t_lote_valido_item_sel-charg      " Nº lote
      AND qals~prueflos   = t_lote_valido_item_sel-prueflos   " Nº lote de controle
      AND qals~art        = c_entrada_pedido                  " Tipo de controle
      AND herkunft        = c_entrada_mercad.                 " Origem do lote de controle

  SORT t_alv_lotes.
  DELETE ADJACENT DUPLICATES FROM t_alv_lotes.

  IF t_alv_lotes IS NOT INITIAL.
    PERFORM f_montar_salv_popup
     USING t_alv_lotes
           c_hotspot_qtd_lotes.
  ELSE.
    MESSAGE 'Não foram encontrados lotes para esse fornecedor e material'(018)
    TYPE 'I'.
  ENDIF.
ENDFORM.                    "f_exibir_lotes

*&---------------------------------------------------------------------*
*&      Form  f_sel_forn_com_lotes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_sel_forn_com_lotes.

  SELECT DISTINCT qals~lifnr                  " Nº conta do fornecedor
         qals~werk                            " Centro
         qals~hersteller                      " Nº fabricante
         qals~matnr                           " Nº do material
   FROM qals
   INNER JOIN mara ON mara~matnr = qals~matnr
   INTO TABLE t_forn_com_lote
    WHERE qals~lifnr      IN s_lifnr          " Nº conta do fornecedor
      AND qals~werk       IN s_werks          " Centro
      AND qals~matnr      IN s_matnr          " Nº do material
      AND mara~mtart      IN s_mtart          " Tipo de material
      AND qals~enstehdat  IN r_periodo_aval   " Data de criação do lote
      AND qals~charg      <> space            " Número do lote
      AND qals~art        = c_entrada_pedido  " Tipo de controle
      AND herkunft        = c_entrada_mercad. " Origem do lote de controle

  SORT t_forn_com_lote.

  PERFORM f_verificar_qtd_lotes.
ENDFORM.                    "f_sel_forn_com_lotes

*&---------------------------------------------------------------------*
*&      Form  f_sel_forn_com_notas_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_sel_forn_com_notas_qm.
  FREE t_qtd_nota_qm.

  DATA: v_indice TYPE sy-tabix.

* Seleciona as Notas de QM
  IF t_forn_com_lote IS NOT INITIAL.
    SELECT qmnum            " Nº da nota
           qmart            " Tipo de nota
           erdat            " Data de criação do registro
           matnr            " Nº do material
           objnr            " Nº objeto para administração de status
           lifnum           " Nº conta do fornecedor
           mawerk           " Centro para material
           hersteller       " Nº fabricante
           yypto_espec      " Pontuação da Especificação
           yypto_rdf        " Pontuação da RDF
           yypto_suptec     " Pontuação do Suporte Técnico
     FROM qmel
     INTO TABLE t_forn_nota_qm
     FOR ALL ENTRIES IN t_forn_com_lote
      WHERE qmart      EQ c_nota_qm
        AND erdat      IN r_periodo_aval
        AND matnr      EQ t_forn_com_lote-matnr
        AND lifnum     EQ t_forn_com_lote-lifnr
        AND mawerk     EQ t_forn_com_lote-werk
        AND hersteller EQ t_forn_com_lote-hersteller
        AND kzloesch   EQ space.
  ENDIF.

  SORT t_forn_nota_qm BY lifnum mawerk hersteller matnr ASCENDING.

  LOOP AT t_forn_nota_qm INTO w_forn_nota_qm.
    v_indice = sy-tabix.

*   Verifica se a nota de QM foi marcada para eliminação
    SELECT COUNT( * )
     FROM jest
     WHERE objnr  = w_forn_nota_qm-objnr
        AND stat  = c_marc_eliminacao
        AND inact = space.

*   Se a nota não foi marcada para eliminação, "soma"
    IF sy-subrc <> 0.
      w_qtd_nota_qm-matnr        = w_forn_nota_qm-matnr       .
      w_qtd_nota_qm-lifnum       = w_forn_nota_qm-lifnum      .
      w_qtd_nota_qm-mawerk       = w_forn_nota_qm-mawerk      .
      w_qtd_nota_qm-hersteller   = w_forn_nota_qm-hersteller  .
      w_qtd_nota_qm-qtd_nqm      = 1                          .
      w_qtd_nota_qm-yypto_espec  = w_forn_nota_qm-yypto_espec .
      w_qtd_nota_qm-yypto_rdf    = w_forn_nota_qm-yypto_rdf   .
      w_qtd_nota_qm-yypto_suptec = w_forn_nota_qm-yypto_suptec.
      w_qtd_nota_qm-pto_qa       = w_forn_nota_qm-yypto_espec +
                                   w_forn_nota_qm-yypto_rdf   +
                                   w_forn_nota_qm-yypto_suptec.
      COLLECT w_qtd_nota_qm INTO t_qtd_nota_qm                .
    ELSE.
      DELETE t_forn_nota_qm INDEX v_indice.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "f_sel_forn_com_notas_qm

*&---------------------------------------------------------------------*
*&      Form  f_sel_nqm_sem_lote_controle
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_sel_nqm_sem_lote_controle.
  DATA: t_qtd_nota_qm_aux  TYPE STANDARD TABLE OF ty_qtd_nota_qm ,
        w_qtd_nota_qm_aux  LIKE LINE OF t_qtd_nota_qm_aux        .

  DATA: v_indice TYPE sy-tabix.

  FREE: t_nqm_sem_lote, t_qtd_nqm_sem_lote.

* Seleciona todas as Notas de QM de acordo com os parâmetros da tela de seleção
  SELECT qmnum            " Nº da nota
         qmart            " Tipo de nota
         erdat            " Data de criação do registro
         matnr            " Nº do material
         objnr            " Nº objeto para administração de status
         lifnum           " Nº conta do fornecedor
         mawerk           " Centro para material
         hersteller       " Nº fabricante
         yypto_espec      " Pontuação da Especificação
         yypto_rdf        " Pontuação da RDF
         yypto_suptec     " Pontuação do Suporte Técnico
   FROM qmel
   INTO TABLE t_nqm_sem_lote
    WHERE qmart  EQ c_nota_qm
      AND erdat  IN r_periodo_aval
      AND matnr  IN s_matnr          " Nº do material
      AND lifnum IN s_lifnr          " Nº conta do fornecedor
      AND mawerk IN s_werks.         " Centro

* Sumariza as notas de QM de acordo com Material, Fornecedor e Fabricante
  LOOP AT t_nqm_sem_lote INTO w_nqm_sem_lote.
    v_indice = sy-tabix.

*   Verifica se a nota de QM foi marcada para eliminação
    SELECT COUNT( * )
     FROM jest
     WHERE objnr  = w_nqm_sem_lote-objnr
        AND stat  = c_marc_eliminacao
        AND inact = space.

    IF sy-subrc <> 0.
      w_qtd_nota_qm_aux-matnr        = w_nqm_sem_lote-matnr       .
      w_qtd_nota_qm_aux-lifnum       = w_nqm_sem_lote-lifnum      .
      w_qtd_nota_qm_aux-mawerk       = w_nqm_sem_lote-mawerk      .
      w_qtd_nota_qm_aux-hersteller   = w_nqm_sem_lote-hersteller  .
      w_qtd_nota_qm_aux-qtd_nqm      = 1                          .
      w_qtd_nota_qm_aux-yypto_espec  = w_nqm_sem_lote-yypto_espec .
      w_qtd_nota_qm_aux-yypto_rdf    = w_nqm_sem_lote-yypto_rdf   .
      w_qtd_nota_qm_aux-yypto_suptec = w_nqm_sem_lote-yypto_suptec.
      w_qtd_nota_qm_aux-pto_qa       = w_nqm_sem_lote-yypto_espec +
                                       w_nqm_sem_lote-yypto_rdf   +
                                       w_nqm_sem_lote-yypto_suptec.
      COLLECT w_qtd_nota_qm_aux INTO t_qtd_nota_qm_aux            .
    ELSE.
      DELETE t_nqm_sem_lote INDEX v_indice.
    ENDIF.
  ENDLOOP.

* Verifica as notas de QM abertas que não tem lotes de controle (QALS)
  LOOP AT t_qtd_nota_qm_aux INTO w_qtd_nota_qm_aux.
    CLEAR w_forn_com_lote.
    READ TABLE t_forn_com_lote
    INTO w_forn_com_lote
    WITH KEY matnr = w_qtd_nota_qm_aux-matnr
             lifnr = w_qtd_nota_qm_aux-lifnum
             werk  = w_qtd_nota_qm_aux-mawerk.

    IF sy-subrc <> 0.
      SELECT COUNT( * )
       FROM mara
       WHERE matnr = w_qtd_nota_qm_aux-matnr
         AND mtart IN s_mtart.

      IF sy-subrc = 0.
        APPEND w_qtd_nota_qm_aux TO t_qtd_nqm_sem_lote.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Adicionar as linhas da t_qtd_nqm_Sem_lote na t_forn_com_lote
* ler a tabela no loop da t_fornecedor_lote para obter as quantidade

  LOOP AT t_qtd_nqm_sem_lote INTO w_qtd_nqm_sem_lote.
    w_forn_com_lote-lifnr      = w_qtd_nqm_sem_lote-lifnum    .
    w_forn_com_lote-werk       = w_qtd_nqm_sem_lote-mawerk    .
    w_forn_com_lote-hersteller = w_qtd_nqm_sem_lote-hersteller.
    w_forn_com_lote-matnr      = w_qtd_nqm_sem_lote-matnr     .
    APPEND w_forn_com_lote TO t_forn_com_lote                 .
  ENDLOOP.

ENDFORM.                    "f_sel_nqm_sem_lote_controle

*&---------------------------------------------------------------------*
*&      Form  f_exibir_notas_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ROW      text
*      -->P_FORNEC   text
*      -->P_CENTRO   text
*      -->P_FABRIC   text
*      -->P_MATNR    text
*----------------------------------------------------------------------*
FORM f_exibir_notas_qm
  USING p_row    TYPE lvc_s_row
        p_fornec TYPE yalv_nqm_avaliacao-lifnr
        p_centro TYPE yalv_nqm_avaliacao-werks
        p_fabric TYPE yalv_nqm_avaliacao-hersteller
        p_matnr  TYPE yalv_nqm_avaliacao-matnr.

  FREE t_alv_nota_qm.

  LOOP AT t_forn_nota_qm INTO w_forn_nota_qm
         WHERE lifnum     = p_fornec
           AND mawerk     = p_centro
           AND hersteller = p_fabric
           AND matnr      = p_matnr.

    w_alv_nota_qm-qmnum      = w_forn_nota_qm-qmnum     .
    w_alv_nota_qm-erdat      = w_forn_nota_qm-erdat     .
    w_alv_nota_qm-matnr      = w_forn_nota_qm-matnr     .
    w_alv_nota_qm-lifnum     = w_forn_nota_qm-lifnum    .
    w_alv_nota_qm-mawerk     = w_forn_nota_qm-mawerk    .
    w_alv_nota_qm-hersteller = w_forn_nota_qm-hersteller.
    APPEND w_alv_nota_qm TO t_alv_nota_qm.
  ENDLOOP.

  SORT t_alv_nota_qm BY erdat DESCENDING.
  DELETE ADJACENT DUPLICATES FROM t_alv_nota_qm.

  IF t_alv_nota_qm IS NOT INITIAL.
    PERFORM f_montar_salv_popup
     USING t_alv_nota_qm
           c_hotspot_qtd_nqm.
  ELSE.

*   Verifica se é uma nota de QM de uma nota sem lote
    LOOP AT t_nqm_sem_lote INTO w_nqm_sem_lote
         WHERE lifnum     = p_fornec
           AND mawerk     = p_centro
           AND hersteller = p_fabric
           AND matnr      = p_matnr.

      w_alv_nota_qm-qmnum      = w_nqm_sem_lote-qmnum     .
      w_alv_nota_qm-erdat      = w_nqm_sem_lote-erdat     .
      w_alv_nota_qm-matnr      = w_nqm_sem_lote-matnr     .
      w_alv_nota_qm-lifnum     = w_nqm_sem_lote-lifnum    .
      w_alv_nota_qm-mawerk     = w_nqm_sem_lote-mawerk    .
      w_alv_nota_qm-hersteller = w_nqm_sem_lote-hersteller.
      APPEND w_alv_nota_qm TO t_alv_nota_qm.
    ENDLOOP.

    IF t_alv_nota_qm IS NOT INITIAL.
      PERFORM f_montar_salv_popup
       USING t_alv_nota_qm
             c_hotspot_qtd_nqm.
    ELSE.
      MESSAGE 'Não foram encontradas '&
              'notas de QM para esse fornecedor e material'
         TYPE 'I'.
    ENDIF.
  ENDIF.

ENDFORM.                    "f_exibir_notas_qm

*&---------------------------------------------------------------------*
*&      Form  f_verificar_qtd_lotes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_verificar_qtd_lotes.

  FREE: t_lotes_objetos, t_qtd_lotes_validos, t_charg_validos.

* Seleciona o nº do objeto para verificar se o lote foi estornado
  SELECT qals~lifnr                           " Nº conta do fornecedor
         qals~werk                            " Centro
         qals~hersteller                      " Nº fabricante
         qals~matnr                           " Nº do material
         qals~objnr                           " Nº objeto
         qals~prueflos                        " Número do lote de controle
         qals~charg                           " Número do lote
   FROM qals
   INNER JOIN mara ON mara~matnr = qals~matnr
   INTO TABLE t_lotes_objetos
    WHERE qals~lifnr      IN s_lifnr          " Nº conta do fornecedor
      AND qals~werk       IN s_werks          " Centro
      AND qals~matnr      IN s_matnr          " Nº do material
      AND mara~mtart      IN s_mtart          " Tipo de material
      AND qals~enstehdat  IN r_periodo_aval   " Data de criação do lote
      AND qals~charg      <> space            " Número do lote
      AND qals~art        = c_entrada_pedido  " Tipo de controle
      AND herkunft        = c_entrada_mercad. " Origem do lote de controle

  SORT t_lotes_objetos BY lifnr ASCENDING.

  DATA: v_estornado TYPE n.

  LOOP AT t_lotes_objetos INTO w_lotes_objetos.
    v_indice = sy-tabix.

*   Verifica se encontrou algum lote com status estornado
    SELECT COUNT( * )
     FROM jest
     WHERE objnr  = w_lotes_objetos-objnr
       AND stat   = c_lote_estornado                        " I0224
       AND inact  = space.

    IF sy-subrc <> 0.
      MOVE-CORRESPONDING w_lotes_objetos TO w_charg_validos.
      APPEND w_charg_validos TO t_charg_validos.

      MOVE-CORRESPONDING w_lotes_objetos TO w_qtd_lotes_validos.
      APPEND w_qtd_lotes_validos TO t_qtd_lotes_validos.
    ENDIF.
  ENDLOOP.

  SORT: t_qtd_lotes_validos BY lifnr werk hersteller matnr       ASCENDING,
        t_forn_com_lote     BY lifnr werk hersteller matnr       ASCENDING,
        t_charg_validos     BY lifnr werk hersteller matnr charg ASCENDING.

  DELETE ADJACENT DUPLICATES FROM: t_qtd_lotes_validos, t_charg_validos.

  SORT t_qtd_lotes_validos BY prueflos.
  DELETE ADJACENT DUPLICATES FROM t_qtd_lotes_validos.

  LOOP AT t_charg_validos INTO w_charg_validos.
*   Atualiza a quantidade de lotes encontrados
    CLEAR w_forn_com_lote.
    READ TABLE t_forn_com_lote
    INTO w_forn_com_lote
    WITH KEY lifnr      = w_charg_validos-lifnr
             werk       = w_charg_validos-werk
             hersteller = w_charg_validos-hersteller
             matnr      = w_charg_validos-matnr
    BINARY SEARCH.

    IF sy-subrc = 0.
      w_forn_com_lote-qtd_lotes = w_forn_com_lote-qtd_lotes + 1.
      MODIFY t_forn_com_lote FROM w_forn_com_lote INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

  SORT: t_forn_com_lote BY lifnr werk hersteller matnr ASCENDING.

ENDFORM.                    "f_verificar_qtd_lotes

*&---------------------------------------------------------------------*
*&      Form  f_sel_detalhes_fornecedor
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_sel_detalhes_fornecedor.
  CHECK t_forn_com_lote IS NOT INITIAL.

* Seleciona o nome do centro
  SELECT werks name1
    FROM t001w
    INTO TABLE t_centro
    FOR ALL ENTRIES IN t_forn_com_lote
    WHERE werks = t_forn_com_lote-werk.

* Seleciona o nome dos fornecedores
  SELECT lifnr name1
   FROM lfa1
   INTO TABLE t_fornecedor
    FOR ALL ENTRIES IN t_forn_com_lote
   WHERE lifnr = t_forn_com_lote-lifnr.

* Seleciona o nome dos fabricantes
  SELECT lifnr name1
   FROM lfa1
   INTO TABLE t_fabricante
    FOR ALL ENTRIES IN t_forn_com_lote
   WHERE lifnr = t_forn_com_lote-hersteller.

* Seleciona o nome do material
  SELECT matnr maktx
   FROM makt
   INTO TABLE t_material
    FOR ALL ENTRIES IN t_forn_com_lote
   WHERE matnr = t_forn_com_lote-matnr.

* Seleciona os fornecedores que já possuem pontuações de Compras/Suprimentos
  IF s_data-high IS NOT INITIAL.
    SELECT mandt lifnr werks data_ini data_fim preco pontual relac
           justif data_atu usuario
      FROM ytnqm_pontuacao
      INTO TABLE t_pontuacao_compras
      FOR ALL ENTRIES IN t_forn_com_lote
      WHERE lifnr     = t_forn_com_lote-lifnr
        AND werks     = t_forn_com_lote-werk
        AND data_ini >= s_data-low
        AND data_fim <= s_data-high.
  ELSE.
    SELECT mandt lifnr werks data_ini data_fim preco pontual relac
           justif data_atu usuario
      FROM ytnqm_pontuacao
      INTO TABLE t_pontuacao_compras
      FOR ALL ENTRIES IN t_forn_com_lote
      WHERE lifnr     = t_forn_com_lote-lifnr
        AND werks     = t_forn_com_lote-werk
        AND data_ini >= s_data-low.
  ENDIF.

* Ordena a tabela pelo Fornecedor/Centro e maior data final
  SORT t_pontuacao_compras BY lifnr werks data_fim DESCENDING.

* Deleta os registros que tem data inferior à maior data encontrada
  DELETE ADJACENT DUPLICATES FROM t_pontuacao_compras COMPARING lifnr werks.

  LOOP AT t_pontuacao_compras INTO w_pontuacao_compras.
    v_indice = sy-tabix.

*----------------------------------------------------------------------
*   Condição Comercial (Preço)
*----------------------------------------------------------------------
    IF w_pontuacao_compras-preco IS INITIAL.
      w_pontuacao_compras-preco = c_sem_destaque. " 0
    ELSE.
      w_pontuacao_compras-preco = ( w_pontuacao_compras-preco * 2 ).
    ENDIF.

*----------------------------------------------------------------------
*   Pontualidade (Entrega)
*----------------------------------------------------------------------
    IF w_pontuacao_compras-pontual IS INITIAL.
      w_pontuacao_compras-pontual = c_sem_destaque. " 0
    ELSE.
      w_pontuacao_compras-pontual = w_pontuacao_compras-pontual *  ( 15 / 10 ).
    ENDIF.

*----------------------------------------------------------------------
*   Pontualidade (Entrega)
*----------------------------------------------------------------------
    IF w_pontuacao_compras-relac IS INITIAL.
      w_pontuacao_compras-relac = c_sem_destaque. " 0
    ELSE.
      w_pontuacao_compras-relac = w_pontuacao_compras-relac *  ( 25 / 10 ).
    ENDIF.

    MODIFY t_pontuacao_compras FROM w_pontuacao_compras INDEX v_indice.
  ENDLOOP.

ENDFORM.                    "f_sel_detalhes_fornecedor

*&---------------------------------------------------------------------*
*&      Form  f_montar_alv_for_aval
*&---------------------------------------------------------------------*
*   Monta a tabela interna com dados do fornecedor avaliado
*----------------------------------------------------------------------*
FORM f_montar_alv_for_aval.
  DATA: v_pto_nota_qm    TYPE yalv_nqm_avaliacao-qtd_nqm,
        v_preco          TYPE yalv_nqm_avaliacao-p_total,
        v_pontualidade   TYPE yalv_nqm_avaliacao-p_total,
        v_relacionamento TYPE yalv_nqm_avaliacao-p_total,
        v_pto_positivo   TYPE yalv_nqm_avaliacao-p_total,
        v_total_pontos   TYPE yalv_nqm_avaliacao-p_total.

  LOOP AT t_forn_com_lote INTO w_forn_com_lote.
    CLEAR: v_pto_nota_qm, v_pto_positivo, v_total_pontos.

*----------------------------------------------------------------------
*   Nome do fornecedor
*----------------------------------------------------------------------
    CLEAR w_fornecedor.
    READ TABLE t_fornecedor
    INTO w_fornecedor
    WITH KEY lifnr = w_forn_com_lote-lifnr.

    IF sy-subrc = 0.
      w_alv_avaliacao-lifnr  = w_forn_com_lote-lifnr.
      w_alv_avaliacao-fornec = w_fornecedor-name1   .
    ENDIF.

*----------------------------------------------------------------------
*   Nome do centro
*----------------------------------------------------------------------
    CLEAR w_centro.
    READ TABLE t_centro
    INTO w_centro
    WITH KEY werks = w_forn_com_lote-werk.

    IF sy-subrc = 0.
      w_alv_avaliacao-werks  = w_forn_com_lote-werk.
      w_alv_avaliacao-centro = w_centro-name1      .
    ENDIF.

*----------------------------------------------------------------------
*   Nome do fabricante
*----------------------------------------------------------------------
    CLEAR w_fabricante.
    READ TABLE t_fabricante
    INTO w_fabricante
    WITH KEY lifnr = w_forn_com_lote-hersteller.

    IF sy-subrc = 0.
      w_alv_avaliacao-hersteller = w_forn_com_lote-hersteller.
      w_alv_avaliacao-fabric     = w_fabricante-name1        .
    ELSE.
      CLEAR: w_alv_avaliacao-hersteller,
             w_alv_avaliacao-fabric    .
    ENDIF.

*----------------------------------------------------------------------
*   Nome do material
*----------------------------------------------------------------------
    CLEAR w_material.
    READ TABLE t_material
    INTO w_material
    WITH KEY matnr = w_forn_com_lote-matnr.

    IF sy-subrc = 0.
      w_alv_avaliacao-matnr = w_forn_com_lote-matnr.
      w_alv_avaliacao-maktx = w_material-maktx     .
    ENDIF.

*----------------------------------------------------------------------
*   Pontuação da Especificação/ RDF / Suporte Técnico/ Qualidade / QTD notas de QM
*----------------------------------------------------------------------
    CLEAR w_qtd_nota_qm.
    READ TABLE t_qtd_nota_qm
    INTO w_qtd_nota_qm
    WITH KEY lifnum     = w_forn_com_lote-lifnr
             mawerk     = w_forn_com_lote-werk
             hersteller = w_forn_com_lote-hersteller
             matnr      = w_forn_com_lote-matnr.

    IF sy-subrc = 0.
      w_alv_avaliacao-pto_espec     = w_qtd_nota_qm-yypto_espec . " Pontuação da Especificação
      w_alv_avaliacao-pto_rdf       = w_qtd_nota_qm-yypto_rdf   . " Pontuação da RDF
      w_alv_avaliacao-pto_suptec    = w_qtd_nota_qm-yypto_suptec. " Pontuação do Suporte Técnico
      w_alv_avaliacao-pto_qualidade = w_qtd_nota_qm-pto_qa      . " Pontuação de Qualidade
      w_alv_avaliacao-qtd_nqm       = w_qtd_nota_qm-qtd_nqm     . " Qtd Notas QM
    ELSE.
      CLEAR w_qtd_nqm_sem_lote.
      READ TABLE t_qtd_nqm_sem_lote
      INTO w_qtd_nqm_sem_lote
      WITH KEY lifnum     = w_forn_com_lote-lifnr
               mawerk     = w_forn_com_lote-werk
               hersteller = w_forn_com_lote-hersteller
               matnr      = w_forn_com_lote-matnr.

      IF sy-subrc = 0.
        w_alv_avaliacao-pto_espec     = w_qtd_nqm_sem_lote-yypto_espec . " Pontuação da Especificação
        w_alv_avaliacao-pto_rdf       = w_qtd_nqm_sem_lote-yypto_rdf   . " Pontuação da RDF
        w_alv_avaliacao-pto_suptec    = w_qtd_nqm_sem_lote-yypto_suptec. " Pontuação do Suporte Técnico
        w_alv_avaliacao-pto_qualidade = w_qtd_nqm_sem_lote-pto_qa      . " Pontuação de Qualidade
        w_alv_avaliacao-qtd_nqm       = w_qtd_nqm_sem_lote-qtd_nqm     . " Qtd Notas QM
      ELSE.
        CLEAR: w_alv_avaliacao-pto_espec    ,
               w_alv_avaliacao-pto_rdf      ,
               w_alv_avaliacao-pto_suptec   ,
               w_alv_avaliacao-pto_qualidade,
               w_alv_avaliacao-qtd_nqm      .
      ENDIF.
    ENDIF.

*----------------------------------------------------------------------
*    Pontuação de compras
*----------------------------------------------------------------------
    CLEAR w_pontuacao_compras.
    READ TABLE t_pontuacao_compras
    INTO w_pontuacao_compras
    WITH KEY lifnr = w_forn_com_lote-lifnr
             werks = w_forn_com_lote-werk
    BINARY SEARCH.

*   Condição Comercial (Preço)
    IF w_pontuacao_compras-preco IS NOT INITIAL.
      v_preco = w_pontuacao_compras-preco.
      w_alv_avaliacao-preco = w_pontuacao_compras-preco.
    ELSE.
      CLEAR: v_preco, w_alv_avaliacao-preco.
    ENDIF.

*   Pontualidade (Entrega)
    IF w_pontuacao_compras-pontual IS NOT INITIAL.
      v_pontualidade = w_pontuacao_compras-pontual.
      w_alv_avaliacao-pontual = w_pontuacao_compras-pontual.
    ELSE.
      CLEAR: v_pontualidade, w_alv_avaliacao-pontual.
    ENDIF.

*   Relacionamento
    IF w_pontuacao_compras-relac IS NOT INITIAL.
      v_relacionamento = w_pontuacao_compras-relac.
      w_alv_avaliacao-relac = w_pontuacao_compras-relac.
    ELSE.
      CLEAR: v_relacionamento, w_alv_avaliacao-relac.
    ENDIF.

    v_total_pontos = v_preco + v_pontualidade + v_relacionamento.
    w_alv_avaliacao-p_total  = v_total_pontos.

    IF w_pontuacao_compras-justif IS NOT INITIAL.
      w_alv_avaliacao-justif = c_icone_visualizar.
    ELSE.
      w_alv_avaliacao-justif = c_icone_sem_justifc.
    ENDIF.

    w_alv_avaliacao-qtd_lotes = w_forn_com_lote-qtd_lotes.

    APPEND w_alv_avaliacao TO t_alv_avaliacao.
  ENDLOOP.
ENDFORM.                    "f_montar_alv_for_aval

*&---------------------------------------------------------------------*
*&      Form  f_montar_fieldcatalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_t_fcat    text
*      -->p_w_fcat    text
*      -->p_structure text
*      -->p_editar    text
*----------------------------------------------------------------------*
FORM f_montar_fieldcatalog
  TABLES p_t_fcat    TYPE lvc_t_fcat
   USING p_w_fcat    TYPE lvc_s_fcat
         p_structure TYPE ddobjname
         p_editar    TYPE c        .

  DATA: t_campos TYPE STANDARD TABLE OF dd03p,
        w_campos LIKE LINE OF t_campos      .

  DATA: v_campo       TYPE rollname       ,
        v_nome_coluna TYPE dd04t-scrtext_l.

  CONSTANTS:
    c_versao_ativa TYPE ddobjstate VALUE 'A',
    c_pt_br        TYPE t002-laiso VALUE 'PT'.

  FREE: p_t_fcat, p_w_fcat.

* Obtém o nome dos campos da estrutura da SE11
  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name          = p_structure
      state         = c_versao_ativa
    TABLES
      dd03p_tab     = t_campos
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  LOOP AT t_campos INTO w_campos.
    v_campo = w_campos-rollname.

*   Seleciona a descrição longa do elemento de dados
    SELECT SINGLE scrtext_l
    FROM  dd04t
    INTO (v_nome_coluna)
     WHERE rollname  = v_campo
      AND ddlanguage = c_pt_br
      AND as4local   = c_versao_ativa.

    MOVE-CORRESPONDING w_campos TO p_w_fcat.
    p_w_fcat-coltext = v_nome_coluna.
    p_w_fcat-col_pos = sy-tabix     .

    IF p_editar IS NOT INITIAL.
      IF    w_campos-fieldname = c_f4_preco    " PRECO
         OR w_campos-fieldname = c_f4_pontual  " PONTUAL
         OR w_campos-fieldname = c_f4_relac.   " RELAC
        p_w_fcat-edit = 'X'.
      ENDIF.
    ENDIF.

    CASE w_campos-fieldname.
      WHEN c_f4_preco              " PRECO
        OR c_f4_pontual            " PONTUAL
        OR c_f4_relac.             " RELAC
        p_w_fcat-f4availabl = 'X'. " F4 (Search Help)
      WHEN c_hotspot_justif.       " JUSTIF
        p_w_fcat-icon    = 'X'.
        p_w_fcat-hotspot = 'X'.
      WHEN c_hotspot_fornec
        OR c_hotspot_fabric
        OR c_hotspot_material
        OR c_hotspot_qtd_lotes
        OR c_hotspot_qtd_nqm.
        p_w_fcat-hotspot = 'X'.
    ENDCASE.

    APPEND p_w_fcat TO p_t_fcat.
    CLEAR p_w_fcat.
  ENDLOOP.
ENDFORM.                    "f_montar_fieldcatalog

*&---------------------------------------------------------------------*
*&      Form  f_montar_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_container text
*      -->p_alv_grid  text
*      -->p_nome_cont text
*      -->p_fieldcat  text
*      -->p_t_alv     text
*      -->p_titulo    text
*      -->p_toolbar   text
*----------------------------------------------------------------------*
FORM f_montar_alv
 USING p_container  TYPE REF TO cl_gui_custom_container
       p_alv_grid   TYPE REF TO cl_gui_alv_grid
       p_nome_cont  TYPE scrfname
       p_fieldcat   TYPE lvc_t_fcat
       p_t_alv      TYPE STANDARD TABLE
       p_titulo     TYPE lvc_s_layo-grid_title
       p_no_toolbar TYPE c.

  IF p_container IS NOT INITIAL.
    p_alv_grid->refresh_table_display( ).

    CALL METHOD p_container->set_visible
      EXPORTING
        visible = space.

    FREE p_container.
  ENDIF.

* Instância o container (cl_gui_custom_container)
  CREATE OBJECT p_container
    EXPORTING
      container_name = p_nome_cont
    EXCEPTIONS
      OTHERS         = 6.

* Cria uma instância da classe cl_gui_alv_grid no custom container
* inserido no layout da tela
  CREATE OBJECT p_alv_grid
    EXPORTING
      i_parent = p_container
    EXCEPTIONS
      OTHERS   = 5.

* Tecla <<ENTER>> foi pressionada
  CALL METHOD p_alv_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

* Dados foram alterados e o cursor foi movido de célula
  CALL METHOD p_alv_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

* Campos quem possuem ajuda de pesquisa
  DATA: t_campos_f4 TYPE lvc_t_f4 WITH HEADER LINE.
  t_campos_f4-fieldname = c_f4_preco. " PRECO
  t_campos_f4-register  = 'X'       .
  INSERT table t_campos_f4          .

  t_campos_f4-fieldname = c_f4_pontual. " PONTUAL
  t_campos_f4-register  = 'X'         .
  INSERT table t_campos_f4            .

  t_campos_f4-fieldname = c_f4_relac. " RELAC
  t_campos_f4-register  = 'X'       .
  INSERT table t_campos_f4          .

* Método para utilizar o Search Help definido anteriormente
  CALL METHOD p_alv_grid->register_f4_for_fields
    EXPORTING
      it_f4 = t_campos_f4[].

  DATA: o_evt_alv TYPE REF TO lcl_evento_alv.
  CREATE OBJECT o_evt_alv.
  SET HANDLER o_evt_alv->hotspot_click FOR p_alv_grid.
  SET HANDLER o_evt_alv->onf4          FOR p_alv_grid.
  SET HANDLER o_evt_alv->data_changed  FOR p_alv_grid.

  DATA: w_alv_layout TYPE lvc_s_layo.
  w_alv_layout-zebra      = 'X'     . " Zebrado
  w_alv_layout-cwidth_opt = 'X'     . " Otimização da coluna
  w_alv_layout-grid_title = p_titulo. " Titulo do ALV

  DATA: t_excluir_campo TYPE ui_functions.

* Exclui os botões da barra de tarefas do ALV (Exportar p/ Excel)
  IF p_no_toolbar IS NOT INITIAL.
    w_alv_layout-no_toolbar = p_no_toolbar.
  ELSE.
*   Exclui opções de toolbar
    APPEND cl_gui_alv_grid=>mc_fc_sum            TO t_excluir_campo.
    APPEND cl_gui_alv_grid=>mc_fc_subtot         TO t_excluir_campo.
    APPEND cl_gui_alv_grid=>mc_fc_loc_undo       TO t_excluir_campo.
    APPEND cl_gui_alv_grid=>mc_fc_loc_append_row TO t_excluir_campo.
    APPEND cl_gui_alv_grid=>mc_fc_loc_copy       TO t_excluir_campo.
    APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row   TO t_excluir_campo.
    APPEND cl_gui_alv_grid=>mc_fc_loc_cut        TO t_excluir_campo.
    APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row TO t_excluir_campo.
    APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row TO t_excluir_campo.
    APPEND cl_gui_alv_grid=>mc_fc_loc_move_row   TO t_excluir_campo.
    APPEND cl_gui_alv_grid=>mc_fc_loc_paste      TO t_excluir_campo.
  ENDIF.

* Exibe o relatório ALV
  CALL METHOD p_alv_grid->set_table_for_first_display
    EXPORTING
      is_layout            = w_alv_layout
      it_toolbar_excluding = t_excluir_campo
    CHANGING
      it_outtab            = p_t_alv
      it_fieldcatalog      = p_fieldcat
    EXCEPTIONS
      OTHERS               = 4.

  p_alv_grid->refresh_table_display( ).
ENDFORM.                    "f_montar_alv

*&---------------------------------------------------------------------*
*&      Form  f_montar_salv_popup
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_ALV    text
*      -->P_COLUMN    text
*----------------------------------------------------------------------*
FORM f_montar_salv_popup
 USING p_t_alv  TYPE STANDARD TABLE
       p_column TYPE lvc_s_col-fieldname.

  DATA: obj_alv_popup TYPE REF TO cl_salv_table        ,
        obj_cols_tab  TYPE REF TO cl_salv_columns_table,
        obj_col_tab   TYPE REF TO cl_salv_column_table ,
        obj_events    TYPE REF TO cl_salv_events_table ,
        obj_evt_local TYPE REF TO lcl_salv_eventos     .

* Cria uma instância para exibir os dados na tabela no ALV
  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table = obj_alv_popup
    CHANGING
      t_table      = p_t_alv.

* Obtém as características das colunas do ALV
  obj_cols_tab = obj_alv_popup->get_columns( ).

  CASE p_column.
    WHEN c_hotspot_qtd_lotes.
* Seleciona os detalhes da coluna 'PRUEFLOS' (Nº lote de controle)
      obj_col_tab ?= obj_cols_tab->get_column( c_hotspot_lote_ctrl ).
    WHEN c_hotspot_qtd_nqm.
      obj_col_tab ?= obj_cols_tab->get_column( c_hotspot_qmnum ).
  ENDCASE.

* Define a coluna 'PRUEFLOS' como hotspot
  CALL METHOD obj_col_tab->set_cell_type
    EXPORTING
      value = if_salv_c_cell_type=>hotspot.

  obj_events = obj_alv_popup->get_event( ).

  CREATE OBJECT obj_evt_local.

* Evento ativo após click em um hostpot ou botão
  SET HANDLER obj_evt_local->on_link_click FOR obj_events.

* Define que o ALV será exibido como um POPUP
  CALL METHOD obj_alv_popup->set_screen_popup
    EXPORTING
      start_column = 40
      end_column   = 115
      start_line   = 6
      end_line     = 15.

* Exibe o ALV
  obj_alv_popup->display( ).
ENDFORM.                    "f_montar_salv_popup

*&---------------------------------------------------------------------*
*&      Form  f_salvar_pontuacao
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_salvar_pontuacao.
* Valida novamente os valores inseridos (register_edit_event)
* para que não seja possível inserir nenhum valor fora dos permitidos
  CALL METHOD obj_alv_grid->check_changed_data( ).

  DATA: v_data      TYPE c LENGTH 10,
        v_hora      TYPE c LENGTH 08,
        v_data_hora TYPE c LENGTH 19.

  WRITE sy-datum TO v_data DD/MM/YYYY                .
  WRITE sy-uzeit TO v_hora USING EDIT MASK '__:__:__'.

  CONCATENATE v_data v_hora INTO v_data_hora SEPARATED BY space.

  DELETE t_alv_pontuacao WHERE preco   IS INITIAL  " Condição Comercial (Preço)
                           AND pontual IS INITIAL  " Pontualidade (Entrega)
                           AND relac   IS INITIAL. " Relacionamento

* Verifica se algum registro do relatório foi alterado para inserir na YTNQM_PONTUACAO
  LOOP AT t_alv_pontuacao INTO w_alv_pontuacao.
    w_pontuacao_compras-mandt     = sy-mandt                 .
    w_pontuacao_compras-lifnr     = w_alv_pontuacao-lifnr    .
    w_pontuacao_compras-werks     = w_alv_pontuacao-werks    .
    w_pontuacao_compras-data_atu  = v_data_hora              .
    w_pontuacao_compras-usuario   = sy-uname                 .

    IF w_alv_pontuacao-preco IS INITIAL.
      w_pontuacao_compras-preco = c_sem_destaque. "0
    ELSE.
      w_pontuacao_compras-preco = w_alv_pontuacao-preco.
    ENDIF.

    IF w_alv_pontuacao-pontual IS INITIAL.
      w_pontuacao_compras-pontual = c_sem_destaque. "0
    ELSE.
      w_pontuacao_compras-pontual = w_alv_pontuacao-pontual.
    ENDIF.

    IF w_alv_pontuacao-relac IS INITIAL.
      w_pontuacao_compras-relac = c_sem_destaque. "0
    ELSE.
      w_pontuacao_compras-relac = w_alv_pontuacao-relac.
    ENDIF.

    READ TABLE r_periodo_atual
    INTO w_periodo
    INDEX 1.

    w_pontuacao_compras-data_ini  = w_periodo-low .
    w_pontuacao_compras-data_fim  = w_periodo-high.

    IF w_alv_pontuacao-justif = c_icone_visualizar.
      w_pontuacao_compras-justif = 'X'.
    ELSE.
      w_pontuacao_compras-justif = space.
    ENDIF.

    APPEND w_pontuacao_compras TO t_pontuacao_compras.
  ENDLOOP.

  IF t_pontuacao_compras IS INITIAL.
    MESSAGE 'Nenhuma alteração foi realizada, verifique antes de salvar'(007)
    TYPE 'I'.
    EXIT.
  ELSE.
*   Insere os registros modificados na tabela YTNQM_PONTUACAO
    MODIFY ytnqm_pontuacao FROM TABLE t_pontuacao_compras.
  ENDIF.

  DATA: t_justif_forn TYPE STANDARD TABLE OF tline           ,
        t_justif_aux  TYPE STANDARD TABLE OF ty_justificativa.

  DATA: w_justif_forn LIKE LINE OF t_justif_forn,
        w_justif_aux  LIKE LINE OF t_justif_aux .

  t_justif_aux[] = t_justificativa[].

*----------------------------------------------------------------------
* 'Quebra' a tabela interna de justificativas por Fornecedor/Centro
* e insere na tabela auxiliar T_JUSTIF_FORN para usar a SAVE_TEXT
*----------------------------------------------------------------------
  LOOP AT t_justif_aux INTO w_justif_aux.
    FREE t_justif_forn.

    READ TABLE t_justificativa
    TRANSPORTING NO FIELDS
    WITH KEY lifnr = w_justif_aux-lifnr
             werks = w_justif_aux-werks.

    v_indice = sy-tabix.

    LOOP AT t_justificativa INTO w_justificativa FROM v_indice.
      IF w_justificativa-lifnr <> w_justif_aux-lifnr.
        EXIT.
      ELSEIF w_justificativa-lifnr = w_justif_aux-lifnr
         AND w_justificativa-werks <> w_justif_aux-werks.
        EXIT.
      ELSE.
        w_justif_forn-tdformat = c_coluna             .
        w_justif_forn-tdline   = w_justificativa-value.
        APPEND w_justif_forn TO t_justif_forn         .
      ENDIF.
    ENDLOOP.

*----------------------------------------------------------------------
*   Grava o nome do usuário e o período
*----------------------------------------------------------------------
    w_justif_forn-tdformat = c_coluna            .
    w_justif_forn-tdline   = '_____________________________________'.
    APPEND w_justif_forn TO t_justif_forn        .

    CONCATENATE 'Período         :' v_periodo_selec
    INTO w_justif_forn-tdline SEPARATED BY space.
    w_justif_forn-tdformat = c_coluna    .
    APPEND w_justif_forn TO t_justif_forn.

    CONCATENATE 'Gravado por     :' sy-uname
    INTO w_justif_forn-tdline SEPARATED BY space.
    w_justif_forn-tdformat = c_coluna    .
    APPEND w_justif_forn TO t_justif_forn.

    CONCATENATE 'Data de gravação:' v_data_hora
    INTO w_justif_forn-tdline SEPARATED BY space.
    w_justif_forn-tdformat = c_coluna    .
    APPEND w_justif_forn TO t_justif_forn.

    w_justif_forn-tdformat = c_coluna            .
    w_justif_forn-tdline   = '_____________________________________'.
    APPEND w_justif_forn TO t_justif_forn        .

*   Tabela auxiliar somente com Fornecedor e centro
    IF t_justif_forn IS NOT INITIAL.
      DATA: w_head TYPE thead.

      CONCATENATE w_justif_aux-lifnr " Fornecedor
                  w_justif_aux-werks " Centro
             INTO w_head-tdname    .

      w_head-tdid     = c_id_texto. " ZQM - Justif. pontos fornecedor
      w_head-tdspras  = sy-langu  . " PT
      w_head-tdobject = c_objeto  . " ZQM_PONTOS

*     Salva a justificativa de pontuação dada ao fornecedor // STXH // SE75
      CALL FUNCTION 'SAVE_TEXT'
        EXPORTING
          header          = w_head
          savemode_direct = 'X'
        TABLES
          lines           = t_justif_forn
        EXCEPTIONS
          OTHERS          = 5.

      DELETE t_justif_aux WHERE lifnr = w_justif_aux-lifnr
                            AND werks = w_justif_aux-werks.
    ENDIF.
  ENDLOOP. " LOOP AT t_justif_aux INTO w_justif_aux.

* Bloqueia os campos após salvar
  CALL METHOD obj_alv_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 0.

* Atualiza as linhas e colunas com os valores salvos
  DATA: w_stable TYPE lvc_s_stbl.
  w_stable-row = 'X'.
  w_stable-col = 'X'.

* Exibe o ALV novamente mas com os campos bloqueados
  CALL METHOD obj_alv_grid->refresh_table_display
    EXPORTING
      is_stable = w_stable
    EXCEPTIONS
      finished  = 1
      OTHERS    = 2.

* Muda o status da variável para indicar que os dados já foram salvos
  v_pontuacao_salva = 'X'.

* Exclui o botão 'Salvar pontuações' da barra de status
  APPEND c_btn_salvar TO t_fcode.

  MESSAGE 'Pontuação inserida com sucesso'(005) TYPE 'I'.
ENDFORM.                    "f_salvar_pontuacao

*&---------------------------------------------------------------------*
*&      Form  event_hotspot_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ROW      text
*      -->P_COLUMN   text
*----------------------------------------------------------------------*
FORM event_hotspot_click
 USING p_row    TYPE lvc_s_row
       p_column TYPE lvc_s_col.

*-----------------------------------------------------------------------
* Insere a pontuação de compras
*-----------------------------------------------------------------------
  IF p_pont IS NOT INITIAL.
    READ TABLE t_alv_pontuacao
    INTO w_alv_pontuacao
    INDEX p_row-index.

    CASE p_column.
      WHEN c_hotspot_justif. " JUSTIF
        IF w_alv_pontuacao-justif = c_icone_editar.
          PERFORM f_preencher_justificativa
            USING p_row
                  w_alv_pontuacao-lifnr
                  w_alv_pontuacao-werks.

        ELSEIF w_alv_pontuacao-justif = c_icone_visualizar.
          PERFORM f_exibir_justificativa
            USING p_row
                  w_alv_pontuacao-lifnr
                  w_alv_pontuacao-werks.
        ENDIF.
      WHEN c_hotspot_fornec. " LIFNR
        PERFORM f_exibir_fornecedor
          USING p_row
                w_alv_pontuacao-lifnr
                w_alv_pontuacao-werks.
    ENDCASE.

*-----------------------------------------------------------------------
* Visualização do relatório
*-----------------------------------------------------------------------
  ELSEIF p_forn IS NOT INITIAL.
    READ TABLE t_alv_avaliacao
    INTO w_alv_avaliacao
    INDEX p_row-index.

    CASE p_column.
      WHEN c_hotspot_justif. " JUSTIF
        IF w_alv_avaliacao-justif = c_icone_visualizar.
          v_pontuacao_salva = 'X'. " Pontuação foi salva pelo usuário de Suprimentos

          PERFORM f_exibir_justificativa
            USING p_row
                  w_alv_avaliacao-lifnr
                  w_alv_avaliacao-werks.
        ELSE.
          MESSAGE 'A justificativa da pontuação não foi '&
                  'cadastrada para esse fornecedor'
             TYPE 'I'.
        ENDIF.

      WHEN c_hotspot_fornec. " LIFNR
        PERFORM f_exibir_fornecedor
          USING p_row
                w_alv_avaliacao-lifnr
                w_alv_avaliacao-werks.

      WHEN c_hotspot_fabric.  " HERSTELLER
        PERFORM f_exibir_fornecedor
          USING p_row
                w_alv_avaliacao-hersteller
                w_alv_avaliacao-werks.

      WHEN c_hotspot_material. " MATNR
        PERFORM f_exibir_material
          USING p_row
                w_alv_avaliacao-matnr
                w_alv_avaliacao-werks.
      WHEN c_hotspot_qtd_lotes. " QTD_LOTES
        PERFORM f_exibir_lotes
          USING p_row
                w_alv_avaliacao-lifnr
                w_alv_avaliacao-werks
                w_alv_avaliacao-hersteller
                w_alv_avaliacao-matnr.

      WHEN c_hotspot_qtd_nqm. " QTD_NQM
        PERFORM f_exibir_notas_qm
          USING p_row
                w_alv_avaliacao-lifnr
                w_alv_avaliacao-werks
                w_alv_avaliacao-hersteller
                w_alv_avaliacao-matnr.
    ENDCASE.
  ENDIF.
ENDFORM.                    "event_hotspot_click

*&---------------------------------------------------------------------*
*&      Form  f_preencher_justificativa
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ROW      text
*      -->P_LIFNR    text
*      -->P_WERKS    text
*----------------------------------------------------------------------*
FORM f_preencher_justificativa
  USING p_row   TYPE lvc_s_row
        p_lifnr TYPE yalv_nqm_preenche_pto-lifnr
        p_werks TYPE yalv_nqm_preenche_pto-werks.

  FREE: t_val_popup, w_val_popup.

* Se a pontuação já foi salva, não permite inserir novamente
  CHECK v_pontuacao_salva IS INITIAL.

* Abre um popup com múltiplas linhas de edição
  CALL FUNCTION 'TERM_CONTROL_EDIT'
    EXPORTING
      titel          = 'Justificativa'(004)
      langu          = sy-langu
    TABLES
      textlines      = t_val_popup
    EXCEPTIONS
      user_cancelled = 1
      OTHERS         = 2.

  LOOP AT t_val_popup INTO w_val_popup.
    w_justificativa-lifnr = p_lifnr          .
    w_justificativa-werks = p_werks          .
    w_justificativa-value = w_val_popup-value.
    APPEND w_justificativa TO t_justificativa.
  ENDLOOP.

* Se algum valor foi informado no popup, altera a tabela
  READ TABLE t_justificativa
  INTO w_justificativa
  WITH KEY lifnr = p_lifnr
           werks = p_werks.

  IF sy-subrc = 0.
    w_alv_pontuacao-justif = c_icone_visualizar.
    MODIFY t_alv_pontuacao FROM w_alv_pontuacao INDEX p_row.

*   Exibe o ALV novamente mas com os campos bloqueados
    obj_alv_grid->refresh_table_display( ).
  ENDIF.
ENDFORM.                    "f_preencher_justificativa

*&---------------------------------------------------------------------*
*&      Form  f_exibir_justificativa
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ROW      text
*      -->P_LIFNR    text
*      -->P_WERKS    text
*----------------------------------------------------------------------*
FORM f_exibir_justificativa
   USING p_row  TYPE lvc_s_row
         p_lifnr TYPE yalv_nqm_preenche_pto-lifnr
         p_werks TYPE yalv_nqm_preenche_pto-werks.

  DATA: t_justif_forn TYPE STANDARD TABLE OF tline,
        w_justif_forn LIKE LINE OF t_justif_forn  ,
        w_head        TYPE thead                  .

*----------------------------------------------------------------------
* Pontuação ainda não foi salva
*----------------------------------------------------------------------
  IF v_pontuacao_salva IS INITIAL.
    FREE: t_val_popup, w_val_popup.

    READ TABLE t_justificativa
    TRANSPORTING NO FIELDS
    WITH KEY lifnr = p_lifnr
             werks = p_werks.

    v_indice = sy-tabix.

*   Verifica se a justificativa foi inserida pelo usuário
*   se estiver vazia é porque já foi inserido e salvo.
    IF v_indice <> 0.

      LOOP AT t_justificativa INTO w_justificativa FROM v_indice.
        IF w_justificativa-lifnr <> p_lifnr.
          EXIT.
        ELSEIF w_justificativa-lifnr = p_lifnr
           AND w_justificativa-werks <> p_werks.
          EXIT.
        ELSE.
          w_val_popup-value = w_justificativa-value.
          APPEND w_val_popup TO t_val_popup.
        ENDIF.
      ENDLOOP.

*     Abre um popup com múltiplas linhas de edição
      CALL FUNCTION 'TERM_CONTROL_EDIT'
        EXPORTING
          titel          = 'Justificativa'(004)
          langu          = sy-langu
        TABLES
          textlines      = t_val_popup
        EXCEPTIONS
          user_cancelled = 1
          OTHERS         = 2.

*     Exclui o valor antigo para que seja atualizado
      DELETE t_justificativa
        WHERE lifnr = p_lifnr
          AND werks = p_werks.

      IF t_val_popup IS NOT INITIAL.
        LOOP AT t_val_popup INTO w_val_popup.
          w_justificativa-lifnr = p_lifnr          .
          w_justificativa-werks = p_werks          .
          w_justificativa-value = w_val_popup-value.
          APPEND w_justificativa TO t_justificativa.
        ENDLOOP.
      ELSE.
        w_alv_pontuacao-justif = c_icone_editar.
        MODIFY t_alv_pontuacao FROM w_alv_pontuacao INDEX p_row-index.

        obj_alv_grid->refresh_table_display( ).
      ENDIF.

*   Obtém o valor salvo anteriormente
    ELSE.
      FREE: t_justif_forn, w_justif_forn, w_head.

      CONCATENATE p_lifnr      " Fornecedor
                  p_werks      " Centro
             INTO w_head-tdname.

      w_head-tdid     = c_id_texto. " ZQM - Justif. pontos fornecedor
      w_head-tdspras  = sy-langu  . " PT
      w_head-tdobject = c_objeto  . " ZQM_PONTOS

*     Verifica se o objeto de texto foi criado na SE75 (SAVE_TEXT)
      SELECT COUNT( DISTINCT tdobject )
         FROM stxh CLIENT SPECIFIED
         INTO (vl_qtd_registros)
         WHERE mandt    = sy-mandt
           AND tdobject = w_head-tdobject
           AND tdname   = w_head-tdname
           AND tdid     = w_head-tdid
           AND tdspras  = w_head-tdspras.

      CHECK vl_qtd_registros <> 0.

      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          object    = w_head-tdobject
          name      = w_head-tdname
          id        = w_head-tdid
          language  = w_head-tdspras
          local_cat = ' '
        TABLES
          lines     = t_justif_forn.

*     Inibe as linhas de detalhe de inserção (usuário, período, data de inserção)
      DATA: v_qtd_itens TYPE i.
      DESCRIBE TABLE t_justif_forn LINES v_qtd_itens.

      v_qtd_itens = v_qtd_itens - c_qtd_linhas_log.

      LOOP AT t_justif_forn INTO w_justif_forn.
        IF sy-tabix <= v_qtd_itens.
          APPEND w_justif_forn-tdline TO t_val_popup.
        ENDIF.
      ENDLOOP.

*     Abre um popup com múltiplas linhas de edição
      CALL FUNCTION 'TERM_CONTROL_EDIT'
        EXPORTING
          titel          = 'Justificativa'(004)
          langu          = sy-langu
        TABLES
          textlines      = t_val_popup
        EXCEPTIONS
          user_cancelled = 1
          OTHERS         = 2.

      DELETE t_justificativa
        WHERE lifnr = p_lifnr
          AND werks = p_werks.

      IF t_val_popup IS NOT INITIAL.
        LOOP AT t_val_popup INTO w_val_popup.
          w_justificativa-lifnr = p_lifnr          .
          w_justificativa-werks = p_werks          .
          w_justificativa-value = w_val_popup-value.
          APPEND w_justificativa TO t_justificativa.
        ENDLOOP.
      ELSE.
        w_alv_pontuacao-justif = c_icone_editar.
        MODIFY t_alv_pontuacao FROM w_alv_pontuacao INDEX p_row-index.

        obj_alv_grid->refresh_table_display( ).
      ENDIF.
    ENDIF.

*----------------------------------------------------------------------
* Pontuação já foi salva, somente exibe a justificativa
*----------------------------------------------------------------------
  ELSEIF v_pontuacao_salva IS NOT INITIAL.
    FREE: t_val_popup, t_justif_forn, w_justif_forn, w_head.

    CONCATENATE p_lifnr      " Fornecedor
                p_werks      " Centro
           INTO w_head-tdname.

    w_head-tdid     = c_id_texto. " ZQM - Justif. pontos fornecedor
    w_head-tdspras  = sy-langu  . " PT
    w_head-tdobject = c_objeto  . " ZQM_PONTOS

*   Verifica se o objeto de texto foi criado na SE75 (SAVE_TEXT)
    SELECT COUNT( DISTINCT tdobject )
       FROM stxh CLIENT SPECIFIED
       INTO (vl_qtd_registros)
       WHERE mandt    = sy-mandt
         AND tdobject = w_head-tdobject
         AND tdname   = w_head-tdname
         AND tdid     = w_head-tdid
         AND tdspras  = w_head-tdspras.

    CHECK vl_qtd_registros <> 0.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        object    = w_head-tdobject
        name      = w_head-tdname
        id        = w_head-tdid
        language  = w_head-tdspras
        local_cat = ' '
      TABLES
        lines     = t_justif_forn.

    LOOP AT t_justif_forn INTO w_justif_forn.
      APPEND w_justif_forn-tdline TO t_val_popup.
    ENDLOOP.

    DATA: v_qtd_linhas TYPE i.
    DESCRIBE TABLE t_justif_forn LINES v_qtd_linhas.
    v_qtd_linhas = v_qtd_linhas + c_qtd_lin_log_exib.

    CALL FUNCTION 'POPUP_WITH_TABLE'
      EXPORTING
        endpos_col   = 132
        endpos_row   = v_qtd_linhas "20
        startpos_col = 15
        startpos_row = 10
        titletext    = 'Justificativa'(004)
      TABLES
        valuetab     = t_val_popup
      EXCEPTIONS
        break_off    = 1
        OTHERS       = 2.
  ENDIF.
ENDFORM.                    "f_exibir_justificativa

*&---------------------------------------------------------------------*
*&      Form  f_exibir_fornecedor
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ROW      text
*      -->P_LIFNR    text
*      -->P_WERKS    text
*----------------------------------------------------------------------*
FORM f_exibir_fornecedor
  USING p_row   TYPE lvc_s_row
        p_lifnr TYPE yalv_nqm_preenche_pto-lifnr
        p_werks TYPE yalv_nqm_preenche_pto-werks.

  SET PARAMETER ID 'LIF' FIELD p_lifnr            .
  SET PARAMETER ID 'BUK' FIELD p_werks            .
  SET PARAMETER ID 'KDY' FIELD c_chk_endereco_xk03.         " /110

  CALL TRANSACTION c_xk03 AND SKIP FIRST SCREEN.
ENDFORM.                    "f_exibir_fornecedor

*&---------------------------------------------------------------------*
*&      Form  f_exibir_material
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ROW      text
*      -->P_LIFNR    text
*      -->P_WERKS    text
*----------------------------------------------------------------------*
FORM f_exibir_material
  USING p_row   TYPE lvc_s_row
        p_matnr TYPE yalv_nqm_avaliacao-matnr
        p_werks TYPE yalv_nqm_avaliacao-werks.

  SET PARAMETER ID 'MAT' FIELD p_matnr.
  CALL TRANSACTION c_mm03 AND SKIP FIRST SCREEN.
ENDFORM.                    "f_exibir_material

*&---------------------------------------------------------------------*
*&      Form  event_link_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ROW  text
*      -->P_COLUMN  text
*----------------------------------------------------------------------*
FORM event_link_click
  USING p_row
        p_column.

  CASE p_column.
    WHEN c_hotspot_lote_ctrl.
      CLEAR w_alv_lotes.
      READ TABLE t_alv_lotes
      INTO w_alv_lotes
      INDEX p_row.

*     Exibe o lote de controle
      SET PARAMETER ID 'QLS'  FIELD w_alv_lotes-prueflos.
      CALL TRANSACTION c_qa03 AND SKIP FIRST SCREEN.

    WHEN c_hotspot_qmnum.
      CLEAR w_alv_nota_qm.
      READ TABLE t_alv_nota_qm
      INTO w_alv_nota_qm
      INDEX p_row.

*     Exibe a nota de QM
      SET PARAMETER ID 'IQM'  FIELD w_alv_nota_qm-qmnum.
      CALL TRANSACTION c_qm03 AND SKIP FIRST SCREEN.
  ENDCASE.
ENDFORM.                    " event_link_click

*&---------------------------------------------------------------------*
*&      Form  event_onf4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_FIELDNAME    text
*      -->P_ES_ROW_NO      text
*      -->P_ER_EVENT_DATA  text
*----------------------------------------------------------------------*
FORM event_onf4
 USING p_e_fieldname   TYPE lvc_fname
       p_es_row_no     TYPE lvc_s_roid
       p_er_event_data TYPE REF TO cl_alv_event_data.

  DATA: BEGIN OF ls_data       ,
          value TYPE domvalue_l,
          dtext TYPE val_text  ,
        END OF ls_data         .

  DATA: t_val_dominio     LIKE TABLE OF ls_data   ,
        t_val_selecionado TYPE TABLE OF ddshretval,
        t_nome_campo      TYPE TABLE OF dselc     .

  DATA: w_nome_campo      TYPE dselc        ,
        w_val_selecionado TYPE ddshretval   ,
        v_dominio         TYPE dd07t-domname.

  READ TABLE t_alv_pontuacao
  INTO w_alv_pontuacao
  INDEX p_es_row_no-row_id.

  CASE p_e_fieldname.
    WHEN c_f4_preco. " PRECO
      v_dominio = c_preco.
    WHEN c_f4_pontual.
      v_dominio = c_pontual.
    WHEN c_f4_relac.
      v_dominio = c_relac.
  ENDCASE.

  IF v_dominio IS NOT INITIAL.
*   Obtém os valores do domínio
    SELECT a~domvalue_l AS value
           b~ddtext     AS dtext
      INTO TABLE t_val_dominio
      FROM dd07l AS a
      INNER JOIN dd07t AS b
         ON a~domname    = b~domname
        AND a~as4local   = b~as4local
        AND a~valpos     = b~valpos
        AND a~as4vers    = b~as4vers
      WHERE a~domname    = v_dominio
        AND b~ddlanguage = sy-langu.
  ENDIF.

* Verifica se encontrou valores para o domínio
  IF t_val_dominio IS NOT INITIAL.
    CLEAR w_nome_campo                          .
    w_nome_campo-fldname   = c_campo_search_help.           " F0001
    w_nome_campo-dyfldname = p_e_fieldname      . " P_SUP_POS
    APPEND w_nome_campo TO t_nome_campo         .

*     Cria o Search Help dinamicamente com os valores do domínio
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = p_e_fieldname       " P_SUP_POS
        value_org       = c_search_help_domin " S
      TABLES
        value_tab       = t_val_dominio
        dynpfld_mapping = t_nome_campo
        return_tab      = t_val_selecionado
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.

    READ TABLE t_val_selecionado
    INTO w_val_selecionado
    WITH KEY fieldname = c_campo_search_help.               " F0001

    IF w_val_selecionado IS NOT INITIAL.
      CASE v_dominio.
        WHEN c_preco.
          w_alv_pontuacao-preco = w_val_selecionado-fieldval.
        WHEN c_pontual.
          w_alv_pontuacao-pontual = w_val_selecionado-fieldval.
        WHEN c_relac.
          w_alv_pontuacao-relac = w_val_selecionado-fieldval.
      ENDCASE.

      MODIFY t_alv_pontuacao FROM w_alv_pontuacao INDEX p_es_row_no-row_id.
    ENDIF.
  ENDIF.

* Atualiza as linhas e colunas com os valores salvos
  DATA: w_stable TYPE lvc_s_stbl.
  w_stable-row = 'X'            .
  w_stable-col = 'X'            .

  CALL METHOD obj_alv_grid->refresh_table_display
    EXPORTING
      is_stable      = w_stable
      i_soft_refresh = 'X'
    EXCEPTIONS
      finished       = 1
      OTHERS         = 2.

  p_er_event_data->m_event_handled = 'X'.
ENDFORM.                                                    "event_onf4

*&---------------------------------------------------------------------*
*&      Form  event_data_changed
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM event_data_changed
  USING p_er_data_changed TYPE REF TO cl_alv_changed_data_protocol.

  TYPES: BEGIN OF ty_val_dominio ,
          dominio TYPE domname   ,
          value   TYPE domvalue_l,
          dtext   TYPE val_text  ,
        END OF ty_val_dominio    .

  DATA: t_val_dominio TYPE TABLE OF ty_val_dominio.

  DATA: w_val_dominio LIKE LINE OF t_val_dominio  ,
        w_celula      TYPE lvc_s_modi             ,
        w_row_id      TYPE lvc_s_row              ,
        w_col_id      TYPE lvc_s_col              ,
        w_row_no      TYPE lvc_s_roid             .

  DATA: v_linha    TYPE i            ,
        v_valor    TYPE c            ,
        v_coluna   TYPE i            ,
        v_conteudo TYPE lvc_value    ,
        v_dominio  TYPE dd07l-domname.

* Obtém os valores permitidos cadastrados no domínio
  SELECT a~domname    AS dominio
         a~domvalue_l AS value
         b~ddtext     AS dtext
    INTO TABLE t_val_dominio
    FROM dd07l AS a
    INNER JOIN dd07t AS b
       ON a~domname    = b~domname
      AND a~as4local   = b~as4local
      AND a~valpos     = b~valpos
      AND a~as4vers    = b~as4vers
    WHERE a~domname    = c_preco    " YPRECO
      OR  a~domname    = c_pontual  " YPONTUAL
      OR  a~domname    = c_relac    " YRELAC
      AND b~ddlanguage = sy-langu.

  SORT t_val_dominio BY dominio ASCENDING.

* Verifica se o valor inserido é permitido com base nos valores do domínio
  LOOP AT p_er_data_changed->mt_good_cells INTO w_celula.

    IF w_celula-fieldname     = c_f4_preco.
      v_dominio = c_preco.
    ELSEIF w_celula-fieldname = c_f4_pontual.
      v_dominio = c_pontual.
    ELSEIF w_celula-fieldname = c_f4_relac.
      v_dominio = c_relac.
    ENDIF.

*   Obtém o conteúdo da linha alterada
    CALL METHOD p_er_data_changed->get_cell_value
      EXPORTING
        i_row_id    = w_celula-row_id
        i_fieldname = w_celula-fieldname
      IMPORTING
        e_value     = v_conteudo.

    SORT t_val_dominio BY dominio value ASCENDING.

    READ TABLE t_val_dominio
    TRANSPORTING NO FIELDS
    WITH KEY dominio = v_dominio
             value   = v_conteudo
    BINARY SEARCH.

    IF sy-subrc <> 0 AND v_conteudo IS NOT INITIAL.
      MESSAGE 'Valor inválido'(006) TYPE 'I'.

      CALL METHOD p_er_data_changed->modify_cell
        EXPORTING
          i_row_id    = w_celula-row_id
          i_fieldname = w_celula-fieldname
          i_value     = space.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "event_data_changed