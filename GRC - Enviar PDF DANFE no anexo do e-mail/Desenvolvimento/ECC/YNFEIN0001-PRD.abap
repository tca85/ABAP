FUNCTION ynfein0001.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(DOCNUM) TYPE  J_1BDOCNUM
*"     VALUE(BUYER) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(CARRIER) TYPE  CHAR1 DEFAULT SPACE
*"  EXPORTING
*"     VALUE(E_MAIL) TYPE  AD_SMTPADR
*"----------------------------------------------------------------------
************************************************************************
*   INÍCIO LÓGICO                                                      *
************************************************************************
* Endereços
  RANGES: rg_adrnr FOR  lfa1-adrnr.
  DATA:   l_adrnr  TYPE lfa1-adrnr.
* Transportador
  DATA:   l_parid_transp TYPE j_1bnfnad-parid.


* Cabeçalho da nota fiscal
  TYPES: BEGIN OF ty_j_1bnfdoc,
           docnum     TYPE j_1bnfdoc-docnum,
           bukrs      TYPE j_1bnfdoc-bukrs,
           partyp     TYPE j_1bnfdoc-partyp,
           parid      TYPE j_1bnfdoc-parid,
         END OF ty_j_1bnfdoc,
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

  DATA: t_j_1bnfdoc   TYPE TABLE OF ty_j_1bnfdoc,
        t_adr6        TYPE TABLE OF ty_adr6,
        t_adrt        TYPE TABLE OF ty_adrt.

  DATA:: wa_j_1bnfdoc TYPE ty_j_1bnfdoc,
         wa_adr6      TYPE ty_adr6,
         wa_adrt      TYPE ty_adrt.

  CLEAR: t_j_1bnfdoc[], t_adr6[], t_adrt[].
  IF NOT docnum IS INITIAL. "AND syst-sysid+1(1) EQ 'P'.

    rg_adrnr-sign   = 'I'.
    rg_adrnr-option = 'EQ'.

*   Seleciona Cabeçalho de NF
    SELECT docnum bukrs partyp parid
      FROM j_1bnfdoc
      INTO TABLE t_j_1bnfdoc
     WHERE docnum = docnum.

*   Caso encontre o Documento
    IF sy-subrc IS INITIAL.

      READ TABLE t_j_1bnfdoc INTO wa_j_1bnfdoc INDEX 1.

      IF sy-subrc EQ 0.
        IF buyer IS NOT INITIAL.
          CASE wa_j_1bnfdoc-partyp.
              CLEAR: rg_adrnr-low.
            WHEN 'V'.
*           Seleciona Fornecedor
              SELECT SINGLE adrnr
                FROM lfa1
                INTO l_adrnr
               WHERE lifnr = wa_j_1bnfdoc-parid.
              rg_adrnr-low = l_adrnr.
              APPEND rg_adrnr.

            WHEN 'C'.
*           Seleciona Cliente
              SELECT SINGLE adrnr
                FROM kna1
                INTO l_adrnr
               WHERE kunnr = wa_j_1bnfdoc-parid.
              rg_adrnr-low = l_adrnr.
              APPEND rg_adrnr.
          ENDCASE.
        ENDIF.

*       Selecionar Transportadora
        IF carrier IS NOT INITIAL.
          SELECT SINGLE parid
            INTO l_parid_transp
            FROM j_1bnfnad
           WHERE docnum EQ docnum
             AND parvw  IN ('SP', 'CA').

*       Seleciona Endereço da Transportadora
          IF NOT l_parid_transp IS INITIAL.
            CLEAR rg_adrnr-low.
            SELECT SINGLE adrnr
              INTO rg_adrnr-low
              FROM lfa1
             WHERE lifnr EQ l_parid_transp.
            IF NOT rg_adrnr-low IS INITIAL.
              APPEND rg_adrnr.
            ENDIF.
          ENDIF.
        ENDIF.

        IF NOT rg_adrnr[] IS INITIAL.
*         Endereços de e-mail (administração de endereços central)
          SELECT addrnumber consnumber smtp_addr
            FROM adr6
            INTO TABLE t_adr6
           WHERE addrnumber IN rg_adrnr.

*         Textos para dados de comunicação (admin.endereços central)
          IF NOT t_adr6[] IS INITIAL.
            SELECT addrnumber consnumber remark
              FROM adrt
              INTO TABLE t_adrt
               FOR ALL ENTRIES IN t_adr6
             WHERE addrnumber EQ t_adr6-addrnumber
               AND comm_type  EQ 'INT'.
          ENDIF.

**         Carregar o E-mail do Cliente/Fornecedor
*          READ TABLE t_adr6 INTO wa_adr6 WITH KEY addrnumber = l_adrnr.
*          IF sy-subrc EQ 0.
*            e_mail = wa_adr6-smtp_addr.
*          ENDIF.
**         Elimina registros de e-mail do Cliente/Fornecedor
*          DELETE t_adr6 WHERE addrnumber = l_adrnr.
*          DELETE t_adrt WHERE addrnumber = l_adrnr.

*         Carregar o E-mail Transportadora
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
      ENDIF.
    ENDIF.
  ENDIF.

ENDFUNCTION.