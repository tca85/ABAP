*----------------------------------------------------------------------*
* Classe   : YCL_GKO                                                   *
* Método   : GET_TAGS_CTE                                              *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obtém tags do CT-e                                        *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  10.08.2015  #108147 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_tags_cte.
*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_emit    TYPE STANDARD TABLE OF ty_xml         ,
    t_xml_cte TYPE STANDARD TABLE OF ty_tag_emit_cte,
    t_rfc_cte TYPE STANDARD TABLE OF ty_rfc_cte     .

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_emit    LIKE LINE OF t_emit      ,
    w_xml_cte LIKE LINE OF t_xml_cte   ,
    w_nfe_cte LIKE LINE OF im_t_nfe_cte,
    w_rfc_cte LIKE LINE OF t_rfc_cte   .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  t_emit = me->xml_parser( im_xml        = im_xml
                           im_raiz       = 'emit'
                           im_filho_raiz = 'enderEmit' ).

  APPEND INITIAL LINE TO t_xml_cte.

  LOOP AT t_emit INTO w_emit.
    CASE w_emit-tag.
      WHEN 'CNPJ'.
        w_xml_cte-cnpj = w_emit-valor.
      WHEN 'IE'.
        w_xml_cte-ie = w_emit-valor.
      WHEN 'xNome'.
        w_xml_cte-xnome = w_emit-valor.
      WHEN 'xFant'.
        w_xml_cte-xfant = w_emit-valor.
      WHEN 'xLgr'.
        w_xml_cte-xlgr = w_emit-valor.
      WHEN 'nro'.
        w_xml_cte-nro = w_emit-valor.
      WHEN 'xBairro'.
        w_xml_cte-xbairro = w_emit-valor.
      WHEN 'cMun'.
        w_xml_cte-cmun = w_emit-valor.
      WHEN 'xMun'.
        w_xml_cte-xmun = w_emit-valor.
      WHEN 'CEP'.
        w_xml_cte-cep = w_emit-valor.
      WHEN 'UF'.
        w_xml_cte-uf = w_emit-valor.
      WHEN 'fone'.
        w_xml_cte-fone = w_emit-valor.
    ENDCASE.

    MODIFY t_xml_cte FROM w_xml_cte INDEX 1.
  ENDLOOP.

*  NF-e(s) que estão no CT-e
  LOOP AT im_t_nfe_cte INTO w_nfe_cte.
    READ TABLE t_xml_cte
    INTO w_xml_cte
    INDEX 1.

    CLEAR w_rfc_cte.
    w_rfc_cte-cte     = im_cteid            . " CT-e: chave de acesso de 44 dígitos
    w_rfc_cte-nfe     = w_nfe_cte-access_key. " Chave de acesso de 44 caracteres
    w_rfc_cte-cnpj    = w_xml_cte-cnpj      . " CNPJ do emissor do CT-e
    w_rfc_cte-ie      = w_xml_cte-ie        . " Inscrição Estadual do Emitente
    w_rfc_cte-xnome   = w_xml_cte-xnome     . " CT-e: nome da empresa emitente CT-e
    w_rfc_cte-xfant   = w_xml_cte-xfant     . " Nome Fantasia
    w_rfc_cte-xlgr    = w_xml_cte-xlgr      . " Logradouro
    w_rfc_cte-nro     = w_xml_cte-nro       . " Número
    w_rfc_cte-xbairro = w_xml_cte-xbairro   . " Bairro
    w_rfc_cte-cmun    = w_xml_cte-cmun      . " Código da cidade (emissor)
    w_rfc_cte-xmun    = w_xml_cte-xmun      . " Nome da cidade (emissor)
    w_rfc_cte-cep     = w_xml_cte-cep       . " CEP
    w_rfc_cte-uf      = w_xml_cte-uf        . " Unidade da Federação (UF) do emissor do CT-e
    w_rfc_cte-fone    = w_xml_cte-fone      . " Número do Telefone
    APPEND w_rfc_cte TO ex_t_rfc_cte        .
  ENDLOOP.

  IF t_rfc_cte IS NOT INITIAL.
    ex_t_rfc_cte = t_rfc_cte.
  ENDIF.

ENDMETHOD.