CREATE OR REPLACE package body WEBSYS.lc
as


reterrors		 GLBX.MYARRAY;

HARD_CODED_PHOTO_WIDTH   CONSTANT INTEGER := 391;
HARD_CODED_PHOTO_HEIGHT  CONSTANT INTEGER := 316;
HARD_CODED_TNAIL_WIDTH   CONSTANT INTEGER := 180;
HARD_CODED_TNAIL_HEIGHT  CONSTANT INTEGER := 133;
SKIN_LOC	 	 CONSTANT VARCHAR2(50) := 'skin/lc/';
C_BACKIMG	         CONSTANT VARCHAR2(1000) := '<BODY BACKGROUND="' || DECS.IMAGE_LOCATION || SKIN_LOC || 'lc_bottom.jpg"';
C_ALT	                 CONSTANT VARCHAR2(1000) := '<BODY BACKGROUND="' || DECS.IMAGE_LOCATION || SKIN_LOC || 'lc_gcard.jpg"';
DMASK			 CONSTANT VARCHAR2(100)  := 'DD-MON-YYYY';
START_DATE		 CONSTANT VARCHAR2(100)  := '02-JUL-2003';
GCARD			 CONSTANT INTEGER := 25;
PADWIDTH		 CONSTANT INTEGER := 5;
PROGRAM_INITIAL		 CONSTANT VARCHAR2(20)   := 'lc';

NO_RESULTS		 CONSTANT VARCHAR2(1000) := '<b>The Search Returned No Results</b>';
TEXT_HTML		 CONSTANT VARCHAR2(1000) := 'ALIGN="CENTER" VALIGN="TOP" style="text-align: center;"';
TEXT_HTML_LINEMODE	 CONSTANT VARCHAR2(1000) := 'ALIGN="LEFT" VALIGN="TOP" style="text-align: left; vertical-align: top;"';
TEXT_001		 CONSTANT VARCHAR2(1000) := '';
TEXT_002		 CONSTANT VARCHAR2(1000) := '';
TEXT_003		 CONSTANT VARCHAR2(1000) := '';
TEXT_004		 CONSTANT VARCHAR2(1000) := '';
TEXT_005		 CONSTANT VARCHAR2(1000) := '';
TEXT_006		 CONSTANT VARCHAR2(1000) := '';
TEXT_007		 CONSTANT VARCHAR2(1000) := 'Previous Set';
TEXT_008		 CONSTANT VARCHAR2(1000) := 'Next Set';
TEXT_009		 CONSTANT VARCHAR2(1000) := '';
TEXT_010		 CONSTANT VARCHAR2(1000) := '';

TEXT_013		 CONSTANT VARCHAR2(1000) := '';
TEXT_014		 CONSTANT VARCHAR2(1000) := '';
TEXT_015		 CONSTANT VARCHAR2(1000) := '';
TEXT_016		 CONSTANT VARCHAR2(1000) := '';
TEXT_017		 CONSTANT VARCHAR2(1000) := '';
TEXT_018		 CONSTANT VARCHAR2(1000) := '';
TEXT_019		 CONSTANT VARCHAR2(1000) := '';
TEXT_020		 CONSTANT VARCHAR2(1000) := '';

TEXT_021		 CONSTANT VARCHAR2(1000) := '';
TEXT_022		 CONSTANT VARCHAR2(1000) := '';
TEXT_023		 CONSTANT VARCHAR2(1000) := '';
TEXT_024		 CONSTANT VARCHAR2(1000) := '';
TEXT_025		 CONSTANT VARCHAR2(1000) := '';
TEXT_026		 CONSTANT VARCHAR2(1000) := '';
TEXT_027		 CONSTANT VARCHAR2(1000) := '';
TEXT_028		 CONSTANT VARCHAR2(1000) := 'New Image';
TEXT_029		 CONSTANT VARCHAR2(1000) := 'Edit Details';
TEXT_030		 CONSTANT VARCHAR2(1000) := 'Read Only';

TEXT_031		 CONSTANT VARCHAR2(1000) := 'Image can be attached in documents';
TEXT_032		 CONSTANT VARCHAR2(1000) := 'Image can be attached in documents';
TEXT_033		 CONSTANT VARCHAR2(1000) := 'Version History';
TEXT_034		 CONSTANT VARCHAR2(1000) := 'Date Created';
TEXT_035		 CONSTANT VARCHAR2(1000) := 'Annotation';
TEXT_036		 CONSTANT VARCHAR2(1000) := 'Load New Image';
TEXT_037		 CONSTANT VARCHAR2(1000) := 'Load Meta Data';
TEXT_038		 CONSTANT VARCHAR2(1000) := 'Load Image and/or Update Meta Data';
TEXT_039		 CONSTANT VARCHAR2(1000) := 'Delete Image';
TEXT_040		 CONSTANT VARCHAR2(1000) := 'Replace current image';

TEXT_041		 CONSTANT VARCHAR2(1000) := 'Attach new image as master';
TEXT_042		 CONSTANT VARCHAR2(1000) := 'Attach new image (not master)';
TEXT_043		 CONSTANT VARCHAR2(1000) := 'Use this URL to allow image to be attached in documents';
TEXT_044		 CONSTANT VARCHAR2(1000) := 'This image cannot be viewed externally';
TEXT_045		 CONSTANT VARCHAR2(1000) := 'Caption';
TEXT_046		 CONSTANT VARCHAR2(1000) := 'Display EXIF Information';
TEXT_047		 CONSTANT VARCHAR2(1000) := '# Results';
TEXT_048		 CONSTANT VARCHAR2(1000) := 'Category';
TEXT_049		 CONSTANT VARCHAR2(1000) := 'Advanced Search';
TEXT_050		 CONSTANT VARCHAR2(1000) := 'Insert New Image';

TEXT_051		 CONSTANT VARCHAR2(1000) := 'View Requests';
TEXT_052		 CONSTANT VARCHAR2(1000) := 'Images in Basket';
TEXT_053		 CONSTANT VARCHAR2(1000) := 'Search returned no results';
TEXT_054		 CONSTANT VARCHAR2(1000) := 'Image Deleted';
TEXT_055		 CONSTANT VARCHAR2(1000) := 'EXIF Information';
TEXT_056		 CONSTANT VARCHAR2(1000) := 'Link other Images to this one';
TEXT_057		 CONSTANT VARCHAR2(1000) := 'See Also: Link an Image';
TEXT_058		 CONSTANT VARCHAR2(1000) := 'Enter in keyword to find related images';
TEXT_059		 CONSTANT VARCHAR2(1000) := 'Perform Search';
TEXT_060		 CONSTANT VARCHAR2(1000) := 'You must specify a search keyword';

