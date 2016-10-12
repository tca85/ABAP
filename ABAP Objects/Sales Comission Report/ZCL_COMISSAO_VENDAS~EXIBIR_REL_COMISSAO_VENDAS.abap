*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Relatorio smartform                                       *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  14.10.2014  #***** - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_NR_REGISTRO	TYPE ZSDE_NRG OPTIONAL
*<-- CHANGING IM_T_COMISSAO   TYPE TP_COMISSAO
*<-- IM_T_APROV_COMISSAO      TYPE TP_APROV_COMISSAO OPTIONAL

METHOD exibir_rel_comissao_vendas.

*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
  TYPES:
   BEGIN OF ty_fornecedor   ,
     lifnr TYPE lfa1-lifnr  , " Nº conta do fornecedor
   END OF ty_fornecedor     ,

   BEGIN OF ty_funcionario  ,
     pernr TYPE pa0001-pernr, " Nº pessoal
   END OF ty_funcionario    ,

   BEGIN OF ty_lfa1         ,
     lifnr TYPE lfa1-lifnr  , " Nº conta do fornecedor
     name1 TYPE lfa1-name1  , " Nome do fornecedor
     stras TYPE lfa1-stras  , " Endereço
     stcd1 TYPE lfa1-stcd1  , " Número do CNPJ
     stcd3 TYPE lfa1-stcd3  , " IE
     telf1 TYPE lfa1-telf1  , " Telefone
     adrnr TYPE lfa1-adrnr  , " E-mail
   END OF ty_lfa1           .

*----------------------------------------------------------------------*
* Tabelas Internas                                                     *
*----------------------------------------------------------------------*
  DATA:
    t_cabecalho      TYPE STANDARD TABLE OF zsde033c         ,
    t_item           TYPE STANDARD TABLE OF zsde033i         ,
    t_cv_item        TYPE STANDARD TABLE OF zsdt033i         ,
    t_cv_cabecalho   TYPE STANDARD TABLE OF zsdt033c         ,
    t_fornecedor     TYPE STANDARD TABLE OF ty_fornecedor    ,
    t_funcionario    TYPE STANDARD TABLE OF ty_funcionario   ,
    t_comissao       TYPE STANDARD TABLE OF ty_comissao      ,
    t_aprov_com_aux  TYPE STANDARD TABLE OF ty_aprov_comissao.

*----------------------------------------------------------------------*
* Work-Areas                                                           *
*----------------------------------------------------------------------*
  DATA:
    w_cv_item       LIKE LINE OF t_cv_item      ,
    w_item          LIKE LINE OF t_item         ,
    w_cabecalho     LIKE LINE OF t_cabecalho    ,
    w_cv_cabecalho  LIKE LINE OF t_cv_cabecalho ,
    w_comissao      LIKE LINE OF t_comissao     ,
    w_fornecedor    LIKE LINE OF t_fornecedor   ,
    w_funcionario   LIKE LINE OF t_funcionario  ,
    w_aprov_com_aux LIKE LINE OF t_aprov_com_aux,
    w_lfa1          TYPE ty_lfa1                .

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
  DATA:
    v_funcao_smartform TYPE rs38l_fnam,
    v_indice           TYPE sy-tabix  ,
    v_msg_erro         TYPE t100-text .

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
  CONSTANTS
    c_smartform_rel_com TYPE tdsfname VALUE 'ZSD_COMISSAO_VENDAS'.

*----------------------------------------------------------------------*
* Início                                                               *
*----------------------------------------------------------------------*

  APPEND LINES OF im_t_aprov_comissao TO t_aprov_com_aux.
  SORT t_aprov_com_aux BY conf ASCENDING.
  DELETE t_aprov_com_aux WHERE conf IS INITIAL.

  IF t_aprov_com_aux IS NOT INITIAL.
    SELECT * FROM zsdt033c
     INTO TABLE t_cv_cabecalho
     FOR ALL ENTRIES IN t_aprov_com_aux
     WHERE nrg = t_aprov_com_aux-nrg.

    SELECT * FROM zsdt033i
     INTO TABLE t_cv_item
     FOR ALL ENTRIES IN t_aprov_com_aux
     WHERE nrg = t_aprov_com_aux-nrg.
  ENDIF.

  LOOP AT t_cv_cabecalho INTO w_cv_cabecalho.
    READ TABLE t_cv_item
    TRANSPORTING NO FIELDS
    WITH KEY nrg = w_cv_cabecalho-nrg.

    v_indice = sy-tabix.

    LOOP AT t_cv_item INTO w_cv_item FROM v_indice.
      IF w_cv_item-nrg <> w_cv_cabecalho-nrg.
        EXIT.
      ENDIF.

      w_comissao-lifnr = w_cv_cabecalho-lifnr.
      w_comissao-pernr = w_cv_cabecalho-pernr.
      w_comissao-vbeln = w_cv_item-vbeln.
      w_comissao-erdat = w_cv_cabecalho-erdat1.
      w_comissao-bstnk = w_cv_item-bstnk.
      w_comissao-netwr = w_cv_item-netwr.
      w_comissao-vcom  = w_cv_item-vcom.
      w_comissao-vcomp = w_cv_item-vcomp.
      w_comissao-vcopd = w_cv_item-vcopd.
      w_comissao-conf  = abap_true.
      APPEND w_comissao TO t_comissao.
    ENDLOOP.
  ENDLOOP.

  APPEND LINES OF im_t_comissao TO t_comissao.
  SORT t_comissao BY conf ASCENDING.
  DELETE t_comissao WHERE conf IS INITIAL.

  IF t_comissao IS INITIAL.
