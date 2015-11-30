*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Super-classe: CL_BSP_CONTROLLER2                                     *
* Sub-classe  : YCL_CONTROLLER_APONTAMENTO_OP                          *
* Método      : DO_REQUEST                                             *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          *
* Descrição: Método redefinido para associar o evento solicitado ao    *
*            controller                                                *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

METHOD do_request.
  me->dispatch_input( ).
ENDMETHOD.