  METHOD display_log.

    DATA:
          ls_disp_profile  TYPE bal_s_prof,
          lt_log_handle    TYPE bal_t_logh.

    " Get standard display profile
    CALL FUNCTION 'BAL_DSP_PROFILE_SINGLE_LOG_GET'
      IMPORTING
        e_s_display_profile = ls_disp_profile.

    " Display log
    APPEND me->mv_log_handle TO lt_log_handle.
* Displays application log on screen.
    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
      EXPORTING
        i_s_display_profile = ls_disp_profile
        i_t_log_handle      = lt_log_handle
      EXCEPTIONS
        OTHERS              = 0.


  ENDMETHOD.                    "display_log