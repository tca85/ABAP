* Tabela para mapeamento da transação VK15 (SHDB)
DATA: BEGIN OF t_bdc OCCURS 100.
        INCLUDE STRUCTURE bdcdata.
DATA: END OF t_bdc.

FUNCTION yypcl_sd_cria_condicao.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      T946 STRUCTURE  Y946 OPTIONAL
*"      T947 STRUCTURE  Y947 OPTIONAL
*"      T960 STRUCTURE  Y960 OPTIONAL
*"      T961 STRUCTURE  Y961 OPTIONAL
*"      T962 STRUCTURE  Y962 OPTIONAL
*"      T963 STRUCTURE  Y963 OPTIONAL
*"      T968 STRUCTURE  Y968 OPTIONAL
*"      T969 STRUCTURE  Y969 OPTIONAL
*"      T972 STRUCTURE  Y972 OPTIONAL
*"      MENSAGENS STRUCTURE  YMENSAGENS
*"----------------------------------------------------------------------
  DATA: BEGIN OF messtab OCCURS 10.
          INCLUDE STRUCTURE bdcmsgcoll.
  DATA END OF messtab.

*-----------------------------------------------------------------------
* VARIÁVEIS GLOBAIS
*-----------------------------------------------------------------------
  DATA: mode     TYPE c VALUE 'N',
        msg_var1 TYPE balm-msgv1,
        msg_var2 TYPE balm-msgv2,
        msg_var3 TYPE balm-msgv3,
        msg_var4 TYPE balm-msgv4.

*-----------------------------------------------------------------------
* CONSTANTES
*-----------------------------------------------------------------------
  CONSTANTS: c_vk15(4) TYPE c VALUE 'VK15'.

*-----------------------------------------------------------------------
* INÍCIO DO PROCESSAMENTO
*-----------------------------------------------------------------------
* Tabela 946
  LOOP AT t946.
* ============================= BATCH INPUT ============================= *
    REFRESH: t_bdc.
*
    PERFORM f_monta_bdc USING:
* Mapeamento SHDB
      'SAPMV13A'  '0100' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'RV13A-KOTABNR',
      space       space  space  'BDC_OKCODE'        '/00',
      space       space  space  'RV13A-KSCHL'       'YDEC',
      space       space  space  'RV13A-KOTABNR'     '946',
      'SAPMV13A'  '1946' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'KONP-ZTERM(01)'.
* Se tiver valor de limite inferior
    IF NOT t946-inferior IS INITIAL.
      PERFORM f_monta_bdc USING:
        space       space  space  'BDC_OKCODE'        '=PDAT'.
    ELSE.
      PERFORM f_monta_bdc USING:
        space       space  space  'BDC_OKCODE'        '=SICH'.
    ENDIF.
*
    PERFORM f_monta_bdc USING:
      space       space  space  'KOMG-VKBUR'        t946-escr_vendas,
      space       space  space  'KOMG-KUNNR'        t946-cliente,
      space       space  space  'KOMG-MATNR'        t946-material,
      space       space  space  'KOMG-CHARG'        t946-lote,
      space       space  space  'KOMG-BSARK_E(01)'  t946-tipo_ped,
      space       space  space  'KONP-KBETR(01)'    t946-montante,
      space       space  space  'RV13A-DATAB(01)'   t946-data1,
      space       space  space  'RV13A-DATBI(01)'   t946-data2,
      space       space  space  'KONP-ZTERM(01)'    t946-cond_pagto.
* Se tiver valor de limite inferior
    IF NOT t946-inferior IS INITIAL.
      PERFORM f_monta_bdc USING:
        'SAPMV13A'  '0300' 'X'    space               space,
        space       space  space  'BDC_CURSOR'        'KONP-MXWRT',
        space       space  space  'BDC_OKCODE'        '=SICH',
        space       space  space  'RV13A-DATAB'       t946-data1,
        space       space  space  'RV13A-DATBI'       t946-data2,
        space       space  space  'KONP-KBETR'        t946-montante,
        space       space  space  'KONP-MXWRT'        t946-inferior,
        space       space  space  'KONP-GKWRT'        t946-montante.
    ENDIF.
*
    CALL TRANSACTION c_vk15 USING t_bdc MODE mode MESSAGES INTO messtab.
