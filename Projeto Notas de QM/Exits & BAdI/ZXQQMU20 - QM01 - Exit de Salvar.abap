*&---------------------------------------------------------------------*
*&  Include           ZXQQMU20
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(I_TQ80)   LIKE TQ80   STRUCTURE TQ80
*"             VALUE(I_AKTYP)  LIKE T365-AKTYP
*"             VALUE(I_VIQMEL) LIKE VIQMEL STRUCTURE VIQMEL
*"       EXPORTING
*"             VALUE(E_VIQMEL) LIKE VIQMEL STRUCTURE VIQMEL
*"             VALUE(E_CHANGE)
*"       TABLES
*"              T_VIQMFE STRUCTURE WQMFE
*"              T_VIQMUR STRUCTURE WQMUR
*"              T_VIQMMA STRUCTURE WQMMA
*"              T_VIQMSM STRUCTURE WQMSM
*"       EXCEPTIONS
*"              EXIT_FROM_SAVE
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*                       xxxxxxxxxxxxxxxxx                              *
*----------------------------------------------------------------------*
* Transação: QM01                                                      *
* Projeto  : CMOD - YNQM                                               *
* Ampliação: SMOD - QQMA0014 / SE37 - EXIT_SAPMIWO0_020                *
* Descrição: QM/PM/SM: controles antes da gravação de uma nota         *
*----------------------------------------------------------------------*
* Objetivo : 1 - Obrigar preenchimento do código do material, lote,    *
*                conta do fornecedor, docto de compras e Tp. de defeito*
*            2 - Não permitir mais de um local de defeito (T_VIQMFE)   *
*            3 - Não permitir salvar nota que não esteja com status    *
*                em processamento                                      *
*            4 - Não permitir salvar nota com ações imediatas sem ação *
*            5 - Bloquear Ação Imediata não concluída p/usuário da tab.*
*            6 - Exibir Popup com Radio Buttons para avaliação da      *
*                especificação, tempo de resposta da RDF, e o suporte  *
*                técnico do fornecedor. As mensagens/peso devem estar  *
*                nas tabelas YNQM_LOCAL_PROB / YNQM_AVALIACAO          *
*            7 - Selecionar idioma e enviar Smartform da RDF como PDF  *
*                em anexo para os parceiros selecionados               *
* Módulo   : QM                                                        *
* Projeto  : Notas de QM (Não-conformidade no recebimento físico)      *
* Funcional: xxxxxxxxxxxxxxxxxxxx                                      *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  05.11.2013  #63782 - Desenvolvimento inicial               *
* ACTHIAGO  06.01.2014  #63782 - Não salvar nota com status diferente  *
*                                de "em processamento"                 *
* ACTHIAGO  22.01.2014  #63782 - Permitir selecionar idioma da RDF     *
* ACTHIAGO  22.01.2014  #63782 - Novos Radio Buttons p/ avaliação      *
* ACTHIAGO  28.01.2014  #63782 - Bloquear Ação Imediata não concluída  *
*----------------------------------------------------------------------*
CHECK sy-tcode = 'QM01'
   OR sy-tcode = 'QM02'.

*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_jest               ,
   objnr TYPE jest-objnr         , " Nº objeto
   stat  TYPE jest-stat          , " Status individual de um objeto
   inact TYPE jest-inact         , " Código: status inativo
  END OF ty_jest                 ,

  BEGIN OF ty_fornecedor         ,
    parnr TYPE ihpa-parnr        , " Nº conta do fornecedor
    email TYPE somlreci1-receiver, " E-mail
  END OF ty_fornecedor           .

