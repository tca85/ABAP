*&---------------------------------------------------------------------*
*&  Include           ZXQEVU12
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(I_QALS)  LIKE  QALS STRUCTURE   QALS OPTIONAL
*"             VALUE(I_QAVE)  LIKE  QAVE STRUCTURE   QAVE OPTIONAL
*"             VALUE(I_RQEVA) LIKE  RQEVA STRUCTURE  RQEVA OPTIONAL
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
*                       xxxxxxxxxxxxxxxxx                              *
*----------------------------------------------------------------------*
* Transação: QA32 e QE01                                               *
* Projeto  : CMOD - YNQM                                               *
* Ampliação: SMOD - QEVA0010 / SE37 - EXIT_SAPMQEVA_010                *
* Descrição: DU: verificação da decisão de utilização                  *
*----------------------------------------------------------------------*
* Objetivo : Obrigar criação da Nota de QM quando a DU for reprovada   *
* Módulo   : QM                                                        *
* Projeto  : Notas de QM (Não-conformidade no recebimento físico)      *
* Funcional: xxxxxxxxxxxxxxxxxxxx                                      *
* ABAP     : Thiago Cordeiro Alves                                     *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data         Descrição                                     *
* ACTHIAGO  17.10.2013  #63782 - Desenvolvimento inicial               *
* ACTHIAGO  31.10.2013  #66404 - Bloquear gravação de Decisões de Util.*
*                                (DU) com granel reprovado             *
*----------------------------------------------------------------------*

CHECK sy-tcode = 'QA32'  " Seleção dos lotes de controle
   OR sy-tcode = 'QE01'  " Entrar resultados
   OR sy-tcode = 'QA11'. " Entrar decisão de utilização

TYPES:
  BEGIN OF ty_tp_material      ,
    matnr    TYPE mara-matnr   , " Nº do material
    mtart    TYPE mara-mtart   , " Tipo de material
  END OF ty_tp_material        ,

  BEGIN OF ty_resb             ,
    rsnum    TYPE resb-rsnum   , " Nº reserva / necessidades dependentes
    matnr    TYPE resb-matnr   , " Nº do material
    werks    TYPE resb-werks   , " Centro
    charg    TYPE resb-charg   , " Número do lote
  END OF ty_resb               ,

  BEGIN OF ty_qals             ,
    prueflos TYPE qals-prueflos, " Nº lote de controle
    werk     TYPE qals-werk    , " Centro
    matnr    TYPE qals-matnr   , " Nº do material
    charg    TYPE qals-charg   , " Número do lote
  END OF ty_qals               ,

  BEGIN OF ty_qave             ,
    prueflos TYPE qave-prueflos, " Nº lote de controle
    vcode    TYPE qave-vcode   , " Cod. da decisão de utilização
  END OF ty_qave               .


DATA: t_tp_material TYPE STANDARD TABLE OF ty_tp_material, " Dados gerais de material
      t_resb        TYPE STANDARD TABLE OF ty_resb       , " Reserva/necessidade dependente
      t_qals        TYPE STANDARD TABLE OF ty_qals       , " Registro do lote de controle
      t_qave        TYPE STANDARD TABLE OF ty_qave       . " Processamento de controle: decisão de utilização

DATA: w_tp_material LIKE LINE OF t_tp_material,
      w_qave        LIKE LINE OF t_qave       ,
      w_resb        LIKE LINE OF t_resb      .

CONSTANTS:
  c_du_reprovada     TYPE qpcd-code   VALUE '03'                   ,
  c_du_aprovada      TYPE qpcd-code   VALUE '01'                   ,
  c_cod_du           TYPE c LENGTH 21 VALUE '(SAPMQEVA)RQEVA-VCODE',
  c_lst_tec_mat      TYPE resb-stlty  VALUE 'M'                    ,
  c_prd_semi_acb     TYPE t134-mtart  VALUE 'HALB'                 ,
  c_prd_semi_acb_imp TYPE t134-mtart  VALUE 'YHAL'                 ,
  c_embalagem        TYPE t134-mtart  VALUE 'VERP'                 ,
  c_mat_revenda      TYPE t134-mtart  VALUE 'HAWA'                 ,
  c_mat_prima        TYPE t134-mtart  VALUE 'ROH'                  ,
  c_mat_prima_imp    TYPE t134-mtart  VALUE 'YROH'                 .

FIELD-SYMBOLS <fs_cod_du> TYPE rqeva-vcode. " Cod. da decisão de utilização

DATA: v_qtd TYPE i.

ASSIGN (c_cod_du) TO <fs_cod_du>.

CHECK <fs_cod_du> IS ASSIGNED.

IF <fs_cod_du> = c_du_aprovada
    AND i_qals-aufnr IS NOT INITIAL.

* Seleciona o nº da reserva (necessidades)
  SELECT rsnum matnr werks charg
    FROM resb
    INTO TABLE t_resb
    WHERE aufnr = i_qals-aufnr  " Nº ordem
      AND xloek <> 'X'          " Item foi eliminado
      AND bdmng <> 0.           " Quantidade necessária

  IF t_resb IS NOT INITIAL.
*   Verifica qual é o tipo do material
    SELECT matnr mtart
     FROM mara
     INTO TABLE t_tp_material
     FOR ALL ENTRIES IN t_resb
     WHERE matnr = t_resb-matnr
       AND mtart IN (c_prd_semi_acb, "HALB"
                     c_prd_semi_acb_imp,
                     c_mat_prima_imp). "YHAL"

*   Buscar o lote de controle do granel
    CLEAR w_tp_material.
    READ TABLE t_tp_material
    INTO w_tp_material
    INDEX 1.

    CLEAR w_resb.
    READ TABLE t_resb
    INTO w_resb
    WITH KEY matnr = w_tp_material-matnr.

    IF sy-subrc EQ 0.
*     Nº lote de controle
      SELECT prueflos werk matnr charg
        FROM qals
        INTO TABLE t_qals
        WHERE werk  = w_resb-werks
          AND matnr = w_resb-matnr
          AND charg = w_resb-charg.

    ENDIF.
  ENDIF.

* Registro do lote de controle
  IF t_qals IS NOT INITIAL.
*   Cod. da decisão de utilização
    SELECT prueflos vcode
     FROM qave
     INTO TABLE t_qave
     FOR ALL ENTRIES IN t_qals
      WHERE prueflos = t_qals-prueflos.

    SORT t_qave BY prueflos ASCENDING.

    CLEAR: w_qave.
    READ TABLE t_qave
    INTO w_qave
    WITH KEY vcode = c_du_reprovada. " 3

    IF sy-subrc = 0 OR t_qave IS INITIAL.
*     Granel reprovado! Não é possível gravar a DU
      MESSAGE e005(ynqm).
    ENDIF.
  ENDIF.
ENDIF.
