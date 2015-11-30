*&---------------------------------------------------------------------*
*&  Include           ZXQQMU01
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(I_VIQMEL) LIKE  VIQMEL STRUCTURE VIQMEL
*"             VALUE(I_TQ80)   LIKE  TQ80   STRUCTURE TQ80
*"       EXPORTING
*"             VALUE(E_VIQMEL) LIKE  VIQMEL STRUCTURE VIQMEL
*"       TABLES
*"              T_VIQMFE STRUCTURE  WQMFE
*"              T_VIQMUR STRUCTURE  WQMUR
*"              T_VIQMMA STRUCTURE  WQMMA
*"              T_VIQMSM STRUCTURE  WQMSM
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*                       xxxxxxxxxxxxxxxxx                              *
*----------------------------------------------------------------------*
* Transação: QM01                                                      *
* Projeto  : CMOD - YNQM                                               *
* Ampliação: SMOD - QQMA0007 / SE37 - EXIT_SAPMIWO0_001                *
* Descrição: QM: valores propostos ao anexar uma nota                  *
*----------------------------------------------------------------------*
* Objetivo : Preenchimento obrigatório do documento de material ou     *
*            documento de compras                                      *
* Módulo   : QM                                                        *
* Projeto  : Notas de QM (Não-conformidade no recebimento físico)      *
* Funcional: xxxxxxxxxxxxxxxxxxxxx                                     *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  18.10.2013  #63782 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

CHECK sy-tcode = 'QM01'. " Criar Nota QM

CONSTANTS:
   c_docto_material TYPE c LENGTH 22 VALUE '(SAPLQM03)RQM01-MBLNR',
   c_itm_doc_mat    TYPE c LENGTH 22 VALUE '(SAPLQM03)RQM01-MBLPO',
   c_docto_compras  TYPE c LENGTH 22 VALUE '(SAPLQM03)RQM01-EBELN',
   c_itm_doc_comp   TYPE c LENGTH 22 VALUE '(SAPLQM03)RQM01-EBELP',
   c_nota_qm        TYPE tq80-qmart  VALUE 'Z1'                   .

FIELD-SYMBOLS: <fs_docto_material> TYPE rqm01-mblnr, " Nº documento de material
               <fs_itm_doc_mat>    TYPE rqm01-mblpo, " Item no documento do material
               <fs_docto_compras>  TYPE rqm01-ebeln, " Nº do documento de compras
               <fs_itm_doc_comp>   TYPE rqm01-ebelp. " Nº item do documento de compra

ASSIGN: (c_docto_material) TO <fs_docto_material>,
        (c_itm_doc_mat)    TO <fs_itm_doc_mat>   ,
        (c_docto_compras)  TO <fs_docto_compras> ,
        (c_itm_doc_comp)   TO <fs_itm_doc_comp>  .

CHECK <fs_docto_material> IS ASSIGNED
  AND <fs_itm_doc_mat>    IS ASSIGNED
  AND <fs_docto_compras>  IS ASSIGNED
  AND <fs_itm_doc_comp>   IS ASSIGNED
  AND i_viqmel-qmart = c_nota_qm.

IF <fs_docto_material> IS NOT INITIAL
   AND <fs_itm_doc_mat> IS INITIAL
  OR <fs_docto_compras> IS NOT INITIAL
   AND <fs_itm_doc_comp> IS INITIAL
  OR <fs_docto_material> IS INITIAL
   AND <fs_docto_compras> IS INITIAL.

* Informar documento do material ou documento de compras
  MESSAGE e003(ynqm).
ENDIF.
