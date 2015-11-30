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

 METHOD get_tags_nfe.
*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
   DATA:
     t_peso_liquido TYPE STANDARD TABLE OF ty_xml,
     t_peso_bruto   TYPE STANDARD TABLE OF ty_xml,
     t_mod_frete    TYPE STANDARD TABLE OF ty_xml.

*----------------------------------------------------------------------*
* Work-Area
*----------------------------------------------------------------------*
   DATA:
     w_peso_liquido LIKE LINE OF t_peso_liquido,
     w_peso_bruto   LIKE LINE OF t_peso_bruto  ,
     w_mod_frete    LIKE LINE OF t_mod_frete   ,
     w_rfc_nfe      LIKE LINE OF t_rfc_nfe     .

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
   DATA:
     v_msg_erro TYPE string.

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
   CONSTANTS:
     c_frete_pelo_destinatario TYPE c LENGTH 01 VALUE 1. " Por conta do destinatário/remetente

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
   IF im_xml_nfe IS INITIAL.
     RETURN.
   ENDIF.

   t_mod_frete = me->xml_parser( im_xml        = im_xml_nfe
                                 im_raiz       = 'infNFe'
                                 im_filho_raiz = 'transp'
                                 im_sub_no     = 'modFrete' ).

   t_peso_liquido = me->xml_parser( im_xml        = im_xml_nfe
                                    im_raiz       = 'transp'
                                    im_filho_raiz = 'vol'
                                    im_sub_no     = 'pesoL' ).

   t_peso_bruto = me->xml_parser( im_xml        = im_xml_nfe
                                  im_raiz       = 'transp'
                                  im_filho_raiz = 'vol'
                                  im_sub_no     = 'pesoB' ).

   READ TABLE t_mod_frete
   INTO w_mod_frete
   INDEX 1.

   IF w_mod_frete-valor <> c_frete_pelo_destinatario.
*    Não é um CT-e contra a empresa xxxxx
     MESSAGE e001(ygko) INTO v_msg_erro.
     RAISE EXCEPTION TYPE ycx_gko EXPORTING msg = v_msg_erro.
   ENDIF.

   READ TABLE t_peso_liquido
   INTO w_peso_liquido
   INDEX 1.

   w_rfc_nfe-pesol = w_peso_liquido-valor.

   READ TABLE t_peso_bruto
   INTO w_peso_bruto
   INDEX 1.

   w_rfc_nfe-pesob = w_peso_bruto-valor.

   APPEND w_rfc_nfe TO t_rfc_nfe.

 ENDMETHOD.