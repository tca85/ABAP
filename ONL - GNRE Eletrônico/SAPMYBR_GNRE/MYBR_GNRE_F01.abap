*&---------------------------------------------------------------------*
*&  Include           MYBR_GNRE_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  f_verificar_nfe
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_nfe    text
*      -->p_emp    text
*      -->p_filial text
*----------------------------------------------------------------------*
FORM f_verificar_nfe
 USING p_nfe    TYPE ybr_gnre_1000-nfe
       p_emp    TYPE ybr_gnre_1000-empresa
       p_filial TYPE ybr_gnre_1000-filial.

  CLEAR vl_qtd_reg.

  CHECK ok_code = 'BTN_ADICIONAR'.

  IF p_nfe IS NOT INITIAL.
    SELECT COUNT( * )
     INTO vl_qtd_reg
     FROM j_1bnfdoc
     WHERE nfenum = p_nfe
       AND bukrs  = p_emp
       AND branch = p_filial.

    IF vl_qtd_reg = 0.
      MESSAGE 'NF-e não encontrada'(001) TYPE 'E'.
    ENDIF.

  ELSE.
    MESSAGE 'NF-e não foi informada'(002) TYPE 'E'.
  ENDIF.
ENDFORM.                    "f_verificar_nfe

*&---------------------------------------------------------------------*
*&      Form  f_verificar_serie
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_nfe    text
*      -->p_serie  text
*      -->p_emp    text
*      -->p_filial text
*----------------------------------------------------------------------*
FORM f_verificar_serie
 USING p_nfe    TYPE ybr_gnre_1000-nfe
       p_serie  TYPE ybr_gnre_1000-serie
       p_emp    TYPE ybr_gnre_1000-empresa
       p_filial TYPE ybr_gnre_1000-filial.

  CLEAR vl_qtd_reg.

  CHECK ok_code = 'BTN_ADICIONAR'.

  IF p_serie IS NOT INITIAL.
    SELECT COUNT( * )
     INTO vl_qtd_reg
     FROM j_1bnfdoc
     WHERE nfenum = p_nfe
       AND series = p_serie
       AND bukrs  = p_emp
       AND branch = p_filial.

    IF vl_qtd_reg = 0.
      MESSAGE 'A serie não corresponde à NF-e'(003) TYPE 'E'.
    ENDIF.

  ELSE.
    MESSAGE 'Serie não foi informada'(004) TYPE 'E'.
  ENDIF.

ENDFORM.                    "f_verificar_serie

*&---------------------------------------------------------------------*
*&      Form  f_verificar_data_venc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DATA     text
*----------------------------------------------------------------------*
FORM f_verificar_data_venc
 USING p_data TYPE ybr_gnre_1000-dt_vencimento.

  DATA: vl_dt_vencimento TYPE sy-datum.

  CHECK ok_code = 'BTN_ADICIONAR'
     OR ok_code = 'BTN_BUSCAR_NOTAS'.

  IF p_data IS INITIAL
    AND ( ok_code = 'BTN_ADICIONAR' OR ok_code = 'BTN_BUSCAR_NOTAS' ).
    MESSAGE 'Data de vencimento não foi informada'(005) TYPE 'E'.
  ELSE.
    CONCATENATE ybr_gnre_1000-dt_vencimento(4)
                ybr_gnre_1000-dt_vencimento+4(2)
                ybr_gnre_1000-dt_vencimento+6(2)
           INTO vl_dt_vencimento.

    IF vl_dt_vencimento < sy-datum.
      MESSAGE 'Data de vencimento é inferior à data atual'(016) TYPE 'E'.
    ENDIF.
  ENDIF.

ENDFORM.                    "f_verificar_data_venc

*&---------------------------------------------------------------------*
*&      Form  f_adicionar_nota
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_adicionar_nota.
  PERFORM f_verificar_existe_alv.

  IF vl_erro IS INITIAL.
    PERFORM f_procurar_nf_sap.

    IF tl_alv_gnre IS NOT INITIAL.
      PERFORM f_informar_qtd_notas.

      PERFORM f_montar_fieldcatalog
       TABLES tl_fcat_gnre
        USING wl_fcat_gnre
              c_alv_gnre. " YBR_GNRE_1000

      PERFORM: f_montar_alv_gnre,
               f_limpar_campos  .

      vl_bloq_campo = 'X'.

    ENDIF.
  ENDIF.
ENDFORM.                    " f_adicionar_nota

*&---------------------------------------------------------------------*
*&      Form  f_verificar_existe_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_verificar_existe_alv.
  CLEAR vl_erro.

  READ TABLE tl_alv_gnre
  INTO wl_alv_gnre
  WITH KEY empresa = ybr_gnre_1000-empresa
           filial  = ybr_gnre_1000-filial
           nfe     = ybr_gnre_1000-nfe
           serie   = ybr_gnre_1000-serie.

  IF sy-subrc = 0.
    vl_erro = 'X'.

    MESSAGE 'A nota informada já foi adicionada, verifique'(015) TYPE 'W'.
    PERFORM f_limpar_campos.
  ENDIF.
ENDFORM.                    "f_verificar_existe_alv

