CREATE OR REPLACE package body WEBSYS.forum
as


global_ctr	integer;
v_exp		arrc;
v_expt		arrc;

procedure rec_frm( surl varchar2,fparent in varchar2, depth in number default 0, ordby in varchar2 default 'DATE' , sort_type in varchar2 default 'DESC', env_id in integer, fpriv in varchar2, acc in varchar2 default 'PHG' );
procedure rec_thread( surl varchar2,fparent in varchar2, depth in number default 0, rtype in varchar2 default 'F', ordby in varchar2 default 'DATE', sort_type in varchar2 default 'DESC', env_id in integer, acc in varchar2 default 'PHG');
procedure disp_entr( surl varchar2,p1 in varchar2, p2 in varchar2, p3 in number default null, env_id in integer, acc in varchar2 default 'PHG');
procedure nested_thread(surl varchar2,frm_id in number, ordby in varchar2, parent_id in number,sort_order in varchar2,env_id in integer, acc in varchar2 default 'PHG' );
procedure display_guestbook_style( surl varchar2,strt in integer default 1, sty in varchar2 default 'X', env_id in integer, acc in varchar2 default 'PHG' );
function array_match( surl varchar2,name_or_id in varchar2, v_type in varchar2 ) return boolean;
function can_drill( surl varchar2,fname in varchar2 ) return varchar2;
function can_drill_t( surl varchar2,fname in varchar2 ) return varchar2;
function forum_style(surl varchar2,acc in varchar2 default 'PHG') return varchar2;
function get_forum_priv( surl varchar2,owner_id integer, owner_type in varchar2 default 'PHOTOGRAPHER') return varchar2;

function forum_style (surl varchar2,acc in varchar2 default 'PHG')
 return varchar2
is
 cursor c1( phgid integer ) is select l_forum_style from photographer where pid = phgid;
 cursor c2( phgid integer ) is select l_forum_style from manufacturer where manufacturer_id = phgid;
 retval		varchar2(20);
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
begin
  if acc = 'PHG'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>FALSE );
   else
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>TRUE );
  end if;
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return( null );
  end if;
 if nvl(owner_id,0) > 0
  then
   if ltype = 'PHOTOGRAPHER'
    then
     open c1( owner_id );
     fetch c1 into retval;
     close c1;
    else
     open c2( owner_id );
     fetch c2 into retval;
     close c2;
   end if;
   return( nvl(retval,LNG2.FRM_TXT_001) );
  else
   return( LNG2.FRM_TXT_001 );
 end if;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'FORUM_STYLE',errmsg=>sqlerrm );
   return( 'FORUM' );
end forum_style;

procedure display_forum(surl varchar2,sty in varchar2 default null, acc in varchar2 default 'PHG')
as
 fmstyle	varchar2(30);
begin
htp.htmlopen;
 fmstyle := forum_style(surl, acc);
 if fmstyle = LNG2.FRM_TXT_002
  then
	 htp.print('  <FRAMESET COLS="20%,80%" FRAMEBORDER=NO FRAMESPACING=0>');
	 htp.print('   <FRAME SRC="forum.display_drill?surl=' || glbx.rndsurl(surl) || '&env_id=' || 1 || '&acc=' || acc || '" NAME="CHAT_CHOICE">');
	 htp.print('   <FRAME SRC="forum.initial_msg?surl=' || glbx.rndsurl(surl) || '&acc=' || acc || '" NAME="CHAT_MAIN">');
	 htp.print('  </FRAMESET>');
	 htp.print('  <NOFRAMES>');
          glbx.noframe(surl,'FORUM.DISPLAY_FORUM');
	 htp.print('  </NOFRAMES>');
 elsif fmstyle = LNG2.FRM_TXT_003
  then
	 htp.print('  <FRAMESET COLS="20%,80%" FRAMEBORDER=NO FRAMESPACING=0>');
	 htp.print('   <FRAME SRC="forum.display_drill?surl=' || glbx.rndsurl(surl) || '&env_id=' || 1 || '&acc=' || acc || '" NAME="CHAT_CHOICE">');
	 htp.print('   <FRAME SRC="forum.initial_msg?surl=' || glbx.rndsurl(surl) || '&acc=' || acc || '" NAME="CHAT_MAIN">');
	 htp.print('  </FRAMESET>');
	 htp.print('  <NOFRAMES>');
          glbx.noframe(surl,'FORUM.DISPLAY_FORUM');
	 htp.print('  </NOFRAMES>');
 elsif fmstyle = LNG2.FRM_TXT_004
  then
	 htp.print('  <FRAMESET COLS="40%,60%" FRAMESPACING=0>');
	 htp.print('  <FRAMESET ROWS="30%,60%,10%">');
	 htp.print('   <FRAME SRC="forum.display_drill?surl=' || glbx.rndsurl(surl) || '&env_id=' || 1 || '&acc=' || acc || '" NAME="CHAT_CHOICE">');
	 htp.print('   <FRAME SRC="forum.display_thread?surl=' || glbx.rndsurl(surl) || '&id=&env_id='|| 1 || '&acc=' || acc || '" NAME="CHAT_THREAD">');
	 htp.print('   <FRAME SRC="forum.graphic_sort?surl=' || glbx.rndsurl(surl) || '&type=MSG&env_id='|| 1 || '&acc=' || acc || '" NAME="CHAT_BOTTOM">');
	 htp.print('  </FRAMESET>');
	 htp.print('   <FRAME SRC="forum.initial_msg?surl=' || glbx.rndsurl(surl) || '&acc=' || acc || '" NAME="CHAT_MAIN">');
	 htp.print('  </FRAMESET>');
	 htp.print('  <NOFRAMES>');
          glbx.noframe(surl,'FORUM.DISPLAY_FORUM');
	 htp.print('  </NOFRAMES>');
 elsif fmstyle = LNG2.FRM_TXT_001
  then
	 htp.print('  <FRAMESET COLS="40%,60%" FRAMEBORDER=YES FRAMESPACING=1>');
	 htp.print('  <FRAMESET ROWS="88%,12%">');
	 htp.print('   <FRAME SRC="forum.display_hierarchy?surl=' || glbx.rndsurl(surl) || '&env_id=' || 1 || '&acc=' || acc || '" NAME="CHAT_CHOICE" SCROLLING=YES>');
	 htp.print('   <FRAME SRC="forum.graphic_sort?surl=' || glbx.rndsurl(surl) || '&env_id='|| 1 || '&acc=' || acc || '" NAME="CHAT_BOTTOM">');
	 htp.print('  </FRAMESET>');
	 htp.print('   <FRAME SRC="forum.initial_msg?surl=' || glbx.rndsurl(surl) || '&acc=' || acc || '" NAME="CHAT_TOP">');
	 htp.print('  </FRAMESET>');
	 htp.print('  <NOFRAMES>');
          glbx.noframe(surl,'FORUM.DISPLAY_FORUM');
	 htp.print('  </NOFRAMES>');
 elsif fmstyle = LNG2.FRM_TXT_049
  then
     display_guestbook_style( surl=>surl,env_id=>1, acc=>acc );
 end if;
htp.htmlclose;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'DISPLAY_FORUM',errmsg=>sqlerrm);
end display_forum;

