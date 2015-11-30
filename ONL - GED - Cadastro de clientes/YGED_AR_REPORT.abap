*----------------------------------------------------------------------*
*                       xxxxxxxxxxxxxxxxx                              *
*----------------------------------------------------------------------*
* Programa : YGED_AR_REPORT                                            *
* Transação: YGED_AR_REPORT                                            *
* Descrição: Relatório ALV com dados do sistema de Gerenciamento       *
*            Eletrônico de Documento (YGED_AR)                         *
* Tipo     : Report ALV                                                *
* Módulo   : FI/AR (contas a pagar)                                    *
* Funcional: xxxxxxxxxxxxxxxxxxxx                                      *
* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  15.07.2013  #55263 - Desenvolvimento inicial               *
* ACTHIAGO  31.07.2013  #55263 - Inclusão da seleção dos bloqueios     *
*----------------------------------------------------------------------*

REPORT yged_ar_report NO STANDARD PAGE HEADING.

TYPE-POOLS: icon.

TABLES:
  ygedar_doc      , " GED - Cadastro de Clientes - Documentos
  yged_ar_1004_alv. " GED - Cadastro de Clientes - ALV de exibição Documentos

*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_tipo            ,
   kunnr TYPE ygedar_doc-kunnr,
   typed TYPE ygedar_doc-typed,
  END OF ty_tipo              .

*----------------------------------------------------------------------*
* Tabelas Internas                                                     *
*----------------------------------------------------------------------*
DATA:
  tl_alv_docto  TYPE STANDARD TABLE OF yged_ar_1004_alv, " ALV de exibição Documentos
  tl_dsc_icon   TYPE STANDARD TABLE OF yged_ar_1005_alv, " ALV Descrição ícones
  tl_documentos TYPE STANDARD TABLE OF ygedar_doc      ,
  tl_tipo       TYPE STANDARD TABLE OF ty_tipo         ,
  tl_fcat_icon  TYPE lvc_t_fcat                        ,
  tl_fcat_doc   TYPE lvc_t_fcat                        .

*----------------------------------------------------------------------*
* Work areas                                                           *
*----------------------------------------------------------------------*
DATA:
  wl_alv_docto  LIKE LINE OF tl_alv_docto ,
  wl_dsc_icon   LIKE LINE OF tl_dsc_icon  ,
  wl_documentos LIKE LINE OF tl_documentos,
  wl_tipo       LIKE LINE OF tl_tipo      ,
  wl_fcat_icon  TYPE lvc_s_fcat           ,
  wl_fcat_doc   TYPE lvc_s_fcat           ,
  wl_alv_layout TYPE lvc_s_layo           .

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
CONSTANTS:
  c_cont_doctos    TYPE scrfname    VALUE 'CONT_DOC_CLI'    ,
  c_cont_dsc_icn   TYPE scrfname    VALUE 'CONT_DSC_ICN'    ,
  c_versao_ativa   TYPE ddobjstate  VALUE 'A'               ,
  c_alv_documentos TYPE ddobjname   VALUE 'YGED_AR_1004_ALV',
  c_alv_icones     TYPE ddobjname   VALUE 'YGED_AR_1005_ALV',
  c_pt_br          TYPE t002-laiso  VALUE 'PT'              ,
  c_contas_receber TYPE tdwa-dokar  VALUE 'YAR'             , " Tipo de documento
  c_doc_parcial    TYPE draw-doktl  VALUE '0000'            , " Documento parcial
  c_hotspot_visual TYPE c LENGTH 10 VALUE 'VISUALIZAR'      ,
  c_hotspot_kunnr  TYPE c LENGTH 05 VALUE 'KUNNR'           , " Cliente
  c_versao         TYPE c LENGTH 07 VALUE 'VERSION'         ,
  c_status         TYPE c LENGTH 06 VALUE 'STATUS'          ,
  c_prazo          TYPE c LENGTH 05 VALUE 'PRAZO'           ,
  c_dias           TYPE c LENGTH 04 VALUE 'DIAS'            ,
  c_icone          TYPE c LENGTH 05 VALUE 'ICONE'           ,
  c_bloqueado      TYPE c LENGTH 09 VALUE 'BLOQUEADO'       ,
  c_vencido        TYPE c LENGTH 04 VALUE '@DF@'            ,
  c_a_vencer       TYPE c LENGTH 04 VALUE '@5Y@'            ,
  c_icone_verde    TYPE c LENGTH 04 VALUE '@08@'            ,
  c_icone_amarelo  TYPE c LENGTH 04 VALUE '@09@'            ,
  c_icone_vermelho TYPE c LENGTH 04 VALUE '@0A@'            ,
  c_icone_visualiz TYPE c LENGTH 04 VALUE '@10@'            ,
  c_icone_bloquear TYPE c LENGTH 04 VALUE '@06@'            ,
  c_icone_desbloq  TYPE c LENGTH 04 VALUE '@07@'            .

