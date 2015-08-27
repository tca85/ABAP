REPORT yfi0045 NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
* Programa...: YFI0045                                                 *
* Transação..: YFI0045                                                 *
* Descrição..: Rel. ficha de crédito de clientes                       *
*              Chamada dinâmica ao report standard RFDKLI41            *
* Tipo.......: ALV                                                     *
* Módulo.....: FI                                                      *
* ABAP.......: Thiago Cordeiro Alves                                   *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  26.08.2015  #118718 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_tela_selecao ,
    kunnr TYPE knkk-kunnr  , " Nº cliente
    kkber TYPE knkk-kkber  , " Área de controle de créditos
  END OF ty_tela_selecao   ,

  BEGIN OF ty_conta_cliente,
    kunnr TYPE knkk-kunnr  , " Nº cliente
    name1 TYPE kna1-name1  , " Nome
    kkber TYPE knkk-kkber  , " Área de controle de créditos
    knkli TYPE knkk-knkli  , " Nº conta de cliente c/respectivos dados de limite de crédito
  END OF ty_conta_cliente  .

*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
DATA:
   t_conta_cliente TYPE STANDARD TABLE OF ty_conta_cliente,
   t_alv           TYPE STANDARD TABLE OF yalv_fi0045     ,
   t_bdc_msg       TYPE tab_bdcmsgcoll                    .

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
DATA:
   w_tela_selecao  TYPE ty_tela_selecao        ,
   w_conta_cliente LIKE LINE OF t_conta_cliente,
   w_alv           LIKE LINE OF t_alv          ,
   w_bdc_msg       LIKE LINE OF t_bdc_msg      ,
   w_msg_erro      TYPE bal_s_msg              ,
   w_layout_key    TYPE salv_s_layout_key      .

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
DATA:
   v_msg_erro         TYPE string     ,
   v_qtd_clientes     TYPE sy-tabix   ,
   v_porcentagem      TYPE p          ,
   v_porcentagem_char TYPE c LENGTH 3 ,
   v_texto_indicador  TYPE c LENGTH 50,
   v_subrc            TYPE sy-subrc   ,
   v_indice_cliente   TYPE sy-tabix   ,
   v_indice_alv       TYPE sy-tabix   ,
   v_valor_txt        TYPE c LENGTH 20.

*----------------------------------------------------------------------*
* Variáveis tipo referência
*----------------------------------------------------------------------*
DATA:
   o_bdc                     TYPE REF TO ycl_bdc                   ,
   o_data                    TYPE REF TO data                      ,
   o_salv_table              TYPE REF TO cl_salv_table             , " Basis Class for Simple Tables
   o_salv_functions          TYPE REF TO cl_salv_functions_list    , " Generic and User-Defined Functions in List-Type Tables
   o_salv_columns_table      TYPE REF TO cl_salv_columns_table     , " Columns in Simple, Two-Dimensional Tables
   o_cl_salv_layout          TYPE REF TO cl_salv_layout            , " Settings for Layout
   o_cx_salv_msg             TYPE REF TO cx_salv_msg               , " ALV: General Error Class with Message
   o_salv_bs_sc_runtime_info TYPE REF TO cx_salv_bs_sc_runtime_info. "#EC NEEDED

*----------------------------------------------------------------------*
* Objetos dinâmicos
*----------------------------------------------------------------------*
FIELD-SYMBOLS:
   <t_alv_dinamico>   TYPE ANY TABLE,
   <w_alv_dinamico>   TYPE ANY      ,
   <v_nome_coluna_01> TYPE simple   ,
   <v_nome_coluna_02> TYPE simple   ,
   <v_conteudo_fval1> TYPE simple   ,
   <v_conteudo_fval2> TYPE simple   .

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
CONSTANTS:
   c_variante_default   TYPE slis_vari  VALUE 'DEFAULT',
   c_matriz             TYPE tras-rasid VALUE 'R01N'   ,
   c_ctrl_credito_geral TYPE t014-kkber VALUE '0050'   .

*----------------------------------------------------------------------*
* Tela de seleção
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t001          . " Outras delimitações
SELECT-OPTIONS: s_kunnr FOR w_tela_selecao-kunnr                  . " Chave do grupo de listas de tarefas
PARAMETERS: p_kkber LIKE w_tela_selecao-kkber OBLIGATORY          . " Área de controle de créditos
SELECTION-SCREEN END OF BLOCK b1                                  .

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE t002          . " Outras delimitações
PARAMETERS: p_cc RADIOBUTTON GROUP r1 DEFAULT 'X'USER-COMMAND rusr, " Conta de crédito
            p_cli  RADIOBUTTON GROUP r1                           . " Cliente
