*&---------------------------------------------------------------------*
*& Report ZALI_CUSTOMER_PORTAL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZALI_CUSTOMER_PORTAL.

CONSTANTS: lc_logobject TYPE bal_s_log-object VALUE 'ZALI',
           lc_subobjec  TYPE bal_s_log-subobject VALUE 'ZALI'.

TRY.
   "logg error message and save in db
    DATA(lo_log) = NEW zcl_ali_webshop_log( iv_object = lc_logobject
                                              iv_suobj = lc_subobjec ).

    "start the application
    NEW zcl_ali_customer_login_cntrl( io_log = lo_log )->start( ).

  CATCH zcx_ali_webshop_exception_new INTO DATA(lo_exc).

    lo_log->add_msg( is_message = lo_exc->get_message( ) ).
    lo_log->safe_log( ).
    "output error message
    MESSAGE lo_exc.
    "If a Exception comes up in the Login oder Register Screen restart application
    SUBMIT zali_customer_portal.

ENDTRY.
