*&---------------------------------------------------------------------*
*&  Include           MYGED_GL_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  f_bloquear_campos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_bloquear_campos.
  CLEAR w_botoes.
  READ TABLE t_botoes
  INTO w_botoes
  INDEX 1.

  CHECK t_botoes      IS INITIAL
     OR w_botoes-novo IS NOT INITIAL.

  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'GR0'.
        screen-input = c_habilitar_campo.
        MODIFY SCREEN.
      WHEN 'GR1' OR 'GR2' OR 'GR3'.
        screen-input = c_desabilitar_campo.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    "f_bloquear_campos

*&---------------------------------------------------------------------*
*&      Form  f_desbloquear_campos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_desbloquear_campos.
  CLEAR w_botoes.
  READ TABLE t_botoes
  INTO w_botoes
  INDEX 1.

* Se já informou o tipo de documento, desbloqueia os outros campos
* se não deu click em 'Novo'
  IF w_botoes-tpdoc IS NOT INITIAL
    AND w_botoes-novo IS INITIAL.

    LOOP AT SCREEN.
      CASE screen-group1.
        WHEN 'GR0' OR 'GR3'.
          screen-input = c_desabilitar_campo.
          MODIFY SCREEN.
        WHEN 'GR1' OR 'GR2'.
          screen-input = c_habilitar_campo.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
  ENDIF.

* Verifica se já importou o arquivo
  IF w_botoes-file IS NOT INITIAL.
    LOOP AT SCREEN.
      CASE screen-group1.
        WHEN 'GR2'.
          screen-input = c_desabilitar_campo.
          MODIFY SCREEN.
        WHEN 'GR3'.
          screen-input = c_habilitar_campo.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
  ENDIF.

  IF w_botoes-novo IS NOT INITIAL.
    LOOP AT SCREEN.
      CASE screen-group1.
        WHEN 'GR0'.
          screen-input = c_habilitar_campo.
          MODIFY SCREEN.
        WHEN 'GR1' OR 'GR2' OR 'GR3'.
          screen-input = c_desabilitar_campo.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.

    w_botoes-novo = space.
    MODIFY t_botoes FROM w_botoes INDEX 1.
  ENDIF.
ENDFORM.                    "f_desbloquear_campos

*&---------------------------------------------------------------------*
*&      Form  f_inserir_novo_docto
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_inserir_novo_docto.
  DATA: v_resposta TYPE c.

  CHECK t_botoes IS NOT INITIAL.

  CLEAR w_botoes.
  READ TABLE t_botoes
  INTO w_botoes
  WITH KEY salv = space.

* Se não mandou salvar, pergunta se quer finalizar o processo
  IF sy-subrc = 0.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'GED - Documentos Fiscais'
        text_question         = 'Deseja inserir um novo documento sem salvar o atual?'
        text_button_1         = 'Sim'
        text_button_2         = 'Não'
        display_cancel_button = space
      IMPORTING
        answer                = v_resposta.

    IF v_resposta = c_sim.
      CLEAR: yged_gl_1000-typedoc    ,
             yged_gl_1001_alv-descrip,
             yged_gl_1000-validfrom  ,
             yged_gl_1000-validto    ,
             yged_gl_1000-descrip    ,
             yged_gl_1000-filename   .

      w_botoes-file  = space.
      w_botoes-tpdoc = space.
      w_botoes-novo  = 'X'  .
      MODIFY t_botoes FROM w_botoes INDEX 1.
    ELSE.
      CLEAR w_botoes-novo.
      MODIFY t_botoes FROM w_botoes INDEX 1.
    ENDIF.
  ELSE.

*   Se já salvou, limpa a tabela
    FREE t_botoes.

    w_botoes-novo = 'X'                  .
    MODIFY t_botoes FROM w_botoes INDEX 1.
  ENDIF.
ENDFORM.                    "f_inserir_novo_docto

*&---------------------------------------------------------------------*
*&      Form  f_selecionar_tp_docto
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_tipo  text
*----------------------------------------------------------------------*
FORM f_selecionar_tp_docto
  USING p_tipo TYPE yged_gl_1000-typedoc.

  FREE t_botoes.

