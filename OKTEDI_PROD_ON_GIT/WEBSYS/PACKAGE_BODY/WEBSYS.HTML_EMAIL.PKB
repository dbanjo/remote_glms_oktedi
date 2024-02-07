CREATE OR REPLACE package body WEBSYS.html_email
as

function base64( nmb integer ) return varchar2;
function conv_3bytes( fbytes varchar2 ) return varchar2;
procedure dump_blob( c in out utl_smtp.connection, img in blob );
procedure send_image(c in out utl_smtp.connection, v_umo in integer, show_image_type in varchar2 );
procedure pline(c in out utl_smtp.connection, bfr in varchar2 );
procedure send_the_mail_smtp(p_from in varchar2, p_to in varchar2, p_subj in varchar2, imgarrs in GLBX.MYARRAY, html_arr in GLBX.MYARRAY, show_image_type in varchar2 default 'THUMBNAIL' );

function base64( nmb integer ) return varchar2
 as
 begin
  return( substr('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/',nvl(nmb,0)+1,1) );
end base64;

function conv_3bytes( fbytes varchar2 ) return varchar2
 as
  nmb 	integer;
  x	integer;
  y	integer;
  z	integer;
  a	integer; --4867657
 begin
  nmb := (65536*ascii(substr(fbytes,1,1))) + (256*ascii(substr(fbytes,2,1))) + ascii(substr(fbytes,3,1));
  x := trunc(nmb/262144); -- 18
  y := trunc((nmb - (x*262144))/4096);
  z := trunc(((nmb - (x*262144) - (y*4096)))/64);
  a := nmb - (x*262144) - (y*4096) - (z*64);
  return( base64(x) || base64(y) || base64(z) || base64(a)); -- || ':' || to_char(x) || '-' || to_char(y) || '-' || to_char(z) || '-' || to_char(a)
end conv_3bytes;

procedure dump_blob( c in out utl_smtp.connection, img in blob )
as

 v_count	integer;
 c_imgchunk	binary_integer;
 v_imgchunk	binary_integer;
 v_buffer 	raw(255);
 contentlength  integer;
 bfr		varchar2(2000);
 xbufr		varchar2(2000);

begin

-- replace with call to C prog
-- dump blob to file
-- convert file
-- read file in and pline it

 if dbms_lob.getlength(img) = 0 then return; end if;

  c_imgchunk := 57;
  v_imgchunk := 57;
  v_count := 0;
  begin
   loop
    dbms_lob.read(img,v_imgchunk,(v_count*c_imgchunk)+1,v_buffer);
    v_count := v_count + 1;
    bfr := NULL;
    xbufr := sys.utl_raw.cast_to_varchar2(v_buffer);
    for j in 1..19 loop
     bfr := bfr || conv_3bytes(substr(xbufr,((j-1)*3)+1,3));
    end loop;
    pline( c, bfr );
   end loop;
  exception
   when no_data_found then null;
   when others
    then return;
  end;
  bfr := NULL;
  xbufr := sys.utl_raw.cast_to_varchar2(v_buffer);
  if mod(length(xbufr),3) = 1 then xbufr := xbufr || chr(0) || chr(0);
  elsif mod(length(xbufr),3) = 2 then xbufr := xbufr || chr(0);
  end if;
  for j in 1..length(trunc(length(v_buffer)/3)) loop
   bfr := bfr || conv_3bytes(substr(xbufr,((j-1)*3)+1,3));
  end loop;
  pline( c, bfr );
exception
 when others then return;
end dump_blob;

procedure send_image(c in out utl_smtp.connection, v_umo in integer, show_image_type in varchar2)
as

 cursor c1(v_umo integer) is select * from umo where umo_id = v_umo;

 c1rec	c1%ROWTYPE;

