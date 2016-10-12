*----------------------------------------------------------------------*
* Programa : ZSDR033                                                   *
* Transação: ZSDR033                                                   *
* Descrição: Relatório de pagamento de comissão de vendas para         *
*            representantes internos (Z1 - Z7) e externos (F1 - F7)    *
* Tipo     : Relatório ALV                                             *
* Módulo   : SD                                                        *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  14.10.2014  #***** - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

REPORT zsdr033 NO STANDARD PAGE HEADING MESSAGE-ID zsdr033.

TYPE-POOLS: abap.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
DATA:
  vl_vbeln    TYPE vbak-vbeln  , " N° do documento de vendas
  vl_lifnr    TYPE vbpa-lifnr  , " N° do Representante
  vl_pernr    TYPE vbpa-pernr  , " N° do funcionário
  vl_erdat    TYPE vbak-erdat  , " Data da criação
  vl_vkorg    TYPE vbak-vkorg  , " Organização de vendas
  vl_vtweg    TYPE vbak-vtweg  , " Canal de distribuição
  vl_spart    TYPE vbak-spart  , " Setor de atividade
  vl_vkbur    TYPE vbak-vkbur  , " Escritório de vendas
  vl_nreg     TYPE zsdt033i-nrg, " Número de registro
  vl_cont     TYPE i           ,
  vl_msg_erro TYPE string      .

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
CONSTANTS:
  c_outros_campos     TYPE screen-group1 VALUE 'Z0'        ,
  c_representante     TYPE screen-group1 VALUE 'Z1'        ,
  c_funcionario       TYPE screen-group1 VALUE 'Z2'        ,
  c_comissao          TYPE screen-group1 VALUE 'Z3'        ,
  c_dt_criacao        TYPE screen-group1 VALUE 'Z4'        ,
  c_habilitar_campo   TYPE c LENGTH 01   VALUE '1'         ,
  c_desabilitar_campo TYPE c LENGTH 01   VALUE '0'         .

*----------------------------------------------------------------------*
* Tela de seleção
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t001. " Opção de seleção
PARAMETERS: p_forn RADIOBUTTON GROUP a USER-COMMAND rusr, " Representante Fornecedor
            p_func RADIOBUTTON GROUP a DEFAULT 'X'      , " Representante Funcionário
            p_com  RADIOBUTTON GROUP a                  . " Efetivar a comissão
SELECTION-SCREEN END OF BLOCK b1                        .

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE t002. " Representante Fornecedor
SELECT-OPTIONS: s_nreg  FOR vl_nreg  MODIF ID z3        , " Nro do Registro
                s_vbeln FOR vl_vbeln MODIF ID z0        , " N° do documento de vendas
                s_lifnr FOR vl_lifnr MODIF ID z1        , " N° do Representante
                s_pernr FOR vl_pernr MODIF ID z2        , " N° do funcionário
                s_erdat FOR vl_erdat MODIF ID z4        , " Data da criação
                s_vkorg FOR vl_vkorg MODIF ID z0        , " Organização de vendas
                s_vtweg FOR vl_vtweg MODIF ID z0        , " Canal de distribuição
                s_spart FOR vl_spart MODIF ID z0        , " Setor de atividade
                s_vkbur FOR vl_vkbur MODIF ID z0        . " Escritório de vendas
SELECTION-SCREEN END OF BLOCK b2                        .

*----------------------------------------------------------------------*
* Inicialização
*----------------------------------------------------------------------*
INITIALIZATION.
  t001 = 'Opção de seleção'(001)                 .          "#EC NOTEXT
  t002 = 'Seleções específicas do relatório'(002).          "#EC NOTEXT

*----------------------------------------------------------------------*
* 'PBO' da selection-screen
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  vl_cont = vl_cont + 1.

  IF vl_cont = 1.
    LOOP AT SCREEN.
      CASE screen-group1.
        WHEN c_outros_campos
          OR c_funcionario
          OR c_representante
          OR c_comissao
          OR c_dt_criacao.
          screen-active = c_desabilitar_campo.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.

  ELSE.
    vl_cont = vl_cont + 1.

