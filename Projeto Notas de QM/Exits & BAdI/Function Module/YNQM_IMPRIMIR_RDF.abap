FUNCTION ynqm_imprimir_rdf.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_VIQMEL) LIKE  VIQMEL STRUCTURE  VIQMEL
*"     VALUE(I_CUSTOMIZING) LIKE  V_TQ85 STRUCTURE  V_TQ85
*"  TABLES
*"      TI_IVIQMFE STRUCTURE  WQMFE
*"      TI_IVIQMUR STRUCTURE  WQMUR
*"      TI_IVIQMSM STRUCTURE  WQMSM
*"      TI_IVIQMMA STRUCTURE  WQMMA
*"      TI_IHPA STRUCTURE  IHPA
*"  EXCEPTIONS
*"      ACTION_STOPPED
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*                       xxxxxxxxxxxxxxxxxx                             *
*----------------------------------------------------------------------*
* Transação: QM01                                                      *
* Função definida dentro do Customizing                                *
*----------------------------------------------------------------------*
* SPRO > Administração de Qualidade > Nota QM > Processamento Notas >  *
*        Funções de nota adicionais > Definir Barra de Atividades      *
* Função: 0051 - Imprimir Rel. Desvio Fornecedor                       *
* Tipo de Nota: Z1 - RNC Fornecedor                                    *
*----------------------------------------------------------------------*
* Objetivo : Preenchimento e impressão do SmartForm da RDF             *
* Módulo   : QM                                                        *
* Projeto  : Notas de QM (Não-conformidade no recebimento físico)      *
* Funcional: xxxxxxxxxxxxxxxxxxxx                                      *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  04.12.2013  #63782 - Desenvolvimento inicial               *
* ACTHIAGO  31.01.2013  #63782 - Radio Button para seleciona o idioma  *
*----------------------------------------------------------------------*
  DATA:
    t_rdl_idioma_rdf TYPE STANDARD TABLE OF spopli,
    w_rdl_idioma_rdf LIKE LINE OF t_rdl_idioma_rdf.

  DATA:
    v_fm_smartform   TYPE rs38l_fnam      ,
    v_formname       TYPE stxfadm-formname,
    v_resp_avaliacao TYPE c LENGTH 01     .

  CONSTANTS:
    c_rdf_portugues TYPE stxfadm-formname VALUE 'YQM_RDF'   ,
    c_rdf_ingles    TYPE stxfadm-formname VALUE 'YQM_RDF_EN'.

  FREE t_rdl_idioma_rdf.

  w_rdl_idioma_rdf-selflag   = space         .
  w_rdl_idioma_rdf-varoption = 'Português'   .
  APPEND w_rdl_idioma_rdf TO t_rdl_idioma_rdf.

  w_rdl_idioma_rdf-selflag   = space         .
  w_rdl_idioma_rdf-varoption = 'Inglês'      .
  APPEND w_rdl_idioma_rdf TO t_rdl_idioma_rdf.

* Monta um popup com Radio Buttons para o usuário escolher
* qual idioma de envio da RDF
  CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
    EXPORTING
      mark_flag = space
      mark_max  = 1
      start_col = 25
      start_row = 10
      textline1 = 'Selecione o idioma de envio do Relatório de Desvio de Fornecedor (RDF)'
      titel     = 'Idioma RDF'
    IMPORTING
      answer    = v_resp_avaliacao
    TABLES
      t_spopli  = t_rdl_idioma_rdf
    EXCEPTIONS
      OTHERS    = 4.

  CASE v_resp_avaliacao.
    WHEN '1'. "  Português
      v_formname = c_rdf_portugues.
    WHEN '2'. " Inglês
      v_formname = c_rdf_ingles.
    WHEN OTHERS.
      EXIT.
  ENDCASE.

* Obter o nome da função do Smartform 'YQM_RDF'
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname = v_formname
    IMPORTING
      fm_name  = v_fm_smartform
    EXCEPTIONS
      OTHERS   = 3.

  CHECK v_fm_smartform IS NOT INITIAL.

  CALL FUNCTION v_fm_smartform
    EXPORTING
      i_viqmel   = i_viqmel
    TABLES
      ti_iviqmfe = ti_iviqmfe " Não Conformidades / Defeito (Desvio)
      ti_iviqmur = ti_iviqmur " Causa do Defeito (Desvio)
      ti_iviqmma = ti_iviqmma " Plano de Ações / Ações Corretivas
      ti_iviqmsm = ti_iviqmsm " Ação Imediata / Definição de Suprimentos
    EXCEPTIONS
      OTHERS     = 5.

ENDFUNCTION.