*----------------------------------------------------------------------*
* Objetos                                                              *
*----------------------------------------------------------------------*
DATA:
  obj_cont_doc  TYPE REF TO cl_gui_custom_container,
  obj_cont_icon TYPE REF TO cl_gui_custom_container,
  obj_alv_docto TYPE REF TO cl_gui_alv_grid        ,
  obj_alv_icon  TYPE REF TO cl_gui_alv_grid        .

*----------------------------------------------------------------------*
* Classes                                                              *
*----------------------------------------------------------------------*
CLASS lcl_evento_alv DEFINITION DEFERRED.

*----------------------------------------------------------------------*
*       CLASS lcl_evento_alv DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_evento_alv DEFINITION.
  PUBLIC SECTION.
    METHODS:
      hotspot_click
           FOR EVENT hotspot_click OF cl_gui_alv_grid
             IMPORTING e_row_id
                       e_column_id
                       es_row_no.
ENDCLASS.                    "lcl_evento_alv DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_evento_alv IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_evento_alv IMPLEMENTATION.

*---------------------------------------------------------------------*
*       METHOD hotspot_click                                          *
*---------------------------------------------------------------------*
  METHOD hotspot_click.
    PERFORM event_hotspot_click
                  USING e_row_id
                        e_column_id.
  ENDMETHOD.                    "hotspot_click
ENDCLASS.                    "lcl_evento_alv IMPLEMENTATION

*----------------------------------------------------------------------*
* Objetos                                                              *
*----------------------------------------------------------------------*
DATA:
  obj_evt  TYPE REF TO lcl_evento_alv.

*----------------------------------------------------------------------*
* Tela de seleção                                                      *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001. " Cliente
SELECT-OPTIONS: so_kunnr FOR ygedar_doc-kunnr               , " @A0@Cliente
                so_typed FOR ygedar_doc-typed               . " @AR@Tipo do Documento
SELECTION-SCREEN END OF BLOCK b1                            .

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002. " Versão
PARAMETERS: ch_vers AS CHECKBOX                             . " @4B@Todas versões
SELECTION-SCREEN END OF BLOCK b2                            .

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003. " Status
PARAMETERS: ch_verd AS CHECKBOX DEFAULT 'X'                 , " @5B@Verde
            ch_amar AS CHECKBOX DEFAULT 'X'                 , " @5D@Amarelo
            ch_verm AS CHECKBOX DEFAULT 'X'                 . " @5C@Vermelho
SELECTION-SCREEN END OF BLOCK b3                            .

SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-004. " Prazo
PARAMETERS: ch_venc AS CHECKBOX                             , " @DF@Vencido
            ch_nven AS CHECKBOX DEFAULT 'X'                 . " @5Y@A vencer
SELECTION-SCREEN END OF BLOCK b4                            .

SELECTION-SCREEN BEGIN OF BLOCK b5 WITH FRAME TITLE text-012. " Cadastrados com erro
PARAMETERS: ch_bloq AS CHECKBOX                             , " @06@Bloqueado
            ch_desb AS CHECKBOX DEFAULT 'X'                 . " @07@Desbloqueado
SELECTION-SCREEN END OF BLOCK b5                            .
*----------------------------------------------------------------------*
* Inicio do processamento                                              *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM: f_carregar_doctos_cliente,
           f_montar_alv_doctos      ,
           f_exibir_alv_doctos      ,
           f_montar_alv_icones      ,
           f_exibir_alv_icones      ,
           f_carregar_tela          .

*&---------------------------------------------------------------------*
*&      Form  f_carregar_doctos_cliente
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_carregar_doctos_cliente.
  DATA: vl_versao TYPE ygedar_doc-version.

  FREE: tl_tipo, tl_alv_docto.

* Seleciona os tipos de documento que o cliente possui
  SELECT kunnr typed
  FROM ygedar_doc
  INTO TABLE tl_tipo
   WHERE kunnr IN so_kunnr
     AND typed IN so_typed.

  DELETE ADJACENT DUPLICATES FROM tl_tipo.

