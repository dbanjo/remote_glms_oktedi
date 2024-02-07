CREATE OR REPLACE package body WEBSYS.sld
as

function lov_refresh( surl varchar2,id in varchar2, default_timing in varchar2 ) return varchar2;
function is_owner( surl varchar2,ltype in varchar2, owner_id in integer, acid in integer ) return boolean;
function is_bf( theme_rec in theme_types%ROWTYPE, ltype in varchar2, nmb1 in integer, nmb2 in integer, exp1 in char, exp2 in char, nmb3 in integer default null, exp3 in char default null ) return boolean;
function cust_button( pfx in THEME%ROWTYPE, gif in varchar2, element in integer default 1 ) return varchar2;

procedure slide_modify(surl varchar2,acid in integer, slid in integer, typ in integer, snmbr in integer, sldtype in varchar2, ltype in varchar2, pfx in THEME%ROWTYPE);
procedure table_photo(surl varchar2, acid in integer, slid in integer, typ in integer, snmbr in integer, photo_id in integer, fsize in integer, id in varchar2, ltype in varchar2, qcbground in varchar2);
procedure disp_table_photo( surl varchar2, pfx in THEME%ROWTYPE, c1rec in SLIDE_MASTER%ROWTYPE, c2rec in SLIDE_DETAILS%ROWTYPE, photo_id in integer, shrink in integer default 1, ltype in varchar2, stype in integer,theme_rec in theme_types%ROWTYPE, qcbground in varchar2 );

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

procedure edit_slideshow_master(surl varchar2, acid in integer, slid in integer)
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'SLD.EDIT_SLIDESHOW_MASTER', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
  htp.htmlopen;
  htp.framesetopen(glbx.sctrl(glbx.fndtheme( owner_id, acid ),'PHG_SLIDESHOW',stype),'100%',cattributes=>'frameborder="1" framespacing="0" border="1"');
   htp.frame( 'sld.slide_main?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid,'SLIDE_TOP');
   htp.frame( 'sld.controller?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid,'SLIDE_BOTTOM');
  htp.framesetclose;
  htp.p( '<BODY>' );
  htp.noframesopen;
   glbx.noframe(surl,'SLD.EDIT_SLIDESHOW_MASTER');
  htp.noframesclose;
  htp.p( '</BODY>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'SLD', 'PHG_MASTER',errmsg=>sqlerrm);
end edit_slideshow_master;

procedure slide_main( surl varchar2,acid in integer, slid in integer, msg in varchar2 default null )
as
 cursor c1(slid integer, acid integer) is select * from slide_master where sid=slid and aid=acid;
 cursor c2(slid integer) is select * from slide_details where sid=slid order by slide_nmbr;
 c1rec	c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		varchar2(4000);
 ctr		integer;
begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.SLIDE_MAIN', iscust=>FALSE );
 if (sts is not null) or not(is_owner(surl, ltype,owner_id,acid))
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1(slid,acid);
 fetch c1 into c1rec;
 close c1;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.SLD_TXT_002 || ' : ' || c1rec.slideshow_name,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'S01',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 if msg is not null
  then
   glbx.header_msg( msg );
  else
   glbx.header_msg( LNG.SLD_TXT_003 );
 end if;
 htp.tableopen( cattributes=>' border="0"');
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.SLD_TXT_004 ), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG.SLD_TXT_005 ), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG.PHG_TXT_345 ), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG.SLD_TXT_007 ), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;
  ctr := 0;

  for c2rec in c2(slid) loop

    tmp := htf.anchor2( 'sld.insert_bslide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=1&snmbr=' || c2rec.slide_nmbr,htf.img( DECS.IMAGE_LOCATION || 'admin/ss_1.gif',cattributes=>'width="22" border=0',calt=>LNG.SLD_ALT_056 ),ctarget=>'SLIDE_TOP' );
    tmp := tmp || htf.anchor2( 'sld.insert_bslide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=2&snmbr=' || c2rec.slide_nmbr,htf.img( DECS.IMAGE_LOCATION || 'admin/ss_2.gif',cattributes=>'width="22" border=0',calt=>LNG.SLD_ALT_057 ),ctarget=>'SLIDE_TOP' );
    tmp := tmp || htf.anchor2( 'sld.insert_bslide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=3&snmbr=' || c2rec.slide_nmbr,htf.img( DECS.IMAGE_LOCATION || 'admin/ss_3.gif',cattributes=>'width="22" border=0',calt=>LNG.SLD_ALT_058 ),ctarget=>'SLIDE_TOP' );
    tmp := tmp || htf.anchor2( 'sld.insert_bslide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=4&snmbr=' || c2rec.slide_nmbr,htf.img( DECS.IMAGE_LOCATION || 'admin/ss_4.gif',cattributes=>'width="22" border=0',calt=>LNG.SLD_ALT_059 ),ctarget=>'SLIDE_TOP' );
    tmp := tmp || htf.anchor2( 'sld.insert_bslide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=5&snmbr=' || c2rec.slide_nmbr,htf.img( DECS.IMAGE_LOCATION || 'admin/ss_5.gif',cattributes=>'width="22" border=0',calt=>LNG.SLD_ALT_060 ),ctarget=>'SLIDE_TOP' ) || htf.nl;
    tmp := tmp || htf.anchor2( 'sld.insert_bslide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=6&snmbr=' || c2rec.slide_nmbr,htf.img( DECS.IMAGE_LOCATION || 'admin/ss_6.gif',cattributes=>'width="22" border=0',calt=>LNG.SLD_ALT_061 ),ctarget=>'SLIDE_TOP' );
    tmp := tmp || htf.anchor2( 'sld.insert_bslide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=7&snmbr=' || c2rec.slide_nmbr,htf.img( DECS.IMAGE_LOCATION || 'admin/ss_7.gif',cattributes=>'width="22" border=0',calt=>LNG.SLD_ALT_062 ),ctarget=>'SLIDE_TOP' );
    tmp := tmp || htf.anchor2( 'sld.insert_bslide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=8&snmbr=' || c2rec.slide_nmbr,htf.img( DECS.IMAGE_LOCATION || 'admin/ss_8.gif',cattributes=>'width="22" border=0',calt=>LNG.SLD_ALT_063 ),ctarget=>'SLIDE_TOP' );
    tmp := tmp || htf.anchor2( 'sld.insert_bslide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=9&snmbr=' || c2rec.slide_nmbr,htf.img( DECS.IMAGE_LOCATION || 'admin/ss_9.gif',cattributes=>'width="22" border=0',calt=>LNG.SLD_ALT_064 ),ctarget=>'SLIDE_TOP' );
    tmp := tmp || htf.anchor2( 'sld.insert_bslide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=0&snmbr=' || c2rec.slide_nmbr,htf.img( DECS.IMAGE_LOCATION || 'admin/ss_0.gif',cattributes=>'width="22" border=0',calt=>LNG.SLD_ALT_065 ),ctarget=>'SLIDE_TOP' );

  htp.tablerowopen;
   htp.tabledata( htf.anchor( 'sld.del_slide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&snmbr=' || c2rec.slide_nmbr, LNG.SLD_TXT_008), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( htf.anchor( 'sld.update_slide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&snmbr=' || c2rec.slide_nmbr || '&typ=' || c2rec.slide_type,htf.img( DECS.IMAGE_LOCATION || 'admin/ss_' || c2rec.slide_type || '.gif',cattributes=>'border=0',calt=>LNG.SLD_ALT_066 ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( htf.anchor( 'sld.update_slide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&snmbr=' || c2rec.slide_nmbr || '&typ=' || c2rec.slide_type, nvl(c2rec.slide_title,'&nbsp;') ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( tmp, cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   ctr := ctr + 1;
  htp.tablerowclose;
  end loop;

 htp.tableclose;
 if ctr = 0
  then
   htp.nl;
   htp.nl;
   htp.bold( LNG.SLD_TXT_009 );
   htp.nl;
   htp.nl;
   htp.nl;
   htp.nl;
   htp.italic( htf.bold(LNG.SLD_TXT_010) );
   htp.formopen( 'SLD.DELETE_SLIDESHOW',ctarget=>'PHG_RIGHT' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ACID', acid );
   htp.formhidden( 'SLID', slid );
   htp.formsubmit( null, LNG.SLD_TXT_011 );
   htp.formclose;
   htp.nl;
 end if;
 htp.nl;
 htp.formopen( 'sld.run_slideshow',ctarget=>'PHG_RIGHT'  );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'SLID', slid );
 htp.formsubmit( null, LNG.SLD_TXT_012 );
 htp.formclose;
 htp.nl;
   htp.nl;
   htp.italic( htf.bold(LNG.SLD_TXT_010) );
   htp.formopen( 'SLD.DELETE_SLIDESHOW',ctarget=>'PHG_RIGHT' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ACID', acid );
   htp.formhidden( 'SLID', slid );
   htp.formsubmit( null, LNG.SLD_TXT_011 );
   htp.formclose;
   htp.nl;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'SLD', 'SLIDE_MAIN',errmsg=>sqlerrm,extdet=>'SLID:' || slid);
end slide_main;

procedure delete_slideshow( surl varchar2, acid in integer, slid in integer )
as
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 --pfx		varchar2(4);
 tmp		varchar2(4000);
 ctr		integer;
begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.DELETE_SLIDESHOW', iscust=>FALSE );
 if (sts is not null) or not(is_owner(surl, ltype,owner_id,acid))
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 --pfx := glbx.get_pfx( acid );
 delete from slide_details where sid=slid and sid = (select sid from slide_master where aid=acid and sid=slid);
 delete from slide_master where aid=acid and sid=slid;
 new_slide( surl, acid, LNG.SLD_TXT_013 );
exception when others then
 glbx.error_details( 'SLD', 'DELETE_SLIDESHOW',errmsg=>sqlerrm,extdet=>'SLID:' || slid);
end delete_slideshow;

procedure update_slide(surl varchar2,acid in integer, slid in integer, snmbr in integer, typ in integer, msg in varchar2 default null)
as
 cursor c1(slid integer, acid integer) is select * from slide_master where sid=slid and aid=acid;
 c1rec	c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 tmp		varchar2(4000);
 pfx		THEME%ROWTYPE;
begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.UPDATE_SLIDE', iscust=>FALSE );
 if (sts is not null) or not(is_owner(surl, ltype,owner_id,acid))
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1(slid,acid);
 fetch c1 into c1rec;
 close c1;
 pfx := glbx.get_thm( acid );
 htp.htmlopen;
 glbx.main_title( surl, nvl(msg,LNG.SLD_TXT_014) || snmbr,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'S02',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 slide_modify( surl, acid, slid, typ, snmbr, 'UPD', ltype, pfx );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'SLD', 'UPDATE_SLIDE',vaid=>acid,errmsg=>sqlerrm,extdet=>'SLID:' || slid || ' SNMBR:' || snmbr);
end update_slide;

procedure controller( surl varchar2,acid in integer, slid in integer )
as
 cursor c1(slid integer, acid integer) is select * from slide_master where sid=slid and aid=acid;
 c1rec	c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		varchar2(4000);
begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.CONTROLLER', iscust=>FALSE );
 if (sts is not null) or not(is_owner(surl, ltype,owner_id,acid))
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 open c1(slid,acid);
 fetch c1 into c1rec;
 close c1;
 glbx.main_title( surl, NULL,glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.tableopen;
  htp.tablerowopen;
   tmp := htf.anchor2( 'sld.edit_slideshow_details?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid,htf.img( DECS.IMAGE_LOCATION || 'admin/details.gif',cattributes=>'border=0',calt=>LNG.SLD_TXT_015 ),ctarget=>'SLIDE_TOP' );
   htp.tabledata( tmp );
   htp.tabledata( htf.bold(LNG.SLD_TXT_085) );
   tmp := htf.anchor2( 'sld.insert_slide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=1',htf.img( DECS.IMAGE_LOCATION || 'admin/ss_1.gif',cattributes=>'border=0',calt=>LNG.SLD_ALT_056 ),ctarget=>'SLIDE_TOP' );
   tmp := tmp || htf.anchor2( 'sld.insert_slide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=2',htf.img( DECS.IMAGE_LOCATION || 'admin/ss_2.gif',cattributes=>'border=0',calt=>LNG.SLD_ALT_057 ),ctarget=>'SLIDE_TOP' );
   tmp := tmp || htf.anchor2( 'sld.insert_slide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=3',htf.img( DECS.IMAGE_LOCATION || 'admin/ss_3.gif',cattributes=>'border=0',calt=>LNG.SLD_ALT_058 ),ctarget=>'SLIDE_TOP' );
   tmp := tmp || htf.anchor2( 'sld.insert_slide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=4',htf.img( DECS.IMAGE_LOCATION || 'admin/ss_4.gif',cattributes=>'border=0',calt=>LNG.SLD_ALT_059 ),ctarget=>'SLIDE_TOP' );
   tmp := tmp || htf.anchor2( 'sld.insert_slide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=5',htf.img( DECS.IMAGE_LOCATION || 'admin/ss_5.gif',cattributes=>'border=0',calt=>LNG.SLD_ALT_060 ),ctarget=>'SLIDE_TOP' );
   tmp := tmp || htf.anchor2( 'sld.insert_slide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=6',htf.img( DECS.IMAGE_LOCATION || 'admin/ss_6.gif',cattributes=>'border=0',calt=>LNG.SLD_ALT_061 ),ctarget=>'SLIDE_TOP' );
   tmp := tmp || htf.anchor2( 'sld.insert_slide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=7',htf.img( DECS.IMAGE_LOCATION || 'admin/ss_7.gif',cattributes=>'border=0',calt=>LNG.SLD_ALT_062 ),ctarget=>'SLIDE_TOP' );
   tmp := tmp || htf.anchor2( 'sld.insert_slide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=8',htf.img( DECS.IMAGE_LOCATION || 'admin/ss_8.gif',cattributes=>'border=0',calt=>LNG.SLD_ALT_063 ),ctarget=>'SLIDE_TOP' );
   tmp := tmp || htf.anchor2( 'sld.insert_slide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=9',htf.img( DECS.IMAGE_LOCATION || 'admin/ss_9.gif',cattributes=>'border=0',calt=>LNG.SLD_ALT_064 ),ctarget=>'SLIDE_TOP' );
   tmp := tmp || htf.anchor2( 'sld.insert_slide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&typ=0',htf.img( DECS.IMAGE_LOCATION || 'admin/ss_0.gif',cattributes=>'border=0',calt=>LNG.SLD_ALT_065 ),ctarget=>'SLIDE_TOP' );
   htp.tabledata( tmp );
  htp.tablerowclose;
 htp.tableclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'SLD', 'CONTROLLER',errmsg=>sqlerrm,extdet=>'SLID:' || slid);
end controller;

procedure phg_master(surl varchar2,acid in integer)
as
 cursor c1(phgid integer, acid integer, ltype in varchar2) is
  select sid,slideshow_name
  from slide_master
  where aid = acid and
        ((aid in (select aid from customer_account where pid=phgid) and (ltype = 'PHOTOGRAPHER')) or
         (ltype = 'OWNER' and phgid = acid))
  order by sid;
 c1rec	c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.PHG_MASTER', iscust=>FALSE );
 if (sts is not null) or not(is_owner(surl, ltype,owner_id,acid))
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 open c1(owner_id, acid, ltype);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   new_slide(surl,acid,LNG.SLD_TXT_016 );
   return;
 end if;
 close c1;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.SLD_TXT_086,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'S03',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>' border="0"');
 for c1rec in c1(owner_id,acid,ltype) loop
  htp.tablerowopen;
   htp.tabledata(htf.anchor( 'sld.edit_slideshow_master?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || c1rec.sid, htf.img( DECS.IMAGE_LOCATION || 'admin/slideshow.gif',cattributes=>'BORDER="0"') ));
   htp.tabledata(htf.anchor( 'sld.edit_slideshow_master?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || c1rec.sid, c1rec.slideshow_name ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="CENTER"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.formopen( 'sld.new_slide' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formsubmit( null, LNG.SLD_TXT_017 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'SLD', 'PHG_MASTER',owner_id,acid,errmsg=>sqlerrm);
end phg_master;

procedure new_slide(surl varchar2,acid in integer, msg in varchar2 default null)
as
 cursor c1 is select clr_name from colours order by clr_name;

 cursor c1a(v_category varchar2, v_owned_by varchar2, v_owner_id integer, v_parent_id integer, v_phgr integer) is
  select usc.order_by,usc.title,usc.umo_scene_id
  from umo_scene usc
  where category = v_category and
        nvl(parent_scene,0) = nvl(v_parent_id,0) and
        ((owned_by = 'PUBLIC') or
         (owned_by = v_owned_by and v_owned_by = 'PHOTOGRAPHER' and owner_id = v_owner_id) or
         (v_owned_by = 'OWNER' and owned_by = v_owned_by and owner_id = v_owner_id) or
         (v_owned_by = 'OWNER' and owned_by = 'PHOTOGRAPHER' and owner_id = v_phgr )) and
         exists (select 'x' from umo um where um.umo_scene_id = usc.umo_scene_id and um.umo_type = 'PHOTO' and um.aid = v_owner_id)
  order by order_by;

 cursor c1b( acid integer, phgid integer ) is
  select distinct nvl(um.extra_roll_id,LNG2.FNM_TXT_004) roll_id
  from umo um
  where um.aid = acid and
        um.umo_type = 'PHOTO' and
        aid in (select aid from customer_account where pid = phgid and aid = acid)
  order by roll_id;

 cursor c2(acid integer, phgid integer) is select scene_name,background_img from customer_account where aid=acid and pid = phgid;

 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		varchar2(4000);
begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.NEW_SLIDE', iscust=>FALSE);
 if (sts is not null) or not(is_owner(surl, ltype,owner_id,acid))
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.SLD_TXT_017,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'S04',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
 htp.formopen( 'sld.accept_new_slide' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.bold( LNG.GLB_TXT_066 );
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
     htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.SLD_TXT_019),cattributes=>pfx.qbground );
       htp.tabledata( htf.formtext( 'P1', 30, 100 ),cattributes=>pfx.qcbground );
     htp.tablerowclose;
	 tmp := htf.formselectopen( 'P2' ) || htf.formselectoption( '5' ) ||
	        htf.formselectoption( '10', 'SELECTED' ) || htf.formselectoption( '15' ) || htf.formselectoption( '20' ) || htf.formselectoption( '25' ) ||
	        htf.formselectoption( '30' ) || htf.formselectoption( '35' ) || htf.formselectoption( '40' ) || htf.formselectoption( '45' ) ||
	        htf.formselectoption( '50' ) || htf.formselectoption( '55' ) || htf.formselectoption( '60' ) ||
			htf.formselectclose;
     htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.SLD_TXT_020),cattributes=>pfx.qbground );
       htp.tabledata( tmp,cattributes=>pfx.qcbground );
     htp.tablerowclose;
	 tmp := htf.formselectopen( 'P3' ) || htf.formselectoption( LNG.SLD_TXT_021, 'SELECTED' ) || htf.formselectoption( LNG.SLD_TXT_022 ) ||
	        htf.formselectoption( LNG.SLD_TXT_023 ) || htf.formselectoption( LNG.SLD_TXT_024 ) || htf.formselectclose;
     htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.SLD_TXT_025),cattributes=>pfx.qbground );
       htp.tabledata( tmp,cattributes=>pfx.qcbground );
     htp.tablerowclose;
	 tmp := htf.formselectopen( 'P4' );
	 for c1rec in c1 loop
	  tmp := tmp || htf.formselectoption( c1rec.clr_name );
	 end loop;
	 tmp := tmp || htf.formselectclose;
     htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.SLD_TXT_026),cattributes=>pfx.qbground );
       htp.tabledata( tmp,cattributes=>pfx.qcbground );
     htp.tablerowclose;
	 htp.formhidden( 'P5','F');
	 htp.formhidden( 'P6','F');
	 htp.formhidden( 'P7','F');
  htp.tableclose;
 htp.nl;
 htp.bold( LNG2.PBK_TXT_060 );
 htp.nl;
 open c2(acid,owner_id);
 fetch c2 into c2rec;
 close c2;
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.PBK_TXT_061 ),cattributes=>pfx.qbground );
   htp.p('<TD ' || pfx.qcbground ||'>');
    htp.formselectopen( 'OTH' );
    htp.formselectoption( NULL );
    htp.formselectoption( LNG.SLD_BUT_052 );
    htp.formselectoption( LNG.SLD_BUT_051 );
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.SLD_TXT_077 ),cattributes=>pfx.qbground );
   htp.p('<TD ' || pfx.qcbground ||'>');
    htp.formselectopen( 'OTH' );
    htp.formselectoption( NULL );
    for c1arec in c1a(c2rec.scene_name, 'OWNER', acid, null, owner_id ) loop
     htp.formselectoption( c1arec.title, cattributes=>'VALUE="[' || c1arec.umo_scene_id || '"' );
    end loop;
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.SLD_TXT_078 ),cattributes=>pfx.qbground );
   htp.p('<TD ' || pfx.qcbground ||'>');
    htp.formselectopen( 'OTH' );
    htp.formselectoption( NULL );
    for c1brec in c1b(acid,owner_id) loop
     htp.formselectoption( c1brec.roll_id, cattributes=>'VALUE="' || c1brec.roll_id || '"' );
    end loop;
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.formsubmit( 'ACTION', LNG.SLD_TXT_017 );
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'SLD', 'NEW_SLIDE',owner_id,acid,errmsg=>sqlerrm);
end new_slide;