TEXT_061		 CONSTANT VARCHAR2(1000) := 'Invalid Access';
TEXT_062		 CONSTANT VARCHAR2(1000) := 'Search Results';
TEXT_063		 CONSTANT VARCHAR2(1000) := 'Check the following boxes to link these images to the current one';
TEXT_064		 CONSTANT VARCHAR2(1000) := 'No Images found to match Search';
TEXT_065		 CONSTANT VARCHAR2(1000) := 'Link all Checked Images';
TEXT_066		 CONSTANT VARCHAR2(1000) := 'Perform another search';
TEXT_067		 CONSTANT VARCHAR2(1000) := 'Already Linked';
TEXT_068		 CONSTANT VARCHAR2(1000) := 'New Link Added';
TEXT_069		 CONSTANT VARCHAR2(1000) := '';
TEXT_070		 CONSTANT VARCHAR2(1000) := '';

procedure err_page( surl in varchar2, errm in varchar2 );
procedure open_page( surl in varchar2, acid in integer, stype in integer, pfx in theme%ROWTYPE, bypass in boolean default FALSE, alternative in boolean default FALSE, ttl in varchar2 default null, cusrec in customer_account%ROWTYPE, ltype in varchar2 );
procedure close_page;
procedure pg(stype in integer, tname in varchar2 default 'DEFAULT');
procedure initialise_control_buttons( surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, cusloc in varchar2, dispvert in char, acid integer );
procedure disp_src( surl in varchar2, acid in integer, cusrec in customer_account%ROWTYPE, stype in integer, pfx in theme%ROWTYPE, left_api_parm in varchar2, search_total in integer, itext in varchar2, uscid in integer default null, theme_rec in theme_types%ROWTYPE, ltype in varchar2, footer_api in varchar2, start_from in integer );
procedure showerr(surl in varchar2, cusrec in customer_account%ROWTYPE, stype in integer, pfx in THEME%ROWTYPE, ltype in varchar2 );
function external_query_show( v_umo in integer, utype in varchar2, value in varchar2, edit_type in varchar2, lov_list in varchar2, sql_select_mask in varchar2, external_query in char ) return varchar2;
function fixnm( val in varchar2 ) return varchar2;

procedure reload_image( surl in varchar2, phg_id in integer, umorec in umo%ROWTYPE, file in varchar2, retval out varchar2 ) ;
procedure new_image( surl in varchar2, umorec in umo%ROWTYPE, cusrec in customer_account%ROWTYPE, file in varchar2, nmb out integer, uscid in integer, retval out varchar2 );
procedure copy_metadata( source_umo in integer, target_umo in integer );

function cust_button( pfx in THEME%ROWTYPE, gif in varchar2, element in integer default 1 )
 return varchar2
as
begin
 if nvl(substr(pfx.separate_customer_bt,1,1),'F') = 'F'
  then
   return( DECS.IMAGE_LOCATION || 'adminc/' || gif );
 end if;

 if nvl(substr(pfx.separate_customer_bt,element,1),'F') = 'F'
  then
   return( DECS.IMAGE_LOCATION || 'adminc/' || gif );
  else
   return( DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || gif );
 end if;
end cust_button;

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

procedure main_display(surl  varchar2, stype integer, ltype varchar2, umrec UMP.SEARCH_RESULT_PHG, cusrec CUSTOMER_ACCOUNT%ROWTYPE, pfx   THEME%ROWTYPE,
		       theme_rec  theme_types%ROWTYPE, footer_api varchar2, current_page_number  integer default 1, search_total    integer default 0,
		       display_detail  char default null, left_api   varchar2, left_api_parm   varchar2, cusloc varchar2, lbox  varchar2, acid  integer default null,
		       sessid integer, msg   varchar2 )
as

 cursor c3( sess_id integer ) is select count('x') tot from shopping_basket sb, purchase_order po where po.sessid=sess_id and po.poid = sb.poid;

 cursor c4( bftr varchar2, ctg varchar2 ) is
  select attribute_id
  from umo_attributes
  where sub_category like '%IMAGE%CAPTION%' and
        business_feature = 'LandcareResearch' and
        umo_type = 'PHOTO'
union all
  select attribute_id
  from umo_attributes
  where sub_category like '%IMAGE%CAPTION%' and
        umo_type = 'PHOTO';

cursor c5(v_umo integer, attribid integer) is select value from umo_attribute where umo_id = v_umo and attribute_id = attribid order by position_id;

  c3rec			c3%ROWTYPE;
  c4rec			c4%ROWTYPE;
  c5rec			c5%ROWTYPE;
  nmb			integer;
  ctr			integer;
  x			integer;
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
   open c4(cusrec.theme_type,cusrec.scene_name);
   fetch c4 into c4rec;
   close c4;
  txtclr := pfx.vert_colour_a;
  display_original := glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL');
  vhor_caption := glbx.userpref( cusrec.pid, cusrec.aid, 'TNAIL_PREF' );
  if umrec.count = 0
   then
    begin if substr(left_api_parm,1,1) = '[' then uscid := null; else uscid := left_api_parm; end if; exception when others then uscid := null; end;
   else
    begin if substr(left_api_parm,1,1) = '[' then uscid := umrec(umrec.first).umo_scene_id; else uscid := left_api_parm; end if; exception when others then uscid := umrec(umrec.first).umo_scene_id; end;
  end if;
  disp_src( surl, acid, cusrec, stype, pfx, left_api_parm, search_total, c3rec.tot, uscid, theme_rec, ltype, footer_api, current_page_number );
  initialise_control_buttons( surl, footer_api, left_api_parm, current_page_number, cusloc, null, acid );
  if umrec.count = 0
   then
    htp.p( NO_RESULTS );
    htp.nl;
    htp.nl;
    htp.p( '</BODY>' );
    return;
  end if;

  htp.tableopen( cattributes=>nvl(pfx.vertical_disp_table,'cellpadding="1" cellspacing="1" border="0" width="100%"') || ' bgcolor="#' || pfx.vert_colour_b || '"' );
  pg(stype,pfx.theme_name);
  htp.tablerowopen( cattributes=>'bgcolor="#' || txtclr || '" align="center"');
  ctr := 0;

  begin x := nvl(glbx.sctrl(pfx.theme_name,'DISPLAY_HORIZONTAL',stype),3); exception when others then x := 1; end;

  for j in umrec.first..umrec.last loop
   ctr := ctr + 1;
   if mod( (ctr-1), x ) = 0 and j > umrec.first then htp.tablerowclose; htp.tablerowopen( cattributes=>'bgcolor="#' || txtclr || '" align="center"'); end if;
   xt := null;
   if umrec(j).umo_type <> 'PHOTO' then xt := '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO'; end if;

   -- Display Thumbnail
   htp.p( '<TD ' || TEXT_HTML || ' bgcolor="#' || txtclr || '">' );
   hor_caption := replace(replace(vhor_caption,'~CAPTION',umrec(j).image_caption),'~NAME', fixnm(umrec(j).extras.photo_name));
   htp.nl;

   if ltype = 'PHOTOGRAPHER'
      then
      htp.anchor('phg.phg_modify?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&phgid=' || umrec(j).umo_id || '&footer_api=' || replace(footer_api,' ','+') ||
                  '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail ||
                  '&msg=' || null,
                  '<IMG BORDER=0 WIDTH=' || umrec(j).photo_thumbnail.width || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec(j).umo_id ||
                  '&parm1=AID&parm2=' || acid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype ||
                  '&parm1=VERSION&parm2=' || umrec(j).version || xt ||
                  '" ALT="' || hor_caption || '"' || 'STYLE="display:block;"' || '>' );
      else
       url := 'cst.disp_acct_photo?surl=' || glbx.rndsurl(surl) || '&photo_id=' || umrec(j).umo_id || '&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&extra_term=' || null;
       url := 'javascript: window.open(''' || url || ''',''' || replace(LNG5.EXT_TXT_301,' ','_') ||
              ''',''height=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) + pfx.fullimg_popup_height) ||
              ',width=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) + 100 + pfx.fullimg_popup_width) || ',scrollbars=yes,resizable=yes'');void('''');';
       if umrec(j).umo_type = 'DOCUMENT' then url := 'mydocument.embed_tag?surl=' || surl || '&v_umo=' || umrec(j).umo_id || '&acid=' || umrec(j).aid; end if;
      htp.anchor( url,
                  '<IMG BORDER=0 WIDTH=' || umrec(j).photo_thumbnail.width || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec(j).umo_id ||
                  '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype ||
                  '&parm1=VERSION&parm2=' || umrec(j).version || xt ||
                  '" ALT="' || hor_caption || '"' || 'STYLE="display:block;"' || '>' );
   end if;

   htp.nl;
   htp.p( '<font face="' || pfx.text_font || '" color="#' || pfx.text_colour || '" size="1">' || fixnm(umrec(j).extras.photo_name) || '</font>' );
   htp.nl;
   cst.small_buttons(surl, ltype, cusrec, umrec(j), pfx, theme_rec, voidrec, footer_api, left_api_parm, lbox, cusloc, null, current_page_number, acid, hor_but, null, display_original,stype,null );

   htp.p( substr(hor_but,1,length(hor_but)-4) );
   htp.nl;
   htp.nl;
   c5rec.value := null;
   open c5(umrec(j).umo_id, c4rec.attribute_id);
   fetch c5 into c5rec;
   close c5;
   if c5rec.value is not null
    then
     htp.p( '<font face="' || pfx.text_font || '" color="#' || pfx.text_colour || '" size="1">' || c5rec.value || '</font>' );
   end if;
   htp.nl; htp.p( '&nbsp;' );

   htp.p( '</TD>' );

  end loop;

  htp.tablerowclose;
  pg(stype,pfx.theme_name);
  htp.tableclose;

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

