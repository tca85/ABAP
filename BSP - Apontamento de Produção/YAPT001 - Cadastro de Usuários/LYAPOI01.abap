*----------------------------------------------------------------------*
***INCLUDE LYAPOI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CARREGAR_SH_RECURSOS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE carregar_sh_recursos INPUT.

  DATA: o_apo TYPE REF TO ycl_bsp_model_apo.

  CREATE OBJECT o_apo.

  yapt001-arbpl = o_apo->get_search_help_recursos(  ).

ENDMODULE.                 " CARREGAR_SH_RECURSOS  INPUT