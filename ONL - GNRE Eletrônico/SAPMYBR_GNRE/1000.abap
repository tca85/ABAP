
PROCESS BEFORE OUTPUT.
  MODULE status_1000.
  MODULE bloquear_campos.

PROCESS AFTER INPUT.
  FIELD: ybr_gnre_1000-nfe           MODULE verificar_nfe    ,
         ybr_gnre_1000-serie         MODULE verificar_serie  ,
         ybr_gnre_1000-dt_vencimento MODULE verificar_dt_venc.

  MODULE user_command_1000.