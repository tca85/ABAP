FUNCTION ybr_gnre_parceiros_nfe.
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(PARTYP) TYPE  J_1BNFNAD-PARTYP
*"  EXPORTING
*"     REFERENCE(NOME) TYPE  J1B_NF_XML_BADI_HEADER-XLOCEMBARQ
*"     REFERENCE(RUA) TYPE  J1B_NF_XML_HEADER-E1_XLGR
*"     REFERENCE(NUM1) TYPE  J1B_NF_XML_HEADER-E1_NRO
*"     REFERENCE(NUM2) TYPE  J1B_NF_XML_HEADER-E1_XCPL
*"     REFERENCE(ISUF) TYPE  J1B_NF_XML_HEADER-E1_ISUF
*"     REFERENCE(CNPJ) TYPE  J1B_NF_XML_HEADER-G_CNPJ
*"     REFERENCE(BAIRRO) TYPE  J1B_NF_XML_HEADER-F_XBAIRRO
*"     REFERENCE(CMUN) TYPE  J1B_NF_XML_HEADER-F_CMUN
*"     REFERENCE(CIDADE) TYPE  J1B_NF_XML_HEADER-F_XMUN
*"     REFERENCE(REGIAO) TYPE  J1B_NF_XML_HEADER-F_UF
*"     REFERENCE(REGIAO_EMB) TYPE  J1B_NF_XML_HEADER-UFEMBARQ
*"     REFERENCE(CEP) TYPE  J1B_NF_XML_HEADER-E1_CEP
*"     REFERENCE(IEST) TYPE  J1B_NF_XML_HEADER-E1_IE
*"     REFERENCE(CPF) TYPE  J1B_NF_XML_HEADER-E_CPF
*"     REFERENCE(PAIS) TYPE  J1B_NF_XML_HEADER-E1_XPAIS
*"     REFERENCE(CPL) TYPE  J1B_NF_XML_HEADER-E1_XCPL
*"  CHANGING
*"     REFERENCE(PARID) TYPE  J_1BNFNAD-PARID
*"--------------------------------------------------------------------

  DATA: BEGIN OF w_adrc.
          INCLUDE STRUCTURE adrc.
  DATA: END OF w_adrc.

  DATA: BEGIN OF wa_j_1btxjurt.
          INCLUDE STRUCTURE j_1btxjurt.
  DATA: END OF wa_j_1btxjurt.

*  DATA: BEGIN OF wa_yocodibge,
*          coduf TYPE yocoduf,
*        END OF wa_yocodibge.

  DATA: v_cgcbranch     LIKE j_1bbranch-cgc_branch,
        v_addrnumber    LIKE adrc-addrnumber,
        v_cgcpref(8)    TYPE n,
        v_cgcfilial(14) TYPE n,
        v_parid         LIKE adrc-name4,
        v_country       TYPE adrc-country,
        ls_t005t        TYPE t005t.

* Variável de Posição e Dígito e Contador de Caracteres
  DATA: v_pos TYPE i VALUE 0,
        v_dig TYPE c,
        v_len TYPE i,
        v_uf  TYPE regio,
        v_cod TYPE char4,
        v_c1  TYPE char10,
        v_e1  TYPE char10.

  CLEAR: v_addrnumber,v_cgcbranch.
  CLEAR: v_cgcbranch.

  SET LOCALE LANGUAGE sy-langu.

* Loca de retirada
  IF partyp = 'L'.

    SELECT b~name4 INTO v_parid
    FROM tvst AS a INNER JOIN adrc AS b
    ON b~addrnumber = a~adrnr UP TO 1 ROWS
    WHERE a~vstel = parid .
    ENDSELECT.

    parid = v_parid.

    TRANSLATE parid TO UPPER CASE.

  ENDIF.