*----------------------------------------------------------------------*
* Tabelas internas                                                     *
*----------------------------------------------------------------------*
DATA:
  t_avaliacao         TYPE STANDARD TABLE OF ynqm_avaliacao ,
  t_local_problema    TYPE STANDARD TABLE OF ynqm_local_prob,
  t_usuario           TYPE STANDARD TABLE OF ynqm_usuario   ,
  t_status_envio_rdf  TYPE STANDARD TABLE OF ynqm_envio_rdf ,
  t_fornecedor        TYPE STANDARD TABLE OF ty_fornecedor  ,
  t_jest_buf          TYPE STANDARD TABLE OF ty_jest        ,
  t_status_acao_imed  TYPE STANDARD TABLE OF ty_jest        , " Status individual por ação imediata
  t_rdl_especificacao TYPE STANDARD TABLE OF spopli         ,
  t_rdl_resposta_rdf  TYPE STANDARD TABLE OF spopli         ,
  t_rdl_sup_tecnico   TYPE STANDARD TABLE OF spopli         ,
  t_rdl_idioma_rdf    TYPE STANDARD TABLE OF spopli         ,
  t_destinatario      TYPE STANDARD TABLE OF somlreci1      ,
  t_pdf               TYPE STANDARD TABLE OF tline          ,
  t_anexo_pdf         TYPE STANDARD TABLE OF solisti1       ,
  t_corpo_email       TYPE STANDARD TABLE OF solisti1       ,
  t_packing_list      TYPE STANDARD TABLE OF sopcklsti1     ,
  t_nao_conform       TYPE STANDARD TABLE OF wqmfe          ,
  t_causa_defeito     TYPE STANDARD TABLE OF wqmur          ,
  t_acao_imediata     TYPE STANDARD TABLE OF wqmsm          ,
  t_plano_acao        TYPE STANDARD TABLE OF wqmma          ,
  t_otf               TYPE STANDARD TABLE OF itcoo          .

*----------------------------------------------------------------------*
* Work Areas                                                           *
*----------------------------------------------------------------------*
DATA:
  w_avaliacao         LIKE LINE OF t_avaliacao        ,
  w_local_problema    LIKE LINE OF t_local_problema   ,
  w_usuario           LIKE LINE OF t_usuario          ,
  w_fornecedor        LIKE LINE OF t_fornecedor       ,
  w_status_envio_rdf  LIKE LINE OF t_status_envio_rdf ,
  w_jest_buf          LIKE LINE OF t_jest_buf         ,
  w_status_acao_imed  LIKE LINE OF t_status_acao_imed ,
  w_rdl_especificacao LIKE LINE OF t_rdl_especificacao,
  w_rdl_resposta_rdf  LIKE LINE OF t_rdl_resposta_rdf ,
  w_rdl_sup_tecnico   LIKE LINE OF t_rdl_sup_tecnico  ,
  w_rdl_idioma_rdf    LIKE LINE OF t_rdl_idioma_rdf   ,
  w_destinatario      LIKE LINE OF t_destinatario     ,
  w_corpo_email       LIKE LINE OF t_corpo_email      ,
  w_pdf               LIKE LINE OF t_pdf              ,
  w_acao_imediata     LIKE LINE OF t_acao_imediata    .

DATA:
  w_sf_controle  TYPE ssfctrlop ,
  w_dados_modif  TYPE sodocchgi1,
  w_packing_list TYPE sopcklsti1,
  w_anexo_pdf    TYPE solisti1  ,
  w_sf_saida     TYPE ssfcrescl .

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
DATA:
  v_local_defeito    TYPE ylocal_def         ,
  v_funcao_smartform TYPE rs38l_fnam         ,
  v_nota_qm          TYPE qmel-qmnum         ,
  v_remetente        TYPE soextreci1-receiver,
  v_nome_smartform   TYPE tdsfname           ,
  v_pdf_tamanho      TYPE i                  ,
  v_qtd_defeitos     TYPE i                  ,
  v_resp_aval        TYPE c LENGTH 01        ,
  v_posicao_linha    TYPE i                  ,
  v_tamanho_linha    TYPE i                  ,
  v_qtd_linhas_pdf   TYPE i                  ,
  v_qtd_concluida    TYPE sy-tfill           ,
  v_qtd_acao_imed    TYPE sy-tfill           .

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
CONSTANTS:
  c_t_destinatario   TYPE c LENGTH 24      VALUE '(SAPLYNQM)T_DESTINATARIO',
  c_jest_buf         TYPE c LENGTH 20      VALUE '(SAPLBSVA)JEST_BUF[]'    ,
  c_especificacao    TYPE dd07l-domvalue_l VALUE 'ESPEC'                   ,
  c_resp_rdf         TYPE dd07l-domvalue_l VALUE 'RESP.RDF'                ,
  c_sup_tecnico      TYPE dd07l-domvalue_l VALUE 'SUP.TÉCNIC'              ,
  c_usuario_compras  TYPE sy-uname         VALUE 'QM_NOTAQM'               ,
  c_smartform_rdf_pt TYPE stxfadm-formname VALUE 'YQM_RDF'                 ,
  c_smartform_rdf_en TYPE stxfadm-formname VALUE 'YQM_RDF_EN'              ,
  c_parceiro_fornec  TYPE tpar-parvw       VALUE 'LF'                      ,
  c_medida_concluida TYPE tj02-istat       VALUE 'I0156'                   ,
  c_medida_aberta    TYPE tj02-istat       VALUE 'I0154'                   ,
  c_msg_em_process   TYPE tj02-istat       VALUE 'I0070'                   ,
  c_msg_encerrada    TYPE tj02-istat       VALUE 'I0072'                   ,
  c_docto_sap        TYPE tsotd-objtp      VALUE 'RAW'                     , "Documento editor SAP
  c_email            TYPE c LENGTH 01      VALUE 'U'                       ,
  c_deletado         TYPE wqmsm-aeknz      VALUE 'D'                       ,
  c_nota_qm          TYPE tq80-qmart       VALUE 'Z1'                      . " RNC - Fornecedor

