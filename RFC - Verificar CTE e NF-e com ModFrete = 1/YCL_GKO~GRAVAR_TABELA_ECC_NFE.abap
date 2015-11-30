*----------------------------------------------------------------------*
* Classe   : YCL_GKO                                                   *
* Método   : GRAVAR_TABELA_ECC_NFE                                     *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Gravar tabela do ECC com NF-e que tem a tag <modFrete> = 1*
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  10.08.2015  #108147 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD gravar_tabela_ecc_nfe.
*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
    t_rfc_nfe TYPE STANDARD TABLE OF ty_rfc_nfe.

  DATA:
    t_nfe_entrada  TYPE /xnfe/innfenfcl_t,                  "#EC NEEDED
    t_nfe_entrada2 TYPE /xnfe/innfenfe_t ,                  "#EC NEEDED
    t_nfe_item     TYPE /xnfe/innfeit_t  ,                  "#EC NEEDED
    w_nfe_header   TYPE /xnfe/innfehd    .

*----------------------------------------------------------------------*
* Work-areas
*----------------------------------------------------------------------*
  DATA:
    w_rfc_nfe LIKE LINE OF t_rfc_nfe.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_rfc_destination TYPE bdbapidst ,
    v_msg_erro        TYPE string    ,
    v_rfc_sap_ecc     TYPE rs38l-name,
    v_indice          TYPE sy-tabix  .

*----------------------------------------------------------------------*
* Objetos
*----------------------------------------------------------------------*
  DATA:
    o_cx_gko TYPE REF TO ycx_gko.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  TRY.
      IF im_xml_nfe IS INITIAL.
        RETURN.
      ENDIF.

*     Converte o XML recebido em XString em algumas tabelas internas
      CALL FUNCTION '/XNFE/NFE_TRANSFORMER_CREATE'
        EXPORTING
          iv_xstring              = im_xml_nfe
        IMPORTING
          es_innfehd              = w_nfe_header
          et_innfenfcl            = t_nfe_entrada
          et_innfenfe             = t_nfe_entrada2
          et_innfeit              = t_nfe_item
        EXCEPTIONS
          cx_proxy_fault          = 1
          cx_transformation_error = 2
          invalid_call            = 3
          mapping_error           = 4
          OTHERS                  = 5.

      IF sy-subrc <> 0.
*       Erro durante a conversão do XML da NF-e
        MESSAGE e009(ygko) INTO v_msg_erro.
        RAISE EXCEPTION TYPE ycx_gko EXPORTING msg = v_msg_erro.
      ENDIF.

*     Obtém as tags do XML de NF-e
      t_rfc_nfe = get_tags_nfe( im_xml_nfe ).

*     Verifica se a destination está ativa, e se a RFC existe no ECC
      me->get_rfc_nfe( EXPORTING im_id_nfe          = w_nfe_header-nfeid
                        CHANGING ex_nome_rfc        = v_rfc_sap_ecc
                                 ex_rfc_destination = v_rfc_destination ).

      IF w_nfe_header-nfeid IS NOT INITIAL.

        LOOP AT t_rfc_nfe INTO w_rfc_nfe.
          v_indice = sy-tabix.
          w_rfc_nfe-nfe    = w_nfe_header-nfeid       . " NF-e
          w_rfc_nfe-nfenum = w_nfe_header-nfeid+25(09). " Número do documento
          MODIFY t_rfc_nfe INDEX v_indice FROM w_rfc_nfe.
        ENDLOOP.

      ELSE.
        FREE t_rfc_nfe.
      ENDIF.

*     Executa de forma síncrona a RFC do SAP ECC -> YGKO_CARGA_NFE_GRC
      IF v_rfc_sap_ecc IS NOT INITIAL
         AND t_rfc_nfe IS NOT INITIAL.

        CALL FUNCTION v_rfc_sap_ecc
          DESTINATION v_rfc_destination
          EXPORTING
            t_gko_nfe_grc         = t_rfc_nfe
          EXCEPTIONS "#EC FB_RC
            system_failure        = 1
            communication_failure = 2
            OTHERS                = 99.
      ENDIF.

    CATCH ycx_gko INTO o_cx_gko.
      RAISE EXCEPTION TYPE ycx_gko EXPORTING msg = o_cx_gko->msg.
  ENDTRY.

ENDMETHOD.