*&---------------------------------------------------------------------*
*&      Form  f_bloquear_campos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_bloquear_campos.
  CHECK vl_bloq_campo IS NOT INITIAL.

* Bloqueia a empresa e a filial após inserir o primeiro registro no ALV
  LOOP AT SCREEN.
    IF screen-group1 = 'GR1'.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "f_bloquear_campos

*&---------------------------------------------------------------------*
*&      Form  f_limpar_campos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_limpar_campos.
  IF ybr_gnre_1000-nfe(3) = '000'.
    ybr_gnre_1000-nfe = '000'.
  ELSE.
    CLEAR ybr_gnre_1000-nfe.
  ENDIF.
ENDFORM.                    "f_limpar_campos

*&---------------------------------------------------------------------*
*&      Form  f_excluir_fora_criterios
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_excluir_fora_criterios.
  DELETE tl_alv_gnre
  WHERE empresa = ybr_gnre_1000-empresa
    AND filial  = ybr_gnre_1000-filial
    AND nfe     = ybr_gnre_1000-nfe
    AND serie   = ybr_gnre_1000-serie.
ENDFORM.                    "f_excluir_fora_criterios

*&---------------------------------------------------------------------*
*&      Form  f_procurar_nf_sap
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_procurar_nf_sap.
* Cabeçalho da nota fiscal
  SELECT bukrs branch nfenum series docnum docdat parid
   FROM j_1bnfdoc
   APPENDING TABLE tl_j_1bnfdoc
   WHERE bukrs  = ybr_gnre_1000-empresa
     AND branch = ybr_gnre_1000-filial
     AND nfenum = ybr_gnre_1000-nfe
     AND series = ybr_gnre_1000-serie.

  IF sy-subrc <> 0.
    MESSAGE 'Dados não encontrados para a NF-e informada'(006) TYPE 'I'.
    PERFORM f_limpar_campos.
  ELSE.

    CLEAR wl_j_1bnfdoc.
    READ TABLE tl_j_1bnfdoc
    INTO wl_j_1bnfdoc
    WITH KEY bukrs  = ybr_gnre_1000-empresa
             branch = ybr_gnre_1000-filial
             nfenum = ybr_gnre_1000-nfe
             series = ybr_gnre_1000-serie.

*   Verifica se já foi gerado um XML para essa nota
    SELECT COUNT( * )
     INTO vl_qtd_reg
     FROM ybr_gnre
      WHERE bukrs  = wl_j_1bnfdoc-bukrs
        AND branch = wl_j_1bnfdoc-branch
        AND docnum = wl_j_1bnfdoc-docnum.

    IF vl_qtd_reg IS NOT INITIAL.
      PERFORM f_permitir_re_inserir.
    ENDIF.

    IF vl_qtd_reg IS INITIAL.
*     Nota fiscal: imposto por item
      SELECT docnum taxtyp SUM( taxval )
       FROM j_1bnfstx
       APPENDING TABLE tl_j_1bnfstx
       WHERE docnum = wl_j_1bnfdoc-docnum
         AND taxtyp = c_icms_st                             " ICS3
       GROUP BY docnum taxtyp.

      IF sy-subrc <> 0.
        MESSAGE 'Nota não possui ICMS de substituição tributária'(007) TYPE 'I'.
        PERFORM f_limpar_campos.
      ELSE.

*       Status das notas fiscais
        SELECT docnum regio nfyear nfmonth stcd1 model serie nfnum9 docnum9 cdv
         FROM j_1bnfe_active
         APPENDING TABLE tl_j_1bnfe_active
         WHERE docnum = wl_j_1bnfdoc-docnum.

*       Após todas verificações, copia os dados da tela de seleção para o ALV
        READ TABLE tl_j_1bnfstx
        INTO wl_j_1bnfstx
        WITH KEY docnum = wl_j_1bnfdoc-docnum.

        ybr_gnre_1000-deletar = c_icone_deletar    .
        ybr_gnre_1000-taxval  = wl_j_1bnfstx-taxval.
        APPEND ybr_gnre_1000 TO tl_alv_gnre        .
      ENDIF.                                                " j_1bnfstx
    ENDIF. " ybr_gnre
  ENDIF. " IF vl_qtd_reg IS NOT INITIAL.
ENDFORM.                    "f_procurar_nf_sap

* ACTHIAGO - #61276 - 28.08.2013 - INICIO
*&---------------------------------------------------------------------*
*&      Form  f_permitir_re_inserir
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_permitir_re_inserir.
  DATA: vl_resp TYPE c.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'GNRE Eletrônico'(008)
      text_question         = 'Nota Fiscal já registrada, deseja continuar?'(017)
      text_button_1         = 'Sim'(010)
      text_button_2         = 'Não'(011)
      display_cancel_button = ' '
    IMPORTING
      answer                = vl_resp.

  IF vl_resp = 1. " sim
    CLEAR vl_qtd_reg.
  ELSE.
    PERFORM f_limpar_campos.
  ENDIF.

ENDFORM.                    "f_permitir_re_inserir
* ACTHIAGO - #61276 - 28.08.2013 - FIM