*----------------------------------------------------------------------*
* Field Symbols                                                        *
*----------------------------------------------------------------------*
FIELD-SYMBOLS:
  <fs_t_destinatario> TYPE STANDARD TABLE,
  <fs_t_jest_buf>     TYPE ANY TABLE     ,
  <fs_w_destinatario> TYPE ANY           ,
  <fs_w_jest_buf>     TYPE ANY           ,
  <fs_campo>          TYPE ANY           .

*----------------------------------------------------------------------*
* Inicio                                                               *
*----------------------------------------------------------------------*
* Verifica se é uma nota de não conformidade de fornecedor
CHECK i_viqmel-qmart = c_nota_qm.

*----------------------------------------------------------------------*
* 1 - Obrigar preenchimento do código do material, lote,               *
*     conta do fornecedor, docto de compras e tp de defeito            *
* 2 - Não permitir mais de um local de defeito (T_VIQMFE)              *
*----------------------------------------------------------------------*
IF t_viqmfe[] IS INITIAL.
* Preencher o tipo de defeito na aba "Não Conformidades"!
  MESSAGE e006(ynqm).
ELSE.
* Verifica a quantidade de ítens não marcados para eliminação
  LOOP AT t_viqmfe WHERE kzloesch IS INITIAL.
    v_qtd_defeitos = v_qtd_defeitos + 1.
  ENDLOOP.

  IF v_qtd_defeitos > 1.
*   Apenas um local de defeito é permitido!
    MESSAGE e012(ynqm).
  ENDIF.
ENDIF.

READ TABLE t_viqmfe
INTO t_viqmfe
INDEX 1.

* Tipo de defeito
IF t_viqmfe-fegrp IS INITIAL
  OR t_viqmfe-fecod IS INITIAL.
* Preencha o tipo de defeito
  MESSAGE e017(ynqm).
ENDIF.

* Local de Defeito
IF t_viqmfe-otgrp IS INITIAL
  OR t_viqmfe-oteil IS INITIAL.
* Preencha o local de defeito
  MESSAGE e018(ynqm).
ENDIF.

IF i_viqmel-matnr IS INITIAL.
  MESSAGE e007(ynqm). " Preencher o código do material
ELSEIF i_viqmel-lifnum IS INITIAL.
  MESSAGE e009(ynqm). " Preencher o nº conta do fornecedor
ENDIF.

*------------------------------------------------------------------------*
* 3 - Não permitir salvar nota que não esteja com status em processamento*
*------------------------------------------------------------------------*
* Faz um ponteiro para (SAPLBSVA)JEST_BUF[] que possui os status alterados
* dos itens da aba Ações Imediatas
ASSIGN (c_jest_buf) TO <fs_t_jest_buf>.

IF <fs_t_jest_buf> IS ASSIGNED.
  LOOP AT <fs_t_jest_buf> ASSIGNING <fs_w_jest_buf>.
    MOVE-CORRESPONDING <fs_w_jest_buf> TO w_jest_buf.

    ASSIGN COMPONENT 'OBJNR'
      OF STRUCTURE <fs_w_jest_buf>
                TO <fs_campo>.

*  Copia apenas nº do objeto referente ao número da nota de QM
    IF <fs_campo> IS ASSIGNED AND <fs_campo> IS NOT INITIAL.
      APPEND w_jest_buf TO t_status_acao_imed.

      CHECK <fs_campo> = e_viqmel-objnr.
      APPEND w_jest_buf TO t_jest_buf.
    ENDIF.
  ENDLOOP.
ENDIF.

