*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                     *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : GET_TEMPO_CONEXAO                                         *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Verifica há quanto tempo o usuário está conectado         *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_USUARIO	TYPE SY-UNAME

METHOD get_tempo_conexao.
  TRY.

*----------------------------------------------------------------------*
*     Variáveis
*----------------------------------------------------------------------*
      DATA:
         v_msg_erro     TYPE string        ,
         w_login        TYPE yapt002       ,
         v_hora_login   TYPE sy-uzeit      ,
         v_data_login   TYPE sy-datum      ,
         v_hora_limite  TYPE sy-uzeit      ,
         v_data_limite  TYPE sy-datum      ,
         v_data_expirou TYPE c LENGTH 10   ,
         v_hora_expirou TYPE c LENGTH 08   ,
         v_qtd_segundos TYPE p             ,
         o_cx_apo       TYPE REF TO ycx_apo.

*----------------------------------------------------------------------*
*     Início
*----------------------------------------------------------------------*

      w_login = get_hora_login_usuario( im_usuario ).

      REPLACE ALL OCCURRENCES OF ':' IN w_login-hora WITH space.
      CONDENSE w_login-hora NO-GAPS.

      v_hora_login = w_login-hora.

      REPLACE ALL OCCURRENCES OF '.' IN w_login-data WITH space.
      CONDENSE w_login-data NO-GAPS.

      CONCATENATE w_login-data+4
                  w_login-data+2(2)
                  w_login-data+0(2)
             INTO v_data_login.

*     qtd_segundos = qtd_minutos * 60 segundos
      v_qtd_segundos = 20 * 60.

      CALL FUNCTION 'C14Z_CALC_DATE_TIME'
        EXPORTING
          i_add_seconds = v_qtd_segundos
          i_uzeit       = v_hora_login
          i_datum       = v_data_login
        IMPORTING
          e_datum       = v_data_limite
          e_uzeit       = v_hora_limite.

      IF sy-uzeit > v_hora_limite
        OR sy-datum <> v_data_limite.

        WRITE v_data_limite TO v_data_expirou DD/MM/YYYY                .
        WRITE v_hora_limite TO v_hora_expirou USING EDIT MASK '__:__:__'.

*       Sessão expirou às & do dia &
        MESSAGE e018(yapo) INTO v_msg_erro WITH v_hora_expirou v_data_expirou .
        RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
      ENDIF.

    CATCH ycx_apo INTO o_cx_apo.
      v_msg_erro = o_cx_apo->msg.
      RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDTRY.

ENDMETHOD.