*----------------------------------------------------------------------*
*       CLASS YCL_PLANO_CONTROLE  DEFINITIO
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS ycl_plano_controle DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

*"* public components of class YCL_PLANO_CONTROLE
*"* do not include other source files here!!!
  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_mapl                 ,
                                    plnty TYPE mapl-plnty          , " Tipo de roteiro
                                    plnnr TYPE mapl-plnnr          , " Chave do grupo de listas de tarefas
                                    plnal TYPE mapl-plnal          , " Numerador de grupos
                                    datuv TYPE mapl-datuv          , " Data início validade
                                    loekz TYPE mapl-loekz          , " Código de eliminação
                                    matnr TYPE mapl-matnr          , " Nº do material
                                    werks TYPE mapl-werks          , " Centro
                                  END OF ty_mapl .
    TYPES:
      BEGIN OF ty_alv                  ,
                                    matnr      TYPE mapl-matnr     , " Nº do material
                                    plnnr      TYPE mapl-plnnr     , " Chave do grupo de listas de tarefas
                                    plnal      TYPE mapl-plnal     , " Numerador de grupos
                                    werks      TYPE mapl-werks     , " Centro
                                    ktext      TYPE plko-ktext     , " TxtBrv.LstTaref.
                                    verwe      TYPE plko-verwe     , " Utilização do plano
                                    statu      TYPE plko-statu     , " Status do plano
                                    losvn      TYPE plko-losvn     , " Tamanho de lote desde
                                    losbs      TYPE plko-losbs     , " Grupo de planejamento/departamento responsável
                                    plnme      TYPE plko-plnme     , " Unidade de medida da lista de tarefas
                                    vornr      TYPE plpo-vornr     , " Nº operação
                                    steus      TYPE plpo-steus     , " Chave de controle
                                    ltxa1      TYPE plpo-ltxa1     , " Txt.breve operação
                                    merknr     TYPE plmk-merknr    , " Nº característica de controle
                                    verwmerkm  TYPE plmk-verwmerkm , " Carac.mestre contr.
                                    kurztext   TYPE plmkb-kurztext , " Texto breve para característica de controle
                                    pmethode   TYPE plmk-pmethode  , " Método de controle
                                    sollwert   TYPE ysollwert      , " Valor teórico para uma característica quantitativa
                                    toleranzun TYPE ytoleranzun    , " Limite inferior de tolerância
                                    toleranzob TYPE ytoleranzob    , " Valor limite superior
                                    stichprver TYPE plmk-stichprver, " Processo de amostra na característica de controle
                                    probemgeh  TYPE plmk-probemgeh , " Unidade de medida da amostra
                                    fakprobme  TYPE yfakprobme     , " Fator para conversão UM amostra em UM material
                                    vsteuerkz  TYPE plmkb-vsteuerkz, " Proposta para códigos de controle da característica
                                    stellen    TYPE plmk-stellen   , " Número de casas decimais (precisão)
                                    masseinhsw TYPE plmk-masseinhsw, " Unidade de medida, na qual os dds.quantit.são gravados
                                    auswmenge1 TYPE plmk-auswmenge1, " Grupo de codes / conjunto de seleção atribuído
                                    auswmgwrk1 TYPE plmk-auswmgwrk1, " Centro do conjunto selecionado atribuido
                                  END OF ty_alv .

    TYPES:
  BEGIN OF ty_material_qp02        ,
                                matnr TYPE mara-matnr          , " Material
                                werks TYPE rc27m-werks         , " Centro
                              END OF ty_material_qp02 .

    TYPES:
      BEGIN OF ty_excel_qp02           ,
                                    matnr TYPE mara-matnr          , " Material
                                    werks TYPE rc27m-werks         , " Centro
                                    plnal TYPE plkod-plnal         , " Numerador de grupos
                                    qdynregel TYPE qdynregel       , " Regra de controle dinâmico
                                    statu TYPE plkod-statu         , " Status do plano
                                    vornr TYPE plpod-vornr         , " Nº operação
                                    merknr TYPE plmkb-merknr       , " Nº característica de controle
                                    toleranzun TYPE yavrg_dec_11_2 , " Limite inferior
                                    toleranzob TYPE yavrg_dec_11_2 , " Limite superior
                                    ctrdin TYPE plmkb-qdynregel    , " Controle dinâmico - Amostra <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                    masseinhsw TYPE qmgeh6         , " Unidade
                        END OF ty_excel_qp02 .

    TYPES:
      BEGIN OF ty_lista_tarefas_qp02        ,
                                  matnr TYPE mara-matnr          , " Material
                                  werks TYPE rc27m-werks         , " Centro
                                  plnal TYPE plkod-plnal         , " Numerador de grupos
                                  qdynregel TYPE qdynregel       , " Regra de controle dinâmico
                                  qdynhead TYPE plkod-qdynhead   , " Nível no qual devem ser definidos parâms.controle dinâmico
                                  statu    TYPE plkod-statu      , " Status do plano
                                END OF ty_lista_tarefas_qp02 .
    TYPES:
      BEGIN OF ty_operacoes_qp02        ,
                                  matnr TYPE mara-matnr          , " Material
                                  werks TYPE rc27m-werks         , " Centro
                                  plnal TYPE plkod-plnal         , " Numerador de grupos
                                  vornr TYPE plpod-vornr         , " Nº operação
                                END OF ty_operacoes_qp02 .
    TYPES:
      BEGIN OF ty_caracteristicas_ctrl_qp02        ,
                                  matnr TYPE mara-matnr          , " Material
                                  werks TYPE rc27m-werks         , " Centro
                                  plnal TYPE plkod-plnal         , " Numerador de grupos
                                  vornr TYPE plpod-vornr         , " Nº operação
                                  merknr TYPE plmkb-merknr       , " Nº característica de controle
                                  qdynregel TYPE qdynregel       , " Regra de controle dinâmico
                                  toleranzun TYPE char12         , "yavrg_dec_11_2 , " Limite inferior
                                  toleranzob TYPE char12         , "yavrg_dec_11_2 , " Limite superior
                                  masseinhsw TYPE qmgeh6         , " Unidade
                                END OF ty_caracteristicas_ctrl_qp02 .
    TYPES:
      BEGIN OF ty_alv_log_qp02         ,
                                    matnr       TYPE mara-matnr    ,
                                    msg_erro    TYPE c LENGTH 99   ,
                                  END OF ty_alv_log_qp02 .
    TYPES:
      tp_mapl          TYPE STANDARD TABLE OF ty_mapl          WITH DEFAULT KEY .
    TYPES:
      tp_alv           TYPE STANDARD TABLE OF ty_alv           WITH DEFAULT KEY .
    TYPES:
      tp_excel_qp02    TYPE STANDARD TABLE OF ty_excel_qp02    WITH DEFAULT KEY .
    TYPES:
      tp_material_qp02 TYPE STANDARD TABLE OF ty_material_qp02 WITH DEFAULT KEY .
    TYPES:
      tp_lista_tarefas_qp02 TYPE STANDARD TABLE OF ty_lista_tarefas_qp02 WITH DEFAULT KEY .
    TYPES:
      tp_operacoes_qp02 TYPE STANDARD TABLE OF ty_operacoes_qp02 WITH DEFAULT KEY .
    TYPES:
      tp_caracteristicas_ctrl_qp02 TYPE STANDARD TABLE OF ty_caracteristicas_ctrl_qp02 WITH DEFAULT KEY .
    TYPES:
      tp_alv_log_qp02  TYPE STANDARD TABLE OF ty_alv_log_qp02  WITH DEFAULT KEY .
    TYPES:
      r_plnnr TYPE RANGE OF char10 .
    TYPES:
      r_datuv TYPE RANGE OF mapl-datuv .
    TYPES:
      r_matnr TYPE RANGE OF mapl-matnr .
    TYPES:
      r_werks TYPE RANGE OF mapl-werks .
    TYPES:
      r_plnal TYPE RANGE OF mapl-plnal .

    METHODS exibir_alv
      CHANGING
        !t_alv TYPE tp_alv .
    METHODS exibir_alv_log_qp02 .
    METHODS get_planos_materiais
      IMPORTING
        !plnnr TYPE r_plnnr
        !datuv TYPE r_datuv OPTIONAL
        !matnr TYPE r_matnr OPTIONAL
        !werks TYPE r_werks OPTIONAL
      RETURNING
        value(t_mapl) TYPE tp_mapl
      RAISING
        ycx_plano_controle .
    METHODS get_plano_controle
      IMPORTING
        !t_mapl TYPE tp_mapl
      RETURNING
        value(t_alv) TYPE tp_alv
      RAISING
        ycx_plano_controle .
    METHODS modificar_plano_controle
      IMPORTING
        !im_nome_arquivo TYPE localfile
        !im_opcao_batch TYPE ctu_mode
      RAISING
        ycx_plano_controle .
    CLASS-METHODS selecionar_planilha
      RETURNING
        value(ex_nome_arquivo) TYPE localfile .