* Mostra na tela o Tipo de documento selecionado
  CLEAR yged_gl_1001_alv-descrip.

  IF p_tipo IS NOT INITIAL.
    SELECT SINGLE descrip
     FROM ygedgl_param
     INTO yged_gl_1001_alv-descrip
     WHERE typedoc = p_tipo.

    IF sy-subrc = 0.
      w_botoes-tpdoc = 'X'.
      APPEND w_botoes TO t_botoes.
    ELSE.
      MESSAGE 'Tipo de documento não cadastrado na YGEDGL_PARAM' TYPE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_selecionar_tp_docto

*&---------------------------------------------------------------------*
*&      Form  f_carregar_doctos_obrigatorios
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_carregar_doctos_obrigatorios.
  FREE t_alv_obrig.

* Carrega os documentos que estão com a flag de obrigatório
  SELECT typedoc descrip extension
   FROM ygedgl_param
   INTO TABLE t_alv_obrig
    WHERE mandatory NE space.

  SORT t_alv_obrig BY typedoc ASCENDING.

  PERFORM f_montar_fieldcatalog
   TABLES t_fcat_stat
    USING w_fcat_stat c_alv_doc_obrig space.

  PERFORM f_montar_alv_doc_obrigatorios.
ENDFORM.                    "f_carregar_doctos_obrigatorios








*&---------------------------------------------------------------------*
*&      Form  f_carregar_doctos_cliente
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_cliente  text
*----------------------------------------------------------------------*
*FORM f_carregar_doctos_cliente
*  USING p_cliente TYPE yged_gl_1000-cliente.
*
*  DATA: v_versao TYPE ygedgl_doc-version.
*
*  FREE: t_tipo, t_alv_docto, tl_documentos.
*
** Seleciona os tipos de documento que o cliente possui
*  SELECT typedococ
*   FROM ygedgl_doc
*   INTO TABLE t_tipo.
**   WHERE kunnr = p_cliente.
*
*  DELETE ADJACENT DUPLICATES FROM t_tipo.
*
** Exibe só a última versão de cada documento
*  LOOP AT t_tipo INTO wl_tipo.
*    SELECT MAX( version )
*     FROM ygedgl_doc
*     INTO (v_versao)
*     WHERE typedoc = wl_tipo-typedoc.
*
*    SELECT * FROM ygedgl_doc
*      APPENDING TABLE tl_documentos
*      WHERE kunnr     = p_cliente
*        AND typedoc     = wl_tipo-typedoc
*        AND version   = v_versao.
*  ENDLOOP.
*
*  DELETE tl_documentos WHERE bloqueado = 'X'.
*
*  LOOP AT tl_documentos INTO w_documentos.
*    MOVE-CORRESPONDING w_documentos TO w_alv_docto.
*    APPEND w_alv_docto TO t_alv_docto.
*  ENDLOOP.
*
** Verifica se há dados cadastrados antes de passar para o ALV
*  CHECK LINES( t_alv_docto ) NE 0.
*
*  PERFORM f_verificar_status_docto.
*
*  SORT t_alv_docto BY typedoc ASCENDING.
*
*  PERFORM f_montar_fieldcatalog
*   TABLES t_fcat_doc
*    USING wl_fcat_doc c_alv_documentos 'X'.
*
** Se o container já foi inicializado, o ALV já foi exibido e o usuário
** quer verificar os detalhes de outro item. É necessário limpar a tabela
*  IF obj_cont_doc IS NOT INITIAL.
*    CALL METHOD obj_alv_docto->refresh_table_display.
*  ELSE.
*    PERFORM f_montar_alv_doctos.
*  ENDIF.
*
*ENDFORM.                    "f_carregar_doctos_cliente

*&---------------------------------------------------------------------*
*&      Form  f_verificar_status_docto
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_verificar_status_docto.

