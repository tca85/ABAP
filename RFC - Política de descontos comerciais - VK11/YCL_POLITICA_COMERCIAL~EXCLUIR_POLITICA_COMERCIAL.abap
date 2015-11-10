*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_POLITICA_COMERCIAL                                    *
* Método   : EXCLUIR_POLITICA_COMERCIAL                                *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Excluir a política comercial da VK15                      *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  08.05.2015  #100197 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD excluir_politica_comercial.
*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
  TYPES:
    BEGIN OF ty_konh               ,
      knumh   TYPE konh-knumh      , " Nº registro de condição
      kappl   TYPE konh-kappl      , " Aplicação
      kschl   TYPE konh-kschl      , " Tipo de condição
      kotabnr TYPE konh-kotabnr    , " Tabela de condições
      kvewe   TYPE konh-kvewe      , " Utilização da tabela de condições
      datab   TYPE konh-datab      , " Data início validade
      datbi   TYPE konh-datbi      , " Data de validade final
      vakey   TYPE konh-vakey      , " Chave variável 100 bytes
      ernam   TYPE konh-ernam      , " Nome do responsável que adicionou o objeto
      erdat   TYPE konh-erdat      , " Data de criação do registro
    END OF ty_konh                 ,

    BEGIN OF ty_konp               ,
      knumh     TYPE konp-knumh    , " Nº registro de condição
      kopos     TYPE konp-kopos    , " Nº seqüencial da condição
      kappl     TYPE konp-kappl    , " Aplicação
      kschl     TYPE konp-kschl    , " Tipo de condição
      stfkz     TYPE konp-stfkz    , " Tipo de escala
      konwa     TYPE konp-konwa    , " Base de escala da condição - valor
      krech     TYPE konp-krech    , " Regra de cálculo de condição
      kbetr     TYPE konp-kbetr    , " Montante/porcentagem de condição no caso de não haver escala
      zaehk_ind TYPE konp-zaehk_ind, " Índice do item de condição
      zterm     TYPE konp-zterm    , " Chave de condições de pagamento
    END OF ty_konp                 .

