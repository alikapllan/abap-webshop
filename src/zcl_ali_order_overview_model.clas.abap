  CLASS zcl_ali_order_overview_model DEFINITION
    PUBLIC
    FINAL
    CREATE PUBLIC.

    PUBLIC SECTION.

      TYPES: t_table  TYPE STANDARD TABLE OF zali_order WITH DEFAULT KEY,
             tty_view TYPE STANDARD TABLE OF zali_s_order WITH DEFAULT KEY.
      DATA:  mt_order_view TYPE tty_view .
      CONSTANTS: lc_no_filter       TYPE string VALUE 'Alle',
                 lc_customer_number TYPE string VALUE 'Kundnnummer',
                 lc_order_number    TYPE string VALUE 'Bestellnummer',
                 lc_status          TYPE string VALUE 'Bestellstatus'.

      METHODS: constructor IMPORTING io_log TYPE REF TO zcl_ali_webshop_log,
        delete_position IMPORTING is_position TYPE zali_order
                        RAISING   zcx_ali_webshop_exception_new,
        edit_postition  IMPORTING iv_wert     TYPE any
                                  is_position TYPE zali_order
                        RAISING   zcx_ali_webshop_exception_new,
        delete_order    IMPORTING iv_order_number TYPE zali_order_number
                        RAISING   zcx_ali_webshop_exception_new,
        get_orders      RETURNING VALUE(rt_orders) TYPE t_table,
        get_information IMPORTING VALUE(iv_filter)          TYPE i OPTIONAL
                                  VALUE(iv_customer_number) TYPE zali_kd_numr_de OPTIONAL
                                  VALUE(iv_order_number)    TYPE zali_order_number OPTIONAL
                                  VALUE(iv_status)          TYPE zali_status OPTIONAL
                        RAISING   zcx_ali_webshop_exception_new,
        select_with_condition  IMPORTING iv_condition             TYPE any OPTIONAL
                                         iv_condition_description TYPE string
                               RAISING   zcx_ali_webshop_exception_new,
        get_positions   IMPORTING iv_order_number TYPE zali_order_number,
        get_positions_output RETURNING VALUE(rt_positions) TYPE t_table,
        get_order_overview   RETURNING VALUE(rt_orders) TYPE tty_view
                             RAISING   zcx_ali_webshop_exception_new,
        get_view RETURNING VALUE(rt_view) TYPE tty_view.

    PROTECTED SECTION.
    PRIVATE SECTION.
      DATA: mt_orders    TYPE t_table,
            mt_positions TYPE t_table,
            mo_log       TYPE REF TO zcl_ali_webshop_log.
      METHODS: change_structur_from_value IMPORTING iv_wert     TYPE any
                                          CHANGING  cs_position TYPE zali_order
                                          RAISING   zcx_ali_webshop_exception_new,
        add_to_view   IMPORTING is_order       TYPE zali_order
                                iv_total_price TYPE p
                      CHANGING  cs_view        TYPE zali_s_order,
        get_article_price_table RETURNING VALUE(rt_artikel_preis) TYPE ltt_artikel_price
                                RAISING   zcx_ali_webshop_exception_new.
  ENDCLASS.



  CLASS zcl_ali_order_overview_model IMPLEMENTATION.


    METHOD add_to_view.
      cs_view-order_number = is_order-order_number.
      cs_view-order_value = iv_total_price.
      cs_view-currency = '€'.
      cs_view-status = is_order-status.
      cs_view-customer_number = is_order-customer_number.
    ENDMETHOD.


    METHOD change_structur_from_value.

    ENDMETHOD.


    METHOD constructor.

      me->mo_log = io_log.

    ENDMETHOD.


    METHOD delete_order.
      DELETE FROM zali_order WHERE order_number = iv_order_number.

      IF sy-subrc <> 0.
        MESSAGE e033(zali_web_shop) INTO DATA(lv_message).
        me->mo_log->add_msg_from_sys( ).
        me->mo_log->safe_log( ).
        RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
      ENDIF.
    ENDMETHOD.


    METHOD delete_position.
      DELETE FROM zali_order WHERE order_number = is_position-order_number AND position_number = is_position-position_number.

      IF sy-subrc <> 0.
        MESSAGE e035(zali_web_shop) INTO DATA(lv_message).
        me->mo_log->add_msg_from_sys( ).
        me->mo_log->safe_log( ).
        RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
      ENDIF.
    ENDMETHOD.


    METHOD edit_postition.
      DATA(ls_position) = is_position.
      DATA(lv_column_type) = cl_abap_typedescr=>describe_by_data( iv_wert )->absolute_name.
      DATA(lv_rest_strlen) = strlen( lv_column_type ) - 6.
      DATA(lt_ddic) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( ls_position ) )->get_ddic_object( ).

      ASSIGN COMPONENT lt_ddic[ rollname = lv_column_type+6(lv_rest_strlen) ]-fieldname OF STRUCTURE ls_position TO FIELD-SYMBOL(<ls_position>).
      IF <ls_position> IS ASSIGNED.
        <ls_position> = iv_wert.
      ELSE.
        MESSAGE i035(zali_web_shop) INTO DATA(ls_msg).
        RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
      ENDIF.

      UPDATE zali_order FROM ls_position.

      IF sy-subrc NE 0.
        ROLLBACK WORK.
        MESSAGE i035(zali_web_shop) INTO ls_msg.
        RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
      ELSE.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDMETHOD.


    METHOD get_article_price_table.
      SELECT article_number , price
        FROM zali_article
        INTO TABLE @rt_artikel_preis.

      IF sy-subrc <> 0.
        MESSAGE e081(zali_web_shop) INTO DATA(lv_msg).
        me->mo_log->add_msg_from_sys( ).
        me->mo_log->safe_log( ).
        RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
      ENDIF.

    ENDMETHOD.


    METHOD get_information.

      CLEAR mt_orders.
      TRY.
          IF iv_filter EQ 0.
            select_with_condition( iv_condition_description = lc_no_filter ).
          ELSEIF iv_filter EQ 1 AND iv_customer_number IS NOT INITIAL.
            select_with_condition( iv_condition_description = lc_customer_number iv_condition = iv_customer_number ).
          ELSEIF iv_filter EQ 2 AND iv_order_number IS NOT INITIAL.
            select_with_condition( iv_condition_description = lc_order_number iv_condition = iv_order_number ).
          ELSEIF iv_filter EQ 3 AND iv_status IS NOT INITIAL.
            select_with_condition( iv_condition_description = lc_status iv_condition = iv_status ).
          ELSE.

          ENDIF.
        CATCH zcx_ali_webshop_exception_new.
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new.
      ENDTRY.

    ENDMETHOD.


    METHOD get_orders.

      rt_orders = me->mt_orders.

    ENDMETHOD.


    METHOD get_order_overview.

      DATA: lt_orders        TYPE TABLE OF zali_order,
            ls_orders        TYPE          zali_order,
            ls_zwischen      TYPE          zali_order,
            lv_price_article TYPE          zali_price,
            lv_total_price   TYPE          p,
            lt_view          TYPE TABLE OF zali_s_order,
            ls_view          TYPE          zali_s_order,
            lv_counter       TYPE          i.

      lt_orders = me->mt_orders.

      DATA(lt_article_price) = me->get_article_price_table(  ).

      LOOP AT lt_orders INTO ls_zwischen.
        lv_price_article = lt_article_price[ artikel_number = ls_zwischen-article ]-artikel_price.
        IF ls_orders-order_number = ls_zwischen-order_number.
          lv_total_price = lv_price_article * ls_zwischen-order_amount + lv_total_price.
          "Sobald eine neue Bestellung beginnt bisherige Bestellung in Tabelle
        ELSEIF ls_orders IS  NOT INITIAL AND ls_orders-order_number <> ls_zwischen-order_number.
          me->add_to_view( EXPORTING is_order       = ls_orders
                                     iv_total_price = lv_total_price
                           CHANGING  cs_view        = ls_view ).
          APPEND ls_view TO lt_view.
          CLEAR ls_view.
          lv_total_price = lv_price_article * ls_zwischen-order_amount.
        ELSE.
          CLEAR lv_total_price.
          lv_total_price = lv_price_article * ls_zwischen-order_amount.
        ENDIF.

        "Datenüberschreiben für Vergleich bei mehreren Loops über Bestellung
        ls_orders = ls_zwischen.
        lv_counter = lv_counter + 1.
      ENDLOOP.

      me->add_to_view( EXPORTING is_order       = ls_orders
                                 iv_total_price = lv_total_price
                       CHANGING cs_view         = ls_view ).

      APPEND ls_view TO lt_view.
      CLEAR ls_view.
      mt_order_view = lt_view.

    ENDMETHOD.


    METHOD get_positions.
      CLEAR me->mt_positions.

      SELECT *
        FROM zali_order
        INTO TABLE mt_positions
        WHERE order_number = iv_order_number.

    ENDMETHOD.


    METHOD get_positions_output.

      rt_positions = me->mt_positions.

    ENDMETHOD.


    METHOD get_view.

      rt_view = me->mt_order_view.

    ENDMETHOD.


    METHOD select_with_condition.
      CASE iv_condition_description.

        WHEN lc_no_filter.
          SELECT * FROM zali_order
            INTO TABLE me->mt_orders.

        WHEN lc_customer_number.
          SELECT * FROM zali_order
              INTO TABLE me->mt_orders
               WHERE customer_number = iv_condition.

          IF sy-subrc = 4.
            MESSAGE i018(zali_web_shop) INTO DATA(lv_message).
            RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
          ELSEIF sy-subrc <> 0.
            MESSAGE e016(zali_web_shop) INTO lv_message.
            RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
          ELSEIF me->mt_orders IS INITIAL.
            MESSAGE e025(zali_web_shop) INTO lv_message.
            RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
          ENDIF.


        WHEN lc_order_number.
          SELECT * FROM zali_order
              INTO TABLE me->mt_orders
              WHERE order_number = iv_condition.

          IF sy-subrc = 4.
            MESSAGE i084(zali_web_shop) INTO lv_message.
            RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
          ELSEIF sy-subrc <> 0.
            MESSAGE e015(zali_web_shop) INTO lv_message.
            RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
          ENDIF.


        WHEN lc_status.
          SELECT * FROM zali_order
            INTO TABLE me->mt_orders
            WHERE status = iv_condition .

          IF sy-subrc = 4.
            MESSAGE i085(zali_web_shop) INTO lv_message.
            RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
          ELSEIF sy-subrc <>  0.
            MESSAGE e017(zali_web_shop) INTO lv_message.
            RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
          ENDIF.


      ENDCASE.
    ENDMETHOD.
  ENDCLASS.
