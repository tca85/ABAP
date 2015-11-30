FUNCTION zml85_enviar_email.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(P_EBELN) TYPE  ESSR-EBELN
*"     REFERENCE(P_LBLNI) TYPE  ESSR-LBLNI
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*                       xxxxxxxxxxxxxxxxx                              *
*----------------------------------------------------------------------*
* Módulo   : MM                                                        *
* Funcional: xxxxxxxxxxxxxxxxxxxxxxxxxx                                *
* ABAP     : Thiago Cordeiro Alves                                     *
* Objetivo : Enviar e-mail para os usuários que precisam aprovar uma   *
*            folha de serviço                                          *
*----------------------------------------------------------------------*
* Enhancement Points:                                                  *
*   ML85 :   ZML85_SAVE   / RMSRVF00 / FORM release_update.            *
*   ML81N:   ZML81N_SAVE  / LMLSRF0F / FORM save.                      *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.03.2014  #75195 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

* Estratégia de liberação de folha de serviço

  CHECK sy-tcode = 'ML81N' " Registro de Serviços (Cria a Folha)
     OR sy-tcode = 'ML85'. " Liberação Coletiva Folha de Registro de Serviços

  CHECK p_ebeln IS NOT INITIAL
    AND p_lblni IS NOT INITIAL.
*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
  TYPES:
   BEGIN OF ty_usuario              ,
     seq     TYPE i                 , " Sequência de Liberação
     cod     TYPE t16fd-frgco       , " Código de liberação
     nome    TYPE bapiaddr3-fullname, " Denominação do código de liberação
     user    TYPE usr02-bname       , " Usuário SAP
     email   TYPE bapiadsmtp-e_mail , " E-mail
     liberou TYPE c LENGTH 01       , " Usuário fez a liberação
   END OF ty_usuario                .

*----------------------------------------------------------------------*
* Tabelas internas                                                     *
*----------------------------------------------------------------------*
  DATA:
    t_usuario     TYPE STANDARD TABLE OF ty_usuario,
    t_email       TYPE STANDARD TABLE OF somlreci1 , " Usuários que receberão o e-mail
    t_usr_subst   TYPE STANDARD TABLE OF zestratlib, " Estratégia de Liberação x Usuários Substitutos p/férias
    t_addsmtp     TYPE STANDARD TABLE OF bapiadsmtp,
    t_return      TYPE STANDARD TABLE OF bapiret2  ,
    t_det_usu     TYPE qisrtuser_name              ,
    t_corpo_email TYPE bcsy_text                   .

*----------------------------------------------------------------------*
* Ranges                                                               *
*----------------------------------------------------------------------*
  DATA:
    r_data TYPE RANGE OF sy-datum.

*----------------------------------------------------------------------*
* Work Areas                                                           *
*----------------------------------------------------------------------*
  DATA:
    w_usuario        LIKE LINE OF t_usuario    ,
    w_email          LIKE LINE OF t_email      ,
    w_usr_subst      LIKE LINE OF t_usr_subst  ,
    w_addsmtp        LIKE LINE OF t_addsmtp    ,
    w_corpo_email    LIKE LINE OF t_corpo_email,
    w_det_usu        LIKE LINE OF t_det_usu    ,
    w_data           LIKE LINE OF r_data       ,
    w_estrategia_lib LIKE t16fs                , " Estratégias de liberação
    w_address        LIKE bapiaddr3            .

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
  DATA:
    v_campo_frgc_1_8 TYPE c LENGTH 05         , " Código de liberação FRGC1 ~ FRGC8
    v_indice_item    TYPE c LENGTH 01         ,
    v_est_lib        TYPE essr-frgzu          , " Estado de liberação
    v_e_mail_usuario TYPE adr6-smtp_addr      ,
    v_assunto_email  TYPE so_obj_des          ,
    v_status_email   TYPE bcs_rqst            ,
    v_erro           TYPE string              ,
    v_resp_liberacao TYPE sy-uname            ,
    v_qtd_lib        TYPE i                   ,
    v_seq_lib        TYPE i                   ,
    v_nome_comp      TYPE user_addr-name_textc.

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
  CONSTANTS:
    c_lib_folha_serv  TYPE t16fg-frggr VALUE '05'      ,
    c_usuario_sap     TYPE usr02-bname VALUE 'WF-BATCH',
    c_qtd_estrat_lib  TYPE i           VALUE 8         ,
    c_raw             TYPE c LENGTH 03 VALUE 'RAW'     ,
    c_cod_liberacao   TYPE c LENGTH 04 VALUE 'FRGC'    .

