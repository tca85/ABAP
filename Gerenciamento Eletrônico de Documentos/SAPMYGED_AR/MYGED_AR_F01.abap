*----------------------------------------------------------------------*
***INCLUDE MYGED_AR_F01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  f_selecionar_cliente
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CLIENTE  text
*----------------------------------------------------------------------*
FORM f_selecionar_cliente
  USING p_cliente TYPE yged_ar_1000-cliente.

  FREE tl_alv_docto.
  CLEAR: kna1-name1,
         yged_ar_1000-qtd_docobrig.

  IF p_cliente IS NOT INITIAL.
    SELECT SINGLE name1
     FROM kna1
     INTO (kna1-name1)
     WHERE kunnr = p_cliente.

    IF sy-subrc NE 0.
      CLEAR kna1-name1.
      MESSAGE 'Cliente não encontrado'(008) TYPE 'E'.
    ELSE.
      PERFORM f_carregar_doctos_cliente
       USING p_cliente.

      IF tl_alv_docto IS NOT INITIAL.
        PERFORM f_qtd_doctos_obrigatorios.
      ENDIF.
    ENDIF.

  ELSE.
    IF obj_cont_doc IS NOT INITIAL.
      CALL METHOD obj_alv_docto->refresh_table_display.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_selecionar_cliente

*&---------------------------------------------------------------------*
*&      Form  f_carregar_xd03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CLIENTE  text
*----------------------------------------------------------------------*
FORM f_carregar_xd03
 USING p_cliente TYPE yged_ar_1000-cliente.

* Código para o evento foi inserido no Status GUI S1000 com o nome 'PICK'
  IF p_cliente IS NOT INITIAL.
    SET PARAMETER ID 'KUN' FIELD p_cliente.
    CALL TRANSACTION 'XD03' AND SKIP FIRST SCREEN.
  ENDIF.
ENDFORM.                    "f_carregar_xd03

*&---------------------------------------------------------------------*
*&      Form  f_selecionar_tp_docto
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TIPO  text
*----------------------------------------------------------------------*
FORM f_selecionar_tp_docto
  USING p_tipo TYPE yged_ar_1000-typed.

* Mostra na tela o Tipo de documento selecionado
  CLEAR yged_ar_1001_alv-descrip.

  IF p_tipo IS NOT INITIAL.
    SELECT SINGLE descrip
     FROM ygedar_param
     INTO yged_ar_1001_alv-descrip
     WHERE typed = p_tipo.
  ENDIF.
ENDFORM.                    "f_selecionar_tp_docto

*&---------------------------------------------------------------------*
*&      Form  f_carregar_doctos_obrigatorios
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_carregar_doctos_obrigatorios.

* Carrega os documentos que estão com a flag de obrigatório
  FREE tl_alv_obrig.
  SELECT typed descrip extension
   FROM ygedar_param
   INTO TABLE tl_alv_obrig
    WHERE mandatory NE space.

  SORT tl_alv_obrig BY typed ASCENDING.

  PERFORM f_montar_fieldcatalog
   TABLES tl_fcat_stat
    USING wl_fcat_stat c_alv_doc_obrig space.

  PERFORM f_montar_alv_doc_obrigatorios.
ENDFORM.                    "f_carregar_doctos_obrigatorios

*&---------------------------------------------------------------------*
*&      Form  f_carregar_doctos_cliente
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CLIENTE  text
*----------------------------------------------------------------------*
FORM f_carregar_doctos_cliente
  USING p_cliente TYPE yged_ar_1000-cliente.

  DATA: vl_versao TYPE ygedar_doc-version.

  FREE: tl_tipo, tl_alv_docto, tl_documentos.

* Seleciona os tipos de documento que o cliente possui
  SELECT typed
   FROM ygedar_doc
   INTO TABLE tl_tipo
   WHERE kunnr = p_cliente.

  DELETE ADJACENT DUPLICATES FROM tl_tipo.

* Exibe só a última versão de cada documento
  LOOP AT tl_tipo INTO wl_tipo.
    SELECT MAX( version )
     FROM ygedar_doc
     INTO (vl_versao)
     WHERE kunnr = p_cliente
     AND typed = wl_tipo-typed.

    SELECT * FROM ygedar_doc
      APPENDING TABLE tl_documentos
      WHERE kunnr     = p_cliente
        AND typed     = wl_tipo-typed
        AND version   = vl_versao.
  ENDLOOP.

  DELETE tl_documentos WHERE bloqueado = 'X'.

  LOOP AT tl_documentos INTO wl_documentos.
    MOVE-CORRESPONDING wl_documentos TO wl_alv_docto.
    APPEND wl_alv_docto TO tl_alv_docto.
  ENDLOOP.

