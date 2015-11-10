************************************************************************
* PROGRAMA  : YFI0010
* OBJETIVOS : SD - PIS E COFINS - ALV (Abap List View)
************************************************************************
* AUTOR   : Uderson Fermino                          DATA: 15/09/2011
************************************************************************
REPORT YFI0010 NO STANDARD PAGE HEADING
                MESSAGE-ID zmsg.
*
************************************************************************
* DECLARAÇÃO DE TABELAS
************************************************************************

TABLES: j_1bnfdoc,
        j_1bnflin,
        t023t,
        j_1bnfstx,
        kna1.

  DATA: ls_j1baj TYPE j_1baj.
*
************************************************************************
* DECLARAÇÃO DE VARIÁVEIS, CONSTANTES, TABELAS PARA ALV
************************************************************************
TYPE-POOLS: slis, kkblo.
*
* Definições para ÍCONE
*INCLUDE <icon>.
*
************************************************************************
* DECLARAÇÃO DE TABELAS INTERNAS / ESTRUTURAS PARA ALV
************************************************************************
DATA:  it_alv_fieldcat    TYPE slis_t_fieldcat_alv,
       st_alv_layout      TYPE slis_layout_alv,
       it_alv_events      TYPE slis_t_event,
       it_alv_listheader  TYPE slis_t_listheader,
       st_sort_alv        TYPE slis_sortinfo_alv,        " header
       it_sort_alv        TYPE slis_t_sortinfo_alv.      " sem header

*
************************************************************************
* DECLARAÇÃO DE VARIÁVEIS / CONSTANTES PARA ALV
************************************************************************
* Variáveis...
DATA:  v_variante LIKE disvariant.
*
* Constantes...
CONSTANTS:
  c_display    LIKE sy-ucomm             VALUE 'DISPLAY',
  c_listheader TYPE slis_listheader-typ  VALUE 'S'.
*
************************************************************************
* DECLARAÇÃO DE TABELAS INTERNAS
************************************************************************

*----------------------------------------------------------------------*
*  STRUCTURES                                                          *
*----------------------------------------------------------------------*
* Nota Fiscal header structure -----------------------------------------
DATA: BEGIN OF wk_header.
        INCLUDE STRUCTURE j_1bnfdoc.
DATA: END OF wk_header.

* Nota Fiscal header structure - add. segment --------------------------
DATA: BEGIN OF wk_header_add.
        INCLUDE STRUCTURE j_1bindoc.
DATA: END OF wk_header_add.

* Nota Fiscal partner structure ----------------------------------------
DATA: BEGIN OF wk_partner OCCURS 0.
        INCLUDE STRUCTURE j_1bnfnad.
DATA: END OF wk_partner.

* Nota Fiscal item structure -------------------------------------------
DATA: BEGIN OF wk_item OCCURS 0.
        INCLUDE STRUCTURE j_1bnflin.
DATA: END OF wk_item.

* Nota Fiscal item structure - add. segment ----------------------------
DATA: BEGIN OF wk_item_add OCCURS 0.
        INCLUDE STRUCTURE j_1binlin.
DATA: END OF wk_item_add.

* Nota Fiscal item tax structure ---------------------------------------
DATA: BEGIN OF wk_item_tax OCCURS 0.
        INCLUDE STRUCTURE j_1bnfstx.
DATA: END OF wk_item_tax.

* Nota Fiscal header message structure ---------------------------------
DATA: BEGIN OF wk_header_msg OCCURS 0.
        INCLUDE STRUCTURE j_1bnfftx.
DATA: END OF wk_header_msg.

* Nota Fiscal reference to header message structure -------------------
DATA: BEGIN OF wk_refer_msg OCCURS 0.
        INCLUDE STRUCTURE j_1bnfref.
DATA: END OF wk_refer_msg.

DATA: nnf(12)  TYPE c.

DATA:
BEGIN OF it_j1bnfdoc OCCURS 0,
 docnum  TYPE j_1bnfdoc-docnum,
 nfnum   TYPE j_1bnfdoc-nfnum,
 series  TYPE j_1bnfdoc-series,
 parid   TYPE j_1bnfdoc-parid,
 bukrs   TYPE j_1bnfdoc-bukrs,
 branch  TYPE j_1bnfdoc-branch,
 pstdat  TYPE j_1bnfdoc-pstdat,
 nftype  TYPE j_1bnfdoc-nftype,
 printd  TYPE j_1bnfdoc-printd,
 cancel  TYPE j_1bnfdoc-cancel,
 direct  TYPE j_1bnfdoc-direct,
 nfenum  TYPE j_1bnfdoc-nfenum,
 model   TYPE j_1bnfdoc-model,
 inco1   TYPE j_1bnfdoc-inco1,
END OF it_j1bnfdoc,

* Tabela J1BNFLIN
BEGIN OF it_j1bnflin OCCURS 0,
 docnum TYPE j_1bnflin-docnum,
 itmnum TYPE j_1bnflin-itmnum,
 matkl  TYPE j_1bnflin-matkl,
 matnr  TYPE j_1bnflin-matnr,
 maktx  TYPE j_1bnflin-maktx,
 nbm    TYPE j_1bnflin-nbm,
 menge  TYPE j_1bnflin-menge,
 netwr   TYPE j_1bnflin-netwr,
 netpr   TYPE j_1bnflin-netpr,
 nfpri   TYPE j_1bnflin-nfpri,
 netdis  TYPE j_1bnflin-netdis,
 nfnett  TYPE j_1bnflin-nfnett,
 cfop   TYPE j_1bnflin-cfop,
 taxsi4 TYPE j_1bnflin-taxsi4,
 taxsi5 TYPE j_1bnflin-taxsi5,
END OF it_j1bnflin,

* Tabela J1BNFNAD
BEGIN OF it_j1bnfnad OCCURS 0,
 docnum TYPE j_1bnfnad-docnum,
 parvw  TYPE j_1bnfnad-parvw,
 parid  TYPE j_1bnfnad-parid,
END OF it_j1bnfnad,

* Tabela J1BNFSTX
BEGIN OF it_j1bnfstx OCCURS 0,
 docnum TYPE j_1bnfstx-docnum,
 itmnum TYPE j_1bnfstx-itmnum,
 rate   TYPE j_1bnfstx-rate,
 taxtyp TYPE j_1bnfstx-taxtyp,
 taxval TYPE j_1bnfstx-taxval,
* Purga! - alteração - Inicio
 base   TYPE  j_1bnfstx-base,
 excbas TYPE  j_1bnfstx-excbas,
 othbas TYPE  j_1bnfstx-othbas,
* Purga! - alteração - Fim

END OF it_j1bnfstx,

* Tabela J1BNFSTX2
BEGIN OF it_j1bnfstx2 OCCURS 0,
 docnum TYPE j_1bnfstx-docnum,
 itmnum TYPE j_1bnfstx-itmnum,
 rate   TYPE j_1bnfstx-rate,
 taxtyp TYPE j_1bnfstx-taxtyp,
 taxval TYPE j_1bnfstx-taxval,
* Purga! - alteração - Inicio
 base   TYPE  j_1bnfstx-base,
 excbas TYPE  j_1bnfstx-excbas,
 othbas TYPE  j_1bnfstx-othbas,