procedure accept_new_slide( surl varchar2,acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, action in varchar2 default null, oth in GLBX.MYARRAY)
as

 cursor c1( acid integer, nme varchar2 ) is
  select count('x')
  from slide_master
  where aid=acid and upper(slideshow_name) = nme;

 cursor c2( cname varchar2 ) is select clr_hex from colours where clr_name = cname;

 cursor c3( acid integer, ctr integer, tmp integer, phgid integer ) is
   select ctr v1,rownum v2,um.extras.photo_name v3,tmp v4,1 v5,um.umo_id v6
    from umo um
    where um.aid=acid and
          um.extras.quality in ('SPECIAL MOMENT','DETAIL PHOTO')
   order by decode(um.extras.quality,'DETAIL PHOTO',1,'SPECIAL MOMENT',2,3),um.extras.orderby_scene,um.extras.orderby_nmb;

 cursor c3a( acid integer, ctr integer, tmp integer, phgid integer ) is
   select ctr v1,rownum v2,um.extras.photo_name v3,tmp v4,1 v5,um.umo_id v6
    from umo um
    where um.aid=acid
   order by um.extras.orderby_nmb;

cursor c4( acid integer,phgid integer ) is select 'x' from customer_account where aid=acid and pid=phgid;

 cursor c5( acid integer, ctr integer, tmp integer, phgid integer, rid varchar2 ) is
  select ctr v1,rownum v2,um.extras.photo_name v3,tmp v4,1 v5,um.umo_id v6
  from umo um
  where um.aid = acid and
        um.umo_type = 'PHOTO' and
        um.extra_roll_id = rid
 order by um.extras.orderby_nmb;

 cursor c6( acid integer, ctr integer, tmp integer, phgid integer, scid integer ) is
   select ctr v1,rownum v2,um.extras.photo_name v3,tmp v4,1 v5,um.umo_id v6
    from umo um
    where um.aid=acid and
          um.umo_scene_id = scid
   order by um.extras.orderby_nmb;

 cursor c7( uscid integer ) is select title from umo_scene where umo_scene_id = uscid;

 c7rec		c7%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 ctr		integer;
 tmp		integer;
 tmp2		varchar2(100);
 rctr		integer;
 vp1		varchar2(100);
 the_option	varchar2(100);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.ACCEPT_NEW_SLIDE', iscust=>FALSE );
 if (sts is not null) or not(is_owner(surl, ltype,owner_id,acid))
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if ltype = 'PHOTOGRAPHER'
  then
   open c4(acid,owner_id);
   fetch c4 into tmp2;
   if c4%NOTFOUND then close c4; return; end if; -- Someone gave an illegal customer account id
   close c4;
 end if;
 tmp2 := NULL;
 for j in oth.first..oth.last loop
  if oth(j) is not null then the_option := oth(j); end if;
 end loop;
 ctr := 0;
 open c1(acid,upper(p1));
 fetch c1 into ctr;
 close c1;

 if (nvl(ctr,0) > 0)
  then
   new_slide( surl, acid, LNG.SLD_TXT_027 );
   return;
 end if;

 select s_slide_master.nextval into ctr from dual;
 if p3 = LNG.SLD_TXT_021 then tmp := 0;
 elsif p3 = LNG.SLD_TXT_022 then tmp := 1;
 elsif p3 = LNG.SLD_TXT_023 then tmp := 5;
 else tmp := 10;
 end if;
 open c2(p4);
 fetch c2 into tmp2;
 close c2;

 vp1 := p1;
 if vp1 is null and the_option = LNG.SLD_BUT_052
  then
   vp1 := LNG2.PBK_TXT_061;
 elsif vp1 is null and the_option = LNG.SLD_BUT_051
  then
   vp1 := initcap( LNG.ORD_TXT_194 );
 elsif vp1 is null and (substr(the_option,1,1) = '[')
  then
   open c7( to_number(substr(the_option,2)));
   fetch c7 into c7rec;
   close c7;
   vp1 := c7rec.title;
 elsif vp1 is null and (substr(the_option,1,1) <> '[') and (the_option is not null)
  then
   vp1 := the_option;
  else
   if vp1 is null then vp1 := LNG.PHG_TXT_042; end if;
 end if;

 insert into slide_master(aid,sid,slideshow_name,default_timing,background_clr,frame_size,b_photo_name,b_comments,b_in_the_photo)
  values
   (acid,ctr,vp1,p2,tmp2,tmp,p5,p6,p7);
 commit;

 -- Create Default Slide Show using Special Moments Photos
 if the_option = LNG.SLD_BUT_052
  then
   for c3rec in c3(acid,ctr,p2,owner_id) loop
    rctr := c3%ROWCOUNT;
    insert into slide_details(sid,slide_nmbr,slide_title,next_timing,slide_type,phid_1)
    values(c3rec.v1,rctr,c3rec.v3,c3rec.v4,c3rec.v5,c3rec.v6);
   end loop;
   commit;
 elsif the_option = LNG.SLD_BUT_051
  then
   for c3arec in c3a(acid,ctr,p2,owner_id) loop
    rctr := c3a%ROWCOUNT;
    insert into slide_details(sid,slide_nmbr,slide_title,next_timing,slide_type,phid_1)
    values(c3arec.v1,rctr,c3arec.v3,c3arec.v4,c3arec.v5,c3arec.v6);
   end loop;
   commit;
 elsif (substr(the_option,1,1) = '[')
  then
   for c6rec in c6(acid,ctr,p2,owner_id,to_number(substr(the_option,2))) loop
    rctr := c6%ROWCOUNT;
    insert into slide_details(sid,slide_nmbr,slide_title,next_timing,slide_type,phid_1)
    values(c6rec.v1,rctr,c6rec.v3,c6rec.v4,c6rec.v5,c6rec.v6);
   end loop;
   commit;
 elsif (substr(the_option,1,1) <> '[') and (the_option is not null)
  then
   for c5rec in c5(acid,ctr,p2,owner_id,the_option) loop
    rctr := c5%ROWCOUNT;
    insert into slide_details(sid,slide_nmbr,slide_title,next_timing,slide_type,phid_1)
    values(c5rec.v1,rctr,c5rec.v3,c5rec.v4,c5rec.v5,c5rec.v6);
   end loop;
   commit;
 elsif action = LNG.SLD_BUT_031
  then
   null;
 end if;
 edit_slideshow_master(surl,acid,ctr);