* Verifica se o documento está no prazo e altera o ícone de Status
  DATA:
    t_param TYPE STANDARD TABLE OF ygedgl_param,
    w_param LIKE LINE OF t_param              .

  DATA:
    v_qtd_dias TYPE i       ,
    v_indice  TYPE sy-tabix.

  SELECT * FROM ygedgl_param
   INTO TABLE t_param
   FOR ALL ENTRIES IN t_alv_docto
   WHERE typedoc = t_alv_docto-typedoc.

  LOOP AT t_alv_docto INTO w_alv_docto.
    v_indice = sy-tabix.

    CLEAR w_param.
    READ TABLE t_param
    INTO w_param
    WITH KEY typedoc = w_alv_docto-typedoc.

    CHECK sy-subrc EQ 0.

*   Diferença entre a data atual com o prazo de validade
*   informado pelo usuário (Válido Até)
    CALL FUNCTION 'HR_99S_INTERVAL_BETWEEN_DATES'
      EXPORTING
        begda = sy-datum
        endda = w_alv_docto-validto
      IMPORTING
        days  = v_qtd_dias.

    IF v_qtd_dias >= w_param-green AND v_qtd_dias > w_param-yellow.
      w_alv_docto-status = c_icone_verde.
    ELSEIF v_qtd_dias < w_param-green
       AND v_qtd_dias >= w_param-yellow
       OR v_qtd_dias > w_param-red.
      w_alv_docto-status = c_icone_amarelo.
    ELSEIF  v_qtd_dias <= w_param-red.
      w_alv_docto-status = c_icone_vermelho.
    ENDIF.

    w_alv_docto-bloquear = c_icone_desbloq.

    w_alv_docto-visualizar = c_icone_visualiz.
    MODIFY t_alv_docto FROM w_alv_docto INDEX v_indice.
  ENDLOOP. " LOOP AT t_alv_docto INTO w_alv_docto.

ENDFORM.                    "f_verificar_status_docto

*&---------------------------------------------------------------------*
*&      Form  f_qtd_doctos_obrigatorios
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_qtd_doctos_obrigatorios.
  DATA: v_qtd_doctos TYPE n.

  yged_gl_1000-qtd_docobrig = 'X de Y documentos obrigatórios'.

  LOOP AT t_alv_docto INTO w_alv_docto.
    SELECT COUNT( * )
     FROM ygedgl_param
     WHERE mandatory NE space
       AND typedoc = w_alv_docto-typedoc.

    IF sy-subrc EQ 0.
      v_qtd_doctos = v_qtd_doctos + 1.
    ENDIF.
  ENDLOOP.

  REPLACE 'X' WITH v_qtd_doctos INTO yged_gl_1000-qtd_docobrig.

  SELECT COUNT( * )
   FROM ygedgl_param
   INTO v_qtd_doctos
   WHERE mandatory NE space.

  REPLACE 'Y' WITH v_qtd_doctos INTO yged_gl_1000-qtd_docobrig.
ENDFORM.                    "f_qtd_doctos_obrigatorios

*&---------------------------------------------------------------------*
*&      Form  f_montar_alv_doctos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_montar_alv_doctos.
* Verifica se o container ainda não foi inicializado
  CHECK obj_cont_doc IS INITIAL.

  CREATE OBJECT obj_cont_doc
    EXPORTING
      container_name              = c_alv_doctos " CONT_DOC_CLI
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

* Cria uma instância da classe cl_gui_alv_grid no container CONT_DOC_CLI
* declarado no layout da tela 1000
  CREATE OBJECT obj_alv_docto
    EXPORTING
      i_parent          = obj_cont_doc
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.

* Atribui os métodos da classe local lcl_evento_alv à do ALV
  CREATE OBJECT obj_evt.
  SET HANDLER obj_evt->hotspot_click
  FOR obj_alv_docto.

* Layout do relatório ALV
  w_alv_layout-cwidth_opt = 'X'.
  w_alv_layout-zebra      = 'X'.
  w_alv_layout-no_toolbar = 'X'. " Exclui os botões da barra de tarefas do ALV

  CALL METHOD obj_alv_docto->set_table_for_first_display
    EXPORTING
      is_layout                     = w_alv_layout
    CHANGING
      it_outtab                     = t_alv_docto
      it_fieldcatalog               = t_fcat_doc
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

