CREATE OR REPLACE package body WEBSYS.aru
as

HARD_CODED_PHOTO_WIDTH   CONSTANT INTEGER := 391;
HARD_CODED_PHOTO_HEIGHT  CONSTANT INTEGER := 316;
HARD_CODED_TNAIL_WIDTH   CONSTANT INTEGER := 180;
HARD_CODED_TNAIL_HEIGHT  CONSTANT INTEGER := 133;
SKIN_LOC	 	 CONSTANT VARCHAR2(50) := 'skin/aru/';
C_BACKIMG	         CONSTANT VARCHAR2(1000) := '<BODY BACKGROUND="' || DECS.IMAGE_LOCATION || SKIN_LOC || 'aru_bottom.jpg"';
C_ALT	                 CONSTANT VARCHAR2(1000) := '<BODY BACKGROUND="' || DECS.IMAGE_LOCATION || SKIN_LOC || 'aru_gcard.jpg"';
DMASK			 CONSTANT VARCHAR2(100)  := 'DD-MON-YYYY';
START_DATE		 CONSTANT VARCHAR2(100)  := '02-JUL-2003';
GCARD			 CONSTANT INTEGER := 25;
PADWIDTH		 CONSTANT INTEGER := 5;
PROGRAM_INITIAL		 CONSTANT VARCHAR2(20)   := 'aru';
SUBMIT_BUTTON 		 CONSTANT VARCHAR2(40)   := 'login_submit_19h.gif';

TEXT_001		 CONSTANT VARCHAR2(1000) := 'The Photo Code Entered is not a valid number';
TEXT_002		 CONSTANT VARCHAR2(1000) := 'Date';
TEXT_003		 CONSTANT VARCHAR2(1000) := 'Location';
TEXT_004		 CONSTANT VARCHAR2(1000) := 'Photo Code';
TEXT_005		 CONSTANT VARCHAR2(1000) := 'Photo''s taken at';
TEXT_006		 CONSTANT VARCHAR2(1000) := 'No Images Found that Matched your Query';
TEXT_007		 CONSTANT VARCHAR2(1000) := 'Previous Set';
TEXT_008		 CONSTANT VARCHAR2(1000) := 'Next Set';
TEXT_009		 CONSTANT VARCHAR2(1000) := 'Buy Photo';
TEXT_010		 CONSTANT VARCHAR2(1000) := 'Send e-card';

TEXT_013		 CONSTANT VARCHAR2(1000) := 'Search again';
TEXT_014		 CONSTANT VARCHAR2(1000) := 'Your Name';
TEXT_015		 CONSTANT VARCHAR2(1000) := 'Your Email Address';
TEXT_016		 CONSTANT VARCHAR2(1000) := 'Send To Name';
TEXT_017		 CONSTANT VARCHAR2(1000) := 'Send To Email Address';
TEXT_018		 CONSTANT VARCHAR2(1000) := 'Greeting';
TEXT_019		 CONSTANT VARCHAR2(1000) := 'Click here to Reply to';
TEXT_020		 CONSTANT VARCHAR2(1000) := 'Your Electronic Greeting Card has been viewed';

TEXT_021		 CONSTANT VARCHAR2(1000) := 'Card Created';
TEXT_022		 CONSTANT VARCHAR2(1000) := 'Card Successfully Edited';
TEXT_023		 CONSTANT VARCHAR2(1000) := 'Shopping Basket';
TEXT_024		 CONSTANT VARCHAR2(1000) := 'From';
TEXT_025		 CONSTANT VARCHAR2(1000) := 'Photo';
TEXT_026		 CONSTANT VARCHAR2(1000) := 'Enlarge Image';
TEXT_027		 CONSTANT VARCHAR2(1000) := 'Search by';

function fixnm( val in varchar2 ) return varchar2;
procedure err_page( surl in varchar2, errm in varchar2 );
procedure open_page( surl in varchar2, acid in integer, stype in integer, pfx in theme%ROWTYPE, bypass in boolean default FALSE, alternative in boolean default FALSE );
procedure close_page;

function backimg( surl varchar2, acid integer )
  return varchar2
as
 cursor c1(acid integer) is select background_img from customer_account where aid = acid;
 retvar	integer;
