CREATE OR REPLACE package body WEBSYS.fname

as

  NL_CHAR constant char(1) := chr(10);

  TYPE merchant_type IS RECORD
   (
    merchant_provider	varchar2(100),
    merchant_url	varchar2(1000),
    merchant_id		varchar2(1000),
    merchant_returl	varchar2(1000),
    popup 		varchar2(100),
    nobutton_page	varchar2(100)
   );

function is_bf( theme_rec in theme_types%ROWTYPE, ltype in varchar2, nmb1 in integer, nmb2 in integer, exp1 in char, exp2 in char, nmb3 in integer default null, exp3 in char default null ) return boolean;
function cust_button( pfx in THEME%ROWTYPE, gif in varchar2 ) return varchar2;
function translate_column( cname in varchar2 ) return varchar2;
function conv( val in varchar2 ) return varchar2;
function check_cntry( voidrec in order_style%rowtype, sess_id in integer ) return boolean;
function get_currency( cntry in varchar2 ) return varchar2;
function merchant_details( phgid in integer ) return merchant_type;
function get_purchase_order( sess_id in integer ) return purchase_order%ROWTYPE;
function indx( v_umo integer, pbook_choice_arr in GLBX.MYARRAY ) return integer;
function check_meta_tag( ppit in integer, v_umo in integer ) return boolean;
function check_exclusive( is_local in boolean , exclusive_local in integer, exclusive_int integer ) return boolean;
function work_details( shop_rec in SHOPPING_BASKET%ROWTYPE ) return varchar2;
function item_quantity( voidrec in order_style%ROWTYPE, ctr in integer, p3 in GLBX.MYARRAY, min_qty in integer ) return integer;
function getval( val in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY ) return varchar2;
function getcheck( val in varchar2, p3 in GLBX.MYARRAY ) return varchar2;
function find_acid(sess_id integer) return integer;
function download_exists( vpoid in integer ) return boolean;
function booking_order(vpoid integer) return boolean;
function find_store_item( price_book_id in integer, element_id in integer, shopid integer, voidrec in order_style%ROWTYPE, purch in purchase_order%ROWTYPE, phgrec in photographer%ROWTYPE, qty_arr in GLBX.MYARRAY, action in varchar2 ) return shopping_basket%ROWTYPE;
function format_name( txt in varchar2, pos in integer, voidrec in order_style%ROWTYPE, typ in varchar2 default 'SHOPPING' ) return varchar2;
function get_profile_username( purchord in purchase_order%ROWTYPE ) return varchar2;
function is_not_preorder( purchord in purchase_order%ROWTYPE ) return boolean;
function one_col( voidrec in order_style%ROWTYPE, nmb in integer ) return boolean;
function format_result( msg in varchar2, pfx in theme%ROWTYPE  ) return varchar2;
function return_link( surl in varchar2, stype in integer, ltype in varchar2, voidrec in order_style%ROWTYPE, pfx in theme%ROWTYPE, acid in integer, footer_api in varchar2 default null, left_api in varchar2 default null, left_api_parm in varchar2 default null, location in varchar2 default '1' ) return varchar2;
function user_fee_adjust_price( c1rec in user_fees%ROWTYPE, current_price in number ) return number;
function default_price( vspb in integer, ftype in varchar2, vppi out integer, pvsize out varchar2 ) return number;
function package_min(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype ) return boolean;
function check_prev_orders(purchid in integer, sess_id in integer, v_umo in integer) return integer;

procedure reset_order_style( surl in varchar2, phgid in integer, void in integer, style_name in varchar2 );
procedure most_popular_photos( surl in varchar2, acid in integer, phgid in integer, ltype in varchar2, pfx in theme%ROWTYPE, voidrec in order_style%ROWTYPE );
procedure customers_who_purchased( surl in varchar2, acid in integer, sess_id in integer, ltype in varchar2, pfx in theme%ROWTYPE, voidrec in order_style%ROWTYPE );

procedure show_cc_facility( surl in varchar2, acid in integer, profid in integer, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, ltype in varchar2, isproblem in boolean, pfx in theme%rowtype );
procedure show_phone_facility( surl in varchar2, acid in integer, profid in integer, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, ltype in varchar2, isproblem in boolean, pfx in theme%rowtype );
procedure show_cheque_facility( surl in varchar2, acid in integer, profid in integer, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, ltype in varchar2, isproblem in boolean, pfx in theme%rowtype );
procedure show_gift_facility( surl in varchar2, acid in integer, profid in integer, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, ltype in varchar2, isproblem in boolean, pfx in theme%rowtype );
procedure show_auth_facility( surl in varchar2, acid in integer, profid in integer, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, ltype in varchar2, isproblem in boolean, pfx in theme%rowtype );
procedure show_billing_facility( surl in varchar2, acid in integer, profid in integer, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, ltype in varchar2, isproblem in boolean, pfx in theme%rowtype );
procedure show_free_images( surl in varchar2, acid in integer, profid in integer, purch in purchase_order%ROWTYPE, cusrec in customer_account%rowtype, voidrec in order_style%ROWTYPE, ltype in varchar2, isproblem in boolean, pfx in theme%rowtype );
procedure show_problems_facility( surl in varchar2, acid in integer, profid in integer, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, ltype in varchar2, pfx in theme%rowtype );

procedure store_item( price_book_id in integer, element_id in integer, shopid integer, voidrec in order_style%ROWTYPE, purch in purchase_order%ROWTYPE, phgrec in photographer%ROWTYPE, qty_arr in GLBX.MYARRAY, action in varchar2 );
procedure price_book_item( id in integer, element_id in integer, shopid integer, voidrec in order_style%ROWTYPE, purch in purchase_order%ROWTYPE, cusrec in customer_account%ROWTYPE, pbook_choice_arr in GLBX.MYARRAY, phgrec in photographer%ROWTYPE, qty_arr in GLBX.MYARRAY, action in varchar2 );
procedure calc_due_date( vpoid in integer );
procedure new_item( id in integer, element_id in integer, shopid integer, voidrec in order_style%ROWTYPE, purch in purchase_order%ROWTYPE, cusrec in customer_account%ROWTYPE, pbook_choice_arr in GLBX.MYARRAY, phgrec in photographer%ROWTYPE, qty_arr in GLBX.MYARRAY, action in varchar2 );
procedure update_item( id in integer, element_id in integer, shopid integer, voidrec in order_style%ROWTYPE, purch in purchase_order%ROWTYPE, cusrec in customer_account%ROWTYPE, pbook_choice_arr in GLBX.MYARRAY, phgrec in photographer%ROWTYPE, qty_arr in GLBX.MYARRAY, action in varchar2 );
procedure process_data_entered( surl in varchar2, pfx in theme%ROWTYPE, acid in integer, ltype in varchar2, profid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, cusrec in customer_account%rowtype, purchord in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, action in varchar2, result out varchar2 );

procedure disp_tracing_style( surl in varchar2, stype in integer, voidrec in order_style%rowtype, pfx in theme%ROWTYPE, purchord in purchase_order%ROWTYPE, at_step in varchar2, acid in integer, ltype in varchar2, theme_rec in theme_types%ROWTYPE );
procedure disp_order_page(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, msg in varchar2 default null, bypass in boolean default FALSE );
procedure disp_payment_page(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, msg in varchar2 default null, calltype in varchar2 default 'FULL' );
procedure disp_order_summary(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, browser_edit in varchar2, newline in out boolean, override_width in varchar2 default null );
procedure disp_additional_options(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, browser_edit in varchar2, newline in out boolean );
procedure disp_order_tracking(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, browser_edit in varchar2, newline in out boolean );
procedure disp_shipping(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, browser_edit in varchar2, newline in out boolean );
procedure disp_payment_method(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, browser_edit in varchar2, newline in out boolean );
procedure disp_postage_details(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, browser_edit in varchar2, newline in out boolean );
procedure disp_confirm_page(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, msg in varchar2 default null );
procedure disp_order_total_details(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, browser_edit in varchar2, newline in out boolean );
procedure display_column(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, msg in varchar2, colnum in integer, colval varchar2, edit_browse in varchar2, newline in out boolean, onecol in boolean);

procedure pay_certificate( surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null);
procedure pay_phone(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null);
procedure pay_cheque(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null);
procedure pay_authorisation(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null);
procedure pay_billing(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null);

procedure check_business_hours( surl varchar2, acid in integer, crec in photographer%ROWTYPE, voidrec in order_style%ROWTYPE );
procedure list_downloadable( surl varchar2, prec in purchase_order%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, voidrec in order_style%ROWTYPE, acid in integer );
procedure htp_bfile( vfname in varchar2, rpc in varchar2 );
procedure recalc_order(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, inpopup in char default null );

procedure confirm_cheque(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null);
procedure finalise_payment(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null);
procedure failed_credit_card(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null);
procedure adjust_purchase_table(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null);
procedure email_details(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null);
procedure mark_exclusive(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null);
procedure configure_for_b2c(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null);
procedure adjust_stock(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null);
procedure initialise_workflow( surl in varchar2, vpoid in integer );
procedure calculate_delivery_time( surl in varchar2, vpoid in integer, purch in purchase_order%ROWTYPE );
procedure calc_booking( vpoid in integer );

procedure auto_configure_tracking( purchord in out purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE );
procedure login_account_second_stage(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, msg in varchar2 default null, simplesearch in varchar2 default NULL, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null );
procedure login_account_final_stage( surl in varchar2, ltype in varchar2, simplesearch in varchar2 default NULL, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null );
procedure display_order_tracking( pfx in theme%ROWTYPE, purchord in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, override_width in varchar2 default null );
procedure display_new_account( pfx in theme%ROWTYPE, un in varchar2, pw in varchar2, override_width in varchar2 default null, msg in varchar2 );
procedure setup_new_account(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype );
procedure check_mandatory(action in varchar2, check_col in char, voidrec in order_style%ROWTYPE, purchrec in purchase_order%ROWTYPE, pfx in theme%ROWTYPE, result in out varchar2 );
procedure smart_check( purchord in purchase_order%ROWTYPE, pfx in theme%ROWTYPE, result in out varchar2 );
procedure check_credit_already_done( vpoid integer );
procedure add_poid_values( vpoid in integer, gcode in out NOCOPY GLBX.MYARRAY, gparam in out NOCOPY GLBX.MYARRAY );

procedure external_html_file(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, msg in varchar2 default null, simplesearch in varchar2 default NULL, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null );
procedure login_account_second_stage_int(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, msg in varchar2 default null, simplesearch in varchar2 default NULL, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null, disptitle in boolean );
procedure user_fee_categories( shoprec in shopping_basket%ROWTYPE, voidrec in order_style%ROWTYPE, p_code in out NOCOPY GLBX.MYARRAY, p_category in out NOCOPY GLBX.MYARRAY, p_default in out NOCOPY GLBX.MYARRAY, p_newprice in out NOCOPY GLBX.MYARRAY_NMB );
procedure user_fee_adjust_default( ltype in varchar2, profid in integer, cusrec in customer_account%ROWTYPE, voidrec in order_style%ROWTYPE, purchord in purchase_order%ROWTYPE, shoprec in shopping_basket%ROWTYPE, p_code in GLBX.MYARRAY, p_default in out NOCOPY GLBX.MYARRAY);
procedure userfee_screen( surl varchar2, msg in varchar2 default null, acid in integer default null, footer_api in varchar2 default null, left_api in varchar2 default null, left_api_parm in varchar2 default null,
                          sess_id in integer, ltype in varchar2, stype in integer, profid in integer, voidrec in ORDER_STYLE%ROWTYPE, pfx in THEME%ROWTYPE, purchord in PURCHASE_ORDER%ROWTYPE, theme_rec in THEME_TYPES%ROWTYPE, cusrec CUSTOMER_ACCOUNT%ROWTYPE, changeitems in boolean default FALSE);
procedure add_opt_combo( slc in varchar2, display_text in varchar2, display_prices in varchar2, opt in varchar2 default null, adj_price in number default 1 );
procedure check_package_add(surl in varchar2, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE );
procedure check_package_justadded(surl in varchar2, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, exit_call out integer, pkg out integer );
procedure phg_order_initialise( sess_id in integer, profid out integer, cusrec out customer_account%ROWTYPE, pfx out theme%ROWTYPE, theme_rec out theme_types%ROWTYPE, purchord out purchase_order%ROWTYPE, voidrec out order_style%ROWTYPE );
procedure display_phg_order_button( surl in varchar2, sess_id in integer );
procedure cheque_fax_details(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, phgrec in photographer%ROWTYPE );
procedure adjust_postage( vpurchrec in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, subtotal in number );

procedure main(surl varchar2, msg in varchar2 default null)
as

 cursor c1(phgid integer) is select name,is_default,oid,date_created,date_updated from order_style where pid = phgid order by decode(is_default,'T',0,1),name;
 cursor c2 is select distinct template_name from order_style_template;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FNAME.MAIN', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG5.EXT_TXT_251, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P67',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg );end if;
  htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_249 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG2.PBK_TXT_024 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.GLB_TXT_078 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG5.EXT_TXT_250 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;
  for c1rec in c1(owner_id) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'fname.master?surl=' || glbx.rndsurl(surl) || '&void=' || c1rec.oid, nvl(initcap(c1rec.name),LNG3.ADM_TXT_351)), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    if c1rec.is_default = 'T'
     then
      htp.tabledata( LNG.PHG_TXT_045,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      htp.tabledata( LNG.PHG_TXT_046,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
    htp.tabledata( to_char(c1rec.date_created,LNG.TSMASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(c1rec.date_updated,LNG.TSMASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.nl;
  htp.formopen( 'fname.accept_new' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl) );
  htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_249 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.formtext( 'P1', 30, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_252 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P2' );
      htp.formselectoption( LNG5.EXT_TXT_253,'SELECTED', cattributes=>'VALUE="DEFAULT"' );
      for c2rec in c2 loop
       htp.formselectoption( c2rec.template_name,'SELECTED' );
      end loop;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.formsubmit( null, 'Create New Order Style' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;
  htp.tableclose;
  htp.formclose;
  htp.nl;
  htp.p( '</CENTER>' );
  htp.formclose;
exception when others then
 glbx.error_details( 'FNAME', 'MAIN', errmsg=>sqlerrm);
end main;

function is_bf( theme_rec in theme_types%ROWTYPE, ltype in varchar2, nmb1 in integer, nmb2 in integer, exp1 in char, exp2 in char, nmb3 in integer default null, exp3 in char default null )
 return boolean
as
begin
  if ltype = 'PHOTOGRAPHER' and nmb3 is null then return( FALSE ); end if;

  if ((substr(theme_rec.theme_data,nmb1,1) = exp1) and ltype in ('OWNER','PROFILE')) or
     ((substr(theme_rec.theme_data,nmb2,1) = exp2) and ltype in ('CUSTOMER','PROFILEG')) or
     ((substr(theme_rec.theme_data,nmb3,1) = exp3) and ltype = 'PHOTOGRAPHER')
   then
     return( TRUE );
  end if;
  return( FALSE );
end is_bf;

function cust_button( pfx in THEME%ROWTYPE, gif in varchar2 )
 return varchar2
as
begin
 if pfx.separate_customer_bt = 'F'
  then
   return( DECS.IMAGE_LOCATION || 'adminc/' || gif );
  else
   return( DECS.IMAGE_LOCATION || pfx.disp_prefix || gif );
 end if;
end cust_button;

procedure accept_new( surl in varchar2, p1 in varchar2, p2 in varchar2 )
as

 cursor c1( phgid integer, nme varchar2 ) is select count('x') tot from order_style where pid = phgid and name = nme;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 newid		integer;
 tot		integer;
 sts		varchar2(100);

begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FNAME.ACCEPT_NEW', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if p1 is null
   then
    main( surl, LNG5.EXT_TXT_257 );
    return;
  end if;

  open c1(owner_id, upper(p1));
  fetch c1 into tot;
  close c1;

  if tot > 0
   then
    main( surl, LNG5.EXT_TXT_258 || ': ' || p1 );
    return;
  end if;

  select s_order_style.nextval into newid from dual;

  insert into order_style(oid,pid,is_default,date_created,date_updated,name)
   values
    (newid,owner_id,'F',sysdate,sysdate,upper(p1));
  commit;

  reset_order_style( surl, owner_id, newid, nvl(p2,'DEFAULT') );
  update order_style set name = upper(p1) where oid = newid;
  commit;

  master( surl, newid );

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_NEW', errmsg=>sqlerrm, extdet=>'P1:' || p1);
end accept_new;

procedure reset_order_style( surl in varchar2, phgid in integer, void in integer, style_name in varchar2 )
as

 cursor c2(phgid integer) is select theme_data from theme_types where theme_type in (select theme_type from photographer where pid = phgid);
 cursor c3(phgid integer) is select photographer_title from photographer where pid = phgid;
 cursor c4(tname varchar2) is select * from order_style_template where template_name = tname;

 c1rec		order_style%ROWTYPE;
 c2rec		c2%ROWTYPE;
 phg_title	varchar2(100);

begin

 -- Need to fill these in to setup the defaults correctly
 c1rec.payment_cc_text := glbx.extract_master_parameter('MERCHANT_TEXT');
 -- Add More Intelligent Check Here.
 if substr(c2rec.theme_data,372,1) = 'T'
  then
   c1rec.payment_gift := 'T';
  else
   c1rec.payment_gift := 'F';
 end if;
 open c3(phgid);
 fetch c3 into phg_title;
 close c3;

 if style_name = 'DEFAULT'
  then

   update order_style
    set
     bftr                           	   = 'Use Customer Account Business Feature',
     laf                            	   = 'Use Customer Account Look and Feel',
     residing_country               	   = 'AUSTRALIA',
     currency_to_use                	   = 'AUSTRALIA',
     payment_display_style 		   = '1',
     payment_problems_def           	   = 'PHONE',
     payment_display_gif            	   = 'T',
     payment_can_cancel_noncc		   = 'T',
     payment_b2c			   = 'F',
     payment_cc                     	   = 'F',
     payment_cc_text                	   = c1rec.payment_cc_text,
     payment_cc_international		   = 'T',
     payment_cc_down_only 		   = 'T',
     payment_cheque                 	   = 'T',
     payment_cheque_text            	   = LNG2.FNM_TXT_124,
     payment_billing                	   = 'F',
     payment_billing_text           	   = LNG4.AHC_TXT_732,
     payment_phone                  	   = 'T',
     payment_phone_text             	   = LNG.ORD_TXT_175,
     payment_phone_ring             	   = 'T',
     payment_auth                   	   = 'F',
     payment_auth_text              	   = LNG4.AHC_TXT_687,
     payment_auth_project_code      	   = 'F',
     payment_gift                   	   = c1rec.payment_gift,
     payment_gift_text              	   = LNG4.AHC_TXT_688,
     payment_free		    	   = 'F',
     payment_free_text		    	   = LNG5.EXT_TXT_256,
     pricing_ship_local             	   = 0,
     pricing_ship_int               	   = 0,
     pricing_expr_local             	   = 0,
     pricing_expr_int               	   = 0,
     pricing_discount               	   = 0,
     pricing_discount_stage  		   = 'S',
     pricing_disc_if_gtr            	   = 0,
     pricing_min_amt                	   = 0,
     pricing_max_amt                	   = 99999,
     pricing_max_qty                	   = 99,
     pricing_gst			   = 0,
     pricing_gst_int_sales		   = 'T',
     pricing_gst_text			   = 'GST',
     pricing_postage_included	   	   = 'F',
     pricing_express_included		   = 'F',
     pricing_offer_manual_ship             = 'F',
     pricing_internal			   = 'F',
     packaged_product_display		   = 'Packaged Product',
     text_manual_ship                      = 'Free Shipping if you pick it up yourself',
     pricing_postage_text		   = 'Postage and Handling',
     pricing_surcharge_text		   = 'Surcharge',
     disp_remove_style			   = 'C',
     disp_gift_wrap                 	   = 'T',
     disp_gift_wrap_col             	   = '1',
     disp_ord_trk                   	   = 'T',
     disp_auto_create_tracking		   = 'F',
     disp_ord_trk_col               	   = '1',
     disp_ord_trk_expire_at	    	   = 'N',
     disp_ord_trk_expire_date	    	   = NULL,
     disp_ord_trk_expire_status	    	   = NULL,
     disp_cust_col			   = '1',
     disp_payment_method_col		   = '0',
     disp_ord_summ                  	   = 'T',
     disp_ord_summ_col              	   = '1',
     disp_ord_summ_matte		   = 'F',
     disp_postage_col		   	   = '0',
     disp_cust				   = 'T',
     disp_payment_method		   = 'T',
     disp_postage			   = 'T',
     disp_shipping			   = 'T',
     disp_total				   = 'T',
     disp_total_col		 	   = '0',
     disp_recent                    	   = 'T',
     disp_recent_nmb                	   = 5,
     disp_most_pop                  	   = 'T',
     disp_most_pop_nmb              	   = 5,
     disp_recent_frame            	   = 'F',
     disp_recent_top            	   = 'F',
     disp_most_frame            	   = 'F',
     disp_most_top	            	   = 'F',
     disp_show_currency             	   = 'T',
     disp_show_convert              	   = 'F',
     disp_goto_order_pge            	   = 'F',
     disp_cntry_fnl_pge             	   = 'F',
     disp_receipt                   	   = 'F',
     disp_receipt_print             	   = 'F',
     disp_auto_create_on_purchase	   = 'F',
     disp_prompt_create_acct	           = 'F',
     disp_email_customer            	   = 'T',
     disp_email_phg                 	   = 'T',
     disp_gift_wrap_col2		   = '1',
     disp_ord_trk_col2			   = '1',
     disp_cust_col2		           = '1',
     disp_payment_method_col2	   	   = '1',
     disp_ord_summ_col2		   	   = '1',
     disp_postage_col2		           = '1',
     disp_total_col2		 	   = '1',
     download_original_any_time		   = 'F',
     download_web_any_time	   	   = 'F',
     download_original_on_purchase  	   = 'F',
     download_web_on_purchase	  	   = 'F',
     download_email_free		   = 'F',
     columns_mark_ast			   = 'F',
     columns_mark_bold			   = 'T',
     columns_mark_italic		   = 'F',
     columns_display                	   = 'TTTTTTTTTTFF',
     columns_mandatory              	   = 'TTFTFTTFFFFF',
     columns_on_login			   = 'FFFFFFFFFFFT',
     columns_name			   =  LNG.PHG_TXT_084,
     columns_firstname			   =  'First Name',
     columns_lastname			   =  'Last Name',
     columns_name_toggle		   =  'T',
     columns_street			   =  LNG.PHG_TXT_239,
     columns_suburb		   	   =  LNG.PHG_TXT_101,
     columns_city			   =  LNG.PHG_TXT_102,
     columns_postcode			   =  LNG.PHG_TXT_104,
     columns_state			   =  'State',
     columns_branch			   =  'Branch',
     columns_department			   =  'Department',
     columns_country			   =  LNG.PHG_TXT_103,
     columns_phone			   =  LNG.PHG_TXT_096,
     columns_email			   =  LNG.PHG_TXT_301,
     columns_comment			   =  LNG4.AHC_TXT_113,
     columns_split			   =  LNG4.AHC_TXT_772,
     workflow_cc_start              	   = 'Ordered',
     workflow_cc_mfctr              	   = 'Ordered',
     workflow_cc_delivery           	   = 'Ordered',
     workflow_cheque_start          	   = 'Ordered',
     workflow_cheque_mfctr          	   = 'Ordered',
     workflow_cheque_delivery       	   = 'Ordered',
     workflow_billing_start         	   = 'Ordered',
     workflow_billing_mfctr         	   = 'Ordered',
     workflow_billing_delivery      	   = 'Ordered',
     workflow_phone_start           	   = 'Ordered',
     workflow_phone_mfctr           	   = 'Ordered',
     workflow_phone_delivery        	   = 'Ordered',
     workflow_auth_start            	   = 'Ordered',
     workflow_auth_mfctr            	   = 'Ordered',
     workflow_auth_delivery         	   = 'Ordered',
     tracing_style_api			   = NULL,
     download_auto_email_web	           = 'F',
     pricing_nopostage_if_zero		   = 'F',
     disp_popup				   = 'F',
     disp_border			   = 'F',
     disp_show_tnail_on_receipt            = 'F',
     disp_tracking_ctr                     = 'F',
     download_prompt_details		   = 'F',
     columns_email_unique		   = 'F',
     columns_smart_check		   = 'F',
     disp_email_is_username		   = 'F',
     text_checkout_button		   = LNG.CST_BUT_127,
     text_image_title			   = LNG.CST_TXT_132,
     text_thumbnail 			   = 'Thumbnail',
     text_print_cheque 			   = LNG2.FNM_TXT_125,
     text_qty 				   = LNG.CST_TXT_135,
     text_subtotal_title		   = LNG.CST_TXT_136,
     text_most_popular			   = LNG.PHG_TXT_435,
     text_recent_purchased	 	   = LNG.ORD_TXT_224,
     text_logon_title		  	   = 'Account Login Details',
     text_accept			   = 'Accept',
     text_decline			   = 'Decline',
     text_recalculate_button		   = LNG.CST_BUT_126,
     text_on_empty_basket		   = LNG.CST_TXT_137,
     text_logoff			   = LNG.CST_ALT_021,
     text_userfee			   = 'User Fees',
     text_empty_basket_button		   = LNG4.AHC_TXT_286,
     text_unsolicited_email	 	   = 'I do not want my email address to be used for unsolicited email',
     text_delayed_pricing           	   = 'Prices are valid until date' || ':',
     text_alt_price_book            	   = 'New pricing now applies',
     text_purch_warning             	   = 'Please note that this cost does include local Shipping and GST.',
     text_phg_title                 	   = NULL,
     text_help_shopping             	   = 'Enter in the Order Quantity and Photo Order Size.',
     text_help_purchase             	   = 'To purchase this Order press the Purchase Button and an order form will appear',
     text_help_purchase2             	   = 'To purchase this Order press the Purchase Button and an order form will appear',
     text_cancel_msg		           = LNG.ORD_TXT_061 || htf.nl || LNG.ORD_TXT_069 || htf.nl || LNG.ORD_TXT_070,
     text_onlogout_itm              	   = 'You still have items in your shopping basket. Do you wish to purchase them?',
     text_privacy			   = 'Contact Details are only used for Administrative Purposes',
     text_disclaimer		           = '<B>IMAGE COPYRIGHT.<BR>READ THIS NOTICE PLEASE.<BR></B>The Photographer: The Photographer holds the Copyright for all images on this web site.<BR><BR>BECAUSE YOU MAY APPEAR IN AN IMAGE ON THIS SITE PLEASE DO NOT ASSUME YOU OWNTHE COPYRIGHT TO COPY, USE, DUPLICATE, DOWNLOAD OR IMPLICATE THESE IMAGES IN ANY FORM WITHOUT CONSULTATION FROM THE PHOTOGRAPHER FIRST.',
     tracing_style 			   = 'None',
     columns_mandatory_on_login 	   = 'FFFFFFFFFFFF',
     text_min_max_reached 		   = 'Order cannot proceed as minimum order amount has not been reached or maximum amount has been reached',
     text_phone_message 		   = replace(LNG.CST_TXT_102,'<PHOTOGRAPHER>',phg_title),
     use_default_if_no_price		   = 'T',
     pricing_gst_inclusive		   = 'F',
     pricing_postage_text_col		   = 'Standard Postage',
     pricing_express_text_col		   = 'Express Postage',
     disp_payment_method_alt		   = 'F',
     disp_graphic_button	 	   = 'F',
     disp_gift_wrap_col3		   = '0',
     disp_ord_trk_col3			   = '0',
     disp_cust_col3			   = '0',
     disp_payment_method_col3		   = '0',
     disp_ord_summ_col3			   = '0',
     disp_postage_col3			   = '0',
     disp_total_col3			   = '1',
     disp_shipping_col			   = '1',
     disp_shipping_col2			   = '0',
     disp_shipping_col3			   = '0',
     disp_gift_wrap_order		   = 8,
     disp_ord_trk_order			   = 7,
     disp_cust_order			   = 4,
     disp_payment_method_order		   = 2,
     disp_ord_summ_order		   = 3,
     disp_postage_order			   = 6,
     disp_shipping_order		   = 5,
     disp_total_order			   = 1,
     disp_gift_wrap_title		   = 'Purchase Options',
     disp_ord_trk_title			   = NULL,
     disp_cust_title			   = NULL,
     disp_payment_method_title		   = NULL,
     disp_ord_summ_title		   = NULL,
     disp_postage_title			   = NULL,
     disp_shipping_title		   = NULL,
     disp_total_title			   = NULL,
     text_page0				   = 'User Fees',
     text_page1				   = 'Shopping Basket',
     text_page2				   = 'Contact Details',
     text_page3				   = 'Select Payment',
     text_page4				   = 'Payment',
     text_page5				   = 'Receipt',
     text_cancel_order			   = 'Create New Order',
     text_shopping_basket	   	   = 'Shopping Basket',
     text_subtotal			   = 'Sub Total',
     text_grandtotal			   = 'Grand Total',
     text_home1				   = 'Home',
     text_home2				   = 'Home',
     payment_display_all_as_butt	   = 'F',
     disp_purch_request_heading		   = 'T',
     columns_swap_pay_confirm		   = 'F',
     payment_cheque_noconfirm		   = 'T',
     payment_cheque_button_loc		   = 'T',
     columns_simple_address		   = 'F',
     columns_update_contact		   = 'T',
     text_purchase_request		   = LNG.CST_TXT_099,
     text_return_button			   = 'Return to the ' || text_shopping_basket,
     text_proceed_button		   = 'Proceed to the Payment Screen',
     text_remove_from			   = LNG.CST_TXT_125,
     text_confirm_button		   = LNG.ORD_TXT_039,
     text_message_under_total		   = NULL,
     text_title_merchant 		   = 'Credit Card',
     text_title_authorisation 		   = 'Authorisation',
     text_title_cheque 			   = 'Cheque',
     text_title_phone 			   = 'Phone',
     text_title_gift			   = 'Gift Certificate',
     text_title_billing 		   = 'Billing',
     text_title_free 		   	   = 'Free Download',
     text_cc_message			   = 'Pay by Credit Card',
     text_cheque_message		   = 'Pay by Cheque',
     text_phone_message_but		   = 'Pay by Phone',
     text_auth_message			   = 'Pay by Authorisation',
     text_billing_message		   = 'Pay by Billing',
     text_free_message			   = 'Free Images',
     text_local_charge			   = 'Local Charge',
     text_international_charge		   = 'International Charge',
     text_order_problem			   = 'If you have any problems then please ring',
     uf_enabled			   	   = 'F',
     uf_display_progress_bar		   = 'F',
     uf_display_price			   = 'F',
     uf_image_position			   = 'L',
     uf_display_matte			   = 'F',
     uf_display_image_name		   = 'T',
     uf_show_continue_gif		   = 'F',
     uf_show_return_gif			   = 'F',
     uf_display_additional_img		   = 'F',
     uf_specify_in_image		   = 'F',
     uf_bl_enable_default		   = 'T',
     uf_bl_locked_fee			   = 'F',
     uf_bl_onnew_def_last		   = 'F',
     uf_bl_onnew_nodisplay		   = 'F',
     uf_bl_cust_can_change		   = 'T',
     uf_bl_enable_combo_box		   = 'F',
     uf_bl_enable_prepricing		   = 'F',
     uf_bl_remember_over_session	   = 'F',
     uf_bl_turf_duplicates		   = 'F',
     uf_text_header			   = 'User Fees',
     uf_instruction_text		   = NULL,
     uf_error_no_default		   = 'Must Specify a User Fee Category',
     uf_continue_text			   = 'Continue',
     uf_return_text			   = 'Return',
     fax_merchant_enabled		   = 'F',
     fax_merchant_border		   = 'F',
     fax_merchant_box_dotted		   = 'B',
     fax_merchant_text_above	           = 'Please charge my credit card for the amount',
     fax_merchant_text_below	           = 'Please fax this completed form to',
     text_merchant_warning		   = 'After the Merchant Details have been entered, some Browsers will Display a message about accessing a non-secure site. Ignore this message and press <B>Yes</B> to return and display the Receipt Page.',
     disp_sep_post_surcharge   		   = 'F',
     text_surcharge	   		   = 'Surcharge'
  where
    oid = void and
    pid = phgid;

  else

   for c4rec in c4(style_name) loop
   begin
    execute immediate 'update order_style set ' || c4rec.template_column || ' = :1 where oid = :2 and pid = :3'
     using c4rec.template_value, void, phgid;
   exception
    when others then null;
   end;
   end loop;

  end if;

 commit;

end reset_order_style;

procedure master(surl varchar2, void in integer)
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'FNAME.MASTER', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  htp.htmlopen;
  htp.framesetopen('100%',glbx.sctrl(glbx.fndtheme( owner_id ),'CST_INNER_FRAME_SIZE',stype),cattributes=>'frameborder="1" framespacing="0" border="1"');
   htp.frame( 'fname.left_frame?surl=' || glbx.rndsurl(surl) || '&void=' || void,'ORDER_LEFT');
   htp.frame( 'fname.right_frame?surl=' || glbx.rndsurl(surl) || '&void=' || void,'ORDER_RIGHT');
  htp.framesetclose;
  htp.noframesopen;
   glbx.noframe(surl,'FNM.MASTER');
  htp.noframesclose;
  htp.htmlclose;

exception when others then
 glbx.error_details( 'FNAME', 'MASTER', errmsg=>sqlerrm);
end master;

procedure left_frame(surl varchar2, void in integer)
as

 cursor c1(phgid integer) is select * from theme_types where theme_type in (select theme_type from photographer where pid = phgid );

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	THEME_TYPES%ROWTYPE;

begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FNAME.LEFT_FRAME', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  htp.htmlopen;

  pfx := glbx.photo_lf(owner_id);
  open c1(owner_id);
  fetch c1 into theme_rec;
  close c1;
  glbx.main_title( surl, null, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P68',stype=>greatest(stype-1,1),sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.bold( 'Options' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  ctr := 0;
   htp.tablerowopen;
    ctr := ctr + 1;
    htp.tabledata( to_char(ctr) || '. ' || htf.anchor2( 'fname.right_frame?surl=' || surl || '&void=' || void || '&disp_style=' || replace(LNG.GLB_TXT_066,' ','+'),LNG.GLB_TXT_066,ctarget=>'ORDER_RIGHT'),cattributes=>'CLASS="SMALL"' );
   htp.tablerowclose;
   htp.tablerowopen;
    ctr := ctr + 1;
    htp.tabledata( to_char(ctr) || '. ' || htf.anchor2( 'fname.right_frame?surl=' || surl || '&void=' || void || '&disp_style=' || replace(LNG5.EXT_TXT_259,' ','+'),LNG5.EXT_TXT_259,ctarget=>'ORDER_RIGHT'),cattributes=>'CLASS="SMALL"' );
   htp.tablerowclose;
   -- xxx language file
   if substr(theme_rec.theme_data,369,1) = 'T'
    then
     htp.tablerowopen;
      ctr := ctr + 1;
      htp.tabledata( to_char(ctr) || '. ' || htf.anchor2( 'fname.right_frame?surl=' || surl || '&void=' || void || '&disp_style=' || replace('User Fees',' ','+'),'User Fees',ctarget=>'ORDER_RIGHT'),cattributes=>'CLASS="SMALL"' );
     htp.tablerowclose;
   end if;
   htp.tablerowopen;
    ctr := ctr + 1;
    htp.tabledata( to_char(ctr) || '. ' || htf.anchor2( 'fname.right_frame?surl=' || surl || '&void=' || void || '&disp_style=' || replace(LNG5.EXT_TXT_260,' ','+'),LNG5.EXT_TXT_260,ctarget=>'ORDER_RIGHT'),cattributes=>'CLASS="SMALL"' );
   htp.tablerowclose;
   htp.tablerowopen;
    ctr := ctr + 1;
    htp.tabledata( to_char(ctr) || '. ' || htf.anchor2( 'fname.right_frame?surl=' || surl || '&void=' || void || '&disp_style=' || replace('Purchase Options',' ','+'),'Purchase Options',ctarget=>'ORDER_RIGHT'),cattributes=>'CLASS="SMALL"' );
   htp.tablerowclose;
   htp.tablerowopen;
    ctr := ctr + 1;
    htp.tabledata( to_char(ctr) || '. ' || htf.anchor2( 'fname.right_frame?surl=' || surl || '&void=' || void || '&disp_style=' || replace(LNG2.PBK_TXT_128,' ','+'),LNG2.PBK_TXT_128,ctarget=>'ORDER_RIGHT'),cattributes=>'CLASS="SMALL"' );
   htp.tablerowclose;
   htp.tablerowopen;
    ctr := ctr + 1;
    htp.tabledata( to_char(ctr) || '. ' || htf.anchor2( 'fname.right_frame?surl=' || surl || '&void=' || void || '&disp_style=' || replace(LNG5.EXT_TXT_261,' ','+'),LNG5.EXT_TXT_261,ctarget=>'ORDER_RIGHT'),cattributes=>'CLASS="SMALL"' );
   htp.tablerowclose;
   htp.tablerowopen;
    ctr := ctr + 1;
    htp.tabledata( to_char(ctr) || '. ' || htf.anchor2( 'fname.right_frame?surl=' || surl || '&void=' || void || '&disp_style=' || replace(LNG5.EXT_TXT_406,' ','+'),LNG5.EXT_TXT_406,ctarget=>'ORDER_RIGHT'),cattributes=>'CLASS="SMALL"' );
   htp.tablerowclose;
   htp.tablerowopen;
    ctr := ctr + 1;
    htp.tabledata( to_char(ctr) || '. ' || htf.anchor2( 'fname.right_frame?surl=' || surl || '&void=' || void || '&disp_style=' || replace(LNG5.EXT_TXT_262,' ','+'),LNG5.EXT_TXT_262,ctarget=>'ORDER_RIGHT'),cattributes=>'CLASS="SMALL"' );
   htp.tablerowclose;
   htp.tablerowopen;
    ctr := ctr + 1;
    htp.tabledata( to_char(ctr) || '. ' || htf.anchor2( 'fname.right_frame?surl=' || surl || '&void=' || void || '&disp_style=' || replace(LNG5.EXT_TXT_405,' ','+'),LNG5.EXT_TXT_405,ctarget=>'ORDER_RIGHT'),cattributes=>'CLASS="SMALL"' );
   htp.tablerowclose;
   htp.tablerowopen;
    ctr := ctr + 1;
    htp.tabledata( to_char(ctr) || '. ' || htf.anchor2( 'fname.right_frame?surl=' || surl || '&void=' || void || '&disp_style=' || replace(LNG5.EXT_TXT_263,' ','+'),LNG5.EXT_TXT_263,ctarget=>'ORDER_RIGHT'),cattributes=>'CLASS="SMALL"' );
   htp.tablerowclose;
   htp.tablerowopen;
    ctr := ctr + 1;
    htp.tabledata( to_char(ctr) || '. ' || htf.anchor2( 'fname.right_frame?surl=' || surl || '&void=' || void || '&disp_style=' || replace(LNG.CST_TXT_005,' ','+'),LNG.CST_TXT_005,ctarget=>'ORDER_RIGHT'),cattributes=>'CLASS="SMALL"' );
   htp.tablerowclose;
   if substr(theme_rec.theme_data,387,1) = 'T'
    then
     htp.tablerowopen;
      ctr := ctr + 1;
      htp.tabledata( to_char(ctr) || '. ' || htf.anchor2( 'fname.right_frame?surl=' || surl || '&void=' || void || '&disp_style=' || replace(LNG5.EXT_TXT_264,' ','+'),LNG5.EXT_TXT_264,ctarget=>'ORDER_RIGHT'),cattributes=>'CLASS="SMALL"' );
     htp.tablerowclose;
   end if;
   htp.tablerowopen;
    ctr := ctr + 1;
    htp.tabledata( to_char(ctr) || '. ' || htf.anchor2( 'fname.right_frame?surl=' || surl || '&void=' || void || '&disp_style=' || replace(LNG.PHG_TXT_352,' ','+'),LNG.PHG_TXT_352,ctarget=>'ORDER_RIGHT'),cattributes=>'CLASS="SMALL"' );
   htp.tablerowclose;
   htp.tablerowopen;
    ctr := ctr + 1;
    htp.tabledata( to_char(ctr) || '. ' || htf.anchor2( 'fname.right_frame?surl=' || surl || '&void=' || void || '&disp_style=' || replace(LNG3.ADM_TXT_619,' ','+'),LNG3.ADM_TXT_619,ctarget=>'ORDER_RIGHT'),cattributes=>'CLASS="SMALL"' );
   htp.tablerowclose;
   htp.tablerowopen;
    ctr := ctr + 1;
    htp.tabledata( to_char(ctr) || '. ' || htf.anchor2( 'fname.main?surl=' || surl,'Return',ctarget=>'PHG_BOTTOM'),cattributes=>'CLASS="SMALL"' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
 glbx.close_page( pfx );
exception when others then
 glbx.error_details( 'FNAME', 'LEFT_FRAME', errmsg=>sqlerrm);
end left_frame;

procedure right_frame(surl varchar2, void in integer, disp_style in varchar2 default LNG3.ADM_TXT_619, msg in varchar2 default null)
as

 cursor c1(phgid integer, void integer) is select * from order_style where oid = void and pid = phgid;
 cursor c2(phgid integer) is select spb, name from phg_price_book where pid = phgid order by name;
 cursor c3(phid integer) is select theme_name from theme order by theme_name;
 cursor c3a is select theme_type from theme_types order by theme_type;
 cursor c4 is select region, two_char_reference, three_char_reference from postal_charge order by region;
 cursor c5(wstate integer) is select status_priority_id,order_option from workflow_state_options where work_state = wstate order by order_by;
 cursor c6(phgid integer) is select oid,name from order_style where pid = phgid order by name;
 cursor c7(phgid integer, styl varchar2) is select oid,name from order_style where pid = phgid and name <> styl order by name;
 cursor c8a(phgid integer, void integer) is select oid,oid_when_invalid,valid_until,b2c_enabled,ltype,aid from customer_price_book where pid = phgid and oid = void;
 cursor c8b(phgid integer, void integer) is select oid,oid_when_invalid,valid_until,b2c_enabled,ltype,aid from customer_price_book where pid = phgid and oid_when_invalid = void;
 cursor c9a(acid integer) is select username from customer_account where aid = acid;
 cursor c9b(profid integer) is select username from customer_profile where profile_id = profid;
 cursor c10(phid integer) is select theme_name from limit_laf where pid = phid order by theme_name;
 cursor c11(phid integer) is select limit_scene,limit_laf,limit_bf,skill_level,default_category,default_bf,default_lf,external_api_access from photographer where pid = phid;
 cursor c12(phid integer) is select theme_type from limit_bf where pid = phid order by theme_type;
 cursor c13 is select column_name from user_tab_columns where table_name = 'ORDER_STYLE' and column_name not in ('OID','PID','DATE_CREATED','DATE_UPDATED','NAME','IS_DEFAULT');
 cursor c14(void integer) is select count('x') tot from customer_price_book where (oid = void or oid_when_invalid = void);
 cursor c15(phgid integer) is select * from theme_types where theme_type in (select theme_type from photographer where pid = phgid );
 cursor c16(phgid integer) is select workflow_name, status_workflow from workflow_set where pid = phgid order by workflow_name;
 cursor c17 is select distinct template_name from order_style_template;
 cursor c18( void integer ) is select * from additional_options_definition where oid = void order by order_by;

 c1rec		c1%ROWTYPE;
 c1arec		c1%ROWTYPE;
 c11rec		c11%ROWTYPE;
 c14rec		c14%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		varchar2(32767);
 tmpa		varchar2(32767);
 theme_rec	THEME_TYPES%ROWTYPE;

 procedure scr( p1 in varchar2, p2 in varchar2, nme in varchar2, col in varchar2, pfx in theme%ROWTYPE )
 as
  tmp	varchar2(4000);
 begin

   tmp := htf.formselectopen( p2 );
   if col = '0'
    then
     tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_407,'SELECTED', cattributes=>'VALUE="0"' );
    else
     tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_407,cattributes=>'VALUE="0"' );
   end if;
   if col = '1'
    then
     tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_352,'SELECTED', cattributes=>'VALUE="1"' );
    else
     tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_352,cattributes=>'VALUE="1"' );
   end if;
   if col = '2'
    then
     tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_353,'SELECTED', cattributes=>'VALUE="2"' );
    else
     tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_353,cattributes=>'VALUE="2"' );
   end if;
   tmp := tmp || htf.formselectclose;
   htp.tabledata( htf.formhidden( p1, nme ) || tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
 end scr;

 procedure ord( p1 in varchar2, p2 in varchar2, nme in varchar2, nmb in integer, pfx in theme%ROWTYPE )
 as
  tmp	varchar2(4000);
 begin

   tmp := htf.formselectopen( p2 );
  for j in 1..8 loop
   if nmb = j
    then
     tmp := tmp || htf.formselectoption( to_char(j),'SELECTED', cattributes=>'VALUE="' || to_char(j) || '"' );
    else
     tmp := tmp || htf.formselectoption( to_char(j), cattributes=>'VALUE="' || to_char(j) || '"' );
   end if;
  end loop;
   tmp := tmp || htf.formselectclose;
   htp.tabledata( htf.formhidden( p1, nme ) || tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
 end ord;

begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FNAME.RIGHT_FRAME', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  open c1(owner_id,void);
  fetch c1 into c1rec;
  close c1;
  if c1rec.oid is null then return; end if; -- Invalid OID
  open c15(owner_id);
  fetch c15 into theme_rec;
  close c15;

  glbx.main_title( surl, initcap(c1rec.name) || ' - ' || disp_style, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P69',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg );end if;

  if disp_style <> LNG3.ADM_TXT_619
   then
    htp.formopen( 'fname.accept_right_frame' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl) );
    htp.formhidden( 'VOID', void );
    htp.formhidden( 'DISP_STYLE', disp_style );
    htp.formhidden( 'P1', null );
    htp.formhidden( 'P2', null );
    htp.formhidden( 'P3', null );
  end if;

  if disp_style = LNG3.ADM_TXT_619
   then
    htp.bold( LNG5.EXT_TXT_265 );
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.PHG_TXT_164 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( LNG4.AHC_TXT_569 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( LNG2.FNM_TXT_053 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( LNG5.EXT_TXT_266 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( LNG5.EXT_TXT_267 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tablerowclose;
     for c8rec in c8a(owner_id,void) loop
     if c8rec.ltype in ('OWNER','CUSTOMER','VIRTUAL')
      then
       open c9a(c8rec.aid);
       fetch c9a into tmp;
       close c9a;
       if c8rec.ltype = 'OWNER' then tmpa := 'Customer'; else tmpa := 'Guest Customer'; end if;
     elsif c8rec.ltype in ('PROFILE','PROFILEG')
      then
       open c9b(c8rec.aid);
       fetch c9b into tmp;
       close c9b;
       if c8rec.ltype = 'PROFILE' then tmpa := 'Profile'; else tmpa := 'Guest Profile'; end if;
     end if;
     open c1(owner_id,c8rec.oid_when_invalid);
     fetch c1 into c1arec;
     close c1;
     htp.tablerowopen;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( tmpa, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( nvl(to_char(c8rec.valid_until,LNG.MASK),'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( nvl(c1arec.name,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      if c8rec.b2c_enabled = 'T'
       then
        htp.tabledata( LNG.PHG_TXT_045, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( LNG.PHG_TXT_046, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
     htp.tablerowclose;
     end loop;
    htp.tableclose;
    htp.nl;
    htp.bold( LNG5.EXT_TXT_268 );
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.PHG_TXT_164 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( LNG4.AHC_TXT_569 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( LNG2.FNM_TXT_053 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( LNG5.EXT_TXT_269 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( LNG5.EXT_TXT_267 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tablerowclose;
     for c8rec in c8b(owner_id,void) loop
     if c8rec.ltype in ('OWNER','CUSTOMER','VIRTUAL')
      then
       open c9a(c8rec.aid);
       fetch c9a into tmp;
       close c9a;
       if c8rec.ltype = 'OWNER' then tmpa := 'Customer'; else tmpa := 'Guest Customer'; end if;
     elsif c8rec.ltype in ('PROFILE','PROFILEG')
      then
       open c9b(c8rec.aid);
       fetch c9b into tmp;
       close c9b;
       if c8rec.ltype = 'PROFILE' then tmpa := 'Profile'; else tmpa := 'Guest Profile'; end if;
     end if;
     open c1(owner_id,c8rec.oid);
     fetch c1 into c1arec;
     close c1;
     htp.tablerowopen;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( tmpa, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( nvl(to_char(c8rec.valid_until,LNG.MASK),'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( nvl(c1arec.name,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      if c8rec.b2c_enabled = 'T'
       then
        htp.tabledata( LNG.PHG_TXT_045, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( LNG.PHG_TXT_046, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
     htp.tablerowclose;
     end loop;
    htp.tableclose;
    htp.nl;

  elsif disp_style = LNG.GLB_TXT_066
   then
    -- Price Book, Look and Feel, Business Ftr override, Residing Country, Currency to use, Is Default
    open c11( owner_id );
    fetch c11 into c11rec;
    close c11;
     htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_633 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      if c1rec.is_locked = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '1-IS_LOCKED', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '1-IS_LOCKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','1-SPB' ) || htf.bold( LNG.PHG_TXT_470 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

       tmp := htf.formselectopen( 'P2' );
       tmp := tmp || htf.formselectoption( NULL );
         for c2rec in c2(owner_id) loop
          if c1rec.spb = c2rec.spb
           then
            tmp := tmp || htf.formselectoption( c2rec.name, 'SELECTED', cattributes=>'VALUE="' || c2rec.spb || '"' );
           else
            tmp := tmp || htf.formselectoption( c2rec.name, cattributes=>'VALUE="' || c2rec.spb || '"' );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_431 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      if c1rec.use_default_if_no_price = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '1-USE_DEFAULT_IF_NO_PRICE', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '1-USE_DEFAULT_IF_NO_PRICE' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','1-BFTR' ) || htf.bold( LNG.PHG_TXT_129 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

       tmp := htf.formselectopen( 'P2' );
       tmp := tmp || htf.formselectoption( 'Use Customer Account Business Feature' );
       if c11rec.limit_bf = 'T'
        then
         for c3arec in c3a loop
          if c1rec.bftr = c3arec.theme_type
           then
            tmp := tmp || htf.formselectoption( c3arec.theme_type, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c3arec.theme_type );
          end if;
         end loop;
        else
         for c12rec in c12(owner_id) loop
          if c1rec.bftr = c12rec.theme_type
           then
            tmp := tmp || htf.formselectoption( c12rec.theme_type, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c12rec.theme_type );
          end if;
         end loop;
       end if;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','1-LAF' ) || htf.bold( LNG3.ADM_TXT_088 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

       tmp := htf.formselectopen( 'P2' );
       tmp := tmp || htf.formselectoption( 'Use Customer Account Look and Feel' );
       if c11rec.limit_laf = 'T'
        then
         for c3rec in c3(owner_id) loop
          if c1rec.laf = c3rec.theme_name
           then
            tmp := tmp || htf.formselectoption( c3rec.theme_name, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c3rec.theme_name );
          end if;
         end loop;
        else
         for c10rec in c10(owner_id) loop
          if c1rec.laf = c10rec.theme_name
           then
            tmp := tmp || htf.formselectoption( c10rec.theme_name, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c10rec.theme_name );
          end if;
         end loop;
       end if;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','1-RESIDING_COUNTRY' ) || htf.bold( LNG5.EXT_TXT_270 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

       tmp := htf.formselectopen( 'P2' );
         for c4rec in c4 loop
          if c1rec.residing_country = c4rec.region
           then
            tmp := tmp || htf.formselectoption( c4rec.region, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c4rec.region );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','1-CURRENCY_TO_USE' ) || htf.bold( LNG5.EXT_TXT_271 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

       tmp := htf.formselectopen( 'P2' );
         for c4rec in c4 loop
          if c1rec.currency_to_use = c4rec.region
           then
            tmp := tmp || htf.formselectoption( c4rec.three_char_reference || '-' || c4rec.region, 'SELECTED', cattributes=>'VALUE="' || c4rec.region || '"' );
           else
            tmp := tmp || htf.formselectoption( c4rec.three_char_reference || '-' || c4rec.region, cattributes=>'VALUE="' || c4rec.region || '"' );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','1-TRACING_STYLE' ) || htf.bold( LNG5.EXT_TXT_272 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

       tmp := htf.formselectopen( 'P2' );
       if c1rec.tracing_style = 'None'
        then
         tmp := tmp || htf.formselectoption( 'None', 'SELECTED', cattributes=>'VALUE="' || 'None' || '"' );
        else
         tmp := tmp || htf.formselectoption( 'None', cattributes=>'VALUE="' || 'None' || '"' );
       end if;
       if c1rec.tracing_style = 'Simple'
        then
         tmp := tmp || htf.formselectoption( 'Simple', 'SELECTED', cattributes=>'VALUE="' || 'Simple' || '"' );
        else
         tmp := tmp || htf.formselectoption( 'Simple', cattributes=>'VALUE="' || 'Simple' || '"' );
       end if;
       if c1rec.tracing_style = 'Thin Line'
        then
         tmp := tmp || htf.formselectoption( 'Thin Line', 'SELECTED', cattributes=>'VALUE="' || 'Thin Line' || '"' );
        else
         tmp := tmp || htf.formselectoption( 'Thin Line', cattributes=>'VALUE="' || 'Thin Line' || '"' );
       end if;
       if c1rec.tracing_style = 'Vertical Box'
        then
         tmp := tmp || htf.formselectoption( 'Vertical Box', 'SELECTED', cattributes=>'VALUE="' || 'Vertical Box' || '"' );
        else
         tmp := tmp || htf.formselectoption( 'Vertical Box', cattributes=>'VALUE="' || 'Vertical Box' || '"' );
       end if;
       if c11rec.external_api_access = 'T'
        then
         if c1rec.tracing_style = 'API'
          then
           tmp := tmp || htf.formselectoption( 'API', 'SELECTED', cattributes=>'VALUE="' || 'API' || '"' );
          else
           tmp := tmp || htf.formselectoption( 'API', cattributes=>'VALUE="' || 'API' || '"' );
         end if;
       end if;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     if c11rec.external_api_access = 'T'
      then
       htp.tablerowopen;
        htp.tabledata( htf.formhidden( 'P1','1-TRACING_STYLE_API' ) || htf.bold( LNG5.EXT_TXT_273 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

        htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.tracing_style_api ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tablerowclose;
     end if;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_274 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      if c1rec.is_default = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '1-IS_DEFAULT', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '1-IS_DEFAULT' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
     htp.tablerowclose;
    htp.tableclose;

  elsif disp_style = LNG5.EXT_TXT_259
   then
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formhidden( 'P1','2-PAYMENT_DISPLAY_STYLE' ) || htf.bold( LNG5.EXT_TXT_485 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      htp.formselectopen( 'P2' );
       if c1rec.payment_display_style = '1'
        then
         htp.formselectoption( LNG5.EXT_TXT_483,'SELECTED', cattributes=>'VALUE="' || '1' || '"' );
        else
         htp.formselectoption( LNG5.EXT_TXT_483,cattributes=>'VALUE="' || '1' || '"' );
       end if;
       if c1rec.payment_display_style = '2'
        then
         htp.formselectoption( LNG5.EXT_TXT_484,'SELECTED', cattributes=>'VALUE="' || '2' || '"' );
        else
         htp.formselectoption( LNG5.EXT_TXT_484,cattributes=>'VALUE="' || '2' || '"' );
       end if;
      htp.formselectclose;
      htp.p( '</TD>' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     if substr(theme_rec.theme_data,198,1) = 'T'
      then
       htp.tablerowopen;
        if c1rec.payment_cc = 'T'
         then
          htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_CC', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
         else
          htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_CC' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        end if;
        htp.tabledata( htf.bold( LNG5.EXT_TXT_275 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

        htp.tabledata(htf.formhidden( 'P1','2-TEXT_TITLE_MERCHANT' ) ||  htf.formtext( 'P2', 30, 100, c1rec.text_title_merchant ) || htf.nl ||
                      htf.formhidden( 'P1','2-PAYMENT_CC_TEXT' ) ||  htf.formtext( 'P2', 30, 100, c1rec.payment_cc_text ) || htf.nl ||
                      htf.formhidden( 'P1','2-TEXT_CC_MESSAGE' ) ||  htf.formtext( 'P2', 30, 100, c1rec.text_cc_message ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

        htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
        if c1rec.payment_cc_international = 'T'
         then
          htp.formcheckbox( 'P3', '2-PAYMENT_CC_INTERNATIONAL', 'CHECKED' ); htp.p( ' ' || LNG5.EXT_TXT_486 );
         else
          htp.formcheckbox( 'P3', '2-PAYMENT_CC_INTERNATIONAL' ); htp.p( ' ' || LNG5.EXT_TXT_486 );
        end if;
        htp.nl;
        if c1rec.payment_cc_separate_display = 'T'
         then
          htp.formcheckbox( 'P3', '2-PAYMENT_CC_SEPARATE_DISPLAY', 'CHECKED' ); htp.p( ' ' || LNG5.EXT_TXT_487 );
         else
          htp.formcheckbox( 'P3', '2-PAYMENT_CC_SEPARATE_DISPLAY' ); htp.p( ' ' || LNG5.EXT_TXT_487 );
        end if;
        htp.p( '</TD>' );
       htp.tablerowclose;
     end if;
     if substr(theme_rec.theme_data,199,1) = 'T'
      then
       htp.tablerowopen;
        if c1rec.payment_cheque = 'T'
         then
          htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_CHEQUE', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
         else
          htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_CHEQUE' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        end if;
        htp.tabledata( htf.bold( LNG5.EXT_TXT_276 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

        htp.tabledata( htf.formhidden( 'P1','2-TEXT_TITLE_CHEQUE' ) || htf.formtext( 'P2', 30, 100, c1rec.text_title_cheque ) || htf.nl ||
                       htf.formhidden( 'P1','2-PAYMENT_CHEQUE_TEXT' ) || htf.formtext( 'P2', 30, 100, c1rec.payment_cheque_text ) || htf.nl ||
                       htf.formhidden( 'P1','2-TEXT_CHEQUE_MESSAGE' ) ||  htf.formtext( 'P2', 30, 100, c1rec.text_cheque_message ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
        if c1rec.payment_cheque_noconfirm = 'T'
         then
          htp.formcheckbox( 'P3', '2-PAYMENT_CHEQUE_NOCONFIRM', 'CHECKED' ); htp.p( ' ' || LNG5.EXT_TXT_471 );
         else
          htp.formcheckbox( 'P3', '2-PAYMENT_CHEQUE_NOCONFIRM' ); htp.p( ' ' || LNG5.EXT_TXT_471 );
        end if;
        htp.nl;
        htp.formhidden( 'P1', '2-PAYMENT_CHEQUE_BUTTON_LOC' );
        htp.p( LNG5.EXT_TXT_464 || htf.nl );
        htp.formselectopen( 'P2' );
         if c1rec.payment_cheque_button_loc = 'T'
          then
           htp.formselectoption( LNG3.ADM_TXT_580,'SELECTED', cattributes=>'VALUE="' || 'T' || '"' );
          else
           htp.formselectoption( LNG3.ADM_TXT_580, cattributes=>'VALUE="' || 'T' || '"' );
         end if;
         if c1rec.payment_cheque_button_loc = 'B'
          then
           htp.formselectoption( LNG5.EXT_TXT_233,'SELECTED', cattributes=>'VALUE="' || 'B' || '"' );
          else
           htp.formselectoption( LNG5.EXT_TXT_233, cattributes=>'VALUE="' || 'B' || '"' );
         end if;
         if c1rec.payment_cheque_button_loc = 'Z'
          then
           htp.formselectoption( LNG5.EXT_TXT_472,'SELECTED', cattributes=>'VALUE="' || 'Z' || '"' );
          else
           htp.formselectoption( LNG5.EXT_TXT_472, cattributes=>'VALUE="' || 'Z' || '"' );
         end if;
        htp.formselectclose;
        htp.nl;
        -- xxx for language file
        if c1rec.fax_merchant_enabled = 'T'
         then
          htp.formcheckbox( 'P3', '2-FAX_MERCHANT_ENABLED', 'CHECKED' );
         else
          htp.formcheckbox( 'P3', '2-FAX_MERCHANT_ENABLED' );
        end if;
        htp.p( ' ' || 'Display Merchant Payment Details on Print Screen' );
        htp.nl;
        if c1rec.fax_merchant_border = 'T'
         then
          htp.formcheckbox( 'P3', '2-FAX_MERCHANT_BORDER', 'CHECKED' );
         else
          htp.formcheckbox( 'P3', '2-FAX_MERCHANT_BORDER' );
        end if;
        htp.p( ' ' || 'Display Border around Merchant Payment Details' );
        htp.nl;
        if c1rec.fax_merchant_box_dotted = 'T'
         then
          htp.formcheckbox( 'P3', '2-FAX_MERCHANT_BOX_DOTTED', 'CHECKED' );
         else
          htp.formcheckbox( 'P3', '2-FAX_MERCHANT_BOX_DOTTED' );
        end if;
        htp.p( ' ' || 'Draw Line as separator' );
        htp.p( '</TD>' );
       htp.tablerowclose;
     end if;
     if substr(theme_rec.theme_data,175,1) = 'T'
      then
       htp.tablerowopen;
        if c1rec.payment_phone = 'T'
         then
          htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_PHONE', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
         else
          htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_PHONE' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        end if;
        htp.tabledata( htf.bold( LNG.ORD_TXT_180 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

        htp.tabledata( htf.formhidden( 'P1','2-TEXT_TITLE_PHONE' ) || htf.formtext( 'P2', 30, 100, c1rec.text_title_phone ) || htf.nl ||
                       htf.formhidden( 'P1','2-PAYMENT_PHONE_TEXT' ) || htf.formtext( 'P2', 30, 100, c1rec.payment_phone_text ) || htf.nl ||
                      htf.formhidden( 'P1','2-TEXT_PHONE_MESSAGE_BUT' ) ||  htf.formtext( 'P2', 30, 100, c1rec.text_phone_message_but ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        if c1rec.payment_phone_ring = 'T'
         then
          htp.tabledata( htf.formradio( 'P4', 'T', 'CHECKED' ) || ' ' || LNG5.EXT_TXT_618 || htf.nl || htf.formradio( 'P4', 'F' ) || ' ' || LNG5.EXT_TXT_619, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
         else
          htp.tabledata( htf.formradio( 'P4', 'T' ) || ' ' || LNG5.EXT_TXT_618 || htf.nl || htf.formradio( 'P4', 'F', 'CHECKED' ) || ' ' || LNG5.EXT_TXT_619, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        end if;
       htp.tablerowclose;
     end if;
     htp.tablerowopen;
      if c1rec.payment_billing = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_BILLING', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_BILLING' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_277 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formhidden( 'P1','2-TEXT_TITLE_BILLING' ) || htf.formtext( 'P2', 30, 100, c1rec.text_title_billing ) || htf.nl ||
                     htf.formhidden( 'P1','2-PAYMENT_BILLING_TEXT' ) || htf.formtext( 'P2', 30, 100, c1rec.payment_billing_text ) || htf.nl ||
                      htf.formhidden( 'P1','2-TEXT_BILLING_MESSAGE' ) ||  htf.formtext( 'P2', 30, 100, c1rec.text_billing_message ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     if substr(theme_rec.theme_data,394,1) = 'T'
      then
       htp.tablerowopen;
        if c1rec.payment_auth = 'T'
         then
          htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_AUTH', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
         else
          htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_AUTH' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        end if;
        htp.tabledata( htf.bold( LNG5.EXT_TXT_278 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

        htp.tabledata( htf.formhidden( 'P1','2-TEXT_TITLE_AUTHORISATION' ) || htf.formtext( 'P2', 30, 100, c1rec.text_title_authorisation ) || htf.nl ||
                       htf.formhidden( 'P1','2-PAYMENT_AUTH_TEXT' ) || htf.formtext( 'P2', 30, 100, c1rec.payment_auth_text ) || htf.nl ||
                       htf.formhidden( 'P1','2-TEXT_AUTH_MESSAGE' ) ||  htf.formtext( 'P2', 30, 100, c1rec.text_auth_message ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
        if c1rec.payment_auth_project_code = 'T'
         then
          htp.formcheckbox( 'P3', '2-PAYMENT_AUTH_PROJECT_CODE', 'CHECKED' ); htp.p( ' ' || 'Prompt for Project Code' );
         else
          htp.formcheckbox( 'P3', '2-PAYMENT_AUTH_PROJECT_CODE' ); htp.p( ' ' || 'Prompt for Project Code' );
        end if;
        htp.p( '</TD>' );
       htp.tablerowclose;
     end if;
     if substr(theme_rec.theme_data,372,1) = 'T'
      then
       htp.tablerowopen;
        if c1rec.payment_gift = 'T'
         then
          htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_GIFT', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
         else
          htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_GIFT' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        end if;
        htp.tabledata( htf.bold( LNG5.EXT_TXT_279 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

        htp.tabledata( htf.formhidden( 'P1','2-TEXT_TITLE_GIFT' ) || htf.formtext( 'P2', 30, 100, c1rec.text_title_gift ) || htf.nl ||
                       htf.formhidden( 'P1','2-PAYMENT_GIFT_TEXT' ) || htf.formtext( 'P2', 30, 100, c1rec.payment_gift_text ) || htf.nl ||
                      htf.formhidden( 'P1','2-TEXT_GIFT_MESSAGE' ) ||  htf.formtext( 'P2', 30, 100, c1rec.text_gift_message ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tablerowclose;
     end if;
     htp.tablerowopen;
      if c1rec.payment_free = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_FREE', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_FREE' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_256 || htf.nl || htf.italic( 'Note: Automatically Disabled if any<BR>Payment Options Above are Enabled') ), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"' );

      htp.tabledata( htf.formhidden( 'P1','2-TEXT_TITLE_FREE' ) || htf.formtext( 'P2', 30, 100, c1rec.text_title_free ) || htf.nl ||
                     htf.formhidden( 'P1','2-PAYMENT_FREE_TEXT' ) || htf.formtext( 'P2', 30, 100, c1rec.payment_free_text ) || htf.nl ||
                      htf.formhidden( 'P1','2-TEXT_FREE_MESSAGE' ) ||  htf.formtext( 'P2', 30, 100, c1rec.text_free_message ), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formhidden( 'P1','2-PAYMENT_PROBLEMS_DEF' ) || htf.bold( LNG5.EXT_TXT_280 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      tmp := htf.formselectopen( 'P2' );
      if c1rec.payment_problems_def = 'NONE'
       then
        tmp := tmp || htf.formselectoption( 'Disabled','SELECTED', cattributes=>'VALUE="' || 'NONE' || '"' );
       else
        tmp := tmp || htf.formselectoption( 'Disabled', cattributes=>'VALUE="' || 'NONE' || '"' );
      end if;
      if substr(theme_rec.theme_data,198,1) = 'T'
       then
        if c1rec.payment_problems_def = 'CC'
          then
          tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_275,'SELECTED', cattributes=>'VALUE="' || 'CC' || '"' );
         else
          tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_275, cattributes=>'VALUE="' || 'CC' || '"' );
        end if;
      end if;
      if substr(theme_rec.theme_data,198,1) = 'T'
       then
        if c1rec.payment_problems_def = 'CHEQUE'
         then
          tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_276,'SELECTED', cattributes=>'VALUE="' || 'CHEQUE' || '"' );
         else
          tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_276, cattributes=>'VALUE="' || 'CHEQUE' || '"' );
        end if;
      end if;
      if substr(theme_rec.theme_data,175,1) = 'T'
       then
        if c1rec.payment_problems_def = 'PHONE'
         then
          tmp := tmp || htf.formselectoption( LNG.ORD_TXT_180,'SELECTED', cattributes=>'VALUE="' || 'PHONE' || '"' );
         else
          tmp := tmp || htf.formselectoption( LNG.ORD_TXT_180, cattributes=>'VALUE="' || 'PHONE' || '"' );
        end if;
      end if;
      if c1rec.payment_problems_def = 'BILLING'
       then
        tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_277,'SELECTED', cattributes=>'VALUE="' || 'BILLING' || '"' );
       else
        tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_277, cattributes=>'VALUE="' || 'BILLING' || '"' );
      end if;
      if substr(theme_rec.theme_data,394,1) = 'T'
       then
        if c1rec.payment_problems_def = 'AUTH'
         then
          tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_278,'SELECTED', cattributes=>'VALUE="' || 'AUTH' || '"' );
         else
          tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_278, cattributes=>'VALUE="' || 'AUTH' || '"' );
        end if;
      end if;
      tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formhidden( 'P1','2-TEXT_ORDER_PROBLEM' ) || htf.formtext( 'P2', 30, 100, c1rec.text_order_problem ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    htp.tableclose;

    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      if c1rec.payment_display_gif = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_DISPLAY_GIF', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_DISPLAY_GIF' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_281 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.payment_display_all_as_butt = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_DISPLAY_ALL_AS_BUTT', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_DISPLAY_ALL_AS_BUTT' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_461 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.disp_purch_request_heading = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '2-DISP_PURCH_REQUEST_HEADING', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '2-DISP_PURCH_REQUEST_HEADING' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_462 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.payment_can_cancel_noncc = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_CAN_CANCEL_NONCC', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_CAN_CANCEL_NONCC' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_282 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.payment_b2c = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_B2C', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_B2C' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_283 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    htp.tableclose;

  elsif disp_style = 'User Fees'
   then
    -- User Fees
    htp.bold( 'Display Controls' );
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      if c1rec.uf_enabled = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_ENABLED', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_ENABLED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'User Fees Enabled' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.uf_display_progress_bar = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_DISPLAY_PROGRESS_BAR', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_DISPLAY_PROGRESS_BAR' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'Display Tracking Bar' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.uf_display_price = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_DISPLAY_PRICE', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_DISPLAY_PRICE' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'Display Adjusted Price' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formhidden( 'P1','UF_IMAGE_POSITION' ) || htf.bold( 'Image Position' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      htp.formselectopen( 'P2' );
      if c1rec.uf_image_position = 'L'
       then
        htp.formselectoption( 'Left','SELECTED', cattributes=>'VALUE="' || 'L' || '"' );
       else
        htp.formselectoption( 'Left', cattributes=>'VALUE="' || 'L' || '"' );
      end if;
      if c1rec.uf_image_position = 'R'
       then
        htp.formselectoption( 'Right','SELECTED', cattributes=>'VALUE="' || 'R' || '"' );
       else
        htp.formselectoption( 'Right', cattributes=>'VALUE="' || 'R' || '"' );
      end if;
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.uf_display_matte = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_DISPLAY_MATTE', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_DISPLAY_MATTE' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'Display Image Matte' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.uf_display_image_name = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_DISPLAY_IMAGE_NAME', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_DISPLAY_IMAGE_NAME' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'Display Image Name' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.uf_display_additional_img = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_DISPLAY_ADDITIONAL_IMG', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_DISPLAY_ADDITIONAL_IMG' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'Display Additional Image Information' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.uf_show_continue_gif = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_SHOW_CONTINUE_GIF', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_SHOW_CONTINUE_GIF' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'Show Continue Gif' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formhidden( 'P1', 'UF_CONTINUE_TEXT' ) || htf.formtext( 'P2', 40, 100, c1rec.uf_continue_text ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.uf_show_return_gif = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_SHOW_RETURN_GIF', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_SHOW_RETURN_GIF' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'Show Return Gif' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formhidden( 'P1', 'UF_RETURN_TEXT' ) || htf.formtext( 'P2', 40, 100, c1rec.uf_return_text ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( 'Header Title' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formhidden( 'P1', 'UF_TEXT_HEADER' ) || htf.formtext( 'P2', 40, 100, c1rec.uf_text_header ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( 'Instruction Text' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formhidden( 'P1', 'UF_INSTRUCTION_TEXT' ) || htf.formtext( 'P2', 40, 100, c1rec.uf_instruction_text ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.uf_specify_in_image = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_SPECIFY_IN_IMAGE', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_SPECIFY_IN_IMAGE' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'Display User Fee Chosen in Shopping Basket Screen' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2"' );
     htp.tablerowclose;
    htp.tableclose;
    htp.nl;

    htp.bold( 'Business Logic' );
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      if c1rec.uf_bl_enable_default = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_ENABLE_DEFAULT', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_ENABLE_DEFAULT' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'Enable Default Category' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( 'Message if no default entered' ) || htf.nl ||
                     htf.formhidden( 'P1', 'UF_ERROR_NO_DEFAULT' ) || htf.formtext( 'P2', 40, 100, c1rec.uf_error_no_default ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.uf_bl_locked_fee = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_LOCKED_FEE', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_LOCKED_FEE' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'Once User Fee is Chosen, it is locked and cannot be changed' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.uf_bl_onnew_def_last = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_ONNEW_DEF_LAST', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_ONNEW_DEF_LAST' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'On addition of new items, default to last category chosen' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.uf_bl_onnew_nodisplay = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_ONNEW_NODISPLAY', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_ONNEW_NODISPLAY' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'On addition of new items, do not display User Fee screen' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.uf_bl_cust_can_change = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_CUST_CAN_CHANGE', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_CUST_CAN_CHANGE' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'Customer can navigate back and change User Fee' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2"' );
     htp.tablerowclose;
     /* commented out for the moment
     htp.tablerowopen;
      if c1rec.uf_bl_enable_combo_box = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_ENABLE_COMBO_BOX', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_ENABLE_COMBO_BOX' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'Customer sees Combo Box of User Fee Options on Order Screen' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.uf_bl_enable_prepricing = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_ENABLE_PREPRICING', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_ENABLE_PREPRICING' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'Pre Pricing for User Fees is Enabled' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2"' );
     htp.tablerowclose;
     */
     htp.tablerowopen;
      if c1rec.uf_bl_remember_over_session = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_REMEMBER_OVER_SESSION', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_REMEMBER_OVER_SESSION' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'Remember last Category chosen over subsequent sessions and use as default' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.uf_bl_turf_duplicates = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_TURF_DUPLICATES', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', 'UF_BL_TURF_DUPLICATES' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'Remove Duplicate Items from Shopping Basket if they have no User Fee Code yet Attached to them' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2"' );
     htp.tablerowclose;
    htp.tableclose;

  elsif disp_style = LNG5.EXT_TXT_260
   then
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
    htp.tablerowopen;
    htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
    htp.bold( LNG5.EXT_TXT_284 );
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_DISPLAY_ORDER' ) || htf.bold( LNG5.EXT_TXT_488 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      htp.formselectopen( 'P2' );
      if c1rec.pricing_display_order = 'P'
       then
         htp.formselectoption( LNG.LAB_TXT_015, 'SELECTED', cattributes=>'VALUE="' || 'P' || '"' );
       else
         htp.formselectoption( LNG.LAB_TXT_015, cattributes=>'VALUE="' || 'P' || '"' );
      end if;
      if c1rec.pricing_display_order = 'N'
       then
         htp.formselectoption( LNG.PHG_TXT_022, 'SELECTED', cattributes=>'VALUE="' || 'N' || '"' );
       else
         htp.formselectoption( LNG.PHG_TXT_022, cattributes=>'VALUE="' || 'N' || '"' );
      end if;
      if c1rec.pricing_display_order = 'C'
       then
         htp.formselectoption( LNG2.PBK_TXT_023, 'SELECTED', cattributes=>'VALUE="' || 'C' || '"' );
       else
         htp.formselectoption( LNG2.PBK_TXT_023, cattributes=>'VALUE="' || 'C' || '"' );
      end if;
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_DISCOUNT' ) || htf.bold( LNG5.EXT_TXT_285 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 10, 10, trim(to_char(c1rec.pricing_discount)) ) || '%', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_DISC_IF_GTR' ) || htf.bold( LNG5.EXT_TXT_286 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 30, 30, trim(to_char(c1rec.pricing_disc_if_gtr,LNG.MONEY_FORMAT)) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_DISCOUNT_STAGE' ) || htf.bold( LNG5.EXT_TXT_287 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      htp.formselectopen( 'P2' );
       if c1rec.pricing_discount_stage = 'S'
        then
         htp.formselectoption( LNG.CST_TXT_136, 'SELECTED', cattributes=>'VALUE="' || 'S' || '"' );
        else
         htp.formselectoption( LNG.CST_TXT_136, cattributes=>'VALUE="' || 'S' || '"' );
       end if;
       if c1rec.pricing_discount_stage = 'P'
        then
         htp.formselectoption( LNG5.EXT_TXT_288, 'SELECTED', cattributes=>'VALUE="' || 'P' || '"' );
        else
         htp.formselectoption( LNG5.EXT_TXT_288, cattributes=>'VALUE="' || 'P' || '"' );
       end if;
       if c1rec.pricing_discount_stage = 'F'
        then
         htp.formselectoption( LNG5.EXT_TXT_289, 'SELECTED', cattributes=>'VALUE="' || 'F' || '"' );
        else
         htp.formselectoption( LNG5.EXT_TXT_289, cattributes=>'VALUE="' || 'F' || '"' );
       end if;
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
     /*
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_GIFT_CHARGE' ) || htf.bold( LNG5.EXT_TXT_290 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 30, 30, trim(to_char(c1rec.pricing_gift_charge,LNG.MONEY_FORMAT)) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
    */
    htp.tableclose;
    htp.nl;

    htp.bold( LNG5.EXT_TXT_291 );
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_SHIP_LOCAL' ) || htf.bold( LNG5.EXT_TXT_292 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 30, trim(to_char(c1rec.pricing_ship_local,LNG.MONEY_FORMAT)) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      if c1rec.pricing_postage_included = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '3-PRICING_POSTAGE_INCLUDED', 'CHECKED' ) || ' ' || LNG5.EXT_TXT_293, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '3-PRICING_POSTAGE_INCLUDED' ) || ' ' || LNG5.EXT_TXT_293, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_SHIP_INT' ) || htf.bold( LNG5.EXT_TXT_294 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 30, trim(to_char(c1rec.pricing_ship_int,LNG.MONEY_FORMAT)) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_EXPR_LOCAL' ) || htf.bold( LNG5.EXT_TXT_295 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 30, trim(to_char(c1rec.pricing_expr_local,LNG.MONEY_FORMAT)) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      if c1rec.pricing_express_included = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '3-PRICING_EXPRESS_INCLUDED', 'CHECKED' ) || ' ' || LNG5.EXT_TXT_296, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '3-PRICING_EXPRESS_INCLUDED' ) || ' ' || LNG5.EXT_TXT_296, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_EXPR_INT' ) || htf.bold( LNG5.EXT_TXT_297 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 30, trim(to_char(c1rec.pricing_expr_int,LNG.MONEY_FORMAT)) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_298 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      if c1rec.pricing_nopostage_if_zero = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '3-PRICING_NOPOSTAGE_IF_ZERO', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '3-PRICING_NOPOSTAGE_IF_ZERO' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     /* Redundant - now in another part
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_299 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      if c1rec.pricing_order_split = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '3-PRICING_ORDER_SPLIT', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '3-PRICING_ORDER_SPLIT' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     */

     -- xxx for language file
     htp.tablerowopen;
      htp.tabledata( htf.bold( 'Customer can pick up Order (no postage charged)' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      if c1rec.pricing_offer_manual_ship = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '3-PRICING_OFFER_MANUAL_SHIP', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '3-PRICING_OFFER_MANUAL_SHIP' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1','3-TEXT_MANUAL_SHIP' ) || htf.formtext( 'P2', 40, 100, c1rec.text_manual_ship ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_POSTAGE_TEXT' ) || htf.bold( LNG5.EXT_TXT_300 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 30, 30, c1rec.pricing_postage_text ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.bold( 'Separate Postage and Surcharge' ), cattributes=>DAPI.GLOBAL_LF.qcbground || 'valign="MIDDLE" align="LEFT"' );
      if c1rec.disp_sep_post_surcharge = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '3-DISP_SEP_POST_SURCHARGE', 'CHECKED' ), cattributes=>DAPI.GLOBAL_LF.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '3-DISP_SEP_POST_SURCHARGE' ), cattributes=>DAPI.GLOBAL_LF.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( '&nbsp;', cattributes=>DAPI.GLOBAL_LF.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_SURCHARGE_TEXT' ) || htf.bold( LNG5.EXT_TXT_354 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 30, 30, c1rec.pricing_surcharge_text ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-TEXT_SURCHARGE' ) || htf.bold( 'Surcharge Heading, if separate from Postage' ), cattributes=>DAPI.GLOBAL_LF.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.text_surcharge ), cattributes=>DAPI.GLOBAL_LF.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>DAPI.GLOBAL_LF.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_POSTAGE_TEXT_COL' ) || htf.bold( LNG5.EXT_TXT_409 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.pricing_postage_text_col ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_EXPRESS_TEXT_COL' ) || htf.bold( LNG5.EXT_TXT_410 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.pricing_express_text_col ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-TEXT_LOCAL_CHARGE' ) || htf.bold( 'Text to Describe Local' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.text_local_charge ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-TEXT_INTERNATIONAL_CHARGE' ) || htf.bold( 'Text to Describe International' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.text_international_charge ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

    htp.tableclose;
    htp.nl;
    htp.bold( LNG5.EXT_TXT_355 );
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_MIN_AMT' ) || htf.bold( LNG5.EXT_TXT_356 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 30, trim(to_char(c1rec.pricing_min_amt,LNG.MONEY_FORMAT)) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_MAX_AMT' ) || htf.bold( LNG5.EXT_TXT_357 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 30, trim(to_char(c1rec.pricing_max_amt,LNG.MONEY_FORMAT)) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_MAX_QTY' ) || htf.bold( LNG5.EXT_TXT_358 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 10, 10, trim(to_char(c1rec.pricing_max_qty)) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-TEXT_MIN_MAX_REACHED' ) || htf.bold( LNG5.EXT_TXT_359 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.text_min_max_reached ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    htp.tableclose;
    htp.nl;
    htp.bold( LNG.LAB_TXT_016 );
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_GST' ) || htf.bold( LNG5.EXT_TXT_360 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 30, trim(to_char(c1rec.pricing_gst)) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','3-PRICING_GST_TEXT' ) || htf.bold( LNG5.EXT_TXT_361 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 30, c1rec.pricing_gst_text ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_362 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      if c1rec.pricing_gst_int_sales = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '3-PRICING_GST_INT_SALES', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '3-PRICING_GST_INT_SALES' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_408 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      if c1rec.pricing_gst_inclusive = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '3-PRICING_GST_INCLUSIVE', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '3-PRICING_GST_INCLUSIVE' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
    htp.tableclose;

    htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tableclose;

 -- Additional Purchase Options
 -- xxx language file
  elsif disp_style = 'Purchase Options'
   then
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
    htp.tablerowopen;
    htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );

    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( 'Order By *' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( 'Merchant Code *' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( 'Option Style' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( 'Display Text/Combo Text' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( 'Price(s)' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( 'Help Text' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( 'Adjust International<BR>Prices By' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( 'Customer can leave comment' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( 'Receipt Page Options' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( 'Customer Response<BR>in Receipt' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( 'Site Specific GIF' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tablerowclose;
     for c18rec in c18(c1rec.oid) loop
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1','ORDER_BY' ) || htf.formtext( 'P2', 3, 5, c18rec.order_by ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.formhidden( 'P1','MERCHANT_CODE' ) || htf.formtext( 'P2', 10, 100, c18rec.merchant_id_code ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
        htp.formhidden( 'P1','DISPLAY_STYLE' ) ;
        htp.formselectopen( 'P2' );
         if c18rec.display_style = 'C' then htp.formselectoption( 'Checkbox', 'SELECTED', cattributes=>'VALUE="C"' ); else htp.formselectoption( 'Checkbox', cattributes=>'VALUE="C"' ); end if;
         if c18rec.display_style = 'L' then htp.formselectoption( 'Combo Box', 'SELECTED', cattributes=>'VALUE="L"' ); else htp.formselectoption( 'Combo Box', cattributes=>'VALUE="L"' ); end if;
        htp.formselectclose;
       htp.p( '</TD>' );
       htp.tabledata( htf.formhidden( 'P1','DISPLAY_TEXT' ) || htf.formtext( 'P2', 20, 100, c18rec.display_text ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
        htp.formhidden( 'P1','DISPLAY_PRICES' );
        htp.formtext( 'P2', 20, 100, c18rec.display_prices );
        if c18rec.display_style = 'L'
         then
          htp.nl;
          htp.italic( 'Example' );
          htp.nl;
          add_opt_combo( null, c18rec.display_text, c18rec.display_prices );
        end if;
       htp.p( '</TD>' );
       htp.tabledata( htf.formhidden( 'P1','DISPLAY_TEXT_HELP' ) || htf.formtext( 'P2', 20, 100, c18rec.display_text_help ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.formhidden( 'P1','INTERNATIONAL_ADJUSTER' ) || htf.formtext( 'P2', 4, 20, c18rec.international_adjuster ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
        htp.formhidden( 'P1','CUSTOMER_COMMENT_ALLOWED' ) ;
        htp.formselectopen( 'P2' );
         if c18rec.customer_comment_allowed = 'T' then htp.formselectoption( 'Yes', 'SELECTED', cattributes=>'VALUE="T"' ); else htp.formselectoption( 'Yes', cattributes=>'VALUE="T"' ); end if;
         if c18rec.customer_comment_allowed = 'F' then htp.formselectoption( 'No', 'SELECTED', cattributes=>'VALUE="F"' ); else htp.formselectoption( 'No', cattributes=>'VALUE="F"' ); end if;
        htp.formselectclose;
       htp.p( '</TD>' );

       htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
        htp.formhidden( 'P1','DISPLAY_RECEIPT_PAGE' ) ;
        htp.formselectopen( 'P2' );
         if c18rec.display_receipt_page = 'N' then htp.formselectoption( 'No Display', 'SELECTED', cattributes=>'VALUE="N"' ); else htp.formselectoption( 'No Display', cattributes=>'VALUE="N"' ); end if;
         if c18rec.display_receipt_page = 'M' then htp.formselectoption( 'Merchant Code', 'SELECTED', cattributes=>'VALUE="M"' ); else htp.formselectoption( 'Merchant Code', cattributes=>'VALUE="M"' ); end if;
         if c18rec.display_receipt_page = 'T' then htp.formselectoption( 'Display Text', 'SELECTED', cattributes=>'VALUE="T"' ); else htp.formselectoption( 'Display Text', cattributes=>'VALUE="T"' ); end if;
        htp.formselectclose;
       htp.p( '</TD>' );
       htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
        htp.formhidden( 'P1','DISPLAY_RECEIPT_CUSTRESP' ) ;
        htp.formselectopen( 'P2' );
         if c18rec.display_receipt_custresp = 'T' then htp.formselectoption( 'Display', 'SELECTED', cattributes=>'VALUE="T"' ); else htp.formselectoption( 'Display', cattributes=>'VALUE="T"' ); end if;
         if c18rec.display_receipt_custresp = 'F' then htp.formselectoption( 'No Display', 'SELECTED', cattributes=>'VALUE="F"' ); else htp.formselectoption( 'No Display', cattributes=>'VALUE="F"' ); end if;
        htp.formselectclose;
       htp.p( '</TD>' );
       htp.tabledata( htf.formhidden( 'P1','SITE_SPECIFIC_GIF' ) || htf.formtext( 'P2', 10, 100, c18rec.site_specific_gif ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tablerowclose;
     end loop;
     for j in 1..3 loop
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1','ORDER_BY' ) || htf.formtext( 'P2', 3, 5 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.formhidden( 'P1','MERCHANT_CODE' ) || htf.formtext( 'P2', 10, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
        htp.formhidden( 'P1','DISPLAY_STYLE' ) ;
        htp.formselectopen( 'P2' );
         htp.formselectoption( 'Checkbox', 'SELECTED', cattributes=>'VALUE="C"' );
         htp.formselectoption( 'Combo Box', cattributes=>'VALUE="L"' );
        htp.formselectclose;
       htp.p( '</TD>' );
       htp.tabledata( htf.formhidden( 'P1','DISPLAY_TEXT' ) || htf.formtext( 'P2', 20, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.formhidden( 'P1','DISPLAY_PRICES' ) || htf.formtext( 'P2', 20, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.formhidden( 'P1','DISPLAY_TEXT_HELP' ) || htf.formtext( 'P2', 20, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.formhidden( 'P1','INTERNATIONAL_ADJUSTER' ) || htf.formtext( 'P2', 4, 20 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
        htp.formhidden( 'P1','CUSTOMER_COMMENT_ALLOWED' ) ;
        htp.formselectopen( 'P2' );
         htp.formselectoption( 'Yes', cattributes=>'VALUE="T"' );
         htp.formselectoption( 'No', 'SELECTED', cattributes=>'VALUE="F"' );
        htp.formselectclose;
       htp.p( '</TD>' );

       htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
        htp.formhidden( 'P1','DISPLAY_RECEIPT_PAGE' ) ;
        htp.formselectopen( 'P2' );
         htp.formselectoption( 'No Display', cattributes=>'VALUE="N"' );
         htp.formselectoption( 'Merchant Code', 'SELECTED', cattributes=>'VALUE="M"' );
         htp.formselectoption( 'Display Text', cattributes=>'VALUE="T"' );
        htp.formselectclose;
       htp.p( '</TD>' );
       htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
        htp.formhidden( 'P1','DISPLAY_RECEIPT_CUSTRESP' ) ;
        htp.formselectopen( 'P2' );
         htp.formselectoption( 'Display', cattributes=>'VALUE="T"' );
         htp.formselectoption( 'No Display', 'SELECTED', cattributes=>'VALUE="F"' );
        htp.formselectclose;
       htp.p( '</TD>' );
       htp.tabledata( htf.formhidden( 'P1','SITE_SPECIFIC_GIF' ) || htf.formtext( 'P2', 10, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tablerowclose;
     end loop;
    htp.tableclose;

    htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tableclose;
    htp.nl;
    htp.p( 'Instructions:' );
    htp.nl;
    htp.p( '1. If the option style is combo box, then enter in all values separated by commas to create the combo box of display values and associated prices.' );
    htp.nl;
    htp.p( '2. * - Mandatory Value. Must be entered.' );
    htp.nl;
    htp.p( '3. To delete an entry, just set to blank the Order By Value and the Merchant Code.' );
    htp.nl;
    htp.p( '4. A Price does not need to be entered in for Checkboxes. No price is displayed to the client.' );
    htp.nl;

  elsif disp_style = LNG2.PBK_TXT_128
   then
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
    htp.tablerowopen;
    htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );

    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
     if c1rec.payment_cc_down_only = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_CC_DOWN_ONLY', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata( htf.formcheckbox( 'P3', '2-PAYMENT_CC_DOWN_ONLY' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     end if;
     htp.tabledata( LNG5.EXT_TXT_363, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
     if c1rec.download_original_any_time = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '2-DOWNLOAD_ORIGINAL_ANY_TIME', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata( htf.formcheckbox( 'P3', '2-DOWNLOAD_ORIGINAL_ANY_TIME' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     end if;
     htp.tabledata( LNG5.EXT_TXT_364, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
     if c1rec.download_web_any_time = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '2-DOWNLOAD_WEB_ANY_TIME', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata( htf.formcheckbox( 'P3', '2-DOWNLOAD_WEB_ANY_TIME' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     end if;
     htp.tabledata( LNG5.EXT_TXT_365, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
     if c1rec.download_original_on_purchase = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '2-DOWNLOAD_ORIGINAL_ON_PURCHASE', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata( htf.formcheckbox( 'P3', '2-DOWNLOAD_ORIGINAL_ON_PURCHASE' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     end if;
     htp.tabledata( LNG5.EXT_TXT_366, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
     if c1rec.download_prompt_details = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '2-DOWNLOAD_PROMPT_DETAILS', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata( htf.formcheckbox( 'P3', '2-DOWNLOAD_PROMPT_DETAILS' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     end if;
     htp.tabledata( LNG5.EXT_TXT_367, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
     if c1rec.download_web_on_purchase = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '2-DOWNLOAD_WEB_ON_PURCHASE', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata( htf.formcheckbox( 'P3', '2-DOWNLOAD_WEB_ON_PURCHASE' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     end if;
     htp.tabledata( LNG5.EXT_TXT_368, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
     if c1rec.download_auto_email_web = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '2-DOWNLOAD_AUTO_EMAIL_WEB', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata( htf.formcheckbox( 'P3', '2-DOWNLOAD_AUTO_EMAIL_WEB' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     end if;
     htp.tabledata( LNG5.EXT_TXT_369, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
     if c1rec.download_email_free = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '2-DOWNLOAD_EMAIL_FREE', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata( htf.formcheckbox( 'P3', '2-DOWNLOAD_EMAIL_FREE' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     end if;
     htp.tabledata( LNG5.EXT_TXT_630, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
    htp.tableclose;

   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tableclose;

  elsif disp_style = LNG5.EXT_TXT_406
   then
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
    htp.tablerowopen;
    htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );

    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( LNG.GLB_TXT_063, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( LNG.GLB_TXT_066, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      if c1rec.columns_swap_pay_confirm = 'T'
       then
        htp.tabledata( LNG5.EXT_TXT_186, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        htp.tabledata( LNG5.EXT_TXT_620, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        htp.tabledata( htf.formcheckbox( 'P3', '4-COLUMNS_SWAP_PAY_CONFIRM', 'CHECKED' ) || ' ' || LNG5.EXT_TXT_463, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( LNG5.EXT_TXT_620, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        htp.tabledata( LNG5.EXT_TXT_186, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        htp.tabledata( htf.formcheckbox( 'P3', '4-COLUMNS_SWAP_PAY_CONFIRM' ) || ' ' || LNG5.EXT_TXT_463, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
     htp.tablerowclose;

     htp.tablerowopen;
      if c1rec.disp_ord_summ = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_ORD_SUMM', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_ORD_SUMM' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_370 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      ord( 'P1', 'P2', '4-DISP_ORD_SUMM_ORDER', c1rec.disp_ord_summ_order, pfx );
      scr( 'P1', 'P2', '4-DISP_ORD_SUMM_COL', c1rec.disp_ord_summ_col, pfx );
      if c1rec.columns_swap_pay_confirm = 'T'
       then
        scr( 'P1', 'P2', '4-DISP_ORD_SUMM_COL3', c1rec.disp_ord_summ_col3, pfx );
        scr( 'P1', 'P2', '4-DISP_ORD_SUMM_COL2', c1rec.disp_ord_summ_col2, pfx );
       else
        scr( 'P1', 'P2', '4-DISP_ORD_SUMM_COL2', c1rec.disp_ord_summ_col2, pfx );
        scr( 'P1', 'P2', '4-DISP_ORD_SUMM_COL3', c1rec.disp_ord_summ_col3, pfx );
      end if;
      if c1rec.disp_ord_summ_matte = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_ORD_SUMM_MATTE', 'CHECKED' ) || ' ' || LNG5.EXT_TXT_442, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_ORD_SUMM_MATTE' ) || ' ' || LNG5.EXT_TXT_442, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
     htp.tablerowclose;

     htp.tablerowopen;
      if c1rec.disp_gift_wrap = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_GIFT_WRAP', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_GIFT_WRAP' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      -- xxx language file
      htp.tabledata( htf.bold( 'Display Purchase Options' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      ord( 'P1', 'P2', '4-DISP_GIFT_WRAP_ORDER', c1rec.disp_gift_wrap_order, pfx );
      scr( 'P1', 'P2', '4-DISP_GIFT_WRAP_COL', c1rec.disp_gift_wrap_col, pfx );
      if c1rec.columns_swap_pay_confirm = 'T'
       then
        scr( 'P1', 'P2', '4-DISP_GIFT_WRAP_COL3', c1rec.disp_gift_wrap_col3, pfx );
        scr( 'P1', 'P2', '4-DISP_GIFT_WRAP_COL2', c1rec.disp_gift_wrap_col2, pfx );
       else
        scr( 'P1', 'P2', '4-DISP_GIFT_WRAP_COL2', c1rec.disp_gift_wrap_col2, pfx );
        scr( 'P1', 'P2', '4-DISP_GIFT_WRAP_COL3', c1rec.disp_gift_wrap_col3, pfx );
      end if;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if c1rec.disp_ord_trk = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_ORD_TRK', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_ORD_TRK' ), cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_411 ), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"' );
      ord( 'P1', 'P2', '4-DISP_ORD_TRK_ORDER', c1rec.disp_ord_trk_order, pfx );
      scr( 'P1', 'P2', '4-DISP_ORD_TRK_COL', c1rec.disp_ord_trk_col, pfx );
      if c1rec.columns_swap_pay_confirm = 'T'
       then
        scr( 'P1', 'P2', '4-DISP_ORD_TRK_COL3', c1rec.disp_ord_trk_col3, pfx );
        scr( 'P1', 'P2', '4-DISP_ORD_TRK_COL2', c1rec.disp_ord_trk_col2, pfx );
       else
        scr( 'P1', 'P2', '4-DISP_ORD_TRK_COL2', c1rec.disp_ord_trk_col2, pfx );
        scr( 'P1', 'P2', '4-DISP_ORD_TRK_COL3', c1rec.disp_ord_trk_col3, pfx );
      end if;
      htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">' );
       htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
        htp.tablerowopen;
         htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2">' );
          if c1rec.disp_auto_create_tracking = 'T'
           then
            htp.formcheckbox( 'P3', '4-DISP_AUTO_CREATE_TRACKING', 'CHECKED' );
           else
            htp.formcheckbox( 'P3', '4-DISP_AUTO_CREATE_TRACKING');
          end if;
          htp.p( ' ' || LNG5.EXT_TXT_413 );
          htp.nl;
          htp.line;
         htp.p( '</TD>' );
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG5.EXT_TXT_414) );
         htp.tabledata( '&nbsp;' );
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( LNG5.EXT_TXT_415 );
         htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
          htp.formhidden( 'P1','4-DISP_ORD_TRK_EXPIRE_AT' );
          htp.formselectopen( 'P2' );
          if c1rec.disp_ord_trk_expire_at = 'N'
           then
            htp.formselectoption( LNG5.EXT_TXT_416, 'SELECTED',cattributes=>'VALUE="' || 'N' || '"' );
           else
            htp.formselectoption( LNG5.EXT_TXT_416, cattributes=>'VALUE="' || 'N' || '"' );
          end if;
          if c1rec.disp_ord_trk_expire_at = 'D'
           then
            htp.formselectoption( LNG5.EXT_TXT_417, 'SELECTED',cattributes=>'VALUE="' || 'D' || '"' );
           else
            htp.formselectoption( LNG5.EXT_TXT_417, cattributes=>'VALUE="' || 'D' || '"' );
          end if;
          if c1rec.disp_ord_trk_expire_at = 'S'
           then
            htp.formselectoption( LNG5.EXT_TXT_418, 'SELECTED',cattributes=>'VALUE="' || 'S' || '"' );
           else
            htp.formselectoption( LNG5.EXT_TXT_418, cattributes=>'VALUE="' || 'S' || '"' );
          end if;
          htp.formselectclose;
         htp.p( '</TD>' );
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( htf.formhidden( 'P1','4-DISP_ORD_TRK_EXPIRE_DATE' ) || LNG5.EXT_TXT_419 );

         htp.tabledata( htf.formtext( 'P2', 5, 20, c1rec.disp_ord_trk_expire_date ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( LNG5.EXT_TXT_420 );
         htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
          htp.formhidden( 'P1','4-DISP_ORD_TRK_EXPIRE_STATUS' );
          htp.formselectopen( 'P2' );
          htp.formselectoption( NULL );
          for c5rec in c5(0) loop
           if c1rec.disp_ord_trk_expire_status = c5rec.order_option
            then
             htp.formselectoption( c5rec.order_option, 'SELECTED' );
            else
             htp.formselectoption( c5rec.order_option );
           end if;
          end loop;
          htp.formselectclose;
         htp.p( '</TD>' );
        htp.tablerowclose;
      htp.tableclose;

      htp.p( '</TD>' );
     htp.tablerowclose;

     htp.tablerowopen;
      if c1rec.disp_cust = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_CUST', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_CUST' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_421 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      ord( 'P1', 'P2', '4-DISP_CUST_ORDER', c1rec.disp_cust_order, pfx );
      scr( 'P1', 'P2', '4-DISP_CUST_COL', c1rec.disp_cust_col, pfx );
      if c1rec.columns_swap_pay_confirm = 'T'
       then
        scr( 'P1', 'P2', '4-DISP_CUST_COL3', c1rec.disp_cust_col3, pfx );
        scr( 'P1', 'P2', '4-DISP_CUST_COL2', c1rec.disp_cust_col2, pfx );
       else
        scr( 'P1', 'P2', '4-DISP_CUST_COL2', c1rec.disp_cust_col2, pfx );
        scr( 'P1', 'P2', '4-DISP_CUST_COL3', c1rec.disp_cust_col3, pfx );
      end if;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if c1rec.disp_shipping = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_SHIPPING', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_SHIPPING' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_422 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      ord( 'P1', 'P2', '4-DISP_SHIPPING_ORDER', c1rec.disp_shipping_order, pfx );
      scr( 'P1', 'P2', '4-DISP_SHIPPING_COL', c1rec.disp_shipping_col, pfx );
      if c1rec.columns_swap_pay_confirm = 'T'
       then
        scr( 'P1', 'P2', '4-DISP_SHIPPING_COL3', c1rec.disp_shipping_col3, pfx );
        scr( 'P1', 'P2', '4-DISP_SHIPPING_COL2', c1rec.disp_shipping_col2, pfx );
       else
        scr( 'P1', 'P2', '4-DISP_SHIPPING_COL2', c1rec.disp_shipping_col2, pfx );
        scr( 'P1', 'P2', '4-DISP_SHIPPING_COL3', c1rec.disp_shipping_col3, pfx );
      end if;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if c1rec.disp_postage = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_POSTAGE', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_POSTAGE' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_423 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      ord( 'P1', 'P2', '4-DISP_POSTAGE_ORDER', c1rec.disp_postage_order, pfx );
      scr( 'P1', 'P2', '4-DISP_POSTAGE_COL', c1rec.disp_postage_col, pfx );
      if c1rec.columns_swap_pay_confirm = 'T'
       then
        scr( 'P1', 'P2', '4-DISP_POSTAGE_COL3', c1rec.disp_postage_col3, pfx );
        scr( 'P1', 'P2', '4-DISP_POSTAGE_COL2', c1rec.disp_postage_col2, pfx );
       else
        scr( 'P1', 'P2', '4-DISP_POSTAGE_COL2', c1rec.disp_postage_col2, pfx );
        scr( 'P1', 'P2', '4-DISP_POSTAGE_COL3', c1rec.disp_postage_col3, pfx );
      end if;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if c1rec.disp_payment_method = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_PAYMENT_METHOD', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_PAYMENT_METHOD' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_424 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      ord( 'P1', 'P2', '4-DISP_PAYMENT_METHOD_ORDER', c1rec.disp_payment_method_order, pfx );
      scr( 'P1', 'P2', '4-DISP_PAYMENT_METHOD_COL', c1rec.disp_payment_method_col, pfx );
      if c1rec.columns_swap_pay_confirm = 'T'
       then
        scr( 'P1', 'P2', '4-DISP_PAYMENT_METHOD_COL3', c1rec.disp_payment_method_col3, pfx );
        scr( 'P1', 'P2', '4-DISP_PAYMENT_METHOD_COL2', c1rec.disp_payment_method_col2, pfx );
       else
        scr( 'P1', 'P2', '4-DISP_PAYMENT_METHOD_COL2', c1rec.disp_payment_method_col2, pfx );
        scr( 'P1', 'P2', '4-DISP_PAYMENT_METHOD_COL3', c1rec.disp_payment_method_col3, pfx );
      end if;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if c1rec.disp_total = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_TOTAL', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_TOTAL' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_425 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      ord( 'P1', 'P2', '4-DISP_TOTAL_ORDER', c1rec.disp_total_order, pfx );
      scr( 'P1', 'P2', '4-DISP_TOTAL_COL', c1rec.disp_total_col, pfx );
      if c1rec.columns_swap_pay_confirm = 'T'
       then
        scr( 'P1', 'P2', '4-DISP_TOTAL_COL3', c1rec.disp_total_col3, pfx );
        scr( 'P1', 'P2', '4-DISP_TOTAL_COL2', c1rec.disp_total_col2, pfx );
       else
        scr( 'P1', 'P2', '4-DISP_TOTAL_COL2', c1rec.disp_total_col2, pfx );
        scr( 'P1', 'P2', '4-DISP_TOTAL_COL3', c1rec.disp_total_col3, pfx );
      end if;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    htp.tableclose;
    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-DISP_ORD_SUMM_TITLE' ) || htf.bold( LNG5.EXT_TXT_426 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 50, 100, c1rec.disp_ord_summ_title), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      -- xxx for language file
      htp.tabledata( htf.formhidden( 'P1','5-DISP_GIFT_WRAP_TITLE' ) || htf.bold( 'Heading Text for Purchase Options' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 50, 100, c1rec.disp_gift_wrap_title), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-DISP_ORD_TRK_TITLE' ) || htf.bold( LNG5.EXT_TXT_428 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 50, 100, c1rec.disp_ord_trk_title), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-DISP_CUST_TITLE' ) || htf.bold( LNG5.EXT_TXT_429 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 50, 100, c1rec.disp_cust_title), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-DISP_SHIPPING_TITLE' ) || htf.bold( LNG5.EXT_TXT_430 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 50, 100, c1rec.disp_shipping_title), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-DISP_POSTAGE_TITLE' ) || htf.bold( LNG5.EXT_TXT_432 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 50, 100, c1rec.disp_postage_title), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-DISP_PAYMENT_METHOD_TITLE' ) || htf.bold( LNG5.EXT_TXT_433 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 50, 100, c1rec.disp_payment_method_title), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-DISP_TOTAL_TITLE' ) || htf.bold( LNG5.EXT_TXT_434 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 50, 100, c1rec.disp_total_title), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

    htp.tableclose;
    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );

     -- xxx language file
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_PAGE0' ) || htf.bold( '0. ' || 'User Fees' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 50, 100, c1rec.text_page0 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_PAGE1' ) || htf.bold( '1. ' || LNG5.EXT_TXT_435 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 50, 100, c1rec.text_page1 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_PAGE2' ) || htf.bold( '2. ' || LNG5.EXT_TXT_436 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 50, 100, c1rec.text_page2 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

    if c1rec.columns_swap_pay_confirm = 'F'
     then
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1','5-TEXT_PAGE3' ) || htf.bold( '3. ' || LNG5.EXT_TXT_437 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.formtext( 'P2', 50, 100, c1rec.text_page3 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1','5-TEXT_PAGE4' ) || htf.bold( '4. ' || LNG5.EXT_TXT_438 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.formtext( 'P2', 50, 100, c1rec.text_page4 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tablerowclose;
     else
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1','5-TEXT_PAGE4' ) || htf.bold( '3. ' || LNG5.EXT_TXT_438 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.formtext( 'P2', 50, 100, c1rec.text_page4 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1','5-TEXT_PAGE3' ) || htf.bold( '4. ' || LNG5.EXT_TXT_437 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.formtext( 'P2', 50, 100, c1rec.text_page3 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tablerowclose;
    end if;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_PAGE5' ) || htf.bold( '5. ' || LNG5.EXT_TXT_439 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 50, 100, c1rec.text_page5 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    htp.tableclose;
    htp.nl;
    htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tableclose;

  elsif disp_style = LNG5.EXT_TXT_261
   then
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
    htp.tablerowopen;
    htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );

    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      if c1rec.disp_recent = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_RECENT', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_RECENT' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata(htf.formhidden( 'P1','4-DISP_RECENT_NMB' ) || htf.bold( LNG5.EXT_TXT_440 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
       htp.p( LNG5.EXT_TXT_441 || ' ' || htf.formtext( 'P2', 10, 10, to_char(c1rec.disp_recent_nmb) ));
       htp.nl;
       if c1rec.disp_recent_frame = 'T'
        then
         htp.formcheckbox( 'P3', '4-DISP_RECENT_FRAME', 'CHECKED' );
        else
         htp.formcheckbox( 'P3', '4-DISP_RECENT_FRAME' );
       end if;
       htp.p( ' ' || LNG5.EXT_TXT_442 );
       htp.nl;
       if c1rec.disp_recent_top = 'T'
        then
         htp.formcheckbox( 'P3', '4-DISP_RECENT_TOP', 'CHECKED' );
        else
         htp.formcheckbox( 'P3', '4-DISP_RECENT_TOP' );
       end if;
       htp.p( ' ' || LNG5.EXT_TXT_443 );
      htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.disp_most_pop = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_MOST_POP', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_MOST_POP' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1','4-DISP_MOST_POP_NMB' ) || htf.bold( LNG5.EXT_TXT_444 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
       htp.p( LNG5.EXT_TXT_441 || ' ' || htf.formtext( 'P2', 10, 10, to_char(c1rec.disp_most_pop_nmb) ));
       htp.nl;
       if c1rec.disp_most_frame = 'T'
        then
         htp.formcheckbox( 'P3', '4-DISP_MOST_FRAME', 'CHECKED' );
        else
         htp.formcheckbox( 'P3', '4-DISP_MOST_FRAME' );
       end if;
       htp.p( ' ' || LNG5.EXT_TXT_442 );
       htp.nl;
       if c1rec.disp_most_top = 'T'
        then
         htp.formcheckbox( 'P3', '4-DISP_MOST_TOP', 'CHECKED' );
        else
         htp.formcheckbox( 'P3', '4-DISP_MOST_TOP' );
       end if;
       htp.p( ' ' || LNG5.EXT_TXT_443 );
      htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;
    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      if c1rec.disp_goto_order_pge = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_GOTO_ORDER_PGE', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_GOTO_ORDER_PGE' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_445 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.disp_cntry_fnl_pge = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_CNTRY_FNL_PGE', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_CNTRY_FNL_PGE' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_446 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     -- xxx for language file
     htp.tablerowopen;
      if c1rec.pricing_internal = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-PRICING_INTERNAL', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-PRICING_INTERNAL' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'Enable Internal Charge Pricing (Disable display of Price Information in Basket)' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    htp.tableclose;

    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      if c1rec.disp_graphic_button = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_GRAPHIC_BUTTON', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_GRAPHIC_BUTTON' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_447 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.disp_popup = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_POPUP', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_POPUP' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_448 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.disp_border = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-BORDER', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-BORDER' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_449 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if c1rec.disp_show_currency = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_SHOW_CURRENCY', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_SHOW_CURRENCY' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_450 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.disp_show_convert = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_SHOW_CONVERT', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_SHOW_CONVERT' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_451 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.disp_tracking_ctr = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_TRACKING_CTR', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_TRACKING_CTR' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( 'Display Basket Total Counter' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
       htp.bold( 'Remove Item from Basket - Display Style' );
       htp.formhidden( 'P1', 'DISP_REMOVE_STYLE' );
       htp.formselectopen( 'P2' );
        if c1rec.disp_remove_style = 'N'
         then
          htp.formselectoption( 'No Option','SELECTED', cattributes=>'VALUE="' || 'N' || '"' );
         else
          htp.formselectoption( 'No Option', cattributes=>'VALUE="' || 'N' || '"' );
        end if;
        if c1rec.disp_remove_style = 'L'
         then
          htp.formselectoption( 'Link','SELECTED', cattributes=>'VALUE="' || 'L' || '"' );
         else
          htp.formselectoption( 'Link', cattributes=>'VALUE="' || 'L' || '"' );
        end if;
        if c1rec.disp_remove_style = 'C'
         then
          htp.formselectoption( 'Checkbox','SELECTED', cattributes=>'VALUE="' || 'C' || '"' );
         else
          htp.formselectoption( 'Checkbox', cattributes=>'VALUE="' || 'C' || '"' );
        end if;
       htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;

    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      if c1rec.disp_receipt = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_RECEIPT', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_RECEIPT' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_489 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.disp_receipt_print = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_RECEIPT_PRINT', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_RECEIPT_PRINT' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_490 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.disp_show_tnail_on_receipt = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_SHOW_TNAIL_ON_RECEIPT', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_SHOW_TNAIL_ON_RECEIPT' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_501 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    htp.tableclose;

    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      if c1rec.disp_email_customer = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_EMAIL_CUSTOMER', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_EMAIL_CUSTOMER' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_491 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.disp_email_phg = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_EMAIL_PHG', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_EMAIL_PHG' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_492 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    htp.tableclose;

    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
    if substr(theme_rec.theme_data,80,1) = 'T'
     then
       htp.tablerowopen;
        if c1rec.disp_auto_create_on_purchase = 'T'
         then
          htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_AUTO_CREATE_ON_PURCHASE', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
         else
          htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_AUTO_CREATE_ON_PURCHASE' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        end if;
        htp.tabledata( htf.bold( LNG5.EXT_TXT_493 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tablerowclose;
       htp.tablerowopen;
        if c1rec.disp_email_is_username = 'T'
         then
          htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_EMAIL_IS_USERNAME', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
         else
          htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_EMAIL_IS_USERNAME' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        end if;
        htp.tabledata( htf.bold( LNG5.EXT_TXT_494 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tablerowclose;
       htp.tablerowopen;
        if c1rec.disp_prompt_create_acct = 'T'
         then
          htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_PROMPT_CREATE_ACCT', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
         else
          htp.tabledata( htf.formcheckbox( 'P3', '4-DISP_PROMPT_CREATE_ACCT' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        end if;
        htp.tabledata( htf.bold( LNG5.EXT_TXT_495 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tablerowclose;
     end if;
    htp.tableclose;
    htp.nl;

    htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tableclose;

  elsif disp_style = LNG5.EXT_TXT_262
   then
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1 width="80%"' );

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_CHECKOUT_BUTTON' ) || htf.bold( LNG5.EXT_TXT_496 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_checkout_button ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_RECALCULATE_BUTTON' ) || htf.bold( LNG5.EXT_TXT_497 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_recalculate_button ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_EMPTY_BASKET_BUTTON' ) || htf.bold( LNG5.EXT_TXT_498 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_empty_basket_button ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_LOGOFF' ) || htf.bold( LNG5.EXT_TXT_499 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_logoff ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     -- xxx language file
     if substr(theme_rec.theme_data,369,1) = 'T'
      then
       htp.tablerowopen;
        htp.tabledata( htf.formhidden( 'P1','5-TEXT_USERFEE' ) || htf.bold( 'User Fee Navigate Back Button' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_userfee ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tablerowclose;
     end if;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_RETURN_BUTTON' ) || htf.bold( LNG5.EXT_TXT_466 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_return_button ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_PROCEED_BUTTON' ) || htf.bold( LNG5.EXT_TXT_467 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_proceed_button ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_CONFIRM_BUTTON' ) || htf.bold( LNG5.EXT_TXT_469 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_confirm_button ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

    htp.tableclose;
    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1 width="80%"' );
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_SHOPPING_BASKET' ) || htf.bold( LNG5.EXT_TXT_500 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 80, 1000, c1rec.text_shopping_basket ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_SUBTOTAL' ) || htf.bold( LNG5.EXT_TXT_502 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_subtotal ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_GRANDTOTAL' ) || htf.bold( LNG5.EXT_TXT_503 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_grandtotal ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    htp.tableclose;

    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1 width="80%"' );
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_THUMBNAIL' ) || htf.bold( LNG5.EXT_TXT_504 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_thumbnail ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_IMAGE_TITLE' ) || htf.bold( LNG5.EXT_TXT_505 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_image_title ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_QTY' ) || htf.bold( LNG5.EXT_TXT_506 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_qty ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_SUBTOTAL_TITLE' ) || htf.bold( LNG5.EXT_TXT_507 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_subtotal_title ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_REMOVE_FROM' ) || htf.bold( LNG5.EXT_TXT_468 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 1000, replace(replace(replace(c1rec.text_remove_from,'"','&#34;' ),'<','&lt;'),'>','&gt;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    htp.tableclose;

    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1 width="80%"' );

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_PHG_TITLE' ) || htf.bold( LNG5.EXT_TXT_508 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 1000, c1rec.text_phg_title ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_HOME1' ) || htf.bold( LNG5.EXT_TXT_574 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 1000, c1rec.text_home1 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_HOME2' ) || htf.bold( LNG5.EXT_TXT_575 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 1000, c1rec.text_home2 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_PURCHASE_REQUEST' ) || htf.bold( LNG5.EXT_TXT_473 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 1000, c1rec.text_purchase_request ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_RETURN_MESSAGE' ) || htf.bold( LNG5.EXT_TXT_552 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 1000, c1rec.text_return_message ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_ON_EMPTY_BASKET' ) || htf.bold( LNG5.EXT_TXT_510 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_on_empty_basket ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_PHONE_MESSAGE' ) || htf.bold( LNG5.EXT_TXT_511 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 4000, c1rec.text_phone_message ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_PRINT_CHEQUE' ) || htf.bold( LNG5.EXT_TXT_512 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 1000, c1rec.text_print_cheque ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_CANCEL_ORDER' ) || htf.bold( LNG5.EXT_TXT_513 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 4000, c1rec.text_cancel_order ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

    htp.tableclose;
    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1 width="80%"' );

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_MESSAGE_UNDER_TOTAL' ) || htf.bold( LNG5.EXT_TXT_470 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_message_under_total ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_MOST_POPULAR' ) || htf.bold( LNG5.EXT_TXT_514 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_most_popular ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_RECENT_PURCHASED' ) || htf.bold( LNG5.EXT_TXT_515 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_recent_purchased ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    htp.tableclose;
    htp.nl;

  elsif disp_style = LNG5.EXT_TXT_405
   then
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1 width="80%"' );
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_LOGON_TITLE' ) || htf.bold( LNG5.EXT_TXT_516 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_logon_title ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_UNSOLICITED_EMAIL' ) || htf.bold( LNG5.EXT_TXT_517 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_unsolicited_email ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_ACCEPT' ) || htf.bold( LNG5.EXT_TXT_518 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_accept ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_DECLINE' ) || htf.bold( LNG5.EXT_TXT_519 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 80, 100, c1rec.text_decline ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_DISCLAIMER' ) || htf.bold( LNG5.EXT_TXT_520 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtextareaopen( 'P2', 3, 60, cattributes=>'WRAP="VIRTUAL"' ) || c1rec.text_disclaimer || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_PRIVACY' ) || htf.bold( LNG5.EXT_TXT_521 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtextareaopen( 'P2', 3, 60, cattributes=>'WRAP="VIRTUAL"' ) || c1rec.text_privacy || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    htp.tableclose;
    htp.nl;

  elsif disp_style = LNG5.EXT_TXT_263
   then
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1 width="80%"' );

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_DELAYED_PRICING' ) || htf.bold( LNG5.EXT_TXT_522 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtextareaopen( 'P2', 3, 60, cattributes=>'WRAP="VIRTUAL"' ) || c1rec.text_delayed_pricing || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_ALT_PRICE_BOOK' ) || htf.bold( LNG5.EXT_TXT_523 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtextareaopen( 'P2', 3, 60, cattributes=>'WRAP="VIRTUAL"' ) || c1rec.text_alt_price_book || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_PURCH_WARNING' ) || htf.bold( LNG5.EXT_TXT_524 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtextareaopen( 'P2', 3, 60, cattributes=>'WRAP="VIRTUAL"' ) || c1rec.text_purch_warning || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_HELP_SHOPPING' ) || htf.bold( LNG5.EXT_TXT_525 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtextareaopen( 'P2', 3, 60, cattributes=>'WRAP="VIRTUAL"' ) || c1rec.text_help_shopping || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata(  htf.formhidden( 'P1','5-TEXT_HELP_PURCHASE' ) || htf.bold( LNG5.EXT_TXT_526 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtextareaopen( 'P2', 3, 60, cattributes=>'WRAP="VIRTUAL"' ) || c1rec.text_help_purchase || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      -- xxx language 5 fix
      htp.tabledata(  htf.formhidden( 'P1','5-TEXT_HELP_PURCHASE2' ) || htf.bold( LNG5.EXT_TXT_526 || '(' || 'Payment Page' || ')' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtextareaopen( 'P2', 3, 60, cattributes=>'WRAP="VIRTUAL"' ) || c1rec.text_help_purchase2 || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      -- xxx language 5 fix
      htp.tabledata(  htf.formhidden( 'P1','5-TEXT_CANCEL_MSG' ) || htf.bold( 'Cancel Message' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtextareaopen( 'P2', 3, 60, cattributes=>'WRAP="VIRTUAL"' ) || replace(replace(replace(c1rec.text_cancel_msg,'"','&#34;' ),'<','&lt;'),'>','&gt;' ) || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_ONLOGOUT_ITM' ) || htf.bold( LNG5.EXT_TXT_527 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtextareaopen( 'P2', 3, 60, cattributes=>'WRAP="VIRTUAL"' ) || c1rec.text_onlogout_itm || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-PACKAGED_PRODUCT_DISPLAY' ) || htf.bold( 'Package Product Coding' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtextareaopen( 'P2', 3, 60, cattributes=>'WRAP="VIRTUAL"' ) || replace(replace(replace(c1rec.packaged_product_display,'"','&#34;' ),'<','&lt;'),'>','&gt;' ) || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-TEXT_MERCHANT_WARNING' ) || htf.bold( 'Merchant Warning Message' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtextareaopen( 'P2', 3, 60, cattributes=>'WRAP="VIRTUAL"' ) || replace(replace(replace(c1rec.text_merchant_warning,'"','&#34;' ),'<','&lt;'),'>','&gt;' ) || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-FAX_MERCHANT_TEXT_ABOVE' ) || htf.bold( 'Cheque Order - Merchant Text Above' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtextareaopen( 'P2', 3, 60, cattributes=>'WRAP="VIRTUAL"' ) || replace(replace(replace(c1rec.fax_merchant_text_above,'"','&#34;' ),'<','&lt;'),'>','&gt;' ) || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1','5-FAX_MERCHANT_TEXT_BELOW' ) || htf.bold( 'Cheque Order - Merchant Text Below' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtextareaopen( 'P2', 3, 60, cattributes=>'WRAP="VIRTUAL"' ) || replace(replace(replace(c1rec.fax_merchant_text_below,'"','&#34;' ),'<','&lt;'),'>','&gt;' ) || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

    htp.tableclose;
    htp.nl;

  elsif disp_style = LNG.CST_TXT_005
   then
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.CST_TXT_005 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER" COLSPAN="2"' );
      htp.tabledata( htf.bold( 'Prompt for<BR>On Login' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER" COLSPAN="2"' );
      htp.tabledata( htf.bold( 'Columns' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER" COLSPAN="2"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold( 'Display' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( 'Mandatory' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( 'Display' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( 'Mandatory' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( 'Name' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( 'Display Text' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,1,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-NAME', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-NAME' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,1,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-NAME-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-NAME-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,1,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-NAME-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-NAME-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,1,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-NAME-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-NAME-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;

      if nvl(c1rec.columns_name_toggle,'T') = 'T'
       then
        htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_NAME' ) || htf.bold( 'Name' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_name ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_FIRSTNAME' ) || htf.bold( 'First Name' ) || htf.nl ||
                       htf.formhidden( 'P1', '6-COLUMNS_LASTNAME' ) || htf.bold( 'Last Name' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_firstname ) || htf.nl ||
                       htf.formtext( 'P2', 30, 100, c1rec.columns_lastname ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.bold( 'Use One Name (or First Name/Last Name)' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT" COLSPAN="5"' );
      if nvl(c1rec.columns_name_toggle,'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_NAME_TOGGLE', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_NAME_TOGGLE' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
     htp.tablerowclose;

     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,20,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-BRANCH', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-BRANCH' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,20,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-BRANCH-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-BRANCH-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,20,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-BRANCH-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-BRANCH-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,20,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-BRANCH-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-BRANCH-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_BRANCH' ) || htf.bold( 'Branch' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_branch ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,21,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-DEPARTMENT', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-DEPARTMENT' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,21,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-DEPARTMENT-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-DEPARTMENT-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,21,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-DEPARTMENT-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-DEPARTMENT-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,21,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-DEPARTMENT-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-DEPARTMENT-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_DEPARTMENT' ) || htf.bold( 'Department' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_department ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,2,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-STREET', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-STREET' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,2,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-STREET-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-STREET-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,2,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-STREET-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-STREET-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,2,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-STREET-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-STREET-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_STREET' ) || htf.bold( 'Street' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_street ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,3,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-SUBURB', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-SUBURB' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,3,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-SUBURB-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-SUBURB-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,3,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-SUBURB-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-SUBURB-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,3,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-SUBURB-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-SUBURB-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_SUBURB' ) || htf.bold( 'Suburb' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_suburb ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,4,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-CITY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-CITY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,4,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-CITY-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-CITY-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,4,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-CITY-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-CITY-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,4,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-CITY-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-CITY-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_CITY' ) || htf.bold( 'City' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_city ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,17,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-STATE', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-STATE' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,17,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-STATE-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-STATE-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,19,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-STATE-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-STATE-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,19,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-STATE-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-STATE-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_STATE' ) || htf.bold( 'State' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_state ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,5,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-POSTCODE', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-POSTCODE' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,5,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-POSTCODE-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-POSTCODE-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,5,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-POSTCODE-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-POSTCODE-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,5,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-POSTCODE-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-POSTCODE-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_POSTCODE' ) || htf.bold( 'Post Code' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_postcode ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,6,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COUNTRY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COUNTRY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,6,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COUNTRY-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COUNTRY-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,6,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COUNTRY-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COUNTRY-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,6,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COUNTRY-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COUNTRY-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_COUNTRY' ) || htf.bold( LNG.CST_TXT_116 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_country ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,7,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-PHONE', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-PHONE' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,7,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-PHONE-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-PHONE-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,7,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-PHONE-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-PHONE-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,7,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-PHONE-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-PHONE-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_PHONE' ) || htf.bold( LNG.ORD_TXT_180 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_phone ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,8,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-EMAIL', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-EMAIL' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,8,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-EMAIL-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-EMAIL-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,8,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-EMAIL-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-EMAIL-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,8,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-EMAIL-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-EMAIL-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      htp.bold( initcap(LNG3.ADM_TXT_612) );
      htp.nl;
      if c1rec.columns_email_unique = 'T'
       then
        htp.formcheckbox( 'P3', '6-COLUMNS_EMAIL_UNIQUE', 'CHECKED' );
       else
        htp.formcheckbox( 'P3', '6-COLUMNS_EMAIL_UNIQUE' );
      end if;
      htp.p( 'Is Unique Across all Profiles' );
      htp.p( '</TD>' );

      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_EMAIL' ) || htf.formtext( 'P2', 30, 100, c1rec.columns_email ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,9,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-CUSTOMER_COMMENT', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-CUSTOMER_COMMENT' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,9,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-CUSTOMER_COMMENT-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-CUSTOMER_COMMENT-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,9,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-CUSTOMER_COMMENT-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-CUSTOMER_COMMENT-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,9,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-CUSTOMER_COMMENT-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-CUSTOMER_COMMENT-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_COMMENT' ) || htf.bold( 'Customer Comment' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_comment ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,11,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL1', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL1' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,11,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL1-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL1-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,13,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL1-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL1-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,13,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL1-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL1-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_CUST_COL1' ) || htf.bold( 'User Defined Column' || '1' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_cust_col1 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,12,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL2', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL2' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,12,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL2-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL2-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,14,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL2-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL2-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,14,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL2-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL2-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_CUST_COL2' ) || htf.bold( 'User Defined Column' || '2' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_cust_col2 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,13,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL3', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL3' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,13,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL3-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL3-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,15,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL3-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL3-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,15,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL3-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL3-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_CUST_COL3' ) || htf.bold( 'User Defined Column' || '3' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_cust_col3 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,14,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL4', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL4' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,14,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL4-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL4-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,16,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL4-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL4-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,16,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL4-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL4-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_CUST_COL4' ) || htf.bold( 'User Defined Column' || '4' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_cust_col4 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,15,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL5', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL5' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,15,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL5-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL5-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,17,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL5-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL5-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,17,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL5-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL5-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_CUST_COL5' ) || htf.bold( 'User Defined Column' || '5' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_cust_col5 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,16,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL6', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL6' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,16,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL6-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL6-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_on_login,18,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL6-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL6-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory_on_login,18,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL6-ON_LOGIN-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_CUST_COL6-ON_LOGIN-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_CUST_COL6' ) || htf.bold( 'User Defined Column' || '6' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_cust_col6 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      if nvl(substr(c1rec.columns_display,10,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-DO_NOT_SPLIT_ORDER', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-DO_NOT_SPLIT_ORDER' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      if nvl(substr(c1rec.columns_mandatory,10,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-DO_NOT_SPLIT_ORDER-MANDATORY', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-DO_NOT_SPLIT_ORDER-MANDATORY' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formhidden( 'P1', '6-COLUMNS_SPLIT' ) || htf.bold( LNG4.AHC_TXT_772 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.columns_split ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      if nvl(substr(c1rec.columns_on_login,11,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-DISCLAIMER-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-DISCLAIMER-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( 'Disclaimer' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      if nvl(substr(c1rec.columns_on_login,12,1),'T') = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-UNSOLICITED-ON_LOGIN', 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-UNSOLICITED-ON_LOGIN' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( 'Check Unsolicited Email Prompt' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    htp.tableclose;

    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      if c1rec.columns_mark_bold = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_MARK_BOLD', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_MARK_BOLD' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_577 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.columns_mark_italic = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_MARK_ITALIC', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_MARK_ITALIC' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_578 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.columns_mark_ast = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_MARK_AST', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_MARK_AST' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_579 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.columns_smart_check = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_SMART_CHECK', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_SMART_CHECK' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_580 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.columns_simple_address = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_SIMPLE_ADDRESS', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_SIMPLE_ADDRESS' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_465 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if c1rec.columns_update_contact = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_UPDATE_CONTACT', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-COLUMNS_UPDATE_CONTACT' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_474 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    htp.tableclose;

    htp.nl;
    htp.bold( 'Display External HTML on Login instead of Purpose Built Page' );
    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( 'External Template Name' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formhidden( 'P1', '6-LOGIN_HTML_TEMPLATE' ) || htf.formtext( 'P2', 50, 100, c1rec.login_html_template ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold( 'External Template Sub Directory' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formhidden( 'P1', '6-LOGIN_HTML_SUBDIR' ) || htf.formtext( 'P2', 50, 100, c1rec.login_html_subdir ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    htp.tableclose;

  elsif disp_style = LNG5.EXT_TXT_264
   then
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.GLB_TXT_063 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( LNG5.EXT_TXT_528 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( LNG5.EXT_TXT_529 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( LNG5.EXT_TXT_530), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_581 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.formhidden( 'P1','7-WORKFLOW_CC_START' );
       tmp := htf.formselectopen( 'P2' );
         for c5rec in c5(0) loop
          if c1rec.workflow_cc_start = c5rec.order_option
           then
            tmp := tmp || htf.formselectoption( c5rec.order_option, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c5rec.order_option );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.formhidden( 'P1','7-WORKFLOW_CC_MFCTR' );
       tmp := htf.formselectopen( 'P2' );
         for c5rec in c5(0) loop
          if c1rec.workflow_cc_mfctr = c5rec.order_option
           then
            tmp := tmp || htf.formselectoption( c5rec.order_option, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c5rec.order_option );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.formhidden( 'P1','7-WORKFLOW_CC_DELIVERY' );
       tmp := htf.formselectopen( 'P2' );
         for c5rec in c5(0) loop
          if c1rec.workflow_cc_delivery = c5rec.order_option
           then
            tmp := tmp || htf.formselectoption( c5rec.order_option, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c5rec.order_option );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_276 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.formhidden( 'P1','7-WORKFLOW_CHEQUE_START' );
       tmp := htf.formselectopen( 'P2' );
         for c5rec in c5(0) loop
          if c1rec.workflow_cheque_start = c5rec.order_option
           then
            tmp := tmp || htf.formselectoption( c5rec.order_option, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c5rec.order_option );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.formhidden( 'P1','7-WORKFLOW_CHEQUE_MFCTR' );
       tmp := htf.formselectopen( 'P2' );
         for c5rec in c5(0) loop
          if c1rec.workflow_cheque_mfctr = c5rec.order_option
           then
            tmp := tmp || htf.formselectoption( c5rec.order_option, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c5rec.order_option );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.formhidden( 'P1','7-WORKFLOW_CHEQUE_DELIVERY' );
       tmp := htf.formselectopen( 'P2' );
         for c5rec in c5(0) loop
          if c1rec.workflow_cheque_delivery = c5rec.order_option
           then
            tmp := tmp || htf.formselectoption( c5rec.order_option, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c5rec.order_option );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.ORD_TXT_180 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.formhidden( 'P1','7-WORKFLOW_PHONE_START' );
       tmp := htf.formselectopen( 'P2' );
         for c5rec in c5(0) loop
          if c1rec.workflow_phone_start = c5rec.order_option
           then
            tmp := tmp || htf.formselectoption( c5rec.order_option, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c5rec.order_option );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.formhidden( 'P1','7-WORKFLOW_PHONE_MFCTR' );
       tmp := htf.formselectopen( 'P2' );
         for c5rec in c5(0) loop
          if c1rec.workflow_phone_mfctr = c5rec.order_option
           then
            tmp := tmp || htf.formselectoption( c5rec.order_option, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c5rec.order_option );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.formhidden( 'P1','7-WORKFLOW_PHONE_DELIVERY' );
       tmp := htf.formselectopen( 'P2' );
         for c5rec in c5(0) loop
          if c1rec.workflow_phone_delivery = c5rec.order_option
           then
            tmp := tmp || htf.formselectoption( c5rec.order_option, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c5rec.order_option );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_277 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.formhidden( 'P1','7-WORKFLOW_BILLING_START' );
       tmp := htf.formselectopen( 'P2' );
         for c5rec in c5(0) loop
          if c1rec.workflow_billing_start = c5rec.order_option
           then
            tmp := tmp || htf.formselectoption( c5rec.order_option, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c5rec.order_option );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.formhidden( 'P1','7-WORKFLOW_BILLING_MFCTR' );
       tmp := htf.formselectopen( 'P2' );
         for c5rec in c5(0) loop
          if c1rec.workflow_billing_mfctr = c5rec.order_option
           then
            tmp := tmp || htf.formselectoption( c5rec.order_option, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c5rec.order_option );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.formhidden( 'P1','7-WORKFLOW_BILLING_DELIVERY' );
       tmp := htf.formselectopen( 'P2' );
         for c5rec in c5(0) loop
          if c1rec.workflow_billing_delivery = c5rec.order_option
           then
            tmp := tmp || htf.formselectoption( c5rec.order_option, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c5rec.order_option );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_278 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.formhidden( 'P1','7-WORKFLOW_AUTH_START' );
       tmp := htf.formselectopen( 'P2' );
         for c5rec in c5(0) loop
          if c1rec.workflow_auth_start = c5rec.order_option
           then
            tmp := tmp || htf.formselectoption( c5rec.order_option, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c5rec.order_option );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.formhidden( 'P1','7-WORKFLOW_AUTH_MFCTR' );
       tmp := htf.formselectopen( 'P2' );
         for c5rec in c5(0) loop
          if c1rec.workflow_auth_mfctr = c5rec.order_option
           then
            tmp := tmp || htf.formselectoption( c5rec.order_option, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c5rec.order_option );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.formhidden( 'P1','7-WORKFLOW_AUTH_DELIVERY' );
       tmp := htf.formselectopen( 'P2' );
         for c5rec in c5(0) loop
          if c1rec.workflow_auth_delivery = c5rec.order_option
           then
            tmp := tmp || htf.formselectoption( c5rec.order_option, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c5rec.order_option );
          end if;
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    htp.tableclose;

    if substr(theme_rec.theme_data,409,1) = 'T'
     then
      htp.nl;
      htp.bold( LNG5.EXT_TXT_582 );
      htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
       htp.tablerowopen;
        htp.tabledata( htf.formhidden( 'P1', '8-WORKFLOW_BOOKING_EDUCATION' ) || htf.bold( LNG5.EXT_TXT_583 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
         htp.formselectopen( 'P2' );
          for c16rec in c16(owner_id) loop
           if c1rec.workflow_booking_education = c16rec.status_workflow
            then
             htp.formselectoption( c16rec.workflow_name, 'SELECTED', cattributes=>'VALUE="' || c16rec.status_workflow || '"' );
            else
             htp.formselectoption( c16rec.workflow_name, cattributes=>'VALUE="' || c16rec.status_workflow || '"' );
           end if;
          end loop;
         htp.formselectclose;
        htp.p( '</TD>' );
       htp.tablerowclose;
       htp.tablerowopen;
        htp.tabledata( htf.formhidden( 'P1', '8-WORKFLOW_BOOKING_EVENTS' ) || htf.bold( 'Events' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
         htp.formselectopen( 'P2' );
          for c16rec in c16(owner_id) loop
           if c1rec.workflow_booking_events = c16rec.status_workflow
            then
             htp.formselectoption( c16rec.workflow_name, 'SELECTED', cattributes=>'VALUE="' || c16rec.status_workflow || '"' );
            else
             htp.formselectoption( c16rec.workflow_name, cattributes=>'VALUE="' || c16rec.status_workflow || '"' );
           end if;
          end loop;
         htp.formselectclose;
        htp.p( '</TD>' );
       htp.tablerowclose;
       htp.tablerowopen;
        htp.tabledata( htf.formhidden( 'P1', '8-WORKFLOW_BOOKING_VISIT' ) || htf.bold( 'Visit' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
         htp.formselectopen( 'P2' );
          for c16rec in c16(owner_id) loop
           if c1rec.workflow_booking_visit = c16rec.status_workflow
            then
             htp.formselectoption( c16rec.workflow_name, 'SELECTED', cattributes=>'VALUE="' || c16rec.status_workflow || '"' );
            else
             htp.formselectoption( c16rec.workflow_name, cattributes=>'VALUE="' || c16rec.status_workflow || '"' );
           end if;
          end loop;
         htp.formselectclose;
        htp.p( '</TD>' );
       htp.tablerowclose;
       htp.tablerowopen;
        htp.tabledata( htf.formhidden( 'P1', '8-WORKFLOW_BOOKING_COMM' ) || htf.bold( 'Commercial' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
         htp.formselectopen( 'P2' );
          for c16rec in c16(owner_id) loop
           if c1rec.workflow_booking_comm = c16rec.status_workflow
            then
             htp.formselectoption( c16rec.workflow_name, 'SELECTED', cattributes=>'VALUE="' || c16rec.status_workflow || '"' );
            else
             htp.formselectoption( c16rec.workflow_name, cattributes=>'VALUE="' || c16rec.status_workflow || '"' );
           end if;
          end loop;
         htp.formselectclose;
        htp.p( '</TD>' );
       htp.tablerowclose;
       htp.tablerowopen;
        htp.tabledata( htf.formhidden( 'P1', '8-WORKFLOW_BOOKING_OTHER1' ) || htf.bold( 'Other 1' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
         htp.formselectopen( 'P2' );
          for c16rec in c16(owner_id) loop
           if c1rec.workflow_booking_other1 = c16rec.status_workflow
            then
             htp.formselectoption( c16rec.workflow_name, 'SELECTED', cattributes=>'VALUE="' || c16rec.status_workflow || '"' );
            else
             htp.formselectoption( c16rec.workflow_name, cattributes=>'VALUE="' || c16rec.status_workflow || '"' );
           end if;
          end loop;
         htp.formselectclose;
        htp.p( '</TD>' );
       htp.tablerowclose;
       htp.tablerowopen;
        htp.tabledata( htf.formhidden( 'P1', '8-WORKFLOW_BOOKING_OTHER2' ) || htf.bold( 'Other 2' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
         htp.formselectopen( 'P2' );
          for c16rec in c16(owner_id) loop
           if c1rec.workflow_booking_other2 = c16rec.status_workflow
            then
             htp.formselectoption( c16rec.workflow_name, 'SELECTED', cattributes=>'VALUE="' || c16rec.status_workflow || '"' );
            else
             htp.formselectoption( c16rec.workflow_name, cattributes=>'VALUE="' || c16rec.status_workflow || '"' );
           end if;
          end loop;
         htp.formselectclose;
        htp.p( '</TD>' );
       htp.tablerowclose;
       htp.tablerowopen;
        htp.tabledata( htf.formhidden( 'P1', '8-WORKFLOW_BOOKING_OTHER3' ) || htf.bold( 'Other 3' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
         htp.formselectopen( 'P2' );
          for c16rec in c16(owner_id) loop
           if c1rec.workflow_booking_other3 = c16rec.status_workflow
            then
             htp.formselectoption( c16rec.workflow_name, 'SELECTED', cattributes=>'VALUE="' || c16rec.status_workflow || '"' );
            else
             htp.formselectoption( c16rec.workflow_name, cattributes=>'VALUE="' || c16rec.status_workflow || '"' );
           end if;
          end loop;
         htp.formselectclose;
        htp.p( '</TD>' );
       htp.tablerowclose;
     htp.tableclose;
    end if;
    htp.nl;

  elsif disp_style = LNG.PHG_TXT_352
   then
    htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1', '8-RENAME' ) || htf.bold( 'Rename to' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1', '8-COPY' ) || htf.bold( 'Copy to' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

      htp.tabledata( htf.formtext( 'P2', 30, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1', '8-DIFFERENCES' ) || htf.bold( LNG5.EXT_TXT_584 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

       tmp := htf.formselectopen( 'P2' );
       tmp := tmp || htf.formselectoption( NULL );
         for c7rec in c7(owner_id, c1rec.name) loop
          tmp := tmp || htf.formselectoption( c7rec.name, cattributes=>'VALUE="' || c7rec.oid || '"' );
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1', '8-RECREATE_EXISTING' ) || htf.bold( LNG5.EXT_TXT_585 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

       tmp := htf.formselectopen( 'P2' );
       tmp := tmp || htf.formselectoption( NULL );
         for c6rec in c6(owner_id) loop
          tmp := tmp || htf.formselectoption( c6rec.name, cattributes=>'VALUE="' || c6rec.oid || '"' );
         end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1', '8-RECREATE_PRE' ) || htf.bold( LNG5.EXT_TXT_586 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

       tmp := htf.formselectopen( 'P2' );
       tmp := tmp || htf.formselectoption( NULL );
       tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_253, cattributes=>'VALUE="DEFAULT"' );
       -- Default Templates
       for c17rec in c17 loop
        tmp := tmp || htf.formselectoption( c17rec.template_name );
       end loop;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     open c14(c1rec.oid);
     fetch c14 into c14rec;
     close c14;
     if c14rec.tot = 0
      then
       htp.tablerowopen;
        htp.tabledata( htf.formhidden( 'P1', '8-DELETE' ) || htf.bold( LNG5.EXT_TXT_587 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );

        htp.tabledata( htf.formtext( 'P2', 20, 20 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tablerowclose;
     end if;
    htp.tableclose;
    htp.nl;

  end if;

  htp.nl;
  if disp_style <> LNG3.ADM_TXT_619
   then
    if disp_style = LNG.PHG_TXT_352
     then
      htp.formsubmit( 'ACTION',LNG5.EXT_TXT_588);
     else
      htp.formsubmit( 'ACTION',LNG5.EXT_TXT_589);
    end if;
    htp.formsubmit( 'ACTION',LNG4.AHC_TXT_919);
    --htp.formclose;
  end if;

  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'FNAME', 'RIGHT_FRAME', errmsg=>sqlerrm);
end right_frame;

function getval( val in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
  return varchar2
 as
 begin
  for j in p1.first..p1.last loop
   if p1(j) = val
    then
     return( p2(j) );
   end if;
  end loop;
  return( NULL );
end getval;

function getcheck( val in varchar2, p3 in GLBX.MYARRAY )
  return varchar2
 as
 begin
  for j in p3.first..p3.last loop
   if p3(j) = val
    then
     return( 'T' );
   end if;
  end loop;
  return( 'F' );
end getcheck;

procedure accept_right_frame( surl in varchar2, void in integer, disp_style in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in varchar2 default 'F', action in varchar2 default null )
as

 cursor c1(phgid integer, void integer) is select * from order_style where oid = void and pid = phgid;
 cursor c2(phgid integer, vname varchar2) is select count('x') tot from order_style where pid = phgid and name = vname;
 cursor c3 is select column_name from user_tab_columns where table_name = 'ORDER_STYLE' and column_name not in ('OID','PID','DATE_CREATED','DATE_UPDATED','NAME','IS_DEFAULT');
 cursor c4(phgid integer) is select oid from order_style where pid = phgid and is_default = 'T';

 c1rec		c1%ROWTYPE;
 c1arec		c1%ROWTYPE;
 crec		additional_options_definition%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 tot		integer;
 foundrec	boolean;
 nmb		number;
 ctr		integer;
 sts		varchar2(100);
 nme		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		varchar2(4000);
 tmpa		varchar2(4000);

 begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FNAME.ACCEPT_RIGHT_FRAME', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if action = LNG4.AHC_TXT_919
   then
    right_frame( surl, void, LNG3.ADM_TXT_619, LNG5.EXT_TXT_631 );
    return;
  end if;

  pfx := glbx.photo_lf(owner_id);

  open c1(owner_id,void);
  fetch c1 into c1rec;
  close c1;
  if c1rec.oid is null then return; end if; -- Invalid OID

  if c1rec.is_locked = 'T' and disp_style <> LNG.GLB_TXT_066
   then
    right_frame(surl, void, disp_style, LNG5.EXT_TXT_632 );
    return;
  end if;

  if disp_style = LNG.GLB_TXT_066
   then
     c1rec.spb := getval( '1-SPB', p1, p2 );
     c1rec.bftr := getval( '1-BFTR', p1, p2 );
     c1rec.laf := getval( '1-LAF', p1, p2 );
     c1rec.residing_country := getval( '1-RESIDING_COUNTRY', p1, p2 );
     c1rec.currency_to_use := getval( '1-CURRENCY_TO_USE', p1, p2 );
     c1rec.tracing_style := getval( '1-TRACING_STYLE', p1, p2 );
     c1rec.is_default  := getcheck( '1-IS_DEFAULT', p3 );
     c1rec.is_locked  := getcheck( '1-IS_LOCKED', p3 );
     c1rec.use_default_if_no_price  := getcheck( '1-USE_DEFAULT_IF_NO_PRICE', p3 );
     c1rec.tracing_style_api := getval( '1-TRACING_STYLE_API', p1, p2 );

     -- Turn of all is_defaults
     if c1rec.is_default = 'T'
      then
       update order_style
       set
        is_default = 'F'
       where
        pid = c1rec.pid;
     end if;

     update order_style
      set
       spb = c1rec.spb,
       bftr = c1rec.bftr,
       laf = c1rec.laf,
       residing_country = c1rec.residing_country,
       currency_to_use = c1rec.currency_to_use,
       is_default = c1rec.is_default,
       tracing_style = c1rec.tracing_style,
       tracing_style_api = c1rec.tracing_style_api,
       use_default_if_no_price = c1rec.use_default_if_no_price,
       is_locked = c1rec.is_locked,
       date_updated = sysdate
     where
      oid = c1rec.oid and
      pid = c1rec.pid;

    -- Ensure only there can be only one default turned on
    foundrec := FALSE;
    for c4rec in c4(c1rec.pid) loop
     foundrec := TRUE;
     if c4%ROWCOUNT > 1
      then
       update order_style
       set
        is_default = 'F'
       where
        pid = c1rec.pid and
        oid = c4rec.oid;
     end if;
    end loop;
    -- No Default Enabled, enable this one
    if not foundrec
     then
       update order_style
       set
        is_default = 'T'
       where
        pid = c1rec.pid and
        oid = c1rec.oid;
    end if;

  elsif disp_style = LNG5.EXT_TXT_259
   then
     c1rec.payment_cc  := getcheck( '2-PAYMENT_CC', p3 );
     c1rec.payment_cc_text := getval( '2-PAYMENT_CC_TEXT', p1, p2 );
     c1rec.payment_display_style := getval( '2-PAYMENT_DISPLAY_STYLE', p1, p2 );
     c1rec.payment_cc_international := getcheck( '2-PAYMENT_CC_INTERNATIONAL', p3 );
     c1rec.payment_cc_separate_display := getcheck( '2-PAYMENT_CC_SEPARATE_DISPLAY', p3 );
     c1rec.payment_cheque  := getcheck( '2-PAYMENT_CHEQUE', p3 );
     c1rec.payment_cheque_text := getval( '2-PAYMENT_CHEQUE_TEXT', p1, p2 );
     c1rec.payment_phone  := getcheck( '2-PAYMENT_PHONE', p3 );
     c1rec.payment_cheque_noconfirm  := getcheck( '2-PAYMENT_CHEQUE_NOCONFIRM', p3 );
     c1rec.payment_cheque_button_loc := getval( '2-PAYMENT_CHEQUE_BUTTON_LOC', p1, p2 );
     c1rec.payment_phone_text := getval( '2-PAYMENT_PHONE_TEXT', p1, p2 );
     c1rec.fax_merchant_enabled  := getcheck( '2-FAX_MERCHANT_ENABLED', p3 );
     c1rec.fax_merchant_border  := getcheck( '2-FAX_MERCHANT_BORDER', p3 );
     c1rec.fax_merchant_box_dotted  := getcheck( '2-FAX_MERCHANT_BOX_DOTTED', p3 );
     c1rec.payment_phone_ring  := p4;
     c1rec.payment_billing  := getcheck( '2-PAYMENT_BILLING', p3 );
     c1rec.payment_billing_text := getval( '2-PAYMENT_BILLING_TEXT', p1, p2 );
     c1rec.payment_auth  := getcheck( '2-PAYMENT_AUTH', p3 );
     c1rec.payment_auth_text := getval( '2-PAYMENT_AUTH_TEXT', p1, p2 );
     c1rec.payment_auth_project_code  := getcheck( '2-PAYMENT_AUTH_PROJECT_CODE', p3 );
     c1rec.payment_gift  := getcheck( '2-PAYMENT_GIFT', p3 );
     c1rec.payment_gift_text := getval( '2-PAYMENT_GIFT_TEXT', p1, p2 );
     c1rec.payment_problems_def := getval( '2-PAYMENT_PROBLEMS_DEF', p1, p2 );
     c1rec.text_order_problem := getval( '2-TEXT_ORDER_PROBLEM', p1, p2 );
     c1rec.payment_display_gif  := getcheck( '2-PAYMENT_DISPLAY_GIF', p3 );
     c1rec.payment_display_all_as_butt  := getcheck( '2-PAYMENT_DISPLAY_ALL_AS_BUTT', p3 );
     c1rec.disp_purch_request_heading := getcheck( '2-DISP_PURCH_REQUEST_HEADING', p3 );
     c1rec.payment_can_cancel_noncc  := getcheck( '2-PAYMENT_CAN_CANCEL_NONCC', p3 );
     c1rec.payment_b2c  := getcheck( '2-PAYMENT_B2C', p3 );
     c1rec.payment_free  := getcheck( '2-PAYMENT_FREE', p3 );
     c1rec.payment_free_text := getval( '2-PAYMENT_FREE_TEXT', p1, p2 );
     c1rec.text_title_merchant := getval( '2-TEXT_TITLE_MERCHANT', p1, p2 );
     c1rec.text_title_authorisation := getval( '2-TEXT_TITLE_AUTHORISATION', p1, p2 );
     c1rec.text_title_cheque := getval( '2-TEXT_TITLE_CHEQUE', p1, p2 );
     c1rec.text_title_phone := getval( '2-TEXT_TITLE_PHONE', p1, p2 );
     c1rec.text_title_gift := getval( '2-TEXT_TITLE_GIFT', p1, p2 );
     c1rec.text_title_billing := getval( '2-TEXT_TITLE_BILLING', p1, p2 );
     c1rec.text_title_free := getval( '2-TEXT_TITLE_FREE', p1, p2 );
     c1rec.text_cc_message := getval( '2-TEXT_CC_MESSAGE', p1, p2 );
     c1rec.text_cheque_message	 := getval( '2-TEXT_CHEQUE_MESSAGE', p1, p2 );
     c1rec.text_phone_message_but := getval( '2-TEXT_PHONE_MESSAGE_BUT', p1, p2 );
     c1rec.text_auth_message	 := getval( '2-TEXT_AUTH_MESSAGE', p1, p2 );
     c1rec.text_billing_message	 := getval( '2-TEXT_BILLING_MESSAGE', p1, p2 );
     c1rec.text_gift_message  	 := getval( '2-TEXT_GIFT_MESSAGE', p1, p2 );
     c1rec.text_free_message	 := getval( '2-TEXT_FREE_MESSAGE', p1, p2 );

     -- If any payment method enabled, then free images is automatically disabled
     if c1rec.payment_cc = 'T' or
        c1rec.payment_cheque = 'T' or
        c1rec.payment_phone = 'T' or
        c1rec.payment_billing = 'T' or
        c1rec.payment_auth = 'T' or
        c1rec.payment_gift = 'T'
      then
       c1rec.payment_free := 'F';
     end if;

     update order_style
      set
       payment_display_style = c1rec.payment_display_style,
       payment_cc   = c1rec.payment_cc,
       payment_cc_text  = c1rec.payment_cc_text,
       payment_cc_international = c1rec.payment_cc_international,
       payment_cc_separate_display = c1rec.payment_cc_separate_display,
       payment_cheque   = c1rec.payment_cheque,
       payment_cheque_text  = c1rec.payment_cheque_text,
       payment_phone   = c1rec.payment_phone,
       payment_phone_text  = c1rec.payment_phone_text,
       payment_phone_ring   = c1rec.payment_phone_ring,
       fax_merchant_enabled = c1rec.fax_merchant_enabled,
       fax_merchant_border = c1rec.fax_merchant_border,
       fax_merchant_box_dotted = c1rec.fax_merchant_box_dotted,
       payment_billing   = c1rec.payment_billing,
       payment_billing_text  = c1rec.payment_billing_text,
       payment_auth   = c1rec.payment_auth,
       payment_auth_text  = c1rec.payment_auth_text,
       payment_auth_project_code = c1rec.payment_auth_project_code,
       payment_gift   = c1rec.payment_gift,
       payment_gift_text  = c1rec.payment_gift_text,
       payment_problems_def  = c1rec.payment_problems_def,
       text_order_problem = c1rec.text_order_problem,
       payment_display_gif   = c1rec.payment_display_gif,
       payment_display_all_as_butt = c1rec.payment_display_all_as_butt,
       disp_purch_request_heading = c1rec.disp_purch_request_heading,
       payment_can_cancel_noncc = c1rec.payment_can_cancel_noncc,
       payment_b2c = c1rec.payment_b2c,
       payment_free = c1rec.payment_free,
       payment_free_text = c1rec.payment_free_text,
       payment_cheque_button_loc = c1rec.payment_cheque_button_loc,
       payment_cheque_noconfirm = c1rec.payment_cheque_noconfirm,
       text_title_merchant =  c1rec.text_title_merchant,
       text_title_authorisation =  c1rec.text_title_authorisation,
       text_title_cheque =  c1rec.text_title_cheque,
       text_title_phone = c1rec.text_title_phone,
       text_title_gift =  c1rec.text_title_gift,
       text_title_billing =  c1rec.text_title_billing,
       text_title_free =  c1rec.text_title_free,
       text_cc_message	= c1rec.text_cc_message,
       text_cheque_message = c1rec.text_cheque_message,
       text_phone_message_but = c1rec.text_phone_message_but,
       text_auth_message = c1rec.text_auth_message,
       text_billing_message = c1rec.text_billing_message,
       text_gift_message = c1rec.text_gift_message,
       text_free_message = c1rec.text_free_message,
       date_updated = sysdate
     where
      oid = c1rec.oid and
      pid = c1rec.pid;

  elsif disp_style = 'User Fees'
   then
     c1rec.uf_enabled  := getcheck( 'UF_ENABLED', p3 );
     c1rec.uf_display_progress_bar  := getcheck( 'UF_DISPLAY_PROGRESS_BAR', p3 );
     c1rec.uf_display_price  := getcheck( 'UF_DISPLAY_PRICE', p3 );
     c1rec.uf_display_matte  := getcheck( 'UF_DISPLAY_MATTE', p3 );
     c1rec.uf_display_image_name  := getcheck( 'UF_DISPLAY_IMAGE_NAME', p3 );
     c1rec.uf_display_additional_img  := getcheck( 'UF_DISPLAY_ADDITIONAL_IMG', p3 );
     c1rec.uf_specify_in_image  := getcheck( 'UF_SPECIFY_IN_IMAGE', p3 );
     c1rec.uf_show_continue_gif  := getcheck( 'UF_SHOW_CONTINUE_GIF', p3 );
     c1rec.uf_show_return_gif  := getcheck( 'UF_SHOW_RETURN_GIF', p3 );
     c1rec.uf_bl_enable_default  := getcheck( 'UF_BL_ENABLE_DEFAULT', p3 );
     c1rec.uf_bl_locked_fee  := getcheck( 'UF_BL_LOCKED_FEE', p3 );
     c1rec.uf_bl_onnew_def_last  := getcheck( 'UF_BL_ONNEW_DEF_LAST', p3 );
     c1rec.uf_bl_onnew_nodisplay  := getcheck( 'UF_BL_ONNEW_NODISPLAY', p3 );
     c1rec.uf_bl_cust_can_change  := getcheck( 'UF_BL_CUST_CAN_CHANGE', p3 );
     c1rec.uf_bl_enable_combo_box  := getcheck( 'UF_BL_ENABLE_COMBO_BOX', p3 );
     c1rec.uf_bl_enable_prepricing  := getcheck( 'UF_BL_ENABLE_PREPRICING', p3 );
     c1rec.uf_bl_remember_over_session  := getcheck( 'UF_BL_REMEMBER_OVER_SESSION', p3 );
     c1rec.uf_bl_turf_duplicates  := getcheck( 'UF_BL_TURF_DUPLICATES', p3 );
     c1rec.uf_image_position := getval( 'UF_IMAGE_POSITION', p1, p2 );
     c1rec.uf_continue_text := getval( 'UF_CONTINUE_TEXT', p1, p2 );
     c1rec.uf_return_text := getval( 'UF_RETURN_TEXT', p1, p2 );
     c1rec.uf_text_header := getval( 'UF_TEXT_HEADER', p1, p2 );
     c1rec.uf_instruction_text := getval( 'UF_INSTRUCTION_TEXT', p1, p2 );
     c1rec.uf_error_no_default := getval( 'UF_ERROR_NO_DEFAULT', p1, p2 );

     update order_style
      set
       uf_enabled  		= c1rec.uf_enabled,
       uf_display_progress_bar  = c1rec.uf_display_progress_bar,
       uf_display_price  	= c1rec.uf_display_price,
       uf_display_matte  	= c1rec.uf_display_matte,
       uf_display_image_name  	= c1rec.uf_display_image_name,
       uf_display_additional_img = c1rec.uf_display_additional_img,
       uf_specify_in_image      = c1rec.uf_specify_in_image ,
       uf_show_continue_gif  	= c1rec.uf_show_continue_gif,
       uf_show_return_gif  	= c1rec.uf_show_return_gif,
       uf_bl_enable_default  	= c1rec.uf_bl_enable_default,
       uf_bl_locked_fee  	= c1rec.uf_bl_locked_fee,
       uf_bl_onnew_def_last  	= c1rec.uf_bl_onnew_def_last,
       uf_bl_onnew_nodisplay  	= c1rec.uf_bl_onnew_nodisplay,
       uf_bl_cust_can_change  	= c1rec.uf_bl_cust_can_change,
       uf_bl_enable_combo_box  	= c1rec.uf_bl_enable_combo_box,
       uf_bl_enable_prepricing  = c1rec.uf_bl_enable_prepricing,
       uf_bl_turf_duplicates    = c1rec.uf_bl_turf_duplicates,
       uf_bl_remember_over_session = c1rec.uf_bl_remember_over_session,
       uf_image_position 	= c1rec.uf_image_position,
       uf_continue_text 	= c1rec.uf_continue_text,
       uf_return_text 		= c1rec.uf_return_text,
       uf_text_header 		= c1rec.uf_text_header,
       uf_instruction_text 	= c1rec.uf_instruction_text,
       uf_error_no_default 	= c1rec.uf_error_no_default,
       date_updated = sysdate
     where
      oid = c1rec.oid and
      pid = c1rec.pid;

  elsif disp_style = LNG5.EXT_TXT_260
   then
     c1rec.pricing_nopostage_if_zero  := getcheck( '3-PRICING_NOPOSTAGE_IF_ZERO', p3 );
     --c1rec.pricing_order_split  := getcheck( '3-PRICING_ORDER_SPLIT', p3 );
     c1rec.pricing_offer_manual_ship  := getcheck( '3-PRICING_OFFER_MANUAL_SHIP', p3 );
     c1rec.text_manual_ship := getval( '3-TEXT_MANUAL_SHIP', p1, p2 );
     c1rec.pricing_discount := glbx.conv_nmb(getval( '3-PRICING_DISCOUNT', p1, p2 ),'PERCENTAGE');
     c1rec.pricing_disc_if_gtr := glbx.conv_nmb(getval( '3-PRICING_DISC_IF_GTR', p1, p2 ),'MONEY');
     c1rec.pricing_discount_stage := getval( '3-PRICING_DISCOUNT_STAGE', p1, p2 );
     c1rec.pricing_display_order := getval( '3-PRICING_DISPLAY_ORDER', p1, p2 );
     c1rec.pricing_ship_local := glbx.conv_nmb(getval( '3-PRICING_SHIP_LOCAL', p1, p2 ),'MONEY');
     c1rec.pricing_ship_int := glbx.conv_nmb(getval( '3-PRICING_SHIP_INT', p1, p2 ),'MONEY');
     c1rec.pricing_expr_local := glbx.conv_nmb(getval( '3-PRICING_EXPR_LOCAL', p1, p2 ),'MONEY');
     c1rec.pricing_expr_int := glbx.conv_nmb(getval( '3-PRICING_EXPR_INT', p1, p2 ),'MONEY');
     --c1rec.pricing_gift_charge := glbx.conv_nmb(getval( '3-PRICING_GIFT_CHARGE', p1, p2 ),'MONEY');
     c1rec.pricing_min_amt := glbx.conv_nmb(getval( '3-PRICING_MIN_AMT', p1, p2 ),'MONEY');
     c1rec.pricing_max_amt := glbx.conv_nmb(getval( '3-PRICING_MAX_AMT', p1, p2 ),'MONEY');
     c1rec.pricing_max_qty := glbx.conv_nmb(getval( '3-PRICING_MAX_QTY', p1, p2 ),'NUMBER');
     c1rec.text_min_max_reached := getval( '3-TEXT_MIN_MAX_REACHED', p1, p2 );
     c1rec.pricing_gst := glbx.conv_nmb(getval( '3-PRICING_GST', p1, p2 ),'PERCENTAGE');
     c1rec.pricing_gst_text := getval( '3-PRICING_GST_TEXT', p1, p2 );
     c1rec.pricing_gst_int_sales  := getcheck( '3-PRICING_GST_INT_SALES', p3 );
     c1rec.pricing_gst_inclusive  := getcheck( '3-PRICING_GST_INCLUSIVE', p3 );
     c1rec.pricing_postage_included  := getcheck( '3-PRICING_POSTAGE_INCLUDED', p3 );
     c1rec.pricing_express_included  := getcheck( '3-PRICING_EXPRESS_INCLUDED', p3 );
     c1rec.pricing_postage_text := getval( '3-PRICING_POSTAGE_TEXT', p1, p2 );
     c1rec.disp_sep_post_surcharge  := getcheck( '3-DISP_SEP_POST_SURCHARGE', p3 );
     c1rec.text_surcharge := getval( '3-TEXT_SURCHARGE', p1, p2 );
     c1rec.pricing_surcharge_text := getval( '3-PRICING_SURCHARGE_TEXT', p1, p2 );
     c1rec.pricing_postage_text_col := getval( '3-PRICING_POSTAGE_TEXT_COL', p1, p2 );
     c1rec.pricing_express_text_col := getval( '3-PRICING_EXPRESS_TEXT_COL', p1, p2 );
     c1rec.text_local_charge := getval( '3-TEXT_LOCAL_CHARGE', p1, p2 );
     c1rec.text_international_charge := getval( '3-TEXT_INTERNATIONAL_CHARGE', p1, p2 );

     --c1rec.columns_display := substr(c1rec.columns_display,1,9) || getcheck( '3-PRICING_ORDER_SPLIT', p3 ) || substr(c1rec.columns_display,11);

     update order_style
      set
       pricing_nopostage_if_zero = c1rec.pricing_nopostage_if_zero,
       pricing_offer_manual_ship = c1rec.pricing_offer_manual_ship,
       text_manual_ship = c1rec.text_manual_ship,
       pricing_discount  = c1rec.pricing_discount,
       pricing_disc_if_gtr  = c1rec.pricing_disc_if_gtr,
       pricing_discount_stage = c1rec.pricing_discount_stage,
       pricing_display_order = c1rec.pricing_display_order,
       pricing_ship_local  = c1rec.pricing_ship_local,
       pricing_ship_int  = c1rec.pricing_ship_int,
       pricing_expr_local  = c1rec.pricing_expr_local,
       pricing_expr_int  = c1rec.pricing_expr_int,
       pricing_min_amt  = c1rec.pricing_min_amt,
       pricing_max_amt  = c1rec.pricing_max_amt,
       pricing_max_qty  = c1rec.pricing_max_qty,
       pricing_gst = c1rec.pricing_gst,
       pricing_gst_text = c1rec.pricing_gst_text,
       pricing_gst_int_sales = c1rec.pricing_gst_int_sales,
       pricing_gst_inclusive = c1rec.pricing_gst_inclusive,
       pricing_postage_included = c1rec.pricing_postage_included,
       pricing_express_included = c1rec.pricing_express_included,
       pricing_postage_text = c1rec.pricing_postage_text,
       pricing_surcharge_text = c1rec.pricing_surcharge_text,
       text_min_max_reached = c1rec.text_min_max_reached,
       columns_display = c1rec.columns_display,
       pricing_postage_text_col = c1rec.pricing_postage_text_col,
       pricing_express_text_col = c1rec.pricing_express_text_col,
       text_local_charge = c1rec.text_local_charge,
       text_international_charge = c1rec.text_international_charge,
       disp_sep_post_surcharge = c1rec.disp_sep_post_surcharge,
       text_surcharge = c1rec.text_surcharge,
       date_updated = sysdate
     where
      oid = c1rec.oid and
      pid = c1rec.pid;

  elsif disp_style = LNG5.EXT_TXT_406
   then
     c1rec.columns_swap_pay_confirm  := getcheck( '4-COLUMNS_SWAP_PAY_CONFIRM', p3 );
     c1rec.disp_ord_summ  := getcheck( '4-DISP_ORD_SUMM', p3 );
     c1rec.disp_ord_summ_matte  := getcheck( '4-DISP_ORD_SUMM_MATTE', p3 );
     c1rec.disp_ord_summ_col := getval( '4-DISP_ORD_SUMM_COL', p1, p2 );
     c1rec.disp_ord_summ_col2 := getval( '4-DISP_ORD_SUMM_COL2', p1, p2 );
     c1rec.disp_ord_summ_col3 := getval( '4-DISP_ORD_SUMM_COL3', p1, p2 );
     c1rec.disp_gift_wrap  := getcheck( '4-DISP_GIFT_WRAP', p3 );
     c1rec.disp_gift_wrap_col := getval( '4-DISP_GIFT_WRAP_COL', p1, p2 );
     c1rec.disp_gift_wrap_col2 := getval( '4-DISP_GIFT_WRAP_COL2', p1, p2 );
     c1rec.disp_gift_wrap_col3 := getval( '4-DISP_GIFT_WRAP_COL3', p1, p2 );
     c1rec.disp_ord_trk  := getcheck( '4-DISP_ORD_TRK', p3 );
     c1rec.disp_cust  := getcheck( '4-DISP_CUST', p3 );
     c1rec.disp_payment_method  := getcheck( '4-DISP_PAYMENT_METHOD', p3 );
     c1rec.disp_postage  := getcheck( '4-DISP_POSTAGE', p3 );
     c1rec.disp_shipping  := getcheck( '4-DISP_SHIPPING', p3 );
     c1rec.disp_total  := getcheck( '4-DISP_TOTAL', p3 );
     c1rec.disp_ord_trk_col := getval( '4-DISP_ORD_TRK_COL', p1, p2 );
     c1rec.disp_ord_trk_col2 := getval( '4-DISP_ORD_TRK_COL2', p1, p2 );
     c1rec.disp_ord_trk_col3 := getval( '4-DISP_ORD_TRK_COL3', p1, p2 );
     c1rec.disp_auto_create_tracking  := getcheck( '4-DISP_AUTO_CREATE_TRACKING', p3 );
     c1rec.disp_ord_trk_expire_at := getval( '4-DISP_ORD_TRK_EXPIRE_AT', p1, p2 );
     c1rec.disp_ord_trk_expire_date := glbx.conv_nmb(getval( '4-DISP_ORD_TRK_EXPIRE_DATE', p1, p2 ),'NUMBER');
     c1rec.disp_ord_trk_expire_status := getval( '4-DISP_ORD_TRK_EXPIRE_STATUS', p1, p2 );
     c1rec.disp_cust_col := getval( '4-DISP_CUST_COL', p1, p2 );
     c1rec.disp_cust_col2 := getval( '4-DISP_CUST_COL2', p1, p2 );
     c1rec.disp_cust_col3 := getval( '4-DISP_CUST_COL3', p1, p2 );
     c1rec.disp_payment_method_col := getval( '4-DISP_PAYMENT_METHOD_COL', p1, p2 );
     c1rec.disp_payment_method_col2 := getval( '4-DISP_PAYMENT_METHOD_COL2', p1, p2 );
     c1rec.disp_payment_method_col3 := getval( '4-DISP_PAYMENT_METHOD_COL3', p1, p2 );
     c1rec.disp_postage_col := getval( '4-DISP_POSTAGE_COL', p1, p2 );
     c1rec.disp_postage_col2 := getval( '4-DISP_POSTAGE_COL2', p1, p2 );
     c1rec.disp_postage_col3 := getval( '4-DISP_POSTAGE_COL3', p1, p2 );
     c1rec.disp_shipping_col := getval( '4-DISP_SHIPPING_COL', p1, p2 );
     c1rec.disp_shipping_col2 := getval( '4-DISP_SHIPPING_COL2', p1, p2 );
     c1rec.disp_shipping_col3 := getval( '4-DISP_SHIPPING_COL3', p1, p2 );
     c1rec.disp_total_col := getval( '4-DISP_TOTAL_COL', p1, p2 );
     c1rec.disp_total_col2 := getval( '4-DISP_TOTAL_COL2', p1, p2 );
     c1rec.disp_total_col3 := getval( '4-DISP_TOTAL_COL3', p1, p2 );
     c1rec.disp_ord_summ_title := getval( '5-DISP_ORD_SUMM_TITLE', p1, p2 );
     c1rec.disp_gift_wrap_title := getval( '5-DISP_GIFT_WRAP_TITLE', p1, p2 );
     c1rec.disp_ord_trk_title := getval( '5-DISP_ORD_TRK_TITLE', p1, p2 );
     c1rec.disp_cust_title := getval( '5-DISP_CUST_TITLE', p1, p2 );
     c1rec.disp_shipping_title := getval( '5-DISP_SHIPPING_TITLE', p1, p2 );
     c1rec.disp_postage_title := getval( '5-DISP_POSTAGE_TITLE', p1, p2 );
     c1rec.disp_payment_method_title := getval( '5-DISP_PAYMENT_METHOD_TITLE', p1, p2 );
     c1rec.disp_total_title := getval( '5-DISP_TOTAL_TITLE', p1, p2 );
     c1rec.text_page0 := getval( '5-TEXT_PAGE0', p1, p2 );
     c1rec.text_page1 := getval( '5-TEXT_PAGE1', p1, p2 );
     c1rec.text_page2 := getval( '5-TEXT_PAGE2', p1, p2 );
     c1rec.text_page3 := getval( '5-TEXT_PAGE3', p1, p2 );
     c1rec.text_page4 := getval( '5-TEXT_PAGE4', p1, p2 );
     c1rec.text_page5 := getval( '5-TEXT_PAGE5', p1, p2 );
     c1rec.disp_ord_summ_order := getval( '4-DISP_ORD_SUMM_ORDER', p1, p2 );
     c1rec.disp_gift_wrap_order := getval( '4-DISP_GIFT_WRAP_ORDER', p1, p2 );
     c1rec.disp_ord_trk_order := getval( '4-DISP_ORD_TRK_ORDER', p1, p2 );
     c1rec.disp_cust_order := getval( '4-DISP_CUST_ORDER', p1, p2 );
     c1rec.disp_shipping_order := getval( '4-DISP_SHIPPING_ORDER', p1, p2 );
     c1rec.disp_postage_order := getval( '4-DISP_POSTAGE_ORDER', p1, p2 );
     c1rec.disp_payment_method_order := getval( '4-DISP_PAYMENT_METHOD_ORDER', p1, p2 );
     c1rec.disp_total_order := getval( '4-DISP_TOTAL_ORDER', p1, p2 );

     update order_style
      set
       columns_swap_pay_confirm = c1rec.columns_swap_pay_confirm,
       disp_ord_summ   = c1rec.disp_ord_summ,
       disp_ord_summ_matte = c1rec.disp_ord_summ_matte,
       disp_ord_summ_col  = c1rec.disp_ord_summ_col,
       disp_ord_summ_col2  = c1rec.disp_ord_summ_col2,
       disp_ord_summ_col3  = c1rec.disp_ord_summ_col3,
       disp_gift_wrap   = c1rec.disp_gift_wrap,
       disp_gift_wrap_col  = c1rec.disp_gift_wrap_col,
       disp_gift_wrap_col2  = c1rec.disp_gift_wrap_col2,
       disp_gift_wrap_col3  = c1rec.disp_gift_wrap_col3,
       disp_ord_trk   = c1rec.disp_ord_trk,
       disp_cust = c1rec.disp_cust,
       disp_payment_method = c1rec.disp_payment_method,
       disp_postage = c1rec.disp_postage,
       disp_shipping = c1rec.disp_shipping,
       disp_total = c1rec.disp_total,
       disp_ord_trk_col  = c1rec.disp_ord_trk_col,
       disp_ord_trk_col2  = c1rec.disp_ord_trk_col2,
       disp_ord_trk_col3  = c1rec.disp_ord_trk_col3,
       disp_auto_create_tracking = c1rec.disp_auto_create_tracking,
       disp_ord_trk_expire_at = c1rec.disp_ord_trk_expire_at,
       disp_ord_trk_expire_date = c1rec.disp_ord_trk_expire_date,
       disp_ord_trk_expire_status = c1rec.disp_ord_trk_expire_status,
       disp_cust_col = c1rec.disp_cust_col,
       disp_cust_col2 = c1rec.disp_cust_col2,
       disp_cust_col3 = c1rec.disp_cust_col3,
       disp_payment_method_col = c1rec.disp_payment_method_col,
       disp_payment_method_col2 = c1rec.disp_payment_method_col2,
       disp_payment_method_col3 = c1rec.disp_payment_method_col3,
       disp_postage_col = c1rec.disp_postage_col,
       disp_postage_col2 = c1rec.disp_postage_col2,
       disp_postage_col3 = c1rec.disp_postage_col3,
       disp_shipping_col = c1rec.disp_shipping_col,
       disp_shipping_col2 = c1rec.disp_shipping_col2,
       disp_shipping_col3 = c1rec.disp_shipping_col3,
       disp_total_col = c1rec.disp_total_col,
       disp_total_col2 = c1rec.disp_total_col2,
       disp_total_col3 = c1rec.disp_total_col3,
       disp_ord_summ_title = c1rec.disp_ord_summ_title,
       disp_gift_wrap_title= c1rec.disp_gift_wrap_title,
       disp_ord_trk_title = c1rec.disp_ord_trk_title,
       disp_cust_title = c1rec.disp_cust_title,
       disp_shipping_title = c1rec.disp_shipping_title,
       disp_postage_title = c1rec.disp_postage_title,
       disp_payment_method_title = c1rec.disp_payment_method_title,
       disp_total_title = c1rec.disp_total_title,
       text_page0 = c1rec.text_page0,
       text_page1 = c1rec.text_page1,
       text_page2 = c1rec.text_page2,
       text_page3 = c1rec.text_page3,
       text_page4 = c1rec.text_page4,
       text_page5 = c1rec.text_page5,
       disp_ord_summ_order = c1rec.disp_ord_summ_order,
       disp_gift_wrap_order = c1rec.disp_gift_wrap_order,
       disp_ord_trk_order = c1rec.disp_ord_trk_order,
       disp_cust_order = c1rec.disp_cust_order,
       disp_shipping_order = c1rec.disp_shipping_order,
       disp_postage_order = c1rec.disp_postage_order,
       disp_payment_method_order = c1rec.disp_payment_method_order,
       disp_total_order = c1rec.disp_total_order,
       date_updated = sysdate
      where
             oid = c1rec.oid and
             pid = c1rec.pid;

         elsif disp_style = LNG5.EXT_TXT_261
   then
     c1rec.disp_recent  := getcheck( '4-DISP_RECENT', p3 );
     c1rec.disp_recent_nmb := nvl(glbx.conv_nmb(getval( '4-DISP_RECENT_NMB', p1, p2 ),'NUMBER'),5);
     c1rec.disp_recent_frame  := getcheck( '4-DISP_RECENT_FRAME', p3 );
     c1rec.disp_recent_top  := getcheck( '4-DISP_RECENT_TOP', p3 );
     c1rec.disp_most_pop  := getcheck( '4-DISP_MOST_POP', p3 );
     c1rec.disp_most_pop_nmb := nvl(glbx.conv_nmb(getval( '4-DISP_MOST_POP_NMB', p1, p2 ),'NUMBER'),5);
     c1rec.disp_most_frame  := getcheck( '4-DISP_MOST_FRAME', p3 );
     c1rec.disp_most_top  := getcheck( '4-DISP_MOST_TOP', p3 );
     c1rec.disp_popup  := getcheck( '4-DISP_POPUP', p3 );
     c1rec.disp_graphic_button  := getcheck( '4-DISP_GRAPHIC_BUTTON', p3 );
     c1rec.disp_border  := getcheck( '4-BORDER', p3 );
     c1rec.disp_show_currency  := getcheck( '4-DISP_SHOW_CURRENCY', p3 );
     c1rec.disp_show_convert  := getcheck( '4-DISP_SHOW_CONVERT', p3 );
     c1rec.disp_tracking_ctr  := getcheck( '4-DISP_TRACKING_CTR', p3 );
     c1rec.disp_remove_style  := getval( 'DISP_REMOVE_STYLE', p1, p2 );
     c1rec.disp_goto_order_pge  := getcheck( '4-DISP_GOTO_ORDER_PGE', p3 );
     c1rec.disp_cntry_fnl_pge  := getcheck( '4-DISP_CNTRY_FNL_PGE', p3 );
     c1rec.disp_receipt   := getcheck( '4-DISP_RECEIPT', p3 );
     c1rec.pricing_internal   := getcheck( '4-PRICING_INTERNAL', p3 );
     c1rec.disp_receipt_print  := getcheck( '4-DISP_RECEIPT_PRINT', p3 );
     c1rec.disp_show_tnail_on_receipt  := getcheck( '4-DISP_SHOW_TNAIL_ON_RECEIPT', p3 );
     c1rec.disp_auto_create_on_purchase  := getcheck( '4-DISP_AUTO_CREATE_ON_PURCHASE', p3 );
     c1rec.disp_email_is_username  := getcheck( '4-DISP_EMAIL_IS_USERNAME', p3 );
     c1rec.disp_prompt_create_acct  := getcheck( '4-DISP_PROMPT_CREATE_ACCT', p3 );
     c1rec.disp_email_customer  := getcheck( '4-DISP_EMAIL_CUSTOMER', p3 );
     c1rec.disp_email_phg  := getcheck( '4-DISP_EMAIL_PHG', p3 );

     update order_style
      set
       disp_recent   = c1rec.disp_recent,
       disp_recent_nmb  = c1rec.disp_recent_nmb,
       disp_most_pop   = c1rec.disp_most_pop,
       disp_most_pop_nmb  = c1rec.disp_most_pop_nmb,
       disp_recent_frame = c1rec.disp_recent_frame,
       disp_recent_top = c1rec.disp_recent_top,
       disp_most_frame = c1rec.disp_most_frame,
       disp_most_top = c1rec.disp_most_top,
       disp_popup = c1rec.disp_popup,
       disp_graphic_button = c1rec.disp_graphic_button,
       disp_border = c1rec.disp_border,
       disp_show_currency   = c1rec.disp_show_currency,
       disp_show_convert   = c1rec.disp_show_convert,
       disp_tracking_ctr = c1rec.disp_tracking_ctr,
       disp_goto_order_pge   = c1rec.disp_goto_order_pge,
       disp_cntry_fnl_pge   = c1rec.disp_cntry_fnl_pge,
       disp_receipt    = c1rec.disp_receipt,
       disp_receipt_print   = c1rec.disp_receipt_print,
       disp_show_tnail_on_receipt = c1rec.disp_show_tnail_on_receipt,
       disp_auto_create_on_purchase = c1rec.disp_auto_create_on_purchase,
       disp_email_is_username = c1rec.disp_email_is_username,
       disp_prompt_create_acct = c1rec.disp_prompt_create_acct,
       disp_email_customer   = c1rec.disp_email_customer,
       disp_email_phg   = c1rec.disp_email_phg,
       disp_remove_style = c1rec.disp_remove_style,
       pricing_internal = c1rec.pricing_internal,
       date_updated = sysdate
     where
      oid = c1rec.oid and
      pid = c1rec.pid;

  elsif disp_style = LNG5.EXT_TXT_262
   then
    c1rec.text_checkout_button := glbx.censor(getval( '5-TEXT_CHECKOUT_BUTTON', p1, p2 ),100);
    c1rec.text_recalculate_button := glbx.censor(getval( '5-TEXT_RECALCULATE_BUTTON', p1, p2 ),100);
    c1rec.text_empty_basket_button := glbx.censor(getval( '5-TEXT_EMPTY_BASKET_BUTTON', p1, p2 ),100);
    c1rec.text_logoff := glbx.censor(getval( '5-TEXT_LOGOFF', p1, p2 ),100);
    c1rec.text_userfee := glbx.censor(getval( '5-TEXT_USERFEE', p1, p2 ),100);
    c1rec.text_return_button := glbx.censor(getval( '5-TEXT_RETURN_BUTTON', p1, p2 ),100);
    c1rec.text_proceed_button := glbx.censor(getval( '5-TEXT_PROCEED_BUTTON', p1, p2 ),100);
    c1rec.text_confirm_button := glbx.censor(getval( '5-TEXT_CONFIRM_BUTTON', p1, p2 ),100);
    c1rec.text_on_empty_basket := glbx.censor(getval( '5-TEXT_ON_EMPTY_BASKET', p1, p2 ),100);
    c1rec.text_image_title := glbx.censor(getval( '5-TEXT_IMAGE_TITLE', p1, p2 ),100);
    c1rec.text_phone_message := glbx.censor(getval( '5-TEXT_PHONE_MESSAGE', p1, p2 ),4000);
    c1rec.text_thumbnail := glbx.censor(getval( '5-TEXT_THUMBNAIL', p1, p2 ),100);
    c1rec.text_qty := glbx.censor(getval( '5-TEXT_QTY', p1, p2 ),100);
    c1rec.text_subtotal_title := glbx.censor(getval( '5-TEXT_SUBTOTAL_TITLE', p1, p2 ),100);
    c1rec.text_print_cheque := glbx.censor(getval( '5-TEXT_PRINT_CHEQUE', p1, p2 ),1000);
    c1rec.text_message_under_total := glbx.censor(getval( '5-TEXT_MESSAGE_UNDER_TOTAL', p1, p2 ),100);
    c1rec.text_most_popular := glbx.censor(getval( '5-TEXT_MOST_POPULAR', p1, p2 ),100);
    c1rec.text_recent_purchased := glbx.censor(getval( '5-TEXT_RECENT_PURCHASED', p1, p2 ),100);
    c1rec.text_remove_from := getval( '5-TEXT_REMOVE_FROM', p1, p2 );
    c1rec.text_purchase_request := glbx.censor(getval( '5-TEXT_PURCHASE_REQUEST', p1, p2 ),100);
    c1rec.text_return_message := glbx.censor(getval( '5-TEXT_RETURN_MESSAGE', p1, p2 ),100);
    c1rec.text_phg_title := glbx.censor(getval( '5-TEXT_PHG_TITLE', p1, p2 ),4000);
    c1rec.text_home1 := glbx.censor(getval( '5-TEXT_HOME1', p1, p2 ),4000);
    c1rec.text_home2 := glbx.censor(getval( '5-TEXT_HOME2', p1, p2 ),4000);
    c1rec.text_shopping_basket := glbx.censor(getval( '5-TEXT_SHOPPING_BASKET', p1, p2 ),4000);
    c1rec.text_subtotal := glbx.censor(getval( '5-TEXT_SUBTOTAL', p1, p2 ),4000);
    c1rec.text_grandtotal := glbx.censor(getval( '5-TEXT_GRANDTOTAL', p1, p2 ),4000);
    c1rec.text_cancel_order := glbx.censor(getval( '5-TEXT_CANCEL_ORDER', p1, p2 ),4000);

     update order_style
      set
       text_checkout_button = c1rec.text_checkout_button,
       text_recalculate_button = c1rec.text_recalculate_button,
       text_empty_basket_button = c1rec.text_empty_basket_button,
       text_logoff = c1rec.text_logoff,
       text_userfee = c1rec.text_userfee,
       text_on_empty_basket = c1rec.text_on_empty_basket,
       text_image_title = c1rec.text_image_title,
       text_message_under_total = c1rec.text_message_under_total,
       text_phone_message = c1rec.text_phone_message,
       text_most_popular = c1rec.text_most_popular,
       text_recent_purchased = c1rec.text_recent_purchased,
       text_remove_from = c1rec.text_remove_from,
       text_purchase_request = c1rec.text_purchase_request,
       text_return_message = c1rec.text_return_message,
       text_phg_title  = c1rec.text_phg_title,
       text_home1  = c1rec.text_home1,
       text_home2  = c1rec.text_home2,
       text_cancel_order = c1rec.text_cancel_order,
       text_grandtotal = c1rec.text_grandtotal,
       text_subtotal = c1rec.text_subtotal,
       text_shopping_basket = c1rec.text_shopping_basket,
       text_return_button = c1rec.text_return_button,
       text_proceed_button = c1rec.text_proceed_button,
       text_confirm_button = c1rec.text_confirm_button,
       text_thumbnail = c1rec.text_thumbnail,
       text_qty = c1rec.text_qty,
       text_subtotal_title = c1rec.text_subtotal_title,
       text_print_cheque = c1rec.text_print_cheque,
       date_updated = sysdate
     where
      oid = c1rec.oid and
      pid = c1rec.pid;

  elsif disp_style = LNG5.EXT_TXT_405
   then
    c1rec.text_disclaimer := substr(getval( '5-TEXT_DISCLAIMER', p1, p2 ),1,4000);
    c1rec.text_privacy := substr(getval( '5-TEXT_PRIVACY', p1, p2 ),1,4000);
    c1rec.text_logon_title := glbx.censor(getval( '5-TEXT_LOGON_TITLE', p1, p2 ),100);
    c1rec.text_unsolicited_email := glbx.censor(getval( '5-TEXT_UNSOLICITED_EMAIL', p1, p2 ),100);
    c1rec.text_accept := glbx.censor(getval( '5-TEXT_ACCEPT', p1, p2 ),100);
    c1rec.text_decline := glbx.censor(getval( '5-TEXT_DECLINE', p1, p2 ),100);

     update order_style
      set
       text_disclaimer = c1rec.text_disclaimer,
       text_logon_title = c1rec.text_logon_title,
       text_unsolicited_email = c1rec.text_unsolicited_email,
       text_accept = c1rec.text_accept,
       text_decline = c1rec.text_decline,
       text_privacy = c1rec.text_privacy,
       date_updated = sysdate
     where
      oid = c1rec.oid and
      pid = c1rec.pid;

  elsif disp_style = 'Purchase Options'
   then
    delete from additional_options_definition where oid = c1rec.oid;
    ctr := 0;
    -- Find First occurance of the values
    for j in p1.first..p1.last loop
     if p1(j) = 'ORDER_BY' then ctr := j; exit; end if;
    end loop;
    loop
     --htp.p( ctr || '-' || p1(ctr) || ':' || p2(ctr) ); htp.nl;
     if ctr = 0 then exit; end if;
     if ctr > 1000 then exit; end if; -- infinite loop protection
     crec.oid := c1rec.oid;
     if p1(ctr) = 'ORDER_BY'
      then
       begin nmb := to_number(p2(ctr)); exception when others then nmb := 999; end;
       crec.order_by := nmb;
     end if;
     if p1(ctr) = 'MERCHANT_CODE'  then  crec.merchant_id_code := p2(ctr); end if;
     if p1(ctr) = 'DISPLAY_TEXT'  then  crec.display_text := p2(ctr); end if;
     if p1(ctr) = 'DISPLAY_TEXT_HELP'  then  crec.display_text_help := p2(ctr); end if;
     if p1(ctr) = 'DISPLAY_PRICES'  then  crec.display_prices := p2(ctr); end if;
     if p1(ctr) = 'CUSTOMER_COMMENT_ALLOWED'  then  crec.customer_comment_allowed := p2(ctr); end if;
     if p1(ctr) = 'DISPLAY_STYLE'  then crec.display_style := p2(ctr); end if;
     if p1(ctr) = 'DISPLAY_RECEIPT_PAGE'  then crec.display_receipt_page := p2(ctr); end if;
     if p1(ctr) = 'DISPLAY_RECEIPT_CUSTRESP'  then crec.display_receipt_custresp := p2(ctr); end if;
     if p1(ctr) = 'INTERNATIONAL_ADJUSTER'
      then
       begin nmb := to_number(p2(ctr)); exception when others then nmb := 1; end;
       crec.international_adjuster := nmb;
     end if;
     if p1(ctr) = 'SITE_SPECIFIC_GIF'
      then
       crec.site_specific_gif := p2(ctr);
       --htp.p( 'X:' || crec.order_by || '-' || crec.merchant_id_code ); htp.nl;
       if crec.order_by is not null and crec.merchant_id_code is not null
        then
        insert into additional_options_definition(oid,order_by,merchant_id_code,display_text_help,display_text,display_prices,international_adjuster,customer_comment_allowed,display_style,display_receipt_page,display_receipt_custresp,site_specific_gif) values
         (crec.oid,crec.order_by,crec.merchant_id_code,crec.display_text_help,crec.display_text,crec.display_prices,crec.international_adjuster,crec.customer_comment_allowed,crec.display_style,crec.display_receipt_page,crec.display_receipt_custresp,crec.site_specific_gif);
       end if;
     end if;
     ctr := ctr + 1;
     -- Test to see if there are no more rows left
     begin tmp := p2(ctr); exception when no_data_found then exit; when others then null; end;
    end loop;

  elsif disp_style = LNG2.PBK_TXT_128
   then
     c1rec.payment_cc_down_only := getcheck( '2-PAYMENT_CC_DOWN_ONLY', p3 );
     c1rec.download_original_any_time := getcheck( '2-DOWNLOAD_ORIGINAL_ANY_TIME', p3 );
     c1rec.download_web_any_time := getcheck( '2-DOWNLOAD_WEB_ANY_TIME', p3 );
     c1rec.download_original_on_purchase := getcheck( '2-DOWNLOAD_ORIGINAL_ON_PURCHASE', p3 );
     c1rec.download_prompt_details := getcheck( '2-DOWNLOAD_PROMPT_DETAILS', p3 );
     c1rec.download_web_on_purchase := getcheck( '2-DOWNLOAD_WEB_ON_PURCHASE', p3 );
     c1rec.download_auto_email_web := getcheck( '2-DOWNLOAD_AUTO_EMAIL_WEB', p3 );
     c1rec.download_email_free := getcheck( '2-DOWNLOAD_EMAIL_FREE', p3 );

     update order_style
      set
       payment_cc_down_only = c1rec.payment_cc_down_only,
       download_original_any_time = c1rec.download_original_any_time,
       download_web_any_time = c1rec.download_web_any_time,
       download_original_on_purchase = c1rec.download_original_on_purchase,
       download_prompt_details = c1rec.download_prompt_details,
       download_web_on_purchase = c1rec.download_web_on_purchase,
       download_auto_email_web = c1rec.download_auto_email_web,
       download_email_free = c1rec.download_email_free,
       date_updated = sysdate
     where
      oid = c1rec.oid and
      pid = c1rec.pid;

  elsif disp_style = LNG5.EXT_TXT_263
   then
    c1rec.text_delayed_pricing := glbx.censor(getval( '5-TEXT_DELAYED_PRICING', p1, p2 ),4000);
    c1rec.text_alt_price_book := glbx.censor(getval( '5-TEXT_ALT_PRICE_BOOK', p1, p2 ),4000);
    c1rec.text_purch_warning := glbx.censor(getval( '5-TEXT_PURCH_WARNING', p1, p2 ),4000);
    c1rec.text_help_shopping := glbx.censor(getval( '5-TEXT_HELP_SHOPPING', p1, p2 ),4000);
    c1rec.text_help_purchase := glbx.censor(getval( '5-TEXT_HELP_PURCHASE', p1, p2 ),4000);
    c1rec.text_help_purchase2 := glbx.censor(getval( '5-TEXT_HELP_PURCHASE2', p1, p2 ),4000);
    c1rec.text_cancel_msg := glbx.censor(getval( '5-TEXT_CANCEL_MSG', p1, p2 ),4000);
    c1rec.text_onlogout_itm := glbx.censor(getval( '5-TEXT_ONLOGOUT_ITM', p1, p2 ),4000);
    c1rec.packaged_product_display := glbx.censor(getval( '5-PACKAGED_PRODUCT_DISPLAY', p1, p2 ),4000);
    c1rec.text_merchant_warning := substr(getval( '5-TEXT_MERCHANT_WARNING', p1, p2 ),1,4000);
    c1rec.fax_merchant_text_above := substr(getval( '5-FAX_MERCHANT_TEXT_ABOVE', p1, p2 ),1,4000);
    c1rec.fax_merchant_text_below := substr(getval( '5-FAX_MERCHANT_TEXT_BELOW', p1, p2 ),1,4000);

     update order_style
      set
       text_delayed_pricing  = c1rec.text_delayed_pricing,
       text_alt_price_book  = c1rec.text_alt_price_book,
       text_purch_warning  = c1rec.text_purch_warning,
       text_help_shopping  = c1rec.text_help_shopping,
       text_help_purchase  = c1rec.text_help_purchase,
       text_help_purchase2  = c1rec.text_help_purchase2,
       text_cancel_msg  = c1rec.text_cancel_msg,
       text_onlogout_itm = c1rec.text_onlogout_itm,
       packaged_product_display = c1rec.packaged_product_display,
       text_merchant_warning = c1rec.text_merchant_warning,
       fax_merchant_text_above = c1rec.fax_merchant_text_above,
       fax_merchant_text_below = c1rec.fax_merchant_text_below,
       date_updated = sysdate
     where
      oid = c1rec.oid and
      pid = c1rec.pid;

  elsif disp_style = LNG.CST_TXT_005
   then
    c1rec.columns_display := lpad('F',40,'F');
    c1rec.columns_display := getcheck( '6-NAME',p3 ) || substr(c1rec.columns_display,2);
    c1rec.columns_display := substr(c1rec.columns_display,1,1) || getcheck( '6-STREET',p3 ) || substr(c1rec.columns_display,3);
    c1rec.columns_display := substr(c1rec.columns_display,1,2) || getcheck( '6-SUBURB',p3 ) || substr(c1rec.columns_display,4);
    c1rec.columns_display := substr(c1rec.columns_display,1,3) || getcheck( '6-CITY',p3 ) || substr(c1rec.columns_display,5);
    c1rec.columns_display := substr(c1rec.columns_display,1,4) || getcheck( '6-POSTCODE',p3 ) || substr(c1rec.columns_display,6);
    c1rec.columns_display := substr(c1rec.columns_display,1,5) || getcheck( '6-COUNTRY',p3 ) || substr(c1rec.columns_display,7);
    c1rec.columns_display := substr(c1rec.columns_display,1,6) || getcheck( '6-PHONE',p3 ) || substr(c1rec.columns_display,8);
    c1rec.columns_display := substr(c1rec.columns_display,1,7) || getcheck( '6-EMAIL',p3 ) || substr(c1rec.columns_display,9);
    c1rec.columns_display := substr(c1rec.columns_display,1,8) || getcheck( '6-CUSTOMER_COMMENT',p3 ) || substr(c1rec.columns_display,10);
    c1rec.columns_display := substr(c1rec.columns_display,1,9) || getcheck( '6-DO_NOT_SPLIT_ORDER',p3 ) || substr(c1rec.columns_display,11);

    c1rec.columns_display := substr(c1rec.columns_display,1,10) || getcheck( '6-COLUMNS_CUST_COL1',p3 ) || substr(c1rec.columns_display,12);
    c1rec.columns_display := substr(c1rec.columns_display,1,11) || getcheck( '6-COLUMNS_CUST_COL2',p3 ) || substr(c1rec.columns_display,13);
    c1rec.columns_display := substr(c1rec.columns_display,1,12) || getcheck( '6-COLUMNS_CUST_COL3',p3 ) || substr(c1rec.columns_display,14);
    c1rec.columns_display := substr(c1rec.columns_display,1,13) || getcheck( '6-COLUMNS_CUST_COL4',p3 ) || substr(c1rec.columns_display,15);
    c1rec.columns_display := substr(c1rec.columns_display,1,14) || getcheck( '6-COLUMNS_CUST_COL5',p3 ) || substr(c1rec.columns_display,16);
    c1rec.columns_display := substr(c1rec.columns_display,1,15) || getcheck( '6-COLUMNS_CUST_COL6',p3 ) || substr(c1rec.columns_display,17);
    c1rec.columns_display := substr(c1rec.columns_display,1,16) || getcheck( '6-STATE',p3 ) || substr(c1rec.columns_display,18);
    c1rec.columns_display := substr(c1rec.columns_display,1,19) || getcheck( '6-BRANCH',p3 ) || substr(c1rec.columns_display,21);
    c1rec.columns_display := substr(c1rec.columns_display,1,20) || getcheck( '6-DEPARTMENT',p3 ) || substr(c1rec.columns_display,22);
    --c1rec.pricing_order_split  := getcheck( '6-DO_NOT_SPLIT_ORDER',p3 );

    c1rec.columns_mandatory := lpad('F',40,'F');
    c1rec.columns_mandatory := getcheck( '6-NAME-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,2);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,1) || getcheck( '6-STREET-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,3);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,2) || getcheck( '6-SUBURB-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,4);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,3) || getcheck( '6-CITY-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,5);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,4) || getcheck( '6-POSTCODE-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,6);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,5) || getcheck( '6-COUNTRY-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,7);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,6) || getcheck( '6-PHONE-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,8);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,7) || getcheck( '6-EMAIL-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,9);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,8) || getcheck( '6-CUSTOMER_COMMENT-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,10);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,9) || getcheck( '6-DO_NOT_SPLIT_ORDER-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,11);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,10) || getcheck( '6-COLUMNS_CUST_COL1-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,12);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,11) || getcheck( '6-COLUMNS_CUST_COL2-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,13);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,12) || getcheck( '6-COLUMNS_CUST_COL3-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,14);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,13) || getcheck( '6-COLUMNS_CUST_COL4-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,15);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,14) || getcheck( '6-COLUMNS_CUST_COL5-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,16);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,15) || getcheck( '6-COLUMNS_CUST_COL6-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,17);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,16) || getcheck( '6-STATE-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,18);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,19) || getcheck( '6-BRANCH-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,21);
    c1rec.columns_mandatory := substr(c1rec.columns_mandatory,1,20) || getcheck( '6-DEPARTMENT-MANDATORY',p3 ) || substr(c1rec.columns_mandatory,22);

    c1rec.columns_email_unique := getcheck( '6-COLUMNS_EMAIL_UNIQUE',p3 );

    -- Auto turn on to display any columns which are mandatory and not turned on
    for j in 1..21 loop
     if substr(c1rec.columns_mandatory,j,1) = 'T' and j <> 18 -- 18 is not used
      then
       if j = 1
        then
         c1rec.columns_display := 'T' || substr(c1rec.columns_display,2);
        else
         c1rec.columns_display := substr(c1rec.columns_display,1,j-1) || 'T' || substr(c1rec.columns_display,j+1);
       end if;
     end if;
    end loop;

   --htp.bold('Step 3' );
    c1rec.columns_on_login := lpad('F',40,'F');
    c1rec.columns_on_login := getcheck( '6-NAME-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,2);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,1) || getcheck( '6-STREET-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,3);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,2) || getcheck( '6-SUBURB-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,4);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,3) || getcheck( '6-CITY-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,5);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,4) || getcheck( '6-POSTCODE-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,6);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,5) || getcheck( '6-COUNTRY-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,7);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,6) || getcheck( '6-PHONE-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,8);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,7) || getcheck( '6-EMAIL-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,9);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,8) || getcheck( '6-CUSTOMER_COMMENT-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,10);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,9) || getcheck( '6-DO_NOT_SPLIT_ORDER-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,11);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,10) || getcheck( '6-DISCLAIMER-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,12);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,11) || getcheck( '6-UNSOLICITED-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,13);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,12) || getcheck( '6-COLUMNS_CUST_COL1-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,14);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,13) || getcheck( '6-COLUMNS_CUST_COL2-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,15);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,14) || getcheck( '6-COLUMNS_CUST_COL3-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,16);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,15) || getcheck( '6-COLUMNS_CUST_COL4-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,17);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,16) || getcheck( '6-COLUMNS_CUST_COL5-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,18);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,17) || getcheck( '6-COLUMNS_CUST_COL6-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,19);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,18) || getcheck( '6-STATE-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,20);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,19) || getcheck( '6-BRANCH-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,21);
    c1rec.columns_on_login := substr(c1rec.columns_on_login,1,20) || getcheck( '6-DEPARTMENT-ON_LOGIN',p3 ) || substr(c1rec.columns_on_login,22);

    c1rec.columns_mandatory_on_login := lpad('F',40,'F');
    c1rec.columns_mandatory_on_login := getcheck( '6-NAME-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,2);
    c1rec.columns_mandatory_on_login := substr(c1rec.columns_mandatory_on_login,1,1) || getcheck( '6-STREET-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,3);
    c1rec.columns_mandatory_on_login := substr(c1rec.columns_mandatory_on_login,1,2) || getcheck( '6-SUBURB-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,4);
    c1rec.columns_mandatory_on_login := substr(c1rec.columns_mandatory_on_login,1,3) || getcheck( '6-CITY-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,5);
    c1rec.columns_mandatory_on_login := substr(c1rec.columns_mandatory_on_login,1,4) || getcheck( '6-POSTCODE-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,6);
    c1rec.columns_mandatory_on_login := substr(c1rec.columns_mandatory_on_login,1,5) || getcheck( '6-COUNTRY-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,7);
    c1rec.columns_mandatory_on_login := substr(c1rec.columns_mandatory_on_login,1,6) || getcheck( '6-PHONE-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,8);
    c1rec.columns_mandatory_on_login := substr(c1rec.columns_mandatory_on_login,1,7) || getcheck( '6-EMAIL-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,9);
    c1rec.columns_mandatory_on_login := substr(c1rec.columns_mandatory_on_login,1,8) || getcheck( '6-CUSTOMER_COMMENT-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,10);
    c1rec.columns_mandatory_on_login := substr(c1rec.columns_mandatory_on_login,1,12) || getcheck( '6-COLUMNS_CUST_COL1-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,14);
    c1rec.columns_mandatory_on_login := substr(c1rec.columns_mandatory_on_login,1,13) || getcheck( '6-COLUMNS_CUST_COL2-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,15);
    c1rec.columns_mandatory_on_login := substr(c1rec.columns_mandatory_on_login,1,14) || getcheck( '6-COLUMNS_CUST_COL3-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,16);
    c1rec.columns_mandatory_on_login := substr(c1rec.columns_mandatory_on_login,1,15) || getcheck( '6-COLUMNS_CUST_COL4-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,17);
    c1rec.columns_mandatory_on_login := substr(c1rec.columns_mandatory_on_login,1,16) || getcheck( '6-COLUMNS_CUST_COL5-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,18);
    c1rec.columns_mandatory_on_login := substr(c1rec.columns_mandatory_on_login,1,17) || getcheck( '6-COLUMNS_CUST_COL6-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,19);
    c1rec.columns_mandatory_on_login := substr(c1rec.columns_mandatory_on_login,1,18) || getcheck( '6-STATE-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,20);
    c1rec.columns_mandatory_on_login := substr(c1rec.columns_mandatory_on_login,1,19) || getcheck( '6-BRANCH-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,21);
    c1rec.columns_mandatory_on_login := substr(c1rec.columns_mandatory_on_login,1,20) || getcheck( '6-DEPARTMENT-ON_LOGIN-MANDATORY',p3 ) || substr(c1rec.columns_mandatory_on_login,22);

    -- Auto turn on to display any columns which are mandatory and not turned on
    for j in 1..9 loop
     if substr(c1rec.columns_mandatory_on_login,j,1) = 'T'
      then
       if j = 1
        then
         c1rec.columns_on_login := 'T' || substr(c1rec.columns_on_login,2);
        else
         c1rec.columns_on_login := substr(c1rec.columns_on_login,1,j-1) || 'T' || substr(c1rec.columns_on_login,j+1);
       end if;
     end if;
    end loop;
    for j in 13..21 loop
     if substr(c1rec.columns_mandatory_on_login,j,1) = 'T'
      then
       if j = 1
        then
         c1rec.columns_on_login := 'T' || substr(c1rec.columns_on_login,2);
        else
         c1rec.columns_on_login := substr(c1rec.columns_on_login,1,j-1) || 'T' || substr(c1rec.columns_on_login,j+1);
       end if;
     end if;
    end loop;

    c1rec.columns_name := getval( '6-COLUMNS_NAME',p1, p2 );
    c1rec.columns_firstname := getval( '6-COLUMNS_FIRSTNAME',p1, p2 );
    c1rec.columns_lastname := getval( '6-COLUMNS_LASTNAME',p1, p2 );
    c1rec.columns_street := getval( '6-COLUMNS_STREET',p1, p2 );
    c1rec.columns_branch := getval( '6-COLUMNS_BRANCH',p1, p2 );
    c1rec.columns_department := getval( '6-COLUMNS_DEPARTMENT',p1, p2 );
    c1rec.columns_suburb := getval( '6-COLUMNS_SUBURB',p1, p2 );
    c1rec.columns_city := getval( '6-COLUMNS_CITY',p1, p2 );
    c1rec.columns_state := getval( '6-COLUMNS_STATE',p1, p2 );
    c1rec.columns_postcode := getval( '6-COLUMNS_POSTCODE',p1, p2 );
    c1rec.columns_country := getval( '6-COLUMNS_COUNTRY',p1, p2 );
    c1rec.columns_phone := getval( '6-COLUMNS_PHONE',p1, p2 );
    c1rec.columns_email := getval( '6-COLUMNS_EMAIL',p1, p2 );
    c1rec.columns_comment := getval( '6-COLUMNS_COMMENT',p1, p2 );
    c1rec.columns_cust_col1 := getval( '6-COLUMNS_CUST_COL1',p1, p2 );
    c1rec.columns_cust_col2 := getval( '6-COLUMNS_CUST_COL2',p1, p2 );
    c1rec.columns_cust_col3 := getval( '6-COLUMNS_CUST_COL3',p1, p2 );
    c1rec.columns_cust_col4 := getval( '6-COLUMNS_CUST_COL4',p1, p2 );
    c1rec.columns_cust_col5 := getval( '6-COLUMNS_CUST_COL5',p1, p2 );
    c1rec.columns_cust_col6 := getval( '6-COLUMNS_CUST_COL6',p1, p2 );
    c1rec.columns_split := getval( '6-COLUMNS_SPLIT',p1, p2 );

    c1rec.columns_name_toggle := getcheck( '6-COLUMNS_NAME_TOGGLE',p3 );
    c1rec.columns_mark_bold := getcheck( '6-COLUMNS_MARK_BOLD',p3 );
    c1rec.columns_mark_italic := getcheck( '6-COLUMNS_MARK_ITALIC',p3 );
    c1rec.columns_mark_ast := getcheck( '6-COLUMNS_MARK_AST',p3 );
    c1rec.columns_smart_check := getcheck( '6-COLUMNS_SMART_CHECK',p3 );
    c1rec.columns_simple_address := getcheck( '6-COLUMNS_SIMPLE_ADDRESS',p3 );
    c1rec.columns_update_contact := getcheck( '6-COLUMNS_UPDATE_CONTACT',p3 );

    c1rec.login_html_template := getval( '6-LOGIN_HTML_TEMPLATE',p1, p2 );
    c1rec.login_html_subdir := getval( '6-LOGIN_HTML_SUBDIR',p1, p2 );

     update order_style
      set
       columns_mark_bold = c1rec.columns_mark_bold,
       columns_mark_italic = c1rec.columns_mark_italic,
       columns_mark_ast = c1rec.columns_mark_ast,
       columns_smart_check = c1rec.columns_smart_check,
       columns_simple_address = c1rec.columns_simple_address,
       columns_update_contact = c1rec.columns_update_contact,
       columns_display = c1rec.columns_display,
       columns_mandatory = c1rec.columns_mandatory,
       columns_on_login = c1rec.columns_on_login,
       columns_mandatory_on_login = c1rec.columns_mandatory_on_login,
       columns_name_toggle = c1rec.columns_name_toggle,
       columns_name = nvl(c1rec.columns_name,columns_name),
       columns_firstname = nvl(c1rec.columns_firstname,columns_firstname),
       columns_lastname = nvl(c1rec.columns_lastname,columns_lastname),
       columns_street = c1rec.columns_street,
       columns_suburb = c1rec.columns_suburb,
       columns_branch = c1rec.columns_branch,
       columns_department = c1rec.columns_department,
       columns_city = c1rec.columns_city,
       columns_state = c1rec.columns_state,
       columns_postcode = c1rec.columns_postcode,
       columns_country = c1rec.columns_country,
       columns_phone = c1rec.columns_phone,
       columns_email = c1rec.columns_email,
       columns_comment = c1rec.columns_comment,
       columns_cust_col1 = c1rec.columns_cust_col1,
       columns_cust_col2 = c1rec.columns_cust_col2,
       columns_cust_col3 = c1rec.columns_cust_col3,
       columns_cust_col4 = c1rec.columns_cust_col4,
       columns_cust_col5 = c1rec.columns_cust_col5,
       columns_cust_col6 = c1rec.columns_cust_col6,
       columns_split = c1rec.columns_split,
       columns_email_unique = c1rec.columns_email_unique,
       login_html_template = c1rec.login_html_template,
       login_html_subdir = c1rec.login_html_subdir,
       date_updated = sysdate
     where
      oid = c1rec.oid and
      pid = c1rec.pid;

  elsif disp_style = LNG5.EXT_TXT_264
   then
    c1rec.workflow_cc_start := getval( '7-WORKFLOW_CC_START', p1, p2 );
    c1rec.workflow_cc_mfctr := getval( '7-WORKFLOW_CC_MFCTR', p1, p2 );
    c1rec.workflow_cc_delivery := getval( '7-WORKFLOW_CC_DELIVERY', p1, p2 );
    c1rec.workflow_cheque_start := getval( '7-WORKFLOW_CHEQUE_START', p1, p2 );
    c1rec.workflow_cheque_mfctr := getval( '7-WORKFLOW_CHEQUE_MFCTR', p1, p2 );
    c1rec.workflow_cheque_delivery := getval( '7-WORKFLOW_CHEQUE_DELIVERY', p1, p2 );
    c1rec.workflow_phone_start := getval( '7-WORKFLOW_PHONE_START', p1, p2 );
    c1rec.workflow_phone_mfctr := getval( '7-WORKFLOW_PHONE_MFCTR', p1, p2 );
    c1rec.workflow_phone_delivery := getval( '7-WORKFLOW_PHONE_DELIVERY', p1, p2 );
    c1rec.workflow_billing_start := getval( '7-WORKFLOW_BILLING_START', p1, p2 );
    c1rec.workflow_billing_mfctr := getval( '7-WORKFLOW_BILLING_MFCTR', p1, p2 );
    c1rec.workflow_billing_delivery := getval( '7-WORKFLOW_BILLING_DELIVERY', p1, p2 );
    c1rec.workflow_auth_start := getval( '7-WORKFLOW_AUTH_START', p1, p2 );
    c1rec.workflow_auth_mfctr := getval( '7-WORKFLOW_AUTH_MFCTR', p1, p2 );
    c1rec.workflow_auth_delivery := getval( '7-WORKFLOW_AUTH_DELIVERY', p1, p2 );
    c1rec.workflow_booking_education := getval( '8-WORKFLOW_BOOKING_EDUCATION', p1, p2 );
    c1rec.workflow_booking_events := getval( '8-WORKFLOW_BOOKING_EVENTS', p1, p2 );
    c1rec.workflow_booking_visit := getval( '8-WORKFLOW_BOOKING_VISIT', p1, p2 );
    c1rec.workflow_booking_comm := getval( '8-WORKFLOW_BOOKING_COMM', p1, p2 );
    c1rec.workflow_booking_other1 := getval( '8-WORKFLOW_BOOKING_OTHER1', p1, p2 );
    c1rec.workflow_booking_other2 := getval( '8-WORKFLOW_BOOKING_OTHER2', p1, p2 );
    c1rec.workflow_booking_other3 := getval( '8-WORKFLOW_BOOKING_OTHER3', p1, p2 );

     update order_style
      set
       workflow_cc_start  = c1rec.workflow_cc_start,
       workflow_cc_mfctr  = c1rec.workflow_cc_mfctr,
       workflow_cc_delivery  = c1rec.workflow_cc_delivery,
       workflow_cheque_start  = c1rec.workflow_cheque_start,
       workflow_cheque_mfctr  = c1rec.workflow_cheque_mfctr,
       workflow_cheque_delivery  = c1rec.workflow_cheque_delivery,
       workflow_phone_start  = c1rec.workflow_phone_start,
       workflow_phone_mfctr  = c1rec.workflow_phone_mfctr,
       workflow_phone_delivery  = c1rec.workflow_phone_delivery,
       workflow_billing_start  = c1rec.workflow_billing_start,
       workflow_billing_mfctr  = c1rec.workflow_billing_mfctr,
       workflow_billing_delivery  = c1rec.workflow_billing_delivery,
       workflow_auth_start  = c1rec.workflow_auth_start,
       workflow_auth_mfctr  = c1rec.workflow_auth_mfctr,
       workflow_auth_delivery  = c1rec.workflow_auth_delivery,
       workflow_booking_education = c1rec.workflow_booking_education,
       workflow_booking_events = c1rec.workflow_booking_events,
       workflow_booking_visit = c1rec.workflow_booking_visit,
       workflow_booking_comm = c1rec.workflow_booking_comm,
       workflow_booking_other1 = c1rec.workflow_booking_other1,
       workflow_booking_other2 = c1rec.workflow_booking_other2,
       workflow_booking_other3 = c1rec.workflow_booking_other3,
       date_updated = sysdate
     where
      oid = c1rec.oid and
      pid = c1rec.pid;

  elsif disp_style = LNG.PHG_TXT_352
   then
     if getval( '8-RENAME', p1, p2 ) is not null
      then
       nme := upper(getval( '8-RENAME', p1, p2 ));
       update order_style
        set name = nme
       where
        oid = c1rec.oid and
        pid = c1rec.pid;
     end if;

     if getval( '8-COPY', p1, p2 ) is not null
      then
       nme := upper(getval( '8-COPY', p1, p2 ));
       open c2(c1rec.pid,nme);
       fetch c2 into tot;
       close c2;
       if tot > 0
        then
         right_frame(surl, void, disp_style, 'Cannot Copy. Order Style with this name already exists' || ':' || getval( '8-COPY', p1, p2 ) );
         return;
       end if;
       select s_order_style.nextval into tot from dual;
       insert into order_style(oid,pid,date_created,date_updated,name,is_default)
        values (tot,c1rec.pid,sysdate,sysdate,nme,'F');
       for c3rec in c3 loop
        execute immediate 'select ' || c3rec.column_name || ' from order_style where oid = :1'
         into tmp
         using c1rec.oid;
        execute immediate 'update order_style set ' || c3rec.column_name || ' = :1 where oid = :2'
         using tmp,tot;
       end loop;
     end if;

     if getval( '8-DIFFERENCES', p1, p2 ) is not null
      then
       open c1(owner_id,to_number(getval( '8-DIFFERENCES', p1, p2 )));
       fetch c1 into c1arec;
       close c1;
       glbx.main_title( surl, 'Differences between Order Styles' , glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P69',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
       htp.nl;
       htp.p( '<CENTER>' );
       htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
        htp.tablerowopen;
         htp.tabledata( htf.bold( 'Column' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
         htp.tabledata( htf.bold( c1rec.name ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
         htp.tabledata( htf.bold( c1arec.name ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
        htp.tablerowclose;
       for c3rec in c3 loop
        tmp := NULL;
        tmpa := NULL;
        execute immediate 'select ' || c3rec.column_name || ' from order_style where oid = :1'
         into tmp
         using c1rec.oid;
        execute immediate 'select ' || c3rec.column_name || ' from order_style where oid = :1'
         into tmpa
         using c1arec.oid;
        if nvl(tmp,'|') <> nvl(tmpa,'|')
         then
          htp.tablerowopen;
           htp.tabledata( htf.bold( translate_column(c3rec.column_name) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
           htp.tabledata( nvl(conv(tmp),'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
           htp.tabledata( nvl(conv(tmpa),'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
         htp.tablerowclose;
        end if;
       end loop;
       htp.tableclose;
       htp.nl;
       htp.p( '</CENTER>' );
       glbx.close_page( pfx );
       return;
     end if;

     if getval( '8-RECREATE_EXISTING', p1, p2 ) is not null
      then
       tot := getval( '8-RECREATE_EXISTING', p1, p2 );
       for c3rec in c3 loop
        execute immediate 'select ' || c3rec.column_name || ' from order_style where oid = :1'
         into tmp
         using tot;
        execute immediate 'update order_style set ' || c3rec.column_name || ' = :1 where oid = :2'
         using tmp,c1rec.oid;
       end loop;
     end if;

     if getval( '8-RECREATE_PRE', p1, p2 ) is not null
      then
       reset_order_style( surl, c1rec.pid, c1rec.oid, getval( '8-RECREATE_PRE', p1, p2 ) );
     end if;

     if getval( '8-DELETE', p1, p2 ) = 'DELETE'
      then
       delete from order_style where oid = c1rec.oid and pid = c1rec.pid;
       htp.htmlopen;
       htp.header( 2, 'Order Style Deleted', 'CENTER' );
       glbx.close_page( pfx );
       return;
     end if;

  end if;

  commit;

  right_frame(surl, void, disp_style, 'Details Modified' );

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_RIGHT_FRAME', errmsg=>sqlerrm);
end accept_right_frame;

function translate_column( cname in varchar2 )
 return varchar2
as
begin
 if cname = 'SPB' then return( 'Price Book Id' );
 elsif cname = 'BFTR' then return( LNG.PHG_TXT_129 );
 elsif cname = 'LAF' then return( LNG3.ADM_TXT_088 );
 elsif cname = 'COLUMNS_DISPLAY' then return( 'Columns Enabled' );
 elsif cname = 'COLUMNS_MANDATORY' then return( 'Mandatory Columns' );
 else
  return( initcap(replace(cname,'_',' ')));
 end if;
exception
 when others
  then return( 'Error' );
end translate_column;

function conv( val in varchar2 )
 return varchar2
as
begin
 if val = 'T'
  then
   return( LNG.PHG_TXT_045 );
 elsif val = 'F'
  then
   return( LNG.PHG_TXT_046 );
 else
  return( val );
 end if;
end conv;

procedure acct_orders( surl varchar2, msg in varchar2 default null, acid in integer default null, force_logoff in varchar2 default 'F', other_logoff in varchar2 default null, footer_api in varchar2 default null, left_api in varchar2 default null, left_api_parm in varchar2 default null, ispopup in char default 'F' )
as

 cursor c1(vpoid integer) is select count('x') tot from shopping_basket where poid = vpoid and user_fee_code is null;
 cursor c2(vpoid integer) is select max(shopping_id) tot from shopping_basket where poid = vpoid and user_fee_code is not null;
 cursor c3(vpoid integer) is select shopping_id from shopping_basket where poid = vpoid and user_fee_code is null and shopping_id not in (select max(sb2.shopping_id) from shopping_basket sb2 where poid = vpoid and user_fee_code is null);

 cusrec		CUSTOMER_ACCOUNT%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	THEME_TYPES%ROWTYPE;
 purchord 	PURCHASE_ORDER%ROWTYPE;
 voidrec	ORDER_STYLE%ROWTYPE;
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 ltype		varchar2(100);
 txt		varchar2(100);
 ord_exists	boolean;
 newline	boolean;
 grand_ttl	number;
 tot		integer;
 retlink	varchar2(1000);

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNM.ACCT_ORDERS' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;


 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 -- Business Feature overriden, get the other one
 if nvl(voidrec.bftr,'Use Customer Account Business Feature') <> 'Use Customer Account Business Feature'
  then
   theme_rec := glbx.get_theme_types( voidrec.bftr );
 end if;

 if nvl(voidrec.laf,'Use Customer Account Look and Feel') <> 'Use Customer Account Look and Feel'
  then
   pfx := glbx.get_thm( voidrec.laf );
 end if;

 -- If Order Made Prevent Access to It
 if is_not_preorder( purchord )
  then
   pfx.fullimg_jscript_popup := ispopup;
   recalc_order( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
   return;
 end if;

 -- Check if User Fees is enabled
 if voidrec.uf_enabled = 'T' and nvl(msg,'!') <> 'BYPASS'
  then
   -- If this is the first time in then go to the User Fee Screen
   open c1(purchord.poid);
   fetch c1 into tot;
   close c1;
   if tot > 1 and voidrec.uf_bl_turf_duplicates = 'T' -- Delete multiple values and only leave the latest
    then
     for c3rec in c3(purchord.poid) loop
      if cleanup_package(purchord.poid, c3rec.shopping_id ) then null; end if;
     end loop;
     commit;
   end if;

   if tot > 0
    then
     if voidrec.uf_bl_onnew_nodisplay = 'T'
      then
       -- Check if there are any already there
       open c2(purchord.poid);
       fetch c2 into tot;
       close c2;
       if nvl(tot,0) > 0
        then
         update shopping_basket
          set
           user_fee_code = (select user_fee_code from shopping_basket where shopping_id = tot)
          where
           poid = purchord.poid and
           user_fee_code is null;
        else
         -- There are no new ones, so go to the userfee screen
         userfee_screen(surl, acid=>acid, profid=>profid, ltype=>ltype, stype=>stype, sess_id=>sess_id, footer_api=>footer_api,left_api_parm=>left_api_parm, voidrec=>voidrec, pfx=>pfx, purchord=>purchord, theme_rec=>theme_rec, cusrec=>cusrec);
         return;
       end if;
      else
       userfee_screen(surl, acid=>acid, profid=>profid, ltype=>ltype, stype=>stype, sess_id=>sess_id, footer_api=>footer_api,left_api_parm=>left_api_parm, voidrec=>voidrec, pfx=>pfx, purchord=>purchord, theme_rec=>theme_rec, cusrec=>cusrec);
       return;
     end if;
   end if;
 end if;

 -- Call User Exit if its built into the Look and Feel
 if pfx.order_show_cart is not null
  then
     execute immediate
     'begin ' || pfx.order_show_cart ||
     '(surl=>:surl,theme_data=>:theme_data,ltype=>:ltype,acid=>:acid,void=>:void,purchid=>:purchid);' ||
     'end;'
     using glbx.rndsurl(surl),theme_rec.theme_data,ltype,acid,voidrec.oid,purchord.poid;
     return;
 end if;

 retlink := return_link( surl, stype, ltype, voidrec, pfx, acid, footer_api, left_api, left_api_parm, '1' );
 if voidrec.disp_purch_request_heading = 'T'
  then
   txt := voidrec.text_page1 || ' [' || purchord.poid || ']';
  else
   txt := voidrec.text_page1;
 end if;
 glbx.main_title( surl, txt, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'O01',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);

-- htp.p('<SCRIPT LANGUAGE="JavaScript">
-- <!--
-- document.cookie = "PICTION_COOKIE=123;";
-- // -->
-- </SCRIPT>');

 htp.p( '<CENTER>' );

 disp_tracing_style(surl, stype, voidrec, pfx, purchord, 'SHOPPING_BASKET', acid, ltype, theme_rec );
 if voidrec.text_phg_title is not null then htp.bold( voidrec.text_phg_title ); htp.nl; end if;

 if msg is not null and msg <> 'BYPASS'
  then
   glbx.header_msg( msg );
 end if;
 glbx.instruction( voidrec.text_help_shopping, pfx );

 -- Popup new window
 if voidrec.disp_popup = 'T'
  then
   if ltype = 'PHOTOGRAPHER'
    then
     htp.formopen( 'fname.accept_acct_order' );
    else
     if pfx.keep_lhf = 'N'
      then
       htp.formopen( 'fname.accept_acct_order' );
      else
       htp.formopen( 'fname.accept_acct_order', ctarget=>'CUS_BOTTOM' );
     end if;
   end if;
  else
   htp.formopen( 'fname.accept_acct_order' );
 end if;

 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'P0','0' ); -- Dummy values required for array
 htp.formhidden( 'P1','0' ); -- Dummy values required for array
 htp.formhidden( 'P2','0' ); -- Dummy values required for array
 htp.formhidden( 'P3','0' ); -- Dummy values required for array
 htp.formhidden( 'P6','0' ); -- Dummy values required for array


 -- Display Images Here

 if nvl(voidrec.disp_recent_top,'F') = 'T'
  then
   most_popular_photos(surl, cusrec.aid, cusrec.pid, ltype, pfx, voidrec );
 end if;
 if nvl(voidrec.disp_most_top,'F') = 'T'
  then
   customers_who_purchased(surl, cusrec.aid, sess_id, ltype, pfx, voidrec );
 end if;
 -- If in logout mode then display message at top of screen
 if force_logoff = 'T'
  then
   glbx.header_msg( voidrec.text_onlogout_itm );
 end if;

 newline := FALSE;
 show_customer_order( surl, cusrec, theme_rec, voidrec, sess_id, stype, ltype, pfx, acid, 'EDIT', ord_exists, grand_ttl, newline, retlink=>retlink );

 if ord_exists
  then
   htp.nl;
   if not(nvl(voidrec.pricing_min_amt,0) <= grand_ttl and
          nvl(voidrec.pricing_max_amt,99999999) >= grand_ttl)
    then
     htp.bold( voidrec.text_min_max_reached );
     htp.nl;
   end if;
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
    htp.tablerowopen;

    if voidrec.disp_graphic_button = 'F'
     then
      if voidrec.text_userfee is not null and voidrec.uf_enabled = 'T' and voidrec.uf_bl_locked_fee = 'F' and voidrec.uf_bl_cust_can_change = 'T'
       then
        htp.tabledata( htf.formsubmit( 'ACTION', voidrec.text_userfee ));
      end if;
      if voidrec.text_recalculate_button is not null
       then
        htp.tabledata( htf.formsubmit( 'ACTION', voidrec.text_recalculate_button ));
      end if;
      if voidrec.text_empty_basket_button is not null
       then
        htp.tabledata( htf.formsubmit( 'ACTION', voidrec.text_empty_basket_button ));
      end if;
      if nvl(voidrec.pricing_min_amt,0) <= grand_ttl and
         nvl(voidrec.pricing_max_amt,99999999) >= grand_ttl
       then
        htp.tabledata( htf.formsubmit( 'ACTION', voidrec.text_checkout_button ));
      end if;

     else
      htp.formhidden( 'ACTION', null );
      if voidrec.text_userfee is not null and voidrec.uf_enabled = 'T' and voidrec.uf_bl_locked_fee = 'F' and voidrec.uf_bl_cust_can_change = 'T'
       then
        htp.tabledata( htf.formimage( 'Userfee', DECS.IMAGE_LOCATION || 'adminc/order_userfee.gif',cattributes=>'BORDER="0"'));
      end if;
      if voidrec.text_recalculate_button is not null
       then
        htp.tabledata( htf.formimage( 'Recalculate', DECS.IMAGE_LOCATION || 'adminc/order_recalc.gif',cattributes=>'BORDER="0"'));
      end if;
      if voidrec.text_empty_basket_button is not null
       then
        htp.tabledata( htf.formimage( 'Empty', DECS.IMAGE_LOCATION || 'adminc/order_empty.gif',cattributes=>'BORDER="0"'));
      end if;
      if nvl(voidrec.pricing_min_amt,0) <= grand_ttl and
         nvl(voidrec.pricing_max_amt,99999999) >= grand_ttl
       then
         htp.tabledata( htf.formimage( 'Checkout', DECS.IMAGE_LOCATION || 'adminc/order_checkout.gif',cattributes=>'BORDER="0"'));
      end if;
     end if;

     htp.formclose;
     if force_logoff = 'T'
      then
       htp.formopen( 'glbx.acct_logoff' );
       htp.formhidden( 'SURL', glbx.rndsurl(surl) );
       htp.formhidden( 'FORCE_LOGOFF', 'T' );
       htp.formhidden( 'OTHER_LOGOFF', other_logoff );
       htp.tabledata( htf.formsubmit( null, voidrec.text_logoff ) );
       htp.formclose;
     end if;
    htp.tablerowclose;
   htp.tableclose;
   -- htp.formclose;
   htp.nl;
   glbx.instruction( voidrec.text_purch_warning, pfx );
 else
  htp.formclose;
  glbx.instruction( nvl(voidrec.text_on_empty_basket,LNG.CST_TXT_137), pfx );
 end if;

 if nvl(voidrec.disp_recent_top,'F') = 'F'
  then
   most_popular_photos(surl, cusrec.aid, cusrec.pid, ltype, pfx, voidrec );
 end if;
 if nvl(voidrec.disp_most_top,'F') = 'F'
  then
   customers_who_purchased(surl, cusrec.aid, sess_id, ltype, pfx, voidrec );
 end if;

 if pfx.ord_inc_simple = 'T'
  then
    cst.disp_standard_search(surl, stype, ltype, profid, acid, cusrec, pfx, theme_rec, 'SIMPLE' );
    if pfx.ord_inc_privacy = 'T' then htp.nl; end if;
 end if;

 if pfx.ord_inc_privacy = 'T'
  then
    cst.disp_privacy(surl, ltype, profid, acid, cusrec, pfx, theme_rec );
 end if;

 if pfx.order_bottom_external is not null
  then
    execute immediate
      'begin ' || pfx.order_bottom_external ||
       '(surl=>:surl,ltype=>:ltype,acid=>:acid,screen_location=>:screen_location);' ||
       'end;'
     using glbx.rndsurl(surl),ltype,acid,'SHOPPING_BASKET';
 end if;
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );
exception when others then
 glbx.error_details( 'FNAME', 'ACCT_ORDERS',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end acct_orders;

procedure most_popular_photos( surl in varchar2, acid in integer, phgid in integer, ltype in varchar2, pfx in theme%ROWTYPE, voidrec in order_style%ROWTYPE )
as
 cursor c1( acid integer, phgid integer ) is
  select sb.phid,um.photo_thumbnail.width width,um.photo_thumbnail.height height,um.aid,um.version,sum( nvl(sb.qty,0) ) as tot
  from shopping_basket sb, purchase_order po, umo um, customer_account ca
  where po.status not in ('PreOrder - No Order Made','Customer Cancelled','Photographer Cancelled','PreOrder','PreOrder - Sent to Bank','Awaiting Authorisation','PreOrder - Confirmed without Payment') and
        po.pid = phgid and
        ca.pid = phgid and
        sb.poid = po.poid and
        um.umo_id = sb.phid and
        ca.aid = acid and
        ca.aid = um.aid
  group by sb.phid,um.photo_thumbnail.width,um.photo_thumbnail.height,um.aid,um.version
  order by tot desc;

  foundrec	boolean;
  dsp		varchar2(1000);
  url		varchar2(1000);

begin
if voidrec.disp_most_pop = 'F' then return; end if;
 -- Most popular photos purchased

foundrec := FALSE;
for c1rec in c1(acid,phgid) loop
 if c1%ROWCOUNT = 1
  then
   foundrec := TRUE;
   if nvl(voidrec.disp_recent_top,'F') = 'F' then htp.line; end if;
   htp.nl;
   htp.bold( voidrec.text_most_popular );
   htp.nl;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
   htp.tablerowopen;
 end if;
 dsp := 'WIDTH=' || c1rec.width || ' HEIGHT=' || c1rec.height;
 url := 'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p1=0&p0=0&pa=0&pb=0&pc=0&ppn=&p1=' || c1rec.phid || '&p0=' || c1rec.phid || '&ADD_TO_TROLLEY=Order+Photos&footer_api=&left_api_parm=&current_page_number=&display_detail=&acid=' || acid;
 if voidrec.disp_most_frame = 'F'
  then
   htp.tabledata( htf.anchor(url, '<IMG BORDER=0 ' || dsp || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.phid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || c1rec.aid ||
                  '" ALT="' || LNG.ORD_TXT_222 || ' ' || c1rec.tot || ' ' || LNG.ORD_TXT_223 || LNG.SLD_TXT_047 || '" STYLE="display:block;">'),
                  cattributes=>pfx.ord_qcbground || 'valign="BOTTOM" align="CENTER"');
  else
   htp.p( '<TD VALIGN="BOTTOM">' );
    glbx.image_matte(pfx,c1rec.width,c1rec.height,
                     url,
                     '<IMG BORDER=0 WIDTH=' || c1rec.width || ' HEIGHT=' || c1rec.height || ' SRC="' ||
                     'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.phid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c1rec.version || '&parm1=AID&parm2=' || c1rec.aid ||
                     '" ALT="' || LNG.ORD_TXT_222 || ' ' || c1rec.tot || ' ' || LNG.ORD_TXT_223 || LNG.SLD_TXT_047 || '" STYLE="display:block;">',null );
   htp.p( '</TD>' );
 end if;
 if c1%ROWCOUNT >= nvl(voidrec.disp_most_pop_nmb,5) then exit; end if;
end loop;
if foundrec then htp.p( htf.tablerowclose || htf.tableclose ); end if;
if foundrec and nvl(voidrec.disp_recent_top,'F') = 'T' then htp.line; end if;
end most_popular_photos;

procedure customers_who_purchased( surl in varchar2, acid in integer, sess_id in integer, ltype in varchar2, pfx in theme%ROWTYPE, voidrec in order_style%ROWTYPE )
as

 cursor c1( acid integer, sess_id integer ) is
 select sb.phid,um.photo_thumbnail.width width,um.photo_thumbnail.height height,um.aid,version,sum( nvl(sb.qty,0) ) as tot
 from umo um, shopping_basket sb
 where sb.poid in
  (select sb2.poid
   from shopping_basket sb1, shopping_basket sb2, purchase_order po1, purchase_order po2
   where po2.status not in ('PreOrder - No Order Made',LNG.ORD_TXT_120,LNG4.AHC_TXT_672,LNG4.AHC_TXT_706,LNG.ORD_TXT_128,LNG.ORD_TXT_129,'PreOrder - Confirmed without Payment') and
         sb2.poid = po2.poid and
         sb1.poid = po1.poid and
         sb1.phid = sb2.phid and
         po1.sessid = sess_id
  ) and
  sb.phid not in
   (select sb3.phid from shopping_basket sb3, purchase_order po3 where sb3.poid = po3.poid and po3.sessid = sess_id) and
  um.umo_id = sb.phid and
  um.aid = acid
  group by sb.phid,um.photo_thumbnail.width,um.photo_thumbnail.height, um.aid,version
  order by tot desc;

  foundrec	boolean;
  dsp		varchar2(1000);
  url		varchar2(1000);

begin

-- Customers who purchased this also purchased
if voidrec.disp_recent = 'F' then return; end if;

foundrec := FALSE;
for c1rec in c1(acid,sess_id) loop
 if c1%ROWCOUNT = 1
  then
   foundrec := TRUE;
   if nvl(voidrec.disp_recent_top,'F') = 'F' then htp.line; end if;
   htp.nl;
   htp.bold( voidrec.text_recent_purchased );
   htp.nl;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
   htp.tablerowopen;
 end if;
 dsp := 'WIDTH=' || c1rec.width || ' HEIGHT=' || c1rec.height;
 url := 'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p1=0&p0=0&pa=0&pb=0&pc=0&ppn=&p1=' || c1rec.phid || '&p0=' || c1rec.phid || '&ADD_TO_TROLLEY=Order+Photos&footer_api=&left_api_parm=&current_page_number=&display_detail=&acid=' || acid;
 if voidrec.disp_most_frame = 'F'
  then
   htp.tabledata( htf.anchor(url, '<IMG BORDER=0 ' || dsp || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.phid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || c1rec.aid ||
                  '" ALT="' || LNG.ORD_TXT_222 || ' ' || c1rec.tot || ' ' || LNG.ORD_TXT_223 || LNG.SLD_TXT_047 || '" STYLE="display:block;">'),
                  cattributes=>pfx.ord_qcbground || 'valign="BOTTOM" align="CENTER"');
  else
   htp.p( '<TD VALIGN="BOTTOM">' );
    glbx.image_matte(pfx,c1rec.width,c1rec.height,
                     url,
                     '<IMG BORDER=0 WIDTH=' || c1rec.width || ' HEIGHT=' || c1rec.height || ' SRC="' ||
                     'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.phid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c1rec.version || '&parm1=AID&parm2=' || c1rec.aid ||
                     '" ALT="' || LNG.ORD_TXT_222 || ' ' || c1rec.tot || ' ' || LNG.ORD_TXT_223 || LNG.SLD_TXT_047 || '" STYLE="display:block;">',null );
   htp.p( '</TD>' );
 end if;

 if c1%ROWCOUNT >= nvl(voidrec.disp_recent_nmb,5) then exit; end if;
end loop;
if foundrec then htp.p( htf.tablerowclose || htf.tableclose ); end if;
if foundrec and nvl(voidrec.disp_recent_top,'F') = 'T' then htp.line; end if;
end customers_who_purchased;

procedure show_customer_order( surl varchar2, cusrec in customer_account%rowtype, theme_rec in theme_types%rowtype, voidrec in order_style%rowtype, sess_id in integer, stype in integer, ltype in varchar2, pfx in THEME%ROWTYPE, acid in integer default null, browse_edit in varchar2, ord_exists out boolean, grand_ttl out number, newline in out boolean, override_width in varchar2 default null, retlink in varchar2 default null, pkg in integer default null, disable_show_total in boolean default FALSE, show_package_items in boolean default FALSE )
as

 cursor c2( sess_id integer, pkg integer ) is
  select /*+ ALL_ROWS */ *
  from shopping_basket sb
  where sb.poid in (select po.poid from purchase_order po where sessid = sess_id) and
        (
         (pkg is null and
           ( packaged_product_id is null or
            (packaged_product_id is not null and photo_cost > 0 )
           )
          )
        or
         (pkg is not null and packaged_product_id = pkg)
        )
  order by decode(isgallery,'P',0,'Q',1,2),nvl(packaged_product_id,999999999),shopping_id;

 cursor c3(v_umo integer) is select * from umo where umo_id = v_umo;

 c3rec			c3%ROWTYPE;
 is_local		boolean;
 is_edit		boolean;
 vpoid			integer;
 totord			integer;
 ctr			integer;
 totqty			integer;
 totitm			integer;
 ttl			number;
 login_type		varchar2(20);
 clr			varchar2(20);
 dsp			varchar2(100);
 url			varchar2(1000);
 tmp1			varchar2(1000);
 tmp2			varchar2(1000);
 tmp3			varchar2(1000);
 tmp			varchar2(32767);

begin
 is_local := check_cntry( voidrec, sess_id );
 is_edit := browse_edit = 'EDIT';

  if newline
   then
    htp.nl;
   else
    newline := TRUE;
  end if;
  if voidrec.disp_ord_summ_title is not null
   then
    if browse_edit = 'EDIT'
     then
      htp.tableopen( cattributes=>'width=' || nvl(override_width,'"80%"') || ' cellpadding=2 cellspacing=2 border=0' );
     else
      htp.tableopen( cattributes=>'width=' || nvl(override_width,'"100%"') || ' cellpadding=2 cellspacing=2 border=0' );
    end if;
     htp.tablerowopen;
       htp.tabledata(htf.bold( retlink ),cattributes=>'style="text-align: left;" valign="MIDDLE" ALIGN="LEFT" WIDTH="10%"');
       htp.tabledata(htf.bold( voidrec.disp_ord_summ_title ),cattributes=>'style="text-align: center;" valign="MIDDLE" ALIGN="CENTER"');
     htp.tablerowclose;
    htp.tableclose;
  end if;
  if browse_edit = 'EDIT'
   then
    htp.tableopen( cattributes=>'width=' || nvl(override_width,'"80%"') || ' cellpadding=2 cellspacing=2 border=' || pfx.ord_text_table_borderi );
   else
    htp.tableopen( cattributes=>'width=' || nvl(override_width,'"100%"') || ' cellpadding=2 cellspacing=2 border=' || pfx.ord_text_table_borderi );
  end if;
  htp.tablerowopen;
    if voidrec.disp_tracking_ctr = 'T'
     then
      htp.tabledata( '&nbsp;', cattributes=>pfx.ord_summary_hdr_clr);
    end if;
    htp.tabledata(htf.bold(nvl(voidrec.text_thumbnail,LNG.GLB_TXT_064)),cattributes=>pfx.ord_summary_hdr_clr || ' valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata(htf.bold(nvl(voidrec.text_image_title,LNG.PHG_TXT_178)),cattributes=>pfx.ord_summary_hdr_clr || ' valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata(htf.bold(nvl(voidrec.text_qty,LNG.CST_TXT_135)),cattributes=>pfx.ord_summary_hdr_clr || ' valign="MIDDLE" ALIGN="CENTER"');
    if voidrec.pricing_internal = 'F' then htp.tabledata(htf.bold(nvl(voidrec.text_subtotal_title,LNG.CST_TXT_136)),cattributes=>pfx.ord_summary_hdr_clr || ' valign="MIDDLE" ALIGN="CENTER"'); end if;
    if is_edit and voidrec.disp_remove_style = 'C' then htp.tabledata(htf.bold(voidrec.text_remove_from),cattributes=>pfx.ord_summary_hdr_clr || ' valign="MIDDLE" ALIGN="CENTER"'); end if;
    if is_edit and voidrec.disp_remove_style = 'L' then htp.tabledata('&nbsp',cattributes=>pfx.ord_summary_hdr_clr || ' valign="MIDDLE" ALIGN="CENTER"'); end if;
  htp.tablerowclose;

 totord := 0;
 totqty := 0;
 totitm := 0;
 ord_exists := FALSE;

 for shop_rec in c2( sess_id, pkg ) loop
  totqty := totqty + nvl(shop_rec.qty,0);
  totitm := totitm + 1;

  if pfx.ord_toggle_colours = 'F'
   then
    clr := pfx.ord_qcbground;
   else
    if mod(c2%ROWCOUNT,2) = 1
     then
      clr := pfx.ord_qcbground;
     else
      clr := pfx.ord_toggle_qcbground;
    end if;
  end if;

  vpoid := shop_rec.poid;
  open c3(shop_rec.phid);
  fetch c3 into c3rec;
  close c3;
  if shop_rec.umo_width > shop_rec.umo_height
   then
    dsp := ' WIDTH=' || shop_rec.umo_width;
   else
    dsp := ' HEIGHT=' || shop_rec.umo_height;
  end if;
  ord_exists := TRUE;
  login_type := ltype;
  if nvl(shop_rec.isgallery,'F') = 'T' then login_type := 'CUSTOMER_GALLERY'; end if;

  htp.tablerowopen;
   -- Display Item Counter
   if voidrec.disp_tracking_ctr = 'T'
    then
     htp.tabledata( totitm, cattributes=>pfx.ord_summary_hdr_clr);
   end if;
   -- Display Thumbnail
    tmp3 := shop_rec.umo_film_name;
    if (shop_rec.umo_film_name <> shop_rec.umo_photo_name) and (shop_rec.umo_photo_name is not null)
     then
      tmp3 := tmp3 || htf.nl || shop_rec.umo_photo_name;
    end if;

    if shop_rec.isgallery in ('C','S','P','Q') -- Manufacturer Clearance, Shop Item, Package Product
     then
       -- Display Product Image if it exists
       if shop_rec.phid is null
        then
          if shop_rec.isgallery in ('P','Q')
           then
            htp.tabledata( 'Packaged Product' || htf.nl || htf.img( DECS.IMAGE_LOCATION || 'admin/mfc.gif',cattributes=>'border=0', calt=>'Packaged Product' ), cattributes=>clr || 'valign="MIDDLE" align="CENTER" CLASS="SMALL"');
           else
            htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'admin/mfc.gif',cattributes=>'border=0', calt=>LNG2.FNM_TXT_052 ), cattributes=>clr || 'valign="MIDDLE" align="CENTER" CLASS="SMALL"');
          end if;
	  else
           url := 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || shop_rec.phid || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || shop_rec.lab_id || '&parm1=LOGIN_TYPE&parm2=MANUFACTURER';
           if voidrec.disp_ord_summ_matte = 'F'
            then
             htp.tabledata(htf.anchor2( url,
                         '<IMG BORDER=0 ' || dsp || ' SRC="' ||
                         'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || shop_rec.phid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL&parm1=LOGIN_TYPE&parm2=MANUFACTURER&parm1=AID&parm2=' || shop_rec.lab_id ||
                         '" ALT="' || LNG2.PBK_TXT_057 || '" STYLE="display:block;">' || htf.nl || tmp3, ctarget=>'IMAGE_WINDOW'),
	  	         cattributes=>clr || 'valign="MIDDLE" align="CENTER" CLASS="SMALL"');
	    else
            htp.p( '<TD ' || clr || 'valign="MIDDLE" align="CENTER" CLASS="SMALL">' );
              glbx.image_matte(pfx,shop_rec.umo_width,shop_rec.umo_height,
                               url,
  	                       '<IMG BORDER=0 ' || dsp || ' SRC="' ||
                               'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || shop_rec.phid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL&parm1=LOGIN_TYPE&parm2=MANUFACTURER&parm1=AID&parm2=' || shop_rec.lab_id ||
                               '" ALT="' || LNG2.PBK_TXT_057 || '" STYLE="display:block;">', 'IMAGE_WINDOW');
            htp.p( htf.nl || tmp3 );
            htp.p( '</TD>' );
	   end if;
       end if;

    elsif shop_rec.isgallery = 'B' -- Booking
     then
         htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'admin/booking.gif',cattributes=>'border=0', calt=>LNG5.BKN_TXT_088 ), cattributes=>clr || 'valign="MIDDLE" align="CENTER" CLASS="SMALL"');

    elsif shop_rec.isgallery = 'H' -- Specialised FTP upload (no thumbnail)
     then
         htp.tabledata( shop_rec.umo_photo_name || DECS.UNIX_OR_NT || shop_rec.umo_film_name, cattributes=>clr || 'valign="MIDDLE" align="CENTER" CLASS="SMALL"');

    else -- F, Price Book, T Gallery Photo, I Individual
        if ltype = 'EXTERNAL_ORDER'
         then
          url := '""';
         else
          url := 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || shop_rec.phid || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=POID&parm2=' || shop_rec.poid || '&parm1=LOGIN_TYPE&parm2=' || login_type|| '&parm1=AID&parm2=' || acid;
        end if;
        if voidrec.disp_ord_summ_matte = 'F'
         then
          htp.tabledata(htf.anchor2( url,
  	                            '<IMG BORDER=0 ' || dsp || ' SRC="' ||
                                    'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || shop_rec.phid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_WHAT&parm2=THUMBNAIL&parm1=POID&parm2=' || shop_rec.poid || '&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid ||
                                    '" ALT="' || LNG2.PBK_TXT_057 || '" STYLE="display:block;">', ctarget=>'IMAGE_WINDOW') || htf.nl || tmp3,
	                            cattributes=>clr || 'valign="MIDDLE" align="CENTER" CLASS="SMALL" style="text-align: center;" ');
         else
          htp.p( '<TD ' || clr || 'valign="MIDDLE" align="CENTER" CLASS="SMALL" style="text-align: center;">' );
          glbx.image_matte(pfx,shop_rec.umo_width,shop_rec.umo_height,
                           url,
  	                   '<IMG STYLE="display:block;" BORDER=0 ' || dsp || ' SRC="' ||
                           'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || shop_rec.phid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_WHAT&parm2=THUMBNAIL&parm1=POID&parm2=' || shop_rec.poid || '&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid ||
                           '" ALT="' || LNG2.PBK_TXT_057 || '">', 'IMAGE_WINDOW');
          htp.p( htf.nl || tmp3 );
          htp.p( '</TD>' );
	end if;

    end if;

    if pfx.ord_extra_col_api_call is not null
     then
      htp.p( '<TD ' || clr || 'valign="MIDDLE" align="CENTER" CLASS="SMALL">' );
      execute immediate
       'begin ' || pfx.ord_extra_col_api_call ||
       '(surl=>:surl,ltype=>:ltype,acid=>:acid,sbid=>:sbid,screen_location=>:screen_location);' ||
       'end;'
     using glbx.rndsurl(surl),ltype,acid,shop_rec.shopping_id,'ITEM';
     htp.p( '</TD>' );
    end if;

    --
    -- List of Values
    --
    if is_edit
     then
      fname.determine_price_book_display(surl, acid, voidrec, cusrec, shop_rec, theme_rec, 'MAIN', ltype, pfx.ord_qbground, clr, tmp, tmp1, tmp2, is_local, c3rec, 0, show_package_items );
     else
      fname.determine_price_book_display(surl, acid, voidrec, cusrec, shop_rec, theme_rec, 'REPORT', ltype, pfx.ord_qbground, clr, tmp, tmp1, tmp2, is_local, c3rec, 0, show_package_items );
    end if;

    -- Sub Total
    totord := totord + shop_rec.qty;
    if shop_rec.isgallery  in ('P','Q') or shop_rec.packaged_product_id is not null
     then
      htp.tabledata( htf.formhidden( 'P3', '1' ) || '1',cattributes=>clr || ' valign="MIDDLE" ALIGN="RIGHT" STYLE="text-align: right;"');
    elsif not is_edit
     then
      htp.tabledata( nvl(to_char(shop_rec.qty),'1' ),cattributes=>clr || ' valign="MIDDLE" ALIGN="RIGHT" STYLE="text-align: right;"');
     else
      htp.tabledata( htf.formtext( 'P3', 6, 20, nvl(to_char(shop_rec.qty),'1') ),cattributes=>clr || ' valign="MIDDLE" ALIGN="RIGHT" STYLE="text-align: right;"');
    end if;
    ttl := (nvl(shop_rec.photo_cost,0)+nvl(shop_rec.frame_cost,0)+nvl(shop_rec.alteration_cost,0)) * nvl(shop_rec.qty,1);
    if voidrec.pricing_internal = 'F'
     then
      htp.tabledata( htf.bold( to_char( ttl, LNG.MONEY_FORMAT )),cattributes=>clr || ' valign="MIDDLE" ALIGN="RIGHT" STYLE="text-align: right;"');
    end if;

   -- Option available to have link to remove or checkbox
   if is_edit and voidrec.disp_remove_style in ('L', 'C', 'N' ) then
    htp.formhidden( 'P0', shop_rec.shopping_id );
    if shop_rec.isgallery = 'C' and shop_rec.phid is null
     then
      htp.formhidden( 'P6', shop_rec.shopping_id );
     else
      htp.formhidden( 'P6', shop_rec.phid );
    end if;
    if voidrec.disp_remove_style = 'C'
     then
      htp.tabledata(htf.formcheckbox('P1',shop_rec.shopping_id ),cattributes=>clr || 'valign="MIDDLE" ALIGN="CENTER" STYLE="text-align: center;"');
     elsif voidrec.disp_remove_style = 'L'
      then
      htp.tabledata(htf.anchor( 'fname.remove_item?surl=' || surl || '&acid=' || acid || '&shpid=' || shop_rec.shopping_id, voidrec.text_remove_from ),cattributes=>clr || 'valign="MIDDLE" ALIGN="CENTER" STYLE="text-align: center;"');
    end if;
   end if;
   htp.tablerowclose;
 end loop;

 if disable_show_total
  then
   -- when called from package basket edit
   htp.tableclose;
   return;
 end if;

-- Display Shopping Basket Sub Total
if vpoid is not null
 then
   grand_ttl := glbx.total_payment( vpoid );
   htp.tablerowopen;
    if voidrec.disp_tracking_ctr = 'T'
     then
      --htp.tabledata( htf.bold( to_char(totitm) ), cattributes=>pfx.ord_summary_hdr_clr);
      htp.tabledata( '&nbsp;', cattributes=>pfx.ord_summary_hdr_clr);
    end if;
    htp.tabledata( '&nbsp;', cattributes=>pfx.ord_summary_hdr_clr );
    if pfx.ord_extra_col_api_call is not null
     then
      htp.p( '<TD ' || pfx.ord_qcbground || 'valign="MIDDLE" align="CENTER" CLASS="SMALL">' );
      execute immediate
       'begin ' || pfx.ord_extra_col_api_call ||
       '(surl=>:surl,ltype=>:ltype,acid=>:acid,sbid=>:sbid,screen_location=>:screen_location);' ||
       'end;'
     using glbx.rndsurl(surl),ltype,acid,vpoid,'TOTAL';
     htp.p( '</TD>' );
    end if;
    htp.tabledata( '&nbsp;',cattributes=>pfx.ord_summary_hdr_clr );
    if voidrec.disp_tracking_ctr = 'T'
     then
      htp.tabledata( htf.bold( to_char(totqty) ), cattributes=>pfx.ord_summary_hdr_clr);
     else
      if voidrec.pricing_internal = 'F'
       then
        htp.tabledata( htf.bold( nvl(voidrec.text_subtotal, '&nbsp;') ), cattributes=>pfx.ord_summary_hdr_clr);
       else
        htp.tabledata( '&nbsp;', cattributes=>pfx.ord_summary_hdr_clr);
      end if;
    end if;
    if voidrec.pricing_internal = 'F'
     then
      if voidrec.disp_show_currency = 'T'
       then
        htp.tabledata( htf.bold( to_char( grand_ttl, LNG.MONEY_FORMAT ) || ' (' || get_currency(voidrec.currency_to_use) || ')' ), cattributes=>pfx.ord_summary_hdr_clr || ' valign="MIDDLE" ALIGN="RIGHT" STYLE="text-align: right;"');
       else
        htp.tabledata( htf.bold( to_char( grand_ttl, LNG.MONEY_FORMAT )), cattributes=>pfx.ord_summary_hdr_clr || ' valign="MIDDLE" ALIGN="RIGHT" STYLE="text-align: right;"');
      end if;
    end if;
    if is_edit and voidrec.disp_remove_style in ('L', 'C' ) then htp.tabledata( '&nbsp;', cattributes=>pfx.ord_summary_hdr_clr ); end if;
   htp.tablerowclose;
end if;
htp.tableclose;

if voidrec.text_message_under_total is not null
 then
  if browse_edit = 'EDIT'
   then
    htp.tableopen( cattributes=>'width=' || nvl(override_width,'"80%"') || ' cellpadding=2 cellspacing=2 border=0' );
   else
    htp.tableopen( cattributes=>'width=' || nvl(override_width,'"100%"') || ' cellpadding=2 cellspacing=2 border=0' );
  end if;
  htp.tablerowopen;
   htp.tabledata(voidrec.text_message_under_total,cattributes=>'style="text-align: right; font-size: smaller;" valign="MIDDLE" ALIGN="RIGHT"');
  htp.tablerowclose;
 htp.tableclose;
end if;


exception when others then
 glbx.error_details( 'FNAME', 'SHOW_CUSTOMER_ORDER',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end show_customer_order;

procedure accept_acct_order( surl varchar2, acid in integer, action in varchar2 DEFAULT NULL, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, recalculate in varchar2 default null, empty in varchar2 default null, checkout in varchar2 default null, userfee in varchar2 default null )
as

 cursor c2( shopid integer ) is select photo_cost from shopping_basket where shopping_id = shopid;
 cursor c3( vspb integer ) is select * from phg_price_book where spb = vspb;

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 subtotal	number;
 quick_exit	boolean;
 vaction	varchar2(100);
 sts		varchar2(100);
 msg		varchar2(1000);
 dummy		GLBX.MYARRAY;
 result		varchar2(32767);

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.ACCEPT_ACCT_ORDER' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
 -- Business Feature overriden, get the other one
 if voidrec.bftr <> 'Use Customer Account Business Feature'
  then
   theme_rec := glbx.get_theme_types( voidrec.bftr );
 end if;

 if voidrec.laf <> 'Use Customer Account Look and Feel'
  then
   pfx := glbx.get_thm( voidrec.laf );
 end if;

 -- If Order Made Prevent Access to It
 if is_not_preorder( purchord )
  then
   recalc_order( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
   return;
 end if;

 if action is not null
  then
   vaction := action;
 elsif recalculate is not null
  then
   vaction := voidrec.text_recalculate_button;
 elsif empty is not null
  then
   vaction := voidrec.text_empty_basket_button;
 elsif userfee is not null
  then
   vaction := voidrec.text_userfee;
 end if;

 if vaction = voidrec.text_userfee
  then
   userfee_screen(surl, acid=>acid, profid=>profid, ltype=>ltype, stype=>stype, sess_id=>sess_id, footer_api=>NULL,left_api_parm=>NULL, voidrec=>voidrec, pfx=>pfx, purchord=>purchord, theme_rec=>theme_rec, cusrec=>cusrec, msg=>NULL, changeitems=>TRUE);
   return;
 end if;

 if vaction = 'E'
  then
    disp_order_page( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
    return;
 end if;

 -- Empty Basket
 if vaction = voidrec.text_empty_basket_button
  then
     delete from umo where sessid is not null and umo_id in (select phid from shopping_basket where poid = purchord.poid and isgallery in ('F') and phid is not null );
     delete from shopping_basket where poid = purchord.poid;
     delete from purchase_package_product where poid = purchord.poid;
     purchase_audit_trail( surl, purchord.poid, 'DELETE FROM BASKET', 'D', 'C', LNG4.AHC_TXT_286, purchord, voidrec );
     fname.acct_orders( surl, LNG4.AHC_TXT_287, acid );
     return;
 end if;

 -- Remove redundant items from the shopping basket
 for j in p1.first..p1.last loop
   if p1(j) <> '0'
    then
     open c2(p1(j));
     fetch c2 into c2rec;
     close c2;
     if cleanup_package(purchord.poid, p1(j) ) then null; end if;
     purchase_audit_trail( surl, purchord.poid, 'DELETE FROM BASKET', 'D', 'C', c2rec.photo_cost, purchord, voidrec );
   end if;
 end loop;

 -- Update the Shopping Basket
 -- P0 - Shopping Id
 -- P2 - New Choice (PPIT Id or UMO_ID)
 -- P3 - Quantity
 -- P6 - Before Choice Value (PPIT Id or UMO_ID)
 fname.process_purchase_order(surl, sess_id, profid, ltype, acid, 'UPDATE', voidrec, cusrec, p6, p3, p2, p0, quick_exit );

 if vaction = voidrec.text_recalculate_button or quick_exit -- Recalculate
  then
    fname.acct_orders( surl, msg, acid );
    return;
 end if;

 -- Check if any packages do not have the minimum number of items in them
 if package_min( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec )
  then
    -- xxx language file
    fname.acct_orders( surl, 'Package needs more Items in it', acid );
    return;
 end if;

 -- Check if price book is part 3, in which case make offers about packages xxxzzz
 open c3(voidrec.spb);
 fetch c3 into c3rec;
 close c3;
 if cst.packaged_product_check( 'BASKET', purchord.poid, c3rec, ltype )
  then
   -- offer package
   -- xxx language file
   glbx.main_title( surl, 'Packaged Product',glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'O25',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, excolour=>pfx.caption_text_colour, exfont=>pfx.caption_text_font,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   htp.p( '<CENTER> ' );
   htp.nl;
   cst.packprod(surl,ltype,stype,sess_id,profid,acid,cusrec,pfx,theme_rec,purchord,voidrec,null,'BASKET','Please Choose a Package');
   return;
 end if;

 -- Check if sufficient details entered to go to the payment method page
 if voidrec.disp_cntry_fnl_pge = 'T'
  then
   -- Check if all mandatory fields have been entered
   result := NULL;
   check_mandatory('ORDER', voidrec.columns_mandatory, voidrec, purchord, pfx, result );

   if result is null
    then
     -- No Errors so go to the Payment Method Page (or Confirm page is swapped around)
     if voidrec.columns_swap_pay_confirm = 'F'
      then
       subtotal := glbx.total_payment(purchord.poid);
       adjust_postage( purchord, voidrec, subtotal );
       disp_payment_page( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
      else
       disp_confirm_page( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, null );
     end if;
     return;
   end if;
   result := NULL;

 end if;

 -- Customer Contact Details
 if voidrec.disp_prompt_create_acct = 'T'
  then
     -- See if there is an API call for Contact Details.
     -- If an error occurs in the API call ignore it, its the issue of the calling program, not Piction to handle errors.
   begin
     if pfx.contact_external_call is null
      then
       -- Currently there is no Piction feature yet built to handle this. Must be done via an API call
       null;
      else
        execute immediate
        'begin ' || pfx.contact_external_call || '(surl=>:surl, acid=>:acid, ltype=>:ltype, stype=>:stype, purchid=>:purchid, called_from=>:called_from); end;'
        using surl, acid, ltype, stype, purchord.poid, 'BASKET';
        /*
        htp.p( 'begin ' || pfx.contact_external_call || '(surl=>:surl, acid=>:acid, ltype=>:ltype, stype=>:stype, purchid=>:purchid, called_from=>:called_from); end;' );
        htp.nl;
        htp.p( surl || '-' || acid || '-' || ltype || '-' || stype || '-' || purchord.poid || '-' || 'BASKET' );
        htp.nl;
        */
       return;
     end if;
   exception
    when others then null;
   end;
 end if;
 disp_order_page( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, result );

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_ACCT_ORDER',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end accept_acct_order;

function check_cntry( voidrec in order_style%rowtype, sess_id in integer )
 return boolean
is

 cursor c1( sess_id integer ) is select country from login_session where sessid=sess_id;
 c1rec	c1%ROWTYPE;

begin
 open c1( sess_id );
 fetch c1 into c1rec;
 close c1;
 if c1rec.country is null then return( TRUE ); end if;
 if voidrec.residing_country = c1rec.country then return( TRUE ); end if;
 return( FALSE );
exception
 when others then return( TRUE );
end check_cntry;

procedure purchase_audit_trail( surl in varchar2, vpoid in integer, colname in varchar2, vaction in char, vchange in char, newval in varchar2, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE )
as

 foundrec boolean;
 chk	  boolean;

begin
 insert into purchase_audit(poid,column_name,date_changed,action,changed_by,new_value)
  values
   (vpoid,colname,sysdate,vaction,vchange,newval);

 if colname = 'STATUS'
  then
   -- Check if Workflow is to be Initiated
   if purch.status = newval then return; end if; -- Status hasn't changed
   if purch.paid_method is null then return; end if;

   -- Calculate Delivery Date
   foundrec := FALSE;
   if purch.paid_method in ('MERCHANT','GIFT') and voidrec.workflow_cc_delivery = newval
    then
     foundrec := TRUE;
   elsif purch.paid_method in ('CHEQUE') and voidrec.workflow_cheque_delivery = newval
    then
     foundrec := TRUE;
   elsif purch.paid_method in ('PHONE') and voidrec.workflow_phone_delivery = newval
    then
     foundrec := TRUE;
   elsif purch.paid_method in ('BILLING') and voidrec.workflow_billing_delivery = newval
    then
     foundrec := TRUE;
   elsif purch.paid_method in ('AUTHORISATION') and voidrec.workflow_auth_delivery = newval
    then
     foundrec := TRUE;
   end if;
   if foundrec
    then
     calculate_delivery_time( surl, vpoid, purch );
     commit;
   end if;

   -- Run Workflow
   foundrec := FALSE;
   if purch.paid_method in ('MERCHANT','GIFT') and voidrec.workflow_cc_start = newval
    then
     foundrec := TRUE;
   elsif purch.paid_method in ('CHEQUE') and voidrec.workflow_cheque_start = newval
    then
     foundrec := TRUE;
   elsif purch.paid_method in ('PHONE') and voidrec.workflow_phone_start = newval
    then
     foundrec := TRUE;
   elsif purch.paid_method in ('BILLING') and voidrec.workflow_billing_start = newval
    then
     foundrec := TRUE;
   elsif purch.paid_method in ('AUTHORISATION') and voidrec.workflow_auth_start = newval
    then
     foundrec := TRUE;
   end if;
   if not foundrec then return; end if;

   -- Initiate Workflow
   initialise_workflow( surl, vpoid );

   -- Check Manual Printing with Lab
   if purch.is_b2c = 'T'
    then
     chk := lab.manual_printing_check( surl, voidrec, purch );
   end if;

 end if;

exception when others then
 glbx.error_details( 'FNAME', 'PURCHASE_AUDIT_TRAIL',errmsg=>sqlerrm,extdet=>'VPOID:' || vpoid);
end purchase_audit_trail;

procedure create_purchase_order( surl in varchar2, sess_id in integer, initial_status in varchar2, profid in integer, ltype in varchar2, cusrec in customer_account%ROWTYPE, voidrec in order_style%ROWTYPE, purch out purchase_order%ROWTYPE)
as

 cursor c2(phgid integer) is select * from photographer where pid = phgid;
 cursor c3(purchid integer) is select * from purchase_order where poid = purchid;
 cursor c4(ltype varchar2, acid integer) is select * from customer_contact where login_type = ltype and aid = acid;
 cursor c5(ltype varchar2, acid integer) is select poid from rfq_prefilled_order where login_type = ltype and aid = acid;
 cursor c6(sess_id integer) is select * from purchase_order where sessid = sess_id;

 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;

begin

  -- Double safeguard to prevent duplicate purchase orders
  open c6( sess_id );
  fetch c6 into c6rec;
  if c6%FOUND
   then
    close c6;
    purch := c6rec;
    return;
  end if;
  close c6;

  -- See if a preorder is already there waiting. If so return it (and delete it to make sure it is not reused).
  if ltype in ('OWNER','PROFILE')
   then
    open c5(ltype,nvl(profid,cusrec.aid));
    fetch c5 into c5rec;
    if c5%FOUND
     then
      close c5;
      open c3(c5rec.poid);
      fetch c3 into purch;
      close c3;
      update purchase_order set sessid = sess_id where poid = c5rec.poid;
      delete from rfq_prefilled_order where login_type = ltype and aid = nvl(profid,cusrec.aid) and poid = c5rec.poid;
      return;
    end if;
    close c5;
  end if;

  select s_purchase_order.nextval into purch.poid from dual;
  if ltype in ('PROFILE','PROFILEG')
   then
     open c4(ltype,profid);
     fetch c4 into c4rec;
     close c4;
   elsif ltype = 'PHOTOGRAPHER'
    then
     open c2(cusrec.pid);
     fetch c2 into c2rec;
     close c2;
     c4rec.sendto_name := c2rec.business_name;
     glbx.fixnm(c4rec.sendto_name,c4rec.sendto_firstname,c4rec.sendto_lastname);
     c4rec.contact_phone := c2rec.work_phone;
     c4rec.sendto_street := c2rec.contact_street;
     c4rec.sendto_suburb := c2rec.contact_suburb;
     c4rec.sendto_city := c2rec.contact_city;
     c4rec.sendto_postcode := c2rec.contact_pcode;
     c4rec.sendto_country := nvl(voidrec.residing_country,'AUSTRALIA');
     c4rec.contact_email := c2rec.contact_email;
   else
     open c4(ltype,cusrec.aid);
     fetch c4 into c4rec;
     close c4;
  end if;
  c4rec.contact_email := nvl(glbx.get_email(surl),c4rec.contact_email);
  c4rec.sendto_country := nvl(glbx.get_country(surl),c4rec.sendto_country);
  c4rec.billing_name := nvl(c4rec.billing_name,c4rec.sendto_name);
  c4rec.billing_firstname := nvl(c4rec.billing_firstname,c4rec.sendto_firstname);
  c4rec.billing_lastname := nvl(c4rec.billing_lastname,c4rec.sendto_lastname);
  if c4rec.billing_lastname is null
   then
    glbx.fixnm(c4rec.billing_name,c4rec.billing_firstname,c4rec.billing_lastname);
  end if;
  c4rec.billing_street := nvl(c4rec.billing_street,c4rec.sendto_street);
  c4rec.billing_suburb := nvl(c4rec.billing_suburb,c4rec.sendto_suburb);
  c4rec.billing_city := nvl(c4rec.billing_city,c4rec.sendto_city);
  c4rec.billing_state := nvl(c4rec.billing_state,c4rec.sendto_state);
  c4rec.billing_branch := nvl(c4rec.billing_branch,c4rec.sendto_branch);
  c4rec.billing_department := nvl(c4rec.billing_department,c4rec.sendto_department);
  c4rec.billing_postcode := nvl(c4rec.billing_postcode,c4rec.sendto_postcode);
  c4rec.billing_country := nvl(c4rec.billing_country,c4rec.sendto_country);
  c4rec.billing_email := nvl(c4rec.billing_email,c4rec.contact_email);
  c4rec.billing_phone := nvl(c4rec.billing_phone,c4rec.contact_phone);

  insert into purchase_order(poid,sessid,pid,status,date_created,contact_phone,contact_email,sendto_name,sendto_firstname,sendto_lastname,sendto_street,sendto_suburb,sendto_city,sendto_postcode,sendto_country,home_country,sendto_state,oid,
                             billing_gpo_box,billing_state,billing_fax,billing_name,billing_firstname,billing_lastname,billing_street,billing_suburb,billing_city,billing_postcode,billing_country,billing_email,billing_phone,
                             sendto_branch,sendto_department,billing_branch,billing_department) values
    (purch.poid,sess_id,cusrec.pid,initial_status,sysdate,c4rec.contact_phone,c4rec.contact_email,c4rec.sendto_name,c4rec.sendto_firstname,c4rec.sendto_lastname,c4rec.sendto_street,c4rec.sendto_suburb,c4rec.sendto_city,c4rec.sendto_postcode,c4rec.sendto_country,voidrec.residing_country,c4rec.sendto_state,voidrec.oid,
     c4rec.billing_gpo_box,c4rec.billing_state,c4rec.billing_fax,c4rec.billing_name,c4rec.billing_firstname,c4rec.billing_lastname,c4rec.billing_street,c4rec.billing_suburb,c4rec.billing_city,c4rec.billing_postcode,c4rec.billing_country,c4rec.billing_email,c4rec.billing_phone,
     c4rec.sendto_branch,c4rec.sendto_department,c4rec.billing_branch,c4rec.billing_department);

  open c3(purch.poid);
  fetch c3 into purch;
  close c3;

 exception
  when others then glbx.error_details( 'FNAME', 'CREATE_PURCHASE_ORDER',cusrec.pid,cusrec.aid,errmsg=>sqlerrm );
end create_purchase_order;

function get_purchase_order( sess_id in integer )
 return purchase_order%ROWTYPE
as
 cursor c1(sess_id integer) is select * from purchase_order where sessid = sess_id;
 c1rec	c1%ROWTYPE;
begin
 open c1(sess_id);
 fetch c1 into c1rec;
 close c1;
 return( c1rec );
end get_purchase_order;

procedure process_purchase_order(surl in varchar2, sess_id in integer, profid in integer, ltype in varchar2, acid in integer, action in varchar2 default null, voidrec in order_style%ROWTYPE, cusrec in customer_account%ROWTYPE,
                                 img_arr in GLBX.MYARRAY, qty_arr in GLBX.MYARRAY, pbook_choice_arr in GLBX.MYARRAY, shopping_id_arr in GLBX.MYARRAY, quick_exit out boolean, check_just_added_package in boolean default TRUE )
as

 cursor c2( sts varchar2 ) is select 'x' exst from workflow_state_options where option_type = 'P' and order_option = sts and work_state = 0;
 cursor c3( phgid integer ) is select * from photographer where pid = phgid;
 cursor c4( vpoid integer, acid integer ) is select shopping_id from shopping_basket sb where poid = vpoid and phid in (select umo_id from umo um where um.umo_id = sb.phid and aid <> acid and umo_type <> 'MANUFACTURER');

 purch		purchase_order%ROWTYPE;
 shoprec	shopping_basket%ROWTYPE;
 c3rec		c3%ROWTYPE;
 exst		char(1);
 shpid		integer;
 pcusrec	CUSTOMER_ACCOUNT%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	THEME_TYPES%ROWTYPE;
 purchord 	PURCHASE_ORDER%ROWTYPE;
 pvoidrec	ORDER_STYLE%ROWTYPE;
 vprofid	integer;
 exit_call	integer;
 vltype		varchar2(100);
 pkg		integer;

begin

 quick_exit := FALSE;
 open c3(cusrec.pid);
 fetch c3 into c3rec;
 close c3;
 purch := get_purchase_order( sess_id );
 if purch.poid is null
  then
   create_purchase_order(surl, sess_id, LNG.ORD_TXT_120, profid, ltype, cusrec, voidrec, purch);
  else
   -- Check if the Purchase has been purchased
   if is_not_preorder( purch )
    then
     glbx.get_all_order_details(sess_id, vltype, acid, vprofid, pcusrec, pfx, theme_rec, purch, pvoidrec );
     recalc_order( surl, 1, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purch, pvoidrec );
     return;
   end if;
 end if;

 -- For a Photographer delete any items in the shopping basket belonging to an older account
 if ltype = 'PHOTOGRAPHER'
  then
   for c4rec in c4( purchord.poid, acid ) loop
    if cleanup_package( purchord.poid, c4rec.shopping_id ) then null; end if;
   end loop;
   delete from umo where sessid is not null and umo_id in (select phid from shopping_basket sb where poid = purch.poid and isgallery in ('F') and phid is not null and phid in (select umo_id from umo um where um.umo_id = sb.phid and aid <> acid and umo_type <> 'MANUFACTURER') );
   delete from shopping_basket sb
    where poid = purch.poid and
          phid in (select umo_id from umo um where um.umo_id = sb.phid and aid <> acid and umo_type <> 'MANUFACTURER');
   -- Reset OID in Purchase to match new customer
   update purchase_order
    set
     oid = voidrec.oid
    where
     poid = purch.poid;
 end if;

 for j in (img_arr.first+1)..(img_arr.last) loop
  if (nvl(img_arr(j),'0') <> '0')
   then
    if action = 'INSERT' then shpid := NULL; else shpid := shopping_id_arr(j); end if; -- Ignore the Shopping Id on Insert.
    if substr(img_arr(j),1,1) = 'S' -- S Stands for Store
     then
      store_item( substr(img_arr(j),2), j, shpid, voidrec, purch, c3rec, qty_arr, action );
     else
      price_book_item( img_arr(j), j, shpid, voidrec, purch, cusrec, pbook_choice_arr, c3rec, qty_arr, action );
    end if;
  end if;
 end loop;

 if not check_just_added_package then return; end if;

 -- xxx check if thumbnails added before any packages, then offer package
 check_package_justadded(surl, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purch, voidrec, exit_call, pkg );
 if exit_call = 0
  then
   null;
 elsif exit_call = 1
  then
   quick_exit := TRUE;
   -- Go to screen prompting for a package
   cst.packprod_hdr(surl, null, null, null, acid );
   return;
 elsif exit_call = 2
  then
   quick_exit := TRUE;
   -- Go to screen for editing a packaged
   cst.packprod_edit( surl, null, 1, null, acid, pkg );
   return;
 end if;

 -- xxx check if package product exists, if it does see if the items can be added to it
 check_package_add(surl, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purch, voidrec );

exception when others then
 glbx.error_details( 'FNAME', 'PROCESS_PURCHASE_ORDER',errmsg=>sqlerrm);
end process_purchase_order;

procedure price_book_item( id in integer, element_id in integer, shopid integer, voidrec in order_style%ROWTYPE, purch in purchase_order%ROWTYPE, cusrec in customer_account%ROWTYPE, pbook_choice_arr in GLBX.MYARRAY, phgrec in photographer%ROWTYPE, qty_arr in GLBX.MYARRAY, action in varchar2 )
as
begin

   -- If array contains now [ then new item to insert (note first element is empty)
   /*
   for j in pbook_choice_arr.first..pbook_choice_arr.last loop
    insert into temp values( 'Y:' || pbook_choice_arr(j)); commit;
   end loop;
   */
   if pbook_choice_arr.count = 1
    then
      new_item(id, element_id, shopid, voidrec, purch, cusrec, pbook_choice_arr, phgrec, qty_arr, action );
     return;
   end if;
   if instr(pbook_choice_arr(2),']') = 0
    then
     new_item(id, element_id, shopid, voidrec, purch, cusrec, pbook_choice_arr, phgrec, qty_arr, action );
    else
     update_item(id, element_id, shopid, voidrec, purch, cusrec, pbook_choice_arr, phgrec, qty_arr, action );
   end if;

exception when others then
 glbx.error_details( 'FNAME', 'PRICE_BOOK_ITEM',errmsg=>sqlerrm, extdet=>' ELEMENT_ID:' || element_id);
end price_book_item;

procedure new_item( id in integer, element_id in integer, shopid integer, voidrec in order_style%ROWTYPE, purch in purchase_order%ROWTYPE, cusrec in customer_account%ROWTYPE, pbook_choice_arr in GLBX.MYARRAY, phgrec in photographer%ROWTYPE, qty_arr in GLBX.MYARRAY, action in varchar2 )
as

 cursor c1( ppit integer ) is
  select ppi,spb,
         decode(nvl(item_discounted,'F'),'F',charge,
                decode(sign(sysdate - nvl(item_disc_from,sysdate)),-1,charge,0,charge,
                       decode(sign(nvl(item_disc_to,sysdate) - sysdate),-1,charge,0,charge,item_disc_charge)
                       )
               ) charge,
         name,phg_code,lab_id,date_created,date_updated,film_type,film_size,enabled,is_default,comments,min_qty,max_qty,shop_item,shop_style,
         umo_id,manufacturer_id,brand_id,delivery_time_local,delivery_time_int,surcharge_local,surcharge_int,production_time,
         stock_less_than_value,status_workflow,auto_increase_perc,item_discounted,item_disc_charge,item_disc_from,item_disc_to,delivery_desc,
         product_desc,stock_less_than_desc,stock_less_purch,lease_download_object,limit_download_object
  from phg_price_item
  where ppi = ppit;

 cursor c2( v_umo integer) is select extra_film_colour from umo where umo_id = v_umo;

 cursor c3(ftype varchar2, voidrec_spb integer ) is
  select ppi,
         decode(nvl(item_discounted,'F'),'F',charge,
                decode(sign(sysdate - nvl(item_disc_from,sysdate)),-1,charge,0,charge,
                       decode(sign(nvl(item_disc_to,sysdate) - sysdate),-1,charge,0,charge,item_disc_charge)
                       )
               ) charge,
         name,phg_code,lab_id,min_qty,status_workflow,item_discounted,item_disc_charge,delivery_time_local,delivery_time_int,
         surcharge_local,surcharge_int,production_time,lease_download_object,limit_download_object,shop_item
  from phg_price_item ppit
  where ppit.spb = voidrec_spb and
        enabled = 'T' and
        is_default = 'T' and
        (nvl(upper(film_type),LNG.ORD_TXT_194) = LNG.ORD_TXT_194 or film_type = ftype);

 cursor c3b( voidrec_spb integer ) is
  select ppi,
         decode(nvl(item_discounted,'F'),'F',charge,
                decode(sign(sysdate - nvl(item_disc_from,sysdate)),-1,charge,0,charge,
                       decode(sign(nvl(item_disc_to,sysdate) - sysdate),-1,charge,0,charge,item_disc_charge)
                       )
               ) charge,
         name ,phg_code,lab_id,min_qty,status_workflow,item_discounted,item_disc_charge,delivery_time_local,delivery_time_int,
         surcharge_local,surcharge_int,production_time,lease_download_object,limit_download_object,shop_item
  from phg_price_item ppit
  where ppit.spb = voidrec_spb and
        enabled = 'T'
  order by decode(is_default,'T',1,2),charge;

 cursor c3c( v_umo integer, acid integer ) is
  select ppit.ppi,
         decode(nvl(ppit.item_discounted,'F'),'F',ppit.charge,
                decode(sign(sysdate - nvl(ppit.item_disc_from,sysdate)),-1,ppit.charge,0,ppit.charge,
                       decode(sign(nvl(ppit.item_disc_to,sysdate) - sysdate),-1,ppit.charge,0,ppit.charge,ppit.item_disc_charge)
                       )
               ) charge,
         ppit.name, ppit.phg_code, ppit.lab_id, ppit.min_qty,status_workflow,item_discounted,item_disc_charge,delivery_time_local,delivery_time_int,
         surcharge_local,surcharge_int,production_time,lease_download_object,limit_download_object,shop_item
  from umo um, price_book_map mpb, phg_price_item ppit
  where mpb.spb = ppit.spb and
        enabled = 'T' and
        um.umo_scene_id = mpb.umo_scene_id and
        mpb.aid = acid and
        um.umo_id = v_umo
  order by decode(ppit.is_default,'T',1,2),ppit.charge;

 cursor c4(prdid integer) is select manufctr_code,xref_mfctr_code,is_discounted,name,manufacturer_id,product_class from product where product_id = prdid;
 cursor c5(prdid integer) is select tax,price,commission from price_book where product_id = prdid and valid_until is null;
 cursor c6(v_umo integer) is select * from umo um where umo_id = v_umo;
 cursor c7(wsid integer) is select * from workflow_set where status_workflow = wsid;
 cursor c8( v_umo integer) is select * from gallery_charge where umo_id = v_umo order by charge;
 cursor c9(vppm integer) is select title,price from phg_price_object where ppm_id = vppm order by price desc;
 cursor c10( vspb integer, vcode varchar2 ) is select * from user_fees where spb = vspb and user_fee_code = vcode;
 cursor c11( vpoid integer ) is select user_fee_code from shopping_basket where poid = vpoid and user_fee_code is not null order by shopping_id desc;

 shoprec	shopping_basket%ROWTYPE;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c10rec		c10%ROWTYPE;

 ftype		varchar2(100);
 k		integer;
 pi		number;
 pcx		number;
 ps		varchar2(100);
 phgcode	varchar2(100);
 lbid		number;
 defqty		integer;
 wstate		integer;
 tmp		varchar2(4000);
 tmp2		varchar2(4000);

begin
   -- Price Book Item
   --ftype := nvl(ump.uma_attribute( surl,p1(j), 'PHOTO', 'FILM_TYPE' ),'ALL'); -- This call is OK. replacing it, involves the same work.
   -- Subsequently replace because it assumes you have meta data and only ordering photos
   open c2(id);
   fetch c2 into ftype;
   close c2;
   ftype := nvl(ftype,'ALL');

   open c3c(id,cusrec.aid); -- Check if a special price book on the scene
   fetch c3c into pi,pcx,ps,phgcode,lbid,defqty,wstate,c1rec.item_discounted,c1rec.item_disc_charge,c1rec.delivery_time_local,c1rec.delivery_time_int,c1rec.surcharge_local,c1rec.surcharge_int,c1rec.production_time,c1rec.lease_download_object,c1rec.limit_download_object,c1rec.shop_item;
   if c3c%NOTFOUND
    then
     close c3c;
     open c3(ftype,voidrec.spb); -- Find the first Default value that matches the photo
     fetch c3 into pi,pcx,ps,phgcode,lbid,defqty,wstate,c1rec.item_discounted,c1rec.item_disc_charge,c1rec.delivery_time_local,c1rec.delivery_time_int,c1rec.surcharge_local,c1rec.surcharge_int,c1rec.production_time,c1rec.lease_download_object,c1rec.limit_download_object,c1rec.shop_item;
     if c3%NOTFOUND
      then
       close c3;
         open c3b(voidrec.spb);
         fetch c3b into pi,pcx,ps,phgcode,lbid,defqty,wstate,c1rec.item_discounted,c1rec.item_disc_charge,c1rec.delivery_time_local,c1rec.delivery_time_int,c1rec.surcharge_local,c1rec.surcharge_int,c1rec.production_time,c1rec.lease_download_object,c1rec.limit_download_object,c1rec.shop_item;
         -- Still not found, then pick out the first item in the price book
         if c3b%NOTFOUND
          then
           close c3b;
            pi := 0;
            if nvl(voidrec.use_default_if_no_price,'T') = 'T'
             then
	      pcx := glbx.extract_master_parameter('DEFAULT_PHOTO_COST');
	      ps := glbx.extract_master_parameter('DEFAULT_PHOTO_SIZE');
	     else
	      pcx := NULL;
	      ps := 0;
	    end if;
	    phgcode := NULL;
	    lbid := NULL;
	    defqty := 1;
	    wstate := NULL;
	   else
	    close c3b;
	  end if;
     else
      close c3;
    end if;
   else
    close c3c;
  end if;

  -- Default for Download Object. Take the most expensive item from the list
  if c1rec.lease_download_object is not null
   then
    open c9(c1rec.lease_download_object);
    fetch c9 into ps,pcx;
    close c9;
  end if;

  c4rec.manufctr_code := NULL;
  c4rec.xref_mfctr_code := NULL;
  c4rec.is_discounted := NULL;
  c4rec.name := NULL;

  if lbid is not null
   then
    open c4(lbid);
    fetch c4 into c4rec;
    close c4;
    open c5(lbid);
    fetch c5 into c5rec;
    close c5;
  end if;
  open c6(id);
  fetch c6 into c6rec;
  close c6;
  if c6rec.pricing_structure = 'S' then c6rec.pricing_structure := 'F'; end if;

  if wstate is not null
   then
    open c7(wstate);
    fetch c7 into c7rec;
    close c7;
   else
    c7rec.work_state := 0;
  end if;

  if nvl(c6rec.pricing_structure,'F') = 'I' -- Individual Pricing Item (like Gallery)
    then
     open c8(id);
     fetch c8 into c8rec;
     if c8%FOUND
      then
       ps := c8rec.charge_desc;
       pcx := c8rec.charge;
     end if;
     close c8;
  end if;

  -- Default to last User Fee Code
  shoprec.original_photo_cost := pcx; -- Used if the user fee value changes, need the original value
  if voidrec.uf_enabled = 'T' and
     voidrec.uf_bl_onnew_def_last = 'T'
   then
    open c11(purch.poid);
    fetch c11 into shoprec.user_fee_code;
    close c11;
    if shoprec.user_fee_code is not null
     then
      open c10( voidrec.spb, shoprec.user_fee_code );
      fetch c10 into c10rec;
      close c10;
      pcx := user_fee_adjust_price( c10rec, pcx );
    end if;
  end if;

  shoprec.poid := purch.poid;
  shoprec.shopping_id := shopid;
  shoprec.phid := id;
  shoprec.qty := item_quantity(voidrec, element_id, qty_arr, defqty);
  shoprec.photo_size := ps;
  shoprec.photo_cost := pcx;
  shoprec.film_type := ftype;
  shoprec.ppi := pi;
  shoprec.phg_code := phgcode;
  shoprec.lab_id := c4rec.manufacturer_id;
  shoprec.manufctr_code := c4rec.manufctr_code;
  shoprec.xref_mfctr_code := c4rec.xref_mfctr_code;
  shoprec.is_discounted := c4rec.is_discounted;
  shoprec.name := c4rec.name;
  shoprec.price := c5rec.price;
  shoprec.tax := c5rec.tax;
  shoprec.commission := c5rec.commission;
  shoprec.b2c_lab_discount := glbx.man_discount( c4rec.manufacturer_id, cusrec.pid );
  shoprec.lab_charge_perc := phgrec.lab_charge_perc;
  shoprec.film_name := c6rec.extras.film_name;
  shoprec.isgallery := nvl(c6rec.pricing_structure,'F');
  -- Packaged Product
  if c1rec.shop_item = 'P' then shoprec.isgallery := 'P'; end if;
  shoprec.status_workflow := wstate;
  shoprec.work_state := c7rec.work_state;
  shoprec.item_discounted := c1rec.item_discounted;
  shoprec.item_disc_charge := c1rec.item_disc_charge;
  shoprec.delivery_time_local := c1rec.delivery_time_local;
  shoprec.delivery_time_int := c1rec.delivery_time_int;
  shoprec.surcharge_local := c1rec.surcharge_local;
  shoprec.surcharge_int := c1rec.surcharge_int;
  shoprec.production_time := c1rec.production_time;
  shoprec.delivery_desc := c1rec.delivery_desc;
  shoprec.product_desc := c1rec.product_desc;
  shoprec.ppm_id := c1rec.lease_download_object;
  shoprec.ppm_id_limit := c1rec.limit_download_object;
  shoprec.umo_width := c6rec.photo_thumbnail.width;
  shoprec.umo_height := c6rec.photo_thumbnail.height;
  shoprec.umo_film_name := c6rec.extras.film_name;
  shoprec.umo_photo_name := c6rec.extras.photo_name;
  shoprec.umo_type := c6rec.umo_type;
  shoprec.contentlength := dbms_lob.getlength(c6rec.photo_original.source.localdata);
  shoprec.ftp_location := c6rec.ftp_location;
  shoprec.ftp_virtual_dir := c6rec.ftp_virtual_dir;
  shoprec.must_download := 'F';

  if nvl(c1rec.lease_download_object,0) = 0
   then
     shoprec.ppm_title := null;
   else
     shoprec.ppm_title := ps;
  end if;
  shoprec.product_class := c4rec.product_class;

  create_shopping_basket_item( shoprec, action );
  if purch.status = 'PreOrder - No Order Made'
   then
    update purchase_order
     set
      status = LNG.ORD_TXT_120
    where
     poid = purch.poid;
  end if;

end new_item;

procedure store_item( price_book_id in integer, element_id in integer, shopid integer, voidrec in order_style%ROWTYPE, purch in purchase_order%ROWTYPE, phgrec in photographer%ROWTYPE, qty_arr in GLBX.MYARRAY, action in varchar2 )
as

 shoprec	shopping_basket%ROWTYPE;

begin

  shoprec := find_store_item( price_book_id, element_id, shopid, voidrec, purch, phgrec, qty_arr, action );
  create_shopping_basket_item( shoprec, action );
  if purch.status = 'PreOrder - No Order Made'
   then
    update purchase_order
     set
      status = LNG.ORD_TXT_120
    where
     poid = purch.poid;
  end if;

end store_item;

procedure update_item( id in integer, element_id in integer, shopid integer, voidrec in order_style%ROWTYPE, purch in purchase_order%ROWTYPE, cusrec in customer_account%ROWTYPE, pbook_choice_arr in GLBX.MYARRAY, phgrec in photographer%ROWTYPE, qty_arr in GLBX.MYARRAY, action in varchar2 )
as

 cursor c1( ppit integer ) is
  select ppi,
         decode(nvl(item_discounted,'F'),'F',charge,
                decode(sign(sysdate - nvl(item_disc_from,sysdate)),-1,charge,0,charge,
                       decode(sign(nvl(item_disc_to,sysdate) - sysdate),-1,charge,0,charge,item_disc_charge)
                       )
               ) charge,
         name,
         phg_code,lab_id,min_qty,status_workflow,item_discounted,item_disc_charge,delivery_time_local,delivery_time_int,
         surcharge_local,surcharge_int,production_time,lease_download_object,limit_download_object,delivery_desc,product_desc,shop_item
  from phg_price_item
  where ppi = ppit;

 cursor c2( v_umo integer) is select extra_film_colour from umo where umo_id = v_umo;

 cursor c3e(ppm integer, ttl varchar2, voidrec_spb integer ) is
  select ppi,
         ppo.price charge,
         ppo.title name,
         phg_code,lab_id,min_qty,status_workflow,item_discounted,item_disc_charge,delivery_time_local,delivery_time_int,
         surcharge_local,surcharge_int,production_time,lease_download_object,limit_download_object,delivery_desc,product_desc,shop_item
  from phg_price_item ppit, phg_price_object ppo
  where ppit.spb = voidrec_spb and
        ppit.lease_download_object = ppo.ppm_id and
        ppo.ppm_id = ppm and
        ppo.title = ttl;

 -- Download Object mapped to category of price book
 cursor c3f_cat(acid integer, v_umo integer, ppm integer, ttl varchar2 ) is
  select ppi,
         ppo.price charge,
         ppo.title name,
         phg_code,lab_id,min_qty,status_workflow,item_discounted,item_disc_charge,delivery_time_local,delivery_time_int,
         surcharge_local,surcharge_int,production_time,lease_download_object,limit_download_object,delivery_desc,product_desc,shop_item
  from phg_price_item ppit, umo um, price_book_map pbm, phg_price_object ppo
  where pbm.aid = acid and
        pbm.spb = ppit.spb and
        um.umo_id = v_umo and
        um.umo_scene_id = pbm.umo_scene_id and
        ppit.lease_download_object = ppo.ppm_id and
        ppo.ppm_id = ppm and
        ppo.title = ttl;

 -- Download Object mapped to category of price book
 cursor c3f_book(acid integer, vspb integer, ppm integer, ttl varchar2 ) is
  select ppi,
         ppo.price charge,
         ppo.title name,
         phg_code,lab_id,min_qty,status_workflow,item_discounted,item_disc_charge,delivery_time_local,delivery_time_int,
         surcharge_local,surcharge_int,production_time,lease_download_object,limit_download_object,delivery_desc,product_desc,shop_item
  from phg_price_item ppit, phg_price_object ppo
  where ppit.spb = vspb and
        ppit.lease_download_object = ppo.ppm_id and
        ppo.ppm_id = ppm and
        ppo.title = ttl;

 -- Price Book Mapped to Category
 cursor c3g(acid integer, v_umo integer, v_ppi integer ) is
  select ppi,
         decode(nvl(item_discounted,'F'),'F',charge,
                decode(sign(sysdate - nvl(item_disc_from,sysdate)),-1,charge,0,charge,
                       decode(sign(nvl(item_disc_to,sysdate) - sysdate),-1,charge,0,charge,item_disc_charge)
                       )
               ) charge,
         name,
         phg_code,lab_id,min_qty,status_workflow,item_discounted,item_disc_charge,delivery_time_local,delivery_time_int,
         surcharge_local,surcharge_int,production_time,lease_download_object,limit_download_object,delivery_desc,product_desc,shop_item
  from umo um, price_book_map pbm, phg_price_item ppit
  where pbm.aid = acid and
        pbm.spb = ppit.spb and
        um.umo_id = v_umo and
        um.umo_scene_id = pbm.umo_scene_id and
        ppit.ppi = v_ppi;

 cursor c4a(shoprecid integer) is select * from shopping_basket where shopping_id =  shoprecid;
 cursor c4(prdid integer) is select manufctr_code,xref_mfctr_code,is_discounted,name,manufacturer_id,product_class from product where product_id = prdid;
 cursor c5(prdid integer) is select tax,price,commission from price_book where product_id = prdid and valid_until is null;
 cursor c6(v_umo integer) is select * from umo um where umo_id = v_umo;
 cursor c7(wsid integer) is select * from workflow_set where status_workflow = wsid;
 cursor c9(mcid integer) is
  select mc.shipping_manual, mc.shipping_charge, mc.display_description, mc.umo_id, mc.manufacturer_id, mc.commission_rate
  from mfctr_clearance mc
  where mc.mfc_clr_id = mcid;
 cursor c10(shopid integer, nmb integer) is
  select price_per_unit,mfc_clr_id
  from mfctr_clearance_items
  where min_amount <= nmb and
        max_amount >= nmb and
        mfc_clr_id in (select manufctr_code from shopping_basket where shopping_id = shopid);
 cursor c11( vspb integer, vcode varchar2 ) is select * from user_fees where spb = vspb and user_fee_code = vcode;
 cursor c12( shpid integer ) is select umo_film_name, umo_photo_name from shopping_basket where shopping_id = shpid;

 shoprec	shopping_basket%ROWTYPE;

 c1rec		c1%ROWTYPE;
 c4arec		c4a%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c9rec		c9%ROWTYPE;
 c10rec		c10%ROWTYPE;
 c11rec		c11%ROWTYPE;
 ftype		varchar2(100);
 x		integer;
 k		integer;
 pi		number;
 pcx		number;
 ps		varchar2(100);
 phgcode	varchar2(100);
 lbid		number;
 defqty		integer;
 wstate		integer;
 sqty		integer;
 tmp		varchar2(4000);
 tmp2		varchar2(4000);
 item_type	char(1);

 tval		varchar2(100);
 val_ext	varchar2(100);
 val_int_a	varchar2(100);
 val_int_b	varchar2(100);

begin

   open c2(id);
   fetch c2 into ftype;
   close c2;
   ftype := nvl(ftype,'ALL');


   --for j in pbook_choice_arr.first..pbook_choice_arr.last loop
   -- glbx.dbg( nvl(shopid,id) || ':-:' || pbook_choice_arr(j) ); htp.nl;
   --end loop;


   k := indx(nvl(shopid,id),pbook_choice_arr);

   if k is null then return; end if;

   -- Safeguard to prevent errors
   if not(k is not null and pbook_choice_arr.exists(k))
    then
     if substr(pbook_choice_arr(k),2,1) = 'C' -- Manufacturer Clearances might not have an image attached
      then
       null;
      else
       return;
     end if;
   end if;
   -- Extract Values
   x := instr(pbook_choice_arr(k),']');
   item_type := substr(pbook_choice_arr(k),2,1);
   val_ext := substr(pbook_choice_arr(k),x + 1);
   val_int_a := substr(pbook_choice_arr(k),4,x-4);
   if instr(val_int_a,'~') > 0
    then
     x := instr(val_int_a,'~');
     val_int_b := substr(val_int_a,x+1);
     val_int_a := substr(val_int_a,1,x-1);
   end if;
   tval := pbook_choice_arr(k);

   if item_type in ('P','H') -- Item
    then
       open c1(val_int_a);
       fetch c1 into pi,pcx,ps,
                     phgcode,lbid,defqty,wstate,c1rec.item_discounted,c1rec.item_disc_charge,c1rec.delivery_time_local,c1rec.delivery_time_int,
                     c1rec.surcharge_local,c1rec.surcharge_int,c1rec.production_time,c1rec.lease_download_object,c1rec.limit_download_object,c1rec.delivery_desc,c1rec.product_desc,c1rec.shop_item;
       close c1;

   elsif item_type in ('I','T') -- Individual or Gallery
    then
     ps := val_int_a;
     pcx := val_int_b;

   elsif item_type = 'B' -- Booking. Not handled here, handled in Booking Program.
    then
     ps := val_int_a;
     pcx := val_int_b;

   elsif item_type = 'Y' -- Package Product. Not handled here, handled in Booking Program.
    then
      open c1(val_int_a);
      fetch c1 into pi,pcx,ps,
                     phgcode,lbid,defqty,wstate,c1rec.item_discounted,c1rec.item_disc_charge,c1rec.delivery_time_local,c1rec.delivery_time_int,
                     c1rec.surcharge_local,c1rec.surcharge_int,c1rec.production_time,c1rec.lease_download_object,c1rec.limit_download_object,c1rec.delivery_desc,c1rec.product_desc,c1rec.shop_item;
      close c1;

   elsif item_type = 'C' -- Manufacturer Clearance
    then
     begin sqty := qty_arr(element_id); exception when others then NULL; end;
     open c10(shopid, sqty);
     fetch c10 into c10rec;
     close c10;
     open c9(c10rec.mfc_clr_id);
     fetch c9 into c9rec;
     close c9;
     pcx := round(c10rec.price_per_unit * ((nvl(c9rec.commission_rate,0)/100) + 1),2);
     ps := c9rec.display_description;

   elsif item_type = 'A' -- Calculated Price
    then
     ps := 'Calculated Price';  -- name
     pcx := val_int_b; -- price
     shoprec.royalty_api_pk := val_int_a;

   elsif item_type = 'R' -- Packaged Product
    then
       open c1(val_int_a);
       fetch c1 into pi,pcx,ps,
                     phgcode,lbid,defqty,wstate,c1rec.item_discounted,c1rec.item_disc_charge,c1rec.delivery_time_local,c1rec.delivery_time_int,
                     c1rec.surcharge_local,c1rec.surcharge_int,c1rec.production_time,c1rec.lease_download_object,c1rec.limit_download_object,c1rec.delivery_desc,c1rec.product_desc,c1rec.shop_item;
       close c1;

   elsif item_type = 'D' -- Download Object
    then

       -- First See if Price Book Category. If nothing found, then check price book
       open c3f_cat(cusrec.aid, id, val_int_b, val_int_a);
       fetch c3f_cat into pi,pcx,ps,
                      phgcode,lbid,defqty,wstate,c1rec.item_discounted,c1rec.item_disc_charge,c1rec.delivery_time_local,c1rec.delivery_time_int,
                      c1rec.surcharge_local,c1rec.surcharge_int,c1rec.production_time,c1rec.lease_download_object,c1rec.limit_download_object,c1rec.delivery_desc,c1rec.product_desc,c1rec.shop_item;
       if c3f_cat%NOTFOUND
        then
         close c3f_cat;
         open c3f_book(cusrec.aid, voidrec.spb, val_int_b, val_int_a);
         fetch c3f_book into pi,pcx,ps,
                        phgcode,lbid,defqty,wstate,c1rec.item_discounted,c1rec.item_disc_charge,c1rec.delivery_time_local,c1rec.delivery_time_int,
                        c1rec.surcharge_local,c1rec.surcharge_int,c1rec.production_time,c1rec.lease_download_object,c1rec.limit_download_object,c1rec.delivery_desc,c1rec.product_desc,c1rec.shop_item;
         close c3f_book;
        else
         close c3f_cat;
       end if;

   elsif item_type = 'S' -- Shop Item
    then
     shoprec := find_store_item( val_int_a, element_id, shopid, voidrec, purch, phgrec, qty_arr, action );
     create_shopping_basket_item( shoprec, action );
     if purch.status = 'PreOrder - No Order Made'
      then
       update purchase_order
        set
         status = LNG.ORD_TXT_120
       where
        poid = purch.poid;
     end if;
     return;

   end if;

  open c4a(shopid);
  fetch c4a into c4arec;
  close c4a;

  -- Adjust fee for User Fee Code
  shoprec.original_photo_cost := pcx; -- Used if the user fee value changes, need the original value
  if c4arec.user_fee_code is not null
   then
     open c11( voidrec.spb, c4arec.user_fee_code );
     fetch c11 into c11rec;
     close c11;
     pcx := user_fee_adjust_price( c11rec, pcx );
  end if;

  shoprec := c4arec;

  if lbid is not null
   then
    open c4(lbid);
    fetch c4 into c4rec;
    close c4;
    open c5(lbid);
    fetch c5 into c5rec;
    close c5;
  end if;

  if item_type = 'H'
   then
    c6rec.umo_type := 'RELATIONAL';
    c6rec.pricing_structure := 'H';
    c6rec.extras := repeated_fields(null,null,null,null,null,null,null,'TRUE','TRUE' );
    open c12( shopid );
    fetch c12 into c6rec.extras.film_name, c6rec.extras.photo_name;
    close c12;
   else
    open c6(id);
    fetch c6 into c6rec;
    close c6;
  end if;
  if c6rec.pricing_structure = 'S' then c6rec.pricing_structure := 'F'; end if;
  if item_type = 'A' then c6rec.pricing_structure := 'A'; end if;
  if item_type = 'C'
   then
    c6rec.pricing_structure := 'C';
    c4rec.manufctr_code := shoprec.manufctr_code;
    c4rec.manufacturer_id := shoprec.lab_id;
    c5rec.price := c10rec.price_per_unit;
    shoprec.qty := sqty;
   else
    shoprec.qty := item_quantity(voidrec, element_id, qty_arr, defqty);
    shoprec.phid := id;
  end if;

  if wstate is not null
   then
    open c7(wstate);
    fetch c7 into c7rec;
    close c7;
   else
    c7rec.work_state := 0;
  end if;
  shoprec.work_state := c7rec.work_state;

  shoprec.poid := purch.poid;
  shoprec.shopping_id := shopid;
  shoprec.photo_size := ps;
  shoprec.photo_cost := pcx;
  shoprec.film_type := ftype;
  shoprec.ppi := pi;
  shoprec.phg_code := phgcode;

  shoprec.item_discounted := c1rec.item_discounted;
  shoprec.item_disc_charge := c1rec.item_disc_charge;
  shoprec.delivery_time_local := c1rec.delivery_time_local;
  shoprec.delivery_time_int := c1rec.delivery_time_int;
  shoprec.surcharge_local := c1rec.surcharge_local;
  shoprec.surcharge_int := c1rec.surcharge_int;
  shoprec.production_time := c1rec.production_time;
  shoprec.delivery_desc := c1rec.delivery_desc;
  shoprec.product_desc := c1rec.product_desc;
  shoprec.ppm_id := c1rec.lease_download_object;
  shoprec.ppm_id_limit := c1rec.limit_download_object;
  if nvl(c1rec.lease_download_object,0) = 0
   then
     shoprec.ppm_title := null;
   else
     shoprec.ppm_title := ps;
  end if;
  shoprec.lab_id := c4rec.manufacturer_id;
  shoprec.manufctr_code := c4rec.manufctr_code;
  shoprec.xref_mfctr_code := c4rec.xref_mfctr_code;
  shoprec.is_discounted := c4rec.is_discounted;
  shoprec.name := c4rec.name;
  shoprec.price := c5rec.price;
  shoprec.tax := c5rec.tax;
  shoprec.commission := c5rec.commission;
  shoprec.b2c_lab_discount := glbx.man_discount( c4rec.manufacturer_id, cusrec.pid );
  shoprec.lab_charge_perc := phgrec.lab_charge_perc;
  shoprec.film_name := c6rec.extras.film_name;
  shoprec.isgallery := nvl(c6rec.pricing_structure,'F');
  -- Packaged Product
  if c1rec.shop_item = 'P' then shoprec.isgallery := nvl(c4arec.isgallery,'P'); end if;

  shoprec.status_workflow := wstate;
  shoprec.work_state := c7rec.work_state;
  shoprec.umo_width := c6rec.photo_thumbnail.width;
  shoprec.umo_height := c6rec.photo_thumbnail.height;
  shoprec.umo_film_name := c6rec.extras.film_name;
  shoprec.umo_photo_name := c6rec.extras.photo_name;
  shoprec.umo_type := c6rec.umo_type;
  shoprec.contentlength := dbms_lob.getlength(c6rec.photo_original.source.localdata);
  shoprec.ftp_location := c6rec.ftp_location;
  shoprec.ftp_virtual_dir := c6rec.ftp_virtual_dir;
  shoprec.must_download := 'F';
  shoprec.product_class := c4rec.product_class;

  if substr(pbook_choice_arr(k),1,1) = 'I'
   then
    create_shopping_basket_item( shoprec, 'INSERT' );
   else
    create_shopping_basket_item( shoprec, 'UPDATE' );
  end if;

  if purch.status = 'PreOrder - No Order Made'
   then
    update purchase_order
     set
      status = LNG.ORD_TXT_120
    where
     poid = purch.poid;
  end if;

exception when others then
 glbx.error_details( 'FNAME', 'UPDATE_ITEM',errmsg=>sqlerrm, extdet=>'K:' || k || ' ITEM_TYPE:' || item_type || ' x:' || x || ' FTYPE:' || ftype || ' VAL_EXT:' || val_ext || ' VAL_INT_A:' || val_int_a || ' VAL_INT_B:' || val_int_b);
end update_item;

function find_store_item( price_book_id in integer, element_id in integer, shopid integer, voidrec in order_style%ROWTYPE, purch in purchase_order%ROWTYPE, phgrec in photographer%ROWTYPE, qty_arr in GLBX.MYARRAY, action in varchar2 )
 return shopping_basket%ROWTYPE
as

 cursor c1( ppit integer ) is
  select ppi,spb,
         decode(nvl(item_discounted,'F'),'F',charge,
                decode(sign(sysdate - nvl(item_disc_from,sysdate)),-1,charge,0,charge,
                       decode(sign(nvl(item_disc_to,sysdate) - sysdate),-1,charge,0,charge,item_disc_charge)
                       )
               ) charge,
         name,phg_code,lab_id,date_created,date_updated,film_type,film_size,enabled,is_default,comments,min_qty,max_qty,shop_item,shop_style,
         umo_id,manufacturer_id,brand_id,delivery_time_local,delivery_time_int,surcharge_local,surcharge_int,production_time,
         stock_less_than_value,status_workflow,auto_increase_perc,item_discounted,item_disc_charge,item_disc_from,item_disc_to,delivery_desc,
         product_desc,stock_less_than_desc,stock_less_purch,lease_download_object,limit_download_object
  from phg_price_item
  where shop_item = 'T' and ppi = ppit;

 cursor c2(wsid integer) is select * from workflow_set where status_workflow = wsid;
 cursor c3(prdid integer) is select manufctr_code,xref_mfctr_code,is_discounted,name,manufacturer_id,product_class from product where product_id = prdid;
 cursor c4(prdid integer) is select tax,price,commission from price_book where product_id = prdid and valid_until is null;
 cursor c5(v_umo integer) is select * from gallery_charge where umo_id = v_umo order by charge;
 cursor c6(v_umo integer) is select * from umo um where umo_id = v_umo;

 shoprec	shopping_basket%ROWTYPE;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 tmp2		varchar2(1000);

begin

  open c1( price_book_id );
  fetch c1 into c1rec;
  close c1;
  if c1rec.status_workflow is not null
   then
    open c2(c1rec.status_workflow);
    fetch c2 into c2rec;
    close c2;
   else
    c2rec.work_state := 0;
  end if;
  open c3(c1rec.lab_id);
  fetch c3 into c3rec;
  close c3;
  open c4(c1rec.lab_id);
  fetch c4 into c4rec;
  close c4;
  open c6(c1rec.umo_id);
  fetch c6 into c6rec;
  close c6;
  if nvl(c6rec.pricing_structure,'S') = 'I' -- Individual Pricing Item (like Gallery)
   then
    open c5(c1rec.umo_id);
    fetch c5 into c5rec;
    if c5%FOUND
     then
      c1rec.name := c5rec.charge_desc;
      c1rec.charge := c5rec.charge;
    end if;
    close c5;
  end if;

  shoprec.poid := purch.poid;
  shoprec.shopping_id := shopid;
  shoprec.phid := c1rec.umo_id;
  shoprec.qty := item_quantity(voidrec, element_id, qty_arr, c1rec.min_qty);
  shoprec.photo_size := c1rec.name;
  shoprec.photo_cost := c1rec.charge;
  shoprec.film_type := c1rec.film_type;
  shoprec.ppi := c1rec.ppi;
  shoprec.phg_code := c1rec.phg_code;
  shoprec.lab_id := c3rec.manufacturer_id;
  shoprec.manufctr_code :=c3rec.manufctr_code;
  shoprec.xref_mfctr_code := c3rec.xref_mfctr_code;
  shoprec.is_discounted := c3rec.is_discounted;
  shoprec.name := c3rec.name;
  shoprec.price := c4rec.price;
  shoprec.tax := c4rec.tax;
  shoprec.commission := c4rec.commission;
  shoprec.b2c_lab_discount := glbx.man_discount( c3rec.manufacturer_id, phgrec.pid );
  shoprec.lab_charge_perc := phgrec.lab_charge_perc;
  shoprec.film_name := c1rec.name;
  shoprec.isgallery := nvl(c6rec.pricing_structure,'S');
  shoprec.status_workflow := c1rec.status_workflow;
  shoprec.work_state := c2rec.work_state;
  shoprec.item_discounted := c1rec.item_discounted;
  shoprec.item_disc_charge := c1rec.item_disc_charge;
  shoprec.delivery_time_local := c1rec.delivery_time_local;
  shoprec.delivery_time_int := c1rec.delivery_time_int;
  shoprec.surcharge_local := c1rec.surcharge_local;
  shoprec.surcharge_int := c1rec.surcharge_int;
  shoprec.production_time := c1rec.production_time;
  shoprec.delivery_desc := c1rec.delivery_desc;
  shoprec.product_desc := c1rec.product_desc;
  shoprec.ppm_id := c1rec.lease_download_object;
  shoprec.ppm_id_limit := c1rec.limit_download_object;
  shoprec.umo_width := c6rec.photo_thumbnail.width;
  shoprec.umo_height := c6rec.photo_thumbnail.height;
  shoprec.umo_film_name := c6rec.extras.film_name;
  shoprec.umo_photo_name := c6rec.extras.photo_name;
  shoprec.umo_type := c6rec.umo_type;
  shoprec.contentlength := dbms_lob.getlength(c6rec.photo_original.source.localdata);
  shoprec.ftp_location := c6rec.ftp_location;
  shoprec.ftp_virtual_dir := c6rec.ftp_virtual_dir;
  shoprec.product_class := c3rec.product_class;

  return( shoprec );

exception
  when others then return( shoprec );
end find_store_item;

procedure create_shopping_basket_item( shoprec in shopping_basket%ROWTYPE, action in varchar2 )
as
begin
 -- Deliberately spread out to make it easier to read
if action = 'INSERT'
 then
  insert into shopping_basket
  (
   poid,
   shopping_id,
   phid,
   film_type,
   qty,
   photo_size,
   photo_cost,
   frame_style,
   frame_cost,
   alteration,
   alteration_cost,
   isgallery,
   ppi,
   phg_code,
   lab_id,
   manufctr_code,
   xref_mfctr_code,
   is_discounted,
   name,
   price,
   tax,
   commission,
   b2c_lab_discount,
   lab_charge_perc,
   film_name,
   must_download,
   status_id,
   status,
   status_priority,
   status_workflow,
   status_comment,
   work_state,
   item_discounted,
   item_disc_charge,
   delivery_time_local,
   delivery_time_int,
   surcharge_local,
   surcharge_int,
   production_time,
   delivery_desc,
   product_desc,
   status_mfctr,
   ppm_id,
   ppm_id_limit,
   umo_width,
   umo_height,
   umo_film_name,
   umo_type,
   contentlength,
   ftp_location,
   ftp_virtual_dir,
   umo_photo_name,
   ppm_title,
   invoice_number,
   invoice_date,
   tax_code,
   invoice_extracted,
   product_class,
   override_wflow_order,
   estimated_due_date,
   priority_of_item,
   royalty_api,
   royalty_api_pk,
   user_fee_code,
   original_photo_cost
  )
values
  (
   shoprec.poid,
   s_shopping_basket.nextval,
   shoprec.phid,
   shoprec.film_type,
   shoprec.qty,
   shoprec.photo_size,
   shoprec.photo_cost,
   shoprec.frame_style,
   shoprec.frame_cost,
   shoprec.alteration,
   shoprec.alteration_cost,
   shoprec.isgallery,
   shoprec.ppi,
   shoprec.phg_code,
   shoprec.lab_id,
   shoprec.manufctr_code,
   shoprec.xref_mfctr_code,
   shoprec.is_discounted,
   shoprec.name,
   shoprec.price,
   shoprec.tax,
   shoprec.commission,
   shoprec.b2c_lab_discount,
   shoprec.lab_charge_perc,
   shoprec.film_name,
   shoprec.must_download,
   shoprec.status_id,
   shoprec.status,
   shoprec.status_priority,
   shoprec.status_workflow,
   shoprec.status_comment,
   shoprec.work_state,
   shoprec.item_discounted,
   shoprec.item_disc_charge,
   shoprec.delivery_time_local,
   shoprec.delivery_time_int,
   shoprec.surcharge_local,
   shoprec.surcharge_int,
   shoprec.production_time,
   shoprec.delivery_desc,
   shoprec.product_desc,
   shoprec.status_mfctr,
   shoprec.ppm_id,
   shoprec.ppm_id_limit,
   shoprec.umo_width,
   shoprec.umo_height,
   shoprec.umo_film_name,
   shoprec.umo_type,
   shoprec.contentlength,
   shoprec.ftp_location,
   shoprec.ftp_virtual_dir,
   shoprec.umo_photo_name,
   shoprec.ppm_title,
   shoprec.invoice_number,
   shoprec.invoice_date,
   shoprec.tax_code,
   shoprec.invoice_extracted,
   shoprec.product_class,
   shoprec.override_wflow_order,
   shoprec.estimated_due_date,
   shoprec.priority_of_item,
   shoprec.royalty_api,
   shoprec.royalty_api_pk,
   shoprec.user_fee_code,
   shoprec.original_photo_cost
 );

else

 update shopping_basket
  set
   phid =		  shoprec.phid,
   film_type =		  shoprec.film_type,
   qty =		  shoprec.qty,
   photo_size =		  shoprec.photo_size,
   photo_cost =		  shoprec.photo_cost,
   frame_style =	  shoprec.frame_style,
   frame_cost =		  shoprec.frame_cost,
   alteration =		  shoprec.alteration,
   alteration_cost =	  shoprec.alteration_cost,
   isgallery =		  shoprec.isgallery,
   ppi =		  shoprec.ppi,
   phg_code =		  shoprec.phg_code,
   lab_id =		  shoprec.lab_id,
   manufctr_code =	  shoprec.manufctr_code,
   xref_mfctr_code =	  shoprec.xref_mfctr_code,
   is_discounted =	  shoprec.is_discounted,
   name =		  shoprec.name,
   price =		  shoprec.price,
   tax =		  shoprec.tax,
   commission =		  shoprec.commission,
   b2c_lab_discount =	  shoprec.b2c_lab_discount,
   lab_charge_perc =	  shoprec.lab_charge_perc,
   film_name =		  shoprec.film_name,
   must_download =	  shoprec.must_download,
   status_id =		  shoprec.status_id,
   status =		  shoprec.status,
   status_priority =	  shoprec.status_priority,
   status_workflow =	  shoprec.status_workflow,
   status_comment =	  shoprec.status_comment,
   work_state =		  shoprec.work_state,
   item_discounted =	  shoprec.item_discounted,
   item_disc_charge =	  shoprec.item_disc_charge,
   delivery_time_local =  shoprec.delivery_time_local,
   delivery_time_int =	  shoprec.delivery_time_int,
   surcharge_local =	  shoprec.surcharge_local,
   surcharge_int =	  shoprec.surcharge_int,
   production_time =	  shoprec.production_time,
   delivery_desc =	  shoprec.delivery_desc,
   product_desc =	  shoprec.product_desc,
   status_mfctr =	  shoprec.status_mfctr,
   ppm_id =		  shoprec.ppm_id,
   ppm_id_limit =	  shoprec.ppm_id_limit,
   umo_width =		  shoprec.umo_width,
   umo_height =		  shoprec.umo_height,
   umo_film_name =	  shoprec.umo_film_name,
   umo_type =		  shoprec.umo_type,
   contentlength =	  shoprec.contentlength,
   ftp_location =	  shoprec.ftp_location,
   ftp_virtual_dir =	  shoprec.ftp_virtual_dir,
   umo_photo_name =	  shoprec.umo_photo_name,
   ppm_title =		  shoprec.ppm_title,
   invoice_number =	  shoprec.invoice_number,
   invoice_date =	  shoprec.invoice_date,
   tax_code =		  shoprec.tax_code,
   invoice_extracted =	  shoprec.invoice_extracted,
   product_class =	  shoprec.product_class,
   override_wflow_order = shoprec.override_wflow_order,
   estimated_due_date =	  shoprec.estimated_due_date,
   priority_of_item =	  shoprec.priority_of_item,
   royalty_api =	  shoprec.royalty_api,
   royalty_api_pk =	  shoprec.royalty_api_pk,
   original_photo_cost =   shoprec.original_photo_cost
 where
  shopping_id = shoprec.shopping_id and
  poid = shoprec.poid;

end if;

end create_shopping_basket_item;

function indx( v_umo integer, pbook_choice_arr in GLBX.MYARRAY )
  return integer
 as
 begin
  for j in pbook_choice_arr.first..pbook_choice_arr.last loop
   --glbx.dbg('Indx:' || v_umo || '-' || pbook_choice_arr(j) );
   if substr(pbook_choice_arr(j),instr(pbook_choice_arr(j),']')+1) = to_char(v_umo)
    then
     return( j );
   end if;
  end loop;
  return( NULL );
end indx;

procedure determine_price_book_display( surl in varchar2, acid in integer, voidrec in order_style%ROWTYPE, c1rec in customer_account%ROWTYPE, shop_rec in SHOPPING_BASKET%ROWTYPE, theme_rec in THEME_TYPES%ROWTYPE, callfrom in varchar2, ltype in varchar2, back2 in varchar2, backclr3 in varchar2, tmp out varchar2, tmp1 out varchar2, tmp2 out varchar2, is_local in boolean, umrec in UMO%ROWTYPE, workflow_tot in integer default 0, show_package_items in boolean default FALSE)
as

 cursor c3(ftype varchar2, price_book integer, order_by char ) is
  select ppi,
         decode(nvl(item_discounted,'F'),'F',charge,
                decode(sign(sysdate - nvl(item_disc_from,sysdate)),-1,charge,0,charge,
                       decode(sign(nvl(item_disc_to,sysdate) - sysdate),-1,charge,0,charge,item_disc_charge)
                       )
               ) charge,
         name,is_default,min_qty,max_qty, exclusive_local, exclusive_int
  from phg_price_item ppit
  where ppit.spb = price_book and
        enabled = 'T' and
        lease_download_object is null and
        shop_item = 'F' and
        (nvl(upper(film_type),LNG.ORD_TXT_194) = LNG.ORD_TXT_194 or film_type = ftype or upper(ftype) = LNG.ORD_TXT_194 )
 order by decode(order_by,'P',to_char(charge,'0000000000.00'),'N',upper(name),'C',upper(phg_code)),charge;

 cursor c3b(ftype varchar2, price_book integer, order_by char ) is
  select lease_download_object ppm,
         decode(nvl(item_discounted,'F'),'F',charge,
                decode(sign(sysdate - nvl(item_disc_from,sysdate)),-1,charge,0,charge,
                       decode(sign(nvl(item_disc_to,sysdate) - sysdate),-1,charge,0,charge,item_disc_charge)
                       )
               ) charge,
         name,is_default,min_qty,max_qty
  from phg_price_item ppit
  where ppit.spb = price_book and
        enabled = 'T' and
        lease_download_object is not null and
        shop_item = 'F' and
        (nvl(upper(film_type),LNG.ORD_TXT_194) = LNG.ORD_TXT_194 or film_type = ftype or upper(ftype) = LNG.ORD_TXT_194 )
 order by decode(order_by,'P',to_char(charge,'0000000000.00'),'N',upper(name),'C',upper(phg_code)),charge;

 cursor c3c( v_umo integer, acid integer ) is
  select mpb.spb
  from umo um, price_book_map mpb
  where um.umo_scene_id = mpb.umo_scene_id and
        mpb.aid = acid and
        um.umo_id = v_umo;

 cursor c3s(vppit integer, order_by char ) is
  select ppi,
         decode(nvl(item_discounted,'F'),'F',charge,
                decode(sign(sysdate - nvl(item_disc_from,sysdate)),-1,charge,0,charge,
                       decode(sign(nvl(item_disc_to,sysdate) - sysdate),-1,charge,0,charge,item_disc_charge)
                       )
               ) charge,
         name,is_default,min_qty,max_qty,lab_id
  from phg_price_item ppit
  where ppit.ppi = vppit and
        enabled = 'T' and
        shop_item = 'T'
 order by decode(order_by,'P',to_char(charge,'0000000000.00'),'N',upper(name),'C',upper(phg_code)), charge;

 cursor c4( mfid integer ) is select name from manufacturer where manufacturer_id = mfid;
 cursor c5( ppm integer ) is select multiple_type from phg_price_object_defn where ppm_id = ppm;
 cursor c6( mcid integer ) is select commission_rate,min_amount,max_amount,price_per_unit from mfctr_clearance_items mci, mfctr_clearance mc where mc.mfc_clr_id = mcid and mci.mfc_clr_id = mc.mfc_clr_id order by min_amount;
 cursor c7( v_umo integer ) is select charge_desc,charge from gallery_charge where umo_id = v_umo;
 cursor c8( v_umo integer ) is select * from log_photo_mod where phid = v_umo order by date_modified desc;
 cursor c9( ppm integer ) is select * from phg_price_object where ppm_id = ppm;
 cursor c10( vspb integer, vcode varchar2 ) is select * from user_fees where spb = vspb and user_fee_code = vcode;
 cursor c11( vpoid integer, vpkg integer ) is select * from shopping_basket where poid = vpoid and packaged_product_id = vpkg;
 cursor c12( vshp integer ) is select * from shopping_basket where shopping_id = vshp;

 c3srec  		c3s%ROWTYPE;
 c4rec			c4%ROWTYPE;
 c5rec			c5%ROWTYPE;
 c10rec			c10%ROWTYPE;
 c12rec			c12%ROWTYPE;
 price_book		integer;
 tmp5			varchar2(1000);
 tmp3			varchar2(1000);
 tmp4			varchar2(20);
 prefix1		char(1);
 prefix2		char(1);

 function showprice( val in varchar2 )
  return varchar2
 as
 begin
  if voidrec.pricing_internal = 'F' then return( val ); else return( NULL ); end if;
 end showprice;

begin
  -- Determine List of Values for Listing of Order Options
  tmp := null;   -- Customer List
  tmp1 := null;  -- Manufacturer List
  tmp2 := null;  -- Manufacturer List

  if callfrom = 'SUMMARY'
   then
    tmp4 := 'PC';
    prefix1 := 'I'; -- I for Insert
   else
    tmp4 := 'P2';
    prefix1 := 'U'; -- U for Upgrade
  end if;

  -- User Fee Display
  if shop_rec.user_fee_code is not null
   then
    open c10( voidrec.spb, shop_rec.user_fee_code );
    fetch c10 into c10rec;
    close c10;
  end if;

  if voidrec.uf_specify_in_image = 'T'
   then
    if shop_rec.user_fee_code is null
     then
      tmp5 := NULL;
     else
      tmp5 := htf.nl;
      if c10rec.price_adjuster = 'I' -- Independent Price. Do not display any other price options.
       then
        tmp := c10rec.user_fee_code || '-' || c10rec.user_fee_text || showprice(' ' || to_char(shop_rec.photo_cost, LNG.MONEY_FORMAT ));
        -- tmp5 := tmp5 || c10rec.user_fee_text;
        if callfrom = 'REPORT'
         then
          htp.tabledata( tmp, cattributes=>backclr3 || 'valign="MIDDLE"');
         elsif callfrom = 'SUMMARY'
          then
           return;
         else
          htp.tabledata( htf.formhidden( tmp4, prefix1 || 'P' || '[' || shop_rec.ppi || ']' || nvl(shop_rec.shopping_id,shop_rec.phid) ) ||
                         tmp, cattributes=>backclr3 || 'valign="MIDDLE"');
         end if;
        return;
      end if;
      tmp5 := tmp5 || c10rec.user_fee_text;
    end if;
   else
    tmp5 := NULL;
  end if;

  -- Check if Price Book is attached to the scene or the whole account.
  if shop_rec.lineitem_spb is not null
   then
    price_book := shop_rec.lineitem_spb;
   else
    open c3c(shop_rec.phid,c1rec.aid);
    fetch c3c into price_book;
    if c3c%FOUND
     then
      close c3c;
     else
      close c3c;
      price_book := voidrec.spb;
    end if;
  end if;

  -- Part of Packaged Product
  if nvl(shop_rec.isgallery,'F') <> 'P' and (shop_rec.packaged_product_id is not null and nvl(shop_rec.photo_cost,0) = 0 and not show_package_items)
   then
    tmp := htf.bold(shop_rec.photo_size) || '(' || 'Included in Package Price' || ')' || htf.nl;
    tmp1 := shop_rec.photo_size ||showprice( ' ' || to_char(shop_rec.photo_cost, LNG.MONEY_FORMAT ));

  -- If Price Book Photo
  elsif nvl(shop_rec.isgallery,'F') in ('F','H')
   then
      for c3rec in c3( shop_rec.film_type, price_book,voidrec.pricing_display_order ) loop
       -- If Price Book Meta Tag Enabled then check if the item is to be displayed
       if check_meta_tag( c3rec.ppi, shop_rec.phid) and check_exclusive( is_local, c3rec.exclusive_local, c3rec.exclusive_int )
       then
        if (c3rec.min_qty is not null) and (c3rec.max_qty is null)
         then
          tmp3 := ' (' || LNG2.PBK_TXT_053 || ':' || c3rec.min_qty || ')';
        elsif (c3rec.min_qty is null) and (c3rec.max_qty is not null)
         then
          tmp3 := ' (' || LNG2.PBK_TXT_054 || ':' || c3rec.max_qty|| ')';
        elsif (c3rec.min_qty is not null) and (c3rec.max_qty is not null)
         then
          tmp3 := ' (' || LNG2.PBK_TXT_053 || ':' || c3rec.min_qty || '-' || LNG2.PBK_TXT_054 || ':' || c3rec.max_qty|| ')';
        else
          tmp3 := NULL;
        end if;
        if shop_rec.isgallery = 'H' then prefix2 := 'H'; else prefix2 := 'P'; end if;

        -- Adjust for User Fees
        c3rec.charge := user_fee_adjust_price( c10rec, c3rec.charge );

        if ((c3rec.is_default = 'T' and shop_rec.ppi is null) or (shop_rec.ppi is not null and shop_rec.ppi=c3rec.ppi)) and
           (nvl(shop_rec.must_download,'F') = 'F')
         then
          tmp := tmp || htf.formselectoption( c3rec.name || showprice(' ' || to_char(c3rec.charge, LNG.MONEY_FORMAT )) || tmp3, 'SELECTED', cattributes=>'VALUE="' || prefix1 || prefix2 || '[' || c3rec.ppi || ']' || nvl(shop_rec.shopping_id,shop_rec.phid) || '"' );
          else
          tmp := tmp || htf.formselectoption( c3rec.name || showprice(' ' || to_char(c3rec.charge, LNG.MONEY_FORMAT )) || tmp3, cattributes=>'VALUE="' || prefix1 || prefix2 || '[' || c3rec.ppi || ']' || nvl(shop_rec.shopping_id,shop_rec.phid) || '"');
        end if;

	   tmp1 := shop_rec.film_name;

           -- Adjust for User Fees
	   if ltype in ('MANUFACTURER','IMANUFACTURER')
	    then
	     if shop_rec.film_name is null
	      then
	       tmp1 := '[' || shop_rec.phid || '] ' || showprice(user_fee_adjust_price( c10rec, shop_rec.photo_cost ));
	       tmp2 := showprice(to_char(shop_rec.photo_cost, LNG.MONEY_FORMAT ));
	       -- if shop_rec.must_download = 'T' then tmp2 := tmp2 || htf.nl || LNG4.AHC_TXT_243; end if;
	      else
	       tmp1 := shop_rec.film_name;
	       tmp2 := shop_rec.photo_size || showprice(htf.nl || to_char(user_fee_adjust_price( c10rec, shop_rec.photo_cost ), LNG.MONEY_FORMAT ));
	       -- if shop_rec.must_download = 'T' then tmp2 := tmp2 || htf.nl || LNG4.AHC_TXT_243; end if;
	     end if;
	    elsif (callfrom = 'REPORT')
	     then
	       tmp1 := shop_rec.photo_size || showprice(htf.nl || to_char(user_fee_adjust_price( c10rec, shop_rec.photo_cost ), LNG.MONEY_FORMAT ));
	       -- if shop_rec.must_download = 'T' then tmp1 := tmp1 || htf.nl || LNG4.AHC_TXT_243; end if;
	    end if;
	    -- Display name of Manufacturer
	     if shop_rec.lab_id is not null and ltype in ('MANUFACTURER','IMANUFACTURER')
	     then
           open c4(shop_rec.lab_id);
           fetch c4 into c4rec;
           close c4;
           tmp1 := tmp1 || htf.nl || c4rec.name;
	    end if;
	  end if;
      end loop;

      -- Look for downloadable objects
      for c3brec in c3b( shop_rec.film_type, price_book,voidrec.pricing_display_order ) loop
        for c9rec in c9(c3brec.ppm) loop
         prefix2 := 'D';
         -- Adjust for User Fees
         c9rec.price := user_fee_adjust_price( c10rec, c9rec.price );
         if shop_rec.ppm_title = c9rec.title
          then
           tmp := tmp || htf.formselectoption( c9rec.title || showprice(' ' || to_char(c9rec.price, LNG.MONEY_FORMAT )), 'SELECTED', cattributes=>'VALUE="' || prefix1 || prefix2 || '[' || c9rec.title || '~' || c9rec.ppm_id  || ']' || nvl(shop_rec.shopping_id,shop_rec.phid) || '"' );
           tmp1 := c9rec.title || ' ' || to_char(c9rec.price, LNG.MONEY_FORMAT );
          else
           tmp := tmp || htf.formselectoption( c9rec.title || showprice(' ' || to_char(c9rec.price, LNG.MONEY_FORMAT )), cattributes=>'VALUE="' || prefix1 || prefix2 || '[' || c9rec.title || '~' || c9rec.ppm_id  || ']' || nvl(shop_rec.shopping_id,shop_rec.phid) || '"' );
         end if;
        end loop;
      end loop;

    -- If no price list could be determined, then use default values
    if tmp is null
     then
      if nvl(voidrec.use_default_if_no_price,'T') = 'T'
       then
        tmp := htf.formselectopen( tmp4 ) || htf.formselectoption(glbx.extract_master_parameter('DEFAULT_PHOTO_SIZE') || showprice(' ' || to_char(to_number(glbx.extract_master_parameter('DEFAULT_PHOTO_COST')), LNG.MONEY_FORMAT ))) || htf.formselectclose;
        tmp1 := glbx.extract_master_parameter('DEFAULT_PHOTO_SIZE') || showprice(' ' || to_char(to_number(glbx.extract_master_parameter('DEFAULT_PHOTO_COST')), LNG.MONEY_FORMAT ));
       else
        tmp := NULL;
        tmp1 := NULL;
      end if;
     else
      tmp := htf.formselectopen( tmp4 ) || tmp || htf.formselectclose;
    end if;

  -- Shop Item
  elsif shop_rec.isgallery = 'S'
   then
    open c3s( shop_rec.ppi,voidrec.pricing_display_order );
    fetch c3s into c3srec;
    close c3s;
    c4rec.name := NULL;
    if c3srec.lab_id is not null and ltype in ('MANUFACTURER','IMANUFACTURER')
     then
      open c4(shop_rec.lab_id);
      fetch c4 into c4rec;
      close c4;
    end if;
    -- Adjust for User Fees
    c3srec.charge := user_fee_adjust_price( c10rec, c3srec.charge );
    prefix2 := 'S';
    tmp := tmp || htf.formhidden( tmp4, prefix1 || prefix2 || '[' || c3srec.ppi || ']' || nvl(shop_rec.shopping_id,shop_rec.phid)  ) || htf.bold(c3srec.name || showprice(' ' || to_char(c3srec.charge, LNG.MONEY_FORMAT ))) || htf.nl;
    tmp1 := nvl(c4rec.name,shop_rec.film_name);
    tmp2 := c3srec.name || showprice(' ' || to_char(c3srec.charge, LNG.MONEY_FORMAT ));

  --- Manufacturer Shipping Clearance
  elsif shop_rec.isgallery = 'C'
   then
    prefix2 := 'C';
    for c6rec in c6(shop_rec.manufctr_code) loop
     if c6rec.min_amount <= shop_rec.qty and
        c6rec.max_amount >= shop_rec.qty
      then
       tmp := tmp || htf.formhidden( tmp4, prefix1 || prefix2 || '[' || shop_rec.shopping_id || ']' || shop_rec.shopping_id ) || '[' || c6rec.min_amount || '-' || c6rec.max_amount || ']' || htf.bold(shop_rec.photo_size || showprice(' ' || to_char(round(c6rec.price_per_unit * ((nvl(c6rec.commission_rate,0)/100) + 1),2), LNG.MONEY_FORMAT ))) || htf.nl;
       tmp1 := shop_rec.photo_size || showprice(' ' || to_char(round(c6rec.price_per_unit * ((nvl(c6rec.commission_rate,0)/100) + 1),2), LNG.MONEY_FORMAT ));
      else
       tmp := tmp || '[' || c6rec.min_amount || '-' || c6rec.max_amount || ']' || shop_rec.photo_size || showprice(' ' || to_char(round(c6rec.price_per_unit * ((nvl(c6rec.commission_rate,0)/100) + 1),2), LNG.MONEY_FORMAT )) || htf.nl;
     end if;
    end loop;
    tmp1 := shop_rec.photo_size || ' ' || to_char(shop_rec.photo_cost, LNG.MONEY_FORMAT );

  --- Booking
  elsif shop_rec.isgallery = 'B' -- Booking Item
   then
    prefix2 := 'B';
    tmp := tmp || htf.formhidden( tmp4, prefix1 || prefix2 || shop_rec.photo_size ) || htf.bold(shop_rec.photo_size) || htf.nl;
    tmp1 := shop_rec.photo_size ||showprice( ' ' || to_char(shop_rec.photo_cost, LNG.MONEY_FORMAT ));

  --- Packaged Product
  elsif shop_rec.isgallery = 'P' -- Packaged Product
   then
    prefix2 := 'Y';
    tmp := htf.formhidden( tmp4, prefix1 || prefix2 || '[' || shop_rec.ppi || '~' || to_char(shop_rec.photo_cost) || ']' || shop_rec.shopping_id ) ||
           htf.bold(htf.anchor( 'cst.packprod_edit' || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=&start_from=1&display_detail=&acid=' || acid, shop_rec.photo_size )) ||
            showprice( ' ' || to_char(shop_rec.photo_cost, LNG.MONEY_FORMAT )) || htf.nl; -- (+mark products as packaged)
    for c11rec in c11( shop_rec.poid, shop_rec.shopping_id ) loop
     tmp := tmp || c11%ROWCOUNT || '.' || ' ' || c11rec.film_name || htf.nl;
    end loop;
    tmp1 := shop_rec.photo_size ||showprice( ' ' || to_char(shop_rec.photo_cost, LNG.MONEY_FORMAT ));

  --- Packaged Product
  elsif shop_rec.isgallery = 'Q' -- Confirmed Packaged Product
   then
    prefix2 := 'Y';
    tmp := htf.formhidden( tmp4, prefix1 || prefix2 || '[' || shop_rec.ppi || '~' || to_char(shop_rec.photo_cost) || ']' || shop_rec.shopping_id ) ||
           htf.bold(shop_rec.photo_size) ||
            showprice( ' ' || to_char(shop_rec.photo_cost, LNG.MONEY_FORMAT )) || htf.nl; -- (+mark products as packaged)
    for c11rec in c11( shop_rec.poid, shop_rec.shopping_id ) loop
     tmp := tmp || c11%ROWCOUNT || '.' || ' ' || c11rec.film_name || htf.nl;
    end loop;
    tmp1 := shop_rec.photo_size ||showprice( ' ' || to_char(shop_rec.photo_cost, LNG.MONEY_FORMAT ));

  elsif shop_rec.isgallery = 'A' -- Pricing Calculator Item
   then
    prefix2 := 'A';
    tmp := tmp || htf.formhidden( tmp4, prefix1 || prefix2 || '[' || shop_rec.royalty_api_pk || '~' || to_char(shop_rec.photo_cost) || ']' || shop_rec.shopping_id ) || htf.bold(shop_rec.photo_size) || htf.nl;
    tmp1 := shop_rec.photo_size || showprice(' ' || to_char(shop_rec.photo_cost, LNG.MONEY_FORMAT ));

  else
    -- Gallery Photo
    -- shop_rec.isgallery = T or I
    prefix2 := shop_rec.isgallery;
    for c7rec in c7(shop_rec.phid) loop
    -- Adjust for User Fees
    c7rec.charge := user_fee_adjust_price( c10rec, c7rec.charge );
    if c7rec.charge_desc = shop_rec.photo_size
     then
      tmp := tmp || htf.formselectoption( c7rec.charge_desc || showprice(' ' || to_char(c7rec.charge, LNG.MONEY_FORMAT )), 'SELECTED', cattributes=>'VALUE="' || prefix1 || prefix2 || '[' || c7rec.charge_desc || '~' || to_char(c7rec.charge) || ']' || nvl(shop_rec.shopping_id,shop_rec.phid) || '"' );
      tmp1 := c7rec.charge_desc || ' ' || to_char(c7rec.charge, LNG.MONEY_FORMAT );
     else
      tmp := tmp || htf.formselectoption( c7rec.charge_desc || showprice(' ' || to_char(c7rec.charge, LNG.MONEY_FORMAT )), cattributes=>'VALUE="' || prefix1 || prefix2 || '[' || c7rec.charge_desc || '~' || to_char(c7rec.charge) || ']' || nvl(shop_rec.shopping_id,shop_rec.phid) || '"' );
    end if;
    end loop;
    -- Adjust for User Fees
    tmp := htf.formselectopen( tmp4 ) || tmp || htf.formselectclose;
    tmp1 := shop_rec.photo_size || showprice(' ' || to_char(user_fee_adjust_price( c10rec, shop_rec.photo_cost ), LNG.MONEY_FORMAT ));
  end if;

  if shop_rec.packaged_product_id is not null
   then
    open c12(shop_rec.packaged_product_id);
    fetch c12 into c12rec;
    close c12;
    tmp := tmp || htf.nl || 'Part of Packaged Product' || ':' || c12rec.photo_size;
    tmp1 := tmp1 || htf.nl || 'Part of Packaged Product' || ':' || c12rec.photo_size;
  end if;

  -- Photo Size Display
  if ltype in ('MANUFACTURER','IMANUFACTURER')
   then
    if workflow_tot > 0
     then
      htp.tabledata(work_details(shop_rec),cattributes=>back2 || ' valign="MIDDLE"');
    end if;
    htp.tabledata(nvl(tmp1,'&nbsp;'),cattributes=>back2 || ' valign="MIDDLE"');
    htp.tabledata(nvl(tmp2,'&nbsp;'),cattributes=>back2 || ' valign="MIDDLE"');
    tmp := NULL;
    for c8rec in c8(shop_rec.phid) loop
     tmp := tmp || htf.bold(c8rec.mod_type) || htf.nl;
     if c8rec.extra_det is not null then tmp := tmp || htf.italic( '(' || c8rec.extra_det || ')' ) || htf.nl; end if;
    end loop;
    if ltype = 'MANUFACTURER' then htp.tabledata(nvl(tmp,LNG.PHG_TXT_462),cattributes=>back2 || ' valign="MIDDLE"'); end if;

   else
    if callfrom = 'REPORT'
     then
      htp.tabledata( tmp1 || tmp5, cattributes=>backclr3 || 'valign="MIDDLE"');
    elsif callfrom = 'SUMMARY'
     then
      return;
     else
      htp.tabledata( tmp || tmp5, cattributes=>backclr3 || 'valign="MIDDLE"');
    end if;

  end if;

end determine_price_book_display;

function check_meta_tag( ppit in integer, v_umo in integer )
 return boolean
as

 cursor c1(ppit integer, v_umo integer) is
  select count('x') tot
  from phg_price_item_display
  where ppi = ppit;

 cursor c2(ppit integer, v_umo integer) is
  select ppid.value vl1, ua.value vl2
  from phg_price_item_display ppid, umo_attribute ua
  where ppi = ppit and
        ua.umo_id = v_umo and
        ua.attribute_id = ppid.attribute_id and
        nvl(position_id,1) = 1;

 c1rec	c1%ROWTYPE;

begin
 open c1(ppit, v_umo);
 fetch c1 into c1rec;
 close c1;
 -- If there are no Meta Tag Values to check return TRUE
 if c1rec.tot = 0 then return( TRUE ); end if;

 -- Assume a NULL value can equal a NULL value
 for c2rec in c2(ppit, v_umo) loop
  if nvl(c2rec.vl1,'|') <> nvl(c2rec.vl2,'|')
   then
    return( FALSE );
  end if;
 end loop;
 return( TRUE );

exception
 when others then return( TRUE );
end check_meta_tag;

function check_exclusive( is_local in boolean , exclusive_local in integer, exclusive_int integer )
 return boolean
is
begin
 if is_local and exclusive_local is null then return( TRUE ); end if;
 if not is_local and exclusive_int is null then return( TRUE ); end if;
 if is_local and exclusive_int > 0 then return( FALSE ); end if;
 return( TRUE );
end check_exclusive;

function work_details( shop_rec in SHOPPING_BASKET%ROWTYPE )
 return varchar2
as

 cursor c1(mfid integer) is select name from manufacturer where manufacturer_id = name;
 cursor c2(wsid integer) is select workflow_name from workflow_set where status_workflow = wsid;

 c1rec	c1%ROWTYPE;
 c2rec	c2%ROWTYPE;
 ret	varchar2(4000);

begin
 open c2(shop_rec.status_workflow);
 fetch c2 into c2rec;
 close c2;
 ret := htf.bold( c2rec.workflow_name ) || htf.nl;
 if shop_rec.status_mfctr is not null
  then
   open c1( shop_rec.status_mfctr );
   fetch c1 into c1rec;
   close c1;
   ret := ret || c1rec.name || htf.nl;
 end if;
 ret := ret || LNG4.AHC_TXT_726 || ':' || shop_rec.priority_of_item || htf.nl;
 ret := ret || 'Step' || ':' || shop_rec.work_state || htf.nl;
 ret := ret || LNG.CST_TXT_144 || ':' || shop_rec.status_comment;

 return( RET );
exception
 when others
  then
   return( RET );
end work_details;

function item_quantity( voidrec in order_style%ROWTYPE, ctr in integer, p3 in GLBX.MYARRAY, min_qty in integer )
 return integer
as
 retnmb		integer;
begin
 -- Modify to check for minimum amount
 if p3.count = 0 then return( nvl(min_qty,1) ); end if;
 begin retnmb := to_number(p3(ctr)); exception when others then return( 1 ); end;
 if retnmb is null then return( nvl(min_qty,1) ); end if;
 if voidrec.pricing_max_qty is null then return( retnmb ); end if;
 if retnmb > voidrec.pricing_max_qty then return( voidrec.pricing_max_qty ); end if;
 if min_qty is null then return( retnmb ); end if;
 if retnmb < min_qty then return( min_qty ); end if;
 return( retnmb );
exception
 when others then return( nvl(min_qty,1) );
end item_quantity;

procedure disp_tracing_style( surl in varchar2, stype in integer, voidrec in order_style%rowtype, pfx in theme%ROWTYPE, purchord in purchase_order%ROWTYPE, at_step in varchar2, acid in integer, ltype in varchar2, theme_rec in theme_types%ROWTYPE )
as
 ctr	integer;
begin
 if voidrec.tracing_style = 'None' then return; end if;

 --
 -- Steps:
 -- SHOPPING_BASKET
 -- CUSTOMER_DETAILS
 -- PAYMENT_METHOD
 -- HANDLE_PAYMENT
 -- FINAL_RECEIPT

 if voidrec.tracing_style = 'Simple'
  then
   htp.tableopen( cattributes=>'cellspacing=0 cellpadding=2 rules="ALL" border=1' );
    htp.tablerowopen;
     if at_step = 'USER_FEES' and voidrec.uf_display_progress_bar = 'T' and substr(theme_rec.theme_data,369,1) = 'T' and voidrec.text_page0 is not null
      then
       htp.tabledata( htf.bold(voidrec.text_page0), cattributes=>'class="TD.SMALL"' );
      elsif voidrec.uf_display_progress_bar = 'T' and voidrec.text_page0 is not null
       then
        htp.tabledata( voidrec.text_page0, cattributes=>'class="TD.SMALL"' );
     end if;
     if at_step = 'SHOPPING_BASKET'
      then
       htp.tabledata( htf.bold(voidrec.text_page1), cattributes=>'class="TD.SMALL"' );
      else
       htp.tabledata( voidrec.text_page1, cattributes=>'class="TD.SMALL"' );
     end if;
     if at_step = 'CUSTOMER_DETAILS'
      then
       htp.tabledata( htf.bold(voidrec.text_page2), cattributes=>'class="TD.SMALL"' );
      else
       htp.tabledata( voidrec.text_page2, cattributes=>'class="TD.SMALL"' );
     end if;

     if voidrec.columns_swap_pay_confirm = 'F'
      then
       if at_step = 'PAYMENT_METHOD'
        then
         htp.tabledata( htf.bold(voidrec.text_page3), cattributes=>'class="TD.SMALL"' );
        else
         htp.tabledata( voidrec.text_page3, cattributes=>'class="TD.SMALL"' );
       end if;
       if at_step = 'HANDLE_PAYMENT'
        then
         htp.tabledata( htf.bold(voidrec.text_page4), cattributes=>'class="TD.SMALL"' );
        else
         htp.tabledata( voidrec.text_page4, cattributes=>'class="TD.SMALL"' );
       end if;
     else
       if at_step = 'HANDLE_PAYMENT'
        then
         htp.tabledata( htf.bold(voidrec.text_page4), cattributes=>'class="TD.SMALL"' );
        else
         htp.tabledata( voidrec.text_page4, cattributes=>'class="TD.SMALL"' );
       end if;
       if at_step = 'PAYMENT_METHOD'
        then
         htp.tabledata( htf.bold(voidrec.text_page3), cattributes=>'class="TD.SMALL"' );
        else
         htp.tabledata( voidrec.text_page3, cattributes=>'class="TD.SMALL"' );
       end if;
     end if;

     if at_step = 'FINAL_RECEIPT'
      then
       htp.tabledata( htf.bold(voidrec.text_page5), cattributes=>'class="TD.SMALL"' );
      else
       htp.tabledata( voidrec.text_page5, cattributes=>'class="TD.SMALL"' );
     end if;
    htp.tablerowclose;
    htp.tablerowopen;
     ctr := 1;
     if at_step = 'USER_FEES' and voidrec.uf_display_progress_bar = 'T' and substr(theme_rec.theme_data,369,1) = 'T' and voidrec.text_page0 is not null
      then
       htp.tabledata( htf.bold( to_char(ctr) || ' &gt;'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT" class="TD.SMALL"');
       ctr := ctr + 1;
      elsif voidrec.uf_display_progress_bar = 'T' and voidrec.text_page0 is not null
       then
        htp.tabledata( to_char(ctr) || ' &gt;', cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT" class="TD.SMALL"');
        ctr := ctr + 1;
     end if;
     if at_step = 'SHOPPING_BASKET'
      then
       htp.tabledata( htf.bold(to_char(ctr) || ' &gt;'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT" class="TD.SMALL"');
       ctr := ctr + 1;
      else
       htp.tabledata( to_char(ctr) || ' &gt;', cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT" class="TD.SMALL"');
       ctr := ctr + 1;
     end if;
     if at_step = 'CUSTOMER_DETAILS'
      then
       htp.tabledata( htf.bold(to_char(ctr) || ' &gt;'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT" class="TD.SMALL"');
       ctr := ctr + 1;
      else
       htp.tabledata( to_char(ctr) || ' &gt;', cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT" class="TD.SMALL"');
       ctr := ctr + 1;
     end if;
     if voidrec.columns_swap_pay_confirm = 'F'
      then
       if at_step = 'PAYMENT_METHOD'
        then
         htp.tabledata( htf.bold(to_char(ctr) || ' &gt;'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT" class="TD.SMALL"');
         ctr := ctr + 1;
        else
         htp.tabledata( to_char(ctr) || ' &gt;', cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT" class="TD.SMALL"');
         ctr := ctr + 1;
       end if;
       if at_step = 'HANDLE_PAYMENT'
        then
         htp.tabledata( htf.bold(to_char(ctr) || ' &gt;'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT" class="TD.SMALL"');
         ctr := ctr + 1;
        else
         htp.tabledata( to_char(ctr) || ' &gt;', cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT" class="TD.SMALL"');
         ctr := ctr + 1;
       end if;
      else
       if at_step = 'HANDLE_PAYMENT'
        then
         htp.tabledata( htf.bold(to_char(ctr) || ' &gt;'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT" class="TD.SMALL"');
         ctr := ctr + 1;
        else
         htp.tabledata( to_char(ctr) || ' &gt;', cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT" class="TD.SMALL"');
         ctr := ctr + 1;
       end if;
       if at_step = 'PAYMENT_METHOD'
        then
         htp.tabledata( htf.bold(to_char(ctr) || ' &gt;'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT" class="TD.SMALL"');
         ctr := ctr + 1;
        else
         htp.tabledata( to_char(ctr) || ' &gt;', cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT" class="TD.SMALL"');
         ctr := ctr + 1;
       end if;
     end if;
     if at_step = 'FINAL_RECEIPT'
      then
       htp.tabledata( htf.bold(to_char(ctr) || ' &gt;'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT" class="TD.SMALL"');
         ctr := ctr + 1;
      else
       htp.tabledata( to_char(ctr) || ' &gt;', cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT" class="TD.SMALL"');
         ctr := ctr + 1;
     end if;
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;

 elsif voidrec.tracing_style = 'Thin Line'
  then
   htp.tableopen( cattributes=>'width="100%" cellspacing=0 cellpadding=2 border=0' );
    htp.tablerowopen;
     htp.tabledata( htf.line, cattributes=>'valign="BOTTOM" align="CENTER" colspan="5"');
    htp.tablerowclose;
    htp.tablerowopen;
     if at_step = 'USER_FEES' and voidrec.uf_display_progress_bar = 'T' and substr(theme_rec.theme_data,369,1) = 'T' and voidrec.text_page0 is not null
      then
       htp.tabledata( htf.bold(voidrec.text_page0), cattributes=>'valign="TOP" align="CENTER" class="TD.SMALL" style="text-align: center;"' );
      elsif voidrec.uf_display_progress_bar = 'T' and voidrec.text_page0 is not null
       then
        htp.tabledata( voidrec.text_page0, cattributes=>'align="CENTER" class="TD.SMALL" style="text-align: center;"' );
     end if;
     if at_step = 'SHOPPING_BASKET'
      then
       htp.tabledata( htf.bold(voidrec.text_page1), cattributes=>'valign="TOP" align="CENTER" class="TD.SMALL" style="text-align: center;"' );
      else
       htp.tabledata( voidrec.text_page1, cattributes=>'align="CENTER" class="TD.SMALL" style="text-align: center;"' );
     end if;
     if at_step = 'CUSTOMER_DETAILS'
      then
       htp.tabledata( htf.bold(voidrec.text_page2), cattributes=>'valign="TOP" align="CENTER" class="TD.SMALL" style="text-align: center;"' );
      else
       htp.tabledata( voidrec.text_page2, cattributes=>'align="CENTER" class="TD.SMALL" style="text-align: center;"' );
     end if;
     if voidrec.columns_swap_pay_confirm = 'F'
      then
       if at_step = 'PAYMENT_METHOD'
        then
         htp.tabledata( htf.bold(voidrec.text_page3), cattributes=>'valign="TOP" align="CENTER" class="TD.SMALL" style="text-align: center;"' );
        else
         htp.tabledata( voidrec.text_page3, cattributes=>'align="CENTER" class="TD.SMALL" style="text-align: center;"' );
       end if;
       if at_step = 'HANDLE_PAYMENT'
        then
         htp.tabledata( htf.bold(voidrec.text_page4), cattributes=>'valign="TOP" align="CENTER" class="TD.SMALL" style="text-align: center;"' );
        else
         htp.tabledata( voidrec.text_page4, cattributes=>'align="CENTER" class="TD.SMALL" style="text-align: center;"' );
       end if;
     else
       if at_step = 'HANDLE_PAYMENT'
        then
         htp.tabledata( htf.bold(voidrec.text_page4), cattributes=>'valign="TOP" align="CENTER" class="TD.SMALL" style="text-align: center;"' );
        else
         htp.tabledata( voidrec.text_page4, cattributes=>'align="CENTER" class="TD.SMALL" style="text-align: center;"' );
       end if;
       if at_step = 'PAYMENT_METHOD'
        then
         htp.tabledata( htf.bold(voidrec.text_page3), cattributes=>'valign="TOP" align="CENTER" class="TD.SMALL" style="text-align: center;"' );
        else
         htp.tabledata( voidrec.text_page3, cattributes=>'align="CENTER" class="TD.SMALL" style="text-align: center;"' );
       end if;
     end if;
     if at_step = 'FINAL_RECEIPT'
      then
       htp.tabledata( htf.bold(voidrec.text_page5), cattributes=>'valign="TOP" align="CENTER" class="TD.SMALL" style="text-align: center;"' );
      else
       htp.tabledata( voidrec.text_page5, cattributes=>'align="CENTER" class="TD.SMALL" style="text-align: center;"' );
     end if;
    htp.tablerowclose;
    htp.tablerowopen;
     if at_step = 'USER_FEES' and voidrec.uf_display_progress_bar = 'T' and substr(theme_rec.theme_data,369,1) = 'T' and voidrec.text_page0 is not null
      then
       htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/uppointer.gif',cattributes=>'border=0' ) || htf.nl || htf.bold('you are here'), cattributes=>'align="CENTER" class="TD.SMALL" style="text-align: center;"');
      elsif voidrec.uf_display_progress_bar = 'T' and voidrec.text_page0 is not null
       then
        htp.tabledata( '&nbsp;' );
     end if;
     if at_step = 'SHOPPING_BASKET'
      then
       htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/uppointer.gif',cattributes=>'border=0' ) || htf.nl || htf.bold('you are here'), cattributes=>'align="CENTER" class="TD.SMALL" style="text-align: center;"');
      else
       htp.tabledata( '&nbsp;' );
     end if;
     if at_step = 'CUSTOMER_DETAILS'
      then
       htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/uppointer.gif',cattributes=>'border=0' ) || htf.nl || htf.bold('you are here'), cattributes=>'align="CENTER" class="TD.SMALL" style="text-align: center;"');
      else
       htp.tabledata( '&nbsp;' );
     end if;
     if voidrec.columns_swap_pay_confirm = 'F'
      then
       if at_step = 'PAYMENT_METHOD'
        then
         htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/uppointer.gif',cattributes=>'border=0' ) || htf.nl || htf.bold('you are here'), cattributes=>'align="CENTER" class="TD.SMALL" style="text-align: center;"');
        else
         htp.tabledata( '&nbsp;' );
       end if;
       if at_step = 'HANDLE_PAYMENT'
        then
         htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/uppointer.gif',cattributes=>'border=0' ) || htf.nl || htf.bold('you are here'), cattributes=>'align="CENTER" class="TD.SMALL" style="text-align: center;"');
        else
         htp.tabledata( '&nbsp;' );
       end if;
     else
       if at_step = 'HANDLE_PAYMENT'
        then
         htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/uppointer.gif',cattributes=>'border=0' ) || htf.nl || htf.bold('you are here'), cattributes=>'align="CENTER" class="TD.SMALL" style="text-align: center;"');
        else
         htp.tabledata( '&nbsp;' );
       end if;
       if at_step = 'PAYMENT_METHOD'
        then
         htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/uppointer.gif',cattributes=>'border=0' ) || htf.nl || htf.bold('you are here'), cattributes=>'align="CENTER" class="TD.SMALL" style="text-align: center;"');
        else
         htp.tabledata( '&nbsp;' );
       end if;
     end if;
     if at_step = 'FINAL_RECEIPT'
      then
       htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/uppointer.gif',cattributes=>'border=0' ) || htf.nl || htf.bold('you are here'), cattributes=>'align="CENTER" class="TD.SMALL" style="text-align: center;"');
      else
       htp.tabledata( '&nbsp;' );
     end if;
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;

 elsif voidrec.tracing_style = 'Vertical Box'
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 rules="NONE" frame="HSIDES,VSIDES" border=1' );
    htp.tablerowopen;
     if at_step = 'USER_FEES' and voidrec.uf_display_progress_bar = 'T' and substr(theme_rec.theme_data,369,1) = 'T' and voidrec.text_page0 is not null
      then
       htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/leftpointer.gif',cattributes=>'border=0' ), cattributes=>'align="CENTER" style="text-align: center;"');
       htp.tabledata( htf.bold(voidrec.text_page0), cattributes=>'class="TD.SMALL"' );
      elsif voidrec.uf_display_progress_bar = 'T' and voidrec.text_page0 is not null
       then
        htp.tabledata( '&nbsp;' );
        htp.tabledata( voidrec.text_page0, cattributes=>'class="TD.SMALL"' );
     end if;
    htp.tablerowclose;
    htp.tablerowopen;
     if at_step = 'SHOPPING_BASKET'
      then
       htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/leftpointer.gif',cattributes=>'border=0' ), cattributes=>'align="CENTER" style="text-align: center;"');
       htp.tabledata( htf.bold(voidrec.text_page1), cattributes=>'class="TD.SMALL"' );
      else
       htp.tabledata( '&nbsp;' );
       htp.tabledata( voidrec.text_page1, cattributes=>'class="TD.SMALL"' );
     end if;
    htp.tablerowclose;
    htp.tablerowopen;
     if at_step = 'CUSTOMER_DETAILS'
      then
       htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/leftpointer.gif',cattributes=>'border=0' ), cattributes=>'align="CENTER" style="text-align: center;"');
       htp.tabledata( htf.bold(voidrec.text_page2), cattributes=>'class="TD.SMALL"' );
      else
       htp.tabledata( '&nbsp;' );
       htp.tabledata( LNG.CST_TXT_005, cattributes=>'class="TD.SMALL"' );
     end if;
    htp.tablerowclose;
    if voidrec.columns_swap_pay_confirm = 'F'
     then
      htp.tablerowopen;
       if at_step = 'PAYMENT_METHOD'
        then
         htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/leftpointer.gif',cattributes=>'border=0' ), cattributes=>'align="CENTER" style="text-align: center;"');
         htp.tabledata( htf.bold(voidrec.text_page3), cattributes=>'class="TD.SMALL"' );
        else
         htp.tabledata( '&nbsp;' );
         htp.tabledata( voidrec.text_page3, cattributes=>'class="TD.SMALL"' );
       end if;
      htp.tablerowclose;
      htp.tablerowopen;
      if at_step = 'HANDLE_PAYMENT'
        then
         htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/leftpointer.gif',cattributes=>'border=0' ), cattributes=>'align="CENTER" style="text-align: center;"');
         htp.tabledata( htf.bold(voidrec.text_page4), cattributes=>'class="TD.SMALL"' );
        else
         htp.tabledata( '&nbsp;' );
         htp.tabledata( voidrec.text_page4, cattributes=>'class="TD.SMALL"' );
       end if;
      htp.tablerowclose;
    else
      htp.tablerowopen;
      if at_step = 'HANDLE_PAYMENT'
        then
         htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/leftpointer.gif',cattributes=>'border=0' ), cattributes=>'align="CENTER" style="text-align: center;"');
         htp.tabledata( htf.bold(voidrec.text_page4), cattributes=>'class="TD.SMALL"' );
        else
         htp.tabledata( '&nbsp;' );
         htp.tabledata( voidrec.text_page4, cattributes=>'class="TD.SMALL"' );
       end if;
      htp.tablerowclose;
      htp.tablerowopen;
       if at_step = 'PAYMENT_METHOD'
        then
         htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/leftpointer.gif',cattributes=>'border=0' ), cattributes=>'align="CENTER" style="text-align: center;"');
         htp.tabledata( htf.bold(voidrec.text_page3), cattributes=>'class="TD.SMALL"' );
        else
         htp.tabledata( '&nbsp;' );
         htp.tabledata( voidrec.text_page3, cattributes=>'class="TD.SMALL"' );
       end if;
      htp.tablerowclose;
    end if;
    htp.tablerowopen;
     if at_step = 'FINAL_RECEIPT'
      then
       htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/leftpointer.gif',cattributes=>'border=0' ), cattributes=>'align="CENTER" style="text-align: center;"');
       htp.tabledata( htf.bold(voidrec.text_page5), cattributes=>'class="TD.SMALL"' );
      else
       htp.tabledata( '&nbsp;' );
       htp.tabledata( voidrec.text_page5, cattributes=>'class="TD.SMALL"' );
     end if;
    htp.tablerowclose;
   htp.tableclose;

 elsif voidrec.tracing_style = 'API' and voidrec.tracing_style_api is not null
  then
     execute immediate
     'begin ' || voidrec.tracing_style_api ||
     '(surl=>:surl,stype=>:stype,ltype=>:ltype,acid=>:acid,void=>:void,purchid=>:purchid, at_step=>:at_step);' ||
     'end;'
     using glbx.rndsurl(surl),stype,ltype,acid,voidrec.oid,purchord.poid,at_step;

 end if;
end disp_tracing_style;

procedure disp_order_page(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, msg in varchar2 default null, bypass in boolean default FALSE )
as

 onecol 	boolean;
 newline	boolean;
 txt		varchar2(100);
 retlink	varchar2(1000);

begin

if is_not_preorder( purchord ) and not bypass
 then
  recalc_order( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
  return;
end if;

--retlink := return_link( surl, stype, ltype, voidrec, pfx, acid, location=>'2' );
if voidrec.disp_purch_request_heading = 'T'
 then
  txt := voidrec.text_page2 || ' [' || purchord.poid || ']';
 else
  txt := voidrec.text_page2;
end if;
glbx.main_title( surl, txt,glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'O02',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,retlink=>retlink,stylesh=>pfx.stylesheet);

htp.p( '<CENTER>' );
if msg is not null
 then
  htp.p( msg );
end if;

disp_tracing_style(surl, stype, voidrec, pfx, purchord, 'CUSTOMER_DETAILS', acid, ltype, theme_rec );
if voidrec.text_phg_title is not null then htp.bold( voidrec.text_phg_title ); htp.nl; end if;
glbx.instruction( voidrec.text_help_purchase, pfx );

newline := FALSE;
onecol := one_col(voidrec, 1);

htp.formopen( 'fname.accept_order_page' );
htp.formhidden( 'SURL', glbx.rndsurl(surl) );
htp.formhidden( 'ACID', acid );
htp.formhidden( 'P1', NULL );
htp.formhidden( 'P2', NULL );
htp.formhidden( 'P3', NULL );

if onecol
 then
  htp.tableopen( cattributes=>pfx.order_nocol_table || ' cellpadding=2 cellspacing=2 rules="NONE" frame="HSIDES,VSIDES" border=' || pfx.ord_text_table_border );
   display_column(surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, msg, 1, '1', 'EDIT', newline, onecol);
  htp.tableclose;

else

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 frame="VOID" rules="COLS" border=' || pfx.ord_text_table_border );
   htp.tablerowopen;
    htp.p( '<TD VALIGN="TOP" ALIGN="LEFT" ' || pfx.order_twocol_table || '>' );
     display_column(surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, msg, 1, '1', 'EDIT', newline, onecol);
    htp.p( '</TD>' );

    newline := FALSE;
    htp.p( '<TD VALIGN="TOP" ALIGN="LEFT" ' || pfx.order_twocol_table || '>' );
     display_column(surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, msg, 1, '2', 'EDIT', newline, onecol);
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;

 end if;

 if voidrec.disp_graphic_button = 'F'
  then
   if voidrec.text_return_button is not null
    then
     htp.formsubmit( 'ACTION', voidrec.text_return_button );
   end if;
   if voidrec.text_proceed_button is not null
    then
     htp.formsubmit( 'ACTION', voidrec.text_proceed_button );
   end if;
   htp.formhidden( 'Order_Return', null );
   htp.formhidden( 'Payment', null );
  else
   htp.formimage( 'Order_Return', DECS.IMAGE_LOCATION || 'adminc/order_return.gif',cattributes=>'BORDER="0"');
   htp.formimage( 'Payment', DECS.IMAGE_LOCATION || 'adminc/order_payment.gif',cattributes=>'BORDER="0"');
   htp.formhidden( 'ACTION', null );
 end if;
 htp.formclose;

 if pfx.ord_inc_simple = 'T'
  then
    htp.nl;
    cst.disp_standard_search(surl, stype, ltype, profid, acid, cusrec, pfx, theme_rec, 'SIMPLE' );
    if pfx.ord_inc_privacy = 'T' then htp.nl; end if;
 end if;

 if pfx.ord_inc_privacy = 'T'
  then
    cst.disp_privacy(surl, ltype, profid, acid, cusrec, pfx, theme_rec );
 end if;

 if pfx.order_bottom_external is not null
  then
    execute immediate
      'begin ' || pfx.order_bottom_external ||
       '(surl=>:surl,ltype=>:ltype,acid=>:acid,screen_location=>:screen_location);' ||
       'end;'
     using glbx.rndsurl(surl),ltype,acid,'CUSTOMER_DETAILS';
 end if;
htp.p( '</CENTER>' );
glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'FNAME', 'DISP_ORDER_PAGE',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end disp_order_page;

procedure disp_confirm_page(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, msg in varchar2 default null )
as

 onecol 	boolean;
 newline	boolean;
 txt		varchar2(100);
 retlink	varchar2(1000);

begin

if voidrec.columns_swap_pay_confirm = 'T'
 then
  --retlink := return_link( surl, stype, ltype, voidrec, pfx, acid, location=>'2' );
  if voidrec.disp_purch_request_heading = 'T'
   then
    txt := voidrec.text_page4 || ' [' || purchord.poid || ']';
   else
    txt := voidrec.text_page4;
  end if;
  glbx.main_title( surl, txt, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'O04',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,retlink=>retlink,stylesh=>pfx.stylesheet);
  htp.p( '<CENTER>' );
  disp_tracing_style(surl, stype, voidrec, pfx, purchord, 'HANDLE_PAYMENT', acid, ltype, theme_rec );
  htp.nl;
 else
  htp.p( '<CENTER>' );
end if;

newline := FALSE;
onecol := one_col(voidrec, 3);

if voidrec.columns_swap_pay_confirm = 'T' and voidrec.payment_cheque_button_loc in ('T','Z')
 then
  htp.formopen( 'fname.confirm_purchase' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );
  htp.formsubmit( 'ACTION', voidrec.text_confirm_button );
  htp.formclose;
end if;

if onecol
 then
  htp.tableopen( cattributes=>pfx.order_nocol_table || ' cellpadding=2 cellspacing=2 rules="NONE" frame="HSIDES,VSIDES" border=' || pfx.ord_text_table_border );
   display_column(surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, msg, 3, '1', 'BROWSE', newline, onecol);
  htp.tableclose;

else

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 frame="VOID" rules="COLS" border=' || pfx.ord_text_table_border );
   htp.tablerowopen;
    htp.p( '<TD VALIGN="TOP" ALIGN="LEFT" ' || pfx.order_twocol_table || '>' );
     display_column(surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, msg, 3, '1', 'BROWSE', newline, onecol);
    htp.p( '</TD>' );

    newline := FALSE;
    htp.p( '<TD VALIGN="TOP" ALIGN="LEFT" ' || pfx.order_twocol_table || '>' );
     display_column(surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, msg, 3, '2', 'BROWSE', newline, onecol);
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;

end if;

if voidrec.columns_swap_pay_confirm = 'T' and voidrec.payment_cheque_button_loc in ('B','Z')
 then
  htp.formopen( 'fname.confirm_purchase' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );
  htp.formsubmit( 'ACTION', voidrec.text_confirm_button );
  htp.formclose;
end if;

exception when others then
 glbx.error_details( 'FNAME', 'DISP_CONFIRM_PAGE',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end disp_confirm_page;

procedure disp_payment_page(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, msg in varchar2 default null, calltype in varchar2 default 'FULL' )
as

 onecol 	boolean;
 newline	boolean;
 txt		varchar2(100);
 retlink	varchar2(1000);

begin

if is_not_preorder( purchord )
 then
  recalc_order( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
  return;
end if;

if calltype = 'FULL'
 then
  --retlink := return_link( surl, stype, ltype, voidrec, pfx, acid, location=>'2' );
  if voidrec.disp_purch_request_heading = 'T'
   then
    txt := voidrec.text_page3 || ' [' || purchord.poid || ']';
   else
   txt := voidrec.text_page3;
  end if;
  glbx.main_title( surl, txt, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'O03',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,retlink=>retlink,stylesh=>pfx.stylesheet);

  htp.p( '<CENTER>' );
  if calltype <> 'SUMMARY' then disp_tracing_style(surl, stype, voidrec, pfx, purchord, 'PAYMENT_METHOD', acid, ltype, theme_rec ); end if;
  if msg is not null
   then
    glbx.header_msg( msg );
  end if;
  glbx.instruction( voidrec.text_help_purchase2, pfx );
  if voidrec.text_phg_title is not null then htp.bold( voidrec.text_phg_title ); htp.nl; end if;
end if;

newline := FALSE;
onecol := one_col(voidrec, 2);
if onecol
 then
  htp.tableopen( cattributes=>pfx.order_nocol_table || ' cellpadding=4 cellspacing=2 rules="NONE" frame="HSIDES,VSIDES" border=' || pfx.ord_text_table_border );
   display_column(surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, msg, 2, '1', 'BROWSE', newline, onecol);
  htp.tableclose;
  if voidrec.text_return_message is not null
   then
    htp.anchor( 'fname.acct_orders?surl=' || surl || '&acid=' || acid, voidrec.text_return_message );
    htp.nl;
  end if;

else

  htp.tableopen( cattributes=>'cellpadding=4 cellspacing=2 frame="VOID" rules="COLS" border=' || pfx.ord_text_table_border );
   htp.tablerowopen;

    htp.p( '<TD VALIGN="TOP" ALIGN="LEFT" ' || pfx.order_twocol_table || '>' );
     display_column(surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, msg, 2, '1', 'BROWSE', newline, onecol);
    htp.p( '</TD>' );

    newline := FALSE;
    htp.p( '<TD VALIGN="TOP" ALIGN="LEFT" ' || pfx.order_twocol_table || '>' );
     display_column(surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, msg, 2, '2', 'BROWSE', newline, onecol);
     if voidrec.text_return_message is not null
      then
       htp.anchor( 'fname.acct_orders?surl=' || surl || '&acid=' || acid, voidrec.text_return_message );
     end if;
     htp.nl;
    htp.p( '</TD>' );

   htp.tablerowclose;
  htp.tableclose;
end if;

if calltype <> 'SUMMARY'
 then
  if pfx.ord_inc_simple = 'T'
   then
    cst.disp_standard_search(surl, stype, ltype, profid, acid, cusrec, pfx, theme_rec, 'SIMPLE' );
    if pfx.ord_inc_privacy = 'T' then htp.nl; end if;
  end if;

  if pfx.ord_inc_privacy = 'T'
   then
    cst.disp_privacy(surl, ltype, profid, acid, cusrec, pfx, theme_rec );
  end if;

  if pfx.order_bottom_external is not null
   then
    execute immediate
      'begin ' || pfx.order_bottom_external ||
       '(surl=>:surl,ltype=>:ltype,acid=>:acid,screen_location=>:screen_location);' ||
       'end;'
     using glbx.rndsurl(surl),ltype,acid,'PAYMENT_METHOD';
  end if;
end if;

exception when others then
 glbx.error_details( 'FNAME', 'DISP_PAYMENT_PAGE',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end disp_payment_page;

procedure disp_order_summary(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, browser_edit in varchar2, newline in out boolean, override_width in varchar2 default null )
as

 ord_exists	boolean;
 grand_ttl	number;

begin
 if voidrec.disp_ord_summ = 'F' then return; end if;
 show_customer_order( surl, cusrec, theme_rec, voidrec, sess_id, stype, ltype, pfx, acid, 'BROWSE', ord_exists, grand_ttl, newline, override_width,
                      return_link( surl, stype, ltype, voidrec, pfx, acid, location=>'2' ) );
end disp_order_summary;

---  (was disp_gift)
procedure disp_additional_options(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, browser_edit in varchar2, newline in out boolean )
as

 cursor c1(void integer) is select * from additional_options_definition where oid = void order by order_by;
 cursor c2(vpoid integer, vmerchid varchar2) is select * from purchase_additional_options where poid = vpoid and merchant_id_code = vmerchid;
 cursor c3(vpoid integer, void integer) is select * from purchase_additional_options po where poid = vpoid;

 c2rec	c2%ROWTYPE;
 nmb	number;

begin

  if voidrec.disp_gift_wrap = 'F' then return; end if;
  -- Do not display if browse and is not a gift

  if newline
   then
    htp.nl;
   else
    newline := TRUE;
  end if;
  if voidrec.disp_gift_wrap_title is not null then htp.bold( voidrec.disp_gift_wrap_title ); htp.nl; end if;

  if browser_edit = 'BROWSE'
   then
    htp.tableopen( cattributes=>'width="100%" cellpadding=4 cellspacing=1 border=' || pfx.ord_text_table_borderi );
    for c3rec in c3(purchord.poid, voidrec.oid) loop
     htp.tablerowopen;
      if c3rec.display_receipt_page = 'M'
       then
        htp.tabledata( htf.bold( c3rec.merchant_id_code), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="RIGHT"');
      elsif c3rec.display_receipt_page = 'T'
       then
        htp.tabledata( htf.bold( c3rec.display_text), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="RIGHT"');
      end if;
      htp.p( '<TD ' || pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT">' );
      htp.p( nvl(to_char(c3rec.chosen_price,LNG.MONEY_FORMAT),'&nbsp;'));
      if c3rec.display_receipt_custresp = 'T'
       then
         htp.nl;
         htp.p( c3rec.customer_comment);
      end if;
      htp.p( '</TD>' );
     htp.tablerowclose;
    end loop;
    htp.tableclose;
    return;
  end if;

  htp.tableopen( cattributes=>'width="100%" cellpadding=4 cellspacing=1 border=' || pfx.ord_text_table_borderi );
   for c1rec in c1(voidrec.oid) loop
    htp.tablerowopen;

    if c1rec.display_style = 'C'
     then
      c2rec.merchant_id_code := NULL;
      c2rec.display_text := NULL;
      c2rec.chosen_price := NULL;
      c2rec.display_receipt_page := NULL;
      c2rec.display_receipt_custresp := NULL;
      c2rec.customer_comment := NULL;
      open c2(purchord.poid,c1rec.merchant_id_code);
      fetch c2 into c2rec;
      close c2;
      if c2rec.display_text is null
       then
        htp.tabledata( htf.formcheckbox( 'P3', '[ADDOPT]' || c1rec.merchant_id_code ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="CENTER"');
       else
        htp.tabledata( htf.formcheckbox( 'P3', '[ADDOPT]' || c1rec.merchant_id_code, 'CHECKED' ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="CENTER"');
      end if;
      htp.tabledata( c1rec.display_text, cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      if c1rec.display_prices is not null
       then
        nmb := glbx.conv_nmb( c1rec.display_prices, 'MONEY' );
        if purchord.local_internation = 'LOCAL'
         then
          null;
         else
          nmb := nmb * nvl(c1rec.international_adjuster,1);
        end if;
        htp.tabledata( nvl(to_char(nmb,LNG.MONEY_FORMAT),'&nbsp;'), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="RIGHT"');
        htp.tabledata( nvl(c1rec.display_text_help,'&nbsp;'), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata( '&nbsp;', cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="RIGHT"');
        htp.tabledata( nvl(c1rec.display_text_help,'&nbsp;'), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      end if;

    elsif c1rec.display_style = 'L'
     then
      htp.tabledata( '&nbsp;', cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( nvl(c1rec.display_text_help,'&nbsp;'), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.p('<TD ' || pfx.ord_qcbground || 'valign="MIDDLE" align="CENTER">');
       htp.formhidden( 'P1', '[ADDOPT]' || c1rec.merchant_id_code );
       c2rec.merchant_id_code := NULL;
       c2rec.display_text := NULL;
       c2rec.chosen_price := NULL;
       c2rec.display_receipt_page := NULL;
       c2rec.display_receipt_custresp := NULL;
       c2rec.customer_comment := NULL;
       open c2(purchord.poid,c1rec.merchant_id_code);
       fetch c2 into c2rec;
       close c2;
       if purchord.local_internation = 'LOCAL'
         then
          add_opt_combo( 'P2', c1rec.display_text, c1rec.display_prices, c2rec.display_text );
         else
          add_opt_combo( 'P2', c1rec.display_text, c1rec.display_prices, c2rec.display_text, nvl(c1rec.international_adjuster,1) );
       end if;
      htp.p('</TD>' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
    if c1rec.customer_comment_allowed = 'T'
     then
      htp.tabledata( htf.formhidden( 'P1', '[ADDCOMM]' || c1rec.merchant_id_code ) || htf.formtext( 'P2', 30, 4000, c2rec.customer_comment ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
     else
      htp.tabledata( '&nbsp;', cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
    htp.tablerowclose;
   end loop;
 htp.tableclose;
end disp_additional_options;

procedure disp_order_tracking(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, browser_edit in varchar2, newline in out boolean )
as
begin

  if voidrec.disp_ord_trk = 'F' then return; end if;
  -- Only display if tracking password entered
  if purchord.contact_password is null and browser_edit <> 'EDIT' then return; end if;

  if newline
   then
    htp.nl;
   else
    newline := TRUE;
  end if;
  if voidrec.disp_ord_trk_title is not null then htp.bold( voidrec.disp_ord_trk_title ); htp.nl; end if;
  htp.tableopen( cattributes=>'width="100%" cellpadding=4 cellspacing=1 border=' || pfx.ord_text_table_borderi );
   if browser_edit = 'EDIT'
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.ORD_TXT_030 ), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( htf.formhidden( 'P1','OR4' ) || htf.formpassword( 'P2', 30, 100, purchord.contact_password ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');

     htp.tablerowclose;
    end if;
    htp.tabledata( htf.bold( LNG.ORD_TXT_031 ), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
    if purchord.event_confirmed = 'T'
     then
      if browser_edit = 'EDIT'
       then
        htp.tabledata( LNG.PHG_TXT_045 || ' ' || htf.formcheckbox( 'P3', 'OR1', 'CHECKED' ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata( LNG.PHG_TXT_045, cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      end if;
     else
      if browser_edit = 'EDIT'
       then
        htp.tabledata( LNG.PHG_TXT_045 || ' ' || htf.formcheckbox( 'P3', 'OR1' ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata( LNG.PHG_TXT_046, cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      end if;
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.ORD_TXT_183 ), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
    if purchord.event_issue = 'T'
     then
      if browser_edit = 'EDIT'
       then
        htp.tabledata( LNG.PHG_TXT_045 || ' ' || htf.formcheckbox( 'P3', 'OR2', 'CHECKED' ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata( LNG.PHG_TXT_045, cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      end if;
     else
      if browser_edit = 'EDIT'
       then
        htp.tabledata( LNG.PHG_TXT_045 || ' ' || htf.formcheckbox( 'P3', 'OR2' ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata( LNG.PHG_TXT_046, cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      end if;
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.ORD_TXT_184 ), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
    if purchord.event_shipped = 'T'
     then
      if browser_edit = 'EDIT'
       then
        htp.tabledata( LNG.PHG_TXT_045 || ' ' || htf.formcheckbox( 'P3', 'OR3', 'CHECKED' ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata( LNG.PHG_TXT_045, cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      end if;
     else
      if browser_edit = 'EDIT'
       then
        htp.tabledata( LNG.PHG_TXT_045 || ' ' || htf.formcheckbox( 'P3', 'OR3' ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata( LNG.PHG_TXT_046, cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      end if;
    end if;
   htp.tablerowclose;
  htp.tableclose;

end disp_order_tracking;

function format_name( txt in varchar2, pos in integer, voidrec in order_style%ROWTYPE, typ in varchar2 default 'SHOPPING' )
 return varchar2
as
 mark_ast	char(1);
begin
 if typ = 'SHOPPING' then if substr(voidrec.columns_mandatory,pos,1) = 'F' then return( txt ); end if; end if;
 if typ = 'ON_LOGIN' then if substr(voidrec.columns_mandatory_on_login,pos,1) = 'F' then return( txt ); end if; end if;
 if voidrec.columns_mark_ast = 'T' then mark_ast := '*'; else mark_ast := NULL; end if;
 if voidrec.columns_mark_bold = 'T' and voidrec.columns_mark_italic = 'T'
  then
   return( htf.bold(htf.italic(txt || mark_ast)) );
 elsif voidrec.columns_mark_bold = 'T'
  then
   return( htf.bold(txt || mark_ast) );
 elsif voidrec.columns_mark_italic = 'T'
  then
   return( htf.italic(txt || mark_ast) );
 else
  return( txt || mark_ast );
 end if;
end format_name;

procedure disp_cust_details(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, browser_edit in varchar2, newline in out boolean, onecol in boolean )
as

 cursor c1 is select distinct region from postal_charge;

 ftext_width	integer;

begin

  if voidrec.disp_cust = 'F' then return; end if;
  if onecol
   then
    ftext_width := (glbx.sctrl(pfx.theme_name,'PROOF_HORIZONTAL',stype) * 6) * 2;
   else
    ftext_width := glbx.sctrl(pfx.theme_name,'PROOF_HORIZONTAL',stype) * 6;
  end if;

  if newline
   then
    htp.nl;
   else
    newline := TRUE;
  end if;
  if voidrec.disp_cust_title is not null then htp.bold( voidrec.disp_cust_title ); htp.nl; end if;
  htp.tableopen( cattributes=>pfx.ord_cust_table );

  if voidrec.columns_simple_address = 'T' and browser_edit = 'BROWSE'
   then
    htp.tablerowopen;
     htp.p( '<TD ' || pfx.ord_cust_right || '>');
     htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0 width="100%"' );
      htp.tablerowopen;
       htp.tableheader( htf.bold(LNG5.EXT_TXT_590) );
       htp.tableheader( htf.bold(LNG5.EXT_TXT_591) );
       htp.tableheader( htf.bold(LNG5.EXT_TXT_592) );
      htp.tablerowclose;
      htp.tablerowopen( cattributes=>'valign="TOP"' );
       htp.p( '<TD>');
       htp.p( purchord.sendto_name ); htp.nl;
       if purchord.sendto_branch is not null
        then
         htp.p( purchord.sendto_branch ); htp.nl;
       end if;
       if purchord.sendto_department is not null
        then
         htp.p( purchord.sendto_department ); htp.nl;
       end if;
       htp.p( purchord.sendto_street || htf.nl || purchord.sendto_suburb || ' ' || purchord.sendto_city || ' ' ||
              purchord.sendto_state || ' ' || purchord.sendto_postcode || htf.nl || purchord.sendto_country);
       htp.p( '</TD>' );
       htp.p( '<TD>' );
       htp.p( nvl(purchord.billing_name,purchord.sendto_name) ); htp.nl;
       if nvl(purchord.billing_branch,purchord.sendto_branch) is not null
        then
         htp.p( nvl(purchord.billing_branch,purchord.sendto_branch) ); htp.nl;
       end if;
       if nvl(purchord.billing_department,purchord.sendto_department) is not null
        then
         htp.p( nvl(purchord.billing_department,purchord.sendto_department) ); htp.nl;
       end if;
       if nvl(purchord.billing_street,purchord.sendto_street) is not null
        then
         htp.p( nvl(purchord.billing_street,purchord.sendto_street) ); htp.nl;
       end if;
       if purchord.billing_suburb is null and purchord.billing_city is null
        then
         htp.p( purchord.sendto_suburb || ' ' || purchord.sendto_city || ' ' || purchord.sendto_state || ' ' || purchord.sendto_postcode);
        else
         htp.p( purchord.billing_gpo_box || ' ' || purchord.billing_suburb || ' ' || purchord.billing_city || ' ' || purchord.billing_state || ' ' || purchord.billing_postcode);
       end if;
       htp.nl;
       htp.p( nvl(purchord.billing_country,purchord.sendto_country) );
       htp.p( '</TD>' );
       htp.tabledata( htf.bold(voidrec.columns_phone) || ':' || nvl(purchord.billing_phone,purchord.contact_phone) || htf.nl ||
                      htf.bold(voidrec.columns_email) || ':' || nvl(purchord.billing_email,purchord.contact_email) || htf.nl ||
                      htf.bold(LNG5.EXT_TXT_621) || ':' || htf.nl || purchord.customer_comment || htf.nl ||
                      htf.anchor('fname.accept_acct_order?surl=' || surl || '&acid=' || acid || '&P0=&P1=&P2=&P3=&P6=&ACTION=E', LNG5.EXT_TXT_622));
      htp.tablerowclose;
     htp.tableclose;
     htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tableclose;
    return;
  end if;

  -- Name
  if nvl(substr(voidrec.columns_display,1,1),'T') = 'T'
   then
    if nvl(voidrec.columns_name_toggle,'T') = 'T'
     then
      htp.tablerowopen;
       htp.tabledata( format_name( voidrec.columns_name,1,voidrec), cattributes=>pfx.ord_cust_left);
       if browser_edit = 'EDIT'
        then
         htp.tabledata( htf.formhidden( 'P1', '6-NAME' ) || htf.formtext( 'P2', ftext_width, 100, purchord.sendto_name ), cattributes=>pfx.ord_cust_right);
       else
         htp.tabledata( nvl(purchord.sendto_name,'&nbsp;'), cattributes=>pfx.ord_cust_right);
       end if;
      htp.tablerowclose;
    else
      htp.tablerowopen;
       htp.tabledata( format_name( voidrec.columns_firstname,1,voidrec), cattributes=>pfx.ord_cust_left);
       if browser_edit = 'EDIT'
        then
         htp.tabledata( htf.formhidden( 'P1', '6-FIRSTNAME' ) || htf.formtext( 'P2', ftext_width, 100, purchord.sendto_firstname ), cattributes=>pfx.ord_cust_right);
       else
         htp.tabledata( nvl(purchord.sendto_firstname,'&nbsp;'), cattributes=>pfx.ord_cust_right);
       end if;
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( format_name( voidrec.columns_lastname,1,voidrec), cattributes=>pfx.ord_cust_left);
       if browser_edit = 'EDIT'
        then
         htp.tabledata( htf.formhidden( 'P1', '6-LASTNAME' ) || htf.formtext( 'P2', ftext_width, 100, purchord.sendto_lastname ), cattributes=>pfx.ord_cust_right);
       else
         htp.tabledata( nvl(purchord.sendto_lastname,'&nbsp;'), cattributes=>pfx.ord_cust_right);
       end if;
      htp.tablerowclose;
    end if;
  end if;

  -- Branch
  if nvl(substr(voidrec.columns_display,20,1),'T') = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_branch,20,voidrec), cattributes=>pfx.ord_cust_left);
      if browser_edit = 'EDIT'
       then
        htp.tabledata( htf.formhidden( 'P1', '6-BRANCH' ) || htf.formtext( 'P2', ftext_width, 100, purchord.sendto_branch ), cattributes=>pfx.ord_cust_right);
       else
        htp.tabledata( nvl(purchord.sendto_branch,'&nbsp;'), cattributes=>pfx.ord_cust_right);
      end if;
     htp.tablerowclose;
  end if;

  -- Department
  if nvl(substr(voidrec.columns_display,21,1),'T') = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_department,21,voidrec), cattributes=>pfx.ord_cust_left);
      if browser_edit = 'EDIT'
       then
        htp.tabledata( htf.formhidden( 'P1', '6-DEPARTMENT' ) || htf.formtext( 'P2', ftext_width, 100, purchord.sendto_department ), cattributes=>pfx.ord_cust_right);
       else
        htp.tabledata( nvl(purchord.sendto_department,'&nbsp;'), cattributes=>pfx.ord_cust_right);
      end if;
     htp.tablerowclose;
  end if;

  -- Street
  if nvl(substr(voidrec.columns_display,2,1),'T') = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_street,2,voidrec), cattributes=>pfx.ord_cust_left);
      if browser_edit = 'EDIT'
       then
        htp.tabledata( htf.formhidden( 'P1', '6-STREET' ) || htf.formtext( 'P2', ftext_width, 100, purchord.sendto_street ), cattributes=>pfx.ord_cust_right);
       else
        htp.tabledata( nvl(purchord.sendto_street,'&nbsp;'), cattributes=>pfx.ord_cust_right);
      end if;
     htp.tablerowclose;
  end if;

  -- Suburb
  if nvl(substr(voidrec.columns_display,3,1),'T') = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_suburb,3,voidrec), cattributes=>pfx.ord_cust_left);
      if browser_edit = 'EDIT'
       then

        htp.tabledata( htf.formhidden( 'P1', '6-SUBURB' ) || htf.formtext( 'P2', ftext_width, 100, purchord.sendto_suburb ), cattributes=>pfx.ord_cust_right);
       else
        htp.tabledata( nvl(purchord.sendto_suburb,'&nbsp;'), cattributes=>pfx.ord_cust_right);
      end if;
     htp.tablerowclose;
  end if;

  -- City
  if nvl(substr(voidrec.columns_display,4,1),'T') = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_city,4,voidrec), cattributes=>pfx.ord_cust_left);
      if browser_edit = 'EDIT'
       then

        htp.tabledata( htf.formhidden( 'P1', '6-CITY' ) || htf.formtext( 'P2', ftext_width, 100, purchord.sendto_city ), cattributes=>pfx.ord_cust_right);
       else
        htp.tabledata( nvl(purchord.sendto_city,'&nbsp;'), cattributes=>pfx.ord_cust_right);
      end if;
     htp.tablerowclose;
  end if;

  -- Postcode
  if nvl(substr(voidrec.columns_display,5,1),'T') = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_postcode,5,voidrec), cattributes=>pfx.ord_cust_left);
      if browser_edit = 'EDIT'
       then

        htp.tabledata( htf.formhidden( 'P1', '6-POSTCODE' ) || htf.formtext( 'P2', ftext_width, 100, purchord.sendto_postcode ), cattributes=>pfx.ord_cust_right);
       else
        htp.tabledata( nvl(purchord.sendto_postcode,'&nbsp;'), cattributes=>pfx.ord_cust_right);
      end if;
     htp.tablerowclose;
  end if;

  -- State
  if nvl(substr(voidrec.columns_display,17,1),'T') = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_state,17,voidrec), cattributes=>pfx.ord_cust_left);
      if browser_edit = 'EDIT'
       then

        htp.tabledata( htf.formhidden( 'P1', '6-STATE' ) || htf.formtext( 'P2', ftext_width, 100, purchord.sendto_state ), cattributes=>pfx.ord_cust_right);
       else
        htp.tabledata( nvl(purchord.sendto_state,'&nbsp;'), cattributes=>pfx.ord_cust_right);
      end if;
     htp.tablerowclose;
  end if;

  -- Country
  if nvl(substr(voidrec.columns_display,6,1),'T') = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_country,6,voidrec), cattributes=>pfx.ord_cust_left);
      if browser_edit = 'EDIT'
       then

        htp.p( '<TD ' || pfx.ord_cust_right || '>');
        htp.formhidden( 'P1', '6-COUNTRY' );
        htp.formselectopen( 'P2' );
        for c1rec in c1 loop
         if c1rec.region = nvl(purchord.sendto_country,voidrec.residing_country)
          then
           htp.formselectoption( c1rec.region, 'SELECTED' );
          else
           htp.formselectoption( c1rec.region );
         end if;
        end loop;
        htp.formselectclose;
        htp.p( '</TD>');
       else
        htp.tabledata( purchord.sendto_country, cattributes=>pfx.ord_cust_right);
      end if;
     htp.tablerowclose;
  end if;

  -- Phone
  if nvl(substr(voidrec.columns_display,7,1),'T') = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_phone,7,voidrec), cattributes=>pfx.ord_cust_left);
      if browser_edit = 'EDIT'
       then

        htp.tabledata( htf.formhidden( 'P1', '6-PHONE' ) || htf.formtext( 'P2', ftext_width, 100, purchord.contact_phone ), cattributes=>pfx.ord_cust_right);
       else
        htp.tabledata( nvl(purchord.contact_phone,'&nbsp;'), cattributes=>pfx.ord_cust_right);
      end if;
     htp.tablerowclose;
  end if;

  -- Email
  if nvl(substr(voidrec.columns_display,8,1),'T') = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_email,8,voidrec), cattributes=>pfx.ord_cust_left);
      if browser_edit = 'EDIT'
       then

        htp.tabledata( htf.formhidden( 'P1', '6-EMAIL' ) || htf.formtext( 'P2', greatest(ftext_width,8), 100, purchord.contact_email ), cattributes=>pfx.ord_cust_right);
       else
        htp.tabledata( nvl(purchord.contact_email,'&nbsp;'), cattributes=>pfx.ord_cust_right);
      end if;
     htp.tablerowclose;
  end if;

  -- User Defined 1
  if nvl(substr(voidrec.columns_display,11,1),'T') = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_cust_col1,11,voidrec), cattributes=>pfx.ord_cust_left);
      if browser_edit = 'EDIT'
       then

        htp.tabledata( htf.formhidden( 'P1', '6-CUSTOMER_COLUMN1' ) || htf.formtext( 'P2', ftext_width, 100, purchord.customer_column1 ), cattributes=>pfx.ord_cust_right);
       else
        htp.tabledata( nvl(purchord.customer_column1,'&nbsp;'), cattributes=>pfx.ord_cust_right);
      end if;
     htp.tablerowclose;
  end if;

  -- User Defined 2
  if nvl(substr(voidrec.columns_display,12,1),'T') = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_cust_col2,12,voidrec), cattributes=>pfx.ord_cust_left);
      if browser_edit = 'EDIT'
       then

        htp.tabledata( htf.formhidden( 'P1', '6-CUSTOMER_COLUMN2' ) || htf.formtext( 'P2', ftext_width, 100, purchord.customer_column2 ), cattributes=>pfx.ord_cust_right);
       else
        htp.tabledata( nvl(purchord.customer_column2,'&nbsp;'), cattributes=>pfx.ord_cust_right);
      end if;
     htp.tablerowclose;
  end if;

  -- User Defined 3
  if nvl(substr(voidrec.columns_display,13,1),'T') = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_cust_col3,13,voidrec), cattributes=>pfx.ord_cust_left);
      if browser_edit = 'EDIT'
       then

        htp.tabledata( htf.formhidden( 'P1', '6-CUSTOMER_COLUMN3' ) || htf.formtext( 'P2', ftext_width, 100, purchord.customer_column3 ), cattributes=>pfx.ord_cust_right);
       else
        htp.tabledata( nvl(purchord.customer_column3,'&nbsp;'), cattributes=>pfx.ord_cust_right);
      end if;
     htp.tablerowclose;
  end if;

  -- User Defined 4
  if nvl(substr(voidrec.columns_display,14,1),'T') = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_cust_col4,14,voidrec), cattributes=>pfx.ord_cust_left);
      if browser_edit = 'EDIT'
       then

        htp.tabledata( htf.formhidden( 'P1', '6-CUSTOMER_COLUMN4' ) || htf.formtext( 'P2', ftext_width, 100, purchord.customer_column4 ), cattributes=>pfx.ord_cust_right);
       else
        htp.tabledata( nvl(purchord.customer_column4,'&nbsp;'), cattributes=>pfx.ord_cust_right);
      end if;
     htp.tablerowclose;
  end if;

  -- User Defined 5
  if nvl(substr(voidrec.columns_display,15,1),'T') = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_cust_col5,15,voidrec), cattributes=>pfx.ord_cust_left);
      if browser_edit = 'EDIT'
       then

        htp.tabledata( htf.formhidden( 'P1', '6-CUSTOMER_COLUMN5' ) || htf.formtext( 'P2', ftext_width, 100, purchord.customer_column5 ), cattributes=>pfx.ord_cust_right);
       else
        htp.tabledata( nvl(purchord.customer_column5,'&nbsp;'), cattributes=>pfx.ord_cust_right);
      end if;
     htp.tablerowclose;
  end if;

  -- User Defined 6
  if nvl(substr(voidrec.columns_display,16,1),'T') = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_cust_col6,16,voidrec), cattributes=>pfx.ord_cust_left);
      if browser_edit = 'EDIT'
       then

        htp.tabledata( htf.formhidden( 'P1', '6-CUSTOMER_COLUMN6' ) || htf.formtext( 'P2', ftext_width, 100, purchord.customer_column6 ), cattributes=>pfx.ord_cust_right);
       else
        htp.tabledata( nvl(purchord.customer_column6,'&nbsp;'), cattributes=>pfx.ord_cust_right);
      end if;
     htp.tablerowclose;
  end if;

  htp.tableclose;

  if browser_edit = 'BROWSE'
   then
    htp.anchor( 'fname.accept_acct_order?surl=' || surl || '&acid=' || acid || '&P0=&P1=&P2=&P3=&P6=&ACTION=E', 'Go Back and Edit Contact Details', cattributes=>'color: #' || pfx.instruct_text_colour || '"' );
  end if;

end disp_cust_details;

procedure disp_shipping(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, browser_edit in varchar2, newline in out boolean )
as

 cursor c1 is select distinct region from postal_charge;

 ftext_width	integer;

begin

  if voidrec.disp_shipping = 'F' then return; end if;
  ftext_width := glbx.sctrl(pfx.theme_name,'PROOF_HORIZONTAL',stype) * 6;

  if newline
   then
    htp.nl;
   else
    newline := TRUE;
  end if;

  if voidrec.disp_shipping_title is not null then htp.bold( voidrec.disp_shipping_title ); htp.nl; end if;
  htp.tableopen( cattributes=>pfx.ord_deliv_table );
  -- Split Order
  if nvl(substr(voidrec.columns_display,10,1),'T') = 'T' and browser_edit = 'EDIT'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_split,10,voidrec), cattributes=>pfx.ord_deliv_left);
      if purchord.do_not_split_order = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-DO_NOT_SPLIT_ORDER', 'CHECKED' ), cattributes=>pfx.ord_deliv_right);
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-DO_NOT_SPLIT_ORDER' ), cattributes=>pfx.ord_deliv_right);
      end if;
     htp.tablerowclose;
  end if;

  -- Offer Express Postage
  if browser_edit = 'EDIT' and
     voidrec.pricing_postage_included = 'F' and
     voidrec.pricing_express_included = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( htf.formhidden( 'P1', '6-POSTAGE' ) || voidrec.pricing_postage_text, cattributes=>pfx.ord_deliv_left);

      htp.p( '<TD ' || pfx.ord_deliv_right || '>');
       htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
        htp.tablerowopen;
         if nvl(purchord.delivery_type,'S') = 'S'
          then
           htp.tabledata( htf.formradio( 'P2', 'S', 'CHECKED' ) );
          else
           htp.tabledata( htf.formradio( 'P2', 'S' ) );
         end if;
         htp.tabledata( voidrec.pricing_postage_text_col );
         htp.tabledata( voidrec.text_local_charge  );
         htp.tabledata( to_char( nvl(voidrec.pricing_ship_local,0), LNG.MONEY_FORMAT ) );
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( '&nbsp;' );
         htp.tabledata( '&nbsp;' );
         htp.tabledata( voidrec.text_international_charge  );
         htp.tabledata( to_char( nvl(voidrec.pricing_ship_int,0), LNG.MONEY_FORMAT ) );
        htp.tablerowclose;

        htp.tablerowopen;
        if purchord.delivery_type = 'X'
         then
          htp.tabledata( htf.formradio( 'P2', 'X', 'CHECKED' ) );
         else
          htp.tabledata( htf.formradio( 'P2', 'X' ) );
        end if;
         htp.tabledata( voidrec.pricing_express_text_col );
         htp.tabledata( voidrec.text_local_charge );
         htp.tabledata( to_char( nvl(voidrec.pricing_expr_local,0), LNG.MONEY_FORMAT ) );
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( '&nbsp;' );
         htp.tabledata( '&nbsp;' );
         htp.tabledata( voidrec.text_international_charge  );
         htp.tabledata( to_char( nvl(voidrec.pricing_expr_int,0), LNG.MONEY_FORMAT ) );
        htp.tablerowclose;

       htp.tableclose;
      htp.p( '</TD>' );
     htp.tablerowclose;

  elsif browser_edit = 'EDIT' and
        voidrec.pricing_postage_included = 'F' and
        voidrec.pricing_express_included = 'F'
   then
     htp.tablerowopen;
      htp.tabledata( voidrec.pricing_postage_text, cattributes=>pfx.ord_deliv_left);
      htp.p( '<TD ' || pfx.ord_deliv_right || '>');
       htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
         htp.tabledata( 'Standard' || '-' );
         htp.tabledata( voidrec.text_local_charge  );
         htp.tabledata( to_char( nvl(voidrec.pricing_ship_local,0), LNG.MONEY_FORMAT ) );
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( '&nbsp;' );
         htp.tabledata( voidrec.text_international_charge  );
         htp.tabledata( to_char( nvl(voidrec.pricing_ship_int,0), LNG.MONEY_FORMAT ) );
        htp.tablerowclose;
       htp.tableclose;
      htp.p( '</TD>' );
     htp.tablerowclose;

  elsif browser_edit = 'BROWSE'
   then
    if nvl(substr(voidrec.columns_display,10,1),'T') = 'T'
     then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_split,10,voidrec), cattributes=>pfx.ord_deliv_left);
      htp.tabledata( LNG.PHG_TXT_045, cattributes=>pfx.ord_deliv_right);
     htp.tablerowclose;
     if voidrec.pricing_offer_manual_ship = 'T'
      then
       htp.tablerowopen;
        htp.tabledata( voidrec.text_manual_ship, cattributes=>pfx.ord_deliv_left);
        if purchord.manual_ship = 'T'
         then
          htp.tabledata( LNG.PHG_TXT_045, cattributes=>pfx.ord_deliv_right);
         else
          htp.tabledata( LNG.PHG_TXT_046, cattributes=>pfx.ord_deliv_right);
        end if;
       htp.tablerowclose;
     end if;
     if nvl(purchord.delivery_type,'S') = 'S'
      then
       htp.tablerowopen;
        htp.tabledata( voidrec.pricing_postage_text_col, cattributes=>pfx.ord_deliv_left);
        htp.tabledata( to_char( nvl(purchord.delivery_cost,0), LNG.MONEY_FORMAT ), cattributes=>pfx.ord_deliv_right);
       htp.tablerowclose;
      else
       htp.tablerowopen;
        htp.tabledata( voidrec.pricing_express_text_col, cattributes=>pfx.ord_deliv_left);
        htp.tabledata( to_char( nvl(purchord.delivery_cost,0), LNG.MONEY_FORMAT ), cattributes=>pfx.ord_deliv_right);
       htp.tablerowclose;
     end if;
    end if;
  end if;

  -- Manual Shipping Offer

  if voidrec.pricing_offer_manual_ship = 'T' and browser_edit = 'EDIT'
   then
     htp.tablerowopen;
      htp.tabledata( voidrec.text_manual_ship, cattributes=>pfx.ord_deliv_left);
      if purchord.manual_ship = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P3', '6-MANUAL_SHIP', 'CHECKED' ), cattributes=>pfx.ord_deliv_right);
       else
        htp.tabledata( htf.formcheckbox( 'P3', '6-MANUAL_SHIP' ), cattributes=>pfx.ord_deliv_right);
      end if;
     htp.tablerowclose;
  end if;

  -- Customer Comment
  if nvl(substr(voidrec.columns_display,9,1),'T') = 'T'
   then
     htp.tablerowopen;
      htp.tabledata( format_name( voidrec.columns_comment,9,voidrec), cattributes=>pfx.ord_deliv_left);
      if browser_edit = 'EDIT'
       then
        htp.tabledata( htf.formhidden( 'P1', '6-CUSTOMER_COMMENT' ) || htf.formtextareaopen( 'P2', 3, greatest(ftext_width,8), cattributes=>'WRAP="VIRTUAL"' ) || purchord.customer_comment || htf.formtextareaclose, cattributes=>pfx.ord_deliv_right);
       else
        htp.tabledata( nvl(purchord.customer_comment,'&nbsp;'), cattributes=>pfx.ord_deliv_right);
      end if;
     htp.tablerowclose;
  end if;

  htp.tableclose;

end disp_shipping;

procedure disp_postage_details(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, browser_edit in varchar2, newline in out boolean )
as

additional_options number;
surcharge	number;
gst		number;
postage		number;
discount	number;
txt		varchar2(1000);

begin
  if voidrec.disp_postage = 'F' then return; end if;

  glbx.purchase_each_cost( purchord, additional_options, surcharge, gst, postage, discount );

  if newline
   then
    htp.nl;
   else
    newline := TRUE;
  end if;

  if voidrec.disp_postage_title is not null then htp.bold( voidrec.disp_postage_title ); htp.nl; end if;
  htp.tableopen( cattributes=>pfx.ord_deliv_table );
   htp.tablerowopen;
    htp.tabledata( htf.bold( voidrec.pricing_postage_text ), cattributes=>'colspan="2" ' || pfx.ord_deliv_left);
   htp.tablerowclose;

   if voidrec.pricing_postage_included = 'F'
    then
     if purchord.delivery_type = 'S'
      then
       txt := voidrec.pricing_postage_text_col;
      else
       txt := voidrec.pricing_express_text_col;
     end if;

     if purchord.local_internation = 'LOCAL'
      then
       txt := txt || '-' || voidrec.text_local_charge ;
      else
       txt := txt || '-' || voidrec.text_international_charge ;
     end if;

     htp.tablerowopen;
      htp.tabledata( htf.bold( txt ), cattributes=>pfx.ord_deliv_left);
      htp.tabledata( to_char(postage, LNG.MONEY_FORMAT), cattributes=>pfx.ord_deliv_right);
     htp.tablerowclose;

     if nvl(surcharge,0) > 0
      then
       htp.tablerowopen;
        htp.tabledata( htf.bold( voidrec.pricing_surcharge_text ), cattributes=>pfx.ord_deliv_left);
        htp.tabledata( to_char(surcharge, LNG.MONEY_FORMAT), cattributes=>pfx.ord_deliv_right);
       htp.tablerowclose;
     end if;

     if purchord.do_not_split_order = 'T'
      then
       htp.tablerowopen;
        htp.tabledata( htf.bold( LNG4.AHC_TXT_772 ), cattributes=>pfx.ord_deliv_left);
        if purchord.do_not_split_order = 'T'
         then
          htp.tabledata( LNG.PHG_TXT_045, cattributes=>pfx.ord_deliv_right);
         else
          htp.tabledata( LNG.PHG_TXT_046, cattributes=>pfx.ord_deliv_right);
        end if;
       htp.tablerowclose;
     end if;

   end if;

  htp.tableclose;

end disp_postage_details;

procedure disp_order_total_details(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, browser_edit in varchar2, newline in out boolean )
as

cursor c1( cntry varchar2 ) is select three_char_reference from postal_charge where region = cntry;

c1rec		c1%ROWTYPE;
tot		number;
additional_options number;
surcharge	number;
gst		number;
postage		number;
discount	number;
gst_value	number;
discounts	number;
cert_total	number;
gtotal		number;
grand_ttl	number;
grand_nogft	number;

begin

 if voidrec.disp_total = 'F' then return; end if;

 tot := glbx.total_payment(purchord.poid);

 glbx.purchase_each_cost( purchord, additional_options, surcharge, gst, postage, discount );
 glbx.extract_grand_total_payment( purchord.poid, gst_value, discounts, cert_total, gtotal, FALSE );

 grand_nogft := glbx.grand_total_payment( purchord.poid, FALSE );
 grand_ttl := glbx.grand_total_payment( purchord.poid, TRUE );

  if newline
   then
    htp.nl;
   else
    newline := TRUE;
  end if;
  if voidrec.disp_total_title is not null then htp.bold( voidrec.disp_total_title ); htp.nl; end if;
  htp.tableopen( cattributes=>pfx.ord_cost_table );

    -- Sub Total
    htp.tablerowopen;
     htp.tabledata( htf.bold( voidrec.text_subtotal ), cattributes=>pfx.ord_cost_left);
     htp.tabledata( to_char( nvl(tot,0), LNG.MONEY_FORMAT ), cattributes=>pfx.ord_cost_right);
    htp.tablerowclose;

    -- Discount at Sub Total Stage
    if purchord.apply_discount_at = 'S' and nvl(discount,0) > 0
     then
      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG5.EXT_TXT_382 ), cattributes=>pfx.ord_cost_left);
       htp.tabledata( trim(to_char(discounts,LNG.MONEY_FORMAT)) || '(' || to_char( nvl(discount,0) ) || '%)', cattributes=>pfx.ord_cost_right);
      htp.tablerowclose;
    end if;

    -- Purchase Options
    if nvl(additional_options,0) > 0
     then
      htp.tablerowopen;
       htp.tabledata( htf.bold( voidrec.disp_gift_wrap_title ), cattributes=>pfx.ord_cost_left);
       htp.tabledata( to_char( additional_options , LNG.MONEY_FORMAT), cattributes=>pfx.ord_cost_right);
      htp.tablerowclose;
    end if;

    if voidrec.disp_sep_post_surcharge = 'F'
     then
      if (voidrec.pricing_postage_included = 'F') or (voidrec.pricing_postage_included = 'T' and (nvl(postage,0) + nvl(surcharge,0)) > 0)
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold( voidrec.pricing_postage_text ), cattributes=>pfx.ord_cost_left);
         htp.tabledata( to_char( nvl(postage,0) + nvl(surcharge,0), LNG.MONEY_FORMAT ), cattributes=>pfx.ord_cost_right);
        htp.tablerowclose;
      end if;
     else
      if (voidrec.pricing_postage_included = 'F') or (voidrec.pricing_postage_included = 'T' and nvl(postage,0) > 0)
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold( voidrec.pricing_postage_text ), cattributes=>pfx.ord_cost_left);
         htp.tabledata( to_char( nvl(postage,0), LNG.MONEY_FORMAT ), cattributes=>pfx.ord_cost_right);
        htp.tablerowclose;
      end if;
      if (voidrec.pricing_postage_included = 'F') or (voidrec.pricing_postage_included = 'T' and nvl(surcharge,0) > 0)
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold( voidrec.text_surcharge ), cattributes=>pfx.ord_cost_left);
         htp.tabledata( to_char( nvl(surcharge,0), LNG.MONEY_FORMAT ), cattributes=>pfx.ord_cost_right);
        htp.tablerowclose;
      end if;
    end if;


    -- Discount at Postage
    if purchord.apply_discount_at = 'P' and nvl(discount,0) > 0
     then
      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG5.EXT_TXT_382 ), cattributes=>pfx.ord_cost_left);
       htp.tabledata( trim(to_char(discounts,LNG.MONEY_FORMAT)) || '(' || to_char( nvl(discount,0) ) || '%)', cattributes=>pfx.ord_cost_right);
      htp.tablerowclose;
    end if;

    -- Tax (display here if GST Inclusive
    if nvl(gst,0) > 0 and voidrec.pricing_gst_inclusive = 'F'
     then
      htp.tablerowopen;
       htp.tabledata( htf.bold( voidrec.pricing_gst_text ), cattributes=>pfx.ord_cost_left);
       htp.tabledata( '(' || to_char( gst ) || '%) ' || trim(to_char(gst_value,LNG.MONEY_FORMAT)), cattributes=>pfx.ord_cost_right);
      htp.tablerowclose;
    end if;

    -- Discount at Final Stage
    if purchord.apply_discount_at = 'F' and nvl(discount,0) > 0
     then
      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG5.EXT_TXT_382 ), cattributes=>pfx.ord_cost_left);
       htp.tabledata( '(' || to_char( nvl(discount,0) ) || '%) ' || trim(to_char(discounts,LNG.MONEY_FORMAT)), cattributes=>pfx.ord_cost_right);
      htp.tablerowclose;
    end if;

    -- Gift Certificate
    if nvl(grand_ttl,0) <> nvl(grand_nogft,0)
     then
      htp.tablerowopen;
       htp.tabledata( htf.bold( '(' || LNG5.EXT_TXT_279 || ')' ), cattributes=>pfx.ord_cost_left);
       htp.tabledata( to_char( round(nvl(grand_nogft,0) - nvl(grand_ttl,0),2), LNG.MONEY_FORMAT), cattributes=>pfx.ord_cost_right);
      htp.tablerowclose;
    end if;

    -- Grand Total
    htp.tablerowopen;
     htp.tabledata( htf.bold( voidrec.text_grandtotal ), cattributes=>pfx.ord_cost_left);
     htp.p( '<TD ' || pfx.ord_cost_right || '>' );
      if voidrec.disp_show_currency = 'T'
       then
        htp.bold( to_char( grand_ttl, LNG.MONEY_FORMAT ) || ' (' || get_currency(voidrec.currency_to_use) || ')' );
       else
        htp.bold( to_char( grand_ttl, LNG.MONEY_FORMAT ));
      end if;
      if voidrec.disp_show_convert = 'T'
       then
        htp.nl;
        open c1(voidrec.residing_country);
        fetch c1 into c1rec;
        close c1;
        if c1rec.three_char_reference is null
         then
          htp.p('<A HREF="javascript: window.open(''' || replace( glbx.extract_master_parameter('MERCHANT_PRICE'), 'PICTION_AMT', trim(to_char( grand_ttl, '999999999.99' ))) || ''',''currency_calculator'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=600,height=170'');void('''');">' || htf.italic(LNG.ORD_TXT_228) || '</A>' );
         else
          htp.p('<A HREF="javascript: window.open(''' || replace(replace( glbx.extract_master_parameter('MERCHANT_PRICE_XREF'), 'PICTION_AMT', trim(to_char( grand_ttl, '999999999.99' ))),'PICTION_REF',c1rec.three_char_reference) || ''',''currency_calculator'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=600,height=170'');void('''');">' || htf.italic(LNG.ORD_TXT_228) || '</A>' );
        end if;
      end if;
     htp.p( '</TD>' );
   htp.tablerowclose;

   -- Tax (display here if GST Inclusive
   if nvl(gst,0) > 0 and voidrec.pricing_gst_inclusive = 'T'
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold( voidrec.pricing_gst_text ), cattributes=>pfx.ord_cost_left);
      htp.tabledata( '(' || to_char( gst ) || '%) ' || trim(to_char(gst_value,LNG.MONEY_FORMAT)), cattributes=>pfx.ord_cost_right);
     htp.tablerowclose;
   end if;

  htp.tableclose;

end disp_order_total_details;

procedure disp_payment_method(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, browser_edit in varchar2, newline in out boolean )
as
begin
  if voidrec.disp_payment_method = 'F' then return; end if;

  if newline
   then
    htp.nl;
   else
    newline := TRUE;
  end if;
  if voidrec.disp_payment_method_title is not null then htp.bold( voidrec.disp_payment_method_title ); htp.nl; end if;
   htp.tableopen( cattributes=>pfx.ord_paym_table );
   show_gift_facility(surl, acid, profid, purchord, voidrec, ltype, FALSE, pfx );
   show_cc_facility(surl, acid, profid, purchord, voidrec, ltype, FALSE, pfx );
   if voidrec.payment_cc_separate_display = 'T'
    then
     htp.tableclose;
     htp.nl;
     htp.p( pfx.ord_bank_divider );
     htp.nl;
     htp.tableopen( cattributes=>pfx.ord_paym_table );
   end if;
   show_billing_facility(surl, acid, profid, purchord, voidrec, ltype, FALSE, pfx );
   show_auth_facility(surl, acid, profid, purchord, voidrec, ltype, FALSE, pfx );
   show_cheque_facility(surl, acid, profid, purchord, voidrec, ltype, FALSE, pfx );
   show_phone_facility(surl, acid, profid, purchord, voidrec, ltype, FALSE, pfx );
   show_free_images(surl, acid, profid, purchord, cusrec, voidrec, ltype, FALSE, pfx );
   show_problems_facility(surl, acid, profid, purchord, voidrec, ltype, pfx );
  htp.tableclose;
end disp_payment_method;

procedure show_cc_facility( surl in varchar2, acid in integer, profid in integer, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, ltype in varchar2, isproblem in boolean, pfx in theme%rowtype )
as

 cursor c1( ploc varchar2 ) is select return_key from merchant_centralised_return where piction_location = ploc;

 cursor c3(phgid integer) is
   select payment_type, cc_mastercard,cc_visa,cc_bankcard,cc_amex,cc_diners,phgid pid
   from charge_plan cp, photographer p
   where cp.id = p.plan_id and pid=phgid;

cursor c4(phgid integer) is select business_name from photographer where pid = phgid;

 c1rec	        c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 mtype		merchant_type;
 chelp		varchar2(2000);
 tmp		varchar2(1000);
 secpage	varchar2(200);
 pp		varchar2(200);
 txt		varchar2(1000);
 ttl		number;
 cnts		number;

begin
 if voidrec.payment_cc = 'F' then return; end if;
 if glbx.extract_master_parameter('ENABLE_ALL_MERCHANT') = 'FALSE' then return; end if;

 mtype := merchant_details(purch.pid);
 chelp := glbx.extract_master_parameter('CREDIT_HELP_PAGE');
 if chelp is not null
  then
   chelp := htf.anchor2( chelp, htf.img( DECS.IMAGE_LOCATION || 'adminc/help_how.gif',cattributes=>'border=0'), ctarget=>'CREDIT_HELP');
 end if;
 htp.tablerowopen;
 if isproblem then txt := htf.bold( LNG4.AHC_TXT_852 ) || ':'; end if;

 open c4(purch.pid);
 fetch c4 into c4rec;
 close c4;

 if ((mtype.merchant_provider = 'SAFEPAY') and (mtype.popup = 'TRUE')) or
    ((mtype.merchant_provider = 'ESEC') and (mtype.popup = 'TRUE'))
  then
   if mtype.merchant_provider = 'ESEC'
      then
       htp.tabledata(chelp || htf.anchor2( 'fname.goto_pay_merchant?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/ord_esec.gif',cattributes=>'border=0'),ctarget=>'MERCHANT_PAGE'), cattributes=>pfx.ord_paym_left);
     else
       htp.tabledata(chelp || htf.anchor2( 'fname.goto_pay_merchant?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/ord_merch.gif',cattributes=>'border=0'),ctarget=>'MERCHANT_PAGE'), cattributes=>pfx.ord_paym_left);
   end if;
   if voidrec.payment_display_all_as_butt = 'T'
     then
      if voidrec.payment_display_style = '2'
       then
        htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
      end if;
      htp.p( '<TD ' || pfx.ord_paym_right2 || '>' );
      if txt is not null
       then
        htp.p( txt ); htp.nl;
      end if;
      htp.formopen( 'fname.goto_pay_merchant', ctarget=>'MERCHANT_PAGE' );
        htp.formhidden( 'SURL', surl );
        htp.formhidden( 'ACID', acid );
        htp.formsubmit( null, voidrec.text_cc_message );
      htp.formclose;
      htp.p( '</TD>' );
      if voidrec.payment_display_style = '1'
       then
        htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
      end if;
     else
      htp.tabledata( txt || htf.anchor2( 'fname.goto_pay_merchant?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,voidrec.text_cc_message,ctarget=>'MERCHANT_PAGE') || htf.nl || voidrec.text_cc_message, cattributes=>pfx.ord_paym_right2);
  end if;

 elsif mtype.merchant_provider = 'ANZ'
  then
   if voidrec.payment_display_gif = 'T' then htp.tabledata(chelp || htf.img( DECS.IMAGE_LOCATION || 'adminc/ord_merch.gif',cattributes=>'border=0'), cattributes=>pfx.ord_paym_right); end if;
   if voidrec.payment_display_style = '2'
     then
       htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
   end if;
   htp.p( '<TD ' || pfx.ord_paym_right2 || '>' );
   htp.p( txt );
   if mtype.nobutton_page = 'TRUE'
    then
     if voidrec.payment_display_all_as_butt = 'T'
      then
       htp.formopen( 'fname.merchant_goto', cattributes=>'onsubmit="javascript: window.open('''',''MERCHANT_WINDOW'',''top=100,left=100,width=400,height=300,location=no,toolbar=no,resizable=yes,menubar=no,scrollbars=yes,status=no''); this.target=''MERCHANT_WINDOW'';"' );
       htp.formhidden( 'SURL', surl );
       htp.formhidden( 'ACID', acid );
       htp.formsubmit( null, voidrec.text_cc_message );
       htp.formclose;
      else
       htp.p( '<A HREF="javascript: window.open(''fname.merchant_goto?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=400,height=300'');void('''');">' ||
              voidrec.payment_cc_text || '</A>');
     end if;
    else
     if mtype.popup = 'TRUE'
      then
       htp.formopen( mtype.merchant_url, ctarget=>'MERCHANT_PAGE' );
      else
       htp.formopen( mtype.merchant_url );
     end if;

     begin
      ttl:= glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE ) * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1);
     exception
      when others then
      ttl := glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE );
     end;
     -- cnts := lpad(to_char(mod(ttl,1)*100),2,'0');

     htp.formhidden( 'CLIENTID', mtype.merchant_id );
     htp.formhidden( 'MERCHANTNAME', glbx.extract_master_parameter('PAGE_TITLE') );
     htp.formhidden( 'AMOUNTDOLLAR', trim(to_char(trunc(ttl),'999999999')) );
     htp.formhidden( 'AMOUNTCENT', trim(to_char(mod(ttl,1)*100,'00')) );
     htp.formhidden( 'CURRENCYCODE', nvl( get_currency( voidrec.currency_to_use), 'AUD') );
     htp.formhidden( 'ORDERNUMBER', to_char(purch.poid));
     htp.formhidden( 'ORDERDESCRIPTION', c4rec.business_name || '(' || to_char(purch.poid) || ')');
     htp.formhidden( 'NAME', purch.sendto_name );
     htp.formhidden( 'CARDS', '4' ); -- 4 is display all credit card icons (Master Card, Visa, Bancard to Amex to Diners)
     htp.formhidden( 'POSTBACK', null ); -- send information back as GET command (needed because of successurl)
     htp.formhidden( 'NORELOAD', '1' );
     htp.formhidden( 'EMAIL', glbx.extract_master_parameter('PICTION_EMAIL_ACCT') );
     if trim(owa_util.get_cgi_env( 'SERVER_PORT' )) = '80'
      then
       htp.formhidden( 'SUCCESSURL', mtype.merchant_returl || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_anz?wrk=T&surl=' || glbx.rndsurl(surl) );
       htp.formhidden( 'FAILURL', mtype.merchant_returl || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_anz?wrk=F&surl=' || glbx.rndsurl(surl) );
      else
       htp.formhidden( 'SUCCESSURL', mtype.merchant_returl || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_anz?wrk=T&surl=' || glbx.rndsurl(surl) );
       htp.formhidden( 'FAILURL', mtype.merchant_returl || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_anz?wrk=F&surl=' || glbx.rndsurl(surl) );
     end if;
     htp.formsubmit( null, voidrec.text_cc_message );
     htp.formclose;
   end if;
   htp.p( '</TD>' );
   if voidrec.payment_display_style = '1'
     then
       htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
   end if;

 elsif mtype.merchant_provider = 'ANZ-II'
  then
   if voidrec.payment_display_gif = 'T' then htp.tabledata(chelp || htf.img( DECS.IMAGE_LOCATION || 'adminc/anzegate.gif',cattributes=>'border=0'),cattributes=>pfx.ord_paym_left); end if;
   if voidrec.payment_display_style = '2'
     then
       htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
   end if;
   htp.p( '<TD ' || pfx.ord_paym_right2 || '>' );
   htp.p( txt );
   -- http://www.imagelab.co.nz:8080/pxaccess.asp
   if mtype.nobutton_page = 'TRUE'
    then
     if voidrec.payment_display_all_as_butt = 'T'
      then
       htp.formopen( 'fname.merchant_goto', cattributes=>'onsubmit="javascript: window.open('''',''MERCHANT_WINDOW'',''top=100,left=100,width=400,height=300,location=no,toolbar=no,resizable=yes,menubar=no,scrollbars=yes,status=no''); this.target=''MERCHANT_WINDOW'';"' );
       htp.formhidden( 'SURL', surl );
       htp.formhidden( 'ACID', acid );
       htp.formsubmit( null, voidrec.text_cc_message );
       htp.formclose;
      else
       htp.p( '<A HREF="javascript: window.open(''fname.merchant_goto?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=400,height=300'');void('''');">' ||
              voidrec.payment_cc_text || '</A>');
     end if;
    else
     if mtype.popup = 'TRUE'
      then
       htp.formopen( mtype.merchant_url, ctarget=>'MERCHANT_PAGE' );
      else
       htp.formopen( mtype.merchant_url );
     end if;
     begin
      cnts := to_number(glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE ))*100 * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1);
     exception
     when others then
       cnts := to_number(glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE ))*100;
     end;
     htp.formhidden( 'MERCHANTID', mtype.merchant_id );
     htp.formhidden( 'MERCHANTTXNREF', to_char(purch.poid));
     htp.formhidden( 'ORDERINFO', SURL);
     htp.formhidden( 'LOCALE', 'en');
     htp.formhidden( 'PURCHASEAMOUNT', trim(to_char(cnts)) );
     htp.formhidden( 'RETURNURL', mtype.merchant_returl );
     htp.formsubmit( null, voidrec.text_cc_message );
     htp.formclose;
   end if;
   htp.p( '</TD>' );
   if voidrec.payment_display_style = '1'
     then
       htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
   end if;

 elsif mtype.merchant_provider = 'CBANK'
  then
   if voidrec.payment_display_gif = 'T' then htp.tabledata(chelp || htf.img( DECS.IMAGE_LOCATION || 'adminc/ord_merch.gif',cattributes=>'border=0'), cattributes=>pfx.ord_paym_right); end if;
   if voidrec.payment_display_style = '2'
     then
       htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
   end if;
   htp.p( '<TD ' || pfx.ord_paym_right2 || '>' );
   htp.p( txt );
   if mtype.nobutton_page = 'TRUE'
    then
     if voidrec.payment_display_all_as_butt = 'T'
      then
       htp.formopen( 'fname.merchant_goto', cattributes=>'onsubmit="javascript: window.open('''',''MERCHANT_WINDOW'',''top=100,left=100,width=400,height=300,location=no,toolbar=no,resizable=yes,menubar=no,scrollbars=yes,status=no''); this.target=''MERCHANT_WINDOW'';"' );
       htp.formhidden( 'SURL', surl );
       htp.formhidden( 'ACID', acid );
       htp.formsubmit( null, voidrec.text_cc_message );
       htp.formclose;
      else
       htp.p( '<A HREF="javascript: window.open(''fname.merchant_goto?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=400,height=300'');void('''');">' ||
              voidrec.payment_cc_text || '</A>');
     end if;
    else
     if mtype.popup = 'TRUE'
      then
       htp.formopen( mtype.merchant_url, ctarget=>'MERCHANT_PAGE' );
      else
       htp.formopen( mtype.merchant_url );
     end if;
     begin
      cnts := glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE ) * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1);
     exception
      when others then
       cnts := glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE );
     end;
     htp.formhidden( 'MERCHID', mtype.merchant_id );
     htp.formhidden( 'AMT', trim(to_char(cnts,'999999999.99')) );
     htp.formhidden( 'MTID', to_char(purch.poid));
     htp.formhidden( 'CURR', nvl( get_currency( voidrec.currency_to_use), 'AUD') );
     if trim(owa_util.get_cgi_env( 'SERVER_PORT' )) = '80'
      then
       htp.formhidden( 'SUCCESSURL', mtype.merchant_returl || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_cbank?wrk=T&surl=' || glbx.rndsurl(surl) ||'&responseText=#M#&authorisationCode=#C#&invoiceNumber=#R#&amountPaid=#A#&transactionRef=#I#&surname=#A#' );
       htp.formhidden( 'FAILURL', mtype.merchant_returl || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_cbank?wrk=F&surl=' || glbx.rndsurl(surl) ||'&responseText=#M#&authorisationCode=#C#&invoiceNumber=#R#&amountPaid=#A#&transactionRef=#I#&surname=#A#' );
      else
       htp.formhidden( 'SUCCESSURL', mtype.merchant_returl || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_cbank?wrk=T&surl=' || glbx.rndsurl(surl) ||'&responseText=#M#&authorisationCode=#C#&invoiceNumber=#R#&amountPaid=#A#&transactionRef=#I#&surname=#A#' );
       htp.formhidden( 'FAILURL', mtype.merchant_returl || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_cbank?wrk=F&surl=' || glbx.rndsurl(surl) ||'&responseText=#M#&authorisationCode=#C#&invoiceNumber=#R#&amountPaid=#A#&transactionRef=#I#&surname=#A#' );
     end if;
     htp.formsubmit( null, voidrec.text_cc_message );
     htp.formclose;
   end if;
   htp.p( '</TD>' );
   if voidrec.payment_display_style = '1'
     then
       htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
   end if;

 elsif mtype.merchant_provider = 'NAB'
  then
   if voidrec.payment_display_gif = 'T' then htp.tabledata(chelp || htf.img( DECS.IMAGE_LOCATION || 'adminc/ord_nab.gif',cattributes=>'border=0'),cattributes=>pfx.ord_paym_left); end if;
   if voidrec.payment_display_style = '2'
     then
       htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
   end if;
   htp.p( '<TD ' || pfx.ord_paym_right2 || '>' );
   htp.p( txt );
   if mtype.nobutton_page = 'TRUE'
    then
     if voidrec.payment_display_all_as_butt = 'T'
      then
       htp.formopen( 'fname.merchant_goto', cattributes=>'onsubmit="javascript: window.open('''',''MERCHANT_WINDOW'',''top=100,left=100,width=400,height=300,location=no,toolbar=no,resizable=yes,menubar=no,scrollbars=yes,status=no''); this.target=''MERCHANT_WINDOW'';"' );
       htp.formhidden( 'SURL', surl );
       htp.formhidden( 'ACID', acid );
       htp.formsubmit( null, voidrec.text_cc_message );
       htp.formclose;
      else
       htp.p( '<A HREF="javascript: window.open(''fname.merchant_goto?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=400,height=300'');void('''');">' ||
              voidrec.payment_cc_text || '</A>');
     end if;
    else
     if mtype.popup = 'TRUE'
      then
       htp.formopen( mtype.merchant_url, ctarget=>'MERCHANT_PAGE' );
      else
       htp.formopen( mtype.merchant_url );
     end if;
     htp.formhidden( 'MERCHID', mtype.merchant_id );
     begin
      cnts := glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE ) * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1);
     exception
     when others then
       cnts := glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE );
     end;
     htp.formhidden( 'AMT', trim(to_char(cnts,'999999999.99')) );
     htp.formhidden( 'MTID', to_char(purch.poid));
     htp.formhidden( 'NAME', substr(nvl(purch.billing_name,purch.sendto_name),1,30) );
     htp.formhidden( 'EMAIL', substr(purch.contact_email,1,64));
     if trim(owa_util.get_cgi_env( 'SERVER_PORT' )) = '80'
      then
       htp.formhidden( 'SUCCESSURL', mtype.merchant_returl || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_nab?wrk=T&surl=' || glbx.rndsurl(surl) ||'&responseText=#M#&authorisationCode=#C#&invoiceNumber=#R#&amountPaid=#A#&transactionRef=#I#&surname=#N#&currency=#U#' );
       htp.formhidden( 'FAILURL', mtype.merchant_returl || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_nab?wrk=F&surl=' || glbx.rndsurl(surl) ||'&responseText=#M#&authorisationCode=#C#&invoiceNumber=#R#&amountPaid=#A#&transactionRef=#I#&surname=#N#&currency=#U#' );
      else
       htp.formhidden( 'SUCCESSURL', mtype.merchant_returl || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_nab?wrk=T&surl=' || glbx.rndsurl(surl) ||'&responseText=#M#&authorisationCode=#C#&invoiceNumber=#R#&amountPaid=#A#&transactionRef=#I#&surname=#N#&currency=#U#' );
       htp.formhidden( 'FAILURL', mtype.merchant_returl || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_nab?wrk=F&surl=' || glbx.rndsurl(surl) ||'&responseText=#M#&authorisationCode=#C#&invoiceNumber=#R#&amountPaid=#A#&transactionRef=#I#&surname=#N#&currency=#U#' );
     end if;
     htp.formsubmit( null, voidrec.text_cc_message );
     htp.formclose;
   end if;
   htp.p( '</TD>' );
   if voidrec.payment_display_style = '1'
     then
       htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
   end if;

 elsif mtype.merchant_provider = 'SAFEPAY'
  then
   if voidrec.payment_display_gif = 'T' then htp.tabledata(chelp || htf.img( DECS.IMAGE_LOCATION || 'adminc/ord_merch.gif',cattributes=>'border=0'), cattributes=>pfx.ord_paym_left); end if;
   if voidrec.payment_display_style = '2'
     then
       htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
   end if;
   htp.p( '<TD ' || pfx.ord_paym_left || '>' );
   htp.p( txt );
   if mtype.nobutton_page = 'TRUE'
    then
     if voidrec.payment_display_all_as_butt = 'T'
      then
       htp.formopen( 'fname.merchant_goto', cattributes=>'onsubmit="javascript: window.open('''',''MERCHANT_WINDOW'',''top=100,left=100,width=400,height=300,location=no,toolbar=no,resizable=yes,menubar=no,scrollbars=yes,status=no''); this.target=''MERCHANT_WINDOW'';"' );
       htp.formhidden( 'SURL', surl );
       htp.formhidden( 'ACID', acid );
       htp.formsubmit( null, voidrec.text_cc_message );
       htp.formclose;
      else
       htp.p( '<A HREF="javascript: window.open(''fname.merchant_goto?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=400,height=300'');void('''');">' ||
              voidrec.payment_cc_text || '</A>');
     end if;
    else
     if mtype.popup = 'TRUE'
      then
       htp.formopen( mtype.merchant_url, ctarget=>'MERCHANT_PAGE' );
      else
       htp.formopen( mtype.merchant_url );
     end if;
     begin
      cnts := glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE ) * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1);
     exception
      when others then
       cnts := glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE );
     end;
     htp.formhidden( 'Locale', 'en' );
     --htp.formhidden( 'ReturnURL', 'http://wallace.piction.com:81/SSL_DR.asp?DR=${DR}'  );
     htp.formhidden( 'ReturnURL', mtype.merchant_returl  );
     htp.formhidden( 'MerchantID', mtype.merchant_id );
     htp.formhidden( 'PurchaseAmount', trim(to_char(cnts * 100,'999999999')) );
     htp.formhidden( 'SessionID', purch.poid || '-' || surl );
     htp.formsubmit( 'SubButL', voidrec.text_cc_message );
     htp.formclose;
   end if;
   htp.p( '</TD>' );
   if voidrec.payment_display_style = '1'
     then
       htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
   end if;

 elsif mtype.merchant_provider = 'SECUREPAY'
  then
   if voidrec.payment_display_gif = 'T' then htp.tabledata(chelp || htf.img( DECS.IMAGE_LOCATION || 'adminc/ord_merch.gif',cattributes=>'border=0'), cattributes=>pfx.ord_paym_left); end if;
   if voidrec.payment_display_style = '2'
     then
       htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
   end if;
   htp.p( '<TD ' || pfx.ord_paym_right2 || '>' );
   htp.p( txt );
   if mtype.nobutton_page = 'TRUE'
    then
     if voidrec.payment_display_all_as_butt = 'T'
      then
       htp.formopen( 'fname.merchant_goto', cattributes=>'onsubmit="javascript: window.open('''',''MERCHANT_WINDOW'',''top=100,left=100,width=400,height=300,location=no,toolbar=no,resizable=yes,menubar=no,scrollbars=yes,status=no''); this.target=''MERCHANT_WINDOW'';"' );
       htp.formhidden( 'SURL', surl );
       htp.formhidden( 'ACID', acid );
       htp.formsubmit( null, voidrec.text_cc_message );
       htp.formclose;
      else
       htp.p( '<A HREF="javascript: window.open(''fname.merchant_goto?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=400,height=300'');void('''');">' ||
              voidrec.payment_cc_text || '</A>');
     end if;
    else
     if mtype.popup = 'TRUE'
      then
       htp.formopen( mtype.merchant_url, ctarget=>'MERCHANT_PAGE' );
      else
       htp.formopen( mtype.merchant_url );
     end if;
     cnts := to_char(glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE )*100);
     begin
      cnts := round(cnts * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1));
     exception
      when others then
       cnts := to_char(glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE )*100);
     end;

     htp.formhidden( 'MERCHANTID', mtype.merchant_id );
     htp.formhidden( 'AMOUNT', cnts );
     htp.formhidden( 'PONUM', to_char(purch.pid) || '-' || to_char(purch.poid)); -- Prefix the purchase order by the photographer PID so reconcilliation reports can be done the server
     htp.formhidden( 'OPTIONAL_INFO', surl );
     if trim(owa_util.get_cgi_env( 'SERVER_PORT' )) = '80'
      then
       htp.formhidden( 'SUCCESS_PAGE', mtype.merchant_returl || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_securepay?wrk=T&ponum=' );
       htp.formhidden( 'FAILURE_PAGE', mtype.merchant_returl || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_securepay?wrk=F&ponum=' );
      else
       htp.formhidden( 'SUCCESS_PAGE', mtype.merchant_returl || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_securepay?wrk=T&ponum=' );
       htp.formhidden( 'FAILURE_PAGE', mtype.merchant_returl || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_securepay?wrk=T&ponum=' );
     end if;
     htp.formsubmit( null, voidrec.text_cc_message );
     htp.formclose;
   end if;
   htp.p( '</TD>' );
   if voidrec.payment_display_style = '1'
     then
       htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
   end if;

 elsif mtype.merchant_provider = 'SECUREBILL'
  then
   if voidrec.payment_display_gif = 'T' then htp.tabledata(chelp || htf.img( DECS.IMAGE_LOCATION || 'adminc/ord_merch.gif',cattributes=>'border=0'), cattributes=>pfx.ord_paym_left); end if;
   if voidrec.payment_display_style = '2'
     then
       htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
   end if;
   htp.p( '<TD ' || pfx.ord_paym_right2 || '>' );
   htp.p( txt );
   if mtype.nobutton_page = 'TRUE'
    then
     if voidrec.payment_display_all_as_butt = 'T'
      then
       htp.formopen( 'fname.merchant_goto', cattributes=>'onsubmit="javascript: window.open('''',''MERCHANT_WINDOW'',''top=100,left=100,width=400,height=300,location=no,toolbar=no,resizable=yes,menubar=no,scrollbars=yes,status=no''); this.target=''MERCHANT_WINDOW'';"' );
       htp.formhidden( 'SURL', surl );
       htp.formhidden( 'ACID', acid );
       htp.formsubmit( null, voidrec.text_cc_message );
       htp.formclose;
      else
       htp.p( '<A HREF="javascript: window.open(''fname.merchant_goto?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=400,height=300'');void('''');">' ||
              voidrec.payment_cc_text || '</A>');
     end if;
    else
     if mtype.popup = 'TRUE'
      then
       htp.formopen( mtype.merchant_url, ctarget=>'MERCHANT_PAGE' );
      else
       htp.formopen( mtype.merchant_url );
     end if;
     cnts := to_char(glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE )*100);
     begin
      cnts := round(cnts * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1));
     exception
      when others then
       cnts := to_char(glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE )*100);
     end;

     open c1( owa_util.get_cgi_env('SCRIPT_NAME') || '/' );
     fetch c1 into c1rec;
     if c1%NOTFOUND
      then
        htp.formhidden( '_SBILL_IN_bill_id', 'Z' || to_char(purch.poid) );
      else
        htp.formhidden( '_SBILL_IN_bill_id', c1rec.return_key || to_char(purch.poid) );
     end if;
     close c1;
     htp.formhidden( '_SBILL_IN_org_id', mtype.merchant_id );
     htp.formhidden( '_SBILL_IN_cents_amount', to_char( mod(cnts,100), '00' ) );
     htp.formhidden( '_SBILL_IN_dollar_amount', to_char( round(cnts / 100), '00' ) );
     htp.formhidden( '_SBILL_IN_customer_name', purch.sendto_name );
     htp.formhidden( '_SBILL_IN_bill_type', 'Merchant' );
     htp.formsubmit( null, voidrec.text_cc_message );
     htp.formclose;
   end if;
   htp.p( '</TD>' );
   if voidrec.payment_display_style = '1'
     then
       htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
   end if;

 elsif mtype.merchant_provider = 'DIRECT PAYMENT(NZ)'
  then
   if voidrec.payment_display_gif = 'T' then htp.tabledata(chelp || htf.img( DECS.IMAGE_LOCATION || 'adminc/directpayment.gif',cattributes=>'border=0'),cattributes=>pfx.ord_paym_left); end if;
   if voidrec.payment_display_style = '2'
     then
       htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
   end if;
   htp.p( '<TD ' || pfx.ord_paym_right2 || '>' );
   htp.p( txt );
   -- http://www.imagelab.co.nz:8080/pxaccess.asp
   if mtype.nobutton_page = 'TRUE'
    then
     if voidrec.payment_display_all_as_butt = 'T'
      then
       htp.formopen( 'fname.merchant_goto', cattributes=>'onsubmit="javascript: window.open('''',''MERCHANT_WINDOW'',''top=100,left=100,width=400,height=300,location=no,toolbar=no,resizable=yes,menubar=no,scrollbars=yes,status=no''); this.target=''MERCHANT_WINDOW'';"' );
       htp.formhidden( 'SURL', surl );
       htp.formhidden( 'ACID', acid );
       htp.formsubmit( null, voidrec.text_cc_message );
       htp.formclose;
      else
       htp.p( '<A HREF="javascript: window.open(''fname.merchant_goto?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=400,height=300'');void('''');">' ||
              voidrec.payment_cc_text || '</A>');
     end if;
    else
     if mtype.popup = 'TRUE'
      then
       htp.formopen( mtype.merchant_url || '/' || 'pxaccess.asp', ctarget=>'MERCHANT_PAGE' );
      else
       htp.formopen( mtype.merchant_url || '/' || 'pxaccess.asp' );
     end if;
     htp.formhidden( 'USERID', mtype.merchant_id );
     begin
      cnts := glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE ) * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1);
     exception
     when others then
       cnts := glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE );
     end;
     htp.formhidden( 'AMOUNT', trim(to_char(cnts,'999999999.99')) );
     htp.formhidden( 'TXNDATA1', to_char(purch.poid));
     htp.formhidden( 'TXNDATA2', substr(nvl(purch.billing_name,purch.sendto_name),1,60));
     htp.formhidden( 'TXNDATA3', SURL);
     htp.formhidden( 'MERCHANTREFERENCE', to_char(purch.poid));
     htp.formhidden( 'EMAIL', substr(purch.contact_email,1,64));
     htp.formhidden( 'URLSUCCESS', mtype.merchant_url || '/' || 'pxsuccess.asp' );
     htp.formhidden( 'URLFAIL', mtype.merchant_url || '/' || 'pxfail.asp' );
     htp.formsubmit( null, voidrec.text_cc_message );
     htp.formclose;
   end if;
   htp.p( '</TD>' );
   if voidrec.payment_display_style = '1'
     then
       htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || voidrec.payment_cc_text, cattributes=>pfx.ord_paym_right );
   end if;

 elsif mtype.merchant_provider = 'HOME'
  then
   secpage := glbx.extract_master_parameter('MERCHANT_URL');
   open c3( purch.pid );
   fetch c3 into c3rec;
   close c3;
   begin
    cnts := glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE ) * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1);
   exception
    when others then
     cnts := glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE );
   end;
   if mtype.popup = 'TRUE'
    then
     pp := 'MERCHANT_PAGE';
    else
     pp := '_top';
   end if;
   htp.tablerowopen;
    tmp := NULL;
    if voidrec.payment_display_gif = 'T' then htp.tabledata( chelp || htf.anchor( secpage, htf.img( DECS.IMAGE_LOCATION || 'adminc/ord_merch.gif',cattributes=>'border=0') ), cattributes=>pfx.ord_paym_left); end if;
    if nvl(c3rec.cc_mastercard,'T') = 'T'
     then
       tmp := tmp || txt || htf.anchor2(  secpage || 'mastercard.html' || '?surl=' || glbx.truncsurl(surl) || '&POID=' || purch.poid || '&TOTORD=' || trim(to_char(cnts, LNG.MONEY_FORMAT )),'Pay by Master Card', ctarget=>pp );
       tmp := tmp || htf.nl;
    end if;
    if nvl(c3rec.cc_visa,'T') = 'T'
     then
       tmp := tmp || txt || htf.anchor2(  secpage || 'visa.html' || '?surl=' || glbx.truncsurl(surl) || '&POID=' || purch.poid || '&TOTORD=' || trim(to_char(cnts, LNG.MONEY_FORMAT )),'Pay by Visa', ctarget=>pp );
       tmp := tmp || htf.nl;
    end if;
    if nvl(c3rec.cc_bankcard,'T') = 'T'
     then
       tmp := tmp || txt || htf.anchor2(  secpage || 'bankcard.html' || '?surl=' || glbx.truncsurl(surl) || '&POID=' || purch.poid || '&TOTORD=' || trim(to_char(cnts, LNG.MONEY_FORMAT )),'Pay by Bankcard', ctarget=>pp );
       tmp := tmp || htf.nl;
    end if;
    if nvl(c3rec.cc_amex,'T') = 'T'
     then
       tmp := tmp || txt || htf.anchor2(  secpage || 'amex.html' || '?surl=' || glbx.truncsurl(surl) || '&POID=' || purch.poid || '&TOTORD=' || trim(to_char(cnts, LNG.MONEY_FORMAT )),'Pay by Amex', ctarget=>pp );
       tmp := tmp || htf.nl;
    end if;
    if nvl(c3rec.cc_diners,'T') = 'T'
     then
       tmp := tmp || txt || htf.anchor2(  secpage || 'diners.html' || '?surl=' || glbx.truncsurl(surl) || '&POID=' || purch.poid || '&TOTORD=' ||trim(to_char(cnts, LNG.MONEY_FORMAT )),'Pay by Diners', ctarget=>pp );
       tmp := tmp || htf.nl;
    end if;
    htp.tabledata( htf.bold(voidrec.text_title_merchant) || htf.nl || tmp || htf.nl || voidrec.text_cc_message, cattributes=>pfx.ord_paym_right );
   htp.tablerowclose;

  else
   if voidrec.payment_display_gif = 'T' then htp.tabledata(htf.anchor( 'fname.goto_pay_merchant?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/ord_merch.gif',cattributes=>'border=0') ), cattributes=>pfx.ord_paym_left); end if;
   htp.tabledata(htf.bold(voidrec.text_title_merchant) || htf.nl || txt || htf.anchor( 'fname.goto_pay_merchant?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,glbx.extract_master_parameter('MERCHANT_TEXT')) || htf.nl || voidrec.text_cc_message, cattributes=>pfx.ord_paym_right2);

 end if;

 htp.tablerowclose;

end show_cc_facility;

procedure goto_pay_merchant( surl varchar2, acid in integer)
as

 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 sts		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 ttl		number;
 cnts		number;
 mtype		merchant_type;

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.GOTO_PAY_MERCHANT' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 update purchase_order
  set
   paid_method = 'MERCHANT',
   status = LNG4.AHC_TXT_672
 where poid = purchord.poid;

 purchase_audit_trail( surl, purchord.poid, 'PAID_METHOD', 'U', 'C', 'MERCHANT', purchord, voidrec);
 purchord.paid_method := 'MERCHANT';
 purchase_audit_trail( surl, purchord.poid, 'STATUS', 'U', 'C', LNG4.AHC_TXT_672, purchord, voidrec);
 commit;

 mtype := merchant_details(cusrec.pid);

 if mtype.merchant_provider = 'CYBERONE'
  then
    begin
     cnts := glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE ) * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1);
    exception
     when others then
      cnts := glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE );
    end;
    owa_util.redirect_url( translate(
          mtype.merchant_url || '?sys_ordernumber=' || nvl(mtype.merchant_id,purchord.poid)  ||
                          '&sys_href=' || mtype.merchant_returl || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant' ||
                          '&sys_amount=' || to_char(round(cnts,2)) ||
                          '&sys_header=' || htf.header(3,glbx.extract_master_parameter('BAR_TITLE'),'CENTER' ) ||
                          '&sys_footer=' || htf.header(3,glbx.extract_master_parameter('PAGE_TITLE'),'CENTER' ),' ','+'));

 /* -- Desupported
 elsif mtype.merchant_provider = 'ANZ'
  then
    begin
      ttl:= glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE ) * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1);
    exception
     when others then
      ttl := glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE );
    end;
    --htp.p('<body onload="self.name=''MerchantPage''">');
    --owa_util.get_cgi_env( 'SERVER_PORT' ) Removed because of firewall issues
    -- cents to_char(mod(ttl,1)*100) ||    dollar
    cnts := lpad(to_char(mod(ttl,1)*100),2,'0');
    owa_util.redirect_url( translate(
          mtype.merchant_url || '?merchantID=' || nvl(mtype.merchant_id,purchord.poid) ||
                          '&merchantName=' || glbx.extract_master_parameter('PAGE_TITLE') ||
                          '&successURL=' || mtype.merchant_returl || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_anz?wrk=T&surl=' || glbx.rndsurl(surl) ||
                          '&failURL=' || mtype.merchant_returl    || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_anz?wrk=F&surl=' || glbx.rndsurl(surl) ||
                          '&amountDollar=' || to_char(trunc(ttl)) ||
                          '&amountCent=' || cnts ||
                          '&currencyCode=' || nvl( voidrec.residing_country, 'AUD') ||
                          '&invoiceNumber=' || purchord.poid ||
                          '&surName=' || purchord.SENDTO_NAME ||
                          '&firstName=' ||
                          '&frameReff=True' ||
                          '&streetAddress=' ||
                          '&suburbLocation=' ||
                          '&postCode=' ||
                          '&homePhone=' ||
                          '&busPhone=' ||
                          '&emailAddress=' ||
                          '&specInstruct=' ||
                          '&orderDescription=PHOTOGRAPH' ||
                          '&B1=Process+Payment' ||
                          '&responseType=TypeA',' ','+'),TRUE
                     );
 */

 elsif mtype.merchant_provider = 'ESEC'
  then
   --
   --
   -- action: https://sec.aba.net.au/merchant/plavenholdings/testpayment.props
   -- action2: https://sec.aba.net.au/cgi-bin/service/authorise/test
   -- http://opus.piction.com/pls/piction/test3
   -- Test ESEC Values
   -- http://opus.piction.com/images/order_esec_test.html
   -- https://sec.aba.net.au/merchant/test/testpayment.props
   -- Prod ESEC Values
   -- http://opus.piction.com/images/order_esec.html
   -- https://sec.aba.net.au/merchant/test/payment.props

    begin
     ttl := glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE ) * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1);
    exception
     when others then
      ttl := glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE );
    end;
    ttl := glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE );
    owa_util.redirect_url
     ( translate(
           mtype.merchant_url ||
           '?secParams=' || mtype.merchant_id ||
           '&merchantName=' || glbx.extract_master_parameter('PAGE_TITLE') ||
           '&resultURL=' || mtype.merchant_returl || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_esec?surl=' || glbx.rndsurl(surl) ||
           '&referenceID=' || purchord.poid ||
           '&amount=' || ltrim(to_char(ttl,'9999999.99')),' ','+'),TRUE);
 end if;


exception when others then
 glbx.error_details( 'FNAME', 'GOTO_PAY_MERCHANT',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end goto_pay_merchant;

procedure show_cheque_facility( surl in varchar2, acid in integer, profid in integer, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, ltype in varchar2, isproblem in boolean, pfx in theme%rowtype )
as
 txt		varchar2(1000);
begin
   if voidrec.payment_cheque = 'F' then return; end if;
   if ((upper(purch.home_country) <> purch.sendto_country) and (voidrec.payment_cc_international = 'T')) then return; end if;

    htp.tablerowopen;
     if voidrec.payment_display_gif = 'T' then htp.tabledata(htf.anchor( 'fname.accept_purchase?surl=' || glbx.rndsurl(surl) || '&paychoice=CHEQUE&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/cheque.gif',cattributes=>'border=0') ), cattributes=>pfx.ord_paym_left); end if;

     if isproblem
      then
       txt := htf.bold( voidrec.text_order_problem );
       if voidrec.payment_display_all_as_butt = 'T'
        then
         if voidrec.payment_display_style = '2'
          then
           if voidrec.text_title_cheque is null then htp.tabledata( txt, cattributes=>pfx.ord_paym_right );
           else htp.tabledata( htf.bold(voidrec.text_title_cheque) || htf.nl || txt, cattributes=>pfx.ord_paym_right ); end if;
         end if;
         htp.p( '<TD ' || pfx.ord_paym_right2 || '>' );
         htp.formopen( 'fname.accept_purchase' );
           htp.formhidden( 'SURL', surl );
           htp.formhidden( 'PAYCHOICE', 'CHEQUE' );
           htp.formhidden( 'ACID', acid );
           htp.formsubmit( null, voidrec.text_cheque_message );
         htp.formclose;
         htp.p( '</TD>' );
         if voidrec.payment_display_style = '1'
          then
           if voidrec.text_title_cheque is null then htp.tabledata( txt, cattributes=>pfx.ord_paym_right );
           else htp.tabledata( htf.bold(voidrec.text_title_cheque) || htf.nl || txt, cattributes=>pfx.ord_paym_right );
           end if;
         end if;
        else
         htp.tabledata(htf.anchor( 'fname.accept_purchase?surl=' || glbx.rndsurl(surl) || '&paychoice=CHEQUE&acid=' || acid, voidrec.text_cheque_message ), cattributes=>pfx.ord_paym_right2);
         if voidrec.payment_display_style = '1'
          then
           if voidrec.text_title_cheque is null then htp.tabledata( txt, cattributes=>pfx.ord_paym_right );
           else htp.tabledata( htf.bold(voidrec.text_title_cheque) || htf.nl || txt, cattributes=>pfx.ord_paym_right );
           end if;
         end if;
       end if;

      else

       txt := nvl(voidrec.payment_cheque_text,'&nbsp;');
       if voidrec.payment_display_style = '2'
        then
         if voidrec.text_title_cheque is null then htp.tabledata( txt, cattributes=>pfx.ord_paym_right );
         else htp.tabledata( htf.bold(voidrec.text_title_cheque) || htf.nl || txt, cattributes=>pfx.ord_paym_right );
         end if;
       end if;
       if voidrec.payment_display_all_as_butt = 'T'
        then
         htp.p( '<TD ' || pfx.ord_paym_right2 || '>' );
         htp.formopen( 'fname.accept_purchase' );
           htp.formhidden( 'SURL', surl );
           htp.formhidden( 'PAYCHOICE', 'CHEQUE' );
           htp.formhidden( 'ACID', acid );
           htp.formsubmit( null, voidrec.text_cheque_message );
         htp.formclose;
         htp.p( '</TD>' );
         if voidrec.payment_display_style = '1'
          then
           if voidrec.text_title_cheque is null then htp.tabledata( txt, cattributes=>pfx.ord_paym_right );
           else htp.tabledata( htf.bold(voidrec.text_title_cheque) || htf.nl || txt, cattributes=>pfx.ord_paym_right );
           end if;
         end if;

        else
         htp.tabledata(htf.anchor( 'fname.accept_purchase?surl=' || glbx.rndsurl(surl) || '&paychoice=CHEQUE&acid=' || acid,voidrec.text_cheque_message ), cattributes=>pfx.ord_paym_right2);
         if voidrec.payment_display_style = '1'
          then
           if voidrec.text_title_cheque is null then htp.tabledata( txt, cattributes=>pfx.ord_paym_right );
           else htp.tabledata( htf.bold(voidrec.text_title_cheque) || htf.nl || txt, cattributes=>pfx.ord_paym_right );
           end if;
         end if;
       end if;

     end if;

    htp.tablerowclose;
end show_cheque_facility;

procedure show_auth_facility( surl in varchar2, acid in integer, profid in integer, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, ltype in varchar2, isproblem in boolean, pfx in theme%rowtype )
as

 cursor c1( phgid integer ) is select project_code,project_name from project_codes where pid = phgid order by project_code;
 txt		varchar2(1000);

begin
   if voidrec.payment_auth = 'F' then return; end if;
   if ((upper(purch.home_country) <> purch.sendto_country) and (voidrec.payment_cc_international = 'T')) then return; end if;
   if isproblem then txt := htf.bold( voidrec.text_order_problem ) || htf.nl || voidrec.text_purchase_request || '#' || purch.poid || htf.nl || voidrec.payment_auth_text; else txt := voidrec.payment_auth_text; end if;
   htp.tablerowopen;

    if voidrec.payment_auth_project_code = 'F' and voidrec.payment_display_all_as_butt = 'F'
     then
      if voidrec.payment_display_gif = 'T' then htp.tabledata(htf.anchor( 'fname.accept_purchase?surl=' || glbx.rndsurl(surl) || '&paychoice=AUTHORISATION&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/authorisation.gif',cattributes=>'border=0') ), cattributes=>pfx.ord_paym_left); end if;
      if isproblem then txt := htf.bold( voidrec.text_order_problem ) || htf.nl || voidrec.text_purchase_request || '#' || purch.poid || htf.nl; end if;
      htp.tabledata(htf.bold( voidrec.text_title_authorisation ) || htf.nl || txt, cattributes=>pfx.ord_paym_right );
      htp.tabledata(htf.anchor( 'fname.accept_purchase?surl=' || glbx.rndsurl(surl) || '&paychoice=AUTHORISATION&acid=' || acid, voidrec.payment_auth_text ), cattributes=>pfx.ord_paym_right2);

     else

      if voidrec.payment_display_gif = 'T' then htp.tabledata(htf.anchor( 'fname.accept_purchase?surl=' || glbx.rndsurl(surl) || '&paychoice=AUTHORISATION&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/authorisation.gif',cattributes=>'border=0') ), cattributes=>pfx.ord_paym_left); end if;
      htp.formopen( 'fname.accept_purchase');
      htp.formhidden( 'SURL', surl );
      htp.formhidden( 'ACID', acid );
      htp.formhidden( 'PAYCHOICE', 'AUTHORISATION' );

      if voidrec.payment_display_style = '1'
       then
        htp.p( '<TD ' || pfx.ord_paym_right2 || '>' );
         htp.formsubmit( null, voidrec.text_auth_message );
        htp.p( '</TD>' );
      end if;
      htp.p( '<TD ' || pfx.ord_paym_right || '>' );

      if voidrec.text_title_authorisation is null then htp.p( txt );
      else htp.p( htf.bold(voidrec.text_title_authorisation) || htf.nl || txt ); end if;

      if voidrec.payment_auth_project_code = 'F'
       then
        htp.formhidden( 'P1', NULL );
       else
        htp.nl;
        htp.formselectopen( 'P1' );
        for c1rec in c1( purch.pid ) loop
         if c1rec.project_code = purch.project_code
          then
           htp.formselectoption( c1rec.project_name || '(' || c1rec.project_code || ')', 'SELECTED', cattributes=>'VALUE="' || c1rec.project_code || '"' );
          else
           htp.formselectoption( c1rec.project_name || '(' || c1rec.project_code || ')', cattributes=>'VALUE="' || c1rec.project_code || '"' );
          end if;
        end loop;
        htp.formselectclose;
      end if;
      htp.p( '</TD>' );
      if voidrec.payment_display_style = '2'
       then
        htp.p( '<TD ' || pfx.ord_paym_right2 || '>' );
         htp.formsubmit( null, voidrec.text_auth_message );
         htp.formclose;
        htp.p( '</TD>' );
       else
        htp.formclose;
      end if;

    end if;

   htp.tablerowclose;
end show_auth_facility;

procedure show_gift_facility( surl in varchar2, acid in integer, profid in integer, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, ltype in varchar2, isproblem in boolean, pfx in theme%rowtype )
as
begin
   if voidrec.payment_gift = 'F' then return; end if;
   if ((upper(purch.home_country) <> purch.sendto_country) and (voidrec.payment_cc_international = 'T')) then return; end if;
   htp.tablerowopen;
    if voidrec.payment_display_gif = 'T'
     then
       htp.tabledata(htf.anchor( 'fname.accept_purchase?surl=' || glbx.rndsurl(surl) || '&paychoice=CERTIFICATE&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/certificate.gif',cattributes=>'border=0') ), cattributes=>pfx.ord_paym_left);
    end if;

    if voidrec.payment_display_all_as_butt = 'T'
     then
      if voidrec.payment_display_style = '2'
       then
        htp.tabledata( htf.bold(voidrec.text_title_gift) || htf.nl || voidrec.payment_gift_text, cattributes=>pfx.ord_paym_right );
      end if;
      htp.p( '<TD ' || pfx.ord_paym_right2 || '>' );
      htp.formopen( 'fname.accept_purchase' );
        htp.formhidden( 'SURL', surl );
        htp.formhidden( 'PAYCHOICE', 'CERTIFICATE' );
        htp.formhidden( 'ACID', acid );
        htp.formsubmit( null, voidrec.payment_gift_text );
      htp.formclose;
      htp.p( '</TD>' );
      if voidrec.payment_display_style = '1'
       then
        htp.tabledata( htf.bold(voidrec.text_title_gift) || htf.nl || voidrec.payment_gift_text, cattributes=>pfx.ord_paym_right );
      end if;

     else
      if voidrec.payment_display_style = '2'
       then
        htp.tabledata( htf.bold(voidrec.text_title_gift) || htf.nl || voidrec.payment_gift_text, cattributes=>pfx.ord_paym_right );
      end if;
      htp.tabledata(htf.anchor( 'fname.accept_purchase?surl=' || glbx.rndsurl(surl) || '&paychoice=CERTIFICATE&acid=' || acid,voidrec.text_gift_message ), cattributes=>pfx.ord_paym_right2);
      if voidrec.payment_display_style = '1'
       then
        htp.tabledata( htf.bold(voidrec.text_title_gift) || htf.nl || voidrec.payment_gift_text, cattributes=>pfx.ord_paym_right );
      end if;

    end if;
   htp.tablerowclose;
end show_gift_facility;

procedure show_phone_facility( surl in varchar2, acid in integer, profid in integer, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, ltype in varchar2, isproblem in boolean, pfx in theme%rowtype )
as

 cursor c1(phgid integer) is select work_phone from photographer where pid = phgid;

 c1rec	c1%ROWTYPE;
 txt	varchar2(200);
 txt2	varchar2(200);

begin
   if voidrec.payment_phone = 'F' then return; end if;
   if ((upper(purch.home_country) <> purch.sendto_country) and (voidrec.payment_cc_international = 'T')) then return; end if;
   htp.tablerowopen;
   if voidrec.payment_display_gif = 'T' then htp.tabledata(htf.anchor( 'fname.accept_purchase?surl=' || glbx.rndsurl(surl) || '&paychoice=PHONE&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/ord_phone.gif',cattributes=>'border=0') ), cattributes=>pfx.ord_paym_left); end if;
   if isproblem
    then
      open c1(purch.pid);
      fetch c1 into c1rec;
      close c1;
      txt := htf.bold( voidrec.text_order_problem );
      if c1rec.work_phone is null
       then
        if glbx.extract_master_parameter('CONTACT_NUMBER') is not null
         then
          txt2 := htf.bold( voidrec.text_order_problem ) || ':' || glbx.extract_master_parameter('CONTACT_NUMBER');
         else
          txt2 := NULL;
        end if;
       else
        txt2 := htf.bold( voidrec.text_order_problem ) || ':' || c1rec.work_phone;
      end if;
      txt2 := txt2 || htf.nl || voidrec.text_purchase_request || '#' || purch.poid || htf.nl;
    else
     txt := voidrec.payment_phone_text;
    end if;
    if voidrec.payment_display_style = '2'
     then
      if voidrec.text_title_phone is null then htp.tabledata( txt, cattributes=>pfx.ord_paym_right );
      else htp.tabledata( htf.bold(voidrec.text_title_phone) || htf.nl || txt, cattributes=>pfx.ord_paym_right ); end if;
    end if;
    if voidrec.payment_display_all_as_butt = 'T'
     then
      htp.p( '<TD ' || pfx.ord_paym_right2 || '>' );
      htp.p( txt2 );
      htp.formopen( 'fname.accept_purchase' );
        htp.formhidden( 'SURL', surl );
        htp.formhidden( 'PAYCHOICE', 'PHONE' );
        htp.formhidden( 'ACID', acid );
        htp.formsubmit( null, voidrec.text_phone_message_but );
      htp.formclose;
      htp.p( '</TD>' );
     else
      htp.tabledata(htf.anchor( 'fname.accept_purchase?surl=' || glbx.rndsurl(surl) || '&paychoice=PHONE&acid=' || acid, voidrec.text_phone_message_but ), cattributes=>pfx.ord_paym_right2);
    end if;
    if voidrec.payment_display_style = '1'
     then
      if voidrec.text_title_phone is null then htp.tabledata( txt, cattributes=>pfx.ord_paym_right );
      else htp.tabledata( htf.bold(voidrec.text_title_phone) || htf.nl || txt, cattributes=>pfx.ord_paym_right ); end if;
    end if;
   htp.tablerowclose;
end show_phone_facility;

procedure show_billing_facility( surl in varchar2, acid in integer, profid in integer, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, ltype in varchar2, isproblem in boolean, pfx in theme%rowtype )
as
 cursor c1(ltype varchar2, acid integer) is select * from customer_contact where accept_pay_by_acct = 'T' and login_type = ltype and aid = acid;
 c1rec	c1%ROWTYPE;
begin
   if voidrec.payment_billing = 'F' then return; end if;
   if ((upper(purch.home_country) <> purch.sendto_country) and (voidrec.payment_cc_international = 'T')) then return; end if;
   if ltype = 'PROFILE'
    then
     open c1(ltype,profid);
    else
     open c1(ltype,acid);
   end if;
   fetch c1 into c1rec;
   if c1%NOTFOUND
    then
     close c1;
     return;
   end if;
   close c1;
   htp.tablerowopen;
     if voidrec.payment_display_gif = 'T' then htp.tabledata('[BILLING]', cattributes=>pfx.ord_paym_left ); end if;
     if voidrec.payment_display_style = '2'
      then
       if voidrec.text_title_billing is null then htp.tabledata( voidrec.payment_billing_text, cattributes=>pfx.ord_paym_right );
       else htp.tabledata( htf.bold(voidrec.text_title_billing) || htf.nl || voidrec.payment_billing_text, cattributes=>pfx.ord_paym_right ); end if;
     end if;
     htp.p( '<TD ' || pfx.ord_paym_right2 || '>' );
     if isproblem then htp.bold( voidrec.text_order_problem ); end if;
     htp.formopen( 'fname.check_account' );
     htp.formhidden( 'SURL', glbx.rndsurl(surl));
     htp.formhidden( 'ACID', acid );
     htp.p( LNG2.PFM_TXT_114 || ' ' || htf.formpassword( 'P1',20,10 ) || ' ' || htf.formsubmit(null,voidrec.text_billing_message ));
     htp.formclose;
     htp.p( '</TD>' );
     if voidrec.payment_display_style = '1'
      then
       if voidrec.text_title_billing is null then htp.tabledata( voidrec.payment_billing_text, cattributes=>pfx.ord_paym_right );
       else htp.tabledata( htf.bold(voidrec.text_title_billing) || htf.nl || voidrec.payment_billing_text, cattributes=>pfx.ord_paym_right ); end if;
     end if;
   htp.tablerowclose;

end show_billing_facility;

procedure show_free_images( surl in varchar2, acid in integer, profid in integer, purch in purchase_order%ROWTYPE, cusrec in customer_account%rowtype, voidrec in order_style%ROWTYPE, ltype in varchar2, isproblem in boolean, pfx in theme%rowtype )
as

 tag_name	GLBX.MYARRAY;
 tag_title	GLBX.MYARRAY;

begin

 if voidrec.payment_free = 'F' then return; end if;

 htp.tablerowopen;
  if voidrec.payment_display_gif = 'T' then htp.tabledata( '&nbsp;', cattributes=>pfx.ord_paym_left); end if;
  htp.p( '<TD ' || pfx.ord_paym_right || '>');
   htp.formopen( 'fname.accept_free_images' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ACID', acid );
    htp.bold( htf.bold(voidrec.text_title_free) || htf.nl || voidrec.payment_free_text );
    htp.nl;
    htp.nl;
    htp.p( htf.bold(LNG.ORD_TXT_158) );
    htp.nl;
     htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 rules="NONE" frame="HSIDES,VSIDES" border=' || pfx.ord_text_table_borderi );
      htp.tablerowopen;
       htp.p( '<TD ' || pfx.ord_paym_right2 || '>' );
        glbx.external_html_file( surl, cusrec, 'TERMS', tag_name, tag_title );
       htp.p( '</TD>' );
      htp.tablerowclose;
     htp.tableclose;
    htp.formsubmit( 'RSP1', LNG.ORD_TXT_159 );
    htp.formsubmit( 'RSP1', LNG.ORD_TXT_160 );
   htp.formclose;
  htp.p( '</TD>' );
 htp.tablerowclose;

exception when others then
 glbx.error_details( 'FNAME', 'SHOW_FREE_IMAGES',errmsg=>sqlerrm);
end show_free_images;

procedure accept_free_images( surl varchar2, rsp1 in varchar2, acid in integer, msg in varchar2 default null )
as

 cursor c5(purchase_id integer) is
  select um.umo_id, um.extras.photo_name photo_name, dbms_lob.getlength(um.photo_original.source.localdata) contentlength, um.photo_original.fileformat fileformat
  from shopping_basket sb,umo um
  where sb.poid = purchase_id and
        sb.phid = um.umo_id and
        nvl(dbms_lob.getlength(um.photo_original.source.localdata),0) > 0
  order by shopping_id;
 cursor c6(purchase_id integer) is
  select um.umo_id, um.extras.photo_name photo_name
  from shopping_basket sb,umo um
  where sb.poid = purchase_id and
        sb.phid = um.umo_id and
        um.ftp_location is not null and
        um.ftp_virtual_dir is not null
  order by shopping_id;

 cusrec		CUSTOMER_ACCOUNT%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	THEME_TYPES%ROWTYPE;
 purchord 	PURCHASE_ORDER%ROWTYPE;
 voidrec	ORDER_STYLE%ROWTYPE;
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 ltype		varchar2(100);
 foundrec	boolean;

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.ACCEPT_FREE_IMAGES' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
 -- Business Feature overriden, get the other one
 if voidrec.bftr <> 'Use Customer Account Business Feature'
  then
   theme_rec := glbx.get_theme_types( voidrec.bftr );
 end if;

 if voidrec.laf <> 'Use Customer Account Look and Feel'
  then
   pfx := glbx.get_thm( voidrec.laf );
 end if;

 if purchord.status not in ('Customer Cancelled','Photographer Cancelled','PreOrder - No Order Made','PreOrder','PreOrder - Sent to Bank','Awaiting Authorisation','PreOrder - Confirmed without Payment')
  then
   recalc_order( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
   return;
 end if;

 if voidrec.payment_free = 'F' then htp.bold( 'Invalid Access' ); return; end if; -- Invalid. Must be set to T.

 if rsp1 = LNG.ORD_TXT_160 -- Decline
  then
    acct_orders(surl, 'Terms and Conditions Declined.', acid );
    return;
  else
    glbx.main_title( surl, LNG.ORD_TXT_157, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'O18',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 end if;

 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
 htp.p( '<CENTER>' );

 if voidrec.payment_free = 'T'
  then
   htp.nl;
   foundrec := FALSE;
   htp.bold( LNG.ORD_TXT_163 ); htp.nl;
   htp.ulistopen;
   for c5rec in c5(purchord.poid) loop
    foundrec := TRUE;
    htp.listitem( htf.anchor( 'fname.download_file?surl=' || glbx.rndsurl(surl) || '&v_umo=' || c5rec.umo_id || '&purchid=' || purchord.poid || '&mthod=ORIGINAL&acid=' || acid, nvl(c5rec.photo_name,LNG3.ADM_TXT_351) || '(' || to_char(c5rec.contentlength) || '-' || c5rec.fileformat || ')'));
   end loop;
   htp.ulistclose;
   htp.bold( LNG3.ADM_TXT_600 ); htp.nl;
   htp.ulistopen;
   htp.nl;
   for c6rec in c6(purchord.poid) loop
    foundrec := TRUE;
    htp.listitem( htf.anchor2( 'fname.download_file?surl=' || glbx.rndsurl(surl) || '&v_umo=' || c6rec.umo_id || '&purchid=' || purchord.poid || '&mthod=FTP&acid=' || acid, nvl(c6rec.photo_name,LNG3.ADM_TXT_351), ctarget=>'FTP_DOWNLOAD_WINDOW'));
   end loop;
   htp.ulistclose;
   if not foundrec then htp.bold( LNG.ORD_TXT_164 ); htp.nl; end if;
 end if;

 htp.p( '</CENTER>' );
 glbx.close_page( pfx );
exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_FREE_IMAGES',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end accept_free_images;

procedure show_problems_facility( surl in varchar2, acid in integer, profid in integer, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, ltype in varchar2, pfx in theme%rowtype )
as
begin
 -- CC, CHEQUE, PHONE, BILLING, AUTH
 if voidrec.payment_problems_def = 'NONE' then return; end if;
 htp.tablerowopen;
 if voidrec.payment_problems_def = 'PHONE'
  then
   show_phone_facility(surl, acid, profid, purch, voidrec, ltype, TRUE, pfx );
 elsif voidrec.payment_problems_def = 'CHEQUE'
  then
   show_cheque_facility(surl, acid, profid, purch, voidrec, ltype, TRUE, pfx );
 elsif voidrec.payment_problems_def = 'BILLING'
  then
   show_billing_facility(surl, acid, profid, purch, voidrec, ltype, TRUE, pfx );
 elsif voidrec.payment_problems_def = 'AUTH'
  then
   show_auth_facility(surl, acid, profid, purch, voidrec, ltype, TRUE, pfx );
 elsif voidrec.payment_problems_def = 'CC'
  then
   show_cc_facility( surl, acid, profid, purch, voidrec, ltype, TRUE, pfx );
 end if;
 htp.tablerowclose;
end show_problems_facility;

function get_currency( cntry in varchar2 )
 return varchar2
is

 cursor c1(cntry varchar2) is select three_char_reference from postal_charge where region = cntry;
 c1rec  c1%ROWTYPE;

begin
 open c1(cntry);
 fetch c1 into c1rec;
 close c1;
 return( c1rec.three_char_reference );
exception
 when others then return( NULL );
end get_currency;

function merchant_details( phgid in integer )
 return merchant_type
as

 cursor c1(phgid integer) is select * from photographer where pid = phgid;
 c1rec		c1%ROWTYPE;

 mtype		merchant_type;

begin
 open c1(phgid);
 fetch c1 into c1rec;
 close c1;
 if c1rec.merchant_used is null or c1rec.credit_card_access = 'F'
  then

   mtype.merchant_provider := glbx.extract_master_parameter('MERCHANT_PROVIDER');
   if mtype.merchant_provider in ('CYBERONE','ANZ','ANZ-II','ESEC','SECUREPAY','SECUREBILL','CBANK','NAB','HOME','DIRECT PAYMENT(NZ)')
    then
     mtype.merchant_url := glbx.extract_master_parameter('MERCHANT_URL');
     mtype.merchant_id := glbx.extract_master_parameter('MERCHANT_ID');
     mtype.merchant_returl := glbx.extract_master_parameter('MERCHANT_RETURNTO_URL');
     mtype.popup := glbx.extract_master_parameter('MERCHANT_POP_WINDOW');
     mtype.nobutton_page := glbx.extract_master_parameter('MERCHANT_WINDOW_NOTITLE');
   elsif mtype.merchant_provider = 'SAFEPAY'
    then
     mtype.merchant_url := glbx.extract_master_parameter('MERCHANT_URL');
     mtype.merchant_id := glbx.extract_master_parameter('MERCHANT_ID');
     mtype.merchant_returl := glbx.extract_master_parameter('MERCHANT_SPECIAL_RETURL');
     mtype.popup := glbx.extract_master_parameter('MERCHANT_POP_WINDOW');
     mtype.nobutton_page := glbx.extract_master_parameter('MERCHANT_WINDOW_NOTITLE');
   end if;

  else
   mtype.merchant_provider := c1rec.merchant_used;
   mtype.merchant_id := c1rec.merchant_id;
   mtype.merchant_url := c1rec.merchant_url_site;
   mtype.merchant_returl := c1rec.merchant_return_url;
   mtype.popup := c1rec.merchant_popup_window;
   mtype.nobutton_page := c1rec.merchant_window_notitle;
 end if;

 return( mtype );
end merchant_details;

procedure accept_order_page( surl in varchar2, acid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, action in varchar2 default null, order_return in varchar2 default null, payment in varchar2 default null )
as

 cursor c1(vpoid integer) is select * from purchase_order where poid = vpoid;

 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 quick_exit	boolean;
 vaction	varchar2(100);
 sts		varchar2(100);
 msg		varchar2(1000);
 result		varchar2(32767);

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.ACCEPT_ORDER_PAGE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
 -- Business Feature overriden, get the other one
 if voidrec.bftr <> 'Use Customer Account Business Feature'
  then
   theme_rec := glbx.get_theme_types( voidrec.bftr );
 end if;

 if voidrec.laf <> 'Use Customer Account Look and Feel'
  then
   pfx := glbx.get_thm( voidrec.laf );
 end if;

 if action is not null
  then
   vaction := action;

 elsif order_return is not null
  then
   vaction := voidrec.text_return_button;

 elsif payment is not null
  then
   vaction := voidrec.text_proceed_button;

 end if;

 if vaction = voidrec.text_return_button or vaction = 'Return to the ' || voidrec.text_shopping_basket
  then
   fname.acct_orders(surl, 'Action Cancelled', acid );
   return;
 end if;

 -- Process Details
 process_data_entered( surl, pfx, acid, ltype, profid, p1, p2, p3, cusrec, purchord, voidrec, 'ORDER', result );
 -- Extract all the new details as purchord is looking at the old values
 open c1(purchord.poid);
 fetch c1 into purchord;
 close c1;

 if result is null
  then
   if voidrec.columns_swap_pay_confirm = 'F'
    then
     disp_payment_page( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, msg, 'FULL' );
    else
     disp_confirm_page( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, msg );
   end if;
   htp.nl;
   htp.p( '</CENTER>' );
   glbx.close_page( pfx );
  else
   disp_order_page( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, result );
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_ORDER_PAGE',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end accept_order_page;

procedure process_data_entered( surl in varchar2, pfx in theme%ROWTYPE, acid in integer, ltype in varchar2, profid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, cusrec in customer_account%rowtype, purchord in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, action in varchar2, result out varchar2 )
as

 cursor c1(acid integer, eml varchar2, profid integer) is
  select count('x') tot
  from customer_contact cc, customer_profile cp
  where cc.login_type = 'PROFILE' and
        cc.aid = cp.profile_id and
        upper(cc.contact_email) = upper(eml) and
        cp.aid = acid and
        cp.profile_id <> profid;

 cursor c2(void integer) is select * from additional_options_definition where oid = void order by order_by;

 c1rec		c1%ROWTYPE;
 purchrec	purchase_order%ROWTYPE;
 addoptrec	purchase_additional_options%ROWTYPE;
 subtotal	number;
 unsol		char(1);
 accid		integer;
 check_col	char(40);
 vtxt		varchar2(4000);

begin
  purchrec.poid := purchord.poid;
  if nvl(voidrec.columns_name_toggle,'T') = 'T'
   then
    purchrec.sendto_name := trim(getval( '6-NAME', p1, p2 ));
    glbx.fixnm( purchrec.sendto_name, purchrec.sendto_firstname, purchrec.sendto_lastname );
   else
    purchrec.sendto_firstname := trim(getval( '6-FIRSTNAME', p1, p2 ));
    purchrec.sendto_lastname := trim(getval( '6-LASTNAME', p1, p2 ));
    purchrec.sendto_name := substr(purchrec.sendto_firstname || ' ' || purchrec.sendto_lastname,1,100);
  end if;
  purchase_audit_trail( surl, purchrec.poid, 'SENDTO_NAME', 'U', 'C', purchrec.sendto_name, purchord, voidrec);
  purchase_audit_trail( surl, purchrec.poid, 'SENDTO_FIRSTNAME', 'U', 'C', purchrec.sendto_firstname, purchord, voidrec);
  purchase_audit_trail( surl, purchrec.poid, 'SENDTO_LASTNAME', 'U', 'C', purchrec.sendto_lastname, purchord, voidrec);
  purchrec.sendto_street := trim(getval( '6-STREET', p1, p2 ));
  purchase_audit_trail( surl, purchrec.poid, 'SENDTO_STREET', 'U', 'C', purchrec.sendto_street, purchord, voidrec);
  purchrec.sendto_branch := trim(getval( '6-BRANCH', p1, p2 ));
  purchase_audit_trail( surl, purchrec.poid, 'SENDTO_BRANCH', 'U', 'C', purchrec.sendto_branch, purchord, voidrec);
  purchrec.sendto_department := trim(getval( '6-DEPARTMENT', p1, p2 ));
  purchase_audit_trail( surl, purchrec.poid, 'SENDTO_DEPARTMENT', 'U', 'C', purchrec.sendto_department, purchord, voidrec);
  purchrec.sendto_suburb := trim(getval( '6-SUBURB', p1, p2 ));
  purchase_audit_trail( surl, purchrec.poid, 'SENDTO_SUBURB', 'U', 'C', purchrec.sendto_suburb, purchord, voidrec);
  purchrec.sendto_city := trim(getval( '6-CITY', p1, p2 ));
  purchase_audit_trail( surl, purchrec.poid, 'SENDTO_CITY', 'U', 'C', purchrec.sendto_city, purchord, voidrec);
  purchrec.sendto_postcode := trim(getval( '6-POSTCODE', p1, p2 ));
  purchase_audit_trail( surl, purchrec.poid, 'SENDTO_POSTCODE', 'U', 'C', purchrec.sendto_postcode, purchord, voidrec);
  purchrec.sendto_state := trim(getval( '6-STATE', p1, p2 ));
  purchase_audit_trail( surl, purchrec.poid, 'SENDTO_STATE', 'U', 'C', purchrec.sendto_state, purchord, voidrec);
  purchrec.sendto_country := trim(getval( '6-COUNTRY', p1, p2 ));
  purchase_audit_trail( surl, purchrec.poid, 'SENDTO_COUNTRY', 'U', 'C', purchrec.sendto_country, purchord, voidrec);
  purchrec.contact_phone := trim(getval( '6-PHONE', p1, p2 ));
  purchase_audit_trail( surl, purchrec.poid, 'CONTACT_PHONE', 'U', 'C', purchrec.contact_phone, purchord, voidrec);
  purchrec.customer_comment := trim(getval( '6-CUSTOMER_COMMENT', p1, p2 ));
  purchase_audit_trail( surl, purchrec.poid, 'CUSTOMER_COMMENT', 'U', 'C', purchrec.customer_comment, purchord, voidrec);

  purchrec.customer_column1 := trim(glbx.censor(getval( '6-CUSTOMER_COLUMN1', p1, p2 ),100));
  purchase_audit_trail( surl, purchrec.poid, 'CUSTOMER_COLUMN1', 'U', 'C', purchrec.customer_column1, purchord, voidrec);
  purchrec.customer_column2 := trim(glbx.censor(getval( '6-CUSTOMER_COLUMN2', p1, p2 ),100));
  purchase_audit_trail( surl, purchrec.poid, 'CUSTOMER_COLUMN2', 'U', 'C', purchrec.customer_column2, purchord, voidrec);
  purchrec.customer_column3 := trim(glbx.censor(getval( '6-CUSTOMER_COLUMN3', p1, p2 ),100));
  purchase_audit_trail( surl, purchrec.poid, 'CUSTOMER_COLUMN3', 'U', 'C', purchrec.customer_column3, purchord, voidrec);
  purchrec.customer_column4 := trim(glbx.censor(getval( '6-CUSTOMER_COLUMN4', p1, p2 ),100));
  purchase_audit_trail( surl, purchrec.poid, 'CUSTOMER_COLUMN4', 'U', 'C', purchrec.customer_column4, purchord, voidrec);
  purchrec.customer_column5 := trim(glbx.censor(getval( '6-CUSTOMER_COLUMN5', p1, p2 ),100));
  purchase_audit_trail( surl, purchrec.poid, 'CUSTOMER_COLUMN5', 'U', 'C', purchrec.customer_column5, purchord, voidrec);
  purchrec.customer_column6 := trim(glbx.censor(getval( '6-CUSTOMER_COLUMN6', p1, p2 ),100));
  purchase_audit_trail( surl, purchrec.poid, 'CUSTOMER_COLUMN6', 'U', 'C', purchrec.customer_column6, purchord, voidrec);

  if voidrec.columns_email_unique = 'T' and ltype = 'PROFILE'
   then
    open c1(acid, getval( '6-EMAIL', p1, p2 ), profid );
    fetch c1 into c1rec;
    close c1;
    if c1rec.tot > 0
     then
      result := result || voidrec.columns_email || ' ' || LNG5.EXT_TXT_593;
     else
      purchrec.contact_email := getval( '6-EMAIL', p1, p2 );
      purchase_audit_trail( surl, purchrec.poid, 'CONTACT_EMAIL', 'U', 'C', purchrec.contact_email, purchord, voidrec);
    end if;
   else
    purchrec.contact_email := getval( '6-EMAIL', p1, p2 );
    purchase_audit_trail( surl, purchrec.poid, 'CONTACT_EMAIL', 'U', 'C', purchrec.contact_email, purchord, voidrec);
  end if;

  if action = 'ORDER'
   then
    purchrec.do_not_split_order := getcheck( '6-DO_NOT_SPLIT_ORDER', p3 );
    purchrec.manual_ship := getcheck( '6-MANUAL_SHIP', p3 );

    purchase_audit_trail( surl, purchrec.poid, 'DO_NOT_SPLIT_ORDER', 'U', 'C', purchrec.do_not_split_order, purchord, voidrec);
    purchrec.delivery_type := nvl(getval( '6-POSTAGE', p1, p2 ),'S');
    purchase_audit_trail( surl, purchrec.poid, 'DELIVERY_TYPE', 'U', 'C', purchrec.delivery_type, purchord, voidrec);

    purchrec.contact_password := getval( 'OR4', p1, p2 );
    purchase_audit_trail( surl, purchrec.poid, 'CONTACT_PASSWORD', 'U', 'C', purchrec.contact_password, purchord, voidrec);
    purchrec.event_confirmed  := getcheck( 'OR1', p3 );
    purchase_audit_trail( surl, purchrec.poid, 'EVENT_CONFIRMED', 'U', 'C', purchrec.event_confirmed, purchord, voidrec);
    purchrec.event_issue  := getcheck( 'OR2', p3 );
    purchase_audit_trail( surl, purchrec.poid, 'EVENT_ISSUE', 'U', 'C', purchrec.event_issue, purchord, voidrec);
    purchrec.event_shipped  := getcheck( 'OR3', p3 );
    purchase_audit_trail( surl, purchrec.poid, 'EVENT_SHIPPED', 'U', 'C', purchrec.event_shipped, purchord, voidrec);

    -- Purchase Options
    delete from purchase_additional_options where poid = purchrec.poid;
    --insert into temp values('OID:' || voidrec.oid ); commit;
    for c2rec in c2(voidrec.oid) loop
     addoptrec.poid := purchrec.poid;
     addoptrec.merchant_id_code := c2rec.merchant_id_code;
     --insert into temp values('DS:' || c2rec.display_style ); commit;
     if c2rec.display_style = 'C'
      then
       vtxt := getcheck( '[ADDOPT]' || c2rec.merchant_id_code, p3 );
       if vtxt = 'T'
        then
         addoptrec.display_text := c2rec.display_text;
         addoptrec.chosen_price := nvl(glbx.conv_nmb( c2rec.display_prices, 'MONEY' ),0);
        else
         -- Disabled, so do not add to the purchase order
         addoptrec.chosen_price := NULL;
       end if;
      else
       vtxt := getval( '[ADDOPT]' || c2rec.merchant_id_code, p1, p2 );
       addoptrec.display_text := substr(vtxt,2,instr(vtxt,']')-2);
       addoptrec.chosen_price := glbx.conv_nmb( substr(vtxt,instr(vtxt,']')+1), 'MONEY' );
     end if;
     --insert into temp values('DT:' || addoptrec.display_text ); commit;
     --insert into temp values('DP:' || addoptrec.chosen_price ); commit;
     addoptrec.display_receipt_page := c2rec.display_receipt_page;
     addoptrec.display_receipt_custresp := c2rec.display_receipt_custresp;
     addoptrec.customer_comment := getval( '[ADDCOMM]' || c2rec.merchant_id_code, p1, p2 );
     if addoptrec.chosen_price is not null
      then
       insert into purchase_additional_options(poid,merchant_id_code,display_text,chosen_price,display_receipt_page,display_receipt_custresp,customer_comment) values
        (addoptrec.poid,addoptrec.merchant_id_code,addoptrec.display_text,addoptrec.chosen_price,addoptrec.display_receipt_page,addoptrec.display_receipt_custresp,addoptrec.customer_comment);
     end if;
    end loop;

    if purchrec.sendto_country = voidrec.residing_country
     then
      purchrec.local_internation := 'LOCAL';
     else
      purchrec.local_internation := 'INTERNATIONAL';
    end if;

    purchrec.home_country := voidrec.residing_country;


    -- Extract Order Sub Total
    subtotal := glbx.total_payment(purchord.poid);

    -- Determine Discount
    if nvl(subtotal,0) >= nvl(voidrec.pricing_disc_if_gtr,0)
     then
      purchrec.photographer_discount := nvl(voidrec.pricing_discount,0);
    end if;
    purchrec.apply_discount_at := voidrec.pricing_discount_stage;

    -- Determine Tax
    purchrec.other_cost := nvl(voidrec.pricing_gst,0);
    if purchrec.other_cost > 0
     then
      if voidrec.pricing_gst_int_sales = 'F' and
         purchrec.local_internation = 'INTERNATIONAL'
       then
        purchrec.other_cost := 0;
      end if;
    end if;
    -- Is GST Inclusive?
    purchrec.gst_incl := voidrec.pricing_gst_inclusive;

    adjust_postage( purchrec, voidrec, subtotal );

  else

    -- Login
    unsol  := getcheck( '6-UNSOLICITED', p3 );
    update login_session
     set
      guest_email = nvl(guest_email,purchrec.contact_email),
      country = nvl(country,purchrec.sendto_country),
      unsolicited_email = nvl(unsol,'T')
    where
     sessid = purchord.sessid;

  end if;

  update purchase_order
   set
    sendto_name = purchrec.sendto_name,
    sendto_firstname = purchrec.sendto_firstname,
    sendto_lastname = purchrec.sendto_lastname,
    sendto_street = purchrec.sendto_street,
    sendto_suburb = purchrec.sendto_suburb,
    sendto_branch = purchrec.sendto_branch,
    sendto_department = purchrec.sendto_department,
    sendto_city = purchrec.sendto_city,
    sendto_postcode = purchrec.sendto_postcode,
    sendto_state = purchrec.sendto_state,
    sendto_country = purchrec.sendto_country,
    contact_phone = purchrec.contact_phone,
    contact_email = purchrec.contact_email,
    customer_comment = purchrec.customer_comment,
    customer_column1 = purchrec.customer_column1,
    customer_column2 = purchrec.customer_column2,
    customer_column3 = purchrec.customer_column3,
    customer_column4 = purchrec.customer_column4,
    customer_column5 = purchrec.customer_column5,
    customer_column6 = purchrec.customer_column6,
    do_not_split_order = purchrec.do_not_split_order,
    contact_password = purchrec.contact_password,
    event_confirmed = purchrec.event_confirmed,
    event_issue = purchrec.event_issue,
    event_shipped = purchrec.event_shipped,
    local_internation = purchrec.local_internation,
    delivery_type = purchrec.delivery_type,
    photographer_discount = purchrec.photographer_discount,
    other_cost = purchrec.other_cost,
    gst_incl = purchrec.gst_incl,
    apply_discount_at = purchrec.apply_discount_at,
    manual_ship = purchrec.manual_ship
  where
   poid = purchord.poid;

  commit;

  if action = 'ORDER'
   then
    check_col := voidrec.columns_mandatory;
   else
    check_col := voidrec.columns_mandatory_on_login;
  end if;

  check_mandatory(action, check_col, voidrec, purchrec, pfx, result );
  if voidrec.columns_smart_check = 'T'
   then
    smart_check( purchrec, pfx, result );
  end if;

  -- Update Customer Contact Details
  if action = 'LOGIN' and ltype in ('OWNER','PROFILE') and voidrec.columns_update_contact = 'T'
   then
    if ltype = 'OWNER' then accid := cusrec.aid; else accid := profid; end if;
    update customer_contact
    set
     sendto_name        = nvl(purchrec.sendto_name,    sendto_name),
     sendto_firstname   = nvl(purchrec.sendto_firstname,    sendto_firstname),
     sendto_lastname    = nvl(purchrec.sendto_lastname,    sendto_lastname),
     sendto_street  	= nvl(purchrec.sendto_street,  sendto_street),
     sendto_branch  	= nvl(purchrec.sendto_branch,  sendto_branch),
     sendto_department 	= nvl(purchrec.sendto_department,  sendto_department),
     sendto_suburb  	= nvl(purchrec.sendto_suburb,  sendto_suburb),
     sendto_city    	= nvl(purchrec.sendto_city,    sendto_city),
     sendto_postcode	= nvl(purchrec.sendto_postcode,sendto_postcode),
     sendto_state	= nvl(purchrec.sendto_state,   sendto_state),
     sendto_country 	= nvl(purchrec.sendto_country, sendto_country),
     contact_phone  	= nvl(purchrec.contact_phone,  contact_phone),
     contact_email      = nvl(purchrec.contact_email,  contact_email)
    where
     aid = accid and
     login_type = ltype;
  end if;

exception when others then
 glbx.error_details( 'FNAME', 'PROCESS_DATA_ENTERED',errmsg=>sqlerrm );
end process_data_entered;

procedure pay_certificate( surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null)
as

 cursor c3(vpoid integer) is select gc.certificate_id,date_used,value,amount_used,expiry_date from gift_certificate_usage gcu, gift_certificate gc where gc.certificate_id = gcu.certificate_id and poid = vpoid;
 cursor c4(certid integer) is select * from gift_certificate where certificate_id = certid;

 certrec	c4%ROWTYPE;
 ttl		number;
 foundrec	boolean;
 txt		varchar2(100);
 purch2		purchase_order%ROWTYPE;

begin

 ttl := glbx.grand_total_payment( purch.poid, include_gift_certificate=>FALSE );

 -- If the Order has been fully paid up then progress to the next screen
 if glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE ) = 0
  then
    update purchase_order
     set
     paid_method = 'GIFT',
     status = LNG.ORD_TXT_121,
     date_purchased = sysdate,
     last_step = 'Pay_Certificate'
    where poid = purch.poid;
    purchase_audit_trail( surl, purch.poid, 'PAID_METHOD', 'U', 'C', 'GIFT', purch2, voidrec);
    purch2 := purch;
    purch2.paid_method := 'GIFT';
    purchase_audit_trail( surl, purch.poid, 'STATUS', 'U', 'C', LNG.ORD_TXT_121, purch2, voidrec);
    purchase_audit_trail( surl, purch.poid, 'LAST_STEP', 'U', 'C', 'Pay_Certificate', purch2, voidrec);
    commit;
   return;
 end if;

 if voidrec.disp_purch_request_heading = 'T'
  then
   txt := LNG4.AHC_TXT_691 || ':' || purch.poid;
  else
   txt := LNG4.AHC_TXT_691;
 end if;
 glbx.main_title( surl, txt, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'O23',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=' || pfx.ord_text_table_borderi );
 htp.tablerowopen;
 htp.p( '<TD valign="TOP">' );

 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=' || pfx.ord_text_table_borderi );
  htp.tablerowopen;
   htp.tabledata( LNG4.AHC_TXT_723, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( to_char(ttl, LNG.MONEY_FORMAT ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"');
  htp.tablerowclose;
  foundrec := FALSE;
  for c3rec in c3(purch.poid) loop
   foundrec := TRUE;
   htp.tablerowopen;
    htp.tabledata( LNG4.AHC_TXT_527, cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.anchor2( 'fname.cert_history?surl=' || surl || '&certid=' || glbx.encrypt_data(c3rec.certificate_id) || '&acid=' || acid,glbx.encrypt_data(c3rec.certificate_id),ctarget=>'CERTIFICATE_WINDOW') || htf.nl ||
                   to_char(c3rec.amount_used, LNG.MONEY_FORMAT ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"');
   htp.tablerowclose;
   open c4( c3rec.certificate_id );
   fetch c4 into certrec;
   close c4;
   ttl := ttl - nvl(c3rec.amount_used,0);
  end loop;
  -- Remaining Order Total to be Paid
  if foundrec
   then
    htp.tablerowopen;
     htp.tabledata( LNG4.AHC_TXT_722, cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( to_char(ttl, LNG.MONEY_FORMAT ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"');
    htp.tablerowclose;
  end if;
 htp.tableclose;

 htp.p( '</TD>' );

 htp.p( '<TD valign="TOP">' );
 htp.bold( LNG4.AHC_TXT_724  );
 htp.nl;
 htp.formopen( 'fname.accept_pay_certificate' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.formhidden( 'ACID', acid );
 htp.formtext( 'P1', 44, 32 );
 htp.nl;
 htp.bold( LNG4.AHC_TXT_725 || ' $' );
 htp.formtext( 'P2', 14, 12 );
 htp.nl;
 htp.formsubmit( null, nvl(voidrec.text_gift_message,LNG4.AHC_TXT_721) );
 htp.formclose;
 htp.p( '</TD>' );
 htp.tablerowclose;

 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );
exception when others then
 glbx.error_details( 'FNAME', 'PAY_CERTIFICATE',null,acid,errmsg=>sqlerrm);
end pay_certificate;

procedure accept_pay_certificate( surl in varchar2, acid in integer, p1 in varchar2, p2 in varchar2 )
as

 cursor c3(vpoid integer) is select sum(amount_used) sm from gift_certificate_usage where poid = vpoid;

 cusrec		CUSTOMER_ACCOUNT%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	THEME_TYPES%ROWTYPE;
 purchord 	PURCHASE_ORDER%ROWTYPE;
 voidrec	ORDER_STYLE%ROWTYPE;
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 ltype		varchar2(100);
 cert_rec	GIFT_CERTIFICATE%ROWTYPE;
 err		varchar2(200);
 nmb 		number;
 ttl		number;
 lft		number;


begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNM.ACCEPT_PAY_CERTIFICATE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
 -- Business Feature overriden, get the other one
 if voidrec.bftr <> 'Use Customer Account Business Feature'
  then
   theme_rec := glbx.get_theme_types( voidrec.bftr );
 end if;

 if voidrec.laf <> 'Use Customer Account Look and Feel'
  then
   pfx := glbx.get_thm( voidrec.laf );
 end if;


 if not glbx.certificate_validate( p1, cusrec.aid, cert_rec, err )
  then
    pay_certificate( sess_id, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, err);
    return;
 end if;

 -- Check if P2 is less than amount left
 ttl := glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE );

 lft := glbx.certificate_remaining( cert_rec.certificate_id );

 if p2 is null
  then
   nmb := ttl;
  else
   nmb := glbx.conv_nmb( p2 );
 end if;

 if nmb > ttl
  then
   nmb := ttl;
 end if;

 if lft > ttl
  then
   lft := ttl;
 end if;

 if nmb > lft
  then
   nmb := lft;
 end if;

 insert into gift_certificate_usage(certificate_id,date_used,amount_used,poid,aid) values
  (cert_rec.certificate_id,sysdate,nmb,purchord.poid,cusrec.aid);

 commit;

 pay_certificate( sess_id, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, 'Gift Certificate Used');

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_PAY_CERTIFICATE',null,acid,errmsg=>sqlerrm);
end accept_pay_certificate;

procedure cert_history( surl in varchar2, certid in varchar2, acid in integer )
as

 cusrec		CUSTOMER_ACCOUNT%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	THEME_TYPES%ROWTYPE;
 purchord 	PURCHASE_ORDER%ROWTYPE;
 voidrec	ORDER_STYLE%ROWTYPE;
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 ltype		varchar2(100);
 ttl		number;
 err		varchar2(200);
 foundrec	boolean;
 cert_rec	GIFT_CERTIFICATE%ROWTYPE;
 ord_exists	boolean;
 grand_ttl	number;

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNM.CERT_HISTORY' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
 -- Business Feature overriden, get the other one
 if voidrec.bftr <> 'Use Customer Account Business Feature'
  then
   theme_rec := glbx.get_theme_types( voidrec.bftr );
 end if;

 if voidrec.laf <> 'Use Customer Account Look and Feel'
  then
   pfx := glbx.get_thm( voidrec.laf );
 end if;

 glbx.main_title( surl, LNG4.AHC_TXT_719,glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'O23',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 if not glbx.certificate_validate( certid, cusrec.aid, cert_rec, err )
  then
   htp.bold( err );
   return;
 end if;
 htp.p( '<CENTER>' );
 glbx.certificate_history( cert_rec, pfx );
 htp.nl;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
 htp.nl;
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'FNAME', 'CERT_HISTORY',null,acid,errmsg=>sqlerrm);
end cert_history;

procedure accept_purchase(surl in varchar2, paychoice in varchar2, acid in integer, p1 in varchar2 default null )
as

 cusrec		CUSTOMER_ACCOUNT%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	THEME_TYPES%ROWTYPE;
 purchord 	PURCHASE_ORDER%ROWTYPE;
 voidrec	ORDER_STYLE%ROWTYPE;
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 ltype		varchar2(100);
 ord_exists	boolean;
 grand_ttl	number;
 empty_array	GLBX.MYARRAY;

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNM.ACCEPT_PURCHASE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
 if is_not_preorder( purchord )
  then
   recalc_order( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
   return;
 end if;
 -- Business Feature overriden, get the other one
 if voidrec.bftr <> 'Use Customer Account Business Feature'
  then
   theme_rec := glbx.get_theme_types( voidrec.bftr );
 end if;

 if voidrec.laf <> 'Use Customer Account Look and Feel'
  then
   pfx := glbx.get_thm( voidrec.laf );
 end if;

 if paychoice = 'CERTIFICATE'
  then
   purchord.paid_method := 'CERTIFICATE';
   pay_certificate( surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, null);

 elsif paychoice = 'AUTHORISATION'
  then
   update purchase_order
    set
     paid_method = 'AUTHORISATION',
     project_code = p1
   where
    poid = purchord.poid;
   purchase_audit_trail( surl, purchord.poid, 'PROJECT_CODE', 'U', 'C', p1, purchord, voidrec);

   purchord.paid_method := 'AUTHORISATION';
   pay_authorisation( surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, null);
   -- Check if there is the need to exit
   if voidrec.disp_receipt = 'T' and pfx.order_show_receipt is not null
    then
     return;
   end if;

 elsif paychoice = 'PHONE'
  then
   purchord.paid_method := 'PHONE';
   pay_phone( surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, null);
   if voidrec.columns_swap_pay_confirm = 'T'
    then
     goto bypass_label; -- Its easier to use than coding in a complex if-then-else
   end if;

 elsif voidrec.columns_swap_pay_confirm = 'T'
  then
   -- Have already gone through the confirm page, go straight to the final receipt page
   empty_array(1) := NULL;
   update purchase_order
    set
     paid_method = paychoice
   where poid = purchord.poid;
   purchase_audit_trail( surl, purchord.poid, 'PAID_METHOD', 'U', 'C', paychoice, purchord, voidrec);
   purchord.paid_method := paychoice;
   confirm_payment( surl, acid=>acid, p1=>empty_array, p2=>empty_array, typ=>paychoice );
   return;

 elsif paychoice = 'CHEQUE' and voidrec.payment_cheque_noconfirm = 'T'
  then
   purchord.paid_method := 'CHEQUE';
   pay_cheque( surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, null);

 elsif paychoice = 'BILLING'
  then
   purchord.paid_method := 'BILLING';
   pay_billing( surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, null);

 end if;

 -- Call Summary of Order Screen
 disp_confirm_page( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, null );

 if paychoice = 'CHEQUE' and voidrec.payment_cheque_button_loc in ('B','Z') and voidrec.payment_cheque_noconfirm = 'T'
  then
   htp.formopen( 'fname.confirm_payment' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ACID', acid );
   htp.formhidden( 'P1',null);
   htp.formhidden( 'P2',null);
   htp.formhidden( 'TYP','CHEQUE');
   htp.formsubmit( null, voidrec.text_confirm_button );
   htp.formclose;
 end if;

 -- If the call is to bypass the cheque confirm page, then go straight to the receipt page.
 if paychoice = 'CHEQUE' and voidrec.payment_cheque_noconfirm = 'F'
  then
   htp.init;
   update purchase_order set paid_method = 'CHEQUE' where poid = purchord.poid;
   purchase_audit_trail( surl, purchord.poid, 'PAID_METHOD', 'U', 'C', 'CHEQUE', purchord, voidrec);
   commit;
   empty_array(1) := NULL;
   confirm_payment( surl, acid=>acid, p1=>empty_array, p2=>empty_array, typ=>'CHEQUE' );
   return;
 end if;

 <<BYPASS_LABEL>>

 if pfx.ord_inc_simple = 'T'
  then
    cst.disp_standard_search(surl, stype, ltype, profid, acid, cusrec, pfx, theme_rec, 'SIMPLE' );
    if pfx.ord_inc_privacy = 'T' then htp.nl; end if;
 end if;

 if pfx.ord_inc_privacy = 'T'
  then
    cst.disp_privacy(surl, ltype, profid, acid, cusrec, pfx, theme_rec );
 end if;

 if pfx.order_bottom_external is not null
  then
    execute immediate
      'begin ' || pfx.order_bottom_external ||
       '(surl=>:surl,ltype=>:ltype,acid=>:acid,screen_location=>:screen_location);' ||
       'end;'
     using glbx.rndsurl(surl),ltype,acid,'HANDLE_PAYMENT';
 end if;
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_PURCHASE',null,acid,errmsg=>sqlerrm,extdet=>'PAYCHOICE:' || paychoice);
end accept_purchase;

procedure pay_phone(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null)
as

 cursor c1(purchid integer) is select * from order_contact_phone_number where poid = purchid;
 cursor c3(phid integer) is select * from photographer where pid = phid;

 c3rec		c3%ROWTYPE;
 c1notfound	boolean;
 txt		varchar2(100);
 retlink	varchar2(1000);

begin
 --retlink := return_link( surl, stype, ltype, voidrec, pfx, acid, location=>'2' );
 if voidrec.disp_purch_request_heading = 'T'
  then
   txt := voidrec.text_page4 || ':' || 'Payment by Phone' || ' [' || purch.poid || ']';
  else
   txt := voidrec.text_page4 || ':' || 'Payment by Phone';
 end if;
 glbx.main_title( surl, txt, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'O04',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,retlink=>retlink,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 if voidrec.columns_swap_pay_confirm = 'F'
  then
   disp_tracing_style(surl, stype, voidrec, pfx, purch, 'HANDLE_PAYMENT', acid, ltype, theme_rec );
  else
   disp_tracing_style(surl, stype, voidrec, pfx, purch, 'PAYMENT_METHOD', acid, ltype, theme_rec );
 end if;
 htp.nl;
 if voidrec.text_phg_title is not null then htp.bold( voidrec.text_phg_title ); htp.nl; end if;

 open c3(cusrec.pid);
 fetch c3 into c3rec;
 close c3;

 if voidrec.payment_phone_ring = 'F'
  then
   htp.bold( LNG.CST_TXT_104 ); htp.nl;
   htp.italic(LNG.CST_TXT_107); htp.nl;
   check_business_hours( surl, acid, c3rec, voidrec );
   htp.nl;
   htp.bold(LNG.ORD_TXT_037);
  else
   check_business_hours( surl, acid, c3rec, voidrec );
   htp.nl;
   htp.bold(LNG3.ADM_TXT_956);
 end if;

 if purch.sendto_country <> purch.home_country
  then
   htp.nl;
   htp.nl;
   htp.bold( LNG.ORD_TXT_214 || ': ' || purch.sendto_country );
 end if;

 htp.formopen( 'fname.confirm_payment' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'TYP','PHONE');
 htp.formhidden( 'P1',null);
 htp.formhidden( 'P2',null);
 update purchase_order set paid_method = 'PHONE' where poid = purch.poid;
 purchase_audit_trail( surl, purch.poid, 'PAID_METHOD', 'U', 'C', 'PHONE', purch, voidrec);
 commit;
 htp.tableopen( cattributes=>'cellpadding=4 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold( lng.CST_TXT_108 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( htf.bold( lng.CST_TXT_109 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
  htp.tablerowclose;
  c1notfound := TRUE;
  for c1rec in c1(purch.poid) loop
  c1notfound := FALSE;
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1', 20,20,c1rec.pnumber), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( htf.formtext( 'P2', 40,200,c1rec.contact_det), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  end loop;
  for j in 1..3 loop
  htp.tablerowopen;
   if j = 1 and c1notfound
    then
     htp.tabledata( htf.formtext( 'P1', 20,20,purch.contact_phone), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    else
     htp.tabledata( htf.formtext( 'P1', 20,20,null), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
   end if;
   htp.tabledata( htf.formtext( 'P2', 40,200,null), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, voidrec.text_confirm_button );
 htp.formclose;

exception when others then
 glbx.error_details( 'FNAME', 'PAY_PHONE',null,acid,errmsg=>sqlerrm);
end pay_phone;

procedure check_business_hours( surl varchar2, acid in integer, crec in photographer%ROWTYPE, voidrec in order_style%ROWTYPE )
as
 currhour	integer;
 currday	integer;
begin
 -- double check charge plan is piction
 currhour := to_number(to_char(sysdate,'HH24'));
 currday := to_number(to_char(sysdate,'D'));
 htp.nl;
 htp.bold( voidrec.text_phone_message );
 htp.nl;

 if ((currhour < nvl(crec.business_hours_min,8)) or
    (currhour > nvl(crec.business_hours_max,16))) or
    (substr(crec.business_days,currday,1) = 'F')
  then
   if voidrec.payment_phone_ring = 'T'
    then
     htp.italic( LNG.CST_TXT_093 || to_char(sysdate,LNG.TSMASK) );
     htp.nl;
     htp.strong( replace(LNG2.FNM_TXT_123,'<PHOTOGRAPHER>', crec.photographer_title ) );
    else
     htp.italic( LNG.CST_TXT_093 || to_char(sysdate,LNG.TSMASK) );
     htp.nl;
     htp.strong( LNG.CST_TXT_094 );
     htp.nl;
     htp.strong( LNG.CST_TXT_095 );
   end if;
  else
   if voidrec.payment_phone_ring = 'T'
    then
     htp.bold( replace(LNG2.FNM_TXT_122,'<PHOTOGRAPHER>',crec.photographer_title) || ' : ' || crec.work_phone);
   end if;
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'CHECK_BUSINESS_HOURS',errmsg=>sqlerrm);
end check_business_hours;

procedure pay_cheque(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null)
as
 txt	 varchar2(100);
 retlink varchar2(1000);
begin

 --retlink := return_link( surl, stype, ltype, voidrec, pfx, acid , location=>'2');
 if voidrec.disp_purch_request_heading = 'T'
  then
   txt := voidrec.text_page4 || ':' || 'Payment using Cheque' || ' [' || purch.poid || ']';
  else
   txt := voidrec.text_page4 || ':' || 'Payment using Cheque';
 end if;
 glbx.main_title( surl, txt, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'O04',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,retlink=>retlink,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 disp_tracing_style(surl, stype, voidrec, pfx, purch, 'HANDLE_PAYMENT', acid, ltype, theme_rec );
 if voidrec.text_phg_title is not null then htp.bold( voidrec.text_phg_title ); htp.nl; end if;

 if voidrec.payment_cheque_button_loc in ('T','Z')
  then
   htp.formopen( 'fname.confirm_payment' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ACID', acid );
   htp.formhidden( 'P1',null);
   htp.formhidden( 'P2',null);
   htp.formhidden( 'TYP','CHEQUE');
   htp.formsubmit( null, voidrec.text_confirm_button );
   htp.formclose;
 end if;
 update purchase_order set paid_method = 'CHEQUE' where poid = purch.poid;
 purchase_audit_trail( surl, purch.poid, 'PAID_METHOD', 'U', 'C', 'CHEQUE', purch, voidrec);
 commit;
exception when others then
 glbx.error_details( 'FNAME', 'PAY_CHEQUE',null,acid,errmsg=>sqlerrm);
end pay_cheque;

procedure pay_authorisation(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null)
as

 cursor c1( ttl number, sess_id integer, profid integer) is
  select /*+ RULE */ cp.profile_id,cp.username
  from customer_profile cp, login_session ls, customer_profile cp2
  where sysdate >= nvl(cp.authority_valid_from,sysdate-1) and
        sysdate <= nvl(cp.authority_valid_to,sysdate+1) and
         (
          (ttl <= nvl(cp.authority_limit,ttl+1) and cp.attribute_id is null) or
          (cp.attribute_id is not null)
        ) and
       cp.authority_own_request = 'A' and
        cp.profile_id = profid and
        ls.sessid = sess_id and
        ls.aid = cp2.profile_id and
        (((cp.request_authority = 'A') and (cp.pid = cp2.pid)) or
         ((cp.request_authority = 'B') and (cp.aid = cp2.aid)) or
         ((cp.request_authority = 'D') and (cp.profile_id = cp2.profile_id)) or
         ((cp.request_authority = 'C') and (cp.profile_id,cp2.profile_id) in (select mgmt_profile_id,profile_id from profile_purchase_authority))
        );

 cursor c11( ttl number, sess_id integer, profid integer) is
  select /*+ RULE */ cp.profile_id,cp.username
  from customer_profile cp, login_session ls, customer_profile cp2
  where sysdate >= nvl(cp.authority_valid_from,sysdate-1) and
        sysdate <= nvl(cp.authority_valid_to,sysdate+1) and
         (
          (ttl <= nvl(cp.authority_limit,ttl+1) and cp.attribute_id is null) or
          (cp.attribute_id is not null)
        ) and
       (cp.authority_own_request in ('T','A') or not(cp.authority_own_request = 'F' and cp.profile_id = profid)) and
        ls.sessid = sess_id and
        ls.aid = cp2.profile_id and
        (((cp.request_authority = 'A') and (cp.pid = cp2.pid)) or
         ((cp.request_authority = 'B') and (cp.aid = cp2.aid)) or
         ((cp.request_authority = 'D') and (cp.profile_id = cp2.profile_id)) or
         ((cp.request_authority = 'C') and (cp.profile_id,cp2.profile_id) in (select mgmt_profile_id,profile_id from profile_purchase_authority))
        )
  order by cp.username;

 cursor c11t( ttl number, sess_id integer, profid integer) is
  select /*+ RULE */ count('x') tot
  from customer_profile cp, login_session ls, customer_profile cp2
  where sysdate >= nvl(cp.authority_valid_from,sysdate-1) and
        sysdate <= nvl(cp.authority_valid_to,sysdate+1) and
        (
          (ttl <= nvl(cp.authority_limit,ttl+1) and cp.attribute_id is null) or
          (cp.attribute_id is not null)
        ) and
        (cp.authority_own_request in ('T','A') or not(cp.authority_own_request = 'F' and cp.profile_id = profid)) and
        ( (cp.authority_limit is null) or
          (ttl <= ( cp.authority_limit - 0))
        ) and
        ls.sessid = sess_id and
        ls.aid = cp2.profile_id and
        (((cp.request_authority = 'A') and (cp.pid = cp2.pid)) or
         ((cp.request_authority = 'B') and (cp.aid = cp2.aid)) or
         ((cp.request_authority = 'D') and (cp.profile_id = cp2.profile_id)) or
         ((cp.request_authority = 'C') and (cp.profile_id,cp2.profile_id) in (select mgmt_profile_id,profile_id from profile_purchase_authority))
        );

 cursor c12(profid integer, ltype varchar2) is select * from customer_contact where aid = profid and login_type = ltype;

 c1rec		c1%ROWTYPE;
 c11trec	c11t%ROWTYPE;
 c12rec		c12%ROWTYPE;
 txt		varchar2(100);
 retlink	varchar2(1000);
 tmp		varchar2(32767);
 empty_array	GLBX.MYARRAY;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin

 --retlink := return_link( surl, stype, ltype, voidrec, pfx, acid, location=>'2' );
 if voidrec.disp_purch_request_heading = 'T'
  then
   txt := voidrec.text_page4 || ':' || 'Payment using Authorisation' || ' [' || purch.poid || ']';
  else
   txt := voidrec.text_page4 || ':' || 'Payment using Authorisation';
 end if;
 glbx.main_title( surl, txt, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'O04',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,retlink=>retlink,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 disp_tracing_style(surl, stype, voidrec, pfx, purch, 'HANDLE_PAYMENT', acid, ltype, theme_rec );
 htp.nl;
 if voidrec.text_phg_title is not null then htp.bold( voidrec.text_phg_title ); htp.nl; end if;
 open c11t(glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE ),sess_id,profid);
 fetch c11t into c11trec;
 close c11t;
 if c11trec.tot = 0
  then

   glbx.header_msg(LNG4.AHC_TXT_703);

  else

   open c1(c11trec.tot, sess_id, profid);
   fetch c1 into c1rec;
   if c1%FOUND
    then
     close c1;
     -- Automatically Progress the Payment
     htp.init;
     empty_array(1) := NULL;
     update purchase_order set paid_method = 'AUTHORISATION',status = 'Order Authorised',authorised_by = profid,date_purchased = sysdate  where poid = purch.poid;
     purchase_audit_trail( surl, purch.poid, 'PAID_METHOD', 'U', 'C', 'AUTHORISATION', purch, voidrec);
     purchase_audit_trail( surl, purch.poid, 'STATUS', 'U', 'C', 'Order Authorised', purch, voidrec);
     commit;
     confirm_payment(surl, acid, 'AUTHORISATION', empty_array, empty_array );
     return;
   end if;
   close c1;

   glbx.header_msg(LNG4.AHC_TXT_702);

   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=' || pfx.ord_text_table_borderi );
   for c11rec in c11( c11trec.tot, sess_id, profid ) loop
    htp.tablerowopen;
     htp.tabledata( c11rec.username );
     open c12(c11rec.profile_id,'PROFILE');
     fetch c12 into c12rec;
     if c12%FOUND
      then
       close c12;
       htp.tabledata( nvl(c12rec.sendto_name,'&nbsp;' ) );
       htp.tabledata( nvl(c12rec.contact_phone,'&nbsp;' ) );
       if c12rec.contact_email is null
        then
         htp.tabledata( '&nbsp;' );
        else
         htp.tabledata( htf.mailto(c12rec.contact_email,c12rec.contact_email ) );
         tmp := tmp || ',' || c12rec.contact_email;
       end if;
      else
       close c12;
       htp.tabledata( '&nbsp;' );
       htp.tabledata( '&nbsp;' );
       htp.tabledata( '&nbsp;' );
     end if;
    htp.tablerowclose;
   end loop;
   if tmp is not null
    then
     gcode(1) := 'PURCHASE_ORDER_ID';
     gparam(1) := purch.poid;
     gcode(2) := 'CURRTIME';
     gparam(2) := to_char(sysdate,LNG.TSMASK);
     gcode(3) := 'USERNAME';
     gparam(3) := cusrec.username;
     gcode(4) := 'TOTAL';
     gparam(4) := to_char(glbx.grand_total_payment( purch.poid, TRUE ), LNG.MONEY_FORMAT );
     gcode(5) := 'SIGNATURE';
     gparam(5) := glbx.extract_master_parameter('MAIL SIGNATURE');
     add_poid_values( purch.poid, gcode, gparam );
     glbx.send( gcode, gparam, 'order_authorised_notify.tmp', p_to=>substr(tmp,2),p_subj=>LNG5.EXT_TXT_594 || ':' || purch.poid,p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'OAN1', v_pid=>cusrec.pid, v_aid=>cusrec.aid, v_profile_id=>profid);
   end if;
   htp.tableclose;
   htp.nl;

 end if;

 htp.formopen( 'fname.confirm_payment' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'P1',null);
 htp.formhidden( 'P2',null);
 htp.formhidden( 'TYP', 'AUTHORISATION');
 htp.nl;
 htp.formsubmit( null, voidrec.text_confirm_button );
 htp.formclose;
 update purchase_order set paid_method = 'AUTHORISATION' where poid = purch.poid;
 purchase_audit_trail( surl, purch.poid, 'PAID_METHOD', 'U', 'C', 'AUTHORISATION', purch, voidrec);
 commit;

exception when others then
 glbx.error_details( 'FNAME', 'PAY_AUTHORISATION',null,acid,errmsg=>sqlerrm);
end pay_authorisation;

procedure pay_billing(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null)
as

 cursor c3(phid integer) is select * from photographer where pid = phid;

 c3rec		c3%ROWTYPE;
 c1notfound	boolean;

begin
 open c3(cusrec.pid);
 fetch c3 into c3rec;
 close c3;
 disp_tracing_style(surl, stype, voidrec, pfx, purch, 'HANDLE_PAYMENT', acid, ltype, theme_rec );

exception when others then
 glbx.error_details( 'FNAME', 'PAY_BILLING',null,acid,errmsg=>sqlerrm);
end pay_billing;

procedure accept_pay_by_credit( surl varchar2, CreditCardNumber in varchar2 default null, CreditCardType in varchar2 default null, ExpirationYear in varchar2 default null, ExpirationMonth in varchar2 default null, ExpirationDay in varchar2 default null, cc4 in varchar2 default null, HomeURL in varchar2 default null )
as

 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 sts		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 acid 		integer;
 nmb		integer;
 vsurl		varchar2(100);
 empty_array	GLBX.MYARRAY;

begin
if surl is null
 then
  vsurl := substr(homeurl,7,22);
 else
  vsurl := surl;
end if;

glbx.cookie_id( vsurl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.ACCEPT_PAY_BY_CREDIT' );
if sts is not null
 then
  htp.nl;htp.bold( LNG5.EXT_TXT_595 || ':' ); htp.nl; htp.nl;
  htp.bold( 'VSURL:' || vsurl ); htp.nl;
  htp.bold( 'SURL:' || surl ); htp.nl;
  htp.bold( 'STS:' || sts ); htp.nl;
  htp.bold( 'HOMEURL:' || homeurl ); htp.nl;
  return;
end if;

 acid := find_acid(sess_id);
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 delete from credit_card where poid = purchord.poid;
 insert into credit_card(poid,card_number,card_type,card_expiry,card_name) values
  (purchord.poid, CreditCardNumber, CreditCardType, substr(ExpirationYear || '-' || ExpirationMonth,1,10), substr(cc4,1,100) );

 select s_purchase_order_merch_ref.nextval into nmb from dual;
 update purchase_order
  set
   paid_method = 'MERCHANT',
   merchant_reference = nmb,
   status = 'Order Payment Received',
   date_purchased = sysdate,
   last_step = 'Step 7'
 where poid = purchord.poid;

 purchase_audit_trail( vsurl, purchord.poid, 'PAID_METHOD', 'U', 'C', 'MERCHANT', purchord, voidrec);
 purchord.paid_method := 'MERCHANT';
 purchase_audit_trail( vsurl, purchord.poid, 'MERCHANT_REFERENCE', 'U', 'C', to_char(nmb), purchord, voidrec);
 purchase_audit_trail( vsurl, purchord.poid, 'STATUS', 'U', 'C', 'Order Payment Received', purchord, voidrec);
 purchase_audit_trail( vsurl, purchord.poid, 'LAST_STEP', 'U', 'C', 'Step 7', purchord, voidrec);

 --finalise_payment(surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, null );
 confirm_payment( vsurl, acid, null, empty_array, empty_array );

exception when others then
 glbx.error_details( 'ORD', 'ACCEPT_PAY_BY_CREDIT',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end accept_pay_by_credit;

procedure accept_merchant(surl varchar2,sys_response_code in varchar2 default null, sys_response_text in varchar2 default null, sys_settlement_date in varchar2 default null, sys_rrn in varchar2 default null)
as

 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 sts		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 acid 		integer;
 nmb		integer;
 empty_array	GLBX.MYARRAY;

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.ACCEPT_MERCHANT' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 acid := find_acid(sess_id);
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 select s_purchase_order_merch_ref.nextval into nmb from dual;
 check_credit_already_done( purchord.poid );
 update purchase_order
  set
   paid_method = 'MERCHANT',
   m_response_code = substr(sys_response_code,1,1000),
   m_response_text = substr(sys_response_text,1,4000),
   m_settlement_date = substr(sys_settlement_date,1,1000),
   m_rrn = substr(sys_rrn,1,1000),
   status = 'Order Payment Received',
   date_purchased = sysdate,
   merchant_reference = nmb,
   payment_received = 'T',
   last_step = 'Step 7'
 where poid = purchord.poid;

 calc_due_date( purchord.poid );
 purchase_audit_trail( surl, purchord.poid, 'PAID_METHOD', 'U', 'C', 'MERCHANT', purchord, voidrec);
 purchord.paid_method := 'MERCHANT';
 purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_CODE', 'U', 'C', substr(sys_response_code,1,1000), purchord, voidrec);
 purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_TEXT', 'U', 'C', substr(sys_response_text,1,4000), purchord, voidrec);
 purchase_audit_trail( surl, purchord.poid, 'M_SETTLEMENT_DATE', 'U', 'C', substr(sys_settlement_date,1,1000), purchord, voidrec);
 purchase_audit_trail( surl, purchord.poid, 'M_RRN', 'U', 'C', substr(sys_rrn,1,1000), purchord, voidrec);
 purchase_audit_trail( surl, purchord.poid, 'MERCHANT_REFERENCE', 'U', 'C', to_char(nmb), purchord, voidrec);
 purchase_audit_trail( surl, purchord.poid, 'STATUS', 'U', 'C', 'Order Payment Received', purchord, voidrec);
 purchase_audit_trail( surl, purchord.poid, 'PAYMENT_RECEIVED', 'U', 'C', 'T', purchord, voidrec);
 purchase_audit_trail( surl, purchord.poid, 'LAST_STEP', 'U', 'C', 'Step 7', purchord, voidrec);

 if glbx.extract_master_parameter('MERCHANT_POP_WINDOW') = 'TRUE'
  then
   htp.p('<HTML><HEAD></HEAD><BODY ONLOAD="javascript: parent.opener.location = ''' || 'fname.confirm_payment?surl=' || surl || '&acid=' || acid || '&typ=&p1=&p2=' || '''; parent.close();"></BODY></HTML>' );
  else
   confirm_payment( surl, acid, null, empty_array, empty_array );
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_MERCHANT',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end accept_merchant;

procedure accept_merchant_anz( surl varchar2, wrk in varchar2 default 'T', transactionDate in varchar2 default null, transactionTime in varchar2 default null, ordernumber in varchar2 default null, authorisationCode in varchar2 default null, responsecode in varchar2 default null, responseText in varchar2 default null, amountPaid in varchar2 default null, transactionRef in varchar2 default null, orderDescription in varchar2 default null, cardname in varchar2 default null )
as

 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 sts		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 acid 		integer;
 nmb		integer;
 empty_array	GLBX.MYARRAY;

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.ACCEPT_MERCHANT_ANZ');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 acid := find_acid(sess_id);
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 if upper(substr(wrk,1,1)) = 'T' or
    upper(responseText) = 'APPROVED' or
    trim(responsecode) in ('0','00','8','08','11','77')
  then
   check_credit_already_done( purchord.poid );
   select s_purchase_order_merch_ref.nextval into nmb from dual;
   update purchase_order
    set
     paid_method = 'MERCHANT',
     m_response_code = substr(transactionRef,1,1000),
     m_response_text = substr(responsecode || '-' || responseText,1,4000),
     m_settlement_date = substr(wrk,3) || substr(transactionDate,1,500) || substr(transactionTime,1,500),
     m_rrn = substr(authorisationCode,1,1000),
     status = 'Order Payment Received',
     date_purchased = sysdate,
     payment_received = 'T',
     merchant_reference = nmb,
     last_step = 'Step 7'
   where poid = purchord.poid;

   calc_due_date( purchord.poid );
   purchase_audit_trail( surl, purchord.poid, 'PAID_METHOD', 'U', 'C', 'MERCHANT', purchord, voidrec);
   purchord.paid_method := 'MERCHANT';
   purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_CODE', 'U', 'C', substr(transactionRef,1,1000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_TEXT', 'U', 'C', substr(responsecode || '-' || responseText,1,4000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'M_SETTLEMENT_DATE', 'U', 'C', substr(wrk,3) || substr(transactionDate,1,500) || substr(transactionTime,1,500), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'M_RRN', 'U', 'C', substr(authorisationCode,1,1000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'MERCHANT_REFERENCE', 'U', 'C', to_char(nmb), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'STATUS', 'U', 'C', 'Order Payment Received', purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'PAYMENT_RECEIVED', 'U', 'C', 'T', purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'LAST_STEP', 'U', 'C', 'Step 7', purchord, voidrec);

 else

  insert into audit_failed_merchant(poid,date_created,m_response_code,m_response_text,m_settlement_date,m_rrn) values
  (purchord.poid,sysdate,substr(transactionRef,1,1000),substr(responsecode || '-' || responseText,1,4000),substr(wrk,3) || substr(transactionDate,1,500) || substr(transactionTime,1,500),substr(authorisationCode,1,1000));
  commit;
  failed_credit_card(surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, responsetext );
  return;

 end if;

 if glbx.extract_master_parameter('MERCHANT_POP_WINDOW') = 'TRUE'
  then
   htp.p('<HTML><HEAD></HEAD><BODY ONLOAD="javascript: parent.opener.location = ''' || 'fname.confirm_payment?surl=' || surl || '&acid=' || acid || '&typ=&p1=&p2=' || '''; parent.close();"></BODY></HTML>' );
  else
   confirm_payment( surl, acid, null, empty_array, empty_array );
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_MERCHANT_ANZ',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end accept_merchant_anz;

procedure accept_merchant_anz_ii( merchtxnref in varchar2 default null, orderinfo in varchar2 default null, merchantid in varchar2 default null, purchaseamountinteger in varchar2 default null, locale in varchar2 default null, receiptno in varchar2 default null, qsiresponsecode in varchar2 default null, acqresponsecode in varchar2 default null, transactiono in varchar2 default null, authorizeid in varchar2 default null, batchno in varchar2 default null, cardtype in varchar2 default null )
as

 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 sts		varchar2(100);
 surl 		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 acid 		integer;
 nmb		integer;
 empty_array	GLBX.MYARRAY;

begin
 surl := orderinfo;
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.ACCEPT_MERCHANT_ANZ_II');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 acid := find_acid(sess_id);
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 if trim(qsiresponsecode) in ('0','00')
  then
   check_credit_already_done( purchord.poid );
   select s_purchase_order_merch_ref.nextval into nmb from dual;
   update purchase_order
    set
     paid_method = 'MERCHANT',
     m_response_code = substr(qsiresponsecode || '-' || acqresponsecode ,1,1000),
     m_response_text = substr(merchtxnRef || '-' || batchno || '-' || transactiono || '-' || cardtype,1,4000),
     m_settlement_date = to_Char(sysdate,LNG.TSMASK),
     m_rrn = substr(receiptno,1,1000),
     status = 'Order Payment Received',
     date_purchased = sysdate,
     payment_received = 'T',
     merchant_reference = nmb,
     last_step = 'Step 7'
   where poid = purchord.poid;

   calc_due_date( purchord.poid );
   purchase_audit_trail( surl, purchord.poid, 'PAID_METHOD', 'U', 'C', 'MERCHANT', purchord, voidrec);
   purchord.paid_method := 'MERCHANT';
   purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_CODE', 'U', 'C', substr(qsiresponsecode || '-' || acqresponsecode,1,1000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_TEXT', 'U', 'C', substr(merchtxnRef || '-' || batchno || '-' || transactiono || '-' || cardtype,1,4000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'M_SETTLEMENT_DATE', 'U', 'C', to_Char(sysdate,LNG.TSMASK), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'M_RRN', 'U', 'C', substr(receiptno,1,1000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'MERCHANT_REFERENCE', 'U', 'C', to_char(nmb), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'STATUS', 'U', 'C', 'Order Payment Received', purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'PAYMENT_RECEIVED', 'U', 'C', 'T', purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'LAST_STEP', 'U', 'C', 'Step 7', purchord, voidrec);

 else

  insert into audit_failed_merchant(poid,date_created,m_response_code,m_response_text,m_settlement_date,m_rrn) values
  (purchord.poid,sysdate,substr(qsiresponsecode || '-' || acqresponsecode,1,1000),substr(merchtxnRef || '-' || receiptno || '-' || cardtype,1,4000),to_Char(sysdate,LNG.TSMASK),substr(authorizeid,1,1000));
  commit;
  failed_credit_card(surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, qsiresponsecode );
  return;

 end if;

 if glbx.extract_master_parameter('MERCHANT_POP_WINDOW') = 'TRUE'
  then
   htp.p('<HTML><HEAD></HEAD><BODY ONLOAD="javascript: parent.opener.location = ''' || 'fname.confirm_payment?surl=' || surl || '&acid=' || acid || '&typ=&p1=&p2=' || '''; parent.close();"></BODY></HTML>' );
  else
   confirm_payment( surl, acid, null, empty_array, empty_array );
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_MERCHANT_ANZ_II',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end accept_merchant_anz_ii;

procedure accept_merchant_cbank(surl varchar2, wrk in varchar2 default 'T', responseText in varchar2 default null, authorisationCode in varchar2 default null, invoiceNumber in varchar2 default null,
                              amountPaid in varchar2 default null, transactionRef in varchar2 default null, surName in varchar2 default null )
as

 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 sts		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 acid 		integer;
 nmb		integer;
 empty_array	GLBX.MYARRAY;

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.ACCEPT_MERCHANT_CBANK');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 acid := find_acid(sess_id);
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 if upper(substr(wrk,1,1)) = 'T'
  then
   check_credit_already_done( purchord.poid );
   select s_purchase_order_merch_ref.nextval into nmb from dual;
   update purchase_order
    set
     paid_method = 'MERCHANT',
     m_response_code = substr(transactionRef,1,1000),
     m_response_text = substr(responseText,1,4000),
     m_settlement_date = to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'),
     m_rrn = substr(authorisationCode,1,1000),
     status = 'Order Payment Received',
     date_purchased = sysdate,
     payment_received = 'T',
     merchant_reference = nmb,
     last_step = 'Step 7'
   where poid = purchord.poid;

   calc_due_date( purchord.poid );
   purchase_audit_trail( surl, purchord.poid, 'PAID_METHOD', 'U', 'C', 'MERCHANT', purchord, voidrec);
   purchord.paid_method := 'MERCHANT';
   purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_CODE', 'U', 'C', substr(transactionRef,1,1000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_TEXT', 'U', 'C', substr(responseText,1,4000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'M_SETTLEMENT_DATE', 'U', 'C', to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'M_RRN', 'U', 'C', substr(authorisationCode,1,1000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'MERCHANT_REFERENCE', 'U', 'C', to_char(nmb), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'STATUS', 'U', 'C', 'Order Payment Received', purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'PAYMENT_RECEIVED', 'U', 'C', 'T', purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'LAST_STEP', 'U', 'C', 'Step 7', purchord, voidrec);

 else

  insert into audit_failed_merchant(poid,date_created,m_response_code,m_response_text,m_settlement_date,m_rrn) values
  (purchord.poid,sysdate,substr(transactionRef,1,1000),substr(responseText,1,4000),to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'),substr(authorisationCode,1,1000));
  commit;
  failed_credit_card(surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, responsetext );
  return;

 end if;

 if glbx.extract_master_parameter('MERCHANT_POP_WINDOW') = 'TRUE'
  then
   htp.p('<HTML><HEAD></HEAD><BODY ONLOAD="javascript: parent.opener.location = ''' || 'fname.confirm_payment?surl=' || surl || '&acid=' || acid || '&typ=&p1=&p2=' || '''; parent.close();"></BODY></HTML>' );
  else
   confirm_payment( surl, acid, null, empty_array, empty_array );
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_MERCHANT_CBANK',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end accept_merchant_cbank;

procedure accept_merchant_nab(surl varchar2, wrk in varchar2 default 'T', responseText in varchar2 default null, authorisationCode in varchar2 default null, invoiceNumber in varchar2 default null,
                              amountPaid in varchar2 default null, transactionRef in varchar2 default null, surName in varchar2 default null, currency in varchar2 default null )
as

 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 sts		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 acid 		integer;
 nmb		integer;
 empty_array	GLBX.MYARRAY;

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.ACCEPT_MERCHANT_NAB');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 acid := find_acid(sess_id);
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 if upper(substr(wrk,1,1)) = 'T'
  then
   check_credit_already_done( purchord.poid );
   select s_purchase_order_merch_ref.nextval into nmb from dual;
   update purchase_order
    set
     paid_method = 'MERCHANT',
     m_response_code = substr(transactionRef,1,1000),
     m_response_text = substr(responseText,1,4000),
     m_settlement_date = to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'),
     m_rrn = substr(authorisationCode,1,1000),
     status = 'Order Payment Received',
     date_purchased = sysdate,
     payment_received = 'T',
     merchant_reference = nmb,
     last_step = 'Step 7'
   where poid = purchord.poid;

  calc_due_date( purchord.poid );
  purchase_audit_trail( surl, purchord.poid, 'PAID_METHOD', 'U', 'C', 'MERCHANT', purchord, voidrec);
  purchord.paid_method := 'MERCHANT';
  purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_CODE', 'U', 'C', substr(transactionRef,1,1000), purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_TEXT', 'U', 'C', substr(responseText,1,4000), purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'M_SETTLEMENT_DATE', 'U', 'C', to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'), purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'M_RRN', 'U', 'C', substr(authorisationCode,1,1000), purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'PAYMENT_RECEIVED', 'U', 'C', 'T', purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'MERCHANT_REFERENCE', 'U', 'C', to_char(nmb), purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'STATUS', 'U', 'C', 'Order Payment Received', purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'LAST_STEP', 'U', 'C', 'Step 7', purchord, voidrec);

 else

  insert into audit_failed_merchant(poid,date_created,m_response_code,m_response_text,m_settlement_date,m_rrn) values
  (purchord.poid,sysdate,substr(transactionRef,1,1000),substr(responseText,1,4000),to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'),substr(authorisationCode,1,1000));
  commit;
  failed_credit_card(surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, responseText );
  return;

 end if;

 if glbx.extract_master_parameter('MERCHANT_POP_WINDOW') = 'TRUE'
  then
   htp.p('<HTML><HEAD></HEAD><BODY ONLOAD="javascript: parent.opener.location = ''' || 'fname.confirm_payment?surl=' || surl || '&acid=' || acid || '&typ=&p1=&p2=' || '''; parent.close();"></BODY></HTML>' );
  else
   confirm_payment( surl, acid, null, empty_array, empty_array );
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_MERCHANT_NAB',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end accept_merchant_nab;

procedure accept_merchant_safepay(SESSIONID in varchar2, MERCHANTID in varchar2, PURCHASEAMOUNT in varchar2, LOCALE in varchar2, RECEIPTNO in varchar2, TRANSACTIONNO in varchar2, ACQRESPONSECODE in varchar2, QSIRESPONSECODE in varchar2 )
as

 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 sts		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 surl		varchar2(100);
 acid 		integer;
 scode		number;
 nmb		integer;
 vtxt		varchar2(1000);
 empty_array	GLBX.MYARRAY;

begin
 surl := substr(sessionid,instr(sessionid,'-')+1);
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.ACCEPT_MERCHANT_SAFEPAY');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 acid := find_acid(sess_id);
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 begin scode := to_number(QSIRESPONSECODE); exception when others then scode := NULL; end;

if scode = 0
 then
  check_credit_already_done( purchord.poid );
  select s_purchase_order_merch_ref.nextval into nmb from dual;
  update purchase_order
   set
    paid_method = 'MERCHANT',
    m_response_code = substr(TRANSACTIONNO,1,1000),
    m_response_text = substr(RECEIPTNO,1,4000),
    m_rrn = substr(ACQRESPONSECODE,1,1000),
    status = 'Order Payment Received',
    date_purchased = sysdate,
    merchant_reference = nmb,
    payment_received = 'T',
    last_step = 'Step 7'
  where poid = purchord.poid;

  calc_due_date( purchord.poid );
  purchase_audit_trail( surl, purchord.poid, 'PAID_METHOD', 'U', 'C', 'MERCHANT', purchord, voidrec);
  purchord.paid_method := 'MERCHANT';
  purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_CODE', 'U', 'C', substr(TRANSACTIONNO,1,1000), purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_TEXT', 'U', 'C', substr(RECEIPTNO,1,4000), purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'M_RRN', 'U', 'C', substr(ACQRESPONSECODE,1,1000), purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'PAYMENT_RECEIVED', 'U', 'C', 'T', purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'MERCHANT_REFERENCE', 'U', 'C', to_char(nmb), purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'STATUS', 'U', 'C', 'Order Payment Received', purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'LAST_STEP', 'U', 'C', 'Step 7', purchord, voidrec);

 else

   if scode = 0 then vtxt := 'Transaction Successful';
   elsif scode = 1 then vtxt := 'Unknown Error';
   elsif scode = 2 then vtxt := 'Bank Declined Transaction';
   elsif scode = 3 then vtxt := 'No Reply from Bank';
   elsif scode = 4 then vtxt := 'Expired Card';
   elsif scode = 5 then vtxt := 'Insufficient funds';
   elsif scode = 6 then vtxt := 'Error Communicating with Bank';
   elsif scode = 7 then vtxt := 'Payment Server System Error';
   elsif scode = 8 then vtxt := 'Transaction Type Not Supported';
   else vtxt := 'Unable to be determined';
   end if;

  insert into audit_failed_merchant(poid,date_created,m_response_code,m_response_text,m_settlement_date,m_rrn) values
  (purchord.poid,sysdate,substr(TRANSACTIONNO,1,1000),substr(RECEIPTNO,1,4000),vtxt,substr(ACQRESPONSECODE,1,1000));
  commit;
  failed_credit_card(surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, vtxt );
  return;

 end if;

 if glbx.extract_master_parameter('MERCHANT_POP_WINDOW') = 'TRUE'
  then
   htp.p('<HTML><HEAD></HEAD><BODY ONLOAD="javascript: parent.opener.location = ''' || 'fname.confirm_payment?surl=' || surl || '&acid=' || acid || '&typ=&p1=&p2=' || '''; parent.close();"></BODY></HTML>' );
  else
   confirm_payment( surl, acid, null, empty_array, empty_array );
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_MERCHANT_SAFEPAY',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end accept_merchant_safepay;

procedure accept_merchant_securepay(wrk in varchar2 default 'T', ponum in varchar2 default null, amount in varchar2 default null, response_code in varchar2 default null, response_text in varchar2 default null, settle_date in varchar2 default null, txn_id in varchar2 default null, card_type in varchar2 default null, optional_info in varchar2 default null )
as

 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 sts		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 surl		varchar2(100);
 acid 		integer;
 nmb		integer;
 empty_array	GLBX.MYARRAY;

begin
 surl := trim(optional_info);
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.ACCEPT_MERCHANT_SECUREPAY');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 -- Note: PONUM is ingored. It will contain the photographer id || '-' || purchase order number

 acid := find_acid(sess_id);
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 if upper(substr(wrk,1,1)) = 'T'
  then
   check_credit_already_done( purchord.poid );
   select s_purchase_order_merch_ref.nextval into nmb from dual;
   update purchase_order
    set
     paid_method = 'MERCHANT',
     m_response_code = substr(response_code,1,1000),
     m_response_text = substr(response_text,1,4000),
     m_settlement_date = settle_date,
     m_rrn = substr(txn_id,1,1000),
     status = 'Order Payment Received',
     date_purchased = sysdate,
     payment_received = 'T',
     merchant_reference = nmb,
     last_step = 'Step 7'
   where poid = purchord.poid;

   calc_due_date( purchord.poid );
   purchase_audit_trail( surl, purchord.poid, 'PAID_METHOD', 'U', 'C', 'MERCHANT', purchord, voidrec);
   purchord.paid_method := 'MERCHANT';
   purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_CODE', 'U', 'C', substr(response_code,1,1000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_TEXT', 'U', 'C', substr(response_text,1,4000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'M_SETTLEMENT_DATE', 'U', 'C', settle_date, purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'M_RRN', 'U', 'C', substr(txn_id,1,1000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'PAYMENT_RECEIVED', 'U', 'C', 'T', purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'MERCHANT_REFERENCE', 'U', 'C', to_char(nmb), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'STATUS', 'U', 'C', 'Order Payment Received', purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'LAST_STEP', 'U', 'C', 'Step 7', purchord, voidrec);
 else
  insert into audit_failed_merchant(poid,date_created,m_response_code,m_response_text,m_settlement_date,m_rrn) values
  (purchord.poid,sysdate,substr(response_code,1,1000),substr(response_text,1,4000),settle_date,substr(txn_id,1,1000));
  commit;
  failed_credit_card(surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, response_text );
  return;
 end if;

 if glbx.extract_master_parameter('MERCHANT_POP_WINDOW') = 'TRUE'
  then
   htp.p('<HTML><HEAD></HEAD><BODY ONLOAD="javascript: parent.opener.location = ''' || 'fname.confirm_payment?surl=' || surl || '&acid=' || acid || '&typ=&p1=&p2=' || '''; parent.close();"></BODY></HTML>' );
  else
   confirm_payment( surl, acid, null, empty_array, empty_array );
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_MERCHANT_SECUREPAY',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end accept_merchant_securepay;

procedure accept_merchant_securebill(bill_id in varchar2 default 'T', field2 in varchar2 default null, approved in varchar2 default null, response in varchar2 default null, txn_id in varchar2 default null, receipt in varchar2 default null, amount in varchar2 default null, sett_date in varchar2 default null, card_type in varchar2 default null )
as

 cursor c1( vbl integer ) is select sessid from purchase_order where poid = vbl;
 cursor c2( sess_id integer ) is select securl,screen_type,login_type from login_session where sessid = sess_id;
 cursor c3( ploc varchar2 ) is select * from merchant_centralised_return where piction_location = ploc;

 c3rec		c3%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 sts		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 surl		varchar2(100);
 acid 		integer;
 nmb		integer;
 vbillid	varchar2(100);
 empty_array	GLBX.MYARRAY;

begin

 -- If multiple sites, redirect the call back to the correct site
 if bill_id is null or
    substr(bill_id,1,1) = 'Z'
  then
   vbillid := substr(bill_id,2);

  else

   open c3(substr(bill_id,1,1) );
   fetch c3 into c3rec;
   if c3%FOUND
    then
     close c3;
     owa_util.redirect_url( c3rec.url_redirect || '?bill_id=' || 'Z' || replace(substr(bill_id,2),' ','+') ||
                            '&field2=' ||    replace(field2,' ','+') ||
                            '&approved=' ||  replace(approved,' ','+') ||
                            '&response=' ||  replace(response,' ','+') ||
                            '&txn_id=' ||    replace(txn_id,' ','+') ||
                            '&receipt=' ||   replace(receipt,' ','+') ||
                            '&amount=' ||    replace(amount,' ','+') ||
                            '&sett_date=' || replace(sett_date,' ','+') ||
                            '&card_type=' || replace(card_type,' ','+') );
     return;
    else
     close c3;
     vbillid := substr(bill_id,2);
   end if;
 end if;

 open c1(vbillid);
 fetch c1 into sess_id;
 close c1;
 open c2(sess_id);
 fetch c2 into surl,stype,ltype;
 close c2;

 acid := find_acid(sess_id);
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 if trim(approved) = '1'
  then
   check_credit_already_done( purchord.poid );
   select s_purchase_order_merch_ref.nextval into nmb from dual;
   update purchase_order
    set
     paid_method = 'MERCHANT',
     m_response_code = substr(response,1,1000),
     m_response_text = substr(receipt || '-' || card_type || ':' || amount,1,4000),
     m_settlement_date = sett_date,
     m_rrn = substr(txn_id,1,1000),
     status = 'Order Payment Received',
     date_purchased = sysdate,
     payment_received = 'T',
     merchant_reference = nmb,
     last_step = 'Step 7'
   where poid = purchord.poid;

   calc_due_date( purchord.poid );
   purchase_audit_trail( surl, purchord.poid, 'PAID_METHOD', 'U', 'C', 'MERCHANT', purchord, voidrec);
   purchord.paid_method := 'MERCHANT';
   purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_CODE', 'U', 'C', substr(response,1,1000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_TEXT', 'U', 'C', substr(receipt || '-' || card_type || ':' || amount,1,4000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'M_SETTLEMENT_DATE', 'U', 'C', sett_date, purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'M_RRN', 'U', 'C', substr(txn_id,1,1000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'PAYMENT_RECEIVED', 'U', 'C', 'T', purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'MERCHANT_REFERENCE', 'U', 'C', to_char(nmb), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'STATUS', 'U', 'C', 'Order Payment Received', purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'LAST_STEP', 'U', 'C', 'Step 7', purchord, voidrec);
 else
  insert into audit_failed_merchant(poid,date_created,m_response_code,m_response_text,m_settlement_date,m_rrn) values
  (purchord.poid,sysdate,substr(response,1,1000),substr(receipt || '-' || card_type || ':' || amount,1,4000),sett_date,substr(txn_id,1,1000));
  commit;
  failed_credit_card(surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, response || '-' || substr(receipt || '-' || card_type || ':' || amount,1,4000) );
  return;
 end if;

 if glbx.extract_master_parameter('MERCHANT_POP_WINDOW') = 'TRUE'
  then
   htp.p('<HTML><HEAD></HEAD><BODY ONLOAD="javascript: parent.opener.location = ''' || 'fname.confirm_payment?surl=' || surl || '&acid=' || acid || '&typ=&p1=&p2=' || '''; parent.close();"></BODY></HTML>' );
  else
   confirm_payment( surl, acid, null, empty_array, empty_array );
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_MERCHANT_SECUREBILL',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end accept_merchant_securebill;

procedure accept_merchant_esec( surl varchar2, r in varchar2 default null, a in varchar2 default null, m in varchar2 default null, s in varchar2 default null )
as

 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 sts		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 acid 		integer;
 nmb		integer;
 empty_array	GLBX.MYARRAY;

begin

 --
 -- Paramters from ESEC as follows:
 --
 -- r:The value from the "referenceID" parameter of the HTML form.
 -- a:The authorisation id as returned by the financial institution.
 -- m:A message that the SecurEpayment SSL Interface
 -- s:An encrypted signature of the transaction details.
 --

 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.ACCEPT_MERCHANT_ESEC');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 acid := find_acid(sess_id);
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 if ((rtrim(m) = '200') or upper(rtrim(m)) = '200 SUCCESS') and (s is not null)
  then
   check_credit_already_done( purchord.poid );
   select s_purchase_order_merch_ref.nextval into nmb from dual;
   update purchase_order
    set
     paid_method = 'MERCHANT',
     m_response_code = substr(a,1,1000),
     m_response_text = substr(m,1,4000),
     m_rrn = substr(s,1,1000),
     status = 'Order Payment Received',
     date_purchased = sysdate,
     payment_received = 'T',
     merchant_reference = nmb,
     last_step = 'Step 7'
   where poid = purchord.poid;

   calc_due_date( purchord.poid );
   purchase_audit_trail( surl, purchord.poid, 'PAID_METHOD', 'U', 'C', 'MERCHANT', purchord, voidrec);
   purchord.paid_method := 'MERCHANT';
   purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_CODE', 'U', 'C', substr(a,1,1000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_TEXT', 'U', 'C', substr(m,1,4000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'M_RRN', 'U', 'C', substr(s,1,1000), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'PAYMENT_RECEIVED', 'U', 'C', 'T', purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'MERCHANT_REFERENCE', 'U', 'C', to_char(nmb), purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'STATUS', 'U', 'C', 'Order Payment Received', purchord, voidrec);
   purchase_audit_trail( surl, purchord.poid, 'LAST_STEP', 'U', 'C', 'Step 7', purchord, voidrec);
   if instr(s,'+') > 0
    then
     update purchase_order
      set
       m_rrn = substr(substr(s,1,instr(s,'+')-1),1,1000)
      where poid = purchord.poid;
     purchase_audit_trail( surl, purchord.poid, 'M_RRN', 'U', 'C', substr(substr(s,1,instr(s,'+')-1),1,1000), purchord, voidrec);
   end if;

 else
  insert into audit_failed_merchant(poid,date_created,m_response_code,m_response_text,m_settlement_date,m_rrn) values
  (purchord.poid,sysdate,substr(a,1,1000),substr(m,1,4000),null,substr(s,1,1000));
  commit;
  failed_credit_card(surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, m );
  return;
 end if;

 if glbx.extract_master_parameter('MERCHANT_POP_WINDOW') = 'TRUE'
  then
   htp.p('<HTML><HEAD></HEAD><BODY ONLOAD="javascript: parent.opener.location = ''' || 'fname.confirm_payment?surl=' || surl || '&acid=' || acid || '&typ=&p1=&p2=' || '''; parent.close();"></BODY></HTML>' );
  else
   confirm_payment( surl, acid, null, empty_array, empty_array );
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_MERCHANT_ESEC',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end accept_merchant_esec;

procedure accept_merchant_dp(surl varchar2, wrk in varchar2 default 'T' )
as

 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 sts		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 acid 		integer;
 nmb		integer;
 empty_array	GLBX.MYARRAY;

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.ACCEPT_MERCHANT_DP');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 acid := find_acid(sess_id);
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 if upper(substr(wrk,1,1)) = 'T'
  then
   check_credit_already_done( purchord.poid );
   select s_purchase_order_merch_ref.nextval into nmb from dual;
   update purchase_order
    set
     paid_method = 'MERCHANT',
     m_response_code = substr('As Per Receipt Page',1,1000),
     m_response_text = substr('Transaction Performed',1,4000),
     m_settlement_date = to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'),
     m_rrn = substr('As Per Receipt Page',1,1000),
     status = 'Order Payment Received',
     date_purchased = sysdate,
     payment_received = 'T',
     merchant_reference = nmb,
     last_step = 'Step 7'
   where poid = purchord.poid;

  calc_due_date( purchord.poid );
  purchase_audit_trail( surl, purchord.poid, 'PAID_METHOD', 'U', 'C', 'MERCHANT', purchord, voidrec);
  purchord.paid_method := 'MERCHANT';
  purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_CODE', 'U', 'C', substr('As Per Receipt Page',1,1000), purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'M_RESPONSE_TEXT', 'U', 'C', substr('Transaction Performed',1,4000), purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'M_SETTLEMENT_DATE', 'U', 'C', to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'), purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'M_RRN', 'U', 'C', substr('As Per Receipt Page',1,1000), purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'PAYMENT_RECEIVED', 'U', 'C', 'T', purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'MERCHANT_REFERENCE', 'U', 'C', to_char(nmb), purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'STATUS', 'U', 'C', 'Order Payment Received', purchord, voidrec);
  purchase_audit_trail( surl, purchord.poid, 'LAST_STEP', 'U', 'C', 'Step 7', purchord, voidrec);

 else

  insert into audit_failed_merchant(poid,date_created,m_response_code,m_response_text,m_settlement_date,m_rrn) values
  (purchord.poid,sysdate,substr('As Per Receipt Page',1,1000),substr('Transaction Performed',1,4000),to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'),substr('As Per Receipt Page',1,1000));
  commit;
  failed_credit_card(surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, 'Transaction Performed' );
  return;

 end if;

 if glbx.extract_master_parameter('MERCHANT_POP_WINDOW') = 'TRUE'
  then
   htp.p('<HTML><HEAD></HEAD><BODY ONLOAD="javascript: parent.opener.location = ''' || 'fname.confirm_payment?surl=' || surl || '&acid=' || acid || '&typ=&p1=&p2=' || '''; parent.close();"></BODY></HTML>' );
  else
   confirm_payment( surl, acid, null, empty_array, empty_array );
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_MERCHANT_DP',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end accept_merchant_dp;

function find_acid(sess_id integer)
 return integer
as

 cursor c1(sess_id integer) is
  select um.aid
  from umo um, shopping_basket sb, purchase_order po
  where po.sessid = sess_id and
        po.poid = sb.poid and
        sb.phid = um.umo_id;

 c1rec	c1%ROWTYPE;

begin
 open c1(sess_id);
 fetch c1 into c1rec;
 close c1;
 return( c1rec.aid);

end find_acid;

procedure check_order( msg in varchar2 default null )
as

 pfx		THEME%ROWTYPE;

begin

 glbx.main_title( null, LNG.ORD_TXT_085,sstyle=>'STANDARD',sclr=>'BLACK' );
 htp.p( '<CENTER>' );

 if msg is not null
  then
   glbx.header_msg( msg );
 end if;

 htp.header(3, LNG.ORD_TXT_086, 'CENTER' );
 htp.header(4, LNG.ORD_TXT_087, 'CENTER' );
 htp.nl;
 htp.nl;
 htp.formopen( 'fname.accept_order_login' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( LNG.ORD_TXT_088 );
    htp.tabledata( htf.formtext( 'P1', 20, 20 ));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( LNG.ORD_TXT_089 );
    htp.tabledata( htf.formpassword( 'P2', 30, 100 ));
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, LNG.ORD_TXT_090 );
 htp.formclose;
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );
exception when others then
 glbx.error_details( 'FNAME', 'CHECK_ORDER',errmsg=>sqlerrm);
end check_order;

procedure accept_order_login( p1 in varchar2, p2 in varchar2 )
as

 cursor c1(purchid integer) is select * from purchase_order where poid = purchid;
 cursor c2(sess_id integer) is select ca.theme_type, ca.theme_name,ca.aid from login_session ls, customer_account ca where ls.sessid = sess_id and ls.aid = ca.aid;
 cursor c3(void integer) is select * from order_style where oid = void;
 cursor c4(wstate integer, voption varchar2) is select status_priority_id from workflow_state_options where work_state = wstate and order_option = voption;
 cursor c5(acid integer) is select * from customer_account where aid = acid;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 voidrec	c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c4arec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		THEME%ROWTYPE;
 surl		varchar2(100);
 id		integer;
 acid		integer;
 hostip		varchar2(100);
 purchid	integer;
 newline	boolean;
 ord_exists	boolean;
 grand_ttl	number;

begin
 begin
  purchid := to_number(p1);
 exception
  when others then
   check_order( LNG.ORD_TXT_091 );
   return;
 end;

 open c1( purchid );
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   check_order( LNG.ORD_TXT_091 );
   return;
 end if;
 close c1;

 if p2 is null
  then
   check_order( LNG.ORD_TXT_093 );
   return;
 end if;

 if upper(p2) <> nvl(upper(c1rec.contact_password),'!')
  then
   check_order( LNG.ORD_TXT_093 );
   return;
 end if;

 id := glbx.get_random_sessionid;
 hostip := owa_util.get_cgi_env( 'REMOTE_ADDR' );
 -- Login as a New Type of User Called

 surl := rpad(to_char(id),12,'Z') || glbx.randstring;
 insert into login_session(screen_type,login_type,sessid,aid,date_created,date_updated,call_ctr,guest_email, browser, ip_address, securl)
  values (1, 'EXTERNAL_ORDER', id, c1rec.poid, sysdate, sysdate, 1, null, substr(owa_util.get_cgi_env( 'HTTP_USER_AGENT'),1,100), hostip, surl );
 commit;

 open c2( c1rec.sessid );
 fetch c2 into c2rec;
 close c2;

 open c3( c1rec.oid );
 fetch c3 into voidrec;
 close c3;

 open c5( c2rec.aid );
 fetch c5 into c5rec;
 close c5;

 pfx := glbx.get_thm( c2rec.theme_name );
 theme_rec := glbx.get_theme_types( c2rec.theme_type );

 open c4(0,c1rec.status);
 fetch c4 into c4rec;
 close c4;
 open c4(0,voidrec.disp_ord_trk_expire_status);
 fetch c4 into c4arec;
 close c4;

 -- Check to See if the Order Tracking Page has Expired
 if voidrec.disp_ord_trk_expire_at = 'D'
  then
   if c1rec.date_created + nvl(voidrec.disp_ord_trk_expire_date,30) < sysdate
    then
     glbx.main_title( surl, 'Access to this Purchase Order has been disabled',glbx.backimg(surl,c1rec.pid,pfx.text_back,null),helpid=>'O22',stype=>1,sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour,det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
     return;
   end if;

 elsif voidrec.disp_ord_trk_expire_at = 'S'
  then
   if c4arec.status_priority_id < c4rec.status_priority_id
    then
     glbx.main_title( surl, 'Access to this Purchase Order has been disabled',glbx.backimg(surl,c1rec.pid,pfx.text_back,null),helpid=>'O22',stype=>1,sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour,det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
     return;
   end if;

 end if;

 glbx.main_title( surl, LNG.ORD_TXT_094 || c1rec.poid,glbx.backimg(surl,c1rec.pid,pfx.text_back,null),helpid=>'O22',stype=>1,sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour,det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );

 htp.header(3, LNG.ORD_TXT_095, 'CENTER' );
 htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold(voidrec.text_purchase_request || ' ' || 'Status'), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( c1rec.status ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   if nvl(voidrec.columns_name_toggle,'T') = 'T'
    then
     htp.tablerowopen;
      htp.tabledata( voidrec.columns_name, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.bold( nvl(c1rec.sendto_name,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
    else
     htp.tablerowopen;
      htp.tabledata( voidrec.columns_firstname, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.bold( nvl(c1rec.sendto_firstname,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( voidrec.columns_lastname, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.bold( nvl(c1rec.sendto_lastname,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
   htp.tablerowopen;
    htp.tabledata( voidrec.columns_street, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( nvl(c1rec.sendto_street,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   if c1rec.sendto_branch is not null
    then
     htp.tablerowopen;
      htp.tabledata( voidrec.columns_branch, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.bold( nvl(c1rec.sendto_branch,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
   if c1rec.sendto_department is not null
    then
     htp.tablerowopen;
      htp.tabledata( voidrec.columns_department, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.bold( nvl(c1rec.sendto_department,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
   htp.tablerowopen;
    htp.tabledata( voidrec.columns_suburb, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( nvl(c1rec.sendto_suburb,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( voidrec.columns_city, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( nvl(c1rec.sendto_city,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( voidrec.columns_country, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( nvl(c1rec.sendto_country,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( voidrec.columns_postcode, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( nvl(c1rec.sendto_postcode,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( voidrec.columns_state, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( nvl(c1rec.sendto_state,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( LNG2.FNM_TXT_111, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( nvl(c1rec.delivery_time,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( voidrec.columns_comment, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( nvl(c1rec.customer_comment,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   if voidrec.columns_cust_col1 is not null
    then
     htp.tablerowopen;
      htp.tabledata( voidrec.columns_cust_col1, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.bold( nvl(c1rec.customer_column1,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
   if voidrec.columns_cust_col2 is not null
    then
     htp.tablerowopen;
      htp.tabledata( voidrec.columns_cust_col2, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.bold( nvl(c1rec.customer_column2,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
   if voidrec.columns_cust_col3 is not null
    then
     htp.tablerowopen;
      htp.tabledata( voidrec.columns_cust_col3, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.bold( nvl(c1rec.customer_column3,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
   if voidrec.columns_cust_col4 is not null
    then
     htp.tablerowopen;
      htp.tabledata( voidrec.columns_cust_col4, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.bold( nvl(c1rec.customer_column4,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
   if voidrec.columns_cust_col5 is not null
    then
     htp.tablerowopen;
      htp.tabledata( voidrec.columns_cust_col5, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.bold( nvl(c1rec.customer_column5,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
   if voidrec.columns_cust_col6 is not null
    then
     htp.tablerowopen;
      htp.tabledata( voidrec.columns_cust_col6, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.bold( nvl(c1rec.customer_column6,'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
   htp.tablerowopen;
    htp.tabledata( LNG4.AHC_TXT_772, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   if c1rec.do_not_split_order = 'T'
    then
      htp.tabledata( LNG.PHG_TXT_045, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    else
      htp.tabledata( LNG.PHG_TXT_046, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   end if;
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( LNG.PHG_TXT_083, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( to_char(c1rec.date_purchased,LNG.TSMASK) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( LNG.PHG_ALT_133, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( nvl(to_char(c1rec.date_fulfilled,LNG.TSMASK),'&nbsp;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;

  show_customer_order( surl, c5rec, theme_rec, voidrec, c1rec.sessid, 1, 'EXTERNAL_ORDER', pfx, acid, 'BROWSE', ord_exists, grand_ttl, newline, '"80%"', null );

  htp.nl;

  if download_exists(purchid)
   then
    htp.nl;
    list_downloadable( surl, c1rec, pfx, theme_rec, voidrec, null );
  end if;
  htp.nl;
  htp.italic( LNG.ORD_TXT_097 );
  htp.nl;
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_ORDER_LOGIN',errmsg=>sqlerrm);
end accept_order_login;

function download_exists( vpoid in integer )
 return boolean
is

 cursor c1(vpoid integer) is
  select count('x') exst
   from shopping_basket sb, phg_price_object p1, phg_price_object_defn p2
   where sb.poid = vpoid and
         sb.ppm_id = p1.ppm_id and
         sb.ppm_title = p1.title and
         p1.ppm_id = p2.ppm_id and
         p2.multiple_type = 'T';

 cursor c2(vpoid integer) is
  select count('x') exst
   from shopping_basket sb
   where sb.poid = vpoid and
         ((contentlength > 0) or (ftp_location is not null));

 c1rec c1%ROWTYPE;

begin
 open c1(vpoid);
 fetch c1 into c1rec;
 close c1;
 if c1rec.exst = 0
  then
   open c2(vpoid);
   fetch c2 into c1rec;
   close c2;
   if c1rec.exst = 0
    then
     return( FALSE );
    else
     return( TRUE );
   end if;
  else
   return( TRUE );
 end if;
end download_exists;

function check_prev_orders(purchid in integer, sess_id in integer, v_umo in integer)
 return integer
as
 cursor c1(vpoid integer) is select sessid from purchase_order where poid = vpoid;
 c1rec		c1%ROWTYPE;
 ordlist	glbx.myarray;
begin
 ordlist := glbx.historic_purchase_orders( sess_id );
 if ordlist.count = 0 then return( sess_id ); end if; -- no previous orders so just return current session_id
 for j in ordlist.first..ordlist.last loop
  if substr(ordlist(j),2) = to_char(purchid)
   then
    open c1(purchid);
    fetch c1 into c1rec;
    close c1;
    return( c1rec.sessid );
  end if;
 end loop;
 return( sess_id );
exception
 when others then return( sess_id );
end check_prev_orders;

procedure download_file(surl varchar2, v_umo in integer, purchid in integer, mthod in varchar2 DEFAULT 'ORIGINAL', acid in integer, shp in integer default null)
as

 cursor c2(v_umo integer) is select ftp_location,ftp_virtual_dir from umo where umo_id = v_umo;

 cursor c3(fvd varchar2) is select site_type from ftp_sites where virtual_directory = fvd;

 cursor c4(shp integer) is
   select sb.shopping_id,sb.phid, sb.umo_photo_name photo_name, sb.contentlength, p1.value_b fileformat, sb.ftp_location, sb.ftp_virtual_dir, sb.must_download, p1.value_c
   from shopping_basket sb, phg_price_object p1, phg_price_object_defn p2
   where sb.shopping_id = shp and
         sb.ppm_id = p1.ppm_id and
         sb.ppm_title = p1.title and
         p1.ppm_id = p2.ppm_id and
         p2.multiple_type = 'T';

 cursor c5(purchase_id integer, sess_id integer, v_umo integer) is
  select um.photo_original.source.localdata orig_photo, um.doc_body orig_document, um.audio_original.source.localdata orig_audio, um.video_original.source.localdata orig_video, um.blueprint_obj.localdata orig_blueprint,
         um.photo_master.source.localdata web_photo, um.doc_html web_document, um.audio_thumbnail.source.localdata web_audio, um.blueprint_obj.online_version web_blueprint,
         um.umo_type,
         decode(um.umo_type,'PHOTO',um.photo_original.mimetype, 'AUDIO',um.audio_original.mimetype, 'VIDEO',um.video_original.mimetype, 'DOCUMENT',um.doc_mimetype, 'BLUEPRINT',um.blueprint_obj.mimetype) mtype,
         decode(um.umo_type,'PHOTO',um.photo_original_loc, 'AUDIO',um.audio_original_loc, 'VIDEO',um.video_original_loc, 'DOCUMENT', um.document_original_loc, 'BLUEPRINT',um.blueprint_obj.blueprint_original_loc ) origloc,
         um.photo_thumbnail.source.localdata tnail_photo
  from shopping_basket sb, umo um, purchase_order po
  where sb.poid = purchase_id and
        sb.phid = um.umo_id and
        po.poid = sb.poid and
        po.sessid = sess_id and
        um.umo_id = v_umo and
        (
         (um.umo_type = 'PHOTO' and nvl(dbms_lob.getlength(um.photo_original.source.localdata),0) > 0) or
         (um.umo_type = 'DOCUMENT' and nvl(dbms_lob.getlength(um.doc_body),0) > 0)  or
         (um.umo_type = 'VIDEO' and nvl(dbms_lob.getlength(um.video_original.source.localdata),0) > 0)  or
         (um.umo_type = 'AUDIO' and nvl(dbms_lob.getlength(um.audio_original.source.localdata),0) > 0)  or
         (um.umo_type = 'BLUEPRINT' and nvl(dbms_lob.getlength(um.blueprint_obj.localdata),0) > 0)
        );

 cursor c5w(purchase_id integer, sess_id integer, v_umo integer) is
  select um.photo_original.source.localdata orig_photo, um.doc_body orig_document, um.audio_original.source.localdata orig_audio, um.video_original.source.localdata orig_video, um.blueprint_obj.localdata orig_blueprint,
         um.photo_master.source.localdata web_photo, um.doc_html web_document, um.audio_thumbnail.source.localdata web_audio, um.blueprint_obj.online_version web_blueprint,
         um.umo_type,
         decode(um.umo_type,'PHOTO',um.photo_master.mimetype, 'AUDIO',um.audio_thumbnail.mimetype, 'VIDEO',um.video_original.mimetype, 'DOCUMENT','text/html', 'BLUEPRINT',um.blueprint_obj.mimetype) mtype,
         decode(um.umo_type,'PHOTO',um.photo_original_loc, 'AUDIO',um.audio_original_loc, 'VIDEO',um.video_original_loc, 'DOCUMENT', um.document_original_loc, 'BLUEPRINT',um.blueprint_obj.blueprint_original_loc ) origloc,
         um.photo_thumbnail.source.localdata tnail_photo
  from shopping_basket sb, umo um, purchase_order po
  where sb.poid = purchase_id and
        sb.phid = um.umo_id and
        po.poid = sb.poid and
        po.sessid = sess_id and
        um.umo_id = v_umo and
        (
         (um.umo_type = 'PHOTO' and nvl(dbms_lob.getlength(um.photo_master.source.localdata),0) > 0) or
         (um.umo_type = 'DOCUMENT' and nvl(dbms_lob.getlength(um.doc_html),0) > 0)  or
         (um.umo_type = 'AUDIO' and nvl(dbms_lob.getlength(um.audio_thumbnail.source.localdata),0) > 0)  or
         (um.umo_type = 'BLUEPRINT' and nvl(dbms_lob.getlength(um.blueprint_obj.online_version),0) > 0)
        );

 cursor c5a(sess_id integer, v_umo integer) is
  select um.photo_original.source.localdata orig_photo, um.doc_body orig_document, um.audio_original.source.localdata orig_audio, um.video_original.source.localdata orig_video, um.blueprint_obj.localdata orig_blueprint,
         um.photo_master.source.localdata web_photo, um.doc_html web_document, um.audio_thumbnail.source.localdata web_audio, um.blueprint_obj.online_version web_blueprint,
         um.umo_type,
         decode(um.umo_type,'PHOTO',um.photo_original.mimetype, 'AUDIO',um.audio_original.mimetype, 'VIDEO',um.video_original.mimetype, 'DOCUMENT',um.doc_mimetype, 'BLUEPRINT',um.blueprint_obj.mimetype) mtype,
         decode(um.umo_type,'PHOTO',um.photo_original_loc, 'AUDIO',um.audio_original_loc, 'VIDEO',um.video_original_loc, 'DOCUMENT', um.document_original_loc, 'BLUEPRINT',um.blueprint_obj.blueprint_original_loc ) origloc,
         um.photo_thumbnail.source.localdata tnail_photo
  from umo um
  where um.umo_id = v_umo and
        (
         (um.umo_type = 'PHOTO' and nvl(dbms_lob.getlength(um.photo_original.source.localdata),0) > 0) or
         (um.umo_type = 'DOCUMENT' and nvl(dbms_lob.getlength(um.doc_body),0) > 0)  or
         (um.umo_type = 'VIDEO' and nvl(dbms_lob.getlength(um.video_original.source.localdata),0) > 0)  or
         (um.umo_type = 'AUDIO' and nvl(dbms_lob.getlength(um.audio_original.source.localdata),0) > 0)  or
         (um.umo_type = 'BLUEPRINT' and nvl(dbms_lob.getlength(um.blueprint_obj.localdata),0) > 0)
        );

 cursor c5b(sess_id integer, v_umo integer) is
  select um.photo_original.source.localdata orig_photo, um.doc_body orig_document, um.audio_original.source.localdata orig_audio, um.video_original.source.localdata orig_video, um.blueprint_obj.localdata orig_blueprint,
         um.photo_master.source.localdata web_photo, um.doc_html web_document, um.audio_thumbnail.source.localdata web_audio, um.blueprint_obj.online_version web_blueprint,
         um.umo_type,
         decode(um.umo_type,'PHOTO',um.photo_master.mimetype, 'AUDIO',um.audio_thumbnail.mimetype, 'VIDEO',um.video_original.mimetype, 'DOCUMENT','text/html', 'BLUEPRINT',um.blueprint_obj.mimetype) mtype,
         decode(um.umo_type,'PHOTO',um.photo_original_loc, 'AUDIO',um.audio_original_loc, 'VIDEO',um.video_original_loc, 'DOCUMENT', um.document_original_loc, 'BLUEPRINT',um.blueprint_obj.blueprint_original_loc ) origloc,
         um.photo_thumbnail.source.localdata tnail_photo
  from umo um
  where um.umo_id = v_umo and
        (
         (um.umo_type = 'PHOTO' and nvl(dbms_lob.getlength(um.photo_master.source.localdata),0) > 0) or
         (um.umo_type = 'DOCUMENT' and nvl(dbms_lob.getlength(um.doc_html),0) > 0)  or
         (um.umo_type = 'AUDIO' and nvl(dbms_lob.getlength(um.audio_thumbnail.source.localdata),0) > 0)  or
         (um.umo_type = 'BLUEPRINT' and nvl(dbms_lob.getlength(um.blueprint_obj.online_version),0) > 0)
        );

 cursor c6( vpoid integer ) is select * from order_style where oid = (select oid from purchase_order where poid = vpoid );
 cursor c7( vpoid integer ) is select * from purchase_order where poid = vpoid;

 c1rec			customer_account%ROWTYPE;
 purchord		purchase_order%ROWTYPE;
 pfx			theme%ROWTYPE;
 voidrec		order_style%ROWTYPE;
 theme_rec		theme_types%ROWTYPE;
 c2rec			c2%ROWTYPE;
 c3rec			c3%ROWTYPE;
 c4rec			c4%ROWTYPE;
 c5rec			c5%ROWTYPE;
 ltype			varchar2(100);
 stype			integer;
 sess_id		integer;
 profid			integer;
 check_sessid		integer;
 sts			varchar2(100);
 c_imgchunk		binary_integer;
 v_imgchunk		binary_integer;
 v_count		integer;
 --v_buffer 		raw(32367);
 c_buffer 		varchar2(32367);
 img			blob;
 imgc			clob;
 fname			varchar2(1000);
 fname1			varchar2(1000);
 result			varchar2(1000);
 b2c_value		char(1);

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.DOWNLOAD_FILE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 --c1rec := glbx.get_cusrec( sess_id, ltype, acid, profid );
 --theme_rec := glbx.get_theme_types( c1rec.theme_type );
 --pfx := glbx.get_thm( c1rec.theme_name );
 glbx.get_all_order_details(sess_id, ltype, acid, profid, c1rec, pfx, theme_rec, purchord, voidrec );

 if purchid is null
  then
   --voidrec := glbx.get_order_style( glbx.get_order_style( c1rec.aid, profid, ltype, b2c_value ));
   if (voidrec.download_original_any_time = 'T') and (mthod = 'ORIGINAL')
    then
     null;
   elsif (voidrec.download_web_any_time = 'T') and (mthod = 'WEB')
    then
     null;
   elsif mthod = 'FTP'
    then
     null;
   elsif ltype = 'PHOTOGRAPHER' and c1rec.aid is not null -- Allow photographer access to download
    then
     null;
   else
     htp.p( LNG5.EXT_TXT_596 ); htp.nl;
     return; -- Cannot download this image
   end if;

  else

   open c6(purchid);
   fetch c6 into voidrec;
   close c6;
   if (voidrec.download_original_on_purchase = 'T') and (mthod = 'ORIGINAL')
    then
     null;
   elsif (voidrec.download_web_on_purchase = 'T') and (mthod = 'WEB')
    then
     null;
   elsif mthod = 'FTP'
    then
     null;
   else
     htp.p( LNG5.EXT_TXT_596 ); htp.nl;
     return; -- Cannot download this image
   end if;
 end if;

 -- If shp is null then the Download is traditional (ie all images) else it is by using the download object option
 -- Check if we are allowed to download it
 check_sessid := check_prev_orders(purchid,sess_id,v_umo);

 if download_exists(purchid)
  then

     if mthod = 'ORIGINAL'
      then
       open c5(purchid,check_sessid,v_umo);
       fetch c5 into c5rec;
       if c5%NOTFOUND
        then
         close c5;
         htp.p( 'Illegal 3'); htp.nl;
         return; -- Trying to break in
       end if;
       close c5;
      elsif mthod = 'WEB'
       then
        open c5w(purchid,check_sessid,v_umo);
        fetch c5w into c5rec;
        close c5w;
     end if;

  else
   if purchid is not null
    then
     if mthod = 'ORIGINAL'
      then
       open c5(purchid,check_sessid,v_umo);
       fetch c5 into c5rec;
       if c5%NOTFOUND
        then
         close c5;
         htp.p( 'Illegal 3'); htp.nl;
         return; -- Trying to break in
       end if;
       close c5;
      elsif mthod = 'WEB'
       then
        open c5w(purchid,check_sessid,v_umo);
        fetch c5w into c5rec;
        close c5w;
     end if;

    elsif purchid is null
    then
     if mthod = 'ORIGINAL'
      then
       open c5a(check_sessid,v_umo);
       fetch c5a into c5rec;
       if c5a%NOTFOUND
        then
         close c5a;
         htp.p( 'Illegal 4'); htp.nl;
         return; -- Trying to break in
       end if;
       close c5a;
      elsif mthod in ('WEB','TNAIL')
       then
        open c5b(check_sessid,v_umo);
        fetch c5b into c5rec;
       close c5b;
     end if;
   end if;
 end if;

 -- Check if all Details Entered
 if voidrec.download_prompt_details = 'T'
  then
   -- Check if all mandatory fields have been entered
   result := NULL;
   open c7(purchid);
   fetch c7 into purchord;
   close c7;
   check_mandatory( 'ORDER', voidrec.columns_mandatory, voidrec, purchord, pfx, result );
   if result is not null
    then
     disp_order_page( surl, stype, sess_id, ltype, acid, profid, c1rec, pfx, theme_rec, purchord, voidrec, result );
     return;
   end if;
 end if;

 if mthod in ('ORIGINAL','WEB','TNAIL','FTP')
  then
   insert into downloaded_photo(umo_id,poid,sessid,ftp_original,timestamp) values (v_umo,purchid,sess_id,mthod,sysdate);
   commit;
 end if;

 if mthod in ('ORIGINAL','WEB','TNAIL')
  then
  -- owa_util.mime_header(nvl(c5rec.photo_original.mimetype,'image/unknown'));
   --owa_util.mime_header('image/unknown');

   fname := glbx.extract_fname(c5rec.origloc,'FILENAME');

   if nvl(c5rec.mtype,'image/jpeg') = 'image/jpeg'
    then
     fname := glbx.extract_fname(fname,'NO_EXTENSION') || '.jpg';
     htp.prn('Content-type: ' || 'bad/type' || NL_CHAR);
   elsif nvl(c5rec.mtype,'image/jpeg') = 'image/gif'
    then
     fname := glbx.extract_fname(fname,'NO_EXTENSION') || '.gif';
     htp.prn('Content-type: ' || 'bad/type' || NL_CHAR);
    else
     htp.prn('Content-type: ' || c5rec.mtype || NL_CHAR);
   end if;
   htp.prn('Content-Disposition: attachment; filename=' || fname || NL_CHAR); -- '"' || instead of attachment file
   htp.prn('Content-Transfer-Encoding: binary' || NL_CHAR);
   htp.prn(NL_CHAR);

   c_imgchunk := 30000;
   v_imgchunk := 30000;
   v_count := 0;

   if c5rec.umo_type = 'PHOTO' and mthod = 'ORIGINAL'
    then
     img := c5rec.orig_photo;
   elsif c5rec.umo_type = 'PHOTO' and mthod = 'WEB'
    then
     img := c5rec.web_photo;
   elsif c5rec.umo_type = 'PHOTO' and mthod = 'TNAIL'
    then
     img := c5rec.tnail_photo;
   elsif c5rec.umo_type = 'DOCUMENT' and mthod = 'ORIGINAL'
    then
     img := c5rec.orig_document;
   elsif c5rec.umo_type = 'DOCUMENT' and mthod = 'WEB'
    then
     imgc := c5rec.web_document;
   elsif c5rec.umo_type = 'AUDIO' and mthod = 'ORIGINAL'
    then
     img := c5rec.orig_audio;
   elsif c5rec.umo_type = 'AUDIO' and mthod = 'WEB'
    then
     img := c5rec.web_audio;
   elsif c5rec.umo_type = 'VIDEO' and mthod = 'ORIGINAL'
    then
     img := c5rec.orig_video;
   elsif c5rec.umo_type = 'BLUEPRINT' and mthod = 'ORIGINAL'
    then
     img := c5rec.orig_blueprint;
   elsif c5rec.umo_type = 'BLUEPRINT' and mthod = 'WEB'
    then
     img := c5rec.web_blueprint;
   end if;

   if c5rec.umo_type = 'DOCUMENT' and mthod = 'WEB'
    then
     begin
      loop
       dbms_lob.read(imgc,v_imgchunk,(v_count*c_imgchunk)+1,c_buffer);
       v_count := v_count + 1;
       htp.prn( c_buffer );
      end loop;
      exception
       when no_data_found then null;
       when others
        then glbx.error_details( 'ORD', 'DOWNLOAD_FILE',errmsg=>sqlerrm,extdet=>'Error Occurred in Program Subloop: V_COUNT:' || v_count);
     end;

   else
     wpg_docload.download_file (img);

   end if;

   /*
   begin
    loop
     if c5rec.umo_type = 'PHOTO'
      then
       dbms_lob.read(c5rec.orig_photo,v_imgchunk,(v_count*c_imgchunk)+1,v_buffer);
     elsif c5rec.umo_type = 'DOCUMENT'
      then
       dbms_lob.read(c5rec.orig_document,v_imgchunk,(v_count*c_imgchunk)+1,v_buffer);
     elsif c5rec.umo_type = 'AUDIO'
      then
       dbms_lob.read(c5rec.orig_audio,v_imgchunk,(v_count*c_imgchunk)+1,v_buffer);
     elsif c5rec.umo_type = 'VIDEO'
      then
       dbms_lob.read(c5rec.orig_video,v_imgchunk,(v_count*c_imgchunk)+1,v_buffer);
     elsif c5rec.umo_type = 'BLUEPRINT'
      then
       dbms_lob.read(c5rec.orig_blueprint,v_imgchunk,(v_count*c_imgchunk)+1,v_buffer);
     elsif c5rec.umo_type = 'DOCUMENT'
      then
       dbms_lob.read(c5rec.orig_document,v_imgchunk,(v_count*c_imgchunk)+1,v_buffer);
     end if;
     v_count := v_count + 1;
     htp.prn( sys.utl_raw.cast_to_varchar2(v_buffer) );
    end loop;
   exception
    when no_data_found then null;
    when others
     then glbx.error_details( 'ORD', 'DOWNLOAD_FILE',errmsg=>sqlerrm,extdet=>'Error Occurred in Program Subloop: V_COUNT:' || v_count);
   end;
   */

 elsif mthod = 'FTP'
  then
   if shp is null
    then
     open c2(v_umo);
     fetch c2 into c2rec;
     close c2;
    else
     open c4(shp);
     fetch c4 into c4rec;
     if c4%FOUND
      then
       close c4;
       c2rec.ftp_virtual_dir := c4rec.ftp_virtual_dir;
       c2rec.ftp_location := c4rec.ftp_location;
      else
       close c4;
       open c2(v_umo);
       fetch c2 into c2rec;
       close c2;
     end if;
   end if;

   open c3(c2rec.ftp_virtual_dir);
   fetch c3 into c3rec;
   close c3;

   if c3rec.site_type in ('R',LNG4.AHC_TXT_445)
    then
     htp_bfile( c2rec.ftp_location, c2rec.ftp_virtual_dir);
    else
     htp.htmlopen;
     htp.p( '<BODY BGCOLOR="#FFFFFF">' );
     htp.p( '<CENTER>' );
     htp.bold( LNG4.AHC_TXT_337 );
     htp.nl;
     htp.bold( LNG4.AHC_TXT_338 );
     htp.nl;
     htp.nl;
     if c4rec.value_c is null
      then
       htp.anchor( c2rec.ftp_virtual_dir || c2rec.ftp_location, c2rec.ftp_virtual_dir || c2rec.ftp_location );
      else
       fname1 := c2rec.ftp_virtual_dir || glbx.extract_fname( c2rec.ftp_location, 'NO_EXTENSION' ) || c4rec.value_c || substr(c2rec.ftp_location,length(glbx.extract_fname( c2rec.ftp_location, 'NO_EXTENSION' ))+1);
       htp.anchor( fname1, fname1 );
     end if;
     htp.nl;
     htp.nl;
     htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
     htp.nl;
     htp.p( '</CENTER>' );
     glbx.close_page( pfx );
  end if;
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'DOWNLOAD_FILE',errmsg=>sqlerrm,extdet=>'V_UMO:' || v_umo || ' PURCHID:' || purchid);
end download_file;

procedure list_downloadable( surl varchar2, prec in purchase_order%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, voidrec in order_style%ROWTYPE, acid in integer )
as

 cursor c5(purchase_id integer) is
  select sb.shopping_id,um.umo_id, um.extras.photo_name photo_name, dbms_lob.getlength(um.photo_original.source.localdata) contentlength, um.photo_original.fileformat fileformat, um.ftp_location, um.ftp_virtual_dir, sb.must_download
  from shopping_basket sb, umo um
  where sb.poid = purchase_id and
        ( (nvl(dbms_lob.getlength(um.photo_original.source.localdata),0) > 0) or (um.ftp_location is not null) ) and
        sb.phid = um.umo_id and
        sb.ppm_id is null and
        sb.ppm_title is null
  union all
  select sb.shopping_id,sb.phid, sb.umo_photo_name photo_name, sb.contentlength, p1.value_a || '-' || p1.value_b fileformat, sb.ftp_location, sb.ftp_virtual_dir, sb.must_download
  from shopping_basket sb, phg_price_object p1, phg_price_object_defn p2
  where sb.poid = purchase_id and
        sb.ppm_id = p1.ppm_id and
        sb.ppm_title = p1.title and
        p1.ppm_id = p2.ppm_id and
        p2.multiple_type = 'T'
  order by 1;

 cursor c5w(purchase_id integer) is
  select sb.shopping_id,um.umo_id, um.extras.photo_name photo_name, dbms_lob.getlength(um.photo_master.source.localdata) contentlength, um.photo_original.fileformat fileformat, um.ftp_location, um.ftp_virtual_dir, sb.must_download
  from shopping_basket sb, umo um
  where sb.poid = purchase_id and
        ( (nvl(dbms_lob.getlength(um.photo_master.source.localdata),0) > 0) or (um.ftp_location is not null) ) and
        sb.phid = um.umo_id and
        sb.ppm_id is null and
        sb.ppm_title is null
  union all
  select sb.shopping_id,sb.phid, sb.umo_photo_name photo_name, sb.contentlength, p1.value_a || '-' || p1.value_b fileformat, sb.ftp_location, sb.ftp_virtual_dir, sb.must_download
  from shopping_basket sb, phg_price_object p1, phg_price_object_defn p2
  where sb.poid = purchase_id and
        sb.ppm_id = p1.ppm_id and
        sb.ppm_title = p1.title and
        p1.ppm_id = p2.ppm_id and
        p2.multiple_type = 'T'
  order by 1;

 cursor c6(purchase_id integer) is
  select sb.shopping_id,sb.phid umo_id, sb.umo_photo_name photo_name, sb.contentlength, p1.value_a || '-' || p1.value_b fileformat, sb.ftp_location, sb.ftp_virtual_dir, sb.must_download
  from shopping_basket sb, phg_price_object p1, phg_price_object_defn p2
  where sb.poid = purchase_id and
        sb.ppm_id = p1.ppm_id and
        sb.ppm_title = p1.title and
        p1.ppm_id = p2.ppm_id and
        p2.multiple_type = 'T'
  order by 1;

 cursor c7(sts varchar2) is select status_priority_id from workflow_state_options where work_state = 0 and order_option = sts;

 cursor c8(vpoid integer) is select status from purchase_order where poid = vpoid;

 nstatus     varchar2(100);
 foundrec    boolean;
 nmb1	     integer;
 nmb2	     integer;
 nmb3	     integer;
 c5rec	     c5%ROWTYPE;
 c6rec	     c6%ROWTYPE;
 fnd	     boolean;

begin
 if voidrec.download_original_on_purchase = 'F' and
    voidrec.download_web_on_purchase = 'F' and
    voidrec.download_web_any_time = 'F' and
    voidrec.download_original_any_time = 'F'
  then
   return;
 end if;

 -- Only display if there are records to download
 fnd := FALSE;
 if voidrec.download_original_on_purchase = 'T' or voidrec.download_web_on_purchase = 'T'
  then
   if voidrec.download_original_on_purchase = 'T'
    then
     open c5(prec.poid);
     fetch c5 into c5rec;
     fnd := c5%FOUND;
     close c5;
   end if;
   if voidrec.download_web_on_purchase = 'T'
    then
     if not fnd
      then
       open c5w(prec.poid);
       fetch c5w into c5rec;
       fnd := c5w%FOUND;
       close c5w;
     end if;
   end if;
  else
   open c6(prec.poid);
   fetch c6 into c6rec;
   fnd := c6%FOUND;
   close c6;
 end if;
 if not fnd then return; end if;

 -- Extract latest status
 open c8(prec.poid);
 fetch c8 into nstatus;
 close c8;

 -- Check Payment Received giving access, or at least ordered giving access
 open c7('Order Authorised');
 fetch c7 into nmb1;
 close c7;
 open c7(nstatus);
 fetch c7 into nmb2;
 close c7;
 open c7('Ordered');
 fetch c7 into nmb3;
 close c7;

 if prec.poid is not null and
    voidrec.payment_cc_down_only = 'T' and
    nmb2 >= nmb1
  then
   null;
 elsif prec.poid is not null and
    voidrec.payment_cc_down_only = 'F' and
    nmb2 >= nmb3
  then
   null;
 else
   glbx.header_msg( LNG4.AHC_TXT_372 );
   return;
 end if;

 foundrec := FALSE;
 htp.nl;
 htp.bold( LNG.ORD_TXT_163 );
 htp.nl;
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.PHG_TXT_022 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG3.ADM_TXT_597 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   -- htp.tabledata( htf.bold( LNG3.ADM_TXT_598 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' ); (now displays if orig)
   htp.tabledata( htf.bold( LNG3.ADM_TXT_599 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;

 if voidrec.download_original_on_purchase = 'T' or voidrec.download_web_on_purchase = 'T'
  then
   if voidrec.download_original_on_purchase = 'T'
    then
     for c5rec in c5(prec.poid) loop
       if c5rec.contentlength > 0
        then
         foundrec := TRUE;
         htp.tablerowopen;
          htp.tabledata( htf.anchor( 'fname.download_file?surl=' || glbx.rndsurl(surl) || '&v_umo=' || c5rec.umo_id || '&purchid=' || prec.poid || '&acid=' || acid, nvl(c5rec.photo_name,LNG3.ADM_TXT_351)), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
          if nvl(c5rec.contentlength,0) > 0
           then
            htp.tabledata( LNG3.ADM_TXT_321 || ' (' || c5rec.contentlength || ')', cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
           else
            htp.tabledata( LNG3.ADM_TXT_321, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
          end if;
          --htp.tabledata( nvl(to_char(c5rec.contentlength),LNG.PHG_TXT_247), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
          htp.tabledata( nvl(c5rec.fileformat,LNG.PHG_TXT_247), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
         htp.tablerowclose;
       end if;
       if c5rec.ftp_location is not null
        then
         foundrec := TRUE;
         htp.tablerowopen;
          htp.tabledata( htf.anchor2( 'fname.download_file?surl=' || glbx.rndsurl(surl) || '&shp=' || c5rec.shopping_id || '&v_umo=' || c5rec.umo_id || '&purchid=' || prec.poid || '&mthod=FTP&acid=' || acid, nvl(c5rec.photo_name,LNG3.ADM_TXT_351), ctarget=>'FTP_DOWNLOAD_WINDOW' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
          if nvl(c5rec.contentlength,0) > 0
           then
            htp.tabledata( LNG3.ADM_TXT_600 || ' (' || c5rec.contentlength || ')', cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
           else
            htp.tabledata( LNG3.ADM_TXT_600, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
          end if;
          htp.tabledata( nvl(c5rec.fileformat,LNG.PHG_TXT_247), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
         htp.tablerowclose;
       end if;
     end loop;
   end if;

   if voidrec.download_web_on_purchase = 'T'
    then
     for c5rec in c5w(prec.poid) loop
       if c5rec.contentlength > 0
        then
         foundrec := TRUE;
         htp.tablerowopen;
          htp.tabledata( htf.anchor( 'fname.download_file?surl=' || glbx.rndsurl(surl) || '&v_umo=' || c5rec.umo_id || '&purchid=' || prec.poid || '&mthod=WEB&acid=' || acid, nvl(c5rec.photo_name,LNG3.ADM_TXT_351)), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
          if nvl(c5rec.contentlength,0) > 0
           then
            htp.tabledata( LNG3.ADM_TXT_321 || ' (' || c5rec.contentlength || ')', cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
           else
            htp.tabledata( LNG3.ADM_TXT_321, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
          end if;
          htp.tabledata( nvl(c5rec.fileformat,LNG.PHG_TXT_247), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
         htp.tablerowclose;
       end if;
       if c5rec.ftp_location is not null and voidrec.download_original_on_purchase = 'F'
        then
         foundrec := TRUE;
         htp.tablerowopen;
          htp.tabledata( htf.anchor2( 'fname.download_file?surl=' || glbx.rndsurl(surl) || '&shp=' || c5rec.shopping_id || '&v_umo=' || c5rec.umo_id || '&purchid=' || prec.poid || '&mthod=FTP&acid=' || acid, nvl(c5rec.photo_name,LNG3.ADM_TXT_351), ctarget=>'FTP_DOWNLOAD_WINDOW' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
          if nvl(c5rec.contentlength,0) > 0
           then
            htp.tabledata( LNG3.ADM_TXT_600 || ' (' || c5rec.contentlength || ')', cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
           else
            htp.tabledata( LNG3.ADM_TXT_600, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
          end if;
          htp.tabledata( nvl(c5rec.fileformat,LNG.PHG_TXT_247), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
         htp.tablerowclose;
       end if;
     end loop;
   end if;

  else

   for c6rec in c6(prec.poid) loop
     if c6rec.contentlength > 0
      then
       foundrec := TRUE;
       htp.tablerowopen;
        htp.tabledata( htf.anchor( 'fname.download_file?surl=' || glbx.rndsurl(surl) || '&v_umo=' || c6rec.umo_id || '&purchid=' || prec.poid || '&acid=' || acid, nvl(c6rec.photo_name,LNG3.ADM_TXT_351)), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
          if nvl(c6rec.contentlength,0) > 0
           then
            htp.tabledata( LNG3.ADM_TXT_321 || ' (' || c6rec.contentlength || ')', cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
           else
            htp.tabledata( LNG3.ADM_TXT_321, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
          end if;
        htp.tabledata( nvl(c6rec.fileformat,LNG.PHG_TXT_247), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tablerowclose;
     end if;
     if c6rec.ftp_location is not null
      then
       foundrec := TRUE;
       htp.tablerowopen;
        htp.tabledata( htf.anchor2( 'fname.download_file?surl=' || glbx.rndsurl(surl) || '&shp=' || c6rec.shopping_id || '&v_umo=' || c6rec.umo_id || '&purchid=' || prec.poid || '&mthod=FTP&acid=' || acid, nvl(c6rec.photo_name,LNG3.ADM_TXT_351), ctarget=>'FTP_DOWNLOAD_WINDOW' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
          if nvl(c6rec.contentlength,0) > 0
           then
            htp.tabledata( LNG3.ADM_TXT_600 || ' (' || c6rec.contentlength || ')', cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
           else
            htp.tabledata( LNG3.ADM_TXT_600, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
          end if;
        htp.tabledata( nvl(c6rec.fileformat,LNG.PHG_TXT_247), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tablerowclose;
     end if;
   end loop;
  end if;

   htp.tableclose;
   if not foundrec then htp.bold( LNG.ORD_TXT_164 ); htp.nl; end if;
exception when others then
 glbx.error_details( 'FNAME', 'LIST_DOWNLOADABLE',errmsg=>sqlerrm,extdet=>'POID:' || prec.poid);
end list_downloadable;

procedure htp_bfile( vfname in varchar2, rpc in varchar2 )
as

 v_buffer	raw(30000);
 v_count	integer;
 v_int		integer;
 fname		varchar2(100);
 load_dir	varchar2(100);
 cursor_name	integer;
 dummy		integer;
 inf_prot	integer;
 sqlstmt	varchar2(1000);

begin
    v_count := 0;
    v_int := 30000;
    v_buffer := NULL;
    load_dir := 'PICTION_LOAD_DIR';
    fname := vfname;
    inf_prot := 1;
    owa_util.mime_header('image/jpeg');
    sqlstmt := 'begin ' || trim(rpc) || '( load_dir=>:load_dir, fname=>:fname, v_int=>:v_int, v_count=>:v_count, v_buffer=>:v_buffer ); end;';

    loop
      cursor_name := dbms_sql.open_cursor;
      dbms_sql.parse( cursor_name, sqlstmt, dbms_sql.native );
      dbms_sql.bind_variable_char(cursor_name, ':load_dir', load_dir, 100);
      dbms_sql.bind_variable_char(cursor_name, ':fname', fname, 100);
      dbms_sql.bind_variable(cursor_name, ':v_int', v_int);
      dbms_sql.bind_variable(cursor_name, ':v_count', v_count);
      dbms_sql.bind_variable_raw(cursor_name, ':v_buffer', v_buffer, 30000);
      dummy := dbms_sql.execute( cursor_name );
      dbms_sql.variable_value(cursor_name, ':v_int', v_int);
      dbms_sql.variable_value(cursor_name, ':v_count', v_count);
      dbms_sql.variable_value_raw(cursor_name, ':v_buffer', v_buffer);
      dbms_sql.close_cursor( cursor_name );

      if v_count > 200000 or v_buffer is null or inf_prot > 20000 -- Infinite Loop Protection (just in case). This approx 4Gb.
       then
        exit;
       else
        htp.prn( sys.utl_raw.cast_to_varchar2(v_buffer) );
      end if;
      inf_prot := inf_prot + 1;
    end loop;

exception when others then
 glbx.error_details( 'FNAME', 'HTP_BFILE',null,null,errmsg=>sqlerrm,extdet=>'VFNAME:' || vfname || ' RPC:' || rpc );
end htp_bfile;

function booking_order(vpoid integer)
 return boolean
as
 cursor cbook(vpoid integer) is select count('x') tot from shopping_basket where isgallery = 'B' and poid = vpoid;
 crec   cbook%ROWTYPE;
begin
 open cbook(vpoid);
 fetch cbook into crec;
 close cbook;
 if crec.tot = 0 then return( FALSE ); end if;
 return( TRUE );
exception when others then return( FALSE );
end booking_order;

procedure disp_currency( surl varchar2, curr in varchar2 default null, acid in integer)
as

 cursor c2( convcurr number) is select date_update,country,to_dollar,in_dollar,to_dollar*convcurr rate from currency_conversion order by country;

 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.DISP_CURRENCY' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := glbx.get_cusrec( sess_id, ltype, acid, profid );
 theme_rec := glbx.get_theme_types( c1rec.theme_type );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.ORD_TXT_225,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'O21',stype=>stype+1,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );

 htp.header( 3, LNG.CST_TXT_103 || ': ' || to_char(to_number(curr),LNG.MONEY_FORMAT), 'CENTER' );
 htp.header( 4, LNG.ORD_TXT_226, 'CENTER' );
 htp.header( 4, LNG.ORD_TXT_227, 'CENTER' );

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1 ' );
    htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.ORD_TXT_229), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( htf.bold(LNG.CST_TXT_116), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( htf.bold(LNG.ORD_TXT_230), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( htf.bold(LNG.ORD_TXT_231), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tablerowclose;
  for c2rec in c2(to_number(curr)) loop
    htp.tablerowopen;
       htp.tabledata( to_char(c2rec.date_update,LNG.MASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( initcap(c2rec.country), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( to_char(c2rec.to_dollar), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
       htp.tabledata( htf.bold(to_char(round(c2rec.rate,2))), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
    htp.tablerowclose;
  end loop;
 htp.tableclose;

 htp.nl;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 htp.nl;

 htp.p( '</CENTER>' );

 glbx.close_page( pfx );
exception when others then
 glbx.error_details( 'FNAME', 'DISP_CURRENCY',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end disp_currency;

procedure cancel_order( surl varchar2, msg in varchar2 default null, acid in integer)
as

 cursor c2(sess_id integer) is select * from purchase_order where sessid = sess_id;
 cursor c3(void integer) is select * from order_style where oid = void;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 voidrec	order_style%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.CANCEL_ORDER' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := glbx.get_cusrec( sess_id, ltype, acid, profid );
 theme_rec := glbx.get_theme_types( c1rec.theme_type );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.ORD_TXT_067,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'O10',stype=>stype+1,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 open c2( sess_id );
 fetch c2 into c2rec;
 close c2;
 open c3(c2rec.oid);
 fetch c3 into voidrec;
 close c3;
 htp.p( '<CENTER>' );
 htp.nl;
 htp.header( 3, voidrec.text_purchase_request || '# ' || c2rec.poid, 'CENTER' );
 htp.nl;
 if msg is not null
  then
   glbx.header_msg( msg );
 end if;

 htp.tableopen( cattributes=>'cellpadding=6 cellspacing=0 border=0 ' || glbx.TABLE_BACKGROUND );
 htp.tablerowopen;

  htp.p( '<TD>' );
  htp.p( '<CENTER>' );
  htp.tableopen( cattributes=>'cellpadding=4 cellspacing=1 border=0 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
       htp.tabledata( htf.bold(voidrec.text_cancel_msg), cattributes=>'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;
  htp.tablerowopen;
       htp.tabledata( htf.anchor('fname.confirm_cancel_order?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/order_cancel.gif',cattributes=>'border=0',calt=>LNG.ORD_ALT_071 || to_char(c2rec.poid) )), cattributes=>'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;
  htp.tableclose;

  htp.p( '</CENTER>' );
  htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.formclose;

 htp.p( '</CENTER>' );

 glbx.close_page( pfx );
exception when others then
 glbx.error_details( 'FNAME', 'CANCEL_ORDER',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end cancel_order;

procedure confirm_cancel_order( surl varchar2, msg in varchar2 default null, acid in integer)
as

 cursor c4(session_id integer) is
  select ca.aid,ca.account_name,ph.pid,ph.business_name,ph.contact_email
  from customer_account ca,login_session ls, photographer ph
  where ls.sessid = session_id and
        ca.aid = ls.aid and
        ca.pid = ph.pid;
 cursor c5(purchase_id integer) is
  select sb.ppi,qty,p.product_id,p.current_stock
  from shopping_basket sb, phg_price_item ppit, product p
  where sb.poid = purchase_id and
        ppit.ppi = sb.ppi and
        ppit.lab_id = p.product_id and
        current_stock is not null;
 cursor c10( vpoid integer ) is select poid,photo_size,photo_cost,isgallery from shopping_basket where poid = vpoid;

 cusrec		CUSTOMER_ACCOUNT%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	THEME_TYPES%ROWTYPE;
 purchord 	PURCHASE_ORDER%ROWTYPE;
 voidrec	ORDER_STYLE%ROWTYPE;
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 ltype		varchar2(100);
 c4rec		c4%ROWTYPE;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.CONFIRM_CANCEL_ORDER' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
 -- Business Feature overriden, get the other one
 if voidrec.bftr <> 'Use Customer Account Business Feature'
  then
   theme_rec := glbx.get_theme_types( voidrec.bftr );
 end if;

 if voidrec.laf <> 'Use Customer Account Look and Feel'
  then
   pfx := glbx.get_thm( voidrec.laf );
 end if;

 open c4(sess_id);
 fetch c4 into c4rec;
 close c4;

 if purchord.status not in ('PreOrder - No Order Made',LNG.ORD_TXT_120,LNG4.AHC_TXT_672,LNG4.AHC_TXT_706,'PreOrder - Confirmed without Payment')
  then

    gcode(1) := 'PURCHASE_ORDER_ID';
    gparam(1) := purchord.poid;
    gcode(2) := 'CURRTIME';
    gparam(2) := to_char(sysdate,LNG.TSMASK);
    gcode(3) := 'SIGNATURE';
    gparam(3) := glbx.extract_master_parameter('MAIL SIGNATURE');
    add_poid_values( purchord.poid, gcode, gparam );
    -- Send to Administrator
    if (glbx.extract_master_parameter('SEND_EMAIL_TO_ADMIN') = 'TRUE') or
       (glbx.extract_master_parameter('SEND_EMAIL_TO_ADMIN') = 'FALSE' and glbx.extract_master_parameter('ADMIN_EMAIL_CREDIT') = 'TRUE' and purchord.paid_method  in ('MERCHANT','GIFT'))
     then
      glbx.send( gcode, gparam, 'order_cancelled.tmp', p_to=>nvl(glbx.extract_master_parameter('PICTION_EMAIL_ACCT'),glbx.extract_master_parameter('MAIL_FROM')),p_subj=>LNG.ORD_TXT_073  || purchord.poid,p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'OC1', v_pid=>cusrec.pid, v_aid=>cusrec.aid, v_profile_id=>profid);
    end if;
    -- Send to Photographer
    glbx.send( gcode, gparam, 'order_cancelled.tmp', p_to=>c4rec.contact_email,p_subj=>LNG.ORD_TXT_073 || purchord.poid,p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'OC1', v_pid=>cusrec.pid, v_aid=>cusrec.aid, v_profile_id=>profid);
 end if;

 -- Increment Stock Level
 for c5rec in c5( purchord.poid ) loop
  update product
   set
    current_stock = current_stock - c5rec.qty
  where
   product_id = c5rec.product_id;
  insert into product_stock_audit(product_id,audit_date,stock_adj,activity) values
      (c5rec.product_id,sysdate,c5rec.qty,'[7] Stock Level Increased after Purchase Order Cancelled (' || purchord.poid || '):' || to_char(c5rec.current_stock - c5rec.qty));
 end loop;
 commit;

 -- Refund Gift Certificate
 insert into gift_certificate_usage(certificate_id,poid,aid,date_used,amount_used)
  select certificate_id,poid,aid,sysdate,(-1 * sum(amount_used))
  from gift_certificate_usage
  where poid = purchord.poid
  group by certificate_id,poid,aid;

 -- Audit All Details
 for c10rec in c10( purchord.poid ) loop
  purchase_audit_trail( surl, c10rec.poid, 'DELETE FROM BASKET', 'D', 'C', c10rec.photo_size || '-' || c10rec.photo_cost || '(' || c10rec.isgallery || ')', purchord, voidrec );
 end loop;
 delete from umo where sessid is not null and umo_id in (select phid from shopping_basket where poid = purchord.poid and isgallery in ('F') and phid is not null );
 delete from shopping_basket where poid = purchord.poid;
 delete from purchase_package_product where poid = purchord.poid;
 delete from order_contact_phone_number where poid = purchord.poid;
 update purchase_order
  set
   delivery_cost = null,
   other_cost  = null,
   gst_incl = null,
   date_purchased  = null,
   date_fulfilled  = null,
   status  = LNG.ORD_TXT_120,
   event_confirmed  = 'F',
   event_issue  = 'F',
   event_shipped   = 'F',
   contact_password  = null,
   local_internation = null
 where poid = purchord.poid;

 purchase_audit_trail( surl, purchord.poid, 'DELIVERY_COST', 'U', 'C', null, purchord, voidrec);
 purchase_audit_trail( surl, purchord.poid, 'OTHER_COST', 'U', 'C', null, purchord, voidrec);
 purchase_audit_trail( surl, purchord.poid, 'GST_INCL', 'U', 'C', null, purchord, voidrec);
 purchase_audit_trail( surl, purchord.poid, 'STATUS', 'U', 'C', LNG.ORD_TXT_120, purchord, voidrec);
 purchase_audit_trail( surl, purchord.poid, 'EVENT_CONFIRMED', 'U', 'C', 'F', purchord, voidrec);
 purchase_audit_trail( surl, purchord.poid, 'EVENT_ISSUE', 'U', 'C', 'F', purchord, voidrec);
 purchase_audit_trail( surl, purchord.poid, 'EVENT_SHIPPED', 'U', 'C', 'F', purchord, voidrec);
 purchase_audit_trail( surl, purchord.poid, 'CONTACT_PASSWORD', 'U', 'C', null, purchord, voidrec);
 purchase_audit_trail( surl, purchord.poid, 'LOCAL_INTERNATION', 'U', 'C', null, purchord, voidrec);

 commit;
 fname.acct_orders( surl, LNG.ORD_TXT_074, acid=>acid );

exception when others then
 glbx.error_details( 'FNAME', 'CONFIRM_CANCEL_ORDER',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end confirm_cancel_order;

procedure recalc_order(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, inpopup in char default null )
as

 jscript		varchar2(1000);
 jscript_close		varchar2(1000);

begin
 glbx.main_title( surl, LNG.PHG_TXT_093, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'O11',stype=>stype+1,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>nvl(inpopup,pfx.keep_lhf), finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);

 htp.p( '<CENTER>' );
 htp.nl;
 htp.header( 3, voidrec.text_purchase_request || '# ' || purchord.poid, 'CENTER' );
 htp.nl;

 if pfx.fullimg_jscript_popup = 'T'
  then
   jscript := 'javascript: window.opener.location = ''';
   jscript_close := '''; window.close();';
  else
   jscript := null;
   jscript_close := null;
 end if;

if purchord.status in ('Awaiting Authorisation','Ordered','Order Authorised','Order Payment Received')
 then
  htp.nl;
  htp.header( 3, LNG.ORD_TXT_076, 'CENTER' );
  htp.nl;
  htp.nl;
  if purchord.paid_method not in ( 'MERCHANT','GIFT' ) and voidrec.payment_can_cancel_noncc = 'T'
   then
    htp.header( 3, LNG.ORD_TXT_077, 'CENTER' );
    htp.nl;
    htp.nl;
    htp.anchor( jscript || 'fname.cancel_order?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || jscript_close, htf.img( DECS.IMAGE_LOCATION || 'adminc/order_cancel.gif',cattributes=>'border=0',calt=>LNG.ORD_TXT_061 )|| ' ' || LNG.ORD_TXT_061);
    htp.nl;
    htp.nl;
    htp.nl;
    htp.nl;
    htp.anchor2( jscript || 'glbx.relogin?surl=' || surl || '&acid=' || acid || jscript_close, LNG4.AHC_TXT_320, ctarget=>'_top' );
   else
    -- Credit Card Order, cannot be cancelled
    htp.nl;
    glbx.header_msg( LNG2.PBK_TXT_125 );
    htp.nl;
    htp.anchor2( jscript || 'glbx.relogin?surl=' || surl || '&acid=' || acid || jscript_close, LNG4.AHC_TXT_320, ctarget=>'_top' );
  end if;

else

  htp.nl;
  htp.header( 3, LNG.ORD_TXT_081 || ':' || purchord.status, 'CENTER' );
  htp.nl;
  glbx.header_msg( LNG.ORD_TXT_082 );
  htp.nl;
  htp.anchor2( jscript || 'glbx.relogin?surl=' || surl || '&acid=' || acid || jscript_close, LNG4.AHC_TXT_320, ctarget=>'_top' );

end if;

htp.p( '</CENTER>' );

 glbx.close_page( pfx );
exception when others then
 glbx.error_details( 'FNAME', 'RECALC_ORDER',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end recalc_order;

procedure confirm_payment( surl in varchar2, acid in integer, typ in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 cursor c3(phid integer) is select * from photographer where pid = phid;

 c3rec		c3%ROWTYPE;
 cusrec		CUSTOMER_ACCOUNT%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	THEME_TYPES%ROWTYPE;
 purchord 	PURCHASE_ORDER%ROWTYPE;
 voidrec	ORDER_STYLE%ROWTYPE;
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 ltype		varchar2(100);
 cens_pnmb	varchar2(20);
 cens_cdet	varchar2(200);
 txt		varchar2(1000);
 txt2		varchar2(1000);
 retlink	varchar2(1000);

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.ACCT_ORDERS' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
 -- Business Feature overriden, get the other one
 if voidrec.bftr <> 'Use Customer Account Business Feature'
  then
   theme_rec := glbx.get_theme_types( voidrec.bftr );
 end if;

 if voidrec.laf <> 'Use Customer Account Look and Feel'
  then
   pfx := glbx.get_thm( voidrec.laf );
 end if;

 if purchord.paid_method = 'PHONE'
  then

   -- Update Phone Details
   delete from order_contact_phone_number where poid = purchord.poid;
   for j in p1.first..p1.last loop
    if p1(j) is not null
     then
       cens_pnmb := substr(glbx.censor(p1(j)),1,20);
       cens_cdet := substr(glbx.censor(p2(j)),1,200);
       insert into order_contact_phone_number(poid,pnumber,contact_det) values (purchord.poid,cens_pnmb,cens_cdet);
    end if;
   end loop;
   -- Superfluous error message
   --txt := voidrec.text_order_problem || ':' || nvl(c3rec.work_phone,c3rec.mobile_phone);
   txt := NULL;

 elsif purchord.paid_method = 'CHEQUE'
  then
   txt := voidrec.text_print_cheque;

 end if;

 finalise_payment(surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, null );

 if voidrec.disp_receipt = 'T'
  then

   -- Call User Exit if its built into the Look and Feel
   if pfx.order_show_receipt is not null
    then
      execute immediate
       'begin ' || pfx.order_show_receipt ||
       '(surl=>:surl,theme_data=>:theme_data,ltype=>:ltype,acid=>:acid,void=>:void,purchid=>:purchid);' ||
       'end;'
      using glbx.rndsurl(surl),theme_rec.theme_data,ltype,acid,voidrec.oid,purchord.poid;
      return;
   end if;

   customer_receipt(surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, txt );

  else

   --retlink := return_link( surl, stype, ltype, voidrec, pfx, acid, location=>'2' );
   if voidrec.disp_purch_request_heading = 'T'
    then
     txt2 := voidrec.text_page5 || ' [' || purchord.poid || ']';
    else
     txt2 := voidrec.text_page5;
   end if;
   glbx.main_title( surl, txt2, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'O05',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,retlink=>retlink,stylesh=>pfx.stylesheet);
   htp.p( '<CENTER>' );
   disp_tracing_style(surl, stype, voidrec, pfx, purchord, 'FINAL_RECEIPT', acid, ltype, theme_rec );
   htp.nl;
   if voidrec.text_phg_title is not null then htp.bold( voidrec.text_phg_title ); htp.nl; end if;
   if purchord.paid_method = 'PHONE'
    then
     open c3(cusrec.pid);
     fetch c3 into c3rec;
     close c3;
     check_business_hours( surl, acid, c3rec, voidrec );
     htp.nl;
     htp.bold( LNG.CST_TXT_070 || ':' || nvl(c3rec.work_phone,c3rec.mobile_phone) );
     htp.nl;

   elsif purchord.paid_method = 'CHEQUE'
    then
     confirm_cheque(surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, null );

   else
    htp.bold( 'Your ' || voidrec.text_purchase_request || '#' || purchord.poid );
    htp.nl;
    htp.p( 'Your Order has been Confirmed' );
    htp.nl;
    htp.nl;
    htp.nl;
    glbx.header_msg( LNG2.PBK_TXT_125 );
    htp.nl;
    htp.anchor2( 'glbx.relogin?surl=' || surl || '&acid=' || acid, LNG4.AHC_TXT_320, ctarget=>'_top' );

   end if;

   display_order_tracking( pfx, purchord, voidrec, null );
   setup_new_account( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
   list_downloadable( surl, purchord, pfx, theme_rec, voidrec, acid );
   if purchord.paid_method = 'MERCHANT' and glbx.extract_master_parameter('MERCHANT_POP_WINDOW') = 'TRUE'
    then
     htp.nl;
     htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
   end if;

 if pfx.ord_inc_simple = 'T'
  then
    cst.disp_standard_search(surl, stype, ltype, profid, acid, cusrec, pfx, theme_rec, 'SIMPLE' );
    if pfx.ord_inc_privacy = 'T' then htp.nl; end if;
 end if;

 if pfx.ord_inc_privacy = 'T'
  then
    cst.disp_privacy(surl, ltype, profid, acid, cusrec, pfx, theme_rec );
 end if;

 display_phg_order_button( surl, sess_id );

 if pfx.order_bottom_external is not null
  then
    execute immediate
      'begin ' || pfx.order_bottom_external ||
       '(surl=>:surl,ltype=>:ltype,acid=>:acid,screen_location=>:screen_location);' ||
       'end;'
     using glbx.rndsurl(surl),ltype,acid,'FINAL_RECEIPT';
  end if;
  htp.p( '</CENTER>' );
 glbx.close_page( pfx );
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'CONFIRM_PAYMENT',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end confirm_payment;

procedure display_phg_order_button( surl in varchar2, sess_id in integer )
as

 cursor c1(sess_id integer) is select count('x') cnt from purchase_order po, shopping_basket sb where po.sessid = sess_id and po.poid = sb.poid and sb.isgallery = 'Z';
 cursor c2(sess_id integer) is select * from shopping_basket where poid = (select poid from purchase_order where sessid = sess_id);

 c1rec  c1%ROWTYPE;
 p0	GLBX.MYARRAY;
 p1	GLBX.MYARRAY;
 p2	GLBX.MYARRAY;

begin
 -- Routine to test if a Photographer has purchased an online account and display a button, update the charge plan
 open c1(sess_id);
 fetch c1 into c1rec;
 close c1;
 if nvl(c1rec.cnt,0) = 0 then return; end if;

 for c2rec in c2(sess_id) loop
  p0(c2%ROWCOUNT) := c2rec.lab_id;
  p1(c2%ROWCOUNT) := c2rec.photo_size;
  p2(c2%ROWCOUNT) := c2rec.qty;
 end loop;
 pbk.confirm_increase_event(surl, p0, p1, p2, action=>'BYPASS' );

 htp.nl;
 htp.formopen( 'phg.phg_create_new_acct' );
 htp.formhidden( 'SURL', surl );
 htp.formsubmit( null, 'Return to Account Creation Screen' );
 htp.formclose;
 htp.nl;

exception when others then
 glbx.error_details( 'FNAME', 'DISPLAY_PHG_ORDER_BUTTON',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end display_phg_order_button;

procedure confirm_cheque(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null)
as

 cursor phg( phgid integer ) is select * from photographer where pid = phgid;

 phgrec		phg%ROWTYPE;
 grand_ttl	number;

begin
 open phg( purch.pid );
 fetch phg into phgrec;
 close phg;
 grand_ttl := glbx.grand_total_payment( purch.poid, TRUE );
 htp.bold( voidrec.text_print_cheque );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=4 cellspacing=1 rules="NONE" frame="HSIDES,VSIDES" border=' || pfx.ord_text_table_border );
  htp.tablerowopen;
   htp.tabledata( htf.bold(voidrec.text_purchase_request || '#'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( htf.bold(purch.poid), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(voidrec.text_grandtotal), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( htf.bold(to_char( grand_ttl, LNG.MONEY_FORMAT)), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.CST_TXT_004), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( nvl(phgrec.business_name,'&nbsp;'), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_022), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( nvl(phgrec.contact_name,'&nbsp;'), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.CST_TXT_113), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( nvl(phgrec.contact_street,'&nbsp;'), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.CST_TXT_114), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( nvl(phgrec.contact_suburb,'&nbsp;'), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.CST_TXT_115), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( nvl(phgrec.contact_city,'&nbsp;'), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.CST_TXT_118), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( nvl(phgrec.contact_pcode,'&nbsp;'), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(phgrec.abn_title), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( nvl(phgrec.abn_number,'&nbsp;'), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 if voidrec.fax_merchant_enabled = 'T'
  then
   cheque_fax_details(surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purch, voidrec, phgrec );
 end if;

end confirm_cheque;

procedure cheque_fax_details(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, phgrec in photographer%ROWTYPE )
as
begin
 if voidrec.fax_merchant_box_dotted = 'T'
  then
   -- Draw Separator Line
   htp.nl;
   htp.line;
   htp.nl;
 end if;

 if voidrec.fax_merchant_border = 'T'
  then
   -- Draw Box Around Details
   htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=1' );
   htp.tablerowopen;
   htp.p( '<TD>' );
 end if;

 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
  -- Text above
  if voidrec.fax_merchant_text_above is not null
   then
    htp.tablerowopen;
     htp.tabledata( voidrec.fax_merchant_text_above, cattributes=>'align="LEFT" colspan="2"' );
    htp.tablerowclose;
  end if;

  -- Display Credit Card Options
  htp.tablerowopen;
  htp.p( '<TD align="LEFT" colspan="2">' );
  if phgrec.cc_bankcard = 'T'
   then
    htp.p( ' [ ] Bankcard' );
  end if;
  if phgrec.cc_visa = 'T'
   then
    htp.p( ' [ ] Visa' );
  end if;
  if phgrec.cc_mastercard = 'T'
   then
    htp.p( ' [ ] Mastercard' );
  end if;
  if phgrec.cc_amex = 'T'
   then
    htp.p( ' [ ] Amex' );
  end if;
  if phgrec.cc_diners = 'T'
   then
    htp.p( ' [ ] Diners' );
  end if;
  htp.p( '</TD>' );
  htp.tablerowclose;

  -- Display Credit Number Entry
  htp.tablerowopen;
  htp.p( '<TD align="LEFT" colspan="2">' );
   htp.p( '|__|__|__|__|  |__|__|__|__|  |__|__|__|__|  |__|__|__|__|' );
  htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata('&nbsp;', cattributes=>'align="LEFT" colspan="2"' );
  htp.tablerowclose;

  -- Signature and Expiry
  htp.tablerowopen;
   htp.tabledata( 'Signature: _______________________', cattributes=>'align="LEFT"' );
   htp.tabledata( 'Expiry Date: _____ / ______', cattributes=>'align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata('&nbsp;', cattributes=>'align="LEFT" colspan="2"' );
  htp.tablerowclose;

  -- Name on Card
  htp.tablerowopen;
   htp.tabledata( 'Name on Card: ____________________________________________', cattributes=>'align="LEFT" colspan="2"' );
  htp.tablerowclose;

  if voidrec.fax_merchant_text_below is not null
   then
    htp.tablerowopen;
     htp.tabledata( voidrec.fax_merchant_text_below, cattributes=>'align="LEFT" colspan="2"' );
    htp.tablerowclose;
  end if;
 htp.tableclose;

 if voidrec.fax_merchant_border = 'T'
  then
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tableclose;
 end if;
end cheque_fax_details;

procedure calc_due_date( vpoid in integer )
as

 cursor c1(vpoid integer) is select * from shopping_basket where poid = vpoid;
 cursor c2(vpoid integer) is select * from purchase_order where poid = vpoid;

 c2rec	c2%ROWTYPE;
 ddate	date;

begin

 open c2(vpoid);
 fetch c2 into c2rec;
 close c2;
 for c1rec in c1(vpoid) loop
  ddate := sysdate;
  if c2rec.home_country = c2rec.sendto_country
   then
    ddate := ddate + nvl(c1rec.production_time,0) + nvl(c1rec.delivery_time_local,0);
   else
    ddate := ddate + nvl(c1rec.production_time,0) + nvl(c1rec.delivery_time_int,0);
  end if;
  update shopping_basket
   set
    estimated_due_date = ddate
  where
   shopping_id = c1rec.shopping_id;
 end loop;
 commit;

exception when others then
 glbx.error_details( 'FNAME', 'CALC_DUE_DATE',null,null,errmsg=>sqlerrm,extdet=>'VPOID:' || vpoid);
end calc_due_date;

procedure calc_booking( vpoid in integer )
as

 cursor c1(vpoid integer) is select * from shopping_basket where poid = vpoid and isgallery = 'B';

 ddate	date;

begin

 for c1rec in c1(vpoid) loop
  update booking
   set
    status = 'Visit Complete'
  where
   purchase_order_id = vpoid;
 end loop;
 commit;

exception when others then
 glbx.error_details( 'FNAME', 'CALC_BOOKING',null,null,errmsg=>sqlerrm,extdet=>'VPOID:' || vpoid);
end calc_booking;

procedure finalise_payment(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null)
as
begin

 -- Calculate Due Date per shopping item
 calc_due_date( purch.poid );

 -- If a booking update the Booking Table status
 calc_booking( purch.poid );

 -- Update Purchase Order Table
 adjust_purchase_table( surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purch, voidrec, null);

 -- Adjust Stock Levels based on Purchase
 adjust_stock( surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purch, voidrec, null);

 -- Configure for B2c
 configure_for_b2c( surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purch, voidrec, null);

 -- Mark Items as Exlusive as Required
 mark_exclusive( surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purch, voidrec, null);

 --Email Details
 email_details( surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purch, voidrec, null);

 -- Email Images if Required
 if voidrec.download_auto_email_web = 'T' and purch.contact_email is not null
  then
   html_email.purchase_order_send(surl, acid );
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'FINALISE_PAYMENT',null,null,errmsg=>sqlerrm);
end finalise_payment;

procedure adjust_purchase_table(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null)
as

 cursor c2(purchase_id integer) is select count('x') tot from order_contact_phone_number where poid = purchase_id;

 c2rec	c2%ROWTYPE;
 ttl	number;

begin

 ttl := glbx.grand_total_payment( purch.poid, include_gift_certificate=>TRUE );
 if purch.paid_method = 'PHONE'
  then
   open c2(purch.poid);
   fetch c2 into c2rec;
   close c2;

   if c2rec.tot = 0
    then
     pay_phone( surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purch, voidrec, LNG.CST_TXT_097);
     return;
   end if;

   update purchase_order
    set status = LNG.ORD_TXT_121,
        initial_grand_total = ttl,
        date_purchased = sysdate,
        last_step = 'Finalise'
    where poid = purch.poid;

    purchase_audit_trail( surl, purch.poid, 'STATUS', 'U', 'C', LNG.ORD_TXT_121, purch, voidrec);
    purchase_audit_trail( surl, purch.poid, 'LAST_STEP', 'U', 'C', 'Finalise', purch, voidrec);

 elsif purch.paid_method = 'CHEQUE'
  then
   update purchase_order
   set status = LNG.ORD_TXT_121,
       initial_grand_total = ttl,
       date_purchased = sysdate,
       last_step = 'Finalise'
    where poid = purch.poid;

    purchase_audit_trail( surl, purch.poid, 'STATUS', 'U', 'C', LNG.ORD_TXT_121, purch, voidrec);
    purchase_audit_trail( surl, purch.poid, 'LAST_STEP', 'U', 'C', 'Finalise', purch, voidrec);

 elsif purch.paid_method = 'AUTHORISATION'
  then

   update purchase_order
    set
     initial_grand_total = ttl,
     date_purchased = sysdate,
     status =  LNG4.AHC_TXT_706 -- 'Awaiting Authorisation'
    where poid = purch.poid and
         status <> 'Order Authorised';
   if sql%FOUND then purchase_audit_trail( surl, purch.poid, 'STATUS', 'U', 'C', LNG4.AHC_TXT_706, purch, voidrec); end if;


 elsif purch.paid_method = 'BILLING'
  then
   update purchase_order
   set status = LNG.ORD_TXT_121,
       initial_grand_total = ttl,
       date_purchased = sysdate,
       last_step = 'Finalise'
    where poid = purch.poid;

    purchase_audit_trail( surl, purch.poid, 'STATUS', 'U', 'C', LNG.ORD_TXT_121, purch, voidrec);
    purchase_audit_trail( surl, purch.poid, 'LAST_STEP', 'U', 'C', 'Finalise', purch, voidrec);

 elsif purch.paid_method in ('MERCHANT','GIFT')
  then
   update purchase_order
   set initial_grand_total = ttl,
       last_step = 'Finalise'
    where poid = purch.poid;

 end if;

end adjust_purchase_table;

procedure email_details(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null)
as

 cursor phg( phgid integer ) is select * from photographer where pid = phgid;

 phgrec			phg%ROWTYPE;
 gcode			GLBX.MYARRAY;
 gparam			GLBX.MYARRAY;
 ttl			number;
 gtotal			number;
 parm1			GLBX.MYARRAY;
 parm2			GLBX.MYARRAY_NMB;

begin

 ttl := glbx.total_payment(purch.poid);
 gtotal := glbx.grand_total_payment(purch.poid, include_gift_certificate=>FALSE);
 glbx.calculate_pricing( purch.poid, parm1, parm2 );

 open phg( purch.pid );
 fetch phg into phgrec;
 close phg;

 gcode(1) := 'PURCHASE_ORDER_ID';
 gparam(1) := purch.poid;
 gcode(2) := 'TOTAL_COST';
 gparam(2) := to_char(ttl,LNG.MONEY_FORMAT);
 gcode(3) := 'PHOTOGRAPHER_ID';
 gparam(3) := purch.pid;
 gcode(4) := 'DATE_MADE';
 gparam(4) := to_char(sysdate,LNG.TSMASK);
 gcode(5) := 'NAME';
 gparam(5) := purch.sendto_name;
 gcode(6) := 'STREET';
 gparam(6) := purch.sendto_street;
 gcode(7) := 'SUBURB';
 gparam(7) := purch.sendto_suburb;
 gcode(8) := 'CITY';
 gparam(8) := purch.sendto_city || ' ' || purch.sendto_state;
 gcode(9) := 'COUNTRY';
 gparam(9) := purch.sendto_country;
 gcode(10) := 'PCODE';
 gparam(10) := purch.sendto_postcode;
 gcode(11) := 'PHOTOGRAPHER_BUSINESS';
 gparam(11) := phgrec.business_name;
 gcode(12) := 'CUSTOMER_ID';
 gparam(12) := cusrec.aid;
 gcode(13) := 'CUSTOMER_NAME';
 gparam(13) := cusrec.account_name;
 gcode(14) := 'PICTION_EMAIL';
 gparam(14) := glbx.extract_master_parameter('PICTION_EMAIL_ACCT');
 gcode(15) := 'GRAND_TOTAL';
 gparam(15) := to_char(gtotal,LNG.MONEY_FORMAT);
 gcode(16) := 'PHOTOGRAPHER';
 gparam(16) := nvl(phgrec.business_name,glbx.extract_master_parameter('BAR_TITLE'));
 gcode(17) := 'PHG_PHONE';
 gparam(17) := nvl(phgrec.work_phone,glbx.extract_master_parameter('CONTACT_NUMBER'));
 gcode(18) := 'PHOTOGRAPHER_EMAIL';
 gparam(18) := nvl(phgrec.contact_email,glbx.extract_master_parameter('PICTION_EMAIL_ACCT'));
 gcode(19) := 'SIGNATURE';
 gparam(19) := glbx.extract_master_parameter('MAIL SIGNATURE');
 gcode(20) := 'PAID_METHOD';
 gparam(20) := purch.paid_method;
 gcode(21) := 'BRANCH';
 gparam(21) := purch.sendto_branch;
 gcode(22) := 'DEPARTMENT';
 gparam(22) := purch.sendto_department;
 gcode(23) := 'DISCOUNT';
 gparam(23) := to_char(glbx.retrieve_pricing_value( 'DISCOUNT', parm1, parm2 ),LNG.MONEY_FORMAT);
 gcode(24) := 'POSTAGE';
 gparam(24) := to_char(glbx.retrieve_pricing_value( 'POSTAGE', parm1, parm2 ),LNG.MONEY_FORMAT);


 if purch.paid_method  in ('MERCHANT','GIFT')
  then
   gcode(25) := 'CREDIT_CARD';
   gparam(25) := LNG.ORD_TXT_216 || NL_CHAR || 'Code : ' || purch.m_response_code || NL_CHAR || 'Nmbr : ' || purch.m_rrn || NL_CHAR || 'Text : ' || purch.m_response_text || NL_CHAR || purch.m_settlement_date;
  else
   gcode(25) := 'CREDIT_CARD';
   gparam(25) := NULL;
 end if;
 gcode(26) := 'TEXT_PURCHASE_REQUEST';
 gparam(26) := voidrec.text_purchase_request;
 gcode(27) := 'CUSTOMER_EMAIL';
 gparam(27) := purch.contact_email;
 gcode(28) := 'CUSTOMER_PHONE';
 gparam(28) := purch.contact_phone;
 gcode(29) := 'CUSTOMER_DEFINED_1';
 gparam(29) := purch.CUSTOMER_COLUMN1;
 gcode(30) := 'CUSTOMER_DEFINED_2';
 gparam(30) := purch.CUSTOMER_COLUMN2;
 gcode(31) := 'CUSTOMER_DEFINED_3';
 gparam(31) := purch.CUSTOMER_COLUMN3;
 gcode(32) := 'CUSTOMER_DEFINED_4';
 gparam(32) := purch.CUSTOMER_COLUMN4;
 gcode(33) := 'CUSTOMER_DEFINED_5';
 gparam(33) := purch.CUSTOMER_COLUMN5;
 gcode(34) := 'CUSTOMER_DEFINED_6';
 gparam(34) := purch.CUSTOMER_COLUMN6;
 add_poid_values( purch.poid, gcode, gparam );

 -- Optionally send email to the Administrator Account
 if (glbx.extract_master_parameter('SEND_EMAIL_TO_ADMIN') = 'TRUE') or
    (glbx.extract_master_parameter('SEND_EMAIL_TO_ADMIN') = 'FALSE' and glbx.extract_master_parameter('ADMIN_EMAIL_CREDIT') = 'TRUE' and purch.paid_method in ('GIFT','MERCHANT'))
  then
   glbx.send( gcode, gparam, 'order_made.tmp', p_to=>nvl(glbx.extract_master_parameter('PICTION_EMAIL_ACCT'),glbx.extract_master_parameter('MAIL_FROM')), p_subj=>voidrec.text_purchase_request || '# ' || purch.poid, p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'OM1', v_pid=>cusrec.pid, v_aid=>cusrec.aid, v_profile_id=>profid);
 end if;

 -- Send email to Photographer about the order
 if (phgrec.contact_email is not null) and (voidrec.disp_email_phg = 'T')
  then
   glbx.send( gcode, gparam, 'phg_order_made.tmp', p_to=>phgrec.contact_email, p_subj=>voidrec.text_purchase_request || '# ' || purch.poid,p_from=>glbx.extract_master_parameter('MAIL_FROM'),ltype=>'PHOTOGRAPHER',own_id=>phgrec.pid, scode=>'POM1', v_pid=>cusrec.pid, v_aid=>cusrec.aid, v_profile_id=>profid);
 end if;

 -- Send SMS to Photographer
 if (phgrec.enable_sms = 'T') and (purch.is_b2c = 'T')
  then
   if (phgrec.notify_order_min is null) or
      (phgrec.notify_order_min is not null and gtotal >= phgrec.notify_order_min)
    then
      if phgrec.mobile_phone is not null
       then
        glbx.send( gcode, gparam, null, p_to=>phgrec.mobile_phone || '@' || glbx.extract_master_parameter('SMS_SITE'),p_subj=>LNG.PHG_TXT_081 || purch.poid || '-' || to_char(gtotal,LNG.MONEY_FORMAT) || '-' || initcap(purch.paid_method),p_from=>glbx.extract_master_parameter('MAIL_FROM'),  is_sms=>TRUE);
      end if;
   end if;
 end if;

  -- Email to customer if specified by the Customer or in the Order Style
 if (purch.event_confirmed = 'T' or voidrec.disp_email_customer = 'T') and
    (purch.contact_email is not null)
   then
    glbx.send( gcode, gparam, 'customer_confirm.tmp', p_to=>purch.contact_email, p_subj=>voidrec.text_purchase_request || '# ' || purch.poid, p_from=>glbx.extract_master_parameter('MAIL_FROM'), extension=>'_' || purch.paid_method, scode=>'CC1', v_pid=>cusrec.pid, v_aid=>cusrec.aid, v_profile_id=>profid);
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'EMAIL_DETAILS',null,null,errmsg=>sqlerrm);
end email_details;

procedure mark_exclusive(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null)
as
begin

 -- If Exclusive Marked Image then Update it and Mark it as Exclusive.
 -- Note: To be marked as exclusive, then either exclusive_local or exclusive_int must be greater than 0.

 update umo
  set
   exclusive_purchased = 'T'
  where
   umo_id in
   (
   select um.umo_id
   from phg_price_item ppi, phg_price_book ppb, shopping_basket sb, umo um
   where ppi.spb = voidrec.spb and
         ppb.spb = ppi.spb and
         (nvl(ppi.exclusive_local,0) > 0 or nvl(ppi.exclusive_int,0) > 0) and
         sb.phid = um.umo_id and
         sb.poid = purch.poid and
         um.date_created + (nvl(decode(nvl(purch.sendto_country,voidrec.residing_country),voidrec.residing_country,ppi.exclusive_local,ppi.exclusive_int),0) * 60) / (86500) < sysdate
    );

exception when others then
 glbx.error_details( 'FNAME', 'MARK_EXCLUSIVE',null,null,errmsg=>sqlerrm);
end mark_exclusive;

procedure configure_for_b2c(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null)
as

 cursor c2( vpoid integer ) is select * from purchase_order where poid = vpoid;

 purchrec	purchase_order%ROWTYPE;
 voidrec2	order_style%ROWTYPE;
 foundrec	boolean;
 newid		integer;
 b2c_enabled	char(1);
 chk		boolean;

begin
 --- Extract the correct B2C from the customer_price book
 voidrec2 := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_enabled ));

 if ((b2c_enabled = 'T') and (voidrec.payment_b2c = 'T')) or
    ((b2c_enabled = 'T') and (nvl(purch.paid_method,'PHONE') not in ('PHONE','CHEQUE','AUTHORISATION','BILLING')) and (voidrec.payment_b2c = 'F'))
  then

     update purchase_order
       set
        is_b2c = 'T'
      where poid = purch.poid;
     purchase_audit_trail( surl, purch.poid, 'IS_B2C', 'U', 'C', 'T', purch, voidrec);

     -- Reselect purchase to get latest copy
     open c2( purch.poid );
     fetch c2 into purchrec;
     close c2;
     chk := lab.manual_printing_check( surl, voidrec, purchrec );

 end if;

exception when others then
 glbx.error_details( 'FNAME', 'CONFIGURE_FOR_B2C',null,null,errmsg=>sqlerrm);
end configure_for_b2c;

procedure adjust_stock(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null)
as

 cursor c1(purchase_id integer) is
  select sb.ppi,qty,p.product_id,p.current_stock
  from shopping_basket sb, phg_price_item ppit, product p
  where sb.poid = purchase_id and
        ppit.ppi = sb.ppi and
        ppit.lab_id = p.product_id and
        current_stock is not null;

begin
 -- Update Stock if Stock is Managed for this item
 for c1rec in c1( purch.poid ) loop
  update product
   set
    current_stock = current_stock - c1rec.qty
  where
   product_id = c1rec.product_id;
  insert into product_stock_audit(product_id,audit_date,stock_adj,activity) values
      (c1rec.product_id,sysdate,c1rec.qty,'[6] Stock Level Decreased after Purchased (' || purch.poid || '):' || to_char(c1rec.current_stock - c1rec.qty));
 end loop;

exception when others then
 glbx.error_details( 'FNAME', 'ADJUST_STOCK',null,null,errmsg=>sqlerrm);
end adjust_stock;

procedure initialise_workflow( surl in varchar2, vpoid in integer )
as

 cursor c1(vpoid integer) is
  select shopping_id,status_workflow
  from shopping_basket
  where poid = vpoid and
        status_workflow is not null
 union all
  select thread_id,status_workflow
  from shopping_basket_thread
  where poid = vpoid and
        status_workflow is not null;
 cursor c3(sts integer) is select * from workflow where status_workflow = sts order by status_priority_default;

 c3rec	c3%ROWTYPE;

begin

 -- The Workflow Set has been identified, but only when an order is confirmed are the other workflow values set
 for c1rec in c1(vpoid) loop
  -- Need to Set: status_mfctr, status_priority, work_state, status_id
  lab.run_workflow(surl,c1rec.shopping_id,null);
  /* -- Redundant Code
  open c3(c1rec.status_workflow);
  fetch c3 into c3rec;
  close c3;
  update shopping_basket set status_priority = c3rec.status_priority_default, status_mfctr = c3rec.manufacturer_id where shopping_id = c1rec.shopping_id;
  if sql%NOTFOUND then update shopping_basket_thread set status_priority = c3rec.status_priority_default, status_mfctr = c3rec.manufacturer_id where thread_id = c1rec.shopping_id; end if;
  if c3rec.workflow_type = 'Q'
   then
    null;
   else

  end if;
  */
 end loop;
 commit;

exception when others then
 glbx.error_details( 'FNAME', 'INITIALISE_WORKFLOW',null,null,errmsg=>sqlerrm,extdet=>'VPOID:' || vpoid);
end initialise_workflow;

procedure customer_receipt(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null)
as

 cursor c3(phgr integer) is select * from photographer where pid = phgr;
 cursor c5(vpoid integer) is select * from order_contact_phone_number where poid = vpoid;

 c3rec		c3%ROWTYPE;
 vfsid		integer;
 newline	boolean;
 popup		boolean;
 txt		varchar2(100);
 retlink	varchar2(1000);

begin

  -- Show Message
  --retlink := return_link( surl, stype, ltype, voidrec, pfx, acid, location=>'2' );
  if voidrec.disp_purch_request_heading = 'T'
   then
    txt := voidrec.text_page5 || ' [' || purch.poid || ']';
   else
    txt := voidrec.text_page5;
  end if;

  if purch.paid_method = 'MERCHANT' and glbx.extract_master_parameter('MERCHANT_POP_WINDOW') = 'TRUE'
   then
    -- Do not display Navigation Page if Customer Receipt
    popup := TRUE;
   else
    glbx.main_title( surl, txt, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'O05',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,retlink=>retlink,stylesh=>pfx.stylesheet);
    popup := FALSE;
  end if;

  if msg is not null
   then
    glbx.header_msg( msg );
  end if;
  htp.p( '<CENTER>' );

  disp_tracing_style(surl, stype, voidrec, pfx, purch, 'FINAL_RECEIPT', acid, ltype, theme_rec );
  if voidrec.text_phg_title is not null then htp.bold( voidrec.text_phg_title ); htp.nl; end if;

  if voidrec.disp_receipt_print = 'T' and (purch.paid_method = 'CHEQUE' and voidrec.columns_swap_pay_confirm = 'T')
   then
    htp.nl;
    htp.bold( voidrec.text_print_cheque );
    htp.nl;
    htp.p('<form><p><input type="button" value="' || LNG2.FNM_TXT_030 || '" onclick="window.print();"> </p></form>');
  end if;

  -- Display Customer Receipt
  -- If B2B extract Photographer Details. If B2C then extract client details.
  open c3(cusrec.pid);
  fetch c3 into c3rec;
  close c3;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=' || pfx.ord_text_table_borderi );
   htp.tablerowopen;
    htp.p( '<TD valign="MIDDLE" ALIGN="LEFT">' );
     htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
      htp.tablerowopen;
       htp.tabledata( htf.bold(voidrec.text_purchase_request), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.bold(purch.poid), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"' );
      htp.tablerowclose;
      if c3rec.business_name is not null then
       htp.tablerowopen;
        htp.tabledata( htf.bold(c3rec.photographer_title), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"' );
        htp.tabledata( c3rec.business_name, cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"' );
       htp.tablerowclose;
      end if;
      if c3rec.abn_number is not null then
      htp.tablerowopen;
       htp.tabledata( htf.bold(c3rec.abn_title), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( c3rec.abn_number, cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"' );
      htp.tablerowclose;
      end if;
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.ORD_TXT_187), cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
       htp.p( '<TD ' || pfx.ord_qcbground || ' valign="TOP" align="LEFT">' );
        if c3rec.work_phone is not null then htp.p( '(w)' || c3rec.work_phone || htf.nl ); end if;
        if c3rec.mobile_phone is not null then htp.p( '(m)' || c3rec.mobile_phone || htf.nl ); end if;
        if c3rec.contact_fax is not null then htp.p( '(f)' || c3rec.contact_fax || htf.nl ); end if;
        if c3rec.contact_email is not null then htp.p( '(e)' || c3rec.contact_email ); end if;
       htp.p( '</TD>' );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.CST_TXT_006), cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
       htp.p( '<TD ' || pfx.ord_qcbground || ' valign="TOP" align="LEFT">' );
        if c3rec.work_phone is not null then htp.p( c3rec.contact_street ); end if;
        if c3rec.work_phone is not null then htp.p( ' ' || c3rec.contact_suburb ); end if;
        if (c3rec.contact_city is not null) or (c3rec.contact_pcode) is not null
         then
          htp.nl;
           if c3rec.contact_city is not null then htp.p( c3rec.contact_city ); end if;
           if c3rec.contact_pcode is not null then htp.p( ' ' || c3rec.contact_pcode ); end if;
        end if;
       htp.p( '</TD>' );
      htp.tablerowclose;

      if purch.paid_method in ('MERCHANT','GIFT')
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.ORD_TXT_218 || ':'), cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
         htp.tabledata( nvl(purch.m_rrn,'&nbsp;'), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.ORD_TXT_217 || ':'), cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
         htp.tabledata( nvl(purch.m_response_text,'&nbsp;'), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.ORD_TXT_216 || ':'), cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
         htp.tabledata( nvl(purch.m_response_code,'&nbsp;'), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
        htp.tablerowclose;
      end if;
     htp.tableclose;
    htp.p( '</TD>' );
   htp.tablerowclose;

   htp.tablerowopen;

    htp.p( '<TD ' || pfx.ord_qcbground || '>' );
     htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
      htp.tablerowopen;
       htp.tabledata( LNG.ORD_TXT_188, cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
       htp.tabledata( htf.bold(to_char(sysdate,LNG.MASK)), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
      htp.tablerowclose;
      if nvl(voidrec.columns_name_toggle,'T') = 'T'
       then
        if purch.sendto_name is not null
         then
          htp.tablerowopen;
           htp.tabledata( nvl(voidrec.columns_name,LNG.CST_TXT_112), cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
           htp.tabledata( htf.bold( purch.sendto_name ), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
          htp.tablerowclose;
        end if;
       else
        if purch.sendto_firstname is not null
         then
          htp.tablerowopen;
           htp.tabledata( nvl(voidrec.columns_firstname,LNG.CST_TXT_112), cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
           htp.tabledata( htf.bold( purch.sendto_firstname ), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
          htp.tablerowclose;
        end if;
        if purch.sendto_lastname is not null
         then
          htp.tablerowopen;
           htp.tabledata( nvl(voidrec.columns_lastname,LNG.CST_TXT_112), cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
           htp.tabledata( htf.bold( purch.sendto_lastname ), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
          htp.tablerowclose;
        end if;
      end if;
      if purch.sendto_branch is not null
       then
        htp.tablerowopen;
         htp.tabledata( voidrec.columns_branch, cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
         htp.tabledata( htf.bold( purch.sendto_branch ), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
        htp.tablerowclose;
      end if;
      if purch.sendto_department is not null then
        htp.tablerowopen;
         htp.tabledata( voidrec.columns_department, cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
         htp.tabledata( htf.bold( purch.sendto_department ), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
        htp.tablerowclose;
      end if;
      if purch.sendto_street is not null then
        htp.tablerowopen;
         htp.tabledata( nvl( voidrec.columns_street,LNG.CST_TXT_113), cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
         htp.tabledata( htf.bold( purch.sendto_street ), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
        htp.tablerowclose;
      end if;
      if purch.sendto_suburb  is not null then
        htp.tablerowopen;
         htp.tabledata( nvl( voidrec.columns_suburb,LNG.CST_TXT_114), cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
         htp.tabledata( htf.bold( purch.sendto_suburb ), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
        htp.tablerowclose;
      end if;
      if purch.sendto_city is not null then
        htp.tablerowopen;
         htp.tabledata( nvl( voidrec.columns_city,LNG.CST_TXT_115), cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
         htp.tabledata( htf.bold( purch.sendto_city ), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
        htp.tablerowclose;
      end if;
      if purch.sendto_country is not null then
        htp.tablerowopen;
         htp.tabledata( nvl( voidrec.columns_country,LNG.CST_TXT_116), cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
         htp.tabledata( htf.bold( purch.sendto_country ), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
        htp.tablerowclose;
      end if;
      if purch.sendto_postcode is not null then
        htp.tablerowopen;
         htp.tabledata( nvl( voidrec.columns_postcode,LNG.CST_TXT_118), cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
         htp.tabledata( htf.bold( purch.sendto_postcode ), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
        htp.tablerowclose;
      end if;
      if purch.sendto_state is not null then
        htp.tablerowopen;
           htp.tabledata( nvl( voidrec.columns_state,LNG5.SCL_TXT_105), cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
         htp.tabledata( htf.bold( purch.sendto_state ), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
        htp.tablerowclose;
      end if;

      htp.tablerowopen;
       htp.tabledata( LNG.ORD_TXT_179, cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
       htp.tabledata( htf.bold( purch.paid_method ), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
      htp.tablerowclose;

      if purch.paid_method  in ('MERCHANT','GIFT')
       then
        /*
        htp.tablerowopen;
         htp.tabledata( LNG.ORD_TXT_218, cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
         htp.tabledata( htf.bold(purch.m_rrn), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( LNG.ORD_TXT_217, cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
         htp.tabledata( htf.bold(purch.m_response_text), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( LNG.ORD_TXT_216, cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
         htp.tabledata( htf.bold(purch.m_response_code), cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
        htp.tablerowclose;
        */
        null;

      elsif purch.paid_method = 'PHONE'
       then
        for c5rec in c5(purch.poid) loop
         htp.tablerowopen;
          htp.tabledata( '&nbsp;', cattributes=>pfx.ord_qbground || 'valign="TOP" align="LEFT"' );
          if c5rec.contact_det is null
           then
            htp.tabledata( c5rec.pnumber , cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
           else
            htp.tabledata( c5rec.pnumber || '(' || c5rec.contact_det || ')', cattributes=>pfx.ord_qcbground || 'valign="TOP" align="LEFT"');
          end if;
         htp.tablerowclose;
        end loop;
      end if;
     htp.tableclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
   htp.tableclose;
   htp.nl;

   if voidrec.disp_show_tnail_on_receipt = 'T'
    then
     disp_order_summary( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purch, voidrec, 'BROWSE', newline, override_width=>'"80%"' );
   end if;

   disp_order_total_details( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purch, voidrec, 'BROWSE', newline );

  htp.tablerowclose;
  htp.tableclose;
  if voidrec.disp_receipt_print = 'T' and not (purch.paid_method = 'CHEQUE' and voidrec.columns_swap_pay_confirm = 'T')
   then
    htp.p('<form><p><input type="button" value="' || LNG2.FNM_TXT_030 || '" onclick="window.print();"> </p></form>');
  end if;

  display_order_tracking( pfx, purch, voidrec, null );
  setup_new_account( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purch, voidrec );
  list_downloadable( surl, purch, pfx, theme_rec, voidrec, acid );

  if voidrec.fax_merchant_enabled = 'T' and purch.paid_method = 'CHEQUE'
   then
    cheque_fax_details(surl, sess_id, stype, ltype, acid, profid, cusrec, pfx, theme_rec, purch, voidrec, c3rec );
  end if;

  if popup
   then
    htp.nl;
    htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
    htp.nl;
  end if;

 if pfx.ord_inc_simple = 'T'
  then
    cst.disp_standard_search(surl, stype, ltype, profid, acid, cusrec, pfx, theme_rec, 'SIMPLE' );
    if pfx.ord_inc_privacy = 'T' then htp.nl; end if;
 end if;

 if pfx.ord_inc_privacy = 'T'
  then
    cst.disp_privacy(surl, ltype, profid, acid, cusrec, pfx, theme_rec );
 end if;

 if pfx.order_bottom_external is not null
  then
    execute immediate
      'begin ' || pfx.order_bottom_external ||
       '(surl=>:surl,ltype=>:ltype,acid=>:acid,screen_location=>:screen_location);' ||
       'end;'
     using glbx.rndsurl(surl),ltype,acid,'FINAL_RECEIPT';
 end if;
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );
end customer_receipt;

procedure calculate_delivery_time( surl in varchar2, vpoid in integer, purch in purchase_order%ROWTYPE )
as

 cursor c1(vpoid integer) is select * from shopping_basket where poid = vpoid;

 surch	number;
 dltime	number;
 ptime	number;
 ddesc	varchar2(1000);
 pdesc	varchar2(1000);

begin
    -- Check Surcharge, Delivery Time and Product Time
 surch := 0;
 dltime := 0;
 ptime := 0;
 for c1rec in c1(purch.poid) loop

  if ( purch.home_country = purch.sendto_country ) and (c1rec.delivery_time_local is not null)
   then
    dltime := greatest(dltime,c1rec.delivery_time_local);
    ddesc := c1rec.delivery_desc;
  elsif ( purch.home_country <> purch.sendto_country ) and (c1rec.delivery_time_int is not null)
   then
    dltime := greatest(dltime,c1rec.delivery_time_int);
    ddesc := c1rec.delivery_desc;
  end if;

  if c1rec.production_time is not null
   then
    ptime := greatest(ptime,c1rec.production_time);
    pdesc := c1rec.product_desc;
  end if;

  update shopping_basket
   set
    delivery_time_local = dltime,
    delivery_time_int = dltime
   where shopping_id = c1rec.shopping_id;

  end loop;

  -- Added this as in theory the production time is for the total order for the greatest length of time
  update shopping_basket
   set
    production_time = ptime
   where poid = purch.poid;

end calculate_delivery_time;

procedure failed_credit_card(surl in varchar2, sess_id in integer, stype in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, msg in varchar2 default null)
as

 newline	boolean;
 npfx		theme%ROWTYPE;
 ntheme_rec	theme_types%ROWTYPE;

begin
 if voidrec.bftr <> 'Use Customer Account Business Feature'
  then
   ntheme_rec := glbx.get_theme_types( voidrec.bftr );
  else
   ntheme_rec := theme_rec;
 end if;

 if voidrec.laf <> 'Use Customer Account Look and Feel'
  then
   npfx := glbx.get_thm( voidrec.laf );
  else
   npfx := pfx;
 end if;

 glbx.main_title( surl, LNG.ORD_TXT_219, glbx.backimg(surl,cusrec.aid,npfx.text_back,cusrec.background_img,ltype),helpid=>'O23',stype=>stype, sstyle=>npfx.text_font,sclr=>npfx.ord_text_colour,det_sstyle=>npfx.ord_title_text_font,det_sclr=>npfx.ord_title_text_colour, det_font=>npfx.ord_title_colour_font,hover=>npfx.hover_colour, disptop=>npfx.keep_lhf, finc=>npfx.ord_text_font_inc, errclr=>npfx.error_text_colour, errfnt=>npfx.error_text_font, instclr=>npfx.instruct_text_colour, instfnt=>npfx.instruct_text_font, instfntinc=>npfx.instruct_font_inc, jscript=>npfx.javascript, icra_label=>npfx.icra_label,top_padding=>npfx.top_padding,left_padding=>npfx.left_padding,lnk=>npfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p('<CENTER>');
 htp.nl;
 htp.header(3, msg, 'CENTER');
 htp.nl;
 htp.header(4,LNG2.FNM_TXT_162,'CENTER');
 htp.header(4,LNG2.FNM_TXT_163,'CENTER');
 htp.nl;
 htp.nl;
 newline := FALSE;
 disp_payment_method( surl, stype, sess_id, ltype, acid, profid, cusrec, npfx, ntheme_rec, purch, voidrec, 'EDIT', newline );
 htp.nl;
 htp.p('</CENTER>');
 glbx.close_page( pfx );

end failed_credit_card;

procedure login_account_first_stage( surl in varchar2, simplesearch in varchar2 default NULL, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null )
as

 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 msg		varchar2(1000);

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.LOGIN_ACCOUNT_FIRST_STAGE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if ltype in ('MANUFACTURER','PHOTOGRAPHER')
  then
   -- Redo this step to bypass a possible cookie program
   -- glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.LOGIN_ACCOUNT_FIRST_STAGE', iscust=>FALSE );
   login_account_final_stage( surl, ltype );
   return;
 end if;

 glbx.get_all_order_details(sess_id, ltype, null, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 -- Create Purchase Order
 create_purchase_order( surl, sess_id, 'PreOrder - No Order Made', profid, ltype, cusrec, voidrec, purchord);

 -- Go Straight in or Prompt for Details
 if (replace(substr(voidrec.columns_on_login,1,11),' ','F') = lpad('F',11,'F') and replace(substr(voidrec.columns_on_login,13,8),' ','F') = lpad('F',8,'F') and voidrec.login_html_template is null) or voidrec.oid is null
  then
   login_account_final_stage( surl, ltype, simplesearch, v_umo, v_product_id, screen_name, screen_parms, screen_type );
   return;
 end if;

 login_account_second_stage(surl, stype, sess_id, ltype, cusrec.aid, profid, cusrec, pfx, theme_rec, purchord, voidrec, null, simplesearch, v_umo, v_product_id, screen_name, screen_parms, screen_type );

exception when others then
 glbx.error_details( 'FNAME', 'LOGIN_ACCOUNT_FIRST_STAGE',null,null,errmsg=>sqlerrm,extdet=>'LTYPE:' || ltype);
end login_account_first_stage;

procedure external_html_file(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, msg in varchar2 default null, simplesearch in varchar2 default NULL, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null )
as

 cursor c1(phgid integer) is select * from photographer where pid = phgid;

 c1rec		c1%ROWTYPE;
 l_terms        utl_file.file_type;
 template_dir	varchar2(100);
 fname_gen	varchar2(100);
 fname_phg	varchar2(100);
 fname_cus	varchar2(100);
 p_body		varchar2(32767);

begin

 open c1(cusrec.pid);
 fetch c1 into c1rec;
 close c1;

 fname_gen := GLBX.EXT_ORDER_STYLE_TERMS_HTML;
 fname_phg := 'order_style_terms_' || c1rec.username || '.html';
 fname_cus := 'order_style_terms_' || cusrec.username || '.html';

 template_dir := glbx.extract_master_parameter('MAIL_TEMPLATE_DIR');
 -- First look for one based on the customer username
 -- Then look for one based on the photographer username
 -- Then look for the general one
 begin
   l_terms := utl_file.fopen( template_dir, fname_cus, 'r', max_linesize=>32767 );
  exception
   when others then
    begin
     l_terms := utl_file.fopen( template_dir, fname_phg, 'r', max_linesize=>32767 );
    exception
     when others then
      begin
        l_terms := utl_file.fopen( template_dir, fname_gen, 'r', max_linesize=>32767 );
      exception
       when others then
        login_account_second_stage_int(surl, stype, sess_id, ltype, cusrec.aid, profid, cusrec, pfx, theme_rec, purchord, voidrec, msg, simplesearch, v_umo, v_product_id, screen_name, screen_parms, screen_type, TRUE );
        return;
      end;
    end;
 end;

 loop
    begin
      utl_file.get_line(l_terms,p_body);
      if p_body = '<PICTION_TERMS_PAGE>'
       then
        login_account_second_stage_int(surl, stype, sess_id, ltype, cusrec.aid, profid, cusrec, pfx, theme_rec, purchord, voidrec, msg, simplesearch, v_umo, v_product_id, screen_name, screen_parms, screen_type, FALSE );
       else
        htp.p( p_body );
      end if;
     exception
      when others
       then exit;
    end;
 end loop;

 utl_file.fclose( l_terms );

exception when others then
 glbx.error_details( 'GLBX', 'EXTERNAL_HTML_FILE', errmsg=>sqlerrm);
 begin utl_file.fclose( l_terms ); exception when others then null; end;
end external_html_file;

-- Terms and Condition Page
-- See if there is an external file that control the display of the Terms and Conditions Page
procedure login_account_second_stage(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, msg in varchar2 default null, simplesearch in varchar2 default NULL, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null )
as
begin
 external_html_file(surl, stype, sess_id, ltype, cusrec.aid, profid, cusrec, pfx, theme_rec, purchord, voidrec, msg, simplesearch, v_umo, v_product_id, screen_name, screen_parms, screen_type );
exception when others then
 glbx.error_details( 'FNAME', 'LOGIN_ACCOUNT_SECOND_STAGE',null,null,errmsg=>sqlerrm,extdet=>'LTYPE:' || ltype);
end login_account_second_stage;

procedure login_account_second_stage_int(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, msg in varchar2 default null, simplesearch in varchar2 default NULL, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null, disptitle in boolean )
as

 cursor c1 is select distinct region from postal_charge;

 url	varchar2(1000);
 err	boolean;
 fl 	UTL_FILE.FILE_TYPE;
 bfr	varchar2(25000);

begin

 if voidrec.login_html_template is not null
  then

   err := FALSE;
   begin
    if voidrec.login_html_subdir is null
     then
      fl := utl_file.fopen( glbx.extract_master_parameter('IMAGE_DIR') || DECS.UNIX_OR_NT || 'order_style', voidrec.login_html_template, 'r', 25000 );
     else
      fl := utl_file.fopen( glbx.extract_master_parameter('IMAGE_DIR') || DECS.UNIX_OR_NT || 'order_style' || DECS.UNIX_OR_NT || voidrec.login_html_subdir, voidrec.login_html_template, 'r', 25000 );
    end if;
   exception
    when others then
     --htp.p( glbx.extract_master_parameter('IMAGE_DIR') || DECS.UNIX_OR_NT || 'order_style' || DECS.UNIX_OR_NT || subdir ); htp.nl;
     htp.p( 'Error: Cannot find HTML Page:' || voidrec.login_html_subdir );
     err := TRUE;
   end;

   if not err
    then
     loop
      begin
       utl_file.get_line( fl, bfr );
       htp.p( replace(replace(bfr,'<PICTION_MSG>',msg),'<PICTION_SURL>', surl ) );
      exception
       when others
        then
         utl_file.fclose( fl );
         return;
       end;
     end loop;
     return;
   end if;

 end if;

 if disptitle
  then
   glbx.main_title( surl, voidrec.text_logon_title,glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'C32',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>'L', finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   htp.title( nvl(glbx.userpref( cusrec.pid, cusrec.aid, 'MENU_BAR' ),glbx.extract_master_parameter('PAGE_TITLE') ) );
   htp.p( '<CENTER>' );
 end if;

 if msg is not null
  then
   htp.p( msg );
 end if;

 htp.formopen( 'fname.accept_login_account_2_stage');
 htp.formhidden( 'SURL', surl  );
 htp.formhidden( 'P1', NULL  );
 htp.formhidden( 'P2', NULL  );
 htp.formhidden( 'P3', NULL  );
 htp.formhidden( 'SIMPLESEARCH', simplesearch );
 htp.formhidden( 'V_UMO', v_umo );
 htp.formhidden( 'V_PRODUCT_ID', v_product_id );
 htp.formhidden( 'SCREEN_NAME', screen_name );
 htp.formhidden( 'SCREEN_PARMS', screen_parms );
 htp.formhidden( 'SCREEN_TYPE', screen_type );

 if substr(voidrec.columns_on_login,11,1) = 'T' and voidrec.text_disclaimer is not null
  then
   htp.tableopen( cattributes=>'width="66%" cellpadding=2 cellspacing=2 rules="NONE" frame="HSIDES,VSIDES" border=' || pfx.ord_text_table_borderi );
    htp.tablerowopen;
     htp.tabledata( voidrec.text_disclaimer, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER" style="text-align: center;"' );
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
 end if;

 if not ((substr(voidrec.columns_on_login,1,9) = lpad('F',9,'F') and substr(voidrec.columns_on_login,13,8) = lpad('F',8,'F')) or voidrec.oid is null)
  then
   htp.tableopen( cattributes=>'cellpadding=4 cellspacing=1 border=' || pfx.ord_text_table_borderi );

   -- Name
   if nvl(substr(voidrec.columns_on_login,1,1),'T') = 'T'
    then
     if nvl(voidrec.columns_name_toggle,'T') = 'T'
      then
       htp.tablerowopen;
        htp.tabledata( htf.formhidden( 'P1', '6-NAME' ) || format_name( voidrec.columns_name,1,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( htf.formtext( 'P2', 40, 100, purchord.sendto_name ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
       htp.tablerowclose;
      else
       htp.tablerowopen;
        htp.tabledata( htf.formhidden( 'P1', '6-FIRSTNAME' ) || format_name( voidrec.columns_firstname,1,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( htf.formtext( 'P2', 40, 100, purchord.sendto_firstname ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
       htp.tablerowclose;
       htp.tablerowopen;
        htp.tabledata( htf.formhidden( 'P1', '6-LASTNAME' ) || format_name( voidrec.columns_lastname,1,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( htf.formtext( 'P2', 40, 100, purchord.sendto_lastname ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
       htp.tablerowclose;
     end if;
   end if;

   -- Street
   if nvl(substr(voidrec.columns_on_login,2,1),'T') = 'T'
    then
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1', '6-STREET' ) || format_name( voidrec.columns_street,2,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');

       htp.tabledata( htf.formtext( 'P2', 40, 100, purchord.sendto_street ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
   end if;

   -- Branch
   if nvl(substr(voidrec.columns_on_login,20,1),'T') = 'T'
    then
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1', '6-BRANCH' ) || format_name( voidrec.columns_branch,20,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata( htf.formtext( 'P2', 40, 100, purchord.sendto_branch ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
   end if;

   -- Department
   if nvl(substr(voidrec.columns_on_login,21,1),'T') = 'T'
    then
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1', '6-DEPARTMENT' ) || format_name( voidrec.columns_department,21,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata( htf.formtext( 'P2', 40, 100, purchord.sendto_department ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
   end if;

   -- Suburb
   if nvl(substr(voidrec.columns_on_login,3,1),'T') = 'T'
    then
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1', '6-SUBURB' ) || format_name( voidrec.columns_suburb,3,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');

       htp.tabledata( htf.formtext( 'P2', 40, 100, purchord.sendto_suburb ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
   end if;

   -- City
   if nvl(substr(voidrec.columns_on_login,4,1),'T') = 'T'
    then
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1', '6-CITY' ) || format_name( voidrec.columns_city,4,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata( htf.formtext( 'P2', 40, 100, purchord.sendto_city ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
   end if;

   -- Postcode
   if nvl(substr(voidrec.columns_on_login,5,1),'T') = 'T'
    then
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1', '6-POSTCODE' ) || format_name( voidrec.columns_postcode,5,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata( htf.formtext( 'P2', 40, 100, purchord.sendto_postcode ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
   end if;

   -- State
   if nvl(substr(voidrec.columns_on_login,19,1),'T') = 'T'
    then
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1', '6-STATE' ) || format_name( voidrec.columns_state,5,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata( htf.formtext( 'P2', 10, 100, purchord.sendto_state ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
   end if;

   -- Country
   if nvl(substr(voidrec.columns_on_login,6,1),'T') = 'T'
    then
      htp.tablerowopen;
       htp.tabledata( format_name( voidrec.columns_country,6,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
       htp.p( '<TD ' || pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT">');
       htp.formhidden( 'P1', '6-COUNTRY' );
       htp.formselectopen( 'P2' );
       for c1rec in c1 loop
        if c1rec.region = nvl(purchord.sendto_country,voidrec.residing_country)
         then
          htp.formselectoption( c1rec.region, 'SELECTED' );
         else
          htp.formselectoption( c1rec.region );
        end if;
       end loop;
       htp.formselectclose;
       htp.p( '</TD>');
      htp.tablerowclose;
   end if;

   -- Phone
   if nvl(substr(voidrec.columns_on_login,7,1),'T') = 'T'
    then
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1', '6-PHONE' ) || format_name( voidrec.columns_phone,7,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');

       htp.tabledata( htf.formtext( 'P2', 20, 100, purchord.contact_phone ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
   end if;

   -- Email
   if nvl(substr(voidrec.columns_on_login,8,1),'T') = 'T'
    then
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1', '6-EMAIL' ) || format_name( voidrec.columns_email,8,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');

       htp.tabledata( htf.formtext( 'P2', 40, 100, purchord.contact_email ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
   end if;

   -- Customer Comment
   if nvl(substr(voidrec.columns_on_login,9,1),'T') = 'T'
    then
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1', '6-CUSTOMER_COMMENT' ) || format_name( voidrec.columns_comment,9,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');

       htp.tabledata( htf.formtext( 'P2', 40, 4000, purchord.customer_comment ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
   end if;

   -- Customer Defined 1
   if nvl(substr(voidrec.columns_on_login,13,1),'T') = 'T'
    then
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1', '6-CUSTOMER_COLUMN1' ) || format_name( voidrec.columns_cust_col1,13,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');

       htp.tabledata( htf.formtext( 'P2', 40, 100, purchord.customer_column1 ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
   end if;

   -- Customer Defined 2
   if nvl(substr(voidrec.columns_on_login,14,1),'T') = 'T'
    then
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1', '6-CUSTOMER_COLUMN2' ) || format_name( voidrec.columns_cust_col2,14,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');

       htp.tabledata( htf.formtext( 'P2', 40, 100, purchord.customer_column2 ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
   end if;

   -- Customer Defined 3
   if nvl(substr(voidrec.columns_on_login,15,1),'T') = 'T'
    then
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1', '6-CUSTOMER_COLUMN3' ) || format_name( voidrec.columns_cust_col3,15,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');

       htp.tabledata( htf.formtext( 'P2', 40, 100, purchord.customer_column3 ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
   end if;

   -- Customer Defined 4
   if nvl(substr(voidrec.columns_on_login,16,1),'T') = 'T'
    then
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1', '6-CUSTOMER_COLUMN4' ) || format_name( voidrec.columns_cust_col4,16,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');

       htp.tabledata( htf.formtext( 'P2', 40, 100, purchord.customer_column4 ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
   end if;

   -- Customer Defined 5
   if nvl(substr(voidrec.columns_on_login,17,1),'T') = 'T'
    then
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1', '6-CUSTOMER_COLUMN5' ) || format_name( voidrec.columns_cust_col5,17,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');

       htp.tabledata( htf.formtext( 'P2', 40, 100, purchord.customer_column5 ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
   end if;

   -- Customer Defined 6
   if nvl(substr(voidrec.columns_on_login,18,1),'T') = 'T'
    then
      htp.tablerowopen;
       htp.tabledata( htf.formhidden( 'P1', '6-CUSTOMER_COLUMN6' ) || format_name( voidrec.columns_cust_col6,18,voidrec,'ON_LOGIN'), cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');

       htp.tabledata( htf.formtext( 'P2', 40, 100, purchord.customer_column6 ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
   end if;

   htp.tablerowopen;
    htp.tabledata( voidrec.text_unsolicited_email, cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
    if nvl(substr(voidrec.columns_on_login,12,1),'T') = 'T'
     then
      htp.tabledata( htf.formcheckbox( 'P3', '6-UNSOLICITED', 'CHECKED' ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
     else
      htp.tabledata( htf.formcheckbox( 'P3', '6-UNSOLICITED' ), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
    end if;
   htp.tablerowclose;

   if is_bf(theme_rec,ltype,361,362,'T','T')
    then
     htp.tablerowopen;
      htp.tabledata( LNG5.EXT_TXT_597, cattributes=>pfx.ord_qbground || 'valign="MIDDLE" align="LEFT"');
      url := 'javascript: window.open(''' || 'cst.acct_showinf?surl=' || glbx.rndsurl(surl) || '&typ=PRIVACY' || ''',''' || 'PRIVACY' || ''',''height=500,width=400,scrollbars=yes,resizable=yes'');void('''');';
      htp.tabledata( htf.anchor(url,htf.img( cust_button(pfx,'privacy.gif'),cattributes=>'border=0',calt=>LNG4.AHC_TXT_459 )), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( nvl(voidrec.text_privacy,'&nbsp;'), cattributes=>pfx.ord_qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2"');
     htp.tablerowclose;
   end if;

  htp.tableclose;
 end if;

 htp.nl;
 if voidrec.text_decline is not null then htp.formsubmit( 'ACTION', voidrec.text_decline, cattributes=>'TABINDEX="2"' ); end if;
 if voidrec.text_accept is not null then htp.formsubmit( 'ACTION', voidrec.text_accept, cattributes=>'TABINDEX="1"' ); end if;
 htp.formclose;
 if disptitle
  then
   htp.p( '</CENTER>' );
   glbx.close_page( pfx );
 end if;
exception when others then
 glbx.error_details( 'FNAME', 'LOGIN_ACCOUNT_SECOND_STAGE_INT',null,null,errmsg=>sqlerrm,extdet=>'LTYPE:' || ltype);
end login_account_second_stage_int;

procedure accept_login_account_2_stage( surl in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, action in varchar2 default null, simplesearch in varchar2 default NULL, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null, image_accept in varchar2 default null, image_decline in varchar2 default null )
as

 cursor c1(vpoid integer) is select * from purchase_order where poid = vpoid;

 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 vaction	varchar2(100);
 result		varchar2(32767);

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.ACCEPT_LOGIN_ACCOUNT_2_STAGE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 glbx.get_all_order_details(sess_id, ltype, null, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 if image_accept is not null
  then
   vaction := voidrec.text_accept;
 elsif image_decline is not null
  then
   vaction := voidrec.text_decline;
 else
  vaction := action;
 end if;

 if vaction = voidrec.text_decline
  then
   glbx.acct_logoff(surl, iscust=>'T', force_logoff=>'T' );
   return;
 end if;

 -- Don't Process if not Prompted to Process (note #12 is unsolicted email prompt and if on doesn't indicate that it must display)
 if not (substr(voidrec.columns_on_login,1,11) = lpad('F',11,'F') and substr(voidrec.columns_on_login,13,8) = lpad('F',8,'F') ) or voidrec.oid is null
  then
   process_data_entered( surl, pfx, cusrec.aid, ltype, profid, p1, p2, p3, cusrec, purchord, voidrec, 'LOGIN', result );
 end if;

 commit;

 if result is null
  then
   login_account_final_stage( surl, ltype, simplesearch, v_umo, v_product_id, screen_name, screen_parms, screen_type );
  else
   -- Redisplay Login
   open c1(purchord.poid);
   fetch c1 into purchord;
   close c1;
   login_account_second_stage(surl, stype, sess_id, ltype, cusrec.aid, profid, cusrec, pfx, theme_rec, purchord, voidrec, result, simplesearch, v_umo, v_product_id, screen_name, screen_parms, screen_type );
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_LOGIN_ACCOUNT_2_STAGE',null,null,errmsg=>sqlerrm,extdet=>'LTYPE:' || ltype);
end accept_login_account_2_stage;

procedure login_account_final_stage( surl in varchar2, ltype in varchar2, simplesearch in varchar2 default NULL, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null )
as

purchord	purchase_order%ROWTYPE;

begin

  -- Enable the Cookies, not for session management, but when exitting and re-entering Piction.
  -- Only once they have completed a valid registration, otherwise they can bypass it
 /*
 if glbx.extract_master_parameter('COOKIE_ENABLED') = 'TRUE'
   then
    owa_util.mime_header('text/html', FALSE);
    owa_cookie.send(nvl(glbx.extract_master_parameter('COOKIE_NAME'),'PICTION_COOKIE'), surl);
    owa_util.http_header_close;
 end if;
 */


 if ltype in ('CUSTOMER','OWNER','PROFILE','PROFILEG','VIRTUAL')
  then
   glbx.reset_cookie( surl, FALSE );
   cst.screen_sze(surl,simplesearch, v_umo, v_product_id, screen_name, screen_parms, screen_type );

 elsif ltype = 'PHOTOGRAPHER'
  then
   phg.screen_sze(surl,simplesearch, v_umo, v_product_id);

 elsif ltype = 'MANUFACTURER'
  then
   lab.screen_sze(surl);

 end if;

exception when others then
 glbx.error_details( 'FNAME', 'LOGIN_ACCOUNT_FINAL_STAGE',null,null,errmsg=>sqlerrm,extdet=>'LTYPE:' || ltype);
end login_account_final_stage;

procedure purchase_method_screen_mfctr( surl in varchar2, vpoid in integer )
as

 cursor c1(vpoid integer) is select * from purchase_order where poid = vpoid;
 cursor c2(sess_id integer) is select * from login_session where sessid = sess_id;

 c2rec		c2%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 result		varchar2(1000);

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.PURCHASE_METHOD_SCREEN_MFCTR', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if ltype <> 'MANUFACTURER' then return; end if;
 open c1(vpoid);
 fetch c1 into purchord;
 close c1;
 open c2(purchord.sessid);
 fetch c2 into c2rec;
 close c2;
 cusrec := glbx.get_cusrec( purchord.sessid, ltype, null, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types( cusrec.theme_type );
 voidrec := glbx.get_order_style( purchord.oid );

 disp_payment_page( surl, stype, purchord.sessid, c2rec.login_type, null, profid, cusrec, pfx, theme_rec, purchord, voidrec );

exception when others then
 glbx.error_details( 'FNAME', 'PURCHASE_METHOD_SCREEN_MFCTR',null,null,errmsg=>sqlerrm,extdet=>'LTYPE:' || ltype);
end purchase_method_screen_mfctr;

procedure auto_configure_tracking( purchord in out purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE )
as

 pw	varchar2(100);

begin

 -- Has the customer already configured order tracking?
 if purchord.contact_password is not null then return; end if;

 -- Is the checkbox to enable auto tracking enabled?
 if voidrec.disp_auto_create_tracking = 'F' then return; end if;

 pw := get_profile_username( purchord );
 purchord.contact_password := pw;
 purchord.event_confirmed := 'T';
 purchord.event_issue := 'T';
 purchord.event_shipped := 'T';
 update purchase_order
  set
   contact_password = purchord.contact_password,
   event_confirmed = purchord.event_confirmed,
   event_issue = purchord.event_issue,
   event_shipped = purchord.event_shipped
 where
  poid = purchord.poid;

end auto_configure_tracking;

function get_profile_username( purchord in purchase_order%ROWTYPE )
 return varchar2
as

 cursor c1(phgid integer) is select reserve_username_prefix from photographer where pid = phgid;

 c1rec		c1%ROWTYPE;
 retarr		GLBX.MYARRAY;
 proposed_name	varchar2(100);
 x		integer;

begin

-- Photographer can reserve a prefix. Make sure it is prefixed to the proposed name.
open c1(purchord.pid);
fetch c1 into c1rec;
close c1;
x := instr( purchord.sendto_name,' ');
if x = 0
 then
  proposed_name := upper(c1rec.reserve_username_prefix || purchord.sendto_name);
 else
  proposed_name := upper(c1rec.reserve_username_prefix || substr(purchord.sendto_name,1,1) || substr(purchord.sendto_name,x+1,5));
end if;
if glbx.userexists( proposed_name ) and proposed_name is not null
 then
  return( proposed_name );
 else
  retarr := glbx.proposed_users( proposed_name, 5 );
  proposed_name := retarr(1);
  return( proposed_name );
end if;

end get_profile_username;

procedure display_order_tracking( pfx in theme%ROWTYPE, purchord in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, override_width in varchar2 default null )
as

v_purch		purchase_order%ROWTYPE;

begin

 -- Check if Auto Tracking needs to be setup
 v_purch := purchord;
 auto_configure_tracking( v_purch, voidrec );

 if v_purch.contact_password is null then return; end if;

 htp.nl;
 htp.tableopen( cattributes=>'width=' || nvl(override_width,'"80%"') || ' cellpadding=2 cellspacing=2 border=' || pfx.ord_text_table_borderi );
  htp.tablerowopen;
    htp.tabledata(htf.bold(LNG5.EXT_TXT_598),cattributes=>pfx.ord_qbground || ' valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG5.EXT_TXT_599),cattributes=>pfx.ord_qbground || ' valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( htf.anchor( glbx.extract_master_parameter('MERCHANT_RETURNTO_URL') || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || GLBX.PICTION_CHECK_ORDER_PAGE,
                   glbx.extract_master_parameter('MERCHANT_RETURNTO_URL') || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || GLBX.PICTION_CHECK_ORDER_PAGE),cattributes=>pfx.ord_qcbground || ' valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.bold(LNG5.EXT_TXT_600),cattributes=>pfx.ord_qbground || ' valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata(htf.bold(v_purch.poid),cattributes=>pfx.ord_qcbground || ' valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.bold(LNG5.EXT_TXT_601),cattributes=>pfx.ord_qbground || ' valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata(htf.bold(v_purch.contact_password),cattributes=>pfx.ord_qcbground || ' valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;

end display_order_tracking;

procedure display_new_account( pfx in theme%ROWTYPE, un in varchar2, pw in varchar2, override_width in varchar2 default null, msg in varchar2 )
as
begin

 if msg is not null then glbx.header_msg( msg ); return; end if;
 htp.nl;
 htp.tableopen( cattributes=>'width=' || nvl(override_width,'"80%"') || ' cellpadding=2 cellspacing=2 border=' || pfx.ord_text_table_borderi );
  htp.tablerowopen;
    htp.tabledata(htf.bold(LNG5.EXT_TXT_602),cattributes=>pfx.ord_qbground || ' valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG5.EXT_TXT_603),cattributes=>pfx.ord_qbground || ' valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.bold(LNG5.EXT_TXT_604),cattributes=>pfx.ord_qbground || ' valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata(htf.bold(un),cattributes=>pfx.ord_qcbground || ' valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.bold(LNG5.EXT_TXT_605),cattributes=>pfx.ord_qbground || ' valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata(htf.bold(pw),cattributes=>pfx.ord_qcbground || ' valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;

end display_new_account;

procedure setup_new_account(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype )
as

 un		varchar2(100);
 pw		varchar2(100);
 pwg		varchar2(100);
 profile_name	varchar2(100);
 result		varchar2(1000);
 return_surl	varchar2(1000);
 transfer_lbox	boolean;
 parm1  	GLBX.MYARRAY;
 parm2  	GLBX.MYARRAY;

begin

 -- This section is valid for anonymous users only
 if ltype in ('PHOTOGRAPHER','OWNER','PROFILE') then return; end if;

 -- Only proceed if the feature is enabled
 if voidrec.disp_auto_create_on_purchase = 'F' then return; end if;

 if voidrec.disp_email_is_username = 'T'
  then
   -- Email Address is Username. Check if it is unique and not null
   un := upper(purchord.CONTACT_EMAIL);
   if glbx.userexists( un ) or un is null
    then
     un := get_profile_username( purchord );
   end if;
  else
   un := get_profile_username( purchord );
 end if;

 profile_name := un;
 pw := glbx.randword;
 pwg := pw || 'G';

 -- Create Profile
 transfer_lbox := FALSE;
 glbx.create_profile( surl, profile_name, un, pw, pwg, cusrec.theme_type, cusrec.theme_name, transfer_lbox, acid, TRUE, return_surl, result );
 if result is not null
  then
    display_new_account( pfx, un, pw, null, result );
 end if;

 -- Parm1 is the value
 -- Parm2 is the column name
 parm1(1) := purchord.SENDTO_NAME;
 parm1(2) := purchord.SENDTO_STREET;
 parm1(3) := purchord.SENDTO_SUBURB;
 parm1(4) := purchord.SENDTO_CITY;
 parm1(5) := purchord.SENDTO_COUNTRY;
 parm1(6) := purchord.SENDTO_POSTCODE;
 parm1(7) := purchord.CONTACT_PHONE;
 parm1(8) := purchord.CONTACT_EMAIL;
 parm1(9) := purchord.SENDTO_STATE;
 parm1(10) := purchord.SENDTO_BRANCH;
 parm1(11) := purchord.SENDTO_DEPARTMENT;
 parm1(12) := purchord.SENDTO_FIRSTNAME;
 parm1(13) := purchord.SENDTO_LASTNAME;

 parm2(1) := 'SENDTO_NAME';
 parm2(2) := 'SENDTO_STREET';
 parm2(3) := 'SENDTO_SUBURB';
 parm2(4) := 'SENDTO_CITY';
 parm2(5) := 'SENDTO_COUNTRY';
 parm2(6) := 'SENDTO_POSTCODE';
 parm2(7) := 'CONTACT_PHONE';
 parm2(8) := 'CONTACT_EMAIL';
 parm2(9) := 'SENDTO_STATE';
 parm2(10) := 'SENDTO_BRANCH';
 parm2(11) := 'SENDTO_DEPARTMENT';
 parm2(11) := 'SENDTO_FIRSTNAME';
 parm2(11) := 'SENDTO_LASTNAME';
 glbx.modify_profile( surl, parm1, parm2, result );

 display_new_account( pfx, un, pw, null, result );

end setup_new_account;

procedure accept_auth_payment( surl in varchar2, acid in integer default null, p1 in glbx.myarray, p2 in glbx.myarray, p3 in glbx.myarray, p4 in glbx.myarray, footer_api in varchar2 default null, left_api_parm in varchar2 default null )
as

  cursor c2( profid integer, vpoid integer ) is
   select poid, cp2.username
   from customer_profile cp, purchase_order po, login_session ls, customer_profile cp2
   where sysdate >= nvl(cp.authority_valid_from,sysdate-1) and
         sysdate <= nvl(cp.authority_valid_to,sysdate+1) and
         po.sessid = ls.sessid and
         po.paid_method = 'AUTHORISATION' and
         po.status = LNG4.AHC_TXT_706 and
         ls.aid = cp2.profile_id and
         po.poid = vpoid and
         cp.profile_id = profid and
         (((cp.request_authority = 'A') and (cp.pid = cp2.pid)) or
          ((cp.request_authority = 'B') and (cp.aid = cp2.aid)) or
          ((cp.request_authority = 'D') and (cp.profile_id = cp2.profile_id)) or
          ((cp.request_authority = 'C') and (cp.profile_id,cp2.profile_id) in (select mgmt_profile_id,profile_id from profile_purchase_authority))
         )
   order by poid;

  cursor c3( profid integer ) is select * from customer_profile where profile_id = profid;
  cursor c4( vpoid integer ) is select * from purchase_order where poid = vpoid;
  cursor c5( void integer ) is select * from order_style where oid = void;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 voidrec	c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 pcode		varchar2(100);
 foundrec	boolean;
 ttl		number;
 pfx		THEME%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

 function getval( val in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
   return varchar2
  as
  begin
   for j in p1.first..p1.last loop
    if p1(j) = val
     then
      return( p2(j) );
    end if;
   end loop;
   return( NULL );
 end getval;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'FNAME.ACCEPT_AUTH_PAYMENT' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );

 open c3(profid);
 fetch c3 into c3rec;
 if c3%NOTFOUND
  then
   close c3;
   return;
 end if;
 close c3;
 if c3rec.request_authority = 'F'
  then
   return;
 end if;
 if sysdate <= nvl(c3rec.authority_valid_from,sysdate-1) or
    sysdate >= nvl(c3rec.authority_valid_to,sysdate+1)
  then
   return;
 end if;
 for j in p1.first..p1.last loop
  if p1(j) is not null
   then
    open c4(p1(j));
    fetch c4 into c4rec;
    close c4;
    open c5(c4rec.oid);
    fetch c5 into voidrec;
    close c5;
    open c2( profid, p1(j) );
    fetch c2 into c2rec;
    if c2%NOTFOUND then close c2; return; end if; -- Not allowed, trying to break in
    close c2;
    ttl := glbx.grand_total_payment(c2rec.poid, include_gift_certificate=>TRUE);
    pcode := getval( p1(j),p3,p2);
    if (ttl <= nvl(c3rec.authority_limit,ttl+1) and c3rec.attribute_id is null) or
       (c3rec.attribute_id is not null)
     then
      update purchase_order
       set
        status = 'Order Authorised',
        date_purchased = sysdate,
        authorised_by = profid,
        authorised_date = sysdate,
        order_comment = p4(j),
        project_code = pcode
      where poid = p1(j);
      calc_due_date( p1(j) );
      purchase_audit_trail( surl, c4rec.poid, 'PROJECT_CODE', 'U', 'C', pcode, c4rec, voidrec);
      purchase_audit_trail( surl, c4rec.poid, 'ORDER_COMMENT', 'U', 'C', p4(j), c4rec, voidrec);
      purchase_audit_trail( surl, c4rec.poid, 'AUTHORISED_DATE', 'U', 'C', sysdate, c4rec, voidrec);
      purchase_audit_trail( surl, c4rec.poid, 'AUTHORISED_BY', 'U', 'C', profid, c4rec, voidrec);
      purchase_audit_trail( surl, c4rec.poid, 'STATUS', 'U', 'C', 'Order Authorised', c4rec, voidrec);
      -- Email customer stating they can now download
      if c4rec.contact_email is not null
       then
        gcode(1) := 'PURCHASE_ORDER_ID';
        gparam(1) := c4rec.poid;
        gcode(2) := 'CURRTIME';
        gparam(2) := to_char(sysdate,LNG.TSMASK);
        gcode(3) := 'USERNAME';
        gparam(3) := c3rec.username;
        gcode(4) := 'TOTAL';
        gparam(4) := to_char(glbx.grand_total_payment( c4rec.poid, TRUE ), LNG.MONEY_FORMAT );
        gcode(5) := 'SIGNATURE';
        gparam(5) := glbx.extract_master_parameter('MAIL SIGNATURE');
        gcode(6) := 'ORDER_COMMENT';
        gparam(6) := p4(j);
        add_poid_values( c4rec.poid, gcode, gparam );
        glbx.send( gcode, gparam, 'order_authorised_approved.tmp', p_to=>c4rec.contact_email,p_subj=>LNG5.EXT_TXT_606 || ' : ' || c4rec.poid,p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'OAA1', v_pid=>c1rec.pid, v_aid=>c1rec.aid, v_profile_id=>profid);
      end if;
    end if;
  end if;
 end loop;
 commit;

 cst.auth_payment( surl, acid, LNG4.AHC_TXT_710, footer_api, left_api_parm );

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_AUTH_PAYMENT',null,acid,errmsg=>sqlerrm);
end accept_auth_payment;

function is_not_preorder( purchord in purchase_order%ROWTYPE )
 return boolean
as
begin
 if purchord.status in ('PreOrder - No Order Made','PreOrder','PreOrder - Sent to Bank','PreOrder - Confirmed without Payment')
  then
   return( FALSE );
  else
   return( TRUE );
 end if;
end is_not_preorder;

procedure order_details( surl in varchar2, vpoid in integer, footer_api in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null, called_from in varchar2 default 'PREV', disp_close_window in char default 'F' )
as

 cursor c2( vpoid integer ) is select * from purchase_order where poid = vpoid;
 cursor c3( void integer) is select * from order_style where oid = void;

 cusrec		customer_account%ROWTYPE;
 purchord	c2%ROWTYPE;
 voidrec	c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 newline	boolean;
 ord_exists	boolean;
 grand_ttl	number;
 msg		varchar2(200);
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;
 result		varchar2(1000);

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.ORDER_DETAILS' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( sess_id, ltype, acid, profid );

 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 pfx := glbx.get_thm( cusrec.theme_name );

 glbx.main_title( surl, LNG4.AHC_TXT_653, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'C23',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;
 open c2(vpoid);
 fetch c2 into purchord;
 close c2;

 open c3(purchord.oid);
 fetch c3 into voidrec;
 close c3;
 show_customer_order( surl, cusrec, theme_rec, voidrec, purchord.sessid, stype, ltype, pfx, acid, 'BROWSE', ord_exists, grand_ttl, newline, null );
-- disp_order_page( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, result, bypass=>TRUE );

 if download_exists(purchord.poid)
  then
   htp.nl;
   list_downloadable( surl, purchord, pfx, theme_rec, voidrec, acid );
 end if;

 htp.nl;
 if called_from = 'AUTH'
  then
   htp.anchor( 'cst.auth_payment?surl=' || surl || '&acid=' || acid || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+'), LNG4.AHC_TXT_564 );
 elsif called_from = 'AUTHP'
  then
   htp.anchor( 'cst.auth_payment_report?surl=' || surl || '&acid=' || acid || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+'), LNG4.AHC_TXT_564 );
 elsif called_from = 'PREV'
  then
   htp.anchor( 'cst.previous_orders?surl=' || surl || '&acid=' || acid || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&disp_close_window=' || disp_close_window, LNG4.AHC_TXT_564 );
 end if;

 htp.p( '</CENTER>' );
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'CST', 'ORDER_DETAILS',cusrec.pid,cusrec.aid,errmsg=>sqlerrm,extdet=>'VPOID:' || vpoid );
end order_details;

procedure disp_payment_screen( surl in varchar2, acid in integer default null, msg in varchar2 default null, calltype in varchar2 default 'FULL' )
as

 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.DISP_PAYMENT_SCREEN' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if calltype = 'PHOTOGRAPHER_ORDER'
  then
   phg_order_initialise(sess_id, profid, cusrec, pfx, theme_rec, purchord, voidrec );
  else
   glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
 end if;
 disp_payment_page( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, msg, calltype );

exception when others then
 glbx.error_details( 'CST', 'DISP_PAYMENT_SCREEN',cusrec.pid,cusrec.aid,errmsg=>sqlerrm );
end disp_payment_screen;

procedure phg_order_initialise( sess_id in integer, profid out integer, cusrec out customer_account%ROWTYPE, pfx out theme%ROWTYPE, theme_rec out theme_types%ROWTYPE, purchord out purchase_order%ROWTYPE, voidrec out order_style%ROWTYPE )
as

 cursor c1(sess_id integer) is select * from purchase_order where sessid = sess_id;
 cursor c2(void integer) is select * from order_style where oid = void;
 cursor c3(sess_id integer) is select aid from login_session where sessid = sess_id;
 cursor c4(acct varchar2) is select * from customer_account where username = upper(acct);

 owner_id  integer;

begin

 open c1(sess_id);
 fetch c1 into purchord;
 close c1;
 open c2(purchord.oid);
 fetch c2 into voidrec;
 close c2;
 open c3(sess_id);
 fetch c3 into owner_id;
 close c3;
 pfx := glbx.photo_lf(owner_id);
 profid := null;
 theme_rec := glbx.get_theme_types(owner_id);
 open c4( glbx.extract_master_parameter('ONLINE_ORDER_ACCOUNT') );
 fetch c4 into cusrec;
 close c4;

exception when others then
 glbx.error_details( 'CST', 'PHG_ORDER_INITIALISE',cusrec.pid,cusrec.aid,errmsg=>sqlerrm );
end phg_order_initialise;

procedure check_mandatory(action in varchar2, check_col in char, voidrec in order_style%ROWTYPE, purchrec in purchase_order%ROWTYPE, pfx in theme%ROWTYPE, result in out varchar2 )
as
begin

  -- Check Mandatory Columns
  if substr(check_col,1,1) = 'T' and purchrec.sendto_name is null and nvl(voidrec.columns_name_toggle,'T') = 'T'
   then
    result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_name, pfx);
  end if;
  if substr(check_col,1,1) = 'T' and purchrec.sendto_lastname is null and nvl(voidrec.columns_name_toggle,'T') = 'F'
   then
    result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_lastname, pfx);
  end if;
  if substr(check_col,2,1) = 'T' and purchrec.sendto_street is null
   then
    result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_street, pfx);
  end if;
  if substr(check_col,20,1) = 'T' and purchrec.sendto_branch is null
   then
    result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_branch, pfx);
  end if;
  if substr(check_col,21,1) = 'T' and purchrec.sendto_department is null
   then
    result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_department, pfx);
  end if;
  if substr(check_col,3,1) = 'T' and purchrec.sendto_suburb is null
   then
    result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_suburb, pfx);
  end if;
  if substr(check_col,4,1) = 'T' and purchrec.sendto_city is null
   then
    result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_city, pfx);
  end if;
  if substr(check_col,5,1) = 'T' and purchrec.sendto_postcode is null
   then
    result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_postcode, pfx);
  end if;
  if substr(check_col,17,1) = 'T' and purchrec.sendto_state is null and action = 'ORDER'
   then
    result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_state, pfx);
  end if;
  if substr(check_col,19,1) = 'T' and purchrec.sendto_state is null and action <> 'ORDER'
   then
    result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_state, pfx);
  end if;
  if substr(check_col,6,1) = 'T' and purchrec.sendto_country is null
   then
    result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_country, pfx);
  end if;
  if substr(check_col,7,1) = 'T' and purchrec.contact_phone is null
   then
    result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_phone, pfx);
  end if;
  if substr(check_col,8,1) = 'T' and purchrec.contact_email is null
   then
    result := result || format_result(LNG5.EXT_TXT_608 || ' ' || voidrec.columns_email, pfx);
  end if;
  if substr(check_col,9,1) = 'T' and purchrec.customer_comment is null
   then
    result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_comment, pfx);
  end if;

  if action = 'ORDER'
   then

    if substr(check_col,11,1) = 'T' and purchrec.customer_column1 is null
     then
      result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_cust_col1, pfx);
    end if;
    if substr(check_col,12,1) = 'T' and purchrec.customer_column2 is null
     then
      result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_cust_col2, pfx);
    end if;
    if substr(check_col,13,1) = 'T' and purchrec.customer_column3 is null
     then
      result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_cust_col3, pfx);
    end if;
    if substr(check_col,14,1) = 'T' and purchrec.customer_column4 is null
     then
      result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_cust_col4, pfx);
    end if;
    if substr(check_col,15,1) = 'T' and purchrec.customer_column5 is null
     then
      result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_cust_col5, pfx);
    end if;
    if substr(check_col,16,1) = 'T' and purchrec.customer_column6 is null
     then
     result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_cust_col6, pfx);
    end if;

  else

    if substr(check_col,13,1) = 'T' and purchrec.customer_column1 is null
     then
      result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_cust_col1, pfx);
    end if;
    if substr(check_col,14,1) = 'T' and purchrec.customer_column2 is null
     then
      result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_cust_col2, pfx);
    end if;
    if substr(check_col,15,1) = 'T' and purchrec.customer_column3 is null
     then
      result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_cust_col3, pfx);
    end if;
    if substr(check_col,16,1) = 'T' and purchrec.customer_column4 is null
     then
      result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_cust_col4, pfx);
    end if;
    if substr(check_col,17,1) = 'T' and purchrec.customer_column5 is null
     then
      result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_cust_col5, pfx);
    end if;
    if substr(check_col,18,1) = 'T' and purchrec.customer_column6 is null
     then
     result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_cust_col6, pfx);
    end if;

  end if;

  if action = 'ORDER'
   then
    if substr(check_col,10,1) = 'T' and purchrec.do_not_split_order is null
     then
      result := result || format_result(LNG5.EXT_TXT_607 || ' ' || voidrec.columns_split , pfx);
    end if;
  end if;

  if result is not null
   then
    result := '<div style="margin: 20px 15%; background-color: #' || pfx.instruct_cell_colour || '; border: #' || pfx.instruct_cell_brd_clr || ' 1px solid; color: #' || pfx.instruct_text_colour || '; padding: 5px 35px">' ||
              '<p>' || htf.bold('* IMPORTANT Please check your details') || '<p><ul>' || result || '</ul></div>';
  end if;

end check_mandatory;

function format_result( msg in varchar2, pfx in theme%ROWTYPE )
 return varchar2
as
begin
 return( '<li>' || msg || '</li>' );
end format_result;

-- This procedure checks that data entered is valid based on fixed rules
procedure smart_check( purchord in purchase_order%ROWTYPE, pfx in theme%ROWTYPE, result in out varchar2 )
as
 nmb	integer;
 fnd	boolean;
 fnd2	boolean;
begin

 -- Check Name
 fnd := false;
 fnd2 := false;
 if purchord.sendto_name is not null
  then
   -- Cannot contain symbols
   if purchord.sendto_name <> translate(purchord.sendto_name,'!@#$%^&*()_+={}[]\|:;"<>?/`0123456789',lpad(' ',37,' '))
    then
     result := result || format_result(LNG5.EXT_TXT_609, pfx);
     fnd := TRUE;
     fnd2 := TRUE;
   end if;

   -- Must Contain at least one Vowel
   if upper(purchord.sendto_name) = translate(upper(purchord.sendto_name),'AEIOUY','     ') and not fnd2
    then
     result := result || format_result(LNG5.EXT_TXT_609, pfx);
     fnd := TRUE;
     fnd2 := TRUE;
   end if;

   -- Must Contain at least two words
   if instr(purchord.sendto_name,' ') = 0 and not fnd2
    then
     result := result || format_result(LNG5.EXT_TXT_609, pfx);
     fnd := TRUE;
   end if;

 end if;

 -- Check Street
 if purchord.sendto_street is not null
  then
   -- Cannot contain symbols
   if purchord.sendto_street <> translate(purchord.sendto_street,'!@#$%^&*()_-+={}[]\|:;"''<>,?/`',lpad(' ',30,' '))
    then
     result := result || format_result(LNG5.EXT_TXT_610, pfx);
     fnd := TRUE;
   end if;
 end if;

 -- Check Email
 fnd2 := false;
 if purchord.contact_email is not null
  then
   -- Must contain an @ symbol
   if instr(purchord.contact_email,'@') < 2 -- @ cannot be first character
    then
     result := result || format_result(LNG5.EXT_TXT_611, pfx);
     fnd := TRUE;
     fnd2 := TRUE;
   end if;
   -- Must contain at least one period
   if instr(purchord.contact_email,'.') < 2 and not fnd2 -- . cannot be first character
    then
     result := result || format_result(LNG5.EXT_TXT_611, pfx);
     fnd := TRUE;
   end if;
 end if;

 -- Check Phone Number
 if purchord.contact_phone is not null
  then
   begin
    nmb := to_number(replace(translate(purchord.contact_phone,'()+-','    '),' ',''));
   exception
    when others then
     result := result || format_result(LNG5.EXT_TXT_613, pfx);
     fnd := TRUE;
   end;
 end if;

 -- Check Post Code
 if purchord.sendto_postcode is not null
  then
   if purchord.sendto_country in ('AUSTRALIA','USA')
    then
     begin
      nmb := to_number(replace(purchord.sendto_postcode,' ',''));
     exception
      when others then
       result := result || format_result(LNG5.EXT_TXT_614, pfx);
     fnd := TRUE;
     end;
   end if;
 end if;

 if fnd
  then
    result := format_result( htf.bold(LNG5.EXT_TXT_615), pfx) || result;
 end if;

end smart_check;

procedure display_column(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype, msg in varchar2, colnum in integer, colval varchar2, edit_browse in varchar2, newline in out boolean, onecol in boolean)
as

 function cval( nmb in integer, val1 in varchar2, val2 in varchar2, val3 in varchar2 )
  return varchar2
 as
 begin
  if nmb = 1 then return (val1);
  elsif nmb = 2 then return (val2);
  elsif nmb = 3 then return (val3);
  end if;
 end cval;

begin
 for j in 1..8 loop
  if j =  voidrec.disp_ord_summ_order and cval(colnum,voidrec.disp_ord_summ_col,voidrec.disp_ord_summ_col2,voidrec.disp_ord_summ_col3) = colval and voidrec.disp_ord_summ = 'T'
   then
    if onecol then htp.tablerowopen; htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' ); end if;
      disp_order_summary( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, edit_browse, newline );
    if onecol then htp.p( '</TD>' ); htp.tablerowclose; end if;
  end if;
  if j =  voidrec.disp_gift_wrap_order and cval(colnum,voidrec.disp_gift_wrap_col,voidrec.disp_gift_wrap_col2,voidrec.disp_gift_wrap_col3) = colval and voidrec.disp_gift_wrap = 'T'
   then
    if onecol then htp.tablerowopen; htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' ); end if;
      disp_additional_options( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, edit_browse, newline );
    if onecol then htp.p( '</TD>' ); htp.tablerowclose; end if;
  end if;
  if j =  voidrec.disp_ord_trk_order and cval(colnum,voidrec.disp_ord_trk_col,voidrec.disp_ord_trk_col2,voidrec.disp_ord_trk_col3) = colval and voidrec.disp_ord_trk = 'T'
   then
    if onecol then htp.tablerowopen; htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' ); end if;
      disp_order_tracking( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, edit_browse, newline );
    if onecol then htp.p( '</TD>' ); htp.tablerowclose; end if;
  end if;
  if j =  voidrec.disp_cust_order and cval(colnum,voidrec.disp_cust_col,voidrec.disp_cust_col2,voidrec.disp_cust_col3) = colval and voidrec.disp_cust = 'T'
   then
    if onecol then htp.tablerowopen; htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' ); end if;
      disp_cust_details( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, edit_browse, newline, onecol );
    if onecol then htp.p( '</TD>' ); htp.tablerowclose; end if;
  end if;
  if j =  voidrec.disp_shipping_order and cval(colnum,voidrec.disp_shipping_col,voidrec.disp_shipping_col2,voidrec.disp_shipping_col3) = colval and voidrec.disp_shipping = 'T'
   then
    if onecol then htp.tablerowopen; htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' ); end if;
      disp_shipping( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, edit_browse, newline );
    if onecol then htp.p( '</TD>' ); htp.tablerowclose; end if;
  end if;
  if j =  voidrec.disp_postage_order and cval(colnum,voidrec.disp_postage_col,voidrec.disp_postage_col2,voidrec.disp_postage_col3) = colval and voidrec.disp_postage = 'T'
   then
    if onecol then htp.tablerowopen; htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' ); end if;
      disp_postage_details( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, edit_browse, newline );
    if onecol then htp.p( '</TD>' ); htp.tablerowclose; end if;
  end if;
  if j =  voidrec.disp_payment_method_order and cval(colnum,voidrec.disp_payment_method_col,voidrec.disp_payment_method_col2,voidrec.disp_payment_method_col3) = colval and voidrec.disp_payment_method = 'T'
   then
    if onecol then htp.tablerowopen; htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' ); end if;
      disp_payment_method( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, edit_browse, newline );
    if onecol then htp.p( '</TD>' ); htp.tablerowclose; end if;
  end if;
  if j =  voidrec.disp_total_order and cval(colnum,voidrec.disp_total_col,voidrec.disp_total_col2,voidrec.disp_total_col3) = colval and voidrec.disp_total = 'T'
   then
    if onecol then htp.tablerowopen; htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' ); end if;
      disp_order_total_details( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, edit_browse, newline );
    if onecol then htp.p( '</TD>' ); htp.tablerowclose; end if;
  end if;
 end loop;
end display_column;

function one_col( voidrec in order_style%ROWTYPE, nmb in integer )
 return boolean
as
begin
 if nmb = 1
  then
   if (voidrec.disp_ord_summ_col in ('0','1') or voidrec.disp_ord_summ = 'F' ) and
      (voidrec.disp_gift_wrap_col in ('0','1') or voidrec.disp_gift_wrap = 'F' ) and
      (voidrec.disp_ord_trk_col in ('0','1') or voidrec.disp_ord_trk = 'F' ) and
      (voidrec.disp_cust_col in ('0','1') or voidrec.disp_cust = 'F' ) and
      (voidrec.disp_shipping_col in ('0','1') or voidrec.disp_shipping = 'F' ) and
      (voidrec.disp_postage_col in ('0','1') or voidrec.disp_postage = 'F' ) and
      (voidrec.disp_payment_method_col in ('0','1') or voidrec.disp_payment_method = 'F' ) and
      (voidrec.disp_total_col in ('0','1') or voidrec.disp_total = 'F' )
    then
     return( TRUE );
    else
     return( FALSE );
   end if;

 elsif nmb = 2
  then
   if (voidrec.disp_ord_summ_col2 in ('0','1') or voidrec.disp_ord_summ = 'F' ) and
      (voidrec.disp_gift_wrap_col2 in ('0','1') or voidrec.disp_gift_wrap = 'F' ) and
      (voidrec.disp_ord_trk_col2 in ('0','1') or voidrec.disp_ord_trk = 'F' ) and
      (voidrec.disp_cust_col2 in ('0','1') or voidrec.disp_cust = 'F' ) and
      (voidrec.disp_shipping_col2 in ('0','1') or voidrec.disp_shipping = 'F' ) and
      (voidrec.disp_postage_col2 in ('0','1') or voidrec.disp_postage = 'F' ) and
      (voidrec.disp_payment_method_col2 in ('0','1') or voidrec.disp_payment_method = 'F' ) and
      (voidrec.disp_total_col2 in ('0','1') or voidrec.disp_total = 'F' )
    then
     return( TRUE );
    else
     return( FALSE );
   end if;

 elsif nmb = 3
  then
   if (voidrec.disp_ord_summ_col3 in ('0','1') or voidrec.disp_ord_summ = 'F' ) and
      (voidrec.disp_gift_wrap_col3 in ('0','1') or voidrec.disp_gift_wrap = 'F' ) and
      (voidrec.disp_ord_trk_col3 in ('0','1') or voidrec.disp_ord_trk = 'F' ) and
      (voidrec.disp_cust_col3 in ('0','1') or voidrec.disp_cust = 'F' ) and
      (voidrec.disp_shipping_col3 in ('0','1') or voidrec.disp_shipping = 'F' ) and
      (voidrec.disp_postage_col3 in ('0','1') or voidrec.disp_postage = 'F' ) and
      (voidrec.disp_payment_method_col3 in ('0','1') or voidrec.disp_payment_method = 'F' ) and
      (voidrec.disp_total_col3 in ('0','1') or voidrec.disp_total = 'F' )
    then
     return( TRUE );
    else
     return( FALSE );
   end if;
 end if;

end one_col;

function return_link( surl in varchar2, stype in integer, ltype in varchar2, voidrec in order_style%ROWTYPE, pfx in theme%ROWTYPE, acid in integer, footer_api in varchar2 default null, left_api in varchar2 default null, left_api_parm in varchar2 default null, location in varchar2 default '1' )
 return varchar2
as

 cusloc	varchar2(100);
 cuspos	varchar2(1000);
 retlnk	varchar2(1000);

begin
 if ltype = 'PHOTOGRAPHER'
  then
   cusloc := 'PHG_RIGHT';
   cuspos := 'phg.glbx.acct_home?surl=' || surl || '&acid=' || acid || '&rnd=' || to_char(sysdate,'SSSSS');
 elsif pfx.keep_lhf = 'N'
  then
   cusloc := '_self';
   cuspos := 'cst.acct_bottom?surl=' || surl || '&stype=' || stype;
 else
   cusloc := 'CUS_BOTTOM';
   cuspos := 'cst.acct_bottom?surl=' || surl || '&stype=' || stype;
 end if;

 if footer_api is not null
  then
   cuspos := footer_api || '?surl=' || surl || '&acid=' || acid || '&left_api_parm=' || replace(left_api_parm,' ','+');
 end if;

 if voidrec.disp_graphic_button = 'T'
  then
   if location = '1'
    then
     retlnk := htf.anchor2( cuspos, htf.img( DECS.IMAGE_LOCATION || 'adminc/home.gif',cattributes=>'border=0',calt=>voidrec.text_home1 ),ctarget=>cusloc );
    else
     retlnk := htf.anchor2( cuspos, htf.img( DECS.IMAGE_LOCATION || 'adminc/home.gif',cattributes=>'border=0',calt=>voidrec.text_home2 ),ctarget=>cusloc );
   end if;
  else
   if location = '1'
    then
     retlnk := htf.anchor2( cuspos, voidrec.text_home1, ctarget=>cusloc );
    else
     retlnk := htf.anchor2( cuspos, voidrec.text_home2, ctarget=>cusloc );
   end if;
 end if;
 return( retlnk );

end return_link;

procedure confirm_purchase( surl in varchar2, acid in integer, action in varchar2 )
as

 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 quick_exit	boolean;
 vaction	varchar2(100);
 sts		varchar2(100);

begin

 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.CONFIRM_PURCHASE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
 -- Business Feature overriden, get the other one
 if voidrec.bftr <> 'Use Customer Account Business Feature'
  then
   theme_rec := glbx.get_theme_types( voidrec.bftr );
 end if;

 if voidrec.laf <> 'Use Customer Account Look and Feel'
  then
   pfx := glbx.get_thm( voidrec.laf );
 end if;

 update purchase_order
  set
   status = 'PreOrder - Confirmed without Payment'
 where
  poid = purchord.poid;

 purchase_audit_trail( surl, purchord.poid, 'STATUS', 'U', 'C', 'PreOrder - Confirmed without Payment', purchord, voidrec);
 commit;

 disp_payment_page( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, NULL, 'FULL' );
 htp.nl;
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'FNAME', 'CONFIRM_PURCHASE',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end confirm_purchase;

procedure merchant_goto( surl in varchar2, acid in integer )
as

 cursor c1( ploc varchar2 ) is select return_key from merchant_centralised_return where piction_location = ploc;

 c1rec	        c1%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 mtype		merchant_type;
 chelp		varchar2(2000);
 cnts		number;

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.MERCHANT_GOTO' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
 -- Business Feature overriden, get the other one
 htp.p( '<CENTER>' );
 if voidrec.bftr <> 'Use Customer Account Business Feature'
  then
   theme_rec := glbx.get_theme_types( voidrec.bftr );
 end if;

 if voidrec.laf <> 'Use Customer Account Look and Feel'
  then
   pfx := glbx.get_thm( voidrec.laf );
 end if;

 if is_not_preorder( purchord )
  then
   recalc_order( surl, stype, sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec, 'L' );
   return;
 end if;

 mtype := merchant_details(purchord.pid);
 pfx.keep_lhf := 'L';
-- if mtype.nobutton_page = 'TRUE'
--  then
-- end if;

 glbx.main_title( surl, NULL, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if voidrec.payment_cc = 'F' then return; end if;
 if glbx.extract_master_parameter('ENABLE_ALL_MERCHANT') = 'FALSE' then return; end if;
 chelp := glbx.extract_master_parameter('CREDIT_HELP_PAGE');
 if chelp is not null
  then
   chelp := htf.anchor2( chelp, htf.img( DECS.IMAGE_LOCATION || 'adminc/help_how.gif',cattributes=>'border=0'), ctarget=>'CREDIT_HELP');
 end if;

 update purchase_order
  set
   paid_method = 'MERCHANT',
   status = LNG4.AHC_TXT_672
 where poid = purchord.poid;

 purchase_audit_trail( surl, purchord.poid, 'PAID_METHOD', 'U', 'C', 'MERCHANT', purchord, voidrec);
 purchord.paid_method := 'MERCHANT';
 purchase_audit_trail( surl, purchord.poid, 'STATUS', 'U', 'C', LNG4.AHC_TXT_672, purchord, voidrec);
 commit;

 htp.bold( voidrec.text_title_merchant );
 htp.nl;
 htp.nl;
 htp.p( voidrec.payment_cc_text );
 htp.nl;
 if mtype.merchant_provider = 'CBANK'
  then
     htp.formopen( mtype.merchant_url );
     htp.formhidden( 'MERCHID', mtype.merchant_id );
     begin
      cnts := glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE ) * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1);
     exception
     when others then
       cnts := glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE );
     end;
     htp.formhidden( 'AMT', trim(to_char(cnts,'999999999.99')) );
     htp.formhidden( 'MTID', to_char(purchord.poid));
     htp.formhidden( 'NAME', substr(nvl(purchord.billing_name,purchord.sendto_name),1,30) );
     htp.formhidden( 'EMAIL', substr(purchord.contact_email,1,64));
     if trim(owa_util.get_cgi_env( 'SERVER_PORT' )) = '80'
      then
       htp.formhidden( 'SUCCESSURL', mtype.merchant_returl || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_nab?wrk=T&surl=' || glbx.rndsurl(surl) ||'&responseText=#M#&authorisationCode=#C#&invoiceNumber=#R#&amountPaid=#A#&transactionRef=#I#&surname=#N#&currency=#U#' );
       htp.formhidden( 'FAILURL', mtype.merchant_returl || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_nab?wrk=F&surl=' || glbx.rndsurl(surl) ||'&responseText=#M#&authorisationCode=#C#&invoiceNumber=#R#&amountPaid=#A#&transactionRef=#I#&surname=#N#&currency=#U#' );
      else
       htp.formhidden( 'SUCCESSURL', mtype.merchant_returl || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_nab?wrk=T&surl=' || glbx.rndsurl(surl) ||'&responseText=#M#&authorisationCode=#C#&invoiceNumber=#R#&amountPaid=#A#&transactionRef=#I#&surname=#N#&currency=#U#' );
       htp.formhidden( 'FAILURL', mtype.merchant_returl || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_nab?wrk=F&surl=' || glbx.rndsurl(surl) ||'&responseText=#M#&authorisationCode=#C#&invoiceNumber=#R#&amountPaid=#A#&transactionRef=#I#&surname=#N#&currency=#U#' );
     end if;
     htp.formsubmit( null, voidrec.text_cc_message );
     htp.formclose;

 elsif mtype.merchant_provider = 'NAB'
  then
     htp.formopen( mtype.merchant_url );
     htp.formhidden( 'MERCHID', mtype.merchant_id );
     begin
      cnts := glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE ) * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1);
     exception
     when others then
       cnts := glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE );
     end;
     htp.formhidden( 'AMT', trim(to_char(cnts,'999999999.99')) );
     htp.formhidden( 'MTID', to_char(purchord.poid));
     htp.formhidden( 'NAME', substr(nvl(purchord.billing_name,purchord.sendto_name),1,30) );
     htp.formhidden( 'EMAIL', substr(purchord.contact_email,1,64));
     if trim(owa_util.get_cgi_env( 'SERVER_PORT' )) = '80'
      then
       htp.formhidden( 'SUCCESSURL', mtype.merchant_returl || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_nab?wrk=T&surl=' || glbx.rndsurl(surl) ||'&responseText=#M#&authorisationCode=#C#&invoiceNumber=#R#&amountPaid=#A#&transactionRef=#I#&surname=#N#&currency=#U#' );
       htp.formhidden( 'FAILURL', mtype.merchant_returl || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_nab?wrk=F&surl=' || glbx.rndsurl(surl) ||'&responseText=#M#&authorisationCode=#C#&invoiceNumber=#R#&amountPaid=#A#&transactionRef=#I#&surname=#N#&currency=#U#' );
      else
       htp.formhidden( 'SUCCESSURL', mtype.merchant_returl || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_nab?wrk=T&surl=' || glbx.rndsurl(surl) ||'&responseText=#M#&authorisationCode=#C#&invoiceNumber=#R#&amountPaid=#A#&transactionRef=#I#&surname=#N#&currency=#U#' );
       htp.formhidden( 'FAILURL', mtype.merchant_returl || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_nab?wrk=F&surl=' || glbx.rndsurl(surl) ||'&responseText=#M#&authorisationCode=#C#&invoiceNumber=#R#&amountPaid=#A#&transactionRef=#I#&surname=#N#&currency=#U#' );
     end if;
     htp.formsubmit( null, voidrec.text_cc_message );
     htp.formclose;

 elsif mtype.merchant_provider = 'SAFEPAY'
  then
     htp.formopen( mtype.merchant_url );
     begin
      cnts := glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE ) * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1);
     exception
      when others then
       cnts := glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE );
     end;
     htp.formhidden( 'Locale', 'en' );
     --htp.formhidden( 'ReturnURL', 'http://wallace.piction.com:81/SSL_DR.asp?DR=${DR}'  );
     htp.formhidden( 'ReturnURL', mtype.merchant_returl  );
     htp.formhidden( 'MerchantID', mtype.merchant_id );
     htp.formhidden( 'PurchaseAmount', trim(to_char(cnts * 100,'999999999')) );
     htp.formhidden( 'SessionID', purchord.poid || '-' || surl );
     htp.formsubmit( 'SubButL', voidrec.text_cc_message );
     htp.formclose;

 elsif mtype.merchant_provider = 'SECUREPAY'
  then
     htp.formopen( mtype.merchant_url );
     cnts := to_char(glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE )*100);
     begin
      cnts := round(cnts * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1));
     exception
      when others then
       cnts := to_char(glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE )*100);
     end;

     htp.formhidden( 'MERCHANTID', mtype.merchant_id );
     htp.formhidden( 'AMOUNT', cnts );
     htp.formhidden( 'PONUM', '[' || substr(glbx.extract_master_parameter('NODE_NAME'),1,12) || ']' || to_char(purchord.pid) || '-' || to_char(purchord.poid)); -- Prefix the purchase order by the photographer PID so reconcilliation reports can be done the server
     htp.formhidden( 'OPTIONAL_INFO', surl );
     if trim(owa_util.get_cgi_env( 'SERVER_PORT' )) = '80'
      then
       htp.formhidden( 'SUCCESS_PAGE', mtype.merchant_returl || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_securepay?wrk=T&ponum=' );
       htp.formhidden( 'FAILURE_PAGE', mtype.merchant_returl || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_securepay?wrk=F&ponum=' );
      else
       htp.formhidden( 'SUCCESS_PAGE', mtype.merchant_returl || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_securepay?wrk=T&ponum=' );
       htp.formhidden( 'FAILURE_PAGE', mtype.merchant_returl || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'fname.accept_merchant_securepay?wrk=T&ponum=' );
     end if;
     htp.formsubmit( null, voidrec.text_cc_message );
     htp.formclose;

 elsif mtype.merchant_provider = 'SECUREBILL'
  then
     htp.formopen( mtype.merchant_url );
     cnts := to_char(glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE )*100);
     begin
      cnts := round(cnts * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1));
     exception
      when others then
       cnts := to_char(glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE )*100);
     end;

     open c1( owa_util.get_cgi_env('SCRIPT_NAME') || '/' );
     fetch c1 into c1rec;
     if c1%NOTFOUND
      then
        htp.formhidden( '_SBILL_IN_bill_id', 'Z' || to_char(purchord.poid) );
      else
        htp.formhidden( '_SBILL_IN_bill_id', c1rec.return_key || to_char(purchord.poid) );
     end if;
     close c1;
     htp.formhidden( '_SBILL_IN_org_id', mtype.merchant_id );
     htp.formhidden( '_SBILL_IN_cents_amount', to_char( mod(cnts,100), '00' ) );
     htp.formhidden( '_SBILL_IN_dollar_amount', to_char( round(cnts / 100), '00' ) );
     htp.formhidden( '_SBILL_IN_customer_name', purchord.sendto_name );
     htp.formhidden( '_SBILL_IN_bill_type', 'Merchant' );
     htp.formsubmit( null, voidrec.text_cc_message );
     htp.formclose;

 elsif mtype.merchant_provider = 'ANZ-II'
  then
     htp.formopen( mtype.merchant_url );
     begin
      cnts := glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE )*100 * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1);
     exception
     when others then
       cnts := glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE )*100;
     end;

     htp.formhidden( 'MERCHANTID', mtype.merchant_id );
     htp.formhidden( 'MERCHANTTXNREF', to_char(purchord.poid));
     htp.formhidden( 'ORDERINFO', SURL);
     htp.formhidden( 'LOCALE', 'en');
     htp.formhidden( 'PURCHASEAMOUNT', trim(to_char(cnts)) );
     htp.formhidden( 'RETURNURL', mtype.merchant_returl );
     htp.formsubmit( null, voidrec.text_cc_message );
     htp.formclose;

 elsif mtype.merchant_provider = 'DIRECT PAYMENT(NZ)'
  then
     htp.formopen( mtype.merchant_url || '/' || 'pxaccess.asp' );
     cnts := to_char(glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE )*100);
     begin
      cnts := glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE ) * nvl(to_number(glbx.extract_master_parameter('MERCHANT_CONVERSION')),1);
     exception
     when others then
       cnts := glbx.grand_total_payment( purchord.poid, include_gift_certificate=>TRUE );
     end;

     htp.formhidden( 'USERID', mtype.merchant_id );
     htp.formhidden( 'AMOUNT', trim(to_char(cnts,'999999999.99')) );
     htp.formhidden( 'TXNDATA1', to_char(purchord.poid));
     htp.formhidden( 'TXNDATA2', substr(nvl(purchord.billing_name,purchord.sendto_name),1,60));
     htp.formhidden( 'TXNDATA3', SURL);
     htp.formhidden( 'MERCHANTREFERENCE', to_char(purchord.poid));
     htp.formhidden( 'EMAIL', substr(purchord.contact_email,1,64));
     htp.formhidden( 'URLSUCCESS', mtype.merchant_url || '/' || 'pxsuccess.asp' );
     htp.formhidden( 'URLFAIL', mtype.merchant_url || '/' || 'pxfail.asp' );
     htp.formsubmit( null, voidrec.text_cc_message );
     htp.formclose;

 end if;
 htp.nl;
 htp.italic( '<B>Note:</B>' || voidrec.text_merchant_warning );
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'FNAME', 'MERCHANT_GOTO',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end merchant_goto;

procedure check_credit_already_done( vpoid integer )
as

 cursor c1(vpoid integer) is select * from purchase_order where poid = vpoid and paid_method = 'MERCHANT' and (m_response_code is not null or m_rrn is not null);
 c1rec  c1%ROWTYPE;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin
 open c1( vpoid );
 fetch c1 into c1rec;
 close c1;
 if c1rec.poid is not null
  then
   -- Send Email to Administrator notifying them of duplicate order
    gcode(1) := 'PURCHASE_ORDER_ID';
    gparam(1) := c1rec.poid;
    gcode(2) := 'CURRTIME';
    gparam(2) := to_char(sysdate,LNG.TSMASK);
    gcode(3) := 'RESPONSE_CODE';
    gparam(3) := c1rec.m_response_code;
    gcode(4) := 'RESPONSE_TEXT';
    gparam(4) := c1rec.M_response_text;
    gcode(5) := 'RRN';
    gparam(5) := c1rec.m_rrn;
    gcode(6) := 'NAME';
    gparam(6) := c1rec.sendto_name;
    gcode(7) := 'SIGNATURE';
    gparam(7) := glbx.extract_master_parameter('MAIL SIGNATURE');
    -- Send to Administrator
    add_poid_values( c1rec.poid, gcode, gparam );
    glbx.send( gcode, gparam, 'order_duplicate.tmp', p_to=>nvl(glbx.extract_master_parameter('PICTION_EMAIL_ACCT'),glbx.extract_master_parameter('MAIL_FROM')),p_subj=>LNG5.EXT_TXT_617 || ':'  || c1rec.poid,p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'OD1', v_pid=>c1rec.pid);
 end if;
exception when others then
 glbx.error_details( 'FNAME', 'CHECK_CREDIT_ALREADY_DONE',errmsg=>sqlerrm,extdet=>'VPOID:' || vpoid);
end check_credit_already_done;

procedure add_poid_values( vpoid in integer, gcode in out NOCOPY GLBX.MYARRAY, gparam in out NOCOPY GLBX.MYARRAY )
as

 poparm1 	GLBX.MYARRAY;
 poparm2 	GLBX.MYARRAY_NMB;
 ctr	 	integer;

begin
    glbx.calculate_pricing( vpoid, poparm1, poparm2 );
    ctr := nvl(gcode.last,0) + 1;
    if poparm1.count = 0 then return; end if;

    for j in poparm1.first..poparm1.last loop
      gcode(ctr) := NULL;
      gparam(ctr) := NULL;
      gcode(ctr) := 'PURCHREC.' || poparm1(j);
      gparam(ctr) := trim(to_char(round(poparm2(j),2),'9999999999990.99')); -- Round value as template has no control over it and format nicely. Do not format to money as some values are %
      ctr := ctr + 1;
    end loop;

end add_poid_values;

procedure user_fee_categories( shoprec in shopping_basket%ROWTYPE, voidrec in order_style%ROWTYPE, p_code in out NOCOPY GLBX.MYARRAY, p_category in out NOCOPY GLBX.MYARRAY, p_default in out NOCOPY GLBX.MYARRAY, p_newprice in out NOCOPY GLBX.MYARRAY_NMB )
as

 cursor c1( vspb integer ) is select * from user_fees where spb = vspb order by order_by;
 cursor c2( v_umo integer ) is select * from umo where umo_id = v_umo;

 c2rec	c2%ROWTYPE;
 ctr	integer;
 vppi	integer;
 pvsize varchar2(4000);

 -- This code supports a comma delimited list (like an IN). If ! is the first character, then this is a NOT IN
 function matches( val1 varchar2, val2 varchar2 )
  return boolean
 as
 begin
  if substr(val2,1,1) = '!'
   then
    if instr(',' || substr(val2,2) || ',', ',' || val1 || ',') = 0 then return( TRUE ); else return( FALSE ); end if;
   else
    if instr(',' || val2 || ',', ',' || val1 || ',' ) = 0 then return( FALSE ); else return( TRUE ); end if;
  end if;
 end matches;

begin
 ctr := 0;
 open c2( shoprec.phid );
 fetch c2 into c2rec;
 close c2;
 for c1rec in c1( voidrec.spb ) loop

  if (c1rec.display_when_value = 'ALL' and c1rec.display_when_repeated is null) or
     (c1rec.display_when_repeated is not null and c1rec.display_when_repeated = 'ATTRIBUTE1' and matches(c2rec.attribute1,c1rec.display_when_equals)) or
     (c1rec.display_when_repeated is not null and c1rec.display_when_repeated = 'ATTRIBUTE2' and matches(c2rec.attribute2,c1rec.display_when_equals)) or
     (c1rec.display_when_repeated is not null and c1rec.display_when_repeated = 'ATTRIBUTE3' and matches(c2rec.attribute3,c1rec.display_when_equals)) or
     (c1rec.display_when_repeated is not null and c1rec.display_when_repeated = 'ATTRIBUTE4' and matches(c2rec.attribute4,c1rec.display_when_equals)) or
     (c1rec.display_when_repeated is not null and c1rec.display_when_repeated = 'ATTRIBUTE5' and matches(c2rec.attribute5,c1rec.display_when_equals)) or
     (c1rec.display_when_repeated is not null and c1rec.display_when_repeated = 'ATTRIBUTE6' and matches(c2rec.attribute6,c1rec.display_when_equals)) or
     (c1rec.display_when_repeated is null and matches( c2rec.umo_type,c1rec.display_when_value)) or
     (c1rec.display_when_value is NULL and c1rec.display_when_repeated is null)
   then
    ctr := ctr + 1;
    p_code( ctr ) := c1rec.user_fee_code;
    p_category( ctr ) := c1rec.user_fee_text;
    p_default( ctr ) := c1rec.is_default;
    if c1rec.lineitem_spb is null
     then
      p_newprice( ctr ) := user_fee_adjust_price( c1rec, shoprec.original_photo_cost );
     else
      -- extract default photo cost for the other price book
      p_newprice( ctr ) := user_fee_adjust_price( c1rec, nvl(default_price(c1rec.lineitem_spb, shoprec.film_type, vppi, pvsize),shoprec.original_photo_cost) );
    end if;

   else
    -- Does not match list so do not add it
    null;
  end if;

 end loop;
exception when others then
 glbx.error_details( 'FNAME', 'USER_FEE_CATEGORIES', errmsg=>sqlerrm);
end user_fee_categories;

procedure user_fee_adjust_default( ltype in varchar2, profid in integer, cusrec in customer_account%ROWTYPE, voidrec in order_style%ROWTYPE, purchord in purchase_order%ROWTYPE, shoprec in shopping_basket%ROWTYPE, p_code in GLBX.MYARRAY, p_default in out NOCOPY GLBX.MYARRAY)
as

 cursor c1( ltype varchar2, profid integer, acid integer, phgid integer ) is
  select user_fee_code
  from customer_contact
  where (ltype = 'PROFILE' and aid = profid ) or
        (ltype = 'OWNER' and aid = acid) or
        (ltype = 'PHOTOGRAPHER' and aid = phgid );

 cursor c2( vpoid integer ) is select user_fee_code from shopping_basket where poid = vpoid order by shopping_id desc;

 c1rec		c1%ROWTYPE;
 found_default	boolean;

begin
 if p_default.count = 0 then return; end if;

 -- Adjust defaults if already chosen
 if shoprec.user_fee_code is not null
  then
   for j in p_default.first..p_default.last loop
    if p_code(j) = shoprec.user_fee_code
     then
      p_default(j) := 'T';
     else
      p_default(j) := 'F';
    end if;
   end loop;
   return;
 end if;

 found_default := FALSE;

 -- Default to last shopping basket item value chosen
 if voidrec.uf_bl_onnew_def_last = 'T'
  then
   for c2rec in c2( purchord.poid ) loop
    if c2rec.user_fee_code is not null
     then
     found_default := TRUE;
     for j in p_default.first..p_default.last loop
      if p_default(j) = c2rec.user_fee_code
       then
        p_default(j) := 'T';
       else
        p_default(j) := 'F';
      end if;
     end loop;
    end if;
   end loop;
 end if;

 -- Default to last session chosen
 if voidrec.uf_bl_remember_over_session = 'T' and not found_default
  then
   open c1( ltype, profid, cusrec.aid, cusrec.pid );
   fetch c1 into c1rec;
   close c1;
   if c1rec.user_fee_code is not null
    then
     found_default := TRUE;
     for j in p_default.first..p_default.last loop
      if p_default(j) = c1rec.user_fee_code
       then
        p_default(j) := 'T';
       else
        p_default(j) := 'F';
      end if;
     end loop;
   end if;
 end if;

 if voidrec.uf_bl_enable_default = 'T' and not found_default
  then
   null;
 elsif found_default
  then
   null;
 else
  -- Turn of all defaults. There is no default.
   for j in p_default.first..p_default.last loop
    p_default(j) := 'F';
   end loop;
 end if;

end user_fee_adjust_default;

procedure userfee_screen( surl varchar2, msg in varchar2 default null, acid in integer default null, footer_api in varchar2 default null, left_api in varchar2 default null, left_api_parm in varchar2 default null,
                          sess_id in integer, ltype in varchar2, stype in integer, profid in integer, voidrec in ORDER_STYLE%ROWTYPE, pfx in THEME%ROWTYPE, purchord in PURCHASE_ORDER%ROWTYPE, theme_rec in THEME_TYPES%ROWTYPE, cusrec CUSTOMER_ACCOUNT%ROWTYPE, changeitems in boolean default FALSE)
as

 cursor c1(vpoid integer, ufcode char) is
  select *
  from shopping_basket
  where poid = vpoid and
        ((user_fee_code is null and ufcode = 'F') or (ufcode = 'T'))
  order by shopping_id;

 foundrec	boolean;
 ufcode		char(1);
 txt		varchar2(100);
 retlink	varchar2(1000);
 ctr		integer;
 tmp		varchar2(4000);
 p_code 	GLBX.MYARRAY;
 p_category 	GLBX.MYARRAY;
 p_default 	GLBX.MYARRAY;
 p_newprice 	GLBX.MYARRAY_NMB;


 procedure dispimg( c1rec in c1%ROWTYPE )
 as

  cursor c2( v_umo integer ) is
   select umo_type, version, aid, um.photo_thumbnail.width width,um.photo_thumbnail.height height, image_caption
   from umo um
   where umo_id = v_umo;

  c2rec		c2%ROWTYPE;
  dsp		varchar2(1000);
  url		varchar2(1000);

 begin
   open c2(c1rec.phid);
   fetch c2 into c2rec;
   if c2%NOTFOUND then close c2; htp.bold( nvl(c1rec.film_name,c1rec.photo_size) ); return; end if;
   close c2;
   if c2rec.umo_type <> 'PHOTO' then htp.bold( nvl(c1rec.film_name,c1rec.photo_size) ); return; end if;
   url := 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.phid || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ltype;
   if voidrec.uf_display_matte = 'T'
    then
     glbx.image_matte(pfx,c2rec.width,c2rec.height,
                     url,
                     '<IMG BORDER=0 WIDTH=' || c2rec.width || ' HEIGHT=' || c2rec.height || ' SRC="' ||
                     'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.phid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c2rec.version || '&parm1=AID&parm2=' || c2rec.aid ||
                     '" ALT="' || c1rec.film_name || '" STYLE="display:block;">',null );
    else
     dsp := 'WIDTH=' || c2rec.width || ' HEIGHT=' || c2rec.height;
     htp.anchor(url, '<IMG BORDER=0 ' || dsp || ' SRC="' ||
                'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.phid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || c2rec.aid ||
                '" ALT="' || c1rec.film_name || '" STYLE="display:block;">');
   end if;
   if voidrec.uf_display_image_name = 'T'
    then
     htp.bold( c1rec.film_name );
   end if;
   if voidrec.uf_display_additional_img = 'T' and c2rec.image_caption is not null
    then
     if voidrec.uf_display_image_name = 'T' then htp.nl; end if;
     htp.p( c2rec.image_caption );
   end if;
 end dispimg;

 procedure disp_uf( c1rec in c1%ROWTYPE, ctr in integer, foundrec in out boolean )
 as

 begin

  if voidrec.uf_instruction_text is not null
   then
    htp.bold( voidrec.uf_instruction_text );
    htp.nl;
  end if;

  htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
   for j in p_code.first..p_code.last loop
    htp.tablerowopen;
    foundrec := TRUE;
    if p_default(j) = 'T'
     then
      htp.tabledata( htf.formradio( 'PA' || to_char(ctr), p_code(j), 'CHECKED' ), cattributes=>'VALIGN="CENTER" ALIGN="CENTER"' );
     else
      htp.tabledata( htf.formradio( 'PA' || to_char(ctr), p_code(j) ), cattributes=>'VALIGN="CENTER" ALIGN="CENTER"' );
    end if;
    htp.tabledata( htf.formhidden( 'PB' || to_char(ctr), c1rec.shopping_id) || p_category(j), cattributes=>'VALIGN="CENTER" ALIGN="LEFT"' );
    if voidrec.uf_display_price = 'T'
     then
      htp.tabledata( to_char(p_newprice(j), LNG.MONEY_FORMAT), cattributes=>'VALIGN="CENTER" ALIGN="RIGHT"' );
    end if;
    htp.tablerowclose;
   end loop;
  htp.tableclose;

 end disp_uf;

begin

 retlink := return_link( surl, stype, ltype, voidrec, pfx, acid, footer_api, left_api, left_api_parm, '1' );
 if voidrec.disp_purch_request_heading = 'T'
  then
   txt := voidrec.text_page0 || ' [' || purchord.poid || ']';
  else
   txt := voidrec.text_page0;
 end if;
 glbx.main_title( surl, txt, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'O26',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);

 htp.p( '<CENTER>' );

 if voidrec.uf_display_progress_bar = 'T'
  then
   disp_tracing_style(surl, stype, voidrec, pfx, purchord, 'USER_FEES', acid, ltype, theme_rec );
 end if;
 if voidrec.uf_text_header is not null then htp.bold( voidrec.uf_text_header ); htp.nl; end if;

 if msg is not null
  then
   glbx.header_msg( msg );
 end if;

 htp.formopen( '!fname.accept_userfee_screen' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'LEFT_API', left_api );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 ctr := 0;
 if changeitems then ufcode := 'T'; else ufcode := 'F'; end if;
 foundrec := FALSE;
 htp.tableopen( cattributes=>pfx.ord_uf_table );
 for c1rec in c1( purchord.poid, ufcode ) loop
  -- Left Cell
  ctr := ctr + 1;
  --foundrec := TRUE;
  /*
   if ctr = 21
    then
     htp.tabledata( 'Can only process 20 images at one time.', cattributes=>'COLSPAN="3"');
     exit;
   end if;
  */

   p_code.delete;
   p_category.delete;
   p_default.delete;
   p_newprice.delete;
   user_fee_categories( shoprec=>c1rec, voidrec=>voidrec, p_code=>p_code, p_category=>p_category, p_default=>p_default, p_newprice=>p_newprice );
   user_fee_adjust_default( ltype=>ltype, profid=>profid, cusrec=>cusrec, voidrec=>voidrec, purchord=>purchord, shoprec=>c1rec, p_code=>p_code, p_default=>p_default);

   if p_code.count > 0
    then
     htp.tablerowopen;
     htp.p( '<TD ' || pfx.ord_uf_left || '>' );
      if voidrec.uf_image_position = 'L'
       then
        dispimg( c1rec );
       else
        disp_uf( c1rec, ctr, foundrec );
      end if;
     htp.p( '</TD>' );

     htp.p( '<TD ' || pfx.ord_uf_right || '>' );
      if voidrec.uf_image_position = 'L'
       then
        disp_uf( c1rec, ctr, foundrec );
       else
        dispimg( c1rec );
      end if;
     htp.p( '</TD>' );
    htp.tablerowclose;
   end if;

  htp.tablerowopen;
   htp.tabledata( htf.line, cattributes=>'COLSPAN="3"');
  htp.tablerowclose;
 end loop;

 -- No Images Found. Return to Main Basket
 if not foundrec
  then
    acct_orders(surl, 'BYPASS', acid ); -- If there are no options that can be configured, then no user fee set. Continue as per normal.
    return;
 end if;

  -- continue and return gif
 if voidrec.uf_image_position = 'L'
  then
   htp.tablerowopen;
   htp.tabledata( '&nbsp;' );
   htp.p( '<TD>' );
  else
   htp.tablerowopen;
   htp.p( '<TD>' );
 end if;

 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
 htp.tablerowopen;
 if voidrec.uf_show_return_gif = 'T'
  then
   htp.tabledata( htf.formimage( 'Return_Back', DECS.IMAGE_LOCATION || 'adminc/order_returnback.gif',cattributes=>'BORDER="0"'));
 elsif voidrec.uf_show_return_gif = 'F' and voidrec.uf_return_text is not null
  then
   htp.tabledata( htf.formsubmit( 'ACTION', voidrec.uf_return_text ));
 end if;
 if voidrec.uf_show_continue_gif = 'T'
  then
   htp.tabledata( htf.formimage( 'Continue', DECS.IMAGE_LOCATION || 'adminc/order_continue.gif',cattributes=>'BORDER="0"'));
 elsif voidrec.uf_show_continue_gif = 'F' and voidrec.uf_continue_text is not null
  then
   htp.tabledata( htf.formsubmit( 'ACTION', voidrec.uf_continue_text ));
 end if;
 htp.tablerowclose;
 htp.tableclose;

 if voidrec.uf_image_position = 'L'
  then
   htp.p( '</TD>' );
   htp.tablerowclose;
  else
   htp.p( '</TD>' );
   htp.tabledata( '&nbsp;' );
   htp.tablerowclose;
 end if;

 htp.tableclose;

 htp.formclose;

 if pfx.ord_inc_simple = 'T'
  then
    cst.disp_standard_search(surl, stype, ltype, profid, acid, cusrec, pfx, theme_rec, 'SIMPLE' );
    if pfx.ord_inc_privacy = 'T' then htp.nl; end if;
 end if;

 if pfx.ord_inc_privacy = 'T'
  then
    cst.disp_privacy(surl, ltype, profid, acid, cusrec, pfx, theme_rec );
 end if;

 if pfx.order_bottom_external is not null
  then
    execute immediate
      'begin ' || pfx.order_bottom_external ||
       '(surl=>:surl,ltype=>:ltype,acid=>:acid,screen_location=>:screen_location);' ||
       'end;'
     using glbx.rndsurl(surl),ltype,acid,'SHOPPING_BASKET';
 end if;

 htp.p( '</CENTER>' );
 glbx.close_page( pfx );
exception when others then
 glbx.error_details( 'FNAME', 'USERFEE_SCREEN', errmsg=>sqlerrm);
end userfee_screen;

function user_fee_adjust_price( c1rec in user_fees%ROWTYPE, current_price in number )
 return number
as
 new_price	number;
begin
  if c1rec.price_adjuster is null then return( current_price ); end if;
  if c1rec.price_adjuster = 'M'
   then
    new_price := current_price * nvl( c1rec.price_adjuster_value, 1 );
   elsif c1rec.price_adjuster = 'F'
    then
     new_price := nvl( c1rec.price_adjuster_value, 0 );
   elsif c1rec.price_adjuster = 'A'
    then
     new_price := current_price + nvl( c1rec.price_adjuster_value, 0 );
     -- Price can not be less than $0
     new_price := greatest(new_price,0);
   elsif c1rec.price_adjuster = 'I'
    then
     new_price := nvl( c1rec.price_adjuster_value, 0 );
  end if;
  return( new_price );
exception
 when others then return( current_price );
end user_fee_adjust_price;

/*
procedure accept_userfee_screen( surl varchar2, acid in integer, footer_api in varchar2, left_api in varchar2, left_api_parm in varchar2,
                                 pa1 in varchar2 default null, pa2 in varchar2 default null, pa3 in varchar2 default null, pa4 in varchar2 default null, pa5 in varchar2 default null, pa6 in varchar2 default null, pa7 in varchar2 default null, pa8 in varchar2 default null, pa9 in varchar2 default null, pa10 in varchar2 default null,
                                 pb1 in varchar2 default null, pb2 in varchar2 default null, pb3 in varchar2 default null, pb4 in varchar2 default null, pb5 in varchar2 default null, pb6 in varchar2 default null, pb7 in varchar2 default null, pb8 in varchar2 default null, pb9 in varchar2 default null, pb10 in varchar2 default null,
                                 pa11 in varchar2 default null, pa12 in varchar2 default null, pa13 in varchar2 default null, pa14 in varchar2 default null, pa15 in varchar2 default null, pa16 in varchar2 default null, pa17 in varchar2 default null, pa18 in varchar2 default null, pa19 in varchar2 default null, pa20 in varchar2 default null,
                                 pb11 in varchar2 default null, pb12 in varchar2 default null, pb13 in varchar2 default null, pb14 in varchar2 default null, pb15 in varchar2 default null, pb16 in varchar2 default null, pb17 in varchar2 default null, pb18 in varchar2 default null, pb19 in varchar2 default null, pb20 in varchar2 default null,
                                 return_back in varchar2 default null, continue in varchar2 default null, action in varchar2 default null)
*/
procedure accept_userfee_screen( num_entries in number, name_array in owa.vc_arr, value_array in owa.vc_arr, reserved in owa.vc_arr )
as

 cursor c1( vspb integer, vcode varchar2 ) is select * from user_fees where spb = vspb and user_fee_code = vcode;
 cursor c2( shopid integer ) is select * from shopping_basket where shopping_id = shopid;

 surl		varchar2(100);
 acid		integer;
 footer_api	varchar2(1000);
 left_api	varchar2(1000);
 left_api_parm	varchar2(1000);
 return_back	varchar2(1000);
 continue	varchar2(1000);
 action		varchar2(1000);

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pa		GLBX.MYARRAY;
 pb		GLBX.MYARRAY;
 cusrec		customer_account%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 pfx		theme%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 new_price	number;
 vppi		integer;
 sts		varchar2(100);
 pvsize		varchar2(4000);
 err		boolean;
 dmy		varchar2(100);
 lastcode	varchar2(40);
 errmsg		varchar2(4000);

begin
 for j in name_array.first..name_array.last loop
  if     upper(name_array(j)) = 'SURL' then surl := value_array(j);
  elsif  upper(name_array(j)) = 'ACID' then acid := value_array(j);
  elsif  upper(name_array(j)) = 'FOOTER_API' then footer_api := value_array(j);
  elsif  upper(name_array(j)) = 'LEFT_API' then left_api := value_array(j);
  elsif  upper(name_array(j)) = 'LEFT_API_PARM' then left_api_parm := value_array(j);
  elsif  upper(name_array(j)) = 'RETURN_BACK' then return_back := value_array(j);
  elsif  upper(name_array(j)) = 'CONTINUE' then continue := value_array(j);
  elsif  upper(name_array(j)) = 'ACTION' then action := value_array(j);
  elsif  upper(name_array(j)) like 'PA%'
   then
    pa(to_number(substr(name_array(j),3))) := value_array(j);
  elsif  upper(name_array(j)) like 'PB%'
   then
    pb(to_number(substr(name_array(j),3))) := value_array(j);
  end if;
 end loop;

 -- Check if a value was chosen and update shopping basket
 if pa.count = 0
  then
   errmsg := 'User Fee Option not chosen.';
   userfee_screen(surl, acid=>acid, profid=>profid, ltype=>ltype, stype=>stype, sess_id=>sess_id, footer_api=>footer_api,left_api_parm=>left_api_parm, voidrec=>voidrec, pfx=>pfx, purchord=>purchord, theme_rec=>theme_rec, cusrec=>cusrec, msg=>errmsg);
   return;
 end if;
 for j in pa.first..pa.last loop
  if not pa.exists(j) then pa(j) := null; end if;
  if not pb.exists(j) then pb(j) := null; end if;
 end loop;

 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.ACCEPT_USERFEE_SCREEN' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
 -- Business Feature overriden, get the other one
 if voidrec.bftr <> 'Use Customer Account Business Feature'
  then
   theme_rec := glbx.get_theme_types( voidrec.bftr );
 end if;

 if voidrec.laf <> 'Use Customer Account Look and Feel'
  then
   pfx := glbx.get_thm( voidrec.laf );
 end if;

 err := FALSE;

 if (return_back is not null) or
    (action is not null and action = voidrec.uf_return_text)
  then
   if footer_api is not null
    then
     owa_util.redirect_url( 'http://' || owa_util.get_cgi_env( 'SERVER_NAME' ) || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' ||
                             footer_api || '?surl=' || surl || '&acid=' || acid || '&left_api_parm=' || replace(left_api_parm,' ','+') );
    else
     cst.acct_bottom( surl=>surl, stype=>stype );
   end if;
   return;
 end if;

 for j in pa.first..pa.last loop
  if pb(j) is not null
   then
    if pa(j) is null
     then
      err := TRUE;
      errmsg := voidrec.uf_error_no_default;
     else
      c1rec.spb := NULL;
      open c1(voidrec.spb,pa(j));
      fetch c1 into c1rec;
      close c1;
      if c1rec.spb is null
       then
        err := TRUE;
        errmsg := errmsg || htf.nl || 'Unable to Determine User Fee Charge for this Item';
       else

        open c2(to_number(pb(j)));
        fetch c2 into c2rec;
        close c2;
        vppi := NULL;
        pvsize := NULL;
        if c1rec.lineitem_spb is null
         then
          new_price := user_fee_adjust_price( c1rec, c2rec.original_photo_cost );
         else
          -- Update price looking at new price book
          new_price := user_fee_adjust_price( c1rec, nvl(default_price(c1rec.lineitem_spb, c2rec.film_type, vppi, pvsize),c2rec.original_photo_cost) );
        end if;
        update shopping_basket
         set
          photo_cost = new_price,
          ppi = nvl(vppi,ppi),
          photo_size = nvl(pvsize,photo_size),
          user_fee_code = pa(j),
          lineitem_spb = c1rec.lineitem_spb
         where
          shopping_id = to_number(pb(j)) and
          poid = purchord.poid;

        lastcode := pa(j);

      end if;
    end if;
  end if;
 end loop;

 if voidrec.uf_bl_remember_over_session = 'T'
  then
   update customer_contact
    set
     user_fee_code = nvl(lastcode,user_fee_code)
   where (ltype = 'PROFILE' and aid = profid ) or
         (ltype = 'OWNER' and aid = cusrec.aid) or
         (ltype = 'PHOTOGRAPHER' and aid = cusrec.pid );
 end if;

 commit;

 if err
  then
    userfee_screen(surl, acid=>acid, profid=>profid, ltype=>ltype, stype=>stype, sess_id=>sess_id, footer_api=>footer_api,left_api_parm=>left_api_parm, voidrec=>voidrec, pfx=>pfx, purchord=>purchord, theme_rec=>theme_rec, cusrec=>cusrec, msg=>errmsg);
  else
   acct_orders( surl=>surl, msg=>NULL, acid=>acid, footer_api=>footer_api, left_api=>left_api, left_api_parm=>left_api_parm );
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'ACCEPT_USERFEE_SCREEN', errmsg=>sqlerrm);
end accept_userfee_screen;

function default_price( vspb in integer, ftype in varchar2, vppi out integer, pvsize out varchar2 )
 return number
as
 cursor c1(vspb integer, ftype varchar2) is
  select charge, ppi, name
  from phg_price_item
  where spb = vspb and
        enabled = 'T' and
        (nvl(upper(film_type),LNG.ORD_TXT_194) = LNG.ORD_TXT_194 or film_type = ftype)
  order by decode(is_default,'T',0,1),ppi;
 c1rec  c1%ROWTYPE;
begin
 vppi := NULL;
 pvsize := NULL;
 open c1(vspb,ftype);
 fetch c1 into c1rec;
 if c1%NOTFOUND then close c1; return( null ); end if;
 close c1;
 vppi := c1rec.ppi;
 pvsize := c1rec.name;
 return( c1rec.charge );
end default_price;

procedure add_opt_combo( slc in varchar2, display_text in varchar2, display_prices in varchar2, opt in varchar2 default null, adj_price in number default 1 )
as
 arr1	GLBX.MYARRAY;
 arr2	GLBX.MYARRAY;
 nmb	number;
begin
 arr1 := glbx.extract_umos( display_text );
 arr2 := glbx.extract_umos( display_prices );
 if slc is null
  then
   if arr1.count = 0 then return; end if;
   for j in arr1.first..arr1.last loop
    begin
     nmb := glbx.conv_nmb( arr2(j), 'MONEY' );
     htp.p( trim(arr1(j)) || ' ' || to_char((nmb*adj_price),LNG.MONEY_FORMAT) ); htp.nl;
    exception
     when others
      then
       htp.p( 'Invalid Price: ' || trim(arr1(j)) );
    end;
   end loop;
  else
 htp.formselectopen( slc );
 if arr1.count = 0 then htp.formselectoption( NULL ); return; end if;
 for j in arr1.first..arr1.last loop
  begin
   nmb := glbx.conv_nmb( arr2(j), 'MONEY' );
   if trim(arr1(j)) = opt
    then
     htp.formselectoption( trim(arr1(j)) || ' ' || to_char((nmb*adj_price),LNG.MONEY_FORMAT), 'SELECTED', cattributes=>'VALUE="[' || trim(arr1(j)) || ']' || to_char(round(nmb*adj_price,2)) || '"' );
    else
     htp.formselectoption( trim(arr1(j)) || ' ' || to_char((nmb*adj_price),LNG.MONEY_FORMAT), cattributes=>'VALUE="[' || trim(arr1(j)) || ']'  || to_char(round(nmb*adj_price,2)) || '"' );
   end if;
  exception
   when others
    then
     nmb := 0;
     htp.formselectoption( trim(arr1(j)) || ' ' || 'Invalid Price', cattributes=>'VALUE="' || to_char(nmb) || '"' );
  end;
 end loop;
 htp.formselectclose;
 end if;
end add_opt_combo;

procedure remove_item(surl in varchar2, shpid in varchar2, acid in integer )
as

 cusrec		CUSTOMER_ACCOUNT%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	THEME_TYPES%ROWTYPE;
 purchord 	PURCHASE_ORDER%ROWTYPE;
 voidrec	ORDER_STYLE%ROWTYPE;
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 ltype		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'FNAME.REMOVE_ITEM' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 if cleanup_package( purchord.poid, shpid ) then null; end if;
 purchase_audit_trail( surl, purchord.poid, 'DELETE FROM BASKET', 'D', 'C', shpid, purchord, voidrec );

 fname.acct_orders( surl, null, acid );

exception when others then
 glbx.error_details( 'FNAME', 'REMOVE_ITEM',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end remove_item;

function package_min(surl in varchar2, stype in integer, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%rowtype, pfx in theme%rowtype, theme_rec in theme_types%rowtype, purchord in purchase_order%rowtype, voidrec in order_style%rowtype )
 return boolean
as

 cursor c1( vpoid integer, vshopid integer ) is select * from purchase_package_product where poid = vpoid and shopping_id= vshopid;
 cursor c2( vpoid integer ) is select * from shopping_basket where poid = vpoid and isgallery = 'P';

 c1rec	c1%ROWTYPE;
 ctr	integer;

begin
 for c2rec in c2( purchord.poid ) loop
  -- If a package exists, but there are no products yet defined for it, then we need to add some.
  open c1(c2rec.poid, c2rec.shopping_id);
  fetch c1 into c1rec;
  if c1%NOTFOUND then close c1; return( TRUE ); end if;
  close c1;
  ctr := 0;
  if c1rec.umo_id_1 is not null then ctr := ctr + 1; end if;
  if c1rec.umo_id_2 is not null then ctr := ctr + 1; end if;
  if c1rec.umo_id_3 is not null then ctr := ctr + 1; end if;
  if c1rec.umo_id_4 is not null then ctr := ctr + 1; end if;
  if c1rec.umo_id_5 is not null then ctr := ctr + 1; end if;
  if c1rec.umo_id_6 is not null then ctr := ctr + 1; end if;
  if c1rec.umo_id_7 is not null then ctr := ctr + 1; end if;
  if c1rec.umo_id_8 is not null then ctr := ctr + 1; end if;
  if c1rec.umo_id_9 is not null then ctr := ctr + 1; end if;
  if c1rec.umo_id_10 is not null then ctr := ctr + 1; end if;
  if ctr < nvl(c1rec.number_of_images,1) then return( TRUE ); end if;
 end loop;
 return( FALSE );
exception when others then
 glbx.error_details( 'FNAME', 'PACKAGE_MIN',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
 return( FALSE );
end package_min;

function cleanup_package( vpoid integer, vshopid integer )
 return boolean
as
begin
  update shopping_basket set packaged_product_id = null, photo_cost = original_photo_cost where poid = vpoid and packaged_product_id = vshopid;
  update purchase_package_product set umo_id_1 = null where poid = vpoid and umo_id_1 = vshopid;
  update purchase_package_product set umo_id_2 = null where poid = vpoid and umo_id_2 = vshopid;
  update purchase_package_product set umo_id_3 = null where poid = vpoid and umo_id_3 = vshopid;
  update purchase_package_product set umo_id_4 = null where poid = vpoid and umo_id_4 = vshopid;
  update purchase_package_product set umo_id_5 = null where poid = vpoid and umo_id_5 = vshopid;
  update purchase_package_product set umo_id_6 = null where poid = vpoid and umo_id_6 = vshopid;
  update purchase_package_product set umo_id_7 = null where poid = vpoid and umo_id_7 = vshopid;
  update purchase_package_product set umo_id_8 = null where poid = vpoid and umo_id_8 = vshopid;
  update purchase_package_product set umo_id_9 = null where poid = vpoid and umo_id_9 = vshopid;
  update purchase_package_product set umo_id_10 = null where poid = vpoid and umo_id_10 = vshopid;
  delete from purchase_package_product where poid = vpoid and shopping_id = vshopid;
  delete from umo where sessid is not null and umo_id in (select phid from shopping_basket where poid = vpoid and isgallery in ('F') and phid is not null and shopping_id = vshopid );
  delete from shopping_basket where poid = vpoid and shopping_id = vshopid;
  return( TRUE );
exception
 when others then return( FALSE );
end cleanup_package;

procedure check_package_add(surl in varchar2, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE )
as

 cursor c1(vpoid integer) is select * from shopping_basket where poid = vpoid and isgallery = 'P' order by shopping_id;
 cursor c2(vpoid integer) is select * from purchase_package_product where poid = vpoid;
 cursor c3( vspb integer, vppi integer ) is select * from item_package_product where spb = vspb and ppi = vppi;
 cursor c4(vpoid integer) is select * from shopping_basket where poid = vpoid and isgallery <> 'P' and packaged_product_id is null order by shopping_id desc;
 cursor c5( vppi integer ) is select spb,ppi from phg_price_item where ppi = vppi;

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ctr		integer;

begin

 for c1rec in c1(purch.poid) loop
  -- get image number
  -- keep adding until the minimum is reached
   open c5(c1rec.ppi);
   fetch c5 into c5rec;
   close c5;
   open c3( c5rec.spb, c5rec.ppi );
   fetch c3 into c3rec;
   close c3;
   open c2(purch.poid);
   fetch c2 into c2rec;
   if c2%NOTFOUND
    then
     close c2;
     insert into purchase_package_product(spb,ppi,poid,shopping_id,number_of_images) values
       (c5rec.spb,c5rec.ppi,purch.poid,c1rec.shopping_id,nvl(c3rec.min_number,1));
     open c2(purch.poid);
     fetch c2 into c2rec;
   end if;
   close c2;
   ctr := 0;
   if c2rec.umo_id_1 is not null then ctr := ctr + 1; end if;
   if c2rec.umo_id_2 is not null then ctr := ctr + 1; end if;
   if c2rec.umo_id_3 is not null then ctr := ctr + 1; end if;
   if c2rec.umo_id_4 is not null then ctr := ctr + 1; end if;
   if c2rec.umo_id_5 is not null then ctr := ctr + 1; end if;
   if c2rec.umo_id_6 is not null then ctr := ctr + 1; end if;
   if c2rec.umo_id_7 is not null then ctr := ctr + 1; end if;
   if c2rec.umo_id_8 is not null then ctr := ctr + 1; end if;
   if c2rec.umo_id_9 is not null then ctr := ctr + 1; end if;
   if c2rec.umo_id_10 is not null then ctr := ctr + 1; end if;
   loop
    -- glbx.dbg( 'XX:' || ctr || '-' || nvl(c2rec.number_of_images,1) );
    if ctr < nvl(c2rec.number_of_images,1)
     then
      open c4(purch.poid);
      fetch c4 into c4rec;
      if c4%NOTFOUND then close c4; return; end if; -- No more shopping basket items to add
      close c4;
     else
      exit;
    end if;

    update shopping_basket
     set
      packaged_product_id = c1rec.shopping_id,
      original_photo_cost = photo_cost
    where poid = purch.poid and
          shopping_id = c4rec.shopping_id;

    if c3rec.images_included_in_price = 'T'
     then
      update shopping_basket
       set
        original_photo_cost = 0
      where poid = purch.poid and
            shopping_id = c4rec.shopping_id;
    end if;

    if c2rec.umo_id_1 is null then update purchase_package_product set umo_id_1 = c4rec.shopping_id where shopping_id = c1rec.shopping_id and poid = purch.poid;
    elsif c2rec.umo_id_2 is null then update purchase_package_product set umo_id_2 = c4rec.shopping_id where shopping_id = c1rec.shopping_id and poid = purch.poid;
    elsif c2rec.umo_id_3 is null then update purchase_package_product set umo_id_3 = c4rec.shopping_id where shopping_id = c1rec.shopping_id and poid = purch.poid;
    elsif c2rec.umo_id_4 is null then update purchase_package_product set umo_id_4 = c4rec.shopping_id where shopping_id = c1rec.shopping_id and poid = purch.poid;
    elsif c2rec.umo_id_5 is null then update purchase_package_product set umo_id_5 = c4rec.shopping_id where shopping_id = c1rec.shopping_id and poid = purch.poid;
    elsif c2rec.umo_id_6 is null then update purchase_package_product set umo_id_6 = c4rec.shopping_id where shopping_id = c1rec.shopping_id and poid = purch.poid;
    elsif c2rec.umo_id_7 is null then update purchase_package_product set umo_id_7 = c4rec.shopping_id where shopping_id = c1rec.shopping_id and poid = purch.poid;
    elsif c2rec.umo_id_8 is null then update purchase_package_product set umo_id_8 = c4rec.shopping_id where shopping_id = c1rec.shopping_id and poid = purch.poid;
    elsif c2rec.umo_id_9 is null then update purchase_package_product set umo_id_9 = c4rec.shopping_id where shopping_id = c1rec.shopping_id and poid = purch.poid;
    elsif c2rec.umo_id_10 is null then update purchase_package_product set umo_id_10 = c4rec.shopping_id where shopping_id = c1rec.shopping_id and poid = purch.poid;
    end if;
    ctr := ctr + 1;

   end loop;

 end loop;

exception when others then
 glbx.error_details( 'FNAME', 'CHECK_PACKAGE_ADD',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end check_package_add;

procedure check_package_justadded(surl in varchar2, sess_id in integer, ltype in varchar2, acid in integer, profid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purch in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, exit_call out integer, pkg out integer )
as

 cursor c1(vpoid integer) is select * from shopping_basket where poid = vpoid and isgallery = 'P' order by shopping_id;
 cursor c3( vspb integer, vppi integer ) is select * from item_package_product where spb = vspb and ppi = vppi;
 cursor c5( vppi integer ) is select * from phg_price_item where ppi = vppi;
 cursor c6(vspb integer) is select * from phg_price_book where spb = vspb;
 cursor c7(vpoid integer, vshopid integer) is select * from shopping_basket where poid = vpoid and shopping_id > vshopid and packaged_product_id is null;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;

begin

 open c6(voidrec.spb);
 fetch c6 into c6rec;
 close c6;
 -- This option is only available for call #2 xxx (maybe other call values can be added here)
 if c6rec.call_location not in ('2')
  then
   exit_call := 0;
   return;
 end if;
 pkg := NULL;
 -- If calltype is 2, and isgallery = Q, then the product is confirmed
 open c1(purch.poid);
 fetch c1 into c1rec;
 if c1%FOUND
  then
   exit_call := 2;
   pkg := c1rec.shopping_id;
   open c5(c1rec.ppi);
   fetch c5 into c5rec;
   close c5;
   open c3( c5rec.spb, c5rec.ppi );
   fetch c3 into c3rec;
   close c3;
   for c7rec in c7(c1rec.poid,c1rec.shopping_id) loop
    if cst.attach_package_item( pkg, purch, c3rec, c5rec, c7rec ) then null; end if;
   end loop;
   close c1;
  else
   exit_call := 1;
   close c1;
 end if;

exception when others then
 glbx.error_details( 'FNAME', 'CHECK_PACKAGE_JUSTADDED',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end check_package_justadded;

procedure adjust_postage( vpurchrec in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, subtotal in number )
as

 cursor c3(vpoid integer) is
  select count('x') cnt
  from shopping_basket sb
  where sb.ppm_id is null and
        sb.poid = vpoid;

 cursor c3a(vpoid integer) is
  select count('x') cnt
  from shopping_basket sb, phg_price_object_defn ppd
  where sb.ppm_id = ppd.ppm_id and
        ppd.multiple_type in ('T','A') and
        sb.poid = vpoid;

 c3rec		c3%ROWTYPE;
 c3arec		c3a%ROWTYPE;
 purchrec	purchase_order%ROWTYPE;

begin
    purchrec := vpurchrec;
    if voidrec.pricing_postage_included = 'T'
     then
      purchrec.delivery_cost := 0;
    elsif purchrec.delivery_type = 'S' and purchrec.local_internation = 'LOCAL'
     then
      purchrec.delivery_cost := nvl(voidrec.pricing_ship_local,0);
    elsif purchrec.delivery_type = 'S' and purchrec.local_internation = 'INTERNATIONAL'
     then
      purchrec.delivery_cost := nvl(voidrec.pricing_ship_int,0);
    elsif purchrec.delivery_type = 'X' and purchrec.local_internation = 'LOCAL'
     then
      purchrec.delivery_cost := nvl(voidrec.pricing_expr_local,0);
    elsif purchrec.delivery_type = 'X' and purchrec.local_internation = 'INTERNATIONAL'
     then
      purchrec.delivery_cost := nvl(voidrec.pricing_expr_int,0);
    else
      purchrec.delivery_cost := nvl(voidrec.pricing_ship_local,0);
    end if;

    -- If sub total is 0 (free images) and no postage if sub total is zero, then update delivery cost to be 0
    if voidrec.pricing_nopostage_if_zero = 'T' and nvl(subtotal,0) = 0
     then
      purchrec.delivery_cost := 0;
    end if;

    -- If all items in the price book are download (e.g. phg_price_item.lease_download_object is not null) then the delivery cost is 0
    -- First check if there are items for download phg_price_object_defn.multiple_type in ('T','A')
    open c3a(purchrec.poid);
    fetch c3a into c3arec;
    close c3a;
    if nvl(c3arec.cnt,0) > 0
     then
      -- Now check the count of number of items that are not downloadable
      open c3(purchrec.poid);
      fetch c3 into c3rec;
      close c3;
      if nvl(c3rec.cnt,0) = 0 then purchrec.delivery_cost := 0; end if;
    end if;

  update purchase_order
   set
    delivery_cost = decode(purchrec.manual_ship,'T',0,purchrec.delivery_cost),
    postage_without_manual = purchrec.delivery_cost
  where
   poid = purchrec.poid;

end adjust_postage;

end fname;

/
