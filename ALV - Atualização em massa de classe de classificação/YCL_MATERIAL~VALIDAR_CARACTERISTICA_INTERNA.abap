*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* Método   : VALIDAR_CARACTERISTICA_INTERNA                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Validar característica interna x Tipo de classe           *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  16.09.2015  #121646 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD validar_caracteristica_interna.
*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
    t_caracteristica TYPE STANDARD TABLE OF ty_caracteristica.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
     v_msg_erro TYPE string.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  IF me->t_caracteristicas IS INITIAL
    AND im_caracteristica IS INITIAL.
*   Selecione a característica interna
    MESSAGE e005(ymaterial) WITH c_classe_material INTO v_msg_erro. "#EC *
    RAISE EXCEPTION TYPE ycx_material EXPORTING msg = v_msg_erro.
  ENDIF.

  FREE me->t_caracteristicas.

  t_caracteristica = me->get_caracteristicas_internas( im_classe_material = im_classe_material
                                                       im_caracteristica  = im_caracteristica ).

  IF t_caracteristica IS NOT INITIAL.
    APPEND LINES OF t_caracteristica TO me->t_caracteristicas.
  ELSE.
*   A característica interna selecionada não pertence ao tipo de classe
    MESSAGE e006(ymaterial) WITH c_classe_material INTO v_msg_erro. "#EC *
    RAISE EXCEPTION TYPE ycx_material EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.