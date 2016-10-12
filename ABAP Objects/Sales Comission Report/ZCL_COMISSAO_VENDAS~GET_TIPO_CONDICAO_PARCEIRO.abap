*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obter tipo de condição x parceiro                         *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  29.09.2014  #***** - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_TIPO_PARCEIRO	TYPE FEHGR
*<-- CHANGING EX_R_KSCHL        TYPE R_KSCHL Tipo de condição
*<-- CHANGING EX_R_PARVW        TYPE R_PARVW Função do parceiro
*<-- CHANGING EX_T_COND_PARC    TYPE TP_COND_PARC Tipo de condição x Parceiro

METHOD get_tipo_condicao_parceiro.
*----------------------------------------------------------------------*
* Work-Areas / Field-Symbols                                           *
*----------------------------------------------------------------------*
  DATA:
    w_parvw LIKE LINE OF ex_r_parvw,
    w_kschl LIKE LINE OF ex_r_kschl.

*----------------------------------------------------------------------*
* Variáveis                                                            *
*----------------------------------------------------------------------*
  DATA:
    v_msg_erro TYPE t100-text.

*----------------------------------------------------------------------*
* Início                                                               *
*----------------------------------------------------------------------*
  SELECT kschl   " Tipo de condição
         parvw   " Parceiro
         fehgr   " Esquema de dados
   FROM zsdt033p " Comissão de Vendas - Tipo de condição x Parceiro
   INTO TABLE ex_t_cond_parc
   WHERE fehgr = im_tipo_parceiro.

  IF ex_t_cond_parc IS INITIAL.
*   Não há dados na tabela de condições x parceiros
    MESSAGE e002(zsdr033) INTO v_msg_erro.
    RAISE EXCEPTION TYPE zcx_comissao_vendas EXPORTING mensagem = v_msg_erro.
  ENDIF.

  LOOP AT ex_t_cond_parc ASSIGNING FIELD-SYMBOL(<f_w_cond_parc>).
    w_parvw-sign   = 'I'                  .                 "#EC NOTEXT
    w_parvw-option = 'EQ'                 .                 "#EC NOTEXT
    w_parvw-low    = <f_w_cond_parc>-parvw.
    APPEND w_parvw TO ex_r_parvw          .

    w_kschl-sign   = 'I'                  .                 "#EC NOTEXT
    w_kschl-option = 'EQ'                 .                 "#EC NOTEXT
    w_kschl-low    = <f_w_cond_parc>-kschl.
    APPEND w_kschl TO ex_r_kschl          .
  ENDLOOP.

ENDMETHOD.
