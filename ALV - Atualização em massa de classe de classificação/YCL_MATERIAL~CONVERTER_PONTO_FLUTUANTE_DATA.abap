*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* Método   : CONVERTER_PONTO_FLUTUANTE_DATA                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Converter ponto flutuante em data                         *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  16.09.2015  #121646 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD converter_ponto_flutuante_data.
*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_data         TYPE cawn-atwrt,
    v_data_interna TYPE sy-datum  .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  CALL FUNCTION 'CTCV_CONVERT_FLOAT_TO_DATE'
    EXPORTING
      float = im_valor
    IMPORTING
      date  = v_data.

  v_data_interna = v_data.

  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = v_data_interna
    IMPORTING
      date_external            = ex_valor_convertido
    EXCEPTIONS                                              "#EC *
      date_internal_is_invalid = 1
      OTHERS                   = 2.

ENDMETHOD.