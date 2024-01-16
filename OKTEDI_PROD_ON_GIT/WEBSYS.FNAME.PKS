CREATE OR REPLACE package WEBSYS.fname
as

procedure main(surl varchar2, msg in varchar2 default null);
procedure master(surl varchar2, void in integer);
procedure accept_new( surl in varchar2, p1 in varchar2, p2 in varchar2 );
procedure left_frame(surl varchar2, void in integer);
procedure right_frame(surl varchar2, void in integer, disp_style in varchar2 default LNG3.ADM_TXT_619, msg in varchar2 default null);
procedure accept_right_frame( surl in varchar2, void in integer, disp_style in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in varchar2 default 'F', action in varchar2 default null );
procedure acct_orders( surl varchar2, msg in varchar2 default null, acid in integer default null, force_logoff in varchar2 default 'F', other_logoff in varchar2 default null, footer_api in varchar2 default null, left_api in varchar2 default null, left_api_parm in varchar2 default null, ispopup in char default 'F' );
procedure goto_pay_merchant( surl varchar2, acid in integer);
procedure create_purchase_order( surl in varchar2, sess_id in integer, initial_status in varchar2, profid in integer, ltype in varchar2, cusrec in customer_account%ROWTYPE, voidrec in order_style%ROWTYPE, purch out purchase_order%ROWTYPE);
procedure process_purchase_order(surl in varchar2, sess_id in integer, profid in integer, ltype in varchar2, acid in integer, action in varchar2 default null, voidrec in order_style%ROWTYPE, cusrec in customer_account%ROWTYPE,
                                 img_arr in GLBX.MYARRAY, qty_arr in GLBX.MYARRAY, pbook_choice_arr in GLBX.MYARRAY, shopping_id_arr in GLBX.MYARRAY, quick_exit out boolean, check_just_added_package in boolean default TRUE );
procedure determine_price_book_display( surl in varchar2, acid in integer, voidrec in order_style%ROWTYPE, c1rec in customer_account%ROWTYPE, shop_rec in SHOPPING_BASKET%ROWTYPE, theme_rec in THEME_TYPES%ROWTYPE, callfrom in varchar2, ltype in varchar2, back2 in varchar2, backclr3 in varchar2, tmp out varchar2, tmp1 out varchar2, tmp2 out varchar2, is_local in boolean, umrec in UMO%ROWTYPE, workflow_tot in integer default 0, show_package_items in boolean default FALSE);
procedure accept_acct_order( surl varchar2, acid in integer, action in varchar2 default null, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, recalculate in varchar2 default null, empty in varchar2 default null, checkout in varchar2 default null, userfee in varchar2 default null );
procedure accept_free_images( surl varchar2, rsp1 in varchar2, acid in integer, msg in varchar2 default null );
procedure accept_order_page( surl in varchar2, acid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, action in varchar2 default null, order_return in varchar2 default null, payment in varchar2 default null );
procedure accept_pay_certificate( surl in varchar2, acid in integer, p1 in varchar2, p2 in varchar2 );
procedure cert_history( surl in varchar2, certid in varchar2, acid in integer );
procedure accept_purchase(surl in varchar2, paychoice in varchar2, acid in integer, p1 in varchar2 default null );
procedure purchase_audit_trail( surl in varchar2, vpoid in integer, colname in varchar2, vaction in char, vchange in char, newval in varchar2, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE );
procedure remove_item(surl in varchar2, shpid in varchar2, acid in integer );
procedure create_shopping_basket_item( shoprec in shopping_basket%ROWTYPE, action in varchar2 );

procedure accept_merchant(surl varchar2,sys_response_code in varchar2 default null, sys_response_text in varchar2 default null, sys_settlement_date in varchar2 default null, sys_rrn in varchar2 default null);
procedure accept_merchant_anz( surl varchar2, wrk in varchar2 default 'T', transactionDate in varchar2 default null, transactionTime in varchar2 default null, ordernumber in varchar2 default null, authorisationCode in varchar2 default null, responsecode in varchar2 default null, responseText in varchar2 default null,
                               amountPaid in varchar2 default null, transactionRef in varchar2 default null, orderDescription in varchar2 default null, cardname in varchar2 default null );
procedure accept_merchant_anz_ii( merchtxnref in varchar2 default null, orderinfo in varchar2 default null, merchantid in varchar2 default null, purchaseamountinteger in varchar2 default null, locale in varchar2 default null, receiptno in varchar2 default null, qsiresponsecode in varchar2 default null, acqresponsecode in varchar2 default null, transactiono in varchar2 default null, authorizeid in varchar2 default null, batchno in varchar2 default null, cardtype in varchar2 default null );
procedure accept_merchant_cbank(surl varchar2, wrk in varchar2 default 'T', responseText in varchar2 default null, authorisationCode in varchar2 default null, invoiceNumber in varchar2 default null,
                                amountPaid in varchar2 default null, transactionRef in varchar2 default null, surName in varchar2 default null );
procedure accept_merchant_nab(surl varchar2, wrk in varchar2 default 'T', responseText in varchar2 default null, authorisationCode in varchar2 default null, invoiceNumber in varchar2 default null,
                              amountPaid in varchar2 default null, transactionRef in varchar2 default null, surName in varchar2 default null, currency in varchar2 default null );
