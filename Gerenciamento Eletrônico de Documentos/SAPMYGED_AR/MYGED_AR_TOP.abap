*&---------------------------------------------------------------------*
*&  Include           MYGED_AR_TOP
*&---------------------------------------------------------------------*
PROGRAM sapmyged_ar.

TABLES: ygedar_doc      , " GED Cadastro de Clientes - Documentos
        rlgrap          , " File local para Upload ou Download
        yged_ar_1000    , " Textboxes da tela 1000
        yged_ar_1001_alv, " Campos do ALV de documentos obrigatórios
        kna1            . " Mestre de clientes

*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_tipo            ,
   typed TYPE ygedar_doc-typed,
  END OF ty_tipo              .

*----------------------------------------------------------------------*
* Tabelas internas                                                     *
*----------------------------------------------------------------------*
DATA:
  tl_alv_docto  TYPE STANDARD TABLE OF yged_ar_1000_alv         ,
  tl_alv_obrig  TYPE STANDARD TABLE OF yged_ar_1001_alv         ,
  tl_documentos TYPE STANDARD TABLE OF ygedar_doc               ,
  tl_tipo       TYPE STANDARD TABLE OF ty_tipo                  ,
  tl_extensao   TYPE STANDARD TABLE OF dd07v WITH KEY domvalue_l,
  tl_fcat_doc   TYPE lvc_t_fcat                                 ,
  tl_fcat_stat  TYPE lvc_t_fcat                                 .

*----------------------------------------------------------------------*
* Work Areas                                                           *
*----------------------------------------------------------------------*
DATA:
  wl_alv_docto  LIKE LINE OF tl_alv_docto ,
  wl_alv_obrig  LIKE LINE OF tl_alv_obrig ,
  wl_documentos LIKE LINE OF tl_documentos,
  wl_tipo       LIKE LINE OF tl_tipo      ,
  wl_extensao   TYPE dd07v                ,
  wl_alv_layout TYPE lvc_s_layo           ,
  wl_fcat_doc   TYPE lvc_s_fcat           ,
  wl_fcat_stat  TYPE lvc_s_fcat           .

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
DATA:
  ok_code     TYPE sy-ucomm   ,
  vl_resp     TYPE c LENGTH 01,
  vl_arq_comp TYPE dsvasdocid ,
  vl_arquivo  TYPE dsvasdocid ,
  vl_caminho  TYPE dsvasdocid ,
  vl_extensao TYPE dsvasdocid .

* Inicialmente não mostra os doctos obrigatórios
DATA:
  vl_tela     TYPE sy-dynnr VALUE '1003'.

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
  c_contas_receber   TYPE tdwa-dokar    VALUE 'YAR'             , " Tipo de documento
  c_objeto_sap       TYPE tdwo-dokob    VALUE 'KNA1'            , " Objeto SAP ligado
  c_liberado         TYPE tdws-dokst    VALUE 'FR'              , " Status documento
  c_cta_receber      TYPE t024l-labor   VALUE 'FAR'             , " Financeiro Contas a Receber
  c_tp_cta_receber   TYPE draw-dokar    VALUE 'YAP'             , " Tipo de documento
  c_doc_parcial      TYPE draw-doktl    VALUE '0000'            , " Documento parcial
  c_alv_doctos       TYPE scrfname      VALUE 'CONT_DOC_CLI'    ,
  c_alv_doctos_obrig TYPE scrfname      VALUE 'CONT_DOC_OBRIG'  ,
  c_sim              TYPE c LENGTH 01   VALUE 1                 ,
  c_arquivado        TYPE c LENGTH 20   VALUE 'Arquivado'       ,
  c_categ_arquiv     TYPE c LENGTH 10   VALUE 'ACHE_AR'         ,
  c_icone_verde      TYPE c LENGTH 04   VALUE '@08@'            ,
  c_icone_amarelo    TYPE c LENGTH 04   VALUE '@09@'            ,
  c_icone_vermelho   TYPE c LENGTH 04   VALUE '@0A@'            ,
  c_icone_visualiz   TYPE c LENGTH 04   VALUE '@10@'            ,
  c_icone_bloquear   TYPE c LENGTH 04   VALUE '@06@'            ,
  c_icone_desbloq    TYPE c LENGTH 04   VALUE '@07@'            ,
  c_hotspot_visual   TYPE c LENGTH 10   VALUE 'VISUALIZAR'      ,
  c_hotspot_bloq     TYPE c LENGTH 08   VALUE 'BLOQUEAR'        ,
  c_versao_ativa     TYPE ddobjstate    VALUE 'A'               ,
  c_alv_documentos   TYPE ddobjname     VALUE 'YGED_AR_1000_ALV',
  c_alv_doc_obrig    TYPE ddobjname     VALUE 'YGED_AR_1001_ALV',
  c_sub_descomprimir TYPE sy-dynnr      VALUE '1001'            ,
  c_sub_comprimir    TYPE sy-dynnr      VALUE '1003'            ,
  c_sub_alv_obrig    TYPE sy-dynnr      VALUE '1002'            ,
  c_erro_bapi        TYPE bapiret2-type VALUE 'E'               ,
  c_pt_br            TYPE t002-laiso    VALUE 'PT'              .