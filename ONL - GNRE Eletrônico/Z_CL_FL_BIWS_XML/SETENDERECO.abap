method SETENDERECO.

DATA: OBJ_NODOE      TYPE REF TO IF_IXML_NODE,
      OBJ_NODO_LISTE TYPE REF TO IF_IXML_NODE_LIST,
      XML_NODEE      TYPE REF TO IF_IXML_NODE,
      XML_ITERATORE  TYPE REF TO IF_IXML_NODE_ITERATOR,
      NAME           TYPE STRING,
      VALUE          TYPE STRING.

       CALL METHOD ME->GETNODE_WITH_NODE
                  EXPORTING
                    NODE      = XENDE
                  RECEIVING
                    NODELIST = OBJ_NODO_LISTE.

      XML_ITERATORE = OBJ_NODO_LISTE->CREATE_ITERATOR( ).
      XML_NODEE     = XML_ITERATORE->GET_NEXT( ).

      WHILE NOT XML_NODEE IS INITIAL.

            NAME =  XML_NODEE->GET_NAME( ).
            VALUE = XML_NODEE->GET_VALUE( ).

            CASE NAME.

                WHEN 'xLgr'.
                     INFCADEND-XLGR     = VALUE.
                WHEN 'nro'.
                     INFCADEND-NRO      = VALUE.
                WHEN 'xCpl'.
                     INFCADEND-XCPL     = VALUE.
                WHEN 'xBairro'.
                     INFCADEND-XBAIRRO  = VALUE.
                WHEN 'cMun'.
                     INFCADEND-CMUN     = VALUE.
                WHEN 'xMun'.
                     INFCADEND-XMUN     = VALUE.
                WHEN 'CEP'.
                     INFCADEND-CEP      = VALUE.

            ENDCASE.

            XML_NODEE = XML_ITERATORE->GET_NEXT( ).

      ENDWHILE.

endmethod.