* Purga! - alteração - Fim

END OF it_j1bnfstx2,

* Tabela J1BNFSTX3
BEGIN OF it_j1bnfstx3 OCCURS 0,
 docnum TYPE j_1bnfstx-docnum,
 itmnum TYPE j_1bnfstx-itmnum,
 rate   TYPE j_1bnfstx-rate,
 taxtyp TYPE j_1bnfstx-taxtyp,
 taxval TYPE j_1bnfstx-taxval,
* Purga! - alteração - Inicio
 base   TYPE  j_1bnfstx-base,
 excbas TYPE  j_1bnfstx-excbas,
 othbas TYPE  j_1bnfstx-othbas,
* Purga! - alteração - Fim

END OF it_j1bnfstx3,

* Tabela J1BNFSTX4
BEGIN OF it_j1bnfstx4 OCCURS 0,
 docnum TYPE j_1bnfstx-docnum,
 itmnum TYPE j_1bnfstx-itmnum,
 rate   TYPE j_1bnfstx-rate,
 taxtyp TYPE j_1bnfstx-taxtyp,
 taxval TYPE j_1bnfstx-taxval,
* Purga! - alteração - Inicio
 base   TYPE  j_1bnfstx-base,
 excbas TYPE  j_1bnfstx-excbas,
 othbas TYPE  j_1bnfstx-othbas,
* Purga! - alteração - Fim

END OF it_j1bnfstx4,


* Tabela J1BNFSTX5
BEGIN OF it_j1bnfstx5 OCCURS 0,
 docnum TYPE j_1bnfstx-docnum,
 itmnum TYPE j_1bnfstx-itmnum,
 rate   TYPE j_1bnfstx-rate,
 taxtyp TYPE j_1bnfstx-taxtyp,
 taxval TYPE j_1bnfstx-taxval,
* Purga! - alteração - Inicio
 base   TYPE  j_1bnfstx-base,
 excbas TYPE  j_1bnfstx-excbas,
 othbas TYPE  j_1bnfstx-othbas,
* Purga! - alteração - Fim

END OF it_j1bnfstx5,


* Tabela V023
BEGIN OF it_t023t OCCURS 0,
 matkl   TYPE t023t-matkl,
 wgbez60 TYPE t023t-wgbez60,
END OF it_t023t,

* Tabela V023
BEGIN OF it_makt OCCURS 0,
  matnr TYPE makt-matnr,
  spras TYPE makt-spras,
  maktx TYPE makt-maktx,
  maktg TYPE makt-maktg,
END OF it_makt,

* Tabela LFA1T
BEGIN OF it_lfa1t OCCURS 0,
 lifnr   TYPE lfa1-lifnr,
 name1   TYPE lfa1-name1,
 regio   TYPE lfa1-regio,
END OF it_lfa1t,

* Tabela LFA1T
BEGIN OF it_kna1 OCCURS 0,
 kunnr   TYPE kna1-kunnr,
 name1   TYPE kna1-name1,
 regio   TYPE kna1-regio,
END OF it_kna1,

* Tabela KNA1
BEGIN OF it_lfa1 OCCURS 0,
 lifnr   TYPE lfa1-lifnr,
 name1   TYPE lfa1-name1,
 regio   TYPE lfa1-regio,
END OF it_lfa1,
* Impressão Final

BEGIN OF it_final OCCURS 0,
     docnum  TYPE j_1bnfdoc-docnum,
     nnf(12)  TYPE c,
     parid   TYPE j_1bnfdoc-parid,
     name1   TYPE kna1-name1,
     transp  TYPE kna1-name1,
     direct  TYPE j_1bnfdoc-direct,
     bukrs   TYPE j_1bnfdoc-bukrs,
     branch  TYPE j_1bnfdoc-branch,
     regio   TYPE kna1-regio,
     pstdat  TYPE j_1bnfdoc-pstdat,
     itmnum  TYPE j_1bnflin-itmnum,
     matkl   TYPE j_1bnflin-matkl,
     wgbez60 TYPE t023t-wgbez60,
     matnr   TYPE j_1bnflin-matnr,
     cfop    TYPE j_1bnflin-cfop,
     inco1   TYPE j_1bnfdoc-inco1,
     model   TYPE j_1bnfdoc-model,
     taxsi4  TYPE j_1bnflin-taxsi4,
     taxsi5  TYPE j_1bnflin-taxsi5,
     maktx   TYPE j_1bnflin-maktx,
     rate1   TYPE j_1bnfstx-rate,
     rate2   TYPE j_1bnfstx-rate,
     rate3   TYPE j_1bnfstx-rate,
     rate4   TYPE j_1bnfstx-rate,
     rate5   TYPE j_1bnfstx-rate,
     rate6   TYPE j_1bnfstx-rate,
     nbm     TYPE j_1bnflin-nbm,
     menge  TYPE j_1bnflin-menge,
     netwr   TYPE j_1bnflin-netwr,
     netpr   TYPE j_1bnflin-netpr,
     nfpri   TYPE j_1bnflin-nfpri,
     netdis  TYPE j_1bnflin-netdis,
     taxval1 TYPE j_1bnfstx-taxval,
     taxval2 TYPE j_1bnfstx-taxval,
     taxval3 TYPE j_1bnfstx-taxval,
     taxval4 TYPE j_1bnfstx-taxval,
     taxval5 TYPE j_1bnfstx-taxval,
     taxval6 TYPE j_1bnfstx-taxval,
     base1   TYPE j_1bnfstx-base,
     base2   TYPE j_1bnfstx-base,
     base3   TYPE j_1bnfstx-base,
     base4   TYPE j_1bnfstx-base,
     base5   TYPE j_1bnfstx-base,
     base6   TYPE j_1bnfstx-base,
     excbas1 TYPE j_1bnfstx-excbas,
     excbas2 TYPE j_1bnfstx-excbas,
     excbas3 TYPE j_1bnfstx-excbas,
     excbas4 TYPE j_1bnfstx-excbas,
     excbas5 TYPE j_1bnfstx-excbas,
     excbas6 TYPE j_1bnfstx-excbas,
     othbas1 TYPE j_1bnfstx-othbas,
     othbas2 TYPE j_1bnfstx-othbas,
     othbas3 TYPE j_1bnfstx-othbas,
     othbas4 TYPE j_1bnfstx-othbas,
     othbas5 TYPE j_1bnfstx-othbas,
     othbas6 TYPE j_1bnfstx-othbas,
     flag(1) TYPE c,
     netwrt  TYPE j_1binlin-netwrt,
     nfnett  TYPE j_1binlin-nfnett,
END OF it_final,

