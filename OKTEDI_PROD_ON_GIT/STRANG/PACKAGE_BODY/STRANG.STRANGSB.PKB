CREATE OR REPLACE package body STRANG.strangsb
as

function customer_state(acid in integer) return varchar2;
function control_code( cd in varchar2, vste in varchar2 ) return varchar2;
function confirm_delete( v_action in varchar2 default 'ACTION', btn in varchar2 default 'Delete', msg in varchar2 default 'Are you sure you want to delete?', script_only in boolean default FALSE ) return varchar2;
function lov_code(lov_name in varchar2, lov_code in varchar2, ret_col in varchar2 default 'DESCRIPTION', xtr_a in varchar2 default null, xtr_b in varchar2 default null) return varchar2;
procedure search( surl in varchar2, msearch in varchar2, curr_rowid in varchar2, samerow in boolean DEFAULT FALSE, buttons_only in boolean DEFAULT FALSE, override_top in varchar2 default null, search_only in boolean DEFAULT FALSE, button_text in varchar2 default NULL, lmnu in rowid default null, split_row in boolean default FALSE );
procedure lov_list( lname in varchar2, parm in varchar2, cd in varchar2 default null, ismand in boolean DEFAULT FALSE, showdesc in boolean DEFAULT TRUE, showcola in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE, xtr_a in varchar2 default null, xtr_b in varchar2 default null );
procedure lov_list_desc( lname in varchar2, parm in varchar2, v_code in varchar2 default null, cd in varchar2 default null, ismand in boolean DEFAULT FALSE, showcola in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE, xtr_a in varchar2 default null, xtr_b in varchar2 default null );
procedure customer_list( custype in varchar2, parm in varchar2, custid in varchar2 default null, ismand in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE );
procedure hb_list( rid_bs in rowid, hb in varchar2, parm in varchar2, ismand in boolean default FALSE, isedit in boolean default TRUE );
procedure list_ships( surl in varchar2, rnd in varchar2, msearch in varchar2 );

procedure search( surl in varchar2, msearch in varchar2, curr_rowid in varchar2, samerow in boolean DEFAULT FALSE, buttons_only in boolean DEFAULT FALSE, override_top in varchar2 default null, search_only in boolean DEFAULT FALSE, button_text in varchar2 default NULL, lmnu in rowid default null, split_row in boolean default FALSE )
as
 ctrg varchar2(20);
begin
 if not samerow
 then
  htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
  htp.tablerowopen;
 end if;
 if not buttons_only
 then
  if not search_only then htp.p( '<TD>' ); end if;
  htp.formopen( 'strangsb.menu', ctarget=>'_top' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'MTYPE', msearch );
  htp.formhidden( 'ACTION', 'SEARCH' );
  htp.formhidden( 'RID_SS', replace(curr_rowid,'~','+') );
  htp.formhidden( 'RND', to_char(sysdate, 'SSSSS' ));
  if search_only
  then
   htp.formtext( 'MSEARCH', 5, 100 );
  else
   htp.formtext( 'MSEARCH', 20, 100 );
  end if;
  htp.formsubmit( null, nvl(button_text,'Search') );
  htp.formclose;
  if search_only then return; end if;
  htp.p( '</TD>' );
  ctrg := '_top';
 else
  ctrg := '_self';
 end if;

 if split_row
  then
   htp.tablerowclose;
   htp.tablerowopen;
 end if;

 ctrg := nvl(override_top,ctrg);
 htp.p( '<TD ALIGN="CENTER" VALIGN="TOP">' );
 if msearch = 'RECEIVALS'
 then
  htp.anchor2( 'strangsb.menu?surl=' || surl || '&mtype=' || msearch || '&rnd=' || to_char(sysdate,'SSSSS') || '&action=PREVIOUS&rid_ss=' || replace(curr_rowid,'+','~'), htf.img( glbx.IMAGE_LOCATION || 'adminc_previous.gif', cattributes=>' BORDER=0',calt=>'Previous Record' ), ctarget=>ctrg );
  htp.anchor2( 'strangsb.menu?surl=' || surl || '&mtype=' || msearch || '&rnd=' || to_char(sysdate,'SSSSS') || '&action=NEXT&rid_ss=' || replace(curr_rowid,'+','~'), htf.img( glbx.IMAGE_LOCATION || 'adminc_next.gif', cattributes=>' BORDER=0',calt=>'Next Record' ), ctarget=>ctrg );
 else
  htp.anchor2( 'strangsb.menu?surl=' || surl || '&mtype=' || msearch || '&rnd=' || to_char(sysdate,'SSSSS') || '&action=PREVIOUS&rid_ss=' || replace(curr_rowid,'+','~'), htf.img( glbx.IMAGE_LOCATION || 'adminc_previous.gif', cattributes=>' BORDER=0',calt=>'Previous Record' ), ctarget=>ctrg );
  if lmnu is null
  then
   htp.anchor2( 'strangsb.menu?surl=' || surl || '&mtype=' || msearch || '&rnd=' || to_char(sysdate,'SSSSS') || '&action=NEXT&rid_ss=' || replace(curr_rowid,'+','~'), htf.img( glbx.IMAGE_LOCATION || 'adminc_next.gif', cattributes=>' BORDER=0',calt=>'Next Record' ), ctarget=>ctrg );
  else
   htp.anchor2( 'strangsb.menu?surl=' || surl || '&mtype=' || msearch || '&rnd=' || to_char(sysdate,'SSSSS') || '&action=NEXT&rid_ss=' || replace(lmnu,'+','~'), htf.img( glbx.IMAGE_LOCATION || 'adminc_next.gif', cattributes=>' BORDER=0',calt=>'Next Record' ), ctarget=>ctrg );
  end if;
 end if;
 htp.p( '</TD>' );
 if not samerow
 then
  htp.tablerowclose;
  htp.tableclose;
 end if;
end search;

function lov_code(lov_name in varchar2, lov_code in varchar2, ret_col in varchar2 default 'DESCRIPTION', xtr_a in varchar2 default null, xtr_b in varchar2 default null) return varchar2
as

cursor c1( lname varchar2, lcode varchar2, xtr_a varchar2, xtr_b varchar2 ) is
 select *
 from strang.lov
 where lov_name = lname
       and code = lcode
       and
       ((xtr_a is null) or (xtr_a is not null and cola = xtr_a) )
        and
       ((xtr_b is null) or (xtr_b is not null and colb = xtr_b) )
 ;

 c1rec    c1%ROWTYPE;
begin

open c1(lov_name, lov_code, xtr_a, xtr_b);
fetch c1 into c1rec;
close c1;

case upper(ret_col)
when 'DESCRIPTION' then return(c1rec.description);
when 'COLA'        then return(c1rec.cola);
when 'COLB'        then return(c1rec.colb);
when 'COLC'        then return(c1rec.colc);
else
 return(c1rec.description);
end case;

exception when others then
 return(null);
end lov_code;

procedure lov_list( lname in varchar2, parm in varchar2, cd in varchar2 default null, ismand in boolean DEFAULT FALSE, showdesc in boolean DEFAULT TRUE, showcola in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE, xtr_a in varchar2 default null, xtr_b in varchar2 default null )
as

 cursor c1( lname varchar2, snd varchar2, xtr_a varchar2, xtr_b varchar2 ) is
 select *
 from strang.lov
 where lov_name = lname and
    ((xtr_a is null) or (xtr_a is not null and cola = xtr_a) ) and
    ((xtr_b is null) or (xtr_b is not null and colb = xtr_b) )
 order by decode(snd,'A',code,'B',description);

 cursor c2( cd varchar2, xtr_a varchar2, xtr_b varchar2 ) is
 select *
 from strang.lov
 where lov_name = lname and
    code = cd and
    ((xtr_a is null) or (xtr_a is not null and cola = xtr_a) ) and
    ((xtr_b is null) or (xtr_b is not null and colb = xtr_b) );

 c2rec c2%ROWTYPE;
 snd varchar2(10);
 fval boolean;

begin

 if showdesc then snd := 'B'; else snd := 'A'; end if;
 fval := false;
 if isedit
 then
  htp.formselectopen( parm );
  if not ismand then htp.formselectoption( NULL ); end if;
  for c1rec in c1( lname, snd, xtr_a, xtr_b ) loop
  if (cd is not null) and (cd = c1rec.code)
   then
   if showdesc
    then
    if showcola
     then
     htp.formselectoption( c1rec.description || '-' || c1rec.cola, 'SELECTED', cattributes=>'VALUE="' || c1rec.code || '"' );
     fval := TRUE;
     else
     htp.formselectoption( c1rec.description, 'SELECTED', cattributes=>'VALUE="' || c1rec.code || '"' );
     fval := TRUE;
    end if;
   else
    htp.formselectoption( c1rec.code, 'SELECTED', cattributes=>'VALUE="' || c1rec.code || '"' );
    fval := TRUE;
   end if;
   else
   if showdesc
    then
    if showcola
     then
     htp.formselectoption( c1rec.description || '-' || c1rec.cola, cattributes=>'VALUE="' || c1rec.code || '"' );
     else
     htp.formselectoption( c1rec.description, cattributes=>'VALUE="' || c1rec.code || '"' );
    end if;
    else
    htp.formselectoption( c1rec.code, cattributes=>'VALUE="' || c1rec.code || '"' );
   end if;
  end if;
  end loop;
  if not fval and cd is not null then htp.formselectoption( cd, 'SELECTED' ); end if;
  htp.formselectclose;
 else

  open c2(cd, xtr_a, xtr_b);
  fetch c2 into c2rec;
  close c2;
  if showdesc
  then
   htp.bold(c2rec.description);
  else
   htp.bold(c2rec.code);
  end if;
 end if;
exception
 when others then htp.p( sqlerrm );
end lov_list;

procedure lov_list_desc( lname in varchar2, parm in varchar2, v_code in varchar2 default null, cd in varchar2 default null, ismand in boolean DEFAULT FALSE, showcola in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE, xtr_a in varchar2 default null, xtr_b in varchar2 default null )
as

 cursor c1( lname varchar2, v_code varchar2, xtr_a varchar2, xtr_b varchar2 ) is
 select *
 from strang.lov
 where lov_name = lname and
    ((v_code is null) or (v_code is not null and code = v_code) ) and
    ((xtr_a is null) or (xtr_a is not null and cola = xtr_a) ) and
    ((xtr_b is null) or (xtr_b is not null and colb = xtr_b) )
 order by description;

 cursor c2( cd varchar2, xtr_a varchar2, xtr_b varchar2 ) is
 select *
 from strang.lov
 where lov_name = lname and
    code = cd and
    ((xtr_a is null) or (xtr_a is not null and cola = xtr_a) ) and
    ((xtr_b is null) or (xtr_b is not null and colb = xtr_b) );

 c2rec c2%ROWTYPE;
 fval boolean;

begin

 fval := false;
 if isedit
 then
  htp.formselectopen( parm );
  if not ismand then htp.formselectoption( NULL ); end if;
  for c1rec in c1( lname, v_code, xtr_a, xtr_b ) loop
  if (cd is not null) and (cd = c1rec.description)
   then
    if showcola
     then
     htp.formselectoption( c1rec.description || '-' || c1rec.cola, 'SELECTED', cattributes=>'VALUE="' || c1rec.description || '"' );
     fval := TRUE;
     else
     htp.formselectoption( c1rec.description, 'SELECTED', cattributes=>'VALUE="' || c1rec.description || '"' );
     fval := TRUE;
    end if;
   else
    if showcola
     then
     htp.formselectoption( c1rec.description || '-' || c1rec.cola, cattributes=>'VALUE="' || c1rec.description || '"' );
     else
     htp.formselectoption( c1rec.description, cattributes=>'VALUE="' || c1rec.description || '"' );
    end if;
  end if;
  end loop;
  if not fval and cd is not null then htp.formselectoption( cd, 'SELECTED' ); end if;
  htp.formselectclose;
 else

  open c2(cd, xtr_a, xtr_b);
  fetch c2 into c2rec;
  close c2;
  htp.bold(c2rec.description);
 end if;
exception
 when others then htp.p( sqlerrm );
end lov_list_desc;

procedure customer_list( custype in varchar2, parm in varchar2, custid in varchar2 default null, ismand in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE )
as

 cursor c1( custype varchar2 ) is select customer_id, customer from strang.customers where customer_type = custype order by customer;
 cursor c2( custid integer) is select customer from strang.customers where customer_id = custid;

 c2rec c2%ROWTYPE;
begin

 if isedit
 then
  htp.formselectopen( parm );
  if not ismand then htp.formselectoption( NULL ); end if;
  for c1rec in c1( custype ) loop
  if (custid is not null) and (custid = c1rec.customer_id)
   then
   htp.formselectoption( c1rec.customer, 'SELECTED', cattributes=>'VALUE="' || c1rec.customer_id || '"' );
   else
   htp.formselectoption( c1rec.customer, cattributes=>'VALUE="' || c1rec.customer_id || '"' );
  end if;
  end loop;
  htp.formselectclose;
 else
  open c2(custid);
  fetch c2 into c2rec;
  close c2;
  htp.bold(c2rec.customer);
 end if;
exception
 when others then htp.p( sqlerrm );
end customer_list;

function customer_details( customer_id in integer ) return strang.customers%ROWTYPE
as

cursor c1( c_id integer ) is select * from strang.customers where customer_id = c_id;

c1rec  strang.customers%ROWTYPE;

begin

open c1(customer_id);
fetch c1 into c1rec;
close c1;

return(c1rec);

exception when others then
 return(null);
end customer_details;

procedure hb_list( rid_bs in rowid, hb in varchar2, parm in varchar2, ismand in boolean default FALSE, isedit in boolean default TRUE )
as

 cursor c1(rid rowid) is
 select hs.*
 from  strang.hbs_southbound hs, strang.bols_southbound bs
 where upper(hs.bol) = upper(bs.bol)
     and upper(hs.ship) = upper(bs.ship)
     and upper(hs.voyage) = upper(bs.voyage)
     and bs.rowid = rid
 order by hb
 ;

 cursor c2(rid rowid) is
 select 'x'
 from  strang.hbs_southbound hs, strang.bols_southbound bs
 where upper(hs.bol) = upper(bs.bol)
     and upper(hs.ship) = upper(bs.ship)
     and upper(hs.voyage) = upper(bs.voyage)
     and bs.rowid = rid
 order by hb
 ;

c2rec    c2%ROWTYPE;

begin

 if isedit
 then
  open c2( rid_bs );
  fetch c2 into c2rec;
  if c2%NOTFOUND
   then
    htp.formhidden( parm, null );
  else
    htp.formselectopen( parm );
    if not ismand then htp.formselectoption( NULL ); end if;
    for c1rec in c1( rid_bs ) loop
    if (hb is not null) and (hb = c1rec.house_bill)
     then
     htp.formselectoption( c1rec.house_bill, 'SELECTED', cattributes=>'VALUE="' || c1rec.house_bill || '"' );
     else
     htp.formselectoption( c1rec.house_bill, cattributes=>'VALUE="' || c1rec.house_bill || '"' );
    end if;
    end loop;
    htp.formselectclose;
  end if;
 else
  htp.bold(hb);
 end if;
 close c2;
exception
 when others then htp.p( sqlerrm );
end hb_list;

function customer_state(acid in integer)
 return varchar2
as
begin
 oltp.identify_user( acid );
 return(nvl(OLTP.USER_SITE,'SYD'));
end customer_state;

function control_code( cd in varchar2, vste in varchar2 )
 return varchar2
as

 cursor c1( cd varchar2, vste varchar2 ) is select description from strang.lov where lov_name = 'CONTROLS' and code = cd and cola = vste;

 c1rec c1%ROWTYPE;

begin
 open c1( cd, vste );
 fetch c1 into c1rec;
 close c1;
 return( c1rec.description );
exception
 when others
 then return( NULL );
end control_code;

function confirm_delete( v_action in varchar2 default 'ACTION', btn in varchar2 default 'Delete', msg in varchar2 default 'Are you sure you want to delete?', script_only in boolean default FALSE )
 return varchar2

as

 v_txt varchar2(32767);

begin
v_txt := '<script LANGUAGE="JavaScript">';
v_txt := v_txt || chr(10) || '<!--';
v_txt := v_txt || chr(10) || 'function confirmPost(vmsg)';
v_txt := v_txt || chr(10) || '{';
v_txt := v_txt || chr(10) || 'var txtConfirm=confirm(vmsg);';
v_txt := v_txt || chr(10) || 'if (txtConfirm)';
v_txt := v_txt || chr(10) || 'return true ;';
v_txt := v_txt || chr(10) || 'else';
v_txt := v_txt || chr(10) || 'return false ;';
v_txt := v_txt || chr(10) || '}';
v_txt := v_txt || chr(10) || '// -->';
v_txt := v_txt || chr(10) || '</script>';
if script_only
 then
 return( v_txt );
