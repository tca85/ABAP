method SETINFCAD.

DATA AUX TYPE STRING.

* Informações de cadastros pode ter 0 - N
DATA: OBJ_NODO      TYPE REF TO IF_IXML_NODE,
      OBJ_NODO_LIST TYPE REF TO IF_IXML_NODE_LIST,
      XML_NODE      TYPE REF TO IF_IXML_NODE,
      XML_ITERATOR  TYPE REF TO IF_IXML_NODE_ITERATOR,
      NAME          TYPE STRING,
      VALUE         TYPE STRING,
      TAB           TYPE ZTBFLBIWSINFCAD.


      CALL METHOD ME->GETNODE_WITH_NODE
                  EXPORTING
                    NODE      = INFCAD
                  RECEIVING
                    NODELIST = OBJ_NODO_LIST.

      XML_ITERATOR = OBJ_NODO_LIST->CREATE_ITERATOR( ).
      XML_NODE     = XML_ITERATOR->GET_NEXT( ).

      WHILE NOT XML_NODE IS INITIAL.

            NAME =  XML_NODE->GET_NAME( ).
            VALUE = XML_NODE->GET_VALUE( ).

            CASE NAME.

                 WHEN 'IE'.
                       ZTBINFCAD-IE       = VALUE.
                 WHEN 'CNPJ'.
                       ZTBINFCAD-CNPJ     = VALUE.
                 WHEN 'UF'.
                       ZTBINFCAD-UF       = VALUE.
                 WHEN 'cSit'.
                       ZTBINFCAD-CSIT     = VALUE.
                 WHEN 'xNome'.
                       ZTBINFCAD-XNOME    = VALUE.
                 WHEN 'xFant'.
                       ZTBINFCAD-XFANT    = VALUE.
                 WHEN 'xRegApur'.
                       ZTBINFCAD-XREGAPUR = VALUE.
                 WHEN 'CNAE'.
                       ZTBINFCAD-CNAE     = VALUE.
                 WHEN 'dIniAtiv'.
                       AUX = VALUE.
                       REPLACE ALL OCCURRENCES OF  '-' IN AUX WITH SPACE.
                       ZTBINFCAD-DINIATIV = AUX.
                 WHEN 'dUltSit'.
                       AUX = VALUE.
                       REPLACE ALL OCCURRENCES OF  '-' IN AUX WITH SPACE.
                       ZTBINFCAD-DULTATIV = AUX.
                 WHEN 'dBaixa'.
                       AUX = VALUE.
                       REPLACE ALL OCCURRENCES OF  '-' IN AUX WITH SPACE.
                       ZTBINFCAD-DBAIXA   = AUX.
                 WHEN 'IEUnica'.
                       ZTBINFCAD-IEUNICA  = VALUE.
                 WHEN 'IEAtual'.
                       ZTBINFCAD-IEATUAL  = VALUE.
                 WHEN 'ender'.

                       CALL METHOD ME->SETENDERECO
                         EXPORTING
                           XENDE     = XML_NODE
                         CHANGING
                           INFCADEND = ZTBINFCAD.

             ENDCASE.
         XML_NODE = XML_ITERATOR->GET_NEXT( ).
      ENDWHILE.
endmethod.