SORT: t_jest_buf, t_status_acao_imed BY objnr inact DESCENDING.
DELETE t_jest_buf WHERE inact IS NOT INITIAL.
DELETE t_status_acao_imed WHERE inact IS NOT INITIAL.

* Verifica se o status da nota está em processamento
CLEAR w_jest_buf.
READ TABLE t_jest_buf
INTO w_jest_buf
WITH KEY stat = c_msg_em_process.                           " I0070

IF sy-subrc <> 0.
* Verifica se o status da nota está em processamento
  CLEAR w_jest_buf.
  READ TABLE t_jest_buf
  INTO w_jest_buf
  WITH KEY stat = c_msg_encerrada.                          " I0072

  IF sy-subrc <> 0.
    MESSAGE e014(ynqm). " A Nota de QM deve estar com status em processamento
  ENDIF.
ENDIF.

*----------------------------------------------------------------------*
* 4 - Não permitir salvar nota com ações imediatas sem ação            *
*----------------------------------------------------------------------*
FREE t_acao_imediata.

LOOP AT t_viqmsm WHERE kzloesch IS INITIAL
                   AND aeknz <> c_deletado.

  CLEAR w_status_acao_imed.
  READ TABLE t_status_acao_imed
  INTO w_status_acao_imed
  WITH KEY objnr = t_viqmsm-objnr.

  IF sy-subrc = 0.
    CASE w_status_acao_imed-stat.
      WHEN c_medida_aberta                                  " I0154
        OR space.
        APPEND t_viqmsm TO t_acao_imediata.
    ENDCASE.
  ENDIF.
ENDLOOP.

CLEAR: v_qtd_concluida, v_qtd_acao_imed.

DESCRIBE TABLE t_acao_imediata LINES v_qtd_acao_imed.

IF v_qtd_acao_imed IS NOT INITIAL.
* Libere ou conclua a ação imediata
  MESSAGE e016(ynqm).
ENDIF.

*----------------------------------------------------------------------*
* 5 - Bloquear Ação Imediata não concluída                             *
*----------------------------------------------------------------------*
FREE t_acao_imediata.
CLEAR: v_qtd_concluida, v_qtd_acao_imed.

* Nota QM : Usuários para bloquear/concluir ação imediata
SELECT * FROM ynqm_usuario
 INTO TABLE t_usuario.

* Verifica se o usuário já concluiu a nota (QM01/QM02 : Shift + F9)
* Ação Imediata / Definição de Suprimentos
LOOP AT t_viqmsm WHERE kzloesch IS INITIAL
                   AND aeknz <> c_deletado.
  APPEND t_viqmsm TO t_acao_imediata.
ENDLOOP.

LOOP AT t_acao_imediata INTO w_acao_imediata.
  CLEAR w_usuario.
  READ TABLE t_usuario
  INTO w_usuario
  WITH KEY bname = t_viqmsm-parnr. " Responsável pela medida

  IF sy-subrc = 0.
*   Verifica se a Ação Imediata foi concluída
    CLEAR w_status_acao_imed.
    READ TABLE t_status_acao_imed
    INTO w_status_acao_imed
    WITH KEY objnr = w_acao_imediata-objnr.


    IF w_status_acao_imed-stat = c_medida_concluida.
      v_qtd_concluida = v_qtd_concluida + 1.
    ENDIF.
  ENDIF.
ENDLOOP.

DESCRIBE TABLE t_acao_imediata LINES v_qtd_acao_imed.

* Se possui apenas uma Ação Imediata como concluída, o usuário
* deve informar mais uma.
IF v_qtd_concluida = 1
  AND v_qtd_acao_imed <= v_qtd_concluida.
* Informe mais uma ação imediata para conclusão da nota
  MESSAGE e015(ynqm).
ENDIF.

*----------------------------------------------------------------------*
* 6 - Radio Buttons para avaliação da especificação, tempo de resposta *
*     da RDF, e o suporte técnico do fornecedor                        *
*----------------------------------------------------------------------*
* Verifica se o usuário já concluiu a nota (QM01/QM02 : Shift + F9)
IF i_viqmel-qmdab IS NOT INITIAL.
* Aba "Não Conformidades" com código de eliminação desabilitado
  READ TABLE t_viqmfe
  WITH KEY kzloesch = space.

* Local do Defeito
  SELECT SINGLE locdef
   FROM ynqm_local_prob
   INTO (v_local_defeito)
   WHERE codegruppe = t_viqmfe-otgrp.
