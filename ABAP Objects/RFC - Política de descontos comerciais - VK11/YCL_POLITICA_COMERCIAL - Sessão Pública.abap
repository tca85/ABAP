*----------------------------------------------------------------------*
*       CLASS YCL_POLITICA_COMERCIAL  DEFINITIO
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS ycl_politica_comercial DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

*"* public components of class YCL_POLITICA_COMERCIAL
*"* do not include other source files here!!!
  PUBLIC SECTION.

    TYPES:
      tp_946 TYPE STANDARD TABLE OF y946 WITH DEFAULT KEY .
    TYPES:
      tp_947 TYPE STANDARD TABLE OF y947 WITH DEFAULT KEY .
    TYPES:
      tp_960 TYPE STANDARD TABLE OF y960 WITH DEFAULT KEY .
    TYPES:
      tp_961 TYPE STANDARD TABLE OF y961 WITH DEFAULT KEY .
    TYPES:
      tp_962 TYPE STANDARD TABLE OF y962 WITH DEFAULT KEY .
    TYPES:
      tp_963 TYPE STANDARD TABLE OF y963 WITH DEFAULT KEY .
    TYPES:
      tp_968 TYPE STANDARD TABLE OF y968 WITH DEFAULT KEY .
    TYPES:
      tp_969 TYPE STANDARD TABLE OF y969 WITH DEFAULT KEY .
    TYPES:
      tp_972 TYPE STANDARD TABLE OF y972 WITH DEFAULT KEY .
    TYPES:
      tp_retorno_bapi TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY .

    METHODS excluir_politica_comercial
      IMPORTING
        !im_t_politica_comercial TYPE yct_politica_comercial .
    CLASS-METHODS get_instance
      RETURNING
        value(ex_instancia) TYPE REF TO ycl_politica_comercial
      RAISING
        ycx_pc .
    METHODS get_msg_retorno
      RETURNING
        value(ex_t_msg_retorno) TYPE yct_mensagens
      RAISING
        ycx_pc .
    METHODS set_chave_a946
      IMPORTING
        !im_t_946 TYPE tp_946 OPTIONAL
      RAISING
        ycx_pc .
    METHODS set_chave_a947
      IMPORTING
        !im_t_947 TYPE tp_947 OPTIONAL
      RAISING
        ycx_pc .
    METHODS set_chave_a960
      IMPORTING
        !im_t_960 TYPE tp_960 OPTIONAL
      RAISING
        ycx_pc .
    METHODS set_chave_a961
      IMPORTING
        !im_t_961 TYPE tp_961 OPTIONAL
      RAISING
        ycx_pc .
    METHODS set_chave_a962
      IMPORTING
        !im_t_962 TYPE tp_962 OPTIONAL
      RAISING
        ycx_pc .
    METHODS set_chave_a963
      IMPORTING
        !im_t_963 TYPE tp_963 OPTIONAL
      RAISING
        ycx_pc .
    METHODS set_chave_a968
      IMPORTING
        !im_t_968 TYPE tp_968 OPTIONAL
      RAISING
        ycx_pc .
    METHODS set_chave_a969
      IMPORTING
        !im_t_969 TYPE tp_969 OPTIONAL .
    METHODS set_chave_a972
      IMPORTING
        !im_t_972 TYPE tp_972 OPTIONAL
      RAISING
        ycx_pc .