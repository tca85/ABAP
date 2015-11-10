METHOD Z_IF_FL_BIWS_XML~PARSEIDOMTOSTRING.

  DATA IXML          TYPE REF TO IF_IXML.
  DATA STREAMFACTORY TYPE REF TO IF_IXML_STREAM_FACTORY.
  DATA OUTPUTSTREAM  TYPE REF TO IF_IXML_OSTREAM.
  DATA RENDERER      TYPE REF TO IF_IXML_RENDERER.
  DATA TEMPSTRING    TYPE STRING.
  DATA RC            TYPE SYSUBRC.

  IXML          = CL_IXML=>CREATE( ).
  STREAMFACTORY = IXML->CREATE_STREAM_FACTORY( ).
  OUTPUTSTREAM  = STREAMFACTORY->CREATE_OSTREAM_CSTRING( TEMPSTRING ).
  RENDERER      = IXML->CREATE_RENDERER(  DOCUMENT      = XMLIDOM
                                          OSTREAM = OUTPUTSTREAM ).
  RENDERER->SET_NORMALIZING( ).
  RC            = RENDERER->RENDER( ).

  WHILE TEMPSTRING(1) <> '<'.
      SHIFT TEMPSTRING LEFT BY 1 PLACES.
  ENDWHILE.

  XMLSTRING = TEMPSTRING.

ENDMETHOD.