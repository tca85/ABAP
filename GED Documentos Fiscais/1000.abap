* Gerenciamento Eletrônico de Documentos
* Documentos Fiscais - Visualização/Inclusão de documentos

PROCESS BEFORE OUTPUT.
  MODULE: status            ,
          bloquear_campos   ,
          desbloquear_campos.

  CALL SUBSCREEN sa_1001 INCLUDING sy-repid v_tela.

PROCESS AFTER INPUT.
  FIELD yged_gl_1000-typedoc   MODULE selecionar_tp_docto.
  FIELD yged_gl_1000-validfrom MODULE verificar_data_de.
  FIELD yged_gl_1000-validto   MODULE verificar_data_ate.
  FIELD yged_gl_1000-descrip   MODULE verificar_descricao.

  MODULE user_command.
  CALL SUBSCREEN sa_1001.