procedure main_image(surl in varchar2, acid in integer, v_umo in integer default null, footer_api in varchar2 default null, left_api_parm in varchar2 default null, current_page_number in integer default 1, uscid in integer default null, foundimg in char default 'F', retval in varchar2 default null, ro in char default 'R')
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;

 umorec			c1%ROWTYPE;
 cusrec			customer_account%ROWTYPE;
 pfx			THEME%ROWTYPE;
 ltype			varchar2(100);
 stype			integer;
 owner_id		integer;
 profid			integer;
 sts			varchar2(100);
 empty_array		GLBX.MYARRAY;
 dbool			boolean;
 theme_rec  		theme_types%ROWTYPE;
 purchord		purchase_order%ROWTYPE;
 voidrec 		order_style%ROWTYPE;
 hor_but		varchar2(4000);
 display_original	varchar2(100);
 lbox			varchar2(100);
 ctr			integer;
 correct_meta_data	boolean;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>PROGRAM_INITIAL || '.MAIN_IMAGE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 glbx.get_all_order_details(owner_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );


 if v_umo is null
  then
    open_page(surl, cusrec.aid, stype, pfx, ttl=>TEXT_028, cusrec=>cusrec, ltype=>ltype);
  else
    open c1(to_number(nvl(to_char(v_umo),left_api_parm)), cusrec.aid);
    fetch c1 into umorec;
    close c1;
    open_page(surl, cusrec.aid, stype, pfx, ttl=>fixnm(umorec.extras.photo_name), cusrec=>cusrec, ltype=>ltype);
 end if;

 correct_meta_data := TRUE;
 if left_api_parm <> 'META' and v_umo is null then correct_meta_data := FALSE; end if;

   htp.tableopen( cattributes=>'cellpadding=0 cellspacing=10 border=0' ); -- TD0

     htp.tablerowopen;
      if correct_meta_data and v_umo is not null and ro = 'R'
       then
        htp.tabledata( htf.anchor( 'lc.main_image?surl=' || surl || '&acid=' || acid || '&v_umo=' || v_umo || '&ro=W', TEXT_029 ));
      elsif correct_meta_data and v_umo is not null and ro = 'W'
       then
        htp.tabledata( htf.anchor( 'lc.main_image?surl=' || surl || '&acid=' || acid || '&v_umo=' || v_umo || '&ro=R', TEXT_030 ));
      end if;
      htp.p( '<TD valign="TOP" align="RIGHT" style="text-align: right;" colspan="2">' );
       htp.bold( '<a href="" onClick="self.close()">' || htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'close_return.gif', cattributes=>'BORDER=0', calt=>LNG.GLB_TXT_033 ) || '</a>');
       htp.nl;
      htp.p( '</TD>' );
     htp.tablerowclose;

    htp.tablerowopen;
     -- Column 1
     htp.p( '<TD valign="TOP" align="LEFT">' );
     htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 borer=0' );
     if retval is not null
      then
       htp.tablerowopen;
        htp.tabledata( htf.bold( retval ) );
       htp.tablerowclose;
     end if;
     if reterrors.count > 0
      then
       correct_meta_data := FALSE;
       htp.tablerowopen;
        htp.p( '<TD valign="TOP" align="LEFT" style="text-align: left;">' );
         htp.bold( 'Errors on Meta Data Modification' );
         htp.nl;
         htp.ulistopen;
         for j in reterrors.first..reterrors.last loop
          if instr( reterrors(j),']') > 0
           then
            htp.listitem( substr(reterrors(j), instr( reterrors(j),']')+1 ) );
           else
            htp.listitem( reterrors(j) );
          end if;
         end loop;
         htp.ulistclose;
        htp.p( '</TD>' );
       htp.tablerowclose;
     end if;

     -- Edit Meta Data
     delete from exception_report;
     htp.tablerowopen;
      htp.p( '<TD valign="TOP" align="LEFT" style="text-align: left;">' );
       if correct_meta_data and v_umo is not null and ro = 'R'
        then
         dbool := glbx.disp_mt( surl, ltype, umorec.umo_id, nvl(umorec.umo_type,'PHOTO'), substr(theme_rec.theme_data,167,1), pfx, acid, empty_array );
        else
         htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'lc.accept_meta_edit', cattributes=>'enctype="multipart/form-data"' );
         htp.formhidden( 'SURL', surl );
         htp.formhidden( 'V_UMO', umorec.umo_id );
         htp.formhidden( 'ACID', acid );
         htp.formhidden( 'USCID', uscid );
         htp.formhidden( 'RO', ro );
         htp.formhidden( 'TAG_ID', null );
         htp.formhidden( 'TAG_NAME', null );
         htp.formhidden( 'TAG_VALUE', null );
         dbool := glbx.img_meta_edit( umorec.umo_id, nvl(umorec.umo_type,'PHOTO'), pfx, TRUE, stype, acid, ltype, bftr=>theme_rec.theme_type );
       end if;
        htp.nl;
      htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tablerowopen;
    if correct_meta_data and v_umo is not null and ro = 'R'
     then
      null;
     else
      if umorec.is_global = 'T'
       then
         htp.tabledata( htf.formcheckbox( 'P3', 'T','CHECKED' ) || ' ' || htf.bold( TEXT_031 ));
       else
         htp.tabledata( htf.formcheckbox( 'P3', 'T' ) || ' ' || htf.bold(TEXT_032  ) );
      end if;
     end if;
     htp.tablerowclose;

     if v_umo is not null then
     -- Usage History
     htp.tablerowopen;
      htp.p( '<TD valign="TOP" align="LEFT" style="text-align: left;">' );
       htp.nl;
       htp.bold( TEXT_033 ); htp.nl;
       dbool := glbx.disp_link_history(umorec.umo_id, pfx.vertical_disp_table, htf.tabledata( '&nbsp;', cattributes=>pfx.ord_qbground) || htf.tabledata( htf.bold(TEXT_034), cattributes=>pfx.ord_qbground) || htf.tabledata( htf.bold( TEXT_035 ), cattributes=>pfx.ord_qbground), pfx.ord_qcbground, pfx.ord_qcbground, 'lc.main_image?surl=' || surl || '&acid=' || acid || '&ro=' || ro, 'V' );
      htp.p( '</TD>' );
     htp.tablerowclose;

     -- See Also
     htp.tablerowopen;
      htp.p( '<TD valign="TOP" align="LEFT" style="text-align: left;">' );
       htp.nl;
        htp.anchor('javascript: window.open(''' || 'lc.linkimage?surl=' || surl || '&acid=' || acid || '&v_umo=' || umorec.umo_id ||
              ''',''' || replace(LNG5.EXT_TXT_301 || 'XXXS',' ','_') ||
              ''',''height=800,width=800,scrollbars=yes,resizable=yes'');void('''');',
              'See Also' );
       htp.nl;
       dbool := glbx.disp_link_history(umorec.umo_id, pfx.vertical_disp_table, htf.tabledata( '&nbsp;', cattributes=>pfx.ord_qbground) || htf.tabledata( htf.bold(TEXT_034), cattributes=>pfx.ord_qbground) || htf.tabledata( htf.bold( TEXT_035 ), cattributes=>pfx.ord_qbground), pfx.ord_qcbground, pfx.ord_qcbground, 'lc.main_image?surl=' || surl || '&acid=' || acid || '&ro=' || ro, 'T' );
      htp.p( '</TD>' );
     htp.tablerowclose;
     end if;

     htp.tableclose;

     htp.p( '</TD>' );

     -- Column 2
     -- Display Main Image

     htp.p( '<TD valign="TOP" align="LEFT">' ); -- TD1

     htp.tableopen( cattributes=>'cellpadding=' || nvl(pfx.tnail_width,0) || ' cellspacing=0 border=0' ); -- TD1
      htp.tablerowopen;
      if v_umo is null
       then
         htp.tabledata( htf.nl );
       else
         htp.tabledata( '<IMG BORDER=0 WIDTH=' || HARD_CODED_PHOTO_WIDTH || ' SRC="' ||
                        'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id ||
                        '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=VERSION&parm2=' || umorec.version ||
                        '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || to_char(cusrec.aid) || '" ' ||
                        'ALT="' || fixnm(umorec.extras.photo_name) || '" ' || 'STYLE="display:block;"' || '>',
                          cattributes=>'align="CENTER" valign="TOP" bgcolor="#' || pfx.tnail_matte_colour || '" style="text-align: center;"' );
      end if;
      htp.tablerowclose;

      if correct_meta_data
      then
       if correct_meta_data and v_umo is not null and ro = 'R'
        then
         null;
        else
      htp.tablerowopen;
       htp.p( '<TD>' );
       htp.tableopen;

        if v_umo is null then
        htp.tablerowopen;
         htp.tabledata( htf.formradio( 'P1', 'N','CHECKED' ) );
         htp.tabledata( htf.bold( TEXT_028) );
        htp.tablerowclose;
        else
        htp.tablerowopen;
         htp.tabledata( htf.formradio( 'P1', 'R','CHECKED' ) );
         htp.tabledata( htf.bold( TEXT_040 ) );
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( htf.formradio( 'P1', 'M' ) );
         htp.tabledata( htf.bold( TEXT_041 ) );
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( htf.formradio( 'P1', 'A' ) );
         htp.tabledata( htf.bold( TEXT_042 ) );
        htp.tablerowclose;
        end if;
        htp.tablerowopen;
         htp.tabledata( '&nbsp;' );
         htp.tabledata( GLBX.UPLOAD_NAME );
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( '&nbsp;' );
         htp.tabledata( htf.bold( TEXT_035 ) || htf.nl || htf.formtextarea( 'P2', 4, 40 ) );
        htp.tablerowclose;
       htp.tableclose;
       htp.p( '</TD>' );
      htp.tablerowclose;
      end if;

      else
       htp.formhidden( 'P1', null );
       htp.formhidden( 'P2', null );
       htp.formhidden( 'FILE', null );
      end if;
      htp.tablerowopen;
       if correct_meta_data and v_umo is not null and ro = 'R'
        then
       htp.formclose;
        else
         if v_umo is null and correct_meta_data
          then
           htp.tabledata( htf.formsubmit( 'ACTION', TEXT_036 ) || htf.formclose );
         elsif v_umo is null
          then
           htp.tabledata( htf.formsubmit( 'ACTION', TEXT_037 ) );
          else
           htp.tabledata( htf.formsubmit( 'ACTION', TEXT_038 ) ||
                          htf.formsubmit( 'ACTION', TEXT_039 ) || htf.formclose );
         end if;
       end if;
      htp.tablerowclose;
     htp.tableclose; -- TD1

     htp.p( '</TD>' );

    htp.tablerowclose;
   htp.tableclose; -- TD0
   htp.nl;

   if v_umo is not null
   then
   -- Is Public
   if umorec.is_global = 'T'
    then
     htp.bold( TEXT_043 || ':' );
     htp.nl;
     htp.p( 'http://' || owa_util.get_cgi_env( 'SERVER_NAME' ) || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'ump.show_public_image?v_umo=' || umorec.umo_id );
    else
     htp.bold( TEXT_044 );
   end if;

   if umorec.image_caption is not null
    then
     htp.line;
     htp.nl;
     htp.bold( TEXT_045 || ' : ' );
     htp.p( umorec.image_caption );
   end if;

   htp.nl;
   htp.nl;
   htp.anchor('javascript: window.open(''' || 'lc.metatag?surl=' || surl || '&acid=' || acid || '&v_umo=' || umorec.umo_id || '&metaload=' || replace('EXIF',' ','+') ||
              ''',''' || replace(LNG5.EXT_TXT_301 || 'XXXD',' ','_') ||
              ''',''height=800,width=800,scrollbars=yes,resizable=yes'');void('''');',
              TEXT_046 );
   end if;

  close_page;
