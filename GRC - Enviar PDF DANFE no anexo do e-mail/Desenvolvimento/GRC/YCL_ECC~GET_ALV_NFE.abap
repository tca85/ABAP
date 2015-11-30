*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                 *
*----------------------------------------------------------------------*
* Classe   : YCL_ECC                                                   *
* Método   : ENVIAR_EMAIL_NFE_DANFE                                    *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Enviar e-mail com XML e DANFE em anexo                    *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  09.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_alv_nfe.
  APPEND LINES OF me->t_alv TO ex_t_alv.
ENDMETHOD.