* Seleciona todas versões
  IF ch_vers IS NOT INITIAL.
    SELECT * FROM ygedar_doc
      INTO TABLE tl_documentos
      FOR ALL ENTRIES IN tl_tipo
      WHERE kunnr = tl_tipo-kunnr
        AND typed = tl_tipo-typed.

  ELSE.
*   Exibe só as maiores versões de cada documento
    LOOP AT tl_tipo INTO wl_tipo.
      SELECT MAX( version )
       FROM ygedar_doc
       INTO (vl_versao)
       WHERE kunnr = wl_tipo-kunnr
         AND typed = wl_tipo-typed.

      SELECT * FROM ygedar_doc
        APPENDING TABLE tl_documentos
        WHERE kunnr     = wl_tipo-kunnr
          AND typed     = wl_tipo-typed
          AND version   = vl_versao.
    ENDLOOP.
  ENDIF.

  IF ch_vers IS INITIAL.
* Cadastrados com erro
    IF ch_bloq IS NOT INITIAL.
      DELETE tl_documentos WHERE bloqueado NE 'X'.
    ELSEIF ch_desb IS NOT INITIAL.
      DELETE tl_documentos WHERE bloqueado = 'X'.
    ENDIF.
  ENDIF.

  LOOP AT tl_documentos INTO wl_documentos.
    MOVE-CORRESPONDING wl_documentos TO wl_alv_docto.

    IF wl_documentos-bloqueado = 'X'.
      wl_alv_docto-bloqueado = c_icone_bloquear.
    ELSE.
      wl_alv_docto-bloqueado = c_icone_desbloq.
    ENDIF.

    APPEND wl_alv_docto TO tl_alv_docto.
  ENDLOOP.

  DESCRIBE TABLE tl_alv_docto.

  IF sy-tfill = 0.
    MESSAGE 'Não há registros para o cliente informado'(005) TYPE 'I'.
    EXIT.
  ENDIF.

ENDFORM.                    "f_carregar_doctos_cliente

*&---------------------------------------------------------------------*
*&      Form  f_montar_alv_doctos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_montar_alv_doctos.

* Verifica se o documento está no prazo e altera o ícone de Status
  DATA:
    tl_param TYPE STANDARD TABLE OF ygedar_param,
    wl_param LIKE LINE OF tl_param              .

  DATA:
    vl_qtd_dias TYPE i.

  SELECT * FROM ygedar_param
   INTO TABLE tl_param
   FOR ALL ENTRIES IN tl_alv_docto
   WHERE typed = tl_alv_docto-typed.

  LOOP AT tl_alv_docto INTO wl_alv_docto.
    DATA: vl_indice TYPE sy-tabix.
    vl_indice = sy-tabix.

    CLEAR wl_param.
    READ TABLE tl_param
    INTO wl_param
    WITH KEY typed = wl_alv_docto-typed.

    CHECK sy-subrc EQ 0.

    SHIFT wl_alv_docto-kunnr LEFT DELETING LEADING '0'.
    wl_alv_docto-desctype = wl_param-descrip.

* Diferença entre a data atual com o prazo de validade
* informado pelo usuário (Válido Até)
    CALL FUNCTION 'HR_99S_INTERVAL_BETWEEN_DATES'
      EXPORTING
        begda = sy-datum
        endda = wl_alv_docto-validto
      IMPORTING
        days  = vl_qtd_dias.

    IF vl_qtd_dias >= wl_param-green  AND vl_qtd_dias > wl_param-yellow.
      wl_alv_docto-status = c_icone_verde.
    ELSEIF vl_qtd_dias < wl_param-green
       AND vl_qtd_dias >= wl_param-yellow
        OR vl_qtd_dias > wl_param-red.
      wl_alv_docto-status = c_icone_amarelo.
    ELSEIF  vl_qtd_dias <= wl_param-red.
      wl_alv_docto-status = c_icone_vermelho.
      wl_alv_docto-prazo = c_vencido.
    ENDIF.

