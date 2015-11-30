*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                     *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : GET_PERMISSOES_USUARIO                                    *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obter permissões do usuário logado                        *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_USUARIO	              TYPE SY-UNAME
*--> IMPORTING IM_RECURSO	              TYPE ARBPL   OPTIONAL
*--> IMPORTING IM_CENTRO                TYPE WERKS_D OPTIONAL
*--> IMPORTING IM_APTO_PARCIAL          TYPE CHAR1   OPTIONAL
*--> IMPORTING IM_APTO_FINAL            TYPE CHAR1   OPTIONAL
*--> IMPORTING IM_ESTORNO	              TYPE CHAR1   OPTIONAL
*--> RETURNING VALUE( EX_W_PERMISSOES )	TYPE TY_PERMISSAO

METHOD get_permissoes_usuario.
*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_permissoes TYPE STANDARD TABLE OF ty_permissao.

*----------------------------------------------------------------------*
* Work Areas
*----------------------------------------------------------------------*
  DATA:
    w_permissoes LIKE LINE OF t_permissoes.
*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_indice   TYPE sy-tabix,
    v_msg_erro TYPE string  .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  CLEAR ex_w_permissoes.

* APO - Apto Horas OP - Cadastro de Usuários e permissões
  SELECT * FROM yapt001
   INTO TABLE t_permissoes
   WHERE bname = im_usuario.

  IF t_permissoes IS INITIAL.
*   Usuário & sem autorização. Verifique a transação YAPT001
    MESSAGE e019(yapo) WITH im_usuario INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDIF.

* Verifica as permissões de acordo com centro e recurso
  CHECK im_usuario IS NOT INITIAL
    AND im_centro  IS NOT INITIAL.

  DELETE t_permissoes WHERE werks <> im_centro.

  IF t_permissoes IS INITIAL.
*   Usuário & sem autorização no centro &. Verifique a transação YAPT001
    MESSAGE e020(yapo) WITH im_usuario im_centro INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDIF.

  LOOP AT t_permissoes INTO w_permissoes.
    v_indice = sy-tabix.

*   Verifica se tem permissão de apontar em qualquer recurso
    IF w_permissoes-arbpl = me->c_acesso_total
      AND w_permissoes-werks = im_centro.

      w_permissoes-arbpl = im_recurso.
      MODIFY t_permissoes FROM w_permissoes INDEX v_indice.
    ENDIF.
  ENDLOOP.

  CLEAR w_permissoes.

  READ TABLE t_permissoes
  INTO w_permissoes
  WITH KEY arbpl = im_recurso
           werks = im_centro.

  IF sy-subrc = 0.
    ex_w_permissoes = w_permissoes.
  ELSE.
    READ TABLE t_permissoes
    INTO w_permissoes
    WITH KEY werks = im_centro.

    IF w_permissoes-visualizar IS NOT INITIAL.
      CLEAR w_permissoes.
      w_permissoes-visualizar = abap_true.
      ex_w_permissoes = w_permissoes.
    ELSE.
      CLEAR ex_w_permissoes.
    ENDIF.
  ENDIF.

  IF im_apto_parcial IS NOT INITIAL.
    READ TABLE t_permissoes
    TRANSPORTING NO FIELDS
    WITH KEY parcial = abap_true
             werks   = im_centro
             arbpl   = im_recurso.

    IF sy-subrc <> 0.
*     Sem permissão para apontamento parcial
      MESSAGE e014(yapo) INTO v_msg_erro.
      RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
    ENDIF.
  ENDIF.

* Verifica se no momento de realizar o apontamento o usuário tem permissão
  IF im_apto_final IS NOT INITIAL.
    READ TABLE t_permissoes
    TRANSPORTING NO FIELDS
    WITH KEY final = abap_true
             werks = im_centro
             arbpl = im_recurso.

    IF sy-subrc <> 0.
      READ TABLE t_permissoes
      TRANSPORTING NO FIELDS
      WITH KEY final = abap_true
               werks = im_centro
               arbpl = me->c_acesso_total.

      IF sy-subrc <> 0.
*       Sem permissão para apontamento final
        MESSAGE e015(yapo) INTO v_msg_erro.
        RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
      ENDIF.

    ENDIF.
  ENDIF.

  IF im_estorno IS NOT INITIAL.
    READ TABLE t_permissoes
    TRANSPORTING NO FIELDS
    WITH KEY estornar = abap_true
             werks    = im_centro
             arbpl    = im_recurso.

    IF sy-subrc <> 0.
      READ TABLE t_permissoes
      TRANSPORTING NO FIELDS
      WITH KEY estornar = abap_true
               werks    = im_centro
               arbpl    = me->c_acesso_total.

      IF sy-subrc <> 0.
*       Sem permissão para estornar
        MESSAGE e016(yapo) INTO v_msg_erro.
        RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
      ENDIF.

    ENDIF.
  ENDIF.

ENDMETHOD.