begin
 open c1(v_umo);
 fetch c1 into c1rec;
 close c1;

 pline( c,null);
 pline( c, '------=_UMO_ID_' || '3D2D4C15C6C7EF3943C2EE26' ); -- to_char(v_umo)
 pline( c,'Content-Type: ' || c1rec.photo_thumbnail.mimetype || '; name="' || c1rec.extras.film_name || '"' );
 pline( c,'Content-Transfer-Encoding: base64' );
 --pline( c,'Content-Description:' );
 pline( c,'Content-ID: <' || '3D2D4C15C6C7EF3943C2EE26_' || to_char(v_umo) || '>' );
 pline( c,null);

 if show_image_type = 'THUMBNAIL' and c1rec.umo_type = 'PHOTO'
  then
   dump_blob( c, c1rec.photo_thumbnail.source.localdata );
 elsif show_image_type = 'MASTER' and c1rec.umo_type = 'PHOTO'
  then
   dump_blob( c, c1rec.photo_master.source.localdata );
 elsif show_image_type = 'ORIGINAL' and c1rec.umo_type = 'PHOTO'
  then
   dump_blob( c, c1rec.photo_original.source.localdata );
 elsif show_image_type = 'MASTER' and c1rec.umo_type = 'DOCUMENT'
  then
   dump_blob( c, c1rec.doc_body );
 elsif show_image_type = 'THUMBNAIL' and c1rec.umo_type = 'AUDIO'
  then
   dump_blob( c, c1rec.audio_thumbnail.source.localdata );
 elsif show_image_type = 'MASTER' and c1rec.umo_type = 'AUDIO'
  then
   dump_blob( c, c1rec.audio_original.source.localdata );
 elsif show_image_type = 'MASTER' and c1rec.umo_type = 'VIDEO'
  then
   dump_blob( c, c1rec.video_original.source.localdata );
 elsif show_image_type = 'MASTER' and c1rec.umo_type = 'BLUEPRINT'
  then
   dump_blob( c, c1rec.blueprint_obj.localdata );
 elsif show_image_type = 'THUMBNAIL' and c1rec.umo_type = 'BLUEPRINT'
  then
   dump_blob( c, c1rec.blueprint_obj.online_version );
 end if;

end send_image;

procedure pline(c in out utl_smtp.connection, bfr in varchar2 )
as
begin
 utl_smtp.write_data(c, utl_tcp.CRLF || bfr);
end pline;