ENDFORM.                    "f_montar_alv_doctos

*&---------------------------------------------------------------------*
*&      Form  f_montar_alv_doc_obrigatorios
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_montar_alv_doc_obrigatorios.

* Se o container já foi inicializado, o ALV já foi exibido e o usuário
* quer verificar os detalhes de outro item. É necessário limpar a tabela
  IF obj_cont_stat IS NOT INITIAL.
    CALL METHOD obj_alv_stat->refresh_table_display.
  ENDIF.

* Verifica se o container ainda não foi inicializado
  CHECK obj_cont_stat IS INITIAL.

  CREATE OBJECT obj_cont_stat
    EXPORTING
      container_name              = c_alv_doctos_obrig " CONT_DOC_OBRIG
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

* Cria uma instância da classe cl_gui_alv_grid no container CONTAINER_STAT
* declarado no layout da tela 1000
  CREATE OBJECT obj_alv_stat
    EXPORTING
      i_parent          = obj_cont_stat
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.

  CLEAR: w_alv_layout.

* Layout do relatório ALV
  w_alv_layout-cwidth_opt = 'X'. "
  w_alv_layout-zebra      = 'X'. " Zebrado
  w_alv_layout-no_toolbar = 'X'. " Exclui os botões da barra de tarefas do ALV

  CALL METHOD obj_alv_stat->set_table_for_first_display
    EXPORTING
      is_layout                     = w_alv_layout
    CHANGING
      it_outtab                     = t_alv_obrig
      it_fieldcatalog               = t_fcat_stat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
ENDFORM.                    "f_montar_alv_doc_obrigatorios

*&---------------------------------------------------------------------*
*&      Form  f_montar_fieldcatalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_t_fcat  text
*      -->p_w_fcat  text
*      -->p_tabela  text
*      -->p_hotspot text
*----------------------------------------------------------------------*
FORM f_montar_fieldcatalog
  TABLES p_t_fcat TYPE lvc_t_fcat
   USING p_w_fcat TYPE lvc_s_fcat
         p_tabela  TYPE ddobjname
         p_hotspot TYPE c.

  DATA: t_campos TYPE STANDARD TABLE OF dd03p,
        w_campos LIKE LINE OF t_campos      .

  DATA: vl_campo       TYPE rollname       ,
        vl_nome_coluna TYPE dd04t-scrtext_s.

* Obtém o nome dos campos da estrutura da SE11
  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name          = p_tabela
      state         = c_versao_ativa
    TABLES
      dd03p_tab     = t_campos
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  LOOP AT t_campos INTO w_campos.
    vl_campo = w_campos-rollname.

* Seleciona a descrição do elemento de dados
    SELECT SINGLE scrtext_s
    FROM  dd04t
    INTO (vl_nome_coluna)
     WHERE rollname  = vl_campo
      AND ddlanguage = c_pt_br
      AND as4local   = c_versao_ativa.

* Verifica quais se algum dos campos deve ter hotspot
    IF p_hotspot IS NOT INITIAL.
      CASE w_campos-fieldname.
        WHEN c_hotspot_visual OR c_hotspot_bloq.
          p_w_fcat-hotspot = 'X'.
          p_w_fcat-icon    = 'X'.
        WHEN 'STATUS' OR 'BLOQUEAR'.
          p_w_fcat-icon    = 'X'.
      ENDCASE.
    ENDIF.

    p_w_fcat-fieldname  = w_campos-fieldname.
    p_w_fcat-coltext    = vl_nome_coluna     .
    p_w_fcat-outputlen  = w_campos-outputlen.

    APPEND p_w_fcat TO p_t_fcat             .
    CLEAR p_w_fcat.
  ENDLOOP.
ENDFORM.                    "f_montar_fieldcatalog

*&---------------------------------------------------------------------*
*&      Form  f_carregar_arquivo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_carregar_arquivo.
* Carregar o arquivo dentro do txt_arquivo
  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    CHANGING
      file_name = rlgrap-filename.

  CHECK rlgrap-filename IS NOT INITIAL.
  PERFORM f_verificar_extensao.

