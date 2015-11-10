FUNCTION ysd_criar_politica_comercial.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(T946) TYPE  YCT_A946 OPTIONAL
*"     VALUE(T947) TYPE  YCT_A947 OPTIONAL
*"     VALUE(T960) TYPE  YCT_A960 OPTIONAL
*"     VALUE(T963) TYPE  YCT_A963 OPTIONAL
*"     VALUE(T972) TYPE  YCT_A972 OPTIONAL
*"     VALUE(T962) TYPE  YCT_A962 OPTIONAL
*"     VALUE(T968) TYPE  YCT_A968 OPTIONAL
*"     VALUE(T961) TYPE  YCT_A961 OPTIONAL
*"     VALUE(T969) TYPE  YCT_A969 OPTIONAL
*"  EXPORTING
*"     VALUE(T_RETORNO) TYPE  YCT_MENSAGENS
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Módulo de Função : YSD_CRIAR_POLITICA_COMERCIAL                      *
* Grupo de Funções : YSD_VK15                                          *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Cria as políticas de desconto comerciais (YDEC) na        *
*            transação VK15. Para consultar, verificar a VK13          *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  24.06.2015  #97992 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

  TRY.
      DATA:
        o_politica_comercial TYPE REF TO ycl_politica_comercial,
        o_cx_pc              TYPE REF TO ycx_pc                ,
        w_retorno            TYPE ymensagens                   ,
        v_msg_exception      TYPE string                       .

      o_politica_comercial = ycl_politica_comercial=>get_instance( ).

      o_politica_comercial->set_chave_a946( t946 ). " EscrVendas/Cliente/Material/Lote/Tipo ped.
      o_politica_comercial->set_chave_a947( t947 ). " EscrVendas/Cliente/Material/Tipo ped.
      o_politica_comercial->set_chave_a960( t960 ). " EscrVendas/Cliente/Material
      o_politica_comercial->set_chave_a963( t963 ). " EscrVendas/Cliente/Grupo mat.
      o_politica_comercial->set_chave_a972( t972 ). " EscrVendas/Região/Material
      o_politica_comercial->set_chave_a962( t962 ). " EscrVendas/Material
      o_politica_comercial->set_chave_a968( t968 ). " EscrVendas/GrpClients/Grupo mat./Material
      o_politica_comercial->set_chave_a961( t961 ). " EscrVendas/GrpClients/Grupo mat.
      o_politica_comercial->set_chave_a969( t969 ). " EscrVendas/Região/Grupo mat.

      t_retorno = o_politica_comercial->get_msg_retorno( ).

    CATCH ycx_pc INTO o_cx_pc.
      v_msg_exception = o_cx_pc->msg             .
      w_retorno-tipo  = 'E'                      .
      WRITE v_msg_exception TO w_retorno-mensagem.
      APPEND w_retorno TO t_retorno              .
  ENDTRY.

ENDFUNCTION.
