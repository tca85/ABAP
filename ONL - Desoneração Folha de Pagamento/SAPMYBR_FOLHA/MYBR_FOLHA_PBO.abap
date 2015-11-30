*----------------------------------------------------------------------*
* Include mybr_folha_pbo.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  status_1000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status OUTPUT.
  IF sy-dynnr = 1000.
    FREE tl_fcode.
  ENDIF.

* Botões voltar, cancelar, sair
  SET PF-STATUS 'S1000' EXCLUDING tl_fcode.

* Desoneração da folha de pagamento (Plano Brasil Maior)
  SET TITLEBAR 'T1000'.
ENDMODULE.                 " status_1000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  bloquear_campos  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE bloquear_campos OUTPUT.
  PERFORM f_bloquear_campos.
ENDMODULE.                 " bloquear_campos  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  bloquear_campos  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE desbloquear_campos OUTPUT.
  PERFORM f_desbloquear_campos.
ENDMODULE.                 " desbloquear_campos  OUTPUT