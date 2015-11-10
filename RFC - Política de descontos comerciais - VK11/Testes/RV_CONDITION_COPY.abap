REPORT zbapi_prices_conditions NO STANDARD PAGE HEADING.

TYPE-POOLS: abap.

DATA: t_copy_records    TYPE STANDARD TABLE OF komv      ,
      t_knumh           TYPE STANDARD TABLE OF knumh_comp.

DATA: w_copy_records        LIKE LINE OF t_copy_records   ,
      w_knumh               LIKE LINE OF t_knumh          ,
      w_condicao            TYPE komg                     ,
      w_det_preco_cabecalho TYPE komk                     ,
      w_det_preco_item      TYPE komp                     .

START-OF-SELECTION.

  CALL FUNCTION 'SD_CONDITION_KOMG_FILL'
    EXPORTING
      p_kotabnr = '972'
      p_kvewe   = 'A'
      p_vakey   = '1100SP 000000000001000101'
    IMPORTING
      p_komg    = w_condicao.

  IF w_condicao IS NOT INITIAL.
    MOVE-CORRESPONDING w_condicao TO w_det_preco_cabecalho.
    w_det_preco_cabecalho-mandt = sy-mandt.

    MOVE-CORRESPONDING w_condicao TO w_det_preco_item.
    w_det_preco_item-kposn = '000001'.
  ENDIF.

  CLEAR w_copy_records                         .
  w_copy_records-mandt = sy-mandt              . " Mandante
  w_copy_records-kappl = 'V'                   . " Aplicação
  w_copy_records-kschl = 'YDEC'                . " Tipo de condição
  w_copy_records-kbetr = '550'                 . " Montante ou porcentagem da condição
  w_copy_records-krech = 'A'                   . " Regra de cálculo de condição
  w_copy_records-waers = '%'                   . " Código da moeda
  w_copy_records-knumh = '$000000001'          . " Nº registro de condição
  w_copy_records-kopos = 1                     . " Nº seqüencial da condição
  w_copy_records-stfkz = 'A'                   . " Tipo de escala
  APPEND w_copy_records TO t_copy_records      . " Registro de condição de comunicação p/determinação de preço

  CALL FUNCTION 'RV_CONDITION_COPY'
    EXPORTING
      application              = 'V'
      condition_table          = '972'
      condition_type           = 'YDEC'
      date_from                = '20180708'
      date_to                  = '20180708'
      enqueue                  = abap_true
      i_komk                   = w_det_preco_cabecalho
      i_komp                   = w_det_preco_item
      key_fields               = w_condicao
      maintain_mode            = 'B'
      no_authority_check       = abap_true
      no_field_check           = abap_true
      keep_old_records         = abap_true
      overlap_confirmed        = abap_true
    TABLES
      copy_records             = t_copy_records
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
      WRITE w_knumh-knumh_new.
    ENDLOOP.
  ELSE.
    DATA: v_msg_erro TYPE string.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            INTO v_msg_erro.

    WRITE v_msg_erro.
  ENDIF.