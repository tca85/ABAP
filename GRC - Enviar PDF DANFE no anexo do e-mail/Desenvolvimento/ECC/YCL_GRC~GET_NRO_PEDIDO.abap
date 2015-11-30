*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_GRC                                                   *
* Método   : GET_NRO_PEDIDO_CLIENTE                                    *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obtém o número do pedido do cliente <xped>                *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  08.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_nro_pedido_cliente.
*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_docnum TYPE docnum.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  v_docnum = im_nro_documento.

  CALL FUNCTION 'YNFEXML_RETURN_XPED'
    EXPORTING
      i_docnum = v_docnum
    IMPORTING
      e_xped   = rt_nro_pedido.

ENDMETHOD.