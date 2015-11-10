*----------------------------------------------------------------------*
*                       ACHÉ LABORATÓRIOS                              *
*----------------------------------------------------------------------*
* Programa : YBR_FOLHA_REL                                             *
* Transação: YBR_FOLHA_REL                                             *
* Tipo     : Relatório ALV                                             *
* Módulo   : FI-AR (contas a receber)                                  *
* Funcional: Uderson Luiz Fermino                                      *
* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          *
* Descrição: Relatório com resultados dos ganhos obtidos na desoneração*
*            da folha de pagamento                                     *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  10.09.2013  #57551 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

REPORT  ybr_folha_rel NO STANDARD PAGE HEADING.

TABLES: ybr_folha_result.

*----------------------------------------------------------------------*
* Tabelas internas                                                     *
*----------------------------------------------------------------------*
DATA: t_alv    TYPE STANDARD TABLE OF ybr_folha_result,
      t_fieldcat TYPE lvc_t_fcat                     . " Fieldcatalog (campos ALV)

*----------------------------------------------------------------------*
* Ranges                                                               *
*----------------------------------------------------------------------*
DATA:
  r_data_inicial TYPE RANGE OF sy-datum,
  r_data_final   TYPE RANGE OF sy-datum.

*----------------------------------------------------------------------*
* Work Areas                                                           *
*----------------------------------------------------------------------*
DATA: w_alv      LIKE LINE OF t_alv         ,
      w_data     LIKE LINE OF r_data_inicial,
      w_fieldcat TYPE lvc_s_fcat            .

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
CONSTANTS:
  c_cont_alv_deso TYPE scrfname  VALUE 'CONT_DESONERACAO',
  c_alv_deso      TYPE ddobjname VALUE 'YBR_FOLHA_RESULT',
  c_icone_verde   TYPE c LENGTH 04 VALUE '@08@'          ,
  c_icone_amarelo TYPE c LENGTH 04 VALUE '@09@'          .

*----------------------------------------------------------------------*
* Objetos                                                              *
*----------------------------------------------------------------------*
DATA:
  obj_container TYPE REF TO cl_gui_custom_container,
  obj_alv_grid  TYPE REF TO cl_gui_alv_grid        .

*----------------------------------------------------------------------*
* Tela de seleção                                                      *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_emp  FOR ybr_folha_result-empresa OBLIGATORY,
  s_data FOR sy-datum                           .
SELECTION-SCREEN END OF BLOCK b1                .

*----------------------------------------------------------------------*
* Inicio                                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_buscar_dados.

  IF t_alv IS NOT INITIAL.
    SORT t_alv BY empresa dt_doc_de dt_doc_ate ASCENDING.

    PERFORM f_montar_fieldcatalog
     TABLES t_fieldcat
      USING w_fieldcat
            c_alv_deso " YBR_FOLHA_RESULT
            'X'.

    PERFORM f_montar_alv
      USING obj_container
            obj_alv_grid
            c_cont_alv_deso " CONT_DESONERACAO
            t_fieldcat
            t_alv
            space
            space.

    CALL SCREEN 1001.
  ELSE.
    MESSAGE 'Dados não encontrados' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  f_buscar_dados
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_buscar_dados.
  LOOP AT s_data.
    w_data-option = 'EQ'           .
    w_data-sign   = 'I'            .
    w_data-low    = s_data-low     .
    APPEND w_data TO r_data_inicial.

    IF s_data-high IS NOT INITIAL.
      w_data-option = 'EQ'           .
      w_data-sign   = 'I'            .
      w_data-low    = s_data-high    .
      APPEND w_data TO r_data_final  .
    ENDIF.
  ENDLOOP.

  SELECT mandt empresa dt_doc_de dt_doc_ate vend_totais revend_outr
         inss_emp br_maior_pg inss_pagar tot_cont_prev
         ganho ganho_perc webservice
  FROM ybr_folha_result
  INTO TABLE t_alv
    WHERE empresa    IN s_emp
      AND dt_doc_de  IN r_data_inicial
      AND dt_doc_ate IN r_data_final.

  DATA: vl_indice TYPE sy-tabix.

  LOOP AT t_alv INTO w_alv.
    vl_indice = sy-tabix.

    IF w_alv-webservice IS NOT INITIAL.
      w_alv-webservice = c_icone_verde.
    ELSE.
      w_alv-webservice = c_icone_amarelo.
    ENDIF.

    MODIFY t_alv FROM w_alv INDEX vl_indice.
  ENDLOOP.
ENDFORM.                    "f_buscar_dados

*----------------------------------------------------------------------*
* MODULE status_1001 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE status_1001 OUTPUT.
  SET PF-STATUS 'S1001'.

