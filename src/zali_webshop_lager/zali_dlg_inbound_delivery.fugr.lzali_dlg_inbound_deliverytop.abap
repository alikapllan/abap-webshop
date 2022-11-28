FUNCTION-POOL ZALI_DLG_INBOUND_DELIVERY.    "MESSAGE-ID ..

* INCLUDE LZALI_DLG_INBOUND_DELIVERYD...     " Local class definition
DATA: go_login_view           TYPE REF TO zcl_ali_inbound_delivery_view,
      gs_login_data           TYPE zali_db_wh_ma,
      gv_article_number       TYPE zali_article_number,
      go_putaway_article_view TYPE REF TO zcl_ali_inbound_delivery_view,
      gv_lagernummer          TYPE zali_warehouse_number,
      gv_lagerbereich         TYPE zali_storage_area,
      gv_lagerplatz           TYPE zali_storage_place,
      gv_storage_place_in     TYPE zali_storage_place,
      gv_quantity             TYPE zali_amount,
      gv_meins                TYPE zali_unit.
