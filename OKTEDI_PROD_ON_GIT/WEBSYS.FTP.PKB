CREATE OR REPLACE package body WEBSYS.ftp
as

SKIN_LOC	 	 CONSTANT VARCHAR2(50) := 'skin/spi/';
C_BACKIMG	         CONSTANT VARCHAR2(1000) := '<BODY BACKGROUND="' || DECS.IMAGE_LOCATION || SKIN_LOC || 'spi_bottom.jpg"';
C_ALT	                 CONSTANT VARCHAR2(1000) := '<BODY BACKGROUND="' || DECS.IMAGE_LOCATION || SKIN_LOC || 'spi_gcard.jpg"';
PROGRAM_INITIAL		 CONSTANT VARCHAR2(20)   := 'ftp';
NO_RESULTS		 CONSTANT VARCHAR2(1000) := '<b>The Search Returned No Results</b>';

procedure err_page( surl in varchar2, errm in varchar2 );
procedure open_page( surl in varchar2, acid in integer, stype in integer, pfx in theme%ROWTYPE, bypass in boolean default FALSE, alternative in boolean default FALSE, ttl in varchar2 default null, cusrec in customer_account%ROWTYPE, ltype in varchar2 );
procedure close_page;
procedure pg(stype in integer, tname in varchar2 default 'DEFAULT');

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

procedure open_page( surl in varchar2, acid in integer, stype in integer, pfx in theme%ROWTYPE, bypass in boolean default FALSE, alternative in boolean default FALSE, ttl in varchar2 default null, cusrec in customer_account%ROWTYPE, ltype in varchar2 )
as

 fsize	number;
 sstyle	varchar2(100);
 lnkh	varchar2(40);
 mrg	varchar2(1000);

