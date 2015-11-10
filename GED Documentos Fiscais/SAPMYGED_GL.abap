*----------------------------------------------------------------------*
*                       ACHÉ LABORATÓRIOS                              *
*----------------------------------------------------------------------*
* Programa : SAPMYGED_GL                                               *
* Transação: YGED_GL                                                   *
* Tipo     : Module Pool (Online)                                      *
* Módulo   : FI                                                        *
* Funcional: Uderson Luiz Fermino                                      *
* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          *
* Descrição: Gerenciamento eletrônico de documentos fiscais            *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  15.01.2014  #64292 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

INCLUDE: myged_gl_top, " Variáveis globais
         myged_gl_lcl, " Classes locais
         myged_gl_pbo, " Process Before Output
         myged_gl_pai, " Process After Input
         myged_gl_f01. " Rotinas