exception when others then
 glbx.error_details( 'SLD', 'ACCEPT_NEW_SLIDE',owner_id,acid,errmsg=>sqlerrm,extdet=>'CTR:' || ctr);
end accept_new_slide;

procedure edit_slideshow_details(surl varchar2,acid in integer, slid in integer, msg in varchar2 default null)
as
 cursor c1 is select clr_name,clr_hex from colours order by clr_name;
 cursor c2(slid integer, acid integer) is select * from slide_master where sid = slid and aid=acid;
 c2rec	c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		varchar2(4000);
 tmp2		varchar2(20);
begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.EDIT_SLIDESHOW_DETAILS', iscust=>FALSE );
 if (sts is not null) or not(is_owner(surl, ltype,owner_id,acid))
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.SLD_TXT_028,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'S05',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.bold( LNG.SLD_TXT_029 );
 htp.nl;
 htp.nl;
 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
 open c2(slid,acid);
 fetch c2 into c2rec;
 close c2;
 htp.formopen( 'sld.accept_edit_slide' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'SLID', slid );
 htp.tableopen(cattributes=>'cellpadding=1 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
     htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.SLD_TXT_019),cattributes=>pfx.qbground );
       htp.tabledata( htf.formtext( 'P1', 30, 100, c2rec.slideshow_name ),cattributes=>pfx.qcbground );
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.SLD_TXT_020),cattributes=>pfx.qbground );
       htp.tabledata( lov_refresh( surl, 'P2', c2rec.default_timing ),cattributes=>pfx.qcbground );
     htp.tablerowclose;
	 tmp := htf.formselectopen( 'P3' );
	 tmp2 := null;
	 if c2rec.frame_size = '0' then tmp2 := 'SELECTED'; end if;
	 tmp := tmp || htf.formselectoption( LNG.SLD_TXT_021,tmp2 );
	 tmp2 := null;
	 if c2rec.frame_size = '1' then tmp2 := 'SELECTED'; end if;
	 tmp := tmp || htf.formselectoption( LNG.SLD_TXT_022,tmp2 );
	 tmp2 := null;
	 if c2rec.frame_size = '5' then tmp2 := 'SELECTED'; end if;
	 tmp := tmp || htf.formselectoption( LNG.SLD_TXT_023,tmp2 );
	 tmp2 := null;
	 if c2rec.frame_size = '10' then tmp2 := 'SELECTED'; end if;
	 tmp := tmp || htf.formselectoption( LNG.SLD_TXT_024,tmp2 );
	 tmp := tmp || htf.formselectclose;
     htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.SLD_TXT_025),cattributes=>pfx.qbground );
       htp.tabledata( tmp,cattributes=>pfx.qcbground );
     htp.tablerowclose;
	 tmp := htf.formselectopen( 'P4' );
	 for c1rec in c1 loop
	  if c2rec.background_gif is null
	   then
	    if c2rec.background_clr = c1rec.clr_hex
	     then
	      tmp := tmp || htf.formselectoption( c1rec.clr_name, 'SELECTED' );
	     else
	      tmp := tmp || htf.formselectoption( c1rec.clr_name );
	    end if;
	   else
	    if c2rec.background_clr = c1rec.clr_hex then tmp := c1rec.clr_name; end if;
	   end if;
	 end loop;
	 if c2rec.background_gif is null then tmp := tmp || htf.formselectclose; end if;
	 if c2rec.background_gif is null
	  then
       htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.SLD_TXT_026),cattributes=>pfx.qbground );
         htp.tabledata( tmp,cattributes=>pfx.qcbground );
       htp.tablerowclose;
	  else
       htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.SLD_TXT_032),cattributes=>pfx.qbground );
         htp.tabledata( LNG.SLD_TXT_033,cattributes=>pfx.qcbground );
		 htp.formhidden( 'P4', tmp );
       htp.tablerowclose;
	 end if;
	 htp.formhidden( 'P5','F');
	 htp.formhidden( 'P6','F');
	 htp.formhidden( 'P7','F');
 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION', LNG.SLD_BUT_053 );
 htp.formsubmit( 'ACTION', LNG.SLD_BUT_054 );
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'SLD', 'EDIT_SLIDESHOW_DETAILS',owner_id,acid,errmsg=>sqlerrm,extdet=>'SLID:' || slid);
end edit_slideshow_details;

procedure accept_edit_slide( surl varchar2,acid in integer, slid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, action in varchar2)
as
 cursor c1(acid integer, nme varchar2) is select count('x') from slide_master where aid=acid and upper(slideshow_name) = nme;
 cursor c2(cname varchar2) is select clr_hex from colours where clr_name = cname;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 ctr		integer;
 tmp		integer;
 tmp2		varchar2(100);
begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.ACCEPT_EDIT_SLIDE', iscust=>FALSE );
 if (sts is not null) or not(is_owner(surl, ltype,owner_id,acid))
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if (p1 is null)
  then
   edit_slideshow_details( acid, slid, LNG.SLD_TXT_034 );
   return;
 end if;
 if p3 = 'None' then tmp := 0;
 elsif p3 = 'Small' then tmp := 1;
 elsif p3 = 'Medium' then tmp := 5;
 else tmp := 10;
 end if;
 open c2(p4);
 fetch c2 into tmp2;
 close c2;
  -- If the timing value changes modify all slides to the new timing
  update slide_details
   set
    next_timing = p2
   where sid = slid and
    p2 <> (select default_timing from slide_master where sid = slid );

 update slide_master
  set slideshow_name = p1,
      default_timing = p2,
	  background_clr = tmp2,
	  frame_size = tmp,
	  b_photo_name = p5,
	  b_comments = p6,
	  b_in_the_photo = p7
  where sid = slid;
 commit;
 if action = LNG.SLD_BUT_053
  then
   slide_main(surl,acid,slid, LNG.SLD_TXT_035);
  else
   sld_bac(surl,slid);
 end if;
exception when others then
 glbx.error_details( 'SLD', 'ACCEPT_EDIT_SLIDE',owner_id,acid,errmsg=>sqlerrm,extdet=>'CTR:' || ctr || ' SLID: ' || slid || ' TMP:' || tmp || ' TMP2:' || tmp2);
end accept_edit_slide;

procedure insert_slide(surl varchar2,acid in integer, slid in integer, typ in integer)
as
 cursor c1(slid integer) is select max(slide_nmbr) from slide_details where sid = slid;
 cursor c2(slid integer) is select * from slide_master where sid=slid;
 c2rec	c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 ctr		integer;
 snmbr		integer;
begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.INSERT_SLIDE', iscust=>FALSE );
 if (sts is not null) or not(is_owner(surl, ltype,owner_id,acid))
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c2(slid);
 fetch c2 into c2rec;
 close c2;
 htp.htmlopen;
  pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.SLD_TXT_085,helpid=>'S06',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 open c1(slid);
 fetch c1 into snmbr;
 close c1;
 if snmbr is null then snmbr := 1; else snmbr := snmbr + 1; end if;
 slide_modify( surl, acid, slid, typ, snmbr, 'ADD', ltype, pfx );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'SLD', 'INSERT_SLIDE',owner_id,acid,errmsg=>sqlerrm,extdet=>'CTR:' || ctr || ' SLID: ' || slid || ' TYP:' || typ);
end insert_slide;

procedure insert_bslide(surl varchar2,acid in integer, slid in integer, typ in integer, snmbr in integer)
as
 cursor c2(slid integer) is select * from slide_master where sid=slid;
 c2rec	c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 ctr		integer;
begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.INSERT_BSLIDE', iscust=>FALSE );
 if (sts is not null) or not(is_owner(surl, ltype,owner_id,acid))
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c2(slid);
 fetch c2 into c2rec;
 close c2;
 htp.htmlopen;
  htp.p( '<BODY BGCOLOR="' ||  c2rec.background_clr || '">' );
  pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.SLD_BUT_069,helpid=>'S07',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 slide_modify( surl, acid, slid, typ, snmbr, 'INS', ltype, pfx );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'SLD', 'INSERT_BSLIDE',owner_id,acid,errmsg=>sqlerrm,extdet=>'CTR:' || ctr || ' SLID: ' || slid || ' TYP:' || typ || ' SNMBR:' || snmbr);
end insert_bslide;

procedure del_slide(surl varchar2,acid in integer, slid in integer, snmbr in integer)
as
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 ctr		integer;
begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.DEL_SLIDE', iscust=>FALSE );
 if (sts is not null) or not(is_owner(surl, ltype,owner_id,acid))
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 delete from slide_details where sid=slid and slide_nmbr=snmbr;
 update slide_details
  set
   slide_nmbr = slide_nmbr - 1
  where sid = slid and
        slide_nmbr > snmbr;
 commit;
 slide_main(surl,acid,slid,LNG.SLD_TXT_038);

exception when others then
 glbx.error_details( 'SLD', 'DEL_SLIDE',owner_id,acid,errmsg=>sqlerrm,extdet=>'CTR:' || ctr || ' SLID: ' || slid || ' SNMBR:' || snmbr);
