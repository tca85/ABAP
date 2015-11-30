*----------------------------------------------------------------------*
* Classe   : YCL_GKO                                                   *
* Método   : TESTAR_RFC_DESTINATION                                    *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Testar RFC destination com o SAP ECC                      *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  01.07.2015  #108147 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD testar_rfc_destination.
*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro        TYPE string         ,
    v_rfc_sap_ecc     TYPE rs38l-name     ,
    v_rfc_destination TYPE bdbapidst      ,
    v_group           TYPE rs38l-area     ,                 "#EC NEEDED
    v_include         TYPE rs38l-include  ,                 "#EC NEEDED
    v_namespace       TYPE rs38l-namespace,                 "#EC NEEDED
    v_str_area        TYPE rs38l-str_area .                 "#EC NEEDED

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  IF im_sistema_logico IS INITIAL.
*   Sistema lógico não informado
    MESSAGE e007(ygko) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_gko EXPORTING msg = v_msg_erro.
  ENDIF.

* Obtém a RFC destination (SM59) para o ECC
  CALL FUNCTION '/XNFE/READ_RFC_DESTINATION'
    EXPORTING
      iv_logsys     = im_sistema_logico
    IMPORTING
      ev_rfcdest    = v_rfc_destination
    EXCEPTIONS
      no_dest_found = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
*   RFC destination (SM59) para o ECC não foi encontrada
    MESSAGE e003(ygko) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_gko EXPORTING msg = v_msg_erro.
  ENDIF.

* Testa a conexão com o SAP ECC
  CALL FUNCTION 'RFC_PING'
    DESTINATION v_rfc_destination
    EXCEPTIONS
      system_failure        = 1
      communication_failure = 2
      OTHERS                = 99.

  IF sy-subrc <> 0.
*   RFC destination está com falha de conexão
    MESSAGE e005(ygko) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_gko EXPORTING msg = v_msg_erro.
  ENDIF.

  v_rfc_sap_ecc = im_nome_rfc_ecc.

  IF v_rfc_sap_ecc IS INITIAL.
*   Nome da RFC não foi informado
    MESSAGE e008(ygko) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_gko EXPORTING msg = v_msg_erro.
  ENDIF.

  CALL FUNCTION 'FUNCTION_EXISTS'
    DESTINATION v_rfc_destination
    EXPORTING
      funcname           = v_rfc_sap_ecc
    IMPORTING
      group              = v_group
      include            = v_include
      namespace          = v_namespace
      str_area           = v_str_area
    EXCEPTIONS
      function_not_exist = 1
      OTHERS             = 2.

  IF sy-subrc = 0.
    ex_nome_rfc_ecc    = v_rfc_sap_ecc    .
    ex_rfc_destination = v_rfc_destination.
  ELSE.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO v_msg_erro.

    RAISE EXCEPTION TYPE ycx_gko EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.