end if;
v_txt := v_txt || chr(10) || '<INPUT TYPE="submit" NAME="' || v_action || '" VALUE="' || btn || '" onClick="return confirmPost(''' || msg || ''')">';

return( v_txt );

exception when others then
 return('<INPUT TYPE="submit" NAME="ACTION" VALUE="Delete">');
end confirm_delete;

procedure list_ships( surl in varchar2, rnd in varchar2, msearch in varchar2 )
is

 cursor c1s( msearch varchar2 ) is
 select sb.*, sb.rowid
 from strang.ships_southbound sb
 where (
     upper(voyage) like upper(msearch) || '%'
     and instr(msearch,'-') = 0
    )
    or
    ( instr(msearch,'-') > 0
     and upper(voyage) = substr(upper(msearch),1,instr(msearch,'-')-1)
     and upper(ship) like substr(upper(msearch),instr(msearch,'-')+1) || '%'
    )
 order by ship,voyage asc
 ;

 cursor c2(lname varchar2, cd varchar2) is select description from strang.lov where lov_name = lname and code = cd;

 c2rec   c2%ROWTYPE;
 owner_id integer;
 ltype   varchar2(100);
 stype   integer;
 sts    varchar2(100);
 cusrec  customer_account%ROWTYPE;
 pfx    THEME%ROWTYPE;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGSB.LIST_SHIPS' );
 if sts is not null
 then
 glbx.redisplay_login_page( sts, TRUE );
 return;
 end if;

 cusrec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( cusrec.theme_name );

 glbx.main_title( surl, 'Southbound Ships',glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'STR16',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 htp.p( '<CENTER>' );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=10 border=0' ); -- Table 1
 htp.tablerowopen;
  htp.tabledata( htf.bold('Southbound Ships - Matching Records'), ' ALIGN="LEFT"');
  htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
  htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
 htp.tablerowclose;

 htp.tablerowopen;
 htp.p( '<TD align="LEFT" colspan="2">' );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border="1" ' || glbx.TABLE_BACKGROUND ); -- Table 2

  htp.tablerowopen;
   htp.tableheader( htf.bold('Ship'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tableheader( htf.bold('Voyage'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"' );
   htp.tableheader( htf.bold('Port of Loading'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"' );
   htp.tableheader( htf.bold('Sailing date'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  for c1rec in c1s( msearch ) loop
   htp.tablerowopen;
   htp.tabledata( htf.anchor( 'strangsb.ship?surl=' || surl || '&rid_ss=' || replace(c1rec.rowid, '+', '~') || '&parm=SHIPS&access_id=x', c1rec.ship ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   htp.tabledata( c1rec.voyage, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   open c2( 'LOCATIONS', c1rec.port_of_loading);
   fetch c2 into c2rec;
   close c2;
   htp.tabledata( nvl(c2rec.description, c1rec.port_of_loading), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   htp.tabledata( to_char(c1rec.sailing_date, lngs.STR_DATE_02), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   htp.tablerowclose;
  end loop;

 htp.tableclose; -- Table 2

 htp.p('</TD>');
 htp.tablerowclose;

 htp.tableclose; -- Table 1

exception when others then
 glbx.error_details( 'STRANGSB', 'LIST_SHIPS',null,owner_id,errmsg=>sqlerrm);
end list_ships;

procedure menu( surl in varchar2, rnd in varchar2, mtype in varchar2, msearch in varchar2 default null, action in varchar2 default 'SEARCH', rid_ss in rowid default null )
is

 cursor c1 is select rowid from strang.ships_southbound order by nvl(sailing_date, to_date('01-jan-1900')) desc, ship, voyage asc;
 cursor c1s( msearch varchar2 ) is
 select rowid
 from strang.ships_southbound
 where (
     upper(voyage) like upper(msearch) || '%'
     and instr(msearch,'-') = 0
    )
    or
    ( instr(msearch,'-') > 0
     and upper(voyage) = substr(upper(msearch),1,instr(msearch,'-')-1)
     and upper(ship) like substr(upper(msearch),instr(msearch,'-')+1) || '%'
    )
 order by ship,voyage asc
 ;

 c1rec   c1%ROWTYPE;

 lrid   rowid;
 ltype   varchar2(100);
 stype   integer;
 owner_id integer;
 sts    varchar2(100);
 cusrec  customer_account%ROWTYPE;
 vste   varchar2(10);
 msg    varchar2(4000);


begin

 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGSB.MENU' );
 if sts is not null
 then
 glbx.redisplay_login_page( sts, TRUE );
 return;
 end if;
 cusrec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(cusrec.aid);
 msg := NULL;

 if mtype = 'SHIPS'
 then
 if action = 'SEARCH'
  then
  if msearch is null
   then
   open c1;
   fetch c1 into c1rec;
   close c1;
  else
   -- Check if > 1 record(s) found
   for c1rec in c1s( msearch ) loop
    if c1s%ROWCOUNT > 1
    then
     list_ships( surl, rnd, msearch );
     return;
    end if;
   end loop;

   open c1s( msearch );
   fetch c1s into c1rec;
   close c1s;
  end if; --msearch is null
  elsif action = 'PREVIOUS'
  then
   open c1;
   lrid := NULL;
   loop
   fetch c1 into c1rec;
   if c1%NOTFOUND then c1rec.rowid := lrid; exit; end if;
   exit when c1rec.rowid = replace(rid_ss,'~','+');
   lrid := c1rec.rowid;
   end loop;
   close c1;
   if lrid is not null then c1rec.rowid := lrid; end if;
  elsif action = 'NEXT'
  then
   open c1;
   lrid := NULL;
   loop
   fetch c1 into c1rec;
   if c1%NOTFOUND then c1rec.rowid := lrid; exit; end if;
   if c1rec.rowid = replace(rid_ss,'~','+')
    then
    lrid := c1rec.rowid;
    fetch c1 into c1rec;
    if c1%NOTFOUND then c1rec.rowid := lrid; end if;
    exit;
   end if;
   lrid := c1rec.rowid;
   end loop;
   close c1;
  end if; -- action = ...

  if c1rec.rowid is null
  then
   msg := 'Record not Found: ' || msearch;
   c1rec.rowid := rid_ss;
  end if;
  ship(surl,c1rec.rowid, 'SHIPS', 'x', msg );
  return;
 end if; -- mtype = 'SHIPS'

exception when others then
 glbx.error_details( 'STRANGSB', 'MENU',null,null,errmsg=>sqlerrm,extdet=>'MTYPE:' || mtype);
end menu;

procedure track_containers(surl in varchar2, rid_ss in rowid, action in varchar2, mov_typ in varchar2 default 'SOUTHBOUND')
as

cursor c1 (rid_ss rowid) is select * from strang.ships_southbound where rowid = rid_ss;

cursor c2 (rid_ss rowid) is
 select cs.*, cs.rowid
 from  strang.containers_southbound cs, strang.ships_southbound ss
 where ss.rowid = rid_ss
    and upper(cs.ship) = upper(ss.ship)
    and upper(cs.voyage) = upper(ss.voyage)
;

cursor c3 (v_cntr varchar2) is select * from strang.tracking_header where upper(trim(containerno)) = upper(trim(v_cntr));
cursor c4 (rid_cs rowid, tid integer) is
 select td.*
 from   strang.tracking_details td, strang.containers_southbound cs
 where  cs.rowid = rid_cs
        and td.id = tid
        and td.ship = cs.ship
        and td.voyage=cs.voyage
;
cursor c5 (v_cntr varchar2) is select * from strang.containers where upper(trim(containerno)) = upper(trim(v_cntr));

 c1rec    c1%ROWTYPE;
 c3rec    c3%ROWTYPE;
 c5rec    c5%ROWTYPE;
 cdrec	  strang.tracking_details%ROWTYPE;
 cusrec   customer_account%ROWTYPE;
 owner_id integer;
 ltype    varchar2(100);
 stype    integer;
 vste     varchar2(10);
 pfx      THEME%ROWTYPE;
 vaccess  varchar2(20);
 seclevel varchar2(100);
 sts      varchar2(100);
 v_rid_ss rowid;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGSB.TRACK_CONTAINERS' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 v_rid_ss := replace(rid_ss, '~', '+');
 cusrec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(cusrec.aid);
 pfx := glbx.get_thm( cusrec.theme_name );
 vaccess := strangp.data_access( owner_id, 'SHP_SB', v_rid_ss );
 seclevel := oltp.security_role( owner_id );

 open c1( v_rid_ss );
 fetch c1 into c1rec;
 close c1;

 case action
 when 'INSERT' then
  for c2rec in c2(v_rid_ss) loop
   c5rec.cat_company := null;
   open c5(c2rec.container);
   fetch c5 into c5rec;
   close c5;
   open c3(c2rec.container);
   fetch c3 into c3rec;
   if c3%NOTFOUND
    then
    c3rec.containerno := c2rec.container;
    c3rec.cat_code := c2rec.container_type;
    c3rec.cat_company := c5rec.cat_company;
    select strang.s_tracking_header.nextval into c3rec.id from dual;
    insert into strang.tracking_header(id,containerno,cat_code,cat_company)
    values (c3rec.id,c3rec.containerno,c3rec.cat_code,c3rec.cat_company);
   elsif c3rec.cat_code is null or c3rec.cat_company is null
    then
     c3rec.cat_code := nvl(c3rec.cat_code, c2rec.container_type);
     c3rec.cat_company := nvl(c3rec.cat_company, c5rec.cat_company);
     update strang.tracking_header
     set    cat_code = c3rec.cat_code
       ,    cat_company = c3rec.cat_company
     where  id = c3rec.id;
   end if;
   close c3;

   cdrec := null;
   open c4( c2rec.rowid, c3rec.id);
   fetch c4 into cdrec;
   cdrec.remark := 'Bill of lading: ' || c2rec.bol;
   cdrec.movement_type := mov_typ;
   cdrec.departure_location := c1rec.port_of_loading;
   cdrec.etd_date := c1rec.sailing_date;
   cdrec.arrival_location := c1rec.final_destination;
   cdrec.eta_date := c1rec.arrival_date;
   cdrec.ship := c1rec.ship;
   cdrec.voyage := c1rec.voyage;
   cdrec.current_location := c1rec.final_destination;

   cdrec.date_at_current_loc := c1rec.arrival_date;

   cdrec.current_location := nvl(cdrec.current_location,cdrec.arrival_location);
   cdrec.date_at_current_loc := nvl(cdrec.date_at_current_loc,cdrec.eta_date);
   if c4%FOUND
    then
     update strang.tracking_details
     set
      remark = cdrec.remark,
      movement_type = cdrec.movement_type,
      departure_location = cdrec.departure_location,
      etd_date = cdrec.etd_date,
      arrival_location = cdrec.arrival_location,
      eta_date = cdrec.eta_date,
      ship = cdrec.ship,
      voyage = cdrec.voyage,
      current_location = cdrec.current_location,
      date_at_current_loc = cdrec.date_at_current_loc
     where id = c3rec.id
           and rno = cdrec.rno;
   else
     select nvl(max(rno),0) + 1 nmb into cdrec.rno from strang.tracking_details where id = c3rec.id;
     insert into strang.tracking_details(id,rno,remark,movement_type,departure_location,etd_date,arrival_location,eta_date,ship,voyage,current_location,date_at_current_loc)
      values(c3rec.id,cdrec.rno,cdrec.remark,cdrec.movement_type,cdrec.departure_location,cdrec.etd_date,cdrec.arrival_location,cdrec.eta_date,cdrec.ship,cdrec.voyage,cdrec.current_location,cdrec.date_at_current_loc);
   end if;
   close c4;
  end loop;
 when 'DELETE' then
  delete from strang.tracking_details where upper(ship) = upper(c1rec.ship) and upper(voyage) = upper(c1rec.voyage);
 else
  null;
 end case;

 commit;

exception when others
 then glbx.dbg('Error in container tracking: ' || sqlerrm);
end track_containers;

procedure ship(surl in varchar2, rid_ss in rowid, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null )
as

 cursor c1 (rid_ss rowid) is select * from strang.ships_southbound where rowid = rid_ss;

 c1rec    c1%ROWTYPE;
 cusrec   customer_account%ROWTYPE;
 owner_id integer;
 ltype    varchar2(100);
 stype    integer;
 vste     varchar2(10);
 pfx      THEME%ROWTYPE;
 vaccess  varchar2(20);
 -- xxxSouthbound vaccess2 varchar2(20);
 -- xxxSouthbound mf    varchar2(100);
 seclevel varchar2(100);
 sts      varchar2(100);
 v_rid_ss rowid;
 v_status owa.vc_arr;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGSB.SHIP' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 v_rid_ss := replace(rid_ss, '~', '+');
 cusrec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(cusrec.aid);
 pfx := glbx.get_thm( cusrec.theme_name );
 vaccess := strangp.data_access( owner_id, 'SHP_SB', v_rid_ss );
 -- xxxSouthbound vaccess2 := strangp.data_access( owner_id, 'SHP2', rid_ss );
 -- xxxSouthbound mf := control_code( 'OFFICE', vste );
 seclevel := oltp.security_role( owner_id );
 glbx.main_title( surl, 'Southbound Ship Management',glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'STR10',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 v_status(1) := 'TEMPORARY';
 v_status(2) := 'LOADING';
 v_status(3) := 'DEPARTED';
 v_status(4) := 'ARRIVED';
 v_status(5) := 'FINAL';

 htp.p( '<CENTER>' );
 if msg is not null
 then
  glbx.header_msg( msg );
 end if;

 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;

-- *===================================================================

 if rid_ss is not null
 then
  open c1( v_rid_ss );
  fetch c1 into c1rec;
  if c1%NOTFOUND
  then
   htp.init;
   close c1;
   htp.htmlopen;
   htp.header(3,'Southbound Ships', 'CENTER' );
   htp.header(3,'RECORD NOT FOUND', 'CENTER' );
   htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
   htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
   htp.nl;
   htp.header(2,'Extra Information: ROWID = ' || nvl(v_rid_ss, 'NULL'), 'CENTER' );
   htp.htmlclose;
   return;
  end if;
  close c1;
 elsif access_id != 'z'
 then
  ship(surl, null, parm, 'z', msg, call_name );
  return;
 end if;

 htp.tableopen; -- Table 1
 htp.tablerowopen;
 htp.p( '<TD align="LEFT" colspan="2">' );
 if vaccess = 'EDIT'
 then
  htp.formopen( 'strangsb.accept_ship' );
  htp.formhidden( 'SURL', surl );
  -- xxxSouthboundhtp.formhidden( 'SCID', scid );
  htp.formhidden( 'PARM', parm );
  htp.formhidden( 'ACCESS_ID', access_id );
 end if;

 if access_id = 'z'
 then
  htp.formhidden( 'RID_SS', null );
 else
  htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
 end if;

 -- Main Table

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border="1" ' || glbx.TABLE_BACKGROUND ); -- Table 2


 -- P1: Ship
 htp.tablerowopen;
  htp.tabledata( htf.bold('Ship'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  if vaccess = 'EDIT'
  then
   -- if access_id = 'z'
   -- then
    htp.tabledata( htf.formtext( 'P1', 30, 30, c1rec.ship ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   -- else
   --  htp.formhidden('P1', c1rec.ship);
   --  htp.tabledata( htf.bold( c1rec.ship ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   -- end if;
  else
   null;
  end if;
 htp.tablerowclose;

 -- P2: Voyage
 htp.tablerowopen;
  htp.tabledata( htf.bold('Voyage'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  if vaccess = 'EDIT'
  then
   -- if access_id = 'z'
   -- then
    htp.tabledata( htf.formtext( 'P2', 30, 30, c1rec.voyage ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   -- else
   --  htp.formhidden('P2', c1rec.voyage);
   --  htp.tabledata( htf.bold( c1rec.voyage ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   -- end if;
  else
   null;
  end if;
 htp.tablerowclose;

 -- P14: Status
 htp.tablerowopen;
  htp.tabledata( htf.bold('Port of Loading'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  if vaccess = 'EDIT'
  then
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   htp.formselectopen('P14');
    for j in v_status.first..v_status.last loop
     if v_status(j) = nvl(c1rec.status, 'LOADING')
      then
       htp.formselectoption(v_status(j), 'SELECTED', cattributes=>'VALUE="' || v_status(j) || '"');
     else
       htp.formselectoption(v_status(j), cattributes=>'VALUE="' || v_status(j) || '"');
     end if;
    end loop;
   htp.p( '</TD>' );
  else
   null;
  end if;
 htp.tablerowclose;

 -- P3: Port of Loading
 htp.tablerowopen;
  htp.tabledata( htf.bold('Port of Loading'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  if vaccess = 'EDIT'
  then
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   lov_list( 'LOCATIONS', 'P3', c1rec.port_of_loading, FALSE, TRUE, FALSE );
   htp.p( '</TD>' );
  else
   null;
  end if;
 htp.tablerowclose;

 -- P4: Port of Discharge
 htp.tablerowopen;
  htp.tabledata( htf.bold('Port of Discharge'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  if vaccess = 'EDIT'
  then
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   lov_list( 'LOCATIONS', 'P4', c1rec.port_of_discharge, FALSE, TRUE, FALSE );
   htp.p( '</TD>' );
  else
   null;
  end if;
 htp.tablerowclose;

 -- P5: Final Destination
 htp.tablerowopen;
  htp.tabledata( htf.bold('Final Destination'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  if vaccess = 'EDIT'
  then
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   lov_list( 'LOCATIONS', 'P5', c1rec.final_destination, FALSE, TRUE, FALSE );
   htp.p( '</TD>' );
  else
   null;
  end if;
 htp.tablerowclose;

 -- P6: Sailing Date
 htp.tablerowopen;
  htp.tabledata( htf.bold('Sailing Date'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  if vaccess = 'EDIT'
  then
   htp.tabledata( htf.formtext( 'P6', 20, 20, to_char(c1rec.sailing_date,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(replace(LNGS.STR_DATE_01, 'HH24:MI', '[HH24:MI]')), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  else
   null;
  end if;
 htp.tablerowclose;

 -- P7: Arrival Date
 htp.tablerowopen;
  htp.tabledata( htf.bold('Arrival Date'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  if vaccess = 'EDIT'
  then
   htp.tabledata( htf.formtext( 'P7', 20, 20, to_char(c1rec.arrival_date,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(replace(LNGS.STR_DATE_01, 'HH24:MI', '[HH24:MI]')), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  else
   null;
  end if;
 htp.tablerowclose;

 -- P8: Berth
 htp.tablerowopen;
  htp.tabledata( htf.bold('Berth'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  if vaccess = 'EDIT'
  then
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   lov_list( 'LOCATIONS', 'P8', c1rec.berth, FALSE, TRUE, FALSE );
   htp.p( '</TD>' );
  else
   null;
  end if;
 htp.tablerowclose;

 -- P9: Place of Acceptance
 htp.tablerowopen;
  htp.tabledata( htf.bold('Place of Acceptance'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  if vaccess = 'EDIT'
  then
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   lov_list( 'LOCATIONS', 'P9', c1rec.place_of_acceptance, FALSE, TRUE, FALSE );
   htp.p( '</TD>' );
  else
   null;
  end if;
 htp.tablerowclose;

 -- P10: Place of Delivery
 htp.tablerowopen;
  htp.tabledata( htf.bold('Place of Delivery'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  if vaccess = 'EDIT'
  then
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   lov_list( 'LOCATIONS', 'P10', c1rec.place_of_delivery, FALSE, TRUE, FALSE );
   htp.p( '</TD>' );
  else
   null;
  end if;
 htp.tablerowclose;

 -- P11: Signature
 htp.tablerowopen;
  htp.tabledata( htf.bold('Signature'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  if vaccess = 'EDIT'
  then
   htp.tabledata( htf.formtext( 'P11', 50, 100, c1rec.signature), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  else
   null;
  end if;
 htp.tablerowclose;

 -- P12: Arrival Date
 htp.tablerowopen;
  htp.tabledata( htf.bold('Date for Bills'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  if vaccess = 'EDIT'
  then
   htp.tabledata( htf.formtext( 'P12', 20, 20, to_char(c1rec.date_for_bills,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(replace(LNGS.STR_DATE_01, 'HH24:MI', '[HH24:MI]')), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  else
   null;
  end if;
 htp.tablerowclose;

 -- P13: Lloyds Number
 htp.tablerowopen;
  htp.tabledata( htf.bold('Lloyds Number'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  if vaccess = 'EDIT'
  then
   htp.tabledata( htf.formtext( 'P13', 50, 100, c1rec.lloyds_no), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  else
   null;
  end if;
 htp.tablerowclose;

 htp.tableclose; -- Table 2

 htp.p('</TD>');

 -- Submit Buttons

 if vaccess = 'EDIT'
 then
  htp.tablerowopen;
  if access_id = 'z'
  then
   htp.tabledata( htf.formsubmit( 'ACTION', lngs.STR_STH_002 ),cattributes=>'VALIGN="TOP"'); -- Insert
   htp.formclose;
  else
   htp.p('<TD VALIGN="TOP">');
   htp.formsubmit( 'ACTION', lngs.STR_STH_003 ); -- Update
   htp.formsubmit( 'ACTION', lngs.STR_STH_002 ); -- Insert
   htp.p( confirm_delete ( btn => lngs.STR_STH_004 )); -- Delete
   htp.formclose;
   htp.p('</TD>');
   htp.p('<TD rowspan="2">');
    htp.tableopen;
     search( surl, 'SHIPS', rid_ss, samerow=>TRUE, split_row=>TRUE );
    htp.tableclose;
   htp.p('</TD>');
  end if;
  htp.tablerowclose;

  if access_id = 'x'
  then
   htp.tablerowopen;
   htp.p('<TD>');
   htp.tableopen;
   htp.tablerowopen;
   htp.formopen( 'strangsb.bols' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'PARM', 'BOLS' );
   htp.formhidden( 'ACCESS_ID', access_id );
   htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
   htp.p('<TD VALIGN="TOP">');
   htp.formsubmit( 'ACTION', lngs.STR_STH_006 );
   htp.p('</TD>');
   htp.formclose;

   htp.formopen( 'strangsb.hbs' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'PARM', 'HBS' );
   htp.formhidden( 'ACCESS_ID', 'z' );
   htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
   htp.p('<TD VALIGN="TOP">');
   htp.formsubmit( 'ACTION', lngs.STR_STH_012 ); -- Edit HBs
   htp.p('</TD>');
   htp.formclose;

   htp.formopen( 'strangsb.dans' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'PARM', 'DANS' );
   htp.formhidden( 'ACCESS_ID', 'z' );
   htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
   htp.formhidden( 'RID_BS', null );
   htp.formhidden( 'RID_CS', null );
   htp.p('<TD VALIGN="TOP">');
   htp.formsubmit( 'ACTION', lngs.STR_STH_009 ); -- Edit DANs
   htp.p('</TD>');
   htp.formclose;

   htp.formopen( 'strangsb.containers_mass' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'PARM', 'CONTAINERS_MASS' );
   htp.formhidden( 'ACCESS_ID', access_id );
   htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
   htp.p('<TD VALIGN="TOP">');
   htp.formsubmit( 'ACTION', lngs.STR_STH_017 );
   htp.p('</TD>');
   htp.formclose;
   htp.tablerowclose;
   htp.tableclose;
   htp.p('</TD>');
   htp.tablerowclose;

-- Copy Ship records
   htp.tablerowopen;
   htp.p('<TD>');
   htp.formopen( 'strangsb.copy_ship' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'PARM', 'COPY_SHIP' );
   htp.formhidden( 'ACCESS_ID', access_id );
   htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
 -- P1: Ship
   htp.bold('Ship');
   htp.formtext( 'P1', 30, 30, 'Copy ' || c1rec.ship );
 -- P2 Voyage
   htp.p('</TD>');
   htp.tablerowclose;
   htp.tablerowopen;
   htp.p('<TD>');
   htp.bold('Voyage');
   htp.formtext( 'P2', 30, 30, 'Copy ' || c1rec.voyage );

   htp.formsubmit( 'ACTION', 'Copy to New Record' );
   htp.formclose;
   htp.p('</TD>');
   htp.tablerowclose;
--
  end if;

 end if;


 -- xxxSouthbound strangs.search( surl, parm, rid_ss, samerow=>TRUE );

 htp.tablerowclose;
 htp.tableclose; -- Table 1

-- *===================================================================

 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'STRANGSB', 'SHIP',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end ship;

procedure copy_ship(surl in varchar2, rid_ss in rowid, p1 in varchar2, p2 in varchar2, parm in varchar2, access_id in varchar2 default null, action in varchar2 )
 is

 cursor c1 ( rid_ss rowid ) is select * from strang.ships_southbound where rowid = rid_ss;
 cursor c1a ( sname varchar2, voy varchar2 ) is select rowid from strang.ships_southbound where upper(sname) = upper(ship) and upper(voy) = upper(voyage);
 cursor c2 (sname varchar2, voy varchar2 ) is select * from strang.bols_southbound where upper(sname) = upper(ship) and upper(voy) = upper(voyage);
 cursor c3 (sname varchar2, voy varchar2 ) is select * from strang.containers_southbound where upper(sname) = upper(ship) and upper(voy) = upper(voyage);
 cursor c4 (sname varchar2, voy varchar2 ) is select * from strang.hbs_southbound where upper(sname) = upper(ship) and upper(voy) = upper(voyage);
 cursor c5 (sname varchar2, voy varchar2 ) is select * from strang.dan_details_southbound where upper(sname) = upper(ship) and upper(voy) = upper(voyage);

 c1rec    c1%ROWTYPE;
 s_rec    c1%ROWTYPE;
 n_ship   varchar2(100);
 n_voy    varchar2(100);
 lrid     rowid;
 msg      varchar2(1000);
 owner_id integer;
 ltype    varchar2(100);
 stype    integer;
 sts      varchar2(100);

begin

 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGSB.COPY_SHIP' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 open c1( rid_ss );
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
  close c1;
  msg := ('Record not found<BR>Ship: ' || p1 || '<BR>Voyage: ' || p2 || '<BR>Extra Details: [ROWID] = ' || rid_ss);
  ship(surl, rid_ss, parm, access_id, msg);
  return;
 end if;
 close c1;

 n_ship := substr(trim(p1), 1, 30);
 n_voy := substr(trim(p2), 1, 10);

 open c1a(n_ship, n_voy);
 fetch c1a into lrid;
 if c1a%FOUND
  then
   close c1a;
   msg := 'Ship/Voyage already exist: ' || n_ship || '/' || n_voy;
   ship(surl, rid_ss, parm, access_id, msg);
   return;
 end if;
 close c1a;

 msg := 'We can create: ' || n_ship || '/' || n_voy;

 s_rec := c1rec;
 s_rec.ship := n_ship;
 s_rec.voyage := n_voy;

 insert into strang.ships_southbound values s_rec;
 if SQL%ROWCOUNT = 1
  then
   for c2rec in c2(c1rec.ship, c1rec.voyage) loop
    c2rec.ship := s_rec.ship;
    c2rec.voyage := s_rec.voyage;
    insert into strang.bols_southbound values c2rec;
   end loop;
   for c3rec in c3(c1rec.ship, c1rec.voyage) loop
    c3rec.ship := s_rec.ship;
    c3rec.voyage := s_rec.voyage;
    insert into strang.containers_southbound values c3rec;
   end loop;
   for c4rec in c4(c1rec.ship, c1rec.voyage) loop
    c4rec.ship := s_rec.ship;
    c4rec.voyage := s_rec.voyage;
    insert into strang.hbs_southbound values c4rec;
   end loop;
   for c5rec in c5(c1rec.ship, c1rec.voyage) loop
    c5rec.ship := s_rec.ship;
    c5rec.voyage := s_rec.voyage;
    insert into strang.dan_details_southbound values c5rec;
   end loop;
   commit;
 else
   rollback;
 end if;

 open c1a(s_rec.ship, s_rec.voyage);
 fetch c1a into lrid;
 if c1a%FOUND
  then
   close c1a;
   ship(surl, lrid, parm, access_id, 'Record inserted');
   return;
 else
   close c1a;
   ship(surl, rid_ss, parm, access_id, 'Error: Record not inserted');
   return;
 end if;

 ship(surl, rid_ss, parm, access_id, 'No action taken');
 return;

exception when others then
 glbx.error_details( 'STRANGSB', 'COPY_SHIP',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end copy_ship;

procedure accept_ship( surl in varchar2, rid_ss in rowid, parm in varchar2, access_id in varchar2, action in varchar2,
            p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2,
            p8 in varchar2, p9 in varchar2, p10 in varchar2, p11 in varchar2, p12 in varchar2, p13 in varchar2, p14 in varchar2 )
is

 cursor c1 ( rid_ss rowid ) is select * from strang.ships_southbound where rowid = rid_ss;
 cursor c1a ( sname varchar2, voy varchar2 ) is select rowid from strang.ships_southbound where upper(sname) = upper(ship) and upper(voy) = upper(voyage);
 cursor c2 ( sname varchar2, voy varchar2 ) is select 'x' from strang.bols_southbound where upper(sname) = upper(ship) and upper(voy) = upper(voyage);
 cursor c3 is select rowid from strang.ships_southbound order by ship, voyage asc;

 c1rec   c1%ROWTYPE;
 c2rec   c2%ROWTYPE;
 c3rec   c3%ROWTYPE;
 owner_id integer;
 ltype   varchar2(100);
 stype   integer;
 sts    varchar2(100);
 msg    varchar2(4000);
 lrid   rowid;
 dt6    date;
 dt7    date;
 dt12   date;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGSB.ACCEPT_SHIP' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 if action = lngs.STR_STH_004 -- Delete
  then
  open c1( rid_ss );
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
   close c1;
   msg := ('Record not found<BR>Ship: ' || p1 || '<BR>Voyage: ' || p2 || '<BR>Extra Details: [ROWID] = ' || rid_ss);
   ship(surl, rid_ss, parm, access_id, msg);
   return;
  end if;
  close c1;

  open c2( c1rec.ship, c1rec.voyage);
  fetch c2 into c2rec;
  if c2%FOUND
   then
   close c2;
   msg := ('Cannot Delete Record.<BR>Delete BOLs First');
   ship(surl, rid_ss, parm, access_id, msg);
   return;
  end if;
  close c2;

  delete from strang.ships_southbound where rowid = rid_ss;
  commit;

  msg := ('Record Deleted.<BR>Ship: ' || p1 || '<BR>Voyage: ' || p2 );
  open c3;
  fetch c3 into c3rec;
  close c3;
  ship(surl, c3rec.rowid, parm, access_id, msg);
  return;
 elsif action = lngs.STR_STH_002 -- Insert
  then
  if access_id = 'z'
   then

   -- Date Validation

   begin dt6 := to_date(p6,LNGS.STR_DATE_01); exception when others then ship(surl, c3rec.rowid, parm, 'z', LNGS.STR_TXT_152 || ':' || p6 || ' ' || LNGS.STR_TXT_153 || ':' || LNGS.STR_DATE_01 ); return; end;
   begin dt7 := to_date(p7,LNGS.STR_DATE_01); exception when others then ship(surl, c3rec.rowid, parm, 'z', LNGS.STR_TXT_152 || ':' || p7 || ' ' || LNGS.STR_TXT_153 || ':' || LNGS.STR_DATE_01 ); return; end;
   begin dt12 := to_date(p12,LNGS.STR_DATE_01); exception when others then ship(surl, c3rec.rowid, parm, 'z', LNGS.STR_TXT_152 || ':' || p12 || ' ' || LNGS.STR_TXT_153 || ':' || LNGS.STR_DATE_01 ); return; end;
   if (dt6 is not null) and (dt7 is not null) and (dt7 < dt6 )
    then
      ship(surl, c3rec.rowid, parm, 'z', LNGS.STR_TXT_190);
    return;
   end if;

   open c1a(p1, p2);
   fetch c1a into lrid;
   if c1a%FOUND
    then
     close c1a;
     msg := 'Ship/Voyage already exist: ' || p1 || '/' || p2;
     ship(surl, c3rec.rowid, parm, 'z', msg);
     return;
   end if;
   close c1a;

   msg := 'Record Inserted';
   insert into strang.ships_southbound (
         ship
        , voyage
        , port_of_loading
        , port_of_discharge
        , final_destination
        , sailing_date
        , arrival_date
        , berth
        , place_of_acceptance
        , place_of_delivery
        , signature
        , date_for_bills
        , lloyds_no
        , status)
       values (
         p1
        , p2
        , p3
        , p4
        , p5
        , dt6
        , dt7
        , p8
        , p9
        , p10
        , p11
        , dt12
        , p13
        , p14);
   commit;
   open c1a(p1, p2);
   fetch c1a into lrid;
   close c1a;
   ship(surl, lrid, parm, 'x', msg);
   return;
  else
   ship(surl, c3rec.rowid, parm, 'z', msg);
  end if;
  return;
 elsif action = lngs.STR_STH_003 -- Update
  then

  -- Date Validation

  begin dt6 := to_date(p6,LNGS.STR_DATE_01); exception when others then ship(surl, rid_ss, parm, 'x', LNGS.STR_TXT_152 || ':' || p6 || ' ' || LNGS.STR_TXT_153 || ':' || LNGS.STR_DATE_01 ); return; end;
  begin dt7 := to_date(p7,LNGS.STR_DATE_01); exception when others then ship(surl, rid_ss, parm, 'x', LNGS.STR_TXT_152 || ':' || p7 || ' ' || LNGS.STR_TXT_153 || ':' || LNGS.STR_DATE_01 ); return; end;
  begin dt12 := to_date(p12,LNGS.STR_DATE_01); exception when others then ship(surl, rid_ss, parm, 'x', LNGS.STR_TXT_152 || ':' || p12 || ' ' || LNGS.STR_TXT_153 || ':' || LNGS.STR_DATE_01 ); return; end;
  if (dt6 is not null) and (dt7 is not null) and (dt7 < dt6 )
   then
     ship(surl, rid_ss, parm, 'x', LNGS.STR_TXT_190);
   return;
  end if;

  open c1(rid_ss);
  fetch c1 into c1rec;
  close c1;

  if p1 <> c1rec.ship or p2 <> c1rec.voyage
   then
    open c1a(p1, p2);
    fetch c1a into lrid;
    if c1a%FOUND
     then
      close c1a;
      msg := 'Ship/Voyage already exist: ' || p1 || '/' || p2;
      ship(surl, rid_ss, parm, 'x', msg);
      return;
    end if;
    close c1a;
    update strang.bols_southbound set ship = upper(trim(p1)), voyage = upper(trim(p2)) where upper(trim(ship)) = upper(trim(c1rec.ship)) and upper(trim(voyage)) = upper(trim(c1rec.voyage));
    update strang.containers_southbound set ship = upper(trim(p1)), voyage = upper(trim(p2)) where upper(trim(ship)) = upper(trim(c1rec.ship)) and upper(trim(voyage)) = upper(trim(c1rec.voyage));
    update strang.dan_details_southbound set ship = upper(trim(p1)), voyage = upper(trim(p2)) where upper(trim(ship)) = upper(trim(c1rec.ship)) and upper(trim(voyage)) = upper(trim(c1rec.voyage));
    update strang.hbs_southbound set ship = upper(trim(p1)), voyage = upper(trim(p2)) where upper(trim(ship)) = upper(trim(c1rec.ship)) and upper(trim(voyage)) = upper(trim(c1rec.voyage));
  end if;

  msg := 'Record Updated';
  update strang.ships_southbound
  set  ship = p1
     , voyage = p2
     , port_of_loading = p3
     , port_of_discharge = p4
     , final_destination = p5
     , sailing_date = dt6
     , arrival_date = dt7
     , berth = p8
     , place_of_acceptance = p9
     , place_of_delivery = p10
     , signature = p11
     , date_for_bills = dt12
     , lloyds_no = p13
     , status = p14
  where rowid = rid_ss;
  commit;
  if p14 = 'FINAL' and c1rec.status <> 'FINAL'
   then
    track_containers(surl, rid_ss, 'INSERT', 'SOUTHBOUND SHIP');
  elsif c1rec.status  ='FINAL' and p14 <> 'FINAL'
   then
    track_containers(surl, rid_ss, 'DELETE');
  end if;
  ship(surl, rid_ss, parm, 'x', msg);
  return;
 else
  htp.htmlopen;
  htp.bodyopen;
  htp.p('action = ' || action); htp.nl;
  htp.p('p1 = ' || p1); htp.nl;
  htp.p('p2 = ' || p2); htp.nl;
  htp.p('p3 = ' || p3); htp.nl;
  htp.p('p4 = ' || p4); htp.nl;
  htp.p('p5 = ' || p5); htp.nl;
  htp.p('p6 = ' || p6); htp.nl;
  htp.p('p7 = ' || p7); htp.nl;
  htp.p('p8 = ' || p8); htp.nl;
  htp.p('p9 = ' || p9); htp.nl;
  htp.p('p10 = ' || p10); htp.nl;
  htp.p('p11 = ' || p11); htp.nl;
  htp.p('p12 = ' || p12); htp.nl;
  htp.p('p13 = ' || p13); htp.nl;
  htp.bodyclose;
  htp.htmlclose;
 end if; -- action

 -- ship(surl, rid_ss, parm, access_id, msg);

exception when others then
 glbx.error_details( 'STRANGSB', 'ACCEPT_SHIP',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_ship;

procedure bols (surl in varchar2, rid_ss in rowid, rid_bs rowid default null, parm in varchar2, action in varchar2, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null
              , p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar default null)
is

cursor c1 (rid_ss rowid) is select * from strang.ships_southbound where rowid = rid_ss;
cursor c2 (rid_ss rowid) is
 select lngs.STR_STH_005 tot
 from  strang.bols_southbound bs, strang.ships_southbound ss
 where ss.rowid = rid_ss
    and upper(bs.ship) = upper(ss.ship)
    and upper(bs.voyage) = upper(ss.voyage)
;
cursor c3a (rid_ss rowid) is
 select sb.* , sb.rowid
 from  strang.bols_southbound sb, strang.ships_southbound ss
 where upper(sb.ship) = upper(ss.ship)
    and upper(sb.voyage) = upper(ss.voyage)
    and ss.rowid = rid_ss
 order by bol asc
;

cursor c3b (rid_ss rowid) is
 select sb.* , sb.rowid
 from  strang.bols_southbound sb, strang.ships_southbound ss
 where upper(sb.ship) = upper(ss.ship)
    and upper(sb.voyage) = upper(ss.voyage)
    and ss.rowid = rid_ss
 order by bol asc
;

cursor c3c (rid_bs rowid) is select sb.*, sb.rowid from strang.bols_southbound sb where rowid = rid_bs;

 c1rec    c1%ROWTYPE;
 c3rec    c3a%ROWTYPE;
 ltype    varchar2(100);
 owner_id integer;
 stype    integer;
 cusrec   customer_account%ROWTYPE;
 v_action varchar2(100);
 vste     varchar2(10);
 pfx      THEME%ROWTYPE;
 vaccess  varchar2(20);
 seclevel varchar2(100);
 sts      varchar2(100);
 v_rid_ss rowid;
 v_rid_bs rowid;


begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGSB.BOLS' );
 if sts is not null
 then
 glbx.redisplay_login_page( sts, TRUE );
 return;
 end if;

 v_rid_ss := replace(rid_ss, '~', '+');
 v_rid_bs := replace(rid_bs, '~', '+');
 cusrec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(cusrec.aid);
 pfx := glbx.get_thm( cusrec.theme_name );
 vaccess := strangp.data_access( owner_id, 'SHP_SB', v_rid_ss );
 seclevel := oltp.security_role( owner_id );

 open c1(v_rid_ss);
 fetch c1 into c1rec;
 if c1%NOTFOUND
 then
  htp.init;
  close c1;
  htp.htmlopen;
  htp.header(3,'Southbound Ships', 'CENTER' );
  htp.header(3,'RECORD NOT FOUND', 'CENTER' );
  htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
  htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
  htp.nl;
  htp.header(2,'Extra Information: ROWID = ' || nvl(v_rid_ss, 'NULL'), 'CENTER' );
  htp.htmlclose;
  return;
 end if;
 close c1;

 if action = lngs.STR_STH_005
 or action = lngs.STR_STH_006
 then
  open c2 (v_rid_ss);
  fetch c2 into v_action;
  if c2%NOTFOUND
  then
   v_action := lngs.STR_STH_002;
  end if;
  close c2;
 end if;

 v_action := nvl(v_action, action);

 glbx.main_title( surl, 'Southbound BOLs',glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'STR16',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 htp.p( '<CENTER>' );

 if msg is not null
 then
  glbx.header_msg( msg );
 end if;

 if v_action in (lngs.STR_STH_005, lngs.STR_STH_006) -- List
 then

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=10 border=0' ); -- Table 1
  htp.tablerowopen;
   htp.tabledata( htf.bold('Southbound BOLs'), ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
  htp.tablerowclose;

  htp.tablerowopen;
  htp.p( '<TD align="LEFT" colspan="2">' );

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border="1" ' || glbx.TABLE_BACKGROUND ); -- Table 2

   htp.tablerowopen;
    htp.tabledata( htf.bold('Ship'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.anchor('strangsb.ship?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=SHIPS&access_id=x', c1rec.ship), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Voyage'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( c1rec.voyage, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tablerowclose;
   htp.p(confirm_delete(script_only=>TRUE));
   for c3rec in c3a(v_rid_ss) loop
    htp.tablerowopen;
     htp.tabledata( c3rec.bol, ' ALIGN="LEFT"');
     htp.tabledata( htf.anchor('strangsb.bols?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_003 || '&rid_bs=' || replace(c3rec.rowid, '+', '~') || '&access_id=x&msg=' || msg || '&call_name=' || call_name, 'Update') ||
            '&nbsp;' ||
            htf.anchor('strangsb.accept_bols?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_004 || '&rid_bs=' || replace(c3rec.rowid, '+', '~') || '&access_id=x&p1=&p2=&p3=&p4=&p5=&p6=&p7=', 'Delete', cattributes=>'onClick="return confirmPost(''Delete ' || c3rec.bol || ': Are you sure?'')"') ||
            '&nbsp;' ||
            htf.anchor('strangsb.bols?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_015 || '&rid_bs=' || replace(c3rec.rowid, '+', '~') || '&access_id=x&msg=' || msg || '&call_name=' || call_name, 'Rename')
            || '&nbsp;' ||
            htf.anchor('strangsb.containers_mass?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_017 || '&rid_bs=' || replace(c3rec.rowid, '+', '~') || '&access_id=x&msg=' || null || '&call_name=' || call_name, LNGS.STR_STH_017)
            , cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tablerowclose;
   end loop;

  -- Submit Buttons

   htp.tablerowopen;

   htp.formopen( 'strangsb.bols' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
   htp.formhidden( 'PARM', 'BOLS' );
   htp.formhidden( 'ACCESS_ID', 'z' );
   htp.formhidden( 'RID_BS', null );
   htp.p('<TD VALIGN="TOP">');
   htp.formsubmit( 'ACTION', lngs.STR_STH_002 ); -- Insert
   htp.p('</TD>');
   htp.formclose;

   htp.tablerowclose;

   htp.tableclose;
   htp.p('</TD>');

  htp.tablerowclose;
  htp.tableclose; -- Table 1
  return;
 end if;

 if v_action = lngs.STR_STH_002 -- Insert
 or v_action = lngs.STR_STH_007 -- Insert Another Record
 then
  if v_rid_bs is null   -- Default values to pre-populate fields
  then
   open c3b( v_rid_ss );
   fetch c3b into c3rec;
   close c3b;
  else
   open c3c( v_rid_bs );
   fetch c3c into c3rec;
   close c3c;
  end if;

  htp.tableopen; -- Table 1
  htp.tablerowopen;
  htp.p( '<TD align="LEFT" colspan="2">' );
  htp.formopen( 'strangsb.accept_bols' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'PARM', parm );
  htp.formhidden( 'ACCESS_ID', 'z' );
  htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
  htp.formhidden( 'RID_BS', null );
 -- Main Table

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border="1" ' || glbx.TABLE_BACKGROUND ); -- Table 2

  -- Ship
  htp.tablerowopen;
   htp.tabledata( htf.bold('Ship'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.anchor('strangsb.ship?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=SHIPS&access_id=x', c1rec.ship ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- Voyage
  htp.tablerowopen;
   htp.tabledata( htf.bold('Voyage'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( c1rec.voyage ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P1: BOL
  htp.tablerowopen;
   htp.tabledata( htf.bold('BOL'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P1', 30, 30), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P5: Delivery Date and Time
  htp.tablerowopen;
   htp.tabledata( htf.bold('Delivery Date and Time'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P5', 25, 25, to_char(c3rec.del_date,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(LNGS.STR_DATE_01), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P6: Customs Authority Number
  htp.tablerowopen;
   htp.tabledata( htf.bold('Customs Authority no.'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P6', 30, 100, c3rec.customs_auth_no), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P7: AQIS Clearance
  htp.tablerowopen;
   htp.tabledata( htf.bold('AQIS Clearance'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P7', 25, 25, to_char(c3rec.aqis_clearance,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(replace(LNGS.STR_DATE_01, 'HH24:MI', '[HH24:MI]')), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P2: Shipper
  htp.tablerowopen;
   htp.tabledata( htf.bold('Shipper'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   customer_list( 'SOUTHBOUND', 'P2', c3rec.shipper, FALSE, isedit=>TRUE );
   htp.anchor( 'javascript: window.open(''' || 'oltp.display_screen?surl=' || surl || '&sname=Customers&rnd=63084&access_in=QUERY&rid=' || ''',''CUSTOMER_CODES'',''height=800,width=1200,scrollbars=yes,resizable=yes'');void('''');', '[Customer Codes]'
             , cattributes=>'title="Edit Code in a new window ***NOTE*** Reload this page for new codes to take effect"');
   htp.p( '</TD>' );
  htp.tablerowclose;

  -- P3: Consignee
  htp.tablerowopen;
   htp.tabledata( htf.bold('Consignee'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   customer_list( 'SOUTHBOUND', 'P3', c3rec.consignee, FALSE, isedit=>TRUE );
   htp.anchor( 'strangsb.bols?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&rid_bs=&parm=' || parm || '&action=' || v_action || '&access_id=' || access_id || '&msg=' || msg || '&call_name=' || call_name
             , '[Reload Page]'
             , cattributes=>'title="Reload this page"');
   htp.p( '</TD>' );
  htp.tablerowclose;

  -- P4: Notifying Party
  htp.tablerowopen;
   htp.tabledata( htf.bold('Notifying Party'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   customer_list( 'SOUTHBOUND', 'P4', c3rec.notifying_party, FALSE, isedit=>TRUE );
   htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tableclose; -- Table 2
  htp.p('</TD>');
  htp.tablerowclose;

  htp.tablerowopen;

  htp.tablerowclose;

 -- Submit Buttons

  htp.p('<TD VALIGN="TOP">');
  htp.formsubmit( 'ACTION', lngs.STR_STH_002 ); -- Insert
  htp.p('&nbsp;');
  htp.formsubmit( 'ACTION', lngs.STR_STH_005 ); -- List All Records
  htp.p('</TD>');

  htp.tablerowclose;
  htp.formclose;
  htp.tableclose; -- Table 1

 end if;

 if v_action in (lngs.STR_STH_003, lngs.STR_STH_015, lngs.STR_STH_016) -- Update or Rename or Confirm Rename
 then
  open c3c( v_rid_bs );
  fetch c3c into c3rec;
  if c3c%NOTFOUND
  then
   close c3c;
   htp.init;
   htp.htmlopen;
   htp.header(3,'Southbound BOLs', 'CENTER' );
   htp.header(3,'RECORD NOT FOUND', 'CENTER' );
   htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
   htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
   htp.nl;
   htp.header(2,'Extra Information: ROWID = ' || nvl(v_rid_bs , 'NULL'), 'CENTER' );
   htp.htmlclose;
   return;
  end if;
  close c3c;

  if v_action in (lngs.STR_STH_016) -- Confirm Rename
   then
    c3rec.bol := P1;
    c3rec.shipper := P2;
    c3rec.consignee := P3;
    c3rec.notifying_party := P4;
  end if;

  htp.tableopen; -- Table 1
  htp.tablerowopen;
  htp.p( '<TD align="LEFT" colspan="4">' );
  htp.formopen( 'strangsb.accept_bols' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'PARM', parm );
  htp.formhidden( 'ACCESS_ID', 'z' );
  htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
  htp.formhidden( 'RID_BS', replace(rid_bs ,'~','+') );
 -- Main Table

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border="1" ' || glbx.TABLE_BACKGROUND ); -- Table 2

  -- Ship
  htp.tablerowopen;
   htp.tabledata( htf.bold('Ship'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.anchor('strangsb.ship?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=SHIPS&access_id=x', c3rec.ship ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- Voyage
  htp.tablerowopen;
   htp.tabledata( htf.bold('Voyage'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( c3rec.voyage ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P1: BOL
  htp.tablerowopen;
   htp.tabledata( htf.bold('BOL'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if v_action in (lngs.STR_STH_015) -- Rename
    then
     htp.tabledata( htf.formtext( 'P1', 30, 30, c3rec.bol), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   else
     htp.formhidden( 'P1', c3rec.bol );
     if v_action in (lngs.STR_STH_016) -- Confirm Rename
      then
       htp.tabledata( htf.bold( c3rec.bol ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
     else
       htp.tabledata( htf.anchor('strangsb.bols?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_003 || '&rid_bs=' || replace(c3rec.rowid, '+', '~') || '&access_id=x&msg=' || msg || '&call_name=' || call_name, c3rec.bol
                               , cattributes=>'title="Reload This Page"')
                     , cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
   end if;
  htp.tablerowclose;

  -- P5: Delivery Date and Time
  htp.tablerowopen;
   htp.tabledata( htf.bold('Delivery Date and Time'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P5', 25, 25, to_char(c3rec.del_date,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(LNGS.STR_DATE_01), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P6: Customs Authority Number
  htp.tablerowopen;
   htp.tabledata( htf.bold('Customs Authority no.'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P6', 30, 100, c3rec.customs_auth_no), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P7: AQIS Clearance
  htp.tablerowopen;
   htp.tabledata( htf.bold('AQIS Clearance'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P7', 25, 25, to_char(c3rec.aqis_clearance,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(replace(LNGS.STR_DATE_01, 'HH24:MI', '[HH24:MI]')), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P2: Shipper
  htp.tablerowopen;
   htp.tabledata( htf.bold('Shipper'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   customer_list( 'SOUTHBOUND', 'P2', c3rec.shipper, FALSE, isedit=>TRUE );
   htp.anchor( 'javascript: window.open(''' || 'oltp.display_screen?surl=' || surl || '&sname=Customers&rnd=63084&access_in=QUERY&rid=' || ''',''CUSTOMER_CODES'',''height=800,width=1200,scrollbars=yes,resizable=yes'');void('''');', '[Customer Codes]'
              , cattributes=>'title="Edit Code in a new window ***NOTE*** Reload this page for new codes to take effect"' );
   htp.p( '</TD>' );
  htp.tablerowclose;

  -- P3: Consignee
  htp.tablerowopen;
   htp.tabledata( htf.bold('Consignee'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   customer_list( 'SOUTHBOUND', 'P3', c3rec.consignee, FALSE, isedit=>TRUE );
   htp.p( '</TD>' );
  htp.tablerowclose;

  -- P4: Notifying Party
  htp.tablerowopen;
   htp.tabledata( htf.bold('Notifying Party'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   customer_list( 'SOUTHBOUND', 'P4', c3rec.notifying_party, FALSE, isedit=>TRUE );
   htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tableclose; -- Table 2
  htp.p('</TD>');
  htp.tablerowclose;

 -- Submit Buttons

  htp.tablerowopen;
  if v_action in (lngs.STR_STH_015, lngs.STR_STH_016) -- Rename, Confirm Rename
   then
    htp.p('<TD VALIGN="TOP" WIDTH="25%">');
    htp.formsubmit( 'ACTION', v_action ); -- Rename
    htp.p('</TD>');
    htp.p('<TD VALIGN="TOP" WIDTH="25%">');
    htp.formsubmit( 'ACTION', lngs.STR_STH_005 ); -- List all Records
    htp.p('</TD>');
    htp.tabledata('&nbsp;', cattributes=>'COLSPAN="2"');
    htp.tablerowclose;
    htp.formclose;
  else
    htp.p('<TD VALIGN="TOP" WIDTH="25%">');
    htp.formsubmit( 'ACTION', lngs.STR_STH_003 ); -- Update
    htp.p('</TD>');
    htp.p('<TD VALIGN="TOP" WIDTH="25%">');
    htp.p( confirm_delete ( 'ACTION', lngs.STR_STH_004, 'Delete ' || c3rec.bol || ': Are you sure?' )); -- Delete
    htp.p('</TD>');
    htp.p('<TD VALIGN="TOP" WIDTH="25%">');
    htp.formsubmit( 'ACTION', lngs.STR_STH_005 ); -- List all Records
    htp.p('</TD>');
    htp.p('<TD VALIGN="TOP" WIDTH="25%">');
    htp.formsubmit( 'ACTION', lngs.STR_STH_007 ); -- Insert Another Record
    htp.p('</TD>');
    htp.tablerowclose;
    htp.formclose;

    htp.tablerowopen;

    htp.formopen( 'strangsb.containers' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'PARM', 'CONTAINERS' );
    htp.formhidden( 'ACCESS_ID', 'z' );
    htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
    htp.formhidden( 'RID_BS', replace(rid_bs ,'~','+') );

    htp.p('<TD VALIGN="TOP">');
    htp.formsubmit( 'ACTION', lngs.STR_STH_008 ); -- Edit Containers
    htp.p('</TD>');
    htp.formclose;

    htp.formopen( 'strangsb.hbs' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'PARM', 'HBS' );
    htp.formhidden( 'ACCESS_ID', 'z' );
    htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
    htp.formhidden( 'RID_BS', replace(rid_bs ,'~','+') );

    htp.p('<TD VALIGN="TOP">');
    htp.formsubmit( 'ACTION', lngs.STR_STH_012 ); -- Edit HBs
    htp.p('</TD>');
    htp.formclose;

    htp.formopen( 'strangsb.dans' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'PARM', 'DANS' );
    htp.formhidden( 'ACCESS_ID', 'z' );
    htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
    htp.formhidden( 'RID_BS', replace(rid_bs ,'~','+') );
    htp.formhidden( 'RID_CS', null );

    htp.p('<TD VALIGN="TOP">');
    htp.formsubmit( 'ACTION', lngs.STR_STH_014 ); -- Break-Bulk DANs
    htp.p('</TD>');
    htp.formclose;

    htp.p('<TD VALIGN="TOP">');
    htp.formopen( 'strangsb.containers_mass' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'PARM', 'CONTAINERS_MASS' );
    htp.formhidden( 'ACCESS_ID', access_id );
    htp.formsubmit( 'ACTION', lngs.STR_STH_017 );
    htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
    htp.formhidden( 'RID_BS', replace(rid_bs,'~','+') );
    htp.formclose;
    htp.p('</TD>');

    htp.tablerowclose;
  end if;

  htp.tableclose; -- Table 1

 else
  null;
 end if;

exception when others then
 glbx.error_details( 'STRANGSB', 'BOLS',null,null,errmsg=>sqlerrm,extdet=>'RID_SS:' || rid_ss);
end bols;

procedure accept_bols( surl in varchar2, rid_ss in rowid, rid_bs in rowid, parm in varchar2, access_id in varchar2, action in varchar2,
            p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2 )
is

 cursor c1 ( rid_bs rowid ) is select * from strang.bols_southbound where rowid = rid_bs ;
 cursor c2 ( v_bol varchar2, rid_ss rowid ) is
 select sb.*, sb.rowid
 from  strang.bols_southbound sb, strang.ships_southbound ss
 where upper(v_bol) = upper(sb.bol)
     and sb.ship = ss.ship
     and sb.voyage = ss.voyage
     and ss.rowid = rid_ss
 ;
 cursor c3( rid_ss rowid ) is select * from strang.ships_southbound where rowid = rid_ss;
 cursor c4( rid_bs rowid ) is
 select distinct msg from
  (
   select 'Delete Containers First. ' msg
   from  strang.containers_southbound sc, strang.bols_southbound sb
   where upper(sc.ship) = upper(sb.ship)
      and upper(sb.voyage) = upper(sb.voyage)
      and upper(sb.bol) = upper(sc.bol)
      and sb.rowid = rid_bs
   UNION ALL
   select 'Delete HBs First. ' msg
   from  strang.hbs_southbound sc, strang.bols_southbound sb
   where upper(sc.ship) = upper(sb.ship)
      and upper(sb.voyage) = upper(sb.voyage)
      and upper(sb.bol) = upper(sc.bol)
      and sb.rowid = rid_bs
   UNION ALL
   select 'Delete DANs First. ' msg
   from  strang.dan_details_southbound sc, strang.bols_southbound sb
   where upper(sc.ship) = upper(sb.ship)
      and upper(sb.voyage) = upper(sb.voyage)
      and upper(sb.bol) = upper(sc.bol)
      and sb.rowid = rid_bs
  )
 ;

 c1rec   c1%rowtype;
 c2rec   c2%rowtype;
 c3rec   c3%rowtype;
 owner_id integer;
 ltype   varchar2(100);
 stype   integer;
 sts    varchar2(100);
 msg    varchar2(4000);
 lrid   rowid;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGSB.ACCEPT_BOLS' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 open c3( rid_ss );
 fetch c3 into c3rec;
 if c3%NOTFOUND
  then
   htp.init;
   close c3;
   htp.htmlopen;
   htp.header(3,'Southbound Ships', 'CENTER' );
   htp.header(3,'RECORD NOT FOUND', 'CENTER' );
   htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
   htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
   htp.nl;
   htp.header(2,'Extra Information: ROWID = ' || nvl(rid_ss, 'NULL'), 'CENTER' );
   htp.htmlclose;
   return;
  end if;
  close c3;

 if action = lngs.STR_STH_004 -- Delete
  then
  open c1(rid_bs);
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
   close c1;
   htp.init;
   htp.htmlopen;
    htp.header(2,'Southbound BOLs', 'CENTER' );
    htp.header(2,'RECORD NOT FOUND', 'CENTER' );
    htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
    htp.header(2,LNGS.STR_TXT_290, 'CENTER' );
    htp.nl;
    htp.header(3,'Extra Information: ROWID = ' || nvl(rid_bs , 'NULL'), 'CENTER' );
   htp.htmlclose;
   return;
  end if;
  close c1;

  msg := null;
  for c4rec in c4(rid_bs ) loop
   msg := msg || c4rec.msg || '<BR>';
  end loop;

  if msg is not null
   then
   bols(surl, rid_ss, rid_bs, parm, lngs.STR_STH_003, access_id, msg);
   return;
  end if;

  msg := 'Record Deleted: ' || c1rec.bol;
  delete from strang.bols_southbound where rowid = rid_bs ;
  commit;
  bols(surl, rid_ss, null, parm, lngs.STR_STH_006, 'z', msg);
  return;
 elsif action = lngs.STR_STH_002 -- Insert
  then
  if p1 is null
   then
   msg := ('Please Enter BOL Number');
   bols(surl, rid_ss, c2rec.rowid, parm, action, access_id, msg);
   return;
  end if;
  open c2(p1, rid_ss);
  fetch c2 into c2rec;
  if c2%FOUND
   then
   close c2;
   msg := ('Record already exists: ' || c2rec.bol);
   bols(surl, rid_ss, c2rec.rowid, parm, action, access_id, msg);
   return;
  end if;
  close c2;

  -- Date Validation - Delivery Date
  begin
  c1rec.del_date := to_date(p5,LNGS.STR_DATE_01);
  exception when others then
  msg := '[Delivery Date] ' || LNGS.STR_TXT_152 || ': ' || p5 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
  bols(surl, rid_ss, c2rec.rowid, parm, action, access_id, msg);
  return;
  end;
  if to_char(c1rec.del_date, 'yyyy') like '0%'
   then
    msg := '[Delivery Date] ' || LNGS.STR_TXT_152 || ': ' || p5 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
    bols(surl, rid_ss, c2rec.rowid, parm, action, access_id, msg);
    return;
  end if;

  -- Date Validation - AQIS Clearance
  begin
  c1rec.aqis_clearance := to_date(p7,LNGS.STR_DATE_01);
  exception when others then
  msg := '[AQIS Clearance] ' || LNGS.STR_TXT_152 || ': ' || p7 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
  bols(surl, rid_ss, c2rec.rowid, parm, action, access_id, msg);
  return;
  end;
  if to_char(c1rec.aqis_clearance, 'yyyy') like '0%'
   then
    msg := '[AQIS Clearance] ' || LNGS.STR_TXT_152 || ': ' || p7 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
    bols(surl, rid_ss, c2rec.rowid, parm, action, access_id, msg);
    return;
  end if;

  msg := 'Record Inserted';
  insert into strang.bols_southbound (
        bol
       , ship
       , voyage
       , del_date
       , customs_auth_no
       , aqis_clearance
       , shipper
       , consignee
       , notifying_party)
      values (
        p1
       , c3rec.ship
       , c3rec.voyage
       , c1rec.del_date
       , P6
       , c1rec.aqis_clearance
       , p2
       , p3
       , p4);
  commit;
  open c2(p1, rid_ss);
  fetch c2 into c2rec;
  close c2;
  bols(surl, rid_ss, c2rec.rowid, parm, lngs.STR_STH_003, access_id, msg);
 elsif action = lngs.STR_STH_003 -- Update
  then
  open c2(p1, rid_ss);
  fetch c2 into c2rec;
  if c2%NOTFOUND
   then
   close c2;
   htp.init;
   htp.htmlopen;
    htp.header(3,'Southbound BOLs', 'CENTER' );
    htp.header(3,'RECORD NOT FOUND', 'CENTER' );
    htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
    htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
    htp.nl;
    htp.header(2,'Extra Information: ROWID = ' || nvl(rid_bs , 'NULL'), 'CENTER' );
   htp.htmlclose;
   bols(surl, rid_ss, c2rec.rowid, parm, action, access_id, msg);
   return;
  end if;
  close c2;
  -- Date Validation - Delivery Date
  begin
  c1rec.del_date := to_date(p5,LNGS.STR_DATE_01);
  exception when others then
  msg := '[Delivery Date] ' || LNGS.STR_TXT_152 || ': ' || p5 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
  bols(surl, rid_ss, c2rec.rowid, parm, action, access_id, msg);
  return;
  end;
  if to_char(c1rec.del_date, 'yyyy') like '0%'
   then
    msg := '[Delivery Date] ' || LNGS.STR_TXT_152 || ': ' || p5 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
    bols(surl, rid_ss, c2rec.rowid, parm, action, access_id, msg);
    return;
  end if;

  -- Date Validation - AQIS Clearance
  begin
  c1rec.aqis_clearance := to_date(p7,LNGS.STR_DATE_01);
  exception when others then
  msg := '[AQIS Clearance] ' || LNGS.STR_TXT_152 || ': ' || p7 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
  bols(surl, rid_ss, c2rec.rowid, parm, action, access_id, msg);
  return;
  end;
  if to_char(c1rec.aqis_clearance, 'yyyy') like '0%'
   then
    msg := '[AQIS Clearance] ' || LNGS.STR_TXT_152 || ': ' || p7 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
    bols(surl, rid_ss, c2rec.rowid, parm, action, access_id, msg);
    return;
  end if;

  msg := 'Record Updated';
  update strang.bols_southbound
  set  bol = P1
     , del_date = c1rec.del_date
     , customs_auth_no = P6
     , aqis_clearance = c1rec.aqis_clearance
     , shipper = P2
     , consignee = P3
     , notifying_party = P4
  where rowid = rid_bs
  ;
  commit;
  bols(surl, rid_ss, rid_bs, parm, action, access_id, msg);
  return;
 elsif action = lngs.STR_STH_007 -- Insert Another Record
  then
  bols(surl, rid_ss, rid_bs, parm, lngs.STR_STH_007, 'z', msg);
 elsif action = lngs.STR_STH_015 -- Rename
  then
  if p1 is null
   then
   msg := ('Please Enter BOL Number');
   bols(surl, rid_ss, c2rec.rowid, parm, action, access_id, msg);
   return;
  end if;
  open c1(rid_bs);
  fetch c1 into c1rec;
  close c1;
  open c2(p1, rid_ss);
  fetch c2 into c2rec;
  if c2%FOUND
     and
     c2rec.rowid <> rid_bs
   then
   close c2;
   msg := ('Record already exists: ' || c2rec.bol || '<BR>All records for BOL ' || c1rec.bol || ' will be transferred to ' || c2rec.bol || '<BR>Press [' || lngs.STR_STH_016 || '] to confirm');
   bols(surl, rid_ss, rid_bs, parm, lngs.STR_STH_016, access_id, msg, P1=>P1, P2=>P2, P3=>P3, P4=>P4);
   return;
  end if;
  close c2;
  msg := 'Record Updated';
  update strang.bols_southbound
  set  bol = P1
     , shipper = P2
     , consignee = P3
     , notifying_party = P4
  where rowid = rid_bs
  ;
  update strang.hbs_southbound set bol = P1 where bol = c1rec.bol and ship = c1rec.ship and voyage = c1rec.voyage;
  update strang.dan_details_southbound set bol = P1 where bol = c1rec.bol and ship = c1rec.ship and voyage = c1rec.voyage;
  update strang.containers_southbound set bol = P1 where bol = c1rec.bol and ship = c1rec.ship and voyage = c1rec.voyage;
  commit;
  bols(surl, rid_ss, rid_bs, parm, lngs.STR_STH_003, access_id, msg);
 elsif action = lngs.STR_STH_016 -- Confirm Rename
  then
  open c1(rid_bs );
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
   close c1;
   htp.init;
   htp.htmlopen;
    htp.header(2,'Southbound BOLs', 'CENTER' );
    htp.header(2,'RECORD NOT FOUND', 'CENTER' );
    htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
    htp.header(2,LNGS.STR_TXT_290, 'CENTER' );
    htp.nl;
    htp.header(3,'Extra Information: RID_BS = ' || rid_bs );
   htp.htmlclose;
   return;
  end if;
  close c1;
  open c2(p1, rid_ss);
  fetch c2 into c2rec;
  if c2%NOTFOUND
   then
   close c1;
   htp.init;
   htp.htmlopen;
    htp.header(2,'Southbound BOLs', 'CENTER' );
    htp.header(2,'RECORD NOT FOUND', 'CENTER' );
    htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
    htp.header(2,LNGS.STR_TXT_290, 'CENTER' );
    htp.nl;
    htp.header(3,'Extra Information: BOL = ' || P1 );
   htp.htmlclose;
   return;
  end if;
  close c2;
  msg := 'All records for BOL ' || c1rec.bol || ' merged with BOL ' || c2rec.bol;
  update strang.hbs_southbound set bol = c2rec.bol where ship = c2rec.ship and voyage = c2rec.voyage and bol = c1rec.bol;
  update strang.dan_details_southbound set bol = c2rec.bol where ship = c2rec.ship and voyage = c2rec.voyage and bol = c1rec.bol;
  update strang.containers_southbound set bol = c2rec.bol where ship = c2rec.ship and voyage = c2rec.voyage and bol = c1rec.bol;
  delete from strang.bols_southbound where rowid = rid_bs;
  update strang.bols_southbound
  set  shipper = P2
     , consignee = P3
     , notifying_party = P4
  where rowid = c2rec.rowid
  ;
  bols(surl, rid_ss, c2rec.rowid, parm, lngs.STR_STH_003, access_id, msg);
 else -- List all Records
  bols(surl, rid_ss, null, parm, lngs.STR_STH_006, 'z', msg);
 end if;

exception when others then
 glbx.error_details( 'STRANGSB', 'ACCEPT_BOLS', null, owner_id, errmsg=>sqlerrm, extdet=>'PARM:' || parm);
end accept_bols;

procedure containers(surl in varchar2, rid_ss in rowid, rid_bs rowid default null, rid_cs rowid default null, parm in varchar2, action in varchar2, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, ctrrec strang.containers_southbound%ROWTYPE default null )
is

cursor c1 (rid_bs rowid) is select * from strang.bols_southbound where rowid = rid_bs ;
cursor c2 (rid_bs rowid) is
 select lngs.STR_STH_005 tot -- List all Records
 from  strang.containers_southbound cs, strang.bols_southbound bs
 where bs.rowid = rid_bs
    and upper(cs.ship) = upper(bs.ship)
    and upper(cs.voyage) = upper(bs.voyage)
    and upper(cs.bol) = upper(bs.bol)
;
cursor c3a (rid_bs rowid) is
 select cs.*, cs.rowid
 from  strang.containers_southbound cs, strang.bols_southbound bs
 where bs.rowid = rid_bs
    and upper(cs.ship) = upper(bs.ship)
    and upper(cs.voyage) = upper(bs.voyage)
    and upper(cs.bol) = upper(bs.bol)
 order by cs.hb, cs.container_type, cs.container asc
;
cursor c3b (rid_bs rowid) is
 select cs.*, cs.rowid
 from  strang.containers_southbound cs, strang.bols_southbound bs
 where bs.rowid = rid_bs
    and upper(cs.ship) = upper(bs.ship)
    and upper(cs.voyage) = upper(bs.voyage)
    and upper(cs.bol) = upper(bs.bol)
 order by cs.container desc
;
cursor c3c(rid_cs rowid) is select cs.*, cs.rowid from strang.containers_southbound cs where rowid = rid_cs ;

cursor c4(v_state varchar2) is select description from strang.lov where lov_name = 'CONTROLS' and cola = v_state and code = 'DEFAULT CONTAINER PARK';

cursor c5 (rid_bs rowid) is
 select count(*) tot
 from  strang.containers_southbound cs, strang.bols_southbound bs
 where bs.rowid = rid_bs
    and upper(cs.ship) = upper(bs.ship)
    and upper(cs.voyage) = upper(bs.voyage)
    and upper(cs.bol) = upper(bs.bol)
;
 c1rec      c1%ROWTYPE;
 c3rec      c3a%ROWTYPE;
 c5rec      c5%ROWTYPE;
 ltype       varchar2(100);
 owner_id    integer;
 stype       integer;
 cusrec      customer_account%ROWTYPE;
 v_action    varchar2(100);
 vste        varchar2(10);
 pfx         THEME%ROWTYPE;
 vaccess     varchar2(20);
 seclevel    varchar2(100);
 sts         varchar2(100);
 name_array  owa.vc_arr;
 value_array owa.vc_arr;
 v_rid_ss    rowid;
 v_rid_bs    rowid;
 v_rid_cs    rowid;
 def_prk     c4%ROWTYPE;

procedure copy_container( from_rec in strang.containers_southbound%ROWTYPE, to_rec in out c3a%ROWTYPE )
 is
begin
 to_rec.container := from_rec.container;
 to_rec.seal := from_rec.seal;
 to_rec.marks_numbers := from_rec.marks_numbers;
 to_rec.container_type := from_rec.container_type;
 to_rec.full_mt := from_rec.full_mt;
 -- to_rec.del_date := from_rec.del_date;
 to_rec.del_transport_company := from_rec.del_transport_company;
 -- to_rec.del_truck_rego := from_rec.del_truck_rego;
 to_rec.hb := from_rec.hb;
 to_rec.container_park := from_rec.container_park;
 to_rec.strang_invoice := from_rec.strang_invoice;
 to_rec.weight := from_rec.weight;
 to_rec.volume := from_rec.volume;
 -- to_rec.customs_auth_no := from_rec.customs_auth_no;
 to_rec.snail_inspect := from_rec.snail_inspect;
 to_rec.wharf_collect := from_rec.wharf_collect;
 to_rec.aqis_depot := from_rec.aqis_depot;
 -- to_rec.aqis_clearance := from_rec.aqis_clearance;
 to_rec.secondary_transport := from_rec.secondary_transport;
 to_rec.export_vessel := from_rec.export_vessel;
 to_rec.offhired_date := from_rec.offhired_date;
 to_rec.destination := from_rec.destination;
 to_rec.cmt := from_rec.cmt;
end copy_container;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGSB.CONTAINERS' );
 if sts is not null
 then
 glbx.redisplay_login_page( sts, TRUE );
 return;
 end if;

 v_rid_ss := replace(rid_ss, '~', '+');
 v_rid_bs := replace(rid_bs, '~', '+');
 v_rid_cs := replace(rid_cs, '~', '+');
 cusrec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(cusrec.aid);
 pfx := glbx.get_thm( cusrec.theme_name );
 vaccess := strangp.data_access( owner_id, 'SHP_SB', v_rid_ss );
 seclevel := oltp.security_role( owner_id );

 open c1(v_rid_bs );
 fetch c1 into c1rec;
 if c1%NOTFOUND
 then
  htp.init;
  close c1;
  htp.htmlopen;
  htp.header(3,'Southbound BOLs', 'CENTER' );
  htp.header(3,'RECORD NOT FOUND', 'CENTER' );
  htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
  htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
  htp.nl;
  htp.header(2,'Extra Information: ROWID = ' || nvl(v_rid_bs , 'NULL'), 'CENTER' );
  htp.htmlclose;
  return;
 end if;
 close c1;

 if action = lngs.STR_STH_005 -- List all Records
 or action = lngs.STR_STH_008 -- Edit Containers
 then
  open c2 (v_rid_bs );
  fetch c2 into v_action;
  if c2%NOTFOUND
  then
   v_action := lngs.STR_STH_002; -- Insert New Record
  end if;
  close c2;
 end if;

 v_action := nvl(v_action, action);

 if action = lngs.STR_STH_004 -- Delete
 then
  name_array(1) := 'SURL';
  value_array(1) := surl;
  name_array(2) := 'RID_SS';
  value_array(2) := v_rid_ss;
  name_array(3) := 'RID_BS';
  value_array(3) := v_rid_bs ;
  name_array(4) := 'RID_CS';
  value_array(4) := v_rid_cs ;
  name_array(5) := 'PARM';
  value_array(5) := parm;
  name_array(6) := 'ACCESS_ID';
  value_array(6) := access_id;
  name_array(7) := 'ACTION';
  value_array(7) := lngs.STR_STH_004;
  accept_containers( name_array.count, name_array, value_array, name_array );
  return;
 end if; -- Delete

 glbx.main_title( surl, 'Southbound Containers',glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'STR16',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 htp.p( '<CENTER>' );

 if msg is not null
 then
  glbx.header_msg( msg );
 end if;

 if v_action in (lngs.STR_STH_005, lngs.STR_STH_008) -- List
 then

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=10 border=0' ); -- Table 1
  htp.tablerowopen;
   htp.tabledata( htf.bold('Southbound Containers'), ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
  htp.tablerowclose;

  htp.tablerowopen;
  htp.p( '<TD align="LEFT" colspan="2">' );

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border="1" ' || glbx.TABLE_BACKGROUND ); -- Table 2

   htp.tablerowopen;
    htp.tabledata( htf.bold('Ship'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.anchor('strangsb.ship?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=SHIPS&access_id=x', c1rec.ship), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" colspan="12"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Voyage'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( c1rec.voyage, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" colspan="12"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('BOL'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.anchor('strangsb.bols?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_003 || '&rid_bs=' || replace(rid_bs, '+', '~') || '&access_id=x&msg=' || msg || '&call_name=' || call_name, c1rec.bol), cattributes=>'colspan="12"');
   htp.tablerowclose;
   open c5(v_rid_bs);
   fetch c5 into c5rec;
   close c5;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Number of Containers'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( c5rec.tot, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" colspan="12"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.center(htf.bold('Containers')), cattributes=>glbx.QUERY_BACKGROUND || ' COLSPAN="13"');
   htp.tablerowclose;
   htp.tablerowopen;
--  htp.tabledata(htf.bold('No.'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Container'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Full/Empty'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Container Type'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Del Transport Co.'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Container Park'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('AQIS Depot'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('G.A.S.'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Wharf Collect'), cattributes=>glbx.QUERY_BACKGROUND);
    -- htp.tabledata(htf.bold('AQIS Clearance'), cattributes=>glbx.QUERY_BACKGROUND);
    -- htp.tabledata(htf.bold('Delivery Date'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Marks'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('HB (Empties)'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Strang Invoice (Empties)'), cattributes=>glbx.QUERY_BACKGROUND);
   htp.tablerowclose;
   htp.p(confirm_delete(script_only=>TRUE));
   for c3rec in c3a( v_rid_bs ) loop
     htp.tablerowopen;
--  htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND);
--     htp.tabledata( htf.anchor('strangsb.containers?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_003 || '&rid_bs=' || replace(rid_bs, '+', '~') || '&access_id=x&msg=' || msg || '&call_name=' || call_name, c3rec.container), cattributes=>'colspan="1"');
     htp.tabledata( htf.anchor('strangsb.containers?surl=' || surl || '&rid_ss=' || rid_ss ||'&parm=' || parm || '&action=' || lngs.STR_STH_003 || '&rid_bs=' || rid_bs || '&rid_cs=' || replace(c3rec.rowid, '+', '~') || '&access_id=x&msg=' || msg || '&call_name=' || call_name, c3rec.container), cattributes=>'colspan="1"');
     htp.tabledata( c3rec.full_mt, cattributes=>glbx.QUERY_CELL_BACKGROUND);
     htp.tabledata( c3rec.container_type, cattributes=>glbx.QUERY_CELL_BACKGROUND);
     htp.tabledata( c3rec.del_transport_company, cattributes=>glbx.QUERY_CELL_BACKGROUND);
     htp.tabledata( c3rec.container_park, cattributes=>glbx.QUERY_CELL_BACKGROUND);
     htp.tabledata( c3rec.aqis_depot, cattributes=>glbx.QUERY_CELL_BACKGROUND);
     htp.tabledata( c3rec.snail_inspect, cattributes=>glbx.QUERY_CELL_BACKGROUND);
     htp.tabledata( c3rec.wharf_collect, cattributes=>glbx.QUERY_CELL_BACKGROUND);
     -- htp.tabledata( c3rec.aqis_clearance, cattributes=>glbx.QUERY_CELL_BACKGROUND);
     -- htp.tabledata( c3rec.del_date, cattributes=>glbx.QUERY_CELL_BACKGROUND);
     htp.tabledata( c3rec.marks_numbers, cattributes=>glbx.QUERY_CELL_BACKGROUND);
     htp.tabledata( c3rec.hb, cattributes=>glbx.QUERY_CELL_BACKGROUND);
     htp.tabledata( c3rec.strang_invoice, cattributes=>glbx.QUERY_CELL_BACKGROUND);
    htp.tablerowclose;
   end loop;

  -- Submit Buttons

   htp.tablerowopen;

   htp.formopen( 'strangsb.containers' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
   htp.formhidden( 'RID_BS', replace(rid_bs ,'~','+') );
   htp.formhidden( 'RID_CS', null );
   htp.formhidden( 'PARM', 'BOLS' );
   htp.formhidden( 'ACCESS_ID', 'z' );
   htp.p('<TD VALIGN="TOP">');
   htp.formsubmit( 'ACTION', lngs.STR_STH_002 ); -- Insert
   htp.p('</TD>');
   htp.formclose;

   htp.tablerowclose;

   htp.tableclose;
   htp.p('</TD>');

  htp.tablerowclose;
  htp.tableclose; -- Table 1
  return;
 end if;

 if v_action in (lngs.STR_STH_002, lngs.STR_STH_003, lngs.STR_STH_007) -- Insert New Record | Update Record | Insert Another Record
 then
  if v_rid_cs is null   -- Default values to pre-populate fields
  then
   open c3b( v_rid_bs );
   fetch c3b into c3rec;
   close c3b;
  else
   open c3c( v_rid_cs );
   fetch c3c into c3rec;
   if v_action = lngs.STR_STH_003 -- Update Record
   and c3c%NOTFOUND
   then
    close c3c;
    htp.init;
    htp.htmlopen;
    htp.header(3,'Southbound Containers', 'CENTER' );
    htp.header(3,'RECORD NOT FOUND', 'CENTER' );
    htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
    htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
    htp.nl;
    htp.header(2,'Extra Information: ROWID = ' || nvl(v_rid_cs , 'NULL'), 'CENTER' );
    htp.htmlclose;
    return;
   end if;
   close c3c;
  end if;

  if access_id = 'e'
  then
   copy_container(ctrrec, c3rec);
  end if;

  htp.tableopen; -- Table 1
  htp.tablerowopen;
  htp.p( '<TD align="LEFT" colspan="2">' );
  htp.formopen( '!strangsb.accept_containers' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
  htp.formhidden( 'RID_BS', replace(rid_bs ,'~','+') );
  htp.formhidden( 'RID_CS', replace(rid_cs ,'~','+') );
  htp.formhidden( 'PARM', parm );
  htp.formhidden( 'ACCESS_ID', 'z' );
 -- Main Table

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border="1" ' || glbx.TABLE_BACKGROUND ); -- Table 2

  -- P_SHIP: Ship
  htp.tablerowopen;
   htp.tabledata( htf.bold('Ship'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if v_action in (lngs.STR_STH_003)
    then
     htp.tabledata( htf.formtext( 'P_SHIP', 25, 25, c1rec.ship ) || '&nbsp;' || htf.anchor('strangsb.ship?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=SHIPS&access_id=x', c1rec.ship ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   else
     htp.tabledata( htf.anchor('strangsb.ship?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=SHIPS&access_id=x', c1rec.ship ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   end if;
  htp.tablerowclose;

  -- P_VOYAGE: Voyage
  htp.tablerowopen;
   htp.tabledata( htf.bold('Voyage'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if v_action in (lngs.STR_STH_003)
    then
     htp.tabledata( htf.formtext( 'P_VOYAGE', 25, 25, c1rec.voyage ) || '&nbsp;' || htf.bold( c1rec.voyage ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   else
     htp.tabledata( htf.bold( c1rec.voyage ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   end if;
  htp.tablerowclose;

  -- BOL
  htp.tablerowopen;
   htp.tabledata( htf.bold('BOL'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.anchor('strangsb.bols?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=BOLS&action=Update Record&rid_bs=' || replace(rid_bs, '+', '~') || '&access_id=x&msg=&call_name=', c1rec.bol), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P1: Container
  htp.tablerowopen;
   htp.tabledata( htf.bold('Container'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
--   if v_action = lngs.STR_STH_003 -- Update Record
--   then
--    htp.formhidden( 'P1', c3rec.container );
--    htp.tabledata( htf.bold( c3rec.container ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
--   else
    htp.tabledata( htf.formtext( 'P1', 15, 15, c3rec.container), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
--   end if;
  htp.tablerowclose;

  -- P2: Seal
  htp.tablerowopen;
   htp.tabledata( htf.bold('Seal'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P2', 20, 20, c3rec.seal), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P3: Marks & Numbers
  htp.tablerowopen;
   htp.tabledata( htf.bold('Marks & Numbers'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P3', 30, 100, c3rec.marks_numbers), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P4: Container Type
  htp.tablerowopen;
   htp.tabledata( htf.bold('Container Type'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   -- htp.tabledata( htf.formtext( 'P4', 80, 80, c3rec.container_type), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
--   lov_list_desc( 'CONTROLS', 'P4', 'CONTAINER_TYPE', c3rec.container_type, TRUE, FALSE, TRUE );
   lov_list( 'SOUTH_CTRTYPE', 'P4', nvl(c3rec.container_type,'20FT'), FALSE, FALSE, FALSE );

   htp.p('</TD>');
  htp.tablerowclose;

  -- P5: Full or Empty
  htp.tablerowopen;
   htp.tabledata( htf.bold('Full or Empty'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    htp.formselectopen( 'P5' );
    if upper(nvl(c3rec.full_mt, 'EMPTY')) = 'FULL'
    then
     htp.formselectoption( 'Full', 'SELECTED', cattributes=>'VALUE="FULL"' );
     htp.formselectoption( 'Empty', cattributes=>'VALUE="EMPTY"' );
    else
     htp.formselectoption( 'Full', cattributes=>'VALUE="FULL"' );
     htp.formselectoption( 'Empty', 'SELECTED', cattributes=>'VALUE="EMPTY"' );
    end if;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;

  /*
  -- P6: Delivery Date and Time
  htp.tablerowopen;
   htp.tabledata( htf.bold('Delivery Date and Time'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P6', 25, 25, to_char(c3rec.del_date,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(LNGS.STR_DATE_01), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;
  */

  -- P7: Delivery Transport Company
  htp.tablerowopen;
   htp.tabledata( htf.bold('Delivery Transport Company'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P7', 30, 100, c3rec.del_transport_company), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  /*
  -- P8: Delivery Truck Rego
  htp.tablerowopen;
   htp.tabledata( htf.bold('Delivery Truck Rego'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P8', 10, 10, c3rec.del_truck_rego), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;
  */

  -- P9: HB
  if upper(nvl(c3rec.full_mt, 'FULL')) = 'EMPTY'
   then
   htp.tablerowopen;
    htp.tabledata( htf.bold('HB'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p('<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    hb_list( v_rid_bs, c3rec.hb, 'P9', FALSE, TRUE );
    htp.p('</TD>');
   htp.tablerowclose;
  end if;

  -- P10: Container Park
  open c4(vste);
  fetch c4 into def_prk;
  close c4;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Container Park'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
   then
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    lov_list( 'CTRPARKS', 'P10', nvl(c3rec.container_park, def_prk.description), FALSE, FALSE, FALSE );
    htp.p( '</TD>' );
   else
    null;
   end if;
  htp.tablerowclose;


  -- P11: Strang Invoice
  htp.tablerowopen;
   htp.tabledata( htf.bold('Strang Invoice'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P11', 30, 30, c3rec.strang_invoice), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P12: Weight
  htp.tablerowopen;
   htp.tabledata( htf.bold('Tare Weight (KG)'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P12', 10, 10, c3rec.weight), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P13: Volume
  htp.tablerowopen;
   htp.tabledata( htf.bold('Tare Volume (Cbm)'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P13', 30, 30, c3rec.volume), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  /*
  -- P14: Customs Authority Number
  htp.tablerowopen;
   htp.tabledata( htf.bold('Customs Authority no.'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P14', 30, 100, c3rec.customs_auth_no), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;
  */

  -- P15: Snail Inspected
  htp.tablerowopen;
   htp.tabledata( htf.bold('Snail Inspected'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P15', 25, 25, to_char(c3rec.snail_inspect,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(replace(LNGS.STR_DATE_01, 'HH24:MI', '[HH24:MI]')), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P16: Wharf Collect
  htp.tablerowopen;
   htp.tabledata( htf.bold('Wharf Collect'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P16', 25, 25, to_char(c3rec.wharf_collect,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(replace(LNGS.STR_DATE_01, 'HH24:MI', '[HH24:MI]')), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P17: AQIS Depot
  htp.tablerowopen;
   htp.tabledata( htf.bold('AQIS Depot'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
    then
      htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
      lov_list( 'AQISDEPOTS', 'P17', c3rec.aqis_depot, FALSE, FALSE, FALSE );
      htp.p( '</TD>' );
    else
      null;
    end if;
  htp.tablerowclose;

  -- P17a: Secondary Transport - delivering from AQIS to container park
  htp.tablerowopen;
   htp.tabledata( htf.bold('Secondary Transport'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P17a', 30, 100, c3rec.secondary_transport), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  /*
  -- P18: AQIS Clearance
  htp.tablerowopen;
   htp.tabledata( htf.bold('AQIS Clearance'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P18', 25, 25, to_char(c3rec.aqis_clearance,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(replace(LNGS.STR_DATE_01, 'HH24:MI', '[HH24:MI]')), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;
  */

  -- P19: Export Vessel
  htp.tablerowopen;
   htp.tabledata( htf.bold('Export Vessel'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P19', 30, 1000, c3rec.export_vessel), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P20: Offhired Date
  htp.tablerowopen;
   htp.tabledata( htf.bold('Offhired Date'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P20', 25, 25, to_char(c3rec.offhired_date,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(replace(LNGS.STR_DATE_01, 'HH24:MI', '[HH24:MI]')), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P21a: Destination [Select]
   htp.tablerowopen;
    htp.tabledata( htf.bold('Place of Delivery'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
    then
      htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
      lov_list( 'LOCATIONS', 'P21A', c3rec.destination, FALSE, TRUE, FALSE );
      htp.p( '</TD>' );
    else
      null;
    end if;
   htp.tablerowclose;


  -- P22: Comment
  htp.tablerowopen;
   htp.tabledata( htf.bold('Comment'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P22', 60, 1000, c3rec.cmt), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  htp.tableclose; -- Table 2
  htp.p('</TD>');
  htp.tablerowclose;

 -- Submit Buttons

  htp.tablerowopen;
  htp.p('<TD VALIGN="TOP" COLSPAN="2">');
  if v_action = lngs.STR_STH_003 -- Update Record
  then
   htp.formsubmit( 'ACTION', lngs.STR_STH_003 ); -- Update Record
   htp.p('&nbsp;');
   htp.p( confirm_delete ( 'ACTION', lngs.STR_STH_004, 'Delete ' || c3rec.container || ': Are you sure?' )); -- Delete
   htp.p('&nbsp;');
   htp.formsubmit( 'ACTION', lngs.STR_STH_007 ); -- Insert Another Record
   htp.p('&nbsp;');
   htp.formsubmit( 'ACTION', lngs.STR_STH_011 ); -- Cancel
  else
   htp.formsubmit( 'ACTION', lngs.STR_STH_002 ); -- Insert
  end if;
  htp.p('&nbsp;');
  htp.formsubmit( 'ACTION', lngs.STR_STH_005 ); -- List All Records
  htp.p('</TD>');

  htp.tablerowclose;
  htp.formclose;

  htp.tablerowopen;

  htp.formopen( 'strangsb.hbs' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'PARM', 'HBS' );
  htp.formhidden( 'ACCESS_ID', 'z' );
  htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
  htp.formhidden( 'RID_BS', replace(rid_bs ,'~','+') );

  htp.p('<TD VALIGN="TOP">');
  htp.formsubmit( 'ACTION', lngs.STR_STH_012 ); -- Edit HBs
  htp.p('</TD>');
  htp.formclose;

  if upper(nvl(c3rec.full_mt, 'EMPTY')) = 'FULL'
   then
    htp.formopen( 'strangsb.dans' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'PARM', 'DANS' );
    htp.formhidden( 'ACCESS_ID', 'z' );
    htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
    htp.formhidden( 'RID_BS', replace(rid_bs,'~','+') );
    htp.formhidden( 'RID_CS', replace(rid_cs,'~','+') );

    htp.p('<TD VALIGN="TOP">');
    htp.formsubmit( 'ACTION', lngs.STR_STH_009 ); -- Edit DANs
    htp.p('</TD>');
    htp.formclose;
  end if;

  htp.tablerowclose;
  htp.tableclose; -- Table 1

 end if;

exception when others then
 glbx.error_details( 'STRANGSB', 'CONTAINERS',null,null,errmsg=>sqlerrm,extdet=>'RID_SS:' || v_rid_ss || '; RID_BS: ' || v_rid_bs || '; RID_CS: ' || v_rid_cs );
end containers;

procedure accept_containers( num_entries in number, name_array in owa.vc_arr, value_array in owa.vc_arr, reserved in owa.vc_arr )
 is

cursor c1 (rid_cs rowid) is select cs.*, cs.rowid from strang.containers_southbound cs where rowid = rid_cs;
cursor c2 (rid_bs rowid) is select * from strang.bols_southbound where rowid = rid_bs;
cursor c3 (rid_bs rowid, ctr varchar2) is
 select cs.rowid
 from  strang.containers_southbound cs, strang.bols_southbound bs
 where upper(cs.container) = upper(ctr)
    and upper(cs.ship) = upper(bs.ship)
    and upper(cs.voyage) = upper(bs.voyage)
    and upper(cs.bol) = upper(bs.bol)
    and bs.rowid = rid_bs
;
cursor c4 (rid_cs rowid) is
 select ds.*
 from  strang.dan_details_southbound ds, strang.containers_southbound cs
 where cs.rowid = rid_cs
    and upper(ds.ship) = upper(cs.ship)
    and upper(ds.voyage) = upper(cs.voyage)
    and upper(ds.container) = upper(cs.container)
    and ds.container is not null
;

cursor c5 (rid_ss rowid) is select * from strang.ships_southbound where rowid = rid_ss;

cursor c6 (v_ctr varchar2, v_dte date) is
 select *
 from   strang.containers
 where  upper(replace(replace(trim(containerno), ' ', ''), '-', '')) = upper(replace(replace(trim(v_ctr), ' ', ''), '-', ''))
        and trunc(datehired) <= v_dte
        and trunc(offdate + 1) >= v_dte
;

cursor c7(v_ship varchar2, v_voy varchar2, v_cntr varchar2) is
 select *
 from   strang.containers_southbound
 where  ship = v_ship
        and voyage = v_voy
        and container = v_cntr
;

cursor c8(v_bol varchar2, v_ship varchar2, v_voy varchar2) is
 select bs.*, bs.rowid
 from   strang.bols_southbound bs
 where  ship = v_ship
        and voyage = v_voy
        and bol = v_bol
;

cursor c9(v_bol varchar2, v_hb varchar2, v_ship varchar2, v_voy varchar2) is
 select *
 from   strang.hbs_southbound
 where  ship = v_ship
        and voyage = v_voy
        and bol = v_bol
        and house_bill = v_hb
;

cursor c10(v_ship varchar2, v_voy varchar2) is
 select ss.*, ss.rowid
 from   strang.ships_southbound ss
 where  ship = v_ship
        and voyage = v_voy
;

 c1rec   c1%ROWTYPE;
 c2rec   c2%ROWTYPE;
 c3rec   c3%ROWTYPE;
 c4rec   c4%ROWTYPE;
 c5rec   c5%ROWTYPE;
 c6rec   c6%ROWTYPE;
 c7rec   c7%ROWTYPE;
 c8rec   c8%ROWTYPE;
 c9rec   c9%ROWTYPE;
 c10rec  c10%ROWTYPE;
 ctrrec  strang.containers_southbound%ROWTYPE;
 owner_id integer;
 ltype   varchar2(100);
 stype   integer;
 sts    varchar2(100);
 surl   varchar2(100);
 rid_ss    rowid;
 rid_bs    rowid;
 rid_cs    rowid;
 parm   varchar2(100);
 access_id varchar2(100);
 action  varchar2(100);
 msg    varchar2(4000);
 stp    varchar2(100);

begin

 for j in name_array.first..name_array.last loop
  stp := 'On: [' || name_array(j) || '] ' || value_array(j);
  case upper(name_array(j))
  when 'SURL' then surl := value_array(j);
  when 'RID_SS' then rid_ss := value_array(j);
  when 'RID_BS' then rid_bs := value_array(j);
  when 'RID_CS' then rid_cs := value_array(j);
  when 'PARM' then parm := value_array(j);
  when 'ACCESS_ID' then access_id := value_array(j);
  when 'ACTION' then action := value_array(j);
  else null;
  end case;
 end loop;

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGSB.ACCEPT_CONTAINERS' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 open c2( rid_bs );
 fetch c2 into c2rec;
 if c2%NOTFOUND
  then
  htp.init;
  close c2;
  htp.htmlopen;
   htp.header(3,'Southbound BOLs', 'CENTER' );
   htp.header(3,'RECORD NOT FOUND', 'CENTER' );
   htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
   htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
   htp.nl;
   htp.header(2,'Extra Information: ROWID = ' || nvl(rid_bs , 'NULL'), 'CENTER' );
  htp.htmlclose;
  return;
 end if;
 close c2;

 if action = lngs.STR_STH_005 -- List All Records
  then
  containers(surl, rid_ss, rid_bs, null, 'CONTAINER', lngs.STR_STH_005, 'z', null);
  return;
 elsif action = lngs.STR_STH_007 -- Insert Another Record
  then
  containers(surl, rid_ss, rid_bs, rid_cs, 'CONTAINER', lngs.STR_STH_007, 'z', null);
  return;
 elsif action = lngs.STR_STH_011 -- Cancel
  then
  containers(surl, rid_ss, rid_bs, rid_cs, 'CONTAINER', lngs.STR_STH_003, 'x', null);
  return;
 end if;

 ctrrec.ship := c2rec.ship;
 ctrrec.voyage := c2rec.voyage;
 ctrrec.bol := c2rec.bol;

 if action = lngs.STR_STH_004 -- Delete
  then
  open c1 (rid_cs );
  fetch c1 into c1rec;
  open c4 (rid_cs);
  fetch c4 into c4rec;
  if c1%NOTFOUND
   then
   close c1;
   htp.init;
   htp.htmlopen;
    htp.header(3,'Southbound Containers', 'CENTER' );
    htp.header(3,'RECORD NOT FOUND', 'CENTER' );
    htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
    htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
    htp.nl;
    htp.header(2,'Extra Information: ROWID = ' || nvl(rid_cs , 'NULL'), 'CENTER' );
   htp.htmlclose;
   return;
  elsif c4%FOUND
   then
    close c4;
    msg := 'Delete DANs first';
    containers(surl, rid_ss, rid_bs, rid_cs, 'CONTAINER', lngs.STR_STH_003, 'x', msg);
    return;
  else
   close c1;
   close c4;
   msg := 'Container [' || c1rec.container || '] DELETED';
   delete from strang.containers_southbound where rowid = c1rec.rowid;
   commit;
   containers(surl, rid_ss, rid_bs, null, 'CONTAINER', lngs.STR_STH_005, 'x', msg);
   return;
  end if;
 end if;

 for j in name_array.first..name_array.last loop
  stp := 'On: [' || name_array(j) || '] ' || value_array(j);
  case upper(name_array(j))
  when'P_SHIP' then ctrrec.ship := upper(trim(value_array(j)));
  when 'P_VOYAGE' then ctrrec.voyage := upper(trim(value_array(j)));
  when 'P1' then ctrrec.container := value_array(j);
  when 'P2' then ctrrec.seal := value_array(j);
  when 'P3' then ctrrec.marks_numbers := value_array(j);
  when 'P4' then ctrrec.container_type := value_array(j);
  when 'P5' then ctrrec.full_mt := value_array(j);
  /*
  when 'P6'
   then
    -- Date Validation
    begin
    ctrrec.del_date := to_date(value_array(j),LNGS.STR_DATE_01);
    exception when others then
    msg := msg || '[Delivery Date] ' || LNGS.STR_TXT_152 || ': ' || value_array(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
    end;
    if to_char(ctrrec.del_date, 'yyyy') like '0%'
     then
      msg := msg || '[Delivery Date] ' || LNGS.STR_TXT_152 || ': ' || value_array(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
    end if;
  */
  when 'P7' then ctrrec.del_transport_company := value_array(j);
  -- when 'P8' then ctrrec.del_truck_rego := value_array(j);
  when 'P9' then ctrrec.hb := value_array(j);
  when 'P10' then ctrrec.container_park := value_array(j);
  when 'P11' then ctrrec.strang_invoice := value_array(j);
  when 'P12'
   then
   -- Number Validation
   begin
    ctrrec.weight := to_number(value_array(j));
   exception when others then
    msg := msg || '[Weight] ' || LNGS.STR_STH_010 || ': ' || value_array(j) || '<BR>';
   end;
  when 'P13'
   then
   -- Number Validation
   begin
    ctrrec.volume := to_number(value_array(j));
   exception when others then
    msg := msg || '[Volume] ' || LNGS.STR_STH_010 || ': ' || value_array(j) || '<BR>';
   end;
  -- when 'P14' then ctrrec.customs_auth_no := value_array(j);
  when 'P15'
   then
    -- Date Validation
    begin
    ctrrec.snail_inspect := to_date(value_array(j),LNGS.STR_DATE_01);
    exception when others then
    msg := msg || '[Snail Inspected] ' || LNGS.STR_TXT_152 || ': ' || value_array(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
    end;
    if to_char(ctrrec.snail_inspect, 'yyyy') like '0%'
     then
      msg := msg || '[Snail Inspected] ' || LNGS.STR_TXT_152 || ': ' || value_array(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
    end if;
  when 'P16'
   then
    -- Date Validation
    begin
    ctrrec.wharf_collect := to_date(value_array(j),LNGS.STR_DATE_01);
    exception when others then
    msg := msg || '[Wharf Collect] ' || LNGS.STR_TXT_152 || ': ' || value_array(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
    end;
    if to_char(ctrrec.wharf_collect, 'yyyy') like '0%'
     then
      msg := msg || '[Wharf Collect] ' || LNGS.STR_TXT_152 || ': ' || value_array(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
    end if;
  when 'P17' then ctrrec.aqis_depot := value_array(j);
  when 'P17A' then ctrrec.secondary_transport := value_array(j);
  /*
  when 'P18'
   then
    -- Date Validation
    begin
    ctrrec.aqis_clearance := to_date(value_array(j),LNGS.STR_DATE_01);
    exception when others then
    msg := msg || '[AQIS Clearance] ' || LNGS.STR_TXT_152 || ': ' || value_array(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
    end;
    if to_char(ctrrec.aqis_clearance, 'yyyy') like '0%'
     then
      msg := msg || '[AQIS Clearance] ' || LNGS.STR_TXT_152 || ': ' || value_array(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
    end if;
  */
  when 'P19' then ctrrec.export_vessel := value_array(j);
  when 'P20' then
    -- Date Validation
    begin
    ctrrec.offhired_date := to_date(value_array(j),LNGS.STR_DATE_01);
    exception when others then
    msg := msg || '[Offhired Date] ' || LNGS.STR_TXT_152 || ': ' || value_array(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
    end;
    if to_char(ctrrec.offhired_date, 'yyyy') like '0%'
     then
      msg := msg || '[Offhired Date] ' || LNGS.STR_TXT_152 || ': ' || value_array(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
    end if;
  when 'P21A' then ctrrec.destination :=  value_array(j);
  when 'P22' then ctrrec.cmt := value_array(j);
  else null;
  end case;
 end loop;

 if ctrrec.offhired_date is null -- Set Offhired Date
  then
   open c5 (rid_ss);
   fetch c5 into c5rec;
   if c5%FOUND
    then
     open c6(ctrrec.container, c5rec.sailing_date);
     fetch c6 into c6rec;
     if c6%FOUND
      then
       ctrrec.offhired_date := c6rec.offdate;
     end if;
     close c6;
   end if;
   close c5;
 end if;

 if nvl(upper(ctrrec.full_mt), 'EMPTY') = 'FULL'
  then
  ctrrec.hb := null;
  if ctrrec.seal is null
   then
   msg := msg || 'Seal mandatory for full container<BR>';
  end if;
 elsif nvl(upper(ctrrec.full_mt), 'FULL') = 'EMPTY'  -- Check for DANs
  then
   open c4 (rid_cs);
   fetch c4 into c4rec;
   if c4%FOUND
    then
     msg := msg || 'Delete DANs before setting to Empty<BR>';
     ctrrec.full_mt := 'FULL';
   end if;
   close c4;
 end if;

 if action = lngs.STR_STH_002 -- Insert New Record
  then

  if ctrrec.container is null
   then
   msg := msg || 'Please Enter Container Number<BR>';
  else -- Check for existing Container number
   open c3 (rid_bs , trim(ctrrec.container));
   fetch c3 into c3rec;
   if c3%FOUND
    then
    msg := msg || 'Record already exists for container [' || ctrrec.container || ']<BR>';
   end if;
   close c3;
  end if;

  if msg is not null
   then
   containers(surl, rid_ss, rid_bs , null, 'CONTAINER', lngs.STR_STH_002, 'e', msg, ctrrec=>ctrrec );
   return;
  end if;

  insert into strang.containers_southbound values ctrrec returning rowid into rid_cs ;

  commit;

  open c3 (rid_bs , ctrrec.container);
  fetch c3 into c3rec;
  close c3;

  containers(surl, rid_ss, rid_bs, rid_cs, 'CONTAINER', lngs.STR_STH_003, 'x', 'Record Inserted');

 elsif action = lngs.STR_STH_003 -- Update Record
  then

  open c1( rid_cs );
  fetch c1 into c1rec;
  close c1;

  if ctrrec.container is null
   then
   msg := msg || 'Please Enter Container Number<BR>';
   ctrrec.container := c1rec.container;
  else -- Check for existing Container number
   open c3 (rid_bs , trim(ctrrec.container));
   fetch c3 into c3rec;
   if c3%FOUND
      and c1rec.container <> ctrrec.container
    then
    msg := msg || 'Record already exists for container [' || ctrrec.container || ']<BR>';
    ctrrec.container := c1rec.container;
   end if;
   close c3;
  end if;

  if ctrrec.ship <> c1rec.ship
     or ctrrec.voyage <> c1rec.voyage
   then
    open c7(ctrrec.ship, ctrrec.voyage, c1rec.container);
    fetch c7 into c7rec;
    if c7%FOUND
     then
      msg := msg || 'Record already exists for container [' || ctrrec.container || '] on Ship/Voyage ' || ctrrec.ship || '/' || ctrrec.voyage || '<BR>';
    end if;
    close c7;
    open c10(ctrrec.ship, ctrrec.voyage);
    fetch c10 into c10rec;
    if c10%NOTFOUND
     then
      msg := msg || 'Ship/Voyage does  not exist: ' || ctrrec.ship || '/' || ctrrec.voyage || '<BR>';
    end if;
    close c10;
    if msg is null
     then
      open c8(c2rec.bol, ctrrec.ship, ctrrec.voyage);
      fetch c8 into c8rec;
      if c8%NOTFOUND
       then
        c2rec.ship := ctrrec.ship;
        c2rec.voyage := ctrrec.voyage;
        insert into strang.bols_southbound values c2rec returning rowid into rid_bs;
      else
        rid_bs := c8rec.rowid;
      end if;
      close c8;
      if ctrrec.hb is not null
       then
        open c9(c2rec.bol, ctrrec.hb, ctrrec.ship, ctrrec.voyage);
        fetch c9 into c9rec;
        if c9%NOTFOUND
         then
          close c9;
          open c9(c2rec.bol, c1rec.hb, c1rec.ship, c1rec.voyage);
          fetch c9 into c9rec;
          close c9;
          c9rec.ship := ctrrec.ship;
          c9rec.voyage := ctrrec.voyage;
          insert into strang.hbs_southbound values c9rec;
        end if;
        close c9;
      end if;
      update strang.dan_details_southbound
      set    ship = ctrrec.ship
           , voyage = ctrrec.voyage
      where  ship = c1rec.ship
             and voyage = c1rec.voyage
             and container = c1rec.container
      ;
      rid_ss := c10rec.rowid;
    else
      ctrrec.ship := c1rec.ship;
      ctrrec.voyage := c1rec.voyage;
    end if;
  end if;

  if msg is not null
   then
   containers(surl, rid_ss, rid_bs, rid_cs, 'CONTAINER', lngs.STR_STH_003, 'e', msg, ctrrec=>ctrrec);
   return;
  end if;

  update strang.containers_southbound set row=ctrrec where rowid=rid_cs ;
  commit;
  containers(surl, rid_ss, rid_bs, rid_cs, 'CONTAINER', lngs.STR_STH_003, 'x', 'Record Updated');
 end if;

exception when others then
 glbx.error_details( 'STRANGSB', 'ACCEPT_CONTAINERS',null,null,errmsg=>sqlerrm,extdet=>stp );
end accept_containers;

procedure containers_mass(surl in varchar2, rid_ss in rowid, rid_bs rowid default null, parm in varchar2, action in varchar2, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null )
is

cursor c1 ( rid_ss rowid, rid_bs rowid ) is
 select distinct cs.rowid, cs.*
 from  strang.containers_southbound cs, strang.ships_southbound ss, strang.bols_southbound bs
 where ss.rowid = rid_ss
       and upper(cs.ship) = upper(ss.ship)
       and upper(cs.voyage) = upper(ss.voyage)
       and ( rid_bs is null
             or
             ( rid_bs is not null
               and bs.rowid = rid_bs
               and bs.bol = cs.bol
             )
           )
 order  by cs.bol, cs.container
 ;

 ltype       varchar2(100);
 owner_id    integer;
 stype       integer;
 sts         varchar2(100);
 v_rid_cs    owa.vc_arr;
 v1          owa.vc_arr;
 v2          owa.vc_arr;
 v3          owa.vc_arr;
 v4          owa.vc_arr;
 v5          owa.vc_arr;
 v6          owa.vc_arr;
 v7          owa.vc_arr;
 -- v8          owa.vc_arr; -- Delivery Date
 v9          owa.vc_arr;
 -- v10         owa.vc_arr; -- Delivery Truck Rego
 v11         owa.vc_arr;
 v12         owa.vc_arr;
 v13         owa.vc_arr;
 v14         owa.vc_arr;
 -- v15         owa.vc_arr; -- Customs Authority Number
 v16         owa.vc_arr;
 v17         owa.vc_arr;
 v18         owa.vc_arr;
 v19         owa.vc_arr;
 -- v20         owa.vc_arr; -- AQIS Clearance
 -- v21         owa.vc_arr; -- Export Vessel
 v22         owa.vc_arr;
 v23         owa.vc_arr;
 v24         owa.vc_arr;
 errmsg      owa.vc_arr;
 v_rid_ss    rowid;
 v_rid_bs    rowid;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGSB.CONTAINERS_MASS' );
 if sts is not null
 then
 glbx.redisplay_login_page( sts, TRUE );
 return;
 end if;

 v_rid_ss := replace(rid_ss, '~', '+');
 v_rid_bs := replace(rid_bs, '~', '+');

 for c1rec in c1( v_rid_ss, v_rid_bs ) loop
  v_rid_cs(c1%ROWCOUNT) := replace(c1rec.rowid, '+', '~');
  v1(c1%ROWCOUNT) := c1rec.bol;
  v2(c1%ROWCOUNT) := c1rec.container;
  v3(c1%ROWCOUNT) := c1rec.hb;
  v4(c1%ROWCOUNT) := c1rec.seal;
  v5(c1%ROWCOUNT) := c1rec.marks_numbers;
  v6(c1%ROWCOUNT) := c1rec.container_type;
  v7(c1%ROWCOUNT) := c1rec.full_mt;
  -- v8(c1%ROWCOUNT) := to_char(c1rec.del_date,LNGS.STR_DATE_01);
  v9(c1%ROWCOUNT) := c1rec.del_transport_company;
  -- v10(c1%ROWCOUNT) := c1rec.del_truck_rego;
  v11(c1%ROWCOUNT) := c1rec.container_park;
  v12(c1%ROWCOUNT) := c1rec.strang_invoice;
  v13(c1%ROWCOUNT) := c1rec.weight;
  v14(c1%ROWCOUNT) := c1rec.volume;
  -- v15(c1%ROWCOUNT) := c1rec.customs_auth_no;
  v16(c1%ROWCOUNT) := to_char(c1rec.snail_inspect,LNGS.STR_DATE_01);
  v17(c1%ROWCOUNT) := to_char(c1rec.wharf_collect,LNGS.STR_DATE_01);
  v18(c1%ROWCOUNT) := c1rec.aqis_depot;
  v19(c1%ROWCOUNT) := c1rec.secondary_transport;
  -- v20(c1%ROWCOUNT) := to_char(c1rec.aqis_clearance,LNGS.STR_DATE_01);
  -- v21(c1%ROWCOUNT) := c1rec.export_vessel;
  v22(c1%ROWCOUNT) := to_char(c1rec.offhired_date,LNGS.STR_DATE_01);
  v23(c1%ROWCOUNT) := c1rec.destination;
  v24(c1%ROWCOUNT) := c1rec.cmt;
  errmsg(c1%ROWCOUNT) := null;
 end loop;

 if v1.count > 0
  then
   containers_mass_update(surl, v_rid_ss, v_rid_bs, parm, action, v_rid_cs, v1, v2, v3, v4, v5, v6, v7, v9, v11, v12, v13, v14, v16, v17, v18, v19, v22, v23, v24, errmsg, access_id, msg, call_name);
 else
  null;
 end if;

exception when others then
 glbx.error_details( 'STRANGSB', 'CONTAINERS_MASS',null,null,errmsg=>sqlerrm );
end containers_mass;

procedure containers_mass_update(surl in varchar2
                               , rid_ss in rowid
                               , rid_bs rowid default null
                               , parm in varchar2
                               , action in varchar2
                               , v_rid_cs in owa.vc_arr
                               , v1 in owa.vc_arr
                               , v2 in owa.vc_arr
                               , v3 in out owa.vc_arr
                               , v4 in out owa.vc_arr
                               , v5 in out owa.vc_arr
                               , v6 in out owa.vc_arr
                               , v7 in out owa.vc_arr
                               , v9 in out owa.vc_arr
                               , v11 in out owa.vc_arr
                               , v12 in out owa.vc_arr
                               , v13 in out owa.vc_arr
                               , v14 in out owa.vc_arr
                               , v16 in out owa.vc_arr
                               , v17 in out owa.vc_arr
                               , v18 in out owa.vc_arr
                               , v19 in out owa.vc_arr
                               , v22 in out owa.vc_arr
                               , v23 in out owa.vc_arr
                               , v24 in out owa.vc_arr
                               , errmsg in out owa.vc_arr
                               , access_id in varchar2 default null
                               , msg in varchar2 default null
                               , call_name in varchar2 default null )
is

 cursor c1( rid_ss ROWID ) is select * from strang.ships_southbound where rowid = rid_ss;

 cursor c2( rid_cs ROWID ) is
  select bs.rowid
  from   strang.bols_southbound bs, strang.containers_southbound cs
  where  cs.rowid = rid_cs
         and upper(cs.ship) = upper(bs.ship)
         and upper(cs.voyage) = upper(bs.voyage)
         and upper(cs.bol) = upper(bs.bol)
 ;

 c1rec       c1%ROWTYPE;
 ltype       varchar2(100);
 owner_id    integer;
 stype       integer;
 cusrec      customer_account%ROWTYPE;
 v_action    varchar2(100);
 vste        varchar2(10);
 pfx         THEME%ROWTYPE;
 vaccess     varchar2(20);
 seclevel    varchar2(100);
 sts         varchar2(100);
 v_rid_ss    rowid;
 v_rid_bs    rowid;
 v_rid_bs_1  rowid;
 stp         varchar2(1000);
 err_txt     varchar2(1000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGSB.CONTAINERS_MASS' );
 if sts is not null
 then
 glbx.redisplay_login_page( sts, TRUE );
 return;
 end if;

 v_rid_ss := replace(rid_ss, '~', '+');
 v_rid_bs := replace(rid_bs, '~', '+');
 cusrec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(cusrec.aid);
 pfx := glbx.get_thm( cusrec.theme_name );
 vaccess := strangp.data_access( owner_id, 'SHP_SB', v_rid_ss );
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'Southbound Containers',glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'STR16',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 htp.p( '<CENTER>' );

 if msg is not null
 then
  glbx.header_msg( msg );
 end if;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=10 border=0' ); -- Table 1
  htp.formopen('strangsb.accept_containers_mass_update');

  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'RID_SS', replace(v_rid_ss,'~','+') );
  htp.formhidden( 'RID_BS', replace(v_rid_bs ,'~','+') );
  htp.formhidden( 'PARM', parm );
  htp.formhidden( 'ACCESS_ID', access_id );
  htp.formhidden( 'CALL_NAME', call_name );

  htp.tablerowopen;
   htp.tabledata( htf.bold('Southbound Containers'), ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
  htp.tablerowclose;

  htp.tablerowopen;
  htp.p( '<TD align="LEFT" colspan="2">' );

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border="1" ' || glbx.TABLE_BACKGROUND ); -- Table 2

   open c1(v_rid_ss);
   fetch c1 into c1rec;
   close c1;

   htp.tablerowopen;
    htp.tabledata( htf.bold('Ship'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.anchor('strangsb.ship?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=SHIPS&access_id=x', c1rec.ship), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" colspan="12"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Voyage'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( c1rec.voyage, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" colspan="12"');
   htp.tablerowclose;

   htp.tablerowopen;
    htp.tabledata( htf.bold('Number of Containers'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( v1.count, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" colspan="12"');
   htp.tablerowclose;

   htp.tablerowopen;
    htp.tabledata(htf.bold('Bol'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Container'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('House Bills'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Seal'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Marks & Numbers'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Container Type'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Full or Empty'), cattributes=>glbx.QUERY_BACKGROUND);
    -- htp.tabledata(htf.bold('Delivery Date/time'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Delivery Company'), cattributes=>glbx.QUERY_BACKGROUND);
    -- htp.tabledata(htf.bold('Delivery Truck rego'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Container Park'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Strang Invoice'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Tare Weight kg'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Tare Volume cbm'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Bol'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Container'), cattributes=>glbx.QUERY_BACKGROUND);
    -- htp.tabledata(htf.bold('Customs Authority no'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Snail Inspected'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Wharf Collect'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Aqis Depot'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Secondary Transport'), cattributes=>glbx.QUERY_BACKGROUND);
    -- htp.tabledata(htf.bold('Aqis Clearance'), cattributes=>glbx.QUERY_BACKGROUND);
    -- htp.tabledata(htf.bold('Export Vessel'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Offhired Date'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Place Of Delivery'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Comment'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Message'), cattributes=>glbx.QUERY_BACKGROUND);
   htp.tablerowclose;

   for j in v1.first..v1.last loop
    htp.formhidden('V_RID_CS', v_rid_cs(j));
    htp.tablerowopen;
     if errmsg(j) is not null
      then
       err_txt := 'style="color:RED;"';
     else
       err_txt := null;
     end if;
     -- BOL
     if v_rid_bs is null
      then
       open c2(replace(v_rid_cs(j), '~', '+'));
       fetch c2 into v_rid_bs_1;
       close c2;
     else
       v_rid_bs_1 := v_rid_bs;
     end if;
     htp.formhidden( 'V1', v1(j) );
     htp.tabledata( htf.anchor('strangsb.bols?surl=' || surl || '&rid_ss=' || rid_ss || '&parm=BOLS&action=Update Record&rid_bs=' || replace(v_rid_bs_1, '+', '~') || '&access_id=x&msg=&call_name=', htf.bold(v1(j))), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
     -- Container
     htp.formhidden( 'V2', v2(j) );
     htp.tabledata( htf.anchor('strangsb.containers?surl=' || surl || '&rid_ss=' || rid_ss ||'&parm=' || parm || '&action=' || lngs.STR_STH_003 || '&rid_bs=' || replace(v_rid_bs_1, '+', '~') || '&rid_cs=' || v_rid_cs(j) || '&access_id=x&msg=&call_name=' || call_name, htf.bold(v2(j)), cattributes=>err_txt), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');

     -- House Bill
     if upper(nvl(v7(j), 'FULL')) = 'EMPTY'
      then
       htp.p('<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
       hb_list( v_rid_bs_1, v3(j), 'V3', FALSE, TRUE );
       htp.p('</TD>');
     else
       htp.tabledata( htf.formhidden( 'V3', null ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
     -- Seal
     htp.tabledata( htf.formtext( 'V4',8,15,v4(j)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     -- Marks & Numbers
     htp.tabledata( htf.formtext( 'V5',8,15,v5(j)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     -- Container Type
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
       lov_list( 'SOUTH_CTRTYPE', 'V6', nvl(v6(j),'20FT'), FALSE, FALSE, FALSE );
     htp.p('</TD>');
     -- Full/Empty
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
      htp.formselectopen( 'V7' );
      if upper(nvl(v7(j), 'EMPTY')) = 'FULL'
      then
       htp.formselectoption( 'Full', 'SELECTED', cattributes=>'VALUE="FULL"' );
       htp.formselectoption( 'Empty', cattributes=>'VALUE="EMPTY"' );
      else
       htp.formselectoption( 'Full', cattributes=>'VALUE="FULL"' );
       htp.formselectoption( 'Empty', 'SELECTED', cattributes=>'VALUE="EMPTY"' );
      end if;
     htp.formselectclose;
     htp.p( '</TD>' );
     -- Delivery Date
     -- htp.tabledata( htf.formtext( 'V8',10,25,to_char(to_date(v8(j),LNGS.STR_DATE_01),LNGS.STR_DATE_03)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     -- Delivery Co.
     htp.tabledata( htf.formtext( 'V9',15,15,v9(j)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     -- Delivery Truck Rego
     -- htp.tabledata( htf.formtext( 'V10',8,15,v10(j)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     -- Container Park
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
      lov_list( 'CTRPARKS', 'V11', v11(j), FALSE, FALSE, FALSE );
     htp.p( '</TD>' );
     -- Strang Invoice
     htp.tabledata( htf.formtext( 'V12',8,15,v12(j)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     -- TARE Weight
     htp.tabledata( htf.formtext( 'V13',8,15,v13(j)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     -- TARE Volume
     htp.tabledata( htf.formtext( 'V14',8,15,v14(j)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');

     -- BOL (Repeated)
     htp.tabledata( htf.anchor('strangsb.bols?surl=' || surl || '&rid_ss=' || rid_ss || '&parm=BOLS&action=Update Record&rid_bs=' || replace(v_rid_bs_1, '+', '~') || '&access_id=x&msg=&call_name=', htf.bold(v1(j))), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
     -- Container (Repeated)
     htp.tabledata( htf.anchor('strangsb.containers?surl=' || surl || '&rid_ss=' || rid_ss ||'&parm=' || parm || '&action=' || lngs.STR_STH_003 || '&rid_bs=' || replace(v_rid_bs_1, '+', '~') || '&rid_cs=' || v_rid_cs(j) || '&access_id=x&msg=&call_name=' || call_name, htf.bold(v2(j)), cattributes=>err_txt), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');

     -- Customs Authority No.
     -- htp.tabledata( htf.formtext( 'V15',15,15,v15(j)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     -- SNAIL Inspected Date
     htp.tabledata( htf.formtext( 'V16',10,25,to_char(to_date(v16(j),LNGS.STR_DATE_01),LNGS.STR_DATE_03)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     -- Wharf Collect Date
     htp.tabledata( htf.formtext( 'V17',10,25,to_char(to_date(v17(j),LNGS.STR_DATE_01),LNGS.STR_DATE_03)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     -- AQIS Depot
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'AQISDEPOTS', 'V18', v18(j), FALSE, FALSE, FALSE );
     htp.p( '</TD>' );
     -- Secondary Transport
     htp.tabledata( htf.formtext( 'V19',15,15,v19(j)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     -- AQIS Clearance
     -- htp.tabledata( htf.formtext( 'V20',15,15,to_char(to_date(v20(j),LNGS.STR_DATE_01),LNGS.STR_DATE_03)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     -- Export Vessel
     -- htp.tabledata( htf.formtext( 'V21',8,15,v21(j)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     -- Offhired Date
     htp.tabledata( htf.formtext( 'V22',10,25,to_char(to_date(v22(j),LNGS.STR_DATE_01),LNGS.STR_DATE_03)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     -- Place of Delivery
      htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
      lov_list( 'LOCATIONS', 'V23', v23(j), FALSE, TRUE, FALSE );
      htp.p( '</TD>' );
     -- Comment
     htp.tabledata( htf.formtext( 'V24',60,1000,v24(j)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     -- Error Message
     -- htp.formhidden( 'ERRMSG', errmsg(j));
     htp.tabledata( errmsg(j) );
    htp.tablerowclose;
   end loop;

  htp.tableclose; -- Table 2
  htp.p('</TD>');
  htp.tablerowclose;

 -- Submit Buttons

  htp.tablerowopen;
  htp.p('<TD VALIGN="TOP" COLSPAN="2">');
   htp.formsubmit( 'ACTION', lngs.STR_TXT_358 ); -- Modify Values
   htp.p('&nbsp;');
   htp.formsubmit( 'ACTION', lngs.STR_STH_011 ); -- Cancel
   htp.p('&nbsp;');
  htp.p('</TD>');

  htp.tablerowclose;

  htp.formclose;
  htp.tableclose; -- Table 1

exception when others then
 glbx.error_details( 'STRANGSB', 'CONTAINERS_MASS_UPDATE',null,null,errmsg=>sqlerrm,extdet=>stp );
end containers_mass_update;

procedure accept_containers_mass_update( surl in varchar2
                                       , rid_ss in rowid
                                       , rid_bs in rowid
                                       , parm in varchar2
                                       , access_id in varchar2
                                       , call_name in varchar2
                                       , v_rid_cs in owa.vc_arr
                                       , v1 in owa.vc_arr
                                       , v2 in owa.vc_arr
                                       , v3 in out owa.vc_arr
                                       , v4 in out owa.vc_arr
                                       , v5 in out owa.vc_arr
                                       , v6 in out owa.vc_arr
                                       , v7 in out owa.vc_arr
                                       , v9 in out owa.vc_arr
                                       , v11 in out owa.vc_arr
                                       , v12 in out owa.vc_arr
                                       , v13 in out owa.vc_arr
                                       , v14 in out owa.vc_arr
                                       , v16 in out owa.vc_arr
                                       , v17 in out owa.vc_arr
                                       , v18 in out owa.vc_arr
                                       , v19 in out owa.vc_arr
                                       , v22 in out owa.vc_arr
                                       , v23 in out owa.vc_arr
                                       , v24 in out owa.vc_arr
                                       , action in varchar2
                                       )
is

 cursor c1(rid ROWID) is select * from strang.containers_southbound where rowid = rid FOR UPDATE;

 cursor c4 (rid_cs rowid) is
  select ds.*
  from  strang.dan_details_southbound ds, strang.containers_southbound cs
  where cs.rowid = rid_cs
     and upper(ds.ship) = upper(cs.ship)
     and upper(ds.voyage) = upper(cs.voyage)
     and upper(ds.container) = upper(cs.container)
     and ds.container is not null
 ;

 cursor c5 (rid_ss rowid) is select * from strang.ships_southbound where rowid = rid_ss;

 cursor c6 (v_ctr varchar2, v_dte date) is
  select *
  from   strang.containers
  where  upper(replace(replace(trim(containerno), ' ', ''), '-', '')) = upper(replace(replace(trim(v_ctr), ' ', ''), '-', ''))
         and trunc(datehired) <= v_dte
         and trunc(offdate + 1) >= v_dte
 ;

 stype       integer;
 ltype       varchar2(100);
 owner_id    integer;
 sts         varchar2(100);
 v_rid_ss    rowid;
 v_rid_bs    rowid;
 error_found boolean;
 ctrrec      strang.containers_southbound%ROWTYPE;
 c4rec       c4%ROWTYPE;
 c5rec       c5%ROWTYPE;
 c6rec       c6%ROWTYPE;
 v_date      date;
 v_number    number;
 errmsg      owa.vc_arr;
 ctr         integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGSB.CONTAINERS_MASS' );
 if sts is not null
 then
 glbx.redisplay_login_page( sts, TRUE );
 return;
 end if;

 v_rid_ss := replace(rid_ss, '~', '+');
 v_rid_bs := replace(rid_bs, '~', '+');
 error_found := FALSE;

 if action = lngs.STR_STH_011 -- Cancel
  then
   if v_rid_bs is not null
    then
     bols(surl, v_rid_ss, null, 'BOLS', lngs.STR_STH_006, 'z', 'Container Update Cancelled');
     return;
   else
     ship(surl,v_rid_ss , 'SHIPS', 'x', 'Container Update Cancelled' );
     return;
   end if;
 end if;

 for j in v1.first..v1.last loop
  errmsg(j) := null;
  open c1(replace(v_rid_cs(j), '~', '+'));
  fetch c1 into ctrrec;
   for k in 1..1 loop
    if c1%NOTFOUND
     then
      error_found := TRUE;
      errmsg(j) := 'Container record not found. ROWID = ' || v_rid_cs(j);
      exit;
    end if;
    -- House Bill - V3
    -- Seal - V4
    ctrrec.seal := v4(j);
    -- Marks & Numbers - V5
    ctrrec.marks_numbers := v5(j);
    -- Container Type - V6
    ctrrec.container_type := v6(j);
    -- Full/Empty - V7
    ctrrec.full_mt := v7(j);
    if nvl(upper(ctrrec.full_mt), 'EMPTY') = 'FULL'
     then
     ctrrec.hb := null;
     if ctrrec.seal is null
      then
      errmsg(j) := errmsg(j) || 'Seal mandatory for full container<BR>';
      error_found := TRUE;
     end if;
    elsif nvl(upper(ctrrec.full_mt), 'FULL') = 'EMPTY'  -- Check for DANs
     then
      open c4 (replace(v_rid_cs(j), '~', '+'));
      fetch c4 into c4rec;
      if c4%FOUND
       then
        errmsg(j) := errmsg(j) || 'Delete DANs before setting to Empty<BR>';
        v7(j) := 'FULL';
        error_found := TRUE;
      end if;
      close c4;
    end if;
    -- Delivery Date - V8
    /*
    begin
     v_date := to_date(v8(j),LNGS.STR_DATE_03);
     if to_char(v_date, 'yyyy') like '0%'
      then
       errmsg(j) := errmsg(j) || '[Delivery Date] ' || LNGS.STR_TXT_152 || ': ' || v8(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
       error_found := TRUE;
     else
       ctrrec.del_date := v_date;
     end if;
    exception when others then
     v8(j) := ctrrec.del_date;
     errmsg(j) := errmsg(j) || '[Delivery Date] ' || LNGS.STR_TXT_152 || ': ' || v8(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_03 || '<BR>';
     error_found := TRUE;
    end;
    */

    -- Delivery Co. - V9
    ctrrec.del_transport_company := v9(j);
    -- Delivery Truck Rego - V10
    -- ctrrec.del_truck_rego := v10(j);
    -- Container Park - V11
    ctrrec.container_park := v11(j);
    -- Strang Invoice - V12
    ctrrec.strang_invoice := v12(j);
    -- TARE Weight - V13
    begin
     v_number := to_number(v13(j));
     ctrrec.weight := v_number;
    exception when others then
     errmsg(j) := errmsg(j) || '[Weight] ' || LNGS.STR_STH_010 || ': ' || v13(j) || '<BR>';
     error_found := TRUE;
     v13(j) := ctrrec.weight;
    end;
    -- TARE Volume - V14
    begin
     v_number := to_number(v14(j));
     ctrrec.volume := v_number;
    exception when others then
     errmsg(j) := errmsg(j) || '[Volume] ' || LNGS.STR_STH_010 || ': ' || v14(j) || '<BR>';
     error_found := TRUE;
     v14(j) := ctrrec.volume;
    end;
    -- Customs Authority No. - V15
   --  ctrrec.customs_auth_no := v15(j);
    -- SNAIL Inspected Date - V16
    begin
     v_date := to_date(v16(j),LNGS.STR_DATE_03);
     if to_char(v_date, 'yyyy') like '0%'
      then
       errmsg(j) := errmsg(j) || '[Snail Inspected] ' || LNGS.STR_TXT_152 || ': ' || v16(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
       error_found := TRUE;
     else
       ctrrec.snail_inspect := v_date;
     end if;
    exception when others then
     errmsg(j) := errmsg(j) || '[Snail Inspected] ' || LNGS.STR_TXT_152 || ': ' || v16(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_03 || '<BR>';
     error_found := TRUE;
     v16(j) := ctrrec.snail_inspect;
    end;
    -- Wharf Collect Date  -V17
    begin
     v_date := to_date(v17(j),LNGS.STR_DATE_03);
     if to_char(v_date, 'yyyy') like '0%'
      then
       errmsg(j) := errmsg(j) || '[Wharf Collect] ' || LNGS.STR_TXT_152 || ': ' || v17(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
       error_found := TRUE;
     else
       ctrrec.wharf_collect := v_date;
     end if;
    exception when others then
     errmsg(j) := errmsg(j) || '[Wharf Collect] ' || LNGS.STR_TXT_152 || ': ' || v17(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_03 || '<BR>';
     error_found := TRUE;
     v17(j) := ctrrec.wharf_collect;
    end;
    -- AQIS Depot - V18
    ctrrec.aqis_depot := v18(j);
    -- Secondary Transport - V19
    ctrrec.secondary_transport := v19(j);
    -- AQIS Clearance - V20
    /*
    begin
     v_date := to_date(v20(j),LNGS.STR_DATE_03);
     if to_char(v_date, 'yyyy') like '0%'
      then
       errmsg(j) := errmsg(j) || '[AQIS Clearance] ' || LNGS.STR_TXT_152 || ': ' || v20(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
       error_found := TRUE;
     else
       ctrrec.aqis_clearance := v_date;
     end if;
    exception when others then
     errmsg(j) := errmsg(j) || '[AQIS Clearance] ' || LNGS.STR_TXT_152 || ': ' || v20(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_03 || '<BR>';
     error_found := TRUE;
     v20(j) := ctrrec.aqis_clearance;
    end;
    */
    -- Export Vessel - V21
    -- ctrrec.export_vessel := v21(j);
    -- Offhired Date - V22
    begin
     v_date := to_date(v22(j),LNGS.STR_DATE_01);
     if to_char(v_date, 'yyyy') like '0%'
      then
       errmsg(j) := errmsg(j) || '[Offhired Date] ' || LNGS.STR_TXT_152 || ': ' || v22(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
       error_found := TRUE;
     else
       ctrrec.offhired_date := v_date;
     end if;
    exception when others then
     errmsg(j) := errmsg(j) || '[Offhired Date] ' || LNGS.STR_TXT_152 || ': ' || v22(j) || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
     error_found := TRUE;
     v22(j) := ctrrec.offhired_date;
    end;

    if ctrrec.offhired_date is null -- Set Offhired Date
     then
      open c5 (v_rid_ss);
      fetch c5 into c5rec;
      if c5%FOUND
       then
        open c6(ctrrec.container, c5rec.sailing_date);
        fetch c6 into c6rec;
        if c6%FOUND
         then
          ctrrec.offhired_date := c6rec.offdate;
        end if;
        close c6;
      end if;
      close c5;
    end if;

    -- Place of Delivery - V23
    ctrrec.destination :=  v23(j);
    -- Comment - V24
    ctrrec.cmt := v24(j);
    if errmsg(j) is null
     then
      update strang.containers_southbound set row = ctrrec where current of c1;
      commit;
    end if;
  end loop;
  close c1;
 end loop;

 if error_found
  then
   containers_mass_update(surl, v_rid_ss, v_rid_bs, parm, action, v_rid_cs, v1, v2, v3, v4, v5, v6, v7, v9, v11, v12, v13, v14, v16, v17, v18, v19, v22, v23, v24, errmsg, access_id, 'Errors Found: Check Messages', call_name);
   return;
 else
   containers_mass_update(surl, v_rid_ss, v_rid_bs, parm, action, v_rid_cs, v1, v2, v3, v4, v5, v6, v7, v9, v11, v12, v13, v14, v16, v17, v18, v19, v22, v23, v24, errmsg, access_id, 'All Records Successfully Updated', call_name);
   return;
 end if;

exception when others then
 glbx.error_details( 'STRANGSB', 'ACCEPT_CONTAINERS_MASS_UPDATE',null,null,errmsg=>sqlerrm );
end accept_containers_mass_update;

procedure hbs (surl in varchar2, rid_ss in rowid, rid_bs rowid default null, rid_hs rowid default null, parm in varchar2, action in varchar2, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null )
is

cursor c1 ( rid_bs rowid ) is select * from strang.bols_southbound where rowid = rid_bs ;
cursor c1a ( rid_ss rowid ) is select * from strang.ships_southbound where rowid = rid_ss ;

cursor c2 (rid_bs rowid) is
 select lngs.STR_STH_005 tot -- List all Records
 from  strang.hbs_southbound hs, strang.bols_southbound bs
 where bs.rowid = rid_bs
    and upper(hs.ship) = upper(bs.ship)
    and upper(hs.voyage) = upper(bs.voyage)
    and upper(hs.bol) = upper(bs.bol)
;

cursor c3a (rid_bs rowid, rid_ss rowid) is
 select distinct hs.*, hs.rowid
 from   strang.hbs_southbound hs, strang.bols_southbound bs, strang.ships_southbound ss
 where  (rid_bs is not null
         and bs.rowid = rid_bs
         and upper(hs.ship) = upper(bs.ship)
         and upper(hs.voyage) = upper(bs.voyage)
         and upper(hs.bol) = upper(bs.bol)
        )
        or
        (rid_bs is null
	         and ss.rowid = rid_ss
	         and upper(hs.ship) = upper(ss.ship)
	         and upper(hs.voyage) = upper(ss.voyage)
        )
 order by hs.house_bill asc
;
cursor c3b (rid_bs rowid) is
 select hs.*, hs.rowid
 from  strang.hbs_southbound hs, strang.bols_southbound bs
 where bs.rowid = rid_bs
    and upper(hs.ship) = upper(bs.ship)
    and upper(hs.voyage) = upper(bs.voyage)
    and upper(hs.bol) = upper(bs.bol)
 order by hs.house_bill desc
;
cursor c3c(rid_hs rowid) is select hs.*, hs.rowid from strang.hbs_southbound hs where rowid = rid_hs ;

cursor c4(rid_bs rowid) is select * from strang.bols_southbound bs where bs.rowid = rid_bs;

cursor c5(rid_hs rowid) is
 select bs.*, bs.rowid
 from   strang.bols_southbound bs, strang.hbs_southbound hs
 where  hs.rowid = rid_hs
        and upper(hs.ship) = upper(bs.ship)
        and upper(hs.voyage) = upper(bs.voyage)
        and upper(hs.bol) = upper(bs.bol)
;

 c1rec     c1%rowtype;
 c1arec    c1a%rowtype;
 c3rec     c3a%ROWTYPE;
 c4rec     c4%ROWTYPE;
 c5rec     c5%ROWTYPE;
 ltype     varchar2(100);
 owner_id  integer;
 stype     integer;
 cusrec    customer_account%ROWTYPE;
 v_action  varchar2(100);
 vste      varchar2(10);
 pfx       THEME%ROWTYPE;
 vaccess   varchar2(20);
 seclevel  varchar2(100);
 sts       varchar2(100);
 v_rid_ss  rowid;
 v_rid_bs  rowid;
 v_rid_hs  rowid;
 v_ship    strang.ships_southbound.ship%TYPE;
 v_voy     strang.ships_southbound.voyage%TYPE;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGSB.HBS' );
 if sts is not null
 then
 glbx.redisplay_login_page( sts, TRUE );
 return;
 end if;

 v_rid_ss := replace(rid_ss, '~', '+');
 v_rid_bs := replace(rid_bs, '~', '+');
 v_rid_hs := replace(rid_hs, '~', '+');

 cusrec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(cusrec.aid);
 pfx := glbx.get_thm( cusrec.theme_name );
 vaccess := strangp.data_access( owner_id, 'SHP_SB', v_rid_ss );
 seclevel := oltp.security_role( owner_id );

 if rid_bs is not null
  then
   open c1(v_rid_bs );
   fetch c1 into c1rec;
   if c1%NOTFOUND
   then
    htp.init;
    close c1;
    htp.htmlopen;
    htp.header(3,'Southbound BOLs', 'CENTER' );
    htp.header(3,'RECORD NOT FOUND', 'CENTER' );
    htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
    htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
    htp.nl;
    htp.header(2,'Extra Information: ROWID = ' || nvl(v_rid_bs , 'NULL'), 'CENTER' );
    htp.htmlclose;
    return;
   end if;
   close c1;
   v_ship := c1rec.ship;
   v_voy := c1rec.voyage;
 else
   open c1a(v_rid_ss );
   fetch c1a into c1arec;
   if c1a%NOTFOUND
   then
    htp.init;
    close c1a;
    htp.htmlopen;
    htp.header(3,'Southbound Ships', 'CENTER' );
    htp.header(3,'RECORD NOT FOUND', 'CENTER' );
    htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
    htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
    htp.nl;
    htp.header(2,'Extra Information: ROWID = ' || nvl(v_rid_ss , 'NULL'), 'CENTER' );
    htp.htmlclose;
    return;
   end if;
   close c1a;
   v_ship := c1arec.ship;
   v_voy := c1arec.voyage;
   v_action := lngs.STR_STH_005;
 end if;

 v_action := nvl(v_action, action);

 if (v_action = lngs.STR_STH_005 and rid_bs is not null) -- List all Records
 or v_action = lngs.STR_STH_012 -- Edit HBs
 then
  open c2 (v_rid_bs );
  fetch c2 into v_action;
  if c2%NOTFOUND
  then
   v_action := lngs.STR_STH_002; -- Insert New Record
  end if;
  close c2;
 end if;


 glbx.main_title( surl, 'Southbound HBs',glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'STR16',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 htp.p( '<CENTER>' );

 if msg is not null
 then
  glbx.header_msg( msg );
 end if;

 if v_action in (lngs.STR_STH_005, lngs.STR_STH_012) -- List
 then

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=10 border=0' ); -- Table 1
  htp.tablerowopen;
   htp.tabledata( htf.bold('Southbound House Bills'), ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
  htp.tablerowclose;

  htp.tablerowopen;
  htp.p( '<TD align="LEFT" colspan="2">' );

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border="1" ' || glbx.TABLE_BACKGROUND ); -- Table 2

   htp.tablerowopen;
    htp.tabledata( htf.bold('Ship'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if rid_bs is null
     then
      htp.tabledata( htf.anchor('strangsb.ship?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=SHIPS&access_id=x', v_ship), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="2"');
    else
      htp.tabledata( htf.anchor('strangsb.ship?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=SHIPS&access_id=x', v_ship), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Voyage'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if rid_bs is null
     then
      htp.tabledata( v_voy, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="2"');
    else
      htp.tabledata( v_voy, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    end if;
   htp.tablerowclose;
   if rid_bs is not null
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold('BOL'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( htf.anchor('strangsb.bols?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_003 || '&rid_bs=' || replace(rid_bs, '+', '~') || '&access_id=x&msg=' || msg || '&call_name=' || call_name, c1rec.bol));
     htp.tablerowclose;
   else
     htp.tablerowopen;
      htp.tabledata( htf.bold('HB'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( htf.bold('BOL'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
   htp.p(confirm_delete(script_only=>TRUE));
   for c3rec in c3a(v_rid_bs, v_rid_ss) loop
    if rid_bs is null
     then
      open c5(c3rec.rowid);
      fetch c5 into c5rec;
      close c5;
      v_rid_bs := replace(c5rec.rowid, '+', '~');
    else
      v_rid_bs := replace(rid_bs, '+', '~');
    end if;
    htp.tablerowopen;
     htp.tabledata( c3rec.house_bill, ' ALIGN="LEFT"');
     if rid_bs is null
      then
       htp.tabledata( htf.anchor('strangsb.bols?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_003 || '&rid_bs=' || v_rid_bs || '&access_id=x&msg=' || msg || '&call_name=' || call_name, c5rec.bol));
     end if;
     htp.tabledata( htf.anchor('strangsb.hbs?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_003 || '&rid_bs=' || v_rid_bs || '&rid_hs=' || replace(c3rec.rowid, '+', '~') || '&access_id=x&msg=' || msg || '&call_name=' || call_name, 'Update') ||
            '&nbsp;' ||
            htf.anchor('strangsb.accept_hbs?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_004 || '&rid_bs=' || v_rid_bs || '&rid_hs=' || replace(c3rec.rowid, '+', '~') || '&access_id=x&P1=&P2=&P3=&P4=&P5=&P6=&P7=', 'Delete', cattributes=>'onClick="return confirmPost(''Delete ' || c3rec.house_bill || ': Are you sure?'')"'), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tablerowclose;
   end loop;

  -- Submit Buttons

   htp.tablerowopen;

   htp.formopen( 'strangsb.hbs' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
   htp.formhidden( 'RID_BS', replace(rid_bs ,'~','+') );
   htp.formhidden( 'RID_HS', null );
   htp.formhidden( 'PARM', 'BOLS' );
   htp.formhidden( 'ACCESS_ID', 'z' );
   htp.p('<TD VALIGN="TOP">');
   htp.formsubmit( 'ACTION', lngs.STR_STH_002 ); -- Insert
   htp.p('</TD>');
   htp.formclose;

   htp.tablerowclose;

   htp.tableclose;
   htp.p('</TD>');

  htp.tablerowclose;
  htp.tableclose; -- Table 1
  htp.p( '</CENTER>' );
  return;
 end if;

 if v_action in (lngs.STR_STH_002, lngs.STR_STH_003, lngs.STR_STH_007) -- Insert New Record | Update Record | Insert Another Record
 then
  if v_rid_hs is null   -- Default values to pre-populate fields
  then
   open c3b( v_rid_bs );
   fetch c3b into c3rec;
   close c3b;
  else
   open c3c( v_rid_hs );
   fetch c3c into c3rec;
   if v_action = lngs.STR_STH_003 -- Update Record
   and c3c%NOTFOUND
   then
    close c3c;
    htp.init;
    htp.htmlopen;
    htp.header(3,'Southbound HBs', 'CENTER' );
    htp.header(3,'RECORD NOT FOUND', 'CENTER' );
    htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
    htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
    htp.nl;
    htp.header(2,'Extra Information: ROWID = ' || nvl(v_rid_hs , 'NULL'), 'CENTER' );
    htp.htmlclose;
    return;
   end if;
   close c3c;
  end if;

  htp.tableopen; -- Table 1
  htp.tablerowopen;
  htp.p( '<TD align="LEFT" colspan="2">' );
  htp.formopen( 'strangsb.accept_hbs' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
  htp.formhidden( 'RID_BS', replace(rid_bs ,'~','+') );
  htp.formhidden( 'RID_HS', replace(rid_hs ,'~','+') );
  htp.formhidden( 'PARM', 'HS' );
  htp.formhidden( 'ACCESS_ID', 'z' );
 -- Main Table

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border="1" ' || glbx.TABLE_BACKGROUND ); -- Table 2

  -- Ship
  htp.tablerowopen;
   htp.tabledata( htf.bold('Ship'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.anchor('strangsb.ship?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=SHIPS&access_id=x', c1rec.ship ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- Voyage
  htp.tablerowopen;
   htp.tabledata( htf.bold('Voyage'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( c1rec.voyage ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- BOL
  htp.tablerowopen;
   htp.tabledata( htf.bold('BOL'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.anchor('strangsb.bols?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=BOLS&action=Update Record&rid_bs=' || replace(rid_bs, '+', '~') || '&access_id=x&msg=&call_name=', c1rec.bol), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P1: House Bill
  htp.tablerowopen;
   htp.tabledata( htf.bold('House Bill'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
/*
   if v_action = lngs.STR_STH_003 -- Update Record
   then
    htp.formhidden( 'P1', c3rec.house_bill );
--    htp.tabledata( htf.bold( c3rec.house_bill ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    htp.tabledata( htf.anchor( 'strangsb.hbs?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=' || parm || '&action=' || v_action || '&rid_bs=' || replace(rid_bs, '+', '~') || '&rid_hs=' || replace(rid_hs, '+', '~') || '&access_id=' || access_id || '&msg=' || msg || '&call_name=' || call_name
                             , c3rec.house_bill
                             , cattributes=>'title="Reload this page"' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   else
*/
    htp.tabledata( htf.formtext( 'P1', 15, 15, c3rec.house_bill)
                                 || '&nbsp;'
                                 || htf.anchor( 'strangsb.hbs?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=' || parm || '&action=' || v_action || '&rid_bs=' || replace(rid_bs, '+', '~') || '&rid_hs=' || replace(rid_hs, '+', '~') || '&access_id=' || access_id || '&msg=' || msg || '&call_name=' || call_name
                                              , '[Reload]'
                                              , cattributes=>'title="Reload this page"'
                                              )
                               , cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"'
                               );
--   end if;
  htp.tablerowclose;

  open c4(v_rid_bs);
  fetch c4 into c4rec;
  close c4;

  -- P5: Delivery Date and Time
  htp.tablerowopen;
   htp.tabledata( htf.bold('Delivery Date and Time'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P5', 25, 25, to_char(c3rec.del_date,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(LNGS.STR_DATE_01), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P6: Customs Authority Number
  htp.tablerowopen;
   htp.tabledata( htf.bold('Customs Authority no.'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P6', 30, 100, c3rec.customs_auth_no), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P7: AQIS Clearance
  htp.tablerowopen;
   htp.tabledata( htf.bold('AQIS Clearance'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P7', 25, 25, to_char(c3rec.aqis_clearance,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(replace(LNGS.STR_DATE_01, 'HH24:MI', '[HH24:MI]')), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P4: Shipper
  htp.tablerowopen;
   htp.tabledata( htf.bold('Shipper'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   customer_list( 'SOUTHBOUND', 'P4', nvl(c3rec.shipper, c4rec.shipper), FALSE, isedit=>TRUE );
   htp.anchor( 'javascript: window.open(''' || 'oltp.display_screen?surl=' || surl || '&sname=Customers&rnd=63084&access_in=QUERY&rid=' || ''',''CUSTOMER_CODES'',''height=800,width=1200,scrollbars=yes,resizable=yes'');void('''');', '[Customer Codes]'
             , cattributes=>'title="Edit Code in a new window ***NOTE*** Reload this page for new codes to take effect"');
   htp.p( '</TD>' );
  htp.tablerowclose;

  -- P2: Consignee
  htp.tablerowopen;
   htp.tabledata( htf.bold('Consignee'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   customer_list( 'SOUTHBOUND', 'P2', nvl(c3rec.consignee, c4rec.consignee), FALSE, isedit=>TRUE );
   if v_action <> lngs.STR_STH_003 -- Update Record
   then
    htp.anchor('strangsb.hbs?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&rid_bs=' || replace(rid_bs, '+', '~') || '&rid_hs=&parm=' || parm || '&action=' || v_action || '&access_id=' || access_id || '&msg=' || msg || '&call_name=' || call_name, '[Reload Page]'
              , cattributes=>'title="Reload page with any new codes"');
   end if;
   htp.p( '</TD>' );
  htp.tablerowclose;

  -- P3: Notifying Party
  htp.tablerowopen;
   htp.tabledata( htf.bold('Notifying Party'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   customer_list( 'SOUTHBOUND', 'P3', nvl(c3rec.notifying_party, c4rec.notifying_party), FALSE, isedit=>TRUE );
   htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tableclose; -- Table 2
  htp.p('</TD>');
  htp.tablerowclose;

  htp.tablerowopen;

  htp.tablerowclose;

 -- Submit Buttons

  htp.p('<TD VALIGN="TOP">');
  if v_action = lngs.STR_STH_003 -- Update Record
  then
   htp.formsubmit( 'ACTION', lngs.STR_STH_003 ); -- Update Record
   htp.p('&nbsp;');
   htp.p( confirm_delete ( 'ACTION', lngs.STR_STH_004, 'Delete ' || c3rec.house_bill || ': Are you sure?' )); -- Delete
   htp.p('&nbsp;');
   htp.formsubmit( 'ACTION', lngs.STR_STH_007 ); -- Insert Another Record
  else
   htp.formsubmit( 'ACTION', lngs.STR_STH_002 ); -- Insert
  end if;
  htp.p('&nbsp;');
  htp.formsubmit( 'ACTION', lngs.STR_STH_005 ); -- List All Records
  htp.p('</TD>');

  htp.tablerowclose;
  htp.formclose;
  htp.tableclose; -- Table 1

 else
  null;
 end if;

exception when others then
 glbx.error_details( 'STRANGSB', 'HBS',null,null,errmsg=>sqlerrm,extdet=>'RID_SS:' || rid_ss || '; RID_BS :' || rid_bs);
end hbs;

procedure accept_hbs( surl in varchar2, rid_ss in rowid, rid_bs in rowid, rid_hs in rowid, parm in varchar2, access_id in varchar2, action in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2 )
is

cursor c1 (rid_hs rowid) is select hs.*, hs.rowid from strang.hbs_southbound hs where rowid = rid_hs;
cursor c2 (rid_bs rowid) is select * from strang.bols_southbound where rowid = rid_bs;
cursor c3 (rid_bs rowid, hb varchar2) is
 select hs.rowid
 from  strang.hbs_southbound hs, strang.bols_southbound bs
 where upper(hs.house_bill) = upper(hb)
    and upper(hs.ship) = upper(bs.ship)
    and upper(hs.voyage) = upper(bs.voyage)
    and upper(hs.bol) = upper(bs.bol)
    and bs.rowid = rid_bs
;

 c1rec    c1%ROWTYPE;
 c2rec    c2%ROWTYPE;
 c3rec    c3%ROWTYPE;
 owner_id integer;
 ltype    varchar2(100);
 stype    integer;
 sts      varchar2(100);
 msg      varchar2(4000);
 v_rid_ss rowid;
 v_rid_bs rowid;
 v_rid_hs rowid;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGSB.ACCEPT_HBS' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 v_rid_ss := replace(rid_ss, '~', '+');
 v_rid_bs := replace(rid_bs, '~', '+');
 v_rid_hs := replace(rid_hs, '~', '+');

 open c2( v_rid_bs );
 fetch c2 into c2rec;
 if c2%NOTFOUND
  then
  htp.init;
  close c2;
  htp.htmlopen;
   htp.header(3,'Southbound BOLs', 'CENTER' );
   htp.header(3,'RECORD NOT FOUND', 'CENTER' );
   htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
   htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
   htp.nl;
   htp.header(2,'Extra Information: ROWID = ' || nvl(v_rid_bs , 'NULL'), 'CENTER' );
  htp.htmlclose;
  return;
 end if;
 close c2;

 if action = lngs.STR_STH_005 -- List All Records
  then
  hbs(surl, v_rid_ss, v_rid_bs, null, 'HB', lngs.STR_STH_005, 'z', null);
  return;
 elsif action = lngs.STR_STH_007 -- Insert Another Record
  then
  hbs(surl, v_rid_ss, v_rid_bs, v_rid_hs, 'HB', lngs.STR_STH_007, 'z', null);
  return;
 elsif action = lngs.STR_STH_011 -- Cancel
  then
  hbs(surl, v_rid_ss, v_rid_bs, v_rid_hs, 'HB', lngs.STR_STH_003, 'x', null);
  return;
 end if;

 if action = lngs.STR_STH_004 -- Delete
  then
  open c1 (v_rid_hs );
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
   close c1;
   htp.init;
   htp.htmlopen;
    htp.header(3,'Southbound House Bills', 'CENTER' );
    htp.header(3,'RECORD NOT FOUND', 'CENTER' );
    htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
    htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
    htp.nl;
    htp.header(2,'Extra Information: ROWID = ' || nvl(v_rid_hs , 'NULL'), 'CENTER' );
   htp.htmlclose;
   return;
  else
   msg := 'House Bill [' || c1rec.house_bill || '] DELETED';
   delete from strang.hbs_southbound where rowid = c1rec.rowid;
   commit;
   hbs(surl, v_rid_ss, v_rid_bs , null, parm, lngs.STR_STH_005, 'x', msg);
   return;
  end if;
 end if;

 if action = lngs.STR_STH_002 -- Insert New Record
  then

  if P1 is null
   then
   msg := msg || 'Please Enter House Bill Number<BR>';
  else -- Check for existing House Bill number
   open c3 (v_rid_bs , trim(P1));
   fetch c3 into c3rec;
   if c3%FOUND
    then
    msg := msg || 'Record already exists for House Bill [' || P1 || ']<BR>';
   end if;
   close c3;
  end if;

  -- Date Validation - Delivery Date
  begin
  c1rec.del_date := to_date(p5,LNGS.STR_DATE_01);
  exception when others then
  msg := msg || '[Delivery Date] ' || LNGS.STR_TXT_152 || ': ' || p5 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
  end;
  if to_char(c1rec.del_date, 'yyyy') like '0%'
   then
    msg := msg || '[Delivery Date] ' || LNGS.STR_TXT_152 || ': ' || p5 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
  end if;

  -- Date Validation - AQIS Clearance
  begin
  c1rec.aqis_clearance := to_date(p7,LNGS.STR_DATE_01);
  exception when others then
  msg := msg || '[AQIS Clearance] ' || LNGS.STR_TXT_152 || ': ' || p7 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
  end;
  if to_char(c1rec.aqis_clearance, 'yyyy') like '0%'
   then
    msg := msg || '[AQIS Clearance] ' || LNGS.STR_TXT_152 || ': ' || p7 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
  end if;

  if msg is not null
   then
   hbs(surl, v_rid_ss, v_rid_bs, null, 'HB', lngs.STR_STH_002, 'e', msg );
   return;
  end if;

  insert into strang.hbs_southbound (
      house_bill
     , bol
     , ship
     , voyage
     , del_date
     , customs_auth_no
     , aqis_clearance
     , shipper
     , consignee
     , notifying_party
      )
  values (
      P1
     , c2rec.bol
     , c2rec.ship
     , c2rec.voyage
     , c1rec.del_date
     , P6
     , c1rec.aqis_clearance
     , P4
     , P2
     , P3
      )
  returning rowid into c3rec.rowid ;

  commit;

  hbs(surl, v_rid_ss, v_rid_bs, c3rec.rowid, 'HB', lngs.STR_STH_003, 'x', 'Record Inserted');
 elsif action = lngs.STR_STH_003 -- Update Record
  then

  open c1 (v_rid_hs );
  fetch c1 into c1rec;
  close c1;

  -- Date Validation - Delivery Date
  begin
  c1rec.del_date := to_date(p5,LNGS.STR_DATE_01);
  exception when others then
  msg := msg || '[Delivery Date] ' || LNGS.STR_TXT_152 || ': ' || p5 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
  end;
  if to_char(c1rec.del_date, 'yyyy') like '0%'
   then
    msg := msg || '[Delivery Date] ' || LNGS.STR_TXT_152 || ': ' || p5 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
  end if;

  -- Date Validation - AQIS Clearance
  begin
  c1rec.aqis_clearance := to_date(p7,LNGS.STR_DATE_01);
  exception when others then
  msg := msg || '[AQIS Clearance] ' || LNGS.STR_TXT_152 || ': ' || p7 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
  end;
  if to_char(c1rec.aqis_clearance, 'yyyy') like '0%'
   then
    msg := msg || '[AQIS Clearance] ' || LNGS.STR_TXT_152 || ': ' || p7 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
  end if;

  -- Change HB value - heck for duplicates

  if P1 is not null and upper(trim(P1)) <> upper(c1rec.house_bill)
   then
    open c3 (v_rid_bs , trim(P1));
    fetch c3 into c3rec;
    if c3%FOUND
     then
     msg := msg || 'Record already exists for House Bill [' || P1 || ']<BR>';
    else
      c1rec.house_bill := nvl(trim(P1), c1rec.house_bill);
    end if;
    close c3;
  end if;

  if msg is not null
   then
   hbs(surl, v_rid_ss, v_rid_bs, v_rid_hs, 'HB', lngs.STR_STH_003, 'e', msg);
   return;
  end if;

  update strang.hbs_southbound
  set  del_date = c1rec.del_date
     , house_bill = c1rec.house_bill
     , customs_auth_no = P6
     , aqis_clearance = c1rec.aqis_clearance
     , consignee = P2
     , notifying_party = P3
  where rowid=v_rid_hs ;
  commit;
  hbs(surl, v_rid_ss, v_rid_bs, v_rid_hs, 'HB', lngs.STR_STH_003, 'x', 'Record Updated');
 end if;

exception when others then
 glbx.error_details( 'STRANGSB', 'ACCEPT_HBS',null,null,errmsg=>sqlerrm,extdet=>'RID_SS:' || v_rid_ss || '; RID_BS :' || v_rid_bs);
end accept_hbs;

procedure dans(surl in varchar2, rid_ss in rowid, rid_bs in rowid default null, rid_cs in rowid default null, rid_ds in rowid default null, parm in varchar2, action in varchar2, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null )
is

cursor c1 ( rid_bs rowid ) is select * from strang.bols_southbound where rowid = rid_bs ;

cursor c1a ( rid_cs rowid ) is select * from strang.containers_southbound where rowid = rid_cs ;

cursor c1b ( rid_ss rowid ) is select * from strang.ships_southbound where rowid = rid_ss ;

cursor c2 (rid_bs rowid) is
 select lngs.STR_STH_005 tot -- List all Records
 from  strang.dan_details_southbound ds, strang.bols_southbound bs
 where bs.rowid = rid_bs
    and upper(ds.ship) = upper(bs.ship)
    and upper(ds.voyage) = upper(bs.voyage)
    and upper(ds.bol) = upper(bs.bol)
    and ds.container is null
;

cursor c2a (rid_cs rowid) is
 select lngs.STR_STH_005 tot -- List all Records
 from  strang.dan_details_southbound ds, strang.containers_southbound cs
 where cs.rowid = rid_cs
    and upper(ds.ship) = upper(cs.ship)
    and upper(ds.voyage) = upper(cs.voyage)
    and upper(ds.container) = upper(cs.container)
    and ds.container is not null
;

cursor c3a (rid_cs rowid) is
 select ds.*, ds.rowid
 from  strang.dan_details_southbound ds, strang.containers_southbound cs
 where cs.rowid = rid_cs
    and upper(ds.ship) = upper(cs.ship)
    and upper(ds.voyage) = upper(cs.voyage)
    and upper(ds.bol) = upper(cs.bol)
    and upper(ds.container) = upper(cs.container)
 order by ds.dan asc
;

cursor c3b (rid_bs rowid) is
 select ds.*, ds.rowid
 from  strang.dan_details_southbound ds, strang.bols_southbound bs
 where bs.rowid = rid_bs
    and upper(ds.ship) = upper(bs.ship)
    and upper(ds.voyage) = upper(bs.voyage)
    and upper(ds.bol) = upper(bs.bol)
    and ds.container is null
 order by ds.dan desc
;

cursor c3c(rid_ds rowid) is select ds.*, ds.rowid from strang.dan_details_southbound ds where rowid = rid_ds ;

cursor c3d (rid_bs rowid) is
 select ds.*, ds.rowid
 from  strang.dan_details_southbound ds, strang.bols_southbound bs
 where bs.rowid = rid_bs
    and upper(ds.ship) = upper(bs.ship)
    and upper(ds.voyage) = upper(bs.voyage)
    and upper(ds.bol) = upper(bs.bol)
    and ds.container is null
 order by ds.dan asc
;

cursor c3e (rid_cs rowid) is
 select ds.*, ds.rowid
 from  strang.dan_details_southbound ds, strang.containers_southbound cs
 where cs.rowid = rid_cs
    and upper(ds.ship) = upper(cs.ship)
    and upper(ds.voyage) = upper(cs.voyage)
    and upper(ds.bol) = upper(cs.bol)
    and upper(ds.container) = upper(cs.container)
 order by ds.dan desc
;

cursor c3f (rid_ss rowid) is
 select ds.*, ds.rowid
 from  strang.dan_details_southbound ds, strang.ships_southbound ss
 where ss.rowid = rid_ss
    and upper(ds.ship) = upper(ss.ship)
    and upper(ds.voyage) = upper(ss.voyage)
 order by ds.bol, ds.container, ds.dan desc
;

cursor c4a (rid_ds rowid) is
 select cs.*, cs.rowid
 from   strang.containers_southbound cs, strang.dan_details_southbound ds
 where  ds.rowid = rid_ds
    and upper(ds.ship) = upper(cs.ship)
    and upper(ds.voyage) = upper(cs.voyage)
    and upper(ds.bol) = upper(cs.bol)
    and upper(ds.container) = upper(cs.container)
;

cursor c4b (rid_ds rowid) is
 select bs.*, bs.rowid
 from   strang.bols_southbound bs, strang.dan_details_southbound ds
 where  ds.rowid = rid_ds
    and upper(ds.ship) = upper(bs.ship)
    and upper(ds.voyage) = upper(bs.voyage)
    and upper(ds.bol) = upper(bs.bol)
;

 c1rec     c1%rowtype;
 c1arec    c1a%rowtype;
 c1brec    c1b%rowtype;
 c3rec     c3a%ROWTYPE;
 c4arec    c4a%ROWTYPE;
 c4brec    c4b%ROWTYPE;
 ltype     varchar2(100);
 owner_id  integer;
 stype     integer;
 cusrec    customer_account%ROWTYPE;
 v_action  varchar2(100);
 vste      varchar2(10);
 pfx       THEME%ROWTYPE;
 vaccess   varchar2(20);
 seclevel  varchar2(100);
 sts       varchar2(100);
 v_rid_ss  rowid;
 v_rid_bs  rowid;
 v_rid_cs  rowid;
 v_rid_ds  rowid;
 v_ship    strang.ships_southbound.ship%TYPE;
 v_voy     strang.ships_southbound.voyage%TYPE;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGSB.DANS' );
 if sts is not null
 then
 glbx.redisplay_login_page( sts, TRUE );
 return;
 end if;

 v_rid_ss := replace(rid_ss, '~', '+');
 v_rid_bs := replace(rid_bs, '~', '+');
 v_rid_cs := replace(rid_cs, '~', '+');
 v_rid_ds := replace(rid_ds, '~', '+');

 cusrec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(cusrec.aid);
 pfx := glbx.get_thm( cusrec.theme_name );
 vaccess := strangp.data_access( owner_id, 'SHP_SB', v_rid_ss );
 seclevel := oltp.security_role( owner_id );

 if rid_bs is not null
  then
   open c1(v_rid_bs);
   fetch c1 into c1rec;
   if c1%NOTFOUND
   then
    htp.init;
    close c1;
    htp.htmlopen;
    htp.header(3,'Southbound BOLs', 'CENTER' );
    htp.header(3,'RECORD NOT FOUND', 'CENTER' );
    htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
    htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
    htp.nl;
    htp.header(2,'Extra Information: ROWID = ' || nvl(v_rid_bs , 'NULL'), 'CENTER' );
    htp.htmlclose;
    return;
   end if;
   close c1;
   v_ship := c1rec.ship;
   v_voy := c1rec.voyage;
 else
   open c1b(v_rid_ss );
   fetch c1b into c1brec;
   if c1b%NOTFOUND
   then
    htp.init;
    close c1b;
    htp.htmlopen;
    htp.header(3,'Southbound Ships', 'CENTER' );
    htp.header(3,'RECORD NOT FOUND', 'CENTER' );
    htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
    htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
    htp.nl;
    htp.header(2,'Extra Information: ROWID = ' || nvl(v_rid_ss , 'NULL'), 'CENTER' );
    htp.htmlclose;
    return;
   end if;
   close c1b;
   v_ship := c1brec.ship;
   v_voy := c1brec.voyage;
   v_action := lngs.STR_STH_005;
 end if;

 if v_rid_cs is not null
 then
  open c1a(v_rid_cs);
  fetch c1a into c1arec;
  if c1a%NOTFOUND
  then
   htp.init;
   close c1;
   htp.htmlopen;
   htp.header(3,'Southbound Containers', 'CENTER' );
   htp.header(3,'RECORD NOT FOUND', 'CENTER' );
   htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
   htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
   htp.nl;
   htp.header(2,'Extra Information: ROWID = ' || nvl(v_rid_cs , 'NULL'), 'CENTER' );
   htp.htmlclose;
   return;
  end if;
  close c1a;
 end if;

 v_action := nvl(v_action, action);

 if (v_action = lngs.STR_STH_005 and rid_bs is not null) -- List all Records
 or action = lngs.STR_STH_009 -- Edit DANs
 or action = lngs.STR_STH_014 -- Break-Bulk DANs
 then
  if v_rid_cs is not null
  then
   open c2a (v_rid_cs);
   fetch c2a into v_action;
   if c2a%NOTFOUND
   then
    v_action := lngs.STR_STH_002; -- Insert New Record
   end if;
   close c2a;
  elsif rid_bs is not null
   then
   open c2 (v_rid_bs);
   fetch c2 into v_action;
   if c2%NOTFOUND
   then
    v_action := lngs.STR_STH_002; -- Insert New Record
   end if;
   close c2;
  end if;
 end if;

 glbx.main_title( surl, 'Southbound DANs',glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'STR16',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 htp.p( '<CENTER>' );

 if msg is not null
 then
  glbx.header_msg( msg );
 end if;

 if v_action in (lngs.STR_STH_005, lngs.STR_STH_009) -- List
 then

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=10 border=0' ); -- Table 1
  htp.tablerowopen;
   htp.tabledata( htf.bold('Southbound DAN Details'), ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
  htp.tablerowclose;

  htp.tablerowopen;
  htp.p( '<TD align="LEFT" colspan="2">' );

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border="1" ' || glbx.TABLE_BACKGROUND ); -- Table 2

   htp.tablerowopen;
    htp.tabledata( htf.bold('Ship'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if rid_bs is null
    then
     htp.tabledata( htf.anchor('strangsb.ship?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=SHIPS&access_id=x', v_ship), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"'|| ' COLSPAN="6"');
   else
     htp.tabledata( htf.anchor('strangsb.ship?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=SHIPS&access_id=x', v_ship), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"'|| ' COLSPAN="4"');
   end if;
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Voyage'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if rid_bs is null
    then
     htp.tabledata( v_voy, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"'|| ' COLSPAN="6"');
   else
     htp.tabledata( v_voy, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"'|| ' COLSPAN="4"');
   end if;
   htp.tablerowclose;
   htp.p(confirm_delete(script_only=>TRUE));
   if rid_bs is null
    then
     htp.tablerowopen;
      htp.tabledata(htf.center(htf.bold('DANs')), cattributes=>glbx.QUERY_BACKGROUND || ' COLSPAN="7"');
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata(htf.bold('DAN'), cattributes=>glbx.QUERY_BACKGROUND);
      htp.tabledata(htf.bold('HB (Full)'), cattributes=>glbx.QUERY_BACKGROUND);
      htp.tabledata(htf.bold('BOL'), cattributes=>glbx.QUERY_BACKGROUND);
      htp.tabledata(htf.bold('Container'), cattributes=>glbx.QUERY_BACKGROUND);
      htp.tabledata(htf.bold('Commodity'), cattributes=>glbx.QUERY_BACKGROUND);
      htp.tabledata(htf.bold('Strang Invoice (Full)'), cattributes=>glbx.QUERY_BACKGROUND);
      htp.tabledata(htf.bold('Action'), cattributes=>glbx.QUERY_BACKGROUND);
     htp.tablerowclose;
    for c3rec in c3f(v_rid_ss) loop
     if rid_bs is null
      then
       open c4a( c3rec.rowid);
       fetch c4a into c4arec;
       close c4a;
       open c4b( c3rec.rowid);
       fetch c4b into c4brec;
       close c4b;
       -- v_rid_cs := replace(c4arec.rowid, '+', '~');
       -- v_rid_bs := replace(c4brec.rowid, '+', '~');
       v_rid_cs := c4arec.rowid;
       v_rid_bs := c4brec.rowid;
     else
       -- v_rid_cs := replace(rid_cs, '+', '~');
       -- v_rid_bs := replace(rid_bs, '+', '~');
       v_rid_cs := replace(rid_cs, '~', '+');
       v_rid_bs := replace(rid_bs, '~', '+');
     end if;
     htp.tablerowopen;
      htp.tabledata( c3rec.dan, ' ALIGN="LEFT"');
      htp.tabledata( nvl(c3rec.hb, '&nbsp;'), ' ALIGN="LEFT"');
      htp.tabledata( nvl(c3rec.bol, '&nbsp;'), ' ALIGN="LEFT"');
      htp.tabledata( nvl(c3rec.container, '&nbsp;'), ' ALIGN="LEFT"');
      htp.tabledata( c3rec.commodity, ' ALIGN="LEFT"');
      htp.tabledata( nvl(c3rec.strang_invoice, '&nbsp;'), ' ALIGN="LEFT"');
      htp.tabledata( htf.anchor('strangsb.dans?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&rid_bs=' || replace(v_rid_bs, '+', '~') || '&rid_cs=' || replace(v_rid_cs, '+', '~') || '&rid_ds=' || replace(c3rec.rowid, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_003 || '&access_id=x&msg=' || msg || '&call_name=' || call_name, 'Update') ||
             '&nbsp;' ||
             htf.anchor('strangsb.accept_dans?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&rid_bs=' || replace(v_rid_bs, '+', '~') || '&rid_cs=' || replace(v_rid_cs, '+', '~') || '&rid_ds=' || replace(c3rec.rowid, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_004 || '&access_id=x&P1=&P2=&P3=&P4=&P5=&P6=&P7=&P8=&P9=', 'Delete', cattributes=>'onClick="return confirmPost(''Delete ' || c3rec.dan || ': Are you sure?'')"'), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tablerowclose;
    end loop;

   elsif v_rid_cs is not null
    then
    htp.tablerowopen;
     htp.tabledata( htf.bold('Container'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.anchor('strangsb.containers?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&rid_bs=' || replace(rid_bs, '+', '~') || '&rid_cs=' || replace(rid_cs, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_003 || '&access_id=x&msg=' || msg || '&call_name=' || call_name, c1arec.container), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"'|| ' COLSPAN="4"');
    htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.center(htf.bold('DANs')), cattributes=>glbx.QUERY_BACKGROUND || ' COLSPAN="5"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold('HB (Full)'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Commodity'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Strang Invoice (Full)'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('DAN'), cattributes=>glbx.QUERY_BACKGROUND);
    htp.tabledata(htf.bold('Action'), cattributes=>glbx.QUERY_BACKGROUND);
   htp.tablerowclose;
    for c3rec in c3a(v_rid_cs) loop
     htp.tablerowopen;
      htp.tabledata( c3rec.hb, ' ALIGN="LEFT"');
      htp.tabledata( c3rec.commodity, ' ALIGN="LEFT"');
      htp.tabledata( c3rec.strang_invoice, ' ALIGN="LEFT"');
      htp.tabledata( c3rec.dan, ' ALIGN="LEFT"');
      htp.tabledata( htf.anchor('strangsb.dans?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&rid_bs=' || replace(rid_bs, '+', '~') || '&rid_cs=' || replace(rid_cs, '+', '~') || '&rid_ds=' || replace(c3rec.rowid, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_003 || '&access_id=x&msg=' || msg || '&call_name=' || call_name, 'Update') ||
             '&nbsp;' ||
             htf.anchor('strangsb.accept_dans?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&rid_bs=' || replace(rid_bs, '+', '~') || '&rid_cs=' || replace(rid_cs, '+', '~') || '&rid_ds=' || replace(c3rec.rowid, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_004 || '&access_id=x&P1=&P2=&P3=&P4=&P5=&P6=&P7=&P8=&P9=', 'Delete', cattributes=>'onClick="return confirmPost(''Delete ' || c3rec.dan || ': Are you sure?'')"'), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tablerowclose;
    end loop;
   else
    htp.tablerowopen;
     htp.tabledata( htf.bold('BOL'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.anchor('strangsb.bols?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_003 || '&rid_bs=' || replace(rid_bs, '+', '~') || '&access_id=x&msg=' || msg || '&call_name=' || call_name, c1rec.bol));
    htp.tablerowclose;
    for c3rec in c3d(v_rid_bs) loop
     htp.tablerowopen;
      htp.tabledata( c3rec.hb, ' ALIGN="LEFT"');
      htp.tabledata( c3rec.strang_invoice, ' ALIGN="LEFT"');
      htp.tabledata( c3rec.dan, ' ALIGN="LEFT"');
      htp.tabledata( htf.anchor('strangsb.dans?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&rid_bs=' || replace(rid_bs, '+', '~') || '&rid_cs=' || replace(rid_cs, '+', '~') || '&rid_ds=' || replace(c3rec.rowid, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_003 || '&access_id=x&msg=' || msg || '&call_name=' || call_name, 'Update') ||
             '&nbsp;' ||
             htf.anchor('strangsb.accept_dans?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&rid_bs=' || replace(rid_bs, '+', '~') || '&rid_cs=' || replace(rid_cs, '+', '~') || '&rid_ds=' || replace(c3rec.rowid, '+', '~') ||'&parm=' || parm || '&action=' || lngs.STR_STH_004 || '&access_id=x&P1=&P2=&P3=&P4=&P5=&P6=&P7=&P8=&P9=', 'Delete', cattributes=>'onClick="return confirmPost(''Delete ' || c3rec.dan || ': Are you sure?'')"'), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tablerowclose;
    end loop;
   end if;
  -- Submit Buttons

   if rid_bs is not null
    then
     htp.tablerowopen;

     htp.formopen( 'strangsb.dans' );
     htp.formhidden( 'SURL', surl );
     htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
     htp.formhidden( 'RID_BS', replace(rid_bs ,'~','+') );
     htp.formhidden( 'RID_CS', replace(rid_cs ,'~','+') );
     htp.formhidden( 'RID_DS', null );
     htp.formhidden( 'PARM', 'BOLS' );
     htp.formhidden( 'ACCESS_ID', 'z' );
     htp.p('<TD VALIGN="TOP">');
     htp.formsubmit( 'ACTION', lngs.STR_STH_002 ); -- Insert
     htp.p('</TD>');
     htp.formclose;

     htp.tablerowclose;
   end if;

   htp.tableclose;
   htp.p('</TD>');

  htp.tablerowclose;
  htp.tableclose; -- Table 1
  htp.p( '</CENTER>' );
  return;
 end if;

 if v_action in (lngs.STR_STH_002, lngs.STR_STH_003, lngs.STR_STH_007) -- Insert New Record | Update Record | Insert Another Record
 then
  if rid_ds is null   -- Default values to pre-populate fields
  then
   if rid_cs is null
   then
    open c3b( v_rid_bs );
    fetch c3b into c3rec;
    close c3b;
   else
    open c3e( v_rid_cs );
    fetch c3e into c3rec;
    close c3e;
   end if;
  else
   open c3c( v_rid_ds );
   fetch c3c into c3rec;
   if v_action = lngs.STR_STH_003 -- Update Record
   and c3c%NOTFOUND
   then
    close c3c;
    htp.init;
    htp.htmlopen;
    htp.header(3,'Southbound DAN Details', 'CENTER' );
    htp.header(3,'RECORD NOT FOUND', 'CENTER' );
    htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
    htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
    htp.nl;
    htp.header(2,'Extra Information: ROWID = ' || nvl(v_rid_ds , 'NULL'), 'CENTER' );
    htp.htmlclose;
    return;
   end if;
   close c3c;
  end if;

  htp.tableopen; -- Table 1
  htp.tablerowopen;
  htp.p( '<TD align="LEFT" colspan="2">' );
  htp.formopen( 'strangsb.accept_dans' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
  htp.formhidden( 'RID_BS', replace(rid_bs ,'~','+') );
  htp.formhidden( 'RID_CS', replace(rid_cs ,'~','+') );
  htp.formhidden( 'RID_DS', replace(rid_ds ,'~','+') );
  htp.formhidden( 'PARM', 'DANS' );
  htp.formhidden( 'ACCESS_ID', 'z' );
 -- Main Table

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border="1" ' || glbx.TABLE_BACKGROUND ); -- Table 2

  -- Record Number
  if v_action = lngs.STR_STH_003 -- Update Record
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold('Record'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( c3rec.record_no ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    htp.tablerowclose;
  end if;

  -- Ship
  htp.tablerowopen;
   htp.tabledata( htf.bold('Ship'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.anchor('strangsb.ship?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=SHIPS&access_id=x', c1rec.ship ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- Voyage
  htp.tablerowopen;
   htp.tabledata( htf.bold('Voyage'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( c1rec.voyage ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- BOL
  htp.tablerowopen;
   htp.tabledata( htf.bold('BOL'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.anchor('strangsb.bols?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=BOLS&action=Update Record&rid_bs=' || replace(rid_bs, '+', '~') || '&access_id=x&msg=&call_name=', c1rec.bol), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- Container
  if rid_cs is not null
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold('Container'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.anchor('strangsb.containers?surl=' || surl || '&rid_ss=' || replace(rid_ss, '+', '~') || '&parm=CONTAINERS&action=Update Record&rid_bs=' || replace(rid_bs, '+', '~') || '&rid_cs=' || replace(rid_cs, '+', '~') || '&access_id=x&msg=&call_name=', c1arec.container), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    htp.tablerowclose;
  end if;

  -- P1: DAN
  htp.tablerowopen;
   htp.tabledata( htf.bold('DAN'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if v_action = lngs.STR_STH_003 -- Update Record
   then
    htp.formhidden( 'P1', c3rec.dan );
    htp.tabledata( htf.bold( c3rec.dan ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   else
    htp.tabledata( htf.formtext( 'P1', 15, 15), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   end if;
  htp.tablerowclose;

  -- P2: House Bill
  htp.tablerowopen;
   htp.tabledata( htf.bold('House Bill'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p('<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    hb_list( v_rid_bs, c3rec.hb, 'P2', FALSE, TRUE );
    htp.p('</TD>');
  htp.tablerowclose;

  -- P10: Marks & Numbers
  if rid_cs is null
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold('Marks & Numbers'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.formtext( 'P10', 30, 100, c3rec.marks_numbers), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    htp.tablerowclose;
  end if;

  -- P3: Commodity
  htp.tablerowopen;
   htp.tabledata( htf.bold('Commodity'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P3', 60, 4000, c3rec.commodity), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P11: Delivery Date and Time
  if rid_cs is null
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold('Delivery Date and Time'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.formtext( 'P11', 25, 25, to_char(c3rec.del_date,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(LNGS.STR_DATE_01), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    htp.tablerowclose;
  end if;

  -- P12: Delivery Transport Company
  if rid_cs is null
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold('Delivery Transport Company'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.formtext( 'P12', 30, 100, c3rec.del_transport_company), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    htp.tablerowclose;
  end if;

  -- P13: Delivery Truck Rego
  if rid_cs is null
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold('Delivery Truck Rego'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.formtext( 'P13', 10, 10, c3rec.del_truck_rego), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    htp.tablerowclose;
  end if;

  -- P4: Strang Invoice
  htp.tablerowopen;
   htp.tabledata( htf.bold('Strang Invoice'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P4', 30, 30, c3rec.strang_invoice), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P5: Pieces
  htp.tablerowopen;
   htp.tabledata( htf.bold('Pieces'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P5', 10, 10, c3rec.pieces), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P6: Packaging
  htp.tablerowopen;
  htp.tabledata( htf.bold('Packaging'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   lov_list( 'PACKTYPES', 'P6', c3rec.packaging, FALSE, TRUE, FALSE );
  htp.p( '</TD>' );
  htp.tablerowclose;

  -- P7: Weight
  htp.tablerowopen;
   htp.tabledata( htf.bold('Weight (KG)'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P7', 10, 10, c3rec.kg), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P8: Volume
  htp.tablerowopen;
   htp.tabledata( htf.bold('Volume (Cbm)'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P8', 30, 30, c3rec.cbm), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

  -- P14: Customs Authority Number
  if rid_cs is null
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold('Customs Authority no.'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.formtext( 'P14', 30, 100, c3rec.customs_auth_no), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    htp.tablerowclose;
  end if;

  -- P15: Snail Inspected
  if rid_cs is null
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold('Snail Inspected'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.formtext( 'P15', 25, 25, to_char(c3rec.snail_inspect,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(replace(LNGS.STR_DATE_01, 'HH24:MI', '[HH24:MI]')), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    htp.tablerowclose;
  end if;

  -- P16: Wharf Collect
  if rid_cs is null
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold('Wharf Collect'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.formtext( 'P16', 25, 25, to_char(c3rec.wharf_collect,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(replace(LNGS.STR_DATE_01, 'HH24:MI', '[HH24:MI]')), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    htp.tablerowclose;
  end if;

  -- P17: AQIS Depot
  if rid_cs is null
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold('AQIS Depot'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      if vaccess = 'EDIT'
      then
        htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
        lov_list( 'AQISDEPOTS', 'P17', c3rec.aqis_depot, FALSE, FALSE, FALSE );
        htp.p( '</TD>' );
      else
        null;
      end if;
    htp.tablerowclose;
  end if;

  -- P18: Secondary Transport - delivering from AQIS to container park
  if rid_cs is null
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold('Secondary Transport'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.formtext( 'P18', 30, 100, c3rec.secondary_transport), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    htp.tablerowclose;
  end if;

  -- P19: AQIS Clearance
  if rid_cs is null
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold('AQIS Clearance'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.formtext( 'P19', 25, 25, to_char(c3rec.aqis_clearance,LNGS.STR_DATE_01)) || '&nbsp;' || htf.italic(replace(LNGS.STR_DATE_01, 'HH24:MI', '[HH24:MI]')), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    htp.tablerowclose;
  end if;

  -- P20 Destination
  if rid_cs is null
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold('Place of Delivery'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'LOCATIONS', 'P20', c3rec.destination, FALSE, TRUE, FALSE );
     htp.p( '</TD>' );
    htp.tablerowclose;
   end if;

  -- P9: Comment
  htp.tablerowopen;
   htp.tabledata( htf.bold('Comment'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P9', 60, 1000, c3rec.cmt), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
  htp.tablerowclose;

 htp.tableclose; -- Table 2
  htp.p('</TD>');
  htp.tablerowclose;

  htp.tablerowopen;

  htp.tablerowclose;

 -- Submit Buttons

  htp.p('<TD VALIGN="TOP">');
  if v_action = lngs.STR_STH_003 -- Update Record
  then
   htp.formsubmit( 'ACTION', lngs.STR_STH_003 ); -- Update Record
   htp.p('&nbsp;');
   htp.p( confirm_delete ( 'ACTION', lngs.STR_STH_004, 'Delete ' || c3rec.dan || ': Are you sure?' )); -- Delete
   htp.p('&nbsp;');
   htp.formsubmit( 'ACTION', lngs.STR_STH_007 ); -- Insert Another Record
  else
   htp.formsubmit( 'ACTION', lngs.STR_STH_002 ); -- Insert
  end if;
  htp.p('&nbsp;');
  htp.formsubmit( 'ACTION', lngs.STR_STH_005 ); -- List All Records
  htp.p('</TD>');

  htp.tablerowclose;
  htp.formclose;

  htp.tablerowopen;

  htp.formopen( 'strangsb.hbs' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'PARM', 'HBS' );
  htp.formhidden( 'ACCESS_ID', 'z' );
  htp.formhidden( 'RID_SS', replace(rid_ss,'~','+') );
  htp.formhidden( 'RID_BS', replace(rid_bs ,'~','+') );

  htp.p('<TD VALIGN="TOP">');
  htp.formsubmit( 'ACTION', lngs.STR_STH_012 ); -- Edit HBs
  htp.p('</TD>');
  htp.formclose;

  htp.tablerowclose;

  htp.tableclose; -- Table 1

 else
  null;
 end if;

exception when others then
 glbx.error_details( 'STRANGSB', 'DANS',null,null,errmsg=>sqlerrm,extdet=>'RID_SS:' || v_rid_ss || '; RID_BS: ' || v_rid_bs || '; RID_CS: ' || v_rid_cs );
end dans;

procedure accept_dans( surl in varchar2, rid_ss in rowid, rid_bs in rowid, rid_cs in rowid default null, rid_ds in rowid default null, parm in varchar2, access_id in varchar2, action in varchar2, p1 in varchar2, p2 in varchar2 default null, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2, p9 in varchar2, p10 in varchar2 default null, p11 in varchar2 default null, p12 in varchar2 default null, p13 in varchar2 default null, p14 in varchar2 default null, p15 in varchar2 default null, p16 in varchar2 default null, p17 in varchar2 default null, p18 in varchar2 default null, p19 in varchar2 default null, p20 in varchar2 default null )
is

cursor c1(rid_ds rowid) is select * from strang.dan_details_southbound where rowid = rid_ds;

cursor c2(rid_bs rowid) is select * from strang.bols_southbound where rowid = rid_bs;

cursor c3 (rid_bs rowid, v_dan varchar2) is
 select ds.rowid
 from  strang.dan_details_southbound ds, strang.bols_southbound bs
 where upper(ds.dan) = upper(v_dan)
    and upper(ds.ship) = upper(bs.ship)
    and upper(ds.voyage) = upper(bs.voyage)
    and upper(ds.bol) = upper(bs.bol)
    and bs.rowid = rid_bs
;
cursor c4(rid_cs rowid) is select * from strang.containers_southbound where rowid = rid_cs;
cursor c5(rid_bs rowid) is
 select max(ds.record_no)
 from   strang.dan_details_southbound ds, strang.bols_southbound bs
 where upper(ds.dan) = upper(dan)
    and upper(ds.ship) = upper(bs.ship)
    and upper(ds.voyage) = upper(bs.voyage)
    and upper(ds.bol) = upper(bs.bol)
    and bs.rowid = rid_bs
;

 c1rec     c1%ROWTYPE;
 c2rec     c2%ROWTYPE;
 c3rec     c3%ROWTYPE;
 c4rec     c4%ROWTYPE;
 owner_id  integer;
 ltype     varchar2(100);
 stype     integer;
 sts       varchar2(100);
 msg       varchar2(4000);
 nbr_val   number;
 recno     integer;
 v_rid_ss    rowid;
 v_rid_bs    rowid;
 v_rid_cs    rowid;
 v_rid_ds    rowid;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGSB.ACCEPT_DANS' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 v_rid_ss := replace(rid_ss, '~', '+');
 v_rid_bs := replace(rid_bs, '~', '+');
 v_rid_cs := replace(rid_cs, '~', '+');
 v_rid_ds := replace(rid_ds, '~', '+');

 open c2( v_rid_bs );
 fetch c2 into c2rec;
 if c2%NOTFOUND
  then
  htp.init;
  close c2;
  htp.htmlopen;
   htp.header(3,'Southbound BOLs', 'CENTER' );
   htp.header(3,'RECORD NOT FOUND', 'CENTER' );
   htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
   htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
   htp.nl;
   htp.header(2,'Extra Information: ROWID = ' || nvl(rid_bs , 'NULL'), 'CENTER' );
  htp.htmlclose;
  return;
 end if;
 close c2;

 if rid_cs is not null
  then
   open c4( v_rid_cs );
   fetch c4 into c4rec;
   if c4%NOTFOUND
    then
    htp.init;
    close c4;
    htp.htmlopen;
     htp.header(3,'Southbound Containers', 'CENTER' );
     htp.header(3,'RECORD NOT FOUND', 'CENTER' );
     htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
     htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
     htp.nl;
     htp.header(2,'Extra Information: ROWID = ' || nvl(v_rid_cs , 'NULL'), 'CENTER' );
    htp.htmlclose;
    return;
   end if;
   close c4;
 end if;

 if action = lngs.STR_STH_005 -- List All Records
  then
  dans(surl, rid_ss, rid_bs, rid_cs, rid_ds, 'DANS', lngs.STR_STH_005, 'z', null);
  return;
 elsif action = lngs.STR_STH_007 -- Insert Another Record
  then
  dans(surl, rid_ss, rid_bs, rid_cs, rid_ds, 'DANS', lngs.STR_STH_007, 'z', null);
  return;
 elsif action = lngs.STR_STH_011 -- Cancel
  then
  dans(surl, rid_ss, rid_bs, rid_cs, rid_ds, 'DANS', lngs.STR_STH_003, 'x', null);
  return;
 end if;

 if action = lngs.STR_STH_004 -- Delete
  then
  open c1 (v_rid_ds );
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
   close c1;
   htp.init;
   htp.htmlopen;
    htp.header(3,'Southbound DAN Details', 'CENTER' );
    htp.header(3,'RECORD NOT FOUND', 'CENTER' );
    htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
    htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
    htp.nl;
    htp.header(2,'Extra Information: ROWID = ' || nvl(v_rid_ds , 'NULL'), 'CENTER' );
   htp.htmlclose;
   return;
  else
   msg := 'DAN Details [' || c1rec.dan || '] DELETED';
   delete from strang.dan_details_southbound where rowid = v_rid_ds;
   commit;
   dans(surl, rid_ss, rid_bs, rid_cs, rid_ds, 'DANS', lngs.STR_STH_005, 'z', msg, null);
   return;
  end if;
 end if;

 -- Number Validation

 begin
  nbr_val := to_number(P5);
 exception when others then
  msg := msg || '[Pieces] ' || LNGS.STR_STH_010 || ': ' || P5 || '<BR>';
 end;

 begin
  nbr_val := to_number(P7);
 exception when others then
  msg := msg || '[Weight] ' || LNGS.STR_STH_010 || ': ' || P7 || '<BR>';
 end;

 begin
  nbr_val := to_number(P8);
 exception when others then
  msg := msg || '[Volume] ' || LNGS.STR_STH_010 || ': ' || P8 || '<BR>';
 end;

 if action = lngs.STR_STH_002 -- Insert New Record
  then

  if P1 is null
   then
    msg := msg || 'Please Enter DAN Number<BR>';
  else -- Check for existing DAN number
    open c3(v_rid_bs, trim(P1));
    fetch c3 into c3rec;
    if c3%FOUND
     then
     msg := msg || 'Record already exists for DAN [' || P1 || ']'; -- - rid = ' || rid_bs || '; dan = ' || trim(P1) || '<BR> Returns: ' || c3rec.rowid;
    end if;
    close c3;
  end if;

  if msg is not null
   then
   dans(surl, rid_ss, rid_bs, rid_cs, null, 'DANS', lngs.STR_STH_002, 'e', msg );
   return;
  end if;

  open c5(v_rid_bs);
  fetch c5 into recno;
  close c5;

  recno := nvl(recno, 0) + 1;

  insert into strang.dan_details_southbound (
       container
     , bol
     , ship
     , voyage
     , record_no
     , dan
     , hb
     , commodity
     , strang_invoice
     , pieces
     , packaging
     , kg
     , cbm
     , cmt
      )
  values (
       c4rec.container
     , c2rec.bol
     , c2rec.ship
     , c2rec.voyage
     , recno
     , P1
     , P2
     , P3
     , P4
     , P5
     , P6
     , P7
     , P8
     , P9
      )
  returning rowid into c3rec.rowid ;

  commit;

  dans(surl, rid_ss, rid_bs, rid_cs, c3rec.rowid, 'DANS', lngs.STR_STH_003, 'x', 'Record Inserted');
 elsif action = lngs.STR_STH_003 -- Update Record
  then

  if msg is not null
   then
   dans(surl, rid_ss, rid_bs, rid_cs, rid_ds, 'DANS', lngs.STR_STH_003, 'e', msg);
   return;
  end if;

  update strang.dan_details_southbound
  set  hb = P2
     , commodity = P3
     , strang_invoice = P4
     , pieces = P5
     , packaging = P6
     , kg = P7
     , cbm = P8
     , cmt = P9
  where rowid=rid_ds ;
  commit;
  dans(surl, rid_ss, rid_bs, rid_cs, rid_ds, 'DANS', lngs.STR_STH_003, 'x', 'Record Updated');
 end if;

exception when others then
 glbx.error_details( 'STRANGSB', 'ACCEPT_DANS',null,null,errmsg=>sqlerrm,extdet=>'RID_SS:' || rid_ss || '; RID_BS :' || rid_bs || '; RID_CS :' || rid_cs);
end accept_dans;

procedure accept_trac_search( surl in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2 )
is

cursor c1d (vv_con varchar, vv_cas varchar, vv_ctr varchar, vv_dan varchar, vv_tan varchar, v_date_from date, v_date_to date) is
 select ds.*, ss.sailing_date, bs.consignee, bs.customs_auth_no bs_customs_auth_no
 from   strang.dan_details_southbound ds, strang.ships_southbound ss, strang.bols_southbound bs
 where  ( vv_dan is null
          or
          ( vv_dan is not null and ds.dan like vv_dan || '%' )
        )
        and
        ( vv_tan is null
          or
          ( vv_tan is not null and ds.cmt like vv_tan || '%' )
        )
        and ss.ship = ds.ship
        and ss.voyage = ds.voyage
        and
        ( v_date_from is null
          or
          ( v_date_from is not null and ss.sailing_date >= v_date_from )
        )
        and
        ( v_date_to is null
          or
          ( v_date_to is not null and ss.sailing_date <= v_date_to )
        )
        and
        ( vv_ctr is null
          or
          ( vv_ctr is not null and ds.container like vv_ctr || '%' )
        )
        and
        ( vv_con is null
          or
          ( vv_con is not null
            and
            ( ds.ship || ':' || ds.voyage || ':' || ds.bol in ( select ship || ':' || voyage || ':' || bol
                                                                from   strang.bols_southbound
                                                                where  consignee in (select customer_id from strang.customers where customer_type='SOUTHBOUND' and upper(customer) like upper(vv_con) || '%')
                                                              )
              or
              ds.ship || ':' || ds.voyage || ':' || ds.hb in ( select ship || ':' || voyage || ':' || house_bill
                                                               from   strang.hbs_southbound
                                                               where  consignee in (select customer_id from strang.customers where customer_type='SOUTHBOUND' and upper(customer) like upper(vv_con) || '%')
                                                              )
            )
          )
        )
        and
        ( vv_cas is null
          or
          ( vv_cas is not null
            and
            ( upper(ds.customs_auth_no) like upper(vv_cas) || '%'
              or
              ds.ship || ':' || ds.voyage || ':' || ds.bol in ( select ship || ':' || voyage || ':' || bol
                                                                from   strang.bols_southbound
                                                                where  upper(customs_auth_no) like upper(vv_cas) || '%'
                                                              )
              or
              ds.ship || ':' || ds.voyage || ':' || ds.hb in ( select ship || ':' || voyage || ':' || house_bill
                                                               from   strang.hbs_southbound
                                                               where  upper(customs_auth_no) like upper(vv_cas) || '%'
                                                              )
            )
          )
        )
        and ds.bol = bs.bol
        and ds.ship = bs.ship
        and ds.voyage = bs.voyage
 ;

cursor c1c (vv_con varchar, vv_cas varchar, vv_ctr varchar, v_date_from date, v_date_to date) is
 select cs.*, ss.sailing_date, bs.consignee, bs.customs_auth_no bs_customs_auth_no
 from   strang.containers_southbound cs, strang.ships_southbound ss, strang.bols_southbound bs
 where  upper(cs.container) like vv_ctr || '%'
        and ss.ship = cs.ship
        and ss.voyage = cs.voyage
        and
        ( v_date_from is null
          or
          ( v_date_from is not null and ss.sailing_date >= v_date_from )
        )
        and
        ( v_date_to is null
          or
          ( v_date_to is not null and ss.sailing_date <= v_date_to )
        )
        and
        ( vv_con is null
          or
          ( vv_con is not null
            and
            ( cs.ship || ':' || cs.voyage || ':' || cs.bol in ( select ship || ':' || voyage || ':' || bol
                                                                from   strang.bols_southbound
                                                                where  consignee in (select customer_id from strang.customers where customer_type='SOUTHBOUND' and upper(customer) like upper(vv_con) || '%')
                                                              )
              or
              cs.ship || ':' || cs.voyage || ':' || cs.hb in ( select ship || ':' || voyage || ':' || house_bill
                                                               from   strang.hbs_southbound
                                                               where  consignee in (select customer_id from strang.customers where customer_type='SOUTHBOUND' and upper(customer) like upper(vv_con) || '%')
                                                              )
            )
          )
        )
        and
        ( vv_cas is null
          or
          ( vv_cas is not null
            and
            ( upper(cs.customs_auth_no) like upper(vv_cas) || '%'
              or
              cs.ship || ':' || cs.voyage || ':' || cs.bol in ( select ship || ':' || voyage || ':' || bol
                                                                from   strang.bols_southbound
                                                                where  upper(customs_auth_no) like upper(vv_cas) || '%'
                                                              )
              or
              cs.ship || ':' || cs.voyage || ':' || cs.hb in ( select ship || ':' || voyage || ':' || house_bill
                                                               from   strang.hbs_southbound
                                                               where  upper(customs_auth_no) like upper(vv_cas) || '%'
                                                              )
            )
          )
        )
        and cs.bol = bs.bol
        and cs.ship = bs.ship
        and cs.voyage = bs.voyage
 ;

cursor c2 (v_hb varchar2, v_ship varchar2, v_voy varchar2) is select * from strang.hbs_southbound where house_bill = v_hb and ship = v_ship and voyage = v_voy;
cursor c3 (v_ctr varchar2, v_ship varchar2, v_voy varchar2) is select * from strang.containers_southbound where container = v_ctr and ship = v_ship and voyage = v_voy order by container;
cursor c3h (v_ship varchar2, v_voy varchar2, v_hb varchar2) is select * from strang.containers_southbound where ship = v_ship and voyage = v_voy and hb is not null and hb = v_hb order by container;
cursor c3b (v_ship varchar2, v_voy varchar2, v_bol varchar2) is select * from strang.containers_southbound where ship = v_ship and voyage = v_voy and bol is not null and bol = v_bol order by container;
cursor c4 (v_ship varchar2, v_voy varchar2, v_ctr varchar2) is select * from strang.dan_details_southbound where ship = v_ship and voyage = v_voy and container = v_ctr order by dan;
cursor c4h (v_ship varchar2, v_voy varchar2, v_hb varchar2) is select * from strang.dan_details_southbound where ship = v_ship and voyage = v_voy and container is null and hb is not null and hb = v_hb order by dan;
cursor c4b (v_ship varchar2, v_voy varchar2, v_bol varchar2) is select * from strang.dan_details_southbound where ship = v_ship and voyage = v_voy and container is null and bol is not null and bol = v_bol order by dan;
cursor c5d (vv_cas varchar, v_date_from date, v_date_to date) is
 select ds.*, ss.sailing_date, bs.consignee, bs.customs_auth_no bs_customs_auth_no
 from   strang.dan_details_southbound ds, strang.ships_southbound ss, strang.bols_southbound bs
 where  upper(trim(ds.customs_auth_no)) like vv_cas || '%'
        and ss.ship = ds.ship
        and ss.voyage = ds.voyage
        and
        ( v_date_from is null
          or
          ( v_date_from is not null and ss.sailing_date >= v_date_from )
        )
        and
        ( v_date_to is null
          or
          ( v_date_to is not null and ss.sailing_date <= v_date_to )
        )
        and not exists ( select 'x' from strang.containers_southbound
                         where  container = ds.container
                                and ship = ds.ship
                                and voyage = ds.voyage
                                and upper(trim(customs_auth_no)) like vv_cas || '%'
                          UNION ALL
                         select 'x' from strang.hbs_southbound
                         where  house_bill = ds.hb
                                and ship = ds.ship
                                and voyage = ds.voyage
                                and upper(trim(customs_auth_no)) like vv_cas || '%'
                          UNION ALL
                         select 'x' from strang.bols_southbound
                         where  bol = ds.bol
                                and ship = ds.ship
                                and voyage = ds.voyage
                                and upper(trim(customs_auth_no)) like vv_cas || '%'
                       )
 ;
cursor c5c (vv_cas varchar, v_date_from date, v_date_to date) is
 select cs.*, ss.sailing_date, bs.consignee, bs.customs_auth_no bs_customs_auth_no
 from   strang.containers_southbound cs, strang.ships_southbound ss, strang.bols_southbound bs
 where  upper(trim(cs.customs_auth_no)) like vv_cas || '%'
        and ss.ship = cs.ship
        and ss.voyage = cs.voyage
        and
        ( v_date_from is null
          or
          ( v_date_from is not null and ss.sailing_date >= v_date_from )
        )
        and
        ( v_date_to is null
          or
          ( v_date_to is not null and ss.sailing_date <= v_date_to )
        )
        and cs.bol = bs.bol
        and cs.ship = bs.ship
        and cs.voyage = bs.voyage
        and not exists ( select 'x' from strang.hbs_southbound
                         where  house_bill = cs.hb
                                and ship = cs.ship
                                and voyage = cs.voyage
                                and upper(trim(customs_auth_no)) like vv_cas || '%'
                          UNION ALL
                         select 'x' from strang.bols_southbound
                         where  bol = cs.bol
                                and ship = cs.ship
                                and voyage = cs.voyage
                                and upper(trim(customs_auth_no)) like vv_cas || '%'
                       )
 ;

cursor c5h (vv_cas varchar, v_date_from date, v_date_to date) is
 select hs.*, ss.sailing_date, bs.consignee bs_consignee, bs.customs_auth_no bs_customs_auth_no
 from   strang.hbs_southbound hs, strang.ships_southbound ss, strang.bols_southbound bs
 where  upper(trim(hs.customs_auth_no)) like vv_cas || '%'
        and ss.ship = hs.ship
        and ss.voyage = hs.voyage
        and
        ( v_date_from is null
          or
          ( v_date_from is not null and ss.sailing_date >= v_date_from )
        )
        and
        ( v_date_to is null
          or
          ( v_date_to is not null and ss.sailing_date <= v_date_to )
        )
        and hs.bol = bs.bol
        and hs.ship = bs.ship
        and hs.voyage = bs.voyage
        and not exists ( select 'x' from strang.bols_southbound
                         where  bol = hs.bol
                                and ship = hs.ship
                                and voyage = hs.voyage
                                and upper(trim(customs_auth_no)) like vv_cas || '%'
                       )
 ;

cursor c5b (vv_cas varchar, v_date_from date, v_date_to date) is
 select bs.*, ss.sailing_date
 from   strang.ships_southbound ss, strang.bols_southbound bs
 where  upper(trim(bs.customs_auth_no)) like vv_cas || '%'
        and ss.ship = bs.ship
        and ss.voyage = bs.voyage
        and
        ( v_date_from is null
          or
          ( v_date_from is not null and ss.sailing_date >= v_date_from )
        )
        and
        ( v_date_to is null
          or
          ( v_date_to is not null and ss.sailing_date <= v_date_to )
        )
 ;

cursor c6h (vv_con varchar2, vv_cas varchar, v_date_from date, v_date_to date) is
 select hs.*, ss.sailing_date, bs.consignee bs_consignee, bs.customs_auth_no bs_customs_auth_no
 from   strang.hbs_southbound hs, strang.ships_southbound ss, strang.bols_southbound bs
 where
        ( vv_cas is null
          or
          ( vv_cas is not null and upper(trim(hs.customs_auth_no)) like vv_cas || '%' )
        )
        and
        ( vv_con is null
          or
          ( vv_con is not null
            and
            ( hs.ship || ':' || hs.voyage || ':' || hs.house_bill in ( select ship || ':' || voyage || ':' || house_bill
                                                                       from   strang.hbs_southbound
                                                                       where  consignee in (select customer_id from strang.customers where customer_type='SOUTHBOUND' and upper(customer) like upper(vv_con) || '%')
                                                                     )
            )
          )
        )
        and ss.ship = hs.ship
        and ss.voyage = hs.voyage
        and
        ( v_date_from is null
          or
          ( v_date_from is not null and ss.sailing_date >= v_date_from )
        )
        and
        ( v_date_to is null
          or
          ( v_date_to is not null and ss.sailing_date <= v_date_to )
        )
        and hs.bol = bs.bol
        and hs.ship = bs.ship
        and hs.voyage = bs.voyage
        and bs.consignee not in (select customer_id from strang.customers where customer_type='SOUTHBOUND' and upper(customer) like upper(vv_con) || '%' )
 ;

cursor c6b (vv_con varchar2, vv_cas varchar, v_date_from date, v_date_to date) is
 select bs.*, ss.sailing_date
 from   strang.ships_southbound ss, strang.bols_southbound bs
 where  upper(trim(bs.customs_auth_no)) like vv_cas || '%'
        and ss.ship = bs.ship
        and ss.voyage = bs.voyage
        and bs.consignee in (select customer_id from strang.customers where customer_type='SOUTHBOUND' and upper(customer) like upper(vv_con) || '%' )
        and
        ( v_date_from is null
          or
          ( v_date_from is not null and ss.sailing_date >= v_date_from )
        )
        and
        ( v_date_to is null
          or
          ( v_date_to is not null and ss.sailing_date <= v_date_to )
        )
 ;

 stype       integer;
 ltype       varchar2(100);
 owner_id    integer;
 sts         varchar2(100);
 cusrec      customer_account%ROWTYPE;
 pfx         THEME%ROWTYPE;
 clr         varchar2(100);
 strcusrec   strang.customers%ROWTYPE;

 c2rec       c2%ROWTYPE;
 c3rec       c3%ROWTYPE;

 v_con       varchar2(100);
 v_cas       strang.hbs_southbound.customs_auth_no%TYPE;
 v_ctr       strang.containers_southbound.container%TYPE;
 v_dan       strang.dan_details_southbound.dan%TYPE;
 v_tan       strang.dan_details_southbound.cmt%TYPE;
 date_from   date;
 date_to     date;
 dan_ctr     integer;
 cntr_ctr    integer;

 msg         varchar2(4000);

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGSB.ACCEPT_TRAC_SEARCH' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;
 cusrec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( cusrec.theme_name );

-- Date Validation

if p6 is not null
 then
  begin
   date_from := to_date(p6,LNGS.STR_DATE_01);
  exception when others then
   msg := msg || '[Date From] ' || LNGS.STR_TXT_152 || ': ' || p6 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
  end;
end if;

if p7 is not null
 then
  begin
   date_to := to_date(p7,LNGS.STR_DATE_01);
  exception when others then
   msg := msg || '[Date To] ' || LNGS.STR_TXT_152 || ': ' || p7 || '. ' || initcap(LNGS.STR_TXT_153) || ': ' || LNGS.STR_DATE_01 || '<BR>';
  end;
end if;

if msg is not null
 then
  strangp.trac_search( surl, msg );
  return;
end if;

glbx.main_title( surl, LNGS.STR_TXT_443,glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'STR16',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

htp.p( '<CENTER>' );
htp.tableopen( cattributes=>'cellpadding=2 cellspacing=10 border=0' );
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNGS.STR_TXT_444 ), ' ALIGN="LEFT"');
  htp.tabledata( htf.bold( LNGS.STR_TXT_445 ), ' ALIGN="LEFT"');
  htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNGS.STR_TXT_446 ), ' ALIGN="LEFT"');
  htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
  htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
  htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
  htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
 htp.tablerowclose;
htp.tableclose;

-- Alternate Colours + Header Colour
htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tabledata( htf.bold( 'Ship' ), ' ALIGN="CENTER"');
  htp.tabledata( htf.bold( 'Voyage' ), ' ALIGN="CENTER"');
  htp.tabledata( htf.bold( 'BOL' ), ' ALIGN="CENTER"');
  htp.tabledata( htf.bold( 'BOL Consignee' ), ' ALIGN="CENTER"');
  htp.tabledata( htf.bold( 'HB' ), ' ALIGN="CENTER"');
  htp.tabledata( htf.bold( 'HB Consignee' ), ' ALIGN="CENTER"');
  htp.tabledata( htf.bold( 'Container' ), ' ALIGN="CENTER"');
  htp.tabledata( htf.bold( 'Customs Authority Number' ), ' ALIGN="CENTER"');
  htp.tabledata( htf.bold( 'OTML DAN Number' ), ' ALIGN="CENTER"');
  htp.tabledata( htf.bold( 'OTML Tracking Order Number' ), ' ALIGN="CENTER"');
  htp.tabledata( htf.bold( 'Sailing Date' ), ' ALIGN="CENTER"');
  htp.tabledata( htf.bold( 'Strang Invoice Number' ), ' ALIGN="CENTER"');
 htp.tablerowclose;


v_con := upper(trim(p1));
v_cas := upper(trim(p2));
v_ctr := upper(replace(p3,' ',''));
v_dan := upper(trim(p4));
v_tan := upper(trim(p5));

if p4 is not null or p5 is not null -- DAN details
 then
  for c1drec in c1d( v_con, v_cas, v_ctr, v_dan, v_tan, date_from, date_to) loop
  if mod(c1d%ROWCOUNT,2) = 1
   then
    clr := glbx.QUERY_CELL_BACKGROUND;
   else
    clr := 'bgcolor="#FFFFFF"';
  end if;
   htp.tablerowopen;
    htp.tabledata( c1drec.ship, cattributes=> clr || ' ALIGN="LEFT"');
    htp.tabledata( c1drec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
    htp.tabledata( c1drec.bol, cattributes=> clr || ' ALIGN="LEFT"');
    strcusrec := customer_details(c1drec.consignee);
    htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
    htp.tabledata( c1drec.hb, cattributes=> clr || ' ALIGN="LEFT"');
    c2rec:= null;
    strcusrec := null;
    if c1drec.hb is not null
     then
      open c2(c1drec.hb, c1drec.ship, c1drec.voyage);
      fetch c2 into c2rec;
      close c2;
      strcusrec := customer_details(c2rec.consignee);
    end if;
    htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
    htp.tabledata( c1drec.container, cattributes=> clr || ' ALIGN="LEFT"');
    htp.tabledata( nvl(c1drec.customs_auth_no, nvl(c2rec.customs_auth_no, c1drec.bs_customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
    htp.tabledata( c1drec.dan, cattributes=> clr || ' ALIGN="LEFT"');
    htp.tabledata( c1drec.cmt, cattributes=> clr || ' ALIGN="LEFT"');
    htp.tabledata( to_char(c1drec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
    c3rec.strang_invoice := null;
    if c1drec.container is not null
     then
      open c3(c1drec.container, c1drec.ship, c1drec.voyage);
      fetch c3 into c3rec;
      close c3;
    end if;
    htp.tabledata( nvl(c3rec.strang_invoice, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tablerowclose;
  end loop;
elsif p3 is not null                -- Container Number
 then
  for c1crec in c1c( v_con, v_cas, v_ctr, date_from, date_to) loop
   if mod(c1c%ROWCOUNT,2) = 1
    then
     clr := glbx.QUERY_CELL_BACKGROUND;
    else
     clr := 'bgcolor="#FFFFFF"';
   end if;
   dan_ctr := 0;
   for c4rec in c4(c1crec.ship, c1crec.voyage, c1crec.container) loop
    htp.tablerowopen;
     if dan_ctr = 0
      then
       htp.tabledata( c1crec.ship, cattributes=> clr || ' ALIGN="LEFT"');
       htp.tabledata( c1crec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
       htp.tabledata( c1crec.bol, cattributes=> clr || ' ALIGN="LEFT"');
       strcusrec := customer_details(c1crec.consignee);
       htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
       htp.tabledata( c1crec.hb, cattributes=> clr || ' ALIGN="LEFT"');
       strcusrec:= null;
       c2rec:= null;
       if c1crec.hb is not null
        then
         open c2(c1crec.hb, c1crec.ship, c1crec.voyage);
         fetch c2 into c2rec;
         close c2;
         strcusrec := customer_details(c2rec.consignee);
       end if;
       htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
       htp.tabledata( c1crec.container, cattributes=> clr || ' ALIGN="LEFT"');
       htp.tabledata( nvl(c1crec.customs_auth_no, nvl(c2rec.customs_auth_no, c1crec.bs_customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
     else
       htp.tabledata( null, cattributes=> clr || ' COLSPAN="8"');
     end if;
     htp.tabledata( c4rec.dan, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c4rec.cmt, cattributes=> clr || ' ALIGN="LEFT"');
     if dan_ctr = 0
      then
       htp.tabledata( to_char(c1crec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
       c3rec.strang_invoice := null;
       if c1crec.container is not null
        then
         open c3(c1crec.container, c1crec.ship, c1crec.voyage);
         fetch c3 into c3rec;
         close c3;
       end if;
       htp.tabledata( nvl(c3rec.strang_invoice, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
      else
       htp.tabledata( '&nbsp;', cattributes=> clr || ' COLSPAN="2"');
     end if;
   htp.tablerowclose;
    dan_ctr := dan_ctr + 1;
   end loop;
   if dan_ctr = 0
    then
    htp.tablerowopen;
     htp.tabledata( c1crec.ship, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c1crec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c1crec.bol, cattributes=> clr || ' ALIGN="LEFT"');
     strcusrec := customer_details(c1crec.consignee);
     htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c1crec.hb, cattributes=> clr || ' ALIGN="LEFT"');
     c2rec:= null;
     strcusrec := null;
     if c1crec.hb is not null
      then
       open c2(c1crec.hb, c1crec.ship, c1crec.voyage);
       fetch c2 into c2rec;
       close c2;
       strcusrec := customer_details(c2rec.consignee);
     end if;
     htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c1crec.container, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( nvl(c1crec.customs_auth_no, nvl(c2rec.customs_auth_no, c1crec.bs_customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( to_char(c1crec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
     c3rec.strang_invoice := null;
     if c1crec.container is not null
      then
       open c3(c1crec.container, c1crec.ship, c1crec.voyage);
       fetch c3 into c3rec;
       close c3;
     end if;
     htp.tabledata( nvl(c3rec.strang_invoice, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
    htp.tablerowclose;
   end if;
  end loop;
elsif p1 is null and p2 is not null -- All matching DANs, containers, HBs and BOLs, based on Customs Authority Number
 then
 -- DANs
  for c5drec in c5d( v_cas, date_from, date_to) loop
  if mod(c5d%ROWCOUNT,2) = 1
   then
    clr := glbx.QUERY_CELL_BACKGROUND;
   else
    clr := 'bgcolor="#FFFFFF"';
  end if;
   htp.tablerowopen;
    htp.tabledata( c5drec.ship, cattributes=> clr || ' ALIGN="LEFT"');
    htp.tabledata( c5drec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
    htp.tabledata( c5drec.bol, cattributes=> clr || ' ALIGN="LEFT"');
    strcusrec := customer_details(c5drec.consignee);
    htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
    htp.tabledata( c5drec.hb, cattributes=> clr || ' ALIGN="LEFT"');
    c2rec:= null;
    strcusrec := null;
    if c5drec.hb is not null
     then
      open c2(c5drec.hb, c5drec.ship, c5drec.voyage);
      fetch c2 into c2rec;
      close c2;
      strcusrec := customer_details(c2rec.consignee);
    end if;
    htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
    htp.tabledata( c5drec.container, cattributes=> clr || ' ALIGN="LEFT"');
    htp.tabledata( nvl(c5drec.customs_auth_no, nvl(c2rec.customs_auth_no, c5drec.bs_customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
    htp.tabledata( c5drec.dan, cattributes=> clr || ' ALIGN="LEFT"');
    htp.tabledata( c5drec.cmt, cattributes=> clr || ' ALIGN="LEFT"');
    htp.tabledata( to_char(c5drec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
    c3rec.strang_invoice := null;
    if c5drec.container is not null
     then
      open c3(c5drec.container, c5drec.ship, c5drec.voyage);
      fetch c3 into c3rec;
      close c3;
    end if;
    htp.tabledata( nvl(c3rec.strang_invoice, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tablerowclose;
  end loop;
 -- Containers
  for c5crec in c5c( v_cas, date_from, date_to) loop
   if mod(c5c%ROWCOUNT,2) = 1
    then
     clr := glbx.QUERY_CELL_BACKGROUND;
    else
     clr := 'bgcolor="#FFFFFF"';
   end if;
   dan_ctr := 0;
   for c4rec in c4(c5crec.ship, c5crec.voyage, c5crec.container) loop
    htp.tablerowopen;
     if dan_ctr = 0
      then
       htp.tabledata( c5crec.ship, cattributes=> clr || ' ALIGN="LEFT"');
       htp.tabledata( c5crec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
       htp.tabledata( c5crec.bol, cattributes=> clr || ' ALIGN="LEFT"');
       strcusrec := customer_details(c5crec.consignee);
       htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
       htp.tabledata( c5crec.hb, cattributes=> clr || ' ALIGN="LEFT"');
       strcusrec:= null;
       c2rec:= null;
       if c5crec.hb is not null
        then
         open c2(c5crec.hb, c5crec.ship, c5crec.voyage);
         fetch c2 into c2rec;
         close c2;
         strcusrec := customer_details(c2rec.consignee);
       end if;
       htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
       htp.tabledata( c5crec.container, cattributes=> clr || ' ALIGN="LEFT"');
       htp.tabledata( nvl(c5crec.customs_auth_no, nvl(c2rec.customs_auth_no, c5crec.bs_customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
     else
       htp.tabledata( null, cattributes=> clr || ' COLSPAN="8"');
     end if;
     htp.tabledata( c4rec.dan, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c4rec.cmt, cattributes=> clr || ' ALIGN="LEFT"');
     if dan_ctr = 0
      then
       htp.tabledata( to_char(c5crec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
       c3rec.strang_invoice := null;
       if c5crec.container is not null
        then
         open c3(c5crec.container, c5crec.ship, c5crec.voyage);
         fetch c3 into c3rec;
         close c3;
       end if;
       htp.tabledata( nvl(c3rec.strang_invoice, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
      else
       htp.tabledata( '&nbsp;', cattributes=> clr || ' COLSPAN="2"');
     end if;
    htp.tablerowclose;
    dan_ctr := dan_ctr + 1;
   end loop;
   if dan_ctr = 0
    then
    htp.tablerowopen;
     htp.tabledata( c5crec.ship, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c5crec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c5crec.bol, cattributes=> clr || ' ALIGN="LEFT"');
     strcusrec := customer_details(c5crec.consignee);
     htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c5crec.hb, cattributes=> clr || ' ALIGN="LEFT"');
     c2rec:= null;
     strcusrec := null;
     if c5crec.hb is not null
      then
       open c2(c5crec.hb, c5crec.ship, c5crec.voyage);
       fetch c2 into c2rec;
       close c2;
       strcusrec := customer_details(c2rec.consignee);
     end if;
     htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c5crec.container, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( nvl(c5crec.customs_auth_no, nvl(c2rec.customs_auth_no, c5crec.bs_customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( to_char(c5crec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
     c3rec.strang_invoice := null;
     if c5crec.container is not null
      then
       open c3(c5crec.container, c5crec.ship, c5crec.voyage);
       fetch c3 into c3rec;
       close c3;
     end if;
     htp.tabledata( nvl(c3rec.strang_invoice, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
    htp.tablerowclose;
   end if;
  end loop;
 -- HBs
  for c5hrec in c5h( v_cas, date_from, date_to) loop
   if mod(c5h%ROWCOUNT,2) = 1
    then
     clr := glbx.QUERY_CELL_BACKGROUND;
    else
     clr := 'bgcolor="#FFFFFF"';
   end if;
   dan_ctr := 0;
   cntr_ctr := 0;
   for c3hrec in c3h(c5hrec.ship, c5hrec.voyage, c5hrec.house_bill) loop -- Containers
    cntr_ctr := cntr_ctr + 1;
    for c4rec in c4(c3hrec.ship, c3hrec.voyage, c3hrec.container) loop -- DANS
     htp.tablerowopen;
      if dan_ctr = 0
       then
        htp.tabledata( c5hrec.ship, cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( c5hrec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( c5hrec.bol, cattributes=> clr || ' ALIGN="LEFT"');
        strcusrec := customer_details(c5hrec.consignee);
        htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( c5hrec.house_bill, cattributes=> clr || ' ALIGN="LEFT"');
        strcusrec:= null;
        c2rec:= null;
        open c2(c5hrec.house_bill, c5hrec.ship, c5hrec.voyage);
        fetch c2 into c2rec;
        close c2;
        strcusrec := customer_details(c2rec.consignee);
        htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( c3hrec.container, cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( nvl(c5hrec.customs_auth_no, nvl(c2rec.customs_auth_no, c3hrec.customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
      else
        htp.tabledata( null, cattributes=> clr || ' COLSPAN="8"');
      end if;
      htp.tabledata( c4rec.dan, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c4rec.cmt, cattributes=> clr || ' ALIGN="LEFT"');
      if dan_ctr = 0
       then
        htp.tabledata( to_char(c5hrec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( nvl(c3hrec.strang_invoice, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
       else
        htp.tabledata( '&nbsp;', cattributes=> clr || ' COLSPAN="2"');
      end if;
     htp.tablerowclose;
     dan_ctr := dan_ctr + 1;
    end loop; -- c4
    if dan_ctr = 0
     then
      htp.tabledata( c5hrec.ship, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c5hrec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c5hrec.bol, cattributes=> clr || ' ALIGN="LEFT"');
      strcusrec := customer_details(c5hrec.consignee);
      htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c3hrec.hb, cattributes=> clr || ' ALIGN="LEFT"');
      strcusrec:= null;
      c2rec:= null;
      open c2(c3hrec.hb, c3hrec.ship, c3hrec.voyage);
      fetch c2 into c2rec;
      close c2;
      strcusrec := customer_details(c2rec.consignee);
      htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c3hrec.container, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( nvl(c5hrec.customs_auth_no, nvl(c2rec.customs_auth_no, c3hrec.customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( to_char(c5hrec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( nvl(c3hrec.strang_invoice, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tablerowclose;
    end if;
   end loop; -- c3h
   for c4hrec in c4h(c5hrec.ship, c5hrec.voyage, c5hrec.house_bill) loop -- Break-Bulk DANs
    htp.tablerowopen;
     htp.tabledata( c5hrec.ship, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c5hrec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c5hrec.bol, cattributes=> clr || ' ALIGN="LEFT"');
     strcusrec := customer_details(c5hrec.consignee);
     htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c5hrec.house_bill, cattributes=> clr || ' ALIGN="LEFT"');
     strcusrec:= null;
     c2rec:= null;
     open c2(c5hrec.house_bill, c5hrec.ship, c5hrec.voyage);
     fetch c2 into c2rec;
     close c2;
     strcusrec := customer_details(c2rec.consignee);
     htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( nvl(c5hrec.customs_auth_no, nvl(c2rec.customs_auth_no, c4hrec.customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c4hrec.dan, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c4hrec.cmt, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( to_char(c5hrec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
    htp.tablerowclose;
   end loop; -- c4h
   if cntr_ctr = 0 and dan_ctr = 0
    then
     htp.tablerowopen;
      htp.tabledata( c5hrec.ship, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c5hrec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c5hrec.bol, cattributes=> clr || ' ALIGN="LEFT"');
      strcusrec := customer_details(c5hrec.consignee);
      htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c5hrec.house_bill, cattributes=> clr || ' ALIGN="LEFT"');
      strcusrec:= null;
      c2rec:= null;
      open c2(c5hrec.house_bill, c5hrec.ship, c5hrec.voyage);
      fetch c2 into c2rec;
      close c2;
      strcusrec := customer_details(c2rec.consignee);
      htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( nvl(c5hrec.customs_auth_no, c2rec.customs_auth_no), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( to_char(c5hrec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
  end loop; -- c5h
 -- BOLs
  for c5brec in c5b( v_cas, date_from, date_to) loop
   if mod(c5b%ROWCOUNT,2) = 1
    then
     clr := glbx.QUERY_CELL_BACKGROUND;
    else
     clr := 'bgcolor="#FFFFFF"';
   end if;
   dan_ctr := 0;
   cntr_ctr := 0;
   for c3brec in c3b(c5brec.ship, c5brec.voyage, c5brec.bol) loop -- Containers
    cntr_ctr := cntr_ctr + 1;
    for c4rec in c4(c3brec.ship, c3brec.voyage, c3brec.container) loop -- DANS
     htp.tablerowopen;
      if dan_ctr = 0
       then
        htp.tabledata( c5brec.ship, cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( c5brec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( c5brec.bol, cattributes=> clr || ' ALIGN="LEFT"');
        strcusrec := customer_details(c5brec.consignee);
        htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( c3brec.hb, cattributes=> clr || ' ALIGN="LEFT"');
        strcusrec:= null;
        c2rec:= null;
        open c2(c3brec.hb, c3brec.ship, c3brec.voyage);
        fetch c2 into c2rec;
        close c2;
        strcusrec := customer_details(c2rec.consignee);
        htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( c3brec.container, cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( nvl(c5brec.customs_auth_no, nvl(c2rec.customs_auth_no, c3brec.customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
      else
        htp.tabledata( null, cattributes=> clr || ' COLSPAN="8"');
      end if;
      htp.tabledata( c4rec.dan, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c4rec.cmt, cattributes=> clr || ' ALIGN="LEFT"');
      if dan_ctr = 0
       then
        htp.tabledata( to_char(c5brec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( nvl(c3brec.strang_invoice, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
       else
        htp.tabledata( '&nbsp;', cattributes=> clr || ' COLSPAN="2"');
      end if;
     htp.tablerowclose;
     dan_ctr := dan_ctr + 1;
    end loop; -- c4
    if dan_ctr = 0
     then
      htp.tabledata( c5brec.ship, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c5brec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c5brec.bol, cattributes=> clr || ' ALIGN="LEFT"');
      strcusrec := customer_details(c5brec.consignee);
      htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c3brec.hb, cattributes=> clr || ' ALIGN="LEFT"');
      strcusrec:= null;
      c2rec:= null;
      open c2(c3brec.hb, c3brec.ship, c3brec.voyage);
      fetch c2 into c2rec;
      close c2;
      strcusrec := customer_details(c2rec.consignee);
      htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c3brec.container, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( nvl(c5brec.customs_auth_no, nvl(c2rec.customs_auth_no, c3brec.customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( to_char(c5brec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( nvl(c3brec.strang_invoice, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tablerowclose;
    end if;
   end loop; -- c3b
   for c4brec in c4b(c5brec.ship, c5brec.voyage, c5brec.bol) loop -- Break-Bulk DANs
    htp.tablerowopen;
     htp.tabledata( c5brec.ship, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c5brec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c5brec.bol, cattributes=> clr || ' ALIGN="LEFT"');
     strcusrec := customer_details(c5brec.consignee);
     htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c4brec.hb, cattributes=> clr || ' ALIGN="LEFT"');
     strcusrec:= null;
     c2rec:= null;
     open c2(c4brec.hb, c4brec.ship, c4brec.voyage);
     fetch c2 into c2rec;
     close c2;
     strcusrec := customer_details(c2rec.consignee);
     htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( nvl(c5brec.customs_auth_no, nvl(c2rec.customs_auth_no, c4brec.customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c4brec.dan, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c4brec.cmt, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( to_char(c5brec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
    htp.tablerowclose;
   end loop; -- c4h
   if cntr_ctr = 0 and dan_ctr = 0
    then
     htp.tablerowopen;
      htp.tabledata( c5brec.ship, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c5brec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c5brec.bol, cattributes=> clr || ' ALIGN="LEFT"');
      strcusrec := customer_details(c5brec.consignee);
      htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c5brec.customs_auth_no, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( to_char(c5brec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
  end loop; -- c5b
else                                -- All matching HBs/BOLs, based on consignee or Customs Authority Number
 -- HBs
  for c6hrec in c6h( v_con, v_cas, date_from, date_to) loop
   if mod(c6h%ROWCOUNT,2) = 1
    then
     clr := glbx.QUERY_CELL_BACKGROUND;
    else
     clr := 'bgcolor="#FFFFFF"';
   end if;
   dan_ctr := 0;
   cntr_ctr := 0;
   for c3hrec in c3h(c6hrec.ship, c6hrec.voyage, c6hrec.house_bill) loop -- Containers
    cntr_ctr := cntr_ctr + 1;
    for c4rec in c4(c3hrec.ship, c3hrec.voyage, c3hrec.container) loop -- DANS
     htp.tablerowopen;
      if dan_ctr = 0
       then
        htp.tabledata( c6hrec.ship, cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( c6hrec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( c6hrec.bol, cattributes=> clr || ' ALIGN="LEFT"');
        strcusrec := customer_details(c6hrec.consignee);
        htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( c6hrec.house_bill, cattributes=> clr || ' ALIGN="LEFT"');
        strcusrec:= null;
        c2rec:= null;
        open c2(c6hrec.house_bill, c6hrec.ship, c6hrec.voyage);
        fetch c2 into c2rec;
        close c2;
        strcusrec := customer_details(c2rec.consignee);
        htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( c3hrec.container, cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( nvl(c6hrec.customs_auth_no, nvl(c2rec.customs_auth_no, c3hrec.customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
      else
        htp.tabledata( null, cattributes=> clr || ' COLSPAN="8"');
      end if;
      htp.tabledata( c4rec.dan, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c4rec.cmt, cattributes=> clr || ' ALIGN="LEFT"');
      if dan_ctr = 0
       then
        htp.tabledata( to_char(c6hrec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( nvl(c3hrec.strang_invoice, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
       else
        htp.tabledata( '&nbsp;', cattributes=> clr || ' COLSPAN="2"');
      end if;
     htp.tablerowclose;
     dan_ctr := dan_ctr + 1;
    end loop; -- c4
    if dan_ctr = 0
     then
      htp.tabledata( c6hrec.ship, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c6hrec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c6hrec.bol, cattributes=> clr || ' ALIGN="LEFT"');
      strcusrec := customer_details(c6hrec.consignee);
      htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c3hrec.hb, cattributes=> clr || ' ALIGN="LEFT"');
      strcusrec:= null;
      c2rec:= null;
      open c2(c3hrec.hb, c3hrec.ship, c3hrec.voyage);
      fetch c2 into c2rec;
      close c2;
      strcusrec := customer_details(c2rec.consignee);
      htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c3hrec.container, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( nvl(c6hrec.customs_auth_no, nvl(c2rec.customs_auth_no, c3hrec.customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( to_char(c6hrec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( nvl(c3hrec.strang_invoice, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tablerowclose;
    end if;
   end loop; -- c3h
   for c4hrec in c4h(c6hrec.ship, c6hrec.voyage, c6hrec.house_bill) loop -- Break-Bulk DANs
    htp.tablerowopen;
     htp.tabledata( c6hrec.ship, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c6hrec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c6hrec.bol, cattributes=> clr || ' ALIGN="LEFT"');
     strcusrec := customer_details(c6hrec.consignee);
     htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c6hrec.house_bill, cattributes=> clr || ' ALIGN="LEFT"');
     strcusrec:= null;
     c2rec:= null;
     open c2(c6hrec.house_bill, c6hrec.ship, c6hrec.voyage);
     fetch c2 into c2rec;
     close c2;
     strcusrec := customer_details(c2rec.consignee);
     htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( nvl(c6hrec.customs_auth_no, nvl(c2rec.customs_auth_no, c4hrec.customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c4hrec.dan, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c4hrec.cmt, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( to_char(c6hrec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
    htp.tablerowclose;
   end loop; -- c4h
   if cntr_ctr = 0 and dan_ctr = 0
    then
     htp.tablerowopen;
      htp.tabledata( c6hrec.ship, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c6hrec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c6hrec.bol, cattributes=> clr || ' ALIGN="LEFT"');
      strcusrec := customer_details(c6hrec.consignee);
      htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c6hrec.house_bill, cattributes=> clr || ' ALIGN="LEFT"');
      strcusrec:= null;
      c2rec:= null;
      open c2(c6hrec.house_bill, c6hrec.ship, c6hrec.voyage);
      fetch c2 into c2rec;
      close c2;
      strcusrec := customer_details(c2rec.consignee);
      htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( nvl(c6hrec.customs_auth_no, c2rec.customs_auth_no), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( to_char(c6hrec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
  end loop; -- c6h
 -- BOLs
  for c6brec in c6b( v_con, v_cas, date_from, date_to) loop
   if mod(c6b%ROWCOUNT,2) = 1
    then
     clr := glbx.QUERY_CELL_BACKGROUND;
    else
     clr := 'bgcolor="#FFFFFF"';
   end if;
   dan_ctr := 0;
   cntr_ctr := 0;
   for c3brec in c3b(c6brec.ship, c6brec.voyage, c6brec.bol) loop -- Containers
    cntr_ctr := cntr_ctr + 1;
    for c4rec in c4(c3brec.ship, c3brec.voyage, c3brec.container) loop -- DANS
     htp.tablerowopen;
      if dan_ctr = 0
       then
        htp.tabledata( c6brec.ship, cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( c6brec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( c6brec.bol, cattributes=> clr || ' ALIGN="LEFT"');
        strcusrec := customer_details(c6brec.consignee);
        htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( c3brec.hb, cattributes=> clr || ' ALIGN="LEFT"');
        strcusrec:= null;
        c2rec:= null;
        open c2(c3brec.hb, c3brec.ship, c3brec.voyage);
        fetch c2 into c2rec;
        close c2;
        strcusrec := customer_details(c2rec.consignee);
        htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( c3brec.container, cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( nvl(c6brec.customs_auth_no, nvl(c2rec.customs_auth_no, c3brec.customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
      else
        htp.tabledata( null, cattributes=> clr || ' COLSPAN="8"');
      end if;
      htp.tabledata( c4rec.dan, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c4rec.cmt, cattributes=> clr || ' ALIGN="LEFT"');
      if dan_ctr = 0
       then
        htp.tabledata( to_char(c6brec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
        htp.tabledata( nvl(c3brec.strang_invoice, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
       else
        htp.tabledata( '&nbsp;', cattributes=> clr || ' COLSPAN="2"');
      end if;
     htp.tablerowclose;
     dan_ctr := dan_ctr + 1;
    end loop; -- c4
    if dan_ctr = 0
     then
      htp.tabledata( c6brec.ship, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c6brec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c6brec.bol, cattributes=> clr || ' ALIGN="LEFT"');
      strcusrec := customer_details(c6brec.consignee);
      htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c3brec.hb, cattributes=> clr || ' ALIGN="LEFT"');
      strcusrec:= null;
      c2rec:= null;
      open c2(c3brec.hb, c3brec.ship, c3brec.voyage);
      fetch c2 into c2rec;
      close c2;
      strcusrec := customer_details(c2rec.consignee);
      htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c3brec.container, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( nvl(c6brec.customs_auth_no, nvl(c2rec.customs_auth_no, c3brec.customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( to_char(c6brec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( nvl(c3brec.strang_invoice, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tablerowclose;
    end if;
   end loop; -- c3b
   for c4brec in c4b(c6brec.ship, c6brec.voyage, c6brec.bol) loop -- Break-Bulk DANs
    htp.tablerowopen;
     htp.tabledata( c6brec.ship, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c6brec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c6brec.bol, cattributes=> clr || ' ALIGN="LEFT"');
     strcusrec := customer_details(c6brec.consignee);
     htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c4brec.hb, cattributes=> clr || ' ALIGN="LEFT"');
     strcusrec:= null;
     c2rec:= null;
     open c2(c4brec.hb, c4brec.ship, c4brec.voyage);
     fetch c2 into c2rec;
     close c2;
     strcusrec := customer_details(c2rec.consignee);
     htp.tabledata( nvl(strcusrec.customer, '&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( nvl(c6brec.customs_auth_no, nvl(c2rec.customs_auth_no, c4brec.customs_auth_no)), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c4brec.dan, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( c4brec.cmt, cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( to_char(c6brec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
    htp.tablerowclose;
   end loop; -- c4h
   if cntr_ctr = 0 and dan_ctr = 0
    then
     htp.tablerowopen;
      htp.tabledata( c6brec.ship, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c6brec.voyage, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c6brec.bol, cattributes=> clr || ' ALIGN="LEFT"');
      strcusrec := customer_details(c6brec.consignee);
      htp.tabledata( strcusrec.customer, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( c6brec.customs_auth_no, cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( to_char(c6brec.sailing_date, LNGS.STR_DATE_03), cattributes=> clr || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=> clr || ' ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
  end loop; -- c6b
end if;

htp.tableclose;

htp.nl;

-- Redisplay Form
htp.tableopen;
htp.tablerowopen;
htp.p('<TD valign="TOP">');
 htp.formopen( 'strangsb.accept_trac_search' );
 htp.formhidden( 'SURL', surl );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=10 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNGS.STR_TXT_437 || ':'), ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Consignee Name'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P1', 20, 100, p1 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Customs Authority Number'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P2', 20, 100, p2 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Container Number' ), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P3', 20, 100, p3 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'OTML DAN Number' ), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P4', 20, 100, p4 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'OTML Tracking Order Number'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P5', 20, 100, p5 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Date Range From'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P6', 20, 100, p6 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Date Range To'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P7', 20, 100, p7 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
htp.tableclose;
htp.nl;
htp.p('<CENTER>');
htp.formsubmit( null, LNGS.STR_TXT_441 );
htp.formclose;
htp.p('</CENTER>');
htp.p('</TD>');
htp.tablerowclose;
htp.tableclose;

exception when others then
 glbx.error_details( 'STRANGSB', 'ACCEPT_TRAC_SEARCH',null,null,errmsg=>sqlerrm);
end accept_trac_search;

function ctr_detail(rid_1 in rowid, det_type in varchar2, rid_2 in rowid default null, ctr_type in varchar2 default null) return varchar2
is

cursor c1 (rid_cs rowid) is select * from strang.containers_southbound where rowid = rid_cs;
cursor c2 (rid_cs rowid) is
 select bs.*
 from   strang.bols_southbound bs, strang.containers_southbound cs
 where  cs.rowid = rid_cs
        and cs.bol is not null
        and bs.bol = cs.bol
        and upper(bs.ship) = upper(cs.ship)
        and upper(bs.voyage) = upper(cs.voyage)
 ;
cursor c3 (rid_cs rowid) is
 select hs.*
 from   strang.hbs_southbound hs, strang.containers_southbound cs
 where  cs.rowid = rid_cs
        and cs.bol is not null
        and hs.house_bill = cs.hb
        and upper(hs.ship) = upper(cs.ship)
        and upper(hs.voyage) = upper(cs.voyage)
        and upper(hs.bol) = upper(cs.bol)
 ;

cursor c4 (rid_cs rowid) is
 select ds.*
 from   strang.dan_details_southbound ds, strang.containers_southbound cs
 where  cs.rowid = rid_cs
        and upper(ds.ship) = upper(cs.ship)
        and upper(ds.voyage) = upper(cs.voyage)
        and upper(ds.container) = upper(cs.container)
        and ds.hb is null
 order  by ds.dan
 ;

cursor c4c (rid_cs rowid) is
 select count(*)
 from   strang.dan_details_southbound ds, strang.containers_southbound cs
 where  cs.rowid = rid_cs
        and upper(ds.ship) = upper(cs.ship)
        and upper(ds.voyage) = upper(cs.voyage)
        and upper(ds.container) = upper(cs.container)
        and ds.hb is null
 ;
cursor c4x (rid_cs rowid) is
 select count(*)
 from   strang.dan_details_southbound ds, strang.containers_southbound cs
 where  cs.rowid = rid_cs
        and upper(ds.ship) = upper(cs.ship)
        and upper(ds.voyage) = upper(cs.voyage)
        and upper(ds.container) = upper(cs.container)
        and ds.hb is not null
 ;

cursor c5 (rid_hs rowid) is select * from strang.hbs_southbound where rowid = rid_hs;

cursor c6 (rid_cs rowid, v_hb varchar2) is
 select ds.*
 from   strang.dan_details_southbound ds, strang.containers_southbound cs
 where  cs.rowid = rid_cs
        and upper(ds.ship) = upper(cs.ship)
        and upper(ds.voyage) = upper(cs.voyage)
        and upper(ds.container) = upper(cs.container)
        and ds.hb is not null
        and (v_hb is null
             or
             (v_hb is not null and ds.hb = v_hb)
            )
 order  by ds.hb, ds.dan
 ;

cursor c7(rid_bs rowid, ctr_type varchar2) is
 select cs.*
 from   strang.bols_southbound bs, strang.containers_southbound cs
 where  bs.rowid = rid_bs
        and cs.bol = bs.bol
        and upper(cs.ship) = upper(bs.ship)
        and upper(cs.voyage) = upper(bs.voyage)
        and cs.full_mt = 'EMPTY'
        and cs.container_type=ctr_type
        and cs.hb is null
 order  by trim(cs.container)
 ;

cursor c7c(rid_bs rowid, ctr_type varchar2) is
 select count(*)
 from   strang.bols_southbound bs, strang.containers_southbound cs
 where  bs.rowid = rid_bs
        and cs.bol = bs.bol
        and upper(cs.ship) = upper(bs.ship)
        and upper(cs.voyage) = upper(bs.voyage)
        and cs.full_mt = 'EMPTY'
        and cs.hb is null
        and cs.container_type=ctr_type
 ;

cursor c8(rid_bs rowid) is select * from strang.bols_southbound where rowid = rid_bs;

cursor c9(rid_bs rowid, ctr_type varchar2, rid_hs rowid) is
 select cs.*
 from   strang.bols_southbound bs, strang.containers_southbound cs, strang.hbs_southbound hs
 where  bs.rowid = rid_bs
        and cs.bol = bs.bol
        and upper(cs.ship) = upper(bs.ship)
        and upper(cs.voyage) = upper(bs.voyage)
        and cs.full_mt = 'EMPTY'
        and cs.container_type=ctr_type
        and cs.hb is not null
        and cs.hb = hs.house_bill
        and hs.rowid = rid_hs
 order  by trim(cs.container)
 ;

cursor c9c(rid_bs rowid, ctr_type varchar2, rid_hs rowid) is
 select count(*)
 from   strang.bols_southbound bs, strang.containers_southbound cs, strang.hbs_southbound hs
 where  bs.rowid = rid_bs
        and cs.bol = bs.bol
        and upper(cs.ship) = upper(bs.ship)
        and upper(cs.voyage) = upper(bs.voyage)
        and cs.full_mt = 'EMPTY'
        and cs.container_type=ctr_type
        and cs.hb is not null
        and cs.hb = hs.house_bill
        and hs.rowid = rid_hs
 ;

cursor c10(rid_bs rowid) is
 select ds.*
 from   strang.dan_details_southbound ds, strang.bols_southbound bs
 where  bs.rowid = rid_bs
        and upper(ds.ship) = upper(bs.ship)
        and upper(ds.voyage) = upper(bs.voyage)
        and ds.bol = bs.bol
        and ds.container is null
        and ds.hb is null
 order  by ds.dan
 ;

cursor c10c(rid_bs rowid) is
 select count(*)
 from   strang.dan_details_southbound ds, strang.bols_southbound bs
 where  bs.rowid = rid_bs
        and upper(ds.ship) = upper(bs.ship)
        and upper(ds.voyage) = upper(bs.voyage)
        and ds.bol = bs.bol
        and ds.container is null
        and ds.hb is null
 ;

cursor c10x(rid_bs rowid) is
 select count(*)
 from   strang.dan_details_southbound ds, strang.bols_southbound bs
 where  bs.rowid = rid_bs
        and upper(ds.ship) = upper(bs.ship)
        and upper(ds.voyage) = upper(bs.voyage)
        and ds.bol = bs.bol
        and ds.container is null
        and ds.hb is not null
 ;

cursor c11(rid_hs rowid) is
 select ds.*
 from   strang.dan_details_southbound ds, strang.hbs_southbound hs
 where  hs.rowid = rid_hs
        and upper(ds.ship) = upper(hs.ship)
        and upper(ds.voyage) = upper(hs.voyage)
        and ds.bol = hs.bol
        and ds.hb is not null
        and ds.hb = hs.house_bill
        and ds.container is null
 order  by hs.house_bill, ds.dan
 ;

cursor c11c(rid_hs rowid) is
 select count(*)
 from   strang.dan_details_southbound ds, strang.hbs_southbound hs
 where  hs.rowid = rid_hs
        and upper(ds.ship) = upper(hs.ship)
        and upper(ds.voyage) = upper(hs.voyage)
        and ds.bol = hs.bol
        and ds.hb is not null
        and ds.hb = hs.house_bill
        and ds.container is null
 ;

cursor c12a(rid_bs rowid) is
 select count(*)
 from   strang.containers_southbound cs, strang.bols_southbound bs
 where  bs.rowid = rid_bs
        and upper(cs.ship) = upper(bs.ship)
        and upper(cs.voyage) = upper(bs.voyage)
        and upper(cs.bol) = upper(bs.bol)
;

cursor c12b(rid_bs rowid) is
 select count(*)
 from   strang.dan_details_southbound ds, strang.bols_southbound bs
 where  bs.rowid = rid_bs
        and upper(ds.ship) = upper(bs.ship)
        and upper(ds.voyage) = upper(bs.voyage)
        and upper(ds.bol) = upper(bs.bol)
        and ds.container is null
;

cursor c12c(rid_bs rowid) is
 select cs.container
 from   strang.containers_southbound cs, strang.bols_southbound bs
 where  bs.rowid = rid_bs
        and upper(cs.ship) = upper(bs.ship)
        and upper(cs.voyage) = upper(bs.voyage)
        and upper(cs.bol) = upper(bs.bol)
;

cursor c12d(rid_hs rowid) is
 select count(*)
 from   strang.containers_southbound cs, strang.hbs_southbound hs
 where  hs.rowid = rid_hs
        and upper(cs.ship) = upper(hs.ship)
        and upper(cs.voyage) = upper(hs.voyage)
        and upper(cs.bol) = upper(hs.bol)
        and (
             (cs.hb is not null and cs.hb = hs.house_bill)
             or
             container in (select ds.container
                           from   strang.dan_details_southbound ds
                           where  upper(ds.ship) = upper(cs.ship)
                                  and upper(ds.voyage) = upper(cs.voyage)
                                  and ds.bol = cs.bol
                                  and ds.hb = hs.house_bill
                           )
           )
;

cursor c12e(rid_hs rowid) is
 select count(*)
 from   strang.dan_details_southbound ds, strang.hbs_southbound hs
 where  hs.rowid = rid_hs
        and upper(ds.ship) = upper(hs.ship)
        and upper(ds.voyage) = upper(hs.voyage)
        and upper(ds.bol) = upper(hs.bol)
        and upper(ds.hb) = upper(hs.house_bill)
        and ds.container is null
;

cursor c12f(rid_hs rowid) is
 select cs.container
 from   strang.containers_southbound cs, strang.hbs_southbound hs
 where  hs.rowid = rid_hs
        and upper(cs.ship) = upper(hs.ship)
        and upper(cs.voyage) = upper(hs.voyage)
        and upper(cs.bol) = upper(hs.bol)
        and (
             (cs.hb is not null and cs.hb = hs.house_bill)
             or
             container in (select ds.container
                           from   strang.dan_details_southbound ds
                           where  upper(ds.ship) = upper(cs.ship)
                                  and upper(ds.voyage) = upper(cs.voyage)
                                  and ds.bol = cs.bol
                                  and ds.hb = hs.house_bill
                           )
           )
;

cursor c13(rid_ds rowid) is
 select cs.rowid, ds.dan
 from   strang.dan_details_southbound ds, strang.containers_southbound cs
 where  ds.rowid = rid_ds
        and upper(cs.ship) = upper(ds.ship)
        and upper(cs.voyage) = upper(ds.voyage)
        and cs.container = ds.container
;

cursor c14(rid_ds rowid) is
 select bs.rowid, ds.dan
 from   strang.dan_details_southbound ds, strang.bols_southbound bs
 where  ds.rowid = rid_ds
        and upper(bs.ship) = upper(ds.ship)
        and upper(bs.voyage) = upper(ds.voyage)
        and bs.bol = ds.bol
;

cursor c15(rid_ds rowid) is
 select hs.rowid, hs.house_bill
 from   strang.dan_details_southbound ds, strang.hbs_southbound hs
 where  ds.rowid = rid_ds
        and upper(hs.ship) = upper(ds.ship)
        and upper(hs.voyage) = upper(ds.voyage)
        and hs.bol = ds.bol
        and hs.house_bill = ds.hb
;

c1rec      c1%ROWTYPE;
c2rec      c2%ROWTYPE;
c3rec      c3%ROWTYPE;
c5rec      c5%ROWTYPE;
c6rec      c6%ROWTYPE;
c8rec      c8%ROWTYPE;
cusrec     strang.customers%ROWTYPE;
vtxt       varchar2(32767);
typ_1      varchar2(10);
typ_2      varchar2(10);
typ_3      varchar2(10);
rec_cnt    integer;
wt         number;
vol        number;
foundrec   boolean;
ctr_code   varchar2(100);
ctr        integer;
rid_cs     rowid;
rid_hs     rowid;
rid_bs     rowid;
v_dan      varchar2(20);
v_hb       varchar2(20);

begin

-- Detail Type CDxyy
--   where
-- x : 1  = Container: Full, No HBs   DANS: None
--     2  = Container: Full, HB       DANS: None
--     3  = Container: Full, No HBs   DANS: No HBs
--     4  = Container: Full, No HBs   DANS: HB
--     5  = Container: Empty, No HBs
--     6  = Container: Empty, HB
--     7  = Break-bulk DAN, no HB
--     8  = Break-bulk DAN, no HB
-- yy: Detail type (01-99)

typ_1 := substr(det_type, 3, 3);
typ_2 := substr(det_type, 3, 1);
typ_3 := substr(det_type, 4, 2);

rid_cs := rid_1;
rid_hs := rid_2;

if typ_2 in ('5', '6')
 then
  rid_bs := rid_1;
end if;

if typ_2 in ('3', '4') -- rid_1 = rowid of DAN
 then
  open c13(rid_1);
  fetch c13 into rid_cs, v_dan;
  close c13;
end if;

if typ_2 in ('7', '8') -- rid_1 = rowid of DAN
 then
  open c14(rid_1);
  fetch c14 into rid_bs, v_dan;
  close c14;
  if typ_2 in ('8')
   then
    open c15(rid_1);
    fetch c15 into rid_hs, v_hb;
    close c15;
  end if;
end if;

if typ_2 in ('1', '2', '3', '4')
 then
  open c1(rid_cs);
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    close c1;
    glbx.dbg('Record not found for container. ROWID = ' || rid_cs);
    return(null);
  end if;
  close c1;
end if;

-- Customer Details from BOL
if typ_1 in ('501', '502', '503', '601', '602', '603', '701', '702', '703', '801', '802', '803', '805')
 then
  open c8(rid_bs);
  fetch c8 into c8rec;
  if c8%NOTFOUND and typ_2 not in ('8')
   then
    close c8;
    glbx.dbg('Record not found for BOL. ROWID = ' || rid_bs);
    return(null);
  end if;
  close c8;
  c2rec.shipper := c8rec.shipper;
  c2rec.consignee := c8rec.consignee;
  c2rec.notifying_party := c8rec.notifying_party;
  if typ_2 in ('6', '8')
   then
    open c5(rid_hs);
    fetch c5 into c5rec;
    if c5%FOUND
     then
      c2rec.shipper := c5rec.shipper;
      c2rec.consignee := c5rec.consignee;
      c2rec.notifying_party := c5rec.notifying_party;
    end if;
    close c5;
  end if;
end if;

-- DAN HBs
if typ_2 in ('4', '8')
 then
  open c5(rid_hs);
  fetch c5 into c5rec;
  if c5%NOTFOUND
   then
    close c5;
    glbx.dbg('Record not found for House Bill. ROWID = ' || rid_hs);
    return(null);
  end if;
  close c5;
  c2rec.shipper := c5rec.shipper;
  c2rec.consignee := c5rec.consignee;
  c2rec.notifying_party := c5rec.notifying_party;
end if;

if typ_1 in ('101', '102', '103', '301', '302', '303', '402', '403')
 then
  open c2(rid_cs);     -- BOL Customer Details
  fetch c2 into c2rec;
  close c2;
  /*
  if typ_2 in ('1')
   then
    open c3(rid_cs);   -- Container HB Customer Details
    fetch c3 into c3rec;
    if c3%FOUND
     then
      c2rec.shipper := c3rec.shipper;
      c2rec.consignee := c3rec.consignee;
      c2rec.notifying_party := c3rec.notifying_party;
    end if;
    close c3;
  end if;
  */
end if;

vtxt := null;

case upper(det_type)
when 'CD101' then       -- Container: Full, No HBs   DANS: None   - DAN NO. MARKS & NOS.
 vtxt := '<span id="1-' || c1rec.container || '"></span>';
 if c1rec.marks_numbers is not null
  then
   vtxt := vtxt || c1rec.marks_numbers || '<br>';
 end if;
 cusrec := customer_details(c2rec.notifying_party);
 vtxt := vtxt ||cusrec.customer;
 vtxt := vtxt || '<br>' || cusrec.street;
 if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
 vtxt := vtxt || cusrec.suburb;
 if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
 vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
 return(vtxt);

when 'CD102' then       -- Container: Full, No HBs   DANS: None   - SHIPPER
 cusrec := customer_details(c2rec.shipper);
 vtxt := cusrec.customer;
 --vtxt := vtxt || '<br>' || cusrec.street;
 --if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
 --vtxt := vtxt || cusrec.suburb;
 --if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
 --vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
 return(vtxt);
when 'CD103' then       -- Container: Full, No HBs   DANS: None   - CONSIGNEE
 cusrec := customer_details(c2rec.consignee);
 vtxt := cusrec.customer;
 vtxt := vtxt || '<br>' || cusrec.street;
 if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
 vtxt := vtxt || cusrec.suburb;
 if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
 vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
 return(vtxt);
when 'CD104' then       -- Container: Full, No HBs   DANS: None   - NO. OF PKGS.
 return('<b>1</b>');
when 'CD105' then       -- Container: Full, No HBs   DANS: None   - DESCRIPTION
 vtxt := '<b><u>' || c1rec.container_type || ' NO. ' || substr(trim(c1rec.container) , 1, 4) || ' ' || trim(substr(trim(c1rec.container), 5));
 vtxt := vtxt || '</u></b>';
 if c1rec.cmt is not null
  then
   vtxt := vtxt || '<br>STC:<br>';
   vtxt := vtxt || c1rec.cmt;
 end if;
 vtxt := vtxt || '<br><br>' || '<b>END OF CONTAINER</b>';
 return(vtxt);
when 'CD106' then       -- Container: Full, No HBs   DANS: None   - SEAL NO.
 vtxt := c1rec.seal;
 return(vtxt);
when 'CD107' then       -- Container: Full, No HBs   DANS: None   - WEIGHT
 vtxt := to_char(nvl(c1rec.weight, 0), '999990.000');
 return(vtxt);
when 'CD108' then       -- Container: Full, No HBs   DANS: None   - VOLUME
 if nvl(c1rec.volume, 0) = 0
  then
   vtxt := '&nbsp;';
 else
   vtxt := to_char(nvl(c1rec.volume, 0), '999990.000');
 end if;
 return(vtxt);
when 'CD109' then       -- Container: Full, No HBs   DANS: None   - REVENUE
 if nvl(c1rec.volume, 0) = 0
  then
   vtxt := '&nbsp;';
 else
   if nvl(c1rec.weight, 0)/1000 >= nvl(c1rec.volume, 0)
    then
     vtxt := to_char(nvl(c1rec.weight, 0)/1000, '999990.000');
   else
     vtxt := to_char(nvl(c1rec.volume, 0), '999990.000');
   end if;
 end if;
 return(vtxt);

/* Reserved - not necessary for Container with HB
when 'CD201' then       -- Container: Full, HB       DANS: None   - DAN NO. MARKS & NOS.
 return(vtxt);
when 'CD202' then       -- Container: Full, HB       DANS: None   - SHIPPER
 return(vtxt);
when 'CD203' then       -- Container: Full, HB       DANS: None   - CONSIGNEE
 return(vtxt);
when 'CD204' then       -- Container: Full, HB       DANS: None   - NO. OF PKGS.
 return(vtxt);
when 'CD205' then       -- Container: Full, HB       DANS: None   - DESCRIPTION
 return(vtxt);
when 'CD206' then       -- Container: Full, HB       DANS: None   - SEAL NO.
 return(vtxt);
when 'CD207' then       -- Container: Full, HB       DANS: None   - WEIGHT
 return(vtxt);
when 'CD208' then       -- Container: Full, HB       DANS: None   - VOLUME
 return(vtxt);
when 'CD209' then       -- Container: Full, HB       DANS: None   - REVENUE
 return(vtxt);
*/

-- Full Container: rid_1 is the rowid of the DAN

when 'CD301' then       -- Container: Full, No HBs   DANS: No HBs - DAN NO. MARKS & NOS.
 vtxt := '<span id="2-' || c1rec.container || '"></span>';
 vtxt := vtxt || '<b><u>';
 for c4rec in c4(rid_cs) loop
  if c4%ROWCOUNT = 1 and c4rec.dan = v_dan
   then
    vtxt := vtxt || 'DAN NO. ' || c4rec.dan;
    vtxt := vtxt || '</u></b><br>';
    cusrec := customer_details(c2rec.consignee);
    vtxt := vtxt || cusrec.customer;
    vtxt := vtxt || '<br>' || cusrec.street;
    if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
    vtxt := vtxt || cusrec.suburb;
    if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
    vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
  elsif c4rec.dan = v_dan
   then
    vtxt := vtxt || c4rec.dan;
    vtxt := vtxt || '</u></b>';
  end if;
 end loop;

 return(vtxt);
when 'CD302' then       -- Container: Full, No HBs   DANS: No HBs - SHIPPER
 cusrec := customer_details(c2rec.shipper);
 vtxt := '&nbsp;';
 for c4rec in c4(rid_cs) loop
  if c4%ROWCOUNT = 1 and c4rec.dan = v_dan
   then
    vtxt := cusrec.customer;
--    vtxt := vtxt || '<br>' || cusrec.street;
--    if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
--    vtxt := vtxt || cusrec.suburb;
--    if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
--    vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
  end if;
 end loop;
 return(vtxt);
when 'CD303' then       -- Container: Full, No HBs   DANS: No HBs - CONSIGNEE
 cusrec := customer_details(c2rec.consignee);
 vtxt := '&nbsp;';
 for c4rec in c4(rid_cs) loop
  if c4%ROWCOUNT = 1 and c4rec.dan = v_dan
   then
    vtxt := cusrec.customer;
    vtxt := vtxt || '<br>' || cusrec.street;
    if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
    vtxt := vtxt || cusrec.suburb;
    if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
    vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
  end if;
 end loop;
 return(vtxt);
when 'CD304' then       -- Container: Full, No HBs   DANS: No HBs - NO. OF PKGS.
 vtxt := '&nbsp;';
 for c4rec in c4(rid_cs) loop
  if c4%ROWCOUNT = 1 and c4rec.dan = v_dan
   then
    vtxt := '<b>1</b>';
  end if;
 end loop;
 return(vtxt);
when 'CD305' then       -- Container: Full, No HBs   DANS: No HBs - DESCRIPTION
 foundrec := FALSE;
 for c4rec in c4(rid_cs) loop
  if c4%ROWCOUNT = 1 and c4rec.dan = v_dan
   then
    vtxt := '<b><u>' || c1rec.container_type || ' NO. ' || substr(trim(c1rec.container) , 1, 4) || ' ' || trim(substr(trim(c1rec.container), 5)) || '</u></b>';
    if c1rec.cmt is not null
     then
      vtxt := vtxt || '<br>' || c1rec.cmt;
    end if;
    vtxt := vtxt || '<br>';
    if nvl(c4rec.pieces, 0) > 0
     then
      vtxt := vtxt || c4rec.pieces || ' ';
    end if;
    vtxt := vtxt || lov_code('PACKTYPES', c4rec.packaging) || ': ';
    vtxt := vtxt || c4rec.commodity;
    foundrec := TRUE;
  elsif c4rec.dan = v_dan
   then
    if nvl(c4rec.pieces, 0) > 0
     then
      vtxt := vtxt || c4rec.pieces || ' ';
    end if;
    vtxt := vtxt || lov_code('PACKTYPES', c4rec.packaging) || ': ';
    vtxt := vtxt || c4rec.commodity;
    if c4rec.cmt is not null then vtxt := vtxt || ',<br>'; end if;
    vtxt := vtxt || c4rec.cmt;
    foundrec := TRUE;
  else
    foundrec := FALSE;
  end if;
 end loop;
 open c4x(rid_cs);
 fetch c4x into rec_cnt;
 close c4x;
 if nvl(rec_cnt, 0) = 0 and foundrec -- Last DAN and no DANS with HBs
  then
   vtxt := vtxt || '<br><br>' || '<b>END OF CONTAINER</b>';
 end if;
 return(vtxt);
when 'CD306' then       -- Container: Full, No HBs   DANS: No HBs - SEAL NO.
 vtxt := '&nbsp;';
 for c4rec in c4(rid_cs) loop
  if c4%ROWCOUNT = 1 and c4rec.dan = v_dan
   then
    vtxt := c1rec.seal;
  end if;
 end loop;
 return(vtxt);
when 'CD307' then       -- Container: Full, No HBs   DANS: No HBs - WEIGHT
 wt := 0;
 for c4rec in c4(rid_cs) loop
  if c4rec.dan = v_dan
   then
    begin
     wt := wt + to_number(nvl(c4rec.kg, 0));
    exception when others then null;
    end;
  end if;
 end loop;
 vtxt := to_char(wt/1000, '999990.000');
 return(vtxt);
when 'CD308' then       -- Container: Full, No HBs   DANS: No HBs - VOLUME
 vol := 0;
 for c4rec in c4(rid_cs) loop
  if c4rec.dan = v_dan
   then
    begin
     vol := vol + to_number(nvl(c4rec.cbm, 0));
    exception when others then null;
    end;
  end if;
 end loop;
 if vol = 0
  then
   vtxt := '&nbsp;';
 else
   vtxt := to_char(vol, '999990.000');
 end if;
 return(vtxt);
when 'CD309' then       -- Container: Full, No HBs   DANS: No HBs - REVENUE
 wt := 0;
 for c4rec in c4(rid_cs) loop
  if c4rec.dan = v_dan
   then
    begin
     wt := wt + to_number(nvl(c4rec.kg, 0));
    exception when others then null;
    end;
  end if;
 end loop;

 vol := 0;
 for c4rec in c4(rid_cs) loop
  if c4rec.dan = v_dan
   then
    begin
     vol := vol + to_number(nvl(c4rec.cbm, 0));
    exception when others then null;
    end;
  end if;
 end loop;

 if vol = 0
  then
   vtxt := '&nbsp;';
 else
   if wt/1000 >= vol
    then
     vtxt := to_char(wt/1000, '999990.000');
   else
     vtxt := to_char(vol, '999990.000');
   end if;
 end if;
 return(vtxt);

when 'CD401' then       -- Container: Full, No HBs   DANS: HB     - DAN NO. MARKS & NOS.
 vtxt := '<span id="2-' || c1rec.container || '-' || c5rec.house_bill || '"></span>';
 vtxt := vtxt || '<b><u>';
 for c6rec in c6(rid_cs, c5rec.house_bill) loop
  if c6%ROWCOUNT = 1 and c6rec.hb = c5rec.house_bill and c6rec.dan = v_dan
   then
    vtxt := vtxt || 'DAN NO. ' || c6rec.dan;
    vtxt := vtxt || '</u></b><br>';
    cusrec := customer_details(c2rec.consignee);
    vtxt := vtxt ||cusrec.customer;
    vtxt := vtxt || '<br>' || cusrec.street;
    if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
    vtxt := vtxt || cusrec.suburb;
    if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
    vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
  elsif c6rec.dan = v_dan
   then
    vtxt := vtxt || c6rec.dan;
    vtxt := vtxt || '</u></b>';
  end if;
 end loop;
 return(vtxt);
when 'CD411' then       -- Container: Full, No HBs   DANS: HB     - DAN NO. MARKS & NOS. - HOUSE BILL-SPECIFIC
 vtxt := '<span id="2-' || c1rec.container || '-' || c5rec.house_bill || '"></span>';
 vtxt := vtxt || '<b><u>';
 for c6rec in c6(rid_cs, c5rec.house_bill) loop
  if c6rec.hb = c5rec.house_bill and c6rec.dan = v_dan
   then
    vtxt := vtxt || 'DAN NO. ' || c6rec.dan;
    vtxt := vtxt || '</u></b>';
  end if;
 end loop;
 return(vtxt);
when 'CD402' then       -- Container: Full, No HBs   DANS: HB     - SHIPPER
 cusrec := customer_details(c2rec.shipper);
 vtxt := '&nbsp;';
 for c6rec in c6(rid_cs, c5rec.house_bill) loop
  if c6%ROWCOUNT = 1 and c6rec.hb = c5rec.house_bill and c6rec.dan = v_dan
   then
    vtxt := cusrec.customer;
 --   vtxt := vtxt || '<br>' || cusrec.street;
 --   if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
 --   vtxt := vtxt || cusrec.suburb;
 --   if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
 --   vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
  end if;
 end loop;
 return(vtxt);
when 'CD403' then       -- Container: Full, No HBs   DANS: HB     - CONSIGNEE
 cusrec := customer_details(c2rec.consignee);
 vtxt := '&nbsp;';
 for c6rec in c6(rid_cs, c5rec.house_bill) loop
  if c6%ROWCOUNT = 1 and c6rec.hb = c5rec.house_bill and c6rec.dan = v_dan
   then
    vtxt := cusrec.customer;
    vtxt := vtxt || '<br>' || cusrec.street;
    if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
    vtxt := vtxt || cusrec.suburb;
    if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
    vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
  end if;
 end loop;
 return(vtxt);
when 'CD404' then       -- Container: Full, No HBs   DANS: HB     - NO. OF PKGS.
 vtxt := '&nbsp;';
 for c6rec in c6(rid_cs, c5rec.house_bill) loop
  if c6%ROWCOUNT = 1 and c6rec.hb = c5rec.house_bill and c6rec.dan = v_dan
   then
    vtxt := '<b>1</b>';
  end if;
 end loop;
 return(vtxt);
when 'CD405' then       -- Container: Full, No HBs   DANS: HB     - DESCRIPTION
 rec_cnt := 0;
 foundrec := FALSE;
 open c4c(rid_cs);
 fetch c4c into rec_cnt;
 close c4c;
 for c6rec in c6(rid_cs, null) loop
  if nvl(rec_cnt, 0) = 0 and c6%ROWCOUNT = 1 and c6rec.hb = c5rec.house_bill and c6rec.dan = v_dan
   then
    vtxt := '<b><u>' || c1rec.container_type || ' NO. ' || substr(trim(c1rec.container) , 1, 4) || ' ' || trim(substr(trim(c1rec.container), 5)) || '</u></b>';
    if c1rec.cmt is not null
     then
      vtxt := vtxt || '<br>' || c1rec.cmt;
    end if;
    vtxt := vtxt || '<br>';
    if nvl(c6rec.pieces, 0) > 0
     then
      vtxt := vtxt || c6rec.pieces || ' ';
    end if;
    vtxt := vtxt || lov_code('PACKTYPES', c6rec.packaging) || ': ';
    vtxt := vtxt || c6rec.commodity;
    foundrec := TRUE;
  elsif c6rec.hb = c5rec.house_bill and c6rec.dan = v_dan
   then
    if nvl(c6rec.pieces, 0) > 0
     then
      vtxt := vtxt || c6rec.pieces || ' ';
    end if;
    vtxt := vtxt || lov_code('PACKTYPES', c6rec.packaging) || ': ';
    vtxt := vtxt || c6rec.commodity;
    foundrec := TRUE;
  else
    foundrec := FALSE;
  end if;
 end loop;

 if foundrec -- This is the last DAN with HBs
  then
   vtxt := vtxt || '<br><br>' || '<b>END OF CONTAINER</b>';
 end if;
 return(vtxt);
when 'CD415' then       -- Container: Full, No HBs   DANS: HB     - DESCRIPTION - HOUSE BILL-SPECIFIC
 foundrec := FALSE;
 for c6rec in c6(rid_cs, c5rec.house_bill) loop
  if nvl(rec_cnt, 0) = 0 and c6%ROWCOUNT = 1 and c6rec.dan = v_dan
   then
    vtxt := '<b><u>' || c1rec.container_type || ' NO. ' || substr(trim(c1rec.container) , 1, 4) || ' ' || trim(substr(trim(c1rec.container), 5)) || '</u></b>';
    if c1rec.cmt is not null
     then
      vtxt := vtxt || '<br>' || c1rec.cmt;
    end if;
    vtxt := vtxt || '<br>';
    if nvl(c6rec.pieces, 0) > 0
     then
      vtxt := vtxt || c6rec.pieces || ' ';
    end if;
    vtxt := vtxt || lov_code('PACKTYPES', c6rec.packaging) || ': ';
    vtxt := vtxt || c6rec.commodity;
    foundrec := TRUE;
  elsif c6rec.dan = v_dan
   then
    if nvl(c6rec.pieces, 0) > 0
     then
      vtxt := vtxt || c6rec.pieces || ' ';
    end if;
    vtxt := vtxt || lov_code('PACKTYPES', c6rec.packaging) || ': ';
    vtxt := vtxt || c6rec.commodity;
    foundrec := TRUE;
  else
    foundrec := FALSE;
  end if;
 end loop;

 if foundrec -- This is the last DAN with HBs
  then
   vtxt := vtxt || '<br><br>' || '<b>END OF CONTAINER</b>';
 end if;
 return(vtxt);
when 'CD406' then       -- Container: Full, No HBs   DANS: HB     - SEAL NO.
 vtxt := '&nbsp;';
 rec_cnt := 0;
 open c4c(rid_cs);
 fetch c4c into rec_cnt;
 close c4c;
 for c6rec in c6(rid_cs, null) loop
  if c6%ROWCOUNT = 1 and c6rec.hb = c5rec.house_bill and c6rec.dan = v_dan and rec_cnt = 0
   then
    vtxt := c1rec.seal;
  end if;
 end loop;
 return(vtxt);
when 'CD407' then       -- Container: Full, No HBs   DANS: HB     - WEIGHT
 wt := 0;
 for c6rec in c6(rid_cs, c5rec.house_bill) loop
  if c6rec.dan = v_dan
   then
    begin
     wt := wt + to_number(nvl(c6rec.kg, 0));
    exception when others then null;
    end;
  end if;
 end loop;
 vtxt := to_char(wt/1000, '999990.000');
 return(vtxt);
when 'CD408' then       -- Container: Full, No HBs   DANS: HB     - VOLUME
 vol := 0;
 for c6rec in c6(rid_cs, c5rec.house_bill) loop
  if c6rec.dan = v_dan
   then
    begin
     vol := vol + to_number(nvl(c6rec.cbm, 0));
    exception when others then null;
    end;
  end if;
 end loop;
 if vol = 0
  then
   vtxt := '&nbsp;';
 else
   vtxt := to_char(vol, '999990.000');
 end if;
 return(vtxt);
when 'CD409' then       -- Container: Full, No HBs   DANS: HB     - REVENUE
 wt := 0;
 for c6rec in c6(rid_cs, c5rec.house_bill) loop
  if c6rec.dan = v_dan
   then
    begin
     wt := wt + to_number(nvl(c6rec.kg, 0));
    exception when others then null;
    end;
  end if;
 end loop;

 vol := 0;
 for c6rec in c6(rid_cs, c5rec.house_bill) loop
  if c6rec.dan = v_dan
   then
    begin
     vol := vol + to_number(nvl(c6rec.cbm, 0));
    exception when others then null;
    end;
  end if;
 end loop;

 if vol = 0
  then
   vtxt := '&nbsp;';
 else
   if wt/1000 >= vol
    then
     vtxt := to_char(wt/1000, '999990.000');
   else
     vtxt := to_char(vol, '999990.000');
   end if;
 end if;
 return(vtxt);

-- Empty Containers: rid_1 is the rowid for strang.bols_southbound

when 'CD501' then       -- Container: Empty, No HBs               - DAN NO. MARKS & NOS.
 vtxt := '<span id="5-' || ctr_type || '"></span>';
 cusrec := customer_details(c2rec.notifying_party);
 vtxt := vtxt ||cusrec.customer;
 vtxt := vtxt || '<br>' || cusrec.street;
 if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
 vtxt := vtxt || cusrec.suburb;
 if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
 vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
 return(vtxt);
when 'CD502' then       -- Container: Empty, No HBs               - SHIPPER
 cusrec := customer_details(c2rec.shipper);
 vtxt := cusrec.customer;
-- vtxt := vtxt || '<br>' || cusrec.street;
-- if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
-- vtxt := vtxt || cusrec.suburb;
-- if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
-- vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
 return(vtxt);
when 'CD503' then       -- Container: Empty, No HBs               - CONSIGNEE
 cusrec := customer_details(c2rec.consignee);
 vtxt := cusrec.customer;
 vtxt := vtxt || '<br>' || cusrec.street;
 if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
 vtxt := vtxt || cusrec.suburb;
 if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
 vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
 return(vtxt);
when 'CD504' then       -- Container: Empty, No HBs               - NO. OF PKGS.
 open c7c(rid_1, ctr_type);
 fetch c7c into rec_cnt;
 close c7c;
 return('<b>' || rec_cnt || '</b>');
when 'CD505' then       -- Container: Empty, No HBs               - DESCRIPTION
 vtxt := '<b><u>EMPTY ' || ctr_type || ':</u></b><br>';
 ctr_code := ' ';
 ctr := 0;
 for c7rec in c7(rid_1, ctr_type) loop
  if substr(trim(c7rec.container) , 1, 4) <> ctr_code
   then
    ctr := 0;
    ctr_code := substr(trim(c7rec.container) , 1, 4);
    vtxt := vtxt || '<br><b>' || ctr_code || '</b> ';
  else
    vtxt := vtxt || ', ';
    ctr := ctr + 1;
  end if;
  if ctr >= 4
   then
    ctr := 0;
    vtxt := vtxt || '<span style="visibility: hidden;">' || '<br><b>' || ctr_code || '</b></span> ';
  end if;
  vtxt := vtxt || trim(substr(trim(c7rec.container), 5));
  if length(vtxt) > 3800
   then
    vtxt := vtxt || '<br><br>' || '<b>FIELD LENGTH LIMIT EXCEEDED. NO FURTHER ENTRIES</b>';
    exit;
  end if;
 end loop;
 vtxt := vtxt || '<br><br>' || '<b>END OF CONTAINER</b>';
 return(vtxt);
when 'CD506' then       -- Container: Empty, No HBs               - SEAL NO.
 return('&nbsp;');
when 'CD507' then       -- Container: Empty, No HBs               - WEIGHT
 wt := 0;
 for c7rec in c7(rid_1, ctr_type) loop
  begin
   wt := wt + to_number(nvl(c7rec.weight, 0));
  exception when others then null;
  end;
 end loop;
 vtxt := to_char(wt/1000, '999990.000');
 return(vtxt);
when 'CD508' then       -- Container: Empty, No HBs               - VOLUME
 return('&nbsp;');
when 'CD509' then       -- Container: Empty, No HBs               - REVENUE
 return('&nbsp;');

when 'CD601' then       -- Container: Empty, HB                   - DAN NO. MARKS & NOS.
 vtxt := '<span id="6-' || c5rec.house_bill || '-' || ctr_type || '"></span>';
 cusrec := customer_details(c2rec.notifying_party);
 vtxt := vtxt ||cusrec.customer;
 vtxt := vtxt || '<br>' || cusrec.street;
 if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
 vtxt := vtxt || cusrec.suburb;
 if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
 vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
 return(vtxt);
when 'CD602' then       -- Container: Empty, HB                   - SHIPPER
 cusrec := customer_details(c2rec.shipper);
 vtxt := cusrec.customer;
-- vtxt := vtxt || '<br>' || cusrec.street;
-- if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
-- vtxt := vtxt || cusrec.suburb;
 if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
 vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
 return(vtxt);
when 'CD603' then       -- Container: Empty, HB                   - CONSIGNEE
 cusrec := customer_details(c2rec.consignee);
 vtxt := cusrec.customer;
 vtxt := vtxt || '<br>' || cusrec.street;
 if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
 vtxt := vtxt || cusrec.suburb;
 if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
 vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
 return(vtxt);
when 'CD604' then       -- Container: Empty, HB                   - NO. OF PKGS.
 open c9c(rid_1, ctr_type, rid_2);
 fetch c9c into rec_cnt;
 close c9c;
 return('<b>' || rec_cnt || '</b>');
when 'CD605' then       -- Container: Empty, HB                   - DESCRIPTION
 vtxt := '<b><u>EMPTY ' || ctr_type || ':</u></b><br>';
 ctr_code := ' ';
 ctr := 0;
 for c9rec in c9(rid_1, ctr_type, rid_2) loop
  if substr(trim(c9rec.container) , 1, 4) <> ctr_code
   then
    ctr := 0;
    ctr_code := substr(trim(c9rec.container) , 1, 4);
    vtxt := vtxt || '<br><b>' || ctr_code || '</b> ';
  else
    vtxt := vtxt || ', ';
    ctr := ctr + 1;
  end if;
  if ctr >= 4
   then
    ctr := 0;
    vtxt := vtxt || '<span style="visibility: hidden;">' || '<br><b>' || ctr_code || '</b></span> ';
  end if;
  vtxt := vtxt || trim(substr(trim(c9rec.container), 5));
 end loop;
 vtxt := vtxt || '<br><br>' || '<b>END OF CONTAINER</b>';
 return(vtxt);
when 'CD606' then       -- Container: Empty, HB                   - SEAL NO.
 return('&nbsp;');
when 'CD607' then       -- Container: Empty, HB                   - WEIGHT
 wt := 0;
 for c9rec in c9(rid_1, ctr_type, rid_2) loop
  begin
   wt := wt + to_number(nvl(c9rec.weight, 0));
  exception when others then null;
  end;
 end loop;
 vtxt := to_char(wt/1000, '999990.000');
 return(vtxt);
when 'CD608' then       -- Container: Empty, HB                   - VOLUME
 return('&nbsp;');
when 'CD609' then       -- Container: Empty, HB                   - REVENUE
 return('&nbsp;');

when 'CD701' then       -- Break-Bulk DANS: No HBs - DAN NO. MARKS & NOS.
 vtxt := '<span id="7-' || v_dan || '"></span>';
 vtxt := vtxt || '<b><u>';
 for c10rec in c10(rid_bs) loop
  if c10%ROWCOUNT = 1 and c10rec.dan = v_dan
   then
    vtxt := vtxt || 'DAN NO. ' || c10rec.dan;
    vtxt := vtxt || '</u></b><br>';
    cusrec := customer_details(c2rec.notifying_party);
    vtxt := vtxt ||cusrec.customer;
    vtxt := vtxt || '<br>' || cusrec.street;
    if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
    vtxt := vtxt || cusrec.suburb;
    if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
    vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
  elsif c10rec.dan = v_dan
   then
    vtxt := vtxt || c10rec.dan || '</u></b>';
  end if;
 end loop;
 return(vtxt);
when 'CD702' then       -- Break-Bulk DANS: No HBs - SHIPPER
 vtxt := '&nbsp;';
 for c10rec in c10(rid_bs) loop
  if c10%ROWCOUNT = 1 and c10rec.dan = v_dan
   then
    cusrec := customer_details(c2rec.shipper);
    vtxt := cusrec.customer;
--    vtxt := vtxt || '<br>' || cusrec.street;
--    if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
--    vtxt := vtxt || cusrec.suburb;
--    if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
--    vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
  end if;
 end loop;
 return(vtxt);
when 'CD703' then       -- Break-Bulk DANS: No HBs - CONSIGNEE
 vtxt := '&nbsp;';
 for c10rec in c10(rid_bs) loop
  if c10%ROWCOUNT = 1 and c10rec.dan = v_dan
   then
    cusrec := customer_details(c2rec.consignee);
    vtxt := cusrec.customer;
    vtxt := vtxt || '<br>' || cusrec.street;
    if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
    vtxt := vtxt || cusrec.suburb;
    if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
    vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
  end if;
 end loop;
 return(vtxt);
when 'CD704' then       -- Break-Bulk DANS: No HBs - NO. OF PKGS.
 vtxt := '&nbsp;';
 for c10rec in c10(rid_bs) loop
  if c10%ROWCOUNT = 1 and c10rec.dan = v_dan
   then
    open c10c(rid_bs);
    fetch c10c into rec_cnt;
    close c10c;
    vtxt := '<b>' || rec_cnt || '</b>';
  end if;
 end loop;
 return(vtxt);
when 'CD705' then       -- Break-Bulk DANS: No HBs - DESCRIPTION
 foundrec := FALSE;
 for c10rec in c10(rid_bs) loop
  if c10%ROWCOUNT = 1 and c10rec.dan = v_dan
   then
    vtxt := '<b><u>BREAK-BULK:</u></b><br>';
    if nvl(c10rec.pieces, 0) > 0
     then
      vtxt := vtxt || c10rec.pieces || ' ';
    end if;
    vtxt := vtxt || lov_code('PACKTYPES', c10rec.packaging) || ': ';
    vtxt := vtxt || c10rec.commodity;
    foundrec := TRUE;
  elsif c10rec.dan = v_dan
   then
    if nvl(c10rec.pieces, 0) > 0
     then
      vtxt := vtxt || c10rec.pieces || ' ';
    end if;
    vtxt := vtxt || lov_code('PACKTYPES', c10rec.packaging) || ': ';
    vtxt := vtxt || c10rec.commodity;
    foundrec := TRUE;
  else
    foundrec := FALSE;
  end if;
 end loop;
 if foundrec -- Last DAN and no DANS with HBs
  then
   vtxt := vtxt || '<br><br>' || '<b>END OF BREAK-BULK</b>';
 end if;
 return(vtxt);
when 'CD706' then       -- Break-Bulk DANS: No HBs - SEAL NO.
 return('&nbsp;');
when 'CD707' then       -- Break-Bulk DANS: No HBs - WEIGHT
 wt := 0;
 for c10rec in c10(rid_bs) loop
  if c10rec.dan = v_dan
   then
    begin
     wt := wt + to_number(nvl(c10rec.kg, 0));
    exception when others then null;
    end;
  end if;
 end loop;
 vtxt := to_char(wt/1000, '999990.000');
 return(vtxt);
when 'CD708' then       -- Break-Bulk DANS: No HBs - VOLUME
 vol := 0;
 for c10rec in c10(rid_bs) loop
  if c10rec.dan = v_dan
   then
    begin
     vol := vol + to_number(nvl(c10rec.cbm, 0));
    exception when others then null;
    end;
  end if;
 end loop;
 if vol = 0
  then
   vtxt := '&nbsp;';
 else
   vtxt := to_char(vol, '999990.000');
 end if;
 return(vtxt);
when 'CD709' then       -- Break-Bulk DANS: No HBs - REVENUE
 wt := 0;
 for c10rec in c10(rid_bs) loop
  if c10rec.dan = v_dan
   then
    begin
     wt := wt + to_number(nvl(c10rec.kg, 0));
    exception when others then null;
    end;
  end if;
 end loop;

 vol := 0;
 for c10rec in c10(rid_bs) loop
  if c10rec.dan = v_dan
   then
    begin
     vol := vol + to_number(nvl(c10rec.cbm, 0));
    exception when others then null;
    end;
  end if;
 end loop;

 if vol = 0
  then
   vtxt := '&nbsp;';
 else
   if wt/1000 >= vol
    then
     vtxt := to_char(wt/1000, '999990.000');
   else
     vtxt := to_char(vol, '999990.000');
   end if;
 end if;
 return(vtxt);

when 'CD801' then       -- Break-Bulk DANS: HB - DAN NO. MARKS & NOS.
 vtxt := '<span id="8-' || v_hb || '-' || v_dan || '"></span>';
 vtxt := vtxt || '<b><u>';
 for c11rec in c11(rid_hs) loop
  if c11%ROWCOUNT = 1 and c11rec.dan = v_dan
   then
    vtxt := vtxt || 'DAN NO. ' || c11rec.dan;
    vtxt := vtxt || '</u></b><br>';
    cusrec := customer_details(c2rec.notifying_party);
    vtxt := vtxt ||cusrec.customer;
    vtxt := vtxt || '<br>' || cusrec.street;
    if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
    vtxt := vtxt || cusrec.suburb;
    if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
    vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
  elsif c11rec.dan = v_dan
   then
    vtxt := vtxt || c11rec.dan || '</u></b>';
  end if;
 end loop;
 return(vtxt);
when 'CD811' then       -- Break-Bulk DANS: HB - DAN NO. MARKS & NOS. - HOUSE BILL-SPECIFIC
 vtxt := '<span id="8-' || v_hb || '-' || v_dan || '"></span>';
 vtxt := vtxt || '<b><u>';
 for c11rec in c11(rid_hs) loop
  if c11rec.dan = v_dan
   then
    vtxt := vtxt || 'DAN NO. ' || c11rec.dan || '</u></b>';
  end if;
 end loop;
 return(vtxt);
when 'CD802' then       -- Break-Bulk DANS: HB - SHIPPER
 vtxt := '&nbsp;';
 for c11rec in c11(rid_hs) loop
  if c11%ROWCOUNT = 1 and c11rec.dan = v_dan
   then
    cusrec := customer_details(c2rec.shipper);
    vtxt := cusrec.customer;
--    vtxt := vtxt || '<br>' || cusrec.street;
--    if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
--    vtxt := vtxt || cusrec.suburb;
--    if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
--    vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
  end if;
 end loop;
 return(vtxt);
when 'CD803' then       -- Break-Bulk DANS: HB - CONSIGNEE
 vtxt := '&nbsp;';
 for c11rec in c11(rid_hs) loop
  if c11%ROWCOUNT = 1 and c11rec.dan = v_dan
   then
    cusrec := customer_details(c2rec.consignee);
    vtxt := cusrec.customer;
    vtxt := vtxt || '<br>' || cusrec.street;
    if cusrec.suburb is not null then vtxt := vtxt || ',<br>'; end if;
    vtxt := vtxt || cusrec.suburb;
    if cusrec.state || cusrec.postcode is not null then vtxt := vtxt || ',<br>'; end if;
    vtxt := vtxt || cusrec.state || ' ' || cusrec.postcode;
  end if;
 end loop;
 return(vtxt);
when 'CD804' then       -- Break-Bulk DANS: HB - NO. OF PKGS.
 vtxt := '&nbsp;';
 for c11rec in c11(rid_hs) loop
  if c11%ROWCOUNT = 1 and c11rec.dan = v_dan
   then
    open c11c(rid_hs);
    fetch c11c into rec_cnt;
    close c11c;
    vtxt := '<b>' || rec_cnt || '</b>';
  end if;
 end loop;
 return(vtxt);
when 'CD805' then       -- Break-Bulk DANS: HB - DESCRIPTION
 foundrec := FALSE;
 for c11rec in c11(rid_hs) loop
  if c11%ROWCOUNT = 1 and c11rec.dan = v_dan
   then
    vtxt := '<b><u>BREAK-BULK DANS - H/B ' || v_hb || ':</u></b><br>';
    if nvl(c11rec.pieces, 0) > 0
     then
      vtxt := vtxt || c11rec.pieces || ' ';
    end if;
    vtxt := vtxt || lov_code('PACKTYPES', c11rec.packaging) || ': ';
    vtxt := vtxt || c11rec.commodity;
    foundrec := TRUE;
  elsif c11rec.dan = v_dan
   then
    if nvl(c11rec.pieces, 0) > 0
     then
      vtxt := vtxt || c11rec.pieces || ' ';
    end if;
    vtxt := vtxt || lov_code('PACKTYPES', c11rec.packaging) || ': ';
    vtxt := vtxt || c11rec.commodity;
    foundrec := TRUE;
  else
    foundrec := FALSE;
  end if;
 end loop;
 if foundrec -- Last DANS for this HB
  then
   vtxt := vtxt || '<br><br>' || '<b>END OF DANS</b>';
 end if;
 return(vtxt);
when 'CD806' then       -- Break-Bulk DANS: HB - SEAL NO.
 return('&nbsp;');
when 'CD807' then       -- Break-Bulk DANS: HB - WEIGHT
 wt := 0;
 for c11rec in c11(rid_hs) loop
  if c11rec.dan = v_dan
   then
    begin
     wt := wt + to_number(nvl(c11rec.kg, 0));
    exception when others then null;
    end;
  end if;
 end loop;
 vtxt := to_char(wt/1000, '999990.000');
 return(vtxt);
when 'CD808' then       -- Break-Bulk DANS: HB - VOLUME
 vol := 0;
 for c11rec in c11(rid_hs) loop
  if c11rec.dan = v_dan
   then
    begin
     vol := vol + to_number(nvl(c11rec.cbm, 0));
    exception when others then null;
    end;
  end if;
 end loop;
 if vol = 0
  then
   vtxt := '&nbsp;';
 else
   vtxt := to_char(vol, '999990.000');
 end if;
 return(vtxt);
when 'CD809' then       -- Break-Bulk DANS: HB - REVENUE
 wt := 0;
 for c11rec in c11(rid_hs) loop
  if c11rec.dan = v_dan
   then
    begin
     wt := wt + to_number(nvl(c11rec.kg, 0));
    exception when others then null;
    end;
  end if;
 end loop;

 vol := 0;
 for c11rec in c11(rid_hs) loop
  if c11rec.dan = v_dan
   then
    begin
     vol := vol + to_number(nvl(c11rec.cbm, 0));
    exception when others then null;
    end;
  end if;
 end loop;

 if vol = 0
  then
   vtxt := '&nbsp;';
 else
   if wt/1000 >= vol
    then
     vtxt := to_char(wt/1000, '999990.000');
   else
     vtxt := to_char(vol, '999990.000');
   end if;
 end if;
 return(vtxt);

-- Miscellaneous Types

when 'CD901' then -- Single Container Number, or other message.
 rec_cnt := null;
 open c12a(rid_1);
 fetch c12a into rec_cnt;
 close c12a;

 if nvl(rec_cnt, 0) > 1                 -- > 1 Containers
  then
   return('AS PER ATTACHED SUMMARY');
 end if;

 if nvl(rec_cnt, 0) = 1                 -- 1 Container
  then
   rec_cnt := null;
   open c12b(rid_1);
   fetch c12b into rec_cnt;
   close c12b;
   if nvl(rec_cnt, 0) = 0               -- 1 Container, no break-bulk DANs
    then
     begin
      open c12c(rid_1);
      fetch c12c into vtxt;
      close c12c;
      return(vtxt);
     exception when others then
      return('N/A');
     end;
   elsif nvl(rec_cnt, 0) > 0            -- 1 Container, also break-bulk DANs
    then
     return('AS PER ATTACHED SUMMARY');
   end if;
 else
   return('N/A');                      -- 0 Containers
 end if;

when 'CD911' then -- Single Container Number, or other message. - HOUSE BILL-SPECIFIC
 rec_cnt := null;
 open c12d(rid_1);
 fetch c12d into rec_cnt;
 close c12d;

 if nvl(rec_cnt, 0) > 1                 -- > 1 Containers
  then
   return('AS PER ATTACHED SUMMARY');
 end if;

 if nvl(rec_cnt, 0) = 1                 -- 1 Container
  then
   rec_cnt := null;
   open c12e(rid_1);
   fetch c12e into rec_cnt;
   close c12e;
   if nvl(rec_cnt, 0) = 0               -- 1 Container, no break-bulk DANs
    then
     begin
      open c12f(rid_1);
      fetch c12f into vtxt;
      close c12f;
      return(vtxt);
     exception when others then
      return('N/A');
     end;
   elsif nvl(rec_cnt, 0) > 0            -- 1 Container, also break-bulk DANs
    then
     return('AS PER ATTACHED SUMMARY');
   end if;
 else
   return('N/A');                      -- 0 Containers
 end if;

else
 return(null);
end case;

-- Should never get here

return(null);

exception when others
 then
  glbx.dbg('Error in strangsb.ctr_detail [rid_1 = ' || rid_1 || '; type = ' || det_type || ']: ' || sqlerrm);
--  return('Error in strangsb.ctr_detail [rid_1 = ' || rid_1 || '; type = ' || det_type || ']: ' || sqlerrm);
  return(null);
end ctr_detail;

end strangsb;
/