procedure send_the_mail_smtp(p_from in varchar2, p_to in varchar2, p_subj in varchar2, imgarrs in GLBX.MYARRAY, html_arr in GLBX.MYARRAY, show_image_type in varchar2 default 'THUMBNAIL' )
as

    l_template      utl_file.file_type;
    l_output2       utl_file.file_type;
    p_body	    varchar2(4000);
    c		    utl_smtp.connection;
    at_step	    varchar2(20);
    x		    integer;
    ctr		    integer;
    lastctr	    integer;
    disphtml	    varchar2(32767);

    procedure send_header(c in out utl_smtp.connection, name in varchar2, header in varchar2, nline in boolean default TRUE) as
     begin
      if nline
       then
        utl_smtp.write_data(c,name || ':' || header || utl_tcp.CRLF );
       else
        utl_smtp.write_data(c,name || ':' || header );
      end if;
    end;

 begin
      --dbms_output.put_line(glbx.extract_master_parameter('SMTP_SERVER'));
      at_step := 'Step1';
      c := utl_smtp.open_connection(glbx.extract_master_parameter('SMTP_SERVER')); -- SMTP Server
      at_step := 'Step2';
      utl_smtp.helo(c,glbx.extract_master_parameter('SMTP_SERVER') );
      at_step := 'Step2a';
      utl_smtp.mail(c,'<' || p_from || '>');
      at_step := 'Step3';

      if instr(p_to,',') > 0
       then
        x := 1;
        lastctr := 0;
        loop
         ctr := instr(p_to,',',1,x);
         if ctr = 0
          then
           utl_smtp.rcpt(c,'<' || trim(substr(p_to,lastctr+1)) || '>');
           exit;
         end if;
         utl_smtp.rcpt(c,'<' || trim(substr(p_to,lastctr+1,(ctr-lastctr)-1)) || '>');
         x := x + 1;
         lastctr := ctr;
        end loop;
       else
        utl_smtp.rcpt(c,'<' || trim(p_to) || '>');
      end if;

      at_step := 'Step4';
      utl_smtp.open_data(c);
      at_step := 'Step5';
      send_header(c, 'From','"Sender" <' || p_from || '>');
      at_step := 'Step6';
      send_header(c, 'To','"Recipient" <' || replace(p_to,',','><') || '>');
      at_step := 'Step7';
      send_header(c, 'Subject',p_subj,FALSE);
      at_step := 'Step8';
      pline(c,'MIME-Version: 1.1');

      -- Display Mime Type Headers
      pline(c,'Content-Type: multipart/related; boundary="----=_UMO_ID_' || '3D2D4C15C6C7EF3943C2EE26' || '"'); --imgarrs(j)
      pline(c, null);
      pline(c, '------=_UMO_ID_' || '3D2D4C15C6C7EF3943C2EE26'); -- imgarrs(j)

      pline(c,'Content-Type: text/html; charset="iso-8859-1"');
      pline(c,'Content-Transfer-Encoding: quoted-printable');
      pline(c, null);

      for k in html_arr.first..html_arr.last loop
       disphtml := html_arr(k);
       for j in imgarrs.first..imgarrs.last loop
        disphtml := replace(disphtml,'<PICTION_IMAGE ' || imgarrs(j) || '>','3D2D4C15C6C7EF3943C2EE26_' || imgarrs(j));
       end loop;
       pline(c,disphtml);
      end loop;

      for j in REVERSE imgarrs.first..imgarrs.last loop
       send_image(c, imgarrs(j), show_image_type);
      end loop;

      pline( c, '------=_UMO_ID_' || '3D2D4C15C6C7EF3943C2EE26' || '--' ); -- to_char(v_umo)

      at_step := 'Step9';
      utl_smtp.close_data(c);
      utl_smtp.quit(c);

  exception
   when others
    then
     dbms_output.put_line( at_step || ':' || sqlerrm );
end send_the_mail_smtp;

procedure test
as

imgarrs		glbx.myarray;
html_arr	glbx.myarray;

begin

 imgarrs(1) := '52741';
 imgarrs(2) := '52742';
 imgarrs(3) := '52743';
 imgarrs(4) := '52743';
 html_arr(1) := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
<TITLE>My Test</TITLE>
<META http-equiv=3DContent-Type = content=3Dtext/html;CHARSET=3Diso-8859-1>
<META content=3D"MSHTML 5.50.4134.100" name=3DGENERATOR>
</HEAD>
<BODY vLink=3Dblack aLink=3Dblack link=3Dblack bgColor=3Dwhite>
<DIV><FONT face=3DArial color=3D#0000ff size=3D2></FONT>&nbsp;</DIV>
<DIV class=3DOutlookMessageHeader dir=3Dltr align=3Dleft><BR>
<A href=3D"http://www.mylink.com/">
<IMG height=3D384=20 alt=3D"My Test Image"=20 src=3D"cid:<PICTION_IMAGE 52741>" width=3D600 align=3Dbottom = border=3D1>
</A>
<BR>
<IMG height=3D384=20 alt=3D"My Test Image"=20 src=3D"cid:<PICTION_IMAGE 52742>" width=3D600 align=3Dbottom = border=3D1>
<BR>
<IMG height=3D384=20 alt=3D"My Test Image"=20 src=3D"cid:<PICTION_IMAGE 52743>" width=3D600 align=3Dbottom = border=3D1>
</DIV>
</BODY>
</HTML>';
 send_the_mail_smtp( 'marcel@xor.com.au','dbinsight@YAHOO.COM','Piction Images Test 1', imgarrs, html_arr );
 dbms_output.put_line( 'Sent' );

end test;

procedure test2
as

cursor c1 is select * from umo where umo_scene_id = 203 and umo_id between 301343 and 301345;
cursor c2(acid integer) is select * from theme where theme_name = (select theme_name from customer_account where aid = acid);

