REPORT zbapi_prices_conditions NO STANDARD PAGE HEADING.

DATA:
  t_bapicondct  TYPE STANDARD TABLE OF bapicondct     ,
  t_bapicondhd  TYPE STANDARD TABLE OF bapicondhd     ,
  t_bapicondit  TYPE STANDARD TABLE OF bapicondit     ,
  t_bapicondqs  TYPE STANDARD TABLE OF bapicondqs     ,
  t_bapicondvs  TYPE STANDARD TABLE OF bapicondvs     ,
  t_bapiret2    TYPE STANDARD TABLE OF bapiret2       ,
  t_bapiknumhs  TYPE STANDARD TABLE OF bapiknumhs     ,
  t_mem_initial TYPE STANDARD TABLE OF cnd_mem_initial.

DATA:
  w_bapicondct LIKE LINE OF t_bapicondct,
  w_bapicondhd LIKE LINE OF t_bapicondhd,
  w_bapicondit LIKE LINE OF t_bapicondit,
  w_bapiknumhs LIKE LINE OF t_bapiknumhs,
  w_bapiret2   LIKE LINE OF t_bapiret2  .

START-OF-SELECTION.

* 004 = Change: Message contains changes

  CLEAR w_bapicondct                                   .
  w_bapicondct-operation  = '004'                      .
  w_bapicondct-applicatio = 'V'                        .
  w_bapicondct-cond_type  = 'YDEC'                     .
  w_bapicondct-table_no   = '972'                      .
  w_bapicondct-cond_usage = 'A'                        .
  w_bapicondct-cond_no    = '$000000001'               .
  w_bapicondct-valid_from = '20150101'                 .
  w_bapicondct-valid_to   = '20151231'                 .
  w_bapicondct-varkey     = '1300PR 000000000001000561'.
  APPEND w_bapicondct TO t_bapicondct                  .

  CLEAR w_bapicondhd                                   .
  w_bapicondhd-operation  = '004'                      .
  w_bapicondhd-applicatio = 'V'                        .
  w_bapicondhd-cond_type  = 'YDEC'                     .
  w_bapicondhd-table_no   = '972'                      .
  w_bapicondhd-cond_usage = 'A'                        .
  w_bapicondhd-cond_no    = '$000000001'               .
  w_bapicondhd-created_by = sy-uname                   .
  w_bapicondhd-creat_date = sy-datum                   .
  w_bapicondhd-varkey     = '1300PR 000000000001000561'.
  w_bapicondhd-valid_from = '20150101'                 .
  w_bapicondhd-valid_to   = '20151231'                 .
  APPEND w_bapicondhd TO t_bapicondhd                  .

  CLEAR w_bapicondit                                   .
  w_bapicondit-operation  = '004'                      .
  w_bapicondit-applicatio = 'V'                        .
  w_bapicondit-cond_type  = 'YDEC'                     .
  w_bapicondit-cond_no    = '$000000001'               .
  w_bapicondit-scaletype  = 'A'                        .
  w_bapicondit-calctypcon = 'A'                        .
  w_bapicondit-cond_count = 1                          .
  w_bapicondit-cond_value = '10.00'                    .
  w_bapicondit-condcurr   = '%'                        .
  w_bapicondit-pmnttrms   = 'YDEC'                     .
  w_bapicondit-conditidx  = 01                         .
  APPEND w_bapicondit TO t_bapicondit                  .

  CALL FUNCTION 'BAPI_PRICES_CONDITIONS'
    EXPORTING
      pi_initialmode = 'X'
    TABLES
      ti_bapicondct  = t_bapicondct
      ti_bapicondhd  = t_bapicondhd
      ti_bapicondit  = t_bapicondit
      ti_bapicondqs  = t_bapicondqs
      ti_bapicondvs  = t_bapicondvs
      to_bapiret2    = t_bapiret2
      to_bapiknumhs  = t_bapiknumhs
      to_mem_initial = t_mem_initial
    EXCEPTIONS
      update_error   = 1
      OTHERS         = 2.

  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    LOOP AT t_bapiknumhs INTO w_bapiknumhs.
      WRITE:/  w_bapiknumhs-cond_no_old,
               w_bapiknumhs-cond_no_new.
    ENDLOOP.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.