begin
 return( C_BACKIMG );
 open c1(acid);
 fetch c1 into retvar;
 close c1;
 return( '<BODY BACKGROUND="ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || retvar || '&parm1=DISPLAY_TYPE&parm2=RAW' ||
         '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || 'OWNER' || '">');
end backimg;

function fixnm( val in varchar2 )
 return varchar2
as
 tmp	varchar2(1000);
 x	integer;
begin
 tmp := replace(replace( val, '.jpg', null ), '.JPG', null );
 x := instr(tmp,'-');
 return( substr(tmp,x+1) );
end fixnm;

function indnt( pscene integer )
  return integer
 is
  cursor cparent( pscene integer ) is
   select parent_scene
   from umo_scene
   where umo_scene_id = pscene;
  crec   cparent%ROWTYPE;
 begin
  if pscene is null then return( null ); end if;
  open cparent(pscene);
  fetch cparent into crec;
  close cparent;
  return( nvl(indnt( crec.parent_scene ),0) + 1 );
end indnt;

procedure open_page( surl in varchar2, acid in integer, stype in integer, pfx in theme%ROWTYPE, bypass in boolean default FALSE, alternative in boolean default FALSE )
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

 if pfx.stylesheet is null
  then
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
else
 htp.p( '<link rel="stylesheet" href="/images/site_specific/' || pfx.stylesheet || '">' );
end if;

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

 htp.p( '</HEAD>' );

 mrg := ' TOPMARGIN="' || pfx.top_padding || '" LEFTMARGIN="' || pfx.left_padding || '"' || ' MARGINHEIGHT="' || pfx.top_padding || '" MARGINWIDTH="' || pfx.left_padding || '"';

 if pfx.javascript = 'DISABLE'
  then
   if alternative
    then
     htp.p( C_ALT || ' ' ||  'onload="trap()"' || ' ' || mrg || '>' );
    else
     htp.p( C_BACKIMG || ' ' ||  'onload="trap()"' || ' ' || mrg || '>' );
   end if;
  else
   if alternative
    then
     htp.p( C_ALT || ' ' || mrg || '>' );
    else
     htp.p( C_BACKIMG || ' ' || mrg || '>' );
   end if;
 end if;

 htp.p( '<CENTER>' );
 if stype in (1)
  then
   htp.tableopen( cattributes=>'width="95%" cellpadding=0 cellspacing=0 border=0' );
 elsif stype in (2)
  then
   htp.tableopen( cattributes=>'width="80%" cellpadding=0 cellspacing=0 border=0' );
 elsif stype in (3,4)
  then
   htp.tableopen( cattributes=>'width="75%" cellpadding=0 cellspacing=0 border=0' );
 else
   htp.tableopen( cattributes=>'width="66%" cellpadding=0 cellspacing=0 border=0' );
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

procedure home_page( surl in varchar2, ltype in varchar2 default 'OWNER', acid in integer, msg in varchar2 default null, left_api_parm in varchar2 default null )
as

 cursor c2( snm varchar2, acid integer, phgid integer ) is
   select distinct usc.umo_scene_id,title,parent_scene,order_by
   from umo um, umo_scene usc
   where category = snm and
         um.umo_scene_id = usc.umo_scene_id and
         um.aid = acid
   order by order_by;

 cusrec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 xltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, xltype, owner_id, sts, 'S', progcalled=>PROGRAM_INITIAL || '.HOME_PAGE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, xltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 open_page(surl, cusrec.aid, stype, pfx);

  htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
  htp.formopen( PROGRAM_INITIAL || '.accept_home_page' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );

   htp.tablerowopen;
    htp.tabledata( '&nbsp;' );
    htp.tabledata( glbx.userpref( cusrec.pid, cusrec.aid, 'HELP_DETAILS' ) );
   htp.tablerowclose;

   htp.tablerowopen;
    htp.tabledata( htf.bold( TEXT_004 || ':' ) );
    htp.tabledata( htf.formtext( 'P1', 30, 100 ) || ' ' ||
                   htf.formimage( 'pcode1',DECS.IMAGE_LOCATION || SKIN_LOC || SUBMIT_BUTTON, cattributes=>'BORDER=0' ) ||
                   htf.nl || htf.nl);
   htp.tablerowclose;

   htp.tablerowopen;
    htp.tabledata( '&nbsp;' );
    htp.tabledata( glbx.userpref( cusrec.pid, cusrec.aid, 'HELP_SEARCH' ) );
   htp.tablerowclose;

   htp.tablerowopen;
    htp.tabledata( htf.bold( TEXT_027 || ':' ) );
    htp.p( '<TD>' );
     htp.formselectopen( 'P2' );
      htp.formselectoption( TEXT_002, cattributes=>'VALUE="DATE"' );
      for j in 1..120 loop
       htp.formselectoption( to_char(to_date( START_DATE, DMASK ) + j, DMASK ));
      end loop;
     htp.formselectclose;

     htp.p( ' ' || htf.bold( 'or' ) || ' ' );

     htp.formselectopen( 'P3' );
      htp.formselectoption( TEXT_003, cattributes=>'VALUE="LOCATION"' );
       for c2rec in c2(cusrec.scene_name, cusrec.aid, cusrec.pid ) loop
         htp.formselectoption( lpad('.', indnt(c2rec.parent_scene),'.') || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
       end loop;
     htp.formselectclose;
     htp.p( ' ' );
     htp.formimage( 'pcode2', DECS.IMAGE_LOCATION || SKIN_LOC || SUBMIT_BUTTON, cattributes=>'BORDER=0' );
    htp.p( '</TD>' );
   htp.tablerowclose;

  htp.formclose;
  htp.tableclose;

  if msg is not null
   then
    glbx.header_msg( msg );
  end if;

  close_page;
exception
 when others then err_page( surl, sqlerrm );
end home_page;

procedure accept_home_page( surl in varchar2, acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, pcode1 in varchar2 default null, pcode2 in varchar2 default null )
as

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 vp1		integer;
 vp3		GLBX.MYARRAY;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>PROGRAM_INITIAL || '.ACCEPT_HOME_PAGE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( c1rec.theme_name );

 if p1 is not null
  then
   -- Search based on ID
   begin vp1 := to_number(p1); exception when others then home_page( surl, ltype, acid, TEXT_001 ); return; end;

   cst.simple_search(surl, p1=>'1-' || lpad(p1,PADWIDTH,'0'), p2=>'N', p3=>vp3, acid=>acid, age=>null, umoids=>',0,', find=>null, display_number=>null, sorton=>'N', image_dim=>'A');
   return;

 elsif p2 <> 'DATE' and p3 = 'LOCATION'
  then
   -- Search based on Date
   cst.simple_search(surl, p1=>p2, p2=>'N', p3=>vp3, acid=>acid, age=>null, umoids=>',0,', find=>null, display_number=>null, sorton=>'N', image_dim=>'A');
   return;

 elsif p3 <> 'LOCATION'
  then
   -- Search based on Location
   if p2 = 'DATE'
    then
     cst.disp_category(surl, left_api_parm=>p3,start_from=>1);
     return;
    else
     vp3(1) := p3;
     cst.simple_search(surl, p1=>p2, p2=>'N', p3=>vp3, acid=>acid, age=>null, umoids=>null, find=>null, display_number=>null, sorton=>'N', image_dim=>'A');
     return;
   end if;

 end if;

 home_page( surl, ltype, acid );

exception
 when others then err_page( surl, sqlerrm );
end accept_home_page;

procedure main_display(surl  varchar2, stype integer, ltype varchar2, umrec UMP.SEARCH_RESULT_PHG, cusrec CUSTOMER_ACCOUNT%ROWTYPE, pfx   THEME%ROWTYPE,
		       theme_rec  theme_types%ROWTYPE, footer_api varchar2, current_page_number  integer default 1, search_total    integer default 0,
		       display_detail  char default null, left_api   varchar2, left_api_parm   varchar2, cusloc varchar2, lbox  varchar2, acid  integer default null,
		       sessid integer, msg   varchar2 )
as

 cursor c2(v_umo integer, attname varchar2 )
  is
   select value
   from umo_attributes uts, umo_attribute uta
   where uta.attribute_id = uts.attribute_id and
         uta.umo_id = v_umo and
         uts.sub_category = attname and
         uts.umo_type = 'PHOTO';

  c2rec			c2%ROWTYPE;
  nmb			integer;
  ctr			integer;
  x			integer;
  hor_caption		varchar2(4000);
  vhor_caption		varchar2(4000);

begin
  if (search_total = 1)
   then
    -- Image Exists go straight to main
    main_image(surl=>surl, acid=>acid, v_umo=>umrec(umrec.first).umo_id, footer_api=>footer_api, left_api_parm=>left_api_parm, current_page_number=>current_page_number, foundimg=>'T');
    return;

  elsif umrec.count >= 1
   then
    --open c2( umrec(umrec.first).umo_id,'DATE TAKEN' );
    --fetch c2 into c2rec;
    --close c2;
    c2rec.value := umrec(umrec.first).extras.title;
    open_page(surl, cusrec.aid, stype, pfx, TRUE);
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 width="100%" border=0' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( TEXT_005 || ':' || ' ' || c2rec.value ), cattributes=>'ALIGN="LEFT" style="text-align: left;"');
      htp.tabledata( htf.anchor( 'glbx.acct_home?surl=' || surl, htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'your_photo_search_again.gif', cattributes=>'BORDER=0' )), cattributes=>'ALIGN="RIGHT" style="text-align: right;"');
     -- xxx
     /*
     htp.anchor( 'fname.acct_orders?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,
                  htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'your_photo_buy_photo.gif',cattributes=>'border=0',calt=>TEXT_009 )) ;
     */
     htp.tablerowclose;
    htp.tableclose;
    --htp.nl;
    htp.line( cattributes=>'width="100%"' );

   else
    home_page( surl, ltype, acid, TEXT_006 );
    return;
  end if;

  vhor_caption := glbx.userpref( cusrec.pid, cusrec.aid, 'TNAIL_PREF' );
  htp.tableopen( cattributes=>'cellspacing=0 cellpadding=4 border=0' );

  htp.tablerowopen;
  ctr := 0;
  if stype = 1 then x := 3; else x := 4; end if;
  for j in umrec.first..umrec.last loop
   ctr := ctr + 1;
   if mod( (ctr-1), x ) = 0 then htp.tablerowclose; htp.tablerowopen; end if;

   -- Display Thumbnail
   htp.p( '<TD ALIGN="CENTER" VALIGN="TOP" style="text-align: center;" >' );
   hor_caption := replace(replace(vhor_caption,'~CAPTION',umrec(j).image_caption),'~NAME', fixnm(umrec(j).extras.photo_name));
   htp.tableopen( cattributes=>'cellspacing=0 cellpadding=' || nvl(pfx.tnail_width,0) || ' border=0 BGCOLOR="#' || pfx.tnail_matte_colour || '"' );
    htp.tablerowopen;
     htp.p( '<TD ALIGN="CENTER" VALIGN="TOP" style="text-align: center;" >' );
     if ltype = 'PHOTOGRAPHER'
      then
      htp.anchor('phg.phg_modify?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&phgid=' || umrec(j).umo_id || '&footer_api=' || replace(footer_api,' ','+') ||
                  '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail ||
                  '&msg=' || null,
                  '<IMG BORDER=0 WIDTH=' || HARD_CODED_TNAIL_WIDTH || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec(j).umo_id ||
                  '&parm1=AID&parm2=' || acid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype ||
                  '&parm1=VERSION&parm2=' || umrec(j).version ||
                  '" ALT="' || hor_caption || '"' || 'STYLE="display:block;"' || '>' );
      else
      htp.anchor('cst.disp_acct_photo?surl=' || glbx.rndsurl(surl) || '&photo_id=' || umrec(j).umo_id || '&footer_api=' || replace(footer_api,' ','+') ||
                  '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail ||
                  '&extra_term=' || null,
                  '<IMG BORDER=0 WIDTH=' || HARD_CODED_TNAIL_WIDTH || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec(j).umo_id ||
                  '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype ||
                  '&parm1=VERSION&parm2=' || umrec(j).version ||
                  '" ALT="' || hor_caption || '"' || 'STYLE="display:block;"' || '>' );
     end if;
     htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tableclose;

    --htp.tablerowopen;
    -- htp.p( '<TD WIDTH="100%">' );
     htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0 width="100%" BGCOLOR="#' || pfx.tnail_matte_colour || '"'  );
     htp.tablerowopen;
     htp.tabledata( '&nbsp;&nbsp;' || TEXT_025 || ':', cattributes=>'align="LEFT" style="text-align: left;"' );
     htp.tabledata( htf.bold( fixnm(umrec(j).extras.photo_name)), cattributes=>'align="CENTER" style="text-align: center;"' );

     htp.tabledata( '&nbsp;' ||
      htf.anchor( 'fname.download_file?surl=' || surl || '&v_umo=' || umrec(j).umo_id || '&purchid=&mthod=WEB&acid=' || acid,
                  htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'sml_c.gif',cattributes=>'border=0',calt=>LNG.ORD_TXT_165 )),
                  cattributes=>'align="RIGHT" style="text-align: right;"' );
     htp.tabledata(
      htf.anchor( PROGRAM_INITIAL || '.zoom?surl=' || glbx.truncsurl(surl) || '&v_umo=' || umrec(j).umo_id || '&footer_api=' || replace(footer_api,' ','+') || '&acid=' || acid ||
                  '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail,
                  htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'search_results_zoom.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_178 )),
                  cattributes=>'align="LEFT" style="text-align: left;"' );
     htp.tablerowclose;
     --htp.tableclose;

     htp.p( '</TD>' );
    --htp.tablerowclose;
   htp.tableclose;

   htp.p( '</TD>' );

  end loop;

  htp.tablerowclose;
  htp.tableclose;
  htp.line( cattributes=>'width="100%"' );

  -- Prev and Next Buttons
  nmb := nvl(to_number(glbx.photo_pref(cusrec.pid,cusrec.aid,'NUMBER_PHOTOS')),10);

  htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 width="100%" border=0' );
   htp.tablerowopen;
    if current_page_number > 1
     then
      htp.tabledata( htf.anchor( footer_api || '?surl=' || surl || '&left_api_parm=' || left_api_parm || '&start_from=' || to_char(greatest(current_page_number - nmb,1)) || '&display_detail=' || display_detail || '&acid=' || acid,
         htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'prev.gif', cattributes=>'BORDER=0', calt=>TEXT_007 )), cattributes=>'ALIGN="LEFT" style="text-align: left;"');
    end if;
    if (current_page_number + nmb) <= search_total
     then
      htp.tabledata( htf.anchor( footer_api || '?surl=' || surl || '&left_api_parm=' || left_api_parm || '&start_from=' || to_char(current_page_number + nmb) || '&display_detail=' || display_detail || '&acid=' || acid,
         htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'next.gif', cattributes=>'BORDER=0', calt=>TEXT_008 )), cattributes=>'ALIGN="RIGHT" style="text-align: right;"');
    end if;
   htp.tablerowclose;
  htp.tableclose;
  htp.p( '</BODY>' );
