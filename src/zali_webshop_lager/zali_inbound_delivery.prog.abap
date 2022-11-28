*&---------------------------------------------------------------------*
*& Report zali_INBOUND_DELIVERY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zali_inbound_delivery.

CONSTANTS: lc_logobject TYPE bal_s_log-object    VALUE 'ZALI_',
           lc_subobjec  TYPE bal_s_log-subobject VALUE 'ZALI_'.

"start the application
TRY.
    DATA(lo_log) = NEW zcl_ali_webshop_log( iv_object = lc_logobject
                                         iv_suobj = lc_subobjec ).

    NEW zcl_ali_inbound_delivery_cntrl( io_log = lo_log )->start( ).

  CATCH zcx_ali_webshop_exception_NEW INTO DATA(lo_exc).

    "logg messages and display in a popup
*    lo_log->add_msg( is_message = lo_exc->get_message( ) ).
    lo_log->safe_log( ).
    lo_log->display_log_as_popup( ).

    "restart the application
    SUBMIT zali_inbound_delivery.
ENDTRY.
