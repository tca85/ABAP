*----------------------------------------------------------------------*
* Classe   : YCL_PLANO_CONTROLE                                        *
* Método   : GET_PLANO_CONTROLE                                        *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obtém o relatório ALV dos planos de controle              *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.07.2015  #111437 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_plano_controle.
*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
     t_plko_aux  TYPE STANDARD TABLE OF plko   ,
     t_plpo_aux  TYPE STANDARD TABLE OF coplpo ,
     t_plmkb_aux TYPE STANDARD TABLE OF plmkb  ,
     t_alv_aux   TYPE STANDARD TABLE OF ty_alv .

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
     w_msg_erro   TYPE bal_s_msg          ,
     w_mapl       LIKE LINE OF t_mapl     ,
     w_mapl_aux   TYPE mapl               ,                 "#EC NEEDED
     w_plko_aux   LIKE LINE OF t_plko_aux ,
     w_plpo_aux   LIKE LINE OF t_plpo_aux ,
     w_plmkb_aux  LIKE LINE OF t_plmkb_aux,
     w_alv        LIKE LINE OF t_alv      .

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
     v_msg_erro         TYPE string      ,
     v_res_appr_chk_exp TYPE plko-chrule ,                  "#EC NEEDED
     v_error_exp        TYPE plko-flg_chk,                  "#EC NEEDED
     v_pi_set_used      TYPE flag        .                  "#EC NEEDED

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  LOOP AT t_mapl INTO w_mapl.
    FREE: t_plko_aux, t_plpo_aux, t_plmkb_aux.
    CLEAR: v_res_appr_chk_exp, v_error_exp, w_mapl_aux, v_pi_set_used.

*   Extração de planos de controle (QP03)
    CALL FUNCTION 'CP_EX_PLAN_READ'
      EXPORTING
        cmode_imp        = space
        plnty_imp        = w_mapl-plnty
        plnnr_imp        = w_mapl-plnnr
        plnal_imp        = w_mapl-plnal
        sttag_imp        = sy-datum
        check_imp        = abap_true
        i_plant          = w_mapl-werks
      IMPORTING
        res_appr_chk_exp = v_res_appr_chk_exp
        error_exp        = v_error_exp
        e_mapl           = w_mapl_aux
        pi_set_used      = v_pi_set_used
      TABLES
        plko_exp         = t_plko_aux
        plpo_exp         = t_plpo_aux
        plmk_exp         = t_plmkb_aux
      EXCEPTIONS                                            "#EC *
        not_found        = 1
        plnal_initial    = 2
        OTHERS           = 3.

*   Tabela de documentos - características de plano de controle
    LOOP AT t_plmkb_aux INTO w_plmkb_aux.
      CLEAR w_alv.

      w_alv-matnr = w_mapl-matnr. " Nº do material
      w_alv-plnnr = w_mapl-plnnr. " Chave do grupo de listas de tarefas
      w_alv-plnal = w_mapl-plnal. " Numerador de grupos
      w_alv-werks = w_mapl-werks. " Centro

*     Plano - cabeçalho
      CLEAR w_plko_aux.
      READ TABLE t_plko_aux
      INTO w_plko_aux
      WITH KEY plnnr = w_plmkb_aux-plnnr.

      IF sy-subrc = 0.
        w_alv-ktext = w_plko_aux-ktext. " TxtBrv.LstTaref.
        w_alv-verwe = w_plko_aux-verwe. " Utilização do plano
        w_alv-statu = w_plko_aux-statu. " Status do plano
        w_alv-losvn = w_plko_aux-losvn. " Tamanho de lote desde
        w_alv-losbs = w_plko_aux-losbs. " Grupo de planejamento/departamento responsável
        w_alv-plnme = w_plko_aux-plnme. " Unidade de medida da lista de tarefas
      ENDIF.

*     Operações planejadas -> ordem
      CLEAR w_plpo_aux.
      READ TABLE t_plpo_aux
      INTO w_plpo_aux
      WITH KEY plnnr = w_plmkb_aux-plnnr
               plnkn = w_plmkb_aux-plnkn.

      IF sy-subrc = 0.
        w_alv-vornr = w_plpo_aux-vornr. " Nº operação
        w_alv-steus = w_plpo_aux-steus. " Chave de controle
        w_alv-ltxa1 = w_plpo_aux-ltxa1. " Txt.breve operação
      ENDIF.

      w_alv-merknr     = w_plmkb_aux-merknr                                   . " Nº característica de controle
      w_alv-verwmerkm  = w_plmkb_aux-verwmerkm                                . " Carac.mestre contr.
      w_alv-kurztext   = w_plmkb_aux-kurztext                                 . " Texto breve para característica de controle
      w_alv-pmethode   = w_plmkb_aux-pmethode                                 . " Método de controle
      w_alv-sollwert   = me->converter_float_decimal( w_plmkb_aux-sollwert   ). " Valor teórico para uma característica quantitativa
      w_alv-toleranzun = me->converter_float_decimal( w_plmkb_aux-toleranzun ). " Limite inferior de tolerância
      w_alv-toleranzob = me->converter_float_decimal( w_plmkb_aux-toleranzob ). " Valor limite superior
      w_alv-stichprver = w_plmkb_aux-stichprver                               . " Processo de amostra na característica de controle
      w_alv-probemgeh  = w_plmkb_aux-probemgeh                                . " Unidade de medida da amostra
      w_alv-fakprobme  = me->converter_float_decimal( w_plmkb_aux-fakprobme  ). " Fator para conversão UM amostra em UM material
      w_alv-vsteuerkz  = w_plmkb_aux-vsteuerkz                                . " Proposta para códigos de controle da característica
      w_alv-stellen    = w_plmkb_aux-stellen                                  . " Número de casas decimais (precisão)
      w_alv-masseinhsw = w_plmkb_aux-masseinhsw                               . " Unidade de medida. na qual os dds.quantit.são gravados
      w_alv-auswmenge1 = w_plmkb_aux-auswmenge1                               . " Grupo de codes / conjunto de seleção atribuído
      w_alv-auswmgwrk1 = w_plmkb_aux-auswmgwrk1                               . " Centro do conjunto selecionado atribuido

      APPEND w_alv TO t_alv_aux.
    ENDLOOP.
  ENDLOOP.

  IF t_alv_aux IS NOT INITIAL.
    APPEND LINES OF t_alv_aux TO t_alv.
  ELSE.
    MESSAGE e001(yplano_controle) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_plano_controle EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.
