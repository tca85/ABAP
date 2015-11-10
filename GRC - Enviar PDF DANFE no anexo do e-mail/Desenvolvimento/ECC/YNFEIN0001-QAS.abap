FUNCTION YNFEIN0001.
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_STCD1) TYPE  STCD1 DEFAULT SPACE
*"     VALUE(I_STCD2) TYPE  STCD2 DEFAULT SPACE
*"  EXPORTING
*"     VALUE(E_MAIL) TYPE  STRING
*"--------------------------------------------------------------------
************************************************************************
*   INÍCIO LÓGICO                                                      *
************************************************************************
* Endereços
  RANGES: rg_adrnr FOR  lfa1-adrnr.
  DATA:   l_adrnr  TYPE lfa1-adrnr.
* Transportador
  DATA:   l_parid_transp TYPE j_1bnfnad-parid.


* Cabeçalho da nota fiscal
  TYPES:

*        Endereços de e-mail (administração de endereços central)
         BEGIN OF ty_adr6,
           addrnumber TYPE adr6-addrnumber,
           consnumber TYPE adr6-consnumber,
           smtp_addr  TYPE adr6-smtp_addr,
         END OF ty_adr6,

*        Textos para dados de comunicação (admin.endereços central)
         BEGIN OF ty_adrt,
           addrnumber TYPE adrt-addrnumber,
           consnumber TYPE adrt-consnumber,
           remark     TYPE adrt-remark,
         END OF ty_adrt.

  DATA: t_adr6        TYPE TABLE OF ty_adr6,
        t_adrt        TYPE TABLE OF ty_adrt.

  DATA: wa_adr6      TYPE ty_adr6,
        wa_adrt      TYPE ty_adrt.

  CLEAR:  t_adr6[], t_adrt[].

  rg_adrnr-sign   = 'I'.
  rg_adrnr-option = 'EQ'.

* Seleciona Cliente
  SELECT SINGLE adrnr
    FROM kna1
    INTO l_adrnr
     WHERE stcd1 = i_stcd1
        OR stcd2 = i_stcd2 .

  rg_adrnr-low = l_adrnr.
  APPEND rg_adrnr.

  IF sy-subrc <> 0.
*    Seleciona Fornecedor
     SELECT SINGLE adrnr
       FROM lfa1
       INTO l_adrnr
      WHERE stcd1 = i_stcd1
         OR stcd2 = i_stcd2 .

      rg_adrnr-low = l_adrnr.
      APPEND rg_adrnr.
  ENDIF.

  IF NOT rg_adrnr[] IS INITIAL.
*    Endereços de e-mail (administração de endereços central)
     SELECT addrnumber consnumber smtp_addr
       FROM adr6
       INTO TABLE t_adr6
      WHERE addrnumber IN rg_adrnr.

*   Textos para dados de comunicação (admin.endereços central)
    IF NOT t_adr6[] IS INITIAL.
       SELECT addrnumber consnumber remark
         FROM adrt
         INTO TABLE t_adrt
          FOR ALL ENTRIES IN t_adr6
        WHERE addrnumber EQ t_adr6-addrnumber
          AND comm_type  EQ 'INT'.
    ENDIF.

*   Carregar o E-mail Transportadora
    LOOP AT t_adrt INTO wa_adrt WHERE NOT remark IS INITIAL.
      CALL FUNCTION 'AIPC_CONVERT_TO_UPPERCASE'
        EXPORTING
          i_input  = wa_adrt-remark
        IMPORTING
          e_output = wa_adrt-remark.
      IF wa_adrt-remark(2) EQ 'NF'.
        READ TABLE t_adr6 INTO wa_adr6 WITH KEY addrnumber = wa_adrt-addrnumber
                                                consnumber = wa_adrt-consnumber.
        IF sy-subrc EQ 0.
          IF e_mail IS INITIAL.
            e_mail = wa_adr6-smtp_addr.
          ELSE.
            CONCATENATE e_mail wa_adr6-smtp_addr
                   INTO e_mail
              SEPARATED BY '; '.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.
