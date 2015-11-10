*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_GRC                                                   *
* Método   : ENVIAR_EMAIL_XML_DANFE                                    *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obtém os destinatários do e-mail da NF-e                  *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  08.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD enviar_email_xml_danfe.
*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
     t_destinatario TYPE STANDARD TABLE OF ty_destinatario,
     t_pdf_danfe    TYPE STANDARD TABLE OF solix          .

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
     v_chave_acesso TYPE j_1b_nfe_access_key_dtel44,
     v_nro_pedido   TYPE bstkd                     .

*----------------------------------------------------------------------*
* Variáveis de referência
*----------------------------------------------------------------------*
  DATA:
     o_cx_grc TYPE REF TO ycx_grc.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  TRY.
      v_chave_acesso = me->get_chave_acesso( im_nro_documento ).

      t_destinatario = me->get_destinatario_email_nfe( im_nro_documento  = im_nro_documento
                                                       im_comprador      = abap_true
                                                       im_transportadora = abap_true ).

      v_nro_pedido = me->get_nro_pedido_cliente( im_nro_documento ).

      t_pdf_danfe = me->get_danfe( im_nro_documento ).

      rt_qtd_email_enviado = me->enviar_dados_grc( im_chave_acesso   = v_chave_acesso
                                                   im_t_destinatario = t_destinatario
                                                   im_t_pdf_danfe    = t_pdf_danfe
                                                   im_nro_pedido     = v_nro_pedido ).

    CATCH ycx_grc INTO o_cx_grc.
      RAISE EXCEPTION TYPE ycx_grc EXPORTING msg = o_cx_grc->msg.
  ENDTRY.

ENDMETHOD.