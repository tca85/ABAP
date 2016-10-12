*"* private components of class YCL_PLANO_CONTROLE
*"* do not include other source files here!!!
PRIVATE SECTION.

  DATA t_excel_qp02 TYPE tp_excel_qp02 .
  DATA t_alv_log_qp02 TYPE tp_alv_log_qp02 .
  DATA t_materiais_qp02 TYPE tp_material_qp02 .
  DATA t_lista_tarefas_qp02 TYPE tp_lista_tarefas_qp02 .
  DATA t_operacoes_qp02 TYPE tp_operacoes_qp02 .
  DATA t_caracteristicas_ctrl_qp02 TYPE tp_caracteristicas_ctrl_qp02 .

  METHODS converter_float_decimal
    IMPORTING
      !float TYPE f
    RETURNING
      value(decimal) TYPE esecompavg .
  METHODS importar_excel
    IMPORTING
      !im_nome_arquivo TYPE localfile
    RETURNING
      value(t_excel_qp02) TYPE tp_excel_qp02
    RAISING
      ycx_plano_controle .
  METHODS parse_excel_qp02
    IMPORTING
      !im_nome_arquivo TYPE localfile
    RAISING
      ycx_plano_controle .
  METHODS verificar_extensao_arquivo
    IMPORTING
      !im_nome_arquivo TYPE localfile
    RAISING
      ycx_plano_controle .