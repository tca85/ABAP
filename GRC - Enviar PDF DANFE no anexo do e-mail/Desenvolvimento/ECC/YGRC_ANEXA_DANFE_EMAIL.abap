FUNCTION ygrc_anexa_danfe_email.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_DOCNUM) TYPE  J_1BDOCNUM
*"  EXPORTING
*"     VALUE(E_PDF_DATA) TYPE  YCT_HRB2A_RAW255
*"     VALUE(E_BIN_SIZE) TYPE  I
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Módulo de Função : YGRC_ANEXA_DANFE_EMAIL                            *
* Grupo de Funções : YGF_GRC_ECC                                       *
*----------------------------------------------------------------------*
* Descrição: RFC para converter o DANFE da NF-e em binário             *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome       Data        Descrição                                     *
* DGECARLOS  01.09.2015  #109075 - Codificação inicial                 *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
     t_linhas_pdf  TYPE STANDARD TABLE OF tline,
     t_pdf_binario TYPE TABLE OF hrb2a_raw255  ,
     lt_otfdata    TYPE ssfcrescl              .

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
     v_bin_size      TYPE i      ,
     v_qtd_registros TYPE i      ,
     v_bin_file      TYPE xstring.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  SELECT COUNT( DISTINCT docnum )
   FROM j_1bnfdoc
   INTO v_qtd_registros
   WHERE docnum = i_docnum.

  IF v_qtd_registros <> 0.
    PERFORM entry_pdf IN PROGRAM znfe_print_danfe USING i_docnum.
    IMPORT lt_otfdata-otfdata TO lt_otfdata-otfdata FROM MEMORY ID 'TAB_OTF'.
  ENDIF.

  IF lt_otfdata-otfdata[] IS INITIAL.
    EXIT.
  ENDIF.

* Converter PDF em OTF
  CALL FUNCTION 'CONVERT_OTF'
    EXPORTING
      format                = 'PDF'
    IMPORTING
      bin_filesize          = v_bin_size
      bin_file              = v_bin_file
    TABLES
      otf                   = lt_otfdata-otfdata[]
      lines                 = t_linhas_pdf
    EXCEPTIONS
      err_max_linewidth     = 1
      err_format            = 2
      err_conv_not_possible = 3
      err_bad_otf           = 4
      OTHERS                = 5.

  IF sy-subrc = 0.
*   Converte a DANFE em binário
    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = v_bin_file
      IMPORTING
        output_length = v_bin_size
      TABLES
        binary_tab    = t_pdf_binario.

    e_pdf_data[] = t_pdf_binario[].
    e_bin_size   = v_bin_size     .
  ENDIF.

ENDFUNCTION.