* Copia o caminho + nome do arquivo para a tela
  yged_gl_1000-filename = rlgrap-filename.

  w_botoes-file = 'X'                  .
  MODIFY t_botoes FROM w_botoes INDEX 1.
ENDFORM.                    " f_carregar_arquivo

*&---------------------------------------------------------------------*
*&      Form  f_salvar_arquivo_dms
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_salvar_arquivo_dms.
  DATA:
    tl_objectlinks TYPE STANDARD TABLE OF bapi_doc_drad   WITH HEADER LINE,
    t_doc_file    TYPE STANDARD TABLE OF bapi_doc_files2 WITH HEADER LINE.

  DATA:
    w_dados_docto  TYPE bapi_doc_draw2,
    wl_return      TYPE bapiret2      .

  DATA:
    v_versao          TYPE ygedgl_doc-version            ,
    vl_documentversion TYPE bapi_doc_draw2-documentversion,
    vl_qtd_tp_doc      TYPE n                             .


  w_botoes-salv = 'X'                  .
  MODIFY t_botoes FROM w_botoes INDEX 1.

  EXIT.

* Verifica se já há alguma versão cadastrada desse tipo de documento
* para o cliente
*  SELECT COUNT( * )
*   FROM ygedgl_doc
*   INTO (vl_qtd_tp_doc)
*   WHERE kunnr = yged_gl_1000-cliente
*     AND typedoc = yged_gl_1000-typedoc.

* Se já houver alguma versão cadastrada acrescenta 1 à versão dele (a versão inicial é zero)
  IF vl_qtd_tp_doc > 0.
*    SELECT MAX( version )
*      FROM ygedgl_doc
*       INTO v_versao
*       WHERE kunnr = yged_gl_1000-cliente
*         AND typedoc = yged_gl_1000-typedoc.

    IF sy-subrc EQ 0.
      v_versao = v_versao + 1.
    ENDIF.
  ENDIF.

  WRITE v_versao TO vl_documentversion.

* Completa o código do cliente com zeros à esquerda
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = vl_documentversion
    IMPORTING
      output = vl_documentversion.

  PERFORM: f_validar_campos          ,
           f_verificar_extensao      ,
           f_verificar_prazo_validade.

* Verifica se a data de vencimento é inferior a data de validade.
* e o usuário mesmo assim deseja inserir
* Se a variável estiver vazia, está no prazo correto
  CHECK v_resp EQ c_sim OR v_resp IS INITIAL.

*  SHIFT yged_gl_1000-cliente LEFT DELETING LEADING '0'.

*  CONCATENATE yged_gl_1000-cliente
*              yged_gl_1000-typedoc
*  INTO w_dados_docto-documentnumber.

  w_dados_docto-documenttype    = c_contas_receber    . " YAR
  w_dados_docto-documentversion = vl_documentversion  .
  w_dados_docto-documentpart    = '00'                .
  w_dados_docto-description     = yged_gl_1000-descrip.
  w_dados_docto-username        = sy-uname            .
  w_dados_docto-statusintern    = c_liberado          . " FR
  w_dados_docto-statuslog       = c_arquivado         . " Arquivado
  w_dados_docto-laboratory      = c_cta_receber       . " FAR

  tl_objectlinks-objecttype = c_objeto_sap        .         " KNA1
*  tl_objectlinks-objectkey  = yged_gl_1000-cliente.
  APPEND tl_objectlinks.

  t_doc_file-storagecategory = c_categ_arquiv. " ACHE_AR
  t_doc_file-docpath         = v_caminho    .
  t_doc_file-docfile         = v_arquivo    .

  CONCATENATE '*.' space v_extensao INTO v_extensao.
  TRANSLATE v_extensao TO LOWER CASE.

* Aplicação estação de trabalho
  SELECT SINGLE dappl
   FROM tdwp
    INTO (t_doc_file-wsapplication)
    WHERE dateifrmt = v_extensao.

  APPEND t_doc_file.

  IF t_doc_file-wsapplication IS INITIAL.
    MESSAGE 'Aplicação não definida na TDWP'(001) TYPE 'I'.
  ELSE.

