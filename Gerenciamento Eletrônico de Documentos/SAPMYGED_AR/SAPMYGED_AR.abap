*----------------------------------------------------------------------*
*                       ACHÉ LABORATÓRIOS                              *
*----------------------------------------------------------------------*
* Programa : SAPMYGED_AR                                               *
* Transação: YGED_AR                                                   *
* Tipo     : Module Pool (Online)                                      *
* Módulo   : FI/AR (contas a pagar)                                    *
* Funcional: Uderson Luiz Fermino                                      *
* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          *
* Descrição: Gerenciamento Eletrônico de Documentos - sistema para     *
*            coletar, vincular e gerenciar tipos de documentos         *
*            específicos no cadastro de clientes através do SAP DMS    *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  15.07.2013  #55263 - Desenvolvimento inicial               *
* ACTHIAGO  31.07.2013  #55263 - Inclusão do botão de bloqueio         *
*----------------------------------------------------------------------*

INCLUDE: myged_ar_top, " Variáveis globais
         myged_ar_lcl, " Classes locais
         myged_ar_o01, " Process Before Output
         myged_ar_i01, " Process After Input
         myged_ar_f01. " Rotinas