end del_slide;

procedure accept_slide_modify(surl varchar2,acid in integer, slid in integer, typ in integer, snmbr in integer, action in varchar2, p1 in varchar2, p2 in varchar2, p3 in SLD.MYARRAY, p4 in SLD.MYARRAY )
as
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 ph1		integer;
 ph2		integer;
 ph3		integer;
 ph4		integer;
begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.ACCEPT_SLIDE_MODIFY', iscust=>FALSE );
 if (sts is not null) or not(is_owner(surl, ltype,owner_id,acid))
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if action not in (LNG.SLD_BUT_067,LNG.SLD_BUT_068,LNG.SLD_BUT_069,LNG.SLD_BUT_070)
  then
   slide_main( surl,acid, slid, LNG.SLD_TXT_040 );
   return;
 end if;
 for j in p3.first..p3.last loop
  if p4(j) = '1' then ph1 := to_number(p3(j)); end if;
  if p4(j) = '2' then ph2 := to_number(p3(j)); end if;
  if p4(j) = '3' then ph3 := to_number(p3(j)); end if;
  if p4(j) = '4' then ph4 := to_number(p3(j)); end if;
 end loop;
 if action in (LNG.SLD_BUT_067,LNG.SLD_BUT_070)
   then
   update slide_details
     set
      slide_title = p1,
	  next_timing = p2,
	  phid_1 = ph1,
	  phid_2 = ph2,
	  phid_3 = ph3,
	  phid_4 = ph4
    where sid = slid and
          slide_nmbr = snmbr;
  elsif action in (LNG.SLD_BUT_068,LNG.SLD_BUT_069)
   then
   update slide_details
    set slide_nmbr = slide_nmbr + 1
	where sid = slid and
	      slide_nmbr >= snmbr;
   insert into slide_details(sid,slide_nmbr,slide_title,next_timing,slide_type,phid_1,phid_2,phid_3,phid_4) values
    (slid,snmbr,p1,p2,typ,ph1,ph2,ph3,ph4);
 end if;
 commit;
 if action = LNG.SLD_BUT_070
  then
   slide_main( surl,acid, slid, LNG.SLD_TXT_040 );
  else
   update_slide(surl,acid,slid,snmbr,typ,LNG.SLD_TXT_039);
 end if;
exception when others then
 glbx.error_details( 'SLD', 'ACCEPT_SLIDE_MODIFY',owner_id,acid,errmsg=>sqlerrm,extdet=>' SLID: ' || slid || ' TYP:' || typ || ' SNMBR:' || snmbr );
end accept_slide_modify;

procedure slide_modify(surl varchar2, acid in integer, slid in integer, typ in integer, snmbr in integer, sldtype in varchar2, ltype in varchar2, pfx in THEME%ROWTYPE)
as
 cursor c1(slid integer, snmbr integer) is select * from slide_details where sid = slid and slide_nmbr = snmbr;
 cursor c2(slid integer) is select * from slide_master where sid = slid;
 c1rec	c1%ROWTYPE;
 c2rec	c2%ROWTYPE;
begin
 open c1(slid,snmbr);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
  else
   close c1;
 end if;
 open c2(slid);
 fetch c2 into c2rec;
 close c2;
 htp.formopen( 'SLD.ACCEPT_SLIDE_MODIFY' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'SLID', slid );
 htp.formhidden( 'TYP', typ );
 htp.formhidden( 'SNMBR', nvl(snmbr,1) );
 htp.bold( LNG.SLD_TXT_041); htp.nl;
 htp.nl;
 if sldtype = 'UPD'
  then
   htp.formsubmit( 'ACTION', LNG.SLD_BUT_067);
 elsif sldtype = 'INS'
  then
   htp.formsubmit( 'ACTION', LNG.SLD_BUT_069 );
 elsif sldtype = 'ADD'
  then
   htp.formsubmit( 'ACTION', LNG.SLD_BUT_068 );
 end if;
 htp.formsubmit( 'ACTION', LNG.SLD_BUT_070 );
 htp.formsubmit( 'ACTION', LNG4.AHC_TXT_919 );
 htp.nl;
 htp.tableopen( cattributes=>' border=0 cellpadding=0 cellspacing=0 ' );
 if typ = 1
  then
   htp.tablerowopen;
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_1, c2rec.frame_size, '1', ltype, pfx.qcbground );
   htp.tablerowclose;
 elsif typ = 2
  then
   htp.tablerowopen;
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_1, c2rec.frame_size, '1', ltype, pfx.qcbground   );
   htp.tablerowclose;
   htp.tablerowopen;
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_2, c2rec.frame_size, '2', ltype, pfx.qcbground   );
   htp.tablerowclose;
 elsif typ = 3
  then
   htp.tablerowopen;
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_1, c2rec.frame_size, '1', ltype, pfx.qcbground   );
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_2, c2rec.frame_size, '2', ltype, pfx.qcbground   );
   htp.tablerowclose;
 elsif typ = 4
  then
   htp.tablerowopen;
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_1, c2rec.frame_size, '1', ltype, pfx.qcbground   );
	htp.p( '<TD>' );
	htp.tableopen(cattributes=>' border=1' );
     htp.tablerowopen;
      table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_2, c2rec.frame_size, '2', ltype, pfx.qcbground   );
     htp.tablerowclose;
     htp.tablerowopen;
      table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_3, c2rec.frame_size, '3', ltype, pfx.qcbground   );
     htp.tablerowclose;
	 htp.tableclose;
	 htp.p( '</TD>' );
   htp.tablerowclose;
 elsif typ = 5
  then
   htp.tablerowopen;
	htp.p( '<TD>' );
	htp.tableopen(cattributes=>' border=1' );
     htp.tablerowopen;
      table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_1, c2rec.frame_size, '1', ltype, pfx.qcbground   );
     htp.tablerowclose;
     htp.tablerowopen;
      table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_2, c2rec.frame_size, '2', ltype, pfx.qcbground   );
     htp.tablerowclose;
	 htp.tableclose;
	 htp.p( '</TD>' );
     table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_3, c2rec.frame_size, '3', ltype, pfx.qcbground   );
   htp.tablerowclose;
 elsif typ = 6
  then
   htp.tablerowopen;
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_1, c2rec.frame_size, '1', ltype, pfx.qcbground   );
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_2, c2rec.frame_size, '2', ltype, pfx.qcbground   );
   htp.tablerowclose;
   htp.tablerowopen;
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_3, c2rec.frame_size, '3', ltype, pfx.qcbground   );
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_4, c2rec.frame_size, '4', ltype, pfx.qcbground   );
   htp.tablerowclose;
 elsif typ = 7
  then
   htp.tablerowopen;
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_1, c2rec.frame_size, '1', ltype, pfx.qcbground   );
	htp.p( '<TD>' );
	htp.tableopen(cattributes=>' border=1' );
     htp.tablerowopen;
      table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_2, c2rec.frame_size, '2', ltype, pfx.qcbground   );
     htp.tablerowclose;
     htp.tablerowopen;
      table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_3, c2rec.frame_size, '3', ltype, pfx.qcbground   );
     htp.tablerowclose;
	 htp.tableclose;
	 htp.p( '</TD>' );
     table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_4, c2rec.frame_size, '4', ltype, pfx.qcbground   );
   htp.tablerowclose;
 elsif typ = 8
  then
   htp.tablerowopen;
    htp.tabledata( '&nbsp;' );
    htp.tabledata( '&nbsp;' );
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_1, c2rec.frame_size, '1', ltype, pfx.qcbground   );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;' );
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_2, c2rec.frame_size, '2', ltype, pfx.qcbground   );
    htp.tabledata( '&nbsp;' );
   htp.tablerowclose;
   htp.tablerowopen;
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_3, c2rec.frame_size, '3', ltype, pfx.qcbground   );
    htp.tabledata( '&nbsp;' );
    htp.tabledata( '&nbsp;' );
   htp.tablerowclose;
 elsif typ = 9
  then
   htp.tablerowopen;
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_1, c2rec.frame_size, '1', ltype, pfx.qcbground   );
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_2, c2rec.frame_size, '2', ltype, pfx.qcbground   );
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_3, c2rec.frame_size, '3', ltype, pfx.qcbground   );
   htp.tablerowclose;
 elsif typ = '0'
  then
   htp.tablerowopen;
    htp.tabledata( '&nbsp;' );
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_1, c2rec.frame_size, '1', ltype, pfx.qcbground   );
    htp.tabledata( '&nbsp;' );
   htp.tablerowclose;
   htp.tablerowopen;
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_2, c2rec.frame_size, '2', ltype, pfx.qcbground   );
    htp.tabledata( '&nbsp;' );
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_3, c2rec.frame_size, '3', ltype, pfx.qcbground   );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;' );
    table_photo( surl, acid, slid, typ, nvl(snmbr,1), c1rec.phid_4, c2rec.frame_size, '4', ltype, pfx.qcbground   );
    htp.tabledata( '&nbsp;' );
   htp.tablerowclose;
 end if;
 htp.tableclose;
 htp.tableopen( cattributes=>'border=1' );
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.SLD_TXT_042),cattributes=>pfx.qbground );
    htp.tabledata( htf.formtext( 'P1', 30, 100, c1rec.slide_title ),cattributes=>pfx.qcbground );
  htp.tablerowclose;
  if c1rec.next_timing is null
   then
    c1rec.next_timing := c2rec.default_timing;
  end if;
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.SLD_TXT_043),cattributes=>pfx.qbground );
    htp.tabledata( lov_refresh( surl, 'P2', c1rec.next_timing ),cattributes=>pfx.qcbground );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 if sldtype = 'UPD'
  then
   htp.formsubmit( 'ACTION', LNG.SLD_BUT_067 );
 elsif sldtype = 'INS'
  then
   htp.formsubmit( 'ACTION', LNG.SLD_BUT_069 );
 elsif sldtype = 'ADD'
  then
   htp.formsubmit( 'ACTION', LNG.SLD_BUT_068 );
 end if;
 htp.formsubmit( 'ACTION', LNG.SLD_BUT_070 );
 htp.formsubmit( 'ACTION', LNG4.AHC_TXT_919 );
 htp.formclose;
exception when others then
 glbx.error_details( 'SLD', 'SLIDE_MODIFY',vaid=>acid,errmsg=>sqlerrm,extdet=>' SLID: ' || slid || ' TYP:' || typ || ' SNMBR:' || snmbr);
end slide_modify;

procedure table_photo(surl varchar2, acid in integer, slid in integer, typ in integer, snmbr in integer, photo_id in integer, fsize in integer, id in varchar2, ltype in varchar2, qcbground in varchar2)
as
 cursor c1(acid integer) is
  select um.umo_id,um.umo_scene_id,um.extras.title title,um.extras.film_name value,um.version
  from umo um
  where um.aid = acid and
        nvl(um.photo_thumbnail.contentlength,0) <> 0
  order by um.extras.orderby_scene,um.umo_id;
  cursor c2(v_umo integer) is
   select um.photo_thumbnail.width width, um.photo_thumbnail.height height
   from umo um where umo_id = v_umo;
 tmp 	varchar2(32767);
 c2rec	c2%ROWTYPE;