*&---------------------------------------------------------------------*
*&      Form  f_informar_qtd_notas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_informar_qtd_notas.
  DATA: vl_qtd       TYPE i          ,
        vl_qtd_notas TYPE c LENGTH 05,
        vl_qtd_lim   TYPE c LENGTH 05,
        vl_val_max   TYPE string     .

  CHECK tl_alv_gnre IS NOT INITIAL.

  qtd_doc_obrig = 'X de Y notas'.
  vl_val_max    = 'O arquivo XML deve conter no máximo & notas'.

  DESCRIBE TABLE tl_alv_gnre LINES vl_qtd.

  WRITE: vl_qtd          TO vl_qtd_notas,
         c_qtd_limite_nf TO vl_qtd_lim  .

  REPLACE: 'X' WITH vl_qtd_notas INTO qtd_doc_obrig,
           'Y' WITH vl_qtd_lim   INTO qtd_doc_obrig,
           '&' WITH vl_qtd_lim   INTO vl_val_max   .

* Verifica se já preencheu o limite de notas
  IF vl_qtd = c_qtd_limite_nf.
    MESSAGE vl_val_max TYPE 'W'.
  ENDIF.
ENDFORM.                    "f_informar_qtd_notas

*&---------------------------------------------------------------------*
*&      Form  f_montar_fieldcatalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TL_FCAT  text
*      -->P_WL_FCAT  text
*      -->P_STRUCTURE text
*----------------------------------------------------------------------*
FORM f_montar_fieldcatalog
  TABLES p_tl_fcat   TYPE lvc_t_fcat
   USING p_wl_fcat   TYPE lvc_s_fcat
         p_structure TYPE ddobjname.

  DATA: tl_campos TYPE STANDARD TABLE OF dd03p,
        wl_campos LIKE LINE OF tl_campos      .

* Obtém o nome dos campos da estrutura da SE11
  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name          = p_structure
      state         = c_versao_ativa
    TABLES
      dd03p_tab     = tl_campos
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  LOOP AT tl_campos INTO wl_campos.
    MOVE-CORRESPONDING wl_campos TO p_wl_fcat.
    p_wl_fcat-outputlen = 10.

    IF wl_campos-fieldname = c_btn_deletar.
      p_wl_fcat-hotspot   = 'X'.
      p_wl_fcat-icon      = 'X'.
      p_wl_fcat-outputlen =  5 .
    ELSEIF wl_campos-fieldname = c_hotspot_nfe.
      p_wl_fcat-hotspot   = 'X'.
    ENDIF.

    APPEND p_wl_fcat TO p_tl_fcat.
    CLEAR p_wl_fcat.
  ENDLOOP.
ENDFORM.                    "f_montar_fieldcatalog

*&---------------------------------------------------------------------*
*&      Form  f_montar_alv_gnre
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_montar_alv_gnre.
* Se o container já foi inicializado, o ALV já foi exibido e o usuário
* quer verificar os detalhes de outro item. É necessário limpar a tabela
  IF obj_cont_gnre IS NOT INITIAL.
    CALL METHOD obj_alv_gnre->refresh_table_display.
  ENDIF.

* Verifica se o container ainda não foi inicializado
  CHECK obj_cont_gnre IS INITIAL.

  CREATE OBJECT obj_cont_gnre
    EXPORTING
      container_name              = c_cont_alv_gnre " CONT_ALV_GNRE
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

* Cria uma instância da classe cl_gui_alv_grid no container CONT_ALV_GNRE
* declarado no layout da tela 1000
  CREATE OBJECT obj_alv_gnre
    EXPORTING
      i_parent          = obj_cont_gnre
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.

  CLEAR: wl_alv_layout.

* Atribui os métodos da classe local lcl_evento_alv à do ALV
  DATA: o_evt TYPE REF TO lcl_evento_alv.
  CREATE OBJECT o_evt.
  SET HANDLER o_evt->hotspot_click FOR obj_alv_gnre.

* Layout do relatório ALV
  wl_alv_layout-zebra      = 'X'. " Zebrado
  wl_alv_layout-no_toolbar = 'X'. " Exclui os botões da barra de tarefas do ALV

  CALL METHOD obj_alv_gnre->set_table_for_first_display
    EXPORTING
      is_layout                     = wl_alv_layout
    CHANGING
      it_outtab                     = tl_alv_gnre
      it_fieldcatalog               = tl_fcat_gnre
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
ENDFORM.                    "f_montar_alv_gnre

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

  READ TABLE tl_alv_gnre
  INTO wl_alv_gnre
  INDEX p_row-index.

  CASE p_column.
    WHEN c_btn_deletar.
      PERFORM f_deletar_nota
        USING p_row
              wl_alv_gnre-nfe.
    WHEN c_hotspot_nfe.
      PERFORM f_carregar_j1b3n
        USING p_row
              wl_alv_gnre-empresa
              wl_alv_gnre-filial
              wl_alv_gnre-nfe
              wl_alv_gnre-serie.
  ENDCASE.
ENDFORM.                    "event_hotspot_click