*    FREE: s_vbeln, s_lifnr, s_pernr, s_erdat,
*          s_vkorg, s_vtweg, s_spart, s_vkbur.

    CASE abap_true.
      WHEN p_forn.
        LOOP AT SCREEN.
          CASE screen-group1.
            WHEN c_funcionario.
              screen-active = c_desabilitar_campo.
            WHEN c_outros_campos
              OR c_dt_criacao.
              screen-active = c_habilitar_campo.
            WHEN c_comissao.
              screen-active = c_desabilitar_campo.
          ENDCASE.
          MODIFY SCREEN.
        ENDLOOP.
      WHEN p_func.
        LOOP AT SCREEN.
          CASE screen-group1.
            WHEN c_representante.
              screen-active = c_desabilitar_campo.
            WHEN c_outros_campos
              OR c_dt_criacao.
              screen-active = c_habilitar_campo.
            WHEN c_comissao.
              screen-active = c_desabilitar_campo.
          ENDCASE.
          MODIFY SCREEN.
        ENDLOOP.
      WHEN p_com.
        LOOP AT SCREEN.
          CASE screen-group1.
            WHEN c_funcionario
               OR c_comissao
               OR c_representante
               OR c_dt_criacao.
              screen-active = c_habilitar_campo.
            WHEN c_outros_campos.
              screen-active = c_desabilitar_campo.
          ENDCASE.
          MODIFY SCREEN.
        ENDLOOP.
    ENDCASE.
  ENDIF.

*----------------------------------------------------------------------*
*       CLASS lcl_salv DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_salv DEFINITION.
  PUBLIC SECTION.
    CONSTANTS:
      c_pessoa            TYPE fieldname     VALUE 'PERNR'     ,
      c_fornecedor        TYPE fieldname     VALUE 'LIFNR'     ,
      c_pedido_compras    TYPE fieldname     VALUE 'BSTNK'     ,
      c_dsc_fornecedor    TYPE fieldname     VALUE 'NAME1'     ,
      c_docto_vendas      TYPE fieldname     VALUE 'VBELN'     ,
      c_valor_liquido     TYPE fieldname     VALUE 'NETWR'     ,
      c_valor_comissao    TYPE fieldname     VALUE 'VCOM'      ,
      c_valor_compensar   TYPE fieldname     VALUE 'VCOMP'     ,
      c_valor_compensado  TYPE fieldname     VALUE 'VCOPD'     ,
      c_confirmar         TYPE fieldname     VALUE 'CONF'      ,
      c_status            TYPE fieldname     VALUE 'STATUS'    ,
      c_btn_registrar     TYPE sy-ucomm      VALUE 'BTN_REGIST',
      c_btn_simular       TYPE sy-ucomm      VALUE 'BTN_SIMUL' ,
      c_btn_imprimir      TYPE sy-ucomm      VALUE 'BTN_IMPRIM',
      c_btn_aprovar       TYPE sy-ucomm      VALUE 'BTN_APROV' ,
      c_btn_eliminar      TYPE sy-ucomm      VALUE 'BTN_ELIMIN',
      c_btn_cancelar      TYPE sy-ucomm      VALUE 'CANC'      ,
      c_btn_sair          TYPE sy-ucomm      VALUE 'EXIT'      ,
      c_va03              TYPE tstc-tcode    VALUE 'VA03'      ,
      c_xk03              TYPE tstc-tcode    VALUE 'XK03'      ,
      c_pa20              TYPE tstc-tcode    VALUE 'PA20'      ,
      c_me23n             TYPE tstc-tcode    VALUE 'ME23N'     .

    DATA: obj_alv TYPE REF TO cl_salv_table.

    METHODS: exibir_relatorio
      IMPORTING im_fornec   TYPE c OPTIONAL
                im_pessoa   TYPE c OPTIONAL
                im_comissao TYPE c OPTIONAL
      CHANGING ex_tabela TYPE STANDARD TABLE.

  PRIVATE SECTION.
    METHODS: set_ajustar_colunas.

    METHODS: set_pf_status
      IMPORTING im_comissao TYPE c OPTIONAL
      CHANGING ex_salv TYPE REF TO cl_salv_table.

    METHODS: set_ordenacao
      IMPORTING im_campo TYPE lvc_fname
       CHANGING ex_salv  TYPE REF TO cl_salv_table.

    METHODS: set_sub_total
      IMPORTING im_campo TYPE lvc_fname
       CHANGING ex_salv  TYPE REF TO cl_salv_table.

    METHODS: set_hotspot
     IMPORTING im_campo TYPE lvc_fname
      CHANGING ex_salv  TYPE REF TO cl_salv_table.

    METHODS: set_icone
     IMPORTING im_campo TYPE lvc_fname
      CHANGING ex_salv  TYPE REF TO cl_salv_table.

    METHODS: set_checkbox
     IMPORTING im_campo TYPE lvc_fname
      CHANGING ex_salv  TYPE REF TO cl_salv_table.

    METHODS: set_hide_field
     IMPORTING im_campo TYPE lvc_fname
      CHANGING ex_salv  TYPE REF TO cl_salv_table.

    METHODS: on_user_command FOR EVENT added_function OF cl_salv_events
       IMPORTING e_salv_function.

    METHODS: on_link_click FOR EVENT link_click OF cl_salv_events_table
      IMPORTING row
                column.