* Cria o documento no DMS (transação CV01N)
    CALL FUNCTION 'BAPI_DOCUMENT_CREATE2'
      EXPORTING
        documentdata  = w_dados_docto
      IMPORTING
        return        = wl_return
      TABLES
        objectlinks   = tl_objectlinks
        documentfiles = t_doc_file.

    IF wl_return-type = c_erro_bapi.
      MESSAGE wl_return-message TYPE 'I'.
    ELSE.
      ygedgl_doc-typedoc   = yged_gl_1000-typedoc    .
      ygedgl_doc-validfrom = yged_gl_1000-validfrom.
      ygedgl_doc-validto   = yged_gl_1000-validto  .
      ygedgl_doc-descrip   = yged_gl_1000-descrip  .
      ygedgl_doc-version   = v_versao             .
      MODIFY ygedgl_doc FROM ygedgl_doc.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      IF wl_return-message IS NOT INITIAL.
        MESSAGE wl_return-message TYPE 'I'.
      ELSE.
        MESSAGE 'Arquivo importado com sucesso'(010) TYPE 'I'.
      ENDIF.

      CLEAR: yged_gl_1000-typedoc     ,
             yged_gl_1000-validfrom   ,
             yged_gl_1000-validto     ,
             yged_gl_1000-descrip     ,
             yged_gl_1000-filename    ,
             yged_gl_1001_alv-descrip . " Descrição do Tipo do documento

*      PERFORM f_carregar_doctos_cliente
*       USING yged_gl_1000-cliente.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_salvar_arquivo_dms

*&---------------------------------------------------------------------*
*&      Form  f_validar_campos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_validar_campos.
  DATA: vl_erro TYPE c.

*  IF yged_gl_1000-typedoc IS INITIAL.
*    MESSAGE 'Informe o tipo do documento'(015) TYPE 'I'.
*    vl_erro = 'X'.
*  ELSEIF yged_gl_1000-validfrom IS INITIAL.
*    MESSAGE 'Informe a data inicial de validade'(012) TYPE 'I'.
*    vl_erro = 'X'.
*  ELSEIF yged_gl_1000-validto IS INITIAL.
*    MESSAGE 'Informe a data final de validade'(013) TYPE 'I'.
*    vl_erro = 'X'.
*  ELSEIF yged_gl_1000-descrip IS INITIAL.
*    MESSAGE 'Informe a descrição'(014) TYPE 'I'.
*    vl_erro = 'X'.
*  ELSEIF yged_gl_1000-filename IS INITIAL.
*    MESSAGE 'Selecione um arquivo'(009) TYPE 'I'.
*    vl_erro = 'X'.
*  ENDIF.
*
*  IF vl_erro = 'X'.
*    EXIT.
*  ENDIF.
ENDFORM.                    "f_validar_campos

*&---------------------------------------------------------------------*
*&      Form  f_verificar_extensao
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_verificar_extensao.
  FREE t_extensao.
  CLEAR: v_caminho ,
         v_arquivo ,
         v_extensao.

  CHECK rlgrap-filename IS NOT INITIAL.

  v_arq_comp = rlgrap-filename.

* Verifica as extensões válidas cadastradas no domínio YDEXTENSION
  CALL FUNCTION 'DDIF_DOMA_GET'
    EXPORTING
      name      = 'YDEXTENSION'
      state     = 'A'
      langu     = sy-langu
    TABLES
      dd07v_tab = t_extensao.

* Verifica a extensão do arquivo que o usuário selecionou
  CALL FUNCTION 'DSVAS_DOC_FILENAME_SPLIT'
    EXPORTING
      pf_docid     = v_arq_comp
    IMPORTING
      pf_directory = v_caminho
      pf_filename  = v_arquivo
      pf_extension = v_extensao.

  TRANSLATE v_extensao TO UPPER CASE.

