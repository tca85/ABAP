*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_ECC                                                   *
* Método   : GET_EMAIL_DESTINATARIO                                    *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obtém o e-mail do destinatário                            *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  09.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_email_destinatario.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_email_cliente     TYPE string        ,
    v_email_cliente_aux TYPE adr6-smtp_addr,
    v_email             TYPE string        ,
    v_msg_erro          TYPE string        ,                "#EC NEEDED
    v_nome_rfc_ecc      TYPE rs38l-name    ,
    v_rfc_destination   TYPE bdbapidst     ,
    v_pdf               TYPE xstring       ,
    v_tamanho_anexo_ecc TYPE i             .

*----------------------------------------------------------------------*
* Variáveis tipo referência
*----------------------------------------------------------------------*
  DATA:
    o_cx_ecc  TYPE REF TO ycx_ecc,
    o_cx_root TYPE REF TO cx_root.

*----------------------------------------------------------------------*
* Work-areas
*----------------------------------------------------------------------*
  DATA:
    w_destinatario TYPE ynfe_destino.

*----------------------------------------------------------------------*
* Contantes
*----------------------------------------------------------------------*
  CONSTANTS:
    c_rfc_ecc TYPE rs38l-name VALUE 'YNFE_EMAIL'.

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
      CALL FUNCTION v_nome_rfc_ecc " YNFE_EMAIL
        DESTINATION v_rfc_destination
        EXPORTING
          docnum                = w_nfe-docnum
          recebedor             = im_recebedor
          transportadora        = im_transportadora
        IMPORTING
          t_destinatario        = t_destinatario
        EXCEPTIONS
          nao_existe            = 1
          communication_failure = 3
          system_failure        = 4
          OTHERS                = 5.

      IF im_email_adicional IS NOT INITIAL.
        w_destinatario-email = im_email_adicional.
        APPEND w_destinatario TO t_destinatario.
      ENDIF.

    CATCH cx_root INTO o_cx_root.
      v_msg_erro = o_cx_root->get_text( ).
  ENDTRY.

ENDMETHOD.