* Verifica se há dados cadastrados antes de passar para o ALV
  CHECK LINES( tl_alv_docto ) NE 0.

  PERFORM f_verificar_status_docto.

  SORT tl_alv_docto BY typed ASCENDING.

  PERFORM f_montar_fieldcatalog
   TABLES tl_fcat_doc
    USING wl_fcat_doc c_alv_documentos 'X'.

* Se o container já foi inicializado, o ALV já foi exibido e o usuário
* quer verificar os detalhes de outro item. É necessário limpar a tabela
  IF obj_cont_doc IS NOT INITIAL.
    CALL METHOD obj_alv_docto->refresh_table_display.
  ELSE.
    PERFORM f_montar_alv_doctos.
  ENDIF.

ENDFORM.                    "f_carregar_doctos_cliente

*&---------------------------------------------------------------------*
*&      Form  f_verificar_status_docto
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_verificar_status_docto.

* Verifica se o documento está no prazo e altera o ícone de Status
  DATA:
    tl_param TYPE STANDARD TABLE OF ygedar_param,
    wl_param LIKE LINE OF tl_param              .

  DATA:
    vl_qtd_dias TYPE i.

  SELECT * FROM ygedar_param
   INTO TABLE tl_param
   FOR ALL ENTRIES IN tl_alv_docto
   WHERE typed = tl_alv_docto-typed.

  LOOP AT tl_alv_docto INTO wl_alv_docto.
    DATA: vl_indice TYPE sy-tabix.
    vl_indice = sy-tabix.

    CLEAR wl_param.
    READ TABLE tl_param
    INTO wl_param
    WITH KEY typed = wl_alv_docto-typed.

    CHECK sy-subrc EQ 0.

* Diferença entre a data atual com o prazo de validade
* informado pelo usuário (Válido Até)
    CALL FUNCTION 'HR_99S_INTERVAL_BETWEEN_DATES'
      EXPORTING
        begda = sy-datum
        endda = wl_alv_docto-validto
      IMPORTING
        days  = vl_qtd_dias.

    IF vl_qtd_dias >= wl_param-green AND vl_qtd_dias > wl_param-yellow.
      wl_alv_docto-status = c_icone_verde.
    ELSEIF vl_qtd_dias < wl_param-green
       AND vl_qtd_dias >= wl_param-yellow
       OR vl_qtd_dias > wl_param-red.
      wl_alv_docto-status = c_icone_amarelo.
    ELSEIF  vl_qtd_dias <= wl_param-red.
      wl_alv_docto-status = c_icone_vermelho.
    ENDIF.

    wl_alv_docto-bloquear = c_icone_desbloq.

    wl_alv_docto-visualizar = c_icone_visualiz.
    MODIFY tl_alv_docto FROM wl_alv_docto INDEX vl_indice.
  ENDLOOP. " LOOP AT tl_alv_docto INTO wl_alv_docto.

ENDFORM.                    "f_verificar_status_docto

*&---------------------------------------------------------------------*
*&      Form  f_qtd_doctos_obrigatorios
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_qtd_doctos_obrigatorios.
  DATA: vl_qtd_doctos TYPE n.

  yged_ar_1000-qtd_docobrig = 'X de Y documentos obrigatórios'.

  LOOP AT tl_alv_docto INTO wl_alv_docto.
    SELECT COUNT( * )
     FROM ygedar_param
     WHERE mandatory NE space
       AND typed = wl_alv_docto-typed.

    IF sy-subrc EQ 0.
      vl_qtd_doctos = vl_qtd_doctos + 1.
    ENDIF.
  ENDLOOP.

  REPLACE 'X' WITH vl_qtd_doctos INTO yged_ar_1000-qtd_docobrig.

  SELECT COUNT( * )
   FROM ygedar_param
   INTO vl_qtd_doctos
   WHERE mandatory NE space.

  REPLACE 'Y' WITH vl_qtd_doctos INTO yged_ar_1000-qtd_docobrig.
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
  wl_alv_layout-cwidth_opt = 'X'.
  wl_alv_layout-zebra      = 'X'.
  wl_alv_layout-no_toolbar = 'X'. " Exclui os botões da barra de tarefas do ALV

  CALL METHOD obj_alv_docto->set_table_for_first_display
    EXPORTING
      is_layout                     = wl_alv_layout
    CHANGING
      it_outtab                     = tl_alv_docto
      it_fieldcatalog               = tl_fcat_doc
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

  CLEAR: wl_alv_layout.

