  METHOD add_text.

    DATA: lv_msgv1 TYPE string,
          lv_msgv2 TYPE string,
          lv_msgv3 TYPE string,
          lv_msgv4 TYPE string,
          lv_msgno TYPE symsgno,
          lv_msgtxt TYPE string.

* Determine Message no dependend if internal or not.
    lv_msgno = gc_symsgno_000.
    IF iv_internal = abap_true.
      lv_msgno = gc_symsgno_900.
    ENDIF.

* Replace placeholders.
    lv_msgtxt = iv_text.
    REPLACE FIRST OCCURRENCE OF gc_char01_placeholder IN lv_msgtxt
WITH iv_msgv1.
    REPLACE FIRST OCCURRENCE OF gc_char01_placeholder IN lv_msgtxt
WITH iv_msgv2.
    REPLACE FIRST OCCURRENCE OF gc_char01_placeholder IN lv_msgtxt
WITH iv_msgv3.
    REPLACE FIRST OCCURRENCE OF gc_char01_placeholder IN lv_msgtxt
WITH iv_msgv4.

* Split text in to 000 or 900 message & & & &.
    CATCH SYSTEM-EXCEPTIONS OTHERS = 0. " Prevent Short Dump in case

      lv_msgv1 = lv_msgtxt+0.
      lv_msgv2 = lv_msgtxt+50.
      lv_msgv3 = lv_msgtxt+100.
      lv_msgv4 = lv_msgtxt+150.
    ENDCATCH.

* Add message to log.
    me->add_message( EXPORTING iv_msg_type = iv_msg_type
                               iv_msg_id   = gc_symsgid_app_log
                               iv_msg_no   = lv_msgno
                               iv_msg_v1   = lv_msgv1
                               iv_msg_v2   = lv_msgv2
                               iv_msg_v3   = lv_msgv3
                               iv_msg_v4   = lv_msgv4 ).

  ENDMETHOD.                    "add_text