*----------------------------------------------------------------------*
*                       ACHÉ LABORATÓRIOS                              *
*----------------------------------------------------------------------*
* Transações   : QM01 / QM02                                           *
* BAdI         : SE18 - NOTIF_EVENT_POST                               *
* Interface    : SE24 - IF_EX_NOTIF_EVENT_POST                         *
* Implementação: SE19 - Y_NOTIF_EVENT_POST                             *
* Classe       : SE24 - YCL_IM_NOTIF_EVENT_POST                        *
*----------------------------------------------------------------------*
* Objetivo : Enviar e-mail com detalhes da aba Ação Imediata que possui*
*            status Liberado/Concluído para os usuários informados no  *
*            campo Responsável dessa aba. Também enviará o "problema", *
*            campo descrição da aba "Detalhes", e a lista de defeitos  *
*            que o usuário informará na aba "Não Conformidades"        *
*            (BAdI é ativada após salvar a nota)                       *
* Módulo   : QM                                                        *
* Projeto  : Notas de QM (Não-conformidade no recebimento físico)      *
* Funcional: Meire Vicente Casale                                      *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  01.12.2013  #63782 - Desenvolvimento inicial               *
* ACTHIAGO  06.01.2014  #63782 - Ajustes finais                        *
* ACTHIAGO  23.01.2014  #63782 - Inclusão dos campos código do material*
*                                descrição, lote Aché e quantidade no  *
*                                e-mail de notificação para o usuário  *
*----------------------------------------------------------------------*

METHOD if_ex_notif_event_post~check_data_at_post.
*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
  TYPES:
    BEGIN OF ty_txt_acao               ,
     codegruppe TYPE qpct-codegruppe   , " Grupo de cod.
     code       TYPE qpct-code         , " Código
     kurztext   TYPE qpct-kurztext     , " Texto breve para o cod.
    END OF ty_txt_acao                 ,

    BEGIN OF ty_rel_acao_liberada      ,
     acao_imed  TYPE qpct-kurztext     , " Ação imediata
     peter      TYPE viqmsm-peter      , " Data fim planejada ação imediata
     fullname   TYPE bapiaddr3-fullname, " Nome completo da pessoa
     matnr      TYPE mara-matnr        , " Nº do material
     maktx      TYPE makt-maktx        , " Descrição do material
     charg      TYPE mch1-charg        , " Número do lote
     mgeig      TYPE viqmel-mgeig      , " Qtd.defeituosa interna
    END OF ty_rel_acao_liberada        ,

    BEGIN OF ty_rel_acao_concluid      ,
     acao_imed  TYPE qpct-kurztext     , " Ação imediata
     status     TYPE c LENGTH 09       , " Status do plano de ação
     erldat     TYPE viqmsm-erldat     , " Data da conclusão da medida
     fullname   TYPE bapiaddr3-fullname, " Nome completo da pessoa
     matnr      TYPE mara-matnr        , " Nº do material
     maktx      TYPE makt-maktx        , " Descrição do material
     charg      TYPE mch1-charg        , " Número do lote
     mgeig      TYPE viqmel-mgeig      , " Qtd.defeituosa interna
    END OF ty_rel_acao_concluid        ,

    BEGIN OF ty_jest                   ,
     objnr      TYPE jest-objnr        , " Nº objeto
     stat       TYPE jest-stat         , " Status individual de um objeto
     inact      TYPE jest-inact        , " Código: status inativo
    END OF ty_jest                     .

*----------------------------------------------------------------------*
* Tabelas internas                                                     *
*----------------------------------------------------------------------*
  DATA:
    t_acao_liberada     TYPE STANDARD TABLE OF wqmsm               , " Ações Imediatas Liberadas - I0155
    t_acao_concluida    TYPE STANDARD TABLE OF wqmsm               , " Ações Imediatas Concluídas - I0156
    t_txt_defeito       TYPE STANDARD TABLE OF ty_txt_acao         , " Descrição do defeito
    t_txt_acao_imed     TYPE STANDARD TABLE OF ty_txt_acao         , " Descrição da ação imediata
    t_jest_buf          TYPE STANDARD TABLE OF ty_jest             , " Status individual por ação imediata
    t_adr6              TYPE STANDARD TABLE OF adr6                , " Endereços de e-mail
    t_parceiro          TYPE STANDARD TABLE OF ihpad               , " Parceiros
    t_acao_imediata     TYPE STANDARD TABLE OF wqmsm               , " Aba Ação Imediata
    t_email             TYPE STANDARD TABLE OF somlreci1           , " Usuários que receberão o e-mail
    t_rel_acao_liberada TYPE STANDARD TABLE OF ty_rel_acao_liberada, " Dados a serem exibidos no e-mail
    t_rel_acao_concluid TYPE STANDARD TABLE OF ty_rel_acao_concluid, " Dados a serem exibidos no e-mail
    t_html              TYPE STANDARD TABLE OF soli                , " Tabela com a formatação em HTML p/enviar
    t_addsmtp           TYPE STANDARD TABLE OF bapiadsmtp          , " Estrutura BAPI p/endereços e-mail (admin.endereços central)
    t_return            TYPE STANDARD TABLE OF bapiret2            , " Parâmetro de retorno
    t_fieldcatalog      TYPE STANDARD TABLE OF lvc_s_fcat          , " Controle VLA: catálogo de campos
    t_campos_relatorio  TYPE STANDARD TABLE OF w3head              , " Catálogo de campos para exibição interna de tabelas em HTML
    t_campos            TYPE STANDARD TABLE OF w3fields            . " Catálogo de campos para exibição interna de tabelas em HTML

