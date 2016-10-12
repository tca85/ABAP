*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* Método   : MODIFICAR_CLASSE_CLASSIFICACAO                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Incluir/Modificar classe de classificação de acordo com   *
*            arquivo do excel (xls)                                    *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.11.2015  #135533 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD modificar_classe_classificacao.
*----------------------------------------------------------------------*
* Tabela interna
*----------------------------------------------------------------------*
  DATA:
    t_ausp           TYPE STANDARD TABLE OF ausp             ,
    t_excel_add      TYPE STANDARD TABLE OF ty_excel         ,
    t_makt           TYPE STANDARD TABLE OF ty_makt          ,
    t_alv_cl_classif TYPE STANDARD TABLE OF ty_alv_cl_classif.

*----------------------------------------------------------------------*
* Work-areas
*----------------------------------------------------------------------*
  DATA:
    w_excel TYPE ty_excel.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro TYPE string  ,
    v_indice   TYPE sy-tabix.

*----------------------------------------------------------------------*
* Ranges
*----------------------------------------------------------------------*
  TYPES:
    r_matnr_range TYPE RANGE OF mara-matnr   ,
    r_matnr_linha TYPE LINE OF  r_matnr_range.

  DATA:
    r_matnr TYPE r_matnr_range,
    w_matnr TYPE r_matnr_linha.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  LOOP AT me->t_excel INTO w_excel.
    v_indice = sy-tabix.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = w_excel-matnr
      IMPORTING
        output       = w_excel-matnr
      EXCEPTIONS                                            "#EC *
        length_error = 1
        OTHERS       = 2.

    CLEAR w_matnr                 .
    w_matnr-sign   = 'I'          .
    w_matnr-option = 'EQ'         .
    w_matnr-low    = w_excel-matnr.
    APPEND w_matnr TO r_matnr     .

    MODIFY me->t_excel FROM w_excel INDEX v_indice.
  ENDLOOP.

  IF r_matnr IS NOT INITIAL
    AND me->t_caracteristicas IS NOT INITIAL.

*   Valores das modalidades das características
    SELECT * FROM ausp
     INTO TABLE t_ausp
     FOR ALL ENTRIES IN me->t_caracteristicas
     WHERE atinn EQ me->t_caracteristicas-imerk " Característica interna
       AND klart EQ me->t_caracteristicas-klart " Tipo de classe
       AND objek IN r_matnr.                    " Chave do objeto a ser classificado

    SELECT DISTINCT matnr maktx
     FROM makt
     INTO TABLE t_makt
     WHERE matnr IN r_matnr.
  ENDIF.

  LOOP AT me->t_excel INTO w_excel.
    READ TABLE t_ausp
    TRANSPORTING NO FIELDS
    WITH KEY objek = w_excel-matnr.

    IF sy-subrc <> 0.
      APPEND w_excel TO t_excel_add.
    ENDIF.
  ENDLOOP.

* Modifica a classe de classificação dos materiais que já tem
  FREE t_alv_cl_classif.
  t_alv_cl_classif = me->atualizar_classe_classificacao( im_t_ausp = t_ausp
                                                         im_t_makt = t_makt ).
  APPEND LINES OF t_alv_cl_classif TO ex_t_alv_cl_class.

* Cria a classe de classificação para os materiais que ainda não tem
  FREE t_alv_cl_classif.
  t_alv_cl_classif = me->criar_classe_classificacao( im_t_excel = t_excel_add
                                                     im_t_makt  = t_makt ).
  APPEND LINES OF t_alv_cl_classif TO ex_t_alv_cl_class.

  SORT ex_t_alv_cl_class BY matnr ASCENDING.
  DELETE ADJACENT DUPLICATES FROM ex_t_alv_cl_class COMPARING ALL FIELDS.
ENDMETHOD.