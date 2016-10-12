*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* Método   : ATUALIZAR_CLASSE_CLASSIFICACAO                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Atualizar classe de classificação dos materiais           *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.11.2015  #121646 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD atualizar_classe_classificacao.
*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
  TYPES:
   BEGIN OF ty_makt       ,
     matnr TYPE mara-matnr,
     maktx TYPE makt-maktx,
   END OF ty_makt         .

*----------------------------------------------------------------------*
* Tabela interna
*----------------------------------------------------------------------*
  DATA:
    t_ausp           TYPE STANDARD TABLE OF ausp             ,
    t_makt           TYPE STANDARD TABLE OF ty_makt          ,
    t_alv_cl_classif TYPE STANDARD TABLE OF ty_alv_cl_classif.

*----------------------------------------------------------------------*
* Work-areas
*----------------------------------------------------------------------*
  DATA:
    w_excel          TYPE ty_excel         ,
    w_makt           TYPE ty_makt          ,
    w_caracteristica TYPE ty_caracteristica,
    w_alv_cl_classif TYPE ty_alv_cl_classif,
    w_ausp           TYPE ausp             .

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro TYPE string  ,
    v_indice   TYPE sy-tabix.

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
  CONSTANTS:
    c_data     TYPE atfor VALUE 'DATE',
    c_caracter TYPE atfor VALUE 'CHAR'.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  IF im_t_ausp IS INITIAL.
    RETURN.
  ENDIF.

  APPEND LINES OF:
     im_t_ausp TO t_ausp,
     im_t_makt TO t_makt.

  LOOP AT t_ausp INTO w_ausp.
    v_indice = sy-tabix.

    CLEAR: w_excel, w_alv_cl_classif.

    READ TABLE me->t_excel
    INTO w_excel
    WITH KEY matnr = w_ausp-objek.                          "#EC *

    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    CLEAR w_caracteristica.
    READ TABLE me->t_caracteristicas
    INTO w_caracteristica
    WITH KEY imerk = w_ausp-atinn
             klart = w_ausp-klart.

    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

*   Categoria de dados da característica
    CASE w_caracteristica-atfor.
      WHEN c_caracter. " CHAR
        w_alv_cl_classif-vlold = w_ausp-atwrt . " Valor antigo
        w_alv_cl_classif-vlnew = w_excel-atwrt. " Valor novo

        w_ausp-atwrt = w_excel-atwrt.

      WHEN c_data. " DATE
        w_alv_cl_classif-vlold = me->converter_ponto_flutuante_data( w_ausp-atflv ). " Valor antigo

        w_ausp-atflv = me->converter_data_ponto_flutuante( w_excel-atwrt ).

        w_alv_cl_classif-vlnew = me->converter_ponto_flutuante_data( w_ausp-atflv ). " Valor novo
    ENDCASE.

    CLEAR w_makt.
    READ TABLE t_makt
    INTO w_makt
    WITH KEY matnr = w_ausp-objek.                          "#EC *

    w_alv_cl_classif-matnr = w_excel-matnr     . " Nº do material
    w_alv_cl_classif-maktx = w_makt-maktx      . " Nome do material
    w_alv_cl_classif-klart = w_ausp-klart      . " Tipo de classe
    w_alv_cl_classif-imerk = w_ausp-atinn      . " Característica interna
    APPEND w_alv_cl_classif TO t_alv_cl_classif.

    MODIFY t_ausp FROM w_ausp INDEX v_indice.
  ENDLOOP.

  IF t_ausp IS NOT INITIAL.
    CALL FUNCTION 'CLVF_UPDATE_AUSP'
      TABLES
        upd_ausp = t_ausp.
  ENDIF.

  IF t_alv_cl_classif IS NOT INITIAL.
    SORT t_alv_cl_classif BY matnr ASCENDING.
    APPEND LINES OF t_alv_cl_classif TO ex_t_alv_cl_class.
  ENDIF.

ENDMETHOD.