begin
 htp.p( '<TD valign="MIDDLE" ALIGN="CENTER">' );
  htp.tableopen( cattributes=>'border=' || fsize );
  htp.tablerowopen;
  if photo_id is not null
   then
    open c2(photo_id);
    fetch c2 into c2rec;
    close c2;
    htp.tabledata( htf.anchor('ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || photo_id || '&parm1=DISPLAY_TYPE&parm2=IMAGE&parm1=DISPLAY_WHAT&parm2=MASTER' ||
                              '&parm1=LOGIN_TYPE&parm2=' || ltype || '&PARM1=AID&PARM2=' || acid ||
                              '&parm1=RETLINK&parm2=sld.update_slide~surl=' || glbx.rndsurl(surl) || '!acid=' || acid || '!slid=' || slid || '!typ=' || typ || '!snmbr=' || snmbr,
                   '<IMG BORDER=0 WIDTH=' || c2rec.width || ' HEIGHT=' || c2rec.height || ' SRC="' ||
                   'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || photo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' ||
                   '&parm1=LOGIN_TYPE&parm2=' || ltype || '&PARM1=AID&PARM2=' || acid  || '" ALT="' || LNG.SLD_TXT_084 || '" STYLE="display:block;">'),cattributes=>qcbground || ' valign="MIDDLE" ALIGN="CENTER"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.p( '<TD>' );
   htp.formhidden( 'P4', id );
   htp.formselectopen( 'P3' );
   for c1rec in c1(acid) loop
    if c1rec.umo_id=photo_id
	 then
	  htp.formselectoption( c1rec.title || '-' || c1rec.value, 'SELECTED', cattributes=>'VALUE="' || c1rec.umo_id || '"' );
	 else
	  htp.formselectoption( c1rec.title || '-' || c1rec.value, cattributes=>'VALUE="' || c1rec.umo_id || '"' );
	end if;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tableclose;
 htp.p( '</TD>' );
exception when others then
 glbx.error_details( 'SLD', 'TABLE_PHOTO',vaid=>acid,errmsg=>sqlerrm,extdet=>' SLID: ' || slid || ' TYP:' || typ || ' SNMBR:' || snmbr || ' PHOTO_ID:' || photo_id);
end table_photo;

function lov_refresh( surl varchar2, id in varchar2, default_timing in varchar2 )
 return varchar2
is
 tmp 	varchar2(2000);
 tmp2	varchar2(20);
begin
	 tmp := htf.formselectopen( 'P2' );
	 tmp2 := null;
	 if default_timing = '5' then tmp2 := 'SELECTED'; end if;
	 tmp := tmp || htf.formselectoption( '5',tmp2 );
	 tmp2 := null;
	 if default_timing = '10' then tmp2 := 'SELECTED'; end if;
	 tmp := tmp || htf.formselectoption( '10',tmp2 );
	 tmp2 := null;
	 if default_timing = '15' then tmp2 := 'SELECTED'; end if;
	 tmp := tmp || htf.formselectoption( '15',tmp2 );
	 tmp2 := null;
	 if default_timing = '20' then tmp2 := 'SELECTED'; end if;
	 tmp := tmp || htf.formselectoption( '20',tmp2 );
	 tmp2 := null;
	 if default_timing = '25' then tmp2 := 'SELECTED'; end if;
	 tmp := tmp || htf.formselectoption( '25',tmp2 );
	 tmp2 := null;
	 if default_timing = '30' then tmp2 := 'SELECTED'; end if;
	 tmp := tmp || htf.formselectoption( '30',tmp2 );
	 tmp2 := null;
	 if default_timing = '35' then tmp2 := 'SELECTED'; end if;
	 tmp := tmp || htf.formselectoption( '35',tmp2 );
	 tmp2 := null;
	 if default_timing = '40' then tmp2 := 'SELECTED'; end if;
	 tmp := tmp || htf.formselectoption( '40',tmp2 );
	 tmp2 := null;
	 if default_timing = '45' then tmp2 := 'SELECTED'; end if;
	 tmp := tmp || htf.formselectoption( '45',tmp2 );
	 tmp2 := null;
	 if default_timing = '50' then tmp2 := 'SELECTED'; end if;
	 tmp := tmp || htf.formselectoption( '50',tmp2 );
	 tmp2 := null;
	 if default_timing = '55' then tmp2 := 'SELECTED'; end if;
	 tmp := tmp || htf.formselectoption( '55',tmp2 );
	 tmp2 := null;
	 if default_timing = '60' then tmp2 := 'SELECTED'; end if;
	 tmp := tmp || htf.formselectoption( '60',tmp2 );
	 tmp := tmp || htf.formselectclose;
	 return( tmp );
exception when others then
 glbx.error_details( 'SLD', 'LOV_REFRESH',errmsg=>sqlerrm,extdet=>'ID:' || id || ' DEFAULT_TIMING: ' || default_timing);
end lov_refresh;

procedure run_slideshow( surl varchar2,acid in integer, slid in integer )
as
begin
 display_slide( surl,acid, slid, 1, 0 );
exception when others then
 glbx.error_details( 'SLD', 'RUN_SLIDESHOW',vaid=>acid,errmsg=>sqlerrm,extdet=>'SLID:' || slid);
end run_slideshow;

procedure display_slide( surl varchar2, acid in integer, slid in integer, snmbr in integer, inf in integer default 0 )
as

 cursor c1(slid integer, acid integer) is select * from slide_master where aid=acid and sid=slid;
 cursor c2(slid integer, snmbr integer) is select * from slide_details where sid=slid and slide_nmbr = snmbr;
 cursor c3(acid integer) is select * from theme_types where theme_type in (select theme_type from customer_account where aid = acid );

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c2%ROWTYPE;
 lastslide	boolean;
 typ		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 tmp		varchar2(2000);
 theme_rec	theme_types%ROWTYPE;
 pfx		THEME%ROWTYPE;

begin
 if acid is null -- Logged in as Owner
  then
   glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.DISPLAY_SLIDE' );
   if sts is not null
    then
     glbx.redisplay_login_page( sts );
     return;
   end if;
   if ltype = 'VIRTUAL' then ltype := 'CUSTOMER'; end if;
   open c1( slid, nvl(acid,owner_id) );
   fetch c1 into c1rec;
   close c1;
   pfx := glbx.get_thm( owner_id );
  else
   glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.DISPLAY_SLIDE', iscust=>FALSE );
   if sts is not null
    then
     glbx.redisplay_login_page( sts );
     return;
   end if;
   -- if ltype <> 'PHOTOGRAPHER' then return; end if; -- someone trying to break in
   open c1( slid, acid);
   fetch c1 into c1rec;
   close c1;
   pfx := glbx.get_thm( acid );
 end if;

 open c3(nvl(acid,owner_id));
 fetch c3 into theme_rec;
 close c3;

 open c2( slid, snmbr );
 fetch c2 into c2rec;
 close c2;
 open c2( slid, snmbr + 1 );
 fetch c2 into c3rec;
 if c2%NOTFOUND
  then
   lastslide := TRUE;
  else
   lastslide := FALSE;
 end if;
 close c2;
 htp.htmlopen;

  if not lastslide
   then
     htp.p( '<META HTTP-EQUIV="Refresh" CONTENT="' || nvl(to_char(c2rec.next_timing),'25') ||
            ';URL=sld.display_slide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&snmbr=' || to_char(snmbr+1) || '&inf=' || to_char(inf) || '">');
   else
    if inf = 1
     then
       htp.p( '<META HTTP-EQUIV="Refresh" CONTENT="' || nvl(to_char(c2rec.next_timing),'25') ||
              ';URL=sld.display_slide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&inf=' || to_char(inf) || '&slid=' || slid || '&snmbr=1">');
    end if;
  end if;

 if ltype <> 'PHOTOGRAPHER'
  then
  htp.p('<HEAD><meta http-equiv="imagetoolbar" content="no">' );
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
htp.p('</HEAD>');
  end if;

  if c1rec.background_gif is null
   then
    htp.p('<BODY BGCOLOR="' || c1rec.background_clr || '" onLoad="trap()">');
   else
    htp.p(glbx.backimg(surl,acid,'FFFFFF',c1rec.background_gif,ltype,' onLoad="trap()" '));
  end if;

  htp.p( '<CENTER>' );

  tmp := htf.formopen( 'sld.process_slideshow' );
  tmp := tmp || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid );
  tmp := tmp || htf.formhidden( 'SLID', slid );
  tmp := tmp || htf.formhidden( 'SNMBR', snmbr );
  tmp := tmp || htf.formhidden( 'INF', inf );
  if lastslide
   then
     tmp := tmp || htf.formsubmit( 'ACTION', LNG.SLD_BUT_071 );
     tmp := tmp || htf.formsubmit( 'ACTION', LNG.SLD_BUT_072 );
     if snmbr > 1 then tmp := tmp || htf.formsubmit( 'ACTION', LNG.SLD_TXT_088 ); end if;
     if not lastslide then tmp := tmp || htf.formsubmit( 'ACTION', LNG.SLD_TXT_087 ); end if;
    else
     tmp := tmp || htf.formsubmit( 'ACTION', LNG.SLD_BUT_071 );
     if pfx.keep_lhf = 'N'
      then
        tmp := tmp || htf.formsubmit( 'ACTION', LNG.SLD_BUT_072 );
     end if;
     tmp := tmp || htf.formsubmit( 'ACTION', LNG.SLD_BUT_073 );
     if snmbr > 1 then tmp := tmp || htf.formsubmit( 'ACTION', LNG.SLD_TXT_088 ); end if;
     if not lastslide then tmp := tmp || htf.formsubmit( 'ACTION', LNG.SLD_TXT_087 ); end if;
  end if;
  tmp := tmp || htf.formclose;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata(tmp,cattributes=>glbx.TITLE_BACKGROUND || 'valign="TOP" ALIGN="LEFT"');
   htp.tabledata('<b><font size="+1" color="#ffffff">' || snmbr || ': ' || c2rec.slide_title || '</font></b>',cattributes=>glbx.TITLE_BACKGROUND || 'valign="TOP" ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=> 'border=0 cellpadding=0 cellspacing=0' );
 typ := c2rec.slide_type;
 if typ = 1
  then
   htp.tablerowopen;
    disp_table_photo( surl, pfx, c1rec, c2rec, c2rec.phid_1, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground );
   htp.tablerowclose;
 elsif typ = 2
  then
   htp.tablerowopen;
    disp_table_photo( surl, pfx, c1rec, c2rec, c2rec.phid_1, 2, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
    disp_table_photo( surl, pfx, c1rec, c2rec, c2rec.phid_2, 2, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground );
   htp.tablerowclose;
 elsif typ = 3
  then
   htp.tablerowopen;
    disp_table_photo( surl, pfx, c1rec, c2rec, c2rec.phid_1, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground  );
    disp_table_photo( surl, pfx, c1rec, c2rec, c2rec.phid_2, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground  );
   htp.tablerowclose;
 elsif typ = 4
  then
   htp.tablerowopen;
    disp_table_photo( surl, pfx, c1rec, c2rec, c2rec.phid_1, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground  );
    htp.p( '<TD>' );
    htp.tableopen(cattributes=>' border=0' );
     htp.tablerowopen;
      disp_table_photo( surl, pfx, c1rec, c2rec, c2rec.phid_2, 2, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground  );
     htp.tablerowclose;
     htp.tablerowopen;
      disp_table_photo( surl, pfx, c1rec, c2rec, c2rec.phid_3, 2, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground  );
     htp.tablerowclose;
    htp.tableclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
 elsif typ = 5
  then
   htp.tablerowopen;
	htp.p( '<TD>' );
	htp.tableopen(cattributes=>' border=0' );
     htp.tablerowopen;
      disp_table_photo( surl, pfx, c1rec, c2rec, c2rec.phid_1, 2, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground  );
     htp.tablerowclose;
     htp.tablerowopen;
      disp_table_photo( surl, pfx, c1rec, c2rec, c2rec.phid_2, 2, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground  );
     htp.tablerowclose;
	 htp.tableclose;
	 htp.p( '</TD>' );
     disp_table_photo( surl, pfx, c1rec, c2rec, c2rec.phid_3, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground  );
   htp.tablerowclose;
 elsif typ = 6
  then
   htp.tablerowopen;
    disp_table_photo( surl, pfx, c1rec, c2rec, c2rec.phid_1, 2, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground  );
    disp_table_photo( surl, pfx, c1rec, c2rec, c2rec.phid_2, 2, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground  );
   htp.tablerowclose;
   htp.tablerowopen;
    disp_table_photo( surl, pfx, c1rec, c2rec, c2rec.phid_3, 2, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground  );
    disp_table_photo( surl, pfx, c1rec, c2rec, c2rec.phid_4, 2, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground  );
   htp.tablerowclose;
 elsif typ = 7
  then
     htp.tablerowopen;
      disp_table_photo(  surl, pfx, c1rec, c2rec, c2rec.phid_1, 3, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground   );
  	htp.p( '<TD>' );
  	htp.tableopen(cattributes=>' border=1' );
       htp.tablerowopen;
        disp_table_photo(  surl, pfx, c1rec, c2rec, c2rec.phid_2, 2, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground   );
       htp.tablerowclose;
       htp.tablerowopen;
        disp_table_photo(  surl, pfx, c1rec, c2rec, c2rec.phid_3, 2, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground   );
       htp.tablerowclose;
  	 htp.tableclose;
  	 htp.p( '</TD>' );
       disp_table_photo(  surl, pfx, c1rec, c2rec, c2rec.phid_4, 3, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground   );
     htp.tablerowclose;
 elsif typ = 8
  then
   htp.tablerowopen;
    htp.tabledata( '&nbsp;' );
    htp.tabledata( '&nbsp;' );
    disp_table_photo(  surl, pfx, c1rec, c2rec, c2rec.phid_1, 3, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground   );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;' );
    disp_table_photo(  surl, pfx, c1rec, c2rec, c2rec.phid_2, 3, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground   );
    htp.tabledata( '&nbsp;' );
   htp.tablerowclose;
   htp.tablerowopen;
    disp_table_photo(  surl, pfx, c1rec, c2rec, c2rec.phid_3, 3, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground   );
    htp.tabledata( '&nbsp;' );
    htp.tabledata( '&nbsp;' );
   htp.tablerowclose;
 elsif typ = 9
  then
   htp.tablerowopen;
    disp_table_photo(  surl, pfx, c1rec, c2rec, c2rec.phid_1, 3, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground   );
    disp_table_photo(  surl, pfx, c1rec, c2rec, c2rec.phid_2, 1, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground   );
    disp_table_photo(  surl, pfx, c1rec, c2rec, c2rec.phid_3, 3, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground   );
   htp.tablerowclose;
 elsif typ = '0'
  then
   htp.tablerowopen;
    htp.tabledata( '&nbsp;' );
    disp_table_photo(  surl, pfx, c1rec, c2rec, c2rec.phid_1, 3, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground   );
    htp.tabledata( '&nbsp;' );
   htp.tablerowclose;
   htp.tablerowopen;
    disp_table_photo(  surl, pfx, c1rec, c2rec, c2rec.phid_2, 2, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground   );
    htp.tabledata( '&nbsp;' );
    disp_table_photo(  surl, pfx, c1rec, c2rec, c2rec.phid_3, 2, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground   );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;' );
    disp_table_photo(  surl, pfx, c1rec, c2rec, c2rec.phid_4, 3, ltype=>ltype, stype=>stype, theme_rec=>theme_rec, qcbground=>pfx.qcbground   );
    htp.tabledata( '&nbsp;' );
   htp.tablerowclose;
 end if;
 htp.tableclose;
   htp.nl;
   if lastslide then htp.bold(htf.italic( LNG.SLD_TXT_044 )); end if;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'SLD', 'DISPLAY_SLIDE',vaid=>acid,errmsg=>sqlerrm,extdet=>'SLID:' || slid || ' SNMBR:' || snmbr);
end display_slide;

procedure process_slideshow(surl varchar2,acid in integer, slid in integer, snmbr in integer, inf in integer, action in varchar2)
as
 cursor c1(slid integer) is select slideshow_name,background_clr from slide_master where sid=slid;
 cursor c2(slid integer) is select slide_nmbr,slide_title from slide_details where sid=slid order by slide_nmbr;
 cursor c3(acid integer) is select count('x') tot from slide_master where aid=acid;
 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
begin
 if action = LNG.SLD_BUT_071
  then
   display_slide(surl,acid,slid,1,inf);
   return;
 elsif action = LNG.SLD_TXT_087
  then
   display_slide(surl,acid,slid,snmbr+1,inf);
   return;
 elsif action = LNG.SLD_TXT_088
  then
   display_slide(surl,acid,slid,greatest(snmbr-1,1),inf);
   return;
 elsif action = LNG.SLD_BUT_072
  then
   if acid is null
    then
	  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.PROCESS_SLIDESHOW' );
	  if sts is not null
	   then
	    glbx.redisplay_login_page( sts );
	    return;
	  end if;
          if ltype = 'VIRTUAL' then ltype := 'CUSTOMER'; end if;
	  open c3( owner_id );
	  fetch c3 into c3rec;
	  close c3;
	  if nvl(c3rec.tot,0) = 0
	   then
	    cst.acct_details(surl);
	   else
	    --cust_slideshow;
	    glbx.acct_home(surl);
	  end if;
	else
	 sld.edit_slideshow_master( surl,acid, slid );
    end if;
   return;
 elsif action = LNG.SLD_BUT_074
  then
   display_slide(surl,acid,slid,snmbr,inf);
   return;
 elsif action = LNG.SLD_TXT_089
  then
   display_slide(surl,acid,slid,snmbr,1);
   return;
 elsif action = LNG.SLD_TXT_090
  then
   display_slide(surl,acid,slid,snmbr,0);
   return;
 end if;

 -- Paused Slideshow. Display Options.
  if acid is null
   then
     glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.PROCESS_SLIDESHOW' );
     if sts is not null
      then
       glbx.redisplay_login_page( sts );
       return;
     end if;
   else
     glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.PROCESS_SLIDESHOW', iscust=>FALSE );
     if sts is not null
      then
       glbx.redisplay_login_page( sts );
       return;
     end if;
  end if;
  if ltype = 'VIRTUAL' then ltype := 'CUSTOMER'; end if;
  open c1(slid);
  fetch c1 into c1rec;
  close c1;
  pfx := glbx.get_thm( nvl(acid,owner_id) );
  glbx.main_title( surl, LNG.SLD_TXT_045  || c1rec.slideshow_name ,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'S11',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active);
  htp.nl;
  htp.p( '<CENTER>' );
  htp.tableopen( cattributes=>'cellpadding=0 cellspacing=5 border=0' );

  htp.tablerowopen;
  htp.p( '<TD>' );
  htp.anchor( 'sld.process_slideshow?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&snmbr=' || snmbr || '&inf=' || translate(inf,' ','+') || '&action=' || translate(LNG.SLD_BUT_071,' ','+'),LNG.SLD_BUT_071);
  htp.nl;
  htp.nl;
  htp.anchor( 'sld.process_slideshow?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&snmbr=' || snmbr || '&inf=' || translate(inf,' ','+') || '&action=' || translate(LNG.SLD_BUT_072,' ','+'),LNG.SLD_BUT_072);
  htp.nl;
  htp.nl;
  htp.anchor( 'sld.process_slideshow?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&snmbr=' || snmbr || '&inf=' || translate(inf,' ','+') || '&action=' || translate(LNG.SLD_BUT_074,' ','+'),LNG.SLD_BUT_074);
  htp.nl;
  htp.nl;
  if inf = 0
   then
    htp.anchor( 'sld.process_slideshow?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&snmbr=' || snmbr || '&inf=' || translate(inf,' ','+') || '&action=' || translate(LNG.SLD_TXT_089,' ','+'),LNG.SLD_TXT_089);
   else
    htp.anchor( 'sld.process_slideshow?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&snmbr=' || snmbr || '&inf=' || translate(inf,' ','+') || '&action=' || translate(LNG.SLD_TXT_090,' ','+'),LNG.SLD_TXT_090);
  end if;
  htp.p( '</TD>' );
  htp.p( '<TD>' );
  htp.tableopen;
    for c2rec in c2(slid) loop
     htp.tablerowopen;
     if c2%ROWCOUNT = 1
      then
       htp.tabledata( htf.bold(LNG.SLD_TXT_046),cattributes=>pfx.qbground );
      else
       htp.tabledata( '&nbsp;' );
     end if;
     htp.tabledata( htf.anchor( 'sld.display_slide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&snmbr=' || c2rec.slide_nmbr || '&inf=' || inf, '[' || c2rec.slide_nmbr || ']' ),cattributes=>pfx.qcbground );
     htp.tabledata( htf.anchor( 'sld.display_slide?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&slid=' || slid || '&snmbr=' || c2rec.slide_nmbr || '&inf=' || inf, nvl(c2rec.slide_title,'&nbsp;') ),cattributes=>pfx.qcbground );
     htp.tablerowclose;
    end loop;
  htp.tableclose;
  htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tableclose;
  htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'SLD', 'PROCESS_SLIDESHOW',vaid=>acid,errmsg=>sqlerrm,extdet=>'SLID:' || slid || ' ACTION:' || action);