* Layout do relatório ALV
  wl_alv_layout-cwidth_opt = 'X'. "
  wl_alv_layout-zebra      = 'X'. " Zebrado
  wl_alv_layout-no_toolbar = 'X'. " Exclui os botões da barra de tarefas do ALV

  CALL METHOD obj_alv_stat->set_table_for_first_display
    EXPORTING
      is_layout                     = wl_alv_layout
    CHANGING
      it_outtab                     = tl_alv_obrig
      it_fieldcatalog               = tl_fcat_stat
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
*      -->P_TL_FCAT  text
*      -->P_WL_FCAT  text
*      -->P_TABELA   text
*      -->P_HOTSPOT  text
*----------------------------------------------------------------------*
FORM f_montar_fieldcatalog
  TABLES p_tl_fcat TYPE lvc_t_fcat
   USING p_wl_fcat TYPE lvc_s_fcat
         p_tabela  TYPE ddobjname
         p_hotspot TYPE c.

  DATA: tl_campos TYPE STANDARD TABLE OF dd03p,
        wl_campos LIKE LINE OF tl_campos      .

  DATA: vl_campo       TYPE rollname    ,
        vl_nome_coluna TYPE dd04t-scrtext_s.

* Obtém o nome dos campos da estrutura da SE11
  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name          = p_tabela
      state         = c_versao_ativa
    TABLES
      dd03p_tab     = tl_campos
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  LOOP AT tl_campos INTO wl_campos.
    vl_campo = wl_campos-rollname.

* Seleciona a descrição do elemento de dados
    SELECT SINGLE scrtext_s
    FROM  dd04t
    INTO (vl_nome_coluna)
     WHERE rollname  = vl_campo
      AND ddlanguage = c_pt_br
      AND as4local   = c_versao_ativa.

* Verifica quais se algum dos campos deve ter hotspot
    IF p_hotspot IS NOT INITIAL.
      CASE wl_campos-fieldname.
        WHEN c_hotspot_visual OR c_hotspot_bloq.
          p_wl_fcat-hotspot = 'X'.
          p_wl_fcat-icon    = 'X'.
        WHEN 'STATUS' OR 'BLOQUEAR'.
          p_wl_fcat-icon    = 'X'.
      ENDCASE.
    ENDIF.

    p_wl_fcat-fieldname  = wl_campos-fieldname.
    p_wl_fcat-coltext    = vl_nome_coluna     .
    p_wl_fcat-outputlen  = wl_campos-outputlen.

    APPEND p_wl_fcat TO p_tl_fcat             .
    CLEAR p_wl_fcat.
  ENDLOOP.
ENDFORM.                    "f_montar_fieldcatalog

*&---------------------------------------------------------------------*
*&      Form  F_CARREGAR_ARQUIVO
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
  yged_ar_1000-filename = rlgrap-filename.

ENDFORM.                    " F_CARREGAR_ARQUIVO

*&---------------------------------------------------------------------*
*&      Form  F_SALVAR_ARQUIVO_DMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_salvar_arquivo_dms.
  DATA:
    tl_objectlinks TYPE STANDARD TABLE OF bapi_doc_drad   WITH HEADER LINE,
    tl_doc_file    TYPE STANDARD TABLE OF bapi_doc_files2 WITH HEADER LINE.

  DATA:
    wl_dados  TYPE bapi_doc_draw2,
    wl_return TYPE bapiret2      .

  DATA:
    vl_versao          TYPE ygedar_doc-version            ,
    vl_documentversion TYPE bapi_doc_draw2-documentversion,
    vl_qtd_tp_doc      TYPE n                             .

* Verifica se já há alguma versão cadastrada desse tipo de documento
* para o cliente
  SELECT COUNT( * )
   FROM ygedar_doc
   INTO (vl_qtd_tp_doc)
   WHERE kunnr = yged_ar_1000-cliente
     AND typed = yged_ar_1000-typed.

