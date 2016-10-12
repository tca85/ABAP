*----------------------------------------------------------------------*
*       CLASS YCL_MATERIAL  DEFINITIO
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS ycl_material DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

*"* public components of class YCL_MATERIAL
*"* do not include other source files here!!!
  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_excel         ,
                     matnr TYPE mara-matnr  , " Material
                     atwrt TYPE ausp-atwrt  , " Valor da característica
                  END OF ty_excel .
    TYPES:
      BEGIN OF ty_campo_alv     ,
                     nome TYPE lvc_fname    , " Nome da coluna do ALV
                  END OF  ty_campo_alv .
    TYPES:
      BEGIN OF ty_alv_cl_classif,
                     matnr TYPE mara-matnr  , " Nº do material
                     maktx TYPE makt-maktx  ,
                     klart TYPE ksml-klart  , " Tipo de classe
                     imerk TYPE ksml-imerk  , " Característica interna
                     vlold TYPE yvl_old     , " Valor Antigo
                     vlnew TYPE yvl_new     , " Valor novo
                     erro  TYPE ymsg_erro   ,
                  END OF ty_alv_cl_classif .
    TYPES:
      BEGIN OF ty_caracteristica,
                     imerk TYPE yimerk      , " Característica interna
                     atnam TYPE cabn-atnam  , " Nome da característica
                     atbez TYPE cabnt-atbez , " Denominação caract
                     klart TYPE ksml-klart  , " Tipo de classe
                     atfor TYPE cabn-atfor  , " Categoria de dados da característica
                     adzhl TYPE cabn-adzhl  , " Contador interno p/arquivo objeto mediante controle modifs.
                  END OF ty_caracteristica .
    TYPES:
      BEGIN OF ty_makt       ,
          matnr TYPE mara-matnr,
          maktx TYPE makt-maktx,
        END OF ty_makt .
    TYPES:
      tp_excel          TYPE STANDARD TABLE OF ty_excel               WITH DEFAULT KEY .
    TYPES:
      tp_makt           TYPE STANDARD TABLE OF ty_makt                WITH DEFAULT KEY .
    TYPES:
      tp_um_proporc     TYPE STANDARD TABLE OF yach_l_um_proporc_prod WITH DEFAULT KEY .
    TYPES:
      tp_bapiret2       TYPE STANDARD TABLE OF bapiret2               WITH DEFAULT KEY .
    TYPES:
      tp_campo_alv      TYPE STANDARD TABLE OF ty_campo_alv           WITH DEFAULT KEY .
    TYPES:
      tp_caracteristica TYPE STANDARD TABLE OF ty_caracteristica      WITH DEFAULT KEY .
    TYPES:
      tp_alv_cl_classif TYPE STANDARD TABLE OF ty_alv_cl_classif      WITH DEFAULT KEY .
    TYPES:
      tp_ausp           TYPE STANDARD TABLE OF ausp                   WITH DEFAULT KEY .

    CONSTANTS c_classe_material TYPE tcla-klart VALUE '001'. "#EC NOTEXT
    CONSTANTS c_pt_br TYPE c VALUE 'P'.                     "#EC NOTEXT

    METHODS caracteristicas_internas_f4
      IMPORTING
        !im_classe_material TYPE ksml-klart
      RETURNING
        value(ex_caracteristica) TYPE ksml-imerk .
    METHODS exibir_alv_cl_classificacao
      IMPORTING
        !t_alv_cl_class TYPE tp_alv_cl_classif .
    METHODS exibir_tabela_como_search_help
      IMPORTING
        !im_t_campo_alv TYPE tp_campo_alv OPTIONAL
      EXPORTING
        value(ex_linhas_selecionadas) TYPE salv_t_row
      CHANGING
        !im_tabela TYPE STANDARD TABLE .
    METHODS get_caracteristicas_internas
      IMPORTING
        !im_classe_material TYPE ksml-klart
        !im_caracteristica TYPE ksml-imerk OPTIONAL
      RETURNING
        value(ex_t_caracteristica) TYPE tp_caracteristica .
    CLASS-METHODS get_dsc_tipo_classe
      IMPORTING
        !im_classe_material TYPE ksml-klart
      RETURNING
        value(ex_descricao) TYPE arttxt .
    METHODS importar_excel
      IMPORTING
        !im_nome_arquivo TYPE localfile
      RAISING
        ycx_material .
    METHODS modificar_classe_classificacao
      RETURNING
        value(ex_t_alv_cl_class) TYPE tp_alv_cl_classif
      RAISING
        ycx_material .
    METHODS modificar_um_proporcional
      IMPORTING
        !im_material TYPE rmmg1-matnr
        !im_t_um_proporc TYPE tp_um_proporc
      EXPORTING
        !ex_t_bapiret2 TYPE tp_bapiret2
      RAISING
        ycx_material .
    CLASS-METHODS selecionar_planilha
      RETURNING
        value(ex_nome_arquivo) TYPE localfile .
    METHODS validar_caracteristica_interna
      IMPORTING
        !im_classe_material TYPE ksml-klart
        !im_caracteristica TYPE ksml-imerk
      RAISING
        ycx_material .
    METHODS verificar_extensao_arquivo
      IMPORTING
        value(im_nome_arquivo) TYPE localfile
      RAISING
        ycx_material .