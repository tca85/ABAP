*----------------------------------------------------------------------*
*INCLUDE MYBR_FOLHA_PAI .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  user_command_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'LEAVE' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'BTN_BUSCA_DADOS'.
      PERFORM f_buscar_dados.
  ENDCASE.
ENDMODULE.                 " user_command_1000  INPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_1001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1001 INPUT.
  CASE ok_code.
    WHEN 'BTN_ALV_VEND_TOT'.
      PERFORM f_exibir_alv_total_ncm.
    WHEN 'BTN_ALV_REVEND'.
      PERFORM f_exibir_alv_total_revendas.
    WHEN 'BTN_WEB_INSS'.
      PERFORM f_obter_webservice_inss_rh.
    WHEN 'BTN_CALCULAR'.
      PERFORM f_calcular_inss_pagar.
    WHEN 'BTN_SALVAR'.
      PERFORM f_salvar_resultados.
    WHEN 'BTN_IMPRIMIR'.
      PERFORM f_imprimir_dados_gerados.
    WHEN 'BTN_SPED'.
      PERFORM f_gerar_sped.
    WHEN 'BTN_NOVO'.
      PERFORM f_novo_periodo_empresa.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.                 " user_command_1001  INPUT

*&---------------------------------------------------------------------*
*&      Module  validar_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validar_data INPUT.
  PERFORM f_verificar_data_informada.
ENDMODULE.                 " validar_data  INPUT

*&---------------------------------------------------------------------*
*&      Module  validar_inss  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validar_inss INPUT.
  PERFORM f_verificar_inss_empresa.
ENDMODULE.                 " validar_inss  INPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_1010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1010 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'LEAVE' OR 'CANCEL'.
      LEAVE TO SCREEN 1000. " tela de seleção
  ENDCASE.
ENDMODULE.                 " user_command_1010  INPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_1020  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1020 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'LEAVE' OR 'CANCEL'.
      LEAVE TO SCREEN 1000.
  ENDCASE.
ENDMODULE.                 " user_command_1020  INPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_1011  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1011 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'LEAVE' OR 'CANCEL'.

      CASE vl_tela_alv.

*       ALV com Total por código de controle (NCM)
        WHEN c_tela_alv_vendas.
          PERFORM f_exibir_alv_total_ncm.

*       ALV - Total por revendas
        WHEN c_tela_alv_revendas.
          PERFORM f_exibir_alv_total_revendas.
      ENDCASE.

  ENDCASE.
ENDMODULE.                 " user_command_1011  INPUT