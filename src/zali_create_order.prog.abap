*&---------------------------------------------------------------------*
*& Report ZALI_CREATE_ORDER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zali_create_order.

PARAMETERS: p_artnum TYPE zali_article_number MATCHCODE OBJECT zali_sh_article OBLIGATORY,
            p_kundid TYPE zali_kd_numr_de MATCHCODE OBJECT zali_sh_customer OBLIGATORY,
            p_amount TYPE zali_order_amount  OBLIGATORY,
            p_bmeins TYPE zali_unit  OBLIGATORY.

CONSTANTS: lc_range_nr       TYPE  nrnr  VALUE '01',
           lc_status_ordered TYPE string VALUE 'BESTELLT',
           lc_status_cart    TYPE string VALUE 'Im Warenkorb'.
DATA: lo_alv          TYPE REF TO   cl_salv_table
      ,ls_order       TYPE          zali_order
      ,lv_bnumber_int TYPE          i
      ,lv_bnumber_chr TYPE          zali_order_number
      ,lt_cart        TYPE TABLE OF zali_order
      ,lo_columns     TYPE REF TO cl_salv_columns_table
      ,lo_column      TYPE REF TO cl_salv_column
      ,lv_posnum      TYPE zali_position_number VALUE 0.

FIELD-SYMBOLS <fs_cart> TYPE zali_order.


SELECTION-SCREEN BEGIN OF BLOCK b1.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (33) FOR FIELD p_amount.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN:
  PUSHBUTTON /2(20) button1 USER-COMMAND add_to_cart , "Zum Warenkorb hinzufügen"
  PUSHBUTTON /2(20) button2 USER-COMMAND order, "Bestellung aufgeben"
  PUSHBUTTON /2(20) button3 USER-COMMAND show. "Bestellung anzeigen"

SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  button1 = TEXT-b01.
  button2 = TEXT-b02.
  button3 = TEXT-b03.

AT SELECTION-SCREEN.
  CASE sy-ucomm.
    WHEN 'ADD_TO_CART'.

      CLEAR ls_order.

      ls_order-status          = lc_status_cart.
      ls_order-customer_number = p_kundid.
      ls_order-article         = p_artnum.
      ls_order-order_amount    = p_amount.
      ls_order-unit            = p_bmeins.

*        IF lt_cart IS INITIAL.
*          ls_order-position_number = lv_posnum.
*        ELSE.
*            LOOP AT lt_cart INTO ls_order2.
*                lv_posnum = sy-tabix.
*            ENDLOOP.
*            ls_order-position_number = lv_posnum.
*        ENDIF.
      "stattdessen kann man LINES nutzen
      ls_order-position_number = lines( lt_cart ).

      APPEND ls_order TO lt_cart.
*
*      ls_order = VALUE #( status = lc_status_cart
*                          customer_number = p_kundid ).


*      APPEND VALUE zali_order( status = lc_status_cart ) TO lt_car.

      IF sy-subrc = 0.
        MESSAGE i014(zali_web_shop) WITH p_artnum.
      ELSE.
        MESSAGE i012(zali_web_shop) DISPLAY LIKE 'E'.
      ENDIF.

    WHEN 'ORDER'.

      IF lt_cart IS INITIAL.
        MESSAGE i018(zali_web_shop) DISPLAY LIKE 'E'.
      ELSE.
        CALL FUNCTION 'NUMBER_GET_NEXT'
          EXPORTING
            nr_range_nr = lc_range_nr
            object      = 'ZALI_ART'
          IMPORTING
            number      = lv_bnumber_int
          EXCEPTIONS
            OTHERS      = 1.
        IF sy-subrc <> 0.
          MESSAGE e001(zali_web_shop).
        ENDIF.
        lv_bnumber_chr = lv_bnumber_int.

        "Ich will Spaltendaten(order number und status) aller Zeilen der lt_card ändern. Wie ??
        CLEAR ls_order.

        LOOP AT lt_cart INTO ls_order.
          ls_order-order_number = lv_bnumber_chr.
          ls_order-status = lc_status_ordered.
          ""
          MODIFY lt_cart FROM ls_order.
        ENDLOOP.

        INSERT zali_order FROM TABLE lt_cart.
        IF sy-subrc <> 0.
          MESSAGE i009(zali_web_shop) DISPLAY LIKE 'E'.
        ELSE.
          MESSAGE i010(zali_web_shop) DISPLAY LIKE 'S'.
          "Nach dem Bestellen, Warenkorb leeren
          CLEAR lt_cart.
        ENDIF.

      ENDIF.

    WHEN 'SHOW'.

      IF lt_cart IS INITIAL.
        MESSAGE i011(zali_web_shop) DISPLAY LIKE 'E'.
      ELSE.
        cl_salv_table=>factory(
        IMPORTING
            r_salv_table = lo_alv
        CHANGING
            t_table = lt_cart
        ).
        lo_alv->display(  ).
      ENDIF.

  ENDCASE.
