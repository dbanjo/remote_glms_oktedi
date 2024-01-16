CREATE OR REPLACE package body WEBSYS.lf
as

WIN_CTR 		INTEGER;

procedure mnt_icons( surl in varchar2, pfx in THEME%ROWTYPE, disp in varchar2 );
procedure scont( surl in varchar2, pfx in THEME%ROWTYPE );
function new_window return varchar2;

function new_window
 return varchar2
as
begin
 WIN_CTR := nvl(WIN_CTR,0) + 1;
 return( 'ADMIN_' || to_char(sysdate,'SSSSS') || to_char(WIN_CTR));
end new_window;

procedure theme_left(surl varchar2)
as
 cursor c1 is select theme_name,disp_prefix,keep_lhf,theme_descript from theme order by upper(theme_name);
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'LF.THEME_LEFT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 adm.main_title( surl, sessid, LNG3.ADM_TXT_185, helpid=>'A26' );
 htp.p('<CENTER>');
 htp.nl;
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('lf.mnt_themes?surl=' || glbx.rndsurl(surl) || '&msg=' || translate( LNG3.ADM_TXT_186,' ','+'),LNG3.ADM_TXT_187,ctarget=>'ADM_THEME'),cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG3.ADM_TXT_088),cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold(LNG3.ADM_TXT_191),cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold(LNG3.ADM_TXT_815),cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold(LNG3.ADM_TXT_105),cattributes=>glbx.QUERY_BACKGROUND );
  htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( htf.anchor2( 'lf.mnt_themes?surl=' || glbx.rndsurl(surl) || '&thm=' || translate( c1rec.theme_name,' ','+'),c1rec.theme_name,ctarget=>new_window),cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tabledata( c1rec.disp_prefix,cattributes=>glbx.QUERY_CELL_BACKGROUND );
   if c1rec.keep_lhf = 'L'
    then
      htp.tabledata( LNG3.ADM_TXT_805,cattributes=>glbx.QUERY_CELL_BACKGROUND );
   elsif c1rec.keep_lhf = 'R'
    then
      htp.tabledata( LNG3.ADM_TXT_806,cattributes=>glbx.QUERY_CELL_BACKGROUND );
   elsif c1rec.keep_lhf = '2'
    then
      htp.tabledata( LNG3.ADM_TXT_804,cattributes=>glbx.QUERY_CELL_BACKGROUND );
   elsif c1rec.keep_lhf = 'N'
    then
      htp.tabledata( LNG3.ADM_TXT_803,cattributes=>glbx.QUERY_CELL_BACKGROUND );
   end if;
   htp.tabledata( nvl(c1rec.theme_descript,'&nbsp;'),cattributes=>glbx.QUERY_CELL_BACKGROUND );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LF', 'THEME_LEFT', errmsg=>sqlerrm, extdet=>null);
end theme_left;

procedure mnt_themes( surl varchar2, thm in varchar2 default null, msg in varchar2 default null )
as

 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.MNT_THEMES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
  htp.htmlopen;
  htp.p( '<HEAD>' );
  htp.title( glbx.extract_master_parameter('MENU_TITLE') );
  htp.p( '</HEAD>' );
  htp.framesetopen('100%','20%,80%',cattributes=>'frameborder="1" framespacing="0" border="1"');
   htp.frame( 'lf.theme_options?surl=' || glbx.rndsurl(surl) || '&thm=' || translate(thm,' ','+') || '&msg=' || translate( msg,' ','+'),'ADM_THEME_LEFT');
   if thm is null
    then
     htp.frame( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=SHAPE&thm=' || translate(thm,' ','+') || '&msg=' || translate( msg,' ','+'),'ADM_THEME_RIGHT');
    else
     htp.frame( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=ICONS_STND&thm=' || translate(thm,' ','+') || '&msg=' || translate( msg,' ','+'),'ADM_THEME_RIGHT');
   end if;
  htp.framesetclose;
  htp.p( '<BODY>' );
  htp.noframesopen;
   glbx.noframe(surl,'lf.MNT_THEMES');
  htp.noframesclose;
  htp.p( '</BODY>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'LF', 'MNT_THEMES', errmsg=>sqlerrm, extdet=>null);
end mnt_themes;

procedure theme_options( surl varchar2, thm in varchar2, msg in varchar2 default null )
as

 cursor c1(thm varchar2) is select * from theme where theme_name = thm;

 c1rec	c1%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.THEME_OPTIONS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 open c1(thm);
 fetch c1 into c1rec;
 close c1;
 adm.main_title( surl, sessid, LNG.LAB_TXT_001, style=>'NOMENU' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=SHAPE&thm=' || translate(thm,' ','+'), LNG4.AHC_TXT_325, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 if thm is not null
 then
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=NOFRAME&thm=' || translate(thm,' ','+'), LNG4.AHC_TXT_855, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=INSTRUCTION&thm=' || translate(thm,' ','+'), LNG3.ADM_TXT_566, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=THUMBNAIL&thm=' || translate(thm,' ','+'), LNG4.AHC_TXT_954, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=VERT&thm=' || translate(thm,' ','+'), LNG4.AHC_TXT_389, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.line;
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=STANDARD&thm=' || translate(thm,' ','+'), LNG4.AHC_TXT_332, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=MATTE&thm=' || translate(thm,' ','+'), LNG4.AHC_TXT_326, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=FULLIMG&thm=' || translate(thm,' ','+'), LNG5.EXT_TXT_037, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=TABLE&thm=' || translate(thm,' ','+'), LNG4.AHC_TXT_953, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=SEARCH&thm=' || translate(thm,' ','+'), LNG.GLB_TXT_092, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=SCREENSIZE&thm=' || translate(thm,' ','+'), 'Screen Size Options', ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.line;
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=TITLE&thm=' || translate(thm,' ','+'), LNG4.AHC_TXT_329, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=LHF&thm=' || translate(thm,' ','+'), LNG4.AHC_TXT_333, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=ORDER&thm=' || translate(thm,' ','+'), LNG5.EXT_TXT_145, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=HOME&thm=' || translate(thm,' ','+'), LNG4.AHC_TXT_327, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=CUSTOMER&thm=' || translate(thm,' ','+'), LNG4.AHC_TXT_334, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=GALLERY&thm=' || translate(thm,' ','+'), LNG.CST_TXT_225, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.line;
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=META&thm=' || translate(thm,' ','+'), LNG4.AHC_TXT_392, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=API&thm=' || translate(thm,' ','+'), LNG5.EXT_TXT_023, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=ERROR&thm=' || translate(thm,' ','+'), LNG3.ADM_TXT_091, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=NESTED&thm=' || translate(thm,' ','+'), LNG3.ADM_TXT_574, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=SECURITY&thm=' || translate(thm,' ','+'), LNG2.PFM_TXT_153, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.line;
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=ICONS_STND&thm=' || translate(thm,' ','+'), LNG4.AHC_TXT_330, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=ICONS_CUST&thm=' || translate(thm,' ','+'), LNG4.AHC_TXT_399, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=ICONS_ALL&thm=' || translate(thm,' ','+'), LNG4.AHC_TXT_331, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.colour_palette?surl=' || glbx.rndsurl(surl) || '&close_window=F', LNG3.ADM_TXT_821, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.repall?surl=' || surl || '&tname=' || replace(thm,' ','+'), LNG3.ADM_TXT_687, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 htp.anchor2( 'lf.theme_right?surl=' || glbx.rndsurl(surl) || '&disp=UTILITIES&thm=' || translate(thm,' ','+'), LNG.PHG_TXT_352, ctarget=>'ADM_THEME_RIGHT' );
 htp.nl;
 end if;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LF', 'THEME_OPTIONS', errmsg=>sqlerrm, extdet=>'THM:' || thm);
end theme_options;

procedure disp_c3(surl varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 default null )
 as
  cursor c3 is select clr_name,clr_hex from colours order by clr_name;
  tmp		varchar2(10000);
  c_one		varchar2(20);
  foundrec	boolean;

 begin
   if p4 is not null
    then
     tmp := htf.formselectopen( 'P2' );
    else
     tmp := htf.formselectopen(p1);
   end if;
   foundrec := FALSE;
   tmp := tmp || htf.formselectoption( NULL );
   for c3rec in c3 loop
    if c3%ROWCOUNT = 1 then c_one := c3rec.clr_hex; end if;
    if c3rec.clr_hex = p2
     then
      foundrec := TRUE;
      if p4 is null
       then
        tmp := tmp || htf.formselectoption( c3rec.clr_name, 'SELECTED' );
       else
        tmp := tmp || htf.formselectoption( c3rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c3rec.clr_hex || '"' );
      end if;
     else
      if p4 is null
       then
        tmp := tmp || htf.formselectoption( c3rec.clr_name );
       else
        tmp := tmp || htf.formselectoption( c3rec.clr_name, cattributes=>'VALUE="' || c3rec.clr_hex || '"' );
      end if;
    end if;
    end loop;
    if not foundrec -- Colour not found, display hex value as colour
     then
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_351 || '-' || p2, 'SELECTED', cattributes=>'VALUE="' || p2 || '"' );
    end if;
    tmp := tmp || htf.formselectclose;
    htp.tablerowopen;
      htp.tabledata(htf.bold( p3 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      if p4 is not null then htp.formhidden( p4, p1 ); end if;
      htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',cattributes=>'bgcolor="#' || nvl(p2,c_one) || '"');
    htp.tablerowclose;
exception when others then
 glbx.error_details( 'LF', 'DISP_C3', errmsg=>sqlerrm, extdet=>null);
end disp_c3;

procedure colour_palette( surl varchar2, close_window in varchar2 default 'T' )
as

 cursor c1 is select clrid, clr_name, clr_hex from colours order by clr_name;

 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.COLOUR_PALETTE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 adm.main_title( surl, sessid, LNG3.ADM_TXT_821 , style=>'NOMENU', helpid=>'A64' );
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 for c1rec in c1 loop
  if mod(c1%ROWCOUNT,4) = 1
   then
    htp.tablerowclose;
    htp.tablerowopen;
  end if;
  htp.tabledata( htf.bold( c1rec.clr_name ) || htf.nl || htf.italic( c1rec.clr_hex ));
  htp.tabledata( '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;', cattributes=>'bgcolor="#' || c1rec.clr_hex || '"' );
 end loop;
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.p( '<TD>' );
    htp.formopen( 'lf.colour_palette_edit' );
     htp.formhidden( 'SURL', surl );
     htp.formhidden( 'ACTION', 'DELETE' );
     htp.formselectopen( 'P1' );
     for c1rec in c1 loop
      htp.formselectoption( c1rec.clr_name, cattributes=>'VALUE="' || c1rec.clrid || '"' );
     end loop;
     htp.formselectclose;
     htp.formsubmit( null, LNG3.ADM_TXT_893 );
    htp.formclose;
   htp.p( '</TD>' );
   htp.p( '<TD>' );
    htp.formopen( 'lf.colour_palette_edit' );
     htp.formhidden( 'SURL', surl );
     htp.formhidden( 'ACTION', 'INSERT' );
     htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG3.ADM_TXT_350) );
       htp.tabledata( htf.formtext( 'P1', 15, 50 ) );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG3.ADM_TXT_895) );
       htp.tabledata( '#' || htf.formtext( 'P2', 10, 20 ) );
      htp.tablerowclose;
     htp.tableclose;
     htp.formsubmit( null, LNG3.ADM_TXT_894 );
    htp.formclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.nl;
 if close_window = 'T'
  then
   htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
   htp.nl;
 end if;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'LF', 'COLOUR_PALETTE', errmsg=>sqlerrm, extdet=>null);
end colour_palette;

procedure colour_palette_edit( surl varchar2, action in varchar2, p1 in varchar2, p2 in varchar2 default null )
as

 cursor c1 is select max(clrid) + 1 from colours;

 sessid	integer;
 sts	varchar2(200);
 nmb	integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.COLOUR_PALETTE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if action = 'DELETE'
  then
   delete from colours where clrid = to_number(p1);
 elsif action = 'INSERT'
  then
   open c1;
   fetch c1 into nmb;
   close c1;
   insert into colours(clrid,clr_name,clr_hex)
    select nmb,p1,p2
    from dual
     where not exists (select 'x' from colours where clr_name = p1 );
 end if;
 commit;
 colour_palette(surl);
exception when others then
 glbx.error_details( 'LF', 'COLOUR_PALETTE_EDIT', errmsg=>sqlerrm, extdet=>'ACTION:' || action || ' P1:' || p1);
end colour_palette_edit;

procedure theme_right( surl varchar2, thm in varchar2 default null, disp in varchar2 default 'ICONS_STND', msg in varchar2 default null )
as

 cursor c1(thm varchar2) is select * from theme where theme_name=thm;
 cursor c2 is select font_name from fonts order by font_name;
 cursor c3 is select clr_name,clr_hex from colours order by clr_name;
 cursor c4(thm varchar2) is select sum(tot) from
  (select count('x') tot from customer_account where theme_name = thm
   union all
   select count('x') tot from manufacturer where theme_name = thm);

 c1rec	c1%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);
 tmp	varchar2(10000);
 tot	integer;
 chk	varchar2(20);


 procedure disp_c2(surl varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2 )
 as
  tmp	varchar2(10000);
 begin
  tmp := htf.formselectopen( 'P2' );
  for c2rec in c2 loop
   if c2rec.font_name = p2
    then
     tmp := tmp || htf.formselectoption( c2rec.font_name,'SELECTED');
    else
     tmp := tmp || htf.formselectoption( c2rec.font_name);
   end if;
   end loop;
   tmp := tmp || htf.formselectclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( p3 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', p1 );
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata('<FONT FACE=' || p2 || '>' || 'abcdefghijklmnopqrstuvwxyz' || '</FONT>',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end disp_c2;

 procedure dispbutt( val in varchar2, rw in varchar2 )
 as
 begin
  htp.formselectopen( rw );
  htp.formselectoption( NULL );
  if val = 'T'
   then
     htp.formselectoption( LNG.PHG_TXT_345, 'SELECTED', cattributes=>'VALUE="' || 'T' || '"');
   else
     htp.formselectoption( LNG.PHG_TXT_345, cattributes=>'VALUE="' || 'T' || '"');
  end if;
  if val = 'S'
   then
     htp.formselectoption( LNG3.ADM_TXT_810, 'CHECKED', cattributes=>'VALUE="' || 'S' || '"');
   else
     htp.formselectoption( LNG3.ADM_TXT_810, cattributes=>'VALUE="' || 'S' || '"');
  end if;
  if val = 'Q'
   then
     htp.formselectoption( LNG4.AHC_TXT_339, 'CHECKED', cattributes=>'VALUE="' || 'Q' || '"');
   else
     htp.formselectoption( LNG4.AHC_TXT_339, cattributes=>'VALUE="' || 'Q' || '"');
  end if;
  if val = 'I'
   then
     htp.formselectoption( LNG3.ADM_TXT_811, 'CHECKED', cattributes=>'VALUE="' || 'I' || '"');
   else
     htp.formselectoption( LNG3.ADM_TXT_811, cattributes=>'VALUE="' || 'I' || '"');
  end if;
  if val = 'i'
   then
     htp.formselectoption( LNG3.ADM_TXT_811 || '(2 rows)', 'CHECKED', cattributes=>'VALUE="' || 'i' || '"');
   else
     htp.formselectoption( LNG3.ADM_TXT_811 || '(2 rows)', cattributes=>'VALUE="' || 'i' || '"');
  end if;
  if val = 'J'
   then
     htp.formselectoption( LNG4.AHC_TXT_321, 'CHECKED', cattributes=>'VALUE="' || 'J' || '"');
   else
     htp.formselectoption( LNG4.AHC_TXT_321, cattributes=>'VALUE="' || 'J' || '"');
  end if;
  if val = 'j'
   then
     htp.formselectoption( LNG4.AHC_TXT_321 || '(2 rows)', 'CHECKED', cattributes=>'VALUE="' || 'j' || '"');
   else
     htp.formselectoption( LNG4.AHC_TXT_321 || '(2 rows)', cattributes=>'VALUE="' || 'j' || '"');
  end if;
  if val = 'K'
   then
     htp.formselectoption( LNG4.AHC_TXT_322, 'CHECKED', cattributes=>'VALUE="' || 'K' || '"');
   else
     htp.formselectoption( LNG4.AHC_TXT_322, cattributes=>'VALUE="' || 'K' || '"');
  end if;
  if val = 'k'
   then
     htp.formselectoption( LNG4.AHC_TXT_322 || '(2 rows)', 'CHECKED', cattributes=>'VALUE="' || 'k' || '"');
   else
     htp.formselectoption( LNG4.AHC_TXT_322 || '(2 rows)', cattributes=>'VALUE="' || 'k' || '"');
  end if;
  if val = 'L'
   then
     htp.formselectoption( LNG4.AHC_TXT_323, 'CHECKED', cattributes=>'VALUE="' || 'L' || '"');
   else
     htp.formselectoption( LNG4.AHC_TXT_323, cattributes=>'VALUE="' || 'L' || '"');
  end if;
  if val = 'H'
   then
     htp.formselectoption( LNG.GLB_TXT_115, 'CHECKED', cattributes=>'VALUE="' || 'H' || '"');
   else
     htp.formselectoption( LNG.GLB_TXT_115, cattributes=>'VALUE="' || 'H' || '"');
  end if;
  if val = 'A'
   then
     htp.formselectoption( LNG3.ADM_TXT_812, 'CHECKED', cattributes=>'VALUE="' || 'A' || '"');
   else
     htp.formselectoption( LNG3.ADM_TXT_812, cattributes=>'VALUE="' || 'A' || '"');
  end if;
  if val = 'P'
   then
     htp.formselectoption( LNG3.ADM_TXT_813, 'CHECKED', cattributes=>'VALUE="' || 'P' || '"');
   else
     htp.formselectoption( LNG3.ADM_TXT_813, cattributes=>'VALUE="' || 'P' || '"');
  end if;
  if val = 'R'
   then
     htp.formselectoption( LNG4.AHC_TXT_692, 'CHECKED', cattributes=>'VALUE="' || 'R' || '"');
   else
     htp.formselectoption( LNG4.AHC_TXT_692, cattributes=>'VALUE="' || 'R' || '"');
  end if;
  if val = 'B'
   then
     htp.formselectoption( LNG3.ADM_TXT_588, 'CHECKED', cattributes=>'VALUE="' || 'B' || '"');
   else
     htp.formselectoption( LNG3.ADM_TXT_588, cattributes=>'VALUE="' || 'B' || '"');
  end if;
  if val = 'C'
   then
     htp.formselectoption( LNG.CST_TXT_042, 'CHECKED', cattributes=>'VALUE="' || 'C' || '"');
   else
     htp.formselectoption( LNG.CST_TXT_042, cattributes=>'VALUE="' || 'C' || '"');
  end if;
  if val = 'D'
   then
     htp.formselectoption( LNG4.AHC_TXT_463, 'CHECKED', cattributes=>'VALUE="' || 'D' || '"');
   else
     htp.formselectoption( LNG4.AHC_TXT_463, cattributes=>'VALUE="' || 'D' || '"');
  end if;
  if val = 'E'
   then
     htp.formselectoption( LNG4.AHC_TXT_464, 'CHECKED', cattributes=>'VALUE="' || 'E' || '"');
   else
     htp.formselectoption( LNG4.AHC_TXT_464, cattributes=>'VALUE="' || 'E' || '"');
  end if;
  if val = 'F'
   then
     htp.formselectoption( LNG4.AHC_TXT_275, 'CHECKED', cattributes=>'VALUE="' || 'F' || '"');
   else
     htp.formselectoption( LNG4.AHC_TXT_275, cattributes=>'VALUE="' || 'F' || '"');
  end if;
  if val = 'G'
   then
     htp.formselectoption( LNG4.AHC_TXT_465, 'CHECKED', cattributes=>'VALUE="' || 'G' || '"');
   else
     htp.formselectoption( LNG4.AHC_TXT_465, cattributes=>'VALUE="' || 'G' || '"');
  end if;
  if val = 'M'
   then
     htp.formselectoption( LNG4.AHC_TXT_466, 'CHECKED', cattributes=>'VALUE="' || 'M' || '"');
   else
     htp.formselectoption( LNG4.AHC_TXT_466, cattributes=>'VALUE="' || 'M' || '"');
  end if;
  if val = 'N'
   then
     htp.formselectoption( LNG.CST_ALT_021, 'CHECKED', cattributes=>'VALUE="' || 'N' || '"');
   else
     htp.formselectoption( LNG.CST_ALT_021, cattributes=>'VALUE="' || 'N' || '"');
  end if;
  if val = 'O'
   then
     htp.formselectoption( LNG4.AHC_TXT_594, 'CHECKED', cattributes=>'VALUE="' || 'O' || '"');
   else
     htp.formselectoption( LNG4.AHC_TXT_594, cattributes=>'VALUE="' || 'O' || '"');
  end if;
  if val = 'X'
   then
     htp.formselectoption( initcap(LNG3.ADM_TXT_721) || initcap(LNG3.ADM_TXT_722), 'CHECKED', cattributes=>'VALUE="' || 'X' || '"');
   else
     htp.formselectoption( initcap(LNG3.ADM_TXT_721) || initcap(LNG3.ADM_TXT_722), cattributes=>'VALUE="' || 'X' || '"');
  end if;
  if val = 'Y'
   then
     htp.formselectoption( initcap(LNG3.ADM_TXT_721), 'CHECKED', cattributes=>'VALUE="' || 'Y' || '"');
   else
     htp.formselectoption( initcap(LNG3.ADM_TXT_721), cattributes=>'VALUE="' || 'Y' || '"');
  end if;
  if val = 'Z'
   then
     htp.formselectoption( initcap(LNG3.ADM_TXT_722), 'CHECKED', cattributes=>'VALUE="' || 'Z' || '"');
   else
     htp.formselectoption( initcap(LNG3.ADM_TXT_722), cattributes=>'VALUE="' || 'Z' || '"');
  end if;
  if val = '1'
   then
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':10', 'CHECKED', cattributes=>'VALUE="' || '1' || '"');
   else
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':10', cattributes=>'VALUE="' || '1' || '"');
  end if;
  if val = '2'
   then
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':20', 'CHECKED', cattributes=>'VALUE="' || '2' || '"');
   else
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':20', cattributes=>'VALUE="' || '2' || '"');
  end if;
  if val = '3'
   then
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':40', 'CHECKED', cattributes=>'VALUE="' || '3' || '"');
   else
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':40', cattributes=>'VALUE="' || '3' || '"');
  end if;
  if val = '4'
   then
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':80', 'CHECKED', cattributes=>'VALUE="' || '4' || '"');
   else
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':80', cattributes=>'VALUE="' || '4' || '"');
  end if;
  if val = '5'
   then
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':160', 'CHECKED', cattributes=>'VALUE="' || '5' || '"');
   else
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':160', cattributes=>'VALUE="' || '5' || '"');
  end if;
  if val = '6'
   then
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':250', 'CHECKED', cattributes=>'VALUE="' || '6' || '"');
   else
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':250', cattributes=>'VALUE="' || '6' || '"');
  end if;
  if val = '7'
   then
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':300', 'CHECKED', cattributes=>'VALUE="' || '7' || '"');
   else
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':300', cattributes=>'VALUE="' || '7' || '"');
  end if;
  if val = '8'
   then
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':400', 'CHECKED', cattributes=>'VALUE="' || '8' || '"');
   else
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':400', cattributes=>'VALUE="' || '8' || '"');
  end if;
  if val = '9'
   then
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':600', 'CHECKED', cattributes=>'VALUE="' || '9' || '"');
   else
     htp.formselectoption( initcap(LNG.PHG_ALT_411) || ':600', cattributes=>'VALUE="' || '9' || '"');
  end if;
  htp.formselectclose;
 end dispbutt;

 procedure show_nested
 as
 begin
  htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
   htp.tablerowopen;
      htp.tabledata(htf.bold( LNG3.ADM_TXT_574 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.formhidden( 'P1', 'PFC' );
      if (c1rec.nested_scene_style = LNG3.ADM_TXT_571) or (c1rec.nested_scene_style is null)
       then
        htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( LNG3.ADM_TXT_571, 'SELECTED' ) || htf.formselectoption( LNG3.ADM_TXT_572 ) || htf.formselectoption( LNG3.ADM_TXT_576 ) || htf.formselectclose,
         cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       elsif c1rec.nested_scene_style = LNG3.ADM_TXT_572
        then
        htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( LNG3.ADM_TXT_571 ) || htf.formselectoption( LNG3.ADM_TXT_572, 'SELECTED' ) || htf.formselectoption( LNG3.ADM_TXT_576 ) || htf.formselectclose,
         cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       elsif c1rec.nested_scene_style = LNG3.ADM_TXT_576
        then
        htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( LNG3.ADM_TXT_571 ) || htf.formselectoption( LNG3.ADM_TXT_572 ) || htf.formselectoption( LNG3.ADM_TXT_576, 'SELECTED' ) || htf.formselectclose,
         cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       else
        htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( LNG3.ADM_TXT_571 ) || htf.formselectoption( LNG3.ADM_TXT_572 ) || htf.formselectoption( LNG3.ADM_TXT_576 ) || htf.formselectclose,
         cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      end if;

   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata(htf.bold( LNG3.ADM_TXT_601 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.formhidden( 'P1', 'DELM' );
      htp.tabledata(htf.formtext('P2',6,1,c1rec.nested_scene_delim),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tableclose;
 end show_nested;

 procedure show_shape
 as
 begin
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_227 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.is_locked = 'T'
      then
       htp.tabledata(htf.formcheckbox('P3','P1LCK','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.formcheckbox('P3','P1LCK'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_022 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'NAME' );
     htp.tabledata(htf.formtext('P2',40, 100, c1rec.theme_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_105 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'DESCRIPTION' );
     htp.tabledata(htf.formtext('P2', 40, 4000, c1rec.theme_descript ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_191 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'PREFIX' );
     htp.tabledata(htf.formtext('P2', 20, 20, c1rec.disp_prefix ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( 'Expired Account Template' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'EXPTEMP' );
     htp.tabledata(htf.formtext('P2', 40, 1000, c1rec.expire_template ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( 'External Style Sheet (Optional)' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'STYLESHEET' );
     htp.tabledata(htf.formtext('P2', 40, 100, c1rec.stylesheet ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;

  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_815 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.formhidden( 'P1', 'PFL' );
     htp.formselectopen( 'P2' );

     if c1rec.keep_lhf = 'L'
      then
       htp.formselectoption( LNG3.ADM_TXT_805, 'CHECKED', cattributes=>'VALUE="' || 'L' || '"');
      else
       htp.formselectoption( LNG3.ADM_TXT_805, cattributes=>'VALUE="' || 'L' || '"');
     end if;
     if c1rec.keep_lhf = 'R'
      then
       htp.formselectoption( LNG3.ADM_TXT_806, 'CHECKED', cattributes=>'VALUE="' || 'R' || '"');
      else
       htp.formselectoption( LNG3.ADM_TXT_806, cattributes=>'VALUE="' || 'R' || '"');
     end if;
     if c1rec.keep_lhf = '2'
      then
       htp.formselectoption( LNG3.ADM_TXT_804, 'CHECKED', cattributes=>'VALUE="' || '2' || '"');
      else
       htp.formselectoption( LNG3.ADM_TXT_804, cattributes=>'VALUE="' || '2' || '"');
     end if;
     if c1rec.keep_lhf = 'N'
      then
       htp.formselectoption( LNG3.ADM_TXT_803, 'CHECKED', cattributes=>'VALUE="' || 'N' || '"');
      else
       htp.formselectoption( LNG3.ADM_TXT_803, cattributes=>'VALUE="' || 'N' || '"');
     end if;
     htp.formselectclose;
     htp.tabledata('</TD>');
  htp.tablerowclose;

  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_192 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.formhidden( 'P1', 'P3A' );
     htp.formselectopen( 'P2' );
     if c1rec.keep_lhf in ('2','N')
      then
       null;
      else
       if c1rec.disploc = 'S'
        then
         htp.formselectoption( LNG3.ADM_TXT_193, 'CHECKED', cattributes=>'VALUE="' || 'S' || '"');
        else
         htp.formselectoption( LNG3.ADM_TXT_193, cattributes=>'VALUE="' || 'S' || '"');
       end if;
     end if;
     if c1rec.disploc = 'T'
      then
       htp.formselectoption( LNG3.ADM_TXT_194, 'CHECKED', cattributes=>'VALUE="' || 'T' || '"');
      else
       htp.formselectoption( LNG3.ADM_TXT_194, cattributes=>'VALUE="' || 'T' || '"');
     end if;
     if c1rec.keep_lhf in ('2','N')
      then
       null;
      else
       if c1rec.disploc = 'D'
        then
         htp.formselectoption( LNG3.ADM_TXT_195, 'CHECKED', cattributes=>'VALUE="' || 'D' || '"');
        else
         htp.formselectoption( LNG3.ADM_TXT_195, cattributes=>'VALUE="' || 'D' || '"');
       end if;
     end if;
     htp.formselectclose;
     htp.tabledata('</TD>');
  htp.tablerowclose;

  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_579 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.formhidden( 'P1', 'PFE' );
     htp.formselectopen( 'P2' );
     if c1rec.keep_lhf in ('2','N')
      then
       null;
      else
       if c1rec.scene_position = 'L'
        then
         htp.formselectoption( LNG.PHG_TXT_285, 'CHECKED', cattributes=>'VALUE="' || 'L' || '"');
        else
         htp.formselectoption( LNG.PHG_TXT_285, cattributes=>'VALUE="' || 'L' || '"');
       end if;
     end if;
     if c1rec.scene_position = 'T'
      then
       htp.formselectoption( LNG3.ADM_TXT_580, 'CHECKED', cattributes=>'VALUE="' || 'T' || '"');
      else
       htp.formselectoption( LNG3.ADM_TXT_580, cattributes=>'VALUE="' || 'T' || '"');
     end if;
     htp.formselectclose;
     htp.tabledata('</TD>');
  htp.tablerowclose;

  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_196 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.uses_boundary = 'T'
      then
       htp.tabledata(htf.formcheckbox('P3','P1X','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.formcheckbox('P3','P1X'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
  htp.tablerowclose;

  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_398 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if substr(c1rec.separate_customer_bt,1,1) = 'T'
      then
       htp.tabledata(htf.formcheckbox('P3','PCB','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.formcheckbox('P3','PCB'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
  htp.tablerowclose;

  -- Details relevant for 3 frame structures only
  if nvl(c1rec.keep_lhf,'L') in ('L','R')
   then
    htp.tablerowopen;
       htp.tabledata(htf.bold( LNG3.ADM_TXT_586 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
       htp.formhidden( 'P1', 'PFG' );
       htp.formselectopen( 'P2' );
        if c1rec.phg_but_scene = 'T' then htp.formselectoption( 'Buttons,Category', 'SELECTED', cattributes=>'VALUE="' || 'T' || '"' ); else htp.formselectoption( 'Buttons,Category', cattributes=>'VALUE="' || 'T' || '"' ); end if;
        if nvl(c1rec.phg_but_scene,'F') = 'F' then htp.formselectoption( 'Category,Buttons', 'SELECTED', cattributes=>'VALUE="' || 'F' || '"' ); else htp.formselectoption( 'Category,Buttons', cattributes=>'VALUE="' || 'F' || '"' ); end if;
        if c1rec.phg_but_scene = 'D' then htp.formselectoption( 'Buttons', 'SELECTED', cattributes=>'VALUE="' || 'D' || '"' ); else htp.formselectoption( 'Buttons', cattributes=>'VALUE="' || 'D' || '"' ); end if;
       htp.formselectclose;
      htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tablerowopen;
       htp.tabledata(htf.bold( LNG3.ADM_TXT_587 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.cus_but_scene = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','PFH','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','PFH'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
    htp.tablerowclose;

    htp.tablerowopen;
       htp.tabledata(htf.bold( LNG3.ADM_TXT_219 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.formhidden( 'P1', 'PFA' );
       htp.tabledata(htf.formtext('P2',10,10,nvl(c1rec.frame_border,'1')),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
       htp.tabledata(htf.bold( LNG3.ADM_TXT_220 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.formhidden( 'P1', 'PFB' );
       htp.tabledata(htf.formtext('P2',10,10,nvl(c1rec.border_around_scene,'0')),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
       htp.tabledata(htf.bold( LNG3.ADM_TXT_573 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.display_bullet = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','PFD','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','PFD'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
    htp.tablerowclose;
    htp.formhidden( 'P1', 'PF3' );
    htp.formhidden( 'P2', 'F' );
   else
    htp.formhidden( 'P1', 'PF3' );
    htp.formhidden( 'P2', 'F' );
   /*
   htp.tablerowopen;
       htp.tabledata(htf.bold( LNG4.AHC_TXT_974 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.sim_three_frame = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','PF3','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','PF3'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
    htp.tablerowclose;
    */
    htp.formhidden( 'P1', 'PFA' );
    htp.formhidden( 'P2', c1rec.frame_border );
    htp.formhidden( 'P1', 'PFB' );
    htp.formhidden( 'P2', c1rec.border_around_scene );
    htp.formhidden( 'P1', 'PFB' );
    htp.formhidden( 'P2', c1rec.border_around_scene );
  end if;

  if c1rec.keep_lhf is null
   then
    htp.tablerowopen;
       htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(
        htf.img( DECS.IMAGE_LOCATION || 'admin/lf_a.gif',cattributes=>' border=0',calt=>LNG3.ADM_TXT_803 ) || htf.nl ||
        htf.img( DECS.IMAGE_LOCATION || 'admin/lf_b.gif',cattributes=>' border=0',calt=>LNG3.ADM_TXT_804 ) || htf.nl ||
        htf.img( DECS.IMAGE_LOCATION || 'admin/lf_c.gif',cattributes=>' border=0',calt=>LNG3.ADM_TXT_805 ) || htf.nl ||
        htf.img( DECS.IMAGE_LOCATION || 'admin/lf_d.gif',cattributes=>' border=0',calt=>LNG3.ADM_TXT_806 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.tablerowclose;
  elsif c1rec.keep_lhf = 'N'
   then
    htp.tablerowopen;
       htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.img( DECS.IMAGE_LOCATION || 'admin/lf_a.gif',cattributes=>' border=0',calt=>LNG3.ADM_TXT_803 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.tablerowclose;
  elsif c1rec.keep_lhf = '2'
   then
    htp.tablerowopen;
       htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.img( DECS.IMAGE_LOCATION || 'admin/lf_b.gif',cattributes=>' border=0',calt=>LNG3.ADM_TXT_804 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.tablerowclose;
  elsif c1rec.keep_lhf = 'L'
   then
    htp.tablerowopen;
       htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.img( DECS.IMAGE_LOCATION || 'admin/lf_c.gif',cattributes=>' border=0',calt=>LNG3.ADM_TXT_805 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.tablerowclose;
  elsif c1rec.keep_lhf = 'R'
   then
    htp.tablerowopen;
       htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.img( DECS.IMAGE_LOCATION || 'admin/lf_d.gif',cattributes=>' border=0',calt=>LNG3.ADM_TXT_806 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.tablerowclose;
  end if;
  htp.tableclose;
 end show_shape;

 procedure show_noframe
 as
 begin
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_910 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'SF1' );
     htp.tabledata(htf.formtext('P2',20,100,replace(c1rec.sf_table_width,'"','')),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_988 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'TOPAPI' );
     htp.tabledata(htf.formtext('P2',60,100,c1rec.top_frame_api_call),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold( LNG4.AHC_TXT_775 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'TOP_PADDING' );
     htp.tabledata(htf.formtext('P2',5,20,c1rec.top_padding),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold( LNG4.AHC_TXT_776 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'LEFT_PADDING' );
     htp.tabledata(htf.formtext('P2',5,20,c1rec.left_padding),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_906 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'SF2' );
     htp.tabledata(htf.formtext('P2',40,100,c1rec.sf_bg_img),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_933 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'SF6' );
     htp.tabledata(htf.formtext('P2',20,20,c1rec.sf_bg_cellspc),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_907 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'SF3' );
     htp.tabledata(htf.formtext('P2',20,20,c1rec.sf_bg_cell_width),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_908 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'SF4' );
     htp.tabledata(htf.formtext('P2',20,20,c1rec.sf_bg_cell_height),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_909 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'SF5' );
     htp.tabledata(htf.formtext('P2',20,20,c1rec.sf_bg_valign),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_814 ) || htf.nl || LNG4.AHC_TXT_856,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="TOP" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.bold( LNG3.ADM_TXT_807 );
     htp.nl;
     for j in 1..10 loop
      dispbutt( substr(c1rec.row1,j,1), 'ROW1' );
      if j in (3,6,9) then htp.nl; end if;
     end loop;
     htp.nl;
     htp.bold( LNG3.ADM_TXT_808 );
     htp.nl;
     for j in 1..10 loop
      dispbutt( substr(c1rec.row2,j,1), 'ROW2' );
      if j in (4,8) then htp.nl; end if;
     end loop;
     htp.nl;
     htp.bold( LNG3.ADM_TXT_809 );
     htp.nl;
     for j in 1..10 loop
      dispbutt( substr(c1rec.row3,j,1), 'ROW3' );
      if j in (4,8) then htp.nl; end if;
     end loop;
     htp.nl;
     htp.bold( LNG3.ADM_TXT_905 );
     htp.nl;
     for j in 1..10 loop
      dispbutt( substr(c1rec.row4,j,1), 'ROW4' );
      if j in (4,8) then htp.nl; end if;
     end loop;
     htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tableclose;
 end show_noframe;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.THEME_RIGHT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if thm is null
  then
   adm.main_title( surl, sessid, LNG3.ADM_TXT_186 , style=>'NOMENU', helpid=>'A27' );
  else
   adm.main_title( surl, sessid, LNG3.ADM_TXT_188 || ': ' || thm , style=>'NOMENU', helpid=>'A27' );
 end if;
 if msg is not null then glbx.header_msg( msg ); end if;
 open c1(thm);
 fetch c1 into c1rec;
 close c1;
 if msg = LNG3.ADM_TXT_186
  then
   c1rec.row1 := 'PASI';
   c1rec.row2 := 'TH';
 end if;

 htp.p( '<CENTER>' );
 if disp in ('SHAPE','NOFRAME','MATTE','INSTRUCTION','ICONS_CUST','STANDARD','LHF','FULLIMG','SEARCH','GALLERY','CUSTOMER','TITLE','HOME','THUMBNAIL','SECURITY','TABLE','META','VERT','ERROR','NESTED','API','ORDER')
  then
   if thm is null
    then
     htp.formopen( 'lf.accept_theme', ctarget=>'_top' );
    else
     htp.formopen( 'lf.accept_theme' );
   end if;
   htp.formhidden( 'SURL', glbx.rndsurl(surl) );
   htp.formhidden( 'THM', thm );
   if thm is null
    then
     htp.formhidden( 'NEWTHEME', 'T' );
    else
     htp.formhidden( 'NEWTHEME', 'F' );
   end if;
   htp.formhidden( 'DISP', disp );
   htp.formhidden( 'P1', null );
   htp.formhidden( 'P2', null );
   htp.formhidden( 'P3', null );
   htp.formhidden( 'ROW1', null );
   htp.formhidden( 'ROW2', null );
   htp.formhidden( 'ROW3', null );
   htp.formhidden( 'ROW4', null );
 end if;

 if disp = 'SHAPE'
  then
   show_shape;
   htp.nl;
   if thm is null
    then
     htp.formsubmit( 'ACTION', LNG3.ADM_TXT_186);
    else
     htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   end if;
   htp.formclose;
 elsif disp = 'NOFRAME'
  then
   show_noframe;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;
 elsif disp = 'MATTE'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
   disp_c3(surl,'M3A', c1rec.tnail_matte_colour, LNG3.ADM_TXT_943,'P1');
   disp_c3(surl,'M3D', c1rec.tnail_border_colour, LNG3.ADM_TXT_944,'P1');
   disp_c3(surl,'M3E', c1rec.tnail_border_colour_l, LNG3.ADM_TXT_945,'P1');
   htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_946 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'M3B' );
     htp.tabledata(htf.formtext( 'P2',10,10,c1rec.tnail_width),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_947 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'M3C' );
     htp.tabledata(htf.formtext( 'P2',10,10,c1rec.tnail_border),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_634 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'M3G' );
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.formselectopen( 'P2' );
     if c1rec.matte_border_style = 'SOLID'
      then
       htp.formselectoption( 'SOLID', 'SELECTED' );
      else
       htp.formselectoption( 'SOLID' );
     end if;
     if c1rec.matte_border_style = 'NONE'
      then
       htp.formselectoption( 'NONE', 'SELECTED' );
      else
       htp.formselectoption( 'NONE' );
     end if;
     if c1rec.matte_border_style = 'DOTTED'
      then
       htp.formselectoption( 'DOTTED', 'SELECTED' );
      else
       htp.formselectoption( 'DOTTED' );
     end if;
     if c1rec.matte_border_style = 'DASHED'
      then
       htp.formselectoption( 'DASHED', 'SELECTED' );
      else
       htp.formselectoption( 'DASHED' );
     end if;
     if c1rec.matte_border_style = 'DOUBLE'
      then
       htp.formselectoption( 'DOUBLE', 'SELECTED' );
      else
       htp.formselectoption( 'DOUBLE' );
     end if;
     if c1rec.matte_border_style = 'GROOVE'
      then
       htp.formselectoption( 'GROOVE', 'SELECTED' );
      else
       htp.formselectoption( 'GROOVE' );
     end if;
     if c1rec.matte_border_style = 'RIDGE'
      then
       htp.formselectoption( 'RIDGE', 'SELECTED' );
      else
       htp.formselectoption( 'RIDGE' );
     end if;
     if c1rec.matte_border_style = 'INSET'
      then
       htp.formselectoption( 'INSET', 'SELECTED' );
      else
       htp.formselectoption( 'INSET' );
     end if;
     if c1rec.matte_border_style = 'OUTSET'
      then
       htp.formselectoption( 'OUTSET', 'SELECTED' );
      else
       htp.formselectoption( 'OUTSET' );
     end if;
     htp.formselectclose;
     htp.p( '</TD>' );
     htp.tabledata( LNG5.EXT_TXT_635,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;
   htp.nl;
   glbx.image_matte( c1rec, 80, 80, null, '<IMG BORDER=0 WIDTH=80 HEIGHT=80 SRC="' || DECS.IMAGE_LOCATION || 'admin/matte.gif">', null );

 elsif disp = 'INSTRUCTION'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    disp_c3(surl,'M2A', c1rec.instruct_text_colour, LNG3.ADM_TXT_951,'P1');
    disp_c2(surl,'M2B', c1rec.instruct_text_font, LNG3.ADM_TXT_952 );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_953 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p('<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">');
     htp.formhidden( 'P1', 'M2C' );
     htp.formselectopen( 'P2' );
     if c1rec.instruct_align = 'CENTER'
      then
       htp.formselectoption( 'CENTER', 'SELECTED' );
      else
       htp.formselectoption( 'CENTER' );
     end if;
     if c1rec.instruct_align = 'LEFT'
      then
       htp.formselectoption( 'LEFT', 'SELECTED' );
      else
       htp.formselectoption( 'LEFT' );
     end if;
     if c1rec.instruct_align = 'RIGHT'
      then
       htp.formselectoption( 'RIGHT', 'SELECTED' );
      else
       htp.formselectoption( 'RIGHT' );
     end if;
     htp.formselectclose;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    disp_c3(surl,'M2D', c1rec.instruct_cell_colour, LNG3.ADM_TXT_940,'P1');
    disp_c3(surl,'M2G', c1rec.instruct_cell_brd_clr, LNG5.EXT_TXT_557,'P1');
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_941 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'M2E' );
     htp.tabledata(htf.formtext( 'P2',10,10,c1rec.instruct_cell_border),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_942 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'M2F' );
     htp.tabledata(htf.formtext( 'P2',10,10,c1rec.instruct_font_inc),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;

 elsif disp = 'STANDARD'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    disp_c2(surl,'P4A', c1rec.text_font, LNG3.ADM_TXT_201 );
    disp_c3(surl,'P4B', c1rec.text_colour, LNG3.ADM_TXT_202,'P1' );
    disp_c3(surl,'P4C', c1rec.text_back, LNG3.ADM_TXT_203,'P1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_948 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'P4D' );
     htp.tabledata(htf.formtext( 'P2',10,10,c1rec.text_font_inc),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    disp_c2(surl,'PCA', c1rec.anchor_text_font, LNG5.EXT_TXT_637 );
    disp_c3(surl,'PCB', c1rec.anchor_text_colour, LNG5.EXT_TXT_636,'P1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_638 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'PCD' );
     htp.tabledata(htf.formtext( 'P2',10,10,c1rec.anchor_font_adj),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_146 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.formhidden( 'P1', 'STD_ACTIVE_LINK' );
       if c1rec.underline_active = 'ACTIVE'
        then
         htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( LNG.PHG_TXT_045,'SELECTED', cattributes=>'VALUE="ACTIVE"' ) || htf.formselectoption( LNG.PHG_TXT_046, cattributes=>'VALUE="NOTACTIVE"' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( LNG.PHG_TXT_045, cattributes=>'VALUE="ACTIVE"' ) || htf.formselectoption( LNG.PHG_TXT_046,'SELECTED', cattributes=>'VALUE="NOTACTIVE"' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_639 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.formhidden( 'P1', 'PCC' );
       if nvl(c1rec.anchor_type,'NORMAL') = 'NORMAL'
        then
         htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( 'NORMAL','SELECTED', cattributes=>'VALUE="NORMAL"' ) || htf.formselectoption( 'ITALIC', cattributes=>'VALUE="ITALIC"' ) || htf.formselectoption( 'OBLIQUE', cattributes=>'VALUE="OBLIQUE"' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       elsif c1rec.anchor_type = 'ITALIC'
        then
         htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( 'NORMAL', cattributes=>'VALUE="NORMAL"' ) || htf.formselectoption( 'ITALIC','SELECTED', cattributes=>'VALUE="ITALIC"' ) || htf.formselectoption( 'OBLIQUE', cattributes=>'VALUE="OBLIQUE"' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       elsif c1rec.anchor_type = 'OBLIQUE'
        then
         htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( 'NORMAL', cattributes=>'VALUE="NORMAL"' ) || htf.formselectoption( 'ITALIC', cattributes=>'VALUE="ITALIC"' ) || htf.formselectoption( 'OBLIQUE','SELECTED', cattributes=>'VALUE="OBLIQUE"' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;
   htp.nl;
   htp.nl;
   htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=0 border=0' );
    htp.tablerowopen;
     htp.tabledata('<b><font size="+0" color="#' || c1rec.title_colour_font || '" FACE="' || c1rec.title_text_font || '">'|| 'TITLE' || '</font></b>',cattributes=>'bgcolor="' || c1rec.title_text_colour || '" valign="MIDDLE" align="CENTER"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata('<BR><BR><BR><BR><BR><font size="+' || c1rec.text_font_inc || '" color="#' || c1rec.text_colour || '" FACE="' || c1rec.text_font || '">'|| LNG3.ADM_TXT_202 || '</font><BR><BR><BR><BR><BR>',cattributes=>'bgcolor="' || c1rec.text_back || '" valign="MIDDLE" align="CENTER"');
    htp.tablerowclose;
   htp.tableclose;

 elsif disp = 'ORDER'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    disp_c2(surl,'OP7A', c1rec.ord_title_text_font, LNG5.EXT_TXT_136);
    disp_c3(surl,'OP7B', c1rec.ord_title_colour_font, LNG5.EXT_TXT_137,'P1' );
    disp_c3(surl,'OP7C', c1rec.ord_title_text_colour, LNG5.EXT_TXT_138,'P1' );
    disp_c2(surl,'OP4A', c1rec.ord_text_font, LNG5.EXT_TXT_139 );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_144 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'OP4D' );
     htp.tabledata(htf.formtext( 'P2',10,10,c1rec.ord_text_font_inc),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    disp_c3(surl,'OP4B', c1rec.ord_text_colour, LNG5.EXT_TXT_140,'P1' );
    disp_c3(surl,'OP4C', c1rec.ord_text_back, LNG5.EXT_TXT_141,'P1' );
    disp_c3(surl,'OTHD', substr(c1rec.ord_qbground,11,6), LNG5.EXT_TXT_142,'P1' );
    disp_c3(surl,'OTCL', substr(c1rec.ord_qcbground,11,6), LNG5.EXT_TXT_143,'P1' );
    disp_c3(surl,'OTCG', substr(c1rec.ord_toggle_qcbground,11,6), LNG5.EXT_TXT_403,'P1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_148 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'OTBL' );
     htp.tabledata(htf.formtext( 'P2',10,10,c1rec.ord_text_table_border),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_151 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'OTBLI' );
     htp.tabledata(htf.formtext( 'P2',10,10,c1rec.ord_text_table_borderi),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_475 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'OTBLA' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.order_nocol_table,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_476 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'OTBLB' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.order_twocol_table,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;

    disp_c3(surl,'ONV1', substr(c1rec.ord_summary_hdr_clr,11,6), LNG5.EXT_TXT_532,'P1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_534 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ONV3' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.ord_bank_divider,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_535 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ONV4' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.ord_cost_table,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_537 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ONV5' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.ord_cost_left,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_536 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ONV6' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.ord_cost_right,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;

    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_544 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ONV13' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.ord_cust_table,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_546 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ONV14' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.ord_cust_left,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_545 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ONV15' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.ord_cust_right,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;

    -- xxx language file User Fees
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'User Fee Table Definition' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ONV16' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.ord_uf_table,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'User Fee Left Cell Definition' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ONV17' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.ord_uf_left,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'User Fee Right Cell Definition' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ONV18' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.ord_uf_right,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;

    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_538 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ONV7' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.ord_deliv_table,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_540 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ONV8' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.ord_deliv_left,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_539 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ONV9' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.ord_deliv_right,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_541 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ONV10' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.ord_paym_table,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_543 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ONV11' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.ord_paym_left,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_542 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ONV12' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.ord_paym_right,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_553 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ONV17' );
     htp.tabledata(htf.formtext( 'P2',80,1000,replace(c1rec.ord_paym_right2,'"','&#34;' )),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;

    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_398 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if substr(c1rec.ord_inc_simple,1,1) = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','ORA1','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','ORA1'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_399 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if substr(c1rec.ord_inc_privacy,1,1) = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','ORA2','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','ORA2'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_401 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if substr(c1rec.ord_toggle_colours,1,1) = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','ORA3','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','ORA3'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_400 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ORA4' );
     htp.tabledata(htf.formtext( 'P2',20,100,c1rec.order_bottom_external),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_402 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ORA5' );
     htp.tabledata(htf.formtext( 'P2',20,100,c1rec.ord_extra_col_api_call),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;
   htp.nl;
   htp.nl;
   htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=0 border=0' );
    htp.tablerowopen;
     htp.tabledata('<b><font size="+6" color="#' || c1rec.ord_title_colour_font || '" FACE="' || c1rec.ord_title_text_font || '">'|| LNG5.EXT_TXT_137 || '</font></b>',cattributes=>'bgcolor="' || c1rec.ord_title_text_colour || '" valign="MIDDLE" align="CENTER"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=0 border=0' );
    htp.tablerowopen;
     htp.tabledata('<b><font size="+0" color="#' || c1rec.ord_title_colour_font || '" FACE="' || c1rec.ord_title_text_font || '">'|| 'TITLE' || '</font></b>',cattributes=>'bgcolor="' || c1rec.ord_title_text_colour || '" valign="MIDDLE" align="CENTER"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata('<BR><BR><BR><BR><BR><font size="+' || c1rec.ord_text_font_inc || '" color="#' || c1rec.ord_text_colour || '" FACE="' || c1rec.ord_text_font || '">'|| LNG5.EXT_TXT_137 || '</font><BR><BR><BR><BR><BR>',cattributes=>'bgcolor="' || c1rec.ord_text_back || '" valign="MIDDLE" align="CENTER"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_115 ),cattributes=>c1rec.ord_qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( 'HIJKLM' ),cattributes=>c1rec.ord_qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_116 ),cattributes=>c1rec.ord_qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( 'YYYYY' ),cattributes=>c1rec.ord_qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( LNG4.AHC_TXT_116,cattributes=>c1rec.ord_qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( 'NNNNN',cattributes=>c1rec.ord_qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.italic( LNG4.AHC_TXT_116 ),cattributes=>c1rec.ord_qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.italic( 'SSSSSS' ),cattributes=>c1rec.ord_qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
   htp.tableclose;

 elsif disp = 'LHF'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    disp_c2(surl,'P5A', c1rec.lhs_text_font, LNG3.ADM_TXT_204 );
    disp_c3(surl,'P5B', c1rec.lhs_text_colour, LNG3.ADM_TXT_205,'P1' );
    disp_c3(surl,'P5C', c1rec.lhs_back, LNG3.ADM_TXT_206,'P1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_225 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'P5D' );
     htp.tabledata(htf.formtext( 'P2',40,100,c1rec.lhf_external_call),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   htp.tableclose;

   -- xxx for language file
   htp.nl;
   htp.bold( 'Left Hand Frame Background Image and Clickable Link - in /images/order_style/' );
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Subdirectory Name' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'P5LHF1' );
     htp.tabledata(htf.formtext( 'P2', 40, 100, c1rec.lhf_subdir),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Background Display Image' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'P5LHF2' );
     htp.tabledata(htf.formtext( 'P2', 40, 100, c1rec.lhf_backimg),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Clickable Image Name' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'P5LHF3' );
     htp.tabledata(htf.formtext( 'P2', 40, 100, c1rec.lhf_clickable_img),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Background Display Image' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'P5LHF4' );
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">');
      htp.formselectopen( 'P2' );
      htp.formselectoption( NULL );
      if c1rec.lhf_clickable_position = '1'
       then
        htp.formselectoption( 'Top of Frame', 'SELECTED', cattributes=>'VALUE="1"' );
       else
        htp.formselectoption( 'Top of Frame', cattributes=>'VALUE="1"' );
      end if;
      if c1rec.lhf_clickable_position = '2'
       then
        htp.formselectoption( 'Before Categories', 'SELECTED', cattributes=>'VALUE="2"' );
       else
        htp.formselectoption( 'Before Categories', cattributes=>'VALUE="2"' );
      end if;
      if c1rec.lhf_clickable_position = '3'
       then
        htp.formselectoption( 'Before Menu', 'SELECTED', cattributes=>'VALUE="3"' );
       else
        htp.formselectoption( 'Before Menu', cattributes=>'VALUE="3"' );
      end if;
      if c1rec.lhf_clickable_position = '4'
       then
        htp.formselectoption( 'Bottom of Frame', 'SELECTED', cattributes=>'VALUE="4"' );
       else
        htp.formselectoption( 'Bottom of Frame', cattributes=>'VALUE="4"' );
      end if;
      htp.formselectclose;
     htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'HTTP Anchor Link' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'P5LHF5' );
     htp.tabledata(htf.formtext( 'P2', 40, 1000, c1rec.lhf_clickable_anchor),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Anchor Target (eg. _top, _blank, NEW_PAGE)' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'P5LHF6' );
     htp.tabledata(htf.formtext( 'P2', 40, 100, c1rec.lhf_clickable_target),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;
   htp.nl;
   htp.nl;
   htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=0 border=0' );
    htp.tablerowopen;
     htp.tabledata('<BR><BR><BR><BR><BR><font color="#' || c1rec.lhs_text_colour || '" FACE="' || c1rec.lhs_text_font || '">'|| LNG3.ADM_TXT_205|| '</font><BR><BR><BR><BR><BR>',cattributes=>'bgcolor="' || c1rec.lhs_back || '" valign="MIDDLE" align="CENTER"');
    htp.tablerowclose;
   htp.tableclose;

 elsif disp = 'SCREENSIZE'
  then
   scont( surl, c1rec );
   htp.nl;

 elsif disp = 'SEARCH'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_412 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if substr(c1rec.search_choices,1,1) = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','SRC1','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','SRC1'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( initcap(LNG2.PBK_TXT_082) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if substr(c1rec.search_choices,2,1) = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','SRC2','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','SRC2'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG2.PBK_TXT_009 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if substr(c1rec.search_choices,3,1) = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','SRC3','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','SRC3'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_940 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if substr(c1rec.search_choices,4,1) = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','SRC4','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','SRC4'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold(LNG5.EXT_TXT_220 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD  ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.formhidden( 'P1', 'SRCD' );
     htp.formselectopen( 'P2' );
     if c1rec.search_default = 'S'
      then
       htp.formselectoption( LNG4.AHC_TXT_412, 'SELECTED', cattributes=>'VALUE="' || 'S' || '"' );
      else
       htp.formselectoption( LNG4.AHC_TXT_412, cattributes=>'VALUE="' || 'S' || '"' );
     end if;
     if c1rec.search_default = 'A'
      then
       htp.formselectoption( LNG2.PBK_TXT_082, 'SELECTED', cattributes=>'VALUE="' || 'A' || '"' );
      else
       htp.formselectoption( LNG2.PBK_TXT_082, cattributes=>'VALUE="' || 'A' || '"' );
     end if;
     if c1rec.search_default = 'M'
      then
       htp.formselectoption( LNG2.PBK_TXT_009, 'SELECTED', cattributes=>'VALUE="' || 'M' || '"' );
      else
       htp.formselectoption( LNG2.PBK_TXT_009, cattributes=>'VALUE="' || 'M' || '"' );
     end if;
     if c1rec.search_default = 'Q'
      then
       htp.formselectoption( LNG4.AHC_TXT_940, 'SELECTED', cattributes=>'VALUE="' || 'Q' || '"' );
      else
       htp.formselectoption( LNG4.AHC_TXT_940, cattributes=>'VALUE="' || 'Q' || '"' );
     end if;
     htp.formselectclose;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_216 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD  ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.formhidden( 'P1', 'SRCS' );
     htp.formselectopen( 'P2' );
     if c1rec.search_style_simple = 'STANDARD'
      then
       htp.formselectoption( 'STANDARD', 'SELECTED');
      else
       htp.formselectoption( 'STANDARD');
     end if;
     if c1rec.search_style_simple = 'SIMPLE'
      then
       htp.formselectoption( 'SIMPLE', 'SELECTED');
      else
       htp.formselectoption( 'SIMPLE');
     end if;
     if c1rec.search_style_simple = 'VERY SIMPLE'
      then
       htp.formselectoption( 'VERY SIMPLE', 'SELECTED');
      else
       htp.formselectoption( 'VERY SIMPLE');
     end if;
     if c1rec.search_style_simple = 'MULTIPLE'
      then
       htp.formselectoption( 'MULTIPLE', 'SELECTED');
      else
       htp.formselectoption( 'MULTIPLE');
     end if;
     if c1rec.search_style_simple = 'LIST_CATEGORIES'
      then
       htp.formselectoption( 'LIST_CATEGORIES', 'SELECTED');
      else
       htp.formselectoption( 'LIST_CATEGORIES');
     end if;
     if c1rec.search_style_simple = 'SEARCH_ON_CATEGORIES'
      then
       htp.formselectoption( 'SEARCH_ON_CATEGORIES', 'SELECTED');
      else
       htp.formselectoption( 'SEARCH_ON_CATEGORIES');
     end if;
     htp.formselectclose;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold(LNG5.EXT_TXT_218 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD  ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.formhidden( 'P1', 'SRCV' );
     htp.formselectopen( 'P2' );
     if c1rec.search_display_style = 'S'
      then
       htp.formselectoption( LNG.GLB_TXT_086, 'SELECTED', cattributes=>'VALUE="' || 'S' || '"' );
      else
       htp.formselectoption( LNG.GLB_TXT_086, cattributes=>'VALUE="' || 'S' || '"' );
     end if;
     if c1rec.search_display_style = 'E'
      then
       htp.formselectoption( LNG5.EXT_TXT_219, 'SELECTED', cattributes=>'VALUE="' || 'E' || '"' );
      else
       htp.formselectoption( LNG5.EXT_TXT_219, cattributes=>'VALUE="' || 'E' || '"' );
     end if;
     htp.formselectclose;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_223 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD  ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.formhidden( 'P1', 'SRCM' );
     htp.formselectopen( 'P2' );
     if c1rec.search_style_mfctr = 'STANDARD'
      then
       htp.formselectoption( 'STANDARD', 'SELECTED');
      else
       htp.formselectoption( 'STANDARD');
     end if;
     if c1rec.search_style_mfctr = 'SIMPLE'
      then
       htp.formselectoption( 'SIMPLE', 'SELECTED');
      else
       htp.formselectoption( 'SIMPLE');
     end if;
     if c1rec.search_style_mfctr = 'SHOP'
      then
       htp.formselectoption( 'SHOP', 'SELECTED');
      else
       htp.formselectoption( 'SHOP');
     end if;
     htp.formselectclose;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_224 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'SRCTTL' );
     htp.tabledata(htf.formtext( 'P2',20,100,c1rec.search_mfctr_title),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_330 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.search_icons = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','SRCI','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','SRCI'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG2.FRM_TXT_054 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.search_stem = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','SRCT','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','SRCT'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG2.PFM_TXT_170 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.search_global = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','SRCG','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','SRCG'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_997 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.search_email_on_new = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','SRCE','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','SRCE'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_217 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.search_ignore_lbox = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','SRCL','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','SRCL'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_226 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.search_number_enable = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','SRCN','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','SRCN'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_318 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.search_with_context = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','SRCTX','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','SRCTX'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tableclose;
    htp.nl;
    htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
    htp.formclose;
    htp.nl;

 elsif disp = 'FULLIMG'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    disp_c2(surl,'PFA', c1rec.fullimg_text_font, LNG5.EXT_TXT_038 );
    disp_c3(surl,'PFB', c1rec.fullimg_text_colour, LNG5.EXT_TXT_039,'P1' );
    disp_c3(surl,'PFC', c1rec.fullimg_back, LNG5.EXT_TXT_040,'P1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_041 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.fullimg_jscript_popup = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','PFD','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','PFD'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_648 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'PNV' );
     if c1rec.fullimg_novelty = 'B'
      then
       htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( 'Button', 'SELECTED', cattributes=>'VALUE="B"' ) ||
                                                   htf.formselectoption( 'List of Value', cattributes=>'VALUE="L"' ) ||
                                                   htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     elsif c1rec.fullimg_novelty = 'L'
      then
       htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( 'Button', cattributes=>'VALUE="B"' ) ||
                                                   htf.formselectoption( 'List of Value', 'SELECTED', cattributes=>'VALUE="L"' ) ||
                                                   htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_043 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'PFE' );
     htp.tabledata(htf.formtext( 'P2',10,30,c1rec.fullimg_popup_width),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_044 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'PFF' );
     htp.tabledata(htf.formtext( 'P2',10,30,c1rec.fullimg_popup_height),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold(LNG5.EXT_TXT_042 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'PFG' );
     if nvl(c1rec.fullimg_display_type,'HORIZONTAL') = 'HORIZONTAL'
      then
       htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( 'HORIZONTAL', 'SELECTED' ) ||
                                                   htf.formselectoption( 'VERTICAL' ) ||
                                                   htf.formselectoption( 'TEMPLATE' ) ||
                                                   htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     elsif c1rec.fullimg_display_type = 'VERTICAL'
      then
       htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( 'HORIZONTAL' ) ||
                                                   htf.formselectoption( 'VERTICAL', 'SELECTED' ) ||
                                                   htf.formselectoption( 'TEMPLATE' ) ||
                                                   htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     elsif c1rec.fullimg_display_type = 'TEMPLATE'
      then
       htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( 'HORIZONTAL' ) ||
                                                   htf.formselectoption( 'VERTICAL' ) ||
                                                   htf.formselectoption( 'TEMPLATE', 'SELECTED' ) ||
                                                   htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
    htp.tablerowclose;
    htp.tablerowopen;
     -- xxx for language file
     htp.tabledata(htf.bold('Title Style' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'PFTT' );
     if nvl(c1rec.fullimg_title_style,'M') = 'M'
      then
       htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( 'Title on Menu Bar', 'SELECTED', cattributes=>'VALUE="M"' ) ||
                                                   htf.formselectoption( 'No Menu Bar, Title Underneath', cattributes=>'VALUE="B"' ) ||
                                                   htf.formselectoption( 'No Menu Bar, No Title', cattributes=>'VALUE="N"' ) ||
                                                   htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     elsif c1rec.fullimg_title_style = 'B'
      then
       htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( 'Title on Menu Bar', cattributes=>'VALUE="M"' ) ||
                                                   htf.formselectoption( 'No Menu Bar, Title Underneath', 'SELECTED', cattributes=>'VALUE="B"' ) ||
                                                   htf.formselectoption( 'No Menu Bar, No Title', cattributes=>'VALUE="N"' ) ||
                                                   htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     elsif c1rec.fullimg_title_style = 'N'
      then
       htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( 'Title on Menu Bar', cattributes=>'VALUE="M"' ) ||
                                                   htf.formselectoption( 'No Menu Bar, Title Underneath', cattributes=>'VALUE="B"' ) ||
                                                   htf.formselectoption( 'No Menu Bar, No Title', 'SELECTED', cattributes=>'VALUE="N"' ) ||
                                                   htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_200 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'PFH' );
     htp.tabledata(htf.formtext( 'P2',30,100,c1rec.main_image_api_call),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;
   htp.nl;
   htp.nl;
   htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=0 border=0' );
    htp.tablerowopen;
     htp.tabledata('<BR><BR><BR><BR><BR><font color="#' || c1rec.fullimg_text_colour || '" FACE="' || c1rec.fullimg_text_font || '">'|| LNG3.ADM_TXT_217 || '</font><BR><BR><BR><BR><BR>',cattributes=>'bgcolor="' || c1rec.fullimg_back || '" valign="MIDDLE" align="CENTER"');
    htp.tablerowclose;
   htp.tableclose;

 elsif disp = 'CUSTOMER'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    disp_c2(surl,'P8A', c1rec.top_text_font, LNG3.ADM_TXT_213 );
    disp_c3(surl,'P8B', c1rec.top_text_colour, LNG3.ADM_TXT_214,'P1' );
    disp_c3(surl,'P8C', c1rec.top_back, LNG3.ADM_TXT_215,'P1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_015 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'P8D' );
     htp.tabledata(htf.formtext( 'P2',20,80,c1rec.top_frame_background),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.top_frame_background is null
      then
       htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata( htf.img(DECS.IMAGE_LOCATION || c1rec.top_frame_background,cattributes=>'border=0'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;
   htp.nl;
   htp.nl;
   htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=0 border=0' );
    htp.tablerowopen;
     htp.tabledata('<BR><BR><BR><BR><BR><font color="#' || c1rec.top_text_colour || '" FACE="' || c1rec.top_text_font || '">'|| LNG3.ADM_TXT_214 || '</font><BR><BR><BR><BR><BR>',cattributes=>'bgcolor="' || c1rec.top_back || '" valign="MIDDLE" align="CENTER"');
    htp.tablerowclose;
   htp.tableclose;

 elsif disp = 'GALLERY'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    disp_c2(surl,'P9A', c1rec.gallery_text_font, LNG3.ADM_TXT_216 );
    disp_c3(surl,'P9B', c1rec.gallery_text_colour, LNG3.ADM_TXT_217,'P1' );
    disp_c3(surl,'P9C', c1rec.gallery_back, LNG3.ADM_TXT_218,'P1' );
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;
   htp.nl;
   htp.nl;
   htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=0 border=0' );
    htp.tablerowopen;
     htp.tabledata('<BR><BR><BR><BR><BR><font color="#' || c1rec.gallery_text_colour || '" FACE="' || c1rec.gallery_text_font || '">'|| LNG3.ADM_TXT_217 || '</font><BR><BR><BR><BR><BR>',cattributes=>'bgcolor="' || c1rec.gallery_back || '" valign="MIDDLE" align="CENTER"');
    htp.tablerowclose;
   htp.tableclose;

 elsif disp = 'API'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_988 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'TFRAME' );
     htp.tabledata(htf.formtext( 'P2',60,100,c1rec.top_frame_api_call),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_022 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'BFRAME' );
     htp.tabledata(htf.formtext( 'P2',60,100,c1rec.bottom_frame_external),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_429 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'HPAGE' );
     htp.tabledata(htf.formtext( 'P2',60,100,c1rec.home_page_external_call),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_009 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'TNAIL' );
     htp.tabledata(htf.formtext( 'P2',60,100,c1rec.external_call),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_152 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'TNAILBOT' );
     htp.tabledata(htf.formtext( 'P2',60,100,c1rec.tnail_page_bottom),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_200 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'PFH' );
     htp.tabledata(htf.formtext( 'P2',60,100,c1rec.main_image_api_call),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_010 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'SHOP' );
     htp.tabledata(htf.formtext( 'P2',60,100,c1rec.shop_external_call),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_153 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'SHOW_CART' );
     htp.tabledata(htf.formtext( 'P2',60,100,c1rec.order_show_cart),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_154 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'SHOW_RECEIPT' );
     htp.tabledata(htf.formtext( 'P2',60,100,c1rec.order_show_receipt),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_400 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ORA4' );
     htp.tabledata(htf.formtext( 'P2',60,100,c1rec.order_bottom_external),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_402 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ORA5' );
     htp.tabledata(htf.formtext( 'P2',60,100,c1rec.ord_extra_col_api_call),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_317 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'SEARCH_BEFORE' );
     htp.tabledata(htf.formtext( 'P2',60,100,c1rec.search_before_entry_api),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_454 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'CONTACT_DET' );
     htp.tabledata(htf.formtext( 'P2',60,100,c1rec.contact_external_call),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_315 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'SEARCH_AFTER' );
     htp.tabledata(htf.formtext( 'P2',60,100,c1rec.search_after_entry_api),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_225 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'P5D' );
     htp.tabledata(htf.formtext( 'P2',60,100,c1rec.lhf_external_call),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    -- xxx for language file
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Greeting Card API Package Name' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'P5E' );
     htp.tabledata(htf.formtext( 'P2',60,100,c1rec.gcard_external_call),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;
   htp.nl;
   htp.nl;

 elsif disp = 'TITLE'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    disp_c2(surl,'P7A', c1rec.title_text_font, LNG3.ADM_TXT_198);
    disp_c3(surl,'P7B', c1rec.title_colour_font, LNG3.ADM_TXT_199,'P1' );
    disp_c3(surl,'P7C', c1rec.title_text_colour, LNG3.ADM_TXT_200,'P1' );
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;
   htp.nl;
   htp.nl;
   htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=0 border=0' );
    htp.tablerowopen;
     htp.tabledata('<b><font size="+6" color="#' || c1rec.title_colour_font || '" FACE="' || c1rec.title_text_font || '">'|| LNG3.ADM_TXT_199 || '</font></b>',cattributes=>'bgcolor="' || c1rec.title_text_colour || '" valign="MIDDLE" align="CENTER"');
    htp.tablerowclose;
   htp.tableclose;

 elsif disp = 'HOME'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    disp_c2(surl,'PTA', c1rec.det_title_font, LNG3.ADM_TXT_207 );
    disp_c3(surl,'PTB', c1rec.det_title_colour, LNG3.ADM_TXT_208,'P1' );
    disp_c3(surl,'PTC', c1rec.det_cell_back, LNG3.ADM_TXT_209,'P1' );
    disp_c2(surl,'P6A', c1rec.det_text_font, LNG3.ADM_TXT_210 );
    disp_c3(surl,'P6B', c1rec.det_text_colour, LNG3.ADM_TXT_211,'P1' );
    disp_c3(surl,'P6C', c1rec.det_back, LNG3.ADM_TXT_212,'P1' );
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;

 elsif disp = 'TABLE'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    disp_c3(surl,'THD', substr(c1rec.qbground,11,6), LNG4.AHC_TXT_115,'P1' );
    disp_c3(surl,'TCL', substr(c1rec.qcbground,11,6), LNG4.AHC_TXT_116,'P1' );
    disp_c3(surl,'PHV', c1rec.hover_colour, LNG3.ADM_TXT_197,'P1' );
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;
   htp.nl;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_115 ),cattributes=>c1rec.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( 'HIJKLM' ),cattributes=>c1rec.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_116 ),cattributes=>c1rec.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( 'YYYYY' ),cattributes=>c1rec.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( LNG4.AHC_TXT_116,cattributes=>c1rec.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( 'NNNNN',cattributes=>c1rec.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.italic( LNG4.AHC_TXT_116 ),cattributes=>c1rec.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.italic( 'SSSSSS' ),cattributes=>c1rec.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
   htp.tableclose;

 elsif disp = 'SECURITY'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_774 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.formhidden( 'P1', 'JAVASCRIPT' );
       htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
       htp.formselectopen( 'P2' );
       htp.formselectoption( NULL );
        if c1rec.javascript = 'DISABLE' then htp.formselectoption( 'DISABLE', 'SELECTED' ); else htp.formselectoption( 'DISABLE' ); end if;
       htp.formselectclose;
       htp.p( '</TD>' );
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_777 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.formhidden( 'P1', 'ICRA_LABEL' );
       if c1rec.icra_label is null
        then
         htp.tabledata(htf.formtext('P2',100,1000),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formtext('P2',100,1000, '&lt;' || replace(substr(c1rec.icra_label,2,length(c1rec.icra_label)-2),'"','&#34;') || '&gt;'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_122 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.debug_enabled = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','DBG','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','DBG'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;
   htp.nl;

 elsif disp = 'THUMBNAIL'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_430 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ITDC' );
      htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
      htp.formselectopen( 'P2' );
      if c1rec.tnail_control_style = 'Standard'
       then
        htp.formselectoption( 'Standard', 'SELECTED' );
       else
        htp.formselectoption( 'Standard' );
      end if;
      if c1rec.tnail_control_style = 'Grouped'
       then
        htp.formselectoption( 'Grouped', 'SELECTED' );
       else
        htp.formselectoption( 'Grouped' );
      end if;
      if c1rec.tnail_control_style = 'Grouped with Title'
       then
        htp.formselectoption( 'Grouped with Title', 'SELECTED' );
       else
        htp.formselectoption( 'Grouped with Title' );
      end if;
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_201 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ITD' );
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.formselectopen( 'P2' );
      if nvl(c1rec.display_style,'F') = 'F'
       then
        htp.formselectoption( LNG3.ADM_TXT_619,'SELECTED', cattributes=>'VALUE="F"' );
       else
        htp.formselectoption( LNG3.ADM_TXT_619, cattributes=>'VALUE="F"' );
      end if;
      if nvl(c1rec.display_style,'F') = 'T'
       then
        htp.formselectoption( LNG4.AHC_TXT_396,'SELECTED', cattributes=>'VALUE="T"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_396, cattributes=>'VALUE="T"' );
      end if;
      if nvl(c1rec.display_style,'F') = 'S'
       then
        htp.formselectoption( LNG4.AHC_TXT_417,'SELECTED', cattributes=>'VALUE="S"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_417, cattributes=>'VALUE="S"' );
      end if;
      if nvl(c1rec.display_style,'F') = 'V'
       then
        htp.formselectoption( LNG4.AHC_TXT_418,'SELECTED', cattributes=>'VALUE="V"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_418, cattributes=>'VALUE="V"' );
      end if;
      if nvl(c1rec.display_style,'F') = 'M'
       then
        htp.formselectoption( LNG4.AHC_TXT_727,'SELECTED', cattributes=>'VALUE="M"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_727, cattributes=>'VALUE="M"' );
      end if;
      if nvl(c1rec.display_style,'F') = 'P'
       then
        htp.formselectoption( LNG4.AHC_TXT_786,'SELECTED', cattributes=>'VALUE="P"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_786, cattributes=>'VALUE="P"' );
      end if;
      if nvl(c1rec.display_style,'F') = 'D'
       then
        htp.formselectoption( LNG5.EXT_TXT_202,'SELECTED', cattributes=>'VALUE="D"' );
       else
        htp.formselectoption( LNG5.EXT_TXT_202, cattributes=>'VALUE="D"' );
      end if;
      if nvl(c1rec.display_style,'F') = 'X'
       then
        htp.formselectoption( LNG4.AHC_TXT_427,'SELECTED', cattributes=>'VALUE="X"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_427, cattributes=>'VALUE="X"' );
      end if;
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_009 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'EXCALL' );
     htp.tabledata(htf.formtext( 'P2', 30, 100, c1rec.external_call ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;

    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_784 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ITS' );
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.formselectopen( 'P2' );
      htp.formselectoption( NULL );
      if c1rec.shop_style = 'F'
       then
        htp.formselectoption( LNG3.ADM_TXT_619,'SELECTED', cattributes=>'VALUE="F"' );
       else
        htp.formselectoption( LNG3.ADM_TXT_619, cattributes=>'VALUE="F"' );
      end if;
      if c1rec.shop_style = 'T'
       then
        htp.formselectoption( LNG4.AHC_TXT_396,'SELECTED', cattributes=>'VALUE="T"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_396, cattributes=>'VALUE="T"' );
      end if;
      if c1rec.shop_style = 'S'
       then
        htp.formselectoption( LNG4.AHC_TXT_417,'SELECTED', cattributes=>'VALUE="S"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_417, cattributes=>'VALUE="S"' );
      end if;
      if c1rec.shop_style = 'V'
       then
        htp.formselectoption( LNG4.AHC_TXT_418,'SELECTED', cattributes=>'VALUE="V"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_418, cattributes=>'VALUE="V"' );
      end if;
      if c1rec.shop_style = 'M'
       then
        htp.formselectoption( LNG4.AHC_TXT_727,'SELECTED', cattributes=>'VALUE="M"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_727, cattributes=>'VALUE="M"' );
      end if;
      if c1rec.shop_style = 'P'
       then
        htp.formselectoption( LNG4.AHC_TXT_786,'SELECTED', cattributes=>'VALUE="P"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_786, cattributes=>'VALUE="P"' );
      end if;
      if c1rec.shop_style = 'D'
       then
        htp.formselectoption( LNG5.EXT_TXT_202,'SELECTED', cattributes=>'VALUE="D"' );
       else
        htp.formselectoption( LNG5.EXT_TXT_202, cattributes=>'VALUE="D"' );
      end if;
      if c1rec.shop_style = 'X'
       then
        htp.formselectoption( LNG4.AHC_TXT_427,'SELECTED', cattributes=>'VALUE="X"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_427, cattributes=>'VALUE="X"' );
      end if;
      htp.p( '</TD>' );
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_010 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'SHOPEX' );
     htp.tabledata(htf.formtext( 'P2', 30, 100, c1rec.shop_external_call ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;

    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_123 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'TGL1' );
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.formselectopen( 'P2' );
      htp.formselectoption( NULL );
      if c1rec.toggle_style = 'F'
       then
        htp.formselectoption( LNG3.ADM_TXT_619,'SELECTED', cattributes=>'VALUE="F"' );
       else
        htp.formselectoption( LNG3.ADM_TXT_619, cattributes=>'VALUE="F"' );
      end if;
      if c1rec.toggle_style = 'T'
       then
        htp.formselectoption( LNG4.AHC_TXT_396,'SELECTED', cattributes=>'VALUE="T"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_396, cattributes=>'VALUE="T"' );
      end if;
      if c1rec.toggle_style = 'S'
       then
        htp.formselectoption( LNG4.AHC_TXT_417,'SELECTED', cattributes=>'VALUE="S"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_417, cattributes=>'VALUE="S"' );
      end if;
      if c1rec.toggle_style = 'V'
       then
        htp.formselectoption( LNG4.AHC_TXT_418,'SELECTED', cattributes=>'VALUE="V"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_418, cattributes=>'VALUE="V"' );
      end if;
      if c1rec.toggle_style = 'M'
       then
        htp.formselectoption( LNG4.AHC_TXT_727,'SELECTED', cattributes=>'VALUE="M"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_727, cattributes=>'VALUE="M"' );
      end if;
      if c1rec.toggle_style = 'P'
       then
        htp.formselectoption( LNG4.AHC_TXT_786,'SELECTED', cattributes=>'VALUE="P"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_786, cattributes=>'VALUE="P"' );
      end if;
      if c1rec.toggle_style = 'D'
       then
        htp.formselectoption( LNG5.EXT_TXT_202,'SELECTED', cattributes=>'VALUE="D"' );
       else
        htp.formselectoption( LNG5.EXT_TXT_202, cattributes=>'VALUE="D"' );
      end if;
      if c1rec.toggle_style = 'X'
       then
        htp.formselectoption( LNG4.AHC_TXT_427,'SELECTED', cattributes=>'VALUE="X"' );
       else
        htp.formselectoption( LNG4.AHC_TXT_427, cattributes=>'VALUE="X"' );
      end if;
      htp.p( '</TD>' );
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_124 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'TGL2' );
     htp.tabledata(htf.formtext( 'P2', 30, 100, c1rec.toggle_external_call ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;

    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_385 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ICN' );
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">');
     htp.formselectopen( 'P2' );
     if c1rec.image_counter_style = 'N'
      then
       htp.formselectoption( LNG.PHG_TXT_443, 'SELECTED', cattributes=>'VALUE="N"' );
      else
       htp.formselectoption( LNG.PHG_TXT_443, cattributes=>'VALUE="N"' );
     end if;
     if c1rec.image_counter_style = 'P'
      then
       htp.formselectoption( LNG4.AHC_TXT_386, 'SELECTED', cattributes=>'VALUE="P"' );
      else
       htp.formselectoption( LNG4.AHC_TXT_386, cattributes=>'VALUE="P"' );
     end if;
     if c1rec.image_counter_style = 'L'
      then
       htp.formselectoption( LNG4.AHC_TXT_416, 'SELECTED', cattributes=>'VALUE="L"' );
      else
       htp.formselectoption( LNG4.AHC_TXT_416, cattributes=>'VALUE="L"' );
     end if;
     if c1rec.image_counter_style = 'M'
      then
       htp.formselectoption( LNG4.AHC_TXT_728, 'SELECTED', cattributes=>'VALUE="M"' );
      else
       htp.formselectoption( LNG4.AHC_TXT_728, cattributes=>'VALUE="M"' );
     end if;
     if c1rec.image_counter_style = '3'
      then
       htp.formselectoption( LNG5.EXT_TXT_211, 'SELECTED', cattributes=>'VALUE="3"' );
      else
       htp.formselectoption( LNG5.EXT_TXT_211, cattributes=>'VALUE="3"' );
     end if;
     if c1rec.image_counter_style = 'X'
      then
       htp.formselectoption( LNG.SLD_TXT_021, 'SELECTED', cattributes=>'VALUE="X"' );
      else
       htp.formselectoption( LNG.SLD_TXT_021, cattributes=>'VALUE="X"' );
     end if;
     htp.formselectclose;
     htp.p( '</TD>' );
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_424 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'ICD' );
     htp.tabledata(htf.formtext( 'P2', 5, 1, c1rec.page_delim ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_425 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.use_line = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','ICL','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','ICL'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_595 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.formhidden( 'P1', 'GAP' );
       htp.tabledata(htf.formtext('P2',10,20,c1rec.gap),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_961 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.tnail_disp_sml_font = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','ICZ','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','ICZ'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    disp_c3(surl,'ITNX1', c1rec.uline, LNG4.AHC_TXT_970,'P1' );
    disp_c3(surl,'ITNX2', c1rec.uline_active, LNG5.EXT_TXT_034,'P1' );
    disp_c3(surl,'ITNX3', c1rec.uline_visited, LNG5.EXT_TXT_035,'P1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_146 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.formhidden( 'P1', 'ACTIVE_LINK' );
       if c1rec.tnail_underline_active = 'ACTIVE'
        then
         htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( LNG.PHG_TXT_045,'SELECTED', cattributes=>'VALUE="ACTIVE"' ) || htf.formselectoption( LNG.PHG_TXT_046, cattributes=>'VALUE="NOTACTIVE"' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formselectopen( 'P2' ) || htf.formselectoption( LNG.PHG_TXT_045, cattributes=>'VALUE="ACTIVE"' ) || htf.formselectoption( LNG.PHG_TXT_046,'SELECTED', cattributes=>'VALUE="NOTACTIVE"' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_971 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.formhidden( 'P1', 'ICV' );
       htp.tabledata(htf.formtext('P2',10,20,c1rec.tnumb_adj),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_453 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.tnail_disable_top = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','INDT','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','INDT'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_208 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.tnail_inc_simple = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','INCS','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','INCS'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_209 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.tnail_inc_privacy = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','INCT','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','INCT'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_241 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if nvl(substr(c1rec.tnail_control_buttons,1,1),'T') = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','INC_CTLT','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','INC_CTLT'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_242 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if nvl(substr(c1rec.tnail_control_buttons,2,1),'T') = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','INC_CTLB','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','INC_CTLB'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    -- xxx language file
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Small Button API Call' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.formhidden( 'P1', 'SML_API' );
       htp.tabledata(htf.formtext('P2',40,1000,c1rec.sml_button_api),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Small Button API Call - Display Text' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.formhidden( 'P1', 'SML_API_TXT' );
       htp.tabledata(htf.formtext('P2',40,100,c1rec.sml_button_api_txt),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;


 elsif disp = 'META'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_394 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.meta_header = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','MGR','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','MGR'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_397 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.meta_category = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','MGC','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','MGC'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    disp_c3(surl,'MET', substr(c1rec.meta_bground,11,6), LNG4.AHC_TXT_118,'P1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_393 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'MTB' );
     htp.tabledata(htf.formtext( 'P2', 30, 100, c1rec.meta_table ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;
   htp.nl;

 elsif disp = 'VERT'
  then
   htp.bold( LNG5.EXT_TXT_350 );
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_390 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c1rec.vert_header = 'T'
        then
         htp.tabledata(htf.formcheckbox('P3','VHDR','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(htf.formcheckbox('P3','VHDR'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    disp_c3(surl,'VCP', c1rec.caption_text_colour, LNG4.AHC_TXT_384,'P1' );
    disp_c2(surl,'VCF', c1rec.caption_text_font, LNG4.AHC_TXT_383 );
    disp_c3(surl,'VCA', c1rec.vert_colour_a, LNG.PHG_TXT_171,'P1' );
    disp_c3(surl,'VCB', c1rec.vert_colour_b, LNG.PHG_TXT_172,'P1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_382 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'VTB' );
     htp.tabledata(htf.formtext( 'P2', 30, 100, c1rec.vertical_disp_table ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.bold( LNG5.EXT_TXT_351 );
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG5.EXT_TXT_212),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
    if c1rec.tnail_global_border = 'T'
     then
      htp.tabledata( htf.formcheckbox( 'P3', 'VSA', 'CHECKED' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
     else
      htp.tabledata( htf.formcheckbox( 'P3', 'VSA' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
    end if;
    htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   disp_c3(surl,'VSA2', c1rec.tnail_global_colour, LNG5.EXT_TXT_213,'P1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_215 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'VSA3' );
     htp.tabledata(htf.formtext( 'P2', 10, 20, c1rec.tnail_global_offset ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_214 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P1', 'VSA4' );
     htp.tabledata(htf.formtext( 'P2', 10, 20, c1rec.tnail_global_spacer ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;&nbsp;&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.bold( LNG5.EXT_TXT_203 );
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG5.EXT_TXT_204),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER" COLSPAN="6"' );
   htp.tablerowclose;
   htp.formhidden( 'P1', 'VSS' );
   htp.tablerowopen;
    c1rec.slider_style := nvl(c1rec.slider_style,'1');
    if c1rec.slider_style = '1' then chk := 'CHECKED'; else chk := NULL; end if;
    htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/slider_1.gif',cattributes=>' border=0' ) || htf.nl || htf.formradio( 'P2', '1', chk ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
    if c1rec.slider_style = '2' then chk := 'CHECKED'; else chk := NULL; end if;
    htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/slider_2.gif',cattributes=>' border=0' ) || htf.nl || htf.formradio( 'P2', '2', chk ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
    if c1rec.slider_style = '3' then chk := 'CHECKED'; else chk := NULL; end if;
    htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/slider_3.gif',cattributes=>' border=0' ) || htf.nl || htf.formradio( 'P2', '3', chk ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
    if c1rec.slider_style = '4' then chk := 'CHECKED'; else chk := NULL; end if;
    htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/slider_4.gif',cattributes=>' border=0' ) || htf.nl || htf.formradio( 'P2', '4', chk ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
    if c1rec.slider_style = '5' then chk := 'CHECKED'; else chk := NULL; end if;
    htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/slider_5.gif',cattributes=>' border=0' ) || htf.nl || htf.formradio( 'P2', '5', chk ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
    if c1rec.slider_style = '6' then chk := 'CHECKED'; else chk := NULL; end if;
    htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/slider_6.gif',cattributes=>' border=0' ) || htf.nl || htf.formradio( 'P2', '6', chk ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
   htp.formhidden( 'P1', 'VSTA' );
   htp.p( '<TD COLSPAN="2" ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER">' );
   htp.bold( 'A' ); htp.nl;
    htp.formselectopen( 'P2' );
    if substr(c1rec.slider_choice,1,1) = 'M'
     then
      htp.formselectoption( LNG5.EXT_TXT_205, 'SELECTED', cattributes=>'VALUE="' || 'M' || '"');
     else
      htp.formselectoption( LNG5.EXT_TXT_205, cattributes=>'VALUE="' || 'M' || '"');
    end if;
    if substr(c1rec.slider_choice,1,1) = 'T'
     then
      htp.formselectoption( LNG5.EXT_TXT_206, 'SELECTED', cattributes=>'VALUE="' || 'T' || '"');
     else
      htp.formselectoption( LNG5.EXT_TXT_206, cattributes=>'VALUE="' || 'T' || '"');
    end if;
    if substr(c1rec.slider_choice,1,1) = 'S'
     then
      htp.formselectoption( LNG.GLB_TXT_092, 'SELECTED', cattributes=>'VALUE="' || 'S' || '"');
     else
      htp.formselectoption( LNG.GLB_TXT_092, cattributes=>'VALUE="' || 'S' || '"');
    end if;
    htp.formselectclose;
   htp.p( '</TD>' );
   htp.formhidden( 'P1', 'VSTB' );
   htp.p( '<TD COLSPAN="2" ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER">' );
   htp.bold( 'B' ); htp.nl;
    htp.formselectopen( 'P2' );
    if substr(c1rec.slider_choice,2,1) = 'M'
     then
      htp.formselectoption( LNG5.EXT_TXT_205, 'SELECTED', cattributes=>'VALUE="' || 'M' || '"');
     else
      htp.formselectoption( LNG5.EXT_TXT_205, cattributes=>'VALUE="' || 'M' || '"');
    end if;
    if substr(c1rec.slider_choice,2,1) = 'T'
     then
      htp.formselectoption( LNG5.EXT_TXT_206, 'SELECTED', cattributes=>'VALUE="' || 'T' || '"');
     else
      htp.formselectoption( LNG5.EXT_TXT_206, cattributes=>'VALUE="' || 'T' || '"');
    end if;
    if substr(c1rec.slider_choice,2,1) = 'S'
     then
      htp.formselectoption( LNG.GLB_TXT_092, 'SELECTED', cattributes=>'VALUE="' || 'S' || '"');
     else
      htp.formselectoption( LNG.GLB_TXT_092, cattributes=>'VALUE="' || 'S' || '"');
    end if;
    htp.formselectclose;
   htp.p( '</TD>' );
   htp.formhidden( 'P1', 'VSTC' );
   htp.p( '<TD COLSPAN="2" ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER">' );
   htp.bold( 'C' ); htp.nl;
    htp.formselectopen( 'P2' );
    htp.formselectoption( NULL );
    if substr(c1rec.slider_choice,3,1) = 'M'
     then
      htp.formselectoption( LNG5.EXT_TXT_205, 'SELECTED', cattributes=>'VALUE="' || 'M' || '"');
     else
      htp.formselectoption( LNG5.EXT_TXT_205, cattributes=>'VALUE="' || 'M' || '"');
    end if;
    if substr(c1rec.slider_choice,3,1) = 'T'
     then
      htp.formselectoption( LNG5.EXT_TXT_206, 'SELECTED', cattributes=>'VALUE="' || 'T' || '"');
     else
      htp.formselectoption( LNG5.EXT_TXT_206, cattributes=>'VALUE="' || 'T' || '"');
    end if;
    if substr(c1rec.slider_choice,3,1) = 'S'
     then
      htp.formselectoption( LNG.GLB_TXT_092, 'SELECTED', cattributes=>'VALUE="' || 'S' || '"');
     else
      htp.formselectoption( LNG.GLB_TXT_092, cattributes=>'VALUE="' || 'S' || '"');
    end if;
    htp.formselectclose;
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold( LNG5.EXT_TXT_210 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"');
    htp.formhidden( 'P1', 'VSTD' );
    htp.p( '<TD COLSPAN="4" ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER">' );
    htp.formselectopen( 'P2' );
     if c1rec.slider_search_style = 'STANDARD'
      then
       htp.formselectoption( 'STANDARD', 'SELECTED');
      else
       htp.formselectoption( 'STANDARD');
     end if;
     if c1rec.slider_search_style = 'SIMPLE'
      then
       htp.formselectoption( 'SIMPLE', 'SELECTED');
      else
       htp.formselectoption( 'SIMPLE');
     end if;
     if c1rec.slider_search_style = 'MULTIPLE'
      then
       htp.formselectoption( 'MULTIPLE', 'SELECTED');
      else
       htp.formselectoption( 'MULTIPLE');
     end if;
     if c1rec.slider_search_style = 'LIST_CATEGORIES'
      then
       htp.formselectoption( 'LIST_CATEGORIES', 'SELECTED');
      else
       htp.formselectoption( 'LIST_CATEGORIES');
     end if;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;
   htp.nl;

 elsif disp = 'ERROR'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    disp_c3(surl,'M1A', c1rec.error_text_colour, LNG3.ADM_TXT_949,'P1');
    disp_c2(surl,'M1B', c1rec.error_text_font, LNG3.ADM_TXT_950 );
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;
   htp.nl;
   htp.nl;
   htp.p('<font size="+3" color="#' || c1rec.error_text_colour || '" FACE="' || c1rec.error_text_font || '">'|| LNG3.ADM_TXT_949 || '</font>' );
   htp.nl;

 elsif disp = 'NESTED'
  then
   show_nested;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;

 elsif disp = 'ICONS_STND'
  then
   mnt_icons( surl, c1rec, disp );

 elsif disp = 'ICONS_CUST'
  then
   mnt_icons( surl, c1rec, disp );
   htp.nl;
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_221 );
   htp.formclose;

 elsif disp = 'ICONS_ALL'
  then
   mnt_icons( surl, c1rec, disp );

 elsif disp = 'UTILITIES'
  then
   htp.nl;
   htp.formopen( 'lf.copy_data' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'P1', thm );
   htp.formhidden( 'TYP', 'LF' );
   htp.formtext( 'P2', 30, 100, LNG2.PFM_TXT_154 || '_' || thm );
   htp.nl;
   htp.formsubmit( null, initcap(LNG2.PFM_TXT_154) );
   htp.formclose;
   htp.nl;
   htp.line;
   htp.nl;
   /*
   htp.formopen( 'lf.xml_unload' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl) );
   htp.formhidden( 'TYP','LAF' );
   htp.formhidden( 'P1',thm );
   htp.italic( LNG3.ADM_TXT_181 || ': ' || htf.formtext( 'P2',30, 100,lower(replace(thm,' ','_') || '.txt' )));
   htp.nl;
   htp.formsubmit( null, LNG3.ADM_TXT_225 );
   htp.formclose;
   htp.nl;
   */
   htp.line;
   htp.nl;

   open c4(thm);
   fetch c4 into tot;
   close c4;
   if tot = 0
    then
     htp.formopen( 'lf.del_lf', ctarget=>'_top' );
     htp.formhidden( 'SURL', surl );
     htp.formhidden( 'P1', thm );
     htp.formsubmit( null, LNG3.ADM_TXT_222 );
     htp.formclose;
   end if;
 end if;

 htp.nl;
 htp.nl;
 htp.anchor2( 'lf.colour_palette?surl=' || glbx.rndsurl(surl), LNG3.ADM_TXT_821, ctarget=>'COLOUR_PALETTE' );
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LF', 'THEME_RIGHT', errmsg=>sqlerrm, extdet=>null);
end theme_right;

procedure del_lf( surl varchar2, p1 in varchar2 )
as

 sessid		integer;
 sts		varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.DEL_LF');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 delete from theme where theme_name = p1;
 delete from screen_controller where theme_name = p1;
 update photographer set default_lf = NULL where default_lf = p1;
 delete from limit_laf where theme_name = p1;
 commit;
 htp.htmlopen;
 htp.header(2,LNG3.ADM_TXT_228,'CENTER');
 htp.nl;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 htp.nl;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LF', 'DEL_LF', errmsg=>sqlerrm, extdet=>null);
end del_lf;

procedure accept_theme( surl varchar2, thm in varchar2, disp in varchar2, newtheme in varchar2 default 'F', action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, row1 in GLBX.MYARRAY, row2 in GLBX.MYARRAY, row3 in GLBX.MYARRAY, row4 in GLBX.MYARRAY)
as

 cursor c1( new_theme varchar2 ) is select 'x' from theme where theme_name = new_theme;

 sessid		integer;
 sts		varchar2(200);
 trec		THEME%ROWTYPE;
 s_exists	boolean;
 theme_exists	char(1);
 rp1		varchar2(100);
 r1		varchar2(10);
 r2		varchar2(10);
 r3		varchar2(10);
 r4		varchar2(10);

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

 function lf_locked(thm in varchar2)
  return boolean
 as
  cursor c1(thm varchar2) is select is_locked from theme where theme_name = thm;
  c1rec  c1%ROWTYPE;
 begin
  open c1(thm);
  fetch c1 into c1rec;
  close c1;
  if c1rec.is_locked = 'T' then return( TRUE ); end if;
  return( FALSE );
 end lf_locked;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.ACCEPT_THEME');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if disp = 'SHAPE'
  then

   trec.is_locked  := getcheck( 'P1LCK', p3 );
   trec.theme_name := getval( 'NAME', p1, p2 );
   trec.theme_descript := getval( 'DESCRIPTION', p1, p2 );
   trec.disp_prefix := getval( 'PREFIX', p1, p2 );
   trec.expire_template := getval( 'EXPTEMP', p1, p2 );
   trec.stylesheet := getval( 'STYLESHEET', p1, p2 );
   trec.scene_position := getval( 'PFE', p1, p2 );
   trec.keep_lhf  := getval( 'PFL', p1, p2 );
   trec.disploc  := getval( 'P3A', p1, p2 );
   trec.uses_boundary  := getcheck( 'P1X', p3 );
   if getcheck( 'PCB', p3 ) = 'F'
    then
     trec.separate_customer_bt  := 'FFFFFFFFFF';
    else
     trec.separate_customer_bt  := 'T';
   end if;
   trec.phg_but_scene  := getval( 'PFG', p1, p2 );
   trec.cus_but_scene  := getcheck( 'PFH', p3 );
   trec.sim_three_frame := 'F'; --getcheck( 'PF3', p3 );
   trec.frame_border  := getval( 'PFA', p1, p2 );
   trec.border_around_scene  := getval( 'PFB', p1, p2 );
   trec.display_bullet  := getcheck( 'PFD', p3 );

   if trec.theme_name is null
     then
     -- New Theme Must Have a Name
      theme_right( surl, thm, disp, LNG3.ADM_TXT_226 );
      return;
    end if;

   if trec.keep_lhf in ('2','N')
    then
     trec.nested_scene_style := LNG3.ADM_TXT_576;
     trec.disploc := 'T';
     trec.scene_position := 'T';
    else
     trec.nested_scene_style := NULL;
   end if;

   if trec.keep_lhf in ('2','N') and trec.scene_position <> 'T'
    then
     theme_right( surl,thm,disp,LNG3.ADM_TXT_800 );
     return;
   end if;

   if trec.keep_lhf in ('2','N') and trec.disploc <> 'T'
    then
     theme_right( surl,thm,disp,LNG3.ADM_TXT_800 );
     return;
   end if;

   if newtheme = 'T'
    then
     rp1 := glbx.strip_special_characters( trec.theme_name );
     if rp1 is null
      then
       theme_right( surl,thm,disp,LNG4.AHC_TXT_335 );
       return;
     end if;
     open c1(rp1);
     fetch c1 into theme_exists;
     if c1%FOUND
      then
       close c1;
       theme_right( surl,thm,disp,LNG3.ADM_TXT_444 );
       return;
     end if;
     close c1;
     insert into theme
     (theme_name,theme_descript,disp_prefix,scene_position,nested_scene_style,keep_lhf,disploc,uses_boundary,phg_but_scene,
      cus_but_scene,frame_border,border_around_scene,display_bullet,sf_table_width,tnail_control_style,expire_template,stylesheet,
      qbground,qcbground,meta_bground,vertical_disp_table,image_counter_style,meta_header,meta_table,meta_category,vert_colour_a,vert_colour_b,separate_customer_bt,is_locked)
     values
     (rp1,trec.theme_descript,trec.disp_prefix,trec.scene_position,nvl(trec.nested_scene_style,'L'),trec.keep_lhf,trec.disploc,trec.uses_boundary,trec.phg_but_scene,
      trec.cus_but_scene,trec.frame_border,trec.border_around_scene,trec.display_bullet,'width=100%','Standard',trec.expire_template,trec.stylesheet,
      GLBX.QUERY_BACKGROUND,GLBX.QUERY_CELL_BACKGROUND,GLBX.QUERY_CELL_BACKGROUND,'cellpadding=2 cellspacing=2 border=1','N','T','cellpadding=2 cellspacing=2 border=1','T','FFFFFF','FFFFFF','N',trec.is_locked);
     insert into screen_controller(theme_name,controller,ctype,v_screen_0,n_screen_0,v_screen_1,n_screen_1,v_screen_2,n_screen_2,v_screen_3,n_screen_3,v_screen_4,n_screen_4,v_screen_5,n_screen_5,v_screen_6,n_screen_6,v_screen_7,n_screen_7)
      select rp1,controller,ctype,v_screen_0,n_screen_0,v_screen_1,n_screen_1,v_screen_2,n_screen_2,v_screen_3,n_screen_3,v_screen_4,n_screen_4,v_screen_5,n_screen_5,v_screen_6,n_screen_6,v_screen_7,n_screen_7
      from screen_controller
      where theme_name = 'DEFAULT';
    else
     rp1 := glbx.strip_special_characters( trec.theme_name );
     if rp1 is null
      then
       theme_right( surl,thm,disp,LNG4.AHC_TXT_335 );
       return;
     end if;
     if rp1 <> thm
      then
       open c1(rp1);
       fetch c1 into theme_exists;
       if c1%FOUND
        then
         close c1;
         theme_right( surl,thm,disp,LNG3.ADM_TXT_444 );
         return;
       end if;
       close c1;
     end if;
     update theme
      set
       theme_name = rp1,
       theme_descript = trec.theme_descript,
       disp_prefix = trec.disp_prefix,
       scene_position = trec.scene_position,
       nested_scene_style = nvl(trec.nested_scene_style,nested_scene_style),
       keep_lhf = trec.keep_lhf,
       disploc = trec.disploc,
       uses_boundary = trec.uses_boundary,
       expire_template = trec.expire_template,
       stylesheet = trec.stylesheet,
       phg_but_scene = trec.phg_but_scene,
       cus_but_scene = trec.cus_but_scene,
       frame_border = trec.frame_border,
       sim_three_frame = trec.sim_three_frame,
       border_around_scene = trec.border_around_scene,
       separate_customer_bt = decode(substr(trec.separate_customer_bt,1,1),'F',trec.separate_customer_bt,
                                     decode(substr(separate_customer_bt,1,1),'F','TTTTTTTTTT',
                                     'T' || substr(separate_customer_bt,2))),
       is_locked = trec.is_locked,
       display_bullet = trec.display_bullet
    where theme_name = thm;
   end if;

 elsif disp = 'NOFRAME'
  then
   s_exists := FALSE;
   for j in row1.first..row1.last loop
    if substr(row1(j),1,1) in ('S','Q') and s_exists
     then
      NULL;
     else
      r1 := r1 || substr(row1(j),1,1);
    end if;
    if substr(row1(j),1,1) in ('S','Q') then s_exists := TRUE; end if;
   end loop;
   for j in row2.first..row2.last loop
    if substr(row2(j),1,1) in ('S','Q') and s_exists
     then
      NULL;
     else
      r2 := r2 || substr(row2(j),1,1);
    end if;
    if substr(row2(j),1,1) in ('S','Q') then s_exists := TRUE; end if;
   end loop;
   for j in row3.first..row3.last loop
    if substr(row3(j),1,1) in ('S','Q') and s_exists
     then
      NULL;
     else
      r3 := r3 || substr(row3(j),1,1);
    end if;
    if substr(row3(j),1,1) in ('S','Q') then s_exists := TRUE; end if;
   end loop;
   for j in row4.first..row4.last loop
    if substr(row4(j),1,1) in ('S','Q') and s_exists
     then
      NULL;
     else
      r4 := r4 || substr(row4(j),1,1);
    end if;
    if substr(row4(j),1,1) in ('S','Q') then s_exists := TRUE; end if;
   end loop;
   trec.sf_table_width  := getval( 'SF1', p1, p2 );
   trec.top_frame_api_call  := getval( 'TOPAPI', p1, p2 );
   trec.sf_bg_img  := getval( 'SF2', p1, p2 );
   trec.sf_bg_cellspc  := getval( 'SF6', p1, p2 );
   trec.sf_bg_cell_width  := getval( 'SF3', p1, p2 );
   trec.sf_bg_cell_height  := getval( 'SF4', p1, p2 );
   trec.sf_bg_valign  := getval( 'SF5', p1, p2 );
   begin trec.top_padding := getval( 'TOP_PADDING', p1, p2 ); exception when others then trec.top_padding := 5; end;
   begin trec.left_padding := getval( 'LEFT_PADDING', p1, p2 ); exception when others then trec.left_padding := 5; end;

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;

   update theme
    set
     row1 = r1,
     row2 = r2,
     row3 = r3,
     row4 = r4,
     top_padding = trec.top_padding,
     top_frame_api_call = trec.top_frame_api_call,
     left_padding = trec.left_padding,
     sf_table_width = replace(trec.sf_table_width,'"',''),
     sf_bg_img = trec.sf_bg_img,
     sf_bg_cellspc = trec.sf_bg_cellspc,
     sf_bg_cell_width = trec.sf_bg_cell_width,
     sf_bg_cell_height = trec.sf_bg_cell_height,
     sf_bg_valign = trec.sf_bg_valign
    where theme_name = thm;

 elsif disp = 'MATTE'
  then
   trec.tnail_matte_colour  := getval( 'M3A', p1, p2 );
   trec.tnail_border_colour  := getval( 'M3D', p1, p2 );
   trec.tnail_border_colour_l  := getval( 'M3E', p1, p2 );
   trec.matte_border_style  := getval( 'M3G', p1, p2 );
   begin trec.tnail_width  := getval( 'M3B', p1, p2 ); exception when others then trec.tnail_width := 0; end;
   begin trec.tnail_border  := getval( 'M3C', p1, p2 ); exception when others then trec.tnail_border := 0; end;

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     tnail_matte_colour = trec.tnail_matte_colour,
     tnail_border_colour = trec.tnail_border_colour,
     tnail_border_colour_l = trec.tnail_border_colour_l,
     tnail_width = trec.tnail_width,
     tnail_border = trec.tnail_border,
     matte_border_style = trec.matte_border_style
    where theme_name = thm;

 elsif disp = 'INSTRUCTION'
  then
   trec.instruct_text_colour  := getval( 'M2A', p1, p2 );
   trec.instruct_text_font  := getval( 'M2B', p1, p2 );
   trec.instruct_align   := getval( 'M2C', p1, p2 );
   trec.instruct_cell_colour  := getval( 'M2D', p1, p2 );
   trec.instruct_cell_brd_clr  := getval( 'M2G', p1, p2 );
   begin trec.instruct_cell_border  := getval( 'M2E', p1, p2 ); exception when others then trec.instruct_cell_border := 0; end;
   begin trec.instruct_font_inc  := getval( 'M2F', p1, p2 ); exception when others then trec.instruct_font_inc := 0; end;

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     instruct_text_colour = trec.instruct_text_colour,
     instruct_text_font = trec.instruct_text_font,
     instruct_align = trec.instruct_align,
     instruct_cell_colour = trec.instruct_cell_colour,
     instruct_cell_brd_clr = trec.instruct_cell_brd_clr,
     instruct_cell_border = trec.instruct_cell_border,
     instruct_font_inc = trec.instruct_font_inc
    where theme_name = thm;

 elsif disp = 'STANDARD'
  then
   trec.text_font  := getval( 'P4A', p1, p2 );
   trec.text_colour  := getval( 'P4B', p1, p2 );
   trec.text_back  := getval( 'P4C', p1, p2 );
   trec.underline_active  := getval( 'STD_ACTIVE_LINK', p1, p2 );
   begin trec.text_font_inc  := getval( 'P4D', p1, p2 ); exception when others then trec.text_font_inc := 0; end;
   trec.anchor_text_font  := getval( 'PCA', p1, p2 );
   trec.anchor_text_colour  := getval( 'PCB', p1, p2 );
   begin trec.anchor_font_adj  := getval( 'PCD', p1, p2 ); exception when others then trec.text_font_inc := 0; end;
   trec.anchor_type  := getval( 'PCC', p1, p2 );

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     text_font = trec.text_font,
     text_colour = trec.text_colour,
     text_back = trec.text_back,
     text_font_inc = trec.text_font_inc,
     underline_active = trec.underline_active,
     anchor_text_font = trec.anchor_text_font,
     anchor_text_colour = trec.anchor_text_colour,
     anchor_font_adj = trec.anchor_font_adj,
     anchor_type = trec.anchor_type
    where theme_name = thm;

 elsif disp = 'LHF'
  then
   trec.lhs_text_font  := getval( 'P5A', p1, p2 );
   trec.lhs_text_colour  := getval( 'P5B', p1, p2 );
   trec.lhs_back  := getval( 'P5C', p1, p2 );
   trec.lhf_external_call  := getval( 'P5D', p1, p2 );
   trec.gcard_external_call  := getval( 'P5E', p1, p2 );
   trec.lhf_subdir              := getval( 'P5LHF1', p1, p2 );
   trec.lhf_backimg             := getval( 'P5LHF2', p1, p2 );
   trec.lhf_clickable_img       := getval( 'P5LHF3', p1, p2 );
   trec.lhf_clickable_position  := getval( 'P5LHF4', p1, p2 );
   trec.lhf_clickable_anchor    := getval( 'P5LHF5', p1, p2 );
   trec.lhf_clickable_target    := getval( 'P5LHF6', p1, p2 );

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     lhs_text_font = trec.lhs_text_font,
     lhs_text_colour = trec.lhs_text_colour,
     lhs_back = trec.lhs_back,
     lhf_external_call = trec.lhf_external_call,
     gcard_external_call = trec.gcard_external_call,
     lhf_subdir = trec.lhf_subdir,
     lhf_backimg = trec.lhf_backimg,
     lhf_clickable_img = trec.lhf_clickable_img,
     lhf_clickable_position = trec.lhf_clickable_position,
     lhf_clickable_anchor = trec.lhf_clickable_anchor,
     lhf_clickable_target = trec.lhf_clickable_target
    where theme_name = thm;

 elsif disp = 'FULLIMG'
  then
   trec.fullimg_text_font  := getval( 'PFA', p1, p2 );
   trec.fullimg_text_colour  := getval( 'PFB', p1, p2 );
   trec.fullimg_back  := getval( 'PFC', p1, p2 );
   trec.fullimg_jscript_popup  := getcheck( 'PFD', p3 );
   trec.fullimg_popup_width  := getval( 'PFE', p1, p2 );
   trec.fullimg_popup_height  := getval( 'PFF', p1, p2 );
   trec.fullimg_display_type  := getval( 'PFG', p1, p2 );
   trec.fullimg_title_style  := getval( 'PFTT', p1, p2 );
   trec.fullimg_novelty  := getval( 'PNV', p1, p2 );
   trec.main_image_api_call  := getval( 'PFH', p1, p2 );

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     fullimg_text_font = trec.fullimg_text_font,
     fullimg_text_colour = trec.fullimg_text_colour,
     fullimg_back = trec.fullimg_back,
     fullimg_jscript_popup = trec.fullimg_jscript_popup,
     fullimg_popup_width = trec.fullimg_popup_width,
     fullimg_popup_height = trec.fullimg_popup_height,
     fullimg_display_type = trec.fullimg_display_type,
     main_image_api_call = trec.main_image_api_call,
     fullimg_novelty = trec.fullimg_novelty,
     fullimg_title_style = trec.fullimg_title_style
    where theme_name = thm;

 elsif disp = 'API'
  then
   trec.top_frame_api_call  := getval( 'TFRAME', p1, p2 );
   trec.bottom_frame_external  := getval( 'BFRAME', p1, p2 );
   trec.home_page_external_call  := getval( 'HPAGE', p1, p2 );
   trec.external_call  := getval( 'TNAIL', p1, p2 );
   trec.tnail_page_bottom  := getval( 'TNAILBOT', p1, p2 );
   trec.shop_external_call  := getval( 'SHOP', p1, p2 );
   trec.contact_external_call  := getval( 'CONTACT_DET', p1, p2 );
   trec.order_show_cart  := getval( 'SHOW_CART', p1, p2 );
   trec.order_show_receipt  := getval( 'SHOW_RECEIPT', p1, p2 );
   trec.main_image_api_call  := getval( 'PFH', p1, p2 );
   trec.search_before_entry_api  := getval( 'SEARCH_BEFORE', p1, p2 );
   trec.search_after_entry_api  := getval( 'SEARCH_AFTER', p1, p2 );
   trec.lhf_external_call  := getval( 'P5D', p1, p2 );
   trec.order_bottom_external  := getval( 'ORA4', p1, p2 );
   trec.ord_extra_col_api_call  := getval( 'ORA5', p1, p2 );

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     top_frame_api_call = trec.top_frame_api_call,
     bottom_frame_external = trec.bottom_frame_external,
     home_page_external_call = trec.home_page_external_call,
     external_call = trec.external_call,
     shop_external_call = trec.shop_external_call,
     contact_external_call = trec.contact_external_call,
     tnail_page_bottom = trec.tnail_page_bottom,
     order_show_cart = trec.order_show_cart,
     order_show_receipt = trec.order_show_receipt,
     main_image_api_call = trec.main_image_api_call,
     lhf_external_call = trec.lhf_external_call,
     search_before_entry_api = trec.search_before_entry_api,
     search_after_entry_api = trec.search_after_entry_api,
     order_bottom_external = trec.order_bottom_external,
     ord_extra_col_api_call =  trec.ord_extra_col_api_call
    where theme_name = thm;

 elsif disp = 'GALLERY'
  then
   trec.gallery_text_font  := getval( 'P9A', p1, p2 );
   trec.gallery_text_colour  := getval( 'P9B', p1, p2 );
   trec.gallery_back  := getval( 'P9C', p1, p2 );

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     gallery_text_font = trec.gallery_text_font,
     gallery_text_colour = trec.gallery_text_colour,
     gallery_back = trec.gallery_back
    where theme_name = thm;

 elsif disp = 'CUSTOMER'
  then
   trec.top_text_font  := getval( 'P8A', p1, p2 );
   trec.top_text_colour  := getval( 'P8B', p1, p2 );
   trec.top_back  := getval( 'P8C', p1, p2 );
   trec.top_frame_background  := getval( 'P8D', p1, p2 );

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     top_text_colour = trec.top_text_colour,
     top_text_font = trec.top_text_font,
     top_back = trec.top_back,
     top_frame_background = trec.top_frame_background
    where theme_name = thm;

 elsif disp = 'TITLE'
  then
   trec.title_text_font  := getval( 'P7A', p1, p2 );
   trec.title_colour_font  := getval( 'P7B', p1, p2 );
   trec.title_text_colour  := getval( 'P7C', p1, p2 );

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     title_text_font = trec.title_text_font,
     title_colour_font = trec.title_colour_font,
     title_text_colour = trec.title_text_colour
    where theme_name = thm;

 elsif disp = 'ORDER'
  then
   trec.ord_title_text_font  := getval( 'OP7A', p1, p2 );
   trec.ord_title_colour_font  := getval( 'OP7B', p1, p2 );
   trec.ord_title_text_colour  := getval( 'OP7C', p1, p2 );
   trec.ord_text_font  := getval( 'OP4A', p1, p2 );
   trec.ord_text_colour  := getval( 'OP4B', p1, p2 );
   trec.ord_text_back  := getval( 'OP4C', p1, p2 );
   begin trec.ord_text_font_inc  := getval( 'OP4D', p1, p2 ); exception when others then trec.ord_text_font_inc := 0; end;

   trec.ord_qbground  := 'bgcolor="#' || getval( 'OTHD', p1, p2 ) || '"';
   trec.ord_qcbground  := 'bgcolor="#' || getval( 'OTCL', p1, p2 ) || '"';
   trec.ord_toggle_qcbground  := 'bgcolor="#' || getval( 'OTCG', p1, p2 ) || '"';
   begin trec.ord_text_table_border  := getval( 'OTBL', p1, p2 ); exception when others then trec.ord_text_table_border := 1; end;
   begin trec.ord_text_table_borderi  := getval( 'OTBLI', p1, p2 ); exception when others then trec.ord_text_table_borderi := 1; end;
   trec.order_nocol_table  := getval( 'OTBLA', p1, p2 );
   trec.order_twocol_table  := getval( 'OTBLB', p1, p2 );
   trec.ord_inc_simple  := getcheck( 'ORA1', p3 );
   trec.ord_inc_privacy  := getcheck( 'ORA2', p3 );
   trec.ord_toggle_colours  := getcheck( 'ORA3', p3 );
   trec.order_bottom_external  := getval( 'ORA4', p1, p2 );
   trec.ord_extra_col_api_call  := getval( 'ORA5', p1, p2 );
   trec.ord_summary_hdr_clr  := 'bgcolor="#' || getval( 'ONV1', p1, p2 ) || '"';
   trec.ord_bank_divider  := getval( 'ONV3', p1, p2 );
   trec.ord_cost_table  := getval( 'ONV4', p1, p2 );
   trec.ord_cost_left  := getval( 'ONV5', p1, p2 );
   trec.ord_cost_right  := getval( 'ONV6', p1, p2 );
   trec.ord_deliv_table  := getval( 'ONV7', p1, p2 );
   trec.ord_deliv_left  := getval( 'ONV8', p1, p2 );
   trec.ord_deliv_right  := getval( 'ONV9', p1, p2 );
   trec.ord_paym_table  := getval( 'ONV10', p1, p2 );
   trec.ord_paym_left  := getval( 'ONV11', p1, p2 );
   trec.ord_paym_right  := getval( 'ONV12', p1, p2 );
   trec.ord_paym_right2  := getval( 'ONV17', p1, p2 );
   trec.ord_cust_table  := getval( 'ONV13', p1, p2 );
   trec.ord_cust_left  := getval( 'ONV14', p1, p2 );
   trec.ord_cust_right  := getval( 'ONV15', p1, p2 );
   trec.ord_uf_table  := getval( 'ONV16', p1, p2 );
   trec.ord_uf_left  := getval( 'ONV17', p1, p2 );
   trec.ord_uf_right  := getval( 'ONV18', p1, p2 );

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     ord_title_text_font = trec.ord_title_text_font,
     ord_title_colour_font = trec.ord_title_colour_font,
     ord_title_text_colour = trec.ord_title_text_colour,
     ord_text_font = trec.ord_text_font,
     ord_text_colour = trec.ord_text_colour,
     ord_text_back = trec.ord_text_back,
     ord_text_font_inc = trec.ord_text_font_inc,
     ord_text_table_border = trec.ord_text_table_border,
     ord_text_table_borderi = trec.ord_text_table_borderi,
     ord_qbground = trec.ord_qbground,
     ord_qcbground = trec.ord_qcbground,
     ord_toggle_qcbground = trec.ord_toggle_qcbground,
     ord_inc_simple = trec.ord_inc_simple,
     ord_inc_privacy = trec.ord_inc_privacy,
     ord_toggle_colours = trec.ord_toggle_colours,
     order_bottom_external = trec.order_bottom_external,
     ord_extra_col_api_call =  trec.ord_extra_col_api_call,
     order_nocol_table = trec.order_nocol_table,
     order_twocol_table = trec.order_twocol_table,
     ord_summary_hdr_clr = trec.ord_summary_hdr_clr,
     ord_bank_divider = trec.ord_bank_divider,
     ord_cost_table = trec.ord_cost_table,
     ord_cost_left = trec.ord_cost_left,
     ord_cost_right = trec.ord_cost_right,
     ord_deliv_table = trec.ord_deliv_table,
     ord_deliv_left  = trec.ord_deliv_left,
     ord_deliv_right = trec.ord_deliv_right,
     ord_paym_table = trec.ord_paym_table,
     ord_paym_left  = trec.ord_paym_left,
     ord_paym_right = trec.ord_paym_right,
     ord_paym_right2 = trec.ord_paym_right2,
     ord_cust_table = trec.ord_cust_table,
     ord_cust_left  = trec.ord_cust_left,
     ord_cust_right = trec.ord_cust_right,
     ord_uf_table = trec.ord_uf_table,
     ord_uf_left  = trec.ord_uf_left,
     ord_uf_right = trec.ord_uf_right
   where theme_name = thm;

 elsif disp = 'HOME'
  then
   trec.det_title_font  := getval( 'PTA', p1, p2 );
   trec.det_title_colour  := getval( 'PTB', p1, p2 );
   trec.det_cell_back  := getval( 'PTC', p1, p2 );
   trec.det_text_font  := getval( 'P6A', p1, p2 );
   trec.det_text_colour  := getval( 'P6B', p1, p2 );
   trec.det_back  := getval( 'P6C', p1, p2 );

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     det_title_font = trec.det_title_font,
     det_title_colour = trec.det_title_colour,
     det_cell_back = trec.det_cell_back,
     det_text_font = trec.det_text_font,
     det_text_colour = trec.det_text_colour,
     det_back = trec.det_back
    where theme_name = thm;

 elsif disp = 'THUMBNAIL'
  then
   trec.image_counter_style  := getval( 'ICN', p1, p2 );
   trec.display_style  := getval( 'ITD', p1, p2 );
   trec.tnail_control_style  := getval( 'ITDC', p1, p2 );
   trec.shop_style  := getval( 'ITS', p1, p2 );
   trec.toggle_style  := getval( 'TGL1', p1, p2 );
   trec.page_delim  := getval( 'ICD', p1, p2 );
   trec.external_call  := getval( 'EXCALL', p1, p2 );
   trec.shop_external_call  := getval( 'SHOPEX', p1, p2 );
   trec.toggle_external_call  := getval( 'TGL2', p1, p2 );
   trec.use_line  := getcheck( 'ICL', p3 );
   trec.tnail_disp_sml_font  := getcheck( 'ICZ', p3 );
   trec.uline  := getval( 'ITNX1', p1, p2 );
   trec.uline_active  := getval( 'ITNX2', p1, p2 );
   trec.uline_visited  := getval( 'ITNX3', p1, p2 );
   trec.tnail_underline_active  := getval( 'ACTIVE_LINK', p1, p2 );
   trec.tnail_inc_simple  := getcheck( 'INCS', p3 );
   trec.tnail_disable_top  := getcheck( 'INDT', p3 );
   trec.tnail_inc_privacy  := getcheck( 'INCT', p3 );
   trec.tnail_control_buttons := getcheck( 'INC_CTLT', p3 ) || getcheck( 'INC_CTLB', p3 );
   begin trec.tnumb_adj  := to_number(getval( 'ICV', p1, p2 )); exception when others then trec.tnumb_adj := 0; end;
   begin trec.gap := getval( 'GAP', p1, p2 ); exception when others then trec.gap := 10; end;
   trec.sml_button_api  := getval( 'SML_API', p1, p2 );
   trec.sml_button_api_txt  := getval( 'SML_API_TXT', p1, p2 );


   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     tnail_control_style = trec.tnail_control_style,
     display_style = trec.display_style,
     shop_style = trec.shop_style,
     image_counter_style = trec.image_counter_style,
     page_delim = trec.page_delim,
     use_line = trec.use_line,
     tnail_disp_sml_font = trec.tnail_disp_sml_font,
     gap = trec.gap,
     uline = trec.uline,
     uline_active = trec.uline_active,
     uline_visited = trec.uline_visited,
     tnail_underline_active = trec.tnail_underline_active,
     tnumb_adj = trec.tnumb_adj,
     external_call = trec.external_call,
     shop_external_call = trec.shop_external_call,
     toggle_style = trec.toggle_style,
     toggle_external_call = trec.toggle_external_call,
     tnail_inc_simple = trec.tnail_inc_simple,
     tnail_disable_top = trec.tnail_disable_top,
     tnail_inc_privacy = trec.tnail_inc_privacy,
     tnail_control_buttons = trec.tnail_control_buttons,
     sml_button_api = trec.sml_button_api,
     sml_button_api_txt = trec.sml_button_api_txt
    where theme_name = thm;

 elsif disp = 'TABLE'
  then
   trec.qbground  := 'bgcolor="#' || getval( 'THD', p1, p2 ) || '"';
   trec.qcbground  := 'bgcolor="#' || getval( 'TCL', p1, p2 ) || '"';
   trec.hover_colour  := getval( 'PHV', p1, p2 );


   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     qbground = trec.qbground,
     qcbground = trec.qcbground,
     hover_colour = trec.hover_colour
    where theme_name = thm;

 elsif disp = 'SECURITY'
  then
   trec.javascript  := getval( 'JAVASCRIPT', p1, p2 );
   trec.icra_label  := getval( 'ICRA_LABEL', p1, p2 );
   trec.debug_enabled  := getcheck( 'DBG', p3 );

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     javascript = trec.javascript,
     icra_label = trec.icra_label,
     debug_enabled = trec.debug_enabled
    where theme_name = thm;

 elsif disp = 'META'
  then
   trec.meta_header  := getcheck( 'MGR', p3 );
   trec.meta_category  := getcheck( 'MGC', p3 );
   trec.meta_bground  := 'bgcolor="#' || getval( 'MET', p1, p2 ) || '"';
   trec.meta_table  := getval( 'MTB', p1, p2 );

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     meta_category = trec.meta_category,
     meta_header = trec.meta_header,
     meta_bground = trec.meta_bground,
     meta_table = trec.meta_table
    where theme_name = thm;

 elsif disp = 'VERT'
  then
   trec.vert_header  := getcheck( 'VHDR', p3 );
   trec.tnail_global_border  := getcheck( 'VSA', p3 );
   trec.tnail_global_colour  := getval( 'VSA2', p1, p2 );
   trec.tnail_global_offset  := getval( 'VSA3', p1, p2 );
   trec.tnail_global_spacer  := getval( 'VSA4', p1, p2 );
   trec.caption_text_colour  := getval( 'VCP', p1, p2 );
   trec.caption_text_font  := getval( 'VCF', p1, p2 );
   trec.vertical_disp_table  := getval( 'VTB', p1, p2 );
   trec.slider_style  := getval( 'VSS', p1, p2 );
   trec.slider_choice  := getval( 'VSTA', p1, p2 ) || getval( 'VSTB', p1, p2 ) || nvl(getval( 'VSTC', p1, p2 ),' ');
   trec.slider_search_style  := getval( 'VSTD', p1, p2 );
   trec.vert_colour_a  := getval( 'VCA', p1, p2 );
   trec.vert_colour_b  := getval( 'VCB', p1, p2 );

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     vert_header = trec.vert_header,
     vert_colour_a = trec.vert_colour_a,
     vert_colour_b = trec.vert_colour_b,
     caption_text_colour = trec.caption_text_colour,
     caption_text_font = trec.caption_text_font,
     vertical_disp_table = trec.vertical_disp_table,
     tnail_global_border = trec.tnail_global_border,
     tnail_global_colour = trec.tnail_global_colour,
     tnail_global_offset = trec.tnail_global_offset,
     tnail_global_spacer = trec.tnail_global_spacer,
     slider_style = trec.slider_style,
     slider_choice = trec.slider_choice,
     slider_search_style = trec.slider_search_style
    where theme_name = thm;

 elsif disp = 'SEARCH'
  then
   trec.search_choices  := getcheck( 'SRC1', p3 ) || getcheck( 'SRC2', p3 ) || getcheck( 'SRC3', p3 ) || getcheck( 'SRC4', p3 );
   trec.search_default  := getval( 'SRCD', p1, p2 );
   trec.search_icons  := getcheck( 'SRCI', p3 );
   trec.search_style_simple  := getval( 'SRCS', p1, p2 );
   trec.search_stem  := getcheck( 'SRCT', p3 );
   trec.search_global  := getcheck( 'SRCG', p3 );
   trec.search_email_on_new  := getcheck( 'SRCE', p3 );
   trec.search_ignore_lbox  := getcheck( 'SRCL', p3 );
   trec.search_display_style  := getval( 'SRCV', p1, p2 );
   trec.search_style_mfctr  := getval( 'SRCM', p1, p2 );
   trec.search_mfctr_title  := getval( 'SRCTTL', p1, p2 );
   trec.search_number_enable  := getcheck( 'SRCN', p3 );
   trec.search_with_context  := getcheck( 'SRCTX', p3 );

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     search_choices = trec.search_choices,
     search_default = trec.search_default,
     search_icons = trec.search_icons,
     search_style_simple = trec.search_style_simple,
     search_stem = trec.search_stem,
     search_global = trec.search_global,
     search_email_on_new = trec.search_email_on_new,
     search_ignore_lbox = trec.search_ignore_lbox,
     search_display_style = trec.search_display_style,
     search_style_mfctr = trec.search_style_mfctr,
     search_mfctr_title = trec.search_mfctr_title,
     search_number_enable = trec.search_number_enable,
     search_with_context = trec.search_with_context
    where theme_name = thm;

 elsif disp = 'ERROR'
  then
   trec.error_text_colour  := getval( 'M1A', p1, p2 );
   trec.error_text_font  := getval( 'M1B', p1, p2 );

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     error_text_colour = trec.error_text_colour,
     error_text_font = trec.error_text_font
    where theme_name = thm;

 elsif disp = 'NESTED'
  then
   trec.nested_scene_style := getval( 'PFC', p1, p2 );
   trec.nested_scene_delim  := getval( 'DELM', p1, p2 );

   if lf_locked(thm) then theme_right( surl,nvl(rp1,thm), disp, LNG5.EXT_TXT_228 ); return; end if;
   update theme
    set
     nested_scene_style = trec.nested_scene_style,
     nested_scene_delim = trec.nested_scene_delim
    where theme_name = thm;

 elsif disp = 'ICONS_CUST'
  then
   trec.separate_customer_bt := 'FFFFFFFFFF';
   for j in p3.first..p3.last loop
    if p3(j) is not null
     then
      trec.separate_customer_bt := substr(trec.separate_customer_bt,1,to_number(p3(j))-1) || 'T' || substr(trec.separate_customer_bt,to_number(p3(j))+1);
    end if;
   end loop;
   update theme
    set
     separate_customer_bt = substr(separate_customer_bt,1,1) || substr(trec.separate_customer_bt,2)
    where theme_name = thm;

 end if;

 commit;

 if thm is null
  then
   mnt_themes( surl,nvl(rp1,thm), LNG3.ADM_TXT_229 );
  else
   theme_right( surl,nvl(rp1,thm), disp, LNG3.ADM_TXT_229 );
 end if;

exception when others then
 glbx.error_details( 'LF', 'ACCEPT_THEME', errmsg=>sqlerrm, extdet=>null);
end accept_theme;

procedure mnt_icons( surl varchar2, pfx in THEME%ROWTYPE, disp in varchar2 )
as

 cursor cn is select * from novelty_definition order by order_by;

 pref varchar2(100);

 procedure show( prefix in varchar2, typ in varchar2, ttl in varchar2, img1 in varchar2, img2 in varchar2, notes in varchar2)
 as
 begin
  htp.tablerowopen;
     htp.tabledata(htf.bold( ttl || htf.nl || htf.italic( img1 ) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
     if glbx.gif_exists('http://' || owa_util.get_cgi_env( 'SERVER_NAME' ) || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || DECS.IMAGE_LOCATION || prefix || '/' || img1)
      then
       htp.tabledata(htf.img( curl=>DECS.IMAGE_LOCATION || prefix || '/' || img1,cattributes=>'BORDER=0' ),cattributes=>'bgcolor="#' || pfx.text_back || '" valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata( LNG4.AHC_TXT_858,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
     if typ = '2'
      then
       if glbx.gif_exists('http://' || owa_util.get_cgi_env( 'SERVER_NAME' ) || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || DECS.IMAGE_LOCATION || prefix || '/' || img1)
        then
         htp.tabledata(htf.img( curl=>DECS.IMAGE_LOCATION || prefix || '/' || img2,cattributes=>'BORDER=0' ),cattributes=>'bgcolor="#' || pfx.text_back || '" valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata(LNG4.AHC_TXT_858,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
      else
       htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
     htp.tabledata(notes,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end;

 procedure stitle( ttl in varchar2, nmb in integer, sep_but in char )
 as
 begin
  htp.tablerowopen;
     htp.p( '<TD ' || GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT" COLSPAN=4>');
      if substr(sep_but,nmb,1) = 'T'
       then
        htp.formcheckbox( 'P3', nmb, 'CHECKED' );
       else
        htp.formcheckbox( 'P3', nmb );
      end if;
      htp.bold( ttl );
     htp.p( '</TD>' );
  htp.tablerowclose;
 end stitle;

begin
 htp.p( '<CENTER>' );
 htp.nl;

 if disp = 'ICONS_CUST'
  then
   htp.tableopen( cattributes=>'width="600" cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
   -- Note: Don't strip out this into language files, its a more a note to developers and should be kept in English.
   if substr(pfx.separate_customer_bt,1,1) = 'F'
    then
     pref := 'adminc';
    elsif substr(pfx.separate_customer_bt,1,1) = 'T' and substr(pfx.separate_customer_bt,2,1) = 'T'
     then
      pref := pfx.disp_prefix;
    else
     pref := 'adminc';
   end if;
   stitle( 'Control Buttons', 2, pfx.separate_customer_bt );
   show(pref,'1',LNG.PHG_TXT_199,'modprev.gif',null,'Display Previous Page');
   show(pref,'1',LNG.PHG_TXT_199,'summary.gif',null,'Toggle - display alterantive thumbnail display');
   show(pref,'1',LNG.PHG_TXT_199,'detail.gif',null,'Toggle - display alterantive thumbnail display');
   show(pref,'1',LNG.PHG_TXT_199,'modnext.gif',null,'Display Next Page');
   show(pref,'1',LNG.PHG_TXT_199,'order.gif',null,'Move all Items checked into the Shopping Basket');
   show(pref,'1',LNG.PHG_TXT_199,'display.gif',null,'Display Side by Side all Checked Images');
   show(pref,'1',LNG.PHG_TXT_199,'moddet.gif',null,'Modify the Details of any Images');
   --
   if substr(pfx.separate_customer_bt,1,1) = 'F'
    then
     pref := 'adminc';
    elsif substr(pfx.separate_customer_bt,1,1) = 'T' and substr(pfx.separate_customer_bt,9,1) = 'T'
     then
      pref := pfx.disp_prefix;
    else
     pref := 'adminc';
   end if;
   stitle( 'Control Buttons - Infrequently Used', 9, pfx.separate_customer_bt );
   show(pref,'1',LNG.PHG_TXT_199,'catshow.gif',null,'View Pop Up Mini Slideshow');
   show(pref,'1',LNG.PHG_TXT_199,'whatsnew.gif',null,'Perform a Whats New Search, list any new images since last login');
   show(pref,'1',LNG.PHG_TXT_199,'packprod.gif',null,'Choose a Packaged Product');
   show(pref,'1',LNG.PHG_TXT_199,'packprode.gif',null,'Edit a Packaged Product');
   show(pref,'1',LNG.PHG_TXT_199,'prv.gif',null,'View Previous Orders Made and Simple Requests Made');
   show(pref,'1',LNG.PHG_TXT_199,'regn.gif',null,'For Guest Accounts, create new account');
   show(pref,'1',LNG.PHG_TXT_199,'regc.gif',null,'For non Guest Accounts, update account details');
   show(pref,'1',LNG.PHG_TXT_199,'rfq.gif',null,'Simple Request - Cannot find it');
   --
   if substr(pfx.separate_customer_bt,1,1) = 'F'
    then
     pref := 'adminc';
    elsif substr(pfx.separate_customer_bt,1,1) = 'T' and substr(pfx.separate_customer_bt,8,1) = 'T'
     then
      pref := pfx.disp_prefix;
    else
     pref := 'adminc';
   end if;
   stitle( 'Control Buttons - Lightbox', 8, pfx.separate_customer_bt );
   show(pref,'1',LNG.PHG_TXT_199,'lightbox.gif',null,'Add any Checked Images to the Lightbox');
   show(pref,'1',LNG.PHG_TXT_199,'lightboxall.gif',null,'Add all Images on the screen to the Lightbox');
   show(pref,'1',LNG.PHG_TXT_199,'seelight.gif',null,'View Lightbox Contents - only if there are images in the lightbox');
   show(pref,'1',LNG.PHG_TXT_199,'lboxes.gif',null,'Manage Multiple Lightboxes (add, move images, delete)');
   show(pref,'1',LNG.PHG_TXT_199,'emptylight.gif',null,'When in Lightbox Screen, delete whole lightbox');
   show(pref,'1',LNG.PHG_TXT_199,'dellight.gif',null,'When in Lightbox Screen, delete any lightbox images checked');
   --
   if substr(pfx.separate_customer_bt,1,1) = 'F'
    then
     pref := 'adminc';
    elsif substr(pfx.separate_customer_bt,1,1) = 'T' and substr(pfx.separate_customer_bt,3,1) = 'T'
     then
      pref := pfx.disp_prefix;
    else
     pref := 'adminc';
   end if;
   stitle( 'Main Image Display Buttons', 3, pfx.separate_customer_bt );
   show(pref,'1',LNG.PHG_TXT_199,'run_novelty.gif',null,'Run the Novelty');
   show(pref,'1',LNG.PHG_TXT_199,'return.gif',null,'Return to the Previous Screen');
   --
   if substr(pfx.separate_customer_bt,1,1) = 'F'
    then
     pref := 'adminc';
    elsif substr(pfx.separate_customer_bt,1,1) = 'T' and substr(pfx.separate_customer_bt,4,1) = 'T'
     then
      pref := pfx.disp_prefix;
    else
     pref := 'adminc';
   end if;
   stitle( 'Small Above Thumbnail Buttons', 4, pfx.separate_customer_bt );
   show(pref,'1',LNG.PHG_TXT_199,'special.gif',null,'Draw Attention to this Image as it has been marked as Special');
   show(pref,'1',LNG.PHG_TXT_199,'new.gif',null,'Image is New and has not been seen by the customer since their last login');
   show(pref,'1',LNG.PHG_TXT_199,'smaudio.gif',null,'There is an Audio File attached to this Image');
   --
   if substr(pfx.separate_customer_bt,1,1) = 'F'
    then
     pref := 'adminc';
    elsif substr(pfx.separate_customer_bt,1,1) = 'T' and substr(pfx.separate_customer_bt,5,1) = 'T'
     then
      pref := pfx.disp_prefix;
    else
     pref := 'adminc';
   end if;
   stitle( 'Search Buttons', 5, pfx.separate_customer_bt );
   show(pref,'1',LNG.PHG_TXT_199,'search_a.gif',null,'Simple Search');
   show(pref,'1',LNG.PHG_TXT_199,'search_b.gif',null,'Advanced Search');
   show(pref,'1',LNG.PHG_TXT_199,'search_c.gif',null,'Manufacturer/Shop Search');
   show(pref,'1',LNG.PHG_TXT_199,'search_d.gif',null,'Meta Tag Query Search');
   --
   if substr(pfx.separate_customer_bt,1,1) = 'F'
    then
     pref := 'adminc';
    elsif substr(pfx.separate_customer_bt,1,1) = 'T' and substr(pfx.separate_customer_bt,6,1) = 'T'
     then
      pref := pfx.disp_prefix;
    else
     pref := 'adminc';
   end if;
   stitle( 'Small Below Thumbnail Buttons', 6, pfx.separate_customer_bt );
   show(pref,'1',LNG.PHG_TXT_199,'note.gif',null,'When in Lightbox Screen, attach a note to the image');
   show(pref,'1',LNG.PHG_TXT_199,'sml_a.gif',null,'Buy this Image - add to shopping basket');
   show(pref,'1',LNG.PHG_TXT_199,'sml_b.gif',null,'Add this Image to the lightbox');
   show(pref,'1',LNG.PHG_TXT_199,'sml_c.gif',null,'Download Original Image');
   show(pref,'1',LNG.PHG_TXT_199,'sml_d.gif',null,'View Image Details - see web quality image');
   show(pref,'1',LNG.PHG_TXT_199,'sml_e.gif',null,'Edit Meta Data attached to this Image');
   show(pref,'1',LNG.PHG_TXT_199,'sml_f.gif',null,'View HTML Version of the Document');
   show(pref,'1',LNG.PHG_TXT_199,'sml_g.gif',null,'View Summary Paragraph on the Document');
   --
   if substr(pfx.separate_customer_bt,1,1) = 'F'
    then
     pref := 'adminc';
    elsif substr(pfx.separate_customer_bt,1,1) = 'T' and substr(pfx.separate_customer_bt,7,1) = 'T'
     then
      pref := pfx.disp_prefix;
    else
     pref := 'adminc';
   end if;
   stitle( 'Top Frame Option Buttons', 7, pfx.separate_customer_bt );
   show(pref,'1',LNG.PHG_TXT_199,'help.gif',null,'Display Customer Specific Help');
   show(pref,'1',LNG.PHG_TXT_199,'readme.gif',null,'Display Customer Specific Readme File');
   show(pref,'1',LNG.PHG_TXT_199,'feedback.gif',null,'Display Customer Specific Feedback Form');
   show(pref,'1',LNG.PHG_TXT_199,'contactus.gif',null,'Display Customer Specific Page on contact details');
   show(pref,'1',LNG.PHG_TXT_199,'legal.gif',null,'Display Legal Notice');
   show(pref,'1',LNG.PHG_TXT_199,'privacy.gif',null,'Display Privacy Notice');
   show(pref,'1',LNG.PHG_TXT_199,'logoff.gif',null,'Logoff the Application (same functionality as home.gif)');
   show(pref,'1',LNG.PHG_TXT_199,'home.gif',null,'Go Back to the Home Page (same functionality as the logoff button)');
   show(pref,'1',LNG.PHG_TXT_199,'authorise.gif',null,'Profile can Authorise Accounts - Accounts they see');

   --
   if substr(pfx.separate_customer_bt,1,1) = 'F'
    then
     pref := 'adminc';
    elsif substr(pfx.separate_customer_bt,1,1) = 'T' and substr(pfx.separate_customer_bt,10,1) = 'T'
     then
      pref := pfx.disp_prefix;
    else
     pref := 'adminc';
   end if;
   stitle( 'Novelty Buttons', 10, pfx.separate_customer_bt );
   for nrec in cn loop
    show(pref,'1',LNG.PHG_TXT_199,nrec.display_suffix,null,nrec.display_name);
   end loop;

   htp.tableclose;
   htp.p( '</CENTER>' );
   htp.nl;
   return;
 end if;

 htp.italic( LNG3.ADM_TXT_230 );
 htp.nl;
 htp.italic ( LNG3.ADM_TXT_231);
 htp.nl;
 htp.italic ( LNG3.ADM_TXT_232);
 htp.nl;
 htp.italic ( LNG3.ADM_TXT_233);
 htp.nl;
 htp.nl;
 htp.tableopen( cattributes=>'width="600" cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );

 -- Greeting Card
 if disp = 'ICONS_ALL'
  then
   show(pfx.disp_prefix,'1',LNG3.ADM_TXT_235,'view.gif',null,'Greeting Card Menu - View Greeting Card');
   show(pfx.disp_prefix,'1',LNG3.ADM_TXT_235,'edit.gif',null,'Greeting Card Menu - Edit Greeting Card');
   show(pfx.disp_prefix,'1',LNG3.ADM_TXT_235,'send.gif',null,'Greeting Card Menu - Send Greeting Card');
   show(pfx.disp_prefix,'1',LNG3.ADM_TXT_235,'del.gif',null,'Greeting Card Menu - Delete Greeting Card');
   show(pfx.disp_prefix,'1',LNG3.ADM_TXT_235,'ret.gif',null,'Greeting Card Menu - Return to Previous Screen');
 end if;

 -- Cust
 if pfx.uses_boundary = 'T'
 then
  show(pfx.disp_prefix,'1',LNG.PHG_TXT_199,'cup.gif',null,'Optional Upper/Left Hand Side Boundry Gif');
 end if;
 show(pfx.disp_prefix,'2',LNG.PHG_TXT_199,'hzm.gif','hzmx.gif','Home');
 show(pfx.disp_prefix,'2',LNG.PHG_TXT_199,'ozd.gif','ozdx.gif','Shopping Basket');
 show(pfx.disp_prefix,'2',LNG.PHG_TXT_199,'szc.gif','szcx.gif',LNG.GLB_TXT_092);
 show(pfx.disp_prefix,'2',LNG.PHG_TXT_199,'szd.gif','szdx.gif','Slideshow');
 show(pfx.disp_prefix,'2',LNG.PHG_TXT_199,'phg.gif','phgx.gif','Photographer Details');
 show(pfx.disp_prefix,'2',LNG.PHG_TXT_199,'dzt.gif','dztx.gif','Customer Details');
 if disp = 'ICONS_ALL'
  then
   --show(pfx.disp_prefix,'2',LNG.PHG_TXT_199,'slz.gif','slzx.gif',null);
   show(pfx.disp_prefix,'2',LNG.PHG_TXT_199,'axp.gif','axpx.gif','Customer Load Image');
   show(pfx.disp_prefix,'2',LNG.PHG_TXT_199,'ol1.gif','ol1x.gif','Forms');
   show(pfx.disp_prefix,'2',LNG.PHG_TXT_199,'ol2.gif','ol2x.gif','Reports');
   show(pfx.disp_prefix,'2',LNG.PHG_TXT_199,'ol3.gif','ol3x.gif','OLAP');
   show(pfx.disp_prefix,'2',LNG.PHG_TXT_199,'stk.gif','stkx.gif','Manufacturer Clearance');
   show(pfx.disp_prefix,'2',LNG.PHG_TXT_199,'ten.gif','tenx.gif','Tender');
   show(pfx.disp_prefix,'2',LNG.PHG_TXT_199,'rev.gif','revx.gif','Reverse Auction');
   show(pfx.disp_prefix,'2',LNG.PHG_TXT_199,'str.gif','strx.gif','Shop Store');
  end if;
  if pfx.uses_boundary = 'T'
   then
    show(pfx.disp_prefix,'1',LNG.PHG_TXT_199,'cdw.gif',null,'Optional Bottom/Right Hand Side Boundry Gif');
  end if;

  -- Phg
  if pfx.uses_boundary = 'T'
   then
   show(pfx.disp_prefix,'1',LNG.PHG_TXT_006,'pup.gif',null,'Optional Upper/Left Hand Side Boundry Gif');
 end if;
 show(pfx.disp_prefix,'2',LNG.PHG_TXT_006,'hom.gif','homx.gif','Home');
 show(pfx.disp_prefix,'2',LNG.PHG_TXT_006,'det.gif','detx.gif','Customer Details');
 show(pfx.disp_prefix,'2',LNG.PHG_TXT_006,'pre.gif','prex.gif','Preferences');
 show(pfx.disp_prefix,'2',LNG.PHG_TXT_006,'utl.gif','utlx.gif','Utilities');
 show(pfx.disp_prefix,'2',LNG.PHG_TXT_006,'sta.gif','stax.gif','Statistics');
 show(pfx.disp_prefix,'2',LNG.PHG_TXT_006,'opd.gif','opdx.gif','Photographer Shopping Basket');
 show(pfx.disp_prefix,'2',LNG.PHG_TXT_006,'ord.gif','ordx.gif','Photographer orders');
 show(pfx.disp_prefix,'2',LNG.PHG_TXT_006,'src.gif','srcx.gif',LNG.GLB_TXT_092);
 show(pfx.disp_prefix,'2',LNG.PHG_TXT_006,'fph.gif','fphx.gif','Mass Edit/Fast Edit');
 show(pfx.disp_prefix,'2',LNG.PHG_TXT_006,'sld.gif','sldx.gif','Slideshow');
 show(pfx.disp_prefix,'2',LNG.PHG_TXT_006,'adp.gif','adpx.gif','Upload Images');
 if disp = 'ICONS_ALL'
  then
   show(pfx.disp_prefix,'2',LNG.PHG_TXT_006,'alb.gif','albx.gif','Album');
   show(pfx.disp_prefix,'2',LNG.PHG_TXT_006,'stk.gif','stkx.gif','Manufacturer Clearance');
   show(pfx.disp_prefix,'2',LNG.PHG_TXT_006,'ths.gif','thsx.gif','Theasurus');
   show('adminc','1','Order Style','order_userfee.gif',null,'Go back to User Fee');
   show('adminc','1','Order Style','order_returnback.gif',null,'User Fee Page - Go back to Main Page');
   show('adminc','1','Order Style','order_continue.gif',null,'User Fee Page - Continue to Next Page');
   show('adminc','1','Order Style','order_recalc.gif',null,'Recalculate Shopping Basket');
   show('adminc','1','Order Style','order_empty.gif',null,'Empty Shopping Basket');
   show('adminc','1','Order Style','order_checkout.gif',null,'Checkout to next Order Page');
   show('adminc','1','Order Style','uppointer.gif',null,'Progress Bar Arrow Marker (Top)');
   show('adminc','1','Order Style','leftpointer.gif',null,'Progress Bar Arrow Marker (left)');
   show('adminc','1','Order Style','order_return.gif',null,'Return to Order Page');
   show('adminc','1','Order Style','order_payment.gif',null,'Proceed to Payment Page');
   show('adminc','1','Order Style','help_how.gif',null,'Order Help Button');
   show('adminc','1','Order Style','ord_merch.gif',null,'Merchant Graphic');
   show('adminc','1','Order Style','cheque.gif',null,'Cheque Graphic');
   show('adminc','1','Order Style','authorisation.gif',null,'Authorisation Graphic');
   show('adminc','1','Order Style','certificate.gif',null,'Gift Certificate Graphic');
   show('adminc','1','Order Style','ord_phone.gif',null,'Phone Graphic');
   show('adminc','1','Order Style','order_cancel.gif',null,'Cancel Graphic');
 end if;
 if pfx.uses_boundary = 'T'
  then
   show(pfx.disp_prefix,'1',LNG.PHG_TXT_006,'pdw.gif',null,'Optional Bottom/Right Hand Side Boundry Gif');
 end if;

 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.nl;
exception when others then
 glbx.error_details( 'LF', 'MNT_ICONS', errmsg=>sqlerrm, extdet=>null);
end mnt_icons;

procedure copy_data( surl in varchar2, p1 in varchar2, typ in varchar2, p2 in varchar2 )
as

 cursor c1(p1 varchar2) is select * from theme_types where theme_type = p1;
 cursor c2(p1 varchar2) is select * from theme where theme_name = p1;
 cursor c3(tname varchar2) is select column_name from user_tab_columns where table_name = tname and column_name not in ('THEME_NAME');

 c1rec	c1%ROWTYPE;
 c2rec	c2%ROWTYPE;
 sessid	integer;
 tmp	varchar2(4000);
 sts	varchar2(200);
 rp2	varchar2(1000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'LF.COPY_DATA');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if typ = 'BF'
  then
   open c1(p1);
   fetch c1 into c1rec;
   if c1%FOUND
    then
     close c1;
     rp2 := glbx.strip_special_characters( p2 );
     insert into theme_types(theme_type,theme_data) values (rp2,c1rec.theme_data);
     commit;
    else
     close c1;
   end if;
   mnt_type_list(surl,rp2);
 elsif typ = 'LF'
  then
   open c2(p1);
   fetch c2 into c2rec;
   if c2%FOUND
    then
     close c2;
       insert into theme(theme_name) values (p2);
       for c3rec in c3('THEME') loop
        execute immediate 'select ' || c3rec.column_name || ' from theme where theme_name = :1'
         into tmp
         using p1;
        execute immediate 'update theme set ' || c3rec.column_name || ' = :1 where theme_name = :2'
         using tmp,p2;
       end loop;
       insert into screen_controller(theme_name,controller,ctype,v_screen_0,n_screen_0,v_screen_1,n_screen_1,v_screen_2,n_screen_2,v_screen_3,n_screen_3,v_screen_4,n_screen_4,v_screen_5,n_screen_5,v_screen_6,n_screen_6,v_screen_7,n_screen_7)
        select p2,controller,ctype,v_screen_0,n_screen_0,v_screen_1,n_screen_1,v_screen_2,n_screen_2,v_screen_3,n_screen_3,v_screen_4,n_screen_4,v_screen_5,n_screen_5,v_screen_6,n_screen_6,v_screen_7,n_screen_7
        from screen_controller
        where theme_name = p1;
       commit;
    else
     close c2;
   end if;
   theme_right(surl,p2);
 end if;
exception when others then
 glbx.error_details( 'LF', 'COPY_DATA', errmsg=>sqlerrm, extdet=>'P1:' || p1);
end copy_data;

procedure mnt_type_list( surl varchar2, ttype in varchar2, template in varchar2 default 'F' )
as

 cursor c1 is select theme_type from theme_types order by theme_type;
 cursor c2 is
  select distinct decode(belongs_to,'P','Client','C','Customer','G','Guest') cola, grouping, decode(belongs_to,'P',1,'C',2,'G',3) colb
  from help_business_features
  order by decode(belongs_to,'P',1,'C',2,'G',3), grouping;
 cursor c3 is
  select distinct xref_a grouping
  from help_business_features
  union
  select distinct xref_b grouping
  from help_business_features
  union
  select distinct xref_c grouping
  from help_business_features;

 sessid	integer;
 sts	varchar2(200);
 lrec	varchar2(100);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.MNT_TYPE_LIST');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 adm.main_title( surl, sessid, ttype, style=>'NOMENU' );

 -- Search Option
 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0');
 htp.tablerowopen;
 htp.p( '<TD>' );
  htp.p('<FONT SIZE=-2>');
  htp.formopen( 'lf.mnt_type_edit', ctarget=>'ADM_SUB_RIGHT');
  htp.formhidden( 'SURL', glbx.rndsurl(surl) );
  htp.formhidden( 'TTYPE', ttype );
  htp.formhidden( 'TEMPLATE', template );
  htp.formhidden( 'CALL', 'S' );
  htp.formtext( 'TYP',5,100);
  htp.formsubmit( null, LNG.GLB_TXT_092 );
  htp.formclose;
  htp.p( '</FONT>' );
 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;

  if template = 'F'
   then
    htp.anchor2( 'lf.mnt_type_edit?surl=' || glbx.rndsurl(surl) || '&ttype=' || translate(ttype,' ','+') || '&typ=' || translate(LNG3.ADM_TXT_684,' ','+') || '&template=' || template,LNG3.ADM_TXT_684  ,ctarget=>'ADM_SUB_RIGHT' );
    htp.nl;
    htp.anchor2( 'lf.mnt_type_edit?surl=' || glbx.rndsurl(surl) || '&ttype=' || translate(ttype,' ','+') || '&typ=' || translate(LNG3.ADM_TXT_684,' ','+') || '&template=' || template || '&call=F',LNG4.AHC_TXT_434  ,ctarget=>'ADM_SUB_RIGHT' );
   else
    htp.anchor2( 'lf.mnt_type_edit?surl=' || glbx.rndsurl(surl) || '&ttype=' || translate(ttype,' ','+') || '&typ=' || translate(LNG3.ADM_TXT_684,' ','+') || '&template=' || template,LNG3.ADM_TXT_684  ,ctarget=>'ADM_SUB_RIGHT' );
  end if;
  htp.nl;
 -- if (ttype <> LNG3.ADM_TXT_682) and (template = 'F')
  for c2rec in c2 loop
   if lrec is null or lrec <> c2rec.cola
    then
     htp.bold( c2rec.cola );
     htp.nl;
   end if;
   htp.anchor2( 'lf.mnt_type_edit?surl=' || glbx.rndsurl(surl) || '&ttype=' || translate(ttype,' ','+') || '&typ=' || translate(c2rec.grouping,' ','+') || '&template=' || template || '&call=N', c2rec.grouping, ctarget=>'ADM_SUB_RIGHT' );
   htp.nl;
   lrec := c2rec.cola;
  end loop;
  htp.nl;
  htp.bold(LNG4.AHC_TXT_311);
  htp.nl;
  for c3rec in c3 loop
   htp.anchor2( 'lf.mnt_type_edit?surl=' || glbx.rndsurl(surl) || '&ttype=' || translate(ttype,' ','+') || '&typ=' || translate(c3rec.grouping,' ','+') || '&template=' || template || '&call=X', initcap(c3rec.grouping), ctarget=>'ADM_SUB_RIGHT' );
   htp.nl;
  end loop;
  htp.nl;
  htp.bold(LNG.PHG_TXT_352);
  htp.nl;
  htp.anchor2( 'lf.mnt_type_xref?surl=' || glbx.rndsurl(surl) || '&ttype=' || translate(ttype,' ','+'),LNG3.ADM_TXT_687, ctarget=>'ADM_SUB_RIGHT' );
  htp.nl;
  -- Replace by Call from Menu
  --htp.anchor2( 'lf.theme_objects?surl=' || glbx.rndsurl(surl) || '&ttype=' || translate(ttype,' ','+'),LNG3.ADM_TXT_896, ctarget=>'ADM_SUB_RIGHT' );
  --htp.nl;
  htp.formopen( 'lf.compare_bf', ctarget=>'ADM_SUB_RIGHT' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'P1', ttype );
  htp.p( '<TD>' );
  htp.formselectopen( 'P2' );
  for c1rec in c1 loop
   if c1rec.theme_type <> ttype
    then
     htp.formselectoption( c1rec.theme_type );
   end if;
  end loop;
  htp.formselectclose;
  htp.p( '</TD>' );
  htp.formsubmit( null, LNG4.AHC_TXT_639 );
  htp.formclose;
  htp.nl;
  htp.formopen( 'lf.copy_data' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'P1', ttype );
  htp.formhidden( 'TYP', 'BF' );
  htp.formtext( 'P2', 15, 100, LNG2.PFM_TXT_154 || '_' || ttype );
  htp.nl;
  htp.formsubmit( null, initcap(LNG2.PFM_TXT_154) );
  htp.formclose;
  htp.nl;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LF', 'MNT_TYPE_LIST', errmsg=>sqlerrm, extdet=>'TTYPE:' || ttype);
end mnt_type_list;

procedure mnt_type_edit( surl varchar2, ttype in varchar2, typ in varchar2, template in varchar2 default 'F', msg in varchar2 default null, call in char default 'N' )
as
 cursor c1(ttype varchar2) is select * from theme_types where theme_type = ttype;
 cursor c1a(ttype varchar2) is select * from theme_types_template where theme_type = ttype;
 cursor c2(ttype varchar2) is select 'x' from customer_account where theme_type = ttype;
 cursor c3(ttype varchar2) is select 'x' from photographer where theme_type = ttype;
 cursor c4(pname varchar2) is select editeable, value_set from piction_module where module_name = pname and module_type = 'BF';
 cursor c5(typ varchar2) is
  select *
  from help_business_features
  where (typ = LNG3.ADM_TXT_684) or
        (grouping = typ)
  order by grouping,help_title;
 cursor c6(typ varchar2) is
  select *
  from help_business_features
  where (xref_a = typ) or (xref_b = typ) or (xref_c = typ)
  order by grouping,help_title;
 cursor c7(typ varchar2) is
  select *
  from help_business_features
  where upper(topic) like typ or
        upper(help_title) like typ
  order by grouping,help_title;
 cursor c8(fid integer) is
  select *
  from help_business_features
  where feature_id = fid
  order by grouping,help_title;
 cursor c9(bftr integer) is
  select *
  from help_business_features
  where feature_id = bftr
  order by grouping,help_title;

 c1rec		c1%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c8rec		c8%ROWTYPE;
 sessid		integer;
 jctr		integer;
 sts		varchar2(200);
 lastrec 	varchar2(100);
 tmp		char(1);
 nmb		integer;
 vttype		varchar2(100);

  procedure dispftr(surl varchar2, theme_rec in theme_types%ROWTYPE, c4rec in c4%ROWTYPE, src in varchar2, md in integer, c1rec in help_business_features%ROWTYPE, call in varchar2 )
  as

  begin
   if substr(c4rec.editeable,c1rec.feature_id,1) = 'T'
    then
      if md = 1 then htp.tablerowopen; end if;
      htp.tabledata( htf.bold(substr('F' || to_char(c1rec.feature_id),2)),cattributes=>glbx.QUERY_BACKGROUND );
      if substr(theme_rec.theme_data,c1rec.feature_id,1) = 'T' or ttype is null
       then
        htp.tabledata( htf.formcheckbox( 'P1', 'F' || to_char(c1rec.feature_id), 'CHECKED' ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
       else
        htp.tabledata( htf.formcheckbox( 'P1', 'F' || to_char(c1rec.feature_id) ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
      end if;
      if src is not null
       then
        if src = 'P'
         then
          htp.tabledata( htf.bold(LNG3.ADM_TXT_261),cattributes=>glbx.QUERY_CELL_BACKGROUND );
        elsif src = 'C'
         then
          htp.tabledata( htf.bold(LNG.PHG_TXT_199),cattributes=>glbx.QUERY_CELL_BACKGROUND );
        elsif src = 'G'
         then
          htp.tabledata( htf.bold(LNG3.ADM_TXT_546),cattributes=>glbx.QUERY_CELL_BACKGROUND );
        end if;
      end if;
      htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || '>' );
      htp.img( DECS.IMAGE_LOCATION || 'adminc/list.gif',cattributes=>'border=0',calt=>c1rec.topic );
      htp.bold(c1rec.help_title);
      htp.p( '</TD>' );
      htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || '>' );
      if c1rec.xref_a is not null
       then
        htp.anchor( 'lf.mnt_type_edit?surl=' || surl || '&ttype=' || replace(theme_rec.theme_type,' ','+') || '&typ=' || replace(c1rec.xref_a,' ','+') || '&call=X',initcap(c1rec.xref_a));
        else
         htp.p( '&nbsp;' );
      end if;
      if c1rec.xref_b is not null
       then
        htp.anchor( 'lf.mnt_type_edit?surl=' || surl || '&ttype=' || replace(theme_rec.theme_type,' ','+') || '&typ=' || replace(c1rec.xref_b,' ','+') || '&call=X',initcap(c1rec.xref_b));
      end if;
      if c1rec.xref_c is not null
       then
        htp.anchor( 'lf.mnt_type_edit?surl=' || surl || '&ttype=' || replace(theme_rec.theme_type,' ','+') || '&typ=' || replace(c1rec.xref_c,' ','+') || '&call=X',initcap(c1rec.xref_c));
      end if;
      htp.p( '</TD>' );
      htp.formhidden( 'P2', 'F' || to_char(c1rec.feature_id));
     if md = 0 then htp.tablerowclose; end if;
   else
    if substr(c4rec.value_set,c1rec.feature_id,1) = 'T'
     then
      htp.formhidden( 'P1','F' || to_char(c1rec.feature_id) );
    end if;
    htp.formhidden( 'P2','F' || to_char(c1rec.feature_id) );
   end if;
  end;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.MNT_TYPE_EDIT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if template = 'F'
  then
   open c1(ttype);
   fetch c1 into c1rec;
   close c1;
   vttype := ttype;
  else
   open c1a(ttype);
   fetch c1a into c1rec;
   close c1a;
   vttype := NULL;
 end if;
 adm.main_title( surl, sessid, LNG3.ADM_TXT_392 || ': ' || ttype, style=>'NOMENU', helpid=>'A53' );
 htp.nl;

 open c4( nvl( glbx.extract_master_parameter('PICTION_MODULE'), 'Enterprise'));
 fetch c4 into c4rec;
 close c4;

 if msg is not null then glbx.header_msg( msg ); end if;
 if typ is not null
  then
   if (vttype = LNG3.ADM_TXT_682) or (template = 'T')
    then
     htp.formopen( 'lf.accept_mnt_type_edit', ctarget=>'_top' );
     htp.formhidden( 'SURL',  glbx.rndsurl(surl));
     htp.formhidden( 'CALL', call );
     htp.bold( LNG3.ADM_TXT_395 || ':' );
     htp.formtext( 'TTYPE', 30, 100 );
     htp.nl;
    else
     htp.formopen( 'lf.accept_mnt_type_edit' );
     htp.formhidden( 'SURL',  glbx.rndsurl(surl));
     htp.formhidden( 'CALL', call );
     htp.formhidden( 'TTYPE', vttype );
   end if;
   htp.formhidden( 'P1', null );
   htp.formhidden( 'P2', null );
   htp.formhidden( 'TYP', typ );
 end if;

 -- Display Group of Business Features
 if call = 'N'
  then
   for c5rec in c5( typ ) loop
    if c5rec.grouping <> lastrec
     then
      htp.tableclose;
      htp.nl;
    end if;
    if c5rec.grouping <> lastrec or lastrec is null
     then
      htp.bold( c5rec.grouping );
      htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    end if;
    dispftr( surl, c1rec, c4rec, null, mod(c5%ROWCOUNT,2), c5rec, call );
    lastrec := c5rec.grouping;
   end loop;
  htp.tableclose;
  htp.nl;
 end if;

 -- Display Group of Disabled Business Features
 if call = 'F' and nvl(length(c1rec.theme_data),0) > 0
  then
   jctr := 0;
   for j in 1..length(c1rec.theme_data) loop
    if nvl(substr(c1rec.theme_data,j,1),'F') = 'F'
     then
      open c8(j);
      fetch c8 into c8rec;
      if c8%FOUND
       then
        close c8;
        jctr := jctr + 1;
        if c8rec.grouping <> lastrec
         then
          htp.tableclose;
          htp.nl;
        end if;
        if c8rec.grouping <> lastrec or lastrec is null
         then
          htp.bold( c8rec.grouping );
          htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
        end if;
        dispftr( surl, c1rec, c4rec, null, mod(jctr,2), c8rec, call );
        lastrec := c8rec.grouping;
      else
       close c8;
      end if;
    end if;
   end loop;
  htp.tableclose;
  htp.nl;
 end if;

 begin nmb := to_number(typ); exception when others then nmb := NULL; end;

 -- Search
 if call = 'S' and nmb is null
  then
   for c7rec in c7( '%' || upper(typ) || '%' ) loop
    if c7rec.grouping <> lastrec
     then
      htp.tableclose;
      htp.nl;
    end if;
    if c7rec.grouping <> lastrec or lastrec is null
     then
      htp.bold( c7rec.grouping );
      htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    end if;
    dispftr( surl, c1rec, c4rec, null, mod(c7%ROWCOUNT,2), c7rec, call );
    lastrec := c7rec.grouping;
   end loop;
  htp.tableclose;
  htp.nl;
 end if;

 -- Search for a business feature number
 if call = 'S' and nmb is not null
  then
   for c9rec in c9( nmb ) loop
    if c9rec.grouping <> lastrec
     then
      htp.tableclose;
      htp.nl;
    end if;
    if c9rec.grouping <> lastrec or lastrec is null
     then
      htp.bold( c9rec.grouping );
      htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    end if;
    dispftr( surl, c1rec, c4rec, null, mod(c9%ROWCOUNT,2), c9rec, call );
    lastrec := c9rec.grouping;
   end loop;
  htp.tableclose;
  htp.nl;
 end if;

 -- Cross Reference View
 if call = 'X'
  then
   htp.bold( typ );
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   for c6rec in c6( typ ) loop
   dispftr( surl, c1rec, c4rec, c6rec.belongs_to, mod(c6%ROWCOUNT,2), c6rec, call);
   end loop;
   htp.tableclose;
   htp.nl;
 end if;

 if typ is not null
  then
   if (vttype = LNG3.ADM_TXT_682) or (template = 'T')
    then
     htp.formsubmit( 'ACTION', LNG3.ADM_TXT_396 );
    else
     htp.formsubmit( 'ACTION', LNG.GLB_TXT_060 );
     open c2(vttype);
     fetch c2 into tmp;
     if c2%NOTFOUND
      then
       open c3(vttype);
       fetch c3 into tmp;
       if c3%NOTFOUND
        then
         htp.formsubmit( 'ACTION', LNG.SLD_TXT_004 );
       end if;
       close c3;
     end if;
     close c2;
     htp.formsubmit( 'ACTION', LNG3.ADM_TXT_686 );
     htp.formsubmit( 'ACTION', LNG5.EXT_TXT_049 );
   end if;
   htp.formclose;
   htp.nl;

   /*
   if (vttype <> LNG3.ADM_TXT_682) and (template = 'F')
    then
     htp.formopen( 'lf.xml_unload' );
     htp.formhidden( 'SURL',  glbx.rndsurl(surl));
     htp.formhidden( 'TYP','FTR' );
     htp.formhidden( 'P1',vttype );
     htp.italic( LNG3.ADM_TXT_181 || ': ' || htf.formtext( 'P2',30, 100,lower(replace(vttype,' ','_') || '.txt' )));
     htp.nl;
     htp.formsubmit( null,LNG3.ADM_TXT_398 );
     htp.formclose;
   end if;
   */

 end if;

 htp.htmlclose;
exception when others then
 glbx.error_details( 'LF', 'MNT_TYPE_EDIT', errmsg=>sqlerrm, extdet=>null);
end mnt_type_edit;

procedure accept_mnt_type_edit( surl varchar2, ttype in varchar2, typ in varchar2, action in varchar2 default null, call in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 cursor c1(ttype varchar2) is select 1 from photographer where theme_type = ttype;
 cursor c2(ttype varchar2) is select 1 from theme_types where theme_type = ttype;

 vttype varchar2(100);
 tot	integer;
 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.ACCEPT_MNT_TYPE_EDIT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if action = LNG.SLD_TXT_004
  then
   open c1(rtrim(ttype));
   fetch c1 into tot;
   if c1%FOUND
    then
     close c1;
     mnt_type_edit(surl,rtrim(ttype),typ,LNG3.ADM_TXT_399);
     return;
   end if;
   close c1;
   delete from limit_bf where theme_type = rtrim(ttype);
   delete from theme_types where theme_type = rtrim(ttype);
   commit;
   htp.htmlopen;
    glbx.header_msg( ttype || ' ' || LNG3.ADM_TXT_400 );
   htp.htmlclose;
   return;
 end if;

 vttype := glbx.strip_special_characters( rtrim(ttype) );
 if nvl(action,LNG3.ADM_TXT_396) = LNG3.ADM_TXT_396
  then
    tot := 0;
    open c2(vttype);
    fetch c2 into tot;
    close c2;
    if tot = 1 or vttype is null
     then
       mnt_type_edit(surl,vttype,typ,'F',LNG3.ADM_TXT_401 || ':' || vttype);
      return;
    end if;
    execute immediate 'insert into theme_types(theme_type) values (''' || vttype || ''')';
 end if;

 if action = LNG3.ADM_TXT_686
  then
   for j in p2.first..p2.last loop
    if p2(j) is not null
     then
      update theme_types set theme_data = substr(theme_data,1,to_number(substr(p2(j),2))-1) || 'T' || substr(theme_data,to_number(substr(p2(j),2))+1) where theme_type = vttype;
    end if;
   end loop;
 elsif action = LNG5.EXT_TXT_049
  then
   for j in p2.first..p2.last loop
    if p2(j) is not null
     then
      update theme_types set theme_data = substr(theme_data,1,to_number(substr(p2(j),2))-1) || 'F' || substr(theme_data,to_number(substr(p2(j),2))+1) where theme_type = vttype;
    end if;
   end loop;
  else
   -- Insert or Modify
   for j in p2.first..p2.last loop
    if p2(j) is not null
     then
      update theme_types set theme_data = substr(theme_data,1,to_number(substr(p2(j),2))-1) || 'F' || substr(theme_data,to_number(substr(p2(j),2))+1) where theme_type = vttype;
    end if;
   end loop;
   for j in p1.first..p1.last loop
    if p1(j) is not null
     then
      update theme_types set theme_data = substr(theme_data,1,to_number(substr(p1(j),2))-1) || 'T' || substr(theme_data,to_number(substr(p1(j),2))+1) where theme_type = vttype;
    end if;
   end loop;
 end if;

 commit;
 if substr(typ,1,1) = '!'
  then
   compare_bf(surl,vttype,substr(typ,2));
 elsif action = LNG3.ADM_TXT_396
  then
   mnt_type_frame(surl, vttype, 'F');
  else
   mnt_type_edit(surl, vttype, typ, 'F', LNG3.ADM_TXT_685, call);
 end if;
exception when others then
 glbx.error_details( 'LF', 'ACCEPT_MNT_TYPE_EDIT', errmsg=>sqlerrm, extdet=>null);
end accept_mnt_type_edit;

procedure mnt_type_xref( surl varchar2,ttype in varchar2 )
as
 cursor c1(ttype varchar2) is select business_name,username from photographer where theme_type = ttype order by business_name;
 cursor c2(ttype varchar2) is select account_name,username from customer_account where theme_type = ttype order by account_name;

 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.MNT_TYPE_XREF');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 adm.main_title( surl, sessid, LNG3.ADM_TXT_687 || ' : ' || ttype, style=>'NOMENU', helpid=>'A75' );
 htp.p( '<CENTER>' );
 htp.nl;
 htp.bold( LNG3.ADM_TXT_261 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.CST_TXT_004), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( htf.bold(LNG.GLB_TXT_076), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
  htp.tablerowclose;
  for c1rec in c1(ttype) loop
   htp.tablerowopen;
    htp.tabledata( c1rec.business_name, cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata( c1rec.username, cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.bold( LNG.PHG_TXT_199 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_164), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( htf.bold(LNG.GLB_TXT_076), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
  htp.tablerowclose;
  for c2rec in c2(ttype) loop
   htp.tablerowopen;
    htp.tabledata( c2rec.account_name, cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata( c2rec.username, cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LF', 'MNT_TYPE_XREF', errmsg=>sqlerrm, extdet=>'TTYPE:' || ttype);
end mnt_type_xref;

procedure mnt_type_frame( surl varchar2, ttype in varchar2, template in varchar2 default 'F' )
as

 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.MNT_TYPE_FRAME');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
  htp.htmlopen;
  htp.p( '<HEAD>' );
  htp.title( glbx.extract_master_parameter('MENU_TITLE') );
  htp.p( '</HEAD>' );
  htp.framesetopen('100%','20%,80%',cattributes=>'frameborder="1" framespacing="0" border="1"');
   htp.frame( 'lf.mnt_type_list?surl=' || glbx.rndsurl(surl) || '&ttype=' || translate(ttype,' ','+') || '&template=' || template,'ADM_SUB_LEFT');
   htp.frame( 'lf.mnt_type_edit?surl=' || glbx.rndsurl(surl) || '&ttype=' || translate(ttype,' ','+') || '&template=' || template|| '&typ=','ADM_SUB_RIGHT');
  htp.framesetclose;
  htp.p( '<BODY>' );
  htp.noframesopen;
   glbx.noframe(surl,'lf.MNT_TYPE_FRAME');
  htp.noframesclose;
  htp.p( '</BODY>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'LF', 'MNT_TYPE_FRAME', errmsg=>sqlerrm, extdet=>'TTYPE:' || ttype);
end mnt_type_frame;

procedure compare_bf( surl in varchar2, p1 in varchar2, p2 in varchar2 )
as

 cursor c1( ttype varchar2 ) is select theme_data from theme_types where theme_type = ttype;
 cursor c2( nmb integer ) is select * from help_business_features where feature_id = nmb;

 c1arec	c1%ROWTYPE;
 c1brec	c1%ROWTYPE;
 c2rec	c2%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'LF.COMPARE_BF');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 open c1(p1);
 fetch c1 into c1arec;
 close c1;
 open c1(p2);
 fetch c1 into c1brec;
 close c1;
 adm.main_title( surl, sessid, LNG3.ADM_TXT_628 || ' ' || P1 || '-' || P2, style=>'NOMENU' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'lf.accept_mnt_type_edit' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.formhidden( 'CALL', 'N' );
 htp.formhidden( 'TTYPE', p1 );
 htp.formhidden( 'P1', null );
 htp.formhidden( 'P2', null );
 htp.formhidden( 'TYP', '!' || p2 );
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
  htp.tablerowopen;
    htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
    htp.tabledata( htf.bold( p1 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
    htp.tabledata( htf.bold( p2 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
    htp.tabledata( htf.bold( LNG.PHG_TXT_348 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
    htp.tabledata( htf.bold(LNG3.ADM_TXT_395),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
    htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
    htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
    htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;
 for j in 1..length(c1arec.theme_data) loop
  if substr(c1arec.theme_data,j,1) <> ' ' and
     substr(c1brec.theme_data,j,1) <> ' ' and
     substr(c1arec.theme_data,j,1) <> substr(c1brec.theme_data,j,1)
   then
    open c2(j);
    fetch c2 into c2rec;
    close c2;
    htp.tablerowopen;
     if substr(c1arec.theme_data,j,1) = 'F'
      then
       htp.tabledata( htf.formcheckbox( 'P1', 'F' || to_char(j) ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
      else
       htp.tabledata( htf.formcheckbox( 'P1', 'F' || to_char(j), 'CHECKED' ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
     end if;
     htp.formhidden( 'P2', 'F' || to_char(j));
     htp.tabledata( substr(c1arec.theme_data,j,1),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tabledata( substr(c1brec.theme_data,j,1),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     if c2rec.belongs_to = 'P'
      then
       htp.tabledata( LNG3.ADM_TXT_261,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
     elsif c2rec.belongs_to = 'C'
      then
       htp.tabledata( LNG.PHG_TXT_199,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
     else
       htp.tabledata( LNG3.ADM_TXT_546,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
     end if;
     htp.tabledata( c2rec.help_title,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( c2rec.xref_a,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( c2rec.xref_b,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( c2rec.xref_c,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
  end if;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION', LNG.GLB_TXT_060 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LF', 'COMPARE_BF', errmsg=>sqlerrm, extdet=>'P1:' || p1 || ' P2:' || p2);
end compare_bf;

procedure audit_parm( surl varchar2, parm varchar2 )
as

 cursor c1(parm varchar2) is select * from master_parameters where parm_name = parm;
 cursor c2(parm varchar2) is select * from audit_master_parameters where parm_name = parm order by date_updated desc;

 c1rec		c1%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 lval		varchar2(1000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.AUDIT_PARM');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 adm.main_title( surl, sessid, 'Master Parameter Audit', style=>'NOMENU', helpid=>'A108' );
 htp.p('<CENTER>');
 open c1(parm);
 fetch c1 into c1rec;
 close c1;
 htp.bold( c1rec.help_on );
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Date Update' ) );
   htp.tabledata( htf.bold( 'New Value' ) );
   --htp.tabledata( htf.bold( 'Session Id' ) );
  htp.tablerowclose;
  for c2rec in c2(parm) loop
   if nvl(c2rec.new_value,'!') <> nvl(lval,'!')
   then
    htp.tablerowopen;
     htp.tabledata( to_char( c2rec.date_updated, LNG.TSMASK ) );
     htp.tabledata( nvl(c2rec.new_value,'&nbsp;') );
     --htp.tabledata( c2rec.sessid );
    htp.tablerowclose;
   end if;
   lval := c2rec.new_value;
  end loop;
  htp.tableclose;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LF', 'AUDIT_PARM', errmsg=>sqlerrm, extdet=>'PARM:' || parm);
end audit_parm;

procedure mnt_master( surl varchar2, msg in varchar2 default null )
as
 cursor c1 is select * from master_parameters order by parm_group,help_on;

 tmp		varchar2(2000);
 sessid		integer;
 sts		varchar2(200);
 last_grp	varchar2(100);

 function parm_audit( vl in varchar2, hlp in varchar2 )
  return varchar2
 as
 begin
 return( '<A HREF="javascript: window.open(''' || 'lf.audit_parm?surl=' || surl || '&parm=' || replace(vl,' ','+') || ''',''master_parameters'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=500,height=500'');void('''');">' || hlp || '</A>' );
 end parm_audit;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.MNT_MASTER');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 adm.main_title( surl, sessid, LNG3.ADM_TXT_013, helpid=>'A02' );
 htp.p('<CENTER>');
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
 htp.tablerowopen;
 htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">');

 htp.formopen( 'lf.accept_mnt_master' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.formhidden( 'PARM3', NULL );
 last_grp := NULL;
 for c1rec in c1 loop
  if (last_grp is null) or (last_grp <> c1rec.parm_group)
   then
    if last_grp is not null
     then
      htp.tableclose;
      htp.nl;
    end if;
    htp.nl;
    htp.bold( initcap( c1rec.parm_group ));
    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || GLBX.TABLE_BACKGROUND );
  end if;
  last_grp := c1rec.parm_group;

  if c1rec.parm_type in ('NUMBER','VARCHAR')
   then
    htp.tablerowopen;
     htp.tabledata( parm_audit( c1rec.parm_name, c1rec.help_on ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'PARM1', c1rec.parm_name );
     htp.tabledata(htf.formtext('PARM2',80, 1000, c1rec.parm_value ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
  elsif c1rec.parm_type = 'LOCKED'
   then
    htp.tablerowopen;
     htp.tabledata(parm_audit( c1rec.parm_name, c1rec.help_on ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c1rec.parm_value ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
  elsif c1rec.parm_type = 'BOOLEAN'
   then
    htp.tablerowopen;
     htp.tabledata(parm_audit( c1rec.parm_name, c1rec.help_on ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.parm_value = 'TRUE'
      then
        htp.tabledata(htf.formcheckbox('PARM3', c1rec.parm_name, 'CHECKED' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      else
        htp.tabledata(htf.formcheckbox('PARM3', c1rec.parm_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
    htp.tablerowclose;
  elsif c1rec.parm_type = 'LOV'
   then
    if c1rec.parm_name = 'MERCHANT_PROVIDER'
     then
      htp.tablerowopen;
       htp.tabledata(parm_audit( c1rec.parm_name, c1rec.help_on ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.formhidden( 'PARM1', c1rec.parm_name );
       htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
       htp.formselectopen( 'PARM2' );
       if c1rec.parm_value = 'ANZ' then htp.formselectoption( 'ANZ', 'SELECTED' ); else htp.formselectoption( 'ANZ' ); end if;
       if c1rec.parm_value = 'ANZ-II' then htp.formselectoption( 'ANZ-II', 'SELECTED' ); else htp.formselectoption( 'ANZ-II' ); end if;
       if c1rec.parm_value = 'CBANK' then htp.formselectoption( 'CBANK', 'SELECTED' ); else htp.formselectoption( 'CBANK' ); end if;
       if c1rec.parm_value = 'CYBERONE' then htp.formselectoption( 'CYBERONE', 'SELECTED' ); else htp.formselectoption( 'CYBERONE' ); end if;
       if c1rec.parm_value = 'ESEC' then htp.formselectoption( 'ESEC', 'SELECTED' ); else htp.formselectoption( 'ESEC' ); end if;
       if c1rec.parm_value = 'SAFEPAY' then htp.formselectoption( 'SAFEPAY', 'SELECTED' ); else htp.formselectoption( 'SAFEPAY' ); end if;
       if c1rec.parm_value = 'SECUREPAY' then htp.formselectoption( 'SECUREPAY', 'SELECTED' ); else htp.formselectoption( 'SECUREPAY' ); end if;
       if c1rec.parm_value = 'SECUREBILL' then htp.formselectoption( 'SECUREBILL', 'SELECTED' ); else htp.formselectoption( 'SECUREBILL' ); end if;
       if c1rec.parm_value = 'NAB' then htp.formselectoption( 'NAB', 'SELECTED' ); else htp.formselectoption( 'NAB' ); end if;
       if c1rec.parm_value = 'DIRECT PAYMENT(NZ)' then htp.formselectoption( 'DIRECT PAYMENT(NZ)', 'SELECTED' ); else htp.formselectoption( 'DIRECT PAYMENT(NZ)' ); end if;
       if c1rec.parm_value = 'HOME' then htp.formselectoption( 'HOME', 'SELECTED' ); else htp.formselectoption( 'HOME' ); end if;
       htp.formselectclose;
       htp.p( '</TD>' );
      htp.tablerowclose;
    end if;
  elsif c1rec.parm_type = 'COLOUR'
   then
    disp_c3( surl,'PARM2',c1rec.parm_value,parm_audit( c1rec.parm_name, c1rec.help_on ) );
    htp.formhidden( 'PARM1', c1rec.parm_name );
  end if;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_013 );
 htp.formclose;

 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LF', 'MNT_MASTER', errmsg=>sqlerrm, extdet=>null);
end mnt_master;

procedure accept_mnt_master( surl varchar2, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, parm3 in GLBX.MYARRAY )
as

 cursor c1(nme varchar2) is select clr_hex from colours where clr_name = nme;
 cursor c2(pname varchar2) is select parm_type from master_parameters where parm_name = pname;

 c2rec	c2%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);
 nmb	integer;
 vmf	varchar2(1000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.ACCEPT_MNT_MASTER');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 for j in parm1.first..parm1.last loop
  open c2(parm1(j));
  fetch c2 into c2rec;
  close c2;
  if c2rec.parm_type in ('VARCHAR','LOV')
   then
    vmf := parm2(j);
  elsif c2rec.parm_type = 'NUMBER'
   then
     begin
      nmb := to_number(parm2(j));
     exception
      when others
       then
        nmb := NULL;
     end;
     vmf := to_char(nmb);
  elsif c2rec.parm_type = 'COLOUR'
   then
     open c1(parm2(j));
     fetch c1 into vmf;
     close c1;
  end if;
  update master_parameters
   set
    parm_value = vmf
   where parm_name = parm1(j);
  insert into audit_master_parameters(parm_name,date_updated,old_value,new_value,sessid) values ( parm1(j), sysdate, null, vmf, sessid );
 end loop;

 update master_parameters
  set
   parm_value = 'FALSE'
    where parm_type = 'BOOLEAN';
  insert into audit_master_parameters(parm_name,date_updated,old_value,new_value,sessid)
   select parm_name,sysdate,parm_value,'FALSE',sessid
   from master_parameters
   where parm_type = 'BOOLEAN' and
         parm_value <> 'FALSE';

 for j in parm3.first..parm3.last loop
  if parm3(j) is not null
   then
    update master_parameters
     set
     parm_value = 'TRUE'
     where parm_name = parm3(j);
     insert into audit_master_parameters(parm_name,date_updated,old_value,new_value,sessid) values ( parm3(j), sysdate, null, 'TRUE', sessid );
  end if;
 end loop;

 commit;
 mnt_master( surl,LNG3.ADM_TXT_012 );
exception when others then
 glbx.error_details( 'LF', 'ACCEPT_MNT_MASTER', errmsg=>sqlerrm, extdet=>null);
end accept_mnt_master;


procedure gcard( surl varchar2 )
as

 cursor c1 is select * from ecard_style order by style_name;
 cursor c2( styl varchar2 ) is
   select count('x') tot, sum(decode( shape, '1', 1, 0)) tot_1, sum(decode( shape, '2', 1, 0)) tot_2, sum(decode( shape, '3', 1, 0)) tot_3,  sum(decode( shape, '4', 1, 0)) tot_4
   from ecard
   where style = styl;
 cursor c3 is select count('x') tot from ecard;

 c2rec	c2%ROWTYPE;
 c3rec	c3%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.GCARD');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 adm.main_title( surl, sessid, LNG4.AHC_TXT_356, helpid=>'A84' );
 htp.p('<CENTER>');
 htp.nl;
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('lf.mng_gcard?surl=' || glbx.rndsurl(surl) || '&gcard=',LNG4.AHC_TXT_357,ctarget=>'ADM_GCARD'),cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG4.AHC_TXT_358),cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold(LNG4.AHC_TXT_421),cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold(LNG.CST_TXT_209),cattributes=>glbx.QUERY_BACKGROUND );
  htp.tablerowclose;
 open c3;
 fetch c3 into c3rec;
 close c3;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( htf.anchor2( 'lf.mng_gcard?surl=' || glbx.rndsurl(surl) || '&gcard=' || translate( c1rec.style_name,' ','+'),c1rec.style_name,ctarget=>'ADM_GCARD'),cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tabledata( '&nbsp;&nbsp;&nbsp;&nbsp',cattributes=>'bgcolor="#' || c1rec.ec_font || '"' );
   open c2( c1rec.style_name );
   fetch c2 into c2rec;
   close c2;
   htp.tabledata( round(((c2rec.tot / c3rec.tot)*100),2) || '%' || htf.nl ||
                  '1:' || c2rec.tot_1 || ' 2:' || c2rec.tot_2 || ' 3:' || c2rec.tot_3 || ' 4:' || c2rec.tot_4,cattributes=>glbx.QUERY_CELL_BACKGROUND );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LF', 'GCARD', errmsg=>sqlerrm, extdet=>null);
end gcard;

procedure mng_gcard( surl varchar2, gcard in varchar2, msg in varchar2 default null)
as

 cursor c1( gcard varchar2 ) is select * from ecard_style where style_name = gcard;
 cursor c2 is select pid,username,business_name from photographer order by business_name,username;

 c1rec	c1%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.MNG_GCARD');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if gcard is null
  then
   adm.main_title( surl, sessid, LNG4.AHC_TXT_361, helpid=>'A84', style=>'NOMENU' );
  else
   open c1( gcard );
   fetch c1 into c1rec;
   close c1;
   adm.main_title( surl, sessid, LNG4.AHC_TXT_360 || ' : ' || gcard, helpid=>'A84', style=>'NOMENU' );
 end if;
 htp.p('<CENTER>');
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.formopen( 'lf.accept_mng_gcard' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'GCARD', gcard );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG4.AHC_TXT_363),cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata(htf.formtext( 'P1', 30, 100, c1rec.style_name ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tabledata('&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND );
  htp.tablerowclose;
  lf.disp_c3( surl, 'P2', c1rec.ec_font, LNG4.AHC_TXT_359, 'P3' );
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG4.AHC_TXT_364),cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || '>' );
   htp.formtext( 'P4', 30, 100, c1rec.ec_image );
   htp.p( '</TD>' );
   htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold('Photographer'),cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || '>' );
   htp.formselectopen( 'P5' );
   htp.formselectoption( NULL );
   for c2rec in c2 loop
    if c1rec.pid = c2rec.pid
     then
      htp.formselectoption( c2rec.business_name || '(' || c2rec.username || ')', 'SELECTED', cattributes=>'VALUE="' || c2rec.pid || '"' );
     else
      htp.formselectoption( c2rec.business_name || '(' || c2rec.username || ')', cattributes=>'VALUE="' || c2rec.pid || '"' );
    end if;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
   if c1rec.ec_image is not null
    then
     htp.tableopen( cattributes=>'width=75% cellpadding=0 cellspacing=0 border=0' );
      htp.tablerowopen;
       htp.p( '<TD BACKGROUND="' || DECS.IMAGE_LOCATION || 'gcard/' || c1rec.ec_image || '">' );
       htp.nl;
       htp.nl;
       htp.nl;
       htp.nl;
       htp.p( '<FONT COLOR="#' || c1rec.ec_font || '">' || LNG4.AHC_TXT_364 || '</FONT>');
       htp.nl;
       htp.nl;
       htp.nl;
       htp.nl;
       htp.p( '</TD>' );
      htp.tablerowclose;
     htp.tableclose;
   end if;
 htp.nl;
 if gcard is null
  then
   htp.formsubmit( 'ACTION', LNG4.AHC_TXT_361);
  else
   htp.formsubmit( 'ACTION', LNG4.AHC_TXT_362);
   htp.formsubmit( 'ACTION', LNG4.AHC_TXT_369);
 end if;
 htp.formclose;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LF', 'MNG_GCARD', errmsg=>sqlerrm, extdet=>'GCARD:' || gcard);
end mng_gcard;

procedure accept_mng_gcard( surl varchar2, gcard in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, action in varchar2)
as

 cursor c1( gcard varchar2 ) is select * from ecard_style where style_name = gcard;

 c1rec	c1%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'lf.ACCEPT_MNG_GCARD');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if action = LNG4.AHC_TXT_361
  then
   if p1 is null
    then
     mng_gcard(surl,null,LNG4.AHC_TXT_366);
     return;
   end if;
   open c1(p1);
   fetch c1 into c1rec;
   if c1%FOUND
    then
     close c1;
     mng_gcard(surl,null,LNG4.AHC_TXT_367);
     return;
   end if;
   close c1;
   insert into ecard_style(style_name,ec_image,ec_font,pid) values (p1,p4,p2,p5);
   mng_gcard(surl,p1,LNG4.AHC_TXT_371);
   return;
 elsif action = LNG4.AHC_TXT_369
  then
   delete from ecard_style where style_name = gcard;
   commit;
   htp.htmlopen;
   htp.header(2,LNG4.AHC_TXT_370,'CENTER' );
   htp.nl;
   htp.p('</CENTER>');
   htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
   htp.p('</CENTER>');
   htp.htmlclose;
   return;
  else
   if p1 is null
    then
     mng_gcard(surl,gcard,LNG4.AHC_TXT_366);
     return;
   end if;
   if gcard <> p1
    then
     open c1(p1);
     fetch c1 into c1rec;
     if c1%FOUND
      then
       close c1;
       mng_gcard(surl,gcard,LNG4.AHC_TXT_367);
       return;
     end if;
     close c1;
    end if;
    update ecard_style
      set
       style_name = p1,
       ec_image = p4,
       ec_font = p2,
       pid = p5
    where
      style_name = gcard;
    commit;
    mng_gcard(surl,p1,LNG4.AHC_TXT_368);
 end if;
exception when others then
 glbx.error_details( 'LF', 'ACCEPT_MNG_GCARD', errmsg=>sqlerrm, extdet=>'GCARD:' || gcard);
end accept_mng_gcard;

procedure scont( surl in varchar2, pfx in THEME%ROWTYPE )
as

 cursor c1( tname varchar2 ) is select * from screen_controller where theme_name = tname order by ctype,controller;
 cursor c1a( tname varchar2 ) is select count('x') cnt from screen_controller where theme_name = tname order by ctype,controller;
 cursor c2( contr varchar2 ) is select description from screen_controller where theme_name = 'DEFAULT' and controller = contr;

 c2rec	c2%ROWTYPE;
 cnt	integer;

begin
 cnt := 0;
 open c1a( pfx.theme_name );
 fetch c1a into cnt;
 close c1a;
 if cnt = 0
  then
        insert into screen_controller(theme_name,controller,ctype,v_screen_0,n_screen_0,v_screen_1,n_screen_1,v_screen_2,n_screen_2,v_screen_3,n_screen_3,v_screen_4,n_screen_4,v_screen_5,n_screen_5,v_screen_6,n_screen_6,v_screen_7,n_screen_7)
         select pfx.theme_name,controller,ctype,v_screen_0,n_screen_0,v_screen_1,n_screen_1,v_screen_2,n_screen_2,v_screen_3,n_screen_3,v_screen_4,n_screen_4,v_screen_5,n_screen_5,v_screen_6,n_screen_6,v_screen_7,n_screen_7
         from screen_controller
         where theme_name = 'DEFAULT';
         htp.nl;
         htp.nl;
         htp.nl;
         htp.bold( 'There were **Missing** Details for Screen Controller: Now Fixed' );
         htp.nl;
         htp.nl;
         htp.nl;
         commit;
 end if;
   htp.formopen( 'lf.accept_scont' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl) );
   htp.formhidden( 'THM', pfx.theme_name );
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Controller' ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( 'Value Type' ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( '0. Mobile<BR>No Javascript' ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( '1. 0-799' ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( '2. 800-1023' ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( '3. 1024-1279' ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( '4. 1280-1399' ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( '5. 1400x1599' ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( '6. 1600x1899' ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( '7. >1900' ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   for c1rec in c1( pfx.theme_name ) loop
    htp.tablerowopen;
     open c2(c1rec.controller);
     fetch c2 into c2rec;
     close c2;
     htp.tabledata(htf.formhidden( 'P0', c1rec.controller ) || htf.bold( c2rec.description ) || htf.nl || htf.italic(c1rec.controller),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.ctype = 'V'
      then
       htp.tabledata( 'Character',cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata( 'Number',cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     end if;
     if c1rec.ctype = 'V'
      then
       htp.tabledata(htf.formtext( 'P0X',15, 30, replace(replace(c1rec.v_screen_0,'"','&#34;'),'%','&#37;')),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.formtext( 'P0X',10, 30, c1rec.n_screen_0),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     end if;
     if c1rec.ctype = 'V'
      then
       htp.tabledata(htf.formtext( 'P1',15, 30, replace(replace(c1rec.v_screen_1,'"','&#34;'),'%','&#37;')),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.formtext( 'P1',10, 30, c1rec.n_screen_1),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     end if;
     if c1rec.ctype = 'V'
      then
       htp.tabledata(htf.formtext( 'P2',15, 30, replace(replace(c1rec.v_screen_2,'"','&#34;'),'%','&#37;')),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.formtext( 'P2',10, 30, c1rec.n_screen_2),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     end if;
     if c1rec.ctype = 'V'
      then
       htp.tabledata(htf.formtext( 'P3',15, 30, replace(replace(c1rec.v_screen_3,'"','&#34;'),'%','&#37;')),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.formtext( 'P3',10, 30, c1rec.n_screen_3),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     end if;
     if c1rec.ctype = 'V'
      then
       htp.tabledata(htf.formtext( 'P4',15, 30, replace(replace(c1rec.v_screen_4,'"','&#34;'),'%','&#37;')),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.formtext( 'P4',10, 30, c1rec.n_screen_4),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     end if;
     if c1rec.ctype = 'V'
      then
       htp.tabledata(htf.formtext( 'P5',15, 30, replace(replace(c1rec.v_screen_5,'"','&#34;'),'%','&#37;')),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.formtext( 'P5',10, 30, c1rec.n_screen_5),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     end if;
     if c1rec.ctype = 'V'
      then
       htp.tabledata(htf.formtext( 'P6',15, 30, replace(replace(c1rec.v_screen_6,'"','&#34;'),'%','&#37;')),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.formtext( 'P6',10, 30, c1rec.n_screen_6),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     end if;
     if c1rec.ctype = 'V'
      then
       htp.tabledata(htf.formtext( 'P7',15, 30, replace(replace(c1rec.v_screen_7,'"','&#34;'),'%','&#37;')),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.formtext( 'P7',10, 30, c1rec.n_screen_7),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     end if;
    htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( null, LNG3.ADM_TXT_221 );
   htp.formclose;
end scont;

procedure accept_scont( surl in varchar2, thm in varchar2, p0 in GLBX.MYARRAY, p0x in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY,p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY )
as

 cursor c2( thm varchar2, contr varchar2 ) is select * from screen_controller where theme_name = thm and controller = contr;

 c2rec		c2%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 err		varchar2(200);
 nmb0		number;
 nmb1		number;
 nmb2		number;
 nmb3		number;
 nmb4		number;
 nmb5		number;
 nmb6		number;
 nmb7		number;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'LF.ACCEPT_SCONT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 for j in p0.first..p0.last loop
  open c2(thm,p0(j));
  fetch c2 into c2rec;
  close c2;
  if c2rec.ctype = 'N'
   then
    begin nmb0 := to_number(p0x(j)); exception when others then nmb0 := c2rec.n_screen_0; err := 'Invalid Number Entered:' || '0.' || p0(j); end;
    begin nmb1 := to_number(p1(j)); exception when others then nmb1 := c2rec.n_screen_1; err := 'Invalid Number Entered:' || '1.' || p0(j); end;
    begin nmb2 := to_number(p2(j)); exception when others then nmb2 := c2rec.n_screen_2; err := 'Invalid Number Entered:' || '2.' || p0(j); end;
    begin nmb3 := to_number(p3(j)); exception when others then nmb3 := c2rec.n_screen_3; err := 'Invalid Number Entered:' || '3.' || p0(j); end;
    begin nmb4 := to_number(p4(j)); exception when others then nmb4 := c2rec.n_screen_4; err := 'Invalid Number Entered:' || '4.' || p0(j); end;
    begin nmb5 := to_number(p5(j)); exception when others then nmb5 := c2rec.n_screen_5; err := 'Invalid Number Entered:' || '5.' || p0(j); end;
    begin nmb6 := to_number(p6(j)); exception when others then nmb6 := c2rec.n_screen_6; err := 'Invalid Number Entered:' || '6.' || p0(j); end;
    begin nmb7 := to_number(p7(j)); exception when others then nmb7 := c2rec.n_screen_7; err := 'Invalid Number Entered:' || '7.' || p0(j); end;

    update screen_controller
     set
      n_screen_0 = nmb0,
      n_screen_1 = nmb1,
      n_screen_2 = nmb2,
      n_screen_3 = nmb3,
      n_screen_4 = nmb4,
      n_screen_5 = nmb5,
      n_screen_6 = nmb6,
      n_screen_7 = nmb7
    where
     theme_name = thm and
     controller = p0(j);
   else
    update screen_controller
     set
      v_screen_0 = p0x(j),
      v_screen_1 = p1(j),
      v_screen_2 = p2(j),
      v_screen_3 = p3(j),
      v_screen_4 = p4(j),
      v_screen_5 = p5(j),
      v_screen_6 = p6(j),
      v_screen_7 = p7(j)
    where
     theme_name = thm and
     controller = p0(j);
  end if;
 end loop;
 commit;

 theme_right( surl, thm, 'SCREENSIZE', nvl(err,'Modified') );

exception
 when others then theme_right( surl, thm, 'SCREENSIZE', 'Invalid Value Entered:' || sqlerrm );
end accept_scont;

procedure mnt_type( surl varchar2, msg in varchar2 default null )
as
 cursor c1 is select theme_type from theme_types order by upper(theme_type);
 cursor c2 is select theme_type from theme_types_template order by (theme_type);

 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'LF.MNT_TYPE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 adm.main_title( surl, sessid, LNG3.ADM_TXT_392, helpid=>'A53' );
 htp.nl;
 htp.p('<CENTER>');
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lf.mnt_type_frame?surl=' || glbx.rndsurl(surl) || '&ttype=' || translate(LNG3.ADM_TXT_682,' ','+'), '[' || LNG3.ADM_TXT_682 || ']',ctarget=>new_window),cattributes=>glbx.QUERY_BACKGROUND );
  for c1rec in c1 loop
   if mod(c1%ROWCOUNT,5) = 1
    then
     htp.tablerowclose;
     htp.tablerowopen;
   end if;
   htp.tabledata( htf.anchor2('lf.mnt_type_frame?surl=' || glbx.rndsurl(surl) || '&ttype=' || translate(c1rec.theme_type,' ','+'), c1rec.theme_type,ctarget=>new_window),cattributes=>glbx.QUERY_CELL_BACKGROUND );
  end loop;
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.line;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_747 );
 htp.nl;
 htp.nl;
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
  for c2rec in c2 loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('lf.mnt_type_frame?surl=' || glbx.rndsurl(surl) || '&ttype=' || translate(c2rec.theme_type,' ','+') || '&template=T', c2rec.theme_type,ctarget=>new_window),cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.line;
 htp.nl;
 htp.bold( LNG4.AHC_TXT_267 );
 htp.nl;
 htp.formopen( 'lf.bus_change' );
 htp.formhidden( 'SURL', surl );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_269 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.formtext( 'P1', 10, 20 ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_268 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.formcheckbox( 'P2', 'T', 'CHECKED' ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG4.AHC_TXT_270 );
 htp.formclose;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LF', 'MNT_TYPE', errmsg=>sqlerrm, extdet=>null);
end mnt_type;

procedure bus_change( surl in varchar2, p1 in varchar2, p2 in varchar2 default 'F' )
as

 sessid	integer;
 sts	varchar2(200);

 nmb	integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'LF.BUS_CHANGE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 begin nmb := to_number( p1 ); exception when others then nmb := NULL; end;

 if nmb is null then mnt_type( surl, LNG4.AHC_TXT_272 ); return; end if;

 update theme_types
  set
    theme_data = substr(theme_data,1,nmb-1) || p2 || substr(theme_data,nmb+1);
 commit;
 mnt_type( surl, LNG4.AHC_TXT_271 );

exception when others then
 glbx.error_details( 'LF', 'BUS_CHANGE', errmsg=>sqlerrm, extdet=>null);
end bus_change;

procedure repall(surl varchar2, tname varchar2)
as

 cursor c2(tname varchar2) is select username, business_name from photographer where default_lf = tname order by business_name;
 cursor c3(tname varchar2) is select username, account_name from customer_account where theme_name = tname order by account_name;
 cursor c4(tname varchar2) is select username, name from manufacturer where theme_name = tname order by name;
 cursor c5(tname varchar2) is select username, account_name from customer_profile where theme_name = tname order by account_name;

 sessid	integer;
 sts	varchar2(200);
 tmp	varchar2(2000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'LF.REPALL');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 adm.main_title( surl, sessid, LNG3.ADM_TXT_687, style=>'NOMENU', helpid=>'A47' );
 htp.nl;

 htp.bold( 'Clients' );
 htp.nl;
 htp.ulistopen;
 for c2rec in c2(tname) loop
  htp.listitem(c2rec.business_name || ' ' || c2rec.username);
 end loop;
 htp.ulistclose;
 htp.nl;
 htp.nl;

 htp.bold( 'Customers' );
 htp.nl;
 htp.ulistopen;
 for c3rec in c3(tname) loop
  htp.listitem(c3rec.account_name || ' ' || c3rec.username);
 end loop;
 htp.ulistclose;
 htp.nl;
 htp.nl;

 htp.bold( 'Manufacturers' );
 htp.nl;
 htp.ulistopen;
 for c4rec in c4(tname) loop
  htp.listitem(c4rec.name || ' ' || c4rec.username);
 end loop;
 htp.ulistclose;
 htp.nl;
 htp.nl;

 htp.bold( 'Profiles' );
 htp.nl;
 htp.ulistopen;
 for c5rec in c5(tname) loop
  htp.listitem(c5rec.account_name || ' ' || c5rec.username);
 end loop;
 htp.ulistclose;
 htp.nl;

 htp.htmlclose;
exception when others then
 glbx.error_details( 'LF', 'REPALL', errmsg=>sqlerrm, extdet=>null);
end repall;

end lf;

/
