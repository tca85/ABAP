*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_ECC                                                   *
* Método   : GET_DANFE_NFE                                             *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obtém o DANFE (pdf) da NF-e                               *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  09.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_danfe_nfe.
*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
  TYPES:
    BEGIN OF ty_binary    ,
      content TYPE ssfdata,
    END OF ty_binary      .

*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_pdf_danfe TYPE STANDARD TABLE OF ty_binary.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro          TYPE string     ,                   "#EC NEEDED
    v_nome_rfc_ecc      TYPE rs38l-name ,
    v_rfc_destination   TYPE bdbapidst  ,
    v_pdf               TYPE xstring    ,
    v_tamanho_anexo_ecc TYPE i          .

*----------------------------------------------------------------------*
* Variáveis tipo referência
*----------------------------------------------------------------------*
  DATA:
    o_cx_ecc  TYPE REF TO ycx_ecc,
    o_cx_root TYPE REF TO cx_root.

*----------------------------------------------------------------------*
* Contantes
*----------------------------------------------------------------------*
  CONSTANTS:
    c_rfc_ecc TYPE rs38l-name VALUE 'YGRC_ANEXA_DANFE_EMAIL'.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  TRY.
      me->testar_rfc_destination( EXPORTING im_sistema_logico  = w_nfe-logsys         " Sistema lógico
                                            im_nome_rfc_ecc    = c_rfc_ecc            " RFC criada no ECC
                                  CHANGING  ex_nome_rfc_ecc    = v_nome_rfc_ecc       " Confirmação da RFC encontrada
                                            ex_rfc_destination = v_rfc_destination ). " Nome da RFC Destination
    CATCH ycx_ecc INTO o_cx_ecc.
      v_msg_erro = o_cx_ecc->msg.
  ENDTRY.

  IF v_nome_rfc_ecc IS INITIAL.
    RETURN.
  ENDIF.

  TRY.

*     Chamar função YGRC_ANEXA_DANFE_EMAIL no ECC para carregar DANFE em binario
      CALL FUNCTION v_nome_rfc_ecc
        DESTINATION v_rfc_destination
        EXPORTING
          i_docnum              = w_nfe-docnum
        IMPORTING
          e_pdf_data            = t_pdf_danfe
          e_bin_size            = v_tamanho_anexo_ecc
        EXCEPTIONS
          communication_failure = 1
          system_failure        = 2.

      IF sy-subrc = 0.
        CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
          EXPORTING
            input_length = v_tamanho_anexo_ecc
          IMPORTING
            buffer       = v_pdf
          TABLES
            binary_tab   = t_pdf_danfe
          EXCEPTIONS
            failed       = 1
            OTHERS       = 2.

        IF sy-subrc = 0.
          cl_document_bcs=>xstring_to_solix( EXPORTING ip_xstring = v_pdf
                                             RECEIVING rt_solix   = t_pdf_binario ).
        ENDIF.
      ENDIF.

    CATCH cx_root INTO o_cx_root.
      v_msg_erro = o_cx_root->get_text( ).
  ENDTRY.

ENDMETHOD.