FUNCTION ZALI_SHOW_ARTICLE_LIST.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"----------------------------------------------------------------------
    DATA: gr_alv TYPE REF TO cl_salv_table,
          gt_artc TYPE TABLE OF zali_article.


    SELECT * FROM zali_article
                INTO TABLE gt_artc.

    cl_salv_table=>factory(
        IMPORTING
            r_salv_table = gr_alv
        CHANGING
            t_table = gt_artc
    ).
    gr_alv->display( ).

ENDFUNCTION.