ENDCLASS.                    "lcl_salv DEFINITION

*----------------------------------------------------------------------*
* Inicio
*----------------------------------------------------------------------*
START-OF-SELECTION.

* Para evitar carregar todas informações antes de exibir a tela de seleção
  vl_cont = vl_cont + 1.

  IF vl_cont <= 2.
    EXIT.
  ENDIF.

  DATA:
    obj_cv      TYPE REF TO zcl_comissao_vendas,
    obj_cx_root TYPE REF TO cx_root            ,
    obj_salv    TYPE REF TO lcl_salv           .

  TRY.
      CREATE OBJECT: obj_cv, obj_salv.

      DATA:
        t_comissao       TYPE STANDARD TABLE OF obj_cv->ty_comissao      ,
        t_aprov_comissao TYPE STANDARD TABLE OF obj_cv->ty_aprov_comissao,
        t_retorno_me21n  TYPE STANDARD TABLE OF obj_cv->ty_bapiret2      .

      CASE abap_true.
        WHEN p_forn. " Fornecedor

          t_comissao = obj_cv->get_comissao_fornecedor( im_vbeln = s_vbeln[]    " N° do documento de vendas
                                                        im_lifnr = s_lifnr[]    " N° do Representante
                                                        im_erdat = s_erdat[]    " Data da criação
                                                        im_vkorg = s_vkorg[]    " Organização de vendas
                                                        im_vtweg = s_vtweg[]    " Canal de distribuição
                                                        im_spart = s_spart[]    " Setor de atividade
                                                        im_vkbur = s_vkbur[] ). " Escritório de vendas

          IF t_comissao IS NOT INITIAL.
            obj_salv->exibir_relatorio( EXPORTING im_fornec = abap_true
                                         CHANGING ex_tabela = t_comissao ).
          ENDIF.

        WHEN p_func. " Funcionário
          t_comissao = obj_cv->get_comissao_funcionario( im_vbeln = s_vbeln[]    " N° do documento de vendas
                                                         im_pernr = s_pernr[]    " N° do funcionário
                                                         im_erdat = s_erdat[]    " Data da criação
                                                         im_vkorg = s_vkorg[]    " Organização de vendas
                                                         im_vtweg = s_vtweg[]    " Canal de distribuição
                                                         im_spart = s_spart[]    " Setor de atividade
                                                         im_vkbur = s_vkbur[] ). " Escritório de vendas
          IF t_comissao IS NOT INITIAL.
            obj_salv->exibir_relatorio( EXPORTING im_pessoa = abap_true
                                         CHANGING ex_tabela = t_comissao ).
          ENDIF.

        WHEN p_com. " Efetivar a comissão
          t_aprov_comissao = obj_cv->get_comissao_pendente( im_r_nrg   = s_nreg[]     " Nº do Registro
                                                            im_r_lifnr = s_lifnr[]    " N° do Representante
                                                            im_r_pernr = s_pernr[]    " N° do funcionário
                                                            im_r_erdat = s_erdat[] ). " Data da criação

          obj_salv->exibir_relatorio( EXPORTING im_comissao = abap_true
                                      CHANGING ex_tabela    = t_aprov_comissao ).
      ENDCASE.

    CATCH cx_root INTO obj_cx_root.
      vl_msg_erro = obj_cx_root->get_longtext( ).
      MESSAGE vl_msg_erro TYPE 'S' DISPLAY LIKE 'E'.        "#EC NOTEXT
  ENDTRY.

