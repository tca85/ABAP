*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Save text object                                        *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD read_text_object.

  DATA:
    lt_tline TYPE STANDARD TABLE OF tline.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      object    = is_header-tdobject
      name      = is_header-tdname
      id        = is_header-tdid
      language  = is_header-tdspras
      local_cat = ' '
    TABLES
      lines     = lt_tline.

  ev_message = me->convert_tline_to_string( lt_tline ).

ENDMETHOD.