*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_politica_comercial TYPE STANDARD TABLE OF ypolitica_comercial,
    t_konp               TYPE STANDARD TABLE OF ty_konp            ,
    t_bapicondct         TYPE STANDARD TABLE OF bapicondct         ,
    t_bapicondhd         TYPE STANDARD TABLE OF bapicondhd         ,
    t_bapicondit         TYPE STANDARD TABLE OF bapicondit         ,
    t_bapicondqs         TYPE STANDARD TABLE OF bapicondqs         ,
    t_bapicondvs         TYPE STANDARD TABLE OF bapicondvs         ,
    t_bapiret2           TYPE STANDARD TABLE OF bapiret2           ,
    t_bapiknumhs         TYPE STANDARD TABLE OF bapiknumhs         ,
    t_mem_initial        TYPE STANDARD TABLE OF cnd_mem_initial    .

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_politica_comercial LIKE LINE OF t_politica_comercial,
    w_konp               LIKE LINE OF t_konp              ,
    w_konh               TYPE ty_konh                     ,
    w_bapicondct         LIKE LINE OF t_bapicondct        ,
    w_bapicondhd         LIKE LINE OF t_bapicondhd        ,
    w_bapicondit         LIKE LINE OF t_bapicondit        ,
    w_bapiret2           LIKE LINE OF t_bapiret2          .

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_indice           TYPE sy-tabix,
    v_tipo_eliminacao  TYPE kdele   ,
    v_tipo_modificacao TYPE msgfn   .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  APPEND LINES OF im_t_politica_comercial TO t_politica_comercial.

  LOOP AT t_politica_comercial INTO w_politica_comercial.
    FREE: t_bapicondct, t_bapicondhd, t_bapicondit,
          t_bapicondqs, t_bapicondvs, t_bapiret2,
          t_bapiknumhs, t_mem_initial, t_konp, w_konh.

    SELECT SINGLE knumh kappl kschl kotabnr
                  kvewe datab datbi vakey
                  ernam erdat
     FROM konh
     INTO w_konh
     WHERE knumh = w_politica_comercial-id_sap
       AND kschl = me->c_desc_comercial
       AND kappl = me->c_aplicacao_sd.

    IF w_konh IS NOT INITIAL.
      SELECT knumh kopos kappl kschl stfkz
             konwa krech kbetr zaehk_ind zterm
      FROM konp
      INTO TABLE t_konp
      WHERE knumh = w_konh-knumh.

    ELSE.
      w_bapiret2-type       = 'E'                                 .
      w_bapiret2-message_v1 = w_politica_comercial-id_sap         .
      w_bapiret2-message    = 'Nº registro de condição não existe'.
      APPEND w_bapiret2 TO t_bapiret2                             .

      me->set_msg_retorno( im_id_modificacao = w_politica_comercial-id
                           im_t_retorno_bapi = t_bapiret2 ).
      CONTINUE.
    ENDIF.

    v_tipo_modificacao = me->c_funcao_eliminacao.

    CLEAR w_bapicondct                          .
    w_bapicondct-operation  = v_tipo_modificacao. " Original: primeira mensagem para operação
    w_bapicondct-cond_no    = w_konh-knumh      . " Nº registro de condição
    w_bapicondct-applicatio = w_konh-kappl      . " Aplicação
    w_bapicondct-cond_type  = w_konh-kschl      . " Tipo de condição
    w_bapicondct-table_no   = w_konh-kotabnr    . " Tabela de condições
    w_bapicondct-cond_usage = w_konh-kvewe      . " Utilização da tabela de condições
    w_bapicondct-valid_from = w_konh-datab      . " Data início validade
    w_bapicondct-valid_to   = w_konh-datbi      . " Data de validade final
    w_bapicondct-varkey     = w_konh-vakey      . " Chave
    APPEND w_bapicondct TO t_bapicondct         .

    CLEAR w_bapicondhd                          .
    w_bapicondhd-operation  = v_tipo_modificacao. " Função
    w_bapicondhd-cond_no    = w_konh-knumh      . " Nº registro de condição
    w_bapicondhd-applicatio = w_konh-kappl      . " Aplicação
    w_bapicondhd-cond_type  = w_konh-kschl      . " Tipo de condição
    w_bapicondhd-table_no   = w_konh-kotabnr    . " Tabela de condições
    w_bapicondhd-cond_usage = w_konh-kvewe      . " Utilização da tabela de condições
    w_bapicondhd-created_by = w_konh-ernam      . " Nome do responsável que adicionou o objeto
    w_bapicondhd-creat_date = w_konh-erdat      . " Data de criação do registro
    w_bapicondhd-valid_from = w_konh-datab      . " Data início validade
    w_bapicondhd-valid_to   = w_konh-datbi      . " Data de validade final
    w_bapicondhd-varkey     = w_konh-vakey      . " Chave variável
    APPEND w_bapicondhd TO t_bapicondhd         .

    LOOP AT t_konp INTO w_konp.
      CLEAR w_bapicondit                          .
      w_bapicondit-operation  = v_tipo_modificacao. " Função
      w_bapicondit-cond_no    = w_konp-knumh      . " Nº registro de condição
      w_bapicondit-applicatio = w_konp-kappl      . " Aplicação
      w_bapicondit-cond_type  = w_konp-kschl      . " Tipo de condição
      w_bapicondit-scaletype  = w_konp-stfkz      . " Tipo de escala
      w_bapicondit-calctypcon = w_konp-krech      . " Regra de cálculo de condição
      w_bapicondit-cond_count = w_konp-kopos      . " Nº seqüencial da condição
      w_bapicondit-cond_value = w_konp-kbetr / 10 . " Montante em moeda para BAPIs (com 9 casas decimais)
      w_bapicondit-condcurr   = w_konp-konwa      . " Unidade de condição (moeda ou porcentagem)
      w_bapicondit-pmnttrms   = w_konp-zterm      . " Chave de condições de pagamento
      w_bapicondit-conditidx  = w_konp-zaehk_ind  . " Índice do item de condição
      APPEND w_bapicondit TO t_bapicondit         .
    ENDLOOP.

*   Exclui a política comercial da transação VK11
    CALL FUNCTION 'BAPI_PRICES_CONDITIONS'
      EXPORTING
        pi_initialmode       = abap_true
        pi_physical_deletion = abap_true
      TABLES
        ti_bapicondct        = t_bapicondct  " Estrutura BAPI p/tabelas de condições (corresp. a COND_RECS)
        ti_bapicondhd        = t_bapicondhd  " Bapistructure of KONH with english field names
        ti_bapicondit        = t_bapicondit  " Bapistructure of KONP with english field names
        ti_bapicondqs        = t_bapicondqs  " Bapistructure of KONM with english field names
        ti_bapicondvs        = t_bapicondvs  " Bapistructure of KONW with english field names
        to_bapiret2          = t_bapiret2    " Parâmetro de retorno
        to_bapiknumhs        = t_bapiknumhs  " Estrutura BAPI para a atribuição de KNUMHs
        to_mem_initial       = t_mem_initial " Condições: buffer para transferência de dados inicial
      EXCEPTIONS
        update_error         = 1
        OTHERS               = 2.

    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

      LOOP AT t_bapiret2 INTO w_bapiret2                   .
        v_indice = sy-tabix                                .
        w_bapiret2-message_v1 = w_politica_comercial-id_sap.
        MODIFY t_bapiret2 FROM w_bapiret2 INDEX v_indice   .
      ENDLOOP.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      LOOP AT t_bapiret2 INTO w_bapiret2.
        v_indice = sy-tabix.

        w_bapiret2-type    = 'E'                                            .
        w_bapiret2-message = 'Erro durante a exclusão da política comercial'.
        MODIFY t_bapiret2 FROM w_bapiret2 INDEX v_indice                    .
      ENDLOOP.
    ENDIF.

    me->set_msg_retorno( im_id_modificacao = w_politica_comercial-id
                         im_t_retorno_bapi = t_bapiret2 ).
  ENDLOOP.
ENDMETHOD.
