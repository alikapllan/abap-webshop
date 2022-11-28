FUNCTION ZALI_ADD_ARTICLE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_ARTICLE) TYPE  ZALI_ARTICLE
*"----------------------------------------------------------------------
    INSERT zali_article FROM is_article.
    IF sy-subrc = 0.
      MESSAGE i006(zali_web_shop) WITH is_article-designation
                                       is_article-price
                                       is_article-article_number.
    ENDIF.

ENDFUNCTION.