ENDIF.

IF v_local_defeito IS NOT INITIAL.
* Notas de QM - Avaliação e pontuação para fornecedores
  SELECT * FROM ynqm_avaliacao
  INTO TABLE t_avaliacao
  WHERE locdef = v_local_defeito.
ENDIF.

LOOP AT t_avaliacao INTO w_avaliacao.
  CALL FUNCTION 'YNQM_CONVERT_FIRSTCHAR_TOUPPER'
    EXPORTING
      input_string  = w_avaliacao-aval
    IMPORTING
      output_string = w_avaliacao-aval.

  MODIFY t_avaliacao FROM w_avaliacao INDEX sy-tabix.

  CASE w_avaliacao-grp.
    WHEN c_especificacao. " ESPEC

      w_rdl_especificacao-selflag   = space            .
      w_rdl_especificacao-varoption = w_avaliacao-aval .
      APPEND w_rdl_especificacao TO t_rdl_especificacao.

    WHEN c_resp_rdf. " RESP.RDF
      w_rdl_resposta_rdf-selflag   = space           .
      w_rdl_resposta_rdf-varoption = w_avaliacao-aval.
      APPEND w_rdl_resposta_rdf TO t_rdl_resposta_rdf.

    WHEN c_sup_tecnico. " SUP.TÉCNIC
      w_rdl_sup_tecnico-selflag   = space           .
      w_rdl_sup_tecnico-varoption = w_avaliacao-aval.
      APPEND w_rdl_sup_tecnico TO t_rdl_sup_tecnico .

  ENDCASE.
ENDLOOP.

*----------------------------------------------------------------------*
* Especificação                                                        *
*----------------------------------------------------------------------*
IF t_rdl_especificacao IS NOT INITIAL.
  CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
    EXPORTING
      mark_flag = space
      mark_max  = 1
      start_col = 25
      start_row = 10
      textline1 = 'Especificação'
      titel     = 'Avaliação de Fornecedor'
    IMPORTING
      answer    = v_resp_aval
    TABLES
      t_spopli  = t_rdl_especificacao
    EXCEPTIONS
      OTHERS    = 4.

* Verifica qual foi a opção selecionada
  CLEAR w_rdl_especificacao.
  READ TABLE t_rdl_especificacao
  INTO w_rdl_especificacao
  WITH KEY selflag = 'X'.

  IF sy-subrc = 0.
    CLEAR w_avaliacao.
    READ TABLE t_avaliacao
    INTO w_avaliacao
    WITH KEY grp  = c_especificacao
             aval = w_rdl_especificacao-varoption.

    e_viqmel-yypto_espec  = w_avaliacao-pont. " Pontuação da Especificação
    e_viqmel-yyaval_espec = w_avaliacao-aval. " Avaliação da Especificação
  ENDIF.
ENDIF. " IF t_rdl_especificacao IS NOT INITIAL.

*----------------------------------------------------------------------*
* Resposta RDF                                                         *
*----------------------------------------------------------------------*
IF t_rdl_resposta_rdf IS NOT INITIAL.
  CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
    EXPORTING
      mark_flag = space
      mark_max  = 1
      start_col = 25
      start_row = 10
      textline1 = 'Resposta RDF'
      titel     = 'Avaliação de Fornecedor'
    IMPORTING
      answer    = v_resp_aval
    TABLES
      t_spopli  = t_rdl_resposta_rdf
    EXCEPTIONS
      OTHERS    = 4.

* Verifica qual foi a opção selecionada
  CLEAR w_rdl_resposta_rdf.
  READ TABLE t_rdl_resposta_rdf
  INTO w_rdl_resposta_rdf
  WITH KEY selflag = 'X'.

  IF sy-subrc = 0.
    CLEAR w_avaliacao.
    READ TABLE t_avaliacao
    INTO w_avaliacao
    WITH KEY grp  = c_resp_rdf
             aval = w_rdl_resposta_rdf-varoption.

    e_viqmel-yypto_rdf  = w_avaliacao-pont. " Pontuação da RDF
    e_viqmel-yyaval_rdf = w_avaliacao-aval. " Avaliação da RDF
  ENDIF.
ENDIF. " IF t_rdl_resposta_rdf IS NOT INITIAL.

