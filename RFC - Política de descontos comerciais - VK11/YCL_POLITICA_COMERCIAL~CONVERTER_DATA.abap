*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_POLITICA_COMERCIAL                                    *
* Método   : CONVERTER_DATA                                            *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Converter data DD.MM.YYYY para YYYYMMDD                   *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.06.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IM_DATA  TYPE CHAR10
*<-- VALUE( EX_DATA )	TYPE SY-DATUM

METHOD converter_data.

  CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
    EXPORTING
      date_external            = im_data
    IMPORTING
      date_internal            = ex_data
    EXCEPTIONS
      date_external_is_invalid = 1
      OTHERS                   = 2.

  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE ycx_pc EXPORTING msg = 'Erro na conversão de data'. "#EC NOTEXT
  ENDIF.

ENDMETHOD.
