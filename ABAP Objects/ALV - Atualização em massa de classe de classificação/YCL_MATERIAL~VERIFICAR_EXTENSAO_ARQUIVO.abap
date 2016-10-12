*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* Método   : VERIFICAR_EXTENSAO_ARQUIVO                                *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Verificar se a extensão do arquivo importado é XLSX       *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  16.09.2015  #121646 - Desenvolvimento inicial              *
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
    MESSAGE e007(ymaterial) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_material EXPORTING msg = v_msg_erro.
  ELSEIF v_extensao <> 'XLSX'.                              "#EC NOTEXT
*   Formato inválido. Somente XLSX é suportado.
    MESSAGE e001(ymaterial) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_material EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.