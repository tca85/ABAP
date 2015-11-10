*----------------------------------------------------------------------*
*                       ACHÉ LABORATÓRIOS                              *
*----------------------------------------------------------------------*
* Programa : YQMR0006                                                  *
* Transação: YQMR0006                                                  *
* Descrição: Relatório de utilização de materiais de lista técnica     *
*            de produção                                               *
* Tipo     : Relatório ALV                                             *
* Módulo   : QM                                                        *
* Funcional: Ikaro Fracaro Lima de Oliveira                            *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  31.03.2015  #98132 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

REPORT yqmr0006 NO STANDARD PAGE HEADING.

*----------------------------------------------------------------------*
* Estruturas                                                           *
*----------------------------------------------------------------------*
TYPES:
 BEGIN OF ty_alv         ,
   werks TYPE stpov-werks, " Centro
   idnrk TYPE stpov-idnrk, " Componente de lista técnica
   maktx TYPE makt-maktx , " Descrição
   matnr TYPE stpov-matnr, " Nº do material
   ojtxb TYPE stpov-ojtxb, " Texto breve do objeto (conjunto)
   ttidx TYPE stpov-ttidx, " Índice em tabela de categoria
   level TYPE stpov-level, " Nível (para explosão de listas técnicas multinível)
   bmeng TYPE stpov-bmeng, " Quantidade básica
   bmein TYPE stpov-bmein, " Unidade de medida base (UMB) da lista técnica
   datuv TYPE stpov-datuv, " Data início validade
   datub TYPE stpov-datub, " Data de validade final
   posnr TYPE stpov-posnr, " Nº item da lista técnica
 END OF ty_alv           ,

 BEGIN OF ty_mara        ,
   matnr TYPE mara-matnr , " Nº do material
 END OF ty_mara          ,

 BEGIN OF ty_makt        ,
   matnr TYPE makt-matnr , " Nº do material
   maktx TYPE makt-maktx , " Texto breve de material
 END OF ty_makt          .

*----------------------------------------------------------------------*
* Tabelas Internas                                                     *
*----------------------------------------------------------------------*
DATA:
    t_lista_tecnica     TYPE STANDARD TABLE OF stpov  ,
    t_lista_tecnica_aux TYPE STANDARD TABLE OF stpov  ,
    t_equipamentos      TYPE STANDARD TABLE OF cscequi,
    t_ordens_cliente    TYPE STANDARD TABLE OF cscknd ,
    t_materiais         TYPE STANDARD TABLE OF cscmat ,
    t_obj_standard      TYPE STANDARD TABLE OF cscstd ,
    t_equipamentos2     TYPE STANDARD TABLE OF csctpl ,
    t_lst_projeto       TYPE STANDARD TABLE OF cscprj ,
    t_alv               TYPE STANDARD TABLE OF ty_alv ,
    t_mara              TYPE STANDARD TABLE OF ty_mara,
    t_makt              TYPE STANDARD TABLE OF ty_makt.

*----------------------------------------------------------------------*
* Work-Areas                                                           *
*----------------------------------------------------------------------*
DATA:
    w_lista_tecnica TYPE stpov  ,
    w_alv           TYPE ty_alv ,
    w_mara          TYPE ty_mara,
    w_makt          TYPE ty_makt.

*----------------------------------------------------------------------*
* Objetos                                                              *
*----------------------------------------------------------------------*
DATA:
    o_salv_table     TYPE REF TO cl_salv_table    ,
    o_salv_columns   TYPE REF TO cl_salv_columns  ,
    o_salv_functions TYPE REF TO cl_salv_functions,
    o_salv_msg       TYPE REF TO cx_salv_msg      .

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
DATA:
    v_matnr                 TYPE mara-matnr ,
    v_centro                TYPE rc29l-werks,
    v_data_validade_inicial TYPE rc29l-datuv,
    v_data_validade_final   TYPE rc29l-datub,
    v_msg_erro              TYPE string     .

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
CONSTANTS:
    c_item_inventariado      TYPE rc29l-postp VALUE 'L',
    c_lista_tecnica_producao TYPE rc29l-stlan VALUE '1'.

*----------------------------------------------------------------------*
* Tela de seleção                                                      *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE txt1                 . " Critério de seleção
SELECT-OPTIONS: s_matnr FOR v_matnr  NO INTERVALS              OBLIGATORY,
                s_werks FOR v_centro NO INTERVALS NO-EXTENSION OBLIGATORY,
                s_data  FOR sy-datum NO-EXTENSION              OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1                                         .