exception
 when others then err_page( surl, sqlerrm );
end main_display;

procedure main_image(surl in varchar2, acid in integer, v_umo in integer default null, footer_api in varchar2 default null, left_api_parm in varchar2 default null, current_page_number in integer default 1, foundimg in char default 'F')
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;

 umorec		c1%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>PROGRAM_INITIAL || '.MAIN_IMAGE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 open c1(to_number(nvl(to_char(v_umo),left_api_parm)), cusrec.aid);
 fetch c1 into umorec;
 close c1;

  open_page(surl, cusrec.aid, stype, pfx);
   htp.tableopen( cattributes=>'cellpadding=0 cellspacing=10 border=0' ); -- TD0
    htp.tablerowopen;
     -- Column 1
     htp.p( '<TD valign="TOP" align="LEFT">' ); -- TD1

     htp.tableopen( cattributes=>'cellpadding=' || nvl(pfx.tnail_width,0) || ' cellspacing=0 border=0' ); -- TD1
      htp.tablerowopen;
      htp.tabledata( '<IMG BORDER=0 WIDTH=' || HARD_CODED_PHOTO_WIDTH || ' SRC="' ||
                    'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id ||
                    '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=VERSION&parm2=' || umorec.version ||
                    '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || to_char(cusrec.aid) || '" ' ||
                    'ALT="' || fixnm(umorec.extras.photo_name) || '" ' || 'STYLE="display:block;"' || '>',
                      cattributes=>'align="CENTER" valign="TOP" bgcolor="#' || pfx.tnail_matte_colour || '" style="text-align: center;"' );
      htp.tablerowclose;
     htp.tableclose; -- TD1

     htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0 width="100%" BGCOLOR="#' || pfx.tnail_matte_colour || '"'  ); -- TD1
      htp.tablerowopen;
       htp.p( '<TD valign="TOP" align="CENTER" bgcolor="#' || pfx.tnail_matte_colour || '">' ); -- TD1
       htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0 width="100%"' ); -- TD2
       htp.tablerowopen;
        htp.tabledata( '&nbsp;&nbsp;' || TEXT_025 || ':', cattributes=>'align="LEFT" style="text-align: left;"' );
        htp.tabledata( htf.bold( fixnm(umorec.extras.photo_name)), cattributes=>'align="LEFT" style="text-align: left;"' );
        htp.tabledata(
         htf.anchor( PROGRAM_INITIAL || '.zoom?surl=' || glbx.truncsurl(surl) || '&v_umo=' || umorec.umo_id || '&footer_api=' || replace(footer_api,' ','+') || '&acid=' || acid ||
                  '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=',
                  htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'search_results_zoom.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_178 )),
                  cattributes=>'align="RIGHT" style="text-align: right;"' );
         htp.tablerowclose;
        htp.tableclose;  -- TD2
        htp.p( '</TD>' );
      htp.tablerowclose;
     htp.tableclose;  -- TD1

     htp.p( '</TD>' );

     -- Column 2
     htp.p( '<TD valign="TOP" align="LEFT">' );
      htp.anchor( 'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=0&p1=0&pa=0&pb=0&pc=0&ppn=&p1=' || umorec.umo_id || '&add_to_trolley=Order+Photos' ||
                  '&footer_api=' || PROGRAM_INITIAL || '.home_page' || '&left_api_parm=' || null || '&current_page_number=' || null ||
                  '&display_detail=' || null || '&acid=' || acid,
                  htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'your_photo_buy_photo.gif',cattributes=>'border=0',calt=>TEXT_009 )) ;
      htp.nl;
      htp.anchor( 'fname.download_file?surl=' || surl || '&v_umo=' || umorec.umo_id || '&purchid=&mthod=WEB&acid=' || acid,
                  htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'sml_c_larger.gif',cattributes=>'border=0',calt=>LNG.ORD_TXT_165 ));
      htp.nl;
      htp.anchor( PROGRAM_INITIAL || '.create_card?surl=' || glbx.rndsurl(surl) || '&photo_id=' || umorec.umo_id || '&card_shape=1' ||
                  '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' ||
                  current_page_number || '&display_detail=',
                  htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'your_photo_e-card.gif',cattributes=>'border=0',calt=>TEXT_010 ) );
      htp.nl;
      htp.nl;
      htp.anchor( 'fname.acct_orders?surl=' || glbx.rndsurl(surl) ||
                  '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+'),
                  htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'sbasket.gif',cattributes=>'border=0',calt=>TEXT_023 ) );
      htp.nl;
      htp.nl;

      if foundimg = 'T'
       then
        htp.bold( glbx.userpref( cusrec.pid, cusrec.aid, 'HELP_INST' ) );
        htp.nl;
       else
        htp.bold( glbx.userpref( cusrec.pid, cusrec.aid, 'HELP_INST' ) );
        htp.nl;
      end if;

      htp.nl;
      htp.anchor( PROGRAM_INITIAL || '.home_page?surl=' || glbx.rndsurl(surl) || '&ltype=' || ltype || '&acid=' || acid,
                  htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'your_photo_search_again.gif',cattributes=>'border=0',calt=>TEXT_013 ) );
     htp.p( '</TD>' );
    htp.tablerowclose;
   htp.tableclose; -- TD0

  close_page;