*----------------------------------------------------------------------*
* Work Areas                                                           *
*----------------------------------------------------------------------*
  DATA:
    w_acao_liberada     LIKE LINE OF t_acao_liberada    ,
    w_acao_concluida    LIKE LINE OF t_acao_concluida   ,
    w_txt_defeito       LIKE LINE OF t_txt_defeito      ,
    w_txt_acao_imed     LIKE LINE OF t_txt_defeito      ,
    w_jest_buf          LIKE LINE OF t_jest_buf         ,
    w_adr6              LIKE LINE OF t_adr6             ,
    w_parceiro          LIKE LINE OF t_parceiro         ,
    w_acao_imediata     LIKE LINE OF t_acao_imediata    ,
    w_email             LIKE LINE OF t_email            ,
    w_rel_acao_liberada LIKE LINE OF t_rel_acao_liberada,
    w_rel_acao_concluid LIKE LINE OF t_rel_acao_concluid,
    w_html              LIKE LINE OF t_html             ,
    w_addsmtp           LIKE LINE OF t_addsmtp          ,
    w_fieldcatalog      LIKE LINE OF t_fieldcatalog     ,
    w_address           TYPE bapiaddr3                  ,
    w_qmsm              TYPE wqmsm                      ,
    w_qmfe              TYPE wqmfe                      ,
    w_cabecalho_email   TYPE w3head                     ,
    w_cabecalho_coluna  TYPE w3head                     .

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
  DATA:
    v_qmnum                TYPE viqmel-qmnum  ,
    v_num_nota_qm          TYPE string        ,
    v_status_email         TYPE bcs_rqst      ,
    v_endereco_email       TYPE adr6-smtp_addr,
    v_indice               TYPE i             ,
    v_acao_imed_existente  TYPE i             ,
    v_tamanho_linha        TYPE i             ,
    v_inserir_indice_linha TYPE i             ,
    v_excluir_linha        TYPE i             .

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
  CONSTANTS:
    c_jest_buf         TYPE c LENGTH 20     VALUE '(SAPLBSVA)JEST_BUF[]' ,
    c_t_parceiro       TYPE c LENGTH 21     VALUE '(SAPLIQS1)IHPAD_TAB[]',
    c_email            TYPE c LENGTH 01     VALUE 'U'                    ,
    c_atribuir_usuario TYPE c LENGTH 01     VALUE 'U'                    ,
    c_visib_geral      TYPE c LENGTH 01     VALUE 'C'                    ,
    c_linha_nota_qm    TYPE i               VALUE 2                      ,
    c_linha_defeito    TYPE i               VALUE 3                      ,
    c_linha_problema   TYPE i               VALUE 4                      ,
    c_coordenador_nota TYPE tpar-parvw      VALUE 'KU'                   ,
    c_acao_incluida    TYPE wqmsm-aeknz     VALUE 'I'                    ,
    c_acao_atualizada  TYPE wqmsm-aeknz     VALUE 'U'                    ,
    c_qm01             TYPE tstc-tcode      VALUE 'QM01'                 ,
    c_qm02             TYPE tstc-tcode      VALUE 'QM02'                 ,
    c_qf01             TYPE tstc-tcode      VALUE 'QF01'                 ,
    c_iqs12            TYPE tstc-tcode      VALUE 'IQS12'                ,
    c_docto_editor     TYPE tsotd-objtp     VALUE 'RAW'                  , "Documento editor SAP.
    c_usuario_compras  TYPE usr02-bname     VALUE 'QM_NOTAQM'            , "Usuario - envio de email compras - qm
    c_prioridade_media TYPE bcs_docimp      VALUE '5'                    ,
    c_medida_liberada  TYPE tj02-istat      VALUE 'I0155'                ,
    c_medida_concluida TYPE tj02-istat      VALUE 'I0156'                ,
    c_pt_br            TYPE t002-spras      VALUE 'P'                    ,
    c_medidas          TYPE tq15-katalogart VALUE '2'                    ,
    c_tipo_defeito     TYPE tq15-katalogart VALUE '9'                    ,
    c_nota_qm          TYPE tq80-qmart      VALUE 'Z1'                   . " RNC - Fornecedor