*----------------------------------------------------------------------*
* Suporte Técnico                                                      *
*----------------------------------------------------------------------*
IF t_rdl_sup_tecnico IS NOT INITIAL.
  CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
    EXPORTING
      mark_flag = space
      mark_max  = 1
      start_col = 25
      start_row = 10
      textline1 = 'Suporte Técnico'
      titel     = 'Avaliação de Fornecedor'
    IMPORTING
      answer    = v_resp_aval
    TABLES
      t_spopli  = t_rdl_sup_tecnico
    EXCEPTIONS
      OTHERS    = 4.

* Verifica qual foi a opção selecionada
  CLEAR w_rdl_sup_tecnico.
  READ TABLE t_rdl_sup_tecnico
  INTO w_rdl_sup_tecnico
  WITH KEY selflag = 'X'.

  IF sy-subrc = 0.
    CLEAR w_avaliacao.
    READ TABLE t_avaliacao
    INTO w_avaliacao
    WITH KEY grp  = c_sup_tecnico
             aval = w_rdl_sup_tecnico-varoption.

    e_viqmel-yypto_suptec  = w_avaliacao-pont. " Pontuação do Suporte Técnico
    e_viqmel-yyaval_suptec = w_avaliacao-aval. " Avaliação do Suporte Técnico
  ENDIF.
ENDIF. " IF t_rdl_sup_tecnico IS NOT INITIAL.

*----------------------------------------------------------------------*
* 7 - Selecionar idioma e enviar Smartform da RDF como PDF em anexo    *
*     para os parceiros selecionados                                   *
*----------------------------------------------------------------------*
* Verifica se o usuário selecionou os parceiros através da opção
* 'Enviar Rel. Desvio Fornecedor' do menu lateral à direita
ASSIGN (c_t_destinatario) TO <fs_t_destinatario>.

CHECK <fs_t_destinatario> IS ASSIGNED
  AND <fs_t_destinatario> IS NOT INITIAL.

LOOP AT <fs_t_destinatario> ASSIGNING <fs_w_destinatario>.
  MOVE-CORRESPONDING <fs_w_destinatario> TO w_destinatario.

  ASSIGN COMPONENT 'EMAILADR'
    OF STRUCTURE <fs_w_destinatario>
              TO <fs_campo>.

* Copia apenas os parceiros com e-mail cadastrado
  IF <fs_campo> IS ASSIGNED AND <fs_campo> IS NOT INITIAL.
    w_destinatario-receiver = <fs_campo>   .
    w_destinatario-rec_type = c_email      . " U
    APPEND w_destinatario TO t_destinatario.
  ENDIF.

  ASSIGN COMPONENT 'PARVW'
       OF STRUCTURE <fs_w_destinatario>
                 TO <fs_campo>.

  IF <fs_campo> IS ASSIGNED AND <fs_campo> = c_parceiro_fornec.
    ASSIGN COMPONENT 'PARNR'
     OF STRUCTURE <fs_w_destinatario>
               TO <fs_campo>.

    w_fornecedor-parnr = <fs_campo>             .
    w_fornecedor-email = w_destinatario-receiver.
    APPEND w_fornecedor TO t_fornecedor.
  ENDIF.
ENDLOOP.

* Remove os zeros do número da nota de QM
v_nota_qm = e_viqmel-qmnum.
SHIFT v_nota_qm LEFT DELETING LEADING '0'.

FREE t_rdl_idioma_rdf.

w_rdl_idioma_rdf-selflag   = space         .
w_rdl_idioma_rdf-varoption = 'Português'   .
APPEND w_rdl_idioma_rdf TO t_rdl_idioma_rdf.

w_rdl_idioma_rdf-selflag   = space         .
w_rdl_idioma_rdf-varoption = 'Inglês'      .
APPEND w_rdl_idioma_rdf TO t_rdl_idioma_rdf.

* Monta um popup com Radio Buttons para o usuário escolher
* qual idioma de envio da RDF
CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
  EXPORTING
    mark_flag = space
    mark_max  = 1
    start_col = 25
    start_row = 10
    textline1 = 'Selecione o idioma de envio do Relatório de Desvio de Fornecedor (RDF)'
    titel     = 'Idioma RDF'
  IMPORTING
    answer    = v_resp_aval
  TABLES
    t_spopli  = t_rdl_idioma_rdf
  EXCEPTIONS
    OTHERS    = 4.

CASE v_resp_aval.
  WHEN '1'. " Português