*----------------------------------------------------------------------*
*       CLASS lcl_salv IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_salv IMPLEMENTATION.
*&---------------------------------------------------------------------*
*&      Method  exibir_relatorio
*&---------------------------------------------------------------------*
* --> IMPORTING im_fornec TYPE c OPTIONAL
*               im_pessoa TYPE c OPTIONAL
* <-- CHANGING  ex_tabela TYPE STANDARD TABLE.
*----------------------------------------------------------------------*
  METHOD exibir_relatorio.
    DATA:
      obj_exc_salv TYPE REF TO cx_salv_msg         ,        "#EC NEEDED
      obj_events   TYPE REF TO cl_salv_events_table.

    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = obj_alv
                                 CHANGING t_table      = ex_tabela ).
      CATCH cx_salv_msg INTO obj_exc_salv.              "#EC NO_HANDLER
    ENDTRY.

    IF im_fornec IS NOT INITIAL.
      me->set_hide_field( EXPORTING im_campo = c_pessoa    CHANGING ex_salv = obj_alv ).
      me->set_ordenacao( EXPORTING im_campo = c_fornecedor CHANGING ex_salv = obj_alv ).

    ELSEIF im_pessoa IS NOT INITIAL.
      me->set_hide_field( EXPORTING im_campo = c_fornecedor CHANGING ex_salv = obj_alv ).
      me->set_ordenacao( EXPORTING im_campo = c_pessoa      CHANGING ex_salv = obj_alv ).
    ENDIF.

    IF im_comissao IS INITIAL.

      me->set_pf_status( CHANGING ex_salv = obj_alv ).

      me->set_ordenacao( EXPORTING im_campo = c_dsc_fornecedor CHANGING ex_salv = obj_alv ).

      me->set_sub_total( EXPORTING im_campo = c_valor_liquido    CHANGING ex_salv = obj_alv ).
      me->set_sub_total( EXPORTING im_campo = c_valor_comissao   CHANGING ex_salv = obj_alv ).
      me->set_sub_total( EXPORTING im_campo = c_valor_compensar  CHANGING ex_salv = obj_alv ).
      me->set_sub_total( EXPORTING im_campo = c_valor_compensado CHANGING ex_salv = obj_alv ).

      me->set_hotspot( EXPORTING im_campo = c_fornecedor   CHANGING ex_salv = obj_alv ).
      me->set_hotspot( EXPORTING im_campo = c_pessoa       CHANGING ex_salv = obj_alv ).
      me->set_hotspot( EXPORTING im_campo = c_docto_vendas CHANGING ex_salv = obj_alv ).

    ELSE.
      me->set_icone( EXPORTING im_campo = c_status CHANGING ex_salv = obj_alv ).
      me->set_hotspot( EXPORTING im_campo = c_pedido_compras CHANGING ex_salv = obj_alv ).

      me->set_pf_status( EXPORTING im_comissao = abap_true
                          CHANGING ex_salv     = obj_alv ).
    ENDIF.

    me->set_checkbox( EXPORTING im_campo = c_confirmar CHANGING ex_salv = obj_alv ).
    me->set_ajustar_colunas( ).

    obj_events = obj_alv->get_event( ).

    SET HANDLER me->on_user_command FOR obj_events.
    SET HANDLER me->on_link_click   FOR obj_events.

    obj_alv->display( ).
  ENDMETHOD.                    "exibir_relatorio

