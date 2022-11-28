FUNCTION ZALI_ADD_CUSTOMER.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_CUSTOMER) TYPE  ZALI_CUSTOMER
*"----------------------------------------------------------------------
   INSERT zali_customer FROM is_customer.

   IF sy-subrc = 0.
     MESSAGE i002(zali_web_shop) WITH is_customer-first_name is_customer-name is_customer-customer_number.
   ENDIF.
ENDFUNCTION.
