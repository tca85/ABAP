*&---------------------------------------------------------------------**&  Include           MY_NQM_PAI*&---------------------------------------------------------------------**&---------------------------------------------------------------------**&      Module  user_command  INPUT*&---------------------------------------------------------------------**       text*----------------------------------------------------------------------*MODULE user_command INPUT.  CASE ok_code.    WHEN 'BACK' OR 'LEAVE' OR 'CANCEL'.      LEAVE TO SCREEN 0.    WHEN 'BTN_EXEC'.      CASE sy-dynnr.        WHEN 1000.          PERFORM f_selecionar_notas_qm.        WHEN 1002.          PERFORM f_verificar_sub_contratacao.      ENDCASE.    WHEN 'BTN_ACAOI'.      CALL TRANSACTION c_qm12.    WHEN 'BTN_AVAL'.      SET PARAMETER ID 'LIF' FIELD space.      SET PARAMETER ID 'MAT' FIELD space.      CALL TRANSACTION 'YNQM_REPORT'.    WHEN 'BTN_NQM'.      CHECK sy-dynnr <> 1002.      PERFORM f_limpar_tela_1002.      CALL SCREEN 1002.  ENDCASE.  CLEAR ok_code.ENDMODULE.                 " user_command  INPUT*&---------------------------------------------------------------------**&      Module  exit_1001  INPUT*&---------------------------------------------------------------------**       text*----------------------------------------------------------------------*MODULE exit_1001 INPUT.  CASE ok_code.    WHEN 'ENT1' OR 'EXIT'.      LEAVE TO SCREEN 0.  ENDCASE.ENDMODULE.                 " exit_1001  INPUT*----------------------------------------------------------------------**  MODULE validar_nqm INPUT*----------------------------------------------------------------------***----------------------------------------------------------------------*MODULE validar_nqm INPUT.  PERFORM f_verificar_range_nqm.ENDMODULE.                    "validar_nqm INPUT*&---------------------------------------------------------------------**&      Module  validar_data  INPUT*&---------------------------------------------------------------------**       text*----------------------------------------------------------------------*MODULE validar_data INPUT.  PERFORM f_verificar_range_data.ENDMODULE.                 " validar_data  INPUT*----------------------------------------------------------------------**  MODULE limpar_campo INPUT*----------------------------------------------------------------------***----------------------------------------------------------------------*MODULE limpar_campo INPUT.  CHECK ynqm_1000-loc_nc IS INITIAL.  CLEAR qpct-kurztext.ENDMODULE.                    "limpar_campo INPUT*----------------------------------------------------------------------**  MODULE carregar_sh_local INPUT*----------------------------------------------------------------------***----------------------------------------------------------------------*MODULE carregar_sh_local INPUT.  PERFORM f_sel_search_help_local.ENDMODULE.                    "carregar_sh_local INPUT*----------------------------------------------------------------------**  MODULE validar_autor INPUT*----------------------------------------------------------------------***----------------------------------------------------------------------*MODULE validar_autor INPUT.  PERFORM f_montar_range_autor.ENDMODULE.                    "validar_autor INPUT*----------------------------------------------------------------------**  MODULE validar_fornec INPUT*----------------------------------------------------------------------***----------------------------------------------------------------------*MODULE validar_fornec INPUT.  PERFORM f_montar_range_fornec.ENDMODULE.                    "validar_fornec INPUT*&---------------------------------------------------------------------**&      Module  validar_data  INPUT*&---------------------------------------------------------------------**       text*----------------------------------------------------------------------*MODULE validar_lote INPUT.  CASE sy-dynnr.    WHEN 1000.      PERFORM f_montar_range_lote.    WHEN 1002.      PERFORM f_verificar_lote.  ENDCASE.ENDMODULE.                 " validar_data  INPUT*----------------------------------------------------------------------**  MODULE validar_material INPUT*----------------------------------------------------------------------***----------------------------------------------------------------------*MODULE validar_material INPUT.  PERFORM f_montar_range_material.ENDMODULE.                    "validar_material INPUT*----------------------------------------------------------------------**  MODULE validar_material INPUT*----------------------------------------------------------------------***----------------------------------------------------------------------*MODULE validar_centro INPUT.  PERFORM f_montar_range_centro.ENDMODULE.                    "validar_material INPUT