begin
 fsize := 8 + trunc(stype/1.5) + nvl(pfx.text_font_inc,0);
 htp.init;
 htp.p('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">' );
 htp.htmlopen;
 htp.p( '<HEAD>' );

 sstyle := pfx.text_font;
 if pfx.underline_active = 'ACTIVE'
  then
   lnkh := NULL;
  else
   lnkh := '; Text-Decoration : None';
 end if;

 htp.p(' <style TYPE="text/css"><!-- ' ||
 ' A:link { font-family:  ' || sstyle || ' ; color :  ' || '#' || nvl(pfx.uline,pfx.text_colour) || '  ' || lnkh || ';}' ||
 ' A:active { font-family:  ' || sstyle || ' ; color :  ' || '#' || nvl(pfx.uline_active,nvl(pfx.uline,pfx.text_colour)) || '  ' || lnkh || ';}' ||
 ' A:visited { font-family:  ' || sstyle || ' ; color :  ' || '#' || nvl(pfx.uline_visited,nvl(pfx.uline,pfx.text_colour)) || '  ' || lnkh || ';}' ||
 ' A:hover { font-family:  ' || sstyle || ' ; color :  ' || '#' || pfx.hover_colour || ' ;}' ||
 ' BODY{font-size: ' || fsize || 'pt; font-family:  ' || sstyle || ' ; color:  #' || pfx.text_colour || ' ;}' ||
 ' H2  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(fsize + 6) || 'pt; color:  #' || pfx.text_colour || ' ;}' ||
 ' H2.ERROR {font-family:  ' || nvl(pfx.error_text_font,sstyle) || ' ; font-size: ' || to_char(fsize + 6) || 'pt; color:  ' || pfx.error_text_colour || ' ;}' ||
 ' H3  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(fsize + 4) || 'pt; color:  #' || pfx.text_colour || ' ;}' ||
 ' H4  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(fsize + 2) || 'pt; color:  #' || pfx.text_colour || ' ;}' ||
 ' H5  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(fsize + 1) || 'pt; color:  #' || pfx.text_colour || ' ;}' ||
 ' H6  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(fsize - 2) || 'pt; font-style: italic; color:  #' || pfx.text_colour || ' ;}' ||
 ' H6.INSTRUCTION  {font-family:  ' || pfx.instruct_text_font || ' ; font-size: ' || to_char(fsize + nvl(pfx.instruct_font_inc,0)) || 'pt; color:  #' || pfx.instruct_text_colour || ' ;}' ||
 ' TD  {font-family:  ' || sstyle || ' ; font-size: ' || fsize || 'pt; color:  #' || pfx.text_colour || ' ; text-align: left;}' ||
 ' SUP {font-family:  ' || sstyle || ' ; font-size: ' || fsize || 'pt; color:  #' || pfx.text_colour || ' ;}' ||
 ' DIV {font-family:  ' || sstyle || ' ; font-size: ' || fsize || 'pt; color:  #' || pfx.text_colour || ' ;}' ||
 '--> </style>' );

 if pfx.icra_label is not null or pfx.javascript = 'DISABLE'
  then
   if pfx.icra_label is not null then htp.p(pfx.icra_label); end if;
   if pfx.javascript = 'DISABLE'then htp.p( '<meta http-equiv="imagetoolbar" content="no">' ); end if;
 end if;

 if pfx.javascript = 'DISABLE'
  then
   htp.p('<SCRIPT LANGUAGE="JavaScript">
              function click(e) {
              var message="' || LNG.GLB_TXT_104 || '";
              if ( navigator.appName.substring ( 0, 9 ) == "Microsoft") {
              if (event.button == 2) {
              alert(message);
              return false;
              }
              }
              if (document.layers || navigator.appName.substring ( 0, 9 ) == "Netscape") {
              if (e.which==3) {
              alert(message);
              return false;
              }
              }
              }

 function trap()
   {
   if(document.images)
     {
     for(i=0;i<document.images.length;i++)
       {
       document.images[i].onmousedown = click;
       document.images[i].onmouseup = click;
       }
     }
   }
 // End -->
 </SCRIPT>');

 end if;
 if ttl is not null then htp.p( '<TITLE>' || ttl || '</TITLE>' ); end if;

 htp.p( '</HEAD>' );

 mrg := ' TOPMARGIN="' || pfx.top_padding || '" LEFTMARGIN="' || pfx.left_padding || '"' || ' MARGINHEIGHT="' || pfx.top_padding || '" MARGINWIDTH="' || pfx.left_padding || '"';

 if pfx.javascript = 'DISABLE'
  then
   if alternative
    then
      htp.p( C_ALT || ' ' ||  'onload="trap()"' || ' ' || mrg || '>' );
    else
     if cusrec.background_img is null
      then
       htp.p( '<BODY BGCOLOR="#' || pfx.text_back || '" ' ||  'onload="trap()"' || ' ' || mrg || '>' );
      else
       htp.p(glbx.backimg(surl,acid,pfx.text_back,cusrec.background_img,ownr=>ltype,extra_js=>'onload="trap()" ' || mrg || ' '));
     end if;
   end if;
  else
   if alternative
    then
      htp.p( C_ALT || ' ' || mrg || '>' );
    else
     if cusrec.background_img is null
      then
       htp.p( '<BODY BGCOLOR="#' || pfx.text_back || '" ' || mrg || '>' );
      else
       htp.p(glbx.backimg(surl,acid,pfx.text_back,cusrec.background_img,ownr=>ltype,extra_js=>' ' || mrg || ' '));
     end if;
   end if;
 end if;

 htp.p( '<CENTER>' );
 if stype in (1)
  then
   htp.tableopen( cattributes=>'width="95%" cellpadding=0 cellspacing=0 border=0' );
 elsif stype in (2)
  then
   htp.tableopen( cattributes=>'width="95%" cellpadding=0 cellspacing=0 border=0' ); -- was 80
 elsif stype in (3,4)
  then
   htp.tableopen( cattributes=>'width="95%" cellpadding=0 cellspacing=0 border=0' ); -- was 75
 else
   htp.tableopen( cattributes=>'width="95%" cellpadding=0 cellspacing=0 border=0' ); -- was 66
 end if;
 htp.tablerowopen;
 if bypass
  then
   htp.p( '<TD VALIGN="TOP" ALIGN="CENTER" style="text-align: center;">' );
  else
   htp.p( '<TD VALIGN="TOP" ALIGN="LEFT" style="text-align: left;">' );
 end if;
 htp.nl;
end open_page;

procedure close_page
as
begin
 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;
 htp.p( '</BODY>' );
 htp.htmlclose;
end close_page;

procedure delimg( surl in varchar2, acid in integer, sess_id in integer )
as

 cursor c1(acid integer, sess_id integer) is
  select umo_id
  from umo um
  where aid = acid and nvl(sessid,0) = sess_id;

 c1rec		c1%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 xltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 ttl		number;
 sts		varchar2(100);
 umrec 		UMP.SEARCH_RESULT_PHG;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, xltype, owner_id, sts, 'S', progcalled=>PROGRAM_INITIAL || '.LISTIMAGE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 cusrec := glbx.get_cusrec( owner_id, xltype, acid, profid );

 open c1(cusrec.aid, nvl(sess_id,0) );
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   htp.bold( 'Session not found' );
   return;
 end if;
 close c1;
 ttl := 0;
 for c1rec in c1(acid, nvl(sess_id,0)) loop
  delete from umo_attribute where umo_id = c1rec.umo_id;
  delete from umo_index where umo_id = c1rec.umo_id and aid = acid;
  delete from umo where umo_id = c1rec.umo_id and aid = acid and nvl(sessid,0) = nvl(sessid,0);
  ttl := ttl + 1;
 end loop;
 commit;
 listimage(surl, acid, ttl || ' ' || 'images were deleted' );
exception when others then
 glbx.error_details( PROGRAM_INITIAL, 'DELIMG',errmsg=>sqlerrm,extdet=>'AID:' || acid);
end delimg;

procedure listimage( surl in varchar2, acid in integer, msg in varchar2 default null )
as

 cursor c1(acid integer) is
  select sessid, count('x') cnt
  from umo um
  where aid = acid
        group by sessid;

 cursor c2(sess_id integer) is select * from purchase_order where sessid = sess_id;

 cursor c3(acid integer, sess_id integer) is select sum(dbms_lob.getlength(um.photo_original.source.localdata)) sm from umo um where nvl(sessid,0) = sess_id and aid = acid;
 cursor c4(acid integer, sess_id integer) is select umo_id, um.extras.film_name fname, um.extras.photo_name pname from umo um where nvl(sessid,0) = sess_id and aid = acid;

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 xltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 ttl		number;
 sts		varchar2(100);
 umrec 		UMP.SEARCH_RESULT_PHG;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, xltype, owner_id, sts, 'S', progcalled=>PROGRAM_INITIAL || '.LISTIMAGE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 cusrec := glbx.get_cusrec( owner_id, xltype, acid, profid );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 pfx := glbx.get_thm( cusrec.theme_name );

 glbx.main_title( surl, 'Loaded Image Listing',glbx.backimg(surl,acid,pfx.text_back,null,xltype),helpid=>'P83',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null then glbx.header_msg(msg); end if;
 htp.p( '<CENTER>' );
 htp.nl;
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1');
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Purchase Order' ) );
   htp.tabledata( htf.bold( 'Date' ) );
   htp.tabledata( htf.bold( 'Status' ) );
   htp.tabledata( htf.bold( 'Total Value' ) );
   htp.tabledata( htf.bold( 'Number of Image(s)' ) );
   htp.tabledata( htf.bold( 'Download Images' ) );
   htp.tabledata( htf.bold( 'Delete Images' ) );
  htp.tablerowclose;
 for c1rec in c1(cusrec.aid) loop
  c2rec := null;
  ttl := null;
  open c2(c1rec.sessid);
  fetch c2 into c2rec;
  close c2;
  ttl := glbx.grand_total_payment( c2rec.poid );
  htp.tablerowopen;
   htp.tabledata(
         htf.anchor('javascript: window.open(''' || 'ord.modify_order?surl=' || surl || '&acid=' || acid || '&purchord=' || c2rec.poid || '&typ=UND' ||
                    ''',''' || replace(LNG5.EXT_TXT_301 || 'XXXA',' ','_') ||
                    ''',''height=800,width=800,scrollbars=yes,resizable=yes'');void('''');',
                    nvl(to_char(c2rec.poid),'Unknown') )
                 );
   htp.tabledata( nvl(to_char(c2rec.date_created,LNG.TSMASK),'&nbsp;'));
   htp.tabledata( nvl(c2rec.status,'Unknown'));
   htp.tabledata( nvl(trim(to_char(ttl,LNG.MONEY_FORMAT)),'&nbsp;'));
   htp.tabledata( c1rec.cnt );
   c3rec.sm := 0;
   open c3(acid,nvl(c1rec.sessid,0));
   fetch c3 into c3rec;
   close c3;
   htp.p( '<TD VALIGN="TOP">' );
   for c4rec in c4(acid, nvl(c1rec.sessid,0)) loop
    htp.anchor( 'fname.download_file?surl=' || surl || '&acid=' || acid || '&purchid=&mthod=WEB' || '&v_umo=' || c4rec.umo_id, nvl(c4rec.fname,c4rec.pname) );
    htp.nl;
   end loop;
   htp.p( '</TD>' );
   htp.tabledata( htf.anchor( PROGRAM_INITIAL || '.delimg?surl=' || surl || '&acid=' || acid || '&sess_id=' || c1rec.sessid, to_char(c3rec.sm) || ' bytes'), cattributes=>'align="RIGHT"' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( PROGRAM_INITIAL, 'LISTIMAGE',errmsg=>sqlerrm,extdet=>'AID:' || acid);
end listimage;

procedure main_display(surl  varchar2, stype integer, ltype varchar2, umrec UMP.SEARCH_RESULT_PHG, cusrec CUSTOMER_ACCOUNT%ROWTYPE, pfx   THEME%ROWTYPE,
		       theme_rec  theme_types%ROWTYPE, footer_api varchar2, current_page_number  integer default 1, search_total    integer default 0,
		       display_detail  char default null, left_api   varchar2, left_api_parm   varchar2, cusloc varchar2, lbox  varchar2, acid  integer default null,
		       sessid integer, msg   varchar2 )
as

 cursor c2(acid integer, vsess integer) is select count('x') cnt from umo where aid = acid and sessid = vsess;

 cursor c3( sess_id integer ) is select count('x') tot from shopping_basket sb, purchase_order po where po.sessid=sess_id and po.poid = sb.poid;

  c3rec			c3%ROWTYPE;
  nmb			integer;
  ctr			integer;
  x			integer;
  tot			integer;
  hor_caption		varchar2(4000);
  vhor_caption		varchar2(4000);
  url			varchar2(4000);
  voidrec 		order_style%ROWTYPE;
  hor_but		varchar2(4000);
  display_original	varchar2(100);
  txtclr		varchar2(20);
  xt			varchar2(100);
  uscid			integer;

begin
  if ltype = 'PHOTOGRAPHER' then listimage(surl, acid ); return; end if;

  htp.init;
   glbx.main_title( surl, null, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>null,
   stype=>greatest(stype-nvl(pfx.tnumb_adj,0),1),sstyle=>pfx.text_font,lnk=>pfx.tnail_underline_active,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,
   det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript,
   disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour,
   errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font,
   instfntinc=>pfx.instruct_font_inc, excolour=>pfx.caption_text_colour, exfont=>pfx.caption_text_font,ltype=>ltype,
   small_link=>TRUE,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,
   uline=>pfx.uline, uline_active=>pfx.uline_active, uline_visited=>pfx.uline_visited,stylesh=>pfx.stylesheet);

   open c3(sessid);
   fetch c3 into c3rec;
   close c3;
  txtclr := pfx.vert_colour_a;
  display_original := glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL');
  vhor_caption := glbx.userpref( cusrec.pid, cusrec.aid, 'TNAIL_PREF' );

   htp.p( '<CENTER>' );
   open c2(cusrec.aid,sessid);
   fetch c2 into tot;
   close c2;
   if msg is not null
    then
     glbx.header_msg( msg );
   end if;

   if tot = 0
    then
     null;
   elsif tot = 1
    then
     htp.nl;
     htp.anchor( 'fname.acct_orders?surl=' || surl, 'You have ' || tot || ' image in your shopping basket' );
     htp.nl;
     htp.nl;
   else
     htp.nl;
     htp.anchor( 'fname.acct_orders?surl=' || surl, 'You have ' || tot || ' images in your shopping basket' );
     htp.nl;
     htp.nl;
   end if;

 htp.nl;
 htp.p( glbx.userpref(cusrec.pid,cusrec.aid,'HOME_HELP') );
 htp.nl;
 htp.formopen( 'ftp.accept_images', cattributes=>'enctype="multipart/form-data"' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'ACID', acid );
 htp.tableopen( 'cellpadding=3 cellspacing=0 border=1 rules="NONE" frame="HSIDES,VSIDES"' );
  for j in 1..5 loop
   htp.tablerowopen;
    htp.tabledata( GLBX.UPLOAD_NAME, cattributes=>pfx.qcbground );
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION', 'Load Images' );
 htp.formclose;
 htp.p( '</CENTER>' );
 close_page;

exception
 when others then err_page( surl, sqlerrm );
end main_display;

procedure home_page( surl in varchar2, ltype in varchar2 default 'OWNER', acid in integer, msg in varchar2 default null, left_api_parm in varchar2 default null )
as

 cusrec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 xltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 umrec 		UMP.SEARCH_RESULT_PHG;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, xltype, owner_id, sts, 'S', progcalled=>PROGRAM_INITIAL || '.HOME_PAGE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 cusrec := glbx.get_cusrec( owner_id, xltype, acid, profid );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 pfx := glbx.get_thm( cusrec.theme_name );
 main_display(surl=>surl, stype=>stype, ltype=>ltype, umrec=>umrec, cusrec=>cusrec, pfx=>pfx,
              theme_rec=>theme_rec, footer_api=>null, current_page_number=>1, search_total=>0,
	      display_detail=>null, left_api=>null, left_api_parm=>null, cusloc=>null, lbox=>null, acid=>acid, sessid=>owner_id, msg=>null );

exception
 when others then err_page( surl, sqlerrm );
end home_page;

procedure accept_images(surl in varchar2, acid in integer, file in GLBX.MYARRAY, action in varchar2)
as

 cursor c4(snm varchar2) is select umo_scene_id from umo_scene where parent_scene is null and category = snm and owned_by = 'PUBLIC' order by order_by;

 cusrec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 ctr1		integer;
 ctr2		integer;
 scnm		integer;
 sts		varchar2(100);
 umrec 		UMP.SEARCH_RESULT_PHG;
 theme_rec	theme_types%ROWTYPE;
 bad_img	glbx.myarray;
 empty_array	GLBX.MYARRAY;
 dummy_array	GLBX.MYARRAY;
 ret_array	GLBX.MYARRAY;
 retval		varchar2(100);

 procedure new_image(fname in varchar2, scnm in integer)
 as
  parm1		ump.parameters;
  parm2		ump.parameters;
  newid_arr	ump.myarray_int;
 begin
    parm1.delete;
    parm2.delete;
    parm1(1)  := 'AID';
    parm2(1)  := to_char(cusrec.aid);
    parm1(2)  := 'OBJECT_TYPE';
    parm2(2)  := 'AUTO';
    parm1(3)  := 'LOAD_FROM_FILE_OR_UPLOAD';
    parm2(3)  := 'UPLOAD';
    parm1(4)  := 'FILE_NAME';
    parm2(4)  := fname;
    parm1(5)  := 'STORE_ORIGINAL';
    parm2(5)  := 'TRUE';
    parm1(6)  := 'CREATE_THUMBNAIL';
    parm2(6)  := 'TRUE';
    parm1(7) := 'KEEP_STATUS';
    parm2(7) := 'KEEP';
    parm1(8) := 'ORIGINAL_LOCATION';
    parm2(8) := fname;
    parm1(9) := 'PARENT_UMO_ID';
    parm2(9) := NULL;
    parm1(10) := 'SCENE_ID';
    parm2(10) := scnm;
    parm1(11) := 'UMO_OWNER';
    parm2(11) := 'OWNER';
    parm1(12) := 'BYPASS_QUOTA_CHECK';
    parm2(12) := 'FALSE';
    parm1(13) := 'PHGR_ID';
    parm2(13) := to_char(cusrec.pid);
    parm1(14) := 'OWS_NAME';
    parm2(14) := fname;
    parm1(15) := 'THUMBNAIL_WIDTH';
    parm2(15) := nvl(glbx.photo_pref(cusrec.pid,cusrec.aid,'THUMBNAIL_WIDTH'),'100');
    parm1(16) := 'PHOTOGRAPHER';
    parm2(16) := 'TRUE';
    parm1(17) := 'NAME';
    parm2(17) := fname;
    parm1(18) := 'PHOTO ALBUM';
    parm2(18) := 'FALSE';
    parm1(19) := 'BRIDAL';
    parm2(19) := 'TRUE';
    parm1(20) := 'QUALITY';
    parm2(20) := 'STANDARD';
    parm1(21) := 'COMPRESSION';
    parm2(21) := 'S';
    parm1(22) := 'CONVERT_TO';
    parm2(22) := 'JPEG';
    parm1(23) := 'SESSION_ID';
    parm2(23) := owner_id;

    ump.load_uma(surl,parm1,parm2,retval,newid_arr );
    if retval is null
     then
      if newid_arr.count > 0
       then
        for j in newid_arr.first..newid_arr.last loop
          ctr1 := ctr1 + 1;
          ret_array(ctr1) := newid_arr(j);
        end loop;
      end if;
     else
      ctr2 := ctr2 + 1;
      bad_img(ctr2) := retval;
    end if;

  end new_image;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>PROGRAM_INITIAL || '.HOME_PAGE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 pfx := glbx.get_thm( cusrec.theme_name );
 ctr1 := 0;
 ctr2 := 0;
 ret_array(0) := '0';
 dummy_array(1) := '0';
 open c4(cusrec.scene_name);
 fetch c4 into scnm;
 close c4;
 for j in file.first..file.last loop
  if file(j) is not null
   then
   glbx.dbg(file(j));
    new_image(file(j),scnm);
  end if;
 end loop;
 if ret_array.count = 0
  then
   main_display(surl=>surl, stype=>stype, ltype=>ltype, umrec=>umrec, cusrec=>cusrec, pfx=>pfx,
              theme_rec=>theme_rec, footer_api=>null, current_page_number=>1, search_total=>0,
	      display_detail=>null, left_api=>null, left_api_parm=>null, cusloc=>null, lbox=>null, acid=>acid, sessid=>owner_id, msg=>'No Images found to load' );
   return;
 end if;

 cst.accept_display(surl=>surl, p0=>empty_array, p1=>ret_array, pa=>empty_array, pb=>empty_array, pc=>dummy_array, ppn=>empty_array,
                    left_api_parm=>scnm, footer_api=>'QUICKBUY', current_page_number=>'1', display_detail=>NULL,
                    add_to_trolley=>'Order Photos' );

exception
 when others then err_page( surl, sqlerrm );
end accept_images;

procedure err_page( surl in varchar2, errm in varchar2 )
as
begin
 htp.htmlopen;
  htp.p( C_BACKIMG );
   glbx.error_details( 'SPI', 'SKIN',errmsg=>errm);
  htp.p( '</BODY>' );
 htp.htmlclose;
end err_page;

procedure pg(stype in integer, tname in varchar2 default 'DEFAULT')
as
 x integer;
begin
 return;
 -- not used but kept just in case
 begin x := nvl(glbx.sctrl(tname,'DISPLAY_HORIZONTAL',stype),3); exception when others then x := 1; end;
 htp.tablerowopen( cattributes=>'bgcolor="#333333"' );
 htp.p( '<TD colspan="' || x || '" bgcolor="#333333" valign="middle" height="18">' );
  htp.tableopen( cattributes=>'<table width="100%" border="0" cellspacing="1" cellpadding="1"' );
   htp.tablerowopen;
    htp.p( '<td width="559" height="15" valign="middle"> ' );
    htp.p( '<Font face=verdana size=1 color=''red''><b>1</b></font>&nbsp;
    <Font face=verdana size=1 color=''#ffffff''>|</font>&nbsp;
    <a href=''xx''>
    <Font face=verdana size=1 color=white>2</font></a>&nbsp;');
    htp.p( '</td>' );
    htp.p( '<td align="right" width="177" height="15" valign="middle" style="text-align: right;">' );
     htp.p( '<font face="Verdana, Arial, Helvetica, sans-serif" size="1" color="#FFFFFF">Page 1 of 6&nbsp;</font>' );
    htp.p( '</td>' );
   htp.tablerowclose;
  htp.tableclose;
 htp.p('</td>' );

 htp.tablerowclose;

end pg;

procedure top_frame( surl in varchar2 )
as
begin
 htp.htmlopen;
  htp.p( '&nbsp;' );
 htp.htmlclose;
end top_frame;

end ftp;

/