*
  ENDLOOP.
* Trata mensagens de retorno
  LOOP AT messtab.
*
    CLEAR: msg_var1, msg_var2, msg_var3, msg_var4, mensagens.
*
    MOVE: messtab-msgv1 TO msg_var1,
          messtab-msgv2 TO msg_var2,
          messtab-msgv3 TO msg_var3,
          messtab-msgv4 TO msg_var4.

*
    CALL FUNCTION 'MESSAGE_PREPARE'
      EXPORTING
        language = 'P'
        msg_id   = messtab-msgid
        msg_no   = messtab-msgnr
        msg_var1 = msg_var1
        msg_var2 = msg_var2
        msg_var3 = msg_var3
        msg_var4 = msg_var4
      IMPORTING
        msg_text = mensagens-mensagem.
*
    MOVE messtab-msgtyp TO mensagens-tipo.
*
    APPEND mensagens.
*
  ENDLOOP.
* Limpa tabela de retorno de mensagens
  REFRESH: messtab.

* Tabela 947
  LOOP AT t947.
* ============================= BATCH INPUT ============================= *
    REFRESH: t_bdc.
*
    PERFORM f_monta_bdc USING:
* Mapeamento SHDB
      'SAPMV13A'  '0100' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'RV13A-KOTABNR',
      space       space  space  'BDC_OKCODE'        '/00',
      space       space  space  'RV13A-KSCHL'       'YDEC',
      space       space  space  'RV13A-KOTABNR'     '947',
      'SAPMV13A'  '1947' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'KONP-ZTERM(01)'.
* Se tiver valor de limite inferior
    IF NOT t947-inferior IS INITIAL.
      PERFORM f_monta_bdc USING:
        space       space  space  'BDC_OKCODE'        '=PDAT'.
    ELSE.
      PERFORM f_monta_bdc USING:
        space       space  space  'BDC_OKCODE'        '=SICH'.
    ENDIF.
*
    PERFORM f_monta_bdc USING:
      space       space  space  'KOMG-VKBUR'        t947-escr_vendas,
      space       space  space  'KOMG-KUNNR'        t947-cliente,
      space       space  space  'KOMG-MATNR'        t947-material,
      space       space  space  'KOMG-BSARK_E(01)'  t947-tipo_ped,
      space       space  space  'KONP-KBETR(01)'    t947-montante,
      space       space  space  'RV13A-DATAB(01)'   t947-data1,
      space       space  space  'RV13A-DATBI(01)'   t947-data2,
      space       space  space  'KONP-ZTERM(01)'    t947-cond_pagto.
* Se tiver valor de limite inferior
    IF NOT t947-inferior IS INITIAL.
      PERFORM f_monta_bdc USING:
        'SAPMV13A'  '0300' 'X'    space               space,
        space       space  space  'BDC_CURSOR'        'KONP-MXWRT',
        space       space  space  'BDC_OKCODE'        '=SICH',
        space       space  space  'RV13A-DATAB'       t947-data1,
        space       space  space  'RV13A-DATBI'       t947-data2,
        space       space  space  'KONP-KBETR'        t947-montante,
        space       space  space  'KONP-MXWRT'        t947-inferior,
        space       space  space  'KONP-GKWRT'        t947-montante.
    ENDIF.
*
    CALL TRANSACTION c_vk15 USING t_bdc MODE mode MESSAGES INTO messtab.
*
  ENDLOOP.
* Trata mensagens de retorno
  LOOP AT messtab.
*
    CLEAR: msg_var1, msg_var2, msg_var3, msg_var4, mensagens.
*
    MOVE: messtab-msgv1 TO msg_var1,
          messtab-msgv2 TO msg_var2,
          messtab-msgv3 TO msg_var3,
          messtab-msgv4 TO msg_var4.

*
    CALL FUNCTION 'MESSAGE_PREPARE'
      EXPORTING
        language = 'P'
        msg_id   = messtab-msgid
        msg_no   = messtab-msgnr
        msg_var1 = msg_var1
        msg_var2 = msg_var2
        msg_var3 = msg_var3
        msg_var4 = msg_var4
      IMPORTING
        msg_text = mensagens-mensagem.