* Se já houver alguma versão cadastrada acrescenta 1 à versão dele (a versão inicial é zero)
  IF vl_qtd_tp_doc > 0.
    SELECT MAX( version )
      FROM ygedar_doc
       INTO vl_versao
       WHERE kunnr = yged_ar_1000-cliente
         AND typed = yged_ar_1000-typed.

    IF sy-subrc EQ 0.
      vl_versao = vl_versao + 1.
    ENDIF.
  ENDIF.

  WRITE vl_versao TO vl_documentversion.

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
  CHECK vl_resp EQ c_sim OR vl_resp IS INITIAL.

  SHIFT yged_ar_1000-cliente LEFT DELETING LEADING '0'.

  CONCATENATE yged_ar_1000-cliente
              yged_ar_1000-typed
  INTO wl_dados-documentnumber.

  wl_dados-documenttype    = c_contas_receber    . " YAR
  wl_dados-documentversion = vl_documentversion  .
  wl_dados-documentpart    = '00'                .
  wl_dados-description     = yged_ar_1000-descrip.
  wl_dados-username        = sy-uname            .
  wl_dados-statusintern    = c_liberado          . " FR
  wl_dados-statuslog       = c_arquivado         . " Arquivado
  wl_dados-laboratory      = c_cta_receber       . " FAR

* Completa o código do cliente com zeros à esquerda
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = yged_ar_1000-cliente
    IMPORTING
      output = yged_ar_1000-cliente.

  tl_objectlinks-objecttype = c_objeto_sap        .         " KNA1
  tl_objectlinks-objectkey  = yged_ar_1000-cliente.
  APPEND tl_objectlinks.

  tl_doc_file-storagecategory = c_categ_arquiv. " ACHE_AR
  tl_doc_file-docpath         = vl_caminho    .
  tl_doc_file-docfile         = vl_arquivo    .

  CONCATENATE '*.' space vl_extensao INTO vl_extensao.
  TRANSLATE vl_extensao TO LOWER CASE.

* Aplicação estação de trabalho
  SELECT SINGLE dappl
   FROM tdwp
    INTO (tl_doc_file-wsapplication)
    WHERE dateifrmt = vl_extensao.

  APPEND tl_doc_file.

  IF tl_doc_file-wsapplication IS INITIAL.
    MESSAGE 'Aplicação não definida na TDWP'(001) TYPE 'I'.
  ELSE.

* Cria o documento no DMS (transação CV01N)
    CALL FUNCTION 'BAPI_DOCUMENT_CREATE2'
      EXPORTING
        documentdata  = wl_dados
      IMPORTING
        return        = wl_return
      TABLES
        objectlinks   = tl_objectlinks
        documentfiles = tl_doc_file.

    IF wl_return-type = c_erro_bapi.
      MESSAGE wl_return-message TYPE 'I'.
    ELSE.
      ygedar_doc-kunnr     = yged_ar_1000-cliente  .
      ygedar_doc-typed     = yged_ar_1000-typed    .
      ygedar_doc-validfrom = yged_ar_1000-validfrom.
      ygedar_doc-validto   = yged_ar_1000-validto  .
      ygedar_doc-descrip   = yged_ar_1000-descrip  .
      ygedar_doc-version   = vl_versao             .
      MODIFY ygedar_doc FROM ygedar_doc.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      IF wl_return-message IS NOT INITIAL.
        MESSAGE wl_return-message TYPE 'I'.
      ELSE.
        MESSAGE 'Arquivo importado com sucesso'(010) TYPE 'I'.
      ENDIF.

      CLEAR: yged_ar_1000-typed       ,
             yged_ar_1000-validfrom   ,
             yged_ar_1000-validto     ,
             yged_ar_1000-descrip     ,
             yged_ar_1000-filename    ,
             yged_ar_1001_alv-descrip . " Descrição do Tipo do documento

      PERFORM f_selecionar_cliente
       USING yged_ar_1000-cliente.

      PERFORM f_carregar_doctos_cliente
       USING yged_ar_1000-cliente.
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

  IF yged_ar_1000-cliente IS INITIAL.
    MESSAGE 'Informe o cliente'(011) TYPE 'I'.
    vl_erro = 'X'.
  ELSEIF yged_ar_1000-typed IS INITIAL.
    MESSAGE 'Informe o tipo do documento'(015) TYPE 'I'.
    vl_erro = 'X'.
  ELSEIF yged_ar_1000-validfrom IS INITIAL.
    MESSAGE 'Informe a data inicial de validade'(012) TYPE 'I'.
    vl_erro = 'X'.
  ELSEIF yged_ar_1000-validto IS INITIAL.
    MESSAGE 'Informe a data final de validade'(013) TYPE 'I'.
    vl_erro = 'X'.
  ELSEIF yged_ar_1000-descrip IS INITIAL.
    MESSAGE 'Informe a descrição'(014) TYPE 'I'.
    vl_erro = 'X'.
  ELSEIF yged_ar_1000-filename IS INITIAL.
    MESSAGE 'Selecione um arquivo'(009) TYPE 'I'.
    vl_erro = 'X'.
  ENDIF.

  IF vl_erro = 'X'.
    EXIT.
  ENDIF.
