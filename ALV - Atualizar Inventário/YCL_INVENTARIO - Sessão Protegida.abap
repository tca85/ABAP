*"* protected components of class YCL_INVENTARIO
*"* do not include other source files here!!!
protected section.

  types:
    BEGIN OF ty_linv                      ,
     lgnum TYPE linv-lgnum                , " Nºdepósito/complexo de depósito
     ivnum TYPE linv-ivnum                , " Nº documento de inventário
     ivpos TYPE linv-ivpos                , " Nº item no documento de inventário
     lgtyp TYPE linv-lgtyp                , " Tipo de depósito
     lgpla TYPE linv-lgpla                , " Posição no depósito
     plpos TYPE linv-plpos                , " Item na posição do depósito
     matnr TYPE linv-matnr                , " Nº do material
     werks TYPE linv-werks                , " Centro
     charg TYPE linv-charg                , " Número do lote
    END OF ty_linv .
  types:
    BEGIN OF ty_ol_empresa                ,
     werks    TYPE ymm_ol_empresa-werks   , " Centro
     lgort_da TYPE ymm_ol_empresa-lgort_da, " Depósito Acabado
     lgort_dp TYPE ymm_ol_empresa-lgort_dp, " Depósito Promocional
    END OF ty_ol_empresa .
  types:
    BEGIN OF ty_linp                      ,
     lgnum TYPE linp-lgnum                , " Nºdepósito/complexo de depósito
     ivnum TYPE linp-ivnum                , " Nº documento de inventário
     lgpla TYPE linp-lgpla                , " Posição no depósito
     idatu TYPE linp-idatu                , " Data do inventário
    END OF ty_linp .
  types:
    BEGIN OF ty_mch1                      ,
     matnr TYPE mch1-matnr                , " Nº do material
     charg TYPE mch1-charg                , " Lote
     hsdat TYPE mch1-hsdat                , " Data de produção
     vfdat TYPE mch1-vfdat                , " Data do vencimento
    END OF ty_mch1 .
  types:
    BEGIN OF ty_mara                      ,
     matnr TYPE mara-matnr                , " Nº do material
     mtart TYPE mara-mtart                , " Tipo de material
    END OF ty_mara .
  types:
    BEGIN OF ty_lqua                      ,
     lgnum TYPE lqua-lgnum                , " Nºdepósito/complexo de depósito
     lqnum TYPE lqua-lqnum                , " Quanto
     matnr TYPE lqua-matnr                , " Nº do material
     werks TYPE lqua-werks                , " Centro
     charg TYPE lqua-charg                , " Número do lote
     lgtyp TYPE lqua-lgtyp                , " Tipo de depósito
     lgpla TYPE lqua-lgpla                , " Posição no depósito
     bestq TYPE lqua-bestq                , " Tipo de estoque no sistema de administração de depósito
   END OF ty_lqua .