FUNCTION ZALI_SHIPPING_ADRESS.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IO_ADDRESS_VIEW) TYPE REF TO  ZCL_ALI_ALTERNATIV_ADRESS
*"----------------------------------------------------------------------

go_address_view = io_address_view.
CALL SCREEN 9002.

ENDFUNCTION.