exception
 when others then err_page( surl, sqlerrm );
end main_image;

procedure zoom(surl in varchar2, acid in integer, v_umo in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, zoom_factor in varchar2 default 1)
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;
  cursor c10(acid integer) is select zoom_factor from customer_account where aid = acid;

 umorec		c1%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 zfactor	char(10);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>PROGRAM_INITIAL || '.MAIN_IMAGE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 open c1(v_umo, cusrec.aid);
 fetch c1 into umorec;
 close c1;

 open c10(cusrec.aid);
 fetch c10 into zfactor;
 close c10;

  open_page(surl, cusrec.aid, stype, pfx);
  htp.p( '<B>' );
   htp.p( TEXT_026 || ':' );
   if substr(zfactor,1,1) = 'T' then htp.anchor( PROGRAM_INITIAL || '.zoom?surl=' || glbx.truncsurl(surl) || '&v_umo=' || v_umo || '&footer_api=' || replace(footer_api,' ','+') || '&acid=' || acid || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&zoom_factor=0.25','[Zoom x 25%]' );  end if;
   if substr(zfactor,2,1) = 'T' then htp.anchor( PROGRAM_INITIAL || '.zoom?surl=' || glbx.truncsurl(surl) || '&v_umo=' || v_umo || '&footer_api=' || replace(footer_api,' ','+') || '&acid=' || acid || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&zoom_factor=0.5','[Zoom x 50%]' );  end if;
   if substr(zfactor,3,1) = 'T' then htp.anchor( PROGRAM_INITIAL || '.zoom?surl=' || glbx.truncsurl(surl) || '&v_umo=' || v_umo || '&footer_api=' || replace(footer_api,' ','+') || '&acid=' || acid || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&zoom_factor=0.75','[Zoom x 75%]' );  end if;
   if substr(zfactor,4,1) = 'T' then htp.anchor( PROGRAM_INITIAL || '.zoom?surl=' || glbx.truncsurl(surl) || '&v_umo=' || v_umo || '&footer_api=' || replace(footer_api,' ','+') || '&acid=' || acid || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&zoom_factor=1','[Zoom x 1]' );  end if;
   if substr(zfactor,5,1) = 'T' then htp.anchor( PROGRAM_INITIAL || '.zoom?surl=' || glbx.truncsurl(surl) || '&v_umo=' || v_umo || '&footer_api=' || replace(footer_api,' ','+') || '&acid=' || acid || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&zoom_factor=1.5','[Zoom x 1.5]' );  end if;
   if substr(zfactor,6,1) = 'T' then htp.anchor( PROGRAM_INITIAL || '.zoom?surl=' || glbx.truncsurl(surl) || '&v_umo=' || v_umo || '&footer_api=' || replace(footer_api,' ','+') || '&acid=' || acid || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&zoom_factor=2','[Zoom x 2]' );  end if;
   if substr(zfactor,7,1) = 'T' then htp.anchor( PROGRAM_INITIAL || '.zoom?surl=' || glbx.truncsurl(surl) || '&v_umo=' || v_umo || '&footer_api=' || replace(footer_api,' ','+') || '&acid=' || acid || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&zoom_factor=3','[Zoom x 3]' );  end if;
   if substr(zfactor,8,1) = 'T' then htp.anchor( PROGRAM_INITIAL || '.zoom?surl=' || glbx.truncsurl(surl) || '&v_umo=' || v_umo || '&footer_api=' || replace(footer_api,' ','+') || '&acid=' || acid || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&zoom_factor=4','[Zoom x 4]' );  end if;
   if substr(zfactor,9,1) = 'T' then htp.anchor( PROGRAM_INITIAL || '.zoom?surl=' || glbx.truncsurl(surl) || '&v_umo=' || v_umo || '&footer_api=' || replace(footer_api,' ','+') || '&acid=' || acid || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&zoom_factor=5','[Zoom x 5]' ); htp.nl; end if;
  htp.p( '</B>' );

  htp.tableopen( cattributes=>'cellpadding=4 cellspacing=0 border=0' );
    htp.tablerowopen;
     htp.p( '<TD valign="TOP" align="LEFT" >' );
      htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
      htp.tablerowopen;
      htp.p( '<TD ALIGN="LEFT" VALIGN="TOP">' );
      htp.anchor( 'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=0&p1=0&pa=0&pb=0&pc=0&ppn=&p1=' || umorec.umo_id || '&add_to_trolley=Order+Photos' ||
                  '&footer_api=' || PROGRAM_INITIAL || '.main_image' || '&left_api_parm=' || umorec.umo_id || '&current_page_number=' || current_page_number ||
                  '&display_detail=' || null || '&acid=' || acid,
                  htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'your_photo_buy_photo.gif',cattributes=>'border=0',calt=>TEXT_009 )) ;
      htp.p( '</TD>' );
      htp.tablerowclose;
      htp.tablerowopen;
      htp.p( '<TD ALIGN="LEFT" VALIGN="TOP">' );
      htp.anchor( 'fname.download_file?surl=' || surl || '&v_umo=' || umorec.umo_id || '&purchid=&mthod=WEB&acid=' || acid,
                  htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'sml_c_larger.gif',cattributes=>'border=0',calt=>LNG.ORD_TXT_165 ));
      htp.p( '</TD>' );
      htp.tablerowclose;
      htp.tablerowopen;
      htp.p( '<TD ALIGN="LEFT" VALIGN="TOP">' );
      htp.anchor( PROGRAM_INITIAL || '.create_card?surl=' || glbx.rndsurl(surl) || '&photo_id=' || umorec.umo_id || '&card_shape=1' ||
                  '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' ||
                  current_page_number || '&display_detail=',
                  htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'your_photo_e-card.gif',cattributes=>'border=0',calt=>TEXT_010 ) );
      htp.p( '</TD>' );
      htp.tablerowclose;
      htp.tablerowopen;
      htp.p( '<TD ALIGN="LEFT" VALIGN="TOP">' );
      htp.nl;
      htp.anchor( 'fname.acct_orders?surl=' || glbx.rndsurl(surl) ||
                  '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+'),
                  htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'sbasket.gif',cattributes=>'border=0',calt=>TEXT_023 ) );

      htp.nl;
      htp.nl;

      htp.anchor( PROGRAM_INITIAL || '.home_page?surl=' || glbx.rndsurl(surl) || '&ltype=' || ltype || '&acid=' || acid,
                  htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'your_photo_search_again.gif',cattributes=>'border=0',calt=>TEXT_013 ) );
      htp.p( '</TD>' );
      htp.tablerowclose;
      htp.tableclose;
     htp.p( '</TD>' );
     htp.p( '<TD valign="TOP" align="LEFT">' ); -- TD1
     htp.tableopen( cattributes=>'cellpadding=' || nvl(pfx.tnail_width,0) || ' cellspacing=0 border=0' ); -- TD2
      htp.tablerowopen;
       htp.tabledata( '<IMG BORDER=0 WIDTH=' || round(HARD_CODED_PHOTO_WIDTH * to_number(zoom_factor)) || ' SRC="' ||
                    'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id ||
                    '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=VERSION&parm2=' || umorec.version ||
                    '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || to_char(cusrec.aid) || '" ' ||
                    'ALT="' || fixnm(umorec.extras.photo_name) || '" ' || 'STYLE="display:block;"' || '>',
                      cattributes=>'align="CENTER" valign="TOP" bgcolor="#' || pfx.tnail_matte_colour || '" style="text-align: center;"' );
       htp.tablerowclose;
      htp.tableclose;  -- TD2
      htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0 width="100%" BGCOLOR="#' || pfx.tnail_matte_colour || '"'  );
       htp.tablerowopen;
        htp.tabledata(htf.bold( fixnm(umorec.extras.photo_name) ), cattributes=>'align="CENTER" style="text-align: center;"');
       htp.tablerowclose;
      htp.tableclose;
     htp.p( '</TD>' );
    htp.tablerowclose;
   htp.tableclose;

  close_page;

exception
 when others then err_page( surl, sqlerrm );
end zoom;

procedure err_page( surl in varchar2, errm in varchar2 )
as
begin
 htp.htmlopen;
  htp.p( C_BACKIMG );
   glbx.error_details( 'ARU', 'SKIN',errmsg=>errm);
  htp.p( '</BODY>' );
 htp.htmlclose;
end err_page;

 function extract_email( surl varchar2,em in varchar2 )
  return GLBX.MYARRAY
 as
  retem	GLBX.MYARRAY;
  ctr	integer;
  ptr	integer;
  lptr	integer;
 begin
  ctr := 1;
  lptr := 0;
  loop
   ptr := nvl(instr(em,',',1,ctr),0);
   if ptr = 0
    then
     retem( ctr ) := substr(em,lptr+1);
     exit;
    else
     retem( ctr ) := substr(em,lptr+1,(ptr-lptr)-1);
   end if;
   lptr := ptr;
   ctr := ctr + 1;
  end loop;
  return( retem );
exception when others then
 glbx.error_details( 'ARU', 'EXTRACT_EMAIL',errmsg=>sqlerrm,extdet=>EM);
end extract_email;

procedure create_card(surl varchar2, photo_id in integer, scard in varchar2 default null, card_shape in integer default 1, msg in varchar2 default null,
                      p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null,
	              p4 in varchar2 default null, p5 in varchar2 default null, p6 in date default null, p1a in varchar2 default null, p2a in varchar2 default null,
	              footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2)
 as

 cursor c2(acid integer, photo_id integer) is select photo_master,version,extras from umo where umo_id = photo_id and aid = acid;
 cursor c3 is select style_name from ecard_style order by style_name;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 photo_name	varchar2(100);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		varchar2(2000);
 retem		GLBX.MYARRAY;
 ctr		integer;
 oth		integer;

 begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>PROGRAM_INITIAL || '.CREATE_CARD' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 open c2(owner_id,photo_id);
 fetch c2 into c2rec;
 close c2;
 retem := extract_email(surl,p2);
 if not retem.exists(1)
  then
   retem(1) := NULL;
 end if;
 photo_name := fixnm(ump.uma_attribute( surl,photo_id, 'PHOTO','NAME'));
 --glbx.main_title( surl, null, backimg(surl, c1rec.aid), helpid=>'D01',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active);
 open_page(surl, c1rec.aid, stype, pfx);

 htp.formopen( PROGRAM_INITIAL || '.accept_create' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'PHOTO_ID', photo_id );
 htp.formhidden( 'SCARD', scard );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );
 --htp.formhidden( 'CARD_SHAPE', nvl(card_shape,'1') );
 htp.nl;

  htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
   htp.tablerowopen;
   htp.p( '<td valign="TOP">' );
  htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
   htp.tablerowopen;
    htp.tabledata( htf.bold(TEXT_016 || ':') );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.formtext( 'P2A', GCARD, 100, p2a ));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(TEXT_017 || ':') );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.formtext( 'P2', GCARD, 1000, retem(1) ));
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(TEXT_014 || ':') );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.formtext( 'P1A', GCARD, 100, p1a ));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(TEXT_015 || ':') );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.formtext( 'P1', GCARD, 100, nvl(p1,glbx.get_email(surl)) ));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.formhidden( 'P3', 'NONE' ) ||
                   htf.formhidden( 'P4', LNG.SLD_TXT_021 ) ||
                   htf.bold(TEXT_018 || ':'));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.formtextareaopen( 'P5', 5, GCARD, cattributes=>'WRAP="VIRTUAL"' ) || p5 || htf.formtextareaclose);
   htp.tablerowclose;
   htp.formhidden( 'EXT', null );
   htp.tablerowopen;
   if scard is null
    then
      htp.tabledata(htf.formimage( 'ACTION',DECS.IMAGE_LOCATION || SKIN_LOC || 'e-card_input_create.gif', cattributes=>'BORDER=0' ),cattributes=>'ALIGN="RIGHT" style="text-align: right;"');
    else
      htp.tabledata(htf.formimage( 'ACTION',DECS.IMAGE_LOCATION || SKIN_LOC || 'e-card_input_create.gif', cattributes=>'BORDER=0' ),cattributes=>'ALIGN="RIGHT" style="text-align: right;"');
   end if;
   htp.tablerowclose;
  htp.tableclose;
  htp.p( '</td>' );

  htp.p( '<TD VALIGN="TOP">' );
