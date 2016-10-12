*----------------------------------------------------------------------*
* Classe   : YCL_PLANO_CONTROLE                                        *
* Método   : PARSE_EXCEL_QP02                                          *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Faz o parse (quebra) da planilha de modificação da QP02   *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  21.01.2016  #142490 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD parse_excel_qp02.

*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
     t_excel_qp02 TYPE STANDARD TABLE OF ty_excel_qp02.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
     w_excel_qp02               LIKE LINE OF t_excel_qp02        ,
     w_material_qp02            TYPE ty_material_qp02            ,
     w_lista_tarefa_qp02        TYPE ty_lista_tarefas_qp02       ,
     w_operacao_qp02            TYPE ty_operacoes_qp02           ,
     w_caracteristica_ctrl_qp02 TYPE ty_caracteristicas_ctrl_qp02.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
     v_indice TYPE sy-tabix.

  CONSTANTS:
     c_ctrl_dinamico_caracteristica TYPE tq39a-dynlevel VALUE '3',
     c_status_bloqueado             TYPE plko-statu     VALUE 'Z1'.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  t_excel_qp02 = me->importar_excel( im_nome_arquivo ).

  LOOP AT t_excel_qp02 INTO w_excel_qp02.
    v_indice = sy-tabix.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = w_excel_qp02-matnr
      IMPORTING
        output       = w_excel_qp02-matnr
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2.

* Alinhar o centro a direita e incluir zeros a esquerda.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = w_excel_qp02-werks
      IMPORTING
        output = w_excel_qp02-werks.

    CLEAR w_material_qp02.

    w_material_qp02-matnr = w_excel_qp02-matnr   .
    w_material_qp02-werks = w_excel_qp02-werks   .
    APPEND w_material_qp02 TO me->t_materiais_qp02.

    MODIFY t_excel_qp02 FROM w_excel_qp02 INDEX v_indice.
  ENDLOOP.

  APPEND LINES OF t_excel_qp02 TO me->t_excel_qp02.

  SORT me->t_materiais_qp02 BY matnr werks ASCENDING.
  DELETE ADJACENT DUPLICATES FROM me->t_materiais_qp02.

  SORT me->t_excel_qp02 BY matnr werks ASCENDING.

  LOOP AT me->t_materiais_qp02 INTO w_material_qp02.
    READ TABLE me->t_excel_qp02
    TRANSPORTING NO FIELDS
    WITH KEY matnr = w_material_qp02-matnr
             werks = w_material_qp02-werks.

    IF sy-subrc = 0.
      v_indice = sy-tabix.
    ELSE.
      CONTINUE.
    ENDIF.

    LOOP AT me->t_excel_qp02 INTO w_excel_qp02 FROM v_indice.
      IF w_excel_qp02-matnr <> w_material_qp02-matnr
        AND w_excel_qp02-werks <> w_material_qp02-werks.
        EXIT.
      ENDIF.

*---------------------------------------------------------------------------------------------------------------------------
*     Lista de tarefas
*---------------------------------------------------------------------------------------------------------------------------
      CLEAR w_lista_tarefa_qp02                                     .
      w_lista_tarefa_qp02-matnr     = w_excel_qp02-matnr            . " Material
      w_lista_tarefa_qp02-werks     = w_excel_qp02-werks            . " Centro
      w_lista_tarefa_qp02-plnal     = w_excel_qp02-plnal            . " Numerador de grupos
      w_lista_tarefa_qp02-qdynhead  = c_ctrl_dinamico_caracteristica. " Nível no qual devem ser definidos parâms.controle dinâmico
      w_lista_tarefa_qp02-qdynregel = w_excel_qp02-qdynregel        . " Regra de controle dinâmico
      w_lista_tarefa_qp02-statu     = c_status_bloqueado            . " Status
      APPEND w_lista_tarefa_qp02 TO me->t_lista_tarefas_qp02        .

*---------------------------------------------------------------------------------------------------------------------------
*     Operações da lista de tarefas
*---------------------------------------------------------------------------------------------------------------------------
      CLEAR w_operacao_qp02                         .
      w_operacao_qp02-matnr = w_excel_qp02-matnr    . " Material
      w_operacao_qp02-werks = w_excel_qp02-werks    . " Centro
      w_operacao_qp02-plnal = w_excel_qp02-plnal    . " Numerador de grupos
      w_operacao_qp02-vornr = w_excel_qp02-vornr    . " Nº operação
      APPEND w_operacao_qp02 TO me->t_operacoes_qp02.

*---------------------------------------------------------------------------------------------------------------------------
*    Características de controle
*---------------------------------------------------------------------------------------------------------------------------
      CLEAR w_caracteristica_ctrl_qp02                                    .
      w_caracteristica_ctrl_qp02-matnr      = w_excel_qp02-matnr           . " Material
      w_caracteristica_ctrl_qp02-werks      = w_excel_qp02-werks           . " Centro
      w_caracteristica_ctrl_qp02-plnal      = w_excel_qp02-plnal           . " Numerador de grupos
      w_caracteristica_ctrl_qp02-vornr      = w_excel_qp02-vornr           . " Nº operação
      w_caracteristica_ctrl_qp02-merknr     = w_excel_qp02-merknr          . " Nº característica de controle
      w_caracteristica_ctrl_qp02-qdynregel  = w_excel_qp02-ctrdin          . " Regra de controle dinâmico
*      w_caracteristica_ctrl_qp02-toleranzun = w_excel_qp02-toleranzun      . " Limite inferior
*      w_caracteristica_ctrl_qp02-toleranzob = w_excel_qp02-toleranzob      . " Limite superior
      IF w_excel_qp02-toleranzun IS NOT INITIAL.
        WRITE w_excel_qp02-toleranzun TO w_caracteristica_ctrl_qp02-toleranzun      . " Limite inferior
        replace ALL OCCURRENCES OF '.' in w_caracteristica_ctrl_qp02-toleranzun WITH space.
        condense w_caracteristica_ctrl_qp02-toleranzun.
      ENDIF.
      IF w_excel_qp02-toleranzob IS NOT INITIAL.
        WRITE w_excel_qp02-toleranzob TO w_caracteristica_ctrl_qp02-toleranzob      . " Limite superior
        replace ALL OCCURRENCES OF '.' in w_caracteristica_ctrl_qp02-toleranzob WITH space.
        condense w_caracteristica_ctrl_qp02-toleranzun.
      ENDIF.
      w_caracteristica_ctrl_qp02-masseinhsw = w_excel_qp02-masseinhsw      . " Unidade
      APPEND w_caracteristica_ctrl_qp02 TO me->t_caracteristicas_ctrl_qp02.
    ENDLOOP.

  ENDLOOP.

  SORT: me->t_lista_tarefas_qp02        ASCENDING,
        me->t_operacoes_qp02            ASCENDING,
        me->t_caracteristicas_ctrl_qp02 ASCENDING.

  DELETE ADJACENT DUPLICATES FROM:
     me->t_lista_tarefas_qp02       ,
     me->t_operacoes_qp02           ,
     me->t_caracteristicas_ctrl_qp02.

ENDMETHOD.
