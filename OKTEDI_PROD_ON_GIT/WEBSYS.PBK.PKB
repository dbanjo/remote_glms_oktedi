CREATE OR REPLACE package body WEBSYS.pbk
as

 MAX_ITEMS			constant integer	:= 50;


function get_theme_types(acid in integer, ltype in varchar2 default null) return theme_types%ROWTYPE;
function indnt( pscene integer ) return integer;
function prod_type( id in integer, cd in varchar2, ftype in varchar2, incnull in boolean default FALSE) return varchar2;
function calculate_query( acid in integer, tgroup in varchar2, c1rec in SHOPPING_BASKET%ROWTYPE, c3rec in PURCHASE_ORDER%ROWTYPE, umo_rec in UMO%ROWTYPE, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY ) return integer;

procedure phg_reverse_email(surl varchar2, acid in integer, typ in varchar2, ebook in varchar2 )
as

 cursor c1( phgid integer, pname varchar2 ) is select abid from address_book where book_name = pname and ltype = 'PHOTOGRAPHER' and own_id = phgid;

 cursor c2( acid integer, phgid integer ) is
  select ut.value
  from umo um, customer_account ca, umo_attribute ut, umo_attributes uts
  where ut.attribute_id = uts.attribute_id and
        uts.category = 'COMMENT' and
        uts.umo_type = 'PHOTO' and
        uts.sub_category = 'EMAIL ADDRESS' and
        um.umo_id = ut.umo_id and
        um.aid = ca.aid and
        ca.aid = acid and
        ca.pid = phgid and
        ut.value is not null;

 cursor c3(acid integer, phgid integer) is
  select guest_email
  from login_session
  where aid = acid and
        unsolicited_email = 'T' and
        guest_email is not null;

 cursor c4(acid integer, phgid integer) is
  select from_email
  from ecard ec, customer_account ca
  where ec.aid = acid and
        ec.aid = ca.aid and
	ca.pid = phgid and
	from_email is not null;

 cursor c5(acid integer, phgid integer) is
  select email_address
  from grab_email
  where aid = acid;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr 		integer;
 newid		integer;
 sts		varchar2(100);
 nme		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.PHG_REVERSE_EMAIL', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  nme := nvl(upper(glbx.strip_special_characters( ebook )),'No Name');
  open c1( owner_id, nme );
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    close c1;
    select max(abid) into newid from address_book;
    newid := nvl(newid,0) + 1;
    insert into address_book(abid,book_name,ltype,own_id,date_created) values (newid,nme,ltype,owner_id,sysdate);
    commit;
   else
    close c1;
    newid := c1rec.abid;
  end if;

  ctr := 0;
  if typ = 'COMMENT'
   then
    for c2rec in c2(acid,owner_id) loop
     insert into address_book_entry(abid,email_address)
      select newid, c2rec.value
      from dual
      where not exists (select 'x' from address_book_entry where abid = newid and email_address = c2rec.value);
     ctr := ctr + nvl(sql%ROWCOUNT,0);
    end loop;
  elsif typ = 'GUEST'
   then
    for c3rec in c3(acid,owner_id) loop
     insert into address_book_entry(abid,email_address)
      select newid, c3rec.guest_email
      from dual
      where not exists (select 'x' from address_book_entry where abid = newid and email_address = c3rec.guest_email);
     ctr := ctr + nvl(sql%ROWCOUNT,0);
    end loop;
  elsif typ = 'GCARD'
   then
    for c4rec in c4(acid,owner_id) loop
     insert into address_book_entry(abid,email_address)
      select newid, c4rec.from_email
      from dual
      where not exists (select 'x' from address_book_entry where abid = newid and email_address = c4rec.from_email);
     ctr := ctr + nvl(sql%ROWCOUNT,0);
    end loop;
  elsif typ = 'DISABLED'
   then
    for c5rec in c5(acid,owner_id) loop
     insert into address_book_entry(abid,email_address)
      select newid, c5rec.email_address
      from dual
      where not exists (select 'x' from address_book_entry where abid = newid and email_address = c5rec.email_address);
     ctr := ctr + nvl(sql%ROWCOUNT,0);
    end loop;
  end if;

  addr( surl, ctr || ' ' || LNG2.FNM_TXT_174 );

exception when others then
 glbx.error_details( 'PBK', 'PHG_REVERSE_EMAIL', errmsg=>sqlerrm);
end phg_reverse_email;

procedure addr(surl varchar2, msg in varchar2 default null)
as

 cursor c1(phgid integer) is select * from address_book where own_id = phgid and ltype = 'PHOTOGRAPHER' order by book_name;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ADDR', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG2.FNM_TXT_152, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B07',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg );end if;
  htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
  for c1rec in c1(owner_id) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'pbk.edit_addr?surl=' || glbx.rndsurl(surl) || '&addrid=' || c1rec.abid, c1rec.book_name), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(c1rec.date_created,LNG.TSMASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.anchor( 'pbk.del_addr?surl=' || glbx.rndsurl(surl) || '&addrid=' || c1rec.abid, LNG2.FNM_TXT_155),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
   htp.bold( LNG2.FNM_TXT_154 );
   htp.formopen( 'pbk.create_new_addr' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
    htp.tablerowopen;
     htp.tabledata( LNG2.FNM_TXT_156 );
     htp.tabledata( htf.formtext( 'P1', 20, 100 ) );
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( null, LNG2.PBK_TXT_012 );
   htp.formclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tableclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'ADDR', errmsg=>sqlerrm);
end addr;

procedure edit_addr(surl varchar2, addrid in integer, msg in varchar2 default null)
as

 cursor c2(phgid integer, addrid integer) is select email_address from address_book_entry where abid = addrid and addrid = (select addrid from address_book where own_id = phgid and ltype = 'PHOTOGRAPHER' and abid = addrid ) order by email_address;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.EDIT_ADDR', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG2.FNM_TXT_159, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B08',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.PHG_TXT_301 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.formopen( 'pbk.accept_addr' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ADDRID', addrid );
   for c2rec in c2(owner_id,addrid) loop
   htp.tablerowopen;
    htp.tabledata( htf.formtext( 'P1', 60, 100, c2rec.email_address ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   end loop;
   for j in 1..10 loop
   htp.tablerowopen;
    htp.tabledata( htf.formtext( 'P1', 60, 100, null ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG4.AHC_TXT_693 );
   htp.formsubmit( 'ACTION', LNG2.FNM_TXT_160 );
   htp.formsubmit( 'ACTION', LNG.PHG_BUT_312 );
   htp.formclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.nl;
  htp.line;
  htp.nl;
  htp.nl;
  htp.header(2,LNG4.AHC_TXT_340,'CENTER' );
  htp.header(3,LNG4.AHC_TXT_341,'CENTER' );
  htp.nl;
  htp.formopen( 'pbk.send_email' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ADDRID', addrid );
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.FRM_TXT_032) );
    htp.tabledata( htf.formtext( 'P1', 50, 100 ) );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;' );
    htp.tabledata( htf.formtextarea( 'P2', 10, 50 ));
   htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( null, LNG4.AHC_TXT_342 );
   htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'EDIT_ADDR', errmsg=>sqlerrm);
end edit_addr;

procedure send_email( surl varchar2, addrid in integer, p1 in varchar2, p2 in varchar2 )
as

 cursor c1(phgid integer) is select contact_email from photographer where pid = phgid;
 cursor c2(phgid integer, addrid integer) is select book_name from address_book where abid = addrid;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 file_handler	UTL_FILE.FILE_TYPE;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.SEND_EMAIL', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  open c1(owner_id);
  fetch c1 into c1rec;
  close c1;
  open c2(owner_id,addrid);
  fetch c2 into c2rec;
  close c2;

  gcode(1) := 'X';
  gparam(1) := 'Y';
  file_handler := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), 'mass_email_' || addrid || '.log', 'w', max_linesize=>32767 );
  utl_file.put_line( file_handler, p2 );
  utl_file.fclose( file_handler );
  glbx.send( gcode, gparam, infile=>'mass_email_' || addrid || '.log', p_to=>c2rec.book_name, p_subj=>nvl(p1,LNG4.AHC_TXT_343), p_from=>nvl(c1rec.contact_email,glbx.extract_master_parameter('DBA_MAIL_FROM')),own_id=>owner_id,ltype=>ltype,v_pid=>owner_id);

  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG4.AHC_TXT_344, glbx.backimg(surl,null,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  htp.bold( p1 );
  htp.nl;
  htp.nl;
  htp.italic( replace(p2,chr(10),'<BR>') );
  htp.p( '<CENTER>' );

exception when others then
 glbx.error_details( 'PBK', 'SEND_EMAIL', errmsg=>sqlerrm);
end send_email;

procedure accept_addr( surl varchar2, addrid in integer, action in varchar2, p1 in GLBX.MYARRAY)
as

 cursor c1( vabid integer ) is select email_address from address_book_entry where abid = vabid;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_ADDR', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if action = LNG2.FNM_TXT_160
   then
    delete from address_book_entry where abid = addrid and abid = (select addrid from address_book where abid = addrid and ltype = 'PHOTOGRAPHER' and own_id = owner_id);
    for j in p1.first..p1.last loop
     if p1(j) is not null
      then
       insert into address_book_entry(abid,email_address) values (addrid,p1(j));
     end if;
    end loop;
    commit;
    edit_addr(surl, addrid, LNG2.FNM_TXT_161);
  elsif action = LNG4.AHC_TXT_693
   then
    delete from address_book_entry
     where
      abid = addrid and
      abid = (select addrid from address_book where abid = addrid and ltype = 'PHOTOGRAPHER' and own_id = owner_id) and
      email_address not like '%@%';
    commit;
    edit_addr(surl, addrid, LNG2.FNM_TXT_161);
  elsif action = LNG.PHG_BUT_312
   then
    htp.htmlopen;
    for c1rec in c1( addrid ) loop
     htp.p( c1rec.email_address || ',' );
    end loop;
    htp.htmlclose;
  end if;
exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_ADDR', errmsg=>sqlerrm);
end accept_addr;

procedure del_addr( surl varchar2, addrid in integer)
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.DEL_ADDR', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  delete from address_book_entry where abid = addrid and abid = (select abid from address_book where ltype = 'PHOTOGRAPHER' and own_id = owner_id and abid = addrid);
  delete from address_book where ltype = 'PHOTOGRAPHER' and own_id = owner_id and abid = addrid;
  commit;
  addr(surl, LNG2.FNM_TXT_157);

exception when others then
 glbx.error_details( 'PBK', 'DEL_ADDR', errmsg=>sqlerrm);
end del_addr;

procedure create_new_addr( surl varchar2, p1 in varchar2 )
as

 cursor c1(aname varchar2, phgid integer) is select 'x' from address_book where own_id = phgid and book_name = aname and ltype = 'PHOTOGRAPHER';

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 newid		integer;
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.DEL_ADDR', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  open c1(upper(p1),owner_id);
  fetch c1 into c1rec;
  if c1%FOUND
   then
    close c1;
    addr(surl, LNG2.FNM_TXT_158 );
    return;
  end if;
  close c1;

  select max(abid) into newid from address_book;
  newid := nvl(newid,0) + 1;
  insert into address_book(abid,book_name,ltype,own_id,date_created) values (newid,upper(p1),ltype,owner_id,sysdate);
  commit;
  edit_addr(surl, newid );

exception when others then
 glbx.error_details( 'PBK', 'DEL_ADDR', errmsg=>sqlerrm);
end create_new_addr;

procedure main(surl varchar2, msg in varchar2 default null)
as

 cursor c1(phgid integer) is select * from phg_price_book where pid = phgid order by upper(name);
 cursor c2(pb integer) is select name,price_book from phg_price_book_lab ppbl, manufacturer m where m.manufacturer_id = ppbl.manufacturer_id and ppbl.spb = pb;
 cursor c3(phgid integer) is
  select manufacturer_id, name, man_type, public_book pbook_name
  from manufacturer
  where price_book_public = 'T' and public_book is not null
   union
  select m.manufacturer_id, name, man_type, product_type pbook_name
  from manufacturer_photographer_disc mpd, manufacturer m
  where m.manufacturer_id = mpd.manufacturer_id and
        mpd.pid = phgid and
        mpd.private_price_book = 'T'
  order by 2;
 cursor c4(phgid integer) is select theme_data, photographer_title from photographer ph, theme_types tt where ph.theme_type = tt.theme_type and ph.pid = phgid;
 cursor c5(phgid integer) is select * from phg_price_object_defn where pid = phgid order by name;

 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		varchar2(32767);
 foundrec	boolean;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MAIN', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  open c4(owner_id);
  fetch c4 into c4rec;
  close c4;
  glbx.main_title( surl, replace(LNG2.PBK_TXT_001,'<PHOTOGRAPHER>',c4rec.photographer_title),glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B01',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg );end if;
  htp.bold( LNG2.PBK_TXT_002);
  htp.nl;
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.PBK_TXT_003),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.bold(LNG2.PBK_TXT_009),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
  htp.tablerowclose;
  for c1rec in c1(owner_id) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'pbk.edit_item?surl=' || glbx.rndsurl(surl) || '&id=' || c1rec.spb, nvl(trim(c1rec.name),LNG3.ADM_TXT_351)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    tmp := NULL;
    for c2rec in c2(c1rec.spb) loop
     tmp := tmp || ',' || c2rec.name || '-' || c2rec.price_book;
    end loop;
    htp.tabledata( nvl(substr(tmp,2),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.bold(LNG2.PBK_TXT_007);
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.formopen( 'pbk.accept_new_pb' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.PBK_TXT_008),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext( 'P1',30,100),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.formhidden( 'P2', null );
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.PBK_TXT_009),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    if substr(c4rec.theme_data,194,1) = 'T'
     then
      htp.formselectopen( 'P2', null, 5, cattributes=>'MULTIPLE' );
     else
      htp.formselectopen( 'P2' );
    end if;
    htp.formselectoption( NULL );
    for c3rec in c3(owner_id) loop
     htp.formselectoption(c3rec.name || '(' || c3rec.pbook_name || ')', cattributes=>'VALUE="[' || c3rec.manufacturer_id || ']' || c3rec.pbook_name  || '"');
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
  htp.tablerowclose;
  if substr(c4rec.theme_data,194,1) = 'T'
   then
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG4.AHC_TXT_857),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( htf.formcheckbox( 'P3', 'T' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG4.AHC_TXT_253),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( htf.formtext( 'P4', 10, 20, '0' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   else
    htp.formhidden( 'P3', 'F' );
    htp.formhidden( 'P4', '0' );
  end if;
  htp.tableclose;
  htp.nl;
  htp.p( LNG2.PBK_TXT_005 );
  htp.nl;
  htp.formsubmit( null, LNG2.PBK_TXT_012 );
  htp.formclose;

  -- Price Book Objects
  if substr(c4rec.theme_data,401,1) = 'T'
   then
    htp.nl;
    htp.line;
    htp.nl;
    htp.bold(LNG4.AHC_TXT_912);
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.PHG_TXT_022),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( htf.bold(LNG3.ADM_TXT_238),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
    for c5rec in c5(owner_id) loop
     htp.tablerowopen;
      htp.tabledata( htf.anchor( 'pbk.download_objects?surl=' || surl || '&ppm=' || c5rec.ppm_id,c5rec.name),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      if c5rec.multiple_type = 'L'
       then
        htp.tabledata( htf.bold( LNG4.AHC_TXT_914 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      elsif c5rec.multiple_type = 'T'
       then
        htp.tabledata( htf.bold( LNG4.AHC_TXT_915 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      elsif c5rec.multiple_type = 'X'
       then
        htp.tabledata( htf.bold( 'Exclusivity'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      else
        htp.tabledata( htf.bold( LNG4.AHC_TXT_916 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      end if;
     htp.tablerowclose;
    end loop;
    htp.tableclose;
    htp.nl;
    htp.formopen( 'pbk.download_objects' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'PPM', NULL );
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.PHG_TXT_022),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( htf.formtext( 'P1', 30, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG3.ADM_TXT_238),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( htf.formselectopen( 'P2' ) || htf.formselectoption( LNG4.AHC_TXT_914,cattributes=>'VALUE="L"' ) || htf.formselectoption( LNG4.AHC_TXT_915,cattributes=>'VALUE="T"' ) ||
                     htf.formselectoption( LNG4.AHC_TXT_916,cattributes=>'VALUE="A"' ) || htf.formselectoption( 'Exclusivity',cattributes=>'VALUE="X"' ) || htf.formselectclose,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
    htp.tableclose;
    htp.nl;
    htp.formsubmit( null, LNG4.AHC_TXT_917 );
    htp.formclose;
  end if;

  htp.nl;
  htp.line;
  htp.nl;

  -- Reports
  htp.bold( LNG.PHG_ALT_432 );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' );
   htp.tablerowopen;
    htp.tabledata( htf.anchor('pbk.report?surl=' || glbx.rndsurl(surl) || '&id=1',LNG.ORD_TXT_004),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
   htp.tablerowclose;
  htp.tableclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'MAIN',errmsg=>sqlerrm);
end main;

procedure accept_new_pb( surl varchar2, p1 in varchar2, p2 in GLBX.MYARRAY, p3 in varchar2 default 'F', p4 in varchar2 )
as

 cursor c1(pbname varchar2, phgid integer) is select 'x' from phg_price_book where upper(name) = upper(pbname) and pid = phgid;

 cursor c2(id integer, phgid integer, chrg number) is
   select s_phg_price_item.nextval nval,id,round(nvl(pb.price,0) * ((to_number(nvl(chrg,0))/100) + 1),2) charge,name,product_key,p.product_id,p.manufacturer_id,product_class,brand_id
   from product p, price_book pb, phg_price_book_lab ppbl
   where ppbl.manufacturer_id = p.manufacturer_id and
         ppbl.price_book = p.product_type and
         spb = id and
         pb.product_id = p.product_id and
         pb.valid_until is null and
         pb.manufacturer_id = p.manufacturer_id and
         pb.price_id = (select max(pb.price_id) from price_book pb2 where pb2.manufacturer_id = pb.manufacturer_id and pb2.product_id = pb.product_id and pb2.valid_until is null) and
         not exists(select 'x' from phg_price_item ppi where manufacturer_id = ppbl.manufacturer_id and ppi.lab_id = p.product_id and ppi.spb = id);

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 newid		integer;
 m1		integer;
 m2		integer;
 m3		integer;
 nmb		integer;
 nmb2		number;
 tmp		char(1);
 foundrec	boolean;

 begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_NEW_PB', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
 if p1 is null
  then
    main( surl, LNG2.PBK_TXT_006);
    return;
 end if;
 open c1(p1,owner_id);
 fetch c1 into tmp;
 if c1%FOUND
  then
    close c1;
    main( surl, LNG2.PBK_TXT_042 || ': ' || p1 || LNG2.PBK_TXT_043);
    return;
 end if;
 close c1;

 if p3 = 'F'
  then
   -- Create the one price book with multiple lab items
   select s_phg_price_book.nextval into newid from dual;
   insert into phg_price_book(spb,pid,name) values (newid,owner_id,p1);

   foundrec := FALSE;
   begin nmb2 := to_number(p4); exception when others then nmb2 := 0; end;
   for j in p2.first..p2.last loop
    if p2(j) is not null
     then
      nmb := to_number(substr(p2(j),2,instr(p2(j),']')-2));
      insert into phg_price_book_lab(spb,manufacturer_id,price_book) values (newid,nmb,substr(p2(j),instr(p2(j),']')+1));
      for c2rec in c2( newid, owner_id, nmb2 ) loop
       foundrec := TRUE;
       insert into phg_price_item(ppi,spb,charge,name,film_type,lab_id,manufacturer_id,date_created,product_class,brand_id) values
        (c2rec.nval,c2rec.id,c2rec.charge,c2rec.name,c2rec.product_key,c2rec.product_id,c2rec.manufacturer_id,sysdate,c2rec.product_class,c2rec.brand_id);
      end loop; -- Review this statement
    end if;
   end loop;
   commit;
   edit_item( surl, newid, LNG2.PBK_TXT_016 );

  else

   -- Create Multiple Price Books
   begin nmb2 := to_number(p4); exception when others then nmb2 := 0; end;
   for j in p2.first..p2.last loop
    if p2(j) is not null
     then
      select s_phg_price_book.nextval into newid from dual;
      insert into phg_price_book(spb,pid,name) values (newid,owner_id,p1 || substr(p2(j),instr(p2(j),']')+1));
      nmb := to_number(substr(p2(j),2,instr(p2(j),']')-2));
      insert into phg_price_book_lab(spb,manufacturer_id,price_book) values (newid,nmb,substr(p2(j),instr(p2(j),']')+1));
      foundrec := FALSE;
      for c2rec in c2( newid, owner_id, nmb2 ) loop
       foundrec := TRUE;
       insert into phg_price_item(ppi,spb,charge,name,film_type,lab_id,manufacturer_id,date_created,product_class,brand_id) values
        (c2rec.nval,c2rec.id,c2rec.charge,c2rec.name,c2rec.product_key,c2rec.product_id,c2rec.manufacturer_id,sysdate,c2rec.product_class,c2rec.brand_id);
      end loop;
    end if;
   end loop;

   commit;
   pbk.main(surl=>surl);
 end if;

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_NEW_PB',errmsg=>sqlerrm);
end accept_new_pb;

procedure edit_item( surl varchar2, id in integer, msg in varchar2 default null )
as

 cursor c1(id integer) is select count('x') tot from phg_price_item where spb = id;

 stype		integer;
 ltype		varchar2(100);
 owner_id	integer;
 sts		varchar2(100);
 booktot	integer;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'PBK.EDIT_ITEM', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  open c1(id);
  fetch c1 into booktot;
  close c1;
  htp.htmlopen;
  htp.framesetopen('100%',glbx.sctrl(glbx.fndtheme(owner_id),'CST_INNER_FRAME_SIZE',stype),cattributes=>'frameborder="1" framespacing="0" border="1"');
   htp.frame( 'pbk.list_item?surl=' || glbx.rndsurl(surl) || '&id=' || id || '&booktot=' || booktot,'PB_LEFT');
   htp.frame( 'pbk.modify_item?surl=' || glbx.rndsurl(surl) || '&id=' || id || '&pbit=&msg=' || replace(msg,' ','+') || '&booktot=' || booktot,'PB_RIGHT');
  htp.framesetclose;
  htp.p( '<BODY>' );
  htp.noframesopen;
   glbx.noframe(surl,'PBK.EDIT_ITEM');
  htp.noframesclose;
  htp.p( '</BODY>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'EDIT_ITEM',errmsg=>sqlerrm);
end edit_item;

procedure list_item( surl varchar2, id in integer, booktot in integer default null, rng in integer default 1, src in varchar2 default null )
as

 cursor c1(id integer, src varchar2) is
  select *
  from phg_price_item
  where spb = id and
   (
     (src is null) or
     (src is not null and
       (
        (upper(name) like '%' || upper(replace(src,'*','%')) || '%') or
        (upper(phg_code) like '%' || upper(replace(src,'*','%')) || '%')
       )
     )
   )
  order by upper(name);

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 disp		boolean;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 pname		varchar2(1000);
 islab		varchar2(20);
 isenabled	varchar2(20);
 MAX_SPAN	constant integer := 50;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.LIST_ITEM', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  htp.htmlopen;
  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG2.PBK_TXT_017,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B18',stype=>greatest(stype-3,1),sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  for c1rec in c1(id, src) loop
   disp := FALSE;
   if c1rec.phg_code is null
    then
     pname := c1rec.name;
    else
     pname := c1rec.name || '(' || c1rec.phg_code || ')';
   end if;
   if c1rec.lab_id is null then islab := 'Standard'; else islab := 'Manufacturer'; end if;
   if c1rec.enabled = 'T' then isenabled := 'Enabled'; else isenabled := 'Disabled'; end if;
   if booktot < MAX_ITEMS
    then
     disp := TRUE;
    else
     disp :=  (c1%ROWCOUNT >= rng and c1%ROWCOUNT < rng + MAX_SPAN);
   end if;
   if disp
    then
     htp.p( htf.img( DECS.IMAGE_LOCATION || 'adminc/list.gif',cattributes=>'border=0',
                    calt=>replace(c1rec.name || chr(10) || c1rec.phg_code || chr(10) || islab || chr(10) || isenabled || chr(10) || trim(to_char(c1rec.charge,LNG.MONEY_FORMAT)) || chr(10) || c1rec.film_type || ' ' || c1rec.comments,'"','')) ||
           htf.anchor2('pbk.modify_item?surl=' || glbx.rndsurl(surl) || '&id=' || id || '&pbit=' || c1rec.ppi || '&booktot=' || booktot, replace(substr(pname,1,40),'"','&#34;'),ctarget=>'PB_RIGHT') || htf.nl);
    else
     if mod(c1%ROWCOUNT,MAX_SPAN) = 1
      then
       htp.anchor( 'pbk.list_item?surl=' || surl || '&id=' || id || '&booktot=' || booktot || '&rng=' || c1%ROWCOUNT, '[' || c1%ROWCOUNT || '-' || to_char(c1%ROWCOUNT+MAX_SPAN-1) || ']' );
       htp.nl;
     end if;
   end if;
  end loop;
  htp.nl;
  htp.anchor2( 'pbk.modify_item?surl=' || glbx.rndsurl(surl) || '&id=' || id || '&pbit=0' || '&booktot=' || booktot, LNG2.PBK_TXT_046, ctarget=>'PB_RIGHT'); htp.nl;
  htp.nl;
  -- xxx language file
  htp.anchor2( 'pbk.modify_item?surl=' || glbx.rndsurl(surl) || '&id=' || id || '&pbit=' || '&booktot=' || booktot, 'Utilities', ctarget=>'PB_RIGHT'); htp.nl;
  htp.nl;
  htp.nl;
  htp.line;
  htp.formopen( 'pbk.list_item' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'ID', id );
   htp.formhidden( 'BOOKTOT', null );
   htp.nl;
   htp.formtext( 'SRC', 20, 100 );
   htp.nl;
   htp.formsubmit( null, 'Search for Name or Code' );
  htp.formclose;
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'LIST_ITEM',errmsg=>sqlerrm);
end list_item;

procedure delete_price_book( surl varchar2, id integer )
as

 cursor c1(id integer, phgid integer) is select 'x' from order_style where spb = id and pid = phgid;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		char(1);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.DELETE_PRICE_BOOK', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  open c1(id,owner_id);
  fetch c1 into tmp;
  if c1%NOTFOUND
   then
    delete from phg_price_item_display where ppi in (select ppi from phg_price_item where spb = id);
    delete from phg_price_book_lab where spb = id;
    delete from phg_price_item where spb = id;
    delete from phg_price_book where spb = id;
    commit;
  end if;
  close c1;
  pbk.main( surl,LNG2.PBK_TXT_039);
exception when others then
 glbx.error_details( 'PBK', 'DELETE_PRICE_BOOK',errmsg=>sqlerrm);
end delete_price_book;

procedure price_book_copy( surl varchar2, id integer, p1 varchar2, booktot in integer default null )
as

 cursor c1(phgid integer, p1 varchar2) is select 'x' from phg_price_book where pid = phgid and upper(name) = p1;
 cursor c2(id integer) is select * from phg_price_item where spb = id;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		char(1);
 newid		integer;
 newppi		integer;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.PRICE_BOOK_COPY', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  open c1(owner_id,upper(p1));
  fetch c1 into tmp;
  if c1%FOUND
   then
    close c1;
    modify_item( surl, id, null, LNG4.AHC_TXT_263, booktot=>booktot );
    return;
  end if;
  close c1;
  select s_phg_price_book.nextval into newid from dual;

  insert into phg_price_book(spb,pid,name) values (newid,owner_id,p1);
  insert into phg_price_book_lab(spb,manufacturer_id,price_book)
   select newid,manufacturer_id,price_book
   from phg_price_book_lab
   where spb = id;
  for c2rec in c2(id) loop
   select s_phg_price_item.nextval into newppi from dual;
   insert into phg_price_item
   (ppi,spb,charge,name,phg_code,lab_id,date_created,date_updated,film_type,film_size,enabled,is_default,comments,min_qty,max_qty,shop_item,
    shop_style,umo_id,manufacturer_id,brand_id,delivery_time_local,delivery_time_int,surcharge_local,surcharge_int,
    production_time,stock_less_than_value,status_workflow,auto_increase_perc,item_discounted,item_disc_charge,item_disc_from,item_disc_to,
   delivery_desc,product_desc,stock_less_than_desc,stock_less_purch,product_class,lease_download_object,limit_download_object,exclusive_local,exclusive_int )
   values(newppi,newid,c2rec.charge,c2rec.name,c2rec.phg_code,c2rec.lab_id,c2rec.date_created,c2rec.date_updated,c2rec.film_type,c2rec.film_size,c2rec.enabled,c2rec.is_default,c2rec.comments,c2rec.min_qty,c2rec.max_qty,c2rec.shop_item,c2rec.
          shop_style,c2rec.umo_id,c2rec.manufacturer_id,c2rec.brand_id,c2rec.delivery_time_local,c2rec.delivery_time_int,c2rec.surcharge_local,c2rec.surcharge_int,c2rec.
          production_time,c2rec.stock_less_than_value,c2rec.status_workflow,c2rec.auto_increase_perc,c2rec.item_discounted,c2rec.item_disc_charge,c2rec.item_disc_from,c2rec.item_disc_to,c2rec.delivery_desc,
          c2rec.product_desc,c2rec.stock_less_than_desc,c2rec.stock_less_purch,c2rec.product_class,c2rec.lease_download_object,c2rec.limit_download_object,c2rec.exclusive_local,c2rec.exclusive_int );
   insert into phg_price_item_display(ppi,attribute_id,value)
    select newppi,attribute_id,value from phg_price_item_display where ppi = c2rec.ppi;
  end loop;
  commit;

  pbk.main( surl,LNG4.AHC_TXT_016);

exception when others then
 glbx.error_details( 'PBK', 'PRICE_BOOK_COPY',errmsg=>sqlerrm);
end price_book_copy;

procedure mass_change( surl varchar2, id integer )
as

 cursor c2(phgid integer) is select workflow_name,status_workflow from workflow_set where pid = phgid order by workflow_name;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MASS_CHANGE', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG4.AHC_TXT_024,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B19',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  htp.bold( LNG4.AHC_TXT_220 );
  htp.nl;
  htp.formopen( 'pbk.accept_mass_change' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ID', id );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_222),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P1', 30, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_229),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( prod_type( id, 'P2', null, TRUE ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_250),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( '$' || htf.formtext( 'P3', 10, 20 ) || ' ' || LNG.PHG_TXT_509 || ' $' || htf.formtext( 'P4', 10, 20 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.nl;
  htp.bold( LNG4.AHC_TXT_254 );
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.formradio( 'R1', 'C', 'CHECKED' ) || ' ' || 'Modify' || ' ' || 'or' || htf.nl ||
                    htf.formradio( 'R1', 'R' ) || ' ' || 'Report',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_256),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'R2', 10, 20 ) || '%',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_261),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( prod_type( id, 'R3', null, TRUE ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_264),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'R4', 30, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_284),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'R5', 30, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_301),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'R6', 30, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_302),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'R7', 30, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_303),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'R8', 30, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_312),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    htp.formselectopen( 'R9' );
    htp.formselectoption( NULL );
    for c2rec in c2( owner_id ) loop
     htp.formselectoption( c2rec.workflow_name, cattributes=>'VALUE="' || c2rec.status_workflow || '"' );
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, LNG4.AHC_TXT_313 );
  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'MASS_CHANGE',errmsg=>sqlerrm);
end mass_change;

procedure accept_mass_change( surl varchar2, id integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2,
                              r1 in varchar2, r2 in varchar2, r3 in varchar2, r4 in varchar2, r5 in varchar2, r6 in varchar2, r7 in varchar2, r8 in varchar2, r9 in varchar2 )
as

 cursor c2(owner_id integer, id integer, nm varchar2, ptype varchar2, pfrom number, pto number ) is
  select *
  from phg_price_item
  where spb = id and
        ((nm is null) or (nm is not null and upper(name) like upper(nm) || '%')) and
        ((ptype is null) or (ptype is not null and film_type = ptype)) and
        ((pfrom is null) or (pfrom is not null and charge >= pfrom)) and
        ((pto is null) or (pto is not null and charge <= pto)) and
        id = (select id from phg_price_book where spb = id and pid = owner_id)
  order by name;

 cursor c3(wflow integer) is select * from workflow_set where status_workflow = wflow;

 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 foundrec	boolean;
 nmb1		number;
 nmb2		number;
 nmb3		number;
 nmb4		number;
 nmb5		number;
 nmb6		number;
 nmb7		number;
 nmb8		number;
 newval		number;
 newchar	varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_MASS_CHANGE', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG4.AHC_TXT_805,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B19',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if r1 = 'R'
   then
    glbx.header_msg( LNG4.AHC_TXT_314 );
   else
    glbx.header_msg( LNG4.AHC_TXT_315 );
  end if;

  begin nmb1 := to_number(p3); exception when others then nmb1 := NULL; htp.bold( 'Invalid Price From Number' || ':' || p3 ); htp.nl; end;
  begin nmb2 := to_number(p4); exception when others then nmb2 := NULL; htp.bold( 'Invalid Price To Number' || ':' || p4 ); htp.nl; end;
  begin nmb3 := to_number(r2); exception when others then nmb3 := NULL; htp.bold( 'Invalid Increase Number' || ':' || r2 ); htp.nl; end;
  begin nmb4 := to_number(r4); exception when others then nmb4 := NULL; htp.bold( 'Invalid Delivery Number' || ':' || r4 ); htp.nl; end;
  begin nmb5 := to_number(r5); exception when others then nmb5 := NULL; htp.bold( 'Invalid Delivery Number' || ':' || r5 ); htp.nl; end;
  begin nmb6 := to_number(r6); exception when others then nmb6 := NULL; htp.bold( 'Invalid Production Number' || ':' || r6 ); htp.nl; end;
  begin nmb7 := to_number(r7); exception when others then nmb7 := NULL; htp.bold( 'Invalid Local Surcharge' || ':' || r7 ); htp.nl; end;
  begin nmb8 := to_number(r8); exception when others then nmb8 := NULL; htp.bold( 'Invalid Int Surcharge' || ':' || r8 ); htp.nl; end;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.LAB_TXT_052),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold(LNG.LAB_TXT_015),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold(LNG.PHG_TXT_479),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold(LNG4.AHC_TXT_229),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold(LNG4.AHC_TXT_763),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold(LNG4.AHC_TXT_790),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold(LNG4.AHC_TXT_764) || ' ' || LNG3.ADM_TXT_668,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold(LNG4.AHC_TXT_771),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold(LNG4.AHC_TXT_789),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold(LNG4.AHC_TXT_612),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;
   foundrec := FALSE;

   for c2rec in c2(owner_id,id,p1,p2,nmb1,nmb2) loop
   htp.tablerowopen;
    foundrec := TRUE;
    htp.tabledata( c2rec.name,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    if r1 = 'C'
     then

      -- Update Charge
      if nmb3 is not null
       then
        newval := c2rec.charge * (1+(nmb3/100));
        update phg_price_item
        set
         charge = newval,
         date_updated = sysdate
        where ppi = c2rec.ppi;
        htp.tabledata( htf.bold(to_char(newval,LNG.MONEY_FORMAT)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
       else
        htp.tabledata( to_char(c2rec.charge,LNG.MONEY_FORMAT),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
      end if;
      htp.tabledata( c2rec.phg_code,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );

      -- Update Product Type
      if r3 is not null
       then
        update phg_price_item
        set
         film_type = r3,
         date_updated = sysdate
        where ppi = c2rec.ppi;
        htp.tabledata( htf.bold(r3),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( c2rec.film_type,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;

      -- Update Delivery Time Local
      if nmb4 is not null
       then
        update phg_price_item
        set
         delivery_time_local = nmb4,
         date_updated = sysdate
        where ppi = c2rec.ppi;
        htp.tabledata( htf.bold(nmb4),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( c2rec.delivery_time_local,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;

      -- Update Delivery Time International
      if nmb5 is not null
       then
        update phg_price_item
        set
         delivery_time_int = nmb5,
         date_updated = sysdate
        where ppi = c2rec.ppi;
        htp.tabledata( htf.bold(nmb5),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( c2rec.delivery_time_int,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;

      -- Update Production Time International
      if nmb6 is not null
       then
        update phg_price_item
        set
         production_time = nmb6,
         date_updated = sysdate
        where ppi = c2rec.ppi;
        htp.tabledata( htf.bold(nmb6),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( c2rec.production_time,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;

      -- Update Surcharge Local
      if nmb7 is not null
       then
        update phg_price_item
        set
         surcharge_local = nmb7,
         date_updated = sysdate
        where ppi = c2rec.ppi;
        htp.tabledata( htf.bold(nmb7),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( c2rec.surcharge_local,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;

      -- Update Surcharge Int
      if nmb8 is not null
       then
        update phg_price_item
        set
         surcharge_int = nmb8,
         date_updated = sysdate
        where ppi = c2rec.ppi;
        htp.tabledata( htf.bold(nmb8),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( c2rec.surcharge_int,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;

      -- Update Workflow Set
      if r9 is not null
       then
        update phg_price_item
        set
         status_workflow = r9,
         date_updated = sysdate
        where ppi = c2rec.ppi;
        c3rec.workflow_name := NULL;
        open c3( r9 );
        fetch c3 into c3rec;
        close c3;
        htp.tabledata( htf.bold(c3rec.workflow_name),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        c3rec.workflow_name := NULL;
        open c3( c2rec.status_workflow );
        fetch c3 into c3rec;
        close c3;
        htp.tabledata( c3rec.workflow_name,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;

     else
      -- Report
      htp.tabledata( to_char(c2rec.charge,LNG.MONEY_FORMAT),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
      htp.tabledata( c2rec.phg_code,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( c2rec.film_type,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( c2rec.delivery_time_local,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( c2rec.delivery_time_int,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( c2rec.production_time,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( c2rec.surcharge_local,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( c2rec.surcharge_int,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      c3rec.workflow_name := NULL;
      open c3( c2rec.status_workflow );
      fetch c3 into c3rec;
      close c3;
      htp.tabledata( c3rec.workflow_name,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
   htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   if not foundrec
    then
     htp.bold( LNG4.AHC_TXT_317 );
    else
     if r1 = 'R'
      then
       htp.bold( LNG4.AHC_TXT_866 );
      else
       htp.bold( LNG4.AHC_TXT_324 );
     end if;
   end if;
   commit;
   htp.p( '</CENTER>' );
   htp.htmlclose;

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_MASS_CHANGE',errmsg=>sqlerrm);
end accept_mass_change;

procedure mass_create( surl varchar2, id integer, p1 in varchar2 default 'F', p2 in varchar2 default '0' )
as

 cursor c1(id integer, phgid integer) is select 'x' from order_style where spb = id and pid = phgid;
 cursor c2(id integer, phgid integer, nmb number) is
   select /*+ ALL_ROWS */ s_phg_price_item.nextval nval,id,round(nvl(pb.price,0) * ((to_number(nvl(nmb,0))/100) + 1),2) charge,name,product_key,p.product_id,p.manufacturer_id,product_class,brand_id
   from product p, price_book pb, phg_price_book_lab ppbl
   where ppbl.manufacturer_id = p.manufacturer_id and
         ppbl.price_book = p.product_type and
         spb = id and
         pb.valid_until is null and
         pb.product_id = p.product_id and
         pb.manufacturer_id = p.manufacturer_id and
         pb.price_id = (select max(pb.price_id) from price_book pb2 where pb2.manufacturer_id = pb.manufacturer_id and pb2.product_id = pb.product_id) and
         not exists(select 'x' from phg_price_item ppi where manufacturer_id = ppbl.manufacturer_id and ppi.lab_id = p.product_id and spb = id);

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 nmb		number;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 foundrec	boolean;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MASS_CREATE', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG4.AHC_TXT_805,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B20',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.LAB_TXT_052),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold(LNG.LAB_TXT_021),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;
  foundrec := FALSE;
  begin nmb := to_number(p2); exception when others then nmb := 0; end;
  for c2rec in c2( id, owner_id, nmb ) loop
   foundrec := TRUE;
   insert into phg_price_item(ppi,spb,charge,name,film_type,lab_id,manufacturer_id,date_created,product_class,brand_id) values
    (c2rec.nval,c2rec.id,c2rec.charge,c2rec.name,c2rec.product_key,c2rec.product_id,c2rec.manufacturer_id,sysdate,c2rec.product_class,c2rec.brand_id);
    htp.tablerowopen;
     htp.tabledata( c2rec.name,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( to_char(c2rec.charge,LNG.MONEY_FORMAT),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"' );
    htp.tablerowclose;
   end loop;
  htp.tableclose;
  commit;
  htp.nl;
  if foundrec
   then
    htp.anchor( 'pbk.edit_item?surl=' || surl || '&id=' || id, LNG4.AHC_TXT_806 );
   else
    htp.nl;
    htp.bold( LNG4.AHC_TXT_807 );
    htp.nl;
    htp.bold( '<a href="javascript:history.go(-1)" onMouseOver="self.status=document.referrer;return true">' || '[' || LNG.CST_TXT_058 || ']' || '</a>' || ' ');
    htp.nl;
  end if;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'MASS_CREATE',errmsg=>sqlerrm);
end mass_create;

procedure modify_item( surl varchar2, id in integer, pbit in integer, msg in varchar2 default NULL, booktot in integer default null )
as

  cursor c1(id integer, pbit integer, owner_id integer) is
  select *
  from phg_price_item
  where spb = id and
        ppi = pbit and
        spb in (select spb from phg_price_book where spb=id and pid = owner_id);

 cursor c2(id integer, owner_id integer) is
  select *
  from phg_price_book
  where spb = id and
        pid = owner_id;
 cursor c2a(id integer) is
  select 'x'
  from phg_price_book_lab
  where spb = id;

 cursor c3(vpb integer, ptype varchar2, mid integer) is
  select p.product_id, p.name, pb.price, p.is_discounted, p.manufctr_code, m.name bname, m.manufacturer_id, ppbl.price_book, p.xref_mfctr_code, 0 b2c_lab_discount, p.detailed_desc
  from price_book pb, product p, phg_price_book_lab ppbl, manufacturer m
  where pb.product_id = p.product_id and
        p.manufacturer_id = ppbl.manufacturer_id and
        ppbl.price_book = p.product_type and
        ppbl.spb = vpb and
        m.manufacturer_id = p.manufacturer_id and
        valid_until is null and
        ((ptype is null and p.product_type = m.public_book) or (ptype is not null and p.product_type = ptype)) and
        (mid is null or (mid is not null and m.manufacturer_id = mid)) and
        pb.manufacturer_id = ppbl.manufacturer_id
  order by m.name,ppbl.price_book,upper(p.name);

cursor c3_tot(vpb integer, phgid integer) is
 select count('x')
  from manufacturer m, product p, manufacturer_photographer_disc mpd, phg_price_book_lab ppbl, phg_price_book ppb
  where ppb.pid = phgid and
        ppb.spb = vpb and
        ppbl.price_book = p.product_type and
        ppbl.spb = ppb.spb and
        ppbl.manufacturer_id = mpd.manufacturer_id and
        mpd.pid = ppb.pid and
        m.manufacturer_id = p.manufacturer_id and
        ((mpd.product_type is null and p.product_type = m.public_book) or (mpd.product_type is not null and p.product_type = mpd.product_type)) and
        (mpd.manufacturer_id is null or (mpd.manufacturer_id is not null and m.manufacturer_id = mpd.manufacturer_id));

 cursor c3_ind(vpb integer, phgid integer, prodid integer) is
  select p.product_id, p.name, pb.price, p.is_discounted, p.manufctr_code, m.name bname, m.manufacturer_id, ppbl.price_book, p.xref_mfctr_code, nvl(mpd.discount,0) b2c_lab_discount, p.detailed_desc
  from price_book pb, manufacturer m, product p, manufacturer_photographer_disc mpd, phg_price_book_lab ppbl, phg_price_book ppb
  where pb.product_id = p.product_id and
        ppb.pid = phgid and
        ppb.spb = vpb and
        ppbl.price_book = p.product_type and
        ppbl.spb = ppb.spb and
        p.product_id = prodid and
        valid_until is null and
        ppbl.manufacturer_id = mpd.manufacturer_id and
        mpd.pid = ppb.pid and
        pb.manufacturer_id = ppbl.manufacturer_id and
        m.manufacturer_id = p.manufacturer_id and
        ((mpd.product_type is null and p.product_type = m.public_book) or (mpd.product_type is not null and p.product_type = mpd.product_type)) and
        (mpd.manufacturer_id is null or (mpd.manufacturer_id is not null and m.manufacturer_id = mpd.manufacturer_id));

 cursor c4(prodid integer) is
  select pb.price, p.is_discounted, p.manufacturer_id, p.current_stock, p.attached_doco
  from price_book pb, product p
  where pb.product_id = prodid and
        pb.product_id = p.product_id and
        pb.valid_until is null;

 cursor c5(phid integer, id integer) is
  select nvl(discount,0) b2c_lab_discount, product_type, mpd.manufacturer_id
  from manufacturer_photographer_disc mpd, phg_price_book_lab ppbl, phg_price_book ppb
  where ppb.pid = phid and
        ppb.spb = id and
        ppbl.spb = id and
        ppbl.spb = ppb.spb and
        ppbl.manufacturer_id = mpd.manufacturer_id and
        mpd.pid = ppb.pid;

 cursor c7(id integer) is
  select count('x') tot
  from phg_price_item
  where spb = id and
        nvl(is_default,'F') = 'T';

 cursor c8(id integer) is select * from phg_price_item where spb = id order by upper(name);

 cursor c9(id integer, phgid integer) is select 'x' from order_style where spb = id and pid = phgid;

 cursor c10(id integer, phgid integer) is
  select distinct ca.aid, account_name
  from customer_account ca,customer_price_book cb,order_style os
  where ca.pid = phgid and
        ca.aid= cb.aid and
        (cb.oid = os.oid or cb.oid_when_invalid = os.oid) and
        os.spb = id
  order by ca.aid;

 cursor c11(phgid integer) is select theme_data,max_pbook_items from photographer ph, theme_types tt where ph.theme_type = tt.theme_type and ph.pid = phgid;

 cursor c12(manid integer, v_umo varchar2) is
  select um.umo_id, um.audio_original.description, um.extras, um.version, um.photo_thumbnail.width wd, um.photo_thumbnail.height hg, um.umo_type
  from umo um
  where um.aid = manid and
        um.umo_type = 'MANUFACTURER' and
        umo_id = v_umo;

 cursor c13(bid integer) is select brand_name from brand where brand_id = bid;

 cursor c14(vspb integer) is select count('x') tot from phg_price_book_lab where spb = vspb and manufacturer_id is not null;

 cursor c15(vppi integer) is
  select uts.sub_category, ppid.value, ppid.attribute_id
  from phg_price_item_display ppid, umo_attributes uts
  where ppid.ppi = vppi and
        uts.attribute_id = ppid.attribute_id
  order by uts.order_by,uts.sub_category;

 cursor c16(phgid integer) is select workflow_name,status_workflow from workflow_set where pid = phgid order by workflow_name;

 cursor c17 is select product_class from class_of_product order by product_class;

 cursor c18( phgid integer ) is select ppm_id,name,decode(multiple_type,'L',LNG4.AHC_TXT_914,'T',LNG4.AHC_TXT_915,'X','Exclusivity') ty from phg_price_object_defn where pid = phgid and multiple_type in ('L','T','X');
 cursor c19( phgid integer ) is select ppm_id,name,decode(multiple_type,'A',LNG4.AHC_TXT_916) ty from phg_price_object_defn where pid = phgid and multiple_type = 'A';
 cursor c20( vppi integer ) is select * from phg_price_item_royalty where ppi = vppi order by percentage desc;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c11rec		c11%ROWTYPE;
 c12rec		c12%ROWTYPE;
 c13rec		c13%ROWTYPE;
 c14rec		c14%ROWTYPE;

 ltype		varchar2(100);
 tot		integer;
 tot_pb		integer;
 ptot		integer;
 tcost		number;
 prc		varchar2(1000);
 extra_msg	varchar2(100);
 stype		integer;
 owner_id	integer;
 tme		number;
 sts		varchar2(100);
 tmp		varchar2(32000);
 tmp1		varchar2(32000);
 tmp2		char(1);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 r1		GLBX.MYARRAY;
 r2		GLBX.MYARRAY;
 r3		GLBX.MYARRAY;
 searchURL 	varchar2(1000);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MODIFY_ITEM', iscust=>FALSE);
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  open c1(id,pbit,owner_id);
  fetch c1 into c1rec;
  close c1;
  open c2(id,owner_id);
  fetch c2 into c2rec;
  close c2;

  c5rec.b2c_lab_discount := 0;
  for c5rec in c5(owner_id, id) loop
   r1(c5%ROWCOUNT) := c5rec.b2c_lab_discount;
   r2(c5%ROWCOUNT) := c5rec.product_type;
   r3(c5%ROWCOUNT) := c5rec.manufacturer_id;
  end loop;

  open c11(owner_id);
  fetch c11 into c11rec;
  close c11;
  open c13(c1rec.brand_id);
  fetch c13 into c13rec;
  close c13;

  htp.htmlopen;
  pfx := glbx.photo_lf(owner_id);
  theme_rec := get_theme_types( owner_id, 'PHOTOGRAPHER' );

  if pbit is null
   then
    glbx.main_title( surl, LNG2.PBK_TXT_018 || ': ' || c2rec.name,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B02',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  elsif pbit = 0
   then
    glbx.main_title( surl, LNG2.PBK_TXT_019,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B02',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  else
    glbx.main_title( surl, LNG2.PBK_TXT_020 || ': ' || c1rec.name,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B02',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  end if;

  htp.nl;
  if msg is not null then glbx.header_msg( msg );end if;
  if pbit is null
   then
    htp.nl;
    htp.p( '<CENTER>' );
    if booktot < MAX_ITEMS
     then
      htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1');
       htp.tablerowopen;
        htp.tableheader( LNG2.PBK_TXT_021,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
        htp.tableheader( LNG2.PBK_TXT_023,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
        htp.tableheader( LNG.PHG_TXT_481,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
        htp.tableheader( LNG.LAB_TXT_014,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
        htp.tableheader( LNG.GLB_TXT_055,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
        htp.tableheader( LNG2.PBK_TXT_024,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tablerowclose;
      for c8rec in c8(id) loop
       htp.tablerowopen;
        htp.tabledata( htf.anchor('pbk.modify_item?surl=' || surl || '&id=' || id || '&pbit=' || c8rec.ppi || '&booktot=' || booktot, htf.bold(c8rec.name)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( htf.anchor('pbk.modify_item?surl=' || surl || '&id=' || id || '&pbit=' || c8rec.ppi || '&booktot=' || booktot, nvl(c8rec.phg_code,LNG.SLD_TXT_021)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( htf.bold(ltrim(to_char(c8rec.charge,LNG.MONEY_FORMAT))),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( htf.bold(c8rec.film_type),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
        if c8rec.enabled = 'T'
         then
          htp.tabledata( htf.bold(LNG.PHG_TXT_045),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         else
          htp.tabledata( htf.bold(LNG.PHG_TXT_046),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
        end if;
        if c8rec.is_default = 'T'
         then
          htp.tabledata( htf.bold(LNG.PHG_TXT_045),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         else
         htp.tabledata( htf.bold(LNG.PHG_TXT_046),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
        end if;
       htp.tablerowclose;
      end loop;
      htp.tableclose;
      htp.nl;
    end if;
    htp.nl;
    htp.bold( LNG.PHG_TXT_352 );
    htp.nl;
    -- xxx language file
    -- User Fees
    if substr(theme_rec.theme_data,369,1) = 'T'
      then
       htp.anchor( 'pbk.userfee?surl=' || glbx.rndsurl(surl) || '&id=' || id, 'User Fees');
       htp.nl;
    end if;

    -- Package Product
    htp.anchor( 'pbk.packprod?surl=' || glbx.rndsurl(surl) || '&id=' || id, 'Packaged Products');
    htp.nl;

    open c9(id,owner_id);
    fetch c9 into tmp;
    if c9%NOTFOUND
     then
       htp.anchor2( 'pbk.delete_price_book?surl=' || glbx.rndsurl(surl) || '&id=' || id, LNG.LAB_TXT_061, ctarget=>'PHG_BOTTOM');
       htp.nl;
       htp.anchor2( 'pbk.main?surl=' || glbx.rndsurl(surl) || '&msg=', LNG2.PBK_TXT_007, ctarget=>'PHG_BOTTOM');
       htp.nl;
       htp.anchor2( 'pbk.mass_change?surl=' || glbx.rndsurl(surl) || '&id=' || id, LNG4.AHC_TXT_024, ctarget=>'PHG_BOTTOM');
       htp.nl;
       if substr(theme_rec.theme_data,142,1) = 'T'
        then
         htp.anchor2( 'pbk.add_mfctr?surl=' || glbx.rndsurl(surl) || '&id=' || id, LNG4.AHC_TXT_871, ctarget=>'PHG_BOTTOM');
         htp.nl;
         htp.anchor2( 'pbk.del_mfctr?surl=' || glbx.rndsurl(surl) || '&id=' || id, LNG4.AHC_TXT_872, ctarget=>'PHG_BOTTOM');
         htp.nl;
       end if;
     else
       htp.nl;
       htp.anchor2( 'pbk.main?surl=' || glbx.rndsurl(surl) || '&msg=', LNG2.PBK_TXT_007, ctarget=>'PHG_BOTTOM');
       htp.nl;
       htp.anchor2( 'pbk.mass_change?surl=' || glbx.rndsurl(surl) || '&id=' || id, LNG4.AHC_TXT_024, ctarget=>'PHG_BOTTOM');
       htp.nl;
       if substr(theme_rec.theme_data,142,1) = 'T'
        then
         htp.anchor2( 'pbk.add_mfctr?surl=' || glbx.rndsurl(surl) || '&id=' || id, LNG4.AHC_TXT_871, ctarget=>'PHG_BOTTOM');
         htp.nl;
         htp.anchor2( 'pbk.del_mfctr?surl=' || glbx.rndsurl(surl) || '&id=' || id, LNG4.AHC_TXT_872, ctarget=>'PHG_BOTTOM');
         htp.nl;
       end if;
       htp.nl;
       htp.bold( LNG2.PBK_TXT_040 );
       htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1');
        for c10rec in c10(id,owner_id) loop
         htp.tablerowopen;
           htp.tabledata( htf.anchor2('phg.phg_acct_master?surl=' || surl || '&acid=' || c10rec.aid,c10rec.account_name,ctarget=>'PHG_BOTTOM'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         htp.tablerowclose;
        end loop;
       htp.tableclose;
       htp.nl;
       htp.italic( LNG2.PBK_TXT_041 );
       htp.nl;
    end if;
    close c9;
    htp.formopen( 'pbk.price_book_copy', ctarget=>'PHG_BOTTOM' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'ID', id );
    htp.formhidden( 'BOOKTOT', booktot );
    htp.formtext( 'P1', 20, 100 );
    htp.formsubmit( null, LNG2.PFM_TXT_154 );
    htp.formclose;
    htp.nl;
    open c14( id );
    fetch c14 into c14rec;
    close c14;
    if c14rec.tot > 0
     then
      htp.formopen( 'pbk.mass_create', ctarget=>'PHG_BOTTOM' );
      htp.formhidden( 'SURL', glbx.rndsurl(surl));
      htp.formhidden( 'ID', id );
      htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1');
       htp.tablerowopen;
        htp.tabledata( htf.bold(LNG4.AHC_TXT_252),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( htf.formcheckbox( 'P1', 'T', 'CHECKED' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
       htp.tablerowclose;
       htp.tablerowopen;
        htp.tabledata( htf.bold(LNG4.AHC_TXT_253),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( htf.formtext( 'P2', 10, 20, '10' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
       htp.tablerowclose;
      htp.tableclose;
      htp.nl;
      htp.formsubmit( null, LNG2.PBK_TXT_060 );
      htp.formclose;
    end if;
    htp.p( '</CENTER>' );
    htp.htmlclose;
    return;
  end if;

  if pbit = 0
   then
    htp.formopen( 'pbk.accept_modify',ctarget=>'PHG_BOTTOM', cattributes=>'name="form1"' ); -- Used for product searches
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
  elsif nvl(pbit,0) > 0
   then
    htp.formopen( 'pbk.accept_modify', cattributes=>'name="form1"' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
  end if;

  htp.formhidden( 'ID', id );
  htp.formhidden( 'PBIT', pbit );

  -- Display Manufacturer Details
  -- Are there any manufacturers for this price book?
  open c14( id );
  fetch c14 into c14rec;
  close c14;

  if c14rec.tot > 0
   then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0');
    htp.tablerowopen;

    htp.p( '<TD>' );
    htp.bold( LNG.LAB_TXT_008 );
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1');
    tmp1 := NULL;
    open c2a(id);
    fetch c2a into tmp2;
    if c2a%FOUND
     then
      close c2a;

      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG3.ADM_TXT_959),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
       htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT"' || '>' );

      -- See how many products there are to display
      -- If its greater than 200 then prompt for the product id and a search button
      open c3_tot(id,owner_id);
      fetch c3_tot into tot_pb;
      close c3_tot;
      if nvl(tot_pb,0) < nvl(c11rec.max_pbook_items,200)
      then
       htp.formselectopen( 'P6' );
       htp.formselectoption( NULL );
       if r1.exists(1)
        then
         c5rec.b2c_lab_discount := 0;
         for k in r1.first..r1.last loop
          for c3rec in c3(id, r2(k), to_number(r3(k))) loop
           -- c5rec.b2c_lab_discount := glbx.man_discount( c3rec.manufacturer_id, owner_id );
           c5rec.b2c_lab_discount := nvl(to_number(r1(k)),0);
           if (nvl(c3rec.is_discounted,'F') = 'T') and (c5rec.b2c_lab_discount > 0)
            then
             prc := to_char(c3rec.price * (1-(c5rec.b2c_lab_discount/100)),LNG.MONEY_FORMAT) || ' Disc ' || c5rec.b2c_lab_discount || '% (' || c3rec.bname || '-' || c3rec.price_book || ')';
            else
             prc := to_char(c3rec.price,LNG.MONEY_FORMAT) || ' (' || c3rec.bname || '-' || c3rec.price_book || ')';
           end if;
           if c3rec.product_id = c1rec.lab_id
            then
             htp.formselectoption( c3rec.name || '-' || prc,'SELECTED', cattributes=>'VALUE="' || c3rec.product_id || '"');
            else
             htp.formselectoption( c3rec.name || '-' || prc, cattributes=>'VALUE="' || c3rec.product_id || '"');
           end if;
          end loop;
         end loop;
        else
         c5rec.b2c_lab_discount := 0;
         for c3rec in c3(id, null, null) loop
          prc := to_char(c3rec.price,LNG.MONEY_FORMAT) || ' (' || c3rec.bname || ')';
          if c3rec.product_id = c1rec.lab_id
           then
            htp.formselectoption( c3rec.name || '-' || prc, 'SELECTED', cattributes=>'VALUE="' || c3rec.product_id || '"');
           else
            htp.formselectoption( c3rec.name || '-' || prc, cattributes=>'VALUE="' || c3rec.product_id || '"');
          end if;
         end loop;
       end if;
       htp.formselectclose;
       if c3rec.detailed_desc is not null then htp.p( c3rec.detailed_desc ); end if;
      else
       -- Must Enter in the Product Id. Display Details of the Manufacturer Product
       open c3_ind(id,owner_id,c1rec.lab_id);
       fetch c3_ind into c3rec;
       close c3_ind;
       htp.p( LNG4.AHC_TXT_388 );
       htp.nl;
       htp.p( LNG.LAB_TXT_052 || ':' || htf.bold(c3rec.name) || ' - ' || LNG.LAB_TXT_053 || ':' || c3rec.xref_mfctr_code );
       htp.nl;
       htp.p( nvl(c3rec.detailed_desc, LNG5.EXT_TXT_192) );
       c5rec.b2c_lab_discount := nvl(to_number(c3rec.b2c_lab_discount),0);
       if (nvl(c3rec.is_discounted,'F') = 'T') and (c5rec.b2c_lab_discount > 0)
        then
          prc := to_char(c3rec.price * (1-(c5rec.b2c_lab_discount/100)),LNG.MONEY_FORMAT) || ' Disc ' || c5rec.b2c_lab_discount || '% (' || c3rec.bname || '-' || c3rec.price_book || ')';
        else
          prc := to_char(c3rec.price,LNG.MONEY_FORMAT) || ' (' || c3rec.bname || '-' || c3rec.price_book || ')';
       end if;
       htp.p( LNG.LAB_TXT_019 || ' ' || htf.bold(prc) );
       htp.nl;
       htp.p( '&nbsp;&nbsp;&nbsp;' );
       -- htp.anchor2( 'pbk.product_search?surl=' || surl || '&id=' || id || '&pbit=' || pbit, LNG4.AHC_TXT_395, ctarget=>'PRODUCT_SEARCH' );
       htp.p('
          <script type="text/javascript">
          <!-- Script in MODIFY_ITEM
          // The new window to be opened
          var searchWindow;

          function openSearchWindow(searchURL, newTitle) {
             searchWindow = window.open(searchURL, newTitle);
             if (searchWindow.opener == null) {
                searchWindow.opener = self;
             }
          }
          // einde script -->
          </script>
       ');
       htp.nl;
       htp.formtext( 'P6', 10, 20, c1rec.lab_id );
       htp.p( '&nbsp;&nbsp;&nbsp;' );
       searchURL := 'pbk.product_search?surl=' || surl || '&id=' || id || '&pbit=' || pbit;
       htp.anchor2( 'javascript:openSearchWindow(''' || searchURL || ''', ''SearchForItem'');', LNG4.AHC_TXT_395); -- , ctarget=>'PRODUCT_SEARCH' );
      end if;

      htp.p('</TD>');
      htp.tablerowclose;
      htp.nl;
     else
      close c2a;
      htp.formhidden( 'P6', null );
    end if;

   if nvl(pbit,0) > 0
     then
      htp.tablerowopen;
        htp.tabledata( htf.bold(LNG2.PBK_TXT_028),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
        tcost := 0;
        c4rec.price := NULL;
        open c4(c1rec.lab_id);
        fetch c4 into c4rec;
        close c4;
        if nvl(c4rec.is_discounted,'F') = 'T'
         then
          c5rec.b2c_lab_discount := glbx.man_discount( c4rec.manufacturer_id, owner_id );
          tcost := tcost + nvl(c4rec.price * (1-(c5rec.b2c_lab_discount/100)),0);
          extra_msg := ' ' || LNG2.PBK_TXT_029 || c5rec.b2c_lab_discount || '%';
         else
          tcost := tcost + nvl(c4rec.price,0);
          extra_msg := NULL;
        end if;
        c4rec.price := NULL;
        tcost := tcost + nvl(c4rec.price,0);
        htp.tabledata( htf.italic( to_char(tcost,LNG.MONEY_FORMAT)) || extra_msg,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
      htp.tablerowopen;
        htp.tabledata( htf.bold(LNG4.AHC_TXT_768),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( htf.formtext( 'PMFCT1', 10, 20, to_char(nvl(c1rec.auto_increase_perc,0))) || '%',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
      htp.tablerowopen;
        htp.tabledata( htf.bold(LNG4.AHC_TXT_694),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( htf.italic( nvl(to_char(c4rec.current_stock),LNG4.AHC_TXT_766)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
      htp.tablerowopen;
        htp.tabledata( htf.bold(LNG4.AHC_TXT_793),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
        htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">');
        htp.p( LNG4.AHC_TXT_765 );
        htp.formtext( 'PSTK', 3, 10, c1rec.stock_less_than_value );
        htp.p( LNG4.AHC_TXT_794 );
        htp.formtext( 'PSTK_MSG', 10, 1000, nvl(c1rec.stock_less_than_desc,glbx.userpref(owner_id,0,'LOW_STOCK_MSG') ));
        htp.p( ' ' );
        if c1rec.stock_less_purch = 'T'
         then
          htp.formcheckbox('PSTCK_A','T','CHECKED');
         else
          htp.formcheckbox('PSTCK_A','T');
        end if;
        htp.p( LNG4.AHC_TXT_767 );
        htp.p( '</TD>' );
      htp.tablerowclose;
      htp.tablerowopen;
        htp.tabledata( htf.bold(LNG4.AHC_TXT_402),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( nvl(c1rec.product_class,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
      htp.tablerowopen;
        htp.tabledata( htf.bold(LNG.GLB_TXT_078),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( htf.italic( to_char(c1rec.date_created,LNG.TSMASK)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
      htp.tablerowopen;
        htp.tabledata( htf.bold(LNG2.FNM_TXT_011),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( htf.italic( to_char(c1rec.date_updated,LNG.TSMASK)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
      if c4rec.attached_doco is not null
       then
        htp.tablerowopen;
          htp.tabledata( htf.bold(LNG4.AHC_TXT_348),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
         htp.tabledata( htf.anchor2( c4rec.attached_doco, LNG4.AHC_TXT_348, ctarget=>'PRODUCT_DOCUMENTATION'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        htp.tablerowclose;
      end if;
    end if;
    htp.tableclose;
    htp.p( '</TD>');

    if c1rec.umo_id is not null
     then
      open c12(c1rec.manufacturer_id,c1rec.umo_id);
      fetch c12 into c12rec;
      close c12;
      htp.p( '<TD>');
       htp.p( htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=AID&parm2=' || c1rec.lab_id || '&parm1=LOGIN_TYPE&parm2=MANUFACTURER',
	   '<IMG BORDER=0 WIDTH=' || c12rec.wd || ' HEIGHT=' || c12rec.hg || ' SRC="' ||
	   'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c12rec.umo_id || '&parm1=AID&parm2=' || c1rec.lab_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=MANUFACTURER&parm1=VERSION&parm2=' || c12rec.version ||
	   '" ALT="' || LNG.CST_TXT_183 || '">',ctarget=>'PRICE_ITEM') );
      htp.p( '</TD>');
    end if;
    htp.tablerowclose;
    htp.tableclose;
    htp.line;
    htp.bold( LNG3.ADM_TXT_960 );
    htp.nl;
  else
   htp.formhidden( 'P6', null );
  end if;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
  htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );

  -- Display Item Details
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.PBK_TXT_021),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext( 'P1',30,100, replace(c1rec.name,'"','&#34;')),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;

  if c13rec.brand_name is not null
   then
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG2.FNM_TXT_128),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( c13rec.brand_name, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
  end if;
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.PHG_TXT_481 || htf.nl || LNG.MONEY_FORMAT),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext( 'P2',30,100, ltrim(to_char(c1rec.charge,LNG.MONEY_FORMAT))),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  /*
  if substr(c11rec.theme_data,175,1) = 'T'
   then
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG4.AHC_TXT_239 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( htf.formtext( 'P2D',30,100, ltrim(to_char(c1rec.download_charge,LNG.MONEY_FORMAT))),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
  end if;
  */
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.PBK_TXT_023),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext( 'P3',30,100, replace(c1rec.phg_code,'"','&#34;')),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.GLB_TXT_055),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    tmp := htf.formcheckbox( 'P4', 'T', 'CHECKED' );
    if c1rec.enabled = 'F' then tmp := htf.formcheckbox( 'P4', 'T' ); end if;
    htp.tabledata( tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_612),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'PWK' );
    htp.formselectoption( NULL );
    for c16rec in c16( owner_id ) loop
     if c16rec.status_workflow = c1rec.status_workflow
      then
       htp.formselectoption( c16rec.workflow_name, 'SELECTED', cattributes=>'VALUE="' || c16rec.status_workflow || '"' );
      else
       htp.formselectoption( c16rec.workflow_name, cattributes=>'VALUE="' || c16rec.status_workflow || '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
  htp.tablerowclose;

  tot := 0;
  if pbit > 0
   then
    open c7(id);
    fetch c7 into tot;
    close c7;
  end if;

  if (tot = 1 and pbit = 0) or (pbit > 0 )
   then
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG2.PBK_TXT_024),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
      tmp := htf.formcheckbox( 'P9', 'T', 'CHECKED' );
      if nvl(c1rec.is_default,'F') = 'F' then tmp := htf.formcheckbox( 'P9', 'T' ); end if;
      htp.tabledata( tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   else
    htp.formhidden( 'P9','F');
  end if;

  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.LAB_TXT_014),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    tmp := prod_type( id, 'P10', c1rec.film_type );
    htp.tabledata( tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  if (substr(c11rec.theme_data,401,1) = 'T') -- Can Specify Download Objects
   then
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG4.AHC_TXT_912),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">');
      htp.formselectopen( 'PDWNA' );
      htp.formselectoption( NULL );
      for c18rec in c18( owner_id ) loop
       if c18rec.ppm_id = c1rec.lease_download_object
        then
         htp.formselectoption( c18rec.name || '-' || c18rec.ty, 'SELECTED', cattributes=>'VALUE="' || c18rec.ppm_id || '"');
        else
         htp.formselectoption( c18rec.name || '-' || c18rec.ty, cattributes=>'VALUE="' || c18rec.ppm_id || '"');
       end if;
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG4.AHC_TXT_913),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">');
      htp.formselectopen( 'PDWNB' );
      htp.formselectoption( NULL );
      for c19rec in c19( owner_id ) loop
       if c19rec.ppm_id = c1rec.limit_download_object
        then
         htp.formselectoption( c19rec.name || '-' || c19rec.ty, 'SELECTED', cattributes=>'VALUE="' || c19rec.ppm_id || '"');
        else
         htp.formselectoption( c19rec.name || '-' || c19rec.ty, cattributes=>'VALUE="' || c19rec.ppm_id || '"');
       end if;
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
    htp.tablerowclose;
   else
    htp.formhidden( 'PDWNA', NULL );
    htp.formhidden( 'PDWNB', NULL );
  end if;
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.CST_TXT_051),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtextareaopen( 'P5',5,20, cattributes=>'WRAP="VIRTUAL"' ) || c1rec.comments || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.tableclose;

  htp.p( '</TD>' );
  htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );

  -- Check if the Item can be marked as a Direct Shop Item
  if (substr(c11rec.theme_data,142,1) = 'T') and (c1rec.lab_id is not null)
   then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1');
     htp.tablerowopen;
      htp.tabledata( htf.bold('Type of Item'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      htp.formselectopen( 'PSA' );
       if c1rec.shop_item = 'F'
        then
         htp.formselectoption( 'Standard Item', 'SELECTED', cattributes=>'VALUE="' || 'F' || '"');
        else
         htp.formselectoption( 'Standard Item', cattributes=>'VALUE="' || 'F' || '"');
       end if;
       if c1rec.shop_item = 'T'
        then
         htp.formselectoption( 'Shopping Item', 'SELECTED', cattributes=>'VALUE="' || 'T' || '"');
        else
         htp.formselectoption( 'Shopping Item', cattributes=>'VALUE="' || 'T' || '"');
       end if;
       if c1rec.shop_item = 'P'
        then
         htp.formselectoption( 'Packaged Product', 'SELECTED', cattributes=>'VALUE="' || 'P' || '"');
        else
         htp.formselectoption( 'Packaged Product', cattributes=>'VALUE="' || 'P' || '"');
       end if;
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
     if c1rec.shop_item = 'T'
      then
       htp.tablerowopen;
        htp.tabledata( htf.bold(LNG3.ADM_TXT_961),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
        htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formselectopen( 'PSB' );
        if c1rec.shop_style = LNG2.FNM_TXT_108
         then
          htp.formselectoption( LNG2.FNM_TXT_108, 'SELECTED' );
         else
          htp.formselectoption( LNG2.FNM_TXT_108 );
        end if;
        if c1rec.shop_style = LNG2.FNM_TXT_109
         then
          htp.formselectoption( LNG2.FNM_TXT_109, 'SELECTED' );
         else
          htp.formselectoption( LNG2.FNM_TXT_109 );
        end if;
        if c1rec.shop_style = LNG4.AHC_TXT_077
         then
          htp.formselectoption( LNG4.AHC_TXT_077, 'SELECTED' );
         else
          htp.formselectoption( LNG4.AHC_TXT_077 );
        end if;
        htp.formselectclose;
        htp.p( '</TD>' );
       htp.tablerowclose;
     elsif c1rec.shop_item = 'T'
      then
       htp.formhidden( 'PSB', c1rec.shop_style );
     elsif c1rec.shop_item = 'P'
      then
       htp.tablerowopen;
        htp.tabledata( htf.formhidden( 'PSB', c1rec.shop_style ) || htf.bold('Package Specification'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( htf.anchor2('pbk.package_details?surl=' || surl || '&id=' || id || '&pbit=' || pbit, 'Edit Details', ctarget=>'PACKAGE_PRODUCT'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
       htp.tablerowclose;
     end if;
    htp.tableclose;
  elsif substr(c11rec.theme_data,142,1) = 'T'
   then
    htp.bold( LNG2.FNM_TXT_107 );
    htp.nl;
      htp.formselectopen( 'PSA' );
       if c1rec.shop_item = 'F'
        then
         htp.formselectoption( 'Standard Item', 'SELECTED', cattributes=>'VALUE="' || 'F' || '"');
        else
         htp.formselectoption( 'Standard Item', cattributes=>'VALUE="' || 'F' || '"');
       end if;
       if c1rec.shop_item = 'P'
        then
         htp.formselectoption( 'Packaged Product', 'SELECTED', cattributes=>'VALUE="' || 'P' || '"');
        else
         htp.formselectoption( 'Packaged Product', cattributes=>'VALUE="' || 'P' || '"');
       end if;
      htp.formselectclose;
      if c1rec.shop_item = 'P'
       then
        htp.nl;
        htp.anchor2('pbk.package_details?surl=' || surl || '&id=' || id || '&pbit=' || pbit, 'Edit Details', ctarget=>'PACKAGE_PRODUCT');
      end if;
   else
      htp.formselectopen( 'PSA' );
       if c1rec.shop_item = 'F'
        then
         htp.formselectoption( 'Standard Item', 'SELECTED', cattributes=>'VALUE="' || 'F' || '"');
        else
         htp.formselectoption( 'Standard Item', cattributes=>'VALUE="' || 'F' || '"');
       end if;
       if c1rec.shop_item = 'P'
        then
         htp.formselectoption( 'Packaged Product', 'SELECTED', cattributes=>'VALUE="' || 'P' || '"');
        else
         htp.formselectoption( 'Packaged Product', cattributes=>'VALUE="' || 'P' || '"');
       end if;
      htp.formselectclose;
      if c1rec.shop_item = 'P'
       then
        htp.nl;
        htp.anchor2('pbk.package_details?surl=' || surl || '&id=' || id || '&pbit=' || pbit, 'Edit Details', ctarget=>'PACKAGE_PRODUCT');
      end if;
  end if;

  -- Delivery Time, Production Time and Surcharge
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1');
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_763),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext( 'PDL_L', 10, 30, c1rec.delivery_time_local ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_790),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext( 'PDL_I', 10, 30, c1rec.delivery_time_int ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_791),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext( 'PDL_DESC', 30, 1000, c1rec.delivery_desc ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_764) || ' ' || LNG3.ADM_TXT_668,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext( 'PPRD', 10, 30, c1rec.production_time ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_792),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext( 'PPRD_DESC', 30, 1000, c1rec.product_desc ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_771),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext( 'PSR_L', 10, 30, c1rec.surcharge_local ) || '%',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_789),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext( 'PSR_I', 10, 30, c1rec.surcharge_int ) || '%',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   if c14rec.tot = 0
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_402),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">');
     htp.formselectopen( 'PCLASS' );
     for c17rec in c17 loop
      if c17rec.product_class = c1rec.product_class
       then
        htp.formselectoption( c17rec.product_class, 'SELECTED' );
       else
        htp.formselectoption( c17rec.product_class );
      end if;
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
    htp.tablerowclose;
   else
    htp.formhidden( 'PCLASS', c1rec.product_class );
   end if;
  htp.tableclose;

  htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tableclose;

  -- Item is Discounted
  htp.line;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
  htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );

  htp.bold( LNG4.AHC_TXT_795 );
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1');
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_796),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    if c1rec.item_discounted = 'T'
     then
      htp.tabledata( htf.formcheckbox('PITM_1','T','CHECKED'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     else
      htp.tabledata( htf.formcheckbox('PITM_1','T'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_797 || htf.nl || LNG.MONEY_FORMAT),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext( 'PITM_2',30,100, ltrim(to_char(c1rec.item_disc_charge,LNG.MONEY_FORMAT))),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_798 || htf.nl || LNG.MASK),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext( 'PITM_3',20,20, to_char(c1rec.item_disc_from,LNG.MASK)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_799 || htf.nl || LNG.MASK),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext( 'PITM_4',20,20, to_char(c1rec.item_disc_to,LNG.MASK)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
  htp.tableclose;

  htp.p( '</TD>' );
  if substr(theme_rec.theme_data,89,1) = 'T'
   then
    htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );

    htp.bold( LNG4.AHC_TXT_800 );
    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1');
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG4.AHC_TXT_769),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
      htp.tabledata( htf.bold(LNG4.AHC_TXT_770),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
     for c15rec in c15( pbit ) loop
      htp.tablerowopen;
       htp.formhidden( 'PMT0', c15rec.attribute_id );
       htp.tabledata( htf.formtext( 'PMT1',20, 100, c15rec.sub_category ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata( htf.formtext( 'PMT2',20, 4000, c15rec.value ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
     end loop;
     for j in 1..3 loop
      htp.tablerowopen;
       htp.formhidden( 'PMT0', null );
       htp.tabledata( htf.formtext( 'PMT1',20, 100, null ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata( htf.formtext( 'PMT2',20, 4000, null ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
     end loop;
    htp.tableclose;

    htp.p( '</TD>' );
   else
    htp.formhidden( 'PMT0', NULL );
    htp.formhidden( 'PMT1', NULL );
    htp.formhidden( 'PMT2', NULL );
  end if;

  htp.tablerowclose;
  htp.tableclose;

  -- Exclusive Release Offer
  if substr(c11rec.theme_data,414,1) = 'T'
   then
    htp.line;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
    htp.tablerowopen;
    htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
    htp.bold( LNG5.EXT_TXT_024 );
    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1');

     htp.tablerowopen;
      htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
      htp.tabledata( htf.bold(LNG3.ADM_TXT_668),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
      htp.tabledata( htf.bold(LNG3.ADM_TXT_669),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
      htp.tabledata( htf.bold(LNG5.EXT_TXT_025),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG5.EXT_TXT_026),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
      tme := (((c1rec.exclusive_local - mod(mod(c1rec.exclusive_local,60*24),60)) /60) -
              mod( ((c1rec.exclusive_local - mod(mod(c1rec.exclusive_local,60*24),60)) /60),24)) / 24;
      htp.p( '<TD ' || pfx.qbground || 'valign="TOP" align="LEFT">');
      htp.formselectopen( 'TM1' );
      for j in 0..100 loop
       if j = tme
        then
         htp.formselectoption( to_char(j),'SELECTED' );
        else
         htp.formselectoption( to_char(j) );
       end if;
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
      tme := mod( ((c1rec.exclusive_local - mod(mod(c1rec.exclusive_local,60*24),60)) /60),24);
      htp.p( '<TD ' ||pfx.qbground || 'valign="TOP" align="LEFT">');
      htp.formselectopen( 'TM2' );
      for j in 0..23 loop
       if j = tme
        then
         htp.formselectoption( to_char(j),'SELECTED' );
        else
         htp.formselectoption( to_char(j) );
       end if;
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
      tme := mod(mod(c1rec.exclusive_local,60*24),60);
      htp.p( '<TD ' ||pfx.qbground || 'valign="TOP" align="LEFT">');
      htp.formselectopen( 'TM3' );
      for j in 0..59 loop
       if j = tme
        then
         htp.formselectoption( to_char(j),'SELECTED' );
        else
         htp.formselectoption( to_char(j) );
       end if;
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG5.EXT_TXT_027),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
      tme := (((c1rec.exclusive_int - mod(mod(c1rec.exclusive_int,60*24),60)) /60) -
              mod( ((c1rec.exclusive_int - mod(mod(c1rec.exclusive_int,60*24),60)) /60),24)) / 24;
      htp.p( '<TD ' ||pfx.qbground || 'valign="TOP" align="LEFT">');
      htp.formselectopen( 'ITM1' );
      for j in 0..100 loop
       if j = tme
        then
         htp.formselectoption( to_char(j),'SELECTED' );
        else
         htp.formselectoption( to_char(j) );
       end if;
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
      tme := mod( ((c1rec.exclusive_int - mod(mod(c1rec.exclusive_int,60*24),60)) /60),24);
      htp.p( '<TD ' ||pfx.qbground || 'valign="TOP" align="LEFT">');
      htp.formselectopen( 'ITM2' );
      for j in 0..23 loop
       if j = tme
        then
         htp.formselectoption( to_char(j),'SELECTED' );
        else
         htp.formselectoption( to_char(j) );
       end if;
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
      tme := mod(mod(c1rec.exclusive_int,60*24),60);
      htp.p( '<TD ' ||pfx.qbground || 'valign="TOP" align="LEFT">');
      htp.formselectopen( 'ITM3' );
      for j in 0..59 loop
       if j = tme
        then
         htp.formselectoption( to_char(j),'SELECTED' );
        else
         htp.formselectoption( to_char(j) );
       end if;
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;

    htp.p( '</TD>' );

    htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
    htp.bold( LNG5.EXT_TXT_028 );
    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1');
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG5.EXT_TXT_029),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
      htp.tabledata( htf.bold(LNG5.EXT_TXT_030),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
      htp.tabledata( htf.bold(LNG.PHG_TXT_465),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
    for c20rec in c20( pbit ) loop
     htp.tablerowopen;
      htp.tabledata( htf.formtext( 'RY1', 20, 100, c20rec.name ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata( htf.formtext( 'RY2', 10, 20, to_char(nvl(c20rec.percentage,0)) ) || '%',cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata( htf.formtext( 'RY3', 40, 4000, c20rec.extra_details ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
    end loop;
    for j in 1..2 loop
     htp.tablerowopen;
      htp.tabledata( htf.formtext( 'RY1', 20, 100, null ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata( htf.formtext( 'RY2', 10, 20, null ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata( htf.formtext( 'RY3', 40, 4000, null ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
    end loop;
    htp.tableclose;
    htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tableclose;
   else
    htp.formhidden( 'TM1', null );
    htp.formhidden( 'TM2', null );
    htp.formhidden( 'TM3', null );
    htp.formhidden( 'ITM1', null );
    htp.formhidden( 'ITM2', null );
    htp.formhidden( 'ITM3', null );
    htp.formhidden( 'RY1', null );
    htp.formhidden( 'RY2', null );
    htp.formhidden( 'RY3', null );
  end if;

  -- Minimum and Maximum Quantity
  htp.line;
  htp.bold( LNG2.PBK_TXT_047 );
  htp.nl;
  htp.italic( LNG2.PBK_TXT_048 );
  htp.nl;
  htp.italic( LNG2.PBK_TXT_049 );
  htp.nl;
  htp.italic( LNG2.PBK_TXT_050 );
  htp.nl;
  htp.italic( LNG2.PBK_TXT_051 );
  htp.nl;
  htp.italic( LNG2.PBK_TXT_052 );
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1');
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.PBK_TXT_044),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext('P11A',10,20,c1rec.min_qty),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.PBK_TXT_045),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext('P11B',10,20,c1rec.max_qty),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
  htp.tableclose;

  htp.line;
  if pbit = 0
   then
    htp.formsubmit( 'ACTION', LNG2.PBK_TXT_030 );
  elsif nvl(pbit,0) > 0
   then
    htp.tableopen;
     htp.tablerowopen(cattributes=>'cellpadding=2 cellspacing=2 border=0');
      htp.tabledata(htf.formsubmit( 'ACTION', LNG2.PBK_TXT_031 ) || htf.formclose);
      htp.tabledata(htf.formopen('pbk.accept_modify',ctarget=>'PHG_BOTTOM', cattributes=>'name="form2"' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ID',id) || htf.formhidden('PBIT',pbit) ||
       htf.formhidden( 'P1', null ) || htf.formhidden( 'P2', null ) || htf.formhidden( 'P3', null ) || htf.formhidden( 'P4', null ) || htf.formhidden( 'P5', null ) ||
       htf.formhidden( 'P6', null ) || htf.formhidden( 'P9', null ) || htf.formhidden( 'P10', null ) ||
       htf.formhidden( 'P11a', null ) || htf.formhidden( 'P11b', null ) || htf.formhidden( 'PCLASS', null ) || htf.formhidden( 'PDL_L', null ) || htf.formhidden( 'PDL_I', null ) || htf.formhidden( 'PDL_DESC', null ) ||
       htf.formhidden( 'PPRD', null ) || htf.formhidden( 'PPRD_DESC', null ) || htf.formhidden( 'PSR_L', null ) || htf.formhidden( 'PSR_I', null ) || htf.formhidden( 'PMT0', null ) || htf.formhidden( 'PMT1', null ) || htf.formhidden( 'PMT2', null ) ||
       htf.formhidden( 'TM1', null ) || htf.formhidden( 'TM2', null ) || htf.formhidden( 'TM3', null ) || htf.formhidden( 'ITM1', null ) || htf.formhidden( 'ITM2', null ) || htf.formhidden( 'ITM3', null ) ||
       htf.formhidden( 'RY1', null ) || htf.formhidden( 'RY2', null ) || htf.formhidden( 'RY3', null ) ||
       htf.formsubmit( 'ACTION', LNG2.PBK_TXT_032 ) || '&nbsp;' || htf.formsubmit( 'ACTION', LNG2.PBK_TXT_018 ) || htf.formclose);
     htp.tablerowclose;
    htp.tableclose;
  end if;
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'MODIFY_ITEM',errmsg=>sqlerrm);
end modify_item;

procedure accept_modify(surl in varchar2, id in integer, pbit in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 DEFAULT 'F', p5 in varchar2, p6 in varchar2, p9 in varchar2 DEFAULT 'F',
                        pmfct1 in varchar2 default null, pdl_l in varchar2, pdl_i in varchar2, pdl_desc in varchar2, pprd in varchar2, pprd_desc in varchar2, psr_l in varchar2, psr_i in varchar2, tm1 in varchar2, tm2 in varchar2, tm3 in varchar2, itm1 in varchar2, itm2 in varchar2, itm3 in varchar2,
                        pstk in varchar2 default null, pstk_msg in varchar2 default null, pstck_a in char default 'F', pitm_1 in char default 'F', pitm_2 in varchar2 default null, pitm_3 in varchar2 default null, pitm_4 in varchar2 default null,
                        p10 in varchar2, p11a in varchar2, p11b in varchar2, psa in varchar2 default 'F', psb in varchar2 default null, pclass in varchar2, action in varchar2, pwk in varchar2 default null, pdwna in varchar2 default null, pdwnb in varchar2 default null,
                        pmt0 in GLBX.MYARRAY, pmt1 in GLBX.MYARRAY, pmt2 in GLBX.MYARRAY, ry1 in GLBX.MYARRAY, ry2 in GLBX.MYARRAY, ry3 in GLBX.MYARRAY, booktot in integer default null)
as

 cursor c1(prodid integer) is select manufacturer_id,product_id,umo_id,name,product_class,manufctr_code from product where product_id = prodid;
 cursor c3(id integer, ftype varchar2) is select count('x') tot from phg_price_item where spb = id and film_type = ftype and is_default = 'T';
 cursor c4(subcat varchar2) is select attribute_id from umo_attributes where sub_category = upper(subcat);

 c1rec		c1%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 newid		integer;
 pfx		THEME%ROWTYPE;
 tmp		varchar2(10000);
 cm		varchar2(4000);
 mny		number;
 mny2		number;
 mny3		number;
 dt1		date;
 dt2		date;
 prodid		integer;
 nmb1		integer;
 nmb2		integer;
 nmb3		integer;
 nmb4		integer;
 nmb5		integer;
 nmb6		number;
 nmb7		number;
 nmb8		number;
 nmb9		number;
 nmb10		number;
 nmb11		number;
 nmb12		number;
 tmbl		number;
 tmbi		number;
 pnmb		number;
 tot		integer;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_MODIFY', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  if action = LNG2.PBK_TXT_018
   then
    edit_item(surl,id);
    return;
  end if;
  if action = LNG2.PBK_TXT_032
   then
    delete from phg_price_item where spb = id and ppi = pbit;
    commit;
    pbk.edit_item(surl,id);
    return;
  end if;
  cm := substr(p5,1,4000);
  prodid := to_number(p6);
  open c1(prodid);
  fetch c1 into c1rec;
  close c1;

  begin nmb4 := to_number(p11a); exception when others then nmb4 := null; end;
  begin nmb5 := to_number(p11b); exception when others then nmb5 := null; end;
  begin nmb6 := to_number(pmfct1); exception when others then nmb6 := 0; end;
  if nmb6 < 0 or nmb6 > 100 then nmb6 := 0; end if;
  begin nmb7 := to_number(pdl_l); exception when others then nmb7 := 0; end;
  if nmb7 < 0 then nmb7 := 0; end if;
  begin nmb8 := to_number(pdl_i); exception when others then nmb8 := 0; end;
  if nmb8 < 0 then nmb8 := 0; end if;
  begin nmb9 := to_number(pprd); exception when others then nmb9 := 0; end;
  if nmb9 < 0 then nmb9 := 0; end if;
  begin nmb10 := to_number(psr_l); exception when others then nmb10 := 0; end;
  if nmb10 < 0 or nmb10 > 100 then nmb10 := 0; end if;
  begin nmb11 := to_number(psr_i); exception when others then nmb11 := 0; end;
  if nmb11 < 0 or nmb11 > 100 then nmb11 := 0; end if;
  begin nmb12 := to_number(pstk); exception when others then nmb12 := 0; end;
  if nmb12 < 0 then nmb12:= 0; end if;
  begin dt1 := to_date(pitm_3,LNG.MASK); exception when others then dt1 := NULL; end;
  begin dt2 := to_date(pitm_4,LNG.MASK); exception when others then dt2 := NULL; end;
  begin tmbl := (tm1*24*60) + (tm2 * 60) + tm3; exception when others then tmbl := NULL; end;
  begin tmbi := (itm1*24*60) + (itm2 * 60) + itm3; exception when others then tmbi := NULL; end;

  mny := glbx.conv_nmb(nvl(p2,'0'));
  if pitm_2 is not null
   then
    mny3 := glbx.conv_nmb(nvl(pitm_2,'0'));
  end if;

  if (nmb4 is not null) and (nmb5 is not null) and (nmb4 > nmb5) then nmb4 := NULL; end if;
  if pbit = 0
   then
    select s_phg_price_item.nextval into newid from dual;
    insert into phg_price_item(ppi,spb,charge,name,phg_code,lab_id,manufacturer_id,date_created,date_updated,enabled,comments,is_default,film_type,min_qty,max_qty,shop_item,shop_style,umo_id,auto_increase_perc,
                               delivery_time_local,delivery_time_int,production_time,surcharge_local,surcharge_int,stock_less_than_value,stock_less_than_desc,stock_less_purch,
                               item_discounted,item_disc_charge,item_disc_from,item_disc_to,delivery_desc,product_desc,status_workflow,product_class,lease_download_object,limit_download_object,exclusive_local,exclusive_int) values
     (newid,id,mny,nvl(nvl(p1,c1rec.name),LNG.CST_TXT_007),nvl(p3,c1rec.manufctr_code),c1rec.product_id,c1rec.manufacturer_id,sysdate,sysdate,p4,cm,p9,p10,nmb4,nmb5,psa,psb,c1rec.umo_id,nmb6,
      nmb7,nmb8,nmb9,nmb10,nmb11,nmb12,pstk_msg,pstck_a,pitm_1,mny3,dt1,dt2,pdl_desc,pprd_desc,pwk,nvl(pclass,c1rec.product_class),pdwna,pdwnb,tmbl,tmbi);
   else
    newid := pbit;
    update phg_price_item
     set
      charge = mny,
      name = nvl(p1,LNG.CST_TXT_007),
      phg_code = p3,
      lab_id = c1rec.product_id,
      manufacturer_id = c1rec.manufacturer_id,
      date_updated = sysdate,
      enabled = p4,
      is_default = decode(psa,'T','F',p9),
      film_type = p10,
      min_qty = nmb4,
      max_qty = nmb5,
      comments = cm,
      shop_item = psa,
      shop_style = psb,
      umo_id = c1rec.umo_id,
      auto_increase_perc = nmb6,
      delivery_time_local = nmb7,
      delivery_time_int = nmb8,
      delivery_desc = pdl_desc,
      product_desc = pprd_desc,
      production_time = nmb9,
      surcharge_local = nmb10,
      surcharge_int = nmb11,
      stock_less_than_value = nmb12,
      stock_less_than_desc = pstk_msg,
      stock_less_purch = pstck_a,
      item_discounted = pitm_1,
      item_disc_charge = mny3,
      item_disc_from = dt1,
      item_disc_to = dt2,
      status_workflow = pwk,
      product_class = nvl(pclass,c1rec.product_class),
      lease_download_object = pdwna,
      limit_download_object = pdwnb,
      exclusive_local = tmbl,
      exclusive_int = tmbi
    where ppi = pbit and
          spb = id and
          spb in (select spb from phg_price_book where pid = owner_id and spb = id);
  end if;

  delete from phg_price_item_display where ppi = pbit;
  for j in pmt0.first..pmt0.last loop
   if pmt0(j) is null and pmt1(j) is not null
    then
     open c4(pmt1(j));
     fetch c4 into c4rec;
     if c4%FOUND
      then
       close c4;
       insert into phg_price_item_display(ppi,attribute_id,value) values ( pbit, c4rec.attribute_id, pmt2(j) );
      else
       close c4;
     end if;
   elsif pmt0(j) is not null and pmt1(j) is not null
    then
     insert into phg_price_item_display(ppi,attribute_id,value) values ( pbit, pmt0(j), pmt2(j) );
   end if;
  end loop;

  delete from phg_price_item_royalty where ppi = pbit;
  for j in ry1.first..ry1.last loop
   begin pnmb := to_number(ry2(j)); exception when others then pnmb := NULL; end;
   if pnmb < 0 then pnmb := 0;	 end if;
   if pnmb > 100 then pnmb := 100; end if;
   if ry1(j) is not null and ry2(j) is not null
    then
     insert into phg_price_item_royalty(ppi,name,percentage,extra_details) values ( pbit, ry1(j), pnmb, ry3(j) );
   end if;
  end loop;

  if p9 = 'T'
   then
    update phg_price_item set is_default = 'F' where spb = id and film_type = p10 and ppi <> newid;
  end if;

  tot := 0;
  open c3(id,p10);
  fetch c3 into tot;
  close c3;
  if (tot = 0) -- There is no default value currently set
   then
    update phg_price_item set is_default = 'T' where spb = id and ppi = newid and shop_item = 'F';
    if sql%NOTFOUND
     then
      update phg_price_item set is_default = 'T' where spb = id and ppi in (select ppi from phg_price_item where spb = id and shop_item = 'F' and rownum < 2);
      if sql%NOTFOUND
       then
        update phg_price_item set is_default = 'T' where spb = id and ppi = newid;
      end if;
    end if;
  end if;
  commit;

  if pbit = 0
   then
    edit_item(surl,id);
   else
    modify_item(surl,id,pbit,LNG2.PBK_TXT_033, booktot=>booktot);
  end if;

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_MODIFY',errmsg=>sqlerrm);
end accept_modify;

procedure report( surl varchar2,id in integer )
as

 cursor c1( phgid integer ) is
  select po.poid,po.pid,ls.aid,po.date_created,po.other_cost
  from login_session ls,purchase_order po
  where po.pid = phgid and
        ls.sessid = po.sessid and
        payment_received = 'T'
  order by po.date_created;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 disc_perc	number;
 disc_if	number;
 ttl		number;
 gtl		number;
 gst		number;
 vgst		number;
 lst_year	varchar2(10);
 lst_month	varchar2(10);
 tot_gst	number;
 tot_value	number;
 tot_orders	number;
 gtot_gst	number;
 gtot_value	number;
 gtot_orders	number;

 begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.REPORT', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  if id = 1
   then
    glbx.main_title( surl, LNG.ORD_TXT_004,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B03',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  elsif id = 2
   then
    glbx.main_title( surl, LNG2.PBK_TXT_014,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B03',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  elsif id = 3
   then
    glbx.main_title( surl, LNG2.PBK_TXT_015,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B03',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  end if;
  htp.p( '<CENTER>' );
  htp.nl;
  if id = 1
   then
    htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1');
    htp.tablerowopen;
     htp.tableheader( LNG2.PBK_TXT_034,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     htp.tableheader( LNG2.PBK_TXT_035,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     htp.tableheader( LNG2.PBK_TXT_036,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     htp.tableheader( LNG.LAB_TXT_016,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     htp.tableheader( LNG.CST_TXT_138,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
    lst_year := NULL;
    lst_month := NULL;
    tot_orders := 0;
    tot_gst := 0;
    tot_value := 0;
    tot_orders := 0;
    gtot_gst := 0;
    gtot_value := 0;
    gtot_orders := 0;
    for c1rec in c1(owner_id) loop
       ttl := glbx.total_payment(c1rec.poid);
       gtl := glbx.grand_total_payment( c1rec.poid, include_gift_certificate=>FALSE );
       if nvl(c1rec.other_cost,0) = 0
        then
         gst := 0;
        else
         gst := gtl - (gtl/c1rec.other_cost);
       end if;

       if (to_char(c1rec.date_created,'MON') <> lst_month) and (lst_month is not null)
        then
         htp.tablerowopen;
          htp.tabledata( lst_year,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          htp.tabledata( lst_month,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          htp.tabledata( to_char(nvl(tot_orders,0)) ,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          htp.tabledata( to_char(nvl(tot_gst,0), LNG.MONEY_FORMAT ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          htp.tabledata( to_char(nvl(tot_value,0), LNG.MONEY_FORMAT ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         htp.tablerowclose;
         gtot_gst := gtot_gst + nvl(tot_gst,0);
         gtot_value := gtot_value + nvl(tot_value,0);
         gtot_orders := gtot_orders + nvl(tot_orders,0);
         tot_gst := gst;
         tot_value := gtl;
         tot_orders := 1;
        else
         tot_gst := tot_gst + nvl(gst,0);
         tot_value := tot_value + nvl(gtl,0);
         tot_orders := tot_orders + 1;
       end if;
       lst_month := to_char(c1rec.date_created,'MON');
       lst_year := to_char(c1rec.date_created,'YYYY');
    end loop;
    gtot_gst := gtot_gst + tot_gst;
    gtot_value := gtot_value + tot_value;
    gtot_orders := gtot_orders + tot_orders;
    htp.tablerowopen;
      htp.tabledata( lst_year,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( lst_month,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( to_char(tot_orders) ,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( to_char(tot_gst, LNG.MONEY_FORMAT ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( to_char(tot_value, LNG.MONEY_FORMAT ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold('Grand'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( htf.bold(LNG.CST_TXT_138),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( htf.bold(to_char(gtot_orders)) ,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( htf.bold(to_char(gtot_gst, LNG.MONEY_FORMAT )),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( htf.bold(to_char(gtot_value, LNG.MONEY_FORMAT )),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
    htp.tableclose;
  end if;

  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'REPORT',errmsg=>sqlerrm);
end report;

function  get_theme_types(acid in integer, ltype in varchar2 default null)
 return theme_types%ROWTYPE
as
 cursor c1(acid integer) is select * from theme_types tt where theme_type = (select theme_type from customer_account where aid=acid);
 cursor c2(phgid integer) is select * from theme_types tt where theme_type = (select theme_type from photographer where pid=phgid);
 c1rec  c1%ROWTYPE;
begin
 if ltype is null
  then
   open c1(acid);
   fetch c1 into c1rec;
   close c1;
   return( c1rec );
  else
   open c2(acid);
   fetch c2 into c1rec;
   close c2;
   return( c1rec );
 end if;
exception when others then
 glbx.error_details( 'PHG', 'GET_THEME_TYPES',errmsg=>sqlerrm,extdet=>'ACID:' || acid);
end get_theme_types;

procedure mng_warranty( surl varchar2, msg in varchar2 default null)
as

 cursor c1(phgid integer) is select * from warranty where pid = phgid order by warranty_name desc;

 c2rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PBK.MNG_WARRANTY', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 pfx := glbx.photo_lf(owner_id);
 glbx.main_title( surl, LNG2.FNM_TXT_058,glbx.backimg(surl,owner_id,pfx.text_back,null),'B04',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.FNM_TXT_059 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG2.FNM_TXT_060 ),cattributes=>pfx.qbground );
  htp.tablerowclose;
 htp.formopen( 'pbk.accept_warranty' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 for c1rec in c1( owner_id ) loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1', 20, 100, c1rec.warranty_name ),cattributes=>pfx.qcbground );
   htp.tabledata( htf.formtext( 'P2', 20, 100, c1rec.warranty_html_page),cattributes=>pfx.qcbground );
   htp.formhidden( 'P0', c1rec.warranty_id );
  htp.tablerowclose;
 end loop;
 for j in 1..5 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1', 20, 100, null ),cattributes=>pfx.qcbground );
   htp.tabledata( htf.formtext( 'P2', 20, 100, null),cattributes=>pfx.qcbground );
   htp.formhidden( 'P0', null );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG2.FNM_TXT_068 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'MNG_WARRANTY',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end mng_warranty;

procedure accept_warranty( surl in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_WARRANTY', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 for j in p0.first..p0.last loop
  if p0(j) is null
   then
    if p1(j) is not null
     then
      insert into warranty(warranty_id,pid,warranty_name,warranty_html_page) values (s_warranty.nextval,owner_id,p1(j),p2(j) );
    end if;
  elsif p0(j) is not null
   then
   if p1(j) is not null
    then
     update warranty set warranty_name = p1(j), warranty_html_page = p2(j) where warranty_id = p0(j) and pid = owner_id;
    else
     update mfctr_clearance set warranty_id = null where warranty_id = p0(j);
     delete from warranty where warranty_id = p0(j) and pid = owner_id;
   end if;
  end if;
 end loop;
 commit;

 mng_warranty( surl, LNG2.FNM_TXT_067 );

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_WARRANTY',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end accept_warranty;

procedure mng_clearance( surl varchar2, msg in varchar2 default null)
as

 cursor c1( phgid integer ) is
  select mc.mfc_clr_id,mf.manufacturer_id,mfc_description,display_description,mc.dump_date,mc.expiry_date, mf.name
  from mfctr_clearance mc, mfctr_target_phg mtp, manufacturer mf
  where mc.mfc_clr_id = mtp.mfc_clr_id and
        mtp.pid = phgid and
        mf.manufacturer_id = mc.manufacturer_id
  order by nvl(dump_date,expiry_date) desc;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PBK.MNG_CLEARANCE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 pfx := glbx.photo_lf(owner_id);
 glbx.main_title( surl, LNG2.FNM_TXT_052,glbx.backimg(surl,owner_id,pfx.text_back,null),'B05',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.LAB_TXT_009 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG3.ADM_TXT_105 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG2.FNM_TXT_053 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG.PHG_TXT_079 ),cattributes=>pfx.qbground );
  htp.tablerowclose;
 for c1rec in c1( owner_id ) loop
  htp.tablerowopen;
   htp.tabledata( c1rec.name,cattributes=>pfx.qcbground );
   if sysdate > nvl(c1rec.dump_date,c1rec.expiry_date)
    then
     htp.tabledata(  htf.anchor( 'pbk.edit_clearance?surl=' || glbx.rndsurl(surl) || '&mcid=' || c1rec.mfc_clr_id, nvl(c1rec.display_description,c1rec.mfc_description) || ' [' || LNG3.ADM_TXT_709 || ']' || htf.nl || c1rec.mfc_description),cattributes=>pfx.qcbground );
    else
     htp.tabledata( htf.anchor( 'pbk.edit_clearance?surl=' || glbx.rndsurl(surl) || '&mcid=' || c1rec.mfc_clr_id, nvl(c1rec.display_description,c1rec.mfc_description) )|| htf.nl || c1rec.mfc_description,cattributes=>pfx.qcbground );
   end if;
   htp.tabledata( to_char( c1rec.expiry_date,LNG.MASK) || htf.nl || htf.italic(to_char( c1rec.dump_date,LNG.MASK)) ,cattributes=>pfx.qcbground );
   htp.tabledata( htf.anchor( 'pbk.mng_clearance_order?surl=' || glbx.rndsurl(surl) || '&mcid=' || c1rec.mfc_clr_id,LNG.PHG_ALT_128),cattributes=>pfx.qcbground );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'MNG_CLEARANCE',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end mng_clearance;

procedure edit_clearance( surl varchar2, mcid in integer, msg in varchar2 default null)
as

 cursor c1( phgid integer, mfcid integer) is select * from mfctr_clearance where mfc_clr_id = mfcid and mfc_clr_id in (select mfc_clr_id from mfctr_target_phg where pid = phgid and mfc_clr_id = mfcid);
 cursor c2( mfid integer ) is select * from manufacturer where manufacturer_id = mfid;
 cursor c3( intid integer, mid integer ) is select interest_id from mfctr_interest_group where mfc_clr_id = mid and interest_id = intid;
 cursor c4 is select interest_id,interest_name from interest_groups order by interest_name;
 cursor c5( phgid integer ) is select * from warranty where pid = phgid order by warranty_name;
 cursor c6(mfcid integer) is select * from mfctr_clearance_items where mfc_clr_id = mfcid order by min_amount;
 cursor c7(manid integer, v_umo varchar2) is
  select um.umo_id, um.audio_original.description, um.extras, um.version, um.photo_thumbnail.width wd, um.photo_thumbnail.height hg, um.umo_type
  from umo um
  where um.aid = manid and
        um.umo_type = 'MANUFACTURER' and
        umo_id = v_umo;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c7rec		c7%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PBK.LAB_EDIT_CLEARANCE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 pfx := glbx.photo_lf(owner_id);
 glbx.main_title( surl, LNG2.FNM_TXT_052,glbx.backimg(surl,owner_id,pfx.text_back,null),'B06',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null then glbx.header_msg(msg); else htp.nl; end if;
 htp.p( '<CENTER>' );
 htp.formopen( 'pbk.accept_edit_clearance' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'MCID', mcid );

 open c1(owner_id,mcid);
 fetch c1 into c1rec;
 close c1;
 open c2(c1rec.manufacturer_id);
 fetch c2 into c2rec;
 close c2;

 c1rec.expiry_date := nvl(c1rec.expiry_date,c1rec.dump_date);
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.LAB_TXT_009 ),cattributes=>pfx.qbground );
   htp.tabledata( c2rec.name,cattributes=>pfx.qcbground );
  htp.tablerowclose;
   if c1rec.product_doco is not null
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG4.AHC_TXT_348 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.anchor2( c1rec.product_doco, LNG4.AHC_TXT_348, ctarget=>'PRODUCT_DOCUMENTATION'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
   end if;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.FNM_TXT_070 ),cattributes=>pfx.qbground );
   htp.tabledata( c1rec.mfc_description,cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_105 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.formtext( 'P1', 30, 100, nvl(c1rec.display_description,c1rec.mfc_description)),cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.FNM_TXT_058 ),cattributes=>pfx.qbground );
   htp.p( '<TD ' || pfx.qcbground || '>' );
   htp.formselectopen( 'P4' );
   htp.formselectoption( NULL );
   for c5rec in c5(owner_id) loop
    if c5rec.warranty_id = c1rec.warranty_id
     then
      htp.formselectoption( c5rec.warranty_name, 'SELECTED', cattributes=>'VALUE="' || c5rec.warranty_id || '"' );
     else
      htp.formselectoption( c5rec.warranty_name, cattributes=>'VALUE="' || c5rec.warranty_id || '"' );
    end if;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.FNM_TXT_061 ),cattributes=>pfx.qbground );
   htp.tabledata( to_char(c1rec.dump_date,LNG.MASK),cattributes=>pfx.qcbground );
  htp.tablerowclose;
   htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.FNM_TXT_053),cattributes=>pfx.qbground );
   htp.p( '<TD ' || pfx.qcbground || '>' );
   htp.formselectopen( 'P2A' );
   for j in 1..31 loop
    if to_number(to_char(c1rec.expiry_date,'DD')) = j
     then
      htp.formselectoption( to_char(j), 'SELECTED' );
     else
      htp.formselectoption( to_char(j) );
    end if;
   end loop;
   htp.formselectclose;
   htp.formselectopen( 'P2B' );
   if to_number(to_char(c1rec.expiry_date,'MM')) = 1 then htp.formselectoption( LNG.LAB_TXT_073, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_073 ); end if;
   if to_number(to_char(c1rec.expiry_date,'MM')) = 2 then htp.formselectoption( LNG.LAB_TXT_074, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_074 ); end if;
   if to_number(to_char(c1rec.expiry_date,'MM')) = 3 then htp.formselectoption( LNG.LAB_TXT_075, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_075 ); end if;
   if to_number(to_char(c1rec.expiry_date,'MM')) = 4 then htp.formselectoption( LNG.LAB_TXT_076, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_076 ); end if;
   if to_number(to_char(c1rec.expiry_date,'MM')) = 5 then htp.formselectoption( LNG.LAB_TXT_077, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_077 ); end if;
   if to_number(to_char(c1rec.expiry_date,'MM')) = 6 then htp.formselectoption( LNG.LAB_TXT_078, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_078 ); end if;
   if to_number(to_char(c1rec.expiry_date,'MM')) = 7 then htp.formselectoption( LNG.LAB_TXT_079, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_079 ); end if;
   if to_number(to_char(c1rec.expiry_date,'MM')) = 8 then htp.formselectoption( LNG.LAB_TXT_080, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_080 ); end if;
   if to_number(to_char(c1rec.expiry_date,'MM')) = 9 then htp.formselectoption( LNG.LAB_TXT_081, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_081 ); end if;
   if to_number(to_char(c1rec.expiry_date,'MM')) = 10 then htp.formselectoption( LNG.LAB_TXT_082, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_082 ); end if;
   if to_number(to_char(c1rec.expiry_date,'MM')) = 11 then htp.formselectoption( LNG.LAB_TXT_083, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_083 ); end if;
   if to_number(to_char(c1rec.expiry_date,'MM')) = 12 then htp.formselectoption( LNG.LAB_TXT_084, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_084 ); end if;
   htp.formselectclose;
   htp.formselectopen( 'P2C' );
   for j in 2000..2010 loop
    if to_number(to_char(c1rec.expiry_date,'YYYY')) = j
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
   htp.tabledata( htf.bold( LNG2.FNM_TXT_062 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.formtextareaopen( 'P3', 5, 40 ) ||  c1rec.detailed_description || htf.formtextareaclose,cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.LAB_TXT_017 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.formtext( 'P5', 30, 100, nvl(to_char(c1rec.commission_rate),'0')),cattributes=>pfx.qcbground );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.FNM_TXT_071 ),cattributes=>pfx.qbground );
   if c1rec.contact_home_page = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P6A', 'T', 'CHECKED'), cattributes=>pfx.qcbground );
    else
     htp.tabledata( htf.formcheckbox( 'P6A', 'T'), cattributes=>pfx.qcbground );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.FNM_TXT_072 ),cattributes=>pfx.qbground );
   if c1rec.contact_email = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P6B', 'T', 'CHECKED'), cattributes=>pfx.qcbground );
    else
     htp.tabledata( htf.formcheckbox( 'P6B', 'T'), cattributes=>pfx.qcbground );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.FNM_TXT_073 ),cattributes=>pfx.qbground );
   if c1rec.contact_sms = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P6C', 'T', 'CHECKED'), cattributes=>pfx.qcbground );
    else
     htp.tabledata( htf.formcheckbox( 'P6C', 'T'), cattributes=>pfx.qcbground );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.FNM_TXT_074 ),cattributes=>pfx.qbground );
   if c1rec.contact_telesales = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P6D', 'T', 'CHECKED'), cattributes=>pfx.qcbground );
    else
     htp.tabledata( htf.formcheckbox( 'P6D', 'T'), cattributes=>pfx.qcbground );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.FNM_TXT_075 ),cattributes=>pfx.qbground );
   if c1rec.shipping_manual = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7A', 'T', 'CHECKED'), cattributes=>pfx.qcbground );
    else
     htp.tabledata( htf.formcheckbox( 'P7A', 'T'), cattributes=>pfx.qcbground );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.FNM_TXT_075 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.formtext( 'P7B', 20, 20, to_char(c1rec.shipping_charge,LNG.MONEY_FORMAT)),cattributes=>pfx.qcbground );
  htp.tablerowclose;
  if c1rec.umo_id is not null
   then
    open c7(c1rec.manufacturer_id,c1rec.umo_id);
    fetch c7 into c7rec;
    close c7;
    htp.tablerowopen;
     htp.tabledata( '&nbsp;',cattributes=>pfx.qbground );
     htp.tabledata( htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c7rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || c1rec.manufacturer_id || '&parm1=LOGIN_TYPE&parm2=MANUFACTURER',
	 '<IMG BORDER=0 WIDTH=' || c7rec.wd || ' HEIGHT=' || c7rec.hg || ' SRC="' ||
	 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c7rec.umo_id || '&parm1=AID&parm2=' || c1rec.manufacturer_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=MANUFACTURER&parm1=VERSION&parm2=' || c7rec.version ||
	 '" ALT="' || LNG.CST_TXT_183 || '">',ctarget=>'PHOTOGRAPHER_ITEM') );
    htp.tablerowclose;
   else
    htp.tablerowopen;
     htp.tabledata( '&nbsp;',cattributes=>pfx.qbground );
     htp.tabledata( LNG2.FNM_TXT_089,cattributes=>pfx.qcbground );
    htp.tablerowclose;
  end if;
 htp.tableclose;

 htp.nl;
 htp.nl;
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.FNM_TXT_079 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.formcheckbox( 'P7C', 'T', 'CHECKED'),cattributes=>pfx.qcbground );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=5 cellspacing=5 border=0' );
 htp.tablerowopen;
 htp.p( '<TD>' );
 htp.bold( LNG3.ADM_TXT_817 );
 htp.nl;
 htp.formhidden( 'P8', null );
 htp.formselectopen( 'P8', null, 5, cattributes=>'MULTIPLE' );
  for c4rec in c4 loop
   open c3(c4rec.interest_id,mcid);
   fetch c3 into c3rec;
   if c3%FOUND
    then
     htp.formselectoption( c4rec.interest_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.interest_id || '"' );
    else
     htp.formselectoption( c4rec.interest_name, cattributes=>'VALUE="' || c4rec.interest_id || '"' );
   end if;
   close c3;
  end loop;
 htp.formselectclose;
 htp.p( '</TD>' );
 htp.p( '<TD>' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.PBK_TXT_044 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG2.PBK_TXT_045 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG2.FNM_TXT_078 ),cattributes=>pfx.qbground );
  htp.tablerowclose;
 for c6rec in c6(mcid) loop
  htp.tablerowopen;
   htp.tabledata( c6rec.min_amount,cattributes=>pfx.qcbground );
   htp.tabledata( c6rec.max_amount,cattributes=>pfx.qcbground );
   htp.tabledata( to_char(round(c6rec.price_per_unit * ((nvl(c1rec.commission_rate,0)/100) + 1),2),LNG.MONEY_FORMAT),cattributes=>pfx.qcbground );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.formsubmit( 'ACTION', LNG2.FNM_TXT_057 );
 htp.formsubmit( 'ACTION', LNG2.FNM_TXT_064 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'LAB', 'EDIT_CLEARANCE',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end edit_clearance;

procedure accept_edit_clearance( surl in varchar2, mcid in integer, p1 in varchar2, p2a in varchar2, p2b in varchar2, p2c in varchar2, p3 in varchar2, p4 in integer, p5 in varchar2,
                                 p6a in varchar2 default 'F', p6b in varchar2 default 'F', p6c in varchar2 default 'F', p6d in varchar2 default 'F', p7a in varchar2 default 'F', p7c in varchar2 default 'F',
                                 p7b in varchar2, p8 in GLBX.MYARRAY, action in varchar2)
as

 cursor c5(phgid integer) is select * from photographer where pid = phgid;

 cursor c6(mcid integer) is
  select mc.display_description,mc.expiry_date,mc.warranty_id,mc.detailed_description,mc.shipping_manual,mc.shipping_charge, cc.aid, cc.login_type,mc.contact_email memail,mc.contact_sms, cc.contact_email ccemail, cc.contact_mobile
  from customer_contact cc, customer_interest ci, mfctr_interest_group mig, mfctr_clearance mc
       where cc.contact_id = ci.contact_id and
             ci.interest_id = mig.interest_id and
             mc.mfc_clr_id  = mig.mfc_clr_id and
             mc.expiry_date is not null and
             mc.expiry_date >= sysdate and
             mc.mfc_clr_id = mcid
  order by mc.expiry_date desc;

 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 edate		date;
 ltext		varchar2(4000);
 nmb		number;
 nmb2		number;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_EDIT_CLEARANCE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 if action = LNG2.FNM_TXT_064
  then
   mng_clearance(mcid);
   return;
 end if;

 edate := to_date(p2a || '-' || p2b || '-' || p2c, 'DD-MM-YYYY');
 ltext := glbx.censor(p3,4000);
 begin nmb := to_number(p5); exception when others then nmb := 0; end;
 nmb2 := glbx.conv_nmb(p7b);

 update mfctr_clearance
  set
   display_description = p1,
   expiry_date = edate,
   warranty_id =  p4,
   detailed_description = ltext,
   commission_rate = nmb,
   contact_home_page = p6a,
   contact_email = p6b,
   contact_sms = p6c,
   contact_telesales = p6d,
   shipping_manual = p7a,
   shipping_charge = nmb2
  where mfc_clr_id = mcid and exists (select 'x' from mfctr_target_phg where pid = owner_id and mfc_clr_id = mcid);

  delete from mfctr_interest_group where mfc_clr_id = mcid;
  for j in p8.first..p8.last loop
   if p8(j) is not null
    then
     insert into mfctr_interest_group(mfc_clr_id,interest_id) values (mcid,p8(j));
   end if;
  end loop;

 commit;

 if p7c = 'T'
  then
   open c5(owner_id);
   fetch c5 into c5rec;
   close c5;
   for c6rec in c6(mcid) loop
    if c6rec.memail = 'T' and c6rec.ccemail is not null
     then
      -- Send Email
      gcode(1) := 'PHOTOGRAPHER';
      gparam(1) := c5rec.business_name;
      gcode(2) := 'EXPIRY_DATE';
      gparam(2) := to_char(edate,LNG.TSMASK);
      gcode(3) := 'DESCRIPTION';
      gparam(3) := p1;
      gcode(4) := 'LONG DESCRIPTION';
      gparam(4) := ltext;
      gcode(5) := 'SIGNATURE';
      gparam(5) := glbx.extract_master_parameter('MAIL SIGNATURE');
      glbx.send( gcode, gparam, 'phg_clearance.tmp', p_to=>c6rec.ccemail, p_subj=>LNG2.FNM_TXT_080 || ':' || c5rec.business_name || ':' ||  p1, p_from=>nvl(c5rec.contact_email,glbx.extract_master_parameter('MAIL_FROM')),ltype=>ltype,own_id=>owner_id, scode=>'PC1',v_pid=>owner_id);
    end if;
    if c6rec.contact_sms = 'T' and c6rec.contact_mobile is not null
     then
      -- Send SMS Message
      gcode(1) := NULL;
      gparam(1) := NULL;
      glbx.send( gcode, gparam, null, p_to=>c6rec.contact_mobile || '@' || glbx.extract_master_parameter('SMS_SITE'),p_subj=>LNG2.FNM_TXT_080 || ':' || c5rec.business_name || ':' || p1,p_from=>nvl(c5rec.contact_email,glbx.extract_master_parameter('MAIL_FROM')),  is_sms=>TRUE,ltype=>ltype,own_id=>owner_id,v_pid=>owner_id);
    end if;
   end loop;
 end if;
 edit_clearance( surl, mcid, LNG2.FNM_TXT_063 );

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_EDIT_CLEARANCE',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end accept_edit_clearance;

procedure tender_list(surl varchar2, msg in varchar2 default null)
as

 cursor c2( phgid integer ) is
  select tender_id,t.date_locked,t.date_created,t.quote_reference,ca.account_name, ca.aid
  from tender t, customer_account ca
  where ca.aid = t.aid and
        ca.pid = phgid
  order by date_locked desc;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.TENDER_LIST', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG4.AHC_TXT_001, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'C19',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_002 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.PHG_TXT_164 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.ORD_TXT_153 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.GLB_TXT_078 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( '&nbsp;' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;
   for c2rec in c2( owner_id ) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'pbk.modify_tender_list?surl=' || glbx.rndsurl(surl) || '&acid=' || c2rec.aid || '&tid=' || c2rec.tender_id, c2rec.quote_reference), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( c2rec.account_name ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(c2rec.date_locked,LNG.MASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(c2rec.date_created,LNG.MASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    if c2rec.date_locked <= trunc(sysdate)
     then
      htp.tabledata( htf.bold( LNG4.AHC_TXT_019 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
   htp.tablerowclose;
   end loop;
   htp.tableclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;

exception when others then
 glbx.error_details( 'PBK', 'TENDER_LIST', errmsg=>sqlerrm);
end tender_list;

procedure modify_tender_list(surl varchar2, acid in integer, tid in varchar2, msg in varchar2 default null)
as

 cursor c2( acid integer, tid integer ) is select * from tender where aid = acid and tender_id = tid;
 cursor c3( phgid integer) is select * from warranty where pid = phgid order by warranty_name desc;
 cursor c4( acid integer, tid integer ) is select * from tender_item where tender_id = tid and tender_id = (select tender_id from tender where aid = acid and tender_id = tid) order by item_id;
 cursor c5( tid integer, itid integer ) is select price_per_unit,shipping,name from tender_mfctr_item tfi, manufacturer m where tender_id = tid and item_id = itid and successful_bid = 'T' and m.manufacturer_id = tfi.manufacturer_id;
 cursor c6( phgid integer ) is select * from warranty where pid = phgid order by warranty_name;
 cursor c7( tid integer ) is select manufacturer_id,notified from tender_mfctr where tender_id = tid;
 cursor c8 is select manufacturer_id,name,man_type from manufacturer order by name;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 ttl		number;
 ttls		number;
 ttls2		number;
 titem		number;
 tcomm		number;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MODIFY_TENDER_LIST', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  pfx := glbx.get_thm( c1rec.theme_name );
  if tid is null
   then
    glbx.main_title( surl, LNG4.AHC_TXT_005, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C19',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   else
    glbx.main_title( surl, LNG4.AHC_TXT_006, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C19',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  end if;
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;
  if tid is not null
   then
    open c2(acid, tid );
    fetch c2 into c2rec;
    close c2;
  end if;

  htp.formopen( 'pbk.accept_tender_list' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'TID', tid );
  htp.formhidden( 'ACID', acid );

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_002 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P1', 30, 100, c2rec.quote_reference ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.LAB_TXT_017 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P1C', 10, 30, c2rec.commission_rate ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.GLB_TXT_078 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( nvl(to_char( c2rec.date_created,LNG.MASK),'&nbsp;')),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_008 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( nvl(to_char( c2rec.date_updated,LNG.MASK),'&nbsp;')),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.ORD_TXT_153 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P2', 20, 40, to_char( c2rec.date_locked,LNG.MASK)) || ' ' || htf.italic( LNG.MASK || ' eg. 17-JAN-2002' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.CST_TXT_118 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P3', 10, 20, c2rec.postcode),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG2.FNM_TXT_087 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || '>' );
    htp.formselectopen( 'P4' );
    htp.formselectoption( NULL );
    for c6rec in c6(owner_id) loop
     if c6rec.warranty_id = c2rec.warranty_id
      then
       htp.formselectoption( c6rec.warranty_name, 'SELECTED', cattributes=>'VALUE="' || c6rec.warranty_id || '"' );
      else
       htp.formselectoption( c6rec.warranty_name, cattributes=>'VALUE="' || c6rec.warranty_id || '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_285 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtextareaopen( 'P3D', 5, 40 ) || c2rec.tender_details || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_009 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_074 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_349 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_011 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_010 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_021 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' ); -- Winning Quote
    htp.tabledata( htf.bold( LNG.ORD_TXT_013 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    -- htp.tabledata( htf.bold( LNG.LAB_TXT_017 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;
   tcomm := 0;
   ttl := 0;
   ttls := 0;
   ttls2 := 0;
   for c4rec in c4(acid,tid) loop
    htp.tablerowopen;
     htp.formhidden( 'R0', c4rec.item_id );
     htp.tabledata( htf.formtext( 'R1', 35, 100, c4rec.disp_description) || htf.nl || c4rec.cust_description,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.formtext( 'R2', 5, 10, c4rec.qty),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
     htp.tabledata( to_char(c4rec.cust_max_price,LNG.LRG_MONEY_FORMAT),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
     if c2rec.commission_rate is null and c4rec.max_price is null
      then
        htp.tabledata( htf.formtext( 'R3', 15, 20, to_char(c4rec.max_price,LNG.LRG_MONEY_FORMAT)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
     elsif c2rec.commission_rate is not null and c4rec.max_price is null
      then
        htp.tabledata( htf.formtext( 'R3', 15, 20, to_char(c4rec.cust_max_price - ((c4rec.cust_max_price * c2rec.commission_rate) / 100),LNG.LRG_MONEY_FORMAT)) || htf.nl ||
                       to_char(c4rec.cust_max_price - ((c4rec.cust_max_price * c2rec.commission_rate) / 100),LNG.LRG_MONEY_FORMAT) ||
                      '('  || to_char((c4rec.cust_max_price - ((c4rec.cust_max_price * c2rec.commission_rate) / 100)) * nvl(c4rec.qty,1),LNG.LRG_MONEY_FORMAT) || ')',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
        ttls := ttls + (c4rec.cust_max_price * nvl(c4rec.qty,1));
        ttls2 := ttls2 + ((c4rec.cust_max_price - ((c4rec.cust_max_price * c2rec.commission_rate) / 100)) * nvl(c4rec.qty,1));
        update tender_item
         set
          max_price = c4rec.cust_max_price - ((c4rec.cust_max_price * c2rec.commission_rate) / 100)
        where tender_id = c4rec.tender_id and
              item_id = c4rec.item_id;
        commit;
      else
        htp.tabledata( htf.formtext( 'R3', 15, 20, to_char(c4rec.max_price,LNG.LRG_MONEY_FORMAT)) || htf.nl ||
                       to_char(c4rec.cust_max_price - c4rec.max_price,LNG.LRG_MONEY_FORMAT) ||
                      '('  || to_char((c4rec.cust_max_price - c4rec.max_price) * nvl(c4rec.qty,1),LNG.LRG_MONEY_FORMAT) || ')',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
        ttls := ttls + (c4rec.cust_max_price * nvl(c4rec.qty,1));
        ttls2 := ttls2 + ((c4rec.cust_max_price - nvl(c4rec.max_price,0)) * nvl(c4rec.qty,1));
     end if;
     if c4rec.item_valid = 'T'
      then
       htp.tabledata( htf.formcheckbox( 'R4', '[' || c4rec.tender_id || ']' || c4rec.item_id, 'CHECKED'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      else
       htp.tabledata( htf.formcheckbox( 'R4', '[' || c4rec.tender_id || ']' || c4rec.item_id),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     end if;
      -- Review All Bids for this Item
      htp.tabledata( htf.anchor2( 'pbk.bid_tender_mfctr?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&tid=' || tid || '&itid=' || c4rec.item_id, LNG4.AHC_TXT_032, ctarget=>'TENDER_WINDOW' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      c5rec.price_per_unit := NULL;
      open c5( tid, c4rec.item_id );
      fetch c5 into c5rec;
      close c5;
      if c5rec.price_per_unit is null
       then
         htp.tabledata( htf.bold(LNG4.AHC_TXT_022),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
         htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
         -- htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
         htp.tabledata( htf.bold(to_char(c5rec.price_per_unit,LNG.LRG_MONEY_FORMAT)) || htf.nl ||
                        c5rec.name,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
         htp.tabledata( htf.bold(to_char(c5rec.shipping,LNG.LRG_MONEY_FORMAT)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
         titem := nvl(((c5rec.price_per_unit - ((100 * c5rec.price_per_unit) / (100 + nvl(c2rec.commission_rate,0)))) * nvl(c4rec.qty,1)),0);
         ttl := ttl + ( c5rec.price_per_unit * nvl(c4rec.qty,1));
         tcomm := tcomm + titem;
         -- htp.tabledata( htf.bold(to_char(titem,LNG.LRG_MONEY_FORMAT)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
      end if;
   htp.tablerowclose;
   end loop;

   /*
   if c2rec.date_locked >= trunc(sysdate) or c2rec.date_locked is null
    then
     for j in 1..2 loop
      htp.tablerowopen;
       htp.formhidden( 'R0', NULL );
       htp.tabledata( htf.formtext( 'R1', 35, 100, null),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.formtext( 'R2', 5, 10, '1'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( htf.formtext( 'R3', 15, 20, null),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       --htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tablerowclose;
     end loop;
   end if;
  */

  htp.tablerowopen;
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( htf.bold(to_char(ttls,LNG.MONEY_FORMAT)) || htf.nl ||
                               to_char(ttls2,LNG.MONEY_FORMAT) || htf.nl || htf.line ||
                               to_char(round(ttls - ttls2,2),LNG.MONEY_FORMAT),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( htf.bold(to_char(ttl,LNG.MONEY_FORMAT)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       --htp.tabledata( htf.bold(to_char(tcomm,LNG.MONEY_FORMAT)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
   htp.tablerowclose;

   htp.formhidden( 'R4', null );
  htp.tableclose;
  htp.nl;
  if tid is null
   then
    htp.formsubmit( 'ACTION', LNG4.AHC_TXT_005 );
   else
    htp.formsubmit( 'ACTION', LNG4.AHC_TXT_006);
  end if;
  htp.formsubmit( 'ACTION', LNG4.AHC_TXT_020);
  htp.formclose;
  if c2rec.warranty_id is not null
   then
    glbx.display_warranty(surl,c2rec.warranty_id,c1rec.pid);
  end if;
  htp.line;
  htp.nl;
  htp.bold( LNG4.AHC_TXT_023 );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG2.PBK_TXT_009 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( '&nbsp;' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;
  htp.nl;
  htp.formopen( 'pbk.accept_tender_mfctr' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'TID', tid );
  htp.formhidden( 'ACID', acid );
  for c7rec in c7( tid ) loop
   htp.tablerowopen;
    htp.formhidden( 'P0', c7rec.manufacturer_id );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
    htp.formselectopen( 'P1' );
    htp.formselectoption( NULL );
    for c8rec in c8 loop
     if c8rec.manufacturer_id = c7rec.manufacturer_id
      then
       htp.formselectoption( c8rec.name, 'SELECTED', cattributes=>'VALUE="' || c8rec.manufacturer_id || '"' );
      else
       htp.formselectoption( c8rec.name, cattributes=>'VALUE="' || c8rec.manufacturer_id || '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.anchor2( 'pbk.tender_mfctr?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&tid=' || tid || '&mid=' || c7rec.manufacturer_id, LNG4.AHC_TXT_029, ctarget=>'TENDER_WINDOW' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tablerowclose;
  end loop;
  for j in 1..5 loop
    htp.tablerowopen;
     htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
     htp.formhidden( 'P0', null );
     htp.formselectopen( 'P1' );
     htp.formselectoption( NULL );
     for c8rec in c8 loop
      htp.formselectoption( c8rec.name, cattributes=>'VALUE="' || c8rec.manufacturer_id || '"' );
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
    htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG4.AHC_TXT_025 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'PBK', 'MODIFY_TENDER_LIST', errmsg=>sqlerrm);
end modify_tender_list;

procedure accept_tender_mfctr( surl varchar2, acid in integer, tid in integer, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY )
as

 cursor c1(manid integer) is select contact_email from manufacturer where manufacturer_id = manid;
 cursor c2(tid integer) is select * from tender where tender_id = tid;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_TENDER_MFCTR', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  for j in p0.first..p0.last loop
   if p1(j) is not null and p0(j) is null
    then
     insert into tender_mfctr( tender_id, manufacturer_id, notified ) values (tid,p1(j),'T');
     insert into tender_mfctr_item(tender_id, manufacturer_id, item_id, successful_bid )
      select tender_id,p1(j),item_id,null
      from tender_item
      where tender_id = tid;
      open c1(p1(j));
      fetch c1 into c1rec;
      close c1;
      open c2(tid);
      fetch c2 into c2rec;
      close c2;
      gcode(1) := 'TENDER';
      gparam(1) := c2rec.quote_reference;
      gcode(2) := 'DUE_DATE';
      gparam(2) := to_char(c2rec.date_locked,LNG.TSMASK);
      gcode(3) := 'POSTCODE';
      gparam(3) := c2rec.postcode;
      gcode(4) := 'SIGNATURE';
      gparam(4) := glbx.extract_master_parameter('MAIL SIGNATURE');
      glbx.send( gcode, gparam, 'tender_notify.tmp', p_to=>c1rec.contact_email, p_subj=>LNG4.AHC_TXT_027, p_from=>glbx.extract_master_parameter('MAIL_FROM'),ltype=>ltype,own_id=>owner_id, scode=>'TN1',v_pid=>owner_id,v_aid=>acid);
   elsif p1(j) is null and p0(j) is null
    then
     null;
   elsif p1(j) is null and p0(j) is not null
    then
     delete from tender_mfctr_item where tender_id = tid and manufacturer_id = p0(j);
     delete from tender_mfctr where tender_id = tid and manufacturer_id = p0(j);
   elsif p1(j) is not null and p0(j) is not null
    then
     if p0(j) <> p1(j)
     then
       delete from tender_mfctr_item where tender_id = tid and manufacturer_id = p0(j);
       update tender_mfctr
        set
         manufacturer_id = p1(j)
       where manufacturer_id = p0(j) and
             tender_id = tid;
     end if;
   end if;
  end loop;
  commit;
  modify_tender_list( surl, acid, tid, LNG4.AHC_TXT_026 );

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_TENDER_MFCTR', errmsg=>sqlerrm);
end accept_tender_mfctr;

procedure accept_tender_list( surl varchar2, acid in integer, tid in integer, p1 in varchar2, p1c in varchar2, p2 in varchar2, p3 in varchar2, p3d in varchar2, p4 in varchar2 default null, action in varchar2, r0 in GLBX.MYARRAY, r1 in GLBX.MYARRAY, r2 in GLBX.MYARRAY, r3 in GLBX.MYARRAY, r4 in GLBX.MYARRAY )
as

 cursor c1( tid integer ) is select max(item_id) from tender_item where tender_id = tid;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 ntid		integer;
 dt1		date;
 msg		varchar2(200);
 nqty		integer;
 mprice		number;
 newid		integer;
 comm		number;
 tdet		varchar2(4000);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_TENDER_LIST', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  begin dt1 := to_date( p2, LNG.MASK ); exception when others then msg := LNG4.AHC_TXT_015; dt1 := sysdate +14; end;
  begin comm := to_number(p1c); exception when others then comm := 0; end;
  tdet := substr(p3d,1,4000);

  /* Photographer can override date and set it to be anything
  if dt1 < sysdate
   then
    msg := LNG4.AHC_TXT_015;
    dt1 := sysdate +14;
  end if;
  */

  if p3 is null then msg := msg || LNG4.AHC_TXT_017; end if;

  if tid is null
   then
    select s_tender.nextval into ntid from dual;
    insert into tender(tender_id, aid, quote_reference,date_created,date_updated,date_locked,postcode,warranty_id,commission_rate,tender_details) values
     (ntid, acid, nvl(p1,LNG4.AHC_TXT_014), sysdate,null, dt1, p3, p4, comm, tdet );
   else
    ntid := tid;
    update tender
     set
      quote_reference = translate(nvl(p1,LNG4.AHC_TXT_014),'+"',' '''),
      date_updated = sysdate,
      date_locked = dt1,
      postcode = p3,
      warranty_id = p4,
      commission_rate = comm,
      tender_details = tdet
    where tender_id = ntid and
          aid = acid;
  end if;

  update tender_item set item_valid = 'F' where tender_id = ntid;

  for j in r0.first..r0.last loop
   if r0(j) is null and r1(j) is not null
    then
     -- Insert
      begin nqty := nvl(to_number( r2(j) ), 1); exception when others then nqty := 1; end;
      begin mprice := to_number(r3(j)); exception when others then begin mprice := to_number(r3(j),LNG.LRG_MONEY_FORMAT); exception when others then mprice := 0; end; end;
      newid := null;
      open c1( ntid );
      fetch c1 into newid;
      close c1;
      newid := nvl(newid,1) + 1;
      insert into tender_item(tender_id,item_id,disp_description,qty,max_price,item_valid) values
       (ntid, newid, translate(nvl(r1(j),LNG4.AHC_TXT_018),'+"',' '''), nqty, mprice, 'T');
      insert into tender_mfctr_item(tender_id,item_id,successful_bid,manufacturer_id)
       select ntid, newid, null, manufacturer_id
       from tender_mfctr
       where tender_id = ntid;
    elsif r0(j) is not null and r1(j) is null
     then
      -- Delete
      delete from tender_mfctr_item where tender_id = tid and tender_id = (select tender_id from tender where aid = acid and tender_id = tid) and item_id = r0(j);
      delete from tender_item where tender_id = tid and tender_id = (select tender_id from tender where aid = acid and tender_id = tid) and item_id = r0(j);
    elsif r0(j) is not null and r1(j) is not null
     then
     -- Update
     begin nqty := nvl(to_number( r2(j) ), 1 ); exception when others then nqty := 1; end;
     begin mprice := to_number(r3(j)); exception when others then begin mprice := to_number(r3(j),LNG.LRG_MONEY_FORMAT); exception when others then mprice := 0; end; end;
     if nqty < 1 then nqty := 1; end if;
     if mprice < 0 then mprice := 0; end if;
     update tender_item
      set
       qty = nqty,
       disp_description = translate(nvl(r1(j),LNG4.AHC_TXT_018),'+"',' '''),
       max_price = mprice
     where tender_id = tid and tender_id = (select tender_id from tender where aid = acid and tender_id = tid) and item_id = r0(j);
   end if;
  end loop;

  for j in r4.first..r4.last loop
   if r4(j) is not null
    then
     update tender_item
      set
       item_valid = 'T'
      where tender_id = to_number(substr(r4(j),2,instr(r4(j),']')-2)) and
            item_id = to_number(substr(r4(j),instr(r4(j),']')+1)) and
            tender_id = (select tender_id from tender where aid = acid and tender_id = ntid);
    end if;
  end loop;

  commit;

  if action = LNG4.AHC_TXT_020 and tid is null
   then
    tender_list( surl, nvl(msg,LNG4.AHC_TXT_012) );
    return;
  elsif action = LNG4.AHC_TXT_020 and tid is not null
   then
    tender_list( surl, nvl(msg,LNG4.AHC_TXT_013) );
    return;
  end if;

  if tid is null
   then
    modify_tender_list(surl, acid, ntid, nvl(msg,LNG4.AHC_TXT_012));
   else
    modify_tender_list(surl, acid, ntid, nvl(msg,LNG4.AHC_TXT_013));
  end if;

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_TENDER_LIST', errmsg=>sqlerrm);
end accept_tender_list;

procedure tender_mfctr(surl varchar2, acid in integer, mid in integer, tid in varchar2, msg in varchar2 default null)
as

 cursor c2( acid integer, tid integer ) is select * from tender where aid = acid and tender_id = tid;
 cursor c3( mid integer, tid integer ) is
  select ti.item_id,tmi.price_per_unit,tmi.shipping,tmi.successful_bid, ti.disp_description, ti.qty
  from tender_mfctr_item  tmi, tender_item ti
  where tmi.tender_id = tid and
        tmi.manufacturer_id = mid  and
        tmi.tender_id = ti.tender_id and
        tmi.item_id = ti.item_id
  order by tmi.item_id;
 cursor c4( mid integer ) is select name from manufacturer where manufacturer_id = mid;
 cursor c8 is select manufacturer_id,name,man_type from manufacturer order by name;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.TENDER_MFCTR', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  pfx := glbx.get_thm( c1rec.theme_name );

  open c4( mid );
  fetch c4 into c4rec;
  close c4;
  glbx.main_title( surl, LNG4.AHC_TXT_030 || ':' || c4rec.name, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P48',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;
  open c2(acid, tid );
  fetch c2 into c2rec;
  close c2;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_009 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG2.FNM_TXT_078 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG2.FNM_TXT_170 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_031 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_075 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   for c3rec in c3( mid, tid ) loop
    htp.tablerowopen;
     htp.tabledata( htf.bold( c3rec.disp_description ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( to_char(c3rec.price_per_unit,LNG.LRG_MONEY_FORMAT) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
     htp.tabledata( htf.bold( to_char(nvl(c3rec.shipping,0),LNG.LRG_MONEY_FORMAT) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     if c3rec.successful_bid is null
      then
       htp.tabledata( htf.bold( LNG4.AHC_TXT_022 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     elsif c3rec.successful_bid = 'T'
      then
       htp.tabledata( htf.bold( LNG.PHG_TXT_045 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
       htp.tabledata( htf.bold( LNG.PHG_TXT_046 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     end if;
     if c3rec.price_per_unit is not null
      then
       htp.tabledata( to_char( (c3rec.price_per_unit * c3rec.qty) + nvl(c3rec.shipping,0) ,LNG.LRG_MONEY_FORMAT),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
      else
       htp.tabledata( '&nbsp;', LNG.LRG_MONEY_FORMAT,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
     end if;
    htp.tablerowclose;
   end loop;
  htp.tableclose;
  htp.nl;
  htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'TENDER_MFCTR', errmsg=>sqlerrm);
end tender_mfctr;

procedure bid_tender_mfctr(surl varchar2, acid in integer, itid in integer, tid in varchar2, msg in varchar2 default null)
as

 cursor c2( acid integer, tid integer ) is select * from tender where aid = acid and tender_id = tid;
 cursor c3( itid integer, tid integer ) is
  select tmi.price_per_unit,tmi.shipping,tmi.successful_bid, tmi.manufacturer_id, m.name
  from tender_mfctr_item  tmi, manufacturer m
  where tmi.tender_id = tid and
        tmi.item_id = itid  and
        m.manufacturer_id = tmi.manufacturer_id
  order by nvl(tmi.price_per_unit,99999999);
 cursor c4( itid integer, tid integer ) is select disp_description from tender_item where item_id = itid and tender_id = tid;
 cursor c8 is select manufacturer_id,name,man_type from manufacturer order by name;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.BID_TENDER_MFCTR', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  pfx := glbx.get_thm( c1rec.theme_name );

  open c4( itid, tid );
  fetch c4 into c4rec;
  close c4;
  glbx.main_title( surl, LNG4.AHC_TXT_033 || ' : ' || c4rec.disp_description, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P47',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;
  open c2(acid, tid );
  fetch c2 into c2rec;
  close c2;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG2.PBK_TXT_009 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG2.FNM_TXT_078 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG2.FNM_TXT_170 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_031 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.formopen( 'pbk.accept_bid_tender' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl) );
   htp.formhidden( 'TID', tid );
   htp.formhidden( 'ITID', itid );
   htp.formhidden( 'ACID', acid );
   for c3rec in c3( itid, tid ) loop
    htp.tablerowopen;
     htp.tabledata( htf.bold( c3rec.name ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( to_char(c3rec.price_per_unit,LNG.LRG_MONEY_FORMAT) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
     htp.tabledata( htf.bold( to_char(nvl(c3rec.shipping,0),LNG.LRG_MONEY_FORMAT) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     if c3rec.successful_bid is null and c3rec.price_per_unit is null
      then
       htp.tabledata( htf.formcheckbox( 'P1', c3rec.manufacturer_id ) || ' ' || htf.bold( LNG4.AHC_TXT_022 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     elsif c3rec.successful_bid is null and c3rec.price_per_unit is not null
      then
       htp.tabledata( htf.formcheckbox( 'P1', c3rec.manufacturer_id ) || ' ' || htf.bold( LNG4.AHC_TXT_037 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     elsif c3rec.successful_bid = 'T'
      then
       htp.tabledata( htf.formcheckbox( 'P1', c3rec.manufacturer_id, 'CHECKED' ) || ' ' || htf.bold( LNG.PHG_TXT_045 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
       htp.tabledata( htf.formcheckbox( 'P1', c3rec.manufacturer_id ) || ' ' || htf.bold( LNG.PHG_TXT_046 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     end if;
    htp.tablerowclose;
   end loop;
  htp.tableclose;
  htp.nl;
  htp.formhidden( 'P1', null );
  htp.p( htf.formcheckbox( 'P2', 'T', 'CHECKED' ) || LNG4.AHC_TXT_249 );
  htp.nl;
  htp.nl;
  htp.formsubmit( null, LNG4.AHC_TXT_034 );
  htp.formclose;
  htp.nl;
  htp.nl;
  htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'BID_TENDER_MFCTR', errmsg=>sqlerrm);
end bid_tender_mfctr;

procedure accept_bid_tender( surl varchar2, acid in integer, tid in integer, itid in integer, p1 in GLBX.MYARRAY, p2 in varchar2 default 'F' )
as

 cursor c1( tid integer, itid integer ) is
  select successful_bid, name, contact_email, disp_description, quote_reference, tmi.price_per_unit, ti.qty
  from tender_item ti, tender_mfctr_item tmi, tender t, manufacturer m
  where tmi.tender_id = tid and
        tmi.item_id = itid and
        m.manufacturer_id = tmi.manufacturer_id and
        ti.tender_id = tmi.tender_id and
        ti.item_id = tmi.item_id and
        t.tender_id = ti.tender_id and
        successful_bid is not null;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_BID_TENDER', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  update tender_mfctr_item
   set
    successful_bid = 'F'
   where successful_bid is not null and
         tender_id = tid and
         item_id = itid;

  for j in p1.first..p1.last loop
   if p1(j) is not null
    then
     update tender_mfctr_item
      set
       successful_bid = 'T'
      where
         tender_id = tid and
         item_id = itid and
         manufacturer_id = p1(j);
   end if;
  end loop;

  -- Notify if Successful or Unsuccessful

  commit;

  if p2 = 'T'
   then
    for c1rec in c1(tid,itid) loop
      gcode(1) := 'NAME';
      gparam(1) := c1rec.name;
      gcode(2) := 'TENDER';
      gparam(2) := c1rec.quote_reference;
      gcode(3) := 'TENDER_ITEM';
      gparam(3) := c1rec.disp_description;
      gcode(4) := 'TENDER_PRICE';
      gparam(4) := to_char(c1rec.price_per_unit,LNG.LRG_MONEY_FORMAT);
      gcode(5) := 'QUANTITY';
      gparam(5) := to_char(c1rec.qty);
      if c1rec.successful_bid = 'T'
       then
        glbx.send( gcode, gparam, 'tender_success.tmp', p_to=>c1rec.contact_email, p_subj=>LNG4.AHC_TXT_031 || ':' || c1rec.disp_description, p_from=>glbx.extract_master_parameter('MAIL_FROM'),ltype=>ltype,own_id=>owner_id, scode=>'TS1',v_pid=>owner_id,v_aid=>acid);
       else
        glbx.send( gcode, gparam, 'tender_failure.tmp', p_to=>c1rec.contact_email, p_subj=>LNG4.AHC_TXT_251 || ':' || c1rec.disp_description, p_from=>glbx.extract_master_parameter('MAIL_FROM'),ltype=>ltype,own_id=>owner_id, scode=>'TF1',v_pid=>owner_id,v_aid=>acid);
      end if;
    end loop;
  end if;

  bid_tender_mfctr( surl, acid, itid, tid, LNG4.AHC_TXT_035 );
exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_BID_TENDER', errmsg=>sqlerrm);
end accept_bid_tender;

procedure reverse_list(surl varchar2, msg in varchar2 default null)
as

 cursor c2( phgid integer ) is
  select *
  from reverse_auction
  where pid = phgid
  order by date_locked desc;

 cursor c3( wid integer ) is select warranty_name from warranty where warranty_id = wid;

 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.REVERSE_LIST', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG4.AHC_TXT_039, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B10',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_040 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_041 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.ORD_TXT_153 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.GLB_TXT_078 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( '&nbsp;' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG2.FNM_TXT_059 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;
   for c2rec in c2( owner_id ) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'pbk.manage_reverse?surl=' || glbx.rndsurl(surl) || '&raid=' || c2rec.reverse_id, c2rec.product_name), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( c2rec.product_location_pcode, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(c2rec.date_locked,LNG.MASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(c2rec.date_created,LNG.MASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    if c2rec.date_locked <= trunc(sysdate)
     then
      htp.tabledata( htf.bold( LNG4.AHC_TXT_042 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      htp.tabledata( htf.bold( LNG4.AHC_TXT_043 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
    if c2rec.warranty_id is not null
     then
      open c3( c2rec.warranty_id );
      fetch c3 into c3rec;
      close c3;
      htp.tabledata( htf.bold( c3rec.warranty_name ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
   htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.formopen( 'pbk.manage_reverse' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl) );
   htp.formhidden( 'RAID', null );
   htp.formsubmit( null, LNG4.AHC_TXT_045 );
   htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;

exception when others then
 glbx.error_details( 'PBK', 'REVERSE_LIST', errmsg=>sqlerrm);
end reverse_list;

procedure manage_reverse(surl varchar2, raid in integer, msg in varchar2 default null)
as

 cursor c2( phgid integer, raid integer ) is select * from reverse_auction where reverse_id = raid and pid = phgid;
 cursor c3( raid integer, intid integer ) is select interest_id from reverse_interest where reverse_id = raid and interest_id = intid;
 cursor c4( raid integer ) is select qty_from, qty_to, price_per_unit from reverse_price where reverse_id = raid order by qty_from;
 cursor c5( raid integer ) is select date_updated, price_per_unit from reverse_history where reverse_id = raid order by date_updated desc;
 cursor c6 is select interest_name, interest_id from interest_groups order by interest_name;
 cursor c7 is select manufacturer_id, name, man_type from manufacturer order by man_type,name;
 cursor c8( phgid integer ) is select * from warranty where pid = phgid order by warranty_name;
 cursor c9( raid integer ) is select rb.aid, ca.account_name, rb.bid_qty from reverse_bid rb, customer_account ca where ca.aid = rb.aid and rb.reverse_id = raid order by bid_qty desc;
 cursor c10(raid integer) is select price_per_unit from reverse_history where reverse_id = raid and date_updated = (select max(date_updated) from reverse_history where reverse_id = raid);

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c10rec		c10%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MANAGE_REVERSE', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if raid is not null
   then
    open c2(owner_id, raid );
    fetch c2 into c2rec;
    close c2;
  end if;
  pfx := glbx.photo_lf(owner_id);
  if raid is null
   then
    glbx.main_title( surl, LNG4.AHC_TXT_045, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B11',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   else
    glbx.main_title( surl, LNG4.AHC_TXT_046 || ' : ' || c2rec.product_name , glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B11',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  end if;
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;

  htp.formopen( 'pbk.accept_manage_reverse' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl) );
  htp.formhidden( 'RAID', raid );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_040 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P1', 30, 100, c2rec.product_name),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_041 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P2', 30, 100, c2rec.product_location_pcode),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG2.PBK_TXT_009 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    htp.formselectopen( 'P3' );
    htp.formselectoption( NULL );
    for c7rec in c7 loop
     if c7rec.manufacturer_id = c2rec.manufacturer_id
      then
       htp.formselectoption( c7rec.name || '(' || c7rec.man_type || ')', 'SELECTED', cattributes=>'VALUE="' || c7rec.manufacturer_id || '"' );
      else
       htp.formselectoption( c7rec.name || '(' || c7rec.man_type || ')', cattributes=>'VALUE="' || c7rec.manufacturer_id || '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_049 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P4', 30, 100, c2rec.manufctr_code),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.GLB_TXT_078 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char( c2rec.date_created, LNG.MASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   if raid is not null
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG2.FNM_TXT_011 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( to_char( c2rec.date_updated, LNG.MASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
   end if;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.ORD_TXT_153 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P5', 20, 30, to_char( c2rec.date_locked, LNG.MASK)) || ' ' || htf.italic(LNG.MASK || ' eg. 17-JAN-2002'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG3.ADM_TXT_260 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    htp.formselectopen( 'P5H' );
    for j in 0..23 loop
     if to_char(c2rec.date_locked,'HH24') = lpad(to_char(j),2,'0')
      then
       htp.formselectoption( lpad(to_char(j),2,'0'), 'SELECTED' );
      else
       htp.formselectoption( lpad(to_char(j),2,'0') );
     end if;
    end loop;
    htp.formselectclose;
    htp.formselectopen( 'P5M' );
    for j in 0..59 loop
     if to_char(c2rec.date_locked,'MI') = lpad(to_char(j),2,'0')
      then
       htp.formselectoption( lpad(to_char(j),2,'0'), 'SELECTED' );
      else
       htp.formselectoption( lpad(to_char(j),2,'0') );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG2.FNM_TXT_058 ),cattributes=>pfx.qbground );
    htp.p( '<TD ' || pfx.qcbground || '>' );
    htp.formselectopen( 'P6' );
    htp.formselectoption( NULL );
    for c8rec in c8(owner_id) loop
     if c8rec.warranty_id = c2rec.warranty_id
      then
       htp.formselectoption( c8rec.warranty_name, 'SELECTED', cattributes=>'VALUE="' || c8rec.warranty_id || '"' );
      else
       htp.formselectoption( c8rec.warranty_name, cattributes=>'VALUE="' || c8rec.warranty_id || '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;

 htp.tableopen( cattributes=>'cellpadding=5 cellspacing=5 border=1' );
 htp.tablerowopen;
 htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' );
 htp.bold( LNG3.ADM_TXT_817 );
 htp.nl;
 htp.formhidden( 'P7', null );
 htp.formselectopen( 'P7', null, 5, cattributes=>'MULTIPLE' );
  for c6rec in c6 loop
   open c3(raid,c6rec.interest_id);
   fetch c3 into c3rec;
   if c3%FOUND
    then
     htp.formselectoption( c6rec.interest_name, 'SELECTED', cattributes=>'VALUE="' || c6rec.interest_id || '"' );
    else
     htp.formselectoption( c6rec.interest_name, cattributes=>'VALUE="' || c6rec.interest_id || '"' );
   end if;
   close c3;
  end loop;
 htp.formselectclose;
 htp.p( '</TD>' );

 htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' );
 htp.bold( LNG4.AHC_TXT_054 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG4.AHC_TXT_050 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG4.AHC_TXT_051 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG2.FNM_TXT_078),cattributes=>pfx.qbground );
  htp.tablerowclose;
 for c4rec in c4(raid) loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P8', 8, 10, c4rec.qty_from),cattributes=>pfx.qcbground );
   htp.tabledata( htf.formtext( 'P9', 8, 10, c4rec.qty_to),cattributes=>pfx.qcbground );
   htp.tabledata( htf.formtext( 'P10', 15, 20, to_char(c4rec.price_per_unit,LNG.LRG_MONEY_FORMAT)),cattributes=>pfx.qcbground );
  htp.tablerowclose;
 end loop;
 for j in 1..4 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P8', 8, 10, null),cattributes=>pfx.qcbground );
   htp.tabledata( htf.formtext( 'P9', 8, 10, null),cattributes=>pfx.qcbground );
   htp.tabledata( htf.formtext( 'P10', 15, 20, null),cattributes=>pfx.qcbground );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.p( '</TD>' );

 htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' );
 htp.bold( LNG4.AHC_TXT_052 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG4.AHC_TXT_053 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG2.FNM_TXT_078 ),cattributes=>pfx.qbground );
  htp.tablerowclose;
 for c5rec in c5(raid) loop
  htp.tablerowopen;
   if c5%ROWCOUNT = 1
    then
     htp.tabledata( htf.bold(to_char(c5rec.date_updated,LNG.TSMASK)),cattributes=>pfx.qcbground );
     htp.tabledata( htf.bold(to_char(c5rec.price_per_unit,LNG.LRG_MONEY_FORMAT)),cattributes=>pfx.qcbground );
    else
     htp.tabledata( to_char(c5rec.date_updated,LNG.TSMASK),cattributes=>pfx.qcbground );
     htp.tabledata( to_char(c5rec.price_per_unit,LNG.LRG_MONEY_FORMAT),cattributes=>pfx.qcbground );
   end if;
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tablerowopen;
 htp.p( '<TD VALIGN="TOP" ALIGN="CENTER" COLSPAN=3>' );
 htp.bold( LNG4.AHC_TXT_072 );
 htp.nl;
  open c10( raid );
  fetch c10 into c10rec;
  close c10;
  if c10rec.price_per_unit is null
   then
    htp.bold( LNG4.AHC_TXT_068 );
    htp.nl;
   else
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.CST_TXT_031 ),cattributes=>pfx.qbground );
      htp.tabledata( htf.bold( LNG4.AHC_TXT_062 ),cattributes=>pfx.qbground );
      htp.tabledata( htf.bold( LNG4.AHC_TXT_071 ),cattributes=>pfx.qbground );
     htp.tablerowclose;
    for c9rec in c9(raid) loop
     htp.tabledata( c9rec.account_name,cattributes=>pfx.qcbground );
     htp.tabledata( c9rec.bid_qty,cattributes=>pfx.qcbground );
     htp.tabledata( to_char(c10rec.price_per_unit * c9rec.bid_qty,LNG.LRG_MONEY_FORMAT),cattributes=>pfx.qcbground );
    end loop;
    htp.tableclose;
  end if;
 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 if raid is null
  then
   htp.formsubmit( 'ACTION', LNG4.AHC_TXT_047 );
  else
   htp.formsubmit( 'ACTION', LNG4.AHC_TXT_048 );
   htp.formsubmit( 'ACTION', LNG4.AHC_TXT_055 );
 end if;
 htp.formsubmit( 'ACTION', LNG4.AHC_TXT_038 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'MANAGE_REVERSE', errmsg=>sqlerrm);
end manage_reverse;

procedure accept_manage_reverse( surl varchar2, raid in integer, action in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p5h in varchar2, p5m in varchar2, p6 in varchar2, p7 in GLBX.MYARRAY, p8 in GLBX.MYARRAY, p9 in GLBX.MYARRAY, p10 in GLBX.MYARRAY )
as

 cursor c1( tid integer ) is select max(item_id) from tender_item where tender_id = tid;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nraid		integer;
 ndate		date;
 nprice		number;
 nqty_from	integer;
 nqty_to	integer;
 foundrec	boolean;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_MANAGE_REVERSE', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  begin ndate := to_date( p5, LNG.MASK ); exception when others then ndate := NULL; end;
  ndate := to_date( p5 || ' ' || p5h || ':' || p5m, LNG.MASK || ' HH24:MI' );

  if raid is null
   then
    select s_reverse_auction.nextval into nraid from dual;
    insert into reverse_auction(reverse_id,pid,manufacturer_id,manufctr_code,warranty_id,product_name,product_location_pcode,date_locked,date_created,date_updated) values
     (nraid,owner_id,p3,p4,p6,p1,p2,ndate,sysdate,null);
   else
    if action = LNG4.AHC_TXT_055
     then
      delete from reverse_interest where reverse_id = nraid;
      delete from reverse_history where reverse_id = nraid;
      delete from reverse_price where reverse_id = nraid;
      delete from reverse_auction where reverse_id = nraid;
      commit;
      reverse_list(surl,LNG4.AHC_TXT_056);
      return;
     else
      nraid := raid;
      update reverse_auction
       set
        manufacturer_id = p3,
        manufctr_code = p4,
        warranty_id = p6,
        product_name = p1,
        product_location_pcode = p2,
        date_locked = ndate,
        date_updated = sysdate
     where reverse_id = nraid and
           pid = owner_id;
    end if;
  end if;

  delete from reverse_interest where reverse_id = nraid;
  for j in p7.first..p7.last loop
   if p7(j) is not null
    then
     insert into reverse_interest(reverse_id,interest_id) values (nraid,p7(j));
   end if;
  end loop;

  delete from reverse_price;
  foundrec := FALSE;
  for j in p8.first..p8.last loop
   if p8(j) is not null and p9(j) is not null and p10(j) is not null
    then
     begin nqty_from := nvl(to_number( p8(j) ), 1 ); exception when others then nqty_from := 1; end;
     begin nqty_to := nvl(to_number( p9(j) ), 1 ); exception when others then nqty_to := 999999; end;
     begin nprice := to_number(p10(j)); exception when others then begin nprice := to_number(p10(j),LNG.LRG_MONEY_FORMAT); exception when others then nprice := 0; end; end;
     insert into reverse_price(reverse_id,qty_from,qty_to,price_per_unit) values (nraid,nqty_from,nqty_to,nprice);
     if raid is null and not foundrec
      then
       insert into reverse_history( reverse_id, price_per_unit, date_updated ) values (nraid,nprice,sysdate);
       foundrec := TRUE;
     end if;
   end if;
  end loop;

  commit;

  if raid is null
   then
    manage_reverse( surl, nraid, LNG4.AHC_TXT_058 );
  elsif action = LNG4.AHC_TXT_038
   then
      reverse_list(surl,LNG4.AHC_TXT_057);
  else
    manage_reverse( surl, nraid, LNG4.AHC_TXT_057 );
  end if;

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_MANAGE_REVERSE', errmsg=>sqlerrm);
end accept_manage_reverse;

procedure home_page_option(surl varchar2, acid in integer, msg in varchar2 default null)
as

 cursor c2( snm varchar2, acid integer, phgid integer ) is
   select distinct usc.umo_scene_id,usc.title,usc.parent_scene,usc.order_by
   from umo um, umo_scene usc
   where category = snm and
         um.umo_scene_id = usc.umo_scene_id and
         um.aid = acid
   order by usc.order_by;

cursor c5(phgid integer) is select external_api_access, photographer_title from photographer where pid = phgid;

cursor c6(acid integer) is select title,order_by,display_column,hnews from home_news where aid=acid order by display_column,order_by;

 c1rec		customer_account%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 notfound	boolean;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PBK.HOME_PAGE_OPTION', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  pfx := glbx.get_thm( c1rec.theme_name );
  --glbx.main_title( surl, LNG4.AHC_TXT_227, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P46',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active);
  glbx.main_title( surl, LNG4.AHC_TXT_227,  glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P46',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); else glbx.header_msg( 'Please Style you wish to use and Press MODIFY OPTIONS'); end if;
  htp.formopen( 'pbk.accept_home_page_option' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );
  htp.formhidden( 'P1', null );
  htp.nl;

  open c5(owner_id);
  fetch c5 into c5rec;
  close c5;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
    htp.p( htf.bold( LNG4.AHC_TXT_931 ) || ' ');
    htp.formselectopen( 'P0' );
    if c1rec.home_page_style = 'C' then htp.formselectoption( LNG4.AHC_TXT_932, 'SELECTED', cattributes=>'VALUE="C"' ); else htp.formselectoption( LNG4.AHC_TXT_932, cattributes=>'VALUE="C"' ); end if;
    if c1rec.home_page_style = 'N' then htp.formselectoption( LNG.CST_TXT_042, 'SELECTED', cattributes=>'VALUE="N"' ); else htp.formselectoption( LNG.CST_TXT_042, cattributes=>'VALUE="N"' ); end if;
    if c1rec.home_page_style = 'S' then htp.formselectoption( LNG.GLB_TXT_092, 'SELECTED', cattributes=>'VALUE="S"' ); else htp.formselectoption( LNG.GLB_TXT_092, cattributes=>'VALUE="S"' ); end if;
    if c1rec.home_page_style = 'O' then htp.formselectoption( LNG.GLB_TXT_063, 'SELECTED', cattributes=>'VALUE="O"' ); else htp.formselectoption( LNG.GLB_TXT_063, cattributes=>'VALUE="O"' ); end if;
    if c1rec.home_page_style = 'P' then htp.formselectoption( c5rec.photographer_title, 'SELECTED', cattributes=>'VALUE="P"' ); else htp.formselectoption( c5rec.photographer_title, cattributes=>'VALUE="P"' ); end if;
    if c1rec.home_page_style = 'X' then htp.formselectoption( LNG4.AHC_TXT_936, 'SELECTED', cattributes=>'VALUE="X"' ); else htp.formselectoption( LNG4.AHC_TXT_936, cattributes=>'VALUE="X"' ); end if;
    -- xxx language file
    if c1rec.home_page_style = 'T' then htp.formselectoption( 'HTML Template', 'SELECTED', cattributes=>'VALUE="T"' ); else htp.formselectoption( 'HTML Template', cattributes=>'VALUE="T"' ); end if;
    if c1rec.home_page_style = 'W' then htp.formselectoption( LNG5.EXT_TXT_053, 'SELECTED', cattributes=>'VALUE="W"' ); else htp.formselectoption( LNG5.EXT_TXT_053, cattributes=>'VALUE="W"' ); end if;
    if c1rec.home_page_style = 'Z' then htp.formselectoption( LNG4.AHC_TXT_932 || '/' || LNG5.EXT_TXT_053, 'SELECTED', cattributes=>'VALUE="Z"' ); else htp.formselectoption( LNG4.AHC_TXT_932 || '/' || LNG5.EXT_TXT_053, cattributes=>'VALUE="Z"' ); end if;
    if c1rec.site_type <> 'S'
     then
      if c1rec.home_page_style = 'V' then htp.formselectoption( LNG4.AHC_TXT_933, 'SELECTED', cattributes=>'VALUE="V"' ); else htp.formselectoption( LNG4.AHC_TXT_933, cattributes=>'VALUE="V"' ); end if;
    end if;
    if c5rec.external_api_access = 'T'
     then
      if c1rec.home_page_style = 'A' then htp.formselectoption( LNG4.AHC_TXT_429, 'SELECTED', cattributes=>'VALUE="A"' ); else htp.formselectoption( LNG4.AHC_TXT_429, cattributes=>'VALUE="A"' ); end if;
    end if;
    htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;

   if c1rec.home_page_style in ('C','Z')
   then
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,1,1) = 'T'
     then
      htp.formcheckbox( 'P1', '1', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '1' );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_228 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,2,1) = 'T'
     then
      htp.formcheckbox( 'P1', '2', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '2' );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_566 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,3,1) = 'T'
     then
      htp.formcheckbox( 'P1', '3', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '3' );
    end if;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    htp.bold( LNG4.AHC_TXT_230 || ' ' );
    if substr(c1rec.home_page_options,20,1) = 'T'
     then
      htp.formcheckbox( 'P1', '20', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '20' );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,4,1) = 'T'
     then
      htp.formcheckbox( 'P1', '4', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '4' );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_231 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,18,1) = 'T'
     then
      htp.formcheckbox( 'P1', '18', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '18' );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold( LNG2.PFM_TXT_080 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,19,1) = 'T'
     then
      htp.formcheckbox( 'P1', '19', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '19' );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_972 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,16,1) = 'T'
     then
      htp.formcheckbox( 'P1', '16', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '16' );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_935  ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,17,1) = 'T'
     then
      htp.formcheckbox( 'P1', '17', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '17' );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold( replace(LNG4.AHC_TXT_934,'<PHOTOGRAPHER>',c5rec.photographer_title) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,12,1) = 'T'
     then
      htp.formcheckbox( 'P1', '12', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '12' );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_306 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,11,1) = 'T'
     then
      htp.formcheckbox( 'P1', '11', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '11' );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_305 || ' (3 Columns)' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,21,1) = 'T'
     then
      htp.formcheckbox( 'P1', '21', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '21' );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_305 || ' (5 Columns)' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,5,1) = 'T'
     then
      htp.formcheckbox( 'P1', '5', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '5' );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_232 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,6,1) = 'T'
     then
      htp.formcheckbox( 'P1', '6', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '6' );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_233 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,7,1) = 'T'
     then
      htp.formcheckbox( 'P1', '7', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '7' );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_234 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,8,1) = 'T'
     then
      htp.formcheckbox( 'P1', '8', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '8' );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_235 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,9,1) = 'T'
     then
      htp.formcheckbox( 'P1', '9', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '9' );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_238 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,13,1) = 'T'
     then
      htp.formcheckbox( 'P1', '13', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '13' );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_350),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">' );
    if substr(c1rec.home_page_options,10,1) = 'T'
     then
      htp.formcheckbox( 'P1', '10', 'CHECKED' );
     else
      htp.formcheckbox( 'P1', '10' );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold( LNG5.EXT_TXT_404),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;

  else

   for j in 1..length(c1rec.home_page_options) loop
    if substr(c1rec.home_page_options,j,1) = 'T' then htp.formhidden( 'P1', j ); end if;
   end loop;
  end if;
  htp.tableclose;
  htp.nl;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   if c1rec.home_page_style = 'A'
    then
     if c5rec.external_api_access = 'T'
      then
       htp.tablerowopen;
        htp.tabledata( htf.bold( LNG4.AHC_TXT_429 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        if pfx.home_page_external_call is null and c1rec.home_page_override is null
         then
         htp.tabledata( htf.formtext( 'PEXT', 30, 1000, null ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        elsif pfx.home_page_external_call is null and c1rec.home_page_override is not null
         then
         htp.tabledata( htf.formtext( 'PEXT', 30, 1000, c1rec.home_page_override ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        elsif pfx.home_page_external_call is not null and c1rec.home_page_override is null
         then
         htp.tabledata( htf.formtext( 'PEXT', 30, 1000, null ) || htf.nl ||
                        htf.bold( pfx.home_page_external_call ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        elsif pfx.home_page_external_call = c1rec.home_page_override
         then
         htp.tabledata( htf.formtext( 'PEXT', 30, 1000, null ) || htf.nl ||
                        htf.bold( pfx.home_page_external_call ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        else
         htp.tabledata( htf.formtext( 'PEXT', 30, 1000, c1rec.home_page_override ) || htf.nl ||
                        htf.bold( pfx.home_page_external_call ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        end if;
       htp.tablerowclose;
     end if;
   end if;

  if c1rec.home_page_style in ('C','Z')
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG4.AHC_TXT_351),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     if substr(c1rec.home_page_options,14,1) = 'T'
      then
       htp.formcheckbox( 'P1', '14', 'CHECKED' );
      else
       htp.formcheckbox( 'P1', '14' );
     end if;
     htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG4.AHC_TXT_353 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">' );
     if substr(c1rec.home_page_options,15,1) = 'T'
      then
       htp.formcheckbox( 'P1', '15', 'CHECKED' );
      else
       htp.formcheckbox( 'P1', '15' );
     end if;
     htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG4.AHC_TXT_352 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.formtext( 'P5', 30, 100, c1rec.link_name ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
  else
   if c1rec.home_page_style <> 'T' then htp.formhidden( 'P5', null ); end if;
  end if;

  if c1rec.home_page_style in ('C','X','Z')
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG4.AHC_TXT_354 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.formtext( 'P4', 30, 100, c1rec.home_page_link ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
   else
    if c1rec.home_page_style <> 'T' then htp.formhidden( 'P4', null ); end if;
  end if;

  if c1rec.home_page_style = 'T'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Template Name' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.formtext( 'P4', 30, 100, c1rec.home_page_link ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Subdirectory' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.formtext( 'P5', 30, 100, c1rec.link_name ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
  end if;

  htp.tableclose;
  htp.nl;

  if c1rec.home_page_style = 'N'
   then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      htp.tabledata(htf.bold( lng.CST_TXT_042 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      notfound := TRUE;
      htp.formselectopen( 'P2' );
      for c2rec in c2(c1rec.scene_name, acid, owner_id ) loop
       notfound := FALSE;
       if c2rec.umo_scene_id = c1rec.home_page_category
        then
         htp.formselectoption( lpad('.', indnt(c2rec.parent_scene),'.') || c2rec.title, 'SELECTED', cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
        else
         htp.formselectoption( lpad('.', indnt(c2rec.parent_scene),'.') || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
       end if;
      end loop;
      if notfound
       then
        htp.formhidden( 'P2', NULL );
      end if;
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;
    htp.nl;

  elsif c1rec.home_page_style = 'V'
   then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
      if substr(c1rec.home_page_options,10,1) = 'T'
       then
        htp.formcheckbox( 'P1', '10', 'CHECKED' );
       else
        htp.formcheckbox( 'P1', '10' );
      end if;
      htp.p( '</TD>' );
      htp.tabledata( htf.bold( LNG4.AHC_TXT_591 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.formhidden( 'P2', c1rec.home_page_category );
    htp.tableclose;
    htp.nl;

  elsif c1rec.home_page_style = 'W'
   then
     htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      htp.tabledata(htf.bold( LNG5.EXT_TXT_053 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata(htf.bold( LNG5.EXT_TXT_056 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_429 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
     for c6rec in c6(acid) loop
      htp.tablerowopen;
       htp.tabledata(htf.anchor( 'pbk.homenews?surl=' || surl || '&acid=' || acid || '&hnw=' || c6rec.hnews,nvl(c6rec.title,LNG5.EXT_TXT_057)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata(htf.bold( c6rec.display_column ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata(htf.bold( c6rec.order_by ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
     end loop;
    htp.tableclose;
    htp.formhidden( 'P2', c1rec.home_page_category );
    htp.nl;
    htp.anchor( 'pbk.homenews?surl=' || surl || '&acid=' || acid || '&hnw=', LNG5.EXT_TXT_055 );
    htp.nl;

  else
   htp.formhidden( 'P2', c1rec.home_page_category );
  end if;

  if c1rec.home_page_style = 'Z'
   then
     htp.nl;
     htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      htp.tabledata(htf.bold( LNG5.EXT_TXT_053 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata(htf.bold( LNG5.EXT_TXT_056 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_429 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
     for c6rec in c6(acid) loop
      htp.tablerowopen;
       htp.tabledata(htf.anchor( 'pbk.homenews?surl=' || surl || '&acid=' || acid || '&hnw=' || c6rec.hnews,nvl(c6rec.title,LNG5.EXT_TXT_057)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata(htf.bold( c6rec.display_column ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata(htf.bold( c6rec.order_by ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
     end loop;
    htp.tableclose;
    htp.formhidden( 'P2', c1rec.home_page_category );
    htp.nl;
    htp.anchor( 'pbk.homenews?surl=' || surl || '&acid=' || acid || '&hnw=', LNG5.EXT_TXT_055 );
    htp.nl;
  end if;

  htp.nl;
  htp.formsubmit( null, LNG4.AHC_TXT_236 );
  htp.formclose;
  htp.nl;
  htp.p( '</CENTER>' );
  htp.htmlclose;

exception when others then
 glbx.error_details( 'PBK', 'HOME_PAGE_OPTION', errmsg=>sqlerrm);
end home_page_option;

procedure accept_home_page_option( surl in varchar2, acid in varchar2, p0 in varchar2, p2 in varchar2, p4 in varchar2, p5 in varchar2, pext in varchar2 default null, p1 in GLBX.MYARRAY )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_HOME_PAGE_OPTION', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  update customer_account
   set
    home_page_style = p0,
    home_page_override = pext,
    home_page_link = p4,
    link_name = p5,
    home_page_options = rpad('F',30,'F')
    where
     aid = acid and pid = owner_id;

  if p0 = 'N' then  update customer_account set home_page_category = p2 where aid = acid and pid = owner_id; end if;

  for j in p1.first..p1.last loop
   if p1(j) is not null
    then
     update customer_account
      set
       home_page_options = substr(home_page_options,1,to_number(p1(j))-1) || 'T' || substr(home_page_options,to_number(p1(j))+1),
       home_page_category = p2
     where
       aid = acid and pid = owner_id;
   end if;
  end loop;

  commit;
  home_page_option(surl,acid,LNG4.AHC_TXT_237);
exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_HOME_PAGE_OPTION', errmsg=>sqlerrm);
end accept_home_page_option;

procedure contactus( surl in varchar2, typ in varchar2 default 'P', msg in varchar2 default null )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.CONTACTUS', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG4.AHC_TXT_275, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P49',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;
  glbx.instruction( LNG4.AHC_TXT_277 || htf.nl || LNG4.AHC_TXT_276, pfx );
  htp.formopen( 'pbk.accept_contactus' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'TYP', typ );
  htp.formtextarea( 'P1', 10, 60 );
  htp.nl;
  htp.nl;
  htp.formsubmit( null, LNG4.AHC_TXT_278 );
  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'CONTACTUS', errmsg=>sqlerrm);
end contactus;

procedure accept_contactus( surl in varchar2, p1 in varchar2, typ in varchar2 )
as

 cursor c2(phgid integer) is select * from photographer where pid = phgid;

 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;
 snd		varchar2(4000);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_CONTACTUS', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if typ = 'P'
   then
    open c2( owner_id);
    fetch c2 into c2rec;
    close c2;
  end if;
  snd := substr( p1, 1, 4000 );
  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG4.AHC_TXT_275, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P49',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  if snd is not null
   then
    gcode(1) := 'PHOTOGRAPHER';
    gparam(1) := c2rec.business_name;
    gcode(2) := 'DETAILS';
    gparam(2) := snd;
    gcode(3) := 'SIGNATURE';
    gparam(3) := glbx.extract_master_parameter('MAIL SIGNATURE');
    glbx.send( gcode, gparam, 'contact_us.tmp', p_to=>glbx.extract_master_parameter('MAIL_FROM'), p_subj=>LNG4.AHC_TXT_275 || ':' || c2rec.business_name, p_from=>nvl(c2rec.contact_email,glbx.extract_master_parameter('MAIL_FROM')),ltype=>ltype,own_id=>owner_id, scode=>'CU1',v_pid=>owner_id);
    glbx.header_msg( LNG4.AHC_TXT_280 );
    htp.nl;
    htp.bold( snd );
    htp.nl;
   else
    glbx.header_msg( LNG4.AHC_TXT_281 );
  end if;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_CONTACTUS', errmsg=>sqlerrm);
end accept_contactus;

procedure mng_clearance_order( surl varchar2, mcid in integer, msg in varchar2 default null)
as

 cursor c1( phgid integer, mcid integer ) is select * from mfctr_clearance where mfc_clr_id = mcid and exists (select 'x' from mfctr_target_phg where pid = phgid and mfc_clr_id = mcid);
 cursor c3( mid integer, mcid integer ) is
  select *
  from mfctr_clearance_items mci
  where mfc_clr_id = mcid
  order by min_amount;
 cursor c4( mid integer, mcid integer ) is select * from shopping_basket where isgallery = 'C' and manufctr_code = mcid and lab_id = mid order by poid;
 cursor c5( vpoid integer ) is select * from purchase_order where poid = vpoid;

 c1rec		c1%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MNG_CLEARANCE_ORDER', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  open c1(owner_id, mcid );
  fetch c1 into c1rec;
  close c1;
  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG4.AHC_TXT_248,glbx.backimg(surl,owner_id,pfx.text_back,null),'L14',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.PHG_TXT_094 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG.PHG_TXT_083 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG.ORD_TXT_185 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   for c4rec in c4( c1rec.manufacturer_id, mcid ) loop
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
 glbx.error_details( 'PBK', 'MNG_CLEARANCE_ORDER', errmsg=>sqlerrm);
end mng_clearance_order;

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

procedure mng_profiles(surl varchar2, acid in integer, startid in varchar2 default 'AC', msg in varchar2 default null, search_profile in varchar2 default null, search_username in varchar2 default null, search_bftr in varchar2 default null, search_laf in varchar2 default null, search_aname in varchar2 default null, search_created in varchar2 default null )
as

 cursor c2(phid integer, acid integer) is select count('x') tot from customer_profile where aid = acid and pid = phid;
 cursor c3(phid integer) is select theme_name from theme order by theme_name;
 cursor c3a is select theme_type from theme_types order by theme_type;
 cursor c10(phid integer) is select theme_name from limit_laf where pid = phid order by theme_name;
 cursor c11(phid integer) is select limit_scene,limit_laf,limit_bf,skill_level,default_category,default_bf,default_lf from photographer where pid = phid;
 cursor c12(phid integer) is select theme_type from limit_bf where pid = phid order by theme_type;
 cursor c13(phid integer, acid integer) is
  select profile_id,username,theme_name,theme_type,account_name
  from customer_profile
  where aid=acid and pid=phid
  order by account_name,username;
 cursor c14(phid integer, acid integer, frm varchar2, fto varchar2) is
  select profile_id,username,theme_name,theme_type,account_name
  from customer_profile
  where aid=acid and
        pid=phid and
        upper(substr(username,1,1)) >= frm and
        upper(substr(username,1,1)) <= fto
  order by account_name,username;
 cursor c15(phid integer, acid integer, spr integer, search_username varchar2, search_bftr varchar2, search_laf varchar2, search_aname varchar2, search_created date) is
  select profile_id,username,theme_name,theme_type,account_name
  from customer_profile
  where aid=acid and
        pid=phid and
        (
         ((spr is null) or (spr is not null and profile_id = spr)) and
         ((search_username is null) or (search_username is not null and upper(username) like upper(search_username) || '%')) and
         ((search_bftr is null) or (search_bftr is not null and search_bftr = theme_type)) and
         ((search_laf is null) or (search_laf is not null and search_laf = theme_name)) and
         ((search_aname is null) or (search_aname is not null and upper(account_name) like upper(search_aname) || '%')) and
         ((search_created is null) or (search_username is not null and date_created >= search_created ))
        )
  order by account_name,username;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c11rec		c11%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 spr		integer;
 dte		date;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 tmp		varchar2(32767);

begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PBK.MNG_PROFILES', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  pfx := glbx.get_thm( c1rec.theme_name );
  theme_rec := get_theme_types( c1rec.aid, null );
  glbx.main_title( surl, LNG.PHG_TXT_089, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P50',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;
  open c2(owner_id,c1rec.aid);
  fetch c2 into c2rec;
  close c2;
  spr := glbx.guess_number( search_profile );

  if c2rec.tot >= 500 and
     (search_profile is null and search_username is null and search_bftr is null and search_laf is null and search_aname is null and search_created is null)
   then
    open c11( owner_id );
    fetch c11 into c11rec;
    close c11;
    -- Display Search Screen (too many to just display)
    htp.formopen( 'pbk.mng_profiles' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ACID', c1rec.aid );
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
     -- Profile Id
     htp.tablerowopen;
      htp.tabledata( 'Profile ID',cattributes=>pfx.qbground );
      htp.tabledata( htf.formtext( 'SEARCH_PROFILE', 10, 100 ),cattributes=>pfx.qcbground );
     htp.tablerowclose;
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
       if c11rec.limit_bf = 'T'
        then
         for c3arec in c3a loop
          tmp := tmp || htf.formselectoption( c3arec.theme_type );
         end loop;
        else
         for c12rec in c12(owner_id) loop
          tmp := tmp || htf.formselectoption( c12rec.theme_type );
         end loop;
       end if;
       tmp := tmp || htf.formselectclose;
      htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     -- Look and Feel
     htp.tablerowopen;
      htp.tabledata( LNG.CST_TXT_235,cattributes=>pfx.qbground );
       tmp := htf.formselectopen( 'SEARCH_LAF' );
       tmp := tmp || htf.formselectoption( NULL );
       if c11rec.limit_laf = 'T'
        then
         for c3rec in c3(owner_id) loop
          tmp := tmp || htf.formselectoption( c3rec.theme_name );
         end loop;
        else
         for c10rec in c10(owner_id) loop
          tmp := tmp || htf.formselectoption( c10rec.theme_name );
         end loop;
       end if;
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
    htp.htmlclose;
    return;

  elsif c2rec.tot >= 50 and c2rec.tot < 500
   then
    -- Display Index to Profiles as a way of limiting the number that are displayed
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
     htp.tablerowopen;
      htp.tabledata( htf.anchor('pbk.mng_profiles?surl=' || surl || '&acid=' || acid || '&startid=AC','[A-C]') );
      htp.tabledata( htf.anchor('pbk.mng_profiles?surl=' || surl || '&acid=' || acid || '&startid=DF','[D-F]') );
      htp.tabledata( htf.anchor('pbk.mng_profiles?surl=' || surl || '&acid=' || acid || '&startid=GI','[G-I]') );
      htp.tabledata( htf.anchor('pbk.mng_profiles?surl=' || surl || '&acid=' || acid || '&startid=JL','[J-L]') );
      htp.tabledata( htf.anchor('pbk.mng_profiles?surl=' || surl || '&acid=' || acid || '&startid=MO','[M-O]') );
      htp.tabledata( htf.anchor('pbk.mng_profiles?surl=' || surl || '&acid=' || acid || '&startid=PS','[P-S]') );
      htp.tabledata( htf.anchor('pbk.mng_profiles?surl=' || surl || '&acid=' || acid || '&startid=TV','[T-V]') );
      htp.tabledata( htf.anchor('pbk.mng_profiles?surl=' || surl || '&acid=' || acid || '&startid=WZ','[W-Z]') );
      htp.tabledata( htf.anchor('pbk.mng_profiles?surl=' || surl || '&acid=' || acid || '&startid=09','[0-9]') );
      htp.tabledata( htf.anchor('pbk.mng_profiles?surl=' || surl || '&acid=' || acid || '&startid=A[','[ALL]') );
     htp.tablerowclose;
    htp.tableclose;

  end if;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tableheader( LNG.GLB_TXT_076,cattributes=>pfx.qbground );
   htp.tableheader( LNG.PHG_TXT_129,cattributes=>pfx.qbground );
   htp.tableheader( LNG.CST_TXT_235,cattributes=>pfx.qbground );
   htp.tableheader( LNG.PHG_TXT_164,cattributes=>pfx.qbground );
   htp.tableheader( LNG.PHG_TXT_352,cattributes=>pfx.qbground );
   htp.tableheader( '&nbsp;',cattributes=>pfx.qbground );
  htp.tablerowclose;

  if c2rec.tot > 500
   then
    begin dte := to_date(search_created,LNG.MASK); exception when others then dte := NULL; end;
    for c15rec in c15( owner_id, c1rec.aid, spr, search_username, search_bftr, search_laf, search_aname, dte ) loop
    htp.tablerowopen;
     htp.tabledata( htf.anchor('phg.phg_acct_details?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c15rec.profile_id,c15rec.username),cattributes=>pfx.qcbground );
     htp.tabledata( c15rec.theme_type,cattributes=>pfx.qcbground );
     htp.tabledata( c15rec.theme_name,cattributes=>pfx.qcbground );
     htp.tabledata( c15rec.account_name,cattributes=>pfx.qcbground );
     htp.p( '<TD ' || pfx.qcbground || ' VALIGN="TOP" ALIGN="LEFT" CLASS="SMALL">' );
      htp.anchor('phg.mng_prof_scenes?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c15rec.profile_id, '.' || LNG.PHG_TXT_067);
      htp.nl;
      htp.anchor('phg.mng_prof_order?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c15rec.profile_id,'.' || LNG.PHG_TXT_064);
      htp.nl;
      htp.anchor2('phg.customer_logon?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c15rec.profile_id || '&login_type=PROFILE','.' || LNG3.ADM_TXT_040, ctarget=>'WIN' || to_char(sysdate,'SSSSS'));
      htp.p( '</TD>' );
      htp.p( '<TD ' || pfx.qcbground || ' VALIGN="TOP" ALIGN="LEFT" CLASS="SMALL">' );
      htp.anchor('phg.phg_prefs_phz?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c15rec.profile_id,'.' || LNG5.EXT_TXT_145);
      htp.nl;
      if substr(theme_rec.theme_data,394,1) = 'T'
       then
        htp.anchor('pbk.mng_authority?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c15rec.profile_id,'.' || 'Authority');
        htp.nl;
      end if;
      htp.p( '</TD>' );
    htp.tablerowclose;
    end loop;

  elsif c2rec.tot < 50
   then
    for c13rec in c13( owner_id, c1rec.aid ) loop
    htp.tablerowopen;
     htp.tabledata( htf.anchor('phg.phg_acct_details?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c13rec.profile_id,c13rec.username),cattributes=>pfx.qcbground );
     htp.tabledata( c13rec.theme_type,cattributes=>pfx.qcbground );
     htp.tabledata( c13rec.theme_name,cattributes=>pfx.qcbground );
     htp.tabledata( c13rec.account_name,cattributes=>pfx.qcbground );
     htp.p( '<TD ' || pfx.qcbground || ' VALIGN="TOP" ALIGN="LEFT" CLASS="SMALL">' );
      htp.anchor('phg.mng_prof_scenes?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c13rec.profile_id, '.' || LNG.PHG_TXT_067);
      htp.nl;
      htp.anchor('phg.mng_prof_order?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c13rec.profile_id,'.' || LNG.PHG_TXT_064);
      htp.nl;
      htp.anchor2('phg.customer_logon?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c13rec.profile_id || '&login_type=PROFILE','.' || LNG3.ADM_TXT_040, ctarget=>'WIN' || to_char(sysdate,'SSSSS'));
      htp.p( '</TD>' );
      htp.p( '<TD ' || pfx.qcbground || ' VALIGN="TOP" ALIGN="LEFT" CLASS="SMALL">' );
      htp.anchor('phg.phg_prefs_phz?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c13rec.profile_id,'.' || LNG5.EXT_TXT_145);
      htp.nl;
      if substr(theme_rec.theme_data,394,1) = 'T'
       then
        htp.anchor('pbk.mng_authority?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c13rec.profile_id,'.' ||  'Authority');
        htp.nl;
      end if;
      htp.p( '</TD>' );
    htp.tablerowclose;
    end loop;

   else
    for c13rec in c14( owner_id,c1rec.aid,substr(nvl(startid,'AC'),1,1),substr(nvl(startid,'AC'),2,1) ) loop
    htp.tablerowopen;
     htp.tabledata( htf.anchor('phg.phg_acct_details?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c13rec.profile_id,c13rec.username),cattributes=>pfx.qcbground );
     htp.tabledata( c13rec.theme_type,cattributes=>pfx.qcbground );
     htp.tabledata( c13rec.theme_name,cattributes=>pfx.qcbground );
     htp.tabledata( c13rec.account_name,cattributes=>pfx.qcbground );
     htp.p( '<TD ' || pfx.qcbground || ' VALIGN="TOP" ALIGN="LEFT" CLASS="SMALL">' );
      htp.anchor('phg.mng_prof_scenes?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c13rec.profile_id, '.' || LNG.PHG_TXT_067);
      htp.nl;
      htp.anchor('phg.mng_prof_order?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c13rec.profile_id,'.' || LNG.PHG_TXT_064);
      htp.nl;
      htp.anchor2('phg.customer_logon?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c13rec.profile_id || '&login_type=PROFILE','.' || LNG3.ADM_TXT_040, ctarget=>'WIN' || to_char(sysdate,'SSSSS'));
      htp.p( '</TD>' );
      htp.p( '<TD ' || pfx.qcbground || ' VALIGN="TOP" ALIGN="LEFT" CLASS="SMALL">' );
      htp.anchor('phg.phg_prefs_phz?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c13rec.profile_id,'.' || LNG5.EXT_TXT_145);
      htp.nl;
      if substr(theme_rec.theme_data,394,1) = 'T'
       then
        htp.anchor('pbk.mng_authority?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c13rec.profile_id,'.' || 'Authority');
        htp.nl;
      end if;
      htp.p( '</TD>' );
    htp.tablerowclose;
    end loop;
  end if;
  htp.tableclose;
  htp.nl;
  htp.formopen( 'phg.phg_acct_details' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ACID', c1rec.aid );
  htp.formhidden( 'PROFID', '0' );
  htp.formsubmit( null, LNG.PHG_TXT_088 );
  htp.formclose;
  htp.htmlclose;

exception when others then
 glbx.error_details( 'PBK', 'MNG_PROFILES', errmsg=>sqlerrm);
end mng_profiles;

procedure delete_profile(surl in varchar2, acid in integer, profid in integer, msg in varchar2 default null)
as

 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PBK.DELETE_PROFILE', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  pfx := glbx.get_thm( c1rec.theme_name );
  glbx.main_title(surl, 'Confirm Deletion of Profile' || ':' || c1rec.username,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P33',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.formopen( 'pbk.delete_profile_confirm' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'ACID', acid );
   htp.formhidden( 'PROFID', profid );
   htp.formsubmit( 'ACTION', 'Confirm Delete Profile' || ': ' || c1rec.username );
   htp.formsubmit( 'ACTION', 'Cancel' );
  htp.formclose;
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'DELETE_PROFILE', errmsg=>sqlerrm);
end delete_profile;

procedure delete_profile_confirm(surl in varchar2, acid in integer, profid in integer, action in varchar2)
as

 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PBK.DELETE_PROFILE_CONFIRM', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  if action = 'Cancel'
   then
    mng_profiles(surl,acid, 'Delete Cancelled');
    return;
  end if;

  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  delete from customer_contact where login_type = 'PROFILE' and aid = profid;
  delete from audit_profile_password where profile_id = profid;
  delete from customer_profile where profile_id = profid and aid = acid;
  commit;
  mng_profiles(surl,acid,LNG4.AHC_TXT_439);
exception when others then
 glbx.error_details( 'PBK', 'DELETE_PROFILE_CONFIRM', errmsg=>sqlerrm);
end delete_profile_confirm;

procedure album_mgmt(surl in varchar2, acid in integer, msg in varchar2 default null)
as

 cursor c2(acid integer) is select album_name,album_id from album where aid = acid and album_name is not null order by album_name;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PBK.ALBUM_MGMT', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  pfx := glbx.get_thm( c1rec.theme_name );
  glbx.main_title( surl, LNG4.AHC_TXT_453, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P51',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tableheader( LNG2.FNM_TXT_016,cattributes=>pfx.qbground );
   htp.tableheader( LNG4.AHC_TXT_462,cattributes=>pfx.qbground );
  htp.tablerowclose;
  for c2rec in c2(c1rec.aid) loop
   htp.tablerowopen;
    htp.tableheader( c2rec.album_name,cattributes=>pfx.qcbground );
    htp.tableheader( htf.anchor('pbk.manage_album?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&albid=' || c2rec.album_id,LNG4.AHC_TXT_460),cattributes=>pfx.qcbground );
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.anchor( 'pbk.manage_album?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&albid=0' ,LNG4.AHC_TXT_461 );
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'ALBUM_MGMT', errmsg=>sqlerrm);
end album_mgmt;

procedure gcertificate(surl in varchar2, acid in integer, msg in varchar2 default null)
as

 cursor c2(acid integer) is select username from customer_account where aid = acid;
 cursor c3(certid integer) is select * from gift_certificate_usage where certificate_id = certid order by date_used desc;
 cursor c4(phgid integer, acid integer) is
   select expiry_date,certificate_id,pid,aid,value,date_created,valid_only_customer,emailed_to,emailed_date
   from gift_certificate
   where pid = phgid and
         valid_only_customer = 'F'
  union all
   select expiry_date,certificate_id,pid,aid,value,date_created,valid_only_customer,emailed_to,emailed_date
   from gift_certificate
   where pid = phgid and
         valid_only_customer = 'T' and
         aid = acid
   order by 1 desc;
 cursor c5( phgid integer ) is select sum(amount_used) sm from gift_certificate_usage where certificate_id in (select certificate_id from gift_certificate where pid = phgid);
 cursor c6( phgid integer ) is select sum(value) sm from gift_certificate where pid = phgid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 foundrec	boolean;

begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PBK.GCERTIFICATE', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  pfx := glbx.get_thm( c1rec.theme_name );
  glbx.main_title( surl, LNG4.AHC_TXT_533, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P52',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( LNG4.AHC_TXT_534, cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG4.AHC_TXT_527, cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG.GLB_TXT_078, cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG4.AHC_TXT_531, cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG4.AHC_TXT_535, cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG4.AHC_TXT_529, cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG4.AHC_TXT_530, cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;

 for c4rec in c4( c1rec.pid, c1rec.aid ) loop
  htp.tablerowopen;
     htp.tabledata( htf.anchor( 'pbk.manage_gift?surl=' || surl || '&acid=' || acid || '&gcid=' || c4rec.certificate_id,c4rec.certificate_id), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( glbx.encrypt_data(c4rec.certificate_id), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( to_char(c4rec.date_created,LNG.TSMASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( to_char(c4rec.expiry_date,LNG.MASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     if c4rec.valid_only_customer = 'T'
      then
       open c2(c4rec.aid);
       fetch c2 into c2rec;
       close c2;
       htp.tabledata( LNG.PHG_TXT_046 || htf.nl || c2rec.username, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      else
       htp.tabledata( LNG.PHG_TXT_045, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     end if;
     htp.tabledata( to_char(c4rec.value,LNG.MONEY_FORMAT), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT" CLASS="SMALL">' );
     foundrec := FALSE;
     if sysdate > c4rec.expiry_date then htp.bold( LNG4.AHC_TXT_532 ); htp.nl; end if;
     for c3rec in c3( c4rec.certificate_id ) loop
      foundrec := TRUE;
      if c4rec.valid_only_customer = 'F'
       then
        open c2(c3rec.aid);
        fetch c2 into c2rec;
        close c2;
        htp.bold( to_char(c3rec.date_used,LNG.TSMASK) || ' ' || to_char(c3rec.amount_used, LNG.MONEY_FORMAT ) || ' (' || c2rec.username || ')');
       else
        htp.bold( to_char(c3rec.date_used,LNG.TSMASK) || ' ' || to_char(c3rec.amount_used, LNG.MONEY_FORMAT ) );
      end if;
      htp.nl;
     end loop;
     htp.bold( LNG4.AHC_TXT_530 || ':' || to_char(glbx.certificate_remaining( c4rec.certificate_id ), LNG.MONEY_FORMAT ));
     if not foundrec then htp.nl; htp.bold( LNG4.AHC_TXT_536 ); end if;
     htp.p( '</TD>' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 open c6(c1rec.pid);
 fetch c6 into c6rec;
 close c6;
 open c5(c1rec.pid);
 fetch c5 into c5rec;
 close c5;
 htp.p(htf.bold( LNG4.AHC_TXT_546 ) || ':' || to_char(nvl(c6rec.sm,0),LNG.MONEY_FORMAT));
 htp.nl;
 htp.p(htf.bold( LNG4.AHC_TXT_547 ) || ':' || to_char(nvl(c5rec.sm,0),LNG.MONEY_FORMAT));
 htp.nl;
 htp.p(htf.bold( LNG4.AHC_TXT_548 ) || ':' || to_char(nvl(c6rec.sm,0) - nvl(c5rec.sm,0),LNG.MONEY_FORMAT));
 htp.nl;
 htp.formopen( 'pbk.manage_gift' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );
  htp.formhidden( 'GCID', null );
  htp.formsubmit( null, LNG4.AHC_TXT_521 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'GCERTIFICATE', errmsg=>sqlerrm);
end gcertificate;

procedure manage_gift(surl in varchar2, acid in integer, gcid in integer, msg in varchar2 default null)
as

 cursor c3(certid integer) is select * from gift_certificate_usage where certificate_id = certid order by date_used desc;
 cursor c4(phgid integer, gcid integer) is select * from gift_certificate where pid = phgid and certificate_id = gcid order by date_created desc;

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PBK.MANAGE_GIFT', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  pfx := glbx.get_thm( c1rec.theme_name );
  if gcid is null
   then
    glbx.main_title( surl, LNG4.AHC_TXT_521, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P52',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   else
    glbx.main_title( surl, LNG4.AHC_TXT_520, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P52',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  end if;
  htp.nl;
  htp.p( '<CENTER>' );
  if gcid is null
   then
    select s_gift_certificate.nextval into c4rec.certificate_id from dual;
    c4rec.valid_only_customer := 'T';
    c4rec.expiry_date := add_months(sysdate,12);
   else
    open c4(owner_id,gcid);
    fetch c4 into c4rec;
    close c4;
  end if;
  if msg is not null then glbx.header_msg( msg ); end if;
  htp.formopen( 'pbk.accept_manage_gift' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );
  htp.formhidden( 'GCID', c4rec.certificate_id );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_534), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold(c4rec.certificate_id), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_527), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold(glbx.encrypt_data(c4rec.certificate_id)), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.GLB_TXT_078), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold(to_char(c4rec.date_created,LNG.TSMASK)), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   if c4rec.emailed_to is not null
    then
     htp.tabledata( htf.bold(LNG.PHG_TXT_301), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold(c4rec.emailed_to || htf.nl || to_char(c4rec.date_created,LNG.TSMASK)), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   end if;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    if c4rec.valid_only_customer = 'T'
     then
      htp.p( htf.formradio( 'P1', 'T', 'CHECKED' ) || ' ' || LNG4.AHC_TXT_525);
     else
      htp.p( htf.formradio( 'P1', 'T' ) || ' ' || LNG4.AHC_TXT_525);
    end if;
    htp.nl;
    if c4rec.valid_only_customer = 'F'
     then
      htp.p( htf.formradio( 'P1', 'F', 'CHECKED' ) || ' ' || LNG4.AHC_TXT_526);
     else
      htp.p( htf.formradio( 'P1', 'F' ) || ' ' || LNG4.AHC_TXT_526);
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_529), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P2', 20, 20, trim(to_char(c4rec.value,LNG.MONEY_FORMAT))), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_531), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P3', 20, 20, to_char(c4rec.expiry_date,LNG.MASK)), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;

  htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
  htp.tablerowopen;
  if gcid is null
   then
    htp.tabledata(htf.formsubmit( 'ACTION', LNG3.ADM_TXT_396 ));
   else
    htp.tabledata(htf.formsubmit( 'ACTION', LNG4.AHC_TXT_540 ));
    htp.tabledata(htf.formsubmit( 'ACTION', LNG4.AHC_TXT_537 ));
    open c3( gcid );
    fetch c3 into c3rec;
    if c3%FOUND
     then
      close c3;
     else
      close c3;
      htp.tabledata(htf.formsubmit( 'ACTION', LNG4.AHC_TXT_522 ));
    end if;
    if c4rec.emailed_to is null
     then
       htp.tablerowclose;
       htp.tableclose;
       htp.nl;
       htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
       htp.tablerowopen;
        htp.tabledata( LNG4.AHC_TXT_528, cattributes=>'VALIGN="TOP" ALIGN="RIGHT"');
        htp.tabledata( htf.formtext( 'P4', 30, 100 ));
       htp.tablerowclose;
       htp.tablerowopen;
        htp.tabledata( LNG4.AHC_TXT_542, cattributes=>'VALIGN="TOP" ALIGN="RIGHT"');
        htp.tabledata( htf.formtext( 'P5', 30, 100 ));
       htp.tablerowclose;
       htp.tablerowopen;
        htp.tabledata( LNG4.AHC_TXT_543, cattributes=>'VALIGN="TOP" ALIGN="RIGHT"');
        htp.tabledata( htf.formtextarea( 'P6', 5, 30, cattributes=>'WRAP="VIRTUAL"' ));
       htp.tablerowclose;
       htp.tablerowopen;
        htp.tabledata( '&nbsp;' );
        htp.tabledata( htf.formsubmit( 'ACTION', LNG4.AHC_TXT_545 ));
    end if;
  end if;
  htp.formclose;
  htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  glbx.certificate_history( c4rec, pfx );
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'MANAGE_GIFT', errmsg=>sqlerrm);
end manage_gift;

procedure accept_manage_gift(surl in varchar2, acid in integer, gcid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, action in varchar2, p4 in varchar2 default null, p5 in varchar2 default null, p6 in varchar2 default null)
as

 cursor c2( gcid integer ) is select * from gift_certificate where certificate_id = gcid;
 cursor c3( phgid integer ) is select * from photographer where pid = phgid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 nmb		number;
 dt		date;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_MANAGE_GIFT', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );

  open c2(gcid);
  fetch c2 into c2rec;
  close c2;

  open c3(c1rec.pid);
  fetch c3 into c3rec;
  close c3;

  begin nmb := to_number(p2); exception when others then begin nmb := to_number( p2, LNG.MONEY_FORMAT); exception when others then nmb := NULL; end; end;
  begin dt := to_date(p3,LNG.MASK); exception when others then dt := NULL; end;

  if action = LNG3.ADM_TXT_396
   then
    if p1 = 'T'
     then
      insert into gift_certificate(certificate_id,pid,aid,value,date_created,valid_only_customer,expiry_date,emailed_to,emailed_date) values
       (gcid,owner_id,c1rec.aid,nmb,sysdate,'T',dt,null,null);
     else
      insert into gift_certificate(certificate_id,pid,aid,value,date_created,valid_only_customer,expiry_date,emailed_to,emailed_date) values
       (gcid,owner_id,null,nmb,sysdate,'F',dt,null,null);
    end if;
  elsif action = LNG4.AHC_TXT_522
   then
    delete from gift_certificate_usage where certificate_id in (select certificate_id from gift_certificate where certificate_id = gcid and pid = owner_id);
    delete from gift_certificate where certificate_id = gcid and pid = owner_id;
  else
   update gift_certificate
    set
     value = nmb,
     valid_only_customer = p1,
     expiry_date = dt
   where certificate_id = gcid;

   if action = LNG4.AHC_TXT_545 and p4 is not null
    then
     gcode(1) := 'REFERENCE_ID';
     gparam(1) := glbx.encrypt_data(gcid);
     gcode(2) := 'PHOTOGRAPHER';
     gparam(2) := c3rec.business_name;
     gcode(3) := 'REPLY_EMAIL';
     gparam(3) := c3rec.contact_email;
     gcode(4) := 'SENDTO';
     gparam(4) := p5;
     gcode(5) := 'MESSAGE';
     gparam(5) := p6;
     gcode(6) := 'VALUE';
     gparam(6) := to_char(nmb,LNG.MONEY_FORMAT);
     gcode(7) := 'EXPIRES';
     gparam(7) := to_char(dt,LNG.MASK);
     gcode(8) := 'SIGNATURE';
     gparam(8) := glbx.extract_master_parameter('MAIL SIGNATURE');
     glbx.send( gcode, gparam, 'gift_certificate.tmp', p_to=>p4, p_subj=>LNG4.AHC_TXT_544, p_from=>nvl(c3rec.contact_email,glbx.extract_master_parameter('MAIL_FROM')),ltype=>ltype,own_id=>owner_id, scode=>'GCT1',v_pid=>owner_id,v_aid=>acid);
     update gift_certificate
      set
       emailed_to = p4,
       emailed_date = sysdate
     where certificate_id = gcid;
   end if;
  end if;

  commit;

  if action in (LNG4.AHC_TXT_522,LNG4.AHC_TXT_540)
   then
    gcertificate(surl,acid,LNG4.AHC_TXT_539);
   elsif action = LNG3.ADM_TXT_396
    then
     manage_gift(surl,acid,gcid,LNG4.AHC_TXT_539);
   elsif action = LNG4.AHC_TXT_545 and p4 is not null
    then
     manage_gift(surl,acid,gcid,LNG4.AHC_TXT_541);
   else
    manage_gift(surl,acid,gcid,LNG4.AHC_TXT_538);
  end if;

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_MANAGE_GIFT', errmsg=>sqlerrm);
end accept_manage_gift;

procedure increase_event_plan(surl in varchar2, msg in varchar2 default null )
as

 cursor c1( phgid integer ) is select * from photographer where pid = phgid;
 cursor c3( phgid integer, plid integer) is
  select cp.pid,cp.plan_id,cp.plan_event,cp.qty,cpe.standard_charge,cpe.images_max, cpe.days_expires
  from charge_plan_event_phg cp, charge_plan_event cpe
  where cp.plan_id = plid and
        cp.pid = phgid and
        cp.plan_id = cpe.plan_id and
        cp.plan_event = cpe.plan_event
  order by cp.plan_event;
 cursor c4(plid integer, pev varchar2) is select * from charge_plan_event_bulk where plan_id = plid and plan_event = pev order by min_number;
 cursor c5(plid integer) is select count('x') tot from charge_plan_event_bulk where plan_id = plid;


 c1rec		c1%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 foundrec	boolean;
 foundrec2	boolean;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.INCREASE_EVENT_PLAN', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG4.AHC_TXT_557, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P53',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( nvl(msg,LNG4.AHC_TXT_561) );end if;
  open c1(owner_id);
  fetch c1 into c1rec;
  close c1;
  open c5(c1rec.plan_id);
  fetch c5 into c5rec;
  close c5;
  c5rec.tot := nvl(c5rec.tot,0);
  htp.formopen( 'pbk.accept_increase_event' );
  htp.formhidden( 'SURL', surl );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_074 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_530 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_787 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.PHG_ALT_399 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    -- Bulk Pricing if available (specify what the rates are)
    if c5rec.tot > 0
     then
      htp.tabledata( htf.bold( LNG5.EXT_TXT_571 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' ); -- Max Images
    end if;
    htp.tabledata( htf.bold( LNG3.ADM_TXT_788 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' ); -- Max Images
    htp.tabledata( htf.bold( LNG3.ADM_TXT_111 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;
   foundrec := FALSE;
   for c3rec in c3( owner_id, c1rec.plan_id ) loop
    foundrec := TRUE;
    htp.tablerowopen;
    htp.formhidden( 'P0', c3rec.plan_id );
    htp.formhidden( 'P1', c3rec.plan_event );
     htp.tabledata( htf.formtext( 'P2', 5, 10, '0' ) , cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( htf.bold( nvl(c3rec.qty,0) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
     htp.tabledata( c3rec.plan_event, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
     htp.tabledata( to_char(c3rec.standard_charge,LNG.MONEY_FORMAT), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
     if c5rec.tot > 0
      then
       htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="RIGHT">' );
       foundrec2 := FALSE;
       for c4rec in c4(c3rec.plan_id, c3rec.plan_event) loop
        foundrec := TRUE;
        htp.p( c4rec.min_number || '-' || c4rec.max_number || ' ' || htf.bold(to_char(c4rec.standard_charge,LNG.MONEY_FORMAT)));
        htp.nl;
       end loop;
       if not foundrec2 then htp.p( LNG5.EXT_TXT_572 ); end if; -- None Available
       htp.p( '</TD>' );
     end if;
     htp.tabledata( c3rec.images_max, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
     htp.tabledata( nvl(to_char(c3rec.days_expires),'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
    htp.tablerowclose;
   end loop;
  htp.tableclose;
  htp.nl;
  htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
  htp.tablerowopen;
  if foundrec then htp.tabledata(htf.formsubmit( null, LNG4.AHC_TXT_560 )); end if;
  htp.formclose;
  htp.formopen( 'phg.phg_accts' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'RND', to_char(sysdate,'SSSSS'));
  htp.tabledata(htf.formsubmit( null, LNG4.AHC_TXT_567 ));
  htp.formclose;
  htp.tablerowclose;
  htp.tableclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'INCREASE_EVENT_PLAN', errmsg=>sqlerrm);
end increase_event_plan;

procedure accept_increase_event(surl in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 cursor c1( phgid integer ) is select * from photographer where pid = phgid;
 cursor c3( phgid integer, plid integer) is
  select cp.pid,cp.plan_id,cp.plan_event,cp.qty,cpe.standard_charge,cpe.images_max, cpe.days_expires
  from charge_plan_event_phg cp, charge_plan_event cpe
  where cp.plan_id = plid and
        cp.pid = phgid and
        cp.plan_id = cpe.plan_id and
        cp.plan_event = cpe.plan_event
  order by cp.plan_event;
 cursor c4(plid integer, pev varchar2, qty integer) is select standard_charge from charge_plan_event_bulk where plan_id = plid and plan_event = pev and qty >= min_number and qty <= max_number;
 cursor c5(acct varchar2) is select aid from customer_account where username = upper(acct);

 c1rec		c1%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		integer;
 ttl		number;
 pfx		THEME%ROWTYPE;
 validrec	boolean;
 usr		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_INCREASE_EVENT', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  --
  -- Check if an Account Exists for Payment
  --
  usr := glbx.extract_master_parameter('ONLINE_ORDER_ACCOUNT');
  open c5(usr);
  fetch c5 into c5rec;
  close c5;
  if c5rec.aid is not null then phg_online_order(surl, p0, p1, p2 ); return; end if;

  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG4.AHC_TXT_563, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P53',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  glbx.header_msg( LNG4.AHC_TXT_562 );
  htp.p( '<CENTER>' );
  open c1(owner_id);
  fetch c1 into c1rec;
  close c1;
  htp.formopen( 'pbk.confirm_increase_event' );
  htp.formhidden( 'SURL', surl );
  validrec := FALSE;
  for j in p0.first..p0.last loop
   htp.formhidden( 'P0', p0(j) );
   htp.formhidden( 'P1', p1(j) );
   begin nmb := to_number(p2(j)); if nmb > 0 then validrec := TRUE; end if; exception when others then nmb := NULL; end;
   htp.formhidden( 'P2', p2(j) );
  end loop;

  if not validrec
   then
    htp.init;
    increase_event_plan( surl, LNG4.AHC_TXT_566 );
    return;
  end if;

  ttl := 0;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_074 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_530 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_787 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.PHG_ALT_399 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_788 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_111 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.PHG_TXT_095 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;
   for c3rec in c3( owner_id, c1rec.plan_id ) loop
    htp.tablerowopen;
     begin
        nmb := to_number(p2( c3%ROWCOUNT ));
        htp.tabledata( htf.bold( nmb ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     exception
      when others
       then
        nmb := NULL;
        htp.tabledata( htf.bold( LNG.PHG_TXT_210), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     end;
     if nmb is not null and nmb > 0
      then
       htp.tabledata( htf.bold(to_char(nvl(c3rec.qty,0)+nmb)) || '(' || c3rec.qty || ')', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
      else
       htp.tabledata( htf.bold( nvl(c3rec.qty,0) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
     end if;
     htp.tabledata( c3rec.plan_event, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
     -- Extract Bulk Discount Price
     open c4(c3rec.plan_id,c3rec.plan_event,nmb);
     fetch c4 into c4rec;
     close c4;
     c3rec.standard_charge := nvl(c4rec.standard_charge,c3rec.standard_charge);
     htp.tabledata( to_char(c3rec.standard_charge,LNG.MONEY_FORMAT), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
     htp.tabledata( c3rec.images_max, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
     htp.tabledata( nvl(to_char(c3rec.days_expires),'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
     if nmb is not null and nmb > 0
      then
       ttl := ttl + nmb * c3rec.standard_charge;
       htp.tabledata( htf.bold( trim(to_char((c3rec.standard_charge * nmb),LNG.MONEY_FORMAT ))), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
      else
       htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
     end if;
    htp.tablerowclose;
   end loop;
  if ttl > 0
   then
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( htf.bold(LNG.ORD_TXT_108), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
     htp.tabledata( htf.bold(trim(to_char(ttl,LNG.MONEY_FORMAT))), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
  end if;
  htp.tableclose;
  htp.nl;
  htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
  htp.tablerowopen;
  htp.tabledata( htf.formsubmit( 'ACTION', LNG4.AHC_TXT_564 ));
  htp.tabledata( htf.formsubmit( 'ACTION', LNG4.AHC_TXT_558 || ' ' || trim(to_char(ttl,LNG.MONEY_FORMAT)) ) );
  htp.tablerowclose;
  htp.tableclose;
  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_INCREASE_EVENT', errmsg=>sqlerrm);
end accept_increase_event;

procedure confirm_increase_event(surl in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, action in varchar2 )
as

 cursor c1( plid integer, plevent varchar2 ) is select * from charge_plan_event where plan_id = plid and plan_event = plevent;
 cursor c2( phgid integer ) is select * from photographer where pid = phgid;
 cursor c4(plid integer, pev varchar2, qty integer) is select standard_charge from charge_plan_event_bulk where plan_id = plid and plan_event = pev and qty >= min_number and qty <= max_number;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 inv		integer;
 pfx		THEME%ROWTYPE;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin
  if action = 'BYPASS'
   then
     glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.CONFIRM_INCREASE_EVENT', iscust=>FALSE, reset=>FALSE );
   else
     glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.CONFIRM_INCREASE_EVENT', iscust=>FALSE );
  end if;
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if action = LNG4.AHC_TXT_564
   then
    increase_event_plan( surl );
    return;
  end if;

  open c2(owner_id);
  fetch c2 into c2rec;
  close c2;

  select s_purchase_order.nextval into inv from dual;

  for j in p0.first..p0.last loop
   if p2(j) > 0
    then
      open c1(p0(j),p1(j));
      fetch c1 into c1rec;
      close c1;
      -- Extract Bulk Discount Price
      c4rec.standard_charge := NULL;
      open c4(p0(j),p1(j),p2(j));
      fetch c4 into c4rec;
      close c4;
      c1rec.standard_charge := nvl(c4rec.standard_charge,c1rec.standard_charge);
      gcode(1) := 'DATE';
      gparam(1) := to_char(sysdate,LNG.TSMASK);
      gcode(2) := 'PHOTOGRAPHER';
      gparam(2) := c2rec.business_name;
      gcode(3) := 'QTY';
      gparam(3) := p2(j);
      gcode(4) := 'PLAN_EVENT';
      gparam(4) := p1(j);
      gcode(5) := 'CHARGE';
      gparam(5) := trim(to_char(c1rec.standard_charge*to_number(p2(j)),LNG.MONEY_FORMAT));
      gcode(6) := 'INVOICE';
      gparam(6) := to_char(inv);

      update charge_plan_event_phg
       set
        qty = nvl(qty,0) + to_number(p2(j))
       where
        pid = owner_id and
        plan_id = p0(j) and
        plan_event = p1(j);

      insert into charge_plan_invoice(pid,plan_id,plan_event,qty,standard_charge,date_purchased,invoice_id,invoice_sent,invoice_sent_dt,invoice_rec,invoice_rec_dt) values
       (owner_id,p0(j),p1(j),p2(j),c1rec.standard_charge,sysdate,inv,'F',null,'F',null);

      gcode(7) := 'SIGNATURE';
      gparam(7) := glbx.extract_master_parameter('MAIL SIGNATURE');
      glbx.send( gcode, gparam, 'new_customer_invoice.tmp', p_to=>glbx.extract_master_parameter('PICTION_EMAIL_ACCT'), p_subj=>LNG4.AHC_TXT_565 || '-' || c2rec.business_name || ':' || inv, p_from=>glbx.extract_master_parameter('MAIL_FROM'),ltype=>ltype,own_id=>owner_id, scode=>'NCI1',v_pid=>owner_id);
      if c2rec.contact_email is not null
       then
        glbx.send( gcode, gparam, 'new_customer_invoice_phg.tmp', p_to=>c2rec.contact_email, p_subj=>LNG4.AHC_TXT_565 || '-' || c2rec.business_name || ':' || inv, p_from=>glbx.extract_master_parameter('MAIL_FROM'),ltype=>ltype,own_id=>owner_id, scode=>'NCIP',v_pid=>owner_id);
      end if;
   end if;
  end loop;

  commit;

  if action = 'BYPASS'
   then
    null;
   else
   phg.phg_create_new_acct(surl);
  end if;
  -- phg.phg_accts( surl, to_char(sysdate,'SSSSS' ), msg=>LNG4.AHC_TXT_568 );

exception when others then
 glbx.error_details( 'PBK', 'CONFIRM_INCREASE_EVENT', errmsg=>sqlerrm);
end confirm_increase_event;

procedure phg_online_order(surl in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 cursor c1(acct varchar2) is select * from customer_account where username = upper(acct);
 cursor c2( plid integer, plevent varchar2 ) is select * from charge_plan_event where plan_id = plid and plan_event = plevent;
 cursor c3( phgid integer ) is select * from photographer where pid = (select aid from login_session where sessid = phgid);
 cursor c4(plid integer, pev varchar2, qty integer) is select standard_charge from charge_plan_event_bulk where plan_id = plid and plan_event = pev and qty >= min_number and qty <= max_number;
 cursor c5(sess_id integer) is select count('x') cnt from purchase_order po, shopping_basket sb where po.sessid = sess_id and po.poid = sb.poid and po.status <> LNG.ORD_TXT_120 and sb.isgallery = 'Z';

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 sts		varchar2(100);
 cusrec		c1%ROWTYPE;
 purch		purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 b2c_value	char(1);
 nmb		integer;
 usr		varchar2(100);
 tval1		varchar2(100);
 tval2		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, sess_id, sts, 'S', progcalled=>'PBK.PHG_ONLINE_RDER', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  usr := glbx.extract_master_parameter('ONLINE_ORDER_ACCOUNT');
  open c1(usr);
  fetch c1 into cusrec;
  close c1;

  open c3(sess_id);
  fetch c3 into c3rec;
  close c3;

  voidrec := glbx.get_order_style(glbx.get_order_style( cusrec.aid, null, 'OWNER', b2c_value ));

  open c5(sess_id);
  fetch c5 into c5rec;
  close c5;
  if nvl(c5rec.cnt,0) > 0
   then
    htp.nl;
    htp.bold( 'Only allowed to Purchase one set of Accounts per Login.' );
    htp.nl;
    htp.nl;
    htp.bold( 'To Purchase another set, you must Relogin again.' );
    htp.nl;
    htp.nl;
    htp.anchor2( 'glbx.relogin?surl=' || surl || '&acid=' || c3rec.pid, LNG4.AHC_TXT_320, ctarget=>'_top' );
    return;
  end if;

  delete from shopping_basket where poid in (select poid from purchase_order where sessid = sessid);
  delete from purchase_order where sessid = sessid;
  fname.create_purchase_order(surl, sess_id, LNG.ORD_TXT_120, null, ltype, cusrec, voidrec, purch);
  glbx.fixnm(c3rec.contact_name,tval1,tval2);
  update purchase_order
   set
    sendto_name = c3rec.contact_name,
    sendto_firstname = tval1,
    sendto_lastname = tval2,
    sendto_street = c3rec.contact_street,
    sendto_suburb = c3rec.contact_suburb,
    sendto_city = c3rec.contact_city,
    sendto_postcode = c3rec.contact_pcode,
    contact_email = c3rec.contact_email
  where poid = purch.poid;
  commit;

  for j in p0.first..p0.last loop
   begin nmb := to_number(p2(j)); exception when others then nmb := null; end;
   nmb := nvl(nmb,0);
   if nmb > 0
    then
      open c2(p0(j),p1(j));
      fetch c2 into c2rec;
      close c2;
      c4rec.standard_charge := NULL;
      open c4(p0(j),p1(j),p2(j));
      fetch c4 into c4rec;
      close c4;
      c2rec.standard_charge := nvl(c4rec.standard_charge,c2rec.standard_charge);
      insert into shopping_basket(poid,shopping_id,qty,photo_size,photo_cost,isgallery,phid,lab_id)
       values
        (purch.poid,s_shopping_basket.nextval,nmb,p1(j),c2rec.standard_charge,'Z',c3rec.pid,p0(j));
   end if;
  end loop;
  commit;
  fname.disp_payment_screen( surl, acid=>cusrec.aid, calltype=>'PHOTOGRAPHER_ORDER' );

exception when others then
 glbx.error_details( 'PBK', 'PHG_ONLINE_RDER', errmsg=>sqlerrm);
end phg_online_order;

procedure mng_usr_event(surl in varchar2, acid in integer, pagenmb in integer default 1, msg in varchar2 default null )
as

 cursor c2( acid integer ) is
  select min(um.extras.orderby_nmb) min_nmb, max(um.extras.orderby_nmb) max_nmb, count(um.extras.orderby_nmb) count_nmb, count(distinct um.extras.orderby_nmb) distinct_nmb
  from umo um
  where aid = acid;

 cursor c2a( acid integer ) is select max(client_id) max_nmb from virtual_logon where aid = acid;

 cursor c3( acid integer, pagenmb integer ) is
  select *
  from virtual_logon
  where aid = acid and
        client_id between pagenmb and (pagenmb+99)
  order by client_id;

 cursor c4( acid integer, client_id integer ) is
  select count('x') tot
  from umo um
  where aid = acid and
        um.extras.orderby_nmb = client_id;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c2arec		c2a%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 foundrec	boolean;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MNG_USR_EVENT', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  pfx := glbx.get_thm( c1rec.theme_name );
  glbx.main_title( surl, LNG4.AHC_TXT_580, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P54',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg );end if;
  open c2(acid);
  fetch c2 into c2rec;
  close c2;
  open c2a(acid);
  fetch c2a into c2arec;
  close c2a;

  htp.formopen( 'pbk.accept_mng_usr_event' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );
  htp.formhidden( 'PAGENMB', pagenmb );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );

   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_569),cattributes=>pfx.qbground );
     htp.p( '<TD ' || pfx.qcbground || '>' );
     htp.formselectopen( 'PE1' );
      if c1rec.site_type = 'S'
       then
        htp.formselectoption( LNG.GLB_TXT_086, 'SELECTED', cattributes=>'VALUE="S"'  );
       else
        htp.formselectoption( LNG.GLB_TXT_086, cattributes=>'VALUE="S"'  );
      end if;
      if c1rec.site_type = 'P'
       then
        htp.formselectoption( LNG4.AHC_TXT_570, 'SELECTED', cattributes=>'VALUE="P"'  );
       else
        htp.formselectoption( LNG4.AHC_TXT_570, cattributes=>'VALUE="P"'  );
      end if;
      if c1rec.site_type = 'V'
       then
        htp.formselectoption( LNG4.AHC_TXT_571, 'SELECTED', cattributes=>'VALUE="V"'  );
       else
        htp.formselectoption( LNG4.AHC_TXT_571, cattributes=>'VALUE="V"'  );
      end if;
     htp.formselectclose;
     htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_579),cattributes=>pfx.qbground );
     htp.p( '<TD ' || pfx.qcbground || '>' );
     if c1rec.event_logon_uses_code = 'T'
      then
       htp.formradio( 'PE2', 'T', 'CHECKED' );
      else
       htp.formradio( 'PE2', 'T' );
     end if;
     htp.p( ' ' || LNG4.AHC_TXT_572 );
     htp.nl;
     if c1rec.event_logon_uses_code = 'F'
      then
       htp.formradio( 'PE2', 'F', 'CHECKED' );
      else
       htp.formradio( 'PE2', 'F' );
     end if;
     htp.p( ' ' || LNG4.AHC_TXT_573 );
     htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_574),cattributes=>pfx.qbground );
     htp.p( '<TD ' || pfx.qcbground || '>' );
     htp.formselectopen( 'PE3' );
     if c1rec.event_logon_password_style = 'O'
      then
       htp.formselectoption( LNG4.AHC_TXT_575, 'SELECTED', cattributes=>'VALUE="O"'  );
      else
       htp.formselectoption( LNG4.AHC_TXT_575, cattributes=>'VALUE="O"'  );
     end if;
     if c1rec.event_logon_password_style = 'M'
      then
       htp.formselectoption( LNG4.AHC_TXT_576, 'SELECTED', cattributes=>'VALUE="M"'  );
      else
       htp.formselectoption( LNG4.AHC_TXT_576, cattributes=>'VALUE="M"'  );
     end if;
     if c1rec.event_logon_password_style = 'S'
      then
       htp.formselectoption( LNG4.AHC_TXT_577, 'SELECTED', cattributes=>'VALUE="S"'  );
      else
       htp.formselectoption( LNG4.AHC_TXT_577, cattributes=>'VALUE="S"'  );
     end if;
     if c1rec.event_logon_password_style = 'I'
      then
       htp.formselectoption( LNG4.AHC_TXT_578, 'SELECTED', cattributes=>'VALUE="I"'  );
      else
       htp.formselectoption( LNG4.AHC_TXT_578, cattributes=>'VALUE="I"'  );
     end if;
    htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;

   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG3.ADM_TXT_191),cattributes=>pfx.qbground );
    htp.tabledata( htf.formtext( 'PE4', 20, 20, c1rec.photographer_account_id), cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_583),cattributes=>pfx.qbground );
    htp.tabledata( c2rec.min_nmb, cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_584),cattributes=>pfx.qbground );
    htp.tabledata( c2rec.max_nmb, cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.PHG_ALT_127),cattributes=>pfx.qbground );
    htp.tabledata( c2rec.count_nmb, cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG4.AHC_TXT_586),cattributes=>pfx.qbground );
    htp.tabledata( c2rec.distinct_nmb, cattributes=>pfx.qcbground );
   htp.tablerowclose;
  htp.tableclose;
  htp.anchor2( 'pbk.reverse_event?surl=' || surl || '&acid=' || acid, LNG4.AHC_TXT_596 ,ctarget=>'REVERSE_WINDOW' );
  htp.nl;

  -- Display Page Numbers for Navigation
  if c2arec.max_nmb > 100
   then
    htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
    htp.tablerowopen;
    for j in 1..(trunc(c2arec.max_nmb/100)+1) loop
     htp.tabledata( htf.anchor( 'pbk.mng_usr_event?surl=' || surl || '&acid=' || acid || '&pagenmb=' || to_char(((j-1)*100)+1), '[' || to_char(((j-1)*100)+1) || '-' || to_char(((j-1)*100)+100) || ']' ));
    end loop;
    htp.tablerowclose;
    htp.tableclose;
  end if;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    if c1rec.site_type = 'V'
     then
      htp.tabledata( htf.bold( LNG4.AHC_TXT_570 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.formhidden( 'ISPUB', NULL );
     else
      htp.formhidden( 'ISPUB', NULL );
    end if;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_587 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.PHG_ALT_127 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_588 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_589 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.GLB_TXT_076 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.GLB_TXT_018 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.PHG_TXT_465 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;
   for c3rec in c3(acid,pagenmb) loop
   htp.tablerowopen;
    htp.formhidden( 'P0', c3rec.client_id );
    if c1rec.site_type = 'V'
     then
      if c3rec.public_event = 'T'
       then
         htp.tabledata( htf.formcheckbox( 'ISPUB', c3rec.client_id, 'CHECKED'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
         htp.tabledata( htf.formcheckbox( 'ISPUB', c3rec.client_id), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
    end if;
    htp.tabledata( htf.formtext( 'P1', 10, 20, c3rec.client_id), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    open c4(acid,c3rec.client_id);
    fetch c4 into c4rec;
    close c4;
    htp.tabledata( c4rec.tot, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
    htp.tabledata( htf.formtext( 'P2', 20, 100, c3rec.first_name), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P3', 20, 100, c3rec.surname), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata(htf.anchor2('phg.customer_logon?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || c3rec.client_id || '&login_type=VIRTUAL',c3rec.username, ctarget=>'WIN' || to_char(sysdate,'SSSSS')), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    if c1rec.event_logon_password_style = 'M'
     then
      htp.tabledata( htf.formtext( 'P4', 20, 100, c3rec.password), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      htp.formhidden( 'P4', c3rec.password );
      htp.tabledata( c3rec.password, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
    htp.tabledata( nvl(c3rec.extra_details,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   end loop;
   for j in 1..10 loop
   htp.tablerowopen;
    htp.formhidden( 'P0', null );
    if c1rec.site_type = 'V'
     then
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
    htp.tabledata( htf.formtext( 'P1', 10, 20, null), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P2', 20, 100, null), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P3', 20, 100, null), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    if c1rec.event_logon_password_style = 'M'
     then
      htp.tabledata( htf.formtext( 'P4', 20, 100, null), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      htp.formhidden( 'P4', null );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
    htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   end loop;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, LNG4.AHC_TXT_590 );
  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'MNG_USR_EVENT', errmsg=>sqlerrm);
end mng_usr_event;

procedure accept_mng_usr_event(surl in varchar2, acid in integer, pe1 in varchar2, pe2 in varchar2, pe3 in varchar2, pe4 in varchar2, pagenmb in integer, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, ispub in GLBX.MYARRAY )
as

 cursor c2(acid integer, clid integer) is select 'x' ex from virtual_logon where aid = acid and client_id = clid;
 cursor c3(acid integer) is select pw from audit_customer_password where aid= acid and date_changed = (select max(date_changed) from audit_customer_password where aid = acid);
 cursor c14( acid integer, jobref varchar2 ) is select 'x' exst from customer_account where upper(photographer_account_id) = upper(jobref) and aid <> acid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c14rec		c14%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		integer;
 pw		varchar2(100);
 currpw		varchar2(100);
 uname		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_MNG_USR_EVENT', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  open c3(acid);
  fetch c3 into currpw;
  close c3;

  update customer_account
   set
    site_type = pe1,
    event_logon_uses_code = pe2,
    event_logon_password_style = pe3,
    photographer_account_id = upper(pe4)
  where
   pid = owner_id and
   aid = acid;

  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );

  for j in p0.first..p0.last loop
   begin nmb := to_number(p1(j)); exception when others then nmb := NULL; end;

   -- Work out Password
   if c1rec.event_logon_password_style = 'M' and p4(j) is null
    then
     pw := upper(p3(j));
   elsif c1rec.event_logon_password_style = 'M' and p4(j) is not null
    then
     pw := upper(p4(j));
   elsif c1rec.event_logon_password_style = 'O'
    then
     pw := currpw;
   elsif c1rec.event_logon_password_style = 'S'
    then
     pw := upper(nvl(p3(j),to_char(nmb)));
   elsif c1rec.event_logon_password_style = 'I'
    then
     pw := to_char(nmb);
   end if;
   pw := nvl(pw,to_char(nmb));

   -- Work out Username
   if c1rec.event_logon_uses_code = 'T'
    then
     uname := c1rec.photographer_account_id || to_char(nmb);
    else
     uname := to_char(nmb);
   end if;

   if p0(j) is null
    then
     if nmb is null
      then
       null;
      else
       -- Insert new logon
       open c2(acid, nmb );
       fetch c2 into c2rec;
       if c2%NOTFOUND
        then
         insert into virtual_logon(aid,client_id,first_name,surname,username,password) values
          (acid,nmb,p2(j),upper(p3(j)),uname,pw);
       end if;
       close c2;
     end if;

   else

      if nmb is null
       then
        -- Delete
        delete from virtual_logon where aid = acid and client_id = p0(j);
      elsif nmb <> p0(j)
       then
        -- Rename but make sure the Client Id does not already exist
       open c2(acid, nmb );
       fetch c2 into c2rec;
       if c2%NOTFOUND
        then
         update virtual_logon
          set
           client_id = nmb,
           public_event = 'F',
           first_name = p2(j),
           surname = upper(p3(j)),
           username = uname,
           password = pw
           where aid = acid and
                 client_id = p0(j);
       end if;
       close c2;
      else
         update virtual_logon
          set
           first_name = p2(j),
           public_event = 'F',
           surname = upper(p3(j)),
           username = uname,
           password = pw
           where aid = acid and
                 client_id = p0(j);
      end if;
    end if;
  end loop;

  if c1rec.site_type = 'V' -- Private Event, enable disable public events
   then
    for j in ispub.first..ispub.last loop
     if ispub(j) is not null
      then
       update virtual_logon
        set
         public_event = 'T'
       where
        aid = c1rec.aid and
        client_id = ispub(j);
     end if;
    end loop;
  end if;

 -- Perform Mass Updates of the Passwords, except for Manual Ones
 if c1rec.event_logon_password_style = 'O'
  then
    update virtual_logon
     set
      password = currpw
     where aid = acid;
 elsif c1rec.event_logon_password_style = 'S'
  then
    update virtual_logon
     set
      password = upper(surname)
     where aid = acid;
 elsif c1rec.event_logon_password_style = 'I'
  then
    update virtual_logon
     set
      password = to_char(client_id)
     where aid = acid;
 end if;

 commit;

 if nvl(pe1,'S') <> 'S' and pe4 is null
  then
    mng_usr_event(surl,acid,pagenmb,LNG4.AHC_TXT_581 );
    return;
 end if;

 -- If an Event Count is used, the Job Ref must be unique to Piction
 if nvl(pe1,'S') <> 'S'
  then
   open c14(c1rec.aid,upper(pe4));
   fetch c14 into c14rec;
   if c14%FOUND
    then
     close c14;
     mng_usr_event(surl,acid,pagenmb,LNG4.AHC_TXT_617 || ':' || upper(pe4) );
     return;
   end if;
   close c14;
 end if;

 mng_usr_event(surl,acid,pagenmb,LNG3.ADM_TXT_229);

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_MNG_USR_EVENT', errmsg=>sqlerrm);
end accept_mng_usr_event;

procedure reverse_event(surl in varchar2, acid in integer, msg in varchar2 default null )
as

 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.REVERSE_EVENT', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  pfx := glbx.get_thm( c1rec.theme_name );
  glbx.main_title( surl, LNG4.AHC_TXT_596, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P55',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.formopen( 'pbk.accept_reverse_event' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );
  htp.bold( LNG4.AHC_TXT_607 );
  htp.nl;
  htp.bold( LNG4.AHC_TXT_606 );
  htp.nl;
  htp.ulistopen;
   htp.listitem( LNG4.AHC_TXT_597 );
   htp.listitem( LNG4.AHC_TXT_598 );
   htp.listitem( LNG4.AHC_TXT_599 );
   htp.listitem( LNG4.AHC_TXT_600 );
   htp.listitem( LNG4.AHC_TXT_601 );
  htp.ulistclose;
  htp.p( '<CENTER>' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.LAB_TXT_046 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P1', 50, 200, 'load.csv' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG3.ADM_TXT_762 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formradio( 'P2', 'T', 'CHECKED' ) || ' ' || LNG4.AHC_TXT_602 || htf.nl ||
                   htf.formradio( 'P2', 'F' ) || ' ' || LNG4.AHC_TXT_603, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_604 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formcheckbox( 'P3', 'T' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.LAB_TXT_048 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formcheckbox( 'P4', 'T' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, LNG4.AHC_TXT_605 );
  htp.formclose;
  htp.nl;
  htp.nl;
  htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'REVERSE_EVENT', errmsg=>sqlerrm);
end reverse_event;

procedure accept_reverse_event( surl in varchar2, acid in integer, p1 in varchar2, p2 in varchar2, p3 in char default 'F', p4 in char default 'F' )
as

 cursor c2(phgid integer) is select * from photographer where pid = phgid;
 cursor c3(acid integer, clid integer) is select rowid from virtual_logon where aid=acid and client_id=clid;
 cursor c4(acid integer) is select pw from audit_customer_password where aid= acid and date_changed = (select max(date_changed) from audit_customer_password where aid = acid);

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 fl		UTL_FILE.FILE_TYPE;
 bfr		varchar2(4000);
 cols		GLBX.MYARRAY;
 ctr		integer;
 x		integer;
 y		integer;
 inf_ctr	integer;
 nmb		integer;
 uname		varchar2(100);
 delim		varchar2(10);
 currpw		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_REVERSE_EVENT', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );

  open c2(c1rec.pid);
  fetch c2 into c2rec;
  close c2;

  if p2 = 'F'
   then
    fl := utl_file.fopen( glbx.extract_master_parameter('REPORTS_DIRECTORY'), nvl(p1,'load.csv'), 'r' );
   else
    fl := utl_file.fopen( c2rec.ftp_load_dir, nvl(p1,'load.csv'), 'r' );
  end if;

  if p4 = 'T' then utl_file.get_line(fl,bfr); end if;

  ctr := 0;
  inf_ctr := 0;
  if p3 = 'T' then delete from virtual_logon where aid = c1rec.aid; end if;
  pfx := glbx.get_thm( c1rec.theme_name );
  glbx.main_title( surl, LNG4.AHC_TXT_608, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P55',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_587 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_588 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_589 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.GLB_TXT_076 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.GLB_TXT_018 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.PHG_TXT_465 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;

  -- Extract Current Customer Password
  open c4(c1rec.aid);
  fetch c4 into currpw;
  close c4;

  loop

   cols.delete;
   cols(1) := NULL;
   cols(2) := NULL;
   cols(3) := NULL;
   cols(4) := NULL;
   cols(5) := NULL;
   begin
    utl_file.get_line(fl,bfr);
   exception
    when others then exit;
   end;
   inf_ctr := inf_ctr + 1;
   if inf_ctr > 100000 then exit; end if;

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

      if ctr > 1000 then exit; end if;

     end loop;
    begin nmb := to_number(cols(1)); exception when others then nmb := NULL; end;

    if cols(4) is null
     then
      if c1rec.event_logon_password_style = 'M'
       then
        cols(4) := upper(cols(3));
      elsif c1rec.event_logon_password_style = 'O'
       then
        cols(4) := currpw;
      elsif c1rec.event_logon_password_style = 'S'
       then
        cols(4) := upper(nvl(cols(3),to_char(nmb)));
      elsif c1rec.event_logon_password_style = 'I'
       then
        cols(4) := to_char(nmb);
      end if;
      cols(4) := nvl(cols(4),to_char(nmb));
    end if;

    -- Work out Username
    if c1rec.event_logon_uses_code = 'T'
     then
      uname := c1rec.photographer_account_id || to_char(nmb);
     else
      uname := to_char(nmb);
    end if;

    if nmb is not null
     then
      open c3(c1rec.aid,nmb);
      fetch c3 into c3rec;
      if c3%FOUND
       then
        close c3;
        update virtual_logon
         set
          client_id = nmb,
          first_name = cols(2),
          surname = cols(3),
          password = cols(4),
          username = uname,
          extra_details = cols(5)
         where rowid = c3rec.rowid;
       else
        close c3;
        insert into virtual_logon(aid,client_id,first_name,surname,username,password,extra_details) values
         (c1rec.aid,nmb,cols(2),cols(3),uname,cols(4),cols(5));
      end if;
      htp.tablerowopen;
       htp.tabledata( to_char(nmb), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( cols(2), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( cols(3), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( uname, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( cols(4), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( nvl(cols(5),'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tablerowclose;
    end if;
   end if;

 end loop;

 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
 htp.p( '</CENTER>' );
 htp.htmlclose;
 commit;
 utl_file.fclose(fl);


exception when others then
 begin utl_file.fclose(fl); exception when others then null; end;
 htp.htmlopen;
  htp.bold( LNG.LAB_TXT_050 || ': ' || p1 ); htp.nl;
  htp.italic( sqlerrm ); htp.nl;
  htp.nl;
  htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
  rollback;
 htp.htmlclose;
end accept_reverse_event;

procedure mng_authority(surl in varchar2, acid in integer, profid integer, msg in varchar2 default null )
as

 cursor c1( phgid integer ) is select project_code from project_codes where pid = phgid order by project_code;
 cursor c2( profid integer ) is select * from customer_profile where profile_id = profid;
 cursor c3( phgid integer, acid integer) is select profile_id,username,account_name from customer_profile where pid = phgid and aid = acid order by account_name,username;
 cursor c4( prfid integer, usrid integer ) is select 'x' exst from profile_purchase_authority where mgmt_profile_id = profid and profile_id = usrid;
 cursor c5 is select attribute_id,category,sub_category from umo_attributes order by category,sub_category;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MNG_AUTHORITY', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  pfx := glbx.get_thm( c1rec.theme_name );
  glbx.main_title( surl, LNG4.AHC_TXT_642, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P56',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  open c2(profid);
  fetch c2 into c2rec;
  close c2;
  if msg is not null then glbx.header_msg(msg); end if;

  htp.p( '<CENTER>' );
  htp.formopen( 'pbk.accept_mng_authority' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );
  htp.formhidden( 'PROFID', profid );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_652 ), cattributes=>pfx.qbground || 'valign="TOP" align="LEFT" width="40%"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    if c2rec.request_authority = 'F'
     then
      htp.p(htf.formradio( 'P1', 'F', 'CHECKED') || ' ' || LNG4.AHC_TXT_643 );
     else
      htp.p(htf.formradio( 'P1', 'F' ) || ' ' || LNG4.AHC_TXT_643 );
    end if;
    htp.nl;
    if c2rec.request_authority = 'A'
     then
      htp.p(htf.formradio( 'P1', 'A', 'CHECKED' ) || ' ' || LNG4.AHC_TXT_644 );
     else
      htp.p(htf.formradio( 'P1', 'A' ) || ' ' || LNG4.AHC_TXT_644 );
    end if;
    htp.nl;
    if c2rec.request_authority = 'B'
     then
      htp.p(htf.formradio( 'P1', 'B', 'CHECKED' ) || ' ' || LNG4.AHC_TXT_645 );
     else
      htp.p(htf.formradio( 'P1', 'B' ) || ' ' || LNG4.AHC_TXT_645 );
    end if;
    -- xxx target for language file
    htp.nl;
    if c2rec.request_authority = 'D'
     then
      htp.p(htf.formradio( 'P1', 'D', 'CHECKED' ) || ' ' || 'Can Authorise Self Only' );
     else
      htp.p(htf.formradio( 'P1', 'D' ) || ' ' || 'Can Authorise Self Only' );
    end if;
    htp.nl;
    if c2rec.request_authority = 'C'
     then
      htp.p(htf.formradio( 'P1', 'C', 'CHECKED' ) || ' ' || LNG4.AHC_TXT_646 );
     else
      htp.p(htf.formradio( 'P1', 'C' ) || ' ' || LNG4.AHC_TXT_646 );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    --htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="2">' );
    htp.formhidden( 'P2', NULL );
    htp.formselectopen( 'P2', null, 8, cattributes=>'MULTIPLE' );
    htp.formselectoption( NULL );
    for c3rec in c3(owner_id,acid) loop
     open c4(profid,c3rec.profile_id);
     fetch c4 into c4rec;
     if c4%FOUND
      then
       close c4;
       htp.formselectoption( c3rec.account_name || '(' || c3rec.username || ')', 'SELECTED', cattributes=>'VALUE="' || c3rec.profile_id|| '"');
      else
       close c4;
       htp.formselectoption( c3rec.account_name || '(' || c3rec.username || ')', cattributes=>'VALUE="' || c3rec.profile_id|| '"');
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_647 ), cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"' );
    -- Also Display How Much is Left on the limit
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">' );
    if c2rec.authority_limit is null
     then
      htp.formtext( 'P3', 20, 30, to_char(c2rec.authority_limit,LNG.MONEY_FORMAT));
      htp.p( ' ' || LNG.ORD_TXT_132 || ' ' || to_char(glbx.authority_outstanding(profid),LNG.MONEY_FORMAT) );
     else
      htp.formtext( 'P3', 20, 30, to_char(c2rec.authority_limit,LNG.MONEY_FORMAT));
      htp.p( ' ' || LNG.PHG_TXT_282 || ' ' || to_char(c2rec.authority_limit - glbx.authority_outstanding(profid),LNG.MONEY_FORMAT) );
    end if;
    htp.nl;
    htp.bold( 'or' );
    htp.nl;
    htp.p( 'Metatag must match username' || ':' );
    htp.formselectopen( 'P3A' );
    htp.formselectoption( NULL );
    for c5rec in c5 loop
     if c5rec.attribute_id = c2rec.attribute_id
      then
       htp.formselectoption( c5rec.category || '-' || c5rec.sub_category, 'SELECTED', cattributes=>'VALUE="' || c5rec.attribute_id ||  '"' );
      else
       htp.formselectoption( c5rec.category || '-' || c5rec.sub_category, cattributes=>'VALUE="' || c5rec.attribute_id ||  '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_554 || htf.nl || LNG5.EXT_TXT_555 || htf.nl || LNG5.EXT_TXT_556 ), cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">' );
    if nvl( c2rec.authority_own_request, 'T' ) = 'F'
     then
      htp.formradio( 'P7', 'F', 'CHECKED' );
     else
      htp.formradio( 'P7', 'F' );
    end if;
    htp.nl;
    if nvl( c2rec.authority_own_request, 'T' ) = 'T'
     then
      htp.formradio( 'P7', 'T', 'CHECKED' );
     else
      htp.formradio( 'P7', 'T' );
    end if;
    htp.nl;
    if nvl( c2rec.authority_own_request, 'T' ) = 'A'
     then
      htp.formradio( 'P7', 'A', 'CHECKED' );
     else
      htp.formradio( 'P7', 'A' );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_648 ) || htf.nl || htf.italic( LNG.MASK ), cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P4', 20, 30, to_char(c2rec.authority_valid_from,LNG.MASK)), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_649 ) || htf.nl || htf.italic( LNG.MASK ), cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P5', 20, 30, to_char(c2rec.authority_valid_to,LNG.MASK)), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_983 ), cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"' );
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
       htp.formselectopen( 'P6' );
       htp.formselectoption( NULL );
       for c1rec in c1( owner_id ) loop
        if c1rec.project_code = c2rec.project_code
         then
          htp.formselectoption( c1rec.project_code, 'SELECTED' );
         else
          htp.formselectoption( c1rec.project_code );
        end if;
       end loop;
       htp.formselectclose;
      htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( 'ACTION', LNG2.PFM_TXT_027 );
  htp.formsubmit( 'ACTION', LNG2.PFM_BUT_014 );
  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'MNG_AUTHORITY', errmsg=>sqlerrm);
end mng_authority;

procedure accept_mng_authority(surl in varchar2, acid in integer, profid integer, p1 in varchar2, p2 in GLBX.MYARRAY, p3 in varchar2, p3a in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, action in varchar2 )
as

 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		number;
 dt1		date;
 dt2		date;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_MNG_AUTHORITY', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );

  begin nmb := to_number(p3); exception when others then begin nmb := to_number(p3,LNG.LRG_MONEY_FORMAT); exception when others then nmb := NULL; end; end;
  begin dt1 := to_date( p4, LNG.MASK ); exception when others then dt1 := NULL; end;
  begin dt2 := to_date( p5, LNG.MASK ); exception when others then dt2 := NULL; end;

  update customer_profile
   set
    request_authority = p1,
    authority_limit = nmb,
    authority_valid_from = dt1,
    authority_valid_to = dt2,
    project_code = p6,
    authority_own_request = p7,
    attribute_id = p3a
  where profile_id = profid and
        aid = c1rec.aid;

  delete from profile_purchase_authority where mgmt_profile_id = profid;
  for j in p2.first..p2.last loop
   if p2(j) is not null
    then
     insert into profile_purchase_authority(mgmt_profile_id,profile_id) values (profid,to_number(p2(j)));
   end if;
  end loop;
  commit;
  if action = LNG2.PFM_TXT_027
   then
    pbk.mng_profiles(surl,acid, LNG4.AHC_TXT_651);
   else
    mng_authority( surl, acid, profid, LNG4.AHC_TXT_651 );
  end if;

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_MNG_AUTHORITY',owner_id,acid,errmsg=>sqlerrm,extdet=>'PROFID:' || profid);
end accept_mng_authority;

procedure mng_simple_rfq(surl in varchar2, see_archived in varchar2 default 'F', msg in varchar2 default null)
as

 cursor c1(phgid integer, arc char) is
  select srfq_id, sr.sessid, sr.contact_name, sr.contact_phone, sr.contact_email, sr.request_made, sr.status, sr.date_made, sr.date_completed
  from simple_rfq sr
  where sr.pid = phgid and
        ((arc = 'F' and status <> LNG.ORD_TXT_127) or
         (arc = 'T' and status = LNG.ORD_TXT_127))
  order by nvl(sr.date_completed,'01-JAN-2000') asc, sr.date_made desc;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MNG_SIMPLE_RFQ', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG4.AHC_TXT_628, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P58',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg );end if;
  htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG4.AHC_TXT_636 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.bold( LNG.CST_TXT_005 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.bold( LNG.GLB_TXT_078 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.bold( LNG4.AHC_TXT_653 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.bold( LNG.PHG_TXT_082 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  for c1rec in c1(owner_id,see_archived) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'pbk.edit_simple_rfq?surl=' || glbx.rndsurl(surl) || '&srfqid=' || c1rec.srfq_id || '&see_archived=' || see_archived, c1rec.srfq_id), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    if c1rec.contact_name is not null
     then
      htp.bold( c1rec.contact_name );
      htp.nl;
    end if;
    if c1rec.contact_phone is null
     then
      htp.italic( c1rec.contact_email );
    elsif c1rec.contact_email is null
     then
      htp.italic( c1rec.contact_phone );
    else
      htp.italic( c1rec.contact_phone || '/' || c1rec.contact_email);
    end if;
    htp.p( '</TD>' );
    htp.tabledata( to_char(c1rec.date_made,LNG.TSMASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( c1rec.request_made,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.p( c1rec.status );
     if c1rec.date_made is not null
      then
       htp.p( htf.nl || to_char(c1rec.date_completed,LNG.TSMASK) );
     end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  if see_archived = 'F'
   then
    htp.anchor( 'pbk.mng_simple_rfq?surl=' || surl || '&see_archived=T', LNG4.AHC_TXT_675 );
   else
    htp.anchor( 'pbk.mng_simple_rfq?surl=' || surl || '&see_archived=F', LNG4.AHC_TXT_676 );
  end if;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'MNG_SIMPLE_RFQ', errmsg=>sqlerrm);
end mng_simple_rfq;

procedure edit_simple_rfq(surl in varchar2, see_archived in varchar2 default 'F', srfqid in integer, msg in varchar2 default null)
as

 cursor c1(phgid integer, srfqid integer) is
  select *
  from simple_rfq sr
  where sr.pid = phgid and
        srfq_id = srfqid;

 cursor c2( srfqid integer ) is select * from simple_rfq_item where srfq_id = srfqid order by ranking desc;
 cursor c3( phgid integer, vppi integer ) is select tppi.name from phg_price_item tppi, phg_price_book  ppb where tppi.spb = ppb.spb and ppb.pid = phgid and ppi = vppi;
 cursor c4( phgid integer ) is select m.name, m.manufacturer_id from manufacturer_photographer mp, manufacturer m where pid = phgid and mp.manufacturer_id = m.manufacturer_id;
 cursor c5( sid integer, mid integer) is select respond_by from simple_rfq_mfctr where srfq_id = sid and manufacturer_id = mid;
 cursor c6( sid integer ) is
  select name,product_id,mfctr_comments
  from simple_rfq_mfctr srm, manufacturer m
  where srm.manufacturer_id = m.manufacturer_id and
        srfq_id = sid and
        (product_id is not null or
         mfctr_comments is not null);
 cursor c7( prodid integer ) is select name,manufctr_code from product where product_id = prodid;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c7rec		c7%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 foundrec	boolean;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.EDIT_SIMPLE_RFQ', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG4.AHC_TXT_628, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P58',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg );end if;
  open c1(owner_id, srfqid );
  fetch c1 into c1rec;
  close c1;
  htp.formopen( 'pbk.accept_simple_rfq' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'SRFQID', srfqid );
  htp.formhidden( 'PC', null );
  htp.formhidden( 'SEE_ARCHIVED', see_archived );
  htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG4.AHC_TXT_636 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.bold( srfqid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.CST_TXT_005 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.formtext( 'P1', 30, 1000, c1rec.contact_name ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.ORD_TXT_180 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.contact_phone ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.PHG_TXT_301 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.formtext( 'P3', 30, 100, c1rec.contact_email ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG4.AHC_TXT_636 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.formtextareaopen( 'P4', 10, 30, cattributes=>'WRAP="VIRTUAL"'  ) || c1rec.request_made || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.PHG_TXT_082 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
   htp.formselectopen( 'P5' );
    if c1rec.status = LNG.ORD_TXT_120
     then
      htp.formselectoption( LNG.ORD_TXT_120, 'SELECTED' );
     else
      htp.formselectoption( LNG.ORD_TXT_120 );
    end if;
    if c1rec.status = LNG4.AHC_TXT_660
     then
      htp.formselectoption( LNG4.AHC_TXT_660, 'SELECTED' );
     else
      htp.formselectoption( LNG4.AHC_TXT_660 );
    end if;
    if c1rec.status = LNG2.PFM_TXT_139
     then
      htp.formselectoption( LNG2.PFM_TXT_139, 'SELECTED' );
     else
      htp.formselectoption( LNG2.PFM_TXT_139 );
    end if;
    if c1rec.status = LNG.ORD_TXT_127
     then
      htp.formselectoption( LNG.ORD_TXT_127, 'SELECTED' );
     else
      htp.formselectoption( LNG.ORD_TXT_127 );
    end if;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.bold( LNG4.AHC_TXT_661 );
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
   htp.tablerowopen;
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_662 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_909 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_663 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_105 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG5.EXT_TXT_379 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_665 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG5.EXT_TXT_376 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   foundrec := FALSE;
   for c2rec in c2( srfqid ) loop
    htp.tablerowopen;
     c3rec.name := NULL;
     open c3( owner_id, c2rec.ppi );
     fetch c3 into c3rec;
     if c3%NOTFOUND then c3rec.name := LNG5.EXT_TXT_377; end if;
     close c3;
     htp.formhidden ('P0', c2rec.srfq_item_id );
     if c2rec.ppi is not null
      then
       foundrec := TRUE;
       htp.tabledata( htf.formcheckbox( 'PC', c2rec.ppi ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      else
       htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     end if;
     htp.tabledata( htf.formtext( 'P6', 15, 15, c2rec.ppi ) || htf.nl || htf.italic( c3rec.name ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     open c7( c2rec.product_id );
     fetch c7 into c7rec;
     close c7;
     htp.tabledata( htf.formtext( 'P7', 15, 15, c2rec.product_id ) || htf.nl || htf.italic( c7rec.name ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.formtext( 'P8', 4, 10, c2rec.ranking), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.formtext( 'P9', 30, 4000, c2rec.free_text_description), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.bold( c2rec.email_or_phone );
     if c2rec.email_sent = 'T'
      then
       htp.nl;
       htp.italic( LNG4.AHC_TXT_668 || '-' || to_char( c2rec.email_sent_date, LNG.MASK ) );
     end if;
     htp.p( '</TD>' );
     htp.tabledata( htf.formtextareaopen( 'P11', 3, 30, 4000 ) ||  c2rec.general_comments || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P10' );
      htp.formselectoption( LNG5.EXT_TXT_378, 'SELECTED' );
      htp.formselectoption( LNG5.EXT_TXT_380 );
      htp.formselectoption( LNG.ORD_TXT_180 );
      if c3rec.name = LNG5.EXT_TXT_377
       then
        null;
       else
        htp.formselectoption( LNG3.ADM_TXT_612 );
        htp.formselectoption( LNG4.AHC_TXT_664 );
      end if;
     htp.formselectclose;
     htp.p( '</TD>' );
    htp.tablerowclose;
   end loop;
   for j in 1..3 loop
    htp.tablerowopen;
     htp.formhidden ('P0', null );
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.formtext( 'P6', 15, 15 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.formtext( 'P7', 15, 15 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.formtext( 'P8', 4, 10), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.formtext( 'P9', 30, 4000), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.formtext( 'P11', 30, 4000), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P10' );
      htp.formselectoption( LNG5.EXT_TXT_378, 'SELECTED' );
      htp.formselectoption( LNG5.EXT_TXT_380 );
     htp.formselectclose;
     htp.p( '</TD>' );
   end loop;
  htp.tableclose;
  htp.nl;
  htp.bold( LNG4.AHC_TXT_670 );
  htp.nl;

  htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
  htp.tablerowopen;
  htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="LEFT">' );
  htp.formhidden( 'P12', null );
  htp.formselectopen( 'P12', null, 3, cattributes=>'MULTIPLE' );
  htp.formselectoption( NULL );
  for c4rec in c4(owner_id) loop
   open c5( srfqid, c4rec.manufacturer_id );
   fetch c5 into c5rec;
   if c5%FOUND
    then
     close c5;
     htp.formselectoption( c4rec.name, 'SELECTED', cattributes=>'VALUE="' || c4rec.manufacturer_id|| '"');
    else
     close c5;
     htp.formselectoption( c4rec.name, cattributes=>'VALUE="' || c4rec.manufacturer_id|| '"');
   end if;
  end loop;
  htp.formselectclose;
  htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_671 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P13', 15, 15, c5rec.respond_by ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowopen;
   htp.tablerowopen;
     htp.tabledata( htf.bold( LNG4.AHC_TXT_673 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowopen;
  for c6rec in c6(srfqid) loop
   htp.tablerowopen;
     htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      htp.bold( c6rec.name );
      htp.nl;
      c4rec.name := NULL;
      open c7( c6rec.product_id );
      fetch c7 into c7rec;
      close c7;
      if c6rec.mfctr_comments is null
       then
        htp.bold( c7rec.name || ' (' || c7rec.manufctr_code || ')' );
      elsif c6rec.product_id is null
       then
        htp.italic( c6rec.mfctr_comments );
      else
        htp.bold( c7rec.name || ' (' || c7rec.manufctr_code || ')' );
        htp.nl;
        htp.italic( c6rec.mfctr_comments );
     end if;
     htp.nl;
     htp.p( LNG4.AHC_TXT_909 || ':' || c6rec.product_id );
     htp.p( '</TD>' );
   htp.tablerowopen;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( 'ACTION', LNG4.AHC_TXT_659 );
  if foundrec
   then
    htp.nl;
    htp.nl;
    htp.bold( LNG5.EXT_TXT_569 );
    htp.nl;
    htp.formsubmit( 'ACTION', LNG5.EXT_TXT_568 );
  end if;
  htp.formclose;
  htp.nl;
  htp.anchor( 'pbk.mng_simple_rfq?surl=' || surl || '&see_archived=' || see_archived, LNG4.AHC_TXT_666 );
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'EDIT_SIMPLE_RFQ', errmsg=>sqlerrm);
end edit_simple_rfq;

procedure accept_simple_rfq(surl in varchar2, srfqid in integer, see_archived in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY, p8 in GLBX.MYARRAY, p9 in GLBX.MYARRAY, p10 in GLBX.MYARRAY, p11 in GLBX.MYARRAY, p12 in GLBX.MYARRAY, p0 in GLBX.MYARRAY, pc in GLBX.MYARRAY, p13 in varchar2, action in varchar2 )
as

 cursor c1(srf integer) is select * from simple_rfq where srfq_id = srf;
 cursor c2 is select max(srfq_item_id) mx from simple_rfq_item;
 cursor c3( s1 integer, s2 integer ) is select rowid from simple_rfq_mfctr where srfq_id = s1 and manufacturer_id = s2;
 cursor c4( s1 integer ) is select manufacturer_id from simple_rfq_mfctr where srfq_id = s1;
 cursor c5( ppit integer, owner_id integer) is select lab_id from phg_price_item pm, phg_price_book ppb where ppb.pid = owner_id and ppb.spb = pm.spb and pm.ppi = ppit;
 cursor c6( phgid integer) is select * from photographer where pid = phgid;
 cursor c7( ppid integer ) is select umo_id from phg_price_item where ppi = ppid;
 cursor c8( sess_id integer) is select * from login_session where sessid = sess_id;
 cursor c9( acid integer) is select * from customer_account where aid = acid;
 cursor c10( profid integer) is select * from customer_account where aid in (select aid from customer_profile where profile_id = profid);
 cursor c11( ppid integer ) is select * from phg_price_item where ppi = ppid;
 cursor c12( prodid integer ) is select * from product where product_id = prodid;
 cursor c13( prodid integer ) is select * from price_book where product_id = prodid and valid_until is null;
 cursor c14( v_umo integer) is select * from umo where umo_id = v_umo;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c9rec		c9%ROWTYPE;
 c11rec		c11%ROWTYPE;
 c12rec		c12%ROWTYPE;
 c13rec		c13%ROWTYPE;
 c14rec		c14%ROWTYPE;
 b2c_value	char(1);
 voidrec	order_style%ROWTYPE;
 purch		purchase_order%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		number;
 em		varchar2(100);
 txt		varchar2(4000);
 txt2		varchar2(4000);
 rq		varchar2(4000);
 dt		date;
 foundrec	boolean;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_SIMPLE_RFQ', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  rq := glbx.censor(p4,4000);

  update simple_rfq
   set
    contact_name = p1,
    contact_phone = p2,
    contact_email = p3,
    request_made = rq,
    status = p5
  where
   srfq_id = srfqid and
   pid = owner_id;

  open c1(srfqid);
  fetch c1 into c1rec;
  close c1;

  for j in p0.first..p0.last loop -- Loop through all entered Price Book Item Id's

   if p0(j) is null -- New Item
    then
      if p10(j) =  LNG5.EXT_TXT_380 -- No Match Exists
       then
        c2rec.mx := NULL;
        open c2;
        fetch c2 into c2rec;
        close c2;
        c2rec.mx := nvl(c2rec.mx,0) + 1;
        txt := glbx.censor(p9(j),4000);
        txt2 := glbx.censor(p11(j),4000);
        begin nmb := to_number(p8(j)); exception when others then nmb := NULL; end;
        insert into simple_rfq_item( srfq_item_id, srfq_id, ppi, product_id, ranking, free_text_description, email_or_phone, general_comments ) values
         ( c2rec.mx, srfqid, null, null, nmb, txt, p10(j), txt2 );
       else
        if p6(j) is not null or p7(j) is not null
         then
          if p7(j) is null
           then
            begin
             open c5(p6(j),owner_id);
             fetch c5 into c5rec;
             close c5;
            exception
             when others then null;
            end;
          end if;
          c2rec.mx := NULL;
          open c2;
          fetch c2 into c2rec;
          close c2;
          c2rec.mx := nvl(c2rec.mx,0) + 1;
          txt := glbx.censor(p9(j),4000);
          txt2 := glbx.censor(p11(j),4000);
          begin nmb := to_number(p8(j)); exception when others then nmb := NULL; end;
          insert into simple_rfq_item( srfq_item_id, srfq_id, ppi, product_id, ranking, free_text_description, email_or_phone, general_comments ) values
           ( c2rec.mx, srfqid, p6(j), nvl(p7(j),c5rec.lab_id), nmb, txt, p10(j), txt2 );
        end if;
      end if;

    else
     if p6(j) is null and p7(j) is null
      then
       delete from simple_rfq_item
       where
        srfq_item_id = p0(j) and
        srfq_id in (select srfq_id from simple_rfq where srfq_id = srfqid and pid = owner_id);
      else
       -- Update
       begin nmb := to_number(p8(j)); exception when others then nmb := NULL; end;
       txt := glbx.censor(p9(j),4000);
       txt2 := glbx.censor(p11(j),4000);
       if p7(j) is null
        then
         begin
          open c5(p6(j),owner_id);
          fetch c5 into c5rec;
          close c5;
         exception
          when others then null;
         end;
       end if;
       if p10(j) in (LNG3.ADM_TXT_612,LNG4.AHC_TXT_664)
        then
         if p3 is null
          then
           em := LNG5.EXT_TXT_378; -- No email address, no action
          else
           em := p10(j);
         end if;
        else
         em := p10(j);
       end if;
       update simple_rfq_item
        set
         ppi = p6(j),
         product_id = nvl(p7(j),c5rec.lab_id),
         ranking = nmb,
         free_text_description = txt,
         email_or_phone = em,
         general_comments = txt2
       where
        srfq_item_id = p0(j) and
        srfq_id in (select srfq_id from simple_rfq where srfq_id = srfqid and pid = owner_id);

       if em in (LNG3.ADM_TXT_612,LNG4.AHC_TXT_664)
        then
         -- Send User Email
         open c6(owner_id);
         fetch c6 into c6rec;
         close c6;
         open c7(p6(j));
         fetch c7 into c7rec;
         close c7;
         gcode(1) := 'SIGNATURE';
         gparam(1) := glbx.extract_master_parameter('MAIL SIGNATURE');
         gcode(2) := 'REQUEST';
         gparam(2) := rq;
         gcode(3) := 'NAME';
         gparam(3) := p1;
         gcode(4) := 'PHONE';
         gparam(4) := p2;
         gcode(5) := 'EMAIL';
         gparam(5) := p3;
         gcode(6) := 'LINK';
         gparam(6) := glbx.extract_master_parameter('MERCHANT_RETURNTO_URL') || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'glbx.accept_login?un=' || '&v_product_id=' || trim(p6(j)) || '&v_umo=' || c7rec.umo_id;
         gcode(7) := 'PRODUCT';
         gparam(7) := txt;
         gcode(8) := 'COMMENT';
         gparam(8) := txt2;
         glbx.send( gcode, gparam, infile=>'customer_rfq.tmp', p_to=>p3, p_subj=>'Customer RFQ', p_from=>nvl(c6rec.contact_email,glbx.extract_master_parameter('DBA_MAIL_FROM')),own_id=>owner_id,ltype=>ltype, scode=>'CR1',v_pid=>owner_id);
       end if;
     end if;
   end if;
  end loop;

  begin dt := to_date(p13,LNG.MASK); exception when others then dt := NULL; end;
  update simple_rfq_mfctr
   set
    respond_by = dt
  where
   srfq_id = srfqid;

  for c4rec in c4(srfqid) loop
   foundrec := FALSE;
   for j in p12.first..p12.last loop
    if p12(j) = c4rec.manufacturer_id then foundrec := TRUE; exit; end if;
   end loop;
   if not foundrec then delete from simple_rfq_mfctr where srfq_id = srfqid and manufacturer_id = c4rec.manufacturer_id; end if;
  end loop;

  for j in p12.first..p12.last loop
   if p12(j) is not null
    then
     open c3(srfqid,p12(j));
     fetch c3 into c3rec;
     if c3%FOUND
      then
       close c3;
      else
       close c3;
       insert into simple_rfq_mfctr(srfq_id,manufacturer_id,respond_by) values (srfqid,p12(j),dt);
     end if;
   end if;
  end loop;
  commit;

  if action = LNG4.AHC_TXT_659
   then
    edit_simple_rfq(surl, see_archived, srfqid, LNG4.AHC_TXT_677 );
    return;
  end if;

  -- Create Precreated Order
  foundrec := FALSE;
  -- Note: First Null is sessid, which hasn't been set yet.
  if c8rec.login_type = 'PHOTOGRAPHER'
   then
    c9rec.aid := NULL;
    c9rec.pid := c8rec.aid;
    voidrec := glbx.get_order_style( glbx.get_order_style( c9rec.pid, null, c8rec.login_type, b2c_value ));
    fname.create_purchase_order(surl, null, 'PreOrder', null, c8rec.login_type, c9rec, voidrec, purch);
  elsif c8rec.login_type in ('OWNER','CUSTOMER')
   then
    open c9(c8rec.aid);
    fetch c9 into c9rec;
    close c9;
    voidrec := glbx.get_order_style( glbx.get_order_style( c9rec.aid, null, c8rec.login_type, b2c_value ));
    fname.create_purchase_order(surl, null, 'PreOrder', null, c8rec.login_type, c9rec, voidrec, purch);
  elsif c8rec.login_type in ('PROFILE','PROFILEG')
   then
    open c10(c8rec.aid);
    fetch c10 into c9rec;
    close c10;
    voidrec := glbx.get_order_style( glbx.get_order_style( c9rec.aid, c8rec.aid, c8rec.login_type, b2c_value ));
    fname.create_purchase_order(surl, null, 'PreOrder', c8rec.aid, c8rec.login_type, c9rec, voidrec, purch);
  end if;

  open c8(c1rec.sessid);
  fetch c8 into c8rec;
  close c8;

  for j in pc.first..pc.last loop
   if pc(j) is not null
    then
     foundrec := TRUE;
     open c11(pc(j));
     fetch c11 into c11rec;
     close c11;
     open c12(c11rec.lab_id);
     fetch c12 into c12rec;
     close c12;
     open c13(c11rec.lab_id);
     fetch c13 into c13rec;
     close c13;
     open c14(c11rec.umo_id);
     fetch c14 into c14rec;
     close c14;
     insert into shopping_basket (poid,shopping_id,qty,phid,
                                  royalty_api,photo_size,photo_cost,isgallery,ppi,phg_code,
                                  lab_id,manufctr_code,xref_mfctr_code,
                                  is_discounted,name,price,tax,commission,
                                  film_name,status_workflow,product_class)
      values
     (purch.poid,s_shopping_basket.nextval,1,c11rec.umo_id,
      c11rec.charge,'Calculated Price',c11rec.charge,'A',c11rec.ppi,c11rec.phg_code,
      c11rec.lab_id,c12rec.manufctr_code,c12rec.xref_mfctr_code,
      c12rec.is_discounted,c12rec.name,c13rec.price,c13rec.tax,c13rec.commission,
      c14rec.extras.film_name,c11rec.status_workflow,c11rec.product_class);
   end if;
  end loop;
  if foundrec
   then
    insert into rfq_prefilled_order(aid, login_type, poid ) values ( c8rec.aid, c8rec.login_type, purch.poid );
   else
    delete from purchase_order where poid = purch.poid;
  end if;
  commit;

  edit_simple_rfq(surl, see_archived, srfqid, LNG5.EXT_TXT_570 );

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_SIMPLE_RFQ',owner_id,null,errmsg=>sqlerrm);
end accept_simple_rfq;

procedure mng_register(surl in varchar2, acid in integer, msg in varchar2 default null )
as

 cursor c2( phgid integer, acid integer ) is select * from generic_registration where pid = phgid and aid = acid;
 cursor c3( phgid integer, acid integer, ut char, cn varchar2) is select 'x' ex from generic_registration_columns where pid = phgid and aid = acid and user_type = ut and column_name = cn;
 cursor c4( ut char ) is select * from generic_columns_names where user_type = ut order by column_name;
 cursor c5(phid integer) is select theme_name from theme order by theme_name;
 cursor c6 is select theme_type from theme_types order by theme_type;
 cursor c7(phgid integer) is select * from photographer where pid=phgid;
 cursor c10(phid integer) is select theme_name from limit_laf where pid = phid order by theme_name;
 cursor c11(phid integer) is select limit_scene,limit_laf,limit_bf,skill_level from photographer where pid = phid;
 cursor c12(phid integer) is select theme_type from limit_bf where pid = phid order by theme_type;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c11rec		c11%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

 procedure cbox( colval in char, nmb in integer, id in varchar2, id2 in varchar2 )
 is
  begin
     if nvl(substr(colval,nmb,1),'F') = 'T'
      then
       htp.tabledata( htf.formcheckbox( id, id2, 'CHECKED' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      else
       htp.tabledata( htf.formcheckbox( id, id2 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     end if;
 end cbox;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MNG_REGISTER', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  pfx := glbx.get_thm( c1rec.theme_name );
  glbx.main_title( surl, LNG4.AHC_TXT_729, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P59',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  if msg is not null then glbx.header_msg(msg); end if;
  open c7( owner_id );
  fetch c7 into c7rec;
  close c7;
  open c2(c1rec.pid, c1rec.aid);
  fetch c2 into c2rec;
  if c2%NOTFOUND
   then
    insert into generic_registration( pid, aid, lov_i,lov_s,lov_c, business_feature_i,business_feature_s,business_feature_c ) values (c1rec.pid, c1rec.aid, c7rec.default_lf, c7rec.default_lf, c7rec.default_lf, c7rec.default_bf, c7rec.default_bf, c7rec.default_bf );
    commit;
  end if;
  close c2;
  open c11( owner_id );
  fetch c11 into c11rec;
  close c11;

  htp.p( '<CENTER>' );
  htp.formopen( 'pbk.accept_mng_register' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );
  htp.formhidden( 'P2', null );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_734 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_presubmit, 1, 'P2', 'A1' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_735 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_presubmit, 2, 'P2', 'A2' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_761 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_presubmit, 3, 'P2', 'A3' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_736 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_presubmit, 4, 'P2', 'A4' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_737 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_presubmit, 5, 'P2', 'A5' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_738 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_presubmit, 6, 'P2', 'A6' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_739 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_740 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_form, 1, 'P2', 'B1' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_741 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_form, 2, 'P2', 'B2' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_742 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_form, 3, 'P2', 'B3' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_780 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_form, 8, 'P2', 'B8' );
    htp.tabledata( htf.bold( LNG5.EXT_TXT_374 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_form, 4, 'P2', 'B4' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_783 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_form, 5, 'P2', 'B5' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_785 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_form, 6, 'P2', 'B6' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_787 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_form, 7, 'P2', 'B7' );
    htp.tabledata( htf.bold( LNG5.EXT_TXT_373 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_743 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_submit, 1, 'P2', 'C1' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_744 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_submit, 2, 'P2', 'C2' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_745 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_submit, 3, 'P2', 'C3' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_746 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_submit, 4, 'P2', 'C4' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_747 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_submit, 11, 'P2', 'C11' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_989 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_submit, 12, 'P2', 'C12' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_990 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_submit, 5, 'P2', 'C5' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_748 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_submit, 6, 'P2', 'C6' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_749 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_submit, 7, 'P2', 'C7' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_750 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_submit, 13, 'P2', 'C13' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_991 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_submit, 14, 'P2', 'C14' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_992 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_submit, 8, 'P2', 'C8' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_751 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_submit, 9, 'P2', 'C9' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_752 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    cbox( c2rec.on_submit, 10, 'P2', 'C10' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_753 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.bold( LNG4.AHC_TXT_754 );
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_755 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_779 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P3',30,100,c2rec.extra_prompt), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_756 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_730 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P4A' );
       if c11rec.limit_laf = 'T'
        then
         for c5rec in c5(owner_id) loop
          if c2rec.lov_i = c5rec.theme_name
           then
            htp.formselectoption( c5rec.theme_name, 'SELECTED' );
           else
            htp.formselectoption( c5rec.theme_name );
          end if;
         end loop;
        else
         for c10rec in c10(owner_id) loop
          if c2rec.lov_i = c10rec.theme_name
           then
            htp.formselectoption( c10rec.theme_name, 'SELECTED' );
           else
            htp.formselectoption( c10rec.theme_name );
          end if;
         end loop;
       end if;
       htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_731 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P4B' );
       if c11rec.limit_laf = 'T'
        then
         for c5rec in c5(owner_id) loop
          if c2rec.lov_s = c5rec.theme_name
           then
            htp.formselectoption( c5rec.theme_name, 'SELECTED' );
           else
            htp.formselectoption( c5rec.theme_name );
          end if;
         end loop;
        else
         for c10rec in c10(owner_id) loop
          if c2rec.lov_s = c10rec.theme_name
           then
            htp.formselectoption( c10rec.theme_name, 'SELECTED' );
           else
            htp.formselectoption( c10rec.theme_name );
          end if;
         end loop;
       end if;
       htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_732 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P4C' );
       if c11rec.limit_laf = 'T'
        then
         for c5rec in c5(owner_id) loop
          if c2rec.lov_c = c5rec.theme_name
           then
            htp.formselectoption( c5rec.theme_name, 'SELECTED' );
           else
            htp.formselectoption( c5rec.theme_name );
          end if;
         end loop;
        else
         for c10rec in c10(owner_id) loop
          if c2rec.lov_c = c10rec.theme_name
           then
            htp.formselectoption( c10rec.theme_name, 'SELECTED' );
           else
            htp.formselectoption( c10rec.theme_name );
          end if;
         end loop;
       end if;
       htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_994 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P4D' );
       if c11rec.limit_laf = 'T'
        then
         for c5rec in c5(owner_id) loop
          if c2rec.lov_g = c5rec.theme_name
           then
            htp.formselectoption( c5rec.theme_name, 'SELECTED' );
           else
            htp.formselectoption( c5rec.theme_name );
          end if;
         end loop;
        else
         for c10rec in c10(owner_id) loop
          if c2rec.lov_g = c10rec.theme_name
           then
            htp.formselectoption( c10rec.theme_name, 'SELECTED' );
           else
            htp.formselectoption( c10rec.theme_name );
          end if;
         end loop;
       end if;
       htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_995 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P4E' );
       if c11rec.limit_laf = 'T'
        then
         for c5rec in c5(owner_id) loop
          if c2rec.lov_n = c5rec.theme_name
           then
            htp.formselectoption( c5rec.theme_name, 'SELECTED' );
           else
            htp.formselectoption( c5rec.theme_name );
          end if;
         end loop;
        else
         for c10rec in c10(owner_id) loop
          if c2rec.lov_n = c10rec.theme_name
           then
            htp.formselectoption( c10rec.theme_name, 'SELECTED' );
           else
            htp.formselectoption( c10rec.theme_name );
          end if;
         end loop;
       end if;
       htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_757 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_730 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P5A' );
       if c11rec.limit_bf = 'T'
        then
         for c6rec in c6 loop
          if c2rec.business_feature_i = c6rec.theme_type
           then
            htp.formselectoption( c6rec.theme_type, 'SELECTED' );
           else
            htp.formselectoption( c6rec.theme_type );
          end if;
         end loop;
        else
         for c12rec in c12(owner_id) loop
          if c2rec.business_feature_i = c12rec.theme_type
           then
            htp.formselectoption( c12rec.theme_type, 'SELECTED' );
           else
            htp.formselectoption( c12rec.theme_type );
          end if;
         end loop;
       end if;
       htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_731 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P5B' );
       if c11rec.limit_bf = 'T'
        then
         for c6rec in c6 loop
          if c2rec.business_feature_s = c6rec.theme_type
           then
            htp.formselectoption( c6rec.theme_type, 'SELECTED' );
           else
            htp.formselectoption( c6rec.theme_type );
          end if;
         end loop;
        else
         for c12rec in c12(owner_id) loop
          if c2rec.business_feature_s = c12rec.theme_type
           then
            htp.formselectoption( c12rec.theme_type, 'SELECTED' );
           else
            htp.formselectoption( c12rec.theme_type );
          end if;
         end loop;
       end if;
       htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_732 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P5C' );
       if c11rec.limit_bf = 'T'
        then
         for c6rec in c6 loop
          if c2rec.business_feature_c = c6rec.theme_type
           then
            htp.formselectoption( c6rec.theme_type, 'SELECTED' );
           else
            htp.formselectoption( c6rec.theme_type );
          end if;
         end loop;
        else
         for c12rec in c12(owner_id) loop
          if c2rec.business_feature_c = c12rec.theme_type
           then
            htp.formselectoption( c12rec.theme_type, 'SELECTED' );
           else
            htp.formselectoption( c12rec.theme_type );
          end if;
         end loop;
       end if;
       htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_994 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P5D' );
       if c11rec.limit_bf = 'T'
        then
         for c6rec in c6 loop
          if c2rec.business_feature_g = c6rec.theme_type
           then
            htp.formselectoption( c6rec.theme_type, 'SELECTED' );
           else
            htp.formselectoption( c6rec.theme_type );
          end if;
         end loop;
        else
         for c12rec in c12(owner_id) loop
          if c2rec.business_feature_g = c12rec.theme_type
           then
            htp.formselectoption( c12rec.theme_type, 'SELECTED' );
           else
            htp.formselectoption( c12rec.theme_type );
          end if;
         end loop;
       end if;
       htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_995 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P5E' );
       if c11rec.limit_bf = 'T'
        then
         for c6rec in c6 loop
          if c2rec.business_feature_n = c6rec.theme_type
           then
            htp.formselectoption( c6rec.theme_type, 'SELECTED' );
           else
            htp.formselectoption( c6rec.theme_type );
          end if;
         end loop;
        else
         for c12rec in c12(owner_id) loop
          if c2rec.business_feature_n = c12rec.theme_type
           then
            htp.formselectoption( c12rec.theme_type, 'SELECTED' );
           else
            htp.formselectoption( c12rec.theme_type );
          end if;
         end loop;
       end if;
       htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_758 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P6',30,100,c2rec.call_program), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.bold( LNG4.AHC_TXT_759 );
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_730 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_731 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_732 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_994 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_995 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
    htp.formhidden( 'P1A', NULL );
    htp.formselectopen( 'P1A', null, 5, cattributes=>'MULTIPLE' );
    for c4rec in c4( 'I' ) loop
     open c3(c1rec.pid,c1rec.aid,'I',c4rec.column_name);
     fetch c3 into c3rec;
     if c3%FOUND
      then
       close c3;
       htp.formselectoption( c4rec.column_name,'SELECTED' );
      else
       close c3;
       htp.formselectoption( c4rec.column_name );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
    htp.formhidden( 'P1B', NULL );
    htp.formselectopen( 'P1B', null, 5, cattributes=>'MULTIPLE' );
    for c4rec in c4( 'S' ) loop
     open c3(c1rec.pid,c1rec.aid,'S',c4rec.column_name);
     fetch c3 into c3rec;
     if c3%FOUND
      then
       close c3;
       htp.formselectoption( c4rec.column_name,'SELECTED' );
      else
       close c3;
       htp.formselectoption( c4rec.column_name );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
    htp.formhidden( 'P1C', NULL );
    htp.formselectopen( 'P1C', null, 5, cattributes=>'MULTIPLE' );
    for c4rec in c4( 'C' ) loop
     open c3(c1rec.pid,c1rec.aid,'C',c4rec.column_name);
     fetch c3 into c3rec;
     if c3%FOUND
      then
       close c3;
       htp.formselectoption( c4rec.column_name,'SELECTED' );
      else
       close c3;
       htp.formselectoption( c4rec.column_name );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
    htp.formhidden( 'P1D', NULL );
    htp.formselectopen( 'P1D', null, 5, cattributes=>'MULTIPLE' );
    for c4rec in c4( 'G' ) loop
     open c3(c1rec.pid,c1rec.aid,'G',c4rec.column_name);
     fetch c3 into c3rec;
     if c3%FOUND
      then
       close c3;
       htp.formselectoption( c4rec.column_name,'SELECTED' );
      else
       close c3;
       htp.formselectoption( c4rec.column_name );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
    htp.formhidden( 'P1E', NULL );
    htp.formselectopen( 'P1E', null, 5, cattributes=>'MULTIPLE' );
    for c4rec in c4( 'N' ) loop
     open c3(c1rec.pid,c1rec.aid,'N',c4rec.column_name);
     fetch c3 into c3rec;
     if c3%FOUND
      then
       close c3;
       htp.formselectoption( c4rec.column_name,'SELECTED' );
      else
       close c3;
       htp.formselectoption( c4rec.column_name );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, LNG4.AHC_TXT_733 );
  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'MNG_REGISTER', errmsg=>sqlerrm);
end mng_register;

procedure accept_mng_register(surl in varchar2, acid in integer, p3 in varchar2, p4a in varchar2, p4b in varchar2, p4c in varchar2, p4d in varchar2, p4e in varchar2,
                              p5a in varchar2, p5b in varchar2, p5c in varchar2, p5d in varchar2, p5e in varchar2,
                              p6 in varchar2, p1a in GLBX.MYARRAY, p1b in GLBX.MYARRAY, p1c in GLBX.MYARRAY, p1d in GLBX.MYARRAY, p1e in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		number;
 von_presubmit	char(50);
 von_form	char(50);
 von_submit	char(50);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_MNG_REGISTER', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  von_presubmit := lpad( von_presubmit, 50, 'F' );
  von_form := lpad( von_presubmit, 50, 'F' );
  von_submit := lpad( von_presubmit, 50, 'F' );
  for j in p2.first..p2.last loop
   if substr(p2(j),1,1) = 'A'
    then
     von_presubmit := substr(von_presubmit,1,to_number(substr(p2(j),2))-1) || 'T' || substr(von_presubmit,to_number(substr(p2(j),2))+1);
   elsif substr(p2(j),1,1) = 'B'
    then
     von_form := substr(von_form,1,to_number(substr(p2(j),2))-1) || 'T' || substr(von_form,to_number(substr(p2(j),2))+1);
   elsif substr(p2(j),1,1) = 'C'
    then
     von_submit := substr(von_submit,1,to_number(substr(p2(j),2))-1) || 'T' || substr(von_submit,to_number(substr(p2(j),2))+1);
   end if;
  end loop;

  update generic_registration
   set
    on_presubmit = von_presubmit,
    on_form = von_form,
    on_submit = von_submit,
    extra_prompt = p3,
    lov_i = p4a,
    lov_s = p4b,
    lov_c = p4c,
    lov_g = p4d,
    lov_n = p4e,
    business_feature_i = p5a,
    business_feature_s = p5b,
    business_feature_c = p5c,
    business_feature_g = p5d,
    business_feature_n = p5e,
    call_program = p6
  where
   pid = c1rec.pid and
   aid = c1rec.aid;

  delete from generic_registration_columns where pid = c1rec.pid and aid = c1rec.aid and user_type = 'I';
  for j in p1a.first..p1a.last loop
   if p1a(j) is not null
    then
     insert into generic_registration_columns(pid,aid,user_type,column_name) values (c1rec.pid,c1rec.aid,'I',p1a(j));
   end if;
  end loop;
  delete from generic_registration_columns where pid = c1rec.pid and aid = c1rec.aid and user_type = 'S';
  for j in p1b.first..p1b.last loop
   if p1b(j) is not null
    then
     insert into generic_registration_columns(pid,aid,user_type,column_name) values (c1rec.pid,c1rec.aid,'S',p1b(j));
   end if;
  end loop;
  delete from generic_registration_columns where pid = c1rec.pid and aid = c1rec.aid and user_type = 'C';
  for j in p1c.first..p1c.last loop
   if p1c(j) is not null
    then
     insert into generic_registration_columns(pid,aid,user_type,column_name) values (c1rec.pid,c1rec.aid,'C',p1c(j));
   end if;
  end loop;
  delete from generic_registration_columns where pid = c1rec.pid and aid = c1rec.aid and user_type = 'G';
  for j in p1d.first..p1d.last loop
   if p1d(j) is not null
    then
     insert into generic_registration_columns(pid,aid,user_type,column_name) values (c1rec.pid,c1rec.aid,'G',p1d(j));
   end if;
  end loop;
  delete from generic_registration_columns where pid = c1rec.pid and aid = c1rec.aid and user_type = 'N';
  for j in p1d.first..p1d.last loop
   if p1e(j) is not null
    then
     insert into generic_registration_columns(pid,aid,user_type,column_name) values (c1rec.pid,c1rec.aid,'N',p1e(j));
   end if;
  end loop;
  commit;

  mng_register( surl, acid, LNG3.ADM_TXT_518 );

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_MNG_REGISTER', errmsg=>sqlerrm);
end accept_mng_register;

procedure mng_workflow(surl in varchar2, msg in varchar2 default null )
as

 cursor c2( phgid integer ) is
  select workflow_name,status_workflow,name,date_created,ws1.work_state
  from workflow_set ws, workflow_state ws1
  where ws.pid = phgid and
        ws.work_state = ws1.work_state
  order by upper(workflow_name);
 cursor c3( phgid integer ) is select * from workflow_activity_defn where pid = phgid order by name;
 cursor c4( phgid integer ) is select * from workflow_state where pid = phgid order by name;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MNG_WORKFLOW', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG4.AHC_TXT_610, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P57',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  if msg is not null then glbx.header_msg(msg); end if;

  htp.p( '<CENTER>' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_612 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG.GLB_TXT_078 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_808 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG2.FNM_TXT_016 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   for c2rec in c2(owner_id) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'pbk.mng_workflow_set?surl=' || surl || '&workid=' || c2rec.status_workflow,htf.bold(initcap(c2rec.workflow_name) )), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(c2rec.date_created,LNG.MASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.anchor( 'pbk.mng_workflow_state?surl=' || surl || '&p1=&wsid=' || c2rec.work_state,c2rec.name ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( '[' || htf.anchor( 'pbk.mng_workflow_set?surl=' || surl || '&workid=' || c2rec.status_workflow,LNG.GLB_TXT_123 ) || ']' ||
                   '[' || htf.anchor( 'pbk.del_workflow_set?surl=' || surl || '&workid=' || c2rec.status_workflow,LNG.SLD_TXT_004 ) || ']' ||
                   '[' || htf.anchor2( 'pbk.workflow_chart?surl=' || surl || '&workid=' || c2rec.status_workflow,LNG4.AHC_TXT_111, ctarget=>'WORKFLOW_WINDOW' ) || ']' || htf.nl ||
                   '[' || htf.anchor( 'pbk.view_workflow_set?surl=' || surl || '&workid=' || c2rec.status_workflow,LNG4.AHC_TXT_810 ) || ']', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   end loop;
  htp.tableclose;
  htp.nl;
  htp.anchor( 'pbk.mng_workflow_set?surl=' || surl || '&workid=', LNG4.AHC_TXT_616 );
  htp.nl;
  htp.line;
  htp.nl;
  htp.bold( LNG4.AHC_TXT_809 );
  htp.nl;
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_811 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG2.FNM_TXT_016 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   for c3rec in c3(owner_id) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'pbk.mng_workflow_activity?surl=' || surl || '&p1=&actid=' || c3rec.workflow_activity_id,c3rec.name), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( '[' || htf.anchor( 'pbk.mng_workflow_activity?surl=' || surl || '&p1=&actid=' || c3rec.workflow_activity_id,LNG.GLB_TXT_123 ) || ']' ||
                   '[' || htf.anchor( 'pbk.del_workflow_activity?surl=' || surl || '&p1=&actid=' || c3rec.workflow_activity_id,LNG.SLD_TXT_004) || ']', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   end loop;
  htp.tableclose;
  htp.nl;
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
  htp.tabledata( htf.bold( LNG4.AHC_TXT_812 ) );
  htp.formopen( 'pbk.mng_workflow_activity' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACTID', null );
  htp.tabledata( htf.formtext('P1', 30, 100) );
  htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, LNG2.PBK_TXT_012 );
  htp.formclose;
  htp.line;
  htp.nl;
  htp.bold( LNG4.AHC_TXT_813 );
  htp.nl;
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_808 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG2.FNM_TXT_016 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   for c4rec in c4(owner_id) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'pbk.mng_workflow_state?surl=' || surl || '&p1=&wsid=' || c4rec.work_state,c4rec.name), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.anchor( 'pbk.mng_workflow_state?surl=' || surl || '&p1=&wsid=' || c4rec.work_state,'[' || LNG.GLB_TXT_123 || ']') ||
                   htf.anchor( 'pbk.mng_workflow_state_del?surl=' || surl || '&wsid=' || c4rec.work_state,'[' || LNG.SLD_TXT_004 || ']'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   end loop;
  htp.tableclose;
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
  htp.tabledata( htf.bold( LNG4.AHC_TXT_814 ) );
  htp.formopen( 'pbk.mng_workflow_state' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'WSID', null );
  htp.tabledata( htf.formtext('P1', 30, 100) );
  htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, LNG2.PBK_TXT_012 );
  htp.formclose;
  htp.line;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'MNG_WORKFLOW', errmsg=>sqlerrm);
end mng_workflow;

procedure mng_workflow_set(surl in varchar2, workid in integer, msg in varchar2 default null )
as

 cursor c2( phgid integer, workid integer ) is select * from workflow_set where pid = phgid and status_workflow = workid;
 cursor c3( phgid integer, workid integer ) is select * from workflow where pid = phgid and status_workflow = workid order by status_priority_default;
 cursor c4( phgid integer, actid integer ) is select name from workflow_activity_defn where pid = phgid and workflow_activity_id = actid;
/*
 cursor c5( stsid integer ) is
  select sub_category || '=' || value nm
  from workflow_query wq, umo_attributes uts
  where status_id = stsid and
        wq.attribute_id = uts.attribute_id
  order by wq.attribute_id;
  */
 cursor c6(phgid integer) is
  select manufacturer_id,name
  from manufacturer
  order by name;

 /*
  -- Removed. Assume restriction is not crucial at this stage
  where price_book_public = 'T' and public_book is not null
   union
  select m.manufacturer_id, name
  from manufacturer_photographer_disc mpd, manufacturer m
  where m.manufacturer_id = mpd.manufacturer_id and
        mpd.pid = phgid and
        mpd.private_price_book = 'T'
  order by 2;
 */

 cursor c7(phgid integer) is select * from workflow_state where pid = phgid order by name;
 cursor c8( phgid integer ) is select * from workflow_activity_defn where pid = phgid order by name;

 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 --c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 foundrec	boolean;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MNG_WORKFLOW_SET', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  open c2(owner_id,workid);
  fetch c2 into c2rec;
  close c2;
  if workid is null
   then
    glbx.main_title( surl, LNG4.AHC_TXT_616, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P57',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   else
    glbx.main_title( surl, LNG4.AHC_TXT_615 || ':' || initcap(c2rec.workflow_name), glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P57',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  end if;
  htp.nl;
  if msg is not null then glbx.header_msg(msg); end if;
  htp.p( '<CENTER>' );
  if workid is null
   then
    htp.nl;
    htp.nl;
    htp.formopen( 'pbk.accept_new_workflow' );
    htp.formhidden( 'SURL', surl );
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG4.AHC_TXT_612 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.formtext( 'P1', 30, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG4.AHC_TXT_815 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      htp.formselectopen( 'P2' );
      htp.formselectoption( LNG.PHG_TXT_042, cattributes=>'VALUE="0"');
      for c7rec in c7(owner_id) loop
       htp.formselectoption( c7rec.name, cattributes=>'VALUE="' || c7rec.work_state || '"');
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tableclose;
     htp.nl;
     htp.nl;
     htp.nl;
     htp.formsubmit( null, LNG4.AHC_TXT_618 );
     htp.formclose;
    htp.htmlclose;
    return;
  end if;

  htp.formopen( 'pbk.accept_mng_workflow_set' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'WORKID', workid );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_614 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_816 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold(LNG2.PBK_TXT_009), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   foundrec := FALSE;
   for c3rec in c3(owner_id,workid) loop
   foundrec := TRUE;
   htp.tablerowopen;
    htp.formhidden( 'P0', c3rec.status_id );
    htp.tabledata( htf.formtext( 'P2', 10, 20, to_char(c3rec.status_priority_default)), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    if c3rec.workflow_type = 'Q'
     then
      htp.tabledata( LNG3.ADM_TXT_428, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.anchor( 'pbk.mng_workflow_task?surl=' || surl || '&workid=' || workid || '&p1=&vsts=' || c3rec.status_id,c3rec.question), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    elsif c3rec.workflow_type = 'M'
     then
      htp.tabledata( LNG4.AHC_TXT_817, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    elsif c3rec.workflow_type in ('G','I')
     then
      if c3rec.workflow_type = 'G'
       then
        htp.tabledata( LNG4.AHC_TXT_818, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( LNG5.EXT_TXT_127, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      open c4(owner_id,c3rec.goto_workflow);
      fetch c4 into c4rec;
      close c4;
      htp.tabledata( htf.anchor( 'pbk.mng_workflow_task?surl=' || surl || '&workid=' || workid || '&p1=&vsts=' || c3rec.status_id,c4rec.name), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
    -- Manufacturer Selection
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    htp.formselectopen( 'P1' );
    htp.formselectoption( NULL );
    for c6rec in c6(owner_id) loop
     if c6rec.manufacturer_id = c3rec.manufacturer_id
      then
       htp.formselectoption( c6rec.name, 'SELECTED', cattributes=>'VALUE="' || c6rec.manufacturer_id || '"');
      else
       htp.formselectoption( c6rec.name, cattributes=>'VALUE="' || c6rec.manufacturer_id || '"');
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.anchor( 'pbk.mng_workflow_task?surl=' || surl || '&workid=' || workid || '&p1=&vsts=' || c3rec.status_id,'[' || LNG.GLB_TXT_123 || ']' ) ||
                   htf.anchor( 'pbk.mng_workflow_task_del?surl=' || surl || '&workid=' || workid || '&vsts=' || c3rec.status_id,'[' || LNG.SLD_TXT_004 || ']' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   end loop;
  htp.tableclose;
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
  if foundrec
   then
    htp.tabledata( htf.formsubmit( null, LNG4.AHC_TXT_819 ));
  end if;
  htp.formclose;
  htp.formopen( 'pbk.mng_workflow' );
  htp.formhidden( 'SURL', surl );
  htp.tabledata( htf.formsubmit( null, LNG4.AHC_TXT_820 ) );
  htp.formclose;
  htp.tablerowclose;
  htp.tableclose;
  htp.line;
  htp.nl;
  htp.bold( LNG4.AHC_TXT_821 );
  htp.nl;
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
  htp.tabledata( htf.bold( LNG4.AHC_TXT_822 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
  htp.formopen( 'pbk.mng_workflow_task' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'WORKID', workid );
  htp.formhidden( 'VSTS', null );
  htp.formselectopen( 'P1' );
  htp.formselectoption( LNG3.ADM_TXT_428, cattributes=>'VALUE="Q"');
  htp.formselectoption( LNG4.AHC_TXT_817, cattributes=>'VALUE="M"');
  htp.formselectoption( LNG4.AHC_TXT_818, cattributes=>'VALUE="G"');
  htp.formselectoption( LNG5.EXT_TXT_126, cattributes=>'VALUE="I"');
  htp.formselectclose;
  htp.p('</TD>' );
  htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit(null, LNG2.PBK_TXT_012 );
  htp.formclose;
  htp.nl;
  htp.line;
  htp.nl;
  htp.bold( LNG4.AHC_TXT_809 );
  htp.nl;
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_811 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG2.FNM_TXT_016 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   for c8rec in c8(owner_id) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'pbk.mng_workflow_activity?surl=' || surl || '&p1=&actid=' || c8rec.workflow_activity_id,c8rec.name), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( '[' || htf.anchor( 'pbk.mng_workflow_activity?surl=' || surl || '&p1=&actid=' || c8rec.workflow_activity_id,LNG.GLB_TXT_123 ) || ']' ||
                   '[' || htf.anchor( 'pbk.del_workflow_activity?surl=' || surl || '&p1=&actid=' || c8rec.workflow_activity_id,LNG.SLD_TXT_004) || ']', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   end loop;
  htp.tableclose;
  htp.nl;
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
  htp.tabledata( htf.bold( LNG4.AHC_TXT_812 ) );
  htp.formopen( 'pbk.mng_workflow_activity' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACTID', null );
  htp.tabledata( htf.formtext('P1', 30, 100) );
  htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, LNG2.PBK_TXT_012 );
  htp.formclose;  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'MNG_WORKFLOW_SET', errmsg=>sqlerrm);
end mng_workflow_set;

procedure accept_new_workflow( surl in varchar2, p1 in varchar2, p2 in integer )
as

 cursor c2 is select max(status_workflow) mx from workflow_set;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_NEW_WORKFLOW', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  open c2;
  fetch c2 into c2rec;
  close c2;
  c2rec.mx := nvl(c2rec.mx,0) + 1;
  insert into workflow_set( pid,status_workflow,date_created,workflow_name,work_state)
   values
    (owner_id, c2rec.mx, sysdate, upper(p1),p2);
  commit;

  mng_workflow_set( surl, c2rec.mx, msg=>LNG4.AHC_TXT_638 );

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_NEW_WORKFLOW', errmsg=>sqlerrm);
end accept_new_workflow;

procedure mng_workflow_task_del(surl in varchar2, workid in integer, vsts in integer )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MNG_WORKFLOW_TASK_DEL', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  delete from workflow_question where status_id = vsts;
  delete from workflow_query_clause where query_id in (select query_id from workflow_query where status_id = vsts);
  delete from workflow_query where status_id = vsts;
  delete from workflow where status_id = vsts and pid = owner_id;
  commit;

  mng_workflow_set( surl, workid, LNG4.AHC_TXT_621 );

exception when others then
 glbx.error_details( 'PBK', 'MNG_WORKFLOW_TASK_DEL', errmsg=>sqlerrm);
end mng_workflow_task_del;

procedure mng_workflow_state_del(surl in varchar2, wsid in integer )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MNG_WORKFLOW_STATE_DEL', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  if wsid = 0
   then
    null;
   else
    delete from workflow_state_options where work_state = wsid and work_state = (select work_state from workflow_state where pid = owner_id and work_state = wsid);
    -- On Cascade Delete, set the Workflow Set back to the default
    update workflow_set set work_state = 0 where work_state = wsid;
    delete from workflow_state where pid = owner_id and work_state = wsid;
    commit;
  end if;

  mng_workflow( surl, LNG4.AHC_TXT_621 );

exception when others then
 glbx.error_details( 'PBK', 'MNG_WORKFLOW_STATE_DEL', errmsg=>sqlerrm, extdet=>'WSID:' || wsid);
end mng_workflow_state_del;

procedure mng_workflow_task(surl in varchar2, workid in integer, vsts in varchar2, p1 in varchar2, msg in varchar2 default null )
as

 cursor c2( phgid integer, workid integer ) is select * from workflow_set where pid = phgid and status_workflow = workid;
 cursor c3( phgid integer, workid integer, vsts integer ) is select * from workflow where pid = phgid and status_workflow = workid and status_id = vsts order by status_priority_default;
 cursor c4( vsts integer ) is select rowid, wq.* from workflow_question wq where status_id = vsts order by response;
 cursor c5( phgid integer ) is select * from workflow_activity_defn where pid = phgid order by name;
 cursor c6( vsts integer ) is select * from workflow_query where status_id = vsts order by decode(if_or_else,'I',0,1),order_by;

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 if_done	boolean;
 else_done	boolean;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MNG_WORKFLOW_TASK', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  open c2(owner_id,workid);
  fetch c2 into c2rec;
  close c2;
  if vsts is null
   then
    glbx.main_title( surl, LNG4.AHC_TXT_821 , glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P57',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   else
    glbx.main_title( surl, LNG4.AHC_TXT_823 || ':' || initcap(c2rec.workflow_name), glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P57',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  end if;
  htp.nl;
  if msg is not null then glbx.header_msg(msg); end if;
  htp.p( '<CENTER>' );

  if vsts is null
   then
    c3rec.workflow_type := p1;
   else
    open c3(owner_id,workid,vsts);
    fetch c3 into c3rec;
    close c3;
  end if;

  htp.formopen( 'pbk.accept_workflow_task' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'WORKID', workid );
  htp.formhidden( 'VSTS', vsts );
  htp.formhidden( 'P1', c3rec.workflow_type );

  if c3rec.workflow_type = 'Q'
   then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
    htp.p( '<TD COLSPAN=2>' );
    htp.bold( LNG3.ADM_TXT_428 || ':' );
    htp.formtext( 'P2', 60, 4000, c3rec.question );
    htp.formhidden( 'P5', null );
    htp.p( '</TD>' );
    htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold( 'Default Answer' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( LNG3.ADM_TXT_561 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( LNG4.AHC_TXT_811 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tablerowclose;
    for c4rec in c4( vsts ) loop
     htp.tablerowopen;
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
      htp.formselectopen( 'P3D' );
      if c4rec.is_default = 'T'
       then
        htp.formselectoption( 'Yes', 'SELECTED', cattributes=>'VALUE="T"');
        htp.formselectoption( 'No', cattributes=>'VALUE="F"');
       else
        htp.formselectoption( 'Yes', cattributes=>'VALUE="T"');
        htp.formselectoption( 'No', 'SELECTED', cattributes=>'VALUE="F"');
      end if;
      htp.formselectclose;
      htp.p( '</TD>' );
      htp.tabledata( htf.formtext( 'P3', 6, 100, c4rec.response ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
      htp.formselectopen( 'P4' );
      if c4rec.workflow_activity_id = 0
       then
         htp.formselectoption( LNG5.EXT_TXT_008, 'SELECTED', cattributes=>'VALUE="0"');
       else
         htp.formselectoption( LNG5.EXT_TXT_008, cattributes=>'VALUE="0"');
      end if;
      for c5rec in c5( owner_id ) loop
       if c5rec.workflow_activity_id = c4rec.workflow_activity_id
        then
         htp.formselectoption( c5rec.name, 'SELECTED', cattributes=>'VALUE="' || c5rec.workflow_activity_id || '"');
        else
         htp.formselectoption( c5rec.name, cattributes=>'VALUE="' || c5rec.workflow_activity_id || '"');
       end if;
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
    end loop;
    for j in 1..5 loop
     htp.tablerowopen;
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
      htp.formselectopen( 'P3D' );
        htp.formselectoption( 'Yes', cattributes=>'VALUE="T"');
        htp.formselectoption( 'No', 'SELECTED', cattributes=>'VALUE="F"');
      htp.formselectclose;
      htp.p( '</TD>' );
      htp.tabledata( htf.formtext( 'P3', 6, 100, null ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
      htp.formselectopen( 'P4' );
      htp.formselectoption( LNG5.EXT_TXT_008, cattributes=>'VALUE="0"');
      for c5rec in c5( owner_id ) loop
       htp.formselectoption( c5rec.name, cattributes=>'VALUE="' || c5rec.workflow_activity_id || '"');
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
    end loop;
    htp.tableclose;

  elsif c3rec.workflow_type = 'M'
   then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.formhidden( 'P2', null );
    htp.formhidden( 'P3D', null );
    if_done := FALSE;
    else_done := FALSE;
    for c6rec in c6( vsts ) loop
     htp.formhidden( 'P4', c6rec.query_id );
     htp.tablerowopen;
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      if c6rec.if_or_else = 'I' and c6%ROWCOUNT = 1
       then
        htp.bold( LNG4.AHC_TXT_620 || ' ' || htf.anchor( 'pbk.edit_workflow_query?surl=' || surl || '&workid=' || workid || '&vsts=' || vsts || '&qry=' || c6rec.query_id, '#' || c6rec.query_id ) || ' ' || LNG4.AHC_TXT_622 || ' ' );
        if_done := TRUE;
      elsif c6rec.if_or_else = 'I'
       then
        htp.bold( LNG4.AHC_TXT_623 || ' ' || htf.anchor( 'pbk.edit_workflow_query?surl=' || surl || '&workid=' || workid || '&vsts=' || vsts || '&qry=' || c6rec.query_id, '#' || c6rec.query_id ) || ' ' || LNG4.AHC_TXT_622 || ' ' );
      elsif c6rec.if_or_else = 'E'
       then
        htp.bold( LNG4.AHC_TXT_624 || ' ' );
        else_done := TRUE;
      end if;
      htp.formselectopen( 'P5' );
      for c5rec in c5( owner_id ) loop
       if c5rec.workflow_activity_id = c6rec.workflow_activity_id
        then
         htp.formselectoption( c5rec.name, 'SELECTED', cattributes=>'VALUE="' || c5rec.workflow_activity_id || '"');
        else
         htp.formselectoption( c5rec.name, cattributes=>'VALUE="' || c5rec.workflow_activity_id || '"');
       end if;
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
      if c6rec.if_or_else = 'I'
       then
        htp.tabledata( htf.formtext('P3',5,10,c6rec.order_by), pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( '&nbsp;', pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        htp.formhidden( 'P3', null );
      end if;
     htp.tablerowclose;
    end loop;

     htp.tablerowopen;
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      if nvl(vsts,0) = 0
       then
        htp.bold( LNG4.AHC_TXT_959 );
       else
        htp.bold( htf.anchor( 'pbk.edit_workflow_query?surl=' || surl || '&workid=' || workid || '&vsts=' || vsts || '&qry=', LNG4.AHC_TXT_625 ));
      end if;
      htp.p( '</TD>' );
      htp.tabledata( '&nbsp;', pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;

    htp.tablerowopen;
    if not else_done
     then
      htp.formhidden( 'P4', '0' );
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      htp.bold( LNG4.AHC_TXT_958 || ' ' );
      htp.formselectopen( 'P5' );
      for c5rec in c5( owner_id ) loop
       htp.formselectoption( c5rec.name, cattributes=>'VALUE="' || c5rec.workflow_activity_id || '"');
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
      htp.tabledata( '&nbsp;', pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.formhidden( 'P3',null);
     htp.tablerowclose;
    end if;
    htp.tableclose;

  elsif c3rec.workflow_type in ('G','I')
   then
    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      if c3rec.workflow_type = 'G'
       then
        htp.tabledata( htf.bold( LNG4.AHC_TXT_827 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
       else
        htp.tabledata( htf.bold( LNG5.EXT_TXT_127 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      end if;
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
      htp.formhidden( 'P2', null );
      htp.formhidden( 'P3', null );
      htp.formhidden( 'P5', null );
      htp.formhidden( 'P3D', null );
      htp.formselectopen( 'P4' );
      for c5rec in c5( owner_id ) loop
       if c5rec.workflow_activity_id = c3rec.goto_workflow
        then
         htp.formselectoption( c5rec.name, 'SELECTED', cattributes=>'VALUE="' || c5rec.workflow_activity_id || '"');
        else
         htp.formselectoption( c5rec.name, cattributes=>'VALUE="' || c5rec.workflow_activity_id || '"');
       end if;
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;
  end if;
  htp.nl;
  if vsts is null
   then
    htp.formsubmit( null, LNG4.AHC_TXT_828 );
   else
    htp.formsubmit( null, LNG4.AHC_TXT_819 );
  end if;
  htp.formclose;
  htp.line;
  htp.formopen( 'pbk.mng_workflow_set' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'WORKID', workid );
  htp.formsubmit( null, LNG4.AHC_TXT_820 );
  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'MNG_WORKFLOW_TASK', errmsg=>sqlerrm);
end mng_workflow_task;

procedure edit_workflow_query(surl in varchar2, workid in integer, vsts in integer, qry in integer, msg in varchar2 default null )
as

 cursor c1(qry integer) is select * from workflow_query_clause where query_id = qry order by order_by;
 cursor c2 is
  select  'A' || attribute_id res, '[' || umo_type || '] ' || sub_category disp
  from umo_attributes
  union all
  select 'P' || column_name, '[Purchase]' || column_name
  from user_tab_columns
  where table_name = 'PURCHASE_ORDER'
  union all
  select 'S' || column_name, '[Shopping]' || column_name
  from user_tab_columns
  where table_name = 'SHOPPING_BASKET'
  union all
  select 'U' || column_name, '[UMO]' || column_name
  from user_tab_columns
  where table_name = 'UMO' and
        data_type in ( 'CHAR','NUMBER','VARCHAR2')
  union all
  select 'Z' || '1', '[System]' || 'Last Item'
  from dual
  order by 1;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 cl		varchar2(100);
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.EDIT_WORKFLOW_QUERY', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  pfx := glbx.photo_lf(owner_id);
  if qry is null
   then
    glbx.main_title( surl, LNG4.AHC_TXT_650 , glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P60',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   else
    glbx.main_title( surl, LNG4.AHC_TXT_667 || ':' || qry , glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P60',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  end if;
  htp.nl;
  if msg is not null then glbx.header_msg(msg); end if;
  htp.p( '<CENTER>' );
  htp.formopen( 'pbk.accept_edit_workflow_query' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'WORKID', workid );
  htp.formhidden( 'VSTS', vsts );
  htp.formhidden( 'QRY', qry );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.GLB_TXT_063 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_674 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_922 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG.CST_TXT_013 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_695 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_697 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  for c1rec in c1(qry) loop
   htp.tablerowopen;
    htp.formhidden( 'P0', c1rec.order_by );
    htp.tabledata( htf.formtext( 'P1', 5, 10, c1rec.order_by ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    cl := NULL;
    if c1rec.attribute_id is not null then cl := 'A' || c1rec.attribute_id;
    elsif c1rec.system_column is not null then cl := 'Z' || c1rec.system_column;
    elsif c1rec.purchase_column is not null then cl := 'P' || c1rec.purchase_column;
    elsif c1rec.shopping_column is not null then cl := 'S' || c1rec.shopping_column;
    elsif c1rec.umo_column is not null then cl := 'U' || c1rec.umo_column;
    end if;
    htp.formselectopen( 'P2' );
    htp.formselectoption( NULL );
    for c2rec in c2 loop
     if c2rec.res = cl
      then
       htp.formselectoption( c2rec.disp,'SELECTED', cattributes=>'VALUE="' || c2rec.res || '"' );
      else
       htp.formselectoption( c2rec.disp,cattributes=>'VALUE="' || c2rec.res || '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    htp.formselectopen( 'P3' );
     if c1rec.expression = '=' then htp.formselectoption( '=','SELECTED'); else htp.formselectoption( '=' ); end if;
     if c1rec.expression = '<' then htp.formselectoption( '<','SELECTED'); else htp.formselectoption( '<' ); end if;
     if c1rec.expression = '>' then htp.formselectoption( '>','SELECTED'); else htp.formselectoption( '>' ); end if;
     if c1rec.expression = '<=' then htp.formselectoption( '<=','SELECTED'); else htp.formselectoption( '<=' ); end if;
     if c1rec.expression = '>=' then htp.formselectoption( '>=','SELECTED'); else htp.formselectoption( '>=' ); end if;
     if c1rec.expression = '<>' then htp.formselectoption( '<>','SELECTED'); else htp.formselectoption( '<>' ); end if;
     if c1rec.expression = 'IN' then htp.formselectoption( 'IN','SELECTED'); else htp.formselectoption( 'IN' ); end if;
     if c1rec.expression = 'NOT IN' then htp.formselectoption( 'NOT IN','SELECTED'); else htp.formselectoption( 'NOT IN' ); end if;
     if c1rec.expression = 'LIKE' then htp.formselectoption( 'LIKE','SELECTED'); else htp.formselectoption( 'LIKE' ); end if;
     if c1rec.expression = 'NOT LIKE' then htp.formselectoption( 'NOT LIKE','SELECTED'); else htp.formselectoption( 'NOT LIKE' ); end if;
     if c1rec.expression = 'IS NULL' then htp.formselectoption( 'IS NULL','SELECTED'); else htp.formselectoption( 'IS NULL' ); end if;
     if c1rec.expression = 'IS NOT NULL' then htp.formselectoption( 'IS NOT NULL','SELECTED'); else htp.formselectoption( 'IS NOT NULL' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext( 'P4', 30, 4000, c1rec.value ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P5', 20, 100, c1rec.apply_function ) || htf.nl ||
                   htf.formtext( 'P6', 20, 100, c1rec.extra_function_parm ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P7' );
     if c1rec.and_or = 'AND' then htp.formselectoption( 'AND','SELECTED'); else htp.formselectoption( 'AND' ); end if;
     if c1rec.and_or = 'OR' then htp.formselectoption( 'OR','SELECTED'); else htp.formselectoption( 'OR' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  end loop;

  for j in 1..5 loop
   htp.tablerowopen;
    htp.formhidden( 'P0', null );
    htp.tabledata( htf.formtext( 'P1', 5, 10, null ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    htp.formselectopen( 'P2' );
    htp.formselectoption( NULL );
    for c2rec in c2 loop
     htp.formselectoption( c2rec.disp,cattributes=>'VALUE="' || c2rec.res || '"' );
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    htp.formselectopen( 'P3' );
     htp.formselectoption( '=' );
     htp.formselectoption( '<' );
     htp.formselectoption( '>' );
     htp.formselectoption( '<=' );
     htp.formselectoption( '>=' );
     htp.formselectoption( '<>' );
     htp.formselectoption( 'IN' );
     htp.formselectoption( 'NOT IN' );
     htp.formselectoption( 'LIKE' );
     htp.formselectoption( 'NOT LIKE' );
     htp.formselectoption( 'IS NULL' );
     htp.formselectoption( 'IS NOT NULL' );
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext( 'P4', 30, 4000 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P5', 20, 100 ) || htf.nl ||
                   htf.formtext( 'P6', 20, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P7' );
     htp.formselectoption( 'AND' );
     htp.formselectoption( 'OR' );
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  end loop;

  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
   htp.tablerowopen;
    htp.tabledata( htf.formsubmit( 'ACTION', LNG4.AHC_TXT_778 ));
    htp.tabledata( htf.formsubmit( 'ACTION', LNG4.AHC_TXT_869 ));
   htp.tablerowclose;
  htp.tableclose;
  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'EDIT_WORKFLOW_QUERY', errmsg=>sqlerrm);
end edit_workflow_query;

procedure accept_edit_workflow_query(surl in varchar2, workid in integer, vsts in integer, qry in integer, action in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY )
as

 cursor c1 is select max(query_id) mx from workflow_query_clause;
 cursor c2(qry integer) is select rowid from workflow_query_clause where query_id = qry order by order_by;
 cursor c3 is select max(order_by) mx from workflow_query;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 nmb		integer;
 cl		varchar2(100);
 sts		varchar2(100);
 mx		integer;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_EDIT_WORKFLOW_QUERY', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if qry is null
   then
    open c1;
    fetch c1 into c1rec;
    close c1;
    c1rec.mx := nvl(c1rec.mx,0) + 1;
    open c3;
    fetch c3 into c3rec;
    close c3;
    c3rec.mx := nvl(c3rec.mx,0) + 1;
    insert into workflow_query(status_id,query_id,workflow_activity_id,order_by,if_or_else) values
     (vsts,c1rec.mx,null,c3rec.mx,'I');
   else
    c1rec.mx := qry;
  end if;

  for j in p0.first..p0.last loop
   begin nmb := to_number(p1(j)); exception when others then nmb := NULL; end;
   if p0(j) is null and p2(j) is null -- Do Nothing
    then
     null;
   elsif p0(j) is null and p2(j) is not null -- Insert New Workflow Query
    then
     insert into workflow_query_clause(query_id,order_by,
       system_column,attribute_id,purchase_column,shopping_column,umo_column,
       expression,value,apply_function,extra_function_parm,and_or) values
      (c1rec.mx,nmb,
       decode(substr(p2(j),1,1),'Z',to_number(substr(p2(j),2)),NULL),
       decode(substr(p2(j),1,1),'A',to_number(substr(p2(j),2)),NULL),
       decode(substr(p2(j),1,1),'P',substr(p2(j),2),NULL),
       decode(substr(p2(j),1,1),'S',substr(p2(j),2),NULL),
       decode(substr(p2(j),1,1),'U',substr(p2(j),2),NULL),
       p3(j),p4(j),p5(j),p6(j),p7(j));
   elsif p0(j) is not null and p2(j) is null -- Delete
    then
     delete from workflow_query_clause
      where
       query_id = c1rec.mx and
       order_by = p0(j);
   elsif p0(j) is not null and p2(j) is not null -- Update
    then
     update workflow_query_clause
      set
       order_by = nmb,
       attribute_id = decode(substr(p2(j),1,1),'A',to_number(substr(p2(j),2)),NULL),
       system_column = decode(substr(p2(j),1,1),'Z',to_number(substr(p2(j),2)),NULL),
       purchase_column = decode(substr(p2(j),1,1),'P',substr(p2(j),2),NULL),
       shopping_column = decode(substr(p2(j),1,1),'S',substr(p2(j),2),NULL),
       umo_column = decode(substr(p2(j),1,1),'U',substr(p2(j),2),NULL),
       expression = p3(j),
       value = p4(j),
       apply_function = p5(j),
       extra_function_parm = p6(j),
       and_or = p7(j)
      where
       query_id = c1rec.mx and
       order_by = p0(j);
   end if;
  end loop;

  for c2rec in c2(c1rec.mx) loop
   nmb := c2%ROWCOUNT;
   update workflow_query_clause
    set
     order_by = nmb
   where
    rowid = c2rec.rowid;
  end loop;

  commit;

  if action = 'Modify Workflow Query Clause'
   then
    edit_workflow_query( surl, workid, vsts, c1rec.mx, LNG4.AHC_TXT_870 );
   else
    mng_workflow_task( surl, workid, vsts, null );
  end if;

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_EDIT_WORKFLOW_QUERY', errmsg=>sqlerrm);
end accept_edit_workflow_query;

procedure view_workflow_set(surl in varchar2, workid in integer, msg in varchar2 default null )
as

 cursor c1(phgid integer, workid integer) is
  select *
  from shopping_basket
  where status_workflow = workid and
        poid in (select poid from purchase_order where pid = phgid )
  order by shopping_id desc;

 cursor c2(stsid integer) is select * from workflow where status_id = stsid;
 cursor c3(mfid integer) is select username from manufacturer where manufacturer_id = mfid;
 cursor c4(st1 integer, st2 integer) is select * from workflow_state_options where work_state = st1 and status_priority_id = st2;

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.VIEW_WORKFLOW_SET', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG4.AHC_TXT_304, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B17',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  if msg is not null then glbx.header_msg(msg); end if;
  htp.p( '<CENTER>' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.CST_TXT_099 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_937 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_938 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG2.PBK_TXT_009 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_939 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_726 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG2.FNM_TXT_016), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  for c1rec in c1(owner_id,workid) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'pbk.view_workflow_details?surl=' || surl || '&workid=' || workid || '&shp=' || c1rec.shopping_id,c1rec.poid), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( c1rec.shopping_id, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    open c2(c1rec.status_id);
    fetch c2 into c2rec;
    close c2;
    if c2rec.workflow_type = 'Q'
     then
      htp.tabledata( LNG3.ADM_TXT_428, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    elsif c2rec.workflow_type = 'M'
     then
      htp.tabledata( LNG4.AHC_TXT_940, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    else
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
    c3rec.username := NULL;
    open c3(c2rec.manufacturer_id);
    fetch c3 into c3rec;
    close c3;
    htp.tabledata( nvl(c3rec.username,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    if c1rec.status = '0'
     then
      htp.tabledata( LNG2.PFM_TXT_139, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    elsif c1rec.status_id = '1'
     then
      htp.tabledata( 'Running', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    elsif c1rec.status_id = '10'
     then
      htp.tabledata( 'Manufacturer Question', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    elsif c1rec.status_id = '20'
     then
      htp.tabledata( 'Manufacturer Update Meta Tag', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    elsif c1rec.status_id = '30'
     then
      htp.tabledata( 'Manufacturer Reassign', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    else
      htp.tabledata( nvl(c1rec.status,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
    htp.tabledata( nvl(to_char(c1rec.priority_of_item),'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( '[' || htf.anchor( 'pbk.utility_workflow?surl=' || surl || '&workid=' || workid || '&shp=' || c1rec.shopping_id || '&action=1', LNG4.AHC_TXT_941 ) || ']' ||
                  ' [' || htf.anchor( 'pbk.utility_workflow?surl=' || surl || '&workid=' || workid || '&shp=' || c1rec.shopping_id || '&action=2', LNG4.AHC_TXT_942 ) || ']' ||
                  ' [' || htf.anchor( 'pbk.utility_workflow?surl=' || surl || '&workid=' || workid || '&shp=' || c1rec.shopping_id || '&action=3', LNG4.AHC_TXT_943 ) || ']', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  end loop;
  htp.tableclose;

  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'VIEW_WORKFLOW_SET', errmsg=>sqlerrm);
end view_workflow_set;

procedure utility_workflow( surl in varchar2, workid in integer, shp in integer, action in varchar2, msg in varchar2 default null )
as

 cursor c1(shp integer, phgid integer) is
  select po.poid,sb.shopping_id,sb.status_mfctr,sb.status_workflow,sb.status_id,sb.status_priority
  from shopping_basket sb,purchase_order po
  where po.poid=sb.poid and
        sb.shopping_id = shp and
        po.pid = phgid;
 cursor c2(phgid integer) is
  select manufacturer_id,name
  from manufacturer
  where price_book_public = 'T' and public_book is not null
   union
  select m.manufacturer_id, name
  from manufacturer_photographer_disc mpd, manufacturer m
  where m.manufacturer_id = mpd.manufacturer_id and
        mpd.pid = phgid and
        mpd.private_price_book = 'T'
  order by 2;
 cursor c3(stw integer, stp integer) is select * from workflow where status_workflow = stw and status_priority_default = stp;
 cursor c4(stsid integer) is select * from workflow_question where status_id = stsid;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.UTILITY_WORKFLOW', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  -- Validate Shopping Id
  open c1(shp,owner_id);
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    close c1;
    htp.p( LNG4.AHC_TXT_944 );
    return;
  end if;
  close c1;

  if action = 1 -- Mark Completed
   then
    update shopping_basket
     set
      status = '0',
      status_mfctr = NULL
    where
     shopping_id = c1rec.shopping_id;
    commit;

  elsif action = 2 -- Reassign
   then
    pfx := glbx.photo_lf(owner_id);
    glbx.main_title( surl, LNG4.AHC_TXT_952 ,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B17',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.nl;
    glbx.instruction( LNG4.AHC_TXT_951, pfx );
    htp.p( '<CENTER>' );
    htp.formopen( 'pbk.utility_workflow_ext' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'WORKID', workid );
    htp.formhidden( 'ACTION_STEP', action );
    htp.formhidden( 'SHP', shp );
    htp.formselectopen( 'P1' );
    for c2rec in c2(owner_id) loop
     if c1rec.status_mfctr = c2rec.manufacturer_id
      then
       htp.formselectoption( c2rec.name, 'SELECTED', cattributes=>'VALUE="' || c2rec.manufacturer_id|| '"');
      else
       htp.formselectoption( c2rec.name, cattributes=>'VALUE="' || c2rec.manufacturer_id|| '"');
     end if;
    end loop;
    htp.formselectclose;
    htp.nl;
    htp.nl;
    htp.formsubmit( 'ACTION', LNG4.AHC_TXT_950 );
    htp.formsubmit( 'ACTION', LNG.CST_BUT_016 );
    htp.formclose;
    htp.p( '</CENTER>' );
    htp.htmlclose;
    return;

  elsif action = 3 -- Progress Workflow
   then

    if c1rec.status_id = 0
     then
      view_workflow_set(surl,workid,LNG4.AHC_TXT_949);
      return;
    /*
    elsif c1rec.status_id < 0
     then
      view_workflow_set(surl,workid,LNG4.AHC_TXT_948);
      return;
    */
    end if;

    open c3(c1rec.status_workflow,c1rec.status_priority);
    fetch c3 into c3rec;
    close c3;
    if c3rec.workflow_type = 'Q'
     then
      pfx := glbx.photo_lf(owner_id);
      glbx.main_title( surl, LNG4.AHC_TXT_943 ,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B17',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
      htp.nl;
      glbx.instruction( LNG4.AHC_TXT_947, pfx );
      glbx.instruction( c3rec.question, pfx );
      htp.p( '<CENTER>' );
      htp.formopen( 'pbk.utility_workflow_ext' );
      htp.formhidden( 'SURL', surl );
      htp.formhidden( 'WORKID', workid );
      htp.formhidden( 'ACTION_STEP', action );
      htp.formhidden( 'SHP', shp );
      htp.formselectopen( 'P1' );
      for c4rec in c4(c1rec.status_id) loop
       htp.formselectoption( c4rec.response );
      end loop;
      htp.formselectclose;
      htp.nl;
      htp.nl;
      htp.formsubmit( 'ACTION', LNG4.AHC_TXT_943 );
      htp.formsubmit( 'ACTION', LNG.CST_BUT_016 );
      htp.formclose;
      htp.p( '</CENTER>' );
      htp.htmlclose;
     else
      lab.run_workflow(surl,shp,null);
      return;
    end if;

  end if;

  view_workflow_set(surl,workid);

exception when others then
 glbx.error_details( 'PBK', 'UTILITY_WORKFLOW', errmsg=>sqlerrm, extdet=>'WORKID:' || workid || ' SHP:' || shp);
end utility_workflow;

procedure utility_workflow_ext( surl in varchar2, workid in integer, shp in integer, action_step in integer, action in varchar2, p1 in varchar2, msg in varchar2 default null )
as

 cursor c1(shp integer, phgid integer) is
  select po.poid,sb.shopping_id,sb.status_mfctr,sb.status_workflow
  from shopping_basket sb,purchase_order po
  where po.poid=sb.poid and sb.shopping_id = shp and po.pid = phgid
 union all
  select po.poid,sb.thread_id,sb.status_mfctr,sb.status_workflow
  from shopping_basket_thread sb,purchase_order po
  where po.poid=sb.poid and sb.thread_id = shp and po.pid = phgid;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.UTILITY_WORKFLOW_EXT', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if action = LNG.CST_BUT_016
   then
    view_workflow_set(surl,workid);
    return;
  end if;

  -- Validate Shopping Id
  open c1(shp,owner_id);
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    close c1;
    htp.p( LNG4.AHC_TXT_944 );
    return;
  end if;
  close c1;

  if action_step = 2
   then
    update shopping_basket set status_mfctr = to_number(p1) where shopping_id = c1rec.shopping_id;
    if sql%NOTFOUND then update shopping_basket_thread set status_mfctr = to_number(p1) where thread_id = c1rec.shopping_id; end if;
    commit;
    view_workflow_set(surl,workid,LNG4.AHC_TXT_946);
    return;

  elsif action_step = 3
   then
    lab.run_workflow(surl,shp,p1);
    return;
  end if;

exception when others then
 glbx.error_details( 'PBK', 'UTILITY_WORKFLOW_EXT', errmsg=>sqlerrm, extdet=>'WORKID:' || workid || ' SHP:' || shp || ' ACTION:' || action || ' P1:' || p1);
end utility_workflow_ext;

procedure view_workflow_details( surl in varchar2, workid in integer, shp in integer, msg in varchar2 default null )
as

 cursor c1(shp integer, phgid integer) is select po.poid,sb.shopping_id from shopping_basket sb,purchase_order po where po.poid=sb.poid and sb.shopping_id = shp and po.pid = phgid;
 cursor c2(shp integer) is
  select /*+ ALL_ROWS */ *
  from audit_workflow_activity awa
  where shopping_id = shp
  order by date_created desc;
cursor c3(mfid integer) is select * from manufacturer where manufacturer_id = mfid;
cursor c4(tp char ) is select * from workflow_option where activity_type = tp;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.VIEW_WORKFLOW_DETAILS', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  open c1(shp,owner_id);
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    close c1;
    htp.p( LNG4.AHC_TXT_944 );
    return;
  end if;
  close c1;
  glbx.main_title( surl, LNG4.AHC_TXT_937 || ' : ' || c1rec.shopping_id || '[' || c1rec.poid || ']' ,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B17',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg );end if;
  htp.p( '<CENTER>' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG2.PBK_TXT_009 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.ORD_TXT_188 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_832 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_833), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.CST_TXT_013 || '1'), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.CST_TXT_013 || '2'), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.CST_TXT_013 || '3'), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.CST_TXT_013 || '4'), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.CST_TXT_013 || '5'), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;
  for c2rec in c2(c1rec.shopping_id) loop
   c3rec.name := '&nbsp;';
   open c3(c2rec.manufacturer_id);
   fetch c3 into c3rec;
   close c3;
   open c4(c2rec.activity_type);
   fetch c4 into c4rec;
   close c4;
   htp.tablerowopen;
    htp.tabledata( c3rec.name, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(c2rec.date_created,LNG.TSMASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( c4rec.option_name, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( c2rec.activity_order, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( nvl(c2rec.extra_value_1,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( nvl(c2rec.extra_value_2,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( nvl(c2rec.extra_value_3,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( nvl(c2rec.extra_value_4,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( nvl(c2rec.extra_value_5,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.anchor( 'pbk.view_workflow_set?surl=' || surl || '&workid=' || workid,LNG4.AHC_TXT_945);
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'VIEW_WORKFLOW_DETAILS', errmsg=>sqlerrm, extdet=>'SHP:' || shp);
end view_workflow_details;

procedure del_workflow_set(surl in varchar2, workid in integer, msg in varchar2 default null )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.DEL_WORKFLOW_SET', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 delete from workflow_query_clause where query_id in (select query_id from workflow_query where status_id in (select status_id from workflow where status_workflow = workid and pid = owner_id));
 delete from workflow_query where status_id in (select status_id from workflow where status_workflow = workid and pid = owner_id);
 delete from workflow_question where status_id in (select status_id from workflow where status_workflow = workid and pid = owner_id);
 delete from workflow where status_workflow = workid and pid = owner_id;
 delete from workflow_set where status_workflow = workid and pid = owner_id;
 commit;
 mng_workflow( surl, LNG4.AHC_TXT_911 );

exception when others then
 glbx.error_details( 'PBK', 'DEL_WORKFLOW_SET', errmsg=>sqlerrm);
end del_workflow_set;

procedure del_workflow_activity(surl in varchar2, actid in integer, p1 in varchar2, msg in varchar2 default null )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.DEL_WORKFLOW_ACTIVITY', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 update workflow_query set workflow_activity_id = NULL where workflow_activity_id = actid;
 update workflow_question set workflow_activity_id = NULL where workflow_activity_id = actid;
 update workflow set goto_workflow = NULL where goto_workflow = actid and pid = owner_id;
 delete from workflow_activity where workflow_activity_id = actid and pid = owner_id;
 delete from workflow_activity_defn where workflow_activity_id = actid and pid = owner_id;
 commit;
 mng_workflow( surl, LNG4.AHC_TXT_910 );

exception when others then
 glbx.error_details( 'PBK', 'DEL_WORKFLOW_ACTIVITY', errmsg=>sqlerrm);
end del_workflow_activity;

procedure mng_workflow_activity(surl in varchar2, actid in integer, p1 in varchar2, msg in varchar2 default null )
as

 cursor c2 is select * from workflow_option order by activity_type;
 cursor c3( phgid integer, actid integer ) is
  select option_responses,option_name,response_1,response_2,response_3,response_4,response_5,lov,lov2,lov3,activity_order,extra_value_1,extra_value_2,extra_value_3,extra_value_4,extra_value_5
  from workflow_activity wa, workflow_option wo
  where pid = phgid and
        workflow_activity_id = actid and
        wo.activity_type = wa.activity_type
  order by activity_order;
 cursor c4( phgid integer, actid integer ) is select * from workflow_activity_defn where pid = phgid and workflow_activity_id = actid;
 cursor c5( phgid integer, actid integer ) is select max(activity_order) mx from workflow_activity where pid = phgid and workflow_activity_id = actid;

 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MNG_WORKFLOW_ACTIVITY', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  open c4(owner_id,actid);
  fetch c4 into c4rec;
  close c4;
  if actid is null
   then
    glbx.main_title( surl, LNG4.AHC_TXT_830 || ' : ' || initcap(p1) , glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P57',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   else
    glbx.main_title( surl, LNG4.AHC_TXT_831 || ' : ' || initcap(c4rec.name), glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P57',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  end if;
  htp.nl;
  if msg is not null then glbx.header_msg(msg); end if;
  htp.p( '<CENTER>' );

  htp.formopen( 'pbk.accept_mng_workflow' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'P1', p1 );
  htp.formhidden( 'ACTID', actid );

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_832), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_833 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_561 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG2.FNM_TXT_016 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   for c3rec in c3(owner_id,actid) loop
   htp.tablerowopen;
    htp.tabledata( htf.bold( c3rec.option_name ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.formhidden( 'P4', null );
    htp.tabledata( htf.formtext( 'P2', 3, 10, c3rec.activity_order ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.formhidden( 'P3', c3rec.activity_order );
    for j in 1..c3rec.option_responses loop
     if j = 1
      then
       -- The LOV replaces the first column
       if c3rec.lov is null
        then
         htp.tabledata( c3rec.response_1 || htf.nl || htf.formtext( 'R1',30,1000,c3rec.extra_value_1 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        else
         htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
         htp.p( c3rec.response_1 || htf.nl );
         glbx.meta_sql( null, null, 'R1', 'T', replace(c3rec.lov,'~PID', to_char(owner_id)), c3rec.extra_value_1 );
         htp.p( '</TD>' );
       end if;
     elsif j = 2
      then
       if c3rec.lov2 is null
        then
         htp.tabledata( c3rec.response_2 || htf.nl || htf.formtext( 'R2',30,1000,c3rec.extra_value_2 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        else
         htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
         htp.p( c3rec.response_2 || htf.nl );
         glbx.meta_sql( null, null, 'R2', 'T', replace(c3rec.lov2,'~PID', to_char(owner_id)), c3rec.extra_value_2 );
       end if;
     elsif j = 3
      then
       if c3rec.lov3 is null
        then
         htp.tabledata( c3rec.response_3 || htf.nl || htf.formtext( 'R3',30,1000,c3rec.extra_value_3 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        else
         htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
         htp.p( c3rec.response_3 || htf.nl );
         glbx.meta_sql( null, null, 'R3', 'T', replace(c3rec.lov3,'~PID', to_char(owner_id)), c3rec.extra_value_3 );
       end if;
     elsif j = 4
      then
       htp.tabledata( c3rec.response_4 || htf.nl || htf.formtext( 'R4',30,1000,c3rec.extra_value_4 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     elsif j = 5
      then
       htp.tabledata( c3rec.response_5 || htf.nl || htf.formtext( 'R5',30,1000,c3rec.extra_value_5 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     end if;
    end loop;
    for j in (c3rec.option_responses + 1)..5 loop
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.formhidden( 'R' || to_char(j), null );
    end loop;
    htp.tabledata( htf.anchor( 'pbk.workflow_activity_delete?surl=' || surl || '&actid=' || actid || '&ord=' || c3rec.activity_order,LNG.SLD_TXT_004 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   end loop;
   open c5(owner_id,actid);
   fetch c5 into c5rec;
   close c5;
   c5rec.mx := nvl(c5rec.mx,0) + 1;
   for j in 1..5 loop
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P4' );
     htp.formselectoption( null, cattributes=>'VALUE="@"');
     for c2rec in c2 loop
      htp.formselectoption( c2rec.option_name, cattributes=>'VALUE="' || c2rec.activity_type || '"');
     end loop;
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext( 'P2', 3, 10, c5rec.mx ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.formhidden( 'P3', null );
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.formhidden( 'R1', null );
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.formhidden( 'R2', null );
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.formhidden( 'R3', null );
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.formhidden( 'R4', null );
     htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.formhidden( 'R5', null );
     htp.tabledata( htf.bold( '&nbsp;' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   end loop;
  htp.tableclose;
  htp.nl;
  htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
  htp.tablerowopen;
  if p1 is null
   then
    htp.tabledata( htf.formsubmit( null, LNG4.AHC_TXT_834 ));
   else
    htp.tabledata( htf.formsubmit( null, LNG4.AHC_TXT_835 ));
  end if;
  htp.formclose;
  htp.formopen( 'pbk.mng_workflow' );
  htp.formhidden( 'SURL', surl );
  htp.tabledata( htf.formsubmit( null, LNG4.AHC_TXT_820 ) );
  htp.formclose;
  htp.tablerowclose;
  htp.tableclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'MNG_WORKFLOW_ACTIVITY', errmsg=>sqlerrm);
end mng_workflow_activity;

procedure workflow_activity_delete(surl in varchar2, actid in integer, ord in integer )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.WORKFLOW_ACTIVITY_DELETE', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  delete from workflow_activity
   where
    pid = owner_id and
    workflow_activity_id = actid and
    activity_order = ord;

  commit;

  mng_workflow_activity(surl,actid,null);

exception when others then
 glbx.error_details( 'PBK', 'WORKFLOW_ACTIVITY_DELETE', errmsg=>sqlerrm,extdet=>'ACTID:' || actid || ' ORD:' || ord);
end workflow_activity_delete;

procedure mng_workflow_state(surl in varchar2, wsid in integer, p1 in varchar2, msg in varchar2 default null )
as

 cursor c3( wsid integer ) is
  select *
  from workflow_state_options
  where work_state = wsid
  order by order_by;
 cursor c4( phgid integer, wsid integer ) is select * from workflow_state where pid = phgid and work_state = wsid;

 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.MNG_WORKFLOW_STATE', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  open c4(owner_id,wsid);
  fetch c4 into c4rec;
  close c4;
  if wsid is null
   then
    glbx.main_title( surl, LNG4.AHC_TXT_836 || ' : ' || initcap(p1) , glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P57',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   else
    glbx.main_title( surl, LNG4.AHC_TXT_837 || ' : ' || initcap(c4rec.name), glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P57',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  end if;
  htp.nl;
  if msg is not null then glbx.header_msg(msg); end if;
  htp.p( '<CENTER>' );

  if wsid <> 0
   then
    htp.formopen( 'pbk.accept_mng_state' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'P1', p1 );
    htp.formhidden( 'WSID', wsid );
  end if;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_838), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_839 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_482 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_429 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG2.FNM_TXT_016 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   for c3rec in c3(wsid) loop
    if wsid = 0
     then
      htp.tablerowopen;
       htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( c3rec.responsibility, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( c3rec.order_option, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( c3rec.order_by, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tablerowclose;
     else
      htp.formhidden( 'SPI', c3rec.status_priority_id );
      htp.tablerowopen;
       htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
       htp.formselectopen( 'P2' );
       if c3rec.option_type = 'P'
        then
         htp.formselectoption( LNG4.AHC_TXT_849, 'SELECTED', cattributes=>'VALUE="P"');
        else
         htp.formselectoption( LNG4.AHC_TXT_849, cattributes=>'VALUE="P"');
       end if;
       if c3rec.option_type = 'O'
        then
         htp.formselectoption( LNG4.AHC_TXT_850, 'SELECTED', cattributes=>'VALUE="O"');
        else
         htp.formselectoption( LNG4.AHC_TXT_850, cattributes=>'VALUE="O"');
       end if;
       if c3rec.option_type = 'R'
        then
         htp.formselectoption( LNG.ORD_TXT_202, 'SELECTED', cattributes=>'VALUE="R"');
        else
         htp.formselectoption( LNG.ORD_TXT_202, cattributes=>'VALUE="R"');
       end if;
       if c3rec.option_type = 'X'
        then
         htp.formselectoption( LNG4.AHC_TXT_852, 'SELECTED', cattributes=>'VALUE="X"');
        else
         htp.formselectoption( LNG4.AHC_TXT_852, cattributes=>'VALUE="X"');
       end if;
       if c3rec.option_type = 'C'
        then
         htp.formselectoption( LNG2.PFM_TXT_139, 'SELECTED', cattributes=>'VALUE="C"');
        else
         htp.formselectoption( LNG2.PFM_TXT_139, cattributes=>'VALUE="C"');
       end if;
       if c3rec.option_type = 'A'
        then
         htp.formselectoption( LNG.ORD_TXT_127, 'SELECTED', cattributes=>'VALUE="A"');
        else
         htp.formselectoption( LNG.ORD_TXT_127, cattributes=>'VALUE="A"');
       end if;
       if c3rec.option_type = 'L'
        then
         htp.formselectoption( LNG.ORD_TXT_207, 'SELECTED', cattributes=>'VALUE="L"');
        else
       htp.formselectoption( LNG.ORD_TXT_207, cattributes=>'VALUE="L"');
       end if;
       if c3rec.option_type = 'W'
        then
         htp.formselectoption( LNG4.AHC_TXT_853, 'SELECTED', cattributes=>'VALUE="W"');
        else
         htp.formselectoption( LNG4.AHC_TXT_853, cattributes=>'VALUE="W"');
       end if;
       htp.formselectclose;
       htp.p( '</TD>' );
       htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
       htp.formselectopen( 'P3' );
       if c3rec.responsibility = 'CUSTOMER'
        then
         htp.formselectoption( 'CUSTOMER', 'SELECTED');
        else
         htp.formselectoption( 'CUSTOMER');
       end if;
       if c3rec.responsibility = 'PHOTOGRAPHER'
        then
         htp.formselectoption( 'PHOTOGRAPHER', 'SELECTED');
        else
       htp.formselectoption( 'PHOTOGRAPHER');
       end if;
       if c3rec.responsibility = 'LAB'
        then
         htp.formselectoption( 'LAB', 'SELECTED');
        else
         htp.formselectoption( 'LAB');
       end if;
       htp.formselectclose;
       htp.p( '</TD>' );
       htp.tabledata( htf.formtext( 'P4', 20, 40, c3rec.order_option ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.formtext( 'P5', 5, 10, c3rec.order_by ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.anchor( 'pbk.del_mng_state?surl=' || surl || '&wsid=' || wsid || '&p1=' || replace(p1,' ','+') || '&spi=' || c3rec.status_priority_id,LNG.SLD_TXT_004), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tablerowclose;
     end if;
     end loop;
     for j in 1..5 loop
      if wsid <> 0
       then
        htp.formhidden( 'SPI', null );
        htp.tablerowopen;
         htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
         htp.formselectopen( 'P2' );
         htp.formselectoption( NULL, 'SELECTED' );
         htp.formselectoption( LNG4.AHC_TXT_849, cattributes=>'VALUE="P"');
         htp.formselectoption( LNG4.AHC_TXT_850, cattributes=>'VALUE="O"');
         htp.formselectoption( LNG.ORD_TXT_202, cattributes=>'VALUE="R"');
         htp.formselectoption( LNG4.AHC_TXT_852, cattributes=>'VALUE="X"');
         htp.formselectoption( LNG2.PFM_TXT_139, cattributes=>'VALUE="C"');
         htp.formselectoption( LNG.ORD_TXT_127, cattributes=>'VALUE="A"');
         htp.formselectoption( LNG.ORD_TXT_207, cattributes=>'VALUE="L"');
         htp.formselectoption( LNG4.AHC_TXT_853, cattributes=>'VALUE="W"');
         htp.formselectclose;
         htp.p( '</TD>' );
         htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
         htp.formselectopen( 'P3' );
         htp.formselectoption( NULL, 'SELECTED' );
         htp.formselectoption( 'CUSTOMER');
         htp.formselectoption( 'PHOTOGRAPHER');
         htp.formselectoption( 'LAB');
         htp.formselectclose;
         htp.p( '</TD>' );
         htp.tabledata( htf.formtext( 'P4', 20, 40 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
         htp.tabledata( htf.formtext( 'P5', 5, 10 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
         htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        htp.tablerowclose;
      end if;
     end loop;
  htp.tableclose;
  htp.nl;
  htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
  htp.tablerowopen;
  if p1 is null
   then
    htp.tabledata( htf.formsubmit( null, LNG4.AHC_TXT_840 ));
   else
    htp.tabledata( htf.formsubmit( null, LNG4.AHC_TXT_841 ));
  end if;
  htp.formclose;
  htp.formopen( 'pbk.mng_workflow' );
  htp.formhidden( 'SURL', surl );
  htp.tabledata( htf.formsubmit( null, LNG4.AHC_TXT_820 ) );
  htp.formclose;
  htp.tablerowclose;
  htp.tableclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'MNG_WORKFLOW_STATE', errmsg=>sqlerrm, extdet=>'WSID:' || wsid);
end mng_workflow_state;

procedure del_mng_state(surl in varchar2, wsid in integer, p1 in varchar2, spi in integer )
as
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.DEL_MNG_STATE', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  delete from workflow_state_options where work_state = wsid and status_priority_id = spi;
  commit;
  mng_workflow_state(surl, wsid, p1, LNG3.ADM_TXT_433 );
exception when others then
 glbx.error_details( 'PBK', 'DEL_MNG_STATE', errmsg=>sqlerrm, extdet=>'WSID:' || wsid);
end del_mng_state;

procedure accept_workflow_task( surl in varchar2, workid in integer, vsts in integer, p1 in varchar2, p2 in varchar2, p3 in GLBX.MYARRAY, p3d in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY )
as

 cursor c2 is select max(status_id) mx from workflow;
 cursor c3(phgid integer, wid integer) is select rowid from workflow_activity where workflow_activity_id = wid and pid = phgid order by activity_order;

 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		integer;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_WORKFLOW_TASK', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if vsts is null
   then
    open c2;
    fetch c2 into c2rec;
    close c2;
    c2rec.mx := nvl(c2rec.mx,0) + 1;

    if p1 = 'Q'
     then
      insert into workflow(pid,status_workflow,status_id,workflow_type,question,status_priority_default ) values
      (owner_id,workid,c2rec.mx,p1,p2,100);
      for j in p3.first..p3.last loop
       if p3(j) is not null
        then
         insert into workflow_question(status_id,response,workflow_activity_id) values
          (c2rec.mx,p3(j),p4(j));
       end if;
      end loop;

    elsif p1 = 'M'
     then
      insert into workflow(pid,status_workflow,status_id,workflow_type,question,status_priority_default ) values
      (owner_id,workid,c2rec.mx,p1,p2,100);
      for j in p4.first..p4.last loop
       begin nmb := nvl(to_number(p3(j)),999); exception when others then nmb := 999; end;
       if p4(j) = '0'
        then
         insert into workflow_query(status_id,query_id,workflow_activity_id,order_by,if_or_else) values (c2rec.mx,null,p5(j),null,'E');
       end if;
      end loop;

    elsif p1 in ('G','I')
     then
      insert into workflow(pid,status_workflow,status_id,workflow_type,goto_workflow,status_priority_default ) values
      (owner_id,workid,c2rec.mx,p1,p4(1),100);
    end if;

   else

    c2rec.mx := vsts;
    if p1 = 'Q'
     then
      update workflow
      set
       question = p2
      where pid = owner_id and
            status_workflow = workid and
            status_id = vsts;
      delete from workflow_question where status_id = c2rec.mx;
      for j in p3.first..p3.last loop
       if p3(j) is not null
        then
         insert into workflow_question(status_id,response,workflow_activity_id,is_default) values
          (c2rec.mx,p3(j),p4(j),p3d(j));
       end if;
      end loop;

    elsif p1 = 'M'
     then
      for j in p4.first..p4.last loop
       begin nmb := nvl(to_number(p3(j)),999); exception when others then nmb := 999; end;
       if p4(j) is not null and p4(j) <> '0'
        then
         update workflow_query
         set
          order_by = nmb,
          workflow_activity_id = p5(j)
         where status_id = c2rec.mx and
               query_id = p4(j);
       elsif p4(j) is null -- Else Clause
        then
         update workflow_query
         set
          workflow_activity_id = p5(j)
         where status_id = c2rec.mx and
               query_id is null;
       elsif p4(j) = '0'
        then
         insert into workflow_query(status_id,query_id,workflow_activity_id,order_by,if_or_else) values (vsts,null,p5(j),null,'E');
       end if;
      end loop;

    elsif p1 in ('G','I')
     then
      update workflow
      set
       goto_workflow = p4(1)
      where pid = owner_id and
            status_workflow = workid and
            status_id = vsts;
    end if;
  end if;

  commit;

  if vsts is null
   then
    mng_workflow_task(surl,workid,c2rec.mx,null,LNG4.AHC_TXT_842 );
   else
    mng_workflow_task(surl,workid,c2rec.mx,null,LNG4.AHC_TXT_843 );
  end if;

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_WORKFLOW_TASK', errmsg=>sqlerrm, extdet=>' P1:' || p1);
end accept_workflow_task;

procedure accept_mng_workflow( surl in varchar2, p1 in varchar2, actid in integer, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, r1 in GLBX.MYARRAY, r2 in GLBX.MYARRAY, r3 in GLBX.MYARRAY, r4 in GLBX.MYARRAY, r5 in GLBX.MYARRAY )
as

 cursor c2 is select max(workflow_activity_id) mx from workflow_activity_defn;
 cursor c7(phgid integer, workid integer) is select rowid from workflow_activity where workflow_activity_id = workid and pid = phgid order by activity_order;

 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		integer;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_MNG_WORKFLOW', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 if p1 is null
  then
   c2rec.mx := actid;
  else
   open c2;
   fetch c2 into c2rec;
   close c2;
   c2rec.mx := nvl(c2rec.mx,0) + 1;
   insert into workflow_activity_defn(pid,workflow_activity_id,name) values (owner_id,c2rec.mx,p1);
 end if;

 for j in p4.first..p4.last loop
  begin nmb := to_number(p2(j)); exception when others then nmb := 0; end;
  if p4(j) is null
   then
    update workflow_activity
    set
     activity_order = 1000000 + nmb,
     extra_value_1 = r1(j),
     extra_value_2 = r2(j),
     extra_value_3 = r3(j),
     extra_value_4 = r4(j),
     extra_value_5 = r5(j)
    where
     workflow_activity_id = c2rec.mx and
     activity_order = p3(j) and
     pid = owner_id;
   else
    if p4(j) <> '@'
     then
      insert into workflow_activity(pid,workflow_activity_id,activity_type,activity_order,extra_value_1,extra_value_2,extra_value_3,extra_value_4,extra_value_5) values
       (owner_id,c2rec.mx,p4(j),nmb,r1(j),r2(j),r3(j),r4(j),r5(j));
    end if;
  end if;
 end loop;


 for c7rec in c7(owner_id,c2rec.mx) loop
  nmb := c7%ROWCOUNT;
  update workflow_activity
   set
    activity_order = nmb
  where rowid = c7rec.rowid;
 end loop;


 commit;
 if p1 is null
  then
   mng_workflow_activity( surl, c2rec.mx, p1=>NULL, msg=>LNG4.AHC_TXT_844 );
  else
   mng_workflow_activity( surl, c2rec.mx, p1=>NULL, msg=>LNG4.AHC_TXT_845 );
 end if;

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_MNG_WORKFLOW', errmsg=>sqlerrm, extdet=>'ACTID:' || actid || ' P1:' || p1);
end accept_mng_workflow;

procedure accept_mng_workflow_set(surl in varchar2, workid in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		integer;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_MNG_WORKFLOW_SET', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  for j in p0.first..p0.last loop
   begin nmb := to_number(p2(j)); exception when others then nmb := NULL; end;
   update workflow
    set
     status_priority_default = nmb,
     manufacturer_id = p1(j)
   where
    pid = owner_id and
    status_workflow = workid and
    status_id = p0(j);
   end loop;
   commit;
   mng_workflow_set( surl, workid, LNG4.AHC_TXT_640 );

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_MNG_WORKFLOW_SET', errmsg=>sqlerrm, extdet=>'WORKID:' || workid );
end accept_mng_workflow_set;

procedure accept_mng_state( surl in varchar2, p1 in varchar2, wsid in integer, spi in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY )
as

 cursor c2 is select max(work_state) mx from workflow_state;
 cursor c3(wsid integer) is select rowid from workflow_state_options where work_state = wsid order by order_by;
 cursor c4 is select max(status_priority_id) mx from workflow_state_options;

 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		integer;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_MNG_STATE', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 if p1 is null
  then
   c2rec.mx := wsid;
  else
   open c2;
   fetch c2 into c2rec;
   close c2;
   c2rec.mx := nvl(c2rec.mx,0) + 1;
   insert into workflow_state(work_state,pid,is_system,name) values (c2rec.mx,owner_id,'F', p1);
 end if;

 for j in spi.first..spi.last loop
  begin nmb := to_number(p5(j)); exception when others then nmb := null; end;
  if spi(j) is not null
   then
    update workflow_state_options
    set
     order_by = nmb,
     option_type = p2(j),
     responsibility = p3(j),
     order_option = nvl(p4(j),order_option)
    where
     work_state = c2rec.mx and
     status_priority_id = spi(j);
   else
    if p2(j) is not null and p3(j) is not null and p4(j) is not null
     then
      open c4;
      fetch c4 into c4rec;
      close c4;
      c4rec.mx := nvl(c4rec.mx,0) + 1;
      insert into workflow_state_options(work_state,status_priority_id,option_type,order_option,responsibility,order_by) values
       (c2rec.mx,c4rec.mx,p2(j),p4(j),p3(j),nmb);
    end if;
  end if;
 end loop;

 for c3rec in c3(c2rec.mx) loop
  nmb := c3%ROWCOUNT;
  update workflow_state_options
   set
    order_by = nmb
  where rowid = c3rec.rowid;
 end loop;

 commit;
 if p1 is null
  then
   mng_workflow_state( surl, c2rec.mx, p1=>NULL, msg=>LNG4.AHC_TXT_847 );
  else
   mng_workflow_state( surl, c2rec.mx, p1=>NULL, msg=>LNG4.AHC_TXT_848 );
 end if;

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_MNG_STATE', errmsg=>sqlerrm, extdet=>'WSID:' || wsid || ' P1:' || p1);
end accept_mng_state;

function prod_type( id in integer, cd in varchar2, ftype in varchar2, incnull in boolean default FALSE)
 return varchar2
as

 cursor c6( vspb integer ) is
  select distinct pk.product_key
  from product_keys pk, phg_price_book_lab pb, manufacturer m
  where pk.man_type = m.man_type and
        m.manufacturer_id = pb.manufacturer_id and
        pb.spb = vspb
  order by pk.product_key;

 -- Note: Deliberately left here so if a Photographer does not choose a manufacturer in their price book, All, BW and Colour will appear as Product Options
 cursor c6a is
  select pk.product_key
  from product_keys pk
  where pk.man_type = 'LAB'
  order by pk.product_key;

 tmp	varchar2(32767);
 tmp2	varchar2(100);

begin
    tmp := NULL;
    tmp2 := NULL;
    if incnull then tmp2 := htf.formselectoption( NULL ); end if;
    for c6rec in c6(id) loop
     if c6rec.product_key = ftype
      then
       tmp := tmp || htf.formselectoption( c6rec.product_key,'SELECTED' );
      else
       tmp := tmp || htf.formselectoption( c6rec.product_key );
     end if;
    end loop;
    if tmp is null
     then

      for c6arec in c6a loop
       if c6arec.product_key = ftype
        then
         tmp := tmp || htf.formselectoption( c6arec.product_key,'SELECTED' );
        else
         tmp := tmp || htf.formselectoption( c6arec.product_key );
       end if;
      end loop;

      if tmp is null
       then
        tmp := htf.formselectopen( cd ) || tmp2 || htf.formselectoption( LNG.ORD_TXT_194 ) || htf.formselectclose; -- Default is ALL
       else
        tmp := htf.formselectopen( cd ) || tmp2 || tmp || htf.formselectclose;
      end if;
     else
      tmp := htf.formselectopen( cd ) || tmp2 || tmp || htf.formselectclose;
    end if;
    return( tmp );
exception
 when others then return( LNG.ORD_TXT_194 );
end prod_type;

procedure product_search( surl in varchar2, id in integer, pbit in integer, msg in varchar2 default null )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 foundrec	boolean;
 searchURL varchar2(1000);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.PRODUCT_SEARCH', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG4.AHC_TXT_825,glbx.backimg(surl,null,pfx.text_back,null,ltype, extra_js=>'onFocus="focusModalWin(searchWindow);" onUnLoad="closeChild(searchWindow);"'),helpid=>'B13',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );

  htp.p('
     <script type="text/javascript">
     <!-- Script in PRODUCT_SEARCH
      // The new window to be opened
      var searchWindow;

      function openSearchWindow(searchURL, newTitle) {
         var sWindowFeatures = "resizable,scrollbars,statusbar";
         searchURL = searchURL + "&P1=" + form2.P1.value + "&P3=" + form2.P3.value +"&P4=" +form2.P4.value + "&P5=" + form2.P5.value + "&P6=" + form2.P6.value + "&P7=" + form2.P7.value;
         searchWindow = window.open(searchURL, newTitle);
         if (searchWindow.opener == null) {
            searchWindow.opener = self;
         }
      }

      function focusModalWin(modalWindow) {
         if ( modalWindow) {
            modalWindow.focus();
         }
      }

      function closeChild(childWindow) {
         if (childWindow) {
            childWindow.close();
         }
      }

     // End Script -->
     </script>
  ');
  searchURL := 'pbk.accept_product_search?surl=' || surl || '&id=' || id || '&pbit=' || pbit;

  htp.p('<FORM NAME="form2">');
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ID', id );
  htp.formhidden( 'PBIT', pbit );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.LAB_TXT_052),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P1', 20, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.LAB_TXT_042),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P3', 20, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.LAB_TXT_053),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P4', 20, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG3.ADM_TXT_876),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P5', 20, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.FNM_TXT_130),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( LNG2.FNM_TXT_131 || ' ' || htf.formtext( 'P6', 10, 20 ) || ' ' || LNG2.FNM_TXT_132 || ' ' || htf.formtext( 'P7', 10, 20 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formclose;
  htp.formsubmit( null, LNG.GLB_TXT_092, cattributes=>'onClick="javascript:openSearchWindow(''' || searchURL || ''', ''AcceptSearch'');"' );
  htp.nl;
  htp.nl;
  htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'PRODUCT_SEARCH',errmsg=>sqlerrm);
end product_search;

procedure accept_product_search( surl in varchar2, id in integer, pbit in integer, p1 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2 )
as


 -- This is a very hard statement to run, but should run fast as most clauses are reduced on running
 cursor c1( phid integer, id integer, p1 varchar2, p3 varchar2, p4 varchar2, p5 varchar2, p6 number, p7 number ) is
  select /*+ ALL_ROWS */ distinct p.product_id,m.name mname,p.name,pb.price,nvl(discount,0) b2c_lab_discount,p.product_type,p.is_discounted, p.manufctr_code, p.xref_mfctr_code
  from product p, manufacturer m, price_book pb, manufacturer_photographer_disc mpd
  where
   m.manufacturer_id = p.manufacturer_id and
   mpd.pid = phid and
   mpd.manufacturer_id = p.manufacturer_id and
   p.product_id = pb.product_id and
   valid_until is null and
   ((p1 is null) or (upper(p.name) like upper(p1) || '%')) and
   ((p3 is null) or (upper(p.manufctr_code) like upper(p3) || '%')) and
   ((p4 is null) or (upper(p.xref_mfctr_code) like upper(p4) || '%')) and
   ((p5 is null) or p.brand_id in
    (select brand_id
     from phg_price_book_lab ppbl, brand b
     where ppbl.spb = id and
           ((ppbl.manufacturer_id = b.manufacturer_id) or (is_public = 'T')) and
	           brand_name like upper(p5) || '%')) and
   pb.price >= nvl(p6,0) and
   pb.price <= nvl(p7,999999) and
   p.manufacturer_id in (select manufacturer_id from phg_price_book_lab where spb = id)
  order by m.name,p.name;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 nmb1		number;
 nmb2		number;
 prc		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_PRODUCT_SEARCH', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, LNG3.ADM_TXT_885,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B13',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.p( '
     <script type="text/javascript">
     <!-- Script in ACCEPT_PRODUCT_SEARCH

     function fillField(pValue) {
        // Copy the value of the chosen produkt into the reference to the Edit box
        window.opener.opener.document.form1.P6.value = pValue;

        // Close the parent window
        window.opener.close();

        // Close this window
        window.close();
     }
     // End Script -->
     </script>
  ');
  htp.nl;
  htp.p( '<CENTER>' );
  htp.bold( LNG4.AHC_TXT_829 );
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   if p1 is not null
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.LAB_TXT_052),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( p1 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
   end if;
   if p3 is not null
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.LAB_TXT_042),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( p3 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
   end if;
   if p4 is not null
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.LAB_TXT_053),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( p4 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
   end if;
   if p5 is not null
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG3.ADM_TXT_876),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold( p5 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
   end if;
   if p6 is not null or p7 is not null
    then
     begin nmb1 := to_number(p6); exception when others then nmb1 := 0; end;
     begin nmb2 := to_number(p7); exception when others then nmb2 := 999999; end;
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG2.FNM_TXT_130),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( LNG2.FNM_TXT_131 || ' ' || htf.bold( nvl(to_char(nmb1),'0') ) || ' ' || LNG2.FNM_TXT_132 || ' ' || htf.bold(to_char(nmb2),'999,999.00'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
   end if;
  htp.tableclose;
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG.LAB_TXT_009 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG.LAB_TXT_052 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG.LAB_TXT_015 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG.PHG_TXT_470 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG.LAB_TXT_042 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG.LAB_TXT_053 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  for c1rec in c1(owner_id,id,p1,p3,p4,p5,nmb1,nmb2) loop
   htp.tablerowopen;
    htp.tabledata( '<A HREF="javascript:fillField(''' || c1rec.product_id || ''');">' || LNG4.AHC_TXT_846 || '</A>',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( c1rec.mname ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( c1rec.name ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    if (nvl(c1rec.is_discounted,'F') = 'T') and (c1rec.b2c_lab_discount > 0)
     then
       prc := to_char(c1rec.price * (1-(c1rec.b2c_lab_discount/100)),LNG.MONEY_FORMAT) || ' Disc ' || c1rec.b2c_lab_discount || '%';
     else
       prc := to_char(c1rec.price,LNG.MONEY_FORMAT);
    end if;
    htp.tabledata( prc,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( c1rec.product_type,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( c1rec.manufctr_code,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( c1rec.xref_mfctr_code,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.nl;
  htp.anchor( 'pbk.product_search?surl=' || surl || '&id=' || id || '&pbit=' || pbit, LNG4.AHC_TXT_851 );
  htp.nl;
  htp.nl;
  htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_PRODUCT_SEARCH',errmsg=>sqlerrm);
end accept_product_search;

procedure add_mfctr( surl in varchar2, id in integer, msg in varchar2 default null )
as

 cursor c3(phgid integer, id integer) is
  select manufacturer_id, name, man_type, pbook_name
  from
  (
  select manufacturer_id, name, man_type, public_book pbook_name
  from manufacturer
  where price_book_public = 'T' and public_book is not null
   union
  select m.manufacturer_id, name, man_type, product_type pbook_name
  from manufacturer_photographer_disc mpd, manufacturer m
  where m.manufacturer_id = mpd.manufacturer_id and
        mpd.pid = phgid and
        mpd.private_price_book = 'T'
  )
  where (manufacturer_id,pbook_name) not in
   (select manufacturer_id,price_book from phg_price_book_lab where spb = id and manufacturer_id is not null)
  order by name;

 cursor c4(phgid integer) is select theme_data from photographer ph, theme_types tt where ph.theme_type = tt.theme_type and ph.pid = phgid;

 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 foundrec	boolean;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ADD_MFCTR', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  open c4(owner_id);
  fetch c4 into c4rec;
  close c4;
  glbx.main_title( surl, LNG4.AHC_TXT_871,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B14',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg );end if;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.formopen( 'pbk.accept_add_mfctr' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ID', id );
  htp.formhidden( 'P2', null );
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.PBK_TXT_009),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    if substr(c4rec.theme_data,194,1) = 'T'
     then
      htp.formselectopen( 'P2', null, 5, cattributes=>'MULTIPLE' );
     else
      htp.formselectopen( 'P2' );
    end if;
    htp.formselectoption( NULL );
    foundrec := FALSE;
    for c3rec in c3(owner_id,id) loop
     foundrec := TRUE;
     htp.formselectoption(c3rec.name || '(' || c3rec.pbook_name || ')', cattributes=>'VALUE="[' || c3rec.manufacturer_id || ']' || c3rec.pbook_name  || '"');
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  if foundrec
   then
    htp.formsubmit( null, LNG4.AHC_TXT_379 );
   else
    htp.bold( LNG4.AHC_TXT_873 );
  end if;
  htp.formclose;
  htp.nl;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'ADD_MFCTR',errmsg=>sqlerrm,extdet=>'ID:' || id);
end add_mfctr;

procedure del_mfctr( surl in varchar2, id in integer, msg in varchar2 default null )
as

 cursor c3(phgid integer, id integer) is
  select m.manufacturer_id, name, man_type, price_book pbook_name
  from phg_price_book_lab ppbl, manufacturer m
  where ppbl.spb = id and
        m.manufacturer_id = ppbl.manufacturer_id and
        (ppbl.manufacturer_id,ppbl.spb,ppbl.price_book) not in
         (select distinct ppbl2.manufacturer_id,ppbl2.spb,ppbl2.price_book
          from phg_price_book_lab ppbl2, phg_price_item ppit, product p
          where ppit.spb = ppbl2.spb and ppit.spb = id and ppit.lab_id = p.product_id and ppbl2.manufacturer_id = ppit.manufacturer_id);

 cursor c4(phgid integer) is select theme_data from photographer ph, theme_types tt where ph.theme_type = tt.theme_type and ph.pid = phgid;

 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 foundrec	boolean;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ADD_MFCTR', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  open c4(owner_id);
  fetch c4 into c4rec;
  close c4;
  glbx.main_title( surl, LNG4.AHC_TXT_872,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B15',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg );end if;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.formopen( 'pbk.accept_del_mfctr' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ID', id );
  htp.formhidden( 'P2', null );
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.PBK_TXT_009),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    if substr(c4rec.theme_data,194,1) = 'T'
     then
      htp.formselectopen( 'P2', null, 5, cattributes=>'MULTIPLE' );
     else
      htp.formselectopen( 'P2' );
    end if;
    htp.formselectoption( NULL );
    foundrec := FALSE;
    for c3rec in c3(owner_id,id) loop
     foundrec := TRUE;
     htp.formselectoption(c3rec.name || '(' || c3rec.pbook_name || ')', cattributes=>'VALUE="[' || c3rec.manufacturer_id || ']' || c3rec.pbook_name  || '"');
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  if foundrec
   then
    htp.formsubmit( null, LNG.SLD_TXT_004 );
   else
    htp.bold( LNG4.AHC_TXT_874 );
  end if;
  htp.formclose;
  htp.nl;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'DEL_MFCTR',errmsg=>sqlerrm,extdet=>'ID:' || id);
end del_mfctr;

procedure accept_add_mfctr( surl in varchar2, id in varchar2, p2 in GLBX.MYARRAY )
as

 cursor c1(phgid integer, id integer, manid integer, pbook varchar2) is
  select 'x' exst
  from
  (
  select manufacturer_id, name, man_type, public_book pbook_name
  from manufacturer
  where price_book_public = 'T' and public_book is not null
   union
  select m.manufacturer_id, name, man_type, product_type pbook_name
  from manufacturer_photographer_disc mpd, manufacturer m
  where m.manufacturer_id = mpd.manufacturer_id and
        mpd.pid = phgid and
        mpd.private_price_book = 'T'
  )
  where (manufacturer_id,pbook_name) not in
   (select manufacturer_id,price_book from phg_price_book_lab where spb = id and manufacturer_id is not null) and
  manufacturer_id = manid and
  nvl(pbook,'|') = nvl(pbook_name,'|');

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 ctr		integer;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_ADD_MFCTR', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  ctr := 0;
  for j in p2.first..p2.last loop
   if p2(j) is not null
    then
     open c1(owner_id,id,substr(p2(j),2,instr(p2(j),']')-2),substr(p2(j),instr(p2(j),']')+1));
     fetch c1 into c1rec;
     if c1%FOUND
      then
       close c1;
       ctr := ctr + 1;
       insert into phg_price_book_lab(spb,manufacturer_id,price_book) values
        (id,substr(p2(j),2,instr(p2(j),']')-2),substr(p2(j),instr(p2(j),']')+1));
      else
       close c1;
     end if;
   end if;
  end loop;
  commit;
  pbk.main(surl, ctr || ' ' || LNG4.AHC_TXT_875 );

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_ADD_MFCTR', errmsg=>sqlerrm, extdet=>'ID:' || id);
end accept_add_mfctr;

procedure accept_del_mfctr( surl in varchar2, id in varchar2, p2 in GLBX.MYARRAY )
as

 cursor c1(phgid integer, id integer, manid integer, pbook varchar2) is
  select 'x' exst
  from
  (
  select m.manufacturer_id, name, man_type, price_book pbook_name, spb
  from phg_price_book_lab ppbl, manufacturer m
  where ppbl.spb = id and
        m.manufacturer_id = ppbl.manufacturer_id and
        (ppbl.manufacturer_id,ppbl.spb,ppbl.price_book) not in
         (select distinct ppbl2.manufacturer_id,ppbl2.spb,ppbl2.price_book
          from phg_price_book_lab ppbl2, phg_price_item ppit, product p
          where ppit.spb = ppbl2.spb and ppit.spb = id and ppit.lab_id = p.product_id)
  )
  where
   spb = id and
   manufacturer_id = manid and
   nvl(pbook,'|') = nvl(pbook_name,'|');

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 ctr		integer;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_DEL_MFCTR', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  ctr := 0;
  for j in p2.first..p2.last loop
   if p2(j) is not null
    then
     open c1(owner_id,id,substr(p2(j),2,instr(p2(j),']')-2),substr(p2(j),instr(p2(j),']')+1));
     fetch c1 into c1rec;
     if c1%FOUND
      then
       close c1;
       ctr := ctr + 1;
       delete from phg_price_book_lab
        where
         spb = id and
         manufacturer_id = substr(p2(j),2,instr(p2(j),']')-2) and
         price_book = substr(p2(j),instr(p2(j),']')+1);
      else
       close c1;
     end if;
   end if;
  end loop;
  commit;
  pbk.main(surl, ctr || ' ' || LNG4.AHC_TXT_876 );

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_DEL_MFCTR', errmsg=>sqlerrm, extdet=>'ID:' || id);
end accept_del_mfctr;

procedure download_objects( surl in varchar2, ppm in integer, p1 in varchar2 default null, p2 in varchar2 default null, msg in varchar2 default null )
as

 cursor c1(ppm integer, phgid integer) is select * from phg_price_object_defn where ppm_id = ppm and pid = phgid;
 cursor c2(ppm integer) is select * from phg_price_object where ppm_id = ppm order by ppm_id;
 cursor c3(phgid integer) is select warranty_id,warranty_name from warranty where pid = phgid;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.DOWNLOAD_OBJECTS', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  pfx := glbx.photo_lf(owner_id);
  open c1(ppm,owner_id);
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    c1rec.name := p1;
    c1rec.multiple_type := p2;
  end if;
  close c1;
  glbx.main_title( surl, LNG4.AHC_TXT_921 || ':' || c1rec.name,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'B16',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg );end if;
  if c1rec.multiple_type = 'L'
    then
     htp.bold(LNG4.AHC_TXT_914); htp.nl;
   elsif c1rec.multiple_type = 'T'
    then
     htp.bold(LNG4.AHC_TXT_915); htp.nl;
   elsif c1rec.multiple_type = 'A'
    then
     htp.bold(LNG4.AHC_TXT_916); htp.nl;
   elsif c1rec.multiple_type = 'X'
    then
     htp.bold('Exclusivity'); htp.nl;
  end if;
  htp.formopen( 'pbk.accept_download_objects' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'PPM', ppm);
  htp.formhidden( 'P1', p1);
  htp.formhidden( 'P2', p2);
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
   if c1rec.multiple_type = 'L'
    then
     htp.tabledata( htf.bold(LNG.PHG_TXT_345),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG4.AHC_TXT_922),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG.LAB_TXT_015),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG4.AHC_TXT_925),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   elsif c1rec.multiple_type = 'T'
    then
     htp.tabledata( htf.bold(LNG.PHG_TXT_345),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG4.AHC_TXT_923),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG4.AHC_TXT_926),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG4.AHC_TXT_955),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG.LAB_TXT_015),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG4.AHC_TXT_925),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   elsif c1rec.multiple_type = 'A'
    then
     htp.tabledata( htf.bold(LNG.PHG_TXT_345),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG4.AHC_TXT_924),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG.LAB_TXT_015),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG4.AHC_TXT_925),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   elsif c1rec.multiple_type = 'X'
    then
     htp.tabledata( htf.bold(LNG.PHG_TXT_345),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold('Exclusivity Details'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG.LAB_TXT_015),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG4.AHC_TXT_925),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   end if;
   htp.tablerowclose;
   for c2rec in c2(c1rec.ppm_id) loop
    htp.tablerowopen;
    htp.tabledata( htf.formtext( 'R1', 20, 100, c2rec.title ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.formtext( 'R2', 20, 100, c2rec.value_a ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    if c1rec.multiple_type = 'T'
     then
       htp.tabledata( htf.formtext( 'R3', 20, 100, c2rec.value_b ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
       htp.tabledata( htf.formtext( 'R6', 20, 100, c2rec.value_c ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
     else
      htp.formhidden( 'R3', c2rec.value_b );
      htp.formhidden( 'R6', c2rec.value_c );
    end if;
    htp.tabledata( htf.formtext( 'R4', 20, 100, to_char(c2rec.price,LNG.MONEY_FORMAT) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">');
    htp.formselectopen( 'R5' );
    htp.formselectoption( NULL );
    for c3rec in c3(owner_id) loop
     if c3rec.warranty_id = c2rec.warranty_id
      then
       htp.formselectoption( c3rec.warranty_name,'SELECTED',cattributes=>'VALUE="' || c3rec.warranty_id || '"' );
      else
       htp.formselectoption( c3rec.warranty_name,cattributes=>'VALUE="' || c3rec.warranty_id || '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.tablerowclose;
   end loop;
   for j in 1..5 loop
    htp.tablerowopen;
    htp.tabledata( htf.formtext( 'R1', 20, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.formtext( 'R2', 20, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    if c1rec.multiple_type = 'T'
     then
       htp.tabledata( htf.formtext( 'R3', 20, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
       htp.tabledata( htf.formtext( 'R6', 20, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
     else
      htp.formhidden( 'R3', NULL );
      htp.formhidden( 'R6', NULL );
    end if;
    htp.tabledata( htf.formtext( 'R4', 20, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">');
    htp.formselectopen( 'R5' );
    htp.formselectoption( NULL );
    for c3rec in c3(owner_id) loop
     htp.formselectoption( c3rec.warranty_name,cattributes=>'VALUE="' || c3rec.warranty_id || '"' );
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
   end loop;
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( 'ACTION', LNG4.AHC_TXT_920 );
  htp.formsubmit( 'ACTION', LNG4.AHC_TXT_919 );
  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'DOWNLOAD_OBJECTS', errmsg=>sqlerrm, extdet=>'PPM:' || ppm);
end download_objects;

procedure accept_download_objects( surl in varchar2, ppm in integer, p1 in varchar2 default null, p2 in varchar2 default null, action in varchar2,
                                   r1 in GLBX.MYARRAY, r2 in GLBX.MYARRAY, r3 in GLBX.MYARRAY, r4 in GLBX.MYARRAY, r5 in GLBX.MYARRAY, r6 in GLBX.MYARRAY )
as

 cursor c1(ppm integer, phgid integer) is select * from phg_price_object_defn where ppm_id = ppm and pid = phgid;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 new_ppm	integer;
 nmb		number;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_DOWNLOAD_OBJECTS', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if action = LNG4.AHC_TXT_919
   then
    pbk.main( surl );
    return;
  end if;

  if ppm is null
   then
    select s_phg_price_object.nextval into new_ppm from dual;
    insert into phg_price_object_defn(pid,name,ppm_id,multiple_type) values (owner_id,nvl(p1,'No Name'),new_ppm,p2);
    open c1(new_ppm,owner_id);
    fetch c1 into c1rec;
    close c1;
   else
    open c1(ppm,owner_id);
    fetch c1 into c1rec;
    close c1;
  end if;

  delete from phg_price_object where ppm_id = c1rec.ppm_id;
  for j in r1.first..r1.last loop
   if r1(j) is not null
    then
     nmb := glbx.conv_nmb( r4(j) );
     insert into phg_price_object(ppm_id,title,value_a,value_b,value_c,price,warranty_id) values
      (c1rec.ppm_id,r1(j),r2(j),r3(j),r6(j),nmb,r5(j));
   end if;
  end loop;
  commit;

  download_objects( surl, c1rec.ppm_id, null, null, LNG4.AHC_TXT_918 );
exception when others then
 glbx.error_details( 'PBK', 'DOWNLOAD_OBJECTS', errmsg=>sqlerrm, extdet=>'PPM:' || ppm);
end accept_download_objects;

procedure usemap( surl in varchar2, v_umo in integer, acid in integer, msg in varchar2 default null  )
as

 cursor c2(v_umo integer) is select * from image_map where umo_id = v_umo;
 cursor c3(v_umo integer, owner_id integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid and aid in (select aid from customer_account where aid = acid and pid = owner_id);

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 usemap		varchar2(100);
 oth		integer;
 imgtot		integer;
 dspht		integer;
 adj		integer;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.USEMAP', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  pfx := glbx.get_thm( c1rec.theme_name );
  glbx.main_title( surl, LNG4.AHC_TXT_967, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P61',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;
  open c3(v_umo, owner_id, acid );
  fetch c3 into c3rec;
  if c3%NOTFOUND then close c3; htp.bold( 'Illegal Access' ); return; end if;
  close c3;
  -- Display the Image with the Map

 if glbx.userpref( owner_id, acid, 'DISPLAY_ORIGINAL' ) = LNG.PHG_TXT_045
  then
   dspht := c3rec.photo_master.width;
   oth := c3rec.photo_master.height;
   adj := 1;
  else
   dspht := trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) /1.3);
   oth := (trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) /1.3) / c3rec.photo_master.width) * c3rec.photo_master.height;
   adj := trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) /1.3) / c3rec.photo_master.width;
 end if;

 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 bordercolordark="#' || pfx.tnail_border_colour || '" bordercolorlight="#' || pfx.tnail_border_colour_l || '" border=' || to_char(nvl(pfx.tnail_border,0)) );
 htp.tablerowopen;
 usemap := glbx.embed_image_map( surl, v_umo, adj, acid );
 htp.tabledata(
        '<IMG BORDER=0 WIDTH=' || to_char( dspht )|| ' HEIGHT=' || to_char( oth ) || usemap || ' SRC="' ||
        'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || v_umo || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=VERSION&parm2=' || to_char(c3rec.version) || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' ||
        '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || to_char(acid) || '">',
        cattributes=>'align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(dspht + nvl(pfx.tnail_width,0)) || '" height="' || to_char(oth + nvl(pfx.tnail_width,0)) || '"' );
 htp.tablerowclose;
 htp.tableclose;

  htp.formopen( 'pbk.accept_usemap' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'V_UMO', v_umo);
  htp.formhidden( 'ACID', acid);
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_962),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG4.AHC_TXT_963),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG4.AHC_TXT_211),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG4.AHC_TXT_964),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG4.AHC_TXT_829),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG4.AHC_TXT_966),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tablerowclose;
   for c2rec in c2( c3rec.umo_id ) loop
    htp.tablerowopen;
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">');
     htp.formselectopen( 'P1' );
      htp.formselectoption( NULL );
      if c2rec.shape = 'RECT' then htp.formselectoption( 'RECT', 'SELECTED' ); else htp.formselectoption( 'RECT' ); end if;
      if c2rec.shape = 'CIRCLE' then htp.formselectoption( 'CIRCLE', 'SELECTED' ); else htp.formselectoption( 'CIRCLE' ); end if;
      if c2rec.shape = 'POLY' then htp.formselectoption( 'POLY', 'SELECTED' ); else htp.formselectoption( 'POLY' ); end if;
      if c2rec.shape = 'DEFAULT' then htp.formselectoption( 'DEFAULT', 'SELECTED' ); else htp.formselectoption( 'DEFAULT' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext( 'P2', 20, 1000, c2rec.coords ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.formtext( 'P3', 30, 4000, c2rec.alt_tag ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">');
     htp.formselectopen( 'P4' );
     if c2rec.search_type = 'N' then htp.formselectoption( LNG.SLD_TXT_021, 'SELECTED',cattributes=>'VALUE="N"' ); else htp.formselectoption( LNG.SLD_TXT_021,cattributes=>'VALUE="N"' ); end if;
     if c2rec.search_type = 'S' then htp.formselectoption( LNG4.AHC_TXT_965, 'SELECTED',cattributes=>'VALUE="S"' ); else htp.formselectoption( LNG4.AHC_TXT_965,cattributes=>'VALUE="S"' ); end if;
     if c2rec.search_type = 'A' then htp.formselectoption( LNG4.AHC_TXT_966, 'SELECTED',cattributes=>'VALUE="A"' ); else htp.formselectoption( LNG4.AHC_TXT_966,cattributes=>'VALUE="A"' ); end if;
     if c2rec.search_type = 'C' then htp.formselectoption( LNG.CST_TXT_042, 'SELECTED',cattributes=>'VALUE="C"' ); else htp.formselectoption( LNG.CST_TXT_042,cattributes=>'VALUE="C"' ); end if;
     if c2rec.search_type = 'H' then htp.formselectoption( LNG4.AHC_TXT_212, 'SELECTED',cattributes=>'VALUE="H"' ); else htp.formselectoption( LNG4.AHC_TXT_212,cattributes=>'VALUE="H"' ); end if;
     if c2rec.search_type = 'M' then htp.formselectoption( LNG.PHG_TXT_301, 'SELECTED',cattributes=>'VALUE="M"' ); else htp.formselectoption( LNG.PHG_TXT_301,cattributes=>'VALUE="M"' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext( 'P6', 20, 1000, c2rec.search_terms ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.formtext( 'P5', 20, 1000, c2rec.search_api_call ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
   htp.tablerowclose;
   end loop;
   for j in 1..5 loop
    htp.tablerowopen;
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">');
     htp.formselectopen( 'P1' );
      htp.formselectoption( NULL );
      htp.formselectoption( 'RECT' );
      htp.formselectoption( 'CIRCLE' );
      htp.formselectoption( 'POLY' );
      htp.formselectoption( 'DEFAULT' );
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext( 'P2', 20, 1000 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.formtext( 'P3', 30, 4000 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">');
     htp.formselectopen( 'P4' );
     htp.formselectoption( LNG.SLD_TXT_021,cattributes=>'VALUE="N"' );
     htp.formselectoption( LNG4.AHC_TXT_965,cattributes=>'VALUE="S"' );
     htp.formselectoption( LNG4.AHC_TXT_966,cattributes=>'VALUE="A"' );
     htp.formselectoption( LNG.CST_TXT_042,cattributes=>'VALUE="C"' );
     htp.formselectoption( LNG4.AHC_TXT_212,cattributes=>'VALUE="H"' );
     htp.formselectoption( LNG.PHG_TXT_301,cattributes=>'VALUE="M"' );
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext( 'P6', 20, 1000 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.formtext( 'P5', 20, 1000 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
   htp.tablerowclose;
   end loop;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( NULL, LNG4.AHC_TXT_968 );
  htp.formclose;
  htp.nl;
  htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'USEMAP', errmsg=>sqlerrm, extdet=>'ACID:' || acid || ' V_UMO:' || v_umo);
end usemap;

procedure accept_usemap( surl in varchar2, v_umo in integer, acid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY  )
as

 cursor c3(v_umo integer, owner_id integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid and aid in (select aid from customer_account where aid = acid and pid = owner_id);

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_USEMAP', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  open c3(v_umo, owner_id, acid );
  fetch c3 into c3rec;
  if c3%NOTFOUND then close c3; htp.bold( 'Illegal Access' ); return; end if;
  close c3;

  delete from image_map where umo_id = c3rec.umo_id;
  for j in p1.first..p1.last loop
   if p1(j) is not null
    then
     insert into image_map(umo_id,shape,coords,alt_tag,search_type,search_api_call,search_terms) values
      (c3rec.umo_id,p1(j),replace(p2(j),'"',''),p3(j),p4(j),p5(j),p6(j));
   end if;
  end loop;
  commit;

  usemap( surl, v_umo, acid, LNG4.AHC_TXT_918 );

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_USEMAP', errmsg=>sqlerrm, extdet=>'ACID:' || acid || ' V_UMO:' || v_umo);
end accept_usemap;

procedure homenews( surl in varchar2, acid in integer, hnw in integer, msg in varchar2 default null )
as

 cursor c2(acid integer, hnw integer) is select * from home_news where aid=acid and hnews = hnw;
 cursor c3(phgid integer) is select * from photographer where pid = phgid;
 cursor c4 is select * from colours order by clr_name;
 cursor c5 is select font_name from fonts order by font_name;
 cursor c6( snm varchar2, acid integer, phgid integer ) is
   select distinct usc.umo_scene_id,usc.title,usc.parent_scene,usc.order_by
   from umo um, umo_scene usc
   where category = snm and
         um.umo_scene_id = usc.umo_scene_id and
         um.aid = acid
   order by usc.order_by;
 cursor c7(acid integer) is select um.umo_id,um.extras.film_name film_name from umo um where aid = acid and umo_type = 'PHOTO' order by um.extras.film_name;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 foundrec	boolean;
 ext_umos	GLBX.MYARRAY;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.HOMENEWS', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
  pfx := glbx.get_thm( c1rec.theme_name );
  theme_rec := get_theme_types( c1rec.aid, null );
  glbx.main_title( surl, LNG5.EXT_TXT_014, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P65',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  open c2(acid,hnw);
  fetch c2 into c2rec;
  close c2;
  open c3(owner_id);
  fetch c3 into c3rec;
  close c3;
  if msg is not null then glbx.header_msg( msg ); end if;
  htp.formopen( 'pbk.accept_homenews' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );
  htp.formhidden( 'HNW', hnw );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.PHG_TXT_345 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P1', 60, 100, c2rec.title ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.SLD_TXT_025 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P20' );
     for j in 0..5 loop
      if j = nvl(c2rec.frame_news,0)
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
    htp.tabledata( htf.bold( LNG5.EXT_TXT_064 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P2' );
     for c4rec in c4 loop
      if c4rec.clr_hex = c2rec.title_highlight
       then
        htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       else
        htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
      end if;
     end loop;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_065 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P3' );
     for c4rec in c4 loop
      if c4rec.clr_hex = c2rec.title_font_colour
       then
        htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       else
        htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
      end if;
     end loop;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_066 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P4' );
     for j in -5..5 loop
      if j = nvl(c2rec.title_inc_font,0)
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
    htp.tabledata( htf.bold( LNG5.EXT_TXT_067 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    if nvl(c2rec.display_column,1) = 1
     then
      htp.tabledata( htf.formradio( 'P5', '1', 'CHECKED' ) || ' ' || '1' || ' ' || htf.formradio( 'P5', '2' ) || ' ' || '2' || ' ' || htf.formradio( 'P5', '3' ) || ' ' || '3', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     elsif nvl(c2rec.display_column,1) = 2
      then
       htp.tabledata( htf.formradio( 'P5', '1' ) || ' ' || '1' || ' ' || htf.formradio( 'P5', '2', 'CHECKED' ) || ' ' || '2' || ' ' || htf.formradio( 'P5', '3' ) || ' ' || '3', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      htp.tabledata( htf.formradio( 'P5', '1' ) || ' ' || '1' || ' ' || htf.formradio( 'P5', '2' ) || ' ' || '2' || ' ' || htf.formradio( 'P5', '3', 'CHECKED' ) || ' ' || '3', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG3.ADM_TXT_429 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P19' );
     for j in 1..30 loop
      if j = c2rec.order_by
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
    htp.tabledata( htf.bold( LNG5.EXT_TXT_068 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P6' );
     for c5rec in c5 loop
      if c5rec.font_name = c2rec.font
       then
        htp.formselectoption( c5rec.font_name, 'SELECTED' );
       else
        htp.formselectoption( c5rec.font_name );
      end if;
     end loop;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_069 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P7' );
     for c4rec in c4 loop
      if c4rec.clr_hex = c2rec.font_colour
       then
        htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       else
        htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
      end if;
     end loop;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_070 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P8' );
     for j in -5..5 loop
      if j = nvl(c2rec.font_inc_font,0)
       then
        htp.formselectoption( to_char(j), 'SELECTED' );
       else
        htp.formselectoption( to_char(j) );
      end if;
     end loop;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;

   -- Embed Object
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_229 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    if nvl(c2rec.news_object,'N') = 'N'
     then
      htp.formradio( 'P21', 'N', 'CHECKED' );
     else
      htp.formradio( 'P21', 'N' );
    end if;
    htp.p( ' ' || LNG.SLD_TXT_021 ); htp.nl;
    if nvl(c2rec.news_object,'N') = 'S'
     then
      htp.formradio( 'P21', 'S', 'CHECKED' );
     else
      htp.formradio( 'P21', 'S' );
    end if;
    htp.p( ' ' || LNG.GLB_TXT_092 ); htp.nl;
    if nvl(c2rec.news_object,'N') = 'C'
     then
      htp.formradio( 'P21', 'C', 'CHECKED' );
     else
      htp.formradio( 'P21', 'C' );
    end if;
    htp.p( ' ' || LNG.PHG_TXT_437 ); htp.nl;
    if nvl(c2rec.news_object,'N') = 'P'
     then
      htp.formradio( 'P21', 'P', 'CHECKED' );
     else
      htp.formradio( 'P21', 'P' );
    end if;
    htp.p( ' ' || LNG5.EXT_TXT_231 ); htp.nl;
    if nvl(c2rec.news_object,'N') = 'A'
     then
      htp.formradio( 'P21', 'A', 'CHECKED' );
     else
      htp.formradio( 'P21', 'A' );
    end if;
    htp.p( ' ' || LNG4.AHC_TXT_202 ); htp.nl;
    if nvl(c2rec.news_object,'N') = 'T'
     then
      htp.formradio( 'P21', 'T', 'CHECKED' );
     else
      htp.formradio( 'P21', 'T' );
    end if;
    htp.p( ' ' || LNG4.AHC_TXT_080 ); htp.nl;
   htp.tablerowclose;

   -- News Text
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_071 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtextareaopen( 'P9', 5, 60, cattributes=>'WRAP="VIRTUAL"' ) || c2rec.news || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_072 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    if nvl(c2rec.reference_link_type,'N') = 'N'
     then
      htp.formradio( 'P10', 'N', 'CHECKED' );
     else
      htp.formradio( 'P10', 'N' );
    end if;
    htp.p( ' ' || LNG.SLD_TXT_021 ); htp.nl;
    if c2rec.reference_link_type = 'S'
     then
      htp.formradio( 'P10', 'S', 'CHECKED' );
     else
      htp.formradio( 'P10', 'S' );
    end if;
    htp.p( ' ' || LNG.GLB_TXT_092 ); htp.nl;
    if c2rec.reference_link_type = 'H'
     then
      htp.formradio( 'P10', 'H', 'CHECKED' );
     else
      htp.formradio( 'P10', 'H' );
    end if;
    htp.p( ' ' || LNG4.AHC_TXT_212 ); htp.nl;
    if c2rec.reference_link_type = 'M'
     then
      htp.formradio( 'P10', 'M', 'CHECKED' );
     else
      htp.formradio( 'P10', 'M' );
    end if;
    htp.p( ' ' || LNG.PHG_TXT_301 ); htp.nl;
    if c2rec.reference_link_type = 'C'
     then
      htp.formradio( 'P10', 'C', 'CHECKED' );
     else
      htp.formradio( 'P10', 'C' );
    end if;
    -- xxx language file
    htp.p( ' ' || 'Category' ); htp.nl;
    if c3rec.external_api_access = 'T'
     then
      if c2rec.reference_link_type = 'A'
       then
        htp.formradio( 'P10', 'A', 'CHECKED' );
       else
        htp.formradio( 'P10', 'A' );
      end if;
    end if;
    htp.p( ' ' || LNG4.AHC_TXT_966 ); htp.nl;
    htp.p( '</TD>' );
   htp.tablerowclose;
   -- Reference Link to Display Text
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_077 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P16', 60, 1000, c2rec.text_display ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_073 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P11', 60, 1000, c2rec.reference_link ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_074 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      ext_umos := glbx.extract_umos( c2rec.reference_search_cat );
      htp.formhidden( 'P12', null );
      htp.formselectopen('P12', null, 5, cattributes=>'MULTIPLE' );
      htp.formselectoption( NULL );
      for c6rec in c6(c1rec.scene_name, acid, owner_id ) loop
       foundrec := FALSE;
       for j in ext_umos.first..ext_umos.last loop
        if ext_umos(j) = c6rec.umo_scene_id then foundrec := TRUE; exit; end if;
       end loop;
       if foundrec
        then
         htp.formselectoption( lpad('.', indnt(c6rec.parent_scene),'.') || c6rec.title, 'SELECTED', cattributes=>'VALUE="' || c6rec.umo_scene_id || '"' );
        else
         htp.formselectoption( lpad('.', indnt(c6rec.parent_scene),'.') || c6rec.title, cattributes=>'VALUE="' || c6rec.umo_scene_id || '"' );
       end if;
      end loop;
      htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;

   -- Search Age
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_075 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
       htp.formselectopen( 'P13' );
       htp.formselectoption( NULL );
        if c2rec.reference_search_age = '1D' then htp.formselectoption( '1 '   || LNG3.ADM_TXT_668, 'SELECTED', cattributes=>'VALUE="1D"' ); else htp.formselectoption( '1 '   || LNG3.ADM_TXT_668, cattributes=>'VALUE="1D"' ); end if;
        if c2rec.reference_search_age = '2D' then htp.formselectoption( '2 '   || LNG3.ADM_TXT_668, 'SELECTED', cattributes=>'VALUE="2D"' ); else htp.formselectoption( '2 '   || LNG3.ADM_TXT_668, cattributes=>'VALUE="2D"' ); end if;
        if c2rec.reference_search_age = '3D' then htp.formselectoption( '3 '   || LNG3.ADM_TXT_668, 'SELECTED', cattributes=>'VALUE="3D"' ); else htp.formselectoption( '3 '   || LNG3.ADM_TXT_668, cattributes=>'VALUE="3D"' ); end if;
        if c2rec.reference_search_age = '4D' then htp.formselectoption( '4 '   || LNG3.ADM_TXT_668, 'SELECTED', cattributes=>'VALUE="4D"' ); else htp.formselectoption( '4 '   || LNG3.ADM_TXT_668, cattributes=>'VALUE="4D"' ); end if;
        if c2rec.reference_search_age = '5D' then htp.formselectoption( '5 '   || LNG3.ADM_TXT_668, 'SELECTED', cattributes=>'VALUE="5D"' ); else htp.formselectoption( '5 '   || LNG3.ADM_TXT_668, cattributes=>'VALUE="5D"' ); end if;
        if c2rec.reference_search_age = '6D' then htp.formselectoption( '6 '   || LNG3.ADM_TXT_668, 'SELECTED', cattributes=>'VALUE="6D"' ); else htp.formselectoption( '6 '   || LNG3.ADM_TXT_668, cattributes=>'VALUE="6D"' ); end if;
        if c2rec.reference_search_age = '7D' then htp.formselectoption( '7 '   || LNG3.ADM_TXT_668, 'SELECTED', cattributes=>'VALUE="7D"' ); else htp.formselectoption( '7 '   || LNG3.ADM_TXT_668, cattributes=>'VALUE="7D"' ); end if;
        if c2rec.reference_search_age = '1W' then htp.formselectoption( '1 '   || LNG5.EXT_TXT_046, 'SELECTED', cattributes=>'VALUE="1W"' ); else htp.formselectoption( '1 '   || LNG5.EXT_TXT_046, cattributes=>'VALUE="1W"' ); end if;
        if c2rec.reference_search_age = '2W' then htp.formselectoption( '2 '   || LNG5.EXT_TXT_046, 'SELECTED', cattributes=>'VALUE="2W"' ); else htp.formselectoption( '2 '   || LNG5.EXT_TXT_046, cattributes=>'VALUE="2W"' ); end if;
        if c2rec.reference_search_age = '3W' then htp.formselectoption( '3 '   || LNG5.EXT_TXT_046, 'SELECTED', cattributes=>'VALUE="3W"' ); else htp.formselectoption( '3 '   || LNG5.EXT_TXT_046, cattributes=>'VALUE="3W"' ); end if;
        if c2rec.reference_search_age = '4W' then htp.formselectoption( '4 '   || LNG5.EXT_TXT_046, 'SELECTED', cattributes=>'VALUE="4W"' ); else htp.formselectoption( '4 '   || LNG5.EXT_TXT_046, cattributes=>'VALUE="4W"' ); end if;
        if c2rec.reference_search_age = '1M' then htp.formselectoption( '1 '   || LNG3.ADM_TXT_667, 'SELECTED', cattributes=>'VALUE="1M"' ); else htp.formselectoption( '1 '   || LNG3.ADM_TXT_667, cattributes=>'VALUE="1M"' ); end if;
        if c2rec.reference_search_age = '2M' then htp.formselectoption( '2 '   || LNG3.ADM_TXT_667, 'SELECTED', cattributes=>'VALUE="2M"' ); else htp.formselectoption( '2 '   || LNG3.ADM_TXT_667, cattributes=>'VALUE="2M"' ); end if;
        if c2rec.reference_search_age = '3M' then htp.formselectoption( '3 '   || LNG3.ADM_TXT_667, 'SELECTED', cattributes=>'VALUE="3M"' ); else htp.formselectoption( '3 '   || LNG3.ADM_TXT_667, cattributes=>'VALUE="3M"' ); end if;
        if c2rec.reference_search_age = '4M' then htp.formselectoption( '4 '   || LNG3.ADM_TXT_667, 'SELECTED', cattributes=>'VALUE="4M"' ); else htp.formselectoption( '4 '   || LNG3.ADM_TXT_667, cattributes=>'VALUE="4M"' ); end if;
        if c2rec.reference_search_age = '5M' then htp.formselectoption( '5 '   || LNG3.ADM_TXT_667, 'SELECTED', cattributes=>'VALUE="5M"' ); else htp.formselectoption( '5 '   || LNG3.ADM_TXT_667, cattributes=>'VALUE="5M"' ); end if;
        if c2rec.reference_search_age = '6M' then htp.formselectoption( '6 '   || LNG3.ADM_TXT_667, 'SELECTED', cattributes=>'VALUE="6M"' ); else htp.formselectoption( '6 '   || LNG3.ADM_TXT_667, cattributes=>'VALUE="6M"' ); end if;
        if c2rec.reference_search_age = '7M' then htp.formselectoption( '7 '   || LNG3.ADM_TXT_667, 'SELECTED', cattributes=>'VALUE="7M"' ); else htp.formselectoption( '7 '   || LNG3.ADM_TXT_667, cattributes=>'VALUE="7M"' ); end if;
        if c2rec.reference_search_age = '8M' then htp.formselectoption( '8 '   || LNG3.ADM_TXT_667, 'SELECTED', cattributes=>'VALUE="8M"' ); else htp.formselectoption( '8 '   || LNG3.ADM_TXT_667, cattributes=>'VALUE="8M"' ); end if;
        if c2rec.reference_search_age = '9M' then htp.formselectoption( '9 '   || LNG3.ADM_TXT_667, 'SELECTED', cattributes=>'VALUE="9M"' ); else htp.formselectoption( '9 '   || LNG3.ADM_TXT_667, cattributes=>'VALUE="9M"' ); end if;
        if c2rec.reference_search_age = '10M' then htp.formselectoption( '10 ' || LNG3.ADM_TXT_667, 'SELECTED', cattributes=>'VALUE="10M"' ); else htp.formselectoption( '10 ' || LNG3.ADM_TXT_667, cattributes=>'VALUE="10M"' ); end if;
        if c2rec.reference_search_age = '11M' then htp.formselectoption( '11 ' || LNG3.ADM_TXT_667, 'SELECTED', cattributes=>'VALUE="11M"' ); else htp.formselectoption( '11 ' || LNG3.ADM_TXT_667, cattributes=>'VALUE="11M"' ); end if;
        if c2rec.reference_search_age = '12M' then htp.formselectoption( '12 ' || LNG3.ADM_TXT_667, 'SELECTED', cattributes=>'VALUE="12M"' ); else htp.formselectoption( '12 ' || LNG3.ADM_TXT_667, cattributes=>'VALUE="12M"' ); end if;
        if c2rec.reference_search_age = '1Y' then htp.formselectoption( '1 '   || LNG2.PBK_TXT_034, 'SELECTED', cattributes=>'VALUE="1Y"' ); else htp.formselectoption( '1 '   || LNG2.PBK_TXT_034, cattributes=>'VALUE="1Y"' ); end if;
        if c2rec.reference_search_age = '2Y' then htp.formselectoption( '2 '   || LNG2.PBK_TXT_034, 'SELECTED', cattributes=>'VALUE="2Y"' ); else htp.formselectoption( '2 '   || LNG2.PBK_TXT_034, cattributes=>'VALUE="2Y"' ); end if;
        if c2rec.reference_search_age = '3Y' then htp.formselectoption( '3 '   || LNG2.PBK_TXT_034, 'SELECTED', cattributes=>'VALUE="3Y"' ); else htp.formselectoption( '3 '   || LNG2.PBK_TXT_034, cattributes=>'VALUE="3Y"' ); end if;
        if c2rec.reference_search_age = '4Y' then htp.formselectoption( '4 '   || LNG2.PBK_TXT_034, 'SELECTED', cattributes=>'VALUE="4Y"' ); else htp.formselectoption( '4 '   || LNG2.PBK_TXT_034, cattributes=>'VALUE="4Y"' ); end if;
        if c2rec.reference_search_age = '5Y' then htp.formselectoption( '5 '   || LNG2.PBK_TXT_034, 'SELECTED', cattributes=>'VALUE="5Y"' ); else htp.formselectoption( '5 '   || LNG2.PBK_TXT_034, cattributes=>'VALUE="5Y"' ); end if;
        if c2rec.reference_search_age = '6Y' then htp.formselectoption( '6 '   || LNG2.PBK_TXT_034, 'SELECTED', cattributes=>'VALUE="6Y"' ); else htp.formselectoption( '6 '   || LNG2.PBK_TXT_034, cattributes=>'VALUE="6Y"' ); end if;
        if c2rec.reference_search_age = '7Y' then htp.formselectoption( '7 '   || LNG2.PBK_TXT_034, 'SELECTED', cattributes=>'VALUE="7Y"' ); else htp.formselectoption( '7 '   || LNG2.PBK_TXT_034, cattributes=>'VALUE="7Y"' ); end if;
        if c2rec.reference_search_age = '8Y' then htp.formselectoption( '8 '   || LNG2.PBK_TXT_034, 'SELECTED', cattributes=>'VALUE="8Y"' ); else htp.formselectoption( '8 '   || LNG2.PBK_TXT_034, cattributes=>'VALUE="8Y"' ); end if;
        if c2rec.reference_search_age = '9Y' then htp.formselectoption( '9 '   || LNG2.PBK_TXT_034, 'SELECTED', cattributes=>'VALUE="9Y"' ); else htp.formselectoption( '9 '   || LNG2.PBK_TXT_034, cattributes=>'VALUE="9Y"' ); end if;
        if c2rec.reference_search_age = '10Y' then htp.formselectoption( '10 ' || LNG2.PBK_TXT_034, 'SELECTED', cattributes=>'VALUE="10Y"' );else  htp.formselectoption( '10 ' || LNG2.PBK_TXT_034, cattributes=>'VALUE="10Y"' );end if;
       htp.formselectclose;
       htp.p( '</TD>' );
   htp.tablerowclose;
   -- Display Thumbnail or Text as Reference Link
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_076 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    if nvl(c2rec.tnail_or_text,'T') = 'T'
     then
      htp.tabledata( htf.formradio( 'P14', 'T', 'CHECKED' ) || ' ' || LNG.PHG_ALT_296 || ' ' || htf.formradio( 'P14', 'N' ) || ' ' || LNG.GLB_TXT_064 || ' ' || htf.formradio( 'P14', 'B' ) || ' ' || LNG5.EXT_TXT_234, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    elsif nvl(c2rec.tnail_or_text,'T') = 'N'
     then
      htp.tabledata( htf.formradio( 'P14', 'T' ) || ' ' || LNG.PHG_ALT_296 || ' ' || htf.formradio( 'P14', 'N', 'CHECKED' ) || ' ' || LNG.GLB_TXT_064 || ' ' || htf.formradio( 'P14', 'B' ) || ' ' || LNG5.EXT_TXT_234, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      htp.tabledata( htf.formradio( 'P14', 'T' ) || ' ' || LNG.PHG_ALT_296 || ' ' || htf.formradio( 'P14', 'N' ) || ' ' || LNG.GLB_TXT_064 || ' ' || htf.formradio( 'P14', 'B', 'CHECKED' ) || ' ' || LNG5.EXT_TXT_234, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
    -- Language File
    htp.tabledata( htf.bold( 'Matte Around Thumbnail' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    if nvl(c2rec.matte_image,'F') = 'T'
     then
      htp.tabledata( htf.formradio( 'P14M', 'T', 'CHECKED' ) || ' ' || 'Yes' || ' ' || htf.formradio( 'P14M', 'F' ) || ' ' || 'No', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      htp.tabledata( htf.formradio( 'P14M', 'T' ) || ' ' || 'Yes' || ' ' || htf.formradio( 'P14M', 'F', 'CHECKED' ) || ' ' || 'No', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
   htp.tablerowclose;
   if c2rec.tnail_or_text in ('N','B')
    then
     -- Thumbnail
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.GLB_TXT_064 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      htp.formselectopen( 'P15' );
      for c7rec in c7(acid) loop
       if c7rec.umo_id = c2rec.tnail_id
        then
         htp.formselectoption( c7rec.film_name, 'SELECTED', cattributes=>'VALUE="' || c7rec.umo_id || '"' );
        else
         htp.formselectoption( c7rec.film_name, cattributes=>'VALUE="' || c7rec.umo_id || '"' );
       end if;
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG5.EXT_TXT_230 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      if nvl(c2rec.image_loc,'T') = 'T'
       then
        htp.formradio( 'P22', 'T', 'CHECKED' );
       else
        htp.formradio( 'P22', 'T' );
      end if;
      htp.p( ' ' || LNG3.ADM_TXT_580 ); htp.nl;
      if nvl(c2rec.image_loc,'T') = 'L'
       then
        htp.formradio( 'P22', 'L', 'CHECKED' );
       else
        htp.formradio( 'P22', 'L' );
      end if;
      htp.p( ' ' || LNG.PHG_TXT_285 ); htp.nl;
      if nvl(c2rec.image_loc,'T') = 'R'
       then
        htp.formradio( 'P22', 'R', 'CHECKED' );
       else
        htp.formradio( 'P22', 'R' );
      end if;
      htp.p( ' ' || LNG5.EXT_TXT_232 ); htp.nl;
      if nvl(c2rec.image_loc,'T') = 'C'
       then
        htp.formradio( 'P22', 'C', 'CHECKED' );
       else
        htp.formradio( 'P22', 'C' );
      end if;
      htp.p( ' ' || LNG.PHG_TXT_385 ); htp.nl;
      if nvl(c2rec.image_loc,'T') = 'B'
       then
        htp.formradio( 'P22', 'B', 'CHECKED' );
       else
        htp.formradio( 'P22', 'B' );
      end if;
      htp.p( ' ' || LNG5.EXT_TXT_233 ); htp.nl;
      htp.p( '</TD>' );
     htp.tablerowclose;
    else
     htp.formhidden( 'P15', NULL );
     htp.formhidden( 'P22', NULL );
   end if;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_078 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    if c2rec.line_between_news = 'T'
     then
      htp.tabledata( htf.formradio( 'P17', 'T', 'CHECKED' ) || ' ' || LNG5.EXT_TXT_080 || ' ' || htf.formradio( 'P17', 'F' ) || ' ' || LNG5.EXT_TXT_081, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      htp.tabledata( htf.formradio( 'P17', 'T' ) || ' ' || LNG5.EXT_TXT_080 || ' ' || htf.formradio( 'P17', 'N', 'CHECKED' ) || ' ' || LNG5.EXT_TXT_081, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG5.EXT_TXT_079 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      htp.formselectopen( 'P18' );
        if c2rec.display_to = 'C' then htp.formselectoption( LNG.PHG_TXT_199, 'SELECTED', cattributes=>'VALUE="C"' ); else htp.formselectoption( LNG.PHG_TXT_199, cattributes=>'VALUE="C"' ); end if;
        if c2rec.display_to = 'G' then htp.formselectoption( LNG3.ADM_TXT_546, 'SELECTED', cattributes=>'VALUE="G"' ); else htp.formselectoption( LNG3.ADM_TXT_546, cattributes=>'VALUE="G"' ); end if;
        if nvl(c2rec.display_to,'B') = 'B' then htp.formselectoption( LNG5.EXT_TXT_082, 'SELECTED', cattributes=>'VALUE="B"' ); else htp.formselectoption( LNG5.EXT_TXT_082, cattributes=>'VALUE="B"' ); end if;
      htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  if hnw is null
   then
    htp.formsubmit( 'ACTION', LNG5.EXT_TXT_058 );
   else
    htp.formsubmit( 'ACTION', LNG5.EXT_TXT_059 );
    htp.formsubmit( 'ACTION', LNG5.EXT_TXT_060 );
  end if;
  htp.formsubmit( 'ACTION', LNG5.EXT_TXT_055 );
  htp.formsubmit( 'ACTION', LNG5.EXT_TXT_061 );
  htp.formclose;
  htp.nl;
  htp.nl;
  htp.line;
  htp.nl;
  htp.nl;
  htp.tableopen( cattributes=>' WIDTH="33%" cellspacing=0 cellpadding=10 border=1 frame="VOID" rules="COLS"' );
  htp.tablerowopen;
   htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' );
    glbx.home_disptable( c2rec, surl, acid, stype, ltype, pfx, c1rec, theme_rec, null );
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tableclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'HOMENEWS', errmsg=>sqlerrm, extdet=>'HNW:' || hnw);
end homenews;

procedure accept_homenews( surl in varchar2, acid in varchar2, hnw in integer,
                           p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2,
                           p9 in varchar2, p10 in varchar2, p11 in varchar2, p12 in GLBX.MYARRAY, p13 in varchar2, p14 in varchar2, p14m in varchar2,
                           p15 in varchar2, p16 in varchar2, p17 in varchar2, p18 in varchar2, p19 in varchar2, p20 in varchar2, p21 in varchar2, p22 in varchar2, action in varchar2)
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 vhnw		integer;
 sts		varchar2(100);
 np12		varchar2(4000);
 cens		varchar2(4000);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_HOMENEWS', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if action = LNG5.EXT_TXT_061
   then
    home_page_option(surl,acid);
    return;
  end if;

  if action = LNG5.EXT_TXT_060
   then
    delete from home_news
     where
      aid = acid and
      hnews = hnw;
    commit;
    home_page_option(surl,acid);
    return;
  end if;

  np12 := NULL;
  for j in p12.first..p12.last loop
   if p12(j) is not null
    then
     np12 := np12 || ',' || p12(j);
   end if;
  end loop;
  if np12 = ',' then np12 := NULL; end if;

  cens := glbx.censor( replace(p9,'<BR>',chr(13)), 4000 );

  if hnw is null
   then
    select s_home_news.nextval into vhnw from dual;
    insert into home_news(hnews,aid,title,title_highlight,title_font_colour,title_inc_font,order_by,display_column,font,font_colour,font_inc_font,reference_link_type,
                          reference_link,reference_search_cat,reference_search_age,tnail_or_text,matte_image,tnail_id,text_display,line_between_news,display_to,news,frame_news,news_object,image_loc) values
    (vhnw,acid,p1,p2,p3,p4,p19,p5,p6,p7,p8,p10,
     p11,np12,p13,p14,p14m,p15,p16,p17,p18,cens,p20,p21,p22);
   else
    vhnw := hnw;
    update home_news
     set
      title = p1,
      title_highlight = p2,
      title_font_colour = p3,
      title_inc_font = p4,
      order_by = p19,
      display_column = p5,
      font = p6,
      font_colour = p7,
      font_inc_font = p8,
      reference_link_type = p10,
      reference_link = p11,
      reference_search_cat = np12,
      reference_search_age = p13,
      tnail_or_text = p14,
      matte_image = p14m,
      tnail_id = p15,
      text_display = p16,
      line_between_news = p17,
      display_to = p18,
      news = cens,
      frame_news = p20,
      news_object = p21,
      image_loc = p22
    where
     aid = acid and
     hnews = vhnw;
  end if;
  commit;

  if action = LNG5.EXT_TXT_055
   then
    homenews(surl,acid,null,null);
    return;
  end if;

  if action = LNG5.EXT_TXT_058
   then
    homenews( surl, acid, vhnw, LNG5.EXT_TXT_062 );
   else
    homenews( surl, acid, vhnw, LNG5.EXT_TXT_063 );
  end if;

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_HOMENEWS', errmsg=>sqlerrm);
end accept_homenews;

procedure workflow_chart(surl in varchar2, workid in integer, msg in varchar2 default null )
as

 cursor c2(phgid integer, workid integer) is select workflow_name from workflow_set where pid = phgid and status_workflow = workid;
 cursor c3(phgid integer, workid integer) is select * from workflow where pid = phgid and status_workflow = workid order by status_priority_default;
 cursor c4(sid integer) is select response,workflow_activity_id from workflow_question where status_id = sid;
 cursor c5(wid integer) is select name from workflow_activity_defn where workflow_activity_id = wid;
 cursor c6(sid integer) is select * from workflow_query where status_id = sid order by decode(if_or_else,'I',1,2),order_by;
 cursor c7( mfcid integer ) is select name from manufacturer where manufacturer_id = mfcid;

 c2rec		c2%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c7rec		c7%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

 function work_act( actid integer )
  return varchar2
 as
  cursor cw( actid integer ) is
   select wo.option_name,wo.activity_type,wa.extra_value_1,wa.extra_value_2,wa.extra_value_3,wa.extra_value_4, wa.extra_value_5
   from workflow_activity wa, workflow_option wo
   where wa.activity_type = wo.activity_type and
         wa.workflow_activity_id = actid
   order by activity_order;
  cursor catt( attid integer ) is select sub_category from umo_attributes where attribute_id = attid;
  cursor cmfc( mfcid integer ) is select name from manufacturer where manufacturer_id = mfcid;

 retval 	varchar2(32767);
 tval		varchar2(100);

 begin
  for cwrec in cw(actid) loop
   retval := retval || htf.nl || ' .' || cwrec.option_name;
   if cwrec.activity_type in ('A','B','C','D''E','F','O','P','Q','R','r','S','T')
    then
     null;
   elsif cwrec.activity_type in ('G','U','V','W','X','Y')
    then
     retval := retval || cwrec.extra_value_1;
   elsif cwrec.activity_type in ('H','j')
    then
     open c2( owner_id, cwrec.extra_value_1 );
     fetch c2 into tval;
     close c2;
     retval := retval || ' (' || tval || ')';
   elsif cwrec.activity_type = 'I'
    then
     open c2( owner_id, substr(cwrec.extra_value_1,instr(cwrec.extra_value_1,']')+1) );
     fetch c2 into tval;
     close c2;
     retval := retval || tval || ' (' || substr(cwrec.extra_value_1,2,instr(cwrec.extra_value_1,']')-2) || ')';
   elsif cwrec.activity_type = 'J'
    then
     open c5( cwrec.extra_value_1 );
     fetch c5 into tval;
     close c5;
     retval := retval || ' (' || tval || ')';
   elsif cwrec.activity_type in ('K','M','N')
    then
     open catt( cwrec.extra_value_1 );
     fetch catt into tval;
     close catt;
     retval := retval || ' (' || tval || ')';
   elsif cwrec.activity_type in ('L','l')
    then
     open cmfc( cwrec.extra_value_1 );
     fetch cmfc into tval;
     close cmfc;
     retval := retval || ' (' || tval || ')';
   elsif cwrec.activity_type in ('Z','b')
    then
     open c5( cwrec.extra_value_3 );
     fetch c5 into tval;
     close c5;
     retval := retval || cwrec.extra_value_1 || ' (' || tval || ')';
   elsif cwrec.activity_type = 'a'
    then
     open cmfc( cwrec.extra_value_1 );
     fetch cmfc into tval;
     close cmfc;
     retval := retval || ' - ' || tval;
     open c5( cwrec.extra_value_3 );
     fetch c5 into tval;
     close c5;
     retval := retval || ' (' || tval || ')';
   elsif cwrec.activity_type in ('c','d')
    then
     open cmfc( cwrec.extra_value_3 );
     fetch cmfc into tval;
     close cmfc;
     retval := retval || cwrec.extra_value_1 || '-' || tval;
   elsif cwrec.activity_type in ('e')
    then
     open catt( cwrec.extra_value_1 );
     fetch catt into tval;
     close catt;
     retval := retval || ' - ' || tval;
     open cmfc( cwrec.extra_value_3 );
     fetch cmfc into tval;
     close cmfc;
     retval := retval || ' (' || tval || ')';
   end if;
  end loop;
  return( retval );
 exception
  when others then return( retval || htf.nl || sqlerrm );
 end work_act;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.WORKFLOW_CHART', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  open c2(owner_id,workid);
  fetch c2 into c2rec;
  close c2;
  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, c2rec.workflow_name, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P57',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.title( LNG4.AHC_TXT_809 );
  htp.nl;
  if msg is not null then glbx.header_msg( msg ); end if;
  htp.p( '<CENTER>' );
  htp.tableopen( cattributes=>'cellpadding=3 cellspacing=3 border=0' );
  for c3rec in c3(owner_id,workid) loop
   htp.tablerowopen;
    htp.tabledata( c3rec.status_priority_default, cattributes=>'valign="TOP" align="LEFT"' );
    if c3rec.workflow_type = 'Q'
     then
      open c7( c3rec.manufacturer_id );
      fetch c7 into c7rec;
      close c7;
      htp.tabledata( LNG3.ADM_TXT_428, cattributes=>'valign="TOP" align="LEFT"' );
      htp.tabledata( htf.anchor( 'pbk.mng_workflow_task?surl=' || surl || '&workid=' || workid || '&p1=&vsts=' || c3rec.status_id ,c3rec.question || '-' || c7rec.name), cattributes=>'valign="TOP" align="LEFT"' );
      for c4rec in c4( c3rec.status_id ) loop
       if c4rec.workflow_activity_id = 0
        then
         htp.tabledata( htf.bold( c4rec.response ) || htf.nl || htf.italic( LNG5.EXT_TXT_008 ), cattributes=>'CLASS="SMALL" valign="TOP" align="LEFT"' );
        else
         open c5( c4rec.workflow_activity_id );
         fetch c5 into c5rec;
         close c5;
         htp.tabledata( htf.bold( c4rec.response ) || htf.nl || htf.italic( htf.anchor( 'pbk.mng_workflow_activity?surl=' || surl || '&p1=&actid=' || c4rec.workflow_activity_id,c5rec.name )) || work_act( c4rec.workflow_activity_id ), cattributes=>'CLASS="SMALL" valign="TOP" align="LEFT"');
       end if;
      end loop;
    elsif c3rec.workflow_type = 'M'
     then
      htp.tabledata( LNG4.AHC_TXT_929, cattributes=>'valign="TOP" align="LEFT"' );
      for c6rec in c6( c3rec.status_id ) loop
       if c6rec.if_or_else = 'E'
        then
         open c5( c6rec.workflow_activity_id );
         fetch c5 into c5rec;
         close c5;
         htp.tabledata( htf.bold( 'Else' ) || htf.nl || htf.italic( htf.anchor( 'pbk.mng_workflow_activity?surl=' || surl || '&p1=&actid=' || c6rec.workflow_activity_id,LNG5.EXT_TXT_008 )) || work_act( c6rec.workflow_activity_id ), cattributes=>'CLASS="SMALL" valign="TOP" align="LEFT"' );
        else
         open c5( c6rec.workflow_activity_id );
         fetch c5 into c5rec;
         close c5;
         htp.tabledata( htf.bold( 'If' ) || htf.nl || htf.italic( htf.anchor( 'pbk.mng_workflow_activity?surl=' || surl || '&p1=&actid=' || c6rec.workflow_activity_id,c5rec.name ) ) || work_act( c6rec.workflow_activity_id ), cattributes=>'CLASS="SMALL" valign="TOP" align="LEFT"' );
       end if;
      end loop;
    elsif c3rec.workflow_type = 'G'
     then
      htp.tabledata( LNG4.AHC_TXT_818, cattributes=>'valign="TOP" align="LEFT"' );
      open c5( c3rec.goto_workflow );
      fetch c5 into c5rec;
      close c5;
      htp.tabledata( htf.bold(htf.anchor( 'pbk.mng_workflow_activity?surl=' || surl || '&p1=&actid=' || c3rec.goto_workflow,c5rec.name )) || work_act( c3rec.goto_workflow ), cattributes=>'CLASS="SMALL" valign="TOP" align="LEFT"' );
    elsif c3rec.workflow_type = 'I'
     then
      htp.tabledata( LNG5.EXT_TXT_126, cattributes=>'valign="TOP" align="LEFT"' );
      open c5( c3rec.goto_workflow );
      fetch c5 into c5rec;
      close c5;
      htp.tabledata( htf.bold(htf.anchor( 'pbk.mng_workflow_activity?surl=' || surl || '&p1=&actid=' || c3rec.goto_workflow,c5rec.name )) || work_act( c3rec.goto_workflow ), cattributes=>'CLASS="SMALL" valign="TOP" align="LEFT"' );
    end if;
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.nl;
  htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'WORKFLOW_CHART', errmsg=>sqlerrm);
end workflow_chart;

procedure meta_screen(surl in varchar2, acid in integer, msg in varchar2 default null)
as

 cursor c2(acid integer) is select distinct target_area from customer_meta_data_group where aid = acid;
 cursor c3(acid integer, tg char) is select count('x') tot from customer_meta_data_group where aid = acid and target_area = tg;

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'C', progcalled=>'PBK.META_SCREEN', iscust=>FALSE );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;
 c1rec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG5.EXT_TXT_236, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P66',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>' );
 if msg is not null then glbx.header_msg( msg ); end if;

 htp.formopen( 'pbk.edit_meta_screen' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'ACID', acid );
 htp.bold( LNG5.EXT_TXT_328 );
 htp.formselectopen( 'TARGET' );
 open c3(acid,'G');
 fetch c3 into c3rec;
 close c3;
 if c3rec.tot = 0 then htp.formselectoption(LNG5.EXT_TXT_325, cattributes=>'VALUE="G"'  ); end if;
 open c3(acid,'I');
 fetch c3 into c3rec;
 close c3;
 if c3rec.tot = 0 then htp.formselectoption(LNG5.EXT_TXT_327, cattributes=>'VALUE="I"'  ); end if;
 open c3(acid,'P');
 fetch c3 into c3rec;
 close c3;
 if c3rec.tot = 0 then htp.formselectoption(LNG5.EXT_TXT_326, cattributes=>'VALUE="P"'  ); end if;
 open c3(acid,'C');
 fetch c3 into c3rec;
 close c3;
 if c3rec.tot = 0 then htp.formselectoption('Customer Load', cattributes=>'VALUE="C"'  ); end if;
 open c3(acid,'R');
 fetch c3 into c3rec;
 close c3;
 if c3rec.tot = 0 then htp.formselectoption('Customer Image Edit', cattributes=>'VALUE="R"'  ); end if;
 open c3(acid,'S');
 fetch c3 into c3rec;
 close c3;
 if c3rec.tot = 0 then htp.formselectoption(LNG.GLB_TXT_092, cattributes=>'VALUE="S"'  ); end if;
 htp.formselectoption(LNG5.EXT_TXT_331, cattributes=>'VALUE="U"'  );
 htp.formselectclose;
 htp.nl;
 htp.nl;
 htp.formsubmit( null, LNG5.EXT_TXT_329 );
 htp.formclose;
 htp.nl;

 htp.nl;
 htp.bold( LNG5.EXT_TXT_330 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 for c2rec in c2(acid) loop
  htp.tablerowopen;
   if c2rec.target_area = 'I'
    then
     htp.tabledata( htf.anchor( 'pbk.edit_meta_screen?surl=' || surl || '&acid=' || acid || '&target=' || c2rec.target_area, LNG5.EXT_TXT_327));
   elsif c2rec.target_area = 'G'
    then
     htp.tabledata( htf.anchor( 'pbk.edit_meta_screen?surl=' || surl || '&acid=' || acid || '&target=' || c2rec.target_area, LNG5.EXT_TXT_325));
   elsif c2rec.target_area = 'P'
    then
     htp.tabledata( htf.anchor( 'pbk.edit_meta_screen?surl=' || surl || '&acid=' || acid || '&target=' || c2rec.target_area, LNG5.EXT_TXT_326));
   elsif c2rec.target_area = 'C'
    then
     htp.tabledata( htf.anchor( 'pbk.edit_meta_screen?surl=' || surl || '&acid=' || acid || '&target=' || c2rec.target_area, 'Customer Load'));
   elsif c2rec.target_area = 'R'
    then
     htp.tabledata( htf.anchor( 'pbk.edit_meta_screen?surl=' || surl || '&acid=' || acid || '&target=' || c2rec.target_area, 'Customer Image Edit'));
   elsif c2rec.target_area = 'S'
    then
     htp.tabledata( htf.anchor( 'pbk.edit_meta_screen?surl=' || surl || '&acid=' || acid || '&target=' || c2rec.target_area, LNG.GLB_TXT_092));
   elsif substr(c2rec.target_area,1,1) = 'U'
    then
     htp.tabledata( htf.anchor( 'pbk.edit_meta_screen?surl=' || surl || '&acid=' || acid || '&target=' || c2rec.target_area, LNG5.EXT_TXT_331 || ':' || substr(c2rec.target_area,2)));
   end if;
  htp.tablerowclose;
 end loop;
 htp.tableclose;

exception when others then
 glbx.error_details( 'PBK', 'META_SCREEN', errmsg=>sqlerrm);
end meta_screen;

procedure edit_meta_screen(surl in varchar2, acid in integer, target in varchar2, msg in varchar2 default null)
as

 cursor c2(acid integer, trg char) is select * from customer_meta_data_group where aid = acid and target_area = trg order by display_order;
 cursor c3(acid integer, grpid integer) is select * from customer_meta_data where aid = acid and group_id = grpid order by display_order;
 cursor c4(acid integer) is select nvl(max(substr(target_area,2)),0) + 1 mx from customer_meta_data_group where aid = acid and substr(target_area,1,1) = 'U';
 cursor c5(phgid integer) is
  select nd.display_name, nd.novelty_id
  from novelty_set ns, charge_plan cp, photographer p, novelty_definition nd
  where p.pid = phgid and
        p.plan_id = cp.id and
        ns.novelty_id = nd.novelty_id and
        cp.novelty_set_id = ns.novelty_set_id
  order by novelty_set_name;
 cursor c6(acid integer) is select distinct target_area from customer_meta_data_group where aid = acid;
 cursor c7(phgid integer) is select aid,account_name from customer_account where pid = phgid order by account_name;

 cusrec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 empty_c3	c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 ttl		varchar2(100);
 trg		varchar2(10);
 button_found	boolean;
 defval		glbx.myarray;

procedure disp_meta_group( c2rec in customer_meta_data_group%ROWTYPE, phgid in integer )
as
begin
 htp.formhidden( 'PG1', c2rec.group_id );
 htp.bold( LNG5.EXT_TXT_332);
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 rules="NONE" frame="HSIDES,VSIDES" border=1');
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG5.EXT_TXT_333),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'PG2', 80, 100, c2rec.title ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  if substr(target,1,1) = 'U'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_929),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.anchor2( 'pbk.edit_query?surl=' || surl || '&acid=' || acid || '&target=' || target, LNG.PHG_TXT_503, ctarget=>'USERDEFINEDQUERY' );
     htp.p( '. ' || LNG5.EXT_TXT_301 );
     htp.formselectopen( 'PG6' );
     htp.formselectoption( NULL );
     for c5rec in c5(phgid) loop
      if c5rec.novelty_id = c2rec.novelty_id
       then
        htp.formselectoption( c5rec.display_name, 'SELECTED', cattributes=>'VALUE="' || c5rec.novelty_id || '"');
       else
        htp.formselectoption( c5rec.display_name, cattributes=>'VALUE="' || c5rec.novelty_id || '"');
      end if;
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
    htp.tablerowclose;
   else
    htp.formhidden( 'PG6', null );
  end if;
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG3.ADM_TXT_177),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'PG3', 10, 10, c2rec.display_order ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG5.EXT_TXT_334),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'PG4', 80, 1000,replace( c2rec.html_table,'"','&#34;' )),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( htf.bold(LNG5.EXT_TXT_335),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'PG5', 80, 1000,replace( c2rec.html_tabledata,'"','&#34;' )),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;
end disp_meta_group;

procedure disp_meta_val( c3rec in customer_meta_data%ROWTYPE )
as

 cursor c1( bftr varchar2 ) is
  select attribute_id, sub_category, umo_type
  from umo_attributes
  where ((business_feature is null) or (business_feature is not null and business_feature = bftr)) and
         disp_phg = 'T' and
         umo_type in ('ALL','PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT')
  order by sub_category;

 cursor c2 is
  select 'P' || column_name res, '[Purchase]' || column_name disp
  from user_tab_columns
  where table_name = 'PURCHASE_ORDER'
  union all
  select 'S' || column_name, '[Shopping]' || column_name
  from user_tab_columns
  where table_name = 'SHOPPING_BASKET'
  union all
  select 'U' || column_name, '[UMO]' || column_name
  from user_tab_columns
  where table_name = 'UMO' and
        data_type in ('CHAR','NUMBER','VARCHAR2')
  order by 1;

  cl		varchar2(100);

begin
 htp.tablerowopen;
  htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
  htp.formhidden( 'PD0', '[' || c3rec.group_id || ']' || c3rec.meta_data_id );
  htp.formselectopen( 'PD1' );
  htp.formselectoption( NULL );

  if c3rec.attribute_id = -1
   then
    htp.formselectoption('Force New Line', 'SELECTED', cattributes=>'VALUE="-1"'  );
   else
    htp.formselectoption('Force New Line', cattributes=>'VALUE="-1"'  );
  end if;
  if c3rec.attribute_id = -2
   then
    htp.formselectoption('Show Title Only', 'SELECTED', cattributes=>'VALUE="-2"'  );
   else
    htp.formselectoption('Show Title Only', cattributes=>'VALUE="-2"'  );
  end if;
  if c3rec.attribute_id = -3
   then
    htp.formselectoption('Embed Gif', 'SELECTED', cattributes=>'VALUE="-3"'  );
   else
    htp.formselectoption('Embed Gif', cattributes=>'VALUE="-3"'  );
  end if;

  -- User Defined Screens cannot upload, but they can display a variable
  if substr(target,1,1) = 'U'
   then
    if c3rec.attribute_id = -10
     then
      htp.formselectoption('Show Object Attribute', 'SELECTED', cattributes=>'VALUE="-10"'  );
     else
      htp.formselectoption('Show Object Attribute', cattributes=>'VALUE="-10"'  );
    end if;
   else
    if c3rec.attribute_id = -4
     then
      htp.formselectoption('Upload/Reload Image Button', 'SELECTED', cattributes=>'VALUE="-4"'  );
     else
      htp.formselectoption('Upload/Reload Image Button', cattributes=>'VALUE="-4"'  );
    end if;
  end if;

  if c3rec.attribute_id = -5
   then
    htp.formselectoption('Category Listing', 'SELECTED', cattributes=>'VALUE="-5"'  );
   else
    htp.formselectoption('Category Listing', cattributes=>'VALUE="-5"'  );
  end if;
  if c3rec.attribute_id = -6
   then
    htp.formselectoption('Image Compression', 'SELECTED', cattributes=>'VALUE="-6"'  );
   else
    htp.formselectoption('Image Compression', cattributes=>'VALUE="-6"'  );
  end if;
  if c3rec.attribute_id = -7
   then
    htp.formselectoption('Image Type', 'SELECTED', cattributes=>'VALUE="-7"'  );
   else
    htp.formselectoption('Image Type', cattributes=>'VALUE="-7"'  );
  end if;
  if c3rec.attribute_id = -8
   then
    htp.formselectoption('Empty Cell', 'SELECTED', cattributes=>'VALUE="-8"'  );
   else
    htp.formselectoption('Empty Cell', cattributes=>'VALUE="-8"'  );
  end if;
  if c3rec.attribute_id = -9
   then
    htp.formselectoption('Image Thumnbail', 'SELECTED', cattributes=>'VALUE="-9"'  );
   else
    htp.formselectoption('Image Thumnbail', cattributes=>'VALUE="-9"'  );
  end if;
  if c3rec.attribute_id = -13
   then
    htp.formselectoption('Main Image', 'SELECTED', cattributes=>'VALUE="-13"'  );
   else
    htp.formselectoption('Main Image', cattributes=>'VALUE="-13"'  );
  end if;
  if c3rec.attribute_id = -11
   then
    htp.formselectoption('Next Screen Button', 'SELECTED', cattributes=>'VALUE="-11"'  );
   else
    htp.formselectoption('Next Screen Button', cattributes=>'VALUE="-11"'  );
  end if;
  if c3rec.attribute_id = -12
   then
    htp.formselectoption('Previous Screen Button', 'SELECTED', cattributes=>'VALUE="-12"'  );
   else
    htp.formselectoption('Previous Screen Button', cattributes=>'VALUE="-12"'  );
  end if;
  if c3rec.attribute_id = -14
   then
    htp.formselectoption('Navigate Tool Bar (with save)', 'SELECTED', cattributes=>'VALUE="-14"'  );
   else
    htp.formselectoption('Navigate Tool Bar (with save)', cattributes=>'VALUE="-14"'  );
  end if;
  if c3rec.attribute_id = -15
   then
    htp.formselectoption('Execute Query Button', 'SELECTED', cattributes=>'VALUE="-15"'  );
   else
    htp.formselectoption('Execute Query Button', cattributes=>'VALUE="-15"'  );
  end if;
  if c3rec.attribute_id = -16
   then
    htp.formselectoption('Navigate Tool Bar', 'SELECTED', cattributes=>'VALUE="-16"'  );
   else
    htp.formselectoption('Navigate Tool Bar', cattributes=>'VALUE="-16"'  );
  end if;
  if c3rec.attribute_id = -17
   then
    htp.formselectoption('Instructions on Query Help', 'SELECTED', cattributes=>'VALUE="-17"'  );
   else
    htp.formselectoption('Instructions on Query Help', cattributes=>'VALUE="-17"'  );
  end if;
  if c3rec.attribute_id = -18
   then
    htp.formselectoption('Query Mode (query/insert/update/read only)', 'SELECTED', cattributes=>'VALUE="-18"'  );
   else
    htp.formselectoption('Query Mode (query/insert/update/read only)', cattributes=>'VALUE="-18"'  );
  end if;
  if c3rec.attribute_id = -19
   then
    htp.formselectoption('Program Defined Value', 'SELECTED', cattributes=>'VALUE="-19"'  );
   else
    htp.formselectoption('Program Defined Value', cattributes=>'VALUE="-19"'  );
  end if;

  htp.formselectoption( '-----------------', cattributes=>'VALUE=""' );

  for c1rec in c1(cusrec.theme_type) loop
   if c1rec.attribute_id = c3rec.attribute_id
    then
     htp.formselectoption(c1rec.sub_category || '(' || c1rec.umo_type || ')', 'SELECTED', cattributes=>'VALUE="' || c1rec.attribute_id || '"'  );
    else
     htp.formselectoption(c1rec.sub_category || '(' || c1rec.umo_type || ')', cattributes=>'VALUE="' || c1rec.attribute_id || '"'  );
   end if;
  end loop;
  htp.formselectclose;
  htp.p( '</TD>' );
  htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
  htp.formselectopen( 'PD2' );
  if nvl(c3rec.edit_display,'T') = 'T'
    then
     htp.formselectoption(LNG.PHG_TXT_045, 'SELECTED', cattributes=>'VALUE="T"'  );
     htp.formselectoption(LNG.PHG_TXT_046, cattributes=>'VALUE="F"'  );
    else
     htp.formselectoption(LNG.PHG_TXT_045, cattributes=>'VALUE="T"'  );
     htp.formselectoption(LNG.PHG_TXT_046, 'SELECTED', cattributes=>'VALUE="F"'  );
   end if;
  htp.formselectclose;
  htp.p( '</TD>' );
  htp.tabledata( htf.formtext( 'PD3', 5, 10, c3rec.display_order ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
  htp.formselectopen( 'PD4' );

  if c3rec.attribute_id = -10
   then
    cl := NULL;
    if c3rec.purchase_column is not null then cl := 'P' || c3rec.purchase_column;
    elsif c3rec.shopping_column is not null then cl := 'S' || c3rec.shopping_column;
    elsif c3rec.umo_column is not null then cl := 'U' || c3rec.umo_column;
    end if;
    for c2rec in c2 loop
     if c2rec.res = cl
      then
       htp.formselectoption( c2rec.disp,'SELECTED', cattributes=>'VALUE="' || c2rec.res || '"' );
      else
       htp.formselectoption( c2rec.disp,cattributes=>'VALUE="' || c2rec.res || '"' );
     end if;
    end loop;
   else
    if c3rec.display_type = 'C'
      then
       htp.formselectoption('Checkbox', 'SELECTED', cattributes=>'VALUE="C"'  );
       htp.formselectoption('LOV', cattributes=>'VALUE="L"'  );
       htp.formselectoption('LOV - Multi', cattributes=>'VALUE="M"'  );
       htp.formselectoption('LOV - Split List', cattributes=>'VALUE="S"'  );
       htp.formselectoption('Varchar2', cattributes=>'VALUE="V"'  );
       htp.formselectoption('Text Box', cattributes=>'VALUE="T"'  );
    elsif c3rec.display_type = 'L'
      then
       htp.formselectoption('Checkbox', cattributes=>'VALUE="C"'  );
       htp.formselectoption('LOV', 'SELECTED', cattributes=>'VALUE="L"'  );
       htp.formselectoption('LOV - Multi', cattributes=>'VALUE="M"'  );
       htp.formselectoption('LOV - Split List', cattributes=>'VALUE="S"'  );
       htp.formselectoption('Varchar2', cattributes=>'VALUE="V"'  );
       htp.formselectoption('Text Box', cattributes=>'VALUE="T"'  );
    elsif c3rec.display_type = 'M'
      then
       htp.formselectoption('Checkbox', cattributes=>'VALUE="C"'  );
       htp.formselectoption('LOV', cattributes=>'VALUE="L"'  );
       htp.formselectoption('LOV - Multi', 'SELECTED', cattributes=>'VALUE="M"'  );
       htp.formselectoption('LOV - Split List', cattributes=>'VALUE="S"'  );
       htp.formselectoption('Varchar2', cattributes=>'VALUE="V"'  );
       htp.formselectoption('Text Box', cattributes=>'VALUE="T"'  );
    elsif c3rec.display_type = 'S'
      then
       htp.formselectoption('Checkbox', cattributes=>'VALUE="C"'  );
       htp.formselectoption('LOV', cattributes=>'VALUE="L"'  );
       htp.formselectoption('LOV - Multi', cattributes=>'VALUE="M"'  );
       htp.formselectoption('LOV - Split List', 'SELECTED', cattributes=>'VALUE="S"'  );
       htp.formselectoption('Varchar2', cattributes=>'VALUE="V"'  );
       htp.formselectoption('Text Box', cattributes=>'VALUE="T"'  );
    elsif nvl(c3rec.display_type,'V') = 'V'
      then
       htp.formselectoption('Checkbox', cattributes=>'VALUE="C"'  );
       htp.formselectoption('LOV', cattributes=>'VALUE="L"'  );
       htp.formselectoption('LOV - Multi', cattributes=>'VALUE="M"'  );
       htp.formselectoption('LOV - Split List', cattributes=>'VALUE="S"'  );
       htp.formselectoption('Varchar2', 'SELECTED', cattributes=>'VALUE="V"'  );
       htp.formselectoption('Text Box', cattributes=>'VALUE="T"'  );
    elsif c3rec.display_type = 'T'
      then
       htp.formselectoption('Checkbox', cattributes=>'VALUE="C"'  );
       htp.formselectoption('LOV', cattributes=>'VALUE="L"'  );
       htp.formselectoption('LOV - Multi', cattributes=>'VALUE="M"'  );
       htp.formselectoption('LOV - Split List', cattributes=>'VALUE="S"'  );
       htp.formselectoption('Varchar2', cattributes=>'VALUE="V"'  );
       htp.formselectoption('Text Box', 'SELECTED', cattributes=>'VALUE="T"'  );
    end if;
    htp.formselectclose;
    htp.p( '</TD>' );
  end if;

  htp.tabledata( htf.formtext( 'PD5', 5, 10, c3rec.display_width ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.formtext( 'PD6', 5, 10, c3rec.lov_checkbox_width ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
  htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
  htp.formselectopen( 'PD7' );
  if c3rec.checkbox_enabled = 'T'
    then
     htp.formselectoption(LNG.PHG_TXT_045, 'SELECTED', cattributes=>'VALUE="T"'  );
     htp.formselectoption(LNG.PHG_TXT_046, cattributes=>'VALUE="F"'  );
    else
     htp.formselectoption(LNG.PHG_TXT_045, cattributes=>'VALUE="T"'  );
     htp.formselectoption(LNG.PHG_TXT_046, 'SELECTED', cattributes=>'VALUE="F"'  );
   end if;
  htp.formselectclose;
  htp.p( '</TD>' );
  htp.tabledata( htf.formtext( 'PD8', 20, 4000, c3rec.title ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tabledata( htf.formtext( 'PD9', 15, 4000, replace(c3rec.tablecell,'"','&#34;' ) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowclose;
end disp_meta_val;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PBK.EDIT_META_SCREEN', iscust=>FALSE );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;
 cusrec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
 pfx := glbx.get_thm( cusrec.theme_name );
 trg := target;
 if target = 'G'
  then
   ttl := LNG5.EXT_TXT_325;
 elsif target = 'I'
  then
   ttl := LNG5.EXT_TXT_327;
 elsif target = 'P'
  then
   ttl := LNG5.EXT_TXT_326;
 elsif target = 'C'
  then
   ttl := 'Customer Load';
 elsif target = 'R'
  then
   ttl := 'Customer Image Edit';
 elsif target = 'S'
  then
   ttl := LNG.GLB_TXT_092;
 elsif substr(target,1,1) = 'U'
  then
   ttl := LNG5.EXT_TXT_331;
   if target = 'U'
    then
     open c4( cusrec.aid );
     fetch c4 into c4rec;
     close c4;
     trg := 'U' || c4rec.mx;
     ttl := ttl || ':' || c4rec.mx;
    else
     ttl := ttl || ':' || substr(target,2);
   end if;
 end if;

 glbx.main_title( surl, ttl, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'P66',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.formopen( 'pbk.edit_meta_screen' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );
  htp.formselectopen( 'TARGET' );
   for c6rec in c6( acid ) loop
    if c6rec.target_area = 'G'
     then
       htp.formselectoption( LNG5.EXT_TXT_325, cattributes=>'VALUE="' || c6rec.target_area || '"');
    elsif c6rec.target_area = 'I'
     then
       htp.formselectoption( LNG5.EXT_TXT_327, cattributes=>'VALUE="' || c6rec.target_area || '"');
    elsif c6rec.target_area = 'P'
     then
       htp.formselectoption( LNG5.EXT_TXT_326, cattributes=>'VALUE="' || c6rec.target_area || '"');
    elsif c6rec.target_area = 'C'
     then
       htp.formselectoption( 'Customer Load', cattributes=>'VALUE="' || c6rec.target_area || '"');
    elsif c6rec.target_area = 'R'
     then
       htp.formselectoption( 'Customer Image Edit', cattributes=>'VALUE="' || c6rec.target_area || '"');
    elsif c6rec.target_area = 'S'
     then
       htp.formselectoption( LNG.GLB_TXT_092, cattributes=>'VALUE="' || c6rec.target_area || '"');
    elsif substr(c6rec.target_area,1,1) = 'U'
     then
       htp.formselectoption( LNG5.EXT_TXT_331 || substr(c6rec.target_area,2), cattributes=>'VALUE="' || c6rec.target_area || '"');
    end if;
   end loop;
  htp.formselectclose;
  htp.formsubmit( null, LNG5.EXT_TXT_459 );
 htp.formclose;
 htp.formopen( 'pbk.copy_meta_screen' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );
  htp.formhidden( 'TARGET', target );
  htp.formselectopen( 'NEWACID' );
  for c7rec in c7(owner_id) loop
   if acid = c7rec.aid
    then
     null;
    else
     htp.formselectoption( c7rec.account_name, cattributes=>'VALUE="' || c7rec.aid || '"');
   end if;
  end loop;
  htp.formselectclose;
  htp.formsubmit( null, LNG5.EXT_TXT_460 );
 htp.formclose;
 htp.p( '<CENTER>' );
 if msg is not null then glbx.header_msg( msg ); end if;

 htp.formopen( 'pbk.accept_meta_screen' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'TARGET', trg );
 for c2rec in c2(acid, trg) loop
  disp_meta_group( c2rec, owner_id );
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
    htp.tabledata( 'Attribute',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( 'Edit/Read',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( 'Display<BR>Order',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    if substr(target,1,1) = 'U'
     then
      htp.tabledata( 'Display Type<BR>Object Attribute',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
     else
      htp.tabledata( 'Display<BR>Type',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    end if;
    htp.tabledata( 'Display<BR>Width',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( 'Colspan[,Rowspan]<BR>or Checkbox<BR>Width',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( 'Checkbox<BR>Enabled',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( 'Title or<BR>GIF',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( 'Cell<BR>Attributes',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;
  for c3rec in c3(acid, c2rec.group_id) loop
   disp_meta_val( c3rec );
  end loop;
  empty_c3.group_id := c2rec.group_id;
  for j in 1..3 loop
   disp_meta_val( empty_c3 );
  end loop;
  htp.tableclose;
 htp.nl;
 htp.line;
 htp.nl;
 end loop;

 disp_meta_group( null, owner_id );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
    htp.tabledata( 'Attribute',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( 'Edit/Read',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( 'Display<BR>Order',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    if substr(target,1,1) = 'U'
     then
      htp.tabledata( 'Display Type<BR>Object Attribute',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
     else
      htp.tabledata( 'Display<BR>Type',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    end if;
    htp.tabledata( 'Display<BR>Width',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( 'Colspan[,Rowspan]<BR>or Checkbox<BR>Width',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( 'Checkbox<BR>Enabled',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( 'Title or<BR>GIF',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( 'Cell<BR>Attributes',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;
 for j in 1..3 loop
  disp_meta_val( null );
 end loop;
 htp.tableclose;
 htp.nl;
 htp.tableopen;
 htp.tablerowopen;
 htp.tabledata( htf.formsubmit( null, LNG5.EXT_TXT_336 ));
 htp.formclose;
 htp.formopen( 'pbk.meta_screen' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'ACID', acid );
 htp.tabledata( htf.formsubmit( null, LNG2.PFM_TXT_027 ));
 htp.formclose;
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.line;
 htp.nl;
 htp.bold( LNG5.EXT_TXT_337 );
 htp.formopen( 'dummy form', cattributes=>'name="navForm"' );
 glbx.meta_prompt( surl=>surl, acid=>acid, ltype=>ltype, tgroup=>trg, v_umo=>NULL, button_found=>button_found, default_names=>defval, default_values=>defval );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'PBK', 'EDIT_META_SCREEN', errmsg=>sqlerrm);
end edit_meta_screen;

procedure accept_meta_screen(surl in varchar2, acid in integer, target in varchar2,
                             pg1 in GLBX.MYARRAY, pg2 in GLBX.MYARRAY, pg3 in GLBX.MYARRAY, pg4 in GLBX.MYARRAY, pg5 in GLBX.MYARRAY, pg6 in GLBX.MYARRAY,
                             pd0 in GLBX.MYARRAY, pd1 in GLBX.MYARRAY, pd2 in GLBX.MYARRAY, pd3 in GLBX.MYARRAY, pd4 in GLBX.MYARRAY, pd5 in GLBX.MYARRAY, pd6 in GLBX.MYARRAY, pd7 in GLBX.MYARRAY, pd8 in GLBX.MYARRAY, pd9 in GLBX.MYARRAY)
as

 cursor c1(grpid integer) is select rowid from customer_meta_data where group_id = grpid order by display_order,meta_data_id;

 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 vl		integer;
 vl2		integer;
 vl3		integer;
 vl4		integer;
 vl5		integer;
 vl6		integer;
 nmb		integer;
 nmb2		integer;
 ctr		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_META_SCREEN', iscust=>FALSE );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;
 ctr := 1;

 for j in pg1.first..pg1.last loop
  if pg1(j) is null and pg2(j) is null
   then
    null;
   elsif pg1(j) is null
    then
     begin nmb := to_number(pg3(j)); exception when others then nmb := null; end;
     select s_meta_data_group.nextval into vl from dual;
     insert into customer_meta_data_group(aid,target_area,group_id,title,display_order,html_table,html_tabledata,novelty_id) values
      (acid,target,vl,pg2(j),nmb,pg4(j),pg5(j),pg6(j));
   else
    begin nmb := to_number(pg3(j)); exception when others then nmb := null; end;
    update customer_meta_data_group
     set
      title = pg2(j),
      display_order = nmb,
      html_table = pg4(j),
      html_tabledata = pg5(j),
      novelty_id = pg6(j)
    where
     group_id = to_number(pg1(j)) and
     aid = acid;
    vl := to_number(pg1(j));
  end if;

  for ctr in pd0.first..pd0.last loop
   if pd0(ctr) like '[' || pg1(j) || ']%'
    then
     vl2 := to_number(substr(pd0(ctr),instr(pd0(ctr),']')+1));
     begin vl4 := to_number(pd3(ctr)); exception when others then vl4 := null; end;
     begin vl5 := to_number(pd5(ctr)); exception when others then vl5 := null; end;
     --begin vl6 := to_number(pd6(ctr)); exception when others then vl6 := null; end;

     if vl2 is null and pd1(ctr) is null
     then
       null;
     elsif vl2 is null
      then
       select s_meta_data.nextval into vl3 from dual;
       if to_number(pd1(ctr)) = -10
        then
         insert into customer_meta_data(meta_data_id,aid,attribute_id,group_id,edit_display,display_order,display_type,display_width,
                                        lov_checkbox_width,checkbox_enabled,title,
                                        purchase_column,shopping_column,umo_column) values
          (vl3,acid,pd1(ctr),vl,pd2(ctr),vl4,null,vl5,pd6(ctr),pd7(ctr),pd8(ctr),
           decode(substr(pd4(ctr),1,1),'P',substr(pd4(ctr),2),NULL),
           decode(substr(pd4(ctr),1,1),'S',substr(pd4(ctr),2),NULL),
           decode(substr(pd4(ctr),1,1),'U',substr(pd4(ctr),2),NULL));
        else
         insert into customer_meta_data(meta_data_id,aid,attribute_id,group_id,edit_display,display_order,display_type,display_width,lov_checkbox_width,checkbox_enabled,title) values
          (vl3,acid,pd1(ctr),vl,pd2(ctr),vl4,pd4(ctr),vl5,pd6(ctr),pd7(ctr),pd8(ctr));
       end if;
     elsif vl2 is not null and pd1(ctr) is null
      then
       delete from customer_meta_data
        where
         aid = acid and
         meta_data_id = vl2;
     else
      if to_number(pd1(ctr)) = -10
       then
        update customer_meta_data
         set
          attribute_id = pd1(ctr),
          edit_display = pd2(ctr),
          display_order = vl4,
          display_type = null,
          display_width = vl5,
          lov_checkbox_width = pd6(ctr),
          checkbox_enabled = pd7(ctr),
          title = pd8(ctr),
          tablecell = pd9(ctr),
          purchase_column = decode(substr(pd4(ctr),1,1),'P',substr(pd4(ctr),2),NULL),
          shopping_column = decode(substr(pd4(ctr),1,1),'S',substr(pd4(ctr),2),NULL),
          umo_column = decode(substr(pd4(ctr),1,1),'U',substr(pd4(ctr),2),NULL)
        where
         aid = acid and
         meta_data_id = vl2;
       else
        update customer_meta_data
         set
          attribute_id = pd1(ctr),
          edit_display = pd2(ctr),
          display_order = vl4,
          display_type = pd4(ctr),
          display_width = vl5,
          lov_checkbox_width = pd6(ctr),
          checkbox_enabled = pd7(ctr),
          title = pd8(ctr),
          tablecell = pd9(ctr)
        where
         aid = acid and
         meta_data_id = vl2;
      end if;
     end if;

   end if;

  end loop;

  -- Readjust Display Counter
  for c1rec in c1(pg1(j)) loop
   nmb2 := c1%ROWCOUNT;
   update customer_meta_data
    set
     display_order = nmb2
   where
    rowid = c1rec.rowid;
  end loop;

 end loop;

 commit;

 edit_meta_screen(surl, acid, target, LNG5.EXT_TXT_457);
exception
 when others then htp.p( sqlerrm );
end accept_meta_screen;

procedure edit_query(surl in varchar2, acid in integer, target in varchar2, msg in varchar2 default null)
as

 cursor c5( acid integer ) is select distinct target_area from customer_meta_data_group where aid = acid and substr(target_area,1,1) = 'U' order by substr(target_area,2);
 cursor c6( usi integer, acid integer ) is select * from userdefined_query where usr_scr_id = usi and aid = acid order by decode(if_or_else,'I',0,1),order_by;

 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 if_done	boolean;
 else_done	boolean;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PBK.EDIT_QUERY', iscust=>FALSE );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;
 cusrec := glbx.get_aidx( acid, 'C', 'CUSTOMER' );
 pfx := glbx.get_thm( cusrec.theme_name );

 glbx.main_title( surl, LNG4.AHC_TXT_929 || ':' || substr(target,2), glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P57',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( LNG4.AHC_TXT_929 );
 htp.nl;
 if msg is not null then glbx.header_msg(msg); end if;
 htp.p( '<CENTER>' );

  htp.formopen( 'pbk.accept_edit_query' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );
  htp.formhidden( 'TARGET', target );

   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    if_done := FALSE;
    else_done := FALSE;
    for c6rec in c6( substr(target,2), acid ) loop
     htp.formhidden( 'P4', c6rec.query_id );
     htp.tablerowopen;
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      if c6rec.if_or_else = 'I' and c6%ROWCOUNT = 1
       then
        htp.bold( LNG4.AHC_TXT_620 || ' ' || htf.anchor( 'pbk.edit_query_statement?surl=' || surl || '&acid=' || acid || '&target=' || target || '&qry=' || c6rec.query_id, '#' || c6rec.query_id ) || ' ' || LNG5.EXT_TXT_338 || ' ' );
        if_done := TRUE;
      elsif c6rec.if_or_else = 'I'
       then
        htp.bold( LNG4.AHC_TXT_623 || ' ' || htf.anchor( 'pbk.edit_query_statement?surl=' || surl || '&acid=' || acid || '&target=' || target || '&qry=' || c6rec.query_id, '#' || c6rec.query_id ) || ' ' || LNG5.EXT_TXT_338 || ' ' );
      elsif c6rec.if_or_else = 'E'
       then
        htp.bold( LNG5.EXT_TXT_339 || ' ' );
        else_done := TRUE;
      end if;
      htp.formselectopen( 'P5' );
      for c5rec in c5( acid ) loop
       if substr(c5rec.target_area,2) = c6rec.next_usr_scr_id
        then
         htp.formselectoption( substr(c5rec.target_area,2), 'SELECTED', cattributes=>'VALUE="' || substr(c5rec.target_area,2) || '"');
        else
         htp.formselectoption( substr(c5rec.target_area,2), cattributes=>'VALUE="' || substr(c5rec.target_area,2) || '"');
       end if;
      end loop;
      if c6rec.next_usr_scr_id = 0
       then
        htp.formselectoption( LNG5.EXT_TXT_342, 'SELECTED', cattributes=>'VALUE="0"');
       else
        htp.formselectoption( LNG5.EXT_TXT_342, cattributes=>'VALUE="0"');
      end if;
      htp.formselectclose;
      htp.p( '</TD>' );
      if c6rec.if_or_else = 'I'
       then
        htp.tabledata( htf.formtext('P3',5,10,c6rec.order_by), pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( '&nbsp;', pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
        htp.formhidden( 'P3', null );
      end if;
     htp.tablerowclose;
    end loop;

     htp.tablerowopen;
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      htp.bold( htf.anchor( 'pbk.edit_query_statement?surl=' || surl || '&acid=' || acid || '&target=' || target || '&qry=', LNG4.AHC_TXT_625 ));
      htp.p( '</TD>' );
      htp.tabledata( '&nbsp;', pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;

    htp.tablerowopen;
    if not else_done
     then
      htp.formhidden( 'P4', '0' );
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
      htp.bold( LNG4.AHC_TXT_958 || ' ' );
      htp.formselectopen( 'P5' );
      for c5rec in c5( acid ) loop
       htp.formselectoption( substr(c5rec.target_area,2), cattributes=>'VALUE="' || substr(c5rec.target_area,2) || '"');
      end loop;
      htp.formselectoption( LNG5.EXT_TXT_342, cattributes=>'VALUE="0"');
      htp.formselectclose;
      htp.p( '</TD>' );
      htp.tabledata( '&nbsp;', pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.formhidden( 'P3',null);
     htp.tablerowclose;
    end if;
    htp.tableclose;

  htp.nl;
  htp.formsubmit( null, LNG5.EXT_TXT_341 );
  htp.formclose;
  htp.nl;
  htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
  htp.p( '</CENTER>' );
  htp.htmlclose;

exception when others then
 glbx.error_details( 'PBK', 'EDIT_QUERY', errmsg=>sqlerrm);
end edit_query;

procedure edit_query_statement(surl in varchar2, acid in integer, target in varchar2, qry in integer, msg in varchar2 default null )
as

 cursor c1(qry integer) is select * from userdefined_clause where query_id = qry order by order_by;
 cursor c2(trg varchar2) is
  select  1 sorton, 'M' || to_char(ua.attribute_id * -1) res, '[Screen Field:' || umo_type || '] ' || sub_category disp
  from umo_attributes ua, customer_meta_data cmd, customer_meta_data_group cmdg
  where cmdg.group_id = cmd.group_id and
        cmd.attribute_id > 0 and
        cmdg.target_area = trg and
        cmd.attribute_id = ua.attribute_id
  union all
  select  2, 'A' || attribute_id res, '[Umo Table:' || umo_type || '] ' || sub_category disp
  from umo_attributes
  union all
  select 3, 'P' || column_name, '[Purchase]' || column_name
  from user_tab_columns
  where table_name = 'PURCHASE_ORDER'
  union all
  select 4, 'S' || column_name, '[Shopping]' || column_name
  from user_tab_columns
  where table_name = 'SHOPPING_BASKET'
  union all
  select 5, 'U' || column_name, '[UMO]' || column_name
  from user_tab_columns
  where table_name = 'UMO' and
        data_type in ('CHAR','NUMBER','VARCHAR2')
  order by 1;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 cl		varchar2(100);
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.EDIT_QUERY_STATEMENT', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  pfx := glbx.photo_lf(owner_id);
  if qry is null
   then
    glbx.main_title( surl, LNG4.AHC_TXT_650 , glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P60',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   else
    glbx.main_title( surl, LNG4.AHC_TXT_667 || ':' || qry , glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P60',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  end if;
  htp.nl;
  if msg is not null then glbx.header_msg(msg); end if;
  htp.p( '<CENTER>' );
  htp.formopen( 'pbk.accept_edit_query_stmt' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );
  htp.formhidden( 'TARGET', target );
  htp.formhidden( 'QRY', qry );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.GLB_TXT_063 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_674 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_922 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG.CST_TXT_013 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_695 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_697 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  for c1rec in c1(qry) loop
   htp.tablerowopen;
    htp.formhidden( 'P0', c1rec.order_by );
    htp.tabledata( htf.formtext( 'P1', 5, 10, c1rec.order_by ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    cl := NULL;
    if c1rec.attribute_id > 0 then cl := 'A' || c1rec.attribute_id;
    elsif c1rec.attribute_id < 0 then cl := 'M' || to_char(c1rec.attribute_id);
    elsif c1rec.purchase_column is not null then cl := 'P' || c1rec.purchase_column;
    elsif c1rec.shopping_column is not null then cl := 'S' || c1rec.shopping_column;
    elsif c1rec.umo_column is not null then cl := 'U' || c1rec.umo_column;
    end if;
    htp.formselectopen( 'P2' );
    htp.formselectoption( NULL );
    for c2rec in c2(target) loop
     if c2rec.res = cl
      then
       htp.formselectoption( c2rec.disp,'SELECTED', cattributes=>'VALUE="' || c2rec.res || '"' );
      else
       htp.formselectoption( c2rec.disp,cattributes=>'VALUE="' || c2rec.res || '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    htp.formselectopen( 'P3' );
     if c1rec.expression = '=' then htp.formselectoption( '=','SELECTED'); else htp.formselectoption( '=' ); end if;
     if c1rec.expression = '<' then htp.formselectoption( '<','SELECTED'); else htp.formselectoption( '<' ); end if;
     if c1rec.expression = '>' then htp.formselectoption( '>','SELECTED'); else htp.formselectoption( '>' ); end if;
     if c1rec.expression = '<=' then htp.formselectoption( '<=','SELECTED'); else htp.formselectoption( '<=' ); end if;
     if c1rec.expression = '>=' then htp.formselectoption( '>=','SELECTED'); else htp.formselectoption( '>=' ); end if;
     if c1rec.expression = '<>' then htp.formselectoption( '<>','SELECTED'); else htp.formselectoption( '<>' ); end if;
     if c1rec.expression = 'IN' then htp.formselectoption( 'IN','SELECTED'); else htp.formselectoption( 'IN' ); end if;
     if c1rec.expression = 'NOT IN' then htp.formselectoption( 'NOT IN','SELECTED'); else htp.formselectoption( 'NOT IN' ); end if;
     if c1rec.expression = 'LIKE' then htp.formselectoption( 'LIKE','SELECTED'); else htp.formselectoption( 'LIKE' ); end if;
     if c1rec.expression = 'NOT LIKE' then htp.formselectoption( 'NOT LIKE','SELECTED'); else htp.formselectoption( 'NOT LIKE' ); end if;
     if c1rec.expression = 'IS NULL' then htp.formselectoption( 'IS NULL','SELECTED'); else htp.formselectoption( 'IS NULL' ); end if;
     if c1rec.expression = 'IS NOT NULL' then htp.formselectoption( 'IS NOT NULL','SELECTED'); else htp.formselectoption( 'IS NOT NULL' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext( 'P4', 30, 4000, c1rec.value ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P5', 20, 100, c1rec.apply_function ) || htf.nl ||
                   htf.formtext( 'P6', 20, 100, c1rec.extra_function_parm ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P7' );
     if c1rec.and_or = 'AND' then htp.formselectoption( 'AND','SELECTED'); else htp.formselectoption( 'AND' ); end if;
     if c1rec.and_or = 'OR' then htp.formselectoption( 'OR','SELECTED'); else htp.formselectoption( 'OR' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  end loop;

  for j in 1..5 loop
   htp.tablerowopen;
    htp.formhidden( 'P0', null );
    htp.tabledata( htf.formtext( 'P1', 5, 10, null ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    htp.formselectopen( 'P2' );
    htp.formselectoption( NULL );
    for c2rec in c2(target) loop
     htp.formselectoption( c2rec.disp,cattributes=>'VALUE="' || c2rec.res || '"' );
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    htp.formselectopen( 'P3' );
     htp.formselectoption( '=' );
     htp.formselectoption( '<' );
     htp.formselectoption( '>' );
     htp.formselectoption( '<=' );
     htp.formselectoption( '>=' );
     htp.formselectoption( '<>' );
     htp.formselectoption( 'IN' );
     htp.formselectoption( 'NOT IN' );
     htp.formselectoption( 'LIKE' );
     htp.formselectoption( 'NOT LIKE' );
     htp.formselectoption( 'IS NULL' );
     htp.formselectoption( 'IS NOT NULL' );
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext( 'P4', 30, 4000 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formtext( 'P5', 20, 100 ) || htf.nl ||
                   htf.formtext( 'P6', 20, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P7' );
     htp.formselectoption( 'AND' );
     htp.formselectoption( 'OR' );
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  end loop;

  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
   htp.tablerowopen;
    htp.tabledata( htf.formsubmit( 'ACTION', LNG4.AHC_TXT_778 ));
    htp.tabledata( htf.formsubmit( 'ACTION', LNG4.AHC_TXT_869 ));
   htp.tablerowclose;
  htp.tableclose;
  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'EDIT_QUERY_STATEMENT', errmsg=>sqlerrm);
end edit_query_statement;

procedure accept_edit_query_stmt(surl in varchar2, acid in integer, target in varchar2, qry in integer, action in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY )
as

 cursor c1 is select max(query_id) mx from userdefined_clause;
 cursor c2(qry integer) is select rowid from userdefined_clause where query_id = qry order by order_by;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 nmb		integer;
 cl		varchar2(100);
 sts		varchar2(100);
 mx		integer;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_EDIT_QUERY_STMT', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if qry is null
   then
    open c1;
    fetch c1 into c1rec;
    close c1;
    c1rec.mx := nvl(c1rec.mx,0) + 1;
    insert into userdefined_query(status_id,aid,usr_scr_id,query_id,next_usr_scr_id,order_by,if_or_else) values
     (null,acid,substr(target,2),c1rec.mx,null,null,'I');
   else
    c1rec.mx := qry;
  end if;

  for j in p0.first..p0.last loop
   begin nmb := to_number(p1(j)); exception when others then nmb := NULL; end;
   if p0(j) is null and p2(j) is null -- Do Nothing
    then
     null;
   elsif p0(j) is null and p2(j) is not null -- Insert New Workflow Query
    then
     insert into userdefined_clause(query_id,order_by,
       attribute_id,purchase_column,shopping_column,umo_column,
       expression,value,apply_function,extra_function_parm,and_or) values
      (c1rec.mx,nmb,
       decode(substr(p2(j),1,1),'A',to_number(substr(p2(j),2)),'M',to_number(substr(p2(j),2)), NULL),
       decode(substr(p2(j),1,1),'P',substr(p2(j),2),NULL),
       decode(substr(p2(j),1,1),'S',substr(p2(j),2),NULL),
       decode(substr(p2(j),1,1),'U',substr(p2(j),2),NULL),
       p3(j),p4(j),p5(j),p6(j),p7(j));
   elsif p0(j) is not null and p2(j) is null -- Delete
    then
     delete from userdefined_clause
      where
       query_id = c1rec.mx and
       order_by = p0(j);
   elsif p0(j) is not null and p2(j) is not null -- Update
    then
     update userdefined_clause
      set
       order_by = nmb,
       attribute_id = decode(substr(p2(j),1,1),'A',to_number(substr(p2(j),2)),'M',to_number(substr(p2(j),2)),NULL),
       purchase_column = decode(substr(p2(j),1,1),'P',substr(p2(j),2),NULL),
       shopping_column = decode(substr(p2(j),1,1),'S',substr(p2(j),2),NULL),
       umo_column = decode(substr(p2(j),1,1),'U',substr(p2(j),2),NULL),
       expression = p3(j),
       value = p4(j),
       apply_function = p5(j),
       extra_function_parm = p6(j),
       and_or = p7(j)
      where
       query_id = c1rec.mx and
       order_by = p0(j);
   end if;
  end loop;

  for c2rec in c2(c1rec.mx) loop
   nmb := c2%ROWCOUNT;
   update userdefined_clause
    set
     order_by = nmb
   where
    rowid = c2rec.rowid;
  end loop;

  commit;

  if action = 'Modify Workflow Query Clause'
   then
    edit_query_statement( surl, acid, target, c1rec.mx, LNG4.AHC_TXT_870 );
   else
    edit_query( surl, acid, target, null );
  end if;

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_EDIT_QUERY_STMT', errmsg=>sqlerrm);
end accept_edit_query_stmt;

procedure accept_edit_query( surl in varchar2, acid in integer, target in varchar2, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY )
as

 cursor c2 is select max(status_id) mx from userdefined_query;

 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		integer;
 vsts		integer;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_EDIT_QUERY', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  c2rec.mx := vsts;
  for j in p4.first..p4.last loop
   htp.p( p3(j) || '-' || p4(j) || '-' || p5(j)); htp.nl;
   begin nmb := nvl(to_number(p3(j)),999); exception when others then nmb := 999; end;
   if p4(j) is not null and p4(j) <> '0'
    then
     update userdefined_query
     set
      order_by = nmb,
      next_usr_scr_id = p5(j)
     where query_id = p4(j);
   elsif p4(j) is null -- Else Clause
    then
     update userdefined_query
     set
      next_usr_scr_id = p5(j)
     where status_id = c2rec.mx and
           query_id is null;
   elsif p4(j) = '0'
    then
     insert into userdefined_query(status_id,query_id,aid,usr_scr_id,order_by,if_or_else,next_usr_scr_id) values (vsts,null,acid,substr(target,2),null,'E',p5(j));
   end if;
  end loop;

  commit;
  edit_query(surl,acid,target,LNG5.EXT_TXT_340 );

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_WORKFLOW_TASK', errmsg=>sqlerrm, extdet=>' TARGET:' || target);
end accept_edit_query;

procedure user_defined_screen( surl in varchar2, acid in integer, tgroup in varchar2, called_from in varchar2, callid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY )
as

 cursor c1( acid integer, tgroup varchar2 ) is
  select display_name
  from novelty_definition nd, customer_meta_data_group cm
  where cm.aid = acid and
        cm.target_area = tgroup and
        cm.novelty_id = nd.novelty_id;

 c1rec		c1%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 button_found	boolean;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 defval		glbx.myarray;

begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'PBK.USER_DEFINED_SCREEN', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 -- Note: Hardcoded for keep_lhf as L
 glbx.main_title( surl, null, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>'L', finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 open c1(acid,tgroup);
 fetch c1 into c1rec;
 close c1;
 htp.title( c1rec.display_name );

 htp.formopen( 'pbk.accept_defined_screen', cattributes=>'name="navForm"' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'CALLED_FROM', called_from );
 htp.formhidden( 'CALLID', callid );
 htp.formhidden( 'TGROUP', tgroup );
 htp.formhidden( 'P1', NULL );
 htp.formhidden( 'P2', NULL );
 htp.formhidden( 'P3', NULL );
 for j in p1.first..p1.last loop
  htp.formhidden( 'P1', p1(j) );
  htp.formhidden( 'P2', p2(j) );
 end loop;
 for j in p3.first..p3.last loop
  htp.formhidden( 'P3', p3(j) );
 end loop;

 button_found := FALSE;
 if glbx.where_called( called_from ) = 1 -- Main
  then
   glbx.meta_prompt( surl, acid=>acid, ltype=>ltype, tgroup=>tgroup, v_umo=>callid, button_found=>button_found, default_names=>defval, default_values=>defval );
  else
   glbx.meta_prompt( surl, acid=>acid, ltype=>ltype, tgroup=>tgroup, v_umo=>NULL, button_found=>button_found, default_names=>defval, default_values=>defval );
 end if;

 if not button_found
  then
   htp.formsubmit( 'ACTION', LNG.SLD_TXT_087 );
 end if;

 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'PBK', 'USER_DEFINED_SCREEN', errmsg=>sqlerrm, extdet=>' TGROUP:' || tgroup);
end user_defined_screen;

procedure accept_defined_screen( surl in varchar2, acid in integer, tgroup in varchar2, called_from in varchar2, callid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, action in varchar2 default null, sectionMenu in varchar2 default null, pageMenu in varchar2 default null )
as

 cursor c1(screen_id integer, acid integer ) is select * from userdefined_query where usr_scr_id = screen_id and aid = acid;
 cursor c2(acid integer, tgroup varchar2 ) is select novelty_id from customer_meta_data_group where aid = acid and target_area = tgroup;
 cursor c3(nvid integer) is select * from novelty_definition where novelty_id = nvid;
 cursor c4(v_umo integer) is select * from umo where umo_id = v_umo;

 vp1		GLBX.MYARRAY;
 vp2		GLBX.MYARRAY;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 shoprec	shopping_basket%ROWTYPE;
 purchrec	purchase_order%ROWTYPE;
 umo_rec	umo%ROWTYPE;
 pfx		theme%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 profid		integer;
 stype		integer;
 sess_id	integer;
 sts		varchar2(100);
 scrid		integer;
 ctr		integer;
 next_scrid	integer;

begin
  glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'PBK.ACCEPT_DEFINED_SCREEN', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  scrid := substr(tgroup,2);
  open c1(scrid,acid);
  fetch c1 into c1rec;
  close c1;

    ctr := 1;
    for j in p1.first..p1.last loop
     if substr(p1(j),1,1) = 'S'
      then
       vp1(j) := substr(p1(j),2);
       vp2(j) := pagemenu;
      else
       vp1(j) := p1(j);
       vp2(j) := p2(ctr);
       ctr := ctr + 1;
     end if;
    end loop;

  glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchrec, voidrec );
  if c1rec.aid is not null
   then
    -- Need to calculate these values
    if called_from = 'MAIN'
     then
      open c4(callid);
      fetch c4 into umo_rec;
      close c4;
    end if;
    next_scrid := calculate_query(acid, tgroup, shoprec, purchrec, umo_rec, vp1, vp2, p3 );
   else
    next_scrid := 0;
  end if;
  next_scrid := nvl(next_scrid,0);

  if next_scrid = 0 -- Finish
   then
    open c2(acid,tgroup);
    fetch c2 into c2rec;
    close c2;
    if c2rec.novelty_id is not null
     then
      open c3( c2rec.novelty_id );
      fetch c3 into c3rec;
      close c3;

      for j in p1.first..p1.last loop
       if p1(j) is not null
        then
         insert into novelty_values(parm_type,parm1,parm2,parm3) values ('1',vp1(j),vp2(j),null);
       end if;
      end loop;

      for j in p3.first..p3.last loop
       if p3(j) is not null
        then
         insert into novelty_values(parm_type,parm1,parm2,parm3) values ('3',null,null,p3(j));
       end if;
      end loop;
      execute immediate 'begin ' || c3rec.program_name || '(surl=>:surl,acid=>:acid,called_from=>:called_from,callid=>:callid,first_parameter=>:first_parameter); end;'
       using surl, acid, called_from, callid,c3rec.first_parameter;
      return;

    end if;
    -- If we are here then we have nothing to do
    -- Need to put some smarts in to handle this situation
   else
    user_defined_screen(surl, acid, 'U' || next_scrid, called_from, callid, vp1, vp2, p3 );
  end if;

exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_DEFINED_SCREEN', errmsg=>sqlerrm, extdet=>' TGROUP:' || tgroup);
end accept_defined_screen;

function calculate_query( acid in integer, tgroup in varchar2, c1rec in SHOPPING_BASKET%ROWTYPE, c3rec in PURCHASE_ORDER%ROWTYPE, umo_rec in UMO%ROWTYPE, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY )
 return integer
as

 cursor c4(tgroup varchar2, acid integer) is select * from userdefined_query where aid=acid and usr_scr_id = to_number(substr(tgroup,2))  order by decode(if_or_else,'I',0,1),order_by;
 cursor c5(vqry integer) is select * from userdefined_clause where query_id = vqry order by order_by;
 cursor c6(v_umo integer, attrid integer) is select value from umo_attribute where umo_id = v_umo and attribute_id = attrid order by position_id;

 c4rec		c4%ROWTYPE;
 vl		varchar2(4000);
 if_clause	boolean;
 res_clause	boolean;
 cnt		integer;
 ctr		integer;
 lclause	varchar2(100);
 tmp		varchar2(4000);

 function extract_value( c5rec in c5%ROWTYPE )
  return varchar2
 as
  vl		varchar2(4000);
 begin
  if c5rec.attribute_id > 0
   then
    open c6(c1rec.phid,c5rec.attribute_id);
    fetch c6 into vl;
    close c6;
    return( vl );
  elsif c5rec.attribute_id < 0
   then

    for j in p1.first..p1.last loop
     if p1(j) = to_char(abs(c5rec.attribute_id))
      then
       return( p2(j) );
     end if;
    end loop;

    for j in p3.first..p3.last loop
     if substr(p3(j),1,1) = '['
      then
       if substr(p3(j),2,instr(p3(j),']')-2) = to_char(abs(c5rec.attribute_id))
        then
         return(substr(p3(j),instr(p3(j),']')-2));
       end if;
     end if;
    end loop;
    return( NULL );
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
    return( vl );
  end if;
  return( NULL );
 end extract_value;

begin
 for c4rec in c4(tgroup,acid) loop
  if c4rec.if_or_else = 'E' then return( c4rec.next_usr_scr_id ); end if;

  if_clause := TRUE;
  for c5rec in c5( c4rec.query_id ) loop
   vl := extract_value( c5rec );
   if c5rec.apply_function is not null
    then
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
    return( c4rec.next_usr_scr_id );
  end if;

 end loop;

 -- If we get here there is a problem as we shouldn't
 return(NULL);

exception
 when others
  then
   tmp := sqlerrm;
   return( NULL );
end calculate_query;

procedure copy_meta_screen( surl in varchar2, acid in integer, newacid in integer, target in varchar2 )
as

 cursor c1(phgid integer, acid integer, target in varchar2) is select * from customer_meta_data_group where aid = acid and target_area = target and aid in (select aid from customer_account where pid = phgid);

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 newid		integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PBK.COPY_META_SCREEN', iscust=>FALSE );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 for c1rec in c1(owner_id, acid, target) loop
  select s_meta_data_group.nextval into newid from dual;
  insert into customer_meta_data_group(aid,target_area,group_id,title,display_order,html_table,html_tabledata,novelty_id) values
   (newacid,target,newid,c1rec.title,c1rec.display_order,c1rec.html_table,c1rec.html_tabledata,c1rec.novelty_id);
  insert into customer_meta_data(meta_data_id,aid,attribute_id,group_id,edit_display,display_order,display_type,display_width,lov_checkbox_width,checkbox_enabled,title,purchase_column,shopping_column,umo_column,tablecell)
   select s_meta_data.nextval,newacid,attribute_id,newid,edit_display,display_order,display_type,display_width,lov_checkbox_width,checkbox_enabled,title,purchase_column,shopping_column,umo_column,tablecell
   from customer_meta_data
   where aid = acid and
         aid in (select aid from customer_account where pid = owner_id) and
         newacid in (select aid from customer_account where pid = owner_id) and
         group_id = c1rec.group_id;
 end loop;
 commit;
 edit_meta_screen(surl, acid, target, LNG5.EXT_TXT_458);
exception when others then
 glbx.error_details( 'PBK', 'COPY_META_SCREEN', errmsg=>sqlerrm);
end copy_meta_screen;

procedure userfee( surl varchar2, id integer, msg in varchar2 default null )
as

 cursor c1(id integer, phgid integer) is select * from user_fees uf where uf.spb = id and uf.spb in (select ppb.spb from phg_price_book ppb where ppb.spb = id and ppb.pid = phgid) order by order_by;
 cursor c2(phgid integer) is select spb,name from phg_price_book where pid = phgid order by name;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		char(1);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.USERFEEE', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, 'Manage User Fees',glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'O26',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg );end if;
  htp.formopen( 'pbk.accept_userfee' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ID', id );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold('Is Default'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold('Order By'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold('User Fee Code'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold('Category Text'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold('Price<BR>Adjuster<BR>Type'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold('Price<BR>Adjuster<BR>Number'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold('Display If<BR>Type Is'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold('Or<BR>Repeated Value'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold('Equal Value'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold('Use this Price Book<BR><I>Optional</I>'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;
   for c1rec in c1(id,owner_id) loop
   htp.tablerowopen;
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P1' );
     if c1rec.is_default = 'T' then htp.formselectoption( 'Yes', 'SELECTED', cattributes=>'VALUE="T"'); else htp.formselectoption( 'Yes', cattributes=>'VALUE="T"'); end if;
     if c1rec.is_default = 'F' then htp.formselectoption( 'No', 'SELECTED', cattributes=>'VALUE="F"'); else htp.formselectoption( 'No', cattributes=>'VALUE="F"'); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext('P2', 5, 10, c1rec.order_by),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.formtext('P3', 8, 40, c1rec.user_fee_code),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.formtext('P4', 30, 1000, c1rec.user_fee_text),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P5' );
     if nvl(c1rec.price_adjuster,'M') = 'M' then htp.formselectoption( 'Multiplier', 'SELECTED', cattributes=>'VALUE="M"'); else htp.formselectoption( 'Multiplier', cattributes=>'VALUE="M"'); end if;
     if c1rec.price_adjuster = 'F' then htp.formselectoption( 'Fixed Price', 'SELECTED', cattributes=>'VALUE="F"'); else htp.formselectoption( 'Fixed Price', cattributes=>'VALUE="F"'); end if;
     if c1rec.price_adjuster = 'A' then htp.formselectoption( 'Adjust Value by', 'SELECTED', cattributes=>'VALUE="A"'); else htp.formselectoption( 'Adjust Value by', cattributes=>'VALUE="A"'); end if;
     if c1rec.price_adjuster = 'I' then htp.formselectoption( 'Independent Price', 'SELECTED', cattributes=>'VALUE="I"'); else htp.formselectoption( 'Independent Price', cattributes=>'VALUE="I"'); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext('P6', 6, 20, c1rec.price_adjuster_value),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P7' );
     htp.formselectoption( NULL );
     if c1rec.display_when_value = 'ALL' then htp.formselectoption( 'ALL', 'SELECTED', cattributes=>'VALUE="ALL"'); else htp.formselectoption( 'ALL', cattributes=>'VALUE="ALL"'); end if;
     if c1rec.display_when_value = 'PHOTO' then htp.formselectoption( 'PHOTO', 'SELECTED', cattributes=>'VALUE="PHOTO"'); else htp.formselectoption( 'PHOTO', cattributes=>'VALUE="PHOTO"'); end if;
     if c1rec.display_when_value = 'DOCUMENT' then htp.formselectoption( 'DOCUMENT', 'SELECTED', cattributes=>'VALUE="DOCUMENT"'); else htp.formselectoption( 'DOCUMENT', cattributes=>'VALUE="DOCUMENT"'); end if;
     if c1rec.display_when_value = 'VIDEO' then htp.formselectoption( 'VIDEO', 'SELECTED', cattributes=>'VALUE="VIDEO"'); else htp.formselectoption( 'VIDEO', cattributes=>'VALUE="VIDEO"'); end if;
     if c1rec.display_when_value = 'AUDIO' then htp.formselectoption( 'AUDIO', 'SELECTED', cattributes=>'VALUE="AUDIO"'); else htp.formselectoption( 'AUDIO', cattributes=>'VALUE="AUDIO"'); end if;
     if c1rec.display_when_value = 'RELATIONAL' then htp.formselectoption( 'RELATIONAL', 'SELECTED', cattributes=>'VALUE="RELATIONAL"'); else htp.formselectoption( 'RELATIONAL', cattributes=>'VALUE="RELATIONAL"'); end if;
     if c1rec.display_when_value = 'BLUEPRINT' then htp.formselectoption( 'BLUEPRINT', 'SELECTED', cattributes=>'VALUE="BLUEPRINT"'); else htp.formselectoption( 'BLUEPRINT', cattributes=>'VALUE="BLUEPRINT"'); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P8' );
     htp.formselectoption( NULL );
     for j in 1..6 loop
      if c1rec.display_when_repeated = 'ATTRIBUTE' || to_char(j)
       then
        htp.formselectoption( 'ATTRIBUTE' || to_char(j), 'SELECTED', cattributes=>'VALUE="ATTRIBUTE' || to_char(j) || '"');
       else
        htp.formselectoption( 'ATTRIBUTE' || to_char(j), cattributes=>'VALUE="ATTRIBUTE' || to_char(j) || '"');
      end if;
     end loop;
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext('P9', 20, 1000, c1rec.display_when_equals),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P10' );
     htp.formselectoption( NULL );
     for c2rec in c2( owner_id ) loop
      if c2rec.spb = c1rec.lineitem_spb
       then
        htp.formselectoption( c2rec.name, 'SELECTED', cattributes=>'VALUE="' || c2rec.spb || '"');
       else
        htp.formselectoption( c2rec.name, cattributes=>'VALUE="' || c2rec.spb || '"');
      end if;
     end loop;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   end loop;

   for j in 1..5 loop
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P1' );
      htp.formselectoption( 'Yes', cattributes=>'VALUE="T"');
      htp.formselectoption( 'No', 'SELECTED', cattributes=>'VALUE="F"');
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext('P2', 5, 10),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.formtext('P3', 8, 40),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.formtext('P4', 30, 1000),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P5' );
      htp.formselectoption( 'Multiplier', 'SELECTED', cattributes=>'VALUE="M"');
      htp.formselectoption( 'Fixed Price', cattributes=>'VALUE="F"');
      htp.formselectoption( 'Adjust Value by', cattributes=>'VALUE="A"');
      htp.formselectoption( 'Independent Price', cattributes=>'VALUE="I"');
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext('P6', 6, 20),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P7' );
      htp.formselectoption( NULL );
      htp.formselectoption( 'ALL', cattributes=>'VALUE="ALL"');
      htp.formselectoption( 'PHOTO', cattributes=>'VALUE="PHOTO"');
      htp.formselectoption( 'DOCUMENT', cattributes=>'VALUE="DOCUMENT"');
      htp.formselectoption( 'VIDEO', cattributes=>'VALUE="VIDEO"');
      htp.formselectoption( 'AUDIO', cattributes=>'VALUE="AUDIO"');
      htp.formselectoption( 'RELATIONAL', cattributes=>'VALUE="RELATIONAL"');
      htp.formselectoption( 'BLUEPRINT', cattributes=>'VALUE="BLUEPRINT"');
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P8' );
     htp.formselectoption( NULL );
     for j in 1..6 loop
      htp.formselectoption( 'ATTRIBUTE' || to_char(j), cattributes=>'VALUE="ATTRIBUTE' || to_char(j) || '"');
     end loop;
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext('P9', 20, 1000),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formselectopen( 'P10' );
     htp.formselectoption( NULL );
     for c2rec in c2( owner_id ) loop
      htp.formselectoption( c2rec.name, cattributes=>'VALUE="' || c2rec.spb || '"');
     end loop;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   end loop;

  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, 'Modify User Fee Details' );
  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'USERFEE',errmsg=>sqlerrm);
end userfee;

procedure accept_userfee( surl varchar2, id integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY, p8 in GLBX.MYARRAY, p9 in GLBX.MYARRAY, p10 in GLBX.MYARRAY )
as

 cursor c1(id integer, phgid integer) is select * from user_fees uf where uf.spb = id and uf.spb in (select ppb.spb from phg_price_book ppb where ppb.spb = id and ppb.pid = phgid);

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		char(1);
 nmb		integer;
 nmb2		number;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_USERFEEE', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  delete from user_fees uf where uf.spb = id and uf.spb in (select ppb.spb from phg_price_book ppb where ppb.spb = id and ppb.pid = owner_id);
  for j in p1.first..p1.last loop
   begin nmb := to_number(p2(j)); exception when others then nmb := null; end;
   begin nmb2 := to_number(p6(j)); exception when others then nmb2 := null; end;
   if p4(j) is not null
    then
     insert into user_fees(spb,order_by,is_default,user_fee_code,user_fee_text,price_adjuster,price_adjuster_value,display_when_value,display_when_repeated,display_when_equals,lineitem_spb)
      values
     (id,nmb,p1(j),p3(j),p4(j),p5(j),nmb2,p7(j),p8(j),p9(j), p10(j));
   end if;
  end loop;
  commit;
  userfee(surl, id, 'User Fee Details Modified' );
exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_USERFEE',errmsg=>sqlerrm);
end accept_userfee;

procedure packprod( surl varchar2, id integer, msg in varchar2 default null )
as

 cursor c1(phgid integer, id integer) is select * from phg_price_book where pid = phgid and spb = id order by name;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		char(1);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.PACKPROD', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, 'Manage Packaged Products',glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'O27',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  open c1(owner_id, id );
  fetch c1 into c1rec;
  close c1;

  if msg is not null then glbx.header_msg( msg );end if;
  htp.formopen( 'pbk.accept_packprod' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ID', id );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold('When to Activate Package Product'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
    htp.formselectopen( 'P1' );
    if c1rec.call_location = 'N'
     then
      htp.formselectoption( 'Do not Enable (Disabled)','SELECTED', cattributes=>'VALUE="' || 'N'  || '"');
     else
      htp.formselectoption( 'Do not Enable (Disabled)',cattributes=>'VALUE="' || 'N'  || '"');
    end if;
    if c1rec.call_location = '1'
     then
      htp.formselectoption( '1. Must choose Package before displaying Thumbnails','SELECTED', cattributes=>'VALUE="' || '1'  || '"');
     else
      htp.formselectoption( '1. Must choose Package before displaying Thumbnails',cattributes=>'VALUE="' || '1'  || '"');
    end if;
    if c1rec.call_location = '2'
     then
      htp.formselectoption( '2. Can choose Package when viewing Thumbnails','SELECTED', cattributes=>'VALUE="' || '2'  || '"');
     else
      htp.formselectoption( '2. Can choose Package when viewing Thumbnails',cattributes=>'VALUE="' || '2'  || '"');
    end if;
    if c1rec.call_location = '3'
     then
      htp.formselectoption( '3. Must Choose at least one Package on Checkout','SELECTED', cattributes=>'VALUE="' || '3'  || '"');
     else
      htp.formselectoption( '3. Must Choose at least one Package on Checkout',cattributes=>'VALUE="' || '3'  || '"');
    end if;
    if c1rec.call_location = '4'
     then
      htp.formselectoption( 'Option 1 and 2','SELECTED', cattributes=>'VALUE="' || '4'  || '"');
     else
      htp.formselectoption( 'Option 1 and 2',cattributes=>'VALUE="' || '4'  || '"');
    end if;
    if c1rec.call_location = '5'
     then
      htp.formselectoption( 'Option 2 and 3','SELECTED', cattributes=>'VALUE="' || '5'  || '"');
     else
      htp.formselectoption( 'Option 2 and 3',cattributes=>'VALUE="' || '5'  || '"');
    end if;
    if c1rec.call_location = '6'
     then
      htp.formselectoption( 'Option 1 and 3','SELECTED', cattributes=>'VALUE="' || '6'  || '"');
     else
      htp.formselectoption( 'Option 1 and 3',cattributes=>'VALUE="' || '6'  || '"');
    end if;
    if c1rec.call_location = '7'
     then
      htp.formselectoption( 'Option 1, 2 and 3','SELECTED', cattributes=>'VALUE="' || '7'  || '"');
     else
      htp.formselectoption( 'Option 1, 2 and 3',cattributes=>'VALUE="' || '7'  || '"');
    end if;
    htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Package Help Text'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
    htp.formtextareaopen( 'P2', 6, 50 );
     htp.p( replace(replace(replace(c1rec.package_help,'"','&#34;'),'<','&lt;'),'>','&gt;') );
    htp.formtextareaclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, 'Modify Packaged Product Details' );
  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'PACKPROD',errmsg=>sqlerrm);
end packprod;

procedure accept_packprod( surl varchar2, id integer, p1 in varchar2, p2 in varchar2 )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_PACKPROD', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  update phg_price_book
   set
    call_location = p1,
    package_help = p2
  where
   spb = id and
   pid = owner_id;
  commit;
  packprod(surl, id, 'Package Product Details Modified' );
exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_PACKPROD',errmsg=>sqlerrm);
end accept_packprod;

procedure package_details( surl varchar2, id in integer, pbit in integer, msg in varchar2 default null )
as

 cursor c1(phgid integer, id integer, pbit integer) is select * from phg_price_item where spb = id and ppi = pbit and exists (select 'x' from phg_price_book where pid = phgid and spb = id);
 cursor c2(phgid integer, id integer, pbit integer) is select * from item_package_product where spb = id and ppi = pbit and exists (select 'x' from phg_price_book where pid = phgid and spb = id);

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		char(1);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.PACKAGE_DETAILS', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  open c1(owner_id, id, pbit);
  fetch c1 into c1rec;
  if c1%NOTFOUND then close c1; return; end if;
  close c1;
  pfx := glbx.photo_lf(owner_id);
  glbx.main_title( surl, 'Manage Packaged Products' || ':' || c1rec.name,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'O27',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  open c2(owner_id, id, pbit );
  fetch c2 into c2rec;
  close c2;

  if msg is not null then glbx.header_msg( msg );end if;
  htp.formopen( 'pbk.accept_package_details' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ID', id );
  htp.formhidden( 'PBIT', pbit );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold('Package Name'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold(c1rec.name),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Package Cost'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold(to_char( c1rec.charge, LNG.MONEY_FORMAT)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Minimum Number of Images<BR>Min is 1'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','MIN_NUMBER') || htf.formtext( 'P2', 10, 20, to_char( c2rec.min_number)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Maximum Number of Images<BR>Max is 10'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','MAX_NUMBER') || htf.formtext( 'P2', 10, 20, to_char( c2rec.max_number)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Images Included in Price'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formhidden( 'P1', 'IMAGES_INCLUDED_IN_PRICE' );
     htp.formselectopen( 'P2' );
     if c2rec.images_included_in_price = 'T' then htp.formselectoption( 'Yes', 'SELECTED', cattributes=>'VALUE="' || 'T' || '"' ); else htp.formselectoption( 'Yes', cattributes=>'VALUE="' || 'T' || '"' ); end if;
     if c2rec.images_included_in_price = 'F' then htp.formselectoption( 'No', 'SELECTED', cattributes=>'VALUE="' || 'F' || '"' ); else htp.formselectoption( 'No', cattributes=>'VALUE="' || 'F' || '"' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;

  htp.nl;
  htp.bold( 'Image #1' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold('Instruction'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','INSTRUCTION_1') || htf.formtext( 'P2', 30, 100, c2rec.instruction_1),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Handling Rule'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formhidden( 'P1', 'IMAGE_1_OPTION' );
     htp.formselectopen( 'P2' );
     if c2rec.image_1_option = 'A' then htp.formselectoption( 'Any Image Accepted', 'SELECTED', cattributes=>'VALUE="' || 'A' || '"' ); else htp.formselectoption( 'Any Image Accepted', cattributes=>'VALUE="' || 'A' || '"' ); end if;
     if c2rec.image_1_option = 'F' then htp.formselectoption( 'Must be this Film Type', 'SELECTED', cattributes=>'VALUE="' || 'F' || '"' ); else htp.formselectoption( 'Must be this Film Type', cattributes=>'VALUE="' || 'F' || '"' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Film Type'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','IMAGE_1_FILMTYPE') || htf.formtext( 'P2', 30, 100, c2rec.image_1_filmtype),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  htp.tableclose;

  htp.nl;
  htp.bold( 'Image #2' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold('Instruction'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','INSTRUCTION_2') || htf.formtext( 'P2', 30, 100, c2rec.instruction_2),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Handling Rule'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formhidden( 'P1', 'IMAGE_2_OPTION' );
     htp.formselectopen( 'P2' );
     if c2rec.image_2_option = 'A' then htp.formselectoption( 'Any Image Accepted', 'SELECTED', cattributes=>'VALUE="' || 'A' || '"' ); else htp.formselectoption( 'Any Image Accepted', cattributes=>'VALUE="' || 'A' || '"' ); end if;
     if c2rec.image_2_option = 'F' then htp.formselectoption( 'Must be this Film Type', 'SELECTED', cattributes=>'VALUE="' || 'F' || '"' ); else htp.formselectoption( 'Must be this Film Type', cattributes=>'VALUE="' || 'F' || '"' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Film Type'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','IMAGE_2_FILMTYPE') || htf.formtext( 'P2', 30, 100, c2rec.image_2_filmtype),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  htp.tableclose;

  htp.nl;
  htp.bold( 'Image #3' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold('Instruction'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','INSTRUCTION_3') || htf.formtext( 'P2', 30, 100, c2rec.instruction_3),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Handling Rule'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formhidden( 'P1', 'IMAGE_3_OPTION' );
     htp.formselectopen( 'P2' );
     if c2rec.image_3_option = 'A' then htp.formselectoption( 'Any Image Accepted', 'SELECTED', cattributes=>'VALUE="' || 'A' || '"' ); else htp.formselectoption( 'Any Image Accepted', cattributes=>'VALUE="' || 'A' || '"' ); end if;
     if c2rec.image_3_option = 'F' then htp.formselectoption( 'Must be this Film Type', 'SELECTED', cattributes=>'VALUE="' || 'F' || '"' ); else htp.formselectoption( 'Must be this Film Type', cattributes=>'VALUE="' || 'F' || '"' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Film Type'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','IMAGE_3_FILMTYPE') || htf.formtext( 'P2', 30, 100, c2rec.image_3_filmtype),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  htp.tableclose;

  htp.nl;
  htp.bold( 'Image #4' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold('Instruction'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','INSTRUCTION_4') || htf.formtext( 'P2', 30, 100, c2rec.instruction_4),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Handling Rule'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formhidden( 'P1', 'IMAGE_4_OPTION' );
     htp.formselectopen( 'P2' );
     if c2rec.image_4_option = 'A' then htp.formselectoption( 'Any Image Accepted', 'SELECTED', cattributes=>'VALUE="' || 'A' || '"' ); else htp.formselectoption( 'Any Image Accepted', cattributes=>'VALUE="' || 'A' || '"' ); end if;
     if c2rec.image_4_option = 'F' then htp.formselectoption( 'Must be this Film Type', 'SELECTED', cattributes=>'VALUE="' || 'F' || '"' ); else htp.formselectoption( 'Must be this Film Type', cattributes=>'VALUE="' || 'F' || '"' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Film Type'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','IMAGE_4_FILMTYPE') || htf.formtext( 'P2', 30, 100, c2rec.image_4_filmtype),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  htp.tableclose;

  htp.nl;
  htp.bold( 'Image #5' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold('Instruction'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','INSTRUCTION_5') || htf.formtext( 'P2', 30, 100, c2rec.instruction_5),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Handling Rule'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formhidden( 'P1', 'IMAGE_5_OPTION' );
     htp.formselectopen( 'P2' );
     if c2rec.image_5_option = 'A' then htp.formselectoption( 'Any Image Accepted', 'SELECTED', cattributes=>'VALUE="' || 'A' || '"' ); else htp.formselectoption( 'Any Image Accepted', cattributes=>'VALUE="' || 'A' || '"' ); end if;
     if c2rec.image_5_option = 'F' then htp.formselectoption( 'Must be this Film Type', 'SELECTED', cattributes=>'VALUE="' || 'F' || '"' ); else htp.formselectoption( 'Must be this Film Type', cattributes=>'VALUE="' || 'F' || '"' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Film Type'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','IMAGE_5_FILMTYPE') || htf.formtext( 'P2', 30, 100, c2rec.image_5_filmtype),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  htp.tableclose;

  htp.nl;
  htp.bold( 'Image #6' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold('Instruction'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','INSTRUCTION_6') || htf.formtext( 'P2', 30, 100, c2rec.instruction_6),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Handling Rule'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formhidden( 'P1', 'IMAGE_6_OPTION' );
     htp.formselectopen( 'P2' );
     if c2rec.image_6_option = 'A' then htp.formselectoption( 'Any Image Accepted', 'SELECTED', cattributes=>'VALUE="' || 'A' || '"' ); else htp.formselectoption( 'Any Image Accepted', cattributes=>'VALUE="' || 'A' || '"' ); end if;
     if c2rec.image_6_option = 'F' then htp.formselectoption( 'Must be this Film Type', 'SELECTED', cattributes=>'VALUE="' || 'F' || '"' ); else htp.formselectoption( 'Must be this Film Type', cattributes=>'VALUE="' || 'F' || '"' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Film Type'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','IMAGE_6_FILMTYPE') || htf.formtext( 'P2', 30, 100, c2rec.image_6_filmtype),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;

  htp.bold( 'Image #7' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold('Instruction'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','INSTRUCTION_7') || htf.formtext( 'P2', 30, 100, c2rec.instruction_7),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Handling Rule'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formhidden( 'P1', 'IMAGE_7_OPTION' );
     htp.formselectopen( 'P2' );
     if c2rec.image_7_option = 'A' then htp.formselectoption( 'Any Image Accepted', 'SELECTED', cattributes=>'VALUE="' || 'A' || '"' ); else htp.formselectoption( 'Any Image Accepted', cattributes=>'VALUE="' || 'A' || '"' ); end if;
     if c2rec.image_7_option = 'F' then htp.formselectoption( 'Must be this Film Type', 'SELECTED', cattributes=>'VALUE="' || 'F' || '"' ); else htp.formselectoption( 'Must be this Film Type', cattributes=>'VALUE="' || 'F' || '"' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Film Type'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','IMAGE_7_FILMTYPE') || htf.formtext( 'P2', 30, 100, c2rec.image_7_filmtype),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  htp.tableclose;

  htp.nl;
  htp.bold( 'Image #8' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold('Instruction'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','INSTRUCTION_8') || htf.formtext( 'P2', 30, 100, c2rec.instruction_8),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Handling Rule'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formhidden( 'P1', 'IMAGE_8_OPTION' );
     htp.formselectopen( 'P2' );
     if c2rec.image_8_option = 'A' then htp.formselectoption( 'Any Image Accepted', 'SELECTED', cattributes=>'VALUE="' || 'A' || '"' ); else htp.formselectoption( 'Any Image Accepted', cattributes=>'VALUE="' || 'A' || '"' ); end if;
     if c2rec.image_8_option = 'F' then htp.formselectoption( 'Must be this Film Type', 'SELECTED', cattributes=>'VALUE="' || 'F' || '"' ); else htp.formselectoption( 'Must be this Film Type', cattributes=>'VALUE="' || 'F' || '"' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Film Type'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','IMAGE_8_FILMTYPE') || htf.formtext( 'P2', 30, 100, c2rec.image_8_filmtype),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  htp.tableclose;

  htp.nl;
  htp.bold( 'Image #9' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold('Instruction'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','INSTRUCTION_9') || htf.formtext( 'P2', 30, 100, c2rec.instruction_9),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Handling Rule'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formhidden( 'P1', 'IMAGE_9_OPTION' );
     htp.formselectopen( 'P2' );
     if c2rec.image_9_option = 'A' then htp.formselectoption( 'Any Image Accepted', 'SELECTED', cattributes=>'VALUE="' || 'A' || '"' ); else htp.formselectoption( 'Any Image Accepted', cattributes=>'VALUE="' || 'A' || '"' ); end if;
     if c2rec.image_9_option = 'F' then htp.formselectoption( 'Must be this Film Type', 'SELECTED', cattributes=>'VALUE="' || 'F' || '"' ); else htp.formselectoption( 'Must be this Film Type', cattributes=>'VALUE="' || 'F' || '"' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Film Type'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','IMAGE_9_FILMTYPE') || htf.formtext( 'P2', 30, 100, c2rec.image_9_filmtype),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  htp.tableclose;

  htp.nl;
  htp.bold( 'Image #10' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold('Instruction'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','INSTRUCTION_10') || htf.formtext( 'P2', 30, 100, c2rec.instruction_10),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Handling Rule'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
     htp.formhidden( 'P1', 'IMAGE_10_OPTION' );
     htp.formselectopen( 'P2' );
     if c2rec.image_10_option = 'A' then htp.formselectoption( 'Any Image Accepted', 'SELECTED', cattributes=>'VALUE="' || 'A' || '"' ); else htp.formselectoption( 'Any Image Accepted', cattributes=>'VALUE="' || 'A' || '"' ); end if;
     if c2rec.image_10_option = 'F' then htp.formselectoption( 'Must be this Film Type', 'SELECTED', cattributes=>'VALUE="' || 'F' || '"' ); else htp.formselectoption( 'Must be this Film Type', cattributes=>'VALUE="' || 'F' || '"' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Film Type'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.formhidden('P1','IMAGE_10_FILMTYPE') || htf.formtext( 'P2', 30, 100, c2rec.image_10_filmtype),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  htp.tableclose;

  htp.nl;
  htp.formsubmit( null, 'Modify Packaged Product Details' );
  htp.formclose;
  htp.nl;
  htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PBK', 'PACKAGE_DETAILS',errmsg=>sqlerrm);
end package_details;

procedure accept_package_details( surl varchar2, id integer, pbit in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 cursor c2(phgid integer, id integer, pbit integer) is select * from item_package_product where spb = id and ppi = pbit and exists (select 'x' from phg_price_book where pid = phgid and spb = id);

 crec		item_package_product%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PBK.ACCEPT_PACKAGE_DETAILS', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  open c2(owner_id,id,pbit);
  fetch c2 into crec;
  if c2%NOTFOUND then insert into item_package_product(spb,ppi) values (id,pbit); end if;
  close c2;

  for j in p1.first..p1.last loop
   if p1(j) = 'IMAGES_INCLUDED_IN_PRICE' then crec.images_included_in_price := p2(j); end if;
   if p1(j) = 'MIN_NUMBER' then begin crec.min_number := p2(j); exception when others then crec.min_number := 1; end; end if;
   if p1(j) = 'MAX_NUMBER' then begin crec.max_number := p2(j); exception when others then crec.max_number := 1; end; end if;
   if p1(j) = 'IMAGE_1_FILMTYPE' then crec.image_1_filmtype := p2(j); end if;
   if p1(j) = 'IMAGE_2_FILMTYPE' then crec.image_2_filmtype := p2(j); end if;
   if p1(j) = 'IMAGE_3_FILMTYPE' then crec.image_3_filmtype := p2(j); end if;
   if p1(j) = 'IMAGE_4_FILMTYPE' then crec.image_4_filmtype := p2(j); end if;
   if p1(j) = 'IMAGE_5_FILMTYPE' then crec.image_5_filmtype := p2(j); end if;
   if p1(j) = 'IMAGE_6_FILMTYPE' then crec.image_6_filmtype := p2(j); end if;
   if p1(j) = 'IMAGE_7_FILMTYPE' then crec.image_7_filmtype := p2(j); end if;
   if p1(j) = 'IMAGE_8_FILMTYPE' then crec.image_8_filmtype := p2(j); end if;
   if p1(j) = 'IMAGE_9_FILMTYPE' then crec.image_9_filmtype := p2(j); end if;
   if p1(j) = 'IMAGE_10_FILMTYPE' then crec.image_10_filmtype := p2(j); end if;
   if p1(j) = 'IMAGE_1_OPTION' then crec.image_1_option := p2(j); end if;
   if p1(j) = 'IMAGE_2_OPTION' then crec.image_2_option := p2(j); end if;
   if p1(j) = 'IMAGE_3_OPTION' then crec.image_3_option := p2(j); end if;
   if p1(j) = 'IMAGE_4_OPTION' then crec.image_4_option := p2(j); end if;
   if p1(j) = 'IMAGE_5_OPTION' then crec.image_5_option := p2(j); end if;
   if p1(j) = 'IMAGE_6_OPTION' then crec.image_6_option := p2(j); end if;
   if p1(j) = 'IMAGE_7_OPTION' then crec.image_7_option := p2(j); end if;
   if p1(j) = 'IMAGE_8_OPTION' then crec.image_8_option := p2(j); end if;
   if p1(j) = 'IMAGE_9_OPTION' then crec.image_9_option := p2(j); end if;
   if p1(j) = 'IMAGE_10_OPTION' then crec.image_10_option := p2(j); end if;
   if p1(j) = 'INSTRUCTION_1' then crec.instruction_1 := p2(j); end if;
   if p1(j) = 'INSTRUCTION_2' then crec.instruction_2 := p2(j); end if;
   if p1(j) = 'INSTRUCTION_3' then crec.instruction_3 := p2(j); end if;
   if p1(j) = 'INSTRUCTION_4' then crec.instruction_4 := p2(j); end if;
   if p1(j) = 'INSTRUCTION_5' then crec.instruction_5 := p2(j); end if;
   if p1(j) = 'INSTRUCTION_6' then crec.instruction_6 := p2(j); end if;
   if p1(j) = 'INSTRUCTION_7' then crec.instruction_7 := p2(j); end if;
   if p1(j) = 'INSTRUCTION_8' then crec.instruction_8 := p2(j); end if;
   if p1(j) = 'INSTRUCTION_9' then crec.instruction_9 := p2(j); end if;
   if p1(j) = 'INSTRUCTION_10' then crec.instruction_10 := p2(j); end if;
  end loop;

  update item_package_product
   set
    images_included_in_price = crec.images_included_in_price,
    min_number         = nvl(crec.min_number,1),
    max_number         = nvl(crec.max_number,1),
    image_1_filmtype   = crec.image_1_filmtype,
    image_1_option     = crec.image_1_option,
    instruction_1      = crec.instruction_1,
    image_2_filmtype   = crec.image_2_filmtype,
    image_2_option     = crec.image_2_option,
    instruction_2      = crec.instruction_2,
    image_3_filmtype   = crec.image_3_filmtype,
    image_3_option     = crec.image_3_option,
    instruction_3      = crec.instruction_3,
    image_4_filmtype   = crec.image_4_filmtype,
    image_4_option     = crec.image_4_option,
    instruction_4      = crec.instruction_4,
    image_5_filmtype   = crec.image_5_filmtype,
    image_5_option     = crec.image_5_option,
    instruction_5      = crec.instruction_5,
    image_6_filmtype   = crec.image_6_filmtype,
    image_6_option     = crec.image_6_option,
    instruction_6      = crec.instruction_6,
    image_7_filmtype   = crec.image_7_filmtype,
    image_7_option     = crec.image_7_option,
    instruction_7      = crec.instruction_7,
    image_8_filmtype   = crec.image_8_filmtype,
    image_8_option     = crec.image_8_option,
    instruction_8      = crec.instruction_8,
    image_9_filmtype   = crec.image_9_filmtype,
    image_9_option     = crec.image_9_option,
    instruction_9      = crec.instruction_9,
    image_10_filmtype  = crec.image_10_filmtype,
    image_10_option    = crec.image_10_option,
    instruction_10     = crec.instruction_10
   where spb = id and
         ppi = pbit and
         exists (select 'x' from phg_price_book where pid = owner_id and spb = id);
   commit;
  package_details(surl, id, pbit, 'Package Product Details Modified' );
exception when others then
 glbx.error_details( 'PBK', 'ACCEPT_PACKAGE_DETAILS',errmsg=>sqlerrm);
end accept_package_details;

end pbk;

/
