*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_ECC                                                   *
* Método   : ATUALIZAR_STATUS_NFE_ECC                                  *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Atualizar no ECC o status da NF-e que foi cancelada fora  *
*            do prazo de 24 horas                                      *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  18.11.2015  #135221 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD atualizar_status_nfe_ecc.
*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
  TYPES:
    BEGIN OF ty_nfe                        ,
      docnum   TYPE /xnfe/outnfehd-docnum  , " Nº do documento NF-e
      id       TYPE /xnfe/outnfehd-id      , " Chave de acesso de 44 caracteres
      logsys   TYPE /xnfe/outnfehd-logsys  , " Sistema lógico
      msgtyp   TYPE /xnfe/outnfehd-msgtyp  , " Status do documento NF-e (sistema back end)
      statcod  TYPE /xnfe/outnfehd-statcod , " Código de status do documento junto às autoridades (SEFAZ)
      dhrecbto TYPE /xnfe/outnfehd-dhrecbto, " Data/hora da autorização em UTC
      nprot    TYPE /xnfe/outnfehd-nprot   , " Nº do protocolo
    END OF ty_nfe                          .

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_nfe TYPE ty_nfe.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro         TYPE string     ,                    "#EC NEEDED
    v_nome_rfc_ecc     TYPE rs38l-name ,
    v_rfc_destination  TYPE bdbapidst  ,
    v_data_autorizacao TYPE dats       ,
    v_hora_autorizacao TYPE uzeit      ,
    v_msg_evento       TYPE c LENGTH 01.

*----------------------------------------------------------------------*
* Variáveis tipo referência
*----------------------------------------------------------------------*
  DATA:
    o_cx_ecc  TYPE REF TO ycx_ecc,
    o_cx_root TYPE REF TO cx_root.

*----------------------------------------------------------------------*
* Contantes
*----------------------------------------------------------------------*
  CONSTANTS:
    c_rfc_ecc_xml_in    TYPE rs38l-name  VALUE 'J_1B_NFE_XML_IN'       ,
    c_rfc_ecc_evt_in    TYPE rs38l-name  VALUE 'Y_J_1BNFE_EVENT_UPDATE',
    c_evento_autorizado TYPE c LENGTH 01 VALUE 1                       .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

* Detalhes da NF-e
  SELECT SINGLE docnum id logsys msgtyp statcod dhrecbto nprot
    FROM /xnfe/outnfehd
    INTO w_nfe
    WHERE id = im_chave_acesso.

  IF w_nfe IS INITIAL.
    RAISE EXCEPTION TYPE ycx_ecc EXPORTING msg = 'NF-e não encontrada'. "#EC NOTEXT
  ENDIF.

  TRY.
      me->testar_rfc_destination( EXPORTING im_sistema_logico  = w_nfe-logsys         " Sistema lógico
                                            im_nome_rfc_ecc    = c_rfc_ecc_xml_in     " RFC criada no ECC
                                  CHANGING  ex_nome_rfc_ecc    = v_nome_rfc_ecc       " Confirmação da RFC encontrada
                                            ex_rfc_destination = v_rfc_destination ). " Nome da RFC Destination
    CATCH ycx_ecc INTO o_cx_ecc.
      v_msg_erro = o_cx_ecc->msg.
      RAISE EXCEPTION TYPE ycx_ecc EXPORTING msg = v_msg_erro.
  ENDTRY.

  IF v_nome_rfc_ecc IS INITIAL.
    RETURN.
  ENDIF.

  v_data_autorizacao = w_nfe-dhrecbto+0(8).
  v_hora_autorizacao = w_nfe-dhrecbto+8(6).
  v_msg_evento       = c_evento_autorizado.

  TRY.
      CALL FUNCTION v_nome_rfc_ecc
        DESTINATION v_rfc_destination
        EXPORTING
          i_docnum              = w_nfe-docnum       " Nº documento
          i_acckey              = w_nfe-id           " Chave de acesso
          i_authcode            = w_nfe-nprot        " Código de autorização da NF-e
          i_authdate            = v_data_autorizacao " Data de processamento
          i_authtime            = v_hora_autorizacao " Hora de processamento
          i_code                = w_nfe-statcod      " NF-e: código de status
          i_msgtyp              = w_nfe-msgtyp       " Tipo da mensagem de entrada
          i_event_msgtyp        = v_msg_evento       " Mensagem do evento
        EXCEPTIONS
          inbound_error         = 1
          communication_failure = 2
          system_failure        = 3
          OTHERS                = 4.

      IF sy-subrc = 0.
        CONCATENATE 'J_1B_NFE_XML_IN executada com sucesso' space INTO rt_mensagem. "#EC NOTEXT
      ELSE.
        RAISE EXCEPTION TYPE ycx_ecc EXPORTING msg = 'Erro na RFC J_1B_NFE_XML_IN'. "#EC NOTEXT
      ENDIF.

    CATCH cx_root INTO o_cx_root.
      v_msg_erro = o_cx_root->get_text( ).
      RAISE EXCEPTION TYPE ycx_ecc EXPORTING msg = v_msg_erro.
  ENDTRY.

  CLEAR: v_nome_rfc_ecc, v_rfc_destination.

  TRY.
      me->testar_rfc_destination( EXPORTING im_sistema_logico  = w_nfe-logsys         " Sistema lógico
                                            im_nome_rfc_ecc    = c_rfc_ecc_evt_in     " RFC criada no ECC
                                  CHANGING  ex_nome_rfc_ecc    = v_nome_rfc_ecc       " Confirmação da RFC encontrada
                                            ex_rfc_destination = v_rfc_destination ). " Nome da RFC Destination
    CATCH ycx_ecc INTO o_cx_ecc.
      v_msg_erro = o_cx_ecc->msg.
      CONCATENATE v_msg_erro rt_mensagem INTO rt_mensagem SEPARATED BY ';'.
  ENDTRY.

  IF v_nome_rfc_ecc IS INITIAL.
    RETURN.
  ENDIF.

  TRY.
      CALL FUNCTION v_nome_rfc_ecc
        DESTINATION v_rfc_destination
        EXPORTING
          im_docnum             = w_nfe-docnum
          im_docstat            = w_nfe-statcod
          im_statuscod          = w_nfe-msgtyp
        EXCEPTIONS
          nfe_nao_encontrada    = 1
          communication_failure = 2
          system_failure        = 3
          OTHERS                = 4.

      IF sy-subrc = 0.
        CONCATENATE 'Y_J_1BNFE_EVENT_UPDATE executada com sucesso' rt_mensagem INTO rt_mensagem SEPARATED BY ';'. "#EC NOTEXT
      ELSE.
        RAISE EXCEPTION TYPE ycx_ecc EXPORTING msg = 'Erro na RFC J_1B_NFE_XML_IN'. "#EC NOTEXT
      ENDIF.

    CATCH cx_root INTO o_cx_root.
      v_msg_erro = o_cx_root->get_text( ).
      RAISE EXCEPTION TYPE ycx_ecc EXPORTING msg = v_msg_erro.
  ENDTRY.

ENDMETHOD.
