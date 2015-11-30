*----------------------------------------------------------------------*
*       CLASS YCL_APONTAMENTO_OP  DEFINITIO
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS ycl_apontamento_op DEFINITION
  PUBLIC
  CREATE PRIVATE .

*"* public components of class YCL_APONTAMENTO_OP
*"* do not include other source files here!!!
  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_cabecalho_op                            ,
             ordem_processo TYPE afpo-aufnr   , " Ordem de Processo
             centro         TYPE werks_d      , " Centro
             dsc_centro     TYPE t001w-name1  , " Nome do centro
             lote           TYPE mch1-charg   , " Lote
             material       TYPE mara-matnr   , " Nº do material
             dsc_mat        TYPE makt-maktx   , " Descrição do material
             fase           TYPE afvc-ltxa1   , " Txt.breve operação
             recurso        TYPE mcafvgv-arbpl, " Recurso
             qtd_total      TYPE c LENGTH 17  , " Quantidade Total
             qtd_produzida  TYPE c LENGTH 17  , " Quantidade Total
             hora_teorica   TYPE c LENGTH 17  , " Hora Teórica
           END OF ty_cabecalho_op .
    TYPES:
      BEGIN OF ty_operacao_op          ,
              ordem_processo TYPE string     , " Ordem de Processo
              centro         TYPE werks_d    , " Centro
              operacao       TYPE afvc-vornr , " Operação da ordem
              fase           TYPE afvc-ltxa1 , " Txt.breve operação
              recurso        TYPE arbpl      , " Recurso
              confirmacao    TYPE co_rmzhl   , " Sequencia da quantidade de apontamentos (CORT)
              hr_apo         TYPE c LENGTH 17, " APO Tp. preparação + APO Tp. maquina
              hr_hh          TYPE c LENGTH 17, " Custo HH Tp. preparação + Custo HH Tp. maquina
              qtd_boa        TYPE c LENGTH 17, " Quantidade boa
              apto_parcial   TYPE c LENGTH 07, " Apontamento Parcial
              apto_final     TYPE c LENGTH 05, " Apontamento Final
              status_apto    TYPE c LENGTH 25, " Status do Apontamento
              estornar_apto  TYPE c LENGTH 08, " Estornar
           END OF ty_operacao_op .
    TYPES:
      BEGIN OF ty_apontamento          ,
              ordem_processo TYPE caufv-aufnr, " Ordem de processo
              centro         TYPE werks_d    , " Centro
              nro_operacao   TYPE afvc-vornr , " Número da operação
              fase           TYPE afvc-ltxa1 , " Txt.breve operação
              recurso        TYPE arbpl      , " Recurso
              dsc_recurso    TYPE rcrtx-ktext, " Descrição do recurso
              confirmacao    TYPE co_rmzhl   , " Sequência do apontamento
              material       TYPE mara-matnr , " Nro do material
              dsc_material   TYPE makt-maktx , " Descrição do material
              qtd_planejada  TYPE afru-smeng , " Quantidade planejada
              unidade_medida TYPE afvgd-meinh, " Unidade de medida
              hr_apo_tp_prep TYPE afrud-ism01, " APO Tp. preparação
              hr_apo_tp_maq  TYPE afrud-ism02, " APO Tp. maquina
              hr_hh_tp_prep  TYPE afrud-ism03, " Custo HH Tp. preparação
              hr_hh_tp_maq   TYPE afrud-ism04, " Custo HH Tp. maquina
              qtd_boa        TYPE afrud-lmnga, " Quantidade boa
              qtd_apontada   TYPE afvgd-lmnga, " Quantidade apontada
              refugo         TYPE afrud-xmnga, " Refugo
            END OF ty_apontamento .
    TYPES:
      BEGIN OF ty_tela_apontamento,
              ordem_processo TYPE caufv-aufnr, " Ordem de processo
              centro         TYPE werks_d    , " Centro
              nro_operacao   TYPE afvc-vornr , " Número da operação
              fase           TYPE afvc-ltxa1 , " Txt.breve operação
              recurso        TYPE arbpl      , " Recurso
              dsc_recurso    TYPE rcrtx-ktext, " Descrição do recurso
              confirmacao    TYPE co_rmzhl   , " Sequência do apontamento
              material       TYPE mara-matnr , " Nro do material
              dsc_material   TYPE makt-maktx , " Descrição do material
              hr_apo_tp_prep TYPE c LENGTH 17, " APO Tp. preparação
              hr_apo_tp_maq  TYPE c LENGTH 17, " APO Tp. maquina
              hr_hh_tp_prep  TYPE c LENGTH 17, " Custo HH Tp. preparação
              hr_hh_tp_maq   TYPE c LENGTH 17, " Custo HH Tp. maquina
              qtd_boa        TYPE c LENGTH 17, " Quantidade boa
              refugo         TYPE c LENGTH 17, " Refugo
           END OF ty_tela_apontamento .
    TYPES:
      BEGIN OF ty_total_operacao      ,
               ordem_processo TYPE string     , " Ordem de Processo
               centro         TYPE werks_d    , " Centro
               operacao       TYPE afvc-vornr , " Operação da ordem
               fase           TYPE afvc-ltxa1 , " Txt.breve operação
               recurso        TYPE arbpl      , " Recurso
               dsc_recurso    TYPE rcrtx-ktext, " Descrição do recurso
               material       TYPE mara-matnr , " Nro do material
               dsc_material   TYPE makt-maktx , " Descrição do material
               qtd_planejada  TYPE afru-smeng , " Quantidade planejada
               unidade_medida TYPE afvgd-meinh, " Unidade de medida
               hr_apo_tp_prep TYPE afvgd-vgw01, " APO Tp. preparação
               hr_apo_tp_maq  TYPE afvgd-vgw02, " APO Tp. maquina
               hr_hh_tp_prep  TYPE afvgd-vgw03, " Custo HH Tp. preparação
               hr_hh_tp_maq   TYPE afvgd-vgw04, " Custo HH Tp. maquina
               qtd_apontada   TYPE afvgd-lmnga, " Quantidade apontada
               qtd_boa        TYPE afvgd-lmnga, " Quantidade boa
               refugo         TYPE afvgd-xmnga, " Refugo
          END OF ty_total_operacao .
    TYPES:
      BEGIN OF ty_msg_app      ,
               tipo TYPE c LENGTH 10 ,
               msg  TYPE c LENGTH 400,
           END OF ty_msg_app .
    TYPES:
      BEGIN OF ty_permissao            .
            INCLUDE TYPE yapt001            . " APO - Cadastro de Usuários e permissões
    TYPES: END OF ty_permissao .
    TYPES:
      tp_operacao       TYPE STANDARD TABLE OF ty_operacao_op     WITH DEFAULT KEY .
    TYPES:
      tp_total_operacao TYPE STANDARD TABLE OF ty_total_operacao  WITH DEFAULT KEY .

    CONSTANTS c_confirmacao_final TYPE string VALUE 'confirmacaoFinal'. "#EC NOTEXT
    CONSTANTS c_confirmacao_parcial TYPE string VALUE 'confirmacaoParcial'. "#EC NOTEXT
    CONSTANTS c_pesquisar_op TYPE string VALUE 'pesquisarOP'. "#EC NOTEXT
    CONSTANTS c_salvar_apontamento TYPE string VALUE 'salvarApontamento'. "#EC NOTEXT

    METHODS converter_char_qty
      IMPORTING
        !im_valor_char TYPE char17
      RETURNING
        value(ex_valor_qty) TYPE mengv13 .
    CLASS ycl_apontamento_op DEFINITION LOAD .
    CLASS-METHODS converter_msg_json
      IMPORTING
        !im_w_msg_app TYPE ycl_apontamento_op=>ty_msg_app
      RETURNING
        value(ex_json) TYPE string .
    METHODS estornar_apontamento
      RETURNING
        value(ex_msg_retorno) TYPE string
      RAISING
        ycx_apo .
    METHODS get_cabecalho_ordem_processo
      RETURNING
        value(ex_w_cabecalho_op) TYPE ty_cabecalho_op
      RAISING
        ycx_apo .
    METHODS get_detalhes_folha_tempos
      IMPORTING
        !im_ordem_processo TYPE afko-aufnr
        !im_confirmacao_final TYPE char1 OPTIONAL
        !im_confirmacao_parcial TYPE char1 OPTIONAL
      RETURNING
        value(ex_w_apontamento) TYPE ty_apontamento
      RAISING
        ycx_apo .
    METHODS get_detalhes_ordem_processo
      CHANGING
        !ex_w_cabecalho_op TYPE ty_cabecalho_op OPTIONAL
        !ex_t_operacao TYPE tp_operacao OPTIONAL
      RAISING
        ycx_apo .
    CLASS-METHODS get_hora_login_usuario
      IMPORTING
        !im_usuario TYPE sy-uname
      RETURNING
        value(ex_login) TYPE yapt002
      RAISING
        ycx_apo .
    CLASS-METHODS get_instance
      RETURNING
        value(ex_instancia) TYPE REF TO ycl_apontamento_op
      RAISING
        ycx_apo .
    METHODS get_operacoes_ordem_processo
      RETURNING
        value(ex_t_operacao) TYPE tp_operacao
      RAISING
        ycx_apo .
    METHODS get_ordem_processo
      RETURNING
        value(ex_ordem_processo) TYPE afko-aufnr
      RAISING
        ycx_apo .
    METHODS get_permissoes_usuario
      IMPORTING
        !im_usuario TYPE sy-uname
        !im_recurso TYPE arbpl OPTIONAL
        !im_centro TYPE werks_d OPTIONAL
        !im_apto_parcial TYPE char1 OPTIONAL
        !im_apto_final TYPE char1 OPTIONAL
        !im_estorno TYPE char1 OPTIONAL
      RETURNING
        value(ex_w_permissoes) TYPE ty_permissao
      RAISING
        ycx_apo .
    METHODS get_search_help_recursos
      CHANGING
        value(ex_recurso) TYPE yapt001 .
    METHODS get_tempo_conexao
      IMPORTING
        !im_usuario TYPE sy-uname
      RAISING
        ycx_apo .
    METHODS get_total_operacao
      RETURNING
        value(ex_t_total_operacao) TYPE tp_total_operacao .
    METHODS get_w_apontamento
      RETURNING
        value(ex_w_apontamento) TYPE ty_apontamento
      RAISING
        ycx_apo .
    METHODS salvar_apontamento
      IMPORTING
        !im_tipo_apto TYPE string
      RETURNING
        value(ex_msg_retorno) TYPE string
      RAISING
        ycx_apo .
    METHODS set_cabecalho_ordem_processo
      IMPORTING
        !im_ordem_processo TYPE afko-aufnr
      RAISING
        ycx_apo .
    METHODS set_centro
      CHANGING
        !ex_centro TYPE werks_d
      RAISING
        ycx_apo .
    CLASS-METHODS set_hora_login_usuario
      IMPORTING
        !im_usuario TYPE sy-uname .
    METHODS set_nro_operacao
      CHANGING
        value(ex_nro_operacao) TYPE afvc-vornr
      RAISING
        ycx_apo .
    METHODS set_operacoes_ordem_processo
      IMPORTING
        !im_ordem_processo TYPE afko-aufnr OPTIONAL
      RAISING
        ycx_apo .
    METHODS set_ordem_processo
      IMPORTING
        !im_ordem_processo TYPE caufv-aufnr
      RAISING
        ycx_apo .
    METHODS set_permissao_modificacao_op
      RAISING
        ycx_apo .
    METHODS set_recurso
      CHANGING
        !ex_recurso TYPE crhd-arbpl
      RAISING
        ycx_apo .
    METHODS set_total_operacao
      IMPORTING
        !im_t_total_operacao TYPE tp_total_operacao .
    METHODS set_t_operacao
      IMPORTING
        !im_t_operacao TYPE tp_operacao
      RAISING
        ycx_apo .
    METHODS set_w_apontamento
      IMPORTING
        !im_w_tela_apto TYPE ty_tela_apontamento
      RAISING
        ycx_apo .
    METHODS validar_centro_recurso
      IMPORTING
        !im_recurso TYPE crhd-arbpl
      CHANGING
        value(ex_centro) TYPE crhd-werks
      RAISING
        ycx_apo .