BEGIN OF it_final_aux OCCURS 0,
       docnum  TYPE j_1bnfdoc-docnum,
       nnf(12)  TYPE c,
       parid   TYPE j_1bnfdoc-parid,
       name1   TYPE kna1-name1,
       transp   TYPE kna1-name1,
       direct  TYPE j_1bnfdoc-direct,
       bukrs   TYPE j_1bnfdoc-bukrs,
       branch  TYPE j_1bnfdoc-branch,
       regio   TYPE kna1-regio,
       pstdat  TYPE j_1bnfdoc-pstdat,
       itmnum  TYPE j_1bnflin-itmnum,
       matkl   TYPE j_1bnflin-matkl,
       wgbez60 TYPE t023t-wgbez60,
       matnr   TYPE j_1bnflin-matnr,
       cfop    TYPE j_1bnflin-cfop,
       inco1   TYPE j_1bnfdoc-inco1,
       model   TYPE j_1bnfdoc-model,
       taxsi4  TYPE j_1bnflin-taxsi4,
       taxsi5  TYPE j_1bnflin-taxsi5,
       maktx   TYPE j_1bnflin-maktx,
       rate1   TYPE j_1bnfstx-rate,
       rate2   TYPE j_1bnfstx-rate,
       rate3   TYPE j_1bnfstx-rate,
       rate4   TYPE j_1bnfstx-rate,
       rate5   TYPE j_1bnfstx-rate,
       rate6   TYPE j_1bnfstx-rate,
       nbm     TYPE j_1bnflin-nbm,
       menge  TYPE j_1bnflin-menge,
       netwr   TYPE j_1bnflin-netwr,
       netpr   TYPE j_1bnflin-netpr,
       nfpri   TYPE j_1bnflin-nfpri,
       netdis  TYPE j_1bnflin-netdis,
       taxval1 TYPE j_1bnfstx-taxval,
       taxval2 TYPE j_1bnfstx-taxval,
       taxval3 TYPE j_1bnfstx-taxval,
       taxval4 TYPE j_1bnfstx-taxval,
       taxval5 TYPE j_1bnfstx-taxval,
       taxval6 TYPE j_1bnfstx-taxval,
       base1   TYPE j_1bnfstx-base,
       base2   TYPE j_1bnfstx-base,
       base3   TYPE j_1bnfstx-base,
       base4   TYPE j_1bnfstx-base,
       base5   TYPE j_1bnfstx-base,
       base6   TYPE j_1bnfstx-base,
       excbas1 TYPE j_1bnfstx-excbas,
       excbas2 TYPE j_1bnfstx-excbas,
       excbas3 TYPE j_1bnfstx-excbas,
       excbas4 TYPE j_1bnfstx-excbas,
       excbas5 TYPE j_1bnfstx-excbas,
       excbas6 TYPE j_1bnfstx-excbas,
       othbas1 TYPE j_1bnfstx-othbas,
       othbas2 TYPE j_1bnfstx-othbas,
       othbas3 TYPE j_1bnfstx-othbas,
       othbas4 TYPE j_1bnfstx-othbas,
       othbas5 TYPE j_1bnfstx-othbas,
       othbas6 TYPE j_1bnfstx-othbas,
       flag(1) TYPE c,
       netwrt  TYPE j_1binlin-netwrt,
       nfnett  TYPE j_1binlin-nfnett,
END OF it_final_aux.

TYPES:  BEGIN OF ty_final_agr,
                bukrs   TYPE j_1bnfdoc-bukrs,
                cfop    TYPE j_1bnflin-cfop,
                taxsi  TYPE j_1bnflin-taxsi5,
                codimp  TYPE c LENGTH 3,
                rate    TYPE j_1bnfstx-rate,
                taxval  TYPE j_1bnfstx-taxval,
                base    TYPE j_1bnfstx-base,
           END OF ty_final_agr.

DATA:  BEGIN OF it_final_agr OCCURS 0,
                bukrs   TYPE j_1bnfdoc-bukrs,
                cfop    TYPE j_1bnflin-cfop,
                taxsi  TYPE j_1bnflin-taxsi5,
                codimp  TYPE c LENGTH 3,
                rate    TYPE j_1bnfstx-rate,
                taxval  TYPE j_1bnfstx-taxval,
                base    TYPE j_1bnfstx-base,
           END OF it_final_agr.

DATA: y_final_agr TYPE HASHED TABLE OF ty_final_agr
                  WITH UNIQUE KEY bukrs cfop taxsi codimp rate.

DATA: t_final_agr  LIKE y_final_agr,
      w_final_agr  LIKE LINE OF y_final_agr.

************************************************************************
*                         Tela de Seleção                              *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

SELECT-OPTIONS: so_bukrs   FOR j_1bnfdoc-bukrs OBLIGATORY,
                so_branc   FOR j_1bnfdoc-branch,
                so_matkl   FOR j_1bnflin-matkl,
                so_regio   FOR kna1-regio MATCHCODE OBJECT yregio,
                so_pstdt   FOR j_1bnfdoc-pstdat,
                so_docda   FOR j_1bnfdoc-pstdat,
                so_nftyp   FOR j_1bnfdoc-nftype,
                so_docnu   FOR j_1bnfdoc-docnum,
                so_nfnum   FOR j_1bnfdoc-nfnum,
                so_nfenu   FOR j_1bnfdoc-nfenum,
                so_serie   FOR j_1bnfdoc-series,
                so_direc   FOR j_1bnfdoc-direct,
                so_cance   FOR j_1bnfdoc-cancel,
                so_matnr   FOR j_1bnflin-matnr,
                so_cfop    FOR j_1bnflin-cfop,
                so_tax1    FOR j_1bnflin-taxsit,
                so_tax2    FOR j_1bnflin-taxsi2,
                so_tax4    FOR j_1bnflin-taxlw4,
                so_tax5    FOR j_1bnflin-taxlw5.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
  SELECTION-SCREEN BEGIN OF LINE.
      SELECTION-SCREEN COMMENT (10) text-003 FOR FIELD p_agr.
                PARAMETERS p_agr type c AS CHECKBOX .
      SELECTION-SCREEN COMMENT (15) text-010 FOR FIELD p_tot.
                PARAMETERS p_tot type c AS CHECKBOX .
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b2.

************************************************************************
* Evento INITIALIZATION
************************************************************************
*INITIALIZATION.
*  PERFORM alv_init.
*
************************************************************************
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_varia.
*************************************************************************
*  PERFORM alv_f4.

************************************************************************
* INÍCIO LÓGICO
************************************************************************
START-OF-SELECTION.
  PERFORM: busca_dados,
           prepara_dados,
           alv.

************************************************************************
*
*&---------------------------------------------------------------------*
*&      Form  busca_dados
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM busca_dados.

* Seleção J1BNFDOC
  SELECT a~docnum
         a~nfnum
         a~series
         a~parid
         a~bukrs
         a~branch
         a~pstdat
         a~nftype
         a~printd
         a~cancel
         a~direct
         a~nfenum
         a~model
         a~inco1
    INTO TABLE it_j1bnfdoc
         FROM j_1bnfdoc AS a INNER JOIN j_1bnflin AS b
                             ON a~docnum = b~docnum
    WHERE a~bukrs   IN so_bukrs AND
          a~branch  IN so_branc AND
          a~pstdat  IN so_pstdt AND
          a~docdat  IN so_docda AND
          a~nftype  IN so_nftyp AND
          a~docnum  IN so_docnu AND
          a~nfnum   IN so_nfnum AND
          a~series  IN so_serie AND
          a~nfenum  IN so_nfenu AND
          a~direct  IN so_direc AND
          b~matnr   IN so_matnr AND
          b~cfop    IN so_cfop  AND
          b~taxsit  IN so_tax1  AND
          b~taxsi2  IN so_tax2  AND
          b~taxsi4  IN so_tax4  AND
          b~taxsi5  IN so_tax5  AND
          a~cancel  IN so_cance.

  IF sy-subrc = 0.
    DELETE ADJACENT DUPLICATES FROM  it_j1bnfdoc COMPARING docnum.

    SELECT docnum parvw parid
      FROM j_1bnfnad
      INTO TABLE it_j1bnfnad
      FOR ALL ENTRIES IN it_j1bnfdoc
     WHERE docnum = it_j1bnfdoc-docnum
       AND parvw in ('SP', 'CA').

