*&---------------------------------------------------------------------*
*&  Include           ZXQQMU25
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(I_VIQMEL) LIKE  VIQMEL STRUCTURE  VIQMEL
*"             VALUE(I_TQ80)   LIKE  TQ80   STRUCTURE  TQ80
*"       TABLES
*"              T_PARTNER STRUCTURE  RQM05
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*                       ACHÉ LABORATÓRIOS                              *
*----------------------------------------------------------------------*
* Transação: QM01                                                      *
* Projeto  : CMOD - YNQM                                               *
* Ampliação: SMOD - QQMA0019 / SE37 - EXIT_SAPLIQS0_006                *
* Descrição: QM/PM/SM: parceiro default ao anexar uma nota             *
*----------------------------------------------------------------------*
* Objetivo : Incluir usuário de compras QM_COMPRAS como parceiro       *
* Módulo   : QM                                                        *
* Projeto  : Notas de QM (Não-conformidade no recebimento físico)      *
* Funcional: Meire Vicente Casale                                      *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  16.10.2013  #63782 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

CONSTANTS:
  c_comprador        TYPE tpar-parvw  VALUE 'EK'        ,
  c_coordenador_nota TYPE tpar-parvw  VALUE 'KU'        ,
  c_compras          TYPE usr02-bname VALUE 'QM_COMPRAS',
  c_nota_qm          TYPE tq80-qmart  VALUE 'Z1'        .

IF i_viqmel-qmart = c_nota_qm  .
*  t_partner-parvw = c_comprador.
*  t_partner-parnr = c_compras  .
*  APPEND t_partner.

  t_partner-parvw = c_coordenador_nota.
  t_partner-parnr = sy-uname          .
  APPEND t_partner.
ENDIF.
