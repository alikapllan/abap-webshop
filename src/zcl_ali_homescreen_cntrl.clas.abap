CLASS zcl_ali_homescreen_cntrl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC

  GLOBAL FRIENDS zcl_ali_customer_login_cntrl .

  PUBLIC SECTION.

    CONSTANTS lc_max_number_of_product TYPE i VALUE 50 ##NO_TEXT.
    DATA: mo_login_cntrl      TYPE REF TO zcl_ali_customer_login_cntrl,
          mo_home_screen_view TYPE REF TO zcl_ali_homescreen_view,
          mt_order_to_show    TYPE zali_tt_order,
          mo_log              TYPE REF TO zcl_ali_webshop_log.

    METHODS: add_buttons_show_position
        FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING
        !e_object ,
      create_tree ,
      on_overview ,
      on_reset_search ,
      get_quantity
        RETURNING
                  VALUE(rv_quantity) TYPE zali_order_amount
        RAISING   zcx_ali_webshop_exception_new,
      on_order
        RAISING zcx_ali_webshop_exception_new ,
      on_edit_quantity ,
      on_remove_item_from_cart ,
      on_show_cart ,
      on_pbo_home_screen ,
      on_add_product_to_cart ,
      search_selected_product
        RETURNING
          VALUE(rs_selected_product) TYPE zali_article ,
      on_pbo_cart ,
      on_back ,
      on_leave
        RAISING zcx_ali_webshop_exception_new ,
      on_back_to_login
        RAISING zcx_ali_webshop_exception_new,
      on_search_entries_in_table
        IMPORTING
          !iv_search_string TYPE string ,
      on_confirm_address
        IMPORTING
          !is_order_address TYPE zali_s_adress ,
      send_order_confirmation
        IMPORTING
          !iv_email        TYPE adr6-smtp_addr
          !iv_order_number TYPE numc10 ,
      on_pbo_order_overview ,
      constructor
        IMPORTING
          !io_login_cntrl TYPE REF TO zcl_ali_customer_login_cntrl
          !iv_customer_number  TYPE zali_customer_number
          !iv_email            TYPE zali_email
          !io_log              TYPE REF TO zcl_ali_webshop_log.
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      tty_item TYPE TABLE OF mtreeitm .

    CONSTANTS:
      BEGIN OF lcs_nodekey,
        orders        TYPE tv_nodekey VALUE 'Bestellungen',
        open_orders   TYPE tv_nodekey VALUE 'open_orders',
        closed_orders TYPE tv_nodekey VALUE 'done_orders',
      END OF lcs_nodekey ,
      mc_open        TYPE tv_nodekey VALUE 'Offen' ##NO_TEXT,
      mc_orders_text TYPE c LENGTH 12 VALUE 'Bestellungen' ##NO_TEXT,
      mc_done        TYPE tv_nodekey VALUE 'Erledigt' ##NO_TEXT.

    DATA:
      mo_home_screen_model          TYPE REF TO zcl_ali_homescreen_model,
      mo_alv_grid_home_screen       TYPE REF TO cl_gui_alv_grid,
      mo_container_home_screen      TYPE REF TO cl_gui_custom_container,
      mo_alv_grid_cart              TYPE REF TO cl_gui_alv_grid,
      mo_container_cart             TYPE REF TO cl_gui_custom_container,
      mo_cart_view                  TYPE REF TO zcl_ali_cart_view,
      mv_quantity                   TYPE zali_order_amount,
      mo_container_logo_home_screen TYPE REF TO cl_gui_custom_container,
      mo_logo_home_screen           TYPE REF TO cl_gui_picture,
      mo_address_view               TYPE REF TO zcl_ali_alternativ_adress,
      mo_order_overview_view        TYPE REF TO zcl_ali_homescreen_order_view,
      mo_container_tree             TYPE REF TO cl_gui_custom_container,
      mo_tree                       TYPE REF TO cl_gui_list_tree,
      mt_orders_for_tree            TYPE zali_tt_order,
      mo_container_show_position    TYPE REF TO cl_gui_custom_container,
      mo_alv_grid_show_position     TYPE REF TO cl_gui_alv_grid,
      mt_article                    TYPE TABLE OF zali_article,
      mo_alv_grid_article           TYPE REF TO cl_gui_alv_grid,
      mo_custom_container_article   TYPE REF TO cl_gui_custom_container.

    METHODS:
      show_company_logo_on_home_sc ,
      create_alv_for_home_screen ,
      start ,
      on_double_click_add_product
        FOR EVENT double_click OF cl_gui_alv_grid ,
      create_alv_for_cart ,
      search_selected_item_in_cart
        RETURNING
          VALUE(rs_selected_item) TYPE zali_s_cart ,
      on_double_click_edit_quantity
        FOR EVENT double_click OF cl_gui_alv_grid ,
      add_btn_to_toolbar_add_to_cart
          FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING
          !e_object ,
      on_toolbar_btn_add_to_cart
          FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING
          !e_ucomm ,
      add_btn_to_toolbar_edit_quan
          FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING
          !e_object
          !e_interactive ,
      on_toolbar_btn_edit_quan
          FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING
          !e_ucomm ,
      generate_html_text_for_email
        RETURNING
          VALUE(rt_html_text_table) TYPE soli_tab ,
      show_order
        IMPORTING
                  !it_order TYPE zali_tt_order
        RAISING   zcx_ali_webshop_exception_new ,
      show_article ,
      build_node_and_item_table
        EXPORTING
          !et_node TYPE treev_ntab
          !et_item TYPE tty_item ,
      on_cancel_position ,
      delete_node_and_items
        IMPORTING
          !is_position TYPE zali_order ,
      edit_quantity_order_position ,
      on_buttons_show_position
          FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING
          !e_ucomm ,
      on_double_click_position
        FOR EVENT double_click OF cl_gui_alv_grid ,
      handle_double_click
          FOR EVENT item_double_click OF cl_gui_list_tree
        IMPORTING
          !node_key
          !item_name .