*   Seleção da descrição do cliente
    SELECT lifnr "chave
           name1
           regio
    FROM lfa1
     INTO TABLE it_lfa1
       FOR ALL ENTRIES IN it_j1bnfdoc
       WHERE lifnr = it_j1bnfdoc-parid AND
             regio IN so_regio.

*   Seleção da descrição do cliente
    SELECT kunnr "chave
           name1
           regio
    FROM kna1
     INTO TABLE it_kna1
       FOR ALL ENTRIES IN it_j1bnfdoc
       WHERE kunnr = it_j1bnfdoc-parid AND
             regio IN so_regio.

*   Seleção da descrição do fornecedor
    SELECT lifnr "chave
           name1
           regio
    FROM lfa1
     INTO TABLE it_lfa1t
       FOR ALL ENTRIES IN it_j1bnfnad
       WHERE lifnr = it_j1bnfnad-parid.

*   Seleção J1BNFLIN
    SELECT docnum "chave
           itmnum "chave
           matkl
           matnr
           maktx
           nbm
           menge
           netwr
           netpr
           nfpri
           netdis
           nfnett
           cfop
           taxsi4
           taxsi5
    FROM j_1bnflin
     INTO TABLE it_j1bnflin
       FOR ALL ENTRIES IN it_j1bnfdoc
       WHERE docnum = it_j1bnfdoc-docnum AND
             matkl IN so_matkl AND
             matnr IN so_matnr AND
             cfop  IN so_cfop.

    IF NOT it_j1bnflin[] IS INITIAL.

*       Seleção J1BNFSTX para coletar todos impostos
        SELECT docnum "chave
               itmnum "chave
               rate
               taxtyp
               taxval
               base
               excbas
               othbas
        FROM j_1bnfstx
         INTO TABLE it_j1bnfstx
           FOR ALL ENTRIES IN it_j1bnflin
           WHERE docnum = it_j1bnflin-docnum
             AND itmnum = it_j1bnflin-itmnum.

*     Seleção na visão V023
      SELECT matkl "chave
             wgbez60
      FROM t023t
       INTO TABLE it_t023t
         FOR ALL ENTRIES IN it_j1bnflin
         WHERE matkl = it_j1bnflin-matkl.

      SELECT MATNR SPRAS MAKTX MAKTG
        FROM MAKT
        INTO TABLE IT_MAKT
         FOR ALL ENTRIES IN it_j1bnflin
       WHERE matnr = it_j1bnflin-matnr
         AND SPRAS = sy-langu.

    ENDIF.
  ELSE.
    MESSAGE i000 WITH 'Nenhum registro encontrado.'.
    STOP.
  ENDIF.

ENDFORM.                    "

*&---------------------------------------------------------------------*
*&      Form  alv
*&---------------------------------------------------------------------*
FORM alvaux.

data v_repida type sy-repid.

* DEFINIÇÀO DO CABEÇALHO
*  PERFORM: alv_build_header.
*
* DEFINIÇÃO DAS COLUNAS A SEREM IMPRESSAS
  PERFORM: alv_build_fieldcat,
           definir_quebras_alv.

* DEFINIÇÃO DO LAYOUT
  PERFORM: alv_set_layout,
*
* DEFINIÇÃO DE EVENTOS
           alv_build_eventtab.

*     display ALV grid.
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
           EXPORTING
                i_callback_program       = 'YFI0010'
                is_layout                = st_alv_layout
                it_fieldcat              = it_alv_fieldcat
                it_events                = it_alv_events
                it_sort                  = it_sort_alv
           TABLES
                t_outtab                 = it_final_aux
           EXCEPTIONS
                program_error            = 1
                OTHERS                   = 2.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

*
ENDFORM.                    " alvaux

*&---------------------------------------------------------------------*
*&      Form  alv
*&---------------------------------------------------------------------*
FORM alv.

data v_repid type sy-repid.

* DEFINIÇÀO DO CABEÇALHO
  PERFORM: alv_build_header.
*
* DEFINIÇÃO DAS COLUNAS A SEREM IMPRESSAS
 IF p_agr IS INITIAL.
    PERFORM: alv_build_fieldcat,
*            DEFINIÇÃO DE QUEBRAS
             definir_quebras_alv.
 ELSE.
    PERFORM: alv_build_fieldcat_agr.
 ENDIF.

*
* DEFINIÇÃO DO LAYOUT
  PERFORM: alv_set_layout,
*
* DEFINIÇÃO DE EVENTOS
           alv_build_eventtab.


 IF p_agr IS INITIAL.
*      display ALV grid.
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
           EXPORTING
                i_callback_program       = 'YFI0010'
                i_callback_user_command  = 'ALV_USER_COMMAND'
                is_layout                = st_alv_layout
                it_fieldcat              = it_alv_fieldcat
                it_events                = it_alv_events
                it_sort                  = it_sort_alv
           TABLES
                t_outtab                 = it_final
           EXCEPTIONS
                program_error            = 1
                OTHERS                   = 2.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
  ELSE.
*      display ALV grid.
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
           EXPORTING
                i_callback_program       = 'YFI0010'
                i_callback_user_command  = 'ALV_USER_COMMAND'
                is_layout                = st_alv_layout
                it_fieldcat              = it_alv_fieldcat
                it_events                = it_alv_events
*                it_sort                  = it_sort_alv
           TABLES
                t_outtab                 = it_final_agr
           EXCEPTIONS
                program_error            = 1
                OTHERS                   = 2.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
 ENDIF.
*
ENDFORM.                    " alv

*&---------------------------------------------------------------------*
*&      Form  ALV_BUILD_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM alv_build_header.

  DATA: v_data(10)  TYPE c,
        v_hora(10)  TYPE c,
        v_dt(25)    TYPE c,
        v_cabec(60) TYPE c,
        v_mandt(20) TYPE c.

  DATA: ls_listheader LIKE LINE OF it_alv_listheader.

  WRITE sy-datum DD/MM/YYYY TO v_data.
  WRITE sy-uzeit TO v_hora.
  CONCATENATE v_data v_hora INTO v_dt SEPARATED BY ' - '.
  CONCATENATE sy-mandt sy-host(4) INTO v_mandt SEPARATED BY ' - '.

  REFRESH: it_alv_listheader.