--        foundrec := glbx.update_meta_data( surl, nvl(new_id,v_umo), cusrec.aid, otype, ltype, tag_id, tag_name, tag_value, reterrors, reterrors_ctr);
exception
 when others then err_page( surl, sqlerrm );
end main_image;

procedure err_page( surl in varchar2, errm in varchar2 )
as
begin
 htp.htmlopen;
  htp.p( C_BACKIMG );
   glbx.error_details( PROGRAM_INITIAL, 'SKIN',errmsg=>errm);
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
 glbx.error_details( PROGRAM_INITIAL, 'EXTRACT_EMAIL',errmsg=>sqlerrm,extdet=>EM);
end extract_email;

procedure initialise_control_buttons( surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, cusloc in varchar2, dispvert in char, acid integer )
as
begin
 htp.formopen( 'cst.accept_display', ctarget=>cusloc );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'DISPLAY_DETAIL', null );
 htp.formhidden( 'P0', '0' );
 htp.formhidden( 'P1', '0' );
 htp.formhidden( 'PA', '0' );
 htp.formhidden( 'PB', '0' );
 htp.formhidden( 'PC', '0' );
 htp.formhidden( 'PPN', '0' );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
exception when others then
 glbx.error_details( PROGRAM_INITIAL, 'INITIALISE_CONTROL_BUTTONS',vaid=>acid,errmsg=>sqlerrm,extdet=>'LEFT_API_PARM:' || left_api_parm);
