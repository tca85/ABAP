REPORT yqmr0045 NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
* Programa...: YQMR0045                                                *
* Transação..: YQMR0045                                                *
* Descrição..: LIMS - Modificar plano de controle (QP02)               *
* Tipo.......: Batch Input / Call Transaction / SHDB                   *
* Módulo.....: PP                                                      *
* Projeto....: LIMS                                                    *
* ABAP.......: Thiago Cordeiro Alves                                   *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  20.01.2016  #142490 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Variáveis de instância
*----------------------------------------------------------------------*
DATA:
  o_pc                TYPE REF TO ycl_plano_controle,
  o_cx_plano_controle TYPE REF TO ycx_plano_controle.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
DATA:
  v_msg_erro TYPE string.

*----------------------------------------------------------------------*
* Tela de seleção
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t001              .
PARAMETER: p_arquiv TYPE rlgrap-filename DEFAULT 'C:\Temp\' OBLIGATORY. "#EC NOTEXT
SELECTION-SCREEN END OF BLOCK b1                                      .

*----------------------------------------------------------------------*
* Initialization
*----------------------------------------------------------------------*
INITIALIZATION.
  t001 = 'Critérios de seleção'.                            "#EC NOTEXT

*----------------------------------------------------------------------*
* Process On Value Request
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_arquiv.
  p_arquiv = ycl_plano_controle=>selecionar_planilha( ).

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
START-OF-SELECTION.

  TRY.
      CREATE OBJECT o_pc TYPE ycl_plano_controle.

      o_pc->modificar_plano_controle( p_arquiv ).

      o_pc->exibir_alv_log_qp02( ).

    CATCH ycx_plano_controle INTO o_cx_plano_controle.
      v_msg_erro = o_cx_plano_controle->msg.
      MESSAGE v_msg_erro TYPE 'S' DISPLAY LIKE 'E'.
  ENDTRY.
