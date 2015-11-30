
PROCESS BEFORE OUTPUT.
  MODULE liste_initialisieren.
  LOOP AT extract WITH CONTROL
   tctrl_yapt001 CURSOR nextline.
    MODULE liste_show_liste.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE liste_exit_command AT EXIT-COMMAND.
  MODULE liste_before_loop.
  LOOP AT extract.
    MODULE liste_init_workarea.
    CHAIN.
      FIELD yapt001-bname .
      FIELD yapt001-arbpl .
      FIELD yapt001-werks .
      MODULE set_update_flag ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD vim_marked MODULE liste_mark_checkbox.
    CHAIN.
      FIELD yapt001-bname .
      FIELD yapt001-arbpl .
      MODULE liste_update_liste.
    ENDCHAIN.
  ENDLOOP.
  MODULE liste_after_loop.

PROCESS ON VALUE-REQUEST.
  FIELD: yapt001-arbpl MODULE carregar_sh_recursos.