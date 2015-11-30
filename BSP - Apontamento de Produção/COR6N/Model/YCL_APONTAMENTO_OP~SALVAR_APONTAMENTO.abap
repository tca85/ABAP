*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                     *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : SALVAR_APONTAMENTO                                        *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obtém os campos da divModalApontamento (view Apontar)     *
*            para salvar o apontamento parcial ou final da o.p         *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_TIPO_APTO	TYPE STRING
*<-- RETURNING VALUE( EX_MSG_RETORNO )  TYPE STRING

METHOD salvar_apontamento.

*----------------------------------------------------------------------*
*  Tabelas internas
*----------------------------------------------------------------------*
  DATA:
    t_folha_tempos TYPE STANDARD TABLE OF bapi_pi_timeticket1,
    t_retorno      TYPE STANDARD TABLE OF bapi_coru_return   .

*----------------------------------------------------------------------*
*  Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_apontamento  TYPE ty_apontamento     ,
    w_permissao    TYPE ty_permissao       ,                "#EC NEEDED
    w_msg_app      TYPE ty_msg_app         ,
    w_return       TYPE bapiret1           ,                "#EC NEEDED
    w_return2      TYPE bapiret2           ,                "#EC NEEDED
    w_retorno      TYPE bapi_coru_return   ,
    w_folha_tempos TYPE bapi_pi_timeticket1.

*----------------------------------------------------------------------*
*  Objetos
*----------------------------------------------------------------------*
  DATA:
    o_cx_apo TYPE REF TO ycx_apo.

*----------------------------------------------------------------------*
*  Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro TYPE string.

*----------------------------------------------------------------------*
*  Constantes
*----------------------------------------------------------------------*
  CONSTANTS:
     c_unidade_medida_hora TYPE t006-msehi VALUE 'H'.

*----------------------------------------------------------------------*
*  Início
*----------------------------------------------------------------------*
  TRY.
      w_apontamento = get_w_apontamento( ).

      CASE im_tipo_apto.
        WHEN me->c_confirmacao_parcial.
          w_permissao = get_permissoes_usuario( im_usuario      = sy-uname
                                                im_centro       = w_apontamento-centro
                                                im_recurso      = w_apontamento-recurso
                                                im_apto_parcial = abap_true ).

          w_folha_tempos-fin_conf = space. " Confirmação parcial

        WHEN me->c_confirmacao_final.
          w_permissao = get_permissoes_usuario( im_usuario    = sy-uname
                                                im_centro     = w_apontamento-centro
                                                im_recurso    = w_apontamento-recurso
                                                im_apto_final = abap_true ).

          w_folha_tempos-fin_conf = abap_true. " Confirmação final
      ENDCASE.

      w_folha_tempos-orderid         = w_apontamento-ordem_processo. " Nº ordem
      w_folha_tempos-phase           = w_apontamento-nro_operacao  . " Nº operação
      w_folha_tempos-clear_res       = space                       . " Dar baixa de reservas pendentes
      w_folha_tempos-postg_date      = sy-datum                    . " Data de lançamento
      w_folha_tempos-yield           = w_apontamento-qtd_boa       . " Qtd.boa a ser confirmada atualmente
      w_folha_tempos-scrap           = w_apontamento-refugo        . " Refugo a ser confirmado neste momento
      w_folha_tempos-conf_activity1  = w_apontamento-hr_apo_tp_prep. " APO tp. preparação
      w_folha_tempos-conf_activity2  = w_apontamento-hr_apo_tp_maq . " APO tp.maquina
      w_folha_tempos-conf_activity3  = w_apontamento-hr_hh_tp_prep . " Custo HH Tp. preparação
      w_folha_tempos-conf_activity4  = w_apontamento-hr_hh_tp_maq  . " Custo HH Tp. maquina
      w_folha_tempos-conf_acti_unit1 = c_unidade_medida_hora       . " Unidade de medida (APO tp. preparação)
      w_folha_tempos-conf_acti_unit2 = c_unidade_medida_hora       . " Unidade de medida (APO tp.maquina)
      w_folha_tempos-conf_acti_unit3 = c_unidade_medida_hora       . " Unidade de medida (Custo HH Tp. maquina)
      w_folha_tempos-conf_acti_unit4 = c_unidade_medida_hora       . " Unidade de medida (Custo HH Tp. maquina)
      APPEND w_folha_tempos TO t_folha_tempos                      .

*     Salva o apontamento parcial ou final na COR6N
      CALL FUNCTION 'BAPI_PROCORDCONF_CREATE_TT'
        IMPORTING
          return        = w_return
        TABLES
          timetickets   = t_folha_tempos
          detail_return = t_retorno.

      READ TABLE t_retorno
      TRANSPORTING NO FIELDS
      WITH KEY type = 'E'.                                  "#EC NOTEXT

      IF sy-subrc = 0.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
          IMPORTING
            return = w_return2.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait   = abap_true
          IMPORTING
            return = w_return2.
      ENDIF.

      LOOP AT t_retorno INTO w_retorno.
        CLEAR w_msg_app.

        CASE w_retorno-type.
          WHEN 'E'.                                         "#EC NOTEXT
            w_msg_app-tipo = 'error'             .          "#EC NOTEXT
            CONCATENATE w_retorno-message
                        w_retorno-message_v3
                   INTO w_msg_app-msg SEPARATED BY ' - '.
          WHEN 'S' OR 'I'.                                  "#EC NOTEXT
            w_msg_app-tipo = 'success'        .             "#EC NOTEXT
            w_msg_app-msg  = w_retorno-message.
          WHEN 'W'.                                         "#EC NOTEXT
            w_msg_app-tipo = 'warning'        .             "#EC NOTEXT
            w_msg_app-msg  = w_retorno-message.
        ENDCASE.                                            "#EC NOTEXT

      ENDLOOP.

      ex_msg_retorno = converter_msg_json( w_msg_app ).

    CATCH ycx_apo INTO o_cx_apo.
      v_msg_erro = o_cx_apo->msg.
      RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDTRY.

ENDMETHOD.