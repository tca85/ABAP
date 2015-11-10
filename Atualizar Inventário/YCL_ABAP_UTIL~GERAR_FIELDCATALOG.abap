*----------------------------------------------------------------------*
*                       ACHÉ LABORATÓRIOS                              *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Gerar fieldcatalog através de type ou estrutura da se11   *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  09.10.2014  #78961 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_W_REPORT       TYPE ANY
*<-- RETURNING EX_T_FIELDCATALOG TYPE LVC_T_FCAT

METHOD gerar_fieldcatalog.

*----------------------------------------------------------------------*
* Objetos
*----------------------------------------------------------------------*
  DATA:
    o_structure_desc TYPE REF TO cl_abap_structdescr.

*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
  DATA:
    t_campos TYPE cl_abap_structdescr=>included_view.

*----------------------------------------------------------------------*
* Work Areas
*----------------------------------------------------------------------*
  DATA:
    w_desc         TYPE x030l                                     ,
    w_fieldcatalog TYPE LINE OF lvc_t_fcat                        ,
    w_campos       TYPE LINE OF cl_abap_structdescr=>included_view.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_nome_estrutura TYPE dd02l-tabname.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*

  TRY.
      o_structure_desc ?= cl_abap_structdescr=>describe_by_data( im_w_estrutura ).
    CATCH cx_root.
  ENDTRY.

* Verifica se é uma estrutura criada na SE11, e obtém os detalhes
  IF o_structure_desc->is_ddic_type( ) IS NOT INITIAL.

    v_nome_estrutura = o_structure_desc->get_relative_name( ).

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_buffer_active        = space
        i_structure_name       = v_nome_estrutura
        i_bypassing_buffer     = 'X'
      CHANGING
        ct_fieldcat            = ex_t_fieldcatalog
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
  ENDIF.

* Obtém os detalhes da estrutura
  t_campos = o_structure_desc->get_included_view( ).

  LOOP AT t_campos INTO w_campos.
    CLEAR: w_fieldcatalog, w_desc.

    w_fieldcatalog-col_pos   = sy-tabix.
    w_fieldcatalog-fieldname = w_campos-name.

    IF w_campos-type->is_ddic_type( ) IS NOT INITIAL.
      w_desc = w_campos-type->get_ddic_header( ).
      w_fieldcatalog-rollname = w_desc-tabname.
    ELSE.
      w_fieldcatalog-inttype  = w_campos-type->type_kind.
      w_fieldcatalog-intlen   = w_campos-type->length.
      w_fieldcatalog-decimals = w_campos-type->decimals.
    ENDIF.

    APPEND w_fieldcatalog TO ex_t_fieldcatalog.
  ENDLOOP.

ENDMETHOD.
