*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : GET_HORA_LOGIN_USUARIO                                    *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obtém a data/hora do login do usuário                     *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_USUARIO	       TYPE SY-UNAME
*<-- RETURNING VALUE( EX_LOGIN ) TYPE YAPT002

METHOD get_hora_login_usuario.

  DATA: v_msg_erro TYPE string.

  SELECT SINGLE * FROM yapt002
   INTO ex_login
   WHERE uname = im_usuario.

  IF ex_login IS INITIAL.
*   Não há registro de login para o usuário &
    MESSAGE e017(yapo) WITH im_usuario INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.