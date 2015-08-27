*----------------------------------------------------------------------*
* Classe   : YCL_GKO                                                   *
* Método   : GRAVAR_TABELA_ECC_CTE                                     *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Gravar tabela do ECC com CT-e emitido contra CNPJ do xxxxx *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  10.08.2015  #108147 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD gravar_tabela_ecc_cte.
*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
    t_rfc_cte TYPE STANDARD TABLE OF ty_rfc_cte,
    t_tag_cte TYPE STANDARD TABLE OF ty_xml    .

  DATA:
    t_nf_cte  TYPE /xnfe/inctenfcl_t       ,                "#EC NEEDED
    t_nfe_cte TYPE /xnfe/inctenfe_t        ,                "#EC NEEDED
    t_proxy   TYPE /xnfe/proxy_structures_t.                "#EC NEEDED

  DATA:
    t_tag_emit_cte TYPE STANDARD TABLE OF ty_tag_emit_cte.

*----------------------------------------------------------------------*
* Work-areas
*----------------------------------------------------------------------*
  DATA:
    w_rfc_cte      LIKE LINE OF t_rfc_cte     ,
    w_nfe_cte      LIKE LINE OF t_nfe_cte     ,
    w_tag_emit_cte LIKE LINE OF t_tag_emit_cte.

  DATA:
    w_cabecalho_cte TYPE /xnfe/inctehd.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_rfc_destination TYPE bdbapidst ,
    v_msg_erro        TYPE string    ,
    v_cte_xstring     TYPE xstring   ,
    v_rfc_sap_ecc     TYPE rs38l-name.

*----------------------------------------------------------------------*
* Objetos
*----------------------------------------------------------------------*
  DATA:
    o_cx_gko TYPE REF TO ycx_gko.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  TRY.
      IF im_cte-cte IS INITIAL
        OR im_cte-prot_cte IS INITIAL.
        RETURN.
      ENDIF.

      CALL FUNCTION '/XNFE/CTE_TRANSFORMER_CREATE'
        EXPORTING
          iv_cte_xstring          = im_cte-cte
          iv_protcte_xstring      = im_cte-prot_cte
        IMPORTING
          ev_ctexstring           = v_cte_xstring
          es_inctehd              = w_cabecalho_cte
          et_inctenf              = t_nf_cte
          et_inctenfe             = t_nfe_cte
          et_structures           = t_proxy
        EXCEPTIONS
          cx_proxy_fault          = 1
          cx_transformation_error = 2
          invalid_call            = 3
          mapping_error           = 4
          OTHERS                  = 5.

      IF sy-subrc <> 0.
*       Erro durante a conversão do XML do CT-e
        MESSAGE e004(ygko) INTO v_msg_erro.
        RAISE EXCEPTION TYPE ycx_gko EXPORTING msg = v_msg_erro.
      ENDIF.

*     Verifica se é um CT-e contra o Aché
      me->verificar_cte_contra_cnpj_ache( w_cabecalho_cte-cnpj_dest ).

*     Verifica se a destination está ativa, e se a RFC existe no ECC
      me->get_rfc_cte( EXPORTING im_id_cte          = w_cabecalho_cte-cteid
                        CHANGING ex_nome_rfc        = v_rfc_sap_ecc
                                 ex_rfc_destination = v_rfc_destination ).

*     Obtém as tags do CT-e
      t_rfc_cte = me->get_tags_cte( im_xml       = v_cte_xstring
                                    im_cteid     = w_cabecalho_cte-cteid
                                    im_t_nfe_cte = t_nfe_cte ).

*     Executa de forma síncrona a RFC do SAP ECC
*     ----> YGKO_CARGA_CTE_GRC
      IF v_rfc_sap_ecc IS NOT INITIAL
         AND t_rfc_cte IS NOT INITIAL.

        CALL FUNCTION v_rfc_sap_ecc
          DESTINATION v_rfc_destination
          EXPORTING
            t_gko_cte             = t_rfc_cte
          EXCEPTIONS "#EC FB_RC
            system_failure        = 1
            communication_failure = 2
            OTHERS                = 99.
      ENDIF.

    CATCH ycx_gko INTO o_cx_gko.
      RAISE EXCEPTION TYPE ycx_gko EXPORTING msg = o_cx_gko->msg.
  ENDTRY.

ENDMETHOD.