*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Efetivar a comissão do fornecedor e criar um pedido de    *
*            compras de serviço (ME21N)                                *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  14.10.2014  #***** - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> CHANGING EX_T_APROV_COMISSAO TYPE TP_APROV_COMISSAO  Aprovar Comissão de Vendas

METHOD efetivar_comissao.
  INCLUDE: <icon>.

*----------------------------------------------------------------------*
* Tabelas Internas                                                     *
*----------------------------------------------------------------------*
  DATA:
    t_aprov_comissao_aux TYPE STANDARD TABLE OF ty_aprov_comissao,
    t_cv_cabecalho       TYPE STANDARD TABLE OF zsdt033c         ,
    t_cv_item            TYPE STANDARD TABLE OF zsdt033i         ,
    t_cv_item_aux        TYPE STANDARD TABLE OF zsdt033i         ,
    t_retorno_bapi       TYPE STANDARD TABLE OF bapiret2         .

*----------------------------------------------------------------------*
* Work-Areas / Field-Symbols                                           *
*----------------------------------------------------------------------*
  DATA:
    w_aprov_comissao     LIKE LINE OF ex_t_aprov_comissao ,
    w_aprov_comissao_aux LIKE LINE OF t_aprov_comissao_aux,
    w_cv_cabecalho       LIKE LINE OF t_cv_cabecalho      ,
    w_cv_item            LIKE LINE OF t_cv_item           ,
    w_cv_item_aux        LIKE LINE OF t_cv_item_aux       .

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
  DATA:
    v_sequencia   TYPE n LENGTH 10    ,
    v_return_code TYPE inri-returncode,
    v_msg_erro    TYPE t100-text      ,
    v_indice      TYPE sy-tabix       .

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
  CONSTANTS:
    c_range_cv  TYPE inri-object    VALUE 'ZSD_COM',
    c_nro_range TYPE inri-nrrangenr VALUE '01'     .

*----------------------------------------------------------------------*
* Início                                                               *
*----------------------------------------------------------------------*

  APPEND LINES OF ex_t_aprov_comissao TO t_aprov_comissao_aux.
  SORT t_aprov_comissao_aux BY conf ASCENDING.

* Exclui as notas que não foram selecionadas (checkbox 'Confirmar')
  DELETE t_aprov_comissao_aux WHERE conf IS INITIAL.

  DELETE t_aprov_comissao_aux WHERE status = icon_checked.

  IF t_aprov_comissao_aux IS INITIAL.
*   Selecione as notas antes de aprovar
    MESSAGE i007(zsdr033) INTO v_msg_erro.
    RAISE EXCEPTION TYPE zcx_comissao_vendas EXPORTING mensagem = v_msg_erro.
  ENDIF.

* Comissão de Vendas - Cabeçalho
  SELECT * FROM zsdt033c
   INTO TABLE t_cv_cabecalho
   FOR ALL ENTRIES IN t_aprov_comissao_aux
   WHERE nrg = t_aprov_comissao_aux-nrg
    AND lifnr <> space.

  IF t_cv_cabecalho IS NOT INITIAL.
*   Comissão de Vendas - Ítem
    SELECT * FROM zsdt033i
     INTO TABLE t_cv_item
     FOR ALL ENTRIES IN t_cv_cabecalho
      WHERE nrg  = t_cv_cabecalho-nrg
       AND ebeln = space.
  ENDIF.

  LOOP AT t_cv_cabecalho INTO w_cv_cabecalho.
    v_indice = sy-tabix.

    READ TABLE t_cv_item
    TRANSPORTING NO FIELDS
    WITH KEY nrg = w_cv_cabecalho-nrg.

    IF sy-subrc <> 0.
      DELETE t_cv_cabecalho INDEX v_indice.
    ENDIF.
  ENDLOOP.

  LOOP AT t_aprov_comissao_aux INTO w_aprov_comissao_aux.
    v_indice = sy-tabix.

    READ TABLE t_cv_cabecalho
    TRANSPORTING NO FIELDS
    WITH KEY nrg = w_aprov_comissao_aux-nrg.

    IF sy-subrc <> 0.
      DELETE t_aprov_comissao_aux INDEX v_indice.
    ENDIF.
  ENDLOOP.


  LOOP AT t_aprov_comissao_aux INTO w_aprov_comissao_aux.
    CLEAR w_aprov_comissao.
    READ TABLE ex_t_aprov_comissao
    INTO w_aprov_comissao
    WITH KEY nrg = w_aprov_comissao_aux-nrg.

    v_indice = sy-tabix.

    IF sy-subrc = 0.
      me->criar_pedido_compras( EXPORTING im_aprov_comissao = w_aprov_comissao_aux
                                 CHANGING ex_nro_pedido     = w_aprov_comissao-bstnk
                                          ex_t_bapiret2     = t_retorno_bapi ).

*     Verifica se criou o pedido
      IF w_aprov_comissao-bstnk IS NOT INITIAL.
        w_aprov_comissao-status = icon_checked. " Status
        MODIFY ex_t_aprov_comissao FROM w_aprov_comissao INDEX v_indice.

        UPDATE zsdt033i SET ebeln = w_aprov_comissao-bstnk
        WHERE nrg = w_aprov_comissao_aux-nrg.

        LOOP AT t_cv_item INTO w_cv_item WHERE nrg = w_aprov_comissao_aux-nrg.
          w_cv_item-ebeln = w_aprov_comissao-bstnk.
          MODIFY t_cv_item FROM w_cv_item INDEX sy-tabix.
        ENDLOOP.
      ELSE.
        APPEND LINES OF t_retorno_bapi TO ex_t_bapiret2.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMETHOD.