ENDCLASS.



CLASS ZCL_ALI_HOMESCREEN_CNTRL IMPLEMENTATION.


  METHOD add_btn_to_toolbar_add_to_cart.

    DATA ls_button TYPE stb_button.
    CONSTANTS: lc_function_code TYPE char70 VALUE 'ADD',
               lc_quickinfo     TYPE char30 VALUE 'Add to cart',
               lc_disabled      TYPE char1  VALUE ' ',
               lc_button_text   TYPE char40 VALUE 'Zum Warenkorb Hinzufügen'.

    "Einfügen eines Seperators (Senkrechter Strich) zum Absetzen von anderen Butalis
    CLEAR ls_button.
    ls_button-butn_type = 3. "Seperator
    APPEND ls_button TO e_object->mt_toolbar.

    "Einfügen des Butalis
    CLEAR ls_button.

    ls_button = VALUE stb_button(  function = lc_function_code
                                       icon = icon_checked
                                  quickinfo = lc_quickinfo
                                   disabled = lc_disabled
                                       text = lc_button_text ).
    "Hinzufügen des Butalis zur Toolbar
    APPEND ls_button TO e_object->mt_toolbar.

  ENDMETHOD.


  METHOD add_btn_to_toolbar_edit_quan.

    DATA ls_button TYPE stb_button.
    CONSTANTS: lc_function_code TYPE char70 VALUE 'EDIT',
               lc_quickinfo     TYPE char30 VALUE 'Edit Quantity',
               lc_disabled      TYPE char1  VALUE ' ',
               lc_button_text   TYPE char40 VALUE 'Menge Bearbeiten'.

    "Einfügen eines Seperators (Senkrechter Strich) zum Absetzen von anderen Butalis
    CLEAR ls_button.
    ls_button-butn_type = 3. "Seperator
    APPEND ls_button TO e_object->mt_toolbar.

    "Einfügen des Butalis
    CLEAR ls_button.

    ls_button = VALUE stb_button(  function = lc_function_code
                                       icon = icon_checked
                                  quickinfo = lc_quickinfo
                                   disabled = lc_disabled
                                       text = lc_button_text ).
    "Hinzufügen des Butalis zur Toolbar
    APPEND ls_button TO e_object->mt_toolbar.

  ENDMETHOD.


  METHOD add_buttons_show_position.

    DATA: lt_buttons TYPE TABLE OF stb_button.

    CONSTANTS: lc_function_code_ca TYPE char70 VALUE 'CANCEL'           ##no_text,
               lc_quickinfo_ca     TYPE char30 VALUE 'Position Canceln' ##no_text,
               lc_button_text_ca   TYPE char40 VALUE 'Position Canceln' ##no_text,
               lc_function_code_ed TYPE char70 VALUE 'EDIT'             ##no_text,
               lc_quickinfo_ed     TYPE char30 VALUE 'Menge bearbeiten' ##no_text,
               lc_button_text_ed   TYPE char40 VALUE 'Menge bearbeiten' ##no_text.

    "Butali Cancel Position
    lt_buttons = VALUE #( ( butn_type  = 3 ) "Seperator
                         ( function   = lc_function_code_ca
                           icon       = icon_cancel
                           quickinfo  = lc_quickinfo_ca
                           disabled   = abap_false
                           text       = lc_button_text_ca ) ).

    "Butali Edit Quantity
    lt_buttons = VALUE #( BASE lt_buttons
                         ( butn_type  = 3 ) "Seperator
                         ( function   = lc_function_code_ed
                           icon       = icon_edit_file
                           quickinfo  = lc_quickinfo_ed
                           disabled   = abap_false
                           text       = lc_button_text_ed ) ).

    APPEND LINES OF lt_buttons TO e_object->mt_toolbar.

  ENDMETHOD.


  METHOD build_node_and_item_table.

    "node and item orders
    et_node = VALUE #( BASE et_node ( node_key = lcs_nodekey-orders
                                            hidden   = abap_false
                                            disabled = abap_false
                                            isfolder = abap_true ) ).

    et_item = VALUE #( BASE et_item ( node_key    = lcs_nodekey-orders
                                            item_name   = '1'
                                            class       = cl_gui_list_tree=>item_class_text
                                            alignment   = cl_gui_list_tree=>align_auto
                                            font        = cl_gui_list_tree=>item_font_prop
                                            text        = mc_orders_text ) ).

    "node and item open orders
    et_node = VALUE #( BASE et_node ( node_key    = lcs_nodekey-open_orders
                                            relatkey    = lcs_nodekey-orders
                                            relatship   = cl_gui_list_tree=>relat_last_child
                                            expander    = abap_true
                                            isfolder    = abap_true ) ).

    et_item = VALUE #( BASE et_item ( node_key    = lcs_nodekey-open_orders
                                            item_name   = '2'
                                            class       = cl_gui_list_tree=>item_class_text
                                            alignment   = cl_gui_list_tree=>align_auto
                                            font        = cl_gui_list_tree=>item_font_prop
                                            text        = mc_open ) ).

    "node and item closed orders
    et_node = VALUE #( BASE et_node ( node_key  = lcs_nodekey-closed_orders
                                            relatkey  = lcs_nodekey-orders
                                            relatship = cl_gui_list_tree=>relat_last_child
                                            expander  = abap_true
                                            isfolder  = abap_true ) ).

    et_item = VALUE #( BASE et_item ( node_key  = lcs_nodekey-closed_orders
                                            item_name = '2'
                                            class     = cl_gui_list_tree=>item_class_text
                                            alignment = cl_gui_list_tree=>align_auto
                                            font      = cl_gui_list_tree=>item_font_prop
                                            text      = mc_done ) ).

    "Show Open orders
    LOOP AT me->mo_home_screen_model->get_open_order_from_mt_order( ) ASSIGNING FIELD-SYMBOL(<ls_open_order>).

      et_node = VALUE #( BASE et_node ( node_key  = <ls_open_order>-order_number
                                        relatkey  = lcs_nodekey-open_orders
                                        relatship = cl_gui_list_tree=>relat_first_child
                                        expander  = abap_false
                                        isfolder  = abap_false ) ).

      et_item = VALUE #( BASE et_item ( node_key  = <ls_open_order>-order_number
                                        item_name = '3'
                                        class     = cl_gui_list_tree=>item_class_text
                                        alignment = cl_gui_list_tree=>align_auto
                                        font      = cl_gui_list_tree=>item_font_prop
                                        text      = <ls_open_order>-order_number ) ).

    ENDLOOP.

    "Show closed orders
    LOOP AT me->mo_home_screen_model->get_done_order_from_mt_order(  ) ASSIGNING FIELD-SYMBOL(<ls_closed_order>).

      et_node = VALUE #( BASE et_node ( node_key  = <ls_closed_order>-order_number
                                        relatkey  = lcs_nodekey-closed_orders
                                        relatship = cl_gui_list_tree=>relat_first_child
                                        expander  = abap_false
                                        isfolder  = abap_false ) ).

      et_item = VALUE #( BASE et_item ( node_key = <ls_closed_order>-order_number
                                             item_name = '3'
                                             class     = cl_gui_list_tree=>item_class_text
                                             alignment = cl_gui_list_tree=>align_auto
                                             font = cl_gui_list_tree=>item_font_prop
                                             text =  <ls_closed_order>-order_number ) ).

    ENDLOOP.

  ENDMETHOD.


  METHOD constructor.

    me->mo_login_cntrl = io_login_cntrl.

    IF me->mo_home_screen_view IS NOT BOUND.
      me->mo_home_screen_view = NEW #( io_home_screen_cntrl = me ).
    ENDIF.

    IF me->mo_home_screen_model IS NOT BOUND.
      me->mo_home_screen_model = NEW #( io_home_screen_cntrl =  me
                                        iv_customer_number        = iv_customer_number
                                        io_log = mo_log ).
    ENDIF.

    me->mo_home_screen_model->set_customer_email( iv_email = iv_email ).

  ENDMETHOD.


  METHOD create_alv_for_cart.


    TRY.
        IF me->mo_container_cart IS INITIAL.
          me->mo_container_cart = NEW cl_gui_custom_container( container_name = 'C_CONTAINER'
                                                                repid         = 'SAPLZALI_HOME_SCREEN'
                                                                dynnr         = '9001').
        ENDIF.

        IF me->mo_container_cart IS BOUND AND me->mo_alv_grid_cart IS INITIAL.
          me->mo_alv_grid_cart = NEW cl_gui_alv_grid( i_parent = me->mo_container_cart ).
        ENDIF.

        me->mo_alv_grid_cart->set_table_for_first_display( EXPORTING  i_structure_name = 'ZALI_S_CART'
                                                           CHANGING   it_outtab        = me->mo_home_screen_model->mt_cart
                                                           EXCEPTIONS invalid_parameter_combination = 1   " Parameter falsch
                                                                      program_error                 = 2   " Programmfehler
                                                                      too_many_lines                = 3   " Zu viele Zeilen in eingabebereitem Grid.
                                                                      OTHERS                        = 4 ).

        IF sy-subrc <> 0.
          MESSAGE i052(zali_web_shop) WITH sy-subrc INTO DATA(ls_msg).
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
        ENDIF.

        SET HANDLER me->on_double_click_edit_quantity
                    me->add_btn_to_toolbar_edit_quan
                    me->on_toolbar_btn_edit_quan
        FOR me->mo_alv_grid_cart.

        me->mo_alv_grid_cart->set_toolbar_interactive( ).

      CATCH zcx_ali_webshop_exception_new INTO DATA(lo_exc).
        MESSAGE lo_exc.

    ENDTRY.

  ENDMETHOD.


  METHOD create_alv_for_home_screen.



    TRY.
        IF me->mo_container_home_screen IS INITIAL.
          me->mo_container_home_screen = NEW cl_gui_custom_container(  container_name          = 'C_CONTAINER'
                                                                       repid                   = 'SAPLZALI_HOME_SCREEN'
                                                                       dynnr                   = '9000' ).
        ENDIF.

        IF me->mo_container_home_screen IS BOUND AND me->mo_alv_grid_home_screen IS NOT BOUND.
          me->mo_home_screen_model->mt_articles_out = me->mo_home_screen_model->mt_articles.
          me->mo_alv_grid_home_screen = NEW cl_gui_alv_grid( i_parent = mo_container_home_screen ).
          me->mo_alv_grid_home_screen->set_table_for_first_display( EXPORTING i_structure_name = 'ZALI_ARTICLE'
                                                                    CHANGING  it_outtab        =   me->mo_home_screen_model->mt_articles_out
                                                                    EXCEPTIONS invalid_parameter_combination = 1   " Parameter falsch
                                                                               program_error                 = 2   " Programmfehler
                                                                               too_many_lines                = 3   " Zu viele Zeilen in eingabebereitem Grid.
                                                                               OTHERS                        = 4  ).

          IF sy-subrc <> 0.
            MESSAGE i053(zali_web_shop) WITH sy-subrc INTO DATA(ls_msg).
            me->mo_log->add_msg_from_sys( ).
            me->mo_log->safe_log( ).
            RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
          ENDIF.

        ENDIF.

        SET HANDLER me->add_btn_to_toolbar_add_to_cart
                    me->on_toolbar_btn_add_to_cart
                    me->on_double_click_add_product
                     FOR me->mo_alv_grid_home_screen.

        me->mo_alv_grid_home_screen->set_toolbar_interactive( ).

      CATCH zcx_ali_webshop_exception_new INTO DATA(lo_exc).
        MESSAGE lo_exc.
    ENDTRY.

  ENDMETHOD.


  METHOD create_tree.

    DATA: ls_event       TYPE          cntl_simple_event,
          lt_events      TYPE          cntl_simple_events,
          node_table     TYPE          treev_ntab,
          item_table     TYPE TABLE OF mtreeitm,
          lt_node_update TYPE          treev_upno.

    TRY.

        IF mo_tree IS NOT BOUND  AND mo_container_tree IS NOT BOUND.

          mo_container_tree = NEW cl_gui_custom_container( container_name = 'C_TREE_CONTROL'
                                                           repid          = 'SAPLZALI_HOME_SCREEN'
                                                           dynnr          = '9003' ).

          mo_tree = NEW #( parent              = mo_container_tree
                           node_selection_mode = cl_gui_list_tree=>node_sel_mode_single
                           item_selection      = abap_true
                           with_headers        = abap_false ).

          me->mo_home_screen_model->get_all_orders_from_customer( ).