* Validação do prazo de validade
    IF sy-datum > wl_alv_docto-validto.
      wl_alv_docto-prazo = c_vencido.
    ELSE.
      wl_alv_docto-prazo = c_a_vencer.
    ENDIF.

    wl_alv_docto-dias       = vl_qtd_dias.
    wl_alv_docto-visualizar = c_icone_visualiz.
    MODIFY tl_alv_docto FROM wl_alv_docto INDEX vl_indice.
  ENDLOOP. " LOOP AT tl_alv_docto INTO wl_alv_docto.

  SORT tl_alv_docto BY kunnr typed version ASCENDING.
  PERFORM f_validar_opcoes_selecionadas.

  PERFORM f_montar_fieldcatalog
   TABLES tl_fcat_doc
    USING wl_fcat_doc c_alv_documentos.

ENDFORM.                    "f_montar_alv_doctos

*&---------------------------------------------------------------------*
*&      Form  f_montar_alv_icones
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_montar_alv_icones.
  wl_dsc_icon-icone   = c_vencido.
  wl_dsc_icon-descrip = 'Prazo vencido'(007).
  APPEND wl_dsc_icon TO tl_dsc_icon.

  wl_dsc_icon-icone   = c_a_vencer.
  wl_dsc_icon-descrip = 'Prazo a vencer'(008).
  APPEND wl_dsc_icon TO tl_dsc_icon.

  wl_dsc_icon-icone   = c_icone_verde.
  wl_dsc_icon-descrip = 'OK'(009).
  APPEND wl_dsc_icon TO tl_dsc_icon.

  wl_dsc_icon-icone   = c_icone_amarelo.
  wl_dsc_icon-descrip = 'Alerta'(010).
  APPEND wl_dsc_icon TO tl_dsc_icon.

  wl_dsc_icon-icone   = c_icone_vermelho.
  wl_dsc_icon-descrip = 'Crítico'(011).
  APPEND wl_dsc_icon TO tl_dsc_icon.

  wl_dsc_icon-icone   = c_icone_bloquear.
  wl_dsc_icon-descrip = 'Documento bloqueado por erro na inserção'(013).
  APPEND wl_dsc_icon TO tl_dsc_icon.

  wl_dsc_icon-icone   = c_icone_desbloq.
  wl_dsc_icon-descrip = 'Documento sem status de bloqueio'(014).
  APPEND wl_dsc_icon TO tl_dsc_icon.

  PERFORM f_montar_fieldcatalog
   TABLES tl_fcat_icon
    USING wl_fcat_icon c_alv_icones.

ENDFORM.                    "f_montar_alv_icones

*&---------------------------------------------------------------------*
*&      Form  f_validar_opcoes_selecionadas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_validar_opcoes_selecionadas.
  CHECK ch_vers IS INITIAL.

* If porco
  IF ch_verd IS NOT INITIAL
   AND ch_amar IS INITIAL
   AND ch_verm IS INITIAL.

    DELETE tl_alv_docto WHERE status NE c_icone_verde.

  ELSEIF ch_verd IS INITIAL
     AND ch_amar IS NOT INITIAL
     AND ch_verm IS INITIAL.

    DELETE tl_alv_docto WHERE status NE c_icone_amarelo.

  ELSEIF ch_verd IS INITIAL
       AND ch_amar IS INITIAL
       AND ch_verm IS NOT INITIAL.

    DELETE tl_alv_docto WHERE status NE c_icone_vermelho.

  ELSEIF ch_verd IS INITIAL
       AND ch_amar IS NOT INITIAL
       AND ch_verm IS NOT INITIAL.

    DELETE tl_alv_docto WHERE status NE c_icone_amarelo
                          AND status NE c_icone_vermelho.

  ELSEIF ch_verd IS NOT INITIAL
       AND ch_amar IS INITIAL
       AND ch_verm IS NOT INITIAL.

    DELETE tl_alv_docto WHERE status NE c_icone_verde
                          AND status NE c_icone_vermelho.

  ELSEIF ch_verd IS NOT INITIAL
       AND ch_amar IS NOT INITIAL
       AND ch_verm IS INITIAL.

    DELETE tl_alv_docto WHERE status NE c_icone_verde
                          AND status NE c_icone_amarelo.
  ENDIF.

* Prazo
  IF ch_venc IS NOT INITIAL
     AND ch_nven IS INITIAL.
    DELETE tl_alv_docto WHERE prazo NE c_vencido.
  ELSEIF ch_nven IS NOT INITIAL
    AND ch_venc IS INITIAL.
    DELETE tl_alv_docto WHERE prazo NE c_a_vencer.
  ENDIF.

  IF tl_alv_docto IS INITIAL.
    MESSAGE 'Não há registros para o cliente informado'(005) TYPE 'I'.
  ENDIF.