*&---------------------------------------------------------------------*
*&      Form  f_deletar_nota
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_ROW  text
*      -->P_WL_ALV_GNRE_NFE  text
*----------------------------------------------------------------------*
FORM f_deletar_nota
 USING p_row   TYPE lvc_s_row
       p_nfe   TYPE ybr_gnre_1000-nfe.

  DATA: vl_resp TYPE c.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'GNRE Eletrônico'(008)
      text_question         = 'Deseja excluir o registro selecionado?'(009)
      text_button_1         = 'Sim'(010)
      text_button_2         = 'Não'(011)
      display_cancel_button = ' '
    IMPORTING
      answer                = vl_resp.

  IF vl_resp = 1. " sim
    DELETE tl_alv_gnre INDEX p_row.

    PERFORM f_informar_qtd_notas.

    IF obj_cont_gnre IS NOT INITIAL.
      CALL METHOD obj_alv_gnre->refresh_table_display.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_deletar_nota

*&---------------------------------------------------------------------*
*&      Form  f_carregar_j1b3n
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ROW      text
*      -->P_EMPRESA  text
*      -->P_FILIAL   text
*      -->P_NFE      text
*      -->P_SERIE    text
*----------------------------------------------------------------------*
FORM f_carregar_j1b3n
 USING p_row     TYPE lvc_s_row
       p_empresa TYPE ybr_gnre_1000-empresa
       p_filial  TYPE ybr_gnre_1000-filial
       p_nfe     TYPE ybr_gnre_1000-nfe
       p_serie   TYPE ybr_gnre_1000-serie.

  CLEAR wl_j_1bnfdoc.
  READ TABLE tl_j_1bnfdoc
  INTO wl_j_1bnfdoc
  WITH KEY bukrs  = p_empresa
           branch = p_filial
           nfenum = p_nfe
           series = p_serie.

  IF sy-subrc = 0.
    SET PARAMETER ID 'JEF' FIELD wl_j_1bnfdoc-docnum.
    CALL TRANSACTION 'J1B3N' AND SKIP FIRST SCREEN.
  ENDIF.
ENDFORM.                    "f_carregar_j1b3n

* Thiago Alves - #63428 - 25.09.2013 - INICIO
*&---------------------------------------------------------------------*
*&      Form  f_quebrar_arquivo_xml
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_quebrar_arquivo_xml.
  DATA: tl_alv_gnre_aux TYPE STANDARD TABLE OF ybr_gnre_1000.

  DATA: vl_qtd_registros TYPE sy-tfill  ,
        vl_contador      TYPE n LENGTH 6,
        vl_gerar_xml     TYPE c         .

  DESCRIBE TABLE tl_alv_gnre LINES vl_qtd_registros.

  IF vl_qtd_registros = 0.
    MESSAGE 'Não há dados para gerar XML'(014) TYPE 'W'.

  ELSEIF  vl_qtd_registros <= c_qtd_limite_nf. "50
    vl_id_arquivo = 1.

    PERFORM f_gerar_xml.

  ELSEIF vl_qtd_registros > c_qtd_limite_nf.
* Se tiver mais de 50 notas, quebra em mais de um arquivo

*  Copia as notas para uma tabela auxiliar
    tl_alv_gnre_aux[] = tl_alv_gnre[].

*   Limpa a tabela original porque ela é usada na rotina f_gerar_xml
    FREE tl_alv_gnre.

*   Gera um arquivo XML a cada 50 notas
    LOOP AT tl_alv_gnre_aux INTO wl_alv_gnre.
      vl_contador = vl_contador + 1.

      APPEND wl_alv_gnre TO tl_alv_gnre.

      IF vl_contador = c_qtd_limite_nf. "50
        vl_id_arquivo = vl_id_arquivo + 1.

        PERFORM f_gerar_xml.

        FREE tl_alv_gnre.
        vl_gerar_xml = 'X'.

        CLEAR vl_contador.
      ENDIF.

      CLEAR vl_gerar_xml.
    ENDLOOP.

    IF vl_gerar_xml IS INITIAL
      AND tl_alv_gnre IS NOT INITIAL.

      vl_id_arquivo = vl_id_arquivo + 1.
      PERFORM f_gerar_xml.

    ENDIF.
  ENDIF.

ENDFORM.                    "f_quebrar_arquivo_xml
* Thiago Alves - #63428 - 25.09.2013 - FIM