end process_slideshow;

procedure disp_table_photo( surl varchar2, pfx in THEME%ROWTYPE, c1rec in SLIDE_MASTER%ROWTYPE, c2rec in SLIDE_DETAILS%ROWTYPE, photo_id in integer, shrink in integer default 1, ltype in varchar2, stype in integer, theme_rec in theme_types%ROWTYPE, qcbground in varchar2 )
as
 cursor c3(photo_id integer) is select umo_id,photo_master from umo where umo_id=photo_id;
 c3rec		c3%ROWTYPE;
 photo_name	varchar2(100);
begin
 htp.p( '<TD valign="MIDDLE" ALIGN="CENTER">' );
  htp.tableopen( cattributes=>'border=' || c1rec.frame_size );
  htp.tablerowopen;
  if photo_id is not null
   then
    open c3( photo_id );
    fetch c3 into c3rec;
    close c3;
    photo_name := ump.uma_attribute( surl,c3rec.umo_id, 'PHOTO', 'NAME' );
    photo_name := nvl(photo_name,ump.uma_attribute( surl,c3rec.umo_id, 'PHOTO', 'FILM_NAME' ));
    if c3rec.photo_master.width > c3rec.photo_master.height
    then
     photo_name := ump.uma_attribute( surl,c3rec.umo_id, 'PHOTO', 'NAME' );
     photo_name := nvl(photo_name,ump.uma_attribute( surl,c3rec.umo_id, 'PHOTO', 'FILM_NAME' ));
     if (ltype = 'PHOTOGRAPHER') or
        (ltype is null) or
        (substr(theme_rec.theme_data,29,1) = 'F' and ltype in ('OWNER','PROFILE')) or
        (substr(theme_rec.theme_data,41,1) = 'F' and ltype in ('CUSTOMER','PROFILEG'))
      then
       htp.p( '<TD ' || qcbground || ' valign="MIDDLE" ALIGN="CENTER">' );
        glbx.image_matte(pfx,round(c3rec.photo_master.width / shrink),round(c3rec.photo_master.height / shrink),
                         trg=>null,
                         trgdisp=>'<IMG BORDER=0 WIDTH=' || to_char(round(c3rec.photo_master.width / shrink)) || ' SRC="' ||
                         'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || photo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&PARM1=AID&PARM2=' || c1rec.aid  ||
  	                 '" ALT="' || photo_name || '" STYLE="display:block;">',
  	                 ctarget=>null);
       htp.p( '</TD>');

      else
       htp.p( '<TD ' || qcbground || ' valign="MIDDLE" ALIGN="CENTER">' );
        glbx.image_matte(pfx,round(c3rec.photo_master.width / shrink),round(c3rec.photo_master.height / shrink),
                      trg=>'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p1=0&p0=0&pa=0&pb=0&pc=0&ppn=&p1=' || photo_id || '&p0=' || photo_id || '&ADD_TO_TROLLEY=Order+Photos&footer_api=&left_api_parm=&current_page_number=&display_detail=&acid=',
                      trgdisp=>'<IMG BORDER=0 WIDTH=' || to_char(round(c3rec.photo_master.width / shrink)) || ' SRC="' ||
                      'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || photo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&PARM1=AID&PARM2=' || c1rec.aid  ||
  	              '" ALT="' || LNG.SLD_TXT_047 || '" STYLE="display:block;">',
  	              ctarget=>null);
       htp.p( '</TD>');

     end if;
    else
     if (ltype = 'PHOTOGRAPHER') or
        (ltype is null) or
        (substr(theme_rec.theme_data,29,1) = 'F' and ltype = 'OWNER') or
        (substr(theme_rec.theme_data,41,1) = 'F' and ltype = 'CUSTOMER')
      then
       htp.p( '<TD ' || qcbground || ' valign="MIDDLE" ALIGN="CENTER">' );
        glbx.image_matte(pfx,round(c3rec.photo_master.width / shrink),round(c3rec.photo_master.height / shrink),
                      null,
                      '<IMG BORDER=0 HEIGHT=' || to_char(round(c3rec.photo_master.height / shrink)) || ' SRC="' ||
                      'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || photo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&PARM1=AID&PARM2=' || c1rec.aid  ||
  	              '" ALT="' || photo_name || '" STYLE="display:block;">',ctarget=>null);
       htp.p( '</TD>');
      else
       htp.p( '<TD ' || qcbground || ' valign="MIDDLE" ALIGN="CENTER">' );
        glbx.image_matte(pfx,round(c3rec.photo_master.width / shrink),round(c3rec.photo_master.height / shrink),
                      'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p1=0&p0=0&pa=0&pb=0&pc=0&ppn=&p1=' || photo_id || '&p0=' || photo_id || '&ADD_TO_TROLLEY=Order+Photos&footer_api=&left_api_parm=&current_page_number=&display_detail=&acid=',
                      '<IMG BORDER=0 HEIGHT=' || to_char(round(c3rec.photo_master.height / shrink)) || ' SRC="' ||
                      'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || photo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&PARM1=AID&PARM2=' || c1rec.aid  ||
  	              '" ALT="' || LNG.SLD_TXT_047 || '" STYLE="display:block;">',ctarget=>null);
       htp.p( '</TD>');
     end if;
   end if;
   end if;
  htp.tablerowclose;
  htp.tableclose;
 htp.p( '</TD>' );