*
    MOVE messtab-msgtyp TO mensagens-tipo.
*
    APPEND mensagens.
*
  ENDLOOP.
* Limpa tabela de retorno de mensagens
  REFRESH: messtab.

* Tabela 960
  LOOP AT t960.
* ============================= BATCH INPUT ============================= *
    REFRESH: t_bdc.
*
    PERFORM f_monta_bdc USING:
* Mapeamento SHDB
      'SAPMV13A'  '0100' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'RV13A-KOTABNR',
      space       space  space  'BDC_OKCODE'        '/00',
      space       space  space  'RV13A-KSCHL'       'YDEC',
      space       space  space  'RV13A-KOTABNR'     '960',
      'SAPMV13A'  '1960' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'KONP-ZTERM(01)',
      space       space  space  'BDC_OKCODE'        '=SICH',
      space       space  space  'KOMG-VKBUR'        t960-escr_vendas,
      space       space  space  'KOMG-KUNNR'        t960-cliente,
      space       space  space  'KOMG-MATNR(01)'    t960-material,
      space       space  space  'KONP-KBETR(01)'    t960-montante,
      space       space  space  'RV13A-DATAB(01)'   t960-data1,
      space       space  space  'RV13A-DATBI(01)'   t960-data2,
      space       space  space  'KONP-ZTERM(01)'    t960-cond_pagto.
*
    CALL TRANSACTION c_vk15 USING t_bdc MODE mode MESSAGES INTO messtab.
*
  ENDLOOP.
* Trata mensagens de retorno
  LOOP AT messtab.
*
    CLEAR: msg_var1, msg_var2, msg_var3, msg_var4, mensagens.
*
    MOVE: messtab-msgv1 TO msg_var1,
          messtab-msgv2 TO msg_var2,
          messtab-msgv3 TO msg_var3,
          messtab-msgv4 TO msg_var4.

*
    CALL FUNCTION 'MESSAGE_PREPARE'
      EXPORTING
        language = 'P'
        msg_id   = messtab-msgid
        msg_no   = messtab-msgnr
        msg_var1 = msg_var1
        msg_var2 = msg_var2
        msg_var3 = msg_var3
        msg_var4 = msg_var4
      IMPORTING
        msg_text = mensagens-mensagem.
*
    MOVE messtab-msgtyp TO mensagens-tipo.
*
    APPEND mensagens.
*
  ENDLOOP.
* Limpa tabela de retorno de mensagens
  REFRESH: messtab.
*
* Tabela 961
  LOOP AT t961.
* ============================= BATCH INPUT ============================= *
    REFRESH: t_bdc.
*
    PERFORM f_monta_bdc USING:
* Mapeamento SHDB
      'SAPMV13A'  '0100' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'RV13A-KOTABNR',
      space       space  space  'BDC_OKCODE'        '/00',
      space       space  space  'RV13A-KSCHL'       'YDEC',
      space       space  space  'RV13A-KOTABNR'     '961',
      'SAPMV13A'  '1961' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'KONP-ZTERM(01)',
      space       space  space  'BDC_OKCODE'        '=SICH',
      space       space  space  'KOMG-VKBUR'        t961-escr_vendas,
      space       space  space  'KOMG-KDGRP'        t961-grupo_cli,
      space       space  space  'KOMG-KONDM(01)'    t961-grupo_mat,
      space       space  space  'KONP-KBETR(01)'    t961-montante,
      space       space  space  'RV13A-DATAB(01)'   t961-data1,
      space       space  space  'RV13A-DATBI(01)'   t961-data2,
      space       space  space  'KONP-ZTERM(01)'    t961-cond_pagto.
*
    CALL TRANSACTION c_vk15 USING t_bdc MODE mode MESSAGES INTO messtab.
*
  ENDLOOP.
* Trata mensagens de retorno
  LOOP AT messtab.
*
    CLEAR: msg_var1, msg_var2, msg_var3, msg_var4, mensagens.
*
    MOVE: messtab-msgv1 TO msg_var1,
          messtab-msgv2 TO msg_var2,
          messtab-msgv3 TO msg_var3,
          messtab-msgv4 TO msg_var4.

