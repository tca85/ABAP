METHOD Z_IF_FL_BIWS_XML~PARSETOTABLE.

DATA VALOR TYPE STRING.
DATA NAME  TYPE STRING.
DATA VALUE TYPE STRING.
DATA AUX   TYPE STRING.

DATA WK_INFCAD TYPE ZTBFLBIWSINFCAD.
DATA INFCAD    TYPE TABLE OF ZTBFLBIWSINFCAD.

*FIELD-SYMBOLS: <WK_INFCAD> TYPE ANY.
*               ASSIGN WK_INFCAD TO <WK_INFCAD>.

DATA: OBJ_NODOR      TYPE REF TO IF_IXML_NODE,
      OBJ_NODO_LISTR TYPE REF TO IF_IXML_NODE_LIST,
      XML_NODER      TYPE REF TO IF_IXML_NODE,
      XML_ITERATORR  TYPE REF TO IF_IXML_NODE_ITERATOR.

      CALL METHOD ME->GETNODE
        EXPORTING
          TAG      = 'infCons'
        RECEIVING
          NODELIST = OBJ_NODO_LISTR.

      XML_ITERATORR = OBJ_NODO_LISTR->CREATE_ITERATOR( ).
      XML_NODER     = XML_ITERATORR->GET_NEXT( ).

      WHILE NOT XML_NODER IS INITIAL.

            NAME =  XML_NODER->GET_NAME( ).
            VALUE = XML_NODER->GET_VALUE( ).

            CASE NAME.

                  WHEN 'cStat'.
                        TBCOMP-CODSTAT = VALUE.
                  WHEN 'xMotivo'.
                        TBCOMP-MOTIVO  = VALUE.
                  WHEN 'cUF'.
                        TBCOMP-UF      = VALUE.
                  WHEN 'IE'.
                        TBCOMP-IE      = VALUE.
                  WHEN 'CNPJ'.
                        TBCOMP-CNPJ    = VALUE.
                  WHEN 'CPF'.
                        TBCOMP-CPF     = VALUE.
                  WHEN 'dhCons'.
                      AUX = VALUE(12).
                      REPLACE ALL OCCURRENCES OF  '-' IN AUX WITH SPACE.
                      TBCOMP-DHCONS    = AUX.
                      REPLACE ALL OCCURRENCES OF  '-' IN AUX WITH SPACE.
                      AUX = VALUE+12.
                      REPLACE ALL OCCURRENCES OF  '-' IN AUX WITH SPACE.
                      TBCOMP-HDCONS    = AUX.
                 WHEN 'infCad'.

                       CALL METHOD ME->SETINFCAD
                         EXPORTING
                           INFCAD    = XML_NODER
                         CHANGING
                           ZTBINFCAD = WK_INFCAD.

                           APPEND WK_INFCAD TO INFCAD.

             ENDCASE.

             XML_NODER = XML_ITERATORR->GET_NEXT( ).
      ENDWHILE.
      TBINF = INFCAD.
ENDMETHOD.