* Verifica se a extensão do arquivo é permitida
  CLEAR w_extensao.
  READ TABLE t_extensao
  INTO w_extensao
  WITH KEY domvalue_l = v_extensao.

  IF sy-subrc NE 0.
    MESSAGE 'Extensão não permitida'(002) TYPE 'E'.

    CLEAR: rlgrap-filename      ,
           yged_gl_1000-filename.
  ENDIF.
ENDFORM.                    "f_verificar_extensao

*&---------------------------------------------------------------------*
*&      Form  f_verificar_prazo_validade
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_verificar_prazo_validade.

* Verifica se o documento está no prazo e altera o ícone de Status
  DATA:
    t_param TYPE STANDARD TABLE OF ygedgl_param,
    w_param LIKE LINE OF t_param              .

  DATA:
    v_data          TYPE p0001-begda,
    v_dias          TYPE t5a4a-dlydy,
    v_meses         TYPE t5a4a-dlymo,
    v_anos          TYPE t5a4a-dlyyr,
    v_data_validade TYPE p0001-begda,
    v_qtd_dias_info TYPE i          ,
    v_qtd_dias_vali TYPE i          .

  SELECT * FROM ygedgl_param
   INTO TABLE t_param
   WHERE typedoc = yged_gl_1000-typedoc.

  CLEAR w_param.
  READ TABLE t_param
  INTO w_param
  WITH KEY typedoc = yged_gl_1000-typedoc.

  CHECK sy-subrc EQ 0.

  v_data  = yged_gl_1000-validfrom.
  v_dias  = w_param-exp_day      .
  v_meses = w_param-exp_months   .
  v_anos  = w_param-exp_year     .

* Verifica o prazo de validade de acordo com os parâmetros
* cadastrados na tabela ygedgl_param
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = v_data
      days      = v_dias
      months    = v_meses
      signum    = '+'
      years     = v_anos
    IMPORTING
      calc_date = v_data_validade.

* Diferença entre a data atual com o prazo de validade
  CALL FUNCTION 'HR_99S_INTERVAL_BETWEEN_DATES'
    EXPORTING
      begda = sy-datum
      endda = v_data_validade
    IMPORTING
      days  = v_qtd_dias_vali.

* Diferença entre a data de validade de/até informado
  CALL FUNCTION 'HR_99S_INTERVAL_BETWEEN_DATES'
    EXPORTING
      begda = yged_gl_1000-validfrom
      endda = yged_gl_1000-validto
    IMPORTING
      days  = v_qtd_dias_info.

  IF v_qtd_dias_info < v_qtd_dias_vali.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        text_question         = 'Data de vencimento inferior a data de validade. Deseja inserir?'(016)
        text_button_1         = 'Sim'(005)
        text_button_2         = 'Não'(006)
        display_cancel_button = space
      IMPORTING
        answer                = v_resp.
  ENDIF.

ENDFORM.                    "f_verificar_prazo_validade

*&---------------------------------------------------------------------*
*&      Form  event_hotspot_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ROW      text
*      -->P_COLUMN   text
*----------------------------------------------------------------------*
FORM event_hotspot_click
 USING p_row    TYPE lvc_s_row
       p_column TYPE lvc_s_col.

  READ TABLE t_alv_docto
  INTO w_alv_docto
  INDEX p_row-index.

  CASE p_column.
    WHEN c_hotspot_visual. " VISUALIZAR
      PERFORM f_visualizar_arquivo_dms
       USING w_alv_docto-typedoc.
    WHEN c_hotspot_bloq. " BLOQUEAR
      PERFORM f_bloquear_documento
        USING p_row
              w_alv_docto-typedoc.
  ENDCASE.
ENDFORM.                    "event_hotspot_click

*&---------------------------------------------------------------------*
*&      Form  f_visualizar_arquivo_dms
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_typedoc    text
*----------------------------------------------------------------------*
FORM f_visualizar_arquivo_dms
  USING p_typedoc TYPE ygedgl_param-typedoc.

  DATA:
   v_nro_doc    TYPE draw-doknr ,
   v_ver_doc    TYPE n          ,
   v_versao     TYPE draw-dokvr ,
   v_arquivo    TYPE draw-filep ,
   v_url_dms    TYPE mcdok-url  ,
   v_visualizar TYPE c LENGTH 01.

