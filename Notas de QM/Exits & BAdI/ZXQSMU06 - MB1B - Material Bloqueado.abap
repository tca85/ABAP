*&---------------------------------------------------------------------**&  Include           ZXQSMU06*&---------------------------------------------------------------------*TABLES: yypcl_ctrl_entor,        *mard,        yypcl_mseg.DATA: w_menge LIKE mard-labst,      w_hora  LIKE sy-uzeit.DATA: wa_mseg TYPE yypcl_mseg.DATA: BEGIN OF t_mard OCCURS 0,        matnr   LIKE mard-matnr,        werks   LIKE mard-werks,        lgort   LIKE mard-lgort,        labst   LIKE mard-labst,        insme   LIKE mard-insme,        speme   LIKE mard-speme,        retme   LIKE mard-retme,      END OF t_mard.DATA: BEGIN OF t_mard_s OCCURS 0,        matnr   LIKE mard-matnr,        qttot   LIKE mard-labst,      END OF t_mard_s.IF sy-tcode = 'MIGO'.  IF sy-ucomm = 'OK_POST' OR sy-ucomm = 'OK_POST1'.* Entrada de Mercadoria    READ TABLE s7_tab_mseg INDEX 1.    IF s7_tab_mseg-bwart = '101'.      SUBMIT yypcl_qm_migo       USING SELECTION-SCREEN '1000'*      WITH p_zeile EQ i_mseg-zeile*      WITH p_hora  EQ w_hora         AND RETURN.    ENDIF.  ENDIF.ENDIF.IF sy-tcode = 'MB1C' OR sy-tcode = 'MB1A'.*  IF sy-ucomm = 'BU'.  READ TABLE s7_tab_mseg INDEX 1.  IF s7_tab_mseg-bwart = '712'.    SELECT SINGLE * FROM yypcl_ctrl_entor                   WHERE werks EQ s7_tab_mseg-werks                     AND matnr EQ s7_tab_mseg-matnr.    IF sy-subrc EQ 0.      SELECT matnr werks lgort labst insme speme retme INTO TABLE t_mard                                                       FROM *mard                                                      WHERE werks EQ s7_tab_mseg-werks                                                        AND matnr EQ s7_tab_mseg-matnr.      LOOP AT t_mard.        MOVE: t_mard-matnr TO t_mard_s-matnr.        ADD t_mard-labst TO t_mard_s-qttot.        ADD t_mard-insme TO t_mard_s-qttot.        ADD t_mard-speme TO t_mard_s-qttot.        ADD t_mard-retme TO t_mard_s-qttot.        COLLECT t_mard_s.      ENDLOOP.      READ TABLE t_mard WITH KEY matnr = s7_tab_mseg-matnr.      w_menge = yypcl_ctrl_entor-mabst - t_mard_s-qttot.      IF s7_tab_mseg-menge GT w_menge.        MESSAGE e051(zmsg) WITH s7_tab_mseg-matnr.      ENDIF.    ENDIF.    MOVE-CORRESPONDING s7_tab_mseg TO wa_mseg.    MOVE: sy-datum   TO wa_mseg-data,          sy-uname   TO wa_mseg-usuario,          sy-uzeit   TO w_hora,          w_hora     TO wa_mseg-hora.    yypcl_mseg = wa_mseg.    MODIFY yypcl_mseg.  ENDIF.*  ENDIF.ENDIF.