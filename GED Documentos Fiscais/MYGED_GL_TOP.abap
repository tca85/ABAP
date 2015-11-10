*&---------------------------------------------------------------------*
*& Include MYGED_GL_TOP
*&---------------------------------------------------------------------*

PROGRAM sapmyged_gl.

TABLES: ygedgl_doc      , " GED - Documentos Fiscais - Versão do Documento
        rlgrap          , " File local para Upload ou Download
        yged_gl_1000    , " GED - Documentos Fiscais - Tela 1000
        yged_gl_1001_alv, " GED - Doctos Fiscais - ALV - Doctos Obrigatórios
        kna1            . " Mestre de clientes

*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_tipo              ,
   typed TYPE ygedgl_doc-typedoc,
  END OF ty_tipo                ,

  BEGIN OF ty_botoes            , " Botões da tela de seleção
   tpdoc TYPE c LENGTH 01       , " Tipo de documento
   novo  TYPE c LENGTH 01       , " Limpar campos
   file  TYPE c LENGTH 01       , " Importou o arquivo
   salv  TYPE c LENGTH 01       , " Salvar
  END OF ty_botoes              .

*----------------------------------------------------------------------*
* Tabelas internas                                                     *
*----------------------------------------------------------------------*
DATA:
  t_alv_docto  TYPE STANDARD TABLE OF yged_gl_1000_alv         ,
  t_alv_obrig  TYPE STANDARD TABLE OF yged_gl_1001_alv         ,
  t_documentos TYPE STANDARD TABLE OF ygedgl_doc               ,
  t_tipo       TYPE STANDARD TABLE OF ty_tipo                  ,
  t_botoes     TYPE STANDARD TABLE OF ty_botoes                ,
  t_extensao   TYPE STANDARD TABLE OF dd07v WITH KEY domvalue_l,
  t_fcat_doc   TYPE lvc_t_fcat                                 ,
  t_fcat_stat  TYPE lvc_t_fcat                                 .

*----------------------------------------------------------------------*
* Work Areas                                                           *
*----------------------------------------------------------------------*
DATA:
  w_alv_docto  LIKE LINE OF t_alv_docto ,
  w_alv_obrig  LIKE LINE OF t_alv_obrig ,
  w_documentos LIKE LINE OF t_documentos,
  w_tipo       LIKE LINE OF t_tipo      ,
  w_botoes     LIKE LINE OF t_botoes    ,
  w_extensao   TYPE dd07v               ,
  w_alv_layout TYPE lvc_s_layo          ,
  w_fcat_doc   TYPE lvc_s_fcat          ,
  w_fcat_stat  TYPE lvc_s_fcat          .

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
DATA:
  ok_code    TYPE sy-ucomm   ,
  v_resp     TYPE c LENGTH 01,
  v_arq_comp TYPE dsvasdocid ,
  v_arquivo  TYPE dsvasdocid ,
  v_caminho  TYPE dsvasdocid ,
  v_extensao TYPE dsvasdocid .

* Inicialmente não mostra os doctos obrigatórios
DATA:
  v_tela     TYPE sy-dynnr VALUE '1003'.

*----------------------------------------------------------------------*
* Objetos                                                              *
*----------------------------------------------------------------------*
DATA:
  obj_cont_doc  TYPE REF TO cl_gui_custom_container,
  obj_cont_stat TYPE REF TO cl_gui_custom_container,
  obj_alv_docto TYPE REF TO cl_gui_alv_grid        ,
  obj_alv_stat  TYPE REF TO cl_gui_alv_grid        .

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
CONSTANTS:
  c_contas_receber    TYPE tdwa-dokar    VALUE 'YAR'             , " Tipo de documento
  c_objeto_sap        TYPE tdwo-dokob    VALUE 'KNA1'            , " Objeto SAP ligado
  c_liberado          TYPE tdws-dokst    VALUE 'FR'              , " Status documento
  c_cta_receber       TYPE t024l-labor   VALUE 'FAR'             , " Financeiro Contas a Receber
  c_tp_cta_receber    TYPE draw-dokar    VALUE 'YAP'             , " Tipo de documento
  c_doc_parcial       TYPE draw-doktl    VALUE '000'             , " Documento parcial
  c_alv_doctos        TYPE scrfname      VALUE 'CONT_DOC_CLI'    ,
  c_alv_doctos_obrig  TYPE scrfname      VALUE 'CONT_DOC_OBRIG'  ,
  c_desabilitar_campo TYPE c LENGTH 01   VALUE '0'               ,
  c_habilitar_campo   TYPE c LENGTH 01   VALUE '1'               ,
  c_sim               TYPE c LENGTH 01   VALUE 1                 ,
  c_arquivado         TYPE c LENGTH 20   VALUE 'Arquivado'       ,
  c_categ_arquiv      TYPE c LENGTH 10   VALUE 'ACHE_AR'         ,
  c_icone_verde       TYPE c LENGTH 04   VALUE '@08@'            ,
  c_icone_amarelo     TYPE c LENGTH 04   VALUE '@09@'            ,
  c_icone_vermelho    TYPE c LENGTH 04   VALUE '@0A@'            ,
  c_icone_visualiz    TYPE c LENGTH 04   VALUE '@10@'            ,
  c_icone_bloquear    TYPE c LENGTH 04   VALUE '@06@'            ,
  c_icone_desbloq     TYPE c LENGTH 04   VALUE '@07@'            ,
  c_hotspot_visual    TYPE c LENGTH 10   VALUE 'VISUALIZAR'      ,
  c_hotspot_bloq      TYPE c LENGTH 08   VALUE 'BLOQUEAR'        ,
  c_versao_ativa      TYPE ddobjstate    VALUE 'A'               ,
  c_alv_documentos    TYPE ddobjname     VALUE 'YGED_GL_1000_ALV',
  c_alv_doc_obrig     TYPE ddobjname     VALUE 'YGED_GL_1001_ALV',
  c_sub_descomprimir  TYPE sy-dynnr      VALUE '1001'            ,
  c_sub_comprimir     TYPE sy-dynnr      VALUE '1003'            ,
  c_sub_alv_obrig     TYPE sy-dynnr      VALUE '1002'            ,
  c_erro_bapi         TYPE bapiret2-type VALUE 'E'               ,
  c_pt_br             TYPE t002-laiso    VALUE 'PT'              .