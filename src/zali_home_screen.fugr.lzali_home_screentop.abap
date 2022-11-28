FUNCTION-POOL ZALI_HOME_SCREEN.                "MESSAGE-ID ..

* INCLUDE LZALI_HOME_SCREEND...                 " Local class definition
DATA go_home_screen_view TYPE REF TO zcl_ali_homescreen_view.
DATA go_cart_view TYPE REF TO zcl_ali_cart_view.
DATA p_quantity TYPE zali_order_amount.
DATA p_search TYPE string.
DATA go_address_view TYPE REF TO zcl_ali_alternativ_adress.
DATA p_street TYPE zali_street.
DATA p_house_number TYPE zali_house_nr.
DATA p_zip_code TYPE zali_postalcode.
DATA p_address_city TYPE zali_city.
DATA go_order_overview_view TYPE REF TO zcl_ali_homescreen_order_view.
