*"* private components of class YCL_MATERIAL
*"* do not include other source files here!!!
PRIVATE SECTION.

  DATA t_excel TYPE tp_excel .
  DATA t_caracteristicas TYPE tp_caracteristica .

  METHODS atualizar_classe_classificacao
    IMPORTING
      !im_t_ausp TYPE tp_ausp
      !im_t_makt TYPE tp_makt
    RETURNING
      value(ex_t_alv_cl_class) TYPE tp_alv_cl_classif
    RAISING
      ycx_material .
  METHODS converter_data_ponto_flutuante
    IMPORTING
      !im_valor TYPE ausp-atwrt
    RETURNING
      value(ex_valor_convertido) TYPE ausp-atflv .
  METHODS converter_ponto_flutuante_data
    IMPORTING
      !im_valor TYPE ausp-atflv
    RETURNING
      value(ex_valor_convertido) TYPE ausp-atwrt .
  METHODS criar_classe_classificacao
    IMPORTING
      !im_t_excel TYPE tp_excel
      !im_t_makt TYPE tp_makt
    RETURNING
      value(ex_t_alv_cl_class) TYPE tp_alv_cl_classif .
  CLASS-METHODS inibir_campos_alv_caract
    RETURNING
      value(ex_t_campo_alv) TYPE tp_campo_alv .