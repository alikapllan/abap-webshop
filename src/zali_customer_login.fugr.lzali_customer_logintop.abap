FUNCTION-POOL ZALI_CUSTOMER_LOGIN.             "MESSAGE-ID ..

* INCLUDE LZALI_CUSTOMER_LOGIND...              " Local class definition
DATA go_login_view TYPE REF TO zcl_ali_customer_login_view.
DATA go_customer_register_view TYPE REF TO zcl_ali_customer_register_view.
DATA p_email    TYPE zali_email.
DATA p_password TYPE zali_password.
DATA p_password_repeat TYPE zali_password.
DATA p_street TYPE zali_street.
DATA p_house_number TYPE zali_house_nr.
DATA p_zipcode TYPE zali_postalcode.
DATA p_city TYPE zali_city.
DATA p_telephone_number TYPE zali_phone_number.
DATA gs_register_data TYPE zali_s_register.
DATA p_salutation type zali_salutation.
DATA p_firstname type zali_firstname.
DATA p_name type zali_name.
