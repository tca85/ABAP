*&---------------------------------------------------------------------*
*&  Include           ZXQQMU08
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_VIQMEL) LIKE  VIQMEL STRUCTURE  VIQMEL
*"     VALUE(I_TABCD)  LIKE  TQTABS-TABCD      OPTIONAL
*"     VALUE(I_SUBNR)  TYPE  N                 OPTIONAL
*"     VALUE(I_USCR)   LIKE  TQ80-USERSCR1     OPTIONAL
*"  EXPORTING
*"     VALUE(E_VIQMEL) LIKE  VIQMEL STRUCTURE VIQMEL
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*                      xxxxxxxxxxxxxxxxxx                              *
*----------------------------------------------------------------------*
* Transação: QM01                                                      *
* Projeto  : CMOD - YNQM                                               *
* Ampliação: SMOD - QQMA0001 / SE37 - EXIT_SAPMIWO0_009                *
* Descrição: QM/PM/SM: subtela do usuário para o cabeçalho da nota     *
*----------------------------------------------------------------------*
* Objetivo : Gravar o valor da subscreen 0100 'Tipo RDF' c/ RadioButton*
*            1 - Comunicação (preenchido por padrão)                   *
*            2 - Reprovação                                            *
* Módulo   : QM                                                        *
* Projeto  : Notas de QM (Não-conformidade no recebimento físico)      *
* Funcional: xxxxxxxxxxxxxxxxxxxxxxx                                   *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  22.10.2013  #63782 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

e_viqmel-yycomunicacao = viqmel-yycomunicacao.
e_viqmel-yyreprovacao  = viqmel-yyreprovacao .