ENDFORM.                    "f_validar_campos

*&---------------------------------------------------------------------*
*&      Form  f_verificar_extensao
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_verificar_extensao.
  FREE tl_extensao.
  CLEAR: vl_caminho ,
         vl_arquivo ,
         vl_extensao.

  CHECK rlgrap-filename IS NOT INITIAL.

  vl_arq_comp = rlgrap-filename.

* Verifica as extensões válidas cadastradas no domínio YDEXTENSION
  CALL FUNCTION 'DDIF_DOMA_GET'
    EXPORTING
      name      = 'YDEXTENSION'
      state     = 'A'
      langu     = c_pt_br
    TABLES
      dd07v_tab = tl_extensao.

* Verifica a extensão do arquivo que o usuário selecionou
  CALL FUNCTION 'DSVAS_DOC_FILENAME_SPLIT'
    EXPORTING
      pf_docid     = vl_arq_comp
    IMPORTING
      pf_directory = vl_caminho
      pf_filename  = vl_arquivo
      pf_extension = vl_extensao.

  TRANSLATE vl_extensao TO UPPER CASE.

* Verifica se a extensão do arquivo é permitida
  CLEAR wl_extensao.
  READ TABLE tl_extensao
  INTO wl_extensao
  WITH KEY domvalue_l = vl_extensao.

  IF sy-subrc NE 0.
    MESSAGE 'Extensão não permitida'(002) TYPE 'E'.

    CLEAR: rlgrap-filename      ,
           yged_ar_1000-filename.
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
    tl_param TYPE STANDARD TABLE OF ygedar_param,
    wl_param LIKE LINE OF tl_param              .

  DATA:
    vl_data          TYPE p0001-begda,
    vl_dias          TYPE t5a4a-dlydy,
    vl_meses         TYPE t5a4a-dlymo,
    vl_anos          TYPE t5a4a-dlyyr,
    vl_data_validade TYPE p0001-begda,
    vl_qtd_dias_info TYPE i          ,
    vl_qtd_dias_vali TYPE i          .

  SELECT * FROM ygedar_param
   INTO TABLE tl_param
   WHERE typed = yged_ar_1000-typed.

  CLEAR wl_param.
  READ TABLE tl_param
  INTO wl_param
  WITH KEY typed = yged_ar_1000-typed.

  CHECK sy-subrc EQ 0.

  vl_data  = yged_ar_1000-validfrom.
  vl_dias  = wl_param-exp_day      .
  vl_meses = wl_param-exp_months   .
  vl_anos  = wl_param-exp_year     .

* Verifica o prazo de validade de acordo com os parâmetros
* cadastrados na tabela YGEDAR_PARAM
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = vl_data
      days      = vl_dias
      months    = vl_meses
      signum    = '+'
      years     = vl_anos
    IMPORTING
      calc_date = vl_data_validade.

* Diferença entre a data atual com o prazo de validade
  CALL FUNCTION 'HR_99S_INTERVAL_BETWEEN_DATES'
    EXPORTING
      begda = sy-datum
      endda = vl_data_validade
    IMPORTING
      days  = vl_qtd_dias_vali.

* Diferença entre a data de validade de/até informado
  CALL FUNCTION 'HR_99S_INTERVAL_BETWEEN_DATES'
    EXPORTING
      begda = yged_ar_1000-validfrom
      endda = yged_ar_1000-validto
    IMPORTING
      days  = vl_qtd_dias_info.

  IF vl_qtd_dias_info < vl_qtd_dias_vali.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        text_question         = 'Data de vencimento inferior a data de validade. Deseja inserir?'(016)
        text_button_1         = 'Sim'(005)
        text_button_2         = 'Não'(006)
        display_cancel_button = space
      IMPORTING
        answer                = vl_resp.
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

  READ TABLE tl_alv_docto
  INTO wl_alv_docto
  INDEX p_row-index.

  CASE p_column.
    WHEN c_hotspot_visual. " VISUALIZAR
      PERFORM f_visualizar_arquivo_dms
       USING wl_alv_docto-typed.
    WHEN c_hotspot_bloq. " BLOQUEAR
      PERFORM f_bloquear_documento
        USING p_row
              wl_alv_docto-typed.
  ENDCASE.