*----------------------------------------------------------------------*
* Field-Symbos                                                         *
*----------------------------------------------------------------------*
  FIELD-SYMBOLS:
    <fs_cod_lib> TYPE t16fs-frgc1.

*----------------------------------------------------------------------*
* Objetos                                                              *
*----------------------------------------------------------------------*
  DATA:
    obj_bcs       TYPE REF TO cl_bcs          ,
    obj_doc_bcs   TYPE REF TO cl_document_bcs ,
    obj_recipient TYPE REF TO if_recipient_bcs,
    obj_sender    TYPE REF TO if_sender_bcs   ,
    obj_excp      TYPE REF TO cx_bcs          .

*----------------------------------------------------------------------*
* Inicio                                                               *
*----------------------------------------------------------------------*

* Estratégias de liberação
  SELECT SINGLE * FROM t16fs
    INTO w_estrategia_lib
    WHERE frggr = c_lib_folha_serv. " 05

* Estratégia de Liberação x Usuários Substitutos p/férias
  SELECT * FROM zestratlib
   INTO TABLE t_usr_subst.

  v_seq_lib = c_qtd_estrat_lib + 1.

* A sequência da estratégia de liberação é feita de trás para frente
* ex: campo FRGC1 é a última sequencia do 'Worflow'
  DO c_qtd_estrat_lib TIMES. " 8
    WRITE sy-index TO v_indice_item.

    v_seq_lib = v_seq_lib - 1.

    CLEAR: w_usuario, w_usr_subst, w_det_usu, v_nome_comp, v_resp_liberacao, t_addsmtp.
    FREE: t_addsmtp, t_return, t_det_usu, r_data.

*   'Monta' o nome do campo FRGC1 ~ FRGC8 da tabela T16FS
    CONCATENATE c_cod_liberacao " FRGC
                v_indice_item                               " 1 ~ 8
           INTO v_campo_frgc_1_8.

    UNASSIGN <fs_cod_lib>.

    ASSIGN COMPONENT v_campo_frgc_1_8
        OF STRUCTURE w_estrategia_lib
                  TO <fs_cod_lib>.

*   Verifica se o campo possui informação (sequência do 'Workflow' de liberação)
    IF <fs_cod_lib> IS ASSIGNED
      AND  <fs_cod_lib> IS NOT INITIAL.

*     Verifica se não possui nenhum usuário substituto para o período
*     atual (ex: o outro está de férias)
      READ TABLE t_usr_subst
      INTO w_usr_subst
      WITH KEY frggr = c_lib_folha_serv " Grupo de liberação / 05
               frgco = <fs_cod_lib>.    " Código de liberação

      IF sy-subrc = 0.
        w_data-sign   = 'I'              . " Include
        w_data-option = 'BT'             . " Between
        w_data-low    = w_usr_subst-dtini.
        w_data-high   = w_usr_subst-dtfim.
        APPEND w_data TO r_data          .
      ENDIF.

      IF r_data IS NOT INITIAL
        AND sy-datum IN r_data.
        v_resp_liberacao = w_usr_subst-subs.
      ELSE.
*       Usuário responsável não está de férias: seleciona o nome cadastrado
*       na SPRO para identificar o usuário do SAP e o e-mail
        SELECT SINGLE frgct
         FROM t16fd
         INTO w_usuario-nome
         WHERE frggr = c_lib_folha_serv " Grupo de liberação / 05
           AND frgco = <fs_cod_lib>.    " Código de liberação

        v_nome_comp = w_usuario-nome.

        REPLACE space INTO v_nome_comp WITH '*'.
        CONCATENATE v_nome_comp '*' INTO v_nome_comp.

*       Obtém o nome do usuário do SAP, para pegar o e-mail dele
        CALL FUNCTION 'ISR_GET_USER'
          EXPORTING
            i_full_name       = v_nome_comp
          IMPORTING
            et_selected_users = t_det_usu.

        READ TABLE t_det_usu
        INTO w_det_usu
        INDEX 1.

        v_resp_liberacao = w_det_usu-user_id.
      ENDIF.