* header info: headline
  CLEAR ls_listheader.

  ls_listheader-typ    = c_listheader.
  ls_listheader-key    = 'Titulo         : '.
  ls_listheader-info   = sy-title.
  APPEND ls_listheader TO it_alv_listheader.

  ls_listheader-typ    = c_listheader.
  ls_listheader-key    = 'Data/Hora      : '.
  ls_listheader-info   = v_dt.
  APPEND ls_listheader TO it_alv_listheader.

  ls_listheader-typ    = c_listheader.
  ls_listheader-key    = 'Mandt/Host     : '.
  ls_listheader-info   = v_mandt.
  APPEND ls_listheader TO it_alv_listheader.

  ls_listheader-typ    = c_listheader.
  ls_listheader-key    = 'Usuário        : '.
  ls_listheader-info   = sy-uname.
  APPEND ls_listheader TO it_alv_listheader.

ENDFORM.                    " ALV_BUILD_HEADER

*&---------------------------------------------------------------------*
*&      Form  ALV_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM alv_build_fieldcat_agr.
*
  DATA: l_fieldcat TYPE slis_fieldcat_alv,
        l_count    TYPE i.
*
  CLEAR: l_count.
  REFRESH: it_alv_fieldcat.

*
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'BUKRS'.
  l_fieldcat-ref_tabname   = 'IT_FINAL_AGR'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '4'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-seltext_l     = 'Empresa'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'CFOP'.
  l_fieldcat-ref_tabname   = 'IT_FINAL_AGR'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '7'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-hotspot       = 'X'.
  l_fieldcat-seltext_l     = 'CFOP'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'TAXSI'.
  l_fieldcat-ref_tabname   = 'IT_FINAL_AGR'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '2'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-seltext_l     = 'CST'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'CODIMP'.
  l_fieldcat-ref_tabname   = 'IT_FINAL_AGR'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '3'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-seltext_l     = 'Imposto'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'RATE'.
  l_fieldcat-ref_tabname   = 'IT_FINAL_AGR'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '6'.
  l_fieldcat-datatype      = 'DEC'.
  l_fieldcat-seltext_l     = 'Aliquota'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'TAXVAL'.
  l_fieldcat-ref_tabname   = 'IT_FINAL_AGR'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-seltext_l     = 'Valor Impostos'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'BASE'.
  l_fieldcat-ref_tabname   = 'IT_FINAL_AGR'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-seltext_l     = 'Base de Cálculo'.
  APPEND l_fieldcat TO it_alv_fieldcat.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ALV_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM alv_build_fieldcat.
*
  DATA: l_fieldcat TYPE slis_fieldcat_alv,
        l_count    TYPE i.
*
  CLEAR: l_count.
  REFRESH: it_alv_fieldcat.

* J_1BNFDOC - DOCNUM
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-KEY           = 'X'.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'DOCNUM'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '10'.
  l_fieldcat-datatype      = 'NUNC'.
  l_fieldcat-hotspot       = 'X'.
  l_fieldcat-seltext_l     = 'Nº Interno NF'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFLIN - ITMNUM
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-KEY           = 'X'.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'ITMNUM'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '6'.
  l_fieldcat-datatype      = 'NUNC'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Item NF'.
  APPEND l_fieldcat TO it_alv_fieldcat.

* J_1BNFDOC - NNF
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
*  l_fieldcat-KEY           = 'X'.
*  l_fieldcat-edit          = 'X'.
  l_fieldcat-KEY           = 'X'.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'NNF'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '12'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Nº NF'.
  APPEND l_fieldcat TO it_alv_fieldcat.

* J_1BNFDOC - NNF
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
*  l_fieldcat-KEY           = 'X'.
*  l_fieldcat-edit          = 'X'.
  l_fieldcat-KEY           = 'X'.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'MODEL'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '2'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Modelo'.
  APPEND l_fieldcat TO it_alv_fieldcat.

* J_1BNFDOC - NNF
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
*  l_fieldcat-KEY           = 'X'.
*  l_fieldcat-edit          = 'X'.
  l_fieldcat-KEY           = 'X'.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'DIRECT'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '2'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Ent/Sai'.
  APPEND l_fieldcat TO it_alv_fieldcat.

* J_1BNFDOC - PARID
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'PARID'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '10'.
  l_fieldcat-datatype      = 'char'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Código Cliente/Fornecedor'.
  APPEND l_fieldcat TO it_alv_fieldcat.
*
* J_1BNFDOC - NAME1
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'NAME1'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '35'.
  l_fieldcat-datatype      = 'char'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Desc. Cliente/Fornecedor'.
  APPEND l_fieldcat TO it_alv_fieldcat.
*
*J_1BNFDOC - BUKRS
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'BUKRS'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '4'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'L.E./Empresa'.
  APPEND l_fieldcat TO it_alv_fieldcat.
*
*J_1BNFDOC - BRANCH
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'BRANCH'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '4'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Filial'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFDOC - BRANCH
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'CFOP'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '8'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'CFOP'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFDOC - BRANCH
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'TAXSI4'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '2'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'CST COFINS'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFDOC - BRANCH
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'TAXSI5'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '2'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'CST PIS'.
  APPEND l_fieldcat TO it_alv_fieldcat.

* KNA1 - REGIO
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
*  l_fieldcat-KEY           = 'X'.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'REGIO'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '3'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-hotspot       = ' '.
  l_fieldcat-seltext_l     = 'Estado'.
  APPEND l_fieldcat TO it_alv_fieldcat.
*
*J_1BNFDOC - PSTDAT
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'PSTDAT'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '8'.
  l_fieldcat-datatype      = 'DATS'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Dt. Emissão'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*
*J_1BNFLIN - INCO1
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'INCO1'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '18'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'CIF/FOB'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFLIN - INCO1
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'TRANSP'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '35'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Transportadora'.
  APPEND l_fieldcat TO it_alv_fieldcat.
*
*J_1BNFLIN - MATNR
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'MATNR'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '18'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Nº Material'.
  APPEND l_fieldcat TO it_alv_fieldcat.
*
*J_1BNFLIN - MAKTX
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'MAKTX'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '40'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Descrição'.
  APPEND l_fieldcat TO it_alv_fieldcat.
*

*
*J_1BNFLIN - NBM
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'NBM'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '16'.
  l_fieldcat-datatype      = 'CHAR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Código de controle'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFLIN - NBM
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'MENGE'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '13'.
  l_fieldcat-datatype      = 'QUAN'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Quantidade'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*
*J_1BNFLIN - netwr
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'NETPR'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Preço líquido'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFLIN - netwr
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'NETWR'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Valor Liq. Item'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFSTX - RATE - PIS
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'RATE1'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '6'.
  l_fieldcat-datatype      = 'DEC'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Aliquota PIS'.
  APPEND l_fieldcat TO it_alv_fieldcat.
*
*J_1BNFSTX - TAXVAL
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'TAXVAL1'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Valor do PIS'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*Valor da BASE - PIS
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'BASE1'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Valor Base PIS'.
  APPEND l_fieldcat TO it_alv_fieldcat.

  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'EXCBAS1'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Base Excl.PIS'.
  APPEND l_fieldcat TO it_alv_fieldcat.

  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'OTHBAS1'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Outra Base PIS'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFSTX - RATE - COFINS
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'RATE2'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '6'.
  l_fieldcat-datatype      = 'DEC'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Aliquota COFINS'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFSTX - TAXVAL
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'TAXVAL2'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Valor da COFINS'.
  APPEND l_fieldcat TO it_alv_fieldcat.
