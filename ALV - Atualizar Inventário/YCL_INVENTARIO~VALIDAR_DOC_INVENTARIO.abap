*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                   *
*----------------------------------------------------------------------*
* Classe   : YCL_INVENTARIO                                            *
* Método   : VALIDAR_DOC_INVENTARIO                                    *
*----------------------------------------------------------------------*
* Projeto  : Operador Logístico                                        *
* Módulo   : MM/WM                                                     *
* Funcional: xxxxxxxxxxxxxxxxxxxxxxxxx                                 *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Atualizar inventário LI11N                                *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  26.11.2014  #93085 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IM_DEPOSITO       TYPE LINV-LGNUM Nº depósito/complexo de depósito
*--> IM_DOC_INVENTARIO TYPE LINV-IVNUM Nº documento de inventário

METHOD validar_doc_inventario.
  DATA:
    v_qtd_registros TYPE i        ,
    v_msg_erro      TYPE t100-text.

  SELECT COUNT( DISTINCT lgnum )
   FROM linv
   INTO v_qtd_registros
   WHERE lgnum = im_deposito
     AND ivnum = im_doc_inventario.

  IF v_qtd_registros = 0.
*   Depósito e documento não encontrados
    MESSAGE e010(yol) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_ol EXPORTING mensagem = v_msg_erro.
  ENDIF.

ENDMETHOD.