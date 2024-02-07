CREATE OR REPLACE package body WEBSYS.adm
as

 WIN_CTR 		INTEGER;
 MAX_PARALLEL_LD	INTEGER := 100; -- 100 seems like a good number to work with

 function getprm( val in varchar2, ky in varchar2 ) return varchar2;
 function randstring return varchar2;
 function new_window return varchar2;
 function findparm( vload_id integer, p1 in varchar2 ) return varchar2;
 function findparm3( vload_id integer, p3 in varchar2 ) return varchar2;

 procedure acct_master( surl in varchar2, msg in varchar2 default null );
 procedure create_photographer( surl in varchar2, vid in integer, un in varchar2, pw in varchar2, bnm in varchar2, plid in varchar2, ttype in varchar2, sts out varchar2, newid out integer );
 procedure create_mfc( surl in varchar2, un in varchar2, pw in varchar2, bnm in varchar2, plid in varchar2, ttype in varchar2, fpriv in varchar2, sts out varchar2, newid out integer );
 procedure confirm_delete( surl in varchar2, phgid in integer );
 procedure confirm_delete_mfc( surl in varchar2, manid in integer );
 procedure grouping( surl in varchar2, nme in integer, open_utl in boolean default true );
 procedure xml_load( surl in varchar2, vdir in varchar2, filename varchar2, delete_exists in boolean default TRUE, retval out varchar2, ignore_parent in boolean default FALSE  );
 procedure dump_slide( surl in varchar2, l_output in out utl_file.file_type, c2rec in SLIDE_MASTER%ROWTYPE, c3rec in SLIDE_DETAILS%ROWTYPE, photo_id in integer, shrink in integer default 1, sldtype in varchar2, dumpurl in varchar2);
 procedure calc_slide( surl in varchar2, c2rec in slide_master%ROWTYPE, c3rec in slide_details%ROWTYPE, l_output in out utl_file.file_type, sldtype in varchar2, p1_k in varchar2 );
 procedure disp_menu( surl in varchar2, acct in integer, ttl in varchar2 );
 procedure extract_tag( surl in varchar2, bfr in varchar2, objtype in varchar2, tagout out varchar2, tagval out varchar2, tagresult out varchar2, ismeta out boolean, debug in varchar2 );
 procedure disp_menu_old( surl varchar2, acct in integer, ttl in varchar2 );
 procedure notify_load_completed(surl in varchar2, acid in integer, vdir in varchar2, numb_loaded in integer );
 procedure calc_scene( acid in integer, directory in varchar2, scene_id in out integer, original_path in varchar2, debug in char, incalloncreate in char );
 procedure process_securepay( data in GLBX.MYARRAY );

 procedure image_load_load( surl varchar2, phgid in integer, acid in integer, usr in varchar2, cprog in boolean );
 procedure image_load_attach( surl varchar2, phgid in integer, acid in integer, usr in varchar2, cprog in boolean );
 procedure image_load_meta( surl varchar2, phgid in integer, acid in integer, usr in varchar2, cprog in boolean );
 procedure load_images( surl in varchar2, vload_id in integer, runfrom in varchar2, c1rec in phg_batch_upload%ROWTYPE, p_j in integer default null, p_rsess in integer default null, parallel_range_from in integer default null, parallel_range_to in integer default null);
 procedure load_attach( surl in varchar2, vload_id in integer, runfrom in varchar2, c1rec in phg_batch_upload%ROWTYPE  );
 procedure load_meta( surl in varchar2, vload_id in integer, runfrom in varchar2, c1rec in phg_batch_upload%ROWTYPE  );
 procedure followlnk( pk_umoid in out integer, debug in char );
 procedure autorotate_image(surl in varchar2, v_umo in integer, c1rec in phg_batch_upload%ROWTYPE );
 procedure virage_index( surl in varchar2, acid in integer );
 procedure context_index(surl in varchar2, acid in integer );
 procedure adobe_tnail(surl in varchar2, acid in integer );
 procedure create_directory_images(surl in varchar2, acid in integer );

procedure test_page( id in varchar2, msg in varchar2 default null )
as
begin
 if nvl(id,'x') <> DECS.PW_RESET then htp.htmlopen; htp.htmlclose; return; end if; -- Security Level 1

 htp.htmlopen;
  htp.print('<BODY BACKGROUND="' || DECS.IMAGE_LOCATION || 'site_specific/' || glbx.extract_master_parameter('LOGIN_PAGE_BACKGROUND') || '">');
  htp.title( LNG4.AHC_TXT_489 );
  if msg is not null
   then
    glbx.header_msg( msg );
  end if;
 htp.p( '<CENTER>' );
 htp.nl;
 htp.nl;
 htp.formopen( 'adm.accept_test_page' );
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=2 ' || GLBX.TABLE_BACKGROUND );
   htp.tablerowopen;
     htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'site_specific/' || glbx.extract_master_parameter('LOGIN_PAGE_IMG1'), cattributes=>'BORDER=0'),cattributes=>GLBX.QUERY_BACKGROUND );
     htp.tabledata( htf.bold(LNG3.ADM_TXT_001),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG3.ADM_TXT_002),cattributes=>GLBX.QUERY_BACKGROUND );
     htp.tabledata( htf.formtext( 'P1', 40, 100 ),cattributes=>GLBX.QUERY_BACKGROUND );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG3.ADM_TXT_003),cattributes=>GLBX.QUERY_BACKGROUND );
     htp.tabledata( htf.formpassword( 'P2', 40, 100 ),cattributes=>GLBX.QUERY_BACKGROUND );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'site_specific/' || glbx.extract_master_parameter('LOGIN_PAGE_IMG2'),cattributes=>'BORDER=0'),cattributes=>GLBX.QUERY_BACKGROUND );
     htp.p( '<TD ' || GLBX.QUERY_BACKGROUND || ' ALIGN="CENTER" valign="MIDDLE">' );
     htp.formsubmit(null, LNG3.ADM_TXT_005 );
     htp.p( '</TD>' );
   htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'TEST_PAGE', errmsg=>sqlerrm, extdet=>null);
end test_page;

procedure accept_test_page( p1 in varchar2, p2 in varchar2 )
as
 -- cursor c1 is select admin_pw,admin_pw_attempts,password_attempts,password_expires,password_expiry_days from master_piction;
 cursor c2(acct varchar2) is select acct_id,acct_name,admin_pw,failed_logins,password_expires,acct_role,restrict_to_ip_address from admin_acct where acct_name = acct;
 cursor c8(hostip varchar2) is select 'x' from track_ip_address where hostip like replace(ip_address,'*','%');

 -- c1rec		c1%ROWTYPE;
 admin_pw	varchar2(100);
 admin_pw_att	varchar2(100);
 password_att	varchar2(100);
 password_exp	varchar2(100);
 password_exp_d	varchar2(100);
 c2rec		c2%ROWTYPE;
 c8rec		c8%ROWTYPE;
 pw		varchar2(100);
 surl		varchar2(100);
 pw_attempts	integer;
 id		integer;
 hostip		varchar2(100);
 restrict_ip	varchar2(100);

 procedure home_page( err in varchar2 default null)
 as
 begin
     begin hostip := owa_util.get_cgi_env( 'REMOTE_ADDR' ); exception when others then hostip := 'UNKNOWN'; end;
     insert into invalid_access_attempt(username,password,ip_address,job,date_access) values (p1,p2,hostip,null,sysdate);
     commit;
     if glbx.extract_master_parameter('LOGIN_PAGE_ERROR') = 'TRUE'
      then
       test_page( DECS.PW_RESET, nvl(err,LNG.GLB_TXT_005) );
     else
       htp.htmlopen;
       htp.p( 'P1-' || p1 ); htp.nl;
       htp.p( 'P2-' || p2 ); htp.nl;
       if err is not null then htp.p( err ); htp.nl; end if;
       htp.nl;
       htp.p( LNG3.ADM_TXT_006 );
       htp.nl;
       htp.htmlclose;
     end if;
 end home_page;

begin
 admin_pw := glbx.extract_master_parameter('ADMIN_PW');
 admin_pw_att := glbx.extract_master_parameter('ADMIN_PW_ATTEMPTS');
 password_att := glbx.extract_master_parameter('PASSWORD_ATTEMPTS');
 password_exp := glbx.extract_master_parameter('PASSWORD_EXPIRES');
 password_exp_d := glbx.extract_master_parameter('PASSWORD_EXPIRY_DAYS');
 restrict_ip := glbx.extract_master_parameter('ADMIN_IPRESTRICT');

 if upper(p1) = DECS.ADMIN_USERNAME
  then
   c2rec.acct_id := 0;
   c2rec.acct_name := DECS.ADMIN_USERNAME;
   c2rec.admin_pw := admin_pw;
   c2rec.password_expires := to_date(password_exp,LNG.MASK);
   c2rec.acct_role := NULL;
   c2rec.failed_logins := to_number(admin_pw_att);
   c2rec.restrict_to_ip_address := restrict_ip;
 else
   open c2(upper(p1));
   fetch c2 into c2rec;
   if c2%NOTFOUND
    then
     close c2;
     home_page;
     return;
   else
    close c2;
   end if;
 end if;


 if nvl(c2rec.admin_pw,'x') <> nvl( glbx.encrypt(upper(p2),special_key=>DECS.ADMIN_ENCRYPT_KEY), 'y' )
  then
   if upper(p1) = DECS.ADMIN_USERNAME
    then
     -- update master_piction set admin_pw_attempts = nvl(admin_pw_attempts,0) + 1 ;
     update master_parameters set parm_value = to_char(nvl(to_number(parm_value),0) + 1) where parm_name = 'ADMIN_PW_ATTEMPTS';
    else
     update admin_acct set failed_logins = nvl(failed_logins,0) + 1  where acct_id = c2rec.acct_id;
   end if;
   home_page;
   return;
 end if;

   -- Check IP Address is Restricted
   hostip := owa_util.get_cgi_env( 'REMOTE_ADDR' );
   --open c7;
   --fetch c7 into c7rec;
   --close c7;
   if glbx.extract_master_parameter('IP_ADDRESS_NORESTRICT') = 'TRUE'
    then
     open c8( hostip );
     fetch c8 into c8rec;
     if c8%FOUND
      then
       close c8;
       home_page;
       return;
     end if;
     close c8;
    else
     open c8( hostip );
     fetch c8 into c8rec;
     if c8%NOTFOUND
      then
       close c8;
       home_page;
       return;
     end if;
     close c8;
   end if;

 -- Check to see if the Admin account has been restricted to only be accessed from certain addresses
 if c2rec.restrict_to_ip_address is not null
  then
   if hostip not like replace(c2rec.restrict_to_ip_address,'*','%')
    then
      home_page( LNG5.EXT_TXT_012 );
      return;
   end if;
 end if;

 if (upper(p1) = DECS.ADMIN_USERNAME) and
    (admin_pw_att is not null) and
    (to_number(admin_pw_att) > to_number(password_att))
  then
   home_page;
   return;
end if;

if (upper(p1) <> DECS.ADMIN_USERNAME) and
    (admin_pw_att is not null) and
    (c2rec.failed_logins > to_number(password_att))
  then
   home_page;
   return;
end if;

 -- Create Session Record
 -- select s_login_session.nextval into id from dual;
 if upper(p1) = DECS.ADMIN_USERNAME
  then
   -- update master_piction set admin_pw_attempts = 0;
   update master_parameters set parm_value = '0' where parm_name = 'ADMIN_PW_ATTEMPTS';
   insert into audit_master_parameters(parm_name,date_updated,old_value,new_value,sessid) values ( 'ADMIN_PW_ATTEMPTS', sysdate, null, '0', 0 );
  else
   update admin_acct set failed_logins = 0 where acct_id = c2rec.acct_id;
 end if;

 id := glbx.get_random_sessionid;

   surl := rpad(to_char(id),12,'Z') || randstring;
   insert into login_session(login_type,sessid,aid,date_created,date_updated,call_ctr, browser, ip_address, securl)
     values ('ADMIN', id, c2rec.acct_id, sysdate, sysdate, 1, substr(owa_util.get_cgi_env( 'HTTP_USER_AGENT'),1,100), owa_util.get_cgi_env( 'REMOTE_ADDR'), surl );
   commit;

if  (c2rec.password_expires is not null) and
    (c2rec.password_expires < sysdate )
 then
  htp.htmlopen;
   htp.header( 3, LNG2.PBK_TXT_126, 'CENTER' );
   htp.formopen( 'adm.accept_change_password' );
   htp.formhidden( 'SURL',  glbx.rndsurl(surl));
   htp.formhidden( 'ACCT', c2rec.acct_id );
   htp.tableopen( cattributes=>'cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
   htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.GLB_TXT_076 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c2rec.acct_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   if c2rec.acct_id = 0
    then
     htp.formhidden( 'P1', null );
    else
     htp.tablerowopen;
      htp.tabledata(htf.bold( LNG.GLB_TXT_117 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.formpassword('P1',40, 100, null ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
   htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_020 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formpassword('P2',40, 100, null ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.GLB_TXT_105 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formpassword('P3',40, 100, null ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formhidden( 'P4', c2rec.acct_role );
   htp.formhidden( 'P5', to_char(sysdate + nvl(to_number(password_exp_d),90),LNG.MASK) );
   htp.formhidden( 'P6', c2rec.failed_logins );
   htp.formsubmit( null, LNG3.ADM_TXT_652 );
   htp.formclose;
  htp.htmlclose;
  return;
end if;

acct_master( surl, LNG3.ADM_TXT_007 );

exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_TEST_PAGE', errmsg=>sqlerrm, extdet=>null);
end accept_test_page;

function randstring
  return varchar2
 is
  retstr	varchar2(10);
 begin

 retstr := NULL;
 dbms_random.Initialize(DECS.SESSION_RANDOM_NUMBER);
 for j in 1..10 loop
  retstr := retstr || chr(mod(abs(dbms_random.Random),26) + 65);
 end loop;

 dbms_random.terminate;
 return( retstr );

end randstring;

procedure acct_master( surl varchar2, msg in varchar2 default null )
as
begin
  htp.htmlopen;
  htp.p( '<HEAD>' );
  htp.title( glbx.extract_master_parameter('MENU_TITLE') );
  htp.p( '</HEAD>' );
  htp.framesetopen('99%,1%','100%',cattributes=>'frameborder="0" framespacing="0" border="0"');
   htp.frame( 'adm.acct_bottom?surl=' || glbx.rndsurl(surl) || '&msg=' || translate(msg,' ','+'),'ADM_MASTER');
  htp.framesetclose;
  htp.p( '<BODY>' );
  htp.noframesopen;
   glbx.noframe(surl,'ADM.ACCT_MASTER');
  htp.noframesclose;
  htp.p( '</BODY>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ACCT_MASTER', errmsg=>sqlerrm, extdet=>null);
end acct_master;

procedure acct_top(surl varchar2)
as
 --cursor c1 is select node_name from master_piction;
 sessid	integer;
 sts	varchar2(200);
 oth	varchar2(2000);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCT_TOP');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 disp_menu(surl,sessid,null);
exception when others then
 glbx.error_details( 'ADM', 'ACCT_TOP', errmsg=>sqlerrm, extdet=>null);
end acct_top;

procedure disp_menu( surl varchar2, acct in integer, ttl in varchar2 )
is

 cursor c2(acct in integer, vmenu varchar2, mname varchar2) is
  select ami.top_menu, ami.menu_item, ami.menu_call
  from admin_menu_items ami,admin_roles ar, admin_acct aa
  where ami.top_menu = vmenu and
        aa.acct_id = acct and
        aa.acct_role = ar.role_name and
        ar.top_menu = ami.top_menu and
        ami.menu_call not in (select disabled_item from piction_module where module_type = 'MENU' and module_name = mname) and
        ar.menu_item = ami.menu_item
  order by ami.top_order, ami.order_id;

 cursor c2a( vmenu varchar2, mname varchar2) is
  select ami.top_menu, ami.menu_item, ami.menu_call
  from admin_menu_items ami
  where ami.top_menu = vmenu and
        ami.menu_call not in (select disabled_item from piction_module where module_type = 'MENU' and module_name = mname)
  order by top_order,order_id;

 cursor c3(acct in integer, mname varchar2) is
  select distinct ami.top_menu,top_order
  from admin_menu_items ami, admin_roles ar, admin_acct aa
  where aa.acct_id = acct and
        aa.acct_role = ar.role_name and
        ar.top_menu = ami.top_menu and
        ami.menu_call not in (select disabled_item from piction_module where module_type = 'MENU' and module_name = mname) and
        ar.menu_item = ami.menu_item
  order by ami.top_order;

 cursor c3a( mname varchar2 ) is
  select distinct ami.top_menu,top_order
  from admin_menu_items ami
  where ami.menu_call not in (select disabled_item from piction_module where module_type = 'MENU' and module_name = mname)
  order by top_order;

 cursor c4(acct in integer) is select acct_role from admin_acct where acct_id = acct;

 c4rec		c4%ROWTYPE;
 clr1		varchar2(100);
 clr2		varchar2(100);
 clr3		varchar2(100);
 clr4		varchar2(100);
 clr5		varchar2(100);
 fnt		varchar2(100);
 brd		varchar2(10);
 main		boolean;
 mname		varchar2(100);

begin
 if glbx.extract_master_parameter('TRADITIONAL_MENU') = 'TRUE'
  then
   disp_menu_old(surl, acct, nvl(ttl,glbx.extract_master_parameter( 'ADMIN_MENU_TITLE' ) )  );
   return;
 end if;
 mname := nvl( glbx.extract_master_parameter('PICTION_MODULE'), 'Enterprise');
 clr2 := glbx.extract_master_parameter('MENU_BAR_COLOUR');
 clr4 := glbx.extract_master_parameter('MENU_BAR_HIGHLIGHT');
 clr5 := glbx.extract_master_parameter('MENU_BAR_FCOLOUR');
 clr3 := glbx.extract_master_parameter('MENU_TOP_COLOUR');
 clr1 := glbx.extract_master_parameter('MENU_TOP_FCOLOUR');
 fnt := glbx.extract_master_parameter('MENU_BAR_FONT');
 brd := '1';

 htp.p('<html><title>' || nvl(ttl,glbx.extract_master_parameter( 'ADMIN_MENU_TITLE' ) ) || '</title><style TYPE="text/css">
.menubar{font-size: 14px;font-weight: bold;padding-left:2px;padding-right:2px;color:#' || clr5 || ';background: #' || clr3 || ';font-family: "' || fnt || '"}
.xpfront .menubar{font-size: 12px; font-weight: bold;padding-left:0px;padding-right:4px;color:#ffffff;background: #000000;font-family: "' || fnt || '"}
.xpfront .menubar a {color:#ffffff;text-decoration:none;font-family: "' || fnt || '";font-family: "' || fnt || '"}
.xpfront .menubar a:visited {color:#ffffff;text-decoration:none;font-family: "' || fnt || '" }
.menubar a {color:#' || clr4 || ';background:#' || clr3 || ';padding-left:5px;padding-right:5px;text-decoration:none;font-family: "' || fnt || '"}
.menubar a:visited {color:#' || clr1 || ';text-decoration:none;}
.menubar a:hover {color:#ffffff;background: #' || clr3 || ';padding-top:4px;padding-left:5px;padding-right:5px;padding-bottom:4px;font-family: "' || fnt || '"}
.menu {padding:5px;color:#' || clr2 || ';background:#' || clr2 || ';font-family: "' || fnt || '"}
.menu .options {font-size: 12px;line-height: 15px;color:#' || clr4 || ';background:#' || clr2 || ';font-family: "' || fnt || '" }
.menu a {color:#ffffff;display:block;text-decoration:none;background:transparent;font-family: "' || fnt || '"}
.menu a:visited {color:#ffffff;text-decoration:none;font-family: "' || fnt || '"}
.menu a:hover {color:#' || clr2 || ';background:#' || clr4 || ';font-family: "' || fnt || '"}
</style>');

 if acct = '0'
  then
   main := TRUE;
  else
   open c4(acct);
   fetch c4 into c4rec;
   close c4;
   if c4rec.acct_role is null
    then
     main := FALSE;
    else
     main := FALSE;
   end if;
 end if;

 htp.p('<head><script language="javascript"></script><script language=javascript1.2 type="text/javascript" src="' || DECS.IMAGE_LOCATION || 'javascript/init.js"></script></head><body>' );
 htp.tableopen( cattributes=>'cellpadding="0" cellspacing="0" border="' || brd || '"');
 if main
  then
   htp.tablerowopen;
   for c3arec in c3a(mname) loop
    htp.p('<td class="menubar" nowrap><a id="act' || to_char(c3arec.top_order-1) || '" href="" onmouseover="ypSlideOutMenu.showMenu(''menu' || c3arec.top_order || ''')" onmouseout="ypSlideOutMenu.hideMenu(''menu' || c3arec.top_order || ''')">&nbsp;' || c3arec.top_menu || '&nbsp;</a></td>' );
   end loop;
   htp.tablerowclose;
   htp.tableclose;
  else
   htp.tablerowopen;
   for c3arec in c3(acct,mname) loop
    htp.p('<td class="menubar" nowrap><a id="act' || to_char(c3arec.top_order-1) || '" href="" onmouseover="ypSlideOutMenu.showMenu(''menu' || c3arec.top_order || ''')" onmouseout="ypSlideOutMenu.hideMenu(''menu' || c3arec.top_order || ''')">&nbsp;' || c3arec.top_menu || '&nbsp;</a></td>' );
   end loop;
   htp.tablerowclose;
   htp.tableclose;
 end if;

 if main
  then
   for c3arec in c3a( mname ) loop
    htp.p('<div id="menu' || c3arec.top_order || 'Container"><table cellpadding="0" cellspacing="0" border="' || brd || '" bgcolor="#' || clr2 || '"><tr valign="top"><td nowrap><div id="menu' || c3arec.top_order || 'Content" class="menu"><div class="options">' );
    for c2arec in c2a(c3arec.top_menu, mname) loop
     if instr(c2arec.menu_call,'?') = 0
      then
       htp.anchor( c2arec.menu_call || '?surl=' || surl, c2arec.menu_item );
      else
       htp.anchor( c2arec.menu_call || '&surl=' || surl, c2arec.menu_item );
     end if;
    end loop;
    htp.p('</div></div></td></tr></table></div>');
   end loop;
else
   for c3arec in c3(acct, mname) loop
    htp.p('<div id="menu' || c3arec.top_order || 'Container"><table cellpadding="0" cellspacing="0" border="' || brd || '" bgcolor="#' || clr2 || '"><tr valign="top"><td nowrap><div id="menu' || c3arec.top_order || 'Content" class="menu"><div class="options">' );
    for c2arec in c2(acct,c3arec.top_menu,mname) loop
     if instr(c2arec.menu_call,'?') = 0
      then
       htp.anchor( c2arec.menu_call || '?surl=' || surl, c2arec.menu_item );
      else
       htp.anchor( c2arec.menu_call || '&surl=' || surl, c2arec.menu_item );
     end if;
    end loop;
    htp.p('</div></div></td></tr></table></div>');
   end loop;
end if;
exception when others then
 glbx.error_details( 'ADM', 'DISP_MENU', errmsg=>sqlerrm, extdet=>null);
end disp_menu;

procedure disp_menu_old( surl varchar2, acct in integer, ttl in varchar2 )
is

 cursor c2(acct in integer,mname varchar2) is
  select ami.top_menu, ami.menu_item, ami.menu_call
  from admin_menu_items ami,admin_roles ar, admin_acct aa
  where aa.acct_id = acct and
        aa.acct_role = ar.role_name and
        ar.top_menu = ami.top_menu and
        ami.menu_call not in (select disabled_item from piction_module where module_type = 'MENU' and module_name = mname) and
        ar.menu_item = ami.menu_item
  order by ami.top_order, ami.order_id;

 cursor c2a(mname varchar2) is
  select ami.top_menu, ami.menu_item, ami.menu_call
  from admin_menu_items ami
  where
        ami.menu_call not in (select disabled_item from piction_module where module_type = 'MENU' and module_name = mname)
  order by top_order,order_id;

 cursor c3(acct in integer) is select acct_role from admin_acct where acct_id = acct;

 --c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;

 ctr		integer;
 lastrec	varchar2(100);
 mname		varchar2(100);
 mncall		varchar2(4000);

begin

 --open c1;
 --fetch c1 into c1rec;
 --close c1;
 mname := nvl( glbx.extract_master_parameter('PICTION_MODULE'), 'Enterprise');
 htp.p('
 <html>
 <head>
 <script language="JavaScript" src="' || DECS.IMAGE_LOCATION || 'javascript/navbar.js"></script>
 <script language="JavaScript" src="' || DECS.IMAGE_LOCATION || 'javascript/dhtmllib.js"></script>
 <script language="JavaScript">


 // Define navigation bar settings.

 navBarX = 0;

 navBarHeaderWidth  = 115;
 navBarMenuWidth    = 190;
 navBarBorderWidth  =   1;
 navBarPaddingWidth =   2;

 navBarBorderColor   = "#000000";
 navBarHeaderBgColor = "#' || glbx.extract_master_parameter('MENU_TOP_COLOUR') || '";
 navBarHeaderFgColor = "#' || glbx.extract_master_parameter('MENU_TOP_FCOLOUR') || '";
 navBarActiveBgColor = "#000080";
 navBarActiveFgColor = "#ffffff";
 navBarItemBgColor   = "#' || glbx.extract_master_parameter('MENU_BAR_COLOUR') || '";
 navBarItemFgColor   = "#' || glbx.extract_master_parameter('MENU_BAR_FCOLOUR') || '";
 navBarHighBgColor   = "#' || glbx.extract_master_parameter('MENU_BAR_HIGHLIGHT') || '";
 navBarHighFgColor   = "#ffffff";

 navBarHeaderFontFamily = "' || glbx.extract_master_parameter('MENU_BAR_FONT') || ',Verdana,Arial,Helvetica,sans-serif";
 navBarHeaderFontStyle  = "plain";
 navBarHeaderFontWeight = "bold";
 navBarHeaderFontSize   = "10pt";
 navBarItemFontFamily   = "Verdana,Arial,Helvetica,sans-serif";
 navBarItemFontStyle    = "plain";
 navBarItemFontWeight   = "bold";
 navBarItemFontSize     = "8pt";

 ');
 ctr := 0;
 lastrec := 'x';

 if acct = '0'
  then
   open c2a(mname);
  else
   open c3(acct);
   fetch c3 into c3rec;
   close c3;
   if c3rec.acct_role is null
    then
     open c2a(mname);
    else
     open c2(acct,mname);
   end if;
 end if;
 loop
  if (acct = '0') or (c3rec.acct_role is null)
   then
    fetch c2a into c2rec;
    if c2a%NOTFOUND then close c2a; exit; end if;
   else
    fetch c2 into c2rec;
    if c2%NOTFOUND then close c2; exit; end if;
  end if;
  if lastrec <> c2rec.top_menu
   then
    if ctr > 0
     then
      htp.p( '); ' );
    end if;
    htp.p( 'navBarMenus[' || to_char(ctr) || '] = new Array("' || c2rec.top_menu || '", ""');
    ctr := ctr + 1;
  end if;
  lastrec := c2rec.top_menu;
  mncall := c2rec.menu_call;
  if instr(mncall,'?') = 0
   then
    mncall := mncall || '?surl=' || glbx.rndsurl(surl);
   else
    mncall := mncall || '&surl=' || glbx.rndsurl(surl);
  end if;
  htp.p( ',"' || c2rec.menu_item || '", "' || mncall || '"' );
 end loop;
 htp.p( '); ');

 htp.p('
 </script>
 <title>' || ttl || '</title>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body bgcolor="#FFFFFF" onLoad="navBarInit()">
');

-- </body>
-- </html>
exception when others then
 glbx.error_details( 'ADM', 'DISP_MENU_OLD', errmsg=>sqlerrm, extdet=>null);
end disp_menu_old;

procedure mng_photographer( surl varchar2, phgid in integer default 0, lc in integer default 0 )
as
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MNG_PHOTOGRAPHER');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if lc = 1
  then
   -- New Photographer from the menu
   main_title( surl, sessid, 'Create New Photographer', helpid=>'A103' );
   htp.p('<CENTER>');
   htp.nl;
   htp.nl;
   htp.anchor2( 'adm.mng_photographer?surl=' || glbx.rndsurl(surl) || '&phgid=0&lc=0',LNG3.ADM_TXT_144,ctarget=>'NEW_PHOTOGRAPHER');
   htp.nl;
  else
    if phgid = 0
     then
      edit_phg_details( surl, 0, null );
      return;
    end if;
    htp.htmlopen;
  htp.p( '<HEAD>' );
    htp.title( glbx.extract_master_parameter('ADMIN_MENU_TITLE') );
  htp.p( '</HEAD>' );
    htp.framesetopen('100%','20%,80%',cattributes=>'frameborder="1" framespacing="0" border="1"');
     htp.frame( 'adm.edit_phg_left?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid,'ADM_LEFT_WIN');
     htp.frame( 'adm.edit_phg_details?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid,'ADM_RIGHT_WIN');
    htp.framesetclose;
  htp.p( '<BODY>' );
    htp.noframesopen;
     glbx.noframe(surl,'ADM.MNG_PHOTOGRAPHER');
    htp.noframesclose;
 end if;
  htp.p( '</BODY>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MNG_PHOTOGRAPHER', errmsg=>sqlerrm, extdet=>null);
end mng_photographer;

procedure mng_mfc( surl varchar2,manid in integer default 0 )
as
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MNG_MFC');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
  if manid = 0
   then
    edit_mfc_details( surl, 0, null );
    return;
  end if;
  htp.htmlopen;
  htp.p( '<HEAD>' );
  htp.title( glbx.extract_master_parameter('MENU_TITLE') );
  htp.p( '</HEAD>' );
  htp.framesetopen('100%','20%,80%',cattributes=>'frameborder="1" framespacing="0" border="1"');
   htp.frame( 'adm.edit_mfc_left?surl=' || glbx.rndsurl(surl) || '&manid=' || manid,'ADM_LEFT_WIN');
   htp.frame( 'adm.edit_mfc_details?surl=' || glbx.rndsurl(surl) || '&manid=' || manid,'ADM_RIGHT_WIN');
  htp.framesetclose;
  htp.p( '<BODY>' );
  htp.noframesopen;
   glbx.noframe(surl,'ADM.MNG_MFC');
  htp.noframesclose;
  htp.p( '</BODY>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MNG_MFC', errmsg=>sqlerrm, extdet=>null);
end mng_mfc;

procedure acct_mfc( surl varchar2,msg in varchar2 default null )
as
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCT_MFC');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
  htp.htmlopen;
  htp.p( '<HEAD>' );
  htp.title( glbx.extract_master_parameter('MENU_TITLE') );
  htp.p( '</HEAD>' );
  htp.framesetopen('100%','20%,80%',cattributes=>'frameborder="1" framespacing="0" border="1"');
   htp.frame( 'adm.acct_mfc_leftx?surl=' || glbx.rndsurl(surl),'ADM_LEFT_WIN');
   htp.frame( 'adm.acct_list_mfc?surl=' || glbx.rndsurl(surl) || '&st=0','ADM_RIGHT_WIN');
  htp.framesetclose;
  htp.p( '<BODY>' );
  htp.noframesopen;
   glbx.noframe(surl,'ADM.ACCT_MFC');
  htp.noframesclose;
  htp.p( '</BODY>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ACCT_MFC', errmsg=>sqlerrm, extdet=>null);
end acct_mfc;

procedure acct_charge( surl varchar2,msg in varchar2 default null )
as
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCT_CHARGE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
  htp.htmlopen;
  htp.p( '<HEAD>' );
  htp.title( LNG3.ADM_TXT_008 );
  htp.p( '</HEAD>' );
  htp.framesetopen('100%','20%,80%',cattributes=>'frameborder="1" framespacing="0" border="1"');
   htp.frame( 'adm.acct_charge_left?surl=' || glbx.rndsurl(surl),'ADM_LEFT_WIN');
   htp.frame( 'adm.acct_charge_right?surl=' || glbx.rndsurl(surl) || '&msg=' || translate( LNG3.ADM_TXT_009,' ','+'),'ADM_RIGHT_WIN');
  htp.framesetclose;
  htp.p( '<BODY>' );
  htp.noframesopen;
   glbx.noframe(surl,'ADM.ACCT_CHARGE');
  htp.noframesclose;
  htp.p( '</BODY>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ACCT_CHARGE', errmsg=>sqlerrm, extdet=>null);
end acct_charge;

procedure edit_phg_left( surl varchar2,phgid in integer )
as

 cursor c1(phgid integer) is
  select ph.pid,ph.username phuser,ca.aid,ca.username causer
  from customer_account ca,photographer ph
  where ca.pid = ph.pid and
        ph.pid = phgid
  order by ph.username,ca.username;

 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.EDIT_PHG_LEFT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG.LAB_TXT_001, style=>'NOMENUX', helpid=>'A03' );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.line );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.edit_phg_details?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid, LNG.GLB_TXT_066,ctarget=>'ADM_RIGHT_WIN') );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.form_load?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid, LNG3.ADM_TXT_042,ctarget=>'ADM_RIGHT_WIN') );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.phg_connect_as?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid, LNG3.ADM_TXT_040,ctarget=>new_window) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.line );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.phg_account?surl=' || glbx.rndsurl(surl) || '&phid=' || phgid || '&msg=', LNG.PHG_TXT_249,ctarget=>'ADM_RIGHT_WIN') );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.expire_phg_cust?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid, 'Expired / Auto Email Load',ctarget=>'ADM_RIGHT_WIN') );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.edit_phg_orders?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid || '&isphg=T', LNG.PHG_ALT_128,ctarget=>'ADM_RIGHT_WIN') );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.line );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.gcertificates?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid, LNG4.AHC_TXT_533,ctarget=>'ADM_RIGHT_WIN') );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.dump_slideshow?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid, LNG3.ADM_TXT_041,ctarget=>'ADM_RIGHT_WIN') );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.form_redirect?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid, LNG3.ADM_TXT_043,ctarget=>'ADM_RIGHT_WIN') );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.line );
  htp.tablerowclose;

  -- Quick Connect to Customer Accounts
  for c1rec in c1(phgid) loop
  htp.tablerowopen;
   htp.tabledata( htf.anchor2( 'adm.phg_connect_as?surl=' || glbx.rndsurl(surl) || '&phgid=' || c1rec.aid || '&typ=C', c1rec.causer, ctarget=>new_window || to_char(sysdate,'SSSSS')) ||
                  ' ' || htf.anchor2( 'adm.phg_connect_as?surl=' || glbx.rndsurl(surl) || '&phgid=' || c1rec.aid || '&typ=G', '(G)', ctarget=>new_window || to_char(sysdate,'SSSSS')));
  htp.tablerowclose;
  end loop;

  htp.tablerowopen;
   htp.tabledata( htf.line );
  htp.tablerowclose;

 htp.tableclose;
exception when others then
 glbx.error_details( 'ADM', 'EDIT_PHG_LEFT', errmsg=>sqlerrm, extdet=>null);
end edit_phg_left;

procedure edit_mfc_left( surl varchar2,manid in integer )
as
 cursor c1(manid integer) is select man_type from manufacturer where manufacturer_id = manid;
 c1rec  c1%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.EDIT_MFC_LEFT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 open c1(manid);
 fetch c1 into c1rec;
 close c1;
 main_title( surl, sessid, LNG.LAB_TXT_001 || c1rec.man_type, style=>'NOMENUX', helpid=>'A04' );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.line );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.edit_mfc_details?surl=' || glbx.rndsurl(surl) || '&manid=' || manid, LNG.GLB_TXT_066,ctarget=>'ADM_RIGHT_WIN') );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.mfc_connect_as?surl=' || glbx.rndsurl(surl) || '&manid=' || manid, LNG3.ADM_TXT_040,ctarget=>'_top') );
  htp.tablerowclose;
  /*
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.mfc_forms?surl=' || glbx.rndsurl(surl) || '&manid=' || manid, LNG3.ADM_TXT_044,ctarget=>'ADM_RIGHT_WIN') );
  htp.tablerowclose;
  */
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.mfc_form_load?surl=' || glbx.rndsurl(surl) || '&manid=' || manid, LNG3.ADM_TXT_042,ctarget=>'ADM_RIGHT_WIN') );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.line );
  htp.tablerowclose;
 htp.tableclose;
exception when others then
 glbx.error_details( 'ADM', 'EDIT_MFC_LEFT', errmsg=>sqlerrm, extdet=>null);
end edit_mfc_left;

procedure edit_phg_orders( surl varchar2,phgid in integer, isphg in varchar2 default 'F')
as
 sessid	integer;
 sts	varchar2(200);
 newid	integer;
 newpw	varchar2(100);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.EDIT_PHG_ORDERS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 adm_acct_orders(surl, phgid, isphg);
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'EDIT_PHG_ORDERS', errmsg=>sqlerrm, extdet=>null);
end edit_phg_orders;

procedure confirm_delete( surl varchar2,phgid in integer )
as
 sessid	integer;
 sts	varchar2(200);
 newid	integer;
 newpw	varchar2(100);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.CONFIRM_DELETE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_045, style=>'NOMENU', helpid=>'A05' );
 htp.nl;
 htp.bold( LNG3.ADM_TXT_046 );
 htp.nl;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_047 );
 htp.nl;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_048 );
 htp.nl;
 htp.nl;
 htp.formopen( 'adm.delete_phg' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.formhidden( 'PHGID', phgid );
 htp.formtext( 'DEL', 6, 6, null );
 htp.formsubmit( null, LNG3.ADM_TXT_049 );
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'CONFIRM_DELETE', errmsg=>sqlerrm, extdet=>null);
end confirm_delete;

procedure confirm_delete_mfc( surl varchar2,manid in integer )
as
 sessid	integer;
 sts	varchar2(200);
 newid	integer;
 newpw	varchar2(100);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.CONFIRM_DELETE_MFC');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_045, style=>'NOMENU', helpid=>'A06' );
 htp.nl;
 htp.bold( LNG3.ADM_TXT_050 );
 htp.nl;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_047 );
 htp.nl;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_048 );
 htp.nl;
 htp.nl;
 htp.formopen( 'adm.delete_mfc' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.formhidden( 'MANID', manid );
 htp.formtext( 'DEL', 6, 6, null );
 htp.formsubmit( null, LNG3.ADM_TXT_051 );
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'CONFIRM_DELETE_MFC', errmsg=>sqlerrm, extdet=>null);
end confirm_delete_mfc;

procedure delete_phg( surl varchar2,phgid in integer, del in varchar2 )
as

 cursor c1(phgid integer) is select aid from customer_account where pid = phgid;
 cursor c2(acid integer) is select umo_id,umo_type from umo um where aid = acid;
 cursor c3(phgid integer) is select poid from purchase_order where pid = phgid;
 cursor c4(v_umo integer) is select u.umo_id,u.aid,ua.attribute_id,ua.position_id,ua.value from umo_attribute ua, umo u where ua.umo_id = u.umo_id and u.umo_id = v_umo;
 cursor c5(acid integer) is select umo_id,umo_type from umo where aid=acid and umo_type = 'DOCUMENT';

 sessid		integer;
 sts		varchar2(200);
 newid		integer;
 gl		boolean;
 newpw		varchar2(100);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.DELETE_PHG');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if nvl(del,'X') <> 'DELETE'
  then
   main_title( surl, sessid, LNG3.ADM_TXT_052, helpid=>'A07' );
   htp.htmlclose;
   return;
 end if;
 for c1rec in c1(phgid) loop
  for c2rec in c2(c1rec.aid) loop
   if c2rec.umo_type = 'AUDIO'
    then
     myaudio.audio_api(v_umo=>c2rec.umo_id,new_acid=>c1rec.aid,old_acid=>NULL,action=>'DELETE');
   elsif c2rec.umo_type = 'VIDEO'
    then
     myvideo.video_api(v_umo=>c2rec.umo_id,new_acid=>c1rec.aid,old_acid=>NULL,action=>'DELETE');
   elsif c2rec.umo_type = 'RELATIONAL'
    then
     myrelational.relational_api(v_umo=>c2rec.umo_id,new_acid=>c1rec.aid,old_acid=>NULL,action=>'DELETE');
   elsif c2rec.umo_type = 'BLUEPRINT'
    then
     myblueprint.blueprint_api(v_umo=>c2rec.umo_id,new_acid=>c1rec.aid,old_acid=>NULL,action=>'DELETE');
   elsif c2rec.umo_type = 'DOCUMENT'
    then
     mydocument.document_api(v_umo=>c2rec.umo_id,new_acid=>c1rec.aid,old_acid=>NULL,action=>'DELETE');
   end if;
 --
   delete from log_photo_mod where phid = c2rec.umo_id;
   delete from log_umo_utility_modification where umo_id = c2rec.umo_id;
   delete from umo_index where umo_id = c2rec.umo_id;
   delete from umo_attribute where umo_id = c2rec.umo_id;
   gl := glbx.delete_link(c2rec.umo_id);
  end loop;
  commit;
  for c5rec in c5(c1rec.aid) loop
   if c5rec.umo_type = 'AUDIO'
    then
      ump.audio_index(v_umo=>c5rec.umo_id,schemaname=>user,howloaded=>NULL,action=>'DELETE');
   elsif c5rec.umo_type = 'VIDEO'
    then
      ump.video_index(v_umo=>c5rec.umo_id,schemaname=>user,howloaded=>NULL,action=>'DELETE');
   elsif c5rec.umo_type = 'RELATIONAL'
    then
      ump.relational_index(v_umo=>c5rec.umo_id,schemaname=>user,howloaded=>NULL,action=>'DELETE');
   elsif c5rec.umo_type = 'BLUEPRINT'
    then
      ump.blueprint_index(v_umo=>c5rec.umo_id,schemaname=>user,howloaded=>NULL,action=>'DELETE');
   elsif c5rec.umo_type = 'DOCUMENT'
    then
      ump.document_index(v_umo=>c5rec.umo_id,schemaname=>user,howloaded=>NULL,action=>'DELETE');
   end if;
  end loop;
  delete from umo um where aid = c1rec.aid and umo_type <> 'GALLERY';
  commit;
  delete from login_session where aid=c1rec.aid;
  commit;
  delete from slide_details where sid in (select sid from slide_master where aid = c1rec.aid );
  delete from slide_master where aid = c1rec.aid;
  delete from ecard_log where eid in (select eid from ecard where aid = c1rec.aid);
  delete from ecard where aid = c1rec.aid;
  delete from price_book_map where aid = c1rec.aid;
  delete from advanced_search where aid = c1rec.aid;
  delete from audit_customer_password where aid = c1rec.aid;
--  delete from birthday_alert where aid = c1rec.aid;
--  delete from birthday_details where aid = c1rec.aid;
--  delete from cdform where aid = c1rec.aid;
--  delete from cdform_cd where aid = c1rec.aid;
--  delete from comic_accounts where aid = c1rec.aid;
  delete from customer_price_book where aid = c1rec.aid;
  delete from customer_profile where aid = c1rec.aid;
  delete from error_trap where aid = c1rec.aid;
  delete from grab_email where aid = c1rec.aid;
  delete from main_value_customer where aid = c1rec.aid;
  delete from track_email where aid = c1rec.aid;
  delete from upl_master where aid = c1rec.aid;
 end loop;
 delete from customer_account where pid = phgid;
 delete from photographer_preference where pid = phgid;
 delete from customer_price_book where pid = phgid;
 for c3rec in c3(phgid) loop
  delete from shopping_basket where poid = c3rec.poid;
 end loop;
 delete from purchase_order where pid = phgid;
 delete from limit_bf where pid = phgid;
 delete from limit_scenes where pid = phgid;
 delete from limit_laf where pid = phgid;
 delete from advanced_search where pid = phgid;
-- delete from cdform where pid = phgid;
-- delete from cdform_cd where pid = phgid;
 delete from customer_profile where pid = phgid;
 delete from error_trap where pid = phgid;
-- delete from form_made where pid = phgid;
 delete from phg_price_book where pid = phgid;
 delete from photographer_payment where pid = phgid;
 delete from photographer_renewal_history where pid = phgid;
 delete from track_email where pid = phgid;
 delete from phg_batch_upload where pid = phgid;
 delete from upl_master where pid = phgid;
 delete from phg_batch_upload where pid = phgid;
 delete from umo where aid = phgid and umo_type = 'GALLERY';
 delete from audit_photographer_password where pid = phgid;
 delete from order_style where pid = phgid;
 delete from photographer where pid = phgid;
 commit;
 main_title( surl, sessid, LNG3.ADM_TXT_053, style=>'NOMENU' );
 htp.htmlclose;
exception
 when others then rollback; htp.p( sqlerrm );
end delete_phg;

procedure delete_mfc( surl varchar2,manid in integer, del in varchar2 )
as
 cursor c1(phgid integer) is select aid from customer_account where pid = phgid;
 cursor c2(acid integer) is select umo_id from umo um where aid = acid;
 cursor c3(phgid integer) is select poid from purchase_order where pid = phgid;
 sessid	integer;
 sts	varchar2(200);
 newid	integer;
 newpw	varchar2(100);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.DELETE_MFC');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if nvl(del,'X') <> 'DELETE'
  then
   main_title( surl, sessid, LNG3.ADM_TXT_054, helpid=>'A08' );
   htp.htmlclose;
   return;
 end if;
 delete from order_attrib where poid in (select poid from order_product where product_id in (select product_id from product where manufacturer_id = manid));
 delete from order_product where product_id in (select product_id from product where manufacturer_id = manid);
 delete from price_book where product_id in (select product_id from product where manufacturer_id = manid);
 delete from part_map where par_product_id in (select product_id from product where manufacturer_id = manid);
 delete from product where manufacturer_id = manid;
 delete from audit_manufacturer_password where manufacturer_id = manid;
 delete from manufacturer_photographer_disc where manufacturer_id = manid;
 delete from manufacturer_photographer where manufacturer_id = manid;
 delete from tender_mfctr_item where manufacturer_id = manid;
 delete from tender_mfctr where manufacturer_id = manid;
 delete from reverse_auction where manufacturer_id = manid;
 delete from simple_rfq_mfctr where manufacturer_id = manid;
 delete from audit_workflow_activity where manufacturer_id = manid;
 delete from workflow where manufacturer_id = manid;
 delete from album_mfctr_cover_template where manufacturer_id = manid;
 delete from album_mfctr_cover where manufacturer_id = manid;
 delete from album where manufacturer_id = manid;
 delete from limit_laf_mfctr where manufacturer_id = manid;
 --delete from man_forms where manufacturer_id = manid;
 delete from manufacturer_price_book where manufacturer_id = manid;
 delete from brand where manufacturer_id = manid;
 delete from phg_price_book_lab where manufacturer_id = manid;
 delete from phg_price_item where manufacturer_id = manid;
 delete from mfctr_clearance where manufacturer_id = manid;
 delete from manufacturer where manufacturer_id = manid;
 commit;
 main_title( surl, sessid, LNG3.ADM_TXT_055, helpid=>'A98' );
 htp.htmlclose;
exception
 when others then rollback; htp.p( sqlerrm );
end delete_mfc;

procedure accept_phgid( surl varchar2, phgid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p3a in varchar2, p4 in varchar2, pwdexp in varchar2, p5 in varchar2, pskl1 in char default 'F', pskl2 in varchar2,
                        pa in varchar2, p6 in varchar2, p6a in varchar2, p6c in varchar2, p7 in varchar2 default 'F', p8 in varchar2 default 'READ ONLY', pfrn in varchar2 default 'F',
                        p8f in varchar2, p8j in varchar2, p9 in varchar2, peaa in varchar2 default 'F', pcc in varchar2 default 'F', pmax in varchar2, pres in varchar2, rstr in varchar2,
                        pobj in MYARRAY, p9a in MYARRAY , p10 in varchar2, p10a in MYARRAY, p11 in varchar2, p11a in MYARRAY, p12 in MYARRAY, prl in GLBX.MYARRAY, p13 in varchar2 )
as

 cursor c1(phgid integer, pres varchar2 ) is
  select reserve_username_prefix,username
  from photographer
  where pid <> phgid and
        reserve_username_prefix is not null and
        (upper(pres) like upper(reserve_username_prefix) || '%' or
         upper(reserve_username_prefix) like upper(pres) || '%');

 c1rec	c1%ROWTYPE;
 msg	varchar2(100);
 vid	integer;
 sessid	integer;
 sts	varchar2(200);
 newid	integer;
 newpw	varchar2(100);
 vpres	varchar2(100);
 ftploc varchar2(1000);
 nmb	number;
 nmb2	number;
 nmb3	integer;
 dte	date;
 vobj	char(10);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_PHGID');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 --open c1;
 --fetch c1 into vid;
 --close c1;
 --vid := nvl(glbx.extract_master_parameter('ID'),1);
 vid := 1; -- Hardcoded to be 1 (maybe in a future release Piction can handle multiple sub versions in it)
 if pa = LNG3.ADM_TXT_056
  then
   confirm_delete( surl, phgid );
   return;
 end if;
 ftploc := p8f;
 if substr(ftploc,length(ftploc),1) = DECS.UNIX_OR_NT
  then
   null;
  else
   ftploc := ftploc || DECS.UNIX_OR_NT;
 end if;
 begin nmb := to_number(p6a); exception when others then nmb := null; end;
 begin nmb2 := to_number(p6c); exception when others then nmb2 := null; end;
 begin nmb3 := to_number(pmax); exception when others then nmb3 := 100; end;
 begin dte := to_date(pwdexp,LNG.MASK); exception when others then dte := NULL; end;
 vobj := 'FFFFFFFFFF';
 msg := LNG3.ADM_TXT_057;

 for j in pobj.first..pobj.last loop
  if pobj(j) = 'PHOTO'
   then
    vobj := 'T' || substr( vobj, 2 );
  elsif pobj(j) = 'DOCUMENT'
   then
    vobj := substr( vobj,1,1) || 'T' || substr( vobj, 3 );
  elsif pobj(j) = 'AUDIO'
   then
    vobj := substr( vobj,1,2) || 'T' || substr( vobj, 4 );
  elsif pobj(j) = 'VIDEO'
   then
    vobj := substr( vobj,1,3) || 'T' || substr( vobj, 5 );
  elsif pobj(j) = 'RELATIONAL'
   then
    vobj := substr( vobj,1,4) || 'T' || substr( vobj, 6 );
  elsif pobj(j) = 'BLUEPRINT'
   then
    vobj := substr( vobj,1,5) || 'T' || substr( vobj, 7 );
  end if;
 end loop;

 -- Check if the Reserve name Prefix might clash.
 vpres := pres;
 open c1( phgid, pres );
 fetch c1 into c1rec;
 close c1;
 if c1rec.reserve_username_prefix is not null
  then
   msg := LNG4.AHC_TXT_976 || c1rec.reserve_username_prefix || '-' || c1rec.username;
   vpres := NULL;
 end if;

 if phgid = 0
  then
   create_photographer( surl, vid, upper(p2), upper(p3), p1, substr(p4,2,instr(p4,']',1,1)-2), p5, sts, newid );
   update photographer
    set lab_account_id = p6,
        forum_enabled = p7,
        b2c_lab_discount = nmb,
        forum_priv = p8,
        ftp_run_now = pfrn,
        lab_charge_perc = nmb2,
        limit_scene = p9,
        limit_laf = p10,
        limit_bf = p11,
        ftp_load_dir = ftploc,
        object_access = vobj,
        external_api_access = peaa,
        credit_card_access = pcc,
        password_expires = dte,
        skill_control = pskl1,
        skill_level = pskl2,
        top_frame_lf = p3a,
        reserve_username_prefix = vpres,
        max_pbook_items = nmb3,
        restrict_to_ip_address = rstr,
        photographer_title = p8j,
        reporting_category = p13
   where pid = newid;
   insert into audit_photographer_password(pid,date_changed,pw) values (newid,sysdate,upper(p3));
   insert into photographer_preference(pid,aid,prefid,value)
     select newid,0,ap.prefid,replace(ap.default_value,'<@>',ph.business_name)
     from all_preferences ap, photographer ph
     where ph.pid = newid;
   for j in p9a.first..p9a.last loop
    if p9a(j) is not null
     then
      insert into limit_scenes(pid,scene_name) values (newid,p9a(j));
    end if;
   end loop;
   for j in p10a.first..p10a.last loop
    if p10a(j) is not null
     then
      insert into limit_laf(pid,theme_name) values (newid,p10a(j));
    end if;
   end loop;
   for j in p11a.first..p11a.last loop
    if p11a(j) is not null
     then
      insert into limit_bf(pid,theme_type) values (newid,p11a(j));
    end if;
   end loop;
   for j in p12.first..p12.last loop
    if p12(j) is not null
     then
      insert into ftp_sites_phg(pid, virtual_directory) values (newid,p12(j));
    end if;
   end loop;
   delete from customer_roles where aid = newid;
   for j in prl.first..prl.last loop
    if prl(j) is not null
     then
      insert into customer_roles(aid,role_id) values (newid,prl(j));
    end if;
   end loop;
   commit;
   if sts is null
    then
	 mng_photographer( surl,newid );
	else
	 edit_phg_details( surl,0, sts );
   end if;
   return;
 end if;

 if p3 is not null then newpw := glbx.encrypt( upper( p3 ), special_key=>DECS.GENERAL_ENCRYPT_KEY || DECS.RANDOM_NUMBER ); end if;
 update photographer
  set
   business_name = p1,
   username = upper( rtrim(p2) ),
   password = nvl(newpw,password),
   plan_id = substr(p4,2,instr(p4,']',1,1)-2),
   theme_type = p5,
   lab_account_id = p6,
   b2c_lab_discount = nvl(nmb,b2c_lab_discount),
   forum_enabled = p7,
   forum_priv = p8,
   ftp_run_now = pfrn,
   lab_charge_perc = nmb2,
   limit_scene = p9,
   limit_laf = p10,
   limit_bf = p11,
   password_expires = dte,
   external_api_access = peaa,
   credit_card_access = pcc,
   object_access = vobj,
   ftp_load_dir = ftploc,
   skill_control = pskl1,
   skill_level = pskl2,
   top_frame_lf = p3a,
   reserve_username_prefix = vpres,
   max_pbook_items = nmb3,
   restrict_to_ip_address = rstr,
   photographer_title = p8j,
   reporting_category = p13
  where pid = phgid;

  insert into audit_photographer_password(pid,date_changed,pw) values (phgid,sysdate,upper(p3));
  delete from limit_scenes where pid = phgid;
  for j in p9a.first..p9a.last loop
   if p9a(j) is not null
    then
     insert into limit_scenes(pid,scene_name) values (phgid,p9a(j));
   end if;
  end loop;
  delete from limit_laf where pid = phgid;
  for j in p10a.first..p10a.last loop
   if p10a(j) is not null
    then
     insert into limit_laf(pid,theme_name) values (phgid,p10a(j));
   end if;
  end loop;
  delete from limit_bf where pid = phgid;
  for j in p11a.first..p11a.last loop
   if p11a(j) is not null
    then
     insert into limit_bf(pid,theme_type) values (phgid,p11a(j));
   end if;
  end loop;
  delete from ftp_sites_phg where pid = phgid;
   for j in p12.first..p12.last loop
    if p12(j) is not null
     then
      insert into ftp_sites_phg(pid, virtual_directory) values (phgid,p12(j));
    end if;
   end loop;
   delete from customer_roles where aid = phgid;
   for j in prl.first..prl.last loop
    if prl(j) is not null
     then
      insert into customer_roles(aid,role_id) values (phgid,prl(j));
    end if;
   end loop;
  commit;
  edit_phg_details( surl,phgid, msg );
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_PHGID', errmsg=>sqlerrm, extdet=>null);
end accept_phgid;

procedure accept_manid( surl varchar2, manid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, pwdexp in varchar2, p5 in varchar2,
                        p6 in varchar2, pa in varchar2, p7 in GLBX.MYARRAY, p8 in varchar2, p9 in GLBX.MYARRAY, prl in GLBX.MYARRAY, pl in char,
                        p10 in varchar2, p11 in varchar2, p12 in varchar2, pls in GLBX.MYARRAY, p13 in varchar2 )
as

 sessid	integer;
 sts	varchar2(200);
 newid	integer;
 newpw	varchar2(100);
 dte	date;
 rchar	char(100);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_MANID');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if pa = LNG3.ADM_TXT_058
  then
   confirm_delete_mfc( surl, manid );
   return;
 end if;
 if manid = 0
  then
   create_mfc( surl,upper(p2), upper(p3), p1, p4, p5, p6, sts, newid );
   begin dte := to_date(pwdexp,LNG.MASK); exception when others then dte := NULL; end;
   for j in p7.first..p7.last loop
    if p7(j) <> '0'
     then
      rchar := substr(rchar,1,to_number(p7(j))-1) || 'T' || substr(rchar,to_number(p7(j))+1);
    end if;
   end loop;
   update manufacturer
    set
     name = p1,
     username = upper( rtrim(p2) ),
     password = nvl(newpw,password),
     man_type = p4,
     theme_name = p5,
     forum_priv = p6,
     password_expires = dte,
     man_bf = rchar,
     all_photographers = p8,
     limit_laf = pl,
     load_directory = p10,
     fund_centre = p11,
     manufacturer_title = p12,
     reporting_category = p13
    where manufacturer_id = newid;
--   insert into man_forms(manufacturer_id,formname) values (newid,upper(p2));
   insert into audit_manufacturer_password(manufacturer_id,date_changed,pw) values (newid,sysdate,upper(p3));
   for j in pls.first..pls.last loop
    if pls(j) is not null
     then
      insert into limit_laf_mfctr(manufacturer_id,theme_name) values (newid,pls(j));
    end if;
   end loop;
   for j in p9.first..p9.last loop
    if p9(j) is not null
     then
      insert into manufacturer_photographer(manufacturer_id,pid) values (newid,p9(j));
    end if;
   end loop;
   delete from customer_roles where aid = manid;
   for j in prl.first..prl.last loop
    if prl(j) is not null
     then
      insert into customer_roles(aid,role_id) values (manid,prl(j));
    end if;
   end loop;
   if sts is null
    then
      mng_mfc( surl, newid );
    else
      edit_mfc_details( surl, 0, sts );
   end if;
   return;
 end if;

 if p3 is not null then newpw := glbx.encrypt( upper( p3 ), special_key=>DECS.GENERAL_ENCRYPT_KEY || DECS.RANDOM_NUMBER ); end if;
 begin dte := to_date(pwdexp,LNG.MASK); exception when others then dte := NULL; end;
 rchar := lpad('F',100,'F');
 for j in p7.first..p7.last loop
  if p7(j) <> '0'
   then
    rchar := substr(rchar,1,to_number(p7(j))-1) || 'T' || substr(rchar,to_number(p7(j))+1);
  end if;
 end loop;
 update manufacturer
  set
   name = p1,
   username = upper( rtrim(p2) ),
   password = nvl(newpw,password),
   man_type = p4,
   theme_name = p5,
   forum_priv = p6,
   password_expires = dte,
   man_bf = rchar,
   all_photographers = p8,
   limit_laf = pl,
   load_directory = p10,
   fund_centre = p11,
   manufacturer_title = p12,
   reporting_category = p13
  where manufacturer_id = manid;
  insert into audit_manufacturer_password(manufacturer_id,date_changed,pw) values (manid,sysdate,upper(p3));
  delete from manufacturer_photographer where manufacturer_id = manid;
  for j in p9.first..p9.last loop
   if p9(j) is not null
    then
     insert into manufacturer_photographer(manufacturer_id,pid) values (manid,p9(j));
   end if;
  end loop;
  commit;
  delete from limit_laf_mfctr where manufacturer_id = manid;
  for j in pls.first..pls.last loop
   if pls(j) is not null
    then
     insert into limit_laf_mfctr(manufacturer_id,theme_name) values (manid,pls(j));
   end if;
  end loop;
  delete from customer_roles where aid = manid;
  for j in prl.first..prl.last loop
   if prl(j) is not null
    then
     insert into customer_roles(aid,role_id) values (manid,prl(j));
   end if;
  end loop;
  commit;
  edit_mfc_details( surl,manid, LNG3.ADM_TXT_059 );
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_MANID', errmsg=>sqlerrm, extdet=>null);
end accept_manid;

procedure edit_phg_details( surl varchar2, phgid in integer, msg in varchar2 default null )
as

 cursor c1(phgid integer) is select * from photographer where pid = phgid;
 cursor c2 is select id, plan_name from charge_plan order by id;
 cursor c3 is select theme_type from theme_types order by theme_type;
 cursor c3a is select theme_name from theme order by theme_name;
 cursor c4 is select 'READ ONLY' priv from dual union all select 'READ WRITE' priv from dual union all select 'FULL CONTROL' priv from dual;
 cursor c5(phgid integer) is select * from audit_photographer_password where pid = phgid and date_changed = (select max(date_changed) from audit_photographer_password where pid = phgid and pw is not null);
 cursor c6 is select scene_name from scene order by scene_name;
 cursor c7(phgid integer, scnm varchar2) is select scene_name from limit_scenes where pid = phgid and scene_name = scnm;
 cursor c6a is select theme_name from theme order by theme_name;
 cursor c6c is select theme_type from theme_types order by theme_type;
 cursor c7a(phgid integer, thm varchar2) is select theme_name from limit_laf where pid = phgid and theme_name = thm;
 cursor c8a(phgid integer, ttype varchar2) is select theme_type from limit_bf where pid = phgid and theme_type = ttype;
 cursor c9(planid integer) is select password_expiry_days,password_attempts from charge_plan where id = planid;
 cursor c10(phgid integer, vd varchar2) is select 'x' exst from ftp_sites_phg where pid = phgid and virtual_directory = vd;
 cursor c11 is select virtual_directory from ftp_sites order by virtual_directory;
 cursor c10a is select role_id,role_name from piction_roles where role_type = 'REPORT' order by role_name;
 cursor c11a(phgid integer, rid integer) is select 'x' exst from customer_roles where aid = phgid and role_id = rid;
 cursor c12a is select scene_name from scene order by scene_name;

 c1rec	c1%ROWTYPE;
 c5rec	c5%ROWTYPE;
 c7rec	c7%ROWTYPE;
 c7arec	c7a%ROWTYPE;
 c8arec	c8a%ROWTYPE;
 c9rec	c9%ROWTYPE;
 c10rec	c10%ROWTYPE;
 c11arec c11a%ROWTYPE;
 tmp	varchar2(32767);
 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.EDIT_PHG_DETAILS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 open c1(phgid);
 fetch c1 into c1rec;
 close c1;
 if phgid = 0
  then
   main_title( surl, sessid, LNG3.ADM_TXT_060, style=>'NOMENU', helpid=>'A09' );
  else
   main_title( surl, sessid, LNG3.ADM_TXT_061 || ': ' || c1rec.business_name, style=>'NOMENU', helpid=>'A09'  );
 end if;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_phgid' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.formhidden( 'PHGID', phgid );
 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
 htp.tablerowopen;
 htp.p( '<TD ALIGN="LEFT" VALIGN="TOP">' );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG.CST_TXT_004) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P1',40, 100, c1rec.business_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG3.ADM_TXT_063) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P2',40, 100, c1rec.username ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG.GLB_TXT_018) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formpassword('P3',40, 100, null ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  open c5(c1rec.pid);
  fetch c5 into c5rec;
  close c5;
  if c5rec.pw is not null
   then
    htp.tablerowopen;
      htp.tabledata(htf.bold( htf.bold(LNG.GLB_TXT_117) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.italic( c5rec.pw ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;

  open c9(c1rec.plan_id);
  fetch c9 into c9rec;
  close c9;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG3.ADM_TXT_702) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('PWDEXP',20, 30, to_char(c1rec.password_expires,LNG.MASK)) || ' (' || nvl(to_char(c9rec.password_expiry_days),LNG3.ADM_TXT_708) || ') ' || LNG.MASK,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG3.ADM_TXT_707) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold(c1rec.failed_logins) || '/' || nvl( to_char(c9rec.password_attempts),LNG3.ADM_TXT_708 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG3.ADM_TXT_775) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
      htp.formtext('P8F',40, 100, c1rec.ftp_load_dir );
      htp.nl;
      if c1rec.ftp_run_now = 'T'
       then
        htp.formcheckbox('PFRN','T','CHECKED');
       else
        htp.formcheckbox('PFRN','T');
      end if;
      htp.p( 'All FTP Load Jobs run immediately (not in batch)' );
      htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG5.EXT_TXT_381) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P8J',40, 100, nvl(c1rec.photographer_title,'Photographer') ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG.PHG_TXT_243) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(nvl(c1rec.dob,'&nbsp;'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || GLBX.TABLE_BACKGROUND );
  tmp := htf.formselectopen( 'P4' );
  for c2rec in c2 loop
   if c2rec.id = c1rec.plan_id
    then
	 tmp := tmp || htf.formselectoption( '[' || c2rec.id || '] ' || c2rec.plan_name, 'SELECTED' );
	else
	 tmp := tmp || htf.formselectoption( '[' || c2rec.id || '] ' || c2rec.plan_name );
   end if;
  end loop;
  tmp := tmp || htf.formselectclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG.PHG_TXT_249) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG3.ADM_TXT_066) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P6',20, 20, c1rec.lab_account_id ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  -- Redundant Parameter
  -- Now moved to the Manufacturer
  htp.formhidden( 'P6A', to_char(nvl(c1rec.b2c_lab_discount,0)));
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG3.ADM_TXT_068) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P6C',20, 20, c1rec.lab_charge_perc ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG4.AHC_TXT_414) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">');
     htp.formselectopen( 'POBJ', null, 3, cattributes=>'MULTIPLE' );
     if nvl(substr(c1rec.object_access,1,1),'T') = 'T'
      then
       htp.formselectoption( 'PHOTO','SELECTED' );
      else
       htp.formselectoption( 'PHOTO' );
     end if;
     if nvl(substr(c1rec.object_access,2,1),'T') = 'T'
      then
       htp.formselectoption( 'DOCUMENT','SELECTED' );
      else
       htp.formselectoption( 'DOCUMENT' );
     end if;
     if nvl(substr(c1rec.object_access,3,1),'T') = 'T'
      then
       htp.formselectoption( 'AUDIO','SELECTED' );
      else
       htp.formselectoption( 'AUDIO' );
     end if;
     if nvl(substr(c1rec.object_access,4,1),'T') = 'T'
      then
       htp.formselectoption( 'VIDEO','SELECTED' );
      else
       htp.formselectoption( 'VIDEO' );
     end if;
     if nvl(substr(c1rec.object_access,5,1),'T') = 'T'
      then
       htp.formselectoption( 'RELATIONAL','SELECTED' );
      else
       htp.formselectoption( 'RELATIONAL' );
     end if;
     if nvl(substr(c1rec.object_access,6,1),'T') = 'T'
      then
       htp.formselectoption( 'BLUEPRINT','SELECTED' );
      else
       htp.formselectoption( 'BLUEPRINT' );
     end if;
     htp.formselectclose;
     htp.p( '<TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG4.AHC_TXT_428) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.external_api_access = 'T'
      then
       htp.tabledata(htf.formcheckbox('PEAA','T','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.formcheckbox('PEAA','T'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG4.AHC_TXT_627) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.credit_card_access = 'T'
      then
       htp.tabledata(htf.formcheckbox('PCC','T','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.formcheckbox('PCC','T'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG3.ADM_TXT_070) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.forum_enabled = 'T'
      then
       htp.tabledata(htf.formcheckbox('P7','T','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.formcheckbox('P7','T'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  tmp := htf.formselectopen( 'P8' );
  for c4rec in c4 loop
   if rtrim(c4rec.priv) = c1rec.forum_priv
    then
	 tmp := tmp || htf.formselectoption( rtrim(c4rec.priv), 'SELECTED' );
	else
	 tmp := tmp || htf.formselectoption( rtrim(c4rec.priv) );
   end if;
  end loop;
  tmp := tmp || htf.formselectclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG3.ADM_TXT_071) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG4.AHC_TXT_788) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.skill_control = 'T'
      then
       htp.tabledata(htf.formcheckbox('PSKL1','T','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.formcheckbox('PSKL1','T'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.bold(LNG2.PBK_TXT_083),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT">');
     htp.formselectopen( 'PSKL2' );
      if c1rec.skill_level = LNG2.PBK_TXT_080
       then
        htp.formselectoption( LNG2.PBK_TXT_080, 'SELECTED' );
       else
        htp.formselectoption( LNG2.PBK_TXT_080 );
      end if;
      if c1rec.skill_level = LNG2.PBK_TXT_081
       then
        htp.formselectoption( LNG2.PBK_TXT_081, 'SELECTED' );
       else
        htp.formselectoption( LNG2.PBK_TXT_081 );
      end if;
      if c1rec.skill_level = LNG2.PBK_TXT_082
       then
        htp.formselectoption( LNG2.PBK_TXT_082, 'SELECTED' );
       else
        htp.formselectoption( LNG2.PBK_TXT_082 );
      end if;
     htp.formselectclose;
    htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG4.AHC_TXT_585) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext( 'PMAX', 5, 10, to_char(nvl(c1rec.max_pbook_items,100))),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG4.AHC_TXT_973) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext( 'PRES', 20, 100, c1rec.reserve_username_prefix),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG5.EXT_TXT_013) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext( 'RSTR', 20, 100, c1rec.restrict_to_ip_address),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( 'Reporting Roles' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">');
     htp.formhidden( 'PRL', null );
     htp.formselectopen( 'PRL', null, 5, cattributes=>'MULTIPLE' );
     htp.formselectoption( NULL );
     for c10arec in c10a loop
      open c11a(phgid,c10arec.role_id);
      fetch c11a into c11arec;
      if c11a%FOUND
       then
         htp.formselectoption( c10arec.role_name, 'SELECTED', cattributes=>'VALUE="' || c10arec.role_id || '"' );
       else
         htp.formselectoption( c10arec.role_name, cattributes=>'VALUE="' || c10arec.role_id || '"' );
      end if;
      close c11a;
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( 'Reporting Category' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">');
     htp.formselectopen( 'P13' );
     htp.formselectoption( NULL );
     for c12arec in c12a loop
      if c12arec.scene_name = c1rec.reporting_category
       then
         htp.formselectoption( c12arec.scene_name, 'SELECTED' );
       else
         htp.formselectoption( c12arec.scene_name );
      end if;
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tableclose;

  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || GLBX.TABLE_BACKGROUND );
  tmp := htf.formselectopen( 'P5' );
  for c3rec in c3 loop
   if c3rec.theme_type = c1rec.theme_type
    then
	 tmp := tmp || htf.formselectoption( c3rec.theme_type, 'SELECTED' );
	else
	 tmp := tmp || htf.formselectoption( c3rec.theme_type );
   end if;
  end loop;
  tmp := tmp || htf.formselectclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG2.PFM_TXT_164) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  tmp := htf.formselectopen( 'P3A' );
  for c3arec in c3a loop
   if c3arec.theme_name = c1rec.top_frame_lf
    then
	 tmp := tmp || htf.formselectoption( c3arec.theme_name, 'SELECTED' );
	else
	 tmp := tmp || htf.formselectoption( c3arec.theme_name );
   end if;
  end loop;
  tmp := tmp || htf.formselectclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG4.AHC_TXT_804) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;

  -- Business Features
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG3.ADM_TXT_073) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="TOP" ALIGN="LEFT"');
     if nvl(c1rec.limit_bf,'T') = 'T'
      then
       tmp := htf.formradio( 'P11','T','CHECKED' ) || ' ' || LNG3.ADM_TXT_074 || htf.nl || htf.formradio( 'P11','F' ) || ' ' || LNG3.ADM_TXT_073;
      else
       tmp := htf.formradio( 'P11','T' ) || ' ' || LNG3.ADM_TXT_074 || htf.nl || htf.formradio( 'P11','F','CHECKED' ) || ' ' || LNG3.ADM_TXT_073;
     end if;
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="TOP" ALIGN="LEFT"');
     htp.formhidden( 'P11A',null);
     tmp := htf.formselectopen( 'P11A', null, 5, cattributes=>'MULTIPLE' );
     for c6crec in c6c loop
      open c8a(c1rec.pid,c6crec.theme_type);
      fetch c8a into c8arec;
      if c8a%FOUND
       then
         tmp := tmp || htf.formselectoption( c6crec.theme_type,'SELECTED' );
       else
         tmp := tmp || htf.formselectoption( c6crec.theme_type );
      end if;
      close c8a;
     end loop;
     tmp := tmp || htf.formselectclose;
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="TOP" ALIGN="LEFT"');
  htp.tablerowclose;

  -- Look and Feel
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG3.ADM_TXT_079) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="TOP" ALIGN="LEFT"');
     if nvl(c1rec.limit_laf,'T') = 'T'
      then
       tmp := htf.formradio( 'P10','T','CHECKED' ) || ' ' || LNG3.ADM_TXT_080 || htf.nl || htf.formradio( 'P10','F' ) || ' ' || LNG3.ADM_TXT_081;
      else
       tmp := htf.formradio( 'P10','T' ) || ' ' || LNG3.ADM_TXT_080 || htf.nl || htf.formradio( 'P10','F','CHECKED' ) || ' ' || LNG3.ADM_TXT_081;
     end if;
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="TOP" ALIGN="LEFT"');
     htp.formhidden( 'P10A',null);
     tmp := htf.formselectopen( 'P10A', null, 5, cattributes=>'MULTIPLE' );
     for c6arec in c6a loop
      open c7a(c1rec.pid,c6arec.theme_name);
      fetch c7a into c7arec;
      if c7a%FOUND
       then
         tmp := tmp || htf.formselectoption( c6arec.theme_name,'SELECTED' );
       else
         tmp := tmp || htf.formselectoption( c6arec.theme_name );
      end if;
      close c7a;
     end loop;
     tmp := tmp || htf.formselectclose;
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="TOP" ALIGN="LEFT"');
  htp.tablerowclose;

  -- Categories
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.bold(LNG3.ADM_TXT_076) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="TOP" ALIGN="LEFT"');
     if nvl(c1rec.limit_scene,'T') = 'T'
      then
       tmp := htf.formradio( 'P9','T','CHECKED' ) || ' ' || LNG.PHG_ALT_390 || htf.nl || htf.formradio( 'P9','F' ) || ' ' || LNG3.ADM_TXT_076;
      else
       tmp := htf.formradio( 'P9','T' ) || ' ' || LNG.PHG_ALT_390 || htf.nl || htf.formradio( 'P9','F','CHECKED' ) || ' ' || LNG3.ADM_TXT_076;
     end if;
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="TOP" ALIGN="LEFT"');
     htp.formhidden( 'P9A',null);
     tmp := htf.formselectopen( 'P9A', null, 5, cattributes=>'MULTIPLE' );
     for c6rec in c6 loop
      open c7(c1rec.pid,c6rec.scene_name);
      fetch c7 into c7rec;
      if c7%FOUND
       then
         tmp := tmp || htf.formselectoption( c6rec.scene_name,'SELECTED' );
       else
         tmp := tmp || htf.formselectoption( c6rec.scene_name );
      end if;
      close c7;
     end loop;
     tmp := tmp || htf.formselectclose;
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="TOP" ALIGN="LEFT"');
  htp.tablerowclose;

  -- FTP Sites
  htp.tablerowopen;
     -- xxx for language file
     htp.tabledata(htf.bold( htf.bold('FTP Sites') ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="TOP" ALIGN="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="TOP" ALIGN="LEFT"');
     htp.formhidden( 'P12',null);
     tmp := htf.formselectopen( 'P12', null, 5, cattributes=>'MULTIPLE' );
     tmp := tmp || htf.formselectoption( NULL );
     for c11rec in c11 loop
      open c10(c1rec.pid,c11rec.virtual_directory);
      fetch c10 into c10rec;
      if c10%FOUND
       then
         tmp := tmp || htf.formselectoption( c11rec.virtual_directory,'SELECTED' );
       else
         tmp := tmp || htf.formselectoption( c11rec.virtual_directory );
      end if;
      close c10;
     end loop;
     tmp := tmp || htf.formselectclose;
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="TOP" ALIGN="LEFT"');
  htp.tablerowclose;

 htp.tableclose;
 htp.nl;
 if phgid = 0
  then
 	htp.formsubmit( 'PA',LNG3.ADM_TXT_082 );
  else
 	htp.formsubmit( 'PA',LNG3.ADM_TXT_083 );
 	htp.formsubmit( 'PA',LNG3.ADM_TXT_056 );
 end if;
 htp.formclose;

 htp.p( '</TD>' );
 htp.tablerowopen;
 htp.tableclose;

 htp.p( '<CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'EDIT_PHG_DETAILS', errmsg=>sqlerrm, extdet=>null);
end edit_phg_details;

procedure edit_mfc_details( surl varchar2, manid in integer, msg in varchar2 default null )
as

 cursor c1(phgid integer) is select * from manufacturer where manufacturer_id = manid;
 cursor c2 is select man_type from man_options;
 cursor c3 is select theme_name from theme;
 cursor c4 is select 'READ ONLY' priv from dual union all select 'READ WRITE' priv from dual union all select 'FULL CONTROL' priv from dual;
 cursor c5(manid integer) is select * from audit_manufacturer_password where manufacturer_id = manid and date_changed = (select max(date_changed) from audit_manufacturer_password where manufacturer_id = manid and pw is not null);
 cursor c6 is select pid,username,business_name from photographer order by business_name;
 cursor c7(manid integer, phgid integer) is select 'x' tot from manufacturer_photographer where manufacturer_id = manid and pid = phgid;
 cursor c8(manid integer, tname varchar2) is select * from limit_laf_mfctr where manufacturer_id = manid and theme_name = tname;
 cursor c9 is select theme_name from theme order by theme_name;
 cursor c10 is select role_id,role_name from piction_roles where role_type = 'REPORT' order by role_name;
 cursor c11(manid integer, rid integer) is select 'x' exst from customer_roles where aid = manid and role_id = rid;
 cursor c12 is select scene_name from scene order by scene_name;

 c1rec	c1%ROWTYPE;
 c5rec	c5%ROWTYPE;
 c7rec	c7%ROWTYPE;
 c8rec	c8%ROWTYPE;
 c11rec	c11%ROWTYPE;
 tmp	varchar2(2000);
 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.EDIT_MFC_DETAILS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 open c1(manid);
 fetch c1 into c1rec;
 close c1;
 if manid = 0
  then
   main_title( surl, sessid, LNG3.ADM_TXT_084, style=>'NOMENU', helpid=>'A10' );
  else
   main_title( surl, sessid, LNG.LAB_TXT_008 || ': ' || c1rec.name, style=>'NOMENU', helpid=>'A10'  );
 end if;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_manid' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.formhidden( 'MANID', manid );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.CST_TXT_004 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P1',40, 100, c1rec.name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_063 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P2',40, 100, c1rec.username ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_576 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P12',40, 100, c1rec.manufacturer_title ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.GLB_TXT_018 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formpassword('P3',40, 100, null ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  open c5(manid);
  fetch c5 into c5rec;
  close c5;
  if c5rec.pw is not null
   then
    htp.tablerowopen;
      htp.tabledata(htf.bold( htf.bold(LNG.GLB_TXT_117) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.italic( c5rec.pw ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_702 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('PWDEXP',20, 30, to_char(c1rec.password_expires,LNG.MASK)) || ' - ' || LNG.MASK,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  tmp := htf.formselectopen( 'P4' );
  for c2rec in c2 loop
   if rtrim(c2rec.man_type) = c1rec.man_type
    then
	 tmp := tmp || htf.formselectoption( rtrim(c2rec.man_type), 'SELECTED' );
	else
	 tmp := tmp || htf.formselectoption( rtrim(c2rec.man_type) );
   end if;
  end loop;
  tmp := tmp || htf.formselectclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_086 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_611 ) || htf.nl || LNG4.AHC_TXT_619 || ':' || glbx.extract_master_parameter( 'REPORTS_DIRECTORY' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext( 'P10', 30, 1000, c1rec.load_directory), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_985 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext( 'P11', 30, 100, c1rec.fund_centre), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  tmp := htf.formselectopen( 'P6' );
  for c4rec in c4 loop
   if rtrim(c4rec.priv) = c1rec.forum_priv
    then
	 tmp := tmp || htf.formselectoption( rtrim(c4rec.priv), 'SELECTED' );
	else
	 tmp := tmp || htf.formselectoption( rtrim(c4rec.priv) );
   end if;
  end loop;
  tmp := tmp || htf.formselectclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_071 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  tmp := htf.formselectopen( 'P5' );
  for c3rec in c3 loop
   if c3rec.theme_name = c1rec.theme_name
    then
	 tmp := tmp || htf.formselectoption( c3rec.theme_name, 'SELECTED' );
	else
	 tmp := tmp || htf.formselectoption( c3rec.theme_name );
   end if;
  end loop;
  tmp := tmp || htf.formselectclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_088 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_081 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">');
     if c1rec.limit_laf = 'F'
      then
       htp.formradio( 'PL', 'F', 'CHECKED' );
      else
       htp.formradio( 'PL', 'F' );
     end if;
     htp.bold( LNG3.ADM_TXT_080 );
     htp.nl;
     if c1rec.limit_laf = 'T'
      then
       htp.formradio( 'PL', 'T', 'CHECKED' );
      else
       htp.formradio( 'PL', 'T' );
     end if;
     htp.bold( LNG3.ADM_TXT_081 );
     htp.nl;
     htp.formhidden( 'PLS', null );
     htp.formselectopen( 'PLS', null, 3, cattributes=>'MULTIPLE' );
     for c9rec in c9 loop
      open c8(c1rec.manufacturer_id,c9rec.theme_name);
      fetch c8 into c8rec;
      if c8%FOUND
       then
         htp.formselectoption( c9rec.theme_name, 'SELECTED' );
       else
         htp.formselectoption( c9rec.theme_name );
      end if;
      close c8;
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_483 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">');
     if c1rec.all_photographers = 'T'
      then
       htp.formradio( 'P8','T','CHECKED' );
      else
       htp.formradio( 'P8','T' );
     end if;
     htp.bold( ' ' || LNG4.AHC_TXT_481 );
     htp.nl;
     if c1rec.all_photographers = 'F'
      then
       htp.formradio( 'P8','F','CHECKED' );
      else
       htp.formradio( 'P8','F' );
     end if;
     htp.bold( ' ' || LNG4.AHC_TXT_482 );
     htp.nl;
     htp.formhidden( 'P9', null );
     htp.formselectopen( 'P9', null, 5, cattributes=>'MULTIPLE' );
      htp.formselectoption( NULL );
      for c6rec in c6 loop
       open c7(c1rec.manufacturer_id,c6rec.pid);
       fetch c7 into c7rec;
       if c7%FOUND
        then
         htp.formselectoption( c6rec.business_name || '(' || c6rec.username || ')', 'SELECTED', cattributes=>'VALUE="' || c6rec.pid || '"' );
        else
         htp.formselectoption( c6rec.business_name || '(' || c6rec.username || ')', cattributes=>'VALUE="' || c6rec.pid || '"' );
       end if;
       close c7;
      end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( 'Reporting Roles' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">');
     htp.formhidden( 'PRL', null );
     htp.formselectopen( 'PRL', null, 5, cattributes=>'MULTIPLE' );
     htp.formselectoption( NULL );
     for c10rec in c10 loop
      open c11(manid,c10rec.role_id);
      fetch c11 into c11rec;
      if c11%FOUND
       then
         htp.formselectoption( c10rec.role_name, 'SELECTED', cattributes=>'VALUE="' || c10rec.role_id || '"' );
       else
         htp.formselectoption( c10rec.role_name, cattributes=>'VALUE="' || c10rec.role_id || '"' );
      end if;
      close c11;
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( 'Reporting Category' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">');
     htp.formselectopen( 'P13' );
     htp.formselectoption( NULL );
     for c12rec in c12 loop
      if c12rec.scene_name = c1rec.reporting_category
       then
         htp.formselectoption( c12rec.scene_name, 'SELECTED' );
       else
         htp.formselectoption( c12rec.scene_name );
      end if;
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formhidden( 'P7','0');
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0 ');
  htp.tablerowopen;
   if substr(c1rec.man_bf,1,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','1','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','1'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/home.gif',cattributes=>'border=0',calt=>LNG.LAB_TXT_002 ),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( LNG.LAB_TXT_002,cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   if substr(c1rec.man_bf,14,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','14','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','14'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/attention.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_686),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( LNG4.AHC_TXT_686,cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   if substr(c1rec.man_bf,16,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','16','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','16'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/cashier.gif',cattributes=>'border=0',calt=>LNG5.EXT_TXT_180),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.p( '<TD ' || 'valign="MIDDLE" ALIGN="LEFT">' );
    htp.p( LNG5.EXT_TXT_180 || ' ');
    -- Advanced Cashier Feature Enabled
    if substr(c1rec.man_bf,17,1) = 'T'
     then
      htp.formcheckbox( 'P7','17','CHECKED');
     else
      htp.formcheckbox( 'P7','17');
    end if;
    htp.p( LNG.PHG_TXT_212 );
   htp.p( '</TD>' );
  htp.tablerowclose;

  -- XXX convert to language5
  htp.tablerowopen;
   if substr(c1rec.man_bf,25,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','25','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','25'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/barcode.gif',cattributes=>'border=0',calt=>'Barcode'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.p( '<TD ' || 'valign="MIDDLE" ALIGN="LEFT">' );
    htp.p( 'Barcode' || ' ');
   htp.p( '</TD>' );
  htp.tablerowclose;

  -- XXX convert to language5
  htp.tablerowopen;
   if substr(c1rec.man_bf,20,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','20','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','20'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/receptionist.gif',cattributes=>'border=0',calt=>'Receptionist'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.p( '<TD ' || 'valign="MIDDLE" ALIGN="LEFT">' );
    htp.p( 'Receptionist' || ' ');
    -- Advanced Cashier Feature Enabled
    if substr(c1rec.man_bf,21,1) = 'T'
     then
      htp.formcheckbox( 'P7','21','CHECKED');
     else
      htp.formcheckbox( 'P7','21');
    end if;
    htp.p( LNG.PHG_TXT_212 );
   htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tablerowopen;
   if substr(c1rec.man_bf,2,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','2','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','2'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/acct.gif',cattributes=>'border=0',calt=>LNG3.ADM_TXT_670),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( LNG3.ADM_TXT_670,cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   if substr(c1rec.man_bf,15,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','15','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','15'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/book.gif',cattributes=>'border=0',calt=>LNG3.ADM_TXT_875),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( LNG5.BKN_TXT_019,cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   if substr(c1rec.man_bf,3,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','3','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','3'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/orders.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_128),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( LNG.PHG_ALT_128,cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;

  htp.tablerowopen;
   if substr(c1rec.man_bf,4,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','4','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','4'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/products.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_470),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( LNG.PHG_TXT_470,cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;

  -- xxx language file addition
  htp.tablerowopen;
   if substr(c1rec.man_bf,22,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','22','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','22'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/printing.gif',cattributes=>'border=0',calt=>'Printing'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( 'Printing', cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;

  -- xxx language file addition
  htp.tablerowopen;
   if substr(c1rec.man_bf,23,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','23','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','23'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/man_pay.gif',cattributes=>'border=0',calt=>'Manual Purchase Order Payment'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.p( '<TD ' || 'valign="MIDDLE" ALIGN="LEFT">' );
    htp.p( 'Manual Purchase Order Payment' || ' ');
    -- Advanced Cashier Feature Enabled
    if substr(c1rec.man_bf,24,1) = 'T'
     then
      htp.formcheckbox( 'P7','24','CHECKED');
     else
      htp.formcheckbox( 'P7','24');
    end if;
    htp.p( LNG.PHG_TXT_212 );
   htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tablerowopen;
   if substr(c1rec.man_bf,5,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','5','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','5'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/clearance.gif',cattributes=>'border=0',calt=>LNG2.FNM_TXT_051),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( LNG2.FNM_TXT_051,cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   if substr(c1rec.man_bf,6,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','6','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','6'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/tender.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_001),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( LNG4.AHC_TXT_001,cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   if substr(c1rec.man_bf,7,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','7','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','7'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/reports.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_432),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( LNG.PHG_ALT_432,cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   if substr(c1rec.man_bf,8,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','8','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','8'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/forum.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_437),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( LNG.PHG_TXT_437,cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   if substr(c1rec.man_bf,12,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','12','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','12'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/album.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_453),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( LNG4.AHC_TXT_453,cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   if substr(c1rec.man_bf,13,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','13','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','13'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/frame.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_454),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( LNG4.AHC_TXT_454,cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   if substr(c1rec.man_bf,11,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','11','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','11'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/brand.gif',cattributes=>'border=0',calt=>LNG3.ADM_TXT_875),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( LNG3.ADM_TXT_875,cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  -- Advanced Report
  htp.tablerowopen;
   if substr(c1rec.man_bf,18,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','18','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','18'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/advrep.gif',cattributes=>'border=0',calt=>LNG5.EXT_TXT_547),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( LNG5.EXT_TXT_547,cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  -- Connect As
  htp.tablerowopen;
   if substr(c1rec.man_bf,19,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','19','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','19'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/connect.gif',cattributes=>'border=0',calt=>LNG3.ADM_TXT_040),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( LNG3.ADM_TXT_040,cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
   if c1rec.is_beta_tester = 'T'
    then
    htp.tablerowopen;
     if substr(c1rec.man_bf,9,1) = 'T'
      then
       htp.tabledata( htf.formcheckbox( 'P7','9','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
      else
       htp.tabledata( htf.formcheckbox( 'P7','9'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
     end if;
     htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'admin/bug.gif', cattributes=>'BORDER=0'), cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
     htp.tabledata( LNG4.AHC_TXT_126, cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   end if;
  htp.tablerowopen;
   if substr(c1rec.man_bf,10,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P7','10','CHECKED'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formcheckbox( 'P7','10'),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.img(DECS.IMAGE_LOCATION || 'admin/logoff.gif',cattributes=>'border=0',calt=>LNG.CST_ALT_021),cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( LNG.CST_ALT_021,cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 if manid = 0
  then
 	htp.formsubmit( 'PA',LNG3.ADM_TXT_089 );
  else
 	htp.formsubmit( 'PA',LNG3.ADM_TXT_090 );
 	htp.formsubmit( 'PA',LNG3.ADM_TXT_058 );
 end if;
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
end edit_mfc_details;

procedure acct_charge_left(surl varchar2)
as
 cursor c1 is select id,plan_name from charge_plan order by id;
 sessid	integer;
 sts	varchar2(200);
 oth	varchar2(2000);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCT_CHARGE_LEFT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_008, helpid=>'A11' );
 htp.nl;
 htp.p('<CENTER>');
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.acct_charge_right?surl=' || glbx.rndsurl(surl) || '&id=0',LNG3.ADM_TXT_092,ctarget=>'ADM_RIGHT') );
  htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.acct_charge_right?surl=' || glbx.rndsurl(surl) || '&id=' || c1rec.id,c1rec.plan_name,ctarget=>'ADM_RIGHT') );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.anchor2( 'adm.expired_acct?surl=' || glbx.rndsurl(surl),LNG3.ADM_TXT_093, ctarget=>'ADM_RIGHT' );
 htp.nl;
 htp.nl;
 htp.anchor2( 'adm.list_outstanding_invoices?surl=' || glbx.rndsurl(surl),LNG4.AHC_TXT_556, ctarget=>'ADM_RIGHT' );
 htp.nl;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ACCT_CHARGE_LEFT', errmsg=>sqlerrm, extdet=>null);
end acct_charge_left;

procedure expired_acct(surl varchar2)
as
 cursor c1 is select p.plan_id,cp.plan_name,p.username,p.date_expires,p.pid from photographer p,charge_plan cp where p.plan_id = cp.id and nvl(date_expires,sysdate+1000) < sysdate order by date_expires desc;
 sessid		integer;
 sts		varchar2(200);
 foundrec 	boolean;
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.EXPIRED_ACCT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_094, style=>'NOMENU', helpid=>'A12' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_249) );
   htp.tabledata( htf.bold(LNG3.ADM_TXT_063) );
   htp.tabledata( htf.bold(LNG3.ADM_TXT_096) );
  htp.tablerowclose;
 foundrec := FALSE;
 for c1rec in c1 loop
  foundrec := TRUE;
  htp.tablerowopen;
   htp.tabledata( htf.anchor( 'adm.acct_charge_right?surl=' || glbx.rndsurl(surl) || '&id=' || c1rec.plan_id, c1rec.plan_name ));
   htp.tabledata( htf.anchor( 'adm.phg_account?surl=' || glbx.rndsurl(surl) || '&phid=' || c1rec.pid || '&msg=', c1rec.username ));
   htp.tabledata( to_char(c1rec.date_expires,LNG3.ADM_DATE_02));
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 if not foundrec
  then
   htp.nl;
   htp.header(3,LNG3.ADM_TXT_097, 'CENTER' );
   htp.nl;
 end if;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'EXPIRED_ACCT', errmsg=>sqlerrm, extdet=>null);
end expired_acct;

procedure acct_charge_right( surl varchar2,id in integer default 0, msg in varchar2 default null )
as

 cursor c1(plan_id integer) is select * from charge_plan where id = plan_id order by id;
 cursor c2 is select id,plan_name from charge_plan order by id;
 cursor c3(plid integer) is select pid,username,date_expires from photographer where plan_id = plid order by date_expires desc, username;
 cursor c4(plid integer) is select * from charge_plan_event where plan_id = plid order by plan_event;
 cursor c5(plid integer) is select business_name,plan_event,qty from photographer ph, charge_plan_event_phg cpe where ph.plan_id = plid and cpe.pid = ph.pid;
 cursor c6 is select distinct novelty_set_name,novelty_set_id from novelty_set;
 cursor c7(plid integer, pev varchar2) is select * from charge_plan_event_bulk where plan_id = plid and plan_event = pev order by min_number;

 c1rec	c1%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);
 tmp	varchar2(2000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCT_CHARGE_RIGHT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_098, style=>'NOMENU', helpid=>'A13');
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 open c1(id);
 fetch c1 into c1rec;
 close c1;
 htp.formopen( 'adm.accept_charge' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.formhidden( 'PLAN_ID', id );
 htp.tableopen( cattributes=>'width="600" cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_099 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P1',40, 100, c1rec.plan_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.formhidden( 'P2','PICTION' );
  htp.tablerowopen;
     tmp := htf.formselectopen( 'P2A' );
	 if c1rec.payment_style = 'PER JOB'
	  then
	   tmp := tmp || htf.formselectoption( 'PER JOB', 'SELECTED' );
	  else
	   tmp := tmp || htf.formselectoption( 'PER JOB' );
	 end if;
	 if c1rec.payment_style = 'YEARLY'
	  then
	   tmp := tmp || htf.formselectoption( 'YEARLY', 'SELECTED' );
	  else
	   tmp := tmp || htf.formselectoption( 'YEARLY' );
	 end if;
	 if c1rec.payment_style = 'EVENT'
	  then
	   tmp := tmp || htf.formselectoption( 'EVENT', 'SELECTED' );
	  else
	   tmp := tmp || htf.formselectoption( 'EVENT' );
	 end if;
	 tmp := tmp || htf.formselectclose;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_100 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     tmp := htf.formselectopen( 'P2B' );
	 if c1rec.payment_target = 'PHOTOGRAPHER'
	  then
	   tmp := tmp || htf.formselectoption( 'PHOTOGRAPHER', 'SELECTED' );
	  else
	   tmp := tmp || htf.formselectoption( 'PHOTOGRAPHER' );
	 end if;
	 if c1rec.payment_target = 'OWNER'
	  then
	   tmp := tmp || htf.formselectoption( 'OWNER', 'SELECTED' );
	  else
	   tmp := tmp || htf.formselectoption( 'OWNER' );
	 end if;
	 if c1rec.payment_target = LNG.PHG_TXT_199
	  then
	   tmp := tmp || htf.formselectoption( LNG.PHG_TXT_199, 'SELECTED' );
	  else
	   tmp := tmp || htf.formselectoption( LNG.PHG_TXT_199 );
	 end if;
	 tmp := tmp || htf.formselectclose;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_101 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  tmp := htf.formselectopen( 'P2D' ) || htf.formselectoption( NULL );
  for c2rec in c2 loop
   if c2rec.id = c1rec.owner_plan_id
    then
     tmp := tmp || htf.formselectoption( c2rec.plan_name, 'SELECTED', cattributes=>'VALUE="' || c2rec.id || '"' );
    else
     tmp := tmp || htf.formselectoption( c2rec.plan_name, cattributes=>'VALUE="' || c2rec.id || '"' );
   end if;
  end loop;
  tmp := tmp || htf.formselectclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_102 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  tmp := htf.formselectopen( 'P2E' ) || htf.formselectoption( NULL );
  for c2rec in c2 loop
   if c2rec.id = c1rec.cust_plan_id
    then
     tmp := tmp || htf.formselectoption( c2rec.plan_name, 'SELECTED', cattributes=>'VALUE="' || c2rec.id || '"' );
    else
     tmp := tmp || htf.formselectoption( c2rec.plan_name, cattributes=>'VALUE="' || c2rec.id || '"' );
   end if;
  end loop;
  tmp := tmp || htf.formselectclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_103 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  tmp := htf.formselectopen( 'P2N' ) || htf.formselectoption( NULL );
  for c6rec in c6 loop
   if c6rec.novelty_set_id = c1rec.novelty_set_id
    then
     tmp := tmp || htf.formselectoption( c6rec.novelty_set_name, 'SELECTED', cattributes=>'VALUE="' || c6rec.novelty_set_id || '"' );
    else
     tmp := tmp || htf.formselectoption( c6rec.novelty_set_name, cattributes=>'VALUE="' || c6rec.novelty_set_id || '"' );
   end if;
  end loop;
  tmp := tmp || htf.formselectclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_301 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_104 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P2C',20, 20, c1rec.renewal_date ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_105 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtextareaopen('P3',3, 40, cattributes=>'WRAP="VIRTUAL"' ) || c1rec.description || htf.formtextareaclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_106 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P4',40, 100, c1rec.plan_cost ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_286 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P5',10, 20, c1rec.max_storage ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_108 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P6',10, 20, c1rec.max_accounts ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_109 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P7',10, 20, c1rec.max_photos ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_110 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P8',10, 20, c1rec.max_photo_size ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_111 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P9',10, 20, c1rec.days_to_expire ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_703 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('PWDA', 10, 20, c1rec.password_expiry_days ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_704 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('PWDB', 10, 20, c1rec.password_attempts ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.bold( LNG5.EXT_TXT_623 );
 htp.tableopen( cattributes=>'width="600" cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_625 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(LNG5.EXT_TXT_624,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('PR1',20, 100, to_char(c1rec.charge_mb_upload) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_626) || ' ' || htf.italic(LNG5.EXT_TXT_627),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(LNG5.EXT_TXT_624,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('PR2',20, 100, to_char(c1rec.charge_mb_original) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_626) || ' ' || htf.italic(LNG5.EXT_TXT_628),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(LNG5.EXT_TXT_624,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('PR3',20, 100, to_char(c1rec.charge_mb_ftp) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_626) || ' ' || htf.italic(LNG5.EXT_TXT_629),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(LNG5.EXT_TXT_624,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('PR4',20, 100, to_char(c1rec.charge_mb_rpc) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 if id = 0
  then
   htp.formsubmit( 'Pa', LNG3.ADM_TXT_112 );
  else
   htp.formsubmit( 'Pa', LNG3.ADM_TXT_113 );
   htp.formsubmit( 'Pa', LNG3.ADM_TXT_114 );
 end if;
 htp.nl;
 htp.formhidden( 'EV1', null );
 htp.formhidden( 'EV2', null );
 htp.formhidden( 'EV3', null );
 htp.formhidden( 'EV4', null );
 htp.formhidden( 'EV5', null );
 htp.formhidden( 'EV6', null );
 htp.formhidden( 'EV7', null );
 htp.formhidden( 'EV8', null );
 htp.formhidden( 'EV9', null );
 if c1rec.payment_style = 'YEARLY'
  then
   htp.nl;
   htp.nl;
   main_title( surl, sessid, LNG3.ADM_TXT_115, style=>'NOMENU', helpid=>'A13' );
   htp.nl;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG3.ADM_TXT_063 ) );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_096 ) );
   htp.tablerowclose;
   for c3rec in c3( id ) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'adm.phg_account?surl=' || glbx.rndsurl(surl) || '&phid=' || c3rec.pid || '&msg=', c3rec.username ) );
    if c3rec.date_expires < sysdate
     then
      htp.tabledata( nvl(to_char( c3rec.date_expires, LNG.MASK ),'&nbsp;') );
      htp.tabledata( LNG3.ADM_TXT_709 );
     else
      htp.tabledata( nvl(to_char( c3rec.date_expires, LNG.MASK ),'&nbsp;') );
      htp.tabledata( '&nbsp;' );
    end if;
   htp.tablerowclose;
   end loop;
   htp.tableclose;

  elsif c1rec.payment_style = 'EVENT'
   then
    htp.nl;
    htp.bold( LNG3.ADM_TXT_786 );
    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG3.ADM_TXT_787 ) );
      htp.tabledata( htf.bold( LNG3.ADM_TXT_788 ) );
      htp.tabledata( htf.bold( LNG.PHG_ALT_399 ) );
      htp.tabledata( htf.bold( LNG3.ADM_TXT_111) );
      htp.tabledata( htf.bold( LNG5.EXT_TXT_571) || htf.nl || LNG5.EXT_TXT_355 || ' - ' || LNG.PHG_ALT_399 );
     htp.tablerowclose;
     for c4rec in c4( id ) loop
      htp.tablerowopen;
       htp.tabledata( htf.formtext( 'EV1',30,100,c4rec.plan_event) );
       htp.tabledata( htf.formtext( 'EV2',10,20,c4rec.images_max), cattributes=>'align="CENTER"' );
       htp.tabledata( htf.formtext( 'EV4',10,20,to_char(c4rec.standard_charge,LNG.MONEY_FORMAT)), cattributes=>'align="CENTER"' );
       htp.tabledata( htf.formtext( 'EV5',5,20,c4rec.days_expires), cattributes=>'align="CENTER"' );
       htp.p( '<TD align="CENTER">' );
       htp.tableopen( cattributes=>'cellspacing=1 cellpadding=1 border=0' );
       for c7rec in c7(c4rec.plan_id, c4rec.plan_event) loop
        htp.tablerowopen;
         htp.formhidden( 'EV6', c4rec.plan_event );
         htp.tabledata( htf.formtext( 'EV7',5,10,c7rec.min_number));
         htp.tabledata( htf.formtext( 'EV8',5,10,c7rec.max_number));
         htp.tabledata( htf.formtext( 'EV9',8,10,trim(to_char(c7rec.standard_charge,LNG.MONEY_FORMAT))));
        htp.tablerowclose;
       end loop;
       for j in 1..2 loop
        htp.tablerowopen;
         htp.formhidden( 'EV6', c4rec.plan_event );
         htp.tabledata( htf.formtext( 'EV7',5,10));
         htp.tabledata( htf.formtext( 'EV8',5,10));
         htp.tabledata( htf.formtext( 'EV9',8,10));
        htp.tablerowclose;
       end loop;
       htp.tableclose;
       htp.p( '</TD>' );
       htp.formhidden( 'EV3', c4rec.plan_event );
      htp.tablerowclose;
     end loop;
     for j in 1..5 loop
      htp.tablerowopen;
       htp.tabledata( htf.formtext( 'EV1',30,100) );
       htp.tabledata( htf.formtext( 'EV2',10,20), cattributes=>'align="CENTER"' );
       htp.tabledata( htf.formtext( 'EV4',10,20), cattributes=>'align="CENTER"' );
       htp.tabledata( htf.formtext( 'EV5',5,20), cattributes=>'align="CENTER"' );
       htp.formhidden( 'EV3', NULL );
      htp.tablerowclose;
     end loop;
    htp.tableclose;
 end if;
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ACCT_CHARGE_RIGHT', errmsg=>sqlerrm, extdet=>null);
end acct_charge_right;

procedure accept_charge( surl varchar2, plan_id in integer, p1 in varchar2, p2 in varchar2, p2a in varchar2, p2b in varchar2, p2c in varchar2, p2d in varchar2, pr1 in varchar2, pr2 in varchar2, pr3 in varchar2, pr4 in varchar2,
                         p2e in varchar2, p2n in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2, p9 in varchar2,
                         pa in varchar2, pwda in varchar2, pwdb in varchar2, ev1 in GLBX.MYARRAY, ev2 in GLBX.MYARRAY, ev3 in GLBX.MYARRAY, ev4 in GLBX.MYARRAY, ev5 in GLBX.MYARRAY,
                         ev6 in GLBX.MYARRAY, ev7 in GLBX.MYARRAY, ev8 in GLBX.MYARRAY, ev9 in GLBX.MYARRAY )
as
 cursor c1( plid integer ) is select count('x') tot from photographer where plan_id = plid;
 sessid	integer;
 sts	varchar2(200);
 desct	varchar2(4000);
 maxid	integer;
 nmb		number;
 nmb2		number;
 nmb3		number;
 nmbpr1		number;
 nmbpr2		number;
 nmbpr3		number;
 nmbpr4		number;
 n2		integer;
 n3		integer;
 n5		integer;
 n6		integer;
 n7		integer;
 n8		integer;
 n9		integer;
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_CHARGE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if pa = LNG3.ADM_TXT_114
  then
   open c1( plan_id );
   fetch c1 into maxid;
   close c1;
   if nvl(maxid,0) > 0
    then
	 acct_charge_right( surl,plan_id, LNG3.ADM_TXT_116 || ' ' || maxid || ' ' || LNG3.ADM_TXT_117 );
	 return;
   end if;
   delete from charge_plan where id = plan_id;
   acct_charge_right( surl,0, LNG3.ADM_TXT_118 );
   return;
 end if;
 desct := substr( p3, 1, 4000 );
 if p1 is null then acct_charge_right( surl,plan_id, LNG3.ADM_TXT_119 ); return; end if;
 begin n2 := to_number(pwda); exception when others then acct_charge_right( surl,plan_id, LNG.PHG_TXT_210 || ': ' || p2); return; end;
 begin n3 := to_number(pwdb); exception when others then acct_charge_right( surl,plan_id, LNG.PHG_TXT_210 || ': ' || p3); return; end;
 begin n5 := to_number(p5); exception when others then acct_charge_right( surl,plan_id, LNG.PHG_TXT_210 || ': ' || p5); return; end;
 begin n6 := to_number(p6); exception when others then acct_charge_right( surl,plan_id, LNG.PHG_TXT_210 || ': ' || p6); return; end;
 begin n7 := to_number(p7); exception when others then acct_charge_right( surl,plan_id, LNG.PHG_TXT_210 || ': ' || p7); return; end;
 begin n8 := to_number(p8); exception when others then acct_charge_right( surl,plan_id, LNG.PHG_TXT_210 || ': ' || p8); return; end;
 n5 := nvl(n5,1000);
 n6 := nvl(n6,20);
 n7 := nvl(n7,1000);
 n8 := nvl(n8,100);
 n9 := nvl(n9,30);
 begin n9 := to_number(p9); exception when others then acct_charge_right( surl,plan_id,  LNG.PHG_TXT_210 || ': ' || p9); return; end;
 nmbpr1 := glbx.conv_nmb( pr1 );
 nmbpr2 := glbx.conv_nmb( pr2 );
 nmbpr3 := glbx.conv_nmb( pr3 );
 nmbpr4 := glbx.conv_nmb( pr4 );
 if plan_id = 0
  then
   select max(id) + 1 into maxid from charge_plan;
   maxid := nvl(maxid,1);
   insert into charge_plan(id,plan_name,payment_type,plan_cost,max_storage,max_accounts,max_photos,max_photo_size,days_to_expire,description,payment_style,payment_target, renewal_date, owner_plan_id, cust_plan_id, password_expiry_days, password_attempts, novelty_set_id,charge_mb_original,charge_mb_ftp,charge_mb_rpc,charge_mb_upload) values
    (maxid, p1, p2, p4, n5, n6, n7, n8, n9, desct, p2a, p2b, p2c, to_number(p2d),to_number(p2e), n2, n3, to_number(p2n),nmbpr1,nmbpr2,nmbpr3,nmbpr4 );
  else
   update charge_plan
    set
	 plan_name = p1,
	 payment_type = p2,
	 payment_style = p2a,
	 payment_target = p2b,
	 renewal_date = p2c,
	 owner_plan_id = to_number(p2d),
	 cust_plan_id = to_number(p2e),
	 novelty_set_id = to_number(p2n),
	 plan_cost = p4,
	 max_storage = n5,
	 max_accounts = n6,
	 max_photos = n7,
	 max_photo_size = n8,
	 days_to_expire = n9,
	 password_expiry_days = n2,
	 password_attempts = n3,
	 description = desct,
	 charge_mb_upload = nmbpr1,
	 charge_mb_original = nmbpr2,
	 charge_mb_ftp = nmbpr3,
	 charge_mb_rpc = nmbpr4
   where id = plan_id;
   maxid := plan_id;
 end if;
 if p2a = 'EVENT'
  then
   for j in ev1.first..ev1.last loop
    begin nmb := to_number(ev2(j)); exception when others then nmb := 1; end;
    nmb2 := glbx.conv_nmb( ev4(j) );
    nmb3 := glbx.conv_nmb( ev5(j) );
    if ev3(j) is null
     then
      if ev1(j) is not null
       then
        insert into charge_plan_event(plan_id,plan_event,images_max,standard_charge,days_expires)
         values
          (maxid,ev1(j),nmb,nmb2,nmb3);
      end if;
     else
      update charge_plan_event
       set
        plan_event = ev1(j),
        images_max = nmb,
        standard_charge = nmb2,
        days_expires = nmb3
       where
        plan_id = maxid and
        plan_event = ev3(j);
      update charge_plan_event_phg
       set
        plan_event = ev1(j)
       where
        plan_event = ev3(j) and
        plan_id = maxid;
    end if;
   end loop;
   delete from charge_plan_event where plan_event is null and plan_id = maxid;
   delete from charge_plan_event_bulk where plan_id = maxid;
   for k in ev6.first..ev6.last loop
    if ev6(k) is not null
     then
      nmb := glbx.conv_nmb( ev7(k) );
      nmb2 := glbx.conv_nmb( ev8(k) );
      nmb3 := glbx.conv_nmb( ev9(k) );
      if nmb is not null and nmb2 is not null and nmb3 is not null
       then
        insert into charge_plan_event_bulk(plan_id,plan_event,min_number,max_number,standard_charge)
         values(maxid,ev6(k),nmb,nmb2,nmb3);
      end if;
    end if;
   end loop;

 end if;
 commit;
 acct_charge_right( surl,maxid, LNG3.ADM_TXT_120);
exception
 when others then htp.p( sqlerrm );
end accept_charge;

procedure acct_mfc_leftx(surl varchar2)
as
 cursor c1 is select distinct man_type from manufacturer;
 sessid	integer;
 sts	varchar2(200);
 oth	varchar2(2000);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCT_MFC_LEFTX');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_121, helpid=>'A14' );
 htp.nl;
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.edit_mfc?surl=' || glbx.rndsurl(surl),LNG3.ADM_TXT_122,ctarget=>'ADM_RIGHT') );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.mfc_keys?surl=' || glbx.rndsurl(surl),LNG3.ADM_TXT_123,ctarget=>'ADM_RIGHT') );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.mfc_frames?surl=' || glbx.rndsurl(surl),LNG3.ADM_TXT_124,ctarget=>'ADM_RIGHT') );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.mfc_photo_size?surl=' || glbx.rndsurl(surl),LNG3.ADM_TXT_125,ctarget=>'ADM_RIGHT') );
  htp.tablerowclose;
  for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.acct_list_mfc?surl=' || glbx.rndsurl(surl) || '&st=' || c1rec.man_type,'[' || c1rec.man_type || ']',ctarget=>'ADM_RIGHT') );
  htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ACCT_MFC_LEFTX', errmsg=>sqlerrm, extdet=>null);
end acct_mfc_leftx;

procedure mfc_frames(surl varchar2)
as

 cursor c1 is select film_type,theme_type from film_types order by theme_type,film_type;
 cursor c2 is select theme_type from theme_types;
 cursor c3 is select distinct product_key from product_keys order by product_key;

 sessid	integer;
 sts	varchar2(200);
 tmp    varchar2(5000);
 tmp2    varchar2(5000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MFC_FRAMES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_126, helpid=>'A15');
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_mfc_frames' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_127), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( htf.bold( LNG.LAB_TXT_014), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   tmp := htf.formselectopen( 'P1' ) || htf.formselectoption( NULL );
   for c2rec in c2 loop
    if c2rec.theme_type = c1rec.theme_type
     then
      tmp := tmp || htf.formselectoption( c2rec.theme_type, 'SELECTED'  );
     else
      tmp := tmp || htf.formselectoption( c2rec.theme_type );
    end if;
   end loop;
   htp.tabledata( tmp || htf.formselectclose, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"'  );
   tmp := htf.formselectopen( 'P2' ) || htf.formselectoption( NULL );
   for c3rec in c3 loop
    if c3rec.product_key = c1rec.film_type
     then
      tmp := tmp || htf.formselectoption( c3rec.product_key, 'SELECTED'  );
     else
      tmp := tmp || htf.formselectoption( c3rec.product_key );
    end if;
   end loop;
   htp.tabledata( tmp || htf.formselectclose, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;
 end loop;
   tmp := htf.formselectopen( 'P1' ) || htf.formselectoption( NULL );
   for c2rec in c2 loop
    tmp := tmp || htf.formselectoption( c2rec.theme_type  );
   end loop;
   tmp := tmp || htf.formselectclose;
   tmp2 := htf.formselectopen( 'P2' ) || htf.formselectoption( NULL );
   for c3rec in c3 loop
    tmp2 := tmp2 || htf.formselectoption( c3rec.product_key );
   end loop;
   tmp2 := tmp2 || htf.formselectclose;
 for j in 1..10 loop
  htp.tablerowopen;
   htp.tabledata( tmp, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( tmp2, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit(null,LNG.GLB_TXT_060);
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MFC_FRAMES', errmsg=>sqlerrm, extdet=>null);
end mfc_frames;

procedure mfc_photo_size(surl varchar2)
as
 cursor c1 is select film_size from film_sizes;
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MFC_PHOTO_SIZE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_130, helpid=>'A16');
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_photo_size' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_131));
  htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1',10,10,c1rec.film_size));
  htp.tablerowclose;
 end loop;
 for j in 1..5 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1',10,10));
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit(null,LNG3.ADM_TXT_132);
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MFC_PHOTO_SIZE', errmsg=>sqlerrm, extdet=>null);
end mfc_photo_size;

procedure accept_photo_size( surl varchar2,p1 in myarray )
as
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_PHOTO_SIZE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 delete from film_sizes;
 for j in p1.first..p1.last loop
  if p1(j) is not null
   then
    insert into film_sizes(film_size) values (p1(j));
  end if;
 end loop;
 commit;
 mfc_photo_size(surl);
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_PHOTO_SIZE', errmsg=>sqlerrm, extdet=>null);
end accept_photo_size;

procedure accept_mfc_frames( surl varchar2,p1 in myarray, p2 in myarray )
as
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_MFC_FRAMES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 delete from film_types;
 for j in p1.first..p1.last loop
  if (p1(j) is not null) and (p2(j) is not null)
   then
    insert into film_types(theme_type,film_type) values (p1(j),p2(j));
  end if;
 end loop;
 commit;
 mfc_frames(surl);
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_MFC_FRAMES', errmsg=>sqlerrm, extdet=>null);
end accept_mfc_frames;

procedure list_all(surl varchar2)
as
 cursor c1 is select ph.pid,ph.username phuser,ca.aid,ca.username causer from customer_account ca,photographer ph where ca.pid = ph.pid order by ph.username,ca.username;
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.LIST_ALL');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_133, helpid=>'A17' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'border=1' );
 htp.tablerowopen;
  htp.tableheader( LNG3.ADM_TXT_261,cattributes=>glbx.QUERY_BACKGROUND );
  htp.tableheader( LNG3.ADM_TXT_135,cattributes=>glbx.QUERY_BACKGROUND );
  htp.tableheader( LNG3.ADM_TXT_136,cattributes=>glbx.QUERY_BACKGROUND );
 htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( htf.anchor2( 'adm.phg_connect_as?surl=' || glbx.rndsurl(surl) || '&phgid=' || c1rec.pid, c1rec.phuser, ctarget=>new_window || to_char(sysdate,'SSSSS') ) );
   htp.tabledata( htf.anchor2( 'adm.phg_connect_as?surl=' || glbx.rndsurl(surl) || '&phgid=' || c1rec.aid || '&typ=C', c1rec.causer, ctarget=>new_window || to_char(sysdate,'SSSSS')) );
   htp.tabledata( htf.anchor2( 'adm.phg_connect_as?surl=' || glbx.rndsurl(surl) || '&phgid=' || c1rec.aid || '&typ=G', c1rec.causer, ctarget=>new_window || to_char(sysdate,'SSSSS')) );
  htp.tablerowclose;
 end loop;
htp.tableclose;
 htp.p( '</CENTER>' );
htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'LIST_ALL', errmsg=>sqlerrm, extdet=>null);
end list_all;

/*
procedure mfc_forms(surl varchar2,manid integer)
as
 --cursor c1(manid integer) is select formname from man_forms where manufacturer_id = manid;
 cursor c2(manid integer) is select username from manufacturer where manufacturer_id = manid;
 sessid	integer;
 sts	varchar2(200);
 tmp    varchar2(5000);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MFC_FORMS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_140, style=>'NOMENU', helpid=>'A19');
 htp.formopen( 'adm.accept_mfc_forms' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.formhidden( 'MANID', manid );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_141));
  htp.tablerowclose;

 for c1rec in c1(manid) loop
  htp.tablerowopen;
   tmp := htf.formselectopen( 'P1' ) || htf.formselectoption( NULL );
   for c2rec in c2(manid) loop
    if c2rec.formname = c1rec.formname
     then
      tmp := tmp || htf.formselectoption( c2rec.formname, 'SELECTED'  );
     else
      tmp := tmp || htf.formselectoption( c2rec.formname );
    end if;
   end loop;
   htp.tabledata( tmp || htf.formselectclose );
  htp.tablerowclose;
 end loop;

   tmp := htf.formselectopen( 'P1' ) || htf.formselectoption( NULL );
   for c2rec in c2(manid) loop
    tmp := tmp || htf.formselectoption( c2rec.formname  );
   end loop;
   tmp := tmp || htf.formselectclose;
 for j in 1..5 loop
  htp.tablerowopen;
   htp.tabledata( tmp );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit(null,LNG3.ADM_TXT_142);
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MFC_FORMS', errmsg=>sqlerrm, extdet=>null);
end mfc_forms;

procedure accept_mfc_forms( surl varchar2,manid integer, p1 in myarray )
as
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_MFC_FORMS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 --delete from man_forms where manufacturer_id = manid;
 for j in p1.first..p1.last loop
  if p1(j) is not null
   then
    insert into man_forms(manufacturer_id,formname) values (manid,p1(j));
  end if;
 end loop;
 commit;
 mfc_forms(surl,manid);
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_MFC_FORMS', errmsg=>sqlerrm, extdet=>null);
end accept_mfc_forms;
*/

procedure acct_list_photo( surl varchar2,st in varchar2, typ in varchar2 default LNG.GLB_TXT_076 )
as

 cursor c1( c1 varchar2, c2 varchar2, c3 in varchar2 ) is
  select pid,date_created,username,business_name,ftp_load_dir,plan_id
  from photographer
  where upper(substr(decode(c3,LNG.GLB_TXT_076,upper(username),upper(business_name)),1,1)) >= c1 and
        upper(substr(decode(c3,LNG.GLB_TXT_076,upper(username),upper(business_name)),1,1)) <= c2
  order by decode(c3,LNG.GLB_TXT_076,upper(username),upper(business_name));
 cursor c2( phgid integer ) is select count('x') tot from customer_account where pid = phgid;
 cursor c3( plid integer ) is select plan_name from charge_plan where id = plid;

 c2rec	c2%ROWTYPE;
 c3rec	c3%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);
 ctr	integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCT_LIST_PHOTO');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_143, helpid=>'A20' );
 htp.nl;
 htp.p( '<CENTER>' );
 ctr := 1;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0 ' || GLBX.QUERY_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.mng_photographer?surl=' || glbx.rndsurl(surl), LNG3.ADM_TXT_144,ctarget=>'ADM_BOTTOM'),cattributes=>GLBX.QUERY_BACKGROUND );
   htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND );
   htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND );
   htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND );
   htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND );
   htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND );
  htp.tablerowclose;
 if st <> '0'
  then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG3.ADM_TXT_127), cattributes=>GLBX.QUERY_BACKGROUND );
     htp.tabledata( htf.bold(LNG.GLB_TXT_076), cattributes=>GLBX.QUERY_BACKGROUND );
     htp.tabledata( htf.bold(LNG.GLB_TXT_078), cattributes=>GLBX.QUERY_BACKGROUND );
     htp.tabledata( htf.bold(LNG.LAB_TXT_039), cattributes=>GLBX.QUERY_BACKGROUND );
     htp.tabledata( htf.bold(LNG.PHG_TXT_249), cattributes=>GLBX.QUERY_BACKGROUND );
     htp.tabledata( htf.bold(LNG2.PFM_TXT_051), cattributes=>GLBX.QUERY_BACKGROUND );
    htp.tablerowclose;
   for c1rec in c1(substr(st,1,1),substr(st,2,1),typ) loop
    htp.tablerowopen;
     htp.tabledata( htf.anchor2('adm.mng_photographer?surl=' || glbx.rndsurl(surl) || '&phgid=' || c1rec.pid,c1rec.business_name,ctarget=>new_window),cattributes=>GLBX.QUERY_CELL_BACKGROUND );
     htp.tabledata( htf.italic(c1rec.username), cattributes=>GLBX.QUERY_CELL_BACKGROUND );
     htp.tabledata( to_char(c1rec.date_created,'DD-Month-YYYY'),cattributes=>GLBX.QUERY_CELL_BACKGROUND );
     c2rec.tot := 0;
     open c2( c1rec.pid );
     fetch c2 into c2rec;
     close c2;
     c3rec.plan_name := 0;
     open c3( c1rec.plan_id );
     fetch c3 into c3rec;
     close c3;
     htp.tabledata( to_char(c2rec.tot),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="CENTER"');
     htp.tabledata( c3rec.plan_name,cattributes=>GLBX.QUERY_CELL_BACKGROUND );
     htp.tabledata( nvl(c1rec.ftp_load_dir,'&nbsp;'),cattributes=>GLBX.QUERY_CELL_BACKGROUND );
    htp.tablerowclose;
   end loop;
  end if;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ACCT_LIST_PHOTO', errmsg=>sqlerrm, extdet=>null);
end acct_list_photo;

/*
procedure edit_mfc(surl varchar2)
as
 cursor c1 is select * from man_options order by man_type,man_option;
 cursor c2 is select distinct man_type from man_options;
 sessid	integer;
 sts	varchar2(200);
 ctr	integer;
 tmp	varchar2(1000);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.EDIT_MFC');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_122, helpid=>'A21' );
 htp.p('<CENTER>');
 htp.nl;
 htp.tableopen( cattributes=>'width="600" cellpadding=2 cellspacing=0 border=1 ' || GLBX.TABLE_BACKGROUND );
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG3.ADM_TXT_146 ), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold( LNG3.ADM_TXT_147 ), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 htp.formopen( 'adm.accept_edit_mfc' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 for c1rec in c1 loop
 htp.tablerowopen;
  tmp := htf.formselectopen( 'P1' );
  for c2rec in c2 loop
   if c2rec.man_type = c1rec.man_type
    then
     tmp := tmp || htf.formselectoption( c2rec.man_type,'SELECTED' );
    else
     tmp := tmp || htf.formselectoption( c2rec.man_type );
   end if;
  end loop;
  htp.tabledata( tmp || htf.formselectclose, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.formtext( 'P2', 20, 40, c1rec.man_option),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 end loop;
 for j in 1..5 loop
  htp.tablerowopen;
  tmp := htf.formselectopen( 'P1' );
  for c2rec in c2 loop
   tmp := tmp || htf.formselectoption( c2rec.man_type );
  end loop;
  htp.tabledata( tmp || htf.formselectclose, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.formtext( 'P2', 20, 40, null), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_148 );
 htp.formclose;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'EDIT_MFC', errmsg=>sqlerrm, extdet=>null);
end edit_mfc;

procedure accept_edit_mfc( surl varchar2,p1 in myarray, p2 in myarray )
as
 sessid	integer;
 sts	varchar2(200);
 ctr	integer;
 tmp	varchar2(1000);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_EDIT_MFC');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 delete from man_options;
 for j in p1.first..p1.last loop
  if p2(j) is not null
   then
    insert into man_options(man_type,man_option) values (p1(j),p2(j));
  end if;
 end loop;
 commit;
 edit_mfc(surl);
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_EDIT_MFC', errmsg=>sqlerrm, extdet=>null);
end accept_edit_mfc;
*/

procedure mfc_keys(surl varchar2)
as
 cursor c1 is select man_type,product_key from product_keys order by man_type,product_key;
 cursor c2 is select man_type from man_options;
 cursor c3(ft varchar2) is select theme_type from film_types where film_type = ft;
 sessid	integer;
 sts	varchar2(200);
 ctr	integer;
 tmp	varchar2(1000);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MFC_KEYS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_149, helpid=>'A22' );
 htp.p('<CENTER>');
 htp.nl;
 htp.tableopen( cattributes=>'width="50%" cellpadding=2 cellspacing=0 border=1 ' || GLBX.TABLE_BACKGROUND );
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG3.ADM_TXT_150 ), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold( LNG.LAB_TXT_014 ), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold( LNG3.ADM_TXT_152 ), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 htp.formopen( 'adm.accept_mfc_keys' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 for c1rec in c1 loop
 htp.tablerowopen;
  tmp := htf.formselectopen( 'P1' );
  for c2rec in c2 loop
   if c2rec.man_type = c1rec.man_type
    then
     tmp := tmp || htf.formselectoption( c2rec.man_type,'SELECTED' );
    else
     tmp := tmp || htf.formselectoption( c2rec.man_type );
   end if;
  end loop;
  htp.tabledata( tmp || htf.formselectclose, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.formtext( 'P2', 20, 40, c1rec.product_key), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  if c1rec.man_type = 'LAB'
   then
    tmp := NULL;
    for c3rec in c3(c1rec.product_key) loop
     tmp := tmp || ',' || c3rec.theme_type;
    end loop;
    htp.tabledata( nvl(substr(tmp,2),'&nbsp;'), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   else
    htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  end if;
 htp.tablerowclose;
 end loop;
 for j in 1..5 loop
  htp.tablerowopen;
  tmp := htf.formselectopen( 'P1' );
  for c2rec in c2 loop
   tmp := tmp || htf.formselectoption( c2rec.man_type );
  end loop;
  htp.tabledata( tmp || htf.formselectclose, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.formtext( 'P2', 20, 40, null), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_153 );
 htp.formclose;
 htp.p('</CENTER>');
 htp.htmlclose;
end mfc_keys;

procedure accept_mfc_keys( surl varchar2,p1 in myarray, p2 in myarray )
as
 sessid	integer;
 sts	varchar2(200);
 ctr	integer;
 tmp	varchar2(1000);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_MFC_KEYS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 delete from product_keys;
 for j in p1.first..p1.last loop
  if p2(j) is not null
   then
    insert into product_keys(man_type,product_key) values (p1(j),p2(j));
  end if;
 end loop;
 commit;
 mfc_keys(surl);
exception when others then
 glbx.error_details( 'ADM', 'MFC_KEYS', errmsg=>sqlerrm, extdet=>null);
end accept_mfc_keys;

procedure acct_list_mfc( surl varchar2, st in varchar2 )
as
 cursor c1( code1 varchar2, code2 varchar2 ) is
  select manufacturer_id,date_created,username,name
  from manufacturer
  where substr(username,1,1) >= code1 and substr(username,1,1) <= code2
  order by upper(name);
 sessid	integer;
 sts	varchar2(200);
 ctr	integer;
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCT_LIST_MFC');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_154, helpid=>'A23' );
 htp.nl;
 htp.p( '<CENTER>' );
 ctr := 2;
 htp.htmlopen;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0 ' || GLBX.QUERY_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.mng_mfc?surl=' || glbx.rndsurl(surl), LNG3.ADM_TXT_155,ctarget=>'ADM_BOTTOM'),cattributes=>GLBX.QUERY_BACKGROUND );
   htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND );
   htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND );
  htp.tablerowclose;
 if st <> '0'
  then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG3.ADM_TXT_261), cattributes=>GLBX.QUERY_BACKGROUND );
     htp.tabledata( htf.bold(LNG.GLB_TXT_076), cattributes=>GLBX.QUERY_BACKGROUND );
     htp.tabledata( htf.bold(LNG.GLB_TXT_078), cattributes=>GLBX.QUERY_BACKGROUND );
    htp.tablerowclose;
    for c1rec in c1(substr(st,1,1),substr(st,2,1)) loop
     htp.tablerowopen;
      htp.tabledata( htf.anchor2('adm.mng_mfc?surl=' || glbx.rndsurl(surl) || '&manid=' || c1rec.manufacturer_id,c1rec.name,ctarget=>new_window),cattributes=>GLBX.QUERY_CELL_BACKGROUND );
      htp.tabledata( htf.italic(c1rec.username), cattributes=>GLBX.QUERY_CELL_BACKGROUND );
      htp.tabledata( to_char(c1rec.date_created,'DD-Month-YYYY'),cattributes=>GLBX.QUERY_CELL_BACKGROUND );
    htp.tablerowclose;
   end loop;
  end if;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
end acct_list_mfc;

procedure acct_bottom( surl varchar2, msg in varchar2 )
as

 cursor c2 is select * from phg_batch_upload where status <> LNG2.PFM_TXT_062 order by date_submitted asc;
 cursor c3(uscid integer) is select title from umo_scene where umo_scene_id = uscid;
 cursor c4 is select job,next_date,what,schema_user from all_jobs where upper(what) like 'ADM.ACCEPT%' order by next_date desc;
 cursor c5(acid integer) is select business_name,account_name,ftp_load_dir, ca.username uname1, ph.username uname2 from customer_account ca,photographer ph where ca.pid = ph.pid and ca.aid = acid;
 cursor c6 is
  select business_name,account_name,po.date_created,po.poid
  from login_session ls, purchase_order po, customer_account ca, photographer ph
  where ca.pid = ph.pid and
        ca.aid = ls.aid and
        ls.sessid = po.sessid and
        po.pid = ph.pid and
        ((po.date_created >= trunc(sysdate-1) and to_char(sysdate,'DY') in ('TUE','WED','THU','FRI') ) or
         (po.date_created >= trunc(sysdate-3) and to_char(sysdate,'DY') in ('MON','SUN','SAT') )) and
        po.status in ( 'Ordered','Order Authorised','Order Payment Received' )
  union
  select business_name,account_name,po.date_created,po.poid
  from login_session ls, purchase_order po, customer_profile cp, photographer ph
  where cp.pid = ph.pid and
        cp.profile_id = ls.aid and
        ls.sessid = po.sessid and
        po.pid = ph.pid and
        ((po.date_created >= trunc(sysdate-1) and to_char(sysdate,'DY') in ('TUE','WED','THU','FRI') ) or
         (po.date_created >= trunc(sysdate-3) and to_char(sysdate,'DY') in ('MON','SUN','SAT') )) and
        po.status in ( 'Ordered','Order Authorised','Order Payment Received' )
  order by 3 desc;
 cursor c7 is select count('x') tot from charge_plan_invoice where invoice_rec = 'F' and invoice_sent = 'F';
 cursor c8( vload_id integer ) is select 'x' exst from phg_batch_upload_parms where load_id = vload_id and parm3 = 'TERMINATE_PROGRAM';

 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c8rec		c8%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 uscid		integer;
 ctr		integer;
 x		integer;
 lastx		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCT_BOTTOM');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 disp_menu(surl,sessid,null);
 htp.nl;
 htp.nl;
 --open c1;
 --fetch c1 into c1rec;
 --close c1;
 -- Display Header (who this box is)
 htp.header(2,LNG3.ADM_TXT_656 || ' : ' || glbx.extract_master_parameter('NODE_NAME') || ' [' || GLBX.CURRENT_VERSION || ']','CENTER' );
 htp.nl;

 -- Display any New Orders in the last Since yesterday midnight
 htp.bold( LNG3.ADM_TXT_778 );
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
  htp.tablerowopen;
     htp.tabledata( htf.bold( LNG.CST_TXT_099), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( LNG3.ADM_TXT_261), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( LNG.PHG_TXT_199), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( LNG.GLB_TXT_078), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  for c6rec in c6 loop
   htp.tablerowopen;
     htp.tabledata( htf.bold(c6rec.poid), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( c6rec.business_name, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( c6rec.account_name, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( to_char( c6rec.date_created,LNG.TSMASK), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.anchor2( 'adm.dispord?surl=' || glbx.rndsurl(surl) || '&purchid=' || c6rec.poid, LNG3.ADM_TXT_780, ctarget=>new_window ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 -- Display All Jobs Waiting to Run by the Administrator

 -- Display All Jobs Waiting to Run by Photographers
 htp.bold( LNG2.PFM_TXT_058 );
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
  htp.tablerowopen;
     htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( LNG.PHG_TXT_348), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( LNG3.ADM_TXT_261), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( LNG.PHG_TXT_199), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( LNG2.PFM_TXT_050), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( LNG.PHG_TXT_356), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( LNG.PHG_ALT_394), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold( LNG.SLD_TXT_087), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( LNG2.PFM_TXT_051), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( LNG.PHG_TXT_217), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( LNG3.ADM_TXT_332), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( LNG2.PFM_TXT_052), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( LNG2.PFM_TXT_059), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;

  for c4rec in c4 loop
  htp.tablerowopen;
     open c5(getprm(c4rec.what,'p1'));
     fetch c5 into c5rec;
     close c5;
     if substr(getprm(c4rec.what,'p12'),1,1) = '['
      then
       c3rec.title := getprm(c4rec.what,'p12');
      else
       open c3(getprm(c4rec.what,'p12'));
       fetch c3 into c3rec;
       close c3;
     end if;
     htp.tabledata( htf.bold(LNG3.ADM_TXT_779), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( c4rec.schema_user, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( c5rec.business_name, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( c5rec.account_name, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( to_char( c4rec.next_date,LNG.TSMASK), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( getprm(c4rec.what,'p29'), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( getprm(c4rec.what,'p30'), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( to_char(c4rec.next_date,LNG.TSMASK), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( getprm(c4rec.what,'p2'), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( getprm(c4rec.what,'p6'), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( getprm(c4rec.what,'p7a'), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( c3rec.title, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold(LNG2.PFM_TXT_060), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( LNG5.EXT_TXT_130, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  end loop;

  for c2rec in c2 loop
  htp.tablerowopen;
   open c5(c2rec.aid);
   fetch c5 into c5rec;
   close c5;
   htp.tabledata( htf.anchor( 'adm.mngbatch?surl=' || glbx.rndsurl(surl) || '&vload_id=' || c2rec.load_id || '&action=TERMINATE', 'Stop Load Cleanly') || htf.nl ||
                  htf.anchor( 'adm.mngbatch?surl=' || glbx.rndsurl(surl) || '&vload_id=' || c2rec.load_id || '&action=DELETE', LNG3.ADM_TXT_776) || htf.nl ||
                  htf.anchor( 'adm.mngbatch?surl=' || glbx.rndsurl(surl) || '&vload_id=' || c2rec.load_id || '&action=RUNNOW', LNG2.PFM_TXT_121) || htf.nl ||
                  htf.anchor2( 'glbx.displog?surl=' || glbx.rndsurl(surl) || '&acid=' || c2rec.aid, 'View Load Log', ctarget=>new_window ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" align="LEFT"' );
   htp.tabledata( user, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" align="LEFT"' );
   htp.tabledata( c5rec.business_name || '(' || c5rec.uname2 || ')', cattributes=>glbx.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" align="LEFT"' );
   htp.tabledata( c5rec.account_name || '(' || c5rec.uname1 || ')', cattributes=>glbx.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" align="LEFT"' );
   htp.tabledata( to_char( c2rec.date_submitted,LNG.TSMASK), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" align="LEFT"' );
   c8rec.exst := 'F';
   open c8(c2rec.load_id);
   fetch c8 into c8rec;
   close c8;
   if c8rec.exst = 'x'
    then
     htp.tabledata( 'Terminate Command Received', cattributes=>glbx.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" align="LEFT"' );
    else
     htp.tabledata( c2rec.status, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" align="LEFT"' );
   end if;
  htp.tablerowclose;

  end loop;

 htp.tableclose;
 htp.nl;
 htp.nl;
 open c7;
 fetch c7 into c7rec;
 close c7;
 if c7rec.tot > 0
  then
   htp.nl;
   htp.bold( htf.anchor2( 'adm.list_outstanding_invoices?surl=' || surl, LNG4.AHC_TXT_556 || ' : ' || c7rec.tot, ctarget=>'ADM_RIGHT' ));
   htp.nl;
 end if;

 /* Commented out, as some browsers have problems with the Javascript
 htp.p( '<CENTER>' );
 htp.bold( '<a href="" onClick="document.location.reload()">' || LNG3.ADM_TXT_903 || '</a>'); htp.nl;
 htp.p( '</CENTER>' );
 */
 htp.htmlclose;

exception when others then
 glbx.error_details( 'ADM', 'ACCT_BOTTOM', errmsg=>sqlerrm, extdet=>null);
end acct_bottom;

function getprm( val in varchar2, ky in varchar2 )
 return varchar2
as
 x integer;
 y integer;
begin

 x := instr(val,ky || '=>');
 y := instr(val,',',x+1,1);
 return( replace(substr(val,x+2+length(ky),(((y-x)-length(ky))-2)),'''','') );

end getprm;

procedure mngbatch( surl varchar2, vload_id integer, action in varchar2 )
as

  cursor c1( vload_id integer) is select * from phg_batch_upload where load_id = vload_id;
  cursor c2(phgid integer) is select ftp_load_dir from photographer where pid = phgid;

  id 		integer;
  c1rec		c1%ROWTYPE;
  c2rec		c2%ROWTYPE;
  sessid	integer;
  sts		varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MNGBATCH');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 --
 if action = 'DELETE'
  then
   delete from phg_batch_upload where load_id = vload_id;
   delete from phg_batch_upload_parms where load_id = vload_id;

 elsif action = 'TERMINATE'
  then
   delete from phg_batch_upload_parms where load_id = vload_id and parm3 = 'TERMINATE_PROGRAM';
   insert into phg_batch_upload_parms(load_id,parm3) values (vload_id,'TERMINATE_PROGRAM');
   commit;

 elsif action = 'RUNNOW'
  then
    open c1(vload_id);
    fetch c1 into c1rec;
    close c1;
    open c2(c1rec.pid);
    fetch c2 into c2rec;
    close c2;
    update phg_batch_upload
     set
      status = LNG2.PFM_TXT_062
     where load_id = vload_id;

     dbms_job.submit(id,'adm.run_load_job(surl=>''' || glbx.encrypt_password( c1rec.load_id ) || ''',vload_id=>' || c1rec.load_id || ', runfrom=>''BATCH'');' );
      commit;
 end if;
 commit;
 acct_bottom( surl, NULL );
exception when others then
 glbx.error_details( 'ADM', 'MNGBATCH', errmsg=>sqlerrm);
end mngbatch;

procedure acct_logoff(surl varchar2,msg in varchar2 default null)
as
 sess_id	integer;
 sts		varchar2(200);
 oth		varchar2(2000);
begin
 glbx.adm_cookie_id( surl,sess_id,sts,'ACCT_LOGOFF');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if msg is null
  then
   update login_session set is_connected = 'F' where sessid = sess_id;
 end if;
 commit;
 htp.htmlopen;
 htp.print('<BODY BGCOLOR="#' || GLBX.QUERY_CELL_BACKGROUND1 || '">');
 htp.p( '<CENTER>' );
  if msg is not null
   then
    glbx.header_msg(msg);
    htp.nl;
  end if;
  htp.bold( LNG3.ADM_TXT_157 );
  htp.nl;
  htp.nl;
  htp.anchor( 'adm.test_page?id=' || DECS.PW_RESET, LNG3.ADM_TXT_158 );
  htp.nl;
  htp.nl;
  htp.anchor( 'glbx.login_page', LNG3.ADM_TXT_159 );
  htp.nl;
  htp.nl;
  htp.italic( LNG3.ADM_TXT_160 );
  htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ACCT_LOGOFF', errmsg=>sqlerrm, extdet=>null);
end acct_logoff;


procedure main_title( surl varchar2, acct in integer, ttl in varchar2, other_elements in varchar2 default null, style in varchar2 default 'BIG', helpid in varchar2 default null )
as

ttlc	varchar2(100);

begin
 if style in ('NOMENU','NOMENUX')
  then
   htp.htmlopen;
   htp.print( '<BODY BGCOLOR="#FFFFFF" TOPMARGIN="1">' );
   htp.title( ttl );
  else
   disp_menu(surl,acct,ttl);
   htp.nl;
 end if;

 if style in ('BIG','NOMENU','NOMENUX')
  then
   ttlc := glbx.extract_master_parameter('TITLE_BAR_COLOUR');
   htp.tableopen( cattributes=>'width="100%" cellpadding=2 cellspacing=0 border=0 bgcolor="#' || ttlc || '"' );
    htp.tablerowopen;
     if style = 'NOMENU'
      then
       htp.tabledata( '<a href="" onClick="parent.close()">' || htf.img( DECS.IMAGE_LOCATION || 'admin/close.gif',cattributes=>'border=0',calt=>LNG.GLB_TXT_033 ) || '</a>',cattributes=>'bgcolor="#' || ttlc || '" valign="TOP" align="LEFT"' );
     end if;
     htp.tabledata('<b><font size="+1" color="#FFFFFF">' || ttl || '</font></b>',cattributes=>'bgcolor="#' || ttlc || '"' || 'valign="TOP" align="CENTER"');
     if helpid is not null
      then
       htp.tabledata( htf.anchor2( 'glbx.show_help?surl=' || glbx.rndsurl(surl) || '&helpid=' || helpid || '&logtyp=ADMIN',htf.img( DECS.IMAGE_LOCATION || 'admin/help.gif',cattributes=>' border=0',calt=>LNG.GLB_ALT_071),ctarget=>'HELP_WINDOW' ),
                      cattributes=>'bgcolor="#' || ttlc || '"' || '" valign="MIDDLE" align="CENTER" width="5%"');
     end if;
     if other_elements is not null
      then
	   htp.p( other_elements );
     end if;
    htp.tablerowclose;
   htp.tableclose;
 elsif style = 'SIMPLE'
  then
   htp.bold( ttl );
   htp.nl;
 end if;
exception when others then
 glbx.error_details( 'ADM', 'MAIN_TITLE', errmsg=>sqlerrm, extdet=>null);
end main_title;


procedure joshua( id in varchar2 )
as
 pw	varchar2(30);
begin
 if nvl(id,'x') <> DECS.PW_RESTART
  then
   htp.htmlopen;
   htp.htmlclose;
   return;
 end if;
 pw := glbx.encrypt( DECS.PW_DEFAULT, special_key=>DECS.ADMIN_ENCRYPT_KEY );
 update master_parameters set parm_value = pw where parm_name = 'ADMIN_PW';
 update master_parameters set parm_value = NULL where parm_name = 'ADMIN_IPRESTRICT';
 insert into audit_master_parameters(parm_name,date_updated,old_value,new_value,sessid) values ( 'ADMIN_PW', sysdate, null, pw, 0 );
 insert into audit_master_parameters(parm_name,date_updated,old_value,new_value,sessid) values ( 'ADMIN_IPRESTRICT', sysdate, null, null, 0 );


 -- update master_piction set admin_pw = pw;
 commit;
   htp.htmlopen;
    htp.bold( LNG3.ADM_TXT_161 );
   htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'JOSHUA', errmsg=>sqlerrm, extdet=>null);
end joshua;

procedure create_photographer( surl varchar2, vid in integer, un in varchar2, pw in varchar2, bnm in varchar2, plid in varchar2, ttype in varchar2, sts out varchar2, newid out integer )
 as
  cursor c1 is select username from customer_account where username = upper(rtrim(un));
  cursor c2 is select username from photographer where username = upper(rtrim(un));
  cursor c3 is select username from manufacturer where username = upper(rtrim(un));

  c1rec		c1%ROWTYPE;
  c2rec		c2%ROWTYPE;
  c3rec		c3%ROWTYPE;
  npw		varchar2(100);

 begin
  -- Check if the account already exists
  if un is null
   then
    sts := LNG3.ADM_TXT_162;
    return;
  end if;
  if pw is null
   then
    sts := LNG3.ADM_TXT_163;
    return;
  end if;

  open c1;
  fetch c1 into c1rec;
  if c1%FOUND
   then
    close c1;
    sts := LNG3.ADM_TXT_164;
    return;
  end if;
  close c1;

  open c2;
  fetch c2 into c2rec;
  if c2%FOUND
   then
    close c2;
    sts := LNG3.ADM_TXT_165;
    return;
  end if;
  close c2;

  open c3;
  fetch c3 into c3rec;
  if c3%FOUND
   then
    close c3;
    sts := LNG3.ADM_TXT_166;
    return;
  end if;
  close c3;

  npw := glbx.encrypt( upper( pw ), special_key=>DECS.GENERAL_ENCRYPT_KEY || DECS.RANDOM_NUMBER );
  select s_customer_profile.nextval into newid from dual;

  insert into photographer( id, pid, username, password, plan_id, date_created, business_name, theme_type )
   values (vid, newid, upper(rtrim(un)), npw, plid, sysdate, bnm, ttype );
 insert into audit_photographer_password(pid,date_changed,pw) values (newid,sysdate,upper(pw));

  commit;

 exception
  when others
   then
    sts := sqlerrm;
    return;
 end create_photographer;

procedure create_mfc( surl varchar2,un in varchar2, pw in varchar2, bnm in varchar2, plid in varchar2, ttype in varchar2, fpriv in varchar2, sts out varchar2, newid out integer )
 as
  cursor c1 is select username from customer_account where username = upper(un);
  cursor c2 is select username from photographer where username = upper(un);
  cursor c3 is select username from manufacturer where username = upper(un);

  c1rec		c1%ROWTYPE;
  c2rec		c2%ROWTYPE;
  c3rec		c3%ROWTYPE;
  npw		varchar2(100);

 begin
  -- Check if the account already exists
  if un is null
   then
    sts := LNG3.ADM_TXT_162;
    return;
  end if;
  if pw is null
   then
    sts := LNG3.ADM_TXT_163;
    return;
  end if;
  open c1;
  fetch c1 into c1rec;
  if c1%FOUND
   then
    close c1;
    sts := LNG3.ADM_TXT_164;
    return;
  end if;
  close c1;

  open c2;
  fetch c2 into c2rec;
  if c2%FOUND
   then
    close c2;
    sts := LNG3.ADM_TXT_165;
    return;
  end if;
  close c2;

  open c3;
  fetch c3 into c3rec;
  if c3%FOUND
   then
    close c3;
    sts := LNG3.ADM_TXT_166;
    return;
  end if;
  close c3;

  npw := glbx.encrypt( upper( pw ), special_key=>DECS.GENERAL_ENCRYPT_KEY || DECS.RANDOM_NUMBER );
  select s_customer_profile.nextval into newid from dual;

  insert into manufacturer( manufacturer_id, username, password, man_type, date_created, name, theme_name, forum_priv )
   values (newid, upper(rtrim(un)), npw, plid, sysdate, bnm, ttype, fpriv );
 insert into audit_manufacturer_password(manufacturer_id,date_changed,pw) values (newid,sysdate,upper(pw));

  commit;

 exception
  when others
   then
    sts := sqlerrm;
    return;
 end create_mfc;

procedure mnt_scene(surl varchar2)
as
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MNT_SCENE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
  htp.htmlopen;
  htp.p( '<HEAD>' );
  htp.title( glbx.extract_master_parameter('MENU_TITLE') );
  htp.p( '</HEAD>' );
  htp.framesetopen('100%','20%,80%',cattributes=>'frameborder="1" framespacing="0" border="1"');
   htp.frame( 'adm.scene_left?surl=' || glbx.rndsurl(surl) || '&','ADM_LEFT_WIN');
   htp.frame( 'adm.scene_right?surl=' || glbx.rndsurl(surl) || '&msg=' || translate( LNG3.ADM_TXT_168,' ','+'),'ADM_RIGHT_WIN');
  htp.framesetclose;
  htp.p( '<BODY>' );
  htp.noframesopen;
   glbx.noframe(surl,'ADM.MNT_SCENE');
  htp.noframesclose;
  htp.p( '</BODY>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MNT_SCENE', errmsg=>sqlerrm, extdet=>null);
end mnt_scene;

procedure scene_left(surl varchar2)
as
 cursor c1 is select scene_name from scene order by scene_name;
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.SCENE_LEFT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, 'Modify Categories', helpid=>'A24' );
 htp.p('<CENTER>');
 htp.nl;
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
   htp.tablerowopen;
    htp.tabledata( htf.anchor2( 'adm.scene_right?surl=' || glbx.rndsurl(surl) || '&msg=' || translate( LNG3.ADM_TXT_168,' ','+'),LNG3.ADM_TXT_169,ctarget=>'ADM_RIGHT_WINCAT' ),cattributes=>glbx.QUERY_BACKGROUND );
 for c1rec in c1 loop
  if mod(c1%ROWCOUNT,5) = 1
    then
     htp.tablerowclose;
     htp.tablerowopen;
   end if;
   htp.tabledata( htf.anchor2( 'adm.scene_right?surl=' || glbx.rndsurl(surl) || '&scnm=' || translate( c1rec.scene_name,' ','+'),c1rec.scene_name,ctarget=>'ADM_RIGHT_WINCAT' ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
 end loop;
  htp.tablerowclose;
 htp.tableclose;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'SCENE_LEFT', errmsg=>sqlerrm, extdet=>null);
end scene_left;

procedure scene_right( surl varchar2,scnm in varchar2 default null, msg in varchar2 default null )
as
 cursor c1(scnm varchar2) is select * from scene where scene_name=scnm;
 cursor c2(scnm varchar2) is select * from umo_scene where category=scnm and owned_by = 'PUBLIC' order by order_by;
 cursor c3(scnm varchar2) is
  select usc.umo_scene_id, usc.category, usc.parent_scene, usc.owned_by, usc.owner_id, usc.order_by, usc.title, usc.associated_gif, usc.umo_type, ph.username
  from umo_scene usc, photographer ph
  where category=scnm and
        usc.owner_id = ph.pid and
        owned_by = 'PHOTOGRAPHER'
  order by order_by;
 cursor c4(scid integer) is select 'x' from dual where exists (select 'x' from umo um where um.umo_scene_id = scid );
 cursor c5(scid integer) is select title from umo_scene where umo_scene_id = scid;

 c1rec	c1%ROWTYPE;
 c4rec	c4%ROWTYPE;
 c5rec	c5%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.SCENE_RIGHT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if scnm is null
  then
   main_title( surl, sessid, LNG3.ADM_TXT_168 , style=>'NOMENU', helpid=>'A25');
  else
   main_title( surl, sessid, LNG3.ADM_TXT_170 || ': ' || scnm , style=>'NOMENU', helpid=>'A25' );
 end if;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 open c1(scnm);
 fetch c1 into c1rec;
 close c1;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_171 ); htp.nl;
 htp.formopen( 'adm.accept_scene' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.formhidden( 'SCNM', scnm );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_200 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P1',40, 100, c1rec.scene_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_173 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P2',40, 100, c1rec.image_gif ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if scnm is not null then
       if glbx.gif_exists('http://' || owa_util.get_cgi_env( 'SERVER_NAME' ) || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || DECS.IMAGE_LOCATION || 'category/' || c1rec.image_gif )
        then
         htp.tabledata(htf.img( DECS.IMAGE_LOCATION || 'category/' || c1rec.image_gif ));
        else
         htp.tabledata(LNG4.AHC_TXT_858);
       end if;
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_174 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P3',40, 100, c1rec.title_gif ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if scnm is not null then
       if glbx.gif_exists('http://' || owa_util.get_cgi_env( 'SERVER_NAME' ) || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || DECS.IMAGE_LOCATION || 'category/' || c1rec.title_gif )
        then
         htp.tabledata(htf.img( DECS.IMAGE_LOCATION || 'category/' || c1rec.title_gif ));
        else
         htp.tabledata(LNG4.AHC_TXT_858);
       end if;
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_105 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P4',40, 4000, c1rec.scene_descript ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tableclose;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_176 ); htp.nl;
 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_578 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG.SLD_TXT_004 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_177 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_582 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG.PHG_TXT_345 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 for c2rec in c2(scnm) loop
  htp.tablerowopen;
     htp.formhidden( 'A0', c2rec.umo_scene_id );
     htp.tabledata(htf.anchor( 'adm.scene_utility?surl=' || glbx.rndsurl(surl) || '&typ=NEST&scnm=' || translate(scnm,' ','+') || '&scid=' || c2rec.umo_scene_id,'[Ins 1]') || htf.nl ||
                   htf.anchor( 'adm.scene_utility?surl=' || glbx.rndsurl(surl) || '&typ=NEST5&scnm=' || translate(scnm,' ','+') || '&scid=' || c2rec.umo_scene_id,'[Ins 5]'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
     open c4( c2rec.umo_scene_id );
     fetch c4 into c4rec;
     if c4%FOUND
      then
       htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
      else
       htp.tabledata(htf.anchor( 'adm.scene_utility?surl=' || glbx.rndsurl(surl) || '&typ=DELETE&scnm=' || translate(scnm,' ','+') || '&scid=' || c2rec.umo_scene_id, LNG.SLD_TXT_004),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
     end if;
     close c4;
     htp.tabledata(htf.formtext( 'A1',5, 10, c2rec.order_by),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c2rec.parent_scene is not null
      then
       open c5(c2rec.parent_scene);
       fetch c5 into c5rec;
       close c5;
       htp.tabledata(htf.italic(c5rec.title),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
      else
       htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
     end if;
     htp.tabledata( lpad('.', glbx.indnt(c2rec.parent_scene),'.') || htf.formtext( 'A2',40, 100, c2rec.title),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 for j in 1..5 loop
  htp.tablerowopen;
     htp.formhidden( 'A0', '0' );
     htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
     htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
     htp.tabledata(htf.formtext( 'A1',5, 10, null),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
     htp.tabledata(htf.formtext( 'A2',40, 100, null),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_180 );
 htp.formclose;
 htp.nl;
 if scnm is not null
  then
   htp.bold( LNG3.ADM_TXT_179 );
   htp.nl;
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    htp.tablerowopen;
       htp.tabledata(htf.bold( LNG3.ADM_TXT_177 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG.PHG_TXT_345 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG.GLB_TXT_076 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   for c3rec in c3(scnm) loop
    htp.tablerowopen;
       htp.tabledata(c3rec.order_by,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold(c3rec.title),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(c3rec.username,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.anchor( 'adm.conv_priv_pub?surl=' || glbx.rndsurl(surl) || '&uscid=' || c3rec.umo_scene_id || '&scnm=' || translate(scnm,' ','+'), LNG3.ADM_TXT_725),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.formopen( 'adm.xml_unload' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl) );
   htp.formhidden( 'TYP','SCN' );
   htp.formhidden( 'P1',scnm );
   htp.italic( LNG3.ADM_TXT_181 || ': ' || htf.formtext( 'P2',30, 100,lower(replace(scnm,' ','_') || '.txt' )));
   htp.nl;
   htp.formsubmit( null,LNG3.ADM_TXT_182 );
   htp.formclose;
 end if;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'SCENE_RIGHT', errmsg=>sqlerrm, extdet=>null);
end scene_right;

procedure conv_priv_pub( surl varchar2,uscid integer, scnm in varchar2 )
as
 sessid	integer;
 sts	varchar2(200);
 nmb	integer;
 nmb2	integer;
 ctr	integer;
 j	integer;
 ttl	varchar2(100);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_SCENE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 update umo_scene
  set
   owned_by = 'PUBLIC',
   owner_id = NULL
 where umo_scene_id = uscid;
 commit;
 scene_right( surl,scnm, LNG3.ADM_TXT_726 );
exception when others then
 glbx.error_details( 'ADM', 'CONV_PRIV_PUB', errmsg=>sqlerrm, extdet=>'USCID:' || uscid);
end conv_priv_pub;

procedure accept_scene( surl varchar2,scnm in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, a0 in MYARRAY, a1 in MYARRAY, a2 in MYARRAY )
as
 sessid	integer;
 sts	varchar2(200);
 nmb	integer;
 nmb2	integer;
 ctr	integer;
 j	integer;
 ttl	varchar2(100);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_SCENE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if p1 is null
  then
   scene_right( surl,scnm, LNG3.ADM_TXT_183 );
   return;
 end if;
 update scene
  set
   image_gif = p2,
   title_gif = p3,
   scene_descript = p4
   where
    scene_name = scnm;
 if (scnm is not null) and (p1 <> scnm)
  then
   update scene
    set scene_name = p1
     where scene_name = scnm;
   update umo_scene
    set category = p1
     where category = scnm;
   update customer_account
    set scene_name = p1
     where scene_name = scnm;
   update customer_profile
    set scene_name = p1
     where scene_name = scnm;
   update limit_scenes
    set scene_name = p1
     where scene_name = scnm;
 end if;

 if (scnm is null)
  then
   insert into scene(scene_name,image_gif,title_gif,scene_descript) values
    (p1,p2,p3,p4);
 end if;

 for j in a0.first..a0.last loop
  ttl := substr(a2(j),1,100);
  nmb2 := to_number(a0(j));
  begin nmb := to_number(a1(j)); exception when others then nmb := 999; end;
  if (nmb2 = '0')
   then
    if ttl is not null
     then
      insert into umo_scene(umo_scene_id,category,owned_by,order_by,title) values (s_umo_scene.nextval,nvl(scnm,p1),'PUBLIC',nmb,ttl);
    end if;
   else
    update umo_scene set order_by = nmb, title=ttl where umo_scene_id = nmb2;
    update umo um
     set
      um.extras.orderby_scene = nmb,
      um.extras.title = ttl
    where um.umo_scene_id = nmb2;
  end if;
 end loop;
 commit;
 if (scnm is not null) and (p1 <> scnm)
  then
   scene_right( surl,p1, LNG3.ADM_TXT_184 );
  else
   scene_right( surl,nvl(scnm,p1), LNG3.ADM_TXT_184 );
 end if;
exception when others then
 rollback;
 glbx.error_details( 'ADM', 'ACCEPT_SCENE', errmsg=>sqlerrm, extdet=>'J:' || j);
end accept_scene;

procedure scene_utility( surl varchar2,scnm in varchar2, typ in varchar2, scid in integer )
as
 cursor c1(scid integer) is select order_by+1 from umo_scene where umo_scene_id = scid;
 sessid	integer;
 sts	varchar2(200);
 nmb	integer;
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.SCENE_UTILITY');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if typ = 'DELETE'
  then
   delete from umo_scene
    where category = scnm and
          umo_scene_id = scid and
          not exists( select 'x' from umo um where um.umo_scene_id = scid);
  elsif typ in ('NEST','NEST5')
   then
     open c1(scid);
     fetch c1 into nmb;
     close c1;
     insert into umo_scene(umo_scene_id,category,owned_by,order_by,title,parent_scene) values
        (s_umo_scene.nextval,scnm,'PUBLIC',nvl(nmb,100),LNG3.ADM_TXT_577,scid);
     if typ = 'NEST5'
      then
       for j in 1..4 loop
        insert into umo_scene(umo_scene_id,category,owned_by,order_by,title,parent_scene) values
         (s_umo_scene.nextval,scnm,'PUBLIC',nvl(nmb,100),LNG3.ADM_TXT_577 || to_char(j+1),scid);
       end loop;
     end if;
  end if;
 commit;
 scene_right( surl,scnm, LNG3.ADM_TXT_184 );
exception when others then
 glbx.error_details( 'ADM', 'SCENE_UTILITY', errmsg=>sqlerrm, extdet=>null);
end scene_utility;

procedure mnt_prefs( surl varchar2,msg in varchar2 default null )
as
 cursor c1 is select * from all_preferences order by prefid;
 c1rec	c1%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);
 tmp	varchar2(2000);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MNT_PREFS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_237, helpid=>'A28' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p('<CENTER>');
 htp.nl;
 htp.formopen( 'adm.accept_prefs' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.tableopen( cattributes=>'width="600" cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_022 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_238 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG.CST_TXT_013 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG.GLB_TXT_115 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
     htp.formhidden( 'A0', c1rec.prefid );
     htp.tabledata(htf.bold( c1rec.preference_name),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
	 tmp := htf.formselectopen( 'A1' );
	 if c1rec.preference_type = 'INTEGER'
	  then
	   tmp := tmp || htf.formselectoption( 'INTEGER', 'SELECTED' );
	  else
	   tmp := tmp || htf.formselectoption( 'INTEGER' );
	 end if;
	 if c1rec.preference_type = 'VARCHAR100'
	  then
	   tmp := tmp || htf.formselectoption( 'VARCHAR100', 'SELECTED' );
	  else
	   tmp := tmp || htf.formselectoption( 'VARCHAR100' );
	 end if;
	 if c1rec.preference_type = 'VARCHAR4000'
	  then
	   tmp := tmp || htf.formselectoption( 'VARCHAR4000', 'SELECTED' );
	  else
	   tmp := tmp || htf.formselectoption( 'VARCHAR4000' );
	 end if;
	 if c1rec.preference_type = 'LOV'
	  then
	   tmp := tmp || htf.formselectoption( 'LOV', 'SELECTED' );
	  else
	   tmp := tmp || htf.formselectoption( 'LOV' );
	 end if;
	 if c1rec.preference_type = 'PERCENTAGE'
	  then
	   tmp := tmp || htf.formselectoption( 'PERCENTAGE', 'SELECTED' );
	  else
	   tmp := tmp || htf.formselectoption( 'PERCENTAGE' );
	 end if;
	 if c1rec.preference_type = 'MONEY'
	  then
	   tmp := tmp || htf.formselectoption( 'MONEY', 'SELECTED' );
	  else
	   tmp := tmp || htf.formselectoption( 'MONEY' );
	 end if;
	 tmp := tmp || htf.formselectclose;
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.preference_type = 'LOV' and c1rec.preference_name in ('GIFT_WRAP','INT_GST','CUST_LOGOFF','RING','INSTRUCTIONS','DISPLAY_ORIGINAL','FAST_NEW','RET_ORIG')
      then
	if c1rec.default_value = LNG.PHG_TXT_045
	 then
	   htp.tabledata(htf.formselectopen( 'A2' ) || htf.formselectoption(  LNG.PHG_TXT_045, 'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_046 ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
	  else
	   htp.tabledata(htf.formselectopen( 'A2' ) || htf.formselectoption(  LNG.PHG_TXT_045 ) || htf.formselectoption(  LNG.PHG_TXT_046, 'SELECTED' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
	end if;
      else
       htp.tabledata(htf.formtext( 'A2',60, 4000, c1rec.default_value),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
     htp.tabledata(htf.formtext( 'A3',60, 1000, c1rec.help_text),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_241 );
 htp.formclose;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MNT_PREFS', errmsg=>sqlerrm, extdet=>null);
end mnt_prefs;

procedure accept_prefs( surl varchar2,a0 in MYARRAY, a1 in MYARRAY, a2 in MYARRAY, a3 in MYARRAY )
as
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_PREFS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 for j in a0.first..a0.last loop
  update all_preferences
   set
    preference_type = a1(j),
	default_value = a2(j),
	help_text = a3(j)
   where prefid = a0(j);
 end loop;
 commit;
 mnt_prefs( surl,LNG3.ADM_TXT_242 );
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_PREFS', errmsg=>sqlerrm, extdet=>null);
end accept_prefs;

procedure mnt_conns_mgmt(surl varchar2, msg in varchar2 default null )
as

 cursor c1(dsc integer) is select login_type, count('x') tot from login_session where is_connected = 'T' and date_updated > (sysdate - (dsc/(24*60))) group by login_type ;
 cursor c3(dsc integer) is
  select  /*+ ALL_ROWS */ date_updated,ls.sessid,login_type,decode(login_type,'VIRTUAL',username || '-' || event_id,username) username,to_char(date_updated,'DD-Mon-YYYY HH24:MI') dte, browser_type, browser_version, os, ip_address, screen_type, securl
  from login_session ls, customer_account ca
  where date_updated > (sysdate - (dsc/(24*60))) and
        ca.aid = ls.aid and
        is_connected = 'T' and
        login_type in ('OWNER','CUSTOMER','VIRTUAL')
  union all
  select  /*+ ALL_ROWS */ date_updated,ls.sessid,login_type,username,to_char(date_updated,'DD-Mon-YYYY HH24:MI') dte, browser_type, browser_version, os, ip_address, screen_type, securl
  from login_session ls, customer_profile ca
  where date_updated > (sysdate - (dsc/(24*60))) and
        ca.profile_id = ls.aid and
        is_connected = 'T' and
        login_type in ('PROFILE','PROFILEG')
  union all
  select  /*+ ALL_ROWS */ date_updated,ls.sessid,login_type,username,to_char(date_updated,'DD-Mon-YYYY HH24:MI') dte, browser_type, browser_version, os, ip_address, screen_type, securl
  from login_session ls, photographer ph
  where date_updated > (sysdate - (dsc/(24*60))) and
        ph.pid = ls.aid and
        is_connected = 'T' and
        login_type in ('PHOTOGRAPHER')
  union all
  select  /*+ ALL_ROWS */ date_updated,ls.sessid,login_type,acct_name,to_char(date_updated,'DD-Mon-YYYY HH24:MI') dte, browser_type, browser_version, os, ip_address, screen_type, securl
  from login_session ls, admin_acct ac
  where date_updated > (sysdate - (dsc/(24*60))) and
        ac.acct_id = ls.aid and
        is_connected = 'T' and
        login_type in ('ADMIN')
  union all
  select  /*+ ALL_ROWS */ date_updated,ls.sessid,login_type,DECS.ADMIN_USERNAME acct_name,to_char(date_updated,'DD-Mon-YYYY HH24:MI') dte, browser_type, browser_version, os, ip_address, screen_type, securl
  from login_session ls
  where date_updated > (sysdate - (dsc/(24*60))) and
        ls.aid = 0 and
        is_connected = 'T' and
        login_type in ('ADMIN')
  order by 1 desc;


 sessid		integer;
 sts		varchar2(200);
 dsc		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MNT_CONNS_MGMT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_911, helpid=>'A65' );
 if msg is not null then glbx.header_msg( msg ); end if;
   htp.p( '<CENTER>' );
   htp.nl;
   htp.bold( LNG3.ADM_TXT_244 ); htp.nl;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || GLBX.TABLE_BACKGROUND );
   dsc := glbx.extract_master_parameter( 'DISCONNECT_AFTER' );
   for c1rec in c1(nvl(dsc,180)) loop
    htp.tablerowopen;
       htp.tabledata(htf.bold( c1rec.login_type ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( c1rec.tot ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.nl;
   htp.bold( LNG3.ADM_TXT_659 ); htp.nl;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || GLBX.TABLE_BACKGROUND );
   htp.tablerowopen;
       htp.tabledata(htf.bold( LNG3.ADM_TXT_659 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG.GLB_TXT_076 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG3.ADM_TXT_660 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG.GLB_TXT_066 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( '&nbsp;' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( '&nbsp;' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   for c3rec in c3(nvl(dsc,180)) loop
    htp.tablerowopen;
       htp.tabledata(htf.bold( c3rec.login_type ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( c3rec.username ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( c3rec.dte ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
       htp.bold( c3rec.browser_type );
       htp.p( '[' || c3rec.browser_version || ']' );
       htp.nl;
       if c3rec.screen_type = 0
        then
         htp.bold( 'Mobile/No Javascript' );
       elsif c3rec.screen_type = 1
        then
         htp.bold( '0-799' );
       elsif c3rec.screen_type = 2
        then
         htp.bold( '800-1023' );
       elsif c3rec.screen_type = 3
        then
         htp.bold( '1024-1279' );
       elsif c3rec.screen_type = 4
        then
         htp.bold( '1280-1399' );
       elsif c3rec.screen_type = 5
        then
         htp.bold( '1400-1599' );
       elsif c3rec.screen_type = 6
        then
         htp.bold( '1600-1899' );
       else
         htp.bold( '&gt;1900' );
       end if;
       htp.p('[' || c3rec.ip_address || '-' || c3rec.os || ']' );
       htp.p( '</TD>' );
       htp.tabledata(htf.anchor( 'adm.disconnect?surl=' || glbx.rndsurl(surl) || '&sess_id=' || c3rec.sessid,LNG3.ADM_TXT_661),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       if c3rec.login_type in ('OWNER','CUSTOMER','PROFILE','PROFILEG','VIRTUAL')
        then
         htp.tabledata(htf.anchor2( 'cst.screen_sze?surl=' || c3rec.securl, LNG3.ADM_TXT_040, ctarget=>'CUSTOMER' || to_char(sysdate,'SSSSS')),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       elsif c3rec.login_type = 'PHOTOGRAPHER'
        then
         htp.tabledata(htf.anchor2( 'phg.screen_sze?surl=' || c3rec.securl, LNG3.ADM_TXT_040, ctarget=>'PHOTOGRAPHER' || to_char(sysdate,'SSSSS')),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       elsif c3rec.login_type = 'MANUFACTURER'
        then
         htp.tabledata(htf.anchor2( 'lab.screen_sze?surl=' || c3rec.securl, LNG3.ADM_TXT_040, ctarget=>'MANUFACTURER' || to_char(sysdate,'SSSSS')),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       else
        htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
    htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.bold( LNG3.ADM_TXT_253 || ': ' ); htp.nl;
   htp.italic( LNG3.ADM_TXT_254 ); htp.nl;
   htp.formopen( 'adm.disconnect_elapsed' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl) );
   htp.formhidden( 'TY','ELAPSED' );
   htp.formsubmit( null, LNG3.ADM_TXT_255 );
   htp.formclose;

   htp.nl;
   htp.bold( LNG3.ADM_TXT_256 || ': ' ); htp.nl;
   htp.italic( LNG3.ADM_TXT_257 ); htp.nl;
   htp.formopen( 'adm.disconnect_elapsed' );
   htp.formhidden( 'SURL',  glbx.rndsurl(surl));
   htp.formhidden( 'TY','ALL' );
   htp.formsubmit( null, LNG3.ADM_TXT_258 );
   htp.formclose;
   htp.p( '</CENTER>' );
   htp.nl;
   htp.line;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MNT_CONNS_MGMT', errmsg=>sqlerrm);
end mnt_conns_mgmt;

procedure disconnect(surl varchar2,sess_id in integer )
as

 sessid		integer;
 sts		varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.DISCONNECT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 update login_session
  set is_connected = 'F' where sessid = sess_id;
 commit;

 mnt_conns_mgmt( surl,LNG3.ADM_TXT_662 );

exception when others then
 glbx.error_details( 'ADM', 'DISCONNECT', errmsg=>sqlerrm, extdet=>'SESS_ID:' || sess_id);
end disconnect;

procedure mnt_conns(surl varchar2, msg in varchar2 default null, phgid in integer default null )
as

 cursor c1 is
  select to_char(date_created,'HH24') hr, count('x') cnt, sum(call_ctr) call_ctr
  from login_session
  where date_created > add_months(sysdate,-3)  and
        browser_version is not null and
        os is not null and
        browser_type is not null
  group by to_char(date_created,'HH24');

 cursor c1y is
  select to_char(date_created,'(MM) Mon') mn, count('x') cnt, sum(call_ctr) call_ctr
  from login_session
  where date_created > add_months(sysdate,-12) and
        browser_version is not null and
        os is not null and
        browser_type is not null
  group by to_char(date_created,'(MM) Mon');

 cursor c1d is
  select to_char(date_created,'(D) Day') mn, count('x') cnt, sum(call_ctr) call_ctr
  from login_session
  where date_created > add_months(sysdate,-12) and
        browser_version is not null and
        os is not null and
        browser_type is not null
  group by to_char(date_created,'(D) Day');

 cursor c2 is
  select login_type, round(avg(call_ctr),2) avg, count('x') tot, sum(call_ctr) sm, round(avg(nvl(date_updated,date_created)-date_created),2) avg_conn
  from login_session
  where browser_version is not null and
        os is not null and
        browser_type is not null
  group by login_type;

 cursor c3 (phgid integer) is
  select account_name,login_type,to_char(ls.date_created,'YYYYMM') mon,count('x') cnt,sum(call_ctr) sm
  from login_session ls, customer_account ca
  where ca.pid = phgid and
        ca.aid = ls.aid and
        login_type in ('CUSTOMER','OWNER','PROFILE','PROFILEG','VIRTUAL') and
        browser_version is not null and
        os is not null and
        browser_type is not null
  group by account_name,login_type,to_char(ls.date_created,'YYYYMM')
  order by account_name,login_type,to_char(ls.date_created,'YYYYMM') asc;

 cursor c4 is select pid,business_name from photographer order by business_name;

 cursor c5 is
  select nvl(os,' ') os,browser_type,browser_version,count('x') tot
  from login_session
  where browser_version is not null and
        os is not null and
        browser_type is not null
  group by nvl(os,' '),browser_type,browser_version;

 cursor c6 is
  select /*+ ALL ROWS */  count(call_ctr) cc,
         sum(call_ctr) sc,
         round(avg(call_ctr),2) ac,
         sum(decode(screen_type,'0',1,0)) s0,
         sum(decode(screen_type,'1',1,0)) s1,
         sum(decode(screen_type,'2',1,0)) s2,
         sum(decode(screen_type,'3',1,0)) s3,
         sum(decode(screen_type,'4',1,0)) s4,
         sum(decode(screen_type,'5',1,0)) s5,
         sum(decode(screen_type,'6',1,0)) s6,
         sum(decode(screen_type,'7',1,0)) s7,
	 sum(decode(login_type,'OWNER',1,'PROFILE',1,0)) lo,
	 sum(decode(login_type,'CUSTOMER',1,'PROFILEG',1,'VIRTUAL',1,0)) lc
  from login_session
  where browser_version is not null and
        os is not null and
        browser_type is not null;

 cursor c7 is
  select count('x') tot
  from login_session
  where browser_version is null and
        os is null and
        browser_type is null;

 c3rec		c3%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 date_tot	MYARRAY;
 date_sum	MYARRAY;
 sessid		integer;
 sts		varchar2(200);
 ctr		integer;
 last_ac	varchar2(100);
 last_ltype	varchar2(100);
 ttl1		integer;
 ttl2		integer;
 foundrec	boolean;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MNT_CONNS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_243, helpid=>'A29' );
 if msg is not null then glbx.header_msg( msg ); end if;
 if phgid is null
  then
   htp.nl;
   htp.p( '<CENTER>' );
   htp.nl;
   htp.tableopen;
   htp.tablerowopen;
   htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' );

   htp.bold( LNG3.ADM_TXT_664 ); htp.nl;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || GLBX.TABLE_BACKGROUND );
    htp.tablerowopen;
       htp.tabledata(htf.bold( LNG3.ADM_TXT_665 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG3.ADM_TXT_666 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( '&nbsp;' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   for c1rec in c1 loop
    htp.tablerowopen;
       htp.tabledata(htf.bold( c1rec.hr ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( c1rec.cnt || htf.nl || c1rec.call_ctr ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata( '<HR ALIGN="LEFT" COLOR="#09334C" SIZE="5" WIDTH="' || round(c1rec.cnt/20) || '">' || htf.nl ||
                      '<HR ALIGN="LEFT" COLOR="#ff3300" SIZE="5" WIDTH="' || round(c1rec.call_ctr/1000) || '">');
    htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.p( '</TD>' );
   htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' );
   htp.bold( LNG4.AHC_TXT_076 ); htp.nl;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || GLBX.TABLE_BACKGROUND );
    htp.tablerowopen;
       htp.tabledata(htf.bold( LNG3.ADM_TXT_667 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG3.ADM_TXT_666 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( '&nbsp;' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   for c1yrec in c1y loop
    htp.tablerowopen;
       htp.tabledata(htf.bold( c1yrec.mn ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( c1yrec.cnt|| htf.nl || c1yrec.call_ctr ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata( '<HR ALIGN="LEFT" COLOR="#09334C" SIZE="5" WIDTH="' || round(c1yrec.cnt/20) || '">' || htf.nl ||
                      '<HR ALIGN="LEFT" COLOR="#ff3300" SIZE="5" WIDTH="' || round(c1yrec.call_ctr/1000) || '">');
    htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.bold( LNG4.AHC_TXT_094 ); htp.nl;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || GLBX.TABLE_BACKGROUND );
    htp.tablerowopen;
       htp.tabledata(htf.bold( LNG4.AHC_TXT_095 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG3.ADM_TXT_666 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( '&nbsp;' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   for c1drec in c1d loop
    htp.tablerowopen;
       htp.tabledata(htf.bold( c1drec.mn ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( c1drec.cnt|| htf.nl || c1drec.call_ctr ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata( '<HR ALIGN="LEFT" COLOR="#09334C" SIZE="5" WIDTH="' || round(c1drec.cnt/20) || '">' || htf.nl ||
                      '<HR ALIGN="LEFT" COLOR="#ff3300" SIZE="5" WIDTH="' || round(c1drec.call_ctr/1000) || '">');
    htp.tablerowclose;
   end loop;
   htp.tableclose;

   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tableclose;

   htp.nl;
   htp.tableopen;
   htp.nl;
   htp.nl;
   htp.bold( LNG.PHG_BUT_340 ); htp.nl;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || GLBX.TABLE_BACKGROUND );
    htp.tablerowopen;
       htp.tabledata(htf.bold( LNG3.ADM_TXT_246 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG.PHG_TXT_314 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG.PHG_TXT_315 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG3.ADM_TXT_248 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG3.ADM_TXT_249 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   ttl1 := 0;
   ttl2 := 0;
   for c2rec in c2 loop
    htp.tablerowopen;
       htp.tabledata(htf.bold( c2rec.login_type ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( c2rec.tot ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( c2rec.sm ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( c2rec.avg ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( c2rec.avg_conn*1440 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       ttl1 := ttl1 + nvl(c2rec.tot,0);
       ttl2 := ttl2 + nvl(c2rec.sm,0);
    htp.tablerowclose;
   end loop;
    htp.tablerowopen;
       htp.tabledata(htf.bold( LNG.CST_TXT_138 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( ttl1 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( ttl2 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   htp.tableclose;
 end if;
 htp.tableclose;

 if phgid is null
  then
  htp.nl;
  htp.nl;
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_276) );
     htp.tabledata( htf.bold(LNG.PHG_TXT_314) );
    htp.tablerowclose;
    for c5rec in c5 loop
    htp.tablerowopen;
      htp.tabledata( htf.italic(c5rec.os || '-' || c5rec.browser_type || '(' || c5rec.browser_version || ')'),cattributes=>glbx.QUERY_BACKGROUND  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(c5rec.tot),cattributes=>glbx.QUERY_CELL_BACKGROUND );
    htp.tablerowclose;
    end loop;
  htp.tableclose;
  htp.nl;

  open c6;
  fetch c6 into c6rec;
  close c6;
    htp.nl;
    htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.PHG_TXT_279) );
       htp.tabledata( htf.bold(LNG.PHG_TXT_314) );
      htp.tablerowclose;
      htp.tablerowopen;
        htp.tabledata( htf.italic(LNG.PHG_TXT_321),cattributes=>glbx.QUERY_BACKGROUND  || ' ALIGN="RIGHT"');
        htp.tabledata( htf.bold(nvl(c6rec.lc,0) + nvl(c6rec.lo,0)),cattributes=>glbx.QUERY_CELL_BACKGROUND );
      htp.tablerowclose;
      htp.tablerowopen;
        htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': ' || 'Mobile/No Javascript'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"' );
        htp.tabledata( htf.bold(c6rec.s0),cattributes=>glbx.QUERY_CELL_BACKGROUND );
      htp.tablerowclose;
      htp.tablerowopen;
        htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': ' || '0-799'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"' );
        htp.tabledata( htf.bold(c6rec.s1),cattributes=>glbx.QUERY_CELL_BACKGROUND );
      htp.tablerowclose;
      htp.tablerowopen;
        htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': ' || '800-1023'),cattributes=>glbx.QUERY_BACKGROUND  || ' ALIGN="RIGHT"');
        htp.tabledata( htf.bold(c6rec.s2),cattributes=>glbx.QUERY_CELL_BACKGROUND );
      htp.tablerowclose;
      htp.tablerowopen;
        htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': ' || '1024-1279'),cattributes=>glbx.QUERY_BACKGROUND  || ' ALIGN="RIGHT"');
        htp.tabledata( htf.bold(c6rec.s3),cattributes=>glbx.QUERY_CELL_BACKGROUND );
      htp.tablerowclose;
      htp.tablerowopen;
        htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': ' || '1280-1399'),cattributes=>glbx.QUERY_BACKGROUND  || ' ALIGN="RIGHT"');
        htp.tabledata( htf.bold(c6rec.s4),cattributes=>glbx.QUERY_CELL_BACKGROUND );
      htp.tablerowclose;
      htp.tablerowopen;
        htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': ' || '1400-1599'),cattributes=>glbx.QUERY_BACKGROUND  || ' ALIGN="RIGHT"');
        htp.tabledata( htf.bold(c6rec.s5),cattributes=>glbx.QUERY_CELL_BACKGROUND );
      htp.tablerowclose;
      htp.tablerowopen;
        htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': ' || '1600-1899'),cattributes=>glbx.QUERY_BACKGROUND  || ' ALIGN="RIGHT"');
        htp.tabledata( htf.bold(c6rec.s6),cattributes=>glbx.QUERY_CELL_BACKGROUND );
      htp.tablerowclose;
      htp.tablerowopen;
        htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': ' || '&gt;1900'),cattributes=>glbx.QUERY_BACKGROUND  || ' ALIGN="RIGHT"');
        htp.tabledata( htf.bold(c6rec.s7),cattributes=>glbx.QUERY_CELL_BACKGROUND );
      htp.tablerowclose;
    htp.tableclose;
    htp.nl;
  end if;

  open c7;
  fetch c7 into c7rec;
  close c7;
    htp.nl;
    htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG5.EXT_TXT_221) );
       htp.tabledata( htf.bold(c7rec.tot) );
      htp.tablerowclose;
    htp.tableclose;
    htp.nl;

  htp.nl;
  htp.bold( LNG3.ADM_TXT_250 ); htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' || GLBX.TABLE_BACKGROUND );
  if phgid is not null
   then
   htp.tablerowopen;
    htp.tabledata(htf.bold( LNG3.ADM_TXT_261 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata(htf.bold( LNG.PHG_ALT_121 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata(htf.bold( LNG3.ADM_TXT_238 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    for j in REVERSE 0..12 loop
     htp.tabledata(htf.bold( to_char(add_months(sysdate,-1*j),'Mon YYYY')),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    end loop;
    htp.tabledata(htf.bold( LNG.CST_TXT_138 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
  end if;

    for c4rec in c4 loop
     if c4rec.pid = phgid
      then
      ctr := 12;
      htp.tabledata(htf.bold( c4rec.business_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      open c3(c4rec.pid);
      last_ltype := '.';
      last_ac := '.';
      ttl1 := 0;
      ttl2 := 0;
      foundrec := FALSE;
      loop
       fetch c3 into c3rec;
       if c3%NOTFOUND then exit; end if;
       foundrec := TRUE;
       if last_ltype <> '.'
        then
         if (last_ltype <> c3rec.login_type) or (last_ac <> c3rec.account_name)
          then
           loop
            if ctr < 0 then exit; end if;
            htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
            ctr := ctr - 1;
            exit when ctr < 0;
           end loop;
           htp.tabledata( htf.bold( to_char(ttl1) || '/' || to_char(ttl2) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
           htp.tablerowclose;
           htp.tablerowopen;
           ctr := 12;
           ttl1 := 0;
           ttl2 := 0;
           htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
         end if;
       end if;
       last_ltype := c3rec.login_type;
       last_ac := c3rec.account_name;
       if ctr = 12
        then
          htp.tabledata(htf.bold( c3rec.account_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
          htp.tabledata(htf.bold( initcap(c3rec.login_type) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        end if;
        loop
         if to_char(add_months(sysdate,-1 * ctr ),'YYYYMM') = c3rec.mon
          then
           htp.tabledata(htf.bold( c3rec.cnt || '/' || c3rec.sm ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
           ttl1 := ttl1 + c3rec.cnt;
           ttl2 := ttl2 + c3rec.sm;
           if date_tot.exists(ctr)
            then
             date_tot(ctr) := to_char(to_number(date_tot(ctr)) + c3rec.cnt);
            else
             date_tot(ctr) := to_char(c3rec.cnt);
           end if;
           if date_sum.exists(ctr)
            then
             date_sum(ctr) := to_char(to_number(date_sum(ctr)) + c3rec.sm);
            else
             date_sum(ctr) := to_char(c3rec.sm);
           end if;
           exit;
          else
           ctr := ctr - 1;
           if ctr < 0 then exit; end if;
           htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
         end if;
        end loop;
        ctr := ctr - 1;
	-- if ctr < 0 then exit; end if;
      end loop;
      close c3;
      if not foundrec
       then
        htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      end if;
      loop
        if ctr < 0 then exit; end if;
        htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        ctr := ctr - 1;
        exit when ctr < 0;
      end loop;
      htp.tabledata( htf.bold( to_char(ttl1) || '/' || to_char(ttl2) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tablerowclose;
     else
      htp.tablerowopen;
       htp.tabledata( htf.anchor( 'adm.mnt_conns?surl=' || surl || '&phgid=' || c4rec.pid, c4rec.business_name ) );
      htp.tablerowclose;
     end if;
     end loop;

   if phgid is not null
    then
     htp.tablerowopen;
      htp.tabledata(htf.bold( LNG.CST_TXT_138 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      ttl1 := 0;
      ttl2 := 0;
      for j in REVERSE 0..12 loop
        begin
           htp.tabledata(htf.bold( date_tot(j) || '/' || date_sum(j) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
           ttl1 := ttl1 + to_number(date_tot(j));
           ttl2 := ttl2 + to_number(date_sum(j));
        exception
         when others then htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        end;
      end loop;
      htp.tabledata( htf.bold( to_char(ttl1) || '/' || to_char(ttl2) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
   htp.tableclose;
  end if;
 htp.tableclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MNT_CONNS', errmsg=>sqlerrm );
end mnt_conns;

procedure disconnect_elapsed( surl varchar2, ty in varchar2 )
as
 --cursor c1 is select disconnect_after from master_piction;
 sessid	integer;
 sts	varchar2(200);
 ctr	integer;
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.DISCONNECT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if ty = 'ALL'
  then
   update login_session set is_connected = 'F' where login_type <> 'ADMIN' and is_connected = 'T';
   ctr := SQL%ROWCOUNT;
   commit;
   mnt_conns( surl, LNG3.ADM_TXT_270 || ': ' || ctr );
  else
   --open c1;
   --fetch c1 into ctr;
   --close c1;
   begin ctr := to_number(glbx.extract_master_parameter('DISCONNECT_AFTER')); exception when others then ctr := 180; end;
   ctr := nvl(ctr,180);
   update login_session
     set
	  is_connected = 'F'
	  where (sysdate - nvl(date_updated,date_created))*1440 > ctr and
	        is_connected = 'T';
   ctr := SQL%ROWCOUNT;
   commit;
   mnt_conns_mgmt( surl, LNG3.ADM_TXT_271 || ': ' || ctr );
 end if;
exception when others then
 glbx.error_details( 'ADM', 'DISCONNECT_ELAPSED', errmsg=>sqlerrm, extdet=>null);
end disconnect_elapsed;

procedure generate_stats(surl varchar2,p1 in varchar2)
as
 cursor c1 is select table_name from user_tables order by table_name;
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.GENERATE_STATS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_272, helpid=>'A30');
 htp.nl;
 for c1rec in c1 loop
  htp.bold( LNG3.ADM_TXT_273 || ': ' || c1rec.table_name );
  htp.nl;
  begin
   execute immediate 'analyze table ' || c1rec.table_name || ' estimate statistics for table for all indexed columns for all indexes sample ' || p1 || ' percent';
  exception
   when others then htp.p( LNG3.ADM_TXT_091 || ': ' || sqlerrm ); htp.nl;
  end;
 end loop;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'GENERATE_STATS', errmsg=>sqlerrm, extdet=>null);
end generate_stats;

procedure mnt_table(surl varchar2,msg in varchar2 default null)
as
 cursor c1 is select segment_type,sum(bytes) sum_by,sum(blocks) sum_bl,max(extents) max_ext from user_segments group by segment_type;
 cursor c2 is select tablespace_name,sum(bytes) sum_by,sum(blocks) sum_bl,max(bytes) max_by,max(blocks) max_bl from user_free_space group by tablespace_name;
 cursor c3 is select segment_name,segment_type,bytes,blocks,extents,tablespace_name,max_extents,initial_extent,next_extent from user_segments order by segment_type,segment_name;
 cursor c4 is select * from user_tables order by table_name;
 cursor c5 is select * from user_indexes order by table_name,index_name;
 cursor c6(tname varchar2) is
  select ul.table_name,ul.column_name,ul.segment_name,uss.bytes,uss.blocks,ul.chunk,uss.extents
  from user_lobs ul,user_segments uss
  where ul.segment_name = uss.segment_name and
        ul.table_name = tname;
 cursor c7(tname varchar2) is
  select ul.table_name,ul.column_name,ul.index_name,uss.bytes,uss.blocks,ul.chunk,uss.extents
  from user_lobs ul,user_segments uss
  where ul.index_name = uss.segment_name and
        ul.table_name = tname;

 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MNT_TABLE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_275, helpid=>'A31' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.bold( LNG3.ADM_TXT_276 || ': ' || GLBX.CURRENT_VERSION ); htp.nl;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_277 || ': ' ); htp.nl;
 htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_278 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_279 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_280 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_281 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
     htp.tabledata(htf.bold( c1rec.segment_type ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c1rec.sum_by ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c1rec.sum_bl ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c1rec.max_ext ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;

 htp.nl;
 htp.bold( LNG3.ADM_TXT_287 || ': ' ); htp.nl;
 htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_282 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_279 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_284 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_280 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_286 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 for c2rec in c2 loop
  htp.tablerowopen;
     htp.tabledata(htf.bold( c2rec.tablespace_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c2rec.sum_by ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c2rec.max_by ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c2rec.sum_bl ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c2rec.max_bl ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;

 htp.nl;
 htp.bold( LNG3.ADM_TXT_288 || ': ' ); htp.nl;
 htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_278 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_279 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_282 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_289 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_290 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_291 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_292 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG.SLD_TXT_087 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_294 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 for c3rec in c3 loop
  htp.tablerowopen;
     htp.tabledata(htf.bold( c3rec.segment_type ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c3rec.segment_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c3rec.tablespace_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c3rec.bytes),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c3rec.blocks ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c3rec.extents ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c3rec.initial_extent ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c3rec.next_extent ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c3rec.max_extents ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;

 htp.nl;
 htp.bold( LNG3.ADM_TXT_295 || ': ' ); htp.nl;
 htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_296 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_282 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_297 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_290 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_298 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_299 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_300 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_301 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_302 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_303 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 for c4rec in c4 loop
  htp.tablerowopen;
     htp.tabledata(htf.bold( c4rec.table_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c4rec.tablespace_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c4rec.num_rows ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c4rec.blocks ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c4rec.empty_blocks ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c4rec.avg_space ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c4rec.chain_cnt ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c4rec.avg_row_len ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c4rec.sample_size ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( to_char(c4rec.last_analyzed,LNG3.ADM_DATE_01) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;

 htp.nl;
 htp.bold( LNG3.ADM_TXT_304 || ': ' ); htp.nl;
 htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_296 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_305 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_282 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_306 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_307 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_308 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_309 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_310 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_311 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG.PHG_TXT_082 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_297 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_303 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 for c5rec in c5 loop
  htp.tablerowopen;
     htp.tabledata(htf.bold( c5rec.table_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c5rec.index_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c5rec.tablespace_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c5rec.pct_free ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c5rec.blevel ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c5rec.leaf_blocks),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c5rec.distinct_keys ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c5rec.avg_leaf_blocks_per_key ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c5rec.avg_data_blocks_per_key ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c5rec.status ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c5rec.num_rows ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( to_char(c5rec.last_analyzed,LNG3.ADM_DATE_01) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;

 htp.formopen( 'adm.generate_stats' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.bold( 'Estimate %' );
 htp.formtext( 'P1', 10, 10, '20' );
 htp.formsubmit( null, LNG3.ADM_TXT_314 );
 htp.formclose;

 htp.nl;
 htp.bold( LNG3.ADM_TXT_315 || ': ' ); htp.nl;
 htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_296 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_316 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_317 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_318 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_289 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_290 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_291 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 for c6rec in c6('PHOTO') loop
  htp.tablerowopen;
     htp.tabledata(htf.bold( c6rec.table_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c6rec.segment_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c6rec.column_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c6rec.chunk ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c6rec.bytes ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c6rec.blocks ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c6rec.extents ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 for c6rec in c6('AUDIO_FILE') loop
  htp.tablerowopen;
     htp.tabledata(htf.bold( c6rec.table_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c6rec.segment_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c6rec.column_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c6rec.chunk ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c6rec.bytes ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c6rec.blocks ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c6rec.extents ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;

 htp.nl;
 htp.bold( LNG3.ADM_TXT_319 || ': ' ); htp.nl;
 htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_296 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_320 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_317 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_318 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_289 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_290 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_291 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 for c7rec in c7('PHOTO') loop
  htp.tablerowopen;
     htp.tabledata(htf.bold( c7rec.table_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c7rec.index_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c7rec.column_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c7rec.chunk ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c7rec.bytes ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c7rec.blocks ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c7rec.extents ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 for c7rec in c7('AUDIO_FILE') loop
  htp.tablerowopen;
     htp.tabledata(htf.bold( c7rec.table_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c7rec.index_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c7rec.column_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c7rec.chunk ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c7rec.bytes ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c7rec.blocks ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c7rec.extents ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;
exception when others then
 glbx.error_details( 'ADM', 'MNT_TABLE', errmsg=>sqlerrm, extdet=>null);
end mnt_table;

procedure phg_connect_as(surl varchar2, phgid in integer, typ in varchar2 default 'P')
as

 cursor c2(ltype varchar2, acid integer) is select * from customer_contact where login_type = ltype and aid = acid;
 cursor c3(phgid integer) is select * from photographer where pid = phgid;
 cursor c4(ltype varchar2, acid integer) is
  select sessid
  from login_session
  where login_type = ltype and
        aid = acid
  order by date_created desc;

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 newsurl	varchar2(100);
 sessid		integer;
 sts		varchar2(200);
 id		integer;
 ltype		varchar2(20);
 lsess		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.PHG_CONNECT_AS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 -- select s_login_session.nextval into id from dual;
 id := glbx.get_random_sessionid;
 newsurl := rpad(to_char(id),12,'Z') || glbx.randstring;
 if typ = 'P'
  then
   ltype := 'PHOTOGRAPHER';
 elsif typ = 'C'
  then
   ltype := 'OWNER';
 elsif typ = 'G'
  then
   ltype  := 'CUSTOMER';
 end if;

 -- Get the last login_session
 open c4( ltype, phgid );
 fetch c4 into lsess;
 close c4;

 if ltype = 'PHOTOGRAPHER'
  then
   open c3(phgid);
   fetch c3 into c3rec;
   close c3;
   c2rec.contact_email := c3rec.contact_email;
   -- c2rec.sendto_country
  else
   open c2(ltype,phgid);
   fetch c2 into c2rec;
   close c2;
 end if;

 insert into login_session(screen_type, login_type, sessid, aid, date_created, date_updated, call_ctr, browser, ip_address, securl, guest_email, country,previous_sessid, calling_sessid)
  values (1, ltype, id, phgid, sysdate, sysdate, 1, owa_util.get_cgi_env( 'HTTP_USER_AGENT'), owa_util.get_cgi_env( 'REMOTE_ADDR'), newsurl, c2rec.contact_email, c2rec.sendto_country, lsess, to_number(replace(substr(surl,1,12),'Z','')) );

 -- Merge the Lightbox from the Old Session
 -- Remember if they are logging in, then old session lightbox results might be merged in from the login routine
 if ltype in ('PHOTOGRAPHER','OWNER','PROFILE')
  then
   update lightbox
    set    sessid = id
    where  sessid = lsess;

   -- Change the Shopping Basket
   --update purchase_order
   -- set   sessid = id
   -- where sessid = lsess;

   -- Remove duplicate entries
   delete from lightbox lb
   where lb.rowid > (select min(lbx.rowid)
                     from lightbox lbx
                     where lbx.umo_id = lb.umo_id
                      and  lbx.sessid = lb.sessid ) and
          sessid = id;
 end if;

 commit;

 if typ = 'P'
  then
   phg.screen_sze(newsurl);
  else
   cst.screen_sze(newsurl);
 end if;

exception when others then
 glbx.error_details( 'ADM', 'PHG_CONNECT_AS', errmsg=>sqlerrm, extdet=>null);
end phg_connect_as;

procedure mfc_connect_as(surl varchar2, manid in integer)
as

 newsurl	varchar2(100);
 sessid		integer;
 sts		varchar2(200);
 id		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MFC_CONNECT_AS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 -- select s_login_session.nextval into id from dual;
 id := glbx.get_random_sessionid;
 newsurl := rpad(to_char(id),12,'Z') || glbx.randstring;
   insert into login_session(screen_type,login_type,sessid,aid,date_created,date_updated,call_ctr, browser, ip_address, securl, calling_sessid)
     values (1,'MANUFACTURER', id, manid, sysdate, sysdate, 1, substr(owa_util.get_cgi_env( 'HTTP_USER_AGENT'),1,100), owa_util.get_cgi_env( 'REMOTE_ADDR'), newsurl, to_number(replace(substr(surl,1,12),'Z','')) );
   commit;

 lab.screen_sze(newsurl);
exception when others then
 glbx.error_details( 'ADM', 'MFC_CONNECT_AS', errmsg=>sqlerrm, extdet=>null);
end mfc_connect_as;

procedure b2c_create(surl varchar2, phgid in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2 )
as
 cursor c3a(cname varchar2) is
  select 'x'
  from customer_account
  where username = cname;
 cursor c3b(cname varchar2) is
  select 'x'
  from photographer
  where username = cname;
 cursor c3d(cname varchar2) is
  select 'x'
  from manufacturer
  where username = cname;
 cursor c3c(phgid integer) is
  select * from charge_plan where id = (select plan_id from photographer where pid = phgid);
 tmpa		char(1);
 sessid		integer;
 acid		integer;
 sts		varchar2(200);
 c3crec 	c3c%ROWTYPE;
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.B2C_CREATE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 htp.nl;

 open c3c(phgid);
 fetch c3c into c3crec;
 close c3c;

   open c3a( upper( p2 ));
   fetch c3a into tmpa;
   if c3a%found
    then
     close c3a;
     load_create( phgid, LNG3.ADM_TXT_345 );
     return;
   end if;
   close c3a;
   open c3b( upper( p2 ));
   fetch c3b into tmpa;
   if c3b%found
    then
     close c3b;
     load_create( phgid, LNG3.ADM_TXT_345 );
     return;
   end if;
   close c3b;
   open c3d( upper( p2 ));
   fetch c3d into tmpa;
   if c3d%found
    then
     close c3d;
     load_create( phgid, LNG3.ADM_TXT_345 );
     return;
   end if;
   close c3d;
   select s_customer_profile.nextval into acid from dual;
   insert into customer_account(pid,aid,account_name,date_created,date_expires,username,scene_name,photographer_account_id,theme_name,theme_type,plan_id,home_page_options,enable_novelties,novelty_features,enable_greetingcards) values
    (phgid,acid,p1,sysdate,sysdate+c3crec.days_to_expire,upper(rtrim(p2)),p3,p4,DECS.DEFAULT_PHG_THEME,p5,1,rpad('T',30,'T'),'T',lpad('F',40,'F'),'T');
   update customer_account
    set
      home_page_options = substr(home_page_options,1,9) || 'F' || substr(home_page_options,11)
   where aid = acid;
   update customer_account
    set
      home_page_options = substr(home_page_options,1,10) || 'F' || substr(home_page_options,12)
   where aid = acid;
   update customer_account
    set
      home_page_options = substr(home_page_options,1,11) || 'F' || substr(home_page_options,13)
   where aid = acid;
   insert into photographer_preference(pid,aid,prefid,value)
    select phgid,acid,ap.prefid,replace(ap.default_value,'<@>',ph.business_name)
	from all_preferences ap, photographer ph
	where ph.pid = phgid;
   insert into customer_price_book(pid,aid,oid,valid_until,oid_when_invalid, ltype)
     select phgid,acid, oid, null, null,'OWNER'
       from order_style
       where pid = phgid and
             is_default = 'T' and
             rownum < 2;
   commit;
 form_load(surl,phgid,LNG3.ADM_TXT_346);
exception when others then
 glbx.error_details( 'ADM', 'B2C_CREATE', errmsg=>sqlerrm, extdet=>null);
end b2c_create;

procedure load_create(surl varchar2,phgid integer, msg in varchar2 default null)
as
 cursor c2 is select theme_type from theme_types order by theme_type;
 cursor c3 is select scene_name from scene order by scene_name;
 tmp varchar2(2000);
begin
 htp.htmlopen;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_340 );
 htp.nl;
 htp.italic( LNG3.ADM_TXT_341 );
 htp.nl;
 htp.nl;
 htp.formopen( 'adm.b2c_create' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.formhidden( 'PHGID', phgid );
 htp.tableopen( cattributes=>'width="600" cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
   htp.tablerowopen;
      htp.tabledata(htf.bold( LNG3.ADM_TXT_342 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.formtext( 'P1', 30, 30 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata(htf.bold( LNG.PHG_TXT_166 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.formtext( 'P2', 30, 30 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   tmp := htf.formselectopen( 'P3' );
   for c3rec in c3 loop
    tmp := tmp || htf.formselectoption(c3rec.scene_name);
   end loop;
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
      htp.tabledata(htf.bold( LNG.CST_TXT_042 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   tmp := htf.formselectopen( 'P5' );
   for c2rec in c2 loop
    tmp := tmp || htf.formselectoption(c2rec.theme_type);
   end loop;
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
      htp.tabledata(htf.bold( LNG.PHG_TXT_129 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata(htf.bold( LNG3.ADM_TXT_343 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.formtext( 'P4', 30, 30 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_344 );
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'LOAD_CREATE', errmsg=>sqlerrm, extdet=>null);
end load_create;

procedure extract_tag( surl varchar2,bfr in varchar2, objtype in varchar2, tagout out varchar2, tagval out varchar2, tagresult out varchar2, ismeta out boolean, debug in varchar2 )
 as

  cursor c1(tagname varchar2, objtype varchar2) is select * from umo_attributes where umo_type = upper(objtype) and sub_category = upper(tagname);

  c1rec	c1%ROWTYPE;

  x	integer;
  y	integer;
  tg1	varchar2(1000);

 begin
  tagresult := NULL;
  tagout := NULL;
  tagval := NULL;
  ismeta := FALSE;

  if substr(bfr,1,1) <> '<'
   then
    tagout := 'FILENAME';
    tagval := rtrim( bfr );
    ismeta := TRUE; -- Overloaded value. Default behaviour.
    if debug = 'T' then htp.p( LNG3.ADM_TXT_743 || ':' || tagout || '-' || tagval ); end if;
    return;
  end if;

  x := instr(bfr,'>' );
  if x = 0
   then
    tagresult := LNG3.ADM_TXT_740;
    return;
  end if;

  tg1 := upper(substr(bfr,2,x-2));
  if tg1 in ('OBJECT','/OBJECT')
   then
    tagout := tg1;
    return;
  end if;

  y := length(tg1);
  if instr(upper(bfr),'</' || tg1 || '>') = 0
   then
    tagresult := LNG3.ADM_TXT_741 || tg1;
    return;
  end if;

  tagval := substr(bfr,y+3,instr(upper(bfr),'</' || tg1 || '>') - (y+3) );

  if tg1 not in ('FILENAME','DIRECTORY','SUBDIRECTORY','ROLL ID','FILM TYPE','KEEP REPLACE IGNORE','SCALE SIZE','SCALE THRESHOLD','THUMBNAIL WIDTH','THUMBNAIL QUALITY','STORE ORIGINAL','OBJECT TYPE','FTP LOCATION','COMPRESSION','SCENE','SCID')
   then
    -- See if it is a Meta Tag
    open c1(tg1,objtype);
    fetch c1 into c1rec;
    if c1%NOTFOUND
     then
      close c1;
      tagresult := LNG3.ADM_TXT_742 || ':' || tg1 || '-' || objtype;
      return;
    end if;
    close c1;
    ismeta := TRUE;

    -- Validate the Meta Tag
    glbx.validate_meta_tag(tagval,c1rec,tagresult);
    if tagresult is not null
     then
      return;
    end if;
  end if;

  if debug = 'T'
   then
    htp.p( LNG3.ADM_TXT_743 || ':' || tg1 );
    htp.nl;
    htp.p( LNG3.ADM_TXT_744 || ':' || tagval );
    htp.nl;
  end if;

  tagout := tg1;

 exception
  when others then tagresult := sqlerrm;
end extract_tag;

procedure notify_load_completed(surl in varchar2, acid in integer, vdir in varchar2, numb_loaded in integer )
as

 cursor c1(acid integer) is select * from customer_account where aid = acid;
 cursor c2(phgid integer) is select * from photographer where pid = phgid;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin
 open c1(acid);
 fetch c1 into c1rec;
 close c1;
 open c2(c1rec.pid);
 fetch c2 into c2rec;
 close c2;
    gcode(1) := 'CUSTOMER';
    gparam(1) := nvl(c1rec.account_name,c1rec.username);
    gcode(2) := 'CURRTIME';
    gparam(2) := to_char(sysdate,LNG.TSMASK);
    gcode(3) := 'DIRECTORY';
    gparam(3) := vdir;
    gcode(4) := 'LOADED_IMAGES';
    gparam(4) := numb_loaded;
    gcode(5) := 'SIGNATURE';
    gparam(5) := glbx.extract_master_parameter('MAIL SIGNATURE');
    if c2rec.contact_email is not null
     then
      glbx.send( gcode, gparam, 'load_completed.tmp', p_to=>c2rec.contact_email,p_subj=>'Load Completed:' || c1rec.account_name,p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'LC1', v_pid=>c1rec.pid, v_aid=>c1rec.aid);
    end if;
exception
 when others then null;
end notify_load_completed;

procedure adm_acct_orders(surl varchar2, phgid in integer default null, isphg in varchar2 default 'F')
as

 cursor c2 is select username,pid from photographer order by username;

 sessid		integer;
 sts		varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ADM_ACCT_ORDERS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if isphg = 'T'
  then
   main_title( surl, sessid, LNG3.ADM_TXT_360, style=>'NOMENU', helpid=>'A34' );
  else
   main_title( surl, sessid, LNG3.ADM_TXT_360, style=>'MENU', helpid=>'A34' );
 end if;
 htp.p('<CENTER>');
 htp.nl;
 htp.bold( htf.formopen( 'adm.dispord', ctarget=>'ORDER_WINDOW' ) || htf.formhidden( 'SURL', surl ) || LNG.CST_TXT_099 || ' ' || htf.formtext( 'PURCHID', 10, 20) || htf.formsubmit( null, LNG.GLB_TXT_092 ) || htf.formclose );
 htp.nl;
 htp.formopen( 'adm.order_report' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.formhidden( 'ACID', NULL );
 htp.formhidden( 'ISPHG', isphg );
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG3.ADM_TXT_261), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT">' );
   htp.formselectopen( 'PHGID' );
    if isphg = 'F' then htp.formselectoption( LNG.ORD_TXT_194, cattributes=>'VALUE="0"' ); end if;
    for c2rec in c2 loop
     if isphg = 'F'
      then
       htp.formselectoption( c2rec.username, cattributes=>'VALUE="' || c2rec.pid || '"' );
      else
       if phgid = c2rec.pid
        then
         htp.formselectoption( c2rec.username, cattributes=>'VALUE="' || c2rec.pid || '"' );
       end if;
     end if;
    end loop;
    htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( '&nbsp;',cattributes=> glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_084), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( htf.formtext( 'PNAME',20,100),cattributes=> glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( '&nbsp;',cattributes=> glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.LAB_TXT_069), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT">' );
   htp.formselectopen( 'YEARFROM' );
    for j in 2000..2010 loop
     if j = to_number(to_char(sysdate,'YYYY'))
      then
       htp.formselectoption( to_char(j), 'SELECTED', cattributes=>'VALUE="' || to_char(j) || '"' );
      else
       htp.formselectoption( to_char(j), cattributes=>'VALUE="' || to_char(j) || '"' );
     end if;
    end loop;
    htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold(LNG.LAB_TXT_071), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT">' );
   htp.formselectopen( 'YEARTO' );
    for j in 2000..2010 loop
     if j = to_number(to_char(sysdate,'YYYY'))
      then
       htp.formselectoption( to_char(j), 'SELECTED', cattributes=>'VALUE="' || to_char(j) || '"' );
      else
       htp.formselectoption( to_char(j), cattributes=>'VALUE="' || to_char(j) || '"' );
     end if;
    end loop;
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.LAB_TXT_070), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT">' );
   htp.formselectopen( 'MONTHFROM' );
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_073 then htp.formselectoption( LNG.LAB_TXT_073, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_073 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_074 then htp.formselectoption( LNG.LAB_TXT_074, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_074 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_075 then htp.formselectoption( LNG.LAB_TXT_075, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_075 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_076 then htp.formselectoption( LNG.LAB_TXT_076, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_076 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_077 then htp.formselectoption( LNG.LAB_TXT_077, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_077 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_078 then htp.formselectoption( LNG.LAB_TXT_078, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_078 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_079 then htp.formselectoption( LNG.LAB_TXT_079, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_079 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_080 then htp.formselectoption( LNG.LAB_TXT_080, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_080 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_081 then htp.formselectoption( LNG.LAB_TXT_081, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_081 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_082 then htp.formselectoption( LNG.LAB_TXT_082, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_082 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_083 then htp.formselectoption( LNG.LAB_TXT_083, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_083 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_084 then htp.formselectoption( LNG.LAB_TXT_084, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_084 ); end if;
    htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold(LNG.LAB_TXT_072), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT">' );
   htp.formselectopen( 'MONTHTO' );
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_073 then htp.formselectoption( LNG.LAB_TXT_073, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_073 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_074 then htp.formselectoption( LNG.LAB_TXT_074, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_074 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_075 then htp.formselectoption( LNG.LAB_TXT_075, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_075 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_076 then htp.formselectoption( LNG.LAB_TXT_076, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_076 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_077 then htp.formselectoption( LNG.LAB_TXT_077, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_077 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_078 then htp.formselectoption( LNG.LAB_TXT_078, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_078 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_079 then htp.formselectoption( LNG.LAB_TXT_079, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_079 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_080 then htp.formselectoption( LNG.LAB_TXT_080, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_080 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_081 then htp.formselectoption( LNG.LAB_TXT_081, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_081 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_082 then htp.formselectoption( LNG.LAB_TXT_082, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_082 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_083 then htp.formselectoption( LNG.LAB_TXT_083, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_083 ); end if;
     if trim(to_char(sysdate,'Month')) = LNG.LAB_TXT_084 then htp.formselectoption( LNG.LAB_TXT_084, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_084 ); end if;
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG4.AHC_TXT_100), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT">' );
   htp.formselectopen( 'DAYFROM' );
    for j in 1..31 loop
     htp.formselectoption( to_char(j), cattributes=>'VALUE="' || to_char(j) || '"' );
    end loop;
    htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold(LNG4.AHC_TXT_101), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT">' );
   htp.formselectopen( 'DAYTO' );
    for j in 1..31 loop
     if j = 28
      then
       htp.formselectoption( to_char(j), 'SELECTED', cattributes=>'VALUE="' || to_char(j) || '"' );
      else
       htp.formselectoption( to_char(j), cattributes=>'VALUE="' || to_char(j) || '"' );
     end if;
    end loop;
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG4.AHC_TXT_083), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( htf.formcheckbox( 'BRK', 'T', 'CHECKED' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( htf.bold(LNG4.AHC_TXT_318), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( htf.formcheckbox( 'BRK3', 'T'  ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG5.EXT_TXT_321), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT" COLSPAN="3"');
   htp.tabledata( htf.formcheckbox( 'ROC', 'T' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG4.AHC_TXT_096), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( htf.formcheckbox( 'BRK2', 'T'  ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( htf.bold(LNG.ORD_TXT_179), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT">' );
   htp.formselectopen( 'BRK4' );
    htp.formselectoption( LNG.ORD_TXT_194, 'SELECTED', cattributes=>'VALUE=""' );
    htp.formselectoption( 'AUTHORISATION' );
    htp.formselectoption( 'CHEQUE' );
    htp.formselectoption( 'GIFT' );
    htp.formselectoption( 'MERCHANT' );
    htp.formselectoption( 'PHONE' );
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_774 );
 htp.formclose;
 htp.nl;
 htp.nl;
 htp.bold( LNG5.EXT_TXT_319 );
 htp.nl;
 htp.nl;
 htp.anchor2( 'pfm.purchrep?surl=' || glbx.rndsurl(surl), LNG5.EXT_TXT_563, ctarget=>'ADVANCEDREP' );
 htp.nl;
 htp.anchor( 'adm.order_summary?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid || '&isphg=' || isphg, LNG5.EXT_TXT_320 );
 htp.nl;
 htp.anchor2( 'adm.preorder_stats?surl=' || glbx.rndsurl(surl), LNG4.AHC_TXT_084, ctarget=>'PREORDER_WINDOW' );
 htp.nl;
 htp.anchor( 'adm.gcert_stats?surl=' || glbx.rndsurl(surl), LNG4.AHC_TXT_533 );
 htp.nl;
 htp.anchor( 'adm.load_reconcilliation_data?surl=' || glbx.rndsurl(surl) || '&msg=', LNG5.EXT_TXT_558 );
 htp.nl;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ADM_ACCT_ORDERS',errmsg=>sqlerrm);
end adm_acct_orders;

procedure order_summary( surl in varchar2, phgid in integer default null, isphg in varchar2 default 'F' )
as

 cursor c1(phgid integer, isphg varchar2) is
  select ph.business_name,ph.pid,ca.account_name account_name,ca.aid,
         sum(decode(po.status,LNG.ORD_TXT_120,1,LNG4.AHC_TXT_672,1,LNG4.AHC_TXT_706,1,'PreOrder - Confirmed without Payment',1,0)) tot_pre,
         sum(decode(po.status,'Ordered',1,'Order Authorised',1,'Order Payment Received',1,0)) tot_new,
         sum(decode(po.status,'Processing',1,'Sent to Lab',1,'Received by Lab',1,'Processed by Lab',1,'Order Completed',1,'On Hold',1,0)) tot_pro,
         sum(decode(po.status,'Archived',1,0)) tot_arch,
         sum(decode(po.status,'PreOrder - No Order Made',1,'Customer Cancelled',1,'Photographer Cancelled',1,0)) tot_oth
  from login_session ls, purchase_order po, customer_account ca, photographer ph
  where po.pid = ph.pid and
        ((isphg = 'F') or (isphg = 'T' and po.pid = phgid)) and
        ls.sessid = po.sessid and
        ls.aid = ca.aid
  group by ph.business_name,ph.pid,ca.account_name,ca.aid
 union
  select ph.business_name,ph.pid,cp.account_name,cp.aid,
         sum(decode(po.status,LNG.ORD_TXT_120,1,LNG4.AHC_TXT_672,1,LNG4.AHC_TXT_706,1,'PreOrder - Confirmed without Payment',1,0)) tot_pre,
         sum(decode(po.status,'Ordered',1,'Order Authorised',1,'Order Payment Received',1,0)) tot_new,
         sum(decode(po.status,'Processing',1,'Sent to Lab',1,'Received by Lab',1,'Processed by Lab',1,'Order Completed',1,'On Hold',1,0)) tot_pro,
         sum(decode(po.status,'Archived',1,0)) tot_arch,
         sum(decode(po.status,'PreOrder - No Order Made',1,'Customer Cancelled',1,'Photographer Cancelled',1,0)) tot_oth
  from login_session ls, purchase_order po, customer_profile cp, photographer ph
  where po.pid = ph.pid and
        ((isphg = 'F') or (isphg = 'T' and po.pid = phgid)) and
        ls.sessid = po.sessid and
        ls.aid = cp.profile_id
  group by ph.business_name,ph.pid,cp.account_name,cp.aid
  order by 1,2,3,4;

 sts		varchar2(200);
 sessid		integer;
 lastphg	integer;
 sum_pre	integer;
 sum_new	integer;
 sum_pro	integer;
 sum_arch	integer;
 sum_oth	integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ORDER_SUMMARY');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_360, style=>'MENU', helpid=>'A34' );
 htp.p('<CENTER>');
 htp.nl;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG3.ADM_TXT_261),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( htf.bold(LNG.PHG_TXT_199),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( htf.bold(LNG.ORD_TXT_120),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( htf.bold(LNG.ORD_TXT_121),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( htf.bold(LNG.ORD_TXT_202),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( htf.bold(LNG.ORD_TXT_127),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( htf.bold(LNG3.ADM_TXT_773),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( htf.bold(LNG.PHG_ALT_432),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
  htp.tablerowclose;

 lastphg := NULL;
 sum_pre := 0;
 sum_new := 0;
 sum_oth := 0;
 for c1rec in c1(phgid,isphg) loop
  htp.tablerowopen;
   if (lastphg <> c1rec.pid) and (lastphg is not null)
    then
     htp.tablerowopen;
      htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( htf.bold(sum_pre),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata( htf.bold(sum_new),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata( htf.bold(sum_pro),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata( htf.bold(sum_arch),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata( htf.bold(sum_oth),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata( htf.anchor( 'adm.order_report?surl=' || glbx.rndsurl(surl) || '&phgid=' || lastphg || '&acid=&brk=T&brk2=F&isphg=' || isphg, LNG3.ADM_TXT_774),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
     htp.tablerowclose;
     sum_pre := 0;
     sum_new := 0;
     sum_oth := 0;
     lastphg := c1rec.pid;
    else
     if lastphg is null then lastphg := c1rec.pid; end if;
   end if;
   htp.tabledata( c1rec.business_name,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( c1rec.account_name,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( c1rec.tot_pre,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( c1rec.tot_new,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( c1rec.tot_pro,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( c1rec.tot_arch,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( c1rec.tot_oth,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( htf.anchor( 'adm.order_report?surl=' || glbx.rndsurl(surl) || '&phgid=' || c1rec.pid || '&acid=' || c1rec.aid || '&brk=T&brk2=F&isphg=' || isphg, LNG3.ADM_TXT_774),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   sum_pre := sum_pre + nvl(c1rec.tot_pre,0);
   sum_new := sum_new + nvl(c1rec.tot_new,0);
   sum_pro := sum_pro + nvl(c1rec.tot_pro,0);
   sum_arch := sum_arch + nvl(c1rec.tot_arch,0);
   sum_oth := sum_oth + nvl(c1rec.tot_oth,0);
  htp.tablerowclose;
 end loop;
 htp.tablerowopen;
   htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( htf.bold(sum_pre),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( htf.bold(sum_new),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( htf.bold(sum_pro),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( htf.bold(sum_arch),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( htf.bold(sum_oth),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER">'  );
   htp.anchor( 'adm.order_report?surl=' || glbx.rndsurl(surl) || '&phgid=' || lastphg || '&acid=&brk=T&brk2=F&roc=F&isphg=' || isphg, LNG3.ADM_TXT_774);
   htp.nl;
   htp.anchor( 'adm.order_report?surl=' || glbx.rndsurl(surl) || '&phgid=' || lastphg || '&acid=&brk=T&brk2=F&roc=T&isphg=' || isphg, LNG5.EXT_TXT_322);
   htp.p( '</TD>' );
 htp.tablerowclose;

 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ORDER_SUMMARY',errmsg=>sqlerrm);
end order_summary;

procedure order_report(surl varchar2, phgid in integer, acid in integer, yearfrom in varchar2 default '2000', yearto in varchar2 default '2010', monthfrom in varchar2 default LNG.LAB_TXT_073, monthto in varchar2 default LNG.LAB_TXT_084, dayfrom in varchar2 default '01', dayto in varchar2 default '31', brk in varchar2 default 'F', brk2 in varchar2 default 'F', brk3 in varchar2 default 'F', brk4 in varchar2 default null, pname in varchar2 default null, isphg in varchar2 default 'F', roc in varchar2 default 'F')
as

 cursor c1(phgid integer, acid integer, dtf date, dtt date, brk2 varchar2, brk3 varchar2, brk4 varchar2, pname varchar2, roc varchar2 ) is
  select /*+ ALL_ROWS */
         po_pid pid, ls_aid aid, status, poid, paid_method, po_date_created date_created, delivery_cost,
         sendto_name, lab_charge_perc, contact_email, sessid, cusername, account_name, business_name, pusername
  from
  (
  select /*+ ALL_ROWS */
         po.pid po_pid,ls.aid ls_aid,po.status,po.poid,po.paid_method,po.date_created po_date_created,po.delivery_cost,
         po.sendto_name,ph.lab_charge_perc,po.contact_email,po.sessid, ca.username cusername, ca.account_name, ph.business_name, ph.username pusername
  from login_session ls, customer_account ca, photographer ph, purchase_order po
  where (((po.pid = phgid) and (phgid > 0)) or (phgid=0)) and
        po.sessid = ls.sessid and
        ph.pid = ca.pid and
        ca.aid = ls.aid and
        ((pname is null) or (pname is not null and upper(sendto_name) like '%' || upper(pname) || '%')) and
        ((brk4 is null) or (brk4 is not null and po.paid_method = brk4 )) and
        nvl(po.date_created,dtf) >= dtf and
        nvl(po.date_created,dtt) <= dtt and
        (
          ((po.status not in ('PreOrder - No Order Made','PreOrder','PreOrder - Sent to Bank','PreOrder - Confirmed without Payment','Awaiting Authorisation','Customer Cancelled','Photographer Cancelled','PreOrder - Confirmed without Payment')) and brk2 = 'F') or
          (brk2 = 'T' and po.status <> 'PreOrder - No Order Made')
         ) and
        (((ls.aid = acid) and (acid is not null)) or (acid is null)) and
        ((roc = 'F') or (roc = 'T' and exists
         (select 'x'
          from purchase_audit pa
          where to_char(pa.date_changed,'MMYYYY') = to_char(po.date_created,'MMYYYY') and
                pa.poid = po.poid and
                pa.column_name = 'STATUS' and
                pa.new_value = 'Order Completed'
         ) )
        )
  union
  select /*+ ALL_ROWS */
         po.pid,ls.aid,po.status,po.poid,po.paid_method,po.date_created,po.delivery_cost,
         po.sendto_name,ph.lab_charge_perc,po.contact_email,po.sessid, cp.username cusername, cp.account_name, ph.business_name, ph.username pusername
  from login_session ls, customer_profile cp, photographer ph, purchase_order po
  where (((po.pid = phgid) and (phgid > 0)) or (phgid=0)) and
        po.sessid = ls.sessid and
        ph.pid = cp.pid and
        cp.profile_id = ls.aid and
        ((pname is null) or (pname is not null and upper(sendto_name) like '%' || upper(pname) || '%')) and
        ((brk4 is null) or (brk4 is not null and po.paid_method = brk4 )) and
        nvl(po.date_created,dtf) >= dtf and
        nvl(po.date_created,dtt) <= dtt and
        (
          ((po.status not in ('PreOrder - No Order Made','PreOrder','PreOrder - Sent to Bank','Awaiting Authorisation','Customer Cancelled','Photographer Cancelled','PreOrder - Confirmed without Payment')) and brk2 = 'F') or
          (brk2 = 'T' and po.status <> 'PreOrder - No Order Made')
         ) and
        (((ls.aid = acid) and (acid is not null)) or (acid is null)) and
        ((roc = 'F') or (roc = 'T' and exists
         (select 'x'
          from purchase_audit pa
          where to_char(pa.date_changed,'MMYYYY') = to_char(po.date_created,'MMYYYY') and
                pa.poid = po.poid and
                pa.column_name = 'STATUS' and
                pa.new_value = 'Order Completed'
         ) )
        )
  )
  order by decode(brk3,'T',poid,1) desc,pusername,cusername,po_date_created desc;

 cursor c2(purchid integer) is select count('x') tot from shopping_basket where poid = purchid;

 cursor c3(phgid integer) is select payment_style,charge_option1_royalty from photographer ph,charge_plan cp where ph.plan_id = cp.id;

 crec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 lstmonth	varchar2(100);
 lstpid		integer;
 sessid		integer;
 tot		integer;
 gtotal		number;
 subtotal	number;
 handling	number;
 royalty	number;
 phg_receives	number;
 tax		number;
 postage	number;
 total_full	number;
 total_phg	number;
 total_lab	number;
 total_admin	number;
 total_tax	number;
 dtf		date;
 dtt		date;
 sts		varchar2(200);
 min_day	integer;
 max_day	integer;
 parm1 		GLBX.MYARRAY;
 parm2 		GLBX.MYARRAY_NMB;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ORDER_REPORT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if isphg = 'T'
  then
   main_title( surl, sessid, LNG3.ADM_TXT_774, style=>'NOMENU', helpid=>'A66' );
  else
   main_title( surl, sessid, LNG3.ADM_TXT_774, style=>'MENU', helpid=>'A66' );
 end if;
 htp.nl;
 max_day := least(to_number(dayto),to_number(to_char(last_day(to_date(monthto || ' ' || yearto, 'Month YYYY')),'DD')));
 if min_day > max_day then min_day := max_day; else min_day := to_number(dayfrom); end if;
 begin dtf := to_date(min_day || ' ' || monthfrom || ' ' || yearfrom, 'DD Month YYYY'); exception when others then dtf := sysdate - 30000; end;
 begin dtt := to_date(max_day || ' ' || monthto || ' ' || yearto || ' 23:59', 'DD Month YYYY HH24:MI'); exception when others then dtf := sysdate + 30000; end;
 open c1(phgid,acid,dtf,dtt,brk2,brk3,brk4,pname,roc);
 htp.p( '<CENTER>' );
 htp.bold( to_char(dtf,'DD Month YYYY') || '-' || to_char(dtt,'DD Month YYYY') );
 htp.nl;
 lstmonth := NULL;
 lstpid := 0;

 loop
   fetch c1 into crec;
   if c1%NOTFOUND then close c1; exit; end if;

   if ((lstmonth is null) or (lstmonth <> to_char(nvl(crec.date_created,sysdate),'Month YYYY') and (brk = 'T')) or (lstpid <> crec.pid))
    then

     if lstmonth is not null
      then
       htp.tablerowopen;
        htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( htf.bold(LNG.CST_TXT_138),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
        htp.tabledata( htf.bold(to_char(total_full,LNG.MONEY_FORMAT)),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="RIGHT"');
        htp.tabledata( htf.bold(to_char(total_phg,LNG.MONEY_FORMAT)),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="RIGHT"');
        htp.tabledata( htf.bold(to_char(total_lab,LNG.MONEY_FORMAT)),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="RIGHT"');
        htp.tabledata( htf.italic( LNG.LAB_TXT_016 ) || ' ' || htf.bold(to_char(total_tax,LNG.MONEY_FORMAT)) || htf.nl ||
                       htf.bold(to_char(total_admin,LNG.MONEY_FORMAT)),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="RIGHT"');
       htp.tablerowclose;
       htp.tableclose;
      end if;

      if lstpid <> crec.pid
       then
        htp.nl;
        htp.line;
        open c3(crec.pid);
        fetch c3 into c3rec;
        close c3;
      end if;

     total_full := 0;
     total_phg := 0;
     total_lab := 0;
     total_admin := 0;
     total_tax := 0;
     htp.nl;
     htp.nl;
     htp.bold( crec.business_name || ' - ' || to_char(nvl(crec.date_created,sysdate),'Month YYYY') || htf.italic( ' (' || c3rec.payment_style || ')' ));
     htp.nl;
     htp.nl;
     htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG.PHG_TXT_199 ),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata( htf.bold( LNG.ORD_TXT_188 ),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata( htf.bold( LNG.CST_TXT_099 ),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata( htf.bold( LNG.GLB_TXT_066 ),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata( htf.bold( LNG.CST_TXT_135 ),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata( htf.bold( LNG.PHG_TXT_085 ),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"'); -- Order Total
       htp.tabledata( htf.bold( LNG5.EXT_TXT_343),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata( htf.bold( LNG5.EXT_TXT_344),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata( htf.bold( LNG5.EXT_TXT_345),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
   end if;
   tot := 0;
   open c2(crec.poid);
   fetch c2 into tot;
   close c2;
   -- Note: GST hardcoded in at 10%
   -- glbx.extract_photographer_order( crec.poid, 10, subtotal, gtotal, handling, royalty, phg_receives, tax, postage, include_gift_certificate=>FALSE );
   glbx.calculate_pricing( crec.poid, parm1, parm2 );

   htp.tablerowopen;
    htp.tabledata( htf.bold(crec.account_name),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( to_char(crec.date_created,LNG.MASK),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.anchor2('adm.dispord?surl=' || glbx.rndsurl(surl) || '&purchid=' || crec.poid, crec.poid,ctarget=>new_window),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( '<FONT SIZE=-1>' || LNG.PHG_TXT_084 || ':' || crec.sendto_name || htf.nl ||
                   LNG.PHG_TXT_301 || ': ' || crec.contact_email || htf.nl ||
                   LNG.ORD_TXT_179 || ': ' || crec.paid_method || htf.nl ||
                   LNG.PHG_TXT_093 || ': ' || crec.status || '</FONT>',cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( to_char(tot) ,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' valign="BOTTOM" align="RIGHT">');
      htp.p('<FONT SIZE="-1">' );
      htp.italic(LNG.ORD_TXT_121 || ':' || to_char(glbx.retrieve_pricing_value( 'SUB_TOTAL', parm1, parm2 ),LNG.MONEY_FORMAT));
      htp.nl;
      htp.italic(LNG.ORD_TXT_102 || ':' || to_char(nvl(glbx.retrieve_pricing_value( 'POSTAGE', parm1, parm2 ),0),LNG.MONEY_FORMAT));
      htp.nl;
      htp.italic('Surcharge' || ':' || to_char(nvl(glbx.retrieve_pricing_value( 'SURCHARGE', parm1, parm2 ),0),LNG.MONEY_FORMAT));
      htp.nl;
      htp.p( '</FONT>' );
      htp.bold(to_char(glbx.retrieve_pricing_value( 'GRAND_TOTAL_NOCERT', parm1, parm2 ),LNG.MONEY_FORMAT));
    htp.p( '</TD>' );

    -- Photographer Receives
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' valign="BOTTOM" align="RIGHT">');
     htp.p('<FONT SIZE="-1">' );
     htp.italic(LNG5.EXT_TXT_285 || ' ' );
     if glbx.retrieve_pricing_value( 'PHG_DISCOUNT', parm1, parm2 ) > 0
      then
       htp.italic( glbx.retrieve_pricing_value( 'PHG_DISCOUNT', parm1, parm2 ) || '%' || ' ');
     end if;
     if glbx.retrieve_pricing_value( 'SPECIAL_DISCOUNT', parm1, parm2 ) > 0
      then
       htp.italic( glbx.retrieve_pricing_value( 'SPECIAL_DISCOUNT', parm1, parm2 ) || '%' || ' ');
     end if;
     htp.italic(to_char(glbx.retrieve_pricing_value( 'DISCOUNT', parm1, parm2 ),LNG.MONEY_FORMAT) );
     htp.nl;
     htp.italic(LNG.LAB_TXT_016 || ' ' || glbx.retrieve_pricing_value( 'GST', parm1, parm2 ) || '%' || to_char(glbx.retrieve_pricing_value( 'GST_VALUE', parm1, parm2 ),LNG.MONEY_FORMAT) );
     htp.nl;
     htp.p( '</FONT>' );
     htp.bold(to_char(glbx.retrieve_pricing_value( 'PHOTOGRAPHER_GETS', parm1, parm2 ),LNG.MONEY_FORMAT));
    htp.p( '</TD>' );

    -- Lab Receives Receives
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' valign="BOTTOM" align="RIGHT">');
     htp.p('<FONT SIZE="-1">' );
     htp.italic(LNG2.PBK_TXT_028 || ' ' || to_char(glbx.retrieve_pricing_value( 'TOTAL_PRODUCT_PRICE', parm1, parm2 ),LNG.MONEY_FORMAT));
     htp.nl;
     htp.italic(LNG2.FNM_TXT_075 || ' ' || to_char(glbx.retrieve_pricing_value( 'LAB_POSTAGE', parm1, parm2 ),LNG.MONEY_FORMAT));
     htp.nl;
     htp.italic(LNG2.FNM_TXT_171 || ' ' || to_char(glbx.retrieve_pricing_value( 'LAB_EXTRA_COST', parm1, parm2 ),LNG.MONEY_FORMAT));
     htp.nl;
     htp.p( '</FONT>' );
     htp.bold(LNG.CST_TXT_136 || ' ' || to_char(glbx.retrieve_pricing_value( 'LAB_GETS', parm1, parm2 ),LNG.MONEY_FORMAT));
    htp.p( '</TD>' );

    -- Admin Receives
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' valign="BOTTOM" align="RIGHT">');
     htp.p('<FONT SIZE="-1">' );
     htp.italic(LNG.LAB_TXT_017 || ' ' || to_char(glbx.retrieve_pricing_value( 'COMMISSION', parm1, parm2 ),LNG.MONEY_FORMAT));
     htp.nl;
     htp.italic(LNG.LAB_TXT_016 || ' ' || to_char(glbx.retrieve_pricing_value( 'TAX', parm1, parm2 ),LNG.MONEY_FORMAT));
     htp.nl;
     htp.italic(LNG3.ADM_TXT_068 || ' ' || to_char(glbx.retrieve_pricing_value( 'HANDLING', parm1, parm2 ),LNG.MONEY_FORMAT));
     htp.nl;
     htp.p( '</FONT>' );
     htp.bold(LNG.CST_TXT_136 || ' ' || to_char(glbx.retrieve_pricing_value( 'GETS', parm1, parm2 ),LNG.MONEY_FORMAT));
    htp.p( '</TD>' );

    total_full := total_full + glbx.retrieve_pricing_value( 'GRAND_TOTAL_NOCERT', parm1, parm2 );
    total_phg := total_phg + glbx.retrieve_pricing_value( 'PHOTOGRAPHER_GETS', parm1, parm2 );
    total_lab := total_lab + glbx.retrieve_pricing_value( 'LAB_GETS', parm1, parm2 );
    total_admin := total_admin + glbx.retrieve_pricing_value( 'GETS', parm1, parm2 );
    total_tax := total_tax + glbx.retrieve_pricing_value( 'TAX', parm1, parm2 );

   htp.tablerowclose;
   lstmonth := to_char(nvl(crec.date_created,sysdate),'Month YYYY');
   lstpid := crec.pid;
  end loop;

  htp.tablerowopen;
   htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( htf.bold(LNG.CST_TXT_138),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( htf.bold(to_char(total_full,LNG.MONEY_FORMAT)),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( htf.bold(to_char(total_phg,LNG.MONEY_FORMAT)),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="RIGHT"');
   htp.tabledata( htf.bold(to_char(total_lab,LNG.MONEY_FORMAT)),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="RIGHT"');
   htp.tabledata( htf.italic( LNG.LAB_TXT_016 ) || ' ' || htf.bold(to_char(total_tax,LNG.MONEY_FORMAT)) || htf.nl ||
                  htf.bold(to_char(total_admin,LNG.MONEY_FORMAT)),cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="RIGHT"');
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.formopen( 'adm.adm_acct_orders' );
  htp.formhidden( 'SURL',  glbx.rndsurl(surl));
  htp.formhidden( 'PHGID', phgid );
  htp.formhidden( 'ISPHG', isphg );
  htp.formsubmit( NULL, LNG.ORD_TXT_136 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
end order_report;

procedure dba_admin(surl varchar2,msg in varchar2 default null)
as
 cursor c1 is select * from v$database;
 cursor c2 is select * from v$instance;
 cursor c3 is select * from v$parameter;
 cursor c4 is select * from v$sysstat;
 cursor c5 is
  select vf.file#,vf.phyrds,vf.phywrts,vd.name,vd.bytes,vd.block_size
  from v$filestat vf, v$datafile vd
  where vf.file#=vd.file#
  order by vf.file#;

 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.DBA_ADMIN');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_275, helpid=>'A36' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.bold( 'V$DATABASE: ' ); htp.nl;
 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_366 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG.PHG_TXT_022 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_367 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
     htp.tabledata(htf.bold( c1rec.dbid ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c1rec.name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( to_char(c1rec.created,LNG.MASK) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;

 htp.nl;
 htp.bold( 'V$INSTANCE: ' ); htp.nl;
 htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_368 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG.PHG_TXT_022 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_369 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_370 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_371 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 for c2rec in c2 loop
  htp.tablerowopen;
     htp.tabledata(htf.bold( c2rec.instance_number ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c2rec.instance_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c2rec.host_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c2rec.version ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( to_char(c2rec.startup_time,LNG.TSMASK) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;

 htp.nl;
 htp.bold( 'V$PARAMETERS: ' ); htp.nl;
 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_022 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG.CST_TXT_013 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_105 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 for c3rec in c3 loop
  htp.tablerowopen;
     htp.tabledata(htf.bold( c3rec.name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c3rec.value ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c3rec.description ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;

 htp.nl;
 htp.bold( 'V$SYSSTAT: ' ); htp.nl;
 htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_022 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_190 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG.CST_TXT_013 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 for c4rec in c4 loop
  htp.tablerowopen;
     htp.tabledata(htf.bold( c4rec.name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c4rec.class ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c4rec.value ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;

 htp.nl;
 htp.bold( 'V$FILESTAT: ' ); htp.nl;
 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( '#' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG.PHG_TXT_022 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_289 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_167 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_137 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_134 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 for c5rec in c5 loop
  htp.tablerowopen;
     htp.tabledata(htf.bold( c5rec.file# ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c5rec.name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c5rec.bytes ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c5rec.block_size ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c5rec.phyrds ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c5rec.phywrts ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;

 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'DBA_ADMIN',errmsg=>sqlerrm);
end dba_admin;

procedure trapped_errors(surl varchar2,msg in varchar2 default null)
as
 cursor c1 is select * from error_trap order by date_created desc,package_name;

 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.TRAPPED_ERRORS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_138, helpid=>'A37' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.ORD_TXT_188 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_139 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_156 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( 'PID' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( 'AID' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( 'PHID' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( 'POID' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_091 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_064 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
     htp.tabledata(htf.bold( to_char(c1rec.date_created,LNG.TSMASK) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c1rec.package_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c1rec.procedure_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c1rec.pid ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c1rec.aid ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c1rec.phid ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c1rec.poid ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c1rec.error_message ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c1rec.extra_details ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formopen( 'adm.cull_trapped_errors' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
  htp.p( LNG3.ADM_TXT_062 || ' : ' || htf.formtext( 'P1',10,10,'5') );
  htp.formsubmit( null, 'Cull' );
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'TRAPPED_ERRORS',errmsg=>sqlerrm);
end trapped_errors;


procedure cull_trapped_errors(surl varchar2,p1 in varchar2)
as
 sessid		integer;
 sts		varchar2(200);
 nmb		integer;
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.CULL_TRAPPED_ERRORS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 begin nmb := to_number(p1); exception when others then nmb := 5; end;
 delete from error_trap where date_created < (sysdate-nmb);
 nmb := SQL%ROWCOUNT;
 commit;
 trapped_errors( surl,nmb || ' Rows Deleted');
exception when others then
 glbx.error_details( 'ADM', 'CULL_TRAPPED_ERRORS',errmsg=>sqlerrm);
end cull_trapped_errors;

procedure remove_job(surl varchar2,id in integer)
as
 sessid		integer;
 sts		varchar2(200);
 tot		integer;
 tmp		char(1);
 foundrec	boolean;
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.REMOVE_JOB');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 dbms_job.remove(id);
 commit;
 htp.htmlopen;
  htp.bold( LNG2.PBK_TXT_032 );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'REMOVE_JOB',errmsg=>sqlerrm);
end remove_job;

procedure mfc_form_load(surl varchar2, manid in integer, msg in varchar2 default null)
as
 cursor c1(manid integer) is select * from manufacturer where manufacturer_id=manid and manid > 0;
 cursor c4 is select job,next_date from all_jobs where upper(what) like 'ADM.ACCEPT%' order by next_date desc;

 c1rec		c1%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 tot		integer;
 cprog		boolean;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.FORM_LOAD');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 open c1(manid);
 fetch c1 into c1rec;
 close c1;
 cprog := TRUE;
 main_title( surl, sessid, LNG3.ADM_TXT_036, style=>'NOMENU' );
 htp.nl;
 htp.ulistopen;
  htp.listitem( htf.bold( c1rec.name ));
   htp.ulistopen;
    htp.listitem( htf.anchor( 'adm.large_load?surl=' || glbx.rndsurl(surl) || '&phgid=&acid=' || c1rec.manufacturer_id || '&typ=FILE', LNG3.ADM_TXT_374 ) );
    if cprog
     then
      htp.listitem( htf.anchor( 'adm.large_load?surl=' || glbx.rndsurl(surl) || '&phgid=&acid=' || c1rec.manufacturer_id || '&typ=WILD', LNG3.ADM_TXT_375 ) );
    end if;
    htp.listitem( htf.anchor2( 'glbx.displog?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.manufacturer_id, LNG3.ADM_TXT_756, ctarget=>new_window ) );
   htp.ulistclose;
 htp.ulistclose;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_822 || ':' ); htp.nl;
 for c4rec in c4 loop
  htp.p( to_char(c4rec.next_date,'DD Mon YYYY HH24:MI') || '-');
  htp.anchor( 'adm.remove_job?surl=' || glbx.rndsurl(surl) || '&id=' || c4rec.job, LNG2.PBK_TXT_032 ); htp.nl;
 end loop;
 htp.nl;
 htp.anchor2( 'admin.manage_batch_queue?surl=' || glbx.rndsurl(surl) || '&msg=',LNG5.EXT_TXT_116,ctarget=>'BATCH_WINDOW' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MFC_FORM_LOAD',errmsg=>sqlerrm);
end mfc_form_load;

procedure form_load(surl varchar2, phgid in integer, msg in varchar2 default null)
as

 cursor c1(phgid integer) is select aid,account_name from customer_account where pid=phgid and aid > 0 order by account_name;
 cursor c4 is select job,next_date,what from all_jobs where upper(what) like 'ADM.ACCEPT%' order by next_date desc;
 cursor c5 is select job,next_date,what from all_jobs where upper(what) like 'ADM.RUN_LOAD_JOB%VLOAD_ID=>%' order by job;

 c1rec		c1%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 tmp		char(1);
 foundrec	boolean;
 cprog		boolean;
 x		integer;
 y		integer;
 tmp2		varchar2(32767);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.FORM_LOAD');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 cprog := TRUE;
 main_title( surl, sessid, LNG3.ADM_TXT_036, style=>'NOMENU' );
 htp.nl;
 foundrec := FALSE;
 htp.ulistopen;
 htp.listitem( htf.anchor('adm.load_create?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid, LNG3.ADM_TXT_010 ));
 for c1rec in c1(phgid) loop
  foundrec := TRUE;
  htp.listitem( htf.bold( c1rec.account_name ));
   htp.ulistopen;
    /*
    htp.listitem( htf.anchor( 'adm.large_load?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid || '&acid=' || c1rec.aid || '&typ=FILE', LNG3.ADM_TXT_374 ) );
    if cprog
     then
      htp.listitem( htf.anchor( 'adm.large_load?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid || '&acid=' || c1rec.aid || '&typ=WILD', LNG3.ADM_TXT_375 ) );
    end if;
    */
    htp.listitem( htf.anchor( 'adm.image_load?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid || '&acid=' || c1rec.aid || '&typ=LOAD', LNG5.EXT_TXT_649 ) );
    htp.listitem( htf.anchor( 'adm.image_load?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid || '&acid=' || c1rec.aid || '&typ=ATTACH', LNG5.EXT_TXT_650 ) );
    htp.listitem( htf.anchor( 'adm.image_load?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid || '&acid=' || c1rec.aid || '&typ=META', LNG5.EXT_TXT_651 ) );
    --xxx language file
    htp.listitem( htf.anchor( 'adm.xml_attach_meta?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid, 'Load/Attach using XML' ) );
    htp.listitem( htf.anchor2( 'glbx.displog?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid, LNG3.ADM_TXT_756, ctarget=>new_window ) );
   htp.ulistclose;
 end loop;
 htp.ulistclose;
 if not foundrec then htp.bold(htf.italic( LNG3.ADM_TXT_376 )); htp.nl; end if;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_822 || ':' ); htp.nl;
 for c4rec in c4 loop
  htp.p( to_char(c4rec.next_date,'DD Mon YYYY HH24:MI') || '-');
  htp.anchor( 'adm.remove_job?surl=' || glbx.rndsurl(surl) || '&id=' || c4rec.job, LNG2.PBK_TXT_032 ); htp.nl;
 end loop;
 htp.nl;
 htp.anchor2( 'admin.manage_batch_queue?surl=' || glbx.rndsurl(surl) || '&msg=',LNG5.EXT_TXT_116,ctarget=>'BATCH_WINDOW' );
 htp.nl;
 htp.nl;
 for c5rec in c5 loop
   x := instr(c5rec.what,'vload_id=>') + length('vload_id=>') + 1;
   y := instr(c5rec.what,',',x+1);
   tmp2 := tmp2 || htf.formselectoption( trim(replace(replace(substr(c5rec.what,x,(y-x)+1),'''',''),',','')));
 end loop;
 if tmp2 is not null
  then
   htp.line;
   htp.nl;
   htp.bold( 'Monitor Parallel Job' );
   htp.nl;
   htp.formopen( 'adm.monitor_screen' );
   htp.formhidden( 'SURL', surl );
   htp.bold( 'vload_id:' );
   htp.formselectopen( 'VLOAD_ID' );
   htp.p( tmp2 );
   htp.formselectclose;
   htp.nl;
   htp.formsubmit( null, 'Refresh' );
   htp.formclose;
 end if;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'FORM_LOAD',errmsg=>sqlerrm);
end form_load;

procedure beta_users(surl varchar2,typ in varchar2 default 'STND', msg in varchar2 default null)
is
 cursor c1 is select aid,account_name,username,is_beta_tester from customer_account order by aid;
 cursor c2 is select pid,business_name,username,is_beta_tester from photographer order by pid;
 cursor c3 is select manufacturer_id,name,username,is_beta_tester from manufacturer order by manufacturer_id;
 cursor c4 is
  select username,account_name nme,LNG.PHG_TXT_199 typ from customer_account
  union all
  select username,business_name nme, LNG3.ADM_TXT_261 typ from photographer
  union all
  select username,name nme, LNG2.PBK_TXT_009 typ from manufacturer
  order by 1;
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.BETA_USERS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG4.AHC_TXT_423, helpid=>'A39' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p('<CENTER>');
 htp.nl;
 if typ = 'CUST'
  then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1');
     htp.tablerowopen;
      htp.tableheader( LNG.GLB_TXT_076, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
      htp.tableheader( LNG3.ADM_TXT_127, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
      htp.tableheader( LNG3.ADM_TXT_403, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
     htp.tablerowclose;
     for c4rec in c4 loop
      htp.tablerowopen;
       htp.tabledata( c4rec.username, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( c4rec.nme, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( c4rec.typ, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      htp.tablerowclose;
     end loop;
    htp.tableclose;
   htp.htmlclose;
   return;
 end if;
 htp.formopen( 'adm.accept_beta_users' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.tableopen( cattributes=>'border=1');
  htp.tablerowopen;
   htp.tableheader( LNG3.ADM_TXT_238, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tableheader( 'ID', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tableheader( LNG.PHG_TXT_022, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tableheader( LNG.GLB_TXT_076, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tableheader( LNG3.ADM_TXT_404, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;
  for c1rec in c1 loop
  htp.tablerowopen;
   htp.formhidden('ID', c1rec.aid );
   htp.formhidden('CT', LNG.PHG_TXT_199);
   htp.tabledata( LNG.PHG_TXT_199 , cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( c1rec.aid, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( c1rec.account_name, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( c1rec.username, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.formtext( 'P1',5, 1, nvl(c1rec.is_beta_tester,'F')), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  end loop;
  for c2rec in c2 loop
  htp.tablerowopen;
   htp.formhidden('ID', c2rec.pid );
   htp.formhidden('CT', LNG3.ADM_TXT_261);
   htp.tabledata( LNG3.ADM_TXT_261, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( c2rec.pid, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( c2rec.business_name, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( c2rec.username, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.formtext( 'P1',5, 1, nvl(c2rec.is_beta_tester,'F')), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  end loop;
  for c3rec in c3 loop
  htp.tablerowopen;
   htp.formhidden('ID', c3rec.manufacturer_id );
   htp.formhidden('CT', 'MANUFACTURER');
   htp.tabledata( LNG2.PBK_TXT_009, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( c3rec.manufacturer_id, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( c3rec.name, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( c3rec.username, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.formtext( 'P1',5, 1, nvl(c3rec.is_beta_tester,'F')), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit(null,LNG3.ADM_TXT_405);
 htp.formclose;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'BETA_USERS', errmsg=>sqlerrm, extdet=>null);
end beta_users;

procedure accept_beta_users( surl varchar2,id in MYARRAY, ct in MYARRAY, p1 in MYARRAY )
as
 sessid	integer;
 sts	varchar2(200);
 bt	char(1);
 pd	integer;
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_BETA_USERS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 for j in id.first..id.last loop
  bt := upper(p1(j));
  bt := nvl(bt,'F');
  if bt not in ('T','F') then bt := 'F'; end if;
  if ct(j) = LNG.PHG_TXT_199
   then
    update customer_account set is_beta_tester = bt where aid = id(j);
  elsif ct(j) = LNG3.ADM_TXT_261
   then
    pd := id(j);
    update photographer set is_beta_tester = bt where pid = pd;
  elsif ct(j) = 'MANUFACTURER'
   then
    update manufacturer set is_beta_tester = bt where manufacturer_id = id(j);
  end if;
 end loop;
 commit;
 beta_users(surl,'Updated');
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_BETA_USERS', errmsg=>sqlerrm, extdet=>null);
end accept_beta_users;

procedure program_stats(surl varchar2)
as
 cursor c1 is select object_name,object_type from user_objects where object_type like 'PAC%' and object_name not like 'OW%' order by object_name,object_type;
 cursor c2(obn varchar2, ot varchar2) is select count(line) from user_source where name = obn and type = ot;
 sessid	integer;
 sts	varchar2(200);
 tot	integer;
 gtot	integer;
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.PROGRAM_STATS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_409, helpid=>'A41' );
 htp.p('<CENTER>');
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tableheader( LNG.PHG_TXT_376, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"'  );
   htp.tableheader( LNG3.ADM_TXT_411, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"'  );
   htp.tableheader( LNG3.ADM_TXT_412, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"'  );
  htp.tablerowclose;
  gtot := 0;
  for c1rec in c1 loop
   tot := 0;
   open c2(c1rec.object_name,c1rec.object_type);
   fetch c2 into tot;
   close c2;
   gtot := gtot + nvl(tot,0);
   htp.tablerowopen;
    htp.tabledata( c1rec.object_type, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( c1rec.object_name, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(tot), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
  end loop;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( 'Grand Total', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.bold(to_char(gtot)), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.tableclose;
  htp.p('</CENTER>');
  htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'PROGRAM_STATS', errmsg=>sqlerrm, extdet=>null);
end program_stats;

procedure expire_phg_cust( surl varchar2,phgid in integer )
as
 cursor c1(phgid integer) is
   select 'CUSTOMER' custype,aid,date_created,date_expires,account_name,username
   from customer_account
   where pid = phgid
  union all
   select 'PROFILE' custype,profile_id aid,date_created,date_expires,account_name,username
   from customer_profile
   where pid = phgid
   order by 4 desc;
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.EXPIRE_PHG_CUST');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_038, style=>'NOMENU', helpid=>'A42' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.italic( LNG3.ADM_TXT_414);
 htp.nl;
 htp.nl;
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
  htp.tablerowopen;
   htp.tableheader( LNG3.ADM_TXT_545,cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tableheader( LNG.PHG_TXT_164,cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tableheader( LNG3.ADM_TXT_063,cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tableheader( LNG.GLB_TXT_078,cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tableheader( LNG3.ADM_TXT_415,cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tableheader( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;
  for c1rec in c1(phgid) loop
   htp.tablerowopen;
    if sysdate < c1rec.date_expires or c1rec.date_expires is null
     then
      htp.tabledata( c1rec.custype,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.anchor('adm.modify_expiry?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid || '&acid=' || c1rec.aid || '&custype=' || c1rec.custype,c1rec.account_name),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( c1rec.username,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( to_char(c1rec.date_created,LNG.MASK),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( nvl(to_char(c1rec.date_expires,LNG.MASK),'&nbsp;'),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
     else
      htp.tabledata( c1rec.custype,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.anchor('adm.modify_expiry?surl=' || glbx.rndsurl(surl) || '&phgid=' || phgid || '&acid=' || c1rec.aid || '&custype=' || c1rec.custype,htf.bold(c1rec.account_name)),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold(c1rec.username),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold(to_char(c1rec.date_created,LNG.MASK)),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.bold(to_char(c1rec.date_expires,LNG.MASK)),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.italic(LNG3.ADM_TXT_709),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
    end if;
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'EXPIRE_PHG_CUST', errmsg=>sqlerrm, extdet=>null);
end expire_phg_cust;

procedure modify_expiry( surl varchar2, phgid in integer, acid in integer, custype in varchar2 default 'CUSTOMER' )
as
 cursor c1(phgid integer, acid integer) is
   select aid,date_created,date_expires,account_name,username,plan_event,receive_images_via_email,receive_image_account,receive_image_umo_scene, scene_name category, receive_image_options
   from customer_account
   where pid = phgid and
         aid = acid;

 cursor c2(phgid integer, acid integer) is
   select profile_id aid,date_created,date_expires,account_name,username,null plan_event,receive_images_via_email,receive_image_account,receive_image_umo_scene, scene_name category, receive_image_options
   from customer_profile
   where pid = phgid and
         profile_id = acid;

 cursor c3(phgid integer) is select plan_event from charge_plan_event where plan_id in (select plan_id from photographer where pid = phgid) order by plan_event;

 cursor c4(v_category varchar2, v_owner_id integer) is
 select umo_scene_id,owned_by,order_by,title,parent_scene
   from umo_scene
   where category = v_category and
   owned_by = 'PUBLIC'
  union all
  select usc.umo_scene_id, usc.owned_by, usc.order_by, usc.title, usc.parent_scene
  from umo_scene usc, photographer ph
  where category = v_category and
        usc.owner_id = ph.pid and
        ph.pid = v_owner_id and
        owned_by = 'PHOTOGRAPHER'
  order by 3;

 c1rec	c1%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);
 tmp	varchar2(10000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MODIFY_EXPIRY');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_416, style=>'NOMENU', helpid=>'A43' );
 htp.nl;
 htp.p( '<CENTER>' );
 if custype = 'CUSTOMER'
  then
   open c1(phgid,acid);
   fetch c1 into c1rec;
   close c1;
  else
   open c2(phgid,acid);
   fetch c2 into c1rec;
   close c2;
 end if;
 htp.nl;

 htp.formopen( 'adm.accept_modify_expiry' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.formhidden( 'PHGID', phgid );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'CUSTYPE', custype );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1');
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_164),cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold(c1rec.account_name),cattributes=>glbx.QUERY_CELL_BACKGROUND );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG3.ADM_TXT_063),cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( c1rec.username,cattributes=>glbx.QUERY_CELL_BACKGROUND );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.GLB_TXT_078),cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( to_char(c1rec.date_created,LNG.MASK),cattributes=>glbx.QUERY_CELL_BACKGROUND );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG3.ADM_TXT_415),cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( nvl(to_char(c1rec.date_expires,LNG.MASK),'&nbsp;'),cattributes=>glbx.QUERY_CELL_BACKGROUND );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG3.ADM_TXT_418),cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || '>' );
    htp.formselectopen( 'P1' );
    htp.formselectoption( NULL );
    for j in 1..60 loop
     htp.formselectoption( to_char( sysdate + j,LNG.MASK) );
    end loop;
    htp.formselectoption( to_char( c1rec.date_created + 30,LNG.MASK) );
    for j in 1..52 loop
     htp.formselectoption( to_char( sysdate + (j*7),LNG.MASK) );
    end loop;
    for j in 13..64 loop
     htp.formselectoption( to_char( add_months(sysdate,j),LNG.MASK) );
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  if custype <> 'CUSTOMER'
   then
    htp.formhidden( 'P2', null );
   else
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG5.EXT_TXT_573),cattributes=>glbx.QUERY_BACKGROUND );
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || '>' );
     -- List of available events
     htp.formselectopen( 'P2' );
     htp.formselectoption( NULL );
     for c3rec in c3( phgid ) loop
      if c3rec.plan_event = c1rec.plan_event
       then
        htp.formselectoption( c3rec.plan_event, 'SELECTED' );
       else
        htp.formselectoption( c3rec.plan_event );
      end if;
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
  end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Auto Receive Images via Email'),cattributes=>glbx.QUERY_BACKGROUND );
   if c1rec.receive_images_via_email = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P3', 'T', 'CHECKED' ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
    else
     htp.tabledata( htf.formcheckbox( 'P3', 'T' ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Email Account Name (File Prefix)<BR>Case Sensitive'),cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formtext( 'P4', 30, 100, c1rec.receive_image_account ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Subject Line is the Category'),cattributes=>glbx.QUERY_BACKGROUND );
   if substr(c1rec.receive_image_options,1,1) = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P6', 'T', 'CHECKED' ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
    else
     htp.tabledata( htf.formcheckbox( 'P6', 'T' ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Load into this Category (Default)'),cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || '>' );
    htp.formselectopen( 'P5' );
    for c4rec in c4( c1rec.category, phgid ) loop
     if c4rec.umo_scene_id = c1rec.receive_image_umo_scene
      then
       htp.formselectoption( lpad('.', glbx.indnt(c4rec.parent_scene),'.') || c4rec.title, 'SELECTED', cattributes=>'VALUE="' || c4rec.umo_scene_id || '"' );
      else
       htp.formselectoption( lpad('.', glbx.indnt(c4rec.parent_scene),'.') || c4rec.title, cattributes=>'VALUE="' || c4rec.umo_scene_id || '"' );
     end if;
    end loop;
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_417 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MODIFY_EXPIRY', errmsg=>sqlerrm, extdet=>null);
end modify_expiry;

procedure accept_modify_expiry( surl varchar2, phgid in integer, acid in integer, p1 in varchar2, p2 in varchar2, p3 in char default 'F', p4 in varchar2, p5 varchar2, p6 in char default 'F', custype in varchar2 )
as
 sessid	integer;
 sts	varchar2(200);
 emopt  varchar2(10);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_MODIFY_EXPIRY');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if p6 = 'T' then emopt := 'T'; else emopt := 'F'; end if;

 if custype = 'CUSTOMER'
  then
   update customer_account set date_expires = to_date(p1,LNG.MASK), plan_event = p2, receive_images_via_email = p3, receive_image_account = p4, receive_image_umo_scene = p5, receive_image_options = emopt where pid = phgid and aid = acid;
  else
   update customer_profile set date_expires = to_date(p1,LNG.MASK), receive_images_via_email = p3, receive_image_account = p4, receive_image_umo_scene = p5, receive_image_options = emopt where pid = phgid and profile_id = acid;
 end if;
 commit;
 expire_phg_cust(surl,phgid);
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_MODIFY_EXPIRY', errmsg=>sqlerrm, extdet=>null);
end accept_modify_expiry;

-- This Function is run from the ADMIN routine
function run_unload_group( nme in integer )
 return boolean
as
 res	boolean;
begin
 grouping( null, nme, TRUE );
 return( TRUE );
exception
 when others then return( FALSE );
end run_unload_group;

procedure grouping( surl varchar2, nme in integer, open_utl in boolean default true )
 as

  cursor c1(nme integer) is select * from unload_group where group_id = nme;
  cursor c2(nme_id integer) is select * from unload_group_columns where group_id = nme_id order by order_by;

  f 		utl_file.file_type;
  f1 		utl_file.file_type;
  c1rec		c1%ROWTYPE;
  sqlstmt	varchar2(32767);
  bfr		varchar2(32767);
  output_line	varchar2(32767);
  fname		varchar2(1000);
  fname1	varchar2(1000);

  cursor_name	integer;
  dummy 	integer;
  col_count	integer;
  desc_t	dbms_sql.desc_tab;
  common_nmb	number;
  common_vc2	varchar2(4000);
  common_dte	date;
  tmpval	varchar2(4000);

 begin
  open c1(nme);
  fetch c1 into c1rec;
  close c1;

  -- Run Before Query Statement
  if c1rec.before_query is not null
   then
    begin
     execute immediate replace(c1rec.before_query,'<' || c1rec.before_query_key || '>', c1rec.before_query_value )
      into c1rec.before_query_value;
     update unload_group set before_query_value = c1rec.before_query_value where group_id = nme;
     commit;
    exception
     when others then glbx.error_details( 'ADM', 'UNLOAD_DEFN', errmsg=>sqlerrm, extdet=>'BEFORE:' || nme);
    end;
  end if;

  -- Create SQL Statement
  sqlstmt := NULL;
  for c2rec in c2(c1rec.group_id) loop
   if c2rec.column_name = LNG4.AHC_TXT_432
    then
     sqlstmt := sqlstmt || ', NULL empty' || c2%ROWCOUNT;
    else
     sqlstmt := sqlstmt || ',' || nvl(c2rec.convert_func,c2rec.column_name);
   end if;
  end loop;
  sqlstmt := 'select ' || substr(sqlstmt,2) || ' from ' || c1rec.table_name;
  if c1rec.where_clause is not null
   then
    if c1rec.before_query_key is not null
     then
      sqlstmt := sqlstmt || ' where ' || replace(c1rec.where_clause,'<' || c1rec.before_query_key || '>', c1rec.before_query_value );
     else
      sqlstmt := sqlstmt || ' where ' || c1rec.where_clause;
    end if;
  end if;
  /*
 	Char - 96
  	VC2  - 1
        Nmb  - 2
        Date - 12
        Blob - 113
        Clob - 112
  */

  -- Parse SQL Statement
   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, sqlstmt, dbms_sql.native );
   dbms_sql.describe_columns(cursor_name,col_count,desc_t);
   for j in 1..col_count loop
    if desc_t(j).col_type in (1,96)
     then
      dbms_sql.define_column_char(cursor_name,j,common_vc2,desc_t(j).col_max_len);
    elsif desc_t(j).col_type = 2
     then
      dbms_sql.define_column(cursor_name,j,common_nmb);
    elsif desc_t(j).col_type = 12
     then
      dbms_sql.define_column(cursor_name,j,common_dte);
    end if;
   end loop;
   dummy := dbms_sql.execute( cursor_name );

   fname := nvl(c1rec.file_name,'file.txt');

   if c1rec.file_attach = 'T' -- If Timestamp
    then
     begin fname := glbx.extract_fname( fname, 'NO_EXTENSION' ) || to_char(sysdate,c1rec.file_attach_extra) ||
           substr(fname,length(glbx.extract_fname( fname, 'NO_EXTENSION' ))+1);
     exception
      when others then fname := nvl(c1rec.file_name,'file.txt');
     end;
   elsif c1rec.file_attach = 'Q' -- If Query
    then
     begin
      execute immediate c1rec.file_attach_extra into fname1;
      fname := glbx.extract_fname( fname, 'NO_EXTENSION' ) || fname1 || substr(fname,length(glbx.extract_fname( fname, 'NO_EXTENSION' ))+1);
     exception
      when others then fname := nvl(c1rec.file_name,'file.txt');
     end;
   end if;

   -- Check File. I - Do nothing.
   if c1rec.check_file = 'I'
    then
     null;

   -- X is do not run if file exists.
   elsif c1rec.check_file = 'X'
    then
      begin
       f := utl_file.fopen( nvl(c1rec.load_directory,glbx.extract_master_parameter('REPORTS_DIRECTORY')), fname, 'r', 32767);
       utl_file.fclose(f);
       -- File Exists. Just exit.
       return;
      exception
       when others then null;
      end;

   -- C is copy the file
   elsif c1rec.check_file = 'C'
    then
      begin
       f := utl_file.fopen( nvl(c1rec.load_directory,glbx.extract_master_parameter('REPORTS_DIRECTORY')), fname, 'r', 32767);
       f1 := utl_file.fopen( nvl(c1rec.load_directory,glbx.extract_master_parameter('REPORTS_DIRECTORY')), fname || '.bak', 'w', 32767);
       -- Copy the file
       loop
        begin
          utl_file.get_line( f, buffer=>bfr );
          utl_file.put_line( f1, buffer=>bfr );
        exception
         when others then exit;
        end;
       end loop;
       utl_file.fclose(f1);
       utl_file.fclose(f);
      exception
       when others then null;
      end;
   end if;

   if open_utl
    then
     f := utl_file.fopen( nvl(c1rec.load_directory,glbx.extract_master_parameter('REPORTS_DIRECTORY')), fname, 'w', 32767);
    else
     f := utl_file.fopen( nvl(c1rec.load_directory,glbx.extract_master_parameter('REPORTS_DIRECTORY')), fname, 'a', 32767);
   end if;

   if c1rec.format_type in ('COMMA DELIMITED','FIXED','CHARACTER SEPARATED') and c1rec.first_header = 'T'
    then
     output_line := NULL;
     for j in 1..col_count loop

      if c1rec.format_type = 'FIXED'
       then
        output_line := output_line || rpad(desc_t(j).col_name,desc_t(j).col_max_len,' ');
       else
        output_line := output_line || ',"' || desc_t(j).col_name || '"';
      end if;
     end loop;
     if c1rec.format_type = 'FIXED'
      then
       utl_file.put_line( f, buffer=>output_line );
      else
       utl_file.put_line( f, buffer=>substr(output_line,2) );
     end if;
   end if;
   if c1rec.format_type = 'XML'
    then
      utl_file.put_line( f, buffer=>'<TABLE>' || c1rec.table_name || '</TABLE>' );
   end if;

   loop
     if c1rec.format_type = 'XML'
      then
       utl_file.put_line( f, buffer=>'<REC>' );
     end if;
     dummy := dbms_sql.fetch_rows(cursor_name);

     if dummy = 0 then exit; end if;
     output_line := NULL;
     for j in 1..col_count loop
      tmpval := NULL;
      common_vc2 := NULL;
      common_nmb := NULL;
      common_dte := NULL;
      if desc_t(j).col_type in (1,96)
       then
        dbms_sql.column_value_char(cursor_name,j,common_vc2);
        tmpval := rtrim( common_vc2 );
       elsif desc_t(j).col_type = 2
        then
         dbms_sql.column_value(cursor_name,j,common_nmb);
         tmpval := to_char( common_nmb );
       elsif desc_t(j).col_type = 12
        then
         dbms_sql.column_value(cursor_name,j,common_dte);
         tmpval := to_char( common_dte,LNG3.ADM_DATE_02 );
      end if;

      if c1rec.format_type = 'XML'
       then
        utl_file.put_line( f, buffer=>'<' || desc_t(j).col_name || '>' || tmpval || '</' || desc_t(j).col_name || '>');
      elsif c1rec.format_type = 'COMMA DELIMITED'
       then
        output_line := output_line || ',' || '"' || tmpval || '"';
      elsif c1rec.format_type = 'CHARACTER SEPARATED'
       then
        output_line := output_line || chr( c1rec.format_delimiter) || tmpval;
      elsif c1rec.format_type = 'FIXED'
       then
        output_line := output_line || rpad(nvl(tmpval,' '),desc_t(j).col_max_len,' ');
      end if;

     end loop;

     if c1rec.format_type = 'XML'
      then
       utl_file.put_line( f, buffer=>'</REC>' );
      elsif c1rec.format_type in ('COMMA DELIMITED','CHARACTER SEPARATED')
       then
        utl_file.put_line( f, buffer=>substr(output_line,2) );
      elsif c1rec.format_type = 'FIXED'
       then
        utl_file.put_line( f, buffer=>output_line );
     end if;
   end loop;

   if c1rec.format_type = 'XML'
    then
      utl_file.put_line( f, buffer=>'</' || c1rec.table_name || '>' );
   end if;

   dbms_sql.close_cursor( cursor_name );
   utl_file.fclose(f);

  -- Run After Query Statements
  if c1rec.extra_update_1 is not null
   then
    begin
     execute immediate replace(c1rec.extra_update_1,'<' || c1rec.before_query_key || '>', c1rec.before_query_value );
     commit;
    exception
     when others then glbx.error_details( 'ADM', 'UNLOAD_DEFN', errmsg=>sqlerrm, extdet=>'UPDATE1:' || nme);
    end;
  end if;

  -- Run After Query Statements
  if c1rec.extra_update_2 is not null
   then
    begin
     execute immediate replace(c1rec.extra_update_2,'<' || c1rec.before_query_key || '>', c1rec.before_query_value );
     commit;
    exception
     when others then glbx.error_details( 'ADM', 'UNLOAD_DEFN', errmsg=>sqlerrm, extdet=>'UPDATE2:' || nme);
    end;
  end if;

  -- Run After Query Statements
  if c1rec.extra_update_3 is not null
   then
    begin
     execute immediate replace(c1rec.extra_update_3,'<' || c1rec.before_query_key || '>', c1rec.before_query_value );
     commit;
    exception
     when others then glbx.error_details( 'ADM', 'UNLOAD_DEFN', errmsg=>sqlerrm, extdet=>'UPDATE3:' || nme);
    end;
  end if;

exception
 when others
  then
   glbx.error_details( 'ADM', 'UNLOAD_DEFN', errmsg=>sqlerrm, extdet=>'General Exception:' || nme);
   htp.p( sqlerrm );
   begin dbms_sql.close_cursor( cursor_name ); utl_file.fclose_all; exception when others then null; end;
end grouping;

procedure unload_defn( surl varchar2,msg in varchar2 default null )
as
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.UNLOAD_DEFN');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
  htp.htmlopen;
  htp.p( '<HEAD>' );
  htp.title( glbx.extract_master_parameter('MENU_TITLE') );
  htp.p( '</HEAD>' );
  htp.framesetopen('100%','20%,80%',cattributes=>'frameborder="1" framespacing="0" border="1"');
   htp.frame( 'adm.unload_defn_leftx?surl=' || glbx.rndsurl(surl),'ADM_LEFT_WIN');
   htp.frame( 'adm.acct_unload_defn_right?surl=' || glbx.rndsurl(surl) || '&gid=0','ADM_RIGHT_WIN');
  htp.framesetclose;
  htp.p( '<BODY>' );
  htp.noframesopen;
   glbx.noframe(surl,'ADM.UNLOAD_DEFN');
  htp.noframesclose;
  htp.p( '</BODY>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'UNLOAD_DEFN', errmsg=>sqlerrm, extdet=>null);
end unload_defn;

procedure unload_defn_leftx(surl varchar2)
as
 cursor c1 is select group_name,group_id,run_every,run_period from unload_group order by group_id;
 cursor c3 is select view_name from user_views order by view_name;
 sessid	integer;
 sts	varchar2(200);
 oth	varchar2(32767);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.UNLOAD_DEFN_LEFTX');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_419, helpid=>'A44' );
 htp.p('<CENTER>');
 htp.nl;
 oth := htf.formselectopen( 'TNAME' );
 for c3rec in c3 loop
  oth := oth || htf.formselectoption( c3rec.view_name );
 end loop;
 oth := oth || htf.formselectclose;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.formopen( 'adm.acct_unload_defn_right',ctarget=>'ADM_RIGHT' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.formhidden( 'GID','0' );
  htp.tablerowopen;
   htp.tabledata( oth );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit(null,LNG3.ADM_TXT_420));
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
 htp.formclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adm.acct_unload_defn_right?surl=' || glbx.rndsurl(surl) || '&gid=' || c1rec.group_id,c1rec.group_name,ctarget=>new_window) );
   htp.p( '<TD>' );
   if c1rec.run_period is null then htp.p( LNG4.AHC_TXT_120 );
   elsif c1rec.run_period = 'H' then htp.p( LNG4.AHC_TXT_216 );
   elsif c1rec.run_period = 'D' then htp.p( LNG4.AHC_TXT_143 );
   elsif c1rec.run_period = 'W' then htp.p( LNG4.AHC_TXT_183 );
   elsif c1rec.run_period = 'M' then htp.p( LNG4.AHC_TXT_184 );
   end if;
   htp.p( ' ' || c1rec.run_every );
   htp.p( '</TD>' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'UNLOAD_DEFN_LEFTX', errmsg=>sqlerrm, extdet=>null);
end unload_defn_leftx;

procedure acct_unload_defn_right( surl varchar2,gid in integer default 0, tname in varchar2 default null, msg in varchar2 default null )
as
 cursor c1(gid integer) is select * from unload_group where group_id = gid;
 cursor c2(gid integer) is select * from unload_group_columns where group_id = gid order by order_by;
 cursor c3 is select 'XML' ftype from dual union all select 'COMMA DELIMITED' ftype from dual union all select 'FIXED' ftype  from dual union all select 'CHARACTER SEPARATED' ftype  from dual;
 cursor c4(tname varchar2) is select column_name from user_tab_columns where table_name = tname and data_type in ('CHAR','VARCHAR2','NUMBER','DATE') order by column_id;
 c1rec	c1%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);
 tmp	varchar2(20000);
 ntname varchar2(40);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCT_UNLOAD_DEFN_RIGHT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_421, style=>'NOMENU', helpid=>'A45');
 if msg is not null then glbx.header_msg( msg ); end if;
 open c1(gid);
 fetch c1 into c1rec;
 close c1;
 if gid = 0 then ntname := tname; else ntname := c1rec.table_name; end if;
 htp.p( '<CENTER>' );
 htp.tableopen;
 htp.tablerowopen;
 htp.p( '<TD>' );

 if tname is null and gid = 0 then return; end if; -- Must have specified a table name if a new plan
 htp.formopen( 'adm.accept_unload' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.formhidden( 'GID', gid );
 htp.formhidden( 'TNAME', tname );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_422 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P1',100, 100, c1rec.group_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_411 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( ntname ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_424 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P2',100, 100, c1rec.file_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_479 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     tmp := htf.formselectopen( 'P2C' );
     if c1rec.check_file = 'I' then tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_480, 'SELECTED', cattributes=>'VALUE="I"' ); else tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_480, cattributes=>'VALUE="I"' ); end if;
     if c1rec.check_file = 'X' then tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_481, 'SELECTED', cattributes=>'VALUE="X"' ); else tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_481, cattributes=>'VALUE="X"' ); end if;
     if c1rec.check_file = 'C' then tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_482, 'SELECTED', cattributes=>'VALUE="C"' ); else tmp := tmp || htf.formselectoption( LNG5.EXT_TXT_482, cattributes=>'VALUE="C"' ); end if;
     tmp := tmp || htf.formselectclose;
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_927 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     tmp := htf.formselectopen( 'P6' );
     if c1rec.file_attach = 'N' then tmp := tmp || htf.formselectoption( LNG.SLD_TXT_021, 'SELECTED', cattributes=>'VALUE="N"' ); else tmp := tmp || htf.formselectoption( LNG.SLD_TXT_021, cattributes=>'VALUE="N"' ); end if;
     if c1rec.file_attach = 'T' then tmp := tmp || htf.formselectoption( LNG4.AHC_TXT_928, 'SELECTED', cattributes=>'VALUE="T"' ); else tmp := tmp || htf.formselectoption( LNG4.AHC_TXT_928, cattributes=>'VALUE="T"' ); end if;
     if c1rec.file_attach = 'Q' then tmp := tmp || htf.formselectoption( LNG4.AHC_TXT_929, 'SELECTED', cattributes=>'VALUE="Q"' ); else tmp := tmp || htf.formselectoption( LNG4.AHC_TXT_929, cattributes=>'VALUE="Q"' ); end if;
     tmp := tmp || htf.formselectclose;
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_930 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P7',100, 4000, c1rec.file_attach_extra ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_613 ) || htf.nl || LNG4.AHC_TXT_619 || ':' || glbx.extract_master_parameter( 'REPORTS_DIRECTORY' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P2A',100, 100, c1rec.load_directory ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG2.PFM_TXT_123 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
     if c1rec.run_period is null
      then
       htp.formradio( 'RP1', 'N','CHECKED' );
      else
       htp.formradio( 'RP1', 'N' );
     end if;
     htp.p( ' ' || LNG4.AHC_TXT_120 );
     if c1rec.run_period = 'H'
      then
       htp.formradio( 'RP1', 'H','CHECKED' );
      else
       htp.formradio( 'RP1', 'H' );
     end if;
     htp.p( ' ' || LNG4.AHC_TXT_216 );
     if c1rec.run_period = 'D'
      then
       htp.formradio( 'RP1', 'D','CHECKED' );
      else
       htp.formradio( 'RP1', 'D' );
     end if;
     htp.p( ' ' || LNG4.AHC_TXT_143 );
     if c1rec.run_period = 'W'
      then
       htp.formradio( 'RP1', 'W','CHECKED' );
      else
       htp.formradio( 'RP1', 'W' );
     end if;
     htp.p( ' ' || LNG4.AHC_TXT_183 );
     if c1rec.run_period = 'M'
      then
       htp.formradio( 'RP1', 'M','CHECKED' );
      else
       htp.formradio( 'RP1', 'M' );
     end if;
     htp.p( ' ' || LNG4.AHC_TXT_184 );
     if c1rec.run_period = 'P'
      then
       htp.formradio( 'RP1', 'P','CHECKED' );
      else
       htp.formradio( 'RP1', 'P' );
     end if;
     htp.p( ' ' || 'Days Specified' ); -- xxx for language file
     htp.nl;
     htp.p( LNG4.AHC_TXT_185 || ' ' || htf.formtext( 'RP2', 20, 100, c1rec.run_every ) );
     htp.nl;
     htp.nl;
     htp.p( LNG4.AHC_TXT_190 );
     htp.nl;
     htp.p( LNG4.AHC_TXT_197 );
     htp.nl;
     -- xxx for language file
     htp.p( 'Days Specified format is like: MON,TUE,WED HH24:MI:SS Note: Only space allowed is between days and time. No other spaces.' );
     htp.p( '</TD>' );
  htp.tablerowclose;
  tmp := htf.formselectopen( 'P3' );
  for c3rec in c3 loop
   if rtrim(c3rec.ftype) = c1rec.format_type
    then
     tmp := tmp || htf.formselectoption( rtrim(c3rec.ftype), 'SELECTED' );
    else
     tmp := tmp || htf.formselectoption( rtrim(c3rec.ftype) );
   end if;
  end loop;
  tmp := tmp || htf.formselectclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_592 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">');
     htp.p( tmp );
     if c1rec.format_type = 'CHARACTER SEPARATED'
      then
       htp.formselectopen( 'P3CHAR' );
        for j in 1..255 loop
         if j > 32 and j < 160
          then
           if j = c1rec.format_delimiter
            then
             htp.formselectoption( to_char(j) || ':' || chr(j), 'SELECTED', cattributes=>'VALUE="' || to_char(j) || '"' );
            else
             htp.formselectoption( to_char(j) || ':' || chr(j), cattributes=>'VALUE="' || to_char(j) || '"' );
           end if;
          else
           if j = c1rec.format_delimiter
            then
             htp.formselectoption( to_char(j), 'SELECTED', cattributes=>'VALUE="' || to_char(j) || '"' );
            else
             htp.formselectoption( to_char(j), cattributes=>'VALUE="' || to_char(j) || '"' );
           end if;
         end if;
        end loop;
       htp.formselectclose;
     else
      htp.formhidden( 'P3CHAR', to_char(c1rec.format_delimiter));
     end if;
     htp.p( '</TD>' );
  htp.tablerowclose;
  if c1rec.first_header = 'T'
   then
    tmp := htf.formcheckbox( 'P4', 'T', 'CHECKED' );
   else
    tmp := htf.formcheckbox( 'P4', 'T' );
  end if;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_425 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( tmp ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_426 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtextareaopen('P5',5, 100, cattributes=>'WRAP="VIRTUAL"' ) || replace(replace(c1rec.where_clause,'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_981 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtextareaopen('P9A',3, 100, cattributes=>'WRAP="VIRTUAL"' ) || replace(replace(c1rec.before_query,'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_982 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P9B',30, 100, c1rec.before_query_key),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_987 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold(nvl(c1rec.before_query_value,'&nbsp;')),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( '1.' || LNG4.AHC_TXT_980 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtextareaopen('P8A',3, 100, cattributes=>'WRAP="VIRTUAL"' ) || replace(replace(c1rec.extra_update_1,'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( '2.' || LNG4.AHC_TXT_980 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtextareaopen('P8B',3, 100, cattributes=>'WRAP="VIRTUAL"' ) || replace(replace(c1rec.extra_update_2,'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( '3.' || LNG4.AHC_TXT_980 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtextareaopen('P8C',3, 100, cattributes=>'WRAP="VIRTUAL"' ) || replace(replace(c1rec.extra_update_3,'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_427 );
 htp.tableopen;
 htp.tablerowopen;
  htp.tableheader( LNG3.ADM_TXT_317 );
  htp.tableheader( LNG3.ADM_TXT_429 );
 htp.tablerowclose;
 for c2rec in c2(gid) loop
  htp.tablerowopen;
   tmp := htf.formselectopen( 'CP1' ) || htf.formselectoption( NULL );
   if c2rec.column_name = LNG4.AHC_TXT_432
    then
      tmp := tmp || htf.formselectoption( LNG4.AHC_TXT_432, 'SELECTED' );
    else
      tmp := tmp || htf.formselectoption( LNG4.AHC_TXT_432 );
   end if;
   for c4rec in c4(ntname) loop
    if c4rec.column_name = c2rec.column_name
     then
      tmp := tmp || htf.formselectoption( c4rec.column_name, 'SELECTED' );
     else
      tmp := tmp || htf.formselectoption( c4rec.column_name);
    end if;
   end loop;
   tmp := tmp || htf.formselectclose;
   htp.tabledata( tmp );
   htp.tabledata( htf.formtext('CP2',10,20,c2rec.order_by ));
  htp.tablerowclose;
 end loop;
 tmp := htf.formselectopen( 'CP1' ) || htf.formselectoption( NULL ) || htf.formselectoption( LNG4.AHC_TXT_432 );
  for c4rec in c4(ntname) loop
    tmp := tmp || htf.formselectoption( c4rec.column_name);
  end loop;
 tmp := tmp || htf.formselectclose;
 for j in 1..5 loop
  htp.tablerowopen;
  htp.tabledata( tmp );
  htp.tabledata( htf.formtext('CP2',10,20,null ));
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION',LNG3.ADM_TXT_430 );
 if gid <> 0 then htp.formsubmit( 'ACTION',LNG3.ADM_TXT_431 ); end if;
 if gid <> 0 then htp.formsubmit( 'ACTION',LNG3.ADM_TXT_432 ); end if;
 htp.formclose;

 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ACCT_UNLOAD_DEFN_RIGHT', errmsg=>sqlerrm, extdet=>null);
end acct_unload_defn_right;

procedure accept_unload(surl varchar2, gid in integer, tname in varchar2 default null, p1 in varchar2, p2 in varchar2, p2c in varchar2, p2a in varchar2, p3 in varchar2, p4 in varchar2 default 'F', p5 in varchar2, p6 in varchar2, p7 in varchar2,
                        p8a in varchar2, p8b in varchar2, p8c in varchar2, p9a in varchar2, p9b in varchar2, p3char in char, rp1 in varchar2, rp2 in varchar2, action in varchar2, cp1 in MYARRAY, cp2 in MYARRAY )
as

 cursor c1 is select max(group_id) from unload_group;

 sessid	integer;
 sts	varchar2(200);
 lp5	varchar2(4000);
 lp8a	varchar2(4000);
 lp8b	varchar2(4000);
 lp8c	varchar2(4000);
 lp9a	varchar2(4000);
 grpid	integer;
 nmb	integer;
 rp	char(1);
 re	varchar2(100);
 tdate	date;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_UNLOAD');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if gid <> 0 and action = LNG3.ADM_TXT_431
  then
   delete from unload_group_columns where group_id = gid;
   delete from unload_group where group_id = gid;
   commit;
   acct_unload_defn_right(surl,0,null,LNG3.ADM_TXT_433);
   return;
 end if;

 rp := rp1;
 if rp = 'N' then rp := NULL; end if;
 if rp is null
  then
   re := NULL;
  else
   if rp = 'H'
    then
     begin tdate := to_date( '01-JAN-2000 00:' || rp2, 'DD-MON-YYYY HH24:MI' ); re := rp2; exception when others then re := NULL; end;
   elsif rp = 'D'
    then
     begin tdate := to_date( '01-JAN-2000 ' || rp2, 'DD-MON-YYYY HH24:MI' ); re := rp2; exception when others then re := NULL; end;
   elsif rp = 'W'
    then
     begin tdate := to_date( rp2, 'DY HH24:MI' ); re := rp2; exception when others then re := NULL; end;
   elsif rp = 'M'
    then
     begin tdate := to_date( rp2, 'DD HH24:MI' ); re := rp2; exception when others then re := NULL; end;
   elsif rp = 'P'
    then
     re := rp2;
   end if;
 end if;
 lp5 := substr(p5,1,4000);
 lp8a := substr(p8a,1,4000);
 lp8b := substr(p8b,1,4000);
 lp8c := substr(p8c,1,4000);
 lp9a := substr(p9a,1,4000);
 if gid = 0
  then
   open c1;
   fetch c1 into grpid;
   close c1;
   grpid := nvl(grpid,0) + 1;
   insert into unload_group(group_id,group_name,file_name,format_type,first_header,table_name,where_clause,run_period,run_every,load_directory,file_attach,file_attach_extra,extra_update_1,extra_update_2,extra_update_3,before_query,before_query_key,format_delimiter,check_file) values
    (grpid,nvl(p1,LNG3.ADM_TXT_351),nvl(p2,'file.txt'),p3,p4,tname,lp5,rp,re,p2a,p6,p7,lp8a,lp8b,lp8c,lp9a,replace(replace(upper(p9b),'<',''),'>',''),p3char,p2c);
  else
   update unload_group
    set
     group_name = nvl(p1,LNG3.ADM_TXT_351),
     file_name = nvl(p2,'file.txt'),
     format_type = p3,
     first_header = p4,
     where_clause = lp5,
     run_period = rp,
     run_every = re,
     load_directory = p2a,
     file_attach = p6,
     file_attach_extra = p7,
     extra_update_1 = lp8a,
     extra_update_2 = lp8b,
     extra_update_3 = lp8c,
     before_query = lp9a,
     before_query_key = replace(replace(upper(p9b),'<',''),'>',''),
     format_delimiter = p3char,
     check_file = p2c
   where group_id = gid;
   delete from unload_group_columns where group_id = gid;
   grpid := gid;
 end if;
 for j in cp1.first..cp1.last loop
  if cp1(j) is not null
   then
    begin nmb := to_number(cp2(j)); exception when others then nmb := 999; end;
    nmb := nvl(nmb,999);
    insert into unload_group_columns(group_id,column_name,order_by,convert_func) values
     (grpid,cp1(j),nmb,null);
  end if;
 end loop;
 commit;

 if (gid <> 0) and (action = LNG3.ADM_TXT_432)
  then
   grouping( surl, gid );
   acct_unload_defn_right(surl,gid,null,LNG3.ADM_TXT_434);
   return;
 end if;

 acct_unload_defn_right(surl,grpid,msg=>LNG3.ADM_TXT_435);
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_UNLOAD', errmsg=>sqlerrm, extdet=>null);
end accept_unload;

procedure xml_unload(surl varchar2, typ in varchar2, p1 in varchar2, p2 in varchar2 )
as
 cursor c1(tname varchar2) is select column_name,column_id from user_tab_columns where table_name = tname order by column_id;
 sessid	integer;
 sts	varchar2(200);
 tname	varchar2(40);
 wclause varchar2(1000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.XML_UNLOAD');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if typ = 'FTR'
  then
   tname := 'THEME_TYPES';
   wclause := 'theme_type = ''' || p1 || '''';
 elsif typ = 'LAF'
  then
   tname := 'THEME';
   wclause := 'theme_name = ''' || p1 || '''';
 elsif typ = 'SCN'
  then
   tname := 'SCENE';
   wclause := 'scene_name = ''' || p1 || '''';
 elsif typ = 'RDF'
  then
   tname := 'REPORT_DEFINITION';
   wclause := 'report_id = ''' || p1 || '''';
 end if;
 delete from unload_group where group_id = 0;
 delete from unload_group_columns where group_id = 0;
 insert into unload_group(group_id,group_name,file_name,format_type,first_header,table_name,where_clause) values
  (0,'TEMP1',p2,'XML','F',tname,wclause);
 for c1rec in c1(tname) loop
  insert into unload_group_columns(group_id,column_name,order_by) values
   (0,c1rec.column_name,c1rec.column_id);
 end loop;
 if typ = 'SCN'
  then
   grouping( surl, 0, TRUE );
   tname := 'UMO_SCENE';
   wclause := 'owned_by = ''PUBLIC'' and category = ''' || p1 || '''';
   delete from unload_group where group_id = 0;
   delete from unload_group_columns where group_id = 0;
   insert into unload_group(group_id,group_name,file_name,format_type,first_header,table_name,where_clause) values
    (0,'TEMP1',p2,'XML','F',tname,wclause);
   for c1rec in c1(tname) loop
    insert into unload_group_columns(group_id,column_name,order_by) values
     (0,c1rec.column_name,c1rec.column_id);
   end loop;
   grouping( surl, 0, FALSE );
 elsif typ = 'RDF'
  then
   grouping( surl, 0, TRUE );
   tname := 'REPORT_PARAMETERS';
   wclause := 'report_id = ''' || p1 || '''';
   delete from unload_group where group_id = 0;
   delete from unload_group_columns where group_id = 0;
   insert into unload_group(group_id,group_name,file_name,format_type,first_header,table_name,where_clause) values
    (0,'TEMP1',p2,'XML','F',tname,wclause);
   for c1rec in c1(tname) loop
    insert into unload_group_columns(group_id,column_name,order_by) values
     (0,c1rec.column_name,c1rec.column_id);
   end loop;
   grouping( surl, 0, FALSE );
  else
   grouping( surl, 0 );
 end if;
 rollback;
 main_title( surl, sessid, LNG3.ADM_TXT_436 || ': ' || p2, style=>'NOMENU' );
 htp.nl;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'XML_UNLOAD', errmsg=>sqlerrm, extdet=>null);
end xml_unload;

procedure xml_load( surl varchar2, vdir in varchar2, filename varchar2, delete_exists in boolean default TRUE, retval out varchar2, ignore_parent in boolean default FALSE )
as

    cursor c1(tkval varchar2) is select 'x' from theme_types where theme_type = tkval;
    cursor c2(tkval varchar2) is select 'x' from theme where theme_name = tkval;
    cursor c3(tkval varchar2) is select 'x' from scene where scene_name = tkval;
    cursor c4(tname varchar2, cname varchar2 ) is select count('x') tot from user_tab_columns where table_name = tname and column_name = upper(cname);
    cursor c5(tkval varchar2) is select 'x' from report_definition where report_name = tkval;
    cursor c6(tkval varchar2) is select report_id from report_definition where report_name = tkval;

    RECORD_TAG  constant varchar2(10) := 'REC';
    TABLE_TAG   constant varchar2(10) := 'TABLE';
    c4rec	c4%ROWTYPE;
    f 		utl_file.file_type;
    curline 	varchar2(32767);
    tknm	varchar2(100);
    tkval	varchar2(32767);
    loc1	integer;
    loc2	integer;
    idval	integer;
    tmp		char(1);
    tname	varchar2(40);
    rname	varchar2(100);
    ins_stmt1   varchar2(32767);
    ins_stmt2   varchar2(32767);

 begin
    begin
      f := utl_file.fopen( vdir, filename, 'r', 32767);
    exception
     when others then
      htp.htmlopen;
      htp.bold('Error opening file' );
      htp.nl;
      htp.nl;
      htp.bold( sqlerrm );
      htp.htmlclose;
      return;
    end;
    -- If requested skip the first table to upload the child table
    if ignore_parent
     then
      utl_file.get_line( f, curline ); -- Skip the first record of the load
      loop
       begin
        utl_file.get_line( f, curline );
        if substr(curline,1,7) = '<TABLE>'
         then
          exit;
        end if;
       exception
        when no_data_found
         then
           utl_file.fclose(f);
           return;
       end;
      end loop;
    end if;

    if not ignore_parent then utl_file.get_line( f, curline ); end if;
    loop
     begin
        curline := rtrim( curline );
        curline := ltrim( curline );
        if upper(curline) = '<' || RECORD_TAG || '>'
         then
          ins_stmt1 := null;
          ins_stmt2 := null;
        elsif upper(curline) = '</' || RECORD_TAG || '>'
         then
          ins_stmt1 := 'insert into ' || tname || '(' || substr(ins_stmt1,2) || ') values (' || substr(ins_stmt2,2) || ')';
          -- htp.nl; htp.p( ins_stmt1 ); htp.nl;
          execute immediate ins_stmt1;
          ins_stmt1 := NULL;
          ins_stmt2 := NULL;
          if tname = 'SCENE'
           then
            utl_file.fclose(f);
            xml_load(surl,vdir,filename,delete_exists,retval,TRUE);
            return;
          end if;
        else
          loc1 := instr( curline, '>', 1, 1 );
          tknm := substr(curline,2,loc1-2 );
          loc2 := instr( curline, '</' || tknm || '>', 1, 1 );
          tkval := substr( curline, loc1 + 1, (loc2 - loc1)-1);
          if tknm = TABLE_TAG
           then
            tname := tkval;
           else
            if tname = 'THEME_TYPES' and tknm = 'THEME_TYPE'
             then
              open c1(tkval);
              fetch c1 into tmp;
              if c1%FOUND and delete_exists
               then
                delete from theme_types where theme_type = tkval;
               elsif not delete_exists
                then
                 close c1;
                 retval := tname || ' ' || tkval;
                 return;
              end if;
              close c1;
            elsif tname = 'THEME' and tknm = 'THEME_NAME'
             then
              open c2(tkval);
              fetch c2 into tmp;
              if c2%FOUND and delete_exists
               then
                delete from theme where theme_name = tkval;
               elsif not delete_exists
                then
                 close c2;
                 retval := tname || ' ' || tkval;
                 return;
              end if;
              close c2;
            elsif tname = 'SCENE' and tknm = 'SCENE_NAME'
             then
              open c3(tkval);
              fetch c3 into tmp;
              if c3%FOUND and delete_exists
               then
                delete from scene where scene_name = tkval;
                delete from umo_scene where category = tkval;
               elsif not delete_exists
                then
                 close c3;
                 retval := tname || ' ' || tkval;
                 return;
              end if;
              close c3;
            elsif tname = 'REPORT_DEFINITION' and tknm = 'REPORT_NAME'
             then
              rname := tkval;
              open c5(tkval);
              fetch c5 into tmp;
              if c5%FOUND and delete_exists
               then
                delete from report_definition where report_name = tkval;
                delete from report_parameters where report_id = (select report_id from report_definition where report_name = tkval);
               elsif not delete_exists
                then
                 close c5;
                 retval := tname || ' ' || tkval;
                 return;
              end if;
              close c5;
            end if;
            if tname = 'UMO_SCENE' and tknm = 'UMO_SCENE_ID'
             then
              ins_stmt1 := ins_stmt1 || ',' || tknm;
              ins_stmt2 := ins_stmt2 || ',' || 's_umo_scene.nextval';
            elsif tname = 'REPORT_DEFINITION' and tknm = 'REPORT_ID'
             then
              ins_stmt1 := ins_stmt1 || ',' || tknm;
              ins_stmt2 := ins_stmt2 || ',' || 's_report_definition.nextval';
            elsif tname = 'REPORT_PARAMETERS' and tknm = 'REPORT_ID'
             then
              open c6(rname);
              fetch c6 into idval;
              close c6;
              ins_stmt1 := ins_stmt1 || ',' || tknm;
              ins_stmt2 := ins_stmt2 || ',' || to_char(idval);
            elsif tname = 'THEME'
             then
              c4rec.tot := 0;
              open c4('THEME',tknm); -- Validate column name. Only add it if it exists in the database. Ensures backwards compatibility
              fetch c4 into c4rec;
              close c4;
              if c4rec.tot > 0
               then
                ins_stmt1 := ins_stmt1 || ',' || tknm;
                ins_stmt2 := ins_stmt2 || ',' || '''' || replace(tkval,'''','''''') || '''';
              end if;
             else
              ins_stmt1 := ins_stmt1 || ',' || tknm;
              ins_stmt2 := ins_stmt2 || ',' || '''' || replace(tkval,'''','''''') || '''';
            end if;
        end if;
      end if;
      utl_file.get_line( f, curline );
     exception
      when no_data_found then
           utl_file.fclose(f);
           return;
      when value_error then
           utl_file.fclose(f);
           htp.p ( LNG3.ADM_TXT_437 || ': ' || sqlerrm || ':' || tname || ':' || ins_stmt1 || '-' || ins_stmt2 );
           return;
      when others then
           utl_file.fclose(f);
           htp.p ( LNG3.ADM_TXT_438 || ': ' || sqlerrm || ':' || tname || ':' || ins_stmt1 || '-' || ins_stmt2 );
           return;
     end;
    end loop;
    commit;
    retval := NULL;
  exception
    when others
     then
      retval := ins_stmt1 || ':' || sqlerrm;
      utl_file.fclose(f);
 end xml_load;

procedure accept_upload_defn(surl varchar2, p1 in varchar2, p2 in varchar2 default 'F', p3 in varchar2 default 'F', p4 in varchar2)
as

 sessid	integer;
 sts	varchar2(200);
 retval varchar2(1000);
 vdir	varchar2(1000);

begin
 -- P1 - File Name
 -- P2 - Replace if Exists
 -- P3 - Confirm before replacing
 -- vdir
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_UPLOAD_DEFN');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 vdir := nvl(p4,glbx.extract_master_parameter('REPORTS_DIRECTORY'));

 if p2 = 'T'
  then
   xml_load(surl,vdir,p1,TRUE,retval);
  else
   xml_load(surl,vdir,p1,FALSE,retval);
   if retval is not null
    then
     if p3 = 'T'
      then
       main_title( surl, sessid, LNG3.ADM_TXT_444, helpid=>'A104' );
       htp.nl;
       htp.nl;
       htp.formopen( 'adm.accept_upload_defn' );
        htp.formhidden( 'SURL',  glbx.rndsurl(surl));
        htp.formhidden( 'P1', p1 );
        htp.formhidden( 'P2', 'T' );
        htp.formhidden( 'P3', 'F' );
        htp.nl;
        htp.formsubmit( null, LNG3.ADM_TXT_445);
        htp.nl;
       htp.formclose;
       htp.htmlclose;
       return;
      else
       xml_load(surl,vdir,p1,TRUE,retval);
     end if;
   end if;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_446, helpid=>'A104' );
 htp.nl;
 htp.nl;
 htp.nl;
 htp.p( retval );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_UPLOAD_DEFN', errmsg=>sqlerrm, extdet=>null);
end accept_upload_defn;

procedure accept_mod_phg(surl varchar2, phid integer, p1 in varchar2, p2 in varchar2, p3 in varchar2 default 'F', p3a in varchar2 default 'F' )
as

 dt	date;
 dt2	date;
 sessid	integer;
 sts	varchar2(200);
 tmp	varchar2(2000);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_MOD_PHG');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 begin dt := to_date(p1,LNG3.ADM_DATE_02); exception when others then phg_account(surl,phid,LNG3.ADM_TXT_453 || p1); return; end;
 begin dt2 := to_date(p2,LNG3.ADM_DATE_02); exception when others then phg_account(surl,phid,LNG3.ADM_TXT_453 || p2 ); return; end;
 update photographer set date_expires = dt, renewal_sent_on = dt2,account_enabled = p3,disable_acct_expired=p3a where pid = phid;
 commit;
 phg_account(surl,phid,LNG3.ADM_TXT_454 );
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_MOD_PHG', errmsg=>sqlerrm, extdet=>null);
end accept_mod_phg;

procedure accept_mod_phg2( surl varchar2,phid integer, p1 in varchar2, p2 in varchar2, p3 in varchar2 )
as

 dt	date;
 nmb	number;
 sessid	integer;
 sts	varchar2(200);
 tmp	varchar2(2000);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_MOD_PHG2');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 begin dt := to_date(p1,LNG3.ADM_DATE_02); exception when others then phg_account(surl,phid,LNG3.ADM_TXT_453); return; end;
 begin
  nmb := to_number(p2,LNG.MONEY_FORMAT);
  exception when others then
   begin
    nmb := to_number(p2,LNG3.ADM_DATE_03);
   exception
    when others then phg_account(surl,phid,LNG3.ADM_TXT_455); return; end;
 end;
 insert into photographer_payment(pid,date_paid,amount_paid,comments) values (phid,dt,nmb,p3);
 commit;
 phg_account(surl,phid, LNG3.ADM_TXT_454 );
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_MOD_PHG2', errmsg=>sqlerrm, extdet=>null);
end accept_mod_phg2;

procedure phg_account( surl varchar2, phid integer, msg in varchar2 )
as

 cursor c1( phid integer ) is select * from photographer where pid = phid;
 cursor c2( phid integer ) is select * from photographer_payment where pid = phid order by date_paid desc;
 cursor c3( phid integer ) is select * from photographer_renewal_history where pid = phid order by date_renewal_sent desc;
 cursor c4( plid integer ) is select * from charge_plan where id = plid;
 cursor c5( plid integer ) is select * from charge_plan_event where plan_id = plid order by plan_event;
 cursor c6( plid integer, phgid integer ) is select * from charge_plan_event_phg where plan_id = plid and pid = phgid;
 cursor c7( plid integer, ev varchar2 ) is select * from charge_plan_event where plan_id = plid and plan_event = ev;
 cursor c8( phgid integer, cevent varchar2, plid integer) is select count('x') tot from customer_account where pid = phgid and plan_id = plid and plan_event = cevent;
 cursor c9( phgid integer ) is select count('x') tot from charge_plan_invoice where pid = phgid;
 cursor c10( phgid integer ) is select * from charge_plan_invoice where pid = phgid order by date_purchased desc;

 c1rec		c1%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c9rec		c9%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 tmp		varchar2(2000);
 foundrec	boolean;
 tot		integer;
 totout		number;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.PHG_ACCOUNT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_456, style=>'NOMENU', helpid=>'A48' );
 htp.nl;
 if msg is not null then glbx.header_msg( msg ); end if;
 open c1( phid );
 fetch c1 into c1rec;
 close c1;
 htp.formopen( 'adm.accept_mod_phg' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.formhidden( 'PHID', phid );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( LNG3.ADM_TXT_457 );
   if c1rec.account_enabled = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P3','T','CHECKED'));
    else
     htp.tabledata( htf.formcheckbox( 'P3','T'));
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( LNG.CST_TXT_004 );
   htp.tabledata( c1rec.business_name );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( LNG.GLB_TXT_076 );
   htp.tabledata( c1rec.username );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( LNG3.ADM_TXT_458 );
   htp.tabledata( htf.formtext( 'P1', 20, 20, to_char(c1rec.date_expires,LNG3.ADM_DATE_02) ) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( LNG4.AHC_TXT_854 );
   if c1rec.disable_acct_expired = 'T'
    then
     htp.tabledata( htf.formcheckbox( 'P3A','T','CHECKED'));
    else
     htp.tabledata( htf.formcheckbox( 'P3A','T'));
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( LNG3.ADM_TXT_459 );
   htp.tabledata( htf.formtext( 'P2', 20, 20, to_char(c1rec.renewal_sent_on,LNG3.ADM_DATE_02) ) );
  htp.tablerowclose;
  if c1rec.date_expires is not null
   then
    htp.tablerowopen;
     htp.tabledata( LNG3.ADM_TXT_460 );
     if c1rec.renewal_acknowledged = 'T'
      then
        htp.tabledata( LNG.PHG_TXT_045 );
      else
        htp.tabledata( LNG.PHG_TXT_046 );
     end if;
    htp.tablerowclose;
  end if;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_461 );
 htp.formclose;

 open c4(c1rec.plan_id);
 fetch c4 into c4rec;
 close c4;
 if c4rec.payment_style = 'EVENT'
  then
   htp.formopen( 'adm.accept_charge_event' );
   htp.formhidden ( 'SURL', surl );
   htp.formhidden ( 'PHID', phid );
   htp.nl;
   htp.bold( LNG3.ADM_TXT_786 );
   htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( LNG3.ADM_TXT_787 );
     htp.tabledata( LNG.LAB_TXT_039 );
     htp.tabledata( LNG3.ADM_TXT_788 );
     htp.tabledata( LNG.PHG_ALT_399 );
     htp.tabledata( LNG3.ADM_TXT_791 );
    htp.tablerowclose;
   for c6rec in c6(c1rec.plan_id,phid) loop
    htp.tablerowopen;
     htp.p( '<TD>' );
     htp.formselectopen( 'EV1' );
     htp.formselectoption( NULL );
     for c5rec in c5(c1rec.plan_id) loop
      if c5rec.plan_event = c6rec.plan_event
       then
        htp.formselectoption( c5rec.plan_event, 'SELECTED' );
       else
        htp.formselectoption( c5rec.plan_event );
      end if;
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
     htp.tabledata( htf.formtext( 'EV2', 10, 20, c6rec.qty), cattributes=>'align="CENTER"' );
     open c7(c1rec.plan_id,c6rec.plan_event);
     fetch c7 into c7rec;
     close c7;
     htp.tabledata( c7rec.images_max );
     htp.tabledata( to_char(c7rec.standard_charge,LNG.MONEY_FORMAT) );
     tot := 0;
     open c8( phid,c6rec.plan_event,c1rec.plan_id);
     fetch c8 into tot;
     close c8;
     htp.tabledata( tot );
    htp.tablerowclose;
   end loop;
   for j in 1..5 loop
    htp.tablerowopen;
     htp.p( '<TD>' );
     htp.formselectopen( 'EV1' );
     htp.formselectoption( NULL );
     for c5rec in c5(c1rec.plan_id) loop
      htp.formselectoption( c5rec.plan_event );
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
     htp.tabledata( htf.formtext( 'EV2', 10, 20), cattributes=>'align="CENTER"' );
     htp.tabledata( '&nbsp;' );
     htp.tabledata( '&nbsp;' );
     htp.tabledata( '&nbsp;' );
    htp.tablerowclose;
   end loop;
  htp.tableclose;
  htp.nl;
   htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( LNG3.ADM_TXT_792 );
     htp.tabledata( htf.formtext( 'OPT1A',20,30,c1rec.charge_option1_discount) );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( LNG3.ADM_TXT_793 );
     htp.tabledata( htf.formtext( 'OPT1B',20,30,c1rec.charge_option1_royalty) );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( LNG3.ADM_TXT_794 );
     htp.tabledata( htf.formtext( 'OPT2A',20,30,c1rec.charge_option2_discount) );
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
  htp.formsubmit(null,LNG3.ADM_TXT_789);
  htp.formclose;
 end if;

 htp.nl;
 htp.bold( LNG3.ADM_TXT_462 );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( LNG3.ADM_TXT_463 );
   htp.tabledata( LNG3.ADM_TXT_464 );
   htp.tabledata( LNG.CST_TXT_051 );
  htp.tablerowclose;
  foundrec := FALSE;
  for c2rec in c2(phid) loop
   htp.tablerowopen;
   foundrec := TRUE;
   htp.tabledata( to_char(c2rec.date_paid,LNG.MASK) );
   htp.tabledata( to_char(c2rec.amount_paid,LNG.MONEY_FORMAT) );
   htp.tabledata( c2rec.comments );
  htp.tablerowclose;
  end loop;
 htp.tableclose;
 if not foundrec then htp.bold( LNG3.ADM_TXT_465 ); htp.nl; end if;
 htp.nl;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_466 );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( LNG3.ADM_TXT_467 );
  htp.tablerowclose;
  foundrec := FALSE;
  for c3rec in c3(phid) loop
   htp.tablerowopen;
   foundrec := TRUE;
   htp.tabledata( to_char(c3rec.date_renewal_sent,LNG.MASK) );
  htp.tablerowclose;
  end loop;
 htp.tableclose;
 if not foundrec then htp.bold( LNG3.ADM_TXT_468 ); htp.nl; end if;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_469 );
 htp.nl;
 htp.formopen( 'adm.accept_mod_phg2' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.formhidden( 'PHID', phid );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( LNG3.ADM_TXT_470 );
   htp.tabledata( htf.formtext( 'P1',20,20,to_char(sysdate,LNG3.ADM_DATE_02)));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( LNG3.ADM_TXT_471 );
   htp.tabledata( htf.formtext( 'P2',20,20));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( LNG.CST_TXT_051 );
   htp.tabledata( htf.formtext( 'P3',40,4000));
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit(null, LNG3.ADM_TXT_472 );
 htp.formclose;
 htp.nl;

 -- Look for Photographer Produced Invoices
 if c4rec.payment_style = 'EVENT'
  then
   htp.line;
   htp.nl;
   open c9( phid );
   fetch c9 into c9rec;
   close c9;
   if c9rec.tot = 0
    then
     htp.bold( LNG4.AHC_TXT_549 );
    else
     htp.bold( LNG4.AHC_TXT_550 );
     htp.nl;
     htp.formopen( 'adm.modify_charge_event' );
     htp.formhidden( 'SURL',  glbx.rndsurl(surl));
     htp.formhidden( 'PHID', phid );
     htp.formhidden( 'P1', null );
     htp.formhidden( 'P2', null );
     htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.PHG_TXT_083) );
       htp.tabledata( htf.bold(LNG.ORD_TXT_197) );
       htp.tabledata( htf.bold(LNG3.ADM_TXT_787) );
       htp.tabledata( htf.bold(LNG4.AHC_TXT_552) );
       htp.tabledata( htf.bold(LNG4.AHC_TXT_553) );
       htp.tabledata( htf.bold(LNG.ORD_TXT_145) );
      htp.tablerowclose;
      totout := 0;
      for c10rec in c10( phid ) loop
       htp.tablerowopen;
        htp.tabledata( to_char( c10rec.date_purchased, LNG.TSMASK) );
        htp.tabledata( c10rec.invoice_id );
        htp.tabledata( c10rec.plan_event );
        htp.tabledata( c10rec.qty || htf.nl || to_char(c10rec.standard_charge,LNG.MONEY_FORMAT) || htf.nl || to_char(c10rec.qty*c10rec.standard_charge,LNG.MONEY_FORMAT) );
        htp.p( '<TD>' );
        if c10rec.invoice_sent = 'F'
         then
          htp.formcheckbox( 'P1', c10rec.invoice_id );
         else
          htp.formcheckbox( 'P1', c10rec.invoice_id, 'CHECKED' );
          htp.italic( ' ' || to_char(c10rec.invoice_sent_dt, LNG.TSMASK) );
        end if;
        htp.p( '</TD>' );
        htp.p( '<TD>' );
        if c10rec.invoice_rec = 'F'
         then
          htp.formcheckbox( 'P2', c10rec.invoice_id );
          totout := totout + (c10rec.qty*c10rec.standard_charge);
         else
          htp.formcheckbox( 'P2', c10rec.invoice_id, 'CHECKED' );
          htp.italic( ' ' || to_char(c10rec.invoice_rec_dt,LNG.TSMASK) );
        end if;
        htp.p( '</TD>' );
       htp.tablerowclose;
      end loop;
     htp.tableclose;
     htp.nl;
     htp.formsubmit( null, LNG4.AHC_TXT_551 );
     htp.formclose;
     if totout > 0
      then
       htp.nl;
       htp.bold( LNG4.AHC_TXT_554 || ' ' || to_char(totout,LNG.MONEY_FORMAT) );
       htp.nl;
     end if;
   end if;
 end if;

 htp.line;
 htp.nl;
 htp.bold( LNG.PHG_TXT_352 );
 htp.nl;
 htp.nl;
 htp.formopen( 'adm.send_renewal' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.formhidden( 'PHID', phid );
 htp.formsubmit( null, LNG3.ADM_TXT_474 );
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'PHG_ACCOUNT', errmsg=>sqlerrm, extdet=>null);
end phg_account;

procedure modify_charge_event( surl in varchar2, phid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 sessid		integer;
 sts		varchar2(200);
 tmp		varchar2(2000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'MODIFY_CHARGE_EVENT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 update charge_plan_invoice
  set
   invoice_sent = 'F'
 where pid = phid;
 for j in p1.first..p1.last loop
  if p1(j) is not null
   then
    update charge_plan_invoice
     set
      invoice_sent = 'T',
      invoice_sent_dt = nvl(invoice_sent_dt,sysdate)
    where
     pid = phid and
     invoice_id = p1(j);
  end if;
 end loop;

 update charge_plan_invoice
  set
   invoice_rec = 'F'
 where pid = phid;
 for j in p2.first..p2.last loop
  if p2(j) is not null
   then
    update charge_plan_invoice
     set
      invoice_rec = 'T',
      invoice_rec_dt = nvl(invoice_rec_dt,sysdate)
    where
     pid = phid and
     invoice_id = p2(j);
  end if;
 end loop;
 commit;

 phg_account(surl,phid,LNG4.AHC_TXT_555);

exception when others then
 glbx.error_details( 'ADM', 'MODIFY_CHARGE_EVENT', errmsg=>sqlerrm, extdet=>null);
end modify_charge_event;

procedure list_outstanding_invoices( surl in varchar2 )
as

 cursor c1 is
  select business_name,plan_event,qty,p.pid,date_purchased,invoice_sent,invoice_sent_dt,invoice_id,standard_charge
  from charge_plan_invoice  cpi, photographer p
  where invoice_rec = 'F' and
        p.pid = cpi.pid
  order by business_name, date_purchased;

 sessid		integer;
 sts		varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'LIST_OUTSTANDING_INVOICES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG4.AHC_TXT_556, style=>'NOMENU' );
 htp.nl;
 htp.p('<CENTER>');
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_261 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG3.ADM_TXT_787 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG.ORD_TXT_197 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG4.AHC_TXT_552 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG4.AHC_TXT_553 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;
  for c1rec in c1 loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'adm.mng_photographer?surl=' || surl || '&phgid=' || c1rec.pid,c1rec.business_name),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( c1rec.plan_event,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( c1rec.invoice_id || htf.nl || htf.italic( c1rec.date_purchased,LNG.TSMASK),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( c1rec.qty || htf.nl || to_char(c1rec.standard_charge,LNG.MONEY_FORMAT) || htf.nl  || to_char(c1rec.qty * c1rec.standard_charge,LNG.MONEY_FORMAT),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
    if c1rec.invoice_sent = 'F'
     then
      htp.tabledata( LNG.PHG_TXT_046,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
     else
      htp.tabledata( LNG.PHG_TXT_045 || htf.nl || to_char(c1rec.invoice_sent_dt,LNG.TSMASK),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
    end if;
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'LIST_OUTSTANDING_INVOICES', errmsg=>sqlerrm, extdet=>null);
end list_outstanding_invoices;

procedure send_renewal( surl varchar2, phid integer )
as

 cursor c1(phid integer) is select * from photographer where pid = phid;
 cursor c2(plid integer) is select * from charge_plan where id = plid;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.SEND_RENEWAL');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 open c1(phid);
 fetch c1 into c1rec;
 close c1;
 open c2(c1rec.plan_id);
 fetch c2 into c2rec;
 close c2;
 gcode(1) := 'PHOTOGRAPHER_NAME';
 gparam(1) := c1rec.business_name;
 gcode(2) := 'RENEWAL_DATE';
 gparam(2) := to_char(c1rec.date_expires);
 gcode(3) := 'RENEWAL_CHARGE';
 gparam(3) := c2rec.plan_cost;
 gcode(4) := 'SIGNATURE';
 gparam(4) := glbx.extract_master_parameter('MAIL SIGNATURE');

 glbx.send( gcode, gparam, 'renewal_reminder.tmp', c1rec.contact_email, LNG3.ADM_TXT_475, glbx.extract_master_parameter('MAIL_FROM'), scode=>'RR1', v_pid=>c1rec.pid);

 insert into photographer_renewal_history(pid,date_renewal_sent) values (phid,sysdate);
 commit;
 phg_account(surl,phid,LNG3.ADM_TXT_476);
exception when others then
 glbx.error_details( 'ADM', 'SEND_RENEWAL', errmsg=>sqlerrm, extdet=>null);
end send_renewal;

procedure storage_manager(surl varchar2)
as

 cursor c2a is select sum(bytes) tot from dba_data_files;
 cursor c3a is select sum(bytes) tot from dba_data_files where tablespace_name like ('PICTION_IMG%');
 cursor c4a is select sum(bytes) tot from dba_data_files where tablespace_name in ('PICTION_SML_1','PICTION_MED_1','PICTION_LRG_1','PICTION_IND_1');
 cursor c5a is select sum(bytes) tot from dba_data_files where tablespace_name not like 'PICTION%';
 cursor c2b is select sum(bytes) tot from dba_free_space;
 cursor c3b is select sum(bytes) tot from dba_free_space where tablespace_name like ('PICTION_IMG%');
 cursor c4b is select sum(bytes) tot from dba_free_space where tablespace_name in ('PICTION_SML_1','PICTION_MED_1','PICTION_LRG_1','PICTION_IND_1');
 cursor c5b is select sum(bytes) tot from dba_free_space where tablespace_name not like 'PICTION%';

 sessid		integer;
 sts		varchar2(200);
 tmp		varchar2(2000);
 tot_free	number;
 tot_used	number;
 tot_img	number;
 avg_size	number;
 avg_free	number;
 pct_free	number;
 used_mst	number;
 used_ori	number;
 used_bac	number;
 used_thm	number;
 actused	number;
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.STORAGE_MANAGER');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_477, helpid=>'A49' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_478 ),cattributes=>GLBX.QUERY_BACKGROUND);
   htp.tabledata( htf.bold( LNG3.ADM_TXT_479 ),cattributes=>GLBX.QUERY_BACKGROUND);
   htp.tabledata( htf.bold( LNG3.ADM_TXT_480 ),cattributes=>GLBX.QUERY_BACKGROUND);
   htp.tabledata( htf.bold( LNG3.ADM_TXT_481 ),cattributes=>GLBX.QUERY_BACKGROUND);
   htp.tabledata( htf.bold( LNG3.ADM_TXT_482 ),cattributes=>GLBX.QUERY_BACKGROUND);
  htp.tablerowclose;
  open c2a;
  fetch c2a into tot_used;
  close c2a;
  open c2b;
  fetch c2b into tot_free;
  close c2b;
  tot_used := nvl(trunc((tot_used/1024)/1024),0);
  tot_free := nvl(trunc((tot_free/1024)/1024),0);
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_483 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( tot_used ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( tot_free ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( to_char(round((tot_free/tot_used)*100,2)) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( '&nbsp;' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
  htp.tablerowclose;
  open c3a;
  fetch c3a into tot_used;
  close c3a;
  open c3b;
  fetch c3b into tot_free;
  close c3b;
  avg_size := nvl(tot_used,0);
  avg_free := nvl(tot_free,0);
  tot_used := nvl(trunc((tot_used/1024)/1024),0);
  tot_free := nvl(trunc((tot_free/1024)/1024),0);
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_484 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( tot_used ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( tot_free ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   pct_free := round((tot_free/tot_used)*100,2);
   if pct_free < 10
    then
     htp.tabledata( htf.bold( to_char( pct_free )),cattributes=>GLBX.QUERY_BACKGROUND);
     htp.tabledata( htf.bold( htf.anchor('adm.storage_inc?surl=' || glbx.rndsurl(surl) || '&typ=img&tot=' || tot_used || '&tot_free=' || tot_free,LNG3.ADM_TXT_485) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
    else
     htp.tabledata( to_char( pct_free ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
     htp.tabledata( htf.anchor('adm.storage_inc?surl=' || glbx.rndsurl(surl) || '&typ=img&tot=' || tot_used || '&tot_free=' || tot_free,LNG3.ADM_TXT_486),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   end if;
  htp.tablerowclose;
  open c4a;
  fetch c4a into tot_used;
  close c4a;
  open c4b;
  fetch c4b into tot_free;
  close c4b;
  tot_used := nvl(trunc((tot_used/1024)/1024),0);
  tot_free := nvl(trunc((tot_free/1024)/1024),0);
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_487 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( tot_used ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( tot_free ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   pct_free := round((tot_free/tot_used)*100,2);
   if pct_free < 10
    then
     htp.tabledata( htf.bold( to_char( pct_free )),cattributes=>GLBX.QUERY_BACKGROUND);
     htp.tabledata( htf.bold( htf.anchor('adm.storage_inc?surl=' || glbx.rndsurl(surl) || '&typ=data&tot=' || tot_used || '&tot_free=' || tot_free,LNG3.ADM_TXT_485) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
    else
     htp.tabledata( to_char( pct_free ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
     htp.tabledata( htf.anchor('adm.storage_inc?surl=' || glbx.rndsurl(surl) || '&typ=data&tot=' || tot_used || '&tot_free=' || tot_free,LNG3.ADM_TXT_486 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   end if;
  htp.tablerowclose;
  open c5a;
  fetch c5a into tot_used;
  close c5a;
  open c5b;
  fetch c5b into tot_free;
  close c5b;
  tot_used := nvl(trunc((tot_used/1024)/1024),0);
  tot_free := nvl(trunc((tot_free/1024)/1024),0);
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_488 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( tot_used ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( tot_free ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   pct_free := round((tot_free/tot_used)*100,2);
   if pct_free < 10
    then
     htp.tabledata( htf.bold( to_char( pct_free )),cattributes=>GLBX.QUERY_BACKGROUND);
     htp.tabledata( htf.bold( htf.anchor('adm.storage_inc?surl=' || glbx.rndsurl(surl) || '&typ=other&tot=' || tot_used || '&tot_free=' || tot_free,LNG3.ADM_TXT_485) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
    else
     htp.tabledata( to_char( pct_free ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
     htp.tabledata( htf.anchor('adm.storage_inc?surl=' || glbx.rndsurl(surl) || '&typ=other&tot=' || tot_used || '&tot_free=' || tot_free,LNG3.ADM_TXT_486),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   end if;
  htp.tablerowclose;
 htp.tableclose;

 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'STORAGE_MANAGER', errmsg=>sqlerrm, extdet=>null);
end storage_manager;

procedure storage_report(surl varchar2)
as
 cursor c1 is select count('x') tot from umo;
 cursor c6 (sn varchar2 ) is select bytes from user_segments where segment_name = sn;
 cursor c7 is
  select nvl(sum(dbms_lob.getlength(um.photo_thumbnail.source.localdata)),0) +
         nvl(sum(dbms_lob.getlength(um.photo_backup.source.localdata)),0) +
         nvl(sum(dbms_lob.getlength(um.photo_master.source.localdata)),0) +
         nvl(sum(dbms_lob.getlength(um.photo_original.source.localdata)),0) +
         nvl(sum(dbms_lob.getlength(um.video_original.source.localdata)),0) +
         nvl(sum(dbms_lob.getlength(um.audio_original.source.localdata)),0) +
         nvl(sum(dbms_lob.getlength(um.audio_thumbnail.source.localdata)),0) +
         nvl(sum(dbms_lob.getlength(um.doc_body)),0) +
         nvl(sum(dbms_lob.getlength(um.doc_gist)),0) +
         nvl(sum(dbms_lob.getlength(um.doc_html)),0) +
         nvl(sum(dbms_lob.getlength(um.blueprint_obj.localdata)),0) +
         nvl(sum(dbms_lob.getlength(um.blueprint_obj.online_version)),0) tot
  from umo um;
 cursor c7a is
  select nvl(sum(dbms_lob.getlength(um.photo_thumbnail.source.localdata)),0) +
         nvl(sum(dbms_lob.getlength(um.photo_backup.source.localdata)),0) +
         nvl(sum(dbms_lob.getlength(um.photo_master.source.localdata)),0) +
         nvl(sum(dbms_lob.getlength(um.photo_original.source.localdata)),0) +
         nvl(sum(dbms_lob.getlength(um.video_original.source.localdata)),0) tot
  from umo um;
 cursor c8(tname varchar2, cname varchar2) is select segment_name from user_lobs where table_name = tname and column_name = cname;
 cursor c9 is select sum(length(value)) sm from umo_attribute;

 c1rec		c1%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c9rec		c9%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 tmp		varchar2(2000);
 tot_free	number;
 tot_used	number;
 tot_img	number;
 avg_size	number;
 avg_free	number;
 pct_free	number;
 used_mst	number;
 used_ori	number;
 used_bac	number;
 used_thm	number;
 actused	number;
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.STORAGE_REPORT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_477, helpid=>'A49' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.nl;
 htp.bold( LNG3.ADM_TXT_489 );htp.nl;
  open c1;
  fetch c1 into tot_img;
  close c1;
   open c8( 'UMO','"PHOTO_MASTER"."SOURCE"."LOCALDATA"');
   fetch c8 into c8rec;
   close c8;
   open c6( c8rec.segment_name );
   fetch c6 into used_mst;
   close c6;
   open c8( 'UMO','"PHOTO_THUMBNAIL"."SOURCE"."LOCALDATA"');
   fetch c8 into c8rec;
   close c8;
   open c6( c8rec.segment_name );
   fetch c6 into used_thm;
   close c6;
   open c8( 'UMO','"PHOTO_BACKUP"."SOURCE"."LOCALDATA"');
   fetch c8 into c8rec;
   close c8;
   open c6( c8rec.segment_name );
   fetch c6 into used_bac;
   close c6;
   open c8( 'UMO','"PHOTO_ORIGINAL"."SOURCE"."LOCALDATA"');
   fetch c8 into c8rec;
   close c8;
   open c6( c8rec.segment_name );
   fetch c6 into used_ori;
   close c6;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_490 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( tot_img ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="RIGHT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_491 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( to_char(round(used_ori/1024,2)) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="RIGHT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_492 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( to_char(round(used_mst/1024,2)) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="RIGHT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_493 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( to_char(round(used_bac/1024,2)) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="RIGHT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_494 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( to_char(round(used_thm/1024,2)) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="RIGHT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_495 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( to_char(round((used_thm+used_bac+used_thm+used_ori)/1024,2)) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="RIGHT"');
  htp.tablerowclose;
  htp.tablerowopen;
   open c8( 'UMO','DOC_BODY');
   fetch c8 into c8rec;
   close c8;
   open c6( c8rec.segment_name );
   fetch c6 into c6rec;
   close c6;
   htp.tabledata( htf.bold( 'Document Usage' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( to_char(round(c6rec.bytes/1024,2)) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="RIGHT"');
  htp.tablerowclose;
   open c8( 'UMO','DOC_HTML');
   fetch c8 into c8rec;
   close c8;
   open c6( c8rec.segment_name );
   fetch c6 into c6rec;
   close c6;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Document HTML' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( to_char(round(c6rec.bytes/1024,2)) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="RIGHT"');
  htp.tablerowclose;
   open c8( 'UMO','DOC_GIST');
   fetch c8 into c8rec;
   close c8;
   open c6( c8rec.segment_name );
   fetch c6 into c6rec;
   close c6;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Document GIST' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( to_char(round(c6rec.bytes/1024,2)) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="RIGHT"');
  htp.tablerowclose;
   open c8( 'UMO','"VIDEO_ORIGINAL"."SOURCE"."LOCALDATA"');
   fetch c8 into c8rec;
   close c8;
   open c6( c8rec.segment_name );
   fetch c6 into c6rec;
   close c6;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Video Usage' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( to_char(round(c6rec.bytes/1024,2)) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="RIGHT"');
  htp.tablerowclose;
   open c8( 'UMO','"AUDIO_ORIGINAL"."SOURCE"."LOCALDATA"');
   fetch c8 into c8rec;
   close c8;
   open c6( c8rec.segment_name );
   fetch c6 into c6rec;
   close c6;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Audio Usage' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( to_char(round(c6rec.bytes/1024,2)) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="RIGHT"');
  htp.tablerowclose;
   open c8( 'UMO','"BLUEPRINT_OBJ"."LOCALDATA"');
   fetch c8 into c8rec;
   close c8;
   open c6( c8rec.segment_name );
   fetch c6 into c6rec;
   close c6;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Blueprint Usage' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( to_char(round(c6rec.bytes/1024,2)) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="RIGHT"');
  htp.tablerowclose;
   open c8( 'UMO','"BLUEPRINT_OBJ"."ONLINE_VERSION"');
   fetch c8 into c8rec;
   close c8;
   open c6( c8rec.segment_name );
   fetch c6 into c6rec;
   close c6;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Blueprint Online' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( to_char(round(c6rec.bytes/1024,2)) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="RIGHT"');
  htp.tablerowclose;
   open c9;
   fetch c9 into c9rec;
   close c9;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Size of Meta Data' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( to_char(round(c9rec.sm/1024,2)) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="RIGHT"');
  htp.tablerowclose;
  open c7;
  fetch c7 into actused;
  close c7;
  actused := nvl(actused,0);
  avg_free := nvl(avg_free,0) + (used_thm+used_bac+used_thm+used_ori - actused);
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_496 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( to_char(round((actused)/1024,2)) ) || htf.nl ||
                  'Total Free:' || to_char(round((avg_free)/1024,2)),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="RIGHT"');
  htp.tablerowclose;
  open c7a;
  fetch c7a into actused;
  close c7a;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_497 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( to_char(round((actused/tot_img)/1024,2)) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="RIGHT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_498 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND);
   htp.tabledata( htf.bold( to_char(round((avg_free/(actused/tot_img)),0)) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' align="RIGHT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'STORAGE_REPORT', errmsg=>sqlerrm, extdet=>null);
end storage_report;

procedure storage_inc(surl varchar2,typ in varchar2, tot in integer, tot_free in integer )
as
 cursor c1 is select instance_name from v$instance;
 cursor c2 is select file_name from dba_data_files;
 cursor c3(ts varchar2) is select count('x') tot from dba_data_files where tablespace_name = ts;
 cursor c4a is select tablespace_name,sum(bytes) tot from dba_data_files where tablespace_name in ('PICTION_SML_1','PICTION_MED_1','PICTION_LRG_1','PICTION_IND_1') group by tablespace_name;
 cursor c4b(ts varchar2)  is select sum(bytes) tot from dba_free_space where tablespace_name = ts;
 cursor c4c is select tablespace_name,sum(bytes) tot from dba_data_files where tablespace_name not like 'PICTION%' group by tablespace_name;
 cursor c4d(ts varchar2)  is select sum(bytes) tot from dba_data_files where tablespace_name = ts;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4arec		c4a%ROWTYPE;
 c4brec		c4b%ROWTYPE;
 c4drec		c4d%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 incstr		varchar2(1000);
 vincstr	varchar2(1000);
 pct_free	number;
 tabspc		varchar2(100);
 tmp		varchar2(1000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.STORAGE_INC');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 open c1;
 fetch c1 into c1rec;
 close c1;
 open c2;
 fetch c2 into c2rec;
 close c2;
 if decs.unix_or_nt = '\'
  then
   incstr := substr(c2rec.file_name,1,3) || 'oradata\' || c1rec.instance_name || '\';
  else
   incstr := substr(c2rec.file_name,1,4) || 'oradata/' || c1rec.instance_name || '/';
 end if;
 vincstr := incstr;

 if typ = 'img'
  then
   open c3( 'PICTION_IMG1' );
   fetch c3 into c3rec;
   close c3;
   incstr := incstr || 'piction_img1_' || to_char(nvl(c3rec.tot,0) + 1) || '.dbf';
   tabspc := 'PICTION_IMG1';
 elsif typ = 'data'
  then
   for c4arec in c4a loop
    open c4b(c4arec.tablespace_name);
    fetch c4b into c4brec;
    close c4b;
    pct_free := round((c4brec.tot/c4arec.tot)*100,2);
    open c3( c4arec.tablespace_name );
    fetch c3 into c3rec;
    close c3;
    incstr := vincstr || c4arec.tablespace_name || '_' || to_char(nvl(c3rec.tot,0) + 1) || '.dbf';
    tabspc := c4arec.tablespace_name;
    if pct_free < 10
     then
      exit;
    end if;
   end loop;
 elsif typ = 'other'
  then
   for c4crec in c4c loop
    open c4b(c4crec.tablespace_name);
    fetch c4b into c4brec;
    close c4b;
    pct_free := round((c4brec.tot/c4crec.tot)*100,2);
    open c3( c4crec.tablespace_name );
    fetch c3 into c3rec;
    close c3;
    incstr := vincstr || c4crec.tablespace_name || '_' || to_char(nvl(c3rec.tot,0) + 1) || '.dbf';
    tabspc := c4crec.tablespace_name;
    if pct_free < 10
     then
      exit;
    end if;
   end loop;
 end if;

 main_title( surl, sessid, LNG3.ADM_TXT_485, helpid=>'A50' );
 htp.nl;
 if tabspc is null or incstr is null
  then
   htp.bold( LNG3.ADM_TXT_499 );
   htp.htmlclose;
   return;
 end if;

 open c4d(tabspc);
 fetch c4d into c4drec;
 close c4d;
 open c4b(tabspc);
 fetch c4b into c4brec;
 close c4b;
 htp.formopen( 'adm.accept_storage_inc' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_282 ),cattributes=>GLBX.QUERY_BACKGROUND);
   htp.tabledata( htf.formtext( 'P1', 40, 100, tabspc ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_500 ),cattributes=>GLBX.QUERY_BACKGROUND);
   htp.tabledata( htf.formtext( 'P2', 40, 1000, incstr ) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_480 ),cattributes=>GLBX.QUERY_BACKGROUND);
   htp.tabledata( round((c4brec.tot/1024)/1024),2);
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_501 ),cattributes=>GLBX.QUERY_BACKGROUND);
   htp.tabledata( round((c4drec.tot/1024)/1024),2);
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( '% ' || LNG3.ADM_TXT_502 ),cattributes=>GLBX.QUERY_BACKGROUND);
   htp.tabledata( round((c4brec.tot/c4drec.tot)*100),2);
  htp.tablerowclose;
  tmp := htf.formselectopen( 'P3' );
  for j in 1..10 loop
   tmp := tmp || htf.formselectoption( to_char(j) );
  end loop;
  for j in 1..9 loop
   tmp := tmp || htf.formselectoption( to_char(j*10) );
  end loop;
  for j in 1..10 loop
   tmp := tmp || htf.formselectoption( to_char(j*100) );
  end loop;
  tmp := tmp || htf.formselectoption( '1200' ) || htf.formselectoption( '1400' ) || htf.formselectoption( '1500' ) || htf.formselectoption( '1600' ) || htf.formselectoption( '1800' ) || htf.formselectoption( '2000','SELECTED' );
  if decs.unix_or_nt = '/'
   then
    for j in 5..20 loop
     tmp := tmp || htf.formselectoption( to_char(j*500) );
    end loop;
  end if;
  tmp := tmp || htf.formselectclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_503 ),cattributes=>GLBX.QUERY_BACKGROUND);
   htp.tabledata( tmp );
  htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.tableopen;
   htp.tablerowopen;
    htp.tabledata( LNG3.ADM_TXT_504 || ': ' );
    htp.tabledata( '&nbsp;' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;' );
    htp.tabledata( LNG3.ADM_TXT_505 );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;' );
    htp.tabledata( LNG3.ADM_TXT_506 );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;' );
    htp.tabledata( LNG3.ADM_TXT_507 );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.nl;
  htp.formsubmit( null, LNG3.ADM_TXT_485 );
  htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'STORAGE_INC', errmsg=>sqlerrm, extdet=>null);
end storage_inc;

procedure form_redirect(surl varchar2,phgid in integer, msg in varchar2 default null )
as

 cursor c1(phgid integer) is select * from photographer where pid = phgid;
 cursor c2(phgid integer) is select * from customer_account where pid = phgid;
 cursor c3 is select site_id,site_dns from redirect_sites order by site_id;
 cursor c4(sid integer) is select site_dns from redirect_sites where site_id = sid;
 cursor c5(phgid integer) is select * from customer_profile where pid = phgid;
 cursor c6(acid integer) is select * from customer_account where aid = acid;

 c1rec		c1%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c6rec		c6%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.FORM_REDIRECT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_043, style=>'NOMENU', helpid=>'A54' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.header( 5,LNG3.ADM_TXT_508 );
 htp.nl;
 htp.formopen( 'adm.accept_redirect' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.formhidden( 'PHGID', phgid );
  htp.tableopen;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG3.ADM_TXT_509 || ':' ));
    htp.p( '<TD>' );
    htp.formselectopen( 'P1' );
    htp.formselectoption( NULL );
    for c3rec in c3 loop
     htp.formselectoption( '[' || c3rec.site_id || '] ' || c3rec.site_dns );
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, LNG3.ADM_TXT_510 );
 htp.formclose;
 htp.nl;
 htp.bold( LNG4.AHC_TXT_316 );
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_261 ) );
   open c1(phgid);
   fetch c1 into c1rec;
   close c1;
   htp.tabledata( htf.bold( c1rec.business_name || '(' || c1rec.username || ')' ));
  htp.tablerowclose;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_512 ) );
   open c4(c1rec.redirect_site_id);
   fetch c4 into c4rec;
   close c4;
   if c4rec.site_dns is not null
    then
     htp.tabledata( htf.bold( glbx.adjust_for_http(c4rec.site_dns) ) );
    else
     htp.tabledata( '&nbsp;' );
   end if;
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
  htp.tablerowopen;
   htp.tableheader( LNG.PHG_TXT_199 );
   htp.tableheader( LNG3.ADM_TXT_512 );
  htp.tablerowclose;
  for c2rec in c2(phgid) loop
  htp.tablerowopen;
   htp.tabledata( c2rec.username );
   c4rec.site_dns := NULL;
   open c4(c2rec.redirect_site_id);
   fetch c4 into c4rec;
   close c4;
   if c4rec.site_dns is not null
    then
     htp.tabledata( htf.bold( glbx.adjust_for_http(c4rec.site_dns) ) );
    else
     htp.tabledata( '&nbsp;' );
   end if;
  htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
  htp.tablerowopen;
   htp.tableheader( LNG3.ADM_TXT_513 );
   htp.tableheader( LNG3.ADM_TXT_512 );
  htp.tablerowclose;
  htp.nl;
  for c5rec in c5(phgid) loop
  htp.tablerowopen;
   htp.tabledata( c5rec.username );
   c4rec.site_dns := NULL;
   open c6(c5rec.aid);
   fetch c6 into c6rec;
   close c6;
   open c4(c6rec.redirect_site_id);
   fetch c4 into c4rec;
   close c4;
   if c4rec.site_dns is not null
    then
     htp.tabledata( htf.bold( glbx.adjust_for_http(c4rec.site_dns )) );
    else
     htp.tabledata( '&nbsp;' );
   end if;
  htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'FORM_REDIRECT', errmsg=>sqlerrm, extdet=>null);
end form_redirect;

procedure accept_redirect(surl varchar2,phgid in integer, p1 in varchar2 )
as

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_REDIRECT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if p1 is null
  then
   sid := NULL;
  else
   sid := to_number(substr(p1,2,instr(p1,']')-2));
 end if;
 update photographer set redirect_site_id = sid where pid = phgid;
 update customer_account set redirect_site_id = sid where pid = phgid;
 commit;
 form_redirect(surl,phgid,LNG3.ADM_TXT_514);
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_REDIRECT', errmsg=>sqlerrm, extdet=>null);
end accept_redirect;

procedure mnt_redirect(surl varchar2,msg in varchar2 default null )
as

 cursor c1 is select site_id,site_dns from redirect_sites order by site_id;
 cursor c2(sid integer) is select username from photographer where redirect_site_id = sid;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MNT_REDIRECT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_512, helpid=>'A55' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_mnt_redirect' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( LNG3.ADM_TXT_512 );
  htp.tableheader( LNG3.ADM_TXT_515 );
 htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1',30,100,glbx.adjust_for_http(c1rec.site_dns) ) );
   htp.formhidden( 'P2',c1rec.site_id);
   htp.p( '<TD>' );
   for c2rec in c2(c1rec.site_id) loop
    htp.p( c2rec.username || '&nbsp;');
   end loop;
   htp.p( '</TD>' );
  htp.tablerowclose;
 end loop;
 for j in 1..3 loop
  htp.tablerowopen;
   htp.tabledata( 'http://' || htf.formtext( 'P1',30,100, null ) );
   htp.formhidden( 'P2',null);
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null,LNG3.ADM_TXT_516 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MNT_REDIRECT', errmsg=>sqlerrm, extdet=>null);
end mnt_redirect;

procedure accept_mnt_redirect(surl varchar2,p1 in MYARRAY, p2 in MYARRAY )
as

 cursor c1(sid integer) is select count('x') tot from photographer where redirect_site_id = sid;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_MNT_REDIRECT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 for j in p1.first..p1.last loop
 if p1(j) is null and p2(j) is not null
  then
   open c1(p2(j));
   fetch c1 into sid;
   close c1;
   if nvl(sid,0) = 0
    then
     delete from redirect_sites where site_id = p2(j);
    else
     rollback;
     mnt_redirect( LNG3.ADM_TXT_517 );
     return;
   end if;
  elsif p1(j) is null and p2(j) is null
   then
    null; -- do nothing
  elsif p1(j) is not null and p2(j) is null
   then
    select nvl(max(site_id),0) + 1 into sid from redirect_sites;
    insert into redirect_sites(site_id,site_dns) values (sid,p1(j));
  else
   update redirect_sites
    set
     site_dns = p1(j)
    where site_id = p2(j);
  end if;
 end loop;
 commit;
 mnt_redirect( surl,LNG3.ADM_TXT_518 );
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_MNT_REDIRECT', errmsg=>sqlerrm, extdet=>null);
end accept_mnt_redirect;

procedure accept_storage_inc(surl varchar2,p1 in varchar2, p2 in varchar2, p3 in varchar2 )
as
 sessid		integer;
 sts		varchar2(200);
 incstr		varchar2(1000);
 pct_free	number;
 tabspc		varchar2(100);
 tmp		varchar2(1000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_STORAGE_INC');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_519, helpid=>'A51' );
 htp.nl;
 htp.italic( LNG3.ADM_TXT_520 || ': ' || 'alter tablespace ' || p1 || ' add datafile ''' || p2 || ''' size ' || p3 || 'm' );
 htp.nl; htp.nl;
 begin
  execute immediate 'alter tablespace ' || p1 || ' add datafile ''' || p2 || ''' size ' || p3 || 'm';
 exception
  when others
   then
    htp.nl;
    htp.bold( LNG3.ADM_TXT_521 || ': ' || sqlerrm ); htp.nl;
    return;
end;
htp.bold( 'Success.' );
htp.nl;
htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_STORAGE_INC', errmsg=>sqlerrm, extdet=>null);
end accept_storage_inc;

procedure stop_piction(surl varchar2)
as
 sessid		integer;
 sts		varchar2(200);
 dm		integer;
begin
  glbx.adm_cookie_id( surl,sessid,sts,'ADM.STOP_PICTION');
  if sts is not null
   then
    htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;
  /*
  dm := dbms_pipe.create_pipe('CPROG',8192,FALSE);
  dbms_pipe.pack_message('END');
  dbms_pipe.pack_message(0);
  dbms_pipe.pack_message(0);
  dbms_pipe.pack_message(user); -- Schema Name
  dbms_pipe.pack_message(100);
  dbms_pipe.pack_message('ROTATE');
  dbms_pipe.pack_message('90C');
  dbms_pipe.pack_message(0);
  dbms_pipe.pack_message(0);
  dbms_pipe.pack_message(0);
  dbms_pipe.pack_message(0);
  dbms_pipe.pack_message('Cross');
  sts := dbms_pipe.send_message('CPROG',maxpipesize=>32767);
  */
 htp.htmlopen;
 htp.bold( 'Command sent to terminate process. Please stop the PICTION Service');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'STOP_PICTION', errmsg=>sqlerrm, extdet=>null);
end stop_piction;

procedure dump_slideshow( surl varchar2,phgid in integer )
as
 cursor c1(phgid integer) is
  select ca.aid,username,account_name,sid,slideshow_name
  from slide_master sm,customer_account ca
  where ca.pid = phgid and
        ca.aid = sm.aid
  order by username,sid;
 cursor c2(slid integer) is select count('x') tot from slide_details where sid = slid;

 tot		integer;
 sessid		integer;
 sts		varchar2(200);
 lastcust	integer;
begin
  glbx.adm_cookie_id( surl,sessid,sts,'ADM.DUMP_SLIDESHOW');
  if sts is not null
   then
    htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;
 main_title( surl, sessid, LNG3.ADM_TXT_522, style=>'NOMENU', helpid=>'A52' );
 htp.nl;
 htp.nl;
 lastcust := NULL;
 for c1rec in c1(phgid) loop
  if (lastcust is not null) and (lastcust <> c1rec.aid)
   then
    htp.tableclose;
    htp.formsubmit( null, LNG3.ADM_TXT_523 );
    htp.formclose;
  end if;
  if (nvl(lastcust,0) <> c1rec.aid)
   then
    htp.formopen( 'adm.download_slide' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
    htp.formhidden( 'P1', null);
    htp.formhidden( 'ACID', c1rec.aid);
    htp.bold( c1rec.account_name || ' (' || c1rec.username || ')' );
    htp.nl;
    htp.bold( LNG3.ADM_TXT_524 );
    htp.formtext( 'dirloc', 30, 1000 );
    htp.nl;
    htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
     htp.tablerowopen;
     htp.tableheader( LNG3.ADM_TXT_525 );
     htp.tableheader( LNG3.ADM_TXT_526 );
     htp.tableheader( LNG3.ADM_TXT_523 );
    htp.tablerowclose;
    lastcust := c1rec.aid;
  end if;
  tot := 0;
  open c2(c1rec.sid);
  fetch c2 into tot;
  close c2;
  htp.tablerowopen;
   htp.tabledata( htf.bold(c1rec.slideshow_name) );
   htp.tabledata( to_char(tot));
   htp.tabledata( htf.formcheckbox( 'P1',to_char(c1rec.sid)));
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.formsubmit( null, LNG3.ADM_TXT_523  );
 htp.formclose;
 htp.nl;
 htp.tableclose;
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'DUMP_SLIDESHOW', errmsg=>sqlerrm, extdet=>null);
end dump_slideshow;

procedure download_slide( surl varchar2,p1 in MYARRAY, acid in integer, dirloc in varchar2 )
as
  cursor c1(slid integer) is
   select phid_1 phid
   from slide_details
   where sid = slid and phid_1 is not null
  union
   select phid_2 phid
   from slide_details
   where sid = slid and phid_2 is not null
  union
   select phid_3 phid
   from slide_details
   where sid = slid and phid_3 is not null
  union
   select phid_1 phid
   from slide_details
   where sid = slid and phid_4 is not null;


  cursor c2(slid integer) is select * from slide_master where sid = slid;
  cursor c3(slid integer) is select * from slide_details where sid = slid order by slide_nmbr;
  cursor c4(slid integer) is select max(slide_nmbr) from slide_details where sid = slid;
  cursor c5(phid integer) is select um.photo_master,um.photo_thumbnail,um.extras.photo_name photo_name from umo um where umo_id = phid;
  cursor c6(phgid integer) is select * from photographer where pid = phgid;
  cursor c7(acid integer) is select * from customer_account where aid = acid;

  cursor c8(acid integer) is select umo_id phid from umo um where aid=acid and um.extras.quality = 'DETAIL PHOTO';


  slid		integer;
  c2rec		c2%ROWTYPE;
  c5rec		c5%ROWTYPE;
  c6rec		c6%ROWTYPE;
  c7rec		c7%ROWTYPE;
  c8rec		c8%ROWTYPE;
  sessid	integer;
  sts 		integer;
  retsess	varchar2(100);
  status        NUMBER;
  result        NUMBER;
  l_output      utl_file.file_type;
  buffer	varchar2(2000);
  maxsld	integer;
  retval	varchar2(1000);
  foundrec	boolean;
  ky		varchar2(10);
  homeimg	varchar2(10000);
  dm		integer;

 begin
  glbx.adm_cookie_id( surl,sessid,sts,'ADM.DOWNLOAD_SLIDE');
  if sts is not null
   then
    htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;

  if p1.last = 1
   then
    htp.htmlopen;
    glbx.header_msg( LNG3.ADM_TXT_527 );
    htp.htmlclose;
    return;
  end if;

  open c7(acid);
  fetch c7 into c7rec;
  close c7;

  open c6(c7rec.pid);
  fetch c6 into c6rec;
  close c6;

  for k in 2..p1.last loop
   --
   -- Step 1: Download the Photos
   --
   -- Download the Home Page Image
   slid := to_number(p1(k));
   if k = 2
    then
     main_title( surl, sessid, LNG3.ADM_TXT_528 || ' #' || p1(k), style=>'NOMENU' );
    else
     htp.header(4, LNG3.ADM_TXT_528 || ' #' || p1(k),'ADM_LEFT' );
   end if;
   open c8(acid);
   fetch c8 into c8rec;
   if c8%FOUND
    then
      select s_umo_sess.nextval into retsess from dual;
      dm := dbms_pipe.create_pipe('CPROG',8192,FALSE);
      dbms_pipe.pack_message(retsess);
      dbms_pipe.pack_message(c8rec.phid);
      dbms_pipe.pack_message(0); -- AID
      dbms_pipe.pack_message(user); -- Schema Name
      dbms_pipe.pack_message(0); -- Thumbnail Width
      dbms_pipe.pack_message('WRITE');
      dbms_pipe.pack_message(dirloc || 'm' || to_char(c8rec.phid) || '.jpg');
      dbms_pipe.pack_message('MASTER'); -- THUMBNAIL
      sts := dbms_pipe.send_message('CPROG',maxpipesize=>32767);
      status := dbms_pipe.receive_message(retsess,30);
      dbms_pipe.unpack_message(result);
      if result > 0
       then
        htp.p( nvl(retval,LNG3.ADM_TXT_550) ); htp.nl;
       else
        htp.p( LNG3.ADM_TXT_529 || ' #' || c8rec.phid ); htp.nl;
      end if;
     homeimg := '<BODY BGCOLOR="#FFFFFF">';
     homeimg := homeimg || htf.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border= 0' ) || htf.tablerowopen;
     homeimg := homeimg || htf.tabledata( htf.img('m' || to_char(c8rec.phid) || '.jpg',cattributes=>'BORDER=0'));
    else
     homeimg := null;
   end if;
   close c8;
   for c1rec in c1(slid) loop
    -- Unpack the Master Image
    foundrec := TRUE;
    open c5(c1rec.phid);
    fetch c5 into c5rec;
    if c5%NOTFOUND then foundrec := FALSE; end if;
    close c5;
    if nvl(dbms_lob.getlength(c5rec.photo_master.source.localdata),0) = 0
     then
      foundrec := FALSE;
    end if;
    if nvl(dbms_lob.getlength(c5rec.photo_thumbnail.source.localdata),0) = 0
     then
      foundrec := FALSE;
    end if;
    if foundrec
     then
      select s_umo_sess.nextval into retsess from dual;
      dm := dbms_pipe.create_pipe('CPROG',8192,FALSE);
      dbms_pipe.pack_message(retsess);
      dbms_pipe.pack_message(c1rec.phid);
      dbms_pipe.pack_message(0); -- AID
      dbms_pipe.pack_message(user); -- Schema Name
      dbms_pipe.pack_message(0); -- Thumbnail Width
      dbms_pipe.pack_message('WRITE');
      dbms_pipe.pack_message(dirloc || 'm' || to_char(c1rec.phid) || '.jpg');
      dbms_pipe.pack_message('MASTER'); -- THUMBNAIL
      sts := dbms_pipe.send_message('CPROG',maxpipesize=>32767);
      status := dbms_pipe.receive_message(retsess,30);
      dbms_pipe.unpack_message(result);
      if result > 0
       then
        htp.p( retval ); htp.nl;
       else
        htp.p( LNG3.ADM_TXT_529 || ' #' || c1rec.phid ); htp.nl;
      end if;

      -- Unpack the Thumbnail
      select s_umo_sess.nextval into retsess from dual;
      dm := dbms_pipe.create_pipe('CPROG',8192,FALSE);
      dbms_pipe.pack_message(retsess);
      dbms_pipe.pack_message(c1rec.phid);
      dbms_pipe.pack_message(0); -- AID
      dbms_pipe.pack_message(user); -- Schema Name
      dbms_pipe.pack_message(0); -- Thumbnail Width
      dbms_pipe.pack_message('WRITE');
      dbms_pipe.pack_message(dirloc || 't' || to_char(c1rec.phid) || '.jpg');
      dbms_pipe.pack_message('THUMBNAIL');
      sts := dbms_pipe.send_message('CPROG',maxpipesize=>32767);
      status := dbms_pipe.receive_message(retsess,30);
      dbms_pipe.unpack_message(result);
      if result > 0
       then
        htp.p( retval ); htp.nl;
       else
        htp.p( LNG3.ADM_TXT_529 || '#' || c1rec.phid ); htp.nl;
      end if;
    end if;
   end loop;

   --
   -- Step 2: Download the HTML Files for the slides
   --
   open c2(slid);
   fetch c2 into c2rec;
   close c2;
   open c4(slid);
   fetch c4 into maxsld;
   close c4;

   for c3rec in c3(slid) loop
    for j in 1..2 loop
     if j = 1
      then
       ky := 's' || p1(k);
       htp.p( LNG3.ADM_TXT_530 || ' #' || c3rec.slide_nmbr ); htp.nl;
     else
       ky := 'n' || p1(k);
       htp.p( LNG3.ADM_TXT_531 || ' #' || c3rec.slide_nmbr ); htp.nl;
     end if;

     begin
      l_output := utl_file.fopen( dirloc, ky || to_char(c3rec.slide_nmbr) || '.htm', 'w' );
     exception
      when others
       then
        htp.htmlopen;
         htp.header(3,LNG3.ADM_TXT_549 || ':' || dirloc );
        htp.htmlclose;
        return;
     end;
     utl_file.put_line( l_output,htf.htmlopen);
     utl_file.put_line( l_output,htf.title(c3rec.slide_nmbr || ': ' || c3rec.slide_title));
     if c2rec.background_gif is null
      then
       utl_file.put_line( l_output,'<BODY BGCOLOR="' || c2rec.background_clr || '">');
      else
      utl_file.put_line( l_output,'<BODY BGCOLOR="FFFFFF">');
      end if;
     utl_file.put_line( l_output,'<CENTER>');
     if j = 1
      then
       if (c3rec.slide_nmbr = maxsld)
        then
         utl_file.put_line( l_output, '<META HTTP-EQUIV="Refresh" CONTENT="' || nvl(to_char(c3rec.next_timing),'25') || ';URL=s' || p1(k) || '1.htm">');
        else
         utl_file.put_line( l_output, '<META HTTP-EQUIV="Refresh" CONTENT="' || nvl(to_char(c3rec.next_timing),'25') || ';URL=s' || p1(k) || to_char(c3rec.slide_nmbr+1) || '.htm">');
       end if;
      end if;
      utl_file.put_line( l_output,htf.tableopen(cattributes=> ' border=' || c2rec.frame_size || ' cellpadding=0 cellspacing=0 ' ));

      calc_slide(surl,c2rec,c3rec,l_output,'m',p1(k));

      utl_file.put_line( l_output,htf.tableclose);
      utl_file.put_line( l_output,htf.nl);
      utl_file.put_line( l_output,htf.nl);
      utl_file.put_line( l_output,htf.anchor( ky || '1.htm','&lt&lt') || '&nbsp;' );
      utl_file.put_line( l_output,htf.anchor( ky || to_char(greatest(1,c3rec.slide_nmbr-1)) || '.htm','&lt') || '&nbsp;' );
      utl_file.put_line( l_output,htf.anchor('index' || p1(k) || '.htm',htf.bold('(' || c3rec.slide_nmbr || ': ' || c3rec.slide_title || ')')));
      utl_file.put_line( l_output,htf.anchor('index.htm',htf.bold('[' || LNG.GLB_TXT_091 || ']')) || '&nbsp;');
      utl_file.put_line( l_output,htf.anchor( ky || to_char(least(maxsld,c3rec.slide_nmbr+1)) || '.htm','&gt') || '&nbsp;' );
      utl_file.put_line( l_output,htf.anchor( ky || to_char(maxsld) || '.htm','&gt&gt')  || '&nbsp;' || '&nbsp;' || '&nbsp;');
      if j = 1
       then
        utl_file.put_line( l_output,htf.anchor( 'n' || p1(k) || '1.htm',' ' || LNG3.ADM_TXT_532 ) );
       else
        utl_file.put_line( l_output,htf.anchor( 's' || p1(k) || '1.htm',' ' || LNG3.ADM_TXT_533 ) );
      end if;
      utl_file.put_line( l_output,'</CENTER>');
      utl_file.put_line( l_output,htf.htmlclose);
     utl_file.fclose( l_output );
    end loop;
   end loop;
  end loop;

  --
  -- Step 3: Download the Individual Index files
  --
  for k in 2..p1.last loop
   htp.p( 'Dumping index' || p1(k) || '.htm' ); htp.nl;
   l_output := utl_file.fopen( dirloc, 'index' || p1(k) || '.htm', 'w' );
   utl_file.put_line( l_output,htf.htmlopen);
   utl_file.put_line( l_output,htf.title('Slideshow Index for ' || c2rec.slideshow_name));
   utl_file.put_line( l_output,htf.header(2,c2rec.slideshow_name,'CENTER'));
   utl_file.put_line( l_output,'<CENTER>');
   utl_file.put_line( l_output, htf.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=2' ) );
   utl_file.put_line( l_output,htf.tablerowopen);
   for c3rec in c3(to_number(p1(k))) loop
    calc_slide(surl,c2rec,c3rec,l_output,'t',p1(k));
    if mod(c3%ROWCOUNT,3) = 0
     then
      utl_file.put_line( l_output,htf.tablerowclose);
      utl_file.put_line( l_output,htf.tablerowopen);
    end if;
   end loop;
   utl_file.put_line( l_output,htf.tablerowclose);
   utl_file.put_line( l_output,htf.tableclose);
   utl_file.put_line( l_output,htf.nl);
   utl_file.put_line( l_output,htf.nl);
   utl_file.put_line( l_output,htf.anchor('index.htm', LNG3.ADM_TXT_534));
   utl_file.put_line( l_output,'</CENTER>');
   utl_file.put_line( l_output,htf.htmlclose);
   utl_file.fclose( l_output );
  end loop;

  --
  -- Step 4: Download the Master Index
  --
  htp.p( LNG3.ADM_TXT_535 ); htp.nl;
  l_output := utl_file.fopen( dirloc, 'index.htm', 'w' );
  utl_file.put_line( l_output,htf.htmlopen);
  if homeimg is null
   then
    utl_file.put_line( l_output,'<BODY BGCOLOR="#FFFFFF">');
    utl_file.put_line( l_output,htf.title(LNG3.ADM_TXT_536));
    utl_file.put_line( l_output,'<CENTER>');
    utl_file.put_line( l_output,htf.header(2,c6rec.business_name,'CENTER'));
    utl_file.put_line( l_output,htf.header(3,c7rec.account_name,'CENTER'));
   else
    utl_file.put_line( l_output,'<BODY BGCOLOR="#FFFFFF">');
    utl_file.put_line( l_output,htf.title(LNG3.ADM_TXT_536));
    utl_file.put_line( l_output,'<CENTER>');
    utl_file.put_line( l_output,homeimg);
    utl_file.put_line( l_output,'<TD>' || htf.header(2,c6rec.business_name,'CENTER') || htf.header(3,c7rec.account_name,'CENTER'));
 end if;

  utl_file.put_line( l_output,htf.nl);
  utl_file.put_line( l_output, htf.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' ) );
  for k in 2..p1.last loop
   open c2(to_number(p1(k)));
   fetch c2 into c2rec;
   close c2;
   utl_file.put_line( l_output,htf.tablerowopen);
    utl_file.put_line( l_output,htf.tabledata(htf.anchor('index' || p1(k) || '.htm',c2rec.slideshow_name)));
   utl_file.put_line( l_output,htf.tablerowclose);
  end loop;
  utl_file.put_line( l_output,htf.tableclose);

  if homeimg is not null
   then
    utl_file.put_line( l_output,'</TD>' || htf.tablerowclose || htf.tableclose);
  end if;
  utl_file.put_line( l_output,'</CENTER>');
  utl_file.put_line( l_output,htf.htmlclose);
  utl_file.fclose( l_output );

  htp.p( LNG3.ADM_TXT_537 ); htp.nl;
  htp.p( LNG3.ADM_TXT_538 || ': ' || dirloc || 'index.htm' ); htp.nl;
  htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'DOWNLOAD_SLIDE',null,null,errmsg=>sqlerrm,extdet=>'SLID:' || slid || ' DIRLOC:' || dirloc );
end download_slide;

procedure dump_slide(surl varchar2,l_output in out utl_file.file_type, c2rec in SLIDE_MASTER%ROWTYPE, c3rec in SLIDE_DETAILS%ROWTYPE, photo_id in integer, shrink in integer default 1, sldtype in varchar2, dumpurl in varchar2)
as
 cursor c4(photo_id integer) is select umo_id,photo_master,photo_thumbnail from umo where umo_id=photo_id;
 c4rec		c4%ROWTYPE;
 photo_name	varchar2(100);
 hg		integer;
 wd		integer;
begin
 utl_file.put_line( l_output,'<TD valign="MIDDLE" ALIGN="CENTER">');
 utl_file.put_line( l_output,htf.tableopen( cattributes=>'border=' || c2rec.frame_size ));
 utl_file.put_line( l_output,htf.tablerowopen);
  if photo_id is not null
   then
    open c4( photo_id );
    fetch c4 into c4rec;
    close c4;
    photo_name := ump.uma_attribute( surl,c4rec.umo_id, 'PHOTO', 'NAME' );
    photo_name := nvl(photo_name,ump.uma_attribute( surl,c4rec.umo_id, 'PHOTO', 'FILM_NAME' ));
    if sldtype = 'm'
     then
      hg := c4rec.photo_master.height;
      wd := c4rec.photo_master.width;
      if wd > hg
      then
       utl_file.put_line( l_output, htf.anchor( dumpurl, '<IMG BORDER=0 HEIGHT=' || to_char(glbx.sctrl('DEFAULT','PHOTO_WIDTH',1) / shrink) || ' SRC="' ||
                        sldtype || to_char(photo_id) || '.jpg' || '" ALT="' || photo_name || '">') );
      else
       utl_file.put_line( l_output, htf.anchor( dumpurl, '<IMG BORDER=0 WIDTH=' || to_char(glbx.sctrl('DEFAULT','PHOTO_WIDTH',1) / shrink) || ' SRC="' ||
                        sldtype || to_char(photo_id) || '.jpg' || '" ALT="' || photo_name || '">') );
      end if;
     else
      hg := c4rec.photo_thumbnail.height;
      wd := c4rec.photo_thumbnail.width;
      if wd > hg
      then
       utl_file.put_line( l_output, htf.anchor( dumpurl, '<IMG BORDER=0 HEIGHT=' || to_char(hg) || ' SRC="' ||
                        sldtype || to_char(photo_id) || '.jpg' || '" ALT="' || photo_name || '">') );
      else
       utl_file.put_line( l_output, htf.anchor( dumpurl, '<IMG BORDER=0 WIDTH=' || to_char(wd) || ' SRC="' ||
                        sldtype || to_char(photo_id) || '.jpg' || '" ALT="' || photo_name || '">') );
      end if;
    end if;
  end if;
 utl_file.put_line( l_output,htf.tablerowclose);
 utl_file.put_line( l_output,htf.tableclose);
 utl_file.put_line( l_output,'</TD>');
exception when others then
 glbx.error_details( 'ADM', 'DUMP_SLIDE', errmsg=>sqlerrm, extdet=>null);
end dump_slide;

procedure calc_slide( surl varchar2,c2rec in slide_master%ROWTYPE, c3rec in slide_details%ROWTYPE, l_output in out utl_file.file_type, sldtype in varchar2, p1_k in varchar2 )
as
begin

      if sldtype = 'm'
       then
        utl_file.put_line( l_output,htf.tablerowopen);
       else
        utl_file.put_line( l_output,'<TD valign="MIDDLE" ALIGN="CENTER">');
        utl_file.put_line( l_output,htf.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=0'));
        utl_file.put_line( l_output,htf.tablerowopen);
      end if;

      if c3rec.slide_type = 1
       then
         dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_1,1,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
       elsif c3rec.slide_type = 2
        then
         dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_1,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
         utl_file.put_line( l_output,htf.tablerowclose);
         utl_file.put_line( l_output,htf.tablerowopen);
         dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_2,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
       elsif c3rec.slide_type = 3
        then
         dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_1,1,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
         dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_2,1,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
       elsif c3rec.slide_type = 4
        then
         dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_1,1,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
         utl_file.put_line( l_output,'<TD>');
         utl_file.put_line( l_output,htf.tableopen);
          utl_file.put_line( l_output,htf.tablerowopen);
           dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_2,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
          utl_file.put_line( l_output,htf.tablerowclose);
          utl_file.put_line( l_output,htf.tablerowopen);
           dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_3,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
          utl_file.put_line( l_output,htf.tablerowclose);
         utl_file.put_line( l_output,htf.tableclose);
         utl_file.put_line( l_output,'</TD>');
       elsif c3rec.slide_type = 5
        then
         utl_file.put_line( l_output,'<TD>');
          utl_file.put_line( l_output,htf.tableopen);
           utl_file.put_line( l_output,htf.tablerowopen);
            dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_1,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
           utl_file.put_line( l_output,htf.tablerowclose);
           utl_file.put_line( l_output,htf.tablerowopen);
            dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_2,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
           utl_file.put_line( l_output,htf.tablerowclose);
          utl_file.put_line( l_output,htf.tableclose);
          utl_file.put_line( l_output,'</TD>');
           dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_3,1,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
       elsif c3rec.slide_type = 6
        then
          dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_1,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
          dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_2,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
         utl_file.put_line( l_output,htf.tablerowclose);
         utl_file.put_line( l_output,htf.tablerowopen);
          dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_3,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
          dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_4,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
       elsif c3rec.slide_type = 7
        then
         dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_1,1,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
         utl_file.put_line( l_output,'<TD>');
         utl_file.put_line( l_output,htf.tableopen);
          utl_file.put_line( l_output,htf.tablerowopen);
           dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_2,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
          utl_file.put_line( l_output,htf.tablerowclose);
          utl_file.put_line( l_output,htf.tablerowopen);
           dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_3,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
          utl_file.put_line( l_output,htf.tablerowclose);
         utl_file.put_line( l_output,htf.tableclose);
         utl_file.put_line( l_output,'</TD>');
         dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_4,1,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
       elsif c3rec.slide_type = 8
        then
          utl_file.put_line( l_output,'&nbsp;');
          utl_file.put_line( l_output,'&nbsp;');
          dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_1,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
         utl_file.put_line( l_output,htf.tablerowclose);
         utl_file.put_line( l_output,htf.tablerowopen);
          utl_file.put_line( l_output,'&nbsp;');
          dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_2,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
          utl_file.put_line( l_output,'&nbsp;');
         utl_file.put_line( l_output,htf.tablerowclose);
         utl_file.put_line( l_output,htf.tablerowopen);
          dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_3,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
          utl_file.put_line( l_output,'&nbsp;');
          utl_file.put_line( l_output,'&nbsp;');
       elsif c3rec.slide_type = 9
        then
          dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_1,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
          dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_2,1,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
          dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_3,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
       elsif c3rec.slide_type = '0'
        then
          utl_file.put_line( l_output,'&nbsp;');
          dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_1,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
          utl_file.put_line( l_output,'&nbsp;');
         utl_file.put_line( l_output,htf.tablerowclose);
         utl_file.put_line( l_output,htf.tablerowopen);
          dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_2,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
          utl_file.put_line( l_output,'&nbsp;');
          dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_3,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
         utl_file.put_line( l_output,htf.tablerowclose);
         utl_file.put_line( l_output,htf.tablerowopen);
          utl_file.put_line( l_output,'&nbsp;');
          dump_slide(surl,l_output,c2rec,c3rec,c3rec.phid_4,2,sldtype,dumpurl=>'s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm');
          utl_file.put_line( l_output,'&nbsp;');
       end if;

       if sldtype = 't'
        then
         utl_file.put_line( l_output,htf.tablerowclose);
         utl_file.put_line( l_output,htf.tableclose);
         utl_file.put_line( l_output,htf.nl);
         utl_file.put_line( l_output,htf.anchor('s' || p1_k || to_char(c3rec.slide_nmbr) || '.htm',htf.bold( c3rec.slide_nmbr || ': ' || c3rec.slide_title) ));
         utl_file.put_line( l_output,'</TD>');
        else
         utl_file.put_line( l_output,htf.tablerowclose);
       end if;
exception when others then
 glbx.error_details( 'ADM', 'CALC_SLIDE', errmsg=>sqlerrm, extdet=>null);
 end calc_slide;

procedure admin_accounts( surl varchar2,msg in varchar2 default null )
as
 cursor c1 is select * from admin_acct order by acct_name;
 -- cursor c2 is select admin_pw_attempts,password_attempts,password_expires from master_piction;

 -- c2rec	c2%ROWTYPE;
 tmp	varchar2(2000);
 sessid	integer;
 sts	varchar2(200);
 admin_pw_att	varchar2(100);
 password_att	varchar2(100);
 password_exp	varchar2(100);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ADMIN_ACCOUNTS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_636, helpid=>'A58' );
 if msg is not null then glbx.header_msg( msg ); end if;
-- open c2;
-- fetch c2 into c2rec;
-- close c2;
 admin_pw_att := glbx.extract_master_parameter('ADMIN_PW_ATTEMPTS');
 password_att := glbx.extract_master_parameter('PASSWORD_ATTEMPTS');
 password_exp := glbx.extract_master_parameter('PASSWORD_EXPIRES');

 htp.p('<CENTER>');
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.GLB_TXT_076),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_635),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_711),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_702),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.anchor( 'adm.change_password?surl=' || glbx.rndsurl(surl) || '&acct=0',DECS.ADMIN_USERNAME),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;', cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( htf.bold(nvl(admin_pw_att,'0')) || '/' || nvl(password_att,'0'), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( htf.bold(nvl(password_exp,'&nbsp;')), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( htf.anchor( 'adm.del_admin?surl=' || glbx.rndsurl(surl) || '&acct=0&typ=RESET',LNG3.ADM_TXT_710),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
  for c1rec in c1 loop
    htp.tablerowopen;
     htp.tabledata( htf.anchor( 'adm.change_password?surl=' || glbx.rndsurl(surl) || '&acct=' || c1rec.acct_id,c1rec.acct_name),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( htf.bold(nvl(c1rec.acct_role,'&nbsp;')), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( htf.bold(nvl(to_char(c1rec.failed_logins),'0')) || '/' || nvl(password_att,'0'), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( htf.bold(nvl(to_char(c1rec.password_expires,LNG.MASK),'&nbsp;')), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( htf.anchor( 'adm.del_admin?surl=' || glbx.rndsurl(surl) || '&acct=' || c1rec.acct_id,LNG3.ADM_TXT_649) || htf.nl ||
                    htf.anchor( 'adm.del_admin?surl=' || glbx.rndsurl(surl) || '&acct=' || c1rec.acct_id || '&typ=RESET',LNG3.ADM_TXT_710),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.anchor( 'adm.change_password?surl=' || glbx.rndsurl(surl) || '&acct=', LNG3.ADM_TXT_648);
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ACCOUNTS', errmsg=>sqlerrm, extdet=>null);
end admin_accounts;

procedure change_password( surl varchar2, acct in integer, msg in varchar2 default null )
as

 cursor c1(acct integer) is select * from admin_acct where acct_id = acct;
 cursor c2 is select distinct role_name from admin_roles order by role_name;

 cursor r0n( rname varchar2, rtype varchar2, rnmb integer ) is
  select 'x' ex
  from admin_restrict
  where role_name = rname and
        restrict_type = rtype and
        unique_id = rnmb;
 cursor r0v( rname varchar2, rtype varchar2, rval varchar2 ) is
  select 'x'  ex
  from admin_restrict
  where role_name = rname and
        restrict_type = rtype and
        unique_name = rval;

 cursor r1 is select theme_type from theme_types order by theme_type;
 cursor r2 is select theme_name from theme order by theme_name;
 cursor r3 is select id,plan_name from charge_plan order by plan_name;
 cursor r4 is select scene_name from scene order by scene_name;
 cursor r5 is select pid,business_name from photographer order by business_name;
 cursor r6 is select manufacturer_id,name from manufacturer order by name;


 c1rec	c1%ROWTYPE;
 rrec	r0v%ROWTYPE;
 tmp	varchar2(2000);
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.CHANGE_PASSWORD');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if acct = 0
  then
   c1rec.acct_id := 0;
   c1rec.acct_name := DECS.ADMIN_USERNAME;
   c1rec.acct_role := NULL;
   c1rec.password_expires := glbx.extract_master_parameter('PASSWORD_EXPIRES');
   c1rec.failed_logins := glbx.extract_master_parameter('ADMIN_PW_ATTEMPTS');
  else
   open c1(acct);
   fetch c1 into c1rec;
   close c1;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_652 || ' : ' || c1rec.acct_name, helpid=>'A56' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p('<CENTER>');
 htp.nl;
 htp.formopen( 'adm.accept_change_password' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.formhidden( 'ACCT', c1rec.acct_id );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.GLB_TXT_076 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if acct is null
      then
       htp.tabledata(htf.formtext( 'P0',30, 100 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.bold( c1rec.acct_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  -- Only ADMIN can change other people's password without having to know them
  if sessid = 0
   then
    htp.formhidden( 'P1', null );
   else
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.GLB_TXT_117 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formpassword('P1',40, 100, null ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
  end if;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_020 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formpassword('P2',40, 100, null ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.GLB_TXT_105 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formpassword('P3',40, 100, null ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_702 ) || '-' || htf.italic(LNG.MASK),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P5',20, 40, to_char(c1rec.password_expires,LNG.MASK) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_704 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P6',10, 10, c1rec.failed_logins ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  if acct = 0
   then
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_635 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'P4', null );
    htp.tablerowclose;
   else
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_635 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.formselectopen( 'P4' );
     htp.formselectoption( NULL );
     for c2rec in c2 loop
      if c2rec.role_name = c1rec.acct_role
       then
        htp.formselectoption( c2rec.role_name, 'SELECTED' );
       else
        htp.formselectoption( c2rec.role_name );
      end if;
     end loop;
     htp.formselectclose;
     htp.p( '<TD>' );
    htp.tablerowclose;
  end if;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_652 );
 htp.formclose;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'CHANGE_PASSWORD', errmsg=>sqlerrm, extdet=>null);
end change_password;

procedure accept_change_password( surl varchar2,acct in varchar2, p0 in varchar2 default null, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2 default 'F')
as
 --cursor c1 is select parm_value admin_pw from master_piction;
 cursor c2(acct integer) is select admin_pw from admin_acct where acct_id = acct;
 cursor c3(usr varchar2) is select 'x' from admin_acct where acct_name = usr;
 cursor c4 is select nvl(max(acct_id),0) + 1 from admin_acct;

 --c1rec	c1%ROWTYPE;

 sessid		integer;
 sts		varchar2(200);
 newpw		varchar2(100);
 tmp		char(1);
 nmb		integer;
 nmb2		integer;
 dt		date;
 admin_pw	varchar2(100);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_CHANGE_PASSWORD');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if acct = '0'
  then
   --open c1;
   --fetch c1 into c1rec;
   --close c1;
   admin_pw := glbx.extract_master_parameter('ADMIN_PW');
  else
   open c2( acct );
   fetch c2 into admin_pw;
   close c2;
 end if;

 begin dt := to_date(p5,LNG.MASK); exception when others then dt := NULL; end;
 begin nmb2 := to_number(p6); exception when others then nmb2 := null; end;

 if (p2 is null and p3 is not null) or (p2 is not null and p3 is null)
  then
   change_password( surl,acct, LNG3.ADM_TXT_540 );
   return;
 end if;

 if (p1 is null) and (sessid <> '0')
  then
   change_password( surl,acct, LNG3.ADM_TXT_540 );
   return;
 end if;

 if (p2 is null) or (p3 is null)
  then
   if acct = '0'
    then
      update master_parameters
       set
        parm_value = to_char(dt,LNG.MASK)
      where
        parm_name = 'PASSWORD_EXPIRES';
      insert into audit_master_parameters(parm_name,date_updated,old_value,new_value,sessid) values ( 'PASSWORD_EXPIRES', sysdate, null, to_char(dt,LNG.MASK), sessid );
      update master_parameters
       set
        parm_value = to_char(nmb2)
      where
        parm_name = 'ADMIN_PW_ATTEMPTS';
      insert into audit_master_parameters(parm_name,date_updated,old_value,new_value,sessid) values ( 'ADMIN_PW_ATTEMPTS', sysdate, null, to_char(nmb2), sessid );

    else
      update admin_acct
       set
        acct_role = p4,
        failed_logins = nmb2,
        password_expires = dt,
        restrict_access = p7
       where
        acct_id = to_number(acct);
   end if;
   commit;
   change_password( surl,acct, LNG3.ADM_TXT_544 );
   return;
 end if;

 -- If the account is not ADMIN then check to see if the know the correct password
 if sessid <> '0'
  then
   if glbx.encrypt(upper(p1),special_key=>DECS.ADMIN_ENCRYPT_KEY) <> admin_pw
    then
     change_password( surl,acct, LNG3.ADM_TXT_542 );
     return;
   end if;
 end if;

 if upper(p2) <> upper(p3)
  then
   change_password( surl,acct, LNG3.ADM_TXT_543 );
   return;
 end if;

 newpw := glbx.encrypt( upper( p2 ),special_key=>DECS.ADMIN_ENCRYPT_KEY);
 if acct = '0'
  then
  update master_parameters set parm_value = newpw where parm_name = 'ADMIN_PW';
  insert into audit_master_parameters(parm_name,date_updated,old_value,new_value,sessid) values ( 'ADMIN_PW', sysdate, null, newpw, sessid );
  update master_parameters set parm_value = to_char(dt,LNG.MASK) where parm_name = 'PASSWORD_EXPIRES';
  insert into audit_master_parameters(parm_name,date_updated,old_value,new_value,sessid) values ( 'PASSWORD_EXPIRES', sysdate, null, to_char(dt,LNG.MASK), sessid );
  update master_parameters set parm_value = to_char(nmb2) where parm_name = 'ADMIN_PW_ATTEMPTS';
  insert into audit_master_parameters(parm_name,date_updated,old_value,new_value,sessid) values ( 'ADMIN_PW_ATTEMPTS', sysdate, null, to_char(nmb2), sessid );

  else
   if acct is null
    then
     if p0 is null
      then
       change_password( surl,acct, LNG3.ADM_TXT_650 );
       return;
     end if;
     if upper(p0) = DECS.ADMIN_USERNAME
      then
       change_password( surl,acct, LNG3.ADM_TXT_651 || ' ' || DECS.ADMIN_USERNAME);
       return;
     end if;
     open c3(upper(p0));
     fetch c3 into tmp;
     if c3%FOUND
      then
       close c3;
       change_password( surl,acct, LNG3.ADM_TXT_651 || ' ' || upper(p0));
       return;
     end if;
     open c4;
     fetch c4 into nmb;
     close c4;
     insert into admin_acct(acct_id,acct_name,admin_pw,acct_role,password_expires,failed_logins,restrict_access) values (nmb,upper(p0),newpw,p4,dt,nmb2,p7);
   else
    nmb := NULL;
    update admin_acct
     set
      admin_pw = newpw,
      acct_role = p4,
      failed_logins = nmb2,
      password_expires = dt,
      restrict_access = p7
     where
      acct_id = to_number(acct);
   end if;
 end if;
 commit;
 change_password( surl, nvl(nmb,acct), LNG3.ADM_TXT_544 );
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_CHANGE_PASSWORD', errmsg=>sqlerrm, extdet=>null);
end accept_change_password;

procedure meta_tags( surl varchar2, msg in varchar2 default null )
as

 cursor c1(ttype varchar2) is select * from umo_attributes where user_defined = ttype order by umo_type,category,sub_category,attribute_id;
 cursor c1a(ttype varchar2) is select distinct umo_type from umo_attributes where user_defined = ttype;
 cursor c1b(ttype varchar2, utype varchar2) is select distinct category from umo_attributes where user_defined = ttype and umo_type = utype;
 cursor c1c(ttype varchar2, utype varchar2, ucat in varchar2) is select * from umo_attributes where user_defined = ttype and umo_type = utype and category = ucat order by sub_category,attribute_id;
 cursor c2 is
  select 'PHOTO' umo_type from dual union all
  select 'DOCUMENT' umo_type from dual union all
  select 'AUDIO' umo_type from dual union all
  select 'VIDEO' umo_type from dual union all
  select 'RELATIONAL' umo_type from dual union all
  select 'BLUEPRINT' umo_type from dual union all
  select 'ALL' umo_type from dual;
 cursor c3 is select theme_type from theme_types order by theme_type;

 tmp	varchar2(2000);
 tmp2	varchar2(32767);
 sessid	integer;
 sts	varchar2(200);
 lastgr	varchar2(100);
 lastct	varchar2(100);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.META_TAGS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_551, helpid=>'A57' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p('<CENTER>');
 htp.nl;
 htp.anchor( 'adm.meta_tag_exception?surl=' || glbx.rndsurl(surl), LNG3.ADM_TXT_734 );
 htp.nl;
 htp.nl;
 htp.header(3, LNG3.ADM_TXT_723, 'CENTER' );
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
 htp.tablerowopen;
 htp.p( '<TD ALIGN="LEFT">' );
 htp.ulistopen;
 lastgr := NULL;
 lastct := NULL;
  for c1arec in c1a('T') loop
   htp.listitem( c1arec.umo_type );
   htp.ulistopen;
    for c1brec in c1b('T',c1arec.umo_type) loop
    htp.listitem( c1brec.category );
    htp.ulistopen;
     for c1crec in c1c('T',c1arec.umo_type,c1brec.category) loop
      if c1crec.business_feature is null
       then
        htp.listitem( htf.anchor2( 'adm.metatg?surl=' || surl || '&id=' || c1crec.attribute_id, c1crec.sub_category, ctarget=>new_window ));
       else
        htp.listitem( htf.anchor2( 'adm.metatg?surl=' || surl || '&id=' || c1crec.attribute_id, c1crec.sub_category, ctarget=>new_window ) || ' (' || c1crec.business_feature || ')');
      end if;
     end loop;
    htp.ulistclose;
    end loop;
   htp.ulistclose;
  end loop;
 htp.ulistclose;
 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formopen( 'adm.accept_meta_tags' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));

 htp.bold( LNG3.ADM_TXT_795 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
      htp.tabledata(htf.bold( LNG3.ADM_TXT_552 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG.PHG_TXT_129 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG.CST_TXT_042 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_957 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_716 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_555 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_556 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_379 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_874 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_873 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_717 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_557 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_733 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 for j in 1..5 loop
   htp.tablerowopen;
    htp.formhidden( 'P1', '0' );
    tmp := htf.formselectopen( 'P2' ) || htf.formselectoption( NULL );
    for c2rec in c2 loop
      tmp := tmp || htf.formselectoption( c2rec.umo_type );
    end loop;
    tmp := tmp || htf.formselectclose;
    tmp2 := htf.formselectopen( 'P2A' ) || htf.formselectoption( NULL );
    for c3rec in c3 loop
      tmp2 := tmp2 || htf.formselectoption( c3rec.theme_type );
    end loop;
    tmp2 := tmp2 || htf.formselectclose;
    htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata(tmp2,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata(htf.formtext( 'P3', 20, 100, null),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata(htf.formtext( 'P4', 20, 100, null),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata(htf.formselectopen( 'P9' ) || htf.formselectoption( 'T', 'SELECTED' ) || htf.formselectoption( 'F' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata(htf.formselectopen( 'P5' ) || htf.formselectoption( 'T', 'SELECTED' ) || htf.formselectoption( 'F' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata(htf.formselectopen( 'P6' ) || htf.formselectoption( 'T', 'SELECTED' ) || htf.formselectoption( 'F' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata(htf.formselectopen( 'P8' ) || htf.formselectoption( 'T', 'SELECTED' ) || htf.formselectoption( 'F' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata(htf.formselectopen( 'P8A' ) || htf.formselectoption( 'T', 'SELECTED' ) || htf.formselectoption( 'F' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata(htf.formselectopen( 'P8H' ) || htf.formselectoption( 'T' ) || htf.formselectoption( 'F', 'SELECTED' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata(htf.formselectopen( 'P10' ) || htf.formselectoption( LNG3.ADM_TXT_718, 'SELECTED' ) || htf.formselectoption( LNG3.ADM_TXT_576 ) ||
                                                 htf.formselectoption( LNG3.ADM_TXT_719 ) || htf.formselectoption( LNG3.ADM_TXT_720 ) ||
                                                 htf.formselectoption( LNG3.ADM_TXT_721 ) || htf.formselectoption( LNG3.ADM_TXT_722 ) ||
                                                 htf.formselectoption( LNG3.ADM_TXT_583 ) || htf.formselectoption( LNG3.ADM_TXT_612 ) || htf.formselectoption( LNG.CST_TXT_038 ) ||
                                                 htf.formselectoption( LNG3.ADM_TXT_872 ) || htf.formselectoption( LNG3.ADM_TXT_862 )  || htf.formselectoption( 'Boolean' ) || htf.formselectoption( 'Thesaurus' ) ||
                                                 htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata(htf.formtext( 'P7', 10, 10, '1000'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata(htf.formtext( 'P11', 20, 4000 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
 end loop;

 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_558 );
 htp.formclose;
 htp.nl;
  htp.nl;
  htp.header(3, LNG3.ADM_TXT_724, 'CENTER' );

  htp.tableopen( cattributes=>'cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
   htp.tablerowopen;
      htp.tabledata(htf.bold( LNG3.ADM_TXT_552 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG.CST_TXT_042 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_957 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_716 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_555 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_556 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_379 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_717 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_557 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG3.ADM_TXT_733 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   for c1rec in c1('F') loop
    htp.tablerowopen;
     htp.tabledata(c1rec.umo_type,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.category,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.sub_category,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.queryable,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.mandatory,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.editeable,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.displayed,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.edit_type,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(to_char(c1rec.maxlength),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.lov_list,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   end loop;
  htp.tableclose;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'META_TAGS', errmsg=>sqlerrm, extdet=>null);
end meta_tags;

procedure accept_meta_tags( surl varchar2, p1 in MYARRAY, p2 in MYARRAY, p2a in MYARRAY, p3 in MYARRAY, p4 in MYARRAY, p5 in MYARRAY, p6 in MYARRAY, p7 in MYARRAY, p8 in MYARRAY, p8a in MYARRAY, p8h in MYARRAY, p9 in MYARRAY, p10 in MYARRAY, p11 in MYARRAY )
as

 cursor c2(utype varchar2) is select umo_id, aid from umo um where umo_type = utype;
 cursor c2a(utype varchar2, bf varchar2) is
  select um.umo_id, um.aid
  from umo um, customer_account ca
  where umo_type = utype and
        ca.theme_type = bf and
        ca.aid = um.aid;
 cursor c3(tagname varchar2, utype varchar2) is select 'x' exst from umo_attributes where sub_category = tagname and umo_type = utype;

 c3rec	c3%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);
 newpw	varchar2(100);
 nmb	integer;
 newval	integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_META_TAGS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 for j in p1.first..p1.last loop
  begin nmb := to_number( p7(j) ); exception when others then nmb := 1000; end;
  if nmb < 1 or nmb > 1000 then nmb := 1000; end if;
  if p1(j) = '0'
   then
    if p2(j) is null or p3(j) is null or p4(j) is null
     then
      null; -- Do Nothing
     else
      open c3(upper(p4(j)),p2(j));
      fetch c3 into c3rec;
      if c3%FOUND
       then
        close c3;
        commit;
        meta_tags( surl, p4(j) || ' ' || LNG2.PBK_TXT_043 );
        exit;
      end if;
      close c3;
      select s_umo_attributes.nextval into newval from dual;
      insert into umo_attributes(attribute_id,umo_type,category,sub_category,mandatory,editeable,maxlength,displayed,queryable,edit_type,user_defined,lov_list,disp_phg,business_feature,cust_hor) values
       (newval, p2(j), upper(p3(j)), upper(p4(j)),p5(j),p6(j),nmb,p8(j),p9(j),p10(j),'T',p11(j),p8a(j),p2a(j),p8h(j));
      if p2a(j) is null
       then
        for c2rec in c2(p2(j)) loop
          insert into umo_attribute(umo_id,attribute_id,date_made,position_id,value) values
              (c2rec.umo_id,newval,sysdate,1,null);
        end loop;
       else
        for c2rec in c2a(p2(j),p2a(j)) loop
          insert into umo_attribute(umo_id,attribute_id,date_made,position_id,value) values
              (c2rec.umo_id,newval,sysdate,1,null);
        end loop;
      end if;
    end if;
  end if;
 end loop;

 commit;
 meta_tags( surl,LNG3.ADM_TXT_559 );
exception when others then
 rollback;
 glbx.error_details( 'ADM', 'ACCEPT_META_TAGS', errmsg=>sqlerrm, extdet=>null);
end accept_meta_tags;

procedure ftp_sites(surl varchar2, msg in varchar2 default null )
as

 cursor c1 is select * from ftp_sites order by virtual_directory;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.FTP_SITES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_593, helpid=>'A78' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.header(4, LNG3.ADM_TXT_593, 'CENTER' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_ftp_sites' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( LNG4.AHC_TXT_444, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG3.ADM_TXT_595, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  -- xxx for language file
  htp.tableheader( 'Actual Location', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   if c1rec.site_type = 'F'
    then
     htp.tabledata( htf.formselectopen( 'P3' ) || htf.formselectoption( LNG3.ADM_TXT_600, 'SELECTED', cattributes=>'VALUE="F"' ) || htf.formselectoption( LNG4.AHC_TXT_445, cattributes=>'VALUE="R"' ) || htf.formselectclose, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
    else
     htp.tabledata( htf.formselectopen( 'P3' ) || htf.formselectoption( LNG3.ADM_TXT_600, cattributes=>'VALUE="F"' ) || htf.formselectoption( LNG4.AHC_TXT_445, 'SELECETED', cattributes=>'VALUE="R"' ) || htf.formselectclose, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   end if;
   htp.tabledata( htf.formtext( 'P1', 40, 1000, replace(c1rec.virtual_directory,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.formhidden( 'P2', c1rec.virtual_directory );
   htp.tabledata( htf.formtext( 'P4', 40, 1000, replace(c1rec.actual_location,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
  htp.tablerowclose;
 end loop;
 for j in 1..10 loop
  htp.tablerowopen;
   htp.tabledata( htf.formselectopen( 'P3' ) || htf.formselectoption( LNG3.ADM_TXT_600, cattributes=>'VALUE="F"' ) || htf.formselectoption( LNG4.AHC_TXT_445, cattributes=>'VALUE="R"' ) || htf.formselectclose, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( htf.formtext( 'P1', 40, 1000 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( htf.formtext( 'P4', 40, 1000 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.formhidden( 'P2', NULL );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null,LNG3.ADM_TXT_596 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'FTP_SITES', errmsg=>sqlerrm, extdet=>null);
end ftp_sites;

procedure accept_ftp_sites( surl varchar2, p1 in MYARRAY, p2 in MYARRAY, p3 in MYARRAY, p4 in MYARRAY )
as

 sessid		integer;
 sts		varchar2(200);
 sid		integer;
 newj		varchar2(1000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_FTP_SITES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 for j in p1.first..p1.last loop
 if p4(j) is null
  then
   newj := NULL;
  else
   if substr(p4(j),length(p4(j)),1) in ('/','\')
    then
     newj := p4(j);
    else
     newj := p4(j) || DECS.UNIX_OR_NT;
   end if;
 end if;
 if p1(j) is not null and p2(j) is null
  then
    insert into ftp_sites(site_type,virtual_directory,actual_location) values (p3(j),p1(j),newj);
 elsif p1(j) is not null and p2(j) is not null
  then
   update ftp_sites set virtual_directory = p1(j),site_type=p3(j),actual_location=newj where virtual_directory = p2(j);
   update ftp_sites_phg set virtual_directory = p1(j) where virtual_directory = p2(j);
   update umo set ftp_virtual_dir = p1(j) where ftp_virtual_dir = p2(j);
 elsif p1(j) is null and p2(j) is not null
  then
   delete from ftp_sites where virtual_directory = p2(j);
   delete from ftp_sites_phg where virtual_directory = p2(j);
   update umo set ftp_virtual_dir = NULL where ftp_virtual_dir = p2(j);
  end if;
 end loop;
 commit;
 ftp_sites( surl,LNG3.ADM_TXT_518 );
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_FTP_SITES', errmsg=>sqlerrm, extdet=>null);
end accept_ftp_sites;

procedure admin_roles(surl varchar2,msg in varchar2 default null )
as

 cursor c1 is select distinct role_name from admin_roles order by role_name;
 cursor c2(arole varchar2) is select acct_name from admin_acct where acct_role = arole order by acct_name;

 sessid		integer;
 tmp		varchar2(4000);
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ADMIN_ROLES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_637, helpid=>'A59' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.anchor( 'adm.admin_roles_edit?surl=' || glbx.rndsurl(surl) || '&rname=', LNG3.ADM_TXT_640 );
 htp.nl;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata(htf.anchor( 'adm.admin_roles_edit?surl=' || glbx.rndsurl(surl) || '&rname=' || translate( c1rec.role_name,' ','+'), c1rec.role_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   tmp := NULL;
   for c2rec in c2(c1rec.role_name) loop
    tmp := tmp || ',' || c2rec.acct_name;
   end loop;
   if tmp is null
    then
     htp.tabledata(htf.anchor( 'adm.delete_role?surl=' || glbx.rndsurl(surl) || '&rname=' || translate( c1rec.role_name,' ','+'), LNG3.ADM_TXT_654 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    else
     htp.tabledata(htf.bold(substr(tmp,2)),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   end if;
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null,LNG3.ADM_TXT_596 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ROLES', errmsg=>sqlerrm, extdet=>null);
end admin_roles;

procedure admin_roles_edit(surl varchar2,rname in varchar2, msg in varchar2 default null )
as

 cursor c1 is select * from admin_roles where role_name = rname order by top_menu,menu_item;
 cursor c2( mname varchar2 ) is
  select top_menu, menu_item
  from admin_menu_items
  where menu_call not in (select disabled_item from piction_module where module_type = 'MENU' and module_name = mname)
  order by top_order, order_id;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;
 mname		varchar2(100);
 tmp		varchar2(4000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ADMIN_ROLES_EDIT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_637 || ' : ' || rname, helpid=>'A59' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 mname := nvl( glbx.extract_master_parameter('PICTION_MODULE'), 'Enterprise');
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_admin_roles' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 if rname is null
  then
   htp.p( htf.bold( LNG3.ADM_TXT_635 ) || ' ' || htf.formtext( 'RNAME', 30, 100 ) );
  else
   htp.formhidden( 'RNAME', rname );
 end if;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( '[' || LNG3.ADM_TXT_638 || '] ' || LNG3.ADM_TXT_639, cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
 htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   tmp := htf.formselectopen( 'P1' ) || htf.formselectoption( NULL );
   for c2rec in c2( mname ) loop
    if (c2rec.top_menu = c1rec.top_menu) and (c2rec.menu_item = c1rec.menu_item)
     then
      tmp := tmp || htf.formselectoption( '[' || c2rec.top_menu || '] ' || c2rec.menu_item, 'SELECTED' );
     else
      tmp := tmp || htf.formselectoption( '[' || c2rec.top_menu || '] ' || c2rec.menu_item );
    end if;
   end loop;
   htp.tabledata( tmp || htf.formselectclose, cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;
 end loop;
 tmp := htf.formselectopen( 'P1' ) || htf.formselectoption( NULL );
 for c2rec in c2( mname ) loop
  tmp := tmp || htf.formselectoption( '[' || c2rec.top_menu || '] ' || c2rec.menu_item );
 end loop;
 tmp := tmp || htf.formselectclose;
 for j in 1..30 loop
  htp.tablerowopen;
   htp.tabledata( tmp, cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_641 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception
 when others then
  glbx.error_details( 'ADM', 'ROLES_EDIT', errmsg=>sqlerrm, extdet=>null);
end admin_roles_edit;

procedure accept_admin_roles( surl varchar2,rname in varchar2, p1 in MYARRAY )
as

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_ADMIN_ROLES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if rname is null
  then
   admin_roles_edit(surl,rname,LNG3.ADM_TXT_647);
   return;
 end if;
 delete from admin_roles where role_name = rname;
 for j in p1.first..p1.last loop
 if p1(j) is not null
  then
    insert into admin_roles(role_name,top_menu,menu_item) values (rname,substr(p1(j),2,instr(p1(j),']')-2),substr(p1(j),instr(p1(j),']')+2));
  end if;
 end loop;
 commit;
 admin_roles_edit( surl,rname, LNG3.ADM_TXT_642 );
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_ADMIN_ROLES', errmsg=>sqlerrm, extdet=>null);
end accept_admin_roles;

procedure del_admin( surl varchar2,acct in varchar2, typ in varchar2 default 'DELETE' )
as

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.DEL_ADMIN');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if typ = 'DELETE'
  then
   delete from admin_acct where acct_id = to_number(acct);
  else
   if acct = 0
    then
     /* update master_piction set admin_pw_attempts = 0; */
      update master_parameters
       set
        parm_value = '0'
      where
        parm_name = 'ADMIN_PW_ATTEMPTS';
      insert into audit_master_parameters(parm_name,date_updated,old_value,new_value,sessid) values ( 'ADMIN_PW_ATTEMPTS', sysdate, null, '0', sessid );
    else
     update admin_acct set failed_logins = 0 where acct_id = to_number(acct);
   end if;
 end if;
 commit;
 admin_accounts( surl,LNG3.ADM_TXT_653 );

exception when others then
 glbx.error_details( 'ADM', 'DEL_ADMIN', errmsg=>sqlerrm, extdet=>'ACCT:' || acct);
end del_admin;

procedure delete_role( surl varchar2,rname in varchar2 )
as

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.DELETE_ROLE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 delete from admin_roles where role_name = rname and not exists (select 'x' from admin_acct where acct_role = rname );

 commit;
 admin_roles( surl,LNG3.ADM_TXT_655);

exception when others then
 glbx.error_details( 'ADM', 'DELETE_ROLE', errmsg=>sqlerrm, extdet=>'RNAME:' || rname);
end delete_role;

procedure audit_drill_ls(surl varchar2,msg in varchar2 default null, drilldate in varchar2 default 'YEAR', drillclient in varchar2 default 'ALL', vdrillclient in varchar2 default null, drillfrom in varchar2 default null, drillto in varchar2 default null, incpurch in varchar2 default 'F', incbar in varchar2 default 'T', aact in varchar2 default 'F' )
as

 TYPE 		EmpCurTyp IS REF CURSOR;
 emp_cv   	EmpCurTyp;

 sessid		integer;
 sts		varchar2(200);
 dfrom		date;
 dto		date;
 v1		varchar2(100);
 v2		varchar2(100);
 v3		integer;
 v4		integer;
 va		varchar2(1000);
 vb		integer;
 vc		varchar2(1000);
 vd		varchar2(1000);
 stmt		varchar2(4000);
 gby		varchar2(1000);
 ctr		integer;
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.AUDIT_DRILL_LS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_673, helpid=>'A60' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.header(3,LNG3.ADM_TXT_259,'CENTER' );
 if drillfrom is null then dfrom := add_months(sysdate,-12); else dfrom := to_date(drillfrom,'YYYY-MON-DD-HH24:MI'); end if;
 if drillto is null then dto := sysdate; else dto := to_date(drillto,'YYYY-MON-DD-HH24:MI'); end if;
 htp.bold( LNG3.ADM_TXT_260 || ': ' || initcap(drilldate) ); htp.nl;
 htp.bold( LNG3.ADM_TXT_261 || ': ' || initcap(drillclient) ); htp.nl;
 htp.bold( LNG3.ADM_TXT_262 || ': ' || to_char(dfrom,'DD Month YYYY HH24:MI') ); htp.nl;
 htp.bold( LNG3.ADM_TXT_263 || ': ' || to_char(dto,'DD Month YYYY HH24:MI') ); htp.nl;
 htp.nl;
 htp.tableopen(cattributes=>'cellspacing=2 cellpadding=2 border=1');
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_264 ));
   htp.tabledata( htf.bold( LNG3.ADM_TXT_265 ));
   htp.tabledata( htf.bold( LNG3.ADM_TXT_266 ));
   if incpurch = 'T'
    then
     htp.tabledata( htf.bold( LNG.PHG_ALT_128 ));
   end if;
   htp.tabledata( htf.bold( LNG2.PBK_TXT_076 ));
   if incbar = 'T'
    then
     htp.tabledata( htf.bold( LNG3.ADM_TXT_269 ));
   end if;
   if drilldate = 'HOUR' and aact = 'T'
    then
     htp.tabledata( htf.bold( LNG3.ADM_TXT_783 ));
     htp.tabledata( htf.bold( LNG3.ADM_TXT_784 ));
     htp.tabledata( htf.bold( LNG3.ADM_TXT_785 ));
   end if;
  htp.tablerowclose;
  if drilldate = 'YEAR' then
   stmt := 'select to_char(ls.date_created,''YYYY'') as dt ';
   gby := 'to_char(ls.date_created,''YYYY'')';
  elsif drilldate = 'MONTH' then
   stmt := 'select to_char(ls.date_created,''YYYY-MON'') as dt';
   gby := 'to_char(ls.date_created,''YYYY-MON'')';
  elsif drilldate = 'DAY' then
   stmt := 'select to_char(ls.date_created,''YYYY-MON-DD'') as dt';
   gby := 'to_char(ls.date_created,''YYYY-MON-DD'')';
  elsif drilldate = 'HOUR' then
   if aact = 'T'
    then
     stmt := 'select to_char(ls.date_created,''YYYY-MON-DD HH24'') as dt, aaa.program_called,aaa.umo_id,aaa.display_what,to_char(aaa.date_updated,''YYYY-MON-DD HH24:MI:SS'') as dtu';
     gby := 'to_char(ls.date_created,''YYYY-MON-DD HH24''), aaa.program_called,aaa.umo_id,aaa.display_what,to_char(aaa.date_updated,''YYYY-MON-DD HH24:MI:SS'')';
    else
     stmt := 'select to_char(ls.date_created,''YYYY-MON-DD HH24'') as dt';
     gby := 'to_char(ls.date_created,''YYYY-MON-DD HH24'')';
   end if;
  end if;

  if drillclient = 'ALL' then
   stmt := stmt || ',' || 'null,null,count(''x'')';
  elsif drillclient = 'PHOTOGRAPHER' then
   stmt := stmt || ',' || 'p.business_name,p.pid,count(''x'')';
   gby := gby || ',' || 'p.business_name,p.pid';
  elsif drillclient = 'ACCOUNT' then
   stmt := stmt || ',' || 'ca.account_name,ca.aid,count(''x'')';
   gby := gby || ',' || 'ca.account_name,ca.aid';
  elsif drillclient = 'OWNER' then
   stmt := stmt || ',' || 'ca.account_name,ca.aid,count(''x'')';
   gby := gby || ',' || 'ca.account_name,ca.aid';
  elsif drillclient = 'GUEST' then
   stmt := stmt || ',' || 'ca.account_name,ca.aid,count(''x'')';
   gby := gby || ',' || 'ca.account_name,ca.aid';
  end if;

  if drilldate = 'YEAR' then
   stmt := stmt || ' from login_session ls';
  elsif drilldate = 'MONTH' then
   stmt := stmt || ' from login_session ls';
  elsif drilldate = 'DAY' then
   stmt := stmt || ' from login_session ls';
  elsif drilldate = 'HOUR' then
   if aact = 'T'
    then
     stmt := stmt || ' from audit_all_activity aaa, login_session ls';
    else
     stmt := stmt || ' from login_session ls';
   end if;
  end if;

  if drillclient = 'ALL' then
   null;
  elsif drillclient = 'PHOTOGRAPHER' then
   stmt := stmt || ',' || 'customer_account ca,photographer p';
  elsif drillclient = 'ACCOUNT' then
   stmt := stmt || ',' || 'customer_account ca';
  elsif drillclient = 'OWNER' then
   stmt := stmt || ',' || 'customer_account ca';
  elsif drillclient = 'GUEST' then
   stmt := stmt || ',' || 'customer_account ca';
  end if;

  if drilldate = 'YEAR' then
   stmt := stmt || ' where ls.date_created between :1 and :2';
  elsif drilldate = 'MONTH' then
   stmt := stmt || ' where ls.date_created between :1 and :2';
  elsif drilldate = 'DAY' then
   stmt := stmt || ' where ls.date_created between :1 and :2';
  elsif drilldate = 'HOUR' then
   if aact = 'T'
    then
     stmt := stmt || ' where ls.date_created between :1 and :2 and ls.sessid = aaa.sessid';
    else
     stmt := stmt || ' where ls.date_created between :1 and :2';
   end if;
  end if;

  if drillclient = 'ALL' then
   null;
  elsif drillclient = 'PHOTOGRAPHER' then
   stmt := stmt || ' and ca.aid = ls.aid and ca.pid = p.pid';
  elsif drillclient = 'ACCOUNT' then
   stmt := stmt || ' and ca.aid = ls.aid and ca.pid = :3';
  elsif drillclient = 'OWNER' then
   stmt := stmt || ' and ca.aid = ls.aid and ca.aid = :3 and login_type in (''OWNER'',''PROFILE'')';
  elsif drillclient = 'GUEST' then
   stmt := stmt || ' and ca.aid = ls.aid and ca.aid = :3 and login_type = (''CUSTOMER'',''PROFILEG'',''VIRTUAL'')';
  end if;

  stmt := stmt || ' group by ' || gby;

  if drilldate = 'YEAR' then
   stmt := stmt || ' order by to_date(dt,''YYYY'') desc';
  elsif drilldate = 'MONTH' then
   stmt := stmt || ' order by to_date(dt,''YYYY-MON'') desc';
  elsif drilldate = 'DAY' then
   stmt := stmt || ' order by to_date(dt,''YYYY-MON-DD'') desc';
  elsif drilldate = 'HOUR' then
   stmt := stmt || ' order by to_date(dt,''YYYY-MON-DD HH24'') desc';
  end if;

  -- htp.p( stmt ); htp.nl;

  if drillclient = 'ALL' then
   open emp_cv for stmt using dfrom,dto;
  elsif drillclient = 'PHOTOGRAPHER' then
   open emp_cv for stmt using dfrom,dto;
  elsif drillclient = 'ACCOUNT' then
   open emp_cv for stmt using dfrom,dto,to_number(vdrillclient);
  elsif drillclient = 'OWNER' then
   open emp_cv for stmt using dfrom,dto,to_number(vdrillclient);
  elsif drillclient = 'GUEST' then
   open emp_cv for stmt using dfrom,dto,to_number(vdrillclient);
  end if;

  loop
    if drilldate = 'HOUR' and aact = 'T'
     then
      FETCH emp_cv INTO v1,va,vb,vc,vd,v2,v3,v4;
     else
      FETCH emp_cv INTO v1,v2,v3,v4;
    end if;
    EXIT WHEN emp_cv%NOTFOUND;

    htp.tablerowopen;

      if drilldate = 'YEAR' then
       htp.tabledata( htf.anchor( 'adm.audit_drill_ls?surl=' || glbx.rndsurl(surl) || '&drilldate=MONTH&drillclient=' || drillclient || '&aact=' || aact || '&vdrillclient=' || v3 || '&drillfrom=' || substr(v1,1,4) || '-JAN-01-00:01&drillto=' || v1 || '-DEC-31-23:59&incpurch=' || incpurch || '&incbar=' || incbar, '[' || LNG3.ADM_TXT_667 || ']'));
      elsif drilldate = 'MONTH' then
       htp.tabledata( htf.anchor( 'adm.audit_drill_ls?surl=' || glbx.rndsurl(surl) || '&drilldate=DAY&drillclient=' || drillclient || '&aact=' || aact || '&vdrillclient=' || v3 || '&drillfrom=' || substr(v1,1,8) || '-01-00:01&drillto=' || to_char(last_day( to_date(v1,'YYYY-MON')),'YYYY-MON-DD') || '-23:59&incpurch=' || incpurch || '&incbar=' || incbar, '[' || LNG3.ADM_TXT_668 || ']'));
      elsif drilldate = 'DAY' then
       htp.tabledata( htf.anchor( 'adm.audit_drill_ls?surl=' || glbx.rndsurl(surl) || '&drilldate=HOUR&drillclient=' || drillclient || '&aact=' || aact || '&vdrillclient=' || v3 || '&drillfrom=' || substr(v1,1,11) || '-00:01&drillto=' || v1 || '-23:59&incpurch=' || incpurch || '&incbar=' || incbar, '[' || LNG3.ADM_TXT_669 || ']'));
      elsif drilldate = 'HOUR' then
       htp.tabledata( htf.anchor( 'adm.audit_drill_ls?surl=' || glbx.rndsurl(surl) || '&drilldate=DAY&drillclient=' || drillclient || '&aact=' || aact || '&vdrillclient=' || v3 || '&drillfrom=' || substr(v1,1,8) || '-01-00:01&drillto=' || to_char(last_day( to_date(v1,'YYYY-MON-DD-HH24:MI')),'YYYY-MON-DD') || '-23:59&incpurch=' || incpurch || '&incbar=' || incbar, '[' || LNG3.ADM_TXT_668 || ']'));
      end if;

     if drillclient = 'ALL' then
       htp.tabledata( htf.anchor( 'adm.audit_drill_ls?surl=' || glbx.rndsurl(surl) || '&drilldate=' || drilldate || '&aact=' || aact || '&drillclient=PHOTOGRAPHER&vdrillclient=' || vdrillclient || '&drillfrom=' || drillfrom || '&drillto=' || drillto || '&incpurch=' || incpurch || '&incbar=' || incbar, '[' || LNG3.ADM_TXT_670 || ']'));
     elsif drillclient = 'PHOTOGRAPHER' then
       htp.tabledata( htf.anchor( 'adm.audit_drill_ls?surl=' || glbx.rndsurl(surl) || '&drilldate=' || drilldate || '&aact=' || aact || '&drillclient=ACCOUNT&vdrillclient=' || to_char(v3) || '&drillfrom=' || drillfrom || '&drillto=' || drillto || '&incpurch=' || incpurch || '&incbar=' || incbar, '[' || LNG.PHG_ALT_121 || ']'));
     elsif drillclient = 'ACCOUNT' then
       htp.tabledata( htf.anchor( 'adm.audit_drill_ls?surl=' || glbx.rndsurl(surl) || '&drilldate=' || drilldate || '&aact=' || aact || drilldate || '&drillclient=OWNER&vdrillclient=' || to_char(v3) || '&drillfrom=' || drillfrom || '&drillto=' || drillto || '&incpurch=' || incpurch || '&incbar=' || incbar, '[' || LNG3.ADM_TXT_671 || ']') ||
       htf.nl ||htf.anchor( 'adm.audit_drill_ls?surl=' || glbx.rndsurl(surl) || '&drilldate=' || drilldate || '&drillclient=GUEST&vdrillclient=' || to_char(v3) || '&drillfrom=' || drillfrom || '&drillto=' || drillto || '&incpurch=' || incpurch || '&incbar=' || incbar, '[' || LNG3.ADM_TXT_672 || ']'));
     elsif drillclient = 'OWNER' then
       htp.tabledata( htf.anchor( 'adm.audit_drill_ls?surl=' || glbx.rndsurl(surl) || '&drilldate=' || drilldate || '&aact=' || aact || drilldate || '&drillclient=ACCOUNT&vdrillclient=' || to_char(v3) || '&drillfrom=' || drillfrom || '&drillto=' || drillto || '&incpurch=' || incpurch || '&incbar=' || incbar, '[' || LNG.PHG_ALT_121 || ']'));
     elsif drillclient = 'GUEST' then
       htp.tabledata( htf.anchor( 'adm.audit_drill_ls?surl=' || glbx.rndsurl(surl) || '&drilldate=' || drilldate || '&aact=' || aact || drilldate || '&drillclient=ACCOUNT&vdrillclient=' || to_char(v3) || '&drillfrom=' || drillfrom || '&drillto=' || drillto || '&incpurch=' || incpurch || '&incbar=' || incbar, '[' || LNG.PHG_ALT_121 || ']'));
     end if;
     if v2 is null
      then
       htp.tabledata( v1 );
      else
       htp.tabledata( v1 || htf.nl || v2);
     end if;
     if incpurch = 'T'
      then
       htp.tabledata( null );
     end if;
     htp.tabledata( v4 );
     if incbar = 'T'
      then
        htp.tabledata( '<HR ALIGN="LEFT" COLOR="#09334C" SIZE="5" WIDTH="' || round(v4/1000) || '">');
     end if;
     if drilldate = 'HOUR' and aact = 'T'
      then
       htp.tabledata( va );
       htp.tabledata( vb || '-' || vc );
       htp.tabledata( vd );
     end if;
    htp.tablerowclose;
  end loop;
  close emp_cv;

 htp.tableclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'AUDIT_DRILL_LS', errmsg=>sqlerrm, extdet=>stmt);
end audit_drill_ls;

procedure audit_cull( surl varchar2,msg in varchar2 default null )
as

 cursor c1 is select count('x') tot from login_session;
 cursor c2 is select count('x') tot from audit_all_activity;
 cursor c3 is select count('x') tot from audit_cprog;
 cursor c4 is select count('x') tot from email_log;

 c1rec	c1%ROWTYPE;
 c2rec  c2%ROWTYPE;
 c3rec  c3%ROWTYPE;
 c4rec  c4%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.AUDIT_CULL');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_674, helpid=>'A61' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p('<CENTER>');
 htp.nl;
 open c1;
 fetch c1 into c1rec;
 close c1;
 open c2;
 fetch c2 into c2rec;
 close c2;
 open c3;
 fetch c3 into c3rec;
 close c3;
 open c4;
 fetch c4 into c4rec;
 close c4;
 htp.formopen( 'adm.accept_audit_cull' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata( htf.bold( LNG3.ADM_TXT_675 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( LNG3.ADM_TXT_678 || ': ' || htf.bold(c1rec.tot),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( LNG3.ADM_TXT_680 || ' ' || htf.formtext( 'P1', 20, 20),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold( LNG3.ADM_TXT_676 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( LNG3.ADM_TXT_678 || ': ' || htf.bold(c2rec.tot),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( LNG3.ADM_TXT_680 || ' ' || htf.formtext( 'P2', 20, 20),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold( LNG3.ADM_TXT_677 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( LNG3.ADM_TXT_678 || ': ' || htf.bold(c3rec.tot),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( LNG3.ADM_TXT_680 || ' ' || htf.formtext( 'P3', 20, 20),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold( LNG5.EXT_TXT_193 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( LNG3.ADM_TXT_678 || ': ' || htf.bold(c4rec.tot),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( LNG3.ADM_TXT_680 || ' ' || htf.formtext( 'P4', 20, 20),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_674 );
 htp.formclose;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'AUDIT_CULL', errmsg=>sqlerrm, extdet=>null);
end audit_cull;

procedure accept_audit_cull( surl varchar2,p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2)
as

 nmb1	integer;
 nmb2	integer;
 nmb3	integer;
 nmb4	integer;
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_AUDIT_CULL');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 begin nmb1 := to_number(p1); exception when others then nmb1 := NULL; end;
 begin nmb2 := to_number(p2); exception when others then nmb2 := NULL; end;
 begin nmb3 := to_number(p3); exception when others then nmb3 := NULL; end;
 begin nmb4 := to_number(p4); exception when others then nmb3 := NULL; end;
 if nmb1 is not null
  then
   -- delete from login_session where is_connected = 'F' and date_created < (sysdate - nmb1 );
   -- removed to safeguard as culling can introduce a bug with purchase order
   null;
 end if;
 if nmb2 is not null
  then
   delete from audit_all_activity where date_updated < (sysdate - nmb1 );
 end if;
 if nmb3 is not null
  then
   delete from audit_cprog where date_modified < (sysdate - nmb1 );
 end if;
 if nmb4 is not null
  then
   delete from email_log where date_created < (sysdate - nmb1 );
 end if;

 commit;
 audit_cull(surl,LNG3.ADM_TXT_679);
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_AUDIT_CULL', errmsg=>sqlerrm, extdet=>'P1:' || p1 || ' P2:' || p2 || ' P3:' || p3);
end accept_audit_cull;

procedure restrict_ip( surl varchar2,msg in varchar2 default null )
as

 --cursor c1 is select ip_address_norestrict from master_piction;
 cursor c2 is select ip_address from track_ip_address;

 --c1rec	c1%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.RESTRICT_IP');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 --open c1;
 --fetch c1 into c1rec;
 --close c1;
 if glbx.extract_master_parameter('IP_ADDRESS_NORESTRICT') = 'TRUE'
  then
   main_title( surl, sessid, LNG3.ADM_TXT_696, helpid=>'A62' );
  else
   main_title( surl, sessid, LNG3.ADM_TXT_695, helpid=>'A62' );
 end if;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p('<CENTER>');
 htp.nl;
 htp.italic( LNG3.ADM_TXT_698 );
 htp.nl;
 htp.nl;
 htp.formopen( 'adm.accept_restrict_ip' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata( htf.bold( LNG3.ADM_TXT_697 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  for c2rec in c2 loop
   htp.tablerowopen;
     htp.tabledata( htf.formtext( 'P1', 30, 100, c2rec.ip_address ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end loop;
  for j in 1..5 loop
   htp.tablerowopen;
     htp.tabledata( htf.formtext( 'P1', 30, 100 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_699 );
 htp.formclose;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'RESTRICT_IP', errmsg=>sqlerrm, extdet=>null);
end restrict_ip;

procedure accept_restrict_ip( surl varchar2,p1 in MYARRAY )
as

 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.AUDIT_CULL');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 delete from track_ip_address;
 for j in p1.first..p1.last loop
  if p1(j) is not null
   then
    insert into track_ip_address(ip_address) values (p1(j));
  end if;
 end loop;
 commit;
 restrict_ip(surl,LNG3.ADM_TXT_700);
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_RESTRICT_IP', errmsg=>sqlerrm );
end accept_restrict_ip;

procedure meta_tag_exception( surl varchar2, id in integer default null, msg in varchar2 default null )
as

 cursor c1(attr_id integer) is select * from umo_attributes where attribute_id = attr_id;
 cursor c2(id integer) is select value,attribute_id,umo_id from umo_attribute where nvl(id,attribute_id) = attribute_id order by attribute_id,umo_id;
 cursor c3(v_umo integer) is select um.extras.film_name film_name,um.extras.photo_name photo_name from umo um where umo_id = v_umo;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 result		varchar2(1000);
 last_attr	integer;
 foundrec	boolean;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.META_TAG_EXCEPTION');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

main_title( surl, sessid, LNG3.ADM_TXT_734, helpid=>'A57' );
htp.nl;
htp.p( '<CENTER>' );
htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
     htp.tabledata( htf.bold( LNG.PHG_TXT_048 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( htf.bold( LNG.CST_TXT_132 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( htf.bold( LNG.CST_TXT_013 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( htf.bold( LNG3.ADM_TXT_552 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( htf.bold( LNG3.ADM_TXT_735 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 last_attr := 0;
 foundrec := FALSE;

 for c2rec in c2(id) loop
  result := NULL;
  if last_attr <> c2rec.attribute_id
   then
    open c1(c2rec.attribute_id);
    fetch c1 into c1rec;
    close c1;
  end if;
  glbx.validate_meta_tag( c2rec.value, c1rec, result);
  if result is not null
   then
    foundrec := TRUE;
    htp.tablerowopen;
    open c3(c2rec.umo_id);
    fetch c3 into c3rec;
    close c3;
     htp.tabledata( c2rec.umo_id,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( nvl(nvl(c3rec.film_name,c3rec.photo_name),'&nbsp;'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( nvl(c2rec.value,'&nbsp;'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '(' || c1rec.umo_type || ')' || c1rec.category || '-' || c1rec.sub_category || '[' || c1rec.edit_type || ']',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( result,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
  end if;
 end loop;
 htp.tableclose;

 if not foundrec then htp.bold( LNG3.ADM_TXT_736 ); end if;

 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'META_TAG_EXCEPTION', errmsg=>sqlerrm, extdet=>null);
end meta_tag_exception;

procedure dispord( surl varchar2, purchid in integer, clear_cc in varchar2 default 'FALSE', action in varchar2 default null)
as

 cursor c4(vpoid integer) is select card_number,card_type,card_expiry,card_name from credit_card where poid = vpoid;
 cursor c5(vpoid integer) is select * from purchase_order where poid = vpoid;

 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 options	GLBX.MYARRAY;

begin

 glbx.adm_cookie_id( surl,sessid,sts,'ADM.DISPORD');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

open c4(purchid);
fetch c4 into c4rec;
close c4;
open c5(purchid);
fetch c5 into c5rec;
close c5;

if clear_cc = 'TRUE'
 then
  update credit_card
   set
    card_number = 'Erased',
    card_name = 'Erased',
    card_expiry = 'Erased'
  where poid = purchid;
  commit;
end if;

if action = LNG4.AHC_TXT_093
 then
  update purchase_order set status = LNG.ORD_TXT_121 where poid = purchid;
  insert into purchase_audit(poid,column_name,date_changed,action,changed_by,new_value) values (purchid,'STATUS',sysdate,'U','A',LNG.ORD_TXT_121);
  commit;
end if;

main_title( surl, sessid, LNG.PHG_TXT_086, style=>'NOMENU', helpid=>'A67' );
htp.nl;
htp.p( '<CENTER>' );

 options(1) := 'BGCOLOUR_HDR:' || GLBX.QUERY_BACKGROUND;
 options(2) := 'BGCOLOUR_BDY:' || GLBX.QUERY_CELL_BACKGROUND;
 options(3) := 'TABLE:' || 'cellpading=2 cellspacing=2 border=1';
 options(4) := 'LINEFEED';
 options(5) := 'BUSINESS';
 options(6) := 'PURCHASE';
 options(7) := 'NODISPLAY_IF_EMPTY';
 ord.display_order_details(surl, 'ADMINISTRATOR', c5rec, options);

 options.delete;
 options(1) := 'BGCOLOUR_HDR:' || GLBX.QUERY_BACKGROUND;
 options(2) := 'BGCOLOUR_BDY:' || GLBX.QUERY_CELL_BACKGROUND;
 options(3) := 'TABLE:' || 'cellpading=2 cellspacing=2 border=1';
 options(4) := 'WORFKLOW';
 options(5) := 'METADATA'; -- Is there meta data to display
 htp.nl;
 ord.display_order_subtotal( surl, 'ADMINISTRATOR', c5rec, options );

 htp.nl;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 htp.nl;
 if c4rec.card_number is not null
  then
   htp.formopen( 'adm.dispord' );
   htp.formhidden( 'SURL',  glbx.rndsurl(surl));
   htp.formhidden( 'PURCHID', purchid );
   htp.formhidden( 'CLEAR_CC', 'TRUE' );
   htp.formsubmit( 'ACTION', LNG3.ADM_TXT_802 );
   if c5rec.status in (LNG.ORD_TXT_120,LNG4.AHC_TXT_672,LNG4.AHC_TXT_706,'PreOrder - Confirmed without Payment')
    then
     htp.formsubmit( 'ACTION', LNG4.AHC_TXT_093 );
   end if;
   htp.formclose;
 end if;
 htp.p( '<CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'DISPORD', errmsg=>sqlerrm, extdet=>'PURCHID:' || purchid);
end dispord;

procedure accept_charge_event(surl varchar2, phid integer, opt1a in varchar2, opt1b in varchar2, opt2a in varchar2, ev1 in GLBX.MYARRAY, ev2 in GLBX.MYARRAY )
as

 cursor c1(phid integer) is select plan_id from photographer where pid = phid;

 sessid		integer;
 sts		varchar2(200);
 nmb		integer;
 nmb1a		number;
 nmb1b		number;
 nmb2a		number;
 planid		integer;
begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_CHARGE_EVENT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 open c1(phid);
 fetch c1 into planid;
 close c1;
 delete from charge_plan_event_phg
  where pid = phid;
 for j in ev1.first..ev1.last loop
  begin nmb := to_number(ev2(j)); exception when others then nmb := 0; end;
  if ev1(j) is not null and ev2(j) is not null
   then
    insert into charge_plan_event_phg(pid,plan_id,plan_event,qty)
     values
      (phid, planid, ev1(j), nmb );
   end if;
 end loop;
 begin nmb1a := to_number(opt1a); exception when others then nmb1a := 0; end;
 begin nmb1b := to_number(opt1b); exception when others then nmb1b := 0; end;
 begin nmb2a := to_number(opt2a); exception when others then nmb2a := 0; end;
 update photographer
  set
   charge_option1_discount = nmb1a,
   charge_option1_royalty = nmb1b,
   charge_option2_discount = nmb2a
   where pid = phid;
 commit;
 phg_account(surl,phid,LNG3.ADM_TXT_057);
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_CHARGE_EVENT', errmsg=>sqlerrm, extdet=>'PHID:' || phid);
end accept_charge_event;

procedure interest_group( surl varchar2, msg in varchar2 default null )
as

 cursor c1 is select * from interest_groups order by interest_name;
 cursor c2(intid integer) is
  select username
  from customer_account ca, customer_contact cc, customer_interest ci
  where cc.login_type = 'OWNER' and
        ca.aid = cc.aid and
        cc.contact_id = ci.contact_id and
        ci.interest_id = intid
  union all
  select username
  from customer_profile ca, customer_contact cc, customer_interest ci
  where cc.login_type = 'PROFILE' and
        ca.profile_id = cc.aid and
        cc.contact_id = ci.contact_id and
        ci.interest_id = intid
  order by 1;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.INTEREST_GROUP');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_817, helpid=>'A68' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_interest_group' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( LNG3.ADM_TXT_817, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"'  );
  htp.tableheader( LNG3.ADM_TXT_820, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"'  );
 htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1', 40, 100, c1rec.interest_name ));
   htp.formhidden( 'P2', c1rec.interest_id );
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT">');
   for c2rec in c2(c1rec.interest_id) loop
    htp.italic( c2rec.username || ' ' );
   end loop;
   htp.p( '</TD>' );
  htp.tablerowclose;
 end loop;
 for j in 1..10 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1', 40, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"'  );
   htp.formhidden( 'P2', NULL );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"'  );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null,LNG3.ADM_TXT_877);
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'INTEREST_GROUP', errmsg=>sqlerrm, extdet=>null);
end interest_group;

procedure accept_interest_group( surl varchar2, p1 in MYARRAY, p2 in MYARRAY )
as

 cursor c1(iname varchar2) is select 'x' from interest_groups where interest_name = iname;
 cursor c2 is select max(interest_id) mx from interest_groups;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_INTEREST_GROUP');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 for j in p1.first..p1.last loop
  if p1(j) is not null and p2(j) is null
  then
   open c1(upper(p1(j)));
   fetch c1 into c1rec;
   if c1%NOTFOUND
    then
     close c1;
     open c2;
     fetch c2 into c2rec;
     close c2;
     if c2rec.mx is null
      then
       c2rec.mx := 1;
      else
       c2rec.mx := c2rec.mx + 1;
     end if;
     insert into interest_groups(interest_id,interest_name) values (c2rec.mx,upper(p1(j)));
    else
     close c1;
   end if;
  elsif p1(j) is not null and p2(j) is not null
  then
   update interest_groups set interest_name = upper(p1(j)) where interest_id = to_number(p2(j));
  elsif p1(j) is null and p2(j) is not null
  then
   delete from interest_groups where interest_id = to_number(p2(j));
   delete from customer_interest where interest_id = to_number(p2(j));
  end if;
 end loop;
 commit;
 interest_group( surl,LNG3.ADM_TXT_518 );
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_INTEREST_GROUP', errmsg=>sqlerrm, extdet=>null);
end accept_interest_group;

procedure vmonitor( surl varchar2, msg in varchar2 default null )
as

 cursor c1 is select stmt_id,stmt_name from dynamic_statements order by stmt_id;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.VMONITOR');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_824, helpid=>'A69' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tabledata( htf.anchor( 'adm.vmonitor_option?surl=' || glbx.rndsurl(surl) || '&opt=1', LNG3.ADM_TXT_825 ) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.anchor( 'adm.vmonitor_option?surl=' || glbx.rndsurl(surl) || '&opt=2', LNG3.ADM_TXT_826 ) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.anchor( 'adm.vmonitor_option?surl=' || glbx.rndsurl(surl) || '&opt=3', LNG3.ADM_TXT_827 ) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.anchor( 'adm.vmonitor_option?surl=' || glbx.rndsurl(surl) || '&opt=4', LNG3.ADM_TXT_828 ) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.anchor( 'adm.vmonitor_option?surl=' || glbx.rndsurl(surl) || '&opt=5', LNG3.ADM_TXT_829 ) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.anchor( 'adm.vmonitor_option?surl=' || glbx.rndsurl(surl) || '&opt=6', LNG3.ADM_TXT_830 ) );
 htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( htf.anchor( 'adm.vmonitor_option?surl=' || glbx.rndsurl(surl) || '&opt=8&stmtid=' || c1rec.stmt_id, c1rec.stmt_name ) );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.htmlclose;

exception when others then
 glbx.error_details( 'ADM', 'VMONITOR', errmsg=>sqlerrm, extdet=>null);
end vmonitor;

procedure vmonitor_option( surl varchar2, opt in integer, sqladdr in varchar2 default null, topstmt in varchar2 default '10', ig in varchar2 default 'F', stmtid in integer default null )
as

 cursor c1(opt integer) is
 select sql_text, executions,disk_reads,buffer_gets,rows_processed,optimizer_mode,address
 from v$sqlarea
 where upper(substr(sql_text,1,6)) = 'SELECT'
 order by decode(opt,1,executions,2,disk_reads,3,buffer_gets,4,rows_processed) desc;

 cursor c1a(opt integer, ig varchar2) is
 select sql_text, executions,disk_reads,buffer_gets,rows_processed,optimizer_mode,address
 from v$sqlarea
 where upper(substr(sql_text,1,6)) = 'SELECT' and
       (sql_text not like ('%#%') or sql_text not like '%#%')
 order by decode(opt,1,executions,2,disk_reads,3,buffer_gets,4,rows_processed) desc;

 cursor c2 is
 select id, parent_id,2*(level-1) lvl,operation||' '||options||' '||object_name||' '|| decode(id, 0, 'cost = '||position) col3
 from plan_table
 start with id = 0
 connect by prior id = parent_id
 order by id, parent_id;

 cursor c3( vaddr varchar2 ) is select sql_text	from v$sqltext where address = vaddr order by piece;

 cursor c4 is select sid,serial#,username,program,logon_time from v$session;

 cursor c5 is select sid,serial#,message,start_time,sql_address,elapsed_seconds from v$session_longops order by start_time desc;

 cursor c6 is select class,count,time from v$waitstat;

 cursor c7(stmtid integer) is select * from dynamic_statements where stmt_id = stmtid;

 c1rec		c1%ROWTYPE;
 c7rec		c7%ROWTYPE;
 sqlstmt	varchar2(32767);
 sessid		integer;
 sts		varchar2(200);
 sid		integer;
 nmb		integer;
 cursor_name	integer;
 col_count	integer;
 dummy		integer;
 desc_t		dbms_sql.desc_tab;
 common_nmb	number;
 common_vc2	varchar2(4000);
 common_dte	date;
 tmpval		varchar2(4000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.VMONITOR_OPTION');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 begin nmb := to_number(topstmt); exception when others then nmb := 10; end;

 if opt = 1
  then
   main_title( surl, sessid, LNG3.ADM_TXT_825, helpid=>'A70' );
 elsif opt = 2
  then
   main_title( surl, sessid, LNG3.ADM_TXT_826, helpid=>'A70' );
 elsif opt = 3
  then
   main_title( surl, sessid, LNG3.ADM_TXT_827, helpid=>'A70' );
 elsif opt = 4
  then
   main_title( surl, sessid, LNG3.ADM_TXT_828, helpid=>'A70' );
 elsif opt = 5
  then
   main_title( surl, sessid, LNG3.ADM_TXT_829, helpid=>'A70' );
 elsif opt = 6
  then
   main_title( surl, sessid, LNG3.ADM_TXT_830, helpid=>'A70' );
 elsif opt = 7
  then
   main_title( surl, sessid, LNG3.ADM_TXT_831, helpid=>'A70' );
 elsif opt = 8
  then
   open c7(stmtid);
   fetch c7 into c7rec;
   close c7;
   main_title( surl, sessid, c7rec.stmt_name, helpid=>'A70' );
 elsif opt = 9
  then
   main_title( surl, sessid, LNG3.ADM_TXT_841, style=>'NOMENU', helpid=>'A70' );
 end if;
 htp.nl;
 htp.p( '<CENTER>' );

 if opt in (1,2,3,4)
  then
   htp.tableopen( cattributes=>'width="100%" cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
     htp.tableheader( '&nbsp;' ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG3.ADM_TXT_832 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG3.ADM_TXT_833 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG3.ADM_TXT_834 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG3.ADM_TXT_835 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG3.ADM_TXT_836 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG3.ADM_TXT_837 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
    htp.tablerowclose;
    if ig = 'T'
     then
      for c1rec in c1a(opt,ig) loop
       htp.tablerowopen;
        htp.tabledata( htf.anchor2( 'adm.vmonitor_option?surl=' || glbx.rndsurl(surl) || '&opt=9&sqladdr=' || c1rec.address, LNG3.ADM_TXT_838, ctarget=>new_window), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
        htp.tabledata( c1rec.sql_text, cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
        htp.tabledata( to_char(c1rec.executions), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
        htp.tabledata( to_char(c1rec.disk_reads), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
        htp.tabledata( to_char(c1rec.buffer_gets), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
        htp.tabledata( to_char(c1rec.rows_processed), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
        htp.tabledata( c1rec.optimizer_mode, cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
       htp.tablerowclose;
       if c1a%ROWCOUNT > nmb then exit; end if;
      end loop;
     else
      for c1rec in c1(opt) loop
       htp.tablerowopen;
        htp.tabledata( htf.anchor2( 'adm.vmonitor_option?surl=' || glbx.rndsurl(surl) || '&opt=9&sqladdr=' || c1rec.address, LNG3.ADM_TXT_838, ctarget=>new_window), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
        htp.tabledata( c1rec.sql_text, cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
        htp.tabledata( to_char(c1rec.executions), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
        htp.tabledata( to_char(c1rec.disk_reads), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
        htp.tabledata( to_char(c1rec.buffer_gets), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
        htp.tabledata( to_char(c1rec.rows_processed), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
        htp.tabledata( c1rec.optimizer_mode, cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
       htp.tablerowclose;
       if c1%ROWCOUNT > nmb then exit; end if;
      end loop;
    end if;
   htp.tableclose;
   htp.nl;
   htp.formopen( 'adm.vmonitor_option' );
   htp.formhidden( 'SURL',  glbx.rndsurl(surl));
   htp.formhidden( 'OPT', to_char(opt) );
   htp.bold( LNG3.ADM_TXT_839 || ':' || htf.formtext( 'topstmt', 5, 10, to_char(nmb) ) );
   htp.nl;
   htp.formcheckbox( 'IG', 'T' );
   htp.p( LNG3.ADM_TXT_853 );
   htp.nl;
   htp.formsubmit( null, LNG3.ADM_TXT_840 );
   htp.formclose;
 elsif opt = 5
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
     htp.tableheader( '&nbsp;' ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG3.ADM_TXT_843 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG3.ADM_TXT_844 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG3.ADM_TXT_845 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG.GLB_TXT_076 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG3.ADM_TXT_846 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
    htp.tablerowclose;
    for c4rec in c4 loop
      if c4rec.program = 'ORACLE.EXE'
       then
        htp.tabledata( '&nbsp;', cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
       else
        htp.tabledata( htf.anchor( 'adm.vmonitor_option?surl=' || glbx.rndsurl(surl) || '&opt=10&sqladdr=' || to_char(c4rec.sid) || ',' || to_char(c4rec.serial#),LNG3.ADM_TXT_255), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
      end if;
      htp.tabledata( to_char(c4rec.sid), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
      htp.tabledata( to_char(c4rec.serial#), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
      htp.tabledata( c4rec.program, cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
      htp.tabledata( c4rec.username, cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
      htp.tabledata( to_char(c4rec.logon_time,LNG.TSMASK), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
     htp.tablerowclose;
    end loop;
    htp.tableclose;
 elsif opt = 6
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
     htp.tableheader( '&nbsp;' ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( '&nbsp;' ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG3.ADM_TXT_843 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG3.ADM_TXT_844 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG3.ADM_TXT_849 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG3.ADM_TXT_847 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG3.ADM_TXT_848 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
    htp.tablerowclose;
    for c5rec in c5 loop
      htp.tabledata( htf.anchor( 'adm.vmonitor_option?surl=' || glbx.rndsurl(surl) || '&opt=10&sqladdr=' || to_char(c5rec.sid) || ',' || to_char(c5rec.serial#),LNG3.ADM_TXT_255), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
      htp.tabledata( htf.anchor2( 'adm.vmonitor_option?surl=' || glbx.rndsurl(surl) || '&opt=9&sqladdr=' || c5rec.sql_address,LNG3.ADM_TXT_838, ctarget=>new_window), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
      htp.tabledata( to_char(c5rec.sid), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
      htp.tabledata( to_char(c5rec.serial#), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
      htp.tabledata( c5rec.message, cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
      htp.tabledata( to_char(c5rec.start_time,LNG.TSMASK), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
      htp.tabledata( to_char(c5rec.elapsed_seconds), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
     htp.tablerowclose;
    end loop;
    htp.tableclose;
 elsif opt = 7
  then
   htp.tableopen( cattributes=>'width="100%" cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
     htp.tableheader( LNG3.ADM_TXT_190 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG3.ADM_TXT_852 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
     htp.tableheader( LNG3.ADM_TXT_260 ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
    htp.tablerowclose;
    for c6rec in c6 loop
      htp.tabledata( c6rec.class, cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
      htp.tabledata( to_char(c6rec.count), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
      htp.tabledata( to_char(c6rec.time), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="RIGHT"' );
     htp.tablerowclose;
    end loop;
    htp.tableclose;
 elsif opt = 8
  then
   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, c7rec.stmt, dbms_sql.native );
   dbms_sql.describe_columns(cursor_name,col_count,desc_t);
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
   htp.tablerowopen;
   for j in 1..col_count loop
    if desc_t(j).col_type in (1,96)
     then
      dbms_sql.define_column_char(cursor_name,j,common_vc2,desc_t(j).col_max_len);
    elsif desc_t(j).col_type = 2
     then
      dbms_sql.define_column(cursor_name,j,common_nmb);
    elsif desc_t(j).col_type = 12
     then
      dbms_sql.define_column(cursor_name,j,common_dte);
    end if;
    htp.tabledata( htf.bold(initcap(replace(desc_t(j).col_name,'_',' '))), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   end loop;
   htp.tablerowclose;
   dummy := dbms_sql.execute( cursor_name );

   loop
      dummy := dbms_sql.fetch_rows( cursor_name );
      if dummy > 0
       then
        htp.tablerowopen;
        for j in 1..col_count loop
         tmpval := NULL;
         common_vc2 := NULL;
         common_nmb := NULL;
         common_dte := NULL;
         if desc_t(j).col_type in (1,96)
          then
           dbms_sql.column_value_char(cursor_name,j,common_vc2);
           tmpval := rtrim( common_vc2 );
          elsif desc_t(j).col_type = 2
           then
            dbms_sql.column_value(cursor_name,j,common_nmb);
            tmpval := to_char( common_nmb );
          elsif desc_t(j).col_type = 12
           then
            dbms_sql.column_value(cursor_name,j,common_dte);
            tmpval := to_char( common_dte,LNG.TSMASK );
         end if;
         htp.tabledata( tmpval, cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
        end loop;
        htp.tablerowclose;
      else
       exit;
      end if;
     end loop;
     dbms_sql.close_cursor( cursor_name );
    htp.tableclose;

 elsif opt = 9
  then
   delete from plan_table;
   commit;
   for c3rec in c3(sqladdr) loop
    sqlstmt := sqlstmt || c3rec.sql_text;
   end loop;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( sqlstmt,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   begin
    execute immediate 'explain plan for ' || sqlstmt;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    for c2rec in c2 loop
     htp.tablerowopen;
      htp.tabledata( c2rec.id );
      htp.tabledata( c2rec.parent_id );
      htp.p( '<TD ' || GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
      for j in 1..c2rec.lvl loop
       htp.p( '&nbsp;' );
      end loop;
      htp.p( c2rec.col3 );
      htp.p( '</TD>' );
     htp.tablerowclose;
    end loop;
    exception
     when others then htp.p( LNG3.ADM_TXT_842 );
    end;
   htp.tableclose;
   htp.nl;
   htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 elsif opt = 10
  then
   begin
    execute immediate 'alter system kill session ''' || sqladdr || '''';
    vmonitor(surl,LNG3.ADM_TXT_850);
    return;
   exception
    when others
     then
      vmonitor(surl,LNG3.ADM_TXT_850 || '-' || sqlerrm );
      return;
   end;
 end if;

 htp.htmlclose;

exception when others then
 glbx.error_details( 'ADM', 'VMONITOR_OPTION', errmsg=>sqlerrm, extdet=>null);
end vmonitor_option;

procedure defrep( surl in varchar2, msg in varchar2 default null  )
as

 cursor c1 is
  select report_id, report_name, title, usc.parent_scene
  from report_definition rd, umo_scene usc
  where usc.umo_scene_id = rd.umo_scene_id
  order by order_by,report_name;

 cursor c2 is
  select scene_name from scene order by scene_name;

 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.DEFREP');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_854, helpid=>'A71' );
 htp.nl;
 htp.p('<CENTER>');
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
   htp.tablerowopen;
    htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND );
    htp.p( '<TD ' || glbx.QUERY_BACKGROUND || '>' );
    htp.formopen( 'adm.mnt_defrep', ctarget=>'ADM_RIGHT' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl) );
    htp.formhidden( 'REPID', '0' );
    htp.formselectopen( 'CTG' );
    for c2rec in c2 loop
     htp.formselectoption( c2rec.scene_name );
    end loop;
    htp.formselectclose;
    htp.formsubmit( null, LNG3.ADM_TXT_855 );
    htp.formclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  for c1rec in c1 loop
   htp.tablerowopen;
    htp.tabledata( lpad('.', glbx.indnt(c1rec.parent_scene),'.') || c1rec.title, cattributes=>glbx.QUERY_CELL_BACKGROUND );
    htp.tabledata( htf.anchor2('adm.mnt_defrep?surl=' || glbx.rndsurl(surl) || '&repid=' || c1rec.report_id, c1rec.report_name,ctarget=>new_window),cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'DEFREP', errmsg=>sqlerrm, extdet=>null);
end defrep;

procedure mnt_defrep( surl in varchar2, repid in integer, msg in varchar2 default null, ctg in varchar2 default 'GENERIC'  )
as

 cursor c1( repid integer ) is
  select *
  from report_definition
  where report_id = repid;

 cursor c2( ctg varchar2 ) is select * from umo_scene where category = ctg order by order_by;

 cursor c3( repid integer ) is select * from report_parameters where report_id = repid order by order_by;

 cursor c4( repid integer ) is select associated_id,do_not_run_if_zero_stmt from report_associated where report_id = repid order by associated_id;

 cursor c5( uscid integer ) is select report_id,report_name from report_definition;

 cursor c6( repid integer) is select pr.role_id from piction_roles pr, report_roles rr where rr.role_id = pr.role_id and pr.role_type in ('REPORT','SECURITY ROLE') and rr.report_id = repid order by pr.role_name;

 cursor c7 is select role_id, role_name, role_type from piction_roles where role_type in ('REPORT','SECURITY ROLE') order by role_name;

 cursor c8( uscid integer ) is select category from umo_scene where umo_scene_id = uscid;

 c1rec	c1%ROWTYPE;
 c8rec	c8%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MNT_DEFREP');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 open c1( repid );
 fetch c1 into c1rec;
 close c1;
 if repid = 0
  then
   main_title( surl, sessid, LNG3.ADM_TXT_855, style=>'NOMENU', helpid=>'A72' );
   c8rec.category := ctg;
  else
   main_title( surl, sessid, LNG3.ADM_TXT_854 || ':' || c1rec.report_name, style=>'NOMENU', helpid=>'A72' );
   open c8( c1rec.umo_scene_id );
   fetch c8 into c8rec;
   close c8;
   c8rec.category := nvl(c8rec.category,ctg);
 end if;
 htp.nl;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p('<CENTER>');
 htp.formopen( 'adm.accept_mnt_defrep' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.formhidden( 'REPID', repid );
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG3.ADM_TXT_856),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.formtext( 'P1', 30, 100, c1rec.report_name ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG3.ADM_TXT_857),cattributes=>glbx.QUERY_BACKGROUND );
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || '>' );
    htp.formselectopen( 'P2' );
    if c1rec.report_type = LNG3.ADM_TXT_861 then htp.formselectoption( LNG3.ADM_TXT_861, 'SELECTED' ); else htp.formselectoption( LNG3.ADM_TXT_861 ); end if;
    if c1rec.report_type = LNG3.ADM_TXT_862 then htp.formselectoption( LNG3.ADM_TXT_862, 'SELECTED' ); else htp.formselectoption( LNG3.ADM_TXT_862 ); end if;
    if c1rec.report_type = LNG3.ADM_TXT_863 then htp.formselectoption( LNG3.ADM_TXT_863, 'SELECTED' ); else htp.formselectoption( LNG3.ADM_TXT_863 ); end if;
    if c1rec.report_type = LNG3.ADM_TXT_864 then htp.formselectoption( LNG3.ADM_TXT_864, 'SELECTED' ); else htp.formselectoption( LNG3.ADM_TXT_864 ); end if;
    htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG3.ADM_TXT_859),cattributes=>glbx.QUERY_BACKGROUND );
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || '>' );
    htp.formselectopen( 'P3' );
    for c2rec in c2( c8rec.category ) loop
     if c2rec.umo_scene_id = c1rec.umo_scene_id
      then
       htp.formselectoption( lpad('.', glbx.indnt(c2rec.parent_scene),'.') || c2rec.title, 'SELECTED', cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
      else
       htp.formselectoption( lpad('.', glbx.indnt(c2rec.parent_scene),'.') || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG3.ADM_TXT_858),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.formtext( 'P4', 50, 1000, c1rec.physical_location ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_867 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tabledata( htf.bold( 'Display Name' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tabledata( htf.bold( LNG3.ADM_TXT_868 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tabledata( htf.bold( LNG3.ADM_TXT_869 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tabledata( htf.bold( LNG3.ADM_TXT_429 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tabledata( htf.bold( LNG3.ADM_TXT_870 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tabledata( htf.bold( LNG3.ADM_TXT_937 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tabledata( htf.bold( LNG4.AHC_TXT_404 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
 htp.tablerowclose;
 for c3rec in c3(repid) loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'PRA0', 20, 100, c3rec.parameter_display_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'PRA', 20, 100, c3rec.parameter_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'PRB' );
    if c3rec.parameter_type = LNG3.ADM_TXT_871 then htp.formselectoption( LNG3.ADM_TXT_871, 'SELECTED' ); else htp.formselectoption( LNG3.ADM_TXT_871 ); end if;
    if c3rec.parameter_type = LNG3.ADM_TXT_872 then htp.formselectoption( LNG3.ADM_TXT_872, 'SELECTED' ); else htp.formselectoption( LNG3.ADM_TXT_872 ); end if;
    if c3rec.parameter_type = LNG4.AHC_TXT_109 then htp.formselectoption( LNG4.AHC_TXT_109, 'SELECTED' ); else htp.formselectoption( LNG4.AHC_TXT_109 ); end if;
    if c3rec.parameter_type = LNG4.AHC_TXT_378 then htp.formselectoption( LNG4.AHC_TXT_378, 'SELECTED' ); else htp.formselectoption( LNG4.AHC_TXT_378 ); end if;
    if c3rec.parameter_type = LNG3.ADM_TXT_922 then htp.formselectoption( LNG3.ADM_TXT_922, 'SELECTED' ); else htp.formselectoption( LNG3.ADM_TXT_922 ); end if;
    if c3rec.parameter_type = 'MULTIPLE SQL RANGE' then htp.formselectoption( 'MULTIPLE SQL RANGE', 'SELECTED' ); else htp.formselectoption( 'MULTIPLE SQL RANGE' ); end if;
    if c3rec.parameter_type = 'ABORT IF COLUMN IS ZERO' then htp.formselectoption( 'ABORT IF COLUMN IS ZERO', 'SELECTED' ); else htp.formselectoption( 'ABORT IF COLUMN IS ZERO' ); end if;
    if c3rec.parameter_type = 'Date Range' then htp.formselectoption( 'Date Range', 'SELECTED' ); else htp.formselectoption( 'Date Range' ); end if;
    if c3rec.parameter_type = 'Comma LOV' then htp.formselectoption( 'Comma LOV', 'SELECTED' ); else htp.formselectoption( 'Comma LOV' ); end if;
    if c3rec.parameter_type = 'Multiple Comma LOV' then htp.formselectoption( 'Multiple Comma LOV', 'SELECTED' ); else htp.formselectoption( 'Multiple Comma LOV' ); end if;
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.formtext( 'PRC', 5, 10, c3rec.order_by ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'PRD', 40, 4000, c3rec.parameter_value ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'PRE', 5, 10, c3rec.parameter_level ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   if c3rec.display_header = 'T'
    then
     htp.tabledata( htf.formradio( 'PRF', c3rec.parameter_name, 'CHECKED' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
    else
     htp.tabledata( htf.formradio( 'PRF', c3rec.parameter_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   end if;
  htp.tablerowclose;
 end loop;
 for j in 1..4 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'PRA0', 20, 100 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'PRA', 20, 100 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'PRB' );
    htp.formselectoption( LNG3.ADM_TXT_871, 'SELECTED' );
    htp.formselectoption( LNG3.ADM_TXT_872 );
    htp.formselectoption( LNG4.AHC_TXT_109 );
    htp.formselectoption( LNG4.AHC_TXT_378 );
    htp.formselectoption( LNG3.ADM_TXT_922 );
    htp.formselectoption( 'MULTIPLE SQL RANGE' );
    htp.formselectoption( 'ABORT IF COLUMN IS ZERO' );
    htp.formselectoption( 'Date Range' );
    htp.formselectoption( 'Comma LOV' );
    htp.formselectoption( 'Multiple Comma LOV' );
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.formtext( 'PRC', 5, 10 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'PRD', 40, 4000 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'PRE', 5, 10 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.formhidden( 'PRF', NULL );
   htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;

 htp.p( '<TD VALIGN="TOP">' );
 htp.bold( LNG3.ADM_TXT_912 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG3.ADM_TXT_856 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tabledata( htf.bold( 'Do Not Run Report if equals 0' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
 htp.tablerowclose;
 for c4rec in c4( c1rec.report_id ) loop
 htp.tablerowopen;
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="TOP" ALIGN="LEFT">' );
   htp.formselectopen( 'RPA' );
   htp.formselectoption( NULL );
    for c5rec in c5(c1rec.umo_scene_id) loop
    if c5rec.report_id = c4rec.associated_id
     then
      htp.formselectoption( c5rec.report_name, 'SELECTED', cattributes=>'VALUE="' || c5rec.report_id || '"' );
     else
      htp.formselectoption( c5rec.report_name, cattributes=>'VALUE="' || c5rec.report_id || '"' );
    end if;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.formtext( 'RPX', 30, 4000, c4rec.do_not_run_if_zero_stmt ));
 htp.tablerowclose;
 end loop;
 for j in 1..4 loop
 htp.tablerowopen;
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'RPA' );
   htp.formselectoption( NULL );
    for c5rec in c5(c1rec.umo_scene_id) loop
     htp.formselectoption( c5rec.report_name, cattributes=>'VALUE="' || c5rec.report_id || '"' );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.formtext( 'RPX', 30, 4000, null ));
 htp.tablerowclose;
 end loop;
 htp.tablerowopen;
  htp.tabledata( htf.bold( 'Run this procedure:' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tabledata(htf.formtext('P_API', 30, 30, c1rec.report_api));
 htp.tablerowclose;
 htp.tableclose;
 htp.p( '</TD>' );

 htp.p( '<TD VALIGN="TOP">' );
 htp.bold( LNG3.ADM_TXT_932 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG3.ADM_TXT_916 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
 htp.tablerowclose;
 for c6rec in c6( c1rec.report_id ) loop
 htp.tablerowopen;
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'RPB' );
   htp.formselectoption( NULL );
    for c7rec in c7 loop
    if c6rec.role_id = c7rec.role_id
     then
      htp.formselectoption( c7rec.role_name || '(' || c7rec.role_type || ')', 'SELECTED', cattributes=>'VALUE="' || c7rec.role_id || '"' );
     else
      htp.formselectoption( c7rec.role_name || '(' || c7rec.role_type || ')', cattributes=>'VALUE="' || c7rec.role_id || '"' );
    end if;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
 htp.tablerowclose;
 end loop;
 for j in 1..4 loop
 htp.tablerowopen;
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="TOP" ALIGN="LEFT">' );
   htp.formselectopen( 'RPB' );
   htp.formselectoption( NULL );
    for c7rec in c7 loop
     htp.formselectoption( c7rec.role_name || '(' || c7rec.role_type || ')', cattributes=>'VALUE="' || c7rec.role_id || '"' );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
 htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.p( '</TD>' );

 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_865 );
 htp.formclose;
 if repid > 0
  then
   htp.anchor( 'adm.manage_report?surl=' || glbx.rndsurl(surl) || '&repid=' || repid, '[' || LNG2.PFM_TXT_154 || ']' );
   htp.anchor( 'adm.manage_report?surl=' || glbx.rndsurl(surl) || '&action=DELETE&repid=' || repid, '[' || LNG.SLD_TXT_004 || ']' );
   htp.nl;
   htp.formopen( 'adm.xml_unload' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl) );
   htp.formhidden( 'TYP','RDF' );
   htp.formhidden( 'P1',repid );
   htp.italic( LNG3.ADM_TXT_181 || ': ' || htf.formtext( 'P2',30, 100,lower(replace(c1rec.report_name,' ','_') || '.txt' )));
   htp.nl;
   htp.formsubmit( null,LNG3.ADM_TXT_182 );
   htp.formclose;
 end if;
 htp.nl;
 htp.nl;
 htp.header(6,'* Date Range Format: months before today, months after today, D | M | Y (increment in Day, Month Year), Display Mask' );
 htp.header(6,'eg. -36,48,M,Month YYYY  - Will display from 36 months ago to 48 months from now, in increments of a month, displayed Month Year' );
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MNT_DEFREP', errmsg=>sqlerrm, extdet=>null);
end mnt_defrep;

procedure manage_report( surl in varchar2, repid in integer, action in varchar2 default 'COPY' )
as

 sessid	integer;
 sts	varchar2(200);
 newid	integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MANAGE_REPORT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if action = 'DELETE'
  then
   delete from report_parameters where report_id = repid;
   delete from report_associated where report_id = repid;
   delete from report_associated where associated_id = repid;
   delete from report_roles where report_id = repid;
   delete from report_definition where report_id = repid;
   commit;
   mnt_defrep(surl,0,LNG3.ADM_TXT_935);
   return;
 end if;
 select s_report_definition.nextval into newid from dual;
 insert into report_definition(report_id,umo_scene_id,report_name,report_type,physical_location)
  select newid,umo_scene_id,LNG2.PFM_TXT_154 || ' ' || report_name,report_type,physical_location
  from report_definition
  where report_id = repid;
 insert into report_parameters(report_id,order_by,parameter_name,parameter_type,parameter_value)
  select newid,order_by,parameter_name,parameter_type,parameter_value
  from report_parameters
  where report_id = repid;
 insert into report_associated(report_id,associated_id)
  select newid,associated_id
  from report_associated
  where report_id = repid;
 insert into report_roles(report_id,role_id)
  select newid,role_id
  from report_roles
  where report_id = repid;
 commit;
 mnt_defrep(surl,newid,LNG3.ADM_TXT_934);
exception when others then
 glbx.error_details( 'ADM', 'MANAGE_REPORT', errmsg=>sqlerrm, extdet=>null);
end manage_report;

procedure accept_mnt_defrep( surl in varchar2, repid in integer, p1 in varchar2, p2 in varchar2, p3 in integer, p4 in varchar2, p_api in varchar2, pra0 in GLBX.MYARRAY, pra in GLBX.MYARRAY, prb in GLBX.MYARRAY, prc in GLBX.MYARRAY, prd in GLBX.MYARRAY, pre in GLBX.MYARRAY, prf in GLBX.MYARRAY, rpa in GLBX.MYARRAY, rpb in GLBX.MYARRAY, rpx in GLBX.MYARRAY )
as

 nmb	integer;
 nmb2	integer;
 newid	integer;
 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MNT_DEFREP');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if repid = 0
  then
   select s_report_definition.nextval into newid from dual;
   insert into report_definition(report_id,umo_scene_id,report_name,report_type,physical_location,report_api)
   values (newid,p3,p1,p2,p4,p_api);
  else
   update report_definition
    set
     umo_scene_id = p3,
     report_type = p2,
     report_name = p1,
     physical_location = p4,
     report_api = p_api
   where report_id = repid;
   newid := repid;
 end if;
 delete from report_parameters where report_id = newid;
 for j in pra.first..pra.last loop
  if pra(j) is not null
   then
    begin nmb := to_number( prc(j) ); exception when others then nmb := 999; end;
    begin nmb2 := to_number( pre(j) ); exception when others then nmb2 := 999; end;
    if prf(1) = pra(j)
     then
      insert into report_parameters(report_id,order_by,parameter_name,parameter_type,parameter_value,parameter_level,display_header,parameter_display_name) values
       (newid,nmb,upper(nvl(pra(j),pra0(j))),prb(j),prd(j),pre(j),'T',nvl(pra0(j),pra(j)));
     else
      insert into report_parameters(report_id,order_by,parameter_name,parameter_type,parameter_value,parameter_level,display_header,parameter_display_name) values
       (newid,nmb,upper(nvl(pra(j),pra0(j))),prb(j),prd(j),pre(j),'F',nvl(pra0(j),pra(j)));
    end if;
  end if;
 end loop;
 delete from report_associated where report_id = newid;
 for j in rpa.first..rpa.last loop
  if rpa(j) is not null
   then
    insert into report_associated(report_id,associated_id,do_not_run_if_zero_stmt) values (newid,rpa(j),rpx(j));
  end if;
 end loop;
 delete from report_roles where report_id = newid;
 for j in rpb.first..rpb.last loop
  if rpb(j) is not null
   then
    insert into report_roles(report_id,role_id) values (newid,rpb(j));
  end if;
 end loop;
 commit;
 mnt_defrep( surl, newid, LNG3.ADM_TXT_860 );
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_MNT_DEFREP', errmsg=>sqlerrm, extdet=>null);
end accept_mnt_defrep;

procedure metatg( surl varchar2, id in integer, msg in varchar2 default null )
as

 cursor c1(id integer) is select * from umo_attributes where attribute_id = id;

 c1rec	c1%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);
 tmp	varchar2(4000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.METATG');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_938, style=>'NOMENU', helpid=>'A57' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p('<CENTER>');
 open c1(id);
 fetch c1 into c1rec;
 close c1;

 htp.formopen( 'adm.accept_metag' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.formhidden( 'ID', id );

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_552 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold(c1rec.umo_type),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.CST_TXT_042 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext( 'P3', 30, 100, c1rec.category),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_129 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold(c1rec.business_feature),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_957 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext( 'P4', 30, 100, c1rec.sub_category),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_429 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext( 'P4O', 10, 20, c1rec.order_by),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_716 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.queryable = 'T'
      then
       htp.tabledata(htf.formcheckbox( 'P5','T','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
      else
       htp.tabledata(htf.formcheckbox( 'P5','T' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
     end if;
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_555 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.mandatory = 'T'
      then
       htp.tabledata(htf.formcheckbox( 'P6','T','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
      else
       htp.tabledata(htf.formcheckbox( 'P6','T' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
     end if;
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_556 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.editeable = 'T'
      then
       htp.tabledata(htf.formcheckbox( 'P7','T','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
      else
       htp.tabledata(htf.formcheckbox( 'P7','T'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
     end if;
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_874 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.disp_phg = 'T'
      then
       htp.tabledata(htf.formcheckbox( 'P2','T','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
      else
       htp.tabledata(htf.formcheckbox( 'P2','T'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
     end if;
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_379 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.displayed = 'T'
      then
       htp.tabledata(htf.formcheckbox( 'P8','T','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
      else
       htp.tabledata(htf.formcheckbox( 'P8','T'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
     end if;
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_873 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.cust_hor = 'T'
      then
       htp.tabledata(htf.formcheckbox( 'P8H','T','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
      else
       htp.tabledata(htf.formcheckbox( 'P8H','T'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
     end if;
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_160 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.prof_editeable = 'T'
      then
       htp.tabledata(htf.formcheckbox( 'P8P','T','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
      else
       htp.tabledata(htf.formcheckbox( 'P8P','T'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
     end if;
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG5.EXT_TXT_313 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c1rec.external_query = 'T'
      then
       htp.tabledata(htf.formcheckbox( 'P8X','T','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
      else
       htp.tabledata(htf.formcheckbox( 'P8X','T'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
     end if;
    htp.tablerowclose;

    tmp := htf.formselectopen( 'P10' );
     if c1rec.edit_type = LNG3.ADM_TXT_718
      then
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_718, 'SELECTED' );
      else
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_718 );
      end if;
     if c1rec.edit_type = LNG3.ADM_TXT_576
      then
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_576, 'SELECTED' );
      else
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_576 );
      end if;
     if c1rec.edit_type = LNG3.ADM_TXT_719
      then
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_719, 'SELECTED' );
      else
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_719 );
      end if;
     if c1rec.edit_type = LNG3.ADM_TXT_720
      then
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_720, 'SELECTED' );
      else
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_720 );
      end if;
     if c1rec.edit_type = LNG3.ADM_TXT_721
      then
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_721, 'SELECTED' );
      else
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_721 );
      end if;
     if c1rec.edit_type = LNG3.ADM_TXT_722
      then
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_722, 'SELECTED' );
      else
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_722 );
      end if;
     if c1rec.edit_type = LNG3.ADM_TXT_583
      then
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_583, 'SELECTED' );
      else
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_583 );
      end if;
     if c1rec.edit_type = LNG3.ADM_TXT_612
      then
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_612, 'SELECTED' );
      else
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_612 );
      end if;
     -- SQL
     if c1rec.edit_type = LNG3.ADM_TXT_872
      then
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_872, 'SELECTED' );
      else
       tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_872 );
      end if;
     --if c1rec.edit_type = LNG3.ADM_TXT_862
     -- then
     --  tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_862, 'SELECTED' );
     -- else
     --  tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_862 );
     -- end if;
     -- Keyword
     if c1rec.edit_type = LNG.CST_TXT_038
      then
       tmp := tmp || htf.formselectoption( LNG.CST_TXT_038 , 'SELECTED' );
      else
       tmp := tmp || htf.formselectoption( LNG.CST_TXT_038  );
      end if;
     if c1rec.edit_type = 'Boolean'
      then
       tmp := tmp || htf.formselectoption( 'Boolean' , 'SELECTED' );
      else
       tmp := tmp || htf.formselectoption( 'Boolean'  );
      end if;
     if c1rec.edit_type = 'Thesaurus'
      then
       tmp := tmp || htf.formselectoption( 'Thesaurus' , 'SELECTED' );
      else
       tmp := tmp || htf.formselectoption( 'Thesaurus'  );
      end if;

    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_717 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_557 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext( 'P9', 10, 20, c1rec.maxlength),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     if c1rec.edit_type = LNG3.ADM_TXT_583
      then
       htp.tabledata(htf.bold( LNG3.ADM_TXT_594 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     elsif c1rec.edit_type = LNG3.ADM_TXT_612
      then
       htp.tabledata(htf.bold( LNG3.ADM_TXT_643 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     elsif c1rec.edit_type = LNG3.ADM_TXT_872
      then
       htp.tabledata(htf.bold( LNG4.AHC_TXT_400 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     elsif c1rec.edit_type = LNG.CST_TXT_038
      then
       htp.tabledata(htf.bold( LNG.CST_TXT_038 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     elsif c1rec.edit_type = LNG3.ADM_TXT_862
      then
       htp.tabledata(htf.bold( LNG4.AHC_TXT_403 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     elsif c1rec.edit_type = 'Boolean'
      then
       htp.tabledata(htf.bold( LNG5.EXT_TXT_312 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.bold( LNG3.ADM_TXT_733 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
     htp.tabledata(htf.formtext( 'P11', 100, 4000, c1rec.lov_list),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    if c1rec.external_query = 'T'
     then
     htp.tablerowopen;
       htp.tabledata(htf.bold( LNG5.EXT_TXT_314 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.formtext( 'P12S', 100, 4000, c1rec.sql_select_mask),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata(htf.bold( LNG5.EXT_TXT_162 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.formtext( 'P12U', 100, 4000, c1rec.sql_update_mask),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata(htf.bold( LNG5.EXT_TXT_310 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.formtext( 'P12I', 100, 4000, c1rec.sql_insert_mask),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
       htp.tabledata(htf.bold( LNG5.EXT_TXT_311 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.formtext( 'P12D', 100, 4000, c1rec.sql_delete_mask),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
    end if;
    htp.tablerowopen;
      htp.tabledata(htf.bold( LNG5.EXT_TXT_161 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.formtext( 'PHLP', 100, 4000, c1rec.help_on),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
  htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_938 );
 htp.formclose;
 htp.nl;
 htp.formopen( 'adm.delete_metatag' );
  htp.formhidden( 'SURL',  glbx.rndsurl(surl));
  htp.formhidden( 'ID', id );
  htp.formsubmit( null, LNG3.ADM_TXT_891 );
 htp.formclose;
 htp.nl;
 htp.anchor( 'adm.meta_tag_exception?surl=' || glbx.rndsurl(surl) || '&id=' || id, LNG3.ADM_TXT_734 );
 htp.nl;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 htp.nl;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'METATG', errmsg=>sqlerrm, extdet=>null);
end metatg;

procedure accept_metag( surl varchar2, id in integer, p3 in varchar2, p4 in varchar2, p4o in varchar2, p2 in varchar2 default 'F', p5 in varchar2 default 'F', p6 in varchar2 default 'F', p7 in varchar2 default 'F', p8 in varchar2 default 'F', p8h in varchar2 default 'F', p8p in varchar2 default 'F', p8x in varchar2 default 'F',
                        p9 in varchar2, p10 in varchar2, p11 in varchar2, phlp in varchar2, p12s in varchar2 default null, p12u in varchar2 default null, p12i in varchar2 default null, p12d in varchar2 default null )
as

 cursor c1(id integer) is select * from umo_attributes where attribute_id = id;

 c1rec	c1%ROWTYPE;
 sessid	integer;
 nmb	integer;
 nmb2	integer;
 sts	varchar2(200);
 tmp	varchar2(4000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.METATG');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 begin nmb := to_number(p9); exception when others then nmb := NULL; end;
 begin nmb2 := to_number(p4o); exception when others then nmb2 := NULL; end;

 update umo_attributes
     set
      category = nvl(upper(p3),category),
      sub_category = nvl(upper(p4),sub_category),
      order_by = nmb2,
      queryable = nvl(p5,'F'),
      mandatory = nvl(p6,'F'),
      editeable = nvl(p7,'F'),
      displayed = nvl(p8,'F'),
      disp_phg = nvl(p2,'F'),
      cust_hor = nvl(p8h,'F'),
      prof_editeable = nvl(p8p,'F'),
      external_query = nvl(p8x,'F'),
      maxlength = nmb,
      edit_type = nvl(p10,LNG3.ADM_TXT_718),
      lov_list = nvl(p11,decode(edit_type,'Boolean','T,F',NULL)),
      sql_select_mask = p12s,
      sql_update_mask = p12u,
      sql_insert_mask = p12i,
      sql_delete_mask = p12d,
      help_on = phlp
     where
      attribute_id = id;

 metatg(surl,id,LNG3.ADM_TXT_939);
end accept_metag;

procedure delete_metatag( surl varchar2, id in integer )
as

 cursor c1(id integer) is select * from umo_attributes where attribute_id = id;
 cursor c2(id integer) is select u.umo_id,u.aid,ua.attribute_id,ua.position_id,ua.value,u.umo_type from umo_attribute ua, umo u where ua.umo_id = u.umo_id and attribute_id = id;

 c1rec		c1%ROWTYPE;
 sessid		integer;
 nmb		integer;
 sts		varchar2(200);
 tmp		varchar2(4000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.DELETE_METATAG');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 for c2rec in c2( id ) loop
   if c2rec.umo_type = 'AUDIO'
    then
     myaudio.audio_api(v_umo=>c2rec.umo_id,attrib_id=>c2rec.attribute_id,data_value=>c2rec.value,acid=>c2rec.aid,posid=>nvl(c2rec.position_id,1),action=>'DELETE');
   elsif c2rec.umo_type = 'VIDEO'
    then
     myvideo.video_api(v_umo=>c2rec.umo_id,attrib_id=>c2rec.attribute_id,data_value=>c2rec.value,acid=>c2rec.aid,posid=>nvl(c2rec.position_id,1),action=>'DELETE');
   elsif c2rec.umo_type = 'RELATIONAL'
    then
     myrelational.relational_api(v_umo=>c2rec.umo_id,attrib_id=>c2rec.attribute_id,data_value=>c2rec.value,acid=>c2rec.aid,posid=>nvl(c2rec.position_id,1),action=>'DELETE');
   elsif c2rec.umo_type = 'BLUEPRINT'
    then
     myblueprint.blueprint_api(v_umo=>c2rec.umo_id,attrib_id=>c2rec.attribute_id,data_value=>c2rec.value,acid=>c2rec.aid,posid=>nvl(c2rec.position_id,1),action=>'DELETE');
   elsif c2rec.umo_type = 'DOCUMENT'
    then
     mydocument.document_api(v_umo=>c2rec.umo_id,attrib_id=>c2rec.attribute_id,data_value=>c2rec.value,acid=>c2rec.aid,posid=>nvl(c2rec.position_id,1),action=>'DELETE');
   end if;
 end loop;

 --
 delete from umo_attribute where attribute_id = to_number(id);
 delete from umo_attributes where attribute_id = to_number(id);
 delete from umo_index where attribute_id = to_number(id);
 --

 commit;
 main_title( surl, sessid, LNG3.ADM_TXT_892, style=>'NOMENU' );
 htp.p( '<CENTER>' );
 htp.nl;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_892 );
 htp.nl;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
 -- meta_tags( surl, LNG3.ADM_TXT_892 );
exception when others then
 glbx.error_details( 'ADM', 'DELETE_METATAG', errmsg=>sqlerrm, extdet=>null);
end delete_metatag;

procedure brands( surl varchar2, msg in varchar2 default null )
as

 cursor c1 is select * from brand where is_public = 'T' order by brand_name;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.BRANDS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_875, helpid=>'A73' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_brands' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( LNG3.ADM_TXT_876, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1', 40, 100, c1rec.brand_name ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.formhidden( 'P2', c1rec.brand_id );
  htp.tablerowclose;
 end loop;
 for j in 1..10 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1', 40, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.formhidden( 'P2', NULL );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null,LNG3.ADM_TXT_878 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'BRANDS', errmsg=>sqlerrm, extdet=>null);
end brands;

procedure accept_brands( surl varchar2, p1 in MYARRAY, p2 in MYARRAY )
as

 cursor c1(iname varchar2) is select 'x' from brand where brand_name = iname and is_public = 'T';
 cursor c2 is select max(brand_id) mx from brand;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_BRANDS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 for j in p1.first..p1.last loop
  if p1(j) is not null and p2(j) is null
  then
   open c1(upper(p1(j)));
   fetch c1 into c1rec;
   if c1%NOTFOUND
    then
     close c1;
     open c2;
     fetch c2 into c2rec;
     close c2;
     if c2rec.mx is null
      then
       c2rec.mx := 1;
      else
       c2rec.mx := c2rec.mx + 1;
     end if;
     insert into brand(brand_id,brand_name) values (c2rec.mx,upper(p1(j)));
    else
     close c1;
   end if;
  elsif p1(j) is not null and p2(j) is not null
  then
   update brand set brand_name = upper(p1(j)) where brand_id = to_number(p2(j));
  elsif p1(j) is null and p2(j) is not null
  then
   update product set brand_id = NULL where brand_id = to_number(p2(j));
   update phg_price_item set brand_id = NULL where brand_id = to_number(p2(j));
   delete from brand where brand_id = to_number(p2(j));
  end if;
 end loop;
 commit;
 brands( surl,LNG3.ADM_TXT_518 );
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_BRANDS', errmsg=>sqlerrm, extdet=>null);
end accept_brands;

procedure class( surl varchar2, msg in varchar2 default null )
as

 cursor c1 is select * from class_of_product order by product_class;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.CLASS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG4.AHC_TXT_402, helpid=>'A87' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_class' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( LNG3.ADM_TXT_190, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1', 40, 100, c1rec.product_class ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.formhidden( 'P2', c1rec.product_class );
  htp.tablerowclose;
 end loop;
 for j in 1..5 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1', 40, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.formhidden( 'P2', NULL );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null,LNG3.ADM_TXT_878 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'CLASS', errmsg=>sqlerrm, extdet=>null);
end class;

procedure accept_class( surl varchar2, p1 in MYARRAY, p2 in MYARRAY )
as

 cursor c1(iname varchar2) is select 'x' from class_of_product where product_class = iname;

 c1rec		c1%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_CLASS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 for j in p1.first..p1.last loop
  if p1(j) is not null and p2(j) is null
  then
   open c1(upper(p1(j)));
   fetch c1 into c1rec;
   if c1%NOTFOUND
    then
     close c1;
     insert into class_of_product(product_class) values (upper(p1(j)));
    else
     close c1;
   end if;
  elsif p1(j) is not null and p2(j) is not null
  then
   update class_of_product set product_class = upper(p1(j)) where product_class = upper(p2(j));
  elsif p1(j) is null and p2(j) is not null
  then
   update product set product_class = NULL where product_class = upper(p2(j));
   delete from class_of_product where product_class = upper(p2(j));
  end if;
 end loop;
 commit;
 class( surl, LNG4.AHC_TXT_559 );
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_CLASS', errmsg=>sqlerrm, extdet=>null);
end accept_class;

procedure dict( surl in varchar2, search_term in varchar2 default null, term_type in varchar2 default null, search_number in varchar2 default '100', msg in varchar2 default null )
as

 cursor c1(st varchar2, tt varchar2) is select * from dictionary where association_type = tt and term like st;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;
 src		integer;
 foundrec	boolean;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.DICT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_879, helpid=>'A74' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 begin src := to_number(search_number); exception when others then src := 100; end;

 htp.p( '<CENTER>' );
 htp.formopen( 'adm.dict' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG3.ADM_TXT_883) );
   htp.tabledata( htf.formtext( 'SEARCH_TERM', 20, 100, search_term ) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio( 'TERM_TYPE', 'D', 'CHECKED' ) || ' ' || LNG3.ADM_TXT_880 );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio( 'TERM_TYPE', 'S' ) || ' ' || LNG4.AHC_TXT_401 );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio( 'TERM_TYPE', 'A' ) || ' ' || LNG3.ADM_TXT_881 );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( LNG3.ADM_TXT_884 );
   htp.tabledata( htf.formtext( 'SEARCH_NUMBER', 5, 10, to_char(src) ) );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG.GLB_TXT_092 );
 htp.formclose;
 if search_term is not null
  then
   htp.line;
   htp.nl;
   htp.bold( LNG3.ADM_TXT_885 );
   htp.nl;
   foundrec := FALSE;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
   htp.tablerowopen;
   htp.p( '<TD>' );
   htp.dlistopen;
   for c1rec in c1(upper(search_term), term_type ) loop
    foundrec := TRUE;
    src := src - 1;
    if src = 0 then exit; end if;
    if c1rec.association_type = 'D'
     then
      htp.listitem( c1rec.term || ' ' ||
                    htf.anchor( 'adm.accept_dict?surl=' || surl || '&action=DELETE&search_number=' || search_number || '&p1=' || c1rec.association_type || '&p2=' || replace(c1rec.term,' ','+'),'[' || LNG.SLD_TXT_004 || ']') );
    elsif c1rec.association_type = 'S'
     then
      htp.listitem( c1rec.term || ' ' ||
                    htf.anchor( 'adm.accept_dict?surl=' || surl || '&action=DELETE&search_number=' || search_number || '&p1=' || c1rec.association_type || '&p2=' || replace(c1rec.term,' ','+'),'[' || LNG.SLD_TXT_004 || ']') );
     else
      htp.listitem( c1rec.term || ' ' || LNG.PHG_TXT_505 || ' ' || c1rec.association || ' ' ||
                    htf.anchor( 'adm.accept_dict?surl=' || surl || '&action=DELETE&search_number=' || search_number || '&p1=' || c1rec.association_type || '&p2=' || replace(c1rec.term,' ','+') || '&p3=' || replace(c1rec.association,' ','+'),'[' || LNG.SLD_TXT_004 || ']') );
    end if;
   end loop;
   htp.dlistclose;
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tableclose;
   if not foundrec then htp.nl; htp.bold( LNG3.ADM_TXT_886 ); htp.nl; end if;
 end if;
 htp.line;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_882 );
 htp.nl;
 htp.formopen( 'adm.accept_dict' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.formhidden( 'ACTION', 'INSERT' );
 htp.formhidden( 'SEARCH_NUMBER', search_number );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formradio( 'P1', 'D' ) || ' ' || LNG3.ADM_TXT_880 );
   htp.tabledata( htf.formtext( 'P2', 30, 100 ) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio( 'P1', 'S' ) || ' ' || LNG4.AHC_TXT_401 );
   htp.tabledata( htf.formtext( 'P2', 30, 100 ) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio( 'P1', 'A', 'CHECKED' ) || ' ' || LNG3.ADM_TXT_881 );
   htp.tabledata( htf.formtext( 'P2', 30, 100 ) || ' ' || LNG.PHG_TXT_505 || ' ' || htf.formtext( 'P3', 30, 100 ));
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_882 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'DICT', errmsg=>sqlerrm, extdet=>'SEARCH_TERM:' || search_term);
end dict;

procedure accept_dict( surl varchar2, action in varchar2, search_number in varchar2, p1 in varchar2, p2 in GLBX.MYARRAY, p3 in varchar2 default null )
as

 cursor c1(st varchar2, assoc char) is select 'x' from dictionary where association_type = assoc and term = st;
 cursor c2(st varchar2, sta varchar2) is select 'x' from dictionary where association_type = 'A' and term = st and association_type = sta;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 sid		integer;
 tmp		char(1);
 trm		varchar2(100);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_BRANDS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if action = 'DELETE'
  then
   if p1 = 'D'
    then
     delete from dictionary where association_type = 'D' and term = p2(1);
    elsif p1 = 'A'
     then
      delete from dictionary where association_type = 'A' and term = p2(1) and association = p3;
    elsif p1 = 'S'
     then
      delete from dictionary where association_type = 'S' and term = p2(1);
   end if;
   commit;
   dict( surl, search_number=>search_number,msg=>LNG3.ADM_TXT_888);
   return;
 end if;

 if p1 = 'A' and p3 is null
  then
   dict( surl, search_number=>search_number,msg=>LNG3.ADM_TXT_889);
   return;
 end if;

 if p1 in ('D','S')
  then
   if p1 = 'D' then trm := upper(p2(1)); else trm := upper(p2(2)); end if;
   open c1(trm,p1);
   fetch c1 into tmp;
   if c1%FOUND or trm is null
    then
     close c1;
     dict( surl, search_term=>trm, term_type=>p1,search_number=>search_number,msg=>LNG3.ADM_TXT_890);
     return;
    else
     close c1;
     insert into dictionary(association_type,term) values (p1,trm);
     commit;
     dict( surl, search_term=>trm, term_type=>p1,search_number=>search_number,msg=>LNG3.ADM_TXT_887);
   end if;
 elsif p1 = 'A'
  then
   open c2(upper(p2(3)),upper(p3));
   fetch c2 into tmp;
   if c2%FOUND or p2(3) is null
    then
     close c2;
     dict( surl, search_term=>upper(p2(3)), term_type=>'A',search_number=>search_number,msg=>LNG3.ADM_TXT_890);
     return;
    else
     close c2;
     insert into dictionary(association_type,term,association) values ('A',upper(p2(3)),upper(p3));
     commit;
     dict( surl, search_term=>upper(p2(3)), term_type=>'A',search_number=>search_number,msg=>LNG3.ADM_TXT_887);
   end if;
 end if;
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_DICT', errmsg=>sqlerrm, extdet=>null);
end accept_dict;

procedure theme_objects( surl varchar2, ttype in varchar2 )
as
 cursor c1(ttype varchar2) is select * from main_object where theme_type = ttype order by mid;
 cursor c2(v_mid integer) is select * from main_value where mid = v_mid order by mvid;

 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.THEME_OBJECTS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if ttype is null then htp.bold( 'Must Enter in a Value' ); return; end if;

 main_title( surl, sessid, LNG3.ADM_TXT_896 || ' : ' || ttype, style=>'NOMENU', helpid=>'A76' );
 htp.p( '<CENTER>' );
 htp.nl;
 htp.formopen( 'adm.accept_theme_objects' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.formhidden( 'TTYPE', ttype );
 for c1rec in c1(ttype) loop
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.PHG_TXT_022), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.formhidden( 'P0', c1rec.mid );
    htp.tabledata( htf.formtext( 'P1', 30, 100, c1rec.name ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG3.ADM_TXT_173), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.formtext( 'P2', 30, 100, c1rec.img ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
   htp.tablerowclose;
  for c2rec in c2(c1rec.mid) loop
   htp.tablerowopen;
    if c2%ROWCOUNT = 1
     then
      htp.tabledata( htf.bold(LNG3.ADM_TXT_898), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
     else
      htp.tabledata( '&nbsp;', cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    end if;
    htp.formhidden( 'P4', '[' || c1rec.mid || ']' || c2rec.mvid );
    htp.tabledata( htf.formtext( 'P3', 30, 100, c2rec.name_default ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
   htp.tablerowclose;
  end loop;
  for j in 1..5 loop
   htp.tablerowopen;
    htp.tabledata( '&nbsp;', cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.formhidden( 'P4', '[' || c1rec.mid || ']0' );
    htp.tabledata( htf.formtext( 'P3', 30, 100, null ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
 end loop;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.PHG_TXT_022), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.formhidden( 'P0', '0' );
    htp.tabledata( htf.formtext( 'P1', 30, 100, null ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG3.ADM_TXT_173), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.formtext( 'P2', 30, 100, null ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
   htp.tablerowclose;
  for j in 1..5 loop
   htp.tablerowopen;
    if j = 1
     then
      htp.tabledata( htf.bold(LNG3.ADM_TXT_898), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
     else
      htp.tabledata( '&nbsp;', cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    end if;
    htp.formhidden( 'P4', '[0]0' );
    htp.tabledata( htf.formtext( 'P3', 30, 100, null ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_897 );
 htp.formclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'THEME_OBJECTS', errmsg=>sqlerrm, extdet=>'TTYPE:' || ttype);
end theme_objects;

procedure accept_theme_objects( surl in varchar2, ttype in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY )
as


 cursor c1 is select max(mid) from main_object;

 sessid	integer;
 sts	varchar2(200);
 tmp	varchar2(1000);
 nmb	integer;
 nvid	integer;
 pnum	integer;
 newp	integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ACCEPT_THEME_OBJECTS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 for j in p0.first..p0.last loop
  if p0(j) = '0'
   then
    if p1(j) is null and p2(j) is null
     then
      null;
     else
      open c1;
      fetch c1 into nmb;
      close c1;
      nmb := nvl(nmb,0) + 1;
      insert into main_object(mid,theme_type,name,img) values (nmb,ttype,p1(j),p2(j));
    end if;
   else
    if p1(j) is null and p2(j) is null
     then
      delete from main_value_customer where mvid in (select mvid from main_value where mid = p0(j));
      delete from main_value where mid = p0(j);
      delete from main_object where mid = p0(j);
     else
      update main_object
       set
        name = p1(j),
        img = p2(j)
      where mid = p0(j);
    end if;
  end if;
 end loop;
 for j in p4.first..p4.last loop
  nvid := to_number(substr(p4(j),2,instr(p4(j),']')-2));
  if nvid = 0 then nvid := nmb; end if;
  pnum := to_number(substr(p4(j),instr(p4(j),']')+1));
  if nvl(nvid,0) = 0
   then
    null;
   else
    if pnum = 0
     then
      if p3(j) is null
       then
        null;
       else
        select s_main_value.nextval into newp from dual;
        insert into main_value(mid,mvid,name_default) values(nvid,newp,p3(j));
      end if;
     else
      if p3(j) is null
       then
        delete from main_value_customer where mvid = pnum;
        delete from main_value where mvid = pnum;
       else
        update main_value set name_default = p3(j) where mvid = pnum;
      end if;
    end if;
  end if;
 end loop;

 commit;
 theme_objects(surl,ttype);
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_THEME_OBJECTS', errmsg=>sqlerrm, extdet=>'TTYPE:' || ttype);
end accept_theme_objects;

procedure manage_fonts(surl varchar2, msg in varchar2 default null )
as

 cursor c1 is select font_name from fonts order by font_name;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MANAGE_FONTS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_899, helpid=>'A77' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_manage_fonts' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( LNG3.ADM_TXT_900, cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tableheader( '&nbsp;', cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
 htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1', 40, 1000, c1rec.font_name ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata('<FONT FACE=' || c1rec.font_name || '>' || 'abcdefghijklmnopqrstuvwxyz' || '</FONT>',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.formhidden( 'P2', c1rec.font_name );
  htp.tablerowclose;
 end loop;
 for j in 1..4 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1', 40, 1000 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( '&nbsp;', cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.formhidden( 'P2', NULL );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null,LNG3.ADM_TXT_899 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MANAGE_FONTS', errmsg=>sqlerrm, extdet=>null);
end manage_fonts;

procedure accept_manage_fonts( surl varchar2, p1 in MYARRAY, p2 in MYARRAY )
as

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_MANAGE_FONTS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 for j in p1.first..p1.last loop
 if p1(j) is not null and p2(j) is null
  then
    insert into fonts(font_name) values (p1(j));
 elsif p1(j) is not null and p2(j) is not null
  then
   update fonts set font_name = p1(j) where font_name = p2(j);
   update theme set text_font = p1(j) where text_font = p2(j);
   update theme set lhs_text_font = p1(j) where lhs_text_font = p2(j);
   update theme set det_text_font = p1(j) where det_text_font = p2(j);
   update theme set det_title_font = p1(j) where det_title_font = p2(j);
   update theme set top_text_font = p1(j) where top_text_font = p2(j);
   update theme set gallery_text_font = p1(j) where gallery_text_font = p2(j);
   update theme set title_text_font = p1(j) where title_text_font = p2(j);
 elsif p1(j) is null and p2(j) is not null
  then
   delete from fonts where font_name = p2(j);
  end if;
 end loop;
 commit;
 manage_fonts( surl, LNG3.ADM_TXT_901 );
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_MANAGE_FONTS', errmsg=>sqlerrm, extdet=>null);
end accept_manage_fonts;

procedure sec_roles( surl in varchar2 )
as

 cursor c1 is select * from piction_roles order by role_name;

 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.SEC_ROLES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_913, helpid=>'A79' );
 htp.p('<CENTER>');
 htp.nl;
 htp.anchor2( 'adm.role_edit?surl=' || glbx.rndsurl(surl) || '&rid=0&msg=', LNG3.ADM_TXT_640, ctarget=>'ADM_RIGHT_WIN' );
 htp.nl;
 for c1rec in c1 loop
  htp.anchor2( 'adm.role_edit?surl=' || glbx.rndsurl(surl) || '&rid=' || c1rec.role_id,c1rec.role_name || ' (' || c1rec.role_type || ')',ctarget=>'ADM_RIGHT_WIN' );
  htp.nl;
 end loop;
 htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'SEC_ROLES', errmsg=>sqlerrm, extdet=>null);
end sec_roles;

procedure role_edit( surl in varchar2, rid in integer, msg in varchar2 default null )
as

 cursor c1(rid integer) is select * from piction_roles where role_id = rid;
 cursor c2(rid integer) is select * from piction_roles_rules where role_id = rid order by table_owner,table_name;

 c1rec	c1%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ROLE_EDIT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 open c1(rid);
 fetch c1 into c1rec;
 close c1;

 if rid = 0
  then
   main_title( surl, sessid, LNG3.ADM_TXT_914 , style=>'NOMENU', helpid=>'A79' );
  else
   main_title( surl, sessid, LNG3.ADM_TXT_914 || ': ' || c1rec.role_name , style=>'NOMENU', helpid=>'A79' );
 end if;

 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_role_edit' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.formhidden( 'RID', rid );
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
     htp.tabledata( htf.bold( LNG3.ADM_TXT_916 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( htf.formtext('P1',40, 100, c1rec.role_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( htf.formhidden('P3', c1rec.role_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_917 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.formselectopen( 'P2' );
      if c1rec.role_type = 'REPORT'
       then
        htp.formselectoption( 'REPORT', 'SELECTED' );
       else
        htp.formselectoption( 'REPORT' );
      end if;
      if c1rec.role_type = 'SCREEN'
       then
        htp.formselectoption( 'SCREEN', 'SELECTED' );
       else
        htp.formselectoption( 'SCREEN' );
      end if;
      if c1rec.role_type = 'TABLE'
       then
        htp.formselectoption( 'TABLE', 'SELECTED' );
       else
        htp.formselectoption( 'TABLE' );
      end if;
      if c1rec.role_type = 'PARAMETER'
       then
        htp.formselectoption( 'PARAMETER', 'SELECTED' );
       else
        htp.formselectoption( 'PARAMETER' );
      end if;
      if c1rec.role_type = 'SECURITY ROLE'
       then
        htp.formselectoption( 'SECURITY ROLE', 'SELECTED' );
       else
        htp.formselectoption( 'SECURITY ROLE' );
      end if;
     htp.formselectclose;
     htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 if rid = 0 or c1rec.role_type in ('SCREEN','REPORT','SECURITY ROLE')
  then
   htp.formhidden( 'R1', null );
   htp.formhidden( 'R2', null );
   htp.formhidden( 'R3', null );
   htp.formhidden( 'R4', null );
   htp.formhidden( 'R5', null );
   htp.formhidden( 'R6', null );
   htp.formhidden( 'R7', null );
   htp.formhidden( 'R8', null );
   if rid = 0
    then
     htp.formsubmit( null, LNG3.ADM_TXT_914 );
    else
     htp.formsubmit( null, LNG3.ADM_TXT_915 );
   end if;
   htp.formclose;
   htp.p( '</CENTER' );
   htp.htmlclose;
   return;
 end if;

 if c1rec.role_type = 'PARAMETER'
  then
   htp.nl;
   htp.bold( LNG3.ADM_TXT_936 );
   htp.nl;
   htp.formhidden( 'R3', null );
   htp.formhidden( 'R4', null );
   htp.formhidden( 'R5', null );
   htp.formhidden( 'R6', null );
   htp.formhidden( 'R7', null );
   htp.formhidden( 'R8', null );
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_868),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext( 'R1', 30, 100, c1rec.parameter_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_869),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext( 'R2', 40, 4000, c1rec.parameter_value ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( null, LNG3.ADM_TXT_915 );
   htp.formclose;
   htp.p( '</CENTER' );
   htp.htmlclose;
   return;
 end if;

 htp.nl;
 htp.bold( LNG3.ADM_TXT_918 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_919 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG.PHG_TXT_348 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_296 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_921 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_922 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG.CST_TXT_013 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_924 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG2.FNM_TXT_016 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( '&nbsp;' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;

 for c2rec in c2(rid) loop
  htp.tablerowopen;
   if c2rec.restriction_type = 'RESTRICT'
    then
     htp.tabledata( htf.formselectopen( 'R1' ) || htf.formselectoption('RESTRICT', 'SELECTED' ) || htf.formselectoption( 'COLUMN' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
    else
     htp.tabledata( htf.formselectopen( 'R1' ) || htf.formselectoption('RESTRICT' ) || htf.formselectoption( 'COLUMN', 'SELECTED' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata(htf.formtext('R2', 5, 100, c2rec.table_owner ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata(htf.formtext('R3', 15, 100, c2rec.table_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   if c2rec.restriction_type = 'RESTRICT'
    then
     htp.tabledata(htf.formtext('R4', 30, 4000, c2rec.where_clause ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'R5', null );
     htp.tabledata( '&nbsp;' ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'R6', null );
     htp.tabledata( '&nbsp;' ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'R7', null );
     htp.tabledata( '&nbsp;' ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.formhidden( 'R8', null );
     htp.tabledata( '&nbsp;' ,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    else
     htp.tabledata(htf.formtext('R4', 30, 100, c2rec.if_column ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER">' );
     htp.formselectopen( 'R5' );
     if c2rec.if_expression = '=' then htp.formselectoption( '=', 'SELECTED' ); else htp.formselectoption( '=' ); end if;
     if c2rec.if_expression = '<' then htp.formselectoption( '<', 'SELECTED' ); else htp.formselectoption( '<' ); end if;
     if c2rec.if_expression = '>' then htp.formselectoption( '>', 'SELECTED' ); else htp.formselectoption( '>' ); end if;
     if c2rec.if_expression = '<=' then htp.formselectoption( '<=', 'SELECTED' ); else htp.formselectoption( '<=' ); end if;
     if c2rec.if_expression = '>=' then htp.formselectoption( '>=', 'SELECTED' ); else htp.formselectoption( '>=' ); end if;
     if c2rec.if_expression = '<>' then htp.formselectoption( '<>', 'SELECTED' ); else htp.formselectoption( '<>' ); end if;
     if c2rec.if_expression = 'IS NULL' then htp.formselectoption( 'IS NULL', 'SELECTED' ); else htp.formselectoption( 'IS NULL' ); end if;
     if c2rec.if_expression = 'LIKE' then htp.formselectoption( 'LIKE', 'SELECTED' ); else htp.formselectoption( 'LIKE' ); end if;
     htp.formselectclose;
     htp.p( '</TD>' );
     htp.tabledata(htf.formtext('R6', 10, 100, c2rec.if_value ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER">' );
     htp.formselectopen( 'R7' );
     if c2rec.if_value_type = 'CONSTANT' then htp.formselectoption( 'CONSTANT', 'SELECTED' ); else htp.formselectoption( 'CONSTANT' ); end if;
     if c2rec.if_value_type = 'SQL' then htp.formselectoption( 'SQL', 'SELECTED' ); else htp.formselectoption( 'SQL' ); end if;
     htp.formselectclose;
     htp.p( '</TD>' );
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER">' );
     htp.formselectopen( 'R8' );
     if c2rec.if_value_type = 'DISABLE EDIT' then htp.formselectoption( 'DISABLE EDIT', 'SELECTED' ); else htp.formselectoption( 'DISABLE EDIT' ); end if;
     if c2rec.if_value_type = 'DISABLE BROWSE' then htp.formselectoption( 'DISABLE BROWSE', 'SELECTED' ); else htp.formselectoption( 'DISABLE BROWSE' ); end if;
     htp.formselectclose;
     htp.p( '</TD>' );
   end if;
  htp.tabledata(htf.anchor( 'adm.del_role_edit?surl=' || glbx.rndsurl(surl) || '&rid=' || rid || '&towner=' || c2rec.table_owner || '&tname=' || c2rec.table_name, LNG.SLD_TXT_004 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;

  for j in 1..3 loop
   htp.tablerowopen;
   htp.tabledata( htf.formselectopen( 'R1' ) || htf.formselectoption('RESTRICT', 'SELECTED' ) || htf.formselectoption( 'COLUMN' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata(htf.formtext('R2', 5, 100 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata(htf.formtext('R3', 15, 100 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata(htf.formtext('R4', 30, 100 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER">' );
     htp.formselectopen( 'R5' );
     htp.formselectoption( '=' );
     htp.formselectoption( '<' );
     htp.formselectoption( '>' );
     htp.formselectoption( '<=' );
     htp.formselectoption( '>=' );
     htp.formselectoption( '<>' );
     htp.formselectoption( 'IS NULL' );
     htp.formselectoption( 'LIKE' );
     htp.formselectclose;
     htp.p( '</TD>' );
   htp.tabledata(htf.formtext('R6', 10, 100 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata( htf.formselectopen( 'R7' ) || htf.formselectoption('CONSTANT', 'SELECTED' ) || htf.formselectoption( 'SQL' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( htf.formselectopen( 'R8' ) || htf.formselectoption('DISABLE EDIT', 'SELECTED' ) || htf.formselectoption( 'DISABLE BROWSE' ) || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_915 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'ADM', 'ROLE_EDIT', errmsg=>sqlerrm, extdet=>null);
end role_edit;

procedure accept_role_edit( surl in varchar2, rid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, r1 in GLBX.MYARRAY, r2 in GLBX.MYARRAY, r3 in GLBX.MYARRAY, r4 in GLBX.MYARRAY, r5 in GLBX.MYARRAY, r6 in GLBX.MYARRAY, r7 in GLBX.MYARRAY, r8 in GLBX.MYARRAY )
as

 cursor c1(rname varchar2) is select max(role_id) role_id from piction_roles where role_name = rname;
 cursor c2(rname varchar2, rid integer) is select 'x' from piction_roles where role_name = rname and role_id <> rid;
 cursor c3 is select max(role_id) role_id from piction_roles;

 c1rec	c1%ROWTYPE;
 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_ROLE_EDIT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if rid = 0 and p1 is null then role_edit(surl,rid,LNG3.ADM_TXT_930); return; end if;

 if rid = 0
  then
   open c1( upper(p1) );
   fetch c1 into c1rec;
   close c1;
   if nvl(c1rec.role_id,0) > 0
    then
     role_edit(surl,rid,LNG3.ADM_TXT_929);
     return;
   end if;
   open c3;
   fetch c3 into c1rec;
   close c3;
   if p2 = 'PARAMETER'
    then
     insert into piction_roles(role_id,role_name,role_type,parameter_name,parameter_value) values (nvl(c1rec.role_id,0)+1,upper(p1),p2,upper(r1(1)),r2(1));
    else
     insert into piction_roles(role_id,role_name,role_type) values (nvl(c1rec.role_id,0)+1,upper(p1),p2);
   end if;
   commit;
   role_edit(surl,nvl(c1rec.role_id,0)+1,LNG3.ADM_TXT_926);
   return;
 end if;

 if p1 is null
  then
   role_edit(surl,rid,LNG3.ADM_TXT_930);
   return;
 end if;

 if p2 = 'PARAMETER'
  then
   update piction_roles
    set
     parameter_name = upper(r1(1)),
     parameter_value = r2(1)
   where role_id = rid;
 end if;

 if upper(p1) <> p3
  then
   open c2( upper(p1), rid );
   fetch c2 into c1rec;
   if c2%FOUND
    then
     close c2;
     role_edit(surl,rid,LNG3.ADM_TXT_929);
     return;
   end if;
   close c2;
   update piction_roles set role_name = upper(p1) where role_id = rid;
 end if;
 update piction_roles set role_type = p2 where role_id = rid;

 delete from piction_roles_rules where role_id = rid;
 if p2 = 'TABLE'
  then
   for j in r1.first..r1.last loop
    if r3(j) is not null
     then
      if r1(j) = 'RESTRICT'
       then
        insert into piction_roles_rules(role_id,table_owner,table_name,restriction_type,where_clause) values
         (rid,upper(r2(j)),upper(r3(j)),r1(j),r4(j));
      elsif r1(j) = 'COLUMN'
       then
        insert into piction_roles_rules(role_id,table_owner,table_name,restriction_type,if_column,if_expression,if_value,if_value_type,if_action) values
         (rid,upper(r2(j)),upper(r3(j)),r1(j),r4(j),r5(j),r6(j),r7(j),r8(j));
      end if;
    end if;
   end loop;
 end if;
 commit;
 role_edit(surl,rid,LNG3.ADM_TXT_642);

exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_ROLE_EDIT', errmsg=>sqlerrm, extdet=>'RID:' || rid);
end accept_role_edit;

procedure del_role_edit( surl in varchar2, rid in integer, towner in varchar2, tname in varchar2 )
as

 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.DEL_ROLE_EDIT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 delete from piction_roles_rules where role_id = rid and table_owner = towner and table_name = tname;
 commit;
 role_edit(surl,rid,LNG3.ADM_TXT_928);
exception when others then
 glbx.error_details( 'ADM', 'DEL_ROLE_EDIT', errmsg=>sqlerrm, extdet=>'RID:' || rid);
end del_role_edit;

procedure mfc_types(surl varchar2, msg in varchar2 default null )
as

 cursor c1 is select man_type from man_options order by man_type;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MFC_TYPES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_962, helpid=>'A80' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_mfc_types' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( LNG3.ADM_TXT_962, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1', 20, 20, c1rec.man_type ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.formhidden( 'P2', c1rec.man_type );
  htp.tablerowclose;
 end loop;
 for j in 1..10 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1', 20, 20 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.formhidden( 'P2', NULL );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_964 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MFC_TYPES', errmsg=>sqlerrm, extdet=>null);
end mfc_types;

procedure accept_mfc_types( surl varchar2, p1 in MYARRAY, p2 in MYARRAY )
as

 cursor c2( mtype varchar2 ) is select count('x') tot from man_options where man_type = mtype;
 cursor c3( mtype varchar2 ) is select count('x') tot from manufacturer where man_type = mtype;

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_MFC_TYPES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 for j in p1.first..p1.last loop
 if p1(j) is not null and p2(j) is null
  then
    open c2( p1(j) );
    fetch c2 into c2rec;
    close c2;
    if c2rec.tot = 0
     then
      insert into man_options(man_type) values (p1(j));
     else
      mfc_types( surl, LNG3.ADM_TXT_966 );
      commit;
      return;
    end if;
 elsif p1(j) is not null and p2(j) is not null
  then
   if p1(j) <> p2(j)
    then
     update man_options set man_type = p1(j) where man_type = p2(j);
     update product_keys set man_type = p1(j) where man_type = p2(j);
     update manufacturer set man_type = p1(j) where man_type = p2(j);
   end if;
 elsif p1(j) is null and p2(j) is not null
  then
   open c3( p2(j) );
   fetch c3 into c3rec;
   close c3;
   if c3rec.tot = 0
    then
     delete from product_keys where man_type = p2(j);
     delete from man_options where man_type = p2(j);
    else
     commit;
     mfc_types( surl, LNG3.ADM_TXT_965 );
     return;
   end if;
  end if;
 end loop;
 commit;
 mfc_types( surl, LNG3.ADM_TXT_963 );
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_MFC_TYPES', errmsg=>sqlerrm, extdet=>null);
end accept_mfc_types;

procedure preorder_stats(surl varchar2, msg in varchar2 default null )
as

 cursor c1 is
  select p.business_name,p.pid, count('x') tot, sum( decode(nvl(length(sendto_name)+length(po.contact_email),0),0,0,1 )) tot1,
         sum(nvl(glbx.grand_total_payment(poid),0)) tot_ord, avg(glbx.grand_total_payment(poid)) avg_ord,
         min(glbx.grand_total_payment(poid)) min_ord, max(glbx.grand_total_payment(poid)) max_ord,
         sum(decode(sign(glbx.grand_total_payment(poid) - 100),-1,0,1)) big_ord
  from purchase_order po, photographer p
  where po.status in (LNG.ORD_TXT_120,LNG4.AHC_TXT_672,LNG4.AHC_TXT_706,'PreOrder - Confirmed without Payment') and
        p.pid = po.pid
  group by p.business_name,p.pid;

 cursor c2 is
  select count('x') tot, sum( decode(nvl(length(sendto_name)+length(po.contact_email),0),0,0,1 )) tot1,
         sum(nvl(glbx.grand_total_payment(poid),0)) tot_ord, avg(glbx.grand_total_payment(poid)) avg_ord,
         min(glbx.grand_total_payment(poid)) min_ord, max(glbx.grand_total_payment(poid)) max_ord,
         sum(decode(sign(glbx.grand_total_payment(poid) - 100),-1,0,1)) big_ord
  from purchase_order po
  where po.status in (LNG.ORD_TXT_120,LNG4.AHC_TXT_672,LNG4.AHC_TXT_706,'PreOrder - Confirmed without Payment');

 cursor c3( vpid integer ) is select count('x') tot2 from purchase_order where status not in (LNG.ORD_TXT_120,LNG4.AHC_TXT_672,LNG4.AHC_TXT_706,'PreOrder - Confirmed without Payment') and pid = vpid;
 cursor c4 is select count('x') tot2 from purchase_order where status in (LNG.ORD_TXT_120,LNG4.AHC_TXT_672,LNG4.AHC_TXT_706,'PreOrder - Confirmed without Payment');

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.PREORDER_STATS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG4.AHC_TXT_084, helpid=>'A81', style=>'NOMENU' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( LNG3.ADM_TXT_261, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' ); -- Photographer
  htp.tableheader( LNG4.AHC_TXT_085, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' ); -- # Preorders
  htp.tableheader( LNG4.AHC_TXT_086, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' ); -- # With Address Details
  htp.tableheader( LNG4.AHC_TXT_091, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' ); -- Average
  htp.tableheader( LNG4.AHC_TXT_087, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' ); -- Average
  htp.tableheader( LNG4.AHC_TXT_088, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' ); -- Smallest
  htp.tableheader( LNG4.AHC_TXT_089, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' ); -- Largest
  htp.tableheader( LNG4.AHC_TXT_090, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' ); -- # > $100
 htp.tablerowclose;
 for c1rec in c1 loop
 htp.tablerowopen;
  c3rec.tot2 := 0;
  open c3(c1rec.pid);
  fetch c3 into c3rec;
  close c3;
  htp.tabledata( htf.bold(c1rec.business_name), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
  htp.tabledata( c1rec.tot || '/' || c3rec.tot2 || ' (' || round( (c1rec.tot / (c1rec.tot + c3rec.tot2)) * 100 ) || '%)', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
  if c1rec.tot1 > 0
   then
    htp.tabledata( htf.anchor( 'adm.preorder_list?surl=' || surl || '&phgid=' || c1rec.pid, c1rec.tot1), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
   else
    htp.tabledata( c1rec.tot1, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
  end if;
  htp.tabledata( to_char(c1rec.tot_ord,LNG.MONEY_FORMAT), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
  htp.tabledata( to_char(c1rec.avg_ord,LNG.MONEY_FORMAT), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
  htp.tabledata( to_char(c1rec.min_ord,LNG.MONEY_FORMAT), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
  htp.tabledata( to_char(c1rec.max_ord,LNG.MONEY_FORMAT), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
  htp.tabledata( c1rec.big_ord, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
 htp.tablerowclose;
 end loop;
 open c2;
 fetch c2 into c2rec;
 close c2;
 open c4;
 fetch c4 into c4rec;
 close c4;
 htp.tablerowopen;
  htp.tabledata( htf.bold(LNG.CST_TXT_138), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
  htp.tabledata( htf.bold(c2rec.tot || '/' || c4rec.tot2) || ' (' || round( (c2rec.tot / (c2rec.tot + c4rec.tot2)) * 100 ) || '%)', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
  htp.tabledata( htf.bold(c2rec.tot1), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
  htp.tabledata( htf.bold(to_char(c2rec.tot_ord,LNG.MONEY_FORMAT)), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
  htp.tabledata( htf.bold(to_char(c2rec.avg_ord,LNG.MONEY_FORMAT)), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
  htp.tabledata( htf.bold(to_char(c2rec.min_ord,LNG.MONEY_FORMAT)), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
  htp.tabledata( htf.bold(to_char(c2rec.max_ord,LNG.MONEY_FORMAT)), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
  htp.tabledata( htf.bold(c2rec.big_ord), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'PREORDER_STATS', errmsg=>sqlerrm, extdet=>null);
end preorder_stats;

procedure preorder_list(surl varchar2, phgid in integer )
as

 cursor c1(phgid integer) is
  select p.business_name,p.pid,po.poid,po.date_created,po.sendto_name
  from purchase_order po, photographer p
  where po.status in (LNG.ORD_TXT_120,LNG4.AHC_TXT_672,LNG4.AHC_TXT_706,'PreOrder - Confirmed without Payment') and
        p.pid = po.pid and
        p.pid = phgid and
        nvl(length(sendto_name)+length(po.contact_email),0) > 0
 order by po.date_created desc;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.PREORDER_LIST');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG4.AHC_TXT_092, helpid=>'A81', style=>'NOMENU' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( LNG3.ADM_TXT_261, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG.PHG_TXT_094, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG.GLB_TXT_078, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG.CST_TXT_112, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 for c1rec in c1(phgid) loop
 htp.tablerowopen;
  htp.tabledata( htf.bold(c1rec.business_name), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
  htp.tabledata( htf.anchor('adm.dispord?surl=' || surl || '&purchid=' || c1rec.poid, c1rec.poid), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( to_char(c1rec.date_created,LNG.TSMASK), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tabledata( c1rec.sendto_name, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'PREORDER_LIST', errmsg=>sqlerrm, extdet=>null);
end preorder_list;

procedure load_stats(surl varchar2, msg in varchar2 default null )
as

 cursor c1 is
  select /*+ ALL_ROWS */ business_name,account_name,ll.aid,count('x') tot, sum(decode(succeeded,'T',1,0)) sumtot
  from load_log ll, customer_account ca, photographer ph
  where ll.aid = ca.aid and
        ph.pid = ca.pid and
        trunc(time_start) = trunc(sysdate)
  group by business_name,account_name,ll.aid ;

 cursor c2 is
  select /*+ ALL_ROWS */ business_name,account_name,ll.aid,count('x') tot, sum(decode(succeeded,'T',1,0)) sumtot
  from load_log ll, customer_account ca, photographer ph
  where ll.aid = ca.aid and
        ph.pid = ca.pid
  group by business_name,account_name,ll.aid ;

 sessid		integer;
 sts		varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.LOAD_STATS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG4.AHC_TXT_289, helpid=>'A82' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 htp.bold( LNG4.AHC_TXT_290 );
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || GLBX.TABLE_BACKGROUND );
   htp.tablerowopen;
       htp.tabledata(htf.bold( LNG.CST_TXT_004),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG.CST_TXT_031 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG4.AHC_TXT_292 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG4.AHC_TXT_293 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   for c1rec in c1 loop
    htp.tablerowopen;
       htp.tabledata(htf.bold( c1rec.business_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( htf.anchor2('glbx.displog?surl=' || surl || '&acid=' || c1rec.aid,c1rec.account_name,ctarget=>new_window) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( c1rec.tot ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( c1rec.sumtot ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.line;
   htp.nl;
  htp.bold( LNG4.AHC_TXT_291 );
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || GLBX.TABLE_BACKGROUND );
   htp.tablerowopen;
       htp.tabledata(htf.bold( LNG.CST_TXT_004),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG.CST_TXT_031 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG4.AHC_TXT_292 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( LNG4.AHC_TXT_293 ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   for c2rec in c2 loop
    htp.tablerowopen;
       htp.tabledata(htf.bold( c2rec.business_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( htf.anchor2('glbx.displog?surl=' || surl || '&acid=' || c2rec.aid,c2rec.account_name,ctarget=>new_window) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( c2rec.tot ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( c2rec.sumtot ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   end loop;
   htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'LOAD_STATS', errmsg=>sqlerrm);
end load_stats;

procedure quick_create(surl in varchar2, msg in varchar2 default null)
as

 cursor c1 is select aid,ca.username auser,p.username puser from customer_account ca, photographer p where p.pid = ca.pid order by p.username,ca.username;
 cursor c2 is select theme_type from theme_types order by theme_type;
 cursor c2a is select theme_name from theme order by theme_name;
 cursor c3 is select id,plan_name from charge_plan;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.QUICK_CREATE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG4.AHC_TXT_345, helpid=>'A83' );
 htp.nl;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_quick_create' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl) );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG.GLB_TXT_076), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.formhidden( 'P1', 'USERNAME' );
  htp.tabledata( htf.formtext( 'P2', 30, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG.GLB_TXT_018), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.formhidden( 'P1', 'PASSWORD' );
  htp.tabledata( htf.formpassword( 'P2', 30, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG.CST_TXT_004), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.formhidden( 'P1', 'BUSINESS' );
  htp.tabledata( htf.formtext( 'P2', 30, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG.PHG_TXT_301), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.formhidden( 'P1', 'EMAIL' );
  htp.tabledata( htf.formtext( 'P2', 30, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG.PHG_TXT_236), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.formhidden( 'P1', 'WEB' );
  htp.tabledata( htf.formtext( 'P2', 30, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowclose;
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG.PHG_TXT_237), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.formhidden( 'P1', 'PHONE1' );
  htp.tabledata( htf.formtext( 'P2', 30, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG.PHG_TXT_336), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.formhidden( 'P1', 'PHONE2' );
  htp.tabledata( htf.formtext( 'P2', 30, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG.PHG_TXT_238), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.formhidden( 'P1', 'PHONE3' );
  htp.tabledata( htf.formtext( 'P2', 30, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG.PHG_TXT_239), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.formhidden( 'P1', 'CONTACT1' );
  htp.tabledata( htf.formtext( 'P2', 30, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG.PHG_TXT_240), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.formhidden( 'P1', 'CONTACT2' );
  htp.tabledata( htf.formtext( 'P2', 30, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG.PHG_TXT_241), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.formhidden( 'P1', 'CONTACT3' );
  htp.tabledata( htf.formtext( 'P2', 30, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG.PHG_TXT_242), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.formhidden( 'P1', 'CONTACT4' );
  htp.tabledata( htf.formtext( 'P2', 30, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tabledata( htf.bold(LNG2.PFM_TXT_164), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.formhidden( 'P1', 'DEFAULT_BFTR' );
  htp.p( '<TD '  || glbx.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" align="LEFT">' );
  htp.formselectopen( 'P2' );
  for c2rec in c2 loop
   htp.formselectoption( c2rec.theme_type );
  end loop;
  htp.formselectclose;
  htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.bold(LNG4.AHC_TXT_804), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.formhidden( 'P1', 'DEFAULT_LF' );
  htp.p( '<TD '  || glbx.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" align="LEFT">' );
  htp.formselectopen( 'P2' );
  for c2arec in c2a loop
   htp.formselectoption( c2arec.theme_name );
  end loop;
  htp.formselectclose;
  htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.bold(LNG.PHG_TXT_249), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.formhidden( 'P1', 'PLAN' );
  htp.p( '<TD '  || glbx.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" align="LEFT">' );
  htp.formselectopen( 'P2' );
  for c3rec in c3 loop
   htp.formselectoption( c3rec.plan_name, cattributes=>'VALUE="' || c3rec.id || '"'  );
  end loop;
  htp.formselectclose;
  htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.bold(LNG4.AHC_TXT_346), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.formhidden( 'P1', 'CUSTOMER' );
  htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" align="LEFT">' );
  htp.formselectopen( 'P2' );
  for c1rec in c1 loop
   htp.formselectoption( c1rec.puser || '-' || c1rec.auser, cattributes=>'VALUE="' || c1rec.aid || '"' );
  end loop;
  htp.formselectclose;
  htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG4.AHC_TXT_347), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.formhidden( 'P1', 'CUSTOMER_USERNAME' );
  htp.tabledata( htf.formtext( 'P2', 30, 100 ) || htf.nl || htf.italic(LNG4.AHC_TXT_422), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowclose;
 htp.tableclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG2.PBK_TXT_060 );
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'QUICK_CREATE', errmsg=>sqlerrm, extdet=>null);
end quick_create;

procedure accept_quick_create(surl in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 cursor c1(usr varchar2) is
  select 'x' ex
  from customer_account
  where username = usr
  union all
  select 'x' ex
  from photographer
  where username = usr
  union all
  select 'x' ex
  from manufacturer
  where username = usr;

 cursor c3(usr integer) is select * from customer_account where aid = usr;

 cursor c4(acid integer) is
  select um.rowid, um.umo_id, um.umo_scene_id
  from umo um
  where um.aid = acid and
        um.umo_type in ('PHOTO','AUDIO','VIDEO','DOCUMENT','RELATIONAL','BLUEPRINT')
  order by umo_id;

 cursor c5(tname varchar2) is select column_name from user_tab_columns where table_name = tname and data_type not in ('DATE') and column_name not in ('SPB','OID','NAME','PID','LOGIN_TYPE','CUSTOMER_CONTACT','AID');

 cursor c6(acid integer) is select oid from customer_price_book where aid = acid and ltype = 'OWNER';

 c1rec		c1%ROWTYPE;
 c2rec		photographer%ROWTYPE;
 c3rec		c3%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 npw		varchar2(100);
 newid		integer;
 cnewid		integer;
 unewid		integer;
 snewid		integer;
 oldpw		varchar2(100);
 usrname	varchar2(100);
 acid		integer;
 new_oid	integer;
 old_oid	integer;
 tbf		varchar2(100);
 tlf		varchar2(100);
 val1		varchar2(4000);

 function find_p1(ky varchar2) return varchar2
 is
 begin
  for j in p1.first..p1.last loop
   if p1(j) = ky then return( p2(j) ); end if;
  end loop;
  return( NULL );
 end find_p1;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.QUICK_CREATE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if find_p1( 'USERNAME' ) is null or
    find_p1( 'CUSTOMER_USERNAME' ) is null
  then
   quick_create( surl, LNG.GLB_TXT_027 );
   return;
 end if;

 open c1( upper(find_p1( 'USERNAME' )) );
 fetch c1 into c1rec;
 if c1%FOUND
  then
   close c1;
   quick_create( surl, LNG.GLB_TXT_027 );
   return;
 end if;
 close c1;

 open c1( upper(find_p1( 'CUSTOMER_USERNAME' )) );
 fetch c1 into c1rec;
 if c1%FOUND
  then
   close c1;
   quick_create( surl, LNG3.ADM_TXT_164 );
   return;
 end if;
 close c1;

 c2rec.username := upper(find_p1( 'USERNAME' ));
 c2rec.business_name := upper(find_p1( 'BUSINESS' ));
 c2rec.contact_email := upper(find_p1( 'EMAIL' ));
 c2rec.home_site := upper(find_p1( 'WEB' ));
 c2rec.work_phone := upper(find_p1( 'PHONE1' ));
 c2rec.contact_fax := upper(find_p1( 'PHONE2' ));
 c2rec.mobile_phone := upper(find_p1( 'PHONE3' ));
 c2rec.contact_street := upper(find_p1( 'CONTACT1' ));
 c2rec.contact_suburb := upper(find_p1( 'CONTACT2' ));
 c2rec.contact_city := upper(find_p1( 'CONTACT3' ));
 c2rec.contact_pcode := upper(find_p1( 'CONTACT4' ));
 c2rec.plan_id := upper(find_p1( 'PLAN' ));
 c2rec.skill_level := 'NOVICE';
 usrname := upper(find_p1( 'CUSTOMER_USERNAME' ));
 acid := upper(find_p1( 'CUSTOMER' ));
 tbf:= find_p1('DEFAULT_BFTR');
 tlf:= find_p1('DEFAULT_LF');

 open c3( acid );
 fetch c3 into c3rec;
 close c3;

 oldpw := upper(find_p1( 'PASSWORD' ) );
 npw := glbx.encrypt( oldpw, special_key=>DECS.GENERAL_ENCRYPT_KEY || DECS.RANDOM_NUMBER );
 select s_customer_profile.nextval into newid from dual;

 insert into photographer( id, date_created, pid, username, business_name, password, contact_email, home_site, work_phone, contact_fax, mobile_phone, contact_street,
                           contact_suburb, contact_city, contact_pcode, plan_id, theme_type, skill_level, top_frame_lf, abn_title, photographer_title )
  values (1, sysdate, newid, c2rec.username, c2rec.business_name, npw, c2rec.contact_email, c2rec.home_site, c2rec.work_phone, c2rec.contact_fax, c2rec.mobile_phone, c2rec.contact_street,
          c2rec.contact_suburb, c2rec.contact_city, c2rec.contact_pcode, c2rec.plan_id, tbf, c2rec.skill_level, nvl(tlf,DECS.DEFAULT_PHG_THEME), nvl(c2rec.abn_title,'ABN'), nvl(c2rec.photographer_title,'Photographer') );
 insert into audit_photographer_password(pid,date_changed,pw) values (newid,sysdate,oldpw);

 select s_customer_profile.nextval into cnewid from dual;

 begin
  insert into photographer_preference(pid,aid,prefid,value)
   select newid,cnewid,prefid,value from photographer_preference where aid = acid;
  insert into photographer_preference(pid,aid,prefid,value)
   select newid,0,prefid,value from photographer_preference where aid = acid;
 exception when no_data_found then null;
 end;

 select s_phg_price_book.nextval into snewid from dual;
 select s_order_style.nextval into new_oid from dual;

 open c6(acid);
 fetch c6 into old_oid;
 close c6;

 begin
 insert into order_style(oid,name,pid,spb)
  select distinct new_oid,name,newid,snewid
  from order_style
  where oid = old_oid;
 exception when others then null;
 end;

 begin
  for c5rec in c5('ORDER_STYLE') loop
   execute immediate 'select ' || c5rec.column_name || ' from order_style where oid = :1'
    into val1
     using old_oid;
   execute immediate 'update order_style set ' || c5rec.column_name || ' = :1 where oid = :2'
    using val1,new_oid;
  end loop;
 exception when others then null;
 end;

 begin
  insert into phg_price_book(spb,pid,name,call_location,package_help)
  select snewid,newid,name,call_location,package_help
  from phg_price_book
  where spb in (select spb from order_style where oid = old_oid);
 exception when others then null;
 end;

 begin
 insert into phg_price_book_lab(spb,manufacturer_id)
  select snewid,manufacturer_id
  from phg_price_book_lab
  where spb in (select spb from order_style where oid = old_oid);
 exception when others then null;
 end;

 begin
 insert into customer_price_book(pid,aid,oid,b2c_enabled,ltype)
  select newid,cnewid,new_oid,b2c_enabled,'OWNER'
  from customer_price_book where aid = acid and ltype = 'OWNER';
 exception when others then null;
 end;

 begin
 insert into customer_contact(contact_id,aid,login_type)
  select s_customer_contact.nextval,cnewid,'OWNER'
  from customer_contact
  where login_type = 'OWNER' and
        aid = acid;
 exception when others then null;
 end;

 begin
 for c5rec in c5('CUSTOMER_CONTACT') loop
  execute immediate 'select ' || c5rec.column_name || ' from customer_contact where aid = :1 and login_type = ''OWNER'''
   into val1
    using acid;
  execute immediate 'update customer_contact set ' || c5rec.column_name || ' = :1 where aid = :2'
   using val1,cnewid;
 end loop;
 exception when others then null;
 end;

 begin
insert into phg_price_item(
 ppi,
 spb,
 charge,
 name,
 phg_code,
 manufacturer_id,
 lab_id,
 min_qty,
 max_qty,
 umo_id,
 brand_id,
 date_created,
 date_updated,
 film_type,
 film_size,
 enabled,
 is_default,
 shop_item,
 shop_style,
 comments,
 delivery_time_local,
 delivery_time_int,
 surcharge_local,
 surcharge_int,
 production_time,
 stock_less_than_value,
 stock_less_purch,
 status_workflow,
 auto_increase_perc,
 item_discounted,
 item_disc_charge,
 item_disc_from,
 item_disc_to,
 delivery_desc,
 product_desc,
 stock_less_than_desc,
 product_class,
 lease_download_object,
 limit_download_object,
 exclusive_local,
 exclusive_int)
select
  s_phg_price_item.nextval,
  snewid,
  charge,
  name,
  phg_code,
  manufacturer_id,
  lab_id,
  min_qty,
  max_qty,
  umo_id,
  brand_id,
  date_created,
  sysdate,
  film_type,
  film_size,
  enabled,
  is_default,
  shop_item,
  shop_style,
  comments,
  delivery_time_local,
  delivery_time_int,
  surcharge_local,
  surcharge_int,
  production_time,
  stock_less_than_value,
  stock_less_purch,
  status_workflow,
  auto_increase_perc,
  item_discounted,
  item_disc_charge,
  item_disc_from,
  item_disc_to,
  delivery_desc,
  product_desc,
  stock_less_than_desc,
  product_class,
  lease_download_object,
  limit_download_object,
  exclusive_local,
  exclusive_int
 from phg_price_item
  where spb in (select os.spb from customer_price_book cpb, order_style os where aid = acid and ltype = 'OWNER' and cpb.oid = os.oid);
 exception when others then null;
 end;

  insert into customer_account
   (
   pid,aid,photographer_account_id,customer_disabled,background_img,plan_id,
   is_beta_tester,account_name,date_held,username,password,password_owner,scene_name,theme_name,
   failed_logins,date_created,date_expires,customer_message,redirect_site_id,
   theme_type,profile_id,date_to_delete,public_account,plan_event,
   home_page_options,home_page_category,zoom_factor,enable_novelties,cusobj,novelty_features,enable_greetingcards,reporting_category,
   receive_images_via_email,receive_image_account,receive_image_umo_scene,receive_image_options
   )
   values
   (
   newid,cnewid,c3rec.photographer_account_id,c3rec.customer_disabled,null,c2rec.plan_id,
   c3rec.is_beta_tester,c3rec.account_name,c3rec.date_held,usrname,c3rec.password,c3rec.password_owner,c3rec.scene_name,c3rec.theme_name,
   0,sysdate,c3rec.date_expires,c3rec.customer_message,c3rec.redirect_site_id,
   c3rec.theme_type,c3rec.profile_id,c3rec.date_to_delete,c3rec.public_account,c3rec.plan_event,
   c3rec.home_page_options,c3rec.home_page_category,c3rec.zoom_factor,c3rec.enable_novelties,c3rec.cusobj,c3rec.novelty_features,c3rec.enable_greetingcards,c3rec.reporting_category,
   c3rec.receive_images_via_email,c3rec.receive_image_account,c3rec.receive_image_umo_scene,c3rec.receive_image_options
   );

    for c4rec in c4( acid ) loop

          select s_umo.nextval into unewid from dual;

          begin
           insert into umo
            (umo_id,parent_id,aid,umo_type,umo_owner,umo_scene_id,version,extras,extra_film_colour,extra_roll_id,extra_film_size,
             photo_original,photo_master,photo_thumbnail,photo_backup,audio_original,audio_thumbnail,video_original,
             ftp_location,ftp_virtual_dir,photo_original_loc,audio_original_loc,video_original_loc,
             doc_mimetype,doc_type,doc_pov,doc_length,doc_body,doc_html,doc_gist,document_original_loc,
             is_global,date_created,expire_date,report_id,
             attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,sort_priority,exclusive_purchased,
             signature,program_obj,blueprint_obj,image_caption)
            select
             unewid,um.parent_id,cnewid,um.umo_type,um.umo_owner,um.umo_scene_id,um.version,um.extras,um.extra_film_colour,um.extra_roll_id,um.extra_film_size,
             um.photo_original,um.photo_master,um.photo_thumbnail,um.photo_backup,um.audio_original,um.audio_thumbnail,um.video_original,
             um.ftp_location,um.ftp_virtual_dir,um.photo_original_loc,um.audio_original_loc,um.video_original_loc,
             um.doc_mimetype,um.doc_type,um.doc_pov,um.doc_length,um.doc_body,um.doc_html,um.doc_gist,um.document_original_loc,
             um.is_global,um.date_created,um.expire_date,um.report_id,
             attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,sort_priority,exclusive_purchased,
             signature,um.program_obj,um.blueprint_obj,image_caption
            from umo um
             where rowid = c4rec.rowid;
            exception when others then null;
            end;

            begin
            insert into umo_index(umo_id,aid,attribute_id,position_id,word_original,word_upper,word_soundex,ordering)
             select newid,acid,attribute_id,position_id,word_original,word_upper,word_soundex,ordering
             from umo_index
             where aid = acid and
                   umo_id = c4rec.umo_id;
            insert into umo_attribute(umo_id,attribute_id,position_id,date_made,value)
             select newid,attribute_id,position_id,date_made,value
             from umo_attribute
             where umo_id = c4rec.umo_id;
            exception when others then null;
            end;

           commit;
    end loop;

    adm.acct_list_photo(surl, st=>substr(c2rec.username,1,1) || substr(c2rec.username,1,1));

exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_QUICK_CREATE', errmsg=>sqlerrm, extdet=>null);
end accept_quick_create;

procedure gcert_stats( surl varchar2 )
as

 cursor c1 is select count('x') tot from gift_certificate;
 cursor c2 is select avg(tot) tot from (select count('x') tot from gift_certificate group by pid);
 cursor c3 is select count('x') tot from gift_certificate gc where exists( select 'x' from gift_certificate_usage gcu where gcu.certificate_id = gc.certificate_id);
 cursor c4 is select count('x') tot from gift_certificate gc where not exists( select 'x' from gift_certificate_usage gcu where gcu.certificate_id = gc.certificate_id);
 cursor c5 is select count('x') tot from gift_certificate gc where exists( select 'x' from gift_certificate_usage gcu where gcu.certificate_id = gc.certificate_id) and value > (select sum(amount_used) from gift_certificate_usage gcu where gcu.certificate_id = gc.certificate_id);
 cursor c6 is select count('x') tot from gift_certificate gc where sysdate < expiry_date and exists( select 'x' from gift_certificate_usage gcu where gcu.certificate_id = gc.certificate_id) and value > (select sum(amount_used) from gift_certificate_usage gcu where gcu.certificate_id = gc.certificate_id) or not exists( select 'x' from gift_certificate_usage gcu where gcu.certificate_id = gc.certificate_id);

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 sid		integer;
 foundrec	boolean;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.GCERT_STATS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG4.AHC_TXT_533, style=>'MENU', helpid=>'A85' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.nl;
 open c1;
 fetch c1 into c1rec;
 close c1;
 open c2;
 fetch c2 into c2rec;
 close c2;
 open c3;
 fetch c3 into c3rec;
 close c3;
 open c4;
 fetch c4 into c4rec;
 close c4;
 open c5;
 fetch c5 into c5rec;
 close c5;
 open c6;
 fetch c6 into c6rec;
 close c6;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG4.AHC_TXT_680), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.bold(c1rec.tot), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG4.AHC_TXT_681), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.bold(c2rec.tot), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG4.AHC_TXT_682), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.bold(c3rec.tot), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG4.AHC_TXT_683), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.bold(c4rec.tot), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG4.AHC_TXT_684), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.bold(c5rec.tot), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG4.AHC_TXT_685), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.bold(c6rec.tot), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.anchor( 'adm.adm_acct_orders?surl=' || surl ,LNG2.PFM_TXT_027 );
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'GCERT_STATS', errmsg=>sqlerrm );
end gcert_stats;

procedure gcertificates(surl varchar2, phgid in integer )
as

 cursor c1(phgid integer) is select * from gift_certificate where pid = phgid order by date_created desc;
 cursor c2(acid integer) is select username from customer_account where aid = acid;
 cursor c3(certid integer) is select * from gift_certificate_usage where certificate_id = certid order by date_used desc;
 cursor c4(phgid integer ) is select sum(value) sm from gift_certificate where pid = phgid;
 cursor c5(phgid integer ) is select sum(amount_used) sm from gift_certificate_usage where certificate_id in (select certificate_id from gift_certificate where pid = phgid);

 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 sid		integer;
 foundrec	boolean;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.GCERTIFICATES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG4.AHC_TXT_533, style=>'NOMENU', helpid=>'A85' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( LNG4.AHC_TXT_534, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG4.AHC_TXT_527, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG.GLB_TXT_078, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG4.AHC_TXT_531, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG4.AHC_TXT_535, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG4.AHC_TXT_529, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG4.AHC_TXT_530, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;

 for c1rec in c1( phgid ) loop
  htp.tablerowopen;
     htp.tabledata( c1rec.certificate_id, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( glbx.encrypt_data(c1rec.certificate_id), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( to_char(c1rec.date_created,LNG.TSMASK), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( to_char(c1rec.expiry_date,LNG.MASK), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     if c1rec.valid_only_customer = 'T'
      then
       open c2(c1rec.aid);
       fetch c2 into c2rec;
       close c2;
       htp.tabledata( LNG.PHG_TXT_046 || htf.nl || c2rec.username, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      else
       htp.tabledata( LNG.PHG_TXT_045, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     end if;
     htp.tabledata( to_char(c1rec.value,LNG.MONEY_FORMAT), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT">' );
     foundrec := FALSE;
     if sysdate < c1rec.expiry_date then htp.bold( LNG4.AHC_TXT_532 ); htp.nl; end if;
     for c3rec in c3( c1rec.certificate_id ) loop
      foundrec := TRUE;
      if c1rec.valid_only_customer = 'F'
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
     htp.bold( LNG4.AHC_TXT_530 || ':' || to_char(glbx.certificate_remaining( c1rec.certificate_id ), LNG.MONEY_FORMAT ));
     if not foundrec then htp.nl; htp.bold( LNG4.AHC_TXT_536 ); end if;
     htp.p( '</TD>' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 open c4(phgid);
 fetch c4 into c4rec;
 close c4;
 open c5(phgid);
 fetch c5 into c5rec;
 close c5;
 htp.p(htf.bold( LNG4.AHC_TXT_546 ) || ':' || to_char(nvl(c4rec.sm,0),LNG.MONEY_FORMAT));
 htp.nl;
 htp.p(htf.bold( LNG4.AHC_TXT_547 ) || ':' || to_char(nvl(c5rec.sm,0),LNG.MONEY_FORMAT));
 htp.nl;
 htp.p(htf.bold( LNG4.AHC_TXT_548 ) || ':' || to_char(nvl(c4rec.sm,0) - nvl(c4rec.sm,0),LNG.MONEY_FORMAT));
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'GCERTIFICATES', vpid=>phgid, errmsg=>sqlerrm, extdet=>null);
end gcertificates;

procedure illegal_access(surl varchar2, sorton in varchar2 default '1', cull in varchar2 default null )
as

 cursor c1(sorton varchar2) is select * from invalid_access_attempt order by decode(sorton,'1',upper(username),'2',upper(password),'3',ip_address,'4',job,'5',to_char(date_access,'YYYYMMDDHH24MISS'),username) asc;
 cursor c2(sorton varchar2) is select * from invalid_access_attempt order by decode(sorton,'1D',upper(username),'2D',upper(password),'3D',ip_address,'4D',job,'5D',to_char(date_access,'YYYYMMDDHH24MISS'),username) desc;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;
 foundrec	boolean;
 vcull		integer;
 srt		varchar2(100);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MANAGE_HELP');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 begin vcull := to_number(cull); exception when others then vcull := NULL; end;
 if vcull is not null then delete from invalid_access_attempt where date_access < (sysdate-vcull); end if;
 commit;

 main_title( surl, sessid, LNG5.EXT_TXT_086, style=>'MENU', helpid=>'A88' );
 htp.p( '<CENTER>' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  srt := 'adm.illegal_access?surl=' || surl || '&sorton=';
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.GLB_TXT_076) || htf.anchor(srt || '1','[Asc]') || htf.anchor(srt || '1D','[Desc]'), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold(LNG.GLB_TXT_018) || htf.anchor(srt || '2','[Asc]') || htf.anchor(srt || '2D','[Desc]'), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold(LNG5.EXT_TXT_084) || htf.anchor(srt || '4','[Asc]') || htf.anchor(srt || '4D','[Desc]'), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold(LNG5.EXT_TXT_085) || htf.anchor(srt || '3','[Asc]') || htf.anchor(srt || '3D','[Desc]'), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold(LNG.ORD_TXT_188) || htf.anchor(srt || '5','[Asc]') || htf.anchor(srt || '5D','[Desc]'), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  if sorton in ('1','2','3','4','5')
   then
    for c1rec in c1(sorton) loop
     htp.tablerowopen;
      htp.tabledata( c1rec.username, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( c1rec.password, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( c1rec.job, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( c1rec.ip_address, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( to_char(c1rec.date_access,LNG.TSMASK), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    end loop;
   else
    for c1rec in c2(sorton) loop
     htp.tablerowopen;
      htp.tabledata( c1rec.username, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( c1rec.password, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( c1rec.job, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( c1rec.ip_address, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( to_char(c1rec.date_access,LNG.TSMASK), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    end loop;
  end if;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.formopen( 'adm.illegal_access' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'SORTON', sorton );
 htp.bold( LNG3.ADM_TXT_062 );
 htp.formtext( 'CULL', 10, 10 );
 htp.formsubmit( null, 'Cull' );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ILLEGAL_ACCESS', errmsg=>sqlerrm, extdet=>null);
end illegal_access;

procedure manage_help(surl varchar2 )
as

 cursor c1 is select * from help_contents where topic_id not in (select topic_id from help_topics);

 sessid		integer;
 sts		varchar2(200);
 sid		integer;
 foundrec	boolean;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MANAGE_HELP');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG5.EXT_TXT_083, style=>'MENU', helpid=>'A86' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );

  htp.tablerowopen;
     htp.tabledata( htf.anchor( 'adm.control_help?surl=' || surl || '&fn=1', LNG4.AHC_TXT_859), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.anchor( 'adm.control_help?surl=' || surl || '&fn=2', LNG4.AHC_TXT_860), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.anchor( 'adm.control_help?surl=' || surl || '&fn=3', LNG4.AHC_TXT_861), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.anchor( 'adm.control_help?surl=' || surl || '&fn=4', LNG4.AHC_TXT_862), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;

 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MANAGE_HELP', errmsg=>sqlerrm, extdet=>null);
end manage_help;

procedure control_help(surl varchar2, fn in integer )
as

 cursor c1 is select  /*+ ALL_ROWS */ * from help_contents where topic_id not in (select topic_id from help_topics);
 cursor c1a is select text,name from user_source where name in ('LNG','LNG2','LNG3','LNG4','LNG5') order by line;
 cursor c2a(txt varchar2) is select  /*+ FIRST_ROWS */ 'x' from report_results where report_text like '%.' || txt || '%';
 cursor c1b is select  /*+ ALL_ROWS */ result_text_a text, result_text_b name from compare_results;
 cursor c2b(txt varchar2) is
  select  /*+ ALL_ROWS */ result_text_a text, result_text_b name
  from compare_results
  where result_text_a like '%' || txt and
        substr(result_text_a,1,2) <> '--';

 sessid		integer;
 sts		varchar2(200);
 sid		integer;
 foundrec	boolean;
 bl		boolean;
 tmp 		char(1);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.CONTROL_HELP');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if fn = 1
  then
   main_title( surl, sessid, LNG4.AHC_TXT_859, style=>'MENU', helpid=>'A86' );
 elsif fn = 2
  then
   main_title( surl, sessid, LNG4.AHC_TXT_704, style=>'MENU', helpid=>'A86' );
 elsif fn = 3
  then
   main_title( surl, sessid, LNG4.AHC_TXT_863, style=>'MENU', helpid=>'A86' );
 elsif fn = 4
  then
   main_title( surl, sessid, LNG4.AHC_TXT_864, style=>'MENU', helpid=>'A86' );
 end if;
 htp.nl;
 htp.p( '<CENTER>' );

 if fn = 1
  then
   bl := generate_help_index;
   htp.bold( LNG4.AHC_TXT_865 );
   htp.nl;
   htp.nl;
   htp.bold( LNG4.AHC_TXT_866 );

 elsif fn = 2
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   for c1rec in c1 loop
    htp.tablerowopen;
        htp.tabledata( c1rec.topic_id, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
        htp.tabledata( c1rec.group_name, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
        htp.tabledata( c1rec.content_name, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
   end loop;
   htp.tableclose;

 elsif fn = 3
  then
  insert into report_results(report_id,report_text)
   select 0,text from user_source where type = 'PACKAGE BODY';
  for c1arec in c1a loop
   if not(c1arec.text is null or substr(c1arec.text,1,2) = '--' or substr(c1arec.text,4,1) <> '_')
    then
     open c2a(substr(c1arec.text,1,11));
     fetch c2a into tmp;
     if c2a%NOTFOUND
      then
       htp.p ('[' || c1arec.name || ']' || substr(c1arec.text,1,11));
       htp.nl;
     end if;
     close c2a;
   end if;
  end loop;
  htp.nl;
  htp.bold( LNG4.AHC_TXT_866 );
  htp.nl;

 elsif fn = 4
  then
   insert into compare_results(result_text_a,result_text_b)
   select text,name from user_source where name in ('LNG','LNG2','LNG3','LNG4','LNG5');
   for c1brec in c1b loop
    if not(c1brec.text is null or substr(c1brec.text,1,2) = '--' or substr(c1brec.text,4,1) <> '_')
     then
      if substr(substr(c1brec.text,instr(c1brec.text,'''')),1,3) <> ''''';'
       then
        for c2brec in c2b(substr(c1brec.text,instr(c1brec.text,''''))) loop
         if (substr(c2brec.text,1,11) <> substr(c1brec.text,1,11))
          then
           htp.p('[' || c1brec.name || ',' || c2brec.name || ']' || substr(c1brec.text,1,11) || '-' || substr(c2brec.text,1,11) || '-' || substr(c1brec.text,instr(c1brec.text,'''')));
           htp.nl;
         end if;
       end loop;
     end if;
   end if;

  end loop;
  htp.nl;
  htp.bold( LNG4.AHC_TXT_866 );
  htp.nl;

 end if;

 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'CONTROL_HELP', errmsg=>sqlerrm, extdet=>null);
end control_help;

function generate_help_index
 return boolean
as
--
-- Help Index Stop Words
-- When the index for help is generated, these words are ingored
--
-- Stop Words Start Here. They should be in upper case.
-- Note: The stop words should not contain special characters (only if in the European alphabet)
-- All stop words should be contained within two single quotes. Follow the syntax as below.
--

STOP_WORDS	constant GLBX.frame_sizes  :=
 GLBX.frame_sizes(
'A',
'ADD',
'ALL',
'AN',
'ARE',
'AND',
'ARE',
'ALSO',
'ANY',
'AS',
'AT',
'B',
'BE',
'BEEN',
'BR',
'BOTTOM',
'BOTH',
'BY',
'CAN',
'DID',
'DISP',
'IF',
'EACH',
'EG',
'EN',
'ETC',
'EXIT',
'FOR',
'HAS',
'HAVE',
'I',
'ID',
'IE',
'IN',
'INTO',
'IS',
'IT',
'MANY',
'MORE',
'NBSP',
'NOT',
'OF',
'OR',
'ON',
'ONCE',
'OUR',
'OVER',
'PHA',
'PHG',
'PHZ',
'PRES',
'GT',
'LT',
'THAT',
'THE',
'THEN',
'THESE',
'THEIR',
'THOSE',
'THIS',
'TO',
'TOO',
'TOOLBAR',
'UNTIL',
'SCREEN',
'RETURN',
'PUBLIC',
'PHOTOGRAPHERS',
'PAGE',
'NAME',
'HIGHLIGHT',
'FIELD',
'FIELDS',
'ENTER',
'ENTERED',
'DISPLAYED',
'DETAILS',
'CONFIRM',
'CLICK',
'BUTTON',
'BUTTONS',
'ADDITIONS/CHANGES',
'ACCOUNT',
'VIA',
'WELL',
'WHICH',
'WILL',
'WITH',
'WITHIN',
'YOU',
'YOUR',
'WINNT',
'WIDTH100>',
'YOURNAVIGATION',
'USED',
'USE',
'USING',
'TYPE',
'TYPES',
'TOP',
'THEY',
'THERE',
'THEM',
'SUPPORTED',
'STEP',
'SESSIONS',
'SO',
'SET',
'SEE',
'PER',
'NAMEGENERATOR',
'NAMEAUTHOR',
'NAVIGATION',
'NAVIGATIONTOOLBAR',
'NEED',
'NEW',
'MOST',
'INSTALLED',
'FRM',
'WHAT',
'WHERE',
'ALREADY',
'WHEN'
);

tokens		GLBX.MYARRAY;
is_stop_word	BOOLEAN;

 cursor c1 is select * from help_topics;
 cursor c2(tid varchar2) is select sec_mask from help_contents where topic_id = tid;
 cursor c3 is select rowid,topic_id,index_word from help_index order by index_word,topic_id;
 cursor c4 is select * from help_contents;
 val	varchar2(200);

 c2rec 		c2%ROWTYPE;
 c3rec 		c3%ROWTYPE;
 retstmt	varchar2(100);
 loadhtml	varchar2(32767);
 lh1		varchar2(4000);
 lh2		varchar2(4000);
 lh3		varchar2(4000);
 lh4		varchar2(4000);
 lh5		varchar2(4000);
 lh6		varchar2(4000);
 lh7		varchar2(4000);
 lh8		varchar2(4000);
 p_body		varchar2(1000);
 f 		utl_file.file_type;
 foundtoken	boolean;

	 function extract_tokens( tval in varchar2, ctr in integer )
	  return varchar2
	 as
	  x	integer;
	 begin
	  if tval is null then return( null ); end if;
	  x := instr(tval,' ',1,1);
	  if x = 0
	   then
	    tokens(ctr) := ltrim(rtrim(tval));
	    return( null );
	   else
	    tokens(ctr) := ltrim(rtrim(substr(tval,1,x)));
	  end if;
	  return( extract_tokens( substr(tval,x+1),ctr+1 ));
	 exception when others then htp.p(sqlerrm); return( null );
	 end extract_tokens;


begin
 -- Load Help Data
 delete from help_topics;
 for c4rec in c4 loop
  loadhtml := NULL;
  begin
   f := utl_file.fopen( glbx.extract_master_parameter('HELP_DIR'), upper(c4rec.topic_id) || '.html', 'r');
   loop
    begin
     utl_file.get_line(f,p_body);
     loadhtml := loadhtml || ' ' || p_body;
    exception
     when others then exit;
    end;
   end loop;
   utl_file.fclose( f );
   lh1 := substr(loadhtml,1,4000);
   lh2 := substr(loadhtml,4001,4000);
   lh3 := substr(loadhtml,8001,4000);
   lh4 := substr(loadhtml,12001,4000);
   lh5 := substr(loadhtml,16001,4000);
   lh6 := substr(loadhtml,20001,4000);
   lh7 := substr(loadhtml,24001,4000);
   lh8 := substr(loadhtml,28001,4000);
   insert into help_topics(topic_id,proc_xref,topic_title,content,content2,content3,content4,content5,content6,content7,content8)
   values(c4rec.topic_id,null,c4rec.content_name,lh1,lh2,lh3,lh4,lh5,lh6,lh7,lh8);
  exception
   when others then null; -- dbms_output.put_line(sqlerrm);
  end;
 end loop;

 -- Create Help Index
 delete from help_index;
 for c1rec in c1 loop
  open c2(c1rec.topic_id);
  fetch c2 into c2rec;
  close c2;
  tokens.delete;
  retstmt := extract_tokens( replace(replace(translate(c1rec.topic_title,chr(13) || chr(12) || chr(11) || chr(10),'    '),'<',' <'),'&',' &')   , 1 );
  if tokens.exists( 1 )
   then
    foundtoken := FALSE;
    for j in tokens.first..tokens.last loop
     val := upper(replace(translate(tokens(j),'~!@#$%^&*()+=-{}[]:;"'',.?|\','                             '),' ',''));
     if not foundtoken
      then
       if upper(val) in ('<B>','<I>','<U>','<H1>','<H2>','<H3>','<H4>','<H5>')
        then
         foundtoken := TRUE;
       end if;
      else
        if upper(val) in ('</B>','</I>','</U>','</H1>','</H2>','</H3>','</H4>','</H5>')
         then
          foundtoken := FALSE;
         else
          if substr(val,1,1) not in ('<','&')
           then
            is_stop_word := FALSE;
            for k in STOP_WORDS.FIRST..STOP_WORDS.LAST loop
          	 if val = stop_words(k) then is_stop_word := TRUE; end if;
            end loop;
            -- Hard Coded HTML values
            if (substr(val,1,10) = 'HTTP-EQUIV') or
               (substr(val,1,7) = 'CONTENT') or
               (substr(val,1,4) = 'HTML') or
               (substr(val,1,5) = 'NAME=') or
               (substr(val,1,12 ) = 'TRANSITIONAL') or
               (substr(val,1,7 ) = 'CHARSET') or
               (substr(val,1,9 ) = 'NETSCAPE>') or
               (substr(val,1,20 ) = 'HTTPEQUIVCONTENTTYPE')
             then
              is_stop_word := TRUE;
            end if;
            if not is_stop_word
             then
             insert into help_index(first_letter,topic_id,sec_mask,index_word) values (substr(val,1,1),c1rec.topic_id,c2rec.sec_mask,val);
            end if;
          end if;
        end if;
     end if;
    end loop;
   end if;
  tokens.delete;

  loadhtml := c1rec.content || c1rec.content2 || c1rec.content3 || c1rec.content4 || c1rec.content5 || c1rec.content6 || c1rec.content7 || c1rec.content8;
  retstmt := extract_tokens( replace(replace(translate(loadhtml,chr(13) || chr(12) || chr(11) || chr(10),'    '),'<',' <'),'&',' &')   , 1 );
  if tokens.exists( 1 )
   then
    foundtoken := FALSE;
    for j in tokens.first..tokens.last loop
     val := upper(replace(translate(tokens(j),'~!@#$%^&*()+=-{}[]:;"'',.?|\','                             '),' ',''));
     if not foundtoken
      then
        if upper(val) in ('<B>','<I>','<U>','<H1>','<H2>','<H3>','<H4>','<H5>')
         then
          foundtoken := TRUE;
         end if;
      else
       if upper(val) in ('</B>','</I>','</U>','</H1>','</H2>','</H3>','</H4>','</H5>')
        then
         foundtoken := FALSE;
        else
         if substr(tokens(j),1,1) not in ('<','&')
          then
           is_stop_word := FALSE;
           for k in STOP_WORDS.FIRST..STOP_WORDS.LAST loop
          	 if val = stop_words(k) then is_stop_word := TRUE; end if;
           end loop;
           -- Hard Coded HTML values
           if (substr(val,1,10) = 'HTTP-EQUIV') or
              (substr(val,1,7) = 'CONTENT') or
              (substr(val,1,4) = 'HTML') or
              (substr(val,1,5) = 'NAME=') or
              (substr(val,1,12 ) = 'TRANSITIONAL') or
              (substr(val,1,7 ) = 'CHARSET') or
              (substr(val,1,9 ) = 'NETSCAPE>') or
              (substr(val,1,20 ) = 'HTTPEQUIVCONTENTTYPE')
             then
              is_stop_word := TRUE;
           end if;
           if not is_stop_word
            then
             insert into help_index(first_letter,topic_id,sec_mask,index_word) values (substr(val,1,1),c1rec.topic_id,c2rec.sec_mask,val);
           end if;
         end if;
       end if;
     end if;
    end loop;
   end if;

 end loop;
 -- Remove Duplicate Entries
 c3rec.topic_id := 'X';
 c3rec.index_word := 'X';
 for crec in c3 loop
  if (crec.topic_id = c3rec.topic_id) and (crec.index_word = c3rec.index_word)
   then
    delete from help_index where rowid = crec.rowid;
  end if;
  c3rec.topic_id := crec.topic_id;
  c3rec.index_word := crec.index_word;
 end loop;

 commit;
 return( TRUE );
exception
 when others then htp.bold( sqlerrm ); return( FALSE );
end generate_help_index;

procedure comm(surl varchar2, msg in varchar2 default null )
as

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.COMM');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG5.EXT_TXT_099, style=>'MENU', helpid=>'A89' );
 htp.nl;
 if msg is not null then htp.header(2,msg,'CENTER' ); end if;
 htp.p( '<CENTER>' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );

  htp.tablerowopen;
     htp.tabledata( htf.anchor( 'adm.comm_table?surl=' || surl || '&tn=', LNG5.EXT_TXT_100), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.anchor( 'adm.comm_utl?surl=' || surl || '&fn=5', LNG5.EXT_TXT_108), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.anchor( 'adm.comm_utl?surl=' || surl || '&fn=1', LNG5.EXT_TXT_101), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.anchor( 'adm.comm_utl?surl=' || surl || '&fn=2', LNG5.EXT_TXT_102), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.anchor( 'adm.comm_utl?surl=' || surl || '&fn=3', LNG5.EXT_TXT_103), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.anchor( 'adm.comm_utl?surl=' || surl || '&fn=4', LNG5.EXT_TXT_104), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.anchor( 'adm.mng_ftrs?surl=' || surl, 'Feature List'), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;

 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'COMM', errmsg=>sqlerrm, extdet=>null);
end comm;

procedure comm_table(surl varchar2, tn in varchar2 default null, msg in varchar2 default null )
as

 cursor c1 is select table_name from user_tables order by table_name;
 cursor c2(tn varchar2) is select column_name from user_tab_columns where table_name = tn order by column_name;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.COMM_TABLE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG5.EXT_TXT_099, style=>'MENU', helpid=>'A89' );
 htp.nl;
 if msg is not null then htp.header(2, msg, 'CENTER' ); end if;
 htp.p( '<CENTER>' );
 if tn is null
  then
   htp.nl;
   htp.anchor( 'adm.comm?surl=' || surl, LNG4.AHC_TXT_564 );
   htp.nl;
  else
   htp.nl;
   htp.anchor( 'adm.comm_table?surl=' || surl || '&tn=', LNG4.AHC_TXT_564 );
   htp.nl;
 end if;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 if tn is null
  then
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG3.ADM_TXT_296) );
   htp.tablerowclose;
   for c1rec in c1 loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'adm.comm_table?surl=' || surl || '&tn=' || replace(c1rec.table_name,' ','+'), c1rec.table_name ));
   htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.anchor( 'adm.comm?surl=' || surl, LNG4.AHC_TXT_564 );

 else
   htp.bold( htf.anchor( 'adm.comm_table_edit?surl=' || surl || '&tn=' || replace(tn,' ','+') || '&cn=' , tn ) );
   htp.nl;
   htp.tablerowopen;
    htp.tabledata( LNG3.ADM_TXT_317 );
   htp.tablerowclose;
   for c2rec in c2(tn) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'adm.comm_table_edit?surl=' || surl || '&tn=' || replace(tn,' ','+') || '&cn=' || replace(c2rec.column_name,' ','+') , c2rec.column_name ));
   htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.anchor( 'adm.comm_table?surl=' || surl || '&tn=', LNG4.AHC_TXT_564 );
 end if;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'COMM_TABLE', errmsg=>sqlerrm, extdet=>'TN=' || tn );
end comm_table;

procedure comm_table_edit(surl varchar2, tn in varchar2, cn in varchar2, msg in varchar2 default null)
as

 cursor c1(tn varchar2) is select comments from user_tab_comments where table_name = tn;
 cursor c2(tn varchar2, cn varchar2) is select comments from user_col_comments where table_name = tn and column_name = cn;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;
 comm		varchar2(4000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.COMM_TABLE_EDIT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG5.EXT_TXT_099, style=>'MENU', helpid=>'A89' );
 htp.nl;
 if msg is not null then htp.header(2,msg,'CENTER' ); end if;
 htp.p( '<CENTER>' );
 htp.nl;
 if cn is null
  then
   open c1(tn);
   fetch c1 into comm;
   close c1;
  else
   open c2(tn,cn);
   fetch c2 into comm;
   close c2;
 end if;
 htp.formopen( 'adm.accept_comm_table' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'TN', tn );
 htp.formhidden( 'CN', cn );
 htp.bold( tn );
 htp.nl;
 htp.bold( cn );
 htp.nl;
 htp.nl;
  htp.formtextareaopen( 'P1', 15, 100 );
  htp.p( comm );
  htp.formtextareaclose;
 htp.nl;
 htp.nl;
 htp.formsubmit( 'ACTION', LNG.CST_BUT_017 );
 htp.formsubmit( 'ACTION', LNG.CST_BUT_018 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'COMM_TABLE_EDIT', errmsg=>sqlerrm, extdet=>'TN=' || tn || ' CN=' || cn);
end comm_table_edit;

procedure accept_comm_table(surl varchar2, tn in varchar2, cn in varchar2, p1 in varchar2, action in varchar2)
as

 sessid		integer;
 sts		varchar2(200);
 sid		integer;
 comm		varchar2(5000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_COMM_TABLE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 comm := replace(p1,'''','''''');
 for j in 1..23 loop
  comm := replace(comm,chr(j),'');
 end loop;
 comm := substr(comm,1,4000);
 if cn is null
  then
   execute immediate 'comment on table ' || tn || ' is ''' || comm || '''';
  else
   execute immediate 'comment on column ' || tn || '.' || cn || ' is ''' || comm || '''';
 end if;
 if action = LNG.CST_BUT_017
  then
   comm_table_edit(surl,tn,cn, LNG.PHG_TXT_245 );
  else
   comm_table(surl,tn);
 end if;
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_COMM_TABLE', errmsg=>sqlerrm, extdet=>'TN=' || tn || ' CN=' || cn);
end accept_comm_table;

procedure comm_utl(surl varchar2, fn in varchar2, msg in varchar2 default null)
as

 cursor c2 is select table_name from user_tables order by table_name;
 cursor c3 is select table_name,column_name from user_tab_columns order by table_name,column_name;
 cursor c4 is select table_name from user_tab_comments where comments is null order by table_name;
 cursor c5 is select table_name,column_name from user_col_comments where comments is null order by table_name,column_name;
 cursor c6 is select table_name,comments from user_tab_comments where comments is not null order by table_name;
 cursor c7 is select table_name,column_name,comments from user_col_comments where comments is not null order by table_name,column_name;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;
 comm		varchar2(4000);
 fl		UTL_FILE.FILE_TYPE;
 bfr		varchar2(32767);
 failed		integer;
 success	integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.COMM_UTL');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if fn = 1
  then
   -- Tables and Columns without Comments
   main_title( surl, sessid, LNG5.EXT_TXT_101, style=>'MENU', helpid=>'A89' );
   htp.p( '<CENTER>' );
   htp.nl;
   htp.nl;
   htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
    htp.tablerowopen;
    htp.tabledata( LNG3.ADM_TXT_296 );
   htp.tablerowclose;
   for c4rec in c4 loop
   htp.tablerowopen;
    htp.tabledata( c4rec.table_name);
   htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
    htp.tablerowopen;
    htp.tabledata( LNG3.ADM_TXT_296 );
    htp.tabledata( LNG3.ADM_TXT_317 );
   htp.tablerowclose;
   for c5rec in c5 loop
   htp.tablerowopen;
    htp.tabledata( c5rec.table_name);
    htp.tabledata( c5rec.column_name);
   htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.p( '</CENTER>' );

 elsif fn = 5
  then
   -- Tables and Columns without Comments
   main_title( surl, sessid, LNG5.EXT_TXT_108, style=>'MENU', helpid=>'A89' );
   htp.p( '<CENTER>' );
   htp.nl;
   htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
    htp.tablerowopen;
    htp.tabledata( LNG3.ADM_TXT_296 );
    htp.tabledata( LNG.CST_TXT_144 );
   htp.tablerowclose;
   for c6rec in c6 loop
   htp.tablerowopen;
    htp.tabledata( c6rec.table_name);
    htp.tabledata( c6rec.comments);
   htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
    htp.tablerowopen;
    htp.tabledata( LNG3.ADM_TXT_296 );
    htp.tabledata( LNG3.ADM_TXT_317 );
    htp.tabledata( LNG.CST_TXT_144 );
   htp.tablerowclose;
   for c7rec in c7 loop
   htp.tablerowopen;
    htp.tabledata( c7rec.table_name);
    htp.tabledata( c7rec.column_name);
    htp.tabledata( c7rec.comments);
   htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.p( '</CENTER>' );

 elsif fn = 2
  then
   -- Generate Comment File
   fl := utl_file.fopen( glbx.extract_master_parameter('REPORTS_DIRECTORY'), 'comments.txt', 'w', 32767);
   for c6rec in c6 loop
    bfr := 'comment on table ' || c6rec.table_name || ' is ''' || replace(c6rec.comments,'''','''''') || '''';
    utl_file.put_line( fl,bfr);
   end loop;
   for c7rec in c7 loop
    bfr := 'comment on column ' || c7rec.table_name || '.' || c7rec.column_name || ' is ''' || replace(c7rec.comments,'''','''''') || '''';
    utl_file.put_line( fl,bfr);
   end loop;
   utl_file.fclose( fl );
   adm.comm(surl, LNG5.EXT_TXT_106 || ':' || glbx.extract_master_parameter('REPORTS_DIRECTORY') || '-' || 'comments.txt' );

 elsif fn = 3
  then
   -- Load Comment File
   fl := utl_file.fopen( glbx.extract_master_parameter('REPORTS_DIRECTORY'), 'comments.txt', 'r', 32767);
   failed := 0;
   success := 0;
   loop
    begin
    utl_file.get_line(fl,bfr);
    if bfr is not null
     then
      begin
       execute immediate bfr;
       success := success + 1;
      exception when others then failed := failed + 1;
      end;
    end if;
    exception
     when others then exit;
    end;
   end loop;
   utl_file.fclose( fl );
   adm.comm(surl, LNG5.EXT_TXT_107 || ': ' || LNG2.PBK_TXT_115 || ':' || success || ' ' || LNG3.ADM_TXT_521 || ':' || failed );

 elsif fn = 4
  then
   -- Delete Comments
   for c2rec in c2 loop
    execute immediate 'comment on table ' || c2rec.table_name || ' is ''' || NULL || '''';
   end loop;
   for c3rec in c3 loop
    execute immediate 'comment on column ' || c3rec.table_name || '.' || c3rec.column_name || ' is ''' || NULL || '''';
   end loop;
   adm.comm(surl,LNG5.EXT_TXT_105 );
 end if;

exception when others then
 glbx.error_details( 'ADM', 'COMM_UTL', errmsg=>sqlerrm, extdet=>'FN=' || fn);
end comm_utl;

procedure cbo_table(surl varchar2, msg in varchar2 default null )
as

 cursor c1 is select table_name from user_tables where tablespace_name is not null and table_name not in (select table_name from cbo where estimate_compute in ('ESTIMATE','COMPUTE') );
 cursor c2 is select table_name,last_analyzed from user_tables where tablespace_name is not null and last_analyzed is not null order by table_name;
 cursor c3(tname varchar2) is select index_name from user_indexes where table_name = tname order by table_name;
 cursor c4 is select table_name,last_analyzed from user_tables where tablespace_name is not null and last_analyzed is null order by table_name;
 cursor c5(tname varchar2) is select index_name from user_indexes where table_name = tname order by table_name;
 cursor c6 is select index_name from piction_indexes where index_name not in (select index_name from user_indexes);

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.CBO_TABLE');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG5.EXT_TXT_110, style=>'MENU', helpid=>'A90' );
 htp.nl;
 if msg is not null then htp.header(2,msg,'CENTER' ); end if;
 htp.p( '<CENTER>' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );

  htp.tablerowopen;
     htp.tabledata( htf.bold( LNG5.EXT_TXT_114 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  for c1rec in c1 loop
  htp.tablerowopen;
     htp.tabledata( c1rec.table_name , cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );

  htp.tablerowopen;
     htp.tabledata( htf.bold( LNG5.EXT_TXT_111 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  for c2rec in c2 loop
   htp.tablerowopen;
     htp.tabledata( c2rec.table_name , cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( to_char(c2rec.last_analyzed,LNG.TSMASK), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   for c3rec in c3( c2rec.table_name ) loop
   htp.tablerowopen;
     htp.tabledata( c3rec.index_name , cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( to_char(c2rec.last_analyzed,LNG.TSMASK), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   end loop;
  end loop;
 htp.tableclose;

 htp.nl;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );

  htp.tablerowopen;
     htp.tabledata( htf.bold( LNG5.EXT_TXT_112 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  for c4rec in c4 loop
   htp.tablerowopen;
     htp.tabledata( c4rec.table_name , cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( to_char(c4rec.last_analyzed,LNG.TSMASK), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   for c5rec in c5( c4rec.table_name ) loop
   htp.tablerowopen;
     htp.tabledata( c5rec.index_name , cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( to_char(c4rec.last_analyzed,LNG.TSMASK), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   end loop;
  end loop;
 htp.tableclose;

 -- Missing indexes
 htp.nl;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );

  htp.tablerowopen;
     htp.tabledata( htf.bold( LNG5.EXT_TXT_565), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT" COLSPAN="2"' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold( LNG5.EXT_TXT_566), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( LNG5.EXT_TXT_567), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  for c6rec in c6 loop
  htp.tablerowopen;
     htp.tabledata( c6rec.index_name , cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'CBO_TABLE', errmsg=>sqlerrm, extdet=>null);
end cbo_table;

procedure chaining(surl varchar2, msg in varchar2 default null )
as

 cursor c1 is select table_name,pct_free from user_tables;
 cursor c2(tname varchar2) is select count('x') tot from chained_rows where table_name = tname;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;
 nmb		integer;
 nmb2		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.COMM');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG5.EXT_TXT_113, style=>'MENU', helpid=>'A91' );
 htp.nl;
 if msg is not null then htp.header(2,msg,'CENTER' ); end if;
 htp.p( '<CENTER>' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNG3.ADM_TXT_296), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold(LNG3.ADM_TXT_306), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold(LNG.CST_TXT_138), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold(LNG3.ADM_TXT_175), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold('%'), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;

 for c1rec in c1 loop
  delete from chained_rows where table_name = c1rec.table_name;
  execute immediate 'analyze table ' || c1rec.table_name || ' list chained rows into chained_rows';
  nmb := 0;
  nmb2 := 0;
  execute immediate 'select count(*) from ' || c1rec.table_name into nmb;
  open c2(c1rec.table_name);
  fetch c2 into nmb2;
  close c2;
  if nvl(nmb,0) > 0 and nvl(nmb2,0) > 0
   then
    htp.tablerowopen;
     htp.tabledata( c1rec.table_name, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
     htp.tabledata( to_char(c1rec.pct_free), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
     htp.tabledata( to_char(nmb), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
     htp.tabledata( to_char(nmb2), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
     if round( (nmb2/nmb)*100,2) > 10
      then
       htp.tabledata( to_char(round( (nmb2/nmb)*100,2)), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
      else
       htp.tabledata( to_char(round( (nmb2/nmb)*100,2)), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="RIGHT"' );
     end if;
   htp.tablerowclose;
  end if;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'CHAINING', errmsg=>sqlerrm, extdet=>null);
end chaining;

procedure projcodes(surl varchar2, msg in varchar2 default null )
as

 cursor c1 is select * from project_codes order by pid, project_code;
 cursor c2 is select pid,username,business_name from photographer order by business_name,username;

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.PROJCODES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG5.EXT_TXT_155, helpid=>'A94' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_projcodes' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( LNG3.ADM_TXT_261, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG4.AHC_TXT_983, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG.PHG_TXT_022, cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 for c1rec in c1 loop
  htp.formhidden( 'P0', c1rec.pid );
  htp.formhidden( 'P1', c1rec.project_code );
  htp.tablerowopen;
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER">' );
   htp.formselectopen( 'P2' );
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
   htp.tabledata( htf.formtext( 'P3', 20, 100, c1rec.project_code ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( htf.formtext( 'P4', 20, 100, c1rec.project_name ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
  htp.tablerowclose;
 end loop;
 for j in 1..10 loop
  htp.tablerowopen;
   htp.formhidden( 'P0', null );
   htp.formhidden( 'P1', null );
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER">' );
   htp.formselectopen( 'P2' );
   htp.formselectoption( NULL );
   for c2rec in c2 loop
    htp.formselectoption( c2rec.business_name || '(' || c2rec.username || ')', cattributes=>'VALUE="' || c2rec.pid || '"' );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.formtext( 'P3', 20, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( htf.formtext( 'P4', 20, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null,LNG5.EXT_TXT_156 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'PROJCODES', errmsg=>sqlerrm, extdet=>null);
end projcodes;

procedure accept_projcodes( surl varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY )
as

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_PROJCODES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 for j in p1.first..p1.last loop
 if p0(j) is null and p1(j) is null and p2(j) is not null and p3(j) is not null
  then
    insert into project_codes(pid,project_code,project_name) values (p2(j),p3(j),p4(j));
 elsif p0(j) is not null and p1(j) is not null and p2(j) is not null and p3(j) is not null
  then
   update project_codes
    set
     pid = p2(j),
     project_code = p3(j),
     project_name = p4(j)
   where pid = p0(j) and
         project_code = p1(j);
 elsif p0(j) is not null and p1(j) is not null and (p2(j) is null or p3(j) is null)
  then
   delete from project_codes where pid = p0(j) and project_code = p1(j);
  end if;
 end loop;
 commit;
 projcodes( surl,LNG3.ADM_TXT_518 );
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_PROJCODES', errmsg=>sqlerrm, extdet=>null);
end accept_projcodes;

procedure audit_email_log( surl in varchar2, msg in varchar2 default null )
as

 cursor c1 is select * from email_log order by date_created desc;

 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.AUDIT_EMAIL_LOG');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG5.EXT_TXT_194, helpid=>'A95' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( htf.bold(LNG.ORD_TXT_188), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( htf.bold(LNG3.ADM_TXT_238), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( htf.bold(LNG3.ADM_TXT_849), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( htf.bold(LNG.GLB_TXT_066), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( htf.bold(LNG2.FNM_TXT_131), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( htf.bold(LNG2.FNM_TXT_132), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( htf.bold(LNG2.FRM_TXT_032), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( htf.bold(LNG5.EXT_TXT_195), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( htf.bold(LNG5.EXT_TXT_196), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( htf.bold(LNG3.ADM_TXT_091), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 for c1rec in c1 loop
  if c1%ROWCOUNT > 100 then exit; end if;
  htp.tablerowopen;
   htp.tabledata( to_char(c1rec.date_created,LNG.TSMASK),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   if substr(c1rec.disp_type,1,5) = 'ERROR'
    then
     htp.tabledata( htf.bold(c1rec.disp_type),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
    else
     htp.tabledata( c1rec.disp_type,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   end if;
   htp.tabledata( c1rec.template,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( c1rec.mail_file,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( c1rec.mail_from,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( c1rec.mail_to,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( c1rec.mail_subject,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( c1rec.is_sms,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( nvl(c1rec.at_step,'&nbsp;'),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( nvl(c1rec.error,'&nbsp;'),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'AUDIT_EMAIL_LOG', errmsg=>sqlerrm, extdet=>null);
end audit_email_log;

procedure currencies( surl in varchar2, msg in varchar2 default null )
as

 cursor c1 is select * from postal_charge order by region;

 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.CURRENCIES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG5.EXT_TXT_197, helpid=>'A96' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_currencies' );
 htp.formhidden( 'SURL', surl );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tabledata( htf.bold(LNG.CST_TXT_116), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold(LNG5.EXT_TXT_303), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold(LNG5.EXT_TXT_304), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold(LNG5.EXT_TXT_305), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1', 30, 30, c1rec.region ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( htf.formtext( 'P2', 5, 30, c1rec.zone ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( htf.formtext( 'P3', 5, 2, c1rec.two_char_reference ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( htf.formtext( 'P4', 5, 3, c1rec.three_char_reference ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;
 end loop;
 for j in 1..3 loop
  htp.tablerowopen;
   htp.tabledata( htf.formtext( 'P1', 30, 30, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( htf.formtext( 'P2', 5, 30, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( htf.formtext( 'P3', 5, 2, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( htf.formtext( 'P4', 5, 3, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG5.EXT_TXT_198 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'ADM', 'CURRENCIES', errmsg=>sqlerrm, extdet=>null);
end currencies;

procedure accept_currencies( surl in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY )
as

 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_CURRENCIES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 delete from postal_charge;
 for j in p1.first..p1.last loop
  if p1(j) is not null
   then
    insert into postal_charge(region,zone,two_char_reference,three_char_reference) values
     (upper(p1(j)),upper(p2(j)),upper(p3(j)),upper(p4(j)));
  end if;
 end loop;
 commit;
 currencies(surl, LNG5.EXT_TXT_199 );
exception when others then
 glbx.error_details( 'ADM', 'CURRENCIES', errmsg=>sqlerrm, extdet=>null);
end accept_currencies;

procedure novelties(surl in varchar2, msg in varchar2 default null)
as

 cursor c1 is
  select novelty_set_id,ns.novelty_id,novelty_set_name
  from novelty_set ns, novelty_definition nd
  where ns.novelty_id = nd.novelty_id
  order by novelty_set_name,display_name;
 cursor c2 is select novelty_id, display_name from novelty_definition order by display_name;
 cursor c3 is
  select distinct business_name, novelty_set_name
  from novelty_set ns, charge_plan cp, photographer p
  where cp.id = p.plan_id and
        ns.novelty_set_id = cp.novelty_set_id
  order by novelty_set_name,business_name;

 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.NOVELTIES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG5.EXT_TXT_302, helpid=>'A97' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_novelties' );
 htp.formhidden( 'SURL', surl );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tabledata( htf.bold(LNG5.EXT_TXT_306), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold(LNG5.EXT_TXT_307), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 for c1rec in c1 loop
 htp.formhidden( 'P0', c1rec.novelty_set_id );
 htp.formhidden( 'P3', c1rec.novelty_id );
 htp.tablerowopen;
  htp.tabledata( htf.formtext( 'P1', 30, 100, c1rec.novelty_set_name ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER">' );
  htp.formselectopen( 'P2' );
  htp.formselectoption( NULL );
  for c2rec in c2 loop
   if c2rec.novelty_id = c1rec.novelty_id
    then
     htp.formselectoption( c2rec.display_name, 'SELECTED', cattributes=>'VALUE="' || c2rec.novelty_id || '"' );
    else
     htp.formselectoption( c2rec.display_name, cattributes=>'VALUE="' || c2rec.novelty_id || '"' );
   end if;
  end loop;
  htp.p( '</TD>' );
 htp.tablerowclose;
 end loop;
 for j in 1..5 loop
 htp.tablerowopen;
  htp.formhidden( 'P0', NULL );
  htp.formhidden( 'P3', NULL );
  htp.tabledata( htf.formtext( 'P1', 30, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER">' );
  htp.formselectopen( 'P2' );
  htp.formselectoption( NULL );
  for c2rec in c2 loop
   htp.formselectoption( c2rec.display_name, cattributes=>'VALUE="' || c2rec.novelty_id || '"' );
  end loop;
  htp.p( '</TD>' );
 htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG5.EXT_TXT_308 );
 htp.formclose;
 htp.nl;
 htp.line;
 htp.nl;
 htp.bold( LNG3.ADM_TXT_687 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tabledata( htf.bold(LNG5.EXT_TXT_301), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold(LNG3.ADM_TXT_261), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 for c3rec in c3 loop
  htp.tablerowopen;
   htp.tabledata( c3rec.novelty_set_name, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( c3rec.business_name, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'NOVELTIES', errmsg=>sqlerrm, extdet=>null);
end novelties;

procedure accept_novelties(surl in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY)
as

 cursor c1(nme varchar2) is select * from novelty_set where upper(novelty_set_name) = upper(nme);
 cursor c2 is select max(novelty_set_id)+1 mx from novelty_set;
 cursor c3(nvs integer, nvd integer) is select * from novelty_set where novelty_set_id = nvs and novelty_id = nvd;

 c1rec	c1%ROWTYPE;
 c3rec	c3%ROWTYPE;
 nmb	integer;
 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_NOVELTIES');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 for j in p0.first..p0.last loop
  if p0(j) is null and p1(j) is null
   then
    -- do nothing
    null;
  elsif p0(j) is null and p1(j) is not null and p2(j) is not null
   then
    -- insert
    c1rec.novelty_set_id := NULL;
    open c1(p1(j));
    fetch c1 into c1rec;
    close c1;
    if c1rec.novelty_set_id is null
     then
      open c2;
      fetch c2 into c1rec.novelty_set_id;
      close c2;
      c1rec.novelty_set_name := p1(j);
    end if;
    insert into novelty_set(novelty_set_id,novelty_set_name,novelty_id) values (c1rec.novelty_set_id,c1rec.novelty_set_name,p2(j));

  elsif p0(j) is not null and p1(j) is null
   then
    -- delete
    delete from novelty_set where novelty_id = p3(j) and novelty_set_id = p0(j);

  elsif p0(j) is not null and p1(j) is not null and p2(j) is not null
   then
    -- update
    open c3(p0(j),p2(j));
    fetch c3 into c3rec;
    close c3;
    if c3rec.novelty_set_name = p1(j)
     then
      update novelty_set
       set
        novelty_set_name = p1(j),
        novelty_id = p2(j)
      where
       novelty_id = p3(j) and
       novelty_set_id = p0(j);
    end if;
  end if;
 end loop;

 commit;
 novelties( surl, LNG5.EXT_TXT_309 );

exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_NOVELTIES', errmsg=>sqlerrm, extdet=>null);
end accept_novelties;

procedure calc_scene( acid in integer, directory in varchar2, scene_id in out integer, original_path in varchar2, debug in char, incalloncreate in char  )
as

 cursor c1(acid integer) is select * from customer_account where aid = acid;
 cursor c2(pscene integer, pcat varchar2, ctg varchar2) is
  select umo_scene_id
  from umo_scene
  where nvl(parent_scene,0) = nvl(pscene,0) and
        upper(title) = upper(pcat) and
        category = ctg;
 cursor c3(pscene integer) is select max(order_by) from umo_scene where parent_scene = pscene;
 cursor c4(pscene integer) is select order_by from umo_scene where umo_scene_id = pscene;

 cusrec 	c1%ROWTYPE;
 c2rec		c2%ROWTYPE;

 path 		varchar2(1000);
 parent 	varchar2(1000);
 new_title 	varchar2(1000);
 parent_path 	varchar2(1000);
 parent_title 	varchar2(1000);
 pscene		integer;
 pcat		varchar2(100);
 mx		integer;

begin
 if directory = null then return; end if;
 open c1(acid);
 fetch c1 into cusrec;
 close c1;

 --
 path := substr(directory,1,length(directory)-1); -- Truncate the trailing slash of the directory name
 parent_path := glbx.extract_fname( path, 'PWD' );
 parent := substr(parent_path,1,length(parent_path)-1);
 new_title := glbx.extract_fname( path, 'NO_EXTENSION' );
 parent_title := glbx.extract_fname( parent, 'NO_EXTENSION' );

  if debug = 'T'
   then
    htp.p( '------------------------' );
    htp.nl;
    htp.bold( 'In Calc_Scene:' );
    htp.nl;
    htp.p( 'Path: ' || path ); htp.nl;
    htp.p( 'Parent path: ' || parent_path); htp.nl;
    htp.p( 'Parent: ' || parent); htp.nl;
    htp.p( 'New Title: ' || new_title); htp.nl;
    htp.p( 'Parent Title: ' || parent_title); htp.nl;
    htp.p( 'Original Path: ' || original_path); htp.nl;
  end if;

 if parent_path is null
  then
   if debug = 'T' then htp.bold( 'Resetting scene to null due to root level and null parent path' ); htp.nl; end if;
   -- if incalloncreate = 'T' then scene_id := null; end if;
   return;
 end if;

 if parent_path = original_path and incalloncreate = 'F'
  then
   pscene := scene_id;
   pcat := new_title;
  else
   if debug = 'T' then htp.bold( 'Recursive call of calc_scene.' ); htp.nl; end if;
   calc_scene( acid, parent_path, scene_id, original_path, debug, incalloncreate );
   pscene := scene_id;
   pcat := new_title;
 end if;

 -- Safeguard
 if ((pscene is null or
      pcat is null) and incalloncreate = 'F' )
     or
    ( (instr(pcat,':') > 0) and incalloncreate = 'T' )
  then
   if debug = 'T' then htp.bold( 'Returning due to safeguard' ); htp.nl; end if;
   if instr(pcat,':') > 0
    then
     if debug = 'T' then htp.bold( 'Resetting scene to null due to root level' ); htp.nl; end if;
     scene_id := null;
   end if; -- if at root level directory set to be parent
   return;
 end if;

 open c2(pscene, pcat, cusrec.scene_name );
 fetch c2 into c2rec;
 close c2;
 -- A scene already exists use it, rather than create a new one.
 if c2rec.umo_scene_id is not null
  then
   scene_id := c2rec.umo_scene_id;
   if debug = 'T' then htp.bold( 'Returning as scene already exists:' || scene_id ); htp.nl; end if;
   if debug = 'T' then htp.bold( pcat || ':' || cusrec.scene_name || '-' || pscene ); htp.nl; end if;
   return;
 end if;

 -- Create a Private UMO Nested Scene
 select s_umo_scene.nextval into scene_id from dual;
 open c3(pscene);
 fetch c3 into mx;
 close c3;
 if mx is null
  then
   open c4(pscene);
   fetch c4 into mx;
   close c4;
   if debug = 'T' then htp.bold( 'mx was null, opening cursor c4(' || pscene || ')' ); htp.nl; end if;
 end if;
 mx := nvl(mx,0) + 5; -- Increment at a nice friendly level
 insert into umo_scene(umo_scene_id, category, parent_scene, owned_by, owner_id, order_by, title )
  values
   (scene_id, cusrec.scene_name, pscene, 'PHOTOGRAPHER', cusrec.pid, mx, pcat );
  if debug = 'T'
   then
    htp.p( '. Created New Scene:' || cusrec.scene_name || '-' || scene_id  ||':' || pscene || '-' || pcat); htp.nl;
  end if;
 commit;

end calc_scene;

procedure load_reconcilliation_data( surl varchar2, msg in varchar2 )
as

 sessid		integer;
 sts		varchar2(200);
 merchant	varchar2(100);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.LOAD_RECONCILLIATION_DATA');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG5.EXT_TXT_558, style=>'MENU', helpid=>'A105' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.nl;
 htp.bold( LNG5.EXT_TXT_559 );
 htp.nl;
 htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'adm.accept_load_reconcilliation', cattributes=>'enctype="multipart/form-data"' );
 htp.formhidden( 'SURL', surl );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.LAB_TXT_046 ), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( GLBX.UPLOAD_NAME,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  merchant := glbx.extract_master_parameter('MERCHANT_PROVIDER');
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG5.EXT_TXT_560), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT">' );
   htp.formselectopen( 'P1' );
     if merchant = 'ANZ' then htp.formselectoption( 'ANZ', 'SELECTED' ); else htp.formselectoption( 'ANZ' ); end if;
     if merchant = 'ANZ-II' then htp.formselectoption( 'ANZ-II', 'SELECTED' ); else htp.formselectoption( 'ANZ-II' ); end if;
     if merchant = 'CBANK' then htp.formselectoption( 'CBANK', 'SELECTED' ); else htp.formselectoption( 'CBANK' ); end if;
     if merchant = 'CYBERONE' then htp.formselectoption( 'CYBERONE', 'SELECTED' ); else htp.formselectoption( 'CYBERONE' ); end if;
     if merchant = 'ESEC' then htp.formselectoption( 'ESEC', 'SELECTED' ); else htp.formselectoption( 'ESEC' ); end if;
     if merchant = 'SAFEPAY' then htp.formselectoption( 'SAFEPAY', 'SELECTED' ); else htp.formselectoption( 'SAFEPAY' ); end if;
     if merchant = 'SECUREPAY' then htp.formselectoption( 'SECUREPAY', 'SELECTED' ); else htp.formselectoption( 'SECUREPAY' ); end if;
     if merchant = 'SECUREBILL' then htp.formselectoption( 'SECUREBILL', 'SELECTED' ); else htp.formselectoption( 'SECUREBILL' ); end if;
     if merchant = 'NAB' then htp.formselectoption( 'NAB', 'SELECTED' ); else htp.formselectoption( 'NAB' ); end if;
     if merchant = 'DIRECT PAYMENT(NZ)' then htp.formselectoption( 'DIRECT PAYMENT(NZ)', 'SELECTED' ); else htp.formselectoption( 'DIRECT PAYMENT(NZ)' ); end if;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG5.EXT_TXT_561), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.formtext( 'P2', 30, 100 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.formsubmit( null, LNG5.EXT_TXT_562 );
 htp.formclose;
 htp.nl;
 htp.anchor( 'adm.adm_acct_orders?surl=' || surl ,LNG2.PFM_TXT_027 );
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'LOAD_RECONCILLIATION_DATA', errmsg=>sqlerrm );
end load_reconcilliation_data;

procedure accept_load_reconcilliation( surl in varchar2, file in varchar2, p1 in varchar2, p2 in varchar2 )
as

 cursor c1 is select * from reconcilliation where trunc(date_loaded) = trunc(sysdate) order by transaction_id;

 sessid		integer;
 sts		varchar2(200);
 dump_dir	varchar2(100);
 fname		varchar2(100);
 fl		UTL_FILE.FILE_TYPE;
 bfr		varchar2(32767);
 comma_delim	GLBX.MYARRAY;
 dmy		varchar2(4000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_LOAD_RECONCILLIATION');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if p2 is null
  then
   glbx.external_file_load( surl, file, dump_dir, fname );
  else
   fname := p2;
   dump_dir := glbx.extract_master_parameter('REPORTS_DIRECTORY');
 end if;

 begin
  fl := utl_file.fopen( dump_dir, fname, 'r', 32767 );
 exception
  when others
   then htp.bold( LNG5.EXT_TXT_564 || ': ' || dump_dir || fname );
        return;
 end;

 loop
  begin
    utl_file.get_line( fl, buffer=>bfr );
    comma_delim.delete;
    glbx.comma_delimited(bfr, comma_delim);
    -- Pad out empty values with blanks
    for j in 1..10 loop
     begin dmy := comma_delim(j); exception when others then comma_delim(j) := NULL; end;
    end loop;
    if p1 = 'SECUREPAY'
     then
      process_securepay( comma_delim );
    end if;
    commit;
  exception
   when others then exit;
  end;
 end loop;

 utl_file.fclose(fl);

 -- Display Reconcilliation Data
 main_title( surl, sessid, 'Reconcilled Data Loaded Today', style=>'MENU', helpid=>'A105' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Merchant Type' ), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Transaction Id' ), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Purchase Order Details' ), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Transaction Timestamp' ), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Return Code' ), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Refunded' ), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Refunded Transaction Id' ), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( c1rec.merchant_type, cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( c1rec.transaction_id,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( c1rec.purchase_order_details,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( c1rec.transaction_timestamp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( c1rec.return_code,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( c1rec.extra_col_1,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( c1rec.extra_col_2,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.anchor( 'adm.adm_acct_orders?surl=' || surl ,LNG2.PFM_TXT_027 );
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_LOAD_RECONCILLIATION', errmsg=>sqlerrm );
end accept_load_reconcilliation;

procedure process_securepay( data in GLBX.MYARRAY )
as

 cursor c1( mrch varchar2, tid varchar2) is select 'x' exst from reconcilliation where merchant_type = mrch and transaction_id = tid;
 cursor c2( sess_id integer) is select aid from login_session where sessid = sess_id;
 cursor purch(vpoid integer, vpid integer) is select * from purchase_order where poid = vpoid and pid = vpid;

 c1rec	  c1%ROWTYPE;
 purchrec purch%ROWTYPE;

 dt	date;
 txt	varchar2(100);
 txt1	varchar2(100);
 vpid	integer;
 vpoid	integer;
 ordtot number;
 acid	integer;
 dmy	integer;
 cnv	number;

begin
 -- Return if the first value is blank or not a number
 if data(1) is null then htp.bold( 'No Data' ); return; end if;
 begin dmy := to_number(data(1)); exception when others then htp.bold( 'Bad Value:' || data(1) );return; end;

 open c1('SAFEPAY', data(1));
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
    -- If Data(8) is X then we have a refund and the row that is entered is not standard.
    if instr(data(3),'-') = 0
     then
      null;
    elsif substr(data(3),1,1) = '['
     then
      txt1 := substr(data(3),2,instr(data(3),']')-2);
      if txt1 is not null and txt1 <> substr(glbx.extract_master_parameter('NODE_NAME'),1,12)
       then
        -- Dont insert if it doesn't belong to this database
        return;
      end if;
      txt := substr(data(3),instr(data(3),']')+1);
     else
      txt := data(3);
    end if;

   begin dt := to_date(data(6),'MM/DD/YY HH:MI AM' ); exception when others then dt := null; end;
   begin cnv := to_number(replace(replace(data(4),'$',''),',','')); exception when others then cnv := null; end;
   insert into reconcilliation (date_loaded,merchant_type,transaction_id,purchase_order_details,transaction_total,cc_details,transaction_timestamp,return_code,extra_col_1)
    values
     (sysdate, 'SECUREPAY', data(1), data(3), cnv, data(5), dt, data(7), data(8));


   if instr(data(3),'-') = 0 -- Refund, none of the values match
    then
     update reconcilliation
       set
        extra_col_2 = data(3)
     where
      transaction_id = data(1);
    else
     begin vpid := substr(txt,1,instr(txt,'-')-1); exception when others then vpid := null; end;
     begin vpoid := substr(txt,instr(txt,'-')+1); exception when others then vpoid := null; end;
     open purch(vpoid,vpid);
     fetch purch into purchrec;
     close purch;
     open c2(purchrec.sessid);
     fetch c2 into acid;
     close c2;
     ordtot := glbx.grand_total_payment( vpoid, FALSE );
   end if;

   update reconcilliation
     set
      date_reconcilled = dt,
      actual_purchase_order_total = ordtot,
      actual_poid = vpoid,
      actual_pid = vpid,
      actual_aid = acid,
      actual_timestamp = purchrec.date_purchased
    where
     transaction_id = data(1);
  else
   close c1;
 end if;

exception when others then htp.bold( sqlerrm );
end process_securepay;

function new_window
 return varchar2
as
begin
 WIN_CTR := nvl(WIN_CTR,0) + 1;
 return( 'ADMIN_' || to_char(sysdate,'SSSSS') || to_char(WIN_CTR));
end new_window;

procedure cusobjs( surl varchar2, msg in varchar2 default null )
as

 cursor c1 is select distinct theme_type from main_object;

 sessid		integer;
 sts		varchar2(200);
 merchant	varchar2(100);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.CUSOBJS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, LNG3.ADM_TXT_896, style=>'MENU', helpid=>'A76' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 htp.tablerowopen;
 htp.p( '<TD ALIGN="LEFT" VALIGN="TOP">' );
 htp.ulistopen;
 for c1rec in c1 loop
  htp.listitem( htf.anchor2( 'adm.theme_objects?surl=' || glbx.rndsurl(surl) || '&ttype=' || translate(c1rec.theme_type,' ','+'), c1rec.theme_type , ctarget=>new_window ));
 end loop;
 htp.ulistclose;
 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.formopen( 'adm.theme_objects', ctarget=>new_window );
 htp.formhidden( 'SURL', surl );
 htp.formtext( 'TTYPE', 30, 100 );
 htp.nl;
 htp.formsubmit( null, LNG5.EXT_TXT_087 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'ADM', 'CUSOBJS', errmsg=>sqlerrm );
end cusobjs;

procedure otemp( surl varchar2, msg in varchar2 default null )
as

 cursor c1 is select distinct template_name from order_style_template;

 sessid		integer;
 sts		varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.OTEMP');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, 'Order Style Template Management', style=>'MENU', helpid=>'A99' );
 htp.nl;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 htp.tablerowopen;
 htp.p( '<TD ALIGN="LEFT" VALIGN="TOP">' );
 htp.ulistopen;
 for c1rec in c1 loop
  htp.listitem( htf.anchor2( 'adm.otemp_edit?surl=' || glbx.rndsurl(surl) || '&tname=' || translate(c1rec.template_name,' ','+'), c1rec.template_name , ctarget=>new_window ));
 end loop;
 htp.ulistclose;
 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.formopen( 'adm.otemp_edit', ctarget=>new_window );
 htp.formhidden( 'SURL', surl );
 htp.formtext( 'TNAME', 30, 100 );
 htp.nl;
 htp.formsubmit( null, 'Create New Template' );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'ADM', 'OTEMP', errmsg=>sqlerrm );
end otemp;

procedure otemp_edit( surl varchar2, tname in varchar2, msg in varchar2 default null )
as

 cursor c1(tname varchar2) is select * from order_style_template where template_name = tname order by template_column;
 cursor c2 is select distinct template_name from order_style_template;
 cursor c3 is select os.oid, p.username, os.name from photographer p, order_style os where p.pid = os.pid order by username,name;

 sessid		integer;
 sts		varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.OTEMP_EDIT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, 'Order Style Template Management', style=>'NOMENU', helpid=>'A99' );
 htp.nl;
 glbx.header_msg( tname || '-' || msg );
 htp.p( '<CENTER>' );
 htp.nl;
 htp.formopen( 'adm.otemp_edit_accept' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'TNAME', tname );
 htp.formhidden( 'P1', null );
 htp.formhidden( 'P2', null );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 htp.tablerowopen;
   htp.tabledata( htf.bold( 'Column Name' ), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( 'Column Value' ), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
 htp.tablerowclose;
 for c1rec in c1(tname) loop
  htp.tablerowopen;
   htp.tabledata( htf.bold( initcap(replace(c1rec.template_column,'-',' ')) ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.formhidden( 'P1', c1rec.template_column );
   htp.tabledata( htf.formtext( 'P2', 80, 4000, replace(replace(replace(c1rec.template_value,'<','&lt;'),'"','&#34;' ),'>','&gt;') ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, 'Modify Details' );
 htp.formclose;
 htp.nl;
 htp.nl;
 htp.nl;
 htp.bold( 'Utilities' );
 htp.nl;
 htp.anchor( 'adm.otemp_edit_util?surl=' || surl || '&tname=' || replace(tname,' ','+') || '&utl=RELOAD','Reload Missing Columns' );
 htp.nl;
 htp.formopen( 'adm.otemp_edit_util' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'TNAME', tname );
  htp.formselectopen( 'P1' );
  for c2rec in c2 loop
   htp.formselectoption( c2rec.template_name );
  end loop;
  htp.formselectclose;
 htp.formsubmit( 'UTL', 'Recreate Using Template' );
 htp.formclose;
 htp.nl;
 htp.formopen( 'adm.otemp_edit_util' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'TNAME', tname );
  htp.formselectopen( 'P1' );
  for c3rec in c3 loop
   htp.formselectoption( c3rec.username || '-' || c3rec.name, cattributes=>'VALUE="' || c3rec.oid || '"' );
  end loop;
  htp.formselectclose;
 htp.formsubmit( 'UTL', 'Recreate Using Order Style' );
 htp.formclose;
 htp.nl;
 htp.anchor( 'adm.otemp_edit_util?surl=' || surl || '&tname=' || replace(tname,' ','+') || '&utl=DELETE','Delete Template' );
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'ADM', 'OTEMP_EDIT', errmsg=>sqlerrm );
end otemp_edit;

procedure otemp_edit_util( surl varchar2, tname in varchar2, utl in varchar2, p1 in varchar2 default null )
as

 cursor c1 is select column_name from user_tab_columns where table_name = 'ORDER_STYLE' and column_name not in ('OID','PID','SPB','IS_DEFAULT','DATE_CREATED','DATE_UPDATED');

 sessid		integer;
 sts		varchar2(200);
 cval		varchar2(4000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.OTEMP_EDIT_UTIL');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if utl = 'RELOAD'
  then
   insert into order_style_template(template_name,template_column,template_value)
   select tname,column_name,null
   from user_tab_columns
   where (tname,column_name) not in (select template_name,template_column from order_style_template where template_name = tname) and
         table_name = 'ORDER_STYLE' and
         column_name not in ('OID','PID','SPB','IS_DEFAULT','DATE_CREATED','DATE_UPDATED');

 elsif utl = 'Recreate Using Template'
  then
   delete from order_style_template where template_name = tname;
   insert into order_style_template(template_name,template_column,template_value)
   select tname,column_name,null
   from user_tab_columns
   where table_name = 'ORDER_STYLE' and
         column_name not in ('OID','PID','SPB','IS_DEFAULT','DATE_CREATED','DATE_UPDATED');
   insert into order_style_template(template_name,template_column,template_value)
    select tname,template_column,template_value
    from order_style_template
    where template_name = p1;

 elsif utl = 'Recreate Using Order Style'
  then
   delete from order_style_template where template_name = tname;
   insert into order_style_template(template_name,template_column,template_value)
   select tname,column_name,null
   from user_tab_columns
   where table_name = 'ORDER_STYLE' and
         column_name not in ('OID','PID','SPB','IS_DEFAULT','DATE_CREATED','DATE_UPDATED');
   for c1rec in c1 loop
    begin
     execute immediate 'select ' || c1rec.column_name || ' from order_style where oid = :1'
      into cval
       using p1;
     execute immediate 'update order_style_template set template_value = :1 where template_name = :2 and template_column = :3'
      using cval, tname, c1rec.column_name;
    exception
     when others then null;
    end;
   end loop;

 elsif utl = 'DELETE'
  then
   delete from order_style_template where template_name = tname;
 end if;

 commit;
 otemp_edit(surl, tname, 'Action Performed' );

exception when others then
 glbx.error_details( 'ADM', 'OTEMP_EDIT_UTIL', errmsg=>sqlerrm );
end otemp_edit_util;

procedure otemp_edit_accept( surl varchar2, tname in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 sessid		integer;
 sts		varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.OTEMP_EDIT_ACCEPT');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 for j in p1.first..p1.last loop
 if p1(j) is not null
  then
   begin
    update order_style_template
     set
      template_value = p2(j)
    where template_name = tname and
          template_column = p1(j);
   exception
    when others then null;
   end;
 end if;
 end loop;

 commit;
 otemp_edit(surl, tname, 'Details Updated' );

exception when others then
 glbx.error_details( 'ADM', 'OTEMP_EDIT_ACCEPT', errmsg=>sqlerrm );
end otemp_edit_accept;

procedure zip_unzip(surl varchar2, msg in varchar2 default null )
as

 sessid		integer;
 sts		varchar2(200);
 sid		integer;

begin
  -- xxx for language file
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ZIP_UNZIP');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( surl, sessid, 'Manual Call Zip and Unzip', helpid=>'A100' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.header(4, 'Zip a set of files', 'CENTER' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'adm.accept_zip' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( 'Zip File Name', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( htf.formtext( 'P1', 40, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tableheader( 'Zip File Wildcard Location', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( htf.formtext( 'P5', 40, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tableheader( 'or specify individual locations', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER" COLSPAN="2"' );
 htp.tablerowclose;
 for j in 1..10 loop
 htp.tablerowopen;
  htp.tableheader( to_char(j) || '. File Name', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( htf.formtext( 'P2', 40, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 end loop;
 htp.tablerowopen;
  htp.tableheader( 'Store Path Name in Zip File', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( htf.formcheckbox( 'P3', 'T' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tableheader( 'Search for Files in Subdirectories', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( htf.formcheckbox( 'P4', 'T' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null,'Call Zip Routine' );
 htp.formclose;
 htp.nl;
 htp.line;
 htp.nl;

 htp.header(4, 'UnZip into a Directory', 'CENTER' );
 htp.formopen( 'adm.accept_unzip' );
 htp.formhidden( 'SURL',  glbx.rndsurl(surl));
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( 'Unzip File Name', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( htf.formtext( 'P1', 40, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tableheader( 'Unzip to Directory (Optional)', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( htf.formtext( 'P2', 40, 100 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tableheader( 'Use Path Names in Unzip File', cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( htf.formcheckbox( 'P3', 'T' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null,'Call Unzip Routine' );
 htp.formclose;

 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ZIP_UNZIP', errmsg=>sqlerrm, extdet=>null);
end zip_unzip;

procedure accept_zip(surl varchar2, p1 in varchar2, p2 in GLBX.MYARRAY, p3 in char default 'F', p4 in char default 'F', p5 in varchar2 )
as

 sessid			integer;
 sts			varchar2(200);
 sid			integer;
 zip_files 		UMP.MYARRAY;
 store_path_name 	boolean;
 search_sub_directories boolean;
 ctr			integer;
begin
  -- xxx for language file
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_ZIP');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if p1 is null then zip_unzip( surl, 'Specify a Zip File Name' ); return; end if;
 store_path_name := FALSE;
 if p3 = 'F' then store_path_name := TRUE; end if;
 search_sub_directories := FALSE;
 if p4 = 'T' then search_sub_directories := TRUE; end if;
 ctr := 0;

 if p5 is null
  then
   for j in p2.first..p2.last loop
    if p2(j) is not null
     then
      ctr := ctr + 1;
      zip_files(ctr) := p2(j);
    end if;
   end loop;
   if ctr = 0 then zip_unzip( surl, 'You must specify files to be Zipped.' ); return; end if;
 end if;

 if p5 is null
  then
   if ump.zip( store_path_name=>store_path_name, search_sub_directories=>search_sub_directories, zip_filename=>p1, zip_files=>zip_files )
    then
     zip_unzip( surl, 'Zip Command Successfully passed to C Program' );
    else
     zip_unzip( surl, 'Zip Command Failed when passed to C Program' );
   end if;
  else
   if ump.zip_wildcard( store_path_name=>store_path_name, search_sub_directories=>search_sub_directories, zip_filename=>p1, zip_files_wildcard=>p5 )
    then
     zip_unzip( surl, 'Zip Command Successfully passed to C Program' );
    else
     zip_unzip( surl, 'Zip Command Failed when passed to C Program' );
   end if;
 end if;
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_ZIP', errmsg=>sqlerrm, extdet=>null);
end accept_zip;

procedure accept_unzip(surl varchar2, p1 in varchar2, p2 in varchar2, p3 in char default 'F' )
as

 sessid			integer;
 sts			varchar2(200);
 sid			integer;
 store_path_name	boolean;

begin
  -- xxx for language file
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_UNZIP');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if p1 is null then zip_unzip( surl, 'Specify a Zip File Name' ); return; end if;
 store_path_name := FALSE;
 if p3 = 'T' then store_path_name := TRUE; end if;

 if ump.unzip( store_path_name=>store_path_name, unzip_filename=>p1, unzip_directory=>p2 )
  then
   zip_unzip( surl, 'Unzip Command Successfully passed to C Program' );
  else
   zip_unzip( surl, 'Unzip Command Failed when passed to C Program' );
 end if;

exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_UNZIP', errmsg=>sqlerrm, extdet=>null);
end accept_unzip;

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

procedure xml_attach_meta(surl varchar2, acid in integer, msg in varchar2 default null)
as
 cursor c1(acid integer) is select scene_name, account_name, pid from customer_account where aid = acid;
 cursor c2(v_category varchar2, v_owner_id integer) is
 select umo_scene_id,owned_by,order_by,title,parent_scene
   from umo_scene
   where category = v_category and
   owned_by = 'PUBLIC'
  union all
  select usc.umo_scene_id, usc.owned_by, usc.order_by, usc.title, usc.parent_scene
  from umo_scene usc, photographer ph
  where category = v_category and
        usc.owner_id = ph.pid and
        ph.pid = v_owner_id and
        owned_by = 'PHOTOGRAPHER'
  order by 3;

 c1rec  	c1%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.XML_ATTACH_META');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 open c1(acid);
 fetch c1 into c1rec;
 close c1;
 main_title( surl, sessid, 'XML Data Load/Attach Meta Data', style=>'NOMENU', helpid=>'A101' );
 htp.nl;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 htp.nl;
 htp.bold( c1rec.account_name );
 htp.nl;
 htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'adm.accept_xml_attach_meta', cattributes=>'enctype="multipart/form-data"' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'P2', null );
 htp.formhidden( 'P3', null );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold('Load XML File through Browser'), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( GLBX.UPLOAD_NAME,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Load XML File from Server. File Name and location.'), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.formtext( 'P1', 100, 1000 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION', 'Attach File' );
 htp.formclose;
 htp.nl;
 htp.line;
 htp.nl;
 htp.nl;
 htp.formopen( 'adm.accept_xml_attach_meta' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'FILE', null );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold('File Name (stored in REPORT_UNLOAD)'), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.formtext( 'P1', 100, 1000 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Data to Extact'), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
    htp.formselectopen( 'P2' );
    htp.formselectoption( 'Whole Account', cattributes=>'VALUE="' || null || '"' );
    for c2rec in c2(c1rec.scene_name, c1rec.pid) loop
     htp.formselectoption( lpad('.', indnt(c2rec.parent_scene),'.') || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
    end loop;
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Primary Key to use on Generation'), cattributes=>glbx.QUERY_BACKGROUND || 'valign="MIDDLE" align="LEFT"' );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT">' );
    htp.formselectopen( 'P3' );
     htp.formselectoption( 'Original Location', cattributes=>'VALUE="1"' );
     htp.formselectoption( 'Name', cattributes=>'VALUE="2"' );
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION', 'Extract Meta Data to the Server' );
 htp.formsubmit( 'ACTION', 'Extract Meta Data to the Browser' );
 htp.formclose;
 htp.nl;
 htp.bold( 'Extract XML Meta Data from Images' );
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
  glbx.error_details( 'ADM', 'XML_ATTACH_META', errmsg=>sqlerrm, extdet=>null);
end xml_attach_meta;

procedure accept_xml_attach_meta(surl in varchar2, acid in integer, file in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, action in varchar2 )
as

 cursor c1(acid integer) is select * from customer_account where aid = acid;

 c1rec		c1%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 vp1 		GLBX.MYARRAY;
 vp2 		GLBX.MYARRAY;
 bl 		boolean;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_XML_ATTACH_META');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 htp.htmlopen;
 htp.p( '<CENTER>' );
 htp.nl;
 open c1(acid);
 fetch c1 into c1rec;
 close c1;
 if p3 = '1' then bl := TRUE; else bl := FALSE; end if;

 if action = 'Extract Meta Data to the Server'
  then
    if mload.generate_xml_metatags(surl,acid,p2,glbx.extract_master_parameter('REPORTS_DIRECTORY') || DECS.UNIX_OR_NT || nvl(p1,c1rec.username),FALSE, bl)
     then
      htp.bold( 'Successfully Downloaded XML file to' || ' : ' || glbx.extract_master_parameter('REPORTS_DIRECTORY') || DECS.UNIX_OR_NT || nvl(p1,c1rec.username) );
     else
      htp.bold( 'Failed in Download' );
    end if;

 elsif action = 'Extract Meta Data to the Browser'
  then
    htp.init;
    if mload.generate_xml_metatags(surl,acid,p2,nvl(p1,c1rec.username) || '.xml',TRUE, bl)
     then
      null;
     else
      htp.bold( 'Failed in Download to ' || nvl(p1,c1rec.username) || '.xml' );
    end if;

 elsif action = 'Attach File' and file is not null
  then
    if mload.load_xml_browser(surl,acid,file,vp1,vp2)
     then
      htp.bold( 'Successfully Loaded XML file.' );
     else
      htp.bold( 'Load Failed.' );
    end if;

 elsif action = 'Attach File' and p1 is not null
  then
    if mload.load_xml_server(surl,acid,p1,vp1,vp2)
     then
      htp.bold( 'Successfully Loaded XML file.' );
     else
      htp.bold( 'Load Failed.' );
    end if;

  end if;

 htp.nl;
 htp.anchor( 'adm.xml_attach_meta?surl=' || surl || '&acid=' || acid, 'Return to Previous Screen' );
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_XML_ATTACH_META', errmsg=>sqlerrm, extdet=>null);
end accept_xml_attach_meta;

function findparm( vload_id integer, p1 in varchar2 )
  return varchar2
 as
  cursor c1(vload_id integer, p1 varchar2 ) is select parm2 from phg_batch_upload_parms where load_id = vload_id and parm1 = p1;
  c1rec	 c1%ROWTYPE;
 begin
  open c1(vload_id, p1);
  fetch c1 into c1rec;
  close c1;
  return( c1rec.parm2 );
 end findparm;

function findparm3( vload_id integer, p3 in varchar2 )
  return varchar2
 as
  cursor c1(vload_id integer, p3 varchar2 ) is select 'T' vl from phg_batch_upload_parms where load_id = vload_id and parm3 = p3;
  c1rec	 c1%ROWTYPE;
 begin
  open c1(vload_id, p3);
  fetch c1 into c1rec;
  if c1%FOUND then close c1; return( 'T' ); else close c1; return( 'F' ); end if;
end findparm3;

procedure accept_image_load_load( surl in varchar2, phgid in integer, acid in integer, ltype in varchar2, usr in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY )
as

 cursor c1(vload_id integer) is select * from phg_batch_upload where load_id = vload_id;

 c1rec		c1%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 vlid		integer;
 id		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_IMAGE_LOAD_LOAD');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 select s_phg_batch_upload.nextval into vlid from dual;

 insert into phg_batch_upload(load_id, pid, aid, load_type, usr_type, date_submitted, status ) values
  (vlid, phgid, acid, ltype, usr, sysdate, 'SUBMITTED' );

 for j in p1.first..p1.last loop
    insert into phg_batch_upload_parms(load_id,parm1,parm2) values (vlid, p1(j), p2(j) );
 end loop;

 for j in p3.first..p3.last loop
    insert into phg_batch_upload_parms(load_id,parm3) values (vlid, p3(j) );
 end loop;

 commit;

 if findparm( vlid, 'BATCH_RUN_IN_TIME' ) is not null
  then
   open c1(vlid);
   fetch c1 into c1rec;
   close c1;
   htp.p( 'ID:' || id ); htp.nl;
   htp.p( 'CALL:' || 'adm.run_load_job(surl=>''' || glbx.encrypt_password( c1rec.load_id ) || ''',vload_id=>' || c1rec.load_id || ', runfrom=>''BATCH'');'  ); htp.nl;
   htp.p( 'Time:' || ( to_number(findparm( vlid, 'BATCH_RUN_IN_TIME' )) / (24 * 60)) ); htp.nl;

    dbms_job.submit(id,'adm.run_load_job(surl=>''' || glbx.encrypt_password( c1rec.load_id ) || ''',vload_id=>' || c1rec.load_id || ', runfrom=>''BATCH'');',
     sysdate + ( to_number(findparm( vlid, 'BATCH_RUN_IN_TIME' )) / (24 * 60)) );
   commit;
   htp.p( 'Submmitted' );
   image_load( surl, c1rec.pid, c1rec.aid, c1rec.load_type, c1rec.usr_type, 'Job Submitted: ' || id || ' for time ' || to_char(sysdate + ( findparm( vlid, 'BATCH_RUN_IN_TIME' ) / (24 * 60)), 'DD Month YYYY HH24:MI') );
   return;

 elsif findparm( vlid, 'BATCH_HOUR' ) is not null
  then
    open c1(vlid);
    fetch c1 into c1rec;
    close c1;
    dbms_job.submit(id,'adm.run_load_job(surl=>''' || glbx.encrypt_password( c1rec.load_id ) || ''',vload_id=>' || c1rec.load_id || ', runfrom=>''BATCH'');',
     to_date(nvl(findparm( vlid, 'BATCH_DAY' ),to_char(sysdate,'DD')) || ' ' || nvl(findparm( vlid, 'BATCH_MONTH' ) ,to_char(sysdate,'Month')) || ' ' || nvl(findparm( vlid, 'BATCH_YEAR' ) ,to_char(sysdate,'YYYY')) || ' ' || findparm( vlid, 'BATCH_HOUR' )  || ':' || findparm( vlid, 'BATCH_MINUTE' ), 'DD Month YYYY HH24:MI') );
    commit;
    image_load( surl, c1rec.pid, c1rec.aid, c1rec.load_type, c1rec.usr_type, 'Job Submitted: ' || id || ' for time ' ||
     nvl(findparm( vlid, 'BATCH_DAY' ),to_char(sysdate,'DD')) || ' ' || nvl(findparm( vlid, 'BATCH_MONTH' ) ,to_char(sysdate,'Month')) || ' ' || nvl(findparm( vlid, 'BATCH_YEAR' ) ,to_char(sysdate,'YYYY')) || ' ' || findparm( vlid, 'BATCH_HOUR' )  || ':' || findparm( vlid, 'BATCH_MINUTE' ) );
   return;

 else
  run_load_job( surl, vlid, 'MAIN' );

 end if;

exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_IMAGE_LOAD_LOAD', errmsg=>sqlerrm);
end accept_image_load_load;

procedure run_load_job( surl in varchar2, vload_id in integer, runfrom in varchar2, p_j in integer default null, p_rsess in integer default null, parallel_range_from in integer default null, parallel_range_to in integer default null )
as

 cursor c1(vload_id integer) is select * from phg_batch_upload where load_id = vload_id;

 c1rec		c1%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 phgid		integer;
 id		integer;
 parallelism	integer;
 errmsg		varchar2(1000);

begin
 if runfrom = 'BATCH'
  then
   if not glbx.match_password( glbx.encrypt_password(to_char(vload_id)), surl )
    then
     htp.p( 'Illegal Access' );
     return;
   end if;
  else
   glbx.adm_cookie_id( surl,sessid,sts,'ADM.RUN_LOAD_JOB');
   if sts is not null
    then
     htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
   end if;
 end if;
 open c1(vload_id);
 fetch c1 into c1rec;
 close c1;

 -- Set Status to Running
 update phg_batch_upload set status = LNG2.PFM_TXT_061 || to_char(sysdate,LNG.TSMASK) where load_id = vload_id;
 commit;

 parallelism := nvl(to_number(findparm( vload_id, 'PARALLELISM' )),0);
 if parallelism > 0 and parallel_range_from is null and nvl(runfrom,'MAIN') <> 'PARALLEL' and c1rec.load_type = 'LOAD'
  then
    dbms_job.submit(id,'adm.run_load_job(surl=>''' || glbx.truncsurl(surl) || ''',vload_id=>' || vload_id || ', runfrom=>''PARALLEL'', p_j=>NULL, p_rsess=>NULL,parallel_range_from=>NULL,parallel_range_to=>NULL);' );
    commit;
    monitor_screen( surl, vload_id );
    return;
 end if;

 -- Process Parameters and Run
 if c1rec.load_type = 'LOAD'
  then
   load_images( surl, vload_id, runfrom, c1rec, p_j, p_rsess, parallel_range_from, parallel_range_to );
 elsif c1rec.load_type = 'ATTACH'
  then
   load_attach( surl, vload_id, runfrom, c1rec );
 elsif c1rec.load_type = 'META'
  then
   load_meta( surl, vload_id, runfrom, c1rec );
 end if;

 -- Load Finish - Cleanup
 if (parallelism > 0) and (parallel_range_from is not null)
  then
   -- Do not remove if in parallel (is delete later).
   null;
  else
   delete from phg_batch_upload where load_id = vload_id;
   delete from phg_batch_upload_parms where load_id = vload_id;
 end if;
 commit;

exception when others then
 glbx.error_details( 'ADM', 'RUN_LOAD_JOB', errmsg=>sqlerrm, extdet=>'VLOAD_ID:' || vload_id);
end run_load_job;

/*
function needs_parallel( rsess in varchar2 )
 return boolean
as
 cursor c1( rsess varchar2 ) is select count('x') cnt from dir_results where id = rsess and file_type = 'F' and fsize > 0;
 c1rec  c1%ROWTYPE;
begin
 open c1( rsess );
 fetch c1 into c1rec;
 close c1;
 if c1rec.cnt > MAX_PARALLEL_LD then return( TRUE ); else return( FALSE ); end if;
end needs_parallel;
*/

procedure load_images( surl in varchar2, vload_id in integer, runfrom in varchar2, c1rec in phg_batch_upload%ROWTYPE, p_j in integer default null, p_rsess in integer default null, parallel_range_from in integer default null, parallel_range_to in integer default null )
as

 cursor c2(rsess varchar2, prf in integer, prt in integer) is
  select *
  from dir_results
  where id = rsess and
        file_type = 'F' and
        fsize > 0 and
        uniqueid >= nvl(prf,0) and
        ((prt is null) or (prt is not null and uniqueid <= prt))
 order by uniqueid;

 cursor c8( phgr integer, acid integer, v_umo integer ) is select um.photo_master from umo um where umo_id = v_umo;

 parm1 				ump.parameters;
 parm2 				ump.parameters;
 ph1				ORDSYS.ORDIMAGE;
 ph2				ORDSYS.ORDIMAGE;
 display_output			GLBX.MYARRAY;
 ran_parallel			boolean;
 category			integer;
 ctr				integer;
 include_subdir			char(1);
 auto_create			char(1);
 file_load			char(1);
 store_original			char(1);
 enable_all			char(1);
 photo_no			char(1);
 debug				char(1);
 bypass_quota			char(1);
 replace_image			char(1);
 notify_by_email		char(1);
 normalize			char(1);
 incalloncreate			char(1);
 autorotate			char(1);
 terminate_program		char(1);
 parallelism			integer;
 vfile				varchar2(4000);
 filename			varchar2(4000);
 object_type			varchar2(1000);
 compression			varchar2(1000);
 ftp_directory			varchar2(1000);
 thumbnail_quality		varchar2(1000);
 thumbnail_width		varchar2(1000);
 film_roll			varchar2(1000);
 filmtype			varchar2(1000);
 webquality			varchar2(1000);
 other_convert			varchar2(1000);
 watermark			varchar2(1000);
 watermark_merge		varchar2(1000);
 watermark_text			varchar2(1000);
 watermark_placement		varchar2(1000);
 v_dir				varchar2(1000);
 metaload			varchar2(1000);
 photo_class			varchar2(100);
 nmb				integer;
 newid				integer;
 xcoord				integer;
 ycoord				integer;
 wsts				integer;
 iphoto_no			integer;
 slowdown			integer;
 include_subdirs		boolean;
 load_using_file		boolean;
 res				boolean;
 rsess				varchar2(100);
 image_type			varchar2(100);
 error_message			varchar2(4000);
 retval				varchar2(4000);
 timestart			date;
 timefinish			date;
 newid_arr			ump.myarray_int;
 sze1				ump.myarray_int;
 sze2				ump.myarray_int;
 cmp 				ump.parameters;

 -- Sub Procedures and Functions ------------------------

 function maxparallel
  return integer
 is
   cursor c1 is select count('x') cnt from all_jobs where upper(what) like 'ADM.RUN_LOAD_JOB(%MAIN%);%';
   c1rec  c1%ROWTYPE;
 begin
  open c1;
  fetch c1 into c1rec;
  close c1;
  return( nvl(c1rec.cnt,0) );
 end maxparallel;

 procedure waitall
 as
   cursor c1 is select count('x') cnt from all_jobs where upper(what) like 'ADM.RUN_LOAD_JOB(%MAIN%);%';
   c1rec  c1%ROWTYPE;
   inf	  integer;
 begin
  inf := 0;
  loop
   c1rec.cnt := 0;
   open c1;
   fetch c1 into c1rec;
   close c1;
   if c1rec.cnt = 0 then exit; end if;
   inf := inf + 1;
   if inf > 5000 then exit; end if; -- infinite loop protection
   dbms_lock.sleep(10);
   if findparm3( vload_id, 'TERMINATE_PROGRAM' ) = 'T'
    then
      return;
   end if;
  end loop;
 end waitall;

 procedure subjob( lp integer, rf integer, rt integer )
 as
  pmx	 integer;
  inf	 integer;
  id	 integer;
 begin
   inf := 0;
   loop
    pmx := maxparallel;
    if pmx < parallelism
     then
      -- submit
      --glbx.dbg('adm.run_load_job(surl=>''' || surl|| ''',vload_id=>' || vload_id || ', runfrom=>''MAIN'',p_j=>' || lp || ', p_rsess=>''' || rsess || ''',parallel_range_from=>' || rf || ',parallel_range_to=>' || rt || ');');
      dbms_job.submit(id,'adm.run_load_job(surl=>''' || surl|| ''',vload_id=>' || vload_id || ', runfrom=>''MAIN'', p_j=>' || lp || ', p_rsess=>''' || rsess || ''',parallel_range_from=>' || rf || ',parallel_range_to=>' || rt || ');' );
      commit;
      exit;
     else
      dbms_lock.sleep( 10 ); -- Wait 20 seconds and then see if any jobs have finished running
    end if;
    if findparm3( vload_id, 'TERMINATE_PROGRAM' ) = 'T'
     then
      return;
    end if;
    inf := inf + 1;
    if inf > 5000 then exit; end if; -- inf loop protection
   end loop;
 exception
  when others then null;
 end subjob;

 procedure run_parallel( lp integer )
 as

  cursor c1( rsess varchar2 ) is select * from dir_results where id = rsess and file_type = 'F' and fsize > 0 order by uniqueid;
  c1rec  c1%ROWTYPE;

  x	 integer;
  rf	 integer;
  rt	 integer;
  lt	 integer;

 begin
  x := 0;
  for c1rec in c1( rsess ) loop
   if x = 0 then rf := c1rec.uniqueid; end if;

   if x = MAX_PARALLEL_LD
    then
     rt := c1rec.uniqueid;
     subjob( lp, rf, rt );
     x := 0;
    else
     x := x + 1;
   end if;
   lt := c1rec.uniqueid;
  end loop;

  if lt >= rf
   then
     subjob( lp, rf, lt );
  end if;

 exception
  when others then null;
 end run_parallel;

 procedure process_multimedia( surl in varchar2, phgid in integer, acid in integer, utype in varchar2, v_umo in integer, vload_id in integer )
 as
  bl boolean;
 begin
    if utype = 'AUDIO'
     then
      bl := myaudio.audio_api(surl=>surl, phgid=>phgid, acid=>acid, v_umo=>v_umo,vload_id=>vload_id,action=>'MAIN_LOAD');
    elsif utype = 'VIDEO'
     then
      myvideo.video_api(v_umo=>v_umo,vload_id=>vload_id,action=>'MAIN_LOAD');
    elsif utype = 'RELATIONAL'
     then
      myrelational.relational_api(v_umo=>v_umo,vload_id=>vload_id,action=>'MAIN_LOAD');
    elsif utype = 'BLUEPRINT'
     then
      myblueprint.blueprint_api(v_umo=>v_umo,vload_id=>vload_id,action=>'MAIN_LOAD');
    elsif utype = 'DOCUMENT'
     then
      mydocument.document_api(v_umo=>v_umo,vload_id=>vload_id,action=>'MAIN_LOAD');
    end if;
 exception
  when others then glbx.dbg( 'Process Multimedia:' || sqlerrm );
 end process_multimedia;

 -- End Sub Procedures ------------------------

begin

 -- Top Level Values
 ran_parallel := FALSE;
 object_type := findparm( vload_id, 'OBJECT_TYPE' );
 compression := findparm( vload_id, 'COMPRESSION' );
 ftp_directory := findparm( vload_id, 'FTP_DIRECTORY' );
 store_original := findparm3( vload_id, 'STORE_ORIGINAL' );
 thumbnail_quality := findparm( vload_id, 'THUMBNAIL_QUALITY' );
 thumbnail_width := findparm( vload_id, 'THUMBNAIL_WIDTH' );

 filmtype := findparm( vload_id, 'FILMTYPE' );
 webquality := findparm( vload_id, 'WEBQUALITY' );
 other_convert := findparm( vload_id, 'OTHER_CONVERT' );
 if webquality = 'OTHER' and other_convert is not null then webquality := upper(other_convert); end if;
 parallelism := nvl(to_number(findparm( vload_id, 'PARALLELISM' )),0);
 slowdown := nvl(to_number(findparm( vload_id, 'SLOWDOWN' )),0);

 normalize := findparm3( vload_id, 'NORMALIZE' );
 photo_no := findparm3( vload_id, 'PHOTO_NO' );
 film_roll := findparm( vload_id, 'FILM_ROLL' );
 watermark := findparm( vload_id, 'WATERMARK' );
 watermark_merge := findparm( vload_id, 'WATERMARK_MERGE' );
 watermark_text := findparm( vload_id, 'WATERMARK_TEXT' );
 watermark_placement := findparm( vload_id, 'WATERMARK_PLACEMENT' );
 enable_all := findparm3( vload_id, 'ENABLE_ALL' );
 enable_all := nvl(enable_all,'T');
 incalloncreate := findparm3( vload_id, 'INCALLONCREATE' );
 metaload := findparm( vload_id, 'METADATA' );
 photo_class := findparm( vload_id, 'PHOTO_CLASS' );
 if metaload = 'IPTC' then metaload := 'IPTC Standard'; end if;
 if metaload = 'Adobe XML' then metaload := 'XML Format'; end if;
 autorotate := findparm3( vload_id, 'AUTOROTATE' );

 debug := findparm3( vload_id, 'DEBUG' );
 bypass_quota := findparm3( vload_id, 'BYPASS_QUOTA' );
 replace_image := findparm3( vload_id, 'REPLACE_IMAGE' );
 notify_by_email := findparm3( vload_id, 'NOTIFY_BY_EMAIL' );

 for j in 1..4 loop
  begin sze1(j) := to_number( findparm( vload_id, 'VARYINGLT' || to_char(j) ) ); exception when others then sze1(j) := null; end;
  begin sze2(j) := to_number( findparm( vload_id, 'VARYINGGT' || to_char(j) ) ); exception when others then sze2(j) := null; end;
  cmp(j) := findparm( vload_id, 'VARYINGCOMP' || to_char(j) );
 end loop;

 begin
  nmb := to_number(thumbnail_width);
 exception
  when others
   then
    thumbnail_width := nvl( glbx.userpref( c1rec.pid, c1rec.aid, 'THUMBNAIL_WIDTH' ),'140');
 end;

 begin
  nmb := to_number(watermark_merge);
  if nmb < 0 then watermark_merge := '0'; end if;
  if nmb > 100 then watermark_merge := '100'; end if;
 exception
  when others
   then
    watermark_merge := '45';
 end;

 if debug = 'T'
  then
   htp.nl;
   htp.bold( 'Debug Mode: Parameters-' ); htp.nl;
   htp.bold( 'OBJECT_TYPE' || ':' || object_type ); htp.nl;
   htp.bold(  'COMPRESSION' || ':' || compression  ); htp.nl;
   htp.bold(  'FTP_DIRECTORY' || ':' || ftp_directory ); htp.nl;
   htp.bold(  'STORE_ORIGINAL' || ':' || store_original ); htp.nl;
   htp.bold(  'THUMBNAIL_QUALITY' || ':' || thumbnail_quality ); htp.nl;
   htp.bold(  'THUMBNAIL_WIDTH' || ':' || thumbnail_width ); htp.nl;
   htp.bold(  'ENABLE_ALL' || ':' || enable_all ); htp.nl;
   htp.bold(  'PHOTO_NO' || ':' || photo_no ); htp.nl;
   htp.bold(  'FILM_ROLL' || ':' || film_roll ); htp.nl;
   htp.bold(  'IMAGE_TYPE' || ':' || filmtype ); htp.nl;
   htp.bold(  'WEBQUALITY' || ':' || webquality ); htp.nl;
   htp.bold(  'WATERMARK' || ':' || watermark ); htp.nl;
   htp.bold(  'WATERMARK_MERGE' || ':' || watermark_merge ); htp.nl;
   htp.bold(  'WATERMARK_TEXT' || ':' || watermark_text ); htp.nl;
   htp.bold(  'WATERMARK_PLACEMENT' || ':' || watermark_placement ); htp.nl;
   htp.bold(  'NORMALIZE' || ':' || normalize ); htp.nl;
   htp.bold(  'DEBUG' || ':' || debug ); htp.nl;
   htp.bold(  'BYPASS_QUOTA' || ':' || bypass_quota ); htp.nl;
   htp.bold(  'REPLACE_IMAGE' || ':' || replace_image ); htp.nl;
   htp.bold(  'NOTIFY_BY_EMAIL' || ':' || notify_by_email ); htp.nl;
   htp.bold(  'PARALLELISM' || ':' || parallelism ); htp.nl;
   htp.nl;
 end if;
 ctr := 0;
 timestart := sysdate;
 if debug = 'T'
  then
   htp.nl;
   htp.bold( 'Load Started at Time:' || to_char(timestart,'DD-Month-YYYY HH24:MI:SS' ) );
   htp.nl;
 end if;

 for j in 1..10 loop
  vfile := NULL;
  vfile := findparm( vload_id, '[' || nvl(p_j,j) || ']FILE' );
  if vfile is not null
   then
    category := NULL;
    filename := NULL;
    include_subdir := findparm3( vload_id, '[' || nvl(p_j,j) || ']INCLUDE_SUBDIR');
    auto_create := findparm3( vload_id, '[' || nvl(p_j,j) || ']AUTO_CREATE');
    file_load := findparm3( vload_id, '[' || nvl(p_j,j) || ']FILE_LOAD');
    filename := findparm( vload_id, '[' || nvl(p_j,j) || ']FILENAME' );
    category := findparm( vload_id, '[' || nvl(p_j,j) || ']CATEGORY' );

    if debug = 'T'
     then
      htp.nl;
      htp.bold( 'Debug Mode: Categories to Load to -' || nvl(p_j,j)); htp.nl;
      htp.bold(  'LOAD LOCATION' || ':' || vfile ); htp.nl;
      htp.bold(  'CATEGORY' || ':' || category ); htp.nl;
      htp.bold(  'INCLUDE_SUBDIR' || ':' || include_subdir ); htp.nl;
      htp.bold(  'AUTO_CREATE' || ':' || auto_create ); htp.nl;
      htp.bold(  'FILE_LOAD' || ':' || file_load ); htp.nl;
      htp.bold(  'FILENAME' || ':' || filename ); htp.nl;
      htp.bold(  'ON CREATE INCLUDE ALL' || ':' || incalloncreate ); htp.nl;
      htp.nl;
    end if;

    if include_subdir = 'T' then include_subdirs := TRUE; else include_subdirs := FALSE; end if;
    if file_load = 'T' then load_using_file := TRUE; else load_using_file := FALSE; end if;

    -- Extract File Names
    rsess := NULL;
    error_message := NULL;

    if (parallelism = 0)
     then
      glbx.file_listing( vfile, include_subdirs, load_using_file, filename, glbx.extract_fname( vfile, 'PWD' ), rsess, error_message );
    elsif (parallelism > 0) and (parallel_range_from is null)
     then
      glbx.file_listing( vfile, include_subdirs, load_using_file, filename, glbx.extract_fname( vfile, 'PWD' ), rsess, error_message );
        run_parallel( j );
        ran_parallel := TRUE;
        goto parallel_bypass;
    else
     rsess := p_rsess; -- Running in Parallel Mode do nothing, except run within the range
    end if;
    if error_message is null
     then
      --glbx.dbg( 'Z:' || rsess || '-' || parallel_range_from || ':' || parallel_range_to );

      for c2rec in c2(rsess,parallel_range_from,parallel_range_to) loop

       if debug = 'T'
        then
         htp.bold( vfile || ':' || c2rec.fname || '-' || c2rec.fsize || '-' || c2rec.file_type || '-' || c2rec.directory_name ); htp.nl;
         htp.bold( c2rec.full_path ); htp.nl; htp.nl;
       end if;

       terminate_program := findparm3( vload_id, 'TERMINATE_PROGRAM' );
       if terminate_program = 'T'
        then
        glbx.dbg( 'Terminated' );
         return;
       end if;

       -- Normalize is a pre option, straight image_magick call
       if normalize = 'T'
        then
         res := os_command.image_magick( 'mogrify', '-normalize ' || c2rec.full_path, display_output );
       end if;

       -- See if the Directory Needs to be Created
       if auto_create = 'T'
        then
         -- Format is [parent_scene_id]new title
         -- c2rec.full_path is the current level
         -- vfile is the original level
         category := findparm( vload_id, '[' || nvl(p_j,j) || ']CATEGORY' );
         if glbx.extract_fname( vfile, 'PWD' ) = glbx.extract_fname( c2rec.full_path, 'PWD' ) and
            incalloncreate = 'F'
          then
           -- We are at the root level. Do nothing just reset the category to the latest.
           null;
          else
           -- Check if the child directory needs to be created
           if debug = 'T'
            then
             htp.bold( 'Calculate Scene Parameters:' );
             htp.nl;
             htp.p( 'Directory: ' || glbx.extract_fname( c2rec.full_path, 'PWD' ) ); htp.nl;
             htp.p( 'Scene Id: ' || category); htp.nl;
             htp.p( 'Original Path: ' || glbx.extract_fname( vfile, 'PWD' )); htp.nl;
           end if;
           calc_scene( c1rec.aid, glbx.extract_fname( c2rec.full_path, 'PWD' ), category, glbx.extract_fname( vfile, 'PWD' ), debug,  incalloncreate );
         end if;
       end if;

       -- Load the Image
       ctr := ctr + 1;
       parm1(1)  := 'AID';
       parm2(1)  := c1rec.aid;
       parm1(2)  := 'OBJECT_TYPE';
       if object_type = 'AUTO' then image_type := nvl(glbx.auto_file_type( c2rec.fname ),'PHOTO'); else image_type := object_type; end if;
       parm2(2)  := nvl(image_type,'PHOTO');
       parm1(3)  := 'LOAD_FROM_FILE_OR_UPLOAD';
       parm2(3)  := 'FILE';
       parm1(4)  := 'CONVERT_TO';
       parm2(4)  := webquality;
       parm1(5)  := 'COMPRESSION';
       parm2(5)  := compression;
       for k in 1..4 loop
        if sze1(k) is not null and sze2(k) is not null and cmp(k) is not null
         then
          if c2rec.fsize >= (sze1(k) * 1024) and
             c2rec.fsize <= (sze2(k) * 1024)
           then
            parm2(5)  := cmp(k);
          end if;
        end if;
       end loop;
       parm1(6)  := 'LOAD_DIRECTORY';
       parm2(6)  := glbx.extract_fname(c2rec.full_path,'PWD');
       if v_dir is null then v_dir := parm2(6); end if; -- For displaying the first directory in the email
       parm1(7)  := 'FILE_NAME';
       parm2(7)  := c2rec.fname;
       parm1(8)  := 'STORE_ORIGINAL';
       if store_original = 'T'
        then
         parm2(8)  := 'TRUE';
        else
         parm2(8)  := 'FALSE';
       end if;
       parm1(9)  := 'CREATE_THUMBNAIL';
       parm2(9)  := 'TRUE';
       parm1(10) := 'THUMBNAIL_WIDTH';
       parm2(10) := thumbnail_width;
       parm1(11) := 'THUMBNAIL_QUALITY';
       parm2(11) := thumbnail_quality;
       parm1(12) := 'KEEP_STATUS';
       if replace_image = 'T'
        then
         parm2(12) := 'R';
        else
         parm2(12) := 'K';
       end if;
       parm1(13) := 'ORIGINAL_LOCATION';
       parm2(13) := c2rec.full_path;
       parm1(14) := 'PARENT_UMO_ID';
       parm2(14) := NULL;
       parm1(15) := 'SCENE_ID';
       parm2(15) := category;
       parm1(16) := 'UMO_OWNER';
       parm2(16) := 'PHOTOGRAPHER';
       parm1(17) := 'BYPASS_QUOTA_CHECK';
       if bypass_quota = 'T'
        then
         parm2(17) := 'TRUE';
        else
         parm2(17) := 'FALSE';
       end if;
       parm1(18) := 'ROLL_ID';
       parm2(18) := film_roll;
       parm1(19) := 'FILM_TYPE';
       parm2(19) := filmtype;
       parm1(20) := 'FILM_NAME';
       parm2(20) := c2rec.fname;
       parm1(21) := 'NEG_NO';
       parm2(21) := to_char(ctr);
       parm1(22) := 'PHGR_ID';
       parm2(22) := to_char(c1rec.pid);
       parm1(23) := 'NAME';
       parm2(23) := nvl(c2rec.fname,LNG3.ADM_TXT_351);
       parm1(24) := 'PHOTO ALBUM';
       parm2(24) := 'FALSE';
       parm1(25) := 'BRIDAL';
       if enable_all = 'T'
        then
         parm2(25) := 'TRUE';
        else
         parm2(25) := 'FALSE';
       end if;
       parm1(26) := 'PHOTOGRAPHER';
       parm2(26) := 'TRUE';
       parm1(27) := 'QUALITY';
       parm2(27) := 'STANDARD';
       parm1(28) := 'NOCOMPRESSIF';
       parm2(28) := NULL;
       parm1(29) := 'SCALE_TO_SIZE';
       parm2(29) := NULL;
       parm1(30) := 'SCALE_THRESHOLD';
       parm2(30) := NULL;
       parm1(31) := 'FTPLOC';
       parm2(31) := ftp_directory;
       parm1(32) := 'PHOTOGRAPHER';
       if enable_all = 'T'
        then
         parm2(32) := 'TRUE';
        else
         parm2(32) := 'FALSE';
       end if;

       if debug = 'T'
        then
         htp.p( LNG3.ADM_TXT_732 ); htp.nl;
         for k in parm1.first..parm2.last loop
          htp.p(parm1(k) || '-' || parm2(k)); htp.nl;
         end loop;
       end if;

       ump.load_uma( surl, parm1, parm2, retval, newid_arr );

       if retval is null
        then
         newid := newid_arr(newid_arr.first);
         if photo_no = 'T'
          then
           iphoto_no := glbx.find_nmb( c2rec.fname );
           update umo um
            set
             um.extras.orderby_nmb = iphoto_no
           where
            umo_id = newid;
         end if;
         insert into load_log(aid,umo_id,time_start,succeeded,filename,result) values (c1rec.aid,newid,sysdate,'T',c2rec.full_path,null);
        else
         insert into load_log(aid,umo_id,time_start,succeeded,filename,result) values (c1rec.aid,newid,sysdate,'F',c2rec.full_path,retval);
       end if;
       commit;

       -- Look to See if Watermarking is Needed
       if nvl(watermark,LNG.PHG_TXT_231) <> LNG.PHG_TXT_231
        then
	   parm1.delete;
	   parm2.delete;
	   parm1(1) := 'UMO_ID';
	   parm2(1) := newid;
	   parm1(2) := 'AID';
	   parm2(2) := to_char(c1rec.aid);
	   parm1(3) := 'OBJECT_TYPE';
	   parm2(3)  := image_type;
	   parm1(4) := 'KEEP_STATUS';
	   parm2(4) := 'KEEP';
	   parm1(5) := 'MERGE';
	   parm2(5) := 'TRANSPARENT_OFFSET';
	   parm1(6) := 'MERGE_LUCENT_OFFSET';
	   parm2(6) := to_number(watermark_merge);
           parm1(7) := 'THUMBNAIL_WIDTH';
           parm2(7) := thumbnail_width;
           parm1(8) := 'THUMBNAIL_QUALITY';
           parm2(8) := thumbnail_quality;
           parm1(9)  := 'CREATE_THUMBNAIL';
           parm2(9)  := 'TRUE';
           parm1(10)  := 'FILM_NAME';
           parm2(10)  := c2rec.fname;

	   parm1(11) := 'MERGE_UMO_ID';
           if substr(watermark,1,1) = 'T'
            then
	     parm2(11) := watermark;
	     open c8(c1rec.pid,c1rec.aid,newid);
	     fetch c8 into ph1;
	     close c8;
	     ph2 := ordsys.ordimage.init();
             ph2.width := 1;
             ph2.height := 1;
            else
             nmb := to_number(watermark);
	     open c8(c1rec.pid,c1rec.aid,newid);
	     fetch c8 into ph1;
	     close c8;
	     open c8(c1rec.pid,c1rec.aid,nmb);
	     fetch c8 into ph2;
	     close c8;
	     parm2(11) := to_char(nmb);
           end if;
           glbx.determine_wm( ph1, ph2, watermark_placement, xcoord, ycoord, wsts);
           if wsts = 1
            then
             htp.htmlopen; glbx.header_msg( LNG.PHG_TXT_457 ); htp.htmlclose; return;
           elsif wsts = 2
            then
             htp.htmlopen; glbx.header_msg( LNG.PHG_TXT_458 ); htp.htmlclose; return;
           elsif wsts = 3
            then
             htp.htmlopen; glbx.header_msg( LNG.PHG_TXT_459 ); htp.htmlclose; return;
           end if;
           parm1(12) := 'MERGE_X_COORD';
           parm2(12) := to_char(xcoord);
           parm1(13) := 'MERGE_Y_COORD';
           parm2(13) := to_char(ycoord);
           parm1(14) := 'MERGE_TEXT';
           parm2(14) := watermark_text;

	   ump.modify_uma(surl,parm1,parm2,retval);
	   if retval is not null
	    then
	     insert into load_log(aid,umo_id,time_start,succeeded,filename,result) values (c1rec.aid,newid,sysdate,'F',c2rec.fname,retval);
	     commit;
	   end if;
       end if;

       -- Extract Meta Data on Load
       if metaload is not null
        then
         res := mload.load_one_image( surl, c1rec.pid, metaload, c1rec.aid, newid );
         if autorotate = 'T'
          then
           autorotate_image( surl, newid , c1rec );
         end if;
       end if;

       -- Multimedia Additional Processing
       process_multimedia( surl, c1rec.pid, c1rec.aid, utype=>image_type, v_umo=>newid, vload_id=>vload_id );
       -- Move this to LOAD_UMA
       if image_type = 'PHOTO'
        then
         update umo set object_class = image_type where umo_id = newid;
       end if;

       -- Slow down the loading of the program
       if slowdown > 0
        then
         dbms_lock.sleep( slowdown );
       end if;

      end loop; -- for c2rec

     else
      -- Display Error Message
      htp.nl;
      htp.bold( 'Error Locating File Names for:' || vfile ); htp.nl;
      htp.bold( 'Error: ' || error_message ); htp.nl;
    end if;

  end if;

  <<parallel_bypass>>
  -- Cleanup
  --delete from dir_results where id = rsess;
  --commit;
  if p_j is not null then exit; end if;
 end loop; -- for j in 1..10 loop

 if ran_parallel then waitall; end if; -- If running in parallel then wait for it to finish
 if p_j is not null then return; end if; -- If a parallel slave job then just finish

 if findparm3( vload_id, 'IMAGEINDEX' ) = 'T'
  then
   virage_index( surl, c1rec.aid );
 end if;

 if findparm3( vload_id, 'DOCUMENTINDEX' ) = 'T'
  then
   context_index( surl, c1rec.aid );
 end if;

 if findparm3( vload_id, 'ADOBETNAIL' ) = 'T'
  then
   adobe_tnail( surl, c1rec.aid );
 end if;

 if findparm3( vload_id, 'CREATEDIRECTORYIMAGE' ) = 'T'
  then
   create_directory_images( surl, c1rec.aid );
 end if;

 timefinish := sysdate;
 if debug = 'T'
  then
   htp.nl;
   htp.bold( 'Load Finished at Time:' || to_char(timefinish,'DD-Month-YYYY HH24:MI:SS' ) );
   htp.nl;
 end if;

 if notify_by_email = 'T'
  then
   notify_load_completed(surl, c1rec.aid, v_dir, ctr );
 end if;

 glbx.displog(surl,c1rec.aid,new_window=>'F');

exception when others then
 glbx.error_details( 'ADM', 'LOAD_IMAGES', errmsg=>sqlerrm, extdet=>'VLOAD_ID:' || vload_id);
end load_images;

procedure load_attach( surl in varchar2, vload_id in integer, runfrom in varchar2, c1rec in phg_batch_upload%ROWTYPE  )
as

 cursor c2(vppm integer) is select value_c from phg_price_object where ppm_id = vppm;
 cursor c3(acid integer, missing char) is
  select *
  from umo um
  where aid = acid and
        umo_type in ('PHOTO') and
        (
         (missing = 'F') or
         (
          (missing = 'T') and
          not exists (select 'x' from umo um2 where umo_type = 'ORIGINAL_PHOTO' and um2.parent_id = um.umo_id)
         )
        );
 cursor c4(vid varchar2, vfilename varchar2 ) is select * from dir_results where upper(fname) = vfilename and id = vid;

 c4rec				c4%ROWTYPE;
 parm1 				ump.parameters;
 parm2 				ump.parameters;
 debug				char(1);
 bypass_quota			char(1);
 load_missing			char(1);
 notify_by_email		char(1);
 vfile				varchar2(4000);
 retval				varchar2(4000);
 load_filename			varchar2(1000);
 rsess				varchar2(100);
 error_message			varchar2(4000);
 timestart			date;
 timefinish			date;
 ctr				integer;
 pbook				integer;
 newid				integer;
 newid_arr			ump.myarray_int;

begin

 vfile := findparm( vload_id, 'FILE' );
 pbook := findparm( vload_id, 'PRICE_BOOK' );
 debug := findparm3( vload_id, 'DEBUG' );
 bypass_quota := findparm3( vload_id, 'BYPASS_QUOTA' );
 load_missing := findparm3( vload_id, 'LOAD_MISSING' );
 notify_by_email := findparm3( vload_id, 'NOTIFY_BY_EMAIL' );


 if debug = 'T'
  then
   htp.nl;
   htp.bold( 'Debug Mode: Parameters-' ); htp.nl;
   htp.bold( 'File Location' || ':' || vfile ); htp.nl;
   htp.bold( 'Price Book Id' || ':' || pbook ); htp.nl;
   htp.bold(  'DEBUG' || ':' || debug ); htp.nl;
   htp.bold(  'LOAD_MISSING' || ':' || load_missing ); htp.nl;
   htp.bold(  'BYPASS_QUOTA' || ':' || bypass_quota ); htp.nl;
   htp.bold(  'NOTIFY_BY_EMAIL' || ':' || notify_by_email ); htp.nl;
   htp.nl;
 end if;

 ctr := 0;
 timestart := sysdate;
 if debug = 'T'
  then
   htp.nl;
   htp.bold( 'Load Started at Time:' || to_char(timestart,'DD-Month-YYYY HH24:MI:SS' ) );
   htp.nl;
 end if;

 -- Extract File Names
 rsess := NULL;
 error_message := NULL;
 glbx.file_listing( vfile, TRUE, FALSE, null, glbx.extract_fname( vfile, 'PWD' ), rsess, error_message );

 for c3rec in c3(c1rec.aid, load_missing) loop
  if debug = 'T'
   then
    htp.nl;
    htp.bold( 'Price Book Id is: ' || pbook ); htp.nl;
  end if;

  for c2rec in c2( pbook ) loop
   load_filename := glbx.extract_fname( c3rec.extras.film_name, 'NO_EXTENSION' ) || c2rec.value_c || '.' || glbx.extract_fname( c3rec.extras.film_name, 'SUFFIX' );
   if debug = 'T'
    then
     htp.nl;
     htp.bold( 'Load File Name is:' || load_filename ); htp.nl;
   end if;

   -- Is the load_filename in the list of files extracted?
   c4rec.full_path := NULL;
   open c4(rsess,upper(load_filename) );
   fetch c4 into c4rec;
   close c4;
   if debug = 'T'
    then
     htp.nl;
     htp.bold( 'Full Path:' || c4rec.full_path ); htp.nl;
   end if;
   --
   if c4rec.full_path is not null
    then
     -- Upload the Original Image
       ctr := ctr + 1;
       parm1(1)  := 'AID';
       parm2(1)  := c1rec.aid;
       parm1(2)  := 'OBJECT_TYPE';
       parm2(2)  := 'ORIGINAL_PHOTO';
       parm1(3)  := 'LOAD_FROM_FILE_OR_UPLOAD';
       parm2(3)  := 'FILE';
       parm1(4)  := 'ORIGINAL_UMO';
       parm2(4)  := c3rec.umo_id;
       parm1(5)  := 'LOAD_DIRECTORY';
       parm2(5)  := glbx.extract_fname(c4rec.full_path,'PWD');
       parm1(6)  := 'FILE_NAME';
       parm2(6)  := c4rec.fname;
       parm1(7)  := 'STORE_ORIGINAL';
       parm2(7)  := 'TRUE';
       parm1(8)  := 'CREATE_THUMBNAIL';
       parm2(8)  := 'FALSE';
       parm1(9) := 'KEEP_STATUS';
       parm2(9) := 'K';
       parm1(10) := 'ORIGINAL_LOCATION';
       parm2(10) := c4rec.full_path;
       parm1(11) := 'UMO_OWNER';
       parm2(11) := 'PHOTOGRAPHER';
       parm1(12) := 'BYPASS_QUOTA_CHECK';
       if bypass_quota = 'T'
        then
         parm2(12) := 'TRUE';
        else
         parm2(12) := 'FALSE';
       end if;
       parm1(13) := 'PHGR_ID';
       parm2(13) := to_char(c1rec.pid);
       parm1(14) := 'PHOTOGRAPHER';
       parm2(14) := 'TRUE';
       parm1(15)  := 'FILM_NAME';
       parm2(15)  := c4rec.fname;
       ump.load_uma( surl, parm1, parm2, retval, newid_arr );
       if retval is null
        then
         insert into load_log(aid,umo_id,time_start,succeeded,filename,result) values (c1rec.aid,newid,sysdate,'T',c4rec.full_path,null);
         update umo um set um.extras.film_name = c4rec.fname where umo_id = newid;
        else
         newid := newid_arr(newid_arr.first);
         insert into load_log(aid,umo_id,time_start,succeeded,filename,result) values (c1rec.aid,newid,sysdate,'F',c4rec.full_path,retval);
       end if;
       commit;
   end if;
  end loop;
 end loop;

 timefinish := sysdate;
 if debug = 'T'
  then
   htp.nl;
   htp.bold( 'Load Finished at Time:' || to_char(timefinish,'DD-Month-YYYY HH24:MI:SS' ) );
   htp.nl;
 end if;

 if notify_by_email = 'T'
  then
   notify_load_completed(surl, c1rec.aid, vfile, ctr );
 end if;
 glbx.displog(surl,c1rec.aid,new_window=>'F');

exception when others then
 glbx.error_details( 'ADM', 'LOAD_IMAGES', errmsg=>sqlerrm, extdet=>'VLOAD_ID:' || vload_id);
end load_attach;


procedure load_meta( surl in varchar2, vload_id in integer, runfrom in varchar2, c1rec in phg_batch_upload%ROWTYPE  )
as

 cursor c1(acid integer, v_umo integer) is select umo_id, umo_type from umo where aid = acid and umo_id = v_umo;
 cursor c2(acid integer, vfilmname varchar2) is select umo_id, umo_type from umo um where aid = acid and um.extras.film_name = vfilmname;
 cursor c3(acid integer, vfilename varchar2) is
  select umo_id, umo_type
  from umo um
  where aid = acid and
  (
   (umo_type = 'PHOTO' and photo_original_loc = vfilename) or
   (umo_type = 'DOCUMENT' and document_original_loc = vfilename) or
   (umo_type = 'AUDIO' and audio_original_loc = vfilename) or
   (umo_type = 'VIDEO' and video_original_loc = vfilename) or
   (umo_type = 'BLUEPRINT' and um.blueprint_obj.blueprint_original_loc = vfilename)
  );
 cursor c3a(acid integer, vfilename varchar2) is
  select umo_id, umo_type
  from umo um
  where aid = acid and
  (
   (umo_type = 'PHOTO' and photo_original_loc like '%' || vfilename) or
   (umo_type = 'DOCUMENT' and document_original_loc like '%' || vfilename) or
   (umo_type = 'AUDIO' and audio_original_loc like '%' || vfilename) or
   (umo_type = 'VIDEO' and video_original_loc like '%' || vfilename) or
   (umo_type = 'BLUEPRINT' and um.blueprint_obj.blueprint_original_loc like '%' || vfilename)
  );
 cursor c4(acid integer, vfilename varchar2, vext varchar2) is
  select umo_id, umo_type
  from umo um
  where aid = acid and
  (
   (umo_type = 'PHOTO' and photo_original_loc like '%' || vfilename || decode(nvl(vext,'%'),'%','%','.' || vext) ) or
   (umo_type = 'DOCUMENT' and document_original_loc like '%' || vfilename || decode(nvl(vext,'%'),'%','%','.' || vext) ) or
   (umo_type = 'AUDIO' and audio_original_loc like '%' || vfilename || decode(nvl(vext,'%'),'%','%','.' || vext) ) or
   (umo_type = 'VIDEO' and video_original_loc like '%' || vfilename || decode(nvl(vext,'%'),'%','%','.' || vext) ) or
   (umo_type = 'BLUEPRINT' and um.blueprint_obj.blueprint_original_loc like '%' || vfilename || decode(nvl(vext,'%'),'%','%','.' || vext) )
  );

 f		 		utl_file.file_type;
 debug				char(1);
 ignore_first_line		char(1);
 validate_data			char(1);
 reject_record			char(1);
 stop_load			char(1);
 notify_by_email		char(1);
 vfile				varchar2(1000);
 vpk				varchar2(1000);
 vdir				varchar2(1000);
 vfilename			varchar2(1000);
 utype				varchar2(100);
 bfr				varchar2(32767);
 retval				varchar2(4000);
 vattr				integer;
 the_pk				integer;
 the_pk_val			varchar2(100);
 the_pk2			integer;
 the_pk_val2			varchar2(100);
 ctr				integer;
 pk_umoid			integer;
 pk_val				varchar2(1000);
 pk_val2			varchar2(1000);
 comma_delim			GLBX.MYARRAY;
 parm1				ump.parameters;
 parm2				ump.parameters;
 err				boolean;
 followlinks			char(1);

begin

 debug := findparm3( vload_id, 'DEBUG' );
 ignore_first_line := findparm3( vload_id, 'IGNORE_FIRST_LINE' );
 validate_data := findparm3( vload_id, 'VALIDATE_DATA' );
 reject_record := findparm3( vload_id, 'REJECT_RECORD' );
 stop_load := findparm3( vload_id, 'STOP_LOAD' );
 notify_by_email := findparm3( vload_id, 'NOTIFY_BY_EMAIL' );
 vfile := findparm( vload_id, 'FILE' );
 followlinks := findparm3( vload_id, 'FOLLOW_LINKS' );

 if debug = 'T'
   then
    htp.nl;
    htp.bold( 'Debug Mode: Comma Delimited File to Load'); htp.nl;
    htp.bold(  'IGNORE_FIRST_LINE' || ':' || ignore_first_line ); htp.nl;
    htp.bold(  'VALIDATE_DATA' || ':' || validate_data ); htp.nl;
    htp.bold(  'REJECT_RECORD' || ':' || reject_record ); htp.nl;
    htp.bold(  'STOP_LOAD' || ':' || stop_load ); htp.nl;
    htp.bold(  'NOTIFY_BY_EMAIL' || ':' || notify_by_email ); htp.nl;
    htp.bold(  'VFILE' || ':' || vfile ); htp.nl;
    htp.bold(  'FOLLOWLINKS' || ':' || followlinks ); htp.nl;
    htp.nl;
 end if;

 if vfile is not null
  then

  begin
   vdir := glbx.extract_fname( vfile, 'PWD' );
   vdir := substr(vdir,1,length(vdir)-1);
   vfilename := glbx.extract_fname( vfile, 'NO_EXTENSION' );
   if glbx.extract_fname( vfile, 'SUFFIX' ) is not null
    then
     vfilename := vfilename || '.' || glbx.extract_fname( vfile, 'SUFFIX' );
   end if;
   f := utl_file.fopen( vdir, vfilename, 'r', 32767);
  exception
   when others then
    htp.bold( 'Unable to Open File:' || vfile );
    htp.nl;
    htp.bold( sqlerrm );
    return;
  end;

  htp.bold( 'Loading Meta from File:' || vdir || ' - ' || vfilename );
  htp.nl;

  if ignore_first_line = 'T' then utl_file.get_line( f, buffer=>bfr ); end if;

  -- Find the column with the PK
  for j in 1..20 loop
    vattr := NULL;
    vpk := findparm( vload_id, '[' || j || ']PK' );
    if vpk is not null
     then
      if the_pk is null
       then
        the_pk := j;
        the_pk_val := vpk;
       else
        the_pk2 := j;
        the_pk_val2 := vpk;
        exit;
      end if;
    end if;
  end loop;

  if the_pk is null
   then
    htp.bold( 'Error: At least one column needs to be marked as the Primary Key' );
    return;
  end if;

  ctr := 0;

  if debug = 'T'
   then
    htp.bold( 'Primary Key Details:' ); htp.nl;
    htp.bold( 'The Pk:' || the_pk); htp.nl;
    htp.bold( 'The Pk Val:' || the_pk_val ); htp.nl;
    htp.bold( 'The Pk2:' || the_pk2 ); htp.nl;
    htp.bold( 'The Pk Val2:' || the_pk_val2 ); htp.nl;
  end if;

  loop

   begin
     utl_file.get_line( f, buffer=>bfr );
     comma_delim.delete;
     glbx.comma_delimited( bfr, comma_delim );
     err := FALSE;

     -- Ignore Blank Lines
     if bfr is not null
      then
       -- Extract the Primary UMO Key
       begin
        pk_val := comma_delim( the_pk );
        if the_pk2 is not null then pk_val2 := comma_delim( the_pk2 ); end if;
       exception
        when others then
         htp.nl;
         htp.bold( ctr || ':' || 'Error - did not find the Primary Key Value in the record. Position:' || the_pk || ':' || the_pk2 );
         htp.nl;
         err := TRUE;
       end;

       pk_umoid := NULL;
       if debug = 'T'
        then
         htp.bold( 'Tracking Primary Keys for:' || c1rec.aid ); htp.nl;
         htp.bold( 'Looking for:' || the_pk_val ); htp.nl;
         htp.bold( 'Primary Key Value:' || pk_val ); htp.nl;
         htp.bold( 'Primary Key Value2:' || pk_val2 ); htp.nl;
       end if;
       if the_pk_val = 'Is UMO_ID'
        then
         open c1( c1rec.aid, pk_val );
         fetch c1 into pk_umoid, utype;
         close c1;
       elsif the_pk_val = 'Is Film Name'
        then
         open c2( c1rec.aid, pk_val );
         fetch c2 into pk_umoid, utype;
         close c2;
       elsif the_pk_val = 'Is File Name (name and extension)'
        then
         open c3a( c1rec.aid, pk_val );
         fetch c3a into pk_umoid, utype;
         close c3a;
       elsif the_pk_val = 'Is Original Location'
        then
         open c3( c1rec.aid, pk_val );
         fetch c3 into pk_umoid, utype;
         close c3;
       elsif the_pk_val = 'Is File Name (extension only)'
        then
         -- assuming they have also specified file name
         open c4( c1rec.aid, pk_val2, pk_val );
         fetch c4 into pk_umoid, utype;
         close c4;
       elsif the_pk_val = 'Is File Name (name only)'
        then
         open c4( c1rec.aid, pk_val, pk_val2 ); -- extension is optional
         fetch c4 into pk_umoid, utype;
         close c4;
       end if;

       if pk_umoid is NULL
        then
         htp.bold( ctr || ':' || 'Error - did not find the Primary Key Value in the UMO Table. Looking for:' || pk_val || ' ' || 'using' || ' '|| the_pk_val );
         htp.nl;
         err := TRUE;
       end if;

       ctr := ctr + 1;

       -- If Error and Stop Load on Error then Exit
       if err and stop_load = 'T'
        then
         exit;
       end if;

       if followlinks = 'T'
        then
         if debug = 'T' then htp.bold( 'Followlinks enabled. Tracking new master. Old Pk:' || pk_umoid ); htp.nl; end if;
         followlnk( pk_umoid, debug );
         if debug = 'T' then htp.bold( 'Followlinks complete. PK is now:' || pk_umoid ); htp.nl; end if;
       end if;

       if not err
        then
         for j in 1..20 loop
          vattr := NULL;
          vattr := findparm( vload_id, '[' || j || ']COLUMN' );
          vpk := NULL;
          if vattr is not null
           then
            vpk := findparm( vload_id, '[' || j || ']PK' );
            if debug = 'T'
             then
              htp.nl;
              htp.bold( 'Debug Mode: Attributes:' || ctr || '-' || j); htp.nl;
              htp.bold(  'VATTR' || ':' || vattr ); htp.nl;
              htp.bold(  'VPK' || ':' || vpk ); htp.nl;
              htp.nl;
            end if;

            -- COMMA_DELIM contains the values, whilst the_pk points to the unique value
            parm1(1) := 'UMO_ID';
            parm2(1) := pk_umoid;
            parm1(2) := 'AID';
            parm2(2) := to_char(c1rec.aid);
            parm1(3) := 'OBJECT_TYPE';
            parm2(3) := utype;
            parm1(4) := 'KEEP_STATUS';
            parm2(4) := 'KEEP';
            parm1(5) := 'ATTRIBUTE_ID';
            begin
             parm2(5) := '[' || vattr || ']' || comma_delim( j );
             ump.modify_uma(surl,parm1,parm2,retval);
            exception
             when others
              then retval := sqlerrm;
            end;

            if retval is null
             then
              htp.bold( ctr || '-' || j || ':' || 'Loaded' );
             else
              htp.bold( ctr || '-' || j || ':' || 'Error - Modifying Meta Data:' || retval);
            end if;

          end if;
         end loop;
       end if;
     end if;

   exception
    when others then exit;
   end;
   end loop;

   utl_file.fclose(f);

 end if;

 if notify_by_email = 'T'
  then
   notify_load_completed(surl, c1rec.aid, 'Meta Data Load From' || ':' || vfile, ctr );
 end if;

exception when others then
 glbx.error_details( 'ADM', 'LOAD_IMAGES', errmsg=>sqlerrm, extdet=>'VLOAD_ID:' || vload_id);
end load_meta;

procedure image_load( surl varchar2, phgid in integer, acid in integer, typ in varchar2, usr in varchar2 default 'CUSTOMER', msg in varchar2 default null )
as

 sessid		integer;
 sts		varchar2(200);
 tmp		char(1);
 foundrec	boolean;
 cprog		boolean;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.IMAGE_LOAD');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 cprog := TRUE;
 if typ = 'LOAD'
  then
   main_title( surl, sessid, LNG5.EXT_TXT_649, style=>'NOMENU' );
   if msg is not null then glbx.header_msg( msg ); end if;
   image_load_load( surl, phgid, acid, usr, cprog );
 elsif typ = 'ATTACH'
  then
   main_title( surl, sessid, LNG5.EXT_TXT_650, style=>'NOMENU' );
   if msg is not null then glbx.header_msg( msg ); end if;
   image_load_attach( surl, phgid, acid, usr, cprog );
 elsif typ = 'META'
  then
   main_title( surl, sessid, LNG5.EXT_TXT_651, style=>'NOMENU' );
   if msg is not null then glbx.header_msg( msg ); end if;
   image_load_meta( surl, phgid, acid, usr, cprog );
 end if;

exception when others then
 glbx.error_details( 'ADM', 'IMAGE_LOAD',errmsg=>sqlerrm);
end image_load;

procedure image_load_load( surl varchar2, phgid in integer, acid in integer, usr in varchar2, cprog in boolean )
as

 cursor c1(phgid integer) is select * from photographer where pid = phgid;
 cursor c2(phgid integer, scnm varchar2, acid integer) is
 	 select order_by,title,umo_scene_id,parent_scene
	 from umo_scene usc
	 where category = scnm and
	       ((owned_by = 'PUBLIC') or ((owned_by = 'PHOTOGRAPHER') and (owner_id = phgid)))
	 order by order_by;
 cursor c3(phgid integer, acid integer) is select * from customer_account where pid=phgid and aid=acid;
 cursor c4(phgid integer) is select virtual_directory from ftp_sites_phg where pid = phgid;
 cursor c6( acid integer, ndx integer ) is
  select 'x' ctr
  from  novelty_definition nd, novelty_set ns, charge_plan cp, photographer p, customer_account ca
  where substr(where_called,3,1) = 'T' and
        nd.novelty_id = ns.novelty_id and
        ns.novelty_set_id = cp.novelty_set_id and
        cp.id = p.plan_id and
        p.pid = ca.pid and
        ca.aid = acid and
        nd.novelty_id = ndx and
        0 in (select count('x') tot from novelty_customer where aid = acid)
 union
  select 'x' ctr
  from  novelty_definition nd, customer_account ca, novelty_customer nc
  where substr(where_called,3,1) = 'T' and
        nd.novelty_id = nc.novelty_id and
        ca.aid = acid and
        nd.novelty_id = ndx and
        nc.aid = ca.aid
  order by 1;
 cursor c8(phgr integer) is select umo_id,um.extras.photo_name photo_name from umo um where umo_type = 'WATERMARK' and aid in (select aid from customer_account where pid = phgr);
 cursor c9(ttype varchar2) is select film_type from film_types where theme_type = ttype;
 cursor c10(ctyp varchar2) is select object_class from object_class where umo_type = ctyp order by decode(is_default,'T','A','B'),object_class;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c6rec		c6%ROWTYPE;
 foundrec	boolean;
 thmb_qual	integer;
 tmp2		varchar2(4000);

begin
 if phgid is not null
  then
   open c1(phgid);
   fetch c1 into c1rec;
   close c1;
   open c3(phgid,acid);
   fetch c3 into c3rec;
   close c3;
 end if;

 glbx.header_msg( c3rec.account_name || ' (' || c3rec.username || ')' );
 htp.formopen( 'ADM.ACCEPT_IMAGE_LOAD_LOAD' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PHGID', phgid );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'USR', usr );
 htp.formhidden( 'LTYPE', 'LOAD' );
 htp.formhidden( 'P1', NULL );
 htp.formhidden( 'P2', NULL );
 htp.formhidden( 'P3', NULL );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold('Load Location') || htf.nl ||
    nvl(c1rec.ftp_load_dir,glbx.extract_master_parameter('DEFAULT_CD_DIR')), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold('Category'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold('Include<BR>Sub Directories'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold('Auto Create<BR>Directory Name'), cattributes=>glbx.QUERY_BACKGROUND );
   if cprog then htp.tabledata( htf.bold('Load by File'), cattributes=>glbx.QUERY_BACKGROUND ); end if;
  htp.tablerowclose;
  for j in 1..10 loop
  htp.tablerowopen;
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formhidden( 'P1','[' || j || ']' || 'FILE' );
    htp.p('<INPUT TYPE="FILE" SIZE="50" NAME="P2"> ' );
   htp.p( '</TD>' );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formhidden( 'P1','[' || j || ']' || 'CATEGORY' );
    htp.formselectopen( 'P2' );
    foundrec := FALSE;
    htp.formselectoption( NULL );
    for c2rec in c2(phgid,c3rec.scene_name,acid) loop
      foundrec := TRUE;
      htp.formselectoption( lpad('.', glbx.indnt(c2rec.parent_scene),'.') || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
    end loop;
    htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.formcheckbox( 'P3', '[' || j || ']' || 'INCLUDE_SUBDIR' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formcheckbox( 'P3', '[' || j || ']' || 'AUTO_CREATE' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
   if cprog then htp.tabledata( htf.formcheckbox( 'P3', '[' || j || ']' || 'FILE_LOAD' ) || htf.formhidden( 'P1', '[' || j || ']' || 'FILENAME' ) || htf.formtext( 'P2', 5, 100, 'files.txt' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' ); end if;
  htp.tablerowclose;
  end loop;
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P3', 'INCALLONCREATE' ) || htf.bold( 'If Auto Create Directory, create all subdirectries right back to disk level'), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT" COLSPAN="5"' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 htp.tablerowopen;
 htp.p( '<TD valign="TOP" ALIGN="LEFT">' );

 htp.bold( 'Photo Options' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );

  htp.tablerowopen;
   htp.tabledata( htf.bold('Object Type'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">');
   htp.formhidden( 'P1','OBJECT_TYPE' );
   htp.formselectopen( 'P2' );
   if phgid is null
    then
     htp.formselectoption( 'MANUFACTURER', 'SELECTED' );
    else
     htp.formselectoption( 'AUTO', 'SELECTED' );
     htp.formselectoption( 'PHOTO' );
     htp.formselectoption( 'DOCUMENT' );
     htp.formselectoption( 'VIDEO' );
     htp.formselectoption( 'AUDIO' );
     htp.formselectoption( 'BLUEPRINT' );
   end if;
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold('Compression'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">');
   htp.formhidden( 'P1','COMPRESSION' );
   htp.formselectopen( 'P2' );
     htp.formselectoption( LNG.PHG_ALT_427, 'SELECTED', cattributes=>'VALUE="' || LNG.PHG_ALT_427 || '"' );
     htp.formselectoption( LNG.PHG_TXT_310 , cattributes=>'VALUE="H"');
     htp.formselectoption( LNG.PHG_TXT_309 , cattributes=>'VALUE="M"');
     htp.formselectoption( LNG.PHG_TXT_308 , cattributes=>'VALUE="L"');
     htp.formselectoption( 'Size to Approx 80K' , cattributes=>'VALUE="S"');
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('FTP Virtual Directory'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">');
   htp.formhidden( 'P1','FTP_DIRECTORY' );
     htp.formselectopen( 'P2' );
     htp.formselectoption( NULL );
     for c4rec in c4(phgid) loop
      htp.formselectoption( c4rec.virtual_directory );
     end loop;
     htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold('Store Original'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'STORE_ORIGINAL' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('Thumbnail Quality'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">');
   htp.formhidden( 'P1','THUMBNAIL_QUALITY' );
   thmb_qual := nvl(glbx.userpref( phgid, acid, 'SUPER_THB' ),'1');
   /*
     htp.formselectopen( 'P2' );
      for j in 1..8 loop
       if to_char(j) = thmb_qual
        then
         htp.formselectoption( to_char(j), 'SELECTED' );
        else
         htp.formselectoption( to_char(j) );
       end if;
      end loop;
     htp.formselectclose;
    */
    htp.p( glbx.quality_loop( 'P2', thmb_qual ) );
   htp.p( '</TD>' );
   htp.tabledata( htf.bold('Thumbnail Width'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.formhidden( 'P1','THUMBNAIL_WIDTH' );
   htp.tabledata( htf.formtext( 'P2', 10, 20, nvl( glbx.userpref( phgid, acid, 'THUMBNAIL_WIDTH' ),'140')), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('Image Type'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">');
   htp.formhidden( 'P1','FILMTYPE' );
     htp.formselectopen( 'P2' );
     htp.formselectoption( 'ALL', 'SELECTED' );
     for c9rec in c9(c1rec.theme_type) loop
      htp.formselectoption( c9rec.film_type );
     end loop;
     htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold('Photo Class'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT" colspan="3">');
   htp.formhidden( 'P1', 'PHOTO_CLASS' );
     htp.formselectopen( 'P2' );
     for c10rec in c10('PHOTO') loop
      htp.formselectoption( c10rec.object_class );
     end loop;
     htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('Convert Web Quality To'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">');
   htp.formhidden( 'P1','WEBQUALITY' );
     htp.formselectopen( 'P2' );
     htp.formselectoption( 'JPEG' );
     htp.formselectoption( 'GIF' );
     htp.formselectoption( 'OTHER' );
     htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold('If Other, Convert to'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formhidden( 'P1','OTHER_CONVERT' ) || htf.formtext( 'P2', 20, 1000 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;

 htp.tableclose;

 htp.p( '</TD>' );

 htp.p( '<TD valign="TOP" ALIGN="LEFT">' );
 htp.bold( 'Audio Options' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );

  htp.tablerowopen;
   htp.tabledata( htf.bold('Convert To'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT" COLSPAN="3">');
   htp.formhidden( 'P1','AUDIO_CONVERT' );
     htp.formselectopen( 'P2' );
     htp.formselectoption( 'No Conversion' );
     htp.formselectoption( 'AIFF' );
     --htp.formselectoption( 'AFT' );
     --htp.formselectoption( 'AU' );
     --htp.formselectoption( 'MPG' );
     htp.formselectoption( 'MP3' );
     --htp.formselectoption( 'MP4' );
     htp.formselectoption( 'WAVE' );
     htp.formselectoption( 'WMA' );
     --htp.formselectoption( 'RA' );
     --htp.formselectoption( 'RAM' );
     --htp.formselectoption( 'RM' );
     htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Extract from CD'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'EXTRACT_FROM_CD' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold('Use CDDB'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'USE_CDDB' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Bit Rate'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT" COLSPAN="3">');
   htp.formhidden( 'P1','BITRATE' );
     htp.formselectopen( 'P2' );
     htp.formselectoption( 'No Conversion' );
     htp.formselectoption( '1' );
     htp.formselectoption( '2' );
     htp.formselectoption( '4' );
     htp.formselectoption( '8' );
     htp.formselectoption( '16' );
     htp.formselectoption( '32' );
     htp.formselectoption( '64' );
     htp.formselectoption( '96' );
     htp.formselectoption( '128' );
     htp.formselectoption( '164' );
     htp.formselectoption( '196' );
     htp.formselectoption( '228' );
     htp.formselectoption( '256' );
     htp.formselectoption( '320' );
     htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Audio Thumbnail Format'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">');
   htp.formhidden( 'P1', 'AUDIO_FORMAT' );
     htp.formselectopen( 'P2' );
     htp.formselectoption( 'No Conversion' );
     htp.formselectoption( 'AIFF' );
     --htp.formselectoption( 'AFT' );
     --htp.formselectoption( 'AU' );
     --htp.formselectoption( 'MPG' );
     htp.formselectoption( 'MP3' );
     --htp.formselectoption( 'MP4' );
     htp.formselectoption( 'WAVE' );
     htp.formselectoption( 'WMA' );
     --htp.formselectoption( 'RA' );
     --htp.formselectoption( 'RAM' );
     --htp.formselectoption( 'RM' );
     htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold('Audio Thumbnail<BR>Length (sec)'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.formhidden( 'P1','AUDIO_LENGTH' );
   htp.tabledata( htf.formtext( 'P2', 5, 20, '10'), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Audio Class'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT" colspan="3">');
   htp.formhidden( 'P1', 'AUDIO_CLASS' );
     htp.formselectopen( 'P2' );
     for c10rec in c10('AUDIO') loop
      htp.formselectoption( c10rec.object_class );
     end loop;
     htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;

 htp.tableclose;

 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.bold( 'Modification Before Load' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P3', 'NORMALIZE' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold('Normalize Image'), cattributes=>glbx.QUERY_BACKGROUND );
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.bold( 'Modification On Load' );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold('Enable all Images'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'ENABLE_ALL', 'CHECKED' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold('Auto Extract Photo Number'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'PHOTO_NO' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('Film Roll'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.formhidden( 'P1','FILM_ROLL' );
   htp.tabledata( htf.formtext( 'P2', 10, 100 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold(LNG.PHG_TXT_365), cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">');

    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
     tmp2 := NULL;
     for c8rec in c8(phgid) loop
      tmp2 := tmp2 || htf.formselectoption( c8rec.photo_name, cattributes=>'VALUE="' || c8rec.umo_id || '"');
     end loop;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.PHG_TXT_365),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.formhidden( 'P1','WATERMARK' ) ||
                        htf.formselectopen( 'P2' ) ||
                        htf.formselectoption(LNG.PHG_TXT_231,'SELECTED') ||
                        htf.formselectoption('Text - Arial 10pt Black') ||
                        htf.formselectoption('Text - Arial 10pt White') ||
                        htf.formselectoption('Text - Arial 10pt Blue') ||
                        htf.formselectoption('Text - Arial 12pt Black') ||
                        htf.formselectoption('Text - Arial 12pt White') ||
                        htf.formselectoption('Text - Arial 12pt Blue') ||
                        htf.formselectoption('Text - Arial 14pt Black') ||
                        htf.formselectoption('Text - Arial 14pt White') ||
                        htf.formselectoption('Text - Arial 14pt Blue') ||
                        tmp2 || htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.PHG_TXT_366),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.formhidden( 'P1','WATERMARK_MERGE' ) || htf.formtext( 'P2', 5, 5,'45' ) || LNG.PHG_ALT_404,cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold( 'Watermark Text'),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.formhidden( 'P1','WATERMARK_TEXT' ) || htf.formtext( 'P2', 20, 100 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.PHG_TXT_378),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.formhidden( 'P1','WATERMARK_PLACEMENT' ) || htf.formselectopen('P2') ||
                     htf.formselectoption( '% ' || LNG.PHG_TXT_285 ) || htf.formselectoption( LNG.PHG_TXT_381 ) || htf.formselectoption( LNG.PHG_TXT_383 ) ||
                     htf.formselectoption( LNG.PHG_TXT_384 ) || htf.formselectoption( LNG.PHG_TXT_385, 'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_401 ) ||
                     htf.formselectoption( LNG.PHG_TXT_402 ) || htf.formselectoption( LNG.PHG_TXT_403 ) || htf.formselectoption( LNG.PHG_TXT_415 ) ||
                     htf.formselectclose,cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.tablerowclose;
   htp.tableclose;

   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Post Load'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">');
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( 'Meta Data' ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
       htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
       htp.formhidden( 'P1','METADATA' );
       htp.formselectopen( 'P2' );
         htp.formselectoption( null, 'SELECTED' );
         c6rec.ctr := null;
         open c6(acid, 330);
         fetch c6 into c6rec;
         close c6;
         if c6rec.ctr = 'x'
          then
           htp.formselectoption( 'IPTC' );
           htp.formselectoption( 'Adobe XML' );
           htp.formselectoption( 'EXIF' );
         end if;
       htp.formselectclose;
       htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tablerowopen;
       htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="TOP" ALIGN="LEFT">' );
         htp.formcheckbox( 'P3', 'AUTOROTATE' );
         htp.p(' ' || 'When EXIF, Auto Rotate' );
         htp.nl;
         htp.line;
         htp.formcheckbox( 'P3', 'CREATEDIRECTORYIMAGE' );
         htp.p(' ' || 'Create Directory Image' );
         htp.nl;
         htp.formcheckbox( 'P3', 'IMAGEINDEX' );
         htp.p(' ' || 'Index Images (Virage)' );
         htp.nl;
         htp.formcheckbox( 'P3', 'AUDIOINDEX' );
         htp.p(' ' || 'Index Audio (Speech)' );
         htp.nl;
         htp.formcheckbox( 'P3', 'DOCUMENTINDEX' );
         htp.p(' ' || 'Index Documents (Context)' );
         htp.nl;
         htp.formcheckbox( 'P3', 'ADOBETNAIL' );
         htp.p(' ' || 'Auto Create Thumbnail on PDF' );
       htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold('Image Size<BR>Compression'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">');
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( 'Image > (kb)' ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.bold( 'Image < (kb)' ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.bold( 'Compression' ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.tablerowclose;
     for j in 1..4 loop
      htp.tablerowopen;
       htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
        htp.formhidden( 'P1','VARYINGLT' || to_char(j) );
        htp.formtext( 'P2', 10, 20 );
       htp.p( '</TD>' );
       htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
        htp.formhidden( 'P1','VARYINGGT' || to_char(j) );
        htp.formtext( 'P2', 10, 20 );
       htp.p( '</TD>' );
       htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
       htp.formhidden( 'P1','VARYINGCOMP' || to_char(j) );
       htp.formselectopen( 'P2' );
         htp.formselectoption( null, 'SELECTED' );
         htp.formselectoption( LNG.PHG_ALT_427, cattributes=>'VALUE="' || LNG.PHG_ALT_427 || '"' );
         htp.formselectoption( LNG.PHG_TXT_310 , cattributes=>'VALUE="H"');
         htp.formselectoption( LNG.PHG_TXT_309 , cattributes=>'VALUE="M"');
         htp.formselectoption( LNG.PHG_TXT_308 , cattributes=>'VALUE="L"');
       htp.formselectclose;
       htp.p( '</TD>' );
      htp.tablerowclose;
     end loop;
    htp.tableclose;
   htp.p( '</TD>' );
  htp.tablerowclose;

 htp.tableclose;
 htp.nl;

 htp.bold( 'Run in Batch' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
      htp.tabledata(htf.bold( LNG3.ADM_TXT_767 ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
      htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">');
      htp.formhidden( 'P1','BATCH_HOUR' );
      htp.formselectopen( 'P2' );
      htp.formselectoption( NULL, 'SELECTED' );
      for j in 0..23 loop
       htp.formselectoption( to_char(j) );
      end loop;
      htp.formselectclose;
      htp.formhidden( 'P1','BATCH_MINUTE' );
      htp.formselectopen( 'P2' );
      htp.formselectoption( NULL, 'SELECTED' );
      for j in 0..59 loop
       htp.formselectoption( to_char(j) );
      end loop;
      htp.formselectclose;
      htp.nl;
      htp.formhidden( 'P1','BATCH_DAY' );
      htp.formselectopen( 'P2' );
      htp.formselectoption( NULL, 'SELECTED' );
      for j in 1..31 loop
       htp.formselectoption( to_char(j) );
      end loop;
      htp.formselectclose;
      htp.formhidden( 'P1','BATCH_MONTH' );
      htp.formselectopen( 'P2' );
      htp.formselectoption( NULL, 'SELECTED' );
      htp.formselectoption( LNG.LAB_TXT_073 );
      htp.formselectoption( LNG.LAB_TXT_074 );
      htp.formselectoption( LNG.LAB_TXT_075 );
      htp.formselectoption( LNG.LAB_TXT_076 );
      htp.formselectoption( LNG.LAB_TXT_077 );
      htp.formselectoption( LNG.LAB_TXT_078 );
      htp.formselectoption( LNG.LAB_TXT_079 );
      htp.formselectoption( LNG.LAB_TXT_080 );
      htp.formselectoption( LNG.LAB_TXT_081 );
      htp.formselectoption( LNG.LAB_TXT_082 );
      htp.formselectoption( LNG.LAB_TXT_083 );
      htp.formselectoption( LNG.LAB_TXT_084 );
      htp.formselectclose;
      htp.formhidden( 'P1','BATCH_YEAR' );
      htp.formselectopen( 'P2' );
      htp.formselectoption( NULL, 'SELECTED' );
      for j in 2001..2010 loop
       htp.formselectoption( to_char(j) );
      end loop;
      htp.formselectclose;
      htp.nl;
      htp.p( LNG.PHG_TXT_510 || ' ' );
      htp.formhidden( 'P1','BATCH_RUN_IN_TIME' );
      htp.formselectopen( 'P2' );
       htp.formselectoption( NULL, 'SELECTED' );
       htp.formselectoption( '1 Minute', cattributes=>'VALUE="1"');
       htp.formselectoption( '2 Minutes', cattributes=>'VALUE="2"');
       htp.formselectoption( '3 Minutes', cattributes=>'VALUE="3"');
       htp.formselectoption( '4 Minutes', cattributes=>'VALUE="4"');
       htp.formselectoption( '5 Minutes', cattributes=>'VALUE="5"');
       htp.formselectoption( '6 Minutes', cattributes=>'VALUE="6"');
       htp.formselectoption( '7 Minutes', cattributes=>'VALUE="7"');
       htp.formselectoption( '8 Minutes', cattributes=>'VALUE="8"');
       htp.formselectoption( '9 Minutes', cattributes=>'VALUE="9"');
       htp.formselectoption( '10 Minutes', cattributes=>'VALUE="10"');
       htp.formselectoption( '11 Minutes', cattributes=>'VALUE="11"');
       htp.formselectoption( '12 Minutes', cattributes=>'VALUE="12"');
       htp.formselectoption( '13 Minutes', cattributes=>'VALUE="13"');
       htp.formselectoption( '14 Minutes', cattributes=>'VALUE="14"');
       htp.formselectoption( '15 Minutes', cattributes=>'VALUE="15"');
       htp.formselectoption( '16 Minutes', cattributes=>'VALUE="16"');
       htp.formselectoption( '17 Minutes', cattributes=>'VALUE="17"');
       htp.formselectoption( '18 Minutes', cattributes=>'VALUE="18"');
       htp.formselectoption( '19 Minutes', cattributes=>'VALUE="19"');
       htp.formselectoption( '20 Minutes', cattributes=>'VALUE="20"');
       htp.formselectoption( '21 Minutes', cattributes=>'VALUE="21"');
       htp.formselectoption( '22 Minutes', cattributes=>'VALUE="22"');
       htp.formselectoption( '23 Minutes', cattributes=>'VALUE="23"');
       htp.formselectoption( '24 Minutes', cattributes=>'VALUE="24"');
       htp.formselectoption( '25 Minutes', cattributes=>'VALUE="25"');
       htp.formselectoption( '30 Minutes', cattributes=>'VALUE="30"');
       htp.formselectoption( '35 Minutes', cattributes=>'VALUE="35"');
       htp.formselectoption( '40 Minutes', cattributes=>'VALUE="40"');
       htp.formselectoption( '45 Minutes', cattributes=>'VALUE="45"');
       htp.formselectoption( '50 Minutes', cattributes=>'VALUE="50"');
       htp.formselectoption( '55 Minutes', cattributes=>'VALUE="55"');
       htp.formselectoption( '1 Hour', cattributes=>'VALUE="60"');
       htp.formselectoption( '1 Hour 15 Minutes', cattributes=>'VALUE="75"');
       htp.formselectoption( '1 Hour 30 Minutes', cattributes=>'VALUE="90"');
       htp.formselectoption( '1 Hour 45 Minutes', cattributes=>'VALUE="105"');
       htp.formselectoption( '2 Hours', cattributes=>'VALUE="120"');
       htp.formselectoption( '2 Hours 30 Minutes', cattributes=>'VALUE="150"');
       htp.formselectoption( '3 Hours', cattributes=>'VALUE="180"');
       htp.formselectoption( '3 Hours 30', cattributes=>'VALUE="210"');
       htp.formselectoption( '4 Hours', cattributes=>'VALUE="240"');
       htp.formselectoption( '4 Hours 30', cattributes=>'VALUE="270"');
       htp.formselectoption( '5 Hours', cattributes=>'VALUE="300"');
       htp.formselectoption( '5 Hours 30', cattributes=>'VALUE="330"');
       htp.formselectoption( '6 Hours', cattributes=>'VALUE="360"');
       htp.formselectoption( '7 Hours', cattributes=>'VALUE="420"');
       htp.formselectoption( '8 Hours', cattributes=>'VALUE="480"');
       htp.formselectoption( '9 Hours', cattributes=>'VALUE="540"');
       htp.formselectoption( '10 Hours', cattributes=>'VALUE="600"');
      htp.formselectclose;
      htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata(htf.bold( 'Run in Parallel') || htf.nl || htf.italic( 'Useful only if # images<BR>is more than 5000'),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"');
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">');
       htp.formhidden( 'P1','PARALLELISM' );
       htp.formselectopen( 'P2' );
       for j in 0..10 loop
        if j = 0
         then
          htp.formselectoption( to_char(j), 'SELECTED' );
         else
          htp.formselectoption( to_char(j) );
        end if;
       end loop;
       htp.formselectclose;
     htp.p( '</TD>' );
   htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.bold( 'Run Options' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold('Load Images Slowly (seconds delay)'), cattributes=>glbx.QUERY_BACKGROUND );
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">');
       htp.formhidden( 'P1','SLOWDOWN' );
       htp.formselectopen( 'P2' );
       for j in 0..10 loop
        if j = 0
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
   htp.tabledata( htf.bold('Debug Mode'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'DEBUG' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Bypass Quota Check'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'BYPASS_QUOTA' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Replace Image if it already exists'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'REPLACE_IMAGE' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Notify ' || c1rec.photographer_title || ' by email on Load Completion'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'NOTIFY_BY_EMAIL' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, 'Run Load' );
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'IMAGE_LOAD_LOAD',errmsg=>sqlerrm);
end image_load_load;

procedure image_load_attach( surl varchar2, phgid in integer, acid in integer, usr in varchar2, cprog in boolean )
as

 cursor c1( phgid integer ) is select * from photographer where pid = phgid;
 cursor c2( bftr varchar2 ) is select * from phg_price_object_defn where pid = phgid and multiple_type = 'T' order by name;
 cursor c3( phgid integer, acid integer ) is select * from customer_account where pid=phgid and aid=acid;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;

begin
 if phgid is not null
  then
   open c1(phgid);
   fetch c1 into c1rec;
   close c1;
   open c3(phgid,acid);
   fetch c3 into c3rec;
   close c3;
 end if;

 glbx.header_msg( c3rec.account_name || ' (' || c3rec.username || ')' );
 htp.formopen( 'ADM.ACCEPT_IMAGE_LOAD_LOAD' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PHGID', phgid );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'USR', usr );
 htp.formhidden( 'LTYPE', 'ATTACH' );
 htp.formhidden( 'P1', NULL );
 htp.formhidden( 'P2', NULL );
 htp.formhidden( 'P3', NULL );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold('Directory Images are Located in'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formhidden( 'P1','FILE' );
    htp.p('<INPUT TYPE="FILE" SIZE="50" NAME="P2"> ' );
   htp.p( '</TD>' );
  htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Price Book Mapping to Use') || htf.nl || '(files located using extension specified in price book)', cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formhidden( 'P1','PRICE_BOOK' );
    htp.formselectopen( 'P2' );
    htp.formselectoption( NULL );
    for c2rec in c2(phgid) loop
     htp.formselectoption( c2rec.name, cattributes=>'VALUE="' || c2rec.ppm_id || '"');
    end loop;
    htp.formselectclose;
   htp.p( '</TD>' );
   htp.tablerowclose;

 htp.tableclose;

 htp.nl;
 htp.bold( 'Run Options' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold('Debug Mode'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'DEBUG' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Only load Missing Originals'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'LOAD_MISSING' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Bypass Quota Check'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'BYPASS_QUOTA' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Notify ' || c1rec.photographer_title || ' by email on Load Completion'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'NOTIFY_BY_EMAIL' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.formsubmit( null, 'Run Attach Images' );
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'IMAGE_LOAD_ATTACH',errmsg=>sqlerrm);
end image_load_attach;

procedure image_load_meta( surl varchar2, phgid in integer, acid in integer, usr in varchar2, cprog in boolean )
as

 cursor c1( phgid integer ) is select * from photographer where pid = phgid;
 cursor c2( bftr varchar2 ) is select * from umo_attributes where (business_feature = bftr or business_feature is null) and umo_type in ('ALL','AUDIO','DOCUMENT','PHOTO','VIDEO','RELATIONAL','BLUEPRINT') order by umo_type, category, sub_category;
 cursor c3( phgid integer, acid integer ) is select * from customer_account where pid=phgid and aid=acid;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;

begin
 if phgid is not null
  then
   open c1(phgid);
   fetch c1 into c1rec;
   close c1;
   open c3(phgid,acid);
   fetch c3 into c3rec;
   close c3;
 end if;

 glbx.header_msg( c3rec.account_name || ' (' || c3rec.username || ')' );
 htp.formopen( 'ADM.ACCEPT_IMAGE_LOAD_LOAD' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PHGID', phgid );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'USR', usr );
 htp.formhidden( 'LTYPE', 'META' );
 htp.formhidden( 'P1', NULL );
 htp.formhidden( 'P2', NULL );
 htp.formhidden( 'P3', NULL );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold('Comma Delimited File Load Location'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formhidden( 'P1','FILE' );
    htp.p('<INPUT TYPE="FILE" SIZE="50" NAME="P2"> ' );
   htp.p( '</TD>' );
  htp.tablerowclose;

  for j in 1..20 loop
   htp.tablerowopen;
    htp.tabledata( htf.bold('Column' || ' ' || to_char(j)), cattributes=>glbx.QUERY_BACKGROUND );
    htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formhidden( 'P1','[' || to_char(j) || ']COLUMN' );
    htp.formselectopen( 'P2' );
    htp.formselectoption( NULL );
    for c2rec in c2(c3rec.theme_type) loop
     htp.formselectoption( '[' || c2rec.umo_type || ']' || c2rec.category || '-' || c2rec.sub_category, cattributes=>'VALUE="' || c2rec.attribute_id || '"' );
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formhidden( 'P1','[' || to_char(j) || ']PK' );
    htp.formselectopen( 'P2' );
    htp.formselectoption( NULL );
    htp.formselectoption( 'Is UMO_ID' );
    htp.formselectoption( 'Is Film Name' );
    htp.formselectoption( 'Is File Name (name and extension)' );
    htp.formselectoption( 'Is File Name (name only)' );
    htp.formselectoption( 'Is File Name (extension only)' );
    htp.formselectoption( 'Is Original Location' );
    htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  end loop;
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P3', 'FOLLOW_LINKS' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold('If Images are linked, follow links and only update master image'), cattributes=>glbx.QUERY_BACKGROUND || ' COLSPAN="2"'  );
  htp.tablerowclose;

 htp.tableclose;

 htp.nl;
 htp.bold( 'Run Options' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold('Debug Mode'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'DEBUG' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Ignore First Line (header)'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'IGNORE_FIRST_LINE' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Validate Data on Load'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'VALIDATE_DATA' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Reject Record if Validation Fails'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'REJECT_RECORD' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Stop load if Validation Fails'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'STOP_LOAD' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Notify ' || c1rec.photographer_title || ' by email on Load Completion'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.formcheckbox( 'P3', 'NOTIFY_BY_EMAIL' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.formsubmit( null, 'Run Meta Data Load' );
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'IMAGE_LOAD_META',errmsg=>sqlerrm);
end image_load_meta;

function recurse_ahead( v_umo integer, lktype char, infctr in integer default 50 )
 return integer
as
  cursor c1( v_umo integer, lktype char ) is select * from umo_link where umo_id = v_umo and link_type = lktype;
  cursor c2( v_umo integer ) is select is_global from umo where umo_id = v_umo;
  c2rec c2%ROWTYPE;
  vl    integer;
 begin
  if infctr = 0 then return( null ); end if;
  for c1rec in c1( v_umo, lktype ) loop
   open c2(c1rec.to_umo_id);
   fetch c2 into c2rec;
   close c2;
   if c2rec.is_global = 'T' then return( c1rec.to_umo_id ); end if;
   vl := recurse_ahead(c1rec.to_umo_id, lktype, infctr-1);
   if vl is not null then return( vl ); end if;
  end loop;
  return( null );
end recurse_ahead;

procedure followlnk( pk_umoid in out integer, debug in char )
as
begin
 pk_umoid := nvl(recurse_ahead( pk_umoid, 'V' ),pk_umoid);
end followlnk;

procedure autorotate_image(surl in varchar2, v_umo in integer, c1rec in phg_batch_upload%ROWTYPE )
as

 res		boolean;
 parmarr1	ump.parameters;
 parmarr2	ump.parameters;
 orient		varchar2(1000);
 nmb		integer;

begin
  -- XXX: Note in V5, make this more efficient, as it has to redo the EXIF extraction here

  res := ump.identify_image( surl, c1rec.aid, v_umo, parmarr1, parmarr2 );
  for j in parmarr1.first..parmarr1.last loop
   if parmarr1(j)='ORIENTATION' then orient := trim(parmarr2(j)); exit; end if;
  end loop;

  begin nmb := to_number(orient); exception when others then nmb := null; end;
  if orient is null then return; end if; -- Nothing there to indicate rotation so do not do anything

  if nmb = 1
   then
    return; -- Image OK nothing to do
  elsif nmb = 2
   then
    res := ump.image_magick_rotate( surl, v_umo, c1rec.aid, LNG.PHG_TXT_469, parmarr1, parmarr2 ); -- Flip
  elsif nmb = 3
   then
    res := ump.image_magick_rotate( surl, v_umo, c1rec.aid, LNG.PHG_TXT_468, parmarr1, parmarr2 ); -- 180
    res := ump.image_magick_rotate( surl, v_umo, c1rec.aid, LNG.PHG_TXT_469, parmarr1, parmarr2 ); -- Flip
  elsif nmb = 4
   then
    res := ump.image_magick_rotate( surl, v_umo, c1rec.aid, LNG.PHG_TXT_468, parmarr1, parmarr2 ); -- 180
  elsif nmb = 5
   then
    res := ump.image_magick_rotate( surl, v_umo, c1rec.aid, LNG.PHG_TXT_466, parmarr1, parmarr2 ); -- Rotate 90
  elsif nmb = 6
   then
    res := ump.image_magick_rotate( surl, v_umo, c1rec.aid, LNG.PHG_TXT_467, parmarr1, parmarr2 ); -- Rotate 270
  elsif nmb = 7
   then
    res := ump.image_magick_rotate( surl, v_umo, c1rec.aid, LNG.PHG_TXT_467, parmarr1, parmarr2 ); -- Rotate 270
    res := ump.image_magick_rotate( surl, v_umo, c1rec.aid, LNG.PHG_TXT_469, parmarr1, parmarr2 ); -- Flip
  elsif nmb = 8
   then
    res := ump.image_magick_rotate( surl, v_umo, c1rec.aid, LNG.PHG_TXT_466, parmarr1, parmarr2 ); -- Rotate 90
    res := ump.image_magick_rotate( surl, v_umo, c1rec.aid, LNG.PHG_TXT_469, parmarr1, parmarr2 ); -- Flip
  end if;

end autorotate_image;

procedure mng_ftrs(surl varchar2, src in varchar2 default null, ins in char default 'F', msg in varchar2 default null)
as

 cursor c1(src varchar2) is
 select *
 from piction_feature_list
 where
  upper(feature) like '%' || upper(src) || '%' or
  upper(testing_notes) like '%' || upper(src) || '%'
 order by id;

 sessid		integer;
 sts		varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MNG_FTRS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 main_title( surl, sessid, 'Manage Piction Features', style=>'MENU', helpid=>'A102' );
 htp.formopen( 'adm.accept_mng_ftrs' );
 htp.formhidden( 'SURL', surl );
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
 htp.tablerowopen;
  htp.tabledata( htf.bold( 'Area' ) );
  htp.tabledata( htf.bold( 'Group' ) );
  htp.tabledata( htf.bold( 'Sub Group' ) );
  htp.tabledata( htf.bold( 'XRef Screen Id' ) );
  htp.tabledata( htf.bold( 'Feature' ) );
  htp.tabledata( htf.bold( 'Testing Notes' ) );
 htp.tablerowclose;
 if ins = 'F'
  then
   htp.formhidden( 'VID', null );
   htp.formhidden( 'P1', null );
   htp.formhidden( 'P2', null );
   htp.formhidden( 'P3', null );
   htp.formhidden( 'P4', null );
   htp.formhidden( 'P5', null );
   htp.formhidden( 'P6', null );
   for c1rec in c1(src) loop
    htp.tablerowopen;
     htp.p( '<TD>' );
     htp.formhidden( 'VID', c1rec.id );
      htp.formselectopen( 'P1' );
       if c1rec.area = 'Admin' then htp.formselectoption( 'Admin', 'SELECTED' ); else htp.formselectoption( 'Admin' ); end if;
       if c1rec.area = 'Command Centre' then htp.formselectoption( 'Command Centre', 'SELECTED' ); else htp.formselectoption( 'Command Centre' ); end if;
       if c1rec.area = 'Manufacturer' then htp.formselectoption( 'Manufacturer', 'SELECTED' ); else htp.formselectoption( 'Manufacturer' ); end if;
       if c1rec.area = 'Customer' then htp.formselectoption( 'Customer', 'SELECTED' ); else htp.formselectoption( 'Customer' ); end if;
       if c1rec.area = 'Skin' then htp.formselectoption( 'Skin', 'SELECTED' ); else htp.formselectoption( 'Skin' ); end if;
       if c1rec.area = 'Reporting' then htp.formselectoption( 'Reporting', 'SELECTED' ); else htp.formselectoption( 'Reporting' ); end if;
       if c1rec.area = 'Environment' then htp.formselectoption( 'Environment', 'SELECTED' ); else htp.formselectoption( 'Environment' ); end if;
      htp.formselectclose;
     htp.p( '</TD>' );
     htp.tabledata( htf.formtext( 'P2', 20, 100, c1rec.feature_group ));
     htp.tabledata( htf.formtext( 'P3', 20, 100, c1rec.feature_subgroup ));
     htp.tabledata( htf.formtext( 'P4', 5, 10, c1rec.xref_screen_id ));
     htp.tabledata( htf.formtextareaopen( 'P5', 3, 30 ) || c1rec.feature || htf.formtextareaclose );
     htp.tabledata( htf.formtextareaopen( 'P6', 3, 30 ) || c1rec.testing_notes || htf.formtextareaclose );
    htp.tablerowclose;
    if c1%ROWCOUNT > 20 then exit; end if;
   end loop;
  else
   for j in 1..20 loop
    htp.tablerowopen;
     htp.p( '<TD>' );
     htp.formhidden( 'VID', null );
      htp.formselectopen( 'P1' );
       htp.formselectoption( 'Admin' );
       htp.formselectoption( 'Command Centre' );
       htp.formselectoption( 'Manufacturer' );
       htp.formselectoption( 'Customer' );
       htp.formselectoption( 'Skin' );
       htp.formselectoption( 'Reporting' );
       htp.formselectoption( 'Environment' );
      htp.formselectclose;
     htp.p( '</TD>' );
     htp.tabledata( htf.formtext( 'P2', 20, 100 ));
     htp.tabledata( htf.formtext( 'P3', 20, 100 ));
     htp.tabledata( htf.formtext( 'P4', 5, 10 ));
     htp.tabledata( htf.formtextarea( 'P5', 3, 30 ) );
     htp.tabledata( htf.formtextarea( 'P6', 3, 30 ) );
    htp.tablerowclose;
   end loop;
 end if;
 htp.tableclose;
 htp.nl;
 htp.bold( 'Search' || htf.formtext( 'SRC', 30, 100, src ) );
 htp.formsubmit( 'ACTION', 'Save' );
 htp.formsubmit( 'ACTION', 'Insert' );
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MNG_FTRS', errmsg=>sqlerrm, extdet=>'SRC=' || src);
end mng_ftrs;

procedure accept_mng_ftrs(surl varchar2, src in varchar2 default null, vid in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, action in varchar2)
as

 cursor c1 is select max(id) mx from piction_feature_list;

 sessid		integer;
 sts		varchar2(200);
 mx		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.ACCEPT_MNG_FTRS');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 if action = 'Insert' then mng_ftrs( surl, src, 'T' ); return; end if;

 for j in p1.first..p1.last loop
  if vid(j) is null and p1(j) is null
   then
    null;
  elsif vid(j) is null and p1(j) is not null
   then
    open c1;
    fetch c1 into mx;
    close c1;
    mx := nvl(mx,0) + 1;
    insert into piction_feature_list(id,area,feature_group,feature_subgroup,xref_screen_id,feature,testing_notes) values
     (mx, p1(j), p2(j), p3(j), p4(j), p5(j), p6(j) );

  elsif vid(j) is not null and p1(j) is not null
   then
    update piction_feature_list
     set
      area = p1(j),
      feature_group = p2(j),
      feature_subgroup = p3(j),
      xref_screen_id = p4(j),
      feature = p5(j),
      testing_notes = p6(j)
    where
     id = vid(j);
  end if;
 end loop;
 commit;
 mng_ftrs( surl, src, 'F' );
exception when others then
 glbx.error_details( 'ADM', 'ACCEPT_MNG_FTRS', errmsg=>sqlerrm, extdet=>'SRC=' || src);
end accept_mng_ftrs;

procedure monitor_screen( surl in varchar2, vload_id in integer, trm in char default 'F' )
as

 cursor c1 is select * from all_jobs where upper(what) like 'ADM.RUN_LOAD_JOB%' order by job;
 cursor c2(acid integer) is select count('x') cnt from umo where aid = acid;
 cursor c3( vload_id integer ) is select * from phg_batch_upload where load_id = vload_id;
 cursor c4( vid varchar2 ) is select count('x') cnt from dir_results where id = vid;

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 x		integer;
 y		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.MONITOR_SCREEN');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 main_title( surl, sessid, 'Monitor Parallel Load Screen', style=>'NOMENU', helpid=>'A106' );
 open c3(vload_id);
 fetch c3 into c3rec;
 close c3;
 open c2(c3rec.aid);
 fetch c2 into c2rec;
 close c2;

 if trm = 'T'
  then
   delete from phg_batch_upload_parms where load_id = vload_id and parm3 = 'TERMINATE_PROGRAM';
   insert into phg_batch_upload_parms(load_id,parm3) values (vload_id,'TERMINATE_PROGRAM');
   commit;
   htp.bold( 'Command Sent to Program to Terminate' );
   htp.nl;
 end if;

 htp.nl;
 htp.nl;
 htp.bold( '# Images in UMO Table:' || c2rec.cnt );
 htp.nl;
 htp.nl;
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( c1rec.job );
   htp.tabledata( c1rec.what );
   if instr( c1rec.what,'MAIN') > 0
    then
     x := instr(c1rec.what,'p_rsess=>') + length('p_rsess=>') + 1;
     y := instr(c1rec.what,'''',x+1);
     -- glbx.dbg( 'X4:' || replace(substr(c1rec.what,x,(y-x)+1),'''','') );
     open c4(replace(substr(c1rec.what,x,(y-x)+1),'''',''));
     fetch c4 into c4rec;
     close c4;
     htp.tabledata( 'Number to load: ' || c4rec.cnt );
    else
     htp.tabledata( '&nbsp;' );
   end if;
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.anchor2( 'adm.dist?surl=' || glbx.rndsurl(surl) || '&vload_id=' || vload_id, 'Display Load Interval (10 Second Interval)', ctarget=>new_window );
 htp.nl;
 htp.anchor2( 'glbx.displog?surl=' || glbx.rndsurl(surl) || '&acid=' || c3rec.aid, LNG3.ADM_TXT_756, ctarget=>new_window );
 htp.formopen( 'adm.monitor_screen' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'VLOAD_ID', vload_id );
 htp.nl;
 htp.formcheckbox( 'TRM', 'T' );
 htp.bold( ' ' || 'Terminate Batch Job' );
 htp.nl;
 htp.nl;
 htp.formsubmit( null, 'Refresh' );
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'MONITOR_SCREEN', errmsg=>sqlerrm, extdet=>'VLOAD_ID=' || vload_id);
end monitor_screen;

procedure dist( surl in varchar2, vload_id in integer )
as

 cursor c1 is select min(time_start) mn, max(time_start) mx from load_log;
 cursor c2(ts date, tf date) is select count('x') cnt from load_log where time_start >= ts and time_start <= tf and succeeded = 'T';

 c1rec 	c1%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 ctr 	integer;
 tot	integer;
 tm	date;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'ADM.DIST');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 main_title( surl, sessid, 'Monitor Parallel Load Screen', style=>'NOMENU', helpid=>'A107' );
 open c1;
 fetch c1 into c1rec;
 close c1;
 tm := c1rec.mn;
 htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0' );
 loop
  tot := 0;
  open c2(tm, tm + ( 10 / (60*24*60) ));
  fetch c2 into tot;
  close c2;
  htp.tablerowopen;
   htp.tabledata( to_char(tot) );
   htp.tabledata( lpad( '*', tot, '*' ) );
  htp.tablerowclose;
  tm := tm + ( 10 / (60*24*60) );
  if tm > c1rec.mx then exit; end if;
 end loop;
 htp.tableclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ADM', 'DIST', errmsg=>sqlerrm, extdet=>'VLOAD_ID=' || vload_id);
end dist;

procedure virage_index( surl in varchar2, acid in integer )
as
 bl	boolean;
begin

 bl := virage.virage_index(surl, acid );

exception when others then
 glbx.error_details( 'ADM', 'VIRAGE_INDEX', acid, errmsg=>sqlerrm);
end virage_index;

procedure context_index(surl in varchar2, acid in integer )
as

 bl	boolean;

begin

 bl := virage.context_index(surl, acid );

exception when others then
 glbx.error_details( 'ADM', 'CONTEXT_INDEX',acid,errmsg=>sqlerrm);
end context_index;

procedure adobe_tnail(surl in varchar2, acid in integer )
as

 cursor c2(acid integer) is
  select um.umo_id
  from umo um
  where um.aid = acid and
        um.umo_type = 'DOCUMENT' and
        nvl(um.doc_length,0) > 0 and
        lower(trim(um.doc_mimetype)) = 'application/pdf' and
        dbms_lob.getlength( um.photo_thumbnail.source.localdata ) = 0;

 retval varchar2(4000);

begin

 for c2rec in c2( acid ) loop
  retval := ump.create_document_tnail( surl, c2rec.umo_id );
 end loop;

exception when others then
 glbx.error_details( 'ADM', 'ADOBE_TNAIL',acid,errmsg=>sqlerrm);
end adobe_tnail;

procedure create_directory_images(surl in varchar2, acid in integer )
as

 bl	boolean;

begin

 bl := ump.create_directory_images(surl, acid );

exception when others then
 glbx.error_details( 'ADM', 'CREATE_DIRECTORY_IMAGES',acid,errmsg=>sqlerrm);
end create_directory_images;

end adm;
/