*----------------------------------------------------------------------*
* Objetos                                                              *
*----------------------------------------------------------------------*
  DATA:
    obj_mime_helper TYPE REF TO cl_gbt_multirelated_service ,
    obj_bcs         TYPE REF TO cl_bcs                      ,
    obj_doc_bcs     TYPE REF TO cl_document_bcs             ,
    obj_recipient   TYPE REF TO if_recipient_bcs            ,
    obj_sender      TYPE REF TO if_sender_bcs               .

*----------------------------------------------------------------------*
* Field-Symbols                                                        *
*----------------------------------------------------------------------*
  FIELD-SYMBOLS:
    <fs_t_parceiro> TYPE ANY TABLE,
    <fs_t_jest_buf> TYPE ANY TABLE.

  FIELD-SYMBOLS:
    <fs_w_parceiro> TYPE ANY,
    <fs_w_jest_buf> TYPE ANY.

*----------------------------------------------------------------------*
* INICIO                                                               *
*----------------------------------------------------------------------*
* "Ações Imediatas" da QM01
  CHECK it_new_iviqmsm IS NOT INITIAL.

* Nº da nota de QM
  v_num_nota_qm = is_new_viqmel-qmnum.
  SHIFT v_num_nota_qm LEFT DELETING LEADING '0'.

* Faz um ponteiro para (SAPLBSVA)JEST_BUF[] que possui os status alterados
* dos itens da aba Ações Imediatas
  ASSIGN (c_jest_buf) TO <fs_t_jest_buf>.

  IF <fs_t_jest_buf> IS ASSIGNED.
    LOOP AT <fs_t_jest_buf> ASSIGNING <fs_w_jest_buf>.
      MOVE-CORRESPONDING <fs_w_jest_buf> TO w_jest_buf.
      APPEND w_jest_buf TO t_jest_buf.
    ENDLOOP.
  ENDIF.

  SORT t_jest_buf BY objnr inact DESCENDING.
  DELETE t_jest_buf WHERE inact IS NOT INITIAL.

  ASSIGN (c_t_parceiro) TO <fs_t_parceiro>.

  IF <fs_t_parceiro> IS ASSIGNED.
    LOOP AT <fs_t_parceiro> ASSIGNING <fs_w_parceiro>.
      MOVE-CORRESPONDING <fs_w_parceiro> TO w_parceiro.
      APPEND w_parceiro TO t_parceiro.
    ENDLOOP.
  ENDIF.

  DELETE t_parceiro WHERE parvw <> c_coordenador_nota.

  CASE sy-tcode.
    WHEN c_qm01 " Criar nota de QM
      OR c_qf01.
*     Tabela da aba "Ações Imediatas" da QM01
      LOOP AT it_new_iviqmsm INTO w_qmsm WHERE kzloesch IS INITIAL.
        CLEAR: w_jest_buf.
        READ TABLE t_jest_buf
        INTO w_jest_buf
        WITH KEY objnr = w_qmsm-objnr.

        IF sy-subrc = 0.
          CASE w_jest_buf-stat.
            WHEN c_medida_liberada.                         " I0155
              APPEND w_qmsm TO t_acao_liberada.
            WHEN c_medida_concluida.                        " I0156
              APPEND w_qmsm TO t_acao_concluida.
          ENDCASE.
        ENDIF.
      ENDLOOP.

    WHEN c_qm02 OR c_iqs12. " Alterar nota de QM
*     Tabela da aba "Ações Imediatas" da QM01
      LOOP AT it_new_iviqmsm INTO w_qmsm WHERE kzloesch IS INITIAL.

*       Verifica se houve inserção/atualização de Ações Imediatas
        IF w_qmsm-aeknz = c_acao_incluida OR
           w_qmsm-aeknz = c_acao_atualizada.
          APPEND w_qmsm TO t_acao_imediata.
        ENDIF.
      ENDLOOP.

*     Tabela com dados das ações imediatas com status alterados
*     ou que foram inseridas na QM02
      LOOP AT t_acao_imediata INTO w_acao_imediata.
        CLEAR w_jest_buf.
        READ TABLE t_jest_buf
        INTO w_jest_buf
        WITH KEY objnr = w_acao_imediata-objnr.

        IF sy-subrc = 0.
          CASE w_jest_buf-stat.
            WHEN c_medida_liberada.                         " I0155
              APPEND w_acao_imediata TO t_acao_liberada.
            WHEN c_medida_concluida.                        " I0156
              APPEND w_acao_imediata TO t_acao_concluida.
          ENDCASE.
        ENDIF.
      ENDLOOP.
  ENDCASE.

* Se não houver nenhuma alteração, sai do método.
  IF t_acao_liberada IS INITIAL
     AND t_acao_concluida IS INITIAL.
    EXIT.
  ENDIF.

* Insere o usuário no grupo 'Sem dados Obrigatórios' da SODIS
* altera o e-mail do usuário QM_NOTAQM para o do usuário corrente
  CALL FUNCTION 'YNQM_SELECT_SODIS_DETAILS'
    EXPORTING
      usuario_comp = c_usuario_compras " QM_NOTAQM
      usuario_log  = sy-uname.

  FREE: t_email, t_txt_acao_imed, t_txt_defeito, t_rel_acao_liberada.

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* Ação Imediata liberada (status I0155)
*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  LOOP AT t_acao_liberada INTO w_acao_liberada.

