CLASS zcl_ali_webshop_log DEFINITION
   PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS: constructor
      IMPORTING
        !iv_object TYPE balobj_d
        !iv_suobj  TYPE balsubobj ,
      add_msg
        IMPORTING
          !is_message TYPE bal_s_msg ,
      safe_log ,
      display_log_as_popup,
      add_msg_from_sys.
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: mv_log_handle TYPE balloghndl,
          mt_log_handle TYPE bal_t_logh.

ENDCLASS.



CLASS ZCL_ALI_WEBSHOP_LOG IMPLEMENTATION.


  METHOD add_msg.
    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = mv_log_handle     " Log handle
        i_s_msg          = is_message        " Notification data
*      IMPORTING
*       e_s_msg_handle   =                  " Message handle
*       e_msg_was_logged =                  " Message collected
*       e_msg_was_displayed =                  " Message output
      EXCEPTIONS
        log_not_found    = 1                " log not found
        msg_inconsistent = 2                " message inconsistent
        log_is_full      = 3                " message number 999999 reached. log is full
        OTHERS           = 4.
    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.


  METHOD add_msg_from_sys.

    DATA: ls_msg TYPE bal_s_msg.

    ls_msg-msgty = sy-msgty.
    ls_msg-msgid = sy-msgty.
    ls_msg-msgno = sy-msgty.
    ls_msg-msgv1 = sy-msgv1.
    ls_msg-msgv2 = sy-msgv2.
    ls_msg-msgv3 = sy-msgv3.
    ls_msg-msgv4 = sy-msgv4.

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = mv_log_handle     " Log handle
        i_s_msg          = ls_msg        " Notification data
*      IMPORTING
*       e_s_msg_handle   =                  " Message handle
*       e_msg_was_logged =                  " Message collected
*       e_msg_was_displayed =                  " Message output
*      EXCEPTIONS
        log_not_found    = 1                " Log not found
        msg_inconsistent = 2                " Message inconsistent
        log_is_full      = 3                " Message number 999999 reached. Log is full
        others           = 4.
    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
    DATA: ls_log TYPE bal_s_log.
    CONSTANTS: lv_obj TYPE balobj_d VALUE 'ZAHK'.

    GET TIME STAMP FIELD DATA(lv_date).
    ls_log = VALUE #( object    = iv_object
                      extnumber = lv_date
                      subobject = iv_suobj ).

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log                 = ls_log
      IMPORTING
        e_log_handle            = mv_log_handle
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.

    IF sy-subrc <> 0.
* Implement suitable error handling here
      MESSAGE i055(zali_web_shop) INTO DATA(lv_msg).
*      RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  METHOD display_log_as_popup.
    DATA: ls_dp_profile TYPE bal_s_prof.

    CALL FUNCTION 'BAL_DSP_PROFILE_POPUP_GET'
*      EXPORTING
*        start_col           = 5                " Application Log: Dialog box coordinates
*        start_row           = 5                " Application Log: Dialog box coordinates
*        end_col             = 87               " Application Log: Dialog box coordinates
*        end_row             = 25               " Application Log: Dialog box coordinates
      IMPORTING
        e_s_display_profile = ls_dp_profile.     " Display Profile

    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
      EXPORTING
        i_s_display_profile  = ls_dp_profile     " Display Profile
        i_t_log_handle       = me->mt_log_handle " Restrict display by log handle
*       i_t_msg_handle       =                  " Restrict display by message handle
*       i_s_log_filter       =                  " Restrict display by log filter
*       i_s_msg_filter       =                  " Restrict display by message filter
*       i_t_log_context_filter        =         " Restrict display by log context filter
*       i_t_msg_context_filter        =         " Restrict display by message context filter
*       i_amodal             = space            " Display amodally in new session
        i_srt_by_timstmp     = abap_true        " Sort Logs by Timestamp ('X') or Log Number (SPACE)
*       i_msg_context_filter_operator = 'A'     " Operator for message context filter ('A'nd or 'O'r)
*        IMPORTING
*       e_s_exit_command     =                  " Application Log: Key confirmed by user at end
      EXCEPTIONS
        profile_inconsistent = 1                " Inconsistent display profile
        internal_error       = 2                " Internal data formatting error
        no_data_available    = 3                " No data to be displayed found
        no_authority         = 4                " No display authorization
        OTHERS               = 5.
    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.


  METHOD safe_log.
    APPEND mv_log_handle TO mt_log_handle.

    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_client         = sy-mandt          " Client in which the new log is to be saved
*       i_in_update_task = space             " Save in UPDATE TASK
        i_save_all       = abap_true         " Save all logs in memory
        i_t_log_handle   = me->mt_log_handle " Table of log handles
*       i_2th_connection = space             " FALSE: No secondary connection
*       i_2th_connect_commit = space            " FALSE: No COMMIT in module
*       i_link2job       = 'X'               " Boolean Variable (X = True, - = False, Space = Unknown)
*      IMPORTING
*       e_new_lognumbers =                   " Table of new log numbers
*       e_second_connection  =               " Name of Secondary Connection
      EXCEPTIONS
        log_not_found    = 1                " Log not found
        save_not_allowed = 2                " Cannot save
        numbering_error  = 3                " Number assignment error
        OTHERS           = 4.
    IF sy-subrc <> 0.
*        REFRESH: me->mt_log_handle.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