*   Assunto do e-mail
    CONCATENATE 'Relatório - RDF'
                'Nota'
                v_nota_qm
          INTO w_dados_modif-obj_descr
          SEPARATED BY space.

    w_dados_modif-obj_name = 'TST'.

    w_corpo_email-line = 'Segue Relatório de Desvio de Fornecimento (RDF) para avaliação e ações pertinentes.'.
    APPEND w_corpo_email TO t_corpo_email.

    w_corpo_email-line = 'Caro Fornecedor, aguardamos com urgência informações sobre causas do desvio e plano de ação.'.
    APPEND w_corpo_email TO t_corpo_email.

    w_corpo_email-line = 'Att.,'.
    APPEND w_corpo_email TO t_corpo_email.

    v_nome_smartform = c_smartform_rdf_pt.
  WHEN '2'. " Inglês
*   Assunto do e-mail
    CONCATENATE 'SDR Report'
                'Note'
                v_nota_qm
          INTO w_dados_modif-obj_descr
          SEPARATED BY space.

    w_dados_modif-obj_name = 'TST'.

    w_corpo_email-line = 'Supplier Diversion Report'.
    APPEND w_corpo_email TO t_corpo_email.

    w_corpo_email-line = 'Dear supplier, we are waiting for informations about diversion causes and action plans.'.
    APPEND w_corpo_email TO t_corpo_email.

    w_corpo_email-line = 'Best Regards,'.
    APPEND w_corpo_email TO t_corpo_email.

    v_nome_smartform = c_smartform_rdf_en.
ENDCASE.

* Obter o nome da função do Smartform 'YQM_RDF'
CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    formname = v_nome_smartform
  IMPORTING
    fm_name  = v_funcao_smartform
  EXCEPTIONS
    OTHERS   = 3.

CHECK v_funcao_smartform IS NOT INITIAL.

FREE: t_nao_conform, t_causa_defeito, t_plano_acao, t_acao_imediata.

* Não Conformidades / Defeito (Desvio)
LOOP AT t_viqmfe WHERE kzloesch IS INITIAL.
  APPEND t_viqmfe TO t_nao_conform.
ENDLOOP.

* Causa do Defeito (Desvio)
LOOP AT t_viqmur WHERE kzloesch IS INITIAL.
  APPEND t_viqmur TO t_causa_defeito.
ENDLOOP.

* Plano de Ações / Ações Corretivas
LOOP AT t_viqmma WHERE kzloesch IS INITIAL.
  APPEND t_viqmma TO t_plano_acao.
ENDLOOP.

* Ação Imediata / Definição de Suprimentos
LOOP AT t_viqmsm WHERE kzloesch IS INITIAL.
  APPEND t_viqmsm TO t_acao_imediata.
ENDLOOP.

w_sf_controle-no_dialog = 'X'     .
w_sf_controle-getotf    = 'X'     .
w_sf_controle-preview   = space   .
w_sf_controle-langu     = sy-langu.

* Carrega o Smart Form YQM_RDF na w_sf_saida
CALL FUNCTION v_funcao_smartform
  EXPORTING
    i_viqmel           = i_viqmel
    control_parameters = w_sf_controle
  IMPORTING
    job_output_info    = w_sf_saida
  TABLES
    ti_iviqmfe         = t_nao_conform   " Não Conformidades / Defeito (Desvio)
    ti_iviqmur         = t_causa_defeito " Causa do Defeito (Desvio)
    ti_iviqmma         = t_plano_acao    " Plano de Ações / Ações Corretivas
    ti_iviqmsm         = t_acao_imediata " Ação Imediata / Definição de Suprimentos
  EXCEPTIONS
    OTHERS             = 5.

* Adiciona o corpo do e-mail na lista de objetos do e-mail
DESCRIBE TABLE t_corpo_email LINES w_packing_list-body_num.

w_packing_list-transf_bin = space      .
w_packing_list-head_start = 1          .
w_packing_list-head_num   = 0          .
w_packing_list-body_start = 1          .
w_packing_list-doc_type   = c_docto_sap.
APPEND w_packing_list TO t_packing_list.

t_otf[] = w_sf_saida-otfdata[].

* Converter o relatório de RDF YQM_RDF (SmartForm) para PDF
CALL FUNCTION 'CONVERT_OTF'
  EXPORTING
    format                = 'PDF'
    max_linewidth         = 132
  IMPORTING
    bin_filesize          = v_pdf_tamanho
  TABLES
    otf                   = t_otf
    lines                 = t_pdf
  EXCEPTIONS
    err_max_linewidth     = 1
    err_format            = 2
    err_conv_not_possible = 3
    err_bad_otf           = 4
    OTHERS                = 5.