*&---------------------------------------------------------------------*
*&      Method  set_ajustar_colunas
*&---------------------------------------------------------------------*
  METHOD set_ajustar_colunas.
    DATA:
      obj_colunas TYPE REF TO cl_salv_columns.

    obj_colunas = obj_alv->get_columns( ).
    obj_colunas->set_optimize( abap_true ).
  ENDMETHOD.

*&---------------------------------------------------------------------*
*&      Method  set_pf_status
*&---------------------------------------------------------------------*
* --> IMPORTING im_comissao TYPE C
* <-- CHANGING ex_salv TYPE REF TO cl_salv_table.
*----------------------------------------------------------------------*
  METHOD set_pf_status.
    DATA
      obj_functions TYPE REF TO cl_salv_functions_list.

    obj_functions = ex_salv->get_functions( ).
    obj_functions->set_default( abap_true ).

    IF im_comissao IS INITIAL.
      obj_alv->set_screen_status( pfstatus      = 'S1000'   "#EC NEEDED
                                  report        = sy-repid
                                  set_functions = obj_alv->c_functions_all ).
    ELSE.
      obj_alv->set_screen_status( pfstatus      = 'S1001'   "#EC NEEDED
                                  report        = sy-repid
                                  set_functions = obj_alv->c_functions_all ).
    ENDIF.

  ENDMETHOD.                    "set_pf_status

*&---------------------------------------------------------------------*
*&      Method  set_ordenacao
*&---------------------------------------------------------------------*
* --> IMPORTING im_campo TYPE lvc_fname
* <-- CHANGING  ex_salv  TYPE REF TO cl_salv_table.
*----------------------------------------------------------------------*
  METHOD set_ordenacao.
    DATA:
      obj_sort TYPE REF TO cl_salv_sorts.

    obj_sort = ex_salv->get_sorts( ).

    TRY.
        obj_sort->add_sort( columnname = im_campo
                            subtotal   = if_salv_c_bool_sap=>true ).

      CATCH cx_salv_not_found.                          "#EC NO_HANDLER
      CATCH cx_salv_existing.                           "#EC NO_HANDLER
      CATCH cx_salv_data_error.                         "#EC NO_HANDLER
    ENDTRY.
  ENDMETHOD.                    "set_hotspot

*&---------------------------------------------------------------------*
*&      Method  set_sub_total
*&---------------------------------------------------------------------*
* --> IMPORTING im_campo TYPE lvc_fname
* <-- CHANGING  ex_salv  TYPE REF TO cl_salv_table.
*----------------------------------------------------------------------*
  METHOD set_sub_total.
    DATA
      obj_aggrs TYPE REF TO cl_salv_aggregations.

    obj_aggrs = ex_salv->get_aggregations( ).

    TRY.
        obj_aggrs->add_aggregation( columnname  = im_campo
                                    aggregation = if_salv_c_aggregation=>total ).
      CATCH cx_salv_data_error.                         "#EC NO_HANDLER
      CATCH cx_salv_not_found .                         "#EC NO_HANDLER
      CATCH cx_salv_existing  .                         "#EC NO_HANDLER
    ENDTRY.
  ENDMETHOD.                    "set_sub_total

*&---------------------------------------------------------------------*
*&      Method  set_hotspot
*&---------------------------------------------------------------------*
* --> IMPORTING im_campo TYPE lvc_fname
* <-- CHANGING  ex_salv  TYPE REF TO cl_salv_table.
*----------------------------------------------------------------------*
  METHOD set_hotspot.
    DATA:
      obj_cols_tab TYPE REF TO cl_salv_columns_table,
      obj_col_tab  TYPE REF TO cl_salv_column_table .

    TRY.
        obj_cols_tab = ex_salv->get_columns( ).
        obj_col_tab ?= obj_cols_tab->get_column( im_campo ).
        obj_col_tab->set_cell_type( if_salv_c_cell_type=>hotspot ).
      CATCH cx_salv_not_found.                          "#EC NO_HANDLER
    ENDTRY.
  ENDMETHOD.                    "set_hotspot