*----------------------------------------------------------------------*
* Inicialização                                                        *
*----------------------------------------------------------------------*
INITIALIZATION.
  txt1 = 'Critério de seleção'(001).                        "#EC NOTEXT

*----------------------------------------------------------------------*
* START-OF-SELECTION                                                   *
*----------------------------------------------------------------------*
START-OF-SELECTION.

  LOOP AT s_matnr.
    FREE: t_lista_tecnica_aux, t_equipamentos, t_ordens_cliente,
          t_materiais, t_obj_standard, t_equipamentos2, t_lst_projeto.

    v_data_validade_inicial = s_data-low .
    v_data_validade_final   = s_data-high.
    v_centro                = s_werks-low.

    CALL FUNCTION 'CS_WHERE_USED_MAT'
      EXPORTING
        datub                      = v_data_validade_final
        datuv                      = v_data_validade_inicial
        matnr                      = s_matnr-low
        postp                      = c_item_inventariado
        stlan                      = c_lista_tecnica_producao
        werks                      = v_centro
      TABLES
        wultb                      = t_lista_tecnica_aux
        equicat                    = t_equipamentos
        kndcat                     = t_ordens_cliente
        matcat                     = t_materiais
        stdcat                     = t_obj_standard
        tplcat                     = t_equipamentos2
        prjcat                     = t_lst_projeto
      EXCEPTIONS
        call_invalid               = 1
        material_not_found         = 2
        no_where_used_rec_found    = 3
        no_where_used_rec_selected = 4
        no_where_used_rec_valid    = 5
        OTHERS                     = 6.

    IF sy-subrc = 0.
      APPEND LINES OF t_lista_tecnica_aux TO t_lista_tecnica.
    ENDIF.

  ENDLOOP.

  IF t_lista_tecnica IS INITIAL.
    MESSAGE 'Dados não encontrados' TYPE 'S' DISPLAY LIKE 'E'. "#EC NOTEXT
    EXIT.
  ENDIF.

  LOOP AT t_lista_tecnica INTO w_lista_tecnica.
    CLEAR w_mara.
    w_mara-matnr = w_lista_tecnica-idnrk.
    APPEND w_mara TO t_mara.
  ENDLOOP.

  SORT t_mara BY matnr ASCENDING.

  DELETE ADJACENT DUPLICATES FROM t_mara.

  IF t_mara IS NOT INITIAL.
    SELECT matnr maktx
     FROM makt
     INTO TABLE t_makt
     FOR ALL ENTRIES IN t_mara
     WHERE matnr = t_mara-matnr.
  ENDIF.

  LOOP AT t_lista_tecnica INTO w_lista_tecnica.
    CLEAR w_makt.
    READ TABLE t_makt
    INTO w_makt
    WITH KEY matnr = w_lista_tecnica-idnrk.

    CLEAR w_alv.
    w_alv-werks = w_lista_tecnica-werks. " Centro
    w_alv-idnrk = w_lista_tecnica-idnrk. " Componente
    w_alv-maktx = w_makt-maktx         . " Descrição
    w_alv-matnr = w_lista_tecnica-matnr. " Material
    w_alv-ojtxb = w_lista_tecnica-ojtxb. " Descrição
    w_alv-ttidx = w_lista_tecnica-ttidx. " Índice
    w_alv-level = w_lista_tecnica-level. " Nível
    w_alv-bmeng = w_lista_tecnica-bmeng. " Quantidade básica
    w_alv-bmein = w_lista_tecnica-bmein. " Unidade de medida
    w_alv-datuv = w_lista_tecnica-datuv. " Válido desde
    w_alv-datub = w_lista_tecnica-datub. " Válido
    w_alv-posnr = w_lista_tecnica-posnr. " Item
    APPEND w_alv TO t_alv              .
  ENDLOOP.

  SORT t_lista_tecnica BY matnr ASCENDING.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = o_salv_table
                               CHANGING t_table      = t_alv ).

    CATCH cx_salv_msg INTO o_salv_msg.
      v_msg_erro = o_salv_msg->get_text( ).
      MESSAGE v_msg_erro TYPE 'S' DISPLAY LIKE 'E'.         "#EC NOTEXT
  ENDTRY.

* Define as colunas do ALV como otimizadas, para se ajustarem ao tamanho dos dados
  o_salv_columns = o_salv_table->get_columns( ).
  o_salv_columns->set_optimize( abap_true ).

* Exibe os botões da barra de status
  o_salv_functions = o_salv_table->get_functions( ).
  o_salv_functions->set_all( abap_true ).

* Exibe o relatório alv
  o_salv_table->display( ).