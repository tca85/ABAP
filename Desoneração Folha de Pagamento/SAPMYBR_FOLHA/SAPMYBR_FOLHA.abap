*----------------------------------------------------------------------*
*                       ACHÉ LABORATÓRIOS                              *
*----------------------------------------------------------------------*
* Programa : SAPMYBR_FOLHA                                             *
* Transação: YBR_FOLHA                                                 *
* Tipo     : Module Pool (Online)                                      *
* Módulo   : FI-AR (contas a receber)                                  *
* Funcional: Uderson Luiz Fermino                                      *
* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          *
* Descrição: Plano Brasil Maior (PBM) - incentivos do governo federal  *
*            para o desenvolvimento da indústria e do comércio através *
*            da desoneração (isenção) de ICMS da folha de pagamento    *
*            utilizando-se de CFOPs e NCMs específicos, onde é possível*
*            obter até 20% de desconto sobre o total das remunerações  *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  26.09.2013  #57551 - Desenvolvimento inicial               *
* ACTHIAGO  03.12.2013  #57551 - Correção para evitar DUMP quando      *
*                                estiver selecionando da J_1BNFLIN     *
*                                com o range de NCM                    *
*----------------------------------------------------------------------*

INCLUDE: mybr_folha_top, " Variáveis globais
         mybr_folha_lcl, " Classes locais
         mybr_folha_pbo, " Process Before Output
         mybr_folha_pai, " Process After Input
         mybr_folha_f01. " Sub-rotinas (Forms)