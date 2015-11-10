*&---------------------------------------------------------------------*
*& Include MYBR_GNRE_TOP
*&---------------------------------------------------------------------*

PROGRAM sapmybr_gnre.

TABLES: ybr_gnre_1000. " Tela de seleção / Campos ALV
*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_j_1bnfdoc               ,
   bukrs   TYPE j_1bnfdoc-bukrs       ,
   branch  TYPE j_1bnfdoc-branch      ,
   nfenum  TYPE j_1bnfdoc-nfenum      ,
   series  TYPE j_1bnfdoc-series      ,
   docnum  TYPE j_1bnfdoc-docnum      ,
   docdat  TYPE j_1bnfdoc-docdat      ,
   parid   TYPE j_1bnfdoc-parid       ,
  END OF ty_j_1bnfdoc                 ,

  BEGIN OF ty_j_1bnfstx               ,
   docnum  TYPE j_1bnfstx-docnum      ,
   taxtyp  TYPE j_1bnfstx-taxtyp      ,
   taxval  TYPE j_1bnfstx-taxval      ,
  END OF ty_j_1bnfstx                 ,

  BEGIN OF ty_j_1bnfe_active          ,
   docnum  TYPE j_1bnfe_active-docnum ,
   regio   TYPE j_1bnfe_active-regio  ,
   nfyear  TYPE j_1bnfe_active-nfyear ,
   nfmonth TYPE j_1bnfe_active-nfmonth,
   stcd1   TYPE j_1bnfe_active-stcd1  ,
   model   TYPE j_1bnfe_active-model  ,
   serie   TYPE j_1bnfe_active-serie  ,
   nfnum9  TYPE j_1bnfe_active-nfnum9 ,
   docnum9 TYPE j_1bnfe_active-docnum9,
   cdv     TYPE j_1bnfe_active-cdv    ,
  END OF ty_j_1bnfe_active            .

*----------------------------------------------------------------------*
* Tabelas internas                                                     *
*----------------------------------------------------------------------*
DATA:
  tl_alv_gnre       TYPE STANDARD TABLE OF ybr_gnre_1000    ,
  tl_gnre           TYPE STANDARD TABLE OF ybr_gnre         ,
  tl_parametros     TYPE STANDARD TABLE OF ybr_gnre_param   ,
  tl_j_1bnfdoc      TYPE STANDARD TABLE OF ty_j_1bnfdoc     ,
  tl_j_1bnfstx      TYPE STANDARD TABLE OF ty_j_1bnfstx     ,
  tl_j_1bnfe_active TYPE STANDARD TABLE OF ty_j_1bnfe_active,
  tl_fcat_gnre      TYPE lvc_t_fcat                         .

*----------------------------------------------------------------------*
* Work Areas                                                           *
*----------------------------------------------------------------------*
DATA:
  wl_alv_gnre       LIKE LINE OF tl_alv_gnre      ,
  wl_gnre           LIKE LINE OF tl_gnre          ,
  wl_parametros     LIKE LINE OF tl_parametros    ,
  wl_alv_layout     TYPE lvc_s_layo               ,
  wl_j_1bnfdoc      LIKE LINE OF tl_j_1bnfdoc     ,
  wl_j_1bnfstx      LIKE LINE OF tl_j_1bnfstx     ,
  wl_j_1bnfe_active LIKE LINE OF tl_j_1bnfe_active,
  wl_fcat_gnre      TYPE lvc_s_fcat               .

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
DATA:
  vl_qtd_reg       TYPE i                   ,
  vl_id_gnre       TYPE string              ,
  vl_id_arquivo    TYPE i                   ,
  vl_erro          TYPE c LENGTH 01         ,
  vl_bloq_campo    TYPE c LENGTH 01         ,
  ok_code          TYPE sy-ucomm            ,
  qtd_doc_obrig    TYPE c LENGTH 20         ,
  vl_dt_ult_exec   TYPE ybr_gnre_param-valor,
  vl_hora_ult_exec TYPE ybr_gnre_param-valor,
  vl_tp_condicao   TYPE ybr_gnre_param-valor,
  vl_uf_st_gnre    TYPE ybr_gnre_param-valor.

*----------------------------------------------------------------------*
* Objetos                                                              *
*----------------------------------------------------------------------*
DATA:
  obj_cont_gnre TYPE REF TO cl_gui_custom_container,
  obj_alv_gnre  TYPE REF TO cl_gui_alv_grid        .

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
CONSTANTS:
  c_cont_alv_gnre  TYPE scrfname              VALUE 'CONT_ALV_GNRE',
  c_alv_gnre       TYPE ddobjname             VALUE 'YBR_GNRE_1000',
  c_btn_deletar    TYPE lvc_s_col             VALUE 'DELETAR'      ,
  c_icone_deletar  TYPE c LENGTH 04           VALUE '@11@'         ,
  c_versao_ativa   TYPE ddobjstate            VALUE 'A'            ,
  c_pt_br          TYPE t002-laiso            VALUE 'PT'           ,
  c_icms_st        TYPE j_1baj-taxtyp         VALUE 'ICS3'         , " ICMS Sub.Trib. de SD
  c_qtd_limite_nf  TYPE i                     VALUE 50             ,
  c_local_negocios TYPE j_1bnfe_active-partyp VALUE 'B'            ,
  c_cliente        TYPE j_1bnfe_active-partyp VALUE 'C'            ,
  c_hotspot_nfe    TYPE c LENGTH 03           VALUE 'NFE'          ,
  c_dt_ult_exec    TYPE c LENGTH 10           VALUE 'DT_LST_EXE'   , " Data da última Execução
  c_hr_lst_exec    TYPE c LENGTH 10           VALUE 'HR_LST_EXE'   , " Hora da última Execução
  c_tp_cnd         TYPE c LENGTH 06           VALUE 'TP_CND'       , " Tipo da Condição
  c_uf_st          TYPE c LENGTH 05           VALUE 'UF_ST'        . " UF ST GNRE