* Filial
  IF partyp = 'B'.
    SELECT SINGLE adrnr cgc_branch state_insc
            FROM j_1bbranch
            INTO (v_addrnumber,v_cgcbranch,iest)
            WHERE bukrs = parid(4)
          AND branch = parid+4(4).

    CALL FUNCTION 'J_1BREAD_CGC_COMPANY'
      EXPORTING
        bukrs       = parid(4)
      IMPORTING
        cgc_company = v_cgcpref.

    CALL FUNCTION 'J_1BBUILD_CGC'
      EXPORTING
        cgc_company = v_cgcpref
        cgc_branch  = v_cgcbranch
      IMPORTING
        cgc_number  = v_cgcfilial.
    cnpj = v_cgcfilial.
  ENDIF.

* Fornecedor
  IF partyp = 'V'.
    SELECT SINGLE adrnr stcd1 stcd2 stcd3
       FROM lfa1
         INTO (v_addrnumber,cnpj,cpf,iest)
           WHERE lifnr = parid.

  ENDIF.

* Cliente
  IF partyp = 'C' OR ( partyp = 'L' AND parid <> '' ).

    SELECT SINGLE adrnr stcd1 stcd2 stcd3
      FROM kna1
        INTO (v_addrnumber,cnpj,cpf,iest)
          WHERE kunnr = parid.

  ENDIF.

* Busca dados do endereço
  SELECT * INTO w_adrc FROM adrc
  WHERE addrnumber = v_addrnumber.
  ENDSELECT.

* Elimina caracteres alfabeticos e caracteres estranhos
* do campo IEST(iscricao estadual).
  IF ( iest  <> 'ISENTO'   OR
     iest    <> 'isento' ) AND
     iest(2) <> 'PR'.
    TRANSLATE iest USING '< > ! @ # $ % ^ & * ( ) _ + - = [ ] { } \ | ; : " / ? . , ` ~ '.
    TRANSLATE iest USING 'A B C D E F G H I J L M N W O P Q R S T U V X Z '.
    TRANSLATE iest USING 'a b c d e f g h i j l m n w o p q r s t u v x z '.
    TRANSLATE iest USING 'Ã Õ Ç Á Ó Ô ã õ á é ç '.
    CONDENSE iest NO-GAPS.
  ENDIF.

  CHECK sy-subrc = 0.
  CONCATENATE w_adrc-name1 w_adrc-name2 INTO nome SEPARATED BY space.
  TRANSLATE w_adrc-post_code1 USING '- '.
  CONDENSE w_adrc-post_code1 NO-GAPS.

* enderecos
  IF w_adrc-country = 'BR'. "BRASIL
    rua = w_adrc-street.
    num1 = w_adrc-house_num1.
    num2 = w_adrc-house_num2.
    bairro = w_adrc-city2.
    cmun = w_adrc-taxjurcode+3(7).
    cidade = w_adrc-city1.
    regiao = w_adrc-region.
    regiao_emb = w_adrc-region(2).
    cep = w_adrc-post_code1.
    cpl = w_adrc-house_num2.
  ELSE.                     "EXTERIOR
    rua = w_adrc-street.
    num1 = w_adrc-house_num1.
    num2 = w_adrc-house_num2.
    bairro = w_adrc-city2.
    IF w_adrc-city2 IS INITIAL.
      bairro = w_adrc-city1.
    ENDIF.
    cmun   = '9999999'.
    cidade = 'EXTERIOR'.
    regiao = 'EX'.
    regiao_emb = w_adrc-region(2).

    cnpj = ' '.

  ENDIF.

* C1_CMUN
  CLEAR v_uf.
  CLEAR v_len.
  CLEAR v_pos.
  CLEAR v_cod.
  CLEAR v_dig.
  CLEAR wa_j_1btxjurt.

* busca denominacao do pais
  IF w_adrc-country <> ''.
    CALL FUNCTION 'READ_T005T'
      EXPORTING
        ic_spras = 'P'
        ic_land1 = w_adrc-country
      IMPORTING
        es_t005t = ls_t005t.

    IF sy-subrc = 0.
      MOVE ls_t005t-landx TO pais.
    ENDIF.

  ENDIF.
* exporta country para memoria
  v_country = w_adrc-country.
  EXPORT country FROM v_country TO MEMORY ID 'COUNTRY'.


ENDFUNCTION.