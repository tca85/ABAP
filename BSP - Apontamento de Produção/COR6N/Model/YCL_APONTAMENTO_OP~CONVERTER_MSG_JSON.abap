*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : CONVERTER_MSG_JSON                                        *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Converte a mensagem de sucesso/erro para retornar à view  *
*            no formato Json                                           *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_W_MSG_APP	    TYPE YCL_APTO_OP=>TY_MSG_APP
*<-- RETURNING VALUE( EX_JSON )	TYPE STRING

METHOD converter_msg_json.
  DATA:
    o_json    TYPE REF TO ycl_json,
    w_msg_app LIKE im_w_msg_app.

  w_msg_app = im_w_msg_app.

* Remover aspas simples da mensagem senão ocorre erro quando for gerar o Json
  REPLACE ALL OCCURRENCES OF '''' IN w_msg_app-msg WITH space.

  CREATE OBJECT o_json
    EXPORTING
      DATA = w_msg_app.

  o_json->serialize( ).

  ex_json = o_json->get_data( ).

ENDMETHOD.