procedure display_frm( surl varchar2,id in number, env_id in integer, acc in varchar2 default 'PHG' )
as
 fmstyle	varchar2(30);
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
begin
  if acc = 'PHG'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>FALSE );
   else
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>TRUE );
  end if;
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
 fmstyle := forum_style(surl, acc);
 if fmstyle = LNG2.FRM_TXT_002
  then
     	 htp.htmlopen;
	 htp.print('  <FRAMESET ROWS="44%,44%,12%">');
	 htp.print('   <FRAME SRC="forum.msg?surl=' || glbx.rndsurl(surl) || '&id=' || id || '&acc=' || acc ||'" NAME="CHAT_TOP">');
	 htp.print('   <FRAME SRC="forum.display_thread?surl=' || glbx.rndsurl(surl) || '&id=' || id || '&env_id=' || env_id || '&acc=' || acc || '" NAME="CHAT_THREAD">');
	 htp.print('   <FRAME SRC="forum.bottom_frame?surl=' || glbx.rndsurl(surl) || '&id=' || id || '&env_id=' || env_id || '&acc=' || acc ||'" NAME="CHAT_BOTTOM">');
	 htp.print('  </FRAMESET>');
	 htp.print('  <NOFRAMES>');
          glbx.noframe(surl,'FORUM.DISPLAY_FRM');
	 htp.print('  </NOFRAMES>');
 elsif fmstyle = LNG2.FRM_TXT_003
  then
     	 htp.htmlopen;
	 htp.print('  <FRAMESET ROWS="44%,44%,12%">');
	 htp.print('   <FRAME SRC="forum.display_thread?surl=' || glbx.rndsurl(surl) || '&id=' || id || '&env_id=' || env_id || '&acc=' || acc ||'" NAME="CHAT_THREAD">');
	 htp.print('   <FRAME SRC="forum.msg?surl=' || glbx.rndsurl(surl) || '&id=' || id || '&acc=' || acc ||'" NAME="CHAT_TOP">');
	 htp.print('   <FRAME SRC="forum.bottom_frame?surl=' || glbx.rndsurl(surl) || '&id=' || id || '&env_id=' || env_id || '&acc=' || acc || '" NAME="CHAT_BOTTOM">');
	 htp.print('  </FRAMESET>');
	 htp.print('  <NOFRAMES>');
          glbx.noframe(surl,'FORUM.DISPLAY_FRM');
	 htp.print('  </NOFRAMES>');
 elsif fmstyle = LNG2.FRM_TXT_004
  then
     	 htp.htmlopen;
	 htp.print('  <FRAMESET ROWS="44%,44%,12%">');
	 htp.print('   <FRAME SRC="forum.display_thread?surl=' || glbx.rndsurl(surl) || '&id=' || id || '&env_id=' || env_id || '&acc=' || acc ||  '" NAME="CHAT_THREAD">');
	 htp.print('   <FRAME SRC="forum.msg?surl=' || glbx.rndsurl(surl) || '&id=' || id || '&acc=' || acc ||'" NAME="CHAT_TOP">');
	 htp.print('   <FRAME SRC="forum.bottom_frame?surl=' || glbx.rndsurl(surl) || '&id=' || id || '&env_id=' || env_id || '&acc=' || acc ||  '" NAME="CHAT_BOTTOM">');
	 htp.print('  </FRAMESET>');
	 htp.print('  <NOFRAMES>');
          glbx.noframe(surl,'FORUM.DISPLAY_FRM');
	 htp.print('  </NOFRAMES>');
 end if;
htp.htmlclose;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'DISPLAY_FRM',errmsg=>sqlerrm );
end display_frm;

procedure msg(surl varchar2,id in number, acc in varchar2 default 'PHG')
as
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
begin
  if acc = 'PHG'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>FALSE );
   else
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>TRUE );
  end if;
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
 htp.htmlclose;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'MSG',errmsg=>sqlerrm );
end msg;

procedure initial_msg( surl varchar2,acc in varchar2 default 'PHG' )
as
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
begin
  if acc = 'PHG'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>FALSE );
   else
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>TRUE );
  end if;
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
    htp.tableopen;
	 htp.tablerowopen;
	  htp.tabledata( htf.bold(LNG2.FRM_TXT_005), cattributes=>'BGCOLOR="' || '#FFFFFF' || '"');
	 htp.tablerowclose;
	htp.tableclose;
 htp.htmlclose;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'INITIAL_MSG',errmsg=>sqlerrm );
end initial_msg;

procedure bottom_frame( surl varchar2,id in varchar2, sort_order in varchar2 default 'ASC', env_id in integer, acc in varchar2 default 'PHG' )
as
 tempvar		varchar2(2000);
 vsort_order		varchar2(10);
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
begin
  if acc = 'PHG'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>FALSE );
   else
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>TRUE );
  end if;
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

-- Toggle Sort Order
if sort_order = 'ASC'
 then
  vsort_order := 'DESC';
 else
  vsort_order := 'ASC';
end if;

htp.tableopen;
 htp.tablerowopen;
 if get_forum_priv(surl, owner_id,ltype) in ('READ WRITE','FULL CONTROL' )
  then
   tempvar := htf.formopen( 'forum.response',ctarget=>'CHAT_TOP' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ID', id ) || htf.formhidden( 'ENV_ID', env_id ) || htf.formhidden( 'ACC', acc ) || htf.formsubmit( null, LNG2.FRM_TXT_006 ) || htf.formclose;
   htp.tabledata( tempvar );
 end if;
 htp.tabledata( htf.formopen( 'forum.display_thread',ctarget=>'CHAT_THREAD' ) || htf.formhidden( 'SURL', surl ) || LNG2.FRM_TXT_007 || ' ' || htf.formhidden( 'ID', id ) || htf.formhidden( 'ENV_ID', env_id ) || htf.formhidden( 'ACC', acc ) || htf.formtext( 'SRC', 10,10) || htf.formclose, cattributes=>'VALIGN=TOP');
 tempvar := htf.formopen( 'forum.display_thread',ctarget=>'CHAT_THREAD' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ID', id ) || htf.formhidden( 'ENV_ID', env_id ) || htf.formhidden( 'ACC', acc ) || LNG2.FRM_TXT_008 || htf.formsubmit( 'ORDBY', LNG2.FRM_TXT_009 ) || htf.formhidden( 'SORT_ORDER', vsort_order ) || htf.formclose;
 htp.tabledata( tempvar );
 tempvar := htf.formopen( 'forum.display_thread',ctarget=>'CHAT_THREAD' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ID', id ) || htf.formhidden( 'ENV_ID', env_id ) || htf.formhidden( 'ACC', acc ) || htf.formsubmit( 'ORDBY', LNG2.FRM_TXT_010 ) || htf.formhidden( 'SORT_ORDER', vsort_order ) || htf.formclose;
 htp.tabledata( tempvar );
 htp.tablerowclose;
htp.tableclose;
htp.htmlclose;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'BOTTOM_FRAME',errmsg=>sqlerrm );
end bottom_frame;

procedure display_thread( surl varchar2,id in number default null, src in varchar2 default null,
   ordby in varchar2 default 'By Date', sort_order in varchar2 default 'ASC',msg in varchar2 default null, env_id in integer, acc in varchar2 default 'PHG' )
as

 retrow			THREAD_TEXT%ROWTYPE;
 fname			FORUM_GROUPS.FORUM_NAME%TYPE;
 ctr			integer;
 vsort_order	varchar2(10);
 tempvar		varchar2(2000);
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
begin
  if acc = 'PHG'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>FALSE );
   else
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>TRUE );
  end if;
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
if src is not null
 then
  display_search(id, src, ordby, sort_order, msg,env_id=>env_id,acc=>acc);  return;
end if;
ctr := 0;
-- Toggle Sort Order
if sort_order = 'ASC'
 then
  vsort_order := 'DESC';
 else
  vsort_order := 'ASC';
end if;

for crec in (select forum_name from forum_groups where forum_id = id ) loop
 htp.header(2, crec.forum_name, 'CENTER' );
end loop;
if msg is not null
 then
  glbx.header_msg( msg );
end if;
 if id is null
  then
  htp.p( htf.italic(LNG2.FRM_TXT_011 || ' : ') || htf.bold(src) );
 end if;

 global_ctr := 0;
 nested_thread(surl, id,ordby,'0',sort_order,env_id=>env_id,acc=>acc);
 if global_ctr = 0
  then
     htp.bold( LNG2.FRM_TXT_012 );
 end if;
htp.nl;
if msg = LNG2.FRM_TXT_013
 then
  htp.formopen( 'forum.DISPLAY_DRILL',ctarget=>'CHAT_CHOICE');
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ENV_ID', env_id );
  htp.formhidden( 'ACC', acc );
  htp.formsubmit( null, LNG2.FRM_TXT_014);
  htp.formclose;
end if;
htp.htmlclose;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'DISPLAY_THREAD',errmsg=>sqlerrm );
end display_thread;

procedure nested_thread(surl varchar2,frm_id in number, ordby in varchar2, parent_id in number,sort_order in varchar2, env_id in integer, acc in varchar2 default 'PHG' )
as
 cursor c1(ordby varchar2) is
  select *
   from thread_text
    where forum_id = frm_id and thread_parent = parent_id
	 order by decode(ordby,LNG2.FRM_TXT_009,to_char(date_created,'YYYYMMDDHH24MISS'),thread_user);

  cursor c2(ordby varchar2)  is
	select *
	  from thread_text
	   where forum_id = frm_id and thread_parent = parent_id
		order by decode(ordby,LNG2.FRM_TXT_009,to_char(date_created,'YYYYMMDDHH24MISS'),thread_user) desc;

 retrow		THREAD_TEXT%ROWTYPE;
 fname		FORUM_GROUPS.FORUM_NAME%TYPE;
 vsort_order	varchar2(10);