** Completa o código do cliente com zeros à esquerda
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = yged_gl_1000-cliente
*    IMPORTING
*      output = yged_gl_1000-cliente.

* Última versão do documento selecionado
*  SELECT MAX( version )
*   FROM ygedgl_doc
*   INTO v_ver_doc
*   WHERE kunnr = yged_gl_1000-cliente
*   AND typedoc = p_typedoc.

  WRITE v_ver_doc TO v_versao.

* Completa o código da versão com zeros à esquerda
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = v_versao
    IMPORTING
      output = v_versao.

*  SHIFT yged_gl_1000-cliente LEFT DELETING LEADING '0'.

*  CONCATENATE yged_gl_1000-cliente
*              p_typedoc
*  INTO v_nro_doc.

  CALL FUNCTION 'CVAPI_DOC_VIEW'
    EXPORTING
      pf_dokar         = c_contas_receber " YAR
      pf_doknr         = v_nro_doc
      pf_dokvr         = v_versao
      pf_doktl         = c_doc_parcial                      " 0000
    IMPORTING
      pfx_file         = v_arquivo
      pfx_url          = v_url_dms
      pfx_view_inplace = v_visualizar
    EXCEPTIONS
      error            = 1
      not_found        = 2
      no_auth          = 3
      no_original      = 4
      OTHERS           = 5.

  IF v_arquivo IS INITIAL.
    MESSAGE 'Documento não cadastrado'(004) TYPE 'I'.
  ENDIF.

ENDFORM.                    "f_visualizar_arquivo_dms

*&---------------------------------------------------------------------*
*&      Form  f_bloquear_documento
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_row     text
*      -->p_typedoc text
*----------------------------------------------------------------------*
FORM f_bloquear_documento
  USING p_row   TYPE lvc_s_row
        p_typedoc TYPE ygedgl_param-typedoc.

  DATA: t_campo TYPE STANDARD TABLE OF sval,
        w_campo LIKE LINE OF t_campo      .

  DATA: v_versao TYPE ygedgl_doc-version.

  w_campo-tabname   = 'YGEDGL_DOC'.
  w_campo-fieldname = 'MOTIVO_BLOQ'.
  APPEND w_campo TO t_campo.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title     = 'Bloquear documento'(007)
      start_column    = 40
      start_row       = 15
    TABLES
      fields          = t_campo
    EXCEPTIONS
      error_in_fields = 1
      OTHERS          = 2.

  READ TABLE t_campo
  INTO w_campo
  INDEX 1.

* Se algum valor foi informado no popup, altera a tabela
  CHECK w_campo-value IS NOT INITIAL.

  w_alv_docto-bloquear   = c_icone_bloquear.
  MODIFY t_alv_docto FROM w_alv_docto INDEX p_row.

  FREE: t_tipo.

* Seleciona os tipos de documento que o cliente possui
*  SELECT typedoc
*   FROM ygedgl_doc
*   INTO TABLE t_tipo
*   WHERE kunnr = yged_gl_1000-cliente
*     AND typedoc = p_typedoc .

* O documento exibido no ALV é sempre a maior versão, por isso
* é necessário verificar novamente para alterar o registro certo
*  SELECT MAX( version )
*   FROM ygedgl_doc
*   INTO (v_versao)
*   WHERE kunnr = yged_gl_1000-cliente
*     AND typedoc = p_typedoc .
*
*  SELECT SINGLE * FROM ygedgl_doc
*   INTO w_documentos
*    WHERE kunnr   = yged_gl_1000-cliente
*      AND typedoc   = p_typedoc
*      AND version = v_versao.

  w_documentos-bloqueado   = 'X'          .
  w_documentos-motivo_bloq = w_campo-value.

  MODIFY ygedgl_doc FROM w_documentos.

*  PERFORM f_carregar_doctos_cliente
*   USING yged_gl_1000-cliente.
ENDFORM.                    "f_bloquear_documento