*&---------------------------------------------------------------------*
*&      Method  set_icone
*&---------------------------------------------------------------------*
* --> IMPORTING im_campo TYPE lvc_fname
* <-- CHANGING  ex_salv  TYPE REF TO cl_salv_table.
*----------------------------------------------------------------------*
  METHOD set_icone.
    DATA:
      obj_cols_tab TYPE REF TO cl_salv_columns_table,
      obj_col_tab  TYPE REF TO cl_salv_column_table .

    TRY.
        obj_cols_tab = ex_salv->get_columns( ).
        obj_col_tab ?= obj_cols_tab->get_column( im_campo ).
        obj_col_tab->set_icon( if_salv_c_bool_sap=>true ).
      CATCH cx_salv_not_found.                          "#EC NO_HANDLER
    ENDTRY.
  ENDMETHOD.                    "set_icone

*&---------------------------------------------------------------------*
*&      Method  set_checkbox
*&---------------------------------------------------------------------*
* --> IMPORTING im_campo TYPE lvc_fname
* <-- CHANGING  ex_salv  TYPE REF TO cl_salv_table.
*----------------------------------------------------------------------*
  METHOD set_checkbox.
    DATA:
      obj_cols_tab TYPE REF TO cl_salv_columns_table,
      obj_col_tab  TYPE REF TO cl_salv_column_table .

    TRY.
        obj_cols_tab = obj_alv->get_columns( ).
        obj_col_tab ?= obj_cols_tab->get_column( im_campo ).
        obj_col_tab->set_cell_type( if_salv_c_cell_type=>checkbox_hotspot ).
        obj_col_tab->set_output_length( 10 ).
      CATCH cx_salv_not_found.                          "#EC NO_HANDLER
    ENDTRY.
  ENDMETHOD.

*&---------------------------------------------------------------------*
*&      Method  set_hide_field
*&---------------------------------------------------------------------*
* --> IMPORTING im_campo TYPE lvc_fname
* <-- CHANGING  ex_salv  TYPE REF TO cl_salv_table.
*----------------------------------------------------------------------*
  METHOD set_hide_field.
    DATA:
      obj_cols_tab TYPE REF TO cl_salv_columns_table,
      obj_col_tab  TYPE REF TO cl_salv_column_table .

    TRY.
        obj_cols_tab = obj_alv->get_columns( ).
        obj_col_tab ?= obj_cols_tab->get_column( im_campo ).
        obj_col_tab->set_visible( value  = if_salv_c_bool_sap=>false ).
      CATCH cx_salv_not_found.                          "#EC NO_HANDLER
    ENDTRY.
  ENDMETHOD.

*&---------------------------------------------------------------------*
*&      Method  on_user_command
*&---------------------------------------------------------------------*
* --> IMPORTING e_salv_function TYPE SALV_DE_FUNCTION
*----------------------------------------------------------------------*
  METHOD on_user_command.
    DATA:
       obj_selections TYPE REF TO cl_salv_selections,
       t_linha_selec  TYPE salv_t_row               ,
       w_linha_selec  LIKE LINE OF t_linha_selec    .

    TRY.
        CASE e_salv_function.
          WHEN c_btn_cancelar OR c_btn_sair.
            LEAVE TO SCREEN 0.

          WHEN me->c_btn_registrar.
            obj_cv->set_comissao( CHANGING im_t_comissao = t_comissao ).
            me->obj_alv->refresh( ).

          WHEN me->c_btn_simular.
            obj_cv->exibir_rel_comissao_vendas( CHANGING im_t_comissao = t_comissao ).

          WHEN me->c_btn_imprimir.
            obj_cv->exibir_rel_comissao_vendas( CHANGING im_t_aprov_comissao = t_aprov_comissao ).

          WHEN me->c_btn_aprovar.
            FREE t_retorno_me21n.

            obj_cv->efetivar_comissao( CHANGING ex_t_aprov_comissao = t_aprov_comissao
                                                ex_t_bapiret2       = t_retorno_me21n ).

            IF t_retorno_me21n IS NOT INITIAL.
              DATA:
                 obj_popup_alv TYPE REF TO cl_salv_table         ,
                 obj_functions TYPE REF TO cl_salv_functions_list.

              IF obj_popup_alv IS NOT INITIAL.
                obj_popup_alv->refresh( ).
                FREE obj_popup_alv.
              ENDIF.

              IF obj_functions IS NOT INITIAL.
                FREE obj_functions.
              ENDIF.

              cl_salv_table=>factory( IMPORTING r_salv_table = obj_popup_alv
                                       CHANGING t_table      = t_retorno_me21n ).

              obj_functions = obj_popup_alv->get_functions( ).

              obj_popup_alv->set_screen_popup( start_column = 25
                                               end_column   = 130
                                               start_line   = 6
                                               end_line     = 15 ).
              obj_popup_alv->display( ).
            ENDIF.

            me->obj_alv->refresh( ).

          WHEN me->c_btn_eliminar.
            obj_cv->eliminar_comissao( CHANGING ex_t_aprov_comissao = t_aprov_comissao ).
            me->obj_alv->refresh( ).

        ENDCASE.

      CATCH cx_root INTO obj_cx_root.
        vl_msg_erro = obj_cx_root->get_longtext( ).
        MESSAGE vl_msg_erro TYPE 'S' DISPLAY LIKE 'E'.      "#EC NOTEXT
    ENDTRY.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*&      Method  on_link_click