begin

 if sort_order = 'ASC' then open c1(ordby); else open c2(ordby); end if;
 htp.ulistopen;
 loop
   if sort_order = 'ASC'
	  then
	   fetch c1 into retrow;
	   if C1%NOTFOUND then exit; end if;
	  else
	   fetch c2 into retrow;
	   if C2%NOTFOUND then exit; end if;
    end if;
   global_ctr := global_ctr + 1;
   htp.listitem( htf.anchor2('forum.display_response?surl=' || glbx.rndsurl(surl) || '&id=' ||
                 retrow.thread_id || '&env_id=' || env_id || '&acc=' || acc, retrow.thread_subject,ctarget=>'CHAT_TOP') ||
                 htf.nl || LNG2.FRM_TXT_015 || ' : ' || htf.bold( retrow.thread_user ) ||
                 ' ' || LNG2.FRM_TXT_016 ||' ' || htf.italic( to_char(retrow.date_created,LNG.TSMASK)));
   nested_thread(surl, frm_id,ordby,retrow.thread_id,sort_order,env_id=>env_id,acc=>acc);
 end loop;
 htp.ulistclose;
  if sort_order = 'ASC' then close c1; else close c2; end if;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'NESTED_THREAD',errmsg=>sqlerrm );
end nested_thread;

procedure frm( surl varchar2,fname in varchar2, env_id in integer, acc in varchar2 default 'PHG' )
 is

 cursor c1( fp varchar2 ) is
 select forum_id, forum_name
  from forum_groups
   where forum_parent = fp;

 fmstyle	varchar2(30);

 begin
 htp.ulistopen;
  for crec in c1(fname) loop
   if fmstyle = LNG2.FRM_TXT_004
    then
      htp.listitem( htf.anchor2('forum.display_thread?surl=' || glbx.rndsurl(surl) || '&id=' || crec.forum_id || '&env_id=' || env_id || '&acc=' || acc, crec.forum_name, ctarget=>'CHAT_THREAD') );
	else
      htp.listitem( htf.anchor2('forum.display_frm?surl=' || glbx.rndsurl(surl) || '&id=' || crec.forum_id || '&env_id=' || env_id || '&acc=' || acc, crec.forum_name, ctarget=>'CHAT_MAIN') );
   end if;
   frm( crec.forum_name, env_id, acc );
  end loop;
 htp.ulistclose;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'FRM',errmsg=>sqlerrm );
end frm;

procedure Display_Drill(surl varchar2,env_id in integer, acc in varchar2 default 'PHG')
as
 cursor c1 is select forum_id, forum_name, forum_parent from forum_groups order by forum_id;
 ctr		integer;
 fmstyle	varchar2(30);
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
begin
  if acc = 'PHG'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>FALSE );
   else
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>TRUE );
  end if;
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
 fmstyle := forum_style(surl, acc);
 ctr := 0;
 htp.bold(htf.anchor2('forum.update_pref?surl=' || glbx.rndsurl(surl) || '&env_id=' || env_id || '&acc=' || acc,'FORUM',ctarget=>'CHAT_MAIN'));
 htp.nl;
 frm( LNG.PARENT_FRM, env_id, acc );

 if get_forum_priv(surl, owner_id,ltype) = 'FULL CONTROL'
  then
    htp.formopen( 'forum.response', ctarget=>'CHAT_MAIN' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
     htp.formhidden( 'ENV_ID', env_id );
     htp.formhidden( 'ACC', acc );
     htp.formsubmit( null, LNG2.FRM_TXT_017 );
    htp.formclose;
    htp.nl;
    htp.formopen( 'forum.delforum',ctarget=>'BOTTOM' );
     htp.formhidden( 'ACC', acc );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formselectopen( 'P1' );
    for c1rec in c1 loop
     htp.formselectoption( c1rec.forum_name || ' (' || c1rec.forum_parent || ')', cattributes=>'VALUE="' || c1rec.forum_id || '"' );
    end loop;
    htp.formselectclose;
    htp.nl;
    htp.formsubmit( null, LNG2.FRM_TXT_051 );
    htp.formclose;
 end if;

 htp.htmlclose;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'DISPLAY_DRILL',errmsg=>sqlerrm );
end display_drill;

procedure delforum( surl varchar2,p1 in varchar2, acc in varchar2 default 'PHG' )
as
 fmstyle	varchar2(30);
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
begin
  if acc = 'PHG'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>FALSE );
   else
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>TRUE );
  end if;
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
 fmstyle := forum_style(surl, acc);
 if get_forum_priv(surl, owner_id,ltype) = 'FULL CONTROL'
  then
   delete from thread_text where forum_id = to_number( p1 );
   delete from forum_groups where forum_id = to_number( p1 );
   commit;
 end if;
 display_forum(surl=>surl,acc=>acc);
exception
 when others
  then
   glbx.error_details( 'FORUM', 'DELFORUM',errmsg=>sqlerrm );
end delforum;

function get_forum_priv( surl varchar2,owner_id integer, owner_type in varchar2 default 'PHOTOGRAPHER')
 return varchar2
as
 cursor c1(owner_id integer) is select forum_priv from photographer where pid = owner_id;
 cursor c2(owner_id integer) is select forum_priv from manufacturer where manufacturer_id = owner_id;
 fpriv	varchar2(40);
begin
 if owner_type = 'PHOTOGRAPHER'
  then
   open c1(owner_id);
   fetch c1 into fpriv;
   close c1;
  else
   open c2(owner_id);
   fetch c2 into fpriv;
   close c2;
 end if;
 return( nvl(fpriv,'READ ONLY' ));
exception
 when others
  then
   glbx.error_details( 'FORUM', 'GET_FORUM_PRIV',errmsg=>sqlerrm );
end get_forum_priv;


procedure accept_group(surl varchar2,id in number default null, grp in varchar2 default null,
                       sb in varchar2 default null, pid in number default null,
                       th in varchar2 default null, tx in varchar2 default null,
		       env_id in integer, acc in varchar2 default 'PHG')
as

 cursor c1(phgid integer) is select business_name nme from photographer where pid = phgid;
 cursor c2(phgid integer) is select name nme from manufacturer where manufacturer_id = phgid;

 c1rec		c1%ROWTYPE;
 ctr		integer;
 vctr		integer;
 fname		FORUM_GROUPS.FORUM_NAME%TYPE;
 fprnt  	FORUM_GROUPS.FORUM_PARENT%TYPE;
 ftxt		varchar2(2000);
 vsb 		varchar2(50);
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
begin
  if acc = 'PHG'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>FALSE );
   else
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>TRUE );
  end if;
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  if ltype = 'PHOTOGRAPHER'
   then
    open c1(owner_id);
    fetch c1 into c1rec;
    close c1;
   else
    open c2(owner_id);
    fetch c2 into c1rec;
    close c2;
  end if;
 -- check if the user has membership
 --
  if id is null
  then
   -- Check to see if the Forum already exists
   select nvl(count('x'),0) into ctr from forum_groups where upper(th) = upper(forum_name) and environment_id = env_id;
   if ctr > 0 then disp_entr( surl, 'FN', th, env_id=>env_id, acc=>acc ); return; end if;
   -- Check to see if the Forum name is the same as a Forum Parent
   select nvl(count('x'),0) into ctr from forum_groups where upper(th) = (forum_parent) and environment_id = env_id;
   if ctr > 1 then disp_entr( surl, 'PA', th, env_id=>env_id, acc=>acc ); return; end if;
   -- Check to see if the censor OK's the forum name
   fname := th;
   fprnt := grp;
   select max(forum_id) + 1 into ctr from forum_groups;
   if ctr is null then ctr := 1; end if;
   insert into forum_groups( forum_id, forum_name, forum_parent, environment_id )
    values (ctr,fname,fprnt,env_id);
   if tx is null
     then
       commit;
       disp_entr( surl, 'NL', th, ctr, env_id=>env_id, acc=>acc ); return;
   end if;
  else
   select forum_name,forum_parent into fname,fprnt from forum_groups where forum_id = id;
   ctr := id;
 end if;
 if tx is null
  then
   disp_entr( surl, 'N2', th, ctr, env_id=>env_id, acc=>acc ); return;
 end if;
 ftxt := replace(substr(tx,1,1000),chr(13),htf.nl);
 ftxt := glbx.censor(ftxt);
 vsb := substr(sb,1,50);
 vsb := glbx.censor(vsb);
 if vsb is null then vsb := 'No Subject'; end if;
 select nvl(max(thread_id),0) + 1 into vctr from thread_text;


 if owner_id is not null
  then
    insert into thread_text(forum_id,thread_id,thread_user,date_created,thread_subject, thread_text, thread_parent) values
    (ctr,vctr,c1rec.nme,sysdate,vsb,ftxt,nvl(pid,0));
    commit;
  else
    disp_entr( surl, 'IU', th, ctr, env_id=>env_id, acc=>acc );
  return;
 end if;

 if forum_style(surl, acc) in ( LNG2.FRM_TXT_002, LNG2.FRM_TXT_003, LNG2.FRM_TXT_004, LNG2.FRM_TXT_001 )
  then
    if id is null
     then
       display_thread(surl, ctr,msg=>LNG2.FRM_TXT_013, env_id=>env_id, acc=>acc);
     else
       display_thread(surl, ctr,msg=>LNG2.FRM_TXT_018, env_id=>env_id, acc=>acc);
     end if;
  else
   display_guestbook_style(surl=>surl,env_id=>env_id, acc=>acc);
 end if;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'ACCEPT_GROUP',errmsg=>sqlerrm );
   disp_entr( surl, 'IN', th, env_id=>env_id, acc=>acc );