end initialise_control_buttons;

procedure disp_src( surl in varchar2, acid in integer, cusrec in customer_account%ROWTYPE, stype in integer, pfx in theme%ROWTYPE, left_api_parm in varchar2, search_total in integer, itext in varchar2, uscid in integer default null, theme_rec in theme_types%ROWTYPE, ltype in varchar2, footer_api in varchar2, start_from in integer )
as
 cursor c1(uscid integer) is select title from umo_scene where umo_scene_id = uscid;
 c1rec  c1%ROWTYPE;
 url	varchar2(4000);
begin
 htp.formclose;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=1 border=1' );
  htp.tablerowopen;
   if substr(left_api_parm,1,1) = '['
    then
     htp.tabledata( TEXT_047 || ' : ' || search_total, cattributes=>'VALIGN="CENTER" ALIGN="CENTER" style="text-align: center;"' );
    else
     open c1(left_api_parm);
     fetch c1 into c1rec;
     close c1;
     htp.tabledata( TEXT_048 || ' : ' || c1rec.title, cattributes=>'VALIGN="CENTER" ALIGN="CENTER" style="text-align: center;"' );
   end if;
   htp.p( '<TD VALIGN="CENTER" ALIGN="CENTER" style="text-align: center;">' );
   htp.formopen( 'cst.simple_search' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ACID', acid );
   htp.formhidden( 'P3', '0' );
   htp.formtext( 'P1', 30, 100, null);
   htp.formsubmit( null, LNG.GLB_TXT_092 );
   htp.p( '</TD>' );
   htp.tabledata( htf.anchor( 'cst.acct_search?surl=' || surl || '&acid=' || acid || '&search_call=META', htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'advsrc.gif', cattributes=>'BORDER=0', calt=>TEXT_049 ) ), cattributes=>'VALIGN="CENTER" ALIGN="CENTER" style="text-align: center;"' );
   htp.formclose;
       url := 'lc.main_image?surl=' || glbx.rndsurl(surl) || '&acid=' || acid  || '&v_umo=' || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&uscid=' || uscid || '&ro=' || 'R';
       url := 'javascript: window.open(''' || url || ''',''' || replace(LNG5.EXT_TXT_301,' ','_N') ||
              ''',''height=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) + pfx.fullimg_popup_height) ||
              ',width=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) + 100 + pfx.fullimg_popup_width) || ',scrollbars=yes,resizable=yes'');void('''');';
   if uscid is not null
    then
     htp.tabledata( htf.anchor( url, TEXT_050 ), cattributes=>'colspan="1"' );
    else
     htp.tabledata( '&nbsp;', cattributes=>'colspan="1"' );
   end if;

    if is_bf(theme_rec,ltype,393,null,'T','T',392,'T') and ltype in ('PHOTOGRAPHER','OWNER','PROFILE','VIRTUAL')
      then
          htp.tabledata(htf.anchor( 'cst.previous_orders' || '?surl=' || glbx.rndsurl(surl) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=T' || '&acid=' || acid,
                        TEXT_051));
    end if;

  htp.tablerowclose;
    if nvl(to_number(itext),0) = 0
     then
      htp.tablerowopen;
       htp.tabledata( glbx.userpref(cusrec.pid,cusrec.aid,'HELP_SEARCH'), cattributes=>'colspan="4"' );
      htp.tablerowclose;
     else
      htp.tablerowopen;
       htp.tabledata( TEXT_052 || ' : ' || itext, cattributes=>'colspan="2"' );
       htp.tabledata( nvl(glbx.userpref(cusrec.pid,cusrec.aid,'HELP_SEARCH'),'&nbsp;'), cattributes=>'colspan="2"' );
      htp.tablerowclose;
    end if;
  htp.tableclose;
end disp_src;

procedure showerr(surl in varchar2, cusrec in customer_account%ROWTYPE, stype in integer, pfx in THEME%ROWTYPE, ltype in varchar2 )
as
begin
    open_page(surl, cusrec.aid, stype, pfx, ttl=>TEXT_053, cusrec=>cusrec, ltype=>ltype);
    htp.p( glbx.userpref( cusrec.pid, cusrec.aid, 'HELP_SEARCH' ) );
    htp.nl;
    htp.nl;
    htp.bold( '<a href="" onClick="javascript:top.window.close()">' || htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'close_return.gif', cattributes=>'BORDER=0', calt=>LNG.GLB_TXT_033 ) || '</a>');
end showerr;

function external_query_show( v_umo in integer, utype in varchar2, value in varchar2, edit_type in varchar2, lov_list in varchar2, sql_select_mask in varchar2, external_query in char )
 return varchar2
as
begin
 if external_query = 'F'
  then
    return( value );
 end if;
 return( glbx.meta_sql_query( v_umo, utype, sql_select_mask ) );
end external_query_show;

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