imgarrs		glbx.myarray;
html_arr	glbx.myarray;
pfx		theme%ROWTYPE;
thepage	        htp.htbuf_arr;
irows		integer;
ctr		integer;

begin
 open c2(3326);
 fetch c2 into pfx;
 close c2;
 html_arr(1) := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">';
 html_arr(2) := htf.htmlopen || '<HEAD><META http-equiv=Content-Type = content=text/html;CHARSET=iso-8859-1></HEAD><BODY><CENTER>' ||
         htf.header(3, 'Piction Images', 'CENTER' ) || htf.tableopen(cattributes=>'cellspacing=10 border=1') || htf.tablerowopen;
 for c1rec in c1 loop
  imgarrs(c1%ROWCOUNT) := c1rec.umo_id;
  ctr := c1%ROWCOUNT+2;
  html_arr(ctr) := '<TD VALIGN="BOTTOM" ALIGN="CENTER">';

  html_arr(ctr) := html_arr(ctr) || '<IMG WIDTH=' || c1rec.photo_thumbnail.width || ' HEIGHT=' || c1rec.photo_thumbnail.height ||
                  ' alt="' || c1rec.extras.film_name || '" src="cid:<PICTION_IMAGE ' || c1rec.umo_id || '>" valign=bottom border=1>';

  html_arr(ctr) := html_arr(ctr) || htf.nl || htf.italic(c1rec.extras.film_name) || '</TD>';

 end loop;
 html_arr(ctr+1) := htf.tablerowclose || htf.tableclose || '</CENTER></BODY>' || htf.htmlclose;
 for j in html_arr.first..html_arr.last loop
  html_arr(j) := replace(replace(html_arr(j),'=','=3D'),'  ',' =20');
 end loop;

send_the_mail_smtp( 'marcel@xor.com.au','dbinsight@yahoo.com','Piction Images Test2', imgarrs, html_arr );

end test2;

procedure test_html_send
as
begin
 htp.htmlopen;
  htp.header( 2, 'Test Send HTML Email Message', 'CENTER' );

  htp.bold( 'Step 1: Build HTML file and put it in the mail template directory' ); htp.nl;
  htp.bold( 'Step 2: Replace all reference to the image src to be displayed with cid:&lt;PICTION_IMAGE umo_id &gt;' ); htp.nl;
  htp.italic( 'e.g. &lt;IMG WIDTH=30 HEIGHT=30 SRC="cid:&lt;PICTION_IMAGE 42&gt;" &gt;' ); htp.nl;
  htp.nl;
  htp.bold( 'Step 3: Enter in the name of the HTML file in mail template' );
  htp.formopen( 'html_email.accept_test_html_send' );
  htp.formtext( 'P1', 30, 100, 'test.html' );
  htp.nl;
  htp.bold( 'Step 4: Enter in the FROM email address' );
  htp.formtext( 'P2', 30, 100, 'info@piction.com' );
  htp.nl;
  htp.bold( 'Step 5: Enter in the TO email address (can be comma separated multiple address)' );
  htp.formtext( 'P3', 30, 4000, 'marcel@piction.com' );
  htp.nl;
  htp.bold( 'Step 6: Enter in the Subject Line' );
  htp.formtext( 'P4', 30, 100, 'Test Email Send' );
  htp.nl;
  htp.formsubmit( null, 'Send it' );
  htp.formclose;

 htp.htmlclose;
end test_html_send;

procedure accept_test_html_send( p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 )
as

 l_terms        utl_file.file_type;
 p_body		varchar2(4000);
 html		varchar2(32767);
 imgarrs	glbx.myarray;
 ctr		integer;
 umid		integer;
 x		integer;
 y		integer;
 html_arr	glbx.myarray;

begin

l_terms := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), p1, 'r' );
ctr := 1;
   loop
     begin
      utl_file.get_line(l_terms,p_body);
      html_arr(ctr) := p_body;
     exception
      when others
       then exit;
     end;
     ctr := ctr + 1;
   end loop;
utl_file.fclose( l_terms );

ctr := 1;
htp.bold( 'Finding Images in UMO Table' ); htp.nl;

