*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : GET_SEARCH_HELP_RECURSOS                                  *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Criar search help com os recursos (CRHD-ARBPL)            *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*<-- RETURNING VALUE( EX_RECURSO )  TYPE YAPT001

METHOD get_search_help_recursos.

*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
  TYPES:
   BEGIN OF ty_sh_recurso ,
     arbpl TYPE crhd-arbpl,
     ktext TYPE crtx-ktext,
     werks TYPE crhd-werks,
   END OF ty_sh_recurso   .

*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_sh_recurso       TYPE STANDARD TABLE OF ty_sh_recurso,
    t_sh_recurso_selec TYPE STANDARD TABLE OF ddshretval   ,
    t_field_map        TYPE STANDARD TABLE OF dselc        .

*----------------------------------------------------------------------*
* Work Areas
*----------------------------------------------------------------------*
  DATA:
    w_sh_recurso_selec LIKE LINE OF t_sh_recurso_selec,
    w_field_map        LIKE LINE OF t_field_map       .

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
  CONSTANTS:
    c_search_help_domin TYPE c LENGTH 01     VALUE 'S'    ,
    c_campo1            TYPE fieldname       VALUE 'F0001',
    c_campo2            TYPE fieldname       VALUE 'F0002',
    c_campo3            TYPE fieldname       VALUE 'F0003',
    c_centro_trabalho   TYPE dfies-fieldname VALUE 'ARBPL',
    c_dsc_centro_trab   TYPE dfies-fieldname VALUE 'KTEXT',
    c_centro            TYPE dfies-fieldname VALUE 'WERKS'.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  SELECT crhd~arbpl
         crtx~ktext
         crhd~werks
  FROM crhd
  INNER JOIN crtx ON crhd~objid = crtx~objid
  INTO TABLE t_sh_recurso.

  IF t_sh_recurso IS INITIAL.
    EXIT.
  ENDIF.

  SORT t_sh_recurso BY arbpl ASCENDING.

  w_field_map-fldname   = c_campo1         .
  w_field_map-dyfldname = c_centro_trabalho.
  APPEND w_field_map TO t_field_map        .

  w_field_map-fldname   = c_campo2         .
  w_field_map-dyfldname = c_dsc_centro_trab.
  APPEND w_field_map TO t_field_map        .

  w_field_map-fldname   = c_campo3 .
  w_field_map-dyfldname = c_centro .
  APPEND w_field_map TO t_field_map.

* Exibe o Search Help dinâmico
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = c_centro_trabalho   " ARBPL
      value_org       = c_search_help_domin " S
    TABLES
      value_tab       = t_sh_recurso
      dynpfld_mapping = t_field_map
      return_tab      = t_sh_recurso_selec
    EXCEPTIONS
      parameter_error = 1                                   "#EC *
      no_values_found = 2
      OTHERS          = 3.

  LOOP AT t_sh_recurso_selec INTO w_sh_recurso_selec.
    CASE w_sh_recurso_selec-retfield.
      WHEN c_centro_trabalho. " ARBPL
        ex_recurso-arbpl = w_sh_recurso_selec-fieldval.
      WHEN c_centro. " WERKS
        ex_recurso-werks = w_sh_recurso_selec-fieldval.
    ENDCASE.
  ENDLOOP.

ENDMETHOD.