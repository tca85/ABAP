*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : GET_INSTANCE                                              *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Cria a classe YCL_APTO_OP utilizando design pattern       *
*            Singleton - ver: http://oprsteny.com/?p=1113              *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*<-- RETURNING VALUE( EX_INSTANCIA )  TYPE REF TO YCL_APTO_OP

METHOD get_instance.

  TRY.
      DATA:
        v_msg_erro TYPE string        ,
        o_cx_apo   TYPE REF TO ycx_apo.

      IF apto_op IS NOT BOUND.
*       Cria a classe privada após chamar o método Constructor
*       que verifica se o usuário tem permissão e se ele está inativo há mais de 20 minutos
        CREATE OBJECT apto_op TYPE ycl_apontamento_op.
      ENDIF.

*     retorna a instância da classe
      ex_instancia = apto_op.

    CATCH ycx_apo INTO o_cx_apo.
      v_msg_erro = o_cx_apo->msg.
      RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDTRY.

ENDMETHOD.