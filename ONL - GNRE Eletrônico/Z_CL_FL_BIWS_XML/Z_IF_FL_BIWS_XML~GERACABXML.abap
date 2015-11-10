method Z_IF_FL_BIWS_XML~GERACABXML.

DATA G_IXML          TYPE REF TO IF_IXML.
DATA G_ENCODING      TYPE REF TO IF_IXML_ENCODING.

* Instancia um objeto do Tipo IF_IXML
G_IXML = CL_IXML=>CREATE( ).

* Informa o tipo do ENCONDING para o objto G_XML
G_ENCODING = G_IXML->CREATE_ENCODING(
             BYTE_ORDER    = 0
             CHARACTER_SET = 'UTF-8' ).

* Cria um  documeto XML
G_DOCUMENT = G_IXML->CREATE_DOCUMENT( ).

* Declaração de cada Elemento do XML
DATA: ROOT       TYPE REF TO IF_IXML_ELEMENT,
      VERDADOS   TYPE REF TO IF_IXML_ELEMENT.

* Tag ROOT
ROOT        = G_DOCUMENT->CREATE_SIMPLE_ELEMENT(
             NAME = 'cabecMsg'
             PARENT = G_DOCUMENT ).

ROOT->SET_ATTRIBUTE( NAME      = 'versao'
                     VALUE     = '1.02' ).

ROOT->SET_ATTRIBUTE( NAME      = 'xsi:schemaLocation'
                     VALUE     = 'http://www.portalfiscal.inf.br/nfe cabecMsg_v1.02.xsd' ).

ROOT->SET_ATTRIBUTE( NAME      = 'xmlns'
                     VALUE     = 'http://www.portalfiscal.inf.br/nfe' ).

ROOT->SET_ATTRIBUTE( NAME      = 'xmlns:xsi'
                     VALUE     = 'http://www.w3.org/2001/XMLSchema-instance' ).

VERDADOS  = G_DOCUMENT->CREATE_SIMPLE_ELEMENT(
            NAME   = 'versaoDados'
            VALUE  = '1.07'
            PARENT = ROOT ).

            CALL METHOD ME->Z_IF_FL_BIWS_XML~PARSEIDOMTOSTRING
              EXPORTING
                XMLIDOM   = G_DOCUMENT
              IMPORTING
                XMLSTRING = XML.
break-point.

endmethod.