procedure recurse_reset_ahead( v_umo integer, vl in varchar2, lktype char, infctr in integer default 50 )
as
  cursor c1( v_umo integer, lktype char ) is select * from umo_link where umo_id = v_umo and link_type = lktype;
 begin
  if infctr = 0 then return; end if;
  for c1rec in c1( v_umo, lktype ) loop
   update umo
    set
     is_global = vl
   where
    umo_id = c1rec.to_umo_id;
   recurse_reset_ahead(c1rec.to_umo_id, vl, lktype, infctr-1);
  end loop;
end recurse_reset_ahead;

procedure recurse_reset( v_umo integer, vl in varchar2, lktype char, infctr in integer default 50 )
as
  cursor c1( v_umo integer, lktype char ) is select * from umo_link where to_umo_id = v_umo and link_type = lktype;
 begin
  if infctr = 0 then return; end if;
  for c1rec in c1( v_umo, lktype ) loop
   update umo
    set
     is_global = vl
   where
    umo_id = c1rec.umo_id;
   recurse_reset(c1rec.umo_id, vl, lktype, infctr-1);
  end loop;
end recurse_reset;

procedure accept_meta_edit( surl in varchar2, v_umo in integer, acid in integer, tag_id in glbx.myarray, tag_name in glbx.myarray, tag_value in glbx.myarray, p1 in varchar2, p2 in varchar2, p3 in char default 'F', file in varchar2, uscid in integer, ro in char, action in varchar2 )
as

 cursor c2(acid integer, v_umo integer) is select * from umo where umo_id = v_umo and aid = acid;

 cusrec		customer_account%ROWTYPE;
 umorec		umo%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 res		boolean;
 sts		varchar2(100);
 retval		varchar2(1000);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 reterrors_ctr	integer;
 new_umo	integer;
 bl		boolean;
 vp3		char(1);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts , 'S', progcalled=>'LC.META_EDIT');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 -- Anonymous Accounts cannot edit meta data
 if not ltype in ('PHOTOGRAPHER','OWNER','PROFILE') then htp.bold( TEXT_061 ); return; end if;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );

 open c2(cusrec.aid, v_umo );
 fetch c2 into umorec;
 close c2;

 if action = TEXT_039
  then
   bl := glbx.delete_link( umorec.umo_id );
   delete from log_photo_mod where phid = umorec.umo_id;
   delete from log_umo_utility_modification where umo_id = umorec.umo_id;
   delete from umo_index where umo_id = umorec.umo_id;
   delete from umo_attribute where umo_id = umorec.umo_id;
   delete from umo where umo_id = umorec.umo_id;
   htp.htmlopen;
    htp.bold( '<a href="" onClick="self.close()">' || htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'close_return.gif', cattributes=>'BORDER=0', calt=>LNG.GLB_TXT_033 ) || '</a>');
     htp.nl;
     htp.nl;
      htp.bold( TEXT_054 );
     htp.nl;
     htp.nl;
    htp.bold( '<a href="" onClick="self.close()">' || htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'close_return.gif', cattributes=>'BORDER=0', calt=>LNG.GLB_TXT_033 ) || '</a>');
   htp.htmlclose;
   commit;
   return;
 end if;

 if p1 = 'R' -- Reload
  then
   new_umo := v_umo;
   reload_image( surl, v_umo, umorec, file, retval );
   if retval is not null
    then
     main_image(surl, acid, nvl(new_umo,v_umo), uscid=>uscid, retval=>retval, left_api_parm=>'META', ro=>ro );
     return;
   end if;

 elsif p1 = 'M'-- Attach as master
  then
   new_image( surl, umorec, cusrec, file, new_umo, uscid, retval );
   if new_umo is null or retval is not null
    then
     main_image(surl, acid, nvl(new_umo,v_umo), uscid=>uscid, retval=>retval, left_api_parm=>'META', ro=>ro );
     return;
   end if;
   copy_metadata(v_umo, new_umo);
   bl := glbx.add_link( v_umo, new_umo, p2, 'T', 'V' );

 elsif p1 = 'A' -- Attached but not as master
  then
   new_image( surl, umorec, cusrec, file, new_umo, uscid, retval );
   if new_umo is null or retval is not null
    then
     main_image(surl, acid, nvl(new_umo,v_umo), uscid=>uscid, retval=>retval, left_api_parm=>'META', ro=>ro );
     return;
   end if;
   copy_metadata(v_umo, new_umo);
   bl := glbx.add_link( v_umo, new_umo, p2, 'F', 'V' );

 elsif p1 = 'N' --   'Insert New Image'
  then
   umorec.umo_type := 'PHOTO';
   new_image( surl, umorec, cusrec, file, new_umo, uscid, retval );
   if new_umo is null or retval is not null
    then
     main_image(surl, acid, nvl(new_umo,v_umo), uscid=>uscid, retval=>retval, left_api_parm=>'META', ro=>ro );
     return;
   end if;

 elsif p1 is null
  then
   umorec.umo_type := 'PHOTO';
   new_umo := null;

 end if;


 res := glbx.update_meta_data( surl, new_umo, cusrec.aid, umorec.umo_type, ltype, tag_id, tag_name, tag_value, reterrors, reterrors_ctr);

 vp3 := p3;
 if p1 = 'M' then vp3 := 'T'; end if;
 if nvl(umorec.is_global,'F') = 'T' and vp3 = 'T'
  then
   null;
 elsif nvl(umorec.is_global,'F') = 'F' and vp3 = 'F'
  then
   null;
 elsif nvl(umorec.is_global,'F') = 'F' and vp3 = 'T'
  then
   recurse_reset_ahead( new_umo, 'F', 'V' );
   recurse_reset( new_umo, 'F', 'V' );
 elsif nvl(umorec.is_global,'F') = 'T' and vp3 = 'F'
  then
   recurse_reset_ahead( new_umo, 'F', 'V' );
   recurse_reset( new_umo, 'F', 'V' );
 end if;

 update umo um
  set
   is_global = p3
  where
   umo_id = new_umo;

 if reterrors_ctr > 0
  then
   -- Mark Image as Non Public
   update umo um
    set
     is_global = 'F'
   where
    umo_id = new_umo;
 end if;

 commit;

 if new_umo is null
  then
   delete from exception_report;
   for j in tag_id.first..tag_id.last loop
    insert into exception_report(id,txt) values (tag_id(j),tag_value(j));
   end loop;
 end if;

 main_image(surl, acid, nvl(new_umo,v_umo), uscid=>uscid, left_api_parm=>'META',ro=>ro);
 delete from exception_report;
 commit;

exception when others then
 glbx.error_details( 'LC', 'ACCEPT_META_EDIT',vaid=>acid,errmsg=>sqlerrm,extdet=>'V_UMO:' || v_umo);
end accept_meta_edit;

procedure reload_image( surl in varchar2, phg_id in integer, umorec in umo%ROWTYPE, file in varchar2, retval out varchar2 )
as
 parm1		ump.parameters;
 parm2		ump.parameters;
 newid_arr	ump.myarray_int;
