*----------------------------------------------------------------------*
*       CLASS YCL_CONTROLLER_APONTAMENTO_OP  DEFINITIO
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS ycl_controller_apontamento_op DEFINITION
  PUBLIC
  INHERITING FROM cl_bsp_controller2
  FINAL
  CREATE PUBLIC .

*"* public components of class YCL_CONTROLLER_APONTAMENTO_OP
*"* do not include other source files here!!!
  PUBLIC SECTION.

    METHODS do_init
      REDEFINITION .
    METHODS do_request
      REDEFINITION .