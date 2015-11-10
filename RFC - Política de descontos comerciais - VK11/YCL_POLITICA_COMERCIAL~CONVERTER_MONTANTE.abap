*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_POLITICA_COMERCIAL                                    *
* Método   : CONVERTER_MONTANTE                                        *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Converter montante em formato texto para moeda            *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.06.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IM_MONTANTE  TYPE CHAR13
*<-- VALUE( EX_MONTANTE )	TYPE BAPICUREXT

METHOD converter_montante.
  DATA v_mont_char TYPE char30.

  v_mont_char = im_montante.

  CALL FUNCTION 'C14DG_CHAR_NUMBER_CONVERSION'
    EXPORTING
      i_string                   = v_mont_char
    IMPORTING
      e_dec                      = ex_montante
    EXCEPTIONS
      wrong_characters           = 1
      first_character_wrong      = 2
      arithmetic_sign            = 3
      multiple_decimal_separator = 4
      thousandsep_in_decimal     = 5
      thousand_separator         = 6
      number_too_big             = 7
      OTHERS                     = 8.

  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE ycx_pc EXPORTING msg = 'Erro na conversão do montante'. "#EC NOTEXT
  ENDIF.

ENDMETHOD.