*   Verifica se o tipo de catálogo é de medida
*   e se grupo de medidas é uma nota de fornecedor
    CHECK w_acao_liberada-mnkat    = c_medidas  " 2
      AND w_acao_liberada-mngrp(2) = c_nota_qm. " Z1

*   Obtem detalhes dos usuário que receberão o e-mail
    IF w_acao_liberada-parnr IS NOT INITIAL.
      CLEAR: t_return, t_addsmtp, w_address.
      REFRESH: t_return, t_addsmtp.

      CALL FUNCTION 'BAPI_USER_GET_DETAIL'
        EXPORTING
          username = w_acao_liberada-parnr "Responsável pela medida (nº parceiro)
        IMPORTING
          address  = w_address
        TABLES
          return   = t_return
          addsmtp  = t_addsmtp.

      LOOP AT t_addsmtp INTO w_addsmtp.
        w_email-receiver = w_addsmtp-e_mail .
        w_email-rec_type = c_email          . " Endereço Internet
        w_email-rec_id   = c_medida_liberada.               " I0155
        APPEND w_email TO t_email           .
      ENDLOOP.
    ENDIF.

    CHECK t_email IS NOT INITIAL.

    CLEAR w_rel_acao_liberada.

*----------------------------------------------------------------------
*   Item da nota com defeito
*----------------------------------------------------------------------
    LOOP AT it_new_iviqmfe INTO w_qmfe WHERE kzloesch IS INITIAL.
      SELECT codegruppe code kurztext
       FROM qpct
       APPENDING TABLE t_txt_defeito
        WHERE codegruppe = w_qmfe-fegrp
          AND code       = w_qmfe-fecod
          AND sprache    = c_pt_br
          AND katalogart = c_tipo_defeito.
    ENDLOOP.

*----------------------------------------------------------------------
*   Item da nota (Ação Imediata)
*----------------------------------------------------------------------
    SELECT codegruppe code kurztext
     FROM qpct
     APPENDING TABLE t_txt_acao_imed
      WHERE codegruppe = w_acao_liberada-mngrp
        AND code       = w_acao_liberada-mncod
        AND sprache    = c_pt_br.

    CLEAR w_txt_acao_imed.

    READ TABLE t_txt_acao_imed
    INTO w_txt_acao_imed
    WITH KEY codegruppe = w_acao_liberada-mngrp
             code       = w_acao_liberada-mncod.

    IF sy-subrc = 0.
      CALL FUNCTION 'YNQM_CONVERT_FIRSTCHAR_TOUPPER'
        EXPORTING
          input_string  = w_txt_acao_imed-kurztext
        IMPORTING
          output_string = w_rel_acao_liberada-acao_imed.
    ELSE.
      CLEAR w_rel_acao_liberada-acao_imed.
    ENDIF.

    w_rel_acao_liberada-peter = w_acao_liberada-peter. " Data fim planejada ação imediata

    CALL FUNCTION 'YNQM_CONVERT_FIRSTCHAR_TOUPPER'
      EXPORTING
        input_string  = w_address-fullname
      IMPORTING
        output_string = w_rel_acao_liberada-fullname.

*----------------------------------------------------------------------
*   Material e descrição
*----------------------------------------------------------------------
    w_rel_acao_liberada-matnr = is_new_viqmel-matnr.
    SHIFT w_rel_acao_liberada-matnr LEFT DELETING LEADING '0'.

    SELECT SINGLE maktx
     FROM makt
     INTO (w_rel_acao_liberada-maktx)
     WHERE matnr = is_new_viqmel-matnr
       AND spras = c_pt_br.

    CALL FUNCTION 'YNQM_CONVERT_FIRSTCHAR_TOUPPER'
      EXPORTING
        input_string  = w_rel_acao_liberada-maktx
      IMPORTING
        output_string = w_rel_acao_liberada-maktx.

*----------------------------------------------------------------------
*   Lote
*----------------------------------------------------------------------
    w_rel_acao_liberada-charg = is_new_viqmel-charg.

*----------------------------------------------------------------------
*   Qtd.defeituosa interna
*----------------------------------------------------------------------
    w_rel_acao_liberada-mgeig = is_new_viqmel-mgeig.

    APPEND w_rel_acao_liberada TO t_rel_acao_liberada   .
  ENDLOOP. " LOOP AT t_acao_liberada.

