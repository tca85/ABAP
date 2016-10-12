*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* Método   : INIBIR_CAMPOS_ALV_CARACT                                  *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Inibir campos do search help (f4) das características     *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.11.2015  #135533 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD inibir_campos_alv_caract.
*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
    t_campo_alv TYPE STANDARD TABLE OF ty_campo_alv.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_campo_alv LIKE LINE OF t_campo_alv.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
* Campos que não serão exibidos no ALV no F4
  w_campo_alv-nome = 'KLART'       .
  APPEND w_campo_alv TO t_campo_alv.
  w_campo_alv-nome = 'ATFOR'       .
  APPEND w_campo_alv TO t_campo_alv.
  w_campo_alv-nome = 'ADZHL'       .
  APPEND w_campo_alv TO t_campo_alv.

  APPEND LINES OF t_campo_alv TO ex_t_campo_alv.
ENDMETHOD.