*     Retorna o e-mail do usuário do SAP
      CALL FUNCTION 'BAPI_USER_GET_DETAIL'
        EXPORTING
          username = v_resp_liberacao
        IMPORTING
          address  = w_address
        TABLES
          return   = t_return
          addsmtp  = t_addsmtp.

      READ TABLE t_addsmtp
      INTO w_addsmtp
      INDEX 1.

*     Converte a 1ª letra para maísculo e o resto em minúsculo
      CALL FUNCTION 'YNQM_CONVERT_FIRSTCHAR_TOUPPER'
        EXPORTING
          input_string  = w_address-fullname
        IMPORTING
          output_string = w_usuario-nome.

      w_usuario-seq   = v_seq_lib       . " Sequencia de liberação
      w_usuario-cod   = <fs_cod_lib>    . " Código de liberação
      w_usuario-user  = v_resp_liberacao. " Usuário SAP
      w_usuario-email = w_addsmtp-e_mail. " E-mail
      APPEND w_usuario TO t_usuario     .
    ENDIF.
  ENDDO.

* Verifica em qual estado de liberação a folha de serviço está
* essa variável pode ter até 8 'X', que representam os
* campos FRGC1 ~ FRGC8 da tabela T16FS
  SELECT SINGLE frgzu
   INTO (v_est_lib)
   FROM essr
   WHERE ebeln = p_ebeln
     AND lblni = p_lblni.

  CONDENSE v_est_lib NO-GAPS.

  v_qtd_lib = STRLEN( v_est_lib ).
  v_qtd_lib = v_qtd_lib + 1.

* Ordena os usuários de acordo com a sequência de liberação
  CASE sy-tcode.
    WHEN 'ML81N'.
      SORT t_usuario BY seq DESCENDING.
    WHEN 'ML85'.
      SORT t_usuario BY seq ASCENDING.
  ENDCASE.

* 'Marca' os usuários que já fizeram a liberação
  LOOP AT t_usuario INTO w_usuario.
    IF v_qtd_lib >= sy-tabix.
      w_usuario-liberou = 'X'.
      MODIFY t_usuario FROM w_usuario INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

  CLEAR w_usuario.

  READ TABLE t_usuario
  INTO w_usuario
  WITH KEY liberou = space.

  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

* Insere o usuário no grupo 'Sem dados Obrigatórios' da SODIS
* altera o e-mail do usuário WF-BATCH para o do usuário corrente
  CALL FUNCTION 'YNQM_SELECT_SODIS_DETAILS'
    EXPORTING
      usuario_comp = c_usuario_sap
      usuario_log  = sy-uname.

* Assunto do e-mail
  v_assunto_email = 'SAP - & - Liberação de Folha de Serviço'.
  REPLACE '&' WITH sy-sysid(3) INTO v_assunto_email.

* Corpo do e-mail
  CONCATENATE 'Sr.(a) ' w_usuario-nome
         INTO w_corpo_email SEPARATED BY space.
  APPEND w_corpo_email TO t_corpo_email.

  CLEAR w_corpo_email.
  APPEND w_corpo_email TO t_corpo_email.

  CONCATENATE 'A folha de serviço ' p_lblni
              'do pedido '          p_ebeln
              'precisa ser liberada na transação ML85.'
        INTO w_corpo_email SEPARATED BY space.
  APPEND w_corpo_email TO t_corpo_email.

* E-mail do usuário responsável que receberá a notificação
  v_e_mail_usuario = w_usuario-email.

* Envia um e-mail ao usuário para que ele saiba que tem uma liberação pendente
  TRY.
      obj_bcs = cl_bcs=>create_persistent( ).

      obj_sender = cl_sapuser_bcs=>create( c_usuario_sap ).

      obj_recipient = cl_cam_address_bcs=>create_internet_address( v_e_mail_usuario ).

      obj_doc_bcs = cl_document_bcs=>create_document(
                           i_type    = c_raw
                           i_text    = t_corpo_email
                           i_subject = v_assunto_email ).

      obj_bcs->set_sender( i_sender = obj_sender ).
      obj_bcs->add_recipient( i_recipient = obj_recipient ).
      obj_bcs->set_document( i_document = obj_doc_bcs ).
      obj_bcs->set_send_immediately( 'X' ).
      obj_bcs->send( ).

      COMMIT WORK.

    CATCH cx_bcs INTO obj_excp.
      v_erro = obj_excp->get_text( ).
      MESSAGE v_erro TYPE 'I'.
  ENDTRY.

ENDFUNCTION.