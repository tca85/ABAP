*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_POLITICA_COMERCIAL                                    *
* Método   : GET_MSG_RETORNO                                           *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Retorno da BAPI                                           *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.06.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*<-- VALUE( EX_T_MSG_RETORNO )  TYPE YCT_MENSAGENS

METHOD get_msg_retorno.
  ex_t_msg_retorno = me->t_msg_retorno.
ENDMETHOD.
