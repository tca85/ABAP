FUNCTION ysd_vk15.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(T946) TYPE  YCT_A946 OPTIONAL
*"     VALUE(T947) TYPE  YCT_A947 OPTIONAL
*"     VALUE(T960) TYPE  YCT_A960 OPTIONAL
*"     VALUE(T961) TYPE  YCT_A961 OPTIONAL
*"     VALUE(T962) TYPE  YCT_A962 OPTIONAL
*"     VALUE(T963) TYPE  YCT_A963 OPTIONAL
*"     VALUE(T968) TYPE  YCT_A968 OPTIONAL
*"     VALUE(T969) TYPE  YCT_A969 OPTIONAL
*"     VALUE(T972) TYPE  YCT_A972 OPTIONAL
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Módulo de Função : YSD_VK15                                          *
* Grupo de Funções : YSD_CRIA_COND                                     *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Cria condição de pagamento na transação VK15 utilizando   *
*            a RFC existente de forma assíncrona                       *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  25.03.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

* obs: o conceito foi retirado do link abaixo:
* http://www.abapzombie.com/guias/2011/03/21/abapzombie-guide-to-abap-parte-19-call-function
* http://www.abapzombie.com/dicas-abap/2012/03/12/processamento-em-paralelo-utilizando-rfc-assincrona/

  DATA:
    t_retorno_rfc TYPE STANDARD TABLE OF ymensagens,
    v_tasks       TYPE i                           ,
    v_task_ativa  TYPE i                           ,
    v_task_id     TYPE numc2                       ,
    v_nome_task   TYPE char10                      .

* Obter o número de sessões disponíveis
  CALL FUNCTION 'SPBT_INITIALIZE'
    IMPORTING
      free_pbt_wps                   = v_tasks
    EXCEPTIONS
      invalid_group_name             = 1
      internal_error                 = 2
      pbt_env_already_initialized    = 3
      currently_no_resources_avail   = 4
      no_pbt_resources_found         = 5
      cant_init_different_pbt_groups = 6
      OTHERS                         = 7.

  DO.
*   Incrementar ao contador de sessões ativas
    IF sy-subrc IS INITIAL.
      v_task_ativa = v_task_ativa + 1.
    ENDIF.

*   Verificar se o número de sessões ativas está dentro do limite
    IF v_task_ativa <= v_tasks.

*     Cada sessão deverá ter um ID único
      v_task_id = v_task_id + 1.

      CALL FUNCTION 'YYPCL_SD_CRIA_CONDICAO' "IN BACKGROUND TASK
        STARTING NEW TASK v_task_id
        DESTINATION IN GROUP DEFAULT
        PERFORMING f_obtem_retorno_rfc ON END OF TASK
        TABLES
          t946      = t946
          t947      = t947
          t960      = t960
          t961      = t961
          t962      = t962
          t963      = t963
          t968      = t968
          t969      = t969
          t972      = t972
          mensagens = t_retorno_rfc.

      IF sy-subrc <> 0.
*       Tenta novamente se a RFC falhar
        v_task_ativa = v_task_ativa - 1.
      ELSE.
        EXIT.
      ENDIF.

    ELSE.
      v_task_id = v_task_id - 1.
    ENDIF.
  ENDDO.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*&      Form  f_obtem_retorno_rfc
*&---------------------------------------------------------------------*
FORM f_obtem_retorno_rfc USING taskname.

  DATA:
    t_retorno_rfc TYPE STANDARD TABLE OF ymensagens,
    t_946         TYPE STANDARD TABLE OF y946      ,
    t_947         TYPE STANDARD TABLE OF y947      ,
    t_960         TYPE STANDARD TABLE OF y960      ,
    t_961         TYPE STANDARD TABLE OF y961      ,
    t_962         TYPE STANDARD TABLE OF y962      ,
    t_963         TYPE STANDARD TABLE OF y963      ,
    t_968         TYPE STANDARD TABLE OF y968      ,
    t_969         TYPE STANDARD TABLE OF y969      ,
    t_972         TYPE STANDARD TABLE OF y972      ,
    w_946         LIKE LINE OF t_946               ,
    w_947         LIKE LINE OF t_947               ,
    w_960         LIKE LINE OF t_960               ,
    w_961         LIKE LINE OF t_961               ,
    w_962         LIKE LINE OF t_962               ,
    w_963         LIKE LINE OF t_963               ,
    w_968         LIKE LINE OF t_968               ,
    w_969         LIKE LINE OF t_969               ,
    w_972         LIKE LINE OF t_972               ,
    w_retorno_rfc LIKE LINE OF t_retorno_rfc       ,
    t_log_vk15    TYPE STANDARD TABLE OF ysd_vk15  ,
    w_log_vk15    LIKE LINE OF t_log_vk15          ,
    v_data_atual  TYPE sy-datum                    ,
    v_hora_atual  TYPE sy-uzeit                    .

  v_data_atual = sy-datum.
  v_hora_atual = sy-uzeit.

* Esse perform será executando quando as tasks da função acabarem de rodar.
* Para pegar os valores que a função retornou, use o comando abaixo:
  RECEIVE RESULTS FROM FUNCTION 'YYPCL_SD_CRIA_CONDICAO'
  TABLES
    t946      = t_946
    t947      = t_947
    t960      = t_960
    t961      = t_961
    t962      = t_962
    t963      = t_963
    t968      = t_968
    t969      = t_969
    t972      = t_972
    mensagens = t_retorno_rfc.

* EscrVendas/Cliente/Material/Lote/Tipo ped.
  LOOP AT t_946 INTO w_946.
    READ TABLE t_retorno_rfc
    INTO w_retorno_rfc
    INDEX 1.

    IF sy-subrc = 0.
      CLEAR w_log_vk15                            .
      w_log_vk15-mandt    = sy-mandt              .
      w_log_vk15-data     = v_data_atual          .
      w_log_vk15-hora     = v_hora_atual          .
      w_log_vk15-kotabnr  = '946'                 . " Nome da condição
      w_log_vk15-id       = 12345                 . " ID
      w_log_vk15-tipo     = w_retorno_rfc-tipo    . " Tipo de retorno da mensagem
      w_log_vk15-mensagem = w_retorno_rfc-mensagem. " Mensagem de retorno
      APPEND w_log_vk15 TO t_log_vk15.
    ENDIF.
  ENDLOOP.

  IF t_log_vk15 IS NOT INITIAL.
    MODIFY ysd_vk15 FROM TABLE t_log_vk15.
  ENDIF.

ENDFORM.                    " f_obtem_retorno_rfc