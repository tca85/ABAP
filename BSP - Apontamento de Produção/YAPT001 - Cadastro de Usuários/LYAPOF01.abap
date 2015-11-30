*----------------------------------------------------------------------*
***INCLUDE LYAPOF01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  f_validar_recurso
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_validar_recurso.
  DATA:
     o_apo     TYPE REF TO ycl_bsp_model_apo,
     o_cx_root TYPE REF TO cx_root          .

  DATA:
    v_msg_erro TYPE string.

  TRY.
      CREATE OBJECT o_apo.

      o_apo->validar_recurso( CHANGING ex_recurso = yapt001-arbpl ).

      o_apo->validar_centro_recurso( EXPORTING im_recurso = yapt001-arbpl
                                      CHANGING ex_centro = yapt001-werks ).

    CATCH cx_root INTO o_cx_root.
      CLEAR yapt001.

      v_msg_erro = o_cx_root->get_longtext( ).

      MESSAGE v_msg_erro TYPE 'E'.
  ENDTRY.

ENDFORM.                    "f_get_recursos