* Converte o pdf para os objetos
LOOP AT t_pdf INTO w_pdf.
  v_posicao_linha = 255 - v_tamanho_linha.

  IF v_posicao_linha > 134.
    v_posicao_linha = 134.
  ENDIF.

  w_anexo_pdf+v_tamanho_linha = w_pdf(v_posicao_linha).
  v_tamanho_linha = v_tamanho_linha + v_posicao_linha.

  IF v_tamanho_linha = 255.
    APPEND w_anexo_pdf TO t_anexo_pdf.
    CLEAR: w_anexo_pdf, v_tamanho_linha.

    IF v_posicao_linha < 134.
      w_anexo_pdf = w_pdf+v_posicao_linha.
      v_tamanho_linha = 134 - v_posicao_linha.
    ENDIF.
  ENDIF.
ENDLOOP.

IF v_tamanho_linha > 0.
  APPEND w_anexo_pdf TO t_anexo_pdf.
ENDIF.

DESCRIBE TABLE t_anexo_pdf LINES v_qtd_linhas_pdf.

CLEAR w_anexo_pdf.
READ TABLE t_anexo_pdf
INTO w_anexo_pdf
INDEX v_qtd_linhas_pdf.

IF sy-subrc = 0.
  w_packing_list-doc_size   = ( v_qtd_linhas_pdf - 1 ) * 255 + STRLEN( w_anexo_pdf ).
  w_packing_list-transf_bin = 'X'             .
  w_packing_list-head_start = 1               .
  w_packing_list-head_num   = 0               .
  w_packing_list-body_start = 1               .
  w_packing_list-body_num   = v_qtd_linhas_pdf.
  w_packing_list-doc_type   = 'PDF'           .
  w_packing_list-obj_name   = 'RDF_NOTAS_QM'  .

  CONCATENATE 'RDF -'
              v_nota_qm
         INTO w_packing_list-obj_descr
         SEPARATED BY space.

  APPEND w_packing_list TO t_packing_list         .
ENDIF.

* Insere o usuário no grupo 'Sem dados Obrigatórios' da SODIS
* altera o e-mail do usuário QM_NOTAQM para o do usuário corrente
CALL FUNCTION 'YNQM_SELECT_SODIS_DETAILS'
  EXPORTING
    usuario_comp = c_usuario_compras " QM_NOTAQM
    usuario_log  = sy-uname.

v_remetente = c_usuario_compras.

* Envia o PDF em anexo do e-mail para os parceiros (fornecedores)
* selecionados
CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
  EXPORTING
    document_data              = w_dados_modif
    put_in_outbox              = space
    sender_address             = v_remetente
    commit_work                = 'X'
  TABLES
    packing_list               = t_packing_list
    contents_bin               = t_anexo_pdf
    contents_txt               = t_corpo_email
    receivers                  = t_destinatario
  EXCEPTIONS
    too_many_receivers         = 1
    document_not_sent          = 2
    document_type_not_exist    = 3
    operation_no_authorization = 4
    parameter_error            = 5
    x_error                    = 6
    enqueue_error              = 7
    OTHERS                     = 8.

IF sy-subrc = 0.
* Verificar na SOST caso demore
  SUBMIT rsconn01 WITH mode EQ 'INT'
  WITH output = 'X'
  AND RETURN.

  READ TABLE t_fornecedor
  INTO w_fornecedor
  INDEX 1.

  IF sy-subrc = 0.
    SHIFT w_fornecedor-parnr LEFT DELETING LEADING '0'.

    w_status_envio_rdf-bname = sy-uname            .
    w_status_envio_rdf-datum = sy-datum            .
    w_status_envio_rdf-uzeit = sy-uzeit            .
    w_status_envio_rdf-qmnum = v_nota_qm           .
    w_status_envio_rdf-lifnr = w_fornecedor-parnr  .
    w_status_envio_rdf-email = w_fornecedor-email  .
    APPEND w_status_envio_rdf TO t_status_envio_rdf.

    MODIFY ynqm_envio_rdf FROM TABLE t_status_envio_rdf.
  ENDIF.

* E-mail enviado com sucesso!
  MESSAGE i013(ynqm).
ENDIF.