*    "define the events which will be passed to the backend
*    " item double click
          lt_events = VALUE #( ( eventid    = cl_gui_list_tree=>eventid_item_double_click
                                 appl_event = abap_true )
                               ( eventid    = cl_gui_list_tree=>eventid_item_context_menu_req
                                 appl_event = abap_true )
                               ( eventid    = cl_gui_list_tree=>eventid_header_context_men_req
                                 appl_event = abap_true )
                               ( eventid    = cl_gui_list_tree=>eventid_def_context_menu_req
                                 appl_event = abap_true )
                                                  ).

          me->mo_tree->set_registered_events( events = lt_events ).

          "Set handler for the actions of mo_tree
*          SET HANDLER me->handle_node_context_menu_sel FOR me->mo_tree.
          SET HANDLER me->handle_double_click FOR me->mo_tree.


          CLEAR node_table.
          CLEAR item_table.


          me->build_node_and_item_table( IMPORTING et_node = node_table
                                                   et_item = item_table ).

          me->mo_tree->add_nodes_and_items( node_table                = node_table
                                            item_table                = item_table
                                            item_table_structure_name = 'MTREEITM' ).

        ELSE.
          "do nothing
        ENDIF.
      CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.

  ENDMETHOD.


  METHOD delete_node_and_items.

    me->mo_tree->delete_node( EXPORTING  node_key = CONV #( is_position-order_number ) " Node key
                              EXCEPTIONS failed            = 1                " General Error
                                         node_not_found    = 2                " Node With Key NODE_KEY Does Not Exist
                                         cntl_system_error = 3                " "
                                         OTHERS            = 4  ).
    IF sy-subrc <> 0.
      MESSAGE i062(zali_web_shop) WITH sy-subrc.
      me->mo_log->add_msg_from_sys( ).
      me->mo_log->safe_log( ).
    ENDIF.


  ENDMETHOD.


  METHOD edit_quantity_order_position.

    TRY.
        me->mo_alv_grid_show_position->get_selected_rows( IMPORTING et_index_rows = DATA(lt_index_row) ).

        IF lt_index_row IS INITIAL.
          MESSAGE i067(zali_web_shop) INTO DATA(lv_msg).
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
        ENDIF.
        "It's only possible to mark one row, so in lt_sel_rows there would be only one line
        DATA(ls_selected_row) = VALUE #( me->mt_order_to_show[ lt_index_row[ 1 ]-index ] ).

        "Call Pop Up for Quantity Entry
        DATA(lv_quantity) = me->get_quantity( ).

        IF lv_quantity IS INITIAL OR lv_quantity <= 0.
          MESSAGE i066(zali_web_shop) INTO lv_msg.
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
        ENDIF.

        me->mo_home_screen_model->edit_quantity_of_position( EXPORTING is_position = ls_selected_row
                                                                       iv_quantity = CONV #( lv_quantity ) ).

        "get new data and refresh alv grid
        me->mo_home_screen_model->get_all_orders_from_customer( ).
        me->show_order( it_order =  me->mo_home_screen_model->get_order( iv_order_number = CONV #( ls_selected_row-order_number ) ) ).
      CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.

  ENDMETHOD.


  METHOD generate_html_text_for_email.

    DATA: lv_html_text TYPE string.

    "standard email text
    lv_html_text = |<BODY> |                                    &&
                   |<P>Sehr geehrte*r Kunde*in <P>|             &&
                   |<P>Ihre Bestellung wurde erfolgreich aufgegeben und wird bei uns bearbeitet <P>| &&
                   |<P>Informationen zu ihrer Bestellung: <P>| &&
                   |<P>Bestellübersicht: <P>|.

    APPEND lv_html_text TO rt_html_text_table.

    "overview for all ordered products
    LOOP AT me->mo_home_screen_model->mt_cart  ASSIGNING FIELD-SYMBOL(<ls_position>).

      lv_html_text = |<P>| && | Artikel: | && |{ <ls_position>-article_designation }| &&
                     | Menge: | &&
                     |{ <ls_position>-number_of_articles }| &&
                     | Preis pro Artikel | &&
                     |{ <ls_position>-price_per_article }| && |<P>|.

      APPEND lv_html_text TO rt_html_text_table.

    ENDLOOP.

    DATA(ls_customer_address) = me->mo_home_screen_model->return_address( ).

    lv_html_text =  |<P>Lieferadresse:<p>| &&
                    |{ ls_customer_address-street   && | | && ls_customer_address-houese_number } </BR>| &&
                    |{ ls_customer_address-zip_code && | | && ls_customer_address-city } </BR> | &&
                    |<P>Bei Fragen können Sie gerne auf diese Email antworten. </BR> Wir bedanken uns bei Ihnen für ihre Bestellung!<P>| &&
                    |<P>Mit freundlichen Grüßen <P>|     &&
                    |<P>Ihr Web-Shop Team<P>|            &&
                    |</BODY>|.

    APPEND lv_html_text TO rt_html_text_table.

  ENDMETHOD.


  METHOD get_quantity.

    DATA: lt_sval   TYPE TABLE OF sval,
          ls_fields TYPE sval.

    ls_fields-tabname   = 'ZALI_ORDER'.
    ls_fields-fieldname = 'ORDER_AMOUNT'.
    ls_fields-field_obl = 'X'.
    APPEND ls_fields TO lt_sval.
    CLEAR ls_fields.

    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
        popup_title     = 'MENGENEINGABE'
        start_column    = '5'
        start_row       = '5'
      TABLES
        fields          = lt_sval
      EXCEPTIONS
        error_in_fields = 1
        OTHERS          = 2.

    IF sy-subrc <> 0.
      MESSAGE i045(zali_web_shop) INTO DATA(ls_msg).
      RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
    ENDIF.

    rv_quantity = lt_sval[ 1 ]-value.

  ENDMETHOD.


  METHOD handle_double_click.

    "
    CONSTANTS lc_item_order TYPE i VALUE 3.

    "Order have the item number 3
    IF item_name EQ lc_item_order.
      "Search the order in model->mt_order and show them in a custom control
      TRY.
          me->show_order( it_order =  me->mo_home_screen_model->get_order( iv_order_number = node_key ) ).
        CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
          MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD on_add_product_to_cart.

    TRY.
        DATA(lv_quantity) = me->get_quantity( ).
        DATA(ls_item) = me->search_selected_product( ).
        lv_quantity = me->mo_home_screen_model->add_up_item( EXPORTING iv_article_number = ls_item-article_number
                                              iv_quantity       = lv_quantity ).

        IF lv_quantity > 0 AND lv_quantity <= lc_max_number_of_product.
          me->mo_home_screen_model->add_to_cart( EXPORTING iv_number_of_articles = lv_quantity
                                                           is_article            = ls_item ).
        ELSEIF lv_quantity <= 0.
          MESSAGE i048(zali_web_shop) INTO DATA(ls_msg).
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.

        ELSEIF lv_quantity >= lc_max_number_of_product.
          MESSAGE i049(zali_web_shop) INTO ls_msg.
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
        ENDIF.

      CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.

  ENDMETHOD.


  METHOD on_back.

    LEAVE TO SCREEN 0.

  ENDMETHOD.


  METHOD on_back_to_login.

    CONSTANTS: lc_text    TYPE char90 VALUE 'Wollen Sie wirklich das Kundenportal verlassen? Ihr Warenkorb geht verloren!' ##no_text,
               lc_kind    TYPE char4  VALUE 'WARN'                                                                         ##no_text,
               lc_button1 TYPE char15 VALUE 'Ja'                                                                           ##no_text,
               lc_button2 TYPE char15 VALUE 'Nein'                                                                         ##no_text.
    TRY.
        DATA(lv_btn) = /auk/cl_msgbox=>show_msgbox( im_text    = lc_text
                                                    im_kind    = lc_kind
                                                    im_button1 = lc_button1
                                                    im_button2 = lc_button2 ).
      CATCH  /auk/cx_vc .
        RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new.
    ENDTRY.

    IF lv_btn = 1.
      MESSAGE i056(zali_web_shop).
      me->mo_log->add_msg_from_sys( ).
      me->mo_log->safe_log( ).
      FREE mo_login_cntrl.
      "start user login
      SUBMIT zali_customer_portal.

    ELSE.
      "do nothing
    ENDIF.

  ENDMETHOD.


  METHOD on_buttons_show_position.

    CASE e_ucomm.
      WHEN 'CANCEL'.
        me->on_cancel_position( ).
      WHEN 'EDIT'.
        me->edit_quantity_order_position(  ).
      WHEN OTHERS.
        "will not happen
    ENDCASE.

  ENDMETHOD.


  METHOD on_cancel_position.
    DATA: lv_exists TYPE boolean.

    TRY.
        me->mo_alv_grid_show_position->get_selected_rows( IMPORTING et_index_rows = DATA(lt_index_row) ).

        IF lt_index_row IS NOT INITIAL.
          "It's only possible to mark one row, so in lt_sel_rows there would be only one line
          DATA(ls_selected_row) = VALUE #( me->mt_order_to_show[ lt_index_row[ 1 ]-index ] ).
          me->mo_home_screen_model->delete_position( is_position = ls_selected_row ).

          lv_exists = me->mo_home_screen_model->check_if_order_exist( is_selected_row = ls_selected_row ).

          IF lv_exists EQ abap_false.
            "If our order is now empty we want to remove it from tree
            me->delete_node_and_items( is_position = ls_selected_row ).
          ENDIF.

          me->mo_home_screen_model->get_all_orders_from_customer( ).
          me->show_order( it_order = me->mo_home_screen_model->get_order( iv_order_number = CONV #( ls_selected_row-order_number ) ) ).

        ENDIF.

      CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.

  ENDMETHOD.


  METHOD on_confirm_address.
    TRY.
        me->mo_home_screen_model->set_order_address( is_order_address = is_order_address ).

        me->mo_home_screen_model->order_cart( ).

        LEAVE TO SCREEN 9000.
      CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.


  METHOD on_double_click_add_product.

    me->on_add_product_to_cart( ).

  ENDMETHOD.


  METHOD on_double_click_edit_quantity.

    me->on_edit_quantity( ).

  ENDMETHOD.


  METHOD on_double_click_position.

    DATA: lt_sel_rows TYPE lvc_t_row.

    CLEAR lt_sel_rows.
    me->mo_alv_grid_show_position->get_selected_rows( IMPORTING et_index_rows = lt_sel_rows ).

    IF lt_sel_rows IS NOT INITIAL.
      "It's only possible to mark one row, so in lt_sel_rows there would be only one line
      DATA(ls_selected_row) = VALUE #( me->mt_order_to_show[ lt_sel_rows[ 1 ]-index ] ).
    ENDIF.

    CLEAR me->mt_article.
    me->mt_article = VALUE #( ( me->mo_home_screen_model->mt_articles[ article_number = ls_selected_row-article ] ) ).

    me->show_article(  ).

  ENDMETHOD.


  METHOD on_edit_quantity.

    TRY.
        DATA(lv_quantity) = me->get_quantity( ).

        IF lv_quantity > 0 AND lv_quantity < lc_max_number_of_product.

          DATA ls_item_for_cart TYPE zali_article.
          DATA(ls_item) =  me->search_selected_item_in_cart( ).

          ls_item_for_cart = VALUE zali_article( article_number = ls_item-article_number
                                                 description  = ls_item-article_description
                                                 designation   = ls_item-article_designation
                                                 unit       = ls_item-unit
                                                 price         = ls_item-price_per_article
                                                 currency      = ls_item-currency ).

          me->mo_home_screen_model->remove_item_from_cart( iv_article_number = ls_item-article_number ).
          me->mo_home_screen_model->add_to_cart( EXPORTING  iv_number_of_articles =   lv_quantity
                                                            is_article            =   ls_item_for_cart ).

          me->mo_alv_grid_cart->refresh_table_display( ).

        ELSEIF lv_quantity <= 0.
          MESSAGE: i048(zali_web_shop) INTO DATA(ls_msg).
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
        ELSEIF lv_quantity > lc_max_number_of_product.
          MESSAGE i049(zali_web_shop) INTO ls_msg.
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
        ENDIF.

      CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.

    ENDTRY.

  ENDMETHOD.


  METHOD on_leave.

    CONSTANTS: lc_text    TYPE char90 VALUE 'Sind Sie sicher, dass Sie das Kundenportal verlassen wollen? Ihr Warenkorb geht verloren!' ##no_text,
               lc_kind    TYPE char4  VALUE 'WARN'                                                                                      ##no_text,
               lc_button1 TYPE char15 VALUE 'Ja'                                                                                        ##no_text,
               lc_button2 TYPE char15 VALUE 'Nein'                                                                                      ##no_text.
    TRY.
        DATA(lv_btn) = /auk/cl_msgbox=>show_msgbox( im_text    = lc_text
                                                    im_kind    = lc_kind
                                                    im_button1 = lc_button1
                                                    im_button2 = lc_button2 ).
      CATCH  /auk/cx_vc .
        RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new.
    ENDTRY.
    IF lv_btn = 1.
      LEAVE PROGRAM.
    ELSE.
      "do nothing
    ENDIF.


  ENDMETHOD.


  METHOD on_order.


    TRY.
        CONSTANTS: lc_text       TYPE char90 VALUE 'An welche Adresse soll geliefert werden?'  ##no_text,
                   lc_kind       TYPE char4  VALUE 'QUES'                                      ##no_text,
                   lc_button1    TYPE char15 VALUE 'Standard'                                  ##no_text,
                   lc_button2    TYPE char15 VALUE 'Alternativ'                                ##no_text,
                   lc_button3    TYPE char15 VALUE 'Abbrechen'                                 ##no_text,
                   lc_text_sc    TYPE char90 VALUE 'Bestellung wurde erfolgreich aufgegeben!'  ##no_text,
                   lc_kind_sc    TYPE char4  VALUE 'INFO'                                      ##no_text,
                   lc_button1_sc TYPE char15 VALUE 'OK'                                        ##no_text.

        DATA(lv_btn) = /auk/cl_msgbox=>show_msgbox( im_text    = lc_text
                                                    im_kind    = lc_kind
                                                    im_button1 = lc_button1
                                                    im_button2 = lc_button2
                                                    im_button3 = lc_button3 ).

        IF me->mo_home_screen_model->mt_cart IS NOT INITIAL.
          "User want to order
          IF lv_btn = 1.

            me->mo_home_screen_model->get_address_of_customer( ).
            me->mo_home_screen_model->order_cart( ).
            "if order has successfully placed, user receive a sucess message
            DATA(lv_button) = /auk/cl_msgbox=>show_msgbox( im_text    = lc_text_sc
                                                           im_kind    = lc_kind_sc
                                                           im_button1 = lc_button1_sc ).
            "Cart is initial->go back to home screen
            me->on_back( ).

          ELSEIF lv_btn = 2.
            IF me->mo_address_view IS NOT BOUND.
              me->mo_address_view = NEW #( io_home_screen_cntrl = me ).
            ENDIF.
            me->mo_address_view->call_dynpro_for_address( ).

          ELSE.
            "nothing happens
          ENDIF.

        ELSE.
          MESSAGE i050(zali_web_shop) INTO DATA(ls_msg).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
        ENDIF.
      CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
        me->on_back( ).
      CATCH  /auk/cx_vc .
        RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new.
    ENDTRY.


  ENDMETHOD.


  METHOD on_overview.

    IF me->mo_order_overview_view IS NOT BOUND.
      me->mo_order_overview_view = NEW #( io_home_screen_cntrl = me ).
    ENDIF.
    TRY.
        me->mo_order_overview_view->call_order_overview( ).
      CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.


  METHOD on_pbo_cart.

    me->create_alv_for_cart( ).

  ENDMETHOD.


  METHOD on_pbo_home_screen.

    me->create_alv_for_home_screen( ).
    me->show_company_logo_on_home_sc( ).

  ENDMETHOD.


  METHOD on_pbo_order_overview.

    me->create_tree( ).

  ENDMETHOD.


  METHOD on_remove_item_from_cart.

    TRY.
        me->mo_home_screen_model->remove_item_from_cart( iv_article_number = me->search_selected_item_in_cart( )-article_number ).
        IF me->mo_home_screen_model->mt_cart IS INITIAL.
          MESSAGE i051(zali_web_shop) INTO DATA(ls_msg).
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
        ENDIF.

        me->mo_alv_grid_cart->refresh_table_display( ).
        IF sy-subrc <> 0.
          MESSAGE i047(zali_web_shop) INTO ls_msg.
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new.
        ENDIF.

      CATCH zcx_ali_webshop_exception_new INTO DATA(lo_exc).
        MESSAGE  lo_exc.
        me->on_back( ).

    ENDTRY.

  ENDMETHOD.


  METHOD on_reset_search.

    "clear output table, hand over origin table and refres alv grid
    CLEAR me->mo_home_screen_model->mt_articles_out.

    me->mo_home_screen_model->mt_articles_out = me->mo_home_screen_model->mt_articles.
    me->mo_alv_grid_home_screen->refresh_table_display( ).

  ENDMETHOD.


  METHOD on_search_entries_in_table.

    me->mo_home_screen_model->search_entries_to_new_table( iv_search_string = iv_search_string ).
    me->mo_alv_grid_home_screen->refresh_table_display( ).


  ENDMETHOD.


  METHOD on_show_cart.

    CONSTANTS: lc_text    TYPE char90 VALUE 'Es sind keine Waren im Warenkorb vorhanden'     ##no_text,
               lc_kind    TYPE char4  VALUE 'INFO'                                           ##no_text,
               lc_button1 TYPE char15 VALUE 'OK'                                             ##no_text.

    IF me->mo_home_screen_model->mt_cart IS NOT INITIAL.

      IF mo_cart_view IS NOT BOUND.
        mo_cart_view = NEW zcl_ali_cart_view( io_cntrl = me ).
      ENDIF.

      me->mo_cart_view->call_screen_cart( ).

    ELSE.

      TRY.
          DATA(lv_btn) = /auk/cl_msgbox=>show_msgbox( im_text    = lc_text
                                                      im_kind    = lc_kind
                                                      im_button1 = lc_button1 ).
        CATCH /auk/cx_vc.
          "just a pop up to show informations so we don't need an extra handling here
      ENDTRY.

    ENDIF.

  ENDMETHOD.


  METHOD on_toolbar_btn_add_to_cart.

    CASE e_ucomm.
      WHEN 'ADD'.
        me->on_add_product_to_cart( ).
      WHEN OTHERS.
        "will not happen
    ENDCASE.

  ENDMETHOD.


  METHOD on_toolbar_btn_edit_quan.

    CASE e_ucomm.
      WHEN 'EDIT'.
        me->on_edit_quantity( ).
      WHEN OTHERS.
        "will not happend
    ENDCASE.

  ENDMETHOD.


  METHOD search_selected_item_in_cart.

    DATA: it_sel_row TYPE lvc_t_row.
    TRY.
        me->mo_alv_grid_cart->get_selected_rows( IMPORTING et_index_rows = it_sel_row ).

        IF it_sel_row IS INITIAL.
          MESSAGE i054(zali_web_shop).
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
        ENDIF.

        DATA(ls_item) = VALUE #( me->mo_home_screen_model->mt_cart[ it_sel_row[ 1 ]-index ] OPTIONAL ).

        IF sy-subrc <> 0.
          MESSAGE i044(zali_web_shop) INTO DATA(ls_msg).
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
        ENDIF.

        rs_selected_item = ls_item.

      CATCH zcx_ali_webshop_exception_new INTO DATA(lo_exc).
        MESSAGE lo_exc.
    ENDTRY.

  ENDMETHOD.


  METHOD search_selected_product.

    DATA: it_sel_rows TYPE lvc_t_row.
    TRY.
        "get index of selected row
        me->mo_alv_grid_home_screen->get_selected_rows( IMPORTING et_index_rows = it_sel_rows ).

        IF it_sel_rows IS INITIAL.
          MESSAGE i057(zali_web_shop).
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
        ENDIF.
        "in the alv it's not possible to select more than 1 row, so in our table it_sel_rows we don't have more than one row
        DATA(ls_product) = VALUE #( me->mo_home_screen_model->mt_articles_out[ it_sel_rows[ 1 ]-index ] OPTIONAL ).

        IF ls_product IS INITIAL.
          MESSAGE i043(zali_web_shop) INTO DATA(ls_msg).
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
        ENDIF.

        rs_selected_product = ls_product.

      CATCH zcx_ali_webshop_exception_new INTO DATA(lo_exc).
        MESSAGE lo_exc.
    ENDTRY.

  ENDMETHOD.


  METHOD send_order_confirmation.

    DATA: lv_subject   TYPE string,
          lv_recipient TYPE adr6-smtp_addr.

    lv_recipient = iv_email.
    lv_subject = 'Bestellbestätigung zur Bestellung: ' && iv_order_number.

    DATA(lt_email_text) = me->generate_html_text_for_email( ).

    TRY.
        DATA(lo_ducumente) = cl_document_bcs=>create_document( i_type    = 'HTM'
                                                               i_text    = lt_email_text
                                                               i_subject = CONV so_obj_des( lv_subject ) ).

        DATA(lo_send_request) = cl_bcs=>create_persistent( ).
        lo_send_request->set_message_subject( ip_subject = lv_subject ).
        lo_send_request->set_document( lo_ducumente ).

        "SAP - User for sending email
        DATA(lo_sender) = cl_sapuser_bcs=>create( sy-uname ).
        lo_send_request->set_sender( lo_sender ).
        DATA(o_recipient) = cl_cam_address_bcs=>create_internet_address( lv_recipient ).
        lo_send_request->add_recipient( i_recipient = o_recipient i_express = abap_true ).
        lo_send_request->set_send_immediately( abap_true ).

        IF lo_send_request->send( i_with_error_screen = abap_true ) = abap_false.
          "If something went wrong by sending email
          MESSAGE i061(zali_web_shop) INTO DATA(ls_msg).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.

        ENDIF.

        COMMIT WORK.

      CATCH zcx_ali_webshop_exception_new
            cx_send_req_bcs
            cx_address_bcs
            cx_document_bcs INTO DATA(lo_exc).
        ROLLBACK WORK.
    ENDTRY.

  ENDMETHOD.


  METHOD show_article.

    IF mo_custom_container_article IS NOT BOUND.

      mo_custom_container_article = NEW cl_gui_custom_container( container_name = 'C_ARTIKEL_TO_POSITION'
                                                                 repid          = 'SAPLZALI_HOME_SCREEN'
                                                                 dynnr          = '9003' ).

      mo_alv_grid_article = NEW cl_gui_alv_grid( i_parent = mo_custom_container_article ).
      mo_alv_grid_article->set_table_for_first_display( EXPORTING i_structure_name = 'ZALI_ARTICLE'
                                                        CHANGING  it_outtab        = mt_article ).

    ELSE.
      mo_alv_grid_article->refresh_table_display(  ).
    ENDIF.


  ENDMETHOD.


  METHOD show_company_logo_on_home_sc.

    DATA: lv_url   TYPE cndp_url,
          lv_objid TYPE w3objid VALUE 'ZSBT_SALT_FIRMENLOGO'.

    TRY.

        IF mo_container_logo_home_screen IS NOT BOUND.
          mo_container_logo_home_screen = NEW cl_gui_custom_container(  container_name          = 'CC_COMPANY_LOGO'
                                                                        repid                   = 'SAPLZALI_HOME_SCREEN'
                                                                        dynnr                   = '9000' ).
        ENDIF.

        IF mo_logo_home_screen IS NOT BOUND.
          mo_logo_home_screen = NEW cl_gui_picture( parent = mo_container_logo_home_screen ).
        ENDIF.

        CALL FUNCTION 'DP_PUBLISH_WWW_URL'
          EXPORTING
            objid                 = lv_objid
            lifetime              = cndp_lifetime_transaction
          IMPORTING
            url                   = lv_url
          EXCEPTIONS
            dp_invalid_parameters = 1
            no_object             = 2
            dp_error_publish      = 3
            OTHERS                = 4.
        IF sy-subrc <> 0.
          MESSAGE: i063(zali_web_shop) WITH sy-subrc INTO DATA(ls_msg).
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
        ENDIF.

        me->mo_logo_home_screen->load_picture_from_url_async( EXPORTING    url    = lv_url
                                                              EXCEPTIONS   error  = 1
                                                                           OTHERS = 2 ).
        IF sy-subrc <> 0.
          MESSAGE: i064(zali_web_shop) WITH sy-subrc INTO ls_msg.
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
        ENDIF.

        me->mo_logo_home_screen->set_display_mode( EXPORTING   display_mode = cl_gui_picture=>display_mode_fit
                                                   EXCEPTIONS  error        = 1
                                                               OTHERS       = 2 ).
        IF sy-subrc <> 0.
          MESSAGE: i065(zali_web_shop) WITH sy-subrc INTO ls_msg.
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
        ENDIF.

      CATCH zcx_ali_webshop_exception_new INTO DATA(lo_exc).
        MESSAGE lo_exc.
    ENDTRY.

  ENDMETHOD.


  METHOD show_order.

    CLEAR me->mt_order_to_show.
    me->mt_order_to_show = it_order.

    IF it_order IS NOT INITIAL.
      IF me->mo_container_show_position IS NOT BOUND.

        me->mo_container_show_position = NEW cl_gui_custom_container(  container_name          = 'C_POSITION_TO_ORDER'
                                                                       repid                   = 'SAPLZALI_HOME_SCREEN'
                                                                       dynnr                   = '9003' ).

        me->mo_alv_grid_show_position = NEW #( i_parent = me->mo_container_show_position ).

        SET HANDLER me->add_buttons_show_position FOR me->mo_alv_grid_show_position.
        SET HANDLER me->on_buttons_show_position  FOR me->mo_alv_grid_show_position.
        SET HANDLER me->on_double_click_position  FOR me->mo_alv_grid_show_position.

        me->mo_alv_grid_show_position->set_table_for_first_display( EXPORTING i_structure_name = 'ZALI_ORDER'
                                                                    CHANGING  it_outtab        = mt_order_to_show ).
      ELSE.
        me->mo_alv_grid_show_position->refresh_table_display(  ).
      ENDIF.

    ELSE.
      MESSAGE i068(zali_web_shop) INTO  DATA(lv_msg).
      me->mo_log->add_msg_from_sys( ).
      me->mo_log->safe_log( ).
      RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  METHOD start.
    TRY.
        me->mo_home_screen_view->call_home_screen( ).
      CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
