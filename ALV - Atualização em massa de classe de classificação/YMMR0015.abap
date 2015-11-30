REPORT ymmr0015 NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
*                 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                   *
*----------------------------------------------------------------------*
* Programa...: YMMR0015                                                *
* Transação..: YMMR0015                                                *
* Descrição..: Cadastro/Atualização em massa da classe de classificação*
*              do cadastro de materiais (Validade do Registro)         *
* Tipo.......: ALV                                                     *
* Módulo.....: MM                                                      *
* Solicitante: xxxxxxxxxxxxxxxxxxxxxxxxxx                              *
* ABAP.......: Thiago Cordeiro Alves                                   *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  16.09.2015  #121646 - Desenvolvimento inicial              *
* ACTHIAGO  25.11.2015  #135533 - Incluir classe quando não existir    *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
TYPES:
 BEGIN OF ty_tela       ,
   klart TYPE ksml-klart, " Tipo de classe
   imerk TYPE ksml-imerk, " Característica interna
 END OF ty_tela         .

*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
DATA:
  t_alv_retorno TYPE STANDARD TABLE OF ycl_material=>ty_alv_cl_classif.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
DATA:
  w_tela TYPE ty_tela.

*----------------------------------------------------------------------*
* Variáveis tipo referência
*----------------------------------------------------------------------*
DATA:
  o_material    TYPE REF TO ycl_material,
  o_cx_material TYPE REF TO ycx_material.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
DATA:
  v_msg_erro TYPE string.

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
CONSTANTS:
  c_campo_desabilitado TYPE c LENGTH 01 VALUE '0',
  c_campo_habilitado   TYPE c LENGTH 01 VALUE '1'.

*----------------------------------------------------------------------*
* Tela de seleção
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE t001              .
SELECTION-SCREEN BEGIN OF LINE                                        .
SELECTION-SCREEN COMMENT 1(14) text-001                               . " Tipo da classe
SELECTION-SCREEN POSITION 16                                          .
PARAMETER: p_klart LIKE w_tela-klart MODIF ID klt                     . " Tipo de classe
SELECTION-SCREEN POSITION 26                                          .
SELECTION-SCREEN COMMENT 22(30) v_dsc                                 .
SELECTION-SCREEN END OF LINE                                          .
SELECTION-SCREEN END OF BLOCK b0                                      .

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t002              .
PARAMETER: p_imerk LIKE w_tela-imerk OBLIGATORY                       . " Característica Interna
SELECTION-SCREEN END OF BLOCK b1                                      .

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE t003              .
PARAMETER: p_arquiv TYPE rlgrap-filename DEFAULT 'C:\Temp\' OBLIGATORY. "#EC NOTEXT
SELECTION-SCREEN END OF BLOCK b2                                      .

*----------------------------------------------------------------------*
* Initialization
*----------------------------------------------------------------------*
INITIALIZATION.
  t001    = 'Tipo de classe'                            .   "#EC NOTEXT
  t002    = 'Característica interna'                    .   "#EC NOTEXT
  t003    = 'Planilha de materiais'                     .   "#EC NOTEXT
  p_klart = ycl_material=>c_classe_material             .   " 001
  v_dsc   = ycl_material=>get_dsc_tipo_classe( p_klart ).

*----------------------------------------------------------------------*
* At Selection-Screen Output - PBO
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'KLT'.
      screen-input = c_campo_desabilitado.
      MODIFY SCREEN.
      CONTINUE.
    ENDIF.
  ENDLOOP.

*----------------------------------------------------------------------*
* Process On Value Request
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_arquiv.
  p_arquiv = ycl_material=>selecionar_planilha( ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_imerk.
  CREATE OBJECT o_material TYPE ycl_material.
  p_imerk = o_material->caracteristicas_internas_f4( p_klart ).

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
START-OF-SELECTION.
  IF o_material IS NOT BOUND.
    CREATE OBJECT o_material TYPE ycl_material.
  ENDIF.

  TRY.
*     Verifica se a característica interna da tela de seleção está correta
*     antes mesmo de fazer upload do arquivo xls
      o_material->validar_caracteristica_interna( im_classe_material = p_klart
                                                  im_caracteristica  = p_imerk ).

      o_material->importar_excel( p_arquiv ).

      t_alv_retorno = o_material->modificar_classe_classificacao( ).

      o_material->exibir_alv_cl_classificacao( t_alv_retorno ).

    CATCH ycx_material INTO o_cx_material.
      v_msg_erro = o_cx_material->msg.
      MESSAGE v_msg_erro TYPE 'S' DISPLAY LIKE 'E'.
  ENDTRY.
