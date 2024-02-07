CREATE OR REPLACE procedure WEBSYS.showdet_right(surl in varchar2, msg in varchar2 default null )
as

  cursor c1(id in number, tbl in varchar2) is
   select *
   from v$session
   where ( (id is null) or (id is not null and sid = id) )
   order by decode( upper(trim(substr(program,1,10))),'ORACLE.EXE',999,'HTTPD.EXE',10,20),action,program;

  cursor c2( vid raw ) is select * from v$sqlarea where address = vid;

  cursor c3( vid raw ) is select * from v$process where addr = vid;

  cursor c3a( vsid integer, vserial integer ) is
   select b.blocks * p.VALUE vtemp
   from v$session a , v$sort_usage b, v$process c , v$parameter p
   where p.NAME = 'db_block_size' and
         a.saddr = b.session_addr and
         a.paddr = c.addr and
         a.sid = vsid and
         a.serial# = vserial;

  cursor c4 is SELECT * FROM V$RESOURCE_LIMIT WHERE resource_name in ('sessions','processes','transactions');

  c2rec		c2%ROWTYPE;
  c3rec		c3%ROWTYPE;
  c3arec	c3a%ROWTYPE;
  sessid	integer;
  sts		varchar2(200);
  url		varchar2(1000);
 parm1        sys.owa.vc_arr;
 parm2        sys.owa.vc_arr;
 v            varchar2(1000);
 pid          integer;
 frec         boolean;
 v_thread     integer;
 role_to_verify varchar2(100);

begin
  glbx.adm_cookie_id(surl,sessid,sts,'ADMIN.SHOWDET_RIGHT');
  if sts is not null
   then
   htp.p('Error with sts');
   -- phg.all_purpose_error(surl, null, sts );
   return;
  end if;

  -- if tbl = 'RMAN' or id = 'RMAN'
  --  then
  --   adm.main_title( surl, dapi.GLOBAL_LOGIN_SESSION.sessid, 'Backup', helpid=>'PD01' );
  --  else
  --   adm.main_title( surl, dapi.GLOBAL_LOGIN_SESSION.sessid, 'Database Session', helpid=>'PD01' );
  -- end if;

 if msg is not null then htp.header(2,msg,'CENTER'); end if;

 htp.p('
 <style>
 table, th, td {
     border: 1px solid black;
 }
</style>');
 htp.nl;

 htp.tableopen( cattributes=>mn.tableopen_style);
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Resource Name' ), cattributes=>mn.header_style );
   htp.tabledata( htf.bold( 'Current' ), cattributes=>mn.header_style );
   htp.tabledata( htf.bold( 'Max' ), cattributes=>mn.header_style );
   htp.tabledata( htf.bold( 'Initial' ), cattributes=>mn.header_style );
   htp.tabledata( htf.bold( 'Limit Value' ), cattributes=>mn.header_style );
  htp.tablerowclose;
  for c4rec in c4 loop
   htp.tablerowopen;
     htp.tabledata( c4rec.resource_name );
     htp.tabledata( c4rec.current_utilization );
     htp.tabledata( c4rec.max_utilization );
     htp.tabledata( c4rec.initial_allocation );
     htp.tabledata( c4rec.limit_value );
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>mn.tableopen_style);
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>mn.header_style );
   htp.tabledata( htf.bold( 'Sid' ), cattributes=>mn.header_style );
   htp.tabledata( htf.bold( 'Serial#' ), cattributes=>mn.header_style );
   htp.tabledata( htf.bold( 'Username' ), cattributes=>mn.header_style );
   htp.tabledata( htf.bold( 'Database Program' ), cattributes=>mn.header_style );
   htp.tabledata( htf.bold( 'Extra Details' ), cattributes=>mn.header_style );
   htp.tabledata( htf.bold( 'Piction Program' ), cattributes=>mn.header_style );
   htp.tabledata( htf.bold( 'SQL Statement' ), cattributes=>mn.header_style );
   htp.tabledata( htf.bold( 'Session/Coll Aid' ), cattributes=>mn.header_style );
  htp.tablerowclose;
  for c1rec in c1(null, null) loop
  htp.tablerowopen( cattributes=>'valign="TOP"');
   if c1rec.username is null
    then
     htp.tabledata( null );
    else
     htp.tabledata( htf.anchor( 'admin.stop_session?surl=' || surl || '&s=' || c1rec.sid || '&y=' || c1rec.serial#, '[Kill]') );
   end if;
   htp.tabledata( c1rec.sid );
   htp.tabledata( c1rec.serial# );
   htp.tabledata( c1rec.username );
     htp.tabledata( c1rec.program || htf.nl || c1rec.module);
   c3rec := null;
   open c3(c1rec.paddr);
   fetch c3 into c3rec;
   close c3;
   open c3a(c1rec.sid,c1rec.serial#);
   fetch c3a into c3arec;
   close c3a;
   htp.tabledata( c1rec.action  );  --
   htp.tabledata( htf.anchor( 'admin.viewsess?surl=' || surl || '&sess=' || c1rec.module, c1rec.client_info ));
   htp.p( '<TD>' );
    c2rec.sql_fulltext := null;
    open c2( c1rec.sql_address );
    fetch c2 into c2rec;
    close c2;
    htp.p( c2rec.sql_fulltext );
    if trim(c2rec.sql_fulltext) is not null
     then
      htp.nl;
      url := 'javascript: window.open(''' || 'admin.sql_extra?surl=' || surl || '&s=' || c1rec.sid || '&y=' || c1rec.serial# || '&x=PLAN' || ''',''' || 'PLAN' || ''',''height=800,width=1200,scrollbars=yes,resizable=yes'');void('''');';
      htp.anchor( url, '[SQL Plan]');
      url := 'javascript: window.open(''' ||  'admin.sql_extra?surl=' || surl || '&s=' || c1rec.sid || '&y=' || c1rec.serial# || '&x=BIND' || ''',''' || 'BIND' || ''',''height=800,width=1200,scrollbars=yes,resizable=yes'');void('''');';
      htp.anchor( url, '[Bind Values]');
    end if;
   htp.p( '</TD>' );
     htp.tabledata( c1rec.action);
  htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.anchor( 'admin.locking?surl=' || surl || '&msg=1', '[View Locked Only]' );
  htp.nl;
 htp.htmlclose;
 -- select * from v$sql_bind_capture where address = (select sql_address from v$session where sid = 142 and serial#=2513)
 -- v$sql_plan
exception when others then
 htp.p('Error: ' || sqlerrm);
end showdet_right;
/