*&---------------------------------------------------------------------*
*&      Form  f_gerar_xml
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_gerar_xml.
  DATA: g_ixml        TYPE REF TO if_ixml                   ,
        g_encoding    TYPE REF TO if_ixml_encoding          ,
        g_document    TYPE REF TO if_ixml_document          ,
        root          TYPE REF TO if_ixml_element           ,
        guias         TYPE REF TO if_ixml_element           ,
        generico      TYPE REF TO if_ixml_element           ,
        extras        TYPE REF TO if_ixml_element           ,
        camp_extr     TYPE REF TO if_ixml_element           ,
        referencia    TYPE REF TO if_ixml_element           ,
        dados_gerais  TYPE REF TO if_ixml_element           ,
        ixml          TYPE REF TO if_ixml                   ,
        streamfactory TYPE REF TO if_ixml_stream_factory    ,
        outputstream  TYPE REF TO if_ixml_ostream           ,
        renderer      TYPE REF TO if_ixml_renderer          .

  DATA: vl_parid      TYPE j_1bnfnad-parid                  ,
        vl_nome       TYPE j1b_nf_xml_badi_header-xlocembarq,
        vl_rua        TYPE j1b_nf_xml_header-e1_xlgr        ,
        vl_num1       TYPE j1b_nf_xml_header-e1_nro         ,
        vl_num2       TYPE j1b_nf_xml_header-e1_xcpl        ,
        vl_isuf       TYPE j1b_nf_xml_header-e1_isuf        ,
        vl_cnpj       TYPE j1b_nf_xml_header-g_cnpj         ,
        vl_bairro     TYPE j1b_nf_xml_header-f_xbairro      ,
        vl_cmun       TYPE j1b_nf_xml_header-f_cmun         ,
        vl_cidade     TYPE j1b_nf_xml_header-f_xmun         ,
        vl_regiao     TYPE j1b_nf_xml_header-f_uf           ,
        vl_regiao_emb TYPE j1b_nf_xml_header-ufembarq       ,
        vl_cep        TYPE j1b_nf_xml_header-e1_cep         ,
        vl_iest       TYPE j1b_nf_xml_header-e1_ie          ,
        vl_cpf        TYPE j1b_nf_xml_header-e_cpf          ,
        vl_pais       TYPE j1b_nf_xml_header-e1_xpais       ,
        vl_cpl        TYPE j1b_nf_xml_header-e1_xcpl        ,
        tempstring    TYPE string                           ,
        xmlstring     TYPE string                           ,
        vl_data       TYPE c LENGTH 10                      ,
        vl_length     TYPE i                                ,
        rc            TYPE sysubrc                          ,
        vl_nome_arq   TYPE string                           .

  DATA result_tab TYPE TABLE OF string.

  FREE tl_gnre.

* Instancia um objeto do Tipo IF_IXML
  g_ixml = cl_ixml=>create( ).

* Informa o tipo do ENCONDING para o objto G_XML
  g_encoding = g_ixml->create_encoding(
               byte_order    = 0
               character_set = 'UTF-8' ).

* Cria um  documeto XML
  g_document = g_ixml->create_document( ).

* Tag ROOT
  root = g_document->create_simple_element(
         name   = 'TLote_GNRE'
         parent = g_document ).

  root->set_attribute(
        name  = 'xmlns'
        value = 'http://www.gnre.pe.gov.br' ).

  guias = g_document->create_simple_element(
          name   = 'guias'
          parent = root    ).

  LOOP AT tl_alv_gnre INTO wl_alv_gnre.
    CONCATENATE sy-datum+2(4)
                sy-uzeit
           INTO vl_id_gnre.

    READ TABLE tl_j_1bnfdoc
    INTO wl_j_1bnfdoc
    WITH KEY bukrs  = wl_alv_gnre-empresa
             branch = wl_alv_gnre-filial
             nfenum = wl_alv_gnre-nfe
             series = wl_alv_gnre-serie.

*   Preenche a tabela interna TL_GNRE para depois salvar na YBR_GNRE
    wl_gnre-mandt   = sy-mandt           .
    wl_gnre-id_gnre = vl_id_gnre         .
    wl_gnre-bukrs   = wl_alv_gnre-empresa.
    wl_gnre-branch  = wl_alv_gnre-filial .
    wl_gnre-docnum  = wl_j_1bnfdoc-docnum.
    wl_gnre-uname   = sy-uname           .
    APPEND wl_gnre TO tl_gnre.

    CONCATENATE wl_alv_gnre-empresa
                wl_alv_gnre-filial
           INTO vl_parid.