*
    CALL FUNCTION 'MESSAGE_PREPARE'
      EXPORTING
        language = 'P'
        msg_id   = messtab-msgid
        msg_no   = messtab-msgnr
        msg_var1 = msg_var1
        msg_var2 = msg_var2
        msg_var3 = msg_var3
        msg_var4 = msg_var4
      IMPORTING
        msg_text = mensagens-mensagem.
*
    MOVE messtab-msgtyp TO mensagens-tipo.
*
    APPEND mensagens.
*
  ENDLOOP.
* Limpa tabela de retorno de mensagens
  REFRESH: messtab.

* Tabela 962
  LOOP AT t962.
* ============================= BATCH INPUT ============================= *
    REFRESH: t_bdc.
*
    PERFORM f_monta_bdc USING:
* Mapeamento SHDB
      'SAPMV13A'  '0100' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'RV13A-KOTABNR',
      space       space  space  'BDC_OKCODE'        '/00',
      space       space  space  'RV13A-KSCHL'       'YDEC',
      space       space  space  'RV13A-KOTABNR'     '962',
      'SAPMV13A'  '1962' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'KONP-ZTERM(01)',
      space       space  space  'BDC_OKCODE'        '=SICH',
      space       space  space  'KOMG-VKBUR'        t962-escr_vendas,
      space       space  space  'KOMG-MATNR(01)'    t962-material,
      space       space  space  'KONP-KBETR(01)'    t962-montante,
      space       space  space  'RV13A-DATAB(01)'   t962-data1,
      space       space  space  'RV13A-DATBI(01)'   t962-data2,
      space       space  space  'KONP-ZTERM(01)'    t962-cond_pagto.
*
    CALL TRANSACTION c_vk15 USING t_bdc MODE mode MESSAGES INTO messtab.
*
  ENDLOOP.
* Trata mensagens de retorno
  LOOP AT messtab.
*
    CLEAR: msg_var1, msg_var2, msg_var3, msg_var4, mensagens.
*
    MOVE: messtab-msgv1 TO msg_var1,
          messtab-msgv2 TO msg_var2,
          messtab-msgv3 TO msg_var3,
          messtab-msgv4 TO msg_var4.

*
    CALL FUNCTION 'MESSAGE_PREPARE'
      EXPORTING
        language = 'P'
        msg_id   = messtab-msgid
        msg_no   = messtab-msgnr
        msg_var1 = msg_var1
        msg_var2 = msg_var2
        msg_var3 = msg_var3
        msg_var4 = msg_var4
      IMPORTING
        msg_text = mensagens-mensagem.
*
    MOVE messtab-msgtyp TO mensagens-tipo.
*
    APPEND mensagens.
*
  ENDLOOP.
* Limpa tabela de retorno de mensagens
  REFRESH: messtab.

* Tabela 963
  LOOP AT t963.
* ============================= BATCH INPUT ============================= *
    REFRESH: t_bdc.
*
    PERFORM f_monta_bdc USING:
* Mapeamento SHDB
      'SAPMV13A'  '0100' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'RV13A-KOTABNR',
      space       space  space  'BDC_OKCODE'        '/00',
      space       space  space  'RV13A-KSCHL'       'YDEC',
      space       space  space  'RV13A-KOTABNR'     '963',
      'SAPMV13A'  '1963' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'KONP-ZTERM(01)',
      space       space  space  'BDC_OKCODE'        '=SICH',
      space       space  space  'KOMG-VKBUR'        t963-escr_vendas,
      space       space  space  'KOMG-KUNNR'        t963-cliente,
      space       space  space  'KOMG-KONDM(01)'    t963-grupo_mat,
      space       space  space  'KONP-KBETR(01)'    t963-montante,
      space       space  space  'RV13A-DATAB(01)'   t963-data1,
      space       space  space  'RV13A-DATBI(01)'   t963-data2,
      space       space  space  'KONP-ZTERM(01)'    t963-cond_pagto.
*
    CALL TRANSACTION c_vk15 USING t_bdc MODE mode MESSAGES INTO messtab.
*
  ENDLOOP.
* Trata mensagens de retorno
  LOOP AT messtab.
*
    CLEAR: msg_var1, msg_var2, msg_var3, msg_var4, mensagens.
