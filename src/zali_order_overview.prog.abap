*&---------------------------------------------------------------------*
*& Report ZALI_BEST_UEBERSICHT_CL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zali_order_overview.

DATA: lv_filter    TYPE         i.
DATA: lv_object    TYPE balobj_d VALUE 'ZALI'.
DATA: lv_subobject TYPE balobj_d VALUE 'ZALI'.

PARAMETERS: p_rkunde RADIOBUTTON GROUP rad1      USER-COMMAND test
            ,p_kundid TYPE zali_kd_numr_de        MODIF ID kid  MATCHCODE OBJECT zali_sh_customer.
*            ,p_kundid TYPE zali_customer_number  MODIF ID kid  MATCHCODE OBJECT zali_sh_customer.

PARAMETERS: p_rbest RADIOBUTTON GROUP rad1
            ,p_best   TYPE zali_order_number  MODIF ID bes  MATCHCODE OBJECT zali_sh_ordernumber. "=>Mit Suchhilfen Exit löscht doppelte Einträge

PARAMETERS: p_rstat  RADIOBUTTON GROUP rad1
            ,p_status TYPE zali_status         MODIF ID sta.

PARAMETERS: p_rall   RADIOBUTTON GROUP rad1      DEFAULT 'X'.

SELECTION-SCREEN PUSHBUTTON /1(15) search         USER-COMMAND search.


AT SELECTION-SCREEN OUTPUT.
  search   = TEXT-b01.

  PERFORM remove_parameters_from_screen.
  "Remove execute butali and save butali from selction-screen
  PERFORM insert_into_excl(rsdbrunt) USING 'ONLI'.
  PERFORM insert_into_excl(rsdbrunt) USING 'SPOS'.



FORM remove_parameters_from_screen.
  "Nicht bennötigte Eingabfelder inaktiv setzen
  LOOP AT SCREEN.
    CASE screen-group1.

      WHEN 'KID'.
        IF p_rkunde = 'X'.
          screen-input = '1'.
        ELSE.
          screen-input = '0'.
        ENDIF.

      WHEN 'STA'.
        IF p_rstat = 'X'.
          screen-active = '1'.
        ELSE.
          screen-input = '0'.
        ENDIF.

      WHEN 'BES'.
        IF p_rbest = 'X'.
          screen-input = '1'.
        ELSE.
          screen-input = '0'.
        ENDIF.

    ENDCASE.

    MODIFY SCREEN.

  ENDLOOP.

ENDFORM.



START-OF-SELECTION.

AT SELECTION-SCREEN.

  CASE sy-ucomm.
    WHEN 'SEARCH'.
      "Nach ausgewälter Selektionsart Filter setzten
      IF p_rbest       EQ 'X'.
        lv_filter = 2.
      ELSEIF p_rkunde  EQ 'X'.
        lv_filter = 1.
      ELSEIF p_rstat   EQ 'X'.
        lv_filter = 3.
      ELSEIF p_rall    EQ 'X'.
        lv_filter = 0.
      ELSE.
        lv_filter = 0.
      ENDIF.

      TRY.
          DATA(lo_log) = NEW zcl_ali_webshop_log( iv_object = lv_object iv_suobj = lv_subobject ).
          DATA(lo_start) = NEW zcl_ali_order_overview_cntrl( iv_filter        = lv_filter
                                                               iv_order_number = p_best
                                                               iv_customer_number  = p_kundid
                                                               iv_status        = p_status
                                                               io_log = lo_log ).

          lo_start->on_start( ).

        CATCH zcx_ali_webshop_exception_new INTO DATA(e_txt).


          MESSAGE: e_txt TYPE 'E'.
      ENDTRY.

  ENDCASE.

END-OF-SELECTION.