*&---------------------------------------------------------------------*
* --> IMPORTING row    TYPE SALV_DE_ROW
* --> IMPORTING column TYPE SALV_DE_COLUMN
*----------------------------------------------------------------------*
  METHOD on_link_click.
    DATA
      vl_kdy TYPE c LENGTH 08 VALUE '/110'.

    READ TABLE t_comissao
    ASSIGNING FIELD-SYMBOL(<f_w_comissao>)
    INDEX row.

    IF sy-subrc = 0.
      CASE column.
        WHEN c_docto_vendas. " VBELN
          SET PARAMETER ID 'AUN' FIELD <f_w_comissao>-vbeln. "#EC NOTEXT
          CALL TRANSACTION me->c_va03 AND SKIP FIRST SCREEN.

        WHEN c_fornecedor. " LIFNR
          SET PARAMETER ID 'LIF' FIELD <f_w_comissao>-lifnr. "#EC NOTEXT
          SET PARAMETER ID 'KDY' FIELD vl_kdy.              "#EC NOTEXT
          CALL TRANSACTION me->c_xk03 AND SKIP FIRST SCREEN.

        WHEN c_pessoa. " PERNR
          SET PARAMETER ID 'PER' FIELD <f_w_comissao>-pernr. "#EC NOTEXT
          CALL TRANSACTION me->c_pa20 AND SKIP FIRST SCREEN.

        WHEN c_confirmar.
          IF <f_w_comissao>-conf IS INITIAL.
            <f_w_comissao>-conf = abap_true.
          ELSE.
            CLEAR <f_w_comissao>-conf.
          ENDIF.

          me->obj_alv->refresh( ).
      ENDCASE.
    ENDIF.

    READ TABLE t_aprov_comissao
    ASSIGNING FIELD-SYMBOL(<f_w_aprov_comissao>)
    INDEX row.

    IF sy-subrc = 0.
      CASE column.
        WHEN c_pedido_compras. "BSTNK
          CHECK <f_w_aprov_comissao>-bstnk IS NOT INITIAL.
          SET PARAMETER ID 'BES' FIELD <f_w_aprov_comissao>-bstnk . "#EC NOTEXT
          CALL TRANSACTION me->c_me23n AND SKIP FIRST SCREEN.

        WHEN c_confirmar.
          IF <f_w_aprov_comissao>-conf IS INITIAL.
            <f_w_aprov_comissao>-conf = abap_true.
          ELSE.
            CLEAR <f_w_aprov_comissao>-conf.
          ENDIF.

          me->obj_alv->refresh( ).
      ENDCASE.
    ENDIF.

  ENDMETHOD.                    "on_link_click
ENDCLASS.                    "lcl_salv IMPLEMENTATION