end accept_group;

procedure disp_entr( surl varchar2,p1 in varchar2, p2 in varchar2, p3 in number default null, env_id in integer, acc in varchar2 default 'PHG')
as
begin
 if    p1 = 'IN'
  then
   response(null, LNG2.FRM_TXT_019, null, env_id, acc );
 elsif p1 = 'FN'
  then
   response(null, LNG2.FRM_TXT_020, null, env_id, acc  );
 elsif p1 = 'PA'
  then
   response(null, LNG2.FRM_TXT_021, null, env_id, acc  );
 elsif p1 = 'IU'
  then
   response(null, LNG2.FRM_TXT_022, null, env_id, acc  );
 elsif p1 = 'CE'
  then
   response(null, LNG2.FRM_TXT_023, null, env_id, acc  );
 elsif p1 = 'NL'
  then
   response(p3, LNG2.FRM_TXT_024, null, env_id, acc  );
 elsif p1 = 'N2'
  then
   response(p3, LNG2.FRM_TXT_025, null, env_id, acc  );
 end if;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'DISP_ENTR',errmsg=>sqlerrm );
end disp_entr;

procedure response( surl varchar2,id in number default null, msg in varchar2 default null, pid in number default null, env_id in integer, action in varchar2 default null, ctype in varchar2 default 'REPLY', acc in varchar2 default 'PHG' )
as
 grp		varchar2(32767);
 def_sub	varchar2(50);
 tid		number;
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 fpriv		varchar2(40);
begin
  if acc = 'PHG'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>FALSE );
   else
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>TRUE );
  end if;

  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if msg is not null
   then
    glbx.header_msg( msg );
  end if;
  fpriv := get_forum_priv(surl, owner_id,ltype);
  if fpriv = 'FULL CONTROL' and action = LNG2.FRM_TXT_050
   then
    delete from thread_text where forum_id = id and thread_id = pid;
    commit;
    htp.htmlopen;
     htp.header( 2,LNG2.FRM_TXT_052,'CENTER');
    htp.htmlclose;
    return;
  end if;
  if forum_style(surl, acc) = LNG2.FRM_TXT_002
   then
    htp.formopen( 'forum.accept_group',ctarget=>'CHAT_THREAD' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  else
    htp.formopen( 'forum.accept_group' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  end if;
  htp.formhidden( 'ENV_ID', env_id );
  htp.formhidden( 'ACC', acc );
  if id is null and pid is null
   then
    grp := htf.formselectopen( 'GRP' );
    for crec in (select forum_name from forum_groups
                 union select LNG.PARENT_FRM from dual order by 1 ) loop
	 grp := grp || htf.formselectoption( crec.forum_name );
	end loop;
	grp := grp || htf.formselectclose;
	htp.tableopen;
	 htp.tablerowopen;
	  htp.tabledata( LNG2.FRM_TXT_026 || ' : ' );
	  htp.tabledata( grp );
	 htp.tablerowclose;
         htp.tablerowopen;
	  htp.tabledata( LNG2.FRM_TXT_027 || ' ' );
	  htp.tabledata( htf.formtext( 'TH', 30, 30 ) );
	 htp.tablerowclose;
	htp.tableclose;
   else
    if pid is not null -- Response to a posting
     then
      for c3rec in (select thread_subject from thread_text where thread_id = pid ) loop
       def_sub := c3rec.thread_subject;
      end loop;
    end if;
    htp.formhidden( 'ID', id );
    htp.formhidden( 'ENV_ID', env_id );
    htp.formhidden( 'ACC', acc );
    htp.formhidden( 'PID', pid );
    for crec in (select forum_name,forum_parent from forum_groups where forum_id = id ) loop
     htp.header(3, LNG2.FRM_TXT_053 || ' : ' || crec.forum_name, 'CENTER' );
    end loop;
  end if;
  if id is null
   then
    htp.formsubmit( null, LNG2.FRM_TXT_028 );
   else
    if ctype = 'REPLY'
     then
      htp.formsubmit( null, LNG2.FRM_TXT_029 );
     else
      htp.formsubmit( null, LNG2.FRM_TXT_033 );
    end if;
  end if;
  htp.nl;
  htp.nl;
  if def_sub is not null
   then
    def_sub := substr( LNG2.FRM_TXT_031 || ': ' || def_sub,1, 50 );
  end if;
  htp.print( LNG2.FRM_TXT_032 || ' ' || htf.formtext( 'SB', 30, 50, def_sub ));
  htp.nl; htp.nl;
  htp.formTextArea( 'TX', 10, 50, cattributes=>'WRAP="VIRTUAL"' );
  htp.nl;
  htp.nl;
  htp.print( LNG2.FRM_TXT_030 );
  htp.nl;
  if id is null
   then
    htp.formsubmit( null, LNG2.FRM_TXT_028 );
   else
    if ctype = 'REPLY'
     then
      htp.formsubmit( null, LNG2.FRM_TXT_029 );
     else
      htp.formsubmit( null, LNG2.FRM_TXT_033 );
    end if;
  end if;
  htp.formclose;
  htp.htmlclose;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'RESPONSE',errmsg=>sqlerrm );
end response;

procedure display_response( surl varchar2,id in number, msg in varchar2 default null, env_id in integer, acc in varchar2 default 'PHG' )
as
 grp		varchar2(32767);
 def_sub	varchar2(50);
 tmptxt		varchar2(2000);
 cursor c1 is select * from thread_text where thread_id = id;
 cursor c2 is select * from forum_groups where forum_id =
   (select forum_id from thread_text where thread_id = id );
 c1rec		C1%ROWTYPE;
 c2rec		C2%ROWTYPE;
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 fpriv		varchar2(40);
begin
  if acc = 'PHG'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>FALSE );
   else
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>TRUE );
  end if;
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
 fpriv := get_forum_priv(surl, owner_id,ltype);
 open c1;
 fetch c1 into c1rec;
 close c1;
 open c2;
 fetch c2 into c2rec;
 close c2;
 htp.bold( LNG2.FRM_TXT_032 || ' : ' || htf.italic(c1rec.thread_subject) );
 htp.nl;
 htp.print( LNG2.FRM_TXT_034 || ' : ' || htf.bold(c1rec.thread_user) || ' ' || LNG2.FRM_TXT_016 || ' ' || htf.italic(to_char(c1rec.date_created,LNG.TSMASK)));
 htp.nl;

 if fpriv in ('READ WRITE','FULL CONTROL')
  then
   htp.tableopen;
    htp.tablerowopen;
     tmptxt := htf.formopen( 'forum.response' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ID', c1rec.forum_id ) || htf.formhidden( 'ENV_ID', env_id ) || htf.formhidden( 'ACC', acc ) || htf.formsubmit( null, LNG2.FRM_TXT_033 ||  ':' || c2rec.forum_name ) || htf.formclose;
     htp.tabledata( tmptxt );
     tmptxt := htf.formopen( 'forum.response');
     tmptxt := tmptxt || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ID', c1rec.forum_id );
     tmptxt := tmptxt || htf.formhidden( 'PID', c1rec.thread_id );
     tmptxt := tmptxt || htf.formhidden( 'ENV_ID', env_id );
     tmptxt := tmptxt || htf.formhidden( 'ACC', acc );
     tmptxt := tmptxt || htf.formsubmit( 'ACTION', LNG2.FRM_TXT_035 );
     tmptxt := tmptxt || htf.formclose;
     htp.tabledata( tmptxt );
    htp.tablerowclose;
   htp.tableclose;
 end if;

 htp.line(cattributes=>'WIDTH=50%');
 htp.p( c1rec.thread_text );
 htp.line(cattributes=>'WIDTH=50%');
 htp.nl;
 if fpriv in ('READ WRITE','FULL CONTROL')
  then
   htp.formopen( 'forum.response');
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ID', c1rec.forum_id );
    htp.formhidden( 'PID', c1rec.thread_id );
    htp.formhidden( 'ENV_ID', env_id );
    htp.formhidden( 'ACC', acc );
    htp.formsubmit( 'ACTION', LNG2.FRM_TXT_035 );
    if fpriv = 'FULL CONTROL' then htp.formsubmit( 'ACTION', LNG2.FRM_TXT_050 ); end if;
   htp.formclose;
 end if;
 htp.htmlclose;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'DISPLAY_RESPONSE',errmsg=>sqlerrm );
