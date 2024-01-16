CREATE OR REPLACE package body WEBSYS.lab
as

IS_LAST_SHOPPING_ITEM	varchar2(20);
BARCODE_DELIMITER	char(1) := chr(13);

 TYPE barcode_type IS RECORD
  (
    shopping_id  	integer,
    umo_id	 	integer,
    poid		integer,
    manufacturer_id	integer,
    status_workflow	integer,
    date_created	date,
    ppi		        integer,
    status    	        varchar2(100),
    paid_method         varchar2(100),
    result		varchar2(100),
    sendto_firstname	varchar2(100),
    sendto_lastname	varchar2(100)
  );

 TYPE barcode_arr IS TABLE OF barcode_type INDEX BY BINARY_INTEGER;

function get_lab_id( surl varchar2, owner_id in integer) return manufacturer%ROWTYPE;
function calculate_meta_tag( c1rec in SHOPPING_BASKET%ROWTYPE, c2rec in WORKFLOW%ROWTYPE, c3rec in PURCHASE_ORDER%ROWTYPE, umo_rec in UMO%ROWTYPE ) return integer;
function retrieve_workflow_shopping( sbid in integer ) return shopping_basket%ROWTYPE;
function check_print( surl in varchar2, purchord in purchase_order%ROWTYPE, sbrec in shopping_basket%ROWTYPE, umorec in umo%ROWTYPE, lmi in integer ) return boolean;
function encrypt_data( input_string in varchar2, ky in varchar2 ) return varchar2;
function tcpcall( srv in varchar2, st in varchar2, refr in varchar2, txtin in varchar2 ) return varchar2;
function process_barcode( bf in varchar2, val in varchar2 ) return varchar2;
function parse_barcode( cd in varchar2, bf in varchar2 ) return glbx.myarray;

procedure perform_workflow_activity( surl in varchar2, vpoid in integer, sbid in integer, wsid in integer, actid in integer, phgid in integer, mfctr_id in integer, override_activity_order integer, stop_workflow out boolean, halt_workflow in out boolean, new_status_id out integer, new_status_workflow out integer, new_workflow_activity_id out integer );
procedure display_purchase_details( surl in varchar2, c1rec in SHOPPING_BASKET%ROWTYPE, c3rec in PURCHASE_ORDER%ROWTYPE, pfx in THEME%ROWTYPE, login_type in varchar2 );
procedure display_workflow_question( c4rec in WORKFLOW%ROWTYPE, pfx in THEME%ROWTYPE, rowonly in boolean, p1 in varchar2, mand in boolean, shrec in SHOPPING_BASKET%ROWTYPE );
procedure assign_invoice( vpoid in integer, current_priority in integer, assign_type in char );
procedure if_thread_delete( sbid in integer );
procedure call_run_print( surl in varchar2, purchord in purchase_order%ROWTYPE, sbrec in shopping_basket%ROWTYPE, umorec in umo%ROWTYPE, lmi in integer, forcerun in boolean default FALSE );
procedure callwebservice(surl in varchar2, printid in integer, v_env in varchar2, test_print in varchar2 );

procedure screen_sze(surl varchar2)
as

begin

htp.htmlopen;
htp.p( '<HEAD>' );
htp.title( glbx.extract_master_parameter('PAGE_TITLE') );
htp.p( '
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
function fillFrame()
{
  var urlsvga = "lab.lab_master?surl=' || glbx.rndsurl(surl) || '&stype=1";
  var urlxga  = "lab.lab_master?surl=' || glbx.rndsurl(surl) || '&stype=2";
  var urlsxga = "lab.lab_master?surl=' || glbx.rndsurl(surl) || '&stype=3";
  var urluga  = "lab.lab_master?surl=' || glbx.rndsurl(surl) || '&stype=4";
  var urlxuga = "lab.lab_master?surl=' || glbx.rndsurl(surl) || '&stype=5";

  if (screen.width < 800)
   parent.xtop.location.href= urlsvga;
  else if ((screen.width >= 800) && (screen.width < 1024))
   parent.xtop.location.href= urlsvga;
  else if ((screen.width >= 1024) && (screen.width < 1280))
   parent.xtop.location.href= urlxga;
  else if ((screen.width >= 1280) && (screen.width < 1400))
   parent.xtop.location.href= urlsxga;
  else if ((screen.width >= 1400) && (screen.width < 1600))
   parent.xtop.location.href= urluga;
  else
   parent.xtop.location.href= urlxuga;
}
//  End -->
</script>
</HEAD>
<FRAMESET ROWS="100" COLS="100%" frameborder="0" framespacing="0" border="0" onLoad="fillFrame();">
  <FRAME NAME="xtop">
</FRAMESET>
<BODY>
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
function fillFrame()
{
  var urlsvga = "lab.lab_master?surl=' || glbx.rndsurl(surl) || '&stype=1";
  var urlxga  = "lab.lab_master?surl=' || glbx.rndsurl(surl) || '&stype=2";
  var urlsxga = "lab.lab_master?surl=' || glbx.rndsurl(surl) || '&stype=3";
  var urluga  = "lab.lab_master?surl=' || glbx.rndsurl(surl) || '&stype=4";
  var urlxuga = "lab.lab_master?surl=' || glbx.rndsurl(surl) || '&stype=5";

  if (screen.width < 800)
   parent.xtop.location.href= urlsvga;
  else if ((screen.width >= 800) && (screen.width < 1024))
   parent.xtop.location.href= urlsvga;
  else if ((screen.width >= 1024) && (screen.width < 1280))
   parent.xtop.location.href= urlxga;
  else if ((screen.width >= 1280) && (screen.width < 1400))
   parent.xtop.location.href= urlsxga;
  else if ((screen.width >= 1400) && (screen.width < 1600))
   parent.xtop.location.href= urluga;
  else
   parent.xtop.location.href= urlxuga;
}
//  End -->
</script>
<NOFRAMES>' );
glbx.noframe(surl,'LAB.SCREEN_SZE');
htp.p( '</NOFRAMES>' );
htp.p( '</BODY>' );
htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'SCREEN_SZE',errmsg=>sqlerrm);
end screen_sze;

procedure lab_master(surl varchar2, stype in integer default 1)
as
 cursor c1(sesid integer) is select * from manufacturer where manufacturer_id in (select aid from login_session where sessid = sesid);

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 sxtype		integer;
 sesid		integer;
 sts		varchar2(100);
begin
  glbx.cookie_id( surl, sxtype, ltype, sesid, sts, 'S', progcalled=>'LAB.LAB_MASTER', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  update login_session set screen_type = stype where sessid = sesid;
  commit;
  open c1( sesid );
  fetch c1 into c1rec;
  close c1;
  htp.htmlopen;
  htp.p( '<HEAD>' );
  htp.title( glbx.extract_master_parameter('BAR_TITLE') );
  htp.p( '</HEAD>' );
  htp.framesetopen(glbx.sctrl(glbx.fndtheme(sesid),'CST_OUTER_FRAME_SIZE',stype),'100%',cattributes=>'frameborder="1" framespacing="0" border="1"  onUnload="history.go(-1);"');
   htp.frame( 'lab.lab_header?surl=' || glbx.rndsurl(surl),'LAB_TOP');
   if substr(c1rec.man_bf,1,1) = 'T'
    then
     htp.frame( 'lab.home?surl=' || glbx.rndsurl(surl),'LAB_BOTTOM');
   elsif substr(c1rec.man_bf,14,1) = 'T'
    then
     htp.frame( 'lab.attention_tasks?surl=' || glbx.rndsurl(surl) || '&shoplist=','LAB_BOTTOM');
   elsif substr(c1rec.man_bf,16,1) = 'T'
    then
     htp.frame( 'lab.cashier?surl=' || glbx.rndsurl(surl),'LAB_BOTTOM');
   elsif substr(c1rec.man_bf,25,1) = 'T'
    then
     htp.frame( 'lab.barcode?surl=' || glbx.rndsurl(surl) || '&p1=&p2=ALL','LAB_BOTTOM');
   elsif substr(c1rec.man_bf,20,1) = 'T'
    then
     htp.frame( 'lab.receptionist?surl=' || glbx.rndsurl(surl),'LAB_BOTTOM');
   elsif substr(c1rec.man_bf,2,1) = 'T'
    then
     htp.frame( 'lab.map_phg?surl=' || glbx.rndsurl(surl),'LAB_BOTTOM');
   elsif substr(c1rec.man_bf,15,1) = 'T'
    then
     htp.frame( 'lab.mng_booking?surl=' || glbx.rndsurl(surl),'LAB_BOTTOM');
   elsif substr(c1rec.man_bf,3,1) = 'T'
    then
     htp.frame( 'ord.labs?surl=' || glbx.rndsurl(surl),'LAB_BOTTOM');
   elsif substr(c1rec.man_bf,4,1) = 'T'
    then
     htp.frame( 'lab.lab_product?surl=' || glbx.rndsurl(surl),'LAB_BOTTOM');
   elsif substr(c1rec.man_bf,22,1) = 'T'
    then
     htp.frame( 'lab.lab_print?surl=' || glbx.rndsurl(surl),'LAB_BOTTOM');
   elsif substr(c1rec.man_bf,23,1) = 'T'
    then
     htp.frame( 'lab.manual_payment?surl=' || glbx.rndsurl(surl),'LAB_BOTTOM');
   elsif substr(c1rec.man_bf,5,1) = 'T'
    then
     htp.frame( 'lab.lab_clearance?surl=' || glbx.rndsurl(surl),'LAB_BOTTOM');
   elsif substr(c1rec.man_bf,6,1) = 'T'
    then
     htp.frame( 'lab.view_tenders?surl=' || glbx.rndsurl(surl),'LAB_BOTTOM');
   elsif substr(c1rec.man_bf,7,1) = 'T'
    then
     htp.frame( 'lab.product_reports?surl=' || glbx.rndsurl(surl),'LAB_BOTTOM');
   elsif substr(c1rec.man_bf,12,1) = 'T'
    then
     htp.frame( 'lab.mng_album?surl=' || glbx.rndsurl(surl),'LAB_BOTTOM');
   elsif substr(c1rec.man_bf,13,1) = 'T'
    then
     htp.frame( 'lab.mng_frames?surl=' || glbx.rndsurl(surl),'LAB_BOTTOM');
   elsif substr(c1rec.man_bf,11,1) = 'T'
    then
     htp.frame( 'lab.mng_brands?surl=' || glbx.rndsurl(surl),'LAB_BOTTOM');
   elsif substr(c1rec.man_bf,18,1) = 'T'
    then
     htp.frame( 'pfm.purchrep?surl=' || glbx.rndsurl(surl),'LAB_BOTTOM');
   end if;
  htp.framesetclose;
  htp.p( '<BODY  onUnload="history.go(-1);">' );
  htp.noframesopen;
   glbx.noframe(surl,'LAB.LAB_MASTER');
  htp.noframesclose;
  htp.p( '</BODY>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'LAB_MASTER',errmsg=>sqlerrm);
end lab_master;

procedure lab_product( surl varchar2, prodid in integer default null, msg in varchar2 default null)
as

 cursor c1(manid integer,prodid integer) is select product_type from product where manufacturer_id = (select aid from login_session where sessid=manid) and product_id = prodid;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'LAB.LAB_PRODUCT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
  htp.htmlopen;
  htp.framesetopen('100%',glbx.sctrl(glbx.fndtheme(owner_id),'CST_INNER_FRAME_SIZE',stype),cattributes=>'frameborder="1" framespacing="0" border="1"');
   if prodid is null
    then
     htp.frame( 'lab.plist?surl=' || glbx.rndsurl(surl),'LAB_LEFT');
     htp.frame( 'lab.product_summary?surl=' || glbx.rndsurl(surl),'LAB_RIGHT');
    else
     open c1(owner_id,prodid);
     fetch c1 into c1rec;
     close c1;
     htp.frame( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&ptype=' || replace(c1rec.product_type,' ','+'),'LAB_LEFT');
     htp.frame( 'lab.edit_product?surl=' || glbx.rndsurl(surl) || '&prodid=' || prodid || '&msg=' || replace(msg,' ','+'),'LAB_RIGHT');
   end if;
  htp.framesetclose;
  htp.p( '<BODY>' );
  htp.noframesopen;
   glbx.noframe(surl,'LAB.LAB_PRODUCT');
  htp.noframesclose;
  htp.p( '</BODY>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'LAB_PRODUCT',errmsg=>sqlerrm);
end lab_product;

procedure lab_print( surl varchar2, msg in varchar2 default null)
as

 cursor c1(manid integer,prodid integer) is select product_type from product where manufacturer_id = manid and product_id = prodid;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'LAB.LAB_PRINT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
  htp.htmlopen;
  htp.framesetopen('100%',glbx.sctrl(glbx.fndtheme(owner_id),'CST_INNER_FRAME_SIZE',stype),cattributes=>'frameborder="1" framespacing="0" border="1"');
   htp.frame( 'lab.print_list?surl=' || glbx.rndsurl(surl), glbx.truncsurl( surl ) || '_LEFT');
   htp.frame( 'lab.print_details?surl=' || glbx.rndsurl(surl) || '&printid=', glbx.truncsurl( surl ) || '_RIGHT');
  htp.framesetclose;
  htp.p( '<BODY>' );
  htp.noframesopen;
   glbx.noframe(surl,'LAB.LAB_PRINT');
  htp.noframesclose;
  htp.p( '</BODY>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'LAB_PRINT',errmsg=>sqlerrm);
end lab_print;

procedure lab_header(surl varchar2)
as

 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.LAB_HEADER', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, null, glbx.backimg(surl,owner_id,pfx.lhs_back,null),stype=>stype,sstyle=>pfx.lhs_text_font,sclr=>pfx.lhs_text_colour,det_sstyle=>pfx.lhs_text_font,det_sclr=>pfx.lhs_text_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.tableopen( cattributes=>'width="100%" cellpadding=2 cellspacing=0 border=0 ');
  htp.tablerowopen;
   htp.tabledata( htf.bold( c1rec.name ) );
   if substr(c1rec.man_bf,1,1) = 'T'
    then
     htp.tabledata( htf.anchor2('lab.home?surl=' || glbx.rndsurl(surl), htf.img(DECS.IMAGE_LOCATION || 'admin/home.gif',cattributes=>'border=0',calt=>LNG.LAB_TXT_002 ),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   if substr(c1rec.man_bf,14,1) = 'T'
    then
     htp.tabledata( htf.anchor2('lab.attention_tasks?surl=' || glbx.rndsurl(surl) || '&shoplist=', htf.img(DECS.IMAGE_LOCATION || 'admin/attention.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_686),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   if substr(c1rec.man_bf,16,1) = 'T'
    then
     htp.tabledata( htf.anchor2('lab.cashier?surl=' || glbx.rndsurl(surl), htf.img(DECS.IMAGE_LOCATION || 'admin/cashier.gif',cattributes=>'border=0',calt=>LNG5.EXT_TXT_180),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   -- XXX add to language5
   if substr(c1rec.man_bf,25,1) = 'T'
    then
     htp.tabledata( htf.anchor2('lab.barcode?surl=' || glbx.rndsurl(surl) || '&p1=&p2=ALL', htf.img(DECS.IMAGE_LOCATION || 'admin/barcode.gif',cattributes=>'border=0',calt=>'Barcode'),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   if substr(c1rec.man_bf,20,1) = 'T'
    then
     htp.tabledata( htf.anchor2('lab.receptionist?surl=' || glbx.rndsurl(surl), htf.img(DECS.IMAGE_LOCATION || 'admin/receptionist.gif',cattributes=>'border=0',calt=>'Receptionist'),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   if substr(c1rec.man_bf,2,1) = 'T'
    then
     htp.tabledata( htf.anchor2('lab.map_phg?surl=' || glbx.rndsurl(surl), htf.img(DECS.IMAGE_LOCATION || 'admin/acct.gif',cattributes=>'border=0',calt=>LNG3.ADM_TXT_670),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   if substr(c1rec.man_bf,15,1) = 'T'
    then
     htp.tabledata( htf.anchor2('lab.mng_booking?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/book.gif',cattributes=>'border=0',calt=>LNG5.BKN_TXT_019),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   if substr(c1rec.man_bf,3,1) = 'T'
    then
     htp.tabledata( htf.anchor2('ord.labs?surl=' || glbx.rndsurl(surl), htf.img(DECS.IMAGE_LOCATION || 'admin/orders.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_128),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   if substr(c1rec.man_bf,4,1) = 'T'
    then
     htp.tabledata( htf.anchor2('lab.lab_product?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/products.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_470),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   if substr(c1rec.man_bf,22,1) = 'T'
    then
     htp.tabledata( htf.anchor2('lab.lab_print?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/printing.gif',cattributes=>'border=0',calt=>'Printing'),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   if substr(c1rec.man_bf,23,1) = 'T'
    then
     htp.tabledata( htf.anchor2('lab.manual_payment?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/man_pay.gif',cattributes=>'border=0',calt=>'Manual Purchase Order Payment'),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   if substr(c1rec.man_bf,5,1) = 'T'
    then
     htp.tabledata( htf.anchor2('lab.lab_clearance?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/clearance.gif',cattributes=>'border=0',calt=>LNG2.FNM_TXT_051),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   if substr(c1rec.man_bf,6,1) = 'T'
    then
     htp.tabledata( htf.anchor2('lab.view_tenders?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/tender.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_001),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   if substr(c1rec.man_bf,7,1) = 'T'
    then
     htp.tabledata( htf.anchor2('lab.product_reports?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/reports.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_432),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   if substr(c1rec.man_bf,8,1) = 'T'
    then
     htp.tabledata( htf.anchor2('forum.display_forum?surl=' || glbx.rndsurl(surl) || '&acc=MFC',htf.img(DECS.IMAGE_LOCATION || 'admin/forum.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_437),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   if substr(c1rec.man_bf,12,1) = 'T'
    then
     htp.tabledata( htf.anchor2('lab.mng_album?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/album.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_453),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   if substr(c1rec.man_bf,13,1) = 'T'
    then
     htp.tabledata( htf.anchor2('lab.mng_frames?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/frame.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_454),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   if substr(c1rec.man_bf,11,1) = 'T'
    then
     htp.tabledata( htf.anchor2('lab.mng_brands?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/brand.gif',cattributes=>'border=0',calt=>LNG3.ADM_TXT_875),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
  if substr(c1rec.man_bf,18,1) = 'T'
   then
    htp.tabledata( htf.anchor2('pfm.purchrep?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/advrep.gif',cattributes=>'border=0',calt=>LNG5.EXT_TXT_547),ctarget=>'ADVANCED_REPORT'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
  end if;
  if substr(c1rec.man_bf,19,1) = 'T'
   then
    htp.tabledata( htf.anchor2('lab.connectas?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/connect.gif',cattributes=>'border=0',calt=>LNG3.ADM_TXT_040),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
  end if;
   if substr(c1rec.man_bf,9,1) = 'T'
    then
     if c1rec.is_beta_tester = 'T'
      then
       htp.tabledata( htf.anchor2( 'glbx.beta_bug',htf.img( DECS.IMAGE_LOCATION || 'admin/bug.gif', cattributes=>'BORDER=0'), ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
     end if;
   end if;
   if substr(c1rec.man_bf,10,1) = 'T'
    then
     htp.tabledata( htf.anchor2(nvl(c1rec.home_page,'glbx.acct_logoff?surl=' || glbx.rndsurl(surl)), htf.img(DECS.IMAGE_LOCATION || 'admin/logoff.gif',cattributes=>'border=0',calt=>LNG.LAB_TXT_002 ),ctarget=>'_top'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
  htp.tablerowclose;
 htp.tableclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'LAB_HEADER',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end lab_header;

procedure map_phg( surl in varchar2, msg in varchar2 default null )
as

 cursor c2(manid integer) is select * from manufacturer_photographer_disc mpd where manufacturer_id = manid;
 cursor c3 is select pid,business_name from photographer order by business_name;
 cursor c3x(manid integer) is select p.pid,p.business_name from photographer p, manufacturer_photographer mp where mp.manufacturer_id = manid and mp.pid = p.pid order by business_name;
 cursor c4(manid integer) is select price_book from manufacturer_price_book where manufacturer_id = manid;

 c1rec		manufacturer%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.MAP_PHG', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 open c4(owner_id);
 fetch c4 into c4rec;
 if c4%NOTFOUND
  then
   close c4;
   manage_price_books(surl, LNG4.AHC_TXT_273);
   return;
 end if;
 close c4;
 glbx.main_title( surl, LNG2.PBK_TXT_131,glbx.backimg(surl,owner_id,pfx.text_back,null),'B09',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ');
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_261 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG4.AHC_TXT_097 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG3.ADM_TXT_067 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG.PHG_TXT_470 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;
  htp.formopen( 'lab.accept_map_phg' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl) );
  for c2rec in c2(c1rec.manufacturer_id) loop
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || ' ALIGN=CENTER VALIGN=CENTER>' );
    htp.formselectopen( 'P1' );
    htp.formselectoption( NULL );
    if c1rec.all_photographers = 'T'
     then
      for c3rec in c3 loop
       if c3rec.pid = c2rec.pid
        then
         htp.formselectoption( c3rec.business_name, 'SELECTED', cattributes=>'VALUE="' || c3rec.pid || '"' );
        else
         htp.formselectoption( c3rec.business_name, cattributes=>'VALUE="' || c3rec.pid || '"' );
       end if;
      end loop;
     else
      for c3rec in c3x(c1rec.manufacturer_id) loop
       if c3rec.pid = c2rec.pid
        then
         htp.formselectoption( c3rec.business_name, 'SELECTED', cattributes=>'VALUE="' || c3rec.pid || '"' );
        else
         htp.formselectoption( c3rec.business_name, cattributes=>'VALUE="' || c3rec.pid || '"' );
       end if;
      end loop;
    end if;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || ' ALIGN=CENTER VALIGN=CENTER>' );
    htp.formselectopen( 'P3' );
    if c2rec.private_price_book = 'T'
     then
      htp.formselectoption( LNG.PHG_TXT_045, 'SELECTED', cattributes=>'VALUE="T"' );
      htp.formselectoption( LNG.PHG_TXT_046, cattributes=>'VALUE="F"' );
     else
      htp.formselectoption( LNG.PHG_TXT_045, cattributes=>'VALUE="T"' );
      htp.formselectoption( LNG.PHG_TXT_046, 'SELECTED', cattributes=>'VALUE="F"' );
    end if;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext( 'P2', 10, 20, c2rec.discount ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
    htp.p( '<TD ' || pfx.qcbground || ' ALIGN=CENTER VALIGN=CENTER>' );
    htp.formselectopen( 'P4' );
    htp.formselectoption( NULL );
    for c4rec in c4(c1rec.manufacturer_id) loop
     if c4rec.price_book = c2rec.product_type
      then
       htp.formselectoption( c4rec.price_book, 'SELECTED' );
      else
       htp.formselectoption( c4rec.price_book );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  end loop;
  for j in 1..5 loop
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || ' ALIGN=CENTER VALIGN=CENTER>' );
    htp.formselectopen( 'P1' );
    htp.formselectoption( NULL );
    if c1rec.all_photographers = 'T'
     then
      for c3rec in c3 loop
       htp.formselectoption( c3rec.business_name, cattributes=>'VALUE="' || c3rec.pid || '"' );
      end loop;
     else
      for c3rec in c3x(c1rec.manufacturer_id) loop
       htp.formselectoption( c3rec.business_name, cattributes=>'VALUE="' || c3rec.pid || '"' );
      end loop;
    end if;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || ' ALIGN=CENTER VALIGN=CENTER>' );
    htp.formselectopen( 'P3' );
     htp.formselectoption( LNG.PHG_TXT_045, 'SELECTED', cattributes=>'VALUE="T"' );
     htp.formselectoption( LNG.PHG_TXT_046, cattributes=>'VALUE="F"' );
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext( 'P2', 10, 20, null ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
    htp.p( '<TD ' || pfx.qcbground || ' ALIGN=CENTER VALIGN=CENTER>' );
    htp.formselectopen( 'P4' );
    htp.formselectoption( NULL );
    for c4rec in c4(c1rec.manufacturer_id) loop
     htp.formselectoption( c4rec.price_book );
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG2.PBK_TXT_132 );
 htp.formclose;
 htp.p( '<CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'MAP_PHG',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end map_phg;

procedure accept_map_phg( surl in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		number;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.ACCEPT_MAP_PHG', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 delete from manufacturer_photographer_disc where manufacturer_id = owner_id;
 for j in p1.first..p1.last loop
  if p1(j) is not null
   then
    begin nmb := to_number( p2(j) ); exception when others then nmb := 0; end;
    insert into manufacturer_photographer_disc(manufacturer_id,pid,discount,private_price_book,product_type) values (owner_id,p1(j),nmb,p3(j),p4(j));
  end if;
 end loop;
 commit;
 map_phg(surl,LNG2.PBK_TXT_133);

exception when others then
 glbx.error_details( 'LAB', 'ACCEPT_MAP_PHG',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end accept_map_phg;

procedure plist(surl varchar2, sortby in integer default 1, ptype in varchar2 default NULL, lmt in varchar2 default '0Z' )
as
 cursor c2(manid integer, sortby integer, ptype varchar2, lmt varchar2) is
  select *
  from product
  where manufacturer_id = manid and
        product_type = ptype and
        upper(substr(name,1,1)) >= substr(lmt,1,1) and
        upper(substr(name,1,1)) <= substr(lmt,2,1) and
        product_id not in (select chi_product_id from part_map)
  order by decode(sortby,1,manufctr_code||name,2,name||manufctr_code,3,product_id);

 -- cursor c3(manid integer) is select distinct product_type from product where manufacturer_id = manid;
 cursor c3(manid integer) is select price_book from manufacturer_price_book where manufacturer_id = manid;

 cursor c4(prodid integer) is select price from price_book where product_id = prodid and valid_until is null;

 c1rec	manufacturer%ROWTYPE;
 c4rec  c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 last_type	varchar2(100);
 last_key	varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.PLIST', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 if ptype is null
  then
   glbx.main_title( surl, LNG.LAB_TXT_006,glbx.backimg(surl,owner_id,pfx.text_back,null),'L01',stype=>greatest(stype-3,1),sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,small_link=>TRUE,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  else
   glbx.main_title( surl, ptype,glbx.backimg(surl,owner_id,pfx.text_back,null),'L01',stype=>greatest(stype-3,1),sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,small_link=>TRUE,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 end if;
 htp.nl;
 htp.anchor2('lab.manage_price_books?surl=' || glbx.rndsurl(surl),LNG.LAB_TXT_059,ctarget=>'LAB_RIGHT');
 htp.nl;
 if ptype is not null
  then
   htp.anchor('lab.plist?surl=' || glbx.rndsurl(surl),LNG4.AHC_TXT_467);
   htp.nl;
 end if;
 htp.anchor2('lab.edit_product?surl=' || glbx.rndsurl(surl) || '&prodid=0&defpbook=' || replace(ptype,' ','+'),LNG.LAB_TXT_007,ctarget=>'LAB_RIGHT');
 htp.nl;

 if ptype is null
  then
   htp.nl;
   htp.ulistopen;
   for c3rec in c3(owner_id) loop
    htp.listitem(htf.anchor( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&ptype=' || replace(c3rec.price_book,' ','+'),c3rec.price_book ));
   end loop;
   htp.ulistclose;
   htp.htmlclose;
   return;
 end if;

 if sortby = 1
  then
   htp.anchor( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&sortby=2&lmt=' || lmt || '&ptype=' || ptype, LNG.LAB_TXT_085 );
   htp.anchor( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&sortby=3&lmt=' || lmt || '&ptype=' || ptype, LNG.LAB_TXT_086 );
 elsif sortby = 1
  then
   htp.anchor( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&sortby=1&lmt=' || lmt || '&ptype=' || ptype, LNG.LAB_TXT_087 );
   htp.anchor( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&sortby=3&lmt=' || lmt || '&ptype=' || ptype, LNG.LAB_TXT_086 );
 else
   htp.anchor( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&sortby=1&lmt=' || lmt || '&ptype=' || ptype, LNG.LAB_TXT_087 );
   htp.anchor( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&sortby=2&lmt=' || lmt || '&ptype=' || ptype, LNG.LAB_TXT_085 );
 end if;

   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
    htp.tablerowopen;
     htp.tabledata( htf.anchor( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&ptype=' || ptype ||  '&lmt=AC','[A-C]' ), cattributes=>'class="TD.SMALL"');
     htp.tabledata( htf.anchor( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&ptype=' || ptype ||  '&lmt=DF','[D-F]' ), cattributes=>'class="TD.SMALL"');
     htp.tabledata( htf.anchor( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&ptype=' || ptype ||  '&lmt=GI','[G-I]' ), cattributes=>'class="TD.SMALL"');
     htp.tabledata( htf.anchor( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&ptype=' || ptype ||  '&lmt=JL','[J-L]' ), cattributes=>'class="TD.SMALL"');
     htp.tabledata( htf.anchor( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&ptype=' || ptype ||  '&lmt=MO','[M-O]' ), cattributes=>'class="TD.SMALL"');
     htp.tabledata( htf.anchor( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&ptype=' || ptype ||  '&lmt=PS','[P-S]' ), cattributes=>'class="TD.SMALL"');
     htp.tabledata( htf.anchor( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&ptype=' || ptype ||  '&lmt=TV','[T-V]' ), cattributes=>'class="TD.SMALL"');
     htp.tabledata( htf.anchor( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&ptype=' || ptype ||  '&lmt=WZ','[W-Z]' ), cattributes=>'class="TD.SMALL"');
     htp.tabledata( htf.anchor( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&ptype=' || ptype ||  '&lmt=09','[0-9]' ), cattributes=>'class="TD.SMALL"');
     htp.tabledata( htf.anchor( 'lab.plist?surl=' || glbx.rndsurl(surl) || '&ptype=' || ptype ||  '&lmt=0Z','[ALL]' ), cattributes=>'class="TD.SMALL"');
    htp.tablerowclose;
   htp.tableclose;

 htp.nl;
 for c2rec in c2(owner_id,sortby,ptype,lmt) loop
  if (last_type is null) or (c2rec.product_type <> last_type)
   then
    htp.bold( c2rec.product_type );
    htp.nl;
  end if;
  c4rec.price := NULL;
  open c4(c2rec.product_id);
  fetch c4 into c4rec;
  close c4;
  htp.p( htf.img( DECS.IMAGE_LOCATION || 'adminc/list.gif',cattributes=>'border=0',
                  calt=>c2rec.name || chr(10) || c2rec.product_type || chr(10) || c2rec.product_key || chr(10) || c2rec.xref_mfctr_code || chr(10) || trim(to_char(c4rec.price,LNG.MONEY_FORMAT)) || chr(10) || LNG4.AHC_TXT_694 || ':' || to_char( c2rec.current_stock) || chr(10) || c2rec.product_class) || ' ' ||
         htf.bold(c2rec.manufctr_code) || ' - ' ||
         htf.anchor2('lab.edit_product?surl=' || glbx.rndsurl(surl) || '&prodid=' || c2rec.product_id,substr(c2rec.name,1,40),ctarget=>'LAB_RIGHT') || htf.nl);
  last_type := c2rec.product_type;
 end loop;
 htp.nl;
 htp.formopen( 'lab.edit_product',ctarget=>'LAB_RIGHT');
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'PRODID','0');
 htp.formsubmit( null, LNG.LAB_TXT_007 );
 htp.formclose;
 htp.nl;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'PLIST',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end plist;

procedure manage_price_books(surl varchar2, msg in varchar2 default null)
as
 cursor c1(mfid integer) is select product_type,count('x') tot from product where manufacturer_id = mfid group by product_type;
 cursor c3(mfid integer, pt varchar2) is select 'x' from phg_price_item where lab_id in (select product_id from product where product_type = pt and manufacturer_id = mfid);
 cursor c4(mfid integer) is select price_book from manufacturer_price_book where manufacturer_id = mfid;

 c2rec		manufacturer%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.MANAGE_PRICE_BOOKS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c2rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c2rec.theme_name );
 glbx.main_title( surl, LNG.LAB_TXT_059,glbx.backimg(surl,owner_id,pfx.text_back,null),'L07',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null
  then
   glbx.header_msg(msg);
 end if;
 htp.formopen( 'lab.pbutil', ctarget=>'LAB_BOTTOM' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.formhidden( 'P2', 'CREATE' );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG2.PBK_TXT_007) );
   htp.tabledata( htf.formtext( 'P1', 20, 20 ) );
   htp.tabledata( htf.formsubmit( null, LNG2.PBK_TXT_012 ));
  htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.formopen( 'lab.pbutil', ctarget=>'LAB_BOTTOM' );
 htp.formhidden( 'P2', 'DELETE' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG4.AHC_TXT_260) );
   htp.p( '<TD>' );
   htp.formselectopen( 'P1' );
   for c4rec in c4(owner_id) loop
    htp.formselectoption( c4rec.price_book );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.formsubmit( null, LNG.SLD_TXT_004 ));
  htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.formopen( 'lab.pbutil_rename', ctarget=>'LAB_BOTTOM' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG4.AHC_TXT_257) );
   htp.tabledata( LNG4.AHC_TXT_258 );
   htp.p( '<TD>' );
   htp.formselectopen( 'P1' );
   for c4rec in c4(owner_id) loop
    htp.formselectoption( c4rec.price_book );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;' );
   htp.tabledata( LNG4.AHC_TXT_259 );
   htp.p( '<TD>' );
   htp.formselectopen( 'P2' );
   for c4rec in c4(owner_id) loop
    htp.formselectoption( c4rec.price_book );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;' );
   htp.tabledata( '&nbsp;' );
   htp.tabledata( htf.formsubmit( null, LNG.PHG_TXT_169 ));
  htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.formopen( 'lab.pbutil' );
 htp.formhidden( 'P2', 'DOWNLOAD' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG4.AHC_TXT_309) );
   htp.p( '<TD>' );
   htp.formselectopen( 'P1' );
   for c4rec in c4(owner_id) loop
    htp.formselectoption( c4rec.price_book );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.formsubmit( null, LNG2.PBK_TXT_128 ));
  htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.line;
 htp.nl;
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.PBK_TXT_003 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG.LAB_TXT_060 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG.LAB_TXT_001 ),cattributes=>pfx.qbground );
  htp.tablerowclose;
 for c1rec in c1( owner_id ) loop
  htp.tablerowopen;
   htp.tabledata( htf.bold( c1rec.product_type ),cattributes=>pfx.qcbground );
   htp.tabledata( c1rec.tot,cattributes=>pfx.qcbground );
   open c3(owner_id,c1rec.product_type);
   fetch c3 into c3rec;
   if c3%FOUND
    then
     htp.tabledata( LNG.LAB_TXT_062 || htf.nl || htf.anchor2( 'lab.del_partial?surl=' || glbx.rndsurl(surl) || '&pt=' || translate(c1rec.product_type,' ','+'),LNG.LAB_TXT_068,ctarget=>'LAB_BOTTOM'),cattributes=>pfx.qcbground );
    else
     htp.tabledata( htf.anchor2('lab.del_pb?surl=' || glbx.rndsurl(surl) || '&pt=' || translate(c1rec.product_type,' ','+'),LNG.LAB_TXT_061,ctarget=>'LAB_BOTTOM'),cattributes=>pfx.qcbground );
   end if;
   close c3;
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.bold(LNG.LAB_TXT_045);
 htp.nl;
 htp.formopen( 'lab.reverse_engineer', ctarget=>'LAB_BOTTOM' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.italic( LNG.LAB_TXT_046 || ' ' );
 htp.formtext( 'P1',20,100,'price.csv' );
 htp.nl;
 htp.italic( LNG.LAB_TXT_048 || ' ' );
 htp.formcheckbox( 'P2', 'T', 'CHECKED' );
 htp.nl;
 htp.nl;
 htp.formsubmit( null, LNG.LAB_TXT_047 );
 htp.formclose;
 htp.nl;
 htp.p('<FONT SIZE="1">');
 htp.italic( LNG.LAB_TXT_058 ); htp.nl;
 htp.italic( htf.bold('Col1:') || ' ' || LNG.LAB_TXT_042 ); htp.nl;
 htp.italic( htf.bold('Col2:') || ' ' || LNG.LAB_TXT_052 ); htp.nl;
 htp.italic( htf.bold('Col3:') || ' ' || LNG.LAB_TXT_053 ); htp.nl;
 htp.italic( htf.bold('Col4:') || ' ' || LNG.LAB_TXT_054 ); htp.nl;
 htp.italic( htf.bold('Col5:') || ' ' || LNG.LAB_TXT_055 ); htp.nl;
 htp.italic( htf.bold('Col6:') || ' ' || LNG.LAB_TXT_056 ); htp.nl;
 htp.italic( htf.bold('Col7:') || ' ' || LNG.LAB_TXT_057 ); htp.nl;
 htp.italic( htf.bold('Col8:') || ' ' || LNG4.AHC_TXT_524 ); htp.nl;
 htp.italic( htf.bold('Col9:') || ' ' || LNG4.AHC_TXT_523 ); htp.nl;
 htp.italic( htf.bold('Col10:') || ' ' || LNG4.AHC_TXT_609 ); htp.nl;
 htp.italic( htf.bold('Col11:') || ' ' || LNG5.EXT_TXT_129 ); htp.nl;
 htp.p('</FONT>');
 htp.nl;
 htp.line;
 htp.nl;
 htp.bold( LNG2.FNM_TXT_090 );
 htp.nl;
 htp.nl;
 htp.formopen( 'lab.attach' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formcheckbox( 'P1', 'T' );
 htp.bold( ' ' || LNG2.FNM_TXT_091 );
 htp.nl;
 htp.formradio( 'P2', '1' );
 htp.bold( ' ' || LNG2.FNM_TXT_092 );
 htp.nl;
 htp.formradio( 'P2', '2' );
 htp.bold( ' ' || LNG2.FNM_TXT_093 );
 htp.nl;
 htp.formradio( 'P2', '3', 'CHECKED' );
 htp.bold( ' ' || LNG2.FNM_TXT_094 );
 htp.nl;
 htp.nl;
 htp.formsubmit( null, LNG2.FNM_TXT_095 );
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'MANAGE_PRICE_BOOKS',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end manage_price_books;

procedure pbutil(surl varchar2, p1 in varchar2, p2 in varchar2)
as

 cursor c1(mfid integer, pb varchar2) is select 'x' from manufacturer_price_book where manufacturer_id = mfid and price_book = pb;
 cursor c2(mfid integer, pb varchar2) is select * from product where manufacturer_id = mfid and product_type = pb order by product_id;
 cursor c3(pid integer) is select price from price_book where product_id = pid and valid_until is null;
 cursor c4(bid integer) is select brand_name from brand where brand_id = bid;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 bfr		varchar2(32767);
 pfx		THEME%ROWTYPE;
 fl		UTL_FILE.FILE_TYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.PBUTIL', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 if p2 = 'DELETE'
  then
   delete from price_book where product_id in (select product_id from product where product_type = p1 and manufacturer_id = owner_id);
   delete from product where product_type = p1 and manufacturer_id = owner_id;
   delete from manufacturer_price_book where manufacturer_id = owner_id and price_book = p1;
   commit;
   lab_product(surl,NULL,LNG2.PBK_TXT_039);
  elsif p2 = 'DOWNLOAD'
   then
   fl := utl_file.fopen( glbx.extract_master_parameter('REPORTS_DIRECTORY'), p1 || '.csv', 'w' );
   for c2rec in c2(owner_id,p1) loop
    open c3(c2rec.product_id);
    fetch c3 into c3rec;
    close c3;
    open c4(c2rec.brand_id);
    fetch c4 into c4rec;
    close c4;
    bfr := NULL;
    bfr := '"' || c2rec.manufctr_code || '","' || replace(c2rec.name,'"','') || '","' || c2rec.xref_mfctr_code || '","' || ltrim(to_char(c3rec.price,LNG.MONEY_FORMAT)) || '","' || c2rec.is_discounted || '","' || replace(c2rec.product_type,'"','') || '","' || replace(c2rec.product_key,'"','') || '","' || replace(c4rec.brand_name,'"','') || '"';
    utl_file.put_line( fl, buffer=>bfr );
   end loop;
   utl_file.fclose(fl);
   manage_price_books(surl,LNG4.AHC_TXT_310);
   return;
  else
   if p1 is null
    then
     lab_product(surl,NULL,LNG4.AHC_TXT_262);
     return;
   end if;
   open c1(owner_id,p1);
   fetch c1 into c1rec;
   if c1%FOUND
    then
     close c1;
     lab_product(surl,NULL,LNG4.AHC_TXT_263);
     return;
   end if;
   close c1;
   insert into manufacturer_price_book(manufacturer_id,price_book) values (owner_id,p1);
   commit;
   lab_product(surl,NULL,LNG2.PBK_TXT_016);
   return;
 end if;

exception when others then
 glbx.error_details( 'LAB', 'PBUTIL',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id || ' P1:' || p1);
end pbutil;

procedure pbutil_rename(surl varchar2, p1 in varchar2, p2 in varchar2)
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.PBUTIL_RENAME', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 if p1 = p2
  then
   manage_price_books(surl,LNG4.AHC_TXT_265);
   return;
 end if;

 update product set product_type = p2 where product_type = p1 and manufacturer_id = owner_id;
 delete from manufacturer_price_book where manufacturer_id = owner_id and price_book = p1;
 commit;
 lab_product(surl,NULL,LNG4.AHC_TXT_266);

exception when others then
 glbx.error_details( 'LAB', 'PBUTIL_RENAME',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id || ' P1:' || p1);
end pbutil_rename;

procedure del_pb(surl varchar2,pt in varchar2)
as
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.DEL_PB', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 -- What happens if photographers are mapped?
 delete from price_book where product_id in (select product_id from product where nvl(product_type,'|') = nvl(pt,'|') and manufacturer_id = owner_id);
 delete from product where nvl(product_type,'|') = nvl(pt,'|') and manufacturer_id = owner_id;
 commit;
 lab_product(surl);
exception when others then
 glbx.error_details( 'LAB', 'DEL_PB',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id || ' PT:' || pt);
end del_pb;

procedure del_partial(surl varchar2,pt in varchar2)
as
 cursor c1(mfid integer, pt varchar2) is select product_id from product where manufacturer_id = mfid and product_type = pt;
 cursor c3(prdid integer) is select 'x' from phg_price_item where lab_id = prdid;

 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.DEL_PARTIAL', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 for c1rec in c1(owner_id,pt) loop
 open c3(c1rec.product_id);
 fetch c3 into c3rec;
 if c3%NOTFOUND
  then
   delete from price_book where product_id = c1rec.product_id;
   delete from product where product_id = c1rec.product_id;
 end if;
 close c3;
 end loop;
 commit;
 lab_product(surl);
exception when others then
 glbx.error_details( 'LAB', 'DEL_PARTIAL',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id || ' PT:' || pt);
end del_partial;

procedure home( surl varchar2, msg in varchar2 default null)
as

 cursor c3 is select theme_name from theme order by theme_name;
 cursor c4(manid integer) is select distinct product_type from product where manufacturer_id = manid;
 cursor c5(manid integer) is select theme_name from limit_laf_mfctr where manufacturer_id = manid order by theme_name;
 cursor c6 is select * from umo_attributes order by umo_type,category,sub_category;
 cursor c7 is select aid,username from customer_account order by username;

 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 tmp		varchar2(32767);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.HOME', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, replace(LNG.LAB_TXT_008,'Manufacturer',c1rec.manufacturer_title),glbx.backimg(surl,owner_id,pfx.text_back,null),'L02',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.formopen( 'glbx.process_mfc_details' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.tableopen(cattributes=>'cellpadding=0 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
     htp.tabledata( htf.bold(replace(LNG.LAB_TXT_009,'Manufacturer',c1rec.manufacturer_title)),cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext( 'P1', 40, 100, c1rec.name ),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_301),cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext( 'P6', 40, 100, c1rec.contact_email ),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.CST_TXT_005),cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext( 'P2', 40, 100, c1rec.name ),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.GLB_TXT_107),cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext( 'P7', 40, 100, c1rec.abn_number),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.GLB_TXT_076),cattributes=>pfx.qbground );
     htp.tabledata( htf.bold(c1rec.username),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.GLB_TXT_078),cattributes=>pfx.qbground );
     htp.tabledata( htf.italic( nvl(to_char(c1rec.date_created,LNG.MASK),'&nbsp;')),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.GLB_TXT_018),cattributes=>pfx.qbground );
     htp.tabledata( htf.formpassword( 'P3', 40, 100, null ),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_098),cattributes=>pfx.qbground );
     if c1rec.price_book_public = 'T'
      then
       htp.tabledata( htf.formcheckbox( 'P9', 'T', 'CHECKED' ),cattributes=>pfx.qcbground );
      else
       htp.tabledata( htf.formcheckbox( 'P9', 'T' ),cattributes=>pfx.qcbground );
     end if;
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_107),cattributes=>pfx.qbground );
     htp.p( '<TD ' || pfx.qcbground || '>' );
     htp.formselectopen( 'P10' );
     htp.formselectoption( NULL );
     for c4rec in c4(owner_id) loop
      if c4rec.product_type = c1rec.public_book
       then
        htp.formselectoption( c4rec.product_type, 'SELECTED' );
       else
        htp.formselectoption( c4rec.product_type );
      end if;
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.GLB_TXT_105),cattributes=>pfx.qbground );
     htp.tabledata( htf.formpassword( 'P4', 40, 100, null ),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   tmp := htf.formselectopen( 'P5' );
   if c1rec.limit_laf = 'F'
    then
     for c3rec in c3 loop
      if c3rec.theme_name = c1rec.theme_name
       then
        tmp := tmp || htf.formselectoption( c3rec.theme_name,'SELECTED' );
       else
        tmp := tmp || htf.formselectoption( c3rec.theme_name );
      end if;
     end loop;
    else
     for c5rec in c5( c1rec.manufacturer_id) loop
      if c5rec.theme_name = c1rec.theme_name
       then
        tmp := tmp || htf.formselectoption( c5rec.theme_name,'SELECTED' );
       else
        tmp := tmp || htf.formselectoption( c5rec.theme_name );
      end if;
     end loop;
   end if;
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG3.ADM_TXT_088),cattributes=>pfx.qbground );
     htp.tabledata( tmp,cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.LAB_TXT_038),cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext( 'P8', 20, 20, c1rec.invoice_days),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_327),cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext( 'P11', 40, 1000, c1rec.home_page),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   if substr(c1rec.man_bf,14,1) = 'T'
    then
     htp.tablerowopen;
       htp.tabledata( htf.bold(LNG4.AHC_TXT_892),cattributes=>pfx.qbground );
       htp.p( '<TD ' || pfx.qcbground || '>' );
       htp.formselectopen( 'P12' );
       if c1rec.workflow_display = 'P'
        then
         htp.formselectoption( LNG4.AHC_TXT_890, 'SELECTED', cattributes=>'VALUE="P"' );
         htp.formselectoption( LNG4.AHC_TXT_891, cattributes=>'VALUE="S"' );
         htp.formselectoption( 'View by Shopping Basket Item', cattributes=>'VALUE="I"' );
       elsif c1rec.workflow_display = 'S'
        then
         htp.formselectoption( LNG4.AHC_TXT_890, cattributes=>'VALUE="P"' );
         htp.formselectoption( LNG4.AHC_TXT_891, 'SELECTED', cattributes=>'VALUE="S"' );
         htp.formselectoption( 'View by Shopping Basket Item', cattributes=>'VALUE="I"' );
       elsif c1rec.workflow_display = 'I'
        then
         htp.formselectoption( LNG4.AHC_TXT_890, cattributes=>'VALUE="P"' );
         htp.formselectoption( LNG4.AHC_TXT_891, cattributes=>'VALUE="S"' );
         htp.formselectoption( 'View by Shopping Basket Item', 'SELECTED', cattributes=>'VALUE="I"' );
       end if;
       htp.formselectclose;
       htp.p( '</TD>' );
    else
     htp.formhidden( 'P12','P' );
   end if;
  if substr(c1rec.man_bf,14,1) = 'T'
   then
     htp.tablerowopen;
       htp.tabledata( htf.bold(LNG5.EXT_TXT_324),cattributes=>pfx.qbground );
       htp.p( '<TD ' || pfx.qcbground || '>' );
       htp.formselectopen( 'P13' );
       htp.formselectoption( NULL );
       for c6rec in c6 loop
        if c1rec.sort_on_attribute_id = c6rec.attribute_id
         then
           htp.formselectoption( c6rec.category || '-' || c6rec.sub_category || ' (' || c6rec.umo_type || ')', 'SELECTED', cattributes=>'VALUE="' || c6rec.attribute_id || '"' );
         else
           htp.formselectoption( c6rec.category || '-' || c6rec.sub_category || ' (' || c6rec.umo_type || ')', cattributes=>'VALUE="' || c6rec.attribute_id || '"' );
        end if;
       end loop;
       htp.formselectclose;
       htp.p( '</TD>' );
    else
     htp.formhidden( 'P13', NULL );
  end if;
  -- Receptionist, specify default logon
  if substr(c1rec.man_bf,20,1) = 'T'
   then
     htp.tablerowopen;
       htp.tabledata( htf.bold('Receptionist Customer Account'),cattributes=>pfx.qbground );
       htp.p( '<TD ' || pfx.qcbground || '>' );
       htp.formselectopen( 'P14' );
       htp.formselectoption( NULL );
       for c7rec in c7 loop
        if c1rec.receptionist_aid = c7rec.aid
         then
           htp.formselectoption( c7rec.username, 'SELECTED', cattributes=>'VALUE="' || c7rec.aid || '"' );
         else
           htp.formselectoption( c7rec.username, cattributes=>'VALUE="' || c7rec.aid || '"' );
        end if;
       end loop;
       htp.formselectclose;
       htp.p( '</TD>' );
    else
     htp.formhidden( 'P14', NULL );
  end if;
  -- Receptionist, specify default logon
  if substr(c1rec.man_bf,25,1) = 'T'
   then
     htp.tablerowopen;
       htp.tabledata( htf.bold('Barcode Function'),cattributes=>pfx.qbground );
       htp.p( '<TD ' || pfx.qcbground || '>' );
       htp.formtext( 'P15', 40, 1000, c1rec.barcode_function );
       htp.p( '</TD>' );
    else
     htp.formhidden( 'P15', NULL );
  end if;
  htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION',replace(LNG.LAB_BUT_011,'Manufacturer',c1rec.manufacturer_title));
 htp.formclose;
 htp.nl;
 htp.line;
 htp.nl;
 htp.bold( c1rec.name );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0 ');
  if substr(c1rec.man_bf,1,1) = 'T'
   then
    htp.tablerowopen;
     htp.tabledata( htf.anchor2('lab.home?surl=' || glbx.rndsurl(surl), htf.img(DECS.IMAGE_LOCATION || 'admin/home.gif',cattributes=>'border=0',calt=>LNG.LAB_TXT_002 ),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
     htp.tabledata( htf.anchor2('lab.home?surl=' || glbx.rndsurl(surl), LNG.LAB_TXT_002 ),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,14,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lab.attention_tasks?surl=' || glbx.rndsurl(surl) || '&shoplist=', htf.img(DECS.IMAGE_LOCATION || 'admin/attention.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_686),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('lab.attention_tasks?surl=' || glbx.rndsurl(surl) || '&shoplist=', LNG4.AHC_TXT_686),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,16,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lab.cashier?surl=' || glbx.rndsurl(surl), htf.img(DECS.IMAGE_LOCATION || 'admin/cashier.gif',cattributes=>'border=0',calt=>LNG5.EXT_TXT_180),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('lab.cashier?surl=' || glbx.rndsurl(surl), LNG5.EXT_TXT_180),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,25,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lab.barcode?surl=' || glbx.rndsurl(surl) || '&p1=&p2=ALL', htf.img(DECS.IMAGE_LOCATION || 'admin/barcode.gif',cattributes=>'border=0',calt=>'Barcode'),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('lab.barcode?surl=' || glbx.rndsurl(surl) || '&p1=&p2=ALL', 'Barcode'),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,20,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lab.receptionist?surl=' || glbx.rndsurl(surl), htf.img(DECS.IMAGE_LOCATION || 'admin/receptionist.gif',cattributes=>'border=0',calt=>'Receptionist'),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('lab.receptionist?surl=' || glbx.rndsurl(surl), 'Receptionist'),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,2,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lab.map_phg?surl=' || glbx.rndsurl(surl), htf.img(DECS.IMAGE_LOCATION || 'admin/acct.gif',cattributes=>'border=0',calt=>LNG3.ADM_TXT_670),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('lab.map_phg?surl=' || glbx.rndsurl(surl), LNG3.ADM_TXT_670),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,15,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lab.mng_booking?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/book.gif',cattributes=>'border=0',calt=>LNG5.BKN_TXT_019),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('lab.mng_booking?surl=' || glbx.rndsurl(surl),LNG5.BKN_TXT_019),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,3,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('ord.labs?surl=' || glbx.rndsurl(surl), htf.img(DECS.IMAGE_LOCATION || 'admin/orders.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_128),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('ord.labs?surl=' || glbx.rndsurl(surl), LNG.PHG_ALT_128),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,4,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lab.lab_product?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/products.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_470),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('lab.lab_product?surl=' || glbx.rndsurl(surl),LNG.PHG_TXT_470),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,22,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lab.lab_print?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/printing.gif',cattributes=>'border=0',calt=>'Printing'),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('lab.lab_print?surl=' || glbx.rndsurl(surl),'Printing'),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,23,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lab.manual_payment?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/man_pay.gif',cattributes=>'border=0',calt=>'Manual Purchase Order Payment'),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('lab.manual_payment?surl=' || glbx.rndsurl(surl),'Manual Purchase Order Payment'),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,5,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lab.lab_clearance?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/clearance.gif',cattributes=>'border=0',calt=>LNG2.FNM_TXT_051),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('lab.lab_clearance?surl=' || glbx.rndsurl(surl),LNG2.FNM_TXT_051),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,6,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lab.view_tenders?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/tender.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_001),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('lab.view_tenders?surl=' || glbx.rndsurl(surl),LNG4.AHC_TXT_001),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,7,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lab.product_reports?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/reports.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_432),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('lab.product_reports?surl=' || glbx.rndsurl(surl),LNG.PHG_ALT_432),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,8,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('forum.display_forum?surl=' || glbx.rndsurl(surl) || '&acc=MFC',htf.img(DECS.IMAGE_LOCATION || 'admin/forum.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_437),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('forum.display_forum?surl=' || glbx.rndsurl(surl) || '&acc=MFC',LNG.PHG_TXT_437),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,12,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lab.mng_album?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/album.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_453),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('lab.mng_album?surl=' || glbx.rndsurl(surl),LNG4.AHC_TXT_453),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,13,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lab.mng_frames?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/frame.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_454),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('lab.mng_frames?surl=' || glbx.rndsurl(surl),LNG4.AHC_TXT_454),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,11,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lab.mng_brands?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/brand.gif',cattributes=>'border=0',calt=>LNG3.ADM_TXT_875),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('lab.mng_brands?surl=' || glbx.rndsurl(surl),LNG3.ADM_TXT_875),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,18,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('pfm.purchrep?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/advrep.gif',cattributes=>'border=0',calt=>LNG5.EXT_TXT_547),ctarget=>'ADVANCED_REPORT'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('pfm.purchrep?surl=' || glbx.rndsurl(surl),LNG5.EXT_TXT_547,ctarget=>'ADVANCED_REPORT'),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(c1rec.man_bf,19,1) = 'T'
   then
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lab.connectas?surl=' || glbx.rndsurl(surl),htf.img(DECS.IMAGE_LOCATION || 'admin/connect.gif',cattributes=>'border=0',calt=>LNG3.ADM_TXT_040),ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.anchor2('lab.connectas?surl=' || glbx.rndsurl(surl),LNG3.ADM_TXT_040,ctarget=>'ADVANCED_REPORT'),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
   if c1rec.is_beta_tester = 'T'
    then
     if substr(c1rec.man_bf,9,1) = 'T'
      then
        htp.tablerowopen;
         htp.tabledata( htf.anchor2( 'glbx.beta_bug',htf.img( DECS.IMAGE_LOCATION || 'admin/bug.gif', cattributes=>'BORDER=0'), ctarget=>'LAB_BOTTOM'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
         htp.tabledata( htf.anchor2( 'glbx.beta_bug',LNG4.AHC_TXT_126 ), cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
        htp.tablerowclose;
     end if;
  end if;
  if substr(c1rec.man_bf,10,1) = 'T'
   then
    htp.tablerowopen;
     htp.tabledata( htf.anchor2(nvl(c1rec.home_page,'glbx.acct_logoff?surl=' || glbx.rndsurl(surl)), htf.img(DECS.IMAGE_LOCATION || 'admin/logoff.gif',cattributes=>'border=0',calt=>LNG.CST_ALT_021 ),ctarget=>'_top'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
     htp.tabledata( htf.anchor2(nvl(c1rec.home_page,'glbx.acct_logoff?surl=' || glbx.rndsurl(surl)), LNG.CST_ALT_021,ctarget=>'_top'),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
  end if;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'HOME',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end home;

procedure stock_report(surl varchar2, prodid in integer, msg in varchar2 default null)
as

 cursor c2( mfid integer, prodid integer ) is select * from product where product_id = prodid and manufacturer_id = mfid;
 cursor c3( prodid integer ) is select * from product_stock_audit where product_id = prodid order by audit_date asc;

 c1rec		manufacturer%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 curr_total	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.EDIT_PRODUCT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, LNG4.AHC_TXT_696,glbx.backimg(surl,owner_id,pfx.text_back,null),'L16',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 open c2(owner_id,prodid);
 fetch c2 into c2rec;
 close c2;
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.ORD_TXT_188 ), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG4.AHC_TXT_699 ), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG4.AHC_TXT_700 ), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG4.AHC_TXT_701 ), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
  htp.tablerowclose;
  curr_total := NULL;
  for c3rec in c3(c2rec.product_id) loop
   htp.tablerowopen;
    htp.tabledata( to_char(c3rec.audit_date, LNG.TSMASK), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
    htp.tabledata( substr(c3rec.activity,4), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
    htp.tabledata( c3rec.stock_adj, cattributes=>pfx.qcbground || ' ALIGN="RIGHT"' );
    if substr(c3rec.activity,1,3) in ('[1]','[2]','[3]','[4]','[5]')
     then
      curr_total := c3rec.stock_adj;
    elsif substr(c3rec.activity,1,3) = '[6]'
     then
      curr_total := curr_total - c3rec.stock_adj;
    elsif substr(c3rec.activity,1,3) = '[7]'
     then
      curr_total := curr_total + c3rec.stock_adj;
    end if;
    htp.tabledata( htf.bold(to_char(curr_total)), cattributes=>pfx.qcbground || ' ALIGN="RIGHT"' );
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.anchor( 'lab.edit_product?surl=' || surl || '&prodid=' || prodid, LNG.ORD_ALT_062 );
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'STOCK_REPORT',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end stock_report;

procedure edit_product(surl varchar2, prodid in integer, msg in varchar2 default null, defpbook in varchar2 default null)
as

 cursor c2(manid integer, prodid integer) is select * from product where product_id = prodid and manufacturer_id = manid;
 cursor c3(prodid integer) is select * from price_book where product_id = prodid order by nvl(valid_until,to_date('01-JAN-1000'));
 --cursor c4(ttype varchar2) is select man_option from man_options where man_type = ttype order by man_option;
 cursor c4(manid integer) is select price_book from manufacturer_price_book where manufacturer_id = manid;
 cursor c5(ttype varchar2) is select product_key from product_keys where man_type = ttype order by product_key;
 cursor c6(prodid integer) is select ph.business_name,ppi.charge from phg_price_item ppi, phg_price_book ppb, photographer ph where ppi.lab_id = prodid and ppb.spb=ppi.spb and ppb.pid = ph.pid;
 cursor c7(manid integer, v_umo varchar2) is
  select um.umo_id, um.audio_original.description, um.extras, um.version, um.photo_thumbnail.width wd, um.photo_thumbnail.height hg, um.umo_type
  from umo um
  where um.aid = manid and
        um.umo_type = 'MANUFACTURER' and
        umo_id = v_umo;
 cursor c8(manid integer) is
  select um.umo_id, um.photo_original_loc
  from umo um
  where um.aid = manid and
        um.umo_type = 'MANUFACTURER'
  order by umo_id;
 cursor c9(mfid integer) is select brand_id, brand_name from brand where is_public = 'T' or (is_public = 'F' and manufacturer_id = mfid) order by brand_name;
 cursor c10 is select product_class from class_of_product order by product_class;

 c1rec		manufacturer%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c7rec		c7%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 tmp		varchar2(2000);
 foundrec	boolean;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.EDIT_PRODUCT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 open c4(owner_id);
 fetch c4 into c4rec;
 if c4%NOTFOUND
  then
   close c4;
   manage_price_books(surl, LNG4.AHC_TXT_273);
 end if;
 close c4;

 open c2(owner_id,prodid);
 fetch c2 into c2rec;
 close c2;
 glbx.main_title( surl, nvl(c2rec.name,nvl(msg,LNG.LAB_TXT_010)),glbx.backimg(surl,owner_id,pfx.text_back,null),'L03',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null then glbx.header_msg( msg ); end if;
 if prodid = '0' then c2rec.product_type := defpbook; end if;

 if nvl(prodid,'0') = '0'
  then
   htp.formopen( 'lab.accept_mfc_product', ctarget=>'LAB_BOTTOM' );
  else
   htp.formopen( 'lab.accept_mfc_product' );
 end if;
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'PRODID', prodid );
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=0');
 htp.tablerowopen;
 htp.p( '<TD>' );
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.LAB_TXT_012),cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext( 'P1', 40, 100, replace(c2rec.name,'"','&#34;' )),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.LAB_TXT_042),cattributes=>pfx.qbground );
     if prodid = '0'
      then
       htp.tabledata( htf.formtext( 'P4', 40, 100, replace(c2rec.manufctr_code,'"','&#34;' )),cattributes=>pfx.qcbground );
      else
       htp.tabledata( htf.bold( replace(c2rec.manufctr_code,'"','&#34;' )),cattributes=>pfx.qcbground );
       htp.formhidden( 'P4', c2rec.manufctr_code );
     end if;
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.LAB_TXT_043),cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext( 'P5', 40, 100, replace(c2rec.xref_mfctr_code,'"','&#34;' )),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.LAB_TXT_044),cattributes=>pfx.qbground );
     if c2rec.is_discounted = 'T'
      then
       htp.tabledata( htf.formcheckbox('P6','T','CHECKED'),cattributes=>pfx.qcbground );
      else
       htp.tabledata( htf.formcheckbox('P6','T'),cattributes=>pfx.qcbground );
     end if;
   htp.tablerowclose;

   tmp := htf.formselectopen( 'P2' );
   for c4rec in c4(c1rec.manufacturer_id) loop
    if c4rec.price_book = c2rec.product_type
     then
      tmp := tmp || htf.formselectoption( c4rec.price_book,'SELECTED' );
     else
      tmp := tmp || htf.formselectoption( c4rec.price_book );
    end if;
   end loop;
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_470),cattributes=>pfx.qbground );
     htp.tabledata( tmp,cattributes=>pfx.qcbground );
   htp.tablerowclose;

   tmp := NULL;
   for c5rec in c5(c1rec.man_type) loop
    if c5rec.product_key = c2rec.product_key
     then
      tmp := tmp || htf.formselectoption( c5rec.product_key,'SELECTED' );
     else
      tmp := tmp || htf.formselectoption( c5rec.product_key );
    end if;
   end loop;
   -- If no mappings yet setup for Products then default to ALL
   if tmp is null
    then
     tmp := htf.formselectopen( 'P3' ) || htf.formselectoption( LNG.ORD_TXT_194 ) || htf.formselectclose;
    else
     tmp := htf.formselectopen( 'P3' ) || tmp || htf.formselectclose;
   end if;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.LAB_TXT_014),cattributes=>pfx.qbground );
     htp.tabledata( tmp,cattributes=>pfx.qcbground );
   htp.tablerowclose;

   tmp := htf.formselectoption( NULL );
   for c10rec in c10 loop
    if c10rec.product_class = c2rec.product_class
     then
      tmp := tmp || htf.formselectoption( c10rec.product_class,'SELECTED' );
     else
      tmp := tmp || htf.formselectoption( c10rec.product_class );
    end if;
   end loop;
   tmp := htf.formselectopen( 'P3C' ) || tmp || htf.formselectclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_402),cattributes=>pfx.qbground );
     htp.tabledata( tmp,cattributes=>pfx.qcbground );
   htp.tablerowclose;

   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG2.FNM_TXT_128),cattributes=>pfx.qbground );
     htp.p( '<TD ' || pfx.qcbground || '>' );
     htp.formselectopen( 'P3B' );
     htp.formselectoption( NULL );
     for c9rec in c9(owner_id) loop
      if c9rec.brand_id = c2rec.brand_id
       then
        htp.formselectoption( c9rec.brand_name, 'SELECTED', cattributes=>'VALUE="' || c9rec.brand_id || '"' );
       else
        htp.formselectoption( c9rec.brand_name, cattributes=>'VALUE="' || c9rec.brand_id || '"' );
      end if;
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_348),cattributes=>pfx.qbground );
     if c2rec.attached_doco is null
      then
       htp.tabledata( htf.formtext( 'PDOCO', 40, 1000, c2rec.attached_doco),cattributes=>pfx.qcbground );
      else
       htp.tabledata( htf.formtext( 'PDOCO', 40, 1000, c2rec.attached_doco) || htf.nl ||
                      htf.anchor2( c2rec.attached_doco, LNG4.AHC_TXT_348, ctarget=>'PRODUCT_DOCUMENTATION'),cattributes=>pfx.qcbground );
     end if;
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_694),cattributes=>pfx.qbground );
     if c2rec.current_stock is null
      then
       htp.tabledata( htf.formtext( 'P11', 40, 100, c2rec.current_stock),cattributes=>pfx.qcbground );
      else
       htp.tabledata( htf.formtext( 'P11', 40, 100, c2rec.current_stock) || htf.nl ||
                      htf.anchor( 'lab.stock_report?surl=' || surl || '&prodid=' || prodid, LNG4.AHC_TXT_696 ),cattributes=>pfx.qcbground );
     end if;
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG5.EXT_TXT_128),cattributes=>pfx.qbground || ' VALIGN="TOP"' );
     htp.tabledata( htf.formtextareaopen( 'P12', 4, 40, cattributes=>'WRAP="VIRTUAL"' ) || c2rec.detailed_desc || htf.formtextareaclose,cattributes=>pfx.qcbground );
   htp.tablerowclose;
 htp.tableclose;
 htp.p( '</TD>' );
 htp.p( '<TD VALIGN="TOP">' );
 if c2rec.umo_id is not null
  then
   open c7( owner_id, c2rec.umo_id );
   fetch c7 into c7rec;
   close c7;
   if c7rec.umo_id is not null
    then
     htp.p( htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c7rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || owner_id || '&parm1=LOGIN_TYPE&parm2=' || ltype,
	 '<IMG BORDER=0 WIDTH=' || c7rec.wd || ' HEIGHT=' || c7rec.hg || ' SRC="' ||
	 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c7rec.umo_id || '&parm1=AID&parm2=' || owner_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c7rec.version ||
	 '" ALT="' || LNG.CST_TXT_183 || '">',ctarget=>'MANUFACTURER_ITEM') );
     htp.nl;
    else
     htp.bold( LNG2.FNM_TXT_089 );
     htp.nl;
   end if;
  else
   htp.bold( LNG2.FNM_TXT_089 );
   htp.nl;
 end if;
 htp.bold( LNG2.FNM_TXT_088 );
 htp.nl;
 htp.formselectopen( 'P10' );
 htp.formselectoption( NULL );
 for c8rec in c8(owner_id) loop
   if c8rec.umo_id = c2rec.umo_id
    then
     htp.formselectoption( c8rec.photo_original_loc, 'SELECTED', cattributes=>'VALUE="' || c8rec.umo_id || '"' );
    else
     htp.formselectoption( c8rec.photo_original_loc, cattributes=>'VALUE="' || c8rec.umo_id || '"' );
   end if;
 end loop;
 htp.formselectclose;
 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 if prodid <> 0
 then
 htp.header(3,LNG4.AHC_TXT_246,'LAB_LEFT');
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.LAB_TXT_015),cattributes=>pfx.qbground );
     htp.tabledata( htf.bold(LNG.LAB_TXT_016),cattributes=>pfx.qbground );
     htp.tabledata( htf.bold(LNG.LAB_TXT_017),cattributes=>pfx.qbground );
     htp.tabledata( htf.bold(LNG.LAB_TXT_018),cattributes=>pfx.qbground );
   htp.tablerowclose;
   for c3rec in c3(c2rec.product_id) loop
    htp.tablerowopen;
     htp.tabledata( htf.bold(to_char(c3rec.price,LNG.MONEY_FORMAT)),cattributes=>pfx.qcbground );
     htp.tabledata( nvl(to_char(c3rec.tax,LNG.MONEY_FORMAT),'&nbsp;'),cattributes=>pfx.qcbground );
     htp.tabledata( nvl(to_char(c3rec.commission,LNG.MONEY_FORMAT),'&nbsp;'),cattributes=>pfx.qcbground );
     htp.tabledata( nvl(to_char(c3rec.valid_until,LNG.MASK),'&nbsp;'),cattributes=>pfx.qcbground );
    htp.tablerowclose;
   end loop;
 htp.tableclose;
 end if;

 htp.nl;
 if prodid = 0
  then
   htp.bold( LNG.LAB_TXT_019); htp.nl;
  else
   htp.bold( LNG.LAB_TXT_020); htp.nl;
 end if;
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.LAB_TXT_021),cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext('P7',20,30),cattributes=>pfx.qcbground );
    htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.LAB_TXT_022),cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext('P8',20,30),cattributes=>pfx.qcbground );
    htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.LAB_TXT_023),cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext('P9',20,30),cattributes=>pfx.qcbground );
    htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 foundrec := FALSE;
 if (prodid = 0)
  then
   htp.formsubmit( 'ACTION',LNG.LAB_BUT_024);
  else
   htp.formsubmit( 'ACTION',LNG.LAB_BUT_025);
   if not foundrec then htp.formsubmit( 'ACTION',LNG.LAB_BUT_026); end if;
 end if;
 htp.formclose;
 htp.nl;
 if prodid = 0
  then
   htp.htmlclose;
   return;
 end if;
 htp.line;
 htp.nl;
 htp.bold( LNG.PHG_TXT_352 );
 htp.nl;
 if substr(c1rec.man_bf,5,1) = 'T'
  then
   htp.anchor2( 'lab.mfc_clr?surl=' || glbx.rndsurl(surl) || '&prodid=' || prodid, LNG2.FNM_TXT_101, ctarget=>'LAB_BOTTOM' );
 end if;
 htp.nl;
 htp.nl;
 htp.line;
 htp.nl;

  htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'lab.product_image', cattributes=>'enctype="multipart/form-data" accept="image/gif,image/jpeg,image/tiff"' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'PRODID', prodid );
  tmp := htf.formselectopen( 'P2' ) || htf.formselectoption( LNG.PHG_ALT_427 );
  tmp := tmp || htf.formselectoption( LNG.PHG_TXT_308,'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_309 ) || htf.formselectoption( LNG.PHG_TXT_310 );
  tmp := tmp || htf.formselectclose;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0');
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.PHG_ALT_422) );
    htp.tabledata( htf.formtext( 'P1', 15, 100 ) );
    htp.tabledata( '&nbsp;');
    htp.tabledata( '&nbsp;');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.PHG_TXT_217 ) );
    htp.tabledata( tmp || htf.formselectclose);
    htp.tabledata( htf.bold(LNG.PHG_TXT_325) );
    htp.tabledata( htf.formtext( 'P3', 5, 100, '150' ) );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.FNM_TXT_142) );
    htp.tabledata( GLBX.UPLOAD_NAME);
    htp.tabledata( htf.bold(LNG3.ADM_TXT_332) );
    htp.p( '<TD>' );
    htp.p( glbx.quality_loop( 'P4', null ) );
    /*
    htp.formselectopen( 'P4' );
    for j in 1..8 loop
     htp.formselectoption( to_char(j) );
    end loop;
    htp.formselectclose;
    */
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;');
    htp.tabledata( htf.formsubmit(null,LNG2.FNM_TXT_088) );
    htp.tabledata( '&nbsp;');
    htp.tabledata( '&nbsp;');
   htp.tablerowclose;
  htp.tableclose;
  htp.formclose;

 htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'EDIT_PRODUCT',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id || ' Product Id:' || prodid);
end edit_product;

procedure product_image(surl in varchar2, prodid in integer, file in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 default 'F')
as

 ltype		varchar2(100);
 stype		integer;
 pid		integer;
 owner_id	integer;
 new_id		integer;
 sts		varchar2(100);
 parm1		ump.parameters;
 parm2		ump.parameters;
 retval		varchar2(100);
 newid_arr	ump.myarray_int;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.PRODUCT_IMAGE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 if file is not null
   then
       parm1(1)  := 'AID';
       parm2(1)  := to_char(owner_id);
       parm1(2)  := 'OBJECT_TYPE';
       parm2(2)  := 'MANUFACTURER';
       parm1(3)  := 'LOAD_FROM_FILE_OR_UPLOAD';
       parm2(3)  := 'UPLOAD';
       parm1(4)  := 'FILE_NAME';
       parm2(4)  := file;
       parm1(5)  := 'STORE_ORIGINAL';
       parm2(5)  := 'FALSE';
       parm1(6)  := 'CREATE_THUMBNAIL';
       parm2(6)  := 'TRUE';
       parm1(7) := 'KEEP_STATUS';
       parm2(7) := 'KEEP';
       parm1(8) := 'ORIGINAL_LOCATION';
       parm2(8) := file;
       parm1(9) := 'PARENT_UMO_ID';
       parm2(9) := NULL;
       parm1(10) := 'SCENE_ID';
       parm2(10) := null;
       parm1(11) := 'UMO_OWNER';
       parm2(11) := 'MANUFACTURER';
       parm1(12) := 'BYPASS_QUOTA_CHECK';
       parm2(12) := 'FALSE';
       parm1(13) := 'PHGR_ID';
       parm2(13) := to_char(pid);
       parm1(14) := 'OWS_NAME';
       parm2(14) := file;
       parm1(15) := 'FILM_NAME';
       parm2(15) := nvl(p1,glbx.extract_fname(file));
       parm1(16) := 'THUMBNAIL_WIDTH';
       parm2(16) := nvl(p3,'100');
       parm1(17) := 'PHOTOGRAPHER';
       parm2(17) := 'TRUE';
       parm1(18) := 'NAME';
       parm2(18) := nvl(p1,glbx.extract_fname(file));
       parm1(19) := 'COMPRESSION';
       parm2(19) := p2;
       parm1(20) := 'CONVERT_TO';
       parm2(20) := 'JPEG';
       parm1(11) := 'THUMBNAIL_QUALITY';
       parm2(11) := p4;
       ump.load_uma(surl,parm1,parm2,retval,newid_arr ); new_id := newid_arr(1);
       update product set umo_id = new_id where product_id = prodid;
       update phg_price_item
        set
         umo_id = new_id
       where lab_id = prodid;
   end if;
  commit;
  edit_product( surl, prodid, retval );
exception when others then
 -- owa_content.delete_document( file );
 glbx.error_details( 'LAB', 'PRODUCT_IMAGE',null,owner_id,errmsg=>sqlerrm);
end product_image;

procedure mfc_clr(surl varchar2, prodid in integer, msg in varchar2 default null)
as

 cursor c2(manid integer, prodid integer) is select * from product where product_id = prodid and manufacturer_id = manid;

 c1rec		manufacturer%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 newval		integer;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.MFC_CLR', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );

 open c2(owner_id,prodid);
 fetch c2 into c2rec;
 close c2;
 select s_mfctr_clearance.nextval into newval from dual;
 insert into mfctr_clearance(mfc_clr_id,manufacturer_id,mfc_description,umo_id,product_doco) values
  (newval,owner_id,c2rec.name,c2rec.umo_id,c2rec.attached_doco);
 commit;
 lab_edit_clearance(surl,newval);
exception when others then
 glbx.error_details( 'LAB', 'MFC_CLR',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id || ' Product Id:' || prodid);
end mfc_clr;

procedure accept_mfc_product(surl varchar2, prodid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p3b in integer, p3c in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2 default 'F', p7 in varchar2, p8 in varchar2, p9 in varchar2, p10 in varchar2, p11 in varchar2, p12 in varchar2, pdoco in varchar2, action in varchar2 )
as

 cursor c1(prodid integer) is select 'x' from part_map where par_product_id = prodid;
 cursor c2(manid integer, pbook varchar2, mfc_code varchar2) is
  select 'x'
  from product
  where manufctr_code = mfc_code and
        manufacturer_id = manid and
        product_type = pbook;
 cursor c3(prodid integer) is select current_stock from product where product_id = prodid;
 cursor c4(prodid integer) is select price from price_book where product_id = prodid and valid_until is null;

 c1rec  	c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 tmp		varchar2(100);
 newval		number;
 nmb1		number;
 nmb2		number;
 nmb3		number;
 nmb4		number;
 pdet		varchar2(4000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.ACCEPT_MFC_PRODUCT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 if (action = LNG.LAB_BUT_026 )
  then
   open c1(prodid);
   fetch c1 into c1rec;
   if c1%FOUND
    then
     close c1;
     if prodid = '0'
      then
       lab_product(surl,prodid,LNG.LAB_TXT_028);
      else
       edit_product(surl,prodid,LNG.LAB_TXT_028);
     end if;
     return;
   end if;
   close c1;
   delete from order_attrib where poid in (select poid from order_product where product_id = prodid and product_id = (select product_id from product where product_id = prodid and manufacturer_id = owner_id));
   delete from order_product where product_id = prodid and product_id = (select product_id from product where product_id = prodid and manufacturer_id = owner_id);
   delete from part_map where chi_product_id = prodid and chi_product_id = (select product_id from product where product_id = prodid and manufacturer_id = owner_id);
   delete from price_book where product_id = prodid and product_id = (select product_id from product where product_id = prodid and manufacturer_id = owner_id);
   update phg_price_item set umo_id = NULL, brand_id = NULL where lab_id = prodid;
   delete from product where product_id = prodid and manufacturer_id = owner_id;
   if prodid = '0'
    then
     lab_product(surl,0,LNG.LAB_TXT_029);
    else
     edit_product(surl,0,LNG.LAB_TXT_029);
   end if;
   return;
 end if;

 tmp := replace(p1,'''''','"');
 if tmp is null then edit_product(surl,prodid,LNG.LAB_TXT_030); return; end if;
 nmb1 := glbx.conv_nmb( p7 );
 nmb2 := glbx.conv_nmb( p8 );
 nmb3 := glbx.conv_nmb( p9 );
 nmb4 := glbx.conv_nmb( p11 );

 if p4 is null
  then
   if prodid = '0'
    then
     lab_product(surl,prodid,LNG.LAB_TXT_066);
    else
     edit_product(surl,prodid,LNG.LAB_TXT_066);
   end if;
   return;
 end if;

 pdet := substr(p12,1,4000);

 if (prodid = '0') and (action = LNG.LAB_BUT_024 )
  then
   open c2(owner_id,p2,p4);
   fetch c2 into c2rec;
   if c2%FOUND
    then
     close c2;
     lab_product(surl,prodid,LNG.LAB_TXT_067);
     return;
   end if;
   select s_product.nextval into newval from dual;
   insert into product(product_id,manufacturer_id,product_type,product_key,manufctr_code,name,xref_mfctr_code,is_discounted,umo_id,brand_id,attached_doco,current_stock,product_class,detailed_desc) values
                      (newval,owner_id,p2,p3,p4,tmp,p5,p6,p10,p3b,pdoco,nmb4,p3c,pdet);
   insert into price_book(price_id,product_id,manufacturer_id,tax,price,valid_until,commission) values
                         (s_price_book.nextval,newval,owner_id,nmb2,nmb1,null,nmb3);
   if nmb4 is not null
    then
     insert into product_stock_audit(product_id,audit_date,stock_adj,activity) values
      (newval,sysdate,nmb4,'[1] Stock Level created on Insert');
   end if;
   commit;
   lab_product(surl,newval,LNG.LAB_TXT_031);
   return;
 end if;

 open c3(prodid);
 fetch c3 into c3rec;
 close c3;

 update product
  set
   name = tmp,
   product_type = p2,
   product_key = p3,
   xref_mfctr_code = p5,
   is_discounted = p6,
   umo_id = p10,
   brand_id = p3b,
   attached_doco = pdoco,
   current_stock = nmb4,
   product_class = p3c,
   detailed_desc = pdet
 where (product_id = prodid) and (manufacturer_id = owner_id);

 if c3rec.current_stock is null and nmb4 is not null
  then
     insert into product_stock_audit(product_id,audit_date,stock_adj,activity) values
      (prodid,sysdate,nmb4,'[2] Stock Level changed from Null to a Value');
 elsif c3rec.current_stock is not null and nmb4 is null
  then
     insert into product_stock_audit(product_id,audit_date,stock_adj,activity) values
      (prodid,sysdate,nmb4,'[3] Stock Level changed to Null from Value:' || c3rec.current_stock);
 elsif c3rec.current_stock is not null and nmb4 is not null and c3rec.current_stock > nmb4
  then
     insert into product_stock_audit(product_id,audit_date,stock_adj,activity) values
      (prodid,sysdate,nmb4,'[4] Stock Level decreased from:' || c3rec.current_stock);
 elsif c3rec.current_stock is not null and nmb4 is not null and c3rec.current_stock < nmb4
  then
     insert into product_stock_audit(product_id,audit_date,stock_adj,activity) values
      (prodid,sysdate,nmb4,'[5] Stock Level increased from:' || c3rec.current_stock);
 end if;

 -- If the image changes then update all related items in the price book
 update phg_price_item
  set
   umo_id = p10,
   brand_id = p3b,
   product_class = p3c
  where lab_id = prodid;

 -- Price Has Changed
 if p7 is not null
  then
   update price_book set valid_until = sysdate where valid_until is null and product_id = prodid and manufacturer_id = owner_id;
   open c4(prodid);
   fetch c4 into c4rec;
   close c4;
   insert into price_book(price_id,product_id,manufacturer_id,tax,price,valid_until,commission) values (s_price_book.nextval,prodid,owner_id,nmb2,nmb1,null,nmb3);
   -- Cascade Update Price if Requested by the Photographer and the price increases
   if c4rec.price < nmb1
    then
     update phg_price_item
     set
      charge = charge * (((nmb1-c4rec.price) / (c4rec.price)) + 1)
     where
      nvl(auto_increase_perc,0) > 0 and
      lab_id = prodid;
   end if;
 end if;
 commit;

 if prodid = '0'
  then
   lab_product(surl,prodid,LNG.LAB_TXT_032);
  else
   edit_product(surl,prodid,LNG.LAB_TXT_032);
 end if;

exception when others then
 glbx.error_details( 'LAB', 'ACCEPT_MFC_PRODUCT',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id || ' Product Id:' || prodid);
end accept_mfc_product;

function get_lab_id( surl varchar2, owner_id in integer)
 return manufacturer%ROWTYPE
as
 cursor c1 is
  select * from manufacturer where manufacturer_id = owner_id;
 c1rec	c1%ROWTYPE;
begin
 open c1;
 fetch c1 into c1rec;
 close c1;
 return( c1rec );
exception when others then
 glbx.error_details( 'LAB', 'GET_LAB_ID',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end get_lab_id;

procedure product_reports( surl varchar2, msg in varchar2 default null)
as
 cursor c3 is select theme_name from theme;
 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 tmp		varchar2(1000);
begin
 oltp.view_report(surl);
 return;
 -- Not used anymore
 /*
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.PRODUCT_REPORTS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.PHG_ALT_432,glbx.backimg(surl,owner_id,pfx.text_back,null),'L04',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active);
 htp.nl;
 htp.ulistopen;
  --htp.listitem(htf.anchor( 'lab.commission_report?surl=' || glbx.rndsurl(surl),LNG.LAB_TXT_034 ));
  --htp.listitem(htf.anchor( 'lab.product_summary?surl=' || glbx.rndsurl(surl),LNG.LAB_TXT_033 ));
  --htp.listitem(htf.anchor( 'lab.heavily_used_phg?surl=' || glbx.rndsurl(surl),LNG.LAB_TXT_035 ));
  --htp.listitem(htf.anchor( 'lab.outstanding_accounts?surl=' || glbx.rndsurl(surl),LNG.LAB_TXT_036 ));
  --htp.listitem(htf.anchor( 'lab.notused_images?surl=' || glbx.rndsurl(surl),LNG2.PFM_TXT_162 ));
  htp.listitem(htf.anchor( 'oltp.view_report?surl=' || glbx.rndsurl(surl),'Reporting Module' ));
 htp.ulistclose;
 htp.nl;
 htp.htmlclose;
 */
exception when others then
 glbx.error_details( 'LAB', 'PRODUCT_REPORTS',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end product_reports;

/*
procedure commission_report(surl varchar2)
as

 cursor c2(manid integer) is select p.pid,p.business_name,p.username from photographer p, manufacturer_photographer mp where mp.manufacturer_id = manid and mp.pid = p.pid order by business_name;

 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 tmp		varchar2(32767);
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.COMMISSION_REPORT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.LAB_TXT_034,glbx.backimg(surl,owner_id,pfx.text_back,null),'L08',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active);
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'lab.accept_commission_report' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG3.ADM_TXT_261),cattributes=>pfx.qbground );
   tmp := htf.formselectopen( 'P1' ) || htf.formselectoption( LNG.PHG_TXT_248, cattributes=>'VALUE="0"' );
   for c2rec in c2(owner_id) loop
    tmp := tmp || htf.formselectoption( c2rec.business_name || ' (' || c2rec.username || ')', cattributes=>'VALUE="' || c2rec.pid || '"' );
   end loop;
   tmp := tmp || htf.formselectclose;
   htp.tabledata( tmp,cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.LAB_TXT_069),cattributes=>pfx.qbground );
   tmp := htf.formselectopen( 'P2' );
   for j in 1999..2020 loop
    tmp := tmp || htf.formselectoption( to_char(j) );
   end loop;
   tmp := tmp || htf.formselectclose;
   htp.tabledata( tmp,cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.LAB_TXT_070),cattributes=>pfx.qbground );
   tmp := htf.formselectopen( 'P3' );
   tmp := tmp || htf.formselectoption( LNG.LAB_TXT_073 ) || htf.formselectoption( LNG.LAB_TXT_074 ) || htf.formselectoption( LNG.LAB_TXT_075 ) || htf.formselectoption( LNG.LAB_TXT_076 ) ||
                 htf.formselectoption( LNG.LAB_TXT_077 ) || htf.formselectoption( LNG.LAB_TXT_078 ) || htf.formselectoption( LNG.LAB_TXT_079 ) || htf.formselectoption( LNG.LAB_TXT_080 ) ||
                 htf.formselectoption( LNG.LAB_TXT_081 ) || htf.formselectoption( LNG.LAB_TXT_082 ) || htf.formselectoption( LNG.LAB_TXT_083 ) || htf.formselectoption( LNG.LAB_TXT_084 );
   tmp := tmp || htf.formselectclose;
   htp.tabledata( tmp,cattributes=>pfx.qcbground );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.LAB_TXT_071),cattributes=>pfx.qbground );
   tmp := htf.formselectopen( 'P4' );
   for j in 1999..2020 loop
    tmp := tmp || htf.formselectoption( to_char(j) );
   end loop;
   tmp := tmp || htf.formselectclose;
   htp.tabledata( tmp,cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.LAB_TXT_072),cattributes=>pfx.qbground );
   tmp := htf.formselectopen( 'P5' );
   tmp := tmp || htf.formselectoption( LNG.LAB_TXT_073 ) || htf.formselectoption( LNG.LAB_TXT_074 ) || htf.formselectoption( LNG.LAB_TXT_075 ) || htf.formselectoption( LNG.LAB_TXT_076 ) ||
                 htf.formselectoption( LNG.LAB_TXT_077 ) || htf.formselectoption( LNG.LAB_TXT_078 ) || htf.formselectoption( LNG.LAB_TXT_079 ) || htf.formselectoption( LNG.LAB_TXT_080 ) ||
                 htf.formselectoption( LNG.LAB_TXT_081 ) || htf.formselectoption( LNG.LAB_TXT_082 ) || htf.formselectoption( LNG.LAB_TXT_083 ) || htf.formselectoption( LNG.LAB_TXT_084 );
   tmp := tmp || htf.formselectclose;
   htp.tabledata( tmp,cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit(null,LNG.LAB_TXT_034);
  htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'COMMISSION_REPORT',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end commission_report;

procedure accept_commission_report(surl varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2)
as
 cursor c2(phgid integer, date_from integer, date_to integer) is
  select *
  from purchase_order
  where pid = phgid and paid_method in ('GIFT','MERCHANT') and is_b2c = 'T' and
        to_number(to_char(date_purchased,'YYYYMM')) >= date_from and
        to_number(to_char(date_purchased,'YYYYMM')) <= date_to
  order by date_purchased;

 --cursor c3(vpoid integer) is select mfc_purch_id from form_orders fo,form_made fm where fo.fsid = fm.fsid and fo.poid = vpoid;
 cursor c4(vpoid integer, disc number) is select sum((round(price*((100-decode(is_discounted,'T',nvl(disc,0),'Y',nvl(disc,0),0))/100),2)*qty)) tot from shopping_basket where poid = vpoid;
 cursor c5(phgid integer) is select * from photographer where pid = phgid;
 --cursor c6(vpoid integer) is select fm.fsid,fm.pay_status from form_orders fo, form_made fm where fo.poid = vpoid and fo.fsid = fm.fsid;
 cursor c7 is select pid from photographer order by username;
 cursor c8(sess_id integer) is select username from login_session ls, customer_account ca where ca.aid = ls.aid and ls.sessid = sess_id;

 c1rec		manufacturer%ROWTYPE;
 --c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 --c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c8rec		c8%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 nmb		integer;
 nmb2		integer;
 dfrom		integer;
 dto		integer;
 lastmonth	varchar2(30);
 tmp		varchar2(1000);
 tcost		number;
 lab_cost	number;
 inter_cost	number;
 gtcost		number;
 glab_cost	number;
 ginter_cost	number;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.ACCEPT_COMMISSION_REPORT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.LAB_TXT_034,glbx.backimg(surl,owner_id,pfx.text_back,null),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active);
 htp.nl;
 nmb := to_number(p1);
 dfrom := to_number(p2 || to_char(to_date(p3,'MONTH'),'MM'));
 dto := to_number(p4 || to_char(to_date(p5,'MONTH'),'MM'));
 htp.p( '<CENTER>' );
 if nmb = 0
  then
   open c7;
 end if;

 loop

 if nmb = 0
  then
   fetch c7 into c7rec;
   if c7%NOTFOUND then close c7; exit; end if;
   nmb2 := c7rec.pid;
  else
   nmb2 := nmb;
 end if;

 open c5(nmb2);
 fetch c5 into c5rec;
 close c5;

 htp.tableopen;
 htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.CST_TXT_004),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(c5rec.business_name),cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.GLB_TXT_076),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(c5rec.username),cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.GLB_TXT_107),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(c5rec.abn_number),cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.CST_TXT_113),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(c5rec.contact_street),cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.CST_TXT_114),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(c5rec.contact_suburb),cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.CST_TXT_115),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(c5rec.contact_city),cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.CST_TXT_118),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(c5rec.contact_pcode),cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_336),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(c5rec.contact_fax),cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_250),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(c5rec.contact_email),cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_237),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(c5rec.work_phone),cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_238),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(c5rec.mobile_phone),cattributes=>pfx.qcbground );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1');
 htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_083),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.GLB_TXT_063),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.PHG_TXT_095),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.ORD_TXT_198),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.ORD_TXT_220),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.CST_TXT_099),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.PHG_TXT_199),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.ORD_TXT_149),cattributes=>pfx.qbground );
 htp.tablerowclose;
 lastmonth := NULL;
 inter_cost := 0;
 gtcost	:= 0;
 glab_cost := 0;
 ginter_cost := 0;
 if p1 <> '0'
  then
   htp.formopen( 'lab.accept_reconcile' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'VFSID', null );
   htp.formhidden( 'PSTS', null );
   htp.formhidden( 'P1', p1 );
   htp.formhidden( 'P2', p2 );
   htp.formhidden( 'P3', p3 );
   htp.formhidden( 'P4', p4 );
   htp.formhidden( 'P5', p5 );
 end if;
 for c2rec in c2(nmb2,dfrom,dto) loop
  if (lastmonth is not null) and (lastmonth <> to_char(c2rec.date_purchased,'MONTH'))
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.ORD_TXT_108)  );
     htp.tabledata( '&nbsp;' );
     htp.tabledata( to_char(gtcost,LNG.MONEY_FORMAT) );
     htp.tabledata( to_char(glab_cost,LNG.MONEY_FORMAT) );
     htp.tabledata( htf.bold(to_char(inter_cost,LNG.MONEY_FORMAT)) );
     htp.tabledata( '&nbsp;' );
     htp.tabledata( '&nbsp;' );
     inter_cost := 0;
     gtcost	:= 0;
     glab_cost := 0;
     ginter_cost := 0;
    htp.tablerowclose;
  end if;

  htp.tablerowopen;
  htp.tabledata( to_char(c2rec.date_purchased,'DD Month YYYY'),cattributes=>pfx.qcbground );
  htp.tabledata( c2rec.poid,cattributes=>pfx.qcbground );
  tcost := nvl(glbx.grand_total_payment(c2rec.poid, include_gift_certificate=>FALSE),0);
  htp.tabledata( to_char(tcost,LNG.MONEY_FORMAT),cattributes=>pfx.qcbground );
  open c4(c2rec.poid, glbx.man_discount( c1rec.manufacturer_id, nmb2 ));
  fetch c4 into c4rec;
  close c4;
  htp.tabledata( nvl(to_char(c4rec.tot,LNG.MONEY_FORMAT),'&nbsp;'),cattributes=>pfx.qcbground );
  lab_cost := round((tcost * (1 - (nvl(c5rec.lab_charge_perc,0)/100))),2) - c4rec.tot;
  lab_cost := nvl(lab_cost,0);
  htp.tabledata( to_char(lab_cost,LNG.MONEY_FORMAT),cattributes=>pfx.qcbground );
  inter_cost := inter_cost + lab_cost;
  lastmonth := to_char(c2rec.date_purchased,'MONTH');
  c8rec.username := '&nbsp;';
  open c8(c2rec.sessid);
  fetch c8 into c8rec;
  close c8;
    htp.tabledata( to_char(c2rec.poid) || htf.nl || c2rec.m_rrn || '(' || c2rec.m_response_code || ')',cattributes=>pfx.qcbground );
    htp.tabledata( c8rec.username,cattributes=>pfx.qcbground );
    htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground );
  --end if;
  --close c6;
  gtcost := gtcost + tcost;
  glab_cost := glab_cost + nvl(c4rec.tot,0);
  ginter_cost := ginter_cost + inter_cost;
  htp.tablerowclose;
 end loop;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.ORD_TXT_108)  );
     htp.tabledata( '&nbsp;' );
     htp.tabledata( to_char(gtcost,LNG.MONEY_FORMAT) );
     htp.tabledata( to_char(glab_cost,LNG.MONEY_FORMAT) );
     htp.tabledata( htf.bold(to_char(inter_cost,LNG.MONEY_FORMAT)) );
     htp.tabledata( '&nbsp;' );
     htp.tabledata( '&nbsp;' );
     htp.tabledata( '&nbsp;' );
     inter_cost := 0;
    htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 if nmb > 0 then exit; end if;
 end loop;

 if p1 <> '0'
  then
   htp.formsubmit( null, LNG.ORD_TXT_135 );
   htp.formclose;
 end if;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'ACCEPT_COMMISSION_REPORT',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id || ' P1:' || p1 || ' P2:' || p2 || ' P3:' || p3 || ' P4:' || p4 || ' P5:' || p5);
end accept_commission_report;
*/

/*
procedure accept_reconcile( surl varchar2,p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, vfsid in GLBX.MYARRAY, psts in GLBX.MYARRAY )
as
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.ACCEPT_RECONCILE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;


 commit;
 accept_commission_report(surl, p1,p2,p3,p4,p5);
exception when others then
 glbx.error_details( 'LAB', 'ACCEPT_RECONCILE',errmsg=>sqlerrm );
end accept_reconcile;
*/

procedure product_summary( surl varchar2 )
as

 cursor c2(manid integer) is
  select ph.business_name,ca.account_name,count('x') tot
  from customer_account ca, photographer ph, workflow_state_options ws, workflow_state_options ws1, purchase_order po, shopping_basket sb
  where ph.pid = po.pid and
        sb.lab_id = manid and
        sb.poid = po.poid and
        ca.pid = ph.pid and
        po.status = ws1.order_option and
        ws.status_priority_id >= ws1.status_priority_id and
        ws.work_state = 0 and
        ws1.work_state = 0
  group by ph.business_name,ca.account_name;

 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 tmp		varchar2(1000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.PRODUCT_SUMMARY', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.LAB_TXT_033,glbx.backimg(surl,owner_id,pfx.text_back,null),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active);
 htp.nl;
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG3.ADM_TXT_261),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.CST_TXT_031),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.ORD_TXT_143),cattributes=>pfx.qbground );
  htp.tablerowclose;
  for c2rec in c2(owner_id) loop
   htp.tablerowopen;
    htp.tabledata( c2rec.business_name,cattributes=>pfx.qcbground );
    htp.tabledata( c2rec.account_name,cattributes=>pfx.qcbground );
    htp.tabledata( c2rec.tot,cattributes=>pfx.qcbground );
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'PRODUCT_SUMMARY',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end product_summary;

/*
procedure heavily_used_phg(surl varchar2)
as


  cursor c2(manid integer) is
  select ph.business_name, count(distinct ca.account_name) tot_cust, sum(nvl(sb.photo_cost,0)) as sum_cust
  from customer_account ca, photographer ph, workflow_state_options ws, workflow_state_options ws1, purchase_order po, shopping_basket sb
  where ph.pid = po.pid and
        ca.pid = ph.pid and
        sb.poid = po.poid and
        sb.lab_id = manid and
        nvl(payment_received,'F') = 'T' and
        po.status = ws1.order_option and
        ws.status_priority_id >= ws1.status_priority_id and
        ws.work_state = 0 and
        ws1.work_state = 0
  group by ph.business_name
  order by sum_cust desc;

 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 tmp		varchar2(1000);
 tot		number;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.HEAVILY_USED_PHG', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.LAB_TXT_033,glbx.backimg(surl,owner_id,pfx.text_back,null),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active);
 htp.nl;
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG3.ADM_TXT_261),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.LAB_TXT_039),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.LAB_TXT_040),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.LAB_TXT_041),cattributes=>pfx.qbground );
  htp.tablerowclose;
  tot := 0;
  for c2rec in c2(owner_id) loop
   htp.tablerowopen;
    tot := tot + c2rec.sum_cust;
    htp.tabledata( c2rec.business_name,cattributes=>pfx.qcbground );
    htp.tabledata( c2rec.tot_cust,cattributes=>pfx.qcbground );
    htp.tabledata( to_char(c2rec.sum_cust,LNG.MONEY_FORMAT),cattributes=>pfx.qcbground );
    htp.tabledata( to_char(round(c2rec.sum_cust/c2rec.tot_cust,2),LNG.MONEY_FORMAT),cattributes=>pfx.qcbground );
   htp.tablerowclose;
  end loop;
    htp.tablerowopen;
     htp.tabledata( '&nbsp;',cattributes=>pfx.qbground );
     htp.tabledata( htf.bold(LNG.CST_TXT_138),cattributes=>pfx.qbground );
     htp.tabledata( htf.bold(to_char(tot,LNG.MONEY_FORMAT)),cattributes=>pfx.qbground );
     htp.tabledata( '&nbsp;',cattributes=>pfx.qbground );
    htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formopen( 'LAB.PRODUCT_REPORTS');
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formsubmit(null,LNG.LAB_TXT_037);
  htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'HEAVILY_USED_PHG',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end heavily_used_phg;
*/
/*
procedure outstanding_accounts(surl varchar2)
as
 cursor c2(manid integer) is
  select ph.business_name, ca.account_name
  from manufacturer mf, form_made fm, customer_account ca, photographer ph
  where manufacturer_id = manid and
        mf.username = fm.formname and
        ph.pid = fm.pid and
        ca.aid = fm.aid and
        pay_status <> LNG.ORD_TXT_145 and
        date_received is null and
        date_due is not null and
        sysdate > date_due
  order by ph.pid,ca.aid;

 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 tmp		varchar2(1000);
 tot		number;
 foundrec	boolean;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.OUTSTANDING_ACCOUNTS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.LAB_TXT_036,glbx.backimg(surl,owner_id,pfx.text_back,null),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active);
 htp.nl;
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG3.ADM_TXT_261),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.CST_TXT_031),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.ORD_TXT_143),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.ORD_TXT_149),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.ORD_TXT_153),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.ORD_TXT_154),cattributes=>pfx.qbground );
  htp.tablerowclose;
  tot := 0;
  foundrec := FALSE;
  for c2rec in c2(owner_id) loop
   tot := tot + nvl(c2rec.total_charge,0);
   foundrec := TRUE;
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'ord.labs_edit_frm?surl=' || glbx.rndsurl(surl) || '&vfsid=' || c2rec.fsid,c2rec.business_name),cattributes=>pfx.qcbground );
    htp.tabledata( c2rec.account_name,cattributes=>pfx.qcbground );
    htp.tabledata( to_char(c2rec.total_charge,LNG.MONEY_FORMAT),cattributes=>pfx.qcbground );
    htp.tabledata( c2rec.pay_status,cattributes=>pfx.qcbground );
    htp.tabledata( to_char(c2rec.date_due,LNG.MASK),cattributes=>pfx.qcbground );
    htp.tabledata( to_char(trunc(sysdate-c2rec.date_due)),cattributes=>pfx.qcbground );
   htp.tablerowclose;
  end loop;
  if foundrec
   then
    htp.tablerowopen;
     htp.tabledata( '&nbsp;',cattributes=>pfx.qbground );
     htp.tabledata( htf.bold(LNG.CST_TXT_138),cattributes=>pfx.qbground );
     htp.tabledata( htf.bold(to_char(tot,LNG.MONEY_FORMAT)),cattributes=>pfx.qbground );
     htp.tabledata( '&nbsp;',cattributes=>pfx.qbground );
     htp.tabledata( '&nbsp;',cattributes=>pfx.qbground );
     htp.tabledata( '&nbsp;',cattributes=>pfx.qbground );
    htp.tablerowclose;
  htp.tableclose;
  else
  htp.tableclose;
  htp.nl;
  htp.bold( LNG.ORD_TXT_155 );
 end if;

  htp.nl;
  htp.formopen( 'LAB.PRODUCT_REPORTS');
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formsubmit(null,LNG.LAB_TXT_037);
  htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'OUTSTANDING_ACCOUNTS',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end outstanding_accounts;
*/

procedure reverse_engineer( surl varchar2, p1 in varchar2, p2 in varchar2 default 'F' )
as
 /*
 Col1: MFC Code
 Col2: Name
 Col3: Cross Ref Code
 Col4: Price
 Col5: Is Discounted
 Col6: Type
 Col7: Key
 Col8: Brand
 Col9: Product Class
 Col10: Stock Level
 */

 cursor c1(mfid integer, mfcode varchar2, nme varchar2, ptype varchar2) is
  select rowid,product_id,current_stock
  from product
  where manufacturer_id = mfid and
        upper(manufctr_code) = mfcode and
        upper(product_type) = ptype and
        name = nme;

 cursor c2(bname varchar2) is select brand_id from brand where upper(brand_name) = upper(bname);
 cursor c5(ttype varchar2, ptype varchar2) is select product_key from product_keys where man_type = ttype and upper(product_key) = upper(ptype);

 c1rec		manufacturer%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c1prod		rowid;
 fl		UTL_FILE.FILE_TYPE;
 bfr		varchar2(4000);
 cols		GLBX.MYARRAY;
 ctr		integer;
 x		integer;
 y		integer;
 delim		varchar2(10);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 nmb		number;
 nmb1		number;
 nmb2		integer;
 bid		integer;
 prodid		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 inf_ctr	integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.REVERSE_ENGINEER', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG4.AHC_TXT_433,glbx.backimg(surl,owner_id,pfx.text_back,null),helpid=>'L22',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.bold( LNG4.AHC_TXT_504 || ':' || glbx.extract_master_parameter('REPORTS_DIRECTORY') || '-' || nvl(p1,'price.csv') );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold('Col1:') || ' ' || LNG.LAB_TXT_042,cattributes=>pfx.qbground );
   htp.tabledata( htf.bold('Col2:') || ' ' || LNG.LAB_TXT_052,cattributes=>pfx.qbground );
   htp.tabledata( htf.bold('Col3:') || ' ' || LNG.LAB_TXT_053,cattributes=>pfx.qbground );
   htp.tabledata( htf.bold('Col4:') || ' ' || LNG.LAB_TXT_054,cattributes=>pfx.qbground );
   htp.tabledata( htf.bold('Col5:') || ' ' || LNG.LAB_TXT_055,cattributes=>pfx.qbground );
   htp.tabledata( htf.bold('Col6:') || ' ' || LNG.LAB_TXT_056,cattributes=>pfx.qbground );
   htp.tabledata( htf.bold('Col7:') || ' ' || LNG.LAB_TXT_057,cattributes=>pfx.qbground );
   htp.tabledata( htf.bold('Col8:') || ' ' || LNG4.AHC_TXT_524,cattributes=>pfx.qbground );
   htp.tabledata( htf.bold('Col9:') || ' ' || LNG4.AHC_TXT_523,cattributes=>pfx.qbground );
   htp.tabledata( htf.bold('Col10:') || ' ' || LNG4.AHC_TXT_609,cattributes=>pfx.qbground );
   htp.tabledata( htf.bold('Col11:') || ' ' || LNG5.EXT_TXT_129,cattributes=>pfx.qbground );
  htp.tablerowclose;

 fl := utl_file.fopen( nvl(c1rec.load_directory,glbx.extract_master_parameter('REPORTS_DIRECTORY')), nvl(p1,'price.csv'), 'r' );
 if p2 = 'T' then utl_file.get_line(fl,bfr); end if;
 ctr := 0;
 inf_ctr := 0;
 loop
   cols.delete;
   cols(1) := NULL;
   cols(2) := NULL;
   cols(3) := NULL;
   cols(4) := NULL;
   cols(5) := 'F';
   cols(6) := 'REPRINT';
   cols(7) := 'All';
   cols(8) := NULL;
   cols(9) := 'GOODS';
   cols(10) := NULL;
   cols(11) := NULL;
  begin
    utl_file.get_line(fl,bfr);
   exception
    when others then exit;
  end;
  inf_ctr := inf_ctr + 1;
  if inf_ctr > 10000 then exit; end if;
  -- htp.p( bfr ); htp.nl;

  if rtrim(ltrim(bfr)) is not null
   then
    ctr := 0;
    y := 1;
    loop

      -- Y is pointing to the current bfr starting position
      if substr(bfr,y,1) = '"'
       then
        delim := '",';
        y := y + 1;
      elsif substr(bfr,y,1) is null
       then
        exit;
       else
        delim := ',';
      end if;

      x := instr( bfr || ',', delim, y );

      -- This shouldn't happen, but check for just in case
      if x = 0
       then
        ctr := ctr + 1;
        cols(ctr) := substr(bfr,y);
        exit;
      end if;

      ctr := ctr + 1;
      cols(ctr) := substr(bfr,y,(x-y));

      y := x + length(delim);

      if ctr > 100 then exit; end if;

    end loop;

   nmb := glbx.conv_nmb(trim(cols(4)));

  -- Brand
  open c2(cols(8));
  fetch c2 into bid;
  if c2%NOTFOUND and (cols(8) is not null)
   then
    select max(brand_id) into bid from brand;
    bid := nvl(bid,0) + 1;
    insert into brand(brand_id,brand_name) values (bid,cols(8));
  end if;
  if cols(8) is null then bid := NULL; end if;
  close c2;

  -- See if Product Type Exists. If not, set it to be All
  c5rec.product_key := 'All';
  open c5(c1rec.man_type,cols(7));
  fetch c5 into c5rec;
  close c5;
  cols(7) := c5rec.product_key;

  -- Stock Level. If invalid number set to NULL
  begin nmb2 := to_number(cols(10)); exception when others then nmb2 := NULL; end;

  if cols(1) is not null
    then
     open c1(owner_id,upper(cols(1)),cols(2),upper(cols(6)));
     fetch c1 into c1prod,prodid,nmb1;
     if c1%FOUND
      then
       close c1;
       update product
        set xref_mfctr_code = cols(3),
            is_discounted = decode( cols(5),'t','T','T','T','Y','T','y','T','F'),
            product_type = substr(nvl(cols(6),product_type),1,100),
            product_key = substr(nvl(cols(7),product_key),1,20),
            brand_id = bid,
            product_class = upper(nvl(cols(9),product_class)),
            current_stock = nvl(nmb2,current_stock),
            detailed_desc = cols(11)
        where rowid = c1prod;
       update price_book
        set valid_until = sysdate
        where product_id = prodid and valid_until is null;
       insert into price_book(price_id,product_id,manufacturer_id,tax,price,valid_until,commission) values
        (s_price_book.nextval,prodid,owner_id,null,nmb,null,null);
       if nmb2 is not null
        then
           insert into product_stock_audit(product_id,audit_date,stock_adj,activity) values
	     (prodid,sysdate,nmb,'[9] Stock Level reset on Mass Load from:' || nmb1 || ' to ' || nmb);
       end if;
      else
       close c1;
       select s_product.nextval into prodid from dual;
       insert into product(product_id,manufacturer_id,product_type,product_key,name,manufctr_code,xref_mfctr_code,is_discounted,brand_id,product_class,current_stock,detailed_desc) values
        (prodid,owner_id,
         substr(replace(cols(6),'"',''),1,100),
         substr(replace(cols(7),'"',''),1,20),
         replace(cols(2),'"',''),
         replace(cols(1),'"',''),
         replace(cols(3),'"',''),
         decode( cols(5),'t','T','T','T','Y','T','y','T','F'),
         bid,
         upper(replace(cols(9),'"','')),
         nmb2,
         replace(cols(11),'"',''));
       insert into price_book(price_id,product_id,manufacturer_id,tax,price,valid_until,commission) values
        (s_price_book.nextval,prodid,owner_id,null,nmb,null,null);
       if nmb2 is not null
        then
           insert into product_stock_audit(product_id,audit_date,stock_adj,activity) values
	     (prodid,sysdate,nmb,'[8] Stock Level create on Mass Load:' || nmb);
       end if;
     end if;
     htp.tablerowopen;
      htp.tabledata( replace(cols(1),'"',''),cattributes=>pfx.qcbground );
      htp.tabledata( replace(cols(2),'"',''),cattributes=>pfx.qcbground );
      htp.tabledata( replace(cols(3),'"',''),cattributes=>pfx.qcbground );
      htp.tabledata( replace(cols(4),'"','') || '-' || nmb,cattributes=>pfx.qcbground );
      htp.tabledata( replace(cols(5),'"',''),cattributes=>pfx.qcbground );
      htp.tabledata( replace(cols(6),'"',''),cattributes=>pfx.qcbground );
      htp.tabledata( replace(cols(7),'"',''),cattributes=>pfx.qcbground );
      htp.tabledata( replace(cols(8),'"',''),cattributes=>pfx.qcbground );
      htp.tabledata( upper(replace(cols(9),'"','')),cattributes=>pfx.qcbground );
      htp.tabledata( nvl(to_char(nmb2),'&nbsp;'),cattributes=>pfx.qcbground );
      htp.tabledata( replace(cols(11),'"',''),cattributes=>pfx.qcbground );
     htp.tablerowclose;
   end if;
  end if;

 end loop;
 htp.tableclose;

 insert into manufacturer_price_book(manufacturer_id,price_book)
  select distinct manufacturer_id,nvl(product_type,'None')
  from product
  where manufacturer_id = owner_id and
        product_type not in (select price_book from manufacturer_price_book where manufacturer_id = owner_id);

 commit;
 utl_file.fclose(fl);
 htp.nl;
 htp.nl;
 htp.anchor( 'lab.lab_product?surl=' || surl, LNG4.AHC_TXT_505 );
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 begin utl_file.fclose(fl); exception when others then null; end;
 htp.htmlopen;
  htp.bold( LNG.LAB_TXT_050 || ': ' || p1 ); htp.nl;
  htp.italic( sqlerrm ); htp.nl;
  rollback;
 htp.htmlclose;
end reverse_engineer;

procedure lab_clearance( surl varchar2, msg in varchar2 default null)
as
 cursor c1(mfid integer) is select * from mfctr_clearance where manufacturer_id = mfid order by nvl(dump_date,expiry_date) desc;

 c2rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.LAB_CLEARANCE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c2rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c2rec.theme_name );
 glbx.main_title( surl, replace(LNG2.FNM_TXT_052,'Manufacturer',c2rec.manufacturer_title),glbx.backimg(surl,owner_id,pfx.text_back,null),'L09',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_105 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG2.FNM_TXT_053 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG.PHG_TXT_079 ),cattributes=>pfx.qbground );
  htp.tablerowclose;
 for c1rec in c1( owner_id ) loop
  htp.tablerowopen;
   if sysdate > nvl(c1rec.dump_date,c1rec.expiry_date)
    then
     htp.tabledata( htf.anchor( 'lab.lab_edit_clearance?surl=' || glbx.rndsurl(surl) || '&mcid=' || c1rec.mfc_clr_id, c1rec.mfc_description || ' [' || LNG3.ADM_TXT_709 || ']'),cattributes=>pfx.qcbground );
    else
     htp.tabledata( htf.anchor( 'lab.lab_edit_clearance?surl=' || glbx.rndsurl(surl) || '&mcid=' || c1rec.mfc_clr_id, c1rec.mfc_description ),cattributes=>pfx.qcbground );
   end if;
   htp.tabledata( to_char( nvl(c1rec.dump_date,c1rec.expiry_date),LNG.MASK),cattributes=>pfx.qcbground );
   htp.tabledata( htf.anchor( 'lab.view_clearance_order?surl=' || glbx.rndsurl(surl) || '&mcid=' || c1rec.mfc_clr_id,LNG.PHG_ALT_128),cattributes=>pfx.qcbground );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.anchor( 'lab.lab_edit_clearance?surl=' || glbx.rndsurl(surl) || '&mcid=0', LNG2.FNM_TXT_055 );
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'LAB_CLEARANCE',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end lab_clearance;

procedure lab_edit_clearance( surl varchar2, mcid in integer, msg in varchar2 default null)
as

 cursor c1( mfid integer, mfcid integer) is select * from mfctr_clearance where manufacturer_id = mfid and mfc_clr_id = mfcid;
 cursor c3( phgid integer, mid integer ) is select pid from mfctr_target_phg where mfc_clr_id = mid and pid = phgid;
 cursor c4 is select pid,username from photographer order by username;
 cursor c5(mfcid integer) is select * from mfctr_clearance_items where mfc_clr_id = mfcid order by min_amount;
 cursor c7(manid integer, v_umo varchar2) is
  select um.umo_id, um.audio_original.description, um.extras, um.version, um.photo_thumbnail.width wd, um.photo_thumbnail.height hg, um.umo_type
  from umo um
  where um.aid = manid and
        um.umo_type = 'MANUFACTURER' and
        umo_id = v_umo;

 c1rec		c1%ROWTYPE;
 c2rec		manufacturer%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c7rec		c7%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.LAB_EDIT_CLEARANCE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c2rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c2rec.theme_name );
 glbx.main_title( surl, LNG2.FNM_TXT_052,glbx.backimg(surl,owner_id,pfx.text_back,null),'L10',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'lab.accept_edit_clearance' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'MCID', mcid );
 open c1(owner_id,mcid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   c1rec.dump_date := sysdate + 100;
 end if;
 close c1;
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=0');
 htp.tablerowopen;
 htp.p( '<TD>' );
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_105 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.formtext( 'P1', 30, 100, c1rec.mfc_description),cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.FNM_TXT_061 ),cattributes=>pfx.qbground );
   htp.p( '<TD ' || pfx.qcbground || '>' );
   htp.formselectopen( 'P2A' );
   for j in 1..31 loop
    if to_number(to_char(c1rec.dump_date,'DD')) = j
     then
      htp.formselectoption( to_char(j), 'SELECTED' );
     else
      htp.formselectoption( to_char(j) );
    end if;
   end loop;
   htp.formselectclose;
   htp.formselectopen( 'P2B' );
   if to_number(to_char(c1rec.dump_date,'MM')) = 1 then htp.formselectoption( LNG.LAB_TXT_073, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_073 ); end if;
   if to_number(to_char(c1rec.dump_date,'MM')) = 2 then htp.formselectoption( LNG.LAB_TXT_074, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_074 ); end if;
   if to_number(to_char(c1rec.dump_date,'MM')) = 3 then htp.formselectoption( LNG.LAB_TXT_075, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_075 ); end if;
   if to_number(to_char(c1rec.dump_date,'MM')) = 4 then htp.formselectoption( LNG.LAB_TXT_076, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_076 ); end if;
   if to_number(to_char(c1rec.dump_date,'MM')) = 5 then htp.formselectoption( LNG.LAB_TXT_077, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_077 ); end if;
   if to_number(to_char(c1rec.dump_date,'MM')) = 6 then htp.formselectoption( LNG.LAB_TXT_078, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_078 ); end if;
   if to_number(to_char(c1rec.dump_date,'MM')) = 7 then htp.formselectoption( LNG.LAB_TXT_079, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_079 ); end if;
   if to_number(to_char(c1rec.dump_date,'MM')) = 8 then htp.formselectoption( LNG.LAB_TXT_080, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_080 ); end if;
   if to_number(to_char(c1rec.dump_date,'MM')) = 9 then htp.formselectoption( LNG.LAB_TXT_081, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_081 ); end if;
   if to_number(to_char(c1rec.dump_date,'MM')) = 10 then htp.formselectoption( LNG.LAB_TXT_082, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_082 ); end if;
   if to_number(to_char(c1rec.dump_date,'MM')) = 11 then htp.formselectoption( LNG.LAB_TXT_083, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_083 ); end if;
   if to_number(to_char(c1rec.dump_date,'MM')) = 12 then htp.formselectoption( LNG.LAB_TXT_084, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_084 ); end if;
   htp.formselectclose;
   htp.formselectopen( 'P2C' );
   for j in 2000..2010 loop
    if to_number(to_char(c1rec.dump_date,'YYYY')) = j
     then
      htp.formselectoption( to_char(j), 'SELECTED' );
     else
      htp.formselectoption( to_char(j) );
    end if;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG4.AHC_TXT_348),cattributes=>pfx.qbground );
   htp.tabledata( htf.formtextareaopen( 'P3', 5, 40 ) ||  c1rec.detailed_description || htf.formtextareaclose,cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.FNM_TXT_062 ) || htf.nl || 'e.g. http://www.abc.com/doco/proddoco.pdf',cattributes=>pfx.qbground );
     if c1rec.product_doco is null
      then
       htp.tabledata( htf.formtext( 'PDOCO', 40, 1000, c1rec.product_doco),cattributes=>pfx.qcbground );
      else
       htp.tabledata( htf.formtext( 'PDOCO', 40, 1000, c1rec.product_doco) || htf.nl ||
                      htf.anchor2( c1rec.product_doco, LNG4.AHC_TXT_348, ctarget=>'PRODUCT_DOCUMENTATION'),cattributes=>pfx.qcbground );
     end if;
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.PBK_TXT_044 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG2.PBK_TXT_045 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG2.FNM_TXT_077 ),cattributes=>pfx.qbground );
  htp.tablerowclose;
  for c5rec in c5(mcid) loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'PH1',10,20,c5rec.min_amount),cattributes=>pfx.qcbground );
   htp.tabledata( htf.formtext( 'PH2',10,20,c5rec.max_amount),cattributes=>pfx.qcbground );
   htp.tabledata( htf.formtext( 'PH3',10,20,to_char(c5rec.price_per_unit,LNG.MONEY_FORMAT)),cattributes=>pfx.qcbground );
  htp.tablerowclose;
  end loop;
  for j in 1..5 loop
   htp.tablerowopen;
    htp.tabledata( htf.formtext( 'PH1',10,20,null),cattributes=>pfx.qcbground );
    htp.tabledata( htf.formtext( 'PH2',10,20,null),cattributes=>pfx.qcbground );
    htp.tabledata( htf.formtext( 'PH3',10,20,null),cattributes=>pfx.qcbground );
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.p( '</TD>' );
 htp.p( '<TD VALIGN="TOP">' );
 if c1rec.umo_id is not null
  then
   open c7( owner_id, c1rec.umo_id );
   fetch c7 into c7rec;
   close c7;
   if c7rec.umo_id is not null
    then
     htp.p( htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c7rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || owner_id || '&parm1=LOGIN_TYPE&parm2=' || ltype,
	 '<IMG BORDER=0 WIDTH=' || c7rec.wd || ' HEIGHT=' || c7rec.hg || ' SRC="' ||
	 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c7rec.umo_id || '&parm1=AID&parm2=' || owner_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c7rec.version ||
	 '" ALT="' || LNG.CST_TXT_183 || '">',ctarget=>'MANUFACTURER_ITEM') );
     htp.nl;
    else
     htp.bold( LNG2.FNM_TXT_089 );
     htp.nl;
   end if;
  else
   htp.bold( LNG2.FNM_TXT_089 );
   htp.nl;
 end if;
 htp.nl;
 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.bold( LNG2.FNM_TXT_065 );
 htp.nl;
 htp.formhidden( 'P4', null );
 htp.formselectopen( 'P4', null, 5, cattributes=>'MULTIPLE' );
  for c4rec in c4 loop
   open c3(c4rec.pid,mcid);
   fetch c3 into c3rec;
   if c3%FOUND
    then
     htp.formselectoption( c4rec.username, 'SELECTED', cattributes=>'VALUE="' || c4rec.pid || '"' );
    else
     htp.formselectoption( c4rec.username, cattributes=>'VALUE="' || c4rec.pid || '"' );
   end if;
   close c3;
  end loop;
 htp.formselectclose;
 htp.nl;
 htp.nl;
 if mcid = '0'
  then
   htp.formsubmit( 'ACTION', LNG2.FNM_TXT_056 );
  else
   htp.formsubmit( 'ACTION', LNG2.FNM_TXT_057 );
 end if;
 htp.formsubmit( 'ACTION', LNG2.FNM_TXT_064 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'LAB_EDIT_CLEARANCE',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end lab_edit_clearance;

procedure accept_edit_clearance(surl varchar2, mcid in integer, p1 in varchar2, p2a in varchar2, p2b in varchar2, p2c in varchar2, p3 in varchar2, pdoco in varchar2, action in varchar2, p4 in GLBX.MYARRAY, ph1 in GLBX.MYARRAY, ph2 in GLBX.MYARRAY, ph3 in GLBX.MYARRAY )
as

 cursor c4(phgid integer) is select * from photographer where pid = phgid;

 c2rec		manufacturer%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 longdesc	varchar2(4000);
 insdate	date;
 newid		integer;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;
 nmb1		integer;
 nmb2		integer;
 nmb3		number;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.ACCEPT_EDIT_CLEARANCE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 if action = LNG2.FNM_TXT_064
  then
   lab_clearance(surl);
   return;
 end if;
 insdate := to_date(p2a || '-' || p2b || '-' || p2c, 'DD-MM-YYYY' );
 c2rec := get_lab_id( surl, owner_id );
 longdesc := glbx.censor(p3,4000);
 if mcid = 0
  then
   select s_mfctr_clearance.nextval into newid from dual;
   insert into mfctr_clearance(mfc_clr_id,manufacturer_id,mfc_description,dump_date,detailed_description,product_doco)
    values
    (newid,owner_id,p1,insdate,longdesc,pdoco);
  else
   newid := mcid;
   update mfctr_clearance
    set
     mfc_description = p1,
     dump_date = insdate,
     detailed_description = longdesc,
     product_doco = pdoco
   where
    mfc_clr_id = newid and
    manufacturer_id = owner_id;
 end if;
 delete from mfctr_target_phg where mfc_clr_id = newid;
 for j in p4.first..p4.last loop
  if p4(j) is not null
   then
    insert into mfctr_target_phg(mfc_clr_id,pid) values (newid,p4(j));
    open c4(p4(j));
    fetch c4 into c4rec;
    close c4;
    if c4rec.contact_email is not null
     then
      gcode(1) := 'MAN_NAME';
      gparam(1) := c2rec.name;
      gcode(2) := 'DUMP_DATE';
      gparam(2) := to_char(insdate,LNG.TSMASK);
      gcode(3) := 'DESCRIPTION';
      gparam(3) := p1;
      gcode(4) := 'SIGNATURE';
      gparam(4) := glbx.extract_master_parameter('MAIL SIGNATURE');
      glbx.send( gcode, gparam, 'mfc_clearance.tmp', p_to=>c4rec.contact_email, p_subj=>LNG2.FNM_TXT_066  || c2rec.name, p_from=>nvl(c2rec.contact_email,glbx.extract_master_parameter('MAIL_FROM')),ltype=>ltype,own_id=>owner_id, scode=>'MC1');
    end if;
  end if;
 end loop;
 delete from mfctr_clearance_items where mfc_clr_id = newid;
 for j in ph1.first..ph1.last loop
  begin nmb1 := to_number(ph1(j)); exception when others then nmb1 := null; end;
  begin nmb2 := to_number(ph2(j)); exception when others then nmb2 := null; end;
  nmb3 := glbx.conv_nmb( ph3(j) );
  if not (nmb1 is null and nmb2 is null)
   then
    insert into mfctr_clearance_items(mfc_clr_id,min_amount,max_amount,price_per_unit) values (newid, nvl(nmb1,1),nvl(nmb2,999999),nvl(nmb3,0));
  end if;
 end loop;
 commit;
 lab_edit_clearance(surl, newid, LNG2.FNM_TXT_063);

exception when others then
 glbx.error_details( 'LAB', 'ACCEPT_EDIT_CLEARANCE',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end accept_edit_clearance;

procedure attach(surl varchar2, p1 in varchar2 default 'F', p2 in varchar2 default '3')
as

 cursor c1(mfid integer, p1 varchar2) is select * from product where manufacturer_id = mfid and ((p1 = 'T') or (p1 = 'F' and umo_id is null));
 cursor c3(manid integer, nm varchar2) is
  select umo_id,photo_original_loc
  from umo um
  where aid = manid and
        umo_type = 'MANUFACTURER' and
        upper(photo_original_loc) like '%' || nm || '.%';
 cursor c4(manid integer, nm varchar2, nm2 varchar2) is
  select 1 id, umo_id,photo_original_loc
  from umo um
  where aid = manid and
        umo_type = 'MANUFACTURER' and
        upper(photo_original_loc) like '%' || nm || '.%'
 union all
  select 2, umo_id,photo_original_loc
  from umo um
  where aid = manid and
        umo_type = 'MANUFACTURER' and
        upper(photo_original_loc) like '%' || nm2 || '.%'
 union all
  select 3, umo_id,photo_original_loc
  from umo um
  where aid = manid and
        umo_type = 'MANUFACTURER' and
        upper(photo_original_loc) like '%' || nm || '%'
 union all
  select 4, umo_id,photo_original_loc
  from umo um
  where aid = manid and
        umo_type = 'MANUFACTURER' and
        upper(photo_original_loc) like '%' || decode(instr(nm,' '),0,nm,rtrim(substr(nm,1,instr(nm,' ')))) || '%'
 union all
  select 5, umo_id,photo_original_loc
  from umo um
  where aid = manid and
        umo_type = 'MANUFACTURER' and
        upper(photo_original_loc) like '%' || substr(nm,1,4) || '%'
  order by 1;

 c2rec		manufacturer%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.ATTACH', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c2rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c2rec.theme_name );
 glbx.main_title( surl, LNG2.FNM_TXT_096,glbx.backimg(surl,owner_id,pfx.text_back,null),'L11',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active);
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.FNM_TXT_096 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG2.FNM_TXT_097 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG2.FNM_TXT_098 ),cattributes=>pfx.qbground );
  htp.tablerowclose;
  for c1rec in c1(owner_id,p1) loop
  htp.tablerowopen;
   htp.tabledata( htf.bold( c1rec.name ),cattributes=>pfx.qcbground );
   if p2 = '1'
    then
     open c3(owner_id,DECS.UNIX_OR_NT || upper(c1rec.name));
     fetch c3 into c3rec;
     if c3%FOUND
      then
       htp.tabledata( c3rec.photo_original_loc,cattributes=>pfx.qcbground );
       htp.tabledata( LNG2.FNM_TXT_099,cattributes=>pfx.qcbground );
       update product
        set
         umo_id = c3rec.umo_id
       where product_id = c1rec.product_id;
      update phg_price_item
       set
        umo_id = c3rec.umo_id
       where lab_id = c1rec.product_id;
      else
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground );
       htp.tabledata( LNG2.FNM_TXT_100,cattributes=>pfx.qcbground );
     end if;
     close c3;
   elsif p2 = '2'
    then
     open c3(owner_id,DECS.UNIX_OR_NT || upper(c1rec.xref_mfctr_code));
     fetch c3 into c3rec;
     if c3%FOUND
      then
       htp.tabledata( c3rec.photo_original_loc,cattributes=>pfx.qcbground );
       htp.tabledata( LNG2.FNM_TXT_099,cattributes=>pfx.qcbground );
       update product
        set
         umo_id = c3rec.umo_id
       where product_id = c1rec.product_id;
      update phg_price_item
       set
        umo_id = c3rec.umo_id
       where lab_id = c1rec.product_id;
      else
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground );
       htp.tabledata( LNG2.FNM_TXT_100,cattributes=>pfx.qcbground );
     end if;
     close c3;
   elsif p2 = '3'
    then
     open c4(owner_id,upper(c1rec.name),upper(c1rec.xref_mfctr_code));
     fetch c4 into c4rec;
     if c4%FOUND
      then
       htp.tabledata( c4rec.photo_original_loc,cattributes=>pfx.qcbground );
       htp.tabledata( LNG2.FNM_TXT_099 || ' (' || c4rec.id || ')',cattributes=>pfx.qcbground );
       update product
        set
         umo_id = c4rec.umo_id
       where product_id = c1rec.product_id;
      update phg_price_item
       set
        umo_id = c3rec.umo_id
       where lab_id = c1rec.product_id;
      else
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground );
       htp.tabledata( LNG2.FNM_TXT_100,cattributes=>pfx.qcbground );
     end if;
     close c4;
   end if;

   commit;
  htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'ATTACH',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end attach;

/*
procedure notused_images( surl varchar2 )
as

 cursor c2( mfctr_id integer) is
  select umo_id,um.photo_thumbnail.width width,um.photo_thumbnail.height height,um.version
  from umo um
  where umo_type = 'MANUFACTURER' and
        aid = mfctr_id and
        not exists (select 'x' from product p where manufacturer_id = mfctr_id and p.umo_id = um.umo_id)
  order by umo_id;

 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 tmp		varchar2(32767);
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.COMMISSION_REPORT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG2.PFM_TXT_162,glbx.backimg(surl,owner_id,pfx.text_back,null),'L08',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active);
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'lab.delete_images' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'P1', null );
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
  for c2rec in c2( owner_id ) loop
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P1', c2rec.umo_id, 'CHECKED' ), cattributes=>pfx.qbground );
   htp.tabledata( htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || owner_id || '&parm1=LOGIN_TYPE&parm2=' || ltype,
	 '<IMG BORDER=0 WIDTH=' || c2rec.width || ' HEIGHT=' || c2rec.height || ' SRC="' ||
	 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=AID&parm2=' || owner_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c2rec.version ||
	 '" ALT="' || LNG.CST_TXT_183 || '">',ctarget=>'MANUFACTURER_ITEM') );
  htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.formsubmit(null,LNG2.PFM_TXT_163);
  htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'NOTUSED_IMAGES',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end notused_images;
*/

procedure delete_images( surl varchar2, p1 in GLBX.MYARRAY )
as

 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr		integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.DELETE_IMAGES', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 ctr := 0;
 for j in p1.first..p1.last loop
  delete from umo
   where
    umo_id = p1(j) and
    aid = owner_id and
    umo_type = 'MANUFACTURER';
  ctr := ctr + 1;
 end loop;
 commit;
 product_reports( surl, ctr || '-' || LNG2.PFM_TXT_163 );

exception when others then
 glbx.error_details( 'LAB', 'NOTUSED_IMAGES',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end delete_images;

procedure view_tenders(surl varchar2, msg in varchar2 default null)
as

 cursor c2( mid integer ) is select t.quote_reference,t.tender_id,t.date_locked,t.date_created,t.postcode from tender_mfctr tm, tender t where tm.tender_id = t.tender_id and manufacturer_id = mid order by t.date_locked desc ;
 cursor c3( mid integer, tid integer ) is select count('x') tot from tender_mfctr_item where manufacturer_id = mid and tender_id = tid and successful_bid = 'T';
 cursor c6( acid integer, vtid integer ) is select count('x') tot from tender_mfctr_item tmi, tender_item ti where ti.tender_id = vtid and ti.item_id = tmi.item_id and tmi.tender_id = vtid and tmi.successful_bid = 'T';
 cursor c7( acid integer, vtid integer ) is select count('x') tot from tender_item ti where ti.tender_id = vtid;

 c1rec		manufacturer%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LAB.VIEW_TENDERS', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := get_lab_id( surl, owner_id );
  pfx := glbx.get_thm( c1rec.theme_name );
  glbx.main_title( surl, LNG4.AHC_TXT_001,glbx.backimg(surl,owner_id,pfx.text_back,null),'L12',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_002 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.GLB_TXT_078 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.ORD_TXT_153 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.CST_TXT_118 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( '&nbsp;' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;
   for c2rec in c2( owner_id ) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'lab.modify_tender?surl=' || glbx.rndsurl(surl) || '&tid=' || c2rec.tender_id, c2rec.quote_reference), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(c2rec.date_created,LNG.MASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(c2rec.date_locked,LNG.MASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( c2rec.postcode, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    open c3(owner_id,c2rec.tender_id);
    fetch c3 into c3rec;
    close c3;
    if c2rec.date_locked <= trunc(sysdate)
     then
      htp.tabledata( htf.bold( LNG4.AHC_TXT_019 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      open c6( owner_id, c2rec.tender_id );
      fetch c6 into c6rec;
      close c6;
      open c7( owner_id, c2rec.tender_id );
      fetch c7 into c7rec;
      close c7;
      if (c6rec.tot = c7rec.tot and c7rec.tot > 0)
       then
        htp.tabledata( htf.bold( LNG4.AHC_TXT_282 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
    end if;
   htp.tablerowclose;
   end loop;
   htp.tableclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;

exception when others then
 glbx.error_details( 'LAB', 'VIEW_TENDERS', errmsg=>sqlerrm);
end view_tenders;

procedure modify_tender(surl varchar2, tid in varchar2, msg in varchar2 default null)
as

 cursor c1( mid integer, tid integer ) is select * from tender where tender_id = tid and tender_id in (select tender_id from tender_mfctr where tender_id = tid and manufacturer_id = mid);
 cursor c3( mid integer, tid integer ) is
  select ti.item_id,tmi.price_per_unit,tmi.shipping,tmi.successful_bid, ti.disp_description , ti.max_price, ti.qty
  from tender_mfctr_item  tmi, tender_item ti
  where tmi.tender_id = tid and
        tmi.manufacturer_id = mid  and
        tmi.tender_id = ti.tender_id and
        tmi.item_id = ti.item_id
  order by tmi.item_id;
 cursor c6( acid integer, vtid integer ) is select count('x') tot from tender_mfctr_item tmi, tender_item ti where ti.tender_id = vtid and ti.item_id = tmi.item_id and tmi.tender_id = vtid and tmi.successful_bid = 'T';
 cursor c7( acid integer, vtid integer ) is select count('x') tot from tender_item ti where ti.tender_id = vtid;

 c1rec		c1%ROWTYPE;
 c2rec		manufacturer%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MODIFY_TENDER', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  open c1(owner_id, tid );
  fetch c1 into c1rec;
  close c1;
  c2rec := get_lab_id( surl, owner_id );
  pfx := glbx.get_thm( c2rec.theme_name );
  open c1(owner_id, tid );
  fetch c1 into c1rec;
  close c1;
  glbx.main_title( surl, LNG4.AHC_TXT_030 || ':' || c1rec.quote_reference,glbx.backimg(surl,owner_id,pfx.text_back,null),'L13',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if c1rec.tender_details is not null
   then
    htp.tableopen( cattributes=>'width="40%" cellpadding=0 cellspacing=0 border=0' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.CST_TXT_118 || ' : ' || c1rec.postcode) );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( c1rec.tender_details );
     htp.tablerowclose;
    htp.tableclose;
   else
    htp.bold( LNG.CST_TXT_118 || ' : ' || c1rec.postcode  );
    htp.nl;
  end if;
  if msg is not null then glbx.header_msg( msg ); end if;
  if c1rec.date_locked > trunc(sysdate)
   then
    htp.formopen( 'lab.accept_tender' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl) );
    htp.formhidden( 'TID', tid );
    htp.formhidden( 'ITID', null );
    htp.formhidden( 'P1', tid );
    htp.formhidden( 'P2', tid );
  end if;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_031 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_009 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG2.FNM_TXT_078 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_074 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG2.FNM_TXT_170 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_011 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_075 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   open c6( owner_id, c1rec.tender_id );
   fetch c6 into c6rec;
   close c6;
   open c7( owner_id, c1rec.tender_id );
   fetch c7 into c7rec;
   close c7;

   for c3rec in c3( owner_id, tid ) loop

    htp.tablerowopen;
   if c3rec.successful_bid is null and c3rec.price_per_unit is null
    then
     htp.tabledata( htf.bold( LNG4.AHC_TXT_022 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   elsif c3rec.successful_bid is null and c3rec.price_per_unit is not null
    then
     htp.tabledata( htf.bold( LNG4.AHC_TXT_037 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   elsif c3rec.successful_bid = 'T'
    then
     htp.tabledata( htf.bold( LNG.PHG_TXT_045 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   else
     htp.tabledata( htf.bold( LNG.PHG_TXT_046 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   end if;
    htp.tabledata( htf.bold( c3rec.disp_description ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    if c1rec.date_locked > trunc(sysdate) and not(c6rec.tot = c7rec.tot and c7rec.tot > 0)
     then
       htp.formhidden( 'ITID', c3rec.item_id );
       htp.tabledata( htf.formtext( 'P1', 20, 30, to_char(c3rec.price_per_unit,LNG.MONEY_FORMAT) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
       htp.tabledata( htf.bold( c3rec.qty ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.formtext( 'P2', 20, 30, to_char(nvl(c3rec.shipping,0),LNG.MONEY_FORMAT) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    else
     htp.tabledata( htf.bold( to_char(c3rec.price_per_unit,LNG.MONEY_FORMAT) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( c3rec.qty ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( to_char(nvl(c3rec.shipping,0),LNG.MONEY_FORMAT) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   end if;
   if c3rec.max_price < nvl(c3rec.price_per_unit,0)
    then
     htp.tabledata( to_char(c3rec.max_price,LNG.MONEY_FORMAT) || '-' || htf.bold( LNG4.AHC_TXT_073),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    else
     htp.tabledata( to_char(c3rec.max_price,LNG.MONEY_FORMAT),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   end if;
   if c3rec.price_per_unit is not null
    then
     htp.tabledata( to_char( (c3rec.price_per_unit * c3rec.qty) + nvl(c3rec.shipping,0) ,LNG.MONEY_FORMAT),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
    else
     htp.tabledata( '&nbsp;', LNG.MONEY_FORMAT,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
   end if;
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  if c1rec.date_locked > trunc(sysdate) and not(c6rec.tot = c7rec.tot and c7rec.tot > 0)
   then
    htp.formsubmit( 'ACTION', LNG4.AHC_TXT_036 );
    htp.formsubmit( 'ACTION', LNG4.AHC_TXT_020 );
    htp.formclose;
  end if;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'MODIFY_TENDER', errmsg=>sqlerrm);
end modify_tender;

procedure accept_tender( surl in varchar2, tid in integer, action in varchar2, itid in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb1		number;
 nmb2		number;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_TENDER', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  for j in itid.first..itid.last loop
   if itid(j) is not null
    then
      begin nmb1 := to_number(p1(j)); exception when others then begin nmb1 := to_number(p1(j),LNG.MONEY_FORMAT); exception when others then nmb1 := 0; end; end;
      begin nmb2 := to_number(p2(j)); exception when others then begin nmb2 := to_number(p2(j),LNG.MONEY_FORMAT); exception when others then nmb2 := 0; end; end;
      update tender_mfctr_item
       set
        price_per_unit = nmb1,
        shipping = nmb2
       where tender_id = tid and
             item_id = itid(j) and
             manufacturer_id = owner_id;
    end if;
  end loop;

  commit;

  if action = LNG4.AHC_TXT_036
   then
    modify_tender( surl, tid, LNG4.AHC_TXT_026 );
   else
    view_tenders( surl, LNG4.AHC_TXT_026 );
  end if;

exception when others then
 glbx.error_details( 'LAB', 'ACCEPT_TENDER', errmsg=>sqlerrm);
end accept_tender;

procedure view_clearance_order(surl varchar2, mcid in integer, msg in varchar2 default null)
as

 cursor c1( mid integer, mcid integer ) is select * from mfctr_clearance where mfc_clr_id = mcid and manufacturer_id = mid;
 cursor c3( mid integer, mcid integer ) is
  select *
  from mfctr_clearance_items mci
  where mfc_clr_id = mcid
  order by min_amount;
 cursor c4( mid integer, mcid integer ) is select * from shopping_basket where isgallery = 'C' and manufctr_code = mcid and lab_id = mid order by poid;
 cursor c5( vpoid integer ) is select * from purchase_order where poid = vpoid;

 c1rec		c1%ROWTYPE;
 c2rec		manufacturer%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LAB.VIEW_CLEARANCE_ORDER', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  open c1(owner_id, mcid );
  fetch c1 into c1rec;
  close c1;
  c2rec := get_lab_id( surl, owner_id );
  pfx := glbx.get_thm( c2rec.theme_name );
  open c1(owner_id, mcid );
  fetch c1 into c1rec;
  close c1;
  glbx.main_title( surl, LNG4.AHC_TXT_248,glbx.backimg(surl,owner_id,pfx.text_back,null),'L14',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.PHG_TXT_094 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG.PHG_TXT_083 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG.ORD_TXT_185 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   for c4rec in c4( owner_id, mcid ) loop
    open c5(c4rec.poid);
    fetch c5 into c5rec;
    close c5;
    htp.tablerowopen;
    htp.tabledata( htf.bold( c4rec.poid ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(c5rec.date_purchased,LNG.TSMASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( c4rec.qty,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    htp.p( c5rec.sendto_name ); htp.nl;
    htp.p( c5rec.sendto_street ); htp.nl;
    htp.p( c5rec.sendto_suburb ); htp.nl;
    htp.p( c5rec.sendto_city ); htp.nl;
    htp.p( c5rec.sendto_postcode ); htp.nl;
    htp.p( c5rec.sendto_country ); htp.nl;
    if c5rec.customer_comment is not null
     then
      htp.p( c5rec.customer_comment ); htp.nl;
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'VIEW_CLEARANCE_ORDER', errmsg=>sqlerrm);
end view_clearance_order;

procedure mng_brands(surl varchar2, msg in varchar2 default null )
as

 cursor c1(mfid integer) is select * from brand where is_public = 'T' or (is_public = 'F' and manufacturer_id = mfid) order by brand_name;

 c2rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LAB.MNG_BRANDS', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  c2rec := get_lab_id( surl, owner_id );
  pfx := glbx.get_thm( c2rec.theme_name );

  glbx.main_title( surl, LNG3.ADM_TXT_875,glbx.backimg(surl,owner_id,pfx.text_back,null),'L15',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  htp.formopen( 'lab.accept_mng_brands' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl) );
  if msg is not null then glbx.header_msg( msg ); end if;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG2.PFM_TXT_160 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_876 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.formhidden( 'P0', null );
   htp.formhidden( 'P1', null );
   for c1rec in c1( owner_id ) loop
    htp.tablerowopen;
     if c1rec.is_public = 'T'
      then
       htp.tabledata( htf.bold( LNG.PHG_TXT_045 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.bold( c1rec.brand_name ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      else
       htp.tabledata( htf.bold( LNG.PHG_TXT_046 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.formhidden( 'P0', c1rec.brand_id );
       htp.tabledata( htf.formtext( 'P1', 30, 100, c1rec.brand_name ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     end if;
   htp.tablerowclose;
  end loop;
  for j in 1..5 loop
   htp.tablerowopen;
       htp.tabledata( htf.bold( LNG.PHG_TXT_046 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.formhidden( 'P0', '0' );
       htp.tabledata( htf.formtext( 'P1', 30, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, LNG3.ADM_TXT_878 );
  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'MNG_BRANDS', errmsg=>sqlerrm);
end mng_brands;

procedure accept_mng_brands(surl varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY )
as

 cursor c1(mfid integer, bid integer) is select * from brand where is_public = 'F' and manufacturer_id = mfid and brand_id = bid;
 cursor c2 is select max(brand_id) mx from brand;
 cursor c3(iname varchar2, mfid integer) is select 'x' from brand where brand_name = iname and (is_public = 'T' or (is_public = 'F' and manufacturer_id = mfid));

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LAB.ACCEPT_MNG_BRANDS', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  for j in p0.first..p0.last loop
   if p0(j) is not null
    then
     open c1(owner_id,p0(j));
     fetch c1 into c1rec;
     close c1;
     if p1(j) is null
      then
       delete from brand where brand_id = p0(j) and is_public = 'F' and manufacturer_id = owner_id;
     elsif p0(j) = '0'
      then
       open c3(upper(p1(j)),owner_id);
       fetch c3 into c3rec;
       if c3%FOUND
        then
         close c3;
         mng_brands( surl, LNG4.AHC_TXT_373 || ':' || p1(j) );
         return;
       end if;
       close c3;
       open c2;
       fetch c2 into c2rec;
       close c2;
       if c2rec.mx is null
        then
         c2rec.mx := 1;
        else
         c2rec.mx := c2rec.mx + 1;
       end if;
       insert into brand(brand_id,brand_name,is_public,manufacturer_id) values (c2rec.mx,upper(p1(j)),'F',owner_id);
     elsif upper(p1(j)) = c1rec.brand_name
      then
       update brand set brand_name = upper(p1(j)) where brand_id = p0(j) and is_public = 'F' and manufacturer_id = owner_id;
     else
       -- New Brand Name. Make sure it does not already exist.
       open c3(upper(p1(j)),owner_id);
       fetch c3 into c3rec;
       if c3%FOUND
        then
         close c3;
         mng_brands( surl, LNG4.AHC_TXT_373 || ':' || p1(j) );
         return;
        else
         close c3;
       end if;
       update brand set brand_name = upper(p1(j)) where brand_id = p0(j) and is_public = 'F' and manufacturer_id = owner_id;
     end if;
   end if;
  end loop;

  commit;
  mng_brands( surl, LNG4.AHC_TXT_374 );

exception when others then
 glbx.error_details( 'LAB', 'ACCEPT_MNG_BRANDS', errmsg=>sqlerrm);
end accept_mng_brands;

procedure attention_tasks(surl varchar2, sorton in integer default 1, msg in varchar2 default null, selectall in varchar2 default null, lvpoid in integer default null, byp in char default null, shoplist in glbx.myarray, sts in integer default null, ws in integer default null )
as

 cursor c1(mfid integer, sorton integer) is
  select status_priority, date_purchased, shopping_id, poid, status_workflow, status_at_step, priority_of_item, photo_size, name, qty, estimated_due_date, value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number
  from
  (
  select sb.status_priority, p.date_purchased,shopping_id,sb.poid,sb.status_workflow,status_at_step,priority_of_item, photo_size, name, qty, estimated_due_date, lpad(' ',1000,' ') value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number
  from shopping_basket sb, purchase_order p, workflow_set ws
  where status_mfctr = mfid and
        sb.status_workflow = ws.status_workflow and
        sb.status in ('10','20','30') and
        p.poid = sb.poid
 union all
  select sb.status_priority,p.date_purchased,thread_id shopping_id,sb.poid,sb.status_workflow,status_at_step,priority_of_item, photo_size, name, qty, estimated_due_date, lpad(' ',1000,' ') value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number
  from shopping_basket_thread sb, purchase_order p, workflow_set ws
  where status_mfctr = mfid and
        sb.status_workflow = ws.status_workflow and
        sb.status in ('10','20','30') and
        p.poid = sb.poid
  )
  order by decode(sorton,1,lpad(to_char(poid),10,'0') || lpad(to_char(shopping_id),10,'0'),
                         2,upper(photo_size),
                         3,lpad(to_char(qty),10,'0'),
                         4,to_char(date_purchased,'YYYYMMDDHH24MI'),
                         5,to_char(estimated_due_date,'YYYYMMDDHH24MI'),
                         6,lpad(to_char(priority_of_item),10,'0'),
                         7,upper(workflow_name),
                         8,upper(value));

 cursor c1m(mfid integer, attribid integer, sorton integer) is
  select status_priority, date_purchased, shopping_id, poid, status_workflow, status_at_step, priority_of_item, photo_size, name, qty, estimated_due_date, value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number
  from
  (
  select sb.status_priority, p.date_purchased,shopping_id,sb.poid,sb.status_workflow,status_at_step,priority_of_item, photo_size, name, qty, estimated_due_date, ua.value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number
  from shopping_basket sb, purchase_order p, umo_attribute ua, workflow_set ws
  where status_mfctr = mfid and
        ua.attribute_id = attribid and
        ua.umo_id = sb.phid and
        sb.status_workflow = ws.status_workflow and
        position_id = 1 and
        sb.status in ('10','20','30') and
        p.poid = sb.poid
 union all
  select sb.status_priority,p.date_purchased,thread_id shopping_id,sb.poid,sb.status_workflow, status_at_step, priority_of_item, photo_size, name, qty, estimated_due_date, ua.value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number
  from shopping_basket_thread sb, purchase_order p, umo_attribute ua, workflow_set ws
  where status_mfctr = mfid and
        ua.attribute_id = attribid and
        ua.umo_id = sb.phid and
        sb.status_workflow = ws.status_workflow and
        position_id = 1 and
        sb.status in ('10','20','30') and
        p.poid = sb.poid
  )
  order by decode(sorton,1,lpad(to_char(poid),10,'0') || lpad(to_char(shopping_id),10,'0'),
                         2,upper(photo_size),
                         3,lpad(to_char(qty),10,'0'),
                         4,to_char(date_purchased,'YYYYMMDDHH24MI'),
                         5,to_char(estimated_due_date,'YYYYMMDDHH24MI'),
                         6,lpad(to_char(priority_of_item),10,'0'),
                         7,upper(workflow_name),
                         8,upper(value));

 cursor c1k(mfid integer, shpid integer, sorton integer) is
  select status_priority, date_purchased, shopping_id, poid, status_workflow, status_at_step, priority_of_item, photo_size, name, qty, estimated_due_date, value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number
  from
  (
  select sb.status_priority, p.date_purchased,shopping_id,sb.poid,sb.status_workflow,status_at_step,priority_of_item, photo_size, name, qty, estimated_due_date, lpad(' ',1000,' ') value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number
  from shopping_basket sb, purchase_order p, workflow_set ws
  where status_mfctr = mfid and
        sb.status_workflow = ws.status_workflow and
        sb.status in ('10','20','30') and
        p.poid = sb.poid and
        sb.shopping_id = shpid
 union all
  select sb.status_priority,p.date_purchased,thread_id shopping_id,sb.poid,sb.status_workflow,status_at_step,priority_of_item, photo_size, name, qty, estimated_due_date, lpad(' ',1000,' ') value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number
  from shopping_basket_thread sb, purchase_order p, workflow_set ws
  where status_mfctr = mfid and
        sb.status_workflow = ws.status_workflow and
        sb.status in ('10','20','30') and
        p.poid = sb.poid and
        sb.shopping_id = shpid
  )
  order by decode(sorton,1,lpad(to_char(poid),10,'0') || lpad(to_char(shopping_id),10,'0'),
                         2,upper(photo_size),
                         3,lpad(to_char(qty),10,'0'),
                         4,to_char(date_purchased,'YYYYMMDDHH24MI'),
                         5,to_char(estimated_due_date,'YYYYMMDDHH24MI'),
                         6,lpad(to_char(priority_of_item),10,'0'),
                         7,upper(workflow_name),
                         8,upper(value));

 cursor c1a(mfid integer, sorton integer) is
  select status_workflow, workflow_name, priority_of_item, cnt, sm, cp
  from
  (
  select sb.status_workflow, ws.workflow_name, priority_of_item, count('x') cnt, sum(nvl(sb.qty,0)) sm, count(distinct p.poid) cp
  from shopping_basket sb, purchase_order p, workflow_set ws
  where status_mfctr = mfid and
        ws.status_workflow = sb.status_workflow and
        sb.status in ('10','20','30') and
        p.poid = sb.poid
  group by sb.status_workflow, ws.workflow_name, sb.priority_of_item
 union all
  select sb.status_workflow, ws.workflow_name, priority_of_item, count('x') cnt, sum(nvl(sb.qty,0)) sm, count(distinct p.poid) cp
  from shopping_basket_thread sb, purchase_order p, workflow_set ws
  where status_mfctr = mfid and
        ws.status_workflow = sb.status_workflow and
        sb.status in ('10','20','30') and
        p.poid = sb.poid
  group by sb.status_workflow, ws.workflow_name, sb.priority_of_item
 )
 order by workflow_name, priority_of_item desc;

 cursor c3(mfid integer) is
  select srm.srfq_id,date_made,respond_by, mfctr_comments, product_id, request_made
  from simple_rfq_mfctr srm, simple_rfq sr
  where manufacturer_id = mfid and
        sr.srfq_id = srm.srfq_id and
        status = LNG.ORD_TXT_120 and
        respond_by >= sysdate
  order by date_made desc;

 cursor c4(prodid integer) is select manufctr_code from product where product_id = prodid;
 cursor c6(attribid integer) is select * from umo_attributes where attribute_id = attribid;

 cursor c7(mfid integer) is
  select poid, estimated_due_date, date_purchased, sendto_name, count(*) cnt, sum(nvl(qty,1)) sm
  from
  (
  select sb.status_priority, p.date_purchased,shopping_id,sb.poid,sb.status_workflow,status_at_step,priority_of_item, photo_size, name, qty, estimated_due_date, lpad(' ',1000,' ') value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number, sendto_name
  from shopping_basket sb, purchase_order p, workflow_set ws
  where status_mfctr = mfid and
        sb.status_workflow = ws.status_workflow and
        sb.status in ('10','20','30') and
        p.poid = sb.poid
 union all
  select sb.status_priority, p.date_purchased,shopping_id,sb.poid,sb.status_workflow,status_at_step,priority_of_item, photo_size, name, qty, estimated_due_date, lpad(' ',1000,' ') value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number, sendto_name
  from shopping_basket_thread sb, purchase_order p, workflow_set ws
  where status_mfctr = mfid and
        sb.status_workflow = ws.status_workflow and
        sb.status in ('10','20','30') and
        p.poid = sb.poid
  )
  group by poid, estimated_due_date, date_purchased, sendto_name;

 cursor c7p(mfid integer) is
  select poid, estimated_due_date, date_purchased, sendto_name, count(*) cnt, sum(nvl(qty,1)) sm
  from
  (
  select /*+ ALL_ROWS LEADING(RMP) */
    sb.status_priority, p.date_purchased,shopping_id,sb.poid,sb.status_workflow,status_at_step,priority_of_item, photo_size, name, qty, estimated_due_date, lpad(' ',1000,' ') value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number, sendto_name
  from shopping_basket sb, purchase_order p, workflow_set ws, report_multi_parameters rmp
  where status_mfctr = mfid and
        sb.status_workflow = ws.status_workflow and
        sb.status in ('10','20','30') and
        p.poid = sb.poid and
        substr(rmp.parameter_value,1,1) = 'S' and
        sb.shopping_id = substr(rmp.parameter_value,2)
 union all
  select /*+ ALL_ROWS LEADING(RMP) */
    sb.status_priority, p.date_purchased,shopping_id,sb.poid,sb.status_workflow,status_at_step,priority_of_item, photo_size, name, qty, estimated_due_date, lpad(' ',1000,' ') value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number, sendto_name
  from shopping_basket_thread sb, purchase_order p, workflow_set ws, report_multi_parameters rmp
  where status_mfctr = mfid and
        sb.status_workflow = ws.status_workflow and
        sb.status in ('10','20','30') and
        p.poid = sb.poid and
        substr(rmp.parameter_value,1,1) = 'W' and
        sb.shopping_id = substr(rmp.parameter_value,2)
  )
  group by poid, estimated_due_date, date_purchased, sendto_name;

 cursor c8(vpoid integer, mfid integer, sorton integer, ws integer, sts integer) is
  select status_priority, date_purchased, shopping_id, poid, status_workflow, status_at_step, priority_of_item, photo_size, name, qty, estimated_due_date, value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number
  from
  (
  select sb.status_priority, p.date_purchased,shopping_id,sb.poid,sb.status_workflow,status_at_step,priority_of_item, photo_size, name, qty, estimated_due_date, lpad(' ',1000,' ') value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number
  from shopping_basket sb, purchase_order p, workflow_set ws1
  where status_mfctr = mfid and
        sb.status_workflow = ws1.status_workflow and
        sb.status in ('10','20','30') and
        (ws1.status_workflow = ws or ws is null) and
        (nvl(priority_of_item,0) = nvl(sts,0) or sts is null) and
        p.poid = sb.poid and
        p.poid = vpoid
 union all
  select sb.status_priority,p.date_purchased,thread_id shopping_id,sb.poid,sb.status_workflow,status_at_step,priority_of_item, photo_size, name, qty, estimated_due_date, lpad(' ',1000,' ') value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number
  from shopping_basket_thread sb, purchase_order p, workflow_set ws1
  where status_mfctr = mfid and
        sb.status_workflow = ws1.status_workflow and
        sb.status in ('10','20','30') and
        (ws1.status_workflow = ws or ws is null) and
        (nvl(priority_of_item,0) = nvl(sts,0) or sts is null) and
        p.poid = sb.poid and
        p.poid = vpoid
  )
order by decode(sorton,1,lpad(to_char(poid),10,'0') || lpad(to_char(shopping_id),10,'0'),
                         2,upper(photo_size),
                         3,lpad(to_char(qty),10,'0'),
                         4,to_char(date_purchased,'YYYYMMDDHH24MI'),
                         5,to_char(estimated_due_date,'YYYYMMDDHH24MI'),
                         6,lpad(to_char(priority_of_item),10,'0'),
                         7,upper(workflow_name),
                         8,upper(value));

 cursor c8m(vpoid integer, mfid integer, attribid integer, sorton integer, ws integer, sts integer) is
  select status_priority, date_purchased, shopping_id, poid, status_workflow, status_at_step, priority_of_item, photo_size, name, qty, estimated_due_date, value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number
  from
  (
  select sb.status_priority, p.date_purchased,shopping_id,sb.poid,sb.status_workflow,status_at_step,priority_of_item, photo_size, name, qty, estimated_due_date, ua.value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number
  from shopping_basket sb, purchase_order p, umo_attribute ua, workflow_set ws1
  where status_mfctr = mfid and
        ua.attribute_id = attribid and
        ua.umo_id = sb.phid and
        sb.status_workflow = ws1.status_workflow and
        position_id = 1 and
        sb.status in ('10','20','30') and
        p.poid = sb.poid and
        (ws1.status_workflow = ws or ws is null) and
        (nvl(priority_of_item,0) = nvl(sts,0) or sts is null) and
        p.poid = vpoid
 union all
  select sb.status_priority,p.date_purchased,thread_id shopping_id,sb.poid,sb.status_workflow, status_at_step, priority_of_item, photo_size, name, qty, estimated_due_date, ua.value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number
  from shopping_basket_thread sb, purchase_order p, umo_attribute ua, workflow_set ws1
  where status_mfctr = mfid and
        ua.attribute_id = attribid and
        ua.umo_id = sb.phid and
        sb.status_workflow = ws1.status_workflow and
        position_id = 1 and
        sb.status in ('10','20','30') and
        p.poid = sb.poid and
        (ws1.status_workflow = ws or ws is null) and
        (nvl(priority_of_item,0) = nvl(sts,0) or sts is null) and
        p.poid = vpoid
  )
order by decode(sorton,1,lpad(to_char(poid),10,'0') || lpad(to_char(shopping_id),10,'0'),
                         2,upper(photo_size),
                         3,lpad(to_char(qty),10,'0'),
                         4,to_char(date_purchased,'YYYYMMDDHH24MI'),
                         5,to_char(estimated_due_date,'YYYYMMDDHH24MI'),
                         6,lpad(to_char(priority_of_item),10,'0'),
                         7,upper(workflow_name),
                         8,upper(value));

 c1rec		c1%ROWTYPE;
 c1mrec		c1m%ROWTYPE;
 c2rec		manufacturer%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7prec		c7p%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr		integer;
 shpid		integer;
 foundrec	boolean;
 vsts		varchar2(100);
 js		varchar2(1000);
 pfx		THEME%ROWTYPE;
 barcode	glbx.myarray;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, vsts, progcalled=>'LAB.ATTENTION_TASKS', iscust=>FALSE );
  if vsts is not null
   then
   glbx.redisplay_login_page( vsts, TRUE );
   return;
  end if;

  c2rec := get_lab_id( surl, owner_id );
  if byp is not null
   then
    c2rec.workflow_display := byp;
  end if;

  pfx := glbx.get_thm( c2rec.theme_name );
  js := '
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
 var checkflag = "false";
 function check(field)
  {
     if (checkflag == "false")
     {
      for (i = 0; i < field.length; i++) {field[i].checked = true;}
       checkflag = "true";
       return "Uncheck All";
     }
  else
     {
      for (i = 0; i < field.length; i++) { field[i].checked = false;}
      checkflag = "false";
      return "Check All";
     }
  }
//  End -->
</script>
';


  glbx.main_title( surl, LNG4.AHC_TXT_686,glbx.backimg(surl,owner_id,pfx.text_back,null),'L17',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet,jscript=>js);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;

  -- Workflow Tasks
  htp.bold( LNG4.AHC_TXT_893 );
  htp.nl;
  barcode(1) := null;
  if c2rec.workflow_display in ('I','L') -- Display by Purchase Order / Shopping Basket Item
   then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Choice
      htp.tabledata( htf.bold( LNG.GLB_TXT_066 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Details
      htp.tabledata( htf.bold( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&sorton=1&shoplist=' || '&ws=' || ws || '&sts=' || sts, LNG.PHG_TXT_081) ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Order #
      htp.tabledata( htf.bold( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&sorton=2&shoplist=' || '&ws=' || ws || '&sts=' || sts, LNG.CST_TXT_132) ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Image Name
      htp.tabledata( htf.bold( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&sorton=3&shoplist=' || '&ws=' || ws || '&sts=' || sts, LNG.ORD_TXT_185) ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Quantity
      htp.tabledata( htf.bold( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&sorton=4&shoplist=' || '&ws=' || ws || '&sts=' || sts, LNG.PHG_TXT_083) ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Date Purchased
      htp.tabledata( htf.bold( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&sorton=5&shoplist=' || '&ws=' || ws || '&sts=' || sts, LNG.ORD_TXT_153) ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Due Date
      if c2rec.sort_on_attribute_id is not null
       then
        open c6(c2rec.sort_on_attribute_id);
        fetch c6 into c6rec;
        close c6;
        htp.tabledata( htf.bold( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&sorton=8&shoplist=' || '&ws=' || ws || '&sts=' || sts, c6rec.sub_category) ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Meta Tag Value
      end if;
      htp.tabledata( htf.bold( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&sorton=6&shoplist=' || '&ws=' || ws || '&sts=' || sts, LNG4.AHC_TXT_726) ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Priority
      htp.tabledata( htf.bold( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&sorton=7&shoplist=' || '&ws=' || ws || '&sts=' || sts, LNG4.AHC_TXT_612) ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Workflow Set Name
     htp.tablerowclose;
     foundrec := FALSE;
     if c2rec.workflow_display in ('L')
      then
       ctr := 0;
     elsif c2rec.sort_on_attribute_id is null
      then
       open c1( owner_id, sorton );
      else
       open c1m( owner_id, c2rec.sort_on_attribute_id, sorton );
     end if;

     htp.formopen( 'lab.attention_accept' );
     htp.formhidden( 'SURL', surl );
     htp.formhidden( 'P1', null );

     loop
      if c2rec.workflow_display in ('L')
       then

        if c1k%ISOPEN
         then
          fetch c1k into c1rec;
          if c1k%NOTFOUND then close c1k; end if;
        end if;
        if not c1k%ISOPEN
         then
          shpid := null;
          loop
           ctr := ctr + 1;
           begin shpid := to_number(shoplist(ctr)); exception when others then exit; end;
           if shpid is not null then exit; end if;
          end loop;
          if shpid is null then exit; end if;
          open c1k( owner_id, shpid, sorton );
          fetch c1k into c1rec;
        end if;

      elsif c2rec.sort_on_attribute_id is null
       then
        fetch c1 into c1rec;
        if c1%NOTFOUND then close c1; exit; end if;
       else
        fetch c1m into c1mrec;
        if c1m%NOTFOUND then close c1m; exit; end if;
        c1rec.status_priority := c1mrec.status_priority;
        c1rec.date_purchased := c1mrec.date_purchased;
        c1rec.shopping_id := c1mrec.shopping_id;
        c1rec.poid := c1mrec.poid;
        c1rec.status_workflow := c1mrec.status_workflow;
        c1rec.status_at_step := c1mrec.status_at_step;
        c1rec.priority_of_item := c1mrec.priority_of_item;
        c1rec.photo_size := c1mrec.photo_size;
        c1rec.name := c1mrec.name;
        c1rec.qty := c1mrec.qty;
        c1rec.estimated_due_date := c1mrec.estimated_due_date;
        c1rec.value := c1mrec.value;
        c1rec.workflow_name := c1mrec.workflow_name;
        c1rec.manufctr_code := c1mrec.manufctr_code;
        c1rec.xref_mfctr_code := c1mrec.xref_mfctr_code;
        c1rec.product_class := c1mrec.product_class;
        c1rec.invoice_number := c1mrec.invoice_number;
      end if;
      barcode( barcode.count + 1 ) := c1rec.shopping_id;
      foundrec := TRUE;
      htp.tablerowopen;
       if selectall = 'T'
        then
         htp.tabledata( htf.formcheckbox( 'P1', c1rec.shopping_id, 'CHECKED' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' ); -- Checkbox
        else
         htp.tabledata( htf.formcheckbox( 'P1', c1rec.shopping_id ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' ); -- Checkbox
       end if;
       htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/list.gif',cattributes=>'border=0',
                      calt=>c1rec.name || chr(10) || c1rec.manufctr_code || chr(10) || c1rec.xref_mfctr_code || chr(10) || c1rec.product_class || chr(10) || c1rec.invoice_number),
                      cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
       htp.tabledata( htf.anchor( 'lab.attention_by_poid?surl=' || surl || '&vpoid=' || c1rec.poid || '&shp=' || c1rec.shopping_id, c1rec.shopping_id ) ||
                      '(' || htf.anchor2( 'lab.show_poid?surl=' || surl || '&vpoid=' || c1rec.poid || '&shp=' || c1rec.shopping_id, c1rec.poid, ctarget=>'PURCHASE_ORDER' ) || ')',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Order #
       htp.tabledata( c1rec.photo_size,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- DImage Name
       htp.tabledata( c1rec.qty,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Quantity
       htp.tabledata( to_char( c1rec.date_purchased, LNG.TSMASK ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Date Purchased
       htp.tabledata( nvl(to_char( c1rec.estimated_due_date, LNG.TSMASK ),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Date Purchased
       if c2rec.sort_on_attribute_id is not null
        then
         htp.tabledata( nvl(c1rec.value,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Meta Tag Value
       end if;
       htp.tabledata( nvl(to_char(c1rec.priority_of_item),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Priority
       htp.tabledata( nvl(c1rec.workflow_name,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Priority
      htp.tablerowclose;
     end loop;
   htp.tableclose;

   if foundrec
    then
     htp.nl;
     htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0' );
      htp.tablerowopen;
       htp.tabledata( htf.formsubmit( null, LNG5.EXT_TXT_323 ), cattributes=>'VALIGN="BOTTOM"' );
       htp.tabledata( '<input type=button value="Check All" onClick="this.value=check(this.form.P1)">', cattributes=>'VALIGN="BOTTOM"' );

       --htp.tabledata( htf.formopen( 'lab.attention_tasks' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'SORTON', sorton ) || htf.formhidden( 'SELECTALL', 'T' ) || htf.formhidden( 'SHOPLIST', null ) || htf.formsubmit( null, LNG5.EXT_TXT_455 ) || htf.formclose );
       --htp.tabledata( htf.formopen( 'lab.attention_tasks' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'SORTON', sorton ) || htf.formhidden( 'SELECTALL', NULL )|| htf.formhidden( 'SHOPLIST', null )  || htf.formsubmit( null, LNG5.EXT_TXT_456 ) || htf.formclose );
      htp.tablerowclose;
     htp.tableclose;
     htp.formclose;
    else
     htp.bold( LNG4.AHC_TXT_894 );
     htp.nl;
   end if;

  elsif c2rec.workflow_display = 'P' -- Display by Purchase Order Summary and Workflow Set Name
   then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Details
      htp.tabledata( htf.bold( LNG.GLB_TXT_066 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Details
      htp.tabledata( htf.bold( 'Name'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Workflow Set Name
      htp.tabledata( htf.bold( '# Items / Quantity' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Workflow Set Name
      htp.tabledata( htf.bold( 'Date Purchased' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Workflow Set Name
      htp.tabledata( htf.bold( 'Due Date' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Workflow Set Name
     htp.tablerowclose;
     foundrec := FALSE;

     for c7rec in c7( owner_id ) loop
      foundrec := TRUE;
      barcode( barcode.count + 1 ) := c7rec.poid;
      htp.tablerowopen;
       htp.tabledata( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&lvpoid=' || c7rec.poid || '&byp=Z&shoplist=' || '&ws=' || ws || '&sts=' || sts, 'List' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Order #
       htp.tabledata( htf.anchor2( 'lab.show_poid?surl=' || surl || '&vpoid=' || c7rec.poid || '&shp=', c7rec.poid, ctarget=>'PURCHASE_ORDER' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Order #
       htp.tabledata( nvl(c7rec.sendto_name,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Priority
       htp.tabledata( c7rec.cnt || '/' || c7rec.sm,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Priority
       htp.tabledata( to_char(c7rec.date_purchased,LNG.TSMASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Priority
       htp.tabledata( to_char(c7rec.estimated_due_date,LNG.TSMASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Priority
      htp.tablerowclose;
     end loop;
   htp.tableclose;

  elsif c2rec.workflow_display = 'K' -- Display by Purchase Order based on a list of values
   then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Details
      htp.tabledata( htf.bold( LNG.GLB_TXT_066 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Details
      htp.tabledata( htf.bold( 'Name'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Workflow Set Name
      htp.tabledata( htf.bold( '# Items / Quantity' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Workflow Set Name
      htp.tabledata( htf.bold( 'Date Purchased' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Workflow Set Name
      htp.tabledata( htf.bold( 'Due Date' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Workflow Set Name
     htp.tablerowclose;
     foundrec := FALSE;

     delete from report_multi_parameters;
     for j in shoplist.first..shoplist.last loop
      insert into report_multi_parameters values (shoplist(j));
     end loop;
     for c7prec in c7p( owner_id ) loop
        foundrec := TRUE;
        barcode( barcode.count + 1 ) := c7prec.poid;
        htp.tablerowopen;
         htp.tabledata( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&lvpoid=' || c7prec.poid || '&byp=Z&shoplist=' || '&ws=' || ws || '&sts=' || sts, 'List' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Order #
         htp.tabledata( htf.anchor2( 'lab.show_poid?surl=' || surl || '&vpoid=' || c7prec.poid || '&shp=', c7prec.poid, ctarget=>'PURCHASE_ORDER' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Order #
         htp.tabledata( nvl(c7prec.sendto_name,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Priority
         htp.tabledata( c7prec.cnt || '/' || c7prec.sm,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Priority
         htp.tabledata( to_char(c7prec.date_purchased,LNG.TSMASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Priority
         htp.tabledata( to_char(c7prec.estimated_due_date,LNG.TSMASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Priority
        htp.tablerowclose;
     end loop;
   htp.tableclose;

  elsif c2rec.workflow_display = 'Z' -- Display by Items within Purchase Order
   then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Choice
      htp.tabledata( htf.bold( LNG.GLB_TXT_066 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Details
      htp.tabledata( htf.bold( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&sorton=1&shoplist=&lvpoid=' || lvpoid || '&byp=' || byp || '&ws=' || ws || '&sts=' || sts, LNG.PHG_TXT_081) ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Order #
      htp.tabledata( htf.bold( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&sorton=2&shoplist=&lvpoid=' || lvpoid || '&byp=' || byp || '&ws=' || ws || '&sts=' || sts, LNG.CST_TXT_132) ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Image Name
      htp.tabledata( htf.bold( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&sorton=3&shoplist=&lvpoid=' || lvpoid || '&byp=' || byp || '&ws=' || ws || '&sts=' || sts, LNG.ORD_TXT_185) ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Quantity
      htp.tabledata( htf.bold( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&sorton=4&shoplist=&lvpoid=' || lvpoid || '&byp=' || byp || '&ws=' || ws || '&sts=' || sts, LNG.PHG_TXT_083) ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Date Purchased
      htp.tabledata( htf.bold( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&sorton=5&shoplist=&lvpoid=' || lvpoid || '&byp=' || byp || '&ws=' || ws || '&sts=' || sts, LNG.ORD_TXT_153) ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Due Date
      if c2rec.sort_on_attribute_id is not null
       then
        open c6(c2rec.sort_on_attribute_id);
        fetch c6 into c6rec;
        close c6;
        htp.tabledata( htf.bold( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&sorton=8&shoplist=&lvpoid=' || lvpoid || '&byp=' || byp || '&ws=' || ws || '&sts=' || sts, c6rec.sub_category) ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Meta Tag Value
      end if;
      htp.tabledata( htf.bold( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&sorton=6&shoplist=&lvpoid=' || lvpoid || '&byp=' || byp || '&ws=' || ws || '&sts=' || sts, LNG4.AHC_TXT_726) ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Priority
      htp.tabledata( htf.bold( htf.anchor( 'lab.attention_tasks?surl=' || surl || '&sorton=7&shoplist=&lvpoid=' || lvpoid || '&byp=' || byp || '&ws=' || ws || '&sts=' || sts, LNG4.AHC_TXT_612) ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Workflow Set Name
     htp.tablerowclose;
     foundrec := FALSE;
     if c2rec.sort_on_attribute_id is null
      then
       open c8( lvpoid, owner_id, sorton, ws, sts );
      else
       open c8m( lvpoid, owner_id, c2rec.sort_on_attribute_id, sorton, ws, sts );
     end if;

     htp.formopen( 'lab.attention_accept' );
     htp.formhidden( 'SURL', surl );
     htp.formhidden( 'P1', null );

     loop
      if c2rec.sort_on_attribute_id is null
       then
        fetch c8 into c1rec;
        if c8%NOTFOUND then close c8; exit; end if;
       else
        fetch c8m into c1mrec;
        if c8m%NOTFOUND then close c8m; exit; end if;
        c1rec.status_priority := c1mrec.status_priority;
        c1rec.date_purchased := c1mrec.date_purchased;
        c1rec.shopping_id := c1mrec.shopping_id;
        c1rec.poid := c1mrec.poid;
        c1rec.status_workflow := c1mrec.status_workflow;
        c1rec.status_at_step := c1mrec.status_at_step;
        c1rec.priority_of_item := c1mrec.priority_of_item;
        c1rec.photo_size := c1mrec.photo_size;
        c1rec.name := c1mrec.name;
        c1rec.qty := c1mrec.qty;
        c1rec.estimated_due_date := c1mrec.estimated_due_date;
        c1rec.value := c1mrec.value;
        c1rec.workflow_name := c1mrec.workflow_name;
        c1rec.manufctr_code := c1mrec.manufctr_code;
        c1rec.xref_mfctr_code := c1mrec.xref_mfctr_code;
        c1rec.product_class := c1mrec.product_class;
        c1rec.invoice_number := c1mrec.invoice_number;
      end if;

      barcode( barcode.count + 1 ) := c1rec.shopping_id;
      foundrec := TRUE;
      htp.tablerowopen;
       if selectall = 'T'
        then
         htp.tabledata( htf.formcheckbox( 'P1', c1rec.shopping_id, 'CHECKED' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' ); -- Checkbox
        else
         htp.tabledata( htf.formcheckbox( 'P1', c1rec.shopping_id ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' ); -- Checkbox
       end if;
       htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/list.gif',cattributes=>'border=0',
                      calt=>c1rec.name || chr(10) || c1rec.manufctr_code || chr(10) || c1rec.xref_mfctr_code || chr(10) || c1rec.product_class || chr(10) || c1rec.invoice_number),
                      cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
       htp.tabledata( htf.anchor( 'lab.attention_by_poid?surl=' || surl || '&vpoid=' || c1rec.poid || '&shp=' || c1rec.shopping_id, c1rec.shopping_id ) ||
                      '(' || htf.anchor2( 'lab.show_poid?surl=' || surl || '&vpoid=' || c1rec.poid || '&shp=' || c1rec.shopping_id, c1rec.poid, ctarget=>'PURCHASE_ORDER' ) || ')',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Order #
       htp.tabledata( c1rec.photo_size,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- DImage Name
       htp.tabledata( c1rec.qty,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Quantity
       htp.tabledata( to_char( c1rec.date_purchased, LNG.TSMASK ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Date Purchased
       htp.tabledata( nvl(to_char( c1rec.estimated_due_date, LNG.TSMASK ),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Date Purchased
       if c2rec.sort_on_attribute_id is not null
        then
         htp.tabledata( nvl(c1rec.value,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Meta Tag Value
       end if;
       htp.tabledata( nvl(to_char(c1rec.priority_of_item),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Priority
       htp.tabledata( nvl(c1rec.workflow_name,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Priority
      htp.tablerowclose;
     end loop;
   htp.tableclose;

   if foundrec
    then
     htp.nl;
     htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0' );
      htp.tablerowopen;
       htp.tabledata( htf.formsubmit( null, LNG5.EXT_TXT_323 ), cattributes=>'VALIGN="BOTTOM"' );
       htp.tabledata( '<input type=button value="Check All" onClick="this.value=check(this.form.P1)">', cattributes=>'VALIGN="BOTTOM"' );
       --htp.tabledata( htf.formopen( 'lab.attention_tasks' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'SORTON', sorton ) || htf.formhidden( 'SELECTALL', 'T' ) || htf.formhidden( 'LVPOID', lvpoid ) || htf.formhidden( 'BYP', byp ) || htf.formhidden( 'SHOPLIST', null ) || htf.formsubmit( null, LNG5.EXT_TXT_455 ) || htf.formclose );
       --htp.tabledata( htf.formopen( 'lab.attention_tasks' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'SORTON', sorton ) || htf.formhidden( 'SELECTALL', NULL ) || htf.formhidden( 'LVPOID', lvpoid ) || htf.formhidden( 'BYP', byp ) || htf.formhidden( 'SHOPLIST', null ) || htf.formsubmit( null, LNG5.EXT_TXT_456 ) || htf.formclose );
      htp.tablerowclose;
     htp.tableclose;
     htp.formclose;
    else
     htp.bold( LNG4.AHC_TXT_894 );
     htp.nl;
   end if;

   elsif c2rec.workflow_display = 'S' -- Display by Status
   then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.PHG_TXT_082 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Status
      htp.tabledata( htf.bold( LNG4.AHC_TXT_978 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' ); -- Number of Purchase Requests to Work On
     htp.tablerowclose;
     foundrec := FALSE;
     for c1arec in c1a( owner_id, sorton ) loop
      foundrec := TRUE;
      barcode( barcode.count + 1 ) := '[' || c1arec.priority_of_item || ']' || c1arec.status_workflow;
      htp.tablerowopen;
       htp.tabledata( htf.anchor( 'lab.attention_by_status?surl=' || surl || '&sts=' || c1arec.priority_of_item || '&ws=' || c1arec.status_workflow, c1arec.workflow_name || '[' || c1arec.priority_of_item || ']'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Priority (removed  || '[' || c1arec.priority_of_item || ']')
       htp.tabledata( c1arec.cp || ' : ' || c1arec.cnt || '/' || c1arec.sm,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' ); -- Date Purchased
      htp.tablerowclose;
    end loop;
   htp.tableclose;
   if not foundrec then
    htp.bold( LNG4.AHC_TXT_894 );
    htp.nl;
   end if;
  end if;


  htp.nl;

  -- Simple Requests
  if byp in ('K','L')
   then
    null;
   else
  htp.bold( LNG4.AHC_TXT_897 );
  htp.nl;
   htp.formopen( 'lab.manage_simple_requests' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'P0', null );
   htp.formhidden( 'P1', null );
   htp.formhidden( 'P2', null );
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG4.AHC_TXT_904 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( LNG.GLB_TXT_078 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( LNG.ORD_TXT_153 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( replace(LNG4.AHC_TXT_905,'Manufacturer',c2rec.manufacturer_title) ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( LNG4.AHC_TXT_909 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     foundrec := FALSE;
     for c3rec in c3( owner_id ) loop
      foundrec := TRUE;
      htp.tablerowopen;
       htp.formhidden( 'P0', c3rec.srfq_id );
       htp.tabledata( htf.italic( c3rec.request_made) || htf.nl || '#' || htf.bold( c3rec.srfq_id ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( to_char(c3rec.date_made,LNG.MASK ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( to_char(c3rec.respond_by,LNG.MASK ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.formtext( 'P1', 60, 4000, c3rec.mfctr_comments ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       c4rec.manufctr_code := NULL;
       open c4(c3rec.product_id);
       fetch c4 into c4rec;
       close c4;
       htp.tabledata( htf.formtext( 'P2', 10, 20, c4rec.manufctr_code),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tablerowclose;
     end loop;
    htp.tableclose;
   if not foundrec then
    htp.bold( LNG4.AHC_TXT_906 );
    htp.nl;
    htp.formclose;
   else
    htp.nl;
    htp.formsubmit( null, LNG4.AHC_TXT_907 );
    htp.formclose;
   end if;
  htp.nl;
  end if;

  if substr(c2rec.man_bf,25,1) = 'T' and nvl(byp,'x') <> 'L' -- Barcode Support I,P,Z,S
   then
    htp.line;
    htp.nl;
    htp.bold( 'Barcode' );
    htp.nl;
    htp.formopen( 'lab.accept_barcode' );
    htp.formhidden( 'SURL', surl );
    for j in barcode.first..barcode.last loop
     htp.formhidden( 'P1', barcode(j) );
    end loop;
    htp.formhidden( 'P2', c2rec.workflow_display );
    htp.formtextarea( 'P3', 6, 60 );
    htp.nl;
    htp.formsubmit( 'ACTION', 'Fast Track' );
    htp.formsubmit( 'ACTION', 'Review' );
   htp.formclose;
  end if;
  htp.htmlclose;

exception when others then
 glbx.error_details( 'LAB', 'ATTENTION_TASKS', errmsg=>sqlerrm);
end attention_tasks;

procedure manage_simple_requests(surl in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 cursor c4(mfccode varchar2, mfid integer) is select product_id from product where manufacturer_id = mfid and upper(manufctr_code) = upper(mfccode);

 c2rec		manufacturer%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 emptyarr	GLBX.MYARRAY;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LAB.MANAGE_SIMPLE_REQUESTS', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;


  c2rec := get_lab_id( surl, owner_id );
  pfx := glbx.get_thm( c2rec.theme_name );

  for j in p0.first..p0.last loop
   if p0(j) is not null
    then
     c4rec.product_id := NULL;
     open c4(p2(j),owner_id);
     fetch c4 into c4rec;
     close c4;
     update simple_rfq_mfctr
      set
       mfctr_comments = p1(j),
       product_id = c4rec.product_id
     where
      srfq_id = p0(j) and
      manufacturer_id = owner_id;
    end if;
  end loop;
  commit;
  lab.attention_tasks( surl, 1, LNG4.AHC_TXT_908, shoplist=>emptyarr );

exception when others then
 glbx.error_details( 'LAB', 'MANAGE_SIMPLE_REQUESTS', errmsg=>sqlerrm);
end manage_simple_requests;

procedure display_workflow_question( c4rec in WORKFLOW%ROWTYPE, pfx in THEME%ROWTYPE, rowonly in boolean, p1 in varchar2, mand in boolean, shrec in SHOPPING_BASKET%ROWTYPE )
as

 cursor c1(sts integer) is select * from workflow_question where status_id = sts order by decode(upper(response),'Y','0','N','1','YES','0','NO','1',upper(response));
 cursor c2(rid rowid) is select * from workflow_activity where rowid = rid;
 cursor c3 is
 select manufacturer_id, name
 from manufacturer
 order by name;

 c2rec	c2%ROWTYPE;
 rsp	varchar2(4000);
 trid	rowid;

begin

  if not rowonly
   then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  end if;

   htp.tablerowopen;
    if rowonly
     then
      htp.tabledata( htf.bold( shrec.poid ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( shrec.photo_size ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( shrec.qty ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( shrec.phid ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( nvl(shrec.manufctr_code,LNG4.AHC_TXT_902) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      if to_number(shrec.status) in (20,30)
       then
        begin
         trid := chartorowid(shrec.status_at_step);
        exception
         when others then
          insert into audit_workflow_activity(seqno,poid,shopping_id,pid,manufacturer_id,date_created,status_workflow,workflow_activity_id,activity_type,activity_order,extra_value_1) values
           (s_audit_workflow_activity.nextval,shrec.poid,shrec.shopping_id,0,0,sysdate,c4rec.status_workflow,c4rec.status_id,null,null,'Invalid Rowid encountered:' || shrec.status_at_step);
          return;
        end;
        begin
         open c2(trid);
         fetch c2 into c2rec;
         close c2;
        exception
         when others then
          insert into audit_workflow_activity(seqno,poid,shopping_id,pid,manufacturer_id,date_created,status_workflow,workflow_activity_id,activity_type,activity_order,extra_value_1) values
           (s_audit_workflow_activity.nextval,shrec.poid,shrec.shopping_id,0,0,sysdate,c4rec.status_workflow,c4rec.status_id,null,null,'Invalid Rowid in cursor found:' || shrec.status_at_step);
          return;
        end;

        if to_number(shrec.status) = 20
         then
          htp.tabledata( htf.bold( c2rec.extra_value_2 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
         else
          htp.tabledata( htf.bold( LNG5.EXT_TXT_094 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        end if;
       else
        htp.tabledata( htf.bold( c4rec.question ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
     else
      if to_number(shrec.status) in (20,30)
       then
        open c2(chartorowid(shrec.status_at_step));
        fetch c2 into c2rec;
        close c2;
        if to_number(shrec.status) = 20
         then
          htp.tabledata( htf.bold( c2rec.extra_value_2 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
         else
          htp.tabledata( htf.bold( LNG5.EXT_TXT_094 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        end if;
       else
        htp.tabledata( htf.bold( c4rec.question ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
    end if;

    -- Manufacturer to update value. Extract current value from list
    if to_number(shrec.status) = 20
     then
      begin
       if c2rec.activity_type = 'c'
        then
         execute immediate 'select ' || c2rec.extra_value_1 || ' from purchase_order where poid = :1'
         into rsp
         using shrec.poid;
       elsif c2rec.activity_type = 'd'
        then
         execute immediate 'select ' || c2rec.extra_value_1 || ' from shopping_basket where shopping_id = :1'
         into rsp
         using shrec.shopping_id;
       elsif c2rec.activity_type = 'e'
        then
         execute immediate 'select value from umo_attribute where phid = :1 and attribute_id = :2 and position_id = 1'
         into rsp
         using shrec.phid,c2rec.extra_value_1;
       end if;
      exception
       when others then rsp := NULL;
      end;
      htp.tabledata( htf.formtext( p1, 20, 1000, rsp ), cattributes=>'valign="MIDDLE" align="LEFT"' );

    elsif to_number(shrec.status) = 30
     then
      htp.p( '<TD ' || 'valign="MIDDLE" align="LEFT">' );
      htp.formselectopen( 'P1' );
      for c3rec in c3 loop
       htp.formselectoption( c3rec.name, cattributes=>'VALUE="' || c3rec.manufacturer_id || '"' );
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );

    else
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' ); -- Responses
      htp.formselectopen( p1 );
      if not mand then htp.formselectoption( NULL ); end if;
      for c1rec in c1(c4rec.status_id) loop
       if c1rec.is_default = 'T'
        then
         htp.formselectoption( c1rec.response, 'SELECTED' );
        else
         htp.formselectoption( c1rec.response );
       end if;
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
    end if;
   htp.tablerowclose;
  if not rowonly
   then
    htp.tableclose;
  end if;
end display_workflow_question;

procedure attention_by_poid(surl in varchar2, vpoid in varchar2, shp in varchar2, msg in varchar2 default null )
as

 cursor c3(vpoid integer) is
  select *
  from purchase_order
  where poid = vpoid;

 cursor c4(stsw integer, stsp integer) is select * from workflow where status_workflow = stsw and status_priority_default = stsp;

 c1rec		shopping_basket%ROWTYPE;
 c2rec		manufacturer%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 foundrec	boolean;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LAB.ATTENTION_BY_POID', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  c2rec := get_lab_id( surl, owner_id );
  pfx := glbx.get_thm( c2rec.theme_name );
  c1rec := retrieve_workflow_shopping( shp );
  if c1rec.status_mfctr <> owner_id
   then
    htp.bold( 'Invalid Manufacturer' );
    return;
  end if;
  open c3(c1rec.poid);
  fetch c3 into c3rec;
  close c3;
  open c4(c1rec.status_workflow,c1rec.status_priority);
  fetch c4 into c4rec;
  close c4;
  glbx.main_title( surl, LNG.CST_TXT_099 || c1rec.poid,glbx.backimg(surl,owner_id,pfx.text_back,null),'L17',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;
  htp.formopen( 'lab.accept_workflow_poid' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'VPOID', vpoid);
  htp.formhidden( 'SHP', shp );
  display_workflow_question(c4rec,pfx,FALSE,'P1',TRUE,c1rec);
  htp.nl;
  htp.formsubmit( 'ACTION', LNG4.AHC_TXT_895 );
  htp.formsubmit( 'ACTION', LNG4.AHC_TXT_896 );
  htp.formclose;
  display_purchase_details(surl,c1rec,c3rec,pfx,ltype);
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'ATTENTION_BY_POID', errmsg=>sqlerrm);
end attention_by_poid;

procedure accept_workflow_poid( surl in varchar2, vpoid in varchar2, shp in varchar2, p1 in varchar2, action in varchar2 )
as

 cursor c1(shpid integer, mfid integer) is select phid, poid, shopping_id, status_id, status_comment,status_at_step,status,status_workflow from shopping_basket where status_mfctr = mfid and shopping_id = shpid;
 cursor c1a(shpid integer, mfid integer) is select phid, poid, shopping_id, status_id, status_comment,status_at_step,status,status_workflow from shopping_basket_thread where status_mfctr = mfid and thread_id = shpid;
 cursor c3(rid rowid) is select * from workflow_activity where rowid = rid;
 cursor c4(cname varchar2, tname varchar2) is select * from user_tab_columns where table_name = tname and column_name = cname;
 cursor c7( sess_id integer ) is select * from login_session where sessid = sess_id;
 cursor c8( poid integer ) is select * from purchase_order where poid = vpoid;

 c1rec		c1%ROWTYPE;
 c2rec		manufacturer%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c8rec		c8%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 foundrec	boolean;
 np1		number;
 dp1		date;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 parm1		UMP.PARAMETERS;
 parm2		UMP.PARAMETERS;
 retval		varchar2(4000);
 tval1		varchar2(100);
 tval2		varchar2(100);
 emptyarr	GLBX.MYARRAY;

begin

  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LAB.ACCEPT_WORKFLOW_POID', reset=>FALSE, iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if action = LNG4.AHC_TXT_896 then lab.attention_tasks( surl, 1, LNG4.AHC_TXT_979, shoplist=>emptyarr ); return; end if;

  c2rec := get_lab_id( surl, owner_id );
  pfx := glbx.get_thm( c2rec.theme_name );

  open c1(shp, owner_id);
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    open c1a(shp, owner_id);
    fetch c1a into c1rec;
    close c1a;
  end if;
  close c1;

  if to_number(c1rec.status) = 20
   then
    open c3(chartorowid(c1rec.status_at_step));
    fetch c3 into c3rec;
    close c3;
    open c8( vpoid );
    fetch c8 into c8rec;
    close c8;
    open c7( c8rec.sessid );
    fetch c7 into c7rec;
    close c7;
    begin
     if c3rec.activity_type = 'c'
      then
       open c4( c3rec.extra_value_1,'PURCHASE_ORDER' );
       fetch c4 into c4rec;
       close c4;
       if c4rec.data_type = 'DATE'
        then
         dp1 := to_date(p1,LNG.MASK);
         execute immediate 'update purchase_order set ' || c3rec.extra_value_1 || ' = :1 where poid = :2'
         using dp1,c1rec.poid;
       elsif c4rec.data_type = 'NUMBER'
        then
         np1 := to_number(p1);
         execute immediate 'update purchase_order set ' || c3rec.extra_value_1 || ' = :1 where poid = :2'
         using np1,c1rec.poid;
       else
        execute immediate 'update purchase_order set ' || c3rec.extra_value_1 || ' = :1 where poid = :2'
        using p1,c1rec.poid;
        if upper(c3rec.extra_value_1) = 'SENDTO_NAME'
         then
          glbx.fixnm(p1,tval1,tval2);
          update purchase_order set sendto_firstname = tval1, sendto_lastname = tval2 where poid = c1rec.poid;
        end if;
        if upper(c3rec.extra_value_1) in ('SENDTO_FIRSTNAME','SENDTO_LASTNAME')
         then
          update purchase_order set sendto_name = substr(sendto_firstname || ' ' || sendto_lastname,1,100) where poid = c1rec.poid;
        end if;
        if upper(c3rec.extra_value_1) = 'BILLING_NAME'
         then
          glbx.fixnm(p1,tval1,tval2);
          update purchase_order set billing_firstname = tval1, billing_lastname = tval2 where poid = c1rec.poid;
        end if;
        if upper(c3rec.extra_value_1) in ('BILLING_FIRSTNAME','BILLING_LASTNAME')
         then
          update purchase_order set sendto_name = substr(billing_firstname || ' ' || billing_lastname,1,100) where poid = c1rec.poid;
        end if;
       end if;

     elsif c3rec.activity_type = 'd'
      then
       open c4( c3rec.extra_value_1,'SHOPPING_BASKET' );
       fetch c4 into c4rec;
       close c4;
       if c4rec.data_type = 'DATE'
        then
         dp1 := to_date(glbx.guess_date(p1),LNG.MASK);
         --
         -- Smart Date Check
         --
         if abs(sysdate-dp1) > 5000
          then
           insert into audit_workflow_activity(seqno,poid,shopping_id,pid,manufacturer_id,date_created,status_workflow,workflow_activity_id,activity_type,activity_order,extra_value_1) values
            (s_audit_workflow_activity.nextval,c1rec.poid,c1rec.shopping_id,0,0,sysdate,c1rec.status_workflow,c1rec.status_id,null,null,'Bad Date Entered:' || to_char(dp1,LNG.MASK) );
          else
           execute immediate 'update shopping_basket set ' || c3rec.extra_value_1 || ' = :1 where shopping_id = :2' using dp1,c1rec.shopping_id;
           if sql%NOTFOUND then execute immediate 'update shopping_basket_thread set ' || c3rec.extra_value_1 || ' = :1 where thread_id = :2' using dp1,c1rec.shopping_id; end if;
         end if;
       elsif c4rec.data_type = 'NUMBER'
        then
         np1 := to_number(p1);
         execute immediate 'update shopping_basket set ' || c3rec.extra_value_1 || ' = :1 where shopping_id = :2' using np1,c1rec.shopping_id;
         if sql%NOTFOUND then execute immediate 'update shopping_basket_thread set ' || c3rec.extra_value_1 || ' = :1 where thread_id = :2' using np1,c1rec.shopping_id; end if;
       else
        execute immediate 'update shopping_basket set ' || c3rec.extra_value_1 || ' = :1 where shopping_id = :2' using p1,c1rec.shopping_id;
        if sql%NOTFOUND then execute immediate 'update shopping_basket_thread set ' || c3rec.extra_value_1 || ' = :1 where thread_id = :2' using p1,c1rec.shopping_id; end if;
       end if;

     elsif c3rec.activity_type = 'e'
      then
       parm1(1) := 'UMO_ID';
       parm2(1) := c1rec.phid;
       parm1(2) := 'AID';
       parm2(2) := to_char(c7rec.aid);
       parm1(3) := 'OBJECT_TYPE';
       parm2(3) := 'PHOTO';
       parm1(4) := 'KEEP_STATUS';
       parm2(4) := 'KEEP';
       parm1(5) := 'ATTRIBUTE_ID';
       parm2(5) := '[' || c3rec.extra_value_1 || ']' || p1;
       ump.modify_uma(surl,parm1,parm2,retval);
     end if;
    exception
     when others then NULL;
    end;
    run_workflow(surl, shp, c3rec.workflow_activity_id );

  elsif to_number(c1rec.status) = 30
   then
    update shopping_basket set status_mfctr = nvl(p1,status_mfctr), status = '30' where shopping_id = c1rec.shopping_id;
    if sql%NOTFOUND then update shopping_basket_thread set status_mfctr = nvl(p1,status_mfctr), status = '30' where thread_id = c1rec.shopping_id; end if;
    open c3(chartorowid(c1rec.status_at_step));
    fetch c3 into c3rec;
    close c3;
    run_workflow(surl, shp, c3rec.workflow_activity_id );

   else
    run_workflow(surl, shp, p1 );
  end if;

  if action <> 'NO DISPLAY'
   then
    glbx.main_title( surl, LNG.CST_TXT_099 || vpoid,glbx.backimg(surl,owner_id,pfx.text_back,null),'L17',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    glbx.header_msg( LNG4.AHC_TXT_899 );
    htp.nl;
    htp.p( '<CENTER>' );
    htp.anchor( 'lab.attention_tasks?surl=' || surl || '&shoplist=', LNG4.AHC_TXT_900 );
    htp.p( '</CENTER>' );
    htp.htmlclose;
  end if;

exception when others then
 glbx.error_details( 'LAB', 'ACCEPT_WORKFLOW_POID', errmsg=>sqlerrm, extdet=>'P1:' || p1 || ' ACTION:' || action || ' VPOID:' || vpoid || ' SHP:' || shp);
end accept_workflow_poid;

procedure attention_by_status(surl in varchar2, sts in integer, ws in integer default null, msg in varchar2 default null )
as

 cursor c3(mfid integer, sts integer, ws integer) is
  select 'S' || sb.shopping_id shopping_id
  from shopping_basket sb, purchase_order po
  where nvl(priority_of_item,0) = nvl(sts,0) and status_mfctr = mfid and status_workflow=ws and sb.poid = po.poid
  union all
  select 'W' || sb.shopping_id shopping_id
  from shopping_basket_thread sb, purchase_order po
  where nvl(priority_of_item,0) = nvl(sts,0) and status_mfctr = mfid and status_workflow=ws and sb.poid = po.poid;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 stsx		varchar2(100);
 p1		GLBX.MYARRAY;

begin
  glbx.cookie_id( surl, stype, ltype, owner_id, stsx, progcalled=>'LAB.ATTENTION_BY_STATUS', iscust=>FALSE );
  if stsx is not null
   then
   glbx.redisplay_login_page( stsx, TRUE );
   return;
  end if;

  p1(1) := NULL;
  for c3rec in c3(owner_id, sts, ws) loop
   p1(c3%ROWCOUNT) := c3rec.shopping_id;
  end loop;
  --attention_accept(surl, p1, sts );
  attention_tasks( surl, byp=>'K', shoplist=>p1, ws=>ws, sts=>sts);

exception when others then
 glbx.error_details( 'LAB', 'ATTENTION_BY_STATUS', errmsg=>sqlerrm, extdet=>'STS:' || sts);
end attention_by_status;

procedure attention_accept(surl in varchar2, p1 in GLBX.MYARRAY, sts in integer default null, msg in varchar2 default null )
as

 cursor c1(sts integer) is select * from workflow_state_options where status_priority_id = sts;

 cursor c4(stsid integer) is select * from workflow where status_id = stsid;

 c1rec		c1%ROWTYPE;
 c2rec		manufacturer%ROWTYPE;
 c3rec		shopping_basket%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 foundrec	boolean;
 xsts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, xsts, progcalled=>'LAB.ATTENTION_ACCEPT', iscust=>FALSE );
  if xsts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  c2rec := get_lab_id( surl, owner_id );
  pfx := glbx.get_thm( c2rec.theme_name );
  open c1(sts);
  fetch c1 into c1rec;
  close c1;
  glbx.main_title( surl, 'Update Workflow Tasks',glbx.backimg(surl,owner_id,pfx.text_back,null),'L17',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;
  htp.formopen( 'lab.accept_workflow_sts' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'STS', sts);
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
    htp.tabledata( LNG.CST_TXT_099,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( LNG3.ADM_TXT_288,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( LNG.CST_TXT_135,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( LNG.PHG_TXT_048,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( LNG.LAB_TXT_042,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( LNG3.ADM_TXT_428,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( LNG3.ADM_TXT_561,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  for j in p1.first..p1.last loop
   if p1(j) is not null
    then
     c3rec := retrieve_workflow_shopping( p1(j) );
     open c4(c3rec.status_id);
     fetch c4 into c4rec;
     close c4;
     htp.formhidden( 'P0', p1(j) );
     display_workflow_question(c4rec,pfx,TRUE,'P1',FALSE,c3rec);
   end if;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( 'ACTION', LNG4.AHC_TXT_895 );
  htp.formsubmit( 'ACTION', LNG4.AHC_TXT_896 );
  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'ATTENTION_ACCEPT', errmsg=>sqlerrm);
end attention_accept;

procedure accept_workflow_sts( surl in varchar2, sts in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, action in varchar2 )
as

 cursor c1(shpid integer, mfid integer, sts integer) is
  select shopping_id,poid,photo_size,photo_cost,qty,phid,manufctr_code
  from shopping_basket
  where shopping_id = shpid
union all
  select thread_id,poid,photo_size,photo_cost,qty,phid,manufctr_code
  from shopping_basket_thread
  where thread_id = shpid;

  cursor c2(sbid integer) is select poid from shopping_basket where shopping_id = sbid union all select poid from shopping_basket_thread where thread_id = sbid;

 c1rec		c1%ROWTYPE;
 c2rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 foundrec	boolean;
 currpoid	integer;
 nextpoid	integer;
 xsts		varchar2(100);
 pfx		THEME%ROWTYPE;
 emptyarr	GLBX.MYARRAY;

begin

  glbx.cookie_id( surl,stype, ltype, owner_id, xsts, progcalled=>'LAB.ACCEPT_WORKFLOW_STS', iscust=>FALSE );
  if xsts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if action = LNG4.AHC_TXT_896 then lab.attention_tasks( surl, 1, LNG4.AHC_TXT_979, shoplist=>emptyarr ); return; end if;

  c2rec := get_lab_id( surl, owner_id );
  pfx := glbx.get_thm( c2rec.theme_name );

  glbx.main_title( surl, LNG4.AHC_TXT_901,glbx.backimg(surl,owner_id,pfx.text_back,null),'L17',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);

  glbx.header_msg( LNG4.AHC_TXT_899 );
  htp.nl;
  htp.p( '<CENTER>' );
  htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
   htp.tablerowopen;
    htp.tablerowopen;
      htp.tabledata( LNG.CST_TXT_099,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( LNG3.ADM_TXT_288,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( LNG.CST_TXT_135,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( 'Image #',cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( LNG.LAB_TXT_042,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( LNG3.ADM_TXT_561,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;

  for j in p0.first..p0.last loop
   if p0(j) is not null
    then
     open c1(p0(j), owner_id, sts);
     fetch c1 into c1rec;
     if c1%NOTFOUND
      then
       close c1;
       htp.bold( LNG4.AHC_TXT_898 );
       return; -- Illegal Call
     end if;
     close c1;

     htp.tablerowopen;
      htp.tabledata( c1rec.poid,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( c1rec.photo_size,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( c1rec.qty,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( c1rec.phid,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( nvl(c1rec.manufctr_code,LNG4.AHC_TXT_902),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( nvl(p1(j),LNG4.AHC_TXT_903),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );  -- Question not answered
    htp.tablerowclose;
    if p1(j) is not null
     then
      -- is this the last one in the list from this purchase order?
      IS_LAST_SHOPPING_ITEM := 'TRUE';
      --insert into temp values ('A:' || p0(j) || '-' || p1(j)); commit;
      open c2(p0(j));
      fetch c2 into currpoid;
      close c2;

      if j = p0.last
       then
        IS_LAST_SHOPPING_ITEM := 'TRUE';
        --insert into temp values ('B:' || p0(j) || '-' || p1(j)); commit;
       else
        for k in (j+1)..p0.last loop
         open c2(p0(k));
         fetch c2 into nextpoid;
         close c2;
         if currpoid = nextpoid then IS_LAST_SHOPPING_ITEM := 'FALSE'; exit; end if;
        end loop;
      end if;

      accept_workflow_poid(surl, c1rec.poid, c1rec.shopping_id, p1(j), 'NO DISPLAY' );
      -- run_workflow(surl, c1rec.shopping_id, p1(j) );

    end if;

   end if;
  end loop;

  htp.tableclose;
  htp.anchor( 'lab.attention_tasks?surl=' || surl || '&shoplist=', LNG4.AHC_TXT_900 );
  htp.p( '</CENTER>' );
  htp.htmlclose;

exception when others then
 glbx.error_details( 'LAB', 'ACCEPT_WORKFLOW_STS', errmsg=>sqlerrm, extdet=>'ACTION:' || action || ' STS:' || sts);
end accept_workflow_sts;

procedure display_purchase_details( surl in varchar2, c1rec in SHOPPING_BASKET%ROWTYPE, c3rec in PURCHASE_ORDER%ROWTYPE, pfx in THEME%ROWTYPE, login_type in varchar2 )
as

 cursor c3(vpoid integer) is select film_type,qty,photo_size,photo_cost,film_name from shopping_basket where poid = vpoid;
 cursor c4(ws integer, stid integer) is select order_option from workflow_state_options where work_state = ws and status_priority_id = stid;
 cursor c5(sbid integer, vpoid integer) is select * from shopping_basket where poid=vpoid and shopping_id = sbid;
 cursor c6(v_umo integer) is select * from umo where umo_id = v_umo;

 c4rec		c4%ROWTYPE;
 c6rec		c6%ROWTYPE;
 dbool		boolean;
 dsp		varchar2(100);
 dispvar	varchar2(1000);
 empty_array	GLBX.MYARRAY;

begin
  open c6(c1rec.phid);
  fetch c6 into c6rec;
  close c6;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
    if c1rec.umo_width > c1rec.umo_height
     then
      dsp := ' WIDTH=' || c1rec.umo_width;
     else
      dsp := ' HEIGHT=' || c1rec.umo_height;
    end if;
    htp.tabledata(htf.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.phid || '&parm1=DISPLAY_TYPE&parm2=IMAGE&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=POID&parm2=' || c1rec.poid || '&parm1=LOGIN_TYPE&parm2=' || login_type|| '&parm1=AID&parm2=' || c6rec.aid || '&parm1=RETURN_LINK&parm2=lab.attention_by_poid~surl=' || surl || '!vpoid=' || c1rec.poid || '!shp=' || c1rec.shopping_id,
                              '<IMG BORDER=0 ' || dsp || ' SRC="' ||
                              'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.phid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL&parm1=POID&parm2=' || c1rec.poid || '&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || c6rec.aid ||
                              '" ALT="' || LNG2.PBK_TXT_057 || '">'),
                              cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER" CLASS="SMALL" colspan="2"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.CST_TXT_099),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(c1rec.poid),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG3.ADM_TXT_288),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(c1rec.photo_size),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.CST_TXT_135),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(c1rec.qty),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold('Image #'),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(c1rec.phid),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.LAB_TXT_042),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(nvl(c1rec.manufctr_code,LNG4.AHC_TXT_902)),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     open c4(c1rec.work_state,c1rec.status_priority);
     fetch c4 into c4rec;
     if c4%NOTFOUND then dispvar := c3rec.status || ' (Note: Item level status not found)'; else dispvar := c4rec.order_option; end if;
     close c4;
     htp.tabledata( htf.bold(LNG.PHG_TXT_082),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(dispvar),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.CST_TXT_051),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( nvl(replace(replace(c3rec.order_comment || htf.nl || htf.italic(c3rec.customer_comment),chr(10),'<BR>'),chr(13),'<BR>'),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.ORD_TXT_179),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(c3rec.paid_method),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_301),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( nvl(htf.bold(c3rec.contact_email),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_762),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     if c3rec.do_not_split_order = 'T'
      then
       htp.tabledata( htf.bold(LNG.PHG_TXT_045),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      else
       htp.tabledata( htf.bold(LNG.PHG_TXT_046),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     end if;
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG3.ADM_TXT_781),cattributes=>pfx.qbground || 'valign="TOP" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(c3rec.sendto_name) || htf.nl || c3rec.sendto_street || htf.nl || c3rec.sendto_suburb || htf.nl || c3rec.sendto_city || htf.nl || c3rec.sendto_country || '-' || c3rec.sendto_postcode,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.CST_TXT_123),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG.PHG_ALT_422 ) );
       htp.tabledata( htf.bold( LNG.PHG_TXT_025 ) );
       htp.tabledata( htf.bold( LNG.ORD_TXT_171 ) );
       htp.tabledata( htf.bold( LNG.CST_TXT_135 ) );
       htp.tabledata( htf.bold( LNG.PHG_TXT_356 ) );
      htp.tablerowclose;

      for c5rec in c5(c1rec.shopping_id,c3rec.poid) loop
       htp.tablerowopen;
        htp.tabledata( htf.bold(c5rec.film_name) );
        htp.tabledata( c5rec.photo_size );
        htp.tabledata( c5rec.photo_cost );
        htp.tabledata( c5rec.qty );
        htp.tabledata( c5rec.film_type );
      htp.tablerowclose;
      end loop;

    htp.tableclose;
    htp.p( '</TD>' );
    htp.tablerowclose;
  htp.tableclose;

  htp.nl;

  dbool := glbx.disp_mt( surl, 'PHOTOGRAPHER', c1rec.phid, c6rec.umo_type, 'T', pfx, c6rec.aid, empty_array ); -- Mark as Photographer

end display_purchase_details;

procedure perform_workflow_activity( surl in varchar2, vpoid in integer, sbid in integer, wsid in integer, actid in integer, phgid in integer, mfctr_id in integer, override_activity_order integer, stop_workflow out boolean, halt_workflow in out boolean, new_status_id out integer, new_status_workflow out integer, new_workflow_activity_id out integer )
as

 TYPE DCurTyp IS REF CURSOR;  -- define weak REF CURSOR type

 cursor c1( actid integer, override_activity_order integer ) is
  select rowid,pid,workflow_activity_id,activity_type,activity_order,extra_value_1,extra_value_2,extra_value_3,extra_value_4,extra_value_5
  from workflow_activity
  where workflow_activity_id = actid and
        activity_order > nvl(override_activity_order,0)
  order by activity_order;
 cursor c2( tname varchar2 ) is select column_name from user_tab_columns where table_name = tname and data_type in ('CHAR','VARCHAR2','NUMBER','DATE');
 cursor c4 is select * from umo_attributes where umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT','ALL');
 cursor c5( phgid integer ) is select contact_email from photographer where pid = phgid;
 cursor c6( manid integer ) is select contact_email from manufacturer where manufacturer_id = manid;
 cursor c7( sess_id integer ) is select * from login_session where sessid = sess_id;
 cursor c8( vpoid integer ) is select * from purchase_order where poid = vpoid;
 cursor c9( v_umo integer, attrib integer ) is select value from umo_attribute where attribute_id = attrib and umo_id = v_umo order by position_id;
 cursor c10( tname varchar2 ) is select column_name, data_type from user_tab_columns where table_name = tname;
 cursor c11( sbid integer ) is select count('x') tot from shopping_basket where shopping_id = sbid;
 cursor c12( profid integer ) is select aid from customer_profile where profile_id = profid;
 cursor c13( attribid integer ) is select * from umo_attributes where attribute_id = attribid;
 cursor c14( trowid rowid ) is select * from shopping_basket where rowid = trowid;
 cursor c15( v_umo integer ) is select * from umo where umo_id = v_umo;
 cursor c16( v_umo integer, attribid integer ) is select ua.value from umo_attribute ua where ua.umo_id = v_umo and ua.attribute_id = attribid;
 cursor c17( ctg varchar2 ) is select attribute_id,sub_category from umo_attributes uas where umo_type = ctg;

 c3rec			shopping_basket%ROWTYPE;
 c7rec			c7%ROWTYPE;
 c8rec			c8%ROWTYPE;
 c9rec			c9%ROWTYPE;
 c11rec			c11%ROWTYPE;
 c13rec			c13%ROWTYPE;
 c14rec			c14%ROWTYPE;
 c15rec			c15%ROWTYPE;
 c16rec			c16%ROWTYPE;
 dcurs  		DCurTyp;
 workflow_thread	integer;
 gcode			GLBX.MYARRAY;
 gparam			GLBX.MYARRAY;
 job			varchar2(1000);
 eml			varchar2(1000);
 ctr			integer;
 ctr2			integer;
 trowid			rowid;
 last_step		char(1);
 step			varchar2(100);
 parm1			UMP.PARAMETERS;
 parm2			UMP.PARAMETERS;
 tmpval			varchar2(4000);
 dtmpval		date;
 retval			varchar2(4000);
 stmt			varchar2(32767);
 poparm1 		GLBX.MYARRAY;
 poparm2 		GLBX.MYARRAY_NMB;
 chk			boolean;
 tval1			varchar2(100);
 tval2			varchar2(100);

 procedure audit_the_activity(c1rec in c1%ROWTYPE)
 as
 begin
  insert into audit_workflow_activity(seqno,poid,shopping_id,thread_id,pid,manufacturer_id,date_created,status_workflow,workflow_activity_id,activity_type,activity_order,extra_value_1,extra_value_2,extra_value_3,extra_value_4,extra_value_5)
   values
    (s_audit_workflow_activity.nextval,vpoid,sbid,workflow_thread,phgid,mfctr_id,sysdate,wsid,actid,c1rec.activity_type,c1rec.activity_order,c1rec.extra_value_1,c1rec.extra_value_2,c1rec.extra_value_3,c1rec.extra_value_4,c1rec.extra_value_5);
 end audit_the_activity;

begin

 stop_workflow := FALSE;
 halt_workflow := FALSE;
 new_status_workflow := NULL;

 -- Reset the Overrides to null
 --insert into temp values(vpoid || '1:' || sbid || '-2:' || wsid || '-3:' || actid || '-4:' || phgid || '-5:' || mfctr_id || '-6:' || override_activity_order );
 --commit;

 update shopping_basket set status = '1', override_wflow_order = null, status_at_step = null where shopping_id = sbid;
 if sql%NOTFOUND then update shopping_basket_thread set status = '1', override_wflow_order = null, status_at_step = null where thread_id = sbid; end if;

 for c1rec in c1(actid, override_activity_order) loop

  last_step := c1rec.activity_type;

  if c1rec.activity_type = 'A'
   then
    -- Stop Workflow
    stop_workflow := TRUE;
    update shopping_basket set status = '0', override_wflow_order = null, status_comment = c1rec.extra_value_1 where shopping_id = sbid;
    if sql%NOTFOUND then update shopping_basket_thread set status = '0', override_wflow_order = null, status_comment = c1rec.extra_value_1 where thread_id = sbid; end if;
   exit;

  elsif c1rec.activity_type in ('B','C','D''E','F','P','g')
   then

    -- B Email any address
    -- C Email Photographer
    -- D Email Manufacturer
    -- E Email Customer
    -- F Email Administrator
    -- P Send to Printer using Special Template
    step := 'X1';

    open c8( vpoid );
    fetch c8 into c8rec;
    close c8;
    open c7( c8rec.sessid );
    fetch c7 into c7rec;
    close c7;

    step := 'X2';

    if c1rec.activity_type = 'B'
     then
      eml := c1rec.extra_value_3;
    elsif c1rec.activity_type = 'g'
     then
      eml := c1rec.extra_value_3;
    elsif c1rec.activity_type = 'C'
     then
      open c5( phgid );
      fetch c5 into eml;
      close c5;
    elsif c1rec.activity_type = 'D'
     then
      open c6( mfctr_id );
      fetch c6 into eml;
      close c6;
    elsif c1rec.activity_type = 'E'
     then
      eml := c7rec.guest_email;
    elsif c1rec.activity_type = 'F'
     then
      eml := glbx.extract_master_parameter('PICTION_EMAIL_ACCT' );
    end if;

    ctr := 1;
    -- Attach as global variable all the pricing information
    step := 'X3';

    glbx.calculate_pricing( vpoid, poparm1, poparm2 );
    step := 'X4';

    for j in poparm1.first..poparm1.last loop
     gcode(ctr) := 'PURCHREC.' || poparm1(j);
     gparam(ctr) := trim(to_char(round(poparm2(j),2),'9999999999990.99')); -- Round value as template has no control over it and format nicely. Do not format to money as some values are %
     ctr := ctr + 1;
    end loop;

    step := 'X5';

    gcode(ctr) := 'ACCOUNT_ID';
    gparam(ctr) := c7rec.aid;

    step := 'X6';

    ctr := ctr + 1;
    gcode(ctr) := 'POID';
    gparam(ctr) := vpoid;

    step := 'X7';

    ctr := ctr + 1;
    gcode(ctr) := 'SIGNATURE';
    gparam(ctr) := glbx.extract_master_parameter('MAIL SIGNATURE');

    step := 'X8';

    for c2rec in c2('PURCHASE_ORDER') loop
     ctr := ctr + 1;
     retval := NULL;
     gcode(ctr) := c2rec.column_name;
     begin
     execute immediate 'select ' || c2rec.column_name || ' from purchase_order where poid = :1'
      into retval
       using vpoid;
     gparam(ctr) := retval;
     exception
      when others then gparam(ctr) := NULL;
     end;
    end loop;

    step := 'X9';

    for c2rec in c2('SHOPPING_BASKET') loop
     ctr := ctr + 1;
     retval := NULL;
     gcode(ctr) := c2rec.column_name;

      begin
       execute immediate 'select ' || c2rec.column_name || ' from shopping_basket where shopping_id = :1'
        into retval
         using sbid;
      exception when others then
       execute immediate 'select ' || c2rec.column_name || ' from shopping_basket_thread where thread_id = :1'
        into retval
         using sbid;
      end;

     gparam(ctr) := retval;
    end loop;

    step := 'X10';

    c3rec := retrieve_workflow_shopping(sbid);
    step := 'X11';

    ctr := ctr + 1;
    gcode(ctr) := 'PRICE_TIMES_QTY';
    gparam(ctr) := to_char(nvl(c3rec.qty,0) * nvl(c3rec.photo_cost,0),'999999990.99');
    step := 'X12';

    if c3rec.phid is not null
     then
      for c2rec in c2('UMO') loop
       begin
        ctr := ctr + 1;
        retval := NULL;
        gcode(ctr) := c2rec.column_name;
        execute immediate 'select ' || c2rec.column_name || ' from umo where umo_id = :1'
         into retval
          using c3rec.phid;
        gparam(ctr) := retval;
       exception when others then gparam(ctr) := NULL;
       end;
      end loop;
    end if;

    step := 'X13';

    for c4rec in c4 loop
     ctr := ctr + 1;
     retval := NULL;
     gcode(ctr) := upper(c4rec.sub_category);
     begin
      execute immediate 'select value from umo_attribute where umo_id = :1 and attribute_id = :2'
       into retval
        using c3rec.phid,c4rec.attribute_id;
     exception
      when others then
       -- If the meta tag does not exist the value of retval is NULL
       retval := NULL;
     end;
     gparam(ctr) := retval;
    end loop;

    -- Group Print
    if c1rec.activity_type = 'g'
     then
      step := 'X14';

      if c1rec.extra_value_4 is null
       then
        stmt := 'where poid = <POID> ';
       else
        stmt := 'where poid = <POID> and ' || c1rec.extra_value_4;
      end if;

      for k in gcode.first..gcode.last loop
       stmt := replace(stmt,'<' || gcode(k) || '>',gparam(k));
      end loop;

      -- Select all the values satisfied
      step := 'X15';

      ctr := ctr + 1;
      gcode(ctr) := 'SHOPREC.SHOPPING_ID';
      gcode(ctr+1) := 'SHOPREC.PHID';
      gcode(ctr+2) := 'SHOPREC.QTY';
      gcode(ctr+3) := 'SHOPREC.PHOTO_SIZE';
      gcode(ctr+4) := 'SHOPREC.PHOTO_COST';
      gcode(ctr+5) := 'SHOPREC.PPI';
      gcode(ctr+6) := 'SHOPREC.LAB_ID';
      gcode(ctr+7) := 'SHOPREC.MANUFCTR_CODE';
      gcode(ctr+8) := 'SHOPREC.PRICE_TIMES_QTY';
      gcode(ctr+9) := 'SHOPREC.FILM_NAME';
      gcode(ctr+10) := 'SHOPREC.PHOTO_ORIGINAL_LOC';
      gcode(ctr+11) := 'SHOPREC.UMO_FILM_NAME';
      gparam(ctr) := NULL;
      gparam(ctr+1) := NULL;
      gparam(ctr+2) := NULL;
      gparam(ctr+3) := NULL;
      gparam(ctr+4) := NULL;
      gparam(ctr+5) := NULL;
      gparam(ctr+6) := NULL;
      gparam(ctr+7) := NULL;
      gparam(ctr+8) := NULL;
      gparam(ctr+9) := NULL;
      gparam(ctr+10) := NULL;
      gparam(ctr+11) := NULL;
      for c17rec in c17('ALL') loop
       gcode(ctr+11+c17%ROWCOUNT) := upper('SHOPREC.' || c17rec.sub_category);
       gparam(ctr+11+c17%ROWCOUNT) := NULL;
      end loop;
      stmt := 'select rowid from shopping_basket ' || stmt;
      --insert into temp values( 'X15A:' || stmt ); commit;

      begin
      open dcurs for stmt;
      loop
       fetch dcurs into trowid;
       if dcurs%NOTFOUND then exit; end if;
       open c14(trowid);
       fetch c14 into c14rec;
       close c14;
       begin gparam(ctr) := gparam(ctr) || ',' || c14rec.shopping_id; exception when others then null; end;
       begin gparam(ctr+1) := gparam(ctr+1) || ',' || c14rec.phid; exception when others then null; end;
       begin gparam(ctr+2) := gparam(ctr+2) || ',' || c14rec.qty; exception when others then null; end;
       begin gparam(ctr+3) := gparam(ctr+3) || ',' || replace(c14rec.photo_size,',',' '); exception when others then null; end;
       begin gparam(ctr+4) := gparam(ctr+4) || ',' || c14rec.photo_cost; exception when others then null; end;
       begin gparam(ctr+5) := gparam(ctr+5) || ',' || c14rec.ppi; exception when others then null; end;
       begin gparam(ctr+6) := gparam(ctr+6) || ',' || c14rec.lab_id; exception when others then null; end;
       begin gparam(ctr+7) := gparam(ctr+7) || ',' || replace(c14rec.manufctr_code,',',' '); exception when others then null; end;
       begin gparam(ctr+8) := gparam(ctr+8) || ',' || trim(to_char(nvl(c14rec.photo_cost,0) * nvl(c14rec.qty,0),'9999990.99')); exception when others then null; end;
       begin gparam(ctr+9) := gparam(ctr+9) || ',' || replace(c14rec.film_name,',',' '); exception when others then null; end;
       open c15(c14rec.phid);
       fetch c15 into c15rec;
        if c15%FOUND
         then
          close c15;
          begin gparam(ctr+10) := gparam(ctr+10) || ',' || replace(c15rec.photo_original_loc,',',' '); exception when others then null; end;
         else
          close c15;
        end if;
       begin gparam(ctr+11) := gparam(ctr+11) || ',' || replace(c14rec.umo_film_name,',',' '); exception when others then null; end;

       -- Add all the ALL Meta Tag Values for the Item
       for c17rec in c17('ALL') loop
        open c16(c14rec.phid,c17rec.attribute_id);
        --fetch c16 into c16rec;
        c16rec.value := null;
        fetch c16 into c16rec;
        begin gparam(ctr+11+c17%ROWCOUNT) := gparam(ctr+11+c17%ROWCOUNT) || ',' || replace(c16rec.value,',',' '); exception when others then null; end;
        close c16;
/*        if c16%FOUND
         then
          close c16;
          begin gparam(ctr+11+c17%ROWCOUNT) := gparam(ctr+11+c17%ROWCOUNT) || ',' || replace(c16rec.value,',',' '); exception when others then null; end;
         else
          close c16;
        end if;
*/
       end loop;
       --insert into temp values ('XXX:' || substr(c1rec.extra_value_5,1,1) || ':' || rowidtochar(trowid)); commit;
       update shopping_basket set printed_out = substr(c1rec.extra_value_5,1,1) where rowid = trowid;

      end loop;

      close dcurs;

      gparam(ctr) := substr(gparam(ctr),2);
      gparam(ctr+1) := substr(gparam(ctr+1),2);
      gparam(ctr+2) := substr(gparam(ctr+2),2);
      gparam(ctr+3) := substr(gparam(ctr+3),2);
      gparam(ctr+4) := substr(gparam(ctr+4),2);
      gparam(ctr+5) := substr(gparam(ctr+5),2);
      gparam(ctr+6) := substr(gparam(ctr+6),2);
      gparam(ctr+7) := substr(gparam(ctr+7),2);
      gparam(ctr+8) := substr(gparam(ctr+8),2);
      gparam(ctr+9) := substr(gparam(ctr+9),2);
      gparam(ctr+10) := substr(gparam(ctr+10),2);
      gparam(ctr+11) := substr(gparam(ctr+11),2);
      for c17rec in c17('ALL') loop
       gparam(ctr+11+c17%ROWCOUNT) := substr(gparam(ctr+11+c17%ROWCOUNT),2);
      end loop;
      exception when others then null;
      end;

    end if;

    /*
    for xx in gcode.first..gcode.last loop
     insert into temp values (sbid || '-' || xx || ':' || gcode(xx) || '-' || gparam(xx)); commit;
    end loop;
    */
    step := 'X16';

    begin
     if c1rec.activity_type in ('P','g')
      then

       -- Not quite sure what to do with the Job Code
       if c1rec.activity_type = 'g' and gparam(ctr) is null
        then
         null;
        else
         begin
          glbx.send_workflow( gcode, gparam, infile=>c1rec.extra_value_2, tname=>c1rec.extra_value_1, job=>job, printer=>c1rec.extra_value_3 );
         exception
          when others then
            glbx.error_details( 'LAB', 'PERFORM_WORKFLOW_ACTIVITY', errmsg=>sqlerrm, extdet=> 'Activity Type P - Printing:' || c1rec.extra_value_1 || '-' || c1rec.extra_value_2);
         end;
       end if;

      else

       glbx.send( gcode, gparam, c1rec.extra_value_1, p_to=>eml, p_subj=>c1rec.extra_value_2, p_from=>glbx.extract_master_parameter('MAIL_FROM'));

     end if;

    exception
     when others then
      -- An error will occur if the wrong template is specified
      -- Now gets logged in the EMAIL_LOG table
      null;
    end;
    step := 'X17';

  elsif c1rec.activity_type = 'G'
   then
    -- Change Status
    update shopping_basket set priority_of_item = c1rec.extra_value_1 where shopping_id = sbid;
    if sql%NOTFOUND then update shopping_basket_thread set status_priority = c1rec.extra_value_1 where thread_id = sbid; end if;

  elsif c1rec.activity_type = 'h'
   then
    -- Change Purchase orderStatus
    update purchase_order set status = c1rec.extra_value_1 where poid = vpoid;

  elsif c1rec.activity_type = 'H'
   then
    -- Go to Workflow Set
    -- Set Status back to first status for this workflow
    update shopping_basket set
      status_workflow = c1rec.extra_value_1,
      work_state = (select distinct work_state from workflow_set where status_workflow = c1rec.extra_value_1),
      status_priority = (select min(status_priority_id) from workflow_state_options where status_workflow = c1rec.extra_value_1)
    where shopping_id = sbid;
    if sql%NOTFOUND then
     update shopping_basket_thread set
       status_workflow = c1rec.extra_value_1,
       work_state = (select distinct work_state from workflow_set where status_workflow = c1rec.extra_value_1),
       status_priority = (select min(status_priority_id) from workflow_state_options where status_workflow = c1rec.extra_value_1)
     where thread_id = sbid;
    end if;
    new_status_workflow := c1rec.extra_value_1;
    exit;

  elsif c1rec.activity_type = 'I'
   then
    -- Go to Workflow Option
    update shopping_basket
     set
      status = '1',
      status_priority = substr(c1rec.extra_value_1,2,instr(c1rec.extra_value_1,']')-2),
      status_workflow = substr(c1rec.extra_value_1,instr(c1rec.extra_value_1,']')+1),
      work_state = (select distinct work_state from workflow_set where status_workflow = substr(c1rec.extra_value_1,instr(c1rec.extra_value_1,']')+1))
    where
     shopping_id = sbid;
    if sql%NOTFOUND
     then
      update shopping_basket_thread
       set
        status = '1',
        status_priority = substr(c1rec.extra_value_1,2,instr(c1rec.extra_value_1,']')-2),
       status_workflow = substr(c1rec.extra_value_1,instr(c1rec.extra_value_1,']')+1),
        work_state = (select distinct work_state from workflow_set where status_workflow = substr(c1rec.extra_value_1,instr(c1rec.extra_value_1,']')+1))
      where
       thread_id = sbid;
    end if;
    new_status_workflow := substr(c1rec.extra_value_1,instr(c1rec.extra_value_1,']')+1);
    exit;

  elsif c1rec.activity_type = 'J'
   then
    -- Go to Workflow Activity
    new_workflow_activity_id := c1rec.extra_value_1;
    exit;

  elsif c1rec.activity_type in ('K','M','N') -- Update Meta Tag, Check In, Check Out
   then
    -- Update Meta-Tag
    c3rec := retrieve_workflow_shopping(sbid);
    open c8( vpoid );
    fetch c8 into c8rec;
    close c8;
    open c7( c8rec.sessid );
    fetch c7 into c7rec;
    close c7;
    if c7rec.login_type in ('PROFILE','PROFILEG')
     then
      open c12(c7rec.aid);
      fetch c12 into c7rec.aid;
      close c12;
    end if;
    open c13(c1rec.extra_value_1);
    fetch c13 into c13rec;
    close c13;
    parm1(1) := 'UMO_ID';
    parm2(1) := c3rec.phid;
    parm1(2) := 'AID';
    parm2(2) := to_char(c7rec.aid);
    parm1(3) := 'OBJECT_TYPE';
    parm2(3) := c13rec.umo_type;
    parm1(4) := 'KEEP_STATUS';
    parm2(4) := 'KEEP';
    parm1(5) := 'ATTRIBUTE_ID';
    parm2(5) := '[' || c1rec.extra_value_1 || ']' || c1rec.extra_value_2;
    ump.modify_uma(surl,parm1,parm2,retval);

  elsif c1rec.activity_type = 'i'
   then
    -- Run Manual Print
    open c8( vpoid );
    fetch c8 into c8rec;
    close c8;
    c3rec := retrieve_workflow_shopping(sbid);
    open c15( c3rec.phid );
    fetch c15 into c15rec;
    close c15;
    lab.run_print( surl, c8rec, c3rec, c15rec, to_number(c1rec.extra_value_1), TRUE );

  elsif c1rec.activity_type = 'L'
   then
    -- Change Responsibility
    update shopping_basket set status_mfctr = nvl(c1rec.extra_value_1,status_mfctr) where shopping_id = sbid;
    if sql%NOTFOUND then update shopping_basket_thread set status_mfctr = nvl(c1rec.extra_value_1,status_mfctr) where thread_id = sbid; end if;

  elsif c1rec.activity_type = 'l'
   then
    -- Manufacturer Assigns New Responsibility
    -- Prompt Manufacturer to Assign New Manufacturer
    -- Change Responsibility
    retval := NULL;
    halt_workflow := TRUE;
    update shopping_basket set status = '30', status_mfctr = nvl(c1rec.extra_value_1,status_mfctr), override_wflow_order = c1rec.activity_order, status_at_step = rowidtochar(c1rec.rowid) where shopping_id = sbid;
    if sql%NOTFOUND then update shopping_basket_thread set status = '30', status_mfctr = nvl(c1rec.extra_value_1,status_mfctr), override_wflow_order = c1rec.activity_order, status_at_step = rowidtochar(c1rec.rowid) where thread_id = sbid; end if;
    commit;
    exit;

  elsif c1rec.activity_type = 'O'
   then
    -- Call PL/SQL Program
    begin
     execute immediate 'begin ' || c1rec.extra_value_1 || '(surl=>''' || surl || ''',wsid=>' || wsid || ',actid=>' || actid || ',poid=>' || vpoid || ',shopping_id=>' || sbid || ',parm1=>''' || c1rec.extra_value_1 || ''',parm2=>''' || c1rec.extra_value_2 || '''); end;';
    exception
     when others then null; -- If an error occurs continue on running
    end;

--  elsif c1rec.activity_type = 'P' -- Now moved to email template above
--   then

  elsif c1rec.activity_type = 'Q'
   then
    --
    -- Not Used. Available for future Workflow Options
    --
    null;

  elsif c1rec.activity_type in ('R','r')
   then
    -- Assign Invoice
    c3rec := retrieve_workflow_shopping(sbid);
    assign_invoice(vpoid,c3rec.priority_of_item,c1rec.activity_type);

  elsif c1rec.activity_type = 'S'
   then
    -- No Action (Dummy Step, akin to NULL)
    NULL;

  elsif c1rec.activity_type = 'T'
   then
    -- Not Used at the moment
    null;

  elsif c1rec.activity_type = 'U'
   then
    -- Purchase Order
    execute immediate 'update purchase_order set ' || c1rec.extra_value_1 || ' = :1 where poid = :2'
     using c1rec.extra_value_2,vpoid;
        if upper(c1rec.extra_value_1) = 'SENDTO_NAME'
         then
          glbx.fixnm(c1rec.extra_value_2,tval1,tval2);
          update purchase_order set sendto_firstname = tval1, sendto_lastname = tval2 where poid = vpoid;
        end if;
        if upper(c1rec.extra_value_1) in ('SENDTO_FIRSTNAME','SENDTO_LASTNAME')
         then
          update purchase_order set sendto_name = substr(sendto_firstname || ' ' || sendto_lastname,1,100) where poid = vpoid;
        end if;
        if upper(c1rec.extra_value_1) = 'BILLING_NAME'
         then
          glbx.fixnm(c1rec.extra_value_2,tval1,tval2);
          update purchase_order set billing_firstname = tval1, billing_lastname = tval2 where poid = vpoid;
        end if;
        if upper(c1rec.extra_value_1) in ('BILLING_FIRSTNAME','BILLING_LASTNAME')
         then
          update purchase_order set sendto_name = substr(billing_firstname || ' ' || billing_lastname,1,100) where poid = vpoid;
        end if;

  elsif c1rec.activity_type = 'V'
   then
    -- Shopping Basket
    execute immediate 'update shopping_basket set ' || c1rec.extra_value_1 || ' = :1 where shopping_id = :2' using c1rec.extra_value_2,sbid;
    if sql%NOTFOUND then execute immediate 'update shopping_basket_thread set ' || c1rec.extra_value_1 || ' = :1 where thread_id = :2' using c1rec.extra_value_2,sbid; end if;

  elsif c1rec.activity_type = 'W'
   then
    -- Stop if Meta Tag Value Equals
    --open c3(sbid);
    --fetch c3 into c3rec;
    --close c3;
    c3rec := retrieve_workflow_shopping(sbid);
    c9rec.value := NULL;
    open c9(c3rec.phid,to_number(c1rec.extra_value_1));
    fetch c9 into c9rec;
    close c9;
    if ((c9rec.value is null) and (c1rec.extra_value_2 is null)) or
        (c9rec.value = c1rec.extra_value_2)
     then
      stop_workflow := TRUE;
      exit;
    end if;

  elsif c1rec.activity_type = 'X'
   then
    -- Stop if Purchase Order Column Equals
    retval := NULL;
    begin
     execute immediate 'select ' || c1rec.extra_value_1 || ' from purchase_order where poid = :1'
      into retval
       using vpoid;
    exception
     when others then null;
    end;

    if ((retval is null) and (c1rec.extra_value_2 is null)) or
        (retval = c1rec.extra_value_2)
     then
      stop_workflow := TRUE;
      exit;
    end if;

  elsif c1rec.activity_type = 'Y'
   then
    -- Stop if Shopping Basket Column Equals
    retval := NULL;
    begin
     execute immediate 'select ' || c1rec.extra_value_1 || ' from shopping_basket where shopping_id = :1'
      into retval
       using sbid;
     exception
      when others then null;
    end;
    if ((retval is null) and (c1rec.extra_value_2 is null)) or
        (retval = c1rec.extra_value_2)
     then
      stop_workflow := TRUE;
      exit;
    end if;

  elsif c1rec.activity_type = 'Z'
   then
    -- Do Activity if Meta Tag Equals Value
    retval := NULL;
    --open c3(sbid);
    --fetch c3 into c3rec;
    --close c3;
    c3rec := retrieve_workflow_shopping(sbid);
    c9rec.value := NULL;
    open c9(c3rec.phid,to_number(c1rec.extra_value_1));
    fetch c9 into c9rec;
    close c9;
    if ((c9rec.value is null) and (c1rec.extra_value_2 is null)) or
        (c9rec.value = c1rec.extra_value_2)
     then
      new_workflow_activity_id := c1rec.extra_value_3;
      exit;
    end if;

  elsif c1rec.activity_type = 'a'
   then
    -- Do Activity if Meta Tag Equals Value
    retval := NULL;
    begin
     execute immediate 'select ' || c1rec.extra_value_1 || ' from purchase_order where poid = :1'
      into retval
       using vpoid;
     exception
      when others then null;
    end;
    if ((retval is null) and (c1rec.extra_value_2 is null)) or
        (retval = c1rec.extra_value_2)
     then
      new_workflow_activity_id := c1rec.extra_value_3;
      exit;
    end if;

  elsif c1rec.activity_type = 'b'
   then
    -- Do Activity if Shopping Column Equals Value
    retval := NULL;
    begin
    execute immediate 'select ' || c1rec.extra_value_1 || ' from shopping_basket where shopping_id = :1'
     into retval
      using sbid;
     exception
      when others then null;
    end;
    if ((retval is null) and (c1rec.extra_value_2 is null)) or
        (retval = c1rec.extra_value_2)
     then
      new_workflow_activity_id := c1rec.extra_value_3;
      exit;
    end if;

  elsif c1rec.activity_type in ('c','d','e')
   then
    -- Prompt Manufacturer to Modify Data Value
    retval := NULL;
    halt_workflow := TRUE;
    update shopping_basket
      set
       status = '20',
       status_mfctr = nvl(c1rec.extra_value_3,status_mfctr),
       override_wflow_order = c1rec.activity_order,
       status_at_step = rowidtochar(c1rec.rowid)
     where
      shopping_id = sbid;
     if sql%NOTFOUND
      then
       update shopping_basket_thread
        set
         status = '20',
         status_mfctr = nvl(c1rec.extra_value_3,status_mfctr),
         override_wflow_order = c1rec.activity_order,
         status_at_step = rowidtochar(c1rec.rowid)
       where
        thread_id = sbid;
       end if;
     commit;
    exit;

  elsif c1rec.activity_type = 'f'
   then
    -- Create workflow thread
    -- Copy the shopping basket contents
    -- Only Create the thread if it originates from a shopping basket item and not a thread item. This should prevent potential customer infinite loops
    open c11(sbid);
    fetch c11 into c11rec;
    close c11;
    if c11rec.tot >= 1
     then
      select s_shopping_basket.nextval into workflow_thread from dual;
      insert into shopping_basket_thread(thread_id) values (workflow_thread);
      for c10rec in c10( 'SHOPPING_BASKET' ) loop
       if c10rec.column_name <> 'THREAD_ID'
        then
        begin
         if c10rec.data_type = 'DATE'
          then
           execute immediate 'select ' || c10rec.column_name || ' from shopping_basket where shopping_id = :1' into dtmpval using sbid;
           execute immediate 'update shopping_basket_thread set ' || c10rec.column_name || ' = :1 where thread_id = :2' using dtmpval, workflow_thread;
          else
           execute immediate 'select ' || c10rec.column_name || ' from shopping_basket where shopping_id = :1' into tmpval using sbid;
           execute immediate 'update shopping_basket_thread set ' || c10rec.column_name || ' = :1 where thread_id = :2' using tmpval, workflow_thread;
         end if;
        exception
         when others then null;
        end;
       end if;
      end loop;
      update shopping_basket_thread set status_workflow = c1rec.extra_value_1, status_priority = NULL where thread_id = workflow_thread;

      -- Run the thread
      run_workflow( surl, workflow_thread, null );

    end if;

  end if;

  step := 'X18';
  audit_the_activity(c1rec);

  -- Update Shopping Basket to let it know its done?

  commit;
 end loop;

exception when others then
 glbx.error_details( 'LAB', 'PERFORM_WORKFLOW_ACTIVITY', errmsg=>sqlerrm, extdet=>'Last Step: ' || last_step || ' WSID:' || wsid || ' ACTID:' || actid || ' PHGID:' || phgid || ' MFCTR_ID:' || mfctr_id || ' Debug Step:' || step);
 -- if an error occurs we are in danger of getting trapped in an infinite loop. update with failure and exit workflow
end perform_workflow_activity;

function calculate_meta_tag( c1rec in SHOPPING_BASKET%ROWTYPE, c2rec in WORKFLOW%ROWTYPE, c3rec in PURCHASE_ORDER%ROWTYPE, umo_rec in UMO%ROWTYPE )
 return integer
as

 cursor c4(stid integer) is select * from workflow_query where status_id = stid order by decode(if_or_else,'I',0,1),order_by;
 cursor c5(vqry integer) is select * from workflow_query_clause where query_id = vqry order by order_by;
 cursor c6(v_umo integer, attrid integer) is select value from umo_attribute where umo_id = v_umo and attribute_id = attrid order by position_id;

 c4rec		c4%ROWTYPE;
 vl		varchar2(4000);
 if_clause	boolean;
 res_clause	boolean;
 cnt		integer;
 lclause	varchar2(100);
 tmp		varchar2(4000);

 function extract_value( c5rec in c5%ROWTYPE )
  return varchar2
 as
  vl		varchar2(4000);
 begin
  --insert into temp values ('ATT1:' || c1rec.phid || '-' || c5rec.attribute_id ); commit;
  if c5rec.attribute_id is not null
   then
    open c6(c1rec.phid,c5rec.attribute_id);
    fetch c6 into vl;
    close c6;
  --insert into temp values ('ATT2:' || c1rec.phid || '-' || c5rec.attribute_id || '-' || vl ); commit;
    return( vl );
  elsif c5rec.system_column is not null
   then
    if c5rec.system_column = '1'
     then
      --insert into temp values ('D:' || c5rec.system_column || '-' || IS_LAST_SHOPPING_ITEM); commit;
      return( IS_LAST_SHOPPING_ITEM );
     else
      --insert into temp values ('E:' || c5rec.system_column || '-' || IS_LAST_SHOPPING_ITEM); commit;
      return( NULL );
    end if;
  elsif c5rec.purchase_column is not null
   then
    execute immediate
     'select ' || c5rec.purchase_column || ' from purchase_order where poid = :1'
      into vl
      using c1rec.poid;
    return( vl );
  elsif c5rec.shopping_column is not null
   then
    execute immediate
     'select ' || c5rec.shopping_column || ' from shopping_basket where shopping_id = :1'
      into vl
      using c1rec.shopping_id;
    return( vl );
  elsif c5rec.umo_column is not null
   then
    execute immediate
     'select ' || c5rec.umo_column || ' from umo where umo_id = :1'
      into vl
      using c1rec.phid;
  --insert into temp values ('UMO:' || c5rec.umo_column || '-' || c1rec.phid || '-' || vl ); commit;
    return( vl );
  end if;
  return( NULL );
 end extract_value;

begin
 --insert into temp values ('A1:' || c2rec.status_id); commit;
 --insert into temp values ('AP:' || c3rec.poid); commit;
 --insert into temp values ('AS:' || c1rec.shopping_id); commit;
 for c4rec in c4(c2rec.status_id) loop
  --insert into temp values ('A2:' || c4rec.if_or_else ); commit;
  -- Else Clause. If we hit this, we have an else situation
  if c4rec.if_or_else = 'E' then return( c4rec.workflow_activity_id ); end if;

  if_clause := TRUE;
  for c5rec in c5( c4rec.query_id ) loop
   vl := extract_value( c5rec );
  --insert into temp values ('A2X:' || vl ); commit;
   if c5rec.apply_function is not null
    then
     --insert into temp values ('B1:' || c5rec.apply_function ); commit;
     if c5rec.extra_function_parm is null
      then
       execute immediate 'begin :1 := ' || c5rec.apply_function || '(' || '''' || vl || '''' || '); end;'
        using in out vl;
      else
       execute immediate 'begin :1 := ' || c5rec.apply_function || '(' || '''' || vl || ''',''' || c5rec.extra_function_parm || '''' || '); end;'
        using in out vl;
     end if;
   end if;

   res_clause := FALSE;
   -- Evaluate expression
   cnt := 0;
  --insert into temp values ('A1:' || c5rec.expression ); commit;
  --insert into temp values ('A2:' || vl ); commit;
  --insert into temp values ('A3:' || c5rec.value ); commit;
   if c5rec.expression in ('IS NULL','IS NOT NULL')
    then
     execute immediate
      'select count(*) cnt from dual where :1 ' || c5rec.expression
       into cnt
        using vl;
    else
     execute immediate
      'select count(*) cnt from dual where :1 ' || c5rec.expression || ' ' || ':2'
       into cnt
        using vl,c5rec.value;
   end if;
  --insert into temp values ('A4:' || cnt ); commit;
   if cnt = 1 then res_clause := TRUE; end if;

   -- Test with previous if function
   if c5%ROWCOUNT = 1
    then
     if_clause := res_clause;
     lclause := c5rec.and_or;
  --insert into temp values ('A5:' || lclause ); commit;
   else
    if lclause = 'AND'
     then
      if_clause := if_clause and res_clause;
     else
      if_clause := if_clause or res_clause;
    end if;
   end if;

  --insert into temp values ('A6:' || lclause ); commit;
   if not if_clause and lclause = 'AND' then exit; end if; -- We have a false, exit and fail
   lclause := c5rec.and_or;
  --insert into temp values ('A7:' || lclause ); commit;

  end loop;

  -- If the query_clause evaluates to true then return this statement as true
  if if_clause
   then
    --insert into temp values ('RET:' || c4rec.workflow_activity_id ); commit;
     insert into audit_workflow_activity(seqno,poid,shopping_id,pid,manufacturer_id,date_created,status_workflow,workflow_activity_id,activity_type,activity_order,extra_value_1) values
     (s_audit_workflow_activity.nextval,c1rec.poid,c1rec.shopping_id,0,0,sysdate,c1rec.status_workflow,c1rec.status_id,null,null,'Condition Met:' || c2rec.status_id || ':' || c4rec.workflow_activity_id || '-' || c4rec.query_id);
    return( c4rec.workflow_activity_id );
  end if;

 end loop;

 -- If we get here there is a problem as we shouldn't
   insert into audit_workflow_activity(seqno,poid,shopping_id,pid,manufacturer_id,date_created,status_workflow,workflow_activity_id,activity_type,activity_order,extra_value_1) values
     (s_audit_workflow_activity.nextval,c1rec.poid,c1rec.shopping_id,0,0,sysdate,c1rec.status_workflow,c1rec.status_id,null,null,'Null Condition hit in Calculate Meta Tag:' || c2rec.status_id);
   return(NULL);

exception
 when others
  then
   tmp := sqlerrm;
   return( NULL );
end calculate_meta_tag;

function retrieve_workflow_shopping( sbid in integer )
 return shopping_basket%ROWTYPE
as

cursor c1(sbid integer) is select * from shopping_basket where shopping_id = sbid;
cursor c2(sbid integer) is select * from shopping_basket_thread where thread_id = sbid;

retval	shopping_basket%ROWTYPE;
retval2	shopping_basket_thread%ROWTYPE;

begin
 open c1(sbid);
 fetch c1 into retval;
 if c1%NOTFOUND
  then
   close c1;
   open c2(sbid);
   fetch c2 into retval2;
   close c2;
   retval.poid                  := retval2.poid;
   retval.shopping_id           := retval2.shopping_id;
   retval.phid                  := retval2.phid;
   retval.film_type             := retval2.film_type;
   retval.qty                   := retval2.qty;
   retval.photo_size            := retval2.photo_size;
   retval.photo_cost            := retval2.photo_cost;
   retval.frame_style           := retval2.frame_style;
   retval.frame_cost            := retval2.frame_cost;
   retval.alteration            := retval2.alteration;
   retval.alteration_cost       := retval2.alteration_cost;
   retval.isgallery             := retval2.isgallery;
   retval.ppi                   := retval2.ppi;
   retval.phg_code              := retval2.phg_code;
   retval.lab_id                := retval2.lab_id;
   retval.manufctr_code         := retval2.manufctr_code;
   retval.xref_mfctr_code       := retval2.xref_mfctr_code;
   retval.is_discounted         := retval2.is_discounted;
   retval.name                  := retval2.name;
   retval.price                 := retval2.price;
   retval.tax                   := retval2.tax;
   retval.commission            := retval2.commission;
   retval.b2c_lab_discount      := retval2.b2c_lab_discount;
   retval.lab_charge_perc       := retval2.lab_charge_perc;
   retval.film_name             := retval2.film_name;
   retval.must_download         := retval2.must_download;
   retval.status_id             := retval2.status_id;
   retval.status                := retval2.status;
   retval.status_priority       := retval2.status_priority;
   retval.status_workflow       := retval2.status_workflow;
   retval.status_comment        := retval2.status_comment;
   retval.work_state            := retval2.work_state;
   retval.item_discounted       := retval2.item_discounted;
   retval.item_disc_charge      := retval2.item_disc_charge;
   retval.delivery_time_local   := retval2.delivery_time_local;
   retval.delivery_time_int     := retval2.delivery_time_int;
   retval.surcharge_local       := retval2.surcharge_local;
   retval.surcharge_int         := retval2.surcharge_int;
   retval.production_time       := retval2.production_time;
   retval.delivery_desc         := retval2.delivery_desc;
   retval.product_desc          := retval2.product_desc;
   retval.status_mfctr          := retval2.status_mfctr;
   retval.ppm_id                := retval2.ppm_id;
   retval.ppm_id_limit          := retval2.ppm_id_limit;
   retval.umo_width             := retval2.umo_width;
   retval.umo_height            := retval2.umo_height;
   retval.umo_film_name         := retval2.umo_film_name;
   retval.umo_type              := retval2.umo_type;
   retval.contentlength         := retval2.contentlength;
   retval.ftp_location          := retval2.ftp_location;
   retval.ftp_virtual_dir       := retval2.ftp_virtual_dir;
   retval.umo_photo_name        := retval2.umo_photo_name;
   retval.ppm_title             := retval2.ppm_title;
   retval.invoice_number        := retval2.invoice_number;
   retval.invoice_date          := retval2.invoice_date;
   retval.tax_code              := retval2.tax_code;
   retval.invoice_extracted     := retval2.invoice_extracted;
   retval.product_class         := retval2.product_class;
   retval.override_wflow_order  := retval2.override_wflow_order;
   retval.estimated_due_date    := retval2.estimated_due_date;
   retval.priority_of_item      := retval2.priority_of_item;
   retval.status_at_step        := retval2.status_at_step;
   retval.special_shipping      := retval2.special_shipping;
   retval.royalty_api           := retval2.royalty_api;
   retval.royalty_api_pk        := retval2.royalty_api_pk;
   retval.printed_out            := retval2.printed_out;
  else
   close c1;
 end if;
 return( retval );
exception when others
 then
 glbx.error_details( 'LAB', 'RETRIEVE_WORKFLOW_SHOPPING', errmsg=>sqlerrm );
 return( retval );
end retrieve_workflow_shopping;

procedure run_workflow( surl in varchar2, sbid in integer, answer in varchar2 default NULL )
as

 cursor c2(sw integer) is select * from workflow where status_workflow = sw and status_priority_default = (select min(status_priority_default) from workflow where status_workflow = sw);
 cursor c3(sw integer, sid integer) is select * from workflow where status_workflow = sw and status_priority_default = sid;
 cursor c4(sid integer, answer varchar2) is select workflow_activity_id from workflow_question where status_id = sid and response = answer;

 cursor c5(sw integer, sdef integer ) is
  select status_id,manufacturer_id,status_priority_default
  from workflow
  where status_workflow = sw and
        status_priority_default > sdef
  order by status_priority_default;

 cursor c6(vpoid integer) is select * from purchase_order where poid = vpoid;

 cursor c7(shp integer, phgid integer) is
  select po.poid,sb.shopping_id
  from shopping_basket sb,purchase_order po
  where po.poid=sb.poid and
        sb.shopping_id = shp and
        po.pid = phgid
 union all
  select po.poid,sb.thread_id shopping_id
  from shopping_basket_thread sb,purchase_order po
  where po.poid=sb.poid and
        sb.thread_id = shp and
        po.pid = phgid;

 cursor c7a(shp integer, acid integer) is
  select po.poid,sb.shopping_id
  from shopping_basket sb,purchase_order po,customer_account ca
  where po.poid=sb.poid and
        sb.shopping_id = shp and
        ca.aid = acid and
        ca.pid = po.pid
 union all
  select po.poid,sb.thread_id shopping_id
  from shopping_basket_thread sb,purchase_order po,customer_account ca
  where po.poid=sb.poid and
        sb.thread_id = shp and
        ca.aid = acid and
        ca.pid = po.pid;

 cursor c7b(shp integer, profid integer) is
  select po.poid,sb.shopping_id
  from shopping_basket sb,purchase_order po,customer_account ca, customer_profile cp
  where po.poid=sb.poid and
        sb.shopping_id = shp and
        cp.profile_id = profid and
        ca.pid = po.pid
 union all
  select po.poid,sb.thread_id shopping_id
  from shopping_basket_thread sb,purchase_order po,customer_account ca, customer_profile cp
  where po.poid=sb.poid and
        sb.thread_id = shp and
        cp.profile_id = profid and
        ca.pid = po.pid;

 cursor c8(rid rowid) is select workflow_activity_id from workflow_activity where rowid = rid;
 cursor c9(v_umo integer) is select * from umo where umo_id = v_umo;

 c1rec				shopping_basket%ROWTYPE;
 c2rec				c2%ROWTYPE;
 c5rec				c5%ROWTYPE;
 c6rec				c6%ROWTYPE;
 c7rec				c7%ROWTYPE;
 umorec				c9%ROWTYPE;
 ltype				varchar2(100);
 stype				integer;
 owner_id			integer;
 sts				varchar2(100);
 pfx				THEME%ROWTYPE;
 do_activity			integer;
 inf_loop			integer;
 vanswer			varchar2(4000);
 stop_workflow			boolean;
 halt_workflow			boolean;
 new_status_id			integer;
 new_status_workflow		integer;
 new_workflow_activity_id	integer;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LAB.RUN_WORKFLOW', reset=>FALSE, iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 -- Validate Login. Details are not referenced.
 if ltype = 'PHOTOGRAPHER'
  then
   open c7(sbid,owner_id);
   fetch c7 into c7rec;
   if c7%NOTFOUND
    then
     close c7;
     htp.p( LNG4.AHC_TXT_944 );
     return;
   end if;
   close c7;

 elsif ltype = 'MANUFACTURER'
  then
   null;

 elsif ltype in ('OWNER','CUSTOMER','VIRTUAL')
  then
  -- Customer, Guest, etc
   open c7a(sbid,owner_id);
   fetch c7a into c7rec;
   if c7a%NOTFOUND
    then
     close c7a;
     htp.p( LNG4.AHC_TXT_944 );
     return;
   end if;
   close c7a;

 elsif ltype in ('PROFILE','PROFILEG')
  then
  -- Customer, Guest, etc
   open c7b(sbid,owner_id);
   fetch c7b into c7rec;
   if c7b%NOTFOUND
    then
     close c7b;
     htp.p( LNG4.AHC_TXT_944 );
     return;
   end if;
   close c7b;
 end if;

 inf_loop := 1;
 vanswer := answer;

 loop
  -- Get details from shopping basket
  c1rec := retrieve_workflow_shopping( sbid );
  --open c1(sbid);
  --fetch c1 into c1rec;
  --close c1;

  -- Check to see if the workflow has stopped (0 indicates stopped, less than 0 is an error)
  if to_number(c1rec.status) < 1
   then
    exit;
  end if;

  -- Check if status is null, if it is then start it from the first workflow set activity. It means the workflow has just started
  --insert into temp values ('I:' || c1rec.status || '-' || c1rec.status_workflow || '-' || c1rec.status_priority); commit;
  if to_number(c1rec.status_priority) is null
   then
    open c2( c1rec.status_workflow );
    fetch c2 into c2rec;
    close c2;

   else
    -- Pull out the current workflow step
    --insert into temp values ('GG:' ); commit;
    open c3( c1rec.status_workflow, c1rec.status_priority );
    fetch c3 into c2rec;
    close c3;

  end if;

  do_activity := NULL;
  --insert into temp values('G:' || c2rec.workflow_type ||'-' || c2rec.goto_workflow); commit;

  if to_number(c1rec.status) in (20,30)
   then
    -- Bypass in effect
    open c8(chartorowid(c1rec.status_at_step));
    fetch c8 into do_activity;
    close c8;

  elsif c2rec.workflow_type = 'Q' and vanswer is NULL
   then
    -- Stop Workflow
    -- Manufacturer needs to enter in answer to question
    update shopping_basket set status = '10', status_id = c2rec.status_id, status_priority = c2rec.status_priority_default, status_mfctr = nvl(c2rec.manufacturer_id,status_mfctr) where shopping_id = sbid;
    if sql%NOTFOUND then update shopping_basket_thread set status = '10', status_id = c2rec.status_id, status_priority = c2rec.status_priority_default, status_mfctr = nvl(c2rec.manufacturer_id,status_mfctr) where thread_id = sbid; end if;
    commit;
    exit;

  elsif c2rec.workflow_type = 'Q' and vanswer is NOT NULL
   then
    -- Determine which workflow activity to perform based on answer
    open c4(c2rec.status_id,vanswer);
    fetch c4 into do_activity;
    close c4;

   elsif c2rec.workflow_type = 'M'
    then
     -- Determine workflow activity from Meta Tag If Then Else
     open c6(c1rec.poid);
     fetch c6 into c6rec;
     close c6;
     open c9(c1rec.phid);
     fetch c9 into umorec;
     close c9;
     --insert into temp values ('BEfore' ); commit;
     do_activity := calculate_meta_tag(c1rec,c2rec,c6rec,umorec);
     --insert into temp values ('After:' || do_activity ); commit;

   elsif c2rec.workflow_type = 'G'
    then
     -- Goto workflow activity
     do_activity := c2rec.goto_workflow;

   elsif c2rec.workflow_type = 'I'
    then
     -- Initialise workflow activity (exactly the same as Goto)
     do_activity := c2rec.goto_workflow;
  end if;

  if c1rec.override_wflow_order is not null
   then
    -- Override Call, continue on
    null;

  elsif do_activity IS NULL
   then
    -- We have a problem
    update shopping_basket set status = '-2', status_mfctr = NULL where shopping_id = sbid;
    if sql%NOTFOUND then update shopping_basket_thread set status = '-2', status_mfctr = NULL where thread_id = sbid; end if;
    commit;
    return;

  elsif do_activity = 0 -- Question response says continue on as is
   then
    goto NEXT_WORKFLOW_STEP;  -- Its a horrible thing to embed in the code, but it avoids a horrible complex if-then-else

  end if;
    --insert into temp values ('h:' || do_activity ); commit;
  -- Workflow Activity
  loop

   -- Keep looping doing all Workflow Activities
   -- Infinite Loop Check
   -- Just in case we get caught in an endless workflow loop. 10000 seems like a reasonable figure
   inf_loop := inf_loop + 1;
   if inf_loop > 500
    then
     insert into audit_workflow_activity(seqno,poid,shopping_id,pid,manufacturer_id,date_created,status_workflow,workflow_activity_id,activity_type,activity_order,extra_value_1)
      values
     (s_audit_workflow_activity.nextval,c1rec.poid,sbid,0,0,sysdate,c1rec.status_workflow,c1rec.status_id,null,null,'Infinite Loop Hit in Lab.Runworkflow');
     update shopping_basket set status = '-1', status_comment = 'Infinite Loop Hit in Lab.Runworkflow', status_mfctr = NULL where shopping_id = sbid;
     if sql%NOTFOUND then update shopping_basket_thread set status = '-1', status_mfctr = NULL where thread_id = sbid; end if;
     commit;
     return;
   end if;

   stop_workflow := FALSE;
   new_status_id := NULL;
   new_status_workflow := NULL;
   perform_workflow_activity( surl=>surl, vpoid=>c1rec.poid, sbid=>sbid, wsid=>c1rec.status_workflow, actid=>do_activity,
                              phgid=>c2rec.pid, mfctr_id=>c2rec.manufacturer_id, override_activity_order=>c1rec.override_wflow_order,
                              stop_workflow=>stop_workflow, halt_workflow=>halt_workflow,
                              new_status_id=>new_status_id,
                              new_status_workflow=>new_status_workflow,
                              new_workflow_activity_id=>new_workflow_activity_id );

   --insert into temp values( 'X:' || c1rec.status_workflow || '-' || do_activity || ':' || new_status_id || '-' || new_status_workflow || '-' || new_workflow_activity_id ); commit;
   -- Check if the workflow has initiated a stop command
   if stop_workflow
    then
     update shopping_basket set status = '0', status_mfctr = NULL where shopping_id = sbid;
     if sql%NOTFOUND then update shopping_basket_thread set status = '0', status_mfctr = NULL where thread_id = sbid; end if;
      if_thread_delete(sbid);
     commit;
     return;
   end if;

   -- Status has been set to 20 (Modify Data) or 30 (Assign Manufacturer)
   if halt_workflow
    then
     return;
   end if;

   -- If the workflow initiated a Goto Workflow command then loop around and do it, otherwise exit
   if new_status_workflow is not null
    then
     exit;

   elsif new_workflow_activity_id is null
    then
     exit;

    else
     do_activity := new_workflow_activity_id;
   end if;

  end loop;

  -- Advance to the next status step in the workflow
  -- Requery shopping basket in case the workflow values have changed

  <<NEXT_WORKFLOW_STEP>>

  if new_status_workflow is null
   then
    c1rec := retrieve_workflow_shopping( sbid );
    --open c1(sbid);
    --fetch c1 into c1rec;
    --close c1;
    open c5(c1rec.status_workflow,c1rec.status_priority);
    fetch c5 into c5rec;
    if c5%NOTFOUND
     then
      close c5;
      update shopping_basket set status = '0', status_mfctr = NULL where shopping_id = sbid;
      if sql%NOTFOUND then update shopping_basket_thread set status = '0', status_mfctr = NULL where thread_id = sbid; end if;
      if_thread_delete(sbid);
      commit;
      return;
    end if;
    close c5;

    update shopping_basket set status_id = c5rec.status_id, status_priority = c5rec.status_priority_default, status_mfctr = nvl(c5rec.manufacturer_id,status_mfctr) where shopping_id = sbid;
    if sql%NOTFOUND then update shopping_basket_thread set status_id = c5rec.status_id, status_priority = c5rec.status_priority_default, status_mfctr = nvl(c5rec.manufacturer_id,status_mfctr) where thread_id = sbid; end if;
    commit;

    -- If nothing comes back, then there is nothing left to do
    if nvl(c5rec.status_id,'0') = '0' then exit; end if;

  end if;

  vanswer := NULL;

 end loop;

exception when others then
 glbx.error_details( 'LAB', 'RUN_WORKFLOW', errmsg=>sqlerrm, extdet=>'SBID:' || sbid || ' ANSWER:' || answer );
end run_workflow;

procedure if_thread_delete( sbid in integer )
as

 cursor c1(sbid integer) is select status from shopping_basket where shopping_id = sbid;
 c1rec	c1%ROWTYPE;

begin
 open c1(sbid);
 fetch c1 into c1rec;
 if c1%FOUND
  then
   close c1;
   return;
 end if;
 -- Dont delete if it is waiting for a manufacturer to do something
 if c1rec.status in ('10','20','30')
  then
   null;
  else
   delete from shopping_basket_thread where thread_id = sbid;
 end if;
end if_thread_delete;

procedure assign_invoice( vpoid in integer, current_priority in integer, assign_type in char )
as

 cursor c1(vpoid integer, current_priority integer) is
  select sum(tot) tot
  from
  (
   select count('x') tot
   from shopping_basket
   where poid = vpoid and
         priority_of_item = current_priority and
         invoice_number is null
   union all
   select count('x') tot
   from shopping_basket_thread
   where poid = vpoid and
         priority_of_item = current_priority and
         invoice_number is null
  );

 cursor c2(vpoid integer, current_priority integer) is
  select shopping_id
  from shopping_basket
  where poid = vpoid and
        priority_of_item = current_priority and
        invoice_number is null
  union all
  select shopping_id
  from shopping_basket_thread
  where poid = vpoid and
        priority_of_item = current_priority and
        invoice_number is null;

 c1rec		c1%ROWTYPE;
 new_inv	integer;

begin

 -- Note: Ignoring current_status
 open c1(vpoid, current_priority);
 fetch c1 into c1rec;
 close c1;
 if nvl(c1rec.tot,0) = 0 then return; end if; -- Nothing to do

 if assign_type = 'R'
  then
   select s_shopping_basket_invoice.nextval into new_inv from dual;
  elsif assign_type = 'r'
   then
    select s_shopping_basket_invoice_int.nextval into new_inv from dual;
 end if;

 for c2rec in c2(vpoid, current_priority) loop
  update shopping_basket set invoice_number = new_inv, invoice_date = sysdate where shopping_id = c2rec.shopping_id;
  if sql%NOTFOUND then update shopping_basket_thread set invoice_number = new_inv, invoice_date = sysdate where thread_id = c2rec.shopping_id; end if;
 end loop;
 commit;

end assign_invoice;

procedure cashier(surl varchar2, msg in varchar2 default null)
as

   mfrec	manufacturer%ROWTYPE;
   ltype	varchar2(100);
   stype	integer;
   owner_id	integer;
   sts		varchar2(100);
   pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LAB.CASHIER', iscust=>FALSE );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 mfrec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( mfrec.theme_name );

 glbx.main_title( surl, LNG5.EXT_TXT_183, glbx.backimg(surl,owner_id,pfx.text_back,null),'L20',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 if msg is not null then glbx.header_msg(msg); end if;
 htp.p( '<CENTER>' );
 htp.formopen( 'lab.accept_cashier' );
 htp.formhidden( 'SURL', surl );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.CST_TXT_099),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold(LNG5.EXT_TXT_182),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold(LNG.CST_TXT_051),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;
  for j in 1..10 loop
   htp.tablerowopen;
    htp.tabledata( htf.formtext( 'P1', 20, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.formtext( 'P2', 30, 1000 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.formtext( 'P3', 30, 1000 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG5.EXT_TXT_184 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
  glbx.error_details( 'LAB', 'CASHIER', errmsg=>sqlerrm);
end cashier;

procedure accept_cashier(surl varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY)
as

   cursor c2( vpoid integer ) is select * from purchase_order where poid = vpoid;

   c2rec	c2%ROWTYPE;
   mfrec	manufacturer%ROWTYPE;
   ltype	varchar2(100);
   stype	integer;
   owner_id	integer;
   vpoid	integer;
   gtotal	number;
   foundrec	boolean;
   sts		varchar2(100);
   pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LAB.ACCEPT_CASHIER', iscust=>FALSE );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 mfrec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( mfrec.theme_name );

 glbx.main_title( surl, LNG5.EXT_TXT_185, glbx.backimg(surl,owner_id,pfx.text_back,null),'L20',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'lab.accept_cashier_2' );
 htp.formhidden( 'SURL', surl );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG5.EXT_TXT_186),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold(LNG.CST_TXT_099),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold(LNG5.EXT_TXT_182),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold(LNG.CST_TXT_051),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold(LNG5.EXT_TXT_187),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold(LNG.PHG_TXT_082),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold(LNG.ORD_TXT_179),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;
  htp.formhidden( 'P0', NULL );
  foundrec := FALSE;
  for j in p1.first..p1.last loop
   vpoid := NULL;
   if p1(j) is not null and p2(j) is not null
    then
     begin
       vpoid := to_number(p1(j));
       open c2(vpoid);
       fetch c2 into c2rec;
       if c2%NOTFOUND
        then
         close c2;
         raise no_data_found;
       end if;
       close c2;
     exception when others then
      htp.tablerowopen;
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
       htp.tabledata( LNG5.EXT_TXT_188 || ':' || p1(j),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
       htp.tabledata( p2(j),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
       htp.tabledata( p3(j),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
        htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
       htp.tablerowclose;
       vpoid := NULL;
     end;
   end if;

   if vpoid is not null and p2(j) is not null
    then
     foundrec := TRUE;
     htp.formhidden( 'P1', p1(j) );
     htp.formhidden( 'P2', p2(j) );
     htp.formhidden( 'P3', p3(j) );
     htp.tablerowopen;
     -- Advanced Cashier can approve any request
      if substr(mfrec.man_bf,17,1) = 'T'
       then
        htp.tabledata( htf.formcheckbox( 'P0', p1(j), 'CHECKED' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
       else
        if c2rec.paid_method = 'CHEQUE'
         then
          if c2rec.status in ('Ordered','PreOrder - Confirmed without Payment')
           then
            htp.tabledata( htf.formcheckbox( 'P0', p1(j), 'CHECKED' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
           else
            htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
          end if;
         else
           htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
        end if;
      end if;
      htp.tabledata( htf.bold(p1(j)),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.bold(p2(j)),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( nvl(p3(j),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      gtotal := glbx.grand_total_payment( vpoid, include_gift_certificate=>TRUE );
      htp.tabledata( to_char(nvl(gtotal,0),LNG.MONEY_FORMAT),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      if c2rec.status = 'Ordered'
       then
        htp.tabledata( c2rec.status,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
       else
        htp.tabledata( htf.bold(nvl(c2rec.status,'&nbsp;')),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      end if;
      if c2rec.paid_method = 'CHEQUE'
       then
        htp.tabledata( c2rec.paid_method,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
       else
        htp.tabledata( htf.bold(nvl(c2rec.paid_method,'&nbsp;')),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      end if;
      htp.tablerowclose;
   end if;
  end loop;
 htp.tableclose;
 htp.nl;
 if not foundrec then htp.formhidden( 'P1', null ); htp.formhidden( 'P2', null ); htp.formhidden( 'P3', null ); end if;
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_189 );
 if foundrec then  htp.formsubmit( 'ACTION', LNG5.EXT_TXT_184 ); end if;
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
  glbx.error_details( 'LAB', 'ACCEPT_CASHIER', errmsg=>sqlerrm);
end accept_cashier;

procedure accept_cashier_2(surl varchar2, action in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY)
as

   cursor c2( vpoid integer ) is select * from purchase_order where poid = vpoid;
   cursor c3( vpoid integer ) is
    select shopping_id,status_workflow
    from shopping_basket
    where poid = vpoid
   union all
    select thread_id,status_workflow
    from shopping_basket_thread
    where poid = vpoid
    order by 1;

   c2rec	c2%ROWTYPE;
   mfrec	manufacturer%ROWTYPE;
   ltype	varchar2(100);
   stype	integer;
   owner_id	integer;
   vpoid	integer;
   idx		integer;
   gtotal	number;
   sts		varchar2(100);
   cmnt		varchar2(4000);
   pfx		THEME%ROWTYPE;

   function find_p1(indx integer, p1 in GLBX.MYARRAY )
    return integer
   as
   begin
    for j in p1.first..p1.last loop
     if p1(j) = indx then return( j ); end if;
    end loop;
    return( null );
   end find_p1;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LAB.ACCEPT_CASHIER_2', iscust=>FALSE );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 if action = LNG5.EXT_TXT_189
  then
   lab.cashier( surl, LNG.ORD_TXT_207 );
   return;
 end if;

 mfrec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( mfrec.theme_name );

 glbx.main_title( surl, LNG5.EXT_TXT_190, glbx.backimg(surl,owner_id,pfx.text_back,null),'L20',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.CST_TXT_099),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold(LNG5.EXT_TXT_182),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold(LNG.CST_TXT_051),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;

 for j in p0.first..p0.last loop
  if p0(j) is not null
   then

    idx := find_p1(p0(j),p1);
    if idx is not null
     then
      vpoid := p0(j);
      cmnt := substr(to_char(sysdate,LNG.MASK) || '-' || p3(idx) || chr(10),1,4000);
      update purchase_order
       set
        status = 'Order Payment Received',
        payment_received = 'T',
        cheque_receipt_number = p2(idx),
        order_comment = substr(order_comment || cmnt,1,4000)
      where
       poid = vpoid;

      insert into purchase_audit(poid,column_name,date_changed,action,changed_by,new_value) values (vpoid,'STATUS',sysdate,'U','L','Order Payment Received');
      insert into purchase_audit(poid,column_name,date_changed,action,changed_by,new_value) values (vpoid,'PAYMENT_RECEIVED',sysdate,'U','L','T');
      insert into purchase_audit(poid,column_name,date_changed,action,changed_by,new_value) values (vpoid,'CHEQUE_RECEIPT_NUMBER',sysdate,'U','L',p2(idx));
      insert into purchase_audit(poid,column_name,date_changed,action,changed_by,new_value) values (vpoid,'ORDER_COMMENT',sysdate,'U','L',cmnt);

      -- Restart the Workflow
      for c3rec in c3( vpoid ) loop
       if c3rec.status_workflow is not null
        then
         lab.run_workflow(surl,c3rec.shopping_id,null);
       end if;
      end loop;

     htp.tablerowopen;
      htp.tabledata( htf.bold(p1(idx)),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.bold(p2(idx)),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( nvl(p3(idx),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tablerowclose;
    end if;
  end if;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formopen( 'lab.cashier' );
 htp.formhidden( 'SURL', surl );
 htp.formsubmit( null, LNG5.EXT_TXT_191  );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
  glbx.error_details( 'LAB', 'ACCEPT_CASHIER_2', errmsg=>sqlerrm);
end accept_cashier_2;

procedure mng_booking(surl varchar2)
as
   cursor c1(cmid integer) is
   select
      all_photographers
   from
      manufacturer
   where
      manufacturer_id = cmid;
   cursor c2(cmid integer, all_photo char) is
   select
      pid,
      aid,
      account_name
   from
      customer_account
   where
      ((all_photo != 'F') or (all_photo = 'F' and pid in (select pid from manufacturer_photographer where manufacturer_id = cmid))) and
      customer_disabled = 'F' and
      aid > 0;

   lManufacturerId integer;
   pfx             theme%ROWTYPE;
   see_all         char(1);
   lCount          integer;
begin
   if not dapi.init(surl, 'LAB.MNG_BOOKING') then
      dapi.initFailed(surl);
      return;
   end if;
   lManufacturerId := dapi.getAccountId;
   pfx := dapi.getLFRecord;
   open c1(dapi.getAccountId);
   fetch c1 into see_all;
   close c1;
   dapi.setTitle('Select customer account to work with');

   dapi.pageOpen;
   htp.p('<center>');
   htp.tableOpen(cattributes=>'cellspacing="1" cellpadding="1" border="1"');
   for c2rec in c2(dapi.getAccountId, see_all) loop
      htp.tableRowOpen;
         htp.tableData(htf.anchor('bkn.booking_admin?surl=' || surl || '&acid=' || c2rec.aid, c2rec.account_name), cattributes=>pfx.qcbground);
      htp.tableRowClose;
   end loop;
   htp.tableClose;
   htp.p('</center>');
   dapi.pageClose;
exception when others then
   glbx.error_details('LAB', 'MNG_BOOKING');
end mng_booking;

procedure show_poid( surl in varchar2, vpoid in integer, shp in integer )
as

 cursor c5(vpoid integer) is select * from purchase_order where poid = vpoid;

 c2rec		manufacturer%ROWTYPE;
 purchrec	c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 foundrec	boolean;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 options	GLBX.MYARRAY;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LAB.SHOW_POID', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  c2rec := get_lab_id( surl, owner_id );
  pfx := glbx.get_thm( c2rec.theme_name );

  open c5(vpoid);
  fetch c5 into purchrec;
  close c5;

  glbx.main_title( surl, LNG.PHG_TXT_086, glbx.backimg(surl,owner_id,pfx.text_back,null),'L21',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );

  options(1) := 'BGCOLOUR_HDR:' || pfx.qbground;
  options(2) := 'BGCOLOUR_BDY:' || pfx.qcbground;
  options(3) := 'TABLE:' || 'cellpading=2 cellspacing=2 border=1';
  options(4) := 'LINEFEED';
  options(5) := 'BUSINESS';
  options(6) := 'PURCHASE';
  ord.display_order_details(surl, ltype, purchrec, options);

  options.delete;
  options(1) := 'BGCOLOUR_HDR:' || pfx.qbground;
  options(2) := 'BGCOLOUR_BDY:' || pfx.qcbground;
  options(3) := 'TABLE:' || 'cellpading=2 cellspacing=2 border=1';
  options(4) := 'WORKFLOW';
  if c2rec.sort_on_attribute_id is not null
   then
    options(5) := 'METADATA';
    options(6) := '[' || c2rec.sort_on_attribute_id || ']';
  end if;
  htp.nl;
  ord.display_order_subtotal( surl, ltype, purchrec, options );

  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'SHOW_POID', errmsg=>sqlerrm);
end show_poid;

procedure connectas(surl varchar2, msg in varchar2 default null )
as

 cursor c1(mfid integer) is select * from brand where is_public = 'T' or (is_public = 'F' and manufacturer_id = mfid) order by brand_name;
 cursor c3 is select theme_name from theme order by theme_name;
 cursor c12 is select theme_type from theme_types order by theme_type;

 c2rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 tmp		varchar2(32767);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LAB.CONNECTAS', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  c2rec := get_lab_id( surl, owner_id );
  pfx := glbx.get_thm( c2rec.theme_name );

  glbx.main_title( surl, LNG5.EXT_TXT_548, glbx.backimg(surl,owner_id,pfx.text_back,null),'L22',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
   htp.formopen( 'lab.accept_connectas' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
    -- Username
    htp.tablerowopen;
     htp.tabledata( LNG.GLB_TXT_076,cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext( 'SEARCH_USERNAME', 40, 100 ),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    -- Business Feature
    htp.tablerowopen;
     htp.tabledata( LNG.PHG_TXT_129,cattributes=>pfx.qbground );
      tmp := htf.formselectopen( 'SEARCH_BFTR' );
      tmp := tmp || htf.formselectoption( NULL );
      for c12rec in c12 loop
         tmp := tmp || htf.formselectoption( c12rec.theme_type );
      end loop;
      tmp := tmp || htf.formselectclose;
     htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
    -- Look and Feel
    htp.tablerowopen;
     htp.tabledata( LNG.CST_TXT_235,cattributes=>pfx.qbground );
      tmp := htf.formselectopen( 'SEARCH_LAF' );
      tmp := tmp || htf.formselectoption( NULL );
      for c3rec in c3 loop
         tmp := tmp || htf.formselectoption( c3rec.theme_name );
      end loop;
      tmp := tmp || htf.formselectclose;
     htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
    -- Account Name
    htp.tablerowopen;
     htp.tabledata( LNG.PHG_TXT_164,cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext( 'SEARCH_ANAME', 40, 100 ),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    -- Date Created
    htp.tablerowopen;
     htp.tabledata( LNG.GLB_TXT_078,cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext( 'SEARCH_CREATED', 20, 20 ) || '-' || htf.italic( LNG.MASK ),cattributes=>pfx.qcbground );
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( null, LNG3.ADM_TXT_883 );
   htp.formclose;
   htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'CONNECTAS', errmsg=>sqlerrm);
end connectas;

procedure accept_connectas(surl varchar2, search_username in varchar2, search_bftr in varchar2, search_laf in varchar2, search_aname in varchar2, search_created in varchar2 )
as

 cursor c1(search_username varchar2, search_bftr varchar2, search_laf varchar2, search_aname varchar2, search_created date) is
  select profile_id,username,theme_name,theme_type,account_name
  from customer_profile
  where (
         ((search_username is null) or (search_username is not null and upper(username) like upper(search_username) || '%')) and
         ((search_bftr is null) or (search_bftr is not null and search_bftr = theme_type)) and
         ((search_laf is null) or (search_laf is not null and search_laf = theme_name)) and
         ((search_aname is null) or (search_aname is not null and upper(account_name) like upper(search_aname) || '%')) and
         ((search_created is null) or (search_username is not null and date_created >= search_created ))
        )
  order by account_name,username;

 cursor c3( profid integer ) is select * from customer_contact where login_type = 'PROFILE' and aid = profid;

 c2rec		manufacturer%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 dte		date;
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LAB.ACCEPT_CONNECTAS', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  c2rec := get_lab_id( surl, owner_id );
  pfx := glbx.get_thm( c2rec.theme_name );

  glbx.main_title( surl, LNG5.EXT_TXT_549, glbx.backimg(surl,owner_id,pfx.text_back,null),'L22',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  glbx.reset_cookie( null, TRUE );
  htp.nl;
  htp.p( '<CENTER>' );

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
   -- Username
   htp.tablerowopen;
    htp.tabledata( LNG5.BKN_TXT_136,cattributes=>pfx.qbground );
    htp.tabledata( LNG.GLB_TXT_066, cattributes=>pfx.qbground );
    htp.tabledata( LNG.PHG_TXT_129, cattributes=>pfx.qbground );
    htp.tabledata( LNG3.ADM_TXT_088, cattributes=>pfx.qbground );
   htp.tablerowclose;
   begin dte := to_date(search_created,LNG.MASK); exception when others then dte := NULL; end;
   for c1rec in c1(search_username, search_bftr, search_laf, search_aname, dte ) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor2( 'lab.login_connectas?surl=' || surl || '&profid=' || c1rec.profile_id, c1rec.username, ctarget=>'PROFILE' || to_char(sysdate,'SSSSS')),cattributes=>pfx.qcbground );
    open c3(c1rec.profile_id);
    fetch c3 into c3rec;
    if c3%FOUND
     then
      close c3;
      htp.p( '<TD ' || pfx.qcbground || '>' );
       htp.bold( c1rec.account_name );
       htp.nl;
       htp.p( c3rec.sendto_name );
       htp.nl;
       htp.p( c3rec.sendto_branch || ' ' || c3rec.sendto_department );
       htp.nl;
       htp.p( c3rec.sendto_street || ' ' || c3rec.sendto_suburb || ' ' || c3rec.sendto_city );
       htp.nl;
       htp.p( c3rec.sendto_state || ' ' || c3rec.sendto_postcode || ' ' || c3rec.sendto_country );
       htp.nl;
       htp.p( c3rec.contact_phone || ' ' || c3rec.contact_email );
      htp.p( '</TD>' );
     else
      close c3;
      htp.tabledata( c1rec.account_name, cattributes=>pfx.qcbground );
    end if;
    htp.tabledata( c1rec.theme_type, cattributes=>pfx.qcbground );
    htp.tabledata( c1rec.theme_name, cattributes=>pfx.qcbground );
   htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.formopen( 'lab.connectas' );
   htp.formhidden( 'SURL', surl );
   htp.formsubmit( null, LNG5.EXT_TXT_550 );
   htp.formclose;
   htp.p( '</CENTER>' );
  htp.htmlclose;

exception when others then
 glbx.error_details( 'LAB', 'ACCEPT_CONNECTAS', errmsg=>sqlerrm);
end accept_connectas;

procedure login_connectas(surl in varchar2, profid in integer )
as

 cursor c1(profid integer) is select 'x' from customer_profile where profile_id=profid;
 cursor c2(ltype varchar2, acid integer) is select * from customer_contact where login_type = ltype and aid = acid;
 cursor c3(ltype varchar2, acid integer) is
  select sessid
  from login_session
  where login_type = ltype and
        aid = acid
  order by date_created desc;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c4rec		manufacturer%ROWTYPE;
 newsurl	varchar2(100);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 id		integer;
 lsess		integer;

begin

  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LAB.LOGIN_CONNECTAS', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  c4rec := get_lab_id( surl, owner_id );
  if nvl(substr(c4rec.man_bf,19,1),'F') <> 'T'
   then
    htp.bold('Illegal Access');
    return;
  end if;

  open c1(profid);
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    close c1;
    htp.bold( LNG.PHG_TXT_175 || profid );
    return;
  end if;
  close c1;

 -- select s_login_session.nextval into id from dual;
 id := glbx.get_random_sessionid;
 newsurl := rpad(to_char(id),12,'Z') || glbx.randstring;

 -- Get the last login_session
 open c3( 'PROFILE', profid );
 fetch c3 into lsess;
 close c3;

 open c2('PROFILE',profid);
 fetch c2 into c2rec;
 close c2;
 insert into login_session(screen_type,login_type,sessid,aid,date_created,date_updated,call_ctr, browser, ip_address, securl, guest_email,country,previous_sessid, calling_sessid)
             values (stype,'PROFILE', id, profid, sysdate, sysdate, 1, substr(owa_util.get_cgi_env( 'HTTP_USER_AGENT'),1,100), owa_util.get_cgi_env( 'REMOTE_ADDR'),newsurl, c2rec.contact_email, c2rec.sendto_country,lsess, to_number(replace(substr(surl,1,12),'Z','')) );
 commit;

 -- Merge the Lightbox from the Old Session
 -- Remember if they are logging in, then old session lightbox results might be merged in from the login routine
 update lightbox
    set    sessid = id
    where  sessid = lsess;

 -- Remove duplicate entries
 delete from lightbox lb
   where lb.rowid > (select min(lbx.rowid)
                     from lightbox lbx
                     where lbx.umo_id = lb.umo_id
                      and  lbx.sessid = lb.sessid ) and
          sessid = id;
 commit;

 cst.screen_sze(newsurl);

exception when others then
 glbx.error_details( 'LAB', 'LOGIN_CONNECTAS',owner_id,profid,errmsg=>sqlerrm);
end login_connectas;

procedure receptionist(surl varchar2, msg in varchar2 default null)
as

   mfrec	manufacturer%ROWTYPE;
   ltype	varchar2(100);
   stype	integer;
   owner_id	integer;
   sts		varchar2(100);
   pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LAB.RECEPTIONIST', iscust=>FALSE );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 mfrec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( mfrec.theme_name );

 glbx.main_title( surl, 'Receptionist on Duty', glbx.backimg(surl,owner_id,pfx.text_back,null),'L23',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 if msg is not null then glbx.header_msg(msg); end if;
 htp.p( '<CENTER>' );
 glbx.instruction( 'Enter in the Receptionist Name', pfx );
 htp.formopen( 'lab.accept_receptionist' );
 htp.formhidden( 'SURL', surl );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1', 20, 100 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.formsubmit( null, 'Display the Daily Calendar' );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
  glbx.error_details( 'LAB', 'RECEPTIONIST', errmsg=>sqlerrm);
end receptionist;

procedure accept_receptionist(surl varchar2, p1 in varchar2)
as

   mfrec	manufacturer%ROWTYPE;
   ltype	varchar2(100);
   stype	integer;
   owner_id	integer;
   sts		varchar2(100);
   pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LAB.ACCEPT_RECEPTIONIST', iscust=>FALSE );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 mfrec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( mfrec.theme_name );

 if p1 is null then receptionist( surl, 'Please Enter your Receptionist Name' ); return; end if;

 -- Extract the session id
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'LAB.ACCEPT_RECEPTIONIST', iscust=>FALSE );
 update login_session set guest_email = p1 where sessid = owner_id;
 commit;

 bkn.lab_reception_screen( surl, acid=>mfrec.receptionist_aid, scrolldate=>substr(mfrec.man_bf,21,1) );

exception when others then
  glbx.error_details( 'LAB', 'ACCEPT_RECEPTIONIST', errmsg=>sqlerrm);
end accept_receptionist;

procedure print_list(surl varchar2, msg in varchar2 default null )
as

 cursor c2(mfid integer) is select * from lab_manual_print where manufacturer_id = mfid order by order_by;

 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.PRINT_LIST', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, 'Printing',glbx.backimg(surl,owner_id,pfx.text_back,null),'L24',stype=>greatest(stype-3,1),sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,small_link=>TRUE,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);

 htp.nl;
 htp.anchor2( 'lab.print_details?surl=' || surl || '&printid=', '[Insert]', ctarget=>glbx.truncsurl( surl ) || '_RIGHT' );

 for c2rec in c2(owner_id) loop

  htp.nl;
  htp.anchor2( 'lab.print_details?surl=' || surl || '&printid=' || c2rec.manprint_id, c2rec.name, ctarget=>glbx.truncsurl( surl ) || '_RIGHT' );

 end loop;

 htp.nl;
 htp.nl;
 htp.anchor2( 'lab.print_audit?surl=' || surl, 'View Audit Trail', ctarget=>glbx.truncsurl( surl ) || '_RIGHT' );

 htp.htmlclose;

exception when others then
  glbx.error_details( 'LAB', 'PRINT_LIST', errmsg=>sqlerrm);
end print_list;

procedure print_details(surl varchar2, printid in integer, msg in varchar2 default null )
as

 cursor c2(mfid integer, printid integer) is select * from lab_manual_print where manprint_id = printid and manufacturer_id = mfid;
 cursor c3(printid integer) is select * from lab_manual_print_when where manprint_id = printid order by order_by;
 cursor c4(printid integer) is select * from lab_manual_print_parms where manprint_id = printid;

 c1rec		manufacturer%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.PRINT_DETAILS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 if printid is not null
  then
   open c2(owner_id,printid);
   fetch c2 into c2rec;
   close c2;
 end if;
 pfx := glbx.get_thm( c1rec.theme_name );

 if c2rec.name is null
  then
   glbx.main_title( surl, 'Create New Printing Definition',glbx.backimg(surl,owner_id,pfx.text_back,null),'L24',stype=>greatest(stype-3,1),sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,small_link=>TRUE,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   select s_lab_manual_print.nextval into c2rec.manprint_id from dual; -- Don't care how often it increase, the more random the better.
  else
   glbx.main_title( surl, c2rec.name, glbx.backimg(surl,owner_id,pfx.text_back,null),'L24',stype=>greatest(stype-3,1),sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,small_link=>TRUE,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 end if;

 htp.formopen( 'lab.accept_print_details' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PRINTID', c2rec.manprint_id );

 htp.p( '<CENTER>' );
 htp.nl;
 htp.bold( 'Details' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ');
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Name' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'P1', 30, 100, c2rec.name ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Order By' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'P2', 30, 100, c2rec.order_by ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.bold( 'When the following Condition is Met' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ');
  htp.tablerowopen;
   htp.tabledata( htf.bold('Order By'), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold('Column'), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold('Matches'), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold('Value'), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;
  for c3rec in c3(c2rec.manprint_id) loop
   htp.tablerowopen;
   htp.tabledata( htf.formtext( 'B1', 8, 20, c3rec.order_by ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'B2' );
    htp.formselectoption( NULL );
    if c3rec.option_column = 'Photographer Username' then htp.formselectoption( 'Photographer Username', 'SELECTED' ); else htp.formselectoption( 'Photographer Username' ); end if;
    if c3rec.option_column = 'Photographer Lab Account Id' then htp.formselectoption( 'Photographer Lab Account Id', 'SELECTED' ); else htp.formselectoption( 'Photographer Lab Account Id' ); end if;
    if c3rec.option_column = 'Photographer Business Name' then htp.formselectoption( 'Photographer Business Name', 'SELECTED' ); else htp.formselectoption( 'Photographer Business Name' ); end if;
    if c3rec.option_column = 'Photographer Price Book Code' then htp.formselectoption( 'Photographer Price Book Code', 'SELECTED' ); else htp.formselectoption( 'Photographer Price Book Code' ); end if;
    if c3rec.option_column = 'Product Name' then htp.formselectoption( 'Product Name', 'SELECTED' ); else htp.formselectoption( 'Product Name' ); end if;
    if c3rec.option_column = 'Product Mfctr Code' then htp.formselectoption( 'Product Mfctr Code', 'SELECTED' ); else htp.formselectoption( 'Product Mfctr Code' ); end if;
    if c3rec.option_column = 'Product Xref Mfctr Code' then htp.formselectoption( 'Product Xref Mfctr Code', 'SELECTED' ); else htp.formselectoption( 'Product Xref Mfctr Code' ); end if;
    if c3rec.option_column = 'User Fee Code' then htp.formselectoption( 'User Fee Code', 'SELECTED' ); else htp.formselectoption( 'User Fee Code' ); end if;
    if c3rec.option_column = 'Film Type' then htp.formselectoption( 'Film Type', 'SELECTED' ); else htp.formselectoption( 'Film Type' ); end if;
    if c3rec.option_column = 'FTP Directory' then htp.formselectoption( 'FTP Directory', 'SELECTED' ); else htp.formselectoption( 'FTP Directory' ); end if;
    if c3rec.option_column = 'FTP Name' then htp.formselectoption( 'FTP Name', 'SELECTED' ); else htp.formselectoption( 'FTP Name' ); end if;
    if c3rec.option_column = 'Price Book Name' then htp.formselectoption( 'Price Book Name', 'SELECTED' ); else htp.formselectoption( 'Price Book Name' ); end if;
    if c3rec.option_column = 'Film Name' then htp.formselectoption( 'Film Name', 'SELECTED' ); else htp.formselectoption( 'Film Name' ); end if;
    if c3rec.option_column = 'Image Type' then htp.formselectoption( 'Image Type', 'SELECTED' ); else htp.formselectoption( 'Image Type' ); end if;
    if c3rec.option_column = 'Photographer Price Book Download Name Option' then htp.formselectoption( 'Photographer Price Book Download Name Option', 'SELECTED' ); else htp.formselectoption( 'Photographer Price Book Download Name Option' ); end if;
    if c3rec.option_column = 'Purchase Order Status' then htp.formselectoption( 'Purchase Order Status', 'SELECTED' ); else htp.formselectoption( 'Purchase Order Status' ); end if;
    if c3rec.option_column = 'Purchase Order Paid Method' then htp.formselectoption( 'Purchase Order Paid Method', 'SELECTED' ); else htp.formselectoption( 'Purchase Order Paid Method' ); end if;
    if c3rec.option_column = 'Orientation' then htp.formselectoption( 'Orientation', 'SELECTED' ); else htp.formselectoption( 'Orientation' ); end if;
    if c3rec.option_column = 'Ratio' then htp.formselectoption( 'Ratio', 'SELECTED' ); else htp.formselectoption( 'Ratio' ); end if;
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'B3' );
    htp.formselectoption( NULL );
    if c3rec.option_match = 'Equals' then htp.formselectoption( 'Equals', 'SELECTED' ); else htp.formselectoption( 'Equals' ); end if;
    if c3rec.option_match = 'Like' then htp.formselectoption( 'Like', 'SELECTED' ); else htp.formselectoption( 'Like' ); end if;
    if c3rec.option_match = 'In' then htp.formselectoption( 'In', 'SELECTED' ); else htp.formselectoption( 'In' ); end if;
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.formtext( 'B4', 30, 1000, c3rec.option_value ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
  end loop;
  for j in 1..3 loop
   htp.tablerowopen;
   htp.tabledata( htf.formtext( 'B1', 8, 20 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'B2' );
    htp.formselectoption( NULL );
    htp.formselectoption( 'Photographer Username' );
    htp.formselectoption( 'Photographer Lab Account Id' );
    htp.formselectoption( 'Photographer Business Name' );
    htp.formselectoption( 'Photographer Price Book Code' );
    htp.formselectoption( 'Product Name' );
    htp.formselectoption( 'Product Mfctr Code' );
    htp.formselectoption( 'Product Xref Mfctr Code' );
    htp.formselectoption( 'User Fee Code' );
    htp.formselectoption( 'Film Type' );
    htp.formselectoption( 'FTP Directory' );
    htp.formselectoption( 'FTP Name' );
    htp.formselectoption( 'Price Book Name' );
    htp.formselectoption( 'Film Name' );
    htp.formselectoption( 'Image Type' );
    htp.formselectoption( 'Photographer Price Book Download Name Option' );
    htp.formselectoption( 'Purchase Order Status' );
    htp.formselectoption( 'Purchase Order Paid Method' );
    htp.formselectoption( 'Orientation' );
    htp.formselectoption( 'Ratio' );
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'B3' );
    htp.formselectoption( NULL );
     htp.formselectoption( 'Equals' );
     htp.formselectoption( 'Like' );
     htp.formselectoption( 'In' );
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.formtext( 'B4', 30, 1000 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;

 htp.bold( 'Perform this Activity' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ');
  htp.tablerowopen;
   htp.tabledata( htf.bold('Print Option'), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'PT1' );
    if nvl(c2rec.print_option,'N') = 'N'
     then
      htp.formselectoption( '[N] Not Active', 'SELECTED', cattributes=>'VALUE="N"' );
     else
      htp.formselectoption( '[N] Not Active', cattributes=>'VALUE="N"' );
    end if;
    if c2rec.print_option = 'C'
     then
      htp.formselectoption( '[C] Copy Original from source to target only', 'SELECTED', cattributes=>'VALUE="C"' );
     else
      htp.formselectoption( '[C] Copy Original from source to target only', cattributes=>'VALUE="C"' );
    end if;
    if c2rec.print_option = 'X'
     then
      htp.formselectoption( '[X] Extract Original from database into target only', 'SELECTED', cattributes=>'VALUE="X"' );
     else
      htp.formselectoption( '[X] Extract Original from database into target only', cattributes=>'VALUE="X"' );
    end if;
    if c2rec.print_option = 'P'
     then
      htp.formselectoption( '[P] Create Printing Template in target only', 'SELECTED', cattributes=>'VALUE="P"' );
     else
      htp.formselectoption( '[P] Create Printing Template in target only', cattributes=>'VALUE="P"' );
    end if;
    if c2rec.print_option = 'B'
     then
      htp.formselectoption( '[B] Create Printing Template and Copy from source to target', 'SELECTED', cattributes=>'VALUE="B"' );
     else
      htp.formselectoption( '[B] Create Printing Template and Copy from source to target', cattributes=>'VALUE="B"' );
    end if;
    if c2rec.print_option = 'D'
     then
      htp.formselectoption( '[D] Create Printing Template and Extract from database to target', 'SELECTED', cattributes=>'VALUE="D"' );
     else
      htp.formselectoption( '[D] Create Printing Template and Extract from database to target', cattributes=>'VALUE="D"' );
    end if;
    if c2rec.print_option = 'W'
     then
      htp.formselectoption( '[W] Use Web Service to pass request to another Site', 'SELECTED', cattributes=>'VALUE="W"' );
     else
      htp.formselectoption( '[W] Use Web Service to pass request to another Site', cattributes=>'VALUE="W"' );
    end if;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Move Original into this Directory (target)' || htf.nl ||
                  '(Use &lt;PHG_USERNAME&gt;, &lt;LABID&gt;, &lt;CUST_USERNAME&gt;<BR>or &lt;PHG_ACCT_ID&gt; for Subdirectories'), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
    htp.formtext( 'PT2', 60, 100, replace(replace(replace(c2rec.target_directory,'"','&#34;' ),'<','&lt;'),'>','&gt;') );
    htp.nl;
    if c2rec.prefix_poid = 'T'
     then
      htp.formcheckbox( 'C2', 'T', 'CHECKED' );
     else
      htp.formcheckbox( 'C2', 'T' );
    end if;
    htp.p( ' ' || 'Prefix Poid onto Target Image File Name' );
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Original is located in this Directory (source)'), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'PT3', 60, 100, replace(replace(replace(c2rec.source_directory,'"','&#34;' ),'<','&lt;'),'>','&gt;') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Web Viewable Report'), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
    htp.formtext( 'PT4', 30, 100, c2rec.printing_template );
    htp.nl;
    if c2rec.save_web_quality = 'T'
     then
      htp.formcheckbox( 'C1', 'T', 'CHECKED' );
     else
      htp.formcheckbox( 'C1', 'T' );
    end if;
    htp.p( ' ' || 'Save Web Quality into Target Directory' );
   htp.p( '</TD>' );
  htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Extra Printing Template Tag'), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( 'Tag Value'), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
  for c4rec in c4( c2rec.manprint_id ) loop
   htp.tablerowopen;
    htp.tabledata( htf.formtext( 'PR1', 30, 100, c4rec.parm1 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.formtext( 'PR2', 30, 100, c4rec.parm2 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
  end loop;
  for j in 1..3 loop
   htp.tablerowopen;
    htp.tabledata( htf.formtext( 'PR1', 30, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.formtext( 'PR2', 30, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;

 htp.bold( 'Web Service Option' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ');
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Web Service URL' || htf.nl || htf.italic( 'e.g. mysite/pls/piction/' ) ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'W1', 50, 1000, c2rec.webservice_url ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Encryption Key' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'W2', 50, 1000, c2rec.encryption_key ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Print Key - match with Remote site Print Key' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'W2A', 10, 10, c2rec.webservice_pk ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'On Failure Options' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'W3' );
   if nvl(c2rec.onfailure,'1') = '1'
    then
      htp.formselectoption( 'Do not Retry (no email)', 'SELECTED', cattributes=>'VALUE="1"' );
    else
      htp.formselectoption( 'Do not Retry (no email)', cattributes=>'VALUE="1"' );
   end if;
   if nvl(c2rec.onfailure,'1') = '2'
    then
      htp.formselectoption( 'Do not Retry (email)', 'SELECTED', cattributes=>'VALUE="2"' );
    else
      htp.formselectoption( 'Do not Retry (email)', cattributes=>'VALUE="2"' );
   end if;
   if nvl(c2rec.onfailure,'1') = '3'
    then
      htp.formselectoption( 'Retry every x minutes (no email)', 'SELECTED', cattributes=>'VALUE="3"' );
    else
      htp.formselectoption( 'Retry every x minutes (no email)', cattributes=>'VALUE="3"' );
   end if;
   if nvl(c2rec.onfailure,'1') = '4'
    then
      htp.formselectoption( 'Retry every x minutes (email)', 'SELECTED', cattributes=>'VALUE="4"' );
    else
      htp.formselectoption( 'Retry every x minutes (email)', cattributes=>'VALUE="4"' );
   end if;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Retry every minutes' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'W4', 5, 100, c2rec.retry_every ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Email Address' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'W5', 50, 4000, c2rec.email_address ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'On Success Options' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'W6' );
   if nvl(c2rec.webservice_result_act,'1') = '1'
    then
      htp.formselectoption( 'Email', 'SELECTED', cattributes=>'VALUE="1"' );
    else
      htp.formselectoption( 'Email', cattributes=>'VALUE="1"' );
   end if;
   if nvl(c2rec.webservice_result_act,'1') = '2'
    then
      htp.formselectoption( 'No Email', 'SELECTED', cattributes=>'VALUE="2"' );
    else
      htp.formselectoption( 'No Email', cattributes=>'VALUE="2"' );
   end if;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Test Web Service' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.anchor2( 'lab.testwebservice?surl=' || surl || '&printid=' || printid, 'Press Here to See if Web Service Connection Works', ctarget=>'TESTWEBSERIVCE' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;

 htp.tableclose;
 htp.nl;

 htp.bold( 'Printing Invoice Options' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ');
  htp.tablerowopen;
   if nvl(c2rec.use_printing_invoice,'N') = 'N'
    then
     htp.tabledata( htf.formradio( 'S1', 'N', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    else
     htp.tabledata( htf.formradio( 'S1', 'N' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   end if;
   htp.tabledata( htf.bold( 'Do not Print an Invoice' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"' );
  htp.tablerowclose;
  htp.tablerowopen;
   if c2rec.use_printing_invoice = 'P'
    then
     htp.tabledata( htf.formradio( 'S1', 'P', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    else
     htp.tabledata( htf.formradio( 'S1', 'P' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   end if;
   htp.tabledata( htf.bold( 'Send to Printer' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( 'Printer' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'S2', 50, 1000, c2rec.invoice_printer ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( 'Paper Orientation' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'S3' );
   if nvl(c2rec.invoice_tray,'1') = '1'
    then
      htp.formselectoption( 'Portrait', 'SELECTED', cattributes=>'VALUE="1"' );
    else
      htp.formselectoption( 'Portrait', cattributes=>'VALUE="1"' );
   end if;
   if nvl(c2rec.invoice_tray,'1') = '2'
    then
      htp.formselectoption( 'Landscape', 'SELECTED', cattributes=>'VALUE="2"' );
    else
      htp.formselectoption( 'Landscape', cattributes=>'VALUE="2"' );
   end if;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   if c2rec.use_printing_invoice = 'F'
    then
     htp.tabledata( htf.formradio( 'S1', 'F', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    else
     htp.tabledata( htf.formradio( 'S1', 'F' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   end if;
   htp.tabledata( htf.bold( 'Save Output to a File' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( 'Directory' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'S5', 50, 1000, c2rec.invoice_outputdir ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( 'Filename Mask' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'S6', 50, 1000, c2rec.invoice_filename_mask ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.line, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT" COLSPAN="3"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( 'Use Template' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'S4', 50, 1000, c2rec.invoice_template ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.bold( 'Printing Label Options' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ');
  htp.tablerowopen;
   if nvl(c2rec.use_printing_label,'N') = 'N'
    then
     htp.tabledata( htf.formradio( 'R1', 'N', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    else
     htp.tabledata( htf.formradio( 'R1', 'N' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   end if;
   htp.tabledata( htf.bold( 'Do not Print a Label' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"' );
  htp.tablerowclose;
  htp.tablerowopen;
   if c2rec.use_printing_label = 'P'
    then
     htp.tabledata( htf.formradio( 'R1', 'P', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    else
     htp.tabledata( htf.formradio( 'R1', 'P' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   end if;
   htp.tabledata( htf.bold( 'Send to Printer' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( 'Printer' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'R2', 50, 1000, c2rec.label_printer ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( 'Paper Orientation' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'R3' );
   if nvl(c2rec.label_tray,'1') = '1'
    then
      htp.formselectoption( 'Portrait', 'SELECTED', cattributes=>'VALUE="1"' );
    else
      htp.formselectoption( 'Portrait', cattributes=>'VALUE="1"' );
   end if;
   if nvl(c2rec.label_tray,'1') = '2'
    then
      htp.formselectoption( 'Landscape', 'SELECTED', cattributes=>'VALUE="2"' );
    else
      htp.formselectoption( 'Landscape', cattributes=>'VALUE="2"' );
   end if;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   if c2rec.use_printing_label = 'F'
    then
     htp.tabledata( htf.formradio( 'R1', 'F', 'CHECKED' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    else
     htp.tabledata( htf.formradio( 'R1', 'F' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   end if;
   htp.tabledata( htf.bold( 'Save Output to a File' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( 'Directory' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'R5', 50, 1000, c2rec.label_outputdir ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( 'Filename Mask' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'R6', 50, 1000, c2rec.label_filename_mask ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.line, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT" COLSPAN="3"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( 'Use Template' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'R4', 50, 1000, c2rec.label_template ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 if printid is null
  then
   htp.formsubmit( 'ACTION', 'Insert Printing Definition' );
  else
   htp.formsubmit( 'ACTION', 'Delete' );
   htp.formsubmit( 'ACTION', 'Modify Printing Definition' );
 end if;
 htp.formclose;

 htp.p( '<CENTER>' );
 htp.htmlclose;
exception when others then
  glbx.error_details( 'LAB', 'PRINT_DETAILS', errmsg=>sqlerrm, extdet=>'PRINTID:' || printid);
end print_details;

procedure accept_print_details(surl varchar2, printid in integer, p1 in varchar2, p2 in varchar2, b1 in GLBX.MYARRAY, b2 in GLBX.MYARRAY, b3 in GLBX.MYARRAY, b4 in GLBX.MYARRAY,
                               pt1 in varchar2, pt2 in varchar2, pt3 in varchar2, pt4 in varchar2, pr1 in GLBX.MYARRAY, pr2 in GLBX.MYARRAY,
                               r1 in varchar2, r2 in varchar2, r3 in varchar2, r4 in varchar2, r5 in varchar2, r6 in varchar2, c1 in char default 'F', c2 in char default 'F',
                               s1 in varchar2, s2 in varchar2, s3 in varchar2, s4 in varchar2, s5 in varchar2, s6 in varchar2,
                               w1 in varchar2, w2 in varchar2, w2a in varchar2, w3 in varchar2, w4 in varchar2, w5 in varchar2, w6 in varchar2, action in varchar2 )
as

 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb1		integer;
 nmb2		integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.ACCEPT_PRINT_DETAILS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );

 if action = 'Insert Printing Definition'
  then
   insert into lab_manual_print(manprint_id, manufacturer_id) values (printid, owner_id );
 elsif action = 'Delete'
  then
   delete from lab_manual_print_parms where manprint_id = printid and exists (select 'x' from lab_manual_print where manprint_id = printid and manufacturer_id = owner_id);
   delete from lab_manual_print_when where manprint_id = printid and exists (select 'x' from lab_manual_print where manprint_id = printid and manufacturer_id = owner_id);
   delete from lab_manual_print where manprint_id = printid and manufacturer_id = owner_id;
   commit;
   print_details(surl, null, 'Deleted' );
   return;
 end if;

 begin nmb1 := to_number(p2); exception when others then nmb1 := null; end;
 begin nmb2 := to_number(w4); exception when others then nmb2 := null; end;
 update lab_manual_print
  set
   name = nvl(nvl(p1,name),'No Name'),
   order_by = nmb1,
   print_option = pt1,
   target_directory = pt2,
   source_directory = pt3,
   printing_template = pt4,
   use_printing_label = r1,
   label_printer = r2,
   label_tray = r3,
   label_template = r4,
   label_outputdir = r5,
   label_filename_mask = r6,
   use_printing_invoice = s1,
   invoice_printer = s2,
   invoice_tray = s3,
   invoice_template = s4,
   invoice_outputdir = s5,
   invoice_filename_mask = s6,
   save_web_quality = c1,
   prefix_poid = c2,
   webservice_url = w1,
   encryption_key = w2,
   webservice_pk = nvl(w2a,'PICTION'),
   onfailure = w3,
   retry_every = nmb2,
   webservice_result_act = w6,
   email_address = w5
 where
  manprint_id = printid and
  manufacturer_id = owner_id;

 delete from lab_manual_print_when where manprint_id = printid and exists (select 'x' from lab_manual_print where manprint_id = printid and manufacturer_id = owner_id);
 for j in b1.first..b1.last loop
  if b2(j) is not null
   then
    begin nmb1 := to_number(b1(j)); exception when others then nmb1 := null; end;
    insert into lab_manual_print_when(manprint_id, order_by, option_column, option_match, option_value ) values (printid, nmb1, b2(j), b3(j), b4(j) );
  end if;
 end loop;

 delete from lab_manual_print_parms where manprint_id = printid and exists (select 'x' from lab_manual_print where manprint_id = printid and manufacturer_id = owner_id);
 for j in pr1.first..pr1.last loop
  if pr1(j) is not null
   then
    insert into lab_manual_print_parms(manprint_id, parm1, parm2 ) values (printid, trim(upper(pr1(j))), trim(pr2(j)) );
  end if;
 end loop;

 commit;

 print_details(surl, printid, 'Printing Details Modified' );

exception when others then
  glbx.error_details( 'LAB', 'ACCEPT_PRINT_DETAILS', errmsg=>sqlerrm, extdet=>'PRINTID:' || printid);
end accept_print_details;

function manual_printing_check( surl in varchar2, voidrec in order_style%ROWTYPE, purchord in purchase_order%ROWTYPE )
 return boolean
as

 cursor c1( vpoid integer ) is
  select lmp.manprint_id lmi, sb.shopping_id, sb.phid, lmp.print_option
  from lab_manual_print lmp, purchase_order po, shopping_basket sb
  where lmp.manufacturer_id = sb.lab_id and
        po.is_b2c = 'T' and
        po.poid = sb.poid and
        po.poid = vpoid
  order by sb.shopping_id, lmp.order_by;

 cursor c2( shopid integer ) is select * from shopping_basket where shopping_id = shopid;
 cursor c3( v_umo integer ) is select * from umo where umo_id = v_umo;

 c2rec	c2%ROWTYPE;
 c3rec	c3%ROWTYPE;
 rpr	boolean;
 lpr	integer;

begin

 rpr := FALSE;
 lpr := 0;
 -- insert into temp values ('X1:' || purchord.status); commit;

 for c1rec in c1(purchord.poid) loop
  if lpr <> c1rec.shopping_id then rpr := FALSE; end if;

  if not rpr
   then
    open c2( c1rec.shopping_id );
    fetch c2 into c2rec;
    close c2;
    open c3( c1rec.phid );
    fetch c3 into c3rec;
    close c3;
    if check_print( surl, purchord, c2rec, c3rec, c1rec.lmi )
     then
      if c1rec.print_option = 'W' -- Web Service
       then
        call_run_print( surl, purchord, c2rec, c3rec, c1rec.lmi );
        rpr := TRUE;
        lpr := c1rec.shopping_id;
       else
        run_print( surl, purchord, c2rec, c3rec, c1rec.lmi );
        rpr := TRUE;
        lpr := c1rec.shopping_id;
      end if;
    end if;
  end if;

 end loop;

 return( TRUE );

exception when others then
  glbx.error_details( 'LAB', 'MANUAL_PRINTING_CHECK', errmsg=>sqlerrm, extdet=>'POID:' || purchord.poid);
  return( FALSE );
end manual_printing_check;

function check_print( surl in varchar2, purchord in purchase_order%ROWTYPE, sbrec in shopping_basket%ROWTYPE, umorec in umo%ROWTYPE, lmi in integer )
 return boolean
as

 cursor c1(lmi integer) is select * from lab_manual_print_when where manprint_id = lmi order by order_by;
 cursor c2(phgid integer) is select * from photographer where pid = phgid;

 c2rec  	c2%ROWTYPE;
 comma_delim	GLBX.MYARRAY;
 tmp		varchar2(1000);

 function match( chk varchar2, val varchar2, chkval varchar2 )
  return boolean
 as
 begin
  if nvl(chk,'Equals') = 'Equals'
   then
    return( upper(chkval) = upper(val) );
  elsif chk = 'Like'
   then
    return( chkval like replace(val,'*','%') );
  elsif chk = 'In'
   then
    glbx.comma_delimited(val, comma_delim);
    if comma_delim.count = 0 then return( FALSE ); end if;
    for j in comma_delim.first..comma_delim.last loop
     if comma_delim(j) = chkval then return( TRUE ); end if;
    end loop;
    return( FALSE );
  end if;
  return( FALSE );
 end match;

begin
 open c2(purchord.pid);
 fetch c2 into c2rec;
 close c2;

 -- Keep looping through doing tests until one is false.
 for c1rec in c1( lmi ) loop

  if c1rec.option_column = 'Photographer Username'
   then
    if not match( c1rec.option_match, c1rec.option_value, c2rec.username ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'Photographer Lab Account Id'
   then
    if not match( c1rec.option_match, c1rec.option_value, c2rec.lab_account_id ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'Photographer Business Name'
   then
    if not match( c1rec.option_match, c1rec.option_value, c2rec.business_name ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'Photographer Price Book Code'
   then
    if not match( c1rec.option_match, c1rec.option_value, sbrec.phg_code ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'Product Name'
   then
    if not match( c1rec.option_match, c1rec.option_value, sbrec.name ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'Product Mfctr Code'
   then
    if not match( c1rec.option_match, c1rec.option_value, sbrec.manufctr_code ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'Product Xref Mfctr Code'
   then
    if not match( c1rec.option_match, c1rec.option_value, sbrec.manufctr_code ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'User Fee Code'
   then
    if not match( c1rec.option_match, c1rec.option_value, sbrec.user_fee_code ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'Film Type'
   then
    if not match( c1rec.option_match, c1rec.option_value, sbrec.film_type ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'FTP Directory'
   then
    if not match( c1rec.option_match, c1rec.option_value, sbrec.ftp_virtual_dir ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'FTP Name'
   then
    if not match( c1rec.option_match, c1rec.option_value, sbrec.ftp_location ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'Price Book Name'
   then
    if not match( c1rec.option_match, c1rec.option_value, sbrec.photo_size ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'Film Name'
   then
    if not match( c1rec.option_match, c1rec.option_value, umorec.extras.film_name ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'Image Type'
   then
    if not match( c1rec.option_match, c1rec.option_value, umorec.umo_type ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'Photographer Price Book Download Name Option'
   then
    if not match( c1rec.option_match, c1rec.option_value, sbrec.ppm_title ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'Purchase Order Status'
   then
    if not match( c1rec.option_match, c1rec.option_value, purchord.status ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'Purchase Order Paid Method'
   then
    if not match( c1rec.option_match, c1rec.option_value, purchord.paid_method ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'Orientation'
   then
    if umorec.photo_master.width < umorec.photo_master.height then tmp := 'PORTRAIT';
    elsif umorec.photo_master.width > umorec.photo_master.height then tmp := 'LANDSCAPE';
    elsif umorec.photo_master.width = umorec.photo_master.height then tmp := 'SQUARE';
    else tmp := 'OTHER';
    end if;
    if not match( c1rec.option_match, upper(c1rec.option_value), tmp ) then return( FALSE ); end if;

  elsif c1rec.option_column = 'Ratio'
   then
    if umorec.photo_master.height <> 0
     then
      tmp := '1:' || to_char( round( umorec.photo_master.width / umorec.photo_master.height,2) );
     else
      tmp := '1:0';
    end if;
    if not match( c1rec.option_match, c1rec.option_value, tmp ) then return( FALSE ); end if;

  end if;

 end loop;
 return( TRUE );

exception when others then
  glbx.error_details( 'LAB', 'CHECK_PRINT', errmsg=>sqlerrm, extdet=>'SHOPPING_ID:' || sbrec.shopping_id);
  return( FALSE );
end check_print;

procedure call_run_print( surl in varchar2, purchord in purchase_order%ROWTYPE, sbrec in shopping_basket%ROWTYPE, umorec in umo%ROWTYPE, lmi in integer, forcerun in boolean default FALSE )
as

  cursor c1(lmi integer) is select * from lab_manual_print where manprint_id = lmi;
  cursor c2( vsurl varchar2 ) is select * from manufacturer where manufacturer_id = (select aid from login_session where securl = glbx.truncsurl(surl));

  c1rec		c1%ROWTYPE;
  c2rec		c2%ROWTYPE;
  env 		VARCHAR2(32767);
  x		integer;
  y		integer;
  msg		varchar2(1000);
  gcode		GLBX.MYARRAY;
  gparam	GLBX.MYARRAY;
  emaddr	varchar2(1000);

begin
  -- This procedure will do a remote web service print call

  open c1(lmi);
  fetch c1 into c1rec;
  close c1;

  open c2(surl);
  fetch c2 into c2rec;
  close c2;

  -- setup env tag populate with purchord, sbrec and umorec
  env := soap.generate_webservice(purchord, sbrec, umorec );

  callwebservice(surl, lmi, env, null );
  emaddr := nvl(c1rec.email_address,c2rec.contact_email);
  x := instr( SOAP.G_MESSAGE,'<MESSAGE>');
  --glbx.dbg( SOAP.G_MESSAGE );
  if x = 0
   then
    x := instr( SOAP.G_MESSAGE,'<LAB_PRINT>');
    y := instr( SOAP.G_MESSAGE,'</LAB_PRINT>');
    msg := 'Success:' || substr( SOAP.G_MESSAGE, x, (y-x)+1);
    insert into audit_lab_manual_print(manprint_id,date_printed,poid,poid_status,shopping_id,umo_id,print_option,printed_invoice,printed_label, webservice_result)
     values (lmi,sysdate,purchord.poid,purchord.status,sbrec.shopping_id,umorec.umo_id,c1rec.print_option, 'F', 'F', msg );
    if c1rec.webservice_result_act = 1 and emaddr is not null
     then
      gcode(1) := 'PURCHASE_ORDER_ID';
      gparam(1) := purchord.poid;
      gcode(2) := 'MSG';
      gparam(2) := msg;
      gcode(3) := 'NAME';
      gparam(3) := c2rec.name;
      gcode(4) := 'SIGNATURE';
      gparam(4) := glbx.extract_master_parameter('MAIL SIGNATURE');
      glbx.send( gcode, gparam, 'webservice_print.tmp', p_to=>emaddr, p_subj=>'Web Service Print' || ':'  || purchord.poid, p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'WP1');
    end if;

   else
    -- Failed
    y := instr( SOAP.G_MESSAGE,'</MESSAGE>');
    msg := 'Failed:' || substr( SOAP.G_MESSAGE, x, (y-x)+1);
    insert into audit_lab_manual_print(manprint_id,date_printed,poid,poid_status,shopping_id,umo_id,print_option,printed_invoice,printed_label, webservice_result)
     values (lmi,sysdate,purchord.poid,purchord.status,sbrec.shopping_id,umorec.umo_id,c1rec.print_option, 'F', 'F', msg );
    if c1rec.onfailure in (2,4) and emaddr is not null
     then
      gcode(1) := 'PURCHASE_ORDER_ID';
      gparam(1) := purchord.poid;
      gcode(2) := 'MSG';
      gparam(2) := msg;
      gcode(3) := 'NAME';
      gparam(3) := c2rec.name;
      gcode(4) := 'SIGNATURE';
      gparam(4) := glbx.extract_master_parameter('MAIL SIGNATURE');
      glbx.send( gcode, gparam, 'webservice_print.tmp', p_to=>emaddr, p_subj=>'Web Service Print' || ':'  || purchord.poid, p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'WP1');
    end if;

  end if;
  commit;

  -- Email
  -- c1rec.email_address
  -- c1rec.onfailure 1 (do not retry - no email), 2 (do not retry email), 3 retry every x minutes no email, 4 retry every x minutes with email
  -- c1rec.retry_every
  -- On success Actions
  -- c1rec.webservice_result_act 1 - email, 2 - no email

end call_run_print;

procedure testwebservice(surl in varchar2, printid in integer )
as
begin

 callwebservice(surl, printid, null, '<TEST_PRINT_SERVICE>TRUE</TEST_PRINT_SERVICE>' );

 --htp.htmlopen;

 --htp.header( 2, 'Result from Web Service Call' );
 -- htp.p( soap.xmlconv( SOAP.G_MESSAGE ) );
 --htp.p( '+' || replace(replace(SOAP.G_MESSAGE,'<','&lt;'),'>','&gt;') || '+' );
 htp.p( SOAP.G_MESSAGE );
 --htp.nl;
 --htp.nl;
 --htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;

 --htp.htmlclose;
exception when others then
  glbx.error_details( 'LAB', 'TESTWEBSERVICE', errmsg=>sqlerrm, extdet=>'PRINTID:' || printid);
end testwebservice;

function encrypt_data( input_string in varchar2, ky in varchar2 )
 return varchar2
as
   raw_input           	raw(128);
   raw_key             	raw(128);
   encrypted_raw        raw(2048);

 begin
   raw_key := utl_raw.cast_to_raw(substr(rpad(ky,8,' '),1,8));
   raw_input := utl_raw.cast_to_raw(substr(rpad(input_string,16,' '),1,16));
   dbms_obfuscation_toolkit.desencrypt(input => raw_input, key => raw_key, encrypted_data => encrypted_raw );
   return( rawtohex(encrypted_raw) );

end encrypt_data;

function tcpcall( srv in varchar2, st in varchar2, refr in varchar2, txtin in varchar2 )
 return varchar2
as

  c  	utl_tcp.connection;  -- TCP/IP connection to the Web server
  rt 	PLS_INTEGER;
  xx 	char(2) := chr(13) || chr(10);
  txt 	varchar2(32767);
  txt2 	varchar2(32767);
  i 	integer;
  sd	varchar2(100);

begin
sd := '7d4219b2017e' || to_char(sysdate,'SSSSS');
c := utl_tcp.open_connection(srv, 80);

txt2 := null;
txt2 := txt2 || '-----------------------------' || sd || xx;
txt2 := txt2 || 'Content-Disposition: form-data; name="FILE"; filename="c:\temp\xmlfile.xml"' || xx;
txt2 := txt2 || 'Content-Type: text/xml' || xx; -- text/html causes an Apache Bug.
txt2 := txt2 || xx;
txt2 := txt2 || txtin || xx; -- 28
txt2 := txt2 || '-----------------------------' || sd || '--';

txt := null;
txt := txt || 'POST ' || st || ' HTTP/1.1' || xx;
txt := txt || 'Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*' || xx;
txt := txt || 'Referer: ' || refr || xx;
txt := txt || 'Accept-Language: en-us' || xx;
txt := txt || 'Content-Type: multipart/form-data; boundary=---------------------------' || sd || xx;
txt := txt || 'Accept-Encoding: gzip, deflate' || xx;
txt := txt || 'User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; .NET CLR 1.1.4322)' || xx;
txt := txt || 'Host: ' || srv || xx;
txt := txt || 'Content-Length: ' || length(txt2) || xx;
txt := txt || 'Connection: Close' || xx; -- Close after finishing
txt := txt || 'Cache-Control: no-cache' || xx;

rt := utl_tcp.write_line(c, txt);

rt := utl_tcp.write_line(c, txt2);
i := 0;
txt2 := null;

 begin
  loop
    i := i + 1; if i > 10000 then exit; end if; -- safety
    txt := utl_tcp.get_line(c, true);
    txt2 := txt2 || trim(txt);
    --glbx.dbg( txt );
    --dbms_output.put_line(txt);  -- read result
  end loop;
 exception
  when utl_tcp.end_of_input then
    null; -- end of input
 end;

 utl_tcp.close_connection(c);
 return( txt2 );
exception
 when others then return( 'TCPCALL:' || SQLERRM );
end tcpcall;

procedure callwebservice(surl in varchar2, printid in integer, v_env in varchar2, test_print in varchar2 )
as

  cursor c1(lmi integer) is select * from lab_manual_print where manprint_id = lmi;

  c1rec		c1%ROWTYPE;
  env 		VARCHAR2(32767);
  c  		utl_tcp.connection;
  enckey	varchar2(1000);
  bl		integer;

begin
  open c1(printid);
  fetch c1 into c1rec;
  close c1;
  --glbx.dbg( 'X:' || c1rec.webservice_pk || '-' || c1rec.encryption_key );
  enckey := encrypt_data( c1rec.webservice_pk, c1rec.encryption_key ); -- Encrypt the Key Name, it points to the lab_manual_print

  env := '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance"  xmlns:xsd="http://www.w3.org/1999/XMLSchema">' ||
         '<SOAP-ENV:Body>' ||
         '<WEBSERVICE xmlns="http://host.piction.com/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">Print_Service' ||
         -- encryption key
         test_print ||
         '<ENCRYPTED_KEY>' || enckey || '</ENCRYPTED_KEY>' ||
         v_env ||
         '</WEBSERVICE>' ||
         '</SOAP-ENV:Body>' ||
         '</SOAP-ENV:Envelope>';

 env := tcpcall(substr(c1rec.WEBSERVICE_URL,1,instr(c1rec.WEBSERVICE_URL,'/')-1),
                substr(c1rec.WEBSERVICE_URL,instr(c1rec.WEBSERVICE_URL,'/')) || 'soap.main',
                'http://' || owa_util.get_cgi_env( 'SERVER_NAME' ) || owa_util.get_cgi_env( 'SCRIPT_NAME' ) || owa_util.get_cgi_env( 'PATH_INFO' ),
                env );
 SOAP.G_MESSAGE := substr( env, instr( env, '<?xml version' ) );

exception when others then
 begin utl_tcp.close_connection(c); exception when others then null; end;
  glbx.error_details( 'LAB', 'CALLWEBSERVICE', errmsg=>sqlerrm, extdet=>'PRINTID:' || printid || ' V_ENV:' || v_env || ' TEST_PRINT:' || test_print);
end callwebservice;

function web_sql(webservice_pk in varchar2, encryption_key in varchar2, url in varchar2, typ in varchar2, stmt in varchar2 )
 return varchar2
as

  env 		VARCHAR2(32767);
  c  		utl_tcp.connection;
  enckey	varchar2(1000);
  bl		integer;

begin
  -- web_sql('PICTION','MYKEY','mercury.piction.com/pls/saturnprd2/','DCL','select count(*) from umo')
  enckey := encrypt_data( webservice_pk, encryption_key ); -- Encrypt the Key Name, it points to the lab_manual_print

  env := '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance"  xmlns:xsd="http://www.w3.org/1999/XMLSchema">' ||
         '<SOAP-ENV:Body>' ||
         '<WEBSERVICE xmlns="http://host.piction.com/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">SQL_Request' ||
         -- encryption key
         '<ENCRYPTED_KEY_SQL>' || enckey || '</ENCRYPTED_KEY_SQL>' ||
         '<parameter xsi:type="xsd:string" name="CALL">' || typ || '</parameter>' ||
         '<parameter xsi:type="xsd:string" name="SQL">' || stmt || '</parameter>' ||
         '</WEBSERVICE>' ||
         '</SOAP-ENV:Body>' ||
         '</SOAP-ENV:Envelope>';

 env := tcpcall(substr(url,1,instr(url,'/')-1),
                substr(url,instr(url,'/')) || 'soap.main',
                'http://' || owa_util.get_cgi_env( 'SERVER_NAME' ) || owa_util.get_cgi_env( 'SCRIPT_NAME' ) || owa_util.get_cgi_env( 'PATH_INFO' ),
                env );
 return( substr( env, instr( env, '<?xml version' ) ) );
exception when others then
 begin utl_tcp.close_connection(c); exception when others then null; end;
  glbx.error_details( 'LAB', 'WEB_SQL', errmsg=>sqlerrm);
  return( sqlerrm );
end web_sql;

procedure run_print( surl in varchar2, purchord in purchase_order%ROWTYPE, sbrec in shopping_basket%ROWTYPE, umorec in umo%ROWTYPE, lmi in integer, forcerun in boolean default FALSE )
as

 cursor c1( lmi integer ) is select * from lab_manual_print where manprint_id = lmi;
 cursor c2( lmi integer, vpoid integer, shpid integer) is select 'x' exst from audit_lab_manual_print where manprint_id = lmi and poid = vpoid and shopping_id = shpid;
 cursor c2a( lmi integer, vpoid integer) is select 'x' exst from audit_lab_manual_print where manprint_id = lmi and poid = vpoid;
 cursor c3( lmi integer ) is select * from lab_manual_print_parms where manprint_id = lmi;
 cursor c4( phgid integer ) is select * from photographer where pid = phgid;
 cursor c5( sess_id integer ) is
  select ca.username, ca.photographer_account_id, ca.account_name
  from customer_account ca, login_session ls
  where ls.sessid = sess_id and
        ls.login_type in ('OWNER','CUSTOMER') and
        ls.aid = ca.aid
  union all
  select ca.username, ca.photographer_account_id, ca.account_name
  from customer_account ca, login_session ls, customer_profile cp
  where ls.sessid = sess_id and
        ls.login_type in ('PROFILE','PROFILEG') and
        ls.aid = cp.profile_id and
        cp.aid = ca.aid;

 c1rec	c1%ROWTYPE;
 c2rec	c2%ROWTYPE;
 c2arec	c2a%ROWTYPE;
 c4rec	c4%ROWTYPE;
 c5rec	c5%ROWTYPE;
 res	boolean;
 pi	char(1);
 pl	char(1);
 pm	char(1);
 parm1 	UMP.MYARRAY;
 parm2	UMP.MYARRAY;
 ctr	integer;
 x	integer;
 fname	varchar2(1000);
 dp     GLBX.MYARRAY;
 ext	varchar2(100);
 ext1	varchar2(1000);

 function subs( val in varchar2 )
  return varchar2
 as
  retval	varchar2(4000);
 begin
  retval := val;
  for j in parm1.first..parm1.last loop
   retval := replace( retval, '<' || parm1(j) || '>', parm2(j) );
  end loop;
  return( retval );
 end subs;

begin
 -- Make sure it has not run already
 if not forcerun
  then
   open c2( lmi, purchord.poid, sbrec.shopping_id );
   fetch c2 into c2rec;
   -- Check if it has already run, if so then return.
   if c2%FOUND
    then
     close c2;
     return;
   end if;
   close c2;
 end if;

 -- Run the Manual Print
 open c1( lmi );
 fetch c1 into c1rec;
 close c1;
 ctr := 0;
 for c3rec in c3( lmi ) loop
  ctr := ctr + 1;
  parm1( ctr ) := c3rec.parm1;
  parm2( ctr ) := c3rec.parm2;
 end loop;

 -- Add UMO Values to Template
 ctr := ctr + 1;  parm1( ctr ) := 'UMO_ID'; parm2( ctr ) := umorec.umo_id;
 ctr := ctr + 1;  parm1( ctr ) := 'UMO_TYPE'; parm2( ctr ) := umorec.umo_type;
 ctr := ctr + 1;  parm1( ctr ) := 'FILM_COLOUR'; parm2( ctr ) := umorec.extra_film_colour;
 ctr := ctr + 1;  parm1( ctr ) := 'ROLL_ID'; parm2( ctr ) := umorec.extra_roll_id;
 ctr := ctr + 1;  parm1( ctr ) := 'FILM_SIZE'; parm2( ctr ) := umorec.extra_film_size;
 ctr := ctr + 1;  parm1( ctr ) := 'ORIGINAL_LOC';
 if umorec.umo_type = 'PHOTO'
  then
   parm2( ctr ) := umorec.photo_original_loc;
 elsif umorec.umo_type = 'DOCUMENT'
  then
   parm2( ctr ) := umorec.document_original_loc;
 elsif umorec.umo_type = 'AUDIO'
  then
   parm2( ctr ) := umorec.audio_original_loc;
 elsif umorec.umo_type = 'VIDEO'
  then
   parm2( ctr ) := umorec.video_original_loc;
 elsif umorec.umo_type = 'BLUEPRINT'
  then
   parm2( ctr ) := umorec.blueprint_obj.blueprint_original_loc;
 else
   parm2( ctr ) := 'PHOTO';
 end if;
 ctr := ctr + 1;  parm1( ctr ) := 'FILM_NAME'; parm2( ctr ) := umorec.extras.film_name;

 -- Add Shopping Basket Values to Template
 ctr := ctr + 1;  parm1( ctr ) := 'PRICE_BOOK_NAME';  parm2( ctr ) := sbrec.photo_size;
 ctr := ctr + 1;  parm1( ctr ) := 'PHOTO_COST'; parm2( ctr ) := to_char(sbrec.photo_cost,LNG.MONEY_FORMAT);
 ctr := ctr + 1;  parm1( ctr ) := 'QUANTITY'; parm2( ctr ) := to_char(sbrec.qty);
 ctr := ctr + 1;  parm1( ctr ) := 'MANUFCTR_CODE'; parm2( ctr ) := sbrec.manufctr_code;
 ctr := ctr + 1;  parm1( ctr ) := 'XREF_MFCTR_CODE'; parm2( ctr ) := sbrec.xref_mfctr_code;
 ctr := ctr + 1;  parm1( ctr ) := 'ITEM_DISCOUNTED'; parm2( ctr ) := sbrec.item_discounted;
 ctr := ctr + 1;  parm1( ctr ) := 'ITEM_DISC_CHARGE'; parm2( ctr ) := to_char(sbrec.item_disc_charge);
 ctr := ctr + 1;  parm1( ctr ) := 'PRODUCT_NAME'; parm2( ctr ) := sbrec.name;
 ctr := ctr + 1;  parm1( ctr ) := 'PRODUCT_DESCRIPTION'; parm2( ctr ) := sbrec.product_desc;
 ctr := ctr + 1;  parm1( ctr ) := 'USER_FEE_CODE';  parm2( ctr ) := sbrec.user_fee_code;
 ctr := ctr + 1;  parm1( ctr ) := 'SHOPPING_ID';  parm2( ctr ) := sbrec.shopping_id;

 -- Add Purchase Order Values to Template
 ctr := ctr + 1;  parm1( ctr ) := 'POID';  parm2( ctr ) := purchord.poid;
 ctr := ctr + 1;  parm1( ctr ) := 'CONTACT_NAME';  parm2( ctr ) := purchord.contact_name;
 ctr := ctr + 1;  parm1( ctr ) := 'CONTACT_PHONE';  parm2( ctr ) := purchord.contact_phone;
 ctr := ctr + 1;  parm1( ctr ) := 'SENDTO_NAME';  parm2( ctr ) := purchord.sendto_name;
 ctr := ctr + 1;  parm1( ctr ) := 'SENDTO_STREET';  parm2( ctr ) := purchord.sendto_street;
 ctr := ctr + 1;  parm1( ctr ) := 'SENDTO_SUBURB';  parm2( ctr ) := purchord.sendto_suburb;
 ctr := ctr + 1;  parm1( ctr ) := 'SENDTO_CITY';  parm2( ctr ) := purchord.sendto_city;
 ctr := ctr + 1;  parm1( ctr ) := 'SENDTO_POSTCODE';  parm2( ctr ) := purchord.sendto_postcode;
 ctr := ctr + 1;  parm1( ctr ) := 'SENDTO_COUNTRY';  parm2( ctr ) := purchord.sendto_country;
 ctr := ctr + 1;  parm1( ctr ) := 'BILLING_GPO_BOX';  parm2( ctr ) := purchord.billing_gpo_box;
 ctr := ctr + 1;  parm1( ctr ) := 'BILLING_NAME';  parm2( ctr ) := purchord.billing_name;
 ctr := ctr + 1;  parm1( ctr ) := 'BILLING_STREET';  parm2( ctr ) := purchord.billing_street;
 ctr := ctr + 1;  parm1( ctr ) := 'BILLING_SUBURB';  parm2( ctr ) := purchord.billing_suburb;
 ctr := ctr + 1;  parm1( ctr ) := 'BILLING_CITY';  parm2( ctr ) := purchord.billing_city;
 ctr := ctr + 1;  parm1( ctr ) := 'BILLING_POSTCODE';  parm2( ctr ) := purchord.billing_postcode;
 ctr := ctr + 1;  parm1( ctr ) := 'BILLING_COUNTRY';  parm2( ctr ) := purchord.billing_country;
 ctr := ctr + 1;  parm1( ctr ) := 'BILLING_EMAIL';  parm2( ctr ) := purchord.billing_email;
 ctr := ctr + 1;  parm1( ctr ) := 'BILLING_FAX';  parm2( ctr ) := purchord.billing_fax;
 ctr := ctr + 1;  parm1( ctr ) := 'BILLING_PHONE';  parm2( ctr ) := purchord.billing_phone;
 ctr := ctr + 1;  parm1( ctr ) := 'BILLING_STATE';  parm2( ctr ) := purchord.billing_state;
 ctr := ctr + 1;  parm1( ctr ) := 'SENDTO_STATE';  parm2( ctr ) := purchord.sendto_state;
 ctr := ctr + 1;  parm1( ctr ) := 'SENDTO_BRANCH';  parm2( ctr ) := purchord.sendto_branch;
 ctr := ctr + 1;  parm1( ctr ) := 'SENDTO_DEPARTMENT';  parm2( ctr ) := purchord.sendto_department;
 ctr := ctr + 1;  parm1( ctr ) := 'BILLING_BRANCH';  parm2( ctr ) := purchord.billing_branch;
 ctr := ctr + 1;  parm1( ctr ) := 'BILLING_DEPARTMENT';  parm2( ctr ) := purchord.billing_department;
 ctr := ctr + 1;  parm1( ctr ) := 'MANUAL_SHIP';  parm2( ctr ) := purchord.manual_ship;
 ctr := ctr + 1;  parm1( ctr ) := 'CONTACT_EMAIL';  parm2( ctr ) := purchord.contact_email;
 ctr := ctr + 1;  parm1( ctr ) := 'CHEQUE_RECEIPT_NUMBER';  parm2( ctr ) := purchord.cheque_receipt_number;
 ctr := ctr + 1;  parm1( ctr ) := 'CUSTOMER_COLUMN1';  parm2( ctr ) := purchord.customer_column1;
 ctr := ctr + 1;  parm1( ctr ) := 'CUSTOMER_COLUMN2';  parm2( ctr ) := purchord.customer_column2;
 ctr := ctr + 1;  parm1( ctr ) := 'CUSTOMER_COLUMN3';  parm2( ctr ) := purchord.customer_column3;
 ctr := ctr + 1;  parm1( ctr ) := 'CUSTOMER_COLUMN4';  parm2( ctr ) := purchord.customer_column4;
 ctr := ctr + 1;  parm1( ctr ) := 'CUSTOMER_COLUMN5';  parm2( ctr ) := purchord.customer_column5;
 ctr := ctr + 1;  parm1( ctr ) := 'CUSTOMER_COLUMN6';  parm2( ctr ) := purchord.customer_column6;
 ctr := ctr + 1;  parm1( ctr ) := 'DO_NOT_SPLIT_ORDER';  parm2( ctr ) := purchord.do_not_split_order;
 ctr := ctr + 1;  parm1( ctr ) := 'MERCHANT_REFERENCE';  parm2( ctr ) := purchord.merchant_reference;
 ctr := ctr + 1;  parm1( ctr ) := 'GST_INCL';  parm2( ctr ) := purchord.gst_incl;
 ctr := ctr + 1;  parm1( ctr ) := 'PROJECT_CODE';  parm2( ctr ) := purchord.project_code;
 ctr := ctr + 1;  parm1( ctr ) := 'SHIPPING_MESSAGE';  parm2( ctr ) := purchord.shipping_message;

 -- Special Values
 open c4( purchord.pid );
 fetch c4 into c4rec;
 close c4;
 open c5( purchord.sessid );
 fetch c5 into c5rec;
 close c5;
 ctr := ctr + 1;  parm1( ctr ) := 'BUSINESS_NAME';  parm2( ctr ) := c4rec.business_name;
 ctr := ctr + 1;  parm1( ctr ) := 'PHG_USERNAME';  parm2( ctr ) := c4rec.username;
 ctr := ctr + 1;  parm1( ctr ) := 'LABID';  parm2( ctr ) := c4rec.lab_account_id;
 ctr := ctr + 1;  parm1( ctr ) := 'CUST_USERNAME';  parm2( ctr ) := c5rec.username;
 ctr := ctr + 1;  parm1( ctr ) := 'PHG_ACCT_ID';  parm2( ctr ) := c5rec.photographer_account_id;
 ctr := ctr + 1;  parm1( ctr ) := 'ACCOUNT_NAME';  parm2( ctr ) := c5rec.account_name;
 ctr := ctr + 1;  parm1( ctr ) := 'IMGNAME';  parm2( ctr ) := ''; -- done this way to avoid getting no data found error
 parm2( ctr ) := 'file:///' || subs(c1rec.target_directory) || DECS.UNIX_OR_NT || 'i' || sbrec.shopping_id || '.jpg';

 pi := 'N';
 pm := 'N';
 res := FALSE;
 if c1rec.print_option in ('C','B')
  then
   -- Copy Original Image
   if sbrec.qty = 1
    then
     fname := umorec.extras.film_name;
     -- Create the directory if it doesn't exist
     res := os_command.make_directory( subs(c1rec.target_directory), dp );
     if glbx.extract_fname(fname,'SUFFIX') is null then fname := fname || '.jpg'; end if;
     if c1rec.prefix_poid = 'T' then ext := 'P' || purchord.poid || '_'; end if;
     res := ump.file_copy( source=>subs(c1rec.source_directory) || DECS.UNIX_OR_NT || fname, destination=>subs(c1rec.target_directory) || DECS.UNIX_OR_NT || ext || fname );
     if res then pm := c1rec.print_option; else pm := 'F'; end if;
    else
     for j in 1..sbrec.qty loop
      x := instr(umorec.extras.film_name,'.');
      if x = 0
       then
        fname := umorec.extras.film_name || '_' || to_char(j);
       else
        fname := substr(umorec.extras.film_name,1,x-1) || '_' || to_char(j) || substr( umorec.extras.film_name,x);
      end if;
      if glbx.extract_fname(fname,'SUFFIX') is null then fname := fname || '.jpg'; end if;
      ext1 := umorec.extras.film_name;
      if glbx.extract_fname(ext1,'SUFFIX') is null then ext1 := ext1 || '.jpg'; end if;
      if c1rec.prefix_poid = 'T' then ext := 'P' || purchord.poid || '_'; end if;
      res := ump.file_copy( source=>subs(c1rec.source_directory) || DECS.UNIX_OR_NT || ext1,
                            destination=>subs(c1rec.target_directory) || DECS.UNIX_OR_NT || ext || fname );
      if res then pm := c1rec.print_option; else pm := 'F'; end if;
     end loop;
   end if;
 end if;

 if c1rec.print_option in ('X','D')
  then
   -- Extract Original Image from Database
   if sbrec.qty = 1
    then
     res := ump.file_extract_source( v_umo=>umorec.umo_id, acid=>umorec.aid, utype=>'MASTER', destination=>subs(c1rec.target_directory));
     if res then pm := c1rec.print_option; else pm := 'F'; end if;
    else
     for j in 1..sbrec.qty loop
      res := ump.file_extract_source( v_umo=>umorec.umo_id, acid=>umorec.aid, utype=>'MASTER',
                                      destination=>subs(c1rec.target_directory));
      if res then pm := c1rec.print_option; else pm := 'F'; end if;
     end loop;
   end if;
 end if;

 if c1rec.print_option in ('P','B','D')
  then
   -- Create the directory if it doesn't exist
   res := os_command.make_directory( subs(c1rec.target_directory), dp );
   -- Create Printing Template
   res := ump.file_printer_template( template=>c1rec.printing_template, destination=>subs(c1rec.target_directory), destfilename=>'print_job_' || purchord.poid || '_' || sbrec.shopping_id || '.' || glbx.extract_fname(c1rec.printing_template,'SUFFIX'), parm1=>parm1, parm2=>parm2 );
   if res then pm := c1rec.print_option; else pm := 'F'; end if;

   -- put exception around for webservice call protection.
   begin
   if c1rec.save_web_quality = 'T' and dbms_lob.getlength(umorec.photo_master.source.localdata) > 0
    then
     utl_lob.unloadtofile(umorec.photo_master.source.localdata, subs(c1rec.target_directory) || DECS.UNIX_OR_NT || 'i' || sbrec.shopping_id || '.jpg', x);
   end if;
   exception when others then null;
   end;

 end if;

 if c1rec.print_option in ('W')
  then
   call_run_print( surl, purchord, sbrec, umorec, lmi );
 end if;

 -- Make sure it has not run and printed and invoice
 if not forcerun
  then
   open c2a( lmi, purchord.poid );
   fetch c2a into c2arec;
   -- Check if it has already run, if so then return.
   if c2a%FOUND
    then
     close c2a;
     return;
   end if;
   close c2a;
 end if;

 -- Print Invoice
 res := FALSE;
 if c1rec.use_printing_invoice = 'P'
  then
   -- Using the C Program to Print
   res := ump.file_print( printer_name=>c1rec.invoice_printer, lptid=>nvl(to_number(c1rec.invoice_tray),1), print_template=>c1rec.invoice_template, parm1=>parm1, parm2=>parm2 );

 elsif c1rec.use_printing_invoice = 'F'
  then
   -- Create Printing invoice and Save to File
   res := ump.file_printer_template( template=>c1rec.invoice_template, destination=>subs(c1rec.invoice_outputdir), destfilename=>subs(c1rec.invoice_filename_mask), parm1=>parm1, parm2=>parm2 );

 end if;
 if res then pi := c1rec.use_printing_invoice; else pi := 'F'; end if;

 -- Print Label
 res := FALSE;
 if c1rec.use_printing_label = 'P'
  then
   -- Using the C Program to Print
   res := ump.file_print( printer_name=>c1rec.label_printer, lptid=>nvl(to_number(c1rec.label_tray),2), print_template=>c1rec.label_template, parm1=>parm1, parm2=>parm2 );

 elsif c1rec.use_printing_label = 'F'
  then
   -- Create Printing Label and Save to File
   res := ump.file_printer_template( template=>c1rec.label_template, destination=>subs(c1rec.label_outputdir), destfilename=>subs(c1rec.label_filename_mask), parm1=>parm1, parm2=>parm2 );

 end if;
 if res then pl := c1rec.use_printing_label; else pl := 'F'; end if;

 insert into audit_lab_manual_print(manprint_id,date_printed,poid,poid_status,shopping_id,umo_id,print_option,printed_invoice,printed_label)
  values (lmi,sysdate,purchord.poid,purchord.status,sbrec.shopping_id,umorec.umo_id,c1rec.print_option, pi, pl );

 commit;

exception when others then
  glbx.error_details( 'LAB', 'RUN_PRINT', errmsg=>sqlerrm, extdet=>'SHOPPING_ID:' || sbrec.shopping_id);
end run_print;

procedure print_audit(surl varchar2, msg in varchar2 default null )
as

 cursor c2( mfid integer) is
  select aud.date_printed,aud.poid,aud.poid_status,aud.shopping_id,aud.umo_id,aud.print_option,aud.printed_invoice,aud.printed_label,lmp.name
  from audit_lab_manual_print aud, lab_manual_print lmp
  where aud.manprint_id = lmp.manprint_id and
        manufacturer_id = mfid
  order by aud.date_printed desc;

 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.PRINT_AUDIT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, 'Last 100 Print Jobs', glbx.backimg(surl,owner_id,pfx.text_back,null),'L24',stype=>greatest(stype-3,1),sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,small_link=>TRUE,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ');
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Date' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Print' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Purchase Id' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Status' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Shopping Id' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'UMO Id' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Print Option' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Printed Invoice' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Printed Label' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;
 for c2rec in c2( owner_id ) loop
  if c2%ROWCOUNT > 100 then exit; end if;
  htp.tablerowopen;
   htp.tabledata( to_char(c2rec.date_printed,LNG.TSMASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( c2rec.name, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( c2rec.poid, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( c2rec.poid_status, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( c2rec.shopping_id, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( c2rec.umo_id, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( c2rec.print_option, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( c2rec.printed_invoice, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( c2rec.printed_label, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
exception when others then
  glbx.error_details( 'LAB', 'PRINT_AUDIT', errmsg=>sqlerrm );
end print_audit;

procedure manual_payment(surl varchar2, msg in varchar2 default null )
as

 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.MANUAL_PAYMENT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, 'Manual Payment',glbx.backimg(surl,owner_id,pfx.text_back,null),'L25',stype=>greatest(stype-3,1),sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,small_link=>TRUE,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 htp.nl;
 htp.formopen( 'lab.accept_manual_payment' );
 htp.formhidden( 'SURL', surl );

 if substr(c1rec.man_bf,21,1) = 'T'
  then
   htp.bold( 'Restricted to Booking Orders Only' );
 end if;

 -- Enter in Purchase Order Id
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ');
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Purchase Order Id' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.formtext( 'P1', 10, 20 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 -- Search for Purchase Order
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ');
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Name of Customer' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.formtext( 'P2', 100, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Address of Customer' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.formtext( 'P3', 100, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Date Purchased From' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.formtext( 'P4', 30, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Date Purchased To' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.formtext( 'P5', 30, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.formsubmit( 'ACTION', 'Search for Purchase Order(s)' );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
  glbx.error_details( 'LAB', 'MANUAL_PAYMENT', errmsg=>sqlerrm);
end manual_payment;

procedure accept_manual_payment(surl varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, action in varchar2 default null )
as

 cursor c2( manid integer, vp1 integer, p2 varchar2, p3 varchar2, d1 date, d2 date, bk char ) is
  select /*+ ALL_ROWS */ poid, po.date_created, sendto_name, billing_name, sendto_street, billing_street, sendto_suburb, billing_suburb, sendto_city, billing_city, status, billing_email, billing_phone,
         sendto_branch, billing_branch, sendto_department, billing_department, po.contact_email, paid_method, sendto_country, billing_country, contact_phone, sendto_postcode, billing_postcode
  from purchase_order po, manufacturer_photographer mp, manufacturer m
  where
   ( (vp1 is null) or (vp1 is not null and poid = vp1)) and
   ( (p2 is null) or (p2 is not null and upper(sendto_name || billing_name || po.contact_email) like '%' || upper(p2) || '%')) and
   ( (p3 is null) or (p3 is not null and upper(sendto_branch || billing_branch || sendto_suburb || billing_suburb || sendto_street || billing_street || sendto_suburb|| billing_suburb || sendto_city || billing_city) like '%' || upper(p3) || '%')) and
   ( (d1 is null) or (d1 is not null and po.date_created >= d1) ) and
   ( (d2 is null) or (d2 is not null and po.date_created <= d2) ) and
   mp.pid = po.pid and
   m.manufacturer_id = manid and
   m.manufacturer_id = mp.manufacturer_id and
   m.all_photographers = 'F' and
   bk = 'F' and
   po.status in ('PreOrder','PreOrder - Sent to Bank','PreOrder - Confirmed without Payment','Awaiting Authorisation','Ordered', 'Order Authorised','Order Payment Received','Processing','Sent to Lab','Received by Lab','Processed by Lab','Order Completed','On Hold','Lab Problems' )
  union all
  select /*+ ALL_ROWS */ poid, po.date_created, sendto_name, billing_name, sendto_street, billing_street, sendto_suburb, billing_suburb, sendto_city, billing_city, status, billing_email, billing_phone,
         sendto_branch, billing_branch, sendto_department, billing_department, po.contact_email, paid_method, sendto_country, billing_country, contact_phone, sendto_postcode, billing_postcode
  from purchase_order po
  where
   ( (vp1 is null) or (vp1 is not null and poid = vp1)) and
   ( (p2 is null) or (p2 is not null and upper(sendto_name || billing_name || po.contact_email) like '%' || upper(p2) || '%')) and
   ( (p3 is null) or (p3 is not null and upper(sendto_branch || billing_branch || sendto_suburb || billing_suburb || sendto_street || billing_street || sendto_suburb|| billing_suburb || sendto_city || billing_city) like '%' || upper(p3) || '%')) and
   ( (d1 is null) or (d1 is not null and po.date_created >= d1) ) and
   ( (d2 is null) or (d2 is not null and po.date_created <= d2) ) and
   bk = 'T'
  order by 1;

 cursor c3( vpoid integer ) is select qty, photo_cost, photo_size from shopping_basket where poid = vpoid;

 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 vp1		integer;
 d1		date;
 d2		date;
 bk		char(1);
 tcost		number;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.ACCEPT_MANUAL_PAYMENT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, 'Purchase Order Details',glbx.backimg(surl,owner_id,pfx.text_back,null),'L25',stype=>greatest(stype-3,1),sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,small_link=>TRUE,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;
 begin vp1 := to_number(p1); exception when others then vp1 := null; end;
 begin d1 := to_date(p4, LNG.MASK ); exception when others then d1 := null; end;
 begin d2 := to_date(p5, LNG.MASK ); exception when others then d2 := null; end;
 if vp1 is null and p2 is null and p3 is null and d1 is null and d2 is null
  then
   manual_payment( surl, 'Please Enter in Search Parameters' );
   return;
 end if;

 bk := 'F';
 if substr(c1rec.man_bf,24,1) = 'T'
  then
   bk := 'T';
 end if;

 -- Enter in Purchase Order Id
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ');
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Purchase Order Id' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Grand Total' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Status' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Paid Method' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Send Details' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Billing Details' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Shopping Basket' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;

  for c2rec in c2(c1rec.manufacturer_id, vp1, p2, p3, d1, d2, bk) loop
  htp.tablerowopen;
   htp.tabledata( htf.anchor( 'lab.manpay?surl=' || surl || '&vpoid=' || c2rec.poid, c2rec.poid ) || ' ' ||
                  htf.anchor2( 'lab.show_poid?surl=' || surl || '&vpoid=' || c2rec.poid || '&shp=', '[' || 'Details' || ']', ctarget=>'WIN' || c2rec.poid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   tcost := nvl(glbx.grand_total_payment(c2rec.poid, include_gift_certificate=>FALSE),0);
   htp.tabledata( to_char(tcost,LNG.MONEY_FORMAT), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="RIGHT"' );
   htp.tabledata( c2rec.status, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( nvl(c2rec.paid_method,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
    htp.p( c2rec.sendto_name || ' ' || c2rec.contact_email); htp.nl;
    if c2rec.sendto_department is not null or c2rec.sendto_branch is not null
     then
      htp.p( c2rec.sendto_branch || ' ' || c2rec.sendto_department ); htp.nl;
    end if;
    htp.p( c2rec.sendto_street || ' ' || c2rec.sendto_suburb ); htp.nl;
    htp.p( c2rec.sendto_city || ' ' || c2rec.sendto_postcode ); htp.nl;
    htp.p( c2rec.contact_phone || ' ' || c2rec.sendto_country ); htp.nl;
   htp.p( '</TD>' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
    htp.p( c2rec.billing_name || ' ' || c2rec.billing_email); htp.nl;
    if c2rec.billing_department is not null or c2rec.billing_branch is not null
     then
      htp.p( c2rec.billing_branch || ' ' || c2rec.billing_department ); htp.nl;
    end if;
    htp.p( c2rec.billing_street || ' ' || c2rec.billing_suburb ); htp.nl;
    htp.p( c2rec.billing_city || ' ' || c2rec.billing_postcode ); htp.nl;
    htp.p( c2rec.billing_phone || ' ' || c2rec.billing_country ); htp.nl;
   htp.p( '</TD>' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
   for c3rec in c3(c2rec.poid) loop
    if c3%ROWCOUNT > 1 then htp.nl; end if;
    htp.p( c3rec.qty || ' x ' || c3rec.photo_size || ' ' || to_char(c3rec.photo_cost,LNG.MONEY_FORMAT) );
   end loop;
   htp.p( '</TD>' );
  htp.tablerowclose;
  end loop;

 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.formopen( 'lab.manual_payment' );
  htp.formhidden( 'SURL', surl );
  htp.formsubmit( null, 'Try Another Search' );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
  glbx.error_details( 'LAB', 'ACCEPT_MANUAL_PAYMENT', errmsg=>sqlerrm);
end accept_manual_payment;

procedure manpay(surl varchar2, vpoid in integer, msg in varchar2 default null )
as

 cursor c2( vpoid integer ) is select * from purchase_order where poid = vpoid;
 cursor c3( vpoid integer ) is select shopping_id, qty, photo_cost, photo_size, status_workflow from shopping_basket where poid = vpoid;
 cursor c4 is select order_option from workflow_state_options where work_state = 0 order by order_by;
 cursor c5( vpoid integer ) is
  select column_name, new_value, date_changed dt
  from purchase_audit
  where poid = vpoid and
        (
         (column_name = 'LAST_STEP' and new_value in ('Finalise','Step 7')) or
         (column_name = 'REFUND_TOTAL') or
         (column_name = 'Part Payment')
        )
  order by date_changed;

 c1rec		manufacturer%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 amt		number;
 pt		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.MANPAY', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, 'Manage Payments for ' || vpoid, glbx.backimg(surl,owner_id,pfx.text_back,null),'L26',stype=>greatest(stype-3,1),sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,small_link=>TRUE,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 htp.nl;
 open c2(vpoid);
 fetch c2 into c2rec;
 close c2;
 htp.formopen( 'lab.accept_manpay' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'VPOID', vpoid );
 htp.formhidden( 'SB1', null );
 htp.formhidden( 'SB2', null );

 -- Detail Payments Already Made
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ');
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Purchase Order Id' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( c2rec.poid ) ||
                  htf.anchor2( 'lab.show_poid?surl=' || surl || '&vpoid=' || c2rec.poid || '&shp=', '[' || 'Details' || ']', ctarget=>'WIN' || c2rec.poid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Status' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'P4' );
   for c4rec in c4 loop
    if c4rec.order_option = c2rec.status
     then
      htp.formselectoption( c4rec.order_option,'SELECTED' );
     else
      htp.formselectoption( c4rec.order_option );
    end if;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Purchase Order Total' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( nvl(to_char(glbx.grand_total_payment(c2rec.poid, FALSE ), LNG.MONEY_FORMAT), 'No Total') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Initial Order Total' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( nvl(to_char(c2rec.initial_grand_total, LNG.MONEY_FORMAT), 'No Total') ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Paid Method' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'P5' );
    if c2rec.paid_method = 'MERCHANT' then htp.formselectoption( 'MERCHANT','SELECTED' ); else htp.formselectoption( 'MERCHANT' ); end if;
    if c2rec.paid_method = 'GIFT' then htp.formselectoption( 'GIFT','SELECTED' ); else htp.formselectoption( 'GIFT' ); end if;
    if c2rec.paid_method = 'CHEQUE' then htp.formselectoption( 'CHEQUE','SELECTED' ); else htp.formselectoption( 'CHEQUE' ); end if;
    if c2rec.paid_method = 'PHONE' then htp.formselectoption( 'PHONE','SELECTED' ); else htp.formselectoption( 'PHONE'); end if;
    if c2rec.paid_method = 'BILLING' then htp.formselectoption( 'BILLING','SELECTED' ); else htp.formselectoption( 'BILLING' ); end if;
    if c2rec.paid_method = 'AUTHORISATION' then htp.formselectoption( 'AUTHORISATION','SELECTED' ); else htp.formselectoption( 'AUTHORISATION' ); end if;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Shopping Basket Items' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
   for c3rec in c3(c2rec.poid) loop
    if c3%ROWCOUNT > 1 then htp.nl; end if;
    if substr( c1rec.man_bf,24,1) = 'T'
     then
      htp.p( htf.formhidden( 'SB1', c3rec.shopping_id ) || htf.formtext( 'SB2', 5, 10, c3rec.qty) || ' x ' || c3rec.photo_size || ' ' || to_char(c3rec.photo_cost,LNG.MONEY_FORMAT) );
     else
      htp.p( c3rec.qty || ' x ' || c3rec.photo_size || ' ' || to_char(c3rec.photo_cost,LNG.MONEY_FORMAT) );
    end if;
    if c3rec.status_workflow is not null
     then
      htp.p( ' ' );
      htp.anchor2( 'lab.manrun_workflow?surl=' || glbx.truncsurl(surl) || '&shpid=' || c3rec.shopping_id, 'Workflow Control Centre', ctarget=>'WORKFLOW_CENTRE' );
    end if;
   end loop;
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 -- Payments already made
 htp.bold( 'Payments Already Made' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ');
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Date Paid' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Amount Paid' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Payment Type' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;
  for c5rec in c5( c2rec.poid ) loop
  htp.tablerowopen;
   htp.tabledata( to_char( c5rec.dt, LNG.TSMASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   if c5rec.column_name = 'LAST_STEP'
    then
     amt := nvl(glbx.grand_total_payment(c2rec.poid, include_gift_certificate=>FALSE),0);
     pt := 'Initial Payment';
   elsif c5rec.column_name = 'REFUND_TOTAL'
    then
     amt := to_number( c5rec.new_value ) * -1;
     pt := 'Refund';
    else
     amt := to_number( c5rec.new_value );
     pt := 'Manual Payment';
   end if;
   htp.tabledata( to_char( amt, LNG.MONEY_FORMAT), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( pt, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  end loop;

  htp.tablerowopen;
   htp.tabledata( htf.line, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER" COLSPAN="3"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'New Manual Payment' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.formtext( 'P1', 30, 100 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.line, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER" COLSPAN="3"' );
  htp.tablerowclose;
  if c2rec.refund_total is null
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Refund' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tabledata( htf.formtext( 'P2', 30, 100 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"' );
    htp.tablerowclose;
   else
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Refund' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tabledata( htf.formtext( 'P2', 30, 100, to_char(c2rec.refund_total,LNG.MONEY_FORMAT) ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold( 'Only one Refund can be given. You can only change the original amount that was refunded.' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
    htp.tablerowclose;
  end if;
 htp.tableclose;

 htp.nl;
 htp.formsubmit( 'ACTION', 'Add New Payment or Modify Payment Details' );
 htp.formsubmit( 'ACTION', 'Perform Another Search' );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
  glbx.error_details( 'LAB', 'MANPAY', errmsg=>sqlerrm);
end manpay;

procedure accept_manpay(surl varchar2, vpoid in integer, p1 in varchar2, p2 in varchar2, p4 in varchar2, p5 in varchar2, action in varchar2, sb1 in GLBX.MYARRAY, sb2 in GLBX.MYARRAY )
as

 cursor c2( vpoid integer ) is select * from purchase_order where poid = vpoid;
 cursor c3( void integer ) is select * from order_style where oid = void;

 c1rec		manufacturer%ROWTYPE;
 c2rec		c2%ROWTYPE;
 voidrec	c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 nmb		number;
 nmb2		number;

begin
 if action = 'Perform Another Search'
  then
   manual_payment( surl );
   return;
 end if;

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.MANPAY', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 open c2(vpoid);
 fetch c2 into c2rec;
 close c2;
 open c3(c2rec.oid);
 fetch c3 into voidrec;
 close c3;

 nmb := glbx.conv_nmb(p1,'MONEY');
 nmb2 := glbx.conv_nmb(p2,'MONEY');

 if nmb is not null
  then
   fname.purchase_audit_trail( surl, c2rec.poid, 'Part Payment', 'U', 'C', p1, c2rec, voidrec);
 end if;

 -- Refund
 if nmb2 is not null and nvl(nmb2,0) <> nvl(c2rec.refund_total,0)
  then
   update purchase_order
    set
     refund_total = nmb2,
     refund_date = sysdate
   where
    poid = c2rec.poid;
   fname.purchase_audit_trail( surl, c2rec.poid, 'REFUND_TOTAL', 'U', 'C', to_char(nmb2), c2rec, voidrec);
 end if;

 -- Paid Method
 if c2rec.paid_method <> p5
  then
   update purchase_order
    set
     paid_method = p5
   where
    poid = c2rec.poid;
   fname.purchase_audit_trail( surl, c2rec.poid, 'PAID_METHOD', 'U', 'C', p5, c2rec, voidrec);
 end if;

 -- Update Status. Might initiate a change in workflow
 if c2rec.status <> p4
  then
   update purchase_order
    set
     status = p4
   where
    poid = c2rec.poid;
   fname.purchase_audit_trail( surl, c2rec.poid, 'STATUS', 'U', 'C', p4, c2rec, voidrec);
 end if;

 if substr( c1rec.man_bf,24,1) = 'T'
  then
   for j in sb1.first..sb1.last loop
    if sb1(j) is not null
     then
      nmb := null;
      begin nmb := to_number(sb2(j)); exception when others then nmb := null; end;
      if nmb < 0 then nmb := null; end if;
      if nmb is not null
       then
        update shopping_basket
         set
          qty = nmb
        where
         poid = c2rec.poid and
         shopping_id = sb1(j);
        -- If booking, update to reflect change
        update booked_programs
         set
          num_of_visitors = nmb
        where
         booking_id in (select booking_id from booking where purchase_order_id = c2rec.poid) and
         program_id = (select phid from shopping_basket where shopping_id = sb1(j) );

        fname.purchase_audit_trail( surl, c2rec.poid, 'QTY', 'U', 'C', nmb, c2rec, voidrec);
     end if;
     -- Recalculate total?
    end if;
   end loop;
 end if;

 commit;

 manpay( surl, vpoid, 'Details Modified' );

exception when others then
  glbx.error_details( 'LAB', 'ACCEPT_MANPAY', errmsg=>sqlerrm);
end accept_manpay;

procedure manrun_workflow(surl varchar2, shpid in integer, stsid in integer default null, aord in integer default null, msg in varchar2 default null )
as

 cursor c2( stsid integer ) is select * from workflow_activity_defn where workflow_activity_id = stsid;
 cursor c3 is select * from workflow_activity_defn order by upper(name);
 cursor c4( stsid integer ) is select * from workflow_activity where workflow_activity_id = stsid order by activity_order;
 cursor c1s( shopid integer ) is select * from shopping_basket where shopping_id = shopid;
 cursor c2s( vpoid integer ) is select * from purchase_order where poid = vpoid;

 c1rec		manufacturer%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c2srec		c2s%ROWTYPE;
 c1srec		shopping_basket%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 new_status_id			integer;
 new_status_workflow		integer;
 new_workflow_activity_id 	integer;
 override_activity_order	integer;
 halt_workflow			boolean;
 stop_workflow			boolean;

begin
 if stsid is not null and aord is not null
  then
   open c1s(shpid);
   fetch c1s into c1srec;
   close c1s;
   open c2s(c1srec.poid);
   fetch c2s into c2srec;
   close c2s;
   stop_workflow := FALSE;
   new_status_id := NULL;
   new_status_workflow := NULL;
   perform_workflow_activity(surl, c1srec.poid, shpid, stsid, aord, c2srec.pid, c1rec.manufacturer_id, override_activity_order, stop_workflow, halt_workflow, new_status_id, new_status_workflow, new_workflow_activity_id );
   htp.bold( 'Workflow Step Run' );
   return;
 end if;

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.MANRUN_WORKFLOW', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, 'Workflow Control Centre for Shopping ID' || ' : ' || shpid, glbx.backimg(surl,owner_id,pfx.text_back,null),'L27',stype=>greatest(stype-3,1),sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,small_link=>TRUE,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 htp.nl;
 htp.formopen( 'lab.manrun_workflow' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'SHPID', shpid );
 if stsid is null
  then
  htp.bold( 'Choose Workflow Activity' || ' : ' );
  htp.nl;
   htp.formselectopen( 'STSID' );
   for c3rec in c3 loop
    htp.formselectoption( c3rec.name, 'SELECTED', cattributes=>'VALUE="' || c3rec.workflow_activity_id || '"' );
   end loop;
   htp.formselectclose;
   htp.nl;
   htp.formsubmit( null, 'Choose Workflow Activity' );
   htp.formclose;
   htp.htmlclose;
   return;
 end if;

 htp.formhidden( 'STSID', stsid );
 open c2(stsid);
 fetch c2 into c2rec;
 close c2;
 htp.bold( 'Workflow Activity' || ' : ' || c2rec.name );
 htp.nl;

 htp.bold( 'Individual Activity' );
 htp.formselectopen( 'AORD' );
 for c4rec in c4(stsid) loop
  htp.formselectoption( c4rec.activity_type || '-' || c4rec.extra_value_1, 'SELECTED', cattributes=>'VALUE="' || c4rec.activity_order || '"' );
 end loop;
 htp.formselectclose;
 htp.formsubmit( null, 'Run Workflow Activity' );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
  glbx.error_details( 'LAB', 'MANRUN_WORKFLOW', errmsg=>sqlerrm);
end manrun_workflow;

function process_barcode( bf in varchar2, val in varchar2 )
 return varchar2
as
 vl	varchar2(4000);
begin
 execute immediate 'begin :vl := ' || bf || '(''' || val || '''); end;'
  using in out vl;
 return( vl );
exception
 when others then return( 'PB:' || sqlerrm );
end process_barcode;

function parse_barcode( cd in varchar2, bf in varchar2 )
 return glbx.myarray
as
 delim		GLBX.MYARRAY;
begin
 if cd is null then return( delim ); end if;
 glbx.comma_delimited(bfr=>cd, comma_delim=>delim, delimchar=>BARCODE_DELIMITER);
 if delim.count = 0 then return( delim ); end if;
 for j in delim.first..delim.last loop
  if substr(delim(j),1,1) in (chr(10),chr(13))
   then
    delim(j) := substr(delim(j),2);
  end if;
 end loop;
 if bf is null then return( delim ); end if;
 for j in delim.first..delim.last loop
  delim(j) := process_barcode( bf, delim(j) );
 end loop;
 return( delim );
exception
 when others then return( delim );
end parse_barcode;

procedure barcode( surl in varchar2, p1 in glbx.myarray, p2 in varchar2, msg in varchar2 default null )
as

 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.BARCODE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, 'Bar Code Item Checker',glbx.backimg(surl,owner_id,pfx.text_back,null),'B09',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;
 htp.formopen( 'lab.accept_barcode' );
  htp.formhidden( 'SURL', surl );
  for j in p1.first..p1.last loop
   htp.formhidden( 'P1', p1(j) );
  end loop;
 htp.formhidden( 'P2', p2 );
 htp.formtextarea( 'P3', 12, 60 );
 htp.nl;
 htp.nl;
 htp.formsubmit( 'ACTION', 'Fast Track' );
 htp.formsubmit( 'ACTION', 'Review' );
 htp.formclose;
 htp.nl;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'BARCODE',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end barcode;

procedure accept_barcode( surl in varchar2, p1 in glbx.myarray, p2 in varchar2, p3 in varchar2, action in varchar2 default 'Edit' )
as

 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 retres		glbx.myarray;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.ACCEPT_BARCODE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 retres := parse_barcode( trim(p3), c1rec.barcode_function );

 barcode_validate(surl, p1, p2, retres, c1rec, owner_id, stype, action=>action );

exception when others then
 glbx.error_details( 'LAB', 'ACCEPT_BARCODE',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end accept_barcode;

procedure accept_barcode_arr( surl in varchar2, p1 in glbx.myarray, p2 in varchar2, retres in glbx.myarray, action in varchar2 default 'Edit' )
as

 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'LAB.ACCEPT_BARCODE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := get_lab_id( surl, owner_id );

 barcode_validate(surl, p1, p2, retres, c1rec, owner_id, stype, action=>action );

exception when others then
 glbx.error_details( 'LAB', 'ACCEPT_BARCODE',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end accept_barcode_arr;

procedure formatrow( c2rec in shopping_basket%ROWTYPE, msg in varchar2 )
as

 cursor c3( mfid integer) is select name from manufacturer where manufacturer_id = mfid;
 cursor c4( stw integer) is select workflow_name from workflow_set where status_workflow = stw;
 cursor c5( stsid integer ) is select * from workflow where status_id = stsid;

 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;

begin
  htp.tablerowopen;
   if msg is not null then htp.tabledata( htf.bold( msg ) ); end if;
   htp.tabledata( htf.bold( c2rec.phid ) );
   htp.tabledata( c2rec.shopping_id );
   htp.tabledata( c2rec.poid );
   htp.tabledata( c2rec.qty || ' x ' || to_char(c2rec.photo_cost, LNG.MONEY_FORMAT) || '-' || c2rec.photo_size );
   htp.tabledata( c2rec.name );
    if c2rec.status_mfctr is not null
     then
      open c3( c2rec.status_mfctr );
      fetch c3 into c3rec;
      close c3;
      htp.tabledata( c3rec.name );
    end if;
   htp.p( '<TD>' );
    if c2rec.status_id is not null
     then
      open c5( c2rec.status_id );
      fetch c5 into c5rec;
      close c5;
      if c5rec.status_id is null or c5rec.question is null
       then
        htp.p( 'Status:' || c2rec.status_id );
       else
        htp.p( 'Status:' || c5rec.question );
      end if;
      htp.nl;
    end if;
    htp.p( 'Priority:' || c2rec.status_priority );
    htp.nl;
    if c2rec.status_mfctr is not null
     then
      open c4( c2rec.status_workflow );
      fetch c4 into c4rec;
      close c4;
      htp.p( 'Workflow:' || c4rec.workflow_name );
      htp.nl;
    end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
end formatrow;

function getshoplist( mfctrid in integer, bitems in glbx.myarray, umo_array in glbx.myarray, originating in varchar2, action in varchar2 )
 return barcode_arr
as

 cursor c2( v_umo integer ) is
  select sb.shopping_id, sb.status_workflow, sb.status_mfctr, po.status, po.paid_method, po.date_created, sb.ppi, sb.poid, po.sendto_firstname, po.sendto_lastname
  from shopping_basket sb, purchase_order po
  where sb.phid = v_umo and
        po.poid = sb.poid
 union all
  select sb.shopping_id, sb.status_workflow, sb.status_mfctr, po.status, po.paid_method, po.date_created, sb.ppi, sb.poid, po.sendto_firstname, po.sendto_lastname
  from shopping_basket_thread sb, purchase_order po
  where sb.phid = v_umo and
        po.poid = sb.poid;

 cursor c3( mfctrid integer, v_umo integer ) is
  select shopping_id
  from shopping_basket
  where status_mfctr = mfctrid
 union all
  select shopping_id
  from shopping_basket_thread
  where status_mfctr = mfctrid;

 c3rec		c3%ROWTYPE;
 x		integer;
 fnd		boolean;
 fnd2		boolean;
 shoplist	barcode_arr;
 ctr		integer;

begin
 if action = 'Fast Track'
  then
    for j in umo_array.first..umo_array.last loop
      begin x := umo_array(j); exception when others then x := null; end;
      open c3( mfctrid, x );
      fetch c3 into c3rec;
      if c3%FOUND
       then
        ctr := shoplist.count + 1;
        shoplist(ctr).shopping_id := c3rec.shopping_id;
        shoplist(ctr).result := 'F';
      end if;
      close c3;
    end loop;
   return( shoplist );
 end if;

 for j in umo_array.first..umo_array.last loop
   begin x := umo_array(j); exception when others then x := null; end;
   if x is null
    then
     null;
   else
     fnd := false;
     for c2rec in c2( x ) loop

      if originating = 'ALL'
       then
        fnd := TRUE;
        ctr := shoplist.count + 1;
        shoplist(ctr).shopping_id := c2rec.shopping_id;
        shoplist(ctr).umo_id := x;
        shoplist(ctr).poid := c2rec.poid;
        shoplist(ctr).manufacturer_id := c2rec.status_mfctr;
        shoplist(ctr).status_workflow := c2rec.status_workflow;
        shoplist(ctr).date_created := c2rec.date_created;
        shoplist(ctr).ppi := c2rec.ppi;
        shoplist(ctr).paid_method := c2rec.paid_method;
        shoplist(ctr).status := c2rec.status;
        shoplist(ctr).sendto_firstname := c2rec.sendto_firstname;
        shoplist(ctr).sendto_lastname := c2rec.sendto_lastname;
        shoplist(ctr).result := 'F';
       else
        fnd2 := FALSE;
        fnd := TRUE;
        for k in bitems.first..bitems.last loop
         if c2rec.shopping_id = bitems(j)
          then
           exit;
         end if;
        end loop;
        if fnd2
         then
          ctr := shoplist.count + 1;
          shoplist(ctr).umo_id := x;
          shoplist(ctr).poid := c2rec.poid;
          shoplist(ctr).manufacturer_id := c2rec.status_mfctr;
          shoplist(ctr).status_workflow := c2rec.status_workflow;
          shoplist(ctr).date_created := c2rec.date_created;
          shoplist(ctr).ppi := c2rec.ppi;
          shoplist(ctr).paid_method := c2rec.paid_method;
          shoplist(ctr).status := c2rec.status;
          shoplist(ctr).sendto_firstname := c2rec.sendto_firstname;
          shoplist(ctr).sendto_lastname := c2rec.sendto_lastname;
          shoplist(ctr).result := 'F';
          if c2rec.status_mfctr is null then shoplist(ctr).result := 'B'; end if;
         else
          ctr := shoplist.count + 1;
          shoplist(ctr).umo_id := x;
          shoplist(ctr).poid := c2rec.poid;
          shoplist(ctr).manufacturer_id := c2rec.status_mfctr;
          shoplist(ctr).status_workflow := c2rec.status_workflow;
          shoplist(ctr).date_created := c2rec.date_created;
          shoplist(ctr).ppi := c2rec.ppi;
          shoplist(ctr).paid_method := c2rec.paid_method;
          shoplist(ctr).status := c2rec.status;
          shoplist(ctr).sendto_firstname := c2rec.sendto_firstname;
          shoplist(ctr).sendto_lastname := c2rec.sendto_lastname;
          shoplist(ctr).result := 'N';
          if c2rec.status_mfctr is null then shoplist(ctr).result := 'C'; end if;
        end if;
      end if;
     end loop;
     if not fnd
      then
        ctr := shoplist.count + 1;
        shoplist(ctr).umo_id := x;
        shoplist(ctr).result := 'X';
     end if;
   end if;
 end loop;
 return( shoplist );
end getshoplist;

function getnme( id in integer, typ in varchar2 )
 return varchar2
as
 cursor c1(id integer) is select name from manufacturer where manufacturer_id = id;
 cursor c2(id integer) is select name from phg_price_book where spb = (select spb from phg_price_item where ppi = id);
 cursor c3(id integer) is select workflow_name from workflow_set where status_workflow = id;
 retval	varchar2(1000);
begin
 if typ = 'M'
  then
   open c1(id);
   fetch c1 into retval;
   close c1;
   return( retval );
 end if;
 if typ = 'P'
  then
   open c2(id);
   fetch c2 into retval;
   close c2;
   return( retval );
 end if;
 if typ = 'W'
  then
   open c3(id);
   fetch c3 into retval;
   close c3;
   return( retval );
 end if;
 return( null );
end getnme;

procedure barcode_validate(surl in varchar2, wrkflow_codes in glbx.myarray, originating in varchar2, umo_array in glbx.myarray, c1rec in manufacturer%ROWTYPE, owner_id in integer, stype in integer, action in varchar2 )
as

 -- Need to review this query.
 cursor c2( v_umo integer ) is
  select phid,shopping_id,poid,qty,photo_size,photo_cost,status_id,status_priority,status_workflow,status_mfctr,name from shopping_basket where shopping_id in (select max(shopping_id) from shopping_basket where phid = v_umo)
 union all
  select phid,shopping_id,poid,qty,photo_size,photo_cost,status_id,status_priority,status_workflow,status_mfctr,name from shopping_basket_thread where shopping_id in (select max(shopping_id) from shopping_basket_thread where phid = v_umo);

 cursor c3(mfid integer, sts integer, ws integer) is
  select shopping_id
  from shopping_basket
  where nvl(priority_of_item,0) = nvl(sts,0) and status_mfctr = mfid and status_workflow=ws
  union
  select shopping_id
  from shopping_basket_thread
  where nvl(priority_of_item,0) = nvl(sts,0) and status_mfctr = mfid and status_workflow=ws;

 cursor c4(vpoid integer, mfid integer) is
  select distinct shopping_id
  from
  (
  select sb.status_priority, p.date_purchased,shopping_id,sb.poid,sb.status_workflow,status_at_step,priority_of_item, photo_size, name, qty, estimated_due_date, lpad(' ',1000,' ') value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number
  from shopping_basket sb, purchase_order p, workflow_set ws
  where status_mfctr = mfid and
        sb.status_workflow = ws.status_workflow and
        sb.status in ('10','20','30') and
        p.poid = sb.poid and
        p.poid = vpoid
 union all
  select sb.status_priority,p.date_purchased,thread_id shopping_id,sb.poid,sb.status_workflow,status_at_step,priority_of_item, photo_size, name, qty, estimated_due_date, lpad(' ',1000,' ') value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number
  from shopping_basket_thread sb, purchase_order p, workflow_set ws
  where status_mfctr = mfid and
        sb.status_workflow = ws.status_workflow and
        sb.status in ('10','20','30') and
        p.poid = sb.poid and
        p.poid = vpoid
  );

 cursor c7(vpoid integer) is
  select poid, estimated_due_date, date_purchased, sendto_name, status, count(*) cnt, sum(nvl(qty,1)) sm
  from
  (
  select p.status, sb.status_priority, p.date_purchased,shopping_id,sb.poid,sb.status_workflow,status_at_step,priority_of_item, photo_size, name, qty, estimated_due_date, lpad(' ',1000,' ') value, workflow_name, manufctr_code, xref_mfctr_code, product_class, invoice_number, sendto_name
  from shopping_basket sb, purchase_order p, workflow_set ws
  where sb.status_workflow = ws.status_workflow and
        p.poid = sb.poid and
        p.poid = vpoid
  )
  group by poid, estimated_due_date, date_purchased, sendto_name, status;

 cursor c8 is select distinct umo_id from advanced_query_temp_result_a where umo_id is not null;
 cursor c9a is select distinct sort_value from advanced_query_temp_result_a;
 cursor c9b(srt varchar2) is select distinct umo_id from advanced_query_temp_result_a where sort_value = srt;
 cursor c10(srt varchar2) is select count('x') cnt, sum(nvl(qty,0)) sm from advanced_query_temp_result_a aa, shopping_basket sb where sort_value = srt and sb.poid = aa.umo_id;

 crec		shopping_basket%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c10rec		c10%ROWTYPE;
 pfx		THEME%ROWTYPE;
 x		integer;
 fnd		boolean;
 fnd2		boolean;
 ctr		integer;
 ctr2		integer;
 tmp		varchar2(100);
 prfx		varchar2(32767);
 bitems		glbx.myarray;
 shoplist	barcode_arr;

begin

 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, 'Validate Barcode Results',glbx.backimg(surl,owner_id,pfx.text_back,null),'B09',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;

 if umo_array.count = 0
  then
   htp.bold( 'No Barcode Values Found' );
   htp.htmlclose;
   return;
 end if;

 if action = 'Fast Track'
  then
   shoplist := getshoplist( owner_id, bitems, umo_array, originating, action );
   if shoplist.count = 0
    then
     htp.bold( 'No Shopping Values Found' );
     htp.htmlclose;
     return;
   end if;
   for j in shoplist.first..shoplist.last loop
    insert into advanced_query_temp_result_a(umo_id) values (shoplist(j).shopping_id);
   end loop;
   for c8rec in c8 loop
    bitems(c8%ROWCOUNT) := c8rec.umo_id;
   end loop;
   attention_accept( surl, p1=>bitems );
   return;
 end if;

 -- Barcode Support I,P,Z,S
 if originating = 'ALL'
  then
   bitems(1) := null;

 elsif originating in ('I','Z')
  then
   bitems(1) := null;
   for j in wrkflow_codes.first..wrkflow_codes.last loop
    bitems(j) := wrkflow_codes(j);
   end loop;

 elsif originating = 'P'
  then
   ctr := 0;
   bitems(1) := null;
   for j in wrkflow_codes.first..wrkflow_codes.last loop
    if wrkflow_codes(j) is not null
     then
     for c4rec in c4(wrkflow_codes(j),owner_id) loop
      ctr := ctr +1;
      bitems(ctr) := c4rec.shopping_id;
     end loop;
    end if;
   end loop;

 elsif originating = 'S'
  then
   ctr := 0;
   bitems(1) := null;
   for j in wrkflow_codes.first..wrkflow_codes.last loop
    if wrkflow_codes(j) is not null
     then
     for c3rec in c3(owner_id,substr(wrkflow_codes(j),2,instr(wrkflow_codes(j),']')-2),substr(wrkflow_codes(j),instr(wrkflow_codes(j),']')+1) ) loop
      ctr := ctr +1;
      bitems(ctr) := c3rec.shopping_id;
     end loop;
    end if;
   end loop;
 end if;

 shoplist := getshoplist( owner_id, bitems, umo_array, originating, action );
 -- Based on Action modify array
 if shoplist.count > 0
  then
   ctr2 := 0;
   for j in shoplist.first..shoplist.last loop
    if shoplist(j).manufacturer_id = owner_id and
       shoplist(j).result = 'F'
     then
      ctr2 := ctr2 + 1;
      bitems(ctr2) := shoplist(j).shopping_id;
    end if;
   end loop;
 end if;
 attention_tasks( surl, byp=>'L', shoplist=>bitems);

 prfx := 'lab.accept_barcode_arr?surl=' || surl || '&p2=' || originating;
 if wrkflow_codes.count = 0
  then
   prfx := prfx || '&p1=';
  else
   for j in wrkflow_codes.first..wrkflow_codes.last loop
    prfx := prfx || '&p1=' || wrkflow_codes(j);
   end loop;
 end if;
 for j in umo_array.first..umo_array.last loop
    prfx := prfx || '&retres=' || umo_array(j);
 end loop;

 htp.anchor( prfx || '&action=Review','[By Image Id]' );
 htp.anchor( prfx || '&action=BYPOID','[By Purchase Order]' );
 htp.anchor( prfx || '&action=MFCTR','[By Manufacturer]' );
 htp.anchor( prfx || '&action=WRK','[By Workflow]' );
 htp.anchor( prfx || '&action=DATE','[By Date Created]' );
 htp.anchor( prfx || '&action=PPI','[By Price Book]' );
 htp.anchor( prfx || '&action=PAID','[By Paid Method]' );
 htp.anchor( prfx || '&action=STATUS','[By Status]' );
 htp.nl;
 htp.nl;

 if action = 'Review'
  then
 -- Based on option look at other options
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Result' ) );
     htp.tabledata( htf.bold( 'UMO Id' ) );
     htp.tabledata( htf.bold( 'Shopping Id' ) );
     htp.tabledata( htf.bold( 'Purchase Order' ) );
     htp.tabledata( htf.bold( 'Details' ) );
     htp.tabledata( htf.bold( 'Price Book' ) );
     htp.tabledata( htf.bold( 'Manufacturer' ) );
     htp.tabledata( htf.bold( 'Workflow Step Details' ) );
    htp.tablerowclose;
   for j in shoplist.first..shoplist.last loop
    htp.tablerowopen;
     if shoplist(j).result = 'F'
      then
       htp.tabledata( 'Valid' );
     elsif shoplist(j).result = 'N'
      then
       htp.tabledata( 'Wrong Mfctr' );
     elsif shoplist(j).result = 'B'
      then
       htp.tabledata( 'No Mfctr' );
     elsif shoplist(j).result = 'C'
      then
       htp.tabledata( 'No Mfctr' );
     elsif shoplist(j).result = 'N'
      then
       htp.tabledata( 'Not Found' );
     else
       htp.tabledata( 'Not Found' );
     end if;
     htp.tabledata( shoplist(j).umo_id );
     htp.tabledata( shoplist(j).shopping_id );
     htp.tabledata( htf.anchor2( 'lab.show_poid?surl=' || surl || '&vpoid=' || shoplist(j).poid || '&shp=', shoplist(j).poid, ctarget=>'PURCHASE_ORDER' ) );
     htp.tabledata( shoplist(j).status );
     htp.tabledata( getnme(shoplist(j).ppi,'P') );
     htp.tabledata( getnme(shoplist(j).manufacturer_id,'M') );
     htp.tabledata( getnme(shoplist(j).status_workflow,'W') );
    htp.tablerowclose;

   end loop;
  htp.tableclose;

 elsif action = 'BYPOID'
  then
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Purchase Order' ) );
     htp.tabledata( htf.bold( 'Name' ) );
     htp.tabledata( htf.bold( 'Status' ) );
     htp.tabledata( htf.bold( '# Items / Quantity' ) );
     htp.tabledata( htf.bold( 'Date Purchased' ) );
     htp.tabledata( htf.bold( 'Due Date' ) );
    htp.tablerowclose;
    delete from advanced_query_temp_result_a;
    for j in shoplist.first..shoplist.last loop
     if shoplist(j).poid is not null
      then
       insert into advanced_query_temp_result_a(umo_id) values (shoplist(j).poid);
     end if;
    end loop;
    for c8rec in c8 loop
     open c7(c8rec.umo_id);
     fetch c7 into c7rec;
     if c7%FOUND
      then
       htp.tablerowopen;
        htp.tabledata( htf.anchor2( 'lab.show_poid?surl=' || surl || '&vpoid=' || c7rec.poid || '&shp=', c7rec.poid, ctarget=>'PURCHASE_ORDER' ) );
        htp.tabledata( c7rec.sendto_name );
        htp.tabledata( c7rec.status );
        htp.tabledata( c7rec.cnt || '/' || c7rec.sm );
        htp.tabledata( to_char(c7rec.date_purchased,LNG.TSMASK) );
        htp.tabledata( to_char(c7rec.estimated_due_date,LNG.TSMASK) );
       htp.tablerowclose;
      else
       htp.tablerowopen;
        htp.tabledata( c8rec.umo_id );
        htp.tabledata( 'Does not belong to a Workflow', cattributes=>'colspan=5' );
       htp.tablerowclose;
     end if;
     close c7;
    end loop;
  htp.tableclose;

 elsif action = 'MFCTR'
  then
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Manufacturer' ) );
     htp.tabledata( htf.bold( 'Orders' ) );
     htp.tabledata( htf.bold( '# Items / Quantity' ) );
    htp.tablerowclose;
    delete from advanced_query_temp_result_a;
    for j in shoplist.first..shoplist.last loop
     if shoplist(j).manufacturer_id is not null
      then
       tmp := getnme(shoplist(j).manufacturer_id,'M');
       insert into advanced_query_temp_result_a(umo_id,sort_value) values (shoplist(j).poid,tmp);
     end if;
    end loop;
    for c9arec in c9a loop
    htp.tablerowopen;
     htp.tabledata( c9arec.sort_value );
     htp.p( '<TD>' );
     for c9brec in c9b(c9arec.sort_value) loop
      htp.anchor2( 'lab.show_poid?surl=' || surl || '&vpoid=' || c9brec.umo_id || '&shp=', c9brec.umo_id, ctarget=>'PURCHASE_ORDER' ); htp.nl;
     end loop;
     htp.p( '</TD>' );
     c10rec := null;
     open c10(c9arec.sort_value );
     fetch c10 into c10rec;
     close c10;
     htp.tabledata( c10rec.cnt || '/' || c10rec.sm );
    htp.tablerowclose;
    end loop;
  htp.tableclose;

 elsif action = 'WRK'
  then
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Workflow' ) );
     htp.tabledata( htf.bold( 'Orders' ) );
     htp.tabledata( htf.bold( '# Items / Quantity' ) );
    htp.tablerowclose;
    delete from advanced_query_temp_result_a;
    for j in shoplist.first..shoplist.last loop
     if shoplist(j).status_workflow is not null
      then
       tmp := getnme(shoplist(j).status_workflow,'W');
       insert into advanced_query_temp_result_a(umo_id,sort_value) values (shoplist(j).poid,tmp);
     end if;
    end loop;
    for c9arec in c9a loop
    htp.tablerowopen;
     htp.tabledata( c9arec.sort_value );
     htp.p( '<TD>' );
     for c9brec in c9b(c9arec.sort_value) loop
      htp.anchor2( 'lab.show_poid?surl=' || surl || '&vpoid=' || c9brec.umo_id || '&shp=', c9brec.umo_id, ctarget=>'PURCHASE_ORDER' ); htp.nl;
     end loop;
     htp.p( '</TD>' );
     c10rec := null;
     open c10(c9arec.sort_value );
     fetch c10 into c10rec;
     close c10;
     htp.tabledata( c10rec.cnt || '/' || c10rec.sm );
    htp.tablerowclose;
    end loop;
  htp.tableclose;

 elsif action = 'DATE'
  then
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Date Created' ) );
     htp.tabledata( htf.bold( 'Orders' ) );
     htp.tabledata( htf.bold( '# Items / Quantity' ) );
    htp.tablerowclose;
    delete from advanced_query_temp_result_a;
    for j in shoplist.first..shoplist.last loop
     if shoplist(j). date_created is not null
      then
       tmp := to_char(shoplist(j). date_created,LNG.TSMASK);
       insert into advanced_query_temp_result_a(umo_id,sort_value) values (shoplist(j).poid,tmp);
     end if;
    end loop;
    for c9arec in c9a loop
    htp.tablerowopen;
     htp.tabledata( c9arec.sort_value );
     htp.p( '<TD>' );
     for c9brec in c9b(c9arec.sort_value) loop
      htp.anchor2( 'lab.show_poid?surl=' || surl || '&vpoid=' || c9brec.umo_id || '&shp=', c9brec.umo_id, ctarget=>'PURCHASE_ORDER' ); htp.nl;
     end loop;
     htp.p( '</TD>' );
     c10rec := null;
     open c10(c9arec.sort_value );
     fetch c10 into c10rec;
     close c10;
     htp.tabledata( c10rec.cnt || '/' || c10rec.sm );
    htp.tablerowclose;
    end loop;
  htp.tableclose;

 elsif action = 'PPI'
  then
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Price Book' ) );
     htp.tabledata( htf.bold( 'Orders' ) );
     htp.tabledata( htf.bold( '# Items / Quantity' ) );
    htp.tablerowclose;
    delete from advanced_query_temp_result_a;
    for j in shoplist.first..shoplist.last loop
     if shoplist(j).ppi is not null
      then
       tmp := getnme(shoplist(j).ppi,'P');
       insert into advanced_query_temp_result_a(umo_id,sort_value) values (shoplist(j).poid,tmp);
     end if;
    end loop;
    for c9arec in c9a loop
    htp.tablerowopen;
     htp.tabledata( c9arec.sort_value );
     htp.p( '<TD>' );
     for c9brec in c9b(c9arec.sort_value) loop
      htp.anchor2( 'lab.show_poid?surl=' || surl || '&vpoid=' || c9brec.umo_id || '&shp=', c9brec.umo_id, ctarget=>'PURCHASE_ORDER' ); htp.nl;
     end loop;
     htp.p( '</TD>' );
     c10rec := null;
     open c10(c9arec.sort_value );
     fetch c10 into c10rec;
     close c10;
     htp.tabledata( c10rec.cnt || '/' || c10rec.sm );
    htp.tablerowclose;
    end loop;
  htp.tableclose;

 elsif action = 'PAID'
  then
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Payment Method' ) );
     htp.tabledata( htf.bold( 'Orders' ) );
     htp.tabledata( htf.bold( '# Items / Quantity' ) );
    htp.tablerowclose;
    delete from advanced_query_temp_result_a;
    for j in shoplist.first..shoplist.last loop
     if shoplist(j).paid_method is not null
      then
       insert into advanced_query_temp_result_a(umo_id,sort_value) values (shoplist(j).poid,shoplist(j).paid_method);
     end if;
    end loop;
    for c9arec in c9a loop
    htp.tablerowopen;
     htp.tabledata( c9arec.sort_value );
     htp.p( '<TD>' );
     for c9brec in c9b(c9arec.sort_value) loop
      htp.anchor2( 'lab.show_poid?surl=' || surl || '&vpoid=' || c9brec.umo_id || '&shp=', c9brec.umo_id, ctarget=>'PURCHASE_ORDER' ); htp.nl;
     end loop;
     htp.p( '</TD>' );
     c10rec := null;
     open c10(c9arec.sort_value );
     fetch c10 into c10rec;
     close c10;
     htp.tabledata( c10rec.cnt || '/' || c10rec.sm );
    htp.tablerowclose;
    end loop;
  htp.tableclose;

 elsif action = 'STATUS'
  then
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Purchase Order Status' ) );
     htp.tabledata( htf.bold( 'Orders' ) );
     htp.tabledata( htf.bold( '# Items / Quantity' ) );
    htp.tablerowclose;
    delete from advanced_query_temp_result_a;
    for j in shoplist.first..shoplist.last loop
     if shoplist(j).status is not null
      then
       insert into advanced_query_temp_result_a(umo_id,sort_value) values (shoplist(j).poid,shoplist(j).status);
     end if;
    end loop;
    for c9arec in c9a loop
    htp.tablerowopen;
     htp.tabledata( c9arec.sort_value );
     htp.p( '<TD>' );
     for c9brec in c9b(c9arec.sort_value) loop
      htp.anchor2( 'lab.show_poid?surl=' || surl || '&vpoid=' || c9brec.umo_id || '&shp=', c9brec.umo_id, ctarget=>'PURCHASE_ORDER' ); htp.nl;
     end loop;
     htp.p( '</TD>' );
     c10rec := null;
     open c10(c9arec.sort_value );
     fetch c10 into c10rec;
     close c10;
     htp.tabledata( c10rec.cnt || '/' || c10rec.sm );
    htp.tablerowclose;
    end loop;
  htp.tableclose;
 end if;

 htp.htmlclose;

exception when others then
 glbx.error_details( 'LAB', 'BARCODE_VALIDATE',errmsg=>sqlerrm,extdet=>'Originating:' || originating);
end barcode_validate;

end lab;

/
