*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section

TYPES: BEGIN OF artikel_price,
       artikel_number TYPE zali_article_number,
       artikel_price TYPE zali_price,
       END OF artikel_price.

TYPES: ltt_artikel_price type STANDARD TABLE OF artikel_price WITH KEY artikel_number.
*TYPES: tty_ansicht TYPE STANDARD TABLE OF zali_s_bestellungen WITH DEFAULT KEY .