*---------------------------------------------------------------------*
* Ação Imediata liberada (status I0155)
* Converter para HTML e enviar e-mail
*---------------------------------------------------------------------*
  IF t_rel_acao_liberada IS NOT INITIAL.
    READ TABLE t_email
    TRANSPORTING NO FIELDS
    WITH KEY rec_id = c_medida_liberada.                    " I0155

    CHECK sy-subrc = 0.

    CLEAR: w_fieldcatalog, w_cabecalho_email.
    FREE: t_fieldcatalog, t_campos_relatorio, t_campos, t_html.

    w_cabecalho_email-text = 'Segue Não Conformidade (NC) para avaliação e ações pertinentes'.
    w_cabecalho_email-font = 'Arial'.
    w_cabecalho_email-size = '3'    .

    w_fieldcatalog-coltext = 'Ação Imediata'.
    APPEND w_fieldcatalog TO t_fieldcatalog.
    w_fieldcatalog-coltext = 'Data fim planejada ação imediata'.
    APPEND w_fieldcatalog TO t_fieldcatalog.
    w_fieldcatalog-coltext = 'Responsável'.
    APPEND w_fieldcatalog TO t_fieldcatalog.
    w_fieldcatalog-coltext = 'Material'.
    APPEND w_fieldcatalog TO t_fieldcatalog.
    w_fieldcatalog-coltext = 'Descrição'.
    APPEND w_fieldcatalog TO t_fieldcatalog.
    w_fieldcatalog-coltext = 'Lote'.
    APPEND w_fieldcatalog TO t_fieldcatalog.
    w_fieldcatalog-coltext = 'Qtd.Defeituosa'.
    APPEND w_fieldcatalog TO t_fieldcatalog.

    LOOP AT t_fieldcatalog INTO w_fieldcatalog.
      w_cabecalho_coluna-text = w_fieldcatalog-coltext.

      CALL FUNCTION 'WWW_ITAB_TO_HTML_HEADERS'
        EXPORTING
          field_nr = sy-tabix
          text     = w_cabecalho_coluna-text
          fgcolor  = 'black'
          bgcolor  = 'yellow'
        TABLES
          header   = t_campos_relatorio.

      CALL FUNCTION 'WWW_ITAB_TO_HTML_LAYOUT'
        EXPORTING
          field_nr = sy-tabix
          fgcolor  = 'black'
          size     = '3'
        TABLES
          fields   = t_campos.
    ENDLOOP.

    CALL FUNCTION 'WWW_ITAB_TO_HTML'
      EXPORTING
        table_header = w_cabecalho_email
      TABLES
        html         = t_html
        fields       = t_campos
        row_header   = t_campos_relatorio
        itable       = t_rel_acao_liberada.

    CONCATENATE '<font face=Arial size=4><h4>'
                'Nota de QM:' v_num_nota_qm
                '</h4></font>'
           INTO w_html SEPARATED BY space.

    INSERT w_html INTO t_html INDEX c_linha_nota_qm. " 2

    CLEAR v_inserir_indice_linha.

*   Insere o defeito em uma linha separada
    LOOP AT it_new_iviqmfe INTO w_qmfe WHERE kzloesch IS INITIAL.
      v_inserir_indice_linha = sy-tabix.

      CLEAR w_txt_defeito.
      READ TABLE t_txt_defeito
      INTO w_txt_defeito
      WITH KEY codegruppe = w_qmfe-fegrp
               code       = w_qmfe-fecod.

      IF sy-subrc = 0.
        CALL FUNCTION 'YNQM_CONVERT_FIRSTCHAR_TOUPPER'
          EXPORTING
            input_string  = w_txt_defeito-kurztext
          IMPORTING
            output_string = w_txt_defeito-kurztext.

        IF v_inserir_indice_linha = 1.
          CONCATENATE '<font face=Arial size=4><h4>'
                      'Defeito:' w_txt_defeito-kurztext
                      '</h4></font>'
                 INTO w_html SEPARATED BY space.

          v_inserir_indice_linha = c_linha_defeito. " 3
        ELSE.
          CONCATENATE '<font face=Arial size=4><h4>'
                      w_txt_defeito-kurztext
                      '</h4></font>'
                 INTO w_html SEPARATED BY space.
          v_inserir_indice_linha = v_inserir_indice_linha + 1.
        ENDIF.

        INSERT w_html INTO t_html INDEX v_inserir_indice_linha.
      ENDIF.
    ENDLOOP.

*   Insere a descrição do problema
    IF is_new_viqmel-qmtxt IS NOT INITIAL.
      CONCATENATE '<font face=Arial size=4><h4>'
                  'Problema:' is_new_viqmel-qmtxt
                  '</h4></font>'
             INTO w_html SEPARATED BY space.

      IF v_inserir_indice_linha IS INITIAL.
        v_inserir_indice_linha = c_linha_problema. " 4
      ELSE.
        v_inserir_indice_linha = v_inserir_indice_linha + 1.
      ENDIF.

      INSERT w_html INTO t_html INDEX v_inserir_indice_linha.
    ENDIF.

    CREATE OBJECT obj_mime_helper.

*   Especifica o html no corpo do e-mail
    CALL METHOD obj_mime_helper->set_main_html
      EXPORTING
        content     = t_html
        filename    = ''
        description = 'SAP Notas de QM'.

