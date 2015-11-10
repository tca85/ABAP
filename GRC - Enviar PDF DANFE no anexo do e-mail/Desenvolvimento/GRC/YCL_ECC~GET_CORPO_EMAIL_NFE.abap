*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_ECC                                                   *
* Método   : GET_CORPO_EMAIL_NFE                                       *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obter corpo do e-mail da NF-e                             *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  09.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_corpo_email_nfe.
*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_corpo_email LIKE LINE OF t_corpo_email.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_nr_nfe TYPE c LENGTH 9.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  APPEND 'Segue anexo o arquivo XML da Nota Fiscal eletrônica.' TO t_corpo_email. "#EC NOTEXT
  APPEND INITIAL LINE TO t_corpo_email      .

  CLEAR v_nr_nfe.
  v_nr_nfe = w_nfe-nnf.
  SHIFT v_nr_nfe LEFT DELETING LEADING '0'.

  CONCATENATE 'NF-e: ' v_nr_nfe 'Série: ' w_nfe-serie INTO w_corpo_email RESPECTING BLANKS. "#EC NOTEXT
  APPEND w_corpo_email TO t_corpo_email     .

  CONCATENATE 'Data de emissão: ' w_nfe-dhemi+4(2) '/' w_nfe-dhemi(4) INTO w_corpo_email RESPECTING BLANKS. "#EC NOTEXT
  APPEND w_corpo_email TO t_corpo_email     .

  CONCATENATE 'Chave de acesso: ' w_nfe-id INTO w_corpo_email RESPECTING BLANKS. "#EC NOTEXT
  APPEND w_corpo_email TO t_corpo_email     .

  APPEND INITIAL LINE TO t_corpo_email      .

  APPEND 'Para efetuar a consulta da sua NF-e acesse o link abaixo:' TO t_corpo_email. "#EC NOTEXT
  APPEND 'http://www.nfe.fazenda.gov.br/PORTAL/Default.aspx ' TO t_corpo_email. "#EC NOTEXT
  APPEND INITIAL LINE TO t_corpo_email      .

  APPEND 'Se você utiliza um filtro de e-mail ou um bloqueador de SPAM, o Aché recomenda que você adicione o domínio "ache.com.br" à sua lista de remetentes seguros.' TO t_corpo_email. "#EC NOTEXT
  APPEND INITIAL LINE TO t_corpo_email      .

  APPEND 'Envio de e-mail automático, favor não responder.' TO t_corpo_email. "#EC NOTEXT
  APPEND INITIAL LINE TO t_corpo_email      .

  APPEND 'Atenciosamente, ' TO t_corpo_email.               "#EC NOTEXT
  APPEND INITIAL LINE TO t_corpo_email      .
  APPEND w_nfe-emit TO t_corpo_email        .

ENDMETHOD.