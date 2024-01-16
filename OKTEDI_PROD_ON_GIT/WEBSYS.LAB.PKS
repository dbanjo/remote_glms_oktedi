CREATE OR REPLACE package WEBSYS.lab
as

procedure lab_master(surl in varchar2, stype in integer default 1);
procedure screen_sze(surl in varchar2);
procedure lab_header(surl in varchar2);
procedure home( surl in varchar2, msg in varchar2 default null);
procedure lab_product( surl in varchar2, prodid in integer default null, msg in varchar2 default null);
procedure plist(surl in varchar2, sortby in integer default 1, ptype in varchar2 default NULL, lmt in varchar2 default '0Z');
procedure edit_product(surl in varchar2, prodid in integer, msg in varchar2 default null, defpbook in varchar2 default null);
procedure accept_mfc_product(surl varchar2, prodid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p3b in integer, p3c in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2 default 'F', p7 in varchar2, p8 in varchar2, p9 in varchar2, p10 in varchar2, p11 in varchar2, p12 in varchar2, pdoco in varchar2, action in varchar2 );
procedure product_reports( surl in varchar2, msg in varchar2 default null);
procedure product_summary(surl in varchar2);
--procedure outstanding_accounts(surl in varchar2);
--procedure heavily_used_phg(surl in varchar2);
procedure reverse_engineer( surl in varchar2, p1 in varchar2, p2 in varchar2 default 'F' );
procedure manage_price_books(surl in varchar2, msg in varchar2 default null);
procedure del_pb(surl in varchar2, pt in varchar2);
procedure del_partial(surl in varchar2, pt in varchar2);
--procedure commission_report(surl in varchar2);
--procedure accept_commission_report(surl in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2);
--procedure accept_reconcile( surl in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, vfsid in GLBX.MYARRAY, psts in GLBX.MYARRAY );
procedure lab_clearance( surl varchar2, msg in varchar2 default null);
procedure lab_edit_clearance( surl varchar2, mcid in integer, msg in varchar2 default null);
procedure accept_edit_clearance(surl varchar2, mcid in integer, p1 in varchar2, p2a in varchar2, p2b in varchar2, p2c in varchar2, p3 in varchar2, pdoco in varchar2, action in varchar2, p4 in GLBX.MYARRAY, ph1 in GLBX.MYARRAY, ph2 in GLBX.MYARRAY, ph3 in GLBX.MYARRAY );
procedure attach(surl varchar2, p1 in varchar2 default 'F', p2 in varchar2 default '3');
procedure mfc_clr(surl varchar2, prodid in integer, msg in varchar2 default null);
procedure product_image(surl in varchar2, prodid in integer, file in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 default 'F');
--procedure notused_images( surl varchar2 );
procedure delete_images( surl varchar2, p1 in GLBX.MYARRAY );
procedure map_phg( surl in varchar2, msg in varchar2 default null );
procedure accept_map_phg( surl in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY  );
procedure view_tenders(surl varchar2, msg in varchar2 default null);
procedure modify_tender(surl varchar2, tid in varchar2, msg in varchar2 default null);
procedure accept_tender( surl in varchar2, tid in integer, action in varchar2, itid in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
procedure view_clearance_order(surl varchar2, mcid in integer, msg in varchar2 default null);
procedure pbutil(surl varchar2, p1 in varchar2, p2 in varchar2);
procedure pbutil_rename(surl varchar2, p1 in varchar2, p2 in varchar2);
procedure mng_brands(surl varchar2, msg in varchar2 default null );
procedure accept_mng_brands(surl varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY );
procedure stock_report(surl varchar2, prodid in integer, msg in varchar2 default null);
procedure attention_tasks(surl varchar2, sorton in integer default 1, msg in varchar2 default null, selectall in varchar2 default null, lvpoid in integer default null, byp in char default null, shoplist in glbx.myarray, sts in integer default null, ws in integer default null );
procedure attention_by_poid(surl in varchar2, vpoid in varchar2, shp in varchar2, msg in varchar2 default null );
procedure attention_by_status(surl in varchar2, sts in integer, ws in integer default null, msg in varchar2 default null );
procedure attention_accept(surl in varchar2, p1 in GLBX.MYARRAY, sts in integer default null, msg in varchar2 default null );
procedure accept_workflow_poid( surl in varchar2, vpoid in varchar2, shp in varchar2, p1 in varchar2, action in varchar2 );
procedure accept_workflow_sts( surl in varchar2, sts in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, action in varchar2 );
procedure manage_simple_requests(surl in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
procedure run_workflow( surl in varchar2, sbid in integer, answer in varchar2 default NULL );
procedure cashier(surl varchar2, msg in varchar2 default null);
procedure accept_cashier(surl varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY);
procedure accept_cashier_2(surl varchar2, action in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY);
procedure mng_booking(surl varchar2);
procedure show_poid( surl in varchar2, vpoid in integer, shp in integer );
procedure connectas(surl varchar2, msg in varchar2 default null );
procedure accept_connectas(surl varchar2, search_username in varchar2, search_bftr in varchar2, search_laf in varchar2, search_aname in varchar2, search_created in varchar2 );
procedure login_connectas(surl in varchar2, profid in integer );
procedure accept_receptionist(surl varchar2, p1 in varchar2);
procedure receptionist(surl varchar2, msg in varchar2 default null);
procedure lab_print( surl varchar2, msg in varchar2 default null);
procedure print_list(surl varchar2, msg in varchar2 default null );
procedure print_audit(surl varchar2, msg in varchar2 default null );
procedure print_details(surl varchar2, printid in integer, msg in varchar2 default null );
procedure accept_print_details(surl varchar2, printid in integer, p1 in varchar2, p2 in varchar2, b1 in GLBX.MYARRAY, b2 in GLBX.MYARRAY, b3 in GLBX.MYARRAY, b4 in GLBX.MYARRAY,
                               pt1 in varchar2, pt2 in varchar2, pt3 in varchar2, pt4 in varchar2, pr1 in GLBX.MYARRAY, pr2 in GLBX.MYARRAY,
                               r1 in varchar2, r2 in varchar2, r3 in varchar2, r4 in varchar2, r5 in varchar2, r6 in varchar2, c1 in char default 'F', c2 in char default 'F',
                               s1 in varchar2, s2 in varchar2, s3 in varchar2, s4 in varchar2, s5 in varchar2, s6 in varchar2,
                               w1 in varchar2, w2 in varchar2, w2a in varchar2, w3 in varchar2, w4 in varchar2, w5 in varchar2, w6 in varchar2, action in varchar2 );
function manual_printing_check( surl in varchar2, voidrec in order_style%ROWTYPE, purchord in purchase_order%ROWTYPE ) return boolean;
procedure manual_payment(surl varchar2, msg in varchar2 default null );
procedure accept_manual_payment(surl varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, action in varchar2 default null );
procedure manpay(surl varchar2, vpoid in integer, msg in varchar2 default null );
procedure accept_manpay(surl varchar2, vpoid in integer, p1 in varchar2, p2 in varchar2, p4 in varchar2, p5 in varchar2, action in varchar2, sb1 in GLBX.MYARRAY, sb2 in GLBX.MYARRAY );
procedure run_print( surl in varchar2, purchord in purchase_order%ROWTYPE, sbrec in shopping_basket%ROWTYPE, umorec in umo%ROWTYPE, lmi in integer, forcerun in boolean default FALSE );
procedure testwebservice(surl in varchar2, printid in integer );
procedure manrun_workflow(surl varchar2, shpid in integer, stsid in integer default null, aord in integer default null, msg in varchar2 default null );
procedure barcode( surl in varchar2, p1 in glbx.myarray, p2 in varchar2, msg in varchar2 default null );
procedure accept_barcode( surl in varchar2, p1 in glbx.myarray, p2 in varchar2, p3 in varchar2, action in varchar2 default 'Edit' );
function web_sql(webservice_pk in varchar2, encryption_key in varchar2, url in varchar2, typ in varchar2, stmt in varchar2 ) return varchar2;
procedure barcode_validate(surl in varchar2, wrkflow_codes in glbx.myarray, originating in varchar2, umo_array in glbx.myarray, c1rec in manufacturer%ROWTYPE, owner_id in integer, stype in integer, action in varchar2 );
procedure accept_barcode_arr( surl in varchar2, p1 in glbx.myarray, p2 in varchar2, retres in glbx.myarray, action in varchar2 default 'Edit' );

end lab;

/
