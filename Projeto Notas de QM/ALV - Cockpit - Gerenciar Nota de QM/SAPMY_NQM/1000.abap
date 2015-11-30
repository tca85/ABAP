* Gerenciamento de Notas de QM

PROCESS BEFORE OUTPUT.
  MODULE: status        ,
          pre_validacoes.

PROCESS AFTER INPUT.
  FIELD: ynqm_1000-nqm_de     MODULE validar_nqm     ,
         ynqm_1000-dt_de      MODULE validar_data    ,
         ynqm_1000-dt_ate     MODULE validar_data    ,
         ynqm_1000-loc_nc     MODULE limpar_campo    ,
         ynqm_1000-fornec     MODULE validar_fornec  ,
         ynqm_1000-matnr_de   MODULE validar_material,
         ynqm_1000-matnr_ate  MODULE validar_material,
         ynqm_1000-centro_de  MODULE validar_centro  ,
         ynqm_1000-centro_ate MODULE validar_centro  ,
         ynqm_1000-lote_de    MODULE validar_lote    ,
         ynqm_1000-lote_ate   MODULE validar_lote    ,
         ynqm_1000-autor      MODULE validar_autor   .

  MODULE user_command.

PROCESS ON VALUE-REQUEST.
  FIELD ynqm_1000-loc_nc MODULE carregar_sh_local.
