*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* Método   : SELECIONAR_PLANILHA                                       *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Selecionar planilha do excel através do file_open_dialog  *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  16.09.2015  #121646 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD selecionar_planilha.
*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
     t_filetable TYPE filetable.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
     w_filetable LIKE LINE OF t_filetable.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
     v_filtro_selecao TYPE string,
     v_titulo_popup   TYPE string,
     v_cod_retorno    TYPE i     .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  v_titulo_popup   = 'Selecione a planilha de carga'.       "#EC NOTEXT
  v_filtro_selecao = 'Excel (*.xlsx)|*.xlsx|'       .       "#EC NOTEXT

  cl_gui_frontend_services=>file_open_dialog( EXPORTING window_title            = v_titulo_popup
                                                        file_filter             = v_filtro_selecao
                                               CHANGING file_table              = t_filetable
                                                        rc                      = v_cod_retorno
                                             EXCEPTIONS file_open_dialog_failed = 1
                                                        cntl_error              = 2
                                                        error_no_gui            = 3
                                                        not_supported_by_gui    = 4
                                                        OTHERS                  = 5 ).

  IF sy-subrc = 0.
    READ TABLE t_filetable
    INTO w_filetable
    INDEX 1.

    IF w_filetable-filename IS NOT INITIAL.
      ex_nome_arquivo = w_filetable-filename.
    ENDIF.
  ENDIF.

ENDMETHOD.