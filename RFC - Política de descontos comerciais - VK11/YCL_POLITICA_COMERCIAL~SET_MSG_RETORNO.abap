*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_POLITICA_COMERCIAL                                    *
* Método   : SET_MSG_RETORNO                                           *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Agrupa o retorno da BAPI                                  *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.06.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IM_ID_MODIFICACAO  TYPE Y946-ID
*--> IM_T_RETORNO_BAPI  TYPE TP_RETORNO_BAPI

METHOD set_msg_retorno.
  DATA:
     w_retorno_bapi LIKE LINE OF im_t_retorno_bapi,
     w_msg_retorno  TYPE ymensagens               .

  LOOP AT im_t_retorno_bapi INTO w_retorno_bapi       .
    CLEAR w_msg_retorno                               .
    w_msg_retorno-id       = im_id_modificacao        .
    w_msg_retorno-tipo     = w_retorno_bapi-type      .
    w_msg_retorno-id_sap   = w_retorno_bapi-message_v1.
    w_msg_retorno-mensagem = w_retorno_bapi-message   .
    APPEND w_msg_retorno TO me->t_msg_retorno         .
  ENDLOOP.

ENDMETHOD.
