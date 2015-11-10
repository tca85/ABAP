*&---------------------------------------------------------------------*
*&  Include           MYBR_GNRE_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'LEAVE' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'BTN_ADICIONAR'.
      PERFORM f_adicionar_nota.
    WHEN 'BTN_BUSCAR_NOTAS'.
      PERFORM f_buscar_notas.
    WHEN 'BTN_GERAR_XML'.
      PERFORM f_quebrar_arquivo_xml.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_1000  INPUT

*&---------------------------------------------------------------------*
*&      Module  verificar_nfe  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE verificar_nfe INPUT.
  PERFORM f_verificar_nfe
   USING ybr_gnre_1000-nfe
         ybr_gnre_1000-empresa
         ybr_gnre_1000-filial.
ENDMODULE.                 " verificar_nfe  INPUT

*&---------------------------------------------------------------------*
*&      Module  verificar_serie  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE verificar_serie INPUT.
  PERFORM f_verificar_serie
   USING ybr_gnre_1000-nfe
         ybr_gnre_1000-serie
         ybr_gnre_1000-empresa
         ybr_gnre_1000-filial.
ENDMODULE.                 " verificar_serie  INPUT

*&---------------------------------------------------------------------*
*&      Module  verificar_dt_venc  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE verificar_dt_venc INPUT.
  PERFORM f_verificar_data_venc
   USING ybr_gnre_1000-dt_vencimento.
ENDMODULE.                 " verificar_dt_venc  INPUT