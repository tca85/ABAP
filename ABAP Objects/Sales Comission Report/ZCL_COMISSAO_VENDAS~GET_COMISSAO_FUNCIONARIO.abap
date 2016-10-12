*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obter comissão do fornecedor                              *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  16.10.2014  #***** - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_VBELN TYPE R_VBELN  N° do documento de vendas
*--> IMPORTING IM_PERNR TYPE R_PERNR  N° do funcionário
*--> IMPORTING IM_ERDAT TYPE R_ERDAT  Data da criação
*--> IMPORTING IM_VKORG TYPE R_VKORG  Organização de vendas
*--> IMPORTING IM_VTWEG TYPE R_VTWEG  Canal de distribuição
*--> IMPORTING IM_SPART TYPE R_SPART  Setor de atividade
*--> IMPORTING IM_VKBUR TYPE R_VKBUR  Escritório de vendas
*<-- RETURNING EX_T_COMISSAO TYPE TP_COMISSAO	Comissão

METHOD get_comissao_funcionario.
*----------------------------------------------------------------------*
* Tabelas Internas                                                     *
*----------------------------------------------------------------------*
  DATA:
    t_vbak       TYPE STANDARD TABLE OF ty_vbak      ,
    t_vbpa       TYPE STANDARD TABLE OF ty_vbpa      ,
    t_vbkd       TYPE STANDARD TABLE OF ty_vbkd      ,
    t_cond_parc  TYPE STANDARD TABLE OF ty_cond_parc ,
    t_konv_total TYPE STANDARD TABLE OF ty_konv_total,
    t_pa0001     TYPE STANDARD TABLE OF ty_pa0001    .

*----------------------------------------------------------------------*
* Ranges                                                               *
*----------------------------------------------------------------------*
  DATA:
    r_parvw TYPE RANGE OF parvw,
    r_kschl TYPE RANGE OF kschl.

*----------------------------------------------------------------------*
* Work-Areas / Field-Symbols                                           *
*----------------------------------------------------------------------*
  DATA:
    w_comissao LIKE LINE OF ex_t_comissao.

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro TYPE t100-text   ,
    v_qtd_reg  TYPE i           ,
    v_nro_reg  TYPE zsdt033i-nrg,
    v_indice   TYPE sy-tabix    .

*----------------------------------------------------------------------*
* Início                                                               *
*----------------------------------------------------------------------*
  SELECT vbeln " Documento de vendas
         erdat " Data de criação do registro
         vkorg " Organização de vendas
         vtweg " Canal de distribuição
         spart " Setor de atividade
         vkbur " Escritório de vendas
         knumv " Nº condição do documento
         netwr " Valor líquido da ordem
         bstnk " Nº pedido do cliente
    FROM vbak  " Documento de vendas: dados de cabeçalho
    INTO TABLE t_vbak
    WHERE vbeln IN im_vbeln
      AND erdat IN im_erdat
      AND vkorg IN im_vkorg
      AND vtweg IN im_vtweg
      AND spart IN im_spart
      AND vkbur IN im_vkbur.

* Exclui as notas que já foram registradas
  LOOP AT t_vbak ASSIGNING FIELD-SYMBOL(<f_w_vbak>).
    v_indice = sy-tabix.

    SELECT SINGLE nrg
     FROM zsdt033i
     INTO v_nro_reg
     WHERE vbeln = <f_w_vbak>-vbeln.

    IF sy-subrc = 0.
      SELECT COUNT( DISTINCT nrg )
       FROM zsdt033c
       INTO v_qtd_reg
       WHERE nrg = v_nro_reg
         AND pernr <> space.

      IF v_qtd_reg <> 0.
        DELETE t_vbak INDEX v_indice.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF t_vbak IS INITIAL.
    MESSAGE e001(zsdr033) INTO v_msg_erro.
    RAISE EXCEPTION TYPE zcx_comissao_vendas EXPORTING mensagem = v_msg_erro.
  ENDIF.

  me->get_tipo_condicao_parceiro( EXPORTING im_tipo_parceiro = me->c_rep_interno
                                   CHANGING ex_r_kschl       = r_kschl
                                            ex_r_parvw       = r_parvw
                                            ex_t_cond_parc   = t_cond_parc ).

  SELECT vbeln " Nº documento de vendas e distribuição
         lifnr " Nº conta do fornecedor
         pernr " Nº pessoal
         parvw " Função do parceiro
  FROM vbpa    " Documento SD: parceiro
  INTO TABLE t_vbpa
  FOR ALL ENTRIES IN t_vbak
   WHERE vbeln EQ t_vbak-vbeln
     AND parvw IN r_parvw
     AND pernr IN im_pernr.

  SORT t_vbpa BY pernr ASCENDING.
  DELETE t_vbpa WHERE pernr IS INITIAL.

  IF t_vbpa IS INITIAL.