begin
  parm1(1) := 'UMO_ID';
  parm2(1) := to_char(umorec.umo_id);
  parm1(2) := 'AID';
  parm2(2) := to_char(umorec.aid);
  parm1(3) := 'OBJECT_TYPE';
  parm2(3) := umorec.umo_type;
  parm1(4) := 'KEEP_STATUS';
  parm2(4) := 'LOAD AGAIN';
  parm1(5) := 'OWS_NAME';
  parm2(5) := file;
  parm1(6) := 'LOAD_FROM_FILE_OR_UPLOAD';
  parm2(6) := 'UPLOAD';
  parm1(7) := 'ORIGINAL_LOCATION';
  parm2(7) := file;
  parm1(8) := 'BYPASS_QUOTA_CHECK';
  parm2(8) := 'FALSE';
  parm1(9) := 'CREATE_THUMBNAIL';
  parm2(9) := 'TRUE';
  parm1(10) := 'THUMBNAIL_WIDTH';
  parm2(10) := nvl(glbx.photo_pref(phg_id,umorec.aid,'THUMBNAIL_WIDTH'),'100');
  parm1(11) := 'THUMBNAIL_QUALITY';
  parm2(11) := nvl(glbx.photo_pref(phg_id,umorec.aid,'SUPER_THB'),'1');
  parm1(12) := 'PHGR_ID';
  parm2(12) := to_char(phg_id);
  parm1(13) := 'STORE_ORIGINAL';
  parm2(13) := 'FALSE';
  parm1(14) := 'RELOAD_PHOTO';
  parm2(14) := 'T';
  parm1(15) := 'SCENE_ID';
  parm2(15) := umorec.umo_scene_id;
  ump.load_uma(surl, parm1, parm2, retval, newid_arr );
end reload_image;

procedure new_image( surl in varchar2, umorec in umo%ROWTYPE, cusrec in customer_account%ROWTYPE, file in varchar2, nmb out integer, uscid in integer, retval out varchar2 )
as
 parm1		ump.parameters;
 parm2		ump.parameters;
 newid_arr	ump.myarray_int;
begin
  parm1(1)  := 'AID';
  parm2(1)  := to_char(cusrec.aid);
  parm1(2)  := 'OBJECT_TYPE';
  parm2(2)  := 'PHOTO';
  parm1(3)  := 'LOAD_FROM_FILE_OR_UPLOAD';
  parm2(3)  := 'UPLOAD';
  parm1(4)  := 'FILE_NAME';
  parm2(4)  := file;
  parm1(5)  := 'STORE_ORIGINAL';
  parm2(5)  := 'TRUE';
  parm1(6)  := 'CREATE_THUMBNAIL';
  parm2(6)  := 'TRUE';
  parm1(7) := 'KEEP_STATUS';
  parm2(7) := 'KEEP';
  parm1(8) := 'ORIGINAL_LOCATION';
  parm2(8) := file;
  parm1(9) := 'PARENT_UMO_ID';
  parm2(9) := NULL;
  parm1(10) := 'SCENE_ID';
  parm2(10) := nvl(umorec.umo_scene_id,uscid);
  parm1(11) := 'UMO_OWNER';
  parm2(11) := 'PHOTOGRAPHER';
  parm1(12) := 'BYPASS_QUOTA_CHECK';
  parm2(12) := 'FALSE';
  parm1(13) := 'PHGR_ID';
  parm2(13) := cusrec.pid;
  parm1(14) := 'OWS_NAME';
  parm2(14) := file;
  parm1(15) := 'ROLL_ID';
  parm2(15) := umorec.extra_roll_id;
  parm1(16) := 'FILM_SIZE';
  parm2(16) := 'IMAGE';
  parm1(17) := 'FILM_TYPE';
  parm2(17) := umorec.extra_film_colour;
  parm1(18) := 'FILM_NAME';
  parm2(18) := glbx.extract_fname(file,'NO_EXTENSION',100);
  parm1(19) := 'THUMBNAIL_WIDTH';
  parm2(19) := nvl(glbx.photo_pref(cusrec.pid,cusrec.aid,'THUMBNAIL_WIDTH'),'100');
  parm1(20) := 'PHOTOGRAPHER';
  parm2(20) := 'TRUE';
  parm1(21) := 'NAME';
  parm2(21) := glbx.extract_fname(file,'NO_EXTENSION',100);
  parm1(22) := 'PHOTO ALBUM';
  parm2(22) := 'FALSE';
  parm1(23) := 'BRIDAL';
  parm2(23) := 'TRUE';
  parm1(24) := 'QUALITY';
  parm2(24) := 'STANDARD';
  parm1(25) := 'COMPRESSION';
  parm2(25) := LNG.PHG_ALT_427;
  parm1(26) := 'CONVERT_TO';
  parm2(26) := 'JPEG';
  parm1(27) := 'THUMBNAIL_QUALITY';
  parm2(27) := nvl(glbx.photo_pref(cusrec.pid,cusrec.aid,'SUPER_THB'),'1');
  parm1(28) := 'BYPASS_QUOTA_CHECK';
  parm2(28) := 'TRUE';
  parm1(29) := 'NEG_NO';
  parm2(29) := '1';
  retval := NULL;

  ump.load_uma(surl,parm1,parm2,retval,newid_arr );
  begin nmb := newid_arr(newid_arr.first); exception when others then nmb := null; end;
end new_image;

procedure copy_metadata( source_umo in integer, target_umo in integer )
as
begin

 delete from umo_attribute where umo_id = target_umo;

 delete from umo_index where umo_id = target_umo;

 insert into umo_attribute(umo_id,attribute_id,position_id,date_made,value)
  select target_umo,attribute_id,position_id,sysdate,value
  from umo_attribute
  where umo_id = source_umo;

 insert into umo_index(umo_id,aid,attribute_id,position_id,word_original,word_upper,word_soundex,ordering)
  select target_umo,aid,attribute_id,position_id,word_original,word_upper,word_soundex,ordering
  from umo_index
  where umo_id = source_umo;

end copy_metadata;

