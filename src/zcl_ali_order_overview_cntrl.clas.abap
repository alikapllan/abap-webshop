CLASS zcl_ali_order_overview_cntrl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      tty_bestellungen TYPE STANDARD TABLE OF zali_order .

    METHODS: on_edit_status ,
      on_edit_menge ,
      on_delete RAISING zcx_ali_webshop_exception_new,
      on_order_overview_pbo RAISING zcx_ali_webshop_exception_new,
      on_start ,
      constructor
        IMPORTING
                  !iv_customer_number TYPE zali_kd_numr_de
                  !iv_order_number    TYPE zali_order_number
                  !iv_status          TYPE zali_status
                  !iv_filter          TYPE i
                  !io_log             TYPE REF TO zcl_ali_webshop_log
                  !ir_order           TYPE zali_order OPTIONAL
                  !ir_grid            TYPE REF TO cl_gui_alv_grid OPTIONAL
        RAISING   zcx_ali_webshop_exception_new,

      on_back ,
      on_leave ,
      on_double_click
        FOR EVENT double_click OF cl_gui_alv_grid ,
      on_position RAISING zcx_ali_webshop_exception_new /auk/cx_vc,
      on_positions_overview_pbo RAISING zcx_ali_webshop_exception_new,
      on_refresh ,
      on_delete_position RAISING zcx_ali_webshop_exception_new,
      on_edit
        IMPORTING
          !iv_wert TYPE any .
  PROTECTED SECTION.
private section.

  data MO_BEST_CONTAINER type ref to CL_GUI_CUSTOM_CONTAINER .
  data MO_POS_CONTAINER type ref to CL_GUI_CUSTOM_CONTAINER .
  data MV_FILTER type I value 0 ##NO_TEXT.
  data MO_WEB_SHOP_MODEL type ref to ZCL_ALI_ORDER_OVERVIEW_MODEL .
  data MV_ORDER_NUMBER type ZALI_ORDER_NUMBER .
  data MV_STATUS type ZALI_STATUS .
  data MO_WEB_SHOP_VIEW type ref to ZCL_ALI_ORDER_OVERVIEW_VIEW .
  data MV_CUSTOMER_NUMBER type ZALI_KD_NUMR_DE .
  data MO_ALV_GRID_ORDER_OVERVIEW type ref to CL_GUI_ALV_GRID .
  data MS_POSITIONS type ZALI_S_ORDER .
  data MT_POSITIONS type TTY_BESTELLUNGEN .
  data MO_ALV_GRID_POSITIONSUBERSICHT type ref to CL_GUI_ALV_GRID .
  data MO_LOG type ref to ZCL_ALI_WEBSHOP_LOG .

  methods DEQUEUE_ZALI_ORDER .
  methods ENQUEUE_ZALI_ORDER
    returning
      value(RV_ENQUEUE_OK) type I .
  methods CREATE_ALV_UEBERSICHT
    raising
      ZCX_ALI_WEBSHOP_EXCEPTION_NEW .
  methods SEARCH_SELECTED_ORDER
    returning
      value(RS_SELECTED_ORDER) type ZALI_S_ORDER
    raising
      ZCX_ALI_WEBSHOP_EXCEPTION_NEW .
  methods SEARCH_SELECTED_POSITION
    returning
      value(RS_ORDER_POSITIONS) type ZALI_ORDER
    raising
      ZCX_ALI_WEBSHOP_EXCEPTION_NEW .
  methods CREATE_ALV_POSITION
    raising
      ZCX_ALI_WEBSHOP_EXCEPTION_NEW .
  methods REFRESH_POSITION
    raising
      ZCX_ALI_WEBSHOP_EXCEPTION_NEW .
  methods ON_DOUBLE_CLICK_EDIT_MENGE
    for event DOUBLE_CLICK of CL_GUI_ALV_GRID .
  methods BUTTON_TOOLBAR_ORDER
    for event TOOLBAR of CL_GUI_ALV_GRID
    importing
      !E_INTERACTIVE
      !E_OBJECT .
  methods ON_TOOLBAR_BTN_DELETE_ORDER
    for event USER_COMMAND of CL_GUI_ALV_GRID
    importing
      !E_UCOMM .
  methods BUTTON_TOOLBAR_POSITION
    for event TOOLBAR of CL_GUI_ALV_GRID
    importing
      !E_INTERACTIVE
      !E_OBJECT .
  methods ON_TOOLBAR_BTN_DELETE_POS
    for event USER_COMMAND of CL_GUI_ALV_GRID
    importing
      !E_UCOMM .
