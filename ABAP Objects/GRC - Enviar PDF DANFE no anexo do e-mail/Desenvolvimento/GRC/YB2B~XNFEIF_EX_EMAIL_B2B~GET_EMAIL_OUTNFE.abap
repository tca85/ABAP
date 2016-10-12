*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* BAdI         : SE18 - /XNFE/EMAIL_B2B                                *
* Interface    : SE24 - /XNFE/IF_EX_EMAIL_B2B                          *
* Implementação: SE19 - YB2B                                           *
* Classe       : SE24 - YB2B                                           *
* Descrição    : BAdI para ampliação do cliente para determinação      *
*                de e-mail para mensagens B2B                          *
*----------------------------------------------------------------------*
* Método       : GET_EMAIL_OUTNFE                                      *
* Descrição    : Determinar endereço de e-mail para NF-e de saída 3.10 *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome       Data         Descrição                                    *
* FLUDERSON  27.04.2015  #****** - Desenvolvimento inicial             *
* ACTHIAGO   09.10.2015  #109075 - Enviar e-mail com DANFE + XML       *
*----------------------------------------------------------------------*

METHOD /xnfe/if_ex_email_b2b~get_email_outnfe.

*  CALL FUNCTION 'Z_BUSCA_EMAIL'
*    EXPORTING
*      i_chave = is_outnfehd-id
*    IMPORTING
*      email   = ev_commparam.

  DATA:
    v_qtd_enviado    TYPE sy-tabix   ,
    v_msg_erro       TYPE string     ,
    v_recebedor      TYPE c LENGTH 01,
    v_transportadora TYPE c LENGTH 01.

* Cenário B2B (quem receberá o e-mail)
  CASE iv_scenario.
    WHEN 'BUYER'.
      v_recebedor = abap_true.
    WHEN 'CARRIER'.
      v_transportadora = abap_true.
  ENDCASE.

  CALL FUNCTION 'YNFE_ENVIAR_XML_EMAIL'
    EXPORTING
      chave_acesso        = is_outnfehd-id
      recebedor           = v_recebedor
      transportadora      = v_transportadora
    IMPORTING
      qtd_emails_enviados = v_qtd_enviado
    EXCEPTIONS
      erro_envio          = 1
      OTHERS              = 2.

  IF sy-subrc <> 0.
    v_msg_erro = sy-msgv1.
  ENDIF.

ENDMETHOD.