*
    MOVE: messtab-msgv1 TO msg_var1,
          messtab-msgv2 TO msg_var2,
          messtab-msgv3 TO msg_var3,
          messtab-msgv4 TO msg_var4.

*
    CALL FUNCTION 'MESSAGE_PREPARE'
      EXPORTING
        language = 'P'
        msg_id   = messtab-msgid
        msg_no   = messtab-msgnr
        msg_var1 = msg_var1
        msg_var2 = msg_var2
        msg_var3 = msg_var3
        msg_var4 = msg_var4
      IMPORTING
        msg_text = mensagens-mensagem.
*
    MOVE messtab-msgtyp TO mensagens-tipo.
*
    APPEND mensagens.
*
  ENDLOOP.
* Limpa tabela de retorno de mensagens
  REFRESH: messtab.

* Tabela 968
  LOOP AT t968.
* ============================= BATCH INPUT ============================= *
    REFRESH: t_bdc.
*
    PERFORM f_monta_bdc USING:
* Mapeamento SHDB
      'SAPMV13A'  '0100' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'RV13A-KOTABNR',
      space       space  space  'BDC_OKCODE'        '/00',
      space       space  space  'RV13A-KSCHL'       'YDEC',
      space       space  space  'RV13A-KOTABNR'     '968',
      'SAPMV13A'  '1968' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'KONP-ZTERM(01)',
      space       space  space  'BDC_OKCODE'        '=SICH',
      space       space  space  'KOMG-VKBUR'        t968-escr_vendas,
      space       space  space  'KOMG-KDGRP'        t968-grupo_cli,
      space       space  space  'KOMG-KONDM'        t968-grupo_mat,
      space       space  space  'KOMG-MATNR(01)'    t968-material,
      space       space  space  'KONP-KBETR(01)'    t968-montante,
      space       space  space  'RV13A-DATAB(01)'   t968-data1,
      space       space  space  'RV13A-DATBI(01)'   t968-data2,
      space       space  space  'KONP-ZTERM(01)'    t968-cond_pagto.
*
    CALL TRANSACTION c_vk15 USING t_bdc MODE mode MESSAGES INTO messtab.
*
  ENDLOOP.
* Trata mensagens de retorno
  LOOP AT messtab.
*
    CLEAR: msg_var1, msg_var2, msg_var3, msg_var4, mensagens.
*
    MOVE: messtab-msgv1 TO msg_var1,
          messtab-msgv2 TO msg_var2,
          messtab-msgv3 TO msg_var3,
          messtab-msgv4 TO msg_var4.

*
    CALL FUNCTION 'MESSAGE_PREPARE'
      EXPORTING
        language = 'P'
        msg_id   = messtab-msgid
        msg_no   = messtab-msgnr
        msg_var1 = msg_var1
        msg_var2 = msg_var2
        msg_var3 = msg_var3
        msg_var4 = msg_var4
      IMPORTING
        msg_text = mensagens-mensagem.
*
    MOVE messtab-msgtyp TO mensagens-tipo.
*
    APPEND mensagens.
*
  ENDLOOP.
* Limpa tabela de retorno de mensagens
  REFRESH: messtab.

* Tabela 969
  LOOP AT t969.
* ============================= BATCH INPUT ============================= *
    REFRESH: t_bdc.
*
    PERFORM f_monta_bdc USING:
* Mapeamento SHDB
      'SAPMV13A'  '0100' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'RV13A-KOTABNR',
      space       space  space  'BDC_OKCODE'        '/00',
      space       space  space  'RV13A-KSCHL'       'YDEC',
      space       space  space  'RV13A-KOTABNR'     '969',
      'SAPMV13A'  '1969' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'KONP-ZTERM(01)',
      space       space  space  'BDC_OKCODE'        '=SICH',
      space       space  space  'KOMG-VKBUR'        t969-escr_vendas,
      space       space  space  'KOMG-REGIO'        t969-regiao,
      space       space  space  'KOMG-KONDM(01)'    t969-grupo_mat,
      space       space  space  'KONP-KBETR(01)'    t969-montante,
      space       space  space  'RV13A-DATAB(01)'   t969-data1,
      space       space  space  'RV13A-DATBI(01)'   t969-data2,
      space       space  space  'KONP-ZTERM(01)'    t969-cond_pagto.