*   Assunto do e-mail
    TRY.
        obj_doc_bcs = cl_document_bcs=>create_from_multirelated(
                        i_subject          = 'SAP Notas de QM'
                        i_importance       = c_prioridade_media
                        i_multirel_service = obj_mime_helper ).
      CATCH cx_document_bcs.
      CATCH cx_bcom_mime.
      CATCH cx_gbt_mime.
    ENDTRY.

    TRY.
        obj_bcs = cl_bcs=>create_persistent( ).
      CATCH cx_send_req_bcs.
    ENDTRY.

    TRY.
        obj_bcs->set_document( i_document = obj_doc_bcs ).
      CATCH cx_send_req_bcs.
    ENDTRY.

    DELETE ADJACENT DUPLICATES FROM t_email COMPARING receiver.

*   Define que o usuário que enviará o e-mail será o QM_NOTAQM
    TRY.
        obj_sender = cl_sapuser_bcs=>create( c_usuario_compras ).
      CATCH cx_address_bcs.
    ENDTRY.

    TRY.
        obj_bcs->set_sender( i_sender = obj_sender ).
      CATCH cx_send_req_bcs.
    ENDTRY.

    LOOP AT t_email INTO w_email.
      v_endereco_email = w_email-receiver.

      TRY .
          obj_recipient = cl_cam_address_bcs=>create_internet_address(
                          i_address_string = v_endereco_email ).
        CATCH cx_address_bcs.
      ENDTRY.

      TRY .
          obj_bcs->add_recipient( i_recipient = obj_recipient ).
        CATCH cx_send_req_bcs.
      ENDTRY.

    ENDLOOP.

    v_status_email = 'N'. " Nenhum status deve ser confirmado

    TRY.
        CALL METHOD obj_bcs->set_status_attributes
          EXPORTING
            i_requested_status = v_status_email.
      CATCH cx_send_req_bcs.
    ENDTRY.

*   Envia o e-mail
    TRY.
        obj_bcs->set_send_immediately( 'X' ).
        obj_bcs->send( ).
      CATCH cx_send_req_bcs .
    ENDTRY.

  ENDIF. " IF t_rel_acao_liberada IS NOT INITIAL.

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* Ação Imediata concluída (status I0156)
*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  FREE: t_email, t_txt_acao_imed, t_txt_defeito, t_rel_acao_concluid.

  LOOP AT t_acao_concluida INTO w_acao_concluida.
*   Verifica se o tipo de catálogo é de medida
*   e se grupo de medidas é uma nota de fornecedor
    CHECK w_acao_concluida-mnkat    = c_medidas  " 2
      AND w_acao_concluida-mngrp(2) = c_nota_qm. " Z1

    CLEAR w_parceiro.
    READ TABLE t_parceiro
    INTO w_parceiro
    INDEX 1.

*  Obtém e-mail do parceiro cadastrado como Coordenador da Nota
    IF w_parceiro-parnr IS NOT INITIAL.
      CLEAR: t_return, t_addsmtp, w_address.
      REFRESH: t_return, t_addsmtp.

      CALL FUNCTION 'BAPI_USER_GET_DETAIL'
        EXPORTING
          username = w_parceiro-parnr "Responsável pela medida (nº parceiro)
        IMPORTING
          address  = w_address
        TABLES
          return   = t_return
          addsmtp  = t_addsmtp.

      LOOP AT t_addsmtp INTO w_addsmtp.
        w_email-receiver = w_addsmtp-e_mail  . " E-mail
        w_email-rec_type = c_email           . " Endereço Internet
        w_email-rec_id   = c_medida_concluida.              " I0156
        APPEND w_email TO t_email            .
      ENDLOOP.
    ENDIF.

    CHECK t_email IS NOT INITIAL.

    CLEAR w_rel_acao_concluid.
*----------------------------------------------------------------------
*   Item da nota com defeito
*----------------------------------------------------------------------
    LOOP AT it_new_iviqmfe INTO w_qmfe WHERE kzloesch IS INITIAL.
      SELECT codegruppe code kurztext
       FROM qpct
       APPENDING TABLE t_txt_defeito
        WHERE codegruppe = w_qmfe-fegrp
          AND code       = w_qmfe-fecod
          AND sprache    = c_pt_br
          AND katalogart = c_tipo_defeito.
    ENDLOOP.

*----------------------------------------------------------------------
*   Item da nota (Ação Imediata)
*----------------------------------------------------------------------
    SELECT codegruppe code kurztext
     FROM qpct
     APPENDING TABLE t_txt_acao_imed
      WHERE codegruppe = w_acao_concluida-mngrp
        AND code       = w_acao_concluida-mncod
        AND sprache    = c_pt_br.

    CLEAR w_txt_acao_imed.
    READ TABLE t_txt_acao_imed
    INTO w_txt_acao_imed
    WITH KEY codegruppe = w_acao_concluida-mngrp
             code       = w_acao_concluida-mncod.

    IF sy-subrc = 0.
      CALL FUNCTION 'YNQM_CONVERT_FIRSTCHAR_TOUPPER'
        EXPORTING
          input_string  = w_txt_acao_imed-kurztext
        IMPORTING
          output_string = w_rel_acao_concluid-acao_imed.
    ELSE.
      CLEAR w_rel_acao_concluid-acao_imed.
    ENDIF.

    w_rel_acao_concluid-status = 'Concluído'.
    w_rel_acao_concluid-erldat = w_acao_concluida-erldat.

    CALL FUNCTION 'YNQM_CONVERT_FIRSTCHAR_TOUPPER'
      EXPORTING
        input_string  = w_address-fullname
      IMPORTING
        output_string = w_rel_acao_concluid-fullname.

