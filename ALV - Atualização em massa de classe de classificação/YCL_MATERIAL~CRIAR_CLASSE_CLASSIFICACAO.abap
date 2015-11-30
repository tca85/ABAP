*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* Método   : CRIAR_CLASSE_CLASSIFICACAO                                *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Criar classe de classificação                             *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  25.11.2015  #135533 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD criar_classe_classificacao.

*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
  TYPES:
    BEGIN OF ty_tcla       ,
      klart TYPE tcla-klart,
      obtab TYPE tcla-obtab,
    END OF ty_tcla         .

*----------------------------------------------------------------------*
* Tabela interna
*----------------------------------------------------------------------*
  DATA:
    t_makt               TYPE STANDARD TABLE OF ty_makt                   ,
    t_alv_cl_classif     TYPE STANDARD TABLE OF ty_alv_cl_classif         ,
    t_alloc_list         TYPE STANDARD TABLE OF bapi1003_alloc_list       ,
    t_classificacao_char TYPE STANDARD TABLE OF bapi1003_alloc_values_char,
    t_classificacao_num  TYPE STANDARD TABLE OF bapi1003_alloc_values_num ,
    t_classificacao_curr TYPE STANDARD TABLE OF bapi1003_alloc_values_curr,
    t_return             TYPE STANDARD TABLE OF bapiret2                  .

*----------------------------------------------------------------------*
* Work-areas
*----------------------------------------------------------------------*
  DATA:
    w_excel              TYPE ty_excel                    ,
    w_makt               TYPE ty_makt                     ,
    w_caracteristica     TYPE ty_caracteristica           ,
    w_tcla               TYPE ty_tcla                     ,
    w_alv_cl_classif     TYPE ty_alv_cl_classif           ,
    w_classificacao_char LIKE LINE OF t_classificacao_char,
    w_classificacao_num  LIKE LINE OF t_classificacao_num ,
    w_return             LIKE LINE OF t_return            .

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_nro_material TYPE bapi1003_key-object     ,
    v_nome_tabela  TYPE bapi1003_key-objecttable,
    v_tipo_classe  TYPE bapi1003_key-classtype  ,
    v_nro_classe   TYPE bapi1003_key-classnum   .

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
  CONSTANTS:
    c_data            TYPE atfor      VALUE 'DATE'     ,
    c_caracter        TYPE atfor      VALUE 'CHAR'     ,
    c_msg_erro        TYPE bapi_mtype VALUE 'E'        ,
    c_classe_material TYPE klasse_d   VALUE 'MAT_GERAL'.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  IF im_t_excel IS INITIAL.
    RETURN.
  ENDIF.

  APPEND LINES OF im_t_makt TO t_makt.

  SELECT SINGLE klart obtab
   FROM tcla
   INTO w_tcla
   WHERE klart = me->c_classe_material.

  LOOP AT im_t_excel INTO w_excel.
    FREE: w_alv_cl_classif, w_classificacao_char, t_classificacao_num,
          t_classificacao_char, t_classificacao_num, t_return.

    CLEAR w_caracteristica.
    READ TABLE me->t_caracteristicas
    INTO w_caracteristica
    INDEX 1.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CLEAR w_makt.
    READ TABLE t_makt
    INTO w_makt
    WITH KEY matnr = w_excel-matnr.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    v_nro_material = w_excel-matnr    .
    v_nome_tabela  = w_tcla-obtab     .
    v_nro_classe   = c_classe_material.
    v_tipo_classe  = w_tcla-klart     .

    FREE: t_alloc_list, t_classificacao_char, t_classificacao_curr,
          t_classificacao_num, t_return.

    CALL FUNCTION 'BAPI_OBJCL_GETCLASSES'
      EXPORTING
        objectkey_imp   = v_nro_material
        objecttable_imp = v_nome_tabela
        classtype_imp   = v_tipo_classe
        read_valuations = abap_true
      TABLES
        alloclist       = t_alloc_list
        allocvalueschar = t_classificacao_char
        allocvaluescurr = t_classificacao_curr
        allocvaluesnum  = t_classificacao_num
        return          = t_return.

*   Categoria de dados da característica
    CASE w_caracteristica-atfor.
      WHEN c_caracter. " CHAR
        w_classificacao_char-charact    = w_caracteristica-atnam. " Nome da característica
        w_classificacao_char-value_char = w_excel-atwrt         . " Valor da característica
        APPEND w_classificacao_char TO t_classificacao_char     .

      WHEN c_data. " DATE
        w_classificacao_num-charact    = w_caracteristica-atnam                             . " Nome da característica
        w_classificacao_num-value_from = me->converter_data_ponto_flutuante( w_excel-atwrt ). " Valor interno vírgula flutuante desde
        APPEND w_classificacao_num TO t_classificacao_num                                   .

    ENDCASE.

    IF t_classificacao_num IS INITIAL
       AND t_classificacao_char IS INITIAL.
      RETURN.
    ENDIF.

    SORT t_classificacao_char BY charact ASCENDING.
    DELETE ADJACENT DUPLICATES FROM t_classificacao_char COMPARING ALL FIELDS.

    SORT t_classificacao_num BY charact ASCENDING.
    DELETE ADJACENT DUPLICATES FROM t_classificacao_num COMPARING ALL FIELDS.

*   Cria a visão de classificação
    CALL FUNCTION 'BAPI_OBJCL_CHANGE'
      EXPORTING
        objectkey          = v_nro_material
        objecttable        = v_nome_tabela
        classnum           = v_nro_classe
        classtype          = v_tipo_classe
      TABLES
        allocvaluesnumnew  = t_classificacao_num
        allocvaluescharnew = t_classificacao_char
        allocvaluescurrnew = t_classificacao_curr
        return             = t_return.

    SORT t_return BY type ASCENDING.

    CLEAR w_return.

    READ TABLE t_return
    INTO w_return
    WITH KEY type = c_msg_erro.

    IF sy-subrc <> 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      LOOP AT t_return INTO w_return WHERE type = c_msg_erro.
        CONCATENATE w_return-message
                    w_alv_cl_classif-erro
               INTO w_alv_cl_classif-erro
       SEPARATED BY ' | '.
      ENDLOOP.
    ENDIF.

    w_alv_cl_classif-matnr = w_excel-matnr         . " Nº do material
    w_alv_cl_classif-maktx = w_makt-maktx          . " Nome do material
    w_alv_cl_classif-klart = w_caracteristica-klart. " Tipo de classe
    w_alv_cl_classif-imerk = w_caracteristica-imerk. " Característica interna
    w_alv_cl_classif-vlnew = w_excel-atwrt         . " Valor novo
    APPEND w_alv_cl_classif TO t_alv_cl_classif    .

  ENDLOOP.

  APPEND LINES OF t_alv_cl_classif TO ex_t_alv_cl_class.
ENDMETHOD.