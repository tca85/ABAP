*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                     *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : SET_RECURSO                                               *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obter recursos (CRHD-ARBPL)                               *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> CHANGING EX_RECURSO  TYPE CRHD-ARBPL

METHOD set_recurso.
  DATA:
     v_qtd_reg  TYPE i     ,
     v_msg_erro TYPE string.

* Perfil de usuário com acesso total
  IF ex_recurso = '*'.
    EXIT.
  ELSE.
    SELECT COUNT( DISTINCT arbpl )
     FROM crhd
     INTO v_qtd_reg
     WHERE arbpl = ex_recurso.

    IF v_qtd_reg IS INITIAL.
      CLEAR ex_recurso.

*     Recurso inexistente
      MESSAGE e003(yapo) INTO v_msg_erro.
      RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
    ENDIF.
  ENDIF.

ENDMETHOD.