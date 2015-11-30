* Gerenciamento Eletrônico de Documentos
* Cadastro de Clientes - Visualização/Inclusão de documentos

PROCESS BEFORE OUTPUT.
  MODULE status_1000.
  CALL SUBSCREEN sa_1001 INCLUDING sy-repid vl_tela.

PROCESS AFTER INPUT.
  FIELD yged_ar_1000-cliente MODULE selecionar_cliente.
  FIELD yged_ar_1000-typed   MODULE selecionar_tp_docto.
  MODULE user_command_1000.
  CALL SUBSCREEN sa_1001.