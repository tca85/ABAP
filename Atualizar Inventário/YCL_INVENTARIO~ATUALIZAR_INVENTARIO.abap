*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_INVENTARIO                                            *
* Método   : ATUALIZAR_INVENTARIO                                      *
*----------------------------------------------------------------------*
* Projeto  : Operador Logístico                                        *
* Módulo   : MM/WM                                                     *
* Funcional: Sergio Vieira de Alcântara / Danilo Morente Carrasco      *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Atualizar inventário LI11N                                *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  26.11.2014  #93085 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IM_T_INVENTARIO TYPE TP_INVENTARIO
*<-- EX_T_LOG	       TYPE TP_LOG

METHOD atualizar_inventario.
*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro TYPE t100-text.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_inventario TYPE me->ty_inventario,
    w_log        TYPE me->ty_log       .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  CALL FUNCTION 'L_INV_COUNT_EXT'
    EXPORTING
      i_commit                     = abap_true
    TABLES
      s_linv                       = ex_t_inventario
    EXCEPTIONS
      either_quantity_or_empty_bin = 1
      ivnum_not_found              = 2
      check_problem                = 3
      no_count_allowed             = 4
      l_inv_read                   = 5
      bin_not_in_ivnum             = 6
      counts_not_updated           = 7
      lock_error                   = 8
      OTHERS                       = 9.

  IF sy-subrc = 0.
    me->salvar_log( im_t_log = ex_t_log ).
  ELSE.
*   Erro na atualização do inventário LI11N
    MESSAGE e013(yol) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_ol EXPORTING mensagem = v_msg_erro.
  ENDIF.

ENDMETHOD.