*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : CONVERTER_CHAR_QTY                                        *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Converte campo char em quantity                           *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_VALOR_CHAR         TYPE CHAR30
*<-- RETURNING VALUE( EX_VALOR_QTY ) TYPE MENGV13

METHOD converter_char_qty.

  DATA w_tab_field TYPE tabfield.

  w_tab_field-tabname   = 'AFRUD'.
  w_tab_field-fieldname = 'LMNGA'.

  CALL FUNCTION 'RS_CONV_EX_2_IN'
    EXPORTING
      input_external  = im_valor_char
      table_field     = w_tab_field
    IMPORTING
      output_internal = ex_valor_qty.

ENDMETHOD.