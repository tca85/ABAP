*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                   *
*----------------------------------------------------------------------*
* Classe   : YCL_POLITICA_COMERCIAL                                    *
* Método   : SET_POLITICA_COMERCIAL                                    *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Criar/altera a condição da política comercial na VK11     *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.06.2015  #97992  - Desenvolvimento inicial              *
* ACTHIAGO  08.07.2015  #108139 - Modificação para tratar o erro de    *
*                                 sobreposição de datas.               *
*                                 Antigo: BAPI_PRICES_CONDITIONS       *
*                                 Novo  : RV_CONDITION_COPY            *
*----------------------------------------------------------------------*

METHOD set_politica_comercial.
*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_detalhe_condicao TYPE STANDARD TABLE OF komv      ,
    t_dados_adicionais TYPE STANDARD TABLE OF komv_idoc ,
    t_knumh            TYPE STANDARD TABLE OF knumh_comp,
    t_bapiret2         TYPE STANDARD TABLE OF bapiret2  .

*----------------------------------------------------------------------*
* Work Areas
*----------------------------------------------------------------------*
  DATA:
    w_detalhe_condicao    LIKE LINE OF t_detalhe_condicao,
    w_dados_adicionais    LIKE LINE OF t_dados_adicionais,
    w_knumh               LIKE LINE OF t_knumh           ,
    w_bapiret2            LIKE LINE OF t_bapiret2        ,
    w_condicao            TYPE komg                      ,
    w_det_preco_cabecalho TYPE komk                      ,
    w_det_preco_item      TYPE komp                      .

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
  CONSTANTS:
    c_percentual      TYPE krech       VALUE 'A',
    c_a_partir_escala TYPE stfkz       VALUE 'A',
    c_modo_alteracao  TYPE c LENGTH 01 VALUE 'B'.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  CALL FUNCTION 'SD_CONDITION_KOMG_FILL'
    EXPORTING
      p_kotabnr = im_tab_condicao
      p_kvewe   = me->c_determinacao_preco
      p_vakey   = im_varkey
    IMPORTING
      p_komg    = w_condicao.

  IF w_condicao IS NOT INITIAL.
    MOVE-CORRESPONDING w_condicao TO w_det_preco_cabecalho.
    w_det_preco_cabecalho-mandt = sy-mandt .

    MOVE-CORRESPONDING w_condicao TO w_det_preco_item.
    w_det_preco_item-kposn = '000001'    . " Nº item ao qual se aplicam as condições
    w_det_preco_item-zterm = im_cond_pgto. " Condição de pagamento
  ENDIF.

  CLEAR w_detalhe_condicao                       .
  w_detalhe_condicao-mandt = sy-mandt            . " Mandante
  w_detalhe_condicao-kappl = me->c_aplicacao_sd  . " Aplicação
  w_detalhe_condicao-kschl = me->c_desc_comercial. " Tipo de condição
  w_detalhe_condicao-kbetr = im_montante * 10    . " Montante ou porcentagem da condição
  w_detalhe_condicao-krech = c_percentual        . " Regra de cálculo de condição
  w_detalhe_condicao-waers = me->c_br_real       . " Código da moeda
  w_detalhe_condicao-knumh = '$000000001'        . " Nº registro de condição
  w_detalhe_condicao-kopos = im_indice_item      . " Nº seqüencial da condição
  w_detalhe_condicao-stfkz = c_a_partir_escala   . " Tipo de escala
  APPEND w_detalhe_condicao TO t_detalhe_condicao. " Registro de condição de comunicação p/determinação de preço

  CLEAR w_dados_adicionais                       .
  w_dados_adicionais-zterm = im_cond_pgto        . " Condição de pagamento
  APPEND w_dados_adicionais TO t_dados_adicionais.

  CALL FUNCTION 'RV_CONDITION_COPY'
    EXPORTING
      application              = me->c_aplicacao_sd
      condition_table          = im_tab_condicao
      condition_type           = me->c_desc_comercial
      date_from                = im_data_inicial
      date_to                  = im_data_final
      enqueue                  = abap_true
      i_komk                   = w_det_preco_cabecalho
      i_komp                   = w_det_preco_item
      key_fields               = w_condicao
      maintain_mode            = c_modo_alteracao
      no_authority_check       = abap_true
      no_field_check           = abap_true
      keep_old_records         = abap_true
      used_by_idoc             = abap_true
      overlap_confirmed        = abap_true
    TABLES
      copy_records             = t_detalhe_condicao
      copy_recs_idoc           = t_dados_adicionais
    EXCEPTIONS
      enqueue_on_record        = 01
      invalid_application      = 02
      invalid_condition_number = 03
      invalid_condition_type   = 04
      no_authority_ekorg       = 05
      no_authority_kschl       = 06
      no_authority_vkorg       = 07
      no_selection             = 08
      table_not_valid          = 09.

  IF sy-subrc = 0.
    CALL FUNCTION 'RV_CONDITION_SAVE'
      TABLES
        knumh_map = t_knumh.

    CALL FUNCTION 'RV_CONDITION_RESET'.

    COMMIT WORK AND WAIT.

    LOOP AT t_knumh INTO w_knumh.
      w_bapiret2-type       = 'S'              .
      w_bapiret2-message_v1 = w_knumh-knumh_new.
      APPEND w_bapiret2 TO t_bapiret2          .
    ENDLOOP.
  ELSE.
    w_bapiret2-type    = 'E'                                           .
    w_bapiret2-message = 'Erro durante a criação da política comercial'.
    APPEND w_bapiret2 TO t_bapiret2.
  ENDIF.

  me->set_msg_retorno( im_id_modificacao = im_id_modificacao
                       im_t_retorno_bapi = t_bapiret2 ).

ENDMETHOD.