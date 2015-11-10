*&---------------------------------------------------------------------*
*&  Include           MYGED_GL_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  status OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status OUTPUT.
* Status da tela 1000 (botões voltar, cancelar, sair)
  SET PF-STATUS 'S1000'.

* Título da tela 1000 - GED - Cadastro de Clientes
  SET TITLEBAR 'T1000'.
ENDMODULE.                 " status  OUTPUT

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