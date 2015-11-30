FUNCTION-POOL ynqm.

TYPE-POOLS: shlp, szadr.

TABLES: adsmtp, rqm07, qnqmasm0, kna1, lfa1, diadr, diadrp,
        sadr, viqmel, wqmsm, viqmsm, itcpo, mtcom, mtext,
        kupav, itcpp.

CONTROLS: partner TYPE TABLEVIEW USING SCREEN 2001.

TYPES:
  BEGIN OF ty_destinatario       ,
   parvw     TYPE ihpa-parvw     ,
   vtext     TYPE tpart-vtext    ,
   parnr     TYPE ihpa-parnr     ,
   name_list TYPE diadr-name_list,
   emailadr  TYPE rqm07-emailadr ,
  END OF ty_destinatario         .

DATA: t_destinatario TYPE STANDARD TABLE OF ty_destinatario,
      w_destinatario LIKE LINE OF t_destinatario           .

DATA:
  BEGIN OF g_partner_tab OCCURS 0,
   parvw     LIKE ihpa-parvw     ,
   vtext     LIKE tpart-vtext    ,
   parnr     LIKE ihpa-parnr     ,
   name_list LIKE diadr-name_list,
   adrnr     LIKE ihpa-adrnr     ,
   mark(1)   TYPE c              ,
  END OF g_partner_tab           .

DATA:
  BEGIN OF act_partner           ,
   parvw     LIKE ihpa-parvw     ,
   vtext     LIKE tpart-vtext    ,
   parnr     LIKE ihpa-parnr     ,
   name_list LIKE diadr-name_list,
   adrnr     LIKE ihpa-adrnr     ,
   mark(1)   TYPE c              ,
  END OF act_partner             .

DATA:
BEGIN OF g_reply_type OCCURS 0           .
DATA: manum           LIKE qmsm-manum    ,
      doku_type       TYPE c LENGTH 40   ,
      doku_type2      TYPE c LENGTH 01   ,
      g_send_mail     TYPE c LENGTH 01   ,
      g_send_internal TYPE c LENGTH 01   ,
      g_send_fax      TYPE c LENGTH 01   ,
      g_send_email    TYPE c LENGTH 01   ,
      g_receiver_b    LIKE adrml-uname   ,
      g_receiver_u    LIKE lfa1-lfurl    ,
      g_form          LIKE itcta-tdform  ,
      g_once          TYPE c LENGTH 01   ,
      g_langtext      TYPE qmma-indtx    ,
      land            LIKE rqm07-land    ,
      telfx           LIKE lfa1-telfx    ,
      lfurl           LIKE lfa1-lfurl    ,
      anred           LIKE lfa1-anred    ,
      name1           LIKE lfa1-name1    ,
      name2           LIKE lfa1-name2    ,
      stras           LIKE lfa1-stras    ,
      pfach           LIKE lfa1-pfach    ,
      ort01           LIKE lfa1-ort01    ,
      ort02           LIKE lfa1-ort02    ,
      pstlz           LIKE lfa1-pstlz    ,
      pfort           LIKE lfa1-pfort    ,
      pstl2           LIKE lfa1-pstl2    ,
      land1           LIKE lfa1-land1    ,
      regio           LIKE lfa1-regio    ,
      send_nam        LIKE soxfx-send_nam,
      send_dep        LIKE soxfx-send_dep,
      send_tel        LIKE soxfx-send_tel,
      send_fax        LIKE soxfx-send_fax,
      langu           LIKE thead-tdspras .
DATA: END OF g_reply_type.

DATA: g_adsmtp TYPE TABLE OF szadr_adsmtp_line WITH HEADER LINE,
      g_adrml  TYPE TABLE OF szadr_adrml_line  WITH HEADER LINE,
      g_adfax  TYPE TABLE OF szadr_adfax_line  WITH HEADER LINE,
      g_ihpa   LIKE ihpa OCCURS 5              WITH HEADER LINE.

DATA: g_adrnr             LIKE ihpavb-adrnr_kupav  ,
      g_persnr            LIKE addr3_val-persnumber,
      g_addr1_complete    TYPE szadr_addr1_complete,
      g_addr3_complete    TYPE szadr_addr3_complete,
      g_addr1             TYPE szadr_addr1_line    ,
      g_addr3             TYPE szadr_addr3_line    ,
      g_8d_form           LIKE itcta-tdform        ,
      g_parnrv            TYPE ihpa-parnr          ,
      l_address_selection LIKE addr1_sel           ,
      codetext            TYPE c LENGTH 80         ,
      v_marc              TYPE c LENGTH 01         ,
      g_bescheid_manum    LIKE qmsm-manum          ,
      g_langu             LIKE sy-langu            ,
      ok_code             LIKE sy-ucomm            ,
      save_ok_code        LIKE sy-ucomm            ,
      g_only_once         LIKE qm00-qkz VALUE 'X'  ,
      l_tfill             LIKE sy-tfill            .

DATA: g_usr03     LIKE usr03 ,
      g_pawa      TYPE kupav ,
      wa_8d_itcpo LIKE itcpo .

CONSTANTS:  c_x  VALUE 'X'.