ENDCLASS.



CLASS ZCL_ALI_ORDER_OVERVIEW_CNTRL IMPLEMENTATION.


  METHOD button_toolbar_order.

    DATA ls_button TYPE stb_button.
    CONSTANTS: lc_function_code TYPE char70 VALUE 'DELETE',
               lc_quickinfo     TYPE char30 VALUE 'Löschen einer Bestellung',
               lc_disabled      TYPE char1  VALUE ' ',
               lc_butali_text   TYPE char40 VALUE 'Bestellung Löschen'.

    "Einfügen eines Seperators (Senkrechter Strich) zum Absetzen von anderen Butalis
    CLEAR ls_button.
    ls_button-butn_type = 3. "Seperator
    APPEND ls_button TO e_object->mt_toolbar.

    "Einfügen des Delete-Butalis
    CLEAR ls_button.

    ls_button = VALUE stb_button(  function = lc_function_code
                                       icon = icon_cancel
                                  quickinfo = lc_quickinfo
                                   disabled = lc_disabled
                                       text = lc_butali_text ).
    "Hinzufügen des Butalis zur Toolbar
    APPEND ls_button TO e_object->mt_toolbar.

  ENDMETHOD.


  METHOD BUTTON_TOOLBAR_POSITION.

    DATA ls_button_position TYPE stb_button.

    CONSTANTS: lc_function_code TYPE char70 VALUE 'DELETE',
               lc_quickinfo     TYPE char30 VALUE 'Löschen einer Position',
               lc_disabled      TYPE char1  VALUE ' ',
               lc_butali_text   TYPE char40 VALUE 'Position Löschen'.

    "Einfügen eines Seperators (Senkrechter Strich) zum Absetzen von anderen Butalis
    CLEAR ls_button_position.
    ls_button_position-butn_type = 3. "Seperator
    APPEND ls_button_position TO e_object->mt_toolbar.

    "Einfügen des Delete-Butalis
    CLEAR ls_button_position.

    ls_button_position = VALUE stb_button(  function = lc_function_code
                                                icon = icon_cancel
                                           quickinfo = lc_quickinfo
                                            disabled = lc_disabled
                                                text = lc_butali_text ).
    "Hinzufügen des Butalis zur Toolbar
    APPEND ls_button_position TO e_object->mt_toolbar.



  ENDMETHOD.


  METHOD constructor.

    mo_log          = io_log.
    mv_customer_number   = iv_customer_number.
    mv_order_number  = iv_order_number.
    mv_status         = iv_status.
    mv_filter         = iv_filter.


    "Instanziierung des Models
    me->mo_web_shop_model = NEW zcl_ali_order_overview_model( NEW zcl_ali_webshop_log( iv_object = 'ZALI_' iv_suobj = 'ZALI_' ) ).

    "Instanziierung der View
    me->mo_web_shop_view = NEW zcl_ali_order_overview_view( io_cntrl = me ).

    "Wenn Objekte nicht vorhanden sind dann Fehler
    IF me->mo_web_shop_model IS NOT BOUND OR me->mo_web_shop_view IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new
        EXPORTING
          textid = zcx_ali_webshop_exception_new=>object_not_found.
    ENDIF.
  ENDMETHOD.


  METHOD create_alv_position.

    "Wenn noch kein Container exsistier=>sonst ensteht Refresh Fehler da immerwieder Objekte nachproduziert werden
    IF mo_pos_container IS INITIAL.
      me->mo_pos_container = NEW cl_gui_custom_container( container_name = 'CC_CONTAINER'
                                                               repid     = 'SAPLZALI_ORDER_OVERVIEW'
                                                               dynnr     = '9002'        ).

      "Zeige ALV mit Positionen an / Achtung Objekt mo_pos_container darf nur einmal existieren
      me->mo_alv_grid_positionsubersicht = NEW cl_gui_alv_grid( i_parent = mo_pos_container ).

      me->mo_alv_grid_positionsubersicht->set_table_for_first_display(
        EXPORTING
          i_structure_name = 'ZALI_ORDER'
        CHANGING
          it_outtab        = mt_positions
        EXCEPTIONS
          OTHERS           = 1 ).

      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new
          EXPORTING
            textid = zcx_ali_webshop_exception_new=>alv_not_able_to_create.
      ENDIF.
    ELSE.
      "Wenn Bereits ein Container existiert führe ein Refresh durch
      mo_alv_grid_positionsubersicht->refresh_table_display( ).
    ENDIF.

    SET HANDLER me->on_double_click_edit_menge
                me->button_toolbar_position
                me->on_toolbar_btn_delete_pos
                FOR me->mo_alv_grid_positionsubersicht.

    me->mo_alv_grid_positionsubersicht->set_toolbar_interactive( ).

  ENDMETHOD.


  METHOD create_alv_uebersicht.

    FREE: me->mo_alv_grid_order_overview.
    CLEAR: me->mo_alv_grid_order_overview.

    IF mo_best_container IS INITIAL.
      mo_best_container = NEW cl_gui_custom_container( container_name = 'C_CONTAINER'
                                                       repid          = 'SAPLZALI_ORDER_OVERVIEW'
                                                       dynnr          = '9001'
                                                     ).
    ENDIF.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new
        EXPORTING
          textid = zcx_ali_webshop_exception_new=>alv_not_able_to_create.
    ENDIF.

    IF mo_best_container IS BOUND.
      me->mo_alv_grid_order_overview = NEW cl_gui_alv_grid( i_parent = mo_best_container ).
    ELSE.
      RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new
        EXPORTING
          textid = zcx_ali_webshop_exception_new=>alv_not_able_to_create.
    ENDIF.

  ENDMETHOD.


  METHOD dequeue_zali_order.

    CALL FUNCTION 'DEQUEUE_EZALI_ORDER'
      EXPORTING
        mode_zali_order = 'E'
        order_number      = me->ms_positions-order_number.

  ENDMETHOD.


  METHOD enqueue_zali_order.

    "Sperre setzen
    CALL FUNCTION 'ENQUEUE_EZALI_ORDER'
      EXPORTING
        mode_zali_order = 'E'
        order_number        = me->ms_positions-order_number
      EXCEPTIONS
        foreign_lock         = 1
        system_failure       = 2
        OTHERS               = 3.
    "Rückgabe des sy-subrc Wertes an den Aufrufer für weitere Verabeitung
    rv_enqueue_ok = sy-subrc.

  ENDMETHOD.


  METHOD on_back.
    TRY.
        me->dequeue_zali_order( ).

        IF me->mo_alv_grid_order_overview IS BOUND.
          me->on_refresh( ).
        ENDIF.

        LEAVE TO SCREEN 0.
      CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.


  METHOD on_delete.

    DATA: lv_sysubrc TYPE i.

    CONSTANTS: lc_text           TYPE char90 VALUE 'Sind Sie sicher das Sie die Bestellung löschen wollen?'    ##no_text,
               lc_kind           TYPE char4  VALUE 'QUES'                                                      ##no_text,
               lc_button1        TYPE char15 VALUE 'JA'                                                        ##no_text,
               lc_button2        TYPE char15 VALUE 'NEIN'                                                      ##no_text,
               lc_text_sperre    TYPE char90 VALUE 'Bestellung wird bereits von einem anderen User bearbeitet' ##no_text,
               lc_kind_sperre    TYPE char4  VALUE 'INFO'                                                      ##no_text,
               lc_butali1_sperre TYPE char15 VALUE 'OK'                                                        ##no_text.

    TRY.
        "Sperre setzen
        lv_sysubrc = me->enqueue_zali_order( ).
        "Wenn Sperre gesetzt werden konnte
        IF lv_sysubrc = 0.
          "Abfrage ob User sicher löschen will
          DATA(lv_btn) = /auk/cl_msgbox=>show_msgbox( im_text    = lc_text
                                                      im_kind    = lc_kind
                                                      im_button1 = lc_button1
                                                      im_button2 = lc_button2 ).
          "Wenn User Löschen will
          IF lv_btn = 1.
            "Ausgewählte Bestellung holen
            DATA(ls_selected_order)  = me->search_selected_order( ).
            "Wenn Benutzer keine Zeile Ausgewählt hat oder ein Fehler dabei auftritt
            IF ls_selected_order IS INITIAL.
              MESSAGE i034(zali_web_shop) INTO DATA(ls_msg).
              me->mo_log->add_msg_from_sys( ).
              me->mo_log->safe_log( ).
              RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
            ENDIF.
            "Ausgewählte Bestellung löschen
            me->mo_web_shop_model->delete_order( iv_order_number = ls_selected_order-order_number ).
            "Bestellungsübersicht aktualisieren
            me->on_refresh( ).
          ELSE.
            "Wird keine Aktion ausgeführt
          ENDIF.

        ELSEIF lv_sysubrc = 1.
          "Ein User hat bereits eine Sperre gesetzt=> Info Pop-Up anzeigen
          DATA(lv_butali) = /auk/cl_msgbox=>show_msgbox( im_text    = lc_text_sperre
                                                         im_kind    = lc_kind_sperre
                                                         im_button1 = lc_butali1_sperre ).

          IF lv_butali = 1.
            "Kehre zur Bestellungsauswahl zurück
            TRY.
                me->on_order_overview_pbo( ).
              CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
                MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
            ENDTRY.
          ELSE.
            "Do nothing
          ENDIF.
        ELSE.
          "Wenn ein Fehler beim Erstellen der Sperre auftritt
          MESSAGE i037(zali_web_shop).
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
        ENDIF.

      CATCH /auk/cx_vc.
        MESSAGE e082(zali_web_shop) INTO DATA(lv_msg).
        me->mo_log->add_msg_from_sys( ).
        me->mo_log->safe_log( ).
        RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
    ENDTRY.

  ENDMETHOD.


  METHOD on_delete_position.

    CONSTANTS: lc_text    TYPE char90 VALUE 'Sind Sie sicher das Sie die Position löschen wollen?'   ##no_text,
               lc_kind    TYPE char4  VALUE 'QUES'                                                   ##no_text,
               lc_button1 TYPE char15 VALUE 'JA'                                                     ##no_text,
               lc_button2 TYPE char15 VALUE 'NEIN'                                                   ##no_text.

    TRY.
        DATA(lv_btn) = /auk/cl_msgbox=>show_msgbox( im_text    = lc_text
                                                    im_kind    = lc_kind
                                                    im_button1 = lc_button1
                                                    im_button2 = lc_button2 ).
      CATCH /auk/cx_vc.
        MESSAGE e082(zali_web_shop) INTO DATA(lv_msg).
        me->mo_log->add_msg_from_sys( ).
        me->mo_log->safe_log( ).
        RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
    ENDTRY.
    "Wenn User löschen möchte
    IF lv_btn = 1.
      TRY.
          me->mo_web_shop_model->delete_position( is_position = me->search_selected_position( ) ).
          "Bestellübersicht aktualisieren
          me->on_refresh( ).
          "Zurückspringen zur Bestellübersicht
          LEAVE TO SCREEN 0.
        CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
          MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
      ENDTRY.
    ELSE.
      "User möchte nicht löschen, es wird keine Aktion durchgeführt
    ENDIF.

  ENDMETHOD.


  METHOD on_double_click.

    "Hohlt Positionen zur Ausgewhälten Bestellung und zeigt diese an
    TRY.
        me->on_position( ).
      CATCH zcx_ali_webshop_exception_new
           /auk/cx_vc   INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.


  METHOD on_double_click_edit_menge.

    me->on_edit_menge( ).

  ENDMETHOD.


  METHOD on_edit.
    TRY.
        "Struktur mit eingegebenen Daten ändern und in eintrag in DB verändern
        me->mo_web_shop_model->edit_postition( EXPORTING iv_wert     = iv_wert
                                                       is_position = me->search_selected_position( ) ).

        "Bestellübericht Aktualisieren
        me->refresh_position( ).
      CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
    "geöffnetes Pop-Up veralssen
    LEAVE TO SCREEN 0.

  ENDMETHOD.


  METHOD on_edit_menge.
    TRY.
        "Pop-Up aufrufen mit Eingabefeld
        me->mo_web_shop_view->call_popup_edit_amount( ).
      CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.


  METHOD on_edit_status.
    TRY.
        me->mo_web_shop_view->call_popup_edit_status( ).
      CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.


  METHOD on_leave.

    LEAVE PROGRAM.

  ENDMETHOD.


  METHOD on_order_overview_pbo.

    SET PF-STATUS '9001'           OF PROGRAM 'SAPLZALI_ORDER_OVERVIEW'.
    SET TITLEBAR 'UEBERSICHT9001'  OF PROGRAM 'SAPLZALI_ORDER_OVERVIEW'.
    "Selektierte Daten holen mit verbesserter Ansicht
    me->mo_web_shop_model->get_order_overview( ) .

    IF me->mo_web_shop_model->mt_order_view IS INITIAL.
      RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new
        EXPORTING
          textid = zcx_ali_webshop_exception_new=>order_not_found.


    ENDIF.

    IF me->mo_alv_grid_order_overview IS NOT BOUND.
      create_alv_uebersicht( ).

      "Tabelle anzeigen
      me->mo_alv_grid_order_overview->set_table_for_first_display(
        EXPORTING
          i_structure_name              = 'ZALI_S_ORDER'
        CHANGING
          it_outtab                     = me->mo_web_shop_model->mt_order_view
        EXCEPTIONS
          OTHERS                        = 1
      ).

      "Wenn Fehler bei der Erstellung ALV-Grid auftauch SY-SUBRC = 1.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new
          EXPORTING
            textid = zcx_ali_webshop_exception_new=>alv_not_able_to_create.
      ENDIF.
      SET HANDLER me->button_toolbar_order
                  me->on_double_click
                  me->on_toolbar_btn_delete_order
                  FOR me->mo_alv_grid_order_overview.
    ENDIF.

    me->mo_alv_grid_order_overview->set_toolbar_interactive( ).

  ENDMETHOD.


  METHOD on_position.

    DATA lv_sy_subrc TYPE i.

    CONSTANTS: lc_text    TYPE char90 VALUE 'Bestellung, wird bereits von einem anderen User bearbeitet' ##no_text,
               lc_kind    TYPE char4  VALUE 'INFO'                                                       ##no_text,
               lc_button1 TYPE char15 VALUE 'OK'                                                         ##no_text.

    CLEAR me->ms_positions.
    TRY.
        me->ms_positions = me->search_selected_order( ).

        "Sperren der ausgewählten Bestellung zum Bearbeiten