ENDFORM.                    "f_validar_opcoes_selecionadas

*&---------------------------------------------------------------------*
*&      Form  f_montar_fieldcatalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TL_FCAT  text
*      -->P_WL_FCAT  text
*      -->P_TABELA   text
*      -->P_HOTSPOT  text
*----------------------------------------------------------------------*
FORM f_montar_fieldcatalog
  TABLES p_tl_fcat TYPE lvc_t_fcat
   USING p_wl_fcat TYPE lvc_s_fcat
         p_tabela  TYPE ddobjname.

  DATA: tl_campos TYPE STANDARD TABLE OF dd03p,
        wl_campos LIKE LINE OF tl_campos      .

  DATA: vl_campo       TYPE rollname    ,
        vl_nome_coluna TYPE dd04t-scrtext_s.

* Obtém o nome dos campos da estrutura da SE11
  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name          = p_tabela
      state         = c_versao_ativa
    TABLES
      dd03p_tab     = tl_campos
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  LOOP AT tl_campos INTO wl_campos.
    vl_campo = wl_campos-rollname.

* Seleciona a descrição do elemento de dados
    SELECT SINGLE scrtext_s
    FROM  dd04t
    INTO (vl_nome_coluna)
     WHERE rollname  = vl_campo
      AND ddlanguage = c_pt_br
      AND as4local   = c_versao_ativa.

* Verifica quais se algum dos campos deve ter hotspot
    CASE wl_campos-fieldname.
      WHEN c_hotspot_visual.
        p_wl_fcat-hotspot = 'X'.
        p_wl_fcat-icon    = 'X'.
      WHEN c_hotspot_kunnr.
        p_wl_fcat-hotspot = 'X'.
        p_wl_fcat-icon    = 'X'.
        p_wl_fcat-key     = 'X'.
      WHEN c_status OR c_prazo OR c_icone OR c_bloqueado.
        p_wl_fcat-icon    = 'X'.
      WHEN c_versao.
        p_wl_fcat-lzero   = 'X'.
    ENDCASE.

    p_wl_fcat-fieldname  = wl_campos-fieldname.
    p_wl_fcat-coltext    = vl_nome_coluna     .
    p_wl_fcat-outputlen  = wl_campos-outputlen.

    APPEND p_wl_fcat TO p_tl_fcat             .
    CLEAR p_wl_fcat.
  ENDLOOP.
ENDFORM.                    "f_montar_fieldcatalog

*&---------------------------------------------------------------------*
*&      Form  f_exibir_alv_doctos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_exibir_alv_doctos.
* Verifica se o container ainda não foi inicializado
  CHECK obj_cont_doc IS INITIAL.

  CREATE OBJECT obj_cont_doc
    EXPORTING
      container_name              = c_cont_doctos " CONT_DOC_CLI
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

* Cria uma instância da classe cl_gui_alv_grid no container CONT_DOC_CLI
* declarado no layout da tela 1000
  CREATE OBJECT obj_alv_docto
    EXPORTING
      i_parent          = obj_cont_doc
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.

* Atribui os métodos da classe local lcl_evento_alv à do ALV
  CREATE OBJECT obj_evt.
  SET HANDLER obj_evt->hotspot_click
  FOR obj_alv_docto.

* Layout do relatório ALV
  wl_alv_layout-cwidth_opt = 'X'.
  wl_alv_layout-zebra      = 'X'.

  CALL METHOD obj_alv_docto->set_table_for_first_display
    EXPORTING
      is_layout                     = wl_alv_layout
    CHANGING
      it_outtab                     = tl_alv_docto
      it_fieldcatalog               = tl_fcat_doc
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
ENDFORM.                    "f_exibir_alv_doctos

*&---------------------------------------------------------------------*
*&      Form  f_exibir_alv_icones
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_exibir_alv_icones.
* Verifica se o container ainda não foi inicializado
  CHECK obj_cont_icon IS INITIAL.

  CREATE OBJECT obj_cont_icon
    EXPORTING
      container_name              = c_cont_dsc_icn " CONT_DSC_ICN
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

* Cria uma instância da classe cl_gui_alv_grid no container CONT_DSC_ICN
* declarado no layout da tela 1001
  CREATE OBJECT obj_alv_icon
    EXPORTING
      i_parent          = obj_cont_icon
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.

