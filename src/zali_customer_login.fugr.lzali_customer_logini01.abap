*----------------------------------------------------------------------*
***INCLUDE LZALI_CUSTOMER_LOGINI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
go_login_view->login_screen_pai( EXPORTING iv_password = p_password iv_email = p_email ).
ENDMODULE.
