*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_INVENTARIO                                            *
* Método   : VALIDAR_EXCEL                                             *
*----------------------------------------------------------------------*
* Projeto  : Operador Logístico                                        *
* Módulo   : MM/WM                                                     *
* Funcional: Sergio Vieira de Alcântara / Danilo Morente Carrasco      *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Validar as entradas do excel para atualizar ou incluir    *
*            materiais no inventário (LI11N)                           *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  26.11.2014  #93085 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*<-- EX_T_EXCEL	     TYPE TP_EXCEL
*<-- EX_T_INVENTARIO TYPE TP_INVENTARIO
*<-- EX_T_LOG	       TYPE TP_LOG

METHOD validar_excel.
*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_qtd_registros TYPE i         ,
    v_deposito      TYPE lqua-lgort,
    v_msg_erro      TYPE t100-text .

*----------------------------------------------------------------------*
* Work-Areas
*----------------------------------------------------------------------*
  DATA:
    w_log        TYPE me->ty_log       ,
    w_excel      TYPE me->ty_excel     ,
    w_inventario TYPE me->ty_inventario,
    w_mch1       TYPE me->ty_mch1      ,
    w_ol_empresa TYPE me->ty_ol_empresa,
    w_linp       TYPE me->ty_linp      ,
    w_mara       TYPE me->ty_mara      ,
    w_lqua       TYPE me->ty_lqua      ,
    w_linv       TYPE me->ty_linv      ,
    w_linv_aux   TYPE linv             .

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
  CONSTANTS:
    c_material_promocional TYPE t134-mtart VALUE 'YPRO'.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  IF ex_t_excel IS INITIAL.
*   Planilha do excel não possui dados
    MESSAGE e011(yol) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_ol EXPORTING mensagem = v_msg_erro.
  ENDIF.

* Dados de inventário por quanto
  SELECT SINGLE lgnum ivnum ivpos lgtyp
                lgpla plpos matnr werks charg
   FROM linv
   INTO w_linv
    WHERE lgnum = me->deposito
      AND ivnum = me->doc_inventario.

  LOOP AT ex_t_excel INTO w_excel.
    CLEAR:
       w_inventario, w_log, w_mch1, w_ol_empresa, w_mara,
       w_linv_aux, w_linp, w_lqua, v_deposito.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = w_excel-matnr
      IMPORTING
        output       = w_excel-matnr
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2.

*   Dados de inventário por quanto
    SELECT SINGLE * FROM linv
     INTO w_linv_aux
     WHERE lgnum = me->deposito
       AND ivnum = me->doc_inventario
       AND matnr = w_excel-matnr
       AND charg = w_excel-charg.

    IF sy-subrc = 0.
      MOVE-CORRESPONDING w_linv_aux TO w_inventario.
      w_inventario-uname = sy-uname         . " Usuário que alterou o material
      w_inventario-menga = w_excel-menge    . " Qtd. para entrada do resultado da contagem
      APPEND w_inventario TO ex_t_inventario.

*----------------------------------------------------------------------*
*   Material que não existia no inventário
*----------------------------------------------------------------------*
    ELSE.

*     Lotes (para administr.de lotes a nível de todos os centros)
      SELECT SINGLE matnr charg hsdat vfdat
       FROM mch1
       INTO w_mch1
       WHERE matnr = w_excel-matnr
         AND charg = w_excel-charg.

      IF sy-subrc <> 0.
        w_log-lgnum = me->deposito                     . " Nºdepósito/complexo de depósito
        w_log-ivnum = me->doc_inventario               . " Nº documento de inventário
        w_log-matnr = w_excel-matnr                    . " Material
        w_log-charg = w_excel-charg                    . " Lote
        w_log-menge = w_excel-menge                    . " Quantidade
        w_log-stat  = me->c_erro                       . " Status
        w_log-text  = 'Material e lote não encontrados'.    "#EC NOTEXT
        APPEND w_log TO ex_t_log                       .
      ELSE.

*       Parametrização de empresas (Operador Logístico)
        SELECT SINGLE werks lgort_da lgort_dp
         FROM ymm_ol_empresa
         INTO w_ol_empresa
         WHERE werks = w_linv-werks.

*       Dados gerais de material
        SELECT SINGLE matnr mtart
         FROM mara
         INTO w_mara
         WHERE matnr = w_excel-matnr.

        IF w_mara-mtart = c_material_promocional. " YPRO
          v_deposito = w_ol_empresa-lgort_dp. " Depósito Promocional
        ELSE.
          v_deposito = w_ol_empresa-lgort_da. " Depósito Acabado
        ENDIF.

*       Item de doc.inventário em WM
        SELECT SINGLE lgnum ivnum lgpla idatu
         FROM linp
         INTO w_linp
         WHERE lgnum = me->deposito
           AND ivnum = me->doc_inventario.

*       Quantos
        SELECT SINGLE lgnum lqnum matnr werks
                      charg lgtyp lgpla bestq
         FROM lqua
         INTO w_lqua
         WHERE lgnum = me->deposito
*           AND ivnum = me->doc_inventario
           AND matnr = w_mara-matnr
           AND werks = w_linv-werks
           AND charg = w_excel-charg
           AND lgort = v_deposito.

        IF sy-subrc EQ 0. "Se encontrar na LQUA, pegar o status que vem do campo BESTQ
          w_inventario-bestq = w_lqua-bestq     . " Tipo de estoque
        ELSE. "Senão colocar 'S' - Bloqueado
          w_inventario-bestq = 'S'     . " Lote
        ENDIF.

        w_inventario-lgnum = w_linv-lgnum     . " Depósito
        w_inventario-ivnum = w_linv-ivnum     . " Documento de inventário
        w_inventario-ivpos = w_linv-ivpos     . " Nº item no documento de inventário
        w_inventario-lgtyp = w_linv-lgtyp     . " Tipo de depósito
        w_inventario-lgpla = w_linp-lgpla     . " Posição no depósito
        w_inventario-plpos = w_linv-plpos     . " Item na posição do depósito
        w_inventario-matnr = w_mch1-matnr     . " Material
        w_inventario-werks = w_linv-werks     . " Centro
        w_inventario-wdatu = w_mch1-hsdat     . " Data da entrada de mercadorias
        w_inventario-charg = w_mch1-charg     . " Lote
        w_inventario-menga = w_excel-menge    . " Qtd. para entrada do resultado da contagem
        w_inventario-idatu = w_linp-idatu     . " Data do inventário
        w_inventario-vfdat = w_mch1-vfdat     . " Data de vencimento (IDOC)
        w_inventario-lgort = v_deposito       . " Deposito
        w_inventario-uname = sy-uname         . " Usuário que incluiu o novo material
        APPEND w_inventario TO ex_t_inventario.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF ex_t_inventario IS INITIAL.
*   Dados não encontrados para incluir/alterar o inventário
    MESSAGE e012(yol) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_ol EXPORTING mensagem = v_msg_erro.
  ENDIF.

ENDMETHOD.