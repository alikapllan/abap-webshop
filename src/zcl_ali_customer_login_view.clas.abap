CLASS zcl_ali_customer_login_view DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mo_customer_login_cntrl TYPE REF TO zcl_ali_customer_login_cntrl .

    METHODS: constructor
      IMPORTING
        !io_customer_login_cntrl TYPE REF TO zcl_ali_customer_login_cntrl ,
      call_login_screen
        RAISING zcx_ali_webshop_exception_new,
      login_screen_pai
        IMPORTING
          !iv_password TYPE zali_password
          !iv_email    TYPE zali_email .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ALI_CUSTOMER_LOGIN_VIEW IMPLEMENTATION.


  METHOD call_login_screen.
*    TRY.
        CALL FUNCTION 'ZALI_CUSTOMER_LOGIN'
          EXPORTING
            io_customer_login_view = me.
*      CATCH cx_root .
*        RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new.
*    ENDTRY.
  ENDMETHOD.


  METHOD constructor.

    me->mo_customer_login_cntrl = io_customer_login_cntrl.

  ENDMETHOD.


  METHOD login_screen_pai.
    TRY.
        CASE sy-ucomm.

          WHEN 'LEAVE'.
            me->mo_customer_login_cntrl->on_leave( ).

          WHEN 'CONFIRM' OR ' '.
            me->mo_customer_login_cntrl->on_confirm_login( EXPORTING iv_email = iv_email iv_password = iv_password ).

          WHEN 'REGISTER'.
            me->mo_customer_login_cntrl->on_register( ).

        ENDCASE.
      CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
