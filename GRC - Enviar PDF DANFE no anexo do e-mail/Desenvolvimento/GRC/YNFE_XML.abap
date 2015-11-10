REPORT ynfe_xml NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
*                 Aché Laboratórios Farmacêuticos SA                   *
*----------------------------------------------------------------------*
* Programa...: YNFE_XML                                                *
* Transação..: YNFE_XML                                                *
* Descrição..: Reenvio de e-mail das NF-e autorizadas (XML + DANFE)    *
* Tipo.......: ALV                                                     *
* Módulo.....: GRC                                                     *
* ABAP.......: Thiago Cordeiro Alves                                   *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  09.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
DATA:
  t_alv TYPE STANDARD TABLE OF ycl_ecc=>ty_alv.

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
DATA
  w_nfe TYPE ycl_ecc=>ty_nfe.

*----------------------------------------------------------------------*
* Variáveis tipo referência
*----------------------------------------------------------------------*
DATA:
  o_ecc                 TYPE REF TO ycl_ecc               ,
  o_cx_ecc              TYPE REF TO ycx_ecc               ,
  o_salv_table          TYPE REF TO cl_salv_table         ,
  o_salv_functions_list TYPE REF TO cl_salv_functions_list,
  o_salv_columns        TYPE REF TO cl_salv_columns       ,
  o_salv_msg            TYPE REF TO cx_salv_msg           .

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
DATA:
  v_msg_erro            TYPE string  ,
  v_qtd_emails_enviados TYPE sy-tabix.

*----------------------------------------------------------------------*
* Tela de seleção
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE t000.
SELECT-OPTIONS: s_nfe FOR w_nfe-id                      . " Chave de acesso
SELECTION-SCREEN END OF BLOCK b0                        .

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t001.
SELECT-OPTIONS: s_nr_nfe FOR w_nfe-nnf                  , " NF-e
                s_docnum FOR w_nfe-docnum               , " Nº do documento
                s_cnpj   FOR w_nfe-cnpj_dest            , " CNPJ Destinatário
                s_cpf    FOR w_nfe-cpf_dest             , " CPF Destinatário
                s_dhemi  FOR sy-datum                   . " Data de emissão
SELECTION-SCREEN END OF BLOCK b1                        .

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE t003.
PARAMETERS: p_chk_01 AS CHECKBOX DEFAULT ''             , " Recebedor da NF-e
            p_chk_02 AS CHECKBOX DEFAULT ''             . " Transportador da NF-e
SELECTION-SCREEN END OF BLOCK b3                        .

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE t004.
PARAMETERS: p_e_mail TYPE adr6-smtp_addr                . " Email adicional
SELECTION-SCREEN END OF BLOCK b2                        .

*----------------------------------------------------------------------*
* Initialization
*----------------------------------------------------------------------*
INITIALIZATION.
  t000 = 'Chave de acesso'            .
  t001 = 'Critério de seleção da NF-e'.
  t003 = 'Destinatário do e-mail'     .
  t004 = 'E-mail adicional'           .

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
START-OF-SELECTION.

  TRY.
      CREATE OBJECT o_ecc TYPE ycl_ecc.

      o_ecc->get_xml_nfe( im_id_nfe    = s_nfe[]
                          im_nro_nfe   = s_nr_nfe[]
                          im_docnum    = s_docnum[]
                          im_emissao   = s_dhemi[]
                          im_cnpj_dest = s_cnpj[]
                          im_cpf_dest  = s_cpf[] ).

      v_qtd_emails_enviados = o_ecc->enviar_email_nfe_danfe( im_email_adicional = p_e_mail
                                                             im_recebedor       = p_chk_01
                                                             im_transportadora  = p_chk_02 ).

    CATCH ycx_ecc INTO o_cx_ecc.
      v_msg_erro = o_cx_ecc->msg.
      MESSAGE v_msg_erro TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
  ENDTRY.

  t_alv = o_ecc->get_alv_nfe( ).

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = o_salv_table
                              CHANGING t_table       = t_alv ).

    CATCH cx_salv_msg INTO o_salv_msg.
      v_msg_erro = o_salv_msg->get_text( ).
      MESSAGE v_msg_erro TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
  ENDTRY.

  o_salv_functions_list = o_salv_table->get_functions( ).
  o_salv_functions_list->set_all( abap_true ).

  o_salv_columns = o_salv_table->get_columns( ).
  o_salv_columns->set_optimize( abap_true ).

  o_salv_table->display( ).