*   Selecione as notas antes de simular
    MESSAGE e004(zsdr033) INTO v_msg_erro.
    RAISE EXCEPTION TYPE zcx_comissao_vendas EXPORTING mensagem = v_msg_erro.
  ENDIF.

* Obter o nome do módulo de função do Smartform 'ZSD_COMISSAO_VENDAS'
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname = c_smartform_rel_com
    IMPORTING
      fm_name  = v_funcao_smartform
    EXCEPTIONS
      OTHERS   = 3.

  CHECK v_funcao_smartform IS NOT INITIAL.

  LOOP AT t_comissao INTO w_comissao.
    CLEAR: w_fornecedor, w_funcionario.

    IF w_comissao-lifnr IS NOT INITIAL.
      w_fornecedor-lifnr = w_comissao-lifnr.
      APPEND w_fornecedor TO t_fornecedor.
    ENDIF.

    IF w_comissao-pernr IS NOT INITIAL.
      w_funcionario-pernr = w_comissao-pernr.
      APPEND w_funcionario TO t_funcionario.
    ENDIF.
  ENDLOOP.

  SORT: t_fornecedor  BY lifnr ASCENDING,
        t_funcionario BY pernr ASCENDING.

  DELETE ADJACENT DUPLICATES FROM: t_fornecedor, t_funcionario.

  SORT t_comissao BY lifnr ASCENDING.

  LOOP AT t_fornecedor INTO w_fornecedor.
    FREE: w_cabecalho, t_item.

    READ TABLE t_comissao
    TRANSPORTING NO FIELDS
    WITH KEY lifnr = w_fornecedor-lifnr.

    v_indice = sy-tabix.

    LOOP AT t_comissao INTO w_comissao FROM v_indice.
      IF w_comissao-lifnr <> w_fornecedor-lifnr.
        EXIT.
      ENDIF.

      FREE: w_item, w_lfa1.

      IF w_comissao-lifnr IS NOT INITIAL.
        SELECT SINGLE lifnr name1 stras stcd1
                      stcd3 telf1 adrnr
        FROM lfa1
        INTO w_lfa1
         WHERE lifnr = w_comissao-lifnr.

        w_cabecalho-endereco = w_lfa1-stras.
        w_comissao-name1     = w_lfa1-name1.
        w_cabecalho-cnpj     = w_lfa1-stcd1.
        w_cabecalho-ie       = w_lfa1-stcd3.
        w_cabecalho-telefone = w_lfa1-telf1.

        SELECT SINGLE smtp_addr
         FROM adr6
         INTO w_cabecalho-email
         WHERE addrnumber = w_lfa1-adrnr.
      ENDIF.

      w_cabecalho-representante = w_comissao-name1.

      IF im_nr_registro IS NOT INITIAL.
        w_cabecalho-nro_controle = im_nr_registro.
      ELSE.
        CLEAR w_aprov_com_aux.

        READ TABLE t_aprov_com_aux
        INTO w_aprov_com_aux
        WITH KEY lifnr = w_comissao-lifnr.

        w_cabecalho-nro_controle = w_aprov_com_aux-nrg.
      ENDIF.

      w_cabecalho-dt_criacao = sy-datum.
      APPEND w_cabecalho TO t_cabecalho.

      SELECT SINGLE bstnk
       FROM vbak
       INTO w_item-nro_pedido
       WHERE vbeln = w_comissao-vbeln.

      w_item-vl_comissao  = w_comissao-vcom .
      w_item-vl_compensar = w_comissao-vcopd. " Valor compensado
      APPEND w_item TO t_item.
    ENDLOOP.

    CALL FUNCTION v_funcao_smartform
      EXPORTING
        w_cabecalho = w_cabecalho
      TABLES
        t_item      = t_item
      EXCEPTIONS
        OTHERS      = 5.
  ENDLOOP.

  SORT t_comissao BY pernr ASCENDING.

  LOOP AT t_funcionario INTO w_funcionario.
    FREE: w_cabecalho, t_item.

    READ TABLE t_comissao
    TRANSPORTING NO FIELDS
    WITH KEY pernr = w_funcionario-pernr.

    v_indice = sy-tabix.

    LOOP AT t_comissao INTO w_comissao FROM v_indice.
      IF w_comissao-pernr <> w_funcionario-pernr.
        EXIT.
      ENDIF.

      w_cabecalho-representante = w_comissao-name1.
      w_cabecalho-nro_controle  = im_nr_registro  .
      w_cabecalho-dt_criacao    = sy-datum        .
      APPEND w_cabecalho TO t_cabecalho           .

      SELECT SINGLE bstnk
       FROM vbak
       INTO w_item-nro_pedido
       WHERE vbeln = w_comissao-vbeln.

      w_item-vl_comissao  = w_comissao-vcom .
      w_item-vl_compensar = w_comissao-vcopd. " valor compensado
      APPEND w_item TO t_item               .
    ENDLOOP.

    CALL FUNCTION v_funcao_smartform
      EXPORTING
        w_cabecalho = w_cabecalho
      TABLES
        t_item      = t_item
      EXCEPTIONS
        OTHERS      = 5.
  ENDLOOP.

ENDMETHOD.