* Layout do relatório ALV
  wl_alv_layout-cwidth_opt = 'X'.
  wl_alv_layout-zebra      = 'X'.
  wl_alv_layout-no_toolbar = 'X'. " Exclui os botões da barra de tarefas do ALV

  CALL METHOD obj_alv_icon->set_table_for_first_display
    EXPORTING
      is_layout                     = wl_alv_layout
    CHANGING
      it_outtab                     = tl_dsc_icon
      it_fieldcatalog               = tl_fcat_icon
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
ENDFORM.                    "f_exibir_alv_icones

*&---------------------------------------------------------------------*
*&      Form  f_carregar_tela
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_carregar_tela.
* Carregar ALV - GED Cadastro de Clientes
  IF tl_alv_docto IS NOT INITIAL.
    CALL SCREEN 1001.
  ENDIF.
ENDFORM.                    "f_carregar_tela

*----------------------------------------------------------------------*
* MODULE status_1001 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE status_1001 OUTPUT.
  SET PF-STATUS 'S1000'.

* Status dos documentos do cadastro de clientes
  SET TITLEBAR 'T1000'.
ENDMODULE.                                           "status_1001 OUTPUT

*----------------------------------------------------------------------*
* MODULE USER_COMMAND_1001 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE user_command_1001 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'LEAVE' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE. "USER_COMMAND_1001 INPUT

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

  READ TABLE tl_alv_docto
  INTO wl_alv_docto
  INDEX p_row-index.

  CASE p_column.
    WHEN c_hotspot_visual.
      PERFORM f_visualizar_arquivo_dms
        USING wl_alv_docto-kunnr
              wl_alv_docto-typed
              wl_alv_docto-version.
    WHEN c_hotspot_kunnr.
      PERFORM f_carregar_xd03
        USING wl_alv_docto-kunnr.
  ENDCASE.
ENDFORM.                    "event_hotspot_click

*&---------------------------------------------------------------------*
*&      Form  f_visualizar_arquivo_dms
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_KUNNR    text
*      -->P_TYPED    text
*      -->P_VERS     text
*----------------------------------------------------------------------*
FORM f_visualizar_arquivo_dms
  USING p_kunnr TYPE yged_ar_1004_alv-kunnr
        p_typed TYPE yged_ar_1004_alv-typed
        p_vers  TYPE yged_ar_1004_alv-version.

  DATA:
   vl_nro_doc    TYPE draw-doknr ,
   vl_ver_doc    TYPE n          ,
   vl_versao     TYPE draw-dokvr ,
   vl_arquivo    TYPE draw-filep ,
   vl_url_dms    TYPE mcdok-url  ,
   vl_visualizar TYPE c LENGTH 01.

* Completa o código do cliente com zeros à esquerda
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_kunnr
    IMPORTING
      output = p_kunnr.

  WRITE vl_ver_doc TO vl_versao.

* Completa o código da versão com zeros à esquerda
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = vl_versao
    IMPORTING
      output = vl_versao.

  SHIFT p_kunnr LEFT DELETING LEADING '0'.

  CONCATENATE p_kunnr
              p_typed
  INTO vl_nro_doc.

  CALL FUNCTION 'CVAPI_DOC_VIEW'
    EXPORTING
      pf_dokar         = c_contas_receber " YAR
      pf_doknr         = vl_nro_doc
      pf_dokvr         = vl_versao
      pf_doktl         = c_doc_parcial                      " 0000
    IMPORTING
      pfx_file         = vl_arquivo
      pfx_url          = vl_url_dms
      pfx_view_inplace = vl_visualizar
    EXCEPTIONS
      error            = 1
      not_found        = 2
      no_auth          = 3
      no_original      = 4
      OTHERS           = 5.

  IF vl_arquivo IS INITIAL.
    MESSAGE 'Documento não cadastrado'(006) TYPE 'I'.
  ENDIF.

ENDFORM.                    "f_visualizar_arquivo_dms

*&---------------------------------------------------------------------*
*&      Form  f_carregar_xd03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CLIENTE  text
*----------------------------------------------------------------------*
FORM f_carregar_xd03
 USING p_cliente TYPE yged_ar_1004_alv-kunnr.

* Código para o evento foi inserido no Status GUI S1000 com o nome 'PICK'
  IF p_cliente IS NOT INITIAL.
    SET PARAMETER ID 'KUN' FIELD p_cliente.
    CALL TRANSACTION 'XD03' AND SKIP FIRST SCREEN.
  ENDIF.
ENDFORM.                    "f_carregar_xd03