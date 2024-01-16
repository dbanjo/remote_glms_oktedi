CREATE OR REPLACE package body WEBSYS.virage
as

procedure virage_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure context_run(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure context_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure move_context_data(v_umo in integer);

procedure main(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as
begin

 if called_from = 'MAIN' and first_parameter = 'VIRAGE'
  then
   virage_run(surl,nvid,loc_id,footer_api,left_api_parm,current_page_number,display_detail,acid,first_parameter,called_from );

 elsif called_from = 'LIGHTBOX'
  then
   null;

 elsif called_from = 'PREFERENCES' and first_parameter = 'VIRAGE'
  then
   virage_pref(surl,nvid,loc_id,acid,first_parameter,called_from );

 elsif called_from = 'PREFERENCES' and first_parameter = 'CONTEXT'
  then
   context_pref(surl,nvid,loc_id,acid,first_parameter,called_from );

 elsif first_parameter = 'CONTEXT'
  then
   context_run(surl,nvid,loc_id,footer_api,left_api_parm,current_page_number,display_detail,acid,first_parameter,called_from );

 elsif called_from = 'LIGHTBOX'
  then
   null;

 end if;

exception when others then
 glbx.error_details( 'VIRAGE', 'MAIN',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end main;

procedure virage_run(surl in varchar2, nvid in integer default null, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2 default null, called_from in varchar2 default null, msg in varchar2 default null )
as


 cursor c1(v_umo integer) is select * from umo where umo_id = v_umo;

 umrec		c1%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'VIRAGE.VIRAGE_RUN' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 open c1(loc_id);
 fetch c1 into umrec;
 close c1;

 glbx.main_title( surl, 'Content Based Image Match', glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype), stype=>1, sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );

 htp.formopen( 'virage.accept_virage_run' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'FOOTER_API', 'virage.accept_virage_run' );
 htp.formhidden( 'LEFT_API_PARM', loc_id );
 htp.formhidden( 'START_FROM', '1' );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );

 glbx.image_matte(pfx,umrec.photo_master.width,umrec.photo_master.height,
                   null,
                   '<IMG BORDER=0 WIDTH=' || umrec.photo_master.width || ' HEIGHT=' || umrec.photo_master.height || ' SRC="' ||
                   'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || cusrec.aid || '&parm1=VERSION&parm2=' || umrec.version ||
                   '" ALT="' || umrec.extras.photo_name || '" STYLE="display:block;">', null );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0' );
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Colour Match' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'P1' );
     htp.formselectoption( 'Must Match', cattributes=>'VALUE="100"' );
     htp.formselectoption( 'Very Important', 'SELECTED', cattributes=>'VALUE="80"' );
     htp.formselectoption( 'Important', cattributes=>'VALUE="60"' );
     htp.formselectoption( 'Average', cattributes=>'VALUE="40"' );
     htp.formselectoption( 'Below Average', cattributes=>'VALUE="20"' );
     htp.formselectoption( 'Not Important', cattributes=>'VALUE="10"' );
    htp.formselectclose;
    htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Texture Match' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'P2' );
     htp.formselectoption( 'Must Match', cattributes=>'VALUE="100"' );
     htp.formselectoption( 'Very Important', cattributes=>'VALUE="80"' );
     htp.formselectoption( 'Important', cattributes=>'VALUE="60"' );
     htp.formselectoption( 'Average', cattributes=>'VALUE="40"' );
     htp.formselectoption( 'Below Average', cattributes=>'VALUE="20"' );
     htp.formselectoption( 'Not Important', 'SELECTED', cattributes=>'VALUE="10"' );
    htp.formselectclose;
    htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Shape Match' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'P3' );
     htp.formselectoption( 'Must Match', cattributes=>'VALUE="100"' );
     htp.formselectoption( 'Very Important', cattributes=>'VALUE="80"' );
     htp.formselectoption( 'Important', 'SELECTED', cattributes=>'VALUE="60"' );
     htp.formselectoption( 'Average', cattributes=>'VALUE="40"' );
     htp.formselectoption( 'Below Average', cattributes=>'VALUE="20"' );
     htp.formselectoption( 'Not Important', cattributes=>'VALUE="10"' );
    htp.formselectclose;
    htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Importance of the Final Match' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'P4' );
     htp.formselectoption( 'Must be Identical', cattributes=>'VALUE="5"' );
     htp.formselectoption( 'Must Match Very Closely', cattributes=>'VALUE="10"' );
     htp.formselectoption( 'Must be a Very Good Match', 'SELECTED', cattributes=>'VALUE="15"' );
     htp.formselectoption( 'Must be a Good Match', cattributes=>'VALUE="20"' );
     htp.formselectoption( 'Can be a Loose Match', cattributes=>'VALUE="25"' );
     htp.formselectoption( 'Match is not Important', cattributes=>'VALUE="40"' );
    htp.formselectclose;
    htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, 'Search' );
 htp.formclose;
 htp.nl;
 htp.nl;
 htp.line;
 htp.nl;
 htp.nl;

 htp.formopen( 'virage.accept_virage_run' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'FOOTER_API', 'virage.accept_virage_run' );
 htp.formhidden( 'LEFT_API_PARM', loc_id );
 htp.formhidden( 'START_FROM', '1' );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0' );
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Colour Match' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formtext( 'P1', 10, 20, '80' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Texture Match' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formtext( 'P2', 10, 20, '10' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Shape Match' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formtext( 'P3', 10, 20, '60' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Importance of the Final Match' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formtext( 'P4', 10, 20, '15' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, ' Advanced Search' );
 htp.formclose;

 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'VIRAGE', 'VIRAGE_RUN',cusrec.pid,owner_id,errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end virage_run;

procedure accept_virage_run(surl in varchar2, footer_api in varchar2 default null, left_api_parm in varchar2, start_from in integer, display_detail in char default null, acid in integer,
                            p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null, p5 in varchar2 default null, pstr in varchar2 default null )
as

 cursor c1(v_umo integer) is select * from umo where umo_id = v_umo;

 -- V8
 cursor c2(v_umo integer, sig raw, acid integer, v1 varchar2, v2 varchar2, v3 varchar2, v4 integer) is
  select *
  from umo um
  where umo_type || null = 'PHOTO' and
        aid + 0 = acid and
        umo_id + 0 <> v_umo and
        ORDSYS.VIRSimilar(um.signature, sig, 'globalcolor="' || v1 || '"  localcolor="' || v1 || '" texture="' || v2 || '" structure="' || v3 || '"', v4, 123) = 1
  order by ORDSYS.VIRScore(123);
--        dbms_lob.getlength(um.photo_master.source.localdata) > 0 and

 cursor c4(v_umo integer, sig raw, acid integer, v1 varchar2, v2 varchar2, v3 varchar2, v4 integer) is
  select count('x') tot
  from umo um
  where umo_type || null = 'PHOTO' and
        aid + 0 = acid and
        umo_id + 0 <> v_umo and
        ORDSYS.VIRSimilar(um.signature, sig, 'globalcolor="' || v1 || '"  localcolor="' || v1 || '" texture="' || v2 || '" structure="' || v3 || '"', v4) = 1;
--         dbms_lob.getlength(um.photo_master.source.localdata) > 0 and

 -- V9
 /*
 cursor c2(v_umo integer, sig blob, acid integer, v1 varchar2, v2 varchar2, v3 varchar2, v4 integer) is
  select *
  from umo um
  where umo_type = 'PHOTO' and
        aid = acid and
        umo_id <> v_umo and
        dbms_lob.getlength(um.photo_master.source.localdata) > 0 and
        ORDSYS.IMGSimilar(sig, um.vir_signature, 'globalcolor="' || v1 || '"  localcolor="' || v1 || '" texture="' || v2 || '" structure="' || v3 || '"', v4) = 1
 order by ordsys.ordvir_pkg.score(sig, um.signature, 'globalcolor="' || v1 || '"  localcolor="' || v1 || '" texture="' || v2 || '" structure="' || v3 || '"');

 cursor c4(v_umo integer, sig blob, acid integer, v1 varchar2, v2 varchar2, v3 varchar2, v4 integer) is
  select count('x') tot
  from umo um
  where umo_type = 'PHOTO' and
        aid = acid and
        umo_id <> v_umo and
        dbms_lob.getlength(um.photo_master.source.localdata) > 0 and
        ORDSYS.IMGSimilar(sig, um.vir_signature, 'globalcolor="' || v1 || '"  localcolor="' || v1 || '" texture="' || v2 || '" structure="' || v3 || '"', v4) = 1;
 */

 c1rec		c1%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 ctr		integer;
 numb_photos	integer;
 loc_id		integer;
 x		integer;
 y		integer;
 vp1		varchar2(20);
 vp2		varchar2(20);
 vp3		varchar2(20);
 vp4		varchar2(20);
 pfx		THEME%ROWTYPE;
 result_list	UMP.SEARCH_RESULT_PHG;
 search_total	integer;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'VIRAGE.ACCEPT_VIRAGE_RUN' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 ctr := 1;
 begin numb_photos := glbx.saved_preference_value(acid, profid, ltype, 'DISPLAY_NUMBER' ); exception when others then numb_photos := NULL; end;
 if numb_photos is null
  then
   if ltype = 'PHOTOGRAPHER'
    then
     numb_photos := to_number(glbx.photo_pref(cusrec.pid,cusrec.aid,'PHOTO_DISPLAY'));
     numb_photos := nvl(numb_photos,10);
    else
     numb_photos := to_number(glbx.photo_pref(cusrec.pid,cusrec.aid,'NUMBER_PHOTOS'));
     numb_photos := nvl(numb_photos,10);
   end if;
 end if;

 if p1 is not null
  then
   loc_id := left_api_parm;
   vp1 := p1;
   vp2 := p2;
   vp3 := p3;
   vp4 := p4;
  else
   x := instr(left_api_parm,':', 1, 1);
   loc_id := substr( left_api_parm, 1, x - 1);
   y := instr(left_api_parm,':', 1, 2);
   vp1 := substr( left_api_parm, x + 1, (y-x) - 1);
   x := instr(left_api_parm,':', 1, 3);
   vp2 := substr( left_api_parm, y + 1, (x-y) - 1);
   y := instr(left_api_parm,':', 1, 4);
   vp3 := substr( left_api_parm, x + 1, (y-x) - 1);
   x := instr(left_api_parm,':', 1, 5);
   vp4 := substr( left_api_parm, y + 1, (x-y) - 1);
 end if;

 open c1(loc_id);
 fetch c1 into c1rec;
 close c1;

 if ctr < (start_from + numb_photos)
  then
   for c2rec in c2(loc_id,c1rec.signature, cusrec.aid, vp1, vp2, vp3, vp4) loop
    if ctr < start_from
     then
      null;
     else
      if ctr >= (start_from + numb_photos)
       then
        exit;
       else
        result_list(ctr) := c2rec;
      end if;
    end if;
    ctr := ctr + 1;
   end loop;
 end if;

 open c4(loc_id,c1rec.signature, cusrec.aid, vp1, vp2, vp3, vp4);
 fetch c4 into search_total;
 close c4;

 glbx.extended_search_api( surl, ltype, result_list, search_total,
                           display_detail=>display_detail, title=>'Image Content Search', help_file_code=>NULL,
                           left_api=>NULL, left_api_parm=>loc_id || ':' || vp1 || ':' || vp2 || ':' || vp3 || ':' || vp4 || ':', footer_api=>footer_api,
                           current_page_number=>start_from, no_results_message=>'No Results', acid=>acid, msg=>NULL);

exception when others then
 glbx.error_details( 'VIRAGE', 'ACCEPT_VIRAGE_RUN',cusrec.pid,owner_id,errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end accept_virage_run;

procedure virage_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1(phgid integer, acid integer) is select count('x') tot from umo um where umo_type = 'PHOTO' and dbms_lob.getlength(um.photo_master.source.localdata) > 0 and aid = acid and aid = (select aid from customer_account where aid=acid and pid=phgid);
 -- v8
 cursor c2(phgid integer, acid integer) is select count('x') tot from umo um where umo_type = 'PHOTO' and signature is null and dbms_lob.getlength(um.photo_master.source.localdata) > 0 and aid = acid and aid = (select aid from customer_account where aid=acid and pid=phgid);
 -- v9
 --cursor c2(phgid integer, acid integer) is select count('x') tot from umo um where umo_type = 'PHOTO' and um.vir_signature signature is null and dbms_lob.getlength(um.photo_master.source.localdata) > 0 and aid = acid and aid = (select aid from customer_account where aid=acid and pid=phgid);

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'VIRAGE.VIRAGE_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1(owner_id,acid);
 fetch c1 into c1rec;
 close c1;
 open c2(owner_id,acid);
 fetch c2 into c2rec;
 close c2;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, 'Manage Content Based Image Match Signatures',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( 'Manage Content Based Image Match Signatures' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'virage.accept_virage_pref' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'NVID', nvid );
 htp.formhidden( 'LOC_ID', loc_id );
 htp.formhidden( 'FIRST_PARAMETER', first_parameter );
 htp.formhidden( 'CALLED_FROM', called_from );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Number of Photos in the Account' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.bold( to_char(nvl(c1rec.tot,0)) ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Number of Photos in the Account without any Signatures' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.bold( to_char(nvl(c2rec.tot,0)) ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Perform Activity' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'P1' );
     htp.formselectoption( 'Generate Signatures for Photos without a Signature', 'SELECTED', cattributes=>'VALUE="G"' );
     htp.formselectoption( 'Generate Signatures for All Photos', cattributes=>'VALUE="A"' );
    htp.formselectclose;
    htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
     htp.formsubmit( null, 'Generate Signatures' );
    htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'VIRAGE', 'VIRAGE_PREF',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end virage_pref;

procedure accept_virage_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 )
as

 cursor c1(phgid integer, acid integer) is select * from umo um where umo_type = 'PHOTO' and dbms_lob.getlength(um.photo_master.source.localdata) > 0 and aid = acid and aid = (select aid from customer_account where aid=acid and pid=phgid);
 -- v8
 cursor c2(phgid integer, acid integer) is select * from umo um where umo_type = 'PHOTO' and signature is null and dbms_lob.getlength(um.photo_master.source.localdata) > 0 and aid = acid and aid = (select aid from customer_account where aid=acid and pid=phgid);
 -- v9
 --cursor c2(phgid integer, acid integer) is select * from umo um where umo_type = 'PHOTO' and dbms_lob.getlength(um.vir_signature.signature) = 0 and dbms_lob.getlength(um.photo_master.source.localdata) > 0 and aid = acid and aid = (select aid from customer_account where aid=acid and pid=phgid);

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr		integer;
 sts		varchar2(100);
 x		integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'VIRAGE.ACCEPT_VIRAGE_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 ctr := 1;

 if p1 = 'A'
  then

   for c1rec in c1(owner_id,acid) loop
    -- V8i Call
    ordsys.ordvir_pkg.analyze(c1rec.photo_master.source.localdata, c1rec.Signature);
    update umo um set signature = c1rec.signature where umo_id = c1rec.umo_id;

    -- V9i Call
    -- c2rec.vir_signature.generateSignature(c2rec.photo_master);
    -- update umo um set um.vir_signature = c2rec.vir_signature where umo_id = c2rec.umo_id;

    ctr := ctr + 1;
    if mod(ctr,10) = 1 then commit; end if;
   end loop;

 elsif p1 = 'G'
  then

   for c2rec in c2(owner_id,acid) loop
    -- V8i Call
    ordsys.ordvir_pkg.analyze(c2rec.photo_master.source.localdata, c2rec.Signature);
    update umo um set signature = c2rec.signature where umo_id = c2rec.umo_id;

    -- V9i Call
    -- c2rec.vir_signature.generateSignature(c2rec.photo_master);
    -- update umo um set um.vir_signature = c2rec.vir_signature where umo_id = c2rec.umo_id;

    ctr := ctr + 1;
    if mod(ctr,10) = 1 then commit; end if;
   end loop;

 end if;

 virage_pref(surl,nvid,loc_id,acid,first_parameter,called_from, ctr || '-' || 'Signature(s) Generated' );

exception when others then
 glbx.error_details( 'VIRAGE', 'ACCEPT_VIRAGE_PREF',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end accept_virage_pref;

-- Context

procedure context_run(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as


 cursor c1(v_umo integer) is select * from umo where umo_id = v_umo;

 umrec		c1%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'VIRAGE.CONTEXT_RUN' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 open c1(loc_id);
 fetch c1 into umrec;
 close c1;

 glbx.main_title( surl, 'Document Search', glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype), stype=>1, sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );

 htp.formopen( 'virage.accept_context_run' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'FOOTER_API', 'virage.accept_context_run' );
 htp.formhidden( 'LEFT_API_PARM', loc_id );
 htp.formhidden( 'START_FROM', '1' );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );

 if dbms_lob.getlength(umrec.photo_master.source.localdata) > 0
  then
   glbx.image_matte(pfx,umrec.photo_master.width,umrec.photo_master.height,
                    null,
                    '<IMG BORDER=0 WIDTH=' || umrec.photo_master.width || ' HEIGHT=' || umrec.photo_master.height || ' SRC="' ||
                   'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || cusrec.aid || '&parm1=VERSION&parm2=' || umrec.version ||
                    '" ALT="' || umrec.extras.photo_name || '" STYLE="display:block;">', null );
 end if;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0' );
  htp.tablerowopen;
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.bold( 'Search Terms' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formtext( 'P1', 40, 1000 ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formsubmit( null, 'Search' ) || htf.formclose,cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.bold( 'Help with Searching');
 htp.nl;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 htp.tablerowopen;
 htp.p( '<TD ALIGN="LEFT" VALIGN="TOP" ' || pfx.qcbground || '>' );
 htp.p('<B>Enter Search Term(s)</B><BR>
Enter search words or numbers in the box provided.<BR>
Choose All Words, Any Words, or Exact Phrase. Wildcards can be used to search on part of a word or number, or to allow for spelling.<BR>
<BR>
<BR>
All Words:<BR>
<BR>
combines terms,
<BR>
<BR>
eg: Enter Search Term gallipoli<BR>
finds all records containing the term tree - <BR>
<BR>
''the large <B>tree</b>''
<BR>
eg: Enter Search Terms tree with bark ] <BR>
finds all records containing all the terms entered, <BR>
<BR>
''  <B>tree with</b> thick <b>bark</b>''
<BR>
<BR>
Any Words:<BR>
finds records containing any term entered<BR>
<BR>
<BR>
Exact Phrase:<BR>
finds records containing only the exact phrase entered, <BR>
<BR>
eg: Enter Search Terms tall trees ] <BR>
''located in Tasmania are <b>tall trees</b>''<BR>
<BR>
<BR>
For similar words use Wild cards, % or !<BR>
Use % to find similar words or accession numbers. For example<BR>
<BR>
tree% will find records containing the words tree, trees,  etc; <BR>
04146% will find records with id numbers 041461, 041462, 041463, etc<BR>
<BR>
<BR>
Spelling<BR>
Use ! to allow for spelling. For example<BR>
<BR>
!smiith will find records containing the correct term smith;<BR>
!alright will find records containing the correct term allright<BR>
<BR>
If unsure of spelling, use the Soundex symbol (!) at the start of a word, eg<BR>
<BR>
!smith will find smythe; !alright will find allright<BR>');
htp.p( '</TD>' );
htp.tablerowclose;
htp.tableclose;

 htp.nl;

 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'VIRAGE', 'CONTEXT_RUN',cusrec.pid,owner_id,errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end context_run;

procedure accept_context_run(surl in varchar2, footer_api in varchar2 default null, left_api_parm in varchar2, start_from in integer, display_detail in char default null, acid in integer, p1 in varchar2  )
as

 cursor c2(acid integer, v1 varchar2) is
 select * from umo
 where umo_id in
 (
  select umo_id
  from umo um
  where umo_type = 'DOCUMENT' and
        aid = acid and
        contains( um.doc_body, v1, 10 )  > 0
 union
  select umo_id
  from umo um
  where
        umo_type = 'DOCUMENT' and
        aid = acid and
        exists ( select 'x' from ctx_themes ctx where ctx.query_id = um.umo_id and upper(theme) = upper(v1))
 )
  order by umo_id;

 cursor c4(acid integer, v1 varchar2) is
 select sum(tot) tot
 from
 (
  select /*+ ALL_ROWS */ count('x') tot
  from umo um
  where umo_type = 'DOCUMENT' and
        aid = acid and
        contains( um.doc_body, v1 )  > 0
 union all
  select count('x') tot
  from umo um
  where
        umo_type = 'DOCUMENT' and
        aid = acid and
        exists ( select 'x' from ctx_themes ctx where ctx.query_id = um.umo_id and upper(theme) = upper(v1))
 );

 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 ctr		integer;
 numb_photos	integer;
 loc_id		integer;
 x		integer;
 y		integer;
 vp1		varchar2(20);
 vp2		varchar2(20);
 vp3		varchar2(20);
 vp4		varchar2(20);
 pfx		THEME%ROWTYPE;
 result_list	UMP.SEARCH_RESULT_PHG;
 search_total	integer;
 step1		varchar2(100);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'VIRAGE.ACCEPT_CONTEXT_RUN', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 ctr := 1;
 begin numb_photos := glbx.saved_preference_value(acid, profid, ltype, 'DISPLAY_NUMBER' ); exception when others then numb_photos := NULL; end;
 if numb_photos is null
  then
   if ltype = 'PHOTOGRAPHER'
    then
     numb_photos := to_number(glbx.photo_pref(cusrec.pid,cusrec.aid,'PHOTO_DISPLAY'));
     numb_photos := nvl(numb_photos,10);
    else
     numb_photos := to_number(glbx.photo_pref(cusrec.pid,cusrec.aid,'NUMBER_PHOTOS'));
     numb_photos := nvl(numb_photos,10);
   end if;
 end if;

 if p1 is not null
  then
   vp1 := p1;
  else
   vp1 := left_api_parm;
 end if;
step1 := 'X:';
 if ctr < (start_from + numb_photos)
  then
step1 := 'X1:' || cusrec.aid || '-' || vp1;
   for c2rec in c2(cusrec.aid, vp1) loop
step1 := 'X2:';
    if ctr < start_from
     then
      null;
     else
      if ctr >= (start_from + numb_photos)
       then
        exit;
       else
step1 := 'X3:';
        result_list(ctr) := c2rec;
      end if;
    end if;
    ctr := ctr + 1;
   end loop;
 end if;

step1 := 'Y:';
 open c4(cusrec.aid, vp1);
 fetch c4 into search_total;
 close c4;

step1 := 'Z:';
 glbx.extended_search_api( surl, ltype, result_list, search_total,
                           display_detail=>display_detail, title=>'Document Search', help_file_code=>NULL,
                           left_api=>NULL, left_api_parm=>vp1, footer_api=>footer_api,
                           current_page_number=>start_from, no_results_message=>'No Results', acid=>acid, msg=>NULL, extra_term=>p1);

exception when others then
 glbx.error_details( 'VIRAGE', 'ACCEPT_CONTEXT_RUN',cusrec.pid,owner_id,errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id || '-' || step1);
end accept_context_run;

procedure context_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1(phgid integer, acid integer) is select count('x') tot from umo um where umo_type = 'DOCUMENT' and um.doc_length > 0 and aid = acid and aid = (select aid from customer_account where aid=acid and pid=phgid);
 cursor c2(phgid integer, acid integer) is select count('x') tot from umo um where umo_type = 'DOCUMENT' and signature is null and um.doc_length > 0 and aid = acid and aid = (select aid from customer_account where aid=acid and pid=phgid);

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'VIRAGE.CONTEXT_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1(owner_id,acid);
 fetch c1 into c1rec;
 close c1;
 open c2(owner_id,acid);
 fetch c2 into c2rec;
 close c2;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, 'Manage the Document Index',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( 'Manage the Document Index' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'virage.accept_context_pref' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'NVID', nvid );
 htp.formhidden( 'LOC_ID', loc_id );
 htp.formhidden( 'FIRST_PARAMETER', first_parameter );
 htp.formhidden( 'CALLED_FROM', called_from );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Number of Documents in the Account' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.bold( to_char(nvl(c1rec.tot,0)) ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Number of Documents in the Account that do not have an Index Entry' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.bold( to_char(nvl(c2rec.tot,0)) ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Perform Activity' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'P1' );
     htp.formselectoption( 'Generate Index Entry for Documents that have not been Indexed', 'SELECTED', cattributes=>'VALUE="G"' );
     htp.formselectoption( 'Generate Index Entry for all Documents', cattributes=>'VALUE="A"' );
    htp.formselectclose;
    htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
     htp.formsubmit( null, 'Generate Index Entry' );
    htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'VIRAGE', 'CONTEXT_PREF',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end context_pref;

procedure accept_context_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 )
as

 cursor c1(phgid integer, acid integer) is select * from umo um where umo_type = 'DOCUMENT' and um.doc_length > 0 and aid = acid and aid = (select aid from customer_account where aid=acid and pid=phgid);
 cursor c2(phgid integer, acid integer) is select * from umo um where umo_type = 'DOCUMENT' and signature is null and um.doc_length > 0 and aid = acid and aid = (select aid from customer_account where aid=acid and pid=phgid);

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr		integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'VIRAGE.ACCEPT_CONTEXT_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 ctr := 1;

 if p1 = 'A'
  then

   execute immediate 'ALTER INDEX I_UMO_CTX rebuild PARAMETERS(''sync memory 10M'')';
   for c1rec in c1(owner_id,acid) loop
    -- Generate Document Data
    CTX_DOC.FILTER('I_UMO_CTX',to_char(c1rec.umo_id),'filtertab', c1rec.umo_id, FALSE);
    CTX_DOC.GIST('I_UMO_CTX',to_char(c1rec.umo_id),'ctx_gist', c1rec.umo_id,glevel => 'S',numparagraphs=>1,pov=>'GENERIC',maxpercent=>1);
    CTX_DOC.THEMES('I_UMO_CTX',to_char(c1rec.umo_id),'ctx_themes',c1rec.umo_id,full_themes => FALSE);
    -- Copy back to the UMO table the GIST and FILTER
    move_context_data( c1rec.umo_id );
    update umo um set signature = utl_raw.cast_to_raw( 'GENERATED' ) where umo_id = c1rec.umo_id;
    ctr := ctr + 1;
    if mod(ctr,10) = 1 then commit; end if;
   end loop;

 elsif p1 = 'G'
  then

   execute immediate 'ALTER INDEX I_UMO_CTX rebuild PARAMETERS(''sync memory 10M'')';
   for c2rec in c2(owner_id,acid) loop
    -- Generate Document Data
    CTX_DOC.FILTER('I_UMO_CTX',to_char(c2rec.umo_id),'filtertab', c2rec.umo_id, FALSE);
    CTX_DOC.GIST('I_UMO_CTX',to_char(c2rec.umo_id),'ctx_gist', c2rec.umo_id, glevel => 'P', numparagraphs=>2, pov=>'GENERIC', maxpercent=>10);
    CTX_DOC.THEMES('I_UMO_CTX',to_char(c2rec.umo_id),'ctx_themes',c2rec.umo_id,full_themes => FALSE);
    -- Copy back to the UMO table the GIST and FILTER
    move_context_data( c2rec.umo_id );
    update umo um set signature = utl_raw.cast_to_raw( 'GENERATED' ) where umo_id = c2rec.umo_id;
    ctr := ctr + 1;
    if mod(ctr,10) = 1 then commit; end if;
   end loop;

 end if;

 context_pref(surl,nvid,loc_id,acid,first_parameter,called_from, ctr || '-' || 'Index Entry(s) Generated' );

exception when others then
 glbx.error_details( 'VIRAGE', 'ACCEPT_CONTEXT_PREF',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end accept_context_pref;

procedure move_context_data(v_umo in integer)
as

 cursor c1(v_umo integer) is select * from umo where umo_id = v_umo for update nowait;
 cursor c2(v_umo integer) is select gist from ctx_gist where query_id = v_umo;
 cursor c3(v_umo integer) is select document from filtertab where query_id = v_umo;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 objlength	integer;

begin
 update umo set doc_gist = empty_clob(), doc_html = empty_clob where umo_id = v_umo;
 commit;

 open c1(v_umo);
 fetch c1 into c1rec;
 close c1;

 open c2(v_umo);
 fetch c2 into c2rec;
 close c2;
 objlength := dbms_lob.getlength(c2rec.gist);
 dbms_lob.copy(c1rec.doc_gist,c2rec.gist,objlength);
 delete from ctx_gist where query_id = v_umo;

 open c3(v_umo);
 fetch c3 into c3rec;
 close c3;
 objlength := dbms_lob.getlength(c3rec.document);
 dbms_lob.copy(c1rec.doc_html,c3rec.document,objlength);
 delete from filtertab where query_id = v_umo;
 commit;

exception when others then
 glbx.error_details( 'VIRAGE', 'MOVE_CONTEXT_DATA',null,c1rec.aid,errmsg=>sqlerrm,extdet=>'V_UMO:' || v_umo);
end move_context_data;

function virage_index( surl in varchar2, acid in integer )
 return boolean
as

 cursor c2(acid integer) is
  select *
  from umo um
  where umo_type = 'PHOTO' and
        um.signature is null and
        dbms_lob.getlength(um.photo_master.source.localdata) > 10000 and
        aid = acid;

 cursor c3(v_umo integer) is select * from umo where umo_id = v_umo for update;

 c3rec		c3%ROWTYPE;
 ctr		integer;

begin

 ctr := 1;
 for c2rec in c2(acid) loop
  begin
    ordsys.ordvir_pkg.analyze(c2rec.photo_master.source.localdata, c2rec.Signature);
    update umo um set signature = c2rec.signature where umo_id = c2rec.umo_id;
   ctr := ctr + 1; commit;
   if mod(ctr,10) = 1 then commit; end if;
  exception when others then null;
  end;
 end loop;
 commit;
 return( TRUE );
exception when others then
 glbx.error_details( 'ADM', 'VIRAGE_INDEX', acid, errmsg=>sqlerrm);
 return( FALSE );
end virage_index;

function context_index(surl in varchar2, acid in integer )
 return boolean
as

 cursor c2(acid integer) is
  select *
  from umo um
  where umo_type = 'DOCUMENT' and
        um.signature is null and
        um.doc_length > 0 and
        aid = acid;

 ctr		integer;

begin
 ctr := 1;

 execute immediate 'ALTER INDEX I_UMO_CTX rebuild PARAMETERS(''sync memory 10M'')';
 for c2rec in c2(acid) loop
  -- Generate Document Data
  CTX_DOC.FILTER('I_UMO_CTX',to_char(c2rec.umo_id),'filtertab', c2rec.umo_id, FALSE);
  CTX_DOC.GIST('I_UMO_CTX',to_char(c2rec.umo_id),'ctx_gist', c2rec.umo_id, glevel => 'P', numparagraphs=>2, pov=>'GENERIC', maxpercent=>10);
  CTX_DOC.THEMES('I_UMO_CTX',to_char(c2rec.umo_id),'ctx_themes',c2rec.umo_id,full_themes => FALSE);
  -- Copy back to the UMO table the GIST and FILTER
  move_context_data( c2rec.umo_id );
  update umo um set signature = utl_raw.cast_to_raw( 'GENERATED' ) where umo_id = c2rec.umo_id;
  ctr := ctr + 1;
  if mod(ctr,10) = 1 then commit; end if;
 end loop;

 commit;
 return( TRUE );
exception when others then
 glbx.error_details( 'ADM', 'CONTEXT_INDEX',acid,errmsg=>sqlerrm);
 return( FALSE );
end context_index;

end virage;

/