--   htp.tableopen( cattributes=>'cellpadding='  || pfx.tnail_border || ' cellspacing=0 border=0' );
   htp.tableopen( cattributes=>'cellpadding=' || nvl(pfx.tnail_width,0) || ' cellspacing=0 border=0' );
   htp.tablerowopen;
     htp.p( '<TD align="CENTER" valign="TOP" bgcolor="#' || pfx.tnail_matte_colour || '" style="text-align: center;">' );
      htp.p('<IMG BORDER=0 WIDTH=' || HARD_CODED_PHOTO_WIDTH || ' SRC="' ||
            'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || photo_id ||
            '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype ||
            '&parm1=VERSION&parm2=' || c2rec.version ||
            '" ALT="' || fixnm(c2rec.extras.photo_name) || '"' || ' STYLE="display:block;"' || '>' );
     htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;
  htp.p( '</TD>' );

  htp.tablerowclose;
  htp.tableclose;

 htp.formclose;
 htp.nl;
 if p6 is not null
  then
    htp.header(3,htf.bold(LNG2.GCARD_TXT_025) || ' : ' || htf.italic( to_char(p6,LNG.MASK)),'CENTER' );
 end if;

 close_page;

exception when others then
 glbx.error_details( 'ARU', 'CREATE_CARD',c1rec.pid,owner_id,photo_id,errmsg=>sqlerrm);
