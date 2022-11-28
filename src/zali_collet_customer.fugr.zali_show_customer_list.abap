FUNCTION ZALI_SHOW_CUSTOMER_LIST.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"----------------------------------------------------------------------
DATA: gr_alv TYPE REF TO cl_salv_table,
      gt_cust TYPE TABLE OF zali_customer.

     SELECT * FROM zali_customer
            INTO TABLE gt_cust.

     cl_salv_table=>factory(
        IMPORTING
            r_salv_table = gr_alv
        CHANGING
            t_table = gt_cust
     ).
     gr_alv->display(  ).

ENDFUNCTION.
