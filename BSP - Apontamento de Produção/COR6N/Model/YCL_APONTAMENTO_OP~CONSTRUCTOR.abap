*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : CONSTRUCTOR                                               *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Faz as validações iniciais no momento de criar a classe   *
*            como verificar se o usuário tem permissão de acesso à     *
*            página BSP e se ele está conectado há mais de 20 minutos  *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD constructor.

  TRY.
      DATA:
         v_msg_erro   TYPE string        ,
         w_permissoes TYPE ty_permissao  ,                  "#EC NEEDED
         o_cx_apo     TYPE REF TO ycx_apo.

*     Verifica se o usuário está com acesso (tabela YAPT001)
      w_permissoes = get_permissoes_usuario( sy-uname ).

*     Verifica se o usuário está conectado há mais de 20 minutos
      get_tempo_conexao( sy-uname ).

    CATCH ycx_apo INTO o_cx_apo .
      v_msg_erro = o_cx_apo->msg.
      RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDTRY.

ENDMETHOD.