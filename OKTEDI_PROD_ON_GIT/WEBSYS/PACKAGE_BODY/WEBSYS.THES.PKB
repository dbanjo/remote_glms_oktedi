CREATE OR REPLACE package body WEBSYS.thes
as

function validate_thesaurus( thesid in integer ) return boolean;
procedure thesaurus_column( surl in varchar2, thesid in integer, acid in integer, term_list in THES.LIST_OF_TERMS, start_from in integer, maxterm in integer, search_term in varchar2, totterms in integer );
procedure thesaurus_footer( surl in varchar2, ltype in varchar2, thesid in integer, search_total in integer, start_from in integer, numb_photos in integer, footer_api in varchar2, acid in integer, pfx in THEME%ROWTYPE, search_term in varchar2, totterms in integer );
procedure thesaurus_alphabet( surl in varchar2, thes in THESAURUS%ROWTYPE, acid in integer, incsearch in boolean default TRUE );
procedure generate_start_alphabet( thesid in integer default 1 );
procedure generate_start_terms( thesid in integer default 1 );
procedure loadthes( thesid in integer, fdir in varchar2, fname in varchar2, retval in out varchar2 );
procedure thes_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure thes_run(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure extract_priv(c1rec in customer_account%ROWTYPE, ltype in varchar2, profid in integer, s_ins in out boolean, s_upd in out boolean, s_del in out boolean, s_pub in out boolean, s_priv in out boolean );

procedure xml_mimeheader( mimetype in varchar2 default 'text/xml', version in varchar2 default '1.0', encoding in varchar2 default 'UTF-8' );
procedure xml_error( errorcode in varchar2, errm in varchar2 );
procedure xml_properties( thesid in integer );
procedure xml_extended( thesid in integer, termid in integer, nested_level in integer default 1 );
procedure xml_term( thesid in integer, termid in integer, nested_level in integer default 1 );
procedure xml_term_description( thesid in integer, termid in integer, nested_level in integer default 1 );
procedure xml_list( thesid in integer, nested_level in integer default 1, termid_list in GLBX.MYARRAY, termid_display in GLBX.MYARRAY );
procedure xml_response_open( thesid in integer );
procedure xml_response_close( thesid in integer );
procedure xml_hierarchy_open( thesid in integer, direction in varchar2, nested_level in number );
procedure xml_hierarchy_close( thesid in integer, direction in varchar2, nested_level in number );
procedure xml_node( thesid in integer, direction in varchar2, nested_level in number, parent_term in integer );

procedure main(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api in varchar2 default null, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as
begin

 if called_from = 'MAIN'
  then
   thes_run(surl,nvid,loc_id,footer_api,left_api_parm,left_api,current_page_number,display_detail,acid,first_parameter,called_from );

 elsif called_from = 'PREFERENCES'
  then
   thes_pref(surl,nvid,loc_id,acid,first_parameter,called_from );

 else
   thes_run(surl,nvid,loc_id,footer_api,left_api_parm,left_api,current_page_number,display_detail,acid,first_parameter,called_from );

 end if;

exception when others then
 glbx.error_details( 'VIRAGE', 'MAIN',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end main;

procedure thes_run(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
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

 list_available(surl, 'TABLE', NULL, acid );

exception when others then
 glbx.error_details( 'THES', 'THES_RUN',cusrec.pid,owner_id,errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end thes_run;

procedure list_available(surl in varchar2, disptype in varchar2 default 'TABLE', disp_parm in varchar2 default null, acid in integer default null )
 as

 cursor c2(phgid integer) is
  select name,thes_id, purpose
  from thesaurus
  where public_private = 'PUBLIC'
 union
  select name,thes_id, purpose
  from thesaurus
  where public_private = 'PRIVATE' and
        private_pid = phgid
  order by 1;

 cursor c3(phgid integer) is
  select count('x') tot
  from
  (
   select name,thes_id
   from thesaurus
   where public_private = 'PUBLIC'
    union
   select name,thes_id
   from thesaurus
   where public_private = 'PRIVATE' and
         private_pid = phgid
  );

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 profid		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin

glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'THES.LIST_AVAILABLE' );
if sts is not null
 then
  glbx.redisplay_login_page( sts );
  return;
end if;

c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
pfx := glbx.get_thm( c1rec.theme_name );

open c3(c1rec.pid);
fetch c3 into c3rec;
close c3;
if nvl(c3rec.tot,0) = 1
 then
  open c2(c1rec.pid);
  fetch c2 into c2rec;
  close c2;
  thes.start_thesaurus(surl,c2rec.thes_id,acid);
  return;
end if;

glbx.main_title( surl, 'Choose a Thesaurus to View and Search',glbx.backimg(surl,owner_id,pfx.text_back,c1rec.background_img,ltype),helpid=>'H01',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
htp.p( '<CENTER>' );
htp.nl;
if disptype = 'TABLE'
 then
  htp.tableopen(cattributes=>disp_parm);
elsif disptype = 'ULIST'
 then
  htp.ulistopen(cattributes=>disp_parm);
elsif disptype = 'DLIST'
 then
  htp.dlistopen(cattributes=>disp_parm);
elsif disptype = 'OLIST'
 then
  htp.olistopen(cattributes=>disp_parm);
end if;

for c2rec in c2(c1rec.pid) loop
 if disptype = 'TABLE'
  then
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'thes.start_thesaurus?surl=' || surl || '&thesid=' || c2rec.thes_id || '&acid=' || acid, c2rec.name ),cattributes=>pfx.qcbground);
    htp.tabledata( nvl( c2rec.purpose, '&nbsp;'),cattributes=>pfx.qcbground);
   htp.tablerowclose;
 elsif disptype in ('ULIST','DLIST','OLIST')
  then
   htp.listitem( htf.anchor( 'thes.start_thesaurus?surl=' || surl || '&thesid=' || c2rec.thes_id || '&acid=' || acid, c2rec.name ) );
 end if;

end loop;

if disptype = 'TABLE'
 then
  htp.tableclose;
elsif disptype = 'ULIST'
 then
  htp.ulistclose;
elsif disptype = 'DLIST'
 then
  htp.dlistclose;
elsif disptype = 'OLIST'
 then
  htp.olistclose;
end if;

exception when others then
 glbx.error_details( 'THES', 'LIST_AVAILABLE',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'DISPTYPE:' || disptype);
end list_available;

procedure start_thesaurus(surl in varchar2, thesid in integer, acid in integer )
as

 cursor c2(thesid integer) is
  select *
  from thesaurus
  where thes_id = thesid;

cursor c3(thesid integer) is
  select tt.term_name,tt.term_id
  from thesaurus_start_terms tst, thesaurus_term tt
  where tst.thes_id = thesid and
        tst.term_id = tt.term_id and
        tt.thes_id = tst.thes_id
  order by term_name;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 profid		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 sterms		THES.LIST_OF_TERMS;

begin

glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'THES.START_THESAURUS' );
if sts is not null
 then
  glbx.redisplay_login_page( sts );
  return;
end if;

c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
pfx := glbx.get_thm( c1rec.theme_name );

open c2(thesid);
fetch c2 into c2rec;
close c2;
-- Check if allowed to access this Thesaurus
if c2rec.thes_id is null or
   (c2rec.public_private = 'PRIVATE' and c2rec.private_pid <> c1rec.pid)
 then
  htp.bold( 'Access not Allowed' );
  return;
end if;

-- Show Start Terms
for c3rec in c3(thesid) loop
 sterms(c3%ROWCOUNT).term_id := c3rec.term_id;
 sterms(c3%ROWCOUNT).term_name := c3rec.term_name;
end loop;

if c2rec.display_style = 'COLUMN'
 then
  thesaurus_column(surl,thesid,acid,sterms,1,sterms.count, null, sterms.count);
elsif c2rec.display_style = 'HIERARCHICAL'
 then
  null;
elsif c2rec.display_style = 'EXTERNAL'
 then
  null;
end if;

exception when others then
 glbx.error_details( 'THES', 'START_THESAURUS',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'THESID:' || thesid);
end start_thesaurus;

procedure thesaurus_column( surl in varchar2, thesid in integer, acid in integer, term_list in THES.LIST_OF_TERMS, start_from in integer, maxterm in integer, search_term in varchar2, totterms in integer )
as

 cursor c2( thesid integer ) is select * from thesaurus where thes_id = thesid;

 cursor c3( thesid integer, trmid integer, trm_type varchar2 ) is
  select tt.term_name, tt.term_id
  from thesaurus_term tt, thesaurus_relationship ttr
  where ttr.related_term_id = tt.term_id and
        tt.thes_id = thesid and
        ttr.relationship_type = trm_type and
        ttr.term_id = trmid
  order by tt.term_name;

 cursor c4( thesid integer, trmid integer, trm_type varchar2 ) is
  select tt.term_name, tt.term_id
  from thesaurus_term tt, thesaurus_relationship ttr
  where ttr.term_id = tt.term_id and
        tt.thes_id = thesid and
        ttr.relationship_type = trm_type and
        ttr.related_term_id = trmid
  order by tt.term_name;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 profid		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 foundrec	boolean;
 pfx		THEME%ROWTYPE;

begin

glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'THES.THESAURUS_COLUMN' );
if sts is not null
 then
  glbx.redisplay_login_page( sts );
  return;
end if;

c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
pfx := glbx.get_thm( c1rec.theme_name );

open c2(thesid);
fetch c2 into c2rec;
close c2;

glbx.main_title( surl, c2rec.name,glbx.backimg(surl,owner_id,pfx.text_back,c1rec.background_img,ltype),helpid=>'H01',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
htp.p( '<CENTER>' );
thesaurus_alphabet(surl,c2rec,acid,TRUE);

if term_list.count > 0
 then
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_490 ), cattributes=>pfx.qbground );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_491 ), cattributes=>pfx.qbground );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_492 ), cattributes=>pfx.qbground );
   htp.tablerowclose;

  for j in term_list.first..term_list.last loop
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || ' VALIGN="TOP">');
   foundrec := FALSE;
   for c3rec in c3(thesid,term_list(j).term_id,'BT') loop
    if c3%ROWCOUNT > 1
     then
      htp.nl;
      foundrec := TRUE;
    end if;
    htp.anchor( 'thes.term_search?surl=' || surl || '&thesid=' || thesid || '&bttermid=' || c3rec.term_id || '&acid=' || acid, c3rec.term_name);
   end loop;
   if not foundrec then htp.p( '&nbsp;' ); end if;
   htp.p( '</TD>' );

   htp.p( '<TD ' || pfx.qcbground || ' VALIGN="TOP">' );
   htp.anchor( 'thes.term_umo?surl=' || surl || '&left_api_parm=' || '[' || thesid || ']' || term_list(j).term_id || '&acid=' || acid, htf.img( DECS.IMAGE_LOCATION || 'adminc/list.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_511 ));
   htp.anchor( 'thes.term_details?surl=' || surl || '&thesid=' || thesid || '&termid=' || term_list(j).term_id || '&acid=' || acid, htf.bold(term_list(j).term_name));
   for c3rec in c3(thesid,term_list(j).term_id,'USE') loop
    htp.nl;
    htp.anchor( 'thes.term_details?surl=' || surl || '&thesid=' || thesid || '&termid=' || c3rec.term_id || '&acid=' || acid, LNG4.AHC_TXT_493 || ':' || c3rec.term_name);
   end loop;
   htp.p( '</TD>' );

   htp.p( '<TD ' || pfx.qcbground || ' VALIGN="TOP">' );
   foundrec := FALSE;
   for c4rec in c4(thesid,term_list(j).term_id,'BT') loop
    if c4%ROWCOUNT > 1
     then
      htp.nl;
      foundrec := TRUE;
    end if;
    htp.anchor( 'thes.term_search?surl=' || surl || '&thesid=' || thesid || '&bttermid=' || c4rec.term_id || '&acid=' || acid, c4rec.term_name);
   end loop;
   if not foundrec then htp.p( '&nbsp;' ); end if;
   htp.p( '</TD>' );

   htp.tablerowclose;

  end loop;
  htp.tableclose;

end if;
thesaurus_footer( surl, ltype, thesid, maxterm, start_from, c2rec.max_display_rows, 'thes.term_search', acid, pfx, search_term, totterms );
exception when others then
 glbx.error_details( 'THES', 'THESAURUS_COLUMN',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'THESID:' || thesid);
end thesaurus_column;

procedure thesaurus_footer( surl in varchar2, ltype in varchar2, thesid in integer, search_total in integer, start_from in integer, numb_photos in integer, footer_api in varchar2, acid in integer, pfx in THEME%ROWTYPE, search_term in varchar2, totterms in integer )
as

 x1	integer;
 x2	integer;

begin
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.anchor('thes.start_thesaurus?surl=' || surl || '&thesid=' || thesid || '&acid=' || acid,LNG4.AHC_TXT_494) );
   htp.tabledata( ' | ' );
   htp.tabledata( htf.anchor('thes.advanced_search?surl=' || surl || '&thesid=' || thesid || '&acid=' || acid,LNG2.FNM_TXT_139) );
  htp.tablerowclose;
 htp.tableclose;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0 align="CENTER"' );
  htp.tablerowopen;
   htp.p( '<TD ALIGN="CENTER" VALIGN="TOP" CLASS="SMALL">');
    x1 := 1;
    x2 := trunc(totterms/numb_photos) + 1;

    for j in x1..x2 loop
     if start_from = ((j-1)*numb_photos) + 1
      then
        htp.p( to_char(j) );
        if j < x2 then htp.p( ' ' || pfx.page_delim || ' ' ); end if;
      else
        htp.anchor( footer_api || '?surl=' || glbx.rndsurl(surl) || '&thesid=' || thesid ||
                     '&start_from=' || to_char(((j-1)*numb_photos) + 1) || '&acid=' || acid || '&search_term=' || replace(search_term,' ','+'),
                     to_char(j),cattributes=>'CLASS="SMALL"');
        if j < x2 then htp.p( ' ' || pfx.page_delim || ' ' ); end if;
     end if;
    end loop;

    if ((trunc(x2/10) + 1) * 10) < trunc(totterms/numb_photos)+1
     then
        htp.anchor( footer_api || '?surl=' || glbx.rndsurl(surl) || '&thesid=' || thesid ||
                     '&start_from=' || to_char(least(((x2+9)*numb_photos) + 1,totterms-numb_photos)) || '&acid=' || acid || '&search_term=' || replace(search_term,' ','+'),
                     ' ' || LNG.SLD_TXT_087 || '&gt;');
        htp.p( ' / ' || to_char(trunc(totterms/numb_photos)+1) );
        htp.p( '</TD>' );
        htp.p( '<TD ALIGN="CENTER" VALIGN="TOP" CLASS="SMALL">');
        htp.formopen( 'thes.goto_page',cattributes=>'CLASS="SMALL"' );
        htp.formhidden( 'SURL', glbx.rndsurl(surl) );
        htp.formhidden( 'FOOTER_API', footer_api );
        htp.formhidden( 'ACID', acid );
        htp.formhidden( 'THESID', thesid );
        htp.formhidden( 'SEARCH_TOTAL', totterms );
        htp.formhidden( 'START_FROM', start_from );
        htp.formtext( 'PAGE', 5, 5 );
        htp.formsubmit( null, LNG4.AHC_TXT_426 );
        htp.formclose;
    end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
end thesaurus_footer;

procedure goto_page( surl in varchar2, footer_api in varchar2, thesid in integer, search_total in integer, acid in integer, start_from in integer, page in varchar2 )
as

 cursor c2( thesid integer ) is select * from thesaurus where thes_id = thesid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 numb_photos	integer;
 profid		integer;

begin

 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'THES.GOTO_PAGE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );

 open c2(thesid);
 fetch c2 into c2rec;
 close c2;
 numb_photos := c2rec.max_display_rows;

 begin nmb := abs(to_number(page)); exception when others then nmb := NULL; end;
 if nmb = 0 then nmb := null; end if;

 nmb := numb_photos * nmb;
 if nmb > search_total then nmb := search_total; end if;
 if nmb is null then nmb := start_from; end if;

 execute immediate
   'begin ' || footer_api ||
    '(surl=>:surl,thesid=>:thesid,start_from=>:start_from,acid=>:acid);' ||
    'end;'
  using glbx.rndsurl(surl),thesid,nmb,acid;

exception when others then
 glbx.error_details( 'THES', 'GOTO_PAGE',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'page: ' || page || ' footer_api:' || footer_api || ' thesid:' || thesid );
end goto_page;

procedure thesaurus_alphabet( surl in varchar2, thes in THESAURUS%ROWTYPE, acid in integer, incsearch in boolean default TRUE )
as
begin
 if thes.start_alphabet is null then return; end if;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.p( '<TD>' );
   for j in 1..length(thes.start_alphabet) loop
    if j > 1
     then
      htp.p( ' | ' || htf.anchor( 'thes.term_search?surl=' || surl || '&thesid=' || thes.thes_id || '&search_term=' || substr(thes.start_alphabet,j,1) || '&acid=' || acid,substr(thes.start_alphabet,j,1)) );
     else
      htp.p( htf.anchor( 'thes.term_search?surl=' || surl || '&thesid=' || thes.thes_id || '&search_term=' || substr(thes.start_alphabet,j,1) || '&acid=' || acid,substr(thes.start_alphabet,j,1)) );
    end if;
   end loop;
   htp.p( '</TD>' );
   if incsearch
    then
     htp.p( '<TD>' );
     htp.p( LNG.GLB_TXT_092 );
     htp.p( '</TD>' );
     htp.p( '<TD valign="MIDDLE" ALIGN="CENTER">' );
     htp.formopen( 'thes.term_search' );
     htp.formhidden( 'SURL', surl );
     htp.formhidden( 'THESID', thes.thes_id );
     htp.formhidden( 'ACID', acid );
     htp.formtext( 'SEARCH_TERM', 10, 100 );
     htp.formclose;
     htp.p( '</TD>' );
   end if;
  htp.tablerowclose;
 htp.tableclose;
end thesaurus_alphabet;

procedure extract_priv(c1rec in customer_account%ROWTYPE, ltype in varchar2, profid in integer, s_ins in out boolean, s_upd in out boolean, s_del in out boolean, s_pub in out boolean, s_priv in out boolean )
as
begin
 -- Extract Privs
 s_ins := TRUE;
 s_upd := TRUE;
 s_del := TRUE;
 s_pub := TRUE;
 s_priv := TRUE;

end extract_priv;

procedure term_details( surl in varchar2, thesid in integer, termid in integer, acid in integer default null )
as

 cursor c2( thesid integer ) is select * from thesaurus where thes_id = thesid;

 cursor c3( termid integer ) is select * from thesaurus_term where term_id = termid;

 cursor c4( thesid integer, termid integer, trm_type varchar2 ) is
  select tt.term_name, tt.term_id
  from thesaurus_term tt, thesaurus_relationship ttr
  where ttr.related_term_id = tt.term_id and
        tt.thes_id = thesid and
        ttr.relationship_type = trm_type and
        ttr.term_id = termid
  order by tt.term_name;

 -- cursor c5( termid integer) is select count('x') from thesaurus_term_umo where term_id = termid;

 cursor c6( termid integer, ntype varchar2) is select count('x') from thesaurus_term_note where term_id = termid and note_type = ntype;

 cursor c7( termid integer, ntype varchar2) is select note from thesaurus_term_note where term_id = termid and note_type = ntype;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ctr		integer;
 profid		integer;
 tot		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 tmp		varchar2(32767);
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 s_ins		boolean;
 s_upd		boolean;
 s_del		boolean;
 s_pub		boolean;
 s_priv		boolean;

begin

 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'THES.TERM_DETAILS' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( c1rec.theme_name );

 extract_priv(c1rec, ltype, profid, s_ins, s_upd, s_del, s_pub, s_priv );

 open c2(thesid);
 fetch c2 into c2rec;
 close c2;

 open c3(termid);
 fetch c3 into c3rec;
 close c3;

glbx.main_title( surl, c2rec.name,glbx.backimg(surl,owner_id,pfx.text_back,c1rec.background_img,ltype),helpid=>'H02',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
htp.p( '<CENTER>' );
thesaurus_alphabet(surl,c2rec,acid,TRUE);

htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 htp.tablerowopen;
    htp.tabledata( LNG4.AHC_TXT_495 || ':', cattributes=>'align="RIGHT"' );
    htp.tabledata( c3rec.term_name );
 htp.tablerowclose;
 htp.tablerowopen;
    htp.tabledata( LNG4.AHC_TXT_496 || ':', cattributes=>'align="RIGHT"' );
    htp.tabledata( c3rec.tracking_name );
 htp.tablerowclose;
 htp.tablerowopen;
    htp.tabledata( LNG4.AHC_TXT_497 || ':', cattributes=>'align="RIGHT"' );
    if c3rec.term_type = 'PT'
     then
      htp.tabledata( c3rec.term_type || ' (' || LNG4.AHC_TXT_498 || ')' );
    elsif c3rec.term_type = 'ND'
     then
      htp.tabledata( c3rec.term_type || ' (' || LNG4.AHC_TXT_499 || ')' );
    else
     htp.tabledata( c3rec.term_type );
    end if;
 htp.tablerowclose;
 htp.tablerowopen;
    htp.tabledata( LNG4.AHC_TXT_500 || ':', cattributes=>'align="RIGHT"' );
    htp.tabledata( nvl(c3rec.notes,'-') );
 htp.tablerowclose;
 htp.tablerowopen;
    htp.tabledata( LNG.GLB_TXT_078 || ':', cattributes=>'align="RIGHT"' );
    htp.tabledata( nvl(to_char(c3rec.date_created,LNG.MASK),'-') );
 htp.tablerowclose;
 htp.tablerowopen;
    htp.tabledata( LNG4.AHC_TXT_501 || ':', cattributes=>'align="RIGHT"' );
    htp.tabledata( nvl(to_char(c3rec.date_updated,LNG.MASK),'-') );
 htp.tablerowclose;
htp.tableclose;

htp.nl;
htp.bold( LNG4.AHC_TXT_502 );
htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 -- Use For
 tmp := NULL;
 for c4rec in c4(thesid,termid,'UF') loop
  if c4%ROWCOUNT > 1 then tmp := tmp || htf.nl; end if;
  tmp := tmp || htf.anchor( 'thes.term_details?surl=' || surl || '&thesid=' || thesid || '&termid=' || c4rec.term_id || '&acid=' || acid, c4rec.term_name );
 end loop;
 if tmp is not null
  then
   htp.tablerowopen;
    htp.tabledata( htf.italic( LNG4.AHC_TXT_503 || ':' ), cattributes=>'align="RIGHT" valign="TOP"' );
    htp.tabledata( tmp );
   htp.tablerowclose;
 end if;

 -- Narrower Terms
 tmp := NULL;
 for c4rec in c4(thesid,termid,'NT') loop
  if c4%ROWCOUNT > 1 then tmp := tmp || htf.nl; end if;
  tmp := tmp || htf.anchor( 'thes.term_details?surl=' || surl || '&thesid=' || thesid || '&termid=' || c4rec.term_id || '&acid=' || acid, c4rec.term_name );
 end loop;
 if tmp is not null
  then
   htp.tablerowopen;
    htp.tabledata( htf.italic( LNG4.AHC_TXT_492 || ':' ), cattributes=>'align="RIGHT" valign="TOP"' );
    htp.tabledata( tmp );
   htp.tablerowclose;
 end if;

 -- Broader Terms
 tmp := NULL;
 for c4rec in c4(thesid,termid,'BT') loop
  if c4%ROWCOUNT > 1 then tmp := tmp || htf.nl; end if;
  tmp := tmp || htf.anchor( 'thes.term_details?surl=' || surl || '&thesid=' || thesid || '&termid=' || c4rec.term_id || '&acid=' || acid, c4rec.term_name );
 end loop;
 if tmp is not null
  then
   htp.tablerowopen;
    htp.tabledata( htf.italic( LNG4.AHC_TXT_490 || ':' ), cattributes=>'align="RIGHT" valign="TOP"' );
    htp.tabledata( tmp );
   htp.tablerowclose;
 end if;

 -- Related Terms
 tmp := NULL;
 for c4rec in c4(thesid,termid,'RT') loop
  if c4%ROWCOUNT > 1 then tmp := tmp || htf.nl; end if;
  tmp := tmp || htf.anchor( 'thes.term_details?surl=' || surl || '&thesid=' || thesid || '&termid=' || c4rec.term_id || '&acid=' || acid, c4rec.term_name );
 end loop;
 if tmp is not null
  then
   htp.tablerowopen;
    htp.tabledata( htf.italic( LNG4.AHC_TXT_506 || ':' ), cattributes=>'align="RIGHT" valign="TOP"' );
    htp.tabledata( tmp );
   htp.tablerowclose;
 end if;
htp.tableclose;

tot := 0;
open c6(termid,'HISTORICAL');
fetch c6 into tot;
close c6;
if tot > 0
 then
  htp.nl;
  htp.bold( LNG4.AHC_TXT_507 );
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  for c7rec in c7(termid,'HISTORICAL') loop
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_508 || ':' || c7%ROWCOUNT) );
    htp.tabledata( c7rec.note );
   htp.tablerowclose;
  end loop;
  htp.tableclose;