* Resultado dos ganhos da desoneração da folha de pagamento
  SET TITLEBAR 'T1001'.
ENDMODULE.                                           "status_0001 OUTPUT

*----------------------------------------------------------------------*
* MODULE USER_COMMAND_0001 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE user_command_1001 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE. "USER_COMMAND_0001 INPUT

*&---------------------------------------------------------------------*
*&      Form  f_montar_fieldcatalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_t_fcat   text
*      -->p_w_fcat   text
*      -->P_STRUCTURE text
*      -->P_HOSTPOT   text
*----------------------------------------------------------------------*
FORM f_montar_fieldcatalog
  TABLES p_t_fcat    TYPE lvc_t_fcat
   USING p_w_fcat    TYPE lvc_s_fcat
         p_structure TYPE ddobjname
         p_hostpot   TYPE c        .

  DATA: t_campos TYPE STANDARD TABLE OF dd03p,
        w_campos LIKE LINE OF t_campos      .

  DATA: v_campo       TYPE rollname       ,
        v_nome_coluna TYPE dd04t-scrtext_m.

  CONSTANTS:
    c_versao_ativa  TYPE ddobjstate VALUE 'A' ,
    c_pt_br         TYPE t002-laiso VALUE 'PT'.

  FREE: p_t_fcat, p_w_fcat.

* Obtém o nome dos campos da estrutura da SE11
  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name          = p_structure
      state         = c_versao_ativa
    TABLES
      dd03p_tab     = t_campos
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  LOOP AT t_campos INTO w_campos.
    v_campo = w_campos-rollname.

    CHECK v_campo NE 'MANDT'.

*   Seleciona a descrição média do elemento de dados
    SELECT SINGLE scrtext_m
    FROM  dd04t
    INTO (v_nome_coluna)
     WHERE rollname  = v_campo
      AND ddlanguage = c_pt_br
      AND as4local   = c_versao_ativa.

    IF w_campos-fieldname = 'WEBSERVICE'.
      p_w_fcat-hotspot = 'X'.
      p_w_fcat-icon    = 'X'.
    ENDIF.

    MOVE-CORRESPONDING w_campos TO p_w_fcat.
    p_w_fcat-coltext = v_nome_coluna.
    p_w_fcat-col_pos = sy-tabix     .

    APPEND p_w_fcat TO p_t_fcat.
    CLEAR p_w_fcat.
  ENDLOOP.
ENDFORM.                    "f_montar_fieldcatalog

*&---------------------------------------------------------------------*
*&      Form  f_montar_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONTAINER text
*      -->P_ALV_GRID  text
*      -->P_NOME_CONT text
*      -->P_FIELDCAT  text
*      -->P_T_ALV     text
*      -->P_TITULO    text
*      -->P_TOOLBAR   text
*----------------------------------------------------------------------*
FORM f_montar_alv
 USING p_container  TYPE REF TO cl_gui_custom_container
       p_alv_grid   TYPE REF TO cl_gui_alv_grid
       p_nome_cont  TYPE scrfname
       p_fieldcat   TYPE lvc_t_fcat
       p_t_alv      TYPE STANDARD TABLE
       p_titulo     TYPE lvc_s_layo-grid_title
       p_no_toolbar TYPE c.

  IF p_container IS NOT INITIAL.
    p_container->free( ).
  ENDIF.

  CREATE OBJECT p_container
    EXPORTING
      container_name = p_nome_cont
    EXCEPTIONS
      OTHERS         = 6.

* Cria uma instância da classe cl_gui_alv_grid no custom container
* inserido no layout da tela
  CREATE OBJECT p_alv_grid
    EXPORTING
      i_parent = p_container
    EXCEPTIONS
      OTHERS   = 5.

  DATA: w_alv_layout TYPE lvc_s_layo.
  w_alv_layout-zebra      = 'X'     . " Zebrado
  w_alv_layout-cwidth_opt = 'X'     . " Otimização da coluna
  w_alv_layout-grid_title = p_titulo. " Titulo do ALV

* Exclui os botões da barra de tarefas do ALV (Exportar p/ Excel)
  IF p_no_toolbar IS NOT INITIAL.
    w_alv_layout-no_toolbar = p_no_toolbar.
  ENDIF.

  p_alv_grid->set_table_for_first_display(
     EXPORTING
       is_layout       = w_alv_layout
     CHANGING
       it_outtab       = p_t_alv
       it_fieldcatalog = p_fieldcat
     EXCEPTIONS
       OTHERS          = 4 ).

  p_alv_grid->refresh_table_display( ).

ENDFORM.                    "f_montar_alv