procedure accept_merchant_esec( surl varchar2,r in varchar2 default null, a in varchar2 default null, m in varchar2 default null, s in varchar2 default null );
procedure accept_merchant_safepay(SESSIONID in varchar2, MERCHANTID in varchar2, PURCHASEAMOUNT in varchar2, LOCALE in varchar2, RECEIPTNO in varchar2, TRANSACTIONNO in varchar2, ACQRESPONSECODE in varchar2, QSIRESPONSECODE in varchar2 );
procedure accept_merchant_securepay(wrk in varchar2 default 'T', ponum in varchar2 default null, amount in varchar2 default null, response_code in varchar2 default null, response_text in varchar2 default null, settle_date in varchar2 default null, txn_id in varchar2 default null, card_type in varchar2 default null, optional_info in varchar2 default null );
procedure accept_merchant_securebill(bill_id in varchar2 default 'T', field2 in varchar2 default null, approved in varchar2 default null, response in varchar2 default null, txn_id in varchar2 default null, receipt in varchar2 default null, amount in varchar2 default null, sett_date in varchar2 default null, card_type in varchar2 default null );
procedure accept_merchant_dp(surl varchar2, wrk in varchar2 default 'T' );
procedure accept_pay_by_credit( surl varchar2, CreditCardNumber in varchar2 default null, CreditCardType in varchar2 default null, ExpirationYear in varchar2 default null, ExpirationMonth in varchar2 default null, ExpirationDay in varchar2 default null, cc4 in varchar2 default null, HomeURL in varchar2 default null );
procedure disp_cust_details(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, browser_edit in varchar2, newline in out boolean, onecol in boolean);

procedure check_order( msg in varchar2 default null );
procedure accept_order_login( p1 in varchar2, p2 in varchar2 );
procedure disp_currency( surl varchar2, curr in varchar2 default null, acid in integer);
procedure cancel_order( surl varchar2, msg in varchar2 default null, acid in integer);
procedure confirm_cancel_order( surl varchar2,msg in varchar2 default null, acid in integer);

procedure confirm_payment( surl in varchar2, acid in integer, typ in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
procedure download_file(surl varchar2, v_umo in integer, purchid in integer, mthod in varchar2 DEFAULT 'ORIGINAL', acid in integer, shp in integer default null);
procedure login_account_first_stage( surl in varchar2, simplesearch in varchar2 default NULL, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null );
procedure accept_login_account_2_stage( surl in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, action in varchar2 default null, simplesearch in varchar2 default NULL, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null, image_accept in varchar2 default null, image_decline in varchar2 default null );

procedure purchase_method_screen_mfctr( surl in varchar2, vpoid in integer );
procedure accept_auth_payment( surl in varchar2, acid in integer default null, p1 in glbx.myarray, p2 in glbx.myarray, p3 in glbx.myarray, p4 in glbx.myarray, footer_api in varchar2 default null, left_api_parm in varchar2 default null );
procedure order_details( surl in varchar2, vpoid in integer, footer_api in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null, called_from in varchar2 default 'PREV', disp_close_window in char default 'F' );

procedure disp_payment_screen( surl in varchar2, acid in integer default null, msg in varchar2 default null, calltype in varchar2 default 'FULL' );
procedure confirm_purchase( surl in varchar2, acid in integer, action in varchar2 );
procedure merchant_goto( surl in varchar2, acid in integer );
/*
procedure accept_userfee_screen( surl varchar2, acid in integer, footer_api in varchar2, left_api in varchar2, left_api_parm in varchar2,
                                 pa1 in varchar2 default null, pa2 in varchar2 default null, pa3 in varchar2 default null, pa4 in varchar2 default null, pa5 in varchar2 default null, pa6 in varchar2 default null, pa7 in varchar2 default null, pa8 in varchar2 default null, pa9 in varchar2 default null, pa10 in varchar2 default null,
                                 pb1 in varchar2 default null, pb2 in varchar2 default null, pb3 in varchar2 default null, pb4 in varchar2 default null, pb5 in varchar2 default null, pb6 in varchar2 default null, pb7 in varchar2 default null, pb8 in varchar2 default null, pb9 in varchar2 default null, pb10 in varchar2 default null,
                                 pa11 in varchar2 default null, pa12 in varchar2 default null, pa13 in varchar2 default null, pa14 in varchar2 default null, pa15 in varchar2 default null, pa16 in varchar2 default null, pa17 in varchar2 default null, pa18 in varchar2 default null, pa19 in varchar2 default null, pa20 in varchar2 default null,
                                 pb11 in varchar2 default null, pb12 in varchar2 default null, pb13 in varchar2 default null, pb14 in varchar2 default null, pb15 in varchar2 default null, pb16 in varchar2 default null, pb17 in varchar2 default null, pb18 in varchar2 default null, pb19 in varchar2 default null, pb20 in varchar2 default null,
                                 return_back in varchar2 default null, continue in varchar2 default null, action in varchar2 default null);
*/
procedure accept_userfee_screen( num_entries in number, name_array in owa.vc_arr, value_array in owa.vc_arr, reserved in owa.vc_arr );

procedure show_customer_order( surl varchar2, cusrec in customer_account%rowtype, theme_rec in theme_types%rowtype, voidrec in order_style%rowtype, sess_id in integer, stype in integer, ltype in varchar2, pfx in THEME%ROWTYPE, acid in integer default null, browse_edit in varchar2, ord_exists out boolean, grand_ttl out number, newline in out boolean, override_width in varchar2 default null, retlink in varchar2 default null, pkg in integer default null, disable_show_total in boolean default FALSE, show_package_items in boolean default FALSE );
procedure customer_receipt(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null);
function cleanup_package( vpoid integer, vshopid integer ) return boolean;

end fname;

/
