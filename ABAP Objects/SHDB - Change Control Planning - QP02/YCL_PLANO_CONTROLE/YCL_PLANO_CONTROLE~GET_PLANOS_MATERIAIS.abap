*----------------------------------------------------------------------*
* Classe   : YCL_PLANO_CONTROLE                                        *
* Método   : GET_PLANOS_MATERIAIS                                      *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obter planos a materiais                                  *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.07.2015  #111437 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_planos_materiais.
*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
  TYPES:
    BEGIN OF ty_mapl       ,
      plnnr TYPE mapl-plnnr, " Chave do grupo de listas de tarefas
      plnal TYPE mapl-plnal, " Numerador de grupos
      datuv TYPE mapl-datuv, " Data início validade
    END OF ty_mapl         .

*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
     t_mapl_aux TYPE STANDARD TABLE OF ty_mapl,
     t_plnnr    TYPE r_plnnr                  .

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
     w_mapl_aux LIKE LINE OF t_mapl_aux,
     w_plnnr    LIKE LINE OF t_plnnr   .

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
  CONSTANTS:
     c_plano_controle TYPE tca01-plnty VALUE 'Q'.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
     v_msg_erro TYPE string,
     v_length   TYPE i     .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  APPEND LINES OF plnnr TO t_plnnr.

  LOOP AT t_plnnr INTO w_plnnr.
    CLEAR: v_length, w_mapl_aux.

    v_length = STRLEN( w_plnnr-low ) - 2.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = w_plnnr-low(v_length)
      IMPORTING
        output = w_mapl_aux-plnnr.

    w_mapl_aux-plnal = w_plnnr-low+v_length(2). " Numerador de grupos

    IF w_mapl_aux-plnnr IS NOT INITIAL
      AND w_mapl_aux-plnal IS NOT INITIAL.

      SELECT MAX( datuv )
       FROM mapl
       INTO w_mapl_aux-datuv
       WHERE plnnr = w_mapl_aux-plnnr
         AND plnal = w_mapl_aux-plnal.
    ENDIF.

    APPEND w_mapl_aux TO t_mapl_aux.
  ENDLOOP.

  IF t_mapl_aux IS NOT INITIAL.
    IF datuv IS NOT INITIAL.
*     Atribuição de planos a materiais
      SELECT plnty plnnr plnal datuv loekz matnr werks
        FROM mapl
        INTO TABLE t_mapl
        FOR ALL ENTRIES IN t_mapl_aux
        WHERE plnnr EQ t_mapl_aux-plnnr
          AND plnal EQ t_mapl_aux-plnal
          AND datuv IN datuv
          AND matnr IN matnr
          AND werks IN werks
          AND plnty EQ c_plano_controle
          AND loekz NE abap_true.
    ELSE.
*     Atribuição de planos a materiais
      SELECT plnty plnnr plnal datuv loekz matnr werks
        FROM mapl
        INTO TABLE t_mapl
        FOR ALL ENTRIES IN t_mapl_aux
        WHERE plnnr EQ t_mapl_aux-plnnr
          AND plnal EQ t_mapl_aux-plnal
          AND datuv EQ t_mapl_aux-datuv
          AND matnr IN matnr
          AND werks IN werks
          AND plnty EQ c_plano_controle
          AND loekz NE abap_true.
    ENDIF.
  ENDIF.

  IF t_mapl IS INITIAL.
    MESSAGE e001(yplano_controle) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_plano_controle EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.