*     Não encontrou parceiros para as notas
    MESSAGE e003(zsdr033) INTO v_msg_erro.
    RAISE EXCEPTION TYPE zcx_comissao_vendas EXPORTING mensagem = v_msg_erro.
  ENDIF.

  SORT:
     t_vbak BY vbeln ASCENDING,
     t_vbpa BY vbeln ASCENDING.

  LOOP AT t_vbak ASSIGNING <f_w_vbak>.
    v_indice = sy-tabix.

    READ TABLE t_vbpa
    ASSIGNING FIELD-SYMBOL(<f_w_vbpa>)
    WITH KEY vbeln = <f_w_vbak>-vbeln
    BINARY SEARCH.

    IF sy-subrc <> 0.
      DELETE t_vbak INDEX v_indice.
    ENDIF.
  ENDLOOP.

  SELECT pernr " Nº pessoal
         sname " Nome do empregado
  FROM pa0001  " Mestre de fornecedores (parte geral)
  INTO TABLE t_pa0001
  FOR ALL ENTRIES IN t_vbpa
   WHERE pernr = t_vbpa-pernr.

  me->get_val_total_comissao( EXPORTING im_t_vbak       = t_vbak
                                        im_r_kschl      = r_kschl
                               CHANGING ex_t_konv_total = t_konv_total ).

  SELECT vbeln " Nº documento de vendas e distribuição
         zterm " Chave de condições de pagamento
  FROM vbkd    " Documento de vendas: dados comerciais
  INTO TABLE t_vbkd
  FOR ALL ENTRIES IN t_vbak
   WHERE vbeln = t_vbak-vbeln.

  SORT:
     t_vbak       BY vbeln ASCENDING,
     t_vbpa       BY vbeln ASCENDING,
     t_vbkd       BY vbeln ASCENDING,
     t_pa0001     BY pernr ASCENDING,
     t_konv_total BY knumv ASCENDING.

  LOOP AT t_vbak ASSIGNING <f_w_vbak>.
    CLEAR w_comissao.

*   Parceiro
    READ TABLE t_vbpa
    TRANSPORTING NO FIELDS
    WITH KEY vbeln = <f_w_vbak>-vbeln
    BINARY SEARCH.

    v_indice = sy-tabix.

    LOOP AT t_vbpa ASSIGNING <f_w_vbpa> FROM v_indice.
      IF <f_w_vbpa>-vbeln <> <f_w_vbak>-vbeln.
        EXIT.
      ENDIF.

*     Registro mestre HR
      READ TABLE t_pa0001
      ASSIGNING FIELD-SYMBOL(<f_w_pa0001>)
      WITH KEY pernr = <f_w_vbpa>-pernr
      BINARY SEARCH.

      IF sy-subrc = 0.
        w_comissao-pernr = <f_w_pa0001>-pernr. " Nº pessoal
        w_comissao-name1 = <f_w_pa0001>-sname. " Nome
      ENDIF.

      w_comissao-vbeln = <f_w_vbak>-vbeln. " Documento de vendas
      w_comissao-erdat = <f_w_vbak>-erdat. " Data de criação do registro
      w_comissao-bstnk = <f_w_vbak>-bstnk. " Nº pedido do cliente

*     Dados comerciais do documento de vendas
      READ TABLE t_vbkd
      ASSIGNING FIELD-SYMBOL(<f_w_vbkd>)
      WITH KEY vbeln = <f_w_vbak>-vbeln
      BINARY SEARCH.

      IF sy-subrc = 0.
        w_comissao-zterm = <f_w_vbkd>-zterm. " Chave de condições de pagamento
      ENDIF.

      w_comissao-vkorg = <f_w_vbak>-vkorg. " Organização de vendas
      w_comissao-vtweg = <f_w_vbak>-vtweg. " Canal de distribuição
      w_comissao-spart = <f_w_vbak>-spart. " Setor de atividade
      w_comissao-netwr = <f_w_vbak>-netwr. " Valor líquido da ordem

*     Tipo de condição x Parceiro (ZF01 x F01)
      READ TABLE t_cond_parc
      ASSIGNING FIELD-SYMBOL(<f_w_cond_parc>)
      WITH KEY parvw = <f_w_vbpa>-parvw
      BINARY SEARCH.

      IF sy-subrc = 0.
        READ TABLE t_konv_total
        ASSIGNING FIELD-SYMBOL(<f_w_konv_total>)
        WITH KEY knumv = <f_w_vbak>-knumv
        BINARY SEARCH.

        IF sy-subrc = 0.
          w_comissao-vcom = <f_w_konv_total>-kwert. " Valor total da comissão
*         Valor total da comissão
          CHECK w_comissao-vcom IS NOT INITIAL.
          APPEND w_comissao TO ex_t_comissao.
        ENDIF.
      ENDIF.

    ENDLOOP. " LOOP AT t_vbpa ASSIGNING <f_w_vbpa>
  ENDLOOP. " LOOP AT t_vbak ASSIGNING <f_w_vbak>

  me->get_val_compensado_financeiro( CHANGING im_t_comissao = ex_t_comissao ).

ENDMETHOD.
