*----------------------------------------------------------------------*
*                       ACHÉ LABORATÓRIOS                              *
*----------------------------------------------------------------------*
* Programa : SAPMY_NQM                                                 *
* Transação: YNQM_GNC                                                  *
* Tipo     : Module Pool (Online)                                      *
* Módulo   : QM                                                        *
* Funcional: Meire Vicente Casale                                      *
* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          *
* Descrição: Gerenciamento de notas de não conformidade (Notas de QM)  *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  12.12.2013  #63782 - Desenvolvimento inicial               *
* ACTHIAGO  06.01.2014  #63782 - Inclusão do Fornecedor na visualização*
*                                da Ação Imediata                      *
* ACTHIAGO  21.01.2014  #63782 - Botão criar nota de QM c/ base no lote*
* ACTHIAGO  23.01.2014  #63782 - Inclusão do material, centro e lote   *
*                                na tela seleção / relatório           *
* ACTHIAGO  30.01.2014  #63782 - Verificar lotes de sub-contratação    *
* ACTHIAGO  18.02.2014  #63782 - Verificar ordem de produção somente   *
*                                com movimento de entrada de mercadoria*
*----------------------------------------------------------------------*

INCLUDE: my_nqm_top, " Variáveis globais
         my_nqm_pbo, " Process Before Output
         my_nqm_pai, " Process After Input
         my_nqm_lcl, " Classes Locais
         my_nqm_f01. " Sub-rotinas (Forms)