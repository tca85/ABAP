*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Read message text (SE75 / Text Object)                  *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD read_message_text.

  DATA:
     ls_header TYPE thead.

  DATA:
     lv_message TYPE string.                                "#EC NEEDED

  IF me->lo_text_object IS BOUND.
    " fill ls_header............
    " ..........................
    " ..........................


    ev_message = me->lo_text_object->read_text_object( ls_header ).

  ELSE.
    MESSAGE e054(zpdr) INTO lv_message. " Error while save message text
    me->lo_log->add_sys_message( abap_false ).
    RETURN.
  ENDIF.

ENDMETHOD.
