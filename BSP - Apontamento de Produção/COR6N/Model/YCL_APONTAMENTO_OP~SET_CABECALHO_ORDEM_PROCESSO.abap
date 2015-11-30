*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                     *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : SET_CABECALHO_ORDEM_PROCESSO                              *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Preenche o cabeçalho da ordem de processo (COR3)          *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IMPORTING IM_ORDEM_PROCESSO  TYPE AFKO-AUFNR

METHOD set_cabecalho_ordem_processo.

*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
  TYPES:
    BEGIN OF ty_afpo       ,
      aufnr TYPE afpo-aufnr, " Nº ordem
      matnr TYPE afpo-matnr, " Nº material para ordem
      charg TYPE afpo-charg, " Número do lote
      maktx TYPE makt-maktx, " Descrição do material
    END OF ty_afpo         .

*----------------------------------------------------------------------*
* Work Areas
*----------------------------------------------------------------------*
  DATA:
    w_caufv     TYPE ty_caufv    , " Visão dos cabeçalhos de ordens PCP/RK
    w_afpo      TYPE ty_afpo     , " Item da ordem
    w_afvc      TYPE ty_afvc     , " Operação da ordem
    w_plpo      TYPE ty_plpo     , " Plano: operação
    w_permissao TYPE ty_permissao.                          "#EC NEEDED

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA:
    v_recurso    TYPE arbpl                        ,
    v_msg_erro   TYPE string                       ,
    v_dsc_centro TYPE t001w-name1                  ,
    v_hora       TYPE p DECIMALS 2                 ,
    v_hr_teorica TYPE ty_cabecalho_op-hora_teorica ,
    v_qtd_total  TYPE ty_cabecalho_op-qtd_total    ,
    v_qtd_prod   TYPE ty_cabecalho_op-qtd_produzida.

*----------------------------------------------------------------------*
* Início
*----------------------------------------------------------------------*
  IF im_ordem_processo IS INITIAL.
*   Informe a ordem de processo
    MESSAGE e007(yapo) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDIF.

* Visão dos cabeçalhos de ordens PCP/RK
  SELECT SINGLE aufnr aufpl bukrs werks
                gsber auart gamng gmein igmng
   FROM caufv
   INTO w_caufv
   WHERE aufnr = im_ordem_processo
     AND autyp = me->c_ordem_processo.

  IF w_caufv IS INITIAL.
*   Ordem de processo & não encontrada
    MESSAGE e001(yapo) WITH im_ordem_processo INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDIF.

  w_permissao = me->get_permissoes_usuario( im_usuario = sy-uname
                                            im_centro  = w_caufv-werks ).

* Item da ordem
  SELECT SINGLE afpo~aufnr                                  "#EC *
                afpo~matnr
                afpo~charg
                makt~maktx
   FROM afpo
   INNER JOIN makt ON afpo~matnr = makt~matnr
   INTO w_afpo
   WHERE aufnr = w_caufv-aufnr. " Nº ordem

* Operação da ordem
  SELECT SINGLE aufpl aplzl vornr plnty                     "#EC *
                plnnr plnkn ltxa1 lek04 phseq
   FROM afvc
   INTO w_afvc
   WHERE aufpl = w_caufv-aufpl  " Nº de roteiro
     AND lek04 = space          " sem atividade restante
     AND phseq = me->c_folha_pi " Destinatário da receita de controle
     AND vornr = ( SELECT MAX( vornr ) " Nº operação
                   FROM afvc
                   WHERE aufpl = w_caufv-aufpl ).

* Versões operação ordem
  SELECT SINGLE arbpl                                       "#EC *
   FROM mcafvgv
   INTO v_recurso
   WHERE aufnr = w_caufv-aufnr " Nº ordem
     AND aufpl = w_caufv-aufpl " Nº de roteiro
     AND aplzl = w_afvc-aplzl. " Numerador interno

* Plano: operação
  SELECT SINGLE plnty plnnr plnkn vgw03 vgw04               "#EC *
   FROM plpo
   INTO w_plpo
   WHERE plnty = w_afvc-plnty  " Tipo de roteiro
     AND plnnr = w_afvc-plnnr  " Chave do grupo de listas de tarefas
     AND plnkn = w_afvc-plnkn. " Nº nó de lista de tarefas

  v_hora = w_plpo-vgw03 + w_plpo-vgw04. " Hora Teórica

  WRITE v_hora TO v_hr_teorica.
  SHIFT v_hr_teorica RIGHT DELETING TRAILING '.'.
  CONDENSE v_hr_teorica NO-GAPS.

* Centros/filiais
  SELECT SINGLE name1
   FROM t001w
   INTO v_dsc_centro
   WHERE werks = w_caufv-werks.

  SHIFT:
    w_afpo-matnr LEFT DELETING LEADING '0',
    w_afpo-aufnr LEFT DELETING LEADING '0'.

  CALL FUNCTION 'YNQM_CONVERT_FIRSTCHAR_TOUPPER'
    EXPORTING
      input_string  = w_afpo-maktx
    IMPORTING
      output_string = w_afpo-maktx.

  CALL FUNCTION 'YNQM_CONVERT_FIRSTCHAR_TOUPPER'
    EXPORTING
      input_string  = w_afvc-ltxa1
    IMPORTING
      output_string = w_afvc-ltxa1.

  v_qtd_total = w_caufv-gamng. " Quantidade total de ordens
  v_qtd_prod  = w_caufv-igmng. " Quantidade produzida confirmada de confirm.p/ordem

  WRITE w_caufv-gamng TO v_qtd_total UNIT w_caufv-gmein.
  SHIFT v_qtd_total RIGHT DELETING TRAILING '.'.
  CONDENSE v_qtd_total NO-GAPS.

  CONCATENATE v_qtd_total   " Quantidade Total
              w_caufv-gmein " Unidade de Medida
         INTO v_qtd_total   " Quantidade Total
      SEPARATED BY space.

  WRITE w_caufv-igmng TO v_qtd_prod UNIT w_caufv-gmein.
  SHIFT v_qtd_prod RIGHT DELETING TRAILING '.'.
  CONDENSE v_qtd_prod NO-GAPS.

  CONCATENATE v_qtd_prod    " Quantidade produzida
              w_caufv-gmein " Unidade de Medida
         INTO v_qtd_prod    " Quantidade produzida
      SEPARATED BY space.

* Atualiza o atributo 'w_cabecalho_op' com os valores obtidos
  me->w_cabecalho_op-ordem_processo = w_afpo-aufnr . " Nº ordem de processo
  me->w_cabecalho_op-lote           = w_afpo-charg . " Número do lote
  me->w_cabecalho_op-centro         = w_caufv-werks. " Centro
  me->w_cabecalho_op-dsc_centro     = v_dsc_centro . " Nome do centro
  me->w_cabecalho_op-material       = w_afpo-matnr . " Nº material para ordem
  me->w_cabecalho_op-dsc_mat        = w_afpo-maktx . " Descrição do material
  me->w_cabecalho_op-fase           = w_afvc-ltxa1 . " Descrição da Fase
  me->w_cabecalho_op-recurso        = v_recurso    . " Recurso
  me->w_cabecalho_op-qtd_total      = v_qtd_total  . " Quantidade total
  me->w_cabecalho_op-qtd_produzida  = v_qtd_prod   . " Quantidade produzida
  me->w_cabecalho_op-hora_teorica   = v_hr_teorica . " Hora Teórica

ENDMETHOD.