exception when others then
 glbx.error_details( 'SLD', 'DISP_TABLE_PHOTO',vaid=>c1rec.aid,errmsg=>sqlerrm,extdet=>' SLID: ' || c1rec.sid || ' SNMBR:' || c2rec.slide_nmbr || ' PHOTO_ID:' || photo_id || ' STYPE:' || stype);
end disp_table_photo;

procedure cust_slideshow(surl varchar2)
is

 cursor c1(acid integer) is  select * from customer_account where aid = acid;
 cursor c1p(profid integer) is  select * from customer_profile where profile_id = profid;
 cursor c2(acid integer) is select count('x') tot from slide_master where aid=acid;
 cursor c3(acid integer) is select sid,slideshow_name from slide_master where aid=acid order by sid;

 c1rec		c1%ROWTYPE;
 c1prec		c1p%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.CUST_SLIDESHOW' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if ltype = 'VIRTUAL' then ltype := 'CUSTOMER'; end if;
 open c2( owner_id );
 fetch c2 into c2rec;
 close c2;
 if nvl(c2rec.tot,0) = 1
  then
   open c3( owner_id );
   fetch c3 into c3rec;
   close c3;
   display_slide( surl,null, c3rec.sid, 1 );
   return;
 end if;
 if ltype in ('PROFILE','PROFILEG')
  then
   open c1p(owner_id);
   fetch c1p into c1prec;
   close c1p;
   open c1(c1prec.aid);
   fetch c1 into c1rec;
   close c1;
   c1rec := glbx.conv_account(c1prec,c1rec);
  else
   open c1(owner_id);
   fetch c1 into c1rec;
   close c1;
 end if;

 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.SLD_TXT_048,glbx.backimg(surl,owner_id,pfx.text_back,c1rec.background_img,ltype),helpid=>'S09',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, excolour=>pfx.caption_text_colour, exfont=>pfx.caption_text_font,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>' );
 htp.bold( htf.italic( LNG.SLD_TXT_049 ));
 htp.nl;
 htp.nl;
 htp.tableopen( cattributes=>' border="0"');
 for c3rec in c3(c1rec.aid) loop
  htp.tablerowopen;
   htp.tabledata(htf.anchor( 'sld.display_slide?surl=' || glbx.rndsurl(surl) || '&acid=&slid=' || c3rec.sid || '&snmbr=1', htf.img( DECS.IMAGE_LOCATION || 'admin/slideshow.gif',cattributes=>'BORDER="0"') ));
   htp.tabledata(htf.anchor( 'sld.display_slide?surl=' || glbx.rndsurl(surl) || '&acid=&slid=' || c3rec.sid || '&snmbr=1', c3rec.slideshow_name ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="CENTER"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'SLD', 'CUST_SLIDESHOW',vaid=>owner_id,errmsg=>sqlerrm);
end cust_slideshow;

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

procedure sld_bac( surl varchar2,slid in integer, msg in varchar2 default null )
as
 cursor c1(acid integer, slid integer) is
   select um.umo_id, um.photo_master
   from slide_master sm, umo um
   where sm.aid = acid and
         sm.sid = slid and
         sm.background_gif = um.umo_id and
         um.umo_type = 'SLIDE';
 cursor c2(slid integer, phgid integer) is
  select aid from slide_master where sid = slid and aid in (select aid from customer_account where pid = phgid);
 cursor c3(owner_id integer) is select aid from customer_account where pid = owner_id;
 acid		integer;
 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		varchar2(2000);
 foundrec	boolean;
begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'SLD.SLD_BAC' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c3(owner_id);
 fetch c3 into acid;
 close c3;
 pfx := glbx.get_thm( acid );
 open c2(slid,owner_id);
 fetch c2 into acid;
 close c2;
 if acid is null then return; end if; -- Invalid SID for this user
 open c1( acid, slid );
 fetch c1 into c1rec;
 foundrec := c1%FOUND;
 close c1;
 glbx.main_title( surl, LNG.SLD_TXT_050,glbx.backimg(surl,acid,pfx.text_back,c1rec.umo_id,ltype),helpid=>'S10',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null then glbx.header_msg( msg );end if;
 htp.italic( LNG.SLD_TXT_075); htp.nl;
 htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'phg.lload', cattributes=>'enctype="multipart/form-data" accept="image/gif,image/jpeg,image/tiff"' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'IMGTYPE', 'SLIDE' );
 htp.formhidden( 'P1', slid );
 htp.formhidden( 'P2', null );
 htp.formhidden( 'P3', null );
 htp.formhidden( 'P4', null );
 htp.tableopen;
  htp.tablerowopen;
   if foundrec
    then
	 htp.tabledata( '<IMG BORDER=2 SRC=' ||
                        'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' ||
                        '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&PARM1=AID&PARM2=' || acid || ' ' ||
                        'ALT="' || LNG.PHG_TXT_015 || '" STYLE="display:block;">' );
    else
	 htp.tabledata( htf.bold(LNG.SLD_TXT_076),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
   end if;
 htp.tablerowclose;
 htp.tablerowopen;
   htp.tabledata( GLBX.UPLOAD_NAME,cattributes=>pfx.qcbground );
 htp.tablerowclose;
 htp.tableclose;

 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_024),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( nvl(htf.bold(c1rec.photo_master.mimetype),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_025),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( nvl(htf.bold(c1rec.photo_master.contentlength),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, LNG.SLD_TXT_080 ) || htf.formclose );
   htp.tabledata( htf.formopen( 'sld.slide_main' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) || htf.formhidden( 'SLID', slid ) || htf.formhidden( 'MSG', LNG.SLD_TXT_081 ) ||
                  htf.formsubmit( null, LNG.SLD_TXT_082 ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'SLD', 'SLD_BAC',owner_id,acid,errmsg=>sqlerrm,extdet=>msg);
end sld_bac;

function is_owner( surl varchar2, ltype in varchar2, owner_id in integer, acid in integer )
 return boolean
as
begin
 if ltype = 'PHOTOGRAPHER' then return( TRUE ); end if;
 if ltype <> 'OWNER' then return( FALSE ); end if;
 return( owner_id = acid );
exception when others then
 glbx.error_details( 'SLD', 'IS_OWNER',owner_id,acid,errmsg=>sqlerrm,extdet=>'LTYPE:' || ltype || ' OWNER_ID:' || owner_id || ' ACID:' || acid);
end is_owner;

procedure slideshow_category(surl in varchar2, uscid in varchar2, dispstyle in varchar2, codes in varchar2 default null, currcode in varchar2 default null, acid in integer, ttl in varchar2 default null )
is

 cursor c1x(acid integer, uscid integer, utype varchar2, sess_id integer, exc number, exc_max number) is
   select umo_id
   from umo um
   where um.umo_scene_id = uscid and
         um.aid = acid and
         ( (exclusive_purchased = 'F') or
           (date_created + exc <= sysdate and exclusive_purchased = 'T' )
         ) and
        ((um.sessid is null or utype = 'PHOTOGRAPHER') or (um.sessid is not null and sessid = sess_id)) and
         umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
         ((utype = 'PHOTOGRAPHER') or
          (utype = 'OWNER' and um.extras.enabled_phg='TRUE') or
          (utype = 'CUSTOMER' and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE')) and
        rownum < 1000
   order by um.sort_priority,um.extras.orderby_nmb,um.umo_id;

 cursor c1y(profid integer, acid integer, uscid integer, utype varchar2, sess_id integer, exc number, exc_max number) is
   select umo_id
   from umo um
   where um.umo_scene_id = uscid and
         ( (exclusive_purchased = 'F') or
           (date_created + exc <= sysdate and exclusive_purchased = 'T' )
         ) and
         (um.umo_scene_id in (select umo_scene_id from profile_scenes where profile_id = profid) or
         0 = (select count('x') tot from profile_scenes where profile_id = profid)
         ) and
         ((um.sessid is null or utype = 'PHOTOGRAPHER') or (um.sessid is not null and sessid = sess_id)) and
         umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
         um.aid = acid and
         ((utype = 'PROFILE' and um.extras.enabled_phg='TRUE') or
          (utype = 'PROFILEG' and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE')) and
        rownum < 1000
   order by um.sort_priority,um.extras.orderby_nmb,um.umo_id;

 cursor c1a(phgid integer) is select * from photographer where pid = phgid;

 cursor c2(acid integer, phgr integer, imgtype varchar2) is
   select um.photo_master, um.umo_id, um.version, 'J' typ, um.extras.orderby_nmb orderby_nmb, attribute1, attribute2
   from umo um, customer_account ca
   where um.aid = acid and
         um.aid = ca.aid and
         ca.pid = phgr and
         um.is_global = 'F' and
         umo_type = imgtype
   union all
   select um.photo_master, um.umo_id, um.version, 'K' typ, um.extras.orderby_nmb orderby_nmb, attribute1, attribute2
   from umo um, customer_account ca
   where um.aid = ca.aid and
         ca.pid = phgr and
         um.is_global = 'T' and
         umo_type = imgtype
   order by 4,5;

 cursor c3(uscid integer) is select title from umo_scene where umo_scene_id = uscid;

 cursor c_umo(v_umo integer) is select * from umo where umo_id = v_umo;

 cursor c6(acid integer, sess_id integer,voidrec_spb integer) is
  select (nvl(decode(nvl(ls.country,pp.value),pp.value,ppi.exclusive_local,ppi.exclusive_int),0) * 60) / (86500) exc,
  greatest(nvl(ppi.exclusive_local,0),nvl(ppi.exclusive_int,0)) exc_max
  from
   login_session ls, phg_price_item ppi,phg_price_book ppb, photographer_preference pp
  where ppi.spb = voidrec_spb and
        ppb.spb = ppi.spb and
        pp.prefid = 43 and
        pp.aid = acid and
        ls.sessid = sess_id;

 cusrec		customer_account%ROWTYPE;
 umrec		c_umo%ROWTYPE;
 c1arec		c1a%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c6rec		c6%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 b2c_value	char(1);
 codelist	varchar2(32767);
 ccode		integer;
 width		integer;
 height		integer;
 val		integer;
 nwidth		integer;
 nheight	integer;
 nxt		integer;
 prv		integer;
 frst		integer;
 x		integer;
 y		integer;
 adj		number;
 dbool		boolean;
 v_uscid	varchar2(20);
 url		varchar2(1000);
 hsite		varchar2(1000);
 http		varchar2(1000);
 tmp		varchar2(1000);
 jscript	varchar2(1000);
 jscript_close	varchar2(1000);
 empty_array	GLBX.MYARRAY;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'SLD.CUST_SLIDESHOW' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );

 open c1a( cusrec.pid );
 fetch c1a into c1arec;
 close c1a;

 if dispstyle = 'FRAME'
  then
   if substr(uscid,1,1) = '['
    then
     v_uscid := substr(uscid,2,instr(uscid,']')-2);
    else
     v_uscid := uscid;
   end if;
   htp.htmlopen;

    if pfx.icra_label is not null then htp.p( '<HEAD>' || pfx.icra_label || htf.title( 'Category Slideshow' ) || '</HEAD>' ); end if;
    htp.framesetopen('10%,80%,10%','*',cattributes=>'frameborder="NO" framespacing="0" border=0"');
     htp.frame( 'sld.slideshow_category?surl=' || glbx.rndsurl(surl) || '&uscid=' || v_uscid || '&dispstyle=TOP&acid=' || acid || '&ttl=' || replace(ttl,' ','+'),'SLIDESHOW_CATEGORY_TOP', cattributes=>'scrolling=NO frameborder="NO" noresize marginwidth="0" marginheight="0"');
     htp.frame( 'sld.slideshow_category?surl=' || glbx.rndsurl(surl) || '&uscid=' || v_uscid || '&dispstyle=MIDDLE&acid=' || acid || '&currcode=' || currcode || '&codes=' || codes,'SLIDESHOW_CATEGORY_MIDDLE', cattributes=>'scrolling=NO frameborder="NO" noresize marginwidth="0" marginheight="0"');
     htp.frame( 'sld.slideshow_category?surl=' || glbx.rndsurl(surl) || '&uscid=' || v_uscid || '&dispstyle=BOTTOM&acid=' || acid,'SLIDESHOW_CATEGORY_BOTTOM', cattributes=>'scrolling=NO frameborder="NO" noresize marginwidth="0" marginheight="0"');
    htp.framesetclose;
    htp.p( '<BODY>' );
    htp.noframesopen;
     glbx.noframe(surl,'SLD.SLIDESHOW_CATEGORY');
    htp.noframesclose;
   htp.p( '</BODY>' );
  htp.htmlclose;
   return;

 elsif dispstyle = 'SETUP'
  then
    open c6(cusrec.aid,owner_id,voidrec.spb);
    fetch c6 into c6rec;
    close c6;
    if ltype in ('PROFILE','PROFILEG')
     then
      for c1rec in c1y(profid,cusrec.aid,uscid,ltype,owner_id,c6rec.exc,c6rec.exc_max) loop
       if c1y%ROWCOUNT = 1 then ccode := c1rec.umo_id; end if;
       codelist := codelist || ';' || c1rec.umo_id;
      end loop;
     else
      for c1rec in c1x(cusrec.aid,uscid,ltype,owner_id,c6rec.exc,c6rec.exc_max) loop
       if c1x%ROWCOUNT = 1 then ccode := c1rec.umo_id; end if;
       codelist := codelist || ';' || c1rec.umo_id;
      end loop;
    end if;
    slideshow_category(surl, uscid, 'FRAME', codelist || ';', ccode, acid );
    return;

 elsif dispstyle = 'TOP'
  then
   open c3(uscid);
   fetch c3 into c3rec;
   close c3;
   -- Note: Hardcoded style is Left Hand Frame
   glbx.main_title( surl, null,null,stype=>stype,sstyle=>pfx.top_text_font,sclr=>pfx.top_text_colour,lnk=>pfx.underline_active,det_sstyle=>pfx.top_text_font,det_sclr=>pfx.top_text_colour,hover=>pfx.hover_colour, disptop=>'L', finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
   htp.p( '<CENTER>' );
   htp.tableopen( cattributes=>'width="100%" cellspacing=0 cellpadding=0 border=0' );
   htp.tablerowopen;
      htp.tabledata( nvl(ttl,c3rec.title),cattributes=>'bgcolor="#' || pfx.top_back || '"' || 'valign="TOP" align="CENTER"' );
      htp.tabledata( '<a href="" onClick="parent.close()">' || htf.img( DECS.IMAGE_LOCATION || 'admin/close.gif',cattributes=>'border=0',calt=>LNG.GLB_TXT_033 ) || '</a>',cattributes=>'bgcolor="#' || pfx.top_back || '" valign="TOP" align="RIGHT"' );
   htp.tablerowclose;
   htp.tableclose;
   htp.p( '</CENTER>' );
   htp.htmlclose;

 elsif dispstyle = 'BOTTOM'
  then
   -- Note: Hardcoded style is Left Hand Frame
   glbx.main_title( surl, null,null,stype=>stype,sstyle=>pfx.top_text_font,sclr=>pfx.top_text_colour,lnk=>pfx.underline_active,det_sstyle=>pfx.top_text_font,det_sclr=>pfx.top_text_colour,hover=>pfx.hover_colour, disptop=>'L', finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
   htp.p( '<CENTER>' );
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
   htp.tablerowopen;
     for c2rec in c2( cusrec.aid, cusrec.pid, 'ICON' ) loop
       hsite := NULL;
       http := ump.uma_attribute( surl,c2rec.umo_id, 'ICON', 'HTTP_LINK' );
       if http is null then hsite := c1arec.home_site; else hsite := http; end if;
       hsite := glbx.adjust_for_http( hsite );
       if nvl(c2rec.attribute1,'F') = 'T' or
          nvl(c2rec.attribute2,'F') = 'T'
        then
         hsite := 'cst.intercept_icon?surl=' || surl || '&v_umo=' || c2rec.umo_id;
       end if;
       width := to_number(ump.uma_attribute( surl, c2rec.umo_id, 'ICON', 'DISPLAY_WIDTH' ));
       height := to_number(ump.uma_attribute( surl, c2rec.umo_id, 'ICON', 'DISPLAY_HEIGHT' ));
       if hsite is null
         then
          htp.tabledata('<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' SRC="' ||
              'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' ||
              '&parm1=LOGIN_TYPE&parm2=' || ltype ||
              '&parm1=OVERRIDE_DISPLAY&parm2=ICON&parm1=AID&parm2=' ||
              '" ALT="' || c1arec.business_name || '" STYLE="display:block;">');
       else
        htp.tabledata(htf.anchor2( hsite,'<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' SRC="' ||
              'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' ||
              '&parm1=LOGIN_TYPE&parm2=' || ltype ||
              '&parm1=OVERRIDE_DISPLAY&parm2=ICON&parm1=AID&parm2=' ||
              '" ALT="' || nvl(http,c1arec.home_site) || '" STYLE="display:block;">',ctarget=>'_top' ));
       end if;
     end loop;
    htp.tablerowclose;
    htp.tableclose;
    htp.p( '</CENTER>' );
    htp.htmlclose;

 elsif dispstyle = 'MIDDLE'
  then
    val := currcode;
    open c_umo( val );
    fetch c_umo into umrec;
    close c_umo;
    tmp := nvl(umrec.image_caption,LNG.CST_TXT_183 || ' -' || umrec.extras.photo_name);
    glbx.main_title( surl, NULL, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>'L', finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.tableopen;
     htp.tablerowopen;
     htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' );
     url := 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umrec.version;
     nwidth := umrec.photo_master.width;
     nheight := umrec.photo_master.height;
     if nwidth > nheight
     then nwidth := 400; adj := umrec.photo_master.width / umrec.photo_master.height; nheight := round(400/adj);
     else nheight := 300; adj := umrec.photo_master.height / umrec.photo_master.width; nwidth := round(300/adj);
     end if;

     if ltype = 'PHOTOGRAPHER'
      then
       glbx.image_matte(pfx,nwidth,nheight,
                        url,
                        '<IMG BORDER=0 WIDTH=' || nwidth || ' HEIGHT=' || nheight || ' SRC="' ||
                        'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || acid || '&parm1=VERSION&parm2=' || umrec.version ||
                        '" ALT="' || tmp || '" STYLE="display:block;">',null );
      else
       if pfx.fullimg_jscript_popup = 'F'
        then
         glbx.image_matte(pfx,nwidth,nheight,
                          url,
                          '<IMG BORDER=0 WIDTH=' || nwidth || ' HEIGHT=' || nheight || ' SRC="' ||
                          'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umrec.version ||
                          '" ALT="' || tmp || '" STYLE="display:block;">',null );
        else
         --
         url := 'javascript: window.open(''' || url || ''',''' || replace(LNG5.EXT_TXT_037,' ','_') ||
                ''',''height=' || to_char(nvl(nheight,0) + pfx.fullimg_popup_height) ||
                ',width=' || to_char(nvl(nwidth,0) + pfx.fullimg_popup_width) || ',scrollbars=no,resizable=yes'');void('''');';
         glbx.image_matte(pfx,nwidth,nheight,
                          url,
                          '<IMG BORDER=0 WIDTH=' || nwidth || ' HEIGHT=' || nheight || ' SRC="' ||
                          'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umrec.version ||
                          '" ALT="' || tmp || '" STYLE="display:block;">',null );
       end if;
     end if;
     htp.p( '</TD>' );
     htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' );
       htp.tableopen( cattributes=>'width="100%" cellpadding=2 cellspacing=0 rules="NONE" frame="HSIDES,VSIDES" border=1' );
        htp.tablerowopen;
         htp.p( '<TD>' );
         htp.bold( umrec.extras.photo_name );
         htp.nl;
         htp.nl;
         if umrec.image_caption is not null
          then
           htp.p( umrec.image_caption );
         end if;
         -- Display Meta Tags
         if is_bf(theme_rec,ltype,257,258,'T','T',280,'T')
          then
           htp.nl;
           dbool := glbx.disp_mt( surl, ltype, umrec.umo_id, umrec.umo_type, substr(theme_rec.theme_data,167,1), pfx, acid, empty_array, FALSE, TRUE );
         end if;
         htp.p( '<TD>' );
        htp.tablerowclose;
       htp.tableclose;
       htp.tableopen( cattributes=>'width="100%" cellpadding=2 cellspacing=0 border=0' );
        htp.tablerowopen;
         htp.p( '<TD>' );
         htp.p( 'Navigate' || ' : ' );
         x := instr(codes,';',1,2);
         frst := substr(codes,2,x-2);

         x := instr(codes,';' || currcode || ';' );
         if x = 1
          then
           x := length(codes);
         end if;
         y := x;
         loop
          y := y - 1;
          exit when substr(codes,y,1) = ';' or y <= 0;
         end loop;
         prv := substr(codes,y + 1, (x-y)-1);

         x := instr(codes,';' || currcode || ';' );
         y := x;
         loop
          y := y + 1;
          exit when substr(codes,y,1) = ';' or y > 32000 or y > length(codes);
         end loop;
         x := y;
         loop
          y := y + 1;
          exit when substr(codes,y,1) = ';' or y > 32000 or y > length(codes);
         end loop;
         if y > length(codes) then nxt := frst; else nxt := substr(codes,x + 1, (y-x)-1); end if;

         htp.anchor( 'sld.slideshow_category?surl=' || glbx.rndsurl(surl) || '&uscid=' || uscid || '&dispstyle=MIDDLE&acid=' || acid || '&currcode=' || prv || '&codes=' || codes,htf.img( DECS.IMAGE_LOCATION || 'adminc/previous.gif',cattributes=>'border=0',calt=>LNG5.EXT_TXT_347 ) );
         htp.anchor( 'sld.slideshow_category?surl=' || glbx.rndsurl(surl) || '&uscid=' || uscid || '&dispstyle=MIDDLE&acid=' || acid || '&currcode=' || frst || '&codes=' || codes,htf.img( DECS.IMAGE_LOCATION || 'adminc/refresh.gif',cattributes=>'border=0',calt=>LNG5.EXT_TXT_348 ) );
         htp.anchor( 'sld.slideshow_category?surl=' || glbx.rndsurl(surl) || '&uscid=' || uscid || '&dispstyle=MIDDLE&acid=' || acid || '&currcode=' || nxt || '&codes=' || codes,htf.img( DECS.IMAGE_LOCATION || 'adminc/next.gif',cattributes=>'border=0',calt=>LNG5.EXT_TXT_349 ) );
         if is_bf(theme_rec,ltype,205,206,'T','T',267,'T')
          then
           htp.p( ' ' );
           jscript := 'javascript: parent.opener.location = ''';
           jscript_close := '''; parent.close();';
           htp.anchor(  jscript || 'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=0&p1=0&pa=0&pb=0&pc=0&ppn=&p1=' || currcode || '&add_to_trolley=Order+Photos' || '&footer_api=SLIDESHOW_CATEGORY&left_api_parm=&current_page_number=&display_detail=&acid=' || acid || jscript_close,htf.img( cust_button(pfx,'sml_a.gif',6),cattributes=>'border=0',calt=>lng.CST_TXT_065 ));
         end if;
         htp.p( '<TD>' );

        htp.tablerowclose;
       htp.tableclose;
     htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;
    htp.htmlclose;

 end if;
exception when others then
 glbx.error_details( 'SLD', 'SLIDESHOW_CATEGORY',owner_id,acid,errmsg=>sqlerrm,extdet=>'LTYPE:' || ltype || ' OWNER_ID:' || cusrec.aid || ' ACID:' || acid);
end slideshow_category;

end sld;

/
