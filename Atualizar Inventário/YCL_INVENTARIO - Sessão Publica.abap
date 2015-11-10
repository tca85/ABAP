class YCL_INVENTARIO definition
  public
  final
  create public .

*"* public components of class YCL_INVENTARIO
*"* do not include other source files here!!!
public section.

  types:
    BEGIN OF ty_excel        ,
                matnr TYPE linv-matnr, " Material
                charg TYPE linv-charg, " Lote
                menge TYPE linv-menge, " Quantidade
              END OF ty_excel .
  types:
    BEGIN OF ty_log,
               lgnum TYPE linv-lgnum , " Nºdepósito/complexo de depósito
               ivnum TYPE linv-ivnum , " Nº documento de inventário
               matnr TYPE mara-matnr , " Material
               charg TYPE linv-charg , " Lote
               menge TYPE linv-menge , " Quantidade
               stat  TYPE yol_status , " Status
               text  TYPE t100-text  , " Mensagem
             END OF ty_log .
  types:
    BEGIN OF ty_inventario.
            INCLUDE TYPE e1linvx.
    TYPES: END OF ty_inventario .
  types:
    tp_excel      TYPE STANDARD TABLE OF ty_excel      WITH DEFAULT KEY .
  types:
    tp_inventario TYPE STANDARD TABLE OF ty_inventario WITH DEFAULT KEY .
  types:
    tp_log        TYPE STANDARD TABLE OF ty_log        WITH DEFAULT KEY .

  class-data T_EXCEL type TP_EXCEL .
  class-data T_INVENTARIO type TP_INVENTARIO .
  class-data T_LOG type TP_LOG .
  data DEPOSITO type LINV-LGNUM .
  data DOC_INVENTARIO type LINV-IVNUM .

  methods ATUALIZAR_INVENTARIO
    changing
      !EX_T_INVENTARIO type TP_INVENTARIO
      !EX_T_LOG type TP_LOG
    raising
      YCX_OL .
  methods VALIDAR_EXCEL
    changing
      !EX_T_EXCEL type TP_EXCEL
      !EX_T_INVENTARIO type TP_INVENTARIO
      !EX_T_LOG type TP_LOG
    raising
      YCX_OL .
  methods VALIDAR_DOC_INVENTARIO
    importing
      !IM_DEPOSITO type LINV-LGNUM
      !IM_DOC_INVENTARIO type LINV-IVNUM
    raising
      YCX_OL .
  methods SALVAR_LOG
    importing
      !IM_T_LOG type TP_LOG .