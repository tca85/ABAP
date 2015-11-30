* Tela de seleção da empresa e do período

PROCESS BEFORE OUTPUT.
  MODULE: status            ,
          bloquear_campos   ,
          desbloquear_campos.

  CALL SUBSCREEN sa_1001 INCLUDING sy-repid vl_tela.

PROCESS AFTER INPUT.
  FIELD: ybr_folha_1000-dt_doc_de  MODULE validar_data,
         ybr_folha_1000-dt_doc_ate MODULE validar_data.

  MODULE user_command_1000.
  CALL SUBSCREEN sa_1001.