end display_response;

procedure display_search( surl varchar2,id in number default null, src in varchar2 default null,
   ordby in varchar2 default 'By Date', sort_order in varchar2 default 'ASC',msg in varchar2 default null, env_id in integer, acc in varchar2 default 'PHG' )
as
 cursor c3(ordby varchar2)  is
  select *
   from thread_text
    where upper(thread_text) like '%' || upper(src) || '%' and
	 (id is null or id = forum_id )
	 order by decode(ordby,LNG2.FRM_TXT_009,to_char(date_created,'YYYYMMDDHH24MISS'),'USERNAME', upper(thread_user),upper(thread_subject));

 cursor c4(ordby varchar2)  is
  select *
   from thread_text
    where upper(thread_text) like '%' || upper(src) || '%' and
	 (id is null or id = forum_id )
	 order by decode(ordby,LNG2.FRM_TXT_009,to_char(date_created,'YYYYMMDDHH24MISS'),thread_user) desc;

 cursor c5(tid number) is
  select forum_name from forum_groups where forum_id = tid;

 retrow			THREAD_TEXT%ROWTYPE;
 fname			FORUM_GROUPS.FORUM_NAME%TYPE;
 ctr			integer;
 vsort_order	varchar2(10);
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
begin
  if acc = 'PHG'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>FALSE );
   else
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>TRUE );
  end if;
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
ctr := 0;
-- Toggle Sort Order
if sort_order = 'ASC'
 then
  vsort_order := 'DESC';
 else
  vsort_order := 'ASC';
end if;
if id is not null
 then
	for crec in (select forum_name from forum_groups where forum_id = id ) loop
	 htp.header(2, crec.forum_name, 'CENTER' );
	end loop;
end if;
if msg is not null
 then
  glbx.header_msg( msg );
end if;
htp.tableopen('BORDER=0');
 if id is null
 then
  htp.p( htf.italic(LNG2.FRM_TXT_011 || ' : ') || htf.bold(src) );
 end if;

   if (src is not null) and (id is null)
   then
    htp.tableopen( 'BORDER' );
   end if;
  if sort_order = 'ASC' then open c3(ordby); else open c4(ordby); end if;
  loop
    if sort_order = 'ASC'
	  then
	   fetch c3 into retrow;
	   if C3%NOTFOUND then exit; end if;
	  else
	   fetch c4 into retrow;
	   if C4%NOTFOUND then exit; end if;
    end if;
  ctr := ctr + 1;
      open c5(retrow.forum_id);
      fetch c5 into fname;
      close c5;
     htp.tablerowopen;
     htp.tabledata( LNG2.FRM_TXT_036 || ': ' || htf.italic(fname) || htf.nl ||
	  LNG2.FRM_TXT_015 || ' : ' || htf.bold( retrow.thread_user ) ||
      ' ' || LNG2.FRM_TXT_016 || ' ' || htf.italic( to_char(retrow.date_created,LNG.TSMASK)) || htf.nl ||
	  htf.anchor2('forum.display_response?surl=' || glbx.rndsurl(surl) || '&id=' || retrow.thread_id || '&env_id=' || env_id || '&acc=' || acc,retrow.thread_subject,ctarget=>'CHAT_TOP') );
     htp.tablerowclose;
end loop;
 if sort_order = 'ASC' then close c3; else close c4; end if;
 if ctr = 0
  then
     htp.bold( LNG2.FRM_TXT_037);
  end if;
 htp.tableclose;
 htp.nl;
htp.htmlclose;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'DISPLAY_SEARCH',errmsg=>sqlerrm );
end display_search;