SELECTION-SCREEN END OF BLOCK b2                                  .

*----------------------------------------------------------------------*
* Process Before Output
*----------------------------------------------------------------------*
INITIALIZATION.
  t001    = 'Cliente'           .                           "#EC NOTEXT
  t002    = 'Tipo de saída'     .                           "#EC NOTEXT
  p_kkber = c_ctrl_credito_geral.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  IF s_kunnr IS INITIAL.
    MESSAGE 'A pesquisa sem cliente será lenta. Deseja prosseguir?'
       TYPE 'W'.                                            "#EC NOTEXT
  ENDIF.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
START-OF-SELECTION.

  IF sy-langu <> 'P'.
    MESSAGE 'Só funciona no idioma Português'
       TYPE 'S' DISPLAY LIKE 'E'.                           "#EC NOTEXT
    EXIT.
  ENDIF.

* Seleciona o range de clientes da tela de seleção
  SELECT knkk~kunnr
         kna1~name1
         knkk~kkber
         knkk~knkli
   FROM knkk
   INNER JOIN kna1 ON knkk~kunnr = kna1~kunnr
   INTO TABLE t_conta_cliente
    WHERE knkk~kunnr IN s_kunnr
      AND knkk~kkber = p_kkber.

  IF p_cc IS NOT INITIAL.
    LOOP AT t_conta_cliente INTO w_conta_cliente.
      v_indice_alv = sy-tabix.

      IF w_conta_cliente-kunnr <> w_conta_cliente-knkli.
        DELETE t_conta_cliente INDEX v_indice_alv.
      ENDIF.
    ENDLOOP.
  ENDIF.

  DESCRIBE TABLE t_conta_cliente LINES v_qtd_clientes.

  LOOP AT t_conta_cliente INTO w_conta_cliente.
    v_indice_cliente = sy-tabix.

    FREE: o_data, w_alv, w_bdc_msg, v_msg_erro, t_bdc_msg, v_subrc.

    UNASSIGN: <t_alv_dinamico>, <w_alv_dinamico>.

*   Evita TimeOut na sessão
    CALL FUNCTION 'TH_REDISPATCH'.

    v_porcentagem = ( v_indice_cliente / v_qtd_clientes ) * 100.
    v_porcentagem_char = v_porcentagem.
    SHIFT v_porcentagem_char LEFT DELETING LEADING space.

    CONCATENATE space v_porcentagem_char '% de processamento' INTO v_texto_indicador.

*   Barra de progresso
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = v_porcentagem
        text       = v_texto_indicador.

    cl_salv_bs_runtime_info=>set( EXPORTING display  = abap_false
                                            metadata = abap_false
                                            data     = abap_true ).

*   Rel. ficha de crédito de clientes
    o_bdc = ycl_bdc=>s_instantiate( im_bdc_type = 'CT'
                                    im_tcode    = 'S_ALR_87012218'              ).

    o_bdc->add_screen( im_repid = 'RFDKLI41'   im_dynnr = '1000'                ).
    o_bdc->add_field( im_fld    = 'KUNNR'      im_val   = w_conta_cliente-kunnr ). " Nº do cliente
    o_bdc->add_field( im_fld    = 'KKBER'      im_val   = w_conta_cliente-kkber ). " Área de controle de créditos
    o_bdc->add_field( im_fld    = 'RASID'      im_val   = c_matriz              ). " Identificação da matriz (dias de atraso)
    o_bdc->add_field( im_fld    = 'BDC_OKCODE' im_val   = '=ONLI'               ).

    o_bdc->add_screen( im_repid = 'SAPMSSY0'   im_dynnr = '0120'                ).
    o_bdc->add_field( im_fld    = 'BDC_OKCODE' im_val   = '=&F03'               ).

    o_bdc->add_screen( im_repid = 'RFDKLI41'   im_dynnr = '1000'                ).
    o_bdc->add_field( im_fld    = 'BDC_OKCODE' im_val   = '/EE'                 ).

    o_bdc->process( IMPORTING ex_subrc    = v_subrc
                              ex_messages = t_bdc_msg ).

    o_bdc->clear_bdc_data( ).

    o_bdc->s_free_instance( ).

    TRY.
*       Obtém a tabela que foi exportada para a memória
        cl_salv_bs_runtime_info=>get_data_ref( IMPORTING r_data = o_data ).

      CATCH cx_salv_bs_sc_runtime_info INTO o_salv_bs_sc_runtime_info.
        MESSAGE 'Erro ao retornar os dados da Ficha de crédito (RFDKLI41)' TYPE 'E'. "#EC NOTEXT
    ENDTRY.