*----------------------------------------------------------------------
*   Material e descrição
*----------------------------------------------------------------------
    w_rel_acao_concluid-matnr = is_new_viqmel-matnr.
    SHIFT w_rel_acao_concluid-matnr LEFT DELETING LEADING '0'.

    SELECT SINGLE maktx
     FROM makt
     INTO (w_rel_acao_concluid-maktx)
     WHERE matnr = is_new_viqmel-matnr
       AND spras = c_pt_br.

    CALL FUNCTION 'YNQM_CONVERT_FIRSTCHAR_TOUPPER'
      EXPORTING
        input_string  = w_rel_acao_concluid-maktx
      IMPORTING
        output_string = w_rel_acao_concluid-maktx.

*----------------------------------------------------------------------
*   Lote
*----------------------------------------------------------------------
    w_rel_acao_concluid-charg = is_new_viqmel-charg.

*----------------------------------------------------------------------
*   Qtd.defeituosa interna
*----------------------------------------------------------------------
    w_rel_acao_concluid-mgeig = is_new_viqmel-mgeig.

    APPEND w_rel_acao_concluid TO t_rel_acao_concluid.
  ENDLOOP. " LOOP AT t_acao_concluida INTO w_acao_concluida.

*---------------------------------------------------------------------*
* Ação Imediata concluída (status I0156)
* Converter para HTML e enviar e-mail
*---------------------------------------------------------------------*
  IF t_rel_acao_concluid IS NOT INITIAL.
    READ TABLE t_email
    TRANSPORTING NO FIELDS
    WITH KEY rec_id = c_medida_concluida.                   " I0156

    CHECK sy-subrc = 0.

    CLEAR: w_fieldcatalog,w_cabecalho_email.
    FREE: t_fieldcatalog, t_campos_relatorio, t_campos, t_html.

    w_cabecalho_email-text = '&'    .
    w_cabecalho_email-font = 'Arial'.
    w_cabecalho_email-size = '3'    .

    w_fieldcatalog-coltext = 'Ação Imediata'.
    APPEND w_fieldcatalog TO t_fieldcatalog.
    w_fieldcatalog-coltext = 'Status plano de ação'.
    APPEND w_fieldcatalog TO t_fieldcatalog.
    w_fieldcatalog-coltext = 'Data conclusão'.
    APPEND w_fieldcatalog TO t_fieldcatalog.
    w_fieldcatalog-coltext = 'Responsável'.
    APPEND w_fieldcatalog TO t_fieldcatalog.
    w_fieldcatalog-coltext = 'Material'.
    APPEND w_fieldcatalog TO t_fieldcatalog.
    w_fieldcatalog-coltext = 'Descrição'.
    APPEND w_fieldcatalog TO t_fieldcatalog.
    w_fieldcatalog-coltext = 'Lote'.
    APPEND w_fieldcatalog TO t_fieldcatalog.
    w_fieldcatalog-coltext = 'Qtd.Defeituosa'.
    APPEND w_fieldcatalog TO t_fieldcatalog.

    LOOP AT t_fieldcatalog INTO w_fieldcatalog.
      w_cabecalho_coluna-text = w_fieldcatalog-coltext.

      CALL FUNCTION 'WWW_ITAB_TO_HTML_HEADERS'
        EXPORTING
          field_nr = sy-tabix
          text     = w_cabecalho_coluna-text
          fgcolor  = 'black'
          bgcolor  = 'yellow'
        TABLES
          header   = t_campos_relatorio.

      CALL FUNCTION 'WWW_ITAB_TO_HTML_LAYOUT'
        EXPORTING
          field_nr = sy-tabix
          fgcolor  = 'black'
          size     = '3'
        TABLES
          fields   = t_campos.
    ENDLOOP.

    CALL FUNCTION 'WWW_ITAB_TO_HTML'
      EXPORTING
        table_header = w_cabecalho_email
      TABLES
        html         = t_html
        fields       = t_campos
        row_header   = t_campos_relatorio
        itable       = t_rel_acao_concluid.

