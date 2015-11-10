*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Programa : YMMR_OL018                                                *
* Transação: YMMR_OL018                                                *
* Tipo     : Report                                                    *
* Módulo   : MM/WM                                                     *
* Funcional: Sergio Vieira de Alcântara / Danilo Morente Carrasco      *
* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          *
* Descrição: Atualização do inventário através da entrada do resultado *
*            de contagem (T-CODE LI11N) por uma planilha do excel      *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  26.11.2014  #93085 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

REPORT ymmr_ol018 NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
* Variáveis Globais
*----------------------------------------------------------------------*
DATA:
    ok_code TYPE sy-ucomm.

*----------------------------------------------------------------------*
* Tela de seleção
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t001              . " Critérios de seleção
PARAMETER: p_lgnum TYPE linv-lgnum OBLIGATORY                         , " Nº depósito/complexo de depósito
           p_ivnum TYPE linv-ivnum OBLIGATORY                         . " Nº documento de inventário
SELECTION-SCREEN END OF BLOCK b1                                      .

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE t002              .
PARAMETER: p_arquiv TYPE rlgrap-filename DEFAULT 'C:\Temp\' OBLIGATORY. "#EC NOTEXT
SELECTION-SCREEN END OF BLOCK b2                                      .

*----------------------------------------------------------------------*
* Process On Value Request
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_arquiv.
  DATA:
    t_filetable   TYPE filetable,
    v_cod_retorno TYPE i        .

  FIELD-SYMBOLS:
    <w_filetable> LIKE LINE OF t_filetable.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title      = 'Selecione uma planilha excel'    "#EC NOTEXT
      default_extension = '*.XLS'                           "#EC NOTEXT
      file_filter       = '*.XLS'                           "#EC NOTEXT
    CHANGING
      file_table        = t_filetable
      rc                = v_cod_retorno
    EXCEPTIONS
      OTHERS            = 4.

  IF sy-subrc = 0.
    READ TABLE t_filetable
    ASSIGNING <w_filetable>
    INDEX 1.

    IF <w_filetable> IS ASSIGNED.
      p_arquiv = <w_filetable>-filename.
    ENDIF.
  ENDIF.

*----------------------------------------------------------------------*
* Inicialização                                                        *
*----------------------------------------------------------------------*
INITIALIZATION.
  t001 = 'Inventário'(001).                                 "#EC NOTEXT
  t002 = 'Selecione a planilha'(002).                       "#EC NOTEXT

*----------------------------------------------------------------------*
*       CLASS lcl_alv DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_alv DEFINITION.
  PUBLIC SECTION.
    CONSTANTS:
      c_nome_cont  TYPE scrfname VALUE 'C_ALV_LOG',
      c_btn_back   TYPE sy-ucomm VALUE 'BACK'     ,
      c_btn_leave  TYPE sy-ucomm VALUE 'LEAVE'    ,
      c_btn_cancel TYPE sy-ucomm VALUE 'CANCEL'   .

    DATA:
      o_container TYPE REF TO cl_gui_custom_container,
      o_alv_grid  TYPE REF TO cl_gui_alv_grid        .

    METHODS: exibir_relatorio
      CHANGING ex_fieldcatalog TYPE lvc_t_fcat
               ex_tabela       TYPE STANDARD TABLE.
ENDCLASS.                    "lcl_alv DEFINITION

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
START-OF-SELECTION.
  DATA:
    o_inventario TYPE REF TO ycl_inventario,
    o_abap_util  TYPE REF TO ycl_abap_util ,
    o_alv        TYPE REF TO lcl_alv       ,
    o_cx_root    TYPE REF TO cx_root       .

  DATA:
    w_log    TYPE ycl_inventario=>ty_log,
    t_fc_log TYPE lvc_t_fcat            .

  TRY.
      CREATE OBJECT: o_abap_util, o_inventario, o_alv.

      o_inventario->deposito       = p_lgnum.
      o_inventario->doc_inventario = p_ivnum.

      o_abap_util->upload_excel_itab( EXPORTING im_arquivo  = p_arquiv
                                       CHANGING ex_t_tabela = o_inventario->t_excel ).

      o_inventario->validar_doc_inventario( im_deposito       = o_inventario->deposito
                                            im_doc_inventario = o_inventario->doc_inventario ).

      o_inventario->validar_excel( CHANGING ex_t_excel      = o_inventario->t_excel
                                            ex_t_inventario = o_inventario->t_inventario
                                            ex_t_log        = o_inventario->t_log ).

      o_inventario->atualizar_inventario( CHANGING ex_t_inventario = o_inventario->t_inventario
                                                   ex_t_log        = o_inventario->t_log ).

      IF o_inventario->t_log IS NOT INITIAL.
        t_fc_log = o_abap_util->gerar_fieldcatalog( im_w_estrutura = w_log ).

        o_alv->exibir_relatorio( CHANGING ex_fieldcatalog = t_fc_log
                                          ex_tabela       = o_inventario->t_log ).
      ENDIF.

    CATCH cx_root INTO o_cx_root.                        "#EC CATCH_ALL
      DATA v_msg_erro TYPE string.

      v_msg_erro = o_cx_root->get_longtext( ).
      MESSAGE v_msg_erro TYPE 'S' DISPLAY LIKE 'E'.         "#EC NOTEXT
  ENDTRY.

*----------------------------------------------------------------------*
*       CLASS lcl_alv IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_alv IMPLEMENTATION.
*&---------------------------------------------------------------------*
*&      Method  exibir_relatorio
*&---------------------------------------------------------------------*
* <-- CHANGING ex_fieldcatalog TYPE lvc_t_fcat
* <-- CHANGING ex_tabela       TYPE STANDARD TABLE.
*----------------------------------------------------------------------*
  METHOD exibir_relatorio.

    IF o_container IS NOT INITIAL.
      o_alv_grid->refresh_table_display( ).
      o_container->set_visible( EXPORTING visible = abap_false ).
      FREE o_container.
    ENDIF.

    CREATE OBJECT o_container
      EXPORTING
        container_name = me->c_nome_cont
      EXCEPTIONS
        OTHERS         = 6.

    CREATE OBJECT o_alv_grid
      EXPORTING
        i_parent = o_container
      EXCEPTIONS
        OTHERS   = 5.

    DATA: w_alv_layout TYPE lvc_s_layo.
    w_alv_layout-zebra      = abap_true. " Zebrado
    w_alv_layout-cwidth_opt = abap_true. " Otimização da coluna

    CALL METHOD o_alv_grid->set_table_for_first_display
      EXPORTING
        is_layout       = w_alv_layout
      CHANGING
        it_outtab       = ex_tabela
        it_fieldcatalog = ex_fieldcatalog
      EXCEPTIONS
        OTHERS          = 4.

    o_alv_grid->refresh_table_display( ).

    CALL SCREEN 1001.
  ENDMETHOD.                    "exibir_relatorio
ENDCLASS.                    "lcl_alv IMPLEMENTATION


*----------------------------------------------------------------------*
* MODULE status_1001 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE status_1001 OUTPUT.
  SET PF-STATUS 'S1001'.

* OL - Atualização do inventário - LI11N
  SET TITLEBAR 'T1001'.
ENDMODULE.                                           "status_0001 OUTPUT

*----------------------------------------------------------------------*
* MODULE user_command_0001 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE user_command_1001 INPUT.
  CASE ok_code.
    WHEN lcl_alv=>c_btn_back
      OR lcl_alv=>c_btn_leave
      OR lcl_alv=>c_btn_cancel.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE. "user_command_1001 INPUT