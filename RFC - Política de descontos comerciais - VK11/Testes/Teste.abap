REPORT z101 NO STANDARD PAGE HEADING.

CONSTANTS: lc_kschl_vkp0 TYPE kscha VALUE 'YDEC'.

DATA: lv_count       TYPE kopos,
      lv_unit        TYPE kpein,
      w_bapicondct  TYPE bapicondct,
      w_bapicondhd  TYPE bapicondhd,
      w_bapicondit  TYPE bapicondit,
      t_bapicondct  TYPE STANDARD TABLE OF bapicondct,
      t_bapicondhd  TYPE STANDARD TABLE OF bapicondhd,
      t_bapicondit  TYPE STANDARD TABLE OF bapicondit,
      t_bapicondqs  TYPE STANDARD TABLE OF bapicondqs,
      t_bapicondvs  TYPE STANDARD TABLE OF bapicondvs,
      t_bapiret2    TYPE STANDARD TABLE OF bapiret2,
      w_bapiret2    TYPE bapiret2,
      t_bapiknumhs  TYPE STANDARD TABLE OF bapiknumhs,
      t_mem_initial TYPE STANDARD TABLE OF cnd_mem_initial.

**ESCR_VENDAS = 5500,
**CLIENTE = 100923,
*GRUPO_MATERIAL = 10,
*MONTANTE = 75,00,
**DATA1 = 01.03.2015,
**DATA2 = 31.03.2015,
*COND_PAGTO = Y029,
*chaveId = chave.ChaveCondicaoEspecialGrupoMaterialId

*EscrVendas/Cliente/Grupo mat.

DATA w_a963 LIKE a963.
w_a963-kappl    = 'V'         . " Aplicação
w_a963-kschl    = 'YDEC'      . " Tipo de condição
w_a963-vkbur    = '5500'      . " Escritório de vendas
w_a963-kunnr    = '0000100923'. " Nº cliente
w_a963-kondm    = '10'        . " Grupo de condições material
w_a963-datab    = '20150301'  . " Início da validade do registro de condição
w_a963-datbi    = '20150331'  . " Fim da validade do registro de condição

w_bapicondct-operation  = '009'. " Original: primeira mensagem para operação
w_bapicondct-applicatio = 'V'.
w_bapicondct-cond_type  = 'YDEC'.
w_bapicondct-table_no   = '963'.
w_bapicondct-cond_usage = 'A'.
w_bapicondct-valid_to   = '20150301'.
w_bapicondct-valid_from = '20150331'.
w_bapicondct-cond_no    = '$000000001'.

CONCATENATE w_a963-vkbur " Escritório de vendas
            w_a963-kunnr " Nº cliente
            w_a963-kondm " Grupo de condições material
       INTO w_bapicondct-varkey.

w_bapicondhd-operation  = '009'.
w_bapicondhd-cond_no    = '$000000001'.
w_bapicondhd-created_by = sy-uname.
w_bapicondhd-creat_date = sy-datum.
w_bapicondhd-cond_usage = 'A'.
w_bapicondhd-table_no   = '963'.
w_bapicondhd-applicatio = 'V'.
w_bapicondhd-cond_type  = 'YDEC'.
w_bapicondhd-varkey     = w_bapicondct-varkey.
w_bapicondhd-valid_to   = '20150331'.
w_bapicondhd-valid_from = '20150301'.

CLEAR w_bapicondit.
w_bapicondit-operation  = '009'.
w_bapicondit-cond_no    = '$000000001'.
w_bapicondit-cond_count = lv_count.
w_bapicondit-applicatio = 'V'.
w_bapicondit-cond_type  = 'YDEC'.
w_bapicondit-scaletype  = 'A'.
w_bapicondit-scalebasin = 'B'.

w_bapicondit-scale_qty = w_bapicondit-scale_qty + 1.
w_bapicondit-calctypcon = 'B'.
lv_unit = '1'.
w_bapicondit-cond_p_unt = lv_unit.
w_bapicondit-cond_value = '1.14'. "wa_vbap-value.
w_bapicondit-condcurr   = 'BRL'.   "wa_vbap-waerk.

APPEND: w_bapicondct TO t_bapicondct,
        w_bapicondhd TO t_bapicondhd,
        w_bapicondit TO t_bapicondit.

*ENDLOOP.

*** BAPI for pricing Condition Records
CALL FUNCTION 'BAPI_PRICES_CONDITIONS'
  TABLES
    ti_bapicondct  = t_bapicondct
    ti_bapicondhd  = t_bapicondhd
    ti_bapicondit  = t_bapicondit
    ti_bapicondqs  = t_bapicondqs
    ti_bapicondvs  = t_bapicondvs
    to_bapiret2    = t_bapiret2
    to_bapiknumhs  = t_bapiknumhs
    to_mem_initial = t_mem_initial
  EXCEPTIONS
    update_error   = 1
    OTHERS         = 2.

IF sy-subrc EQ 0.

  LOOP AT t_bapiret2 INTO w_bapiret2.
    WRITE: /1 w_bapiret2-message.
  ENDLOOP.
  ULINE.

*  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*    EXPORTING
*      wait   = 'X'
*    IMPORTING
*      return = w_bapiret2.
ENDIF. 