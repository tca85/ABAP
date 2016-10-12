*----------------------------------------------------------------------*
* Classe   : YCL_PLANO_CONTROLE                                        *
* Método   : CONVERTER_FLOAT_DECIMAL                                   *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Converter float para decimal                              *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.07.2015  #111437 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD converter_float_decimal.

  CALL FUNCTION 'C14W_NUMBER_CHAR_CONVERSION'
    EXPORTING
      i_float        = float
    IMPORTING
      e_dec          = decimal
    EXCEPTIONS
      number_too_big = 1
      OTHERS         = 2.

ENDMETHOD.
