FUNCTION YNFEIN0001.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(NFEID) TYPE  /XNFE/ID
*"  TABLES
*"      TI_YNFEIN0002ST STRUCTURE  YNFEIN0002ST
*"----------------------------------------------------------------------

* Variável para GUID
  DATA: vl_guid_header TYPE /xnfe/innfehd-guid_header.

* Seleciona GUID da tabela /XNFE/INNFEHD
  CLEAR: vl_guid_header.
  SELECT SINGLE guid_header
    FROM /xnfe/innfehd
    INTO vl_guid_header
   WHERE nfeid EQ nfeid.

* Seleciona dados da tabela /XNFE/NFEASSIGN
  SELECT guid_header ponumber poitem delnumber delitem
         pomatnr pomaktx recquan recuom
    FROM /xnfe/nfeassign
    INTO TABLE ti_ynfein0002st
   WHERE guid_header = vl_guid_header.

* Preencher o campo NFEID para todas as linhas selecionadas
  LOOP AT ti_ynfein0002st.
    ti_ynfein0002st-nfeid = nfeid.
    MODIFY ti_ynfein0002st INDEX sy-tabix.
  ENDLOOP.

ENDFUNCTION.