*   Não dá para acessar diretamente o conteúdo da referência, é obrigatório usar o
*   dereferencing operator ->* para mover os valores para um field-symbol
    IF o_data IS BOUND.
      ASSIGN o_data->* TO <t_alv_dinamico>.

      cl_salv_bs_runtime_info=>clear_all( ).
    ENDIF.

*   Se não verificar que está atribuido, pode ocorrer dump
    IF <t_alv_dinamico> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.

*   Insere uma linha em branco na tabela do ALV
    APPEND INITIAL LINE TO t_alv.

    LOOP AT <t_alv_dinamico> ASSIGNING <w_alv_dinamico>.
      v_indice_alv = sy-tabix.

      ASSIGN COMPONENT 'FTXT1' OF STRUCTURE <w_alv_dinamico> TO <v_nome_coluna_01>. " Nome da coluna 1
      ASSIGN COMPONENT 'FTXT2' OF STRUCTURE <w_alv_dinamico> TO <v_nome_coluna_02>. " Nome da coluna 2
      ASSIGN COMPONENT 'FVAL1' OF STRUCTURE <w_alv_dinamico> TO <v_conteudo_fval1>. " Valor da coluna 1
      ASSIGN COMPONENT 'FVAL2' OF STRUCTURE <w_alv_dinamico> TO <v_conteudo_fval2>. " Valor da coluna 2

      IF <v_nome_coluna_01> IS NOT ASSIGNED
        AND <v_nome_coluna_02> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      CASE <v_nome_coluna_01>.
        WHEN 'Cliente'.
          IF <v_conteudo_fval1> IS ASSIGNED.
            w_alv-kunnr = <v_conteudo_fval1>.
            w_alv-name1 = w_conta_cliente-name1.
          ENDIF.

        WHEN 'Lim.crédito'.
          IF <v_conteudo_fval1> IS ASSIGNED.
            CLEAR v_valor_txt.

            REPLACE ALL OCCURENCES OF '.' IN <v_conteudo_fval1> WITH space.
            REPLACE ALL OCCURRENCES OF ',' IN <v_conteudo_fval1> WITH '.'.
            CONDENSE <v_conteudo_fval1> NO-GAPS.
            WRITE <v_conteudo_fval1> TO v_valor_txt DECIMALS 2.

            w_alv-limc = v_valor_txt.
          ENDIF.

        WHEN 'Esgotamento'.
          IF <v_conteudo_fval1> IS ASSIGNED.
            CLEAR v_valor_txt.

            SEARCH <v_conteudo_fval1> FOR '%'.

            IF sy-subrc = 0.
              REPLACE ALL OCCURENCES OF '.' IN <v_conteudo_fval1> WITH space.
              REPLACE ALL OCCURRENCES OF ',' IN <v_conteudo_fval1> WITH '.'.
              CONDENSE <v_conteudo_fval1> NO-GAPS.
              WRITE <v_conteudo_fval1> TO v_valor_txt.

              w_alv-esgot_perc = v_valor_txt.

            ELSE.
              REPLACE ALL OCCURENCES OF '.' IN <v_conteudo_fval1> WITH space.
              REPLACE ALL OCCURRENCES OF ',' IN <v_conteudo_fval1> WITH '.'.
              CONDENSE <v_conteudo_fval1> NO-GAPS.
              WRITE <v_conteudo_fval1> TO v_valor_txt DECIMALS 2.

              w_alv-esgot = v_valor_txt.

            ENDIF.
          ENDIF.

        WHEN 'Delta'.
          IF <v_conteudo_fval1> IS ASSIGNED.
            CLEAR v_valor_txt.

            REPLACE ALL OCCURENCES OF '.' IN <v_conteudo_fval1> WITH space.
            REPLACE ALL OCCURRENCES OF ',' IN <v_conteudo_fval1> WITH '.'.
            CONDENSE <v_conteudo_fval1> NO-GAPS.
            WRITE <v_conteudo_fval1> TO v_valor_txt DECIMALS 2.

            w_alv-delta = v_valor_txt.
          ENDIF.
      ENDCASE.

      CASE <v_nome_coluna_02>.
        WHEN 'Dívid.a receber'.
          IF <v_conteudo_fval2> IS ASSIGNED.
            CLEAR v_valor_txt.

            REPLACE ALL OCCURENCES OF '.' IN <v_conteudo_fval2> WITH space.
            REPLACE ALL OCCURRENCES OF ',' IN <v_conteudo_fval2> WITH '.'.
            CONDENSE <v_conteudo_fval2> NO-GAPS.
            WRITE <v_conteudo_fval2> TO v_valor_txt DECIMALS 2.

            w_alv-divida = v_valor_txt.
          ENDIF.

        WHEN 'Comprom.espec.'.
          IF <v_conteudo_fval2> IS ASSIGNED.
            CLEAR v_valor_txt.

            REPLACE ALL OCCURENCES OF '.' IN <v_conteudo_fval2> WITH space.
            REPLACE ALL OCCURRENCES OF ',' IN <v_conteudo_fval2> WITH '.'.
            CONDENSE <v_conteudo_fval2> NO-GAPS.
            WRITE <v_conteudo_fval2> TO v_valor_txt DECIMALS 2.

            w_alv-comp = v_valor_txt.
          ENDIF.

        WHEN 'Val.remessa aberto'.
          IF <v_conteudo_fval2> IS ASSIGNED.
            CLEAR v_valor_txt.

            REPLACE ALL OCCURENCES OF '.' IN <v_conteudo_fval2> WITH space.
            REPLACE ALL OCCURRENCES OF ',' IN <v_conteudo_fval2> WITH '.'.
            CONDENSE <v_conteudo_fval2> NO-GAPS.
            WRITE <v_conteudo_fval2> TO v_valor_txt DECIMALS 2.

            w_alv-vl_rem = v_valor_txt.
          ENDIF.

        WHEN 'Valor ordem aberto'.
          IF <v_conteudo_fval2> IS ASSIGNED.
            CLEAR v_valor_txt.

            REPLACE ALL OCCURENCES OF '.' IN <v_conteudo_fval2> WITH space.
            REPLACE ALL OCCURRENCES OF ',' IN <v_conteudo_fval2> WITH '.'.
            CONDENSE <v_conteudo_fval2> NO-GAPS.
            WRITE <v_conteudo_fval2> TO v_valor_txt DECIMALS 2.

            w_alv-vl_oa = v_valor_txt.
          ENDIF.

        WHEN 'Val.doc.fat.aberto'.
          IF <v_conteudo_fval2> IS ASSIGNED.
            CLEAR v_valor_txt.

            REPLACE ALL OCCURENCES OF '.' IN <v_conteudo_fval2> WITH space.
            REPLACE ALL OCCURRENCES OF ',' IN <v_conteudo_fval2>  WITH '.'.
            CONDENSE <v_conteudo_fval2> NO-GAPS.
            WRITE <v_conteudo_fval2> TO v_valor_txt DECIMALS 2.

            w_alv-vl_fa = v_valor_txt.
          ENDIF.

      ENDCASE.

      w_alv-kkber = w_conta_cliente-kkber. " Área de controle de créditos
      w_alv-knkli = w_conta_cliente-knkli. " Nº conta de cliente

      MODIFY t_alv FROM w_alv INDEX v_indice_cliente.

    ENDLOOP. " LOOP AT <t_alv_dinamico> ASSIGNING <w_alv_dinamico>.
  ENDLOOP. " LOOP AT t_cliente INTO w_cliente.

  IF t_alv IS NOT INITIAL.
    SORT t_alv BY kkber kunnr knkli ASCENDING.

    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = o_salv_table
                                 CHANGING t_table      = t_alv ).

      CATCH cx_salv_msg INTO o_cx_salv_msg.
        w_msg_erro = o_cx_salv_msg->get_message( ).

        CONCATENATE w_msg_erro-msgv1
                    w_msg_erro-msgv2
                    w_msg_erro-msgv3
                    w_msg_erro-msgv4
               INTO v_msg_erro SEPARATED BY space.

        MESSAGE v_msg_erro TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
    ENDTRY.

*   Exibe todos os botões da pf-status
    o_salv_functions = o_salv_table->get_functions( ).
    o_salv_functions->set_all( abap_true )          .

*   Permite que o usuário salve uma variante do layout
    o_cl_salv_layout = o_salv_table->get_layout( ).

    w_layout_key-report = sy-repid.

    o_cl_salv_layout->set_key( w_layout_key )                                .
    o_cl_salv_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
    o_cl_salv_layout->set_default( abap_true )                               .
    o_cl_salv_layout->set_initial_layout( c_variante_default )               .

    o_salv_columns_table = o_salv_table->get_columns( ).
    o_salv_columns_table->set_optimize( abap_true )    .

    o_salv_table->display( ).

  ELSE.
    MESSAGE 'Dados não encontrados' TYPE 'S' DISPLAY LIKE 'E'. "#EC NOTEXT
    EXIT.
  ENDIF.