ENDFORM.                    "event_hotspot_click

*&---------------------------------------------------------------------*
*&      Form  f_visualizar_arquivo_dms
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TYPED    text
*----------------------------------------------------------------------*
FORM f_visualizar_arquivo_dms
  USING p_typed TYPE ygedar_param-typed.

  DATA:
   vl_nro_doc    TYPE draw-doknr ,
   vl_ver_doc    TYPE n          ,
   vl_versao     TYPE draw-dokvr ,
   vl_arquivo    TYPE draw-filep ,
   vl_url_dms    TYPE mcdok-url  ,
   vl_visualizar TYPE c LENGTH 01.

* Completa o código do cliente com zeros à esquerda
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = yged_ar_1000-cliente
    IMPORTING
      output = yged_ar_1000-cliente.

* Última versão do documento selecionado
  SELECT MAX( version )
   FROM ygedar_doc
   INTO vl_ver_doc
   WHERE kunnr = yged_ar_1000-cliente
   AND typed = p_typed.

  WRITE vl_ver_doc TO vl_versao.

* Completa o código da versão com zeros à esquerda
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = vl_versao
    IMPORTING
      output = vl_versao.

  SHIFT yged_ar_1000-cliente LEFT DELETING LEADING '0'.

  CONCATENATE yged_ar_1000-cliente
              p_typed
  INTO vl_nro_doc.

  CALL FUNCTION 'CVAPI_DOC_VIEW'
    EXPORTING
      pf_dokar         = c_contas_receber " YAR
      pf_doknr         = vl_nro_doc
      pf_dokvr         = vl_versao
      pf_doktl         = c_doc_parcial                      " 0000
    IMPORTING
      pfx_file         = vl_arquivo
      pfx_url          = vl_url_dms
      pfx_view_inplace = vl_visualizar
    EXCEPTIONS
      error            = 1
      not_found        = 2
      no_auth          = 3
      no_original      = 4
      OTHERS           = 5.

  IF vl_arquivo IS INITIAL.
    MESSAGE 'Documento não cadastrado'(004) TYPE 'I'.
  ENDIF.

ENDFORM.                    "f_visualizar_arquivo_dms

*&---------------------------------------------------------------------*
*&      Form  f_bloquear_documento
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ROW    text
*----------------------------------------------------------------------*
FORM f_bloquear_documento
  USING p_row   TYPE lvc_s_row
        p_typed TYPE ygedar_param-typed.

  DATA: tl_campo TYPE STANDARD TABLE OF sval,
        wl_campo LIKE LINE OF tl_campo      .

  DATA: vl_versao TYPE ygedar_doc-version.

  wl_campo-tabname   = 'YGEDAR_DOC'.
  wl_campo-fieldname = 'MOTIVO_BLOQ'.
  APPEND wl_campo TO tl_campo.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title     = 'Bloquear documento'(007)
      start_column    = 40
      start_row       = 15
    TABLES
      fields          = tl_campo
    EXCEPTIONS
      error_in_fields = 1
      OTHERS          = 2.

  READ TABLE tl_campo
  INTO wl_campo
  INDEX 1.

* Se algum valor foi informado no popup, altera a tabela
  CHECK wl_campo-value IS NOT INITIAL.

  wl_alv_docto-bloquear   = c_icone_bloquear.
  MODIFY tl_alv_docto FROM wl_alv_docto INDEX p_row.

  FREE: tl_tipo.

* Seleciona os tipos de documento que o cliente possui
  SELECT typed
   FROM ygedar_doc
   INTO TABLE tl_tipo
   WHERE kunnr = yged_ar_1000-cliente
     AND typed = p_typed .

* O documento exibido no ALV é sempre a maior versão, por isso
* é necessário verificar novamente para alterar o registro certo
  SELECT MAX( version )
   FROM ygedar_doc
   INTO (vl_versao)
   WHERE kunnr = yged_ar_1000-cliente
     AND typed = p_typed .

  SELECT SINGLE * FROM ygedar_doc
   INTO wl_documentos
    WHERE kunnr   = yged_ar_1000-cliente
      AND typed   = p_typed
      AND version = vl_versao.

  wl_documentos-bloqueado   = 'X'           .
  wl_documentos-motivo_bloq = wl_campo-value.

  MODIFY ygedar_doc FROM wl_documentos.

  PERFORM f_carregar_doctos_cliente
   USING yged_ar_1000-cliente.
ENDFORM.                    "f_bloquear_documento