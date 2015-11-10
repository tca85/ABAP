*&---------------------------------------------------------------------*
*&  Include           ZXVBZU05
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(X_BNCOM) LIKE  BNCOM STRUCTURE  BNCOM OPTIONAL
*"             VALUE(X_MCHA) LIKE  MCHA STRUCTURE  MCHA OPTIONAL
*"       CHANGING
*"             VALUE(REF_MATERIAL) LIKE  MCHA-MATNR OPTIONAL
*"             VALUE(REF_BATCH) LIKE  MCHA-CHARG OPTIONAL
*"             VALUE(REF_PLANT) LIKE  MCHA-WERKS OPTIONAL
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*                       ACHÉ LABORATÓRIOS                              *
*----------------------------------------------------------------------*
* Transação: QA11                                                      *
* Projeto  : CMOD - SAPLV1ZN                                           *
* Ampliação: SMOD - SAPLV1ZN / SE37 - EXIT_SAPLV01Z_011                *
* Descrição: Exits MF p/ aval. de lotes no âmbito de VB_CREATE_BATCH   *
*----------------------------------------------------------------------*
* Objetivo : Obrigar criação da Nota de QM quando a DU for reprovada   *
*            no momento de salvar DU (QA11)                            *
* Módulo   : QM                                                        *
* Projeto  : Notas de QM (Não-conformidade no recebimento físico)      *
* Funcional: Meire Vicente Casale                                      *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  17.10.2013  #63782 - Desenvolvimento inicial               *
* ACTHIAGO  30.01.2014  #63782 - Tratamento para sub-contratação       *
*----------------------------------------------------------------------*

CHECK sy-tcode = 'QA11'. " Entrar Decisão de Utilização

*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_tp_material    ,
    matnr TYPE mara-matnr    , " Nº do material
    mtart TYPE mara-mtart    , " Tipo de material
  END OF ty_tp_material      ,

  BEGIN OF ty_sub_contratacao,
    mblnr TYPE mseg-mblnr    , " Nº documento de material
    zeile TYPE mseg-zeile    , " Item no documento do material
    bwart TYPE mseg-bwart    , " Tipo de movimento (administração de estoques)
    werks TYPE mseg-werks    , " Centro
    charg TYPE mseg-charg    , " Número do lote
    lifnr TYPE mseg-lifnr    , " Nº conta do fornecedor
    aufnr TYPE mseg-aufnr    , " Nº ordem
    bstmg TYPE mseg-bstmg    , " Qtd.entrada em unidade de medida de pedido
  END OF ty_sub_contratacao  .

*----------------------------------------------------------------------*
* Tabelas internas                                                     *
*----------------------------------------------------------------------*
DATA: t_tp_material     TYPE STANDARD TABLE OF ty_tp_material    ,
      t_sub_contratacao TYPE STANDARD TABLE OF ty_sub_contratacao.

*----------------------------------------------------------------------*
* Work Areas                                                           *
*----------------------------------------------------------------------*
DATA: w_tp_material     LIKE LINE OF t_tp_material    ,
      w_sub_contratacao LIKE LINE OF t_sub_contratacao.

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
DATA: v_ordem_producao TYPE mseg-aufnr.

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
CONSTANTS:
  c_du_reprovada    TYPE qpcd-code   VALUE '03'                   ,
  c_ctrl_em_prod    TYPE tq30-art    VALUE '04'                   , "Controle final na EM da produção
  c_cod_du          TYPE c LENGTH 21 VALUE '(SAPMQEVA)RQEVA-VCODE',
  c_qals            TYPE c LENGTH 14 VALUE '(SAPMQEVA)QALS'       ,
  c_entr_mercadoria TYPE t156-bwart  VALUE '101'                  ,
  c_embalagem       TYPE t134-mtart  VALUE 'VERP'                 ,
  c_mat_revenda     TYPE t134-mtart  VALUE 'HAWA'                 ,
  c_mat_prima       TYPE t134-mtart  VALUE 'ROH'                  ,
  c_mat_prima_imp   TYPE t134-mtart  VALUE 'YROH'                 .

FIELD-SYMBOLS: <fs_cod_du> TYPE rqeva-vcode, " Code da decisão de utilização
               <fs_qals>   TYPE qals       . " Registro do lote de controle

DATA: v_qtd TYPE i.

ASSIGN: (c_cod_du) TO <fs_cod_du>,
        (c_qals)   TO <fs_qals>  .

CHECK <fs_cod_du> IS ASSIGNED
  AND <fs_qals>   IS ASSIGNED.

* Se a DU for reprovada e  houver nº do fornecedor
* solicitar obrigatoriamente a Nota de QM
IF    <fs_cod_du> = c_du_reprovada " 03
  AND <fs_qals>-sellifnr IS NOT INITIAL.

  SELECT matnr   " Nº do material
         mtart   " Tipo de material
   FROM mara
   INTO TABLE t_tp_material
   WHERE matnr = <fs_qals>-matnr
     AND mtart IN (c_embalagem     ,  " VERP
                   c_mat_revenda   ,  " HAWA
                   c_mat_prima     ,  " ROH
                   c_mat_prima_imp).  " YROH

  CHECK t_tp_material IS NOT INITIAL.

  CLEAR v_qtd.

* Verifica se já existe Nota de QM para esse material
  SELECT COUNT( * )
    FROM qmel
    INTO v_qtd
    WHERE matnr  = <fs_qals>-matnr  " Material
      AND charg  = <fs_qals>-charg  " Lote
      AND mawerk = <fs_qals>-werk.  " Centro

  IF sy-subrc <> 0.
*   Criar a Nota de QM - Registro de Não Conformidade de Fornecedor.
    MESSAGE e001(ynqm).
  ENDIF.

* Sub-Contratação
ELSEIF <fs_cod_du>   = c_du_reprovada " 03
   AND <fs_qals>-art = c_ctrl_em_prod    " Tipo de controle = 4* (entrada de mercadoria pela produção)
   AND <fs_qals>-sellifnr IS INITIAL
   AND <fs_qals>-aufnr    IS NOT INITIAL.

  SELECT mblnr    " Nº documento de material
         zeile    " Item no documento do material
         bwart    " Tipo de movimento (administração de estoques)
         werks    " Centro
         charg    " Número do lote
         lifnr    " Nº conta do fornecedor
         aufnr    " Nº ordem
         bstmg    " Qtd.entrada em unidade de medida de pedido
    FROM mseg
    INTO TABLE t_sub_contratacao
    WHERE bwart = c_entr_mercadoria                         " 101
      AND aufnr = <fs_qals>-aufnr
      AND lifnr <> space.

  IF t_sub_contratacao IS NOT INITIAL.

*   Verifica se já existe Nota de QM para esse material
    SELECT COUNT( * )
      FROM qmel
      WHERE matnr  = <fs_qals>-matnr  " Material
        AND charg  = <fs_qals>-charg  " Lote
        AND mawerk = <fs_qals>-werk.  " Centro

    IF sy-subrc <> 0.
*     Criar a Nota de QM - Registro de Não Conformidade de Fornecedor.
      MESSAGE e001(ynqm).
    ENDIF.
  ENDIF.
ENDIF.