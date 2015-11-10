* Após o usuário selecionar a empresa, período e mandar buscar
* carrega a tela com dados do Brasil Maior

PROCESS BEFORE OUTPUT.
  MODULE: bloquear_campos   ,
          desbloquear_campos.

PROCESS AFTER INPUT.
  FIELD: ybr_folha_1000-inss_emp MODULE validar_inss.
  MODULE user_command_1001.