*   Destinatário
    CALL FUNCTION 'YBR_GNRE_PARCEIROS_NFE'
      EXPORTING
        partyp     = c_local_negocios " B
      IMPORTING
        nome       = vl_nome
        rua        = vl_rua
        num1       = vl_num1
        num2       = vl_num2
        isuf       = vl_isuf
        cnpj       = vl_cnpj
        bairro     = vl_bairro
        cmun       = vl_cmun
        cidade     = vl_cidade
        regiao     = vl_regiao
        regiao_emb = vl_regiao_emb
        cep        = vl_cep
        iest       = vl_iest
        cpf        = vl_cpf
        pais       = vl_pais
        cpl        = vl_cpl
      CHANGING
        parid      = vl_parid.

    dados_gerais = g_document->create_simple_element(
                   name   = 'TDadosGNRE'
                   value  = ''
                   parent = guias ).

    generico = g_document->create_simple_element(
                name   = 'c01_UfFavorecida'
                value  = 'MT'
                parent = dados_gerais ).

    generico = g_document->create_simple_element(
                name   = 'c02_receita'
                value  = '100099'
                parent = dados_gerais ).

    generico = g_document->create_simple_element(
                name   = 'c25_detalhamentoReceita'
                value  = '000022'
                parent = dados_gerais ).

    generico = g_document->create_simple_element(
               name   = 'c27_tipoIdentificacaoEmitente'
               value  = '1'
               parent = dados_gerais ).

    generico = g_document->create_simple_element(
               name   = 'c03_idContribuinteEmitente'
               parent = dados_gerais ).

    tempstring = vl_cnpj.

    generico = g_document->create_simple_element(
               name   = 'CNPJ'
               value  = tempstring
               parent = generico ).

    generico = g_document->create_simple_element(
               name   = 'c28_tipoDocOrigem'
               value  = '10'
               parent = dados_gerais ).

    CONCATENATE wl_alv_gnre-nfe
                wl_alv_gnre-serie
           INTO tempstring.

    generico = g_document->create_simple_element(
               name   = 'c04_docOrigem'
               value  = tempstring
               parent = dados_gerais ).

    tempstring = wl_alv_gnre-taxval.
    CONDENSE tempstring NO-GAPS.

    generico = g_document->create_simple_element(
               name   = 'c06_valorPrincipal'
               value  = tempstring
               parent = dados_gerais ).

    CONCATENATE wl_alv_gnre-dt_vencimento(4)
                wl_alv_gnre-dt_vencimento+4(2)
                wl_alv_gnre-dt_vencimento+6(2)
           INTO vl_data SEPARATED BY '-'.

    tempstring = vl_data.

    generico = g_document->create_simple_element(
               name   = 'c14_dataVencimento'
               value  = tempstring
               parent = dados_gerais ).

    tempstring = vl_nome.

    generico = g_document->create_simple_element(
               name   = 'c16_razaoSocialEmitente'
               value  = tempstring
               parent = dados_gerais ).

    CONCATENATE vl_rua
                vl_num1
                vl_bairro
                vl_cidade
                vl_regiao
           INTO tempstring
           SEPARATED BY ','.

    generico = g_document->create_simple_element(
               name   = 'c18_enderecoEmitente'
               value  = tempstring
               parent = dados_gerais ).

    vl_length = STRLEN( vl_cmun ) - 2.
    tempstring = vl_cmun+2(vl_length).

    generico = g_document->create_simple_element(
               name   = 'c19_municipioEmitente'
               value  = tempstring
               parent = dados_gerais ).

    tempstring = vl_regiao.

    generico = g_document->create_simple_element(
               name   = 'c20_ufEnderecoEmitente'
               value  = tempstring
               parent = dados_gerais ).

    tempstring = vl_cep.

    TRANSLATE tempstring USING '- '.
    CONDENSE tempstring NO-GAPS.

    generico = g_document->create_simple_element(
               name   = 'c21_cepEmitente'
               value  = tempstring
               parent = dados_gerais ).

    generico = g_document->create_simple_element(
               name   = 'c34_tipoIdentificacaoDestinatario'
               value  = '1'
               parent = dados_gerais ).

    generico = g_document->create_simple_element(
               name   = 'c35_idContribuinteDestinatario'
               parent = dados_gerais ).

