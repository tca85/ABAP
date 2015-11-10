*----------------------------------------------------------------------*
*               Aché Laboratórios Farmacêuticos S.A                    *
*----------------------------------------------------------------------*
* Classe   : YCL_GRC                                                   *
* Método   : GET_DESTINATARIO_EMAIL_NFE                                *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obtém os destinatários do e-mail da NF-e                  *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  08.10.2015  #109075 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_destinatario_email_nfe.

*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
  TYPES:
     BEGIN OF ty_j_1bnfdoc            ,
       docnum    TYPE j_1bnfdoc-docnum, " Nº documento
       bukrs     TYPE j_1bnfdoc-bukrs , " Empresa
       partyp    TYPE j_1bnfdoc-partyp, " Tipo de parceiro nota fiscal
       parid     TYPE j_1bnfdoc-parid , " Identificação do parceiro (cliente, fornecedor, loc.negócio)
     END OF ty_j_1bnfdoc              ,

     BEGIN OF ty_adr6                 ,
       addrnumber TYPE adr6-addrnumber, " Nº endereço
       consnumber TYPE adr6-consnumber, " Nº seqüencial
       smtp_addr  TYPE adr6-smtp_addr , " Endereço de e-mail
     END OF ty_adr6                   ,

     BEGIN OF ty_adrt                 ,
       addrnumber TYPE adrt-addrnumber, " Nº endereço
       consnumber TYPE adrt-consnumber, " Nº seqüencial
       remark     TYPE adrt-remark    , " Observações sobre a ligação de comunicação
     END OF ty_adrt                   .

*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA:
     t_adr6 TYPE STANDARD TABLE OF ty_adr6,
     t_adrt TYPE STANDARD TABLE OF ty_adrt.

  DATA:
     w_j_1bnfdoc    TYPE ty_j_1bnfdoc   ,
     w_destinatario TYPE ty_destinatario,
     w_adr6         TYPE ty_adr6        ,
     w_adrt         TYPE ty_adrt        .

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
     v_endereco       TYPE lfa1-adrnr     ,
     v_msg_erro       TYPE string         ,
     v_transportadora TYPE j_1bnfnad-parid.

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
  CONSTANTS:
     c_cliente          TYPE j_1bpartyp     VALUE 'C'  ,
     c_fornecedor       TYPE j_1bpartyp     VALUE 'V'  ,
     c_transportadora   TYPE j_1bad-parvw   VALUE 'SP' ,
     c_transporte_aereo TYPE j_1bad-parvw   VALUE 'CA' ,
     c_e_mail           TYPE tsac-comm_type VALUE 'INT'.

*----------------------------------------------------------------------*
* Ranges
*----------------------------------------------------------------------*
  TYPES:
     r_adrnr_range TYPE RANGE OF lfa1-adrnr   ,
     r_adrnr_linha TYPE LINE OF  r_adrnr_range.

  DATA:
     r_adrnr TYPE r_adrnr_range,
     w_adrnr TYPE r_adrnr_linha.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  IF im_nro_documento IS INITIAL.
    EXIT.
  ENDIF.

* Seleciona Cabeçalho de NF
  SELECT SINGLE docnum bukrs partyp parid
    FROM j_1bnfdoc
    INTO w_j_1bnfdoc
   WHERE docnum = im_nro_documento.

  IF w_j_1bnfdoc IS INITIAL.
    EXIT.
  ENDIF.

  IF im_comprador IS NOT INITIAL.

*   Tipo de parceiro nota fiscal
    CASE w_j_1bnfdoc-partyp.

      WHEN c_fornecedor.
        SELECT SINGLE adrnr " Endereço
          FROM lfa1
          INTO v_endereco
         WHERE lifnr = w_j_1bnfdoc-parid.

        IF v_endereco IS NOT INITIAL.
          w_adrnr-sign   = 'I'       .
          w_adrnr-option = 'EQ'      .
          w_adrnr-low    = v_endereco.
          APPEND w_adrnr TO r_adrnr  .
        ENDIF.

      WHEN c_cliente.
        SELECT SINGLE adrnr
          FROM kna1
          INTO v_endereco
         WHERE kunnr = w_j_1bnfdoc-parid.

        IF v_endereco IS NOT INITIAL.
          w_adrnr-sign   = 'I'       .
          w_adrnr-option = 'EQ'      .
          w_adrnr-low    = v_endereco.
          APPEND w_adrnr TO r_adrnr  .
        ENDIF.
    ENDCASE.

  ENDIF.

* Selecionar Transportadora
  IF im_transportadora IS NOT INITIAL.
    SELECT SINGLE parid                                     "#EC *
      INTO v_transportadora
      FROM j_1bnfnad
     WHERE docnum = im_nro_documento
       AND parvw IN (c_transportadora, c_transporte_aereo).

*   Seleciona Endereço da Transportadora
    IF v_transportadora IS NOT INITIAL.
      SELECT SINGLE adrnr
        INTO v_endereco
        FROM lfa1
       WHERE lifnr = v_transportadora.

      IF v_endereco IS NOT INITIAL.
        w_adrnr-sign   = 'I'       .
        w_adrnr-option = 'EQ'      .
        w_adrnr-low    = v_endereco.
        APPEND w_adrnr TO r_adrnr  .
      ENDIF.

    ENDIF.
  ENDIF.

  IF r_adrnr IS NOT INITIAL.
*   Endereços de e-mail (administração de endereços central)
    SELECT addrnumber consnumber smtp_addr
      FROM adr6
      INTO TABLE t_adr6
     WHERE addrnumber IN r_adrnr.
  ENDIF.

  IF t_adr6 IS NOT INITIAL.
    SELECT addrnumber consnumber remark
      FROM adrt
      INTO TABLE t_adrt
       FOR ALL ENTRIES IN t_adr6
     WHERE addrnumber = t_adr6-addrnumber
       AND comm_type  = c_e_mail.
  ENDIF.

  SORT t_adrt BY remark ASCENDING.
  DELETE t_adrt WHERE remark IS INITIAL.

* Carregar o E-mail Transportadora
  LOOP AT t_adrt INTO w_adrt.
    CALL FUNCTION 'AIPC_CONVERT_TO_UPPERCASE'
      EXPORTING
        i_input  = w_adrt-remark
      IMPORTING
        e_output = w_adrt-remark.

    IF w_adrt-remark(2) = 'NF'.

      READ TABLE t_adr6
      INTO w_adr6
      WITH KEY addrnumber = w_adrt-addrnumber
               consnumber = w_adrt-consnumber.

      IF sy-subrc EQ 0.
        w_destinatario-email = w_adr6-smtp_addr.
        APPEND w_destinatario TO rt_t_destinatario.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF rt_t_destinatario IS INITIAL.
*   Não foram encontrados destinatários de e-mail
    MESSAGE e001(ygrc) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_grc EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.