*   Após usar a função na 2ª vez, estava sendo gerada "sujeira" dentro do html
*   o tratamento abaixo serve para que esse erro não aconteça
    LOOP AT t_html INTO w_html.
      IF w_html CA '<font face=Arial size=3 ><h3>&</h3></font>'.
        REPLACE '<font face=Arial size=3 ><h3>&</h3></font>' WITH space INTO w_html.
        MODIFY t_html FROM w_html INDEX sy-tabix.

        w_html = '<font face=Arial size=3 ><h3>Segue Não Conformidade (NC) definido com as ações pertinentes</h3></font>'.
        INSERT w_html INTO t_html INDEX 1.
        EXIT.
      ENDIF.
    ENDLOOP.

    CONCATENATE '<font face=Arial size=4><h4>'
                'Nota de QM:' v_num_nota_qm
                '</h4></font>'
           INTO w_html SEPARATED BY space.

    INSERT w_html INTO t_html INDEX c_linha_nota_qm. " 2

*   Insere o defeito em uma linha separada
    LOOP AT it_new_iviqmfe INTO w_qmfe WHERE kzloesch IS INITIAL.
      v_inserir_indice_linha = sy-tabix.

      CLEAR w_txt_defeito.
      READ TABLE t_txt_defeito
      INTO w_txt_defeito
      WITH KEY codegruppe = w_qmfe-fegrp
               code       = w_qmfe-fecod.

      IF sy-subrc = 0.
        CALL FUNCTION 'YNQM_CONVERT_FIRSTCHAR_TOUPPER'
          EXPORTING
            input_string  = w_txt_defeito-kurztext
          IMPORTING
            output_string = w_txt_defeito-kurztext.

        IF v_inserir_indice_linha = 1.
          CONCATENATE '<font face=Arial size=4><h4>'
                      'Defeito:' w_txt_defeito-kurztext
                      '</h4></font>'
                 INTO w_html SEPARATED BY space.

          v_inserir_indice_linha = c_linha_defeito. " 3
        ELSE.
          CONCATENATE '<font face=Arial size=4><h4>'
                      w_txt_defeito-kurztext
                      '</h4></font>'
                 INTO w_html SEPARATED BY space.
          v_inserir_indice_linha = v_inserir_indice_linha + 1.
        ENDIF.

        INSERT w_html INTO t_html INDEX v_inserir_indice_linha.
      ENDIF.
    ENDLOOP.

    IF is_new_viqmel-qmtxt IS NOT INITIAL.
      CONCATENATE '<font face=Arial size=4><h4>'
            'Problema:' is_new_viqmel-qmtxt
            '</h4></font>'
       INTO w_html SEPARATED BY space.

      IF v_inserir_indice_linha IS INITIAL.
        v_inserir_indice_linha = c_linha_problema. " 4
      ELSE.
        v_inserir_indice_linha = v_inserir_indice_linha + 1.
      ENDIF.

      INSERT w_html INTO t_html INDEX v_inserir_indice_linha.
    ENDIF.

    CREATE OBJECT obj_mime_helper.

*   Especifica o html no corpo do e-mail
    CALL METHOD obj_mime_helper->set_main_html
      EXPORTING
        content     = t_html
        filename    = ''
        description = 'SAP Notas de QM'.

*   Assunto do e-mail
    TRY.
        obj_doc_bcs = cl_document_bcs=>create_from_multirelated(
                        i_subject          = 'SAP Notas de QM'
                        i_importance       = c_prioridade_media
                        i_multirel_service = obj_mime_helper ).
      CATCH cx_document_bcs.
      CATCH cx_bcom_mime.
      CATCH cx_gbt_mime.
    ENDTRY.

    TRY.
        obj_bcs = cl_bcs=>create_persistent( ).
        obj_bcs->set_document( i_document = obj_doc_bcs ).
      CATCH cx_send_req_bcs.
    ENDTRY.

    DELETE ADJACENT DUPLICATES FROM t_email COMPARING receiver.

*   Define que o usuário que enviará o e-mail será o QM_NOTAQM
    TRY.
        obj_sender = cl_sapuser_bcs=>create( c_usuario_compras ).
      CATCH cx_address_bcs.
    ENDTRY.

    TRY.
        obj_bcs->set_sender( i_sender = obj_sender ).
      CATCH cx_send_req_bcs.
    ENDTRY.

    LOOP AT t_email INTO w_email.
      v_endereco_email = w_email-receiver.

      TRY.
          obj_recipient = cl_cam_address_bcs=>create_internet_address(
                          i_address_string = v_endereco_email ).
        CATCH cx_address_bcs.
      ENDTRY.

      TRY.
          obj_bcs->add_recipient( i_recipient = obj_recipient ).
        CATCH cx_send_req_bcs .
      ENDTRY.

    ENDLOOP.

    v_status_email = 'N'. " Nenhum status deve ser confirmado

    TRY.
        CALL METHOD obj_bcs->set_status_attributes
          EXPORTING
            i_requested_status = v_status_email.
      CATCH cx_send_req_bcs.
    ENDTRY.

*   Envia o e-mail
    TRY.
        obj_bcs->set_send_immediately( 'X' ).
        obj_bcs->send( ).
      CATCH cx_send_req_bcs .
    ENDTRY.

  ENDIF. " IF t_rel_acao_liberada IS NOT INITIAL.
ENDMETHOD.