*
*Valor da BASE - COFINS
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'BASE2'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Valor Base COFINS'.
  APPEND l_fieldcat TO it_alv_fieldcat.

  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'EXCBAS2'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Base Excl.COFINS'.
  APPEND l_fieldcat TO it_alv_fieldcat.

  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'OTHBAS2'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Outra Base COFINS'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFSTX - RATE - IPI
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'RATE3'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '6'.
  l_fieldcat-datatype      = 'DEC'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Aliquota IPI'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFSTX - TAXVAL
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'TAXVAL3'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Valor da IPI'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*Valor da BASE - IPI
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'BASE3'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Valor Base IPI'.
  APPEND l_fieldcat TO it_alv_fieldcat.

  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'EXCBAS3'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Base Excl.IPI'.
  APPEND l_fieldcat TO it_alv_fieldcat.

  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'OTHBAS3'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Outra Base IPI'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFSTX - RATE - ICMS
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'RATE4'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '6'.
  l_fieldcat-datatype      = 'DEC'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Aliquota ICMS'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFSTX - TAXVAL
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'TAXVAL4'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Valor da ICMS'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*Valor da BASE - ICMS
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'BASE4'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Valor Base ICMS'.
  APPEND l_fieldcat TO it_alv_fieldcat.

  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'EXCBAS4'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Base Excl.ICMS'.
  APPEND l_fieldcat TO it_alv_fieldcat.

  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'OTHBAS4'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Outra Bae.ICMS'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFSTX - RATE - ICMS ST
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'RATE5'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '6'.
  l_fieldcat-datatype      = 'DEC'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Aliquota ICMS ST'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFSTX - TAXVAL
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'TAXVAL5'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Valor da ICMS ST'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*Valor da BASE - ICMS Sub
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'BASE5'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Valor Base ICMS Sub'.
  APPEND l_fieldcat TO it_alv_fieldcat.

  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'EXCBAS5'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Base Excl.ICMS Sub'.
  APPEND l_fieldcat TO it_alv_fieldcat.

  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'OTHBAS5'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Outra Base ICMS Sub'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFSTX - RATE - ICMS ST
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'RATE6'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '6'.
  l_fieldcat-datatype      = 'DEC'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Aliquota ICMS ZF'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*J_1BNFSTX - TAXVAL
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'TAXVAL6'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Valor da ICMS ZF'.
  APPEND l_fieldcat TO it_alv_fieldcat.

*Valor da BASE - ICMS Sub
  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'BASE6'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Valor Base ICMS ZF'.
  APPEND l_fieldcat TO it_alv_fieldcat.

  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'EXCBAS6'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Base Excl.ICMS ZF'.
  APPEND l_fieldcat TO it_alv_fieldcat.

  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'OTHBAS6'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Outra Base ICMS ZF'.
  APPEND l_fieldcat TO it_alv_fieldcat.

  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'NETWRT'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Total Liquido'.
  APPEND l_fieldcat TO it_alv_fieldcat.

  CLEAR  l_fieldcat.
  l_count                  = l_count + 1.
  l_fieldcat-col_pos       = l_count.
  l_fieldcat-fieldname     = 'NFNETT'.
  l_fieldcat-ref_tabname   = 'IT_FINAL'.
  l_fieldcat-ddictxt       = 'L'.
  l_fieldcat-outputlen     = '15'.
  l_fieldcat-datatype      = 'CURR'.
  l_fieldcat-hotspot       = ''.
  l_fieldcat-seltext_l     = 'Total'.
  APPEND l_fieldcat TO it_alv_fieldcat.
ENDFORM.                    " ALV_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  ALV_SET_LAYOUT
*&---------------------------------------------------------------------*
FORM alv_set_layout.

  CLEAR: st_alv_layout.
* DEFINIÇÃO DE ÍTEM COMO DEFAULT (JÁ USEI COM 'X' E VAZIO E NÃO TIVE
* PROBLEMAS....
  st_alv_layout-default_item      = 'X'.
* DEFINIÇÃO DE LINHAS DIFERENCIADAS POR CORES
  st_alv_layout-zebra             = 'X'.
* SY-UCOMM, NESTE PONTO FIXA-SE A VAR C_DISPLAY = 'DISPLAY'
  st_alv_layout-f2code            = c_display.
* DEFINIÇÃO IDEAL DA LARGURA DAS COLUNAS
  st_alv_layout-colwidth_optimize = 'X'.
* DEFINIÇÃO DE COR EM COLUNAS
*  st_alv_layout-box_fieldname = 'FLAG'.

ENDFORM.                    " ALV_SET_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  ALV_BUILD_EVENTTAB
*&---------------------------------------------------------------------*
FORM alv_build_eventtab.

  DATA: ls_alv_events    TYPE slis_alv_event,
        l_dummy_ucomm    LIKE sy-ucomm,
        l_dummy_selfield TYPE slis_selfield.

  REFRESH: it_alv_events.

** event 'BEFORE_LINE_OUTPUT'
*  CLEAR ls_alv_events.
*  ls_alv_events-name = slis_ev_before_line_output.
*  ls_alv_events-form = 'BEFORE_LINE_OUTPUT'.
*  APPEND ls_alv_events TO it_alv_events.

** event 'TOP_OF_PAG_ALV'
*  CLEAR ls_alv_events.
*  ls_alv_events-name = slis_ev_top_of_page.
*  ls_alv_events-form = 'TOP_OF_PAG_ALV'.
*  APPEND ls_alv_events TO et_alv_events.

* event 'USER_COMMAND'.
  CLEAR ls_alv_events.
  ls_alv_events-name = slis_ev_user_command.
  ls_alv_events-form = 'ALV_USER_COMMAND'.
  APPEND ls_alv_events TO it_alv_events.

* event 'ALV_TOP_OF_LIST'.
  CLEAR ls_alv_events.
  ls_alv_events-name = slis_ev_top_of_list.
  ls_alv_events-form = 'ALV_TOP_OF_LIST'.
  APPEND ls_alv_events TO it_alv_events.

* callback forms.
  IF 1 = 0.
    PERFORM alv_top_of_list.
    PERFORM alv_user_command USING l_dummy_ucomm
                                   l_dummy_selfield.
  ENDIF.

ENDFORM.                    " ALV_BUILD_EVENTTAB


*&---------------------------------------------------------------------*
*&      Form  ALV_TOP_OF_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_top_of_list.

* O LOGO somente aparece qnd. executa-se GRID...

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = it_alv_listheader
      i_logo             = 'ENJOYSAP_LOGO'. " ID da figura

ENDFORM.                    " ALV_TOP_OF_LIST

*&---------------------------------------------------------------------*
*&      Form  ALV_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_DUMMY_UCOMM  text
*      -->P_L_DUMMY_SELFIELD  text
*----------------------------------------------------------------------*
FORM alv_user_command USING i_ucomm    LIKE sy-ucomm
                            i_selfield TYPE slis_selfield.

  i_selfield-before_action = 'X'.

  CASE i_ucomm.

    WHEN c_display.
      CASE i_selfield-fieldname.
        WHEN 'DOCNUM'.
          IF p_agr is INITIAL.
              READ TABLE it_final INDEX i_selfield-tabindex.
              IF sy-subrc = 0.
*    Neste ponto, se ao realizar um Clique duplo no campo BELNR, tem-se
*     duas(2) opções:
*     1) Se a transação FB03 executasse com um parâmetro apenas:
*                SET PARAMETER ID 'JEF' FIELD i_selfield-value.
*     2) Se a transação FB03 executasse com dois parâmetro (Exemplo):
                SET PARAMETER ID 'JEF' FIELD it_final-docnum.
                CALL TRANSACTION 'J1B3N' AND SKIP FIRST SCREEN.
              ENDIF.
          ELSE.
            READ TABLE it_final_aux INDEX i_selfield-tabindex.
            IF sy-subrc = 0.