*    lv_sy_subrc = me->enqueue_zali_bestellung( ).

        IF me->enqueue_zali_order( ) = 0.
          "Rufe View Positionsübersicht auf
          me->mo_web_shop_view->call_position_overview( ).

        ELSEIF me->enqueue_zali_order( ) = 1.
          "Wenn eine Sperre vorhanden ist soll der User nicht die Möglichkeit haben den Eintrag zu bearbeiten
          "Anzeige ein Pop-Ups mit Info Text, dass  ein User bereits bearbeitet
          DATA(lv_btn) = /auk/cl_msgbox=>show_msgbox( im_text    = lc_text
                                                      im_kind    = lc_kind
                                                      im_button1 = lc_button1 ).

          IF lv_btn = 1.

            "Kehre zur Bestellungsauswahl zurück
            me->on_order_overview_pbo( ).
          ELSE.
            "Do nothing
          ENDIF.

        ELSEIF me->enqueue_zali_order( ) = 2 OR me->enqueue_zali_order( ) = 3.
          "Falls ein Fehler beim Sperren auftritt
          MESSAGE i037(zali_web_shop).
          me->mo_log->add_msg_from_sys( ).
          me->mo_log->safe_log( ).
          RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
        ENDIF.
      CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.


  METHOD on_positions_overview_pbo.

    SET PF-STATUS '9002'                OF PROGRAM 'SAPLZALI_ORDER_OVERVIEW'.
    SET TITLEBAR 'POSITIONSUEBERSICHT'  OF PROGRAM 'SAPLZALI_ORDER_OVERVIEW'.

    CLEAR me->mt_positions.
    "Hole aktuelle Positionen zur Bestellnummer
    me->mo_web_shop_model->get_positions( iv_order_number = ms_positions-order_number ).
    me->mt_positions = me->mo_web_shop_model->get_positions_output( ).

    IF me->mt_positions IS INITIAL.
      "Raise Exception mit USING MESSAGE
      MESSAGE i020(zali_web_shop) INTO DATA(ls_msg).
      me->mo_log->add_msg_from_sys( ).
      me->mo_log->safe_log( ).
      RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
    ENDIF.

    me->create_alv_position( ).

  ENDMETHOD.


  METHOD on_refresh.
    TRY.
        "Selekiert die aktuellen Daten
        mo_web_shop_model->get_information(
          EXPORTING
            iv_filter        =     mv_filter          " gibt an nach was selektiert werden soll
            iv_customer_number  =     mv_customer_number    " Kundennummer
            iv_order_number =     mv_order_number   " Bestellnummer
            iv_status        =     mv_status          " Bestellstatus
                ).

        "Aktuelle Daten werden zu einer Ausgabe-Tabelle verarbeitet
        me->mo_web_shop_model->get_order_overview( ).

        "Refresh Tabelle mit aktuellen Daten
        me->mo_alv_grid_order_overview->refresh_table_display( ).
      CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.


  METHOD on_start.
    TRY.
        "Selekierte Daten vom Model
        mo_web_shop_model->get_information(
          EXPORTING
            iv_filter        =     mv_filter          " gibt an nach was selektiert werden soll
            iv_customer_number  =     mv_customer_number    " Kundennummer
            iv_order_number =     mv_order_number   " Bestellnummer
            iv_status        =     mv_status          " Bestellstatus
        ).

        "Aufrufen der View
        mo_web_shop_view->call_order_overview( ).
      CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.


  METHOD on_toolbar_btn_delete_order.

    CASE e_ucomm.
      WHEN 'DELETE'.
        TRY.
            me->on_delete( ).
          CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
            MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
        ENDTRY.
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.


  METHOD on_toolbar_btn_delete_pos.

    CASE e_ucomm.
      WHEN 'DELETE'.
        TRY.
            me->on_delete_position( ).
          CATCH zcx_ali_webshop_exception_new INTO DATA(e_text).
            MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
        ENDTRY.
      WHEN OTHERS.
        "Kommt nicht vor, daher passiert hier nichts
    ENDCASE.

  ENDMETHOD.


  METHOD refresh_position.

    "Aktuelle Daten beschaffen
    CLEAR me->mt_positions.
    "Hole aktuelle Positionen zur Bestellnummer
    me->mo_web_shop_model->get_positions( iv_order_number = ms_positions-order_number ).
    me->mt_positions = me->mo_web_shop_model->get_positions_output( ).

    IF me->mt_positions IS INITIAL.
      "Raise Exception mit USING MESSAGE
      MESSAGE i020(zali_web_shop) INTO DATA(ls_msg).
      me->mo_log->add_msg_from_sys( ).
      me->mo_log->safe_log( ).
      RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
    ENDIF.

    "Positionsübersicht aktualisieren
    me->mo_alv_grid_positionsubersicht->refresh_table_display( ).

  ENDMETHOD.


  METHOD search_selected_order.

    DATA:  it_sel_rows TYPE lvc_t_row.

    "Hole index Selektierte Zeile
    me->mo_alv_grid_order_overview->get_selected_rows( IMPORTING et_index_rows = it_sel_rows ).

    LOOP AT it_sel_rows ASSIGNING  FIELD-SYMBOL(<lv_sel_rows>).
      "Suche Markierte Zeile anhand index und gebe Markierten Eintrag in ls_zwischen
      READ TABLE  me->mo_web_shop_model->get_view( ) INTO DATA(ls_zwischen) INDEX <lv_sel_rows>-index.
      IF sy-subrc NE 0.
        MESSAGE: e024(zali_web_shop) INTO DATA(ls_msg).
        me->mo_log->add_msg_from_sys( ).
        me->mo_log->safe_log( ).
        RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
      ENDIF.
    ENDLOOP.

    rs_selected_order = ls_zwischen.

  ENDMETHOD.


  METHOD search_selected_position.

    "Hole index Selektierte Zeile
    me->mo_alv_grid_positionsubersicht->get_selected_rows( IMPORTING et_index_rows = DATA(it_sel_rows) ).

    "Falls keine Position angeklickt wurde, wird alternativ die erste Position der Bestellung ausgewählt
    IF it_sel_rows IS INITIAL.
      rs_order_positions = VALUE zali_order( mt_positions[ 1 ] OPTIONAL ).
    ELSE.
      "Falls User eine Position ausgewählt hat
      rs_order_positions = VALUE zali_order( mt_positions[ it_sel_rows[ 1 ]-index ] OPTIONAL ).
    ENDIF.

    "Falls ein keine Position in der Struktur ist
    IF rs_order_positions IS INITIAL.
      MESSAGE i036(zali_web_shop) INTO DATA(ls_msg).
      me->mo_log->add_msg_from_sys( ).
      me->mo_log->safe_log( ).
      RAISE EXCEPTION TYPE zcx_ali_webshop_exception_new USING MESSAGE.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
