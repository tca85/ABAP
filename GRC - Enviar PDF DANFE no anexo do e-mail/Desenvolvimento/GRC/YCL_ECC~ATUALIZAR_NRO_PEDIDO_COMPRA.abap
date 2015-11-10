*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_ECC                                                   *
* Método   : ATUALIZAR_NRO_PEDIDO_COMPRA                               *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Atualizar a tag do número do pedido de compras <xPed>     *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  09.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD atualizar_nro_pedido_compra.
*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_xml_string      TYPE xstring    ,
    v_xml             TYPE string     ,
    v_xped            TYPE c LENGTH 15,
    v_xped_tag        TYPE string     ,
    v_msg_erro        TYPE string     ,                     "#EC NEEDED
    v_nome_rfc_ecc    TYPE rs38l-name ,
    v_rfc_destination TYPE bdbapidst  .

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
    c_rfc_ecc TYPE rs38l-name VALUE 'YNFEXML_RETURN_XPED'.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  IF xped IS NOT INITIAL.
    v_xped = xped.
  ELSE.

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
*       YNFEXML_RETURN_XPED
        CALL FUNCTION v_nome_rfc_ecc
          DESTINATION v_rfc_destination
          EXPORTING
            i_docnum              = w_nfe-docnum
          IMPORTING
            e_xped                = v_xped
          EXCEPTIONS
            communication_failure = 1
            system_failure        = 2.

        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

      CATCH cx_root INTO o_cx_root.
        v_msg_erro = o_cx_root->get_text( ).
    ENDTRY.

  ENDIF.

* Se o xped estiver vazio, não modifica nada no XML
  IF v_xped IS INITIAL.
    RETURN.
  ENDIF.

  v_xml_string = w_nfe-xmlstring.

  CALL FUNCTION '/XNFE/XML_XSTRINGADD'
    CHANGING
      inxstring = v_xml_string.

  CALL FUNCTION '/XNFE/XML_XSTRING2STRING'
    EXPORTING
      inxstring = v_xml_string
    IMPORTING
      outstring = v_xml.

  CONCATENATE '<xPed>' v_xped '</xPed>' INTO v_xped_tag.
  REPLACE ALL OCCURRENCES OF REGEX '<xPed>[0-9|A-Z|a-z]+</xPed>' IN v_xml WITH v_xped_tag.

  CALL FUNCTION '/XNFE/XML_STRING2XSTRING'
    EXPORTING
      instring   = v_xml
    IMPORTING
      outxstring = w_nfe-xmlstring.

ENDMETHOD.