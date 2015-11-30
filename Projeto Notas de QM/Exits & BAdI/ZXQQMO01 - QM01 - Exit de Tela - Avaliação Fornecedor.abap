*----------------------------------------------------------------------*
*                       xxxxxxxxxxxxxxxxx                              *
*----------------------------------------------------------------------*
* Transação: QM01 / QM02 / QM03                                        *
* Projeto  : CMOD - YNQM                                               *
* Ampliação: SMOD - QQMA0001 - Exit de Tela (SAPLIQS0)                 *
* Descrição: QM/PM/SM: subtela do usuário para o cabeçalho da nota     *
*----------------------------------------------------------------------*
* Objetivo : Subtela - Tipo de RDF / Avaliação de Fornecedor           *
* Módulo   : QM                                                        *
* Projeto  : Notas de QM (Não-conformidade no recebimento físico)      *
* Funcional: xxxxxxxxxxxxxxxxxxxx                                      *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  27.01.2014  #63782 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZXQQMO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  CONSTANTS c_desabilitar_campo TYPE c LENGTH 01 VALUE '0'.

  CASE sy-tcode.
    WHEN 'QM01'.
      LOOP AT SCREEN.
        IF screen-group1 = 'Q2'.
          screen-active = c_desabilitar_campo.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

    WHEN 'QM03'.
      LOOP AT SCREEN.
        IF screen-group1 = 'Q1'.
          screen-input = c_desabilitar_campo.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
  ENDCASE.

ENDMODULE.                 " STATUS_0100  OUTPUT