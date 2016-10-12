*----------------------------------------------------------------------*
* Classe   : YCL_PLANO_CONTROLE                                        *
* Método   : IMPORTAR_EXCEL                                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Importar arquivo excel para tabela interna                *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.01.2016  #142490 - Desenvolvimento inicial              *
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
    t_raw_data TYPE truxs_t_text_data.

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
      i_tab_converted_data = t_excel_qp02
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF t_excel_qp02 IS INITIAL.
*   Não há dados na planilha importada
    MESSAGE e003(yplano_controle) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_plano_controle EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.