for k in html_arr.first..html_arr.last loop
 loop
  x := instr(html_arr(k),'PICTION_IMAGE',1,ctr);
  if x = 0 then exit; end if;
  y := x + length('PICTION_IMAGE');
  x := instr(html_arr(k),'>',y,1);
  htp.bold( ctr || ':' || substr(html_arr(k),y+1,(x-y)-1) ); htp.nl;
  umid := to_number(substr(html_arr(k),y+1,(x-y)-1));
  imgarrs(ctr) := umid;
  ctr := ctr + 1;
  exit when ctr > 1000;
 end loop;
end loop;

 for j in html_arr.first..html_arr.last loop
  html_arr(j) := replace(replace(html_arr(j),'=','=3D'),'  ',' =20');
 end loop;
 send_the_mail_smtp( p2,p3,p4, imgarrs, html_arr );
 htp.bold( 'Sent to ' || p3 || ' with subject ' || p4 );

exception
 when others then htp.p( sqlerrm ); htp.nl;
end accept_test_html_send;

procedure purchase_order_send( surl in varchar2, acid in integer )
as

 cursor c1(sts varchar2) is select status_priority_id from workflow_state_options where work_state = 0 and order_option = sts;
 cursor c2(phgid integer) is select * from photographer where pid = phgid;
 cursor c3(vpoid integer) is select phid,film_name from shopping_basket where poid = vpoid order by shopping_id;

 c2rec		c2%ROWTYPE;
 cusrec		CUSTOMER_ACCOUNT%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	THEME_TYPES%ROWTYPE;
 purchord 	PURCHASE_ORDER%ROWTYPE;
 voidrec	ORDER_STYLE%ROWTYPE;
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 ltype		varchar2(100);
 nmb1		integer;
 nmb2		integer;
 imgarrs	glbx.myarray;
 html		varchar2(32767);
 html_arr	glbx.myarray;
 ctr		integer;

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'HTML_EMAIL.PURCHASE_ORDER_SEND' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 glbx.get_all_order_details(sess_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 -- Make sure allowed to download originals
-- if voidrec.download_auto_email_web = 'F' then return; end if;

 -- Make sure the customer has supplied and email
 if purchord.contact_email is null then return; end if;

 -- Make sure status is at least at ordered
 open c1('Ordered');
 fetch c1 into nmb1;
 close c1;
 open c1(purchord.status);
 fetch c1 into nmb2;
 close c1;
 if nmb2 < nmb1 then return; end if;

 open c2(purchord.pid);
 fetch c2 into c2rec;
 close c2;

 html_arr(1) := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">';
 html_arr(1) := html_arr(1) || htf.htmlopen || '<HEAD><META http-equiv=Content-Type = content=text/html;CHARSET=iso-8859-1></HEAD><BODY><CENTER>' ||
                htf.header(3, LNG.CST_TXT_099 || purchord.poid, 'CENTER' ) || htf.nl;
 html_arr(1) := html_arr(1) || htf.tableopen( cattributes=>'cellpadding=4 cellspacing=1 rules="NONE" frame="HSIDES,VSIDES" border=1' ) || htf.tablerowopen || '<TD>';
 html_arr(1) := html_arr(1) || htf.bold( c2rec.business_name ) || htf.nl || htf.nl || htf.italic(c2rec.abn_number) || htf.nl || c2rec.contact_street || htf.nl || c2rec.contact_suburb ||
                htf.nl || c2rec.contact_city || htf.nl || c2rec.contact_pcode || htf.nl || htf.nl || c2rec.contact_email || htf.nl || c2rec.work_phone;
 html_arr(1) := html_arr(1) || '</TD>' || htf.tablerowclose || htf.tableclose || htf.nl;
 html_arr(1) := html_arr(1) || htf.italic( 'Depending on your email client you can either right mouse click and save the image, or save the image as an attachment') || htf.nl;

 for c3rec in c3(purchord.poid) loop
  ctr := c3%ROWCOUNT+1;
  imgarrs(c3%ROWCOUNT) := c3rec.phid;
  html_arr(ctr) := '<IMG alt="' || c3rec.film_name || '" src="cid:<PICTION_IMAGE ' || c3rec.phid || '>" border=1>' || htf.nl || htf.bold(c3rec.film_name) || htf.nl || htf.nl;
 end loop;

 html_arr(ctr+1) := htf.nl || '</CENTER></BODY>' || htf.htmlclose;

 for j in html_arr.first..html_arr.last loop
  html_arr(j) := replace(replace(html_arr(j),'=','=3D'),'  ',' =20');
 end loop;

 send_the_mail_smtp( c2rec.contact_email,purchord.contact_email,LNG.CST_TXT_099 || purchord.poid, imgarrs, html_arr, 'MASTER' ); -- xxx adjust for sending original

exception when others then
 glbx.error_details( 'HTML_EMAIL', 'PURCHASE_ORDER_SEND',null,null,errmsg=>sqlerrm,extdet=>'LTYPE:' || ltype);
end purchase_order_send;

procedure accept_email_lightbox(surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in varchar2, acid in integer default null, lbox in varchar2, lighthdr in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, action in varchar2 )
as

 cursor c1(sess_id integer, lighthdr integer) is
  select um.umo_id,photo_thumbnail,note,um.extras
  from umo um, lightbox l
  where l.umo_id = um.umo_id and
        l.sessid = sess_id and
        nvl(l.lightid,0) = nvl(lighthdr,0)
  order by um.umo_id;

 cursor c2(lighthdr integer) is select name from lightbox_header where lightid = lighthdr;
 cursor c3(acid integer, ltype varchar2) is select contact_email from customer_contact where aid=acid and login_type = ltype;
 cursor c4(phgid integer) is select contact_email from photographer where pid = phgid;
 cursor c5(sess_id integer) is select guest_email from login_session where sessid = sess_id;

 c2rec		c2%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 imgarrs	glbx.myarray;
 html_arr	glbx.myarray;
 ctr		integer;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts , 'S', progcalled=>'CST.ACCEPT_EMAIL_LIGHTBOX');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );

if action = LNG5.EXT_TXT_246
 then
  cst.mng_lightbox(surl, footer_api, left_api_parm, start_from, display_detail, acid );
  return;
end if;

if p1 is null
 then
   cst.mng_lightbox(surl, footer_api, left_api_parm, start_from, display_detail, acid, LNG4.AHC_TXT_449);
   return;
end if;

open c2( lighthdr );
fetch c2 into c2rec;
close c2;


 html_arr(1) := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">';
 html_arr(2) := htf.htmlopen || '<HEAD><META http-equiv=Content-Type = content=text/html;CHARSET=iso-8859-1></HEAD><BODY><CENTER>' ||
                htf.header(3, nvl(c2rec.name,LNG5.EXT_TXT_244), 'CENTER' ) ||
                htf.italic( p2 ) || htf.nl ||
                htf.tableopen(cattributes=>'cellspacing=10 border=1') ||
                htf.tablerowopen;

 ctr := 0;
 for c1rec in c1(owner_id,lighthdr) loop
  ctr := c1%ROWCOUNT + 2;
  if mod(c1%ROWCOUNT,5) = 0
   then
    html_arr(ctr) := htf.tablerowclose || htf.tablerowopen;
   else
    html_arr(ctr) := NULL;
  end if;

  imgarrs(c1%ROWCOUNT) := c1rec.umo_id;
  html_arr(ctr) := html_arr(ctr) || '<TD VALIGN="TOP" ALIGN="CENTER">';

  html_arr(ctr) := html_arr(ctr) || '<IMG WIDTH=' || c1rec.photo_thumbnail.width || ' HEIGHT=' || c1rec.photo_thumbnail.height ||
                  ' alt="' || c1rec.extras.film_name || '" src="cid:<PICTION_IMAGE ' || c1rec.umo_id || '>" valign=bottom border=1>';

  html_arr(ctr) := html_arr(ctr) || htf.nl || htf.italic(c1rec.extras.film_name) || htf.nl || htf.italic(c1rec.note) || '</TD>';

 end loop;

 html_arr(ctr+1) := htf.tablerowclose || htf.tableclose || '</CENTER></BODY>' || htf.htmlclose;

 for j in html_arr.first..html_arr.last loop
  html_arr(j) := replace(replace(html_arr(j),'=','=3D'),'  ',' =20');
 end loop;

 send_the_mail_smtp( nvl(p3,glbx.extract_master_parameter('MAIL_FROM')),p1,nvl(c2rec.name,LNG5.EXT_TXT_244), imgarrs, html_arr );

 cst.mng_lightbox(surl, footer_api, left_api_parm, start_from, display_detail, acid, lbox || ' ' || LNG5.EXT_TXT_248 || ' ' || p1);

