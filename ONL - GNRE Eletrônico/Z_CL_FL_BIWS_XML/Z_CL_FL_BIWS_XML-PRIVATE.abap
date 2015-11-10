*"* private components of class Z_CL_FL_BIWS_XML
*"* do not include other source files here!!!
private section.

  data G_DOCUMENT type ref to IF_IXML_DOCUMENT .

  methods GETTAG
    importing
      !TAG type STRING
    returning
      value(VALOR) type STRING .
  methods GETNODE_WITH_NODE
    importing
      !NODE type ref to IF_IXML_NODE
    returning
      value(NODELIST) type ref to IF_IXML_NODE_LIST .
  methods GETNODE
    importing
      !TAG type STRING
    returning
      value(NODELIST) type ref to IF_IXML_NODE_LIST .
  methods GETFILHOS
    importing
      !NODE type ref to IF_IXML_NODE .
  methods SETENDERECO
    importing
      !XENDE type ref to IF_IXML_NODE
    changing
      !INFCADEND type ZTBFLBIWSINFCAD .
  methods SETINFCAD
    importing
      !INFCAD type ref to IF_IXML_NODE
    changing
      !ZTBINFCAD type ZTBFLBIWSINFCAD .