*   Cliente
    CALL FUNCTION 'YBR_GNRE_PARCEIROS_NFE'
      EXPORTING
        partyp     = c_cliente " C
      IMPORTING
        nome       = vl_nome
        rua        = vl_rua
        num1       = vl_num1
        num2       = vl_num2
        isuf       = vl_isuf
        cnpj       = vl_cnpj
        bairro     = vl_bairro
        cmun       = vl_cmun
        cidade     = vl_cidade
        regiao     = vl_regiao
        regiao_emb = vl_regiao_emb
        cep        = vl_cep
        iest       = vl_iest
        cpf        = vl_cpf
        pais       = vl_pais
        cpl        = vl_cpl
      CHANGING
        parid      = wl_j_1bnfdoc-parid.

    tempstring = vl_cnpj.

    generico = g_document->create_simple_element(
               name   = 'CNPJ'
               value  = tempstring
               parent = generico ).

    tempstring = vl_iest.

    generico = g_document->create_simple_element(
               name   = 'c36_inscricaoEstadualDestinatario'
               value  = tempstring
               parent = dados_gerais ).

    tempstring = vl_nome.

    generico = g_document->create_simple_element(
               name   = 'c37_razaoSocialDestinatario'
               value  = tempstring
               parent = dados_gerais ).

    vl_length = STRLEN( vl_cmun ) - 2.
    tempstring = vl_cmun+2(vl_length).

    generico = g_document->create_simple_element(
               name   = 'c38_municipioDestinatario'
               value  = tempstring
               parent = dados_gerais ).

    tempstring = vl_data.

    generico = g_document->create_simple_element(
           name   = 'c33_dataPagamento'
           value  = tempstring
           parent = dados_gerais ).

    referencia = g_document->create_simple_element(
                 name   = 'c05_referencia'
                 parent = dados_gerais ).

    tempstring = wl_j_1bnfdoc-docdat+4(2).

    generico = g_document->create_simple_element(
               name   = 'mes'
               value  = tempstring
               parent = referencia ).

    tempstring = wl_j_1bnfdoc-docdat(4).

    generico = g_document->create_simple_element(
               name   = 'ano'
               value  = tempstring
               parent = referencia ).

    extras = g_document->create_simple_element(
             name   = 'c39_camposExtras'
             parent = dados_gerais ).

    camp_extr  = g_document->create_simple_element(
        name   = 'campoExtra'
        parent = extras ).

    generico = g_document->create_simple_element(
               name   = 'codigo'
               value  = '17'
               parent = camp_extr ).

    generico = g_document->create_simple_element(
               name   = 'tipo'
               value  = 'T'
               parent = camp_extr ).

    READ TABLE tl_j_1bnfe_active
    INTO wl_j_1bnfe_active
    WITH KEY docnum = wl_j_1bnfdoc-docnum.

    CONCATENATE wl_j_1bnfe_active-regio
                wl_j_1bnfe_active-nfyear
                wl_j_1bnfe_active-nfmonth
                wl_j_1bnfe_active-stcd1
                wl_j_1bnfe_active-model
                wl_j_1bnfe_active-serie
                wl_j_1bnfe_active-nfnum9
                wl_j_1bnfe_active-docnum9
                wl_j_1bnfe_active-cdv
           INTO tempstring.

    generico = g_document->create_simple_element(
               name   = 'valor'
               value  = tempstring
               parent = camp_extr ).

    generico = g_document->create_simple_element(
               name   = 'c42_identificadorGuia'
               value  = vl_id_gnre
               parent = dados_gerais ).

    CLEAR: generico    ,
           camp_extr   ,
           extras      ,
           dados_gerais.
  ENDLOOP. " LOOP AT tl_alv_gnre INTO wl_alv_gnre.

  ixml          = cl_ixml=>create( ).

  streamfactory = ixml->create_stream_factory( ).

  outputstream  = streamfactory->create_ostream_cstring( tempstring ).

  renderer      = ixml->create_renderer(  document = g_document
                                          ostream  = outputstream ).
  renderer->set_normalizing( ).
  rc = renderer->render( ).

  WHILE tempstring(1) <> '<'.
    SHIFT tempstring LEFT BY 1 PLACES.
  ENDWHILE.

  xmlstring = tempstring.

  REPLACE 'iso-8859-1' WITH 'UTF-8' INTO xmlstring.

  APPEND xmlstring TO result_tab.

  DATA: vl_numero_arquivo TYPE string.
  vl_numero_arquivo = vl_id_arquivo.
  SHIFT vl_numero_arquivo RIGHT DELETING TRAILING space.

  CONCATENATE 'C:\TEMP\GNRE'
               vl_dt_ult_exec
               '-'
               vl_numero_arquivo
               '.xml'
          INTO vl_nome_arq.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename = vl_nome_arq
      filetype = 'DAT'
    CHANGING
      data_tab = result_tab
    EXCEPTIONS
      OTHERS   = 24.

  IF sy-subrc = 0.
    MODIFY ybr_gnre FROM TABLE tl_gnre.

    MESSAGE 'Arquivo XML gerado com sucesso na pasta C:\Temp' TYPE 'S'.

    FREE: tl_gnre, tl_alv_gnre.
    CLEAR: qtd_doc_obrig, vl_bloq_campo, ybr_gnre_1000.

    IF obj_cont_gnre IS NOT INITIAL.
      CALL METHOD obj_alv_gnre->refresh_table_display.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_gerar_xml

* Thiago Alves - #63428 - 25.09.2013 - INICIO
*&---------------------------------------------------------------------*
*&      Form  f_buscar_notas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_buscar_notas.
  IF ybr_gnre_1000-empresa IS INITIAL.
    MESSAGE 'Preencha a empresa' TYPE 'W'.
    EXIT.
  ELSEIF ybr_gnre_1000-filial IS INITIAL.
    MESSAGE 'Preencha a filial' TYPE 'W'.
    EXIT.
  ENDIF.

  PERFORM f_verificar_existe_alv        .

  IF vl_erro IS INITIAL.
    PERFORM: f_selecionar_parametros  ,
             f_salvar_periodo_pesquisa,
             f_procurar_nf_sap_periodo.

    IF tl_alv_gnre IS NOT INITIAL.
      PERFORM f_informar_qtd_notas.

      PERFORM f_montar_fieldcatalog
       TABLES tl_fcat_gnre
        USING wl_fcat_gnre
              c_alv_gnre. " YBR_GNRE_1000

      PERFORM: f_montar_alv_gnre,
               f_limpar_campos  .

      vl_bloq_campo = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_buscar_notas

*&---------------------------------------------------------------------*
*&      Form  f_selecionar_parametros
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_selecionar_parametros.
  SELECT * FROM ybr_gnre_param
      INTO TABLE tl_parametros.

*----------------------------------------------------------------------
* Data da última Execução
*----------------------------------------------------------------------
  CLEAR wl_parametros.

  READ TABLE tl_parametros
  INTO wl_parametros
  WITH KEY param = c_dt_ult_exec " DT_LST_EXE
  BINARY SEARCH.

  vl_dt_ult_exec = wl_parametros-valor.

*----------------------------------------------------------------------
* Hora da última Execução
*----------------------------------------------------------------------
  CLEAR wl_parametros.

  READ TABLE tl_parametros
  INTO wl_parametros
  WITH KEY param = c_hr_lst_exec " HR_LST_EXE
  BINARY SEARCH.

  vl_hora_ult_exec = wl_parametros-valor.

*----------------------------------------------------------------------
* Tipo da Condição
*----------------------------------------------------------------------
  CLEAR wl_parametros.

  READ TABLE tl_parametros
  INTO wl_parametros
  WITH KEY param = c_tp_cnd " TP_CND
  BINARY SEARCH.

  vl_tp_condicao = wl_parametros-valor.

