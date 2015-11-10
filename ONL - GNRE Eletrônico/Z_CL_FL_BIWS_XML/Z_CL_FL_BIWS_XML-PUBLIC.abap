class Z_CL_FL_BIWS_XML definition
  public
  create public .

*"* public components of class Z_CL_FL_BIWS_XML
*"* do not include other source files here!!!
public section.

  interfaces Z_IF_FL_BIWS_XML .

  data XMLDOCUMENT type ref to CL_XML_DOCUMENT .

  methods XML_FROM_FILE
    importing
      !FILENAME type LOCALFILE .
  methods SETDOM
    importing
      !XMLDOM type ref to CL_XML_DOCUMENT .
  methods GETDOM
    returning
      value(XMLDOM) type ref to CL_XML_DOCUMENT .