*  Neste ponto, se ao realizar um Clique duplo no campo BELNR, tem-se
*   duas(2) opções:
*   1) Se a transação FB03 executasse com um parâmetro apenas:
*              SET PARAMETER ID 'JEF' FIELD i_selfield-value.
*   2) Se a transação FB03 executasse com dois parâmetro (Exemplo):
              SET PARAMETER ID 'JEF' FIELD it_final_aux-docnum.
              CALL TRANSACTION 'J1B3N' AND SKIP FIRST SCREEN.
            ENDIF.
          ENDIF.

       WHEN 'CFOP'.
          CLEAR: it_final_aux, it_final_aux[].
          READ TABLE it_final_agr INTO w_final_agr INDEX i_selfield-tabindex.
          LOOP AT it_final WHERE bukrs = w_final_agr-bukrs and cfop = w_final_agr-cfop and ( taxsi4 = w_final_agr-taxsi or taxsi5 = w_final_agr-taxsi ).
               APPEND it_final TO it_final_aux.
          ENDLOOP.
          PERFORM alvaux.
      ENDCASE.

* TRATAMENTO DO BOTÃO SAVE(refresh na tela) PARA CAMPOS EDITADOS...

*        WHEN '&DATA_SAVE'.
**
*          LOOP AT it_final WHERE flag = 'X'.
**
*            CONCATENATE IT_J1BNFDOC-DOCNUM '_00_' INTO IT_FINAL-DOCNUM.
*            MODIFY it_FINAL INDEX SY-TABIX.
**
*          ENDLOOP.
*
*          PERFORM ALV.
**
*        WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " ALV_USER_COMMAND

**&---------------------------------------------------------------------*
**&      Form  definir_quebras_alv
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
FORM definir_quebras_alv.

* Ordenar lista
  SORT it_final BY docnum nnf.

  CLEAR st_sort_alv.
  st_sort_alv-spos = '01'.
  st_sort_alv-fieldname = 'DOCNUM'.
  st_sort_alv-tabname = 'IT_J1BNFDOC'.
  st_sort_alv-up = 'X'.
*  st_sort_alv-DOWN = 'X'.
  st_sort_alv-subtot = 'X'.    " inicializar com 'X' para totalização
  st_sort_alv-group = ''.     " inicializar com '*' para quebra
  APPEND st_sort_alv TO it_sort_alv.

* Ordenar lista
  SORT it_final BY docnum itmnum.

*  CLEAR st_sort_alv.
*  st_sort_alv-spos = '01'.
*  st_sort_alv-fieldname = 'ITMNUM'.
*  st_sort_alv-tabname = 'IT_J1BNFDOC'.
*  st_sort_alv-up = 'X'.
**  st_sort_alv-DOWN = 'X'.
*  st_sort_alv-subtot = 'X'.    " inicializar com 'X' para totalização
*  st_sort_alv-group = ''.     " inicializar com '*' para quebra
*  APPEND st_sort_alv TO it_sort_alv.

*  CLEAR st_sort_alv.
*  st_sort_alv-spos = '02'.
*  st_sort_alv-fieldname = 'nnf'.
*  st_sort_alv-tabname = 'it_j1bnfdoc'.
*  st_sort_alv-up = 'X'.
**  st_sort_alv-DOWN = 'X'.
*  st_sort_alv-subtot = 'X'.    " inicializar com 'X' para totalização
*  st_sort_alv-group = ''.     " inicializar com '*' para quebra
*  APPEND st_sort_alv TO it_sort_alv.
**
ENDFORM.                    " definir_quebras_alv
**&---------------------------------------------------------------------*
**&      Form  ALV_INIT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*FORM alv_init.
**
*  CLEAR: v_variante.
*  v_variante-report = sy-repid.
**
*  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
*    EXPORTING
*      i_save     = 'A'
*    CHANGING
*      cs_variant = v_variante
*    EXCEPTIONS
*      not_found  = 2.
**
*  IF sy-subrc = 0.
*    p_varia = v_variante-variant.
*  ENDIF.
**
*ENDFORM.                    " ALV_INIT
*&---------------------------------------------------------------------*
*&      Form  ALV_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM alv_f4.
**
*  v_variante-report = sy-repid.
*  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
*    EXPORTING
*      is_variant = v_variante
*      i_save     = 'A'
*    IMPORTING
*      es_variant = v_variante
*    EXCEPTIONS
*      not_found  = 2.
**
*  IF sy-subrc = 2.
*    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ELSE.
*    p_varia = v_variante-variant.
*  ENDIF.
**
*ENDFORM.                                                    " ALV_F4
*&---------------------------------------------------------------------*
*&      Form  prepara_dados
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM  prepara_dados.

  SORT: it_j1bnfdoc BY docnum.
  SORT: it_j1bnflin BY docnum.

  LOOP AT it_j1bnflin.

     IF NOT P_TOT IS INITIAL.

         CALL FUNCTION 'J_1B_NF_DOCUMENT_READ'
            EXPORTING
              doc_number         = it_j1bnflin-docnum
            IMPORTING
              doc_header         = wk_header
            TABLES
              doc_partner        = wk_partner
              doc_item           = wk_item
              doc_item_tax       = wk_item_tax
              doc_header_msg     = wk_header_msg
              doc_refer_msg      = wk_refer_msg
            EXCEPTIONS
              document_not_found = 1
              docum_lock         = 2
              OTHERS             = 3.

         CALL FUNCTION 'J_1B_NF_VALUE_DETERMINATION'
            EXPORTING
              nf_header   = wk_header
            IMPORTING
              ext_header  = wk_header_add
            TABLES
              nf_item     = wk_item
              nf_item_tax = wk_item_tax
              ext_item    = wk_item_add.

     ENDIF.

     LOOP AT it_j1bnfdoc where docnum = it_j1bnflin-docnum.

       MOVE: it_j1bnfdoc-docnum  TO it_final-docnum,
             it_j1bnflin-itmnum  TO it_final-itmnum ,
             it_j1bnflin-cfop    TO it_final-cfop ,
             it_j1bnfdoc-model   TO it_final-model ,
             it_j1bnfdoc-direct  TO it_final-direct ,
             it_j1bnfdoc-inco1   TO it_final-inco1 ,
             it_j1bnflin-taxsi4  TO it_final-taxsi4 ,
             it_j1bnflin-taxsi5  TO it_final-taxsi5 ,
             it_j1bnflin-matnr   TO it_final-matnr ,
             it_j1bnflin-menge   TO it_final-menge ,
             it_j1bnflin-nbm     TO it_final-nbm ,
             it_j1bnflin-netdis  TO it_final-netdis,
             it_j1bnflin-netwr   TO it_final-netwr,
             it_j1bnflin-netpr   TO it_final-netpr,
             it_j1bnflin-nfpri   TO it_final-nfpri ,
             it_j1bnflin-nfnett  TO it_final-nfnett,
             it_j1bnfdoc-parid   TO it_final-parid ,
             it_j1bnfdoc-bukrs   TO it_final-bukrs ,
             it_j1bnfdoc-branch  TO it_final-branch,
             it_j1bnfdoc-pstdat  TO it_final-pstdat,
             wk_item_add-netwrt  TO it_final-netwrt,
             wk_item_add-nfnett  TO it_final-nfnett.



       IF it_j1bnfdoc-nfnum NE '000000'.
         CONCATENATE it_j1bnfdoc-nfnum
                     it_j1bnfdoc-series
                     INTO nnf.
       ELSE.
         CONCATENATE it_j1bnfdoc-nfenum
                     it_j1bnfdoc-series
                     INTO nnf.
       ENDIF.

       MOVE: nnf TO it_final-nnf.

