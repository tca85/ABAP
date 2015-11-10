FUNCTION ynfe_enviar_xml_email.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(CHAVE_ACESSO) TYPE  /XNFE/ID
*"     VALUE(T_PDF_BINARIO) TYPE  SOLIX_TAB OPTIONAL
*"     VALUE(NRO_PEDIDO) TYPE  BSTKD OPTIONAL
*"     VALUE(T_DESTINATARIO) TYPE  YNFE_CT_DESTINO OPTIONAL
*"     VALUE(RECEBEDOR) TYPE  CHAR1 OPTIONAL
*"     VALUE(TRANSPORTADORA) TYPE  CHAR1 OPTIONAL
*"  EXPORTING
*"     VALUE(QTD_EMAILS_ENVIADOS) TYPE  SY-TABIX
*"  EXCEPTIONS
*"      ERRO_ENVIO
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*                Aché Laboratórios Farmacêuticos S.A                   *
*----------------------------------------------------------------------*
* Módulo de Função : YNFE_ENVIAR_XML_EMAIL                             *
* Grupo de Funções : YNFE                                              *
*----------------------------------------------------------------------*
* Descrição: RFC para enviar XML e PDF (DANFE) por e-mail              *
*            --- essa RFC também é chamada pela J1BNFE do ECC ---      *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  09.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Variáveis tipo referência
*----------------------------------------------------------------------*
  DATA:
    o_ecc    TYPE REF TO ycl_ecc,
    o_cx_ecc TYPE REF TO ycx_ecc.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro TYPE string.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  IF chave_acesso IS INITIAL.
    EXIT.
  ENDIF.

  TRY.
      CREATE OBJECT o_ecc TYPE ycl_ecc.

      o_ecc->get_xml_nfe( im_chave_acesso = chave_acesso ).

      qtd_emails_enviados = o_ecc->enviar_email_nfe_danfe( im_t_pdf_binario  = t_pdf_binario
                                                           im_t_destinatario = t_destinatario
                                                           im_nro_pedido     = nro_pedido
                                                           im_recebedor      = recebedor
                                                           im_transportadora = transportadora ).
    CATCH ycx_ecc INTO o_cx_ecc.
      v_msg_erro = o_cx_ecc->msg.

      MESSAGE e398(00) WITH v_msg_erro RAISING erro_envio.
      EXIT.
  ENDTRY.

ENDFUNCTION.