end create_card;

procedure accept_create( surl varchar2, photo_id in integer, scard in integer, action in varchar2, card_shape in integer default 1,
                         p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p1a in varchar2, p2a in varchar2, ext in GLBX.MYARRAY,
                         footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2)
 as

 cursor c2(photo_id integer,acid integer) is
  select um.extras.photo_name photo_name,um.photo_master.width width, um.photo_master.height height
  from umo um
  where umo_id = photo_id and
        um.extras.enabled_phg = 'TRUE' and
		aid = acid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		varchar2(2000);
 new_scard	integer;
 cexp		integer;
 np2		varchar2(32767);
 np5		varchar2(4000);

 begin

 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>PROGRAM_INITIAL || '.ACCEPT_CREATE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 np2 := p2;

 for j in ext.first..ext.last loop
  if ext(j) is not null
   then
    begin
     np2 := np2 || ',' || ext(j);
    exception
     when others then exit;
    end;
  end if;
 end loop;
 np2 := substr(np2,1,1000);
 np5 := glbx.censor(p5,1000);
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 open c2(photo_id,owner_id);
 fetch c2 into c2rec;
 close c2;
 if action = LNG.CST_BUT_016 and scard is not null
  then
   gcard_menu(surl,scard,LNG2.GCARD_TXT_026,owner_id,c1rec,pfx,stype,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail, ltype=>ltype);
   htp.htmlclose;
   return;
 end if;
 if p1 is null or p1a is null
  then
   create_card(surl,photo_id,scard,card_shape,LNG2.GCARD_TXT_027,p1,np2,p3,p4,np5,null,p1a,p2a,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail);
   return;
 end if;
 if np2 is null or p2a is null
  then
   create_card(surl,photo_id,scard,card_shape,LNG2.GCARD_TXT_028,p1,np2,p3,p4,np5,null,p1a,p2a,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail);
   return;
 end if;
 if scard is null
  then
   cexp := glbx.extract_master_parameter('CARD_EXPIRY');
   select s_ecard.nextval into new_scard from dual;
   insert into ecard(eid,aid,phid,created,expires,style,border,photo_name,from_email,sendto,greeting,width,height,is_accessed,shape,nfrom_email,nsendto)
    values
     (new_scard,c1rec.aid,photo_id,sysdate,sysdate+cexp,p3,p4,c2rec.photo_name,p1,np2,np5,c2rec.width,c2rec.height,'F',card_shape,p1a,p2a);
   insert into track_email(pid,aid,date_stored,track_type,email_address,made_by)
    values
	 (photo_id,c1rec.aid,sysdate,'GREETING CARD',np2,p1);
   commit;
   gcard_menu(surl,new_scard,TEXT_021,owner_id,c1rec,pfx,stype,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail, ltype=>ltype);
  else
   update ecard
    set
	 from_email = p1,
	 sendto = np2,
	 nfrom_email = p1a,
	 nsendto = p2a,
	 style = p3,
	 border = p4,
	 greeting = np5,
	 shape = card_shape
   where eid = scard;
   commit;
   gcard_menu(surl,scard,TEXT_022,owner_id,c1rec,pfx,stype,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail, ltype=>ltype);
 end if;

 close_page;

