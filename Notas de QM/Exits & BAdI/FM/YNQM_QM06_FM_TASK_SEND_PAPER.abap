FUNCTION ynqm_qm06_fm_task_send_paper.
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
*                       ACHÉ LABORATÓRIOS                              *
*----------------------------------------------------------------------*
* Transação: QM01                                                      *
* Função definida dentro do Customizing                                *
*----------------------------------------------------------------------*
* SPRO > Administração de Qualidade > Nota QM > Processamento Notas >  *
*        Funções de nota adicionais > Definir Barra de Atividades      *
* Função: 0050 - Relatório Desvio Fornecedor                           *
* Tipo de Nota: Z1 - RNC Fornecedor                                    *
*----------------------------------------------------------------------*
* Objetivo : Usuário poder selecionar mais de 1 parceiro na QM01 para  *
*            o envio do e-mail do RDF (Relatório de Desvio de Fornec.) *
*            Foi realizada uma cópia de algumas partes do standard     *
*            QM06_FM_TASK_SEND_PAPER para essa melhoria porque no      *
*            customizing só é aceita a função com a mesma assinatura   *
* Módulo   : QM                                                        *
* Projeto  : Notas de QM (Não-conformidade no recebimento físico)      *
* Funcional: Meire Vicente Casale                                      *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  24.10.2013  #63782 - Desenvolvimento inicial               *
* ACTHIAGO  21.01.2014  #63782 - Permitir selecionar smartform em outro*
*                                idioma (português/inglês)             *
*----------------------------------------------------------------------*
  PERFORM f_limpar_tabelas.

  DESCRIBE TABLE ti_ihpa LINES g_bescheid_manum.

* Verifica se possui somente um parceiro cadastrado
  IF g_bescheid_manum = 1.
    CLEAR v_marc.
  ELSE.
    v_marc = 'X'.
  ENDIF.

  viqmel   = i_viqmel .
  g_ihpa[] = ti_ihpa[].

* Enviar RDF: selecionar parceiros
  PERFORM f_sel_parceiros.

  LOOP AT g_partner_tab WHERE mark = v_marc.
    MOVE-CORRESPONDING g_partner_tab TO act_partner.

    PERFORM: f_buscar_detalhes_parceiro,
             f_retornar_email_parceiro .
  ENDLOOP.

  PERFORM f_verif_parc_sem_email.

* (SAPLYNQM)T_DESTINATARIO

ENDFUNCTION.