exception when others then
 glbx.error_details( 'HTML_EMAIL', 'ACCEPT_EMAIL_LIGHTBOX',vaid=>acid,errmsg=>sqlerrm,extdet=>'LEFT_API_PARM:' || left_api_parm);
end accept_email_lightbox;

procedure add_email_log(v_disp_type in varchar2, v_template in varchar2, v_mail_file in varchar2, v_mail_from in varchar2, v_mail_to in varchar2, v_mail_subject in varchar2, v_is_sms in varchar2, v_at_step in varchar2, v_error in varchar2)
as
 s_mail_to	varchar2(4000);
begin
 s_mail_to := substr(v_mail_to,1,4000);
 insert into email_log(date_created,disp_type,template,mail_file,mail_from,mail_to,mail_subject,is_sms,at_step,error)
  values
   (sysdate,v_disp_type,v_template,v_mail_file,v_mail_from,s_mail_to,v_mail_subject,v_is_sms,v_at_step,v_error);
 commit;
end add_email_log;

function send_the_mail_smtp(p_from in varchar2, p_to in varchar2, p_subj in varchar2, blb in blob, fnm in varchar2 default null )
 return boolean
as

    l_template      utl_file.file_type;
    l_output2       utl_file.file_type;
    p_body	    varchar2(4000);
    c		    utl_smtp.connection;
    at_step	    varchar2(20);
    x		    integer;
    ctr		    integer;
    currj	    integer;
    lastctr	    integer;
    disphtml	    varchar2(32767);

    procedure send_header(c in out utl_smtp.connection, name in varchar2, header in varchar2, nline in boolean default TRUE) as
     begin
      if nline
       then
        utl_smtp.write_data(c,name || ':' || header || utl_tcp.CRLF );
       else
        utl_smtp.write_data(c,name || ':' || header );
      end if;
    end;

 begin
      --dbms_output.put_line(glbx.extract_master_parameter('SMTP_SERVER'));
      at_step := 'Step1';
      c := utl_smtp.open_connection(glbx.extract_master_parameter('SMTP_SERVER')); -- SMTP Server
      at_step := 'Step2';
      utl_smtp.helo(c,glbx.extract_master_parameter('SMTP_SERVER') );
      at_step := 'Step2a';
      utl_smtp.mail(c,'<' || p_from || '>');
      at_step := 'Step3';

      if instr(p_to,',') > 0
       then
        x := 1;
        lastctr := 0;
        loop
         ctr := instr(p_to,',',1,x);
         if ctr = 0
          then
           utl_smtp.rcpt(c,'<' || trim(substr(p_to,lastctr+1)) || '>');
           exit;
         end if;
         utl_smtp.rcpt(c,'<' || trim(substr(p_to,lastctr+1,(ctr-lastctr)-1)) || '>');
         x := x + 1;
         lastctr := ctr;
        end loop;
       else
        utl_smtp.rcpt(c,'<' || trim(p_to) || '>');
      end if;

      at_step := 'Step4';
      utl_smtp.open_data(c);
      at_step := 'Step5';
      send_header(c, 'From','"Sender" <' || p_from || '>');
      at_step := 'Step6';
      send_header(c, 'To','"Recipient" <' || replace(p_to,',','><') || '>');
      at_step := 'Step7';
      send_header(c, 'Subject',p_subj,FALSE);
      at_step := 'Step8';
      pline(c,'MIME-Version: 1.1');

      -- Display Mime Type Headers
      pline(c,'Content-Type: multipart/related; boundary="----=_UMO_ID_' || '3D2D4C15C6C7EF3943C2EE26' || '"');
      pline(c, null);
      pline(c, '------=_UMO_ID_' || '3D2D4C15C6C7EF3943C2EE26');

      pline( c,'Content-Type: ' || 'application/x-zip-compressed' || '; name="' || nvl(fnm,'download.zip') || '"' );
      pline( c,'Content-Transfer-Encoding: base64' );
      pline( c,'Content-ID: ' || '3D2D4C15C6C7EF3943C2EE26_BLOB'  );
      pline( c,null);
      dump_blob( c, blb );


      pline( c, '------=_UMO_ID_' || '3D2D4C15C6C7EF3943C2EE26' || '--' ); -- to_char(v_umo)

      at_step := 'Step9';
      utl_smtp.close_data(c);
      utl_smtp.quit(c);
      add_email_log('EMAIL SEND',glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || glbx.extract_master_parameter('SMTP_SERVER'),'Image Name:' || fnm,p_from,p_to,p_subj,'F','SMTP Send:' || at_step,null);
      return( TRUE );

  exception
   when others
    then
      add_email_log('ERROR ON SEND', 'UMO ID:' || currj || '-' || glbx.extract_master_parameter('SMTP_SERVER'),'Image Name:' || fnm,p_from,p_to,p_subj,'F','SMTP Send Error:' || at_step,sqlerrm);
      return( FALSE );