exception when others then
 glbx.error_details( 'ARU', 'ACCEPT_CREATE',c1rec.pid,owner_id,photo_id,errmsg=>sqlerrm);
end accept_create;

procedure view_card( scard in varchar2, pw in varchar2, stype in integer default 1, ltype in varchar2 default 'EXTERNAL', surl varchar2 default null )
as
 cursor c1(scard integer) is select * from ecard where eid=scard;
 cursor c2(acid integer) is select * from customer_account where aid=acid;
 cursor c3(styl varchar2) is select * from ecard_style where style_name = styl;
 cursor c4(acid integer) is select * from photographer where pid = (select pid from customer_account where aid=acid);
 cursor c5(thm varchar2) is select * from theme where theme_name = thm;
 cursor c6(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 pfx		c5%ROWTYPE;
 umorec		c6%ROWTYPE;
 brd		integer;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin
  if replace(pw,'3D',null) <> glbx.encrypt( DECS.GREETING_CARD_KEYWORD || replace(scard,'3D',null), TRUE )
   then
    htp.header( 2, LNG2.GCARD_TXT_036, 'CENTER' );
    htp.htmlclose;
    return;
  end if;

  open c1(replace(scard,'3D',null));
  fetch c1 into c1rec;
  close c1;

  open c3(c1rec.style);
  fetch c3 into c3rec;
  close c3;

  if sysdate > c1rec.expires
   then
    htp.header( 2, LNG2.GCARD_TXT_037, 'CENTER' );
    htp.htmlclose;
    return;
  end if;

  open c2(c1rec.aid);
  fetch c2 into c2rec;
  close c2;

  open c5(c2rec.theme_name);
  fetch c5 into pfx;
  close c5;

 ------------------------------------------------
 open_page(surl, c2rec.aid, stype, pfx, alternative=>TRUE);
 open c6(c1rec.phid, c1rec.aid);
 fetch c6 into umorec;
 close c6;
 htp.nl;
 htp.nl;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=10 cellspacing=0 border=0' );
 htp.tablerowopen;
 htp.p( '<TD VALIGN="TOP" ALIGN="CENTER" style="text-align: center;">' );
  htp.tableopen( cattributes=>'cellpadding=' || nvl(pfx.tnail_width,0) || ' cellspacing=0 border=0' );
   htp.tablerowopen;
     htp.tabledata( '<IMG BORDER=0 WIDTH=' || HARD_CODED_PHOTO_WIDTH || ' SRC="' ||
                    'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' ||
                    '&parm1=LOGIN_TYPE&parm2=EXTERNAL&parm1=PASSWORD&parm2=' || replace(pw,'3D',null) || '&parm1=GREETING_CARD&parm2=' || replace(scard,'3D',null) || '" ' ||
                    'ALT="' || fixnm(umorec.extras.photo_name) || '" ' || 'STYLE="display:block;"' || '>',
                      cattributes=>'align="CENTER" valign="TOP" bgcolor="#' || pfx.tnail_matte_colour || '"  style="text-align: center;"' );
   htp.tablerowclose;
  htp.tableclose;
 htp.p( '</TD>' );
 htp.p( '<TD VALIGN="TOP" ALIGN="LEFT" style="text-align: left;">' );
 if c1rec.nsendto is not null
  then
   htp.bold( c1rec.nsendto || ',' );
   htp.nl;
   htp.nl;
 end if;
 htp.bold( c1rec.greeting );
 htp.nl;
 htp.nl;
 htp.p( TEXT_024 || ':' );
 htp.bold( c1rec.nfrom_email );
 htp.nl;
 htp.p( c1rec.from_email );
 htp.nl;

 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;

 close_page;

 ------------------------------------------------

 open c4(c1rec.aid);
 fetch c4 into c4rec;
 close c4;

 if c1rec.is_accessed = 'F'
  then
   update ecard
    set is_accessed = 'T'
	 where eid = replace(scard,'3D',null);
   commit;
   gcode(1) := 'NSENDTO';
   gparam(1) := c1rec.nsendto;
   gcode(2) := 'SENDTO';
   gparam(2) := c1rec.sendto;
   gcode(3) := 'LOGIN_ADDRESS';
   gparam(3) := glbx.extract_master_parameter('ECARD_LINK') || '?scard=' || replace(scard,'3D',null) || '&pw=' || glbx.encrypt( DECS.GREETING_CARD_KEYWORD || c1rec.eid, TRUE );
   gcode(4) := 'PHOTOGRAPHER';
   gparam(4) := c4rec.business_name;
   gcode(5) := 'PHOTOGRAPHER_SITE';
   gparam(5) := nvl(c4rec.home_site,c4rec.contact_email);
   gcode(6) := 'SIGNATURE';
   gparam(6) := glbx.extract_master_parameter('MAIL SIGNATURE');
   glbx.send( gcode, gparam, 'greeting_accept.tmp', c1rec.from_email, TEXT_020, glbx.extract_master_parameter('MAIL_FROM'),is_attachment=>TRUE, scode=>'ARU_G1');
 end if;
 insert into ecard_log(eid,date_viewed) values (replace(scard,'3D',null),sysdate);
 commit;

exception when others then
 glbx.error_details( 'ARU', 'VIEW_CARD',errmsg=>sqlerrm,extdet=>'SCARD:' || replace(scard,'3D',null) );
end view_card;

procedure gcard_menu( surl varchar2, scard in integer, msg in varchar2, owner_id in integer, c1rec in customer_account%ROWTYPE, pfx in THEME%ROWTYPE, stype in integer,
                      footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2, ltype in varchar2)
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;
 cursor c2(scard integer, acid integer) is select * from ecard where eid=scard and aid = acid;

 umorec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;

begin
 --glbx.main_title( surl, null, backimg(surl, c1rec.aid), helpid=>'D02',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active);
 --set_main;
 open_page(surl, c1rec.aid, stype, pfx);
 open c2(scard, c1rec.aid);
 fetch c2 into c2rec;
 close c2;
 open c1(c2rec.phid, c1rec.aid);
 fetch c1 into umorec;
 close c1;
 htp.tableopen( cattributes=>'cellpadding=10 cellspacing=0 border=0' );
 htp.tablerowopen;
 htp.p( '<TD VALIGN="TOP" ALIGN="CENTER" style="text-align: center;">' );

  htp.tableopen( cattributes=>'cellpadding=' || nvl(pfx.tnail_width,0) || ' cellspacing=0 border=0' );
   htp.tablerowopen;
     htp.tabledata( '<IMG BORDER=0 WIDTH=' || HARD_CODED_PHOTO_WIDTH || ' SRC="' ||
                    'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id ||
                    '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=VERSION&parm2=' || umorec.version ||
                    '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || to_char(c1rec.aid) || '" ' ||
                    'ALT="' || fixnm(umorec.extras.photo_name) || '" ' || 'STYLE="display:block;"' || '>',
                      cattributes=>'align="CENTER" valign="TOP" bgcolor="#' || pfx.tnail_matte_colour || '"  style="text-align: center;"' );
   htp.tablerowclose;
  htp.tableclose;
 htp.p( '<TD VALIGN="TOP" ALIGN="LEFT" style="text-align: left;">' );
 if c2rec.nsendto is not null
  then
   htp.bold( c2rec.nsendto || ',' );
   htp.nl;
   htp.nl;
 end if;
 htp.bold( c2rec.greeting );
 htp.nl;
 htp.nl;
 htp.p( TEXT_024 || ':' );
 htp.bold( c2rec.nfrom_email );
 htp.nl;
 htp.p( c2rec.from_email );
 htp.nl;
 htp.nl;

  htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
   htp.tablerowopen;
   htp.p( '<td valign="TOP">' );
   htp.formopen( PROGRAM_INITIAL || '.accept_menu' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'SCARD', scard );
   htp.formhidden( 'FOOTER_API', footer_api );
   htp.formhidden( 'LEFT_API_PARM', left_api_parm );
   htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
   htp.formhidden( 'DISPLAY_DETAIL', display_detail );

   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
    htp.tablerowopen;
     htp.tabledata( htf.formimage( 'ACTION_SEND', DECS.IMAGE_LOCATION || SKIN_LOC || 'e-card_layout_send.gif',cattributes=>'BORDER="0"' ) || htf.nl || htf.nl);
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.formimage( 'ACTION_DEL',  DECS.IMAGE_LOCATION || SKIN_LOC ||  'e-card_layout_delete.gif',cattributes=>'BORDER="0"' ));
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.formimage( 'ACTION_EDIT', DECS.IMAGE_LOCATION || SKIN_LOC ||  'e-card_layout_edit.gif',cattributes=>'BORDER="0"' ));
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.formimage( 'ACTION_RET',  DECS.IMAGE_LOCATION || SKIN_LOC ||  'e-card_layout_your_photo.gif',cattributes=>'BORDER="0"' ));
    htp.tablerowclose;
    htp.tablerowopen;
   htp.formclose;

  htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tableclose;

 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;

 if msg is not null
  then
   glbx.header_msg( msg );
 end if;

 close_page;