procedure display_guestbook_style( surl varchar2,strt in integer default 1, sty in varchar2 default 'X', env_id in integer, acc in varchar2 default 'PHG' )
as
 grp		varchar2(32767);
 def_sub	varchar2(50);
 ctr		integer;
 tmptxt		varchar2(2000);

 cursor c1 is
  select fg.forum_name, tt.date_created, tt.thread_subject,
         tt.thread_id, tt.forum_id, tt.thread_user, tt.thread_text
   from thread_text tt,forum_groups fg
    where fg.forum_id = tt.forum_id
  order by date_created desc;

 cursor c2 is
  select fg.forum_name, tt.date_created, tt.thread_subject,
         tt.thread_id, tt.forum_id, tt.thread_user, tt.thread_text
   from thread_text tt,forum_groups fg
    where fg.forum_id = tt.forum_id and
	      date_created > (sysdate - 1)
  order by date_created desc;

 cursor c3 is
  select fg.forum_name, tt.date_created, tt.thread_subject,
         tt.thread_id, tt.forum_id, tt.thread_user, tt.thread_text
   from thread_text tt,forum_groups fg
    where fg.forum_id = tt.forum_id and
	      date_created > (sysdate - 7)
  order by date_created desc;

 cursor c4(un integer, cid integer) is
  select fg.forum_name, tt.date_created, tt.thread_subject,
         tt.thread_id, tt.forum_id, tt.thread_user, tt.thread_text
   from thread_text tt,forum_groups fg
    where fg.forum_id = tt.forum_id and
	      date_created > (select max(date_updated) from login_session where aid = un and sessid <> cid)
  order by date_created desc;

 cursor c5(acid integer) is
  select sessid from login_session where aid = acid and date_updated =
   (select max(date_updated) from login_session where aid = acid);

 c1rec		C1%ROWTYPE;
 cid		integer;
 infloop	integer;
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 fpriv		varchar2(40);
begin
  if acc = 'PHG'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>FALSE );
   else
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>TRUE );
  end if;
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  fpriv := get_forum_priv(surl, owner_id,ltype);
 htp.header( 3, htf.anchor('forum.update_pref?surl=' || glbx.rndsurl(surl) || '&env_id=' || env_id || '&acc=' || acc, LNG2.FRM_TXT_038), 'Center' );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG2.FRM_TXT_039 || ' : ') );
   htp.tabledata( htf.formopen( 'forum.display_forum' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'STY', 'X' ) || htf.formhidden( 'ACC', acc ) || htf.formsubmit(null, LNG2.FRM_TXT_040 ) || htf.formclose );
   htp.tabledata( htf.formopen( 'forum.display_forum' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'STY', 'Y' ) || htf.formhidden( 'ACC', acc ) || htf.formsubmit(null, LNG2.FRM_TXT_041 ) || htf.formclose );
   htp.tabledata( htf.formopen( 'forum.display_forum' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'STY', 'Z' ) || htf.formhidden( 'ACC', acc ) || htf.formsubmit(null, LNG2.FRM_TXT_042 ) || htf.formclose );
   htp.tabledata( htf.formopen( 'forum.display_forum' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACC', acc ) || htf.formsubmit(null, LNG2.FRM_TXT_043 ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;
 ctr := 1;
 if sty is null
  then
    open c1;
 elsif sty = 'X'
  then
    open c2;
 elsif sty = 'Y'
  then
    open c3;
 elsif sty = 'Z'
  then
    open c5(owner_id);
    fetch c5 into cid;
    close c5;
    open c4(owner_id,cid);
 end if;

 infloop := 1;
 loop
  infloop := infloop + 1;
  if infloop > 1000 then htp.bold( 'Hit an Infinite Loop...Exitting...' ); htp.nl; exit; end if;
  if sty = 'X'
   then
	fetch c2 into c1rec;
	if c2%NOTFOUND then close c2; exit; end if;
   elsif sty = 'Y'
   then
	fetch c3 into c1rec;
	if c3%NOTFOUND then close c3; exit; end if;
   elsif sty = 'Z'
   then
	fetch c4 into c1rec;
	if c4%NOTFOUND then close c4; exit; end if;
   else
	fetch c1 into c1rec;
	if c1%NOTFOUND then close c1; exit; end if;
  end if;

  if (( ctr - strt ) = 20) and (sty is null)
   then
    exit;
  elsif ( ctr >= strt and sty is null) or (sty is not null)
   then
	 htp.line(cattributes=>'WIDTH=50%');
	 htp.bold( LNG2.FRM_TXT_036 ||' : ' || htf.italic(c1rec.forum_name) );
	 htp.nl;
	 htp.bold( LNG2.FRM_TXT_032 || ' : ' || htf.italic(c1rec.thread_subject) );
	 htp.nl;
	 htp.print( LNG2.FRM_TXT_034 || ' : ' || htf.bold(c1rec.thread_user) || ' ' || LNG2.FRM_TXT_016 || ' ' || htf.italic(to_char(c1rec.date_created,LNG.TSMASK)));
	 htp.nl;
	 if fpriv in ('READ WRITE','FULL CONTROL')
	  then
	   htp.tableopen;
	    htp.tablerowopen;
	    tmptxt := htf.formopen( 'forum.response' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ID', c1rec.forum_id ) || htf.formhidden( 'ENV_ID', env_id ) || htf.formhidden( 'ACC', acc ) || htf.formsubmit( null, LNG2.FRM_TXT_033 || ' :' || c1rec.forum_name ) || htf.formclose;
            htp.tabledata( tmptxt );
	    tmptxt := htf.formopen( 'forum.response');
	    tmptxt := tmptxt || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ID', c1rec.forum_id );
	    tmptxt := tmptxt || htf.formhidden( 'PID', c1rec.thread_id );
	    tmptxt := tmptxt || htf.formhidden( 'ENV_ID', env_id );
	    tmptxt := tmptxt || htf.formhidden( 'ACC', acc );
	    tmptxt := tmptxt || htf.formsubmit( null, LNG2.FRM_TXT_035 );
	    tmptxt := tmptxt || htf.formclose;
            htp.tabledata( tmptxt );
           htp.tablerowclose;
	   htp.tableclose;
	 end if;
	 htp.p( c1rec.thread_text );
	 htp.nl;
  end if;
  ctr := ctr + 1;
 end loop;
 if sty is null
 then
  if (strt = 1 and (ctr - strt < 20))
  then
   null;
  elsif (strt = 1 )
  then
   htp.formopen( 'forum.scroll_guestbook' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ENV_ID', env_id );
    htp.formhidden( 'ACC', acc );
    htp.p( htf.formsubmit( 'SCRLL',LNG.SLD_TXT_087 || ' >>' ));
	htp.formhidden( 'STRT', to_char( strt + 20 ));
   htp.formclose;
 elsif (ctr - strt ) < 20
  then
   htp.formopen( 'forum.scroll_guestbook' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ENV_ID', env_id );
    htp.formhidden( 'ACC', acc );
    htp.p( htf.formsubmit( 'SCRLL','<< ' || LNG.SLD_TXT_088 ));
	htp.formhidden( 'STRT', to_char( strt - 20 ));
   htp.formclose;
 else
   htp.tableopen;
    htp.tablerowopen;
	tmptxt := htf.formopen( 'forum.scroll_guestbook' );
    tmptxt := tmptxt || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'STRT', to_char( strt - 20 ));
	tmptxt := tmptxt || htf.formhidden( 'ENV_ID',env_id );
	tmptxt := tmptxt || htf.formhidden( 'ACC',acc );
	tmptxt := tmptxt || htf.formsubmit( 'SCRLL','<< ' || LNG.SLD_TXT_088  );
	tmptxt := tmptxt || htf.formclose;
    htp.tabledata( tmptxt );
	tmptxt := htf.formopen( 'forum.scroll_guestbook' );
    tmptxt := tmptxt || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'STRT', to_char( strt + 20 ));
	tmptxt := tmptxt || htf.formhidden( 'ENV_ID',env_id );
	tmptxt := tmptxt || htf.formhidden( 'ACC',acc );
	tmptxt := tmptxt || htf.formsubmit( 'SCRLL',LNG.SLD_TXT_087 || ' >>' );
	tmptxt := tmptxt || htf.formclose;
    htp.tabledata( tmptxt );
    htp.tablerowclose;
   htp.tableclose;
 end if;
 else
   htp.line(cattributes=>'WIDTH=50%');
   htp.bold( '[End Listing]'); htp.nl;
 end if;
 htp.htmlclose;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'DISPLAY_GUESTBOOK_STYLE',errmsg=>sqlerrm );
end display_guestbook_style;

procedure scroll_guestbook( surl varchar2,strt in integer default 1, scrll in varchar2, env_id in integer, acc in varchar2 default 'PHG' )
as
begin
 display_guestbook_style( surl,strt, env_id=>env_id, acc=>acc );
exception
 when others
  then
   glbx.error_details( 'FORUM', 'SCROLL_GUESTBOOK',errmsg=>sqlerrm );
end scroll_guestbook;

procedure display_hierarchy(surl varchar2,ordby in varchar2 default 'DATE', sort_type in varchar2 default 'DESC', env_id in integer, acc in varchar2 default 'PHG' )
as
begin
 disp_hier(surl,v_exp, ordby => ordby, sort_type=> sort_type, env_id=>env_id, acc=>acc );
exception
 when others
  then
   glbx.error_details( 'FORUM', 'DISPLAY_HIERARCHY',errmsg=>sqlerrm );
end display_hierarchy;

function can_drill( surl varchar2,fname in varchar2 )
 return varchar2
as
 cursor c1 is select nvl(count('x'),0) from forum_groups where forum_parent = fname;
 cursor c2 is select nvl(count('x'),0)
 	      from thread_text
	      where thread_parent = 0 and
	            forum_id = (select forum_id from forum_groups where forum_name = fname );
 temp	integer;
 temp2	integer;
begin
 open c1;
 fetch c1 into temp;
 close c1;
  open c2;
 fetch c2 into temp2;
 close c2;
 if temp = 0 and temp2 = 0 then return( 'NO_DRILL' ); end if;
 if temp > 0 and temp2 = 0 then return( 'DRILL_FORUM' ); end if;
 if temp = 0 and temp2 > 0 then return( 'DRILL_THREAD' ); end if;
 return( 'DRILL_FORUM_THREAD' );
exception
 when others
  then
   glbx.error_details( 'FORUM', 'CAN_DRILL',errmsg=>sqlerrm );
   return( null );
end can_drill;

function can_drill_t( surl varchar2,fname in varchar2 )
 return varchar2
as
  cursor c1 is select nvl(count('x'),0)
 				from thread_text
				where thread_parent = fname;
 temp	integer;
begin
 open c1;
 fetch c1 into temp;
 close c1;
 if temp > 0 then return( 'DRILL_THREAD' ); end if;
 return( 'NO_DRILL' );
exception
 when others
  then
   glbx.error_details( 'FORUM', 'CAN_DRILL_T',errmsg=>sqlerrm );
   return( null );
end can_drill_t;

function array_match( surl varchar2,name_or_id in varchar2, v_type in varchar2 )
 return boolean
as
begin
for i in nvl(v_exp.first,1)..nvl(v_exp.last,0) loop
  if v_exp(i) = name_or_id
   then
    return( TRUE );
  end if;
 end loop;
 return( FALSE );
 exception
  when others then return( FALSE );
end array_match;

procedure rec_thread( surl varchar2,fparent in varchar2, depth in number default 0, rtype in varchar2 default 'F', ordby in varchar2 default 'DATE', sort_type in varchar2 default 'DESC', env_id in integer, acc in varchar2 default 'PHG')
as
  cursor c1( fp varchar2 ) is select *
               from thread_text
			   where thread_parent = 0 and
			   forum_id = (select forum_id from forum_groups where forum_name = fparent)
			   order by decode( ordby, 'DATE',to_char(date_created,'YYYYMMDDHH24MISS') ,'USERNAME',upper(thread_user),upper(thread_subject));
  cursor c2( fp varchar2 ) is select *
               from thread_text
			   where thread_parent = fp
			   order by decode( ordby, 'DATE',to_char(date_created,'YYYYMMDDHH24MISS') ,'USERNAME',upper(thread_user),upper(thread_subject));
  cursor c3( fp varchar2 ) is select *
               from thread_text
			   where thread_parent = 0 and
			   forum_id = (select forum_id from forum_groups where forum_name = fparent)
			   order by decode( ordby, 'DATE',to_char(date_created,'YYYYMMDDHH24MISS') ,'USERNAME',upper(thread_user),upper(thread_subject)) desc;
  cursor c4( fp varchar2 ) is select *
               from thread_text
			   where thread_parent = fp
			   order by decode( ordby, 'DATE',to_char(date_created,'YYYYMMDDHH24MISS') ,'USERNAME',upper(thread_user),upper(thread_subject)) desc;

  txt			varchar2(1000);
  anchr			varchar2(32767);
  anchr2		varchar2(1000);
  anchr3		varchar2(1000);
  is_exp		boolean;
  drill_type	varchar2(30);
  crec			THREAD_TEXT%ROWTYPE;
begin
 if    rtype = 'F' and sort_type = 'ASC' then
  open c1( fparent);
 elsif rtype = 'F' and sort_type = 'DESC' then
  open c3( fparent);
 elsif rtype <> 'F' and sort_type = 'ASC' then
  open c2( fparent);
 else
  open c4( fparent);
 end if;
 loop
  if    rtype = 'F' and sort_type = 'ASC' then
    fetch c1 into crec;
	if c1%NOTFOUND then close c1; exit; end if;
   elsif rtype = 'F' and sort_type = 'DESC' then
    fetch c3 into crec;
	if c3%NOTFOUND then close c3; exit; end if;
   elsif rtype <> 'F' and sort_type = 'ASC' then
    fetch c2 into crec;
	if c2%NOTFOUND then close c2; exit; end if;
   else
    fetch c4 into crec;
	if c4%NOTFOUND then close c4; exit; end if;
   end if;

  is_exp := array_match( surl, crec.thread_id, 'T' );
  anchr3 := '<img src=' || DECS.IMAGE_LOCATION || 'admin_space_1.gif border=0 hspace=' ||
     to_char(depth * 6 - 2 ) || ' alt="">';
  anchr := null;
  txt := null;
  drill_type := can_drill_t( surl, crec.thread_id );
  if is_exp
   then
    anchr := anchr || '&ID=' || 'T' || crec.thread_id ||
	       '&TID=MINUS' ||
	       '&DRILL_DOWN=';
    anchr2 := DECS.IMAGE_LOCATION || 'adminc_minus.gif';
  elsif drill_type = 'DRILL_THREAD'
   then
    anchr := anchr || '&ID=' || 'T' || crec.thread_id ||
	       '&TID=PLUS' ||
	       '&DRILL_DOWN=';
    anchr2 := DECS.IMAGE_LOCATION || 'adminc_plus.gif';
   else
    anchr2 := DECS.IMAGE_LOCATION || 'admin_square.gif';
  end if;
  txt := txt || ' ' || htf.italic(htf.anchor2('forum.display_response?surl=' || glbx.rndsurl(surl) || '&id=' ||
         crec.thread_id || '&env_id=' || env_id || '&acc=' || acc,crec.thread_subject,ctarget=>'CHAT_TOP'));
/*  txt := txt || htf.anchor2( 'forum.response?id=' || crec.forum_id ||
        '&pid=' || crec.thread_id,
         htf.img( DECS.IMAGE_LOCATION || 'reply.gif' ),ctarget=>'CHAT_TOP'); */
  txt := txt || htf.italic( to_char( crec.date_created,LNG.TSMASK)) ||
         ' ' || htf.bold( crec.thread_user);
  if v_exp.first is not null
   then
      begin
	for i in v_exp.first..v_exp.last loop
	 anchr := anchr || '&EXP=' || v_expt(i) || translate(v_exp(i),' ','+');
	end loop;
	exception
	 when others then
	 anchr := anchr || '&EXP=';
      end;
     else
      anchr := anchr || '&EXP=';
  end if;
  anchr := 'FORUM.DISP_HIER' || '?surl=' || glbx.rndsurl(surl) || '&ORDBY=' || ordby || '&ENV_ID=' || env_id ||'&acc=' || acc || '&SORT_TYPE=' || sort_type || anchr || '#' || crec.thread_id;
  htp.p( '<A NAME="' || crec.thread_id || '"></A>');
  htp.p('<FONT SIZE=1 face="TIMES NEW ROMAN">' || anchr3 || htf.anchor(anchr,htf.img(anchr2)) || txt || '</FONT>'); htp.nl;
  htp.formclose;
  if is_exp
   then
    rec_thread( surl, crec.thread_id, depth + 1, 'T', ordby, sort_type, env_id=>env_id, acc=>acc );
  end if;
 end loop;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'REC_THREAD',errmsg=>sqlerrm );
end rec_thread;

procedure rec_frm( surl varchar2,fparent in varchar2, depth in number default 0, ordby in varchar2 default 'DATE', sort_type in varchar2 default 'DESC', env_id in integer, fpriv in varchar2, acc in varchar2 default 'PHG')
as
  cursor c1( fp varchar2 ) is
   select forum_id, forum_name
   from forum_groups
   where forum_parent = fp
   order by forum_name;

  txt		varchar2(1000);
  is_exp	boolean;
  drill_type	varchar2(30);

begin
 for crec in c1( fparent) loop
  is_exp := array_match( surl, crec.forum_name, 'F' );
  txt := '<img src=' || DECS.IMAGE_LOCATION || 'admin_space_1.gif border=0 hspace=' || to_char(depth * 6 ) || ' alt="">';
  drill_type := can_drill( surl, crec.forum_name );
  if is_exp
   then
    txt := txt || htf.formhidden( 'ID', 'F' || crec.forum_name ) || htf.formhidden( 'TID', 'MINUS' ) || htf.formimage( 'DRILL_DOWN', DECS.IMAGE_LOCATION || 'adminc_minus.gif' );
  elsif drill_type in ( 'DRILL_FORUM','DRILL_THREAD', 'DRILL_FORUM_THREAD')
   then
    txt := txt || htf.formhidden( 'ID', 'F' || crec.forum_name ) || htf.formhidden( 'TID', 'PLUS' ) || htf.formimage( 'DRILL_DOWN', DECS.IMAGE_LOCATION || 'adminc_plus.gif' );
   else
    txt := txt || htf.img( DECS.IMAGE_LOCATION || 'admin_square.gif',cattributes=>'border=0',calt=>LNG2.FRM_TXT_044 );
  end if;
  txt := txt || ' ' || '<FONT SIZE=3 face=arial>' || crec.forum_name || '</FONT> ';
  if fpriv in ('READ WRITE','FULL CONTROL')
   then
    txt := txt || htf.anchor2( 'forum.response?surl=' || glbx.rndsurl(surl) || '&id=' || crec.forum_id || '&env_id=' || env_id || '&acc=' || acc || '&ctype=POST', htf.img( DECS.IMAGE_LOCATION || 'admin_post.gif',cattributes=>'border=0',calt=>LNG2.FRM_TXT_045 ),ctarget=>'CHAT_TOP');
  end if;
  htp.formopen( 'FORUM.DISP_HIER' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ENV_ID', env_id );
  htp.formhidden( 'ACC', acc );
  htp.formhidden( 'ORDBY', ordby );
  htp.formhidden( 'SORT_TYPE', sort_type );
  if v_exp.first is not null
  then
   begin
    for i in v_exp.first..v_exp.last loop
     htp.formhidden( 'EXP', v_expt(i) || v_exp(i));
    end loop;
    exception
    when others then
     htp.formhidden( 'EXP', null);
    end;
  else
    htp.formhidden( 'EXP', null);
  end if;
  htp.p(txt);
  htp.formclose;
  if is_exp
   then
    if drill_type in ( 'DRILL_THREAD', 'DRILL_FORUM_THREAD' )
     then
       rec_thread( surl, crec.forum_name, depth + 1, ordby=>ordby, sort_type=>sort_type, env_id=>env_id, acc=>acc );
    end if;
    if drill_type in ( 'DRILL_FORUM', 'DRILL_FORUM_THREAD' )
     then
      rec_frm( surl, crec.forum_name, depth + 1, ordby=>ordby, sort_type=>sort_type, env_id=>env_id, fpriv=>fpriv, acc=>acc );
    end if;
  end if;
 end loop;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'REC_FRM',errmsg=>sqlerrm );
end rec_frm;

procedure disp_hier( surl varchar2,exp in arrc, drill_down in varchar2 default null,
                     id in varchar2 default null, tid in varchar2 default null,
		     ordby in varchar2 default 'DATE',
		     sort_type in varchar2 default 'DESC', env_id in integer, acc in varchar2 default 'PHG')
as
 cursor c1 is select forum_id, forum_name, forum_parent from forum_groups order by forum_id;
 ctr		integer;
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 fpriv		varchar2(40);
begin
  if acc = 'PHG'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>FALSE );
   else
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>TRUE );
  end if;
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
 fpriv := get_forum_priv(surl, owner_id,ltype);
 ctr := 0;
 for i in nvl(exp.first,1)..nvl(exp.last,0) loop
  if not(tid = 'MINUS' and translate(exp(i),'+',' ') = id )
   then
    if (exp(i) is not null)
     then
	ctr := ctr + 1;
	v_exp(ctr)  := substr(translate(exp(i),'+',' '),2);
	v_expt(ctr) := substr(translate(exp(i),'+',' '),1,1);
     end if;
  end if;
 end loop;
 if (tid = 'PLUS')
  then
   ctr := ctr + 1;
   v_exp(ctr)  := substr(id,2);
   v_expt(ctr) := substr(id,1,1);
 end if;
 htp.bold(htf.anchor2('forum.update_pref?surl=' || glbx.rndsurl(surl) || '&env_id=' || env_id || '&acc=' || acc,'FORUM',ctarget=>'CHAT_TOP'));
 htp.nl;
 rec_frm( surl, LNG.PARENT_FRM, ordby=>ordby, sort_type=>sort_type, env_id=>env_id, fpriv=>fpriv, acc=>acc );