procedure metatag( surl in varchar2, acid in integer, v_umo in integer, metaload in varchar2 )
as

 cursor c1(acid integer, v_umo integer) is select umo_id from umo um where umo_id = v_umo and aid = acid;

 c1rec			c1%ROWTYPE;
 cusrec			customer_account%ROWTYPE;
 pfx			THEME%ROWTYPE;
 ltype			varchar2(100);
 stype			integer;
 owner_id		integer;
 profid			integer;
 sts			varchar2(100);
 theme_rec  		theme_types%ROWTYPE;
 purchord		purchase_order%ROWTYPE;
 voidrec 		order_style%ROWTYPE;
 res 			boolean;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'LC.METATAG' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 glbx.get_all_order_details(owner_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
 open_page(surl, cusrec.aid, stype, pfx, ttl=>TEXT_055, cusrec=>cusrec, ltype=>ltype);
 open c1(cusrec.aid, v_umo);
 fetch c1 into c1rec;
 close c1;
 if c1rec.umo_id is null then return; end if;
 res := mload.load_one_image( surl, owner_id, metaload, acid, v_umo, printoutput=>TRUE );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LC', 'METATAG', vaid=>acid, errmsg=>sqlerrm);
end metatag;

procedure linkimage(surl in varchar2, acid in integer, v_umo in integer, msg in varchar2 default null )
as

 cursor c2(acid integer, v_umo integer) is select * from umo where umo_id = v_umo and aid = acid;

 cusrec		customer_account%ROWTYPE;
 umorec		umo%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 res		boolean;
 sts		varchar2(100);
 retval		varchar2(1000);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts , 'S', progcalled=>'LC.LINKIMAGE');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 -- Anonymous Accounts cannot edit meta data
 if not ltype in ('PHOTOGRAPHER','OWNER','PROFILE') then htp.bold( TEXT_061 ); return; end if;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );

 open c2(cusrec.aid, v_umo );
 fetch c2 into umorec;
 close c2;

 open_page(surl, cusrec.aid, stype, pfx, ttl=>TEXT_057, cusrec=>cusrec, ltype=>ltype);
 if msg is null
  then
   htp.bold( TEXT_056 );
   htp.nl;
  else
   glbx.header_msg( msg );
 end if;
 htp.nl;
 htp.formopen( 'lc.accept_linkimage' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );
  htp.formhidden( 'V_UMO', v_umo );
  htp.bold( TEXT_058 );
  htp.nl;
  htp.formtext( 'P1', 20, 100 );
  htp.formsubmit( null, TEXT_059 );
 htp.formclose;
 close_page;
exception
 when others then err_page( surl, sqlerrm );
end linkimage;

procedure accept_linkimage(surl in varchar2, acid in integer, v_umo in integer, p1 in varchar2 )
as

 cursor c2(acid integer, v_umo integer) is select * from umo where umo_id = v_umo and aid = acid;
 cursor c3(acid integer, kw varchar2, v_umo integer) is select u.* from umo u, umo_index ui where u.umo_id = ui.umo_id and ui.aid = acid and word_upper like kw and ui.umo_id <> v_umo;

 cusrec		customer_account%ROWTYPE;
 umorec		umo%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 res		boolean;
 sts		varchar2(100);
 retval		varchar2(1000);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 kw		varchar2(4000);
 foundrec	boolean;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts , 'S', progcalled=>'LC.ACCEPT_LINKIMAGE');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if p1 is null then linkimage(surl,acid,v_umo,TEXT_060 ); return; end if;

 -- Anonymous Accounts cannot edit meta data
 if not ltype in ('PHOTOGRAPHER','OWNER','PROFILE') then htp.bold( TEXT_061 ); return; end if;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );

 open c2(cusrec.aid, v_umo );
 fetch c2 into umorec;
 close c2;

 if instr(trim(p1),' ') > 0
  then
   kw := substr(upper(trim(p1)),1,instr(trim(p1),' ')-1);
  else
   kw := upper(trim(p1));
 end if;
 open_page(surl, cusrec.aid, stype, pfx, ttl=>TEXT_062, cusrec=>cusrec, ltype=>ltype);
 htp.nl;
 htp.bold( TEXT_063 );
 htp.nl;
 htp.nl;
 htp.formopen( 'lc.accept_linkimage_transfer' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );
  htp.formhidden( 'V_UMO', v_umo );
  htp.formhidden( 'P1', null );
  htp.formhidden( 'P2', null );
  htp.formhidden( 'P3', null );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 foundrec := FALSE;
 for c3rec in c3(cusrec.aid,kw,v_umo) loop
  foundrec := TRUE;
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P3', c3rec.umo_id ) );
   htp.tabledata( c3rec.extras.film_name );
   htp.tabledata( htf.formhidden( 'P1',c3rec.umo_id) || htf.formtext( 'P2', 30, 4000 ) );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 if not foundrec
  then
   htp.nl;
   htp.bold( TEXT_064 );
   htp.formclose;
  else
   htp.nl;
   htp.formsubmit(null, TEXT_065 );
   htp.formclose;
 end if;
 htp.nl;
 htp.nl;
 htp.anchor( 'lc.linkimage?surl=' || surl || '&acid=' || acid || '&v_umo=' || v_umo, TEXT_066 );
 htp.nl;
 close_page;
exception
 when others then err_page( surl, sqlerrm );
end accept_linkimage;

procedure accept_linkimage_transfer(surl in varchar2, acid in integer, v_umo in integer, p1 in glbx.myarray, p2 in glbx.myarray, p3 in glbx.myarray )
as

 cursor c2(acid integer, v_umo integer) is select * from umo where umo_id = v_umo and aid = acid;
 cursor c3(acid integer, v_umo integer, vt integer) is select 'x' exst from umo_link where umo_id = v_umo and to_umo_id = vt and link_type = 'T';

 cusrec		customer_account%ROWTYPE;
 umorec		umo%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 res		boolean;
 bl		boolean;
 sts		varchar2(100);
 retval		varchar2(1000);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 kw		varchar2(4000);
 foundrec	boolean;
 annote		varchar2(4000);

function findimage( nmb in integer )
 return varchar2
is
begin
 for j in p1.first..p1.last loop
  if p1(j) = nmb
   then
    return( p2(j) );
  end if;
 end loop;
 return( null );
end findimage;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts , 'S', progcalled=>'LC.ACCEPT_LINKIMAGE_TRANSFER');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 -- Anonymous Accounts cannot edit meta data
 if not ltype in ('PHOTOGRAPHER','OWNER','PROFILE') then htp.bold( TEXT_061 ); return; end if;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );

 open_page(surl, cusrec.aid, stype, pfx, ttl=>'Link Completed', cusrec=>cusrec, ltype=>ltype);
 htp.tableopen;
 for j in p3.first..p3.last loop
  if p3(j) is not null
   then
    htp.tablerowopen;
    c3rec.exst := null;
    open c3(cusrec.aid, v_umo, p3(j) );
    fetch c3 into c3rec;
    close c3;
    open c2(cusrec.aid, v_umo );
    fetch c2 into umorec;
    close c2;
    htp.tabledata( htf.bold( umorec.extras.film_name ) );

    if c3rec.exst = 'x'
     then
      htp.tabledata( TEXT_067 );
     else
      annote := findimage( p3(j) );
      bl := glbx.add_link( v_umo, p3(j), annote, 'F', 'T' );
      commit;
      htp.tabledata( TEXT_068 );
    end if;
    htp.tablerowclose;
  end if;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.anchor( 'lc.linkimage?surl=' || surl || '&acid=' || acid || '&v_umo=' || v_umo, TEXT_066 );
 htp.nl;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'close_return.gif', cattributes=>'BORDER=0', calt=>LNG.GLB_TXT_033 ) || '</a>');
 htp.nl;
 close_page;
exception
 when others then err_page( surl, sqlerrm );
end accept_linkimage_transfer;

end lc;

/