exception when others then
 glbx.error_details( 'ARU', 'GCARD_MENU',c1rec.pid,owner_id,errmsg=>sqlerrm,extdet=>'SCARD:' || scard);
end gcard_menu;

procedure accept_menu( surl varchar2, scard in integer, action_send in varchar2 default null, action_edit in varchar2 default null, action_view in varchar2 default null,
                       action_del in varchar2 default null, action_ret in varchar2 default null,
                       footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2)
 as
 cursor c2(scard integer,acid integer) is select * from ecard where eid = scard and aid = acid;
 cursor c3(acid integer) is select business_name,nvl(home_site,contact_email) cnt from photographer where pid in (select pid from customer_account where aid = acid);
 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 action		varchar2(40);
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

 begin

 if action_send is not null then action := 'Send Greeting Card';
 elsif action_edit is not null then action := 'Edit Greeting Card';
 elsif action_del is not null then action := 'Delete Greeting Card';
 elsif action_ret is not null then action := 'Return to Photo Display';
 end if;

 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>PROGRAM_INITIAL || '.ACCEPT_MENU' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 if action = 'Return to Photo Display'
  then
   open c2(scard,c1rec.aid);
   fetch c2 into c2rec;
   close c2;
   main_image(surl=>surl, acid=>null, v_umo=>c2rec.phid, footer_api=>footer_api, left_api_parm=>left_api_parm, current_page_number=>current_page_number, foundimg=>'T');
   return;
 end if;

 if action = 'Delete Greeting Card'
  then
   open c2(scard,c1rec.aid);
   fetch c2 into c2rec;
   close c2;
   delete from ecard where eid = scard;
   --cst.disp_acct_photo(surl=>surl,photo_id=>c2rec.phid,msg=>LNG2.GCARD_TXT_033,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail);
   if pfx.keep_lhf = 'L' or footer_api is null
    then
     cst.disp_acct_photo(surl=>surl,photo_id=>c2rec.phid,msg=>LNG2.GCARD_TXT_033,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail);
    else
     --glbx.acct_home(surl=>surl,rnd=>to_char(sysdate,'SSSSS'),acid=>null);

      execute immediate
       'begin ' || footer_api ||
        '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
       'end;'
       using glbx.rndsurl(surl),left_api_parm,current_page_number,display_detail,owner_id;

   end if;
   return;
 end if;

 if action = 'Edit Greeting Card'
  then
   open c2(scard,c1rec.aid);
   fetch c2 into c2rec;
   close c2;
   create_card(surl,c2rec.phid,c2rec.eid,c2rec.shape,'Edit Greeting Card', c2rec.from_email, c2rec.sendto, c2rec.style, c2rec.border, c2rec.greeting, c2rec.expires, c2rec.nfrom_email, c2rec.nsendto,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail );
   return;
 end if;

 if action = 'Send Greeting Card'
  then
   open c2(scard,c1rec.aid);
   fetch c2 into c2rec;
   close c2;
   open c3(c1rec.aid);
   fetch c3 into c3rec;
   close c3;
   gcode(1) := 'NFROM_EMAIL';
   gparam(1) := c2rec.nfrom_email;
   gcode(2) := 'FROM_EMAIL';
   gparam(2) := c2rec.from_email;
   gcode(3) := 'LOGIN_ADDRESS';
   gparam(3) := glbx.extract_master_parameter('ECARD_LINK') || '?scard=' || scard || '&pw=' || glbx.encrypt( DECS.GREETING_CARD_KEYWORD || c2rec.eid, TRUE );
   gcode(4) := 'PHOTOGRAPHER';
   gparam(4) := c3rec.business_name;
   gcode(5) := 'PHOTOGRAPHER_SITE';
   gparam(5) := c3rec.cnt;
   gcode(6) := 'SIGNATURE';
   gparam(6) := glbx.extract_master_parameter('MAIL SIGNATURE');
   glbx.send( gcode, gparam, 'greeting_card.tmp', c2rec.sendto, LNG2.GCARD_TXT_034, c2rec.from_email,ltype=>ltype,own_id=>owner_id,is_attachment=>TRUE, scode=>'ARU_GCT1');

   main_image(surl=>surl, acid=>null, v_umo=>c2rec.phid, footer_api=>footer_api, left_api_parm=>left_api_parm, current_page_number=>current_page_number, foundimg=>'T');
   return;
 end if;

 close_page;
exception when others then
 glbx.error_details( 'ARU', 'ACCEPT_MENU',c1rec.pid,owner_id,c2rec.phid,errmsg=>sqlerrm,extdet=>'SCARD:' || scard || ' ACTION:' || action);
end accept_menu;

end aru;

/
