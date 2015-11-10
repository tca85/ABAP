*&---------------------------------------------------------------------*
*&  Include           MYGED_GL_PAI
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'LEAVE' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'BTN_NOVO'.
      PERFORM f_inserir_novo_docto.
    WHEN 'BTN_ARQUIVO'.
      PERFORM f_carregar_arquivo.
    WHEN 'BTN_GRAVAR'.
      PERFORM f_salvar_arquivo_dms.
*   O nome do botão foi dado no campo "Código de Função" da Sub-Tela 1001 / 1003
    WHEN 'PB_1001_1'. " Comprimir
      v_tela = c_sub_comprimir.                             " 1003
    WHEN 'PB_1001_2'. " Descomprimir
      v_tela = c_sub_descomprimir.                          " 1001
      PERFORM f_carregar_doctos_obrigatorios.
  ENDCASE.

  CLEAR ok_code.
ENDMODULE.                 " user_command  INPUT

*&---------------------------------------------------------------------*
*&      Module  selecionar_tp_docto  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE selecionar_tp_docto INPUT.
  PERFORM f_selecionar_tp_docto
   USING yged_gl_1000-typedoc.
ENDMODULE.                 " selecionar_tp_docto  INPUT

*----------------------------------------------------------------------*
*  MODULE verificar_data_de INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE verificar_data_de INPUT.
  READ TABLE t_botoes
  TRANSPORTING NO FIELDS
  WITH KEY salv = 'X'.

  CHECK sy-subrc = 0.

  IF yged_gl_1000-validfrom IS INITIAL.
    MESSAGE 'Informe a data inicial de validade'(012) TYPE 'E'.
  ENDIF.
ENDMODULE.                    "verificar_data_de INPUT

*----------------------------------------------------------------------*
*  MODULE verificar_data_ate INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE verificar_data_ate INPUT.
  READ TABLE t_botoes
  TRANSPORTING NO FIELDS
  WITH KEY salv = 'X'.

  CHECK sy-subrc = 0.

  IF yged_gl_1000-validto IS INITIAL.
    MESSAGE 'Informe a data final de validade'(013) TYPE 'E'.
  ENDIF.
ENDMODULE.                    "verificar_data_ate INPUT

*----------------------------------------------------------------------*
*  MODULE verificar_descricao INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE verificar_descricao INPUT.
  READ TABLE t_botoes
  TRANSPORTING NO FIELDS
  WITH KEY salv = 'X'.

  CHECK sy-subrc = 0.

  IF yged_gl_1000-descrip IS INITIAL.
    MESSAGE 'Informe a descrição'(014) TYPE 'E'.
  ENDIF.
ENDMODULE.                    "verificar_descricao INPUT