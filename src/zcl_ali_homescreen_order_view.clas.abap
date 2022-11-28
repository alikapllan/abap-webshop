CLASS zcl_ali_homescreen_order_view DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS: order_overview_pai ,
      order_overview_pbo ,
      constructor
        IMPORTING
          !io_home_screen_cntrl TYPE REF TO zcl_ali_homescreen_cntrl ,
      call_order_overview  RAISING
                             zcx_ali_webshop_exception_new .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mo_home_screen_cntrl TYPE REF TO zcl_ali_homescreen_cntrl .
ENDCLASS.



CLASS zcl_ali_homescreen_order_view IMPLEMENTATION.


  METHOD call_order_overview.
    TRY.
        CALL FUNCTION 'ZALI_ORDER_OVERVIEW'
          EXPORTING
            io_overview_view = me.
      CATCH cx_root .
        RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new.
    ENDTRY.
  ENDMETHOD.


  METHOD constructor.

    mo_home_screen_cntrl = io_home_screen_cntrl.

  ENDMETHOD.


  METHOD order_overview_pai.

    CASE sy-ucomm.

      WHEN 'BACK'.
        LEAVE TO SCREEN 0.
      WHEN 'LEAVE'.
        LEAVE PROGRAM.
    ENDCASE.


  ENDMETHOD.


  METHOD order_overview_pbo.

    me->mo_home_screen_cntrl->on_pbo_order_overview( ).

  ENDMETHOD.
ENDCLASS.
