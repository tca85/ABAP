*&---------------------------------------------------------------------*
*&  Include           MYGED_AR_LCL
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Classes                                                              *
*----------------------------------------------------------------------*
CLASS lcl_evento_alv DEFINITION DEFERRED.

*----------------------------------------------------------------------*
*       CLASS lcl_evento_alv DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_evento_alv DEFINITION.
  PUBLIC SECTION.
    METHODS: hotspot_click
     FOR EVENT hotspot_click OF cl_gui_alv_grid
     IMPORTING e_row_id
               e_column_id
               es_row_no.
ENDCLASS.                    "lcl_evento_alv DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_evento_alv IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_evento_alv IMPLEMENTATION.

*---------------------------------------------------------------------*
*       METHOD hotspot_click                                          *
*---------------------------------------------------------------------*
  METHOD hotspot_click.
    PERFORM event_hotspot_click
      USING e_row_id
            e_column_id.
  ENDMETHOD.                    "hotspot_click
ENDCLASS.                    "lcl_evento_alv IMPLEMENTATION

*----------------------------------------------------------------------*
* Objetos                                                              *
*----------------------------------------------------------------------*
DATA:
  obj_evt  TYPE REF TO lcl_evento_alv.