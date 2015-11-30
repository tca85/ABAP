*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* Método   : IMPORTAR_EXCEL                                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Importar arquivo excel para tabela interna                *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  16.09.2015  #121646 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD importar_excel.
  TYPE-POOLS truxs.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro TYPE string.

*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
    t_excel    TYPE STANDARD TABLE OF ty_excel,
    t_raw_data TYPE truxs_t_text_data         .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  me->verificar_extensao_arquivo( im_nome_arquivo ).

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_tab_raw_data       = t_raw_data
      i_filename           = im_nome_arquivo
      i_line_header        = abap_true
    TABLES
      i_tab_converted_data = t_excel
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF sy-subrc <> 0.
*   Erro no arquivo importado
    MESSAGE e002(ymaterial) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_material EXPORTING msg = v_msg_erro.
  ENDIF.

  IF t_excel IS NOT INITIAL.
    APPEND LINES OF t_excel TO me->t_excel.
  ELSE.
*   Não há dados na planilha importada
    MESSAGE e003(ymaterial) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_material EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.