*   -------------------------------------------------------
       READ TABLE it_j1bnfnad WITH KEY docnum = it_j1bnfdoc-docnum.
       IF sy-subrc = 0.
          READ TABLE it_lfa1t WITH KEY lifnr = it_j1bnfnad-parid.
          IF sy-subrc = 0.
              MOVE: it_lfa1t-name1  TO it_final-transp.
          ENDIF.
       ENDIF.

*   -------------------------------------------------------
       READ TABLE it_lfa1 WITH KEY lifnr = it_j1bnfdoc-parid.
       IF sy-subrc = 0.
         MOVE: it_lfa1-name1  TO it_final-name1,
               it_lfa1-regio  TO it_final-regio.
       ELSE.
         READ TABLE it_kna1 WITH KEY kunnr = it_j1bnfdoc-parid.
         IF sy-subrc = 0..
            MOVE: it_kna1-name1  TO it_final-name1,
                  it_kna1-regio  TO it_final-regio.
         ENDIF.
       ENDIF.

*   -------------------------------------------------------
       READ TABLE IT_MAKT WITH KEY matnr = it_j1bnflin-matnr.
       IF sy-subrc = 0.
          it_final-maktx = it_makt-maktx.
       ENDIF.
*   -------------------------------------------------------
             LOOP AT it_j1bnfstx WHERE docnum = it_j1bnfdoc-docnum
                                   AND itmnum = it_j1bnflin-itmnum.

              CALL FUNCTION 'J_1BAJ_READ'
                  EXPORTING
                   taxtype              = it_j1bnfstx-taxtyp
                  IMPORTING
                   e_j_1baj             = ls_j1baj
                  EXCEPTIONS
                   not_found            = 1
                   parameters_incorrect = 2
                  OTHERS               = 3.

                IF sy-subrc <> 0.
                   MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                ENDIF.

                CASE ls_j1baj-taxgrp.
               WHEN 'IPI'.
                 MOVE: it_j1bnfstx-rate    TO it_final-rate3,
                       it_j1bnfstx-base    TO it_final-base3,
                       it_j1bnfstx-taxval  TO it_final-taxval3,
                       it_j1bnfstx-excbas  TO it_final-excbas3,
                       it_j1bnfstx-othbas  TO it_final-othbas3.
               WHEN 'PIS'.
                 MOVE: it_j1bnfstx-rate    TO it_final-rate1,
                       it_j1bnfstx-base    TO it_final-base1,
                       it_j1bnfstx-taxval  TO it_final-taxval1,
                       it_j1bnfstx-excbas  TO it_final-excbas1,
                       it_j1bnfstx-othbas  TO it_final-othbas1.

                       MOVE-CORRESPONDING it_j1bnfstx TO w_final_agr.
                       MOVE-CORRESPONDING it_final TO w_final_agr.

                       IF NOT it_j1bnfstx-base IS INITIAL.
                          w_final_agr-base = it_j1bnfstx-base.
                       ELSEIF NOT  it_j1bnfstx-excbas IS INITIAL.
                           w_final_agr-base = it_j1bnfstx-excbas.
                       ELSE.
                           w_final_agr-base = it_j1bnfstx-othbas.
                       ENDIF.

                       w_final_agr-taxsi = it_final-taxsi4.
                       w_final_agr-codimp = 'PIS'.
                       COLLECT w_final_agr INTO t_final_agr.
               WHEN 'COFI'.
                 MOVE: it_j1bnfstx-rate    TO it_final-rate2,
                       it_j1bnfstx-base    TO it_final-base2,
                       it_j1bnfstx-taxval  TO it_final-taxval2,
                       it_j1bnfstx-excbas  TO it_final-excbas2,
                       it_j1bnfstx-othbas  TO it_final-othbas2.

                       MOVE-CORRESPONDING it_j1bnfstx TO w_final_agr.
                       MOVE-CORRESPONDING it_final    TO w_final_agr.

                       IF NOT it_j1bnfstx-base IS INITIAL.
                          w_final_agr-base = it_j1bnfstx-base.
                       ELSEIF NOT  it_j1bnfstx-excbas IS INITIAL.
                           w_final_agr-base = it_j1bnfstx-excbas.
                       ELSE.
                           w_final_agr-base = it_j1bnfstx-othbas.
                       ENDIF.

                       w_final_agr-taxsi = it_final-taxsi5.
                       w_final_agr-codimp = 'COF'.
                       COLLECT w_final_agr INTO t_final_agr.
               WHEN 'ICMS'.
                 IF it_j1bnfstx-taxtyp = 'ICZF'.
                      MOVE: it_j1bnfstx-rate    TO it_final-rate6,
                            it_j1bnfstx-base    TO it_final-base6,
                            it_j1bnfstx-taxval  TO it_final-taxval6,
                            it_j1bnfstx-excbas  TO it_final-excbas6,
                            it_j1bnfstx-othbas  TO it_final-othbas6.
                 ELSE.
                      MOVE: it_j1bnfstx-rate    TO it_final-rate4,
                            it_j1bnfstx-base    TO it_final-base4,
                            it_j1bnfstx-taxval  TO it_final-taxval4,
                            it_j1bnfstx-excbas  TO it_final-excbas4,
                            it_j1bnfstx-othbas  TO it_final-othbas4.
                 ENDIF.
               WHEN 'ICST'.
                 MOVE: it_j1bnfstx-rate    TO it_final-rate5,
                       it_j1bnfstx-base    TO it_final-base5,
                       it_j1bnfstx-taxval  TO it_final-taxval5,
                       it_j1bnfstx-excbas  TO it_final-excbas5,
                       it_j1bnfstx-othbas  TO it_final-othbas5.
             ENDCASE.

           ENDLOOP.

       APPEND it_final.
       CLEAR: it_final.
       CLEAR: nnf.

     ENDLOOP.
  ENDLOOP.

  LOOP AT t_final_agr INTO w_final_agr.
       APPEND w_final_agr TO it_final_agr.
  ENDLOOP.
ENDFORM.                    " prepara_dados