end send_the_mail_smtp;

procedure create_dir( fdirname in varchar2, floc in varchar2 )
as
 cursor c1( floc varchar2 ) is select directory_name from all_directories where directory_path = floc;
 c1rec   c1%ROWTYPE;
begin
 open c1( floc );
 fetch c1 into c1rec;
 if c1%FOUND
  then
   close c1;
   return;
 end if;
 close c1;

 execute immediate 'create or replace directory ' || fdirname || ' as ''' || floc || '''';
end create_dir;

function retrieve_physical_original( fnm in varchar2, blb in out blob )
 return boolean
as

 vfdir		varchar2(100);
 load_file	bfile;
 obj_length	integer;

begin
 create_dir( 'ZIPLOC', glbx.extract_master_parameter('MAIL_OUTPUT_DIR'));

 load_file := bfilename( 'ZIPLOC', fnm );

 dbms_lob.fileopen( load_file, dbms_lob.file_readonly );
 obj_length := dbms_lob.getlength(load_file);
 dbms_lob.loadfromfile( blb, load_file, obj_length );
 dbms_lob.fileclose(load_file);
 commit;
 return( TRUE );

exception
 when others then
  return( FALSE );
end retrieve_physical_original;

procedure zipsend( gcode	 in GLBX.MYARRAY,
  		gparam	 in GLBX.MYARRAY,
  		infile	 in varchar2,
		p_to     in varchar2,
                p_subj   in varchar2 default NULL,
                p_from   in varchar2 default NULL,
                p_cc     in varchar2 default NULL,
                p_bcc    in varchar2 default NULL,
                is_sms   in boolean default FALSE,
                is_report in boolean default FALSE,
                ltype    in varchar2 default null,
                own_id   in integer default null,
                extension in varchar2 default null,
                is_attachment in boolean default FALSE,
                scode in varchar2 default null,
                v_pid in integer default null,
                v_aid in integer default null,
                v_profile_id in integer default null)
is
 blb	blob;
begin
 dbms_lob.createtemporary( blb, FALSE);
 -- Load the Zip File
 --glbx.dbg( 'a:' || infile );
 --glbx.dbg( 'b:' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') );
 if retrieve_physical_original(infile,blb)
  then
   if send_the_mail_smtp( p_from, p_to, infile, blb, infile) then null; end if;
 end if;

 begin dbms_lob.freetemporary(blb); exception when others then null; end;
end zipsend;

end html_email;

/
