*&---------------------------------------------------------------------*
*& Report ZALI_COLLECT_CUSTOMER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zali_collect_customer.

PARAMETERS:
  p_salut   TYPE zali_salutation  OBLIGATORY,
  p_name    TYPE zali_name OBLIGATORY,
  p_fname   TYPE zali_firstname OBLIGATORY,
  p_street  TYPE zali_street OBLIGATORY,
  p_nr      TYPE zali_house_nr OBLIGATORY,
  p_plz     TYPE zali_postalcode     OBLIGATORY,
  p_city    TYPE zali_city     OBLIGATORY,
  p_email   TYPE zali_email   OBLIGATORY,
  p_phone   TYPE zali_phone_number.


DATA: ls_customer   TYPE          zali_customer,
      lv_nummerint  TYPE          i,
      lv_nummerchar TYPE          zali_kd_numr_de.

CONSTANTS: lc_range_nr TYPE inri-nrrangenr VALUE '01'.

CALL FUNCTION 'NUMBER_GET_NEXT'
  EXPORTING
    nr_range_nr = lc_range_nr
    object      = 'ZALI_CUSTO'
  IMPORTING
    number      = lv_nummerint
  EXCEPTIONS
    OTHERS      = 1.
IF sy-subrc <> 0.
  MESSAGE e001(zali_web_shop) .
ENDIF.

lv_nummerchar = lv_nummerint.

CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
  EXPORTING
    input  = lv_nummerchar
  IMPORTING
    output = lv_nummerchar.

ls_customer-customer_number = lv_nummerchar.
ls_customer-salutation = p_salut.
ls_customer-name = p_name.
ls_customer-first_name = p_fname.
ls_customer-street = p_street.
ls_customer-house_number = p_nr.
ls_customer-zip_code = p_plz.
ls_customer-city = p_city.
ls_customer-email = p_email.
ls_customer-telephone_number = p_phone.

CALL FUNCTION 'ZALI_ADD_CUSTOMER'
  EXPORTING is_customer = ls_customer.

CALL FUNCTION 'ZALI_SHOW_CUSTOMER_LIST'.
