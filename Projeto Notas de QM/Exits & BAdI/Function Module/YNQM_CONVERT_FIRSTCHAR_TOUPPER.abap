FUNCTION ynqm_convert_firstchar_toupper.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(INPUT_STRING) TYPE  C
*"     VALUE(SEPARATORS) TYPE  C DEFAULT ' -.,;:'
*"  EXPORTING
*"     VALUE(OUTPUT_STRING) TYPE  C
*"----------------------------------------------------------------------

  DATA: pos     LIKE sy-fdpos,
        pos_max LIKE sy-fdpos.
  FIELD-SYMBOLS: <poi>, <hpoi>, <rest>.

  CHECK NOT input_string IS INITIAL.

  output_string = input_string.

  TRANSLATE output_string TO LOWER CASE.                  "#EC SYNTCHAR
*
  pos_max = STRLEN( output_string ) - 1.
*
  pos = 0.
  ASSIGN output_string+pos(1) TO <poi>.
  ASSIGN input_string+pos(1)  TO <hpoi>.
  <poi> = <hpoi>.
*
  ASSIGN input_string+pos(*) TO <rest>.
  WHILE <rest> CA separators.
    pos = pos + sy-fdpos + 1.
    IF pos > pos_max. EXIT. ENDIF.
    ASSIGN output_string+pos(1) TO <poi>.
    ASSIGN input_string+pos(1)  TO <hpoi>.
    <poi> = <hpoi>.
    ASSIGN input_string+pos(*) TO <rest>.
  ENDWHILE.
*
ENDFUNCTION.
