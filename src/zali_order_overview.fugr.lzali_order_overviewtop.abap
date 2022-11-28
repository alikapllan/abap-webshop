FUNCTION-POOL ZALI_ORDER_OVERVIEW.             "MESSAGE-ID ..

* INCLUDE LZALI_ORDER_OVERVIEWD...              " Local class definition

DATA: go_web_shop TYPE REF TO zcl_ali_order_overview_view.
DATA: p_ein       TYPE        zali_order_amount.
DATA: p_status    TYPE        zali_status.
