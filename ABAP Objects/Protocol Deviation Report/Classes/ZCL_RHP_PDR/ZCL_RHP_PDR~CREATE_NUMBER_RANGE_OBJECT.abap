*----------------------------------------------------------------------*
* Activity   : PM-ENC-018                                              *
* Author     : Thiago Cordeiro Alves                                   *
* Description: Create a new Number Range Object (T-CODE SNRO)          *
*----------------------------------------------------------------------*
*                     Modification History                             *
*----------------------------------------------------------------------*
* SAP User   Date         Description                                  *
* CORDETHI   20.07.2016   First development                            *
*----------------------------------------------------------------------*

METHOD create_number_range_object.
*----------------------------------------------------------------------*
* Variables
*----------------------------------------------------------------------*
  DATA:
    lv_nr_range    TYPE inri-nrrangenr ,
    lv_return_code TYPE inri-returncode,                    "#EC NEEDED
    lv_msg_error   TYPE string         .                    "#EC NEEDED

*----------------------------------------------------------------------*
* Constants
*----------------------------------------------------------------------*
  CONSTANTS:
    lc_nr_range TYPE inri-nrrangenr VALUE '01'.

*----------------------------------------------------------------------*
* Begin
*----------------------------------------------------------------------*

  lv_nr_range = lc_nr_range.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = lv_nr_range
      object                  = iv_snro_object
    IMPORTING
      number                  = ro_snro
      returncode              = lv_return_code
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
       INTO lv_msg_error.

    me->lo_log->add_sys_message( abap_false ).
  ENDIF.

  IF ro_snro IS INITIAL.
    CASE iv_snro_object.
      WHEN me->lc_snro_pdr_id.
        MESSAGE e011(zpdr) INTO lv_msg_error. " PDR ID creation error
        me->lo_log->add_sys_message( abap_false ).

      WHEN me->lc_snro_hist_id.
        MESSAGE e031(zpdr) INTO lv_msg_error. " PDR History id creation error
        me->lo_log->add_sys_message( abap_false ).
    ENDCASE.
  ENDIF.

ENDMETHOD.