if fpriv = 'FULL CONTROL'
 then
   htp.formopen( 'forum.response', ctarget=>'CHAT_TOP' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ENV_ID', env_id );
   htp.formhidden( 'ACC', acc );
   htp.formsubmit( null, LNG2.FRM_TXT_017 );
   htp.formclose;
    htp.nl;
    htp.formopen( 'forum.delforum',ctarget=>'BOTTOM' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
     htp.formhidden( 'ACC', acc );
    htp.formselectopen( 'P1' );
    for c1rec in c1 loop
     htp.formselectoption( c1rec.forum_name || ' (' || c1rec.forum_parent || ')', cattributes=>'VALUE="' || c1rec.forum_id  || '"' );
    end loop;
    htp.formselectclose;
    htp.nl;
    htp.formsubmit( null, LNG2.FRM_TXT_051 );
    htp.formclose;
end if;

 htp.htmlclose;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'DISP_HIER',errmsg=>sqlerrm );
end disp_hier;

PROCEDURE Update_Pref( surl varchar2,env_id in integer, acc in varchar2 default 'PHG' )
as

 cursor c1(phgid integer) is select l_forum_style from photographer where pid = phgid;
 cursor c1a(phgid integer) is select l_forum_style from manufacturer where manufacturer_id = phgid;
 cursor c2 is
   select LNG2.FRM_TXT_001 value,'T' is_default
   from dual
   union all
   select LNG2.FRM_TXT_003 value,'F'
   from dual
   union all
   select LNG2.FRM_TXT_004 value,'F'
   from dual
   union all
   select LNG2.FRM_TXT_002 value,'F'
   from dual
   union all
   select LNG2.FRM_TXT_049 value,'F'
   from dual;

 c1rec		c1%ROWTYPE;
 llist		varchar2(5000);
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
begin
  if acc = 'PHG'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>FALSE );
   else
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>TRUE );
  end if;
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
 if ltype = 'PHOTOGRAPHER'
  then
   open c1(owner_id);
   fetch c1 into c1rec;
   close c1;
  else
   open c1a(owner_id);
   fetch c1a into c1rec;
   close c1a;
 end if;
 glbx.main_title( surl, LNG2.FRM_TXT_046 );
 htp.formopen( 'FORUM.ACCEPT_UPDATE', ctarget=>'BOTTOM' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ENV_ID', env_id );
 htp.formhidden( 'ACC', acc );
     llist := htf.formselectopen( 'P1' );
     for c2rec in c2 loop
      if rtrim(c2rec.value) = c1rec.l_forum_style
  	 then
        llist := llist || htf.formselectoption( rtrim(c2rec.value), 'SELECTED' );
  	 else
        llist := llist || htf.formselectoption( rtrim(c2rec.value) );
  	end if;
     end loop;
     llist := llist || htf.formselectclose;
 htp.p( htf.italic( LNG2.FRM_TXT_047 || ' : ' ) || llist );
 htp.formsubmit( null, LNG.GLB_TXT_060 );
 htp.formclose;
 htp.htmlclose;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'UPDATE_PREF',errmsg=>sqlerrm );
