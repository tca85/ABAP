*&---------------------------------------------------------------------*
*&  Include           MYBR_GNRE_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  status_1000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_1000 OUTPUT.

* Status da tela 1000 (bot�es voltar, cancelar, sair)
  SET PF-STATUS 'S1000'.

* T�tulo da tela 1000 - GNRE Eletr�nico
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