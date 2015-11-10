*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_ECC                                                   *
* Método   : GET_EMAIL_REMETENTE                                       *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obtém o e-mail do remetente                               *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  09.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_email_remetente.
*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_cnpj_emitente TYPE string,
    v_raiz_cnpj     TYPE string,
    v_email_ache    TYPE string,
    v_email_magenta TYPE string.

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
  CONSTANTS:
    c_email_ache_homologacao    TYPE string VALUE 'nfeh@ache.com.br'   , "#EC NOTEXT
    c_email_magenta_homologacao TYPE string VALUE 'nfeh@magenta.com.br', "#EC NOTEXT
    c_email_ache_producao       TYPE string VALUE 'nfe@ache.com.br'    , "#EC NOTEXT
    c_email_magenta_producao    TYPE string VALUE 'nfe@magenta.com.br' . "#EC NOTEXT

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  v_cnpj_emitente = im_chave_acesso+6(14).
  v_raiz_cnpj     = v_cnpj_emitente+0(8) .

  IF sy-sysid = 'NFD'.
    v_email_ache    = c_email_ache_homologacao   .
    v_email_magenta = c_email_magenta_homologacao.
  ELSE.
    v_email_ache    = c_email_ache_producao   .
    v_email_magenta = c_email_magenta_producao.
  ENDIF.

  CASE v_raiz_cnpj.
    WHEN '60659463'
      OR '53162095'
      OR '07863523'.

      ex_email = v_email_ache.

    WHEN '04972463'
      OR '01299251'.
      ex_email = v_email_magenta.

  ENDCASE.

ENDMETHOD.