*&---------------------------------------------------------------------*
*&  Include           ZXQQMU07
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_VIQMEL) LIKE  VIQMEL        STRUCTURE VIQMEL OPTIONAL
*"     VALUE(I_AKTYP)  LIKE  T365-AKTYP    OPTIONAL
*"     VALUE(I_TABCD)  LIKE  TQTABS-TABCD  OPTIONAL
*"     VALUE(I_SUBNR)  TYPE  N             OPTIONAL
*"     VALUE(I_USCR)   LIKE  TQ80-USERSCR1 OPTIONAL
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*                       xxxxxxxxxxxxxxxxx                              *
*----------------------------------------------------------------------*
* Transação: QM01                                                      *
* Projeto  : CMOD - YNQM                                               *
* Ampliação: SMOD - QQMA0001 / SE37 - EXIT_SAPMIWO0_008                *
* Descrição: QM/PM/SM: subtela do usuário para o cabeçalho da nota     *
*----------------------------------------------------------------------*
* Objetivo : Retornar o valor da subscreen 0100 'Tipo RDF' RadioButtons*
*            1 - Comunicação (preenchido por padrão)                   *
*            2 - Reprovação                                            *
* Módulo   : QM                                                        *
* Projeto  : Notas de QM (Não-conformidade no recebimento físico)      *
* Funcional: xxxxxxxxxxxxxxxxxxxx                                      *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  22.10.2013  #63782 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

viqmel-yycomunicacao = viqmel-yycomunicacao.
viqmel-yyreprovacao  = viqmel-yyreprovacao .