end if;

tot := 0;
open c6(termid,'SEARCH');
fetch c6 into tot;
close c6;
if tot > 0
 then
  htp.nl;
  htp.bold( LNG4.AHC_TXT_509 );
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  for c7rec in c7(termid,'SEARCH') loop
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_508 || ':' || c7%ROWCOUNT) );
    htp.tabledata( c7rec.note );
   htp.tablerowclose;
  end loop;
  htp.tableclose;
end if;

tot := 0;
--open c5(termid);
--fetch c5 into tot;
--close c5;
--if tot > 0
-- then
  htp.nl;
  htp.bold( LNG4.AHC_TXT_510 );
  htp.nl;
  htp.anchor( 'thes.term_umo?surl=' || surl || '&left_api_parm=' || '[' || thesid || ']' || termid || '&acid=' || acid, htf.img( DECS.IMAGE_LOCATION || 'adminc/list.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_511 ));
-- end if;

htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 htp.tablerowopen;
 if s_ins then htp.tabledata( htf.anchor( 'thes.term_manager?surl=' || surl || '&thesid=' || thesid || '&termid=' || termid || '&acid=' || acid ||'&cmd=INS', '[' || 'Insert' || ']' )); end if;
 if s_upd then htp.tabledata( htf.anchor( 'thes.term_manager?surl=' || surl || '&thesid=' || thesid || '&termid=' || termid || '&acid=' || acid ||'&cmd=UPD', '[' || 'Update' || ']' )); end if;
 if s_del then htp.tabledata( htf.anchor( 'thes.term_manager?surl=' || surl || '&thesid=' || thesid || '&termid=' || termid || '&acid=' || acid ||'&cmd=DEL', '[' || 'Delete' || ']' )); end if;
 if s_pub then htp.tabledata( htf.anchor( 'thes.term_manager?surl=' || surl || '&thesid=' || thesid || '&termid=' || termid || '&acid=' || acid ||'&cmd=PUB', '[' || 'Attach Public Images' || ']' )); end if;
 if s_priv then htp.tabledata( htf.anchor( 'thes.term_manager?surl=' || surl || '&thesid=' || thesid || '&termid=' || termid || '&acid=' || acid ||'&cmd=PRIV', '[' || 'Attach Private Images' || ']' )); end if;
 htp.tablerowclose;
htp.tableclose;

htp.p( '</CENTER>' );
htp.htmlclose;
exception when others then
 glbx.error_details( 'THES', 'TERM_DETAILS',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'thesid=' || thesid || '&termid=' || termid );
end term_details;

procedure advanced_search( surl in varchar2, thesid in integer, acid in integer )
as

 cursor c2( thesid integer ) is select * from thesaurus where thes_id = thesid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 profid		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 foundrec	boolean;
 pfx		THEME%ROWTYPE;

begin

glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'THES.ADVANCED_SEARCH' );
if sts is not null
 then
  glbx.redisplay_login_page( sts );
  return;
end if;

c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
pfx := glbx.get_thm( c1rec.theme_name );

open c2(thesid);
fetch c2 into c2rec;
close c2;

glbx.main_title( surl, c2rec.name,glbx.backimg(surl,owner_id,pfx.text_back,c1rec.background_img,ltype),helpid=>'H03',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
htp.p( '<CENTER>' );
thesaurus_alphabet(surl,c2rec,acid,TRUE);
htp.bold( LNG2.FNM_TXT_139 );
htp.nl;
htp.formopen( 'thes.accept_advanced_search' );
htp.formhidden( 'SURL', surl );
htp.formhidden( 'THESID', thesid );
htp.formhidden( 'ACID', acid );
htp.tableopen;
 htp.tablerowopen;
  htp.tabledata( LNG4.AHC_TXT_495 );
  htp.p( '<TD>' );
   htp.formselectopen( 'P1' );
   htp.formselectoption( LNG.PHG_TXT_505, 'SELECTED' );
   htp.formselectoption( LNG.PHG_TXT_506 );
   htp.formselectoption( LNG.PHG_TXT_508 );
   htp.formselectoption( LNG.PHG_TXT_507 );
   htp.formselectclose;
  htp.p( '</TD>' );
  htp.tabledata( htf.formtext( 'P2', 30, 100 ) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( LNG4.AHC_TXT_512 );
  htp.p( '<TD>' );
   htp.formselectopen( 'P3' );
   htp.formselectoption( LNG.PHG_TXT_505, 'SELECTED' );
   htp.formselectoption( LNG.PHG_TXT_506 );
   htp.formselectoption( LNG.PHG_TXT_508 );
   htp.formselectoption( LNG.PHG_TXT_507 );
   htp.formselectclose;
  htp.p( '</TD>' );
  htp.tabledata( htf.formtext( 'P4', 30, 100 ) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( LNG4.AHC_TXT_513 );
  htp.tabledata( '&nbsp;' );
  htp.tabledata( htf.formtext( 'P5', 30, 100 ) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( LNG4.AHC_TXT_514 );
  htp.tabledata( htf.italic( LNG.MASK ) );
  htp.tabledata( htf.formtext( 'P6', 30, 100 ) );
 htp.tablerowclose;
htp.tableclose;
htp.nl;
htp.formsubmit( null, LNG.PHG_TXT_512 );
htp.formclose;
htp.htmlclose;
exception when others then
 glbx.error_details( 'THES', 'ADVANCED_SEARCH',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'thesid=' || thesid );
end advanced_search;

procedure accept_advanced_search( surl in varchar2, thesid in integer, acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2 )
as

 cursor c2( thesid integer ) is select * from thesaurus where thes_id = thesid;

 TYPE DynCurs IS REF CURSOR;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 profid		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 sqlstmt	varchar2(32767);
 DCurs		DynCurs;
 ctr		integer;
 sterms		THES.LIST_OF_TERMS;

begin

glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'THES.ADVANCED_SEARCH' );
if sts is not null
 then
  glbx.redisplay_login_page( sts );
  return;
end if;

c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
open c2(thesid);
fetch c2 into c2rec;
close c2;

if p2 is not null
 then
  if p1 = LNG.PHG_TXT_505
   then
    sqlstmt := 'term_name_upper = ''' || upper(p2) || '''';
  elsif p1 = LNG.PHG_TXT_506
   then
    sqlstmt := 'term_name_upper like ''' || upper(p2) || '%''';
  elsif p1 = LNG.PHG_TXT_508
   then
    sqlstmt := 'term_name_soundex = ''' || soundex_api(p2,null) || '''';
  elsif p1 = LNG.PHG_TXT_507
   then
    sqlstmt := 'term_name = ''' || p2 || '''';
  end if;
end if;

if p4 is not null
 then
  if sqlstmt is not null then sqlstmt := sqlstmt || ' and '; end if;
  if p3 = LNG.PHG_TXT_505
   then
    sqlstmt := sqlstmt || 'upper(tracking_name) = ''' || upper(p4) || '''';
  elsif p3 = LNG.PHG_TXT_506
   then
    sqlstmt := sqlstmt || 'upper(tracking_name) like ''' || upper(p4) || '%''';
  elsif p3 = LNG.PHG_TXT_508
   then
    sqlstmt := sqlstmt || 'soundex_api(tracking_name,null) = ''' || soundex_api(p4,null) || '''';
  elsif p3 = LNG.PHG_TXT_507
   then
    sqlstmt := sqlstmt || 'tracking_name = ''' || p4 || '''';
  end if;
end if;

if p5 is not null
 then
  if sqlstmt is not null then sqlstmt := sqlstmt || ' and '; end if;
  sqlstmt := sqlstmt || 'upper(notes) like ''%' || upper(p5) || '%''';
end if;

if p6 is not null
 then
  if sqlstmt is not null then sqlstmt := sqlstmt || ' and '; end if;
  sqlstmt := sqlstmt || 'date_updated > to_date(''' || p6 || ''',''' || LNG.MASK || ''')';
end if;

if sqlstmt is null
 then
  htp.htmlopen;
  glbx.header_msg( 'You must in a Search Term' );
  htp.htmlclose;
  return;
end if;

sqlstmt := 'select term_id,term_name from thesaurus_term where thes_id = ' || thesid || ' and ' || sqlstmt;
--htp.p( sqlstmt );
--return;

ctr := 0;
open dcurs for sqlstmt;
loop
   ctr := ctr + 1;
   fetch dcurs into sterms(ctr).term_id,sterms(ctr).term_name;
   exit when dcurs%notfound;
end loop;
close dcurs;

if c2rec.display_style = 'COLUMN'
 then
  thesaurus_column(surl,thesid,acid,sterms,1,sterms.count,p2,sterms.count);
elsif c2rec.display_style = 'HIERARCHICAL'
 then
  null;
elsif c2rec.display_style = 'EXTERNAL'
 then
  null;
end if;

exception when others then
 glbx.error_details( 'THES', 'ACCEPT_ADVANCED_SEARCH',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'thesid=' || thesid );
end accept_advanced_search;

procedure term_umo( surl in varchar2, left_api in varchar2 default null, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null )
as

 -- XXX: These queries need to be written better to run faster
 cursor c2( thesid integer, termid integer, acid integer ) is
  select /*+ ALL_ROWS */ *
  from umo
  where aid = acid and
        umo_id in
   (select /*+ ALL_ROWS */ umo_id
    from thesaurus_term tt, thesaurus_term_umo ttu
    where tt.term_id = ttu.term_id and tt.thes_id = thesid and tt.term_id = termid
   union
    select /*+ ALL_ROWS */ ua.umo_id
    from map_meta_thesaurus mmt, umo_attribute ua, thesaurus_term tt, umo um
    where mmt.aid = acid and
          mmt.thes_id = tt.thes_id and
          ua.attribute_id = mmt.attribute_id and
          um.umo_id = ua.umo_id and
          um.aid = mmt.aid and
          tt.term_name_upper = upper(ua.value) and
          tt.term_id = termid and
          tt.thes_id = thesid
   );

 cursor c4( thesid integer, termid integer, acid integer ) is
  select count('x') tot
  from umo
  where aid = acid and
        umo_id in
   (select /*+ ALL_ROWS */ umo_id
    from thesaurus_term tt, thesaurus_term_umo ttu
    where tt.term_id = ttu.term_id and tt.thes_id = thesid and tt.term_id = termid
   union
    select /*+ ALL_ROWS */ ua.umo_id
    from map_meta_thesaurus mmt, umo_attribute ua, thesaurus_term tt, umo um
    where mmt.aid = acid and
          mmt.thes_id = tt.thes_id and
          ua.attribute_id = mmt.attribute_id and
          um.umo_id = ua.umo_id and
          um.aid = mmt.aid and
          tt.term_name_upper = upper(ua.value) and
          tt.term_id = termid and
          tt.thes_id = thesid
   );

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ctr		integer;
 profid		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 result_list	UMP.SEARCH_RESULT_PHG;
 thesid		integer;
 termid		integer;
 numb_photos	integer;
 total_records	integer;

begin

 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'THES.TERM_UMO' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 ctr := 1;

 if acid is null
  then
   numb_photos := to_number(glbx.photo_pref(c1rec.pid,c1rec.aid,'NUMBER_PHOTOS'));
   numb_photos := nvl(numb_photos,10);
  else
   numb_photos := to_number(glbx.photo_pref(c1rec.pid,c1rec.aid,'PHOTO_DISPLAY'));
   numb_photos := nvl(numb_photos,10);
 end if;

 thesid := substr(left_api_parm,2,instr(left_api_parm,']')-2);
 termid := substr(left_api_parm,instr(left_api_parm,']')+1);

 for c2rec in c2(thesid,termid,acid) loop
  if ctr < start_from
   then
    null;
   else
    if ctr >= (start_from + numb_photos)
     then
      exit;
     else
      result_list( ctr ) := c2rec;
    end if;
  end if;
  ctr := ctr + 1;
 end loop;

 open c4(thesid,termid,acid);
 fetch c4 into total_records;
 close c4;
 glbx.extended_search_api( surl=>surl, ltype=>ltype, result_list=>result_list, search_total=>total_records,
                           display_detail=>display_detail, title=>'Matching Thesaurus Images',
                           left_api_parm=>left_api_parm, left_api=>null,footer_api=>'thes.term_umo',
                           current_page_number=>start_from,no_results_message=>'There are no Associated Images for this Thesaurus Value',acid=>acid);

exception when others then
 glbx.error_details( 'THES', 'TERM_UMO',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'left_api_parm=' || left_api_parm );
end term_umo;

procedure term_search( surl in varchar2, thesid in integer, search_term in varchar2 default null, bttermid in integer default null, acid in integer default null, start_from in integer default 1 )
as

 cursor c2( thesid integer ) is select * from thesaurus where thes_id = thesid;

 cursor c3( thesid integer, src varchar2 ) is
  select term_id,term_name
  from thesaurus_term
  where thes_id = thesid and
        term_name_upper like src || '%';
 cursor c3_tot( thesid integer, src varchar2 ) is
  select count('x') tot
  from thesaurus_term
  where thes_id = thesid and
        term_name_upper like src || '%'
  order by term_name;

 cursor c4( thesid integer, bttermid integer ) is
  select tt.term_id,tt.term_name
  from thesaurus_term tt, thesaurus_relationship ttr
  where ttr.related_term_id = bttermid and
        relationship_type = 'BT' and
        tt.thes_id = thesid and
        ttr.term_id = tt.term_id
  order by tt.term_name;
 cursor c4_tot( thesid integer, bttermid integer ) is
  select count('x') tot
  from thesaurus_term tt, thesaurus_relationship ttr
  where ttr.related_term_id = bttermid and
        relationship_type = 'BT' and
        tt.thes_id = thesid and
        ttr.term_id = tt.term_id;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 profid		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 sterms		THES.LIST_OF_TERMS;
 ctr		integer;
 tot		integer;

begin

glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'THES.TERM_SEARCH' );
if sts is not null
 then
  glbx.redisplay_login_page( sts );
  return;
end if;

c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
open c2(thesid);
fetch c2 into c2rec;
close c2;

ctr := 0;
if search_term is not null
 then
  open c3_tot(thesid, upper(search_term) );
  fetch c3_tot into tot;
  close c3_tot;
  for c3rec in c3( thesid, upper(search_term) ) loop
   if (c3%ROWCOUNT > start_from) or (start_from = 1)
    then
     ctr := ctr + 1;
     sterms(ctr).term_id := c3rec.term_id;
     sterms(ctr).term_name := c3rec.term_name;
     if ctr > c2rec.max_display_rows then exit; end if;
   end if;
  end loop;
elsif bttermid is not null
 then
  open c4_tot(thesid, bttermid );
  fetch c4_tot into tot;
  close c4_tot;
  for c4rec in c4( thesid, bttermid ) loop
   if (c4%ROWCOUNT > start_from) or (start_from = 1)
    then
     ctr := ctr + 1;
     sterms(ctr).term_id := c4rec.term_id;
     sterms(ctr).term_name := c4rec.term_name;
     if ctr > c2rec.max_display_rows then exit; end if;
   end if;
  end loop;
else
 null;
end if;

if c2rec.display_style = 'COLUMN'
 then
  thesaurus_column(surl,thesid,acid,sterms,start_from,sterms.count,search_term,nvl(tot,0));
elsif c2rec.display_style = 'HIERARCHICAL'
 then
  null;
elsif c2rec.display_style = 'EXTERNAL'
 then
  null;
end if;

exception when others then
 glbx.error_details( 'THES', 'TERM_SEARCH',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'search_term:' || search_term || ' thesid:' || thesid );
end term_search;

procedure loadthes( thesid in integer, fdir in varchar2, fname in varchar2, retval in out varchar2 )
as

cursor c1( thesid integer, trname varchar2 ) is select * from thesaurus_term where tracking_name = trname and thes_id = thesid;
cursor c2 is select max(term_id) from thesaurus_term;

c1rec	c1%ROWTYPE;
c1xrec	c1%ROWTYPE;
fl	UTL_FILE.FILE_TYPE;
bfr	varchar2(1000);
ctr	integer;
nmb	integer;
tr_name	varchar2(100);
t_name	varchar2(100);
nt	varchar2(4000);

begin

 open c2;
 fetch c2 into ctr;
 close c2;
 ctr := nvl(ctr,0);
 nmb := 0;
 delete from thesaurus_relationship where term_id in (select term_id from thesaurus_term where thes_id = thesid );
 delete from thesaurus_term where thes_id = thesid;

  -- First Parse Just add Terms
  -- fl := utl_file.fopen( 'C:\XOR\Customers\AWM\data', 'places.txt', 'r' );
  fl := utl_file.fopen( fdir, fname, 'r' );
  loop
   begin utl_file.get_line(fl,bfr); exception when others then exit; end;
   if bfr = '<REC>'
    then
     tr_name := null;
     t_name := null;
     nt := null;
   elsif bfr = '</REC>'
    then
      ctr := ctr + 1;
      nmb := nmb + 1;
      insert into thesaurus_term(thes_id,term_id,tracking_name,term_name,term_name_upper,term_name_soundex,term_type,date_created,date_updated,notes) values
       (thesid,ctr,tr_name, t_name, upper(t_name),soundex_api(t_name,null),'PT',sysdate,sysdate,nt );
   elsif substr(bfr,1,4) = '<ID>'
    then
     tr_name := substr(bfr,5,instr(bfr,'</ID>',6) - 5);
   elsif substr(bfr,1,7) = '<TITLE>'
    then
     t_name := substr(bfr,8,instr(bfr,'</TITLE>',9) - 8);
   elsif substr(bfr,1,6) = '<NOTE>'
    then
     t_name := substr(bfr,7,instr(bfr,'</NOTE>',8) - 7);
   elsif substr(bfr,1,4) = '<BT>'
    then
     null;
   elsif substr(bfr,1,4) = '<UF>'
    then
     null;
   elsif substr(bfr,1,4) = '<RT>'
    then
     null;
   elsif substr(bfr,1,5) = '<USE>'
    then
     null;
   end if;
  end loop;
  utl_file.fclose( fl );

  -- Second Parse add Relationships
  fl := utl_file.fopen( fdir, fname, 'r' );
  loop
   begin utl_file.get_line(fl,bfr); exception when others then exit; end;
   if bfr = '<REC>'
    then
     tr_name := null;
     t_name := null;
   elsif bfr = '</REC>'
    then
     null;
   elsif substr(bfr,1,4) = '<ID>'
    then
     tr_name := substr(bfr,5,instr(bfr,'</ID>',6) - 5);
     open c1(thesid,tr_name);
     fetch c1 into c1rec;
     close c1;
   elsif substr(bfr,1,7) = '<TITLE>'
    then
     t_name := substr(bfr,8,instr(bfr,'</TITLE>',9) - 8);
   elsif substr(bfr,1,4) = '<BT>'
    then
     open c1(thesid,substr(bfr,5,instr(bfr,'</BT>',6) - 5));
     fetch c1 into c1xrec;
     close c1;
     insert into thesaurus_relationship(term_id,related_term_id,relationship_type) values (c1rec.term_id, c1xrec.term_id, 'BT' );
   elsif substr(bfr,1,4) = '<UF>'
    then
     open c1(thesid,substr(bfr,5,instr(bfr,'</UF>',6) - 5));
     fetch c1 into c1xrec;
     close c1;
     insert into thesaurus_relationship(term_id,related_term_id,relationship_type) values (c1rec.term_id, c1xrec.term_id, 'UF' );
   elsif substr(bfr,1,4) = '<RT>'
    then
     open c1(thesid,substr(bfr,5,instr(bfr,'</RT>',6) - 5));
     fetch c1 into c1xrec;
     close c1;
     insert into thesaurus_relationship(term_id,related_term_id,relationship_type) values (c1rec.term_id, c1xrec.term_id, 'RT' );
   elsif substr(bfr,1,4) = '<NT>'
    then
     open c1(thesid,substr(bfr,5,instr(bfr,'</NT>',6) - 5));
     fetch c1 into c1xrec;
     close c1;
     insert into thesaurus_relationship(term_id,related_term_id,relationship_type) values (c1rec.term_id, c1xrec.term_id, 'NT' );
   elsif substr(bfr,1,5) = '<USE>'
    then
     open c1(thesid,substr(bfr,6,instr(bfr,'</USE>',7) - 6));
     fetch c1 into c1xrec;
     close c1;
     insert into thesaurus_relationship(term_id,related_term_id,relationship_type) values (c1rec.term_id, c1xrec.term_id, 'USE' );
   end if;
  end loop;
  utl_file.fclose( fl );

  commit;
  generate_start_alphabet( thesid );
  generate_start_terms( thesid );
  retval := 'Thesaurus Loaded. Number of terms' || ':' || nmb;

exception
 when others then retval := sqlerrm;
end loadthes;

procedure generate_start_alphabet( thesid in integer default 1 )
as

 cursor c1(thesid integer) is select distinct(upper(substr(term_name,1,1))) tname from thesaurus_term where thes_id = thesid;

 start_alpha	varchar2(100);

begin

 start_alpha := NULL;
 for c1rec in c1(thesid) loop
  start_alpha := start_alpha || c1rec.tname;
 end loop;
 update thesaurus set start_alphabet = start_alpha where thes_id = thesid;
 commit;

end generate_start_alphabet;

procedure generate_start_terms( thesid in integer default 1 )
as

begin
 delete from thesaurus_start_terms where thes_id = thesid;
 insert into thesaurus_start_terms(thes_id,term_id)
  select thesid,term_id
  from thesaurus_term
  where thes_id = thesid and
        term_id not in (select tr.term_id from thesaurus_relationship tr, thesaurus_term tt where tr.term_id = tt.term_id and tt.thes_id = thesid );
 commit;
end generate_start_terms;

procedure thes_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c2(phgid integer) is
  select name,thes_id
  from thesaurus
  where public_private = 'PUBLIC'
 union
  select name,thes_id
  from thesaurus
  where public_private = 'PRIVATE' and
        private_pid = phgid
  order by 1;

 cursor c3( thesid integer ) is select * from thesaurus where thes_id = thesid;

 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 vv_thes_id	integer;
 sts		varchar2(100);
 retcall	varchar2(1000);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'THES.THES_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, 'Manage the Customer Thesaurus',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( 'Manage the Customer Thesaurus' );
 htp.nl;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );

 htp.bold( 'Available Thesauri' );
 htp.nl;
 htp.nl;
 htp.tablerowopen;
 for c2rec in c2(owner_id) loop
   vv_thes_id := nvl(vv_thes_id,c2rec.thes_id);
   htp.tabledata( htf.anchor( 'thes.main?surl=' || surl || '&nvid=' || nvid || '&loc_id=' || c2rec.thes_id || '&footer_api=&left_api_parm=&left_api=&current_page_number=&display_detail=&acid=' || acid || '&first_parameter=' || replace(first_parameter,' ','+') || '&called_from=' || replace(called_from,' ','+'), '[' || c2rec.name || ']' ));
 end loop;
 htp.tablerowclose;
 htp.tableclose;

 vv_thes_id := nvl(loc_id,vv_thes_id);
 open c3(vv_thes_id);
 fetch c3 into c3rec;
 close c3;

 htp.nl;
 htp.nl;
 htp.bold( 'Current Thesaurus' || ':' || c3rec.name );
 htp.nl;
 htp.nl;
 --thesaurus_alphabet(surl, c3rec, acid, TRUE);

 htp.nl;
 retcall := 'thes.accept_thes_pref?surl=' || surl || '&acid=' || acid || '&nvid=' || nvid || '&loc_id=' || vv_thes_id || '&first_parameter=' || replace(first_parameter,' ','+') || '&called_from=' || replace(called_from,' ','+');

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
  htp.tablerowopen;
    htp.tabledata(htf.anchor( retcall || '&p1=1', LNG4.AHC_TXT_515 ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.anchor( retcall || '&p1=2', LNG4.AHC_TXT_516 ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.anchor( retcall || '&p1=3', LNG4.AHC_TXT_517 ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.anchor( retcall || '&p1=4', LNG4.AHC_TXT_518 ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.anchor( retcall || '&p1=5', LNG4.AHC_TXT_519 ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.anchor( retcall || '&p1=6', 'Unload a Thesaurus' ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.anchor( retcall || '&p1=7', 'Map to Meta Data' ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.anchor( retcall || '&p1=8', 'Validate Terms (Exception Report)' ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.anchor( retcall || '&p1=9', 'Report on Term Usage' ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'THES', 'THES_PREF',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end thes_pref;

procedure accept_thes_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 )
as

 cursor c3( thesid integer ) is select * from thesaurus where thes_id = thesid;
 cursor c4( thesid integer, rt varchar2 ) is select role_id from thesaurus_roles where thes_id = thesid and role_target = rt;
 cursor c5 is select role_id,role_name from piction_roles where role_type = 'SECURITY ROLE' order by role_name;
 cursor c6( bftr varchar2 ) is
  select attribute_id, sub_category, umo_type, edit_type
  from umo_attributes
  where ((business_feature is null) or (business_feature is not null and business_feature = bftr)) and
         disp_phg = 'T' and
         edit_type in ('Thesaurus','VARCHAR','LOV') and
         umo_type in ('ALL','PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT')
  order by sub_category;
 cursor c7(acid integer) is select theme_type from customer_account where aid = acid;
 cursor c8(thesid integer, acid integer) is select mmt.attribute_id, ut.edit_type from map_meta_thesaurus mmt, umo_attributes ut where ut.attribute_id = mmt.attribute_id and thes_id = thesid and aid = acid;
 cursor c9(thesid integer) is
  select length(term_name) len, count('x') cnt, min(term_name) mn, max(term_name) mx
  from thesaurus_term
  where thes_id = thesid
  group by length(term_name);

 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c7rec		c7%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'THES.ACCEPT_THES_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 ctr := 1;

 pfx := glbx.get_thm( acid );

 open c3(loc_id);
 fetch c3 into c3rec;
 close c3;

 if p1 = '1'
  then
   -- Create a New Thesaurus
    glbx.main_title( surl, 'Create a New Thesaurus',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.title( 'Create a New Thesaurus' );
    htp.nl;
    htp.p( '<CENTER>' );
    htp.formopen( 'thes.accept_thes_pref_create' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ACID', acid );
    htp.formhidden( 'NVID', nvid );
    htp.formhidden( 'LOC_ID', loc_id );
    htp.formhidden( 'FIRST_PARAMETER', first_parameter );
    htp.formhidden( 'CALLED_FROM', called_from );

    htp.bold( 'Create a Private Thesaurus - Valid across all Customer Accounts' );
    htp.nl;
    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
     htp.tablerowopen;
       htp.tabledata(htf.bold( 'Thesaurus Name' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.tabledata(htf.formtext( 'P1', 30, 100 ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formsubmit( null, 'Create' );
       htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;
    htp.formclose;
    htp.p( '</CENTER>' );
    htp.htmlclose;

 elsif p1 = '2'
  then
    -- Modify Thesaurus Details
    if c3rec.public_private = 'PUBLIC'
     then
       thes_pref(surl,nvid,loc_id,acid,first_parameter,called_from, 'A Public Thesaurus cannot be modified');
       return;
    end if;

    glbx.main_title( surl, 'Modify Thesaurus' || ':' || c3rec.name,glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.title( 'Modify Thesaurus' );
    htp.nl;
    htp.p( '<CENTER>' );
    htp.formopen( 'thes.accept_thes_pref_modify' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ACID', acid );
    htp.formhidden( 'NVID', nvid );
    htp.formhidden( 'LOC_ID', loc_id );
    htp.formhidden( 'FIRST_PARAMETER', first_parameter );
    htp.formhidden( 'CALLED_FROM', called_from );

    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
     htp.tablerowopen;
       htp.tabledata(htf.bold( 'Rename Thesaurus to Name' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.tabledata(htf.formtext( 'P1', 30, 100 ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
       htp.tabledata(htf.formsubmit( 'ACTION', 'Rename' ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata(htf.bold( 'Change Display Style to' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formselectopen( 'P1' );
        if c3rec.display_style = 'COLUMN'
         then
          htp.formselectoption( 'COLUMN', 'SELECTED' );
         else
          htp.formselectoption( 'COLUMN' );
        end if;
        if c3rec.display_style = 'HIERARCHICAL'
         then
          htp.formselectoption( 'HIERARCHICAL', 'SELECTED' );
         else
          htp.formselectoption( 'HIERARCHICAL' );
        end if;
        if c3rec.display_style = 'EXTERNAL'
         then
          htp.formselectoption( 'EXTERNAL', 'SELECTED' );
         else
          htp.formselectoption( 'EXTERNAL' );
        end if;
        htp.formselectclose;
       htp.p( '</TD>' );
       htp.tabledata(htf.formsubmit( 'ACTION', 'Change' ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata(htf.bold( 'Regenerate Start Alphabet' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
       htp.tabledata(htf.formsubmit( 'ACTION', 'Regenerate' ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata(htf.bold( 'Change Purpose of Thesaurus' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.tabledata(htf.formtext( 'P1', 30, 4000,c3rec.purpose  ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
       htp.tabledata(htf.formsubmit( 'ACTION', 'Update' ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
    htp.formclose;
    htp.formopen( 'thes.accept_thes_pref_modify' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ACID', acid );
    htp.formhidden( 'NVID', nvid );
    htp.formhidden( 'LOC_ID', loc_id );
    htp.formhidden( 'FIRST_PARAMETER', first_parameter );
    htp.formhidden( 'CALLED_FROM', called_from );
     htp.tablerowopen;
       htp.tabledata(htf.bold( 'Can be Externally Queried' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       if c3rec.external_queried = 'T'
        then
         htp.tabledata(htf.formradio( 'P1', 'T', 'CHECKED' ) || 'Yes' || ' ' || htf.formradio( 'P1', 'F' ) || 'No', cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
        else
         htp.tabledata(htf.formradio( 'P1', 'T' ) || 'Yes' || ' ' || htf.formradio( 'P1', 'F', 'CHECKED' ) || 'No',cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
       end if;
       htp.tabledata(htf.formsubmit( 'ACTION', 'Change Security' ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
    htp.formclose;
    htp.tableclose;

 elsif p1 = '3'
  then
   -- Reverse Engineer a Thesaurus
    glbx.main_title( surl, 'Reverse Engineer a Thesaurus into' || ':' || c3rec.name,glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.title( 'Reverse Engineer a Thesaurus' );
    htp.nl;
    htp.p( '<CENTER>' );
    htp.formopen( 'thes.accept_thes_pref_load' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ACID', acid );
    htp.formhidden( 'NVID', nvid );
    htp.formhidden( 'LOC_ID', loc_id );
    htp.formhidden( 'FIRST_PARAMETER', first_parameter );
    htp.formhidden( 'CALLED_FROM', called_from );

    htp.bold( 'Thesaurus File Data must be in XML Format' );
    htp.nl;
    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
     htp.tablerowopen;
       htp.tabledata(htf.bold( LNG4.AHC_TXT_613 ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.tabledata(htf.bold( glbx.extract_master_parameter( 'REPORTS_DIRECTORY' ) ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata(htf.bold( LNG.LAB_TXT_046 ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.tabledata(htf.formtext( 'P1', 30, 100 ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formsubmit( null, 'Reverse Engineer' );
       htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;
    htp.formclose;

    htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
    htp.tablerowopen;
    htp.p( '<TD ALIGN="LEFT" VALIGN="TOP">' );
    htp.nl;
    htp.nl;
    htp.bold( 'Valid Tags' );
    htp.nl;
    htp.nl;
    htp.p( '<I>The Thesaurus Conforms to ISO 2788:1986 - A Monlingual Thesauri</I>' );
    htp.nl;
    htp.nl;
    htp.p( 'One XML Tag Per Line. Each term to be enclosed between a &lt;REC&gt; and a &lt;/REC&gt; tag.<BR>The REC tags are also stored on a separate line.' );
    htp.nl;
    htp.nl;
    htp.nl;
    htp.p( '<B>&lt;ID&gt;</B> - ID of the Thesaurus Term' );
    htp.nl;
    htp.nl;
    htp.p( '<B>&lt;TITLE&gt;</B> - Name of the Thesaurus Term' );
    htp.nl;
    htp.nl;
    htp.p( '<B>&lt;NOTE&gt;</B> - Note/Details of the Thesaurus Term' );
    htp.nl;
    htp.nl;
    htp.p( '<B>&lt;BT&gt;</B> - Broader Term' );
    htp.nl;
    htp.nl;
    htp.p( '<B>&lt;UF&gt;</B> - Used For' );
    htp.nl;
    htp.nl;
    htp.p( '<B>&lt;RT&gt;</B> - Related Term' );
    htp.nl;
    htp.nl;
    htp.p( '<B>&lt;NT&gt;</B> - Narrower Term' );
    htp.nl;
    htp.nl;
    htp.p( '<B>&lt;USE&gt;</B> - Use' );
    htp.nl;
    htp.nl;
    htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tableclose;
    htp.p( '</CENTER>' );
    htp.htmlclose;

 elsif p1 = '4'
  then
    -- Thesaurus Security
    glbx.main_title( surl, 'Thesaurus Security',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.title( 'Thesaurus Security' );
    htp.nl;
    htp.p( '<CENTER>' );
    htp.formopen( 'thes.accept_thes_pref_security' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ACID', acid );
    htp.formhidden( 'NVID', nvid );
    htp.formhidden( 'LOC_ID', loc_id );
    htp.formhidden( 'FIRST_PARAMETER', first_parameter );
    htp.formhidden( 'CALLED_FROM', called_from );

    htp.bold( 'Map Roles to Thesaurus Functionality' );
    htp.nl;
    htp.italic( 'Note: Use the Security Role Preference to map roles to a customer' );
    htp.nl;
    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
     htp.tablerowopen;
       htp.tabledata(htf.bold( 'Can Insert a Term' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formselectopen( 'P1' );
        htp.formselectoption( NULL );
        c4rec.role_id := NULL;
        open c4( loc_id, 'INSERT' );
        fetch c4 into c4rec;
        close c4;
        for c5rec in c5 loop
         if c4rec.role_id = c5rec.role_id
          then
           htp.formselectoption( c5rec.role_name, 'SELECTED', cattributes=>'VALUE="' || c5rec.role_id || '"'  );
          else
          htp.formselectoption( c5rec.role_name, cattributes=>'VALUE="' || c5rec.role_id || '"'  );
         end if;
        end loop;
        htp.formselectclose;
       htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata(htf.bold( 'Can Update a Term' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formselectopen( 'P2' );
        htp.formselectoption( NULL );
        c4rec.role_id := NULL;
        open c4( loc_id, 'UPDATE' );
        fetch c4 into c4rec;
        close c4;
        for c5rec in c5 loop
         if c4rec.role_id = c5rec.role_id
          then
           htp.formselectoption( c5rec.role_name, 'SELECTED', cattributes=>'VALUE="' || c5rec.role_id || '"'  );
          else
          htp.formselectoption( c5rec.role_name, cattributes=>'VALUE="' || c5rec.role_id || '"'  );
         end if;
        end loop;
        htp.formselectclose;
       htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata(htf.bold( 'Can Delete a Term' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formselectopen( 'P3' );
        htp.formselectoption( NULL );
        c4rec.role_id := NULL;
        open c4( loc_id, 'DELETE' );
        fetch c4 into c4rec;
        close c4;
        for c5rec in c5 loop
         if c4rec.role_id = c5rec.role_id
          then
           htp.formselectoption( c5rec.role_name, 'SELECTED', cattributes=>'VALUE="' || c5rec.role_id || '"'  );
          else
          htp.formselectoption( c5rec.role_name, cattributes=>'VALUE="' || c5rec.role_id || '"'  );
         end if;
        end loop;
        htp.formselectclose;
       htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata(htf.bold( 'Can Map a Term to an Image Publically' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formselectopen( 'P4' );
        htp.formselectoption( NULL );
        c4rec.role_id := NULL;
        open c4( loc_id, 'MAP_PUB' );
        fetch c4 into c4rec;
        close c4;
        for c5rec in c5 loop
         if c4rec.role_id = c5rec.role_id
          then
           htp.formselectoption( c5rec.role_name, 'SELECTED', cattributes=>'VALUE="' || c5rec.role_id || '"'  );
          else
          htp.formselectoption( c5rec.role_name, cattributes=>'VALUE="' || c5rec.role_id || '"'  );
         end if;
        end loop;
        htp.formselectclose;
       htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata(htf.bold( 'Can Map a Term to an Image Privately' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formselectopen( 'P5' );
        htp.formselectoption( NULL );
        c4rec.role_id := NULL;
        open c4( loc_id, 'MAP_PRIV' );
        fetch c4 into c4rec;
        close c4;
        for c5rec in c5 loop
         if c4rec.role_id = c5rec.role_id
          then
           htp.formselectoption( c5rec.role_name, 'SELECTED', cattributes=>'VALUE="' || c5rec.role_id || '"'  );
          else
          htp.formselectoption( c5rec.role_name, cattributes=>'VALUE="' || c5rec.role_id || '"'  );
         end if;
        end loop;
        htp.formselectclose;
       htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formsubmit( null, 'Modify Security' );
       htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;
    htp.formclose;
    htp.p( '</CENTER>' );
    htp.htmlclose;

 elsif p1 = '5'
  then
    -- Delete a Thesaurus
    glbx.main_title( surl, 'Delete Thesaurus' || ':' || c3rec.name,glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.title( 'Delete Thesaurus' );
    htp.nl;
    htp.p( '<CENTER>' );
    htp.formopen( 'thes.accept_thes_pref_delete' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ACID', acid );
    htp.formhidden( 'NVID', nvid );
    htp.formhidden( 'LOC_ID', loc_id );
    htp.formhidden( 'FIRST_PARAMETER', first_parameter );
    htp.formhidden( 'CALLED_FROM', called_from );

    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
     htp.tablerowopen;
       htp.tabledata(htf.bold( 'Type in the word DELETE to confirm Deletion of this Thesaurus.' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.tabledata(htf.formtext( 'P1', 30, 100 ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formsubmit( null, 'Delete Thesaurus' );
       htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;
    htp.formclose;

 elsif p1 = '6'
  then
    -- Unload a Thesaurus
    glbx.main_title( surl, 'Unload Thesaurus' || ':' || c3rec.name,glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.title( 'Unload Thesaurus' );
    htp.nl;
    htp.p( '<CENTER>' );
    htp.formopen( 'thes.accept_thes_pref_unload' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ACID', acid );
    htp.formhidden( 'NVID', nvid );
    htp.formhidden( 'LOC_ID', loc_id );
    htp.formhidden( 'FIRST_PARAMETER', first_parameter );
    htp.formhidden( 'CALLED_FROM', called_from );

    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
     htp.tablerowopen;
       htp.tabledata(htf.bold( LNG4.AHC_TXT_613 ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.tabledata(htf.bold( glbx.extract_master_parameter( 'REPORTS_DIRECTORY' ) ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata(htf.bold( LNG.LAB_TXT_046 ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.tabledata(htf.formtext( 'P1', 30, 100 ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formsubmit( null, 'Unload Thesaurus' );
       htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;
    htp.formclose;

 elsif p1 = '7'
  then
    -- Validate Terms
    glbx.main_title( surl, 'Map to Meta Data',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.title( 'Map to Meta Data' );
    htp.nl;
    htp.p( '<CENTER>' );
    htp.formopen( 'thes.accept_thes_pref_map' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ACID', acid );
    htp.formhidden( 'NVID', nvid );
    htp.formhidden( 'LOC_ID', loc_id );
    htp.formhidden( 'FIRST_PARAMETER', first_parameter );
    htp.formhidden( 'CALLED_FROM', called_from );
    open c7(acid);
    fetch c7 into c7rec;
    close c7;
    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
     htp.tablerowopen;
       htp.tabledata(htf.bold( LNG3.ADM_TXT_957 ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.tabledata('&nbsp',cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
     htp.formselectoption( NULL );

     for c8rec in c8(loc_id, acid) loop
      htp.tablerowopen;
      htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
      htp.formselectopen( 'P1' );
      htp.formselectoption( NULL );
      for c6rec in c6(c7rec.theme_type) loop
       if c6rec.attribute_id = c8rec.attribute_id
        then
         htp.formselectoption(c6rec.sub_category || '(' || c6rec.umo_type || ')', 'SELECTED', cattributes=>'VALUE="' || c6rec.attribute_id || '"'  );
        else
         htp.formselectoption(c6rec.sub_category || '(' || c6rec.umo_type || ')', cattributes=>'VALUE="' || c6rec.attribute_id || '"'  );
       end if;
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
      if c8rec.edit_type = 'Thesaurus'
       then
         htp.tabledata(htf.bold( 'Can be Cross Referenced'),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
       else
         htp.tabledata(htf.bold( 'Cross Reference not enabled' ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      end if;
      htp.tablerowclose;
     end loop;
     for j in 1..5 loop
      htp.tablerowopen;
      htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
      htp.formselectopen( 'P1' );
      htp.formselectoption( NULL );
      for c6rec in c6(c7rec.theme_type) loop
       htp.formselectoption(c6rec.sub_category || '(' || c6rec.umo_type || ')', cattributes=>'VALUE="' || c6rec.attribute_id || '"'  );
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
      htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tablerowclose;
     end loop;
    htp.tableclose;
    htp.nl;
    htp.formsubmit( null, 'Modify Mapping' );
    htp.formclose;

 elsif p1 = '8'
  then
    -- Validate Terms
    glbx.main_title( surl, 'Validate Terms (Exception Report)',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.title( 'Validate Terms (Exception Report)' );
    htp.nl;
    htp.p( '<CENTER>' );
    htp.bold( 'Available Exception Reports' );
    htp.nl;
    htp.nl;
    htp.anchor( 'thes.accept_thes_exception?surl=' || surl || '&acid=' || acid || '&nvid=' || nvid || '&loc_id=' || loc_id || '&first_parameter=' || replace(first_parameter,' ','+') || '&called_from=' || replace(called_from,' ', '+' ) || '&p1=1','Terms with Symbols in them' );
    htp.nl;
    htp.anchor( 'thes.accept_thes_exception?surl=' || surl || '&acid=' || acid || '&nvid=' || nvid || '&loc_id=' || loc_id || '&first_parameter=' || replace(first_parameter,' ','+') || '&called_from=' || replace(called_from,' ', '+' ) || '&p1=2','Terms that are not in the Dictionary' );
    htp.nl;
    htp.anchor( 'thes.accept_thes_exception?surl=' || surl || '&acid=' || acid || '&nvid=' || nvid || '&loc_id=' || loc_id || '&first_parameter=' || replace(first_parameter,' ','+') || '&called_from=' || replace(called_from,' ', '+' ) || '&p1=3','Duplicate Terms' );
    htp.nl;
    htp.anchor( 'thes.accept_thes_exception?surl=' || surl || '&acid=' || acid || '&nvid=' || nvid || '&loc_id=' || loc_id || '&first_parameter=' || replace(first_parameter,' ','+') || '&called_from=' || replace(called_from,' ', '+' ) || '&p1=4','Terms without a correspoding meta tag value' );
    htp.nl;
    htp.anchor( 'thes.accept_thes_exception?surl=' || surl || '&acid=' || acid || '&nvid=' || nvid || '&loc_id=' || loc_id || '&first_parameter=' || replace(first_parameter,' ','+') || '&called_from=' || replace(called_from,' ', '+' ) || '&p1=5','Terms related to themselves (circular reference)' );
    htp.nl;

 elsif p1 = '9'
  then
    -- Report on Term Usage
    glbx.main_title( surl, 'Report on Term Usage',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.title( 'Report on Term Usage' );
    htp.nl;
    htp.p( '<CENTER>' );
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
       htp.tabledata(htf.bold( 'Term Length' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.tabledata(htf.bold( '#Terms' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.tabledata(htf.bold( 'Min Term' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
       htp.tabledata(htf.bold( 'Max Term' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
    for c9rec in c9(loc_id) loop
     htp.tablerowopen;
       htp.tabledata(c9rec.len,cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
       htp.tabledata(c9rec.cnt,cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
       htp.tabledata(c9rec.mn,cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
       htp.tabledata(c9rec.mx,cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
    end loop;
   htp.tableclose;
 end if;

 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'THES', 'ACCEPT_THES_PREF',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end accept_thes_pref;

procedure accept_thes_pref_load(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr		integer;
 sts		varchar2(100);
 retval		varchar2(1000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'THES.ACCEPT_THES_PREF_LOAD', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 ctr := 1;

 if p1 is not null
  then
   loadthes( loc_id, glbx.extract_master_parameter( 'REPORTS_DIRECTORY' ), p1, retval);
  else
   retval := 'Filename cannot be empty';
 end if;

 thes_pref(surl,nvid,loc_id,acid,first_parameter,called_from, retval );

exception when others then
 glbx.error_details( 'THES', 'ACCEPT_THES_PREF_LOAD',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end accept_thes_pref_load;

procedure accept_thes_pref_create(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 )
as

 cursor c1 is select max(thes_id) from thesaurus;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr		integer;
 sts		varchar2(100);
 retval		varchar2(1000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'THES.ACCEPT_THES_PREF_LOAD', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 open c1;
 fetch c1 into ctr;
 close c1;
 ctr := nvl(ctr,1) + 1;

 if p1 is not null
  then
   insert into thesaurus(thes_id,name,public_private,private_pid,display_style) values (ctr,p1,'PRIVATE',owner_id,'COLUMN');
   commit;
   thes_pref(surl,nvid,ctr,acid,first_parameter,called_from, p1 || ':' || 'Created');
  else
   thes_pref(surl,nvid,loc_id,acid,first_parameter,called_from, 'A Name must be Supplied');
 end if;

exception when others then
 glbx.error_details( 'THES', 'ACCEPT_THES_PREF_CREATE',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end accept_thes_pref_create;

procedure accept_thes_pref_unload(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 )
as

 cursor c1(thid integer) is select * from thesaurus_term where thes_id = thid order by tracking_name;
 cursor c2(tid integer) is select * from thesaurus_term_note where term_id = tid;
 cursor c3(thid integer, tid integer) is select * from thesaurus_relationship where term_id = tid;
 cursor c4(thid integer, tid integer) is select tracking_name from thesaurus_term where term_id = tid and thes_id = thid;

 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr		integer;
 sts		varchar2(100);
 retval		varchar2(1000);
 bfr		varchar2(2000);
 fl		UTL_FILE.FILE_TYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'THES.ACCEPT_THES_PREF_UNLOAD', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 ctr := 1;

 if p1 is null
  then
    thes_pref(surl,nvid,loc_id,acid,first_parameter,called_from, 'File name cannot be empty' );
    return;
 end if;

  fl := utl_file.fopen( glbx.extract_master_parameter( 'REPORTS_DIRECTORY' ), p1, 'w' );

  for c1rec in c1(loc_id) loop
   bfr := '<REC>';
   utl_file.put_line( fl, bfr );
    bfr := '<ID>' || c1rec.tracking_name || '</ID>';
    utl_file.put_line( fl, bfr );
    bfr := '<TITLE>' || c1rec.term_name || '</TITLE>';
    utl_file.put_line( fl, bfr );
    for c2rec in c2(c1rec.term_id) loop
     bfr := '<NOTE>' || c2rec.note || '</NOTE>';
     utl_file.put_line( fl, bfr );
    end loop;
    for c3rec in c3(loc_id, c1rec.term_id) loop
      c4rec.tracking_name := NULL;
     open c4(loc_id,c3rec.RELATED_TERM_ID);
     fetch c4 into c4rec;
     close c4;
     if c4rec.tracking_name is not null
      then
       bfr := '<' || c3rec.relationship_type || '>' || c4rec.tracking_name || '</' || c3rec.relationship_type || '>';
       utl_file.put_line( fl, bfr );
     end if;
    end loop;
   bfr := '</REC>';
   utl_file.put_line( fl, bfr );
  end loop;
  utl_file.fclose( fl );

  thes_pref(surl,nvid,loc_id,acid,first_parameter,called_from, 'Generate File to' || ':' || p1 );

exception when others then
 glbx.error_details( 'THES', 'ACCEPT_THES_PREF_UNLOAD',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end accept_thes_pref_unload;

procedure accept_thes_pref_delete(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 )
as

 cursor c1(thid integer) is select * from thesaurus where thes_id = thid;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr		integer;
 sts		varchar2(100);
 retval		varchar2(1000);
 bfr		varchar2(2000);
 fl		UTL_FILE.FILE_TYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'THES.ACCEPT_THES_PREF_DELETE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 ctr := 1;

 if p1 is null or p1 <> 'DELETE'
  then
    thes_pref(surl,nvid,loc_id,acid,first_parameter,called_from, 'You must type in the word DELETE to delete this Thesaurus' );
    return;
 end if;

 open c1(loc_id);
 fetch c1 into c1rec;
 close c1;
 if c1rec.public_private = 'PUBLIC'
  then
    thes_pref(surl,nvid,loc_id,acid,first_parameter,called_from, 'You cannot delete a PUBLIC Thesaurus' );
    return;
 end if;

 if c1rec.private_pid <> owner_id
  then
    thes_pref(surl,nvid,loc_id,acid,first_parameter,called_from, 'Illegal Access attempting to Delete Thesaurus' );
    return;
 end if;

 delete from thesaurus_relationship where term_id in (select term_id from thesaurus_term where thes_id = loc_id );
 delete from thesaurus_term_note where term_id in (select term_id from thesaurus_term where thes_id = loc_id );
 delete from thesaurus_term_track_update where term_id in (select term_id from thesaurus_term where thes_id = loc_id );
 delete from thesaurus_term_umo where term_id in (select term_id from thesaurus_term where thes_id = loc_id );
 delete from thesaurus_term where thes_id = loc_id;
 delete from thesaurus_start_terms where thes_id = loc_id;
 delete from thesaurus_roles where thes_id = loc_id;
 delete from thesaurus where thes_id = loc_id;
 commit;

 thes_pref(surl,nvid,null,acid,first_parameter,called_from, 'Thesaurus Deleted' );

exception when others then
 glbx.error_details( 'THES', 'ACCEPT_THES_PREF_DELETE',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end accept_thes_pref_delete;

procedure accept_thes_pref_modify(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in GLBX.MYARRAY, action in varchar2 )
as

 cursor c1(thid integer) is select * from thesaurus where thes_id = thid;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr		integer;
 sts		varchar2(100);
 retval		varchar2(1000);
 bfr		varchar2(2000);
 fl		UTL_FILE.FILE_TYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'THES.ACCEPT_THES_PREF_MODIFY', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 ctr := 1;

 open c1(loc_id);
 fetch c1 into c1rec;
 close c1;
 if c1rec.public_private = 'PUBLIC'
  then
    thes_pref(surl,nvid,loc_id,acid,first_parameter,called_from, 'You cannot update a PUBLIC Thesaurus' );
    return;
 end if;

 if c1rec.private_pid <> owner_id
  then
    thes_pref(surl,nvid,loc_id,acid,first_parameter,called_from, 'Illegal Access attempting to Update Thesaurus' );
    return;
 end if;

 if action = 'Rename'
  then
   if p1 is null then thes_pref(surl,nvid,loc_id,acid,first_parameter,called_from, 'New Name cannot be Empty' ); return; end if;
   update thesaurus
    set
     name = p1(1)
    where
     thes_id = loc_id;

 elsif action = 'Change'
  then
   update thesaurus
    set
     display_style = p1(2)
    where
     thes_id = loc_id;

 elsif action = 'Regenerate'
  then
   generate_start_alphabet( loc_id );
   generate_start_terms( loc_id );

 elsif action = 'Update'
  then
   update thesaurus
    set
     purpose = p1(3)
    where
     thes_id = loc_id;

 elsif action = 'Change Security'
  then
   update thesaurus
    set
     external_queried = p1(1)
    where
     thes_id = loc_id;
 end if;
 commit;

 thes_pref(surl,nvid,loc_id,acid,first_parameter,called_from, 'Changes Made' );

exception when others then
 glbx.error_details( 'THES', 'ACCEPT_THES_PREF_MODIFY',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end accept_thes_pref_modify;

procedure accept_thes_pref_security(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2,
                                    p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, action in varchar2 default null )
as

 cursor c1(thid integer) is select * from thesaurus where thes_id = thid;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr		integer;
 sts		varchar2(100);
 retval		varchar2(1000);
 bfr		varchar2(2000);
 fl		UTL_FILE.FILE_TYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'THES.ACCEPT_THES_PREF_SECURITY', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 ctr := 1;

 open c1(loc_id);
 fetch c1 into c1rec;
 close c1;
 if c1rec.public_private = 'PUBLIC'
  then
    thes_pref(surl,nvid,loc_id,acid,first_parameter,called_from, 'You cannot update a PUBLIC Thesaurus' );
    return;
 end if;

 if c1rec.private_pid <> owner_id
  then
    thes_pref(surl,nvid,loc_id,acid,first_parameter,called_from, 'Illegal Access attempting to Update Thesaurus' );
    return;
 end if;

 update thesaurus_roles
  set
   role_id = p1
  where
   thes_id = loc_id and
   role_target = 'INSERT';
 if SQL%NOTFOUND then insert into thesaurus_roles(role_id,thes_id,role_target) values (p1, loc_id, 'INSERT' ); end if;

 update thesaurus_roles
  set
   role_id = p2
  where
   thes_id = loc_id and
   role_target = 'UPDATE';
 if SQL%NOTFOUND then insert into thesaurus_roles(role_id,thes_id,role_target) values (p2, loc_id, 'UPDATE' ); end if;

 update thesaurus_roles
  set
   role_id = p3
  where
   thes_id = loc_id and
   role_target = 'DELETE';
 if SQL%NOTFOUND then insert into thesaurus_roles(role_id,thes_id,role_target) values (p3, loc_id, 'DELETE' ); end if;

 update thesaurus_roles
  set
   role_id = p4
  where
   thes_id = loc_id and
   role_target = 'MAP_PUB';
 if SQL%NOTFOUND then insert into thesaurus_roles(role_id,thes_id,role_target) values (p4, loc_id, 'MAP_PUB' ); end if;

 update thesaurus_roles
  set
   role_id = p5
  where
   thes_id = loc_id and
   role_target = 'MAP_PRIV';
 if SQL%NOTFOUND then insert into thesaurus_roles(role_id,thes_id,role_target) values (p5, loc_id, 'MAP_PRIV' ); end if;

 commit;

 thes_pref(surl,nvid,loc_id,acid,first_parameter,called_from, 'Changes Made' );

exception when others then
 glbx.error_details( 'THES', 'ACCEPT_THES_PREF_SECURITY',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end accept_thes_pref_security;

procedure accept_thes_exception(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 )
as

 cursor c1(thid integer) is
  select /*+ ALL_ROWS */ *
  from thesaurus_term
  where thes_id = thid and
        translate(term_name,'~!@#$%^&*(){}+=-`\[]:;"<>,.?/''','                               ') <> term_name
  order by term_name;

 cursor c2(thid integer) is
  select /*+ ALL_ROWS */  *
  from thesaurus_term
  where thes_id = thid and
        term_id not in
  (
  select tt.term_id
  from thesaurus_term tt, dictionary d
  where thes_id = thid and
        tt.term_name_upper = d.term and
        association_type in ('A','D')
  )
  order by term_name;

 cursor c3(thid integer) is
  select /*+ ALL_ROWS */ *
  from thesaurus_term
  where thes_id = thid and
        replace(term_name_upper,' ','') in
   (select replace(term_name_upper,' ','') from thesaurus_term where thes_id = thid group by replace(term_name_upper,' ','') having count('x') > 1)
  order by term_name;

 cursor c4(thid integer) is
  select /*+ ALL_ROWS */  *
  from thesaurus_term
  where thes_id = thid and
        term_id not in
  (
  select /*+ ALL_ROWS */ tt.term_id
  from thesaurus_term tt, map_meta_thesaurus mmt, umo_attribute ua, umo um
  where tt.thes_id = thid and
        tt.thes_id = mmt.thes_id and
        mmt.aid = acid and
        tt.term_name_upper = upper(ua.value) and
        ua.attribute_id = mmt.attribute_id and
        um.aid = mmt.aid and
        um.umo_id = ua.umo_id
  )
  order by term_name;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'THES.ACCEPT_THES_EXCEPTION', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 ctr := 1;
 pfx := glbx.get_thm( acid );

 if p1 = '1'
  then
    glbx.main_title( surl, 'Terms with Symbols in them',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.title( 'Terms with Symbols in them' );
 elsif p1 = '2'
  then
    glbx.main_title( surl, 'Terms that are not in the Dictionary',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.title( 'Terms that are not in the Dictionary' );
 elsif p1 = '3'
  then
    glbx.main_title( surl, 'Duplicate Terms',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.title( 'Duplicate Terms' );
 elsif p1 = '4'
  then
    glbx.main_title( surl, 'Terms without a correspoding meta tag value',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.title( 'Terms without a correspoding meta tag value' );
 elsif p1 = '5'
  then
    glbx.main_title( surl, 'Terms related to themselves (circular reference)',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.title( 'Terms related to themselves (circular reference)' );
 end if;
 htp.p( '<CENTER>' );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
    htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.bold( 'Term ID' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.bold( 'Term Name' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.bold( 'Tracking Name' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
 htp.tablerowclose;
 htp.nl;

 if p1 = '1'
  then
   for c1rec in c1(loc_id) loop
    htp.tablerowopen;
      htp.tabledata(to_char(c1%ROWCOUNT),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(to_char(c1rec.term_id),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(c1rec.term_name,cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(nvl(c1rec.tracking_name,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
   end loop;
 elsif p1 = '2'
  then
   for c2rec in c2(loc_id) loop
    htp.tablerowopen;
      htp.tabledata(to_char(c2%ROWCOUNT),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(to_char(c2rec.term_id),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(c2rec.term_name,cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(nvl(c2rec.tracking_name,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
   end loop;
 elsif p1 = '3'
  then
   for c3rec in c3(loc_id) loop
    htp.tablerowopen;
      htp.tabledata(to_char(c3%ROWCOUNT),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(to_char(c3rec.term_id),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(c3rec.term_name,cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(nvl(c3rec.tracking_name,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
   end loop;
 elsif p1 = '4'
  then
   for c4rec in c4(loc_id) loop
    htp.tablerowopen;
      htp.tabledata(to_char(c4%ROWCOUNT),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(to_char(c4rec.term_id),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(c4rec.term_name,cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(nvl(c4rec.tracking_name,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
   end loop;
 elsif p1 = '5'
  then
   -- XXX Not Built Yet
   null;
 end if;

 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'THES', 'ACCEPT_THES_EXCEPTION',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end accept_thes_exception;

procedure accept_thes_pref_map(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in GLBX.MYARRAY )
as
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr		integer;
 sts		varchar2(100);
 retval		varchar2(1000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'THES.ACCEPT_THES_PREF_MAP', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 ctr := 1;

 delete from map_meta_thesaurus where thes_id = loc_id;
 for j in p1.first..p1.last loop
  if p1(j) is not null
   then
    insert into map_meta_thesaurus(attribute_id, thes_id, aid) values (p1(j), loc_id, acid );
  end if;
 end loop;
 commit;

 retval := 'Mapping Completed';
 thes_pref(surl,nvid,loc_id,acid,first_parameter,called_from, retval );

exception when others then
 glbx.error_details( 'THES', 'ACCEPT_THES_PREF_MAP',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end accept_thes_pref_map;

procedure xml_mimeheader( mimetype in varchar2 default 'text/xml', version in varchar2 default '1.0', encoding in varchar2 default 'UTF-8' )
as
begin

 owa_util.mime_header( ccontent_type=>mimetype, ccharset=>encoding );
 htp.p( '<?xml version="' || version || '" encoding="' || encoding || '"?>' );
 htp.p( '<!DOCTYPE response SYSTEM "' || 'http://' || glbx.extract_master_parameter('PICTION_HOME_PAGE') || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || '">' );

end xml_mimeheader;

procedure xml_error( errorcode in varchar2, errm in varchar2 )
as
begin
 htp.p( '<error>' );
 htp.p( '<code>' || errorcode || '</code>' );
 htp.p( '<description>' || errm || '</description>' );
 htp.p( '</error>' );
end xml_error;

procedure xml_properties( thesid in integer )
as
 cursor c1(thesid integer) is select * from thesaurus where thes_id = thesid;
 c1rec	c1%ROWTYPE;
begin
 open c1(thesid);
 fetch c1 into c1rec;
 close c1;
 htp.p( '<properties>' );
 htp.p( '<name>' || c1rec.name || '</name>' );
 htp.p( '<version>' || c1rec.version || '</version>' );
 htp.p( '<description>' || c1rec.purpose || '</purpose>' );
 htp.p( '<query-operators equals="true" contains-all-words="true" contains-any-words="true" matches-regexp="true"/>' );
 htp.p( '</properties>' );
exception when others
 then
  xml_error( sqlcode, sqlerrm );
end xml_properties;

procedure xml_extended( thesid in integer, termid in integer, nested_level in integer default 1 )
as
begin
 if nested_level = 0 then return; end if;
exception when others
 then
  xml_error( sqlcode, sqlerrm );
end xml_extended;

procedure xml_term( thesid in integer, termid in integer, nested_level in integer default 1 )
as
 cursor c1(thesid integer, termid integer) is select * from thesaurus_term where thes_id = thesid and term_id = termid;
 c1rec	c1%ROWTYPE;
begin
 if nested_level = 0 then return; end if;
 open c1(thesid, termid);
 fetch c1 into c1rec;
 close c1;
 if c1rec.term_type = 'PT'
  then
   htp.p( '<term>' || c1rec.term_name || '</term>' );
  else
   htp.p( '<term preferred="false">' || c1rec.term_name || '</term>' );
 end if;
exception when others
 then
  xml_error( sqlcode, sqlerrm );
end xml_term;

procedure xml_term_description( thesid in integer, termid in integer, nested_level in integer default 1 )
as
 cursor c1(thesid integer, termid integer) is select * from thesaurus_term_note where term_id = termid;
 cursor c2(thesid integer, termid integer) is select * from thesaurus_relationship where term_id = termid;
begin
 if nested_level = 0 then return; end if;
 htp.p( '<term-description>' );
 xml_term(thesid,termid,nested_level);
 for c1rec in c1(thesid,termid) loop
  htp.p( '<note type="' || c1rec.note_type || '">' || c1rec.note || '</note>' );
 end loop;
 for c2rec in c2(thesid,termid) loop
  if c2rec.relationship_type = 'BT'
   then
    htp.p( '<broader>' );
    xml_term(thesid,c2rec.related_term_id,nested_level);
    htp.p( '</broader>' );
  elsif c2rec.relationship_type = 'NT'
   then
    htp.p( '<narrower>' );
    xml_term(thesid,c2rec.related_term_id,nested_level);
    htp.p( '</narrower>' );
  elsif c2rec.relationship_type = 'RT'
   then
    htp.p( '<related>' );
    xml_term(thesid,c2rec.related_term_id,nested_level);
    htp.p( '</related>' );
  elsif c2rec.relationship_type = 'USE'
   then
    htp.p( '<use-instead>' );
    xml_term(thesid,c2rec.related_term_id,nested_level);
    htp.p( '</use-instead>' );
  end if;
 end loop;
 htp.p( '</term-description>' );
exception when others
 then
  xml_error( sqlcode, sqlerrm );
end xml_term_description;

procedure xml_list( thesid in integer, nested_level in integer default 1, termid_list in GLBX.MYARRAY, termid_display in GLBX.MYARRAY )
as
 cursor c1(thesid integer, termid integer) is select * from thesaurus_term where thes_id = thesid and term_id = termid;
 c1rec	c1%ROWTYPE;
begin
 if nested_level = 0 then return; end if;
 if termid_list.count = 0 then return; end if;
 htp.p( '<list>' );
 for j in termid_list.first..termid_list.last loop
  if termid_display(j) = 'term-description'
   then
    xml_term_description( thesid, to_number(termid_list(j)), nested_level );
  elsif termid_display(j) = 'term'
   then
    xml_term( thesid, to_number(termid_list(j)), nested_level );
  elsif termid_display(j) = 'extended'
   then
    xml_extended( thesid, to_number(termid_list(j)), nested_level );
  end if;
 end loop;
 htp.p( '</list>' );
exception when others
 then
  xml_error( sqlcode, sqlerrm );
end xml_list;

procedure xml_response_open( thesid in integer )
as
begin
 htp.p( '<response version="1.0" xmlns="http://' || glbx.extract_master_parameter('PICTION_HOME_PAGE') || '">' );
exception when others
 then
  xml_error( sqlcode, sqlerrm );
end xml_response_open;

procedure xml_response_close( thesid in integer )
as
begin
 htp.p( '</response>' );
exception when others
 then
  xml_error( sqlcode, sqlerrm );
end xml_response_close;

procedure xml_hierarchy_open( thesid in integer, direction in varchar2, nested_level in number )
as
begin
 if nested_level = 0 then return; end if;
 htp.p( '<hierarchy direction="' || direction || '" max_levels="' || nested_level || '">' );
exception when others
 then
  xml_error( sqlcode, sqlerrm );
end xml_hierarchy_open;

procedure xml_hierarchy_close( thesid in integer, direction in varchar2, nested_level in number )
as
begin
 if nested_level = 0 then return; end if;
 htp.p( '</hierarchy>' );
exception when others
 then
  xml_error( sqlcode, sqlerrm );
end xml_hierarchy_close;

procedure xml_node( thesid in integer, direction in varchar2, nested_level in number, parent_term in integer )
as
 cursor c2(thesid integer, termid integer) is select * from thesaurus_relationship where term_id = termid;
begin
 if nested_level = 0 then return; end if;
 htp.p( '<node>' );
 xml_term(thesid,parent_term,nested_level);
 for c2rec in c2(thesid,parent_term) loop
  if direction = 'narrower' and c2rec.relationship_type = 'NT'
   then
    xml_node(thesid, direction, (nested_level - 1), c2rec.term_id );
  elsif direction = 'broader' and c2rec.relationship_type = 'BT'
   then
    xml_node(thesid, direction, (nested_level - 1), c2rec.term_id );
  end if;
 end loop;
 htp.p( '</node>' );
exception when others
 then
  xml_error( sqlcode, sqlerrm );
end xml_node;

function validate_thesaurus( thesid in integer )
 return boolean
as
 cursor c1(thesid integer) is select external_queried from thesaurus where thes_id = thesid;
 c1rec	c1%ROWTYPE;
begin
 open c1(thesid);
 fetch c1 into c1rec;
 if c1%NOTFOUND then close c1; return(FALSE); end if;
 close c1;
 if c1rec.external_queried = 'T'
  then
   return( TRUE );
  else
   return( FALSE );
 end if;
exception
 when others then return( FALSE );
end validate_thesaurus;

procedure get_properties( thesid in integer )
as
begin
 if not validate_thesaurus( thesid ) then xml_error( '0', 'Access to Thesaurus is not allowed' ); end if;

exception when others
 then
  xml_error( sqlcode, sqlerrm );
end get_properties;

procedure download( thesid in integer, include_nonpreferred in varchar2 default 'FALSE', format in varchar2 default 'TERM' )
as

 cursor c1(thesid integer, incl varchar2) is select term_id from thesaurus_term where thes_id = thesid and (incl = 'TRUE' or (incl = 'FALSE' and term_type = 'PT')) order by term_name;

 term_list	GLBX.MYARRAY;
 term_defn	GLBX.MYARRAY;

begin
 if not validate_thesaurus( thesid ) then xml_error( '0', 'Access to Thesaurus is not allowed' ); return; end if;
 if upper(include_nonpreferred) not in ('TRUE','FALSE') then xml_error( '0', 'Invalid Value for include_nopreferred. Must be either true or false. You specified:' || include_nonpreferred ); return; end if;
 if upper(format) not in ('TERM','TERM-DESCRIPTION','EXTENDED') then xml_error( '0', 'Invalid Value for format. Must be either term, term-description or extended. You specified:' || format ); return; end if;

 xml_mimeheader( 'text/xml', version=>'1.0', encoding=>'UTF-8' );
 xml_response_open( thesid );
 for c1rec in c1(thesid, upper(include_nonpreferred)) loop
  term_list(c1%ROWCOUNT) := c1rec.term_id;
  term_defn(c1%ROWCOUNT) := upper(format);
 end loop;
 xml_list(thesid, 1, term_list, term_defn );
 xml_response_close( thesid );

exception when others
 then
  xml_error( sqlcode, sqlerrm );
end download;

procedure query( thesid in integer, operator in varchar2 default 'EQUALS', text in varchar2 default null, fuzzy in varchar2 default 'FALSE', format in varchar2 default 'TERM' )
as

 cursor c1(thesid integer, txt varchar2, opr varchar2) is
  select term_id
  from thesaurus_term
  where thes_id = thesid and
  (
   (opr = 'EQUALS' and term_name_upper = txt) or
   (opr = 'CONTAINS-ANY-WORDS' and instr(' ' || txt || ' ',' ' || term_name || ' ') > 0)
  )
  order by term_name;

 term_list	GLBX.MYARRAY;
 term_defn	GLBX.MYARRAY;
 comma_delim	GLBX.MYARRAY;
 ctr		integer;

begin
 if not validate_thesaurus( thesid ) then xml_error( '0', 'Access to Thesaurus is not allowed' ); return; end if;
 if upper(operator) not in ('EQUALS','CONTAINS-ALL-WORDS','CONTAINS-ANY-WORDS','MATCHES-REGEXP') then xml_error( '0', 'Invalid Value for operator. Must be either equals, contains-all-words, contains-any-words, matches-regexp. You specified:' || operator ); return; end if;
 if upper(format) not in ('TERM','TERM-DESCRIPTION','EXTENDED') then xml_error( '0', 'Invalid Value for format. Must be either term, term-description or extended. You specified:' || format ); return; end if;
 if text is null then xml_error( '0', 'A search term must be specified. The value for column text was empty.' ); return; end if;
 if upper(fuzzy) not in ('TRUE','FALSE') then xml_error( '0', 'Invalid Value for fuzzy. Must be either true or false. You specified:' || fuzzy ); return; end if;

 -- Note: Fuzzy is not implemented at the moment. XXX
 -- Note: matches-regexp is not implemented at the moment. XXX

 xml_mimeheader( 'text/xml', version=>'1.0', encoding=>'UTF-8' );
 xml_response_open( thesid );

 if upper(operator) in ('EQUALS','CONTAINS-ANY-WORDS')
  then
   for c1rec in c1(thesid, trim(upper(text)), upper(operator)) loop
    term_list(c1%ROWCOUNT) := c1rec.term_id;
    term_defn(c1%ROWCOUNT) := upper(format);
   end loop;

 elsif upper(operator) in ('CONTAINS-ALL-WORDS')
  then
   glbx.comma_delimited(trim(upper(text)), comma_delim, delimchar=>'');
   ctr := 1;
   if comma_delim.count > 1
    then
     for j in comma_delim.first..comma_delim.last loop
      for c1rec in c1(thesid, comma_delim(j), 'EQUALS') loop
       ctr := ctr + 1;
       term_list(ctr) := c1rec.term_id;
       term_defn(ctr) := upper(format);
      end loop;
     end loop;
   end if;

 end if;
 xml_list(thesid, 1, term_list, term_defn );
 xml_response_close( thesid );

exception when others
 then
  xml_error( sqlcode, sqlerrm );
end query;

procedure get_broader( thesid in integer, starting_term in varchar2 default null, max_levels in varchar2 default null, format in varchar2 default 'TERM' )
as

 cursor c1(thesid integer, tname varchar2) is select term_id from thesaurus_term where thes_id = thesid and term_type = 'PT' and term_name_upper = tname;
 c1rec	c1%ROWTYPE;
 nmb	integer;

begin
 if not validate_thesaurus( thesid ) then xml_error( '0', 'Access to Thesaurus is not allowed' ); return; end if;
 if upper(format) not in ('TERM','TERM-DESCRIPTION','EXTENDED') then xml_error( '0', 'Invalid Value for format. Must be either term, term-description or extended. You specified:' || format ); return; end if;
 if starting_term is null then xml_error( '0', 'A search term must be specified. The value for column starting_term was empty.' ); return; end if;
 if max_levels is null then xml_error( '0', 'Max_levels must be specified. The value for column max_levels was empty.' ); return; end if;
 begin nmb := to_number(max_levels); exception when others then xml_error( '0', 'Invalid number for max_levels:' || max_levels ); return; end;

 open c1(thesid, upper(starting_term));
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   xml_error( '0', 'Starting Term not found:' || starting_term );
   return;
 end if;
 close c1;

 xml_mimeheader( 'text/xml', version=>'1.0', encoding=>'UTF-8' );
 xml_response_open( thesid );
 xml_hierarchy_open( thesid, 'broader', nmb );
 xml_node( thesid, 'broader', nmb, c1rec.term_id );
 xml_hierarchy_close( thesid, 'broader', nmb );
 xml_response_close( thesid );

exception when others
 then
  xml_error( sqlcode, sqlerrm );
end get_broader;

procedure get_narrower( thesid in integer, starting_term in varchar2 default null, max_levels in varchar2 default null, format in varchar2 default 'TERM' )
as

 cursor c1(thesid integer, tname varchar2) is select term_id from thesaurus_term where thes_id = thesid and term_type = 'PT' and term_name_upper = tname;
 c1rec	c1%ROWTYPE;
 nmb	integer;

begin
 if not validate_thesaurus( thesid ) then xml_error( '0', 'Access to Thesaurus is not allowed' ); return; end if;
 if upper(format) not in ('TERM','TERM-DESCRIPTION','EXTENDED') then xml_error( '0', 'Invalid Value for format. Must be either term, term-description or extended. You specified:' || format ); return; end if;
 if max_levels is null then xml_error( '0', 'Max_levels must be specified. The value for column max_levels was empty.' ); return; end if;
 begin nmb := to_number(max_levels); exception when others then xml_error( '0', 'Invalid number for max_levels:' || max_levels ); return; end;

 -- starting term can be null
 if starting_term is null then xml_error( '0', 'A search term must be specified. The value for column starting_term was empty.' ); return; end if;

 open c1(thesid, upper(starting_term));
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   xml_error( '0', 'Starting Term not found:' || starting_term );
   return;
 end if;
 close c1;

 xml_mimeheader( 'text/xml', version=>'1.0', encoding=>'UTF-8' );
 xml_response_open( thesid );
 xml_hierarchy_open( thesid, 'narrower', nmb );
 xml_node( thesid, 'narrower', nmb, c1rec.term_id );
 xml_hierarchy_close( thesid, 'narrower', nmb );
 xml_response_close( thesid );

exception when others
 then
  xml_error( sqlcode, sqlerrm );
end get_narrower;

end thes;

/
