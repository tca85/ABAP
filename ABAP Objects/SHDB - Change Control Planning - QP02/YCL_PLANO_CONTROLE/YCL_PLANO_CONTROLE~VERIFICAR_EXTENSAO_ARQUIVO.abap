*----------------------------------------------------------------------*
* Classe   : YCL_PLANO_CONTROLE                                        *
* Método   : VERIFICAR_EXTENSAO_ARQUIVO                                *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Verificar se a extensão do arquivo importado é XLSX       *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.01.2016  #142490 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD verificar_extensao_arquivo.
*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
   v_extensao TYPE string,
   v_msg_erro TYPE string.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  FIND REGEX '[.](.*)$' IN im_nome_arquivo SUBMATCHES v_extensao.

  TRANSLATE v_extensao TO UPPER CASE.
  CONDENSE v_extensao NO-GAPS.

  IF v_extensao IS INITIAL.
*   Selecione a planilha do Excel para importar.
    MESSAGE e005(yplano_controle) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_plano_controle EXPORTING msg = v_msg_erro.

  ELSEIF v_extensao <> 'XLSX'.                              "#EC NOTEXT
*   Formato inválido. Somente XLSX é suportado.
    MESSAGE e006(yplano_controle) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_plano_controle EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.
