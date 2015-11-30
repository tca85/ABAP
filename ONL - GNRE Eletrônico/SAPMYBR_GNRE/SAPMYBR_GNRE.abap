*----------------------------------------------------------------------*
*                       xxxxxxxxxxxxxxxxx                              *
*----------------------------------------------------------------------*
* Programa : SAPMYBR_GNRE                                              *
* Transação: YBR_GNRE                                                  *
* Tipo     : Module Pool (Online)                                      *
* Módulo   : FI/AR (contas a receber)                                  *
* Funcional: xxxxxxxxxxxxxxxxxxxx                                      *
* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          *
* Descrição: Gerar XML com dados das NF-e com ICMS ST para a GNRE - MS *
*            A Guia Nacional de Recolhimento de Tributos Estaduais -   *
*            GNRE, tem sido um documento de uso habitual por todos os  *
*            contribuintes que realizam operações de vendas            *
*            interestaduais sujeitas à substituição tributária.        *
*            http://www.gnre.pe.gov.br   (produção)                    *
*            http://www.gnre-h.pe.gov.br (homologação)                 *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  06.08.2013  #58899 - Desenvolvimento inicial               *
* ACTHIAGO  28.08.2013  #61276 - Inserção de mensagem quando salvar 2x *
* ACTHIAGO  25.09.2013  #63428 - Geração do XML em arquivos de 50 com  *
*                                base na data/hora da YBR_GNRE_PARAM   *
*----------------------------------------------------------------------*

INCLUDE: mybr_gnre_top, " Variáveis globais
         mybr_gnre_lcl, " Classes
         mybr_gnre_pbo, " Process Before Output
         mybr_gnre_pai, " Process After Input
         mybr_gnre_f01. " Sub-rotinas