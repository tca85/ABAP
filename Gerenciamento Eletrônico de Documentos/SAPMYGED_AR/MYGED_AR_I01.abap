*----------------------------------------------------------------------*
***INCLUDE MYGED_AR_I01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

* Eventos de tela (clicks)

MODULE user_command_1000 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'LEAVE' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'BTN_ARQUIVO'.
      PERFORM f_carregar_arquivo.
    WHEN 'BTN_GRAVAR'.
      PERFORM f_salvar_arquivo_dms.

* O nome do evento foi dado no Status GUI (S100) na tecla de função F2
    WHEN 'PICK'.
      PERFORM f_carregar_xd03
       USING yged_ar_1000-cliente.

* O nome do botão foi dado no campo "Código de Função" da Sub-Tela 1001 / 1003
    WHEN 'PB_1001_1'. " Comprimir
      vl_tela = c_sub_comprimir.                            " 1003
    WHEN 'PB_1001_2'. " Descomprimir
      vl_tela = c_sub_descomprimir.                         " 1001
      PERFORM f_carregar_doctos_obrigatorios.
  ENDCASE.

  CLEAR ok_code.
ENDMODULE.                 " USER_COMMAND_1000  INPUT

*----------------------------------------------------------------------*
*  MODULE selecionar_cliente
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE selecionar_cliente.
  PERFORM f_selecionar_cliente
   USING yged_ar_1000-cliente.
ENDMODULE.                    "selecionar_cliente

*&---------------------------------------------------------------------*
*&      Module  SELECIONAR_TP_DOCTO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE selecionar_tp_docto INPUT.
  PERFORM f_selecionar_tp_docto
   USING yged_ar_1000-typed.
ENDMODULE.                 " SELECIONAR_TP_DOCTO  INPUT