*
    CALL TRANSACTION c_vk15 USING t_bdc MODE mode MESSAGES INTO messtab.
*
  ENDLOOP.
* Trata mensagens de retorno
  LOOP AT messtab.
*
    CLEAR: msg_var1, msg_var2, msg_var3, msg_var4, mensagens.
*
    MOVE: messtab-msgv1 TO msg_var1,
          messtab-msgv2 TO msg_var2,
          messtab-msgv3 TO msg_var3,
          messtab-msgv4 TO msg_var4.

*
    CALL FUNCTION 'MESSAGE_PREPARE'
      EXPORTING
        language = 'P'
        msg_id   = messtab-msgid
        msg_no   = messtab-msgnr
        msg_var1 = msg_var1
        msg_var2 = msg_var2
        msg_var3 = msg_var3
        msg_var4 = msg_var4
      IMPORTING
        msg_text = mensagens-mensagem.
*
    MOVE messtab-msgtyp TO mensagens-tipo.
*
    APPEND mensagens.
*
  ENDLOOP.
* Limpa tabela de retorno de mensagens
  REFRESH: messtab.

* Tabela 972
  LOOP AT t972.
* ============================= BATCH INPUT ============================= *
    REFRESH: t_bdc.
*
    PERFORM f_monta_bdc USING:
* Mapeamento SHDB
      'SAPMV13A'  '0100' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'RV13A-KOTABNR',
      space       space  space  'BDC_OKCODE'        '/00',
      space       space  space  'RV13A-KSCHL'       'YDEC',
      space       space  space  'RV13A-KOTABNR'     '972',
      'SAPMV13A'  '1972' 'X'    space               space,
      space       space  space  'BDC_CURSOR'        'KONP-ZTERM(01)',
      space       space  space  'BDC_OKCODE'        '=SICH',
      space       space  space  'KOMG-VKBUR'        t972-escr_vendas,
      space       space  space  'KOMG-REGIO'        t972-regiao,
      space       space  space  'KOMG-MATNR(01)'    t972-material,
      space       space  space  'KONP-KBETR(01)'    t972-montante,
      space       space  space  'RV13A-DATAB(01)'   t972-data1,
      space       space  space  'RV13A-DATBI(01)'   t972-data2,
      space       space  space  'KONP-ZTERM(01)'    t972-cond_pagto.
*
    CALL TRANSACTION c_vk15 USING t_bdc MODE mode MESSAGES INTO messtab.
*
  ENDLOOP.
* Trata mensagens de retorno
  LOOP AT messtab.
*
    CLEAR: msg_var1, msg_var2, msg_var3, msg_var4, mensagens.
*
    MOVE: messtab-msgv1 TO msg_var1,
          messtab-msgv2 TO msg_var2,
          messtab-msgv3 TO msg_var3,
          messtab-msgv4 TO msg_var4.

*
    CALL FUNCTION 'MESSAGE_PREPARE'
      EXPORTING
        language = 'P'
        msg_id   = messtab-msgid
        msg_no   = messtab-msgnr
        msg_var1 = msg_var1
        msg_var2 = msg_var2
        msg_var3 = msg_var3
        msg_var4 = msg_var4
      IMPORTING
        msg_text = mensagens-mensagem.
*
    MOVE messtab-msgtyp TO mensagens-tipo.
*
    APPEND mensagens.
*
  ENDLOOP.
* Limpa tabela de retorno de mensagens
  REFRESH: messtab.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*&      Form  F_MONTA_BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SPACE  text
*      -->P_SPACE  text
*      -->P_SPACE  text
*      -->P_SPACE  text
*      -->P_SPACE  text
*----------------------------------------------------------------------*
FORM f_monta_bdc USING p_program
                       p_dynpro
                       p_dynbegin
                       p_fnam
                       p_fval.

  MOVE p_program  TO t_bdc-program.
  MOVE p_dynpro   TO t_bdc-dynpro.
  MOVE p_dynbegin TO t_bdc-dynbegin.
  MOVE p_fnam     TO t_bdc-fnam.
  MOVE p_fval     TO t_bdc-fval.

  APPEND t_bdc.

ENDFORM.                    " F_MONTA_BDC