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
* ACTHIAGO  09.10.2015  #108147 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD atualizar_status_nfe_ecc.
*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro        TYPE string    ,                      "#EC NEEDED
    v_nome_rfc_ecc    TYPE rs38l-name,
    v_rfc_destination TYPE bdbapidst .

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
    c_rfc_ecc TYPE rs38l-name VALUE 'J_1B_NFE_XML_IN'.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  TRY.
      me->testar_rfc_destination( EXPORTING im_sistema_logico  = w_nfe-logsys         " Sistema lógico
                                            im_nome_rfc_ecc    = c_rfc_ecc            " RFC criada no ECC
                                  CHANGING  ex_nome_rfc_ecc    = v_nome_rfc_ecc       " Confirmação da RFC encontrada
                                            ex_rfc_destination = v_rfc_destination ). " Nome da RFC Destination
    CATCH ycx_ecc INTO o_cx_ecc.
      v_msg_erro = o_cx_ecc->msg.
  ENDTRY.

  IF v_nome_rfc_ecc IS INITIAL.
    RETURN.
  ENDIF.

  TRY.
* Pegar dados da /XNFE/OUTNFEHD, e verificar onde buscar os outros valores que faltam

*      CALL FUNCTION v_nome_rfc_ecc
*        DESTINATION v_rfc_destination
*        EXPORTING
*          i_docnum              = w_nfe-docnum   " Nº documento
*          i_acckey              = w_nfe-id       " Chave de acesso
*          i_authcode            = i_authcode     " Código de autorização
*          i_authdate            = i_authdate     " Data de processamento
*          i_authtime            = i_authtime     " Hora de processamento
*          i_code                = w_nfe-statcod  " NF-e: código de status
*          i_msgtyp              = w_nfe-msgtyp   " Tipo da mensagem de entrada
*          i_event_msgtyp        = i_event_msgtyp " Mensagem do evento
*        EXCEPTIONS
*          inbound_error         = 1
*          communication_failure = 2
*          system_failure        = 3.

*>>>>>>>> essa é a função que o GRC (standard) usa: /XNFE/UPDATE_ERP_STATUS

    CATCH cx_root INTO o_cx_root.
      v_msg_erro = o_cx_root->get_text( ).
  ENDTRY.

ENDMETHOD.