*----------------------------------------------------------------------
* UF ST GNRE
*----------------------------------------------------------------------
  CLEAR wl_parametros.

  READ TABLE tl_parametros
  INTO wl_parametros
  WITH KEY param = c_uf_st " UF_ST
  BINARY SEARCH.

  vl_uf_st_gnre = wl_parametros-valor.
ENDFORM.                    "f_selecionar_parametros

*&---------------------------------------------------------------------*
*&      Form  f_salvar_periodo_pesquisa
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_salvar_periodo_pesquisa.
  FREE: tl_parametros, wl_parametros.

  DELETE FROM ybr_gnre_param
    WHERE param = c_dt_ult_exec
       OR param = c_hr_lst_exec.

*----------------------------------------------------------------------
* Data da última Execução
*----------------------------------------------------------------------
  wl_parametros-mandt = sy-mandt             .
  wl_parametros-bukrs = ybr_gnre_1000-empresa.
  wl_parametros-param = c_dt_ult_exec        . " DT_LST_EXE
  wl_parametros-valor = sy-datum             .
  APPEND wl_parametros TO tl_parametros      .

*----------------------------------------------------------------------
* Hora da última Execução
*----------------------------------------------------------------------
  wl_parametros-mandt = sy-mandt             .
  wl_parametros-bukrs = ybr_gnre_1000-empresa.
  wl_parametros-param = c_hr_lst_exec        . " HR_LST_EXE
  wl_parametros-valor = sy-uzeit             .
  APPEND wl_parametros TO tl_parametros      .

  MODIFY ybr_gnre_param FROM TABLE tl_parametros.
ENDFORM.                    "f_salvar_periodo_pesquisa

*&---------------------------------------------------------------------*
*&      Form  f_procurar_nf_sap_periodo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_procurar_nf_sap_periodo.
  DATA: vl_taxval TYPE j_1bnfstx-taxval,
        vl_indice TYPE sy-tabix        .

* Cabeçalho da nota fiscal
  SELECT bukrs branch nfenum series docnum docdat parid
   FROM j_1bnfdoc
   INTO TABLE tl_j_1bnfdoc
   WHERE bukrs  = ybr_gnre_1000-empresa
     AND branch = ybr_gnre_1000-filial
     AND regio  = vl_uf_st_gnre
     AND credat >= vl_dt_ult_exec
     AND cretim >= vl_hora_ult_exec.

  IF tl_j_1bnfdoc IS INITIAL.
    MESSAGE 'Dados não encontrados'(018) TYPE 'I'.
  ELSE.
    LOOP AT tl_j_1bnfdoc INTO wl_j_1bnfdoc.
      vl_indice = sy-tabix.

*     Verifica se já foi gerado um XML para essa nota
      SELECT COUNT( * )
       INTO vl_qtd_reg
       FROM ybr_gnre
        WHERE bukrs  = wl_j_1bnfdoc-bukrs
          AND branch = wl_j_1bnfdoc-branch
          AND docnum = wl_j_1bnfdoc-docnum.

      IF vl_qtd_reg IS NOT INITIAL.
        DELETE tl_j_1bnfdoc INDEX vl_indice.
        EXIT.
      ELSE.

*       Soma dos valores dos impostos da nota fiscal
        SELECT SUM( taxval )
         FROM j_1bnfstx
         INTO (vl_taxval)
         WHERE docnum = wl_j_1bnfdoc-docnum
           AND taxtyp = vl_tp_condicao.

*       Nota não possui ICMS de substituição tributária
        IF sy-subrc <> 0.
          DELETE tl_j_1bnfdoc INDEX vl_indice.
          EXIT.
        ELSE.
          IF vl_taxval IS NOT INITIAL.
            CONCATENATE ybr_gnre_1000-dt_vencimento(4)
                        ybr_gnre_1000-dt_vencimento+4(2)
                        ybr_gnre_1000-dt_vencimento+6(2)
                   INTO wl_alv_gnre-dt_vencimento.

            wl_alv_gnre-empresa       = ybr_gnre_1000-empresa.
            wl_alv_gnre-filial        = ybr_gnre_1000-filial .
            wl_alv_gnre-nfe           = wl_j_1bnfdoc-nfenum  .
            wl_alv_gnre-serie         = wl_j_1bnfdoc-series  .
            wl_alv_gnre-taxval        = vl_taxval            .
            wl_alv_gnre-deletar       = c_icone_deletar      .
            APPEND wl_alv_gnre TO tl_alv_gnre                .
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

*   Status das notas fiscais
    SELECT docnum regio nfyear nfmonth stcd1 model serie nfnum9 docnum9 cdv
     FROM j_1bnfe_active
     INTO TABLE tl_j_1bnfe_active
      FOR ALL ENTRIES IN tl_j_1bnfdoc
     WHERE docnum = tl_j_1bnfdoc-docnum.
  ENDIF. " IF tl_j_1bnfdoc IS NOT INITIAL.

ENDFORM.                    "f_procurar_nf_sap_periodo
* Thiago Alves - #63428 - 25.09.2013 - FIM
