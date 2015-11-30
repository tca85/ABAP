*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                     *
*----------------------------------------------------------------------*
* Classe   : YCL_APONTAMENTO_OP                                        *
* Método   : VALIDAR_CENTRO_RECURSO                                    *
*----------------------------------------------------------------------*
* Projeto  : SAP APO - Advanced Planning and Optimization              *
*            (Otimização Avançada do Planejamento de Produção)         *
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obter recursos (CRHD-ARBPL)                               *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  20.05.2015  #75787 - Desenvolvimento inicial               *
*----------------------------------------------------------------------*

*--> IM_RECURSO	TYPE CRHD-ARBPL
*--> CHANGING VALUE( EX_CENTRO )TYPE CRHD-WERKS

METHOD validar_centro_recurso.

  DATA:
    v_msg_erro TYPE string.

  IF im_recurso = '*'.
    EXIT.
  ENDIF.

  SELECT SINGLE werks                                       "#EC *
   FROM crhd
   INTO ex_centro
   WHERE arbpl = im_recurso.

  IF ex_centro IS INITIAL.
    CLEAR ex_centro.

*   Centro inexistente
    MESSAGE e004(yapo) INTO v_msg_erro.
    RAISE EXCEPTION TYPE ycx_apo EXPORTING msg = v_msg_erro.
  ENDIF.

ENDMETHOD.