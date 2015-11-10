REPORT zteste6.

*&---------------------------------------------------------------------*
*& Report  z_xit_xml_check
*&---------------------------------------------------------------------*  R
*report  z_xit_xml_check.
TYPE-POOLS: ixml.
TYPES: BEGIN OF t_xml_line,
   data(256) TYPE x,
  END OF t_xml_line.
DATA: l_ixml TYPE REF TO if_ixml,
      l_streamfactory   TYPE REF TO if_ixml_stream_factory,
      l_parser          TYPE REF TO if_ixml_parser,
      l_istream         TYPE REF TO if_ixml_istream,
      l_document        TYPE REF TO if_ixml_document,
      l_node            TYPE REF TO if_ixml_node,
      l_xmldata         TYPE string.
DATA: l_elem            TYPE REF TO if_ixml_element,
      l_root_node       TYPE REF TO if_ixml_node,
      l_next_node       TYPE REF TO if_ixml_node,
      l_name            TYPE string,
      l_iterator        TYPE REF TO if_ixml_node_iterator.
DATA: l_xml_table       TYPE TABLE OF t_xml_line,
      l_xml_line        TYPE t_xml_line,
      l_xml_table_size  TYPE i.
DATA: l_filename        TYPE string.
PARAMETERS: pa_file TYPE rlgrap-filename DEFAULT 'D:\temp\*.xml'. "char1024 DEFAULT 'D:\temp\'.
* Validation of XML file: Only DTD included in xml document is supported

PARAMETERS: pa_val  TYPE char1 AS CHECKBOX.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_file.
  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
      mask      = '*.xml,*.XML'
      static    = 'X'
    CHANGING
      file_name = pa_file.


START-OF-SELECTION.
*   Creating the main iXML factory
  l_ixml = cl_ixml=>create( ).
*   Creating a stream factory
  l_streamfactory = l_ixml->create_stream_factory( ).
  PERFORM get_xml_table CHANGING l_xml_table_size l_xml_table.
*   wrap the table containing the file into a stream
  l_istream = l_streamfactory->create_istream_itable( table = l_xml_table
      size  = l_xml_table_size ).
*   Creating a document
  l_document = l_ixml->create_document( ).
*   Create a Parser
  l_parser = l_ixml->create_parser( stream_factory = l_streamfactory
  istream        = l_istream
  document       = l_document ).
*   Validate a document
  IF pa_val EQ 'X'.
    l_parser->set_validating( mode = if_ixml_parser=>co_validate ).
  ENDIF.
*   Parse the stream
  IF l_parser->parse( ) NE 0.
    IF l_parser->num_errors( ) NE 0.
      DATA: parseerror TYPE REF TO if_ixml_parse_error,
            str        TYPE string,
            i          TYPE i,
            count      TYPE i,
            index      TYPE i.
      count = l_parser->num_errors( ).
      WRITE: count, ' parse errors have occured:'.
      index = 0.
      WHILE index < count.
        parseerror = l_parser->get_error( index = index ).
        i = parseerror->get_line( ).
        WRITE: 'line: ', i.
        i = parseerror->get_column( ).
        WRITE: 'column: ', i.
        str = parseerror->get_reason( ).
        WRITE: str.
        index = index + 1.
      ENDWHILE.
    ENDIF.
  ENDIF.
*   Process the document
  IF l_parser->is_dom_generating( ) EQ 'X'.
    PERFORM process_dom USING l_document.
  ENDIF.
*&--------------------------------------------------------------------*
*&   Form  get_xml_table
*&--------------------------------------------------------------------*
FORM get_xml_table CHANGING l_xml_table_size TYPE i
  l_xml_table      TYPE STANDARD TABLE.
*   Local variable declaration
  DATA: l_len      TYPE i,
        l_len2     TYPE i,
        l_tab      TYPE tsfixml,
        l_content  TYPE string,
        l_str1     TYPE string,
        c_conv     TYPE REF TO cl_abap_conv_in_ce,
        l_itab     TYPE TABLE OF string.
  l_filename = pa_file.
*   upload a file from the client's workstation
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename   = l_filename
      filetype   = 'BIN'
    IMPORTING
      filelength = l_xml_table_size
    CHANGING
      data_tab   = l_xml_table
    EXCEPTIONS
      OTHERS     = 19.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*   Writing the XML document to the screen
  CLEAR l_str1.
  LOOP AT l_xml_table INTO l_xml_line.
    c_conv = cl_abap_conv_in_ce=>create( input = l_xml_line-data replacement = space  ).
    c_conv->read( IMPORTING data = l_content len = l_len ).
    CONCATENATE l_str1 l_content INTO l_str1.
  ENDLOOP.
  l_str1 = l_str1+0(l_xml_table_size).
  SPLIT l_str1 AT cl_abap_char_utilities=>cr_lf INTO TABLE l_itab.
  WRITE: /.
  WRITE: /' XML File'.
  WRITE: /.
  LOOP AT l_itab INTO l_str1.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>horizontal_tab IN        l_str1 WITH space.
    WRITE: / l_str1.
  ENDLOOP.
  WRITE: /.
ENDFORM.                    "get_xml_table
"get_xml_table
*&--------------------------------------------------------------------*
*&      Form  process_dom
*&--------------------------------------------------------------------*
FORM process_dom USING document TYPE REF TO if_ixml_document.
  DATA: node      TYPE REF TO if_ixml_node,
        iterator  TYPE REF TO if_ixml_node_iterator,
        nodemap   TYPE REF TO if_ixml_named_node_map,
        attr      TYPE REF TO if_ixml_node,
        name      TYPE string,
        prefix    TYPE string,
        value     TYPE string,
        indent    TYPE i,
        count     TYPE i,
        index     TYPE i.
  node ?= document.
  CHECK NOT node IS INITIAL.
  ULINE.
  WRITE: /.
  WRITE: /' DOM-TREE'.
  WRITE: /.
  IF node IS INITIAL.
    EXIT.
  ENDIF.
*   create a node iterator
  iterator  = node->create_iterator( ).
*   get current node
  node = iterator->get_next( ).
*   loop over all nodes
  WHILE NOT node IS INITIAL.
    indent = node->get_height( ) * 2.
    indent = indent + 20.
    CASE node->get_type( ).
      WHEN if_ixml_node=>co_node_element.
*         element node
        name    = node->get_name( ).
        nodemap = node->get_attributes( ).
        WRITE: / 'ELEMENT  :'.
        WRITE: AT indent name COLOR COL_POSITIVE INVERSE.
        IF NOT nodemap IS INITIAL.
*           attributes
          count = nodemap->get_length( ).
          DO count TIMES.
            index  = sy-index - 1.
            attr   = nodemap->get_item( index ).
            name   = attr->get_name( ).
            prefix = attr->get_namespace_prefix( ).
            value  = attr->get_value( ).
            WRITE: / 'ATTRIBUTE:'.
            WRITE: AT indent name  COLOR COL_HEADING INVERSE, '=',
            value COLOR COL_TOTAL   INVERSE.
          ENDDO.
        ENDIF.
      WHEN if_ixml_node=>co_node_text OR             if_ixml_node=>co_node_cdata_section.
*         text node
        value  = node->get_value( ).
        WRITE: / 'VALUE     :'.
        WRITE: AT indent value COLOR COL_GROUP INVERSE.
    ENDCASE.
*     advance to next node
    node = iterator->get_next( ).
  ENDWHILE.
ENDFORM.                    "process_dom