end Update_Pref;

PROCEDURE Accept_Update( surl varchar2,env_id in integer, p1 in varchar2, acc in varchar2 default 'PHG' )
as

 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
begin
  if acc = 'PHG'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>FALSE );
   else
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>TRUE );
  end if;
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if ltype = 'PHOTOGRAPHER'
   then
    update photographer set l_forum_style = p1 where pid = owner_id;
   else
    update manufacturer set l_forum_style = p1 where manufacturer_id = owner_id;
  end if;
 commit;
 forum.display_forum(p1,acc=>acc);
exception
 when others
  then
   glbx.error_details( 'FORUM', 'ACCEPT_UPDATE',errmsg=>sqlerrm);
end Accept_Update;

procedure graphic_sort( surl varchar2,type in varchar2 default 'HIER', env_id in integer, acc in varchar2 default 'PHG' )
as
 tmptxt varchar2(2000);
 typtxt	varchar2(100);
 tgr	varchar2(100);
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
begin
  if acc = 'PHG'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>FALSE );
   else
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'FORUM.INITIAL_MSG', iscust=>TRUE );
  end if;
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
 if type = 'HIER'
  then
   typtxt := 'display_hierarchy';
   tgr := 'CHAT_CHOICE';
  else
   typtxt := 'display_thread';
   tgr := 'CHAT_THREAD';
 end if;
 htp.tableopen;
  htp.tablerowopen;
	tmptxt := '<IMG SRC="' || DECS.IMAGE_LOCATION || 'admin_sort.gif' || '" BORDER="0" ALIGN="TOP" usemap="#sort">';
	tmptxt := tmptxt || '<map name="sort">';
	tmptxt := tmptxt || '<area shape="rect" coords="1,1,23,40" href="forum.' || typtxt || '?surl=' || glbx.rndsurl(surl) || '&ordby=DATE&sort_type=ASC&env_id=' || env_id || '&acc=' || acc || '" target="' || tgr || '">';
	tmptxt := tmptxt || '<area shape="rect" coords="28,1,50,40" href="forum.' || typtxt || '?surl=' || glbx.rndsurl(surl) || '&ordby=DATE&sort_type=DESC&env_id=' || env_id || '&acc=' || acc ||  '" target="' || tgr || '">';
	tmptxt := tmptxt || '<area shape="rect" coords="57,1,80,40" href="forum.' || typtxt || '?surl=' || glbx.rndsurl(surl) || '&ordby=USERNAME&sort_type=ASC&env_id=' || env_id || '&acc=' || acc ||  '" target="' || tgr || '">';
	tmptxt := tmptxt || '<area shape="rect" coords="85,1,105,40" href="forum.' || typtxt || '?surl=' || glbx.rndsurl(surl) || '&ordby=USERNAME&sort_type=DESC&env_id=' || env_id || '&acc=' || acc ||  '" target="' || tgr || '">';
	tmptxt := tmptxt || '<area shape="rect" coords="114,1,133,40" href="forum.' || typtxt || '?surl=' || glbx.rndsurl(surl) || '&ordby=SUBJECT&sort_type=ASC&env_id=' || env_id || '&acc=' || acc ||  '" target="' || tgr || '">';
	tmptxt := tmptxt || '<area shape="rect" coords="139,1,161,40" href="forum.' || typtxt || '?surl=' || glbx.rndsurl(surl) || '&ordby=SUBJECT&sort_type=DESC&env_id=' || env_id || '&acc=' || acc ||  '" target="' || tgr || '">';
	tmptxt := tmptxt || '<area shape="default" nohref>';
	tmptxt := tmptxt || '</map>';
 if type = 'HIER'
 then
   htp.tabledata( tmptxt );
 else
   htp.tabledata ( '<FONT SIZE=1 face="TIMES NEW ROMAN">Sort not available</FONT>' );
 end if;
   htp.tabledata(htf.formopen( 'forum.display_search',ctarget=>'CHAT_TOP') || '<FONT SIZE=1 face="TIMES NEW ROMAN"> Search ' || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ENV_ID', env_id ) || htf.formhidden( 'ACC', acc ) ||
	         htf.formtext( 'SRC',5, 30 ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;
exception
 when others
  then
   glbx.error_details( 'FORUM', 'GRAPHIC_SORT',errmsg=>sqlerrm );
end graphic_sort;

end FORUM;

/
