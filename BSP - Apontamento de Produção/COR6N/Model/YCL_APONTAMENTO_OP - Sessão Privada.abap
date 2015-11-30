*"* private components of class YCL_APONTAMENTO_OP
*"* do not include other source files here!!!
PRIVATE SECTION.

  TYPES:
    BEGIN OF ty_caufv         ,
    aufnr TYPE caufv-aufnr  , " Nº ordem
    aufpl TYPE caufv-aufpl  , " Nº de roteiro de operações na ordem
    bukrs TYPE caufv-bukrs  , " Empresa
    werks TYPE caufv-werks  , " Centro
    gsber TYPE caufv-gsber  , " Divisão
    auart TYPE caufv-auart  , " Tipo de ordem
    gamng TYPE caufv-gamng  , " Quantidade total de ordens
    gmein TYPE caufv-gmein  , " Unidade de medida básica
    igmng TYPE caufv-igmng  , " Quantidade produzida confirmada de confirm.p/ordem
  END OF ty_caufv .
  TYPES:
    BEGIN OF ty_afvc          ,
    aufpl TYPE afvc-aufpl   , " Nº de roteiro de operações na ordem
    aplzl TYPE afvc-aplzl   , " Numerador geral da ordem
    vornr TYPE afvc-vornr   , " Nº operação
    plnty TYPE afvc-plnty   , " Tipo de roteiro
    plnnr TYPE afvc-plnnr   , " Chave do grupo de listas de tarefas
    plnkn TYPE afvc-plnkn   , " Nº nó de lista de tarefas
    ltxa1 TYPE afvc-ltxa1   , " Txt.breve operação
    lek04 TYPE afvc-lek04   , " Código: nenhuma atividade restante esperada
    phseq TYPE afvc-phseq   , " Destinatário da receita de controle
  END OF ty_afvc .
  TYPES:
    BEGIN OF ty_mcafvgv       ,
    aufnr TYPE mcafvgv-aufnr, " Nº ordem
    aufpl TYPE mcafvgv-aufpl, " Nº de roteiro de operações na ordem
    aplzl TYPE mcafvgv-aplzl, " Numerador geral da ordem
    arbpl TYPE mcafvgv-arbpl, " Centro de trabalho
    mgvrg TYPE mcafvgv-mgvrg, " Quantidade da operação
    meinh TYPE mcafvgv-meinh, " Unidade de Medida
  END OF  ty_mcafvgv .
  TYPES:
    BEGIN OF ty_plpo          ,
    plnty TYPE plpo-plnty   , " Tipo de roteiro
    plnnr TYPE plpo-plnnr   , " Chave do grupo de listas de tarefas
    plnkn TYPE plpo-plnkn   , " Nº nó de lista de tarefas
    vgw03 TYPE plpo-vgw03   , " Custo HH preparação
    vgw04 TYPE plpo-vgw04   , " Custo HH máquina
  END OF ty_plpo .

  CLASS-DATA apto_op TYPE REF TO ycl_apontamento_op .
  CONSTANTS c_acesso_total TYPE c VALUE '*'.                "#EC NOTEXT
  CONSTANTS c_apto_final TYPE string VALUE 'Final'.         "#EC NOTEXT
  CONSTANTS c_apto_parcial TYPE string VALUE 'Parcial'.     "#EC NOTEXT
  CONSTANTS c_apto_total TYPE string VALUE 'Total'.         "#EC NOTEXT
  CONSTANTS c_estornar_apto TYPE string VALUE 'Estornar'.   "#EC NOTEXT
  CONSTANTS c_folha_pi TYPE tc52-phseq VALUE '01'.          "#EC NOTEXT
  CONSTANTS c_ordem_processo TYPE auftyp VALUE 40.          "#EC NOTEXT
  CONSTANTS c_sem_apto TYPE string VALUE 'Operação sem apontamento'. "#EC NOTEXT
  DATA ordem_processo TYPE caufv-aufnr .
  DATA t_operacao TYPE tp_operacao .
  DATA t_total_operacao TYPE tp_total_operacao .
  DATA w_apontamento TYPE ty_apontamento .
  DATA w_cabecalho_op TYPE ty_cabecalho_op .

  METHODS constructor
    RAISING
      ycx_apo .