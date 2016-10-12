REPORT ynfe_atualizar_ecc NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
*                 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                   *
*----------------------------------------------------------------------*
* Programa...: YNFE_ATUALIZAR_ECC                                      *
* Transação..: YNFE_ATUALIZAR_ECC                                      *
* Descrição..: Atualizar status no ECC após cancelamento feito na      *
*              J1BNFE "travar". Vai atualizar as tabelas J_1BNFE_EVENT *
*              e J_1BNFE_ACTIVE                                        *
* Tipo.......: ALV                                                     *
* Módulo.....: GRC                                                     *
* ABAP.......: Thiago Cordeiro Alves                                   *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  18.11.2015  #135221 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Variáveis tipo referência
*----------------------------------------------------------------------*
DATA:
  o_ecc    TYPE REF TO ycl_ecc,
  o_cx_ecc TYPE REF TO ycx_ecc.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
DATA:
  v_msg_erro TYPE string.

*----------------------------------------------------------------------*
* Tela de seleção
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE t000.
PARAMETERS: p_nfe TYPE /xnfe/id OBLIGATORY              . " Chave de acesso
SELECTION-SCREEN END OF BLOCK b0                        .

*----------------------------------------------------------------------*
* Initialization
*----------------------------------------------------------------------*
INITIALIZATION.
  t000 = 'Chave de acesso'.                                 "#EC NOTEXT

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
START-OF-SELECTION.

  TRY.
      CREATE OBJECT o_ecc TYPE ycl_ecc.

      WRITE: o_ecc->atualizar_status_nfe_ecc( p_nfe ).

    CATCH ycx_ecc INTO o_cx_ecc.
      v_msg_erro = o_cx_ecc->msg.
      MESSAGE v_msg_erro TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
  ENDTRY.