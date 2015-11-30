* Enviar RDF: selecionar parceiros

PROCESS BEFORE OUTPUT.
  MODULE status_2001.
  MODULE init_2001.
  LOOP AT g_partner_tab WITH CONTROL partner
     CURSOR partner-current_line.
  ENDLOOP.


PROCESS AFTER INPUT.
  MODULE exit_2001 AT EXIT-COMMAND.

  LOOP AT g_partner_tab.
    FIELD g_partner_tab-mark MODULE modify_tab ON REQUEST.
  ENDLOOP.

  MODULE user_command_2001.