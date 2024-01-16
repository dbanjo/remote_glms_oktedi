CREATE OR REPLACE package body WEBSYS.oltp
as

 TYPE rp IS TABLE OF REPORT_PARAMETERS%ROWTYPE INDEX BY BINARY_INTEGER;
 NL_CHAR 	constant char(1) := chr(10);
 LINEFEED	constant char(2) := chr(13) || chr(10);

 cursor c_object(scid integer, ptype varchar2) is select * from oltp_object where screen_id = scid and primary_secondary = ptype order by screen_order;

 Gbufr		varchar2(32767);
 Lbufr		varchar2(32767);
 GBL_SELECT	varchar2(32767);
 GBL_NAME	varchar2(1000);
 GBL_SURL	varchar2(100);
 GBL_LTYPE	varchar2(100);
 GBL_STYPE	integer;
 GBL_REP	varchar2(100);
 GBL_PARENT	integer;
 Gout_clob	clob;
 DEFSECURITY	varchar2(100);

 function get_attribute( scid in integer, otype in varchar2, ptype in varchar2 ) return oltp_object%ROWTYPE;
 function conv_upper( cobj in c_object%ROWTYPE, val in varchar2 ) return varchar2;
 function total_rows( sqlstmt in varchar2 ) return integer;
 function query_rowid( acid in integer, sqlstmt in varchar2, cntrl in varchar2, currrowid in rowid, rows_to_ret in integer, ctr in out integer, accmode in varchar2 ) return GLBX.MYARRAY;
 function extract_sqlstmt( scid integer, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, parm3 in GLBX.MYARRAY, parm4 in GLBX.MYARRAY) return varchar2;
 function is_in( val in varchar2, p1 in GLBX.MYARRAY ) return boolean;
 function order_by( c1rec in oltp_overview%ROWTYPE, sort in varchar2 ) return varchar2;
 function lov_list_array( listval in varchar2 ) return GLBX.MYARRAY;
 function lov_sqlstmt( listval in varchar2 ) return GLBX.MYARRAY;
 function extract_tag_quick( val in varchar2 ) return varchar2;
 function extract_tag_value( tagval in varchar2, tagkey in varchar2 ) return varchar2;
 function indnt( pscene integer ) return integer;
 function extract_from_clause( sqlstmt in varchar2 ) return GLBX.MYARRAY;
 function attach_where_clause( sqlstmt in varchar2, where_clause in varchar2 ) return varchar2;
 function restrict_sqlstmt( acid in integer, sqlstmt in varchar2 ) return varchar2;
 function check_column_security( acid in integer, tname in varchar2, col_name in GLBX.MYARRAY, col_value in GLBX.MYARRAY ) return varchar2;
 function attach_alias( table_name in varchar2, where_clause in varchar2, alias in varchar2 ) return varchar2;
 function is_report_stopped( repid in integer ) return boolean;
 function merge_tablerows( row1 in varchar2, row2 in varchar2 ) return varchar2;
 function check_run_report( do_not_run_if_zero_stmt in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, rval in integer ) return varchar2;
 function ziprepname( rname in varchar2, dt in varchar2 ) return varchar2;

 procedure lov_list( listval in varchar2, currvalue in varchar2 );
 procedure lov_select( acid in integer, select_stmt in varchar2, currvalue in varchar2 );
 procedure display_object( acid in integer, surl in varchar2, ltype in varchar2, c1rec in OLTP_OVERVIEW%ROWTYPE, cobj in c_object%ROWTYPE, access_in in varchar2, rid in varchar2, col_name in GLBX.MYARRAY, col_value in GLBX.MYARRAY, gen_tabattr in varchar2, cntrl_str in varchar2, display_tablerowopen in boolean, res out varchar2 );
 procedure display_controlbar( attr in varchar2, navigate in varchar2, edit in varchar2, access_in in varchar2, current_row in integer, totrows in integer, alt_attr in varchar2 default null, hlp in varchar2 default null, acid in integer default null );
 procedure extract_row( acid in integer, c1rec in OLTP_OVERVIEW%ROWTYPE, rid in varchar2, col_name out GLBX.MYARRAY, col_value out GLBX.MYARRAY, dummy out integer );
 procedure display_screen_single( acid in integer, surl in varchar2, ltype in varchar2, stype in integer, pfx in THEME%ROWTYPE, crec in CUSTOMER_ACCOUNT%ROWTYPE, c1rec in OLTP_OVERVIEW%ROWTYPE, access_in in varchar2, rid in varchar2, cntrl_str in varchar2, current_row in integer default null, totrows in integer default null, msg in varchar2 default null );
 procedure display_screen_single_two( surl in varchar2, ltype in varchar2, c1rec in OLTP_OVERVIEW%ROWTYPE, access_in in varchar2, rid in varchar2 );
 procedure display_screen_many_tabular( surl in varchar2, ltype in varchar2, c1rec in OLTP_OVERVIEW%ROWTYPE, access_in in varchar2, rid in varchar2 );
 procedure display_screen_tabular( acid in integer, surl in varchar2, ltype in varchar2, stype in integer, pfx in THEME%ROWTYPE, crec in CUSTOMER_ACCOUNT%ROWTYPE, c1rec in OLTP_OVERVIEW%ROWTYPE, access_in in varchar2, rid in GLBX.MYARRAY, cntrl_str in varchar2, current_row in integer default null, totrows in integer default null, id in varchar2 default null, msg in varchar2 default null );
 procedure display_title_page( surl in varchar2, ltype in varchar2, c1rec in OLTP_OVERVIEW%ROWTYPE, access_in in varchar2, rid in varchar2 );
 procedure display_menu( surl in varchar2, acid in integer, ltype in varchar2, stype in integer, pfx in THEME%ROWTYPE, crec in CUSTOMER_ACCOUNT%ROWTYPE, c1rec in OLTP_OVERVIEW%ROWTYPE, access_in in varchar2, rid in varchar2, cntrl_str in varchar2, current_row in integer default null, totrows in integer default null, msg in varchar2 default null );
 procedure update_record( surl in varchar2, scid in integer, rid in varchar2, c1rec in oltp_overview%ROWTYPE, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, parm3 in GLBX.MYARRAY, parm4 in GLBX.MYARRAY, bypass in boolean DEFAULT FALSE, acid in integer default null );
 procedure insert_record( acid in integer, surl in varchar2, scid in integer, rid in varchar2, c1rec in oltp_overview%ROWTYPE, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, parm3 in GLBX.MYARRAY, parm4 in GLBX.MYARRAY );
 procedure delete_record( surl in varchar2, scid in integer, rid in varchar2, c1rec in oltp_overview%ROWTYPE, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, parm3 in GLBX.MYARRAY, parm4 in GLBX.MYARRAY, acid in integer default null );
 procedure delete_record_confirm( surl in varchar2, scid in integer, rid in varchar2, c1rec in oltp_overview%ROWTYPE, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, parm3 in GLBX.MYARRAY, parm4 in GLBX.MYARRAY );
 procedure disp_group_columns( acid in integer, surl in varchar2, c1rec in oltp_overview%ROWTYPE, new_table in BOOLEAN );
 procedure business_logic( acid in integer, surl in varchar2, scid in integer, c1rec in OLTP_OVERVIEW%ROWTYPE, rid in varchar2, finish out boolean);
 procedure business_rule( c2rec in OLTP_BUSINESS_RULE%ROWTYPE, col_name in GLBX.MYARRAY, col_value in GLBX.MYARRAY, action out varchar2 );
 procedure add_tbl( bufr in varchar2, ltag in out varchar2, acid in integer, parm1 in out NOCOPY GLBX.MYARRAY, parm2 in out NOCOPY GLBX.MYARRAY );
 procedure process_tag( ltag in out varchar2, tagval varchar2, typ in varchar2, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY );
 procedure report_file( acid in integer, fdir in varchar2, fname in varchar2, parm1 in out NOCOPY GLBX.MYARRAY, parm2 in out NOCOPY GLBX.MYARRAY, repid in integer );
 procedure clob_append( bufr in varchar2 );
 procedure substitute_parameters( vbufr in out varchar2, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY );
 procedure substitute_parameters2( vbufr in varchar2, vbfr1 out varchar2, vbfr2 out varchar2, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY );
 procedure execute_piction_report( acid in integer );
 procedure piction_report_sql( acid in integer, crec in report_temp_piction_tag%ROWTYPE, sqlrec in report_temp_piction_sql%ROWTYPE, sqlrec2 in report_temp_piction_sql%ROWTYPE, child_record_exists in out boolean );
 procedure run_the_report( repid in integer, ltype in varchar2, owner_id in integer );
 procedure check_include_file( vbufr in out varchar2, fdir in varchar2, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY );
 procedure display_row( c1rec in OLTP_OVERVIEW%ROWTYPE, rid in varchar2, col_name in GLBX.MYARRAY, col_value in GLBX.MYARRAY, pfx in THEME%ROWTYPE, ctr in integer );
 procedure display_row_edit( acid in integer, c1rec in OLTP_OVERVIEW%ROWTYPE, rid in varchar2, col_name in GLBX.MYARRAY, col_value in GLBX.MYARRAY, pfx in THEME%ROWTYPE, ctr in integer, current_row in integer );
 procedure prepopulate_values( acid in integer, surl in varchar2, c1rec in OLTP_OVERVIEW%ROWTYPE, col_name in GLBX.MYARRAY, col_value in out NOCOPY GLBX.MYARRAY );
 procedure ext_parms( acid in integer, parm1 in out NOCOPY GLBX.MYARRAY, parm2 in out NOCOPY GLBX.MYARRAY );
 procedure ext_function( acid in integer, parm1 in out NOCOPY GLBX.MYARRAY, parm2 in out NOCOPY GLBX.MYARRAY );
 procedure lov_sql( acid in integer, p1 in varchar2 );
 procedure prompt_extra_parms( surl in varchar2, owner_id in integer, ltype in varchar2, stype in integer, rq_id in integer, repid in integer, p0 in GLBX.MYARRAY, p1 in rp );
 procedure extract_col_total( acid in integer, c1rec in OLTP_OVERVIEW%ROWTYPE, rid in varchar2, col_name out GLBX.MYARRAY, col_value out GLBX.MYARRAY, dummy out integer );
 procedure display_procedure( surl in varchar2, acid in integer, ltype in varchar2, stype in integer, pfx in THEME%ROWTYPE, crec in CUSTOMER_ACCOUNT%ROWTYPE, c1rec in OLTP_OVERVIEW%ROWTYPE, access_in in varchar2, rid in varchar2, cntrl_str in varchar2, current_row in integer default null, totrows in integer default null, msg in varchar2 default null );
 procedure display_report( surl in varchar2, acid in integer, ltype in varchar2, stype in integer, pfx in THEME%ROWTYPE, crec in CUSTOMER_ACCOUNT%ROWTYPE, c1rec in OLTP_OVERVIEW%ROWTYPE, access_in in varchar2, rid in varchar2, cntrl_str in varchar2, current_row in integer default null, totrows in integer default null, msg in varchar2 default null );
 procedure ext_role( acid in integer, parm1 in out NOCOPY GLBX.MYARRAY, parm2 in out NOCOPY GLBX.MYARRAY );
 procedure ext_assign( acid in integer, parm1 in out NOCOPY GLBX.MYARRAY, parm2 in out NOCOPY GLBX.MYARRAY );
 procedure validate_attribute( nmb in integer, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY );
 procedure form_report( surl in varchar2, repid in integer, reploc in varchar2 );
 procedure clob_trim_header;
 procedure clob_trim_emptyrow;
 procedure empty_file(umo_rec in umo%ROWTYPE, is_lob in varchar2);
 procedure free_temporary_lob;
 procedure lov_date( val in varchar2 );
 procedure populate_other_parameters( rq_id integer, repid in integer, ltype in varchar2, owner_id in integer );
 procedure populate_other_parameters_p( ltype in varchar2, owner_id in integer, p0 in out nocopy GLBX.MYARRAY, p1 in out nocopy GLBX.MYARRAY, ptype in out nocopy GLBX.MYARRAY );
 procedure zip( zip_filename in varchar2, file_to_add in varchar2 );

 function xmlconv( vl in varchar2 )
  return varchar2
 as
  rv varchar2(32767);
 begin
  if vl is null then return( NULL ); end if;
  rv := vl;
  rv := replace( rv, '<', '&lt;' );
  rv := replace( rv, '>', '&gt;' );
  rv := replace( rv, '"', '&#034;' );
  rv := replace( rv, '#', '&#035;' );
  rv := replace( rv, '!', '&#033;' );
  rv := replace( rv, '%', '&#037;' );
  rv := replace( rv, '&', '&#038;' );
  rv := replace( rv, '''', '&#039;' );
  rv := replace( rv, chr(9), '&#009;' );
  rv := replace( rv, chr(10), '&#010;' );
  rv := replace( rv, chr(13), '&#013;' );
  return( rv );
 end xmlconv;

 procedure display_screen( surl in varchar2, rnd in varchar2, sname in varchar2, access_in in varchar2, rid in varchar2 default null, acid in integer default NULL )
 as

 cursor c1(sname varchar2) is select * from oltp_overview where screen_name = sname;

 c1rec		c1%ROWTYPE;
 crec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 ridarr		GLBX.MYARRAY;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

 begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'OLTP.DISPLAY_SCREEN' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 crec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 --crec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( crec.theme_name );

  open c1(upper(nvl(sname,'MAIN_MENU')));
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    close c1;
    open c1(nvl(sname,'Main Menu'));
    fetch c1 into c1rec;
    if c1%NOTFOUND
       then
         close c1;
         htp.p( 'Cannot find screen' );
         return;
    end if;
  end if;
  close c1;

  if (c1rec.bypass_edit = 'BEFORE QUERY')
   then
    execute immediate 'begin ' || c1rec.bypass_call || '(surl=>''' || surl || ''',call_name=>''' || c1rec.bypass_call || ''',parm=>''' || c1rec.bypass_parameter || '''); end;';
    return;
  elsif (c1rec.bypass_edit = 'AFTER QUERY') and (access_in in ('EDIT'))
   then
    execute immediate 'begin ' || c1rec.bypass_call || '(surl=>''' || surl || ''',rid=>''' || rid || ''',scid=>''' || c1rec.screen_id || ''',call_name=>''' || c1rec.bypass_call || ''',parm=>''' || c1rec.bypass_parameter || '''); end;';
    return;
  end if;

  if c1rec.screen_type = 'SINGLE'
   then
    display_screen_single( crec.aid, surl, ltype, stype, pfx, crec, c1rec, access_in, replace(rid,'~','+'), null );
  elsif c1rec.screen_type = 'SINGLE TWO COLUMN'
   then
    display_screen_single_two( surl, ltype, c1rec, access_in, replace(rid,'~','+') );
  elsif c1rec.screen_type = 'ONE TO MANY TABULAR'
   then
    display_screen_many_tabular( surl, ltype, c1rec, access_in, replace(rid,'~','+') );
  elsif c1rec.screen_type = 'TABULAR'
   then
    ridarr(1) := replace(rid,'~','+');
    display_screen_tabular( crec.aid, surl, ltype, stype, pfx, crec, c1rec, access_in, ridarr, null,  null, null );
  elsif c1rec.screen_type = 'TITLE PAGE'
   then
    display_title_page( surl, ltype, c1rec, access_in, replace(rid,'~','+') );
  elsif c1rec.screen_type = 'MENU'
   then
    display_menu( surl, crec.aid, ltype, stype, pfx, crec, c1rec, access_in, replace(rid,'~','+'), null );
  elsif c1rec.screen_type = 'PROCEDURE'
   then
    display_procedure( surl, crec.aid, ltype, stype, pfx, crec, c1rec, access_in, replace(rid,'~','+'), null );
  elsif c1rec.screen_type = 'REPORT'
   then
    display_report( surl, crec.aid, ltype, stype, pfx, crec, c1rec, access_in, replace(rid,'~','+'), null );
  end if;

 exception when others then
  glbx.error_details( 'OLTP', 'DISPLAY_SCREEN',null,crec.aid,errmsg=>sqlerrm);
 end display_screen;

 procedure lov_date( val in varchar2 )
 as
  dfrm	number;
  dto   number;
  msk   varchar2(100);
  incr  varchar2(100);
  x	integer;
  y	integer;
 begin
  --glbx.dbg( 'X:' || val );
  x := instr( val, ',', 1 );
  begin dfrm := substr(val,1,x-1); exception when others then null; end;
  y := instr( val, ',', 1, 2 );
  begin dto := substr(val,x+1,(y-x)-1); exception when others then null; end;
  x := y;
  y := instr( val, ',', 1, 3 );
  begin incr := substr(val,x+1,(y-x)-1); exception when others then null; end;
  begin msk := substr(val,y+1); exception when others then null; end;
  dfrm := abs(nvl(dfrm,1));
  dto := abs(nvl(dto,1));
  msk := nvl(msk,'DD-MON-YYYY');
  incr := nvl(incr,'M');

  --glbx.dbg( 'V:' || dfrm || '-' || dto || ':' || msk || '-' || incr );
  if incr not in ('D','Y') -- M
   then
    for j in (-1 * dfrm) .. dto loop
     if j = 0
      then
       htp.formselectoption( to_char(add_months(sysdate,j),msk), 'SELECTED' );
      else
       htp.formselectoption( to_char(add_months(sysdate,j),msk) );
     end if;
    end loop;
  elsif incr = 'D'
   then
    for j in (-1 * dfrm) .. dto loop
     if j = 0
      then
       htp.formselectoption( to_char(sysdate + j,msk), 'SELECTED' );
      else
       htp.formselectoption( to_char(sysdate + j,msk) );
     end if;
    end loop;
  elsif incr = 'Y'
   then
    for j in (-1 * dfrm) .. dto loop
     if j = 0
      then
       htp.formselectoption( to_char(add_months(sysdate,(j*12)),msk), 'SELECTED' );
      else
       htp.formselectoption( to_char(add_months(sysdate,(j*12)),msk) );
     end if;
    end loop;
  end if;
 end lov_date;

 procedure extract_row( acid in integer, c1rec in OLTP_OVERVIEW%ROWTYPE, rid in varchar2, col_name out GLBX.MYARRAY, col_value out GLBX.MYARRAY, dummy out integer )
 as

   sqlstmt		varchar2(32767);

   cursor_name		integer;
   col_count		integer;
   desc_t		dbms_sql.desc_tab;
   common_nmb		number;
   common_vc2		varchar2(4000);
   common_dte		date;
   tmpval		varchar2(4000);

 begin
   sqlstmt := 'select * from ' || c1rec.primary_table || ' where rowid = :rid';
   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, restrict_sqlstmt(acid,sqlstmt), dbms_sql.native );
   dbms_sql.bind_variable_rowid(cursor_name, ':rid', chartorowid(rid));
   dbms_sql.describe_columns(cursor_name,col_count,desc_t);

   for j in 1..col_count loop
    col_name(j) := desc_t(j).col_name;
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

   dummy := dbms_sql.fetch_rows( cursor_name );
   --htp.bold( sqlstmt || '-' || rid ); htp.nl;
   if dummy > 0
    then

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
      col_value(j) := tmpval;
     end loop;
  end if;

  dbms_sql.close_cursor( cursor_name );

 exception when others then
  glbx.error_details( 'OLTP', 'EXTRACT_ROW',null,null,errmsg=>sqlerrm);
 end extract_row;

 procedure extract_col_total( acid in integer, c1rec in OLTP_OVERVIEW%ROWTYPE, rid in varchar2, col_name out GLBX.MYARRAY, col_value out GLBX.MYARRAY, dummy out integer )
 as

   sqlstmt		varchar2(32767);

   cursor_name		integer;
   common_nmb		number;
   common_vc2		varchar2(4000);
   common_dte		date;
   col_count		integer;
   desc_t		dbms_sql.desc_tab;
   ttl			integer;

 begin
   sqlstmt := 'select * from ' || c1rec.primary_table;
   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, restrict_sqlstmt(acid,sqlstmt), dbms_sql.native );
   dbms_sql.describe_columns(cursor_name,col_count,desc_t);

   for j in 1..col_count loop
    col_name(j) := desc_t(j).col_name;
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
  dbms_sql.close_cursor( cursor_name );

  for j in 1..col_count loop
   ttl := 0;
   execute immediate restrict_sqlstmt( acid, 'select count(distinct ' || desc_t(j).col_name || ' ) tot from ' || c1rec.primary_table ) into ttl;
   col_value(j) := to_char(ttl);
  end loop;
  dummy := 1;

 exception when others then
  glbx.error_details( 'OLTP', 'EXTRACT_COL_TOTAL',null,null,errmsg=>sqlerrm);
 end extract_col_total;

 function get_attribute( scid in integer, otype in varchar2, ptype in varchar2 )
  return oltp_object%ROWTYPE
 as

   cursor c_object_type(scid integer, otype varchar2, ptype varchar2) is select * from oltp_object where screen_id = scid and attribute_type = otype and primary_secondary = ptype order by screen_order;

   retval c_object_type%ROWTYPE;

 begin

  open c_object_type(scid, otype, ptype);
  fetch c_object_type into retval;
  close c_object_type;
  return( retval );

 exception when others then
  glbx.error_details( 'OLTP', 'GET_ATTRIBUTE',null,null,errmsg=>'OTYPE:' || otype);
   return( NULL );
 end get_attribute;

procedure lov_list( listval in varchar2, currvalue in varchar2 )
 as

   lov_value	varchar2(1000);
   ctr		integer;
   lastloc	integer;
   ctr_loc	integer;

 begin
  ctr := 0;
  lastloc := 0;
  loop
   ctr := ctr + 1;
   if ctr > 1000 then exit; end if; -- Inf Loop Protection
   ctr_loc := instr(listval,',',1,ctr);
   if ctr_loc = 0
    then
     lov_value := substr(listval,lastloc+1);
     if lov_value is not null
      then
       if lov_value = currvalue
	then
	 htp.formselectoption( lov_value, 'SELECTED' );
	else
	 htp.formselectoption( lov_value );
       end if;
     end if;
     exit;
   end if;
   lov_value := substr(listval,lastloc+1,(ctr_loc-lastloc)-1);
   if lov_value is not null
    then
       if lov_value = currvalue
	then
	 htp.formselectoption( lov_value, 'SELECTED' );
	else
	 htp.formselectoption( lov_value );
       end if;
   end if;
   lastloc := ctr_loc;
  end loop;

 exception when others then
  glbx.error_details( 'OLTP', 'LOV_LIST',null,null,errmsg=>sqlerrm);
 end lov_list;

function lov_list_array( listval in varchar2 )
 return GLBX.MYARRAY
 as

   lov_value	varchar2(1000);
   ctr		integer;
   lastloc	integer;
   ctr_loc	integer;
   array_ctr	integer;
   ret_array	GLBX.MYARRAY;

 begin
  ctr := 0;
  lastloc := 0;
  array_ctr := 0;
  loop
   ctr := ctr + 1;
   if ctr > 1000 then exit; end if; -- Inf Loop Protection
   ctr_loc := instr(listval,',',1,ctr);
   if ctr_loc = 0
    then
     lov_value := substr(listval,lastloc+1);
     if lov_value is not null
      then
       array_ctr := array_ctr + 1;
       ret_array(array_ctr) := lov_value;
     end if;
     exit;
   end if;
   lov_value := substr(listval,lastloc+1,(ctr_loc-lastloc)-1);
   if lov_value is not null
    then
       array_ctr := array_ctr + 1;
       ret_array(array_ctr) := lov_value;
   end if;
   lastloc := ctr_loc;
  end loop;
  return( ret_array );
 exception when others then
  glbx.error_details( 'OLTP', 'LOV_LIST_ARRAY',null,null,errmsg=>sqlerrm);
end lov_list_array;

function lov_sqlstmt( listval in varchar2 )
 return GLBX.MYARRAY
 as

   TYPE DCurTyp IS REF CURSOR;  -- define weak REF CURSOR type
   dcurs  DCurTyp;
   lov_value	varchar2(1000);
   array_ctr	integer;
   ret_array	GLBX.MYARRAY;

 begin
  array_ctr := 0;
  open dcurs for listval;
  loop
   fetch dcurs into lov_value;
   if dcurs%NOTFOUND then exit; end if;
   array_ctr := array_ctr + 1;
   ret_array(array_ctr) := lov_value;
  end loop;
  close dcurs;
  return( ret_array );
 exception when others then
  glbx.error_details( 'OLTP', 'LOV_SQLSTMT',null,null,errmsg=>sqlerrm);
end lov_sqlstmt;

procedure lov_select( acid in integer, select_stmt in varchar2, currvalue in varchar2 )
 as

   cursor_name		integer;
   dummy 		integer;
   col_count		integer;
   desc_t		dbms_sql.desc_tab;
   common_nmb		number;
   common_vc2		varchar2(4000);
   common_dte		date;
   tmpval		varchar2(4000);
   tmpval2		varchar2(4000);

 begin

   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, restrict_sqlstmt(acid,select_stmt), dbms_sql.native );
   dbms_sql.describe_columns(cursor_name,col_count,desc_t);

   for j in 1..least(2,col_count) loop
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

   loop
     dummy := dbms_sql.fetch_rows(cursor_name);
     if dummy = 0 then exit; end if;
     tmpval := NULL;
     tmpval2 := NULL;
     for j in 1..least(2,col_count) loop
      tmpval := NULL;
      common_vc2 := NULL;
      common_nmb := NULL;
      common_dte := NULL;
      if desc_t(j).col_type in (1,96)
       then
        dbms_sql.column_value_char(cursor_name,j,common_vc2);
        if j = 1 then tmpval := rtrim( common_vc2 ); else tmpval2 := rtrim( common_vc2 ); end if;
       elsif desc_t(j).col_type = 2
        then
         dbms_sql.column_value(cursor_name,j,common_nmb);
         if j = 1 then tmpval := to_char( common_nmb ); else tmpval2 := to_char( common_nmb ); end if;
       elsif desc_t(j).col_type = 12
        then
         dbms_sql.column_value(cursor_name,j,common_dte);
         if j = 1 then tmpval := to_char( common_dte,LNG.TSMASK ); else tmpval2 := to_char( common_dte,LNG.TSMASK ); end if;
      end if;
     end loop;
     if tmpval2 = currvalue
      then
       htp.formselectoption( tmpval2, 'SELECTED', cattributes=>'VALUE="' || tmpval2 || '"' );
      else
       htp.formselectoption( tmpval2, cattributes=>'VALUE="' || tmpval2 || '"' );
     end if;
   end loop;

   dbms_sql.close_cursor( cursor_name );

 exception when others then
  glbx.error_details( 'OLTP', 'LOV_SELECT',null,null,errmsg=>sqlerrm);
 end lov_select;

 function conv_upper( cobj in c_object%ROWTYPE, val in varchar2 )
  return varchar2
 as
 begin
  if cobj.convert_uppercase = 'T'
   then
    return(upper(val));
  end if;
  return( val );
 end conv_upper;

 procedure display_object( acid in integer, surl in varchar2, ltype in varchar2, c1rec in OLTP_OVERVIEW%ROWTYPE, cobj in c_object%ROWTYPE, access_in in varchar2, rid in varchar2, col_name in GLBX.MYARRAY, col_value in GLBX.MYARRAY, gen_tabattr in varchar2, cntrl_str in varchar2, display_tablerowopen in boolean, res out varchar2 )
 as

  cursor c_umo(v_umo integer) is select aid,version, um.photo_thumbnail.width width, um.photo_thumbnail.height height,extras from umo um where umo_id = v_umo;

  show_val	varchar2(4000);
  tab_attr	varchar2(1000);
  curec		c_umo%ROWTYPE;
  condition	varchar2(1000);
  tdate		date;

 begin

   if access_in = 'QUERY'
    then
     condition := htf.formselectopen( 'PARM4' ) || htf.formselectoption( NULL ) || htf.formselectoption( '=' ) || htf.formselectoption( '<' ) || htf.formselectoption( '>' ) || htf.formselectoption( '<=' ) || htf.formselectoption( '>=' ) || htf.formselectoption( '<>' ) || htf.formselectoption( 'Is Null' ) || htf.formselectoption( 'Like' ) || htf.formselectclose;
   end if;

  -- In Query Mode, can only see queryable columns
  if (access_in = 'QUERY') and (cobj.can_be_queried_on = 'F')
   then
    return;
  end if;

  if display_tablerowopen
   then
    htp.tablerowclose;
  end if;

  if cobj.object_type = 'ATTRIBUTE'
    then
     if cobj.attribute_type in ('BACKGROUND','TITLE','HEADING','SCREEN ALIGNMENT','CONTROL BAR','CELL COLOUR') then return; end if;
     if cobj.attribute_type = 'TABLE MARKER SPLIT' then res := 'SPLIT'; return; end if;

   elsif cobj.object_type = 'COLUMN'
    then
     if access_in = 'QUERY'
      then
       show_val := NULL;
      else
       -- XXX: Note - populate default values here
       begin
        for j in col_name.first..col_name.last loop
         if col_name(j) = cobj.original_column then show_val := col_value(j); exit; end if;
        end loop;
       exception
        when others then show_val := cobj.default_value;
       end;
       show_val := conv_upper( cobj, show_val );
     end if;
     /*
     for j in col_name.first..col_name.last loop
      htp.p( cobj.original_column || '-' || col_name(j) || '-' || col_value(j) ); htp.nl;
     end loop;
     */

     -- Specify Attributes for display
     if cobj.data_type in ('INTEGER','NUMBER','VARCHAR','DATE','DATE TIME','TIME')
      then
       if c1rec.display_datatype_icon = 'T' and access_in in ('EDIT','QUERY')
        then
         if cobj.data_type = 'VARCHAR'
          then
           htp.tabledata(htf.img( glbx.IMAGE_LOCATION || 'adminc_varchar.gif',cattributes=>'border=0', calt=>LNG3.ADM_TXT_718 || ':' || cobj.help_text), cattributes=>gen_tabattr);
         elsif cobj.data_type = 'INTEGER'
          then
           htp.tabledata(htf.img( glbx.IMAGE_LOCATION || 'adminc_int.gif',cattributes=>'border=0', calt=>LNG3.ADM_TXT_720 || ':' || cobj.help_text), cattributes=>gen_tabattr);
         elsif cobj.data_type = 'NUMBER'
          then
           htp.tabledata(htf.img( glbx.IMAGE_LOCATION || 'adminc_number.gif',cattributes=>'border=0', calt=>LNG3.ADM_TXT_719 || ':' || cobj.help_text), cattributes=>gen_tabattr);
         elsif cobj.data_type = 'DATE'
          then
           htp.tabledata(htf.img( glbx.IMAGE_LOCATION || 'adminc_date.gif',cattributes=>'border=0', calt=>LNG3.ADM_TXT_721 || ':' || cobj.help_text), cattributes=>gen_tabattr);
         elsif cobj.data_type = 'TIME'
          then
           htp.tabledata(htf.img( glbx.IMAGE_LOCATION || 'adminc_time.gif',cattributes=>'border=0', calt=>LNG3.ADM_TXT_722 || ':' || cobj.help_text), cattributes=>gen_tabattr);
         end if;
       end if;
       if cobj.mandatory = 'T'
        then
         htp.tabledata( htf.bold(cobj.display_text), cattributes=>gen_tabattr );
        else
         htp.tabledata( cobj.display_text, cattributes=>gen_tabattr );
       end if;

       if (access_in = 'BROWSE') and (cobj.can_be_resorted_on = 'T')
        then
        htp.tabledata( htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=A' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sort.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_099 )) ||
                       htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=D' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sortdesc.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_100 )) );
       elsif (access_in = 'BROWSE')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;

       if (access_in = 'QUERY') and (cobj.can_be_queried_on = 'T')
        then
         htp.tabledata( condition, cattributes=>gen_tabattr );
       elsif (access_in = 'QUERY')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;
       if (access_in in ('EDIT') and nvl(cobj.display_only,'F') = 'F') or ((access_in = 'QUERY') and (cobj.can_be_queried_on = 'T'))
        then
         if cobj.data_type = 'DATE'
          then
           tdate := nvl(to_date( show_val, LNG.MASK ),sysdate);
           htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || '>' );
           htp.formselectopen( 'PARM1' );
           for j in 1..31 loop
            if to_number(to_char(tdate,'DD')) = j
             then
              htp.formselectoption( to_char(j), 'SELECTED' );
             else
              htp.formselectoption( to_char(j) );
            end if;
           end loop;
           htp.formselectclose;
           htp.formselectopen( 'PARM1' );
           if to_number(to_char(tdate,'MM')) = 1 then htp.formselectoption( LNG.LAB_TXT_073, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_073 ); end if;
           if to_number(to_char(tdate,'MM')) = 2 then htp.formselectoption( LNG.LAB_TXT_074, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_074 ); end if;
           if to_number(to_char(tdate,'MM')) = 3 then htp.formselectoption( LNG.LAB_TXT_075, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_075 ); end if;
           if to_number(to_char(tdate,'MM')) = 4 then htp.formselectoption( LNG.LAB_TXT_076, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_076 ); end if;
           if to_number(to_char(tdate,'MM')) = 5 then htp.formselectoption( LNG.LAB_TXT_077, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_077 ); end if;
           if to_number(to_char(tdate,'MM')) = 6 then htp.formselectoption( LNG.LAB_TXT_078, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_078 ); end if;
           if to_number(to_char(tdate,'MM')) = 7 then htp.formselectoption( LNG.LAB_TXT_079, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_079 ); end if;
           if to_number(to_char(tdate,'MM')) = 8 then htp.formselectoption( LNG.LAB_TXT_080, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_080 ); end if;
           if to_number(to_char(tdate,'MM')) = 9 then htp.formselectoption( LNG.LAB_TXT_081, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_081 ); end if;
           if to_number(to_char(tdate,'MM')) = 10 then htp.formselectoption( LNG.LAB_TXT_082, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_082 ); end if;
           if to_number(to_char(tdate,'MM')) = 11 then htp.formselectoption( LNG.LAB_TXT_083, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_083 ); end if;
           if to_number(to_char(tdate,'MM')) = 12 then htp.formselectoption( LNG.LAB_TXT_084, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_084 ); end if;
           htp.formselectclose;
           htp.formselectopen( 'PARM1' );
           for j in 1980..2020 loop
            if to_number(to_char(tdate,'YYYY')) = j
             then
              htp.formselectoption( to_char(j), 'SELECTED' );
             else
              htp.formselectoption( to_char(j) );
            end if;
           end loop;
           htp.formselectclose;
           htp.p( '</TD>' );

         else
           htp.tabledata( htf.formtext( 'PARM1', cobj.display_length, cobj.data_length, show_val), cattributes=>tab_attr );
           htp.formhidden( 'PARM2', cobj.oltp_id );
         end if;
        else
         htp.tabledata( show_val, cattributes=>tab_attr );
       end if;

     elsif cobj.data_type = 'MONEY'
      then
       if c1rec.display_datatype_icon = 'T' and access_in in ('EDIT','QUERY')
        then
          htp.tabledata(htf.img( glbx.IMAGE_LOCATION || 'adminc_money.gif',cattributes=>'border=0', calt=>LNG3.ADM_TXT_816 || ':' || cobj.help_text), cattributes=>gen_tabattr);
       end if;
       if cobj.mandatory = 'T'
        then
         htp.tabledata( htf.bold(cobj.display_text), cattributes=>gen_tabattr );
        else
         htp.tabledata( cobj.display_text, cattributes=>gen_tabattr);
       end if;
       if (access_in = 'BROWSE') and (cobj.can_be_resorted_on = 'T')
        then
        htp.tabledata( htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=A' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sort.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_099 )) ||
                       htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=D' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sortdesc.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_100 )) );
       elsif (access_in = 'BROWSE')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;

       if (access_in = 'QUERY') and (cobj.can_be_queried_on = 'T')
        then
         htp.tabledata( condition, cattributes=>gen_tabattr );
       elsif (access_in = 'QUERY')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;
       if (access_in in ('EDIT') and nvl(cobj.display_only,'F') = 'F') or ((access_in = 'QUERY') and (cobj.can_be_queried_on = 'T'))
        then
         htp.tabledata( htf.formtext( 'PARM1', cobj.display_length, cobj.data_length, glbx.conv_nmb(show_val)), cattributes=>tab_attr );
         htp.formhidden( 'PARM2', cobj.oltp_id );
        else
         htp.tabledata( glbx.conv_nmb(show_val), cattributes=>tab_attr );
       end if;

     elsif cobj.data_type = 'HIDDEN'
      then
         htp.formhidden( 'PARM1', cobj.lov_list );
         htp.formhidden( 'PARM2', cobj.oltp_id );
         htp.formhidden( 'PARM4', '=' );

     elsif cobj.data_type = 'LOV'
      then
       if c1rec.display_datatype_icon = 'T' and access_in in ('EDIT','QUERY')
        then
          htp.tabledata(htf.img( glbx.IMAGE_LOCATION || 'adminc_list.gif',cattributes=>'border=0', calt=>LNG3.ADM_TXT_576 || ':' || cobj.help_text), cattributes=>gen_tabattr);
       end if;
       if cobj.mandatory = 'T'
        then
         htp.tabledata( htf.bold(cobj.display_text), cattributes=>gen_tabattr );
        else
         htp.tabledata( cobj.display_text, cattributes=>gen_tabattr );
       end if;
       if (access_in = 'BROWSE') and (cobj.can_be_resorted_on = 'T')
        then
        htp.tabledata( htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=A' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sort.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_099 )) ||
                       htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=D' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sortdesc.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_100 )) );
       elsif (access_in = 'BROWSE')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;

       if (access_in = 'QUERY') and (cobj.can_be_queried_on = 'T')
        then
         htp.tabledata( condition, cattributes=>gen_tabattr );
       elsif (access_in = 'QUERY')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;
       if (access_in in ('EDIT') and nvl(cobj.display_only,'F') = 'F') or ((access_in = 'QUERY') and (cobj.can_be_queried_on = 'T'))
        then
         htp.formhidden( 'PARM2', cobj.oltp_id );
         htp.p( '<TD ' || tab_attr || '>' );
         htp.formselectopen( 'PARM1' );
         if cobj.mandatory = 'F'
          then
           htp.formselectoption( NULL );
         end if;
         if cobj.lov_select is null
          then
           lov_list( cobj.lov_list, show_val );
          else
           lov_select( acid, cobj.lov_select, show_val );
         end if;
         htp.formselectclose;
         htp.p( '</TD>' );
       else
         htp.tabledata( show_val, cattributes=>tab_attr );
       end if;

     elsif cobj.data_type = 'BOOLEAN'
      then
       if c1rec.display_datatype_icon = 'T' and access_in in ('EDIT','QUERY')
        then
          htp.tabledata(htf.img( glbx.IMAGE_LOCATION || 'adminc_boolean.gif',cattributes=>'border=0', calt=>LNG3.ADM_TXT_611 || ':' || cobj.help_text), cattributes=>gen_tabattr);
       end if;
       if cobj.mandatory = 'T'
        then
         htp.tabledata( htf.bold(cobj.display_text), cattributes=>gen_tabattr );
        else
         htp.tabledata( cobj.display_text, cattributes=>gen_tabattr );
       end if;
       if (access_in = 'BROWSE') and (cobj.can_be_resorted_on = 'T')
        then
        htp.tabledata( htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=A' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sort.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_099 )) ||
                       htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=D' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sortdesc.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_100 )) );
       elsif (access_in = 'BROWSE')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;

       if (access_in = 'QUERY') and (cobj.can_be_queried_on = 'T')
        then
         htp.tabledata( condition, cattributes=>gen_tabattr );
       elsif (access_in = 'QUERY')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;
       if (access_in in ('EDIT') and nvl(cobj.display_only,'F') = 'F') or ((access_in = 'QUERY') and (cobj.can_be_queried_on = 'T'))
        then
         if show_val = 'T'
          then
           htp.tabledata( htf.formcheckbox( 'PARM3', cobj.oltp_id, 'CHECKED' ), cattributes=>tab_attr);
          else
           htp.tabledata( htf.formcheckbox( 'PARM3', cobj.oltp_id ), cattributes=>tab_attr);
         end if;
        else
         if show_val = 'T'
          then
            htp.tabledata( LNG.PHG_TXT_045, cattributes=>tab_attr );
          else
            htp.tabledata( LNG.PHG_TXT_046, cattributes=>tab_attr );
         end if;
       end if;

     elsif cobj.data_type = 'TEXTBOX'
      then
       if c1rec.display_datatype_icon = 'T' and access_in in ('EDIT','QUERY')
        then
          htp.tabledata(htf.img( glbx.IMAGE_LOCATION || 'adminc_varchar.gif',cattributes=>'border=0', calt=>LNG3.ADM_TXT_718 || ':' || cobj.help_text), cattributes=>gen_tabattr);
       end if;
       if cobj.mandatory = 'T'
        then
         htp.tabledata( htf.bold(cobj.display_text), cattributes=>gen_tabattr );
        else
         htp.tabledata( cobj.display_text, cattributes=>gen_tabattr );
       end if;
       if (access_in = 'BROWSE') and (cobj.can_be_resorted_on = 'T')
        then
        htp.tabledata( htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=A' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sort.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_099 )) ||
                       htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=D' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sortdesc.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_100 )) );
       elsif (access_in = 'BROWSE')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;

       if (access_in = 'QUERY') and (cobj.can_be_queried_on = 'T')
        then
         htp.tabledata( condition, cattributes=>gen_tabattr );
       elsif (access_in = 'QUERY')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;
       if (access_in in ('EDIT') and nvl(cobj.display_only,'F') = 'F') or ((access_in = 'QUERY') and (cobj.can_be_queried_on = 'T'))
        then
         htp.tabledata( htf.formtextareaopen( 'PARM1', cobj.textbox_height, cobj.textbox_width ) || show_val || htf.formtextareaclose, cattributes=>tab_attr );
         htp.formhidden( 'PARM2', cobj.oltp_id );
        else
         htp.tabledata( glbx.conv_nmb(show_val), cattributes=>tab_attr );
       end if;
     end if;

   elsif cobj.object_type = 'UMO'
    then
       if cobj.mandatory = 'T'
        then
         htp.tabledata( htf.bold(cobj.display_text), cattributes=>gen_tabattr );
        else
         htp.tabledata( cobj.display_text, cattributes=>gen_tabattr );
       end if;
       if (access_in = 'BROWSE') and (cobj.can_be_resorted_on = 'T')
        then
        htp.tabledata( htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=A' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sort.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_099 )) ||
                       htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=D' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sortdesc.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_100 )) );
       elsif (access_in = 'BROWSE')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;

       if (access_in = 'QUERY') and (cobj.can_be_queried_on = 'T')
        then
         htp.tabledata( condition, cattributes=>gen_tabattr );
       elsif (access_in = 'QUERY')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;
      open c_umo(cobj.umo_id);
      fetch c_umo into curec;
      close c_umo;
      htp.tabledata( htf.anchor(
              'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || cobj.umo_id || '&parm1=DISPLAY_TYPE&parm2=GALLERY&parm1=DISPLAY_WHAT&parm2=MASTER'  || '&parm1=VERSION&parm2=' || curec.version || '&parm1=LOGIN_TYPE&parm2=IMAGEW',
              '<IMG BORDER=0 WIDTH=' || curec.width || ' HEIGHT=' || curec.height || ' SRC="' ||
              'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || cobj.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL'  || '&parm1=VERSION&parm2=' || curec.version||
              '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || to_char(curec.aid) || '" ' ||
	      'ALT="' || curec.extras.photo_name || '">') || htf.nl ||
	      htf.bold(curec.extras.photo_name) ,cattributes=>tab_attr );

   elsif cobj.object_type = 'DERIVED'
    then
       if cobj.mandatory = 'T'
        then
         htp.tabledata( htf.bold(cobj.display_text), cattributes=>gen_tabattr );
        else
         htp.tabledata( cobj.display_text, cattributes=>gen_tabattr );
       end if;
       if (access_in = 'BROWSE') and (cobj.can_be_resorted_on = 'T')
        then
        htp.tabledata( htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=A' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sort.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_099 )) ||
                       htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=D' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sortdesc.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_100 )) );
       elsif (access_in = 'BROWSE')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;

       if (access_in = 'QUERY') and (cobj.can_be_queried_on = 'T')
        then
         htp.tabledata( condition, cattributes=>gen_tabattr );
       elsif (access_in = 'QUERY')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;

   elsif cobj.object_type = 'ANCHOR'
    then
       if cobj.mandatory = 'T'
        then
         htp.tabledata( htf.bold(cobj.display_text), cattributes=>gen_tabattr );
        else
         htp.tabledata( cobj.display_text, cattributes=>gen_tabattr );
       end if;
       if (access_in = 'BROWSE') and (cobj.can_be_resorted_on = 'T')
        then
        htp.tabledata( htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=A' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sort.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_099 )) ||
                       htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=D' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sortdesc.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_100 )) );
       elsif (access_in = 'BROWSE')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;

       if (access_in = 'QUERY') and (cobj.can_be_queried_on = 'T')
        then
         htp.tabledata( condition, cattributes=>gen_tabattr );
       elsif (access_in = 'QUERY')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;

   elsif cobj.object_type = 'PREBUILT'
    then
       if cobj.mandatory = 'T'
        then
         htp.tabledata( htf.bold(cobj.display_text), cattributes=>gen_tabattr );
        else
         htp.tabledata( cobj.display_text, cattributes=>gen_tabattr );
       end if;
       if (access_in = 'BROWSE') and (cobj.can_be_resorted_on = 'T')
        then
        htp.tabledata( htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=A' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sort.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_099 )) ||
                       htf.anchor( 'oltp.process_query?id=n&access_in=BROWSE&rnd=' || to_char(sysdate,'SSSSS') || '&sort=D' || cobj.oltp_id || cntrl_str, htf.img( glbx.IMAGE_LOCATION || 'adminc_sortdesc.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_100 )) );
       elsif (access_in = 'BROWSE')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;

       if (access_in = 'QUERY') and (cobj.can_be_queried_on = 'T')
        then
         htp.tabledata( condition, cattributes=>gen_tabattr );
       elsif (access_in = 'QUERY')
        then
         htp.tabledata( '&nbsp;', cattributes=>gen_tabattr );
       end if;

   end if;
  if display_tablerowopen
   then
    htp.tablerowclose;
  end if;
 exception
  when others
   then htp.p( 'H:' || sqlerrm );
 end display_object;

 procedure display_controlbar( attr in varchar2, navigate in varchar2, edit in varchar2, access_in in varchar2, current_row in integer, totrows in integer, alt_attr in varchar2 default null, hlp in varchar2 default null, acid in integer default null )
 as
 begin
   htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
   htp.tablerowopen;

   if access_in in ('QUERY')
    then
     htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid || '&id=h&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=QUERY' || attr || '&parm1=&parm2=&parm3=&parm4=', htf.img( glbx.IMAGE_LOCATION || 'adminc_home.gif',cattributes=>'border=0',calt=>LNG.LAB_TXT_002 )) );
     htp.tabledata( htf.formimage( 'ACTION1', glbx.IMAGE_LOCATION || 'adminc_execquery.gif',cattributes=>'border=0' ) );
     htp.tabledata( htf.formimage( 'ACTION5', glbx.IMAGE_LOCATION || 'adminc_unique.gif',cattributes=>'border=0' ) );
   end if;

   if access_in in ('BROWSE','EDIT')
    then
     htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid ||  '&id=h&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=QUERY' || attr, htf.img( glbx.IMAGE_LOCATION || 'adminc_home.gif',cattributes=>'border=0',calt=>LNG.LAB_TXT_002 )) );
     htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid ||  '&id=b&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=QUERY' || attr, htf.img( glbx.IMAGE_LOCATION || 'adminc_query.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_094 )) );
     if access_in = 'BROWSE' and substr(navigate,1,1) = 'T'
      then
       if alt_attr is null
        then
         htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid ||  '&id=e&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=EDIT' || attr, htf.img( glbx.IMAGE_LOCATION || 'adminc_edit.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_091 )) );
        else
         htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid ||  '&id=e&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=EDIT' || alt_attr, htf.img( glbx.IMAGE_LOCATION || 'adminc_edit.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_091 )) );
       end if;
     end if;
     htp.tabledata( htf.img( glbx.IMAGE_LOCATION || 'adminc_dispbar.gif',cattributes=>'border=0',calt=>NULL ) );
   end if;

   if access_in in ('BROWSE')
    then
     if substr(navigate,1,1) = 'T'
      then
       if nvl(current_row,0) = 1
        then
         htp.tabledata( htf.img( glbx.IMAGE_LOCATION || 'adminc_first.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_084 ));
        else
         htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid ||  '&id=1&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=BROWSE' || attr, htf.img( glbx.IMAGE_LOCATION || 'adminc_first.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_084 )) );
       end if;
     end if;
     if substr(navigate,2,1) = 'T'
      then
       if nvl(current_row,0) <= 5
        then
         htp.tabledata( htf.img( glbx.IMAGE_LOCATION || 'adminc_prevset.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_085 ) );
        else
         if alt_attr is null
          then
           htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid ||  '&id=2&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=BROWSE' || attr, htf.img( glbx.IMAGE_LOCATION || 'adminc_prevset.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_085 )) );
          else
           htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid ||  '&id=2&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=BROWSE' || alt_attr, htf.img( glbx.IMAGE_LOCATION || 'adminc_prevset.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_085 )) );
         end if;
       end if;
     end if;
     if substr(navigate,3,1) = 'T'
      then
       if nvl(current_row,0) = 1
        then
         htp.tabledata( htf.img( glbx.IMAGE_LOCATION || 'adminc_previous.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_086 ) );
        else
         if alt_attr is null
          then
           htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid ||  '&id=3&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=BROWSE' || attr, htf.img( glbx.IMAGE_LOCATION || 'adminc_previous.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_086 )) );
          else
           htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid ||  '&id=3&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=BROWSE' || alt_attr, htf.img( glbx.IMAGE_LOCATION || 'adminc_previous.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_086 )) );
         end if;
       end if;
     end if;

     if alt_attr is null
      then
       htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid ||  '&id=n&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=BROWSE' || attr, htf.img( glbx.IMAGE_LOCATION || 'adminc_refresh.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_101 )) );
      else
       htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid ||  '&id=n&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=BROWSE' || alt_attr, htf.img( glbx.IMAGE_LOCATION || 'adminc_refresh.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_101 )) );
     end if;

     if substr(navigate,4,1) = 'T'
      then
       if nvl(current_row,0) = nvl(totrows,0)
        then
         htp.tabledata( htf.img( glbx.IMAGE_LOCATION || 'adminc_next.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_089 ) );
        else
         htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid ||  '&id=4&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=BROWSE' || attr, htf.img( glbx.IMAGE_LOCATION || 'adminc_next.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_089 )) );
       end if;
     end if;
     if substr(navigate,5,1) = 'T'
      then
       if nvl(current_row,0)+5 >= nvl(totrows,0)
        then
         htp.tabledata( htf.img( glbx.IMAGE_LOCATION || 'adminc_nextset.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_088 ) );
        else
         htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid ||  '&id=5&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=BROWSE' || attr, htf.img( glbx.IMAGE_LOCATION || 'adminc_nextset.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_088 )) );
       end if;
     end if;
     if substr(navigate,6,1) = 'T'
      then
       if nvl(current_row,0) = nvl(totrows,0)
        then
         htp.tabledata( htf.img( glbx.IMAGE_LOCATION || 'adminc_last.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_087 ) );
        else
         htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid ||  '&id=6&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=BROWSE' || attr, htf.img( glbx.IMAGE_LOCATION || 'adminc_last.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_087 )) );
       end if;
     end if;
     htp.tabledata( htf.img( glbx.IMAGE_LOCATION || 'adminc_dispbar.gif',cattributes=>'border=0',calt=>NULL ) );
     if substr(navigate,7,1) = 'T'
      then
       htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid ||  '&id=z&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=EDIT' || attr, htf.img( glbx.IMAGE_LOCATION || 'adminc_insert.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_093 )) );
     end if;
     if substr(navigate,8,1) = 'T'
      then
       htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid ||  '&id=8&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=EDIT' || attr, htf.img( glbx.IMAGE_LOCATION || 'adminc_copy.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_090 )) );
     end if;
     if substr(navigate,9,1) = 'T'
      then
       htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid  || '&id=9&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=EDIT' || attr, htf.img( glbx.IMAGE_LOCATION || 'adminc_delete.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_092 )) );
     end if;
  end if;

  if access_in in ('EDIT')
   then
     if substr(edit,1,1) = 'T'
      then
       htp.tabledata( htf.formimage( 'ACTION2', glbx.IMAGE_LOCATION || 'adminc_save.gif',cattributes=>'border=0' ) );
     end if;
     if substr(edit,2,1) = 'T'
      then
       htp.tabledata( htf.formimage( 'ACTION3', glbx.IMAGE_LOCATION || 'adminc_clear.gif',cattributes=>'border=0' ) );
     end if;
     if substr(edit,3,1) = 'T'
      then
       htp.tabledata( htf.formimage( 'ACTION4', glbx.IMAGE_LOCATION || 'adminc_cancel.gif',cattributes=>'border=0' ) );
     end if;
  end if;

  if access_in in ('BROWSE')
   then
     htp.tabledata( htf.img( glbx.IMAGE_LOCATION || 'adminc_dispbar.gif',cattributes=>'border=0',calt=>NULL ) );
     htp.tabledata( nvl(to_char(current_row),'?') || '/' || nvl(to_char(totrows),'?') );
  end if;

  htp.tablerowclose;
  htp.tableclose;
  if substr(hlp,1,1) = 'X'
   then
    htp.nl;
    htp.p( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
    htp.nl;
  end if;
 exception
  when others
   then htp.p( 'G:' || sqlerrm );
 end display_controlbar;

 procedure prepopulate_values( acid in integer, surl in varchar2, c1rec in OLTP_OVERVIEW%ROWTYPE, col_name in GLBX.MYARRAY, col_value in out NOCOPY GLBX.MYARRAY )
 as

  cursor c2( scid integer ) is select * from oltp_object where screen_id = scid and default_value is not null;
  cursor c3( scid integer ) is select * from oltp_object where screen_id = scid and is_primary_key = 'T' and generate_pk = 'T';

 begin
  -- Setup Default Values
  for c2rec in c2( c1rec.screen_id ) loop
   for j in col_name.first..col_name.last loop
    if col_name(j) = c2rec.original_column
     then
      col_value(j) := c2rec.default_value;
    end if;
   end loop;
  end loop;

  for c3rec in c3( c1rec.screen_id ) loop
   for j in col_name.first..col_name.last loop
    if col_name(j) = c3rec.original_column
     then
      col_value(j) := aug( c3rec.original_column );
    end if;
   end loop;
  end loop;

 exception
  when others
   then htp.p( 'PV:' || sqlerrm );
 end prepopulate_values;

 procedure display_screen_single( acid in integer, surl in varchar2, ltype in varchar2, stype in integer, pfx in THEME%ROWTYPE, crec in CUSTOMER_ACCOUNT%ROWTYPE, c1rec in OLTP_OVERVIEW%ROWTYPE, access_in in varchar2, rid in varchar2, cntrl_str in varchar2, current_row in integer default null, totrows in integer default null, msg in varchar2 default null )
 as

  col_name	GLBX.MYARRAY;
  col_value	GLBX.MYARRAY;
  lst_grp	oltp_object.htmltable_name%TYPE;
  obj		oltp_object%ROWTYPE;
  obj1		oltp_object%ROWTYPE;
  obj2		oltp_object%ROWTYPE;
  res		varchar2(100);
  v_rid		varchar2(100);
  attr		varchar2(1000);
  ctr		integer;
  outrow	integer;
  v_access_in	varchar2(100);

 begin

  -- Extra PFX
  -- Display Title
  v_rid := rid;
  if (access_in in ('BROWSE','EDIT')) and (rid is not null)
   then
    extract_row( acid, c1rec, rid, col_name, col_value, outrow );
    if outrow = 0
     then
      v_access_in := 'BROWSE';
      v_rid := NULL;
    end if;
   elsif access_in = 'EDIT' and rid is null -- Insert
    then
     extract_row( acid, c1rec, rid, col_name, col_value, outrow );
     v_rid := NULL;
   elsif access_in = 'BROWSET'
    then
     extract_col_total( acid, c1rec, rid, col_name, col_value, outrow );
   elsif access_in = 'COPY'
    then
     extract_row( acid, c1rec, rid, col_name, col_value, outrow );
     v_rid := NULL;
     if outrow = 0
      then
       v_access_in := 'BROWSE';
     end if;
  end if;

  if (access_in = 'BROWSE') and (v_rid is null)
   then
    -- No Rows Returned from Query
    v_access_in := 'QUERY';
  elsif (access_in = 'BROWSET') and (v_rid is null)
   then
    -- No Rows Returned from Query
    v_access_in := 'QUERY';
   else
    if access_in = 'COPY'
     then
      v_access_in := 'EDIT';
     else
      v_access_in := access_in;
    end if;
  end if;

  obj := get_attribute( c1rec.screen_id, 'HEADING', 'PRIMARY' );
  glbx.main_title( surl, obj.attribute_prebuilt,glbx.backimg(surl,crec.aid,pfx.text_back,crec.background_img,ltype),helpid=>c1rec.help_id,stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
  obj := get_attribute( c1rec.screen_id, 'TITLE', 'PRIMARY' );
  htp.p( '<CENTER>' );
  if obj.attribute_prebuilt is not null
   then
    htp.title( obj.attribute_prebuilt );
  end if;
  if (access_in = 'BROWSE') and (v_rid is null)
   then
    glbx.header_msg( 'Query Returned no rows.' || ' [' || 'Query Mode' || ']' );
   else
    if obj.attribute_prebuilt is not null
     then
      if v_access_in = 'QUERY'
       then
        glbx.header_msg( obj.attribute_prebuilt || ' [' || 'Query Mode' || ']' );
      elsif v_access_in = 'BROWSE'
       then
        glbx.header_msg( obj.attribute_prebuilt || ' [' || 'Browse Mode' || ']' );
      elsif v_access_in = 'EDIT'
       then
        if v_rid is null
         then
          glbx.header_msg( obj.attribute_prebuilt || ' [' || 'Insert Mode' || ']' );
         else
          glbx.header_msg( obj.attribute_prebuilt || ' [' || 'Edit Mode' || ']' );
        end if;
      end if;
    end if;
  end if;
  if msg is not null then glbx.header_msg( msg ); end if;

  if (c1rec.group_column is not null) and (access_in = 'BROWSE')
   then
    disp_group_columns(acid,surl,c1rec,TRUE);
  end if;

  obj1 := get_attribute( c1rec.screen_id, 'SCREEN ALIGNMENT', 'PRIMARY' );
  obj2 := get_attribute( c1rec.screen_id, 'CELL COLOUR', 'PRIMARY' );
  htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=2' );
  htp.tablerowopen;
  htp.p( '<TD align="' || nvl(obj1.attribute_prebuilt,'LEFT') || '" bgcolor="#' || obj2.attribute_prebuilt || '">' );

  if v_access_in in ('QUERY','EDIT')
   then
    htp.formopen( 'oltp.process_query' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'RND', to_char(sysdate,'SSSSS'));
    htp.formhidden( 'RID', v_rid );
    htp.formhidden( 'ACCESS_IN', v_access_in );
    htp.formhidden( 'SCID', c1rec.screen_id );
    htp.formhidden( 'PARM3', NULL );
    htp.formhidden( 'ACID', acid );
    if v_access_in = 'EDIT'
     then
      htp.formhidden( 'PARM4', NULL );
      if v_rid is null
       then
        htp.formhidden( 'ID', 'i');
        prepopulate_values( acid, surl, c1rec, col_name, col_value );
       else
        htp.formhidden( 'ID', 'x');
      end if;
    end if;
  end if;

  lst_grp := NULL;
  for cobj in c_object( c1rec.screen_id, 'PRIMARY' ) loop
   if (cobj.object_type in ('COLUMN')) and (cobj.display = 'T')
    then
     if (lst_grp is null) or (lst_grp <> cobj.htmltable_name)
      then
       if (lst_grp <> cobj.htmltable_name)
        then
         htp.tableclose;
         htp.nl;
       end if;
       htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     end if;
     lst_grp := cobj.htmltable_name;
   end if;

   if cobj.display = 'T'
    then
     ctr := ctr + 1;
     if c1rec.alternate_colours = 'T'
      then
       if mod(ctr,2) = 0
        then
         attr := 'bgcolor="#' || pfx.lhs_back || ' valign="MIDDLE" align="LEFT"';
        else
         attr := 'bgcolor="#' || pfx.lhs_back || ' valign="MIDDLE" align="LEFT"';
       end if;
      else
       attr := 'bgcolor="#' || pfx.lhs_back || ' valign="MIDDLE" align="LEFT"';
     end if;
     display_object( acid, surl, ltype, c1rec, cobj, v_access_in, v_rid, col_name, col_value, attr, '&surl=' || glbx.rndsurl(surl) || '&rid=' || replace(v_rid,'+','~') || '&scid=' || c1rec.screen_id || cntrl_str, TRUE, res );
   end if;
   -- Post Display Commands
   if res = 'SPLIT'
    then
     lst_grp := NULL;
   end if;

  end loop;
  htp.tableclose;
  htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tableclose;
  htp.nl;

  obj := get_attribute( c1rec.screen_id, 'CONTROL BAR', 'PRIMARY' );
  display_controlbar( '&surl=' || glbx.rndsurl(surl) || '&rid=' || replace(v_rid,'+','~') || '&scid=' || c1rec.screen_id || cntrl_str || '&acid=' || acid,
                      obj.attribute_prebuilt, 'TTT', v_access_in, current_row, totrows, hlp=>c1rec.help_id, acid=>acid );

  if v_access_in in ('EDIT','QUERY')
   then
    htp.formclose;
  end if;
  htp.p( '</CENTER>' );
  htp.htmlclose;

 exception when others then
  glbx.error_details( 'OLTP', 'DISPLAY_SCREEN_SINGLE',null,acid,errmsg=>sqlerrm);
 end display_screen_single;

 procedure display_screen_single_two( surl in varchar2, ltype in varchar2, c1rec in OLTP_OVERVIEW%ROWTYPE, access_in in varchar2, rid in varchar2 )
 as
 begin
  null;


 exception when others then
  glbx.error_details( 'OLTP', 'DISPLAY_SCREEN_SINGLE_TWO',null,null,errmsg=>sqlerrm);
 end display_screen_single_two;

 procedure display_screen_many_tabular( surl in varchar2, ltype in varchar2, c1rec in OLTP_OVERVIEW%ROWTYPE, access_in in varchar2, rid in varchar2 )
 as
 begin
  null;


 exception when others then
  glbx.error_details( 'OLTP', 'DISPLAY_SCREEN_MANY_TABULAR',null,null,errmsg=>sqlerrm);
 end display_screen_many_tabular;

 procedure display_row( c1rec in OLTP_OVERVIEW%ROWTYPE, rid in varchar2, col_name in GLBX.MYARRAY, col_value in GLBX.MYARRAY, pfx in THEME%ROWTYPE, ctr in integer )
 as

  cursor c2( scid integer ) is
   select original_column
   from oltp_object
   where screen_id = scid and
         display = 'T' and
         object_type = 'COLUMN'
   order by screen_order;

  attr	varchar2(1000);

 begin

  if c1rec.alternate_colours = 'T'
   then
    if mod(ctr,2) = 0
     then
      attr := 'bgcolor="#' || pfx.lhs_back || ' valign="MIDDLE" align="LEFT"';
     else
      attr := 'bgcolor="#' || pfx.lhs_back || ' valign="MIDDLE" align="LEFT"';
    end if;
   else
    attr := 'bgcolor="#' || pfx.lhs_back || ' valign="MIDDLE" align="LEFT"';
  end if;
 htp.tablerowopen;
 for c2rec in c2(c1rec.screen_id) loop
  for j in col_name.first..col_name.last loop
   if col_name(j) = c2rec.original_column
    then
     htp.tabledata( col_value( j ), cattributes=>attr );
   end if;
  end loop;
 end loop;
 htp.tablerowclose;

 exception when others then
  glbx.error_details( 'OLTP', 'DISPLAY_ROW',null,null,errmsg=>sqlerrm);
 end display_row;

 procedure display_row_edit( acid in integer, c1rec in OLTP_OVERVIEW%ROWTYPE, rid in varchar2, col_name in GLBX.MYARRAY, col_value in GLBX.MYARRAY, pfx in THEME%ROWTYPE, ctr in integer, current_row in integer )
 as

  cursor c2( scid integer ) is
   select *
   from oltp_object
   where screen_id = scid and
         display = 'T' and
         nvl(display_only,'F') = 'F' and
         object_type = 'COLUMN'
   order by screen_order;

  attr	varchar2(1000);

 begin

  if c1rec.alternate_colours = 'T'
   then
    if mod(ctr,2) = 0
     then
      attr := 'bgcolor="#' || pfx.lhs_back || ' valign="MIDDLE"';
     else
      attr := 'bgcolor="#' || pfx.lhs_back || ' valign="MIDDLE"';
    end if;
   else
    attr := 'bgcolor="#' || pfx.lhs_back || ' valign="MIDDLE"';
  end if;

 htp.tablerowopen;
 htp.tabledata( current_row, cattributes=>attr || ' align="RIGHT"' );
 for c2rec in c2(c1rec.screen_id) loop
  for j in col_name.first..col_name.last loop
   if col_name(j) = c2rec.original_column
    then
     if c2rec.data_type = 'NUMBER'
      then
       htp.tabledata( htf.formtext( 'PARM1', nvl(c2rec.display_length,20), c2rec.data_length, col_value( j ) ) || htf.formhidden( 'PARM2', c2rec.oltp_id ) || htf.formhidden( 'PARM3', rid ), cattributes=>attr || ' align="RIGHT"' );
     elsif c2rec.data_type = 'LOV'
      then
         htp.p( '<TD ' || attr || ' align="CENTER"' || '>' );
         htp.formselectopen( 'PARM1' );
         if c2rec.mandatory = 'F'
          then
           htp.formselectoption( NULL );
         end if;
         if c2rec.lov_select is null
          then
           lov_list( c2rec.lov_list, col_value( j ) );
          else
           lov_select( acid, c2rec.lov_select, col_value( j ) );
         end if;
         htp.formselectclose;
         htp.p( '</TD>' );
         htp.formhidden( 'PARM2', c2rec.oltp_id );
         htp.formhidden( 'PARM3', rid );
     elsif c2rec.data_type = 'BOOLEAN'
      then
         htp.p( '<TD ' || attr || ' align="CENTER"' || '>' );
         htp.formselectopen( 'PARM1' );
         if col_value( j ) = 'T'
          then
           htp.formselectoption( LNG.PHG_TXT_045, 'SELECTED', cattributes=>'VALUE="' || 'T' || '"' );
           htp.formselectoption( LNG.PHG_TXT_046, cattributes=>'VALUE="' || 'F' || '"' );
          else
           htp.formselectoption( LNG.PHG_TXT_045, cattributes=>'VALUE="' || 'T' || '"' );
           htp.formselectoption( LNG.PHG_TXT_046, 'SELECTED', cattributes=>'VALUE="' || 'F' || '"' );
         end if;
         htp.formselectclose;
         htp.formhidden( 'PARM2', c2rec.oltp_id );
         htp.formhidden( 'PARM3', rid );
         htp.p( '</TD>' );
      else
       htp.tabledata( htf.formtext( 'PARM1', nvl(c2rec.display_length,20), c2rec.data_length, col_value( j ) ) || htf.formhidden( 'PARM2', c2rec.oltp_id ) || htf.formhidden( 'PARM3', rid ), cattributes=>attr || ' align="LEFT"' );
     end if;
   end if;
  end loop;
 end loop;
 htp.tablerowclose;

 exception when others then
  glbx.error_details( 'OLTP', 'DISPLAY_ROW_EDIT',null,acid,errmsg=>sqlerrm);
 end display_row_edit;

 procedure display_screen_tabular( acid in integer, surl in varchar2, ltype in varchar2, stype in integer, pfx in THEME%ROWTYPE, crec in CUSTOMER_ACCOUNT%ROWTYPE, c1rec in OLTP_OVERVIEW%ROWTYPE, access_in in varchar2, rid in GLBX.MYARRAY, cntrl_str in varchar2, current_row in integer default null, totrows in integer default null, id in varchar2 default null, msg in varchar2 default null )
 as

  cursor c2( scid integer ) is
   select display_text
   from oltp_object
   where screen_id = scid and
         display = 'T' and
         object_type = 'COLUMN'
   order by screen_order;

  cursor c3( scid integer ) is
   select display_text
   from oltp_object
   where screen_id = scid and
         display = 'T' and
         nvl(display_only,'F') = 'F' and
         object_type = 'COLUMN'
   order by screen_order;

  col_name	GLBX.MYARRAY;
  col_value	GLBX.MYARRAY;
  lst_grp	oltp_object.htmltable_name%TYPE;
  obj		oltp_object%ROWTYPE;
  obj1		oltp_object%ROWTYPE;
  obj2		oltp_object%ROWTYPE;
  res		varchar2(100);
  v_rid		varchar2(100);
  attr		varchar2(1000);
  ctr		integer;
  firstrid	varchar2(100);
  lastrid	varchar2(100);
  outrow	integer;

 begin

  if access_in = 'QUERY'
   then
    display_screen_single( acid, surl, ltype, stype, pfx, crec, c1rec, access_in, null, cntrl_str, current_row, totrows, msg );
    return;
  end if;

  -- Tabular Display for Edit and Row Display not Querying
  obj := get_attribute( c1rec.screen_id, 'HEADING', 'PRIMARY' );
  glbx.main_title( surl, obj.attribute_prebuilt,glbx.backimg(surl,crec.aid,pfx.text_back,crec.background_img,ltype),helpid=>c1rec.help_id,stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
  obj := get_attribute( c1rec.screen_id, 'TITLE', 'PRIMARY' );
  htp.p( '<CENTER>' );
  if obj.attribute_prebuilt is not null
   then
    htp.title( obj.attribute_prebuilt );
  end if;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
  if access_in = 'EDIT'
   then
    htp.tabledata( htf.bold('#'),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
    for c3rec in c3( c1rec.screen_id ) loop
     htp.tabledata( htf.bold(c3rec.display_text),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
    end loop;
   else
    for c2rec in c2( c1rec.screen_id ) loop
     htp.tabledata( htf.bold(c2rec.display_text),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
    end loop;
  end if;
  htp.tablerowclose;

  if access_in = 'EDIT'
   then
    htp.formopen( 'oltp.process_query_tab' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'RND', to_char(sysdate,'SSSSS'));
    htp.formhidden( 'RID', v_rid );
    htp.formhidden( 'ACID', acid );
    htp.formhidden( 'ACCESS_IN', access_in );
    htp.formhidden( 'SCID', c1rec.screen_id );
    htp.formhidden( 'PARM1', null );
    htp.formhidden( 'PARM2', null );
    htp.formhidden( 'PARM3', null );
  end if;

  if access_in = 'EDIT' and not rid.exists(1)
   then
     extract_row( acid, c1rec, null, col_name, col_value, outrow );
     for j in col_name.first..col_name.last loop
      col_value( j ) := NULL;
     end loop;
     prepopulate_values( acid, surl, c1rec, col_name, col_value );
     for j in 1..c1rec.screen_height loop
      display_row_edit( acid, c1rec, null, col_name, col_value, pfx, j,  j );
     end loop;
   else
    for j in rid.first..rid.last loop
      extract_row( acid, c1rec, rid(j), col_name, col_value, outrow );
      if outrow > 0
       then
        if access_in = 'EDIT'
         then
          display_row_edit( acid, c1rec, rid(j), col_name, col_value, pfx, j, (nvl(current_row,1) - 1) + j );
         else
          display_row( c1rec, rid(j), col_name, col_value, pfx, j );
        end if;
      end if;
     end loop;
  end if;
  htp.tableclose;

  obj := get_attribute( c1rec.screen_id, 'CONTROL BAR', 'PRIMARY' );
  htp.nl;
  if rid.exists(1)
   then
    firstrid := rid(rid.first);
    lastrid := rid(rid.last);
   else
    firstrid := NULL;
    lastrid := NULL;
  end if;
  display_controlbar( '&surl=' || glbx.rndsurl(surl) || '&rid=' || replace(lastrid,'+','~') || '&scid=' || c1rec.screen_id || cntrl_str,
                      obj.attribute_prebuilt, 'TTT', access_in, current_row, totrows, '&surl=' || glbx.rndsurl(surl) || '&rid=' || replace(firstrid,'+','~') || '&scid=' || c1rec.screen_id || cntrl_str || '&acid=' || acid, hlp=>c1rec.help_id, acid=>acid );

  if access_in = 'EDIT'
   then
    htp.formclose;
  end if;

  htp.p( '</CENTER>' );
  htp.htmlclose;

 exception when others then
  glbx.error_details( 'OLTP', 'DISPLAY_SCREEN_TABULAR',null,acid,errmsg=>sqlerrm);
 end display_screen_tabular;

 procedure display_title_page( surl in varchar2, ltype in varchar2, c1rec in OLTP_OVERVIEW%ROWTYPE, access_in in varchar2, rid in varchar2 )
 as
 begin
  null;

 exception when others then
  glbx.error_details( 'OLTP', 'DISPLAY_TITLE_PAGE',null,null,errmsg=>sqlerrm);
 end display_title_page;

procedure process_query_tab( surl in varchar2, rnd in varchar2, scid in integer, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, parm3 in GLBX.MYARRAY,
                         access_in in varchar2, rid in varchar2 default null, id in varchar2 default '1',
                         action1 in varchar2 default null, action2 in varchar2 default null, action3 in varchar2 default null, action4 in varchar2 default null, action5 in varchar2 default null, msg in varchar2 default null, sort in varchar2 default null, acid in integer default null )
as

 cursor c1(scid integer) is select * from oltp_overview where screen_id = scid;

 c1rec		c1%ROWTYPE;
 crec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 finish		boolean;
 ctr		integer;
 profid		integer;
 lrid		varchar2(100);
 frid		varchar2(100);
 sts		varchar2(100);
 p1		GLBX.MYARRAY;
 p2		GLBX.MYARRAY;
 p3		GLBX.MYARRAY;
 p4		GLBX.MYARRAY;
 pfx		THEME%ROWTYPE;

begin

 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'OLTP.DISPLAY_SCREEN' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 crec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( crec.theme_name );

  open c1(scid);
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    close c1;
    htp.p( 'Cannot find screen' );
    return;
  end if;
  close c1;

  lrid := NULL;
  ctr := 0;
  p3(1) := NULL;
  p4(1) := NULL;
  for j in parm3.first..parm3.last loop
   if lrid is null
    then
     lrid := parm3(j);
     frid := parm3(j);
   end if;
   if lrid <> parm3(j)
    then
     update_record(surl, scid, replace(lrid,'~','+'), c1rec, p1, p2, p3, p4, TRUE, acid );
     p1.delete;
     p2.delete;
     lrid := parm3(j);
     ctr := 0;
   end if;
   ctr := ctr + 1;
   p1( ctr ) := parm1(j);
   p2( ctr ) := parm2(j);
  end loop;
  update_record(surl, scid, replace(lrid,'~','+'), c1rec, p1, p2, p3, p4, TRUE, acid );

  process_query( surl, null, scid, p1, p2, p3, p4, 'EDIT', frid, 'e', msg=> 'Record(s) Successfully Updated', acid=>acid );

 exception when others then
  glbx.error_details( 'OLTP', 'PROCESS_QUERY_TAB',null,crec.aid,errmsg=>sqlerrm);
end process_query_tab;

procedure process_query( surl in varchar2, rnd in varchar2, scid in integer, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, parm3 in GLBX.MYARRAY, parm4 in GLBX.MYARRAY,
                         access_in in varchar2, rid in varchar2 default null, id in varchar2 default '1',
                         action1 in varchar2 default null, action2 in varchar2 default null, action3 in varchar2 default null, action4 in varchar2 default null, action5 in varchar2 default null, msg in varchar2 default null, sort in varchar2 default null, acid in integer default null )
as

 cursor c1(scid integer) is select * from oltp_overview where screen_id = scid;

 cntrl_str	varchar2(32767);
 sqlstmt	varchar2(32767);
 c1rec		c1%ROWTYPE;
 totrows	integer;
 curr_rowid	GLBX.MYARRAY;
 rowctr		integer;
 crec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 finish		boolean;
 dummy		varchar2(1);
 dummy_arr	GLBX.MYARRAY;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin

 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'OLTP.DISPLAY_SCREEN' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 -- crec := glbx.get_aid( owner_id, 'C', ltype );
 crec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( crec.theme_name );

  open c1(scid);
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    close c1;
    htp.p( 'Cannot find screen' );
    return;
  end if;
  close c1;

  if (c1rec.bypass_edit = 'BEFORE QUERY')
   then
    execute immediate 'begin ' || c1rec.bypass_call || '(surl=>''' || surl || ''',call_name=>''' || c1rec.bypass_call || ''',parm=>''' || c1rec.bypass_parameter || '''); end;';
    return;
  elsif (c1rec.bypass_edit = 'AFTER QUERY') and (access_in in ('EDIT'))
   then
    execute immediate 'begin ' || c1rec.bypass_call || '(surl=>''' || surl || ''',rid=>''' || replace(rid,'+','~') || ''',scid=>''' || c1rec.screen_id || ''',access_id=>''' || id || ''',call_name=>''' || c1rec.bypass_call || ''',parm=>''' || c1rec.bypass_parameter || '''); end;';
    return;
  end if;

  cntrl_str := NULL;
  for j in parm1.first..parm1.last loop
   --htp.p( '1:' || j || ':' || parm1(j) ); htp.nl;
   cntrl_str := cntrl_str || '&parm1=' || translate(parm1(j),' %','+~');
  end loop;
  for j in parm2.first..parm2.last loop
   --htp.p( '2:' || j || ':' || parm2(j) ); htp.nl;
   cntrl_str := cntrl_str || '&parm2=' || translate(parm2(j),' ','+');
  end loop;
  for j in parm3.first..parm3.last loop
   --htp.p( '3:' || j || ':' || parm3(j) ); htp.nl;
   cntrl_str := cntrl_str || '&parm3=' || translate(parm3(j),' ','+');
  end loop;
  for j in parm4.first..parm4.last loop
   --htp.p( '4:' || j || ':' || parm4(j) ); htp.nl;
   cntrl_str := cntrl_str || '&parm4=' || translate(parm4(j),' ','+');
  end loop;
  cntrl_str := cntrl_str || '&sort=' || sort;
  -- Post Entry Business Logic
  if id in ('e')
   then
    business_logic(crec.aid,surl,scid,c1rec,rid,finish);
    if finish then return; end if; -- If business logic calls another program then terminate here
  end if;

  if (id in ('n','1','2','3','4','5','6')) or (id ='d' and action2 is not null)
   then
    sqlstmt := ' from ' || c1rec.primary_table || ' ' || extract_sqlstmt( scid, parm1, parm2, parm3, parm4 );
    --htp.bold( sqlstmt ); htp.nl;
    if c1rec.on_query_totrows = 'T'
     then
      totrows := total_rows( restrict_sqlstmt(crec.aid,'select count(''x'') tot ' || sqlstmt) );
      --htp.bold( 'Tot:' || totrows ); htp.nl;
    end if;

    rowctr := 0;
    curr_rowid := query_rowid( crec.aid, 'select rowid ' || sqlstmt || order_by( c1rec, sort ), id, chartorowid(replace(rid,'~','+')), c1rec.screen_height, rowctr, 'BROWSE' );
    -- htp.bold( 'select rowid ' || sqlstmt || order_by( c1rec, sort ) ); htp.nl;
    -- htp.p( curr_rowid.first || '-' || curr_rowid.last ); htp.nl;
    -- htp.bold( 'RID:' || rowidtochar(curr_rowid(1)) ); htp.nl;

    if not curr_rowid.exists(1) then curr_rowid(1) := NULL; end if;
    if c1rec.screen_type = 'SINGLE'
     then
      if action5 is null
       then
        display_screen_single( crec.aid, surl, ltype, stype, pfx, crec, c1rec, 'BROWSE', curr_rowid(1), cntrl_str, rowctr, totrows, msg=>msg );
       else
        display_screen_single( crec.aid, surl, ltype, stype, pfx, crec, c1rec, 'BROWSET', curr_rowid(1), cntrl_str, rowctr, totrows, msg=>msg );
      end if;
    elsif c1rec.screen_type = 'TABULAR'
     then
      display_screen_tabular( crec.aid, surl, ltype, stype, pfx, crec, c1rec, 'BROWSE', curr_rowid, cntrl_str, rowctr, totrows, id, msg=>msg );
    end if;
  elsif id in ('h')
   then
    display_screen( surl, null, null, 'QUERY', null );
  elsif id in ('e')
   then
    if c1rec.screen_type = 'SINGLE'
     then
      display_screen_single( crec.aid, surl, ltype, stype, pfx, crec, c1rec, 'EDIT', rid, cntrl_str, null, null, msg=>msg );
    elsif c1rec.screen_type = 'TABULAR'
     then
      rowctr := 0;
      sqlstmt := ' from ' || c1rec.primary_table || ' ' || extract_sqlstmt( scid, parm1, parm2, parm3, parm4 );
      curr_rowid := query_rowid( crec.aid, 'select rowid ' || sqlstmt || order_by( c1rec, sort ), 'n', chartorowid(replace(rid,'~','+')), c1rec.screen_height, rowctr, 'TABEDIT' );
      if not curr_rowid.exists(1) then curr_rowid(1) := NULL; end if;
      display_screen_tabular( crec.aid, surl, ltype, stype, pfx, crec, c1rec, 'EDIT', curr_rowid, cntrl_str, null, null, id, msg=>msg );
    end if;
  elsif id in ('b')
   then
    if c1rec.screen_type = 'SINGLE'
     then
      display_screen_single( crec.aid, surl, ltype, stype, pfx, crec, c1rec, 'QUERY', rid, cntrl_str, null, null, msg=>msg );
    elsif c1rec.screen_type = 'TABULAR'
     then
      display_screen_tabular( crec.aid, surl, ltype, stype, pfx, crec, c1rec, 'QUERY', curr_rowid, cntrl_str, null, null, id, msg=>msg );
    end if;
  elsif id in ('7') -- Insert
   then
    if c1rec.screen_type = 'SINGLE'
     then
      display_screen_single( crec.aid, surl, ltype, stype, pfx, crec, c1rec, 'EDIT', rid, cntrl_str, null, null, msg=>msg );
    elsif c1rec.screen_type = 'TABULAR'
     then
      display_screen_tabular( crec.aid, surl, ltype, stype, pfx, crec, c1rec, 'EDIT', curr_rowid, cntrl_str, null, null, id, msg=>msg );
    end if;
  elsif id in ('i') -- Insert
   then
    insert_record( crec.aid, surl, scid, replace(rid,'~','+'), c1rec, parm1, parm2, parm3, parm4 );
  elsif id in ('8') -- Copy
   then
    if c1rec.screen_type = 'SINGLE'
     then
      display_screen_single( crec.aid, surl, ltype, stype, pfx, crec, c1rec, 'COPY', rid, cntrl_str, null, null, msg=>msg );
    elsif c1rec.screen_type = 'TABULAR'
     then
      display_screen_tabular( crec.aid, surl, ltype, stype, pfx, crec, c1rec, 'COPY', curr_rowid, cntrl_str, null, null, id, msg=>msg );
    end if;
  elsif id in ('9') -- Delete
   then
    if c1rec.confirm_delete = 'T'
     then
      delete_record_confirm(surl, scid, replace(rid,'~','+'), c1rec, parm1, parm2, parm3, parm4 );
     else
      delete_record(surl, scid, replace(rid,'~','+'), c1rec, parm1, parm2, parm3, parm4, acid=>acid );
    end if;
  elsif id in ('d') and (action1 is not null)-- Delete Confirmed
   then
      delete_record(surl, scid, replace(rid,'~','+'), c1rec, parm1, parm2, parm3, parm4, acid=>acid );
  elsif id in ('x')
   then
    update_record(surl, scid, replace(rid,'~','+'), c1rec, parm1, parm2, parm3, parm4, acid=>acid );
  elsif id = 'z' -- Edit -> Insert
   then
    if c1rec.screen_type = 'SINGLE'
     then
      display_screen_single( crec.aid, surl, ltype, stype, pfx, crec, c1rec, 'EDIT', dummy, cntrl_str, null, null, msg=>msg );
    elsif c1rec.screen_type = 'TABULAR'
     then
      display_screen_tabular( crec.aid, surl, ltype, stype, pfx, crec, c1rec, 'EDIT', dummy_arr, cntrl_str, null, null, id, msg=>msg );
    end if;
  end if;

 exception when others then
  glbx.error_details( 'OLTP', 'PROCESS_QUERY',null,crec.aid,errmsg=>sqlerrm);
end process_query;

function order_by( c1rec in oltp_overview%ROWTYPE, sort in varchar2 )
 return varchar2
as

 cursor c2(scid integer, oid integer) is select original_column from oltp_object where can_be_resorted_on = 'T' and screen_id = scid and oltp_id = oid;

 c2rec	c2%ROWTYPE;

begin
 if sort is null and c1rec.order_by is null then return( null ); end if;

 if sort is not null
  then
   open c2( c1rec.screen_id, substr(sort,2) );
   fetch c2 into c2rec;
   close c2;
   if substr(sort,1,1) = 'A'
    then
     return( ' order by ' || c2rec.original_column );
    else
     return( ' order by ' || c2rec.original_column || ' desc' );
   end if;
  else
   return( ' order by ' || c1rec.order_by );
 end if;
 exception when others then
  glbx.error_details( 'OLTP', 'ORDER_BY',null,null,errmsg=>sqlerrm);
   return( NULL );
end order_by;

function extract_sqlstmt( scid integer, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, parm3 in GLBX.MYARRAY, parm4 in GLBX.MYARRAY)
 return varchar2
as

 cursor c2(scid integer, oid integer) is select * from oltp_object where screen_id = scid and oltp_id = oid;

 c2rec		c2%ROWTYPE;
 sqlstmt 	varchar2(32767);

begin
  sqlstmt := NULL;
  for j in parm4.first..parm4.last loop
   if parm4(j) is not null
    then
     if parm4(j) = 'Is Null'
      then
       open c2(scid, to_number(parm2(j)) );
       fetch c2 into c2rec;
       close c2;
       sqlstmt := sqlstmt || ' and ' || c2rec.original_column || ' ' || 'Is null';
     else
       open c2(scid, to_number(parm2(j)) );
       fetch c2 into c2rec;
       close c2;
       if c2rec.data_type in ('INTEGER','NUMBER')
        then
         sqlstmt := sqlstmt || ' and ' || c2rec.original_column || ' ' || parm4(j) || ' ' || translate(parm1(j),'~','%');
       elsif c2rec.data_type in ('VARCHAR','LOV','HIDDEN')
        then
         sqlstmt := sqlstmt || ' and ' || c2rec.original_column || ' ' || parm4(j) || ' ''' || translate(parm1(j),'~','%') || '''';
       end if;
     end if;
   end if;
  end loop;
  if sqlstmt is not null
   then
    sqlstmt := 'where ' || substr(sqlstmt,5);
  end if;
  return( sqlstmt );
 exception when others then
  glbx.error_details( 'OLTP', 'EXTRACT_SQLSTMT',null,null,errmsg=>sqlerrm);
  return(null);
end extract_sqlstmt;

function total_rows( sqlstmt in varchar2 )
 return integer
as
   retval		integer;
begin
 retval := NULL;
 execute immediate sqlstmt into retval;
 return( retval);
 exception when others then
  glbx.error_details( 'OLTP', 'TOTAL_ROWS',null,null,errmsg=>sqlerrm);
  return( NULL );
end total_rows;

function query_rowid( acid in integer, sqlstmt in varchar2, cntrl in varchar2, currrowid in rowid, rows_to_ret in integer, ctr in out integer, accmode in varchar2 )
 return GLBX.MYARRAY
as

   prevret		rowid;
   retval		rowid;
   retvalarr		GLBX.MYARRAY;
   cursor_name		integer;
   dummy 		integer;
   rowret		integer;

begin
 retval := NULL;
 rowret := nvl(rows_to_ret,1);
 if rowret = 0 then rowret := 1; end if;
 if cntrl = '1'
  then
   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, restrict_sqlstmt(acid,sqlstmt), dbms_sql.native );
   dbms_sql.define_column_rowid(cursor_name,1,retval);
   dummy := dbms_sql.execute( cursor_name );
   for j in 1..rowret loop
    dummy := dbms_sql.fetch_rows(cursor_name);
    if dummy = 0 then exit; end if;
    dbms_sql.column_value_rowid(cursor_name,1,retval);
    retvalarr(j) := rowidtochar( retval );
   end loop;
   dbms_sql.close_cursor( cursor_name );
   ctr := 1;
   return( retvalarr );

 elsif cntrl = '3'
  then
   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, restrict_sqlstmt(acid,sqlstmt), dbms_sql.native );
   dbms_sql.define_column_rowid(cursor_name,1,retval);
   dummy := dbms_sql.execute( cursor_name );
   loop
    dummy := dbms_sql.fetch_rows(cursor_name);
    if dummy = 0 then dbms_sql.close_cursor( cursor_name ); exit; end if;
    dbms_sql.column_value_rowid(cursor_name,1,retval);
    exit when retval = currrowid;
    prevret := retval;
    ctr := ctr + 1;
   end loop;
   if prevret is not null then retvalarr(1) := rowidtochar( prevret ); end if;
   if prevret <> retval then retvalarr(2) := rowidtochar( retval ); end if;
   for j in 3..rowret loop
    retvalarr(j) := rowidtochar( retval );
    dummy := dbms_sql.fetch_rows(cursor_name);
    if dummy = 0 then exit; end if;
    dbms_sql.column_value_rowid(cursor_name,1,retval);
   end loop;
   dbms_sql.close_cursor( cursor_name );
   return( retvalarr );

 elsif cntrl = 'n' -- Refresh
  then
   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, restrict_sqlstmt(acid,sqlstmt), dbms_sql.native );
   dbms_sql.define_column_rowid(cursor_name,1,retval);
   dummy := dbms_sql.execute( cursor_name );
   loop
    dummy := dbms_sql.fetch_rows(cursor_name);
    if dummy = 0 then dbms_sql.close_cursor( cursor_name ); exit; end if;
    dbms_sql.column_value_rowid(cursor_name,1,retval);
    exit when retval = currrowid;
    ctr := ctr + 1;
   end loop;

   for j in 1..rowret loop
    retvalarr(j) := rowidtochar( retval );
    dummy := dbms_sql.fetch_rows(cursor_name);
    if dummy = 0 then exit; end if;
    dbms_sql.column_value_rowid(cursor_name,1,retval);
   end loop;
   dbms_sql.close_cursor( cursor_name );
   return( retvalarr );

 elsif cntrl = '4'
  then
   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, restrict_sqlstmt(acid,sqlstmt), dbms_sql.native );
   dbms_sql.define_column_rowid(cursor_name,1,retval);
   dummy := dbms_sql.execute( cursor_name );
   loop
    dummy := dbms_sql.fetch_rows(cursor_name);
    if dummy = 0 then dbms_sql.close_cursor( cursor_name ); exit; end if;
    dbms_sql.column_value_rowid(cursor_name,1,retval);
    ctr := ctr + 1;
    exit when retval = currrowid;
   end loop;
   dummy := dbms_sql.fetch_rows(cursor_name);
   if dummy = 0
    then
     null;
     -- dbms_sql.close_cursor( cursor_name );
    else
     dbms_sql.column_value_rowid(cursor_name,1,retval);
     -- dbms_sql.close_cursor( cursor_name );
   end if;
   for j in 1..rowret loop
    retvalarr(j) := rowidtochar( retval );
    dummy := dbms_sql.fetch_rows(cursor_name);
    if dummy = 0 then exit; end if;
    dbms_sql.column_value_rowid(cursor_name,1,retval);
   end loop;
   dbms_sql.close_cursor( cursor_name );
   return( retvalarr );

 elsif cntrl = '5'
  then
   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, restrict_sqlstmt(acid,sqlstmt), dbms_sql.native );
   dbms_sql.define_column_rowid(cursor_name,1,retval);
   dummy := dbms_sql.execute( cursor_name );
   loop
    dummy := dbms_sql.fetch_rows(cursor_name);
    if dummy = 0 then dbms_sql.close_cursor( cursor_name ); exit; end if;
    dbms_sql.column_value_rowid(cursor_name,1,retval);
    ctr := ctr + 1;
    exit when retval = currrowid;
   end loop;
   for j in 1..5 loop
     dummy := dbms_sql.fetch_rows(cursor_name);
     if dummy = 0
      then
       exit;
     end if;
     ctr := ctr + 1;
     dbms_sql.column_value_rowid(cursor_name,1,retval);
   end loop;
   for j in 1..rowret loop
    retvalarr(j) := rowidtochar( retval );
    dummy := dbms_sql.fetch_rows(cursor_name);
    if dummy = 0 then exit; end if;
    dbms_sql.column_value_rowid(cursor_name,1,retval);
   end loop;
   dbms_sql.close_cursor( cursor_name );
   return( retvalarr );

 elsif cntrl = '6'
  then
   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, restrict_sqlstmt(acid,sqlstmt), dbms_sql.native );
   dbms_sql.define_column_rowid(cursor_name,1,retval);
   dummy := dbms_sql.execute( cursor_name );
   loop
     dummy := dbms_sql.fetch_rows(cursor_name);
     if dummy = 0
      then
       dbms_sql.close_cursor( cursor_name );
       retvalarr(1) := rowidtochar( retval );
       return( retvalarr );
     end if;
     ctr := ctr + 1;
     dbms_sql.column_value_rowid(cursor_name,1,retval);
   end loop;
 end if;
 retvalarr(1) := rowidtochar( retval );
 return( retvalarr );
exception
 when others then
  begin dbms_sql.close_cursor( cursor_name ); exception when others then null; end;
  return( retvalarr ); -- Query Returned no rows
end query_rowid;

function is_in( val in varchar2, p1 in GLBX.MYARRAY )
 return boolean
as
begin
 for j in p1.first..p1.last loop
  if p1(j) = val then return( TRUE ); end if;
 end loop;
 return( FALSE );
end is_in;

procedure update_record( surl in varchar2, scid in integer, rid in varchar2, c1rec in oltp_overview%ROWTYPE, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, parm3 in GLBX.MYARRAY, parm4 in GLBX.MYARRAY, bypass in boolean DEFAULT FALSE, acid in integer default null )
as

 cursor c2(scid integer, oid integer) is select * from oltp_object where screen_id = scid and oltp_id = oid;
 cursor c3(scid integer) is select * from oltp_object where object_type = 'COLUMN' and data_type = 'BOOLEAN' and screen_id = scid;

 c2rec		c2%ROWTYPE;
 sqlstmt 	varchar2(32767);

begin
  sqlstmt := NULL;
  for j in parm2.first..parm2.last loop
   if parm2(j) is not null
    then
       open c2(scid, to_number(parm2(j)) );
       fetch c2 into c2rec;
       close c2;
       if c2rec.data_type in ('INTEGER','NUMBER')
        then
         sqlstmt := sqlstmt || ',' || c2rec.original_column || ' = ' || parm1(j);
       elsif c2rec.data_type in ('VARCHAR','LOV')
        then
         sqlstmt := sqlstmt || ',' || c2rec.original_column || ' = ''' || parm1(j) || '''';
       end if;
   end if;
  end loop;
  -- Handle Boolean Values
  for c3rec in c3( scid ) loop
   if not is_in( c3rec.oltp_id, parm3 )
    then
       sqlstmt := sqlstmt || ',' || c3rec.original_column || ' = ''F''';
   end if;
  end loop;
  for j in parm3.first..parm3.last loop
   if parm3(j) is not null
    then
       open c2(scid, to_number(parm3(j)) );
       fetch c2 into c2rec;
       close c2;
       sqlstmt := sqlstmt || ',' || c2rec.original_column || ' = ''T''';
   end if;
  end loop;
  if sqlstmt is not null
   then
    sqlstmt := 'update ' || c1rec.primary_table || ' set ' || substr(sqlstmt,2) || ' where rowid=''' || rid || '''';
  end if;

  -- htp.p( sqlstmt );
  execute immediate sqlstmt;
  commit;

  if bypass
   then
    return;
   else
    process_query( surl, null, scid, parm1, parm2, parm3, parm4, 'EDIT', rid, 'e', msg=> 'Record Successfully Updated', acid=>acid );
  end if;

 exception when others then
  glbx.error_details( 'OLTP', 'UPDATE_RECORD',null,null,errmsg=>sqlerrm);
end update_record;

procedure insert_record( acid in integer, surl in varchar2, scid in integer, rid in varchar2, c1rec in oltp_overview%ROWTYPE, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, parm3 in GLBX.MYARRAY, parm4 in GLBX.MYARRAY )
as

 cursor c2(scid integer, oid integer) is select * from oltp_object where screen_id = scid and oltp_id = oid;
 cursor c3(scid integer) is select * from oltp_object where object_type = 'COLUMN' and data_type = 'BOOLEAN' and screen_id = scid;
 cursor c4(scid integer) is select original_column,generate_pk,data_type from oltp_object where screen_id = scid and is_primary_key = 'T' and display = 'F';

 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 sqlstmt 	varchar2(32767);
 sqlstmt1 	varchar2(32767);
 sqlstmt2 	varchar2(32767);
 newrid		rowid;
 pkvali		integer;
 pkval		varchar2(4000);
 cursor_name	integer;
 dummy		integer;

begin
  sqlstmt1 := NULL; -- Columns
  sqlstmt2 := NULL; -- Values

  -- currently support only one Primary Key Value
  for c4rec in c4(scid) loop
    if c4rec.generate_pk = 'T'
     then
      execute immediate 'select max(' || c4rec.original_column || ') + 1 tot from ' || c1rec.primary_table into pkvali;
      if pkvali is null then pkval := '1'; else pkval := to_char(pkvali); end if;
     else
      null;
      -- Calculate using some sort of MASK structure
      -- Future enhancement
    end if;

    if c4rec.data_type in ('INTEGER','NUMBER')
     then
      sqlstmt1 := sqlstmt1 || ',' || c4rec.original_column;
      sqlstmt2 := sqlstmt2 || ',' || pkval;
    elsif c2rec.data_type in ('VARCHAR','LOV')
     then
      sqlstmt1 := sqlstmt1 || ',' || c4rec.original_column;
      sqlstmt2 := sqlstmt2 || ',''' || pkval || '''';
    end if;
  end loop;

  for j in parm2.first..parm2.last loop
   if parm2(j) is not null
    then
       open c2(scid, to_number(parm2(j)) );
       fetch c2 into c2rec;
       close c2;
       if c2rec.data_type in ('INTEGER','NUMBER')
        then
         sqlstmt1 := sqlstmt1 || ',' || c2rec.original_column;
         sqlstmt2 := sqlstmt2 || ',' || parm1(j);
       elsif c2rec.data_type in ('VARCHAR','LOV')
        then
         sqlstmt1 := sqlstmt1 || ',' || c2rec.original_column;
         sqlstmt2 := sqlstmt2 || ',''' || parm1(j) || '''';
       end if;
   end if;
  end loop;
  -- Handle Boolean Values
  for c3rec in c3( scid ) loop
   if not is_in( c3rec.oltp_id, parm3 )
    then
       sqlstmt1 := sqlstmt1 || ',' || c3rec.original_column;
       sqlstmt2 := sqlstmt2 || ',''F''';
   end if;
  end loop;
  for j in parm3.first..parm3.last loop
   if parm3(j) is not null
    then
       open c2(scid, to_number(parm3(j)) );
       fetch c2 into c2rec;
       close c2;
       sqlstmt1 := sqlstmt1 || ',' || c2rec.original_column;
       sqlstmt2 := sqlstmt2 || ',''T''';
   end if;
  end loop;
  sqlstmt := 'insert into ' || c1rec.primary_table || ' (' || substr(sqlstmt1,2) || ') values (' || substr(sqlstmt2,2) || ') returning rowid into :rid';

  --htp.p( sqlstmt );
  --execute immediate sqlstmt using out newrid;
   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, sqlstmt, dbms_sql.native );
   dbms_sql.bind_variable_rowid(cursor_name, ':rid', newrid);
   dummy := dbms_sql.execute( cursor_name );
   dbms_sql.variable_value_rowid(cursor_name,':rid', newrid );
   dbms_sql.close_cursor(cursor_name);
  commit;
  --htp.bold( 'RID:' || rowidtochar(newrid) ); htp.nl;
  process_query( surl, null, scid, parm1, parm2, parm3, parm4, 'EDIT', rowidtochar(newrid), 'e', msg=> 'Record Successfully Inserted', acid=>acid );

 exception when others then
  glbx.error_details( 'OLTP', 'INSERT_RECORD',null,acid,errmsg=>sqlerrm);
end insert_record;

procedure delete_record( surl in varchar2, scid in integer, rid in varchar2, c1rec in oltp_overview%ROWTYPE, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, parm3 in GLBX.MYARRAY, parm4 in GLBX.MYARRAY, acid in integer default null )
as

begin
  execute immediate 'delete from ' || c1rec.primary_table || ' where rowid = :1' using in rid;
  commit;
  process_query( surl, null, scid, parm1, parm2, parm3, parm4, 'BROWSE', null, '1', msg=> 'Record Deleted', acid=>acid );

 exception when others then
  glbx.error_details( 'OLTP', 'DELETE_RECORD',null,null,errmsg=>sqlerrm);
end delete_record;

procedure delete_record_confirm( surl in varchar2, scid in integer, rid in varchar2, c1rec in oltp_overview%ROWTYPE, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, parm3 in GLBX.MYARRAY, parm4 in GLBX.MYARRAY )
as

begin

  htp.htmlopen;
   glbx.header_msg( 'Confirm Deletion of this Record' );
    htp.formopen( 'oltp.process_query' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'RID', rid );
    htp.formhidden( 'RND', to_char(sysdate,'SSSSS') );
    htp.formhidden( 'ACCESS_IN', 'EDIT' );
    htp.formhidden( 'ID', 'd');
    htp.formhidden( 'SCID', c1rec.screen_id );
    htp.p( '<CENTER>' );
    for j in parm1.first..parm1.last loop
     htp.formhidden( 'PARM1', parm1(j) );
    end loop;
    for j in parm2.first..parm2.last loop
     htp.formhidden( 'PARM2', parm2(j) );
    end loop;
    for j in parm3.first..parm3.last loop
     htp.formhidden( 'PARM3', parm3(j) );
    end loop;
    for j in parm4.first..parm4.last loop
     htp.formhidden( 'PARM4', parm4(j) );
    end loop;
    htp.formsubmit( 'action1', 'Delete Record' );
    htp.formsubmit( 'action2', 'Cancel and Return' );
    htp.formclose;
    htp.p( '</CENTER>' );
    htp.htmlclose;

 exception when others then
  glbx.error_details( 'OLTP', 'DELETE_RECORD_CONFIRM',null,null,errmsg=>sqlerrm);
end delete_record_confirm;

procedure display_report( surl in varchar2, acid in integer, ltype in varchar2, stype in integer, pfx in THEME%ROWTYPE, crec in CUSTOMER_ACCOUNT%ROWTYPE, c1rec in OLTP_OVERVIEW%ROWTYPE, access_in in varchar2, rid in varchar2, cntrl_str in varchar2, current_row in integer default null, totrows in integer default null, msg in varchar2 default null )
as

 cursor c2( rname varchar2 ) is select report_id from report_definition where upper(report_name) = upper(rname);

  c2rec		c2%ROWTYPE;
  obj		oltp_object%ROWTYPE;
  dmy1		GLBX.MYARRAY;
  dmy2		GLBX.MYARRAY;
  dmy3		GLBX.MYARRAY;

begin
 open c2( c1rec.menu_call );
 fetch c2 into c2rec;
 if c2%NOTFOUND
  then
   close c2;
   obj := get_attribute( c1rec.screen_id, 'HEADING', 'PRIMARY' );
   obj.attribute_prebuilt := nvl(obj.attribute_prebuilt,c1rec.screen_name);
   glbx.main_title( surl, 'Report Not Found',glbx.backimg(surl,crec.aid,pfx.text_back,crec.background_img,ltype),helpid=>c1rec.help_id,stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
   htp.htmlclose;
   return;
 end if;
 close c2;

 run_report( surl, c2rec.report_id,0,dmy1,dmy2,dmy3 );

 exception when others then
  glbx.error_details( 'OLTP', 'DISPLAY_REPORT',null,acid,errmsg=>sqlerrm);
end display_report;

procedure display_procedure( surl in varchar2, acid in integer, ltype in varchar2, stype in integer, pfx in THEME%ROWTYPE, crec in CUSTOMER_ACCOUNT%ROWTYPE, c1rec in OLTP_OVERVIEW%ROWTYPE, access_in in varchar2, rid in varchar2, cntrl_str in varchar2, current_row in integer default null, totrows in integer default null, msg in varchar2 default null )
as

  cursor c2( scid integer ) is select * from oltp_object where screen_id = scid and object_type = 'COLUMN' order by screen_order;

  obj		oltp_object%ROWTYPE;

begin
  obj := get_attribute( c1rec.screen_id, 'HEADING', 'PRIMARY' );
  obj.attribute_prebuilt := nvl(obj.attribute_prebuilt,c1rec.screen_name);
  glbx.main_title( surl, obj.attribute_prebuilt,glbx.backimg(surl,crec.aid,pfx.text_back,crec.background_img,ltype),helpid=>c1rec.help_id,stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
  htp.p( '<CENTER>' );
  htp.formopen( 'oltp.accept_procedure' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'SCID', c1rec.screen_id );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.formhidden( 'P0', null );
  htp.formhidden( 'P1', null );
  for c2rec in c2( c1rec.screen_id ) loop
   htp.tablerowopen;
    htp.formhidden( 'P0', c2rec.oltp_id );
    if c2rec.mandatory = 'T'
     then
      htp.tabledata( htf.bold( c2rec.display_text ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' ); -- XXX Set to the right value later
     else
      htp.tabledata(  c2rec.display_text, cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' ); -- XXX Set to the right value later
    end if;
    if c2rec.data_type = 'LOV'
     then
         htp.p( '<TD ' || GLBX.QUERY_BACKGROUND || ' align="CENTER"' || '>' );
         htp.formselectopen( 'PARM1' );
         if c2rec.mandatory = 'F'
          then
           htp.formselectoption( NULL );
         end if;
         if c2rec.lov_select is null
          then
           lov_list( c2rec.lov_list, c2rec.default_value );
          else
           lov_select( acid, c2rec.lov_select, c2rec.default_value );
         end if;
         htp.formselectclose;
         htp.p( '</TD>' );
     else
      htp.tabledata( htf.formtext( 'P1', c2rec.display_length, c2rec.data_length, c2rec.default_value ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    end if;
   htp.tablerowclose;
  end loop;
  htp.tablerowopen;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, 'Execute' );
  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;

 exception when others then
  glbx.error_details( 'OLTP', 'DISPLAY_PROCEDURE',null,acid,errmsg=>sqlerrm);
end display_procedure;

procedure accept_procedure( surl in varchar2, scid in integer, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY )
as

 cursor c1(scid integer) is select * from oltp_overview where screen_id = scid;
 cursor c2(oid integer) is select * from oltp_object where oltp_id = oid;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 crec		customer_account%ROWTYPE;
 obj		oltp_object%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 call_str	varchar2(32767);
 result_call	varchar2(2000);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'OLTP.ACCEPT_PROCEDURE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 crec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( crec.theme_name );

  open c1(scid);
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    close c1;
    htp.p( 'Cannot find screen' );
    return;
  end if;
  close c1;

  for j in p0.first..p0.last loop
   if p0(j) is not null
    then
     open c2( p0(j) );
     fetch c2 into c2rec;
     if c2%FOUND
      then
       close c2;
       if c2rec.data_type = 'NUMBER'
        then
         call_str := call_str || ',' || c2rec.original_column || '=>' || p1(j);
        else
         call_str := call_str || ',' || c2rec.original_column || '=>' || '''' || replace(p1(j),'''','''''') || '''';
       end if;
      else
       close c2;
     end if;
   end if;
  end loop;

  if call_str is null
   then
    call_str := 'begin ' || c1rec.primary_table || '; end;';
   else
    call_str := 'begin ' || c1rec.primary_table || '(' || substr(call_str,2) || '); end;';
  end if;

  begin
   execute immediate call_str;
  exception
   when others then result_call := sqlerrm;
  end;

  obj := get_attribute( c1rec.screen_id, 'HEADING', 'PRIMARY' );
  obj.attribute_prebuilt := nvl(obj.attribute_prebuilt,c1rec.screen_name);
  glbx.main_title( surl, obj.attribute_prebuilt,glbx.backimg(surl,crec.aid,pfx.text_back,crec.background_img,ltype),helpid=>c1rec.help_id,stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
  htp.p( '<CENTER>' );
  glbx.header_msg( nvl(result_call,'Procedure was successfully run') );
  htp.p( '</CENTER>' );
  htp.htmlclose;

 exception when others then
  glbx.error_details( 'OLTP', 'ACCEPT_PROCEDURE',null,owner_id,errmsg=>sqlerrm);
end accept_procedure;

procedure display_menu( surl in varchar2, acid in integer, ltype in varchar2, stype in integer, pfx in THEME%ROWTYPE, crec in CUSTOMER_ACCOUNT%ROWTYPE, c1rec in OLTP_OVERVIEW%ROWTYPE, access_in in varchar2, rid in varchar2, cntrl_str in varchar2, current_row in integer default null, totrows in integer default null, msg in varchar2 default null )
as

  cursor cmenu( mn_name varchar2, acid integer ) is
   select *
   from oltp_overview oo
   where ((menu_name = mn_name and menu_name is not null) or (menu_name is null and mn_name is null)) and
         menu_display='T' and
         screen_type <> 'MENU' and
         (security_role is null or
          exists (select 'x' from customer_roles cr, piction_roles pr where cr.role_id = pr.role_id and pr.role_type = 'SCREEN' and pr.role_name = oo.security_role and cr.aid = acid)
         )
   order by menu_orderby;

  cursor c_sub_menu( mn_name varchar2, acid integer ) is
   select *
   from oltp_overview oo
   where ((menu_name = mn_name and menu_name is not null) or (menu_name is null and mn_name is null)) and
         menu_display='T' and
         menu_call is not null and
         screen_type = 'MENU' and
         (security_role is null or
          exists (select 'x' from customer_roles cr, piction_roles pr where cr.role_id = pr.role_id and pr.role_type = 'SCREEN' and pr.role_name = oo.security_role and cr.aid = acid)
         )
   order by menu_orderby;

  cursor c2( mn_name varchar2 ) is
   select menu_name, screen_name
   from oltp_overview
   where menu_display = 'T' and
         screen_type = 'MENU' and
         menu_call = mn_name;

  obj		oltp_object%ROWTYPE;
  obj1		oltp_object%ROWTYPE;
  obj2		oltp_object%ROWTYPE;
  obj3		oltp_object%ROWTYPE;
  obj4		oltp_object%ROWTYPE;
  c2rec		c2%ROWTYPE;

begin
  obj := get_attribute( c1rec.screen_id, 'HEADING', 'PRIMARY' );
  obj.attribute_prebuilt := nvl(obj.attribute_prebuilt,c1rec.screen_name);
  glbx.main_title( surl, obj.attribute_prebuilt,glbx.backimg(surl,crec.aid,pfx.text_back,crec.background_img,ltype),helpid=>c1rec.help_id,stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
  htp.p( '<CENTER>' );
  if obj.attribute_prebuilt is not null
   then
    htp.title( obj.attribute_prebuilt );
  end if;
  if msg is not null then glbx.header_msg( msg ); end if;

  obj1 := get_attribute( c1rec.screen_id, 'SCREEN ALIGNMENT', 'PRIMARY' );
  obj1.attribute_prebuilt := nvl(obj1.attribute_prebuilt,'LEFT');
  obj2 := get_attribute( c1rec.screen_id, 'CELL COLOUR', 'PRIMARY' );
  obj2.attribute_prebuilt := nvl(obj2.attribute_prebuilt,pfx.text_back);
  obj3 := get_attribute( c1rec.screen_id, 'CELL WIDTH', 'PRIMARY' );
  obj3.attribute_prebuilt := nvl(obj3.attribute_prebuilt,'"30%"');
  obj4 := get_attribute( c1rec.screen_id, 'BORDER', 'PRIMARY' );
  obj4.attribute_prebuilt := nvl(obj4.attribute_prebuilt,'"2"');
  htp.tableopen( cattributes=>'width=' || obj3.attribute_prebuilt || ' cellpadding=0 cellspacing=0 border=' || obj4.attribute_prebuilt );
  htp.tablerowopen;
  htp.p( '<TD align="' || nvl(obj1.attribute_prebuilt,'LEFT') || '" bgcolor="#' || obj2.attribute_prebuilt || '">' );
  for cmenu_rec in cmenu( c1rec.menu_name, acid ) loop
   htp.anchor( 'oltp.display_screen?surl=' || glbx.rndsurl(surl) || '&sname=' || replace(cmenu_rec.screen_name,' ','+') || '&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=QUERY&rid=', cmenu_rec.screen_name);
   htp.nl;
  end loop;
  htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tablerowopen;
  htp.p( '<TD align="' || nvl(obj1.attribute_prebuilt,'LEFT') || '" bgcolor="#' || obj2.attribute_prebuilt || '">' );
  for csubmenu_rec in c_sub_menu( c1rec.menu_name, acid ) loop
    if (csubmenu_rec.menu_call <> c1rec.menu_name) or (c1rec.menu_name is null)
     then
      htp.anchor( 'oltp.display_screen?surl=' || glbx.rndsurl(surl) || '&sname=' || replace(csubmenu_rec.menu_call,' ','+') || '&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=&rid=', csubmenu_rec.menu_call);
      htp.nl;
    end if;
  end loop;

  if c1rec.menu_name is not null
   then
    open c2( c1rec.menu_name );
    fetch c2 into c2rec;
    close c2;
    htp.anchor( 'oltp.display_screen?surl=' || glbx.rndsurl(surl) || '&sname=' || replace(c2rec.menu_name,' ','+') || '&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=&rid=', c2rec.screen_name);
    htp.nl;
  end if;
  htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tableclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
 exception when others then
  glbx.error_details( 'OLTP', 'DISPLAY_MENU',null,acid,errmsg=>sqlerrm);
 end display_menu;

procedure disp_group_columns( acid in integer, surl in varchar2, c1rec in oltp_overview%ROWTYPE, new_table in BOOLEAN )
as

   cursor c2(scid integer, cname varchar2) is select oltp_id from oltp_object where screen_id = scid and original_column = cname;

   c2rec		c2%ROWTYPE;
   sqlstmt		varchar2(32767);
   cursor_name		integer;
   col_count		integer;
   desc_t		dbms_sql.desc_tab;
   common_nmb		number;
   dummy		integer;
   common_vc2		varchar2(4000);
   common_dte		date;
   tmpval		varchar2(4000);
   tmpval2		varchar2(4000);

begin

   open c2(c1rec.screen_id,c1rec.group_column);
   fetch c2 into c2rec;
   close c2;

   if new_table
    then
     htp.tableopen(cattributes=>'cellpadding=0 cellspacing=0 border=0');
     htp.tablerowopen;
   end if;

   if c1rec.group_column is null then return; end if;

   sqlstmt := 'select ' || c1rec.group_column || ',count(''x'') tot from ' || c1rec.primary_table || ' group by ' || c1rec.group_column;
   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, restrict_sqlstmt(acid,sqlstmt), dbms_sql.native );
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

   loop
    dummy := dbms_sql.fetch_rows( cursor_name );
    if dummy > 0
     then
     tmpval := NULL;
     tmpval2 := NULL;
     for j in 1..col_count loop
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
         if j = 2 then tmpval2 := to_char( common_nmb ); else tmpval := to_char( common_nmb ); end if;
       elsif desc_t(j).col_type = 12
        then
         dbms_sql.column_value(cursor_name,j,common_dte);
         tmpval := to_char( common_dte,LNG.TSMASK );
      end if;
     end loop;
     if c2rec.oltp_id is null
      then
         htp.tabledata('[' || tmpval || '-' || tmpval2 || ']');
      else
       if c1rec.display_group_col_ctr = 'T'
        then
         htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid || '&surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS') || '&scid=' || c1rec.screen_id || '&access_in=BROWSE&parm4==&parm3=&parm2=' || c2rec.oltp_id || '&parm1=' || translate(tmpval,' ','+') ,'[' || tmpval || '-' || tmpval2 || ']') );
        else
         htp.tabledata( htf.anchor( 'oltp.process_query?acid=' || acid || '&surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS') || '&scid=' || c1rec.screen_id || '&access_in=BROWSE&parm4==&parm3=&parm2=' || c2rec.oltp_id || '&parm1=' || translate(tmpval,' ','+') ,'[' || tmpval || ']') );
       end if;
     end if;
   else
    dbms_sql.close_cursor( cursor_name );
    exit;
   end if;
   end loop;

   if new_table
    then
     htp.tablerowclose;
     htp.tableclose;
   end if;

 exception when others then
  glbx.error_details( 'OLTP', 'DISP_GROUP_COLUMNS',null,acid,errmsg=>sqlerrm);
end disp_group_columns;

function aug(vname in varchar2, p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null, p5 in varchar2 default null, p6 in varchar2 default null, p7 in varchar2 default null, p8 in varchar2 default null, p9 in varchar2 default null )
 return varchar2
as

 cursor c1(vname varchar2) is select * from advanced_unique_generator where name = vname order by order_by;

 TYPE DCurTyp IS REF CURSOR;  -- define weak REF CURSOR type

 tmp	varchar2(4000);
 tmp2	varchar2(4000);
 dcurs  DCurTyp;

begin
 tmp := NULL;
 for c1rec in c1(upper(vname)) loop
  tmp2 := NULL;

  if c1rec.aug_type = 'UNIQUE NUMBER'
   then
    execute immediate 'select ' || c1rec.mask_stmt || '.nextval from dual' into tmp2;
  elsif c1rec.aug_type = 'UNIQUE NUMBER YEARLY REFRESH'
   then
    null;
  elsif c1rec.aug_type = 'DATE MASK'
   then
    tmp2 := to_char(sysdate,c1rec.mask_stmt);
  elsif c1rec.aug_type = 'FIXED CHARACTER'
   then
    tmp2 := c1rec.mask_stmt;
  elsif c1rec.aug_type = 'PARAMETER'
   then
    if c1rec.mask_stmt = '1' then tmp2 := p1;
    elsif c1rec.mask_stmt = '2' then tmp2 := p2;
    elsif c1rec.mask_stmt = '3' then tmp2 := p3;
    elsif c1rec.mask_stmt = '4' then tmp2 := p4;
    elsif c1rec.mask_stmt = '5' then tmp2 := p5;
    elsif c1rec.mask_stmt = '6' then tmp2 := p6;
    elsif c1rec.mask_stmt = '7' then tmp2 := p7;
    elsif c1rec.mask_stmt = '8' then tmp2 := p8;
    elsif c1rec.mask_stmt = '9' then tmp2 := p9;
    end if;
  elsif c1rec.aug_type = 'SQL STATEMENT'
   then
    begin
     execute immediate c1rec.mask_stmt into tmp2;
    exception
     when others then tmp2 := NULL;
    end;
  end if;

  if nvl(c1rec.padded_out_length,0) > 0
   then
    tmp2 := lpad(tmp2,c1rec.padded_out_length, nvl(c1rec.padded_out_character,' '));
  end if;
  tmp := tmp || tmp2;
 end loop;
 return( tmp );
exception
 when others
  then return( NULL );
end aug;

procedure business_logic( acid in integer, surl in varchar2, scid in integer, c1rec in OLTP_OVERVIEW%ROWTYPE, rid in varchar2, finish out boolean)
as

 cursor c2(scid integer) is select * from oltp_business_rule where screen_id = scid order by order_by;

  col_name	GLBX.MYARRAY;
  col_value	GLBX.MYARRAY;
  outrow	integer;
  action	varchar2(100);

begin
 finish := FALSE;
 extract_row( acid, c1rec, rid, col_name, col_value, outrow );
 if outrow = 0
  then
   htp.p( 'Error: Row does not exist' ); htp.nl;
   finish := TRUE;
   return;
 end if;
 for c2rec in c2(scid) loop

  -- Rules are ON SAVE, ON ERROR, VALIDATE FIELD, CHECK EDIT
  if c2rec.rule_fires_on = 'ON SAVE'
   then
    action := NULL;
    business_rule( c2rec, col_name, col_value, action );
    if action is not null
     then
      if action = 'CALL SCREEN'
       then
        display_screen( surl, to_char(sysdate,'SSSSS'), c2rec.if_action_call, c2rec.if_action_call_parm, null );
      -- elsif action = 'CALL REPORT' 'CALL OLTP' 'CALL PICTION' ' CALL WEB PAGE'
      end if;
      finish := TRUE;
      return;
    end if;
  end if;
 end loop;

 exception when others then
  glbx.error_details( 'OLTP', 'BUSINESS_LOGIC',null,acid,errmsg=>sqlerrm);
end business_logic;

procedure business_rule( c2rec in OLTP_BUSINESS_RULE%ROWTYPE, col_name in GLBX.MYARRAY, col_value in GLBX.MYARRAY, action out varchar2 )
as

 ind	integer;
 fnd	boolean;
 fnd1	boolean;
 vals	GLBX.MYARRAY;


begin

 ind := 0;
 action := NULL;
 for j in col_name.first..col_name.last loop
  if col_name(j) = c2rec.if_column
   then
    ind := j;
    exit;
  end if;
 end loop;
 if ind = 0 then return; end if;

 if c2rec.if_value_type = 'CONSTANT'
  then
   vals(1) := c2rec.if_value;
 elsif c2rec.if_value_type = 'LIST'
  then
   vals := lov_list_array(c2rec.if_value);
 elsif c2rec.if_value_type = 'SQL STATEMENT'
  then
   vals := lov_sqlstmt(c2rec.if_value);
 end if;

 fnd := FALSE;
 if c2rec.if_expression = '='
  then
   for j in vals.first..vals.last loop
    if col_value(j) =  vals(j)
     then
      fnd := TRUE;
      exit;
    end if;
   end loop;
 elsif c2rec.if_expression = '<'
  then
   for j in vals.first..vals.last loop
    if col_value(j) < vals(j)
     then
      fnd := TRUE;
      exit;
    end if;
   end loop;
 elsif c2rec.if_expression = '>'
  then
   for j in vals.first..vals.last loop
    if col_value(j) > vals(j)
     then
      fnd := TRUE;
      exit;
    end if;
   end loop;
 elsif c2rec.if_expression = '<='
  then
   for j in vals.first..vals.last loop
    if col_value(j) <= vals(j)
     then
      fnd := TRUE;
      exit;
    end if;
   end loop;
 elsif c2rec.if_expression = '>='
  then
   for j in vals.first..vals.last loop
    if col_value(j) >= vals(j)
     then
      fnd := TRUE;
      exit;
    end if;
   end loop;
 elsif c2rec.if_expression = '<>'
  then
   for j in vals.first..vals.last loop
    if col_value(j) <> vals(j)
     then
      fnd := TRUE;
      exit;
    end if;
   end loop;
 elsif c2rec.if_expression in ('like','LIKE')
  then
   for j in vals.first..vals.last loop
    if col_value(j) like vals(j)
     then
      fnd := TRUE;
      exit;
    end if;
   end loop;
 elsif c2rec.if_expression in ('in','IN')
  then
   for j in vals.first..vals.last loop
    if col_value(j) = vals(j)
     then
      fnd := TRUE;
      exit;
    end if;
   end loop;
 elsif c2rec.if_expression in ('not in','NOT IN')
  then
   fnd1 := TRUE;
   for j in vals.first..vals.last loop
    if col_value(j) = vals(j)
     then
      fnd1 := FALSE;
      exit;
    end if;
   end loop;
   fnd := fnd1;
 end if;

 if fnd
  then
   action := c2rec.if_action;
 end if;


 exception when others then
  glbx.error_details( 'OLTP', 'BUSINESS_RULE',null,null,errmsg=>sqlerrm);
end business_rule;

function is_report_stopped( repid in integer ) return boolean
as

 cursor c1(repid integer) is select status from report_queue where report_id = repid;

 c1rec  c1%ROWTYPE;

begin
 open c1(repid);
 fetch c1 into c1rec;
 close c1;
 if c1rec.status = 'STOPPED'
  then
   return( TRUE );
  else
   return( FALSE );
 end if;
exception
 when others then return( FALSE );
end is_report_stopped;

procedure populate_other_parameters( rq_id integer, repid in integer, ltype in varchar2, owner_id in integer )
as

 cursor c6(ltype varchar2, acid integer) is
  select username, contact_mobile, contact_email, theme_name lf
  from customer_contact cc, customer_account ca
  where ltype = 'OWNER' and ca.aid = acid and
         ca.aid = cc.aid
 union all
  select username, contact_mobile, contact_email, theme_name lf
  from customer_contact cc, customer_profile cp
  where ltype = 'PROFILE' and profile_id = acid and
        profile_id = cc.aid
 union all
  select username, contact contact_mobile, contact_email, theme_name lf
  from manufacturer
  where ltype = 'MANUFACTURER' and manufacturer_id = acid
 union all
  select username, mobile_phone contact_mobile, contact_email, default_lf lf
  from photographer
  where ltype = 'PHOTOGRAPHER' and pid = acid;

 c6rec c6%ROWTYPE;

begin

 open c6(ltype, owner_id);
 fetch c6 into c6rec;
 close c6;

 insert into report_queue_parameters(report_queue_id,report_id,parameter_name,parameter_type,parameter_value) values (rq_id,repid,'LOGIN.OWNER_ID','CONSTANT',to_char(owner_id));
 insert into report_queue_parameters(report_queue_id,report_id,parameter_name,parameter_type,parameter_value) values (rq_id,repid,'LOGIN.USERNAME','CONSTANT',c6rec.username);
 insert into report_queue_parameters(report_queue_id,report_id,parameter_name,parameter_type,parameter_value) values (rq_id,repid,'LOGIN.LOOK_AND_FEEL','CONSTANT',c6rec.lf);
 insert into report_queue_parameters(report_queue_id,report_id,parameter_name,parameter_type,parameter_value) values (rq_id,repid,'LOGIN.LOGIN_TYPE','CONSTANT',ltype);
 insert into report_queue_parameters(report_queue_id,report_id,parameter_name,parameter_type,parameter_value) values (rq_id,repid,'LOGIN.SURL','CONSTANT',GBL_SURL);

 commit;

end populate_other_parameters;

procedure populate_other_parameters_p( ltype in varchar2, owner_id in integer, p0 in out nocopy GLBX.MYARRAY, p1 in out nocopy GLBX.MYARRAY, ptype in out nocopy GLBX.MYARRAY )
as

 cursor c6(ltype varchar2, acid integer) is
  select username, contact_mobile, contact_email, theme_name lf
  from customer_contact cc, customer_account ca
  where ltype = 'OWNER' and ca.aid = acid and
         ca.aid = cc.aid
 union all
  select username, contact_mobile, contact_email, theme_name lf
  from customer_contact cc, customer_profile cp
  where ltype = 'PROFILE' and profile_id = acid and
        profile_id = cc.aid
 union all
  select username, contact contact_mobile, contact_email, theme_name lf
  from manufacturer
  where ltype = 'MANUFACTURER' and manufacturer_id = acid
 union all
  select username, mobile_phone contact_mobile, contact_email, default_lf lf
  from photographer
  where ltype = 'PHOTOGRAPHER' and pid = acid;

 cursor c7(phgid integer) is select theme_data from theme_types where theme_type = (select theme_type from photographer where pid = phgid);

 c6rec c6%ROWTYPE;
 c7rec c7%ROWTYPE;

begin

 open c6(ltype, owner_id);
 fetch c6 into c6rec;
 close c6;

 open c7(owner_id);
 fetch c7 into c7rec;
 close c7;

 p0(1) := 'LOGIN.OWNER_ID';
 ptype(1) := 'NO DISPLAY';
 p1(1) := to_char(owner_id);

 p0(2) := 'LOGIN.USERNAME';
 ptype(2) := 'NO DISPLAY';
 p1(2) := c6rec.username;

 p0(3) := 'LOGIN.LOOK_AND_FEEL';
 ptype(3) := 'NO DISPLAY';
 p1(3) := c6rec.lf;

 p0(4) := 'LOGIN.LOGIN_TYPE';
 ptype(4) := 'NO DISPLAY';
 p1(4) := ltype;

 p0(5) := 'LOGIN.SURL';
 ptype(5) := 'NO DISPLAY';
 p1(5) := GBL_SURL;

 p0(6) := 'LOGIN.BFTR172';
 ptype(6) := 'NO DISPLAY';
 p1(6) := substr(c7rec.theme_data,172,1);

 p0(7) := 'LOGIN.BFTR173';
 ptype(7) := 'NO DISPLAY';
 p1(7) := substr(c7rec.theme_data,173,1);

end populate_other_parameters_p;

procedure run_the_report( repid in integer, ltype in varchar2, owner_id in integer )
as

 cursor c1(repid integer) is select * from report_queue where report_queue_id = repid;
 cursor c2(rq_id integer, repid integer) is
  select *
  from report_queue_parameters
  where report_queue_id = rq_id and report_id = repid
  order by parameter_name;
 cursor c3(repdefn integer) is select * from report_definition where report_id = repdefn;
 cursor c4(v_umo integer) is select umo_id,doc_html,document_original_loc from umo where umo_id = v_umo for update;
 cursor c5(usc integer) is select title from umo_scene where umo_scene_id = usc;
 cursor c6(ltype varchar2, acid integer) is
  select contact_mobile,billing_email,contact_email
  from customer_contact
  where (ltype = 'OWNER' and aid = acid) or
        (ltype = 'PROFILE' and aid = acid)
 union all
  select contact contact_mobile, contact_email billing_email,contact_email
  from manufacturer
  where ltype = 'MANUFACTURER' and manufacturer_id = acid
 union all
  select mobile_phone contact_mobile, contact_email billing_email,contact_email
  from photographer
  where ltype = 'PHOTOGRAPHER' and pid = acid;
 cursor c7(repid integer) is select associated_id from report_queue_also_run where report_queue_id = repid;
 cursor c8(rq_id integer, repid integer) is
  select rqp.parameter_value
  from report_queue_parameters rqp, report_parameters rp
  where rqp.report_queue_id = rq_id and
        rqp.report_id = rp.report_id and
        rqp.report_id = repid and
        display_header = 'T' and
        rqp.parameter_name = rp.parameter_name
  order by rp.order_by;
 cursor c9(rq_id integer, repid integer) is
  select rqp.parameter_value  ||' '||nvl(Lead(rqp.parameter_value) OVER (ORDER BY rp.order_by),'') as parameter_value 
  from report_queue_parameters rqp, report_parameters rp
  where rqp.report_queue_id = rq_id and
        rqp.report_id = rp.report_id and
        rqp.report_id = repid and
        rqp.parameter_name = rp.parameter_name
  order by rp.order_by;
 cursor c11(v_fun varchar2) is select 'x' from user_objects where object_type = 'PROCEDURE' and upper(object_name) = v_fun;

 fl		UTL_FILE.FILE_TYPE;
 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c11rec		c11%ROWTYPE;
 parm1		GLBX.MYARRAY;
 parm2		GLBX.MYARRAY;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;
 ctr		integer;
 newid		integer;
 newrep		integer;
 v_count	integer;
 v_int		integer;
 x		integer;
 ttl		varchar2(100);
 oloc		varchar2(1000);
 vfdir		varchar2(1000);
 vfname		varchar2(1000);
 bufr		varchar2(32767);

begin
 -- Populate the global variable containing the report
 identify_user(owner_id);

 if GBL_PARENT is null then GBL_PARENT := repid; end if;

 -- Extract Report Location
 open c1(repid);
 fetch c1 into c1rec;
 close c1;

 open c3(c1rec.report_id);
 fetch c3 into c3rec;
 close c3;

 parm1(1) := NULL;
 parm2(1) := NULL;
 ctr := 1;

 select s_umo.nextval into newid from dual;
 update report_queue set run_time = sysdate, status = LNG2.PFM_TXT_141 where report_queue_id = repid;
 insert into report_queue_log(report_queue_id,report_id,activity_type,activity_date,activity_result) values
  (repid,c1rec.report_id,'START',sysdate,to_char(newid));
 commit;

 vfdir := glbx.extract_fname(c3rec.physical_location,'PWD');
 if substr(vfdir,length(vfdir),1) in ('/','\')
  then
   vfdir := substr(vfdir,1,length(vfdir)-1);
 end if;
 vfname := glbx.extract_fname(c3rec.physical_location,'FILENAME');

 -- Add a variety of customer specific parameters, based on logon type to the report
 populate_other_parameters( repid, c1rec.report_id, ltype, owner_id );

 for c2rec in c2(repid, c1rec.report_id) loop
  ctr := ctr + 1;
  parm1( ctr ) := c2rec.parameter_name;
  parm2( ctr ) := c2rec.parameter_value;
 end loop;

 open c8(repid, c1rec.report_id);
 fetch c8 into c8rec;
 if c8%NOTFOUND
  then
   open c9(repid, c1rec.report_id);
   fetch c9 into c8rec;
   if c9%NOTFOUND
    then
      begin c8rec.parameter_value := parm2( parm2.last ); exception when others then null; end;
   end if;
   close c9;
 end if;
 close c8;

 -- Create new clob
 dbms_lob.createtemporary(Gout_clob, FALSE);
 report_file(acid=>owner_id,fdir=>vfdir,fname=>vfname,parm1=>parm1,parm2=>parm2,repid=>repid);
 if GBufr is not null
  then
   dbms_lob.writeappend(Gout_clob,length(GBufr),GBufr);
 end if;

 if dbms_lob.getlength( Gout_clob ) = 0
  then
   update report_queue set status = LNG3.ADM_TXT_521 where report_queue_id = repid;
   commit;
   return;
 end if;

 open c5(c3rec.umo_scene_id);
 fetch c5 into ttl;
 close c5;
 if glbx.extract_master_parameter('REPORTS_DATABASE') = 'TRUE'
  then
   insert into umo(umo_id,aid,umo_type,umo_owner,umo_scene_id,version,
                   extras,
                   doc_html,date_created,expire_date,report_id,document_original_loc)
    values
      (newid,c1rec.aid,'REPORT','OWNER',c3rec.umo_scene_id,1,
       repeated_fields(null,null,null,ttl,null,substr(c3rec.report_name || ' : ' || c8rec.parameter_value,1,100),null,nvl(DEFSECURITY,'FALSE'),'FALSE'),
       empty_clob(),sysdate,sysdate+c1rec.autoexpire,c1rec.report_id,c3rec.physical_location);
  else
   oloc := glbx.extract_master_parameter('MAIL_OUTPUT_DIR');
   insert into umo(umo_id,aid,umo_type,umo_owner,umo_scene_id,version,
                   extras,
                   doc_html,date_created,expire_date,report_id,document_original_loc)
    values
      (newid,c1rec.aid,'REPORT','OWNER',c3rec.umo_scene_id,1,
       repeated_fields(null,null,null,ttl,null,substr(c3rec.report_name || ' : ' || c8rec.parameter_value,1,100),null,nvl(DEFSECURITY,'FALSE'),'FALSE'),
       empty_clob(),sysdate,sysdate+c1rec.autoexpire,c1rec.report_id,oloc);
 end if;
 commit;
 open c4( newid );
 fetch c4 into c4rec;
 close c4;

 if glbx.extract_master_parameter('REPORTS_DATABASE') = 'TRUE'
  then
   dbms_lob.copy(c4rec.doc_html,Gout_clob,dbms_lob.getlength( Gout_clob ));
   update umo set doc_html = c4rec.doc_html where umo_id = newid;
  else
   -- Write to File
    fl := utl_file.fopen( c4rec.document_original_loc, 'report_' || c4rec.umo_id || '.html', 'w', max_linesize=>32767 );
    v_count := 0;
    v_int := 10000; --255
    LBufr := NULL;
    begin
     loop
      dbms_lob.read(Gout_clob,v_int,(v_count*10000)+1,bufr);
      --insert into temp values ('FF:' || length(bufr));
      v_count := v_count + 1;
      LBufr := lBufr || bufr;
      x := instr(lBufr,' ',-1);
      if x = 0
       then
        bufr := LBufr;
        LBufr := NULL;
       else
        bufr := substr(LBufr,1,x-1);
        LBufr := substr(LBufr,x);
      end if;
      utl_file.put_line( fl, buffer=>bufr );
     end loop;
    exception
     when no_data_found then null;
    end;
    if LBufr is not null then utl_file.put_line( fl, buffer=>Lbufr ); LBufr := NULL; end if;
    utl_file.fclose(fl);
    update umo um set um.extras.orderby_nmb = dbms_lob.getlength(Gout_clob) where umo_id = c4rec.umo_id;
    --zip( c4rec.document_original_loc || DECS.UNIX_OR_NT || ziprepname( c3rec.report_name, to_char(sysdate,'SSSSS')) || '.zip',
    --     c4rec.document_original_loc || DECS.UNIX_OR_NT || 'report_' || c4rec.umo_id || '.html' );
    --glbx.dbg( 'Add:' || ziprepname( c3rec.report_name, c8rec.parameter_value || '_' || to_char(sysdate,'hh24_mi')) || '.zip' );
    --glbx.dbg( 'To:' || 'report_' || c4rec.umo_id || '.html'  );
    if c1rec.notification = '4'
     then
      zip( c4rec.document_original_loc || DECS.UNIX_OR_NT || ziprepname( c3rec.report_name, c8rec.parameter_value || '_' || to_char(sysdate,'hh24_mi')) || '.zip',
           c4rec.document_original_loc || DECS.UNIX_OR_NT || 'report_' || c4rec.umo_id || '.html' );
    end if;
 end if;

 -- dbms_lob.freetemporary( Gout_clob );
 free_temporary_lob;

 insert into report_queue_log(report_queue_id,report_id,activity_type,activity_date,activity_result) values
  (repid,c1rec.report_id,'STOP',sysdate,to_char(newid));
 commit;

 -- Also run reports
 for c7rec in c7(repid) loop
  select s_report_queue_id.nextval into newrep from dual;
  insert into report_queue(report_queue_id,report_id,sessid,aid,submit_time,run_every_1,run_every_2,run_every_3,priority,notification,autoexpire,status)
   values
   (newrep,c7rec.associated_id,owner_id,c1rec.aid,sysdate,'1',null,null,'A',c1rec.notification,null,LNG2.PFM_TXT_140);
  insert into report_queue_parameters(report_queue_id,report_id,parameter_name,parameter_type,parameter_value)
    select newrep,c7rec.associated_id,parameter_name,parameter_type,parameter_value
    from report_queue_parameters
    where report_queue_id = repid and
          report_id = c7rec.associated_id;
  -- Copy the latest parameters as well
  insert into report_queue_parameters(report_queue_id,report_id,parameter_name,parameter_type,parameter_value)
    select newrep,c7rec.associated_id,parameter_name,parameter_type,parameter_value
    from report_queue_parameters
    where report_queue_id = repid and
          report_id = c1rec.report_id;
  commit;
  run_the_report(newrep, ltype, owner_id);
 end loop;

 begin
 -- glbx.dbg('API: ' || c3rec.report_api);
 if c3rec.report_api is not null
  then
   open c11(upper(c3rec.report_api));
   fetch c11 into c11rec;
   if c11%FOUND
    then
     close c11;
     delete from report_api_parms;
     for j in parm1.first..parm1.last loop
      insert into report_api_parms(parm1, parm2) values (parm1(j), parm2(j));
     end loop;
     -- glbx.dbg('calling ' || 'begin ' || c3rec.report_api || '(' || newid || '); end;');
	 execute immediate 'begin ' || c3rec.report_api || '(:v_umo); end;' using newid;
   else
     close c11;
     -- glbx.dbg('Not found: ' || upper(c3rec.report_api));
   end if;
 end if;
 exception when others then
   glbx.dbg('Error Calling API: ' || sqlerrm);
 end;

 if c1rec.run_every_1 in ('1','2')
  then
   delete from report_queue_also_run where report_queue_id = repid;
   delete from report_queue_parameters where report_queue_id = repid;
   delete from report_queue where report_queue_id = repid;
 end if;
 commit;

 if c1rec.notification in ('2','3','4')
  then
    open c6(ltype,owner_id);
    fetch c6 into c6rec;
    close c6;
 end if;

 if c1rec.notification = '2' and (GBL_PARENT = repid )   -- Email Notification
  then
     gcode(1) := 'REPORT_NAME';
     gparam(1) := c3rec.report_name;
     gcode(2) := 'SIGNATURE';
     gparam(2) := glbx.extract_master_parameter('MAIL SIGNATURE');
     glbx.send( gcode, gparam, 'report_finished.tmp', p_to=>nvl(c6rec.billing_email,c6rec.contact_email), p_subj=>c3rec.report_name, p_from=>glbx.extract_master_parameter('MAIL_FROM'),ltype=>ltype,own_id=>owner_id, scode=>'RF1', v_pid=>owner_id, v_aid=>owner_id, v_profile_id=>owner_id);

 elsif c1rec.notification = '3' and (GBL_PARENT = repid )   -- Send SMS Notification
  then
   if c6rec.contact_mobile is not null
    then
     gcode(1) := NULL;
     gparam(1) := NULL;
     glbx.send( gcode, gparam, null, p_to=>c6rec.contact_mobile || '@' || glbx.extract_master_parameter('SMS_SITE'),p_subj=>LNG2.PFM_TXT_139 || ':' || c3rec.report_name,p_from=>glbx.extract_master_parameter('MAIL_FROM'),  is_sms=>TRUE,ltype=>ltype,own_id=>owner_id);
   end if;


 end if;

 exception when others then
  glbx.error_details( 'OLTP', 'RUN_THE_REPORT',null,owner_id,errmsg=>sqlerrm);
  free_temporary_lob;
end run_the_report;

procedure clob_append( bufr in varchar2 )
as

 loc1		integer;
 loc2		integer;
 abc		varchar2(2000);

begin

loc1 := length( bufr );
loc2 := length( Gbufr );
if ( loc1 + loc2 ) >= 32000
 then
  GBufr := GBufr || substr(bufr,1,(32000-loc2));
  dbms_lob.writeappend(Gout_clob,32000,GBufr);
  GBufr := substr(bufr,(32000-loc2)+1);
 else
  GBufr := GBufr || bufr;
end if;

 exception when others then
  glbx.error_details( 'OLTP', 'CLOB_APPEND',null,null,errmsg=>sqlerrm);
end clob_append;

procedure clob_trim_header
as
 loc2		integer;
 ctr		integer;
 ctr1		integer;
 x		integer;
 x1		integer;
begin
 -- Flush Current Buffer
 loc2 := length( Gbufr );
 dbms_lob.writeappend(Gout_clob,loc2,GBufr);
 GBufr := NULL;
 -- Loop through until there are no more
 ctr := 1;
 loop
  x := dbms_lob.instr(Gout_clob,'<TABLE',1,ctr);
  if x = 0 then exit; end if;
  ctr := ctr + 1;
 end loop;
 -- Find Position of Last Table Open
 ctr := ctr - 1;
 x := dbms_lob.instr(Gout_clob,'<TABLE',1,ctr);

 ctr1 := 1;
 loop
  x1 := dbms_lob.instr(Gout_clob,'<!-- END -->',1,ctr1);
  if x1 = 0 then exit; end if;
  ctr1 := ctr1 + 1;
 end loop;
 -- Find Position of Table End Marker
 ctr1 := ctr1 - 1;
 x1 := dbms_lob.instr(Gout_clob,'<!-- END -->',1,ctr1);
-- Added by David Banjo on 28/07/2020 to trim trailing headers with no records
if dbms_lob.substr(Gout_clob,7,x1-16) = '</THEAD' and x1 > 20 then
   GBufr := dbms_lob.substr(Gout_clob,loc2,x1);
   dbms_lob.trim(Gout_clob,x-1); 
   dbms_lob.writeappend(Gout_clob,loc2,GBufr);
   GBufr := NULL;
end if;
 x1 := nvl(x1,0);
 if x1 < x  then 
   dbms_lob.trim(Gout_clob,x-1); 
 end if; -- Only delete if the marker is before the table open tag

end clob_trim_header;

procedure clob_trim_emptyrow
as
 loc2		integer;
 ctr		integer;
 x		integer;
 y		integer;
 tstr		varchar2(100);
begin
 -- Flush Current Buffer
 loc2 := length( Gbufr );
 dbms_lob.writeappend(Gout_clob,loc2,GBufr);
 GBufr := NULL;
 -- Loop through until there are no more
 ctr := 1;
 loop
  x := dbms_lob.instr(Gout_clob,'<TR',1,ctr);
  if x = 0 then exit; end if;
  ctr := ctr + 1;
 end loop;
 -- Find Position of Last Table RowOpen
 ctr := ctr - 1;
 x := dbms_lob.instr(Gout_clob,'<TR',1,ctr);
 y := dbms_lob.instr(Gout_clob,'>',x,1);
 tstr := dbms_lob.substr(Gout_clob,6,y);
 if tstr = '></TR>'
  then
   dbms_lob.trim(Gout_clob,x-1);
 end if;
exception
 when others then null;
end clob_trim_emptyrow;

procedure report_file( acid in integer, fdir in varchar2, fname in varchar2, parm1 in out NOCOPY GLBX.MYARRAY, parm2 in out NOCOPY GLBX.MYARRAY, repid in integer )
as

fl	UTL_FILE.FILE_TYPE;
bufr	varchar2(32767);
vbufr	varchar2(32767);
ttag	varchar2(100);
ltag	varchar2(100);
ctr	integer;
stg	boolean;

begin
 -- Read in File
 Gbufr := NULL;

 begin
  fl := utl_file.fopen( fdir, fname, 'r', max_linesize=>32767 );
 exception
  when others then
   clob_append( LNG2.PFM_TXT_145 || ':' || fdir || fname );
   return;
 end;

 ctr := 0;
 stg := FALSE;
 loop

  begin
   utl_file.get_line(fl,vbufr);
  exception
   when others then exit;
  end;
  substitute_parameters( vbufr, parm1, parm2 );
  check_include_file( vbufr, fdir, parm1, parm2 );

  bufr := trim(vbufr);
  ttag := extract_tag_quick( bufr );
  if ttag = 'PICTION'
   then
    -- Empty Out Tables
    delete from report_temp_piction_tag;
    delete from report_temp_piction_attribute;
    delete from report_temp_piction_sql;
    delete from report_temp_piction_sql_exc;
    delete from report_temp_piction_sql_sum ;
    delete from report_temp_piction_sql_head;
    stg := TRUE;
    add_tbl( bufr, ltag, acid, parm1, parm2 );
    if is_report_stopped( repid ) then exit; end if; -- Check if the report has been marked as stopped
  elsif ttag in ('SUM','HEADING','COLUMN','FORMAT','HEADING','TAG_MASK','SUM_TAG_MASK','BREAK_ON','GROUP_BREAK_ON','LOCK_CELL','CELL','CELL_ALT','CELL_DETAILS','SQL','PICTION_SELECT','PICTION_ROLE','PICTION_ASSIGN','PICTION_FUNCTION','PATTRIBUTE','HEADER','EXCEPTION','IF_COLUMN','IF_EXPRESSION','IF_VALUE','IF_VALUE_TYPE','IF_ACTION','IF_ACTION_ATTRIB')
   then
    stg := TRUE;
    add_tbl( bufr, ltag, acid, parm1, parm2 );
    if ltag = 'PICTION_ROLE'
     then
      ext_role(acid, parm1, parm2 );
      ltag := NULL;
      stg := FALSE;
    elsif ltag = 'PICTION_ASSIGN'
     then
      ext_assign(acid, parm1, parm2 );
      ltag := NULL;
      stg := FALSE;
    end if;
    if is_report_stopped( repid ) then exit; end if; -- Check if the report has been marked as stopped
  elsif ttag in ('/SUM','/HEADING','/COLUMN','/FORMAT','/HEADER','/CELL','/SUM_TAG_MASK','/TAG_MASK','/GROUP_BREAK_ON','/LOCK_CELL','/BREAK_ON','CELL_ALT','CELL_DETAILS','/SQL','/PATTRIBUTE','/HEADER','/EXCEPTION','/IF_COLUMN','/IF_EXPRESSION','/IF_VALUE','/IF_VALUE_TYPE','/IF_ACTION','/IF_ACTION_ATTRIB')
   then
    stg := FALSE;
    ltag := NULL;
    if is_report_stopped( repid ) then exit; end if; -- Check if the report has been marked as stopped
  elsif ttag = '/PICTION_SELECT'
   then
    stg := FALSE;
    ltag := NULL;
    ext_parms(acid, parm1, parm2);
    if is_report_stopped( repid ) then exit; end if; -- Check if the report has been marked as stopped
  elsif ttag = '/PICTION_FUNCTION'
   then
    stg := FALSE;
    ltag := NULL;
    ext_function(acid, parm1, parm2);
    if is_report_stopped( repid ) then exit; end if; -- Check if the report has been marked as stopped
  elsif ttag = '/PICTION'
   then
    stg := FALSE;
    ltag := NULL;
    execute_piction_report( acid );
    if is_report_stopped( repid ) then exit; end if; -- Check if the report has been marked as stopped
  elsif stg
    then
     process_tag( ltag, bufr, 'F', parm1, parm2);
     if is_report_stopped( repid ) then exit; end if; -- Check if the report has been marked as stopped
   else
    ctr := ctr + 1;
    clob_append( vbufr || chr(10) );
    -- Every ten lines check to see if the report has to be stopped
    if mod(ctr,10) = 0
     then
       if is_report_stopped( repid ) then exit; end if; -- Check if the report has been marked as stopped
    end if;
  end if;

 end loop;
 utl_file.fclose(fl);

/*
 htp.italic( 'report_temp_piction_tag' ); htp.nl;
 for crec3 in (select * from  report_temp_piction_tag) loop
  htp.bold( crec3.tag_id || '-' || crec3.tag_type || '-' || crec3.tag_style ); htp.nl;
 end loop;
 htp.italic( 'report_temp_piction_attribute' ); htp.nl;
 for crec4 in (select * from  report_temp_piction_attribute) loop
  htp.bold( crec4.tag_id || '-' || crec4.tag_type || '-' || crec4.tag_value ); htp.nl;
 end loop;
 htp.italic( 'report_temp_piction_sql' ); htp.nl;
 for crec2 in (select * from report_temp_piction_sql) loop
  htp.bold( crec2.stmt_id || '-' || crec2.tag_value ); htp.nl;
 end loop;
 htp.italic( 'report_temp_piction_sql_sum' ); htp.nl;
 for crec in (select * from report_temp_piction_sql_sum) loop
  htp.bold( crec.stmt_id || '-' || crec.tag_column ); htp.nl;
 end loop;
 htp.italic( 'report_temp_piction_sql_head' ); htp.nl;
 for crec5 in (select * from report_temp_piction_sql_head) loop
  htp.bold( crec5.stmt_id || '-' || crec5.tag_column || '-' || crec5.tag_format || '-' || crec5.tag_header || '-' || crec5.tag_cell ); htp.nl;
 end loop;
*/

 exception when others then
  glbx.error_details( 'OLTP', 'REPORT_FILE',null,acid,errmsg=>sqlerrm);
end report_file;

procedure ext_parms( acid in integer, parm1 in out NOCOPY GLBX.MYARRAY, parm2 in out NOCOPY GLBX.MYARRAY )
as

   cursor_name		integer;
   col_count		integer;
   desc_t		dbms_sql.desc_tab;
   common_nmb		number;
   common_vc2		varchar2(4000);
   common_dte		date;
   tmpval		varchar2(4000);
   dummy		integer;

begin

   if GBL_SELECT is null then return; end if;
   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, restrict_sqlstmt(acid, GBL_SELECT), dbms_sql.native );
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

   dummy := dbms_sql.fetch_rows( cursor_name );
   if dummy > 0
    then

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
      if parm1.exists(1)
       then
        dummy := parm1.last + 1;
       else
        dummy := 1;
      end if;
      parm1(dummy) := desc_t(j).col_name;
      parm2(dummy) := tmpval;
     end loop;
  end if;

  dbms_sql.close_cursor( cursor_name );
  GBL_SELECT := NULL;

 exception when others then
  glbx.error_details( 'OLTP', 'EXT_PARMS',null,acid,errmsg=>sqlerrm,extdet=>substr(GBL_SELECT,1,4000));
end ext_parms;

procedure ext_role( acid in integer, parm1 in out NOCOPY GLBX.MYARRAY, parm2 in out NOCOPY GLBX.MYARRAY )
as

   cursor c1( acid integer, rname varchar2 ) is
    select parameter_value
    from piction_roles pr, customer_roles cr
    where cr.aid = acid and
          cr.role_id = pr.role_id and
          role_type = 'PARAMETER' and
          parameter_name = rname;

   tmpval	varchar2(4000);
   dummy	integer;

begin
  if GBL_NAME is null then return; end if;
  if parm1.exists(1)
   then
    dummy := parm1.last + 1;
   else
    dummy := 1;
  end if;

  open c1(acid,upper(GBL_NAME));
  fetch c1 into tmpval;
  if c1%FOUND
   then
    parm1(dummy) := upper(GBL_NAME);
    parm2(dummy) := tmpval;
  end if;
  close c1;

  GBL_NAME := NULL;

 exception when others then
  glbx.error_details( 'OLTP', 'EXT_ROLE',null,acid,errmsg=>sqlerrm);
end ext_role;

procedure ext_assign( acid in integer, parm1 in out NOCOPY GLBX.MYARRAY, parm2 in out NOCOPY GLBX.MYARRAY )
as

   tmpval	varchar2(4000);
   dummy	integer;

begin
  if GBL_NAME is null then return; end if;
  if parm1.exists(1)
   then
    dummy := parm1.last + 1;
   else
    dummy := 1;
  end if;

  parm1(dummy) := upper(GBL_NAME);
  parm2(dummy) := GBL_SELECT;

  GBL_NAME := NULL;
  GBL_SELECT := NULL;

 exception when others then
  glbx.error_details( 'OLTP', 'EXT_ASSIGN',null,acid,errmsg=>sqlerrm);
end ext_assign;

procedure ext_function( acid in integer, parm1 in out NOCOPY GLBX.MYARRAY, parm2 in out NOCOPY GLBX.MYARRAY )
as

   tmpval	varchar2(4000);
   dummy	integer;

begin

  if GBL_SELECT is null or GBL_NAME is null then return; end if;
  if substr(GBL_SELECT,length(GBL_SELECT),1) = ';'
   then
    execute immediate 'begin :1 := ' || GBL_SELECT || ' end;' using in out tmpval;
   else
    execute immediate 'begin :1 := ' || GBL_SELECT || '; end;' using in out tmpval;
  end if;

  if parm1.exists(1)
   then
    dummy := parm1.last + 1;
   else
    dummy := 1;
  end if;
  parm1(dummy) := upper(GBL_NAME);
  parm2(dummy) := tmpval;

  GBL_SELECT := NULL;
  GBL_NAME := NULL;

 exception when others then
  glbx.error_details( 'OLTP', 'EXT_FUNCTION',null,acid,errmsg=>sqlerrm,extdet=>'Function:' || GBL_SELECT);
end ext_function;

function extract_tag_quick( val in varchar2 )
 return varchar2
as

 loc	integer;
 loc2	integer;

begin
 loc2 := 0;
 if substr( val,1,1) <> '<' then return( NULL ); end if;
 loc := instr(val,'>');
 if loc = 0 then return( NULL ); end if; -- No end tag
 loc2 := instr(val,' ');
 if (nvl(loc2,0) < loc) and (nvl(loc2,0) <> 0) then loc := loc2 - 1; else loc := loc - 1; end if;
 return( upper( substr( val,2,loc-1)));
 exception when others then
  glbx.error_details( 'OLTP', 'EXTRACT_TAG_QUICK',null,null,errmsg=>sqlerrm);
end extract_tag_quick;

procedure add_tbl( bufr in varchar2, ltag in out varchar2, acid in integer, parm1 in out NOCOPY GLBX.MYARRAY, parm2 in out NOCOPY GLBX.MYARRAY )
as

 tag_ctr	integer;
 loc		integer;
 endloc		integer;
 lastloc	integer;
 tagstr		varchar2(32767);

begin
 tag_ctr := 1;
 lastloc := 1;
 endloc := 1;
 loop

  loc:= instr( bufr, '<', 1, tag_ctr );
  if loc = 0
   then
    if substr(bufr,length(bufr),1) = '>'
     then
      exit;
     else
      if endloc = 1
       then
        tagstr := bufr;
       else
        tagstr := substr(bufr,endloc + 1);
      end if;
      -- Process
      process_tag( ltag, tagstr, 'F', parm1, parm2 );
      exit;
    end if;
   else
    if endloc + 1 = loc
     then
      endloc := instr( bufr, '>', 1, tag_ctr );
      tagstr := substr(bufr,lastloc+1,(endloc - loc)-1);
      if tagstr = '/PICTION_SELECT'
       then
        ext_parms( acid, parm1, parm2 );
      elsif tagstr = '/PICTION_FUNCTION'
       then
        commit;
        ext_function( acid, parm1, parm2 );
      else
        process_tag( ltag, tagstr, 'T', parm1, parm2 );
      end if;
      tag_ctr := tag_ctr + 1; -- Only increment here
     else
      -- Tagstr if freeform text
      tagstr := substr(bufr,endloc+1,(loc - endloc)-1);
      process_tag( ltag, tagstr, 'F', parm1, parm2 );
      endloc := loc - 1;
    end if;
  end if;
  if tag_ctr > 100 then htp.p( 'Inf:' || bufr ); htp.nl; exit; end if;
  lastloc := loc;
 end loop;

 exception when others then
  glbx.error_details( 'OLTP', 'ADD_TBL',null,acid,errmsg=>sqlerrm);
end add_tbl;

procedure process_tag( ltag in out varchar2, tagval varchar2, typ in varchar2, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY )
as

  nmb		integer;
  nmb2		integer;
  tval1		varchar2(1000);
  tval2		varchar2(4000);
  tval3		varchar2(4000);

begin
 if typ = 'T'
  then
   if substr(tagval,1,1) = '/' then ltag := NULL; return; end if;
   ltag := NULL;
   if upper(substr(tagval,1,3)) = 'SQL'
    then
     tval1 := extract_tag_value( tagval,'TITLE');
     tval2 := extract_tag_value( tagval,'LINEFEED');
     select nvl(max(tag_id),0) + 1 into nmb from report_temp_piction_sql;
     insert into report_temp_piction_sql(tag_id,tag_value,title,linefeed) values(nmb,null,tval1,tval2);
     ltag := 'SQL';
   elsif upper(tagval) = 'PICTION_SELECT'
    then
     GBL_SELECT := NULL;
     ltag := 'PICTION_SELECT';
   elsif upper(substr(tagval,1,12)) = 'PICTION_ROLE'
    then
     GBL_NAME := extract_tag_value( tagval,'NAME');
     ltag := 'PICTION_ROLE';
   elsif upper(substr(tagval,1,14)) = 'PICTION_ASSIGN'
    then
     GBL_NAME := extract_tag_value( tagval,'NAME');
     GBL_SELECT := extract_tag_value( tagval,'VALUE');
     ltag := 'PICTION_ASSIGN';
   elsif upper(substr(tagval,1,16)) = 'PICTION_FUNCTION'
    then
     GBL_SELECT := NULL;
     GBL_NAME := extract_tag_value( tagval,'NAME');
     commit;
     ltag := 'PICTION_FUNCTION';
   elsif upper(tagval) = 'SUM'
    then
     select nvl(max(stmt_id),0) + 1 into nmb from report_temp_piction_sql_sum;
     select nvl(max(tag_id),1) into nmb2 from report_temp_piction_sql;
     insert into report_temp_piction_sql_sum(tag_id,stmt_id,tag_column) values (nmb2,nmb,null);
     ltag := 'SUM';
   elsif upper(substr(tagval,1,7)) = 'PICTION'
    then
     tval1 := extract_tag_value( tagval,'TYPE');
     tval2 := extract_tag_value( tagval,'STYLE');
     insert into report_temp_piction_tag(tag_type,tag_style) values (tval1,tval2);
     ltag := 'PICTION';
   elsif upper(substr(tagval,1,10)) = 'PATTRIBUTE'
    then
     tval1 := upper(extract_tag_value( tagval,'TYPE'));
     tval2 := upper(extract_tag_value( tagval,'COLUMN'));
     tval3 := extract_tag_value( tagval,'VALUE');
     select nvl(max(tag_id),0) + 1 into nmb from report_temp_piction_attribute;
     insert into report_temp_piction_attribute(tag_id,tag_type,tag_value,tag_column,tag_col_value) values (nmb,tval1,null,tval2,tval3);
     ltag := 'PATTRIBUTE';
   elsif upper(tagval) = 'HEADING'
    then
     select nvl(max(stmt_id),0) + 1 into nmb from report_temp_piction_sql_head;
     select nvl(max(tag_id),1) into nmb2 from report_temp_piction_sql;
     insert into report_temp_piction_sql_head(tag_id,stmt_id) values (nmb2,nmb);
     ltag := 'HEADING';
   elsif upper(tagval) = 'COLUMN'
    then
     ltag := 'COLUMN';
   elsif upper(tagval) = 'FORMAT'
    then
     ltag := 'FORMAT';
   elsif upper(tagval) = 'HEADER'
    then
     ltag := 'HEADER';
   elsif upper(tagval) = 'CELL'
    then
     ltag := 'CELL';
   elsif upper(tagval) = 'CELL_ALT'
    then
     ltag := 'CELL_ALT';
   elsif upper(tagval) = 'CELL_DETAILS'
    then
     ltag := 'CELL_DETAILS';
   elsif upper(tagval) = 'TAG_MASK'
    then
     ltag := 'TAG_MASK';
   elsif upper(tagval) = 'SUM_TAG_MASK'
    then
     ltag := 'SUM_TAG_MASK';
   elsif upper(tagval) = 'BREAK_ON'
    then
     ltag := 'BREAK_ON';
   elsif upper(tagval) = 'GROUP_BREAK_ON'
    then
     ltag := 'GROUP_BREAK_ON';
   elsif upper(tagval) = 'LOCK_CELL'
    then
     ltag := 'LOCK_CELL';
   elsif upper(tagval) = 'EXCEPTION'
    then
     select nvl(max(stmt_id),0) + 1 into nmb from report_temp_piction_sql_exc;
     select nvl(max(tag_id),1) into nmb2 from report_temp_piction_sql;
     insert into report_temp_piction_sql_exc(tag_id,stmt_id) values (nmb2,nmb);
     ltag := 'EXCEPTION';
   elsif upper(tagval) = 'IF_COLUMN'
    then
     ltag := 'IF_COLUMN';
   elsif upper(tagval) = 'IF_EXPRESSION'
    then
     ltag := 'IF_EXPRESSION';
   elsif upper(tagval) = 'IF_VALUE'
    then
     ltag := 'IF_VALUE';
   elsif upper(tagval) = 'IF_VALUE_TYPE'
    then
     ltag := 'IF_VALUE_TYPE';
   elsif upper(tagval) = 'IF_ACTION'
    then
     ltag := 'IF_ACTION';
   elsif upper(tagval) = 'IF_ACTION_ATTRIB'
    then
     ltag := 'IF_ACTION_ATTRIB';
   else
    null; --htp.bold( 'I:' || tagval ); htp.nl;
   end if;

  else

   if ltag = 'SQL'
    then
     select nvl(max(tag_id),0) into nmb from report_temp_piction_sql;
     begin
      update report_temp_piction_sql
       set
        tag_value = tag_value || ' ' || tagval
       where tag_id = nmb and tag_value2 is null;
      update report_temp_piction_sql
       set
        tag_value2 = tag_value2 || ' ' || tagval
       where tag_id = nmb and tag_value2 is not null;
     exception
      when others then
       update report_temp_piction_sql
        set
         tag_value2 = ' ' || tagval
        where tag_id = nmb;
     end;

    elsif ltag = 'PICTION_SELECT'
     then
      begin GBL_SELECT := GBL_SELECT || ' ' || tagval; exception when others then null; end;
    elsif ltag = 'PICTION_FUNCTION'
     then
      begin GBL_SELECT := GBL_SELECT || ' ' || tagval; exception when others then null; end;
    elsif ltag = 'SUM'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_sum;
     update report_temp_piction_sql_sum
       set
        tag_column = tagval
       where stmt_id = nmb;
    elsif ltag = 'PATTRIBUTE'
     then
     select nvl(max(tag_id),0) into nmb from report_temp_piction_attribute;
     update report_temp_piction_attribute
       set
        tag_value = tagval
       where tag_id = nmb;
     validate_attribute( nmb, parm1, parm2 );
    elsif ltag = 'COLUMN'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_head;
     update report_temp_piction_sql_head
       set
        tag_column = tagval
       where stmt_id = nmb;
    elsif ltag = 'FORMAT'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_head;
     update report_temp_piction_sql_head
       set
        tag_format = tagval
       where stmt_id = nmb;
    elsif ltag = 'HEADER'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_head;
     update report_temp_piction_sql_head
       set
        tag_header = nvl(replace(tagval,'|','<BR>'),'~')
       where stmt_id = nmb;
    elsif ltag = 'CELL'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_head;
     update report_temp_piction_sql_head
       set
        tag_cell = tagval
       where stmt_id = nmb;
    elsif ltag = 'CELL_ALT'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_head;
     update report_temp_piction_sql_head
       set
        tag_cell_alt = tagval
       where stmt_id = nmb;
    elsif ltag = 'TAG_MASK'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_head;
     update report_temp_piction_sql_head
       set
        tag_mask = tagval
       where stmt_id = nmb;
    elsif ltag = 'BREAK_ON'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_head;
     update report_temp_piction_sql_head
       set
        break_on = tagval
       where stmt_id = nmb;
    elsif ltag = 'GROUP_BREAK_ON'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_head;
     update report_temp_piction_sql_head
       set
        group_break_on = tagval
       where stmt_id = nmb;
    elsif ltag = 'LOCK_CELL'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_head;
     update report_temp_piction_sql_head
       set
        lock_cell = tagval
       where stmt_id = nmb;
    elsif ltag = 'CELL_DETAILS'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_sum;
     update report_temp_piction_sql_sum
       set
        cell_details = tagval
       where stmt_id = nmb;
    elsif ltag = 'SUM_TAG_MASK'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_sum;
     update report_temp_piction_sql_sum
       set
        tag_mask = tagval
       where stmt_id = nmb;
    elsif ltag = 'IF_COLUMN'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_exc;
     update report_temp_piction_sql_exc
       set
        if_column = tagval
       where stmt_id = nmb;
    elsif ltag = 'IF_EXPRESSION'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_exc;
     update report_temp_piction_sql_exc
       set
        if_expression = tagval
       where stmt_id = nmb;
    elsif ltag = 'IF_VALUE'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_exc;
     update report_temp_piction_sql_exc
       set
        if_value = tagval
       where stmt_id = nmb;
    elsif ltag = 'IF_VALUE_TYPE'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_exc;
     update report_temp_piction_sql_exc
       set
        if_value_type = tagval
       where stmt_id = nmb;
    elsif ltag = 'IF_ACTION'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_exc;
     update report_temp_piction_sql_exc
       set
        if_action = tagval
       where stmt_id = nmb;
    elsif ltag = 'IF_ACTION_ATTRIB'
     then
     select nvl(max(stmt_id),0) into nmb from report_temp_piction_sql_exc;
     update report_temp_piction_sql_exc
       set
        if_action_attrib = tagval
       where stmt_id = nmb;
   end if;
   if ltag not in ('SQL','PICTION_SELECT','PICTION_FUNCTION') then ltag := NULL; end if;
 end if;
 exception when others then
  glbx.error_details( 'OLTP', 'PROCESS_TAG',null,null,errmsg=>sqlerrm);
end process_tag;

procedure validate_attribute( nmb in integer, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY )
as

 cursor c1( nmb integer ) is select * from report_temp_piction_attribute where tag_id = nmb;

 c1rec		c1%ROWTYPE;
 outsql		varchar2(5000);
 retval		varchar2(4000);
 cursor_name	integer;
 dummy		integer;

begin
 open c1( nmb );
 fetch c1 into c1rec;
 close c1;
 if c1rec.tag_type not in ('DO_NOT_DISPLAY_REPORT','DO_NOT_DISPLAY_COLUMN' )
  then
   return;
 end if;
 if (c1rec.tag_col_value is null) or (c1rec.tag_column is null) or (c1rec.tag_value is null)
  then
   return;
 end if;
 outsql := c1rec.tag_value;
 substitute_parameters(outsql,parm1,parm2);
 --execute immediate outsql into retval;
 -- Using this to fix issue if row returns more than one value
 cursor_name := dbms_sql.open_cursor;
 dbms_sql.parse( cursor_name, outsql, dbms_sql.native );
 dbms_sql.define_column_char(cursor_name,1,retval,4000);
 dummy := dbms_sql.execute( cursor_name );
 dummy := dbms_sql.fetch_rows( cursor_name );
 dbms_sql.column_value_char(cursor_name,1,retval);
 retval := trim(retval);
 dbms_sql.close_cursor( cursor_name );

 if retval = c1rec.tag_col_value
  then
    update report_temp_piction_attribute
     set
      col_val_result = retval
     where tag_id = nmb;
 end if;

 exception when others then
  glbx.error_details( 'OLTP', 'VALIDATE_ATTRIBUTE',null,null,errmsg=>sqlerrm,extdet=>substr(outsql,1,4000));
end validate_attribute;

function extract_tag_value( tagval in varchar2, tagkey in varchar2 )
 return varchar2
as

 loc	integer;
 loc2	integer;
 ctr	integer;
 dlm	char(1);
 retstr	varchar2(1000);

begin
 if tagval is null then return( NULL ); end if;
 ctr := 1;
 loop
  loc := instr(upper(tagval),tagkey,1,ctr);
  if loc = 0 then return( NULL ); end if;
  -- Check previous position of tag for valid delimiters
  exit when (loc = 1) or (substr(tagval,loc-1,1) = ' ') or (substr(tagval,loc-1,1) = '<') or (substr(tagval,loc-1,1) = '"');
  ctr := ctr + 1;
 end loop;

 if substr(tagval,loc+length( tagkey ) + 1,1) = '"'
  then
   dlm := '"';
  else
   dlm := ' ';
 end if;
 loc2 := instr(tagval,dlm,loc+length( tagkey )+2);
 if loc2 = 0
  then
   loc2 := length( tagval ) + 1;
 end if;
 retstr := substr( tagval, loc+1, (loc2-loc) - 1 );
 retstr := substr( retstr, length( tagkey ) + 1 );
 retstr := replace( retstr, '"','');
 return( retstr );
 exception when others then
  glbx.error_details( 'OLTP', 'EXTRACT_TAG_VALUE',null,null,errmsg=>sqlerrm);
end extract_tag_value;

procedure substitute_parameters( vbufr in out varchar2, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY )
as

 loc	integer;
 ctr	integer;

begin
 for j in parm1.first..parm1.last loop
  if parm1(j) is not null
   then
    ctr := 1;
    vbufr := replace( vbufr, '<PICTION_PARAMETER=' || upper(parm1(j)) || '>', parm2(j) );
    vbufr := replace( vbufr, '<PP=' || upper(parm1(j)) || '>', parm2(j) );
  end if;
 end loop;
 exception when others then
  glbx.error_details( 'OLTP', 'SUBSTITUTE_PARAMETERS',null,null,errmsg=>sqlerrm);
end substitute_parameters;

procedure substitute_parameters2( vbufr in varchar2, vbfr1 out varchar2, vbfr2 out varchar2, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY )
as

 loc	integer;
 ctr	integer;
 xbufr	varchar2(6000);

begin
 xbufr := vbufr;
 for j in parm1.first..parm1.last loop
  if parm1(j) is not null
   then
    ctr := 1;
    xbufr := replace( xbufr, '<PICTION_PARAMETER=' || upper(parm1(j)) || '>', parm2(j) );
    xbufr := replace( xbufr, '<PP=' || upper(parm1(j)) || '>', parm2(j) );
  end if;
 end loop;
 vbfr1 := substr(xbufr,1,4000);
 vbfr2 := ' ' || substr(xbufr,4001);
 exception when others then
  glbx.error_details( 'OLTP', 'SUBSTITUTE_PARAMETERS2',null,null,errmsg=>sqlerrm);
end substitute_parameters2;

procedure check_include_file( vbufr in out varchar2, fdir in varchar2, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY )
as

 loc		integer;
 loc2		integer;
 fl		UTL_FILE.FILE_TYPE;
 vfdir		varchar2(1000);
 vfname		varchar2(1000);
 fname		varchar2(1000);
 bufr		varchar2(32767);

begin

 loc := instr(upper(vbufr),'<PICTION_INCLUDE>');

 if loc > 0
  then
    loc := loc + length('<PICTION_INCLUDE>');
    loc2 := instr(upper(vbufr),'</PICTION_INCLUDE>',loc);
    fname := substr(vbufr,loc,loc2-loc);
    vfdir := nvl(glbx.extract_fname(fname,'PWD'),fdir);
    vfname := glbx.extract_fname(fname,'FILENAME');
    begin
     fl := utl_file.fopen( vfdir, vfname, 'r', max_linesize=>32767 );
    exception
     when others then
       clob_append( LNG2.PFM_TXT_145 || ':' || vfdir || vfname );
     return;
    end;

    loop
     begin
       utl_file.get_line(fl,bufr);
      exception
       when others then exit;
     end;
     --bufr := bufr || chr(10);
     substitute_parameters( bufr, parm1, parm2 );
     clob_append( bufr );
    end loop;
    utl_file.fclose(fl);
    vbufr := null;
  else
    return;

 end if;

 exception when others then
  glbx.error_details( 'OLTP', 'CHECK_INCLUDE_FILE',null,null,errmsg=>sqlerrm);
end check_include_file;

procedure execute_piction_report( acid in integer )
as

 cursor c1 is select * from report_temp_piction_tag;
 cursor c2 is select * from report_temp_piction_attribute where tag_type = 'DO_NOT_DISPLAY_REPORT' and col_val_result = tag_col_value;
 cursor c3 is select * from report_temp_piction_sql;
 cursor c4 is select * from report_temp_piction_attribute where tag_type = 'DO_NOT_DISPLAY_COLUMN' and col_val_result = tag_col_value;

 c1rec	c1%ROWTYPE;
 c2rec	c2%ROWTYPE;
 c3rec	c3%ROWTYPE;
 c3rec1	c3%ROWTYPE;
 child_record_exists boolean;

begin

 open c2;
 fetch c2 into c2rec;
 if c2%FOUND
  then
   close c2;
   -- Tag has evaluated to indicate this report should not be run. So exit.
   return;
  else
   close c2;
 end if;

 -- Display display of headings if requested
 for c4rec in c4 loop
  update report_temp_piction_sql_head
   set
    tag_header = '~'
  where tag_column = c4rec.tag_column;
 end loop;

 open c1;
 fetch c1 into c1rec;
 close c1;


 if c1rec.tag_style = 'CSV'
  then
   null;
   --clob_append('Content-type: ' || 'bad/type' || LINEFEED );
   --clob_append('Content-Disposition: attachment; filename="report.csv"' || LINEFEED);
   --clob_append('Content-Transfer-Encoding: 7bit' || LINEFEED);
   --clob_append(LINEFEED);
 end if;

 if c1rec.tag_style = 'XML'
  then
   null;
   --clob_append('Content-type: ' || 'bad/type' || LINEFEED );
   --clob_append('Content-Disposition: attachment; filename="report.csv"' || LINEFEED);
   --clob_append('Content-Transfer-Encoding: 7bit' || LINEFEED);
   --clob_append(LINEFEED);
 end if;


 if c1rec.tag_type = 'SINGLE'
  then
   for c3rec in c3 loop
    child_record_exists := FALSE;
    piction_report_sql( acid, c1rec, c3rec, c3rec1, child_record_exists );
   end loop;
 elsif c1rec.tag_type = 'ONE_TO_MANY' --xxx
  then
    open c3;
    fetch c3 into c3rec;
    fetch c3 into c3rec1;
    close c3;
    child_record_exists := FALSE;
    piction_report_sql( acid, c1rec, c3rec, c3rec1, child_record_exists );
    if not child_record_exists then clob_trim_header; end if;
 end if;

 if nvl(c1rec.tag_style,'TABLE') = 'TABLE'
  then
   clob_append( '<!-- END -->' ); -- Attach Marker to prevent accidental header erasure
   clob_trim_header;  -- ADDED BY David Banjo to trim trailing headers
 end if;
 exception when others then
  glbx.error_details( 'OLTP', 'EXECUTE_PICTION_REPORT',null,acid,errmsg=>sqlerrm);
end execute_piction_report;

procedure piction_report_sql( acid in integer, crec in report_temp_piction_tag%ROWTYPE, sqlrec in report_temp_piction_sql%ROWTYPE, sqlrec2 in report_temp_piction_sql%ROWTYPE, child_record_exists in out boolean )
as

 TYPE sum_array is TABLE OF number INDEX BY BINARY_INTEGER;
 TYPE sum_array_f is TABLE OF varchar2(4000) INDEX BY BINARY_INTEGER;

 cursor c1(tid integer, cname varchar2) is select * from report_temp_piction_sql_exc where tag_id = tid and upper(if_column) = cname;
 cursor c2(tid integer, cname varchar2) is select * from report_temp_piction_sql_sum where tag_id = tid and upper(tag_column) = cname;
 cursor c3(tid integer, cname varchar2) is select * from report_temp_piction_sql_head where tag_id = tid and upper(tag_column) = cname;
 cursor c4(ttype varchar2, tname varchar2) is select tag_value from report_temp_piction_attribute where upper(tag_type) = ttype and upper(tag_value) = tname;
 cursor c5(ttype varchar2) is select tag_value from report_temp_piction_attribute where upper(tag_type) = ttype and upper(tag_value) not in ('HEADER','NOHEADER');
 cursor c6(ttype varchar2) is select tag_value from report_temp_piction_attribute where upper(tag_type) = ttype;
 cursor c7(tid integer) is select 'x' from report_temp_piction_sql_sum where tag_id = tid;
 cursor c8(v_umo integer) is select * from umo where umo_id = v_umo;

 c1rec			c1%ROWTYPE;
 c2rec			c2%ROWTYPE;
 c3rec			c3%ROWTYPE;
 c4rec			c4%ROWTYPE;
 c6rec			c6%ROWTYPE;
 c8rec			c8%ROWTYPE;
 parm1			GLBX.MYARRAY;
 parm2			GLBX.MYARRAY;
 nxt_sqlrec		report_temp_piction_sql%ROWTYPE;
 emp_sqlrec		report_temp_piction_sql%ROWTYPE;
 cursor_name		integer;
 col_count		integer;
 dummy			integer;
 rowctr			integer;
 desc_t			dbms_sql.desc_tab;
 common_nmb		number;
 common_vc2		varchar2(4000);
 common_dte		date;
 step			varchar2(100);
 tmp			char(1);
 disp_header		boolean;
 frec			boolean;
 is_rowctr		boolean;
 any_sum		boolean;
 lockcell		boolean;
 child_record_exists2	boolean;
 summ			sum_array;
 summ_f			sum_array_f;
 sum_cell		glbx.myarray;
 break_on		glbx.myarray;
 group_break_on		glbx.myarray;
 cname			varchar2(100);
 tmpval			varchar2(4000);
 no_row_message		varchar2(4000);
 tattr			varchar2(1000);
 rattr			varchar2(1000);
 rtype			varchar2(4000);
 currlock		varchar2(4000);
 lastlock		varchar2(4000);
 tablerow		varchar2(32767);
 lastgbo		varchar2(32767);
 currgbo		varchar2(32767);
 gbo_tablerow		varchar2(32767);
 curr_lockrow		varchar2(32767);
 xtmp varchar2(32767);

 procedure display_the_header
 is
 begin

    if sqlrec.title is not null
     then
      clob_append( htf.header(3,sqlrec.title,'CENTER') );
    end if;

    if nvl(crec.tag_style,'TABLE') = 'TABLE' and disp_header
     then
      clob_append( htf.tableopen( cattributes=>tattr ) );
      clob_append( '<THEAD>' );
      clob_append( htf.tablerowopen( cattributes=>rattr ) );
      if is_rowctr
       then
        cname := c6rec.tag_value;
        open c3( sqlrec.tag_id, upper(cname) );
        fetch c3 into c3rec;
        if c3%FOUND
         then
          cname := nvl(c3rec.tag_header,cname);
        end if;
        close c3;
        -- An Empty Header Tag says do not display
        clob_append( htf.tableheader(cname,cattributes=>c3rec.tag_format) );
      end if;
      for j in 1..col_count loop
       cname := desc_t(j).col_name;
       open c3( sqlrec.tag_id, upper(cname) );
       fetch c3 into c3rec;
       if c3%FOUND
        then
         cname := nvl(c3rec.tag_header,cname);
       end if;
       close c3;
        if cname = '~'
         then
          desc_t(j).col_schema_name := '~'; -- Says do not display
         else
          clob_append( htf.tableheader(cname,cattributes=>c3rec.tag_format) );
        end if;
      end loop;
      clob_append( htf.tablerowclose );
      clob_append( '</THEAD>' );

     elsif nvl(crec.tag_style,'TABLE') = 'TABLE'
      then
       clob_append( htf.tableopen( cattributes=>tattr ) );

     elsif nvl(crec.tag_style,'TABLE') = 'CSV'
     then
      for j in 1..col_count loop
       if j = 1
        then
         clob_append( '"' || replace(desc_t(j).col_name,'"','') || '"' );
        else
         clob_append( ',"' || replace(desc_t(j).col_name,'"','') || '"' );
       end if;
      end loop;
      clob_append(LINEFEED );

     elsif nvl(crec.tag_style,'TABLE') = 'XML'
     then
      clob_append( '<?xml version = "1.0"?>' );
      clob_append( LINEFEED );
      clob_append( '<REPORT>' );
      clob_append( LINEFEED );

    end if;
   end display_the_header;

begin
step := 'Xa';
   cursor_name := dbms_sql.open_cursor;
   begin
     dbms_sql.parse( cursor_name, restrict_sqlstmt(acid,sqlrec.tag_value || sqlrec.tag_value2), dbms_sql.native );
   exception
    when others then
      clob_append( sqlerrm );
      clob_append( htf.nl );
      clob_append( restrict_sqlstmt(acid,sqlrec.tag_value || sqlrec.tag_value2) );
      begin dbms_sql.close_cursor( cursor_name ); exception when others then null; end;
      return;
   end;
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

   disp_header := TRUE;
   open c4( 'TABLE','NOHEADER' ); -- PATTRIBUTE TYPE=
   fetch c4 into c4rec;
   if c4%FOUND then disp_header := FALSE; end if;
   close c4;

   tattr := 'cellspacing=2 cellpadding=2 border=1';
   open c5('TABLE'); -- PATTRIBUTE TYPE=
   fetch c5 into tattr;
   close c5;

   is_rowctr := FALSE;
   open c6('ROWCTR');
   fetch c6 into c6rec;
   if c6%FOUND then is_rowctr := TRUE; end if;
   close c6;

   open c6('ROW');
   fetch c6 into rattr;
   close c6;

step := 'Xb';
   open c6('WHEN_NO_ROWS');
   fetch c6 into no_row_message;
   close c6;

   any_sum := FALSE;
   open c7( sqlrec.tag_id );
   fetch c7 into tmp;
   if c7%FOUND then any_sum := TRUE; end if;
   close c7;

   begin
   dummy := dbms_sql.execute( cursor_name );
   exception
    when others then
      begin dbms_sql.close_cursor( cursor_name ); exception when others then null; end;
      clob_append( sqlerrm );
      clob_append( htf.nl );
      clob_append( sqlrec.tag_value || sqlrec.tag_value2 );
      return;
   end;
   rowctr := 0;
   lastgbo := NULL;
   currgbo := NULL;

   lockcell := FALSE;
   loop -- MainLoop
   dummy := dbms_sql.fetch_rows( cursor_name );
   if dummy > 0
    then
     if not child_record_exists
      then
       child_record_exists := TRUE;
       display_the_header;
     end if;
     rowctr := rowctr + 1;
     if nvl(crec.tag_style,'TABLE') = 'TABLE'
      then
       clob_append( htf.tablerowopen( cattributes=>rattr ) );
     elsif nvl(crec.tag_style,'TABLE') = 'XML'
      then
       clob_append( '<ROWSET ID="' || to_char(rowctr) || '">' );
     end if;
     tablerow := NULL;
     gbo_tablerow := NULL;

step := 'Xc';
     for j in 1..col_count loop -- JRow

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
         tmpval := to_char( common_dte, LNG.TSMASK );
      end if;

      -- Check for Exception
      frec := FALSE;
      open c1( sqlrec.tag_id, upper(desc_t(j).col_name) );
      fetch c1 into c1rec;
      if c1%found
       then
        close c1;
        if upper(c1rec.if_value_type) = 'CONSTANT'
         then
          rtype := c1rec.if_value;
        end if;
        if c1rec.if_expression = '='
         then
          if rtype = tmpval then frec := TRUE; end if;
        elsif c1rec.if_expression = '<>'
         then
          if rtype <> tmpval then frec := TRUE; end if;
        elsif c1rec.if_expression in ('<','LT')
         then
          if rtype > tmpval then frec := TRUE; end if;
        elsif c1rec.if_expression in ('>','GT')
         then
          if rtype < tmpval then frec := TRUE; end if;
        elsif c1rec.if_expression in ('<=','LEQ')
         then
          if rtype >= tmpval then frec := TRUE; end if;
        elsif c1rec.if_expression in ('>=','GEQ')
         then
          if rtype <= tmpval then frec := TRUE; end if;
        elsif upper(c1rec.if_expression) = 'LIKE'
         then
          if rtype like tmpval then frec := TRUE; end if;
        elsif upper(c1rec.if_expression) = 'IS NULL'
         then
          if tmpval is null then frec := TRUE; end if;
        elsif upper(c1rec.if_expression) = 'IS NOT NULL'
         then
          if tmpval is not null then frec := TRUE; end if;
        end if;
       else
        close c1;
      end if;

      -- Display Table Data with Attributes
      if frec
       then
        if upper(nvl(c1rec.if_action,'FONT')) = 'FONT'
         then
          if is_rowctr and (j=1)
	   then
	    if nvl(crec.tag_style,'TABLE') = 'TABLE'
	     then
	      tablerow := tablerow || htf.tabledata( to_char(rowctr), cattributes=>c1rec.if_action_attrib );
	      gbo_tablerow := gbo_tablerow || htf.tabledata( to_char(rowctr), cattributes=>c1rec.if_action_attrib );
	    elsif crec.tag_style = 'CSV'
	     then
	      tablerow := tablerow || ',' || to_char(rowctr);
	      gbo_tablerow := gbo_tablerow || ',' || to_char(rowctr);
	    elsif crec.tag_style = 'XML'
	     then
	      tablerow := tablerow || '<ROWCTR>' || to_char(rowctr) || '</ROWCTR>' || LINEFEED;
	      gbo_tablerow := gbo_tablerow || '<ROWCTR>' || to_char(rowctr) || '</ROWCTR>' || LINEFEED;
	    end if;
            -- clob_append( htf.tabledata( to_char(rowctr), cattributes=>c1rec.if_action_attrib ) );
          end if;
          if desc_t(j).col_schema_name = '~'
           then
            null;
           else
            if nvl(crec.tag_style,'TABLE') = 'TABLE'
             then
              tablerow := tablerow || htf.tabledata( tmpval, cattributes=>c1rec.if_action_attrib );
              gbo_tablerow := gbo_tablerow || htf.tabledata( tmpval, cattributes=>c1rec.if_action_attrib );
	    elsif crec.tag_style = 'CSV'
	     then
              tablerow := tablerow || ',' || '"' || replace(tmpval,'"','''') || '"';
              gbo_tablerow := gbo_tablerow  || ',' || '"' || replace(tmpval,'"','''') || '"';
	    elsif crec.tag_style = 'XML'
	     then
	      tablerow := tablerow || '<' || desc_t(j).col_name || '>' || xmlconv(tmpval) || '</' || desc_t(j).col_name || '>' || LINEFEED;
              gbo_tablerow := gbo_tablerow  || '<' || desc_t(j).col_name || '>' || xmlconv(tmpval) || '</' || desc_t(j).col_name || '>' || LINEFEED;
             else
              tablerow := tablerow || tmpval;
              gbo_tablerow := gbo_tablerow || tmpval;
            end if;
            -- clob_append( htf.tabledata( tmpval, cattributes=>c1rec.if_action_attrib ) );
          end if;
        end if;

       else

step := 'Xd';
        open c3( sqlrec.tag_id, upper(desc_t(j).col_name) );
        fetch c3 into c3rec;
        if c3%FOUND
         then

step := 'Xd1';
          if c3rec.tag_mask is not null
           then
            if desc_t(j).col_type = 2 and upper(c3rec.tag_mask) <> 'UMO_ID'
             then
              tmpval := to_char(to_number(replace(replace(tmpval,htf.nl,null),',',null)),c3rec.tag_mask);
            elsif desc_t(j).col_type = 2 and upper(c3rec.tag_mask) = 'UMO_ID'
             then
              open c8( to_number(tmpval) );
              fetch c8 into c8rec;
              close c8;
              tmpval := htf.anchor(
              'ump.retrieve_uma?surl=' || GBL_SURL || '&parm1=UMO_ID&parm2=' || c8rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=IMAGENW&parm1=DISPLAY_WHAT&parm2=MASTER'  || '&parm1=VERSION&parm2=' || c8rec.version || '&parm1=LOGIN_TYPE&parm2=' || GBL_LTYPE || '&parm1=AID&parm2=' || to_char(c8rec.aid),
              '<IMG BORDER=0 WIDTH=' || c8rec.photo_thumbnail.width || ' HEIGHT=' || c8rec.photo_thumbnail.height || ' SRC="' ||
              'ump.retrieve_uma?surl=' || GBL_SURL || '&parm1=UMO_ID&parm2=' || c8rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL'  || '&parm1=VERSION&parm2=' || c8rec.version||
                '&parm1=LOGIN_TYPE&parm2=' || GBL_LTYPE || '&parm1=AID&parm2=' || to_char(c8rec.aid) || '" ' ||
	      'ALT="' || c8rec.extras.photo_name || '">');
            elsif desc_t(j).col_type = 12
             then
              tmpval := to_char(to_date(replace(tmpval,htf.nl,null),LNG.TSMASK),c3rec.tag_mask);
            elsif desc_t(j).col_type in (1,96)
             then
              if upper(c3rec.tag_mask) = 'BOLD'
               then
                tmpval := htf.bold( tmpval );
              elsif upper(c3rec.tag_mask) = 'ITALIC'
               then
                tmpval := htf.italic( tmpval );
              else
               begin
                if instr(tmpval,htf.nl) = 0
                 then
                  tmpval := replace(tmpval,',',null);
                 else
                  tmpval := to_char(to_number(replace(replace(tmpval,htf.nl,null),',',null)),c3rec.tag_mask) ||
                            substr(tmpval,instr(tmpval,htf.nl));
                 end if;
                exception when others then null;
               end;
              end if;
            end if;
          end if;

step := 'Xd2';
          if c3rec.break_on is not null
           then
            if break_on.exists(j)
             then
              if break_on(j) is not null and break_on(j) = tmpval
               then
                tmpval := '&nbsp;';
               else
                break_on(j) := tmpval;
              end if;
             else
              break_on(j) := tmpval;
            end if;
          end if;

          if c3rec.lock_cell is not null
           then
            lockcell := TRUE;
            currlock := tmpval;
          end if;

          if c3rec.group_break_on is not null
           then
            currgbo := currgbo || tmpval;
          end if;

step := 'Xd3';
          if c3rec.tag_cell_alt is not null
           then
            if mod(rowctr,2) = 1
             then
              if is_rowctr and (j=1)
	       then
                if nvl(crec.tag_style,'TABLE') = 'TABLE'
                 then
	          tablerow := tablerow || htf.tabledata( to_char(rowctr), cattributes=>c3rec.tag_cell );
	          gbo_tablerow := gbo_tablerow || htf.tabledata( to_char(rowctr), cattributes=>c3rec.tag_cell );
                elsif crec.tag_style = 'CSV'
                 then
	          tablerow := tablerow || ',' || to_char(rowctr);
	          gbo_tablerow := gbo_tablerow || ',' || to_char(rowctr);
                elsif crec.tag_style = 'XML'
                 then
	          tablerow := tablerow || '<ROWCTR>' || to_char(rowctr) || '</ROWCTR>' || LINEFEED;
	          gbo_tablerow := gbo_tablerow || '<ROWCTR>' || to_char(rowctr) || '</ROWCTR>' || LINEFEED;
	        end if;
                -- clob_append( htf.tabledata( to_char(rowctr), cattributes=>c3rec.tag_cell ) );
              end if;
              if desc_t(j).col_schema_name = '~'
               then
                 null;
               else
                 if c3rec.group_break_on is not null
                  then
                   gbo_tablerow := gbo_tablerow || htf.tabledata( '&nbsp;', cattributes=>c3rec.tag_cell );
                  else
                   if nvl(crec.tag_style,'TABLE') = 'TABLE'
                    then
                     gbo_tablerow := gbo_tablerow || htf.tabledata( tmpval, cattributes=>c3rec.tag_cell );
                   elsif crec.tag_style = 'CSV'
                    then
                     gbo_tablerow := gbo_tablerow || ',' || '"' || replace(tmpval,'"','''') || '"';
                   elsif crec.tag_style = 'XML'
                    then
                     gbo_tablerow := gbo_tablerow || '<' || desc_t(j).col_name || '>' || xmlconv(tmpval) || '</' || desc_t(j).col_name || '>' || LINEFEED;
                    else
                     gbo_tablerow := gbo_tablerow || tmpval;
                   end if;
                 end if;
                 if nvl(crec.tag_style,'TABLE') = 'TABLE'
                  then
                   tablerow := tablerow || htf.tabledata( tmpval, cattributes=>c3rec.tag_cell );
                   elsif crec.tag_style = 'CSV'
                    then
                     tablerow := tablerow || ',' || '"' || replace(tmpval,'"','''') || '"';
                   elsif crec.tag_style = 'XML'
                    then
                     tablerow := tablerow || '<' || desc_t(j).col_name || '>' || xmlconv(tmpval) || '</' || desc_t(j).col_name || '>' || LINEFEED;
                  else
                   tablerow := tablerow || tmpval;
                 end if;
                 -- clob_append( htf.tabledata( tmpval, cattributes=>c3rec.tag_cell ) );
              end if;
             else
              if is_rowctr and (j=1)
	       then
                tablerow := tablerow || htf.tabledata( to_char(rowctr), cattributes=>c3rec.tag_cell_alt );
                gbo_tablerow := gbo_tablerow || htf.tabledata( to_char(rowctr), cattributes=>c3rec.tag_cell_alt );
                -- clob_append( htf.tabledata( to_char(rowctr), cattributes=>c3rec.tag_cell_alt ) );
              end if;
step := 'Xd4';
              if desc_t(j).col_schema_name = '~'
               then
                 null;
               else
                 if c3rec.group_break_on is not null
                  then
                   gbo_tablerow := gbo_tablerow || htf.tabledata( '&nbsp;', cattributes=>c3rec.tag_cell_alt );
                  else
                   if nvl(crec.tag_style,'TABLE') = 'TABLE'
                    then
                     gbo_tablerow := gbo_tablerow || htf.tabledata( tmpval, cattributes=>c3rec.tag_cell_alt );
                   elsif crec.tag_style = 'CSV'
                    then
                     gbo_tablerow := gbo_tablerow || ',' || '"' || replace(tmpval,'"','''') || '"';
                   elsif crec.tag_style = 'XML'
                    then
                     gbo_tablerow := gbo_tablerow  || '<' || desc_t(j).col_name || '>' || xmlconv(tmpval) || '</' || desc_t(j).col_name || '>' || LINEFEED;
                    else
                     gbo_tablerow := gbo_tablerow || tmpval;
                   end if;
                 end if;
                 if nvl(crec.tag_style,'TABLE') = 'TABLE'
                  then
                   tablerow := tablerow || htf.tabledata( tmpval, cattributes=>c3rec.tag_cell_alt );
                   elsif crec.tag_style = 'CSV'
                    then
                      tablerow := tablerow || ',' || '"' || replace(tmpval,'"','''') || '"';
                   elsif crec.tag_style = 'XML'
                    then
                      tablerow := tablerow || '<' || desc_t(j).col_name || '>' || xmlconv(tmpval) || '</' || desc_t(j).col_name || '>' || LINEFEED;
                  else
                   tablerow := tablerow || tmpval;
                 end if;
                -- clob_append( htf.tabledata( tmpval, cattributes=>c3rec.tag_cell_alt ) );
              end if;
            end if;
           else
step := 'Xd5';
            if is_rowctr and (j=1)
	     then
                 if nvl(crec.tag_style,'TABLE') = 'TABLE'
                  then
  	           tablerow := tablerow || htf.tabledata( to_char(rowctr), cattributes=>c3rec.tag_cell );
	           gbo_tablerow := gbo_tablerow || htf.tabledata( to_char(rowctr), cattributes=>c3rec.tag_cell );
                elsif crec.tag_style = 'CSV'
                 then
	          tablerow := tablerow || ',' || to_char(rowctr);
	          gbo_tablerow := gbo_tablerow || ',' || to_char(rowctr);
                elsif crec.tag_style = 'XML'
                 then
  	          tablerow := tablerow || '<ROWCTR>' || to_char(rowctr) || '</ROWCTR>' || LINEFEED;
	          gbo_tablerow := gbo_tablerow || '<ROWCTR>' || to_char(rowctr) || '</ROWCTR>' || LINEFEED;
	         end if;
              -- clob_append( htf.tabledata( to_char(rowctr), cattributes=>c3rec.tag_cell ) );
            end if;
step := 'Xd6';
            if desc_t(j).col_schema_name = '~'
             then
               null;
             else
                 if c3rec.group_break_on is not null
                  then
                   gbo_tablerow := gbo_tablerow || htf.tabledata( '&nbsp;', cattributes=>c3rec.tag_cell );
                  else
                   gbo_tablerow := gbo_tablerow || htf.tabledata( tmpval, cattributes=>c3rec.tag_cell ) ;
                 end if;
                 if nvl(crec.tag_style,'TABLE') = 'TABLE'
                  then
                   tablerow := tablerow || htf.tabledata( tmpval, cattributes=>c3rec.tag_cell ) ;
                  elsif crec.tag_style = 'CSV'
                   then
                    tablerow := tablerow || ',' || '"' || replace(tmpval,'"','''') || '"';
                  elsif crec.tag_style = 'XML'
                   then
                    tablerow := tablerow || '<' || desc_t(j).col_name || '>' || xmlconv(tmpval) || '</' || desc_t(j).col_name || '>' || LINEFEED;
                  else
                   tablerow := tablerow || tmpval;
                 end if;
              -- clob_append( htf.tabledata( tmpval, cattributes=>c3rec.tag_cell ) );
            end if;
          end if;

         else
step := 'Xd7';
          if is_rowctr and (j=1)
	   then
	    tablerow := tablerow || htf.tabledata( to_char(rowctr) );
	    gbo_tablerow := gbo_tablerow || htf.tabledata( to_char(rowctr) );
            -- clob_append( htf.tabledata( to_char(rowctr) ) );
          end if;
          step := 'Xd7a:' || desc_t(j).col_schema_name;
          if desc_t(j).col_schema_name = '~'
           then
            null;
           else
            step := 'Xd7a2:' || length( gbo_tablerow ) || '-' || length(tmpval);
            -- xxx group_break_on is null
            begin
            if c3rec.group_break_on is not null
             then
               gbo_tablerow := gbo_tablerow || htf.tabledata( '&nbsp;' );
             else
               gbo_tablerow := gbo_tablerow || htf.tabledata( tmpval );
            end if;
            exception when others then null;
            end;

            step := 'Xd7b';

            if nvl(crec.tag_style,'TABLE') = 'TABLE'
             then
              begin
               tablerow := tablerow || htf.tabledata( tmpval );
              exception
               when others then
                clob_append( tablerow );
                tablerow := htf.tabledata( tmpval );
              end;
             elsif crec.tag_style = 'CSV'
             then
              tablerow := tablerow || ',' || '"' || replace(tmpval,'"','''') || '"';
             elsif crec.tag_style = 'XML'
             then
              tablerow := tablerow || '<' || desc_t(j).col_name || '>' || xmlconv(tmpval) || '</' || desc_t(j).col_name || '>' || LINEFEED;
             else
              begin
               tablerow := tablerow || tmpval;
              exception
               when others then
                clob_append( tablerow );
                tablerow := tmpval;
              end;
            end if;
            step := 'Xd7c';
            -- clob_append( htf.tabledata( tmpval ) );
          end if;
        end if;
        close c3;
      end if;

step := 'Xe';
      if any_sum
       then
        open c2( sqlrec.tag_id, upper(desc_t(j).col_name)  );
        fetch c2 into c2rec;
        if c2%FOUND
         then
          if summ.exists( j )
           then
            begin summ(j) := summ(j) + nvl(to_number( replace(replace(tmpval,htf.nl,null),',',null) ),0); exception when others then begin summ(j) := summ(j) + nvl(to_number( replace(tmpval,htf.nl,null),LNG.MONEY_FORMAT ),0); exception when others then null; end; end;
            if c2rec.tag_mask is null
             then
              summ_f(j) := to_char(summ(j));
             else
              summ_f(j) := to_char(summ(j),c2rec.tag_mask);
            end if;
           else
            begin summ(j) := nvl(to_number( replace(replace(tmpval,htf.nl,null),',',null) ),0); exception when others then begin summ(j) := nvl(to_number( replace(tmpval,htf.nl,null),LNG.MONEY_FORMAT ),0); exception when others then summ(j) := 0; end; end;
            if c2rec.tag_mask is null
             then
              summ_f(j) := to_char(summ(j));
             else
              summ_f(j) := to_char(summ(j),c2rec.tag_mask);
            end if;
            sum_cell(j) := c2rec.cell_details;
          end if;
        end if;
        close c2;
      end if;

      if (crec.tag_type = 'ONE_TO_MANY') and (sqlrec2.tag_id is not null) -- And there is a second SQL statement to run.
       then
        parm1(j) := upper(desc_t(j).col_name);
        parm2(j) := tmpval;
      end if;

     end loop; -- End JRow

step := 'Xf';
     -- One to Many Report
     if (crec.tag_type = 'ONE_TO_MANY') and (sqlrec2.tag_id is not null)
      then
       if (lastgbo = currgbo) and (lastgbo is not null)
        then
         if nvl(crec.tag_style,'TABLE') in ('TABLE','NOTABLE','XML') then clob_append( gbo_tablerow ); elsif crec.tag_style = 'CSV' then clob_append( substr(gbo_tablerow,2)); end if;
        else
         if nvl(crec.tag_style,'TABLE') in ('TABLE','NOTABLE','XML') then clob_append( tablerow ); elsif crec.tag_style = 'CSV' then clob_append( substr(tablerow,2)); end if;
       end if;
       if nvl(crec.tag_style,'TABLE') in ('TABLE','NOTABLE')
        then
         clob_append( htf.tablerowclose );
         clob_append( htf.tableclose );
        elsif crec.tag_style = 'CSV'
         then
          clob_append( LINEFEED );
        elsif crec.tag_style = 'XML'
         then
          clob_append( '</ROWSET>' );
       end if;
       if sqlrec.linefeed is not null
        then
         begin
          for j in 1..to_number(sqlrec.linefeed) loop
           clob_append( htf.nl );
          end loop;
         exception
          when others then null;
         end;
       end if;
       nxt_sqlrec := sqlrec2;
       emp_sqlrec.tag_id := NULL;
       substitute_parameters2( nxt_sqlrec.tag_value || nxt_sqlrec.tag_value2, nxt_sqlrec.tag_value, nxt_sqlrec.tag_value2, parm1, parm2 );
       child_record_exists2 := FALSE;
       piction_report_sql( acid, crec, nxt_sqlrec, emp_sqlrec, child_record_exists2 );
        if not child_record_exists2 then display_the_header; end if;  
       -- Be careful the above line removes subsequent table open commands from one to many reports
       if not child_record_exists2 and nvl(crec.tag_style,'TABLE') = 'TABLE'
        then
        display_the_header; -- DAVID BANJO added on 30/6/2020 
         clob_trim_header;
        else  -- added for testing purposes
         display_the_header;
       end if;

      else

       -- merge if lock cell
       if (lastgbo = currgbo) and (lastgbo is not null)
        then
         if lockcell
          then
           if lastlock = currlock
            then
             curr_lockrow := merge_tablerows( curr_lockrow, gbo_tablerow );
            else
             if curr_lockrow is not null and lastlock is not null
              then
               if nvl(crec.tag_style,'TABLE') in ('TABLE','NOTABLE') then clob_append( curr_lockrow ); clob_append( htf.tablerowclose ); clob_append( htf.tablerowopen ); elsif crec.tag_style = 'CSV' then clob_append( substr(curr_lockrow,2) || LINEFEED ); elsif crec.tag_style = 'XML' then clob_append( '</ROWSET>' || LINEFEED ); end if;
              else
               if lastlock is not null
                then
                 if nvl(crec.tag_style,'TABLE') in ('TABLE','NOTABLE') then clob_append( gbo_tablerow ); elsif crec.tag_style = 'CSV' then clob_append( substr(gbo_tablerow,2)); elsif crec.tag_style = 'XML' then clob_append( substr(gbo_tablerow,1)); end if;
               end if;
             end if;
             curr_lockrow := gbo_tablerow;
           end if;
           lastlock := currlock;
          else
           if nvl(crec.tag_style,'TABLE') in ('TABLE','NOTABLE') then clob_append( gbo_tablerow ); elsif crec.tag_style = 'CSV' then clob_append( substr(gbo_tablerow,2)); elsif crec.tag_style = 'XML' then clob_append( substr(gbo_tablerow,1)); end if;
         end if;
        else
         if lockcell
          then
           if lastlock = currlock
            then
             curr_lockrow := merge_tablerows( curr_lockrow, tablerow );
            else
             if curr_lockrow is not null and lastlock is not null
              then
                if nvl(crec.tag_style,'TABLE') in ('TABLE','NOTABLE') then clob_append( curr_lockrow ); clob_append( htf.tablerowclose ); clob_append( htf.tablerowopen ); elsif crec.tag_style = 'CSV' then clob_append( substr(curr_lockrow,2) || LINEFEED ); elsif crec.tag_style = 'XML' then clob_append( '</ROWSET>' || LINEFEED ); end if;
              else
               if lastlock is not null
                then
                 if nvl(crec.tag_style,'TABLE') in ('TABLE','NOTABLE') then clob_append( tablerow ); elsif crec.tag_style = 'CSV' then clob_append( substr(tablerow,2)); elsif crec.tag_style = 'XML' then clob_append( substr(tablerow,1)); end if;
               end if;
              end if;
             curr_lockrow := tablerow;
           end if;
           lastlock := currlock;
          else
           if nvl(crec.tag_style,'TABLE') in ('TABLE','NOTABLE') then clob_append( tablerow ); elsif crec.tag_style = 'CSV' then clob_append( substr(tablerow,2)); elsif crec.tag_style = 'XML' then clob_append( substr(tablerow,1)); end if;
         end if;
       end if;
       if nvl(crec.tag_style,'TABLE') in ('TABLE','NOTABLE')
        then
          clob_append( htf.tablerowclose );
       elsif crec.tag_style = 'CSV'
        then
          clob_append( LINEFEED );
       elsif crec.tag_style = 'XML'
        then
          clob_append( '</ROWSET>' || LINEFEED );
       end if;
      if lockcell then clob_trim_emptyrow; end if; -- cleanup non rows

     end if;

   else
    exit;
   end if;

   lastgbo := currgbo;
   currgbo := NULL;
  end loop; -- End Mainloop

  dbms_sql.close_cursor( cursor_name );
step := 'Xf';

  -- Fixes missing last row and duplicate last row
  if (crec.tag_type = 'ONE_TO_MANY') and (sqlrec2.tag_id is not null) and not child_record_exists2
   then
    if (lastgbo = currgbo) and (lastgbo is not null)
     then
      clob_append( gbo_tablerow );
      if nvl(crec.tag_style,'TABLE') in ('TABLE','NOTABLE') then clob_append( gbo_tablerow ); elsif crec.tag_style = 'CSV' then clob_append( substr(gbo_tablerow,2)); elsif crec.tag_style = 'XML' then clob_append( substr(gbo_tablerow,1)); end if;
     else
      clob_append( tablerow );
      if nvl(crec.tag_style,'TABLE') in ('TABLE','NOTABLE') then clob_append( tablerow ); elsif crec.tag_style = 'CSV' then clob_append( substr(tablerow,2)); elsif crec.tag_style = 'XML' then clob_append( substr(tablerow,1)); end if;
    end if;
       if nvl(crec.tag_style,'TABLE') in ('TABLE','NOTABLE')
        then
         clob_append( htf.tablerowclose );
         clob_append( htf.tableclose );
       elsif crec.tag_style = 'CSV'
        then
          clob_append( LINEFEED );
       elsif crec.tag_style = 'XML'
        then
          clob_append( '</ROWSET>' || LINEFEED );
       end if;
    if sqlrec.linefeed is not null
     then
      begin
       for j in 1..to_number(sqlrec.linefeed) loop
        clob_append( htf.nl );
       end loop;
      exception
       when others then null;
      end;
    end if;
    nxt_sqlrec := sqlrec2;
    emp_sqlrec.tag_id := NULL;
    substitute_parameters2( nxt_sqlrec.tag_value || nxt_sqlrec.tag_value2, nxt_sqlrec.tag_value, nxt_sqlrec.tag_value2, parm1, parm2 );
    child_record_exists2 := FALSE;
    piction_report_sql( acid, crec, nxt_sqlrec, emp_sqlrec, child_record_exists2 );
    --if not child_record_exists2 then display_the_header; end if;
    -- Be careful the above line removes subsequent table open commands from one to many reports
    if not child_record_exists2 and nvl(crec.tag_style,'TABLE') = 'TABLE'
     then
      clob_trim_header;
     else -- added for testing purposes
      display_the_header;
    end if;
  end if;


  if lockcell then clob_append( curr_lockrow ); clob_append( htf.tablerowclose ); clob_trim_emptyrow; end if;

step := 'Xg';

  if any_sum
   then
    clob_append( htf.tablerowopen );
    for j in 1..col_count loop
     if desc_t(j).col_schema_name = '~' -- If column is not displayed then do not try and display anything.
      then
       null;
      else
       if is_rowctr and (j=1)
        then
         clob_append( htf.tabledata( '&nbsp;' ) );
       end if;
       if summ.exists( j )
        then
         clob_append( htf.tabledata( htf.bold( summ_f(j) ), cattributes=>'align="RIGHT"' || ' ' || sum_cell(j)) );
        else
         clob_append( htf.tabledata( '&nbsp;' ) );
       end if;
     end if;
    end loop;
    clob_append( htf.tablerowclose );
  end if;

  if nvl(crec.tag_style,'TABLE') = 'TABLE'
   then
    clob_append( htf.tableclose );
  elsif crec.tag_style = 'XML'
   then
    clob_append( '</REPORT>' || LINEFEED );
  end if;

  if sqlrec.linefeed is not null
   then
    begin
    for j in 1..to_number(sqlrec.linefeed) loop
     clob_append( htf.nl );
    end loop;
    exception
     when others then null;
    end;
  end if;

step := 'Xh';
  if rowctr = 0 and no_row_message is not null
   then
    no_row_message := replace( no_row_message, '&lt;','<' );
    no_row_message := replace( no_row_message, '&gt;','>' );
    no_row_message := replace( no_row_message, '&quote;','"' );
    clob_append( htf.nl || no_row_message );
  end if;

 exception when others then
  glbx.error_details( 'OLTP', 'PICTION_REPORT_SQL',null,acid,errmsg=>sqlerrm,extdet=>'Step:' || step);
       begin close c1; exception when others then null; end;
       begin close c3; exception when others then null; end;
end piction_report_sql;

 function merge_tablerows( row1 in varchar2, row2 in varchar2 )
  return varchar2
 as

  retvar	varchar2(32767);
  ctr	integer;
  x	integer;
  xend	integer;
  lastx	integer;
  y	integer;
  lasty	integer;
  yend	integer;

 begin
  if row1 is null then return(row2); end if;
  if row2 is null then return(row1); end if;
  ctr := 0;
  lastx := 1;
  lasty := 1;
  retvar := NULL;
  loop
   ctr := ctr + 1;
   x := instr(row1,'</TD>',1,ctr);
   y := instr(row2,'</TD>',1,ctr);
   yend := instr(row2,'>',lasty) - lasty;
   if x = 0 or y = 0 then exit; end if;
   if substr(row2,lasty+yend+1,(y-(lasty+yend+1))) is null
    then
     retvar := retvar || substr(row1,lastx,(x-lastx)) || '</TD>';
    else
     retvar := retvar || substr(row1,lastx,(x-lastx)) || htf.nl || substr(row2,lasty+yend+1,(y-(lasty+yend+1))) || '</TD>';
   end if;
   lastx := x+5;
   lasty := y+5;
  end loop;
  return( retvar );

 exception
  when others then return( 'Error on Merge:' || row2 );
 end merge_tablerows;

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

procedure display_reports( surl in varchar2, rnd in varchar2 default null )
 as

 cursor c2( scn_nme varchar2 ) is
  select usc.umo_scene_id, usc.title, usc.parent_scene
  from umo_scene usc
  where usc.category = scn_nme and
        usc.parent_scene is null
  order by usc.order_by;

 cursor c3( acid integer, uscid integer ) is
  select distinct rd.report_id, rd.report_name
  from report_definition rd, report_roles rr, customer_roles cr
  where rd.umo_scene_id = uscid and
        rd.report_id = rr.report_id and
        cr.role_id = rr.role_id and
        cr.aid = acid
  order by rd.report_name;

 crec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 foundrec	boolean;

 procedure subcat( scn_nme varchar2, acid in integer, uscid integer, dpth integer )
 as
  cursor c2(scn_nme varchar2, uscid integer) is
  select distinct usc.umo_scene_id, usc.title, usc.order_by
  from umo_scene usc
  where usc.category = scn_nme and
        usc.parent_scene = uscid
  order by order_by;

 begin
  for c2rec in c2(scn_nme, uscid) loop
  htp.tablerowopen;
   htp.tabledata( lpad('.', dpth * 3,'.') || c2rec.title );
   htp.tabledata( '&nbsp;' );
   htp.tabledata( '&nbsp;' );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  for c3rec in c3(acid, c2rec.umo_scene_id) loop
   htp.tablerowopen;
    htp.tabledata( '&nbsp;' );
    htp.tabledata( htf.bold('<DIV STYLE="font-family: monospace">' || rpad(c3rec.report_name,50,'.') || '</DIV>') );
    htp.tabledata( htf.anchor( 'oltp.run_report?surl=' || glbx.rndsurl(surl) || '&repid=' || c3rec.report_id || '&lvl=0&p0=&p1=&ptype=', '[' || LNG2.PFM_TXT_120 || ']' ) );
    htp.tabledata( htf.anchor( 'oltp.view_report?surl=' || glbx.rndsurl(surl) || '&repid=' || c3rec.report_id, '[' || LNG2.PFM_TXT_149 || ']' ) );
   htp.tablerowclose;
  end loop;
  subcat( scn_nme, acid, c2rec.umo_scene_id, dpth + 1 );
  end loop;
 end subcat;


 begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'OLTP.DISPLAY_REPORTS', ignore_cookie_check=>TRUE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 crec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( crec.theme_name );

 glbx.main_title( surl, LNG2.PFM_TXT_119,glbx.backimg(surl,crec.aid,pfx.text_back,crec.background_img,ltype),helpid=>'T01',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.anchor( 'oltp.view_report?surl=' || SURL, LNG4.AHC_TXT_355 );
 htp.nl;
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
 foundrec := FALSE;
  for c2rec in c2(nvl(crec.reporting_category,crec.scene_name)) loop
  htp.tablerowopen;
   htp.tabledata( c2rec.title );
   htp.tabledata( '&nbsp;' );
   htp.tabledata( '&nbsp;' );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  for c3rec in c3(owner_id, c2rec.umo_scene_id) loop
   htp.tablerowopen;
    htp.tabledata( '&nbsp;' );
    htp.tabledata( htf.bold('<DIV STYLE="font-family: monospace">' || rpad(c3rec.report_name,50,'.') || '</DIV>') );
    htp.tabledata( htf.anchor( 'oltp.run_report?surl=' || glbx.rndsurl(surl) || '&repid=' || c3rec.report_id || '&lvl=0&p0=&p1=&ptype=', '[' || LNG2.PFM_TXT_120 || ']' ) );
    htp.tabledata( htf.anchor( 'oltp.view_report?surl=' || glbx.rndsurl(surl) || '&repid=' || c3rec.report_id, '[' || LNG2.PFM_TXT_149 || ']' ) );
   htp.tablerowclose;
  end loop;
  subcat( crec.scene_name, owner_id, c2rec.umo_scene_id, 1 );
  end loop;
  htp.tableclose;
  -- if not foundrec then glbx.header_msg( LNG2.FNM_TXT_168 ); end if;
 htp.p( '</CENTER>' );
 exception when others then
  glbx.error_details( 'OLTP', 'DISPLAY_REPORTS',null,owner_id,errmsg=>sqlerrm);
end display_reports;

procedure lov_sql( acid in integer, p1 in varchar2 )
 as

   cursor_name		integer;
   col_count		integer;
   desc_t		dbms_sql.desc_tab;
   common_nmb		number;
   common_vc2		varchar2(4000);
   common_dte		date;
   dummy		integer;
   foundrec		boolean;
   tmpval		varchar2(4000);
   lov_value1		varchar2(4000);
   lov_value2		varchar2(4000);

 begin
   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, restrict_sqlstmt(acid,p1), dbms_sql.native );
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
   foundrec := FALSE;
  loop
   dummy := dbms_sql.fetch_rows( cursor_name );
   if dummy > 0
    then
     foundrec := TRUE;
     lov_value1 := NULL;
     lov_value2 := NULL;
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
      if j = 1 then lov_value1 := rtrim( tmpval ); end if;
      if j = 2 then lov_value2 := rtrim( tmpval ); end if;
     end loop;
     if lov_value2 is null
      then
       htp.formselectoption( lov_value1 );
      else
       htp.formselectoption(lov_value1, cattributes=>'VALUE="' || lov_value2 || '"');
     end if;
    else
     exit;
   end if;
  end loop;
  dbms_sql.close_cursor( cursor_name );
  if not foundrec then htp.formselectoption( NULL, cattributes=>'VALUE="0"' ); end if;

 exception when others then
  glbx.error_details( 'OLTP', 'DISPLAY_SCREEN',null,acid,errmsg=>sqlerrm);
end lov_sql;

function check_run_report( do_not_run_if_zero_stmt in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, rval in integer )
 return varchar2
as
 stmt	varchar2(4000);
 res	varchar2(1000);
begin
 if do_not_run_if_zero_stmt is null then return( 'CHECKED' ); end if;
 stmt := do_not_run_if_zero_stmt;
 stmt := replace( stmt, '<PICTION_PARAMETER=RANGE_FROM>', rval );
 stmt := replace( stmt, '<PP=RANGE_FROM>', rval );
 substitute_parameters( stmt, p0, p1 );

 if upper(substr(stmt,1,6)) = 'SELECT'
  then
   execute immediate stmt into res;
  else
   execute immediate 'begin :res := ' || stmt || '; end;'
    using in out res;
 end if;

 if res = '0'
  then
   return( NULL );
  else
   return( 'CHECKED' );
 end if;
exception
 when others then return( 'CHECKED' );
end check_run_report;

procedure run_report( surl in varchar2, repid in integer, lvl in integer default 0, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, ptype in GLBX.MYARRAY )
 as

 cursor c2( repid integer ) is select * from report_definition where report_id = repid;
 cursor c3( repid integer, lvl integer ) is select * from report_parameters where report_id = repid and nvl(parameter_level,0) = lvl order by order_by;
 cursor c4( repid integer ) is select associated_id, report_name, do_not_run_if_zero_stmt from report_associated ra, report_definition rd where associated_id = rd.report_id and ra.report_id = repid;
 cursor c5( repid integer, lvl integer ) is select count('x') from report_parameters where report_id = repid and nvl(parameter_level,0) = lvl;
 cursor c7 is select role_id, role_name, role_type from piction_roles where role_type in ('REPORT','SECURITY ROLE') order by role_name;

 crec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 cntr		integer;
 sts		varchar2(100);
 prm		varchar2(100);
 wclause	varchar2(32767);
 pfx		THEME%ROWTYPE;
 pvalue		varchar2(4000);
 abort		boolean;
 chk		varchar2(100);
 np0		GLBX.MYARRAY;
 np1		GLBX.MYARRAY;
 nptype		GLBX.MYARRAY;

 function r_exists( repid integer, lvl integer )
  return boolean
 as
  cursor c3( repid integer, lvl integer ) is select count('x') tot from report_parameters where parameter_type = LNG4.AHC_TXT_109 and report_id = repid and nvl(parameter_level,0) = lvl;
  c3rec  c3%ROWTYPE;
 begin
  open c3(repid, lvl);
  fetch c3 into c3rec;
  close c3;
  if c3rec.tot = 0 then return( FALSE ); else return( TRUE ); end if;
 end r_exists;

 procedure dispday(tdate in date default sysdate)
 as
 begin
   htp.formselectopen( 'PARM_DD' );
   for j in 1..31 loop
    if to_number(to_char(tdate,'DD')) = j
     then
      htp.formselectoption( to_char(j), 'SELECTED' );
     else
      htp.formselectoption( to_char(j) );
    end if;
   end loop;
   htp.formselectclose;
 end;

 procedure dispmonth(tdate in date default sysdate)
 as
 begin
   htp.formselectopen( 'PARM_MM' );
   if to_number(to_char(tdate,'MM')) = 1 then htp.formselectoption( LNG.LAB_TXT_073, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_073 ); end if;
   if to_number(to_char(tdate,'MM')) = 2 then htp.formselectoption( LNG.LAB_TXT_074, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_074 ); end if;
   if to_number(to_char(tdate,'MM')) = 3 then htp.formselectoption( LNG.LAB_TXT_075, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_075 ); end if;
   if to_number(to_char(tdate,'MM')) = 4 then htp.formselectoption( LNG.LAB_TXT_076, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_076 ); end if;
   if to_number(to_char(tdate,'MM')) = 5 then htp.formselectoption( LNG.LAB_TXT_077, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_077 ); end if;
   if to_number(to_char(tdate,'MM')) = 6 then htp.formselectoption( LNG.LAB_TXT_078, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_078 ); end if;
   if to_number(to_char(tdate,'MM')) = 7 then htp.formselectoption( LNG.LAB_TXT_079, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_079 ); end if;
   if to_number(to_char(tdate,'MM')) = 8 then htp.formselectoption( LNG.LAB_TXT_080, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_080 ); end if;
   if to_number(to_char(tdate,'MM')) = 9 then htp.formselectoption( LNG.LAB_TXT_081, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_081 ); end if;
   if to_number(to_char(tdate,'MM')) = 10 then htp.formselectoption( LNG.LAB_TXT_082, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_082 ); end if;
   if to_number(to_char(tdate,'MM')) = 11 then htp.formselectoption( LNG.LAB_TXT_083, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_083 ); end if;
   if to_number(to_char(tdate,'MM')) = 12 then htp.formselectoption( LNG.LAB_TXT_084, 'SELECTED' ); else htp.formselectoption( LNG.LAB_TXT_084 ); end if;
   htp.formselectclose;
 end;

 procedure dispyear(tdate in date default sysdate)
 as
 begin
   htp.formselectopen( 'PARM_YY' );
   for j in 2001..2020 loop
    if to_number(to_char(tdate,'YYYY')) = j
     then
      htp.formselectoption( to_char(j), 'SELECTED' );
     else
      htp.formselectoption( to_char(j) );
    end if;
   end loop;
   htp.formselectclose;
 end;

 procedure disptime(tdate in date default sysdate)
 as
 begin
   htp.formselectopen( 'PARM_HH24' );
   for j in 0..23 loop
    if to_number(to_char(tdate,'HH24')) = j
     then
      htp.formselectoption( to_char(j), 'SELECTED' );
     else
      htp.formselectoption( to_char(j) );
    end if;
   end loop;
   htp.formselectclose;
   htp.formselectopen( 'PARM_MI' );
   for j in 0..59 loop
    if to_number(to_char(tdate,'MI')) = j
     then
      htp.formselectoption( lpad(to_char(j),2,'0'), 'SELECTED' );
     else
      htp.formselectoption( lpad(to_char(j),2,'0') );
    end if;
   end loop;
   htp.formselectclose;
 end;

 begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'OLTP.RUN_REPORT', ignore_cookie_check=>TRUE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 GBL_SURL := surl;
 GBL_LTYPE := ltype;
 GBL_STYPE := stype;

 crec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( crec.theme_name );
 if lvl = 0 and p0.count = 1
  then
   populate_other_parameters_p( ltype, owner_id, np0, np1, nptype );
   run_report(surl,repid,lvl,np0,np1,nptype);
   return;
 end if;

 -- Populate the global variable containing the report
 identify_user(crec.aid);
 abort := FALSE;
 GBL_SURL := surl;

 open c2(repid);
 fetch c2 into c2rec;
 close c2;

 if c2rec.report_type = 'FORM'
  then
   form_report( surl, c2rec.report_id, c2rec.physical_location );
   return;
 end if;

 glbx.main_title( surl, LNG2.PFM_TXT_134 || '-' || c2rec.report_name,glbx.backimg(surl,crec.aid,pfx.text_back,crec.background_img,ltype),helpid=>'T02',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.bold( LNG3.ADM_TXT_867 );
 htp.nl;
 open c5(repid, lvl + 1);
 fetch c5 into cntr;
 close c5;
 if cntr > 0
  then
   htp.formopen( 'oltp.run_report' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'REPID', repid );
   htp.formhidden( 'LVL', to_char(lvl + 1) );
   if p0.exists(1)
    then
     for j in p0.first..p0.last loop
      htp.formhidden( 'P0', p0(j) );
      htp.formhidden( 'P1', p1(j) );
      htp.formhidden( 'PTYPE', ptype(j) );
     end loop;
    else
     htp.formhidden( 'P0', null );
     htp.formhidden( 'P1', null );
     htp.formhidden( 'PTYPE', null );
   end if;
  else
   htp.formopen( 'oltp.submit_report' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'REPID', repid );
   if p0.exists(1)
    then
     for j in p0.first..p0.last loop
      htp.formhidden( 'P0', p0(j) );
      htp.formhidden( 'P1', p1(j) );
      htp.formhidden( 'PTYPE', ptype(j) );
     end loop;
     for j in (p0.last)+1..p1.last loop
      htp.formhidden( 'P0', p0(p0.last) );
      htp.formhidden( 'P1', p1(j) );
      htp.formhidden( 'PTYPE', ptype(p0.last) );
     end loop;
    else
     htp.formhidden( 'P0', null );
     htp.formhidden( 'P1', null );
     htp.formhidden( 'PTYPE', null );
   end if;
 end if;

 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
 -- Display Parameters
 if p0.exists(1)
    then
     for j in p0.first..p0.last loop
     if ptype(j) = 'NO DISPLAY'
      then
       null;
      else
       if p0(j) is not null
        then
         htp.tablerowopen;
          htp.tabledata( htf.bold( p0(j) ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
          htp.tabledata( htf.bold( p1(j) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
         htp.tablerowclose;
       end if;
      end if;
      end loop;
      for j in (p0.last)+1..p1.last loop
      if ptype(j) = 'NO DISPLAY'
       then
        null;
       else
        if p1(j) is not null and p1(j) <> p1(p0.last)
         then
          htp.tablerowopen;
           htp.tabledata( htf.bold( p0(p0.last) ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
           htp.tabledata( htf.bold( p1(j) ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
          htp.tablerowclose;
         end if;
      end if;
      end loop;
 end if;

 for c3rec in c3( repid, lvl ) loop
  if c3rec.parameter_type <> 'ABORT IF COLUMN IS ZERO'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( nvl(c3rec.parameter_display_name,c3rec.parameter_name) ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  end if;
   if c3rec.parameter_type = LNG3.ADM_TXT_871
    then
     htp.tabledata( htf.formtext( 'P1', 20, 1000, c3rec.parameter_value),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
     if r_exists(repid, lvl ) then htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' ); end if;
     htp.formhidden( 'P0', c3rec.parameter_name );
     htp.formhidden( 'PTYPE', 'C' );
   elsif c3rec.parameter_type = LNG3.ADM_TXT_922
    then
     begin
      execute immediate 'select ' || c3rec.parameter_value || ' from dual' into pvalue;
     exception
      when others then pvalue := NULL;
     end;
     htp.tabledata( htf.formtext( 'P1', 20, 1000, pvalue),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
     if r_exists(repid, lvl ) then htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' ); end if;
     htp.formhidden( 'P0', c3rec.parameter_name );
     htp.formhidden( 'PTYPE', 'C' );
   elsif c3rec.parameter_type = LNG4.AHC_TXT_109 and c3rec.parameter_value is null
    then
     htp.tabledata( htf.formtext( 'P1', 20, 1000, c3rec.parameter_value) || ' (' || initcap( LNG4.AHC_TXT_109 ) || ')',cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.formhidden( 'P0', c3rec.parameter_name );
     htp.formhidden( 'PTYPE', 'RFROM' );
     htp.tabledata( htf.formtext( 'P1', 20, 1000, c3rec.parameter_value) || ' (' || initcap( LNG4.AHC_TXT_110 ) || ')',cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.formhidden( 'P0', c3rec.parameter_name );
     htp.formhidden( 'PTYPE', 'RTO' );

   elsif c3rec.parameter_type = LNG4.AHC_TXT_109 and c3rec.parameter_value is not null
    then
      htp.p('<td>' );
      htp.formselectopen( 'P1' );
      if p0.exists(1)
       then
        wclause := c3rec.parameter_value;
        substitute_parameters(wclause,p0,p1);
        lov_sql( owner_id, wclause );
       else
        lov_sql( owner_id, c3rec.parameter_value );
      end if;
      htp.formselectclose;
      htp.formhidden( 'P0', c3rec.parameter_name );
      htp.formhidden( 'PTYPE', 'RFROM' );
      htp.p( ' (' || initcap( LNG4.AHC_TXT_109 ) || ')' );
      htp.p( '</td>' );

      htp.p('<td>' );
      htp.formselectopen( 'P1' );
      if p0.exists(1)
       then
        wclause := c3rec.parameter_value;
        substitute_parameters(wclause,p0,p1);
        lov_sql( owner_id, wclause );
       else
        lov_sql( owner_id, c3rec.parameter_value );
      end if;
      htp.formselectclose;
      htp.formhidden( 'P0', c3rec.parameter_name );
      htp.formhidden( 'PTYPE', 'RTO' );
      htp.p( ' (' || initcap( LNG4.AHC_TXT_109 ) || ')' );
      htp.p( '</td>' );

   elsif c3rec.parameter_type = 'ABORT IF COLUMN IS ZERO'
    then
       wclause := c3rec.parameter_value;
       substitute_parameters(wclause,p0,p1);
       for j in ptype.first..ptype.last loop
        if ptype(j) = 'RFROM'
         then
          wclause := replace(wclause,'<PICTION_PARAMETER=RFROM>',p1(j) );
          wclause := replace(wclause,'<PP=RFROM>',p1(j) );
        elsif ptype(j) = 'RTO'
         then
          wclause := replace(wclause,'<PICTION_PARAMETER=RTO>',p1(j) );
          wclause := replace(wclause,'<PP=RTO>',p1(j) );
        elsif ptype(j) = 'MULTISQL-RANGE'
         then
             delete from report_multi_parameters;
	     for j in p1.first..p1.last loop
	      insert into report_multi_parameters values( substr(p1(j),1,1000) );
	     end loop;
        end if;
       end loop;

       begin
        execute immediate wclause into pvalue;
       exception
        -- Any Failure and the report will not run
        when others then pvalue := '0';
       end;

       if pvalue = '0'
        then
         prm := c3rec.parameter_name;
         abort := TRUE;
         exit;
       end if;

   elsif c3rec.parameter_type in (LNG3.ADM_TXT_872,LNG4.AHC_TXT_378,'MULTIPLE SQL RANGE')
    then
     htp.formhidden( 'P0', c3rec.parameter_name );
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
     if c3rec.parameter_type = LNG4.AHC_TXT_378
      then
       htp.formhidden( 'PTYPE', 'MULTISQL' );
       htp.formselectopen( 'P1', null, 5, cattributes=>'MULTIPLE' );
     elsif c3rec.parameter_type = 'MULTIPLE SQL RANGE'
      then
       htp.formhidden( 'PTYPE', 'MULTISQL-RANGE' );
       htp.formselectopen( 'P1', null, 5, cattributes=>'MULTIPLE' );
      else
       htp.formhidden( 'PTYPE', 'C' );
       htp.formselectopen( 'P1' );
     end if;
     if p0.exists(1)
      then
       wclause := c3rec.parameter_value;
       substitute_parameters(wclause,p0,p1);
       lov_sql( owner_id, wclause );
      else
       lov_sql( owner_id, c3rec.parameter_value );
     end if;
     htp.formselectclose;
     htp.p( '</TD>' );
     if r_exists(repid, lvl ) then htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' ); end if;

   elsif c3rec.parameter_type in ('Date Range')
    then
     htp.formhidden( 'P0', c3rec.parameter_name );
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
      htp.formhidden( 'PTYPE', 'C' );
      htp.formselectopen( 'P1' );
       lov_date(c3rec.parameter_value);
      htp.formselectclose;
     htp.p( '</TD>' );
     if r_exists(repid, lvl ) then htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' ); end if;

   elsif c3rec.parameter_type in ('Comma LOV')
    then
     htp.formhidden( 'P0', c3rec.parameter_name );
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
      htp.formhidden( 'PTYPE', 'C' );
      glbx.meta_lov( 'P1', 'T', c3rec.parameter_value, null );
     htp.p( '</TD>' );
     if r_exists(repid, lvl ) then htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' ); end if;

   elsif c3rec.parameter_type in ('Multiple Comma LOV')
    then
     htp.formhidden( 'P0', c3rec.parameter_name );
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
      htp.formhidden( 'PTYPE', 'MULTISQL' );
      glbx.meta_lov( 'P1', 'T', c3rec.parameter_value, null, '5' ); -- xxx Note: THis doesn't work for V5
     htp.p( '</TD>' );
     if r_exists(repid, lvl ) then htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' ); end if;

   end if;
  if c3rec.parameter_type <> 'ABORT IF COLUMN IS ZERO'
   then
    htp.tablerowclose;
  end if;
 end loop;
 htp.tableclose;
 htp.nl;

 if abort
  then
    htp.init;
    glbx.main_title( surl, 'Report is not Allowed to Run',glbx.backimg(surl,crec.aid,pfx.text_back,crec.background_img,ltype),helpid=>'T02',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
    htp.p( '<CENTER>' );
    htp.nl;
    htp.bold( prm );
    htp.htmlclose;
    return;
 end if;

 if cntr > 0
  then
   htp.formsubmit( null, LNG2.FNM_TXT_175 );
   htp.formclose;
   htp.p( '</CENTER>' );
   htp.htmlclose;
   return;
 end if;

 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
 htp.tablerowopen;
 htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
  htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
  htp.tablerowopen;
   htp.p( '<TD ALIGN="CENTER">' );
    htp.formselectopen( 'P2' );
    htp.formselectoption( NULL );
    for j in 1..365 loop
     if j = 30
      then
       htp.formselectoption( to_char(j), 'SELECTED' );
      else
       htp.formselectoption( to_char(j) );
     end if;
    end loop;
    htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( LNG2.PFM_TXT_131, cattributes=>'align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio( 'P3', '1', 'CHECKED'), cattributes=>'align="CENTER"' );
   htp.tabledata( LNG2.PFM_TXT_135, cattributes=>'align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio( 'P3', '2'), cattributes=>'align="CENTER"' );
   htp.tabledata( LNG2.PFM_TXT_132, cattributes=>'align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio( 'P3', '3'), cattributes=>'align="CENTER"' );
   htp.tabledata( LNG2.PFM_TXT_136, cattributes=>'align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio( 'P3', '4'), cattributes=>'align="CENTER"' );
   htp.tabledata( LNG2.PFM_TXT_137, cattributes=>'align="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;
 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 open c4(repid);
 fetch c4 into c4rec;
 if c4%FOUND
  then
   close c4;
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
   htp.tablerowopen;
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.bold( LNG3.ADM_TXT_912 );
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
   htp.formhidden( 'REPALSO', null );
   for c4rec in c4(repid) loop
    htp.tablerowopen;
     chk := check_run_report( c4rec.do_not_run_if_zero_stmt, p0, p1, null );
     htp.tabledata( htf.formcheckbox( 'REPALSO', c4rec.associated_id, chk ) );
     htp.tabledata( c4rec.report_name );
    htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tableclose;
   htp.nl;
  else
   htp.formhidden( 'REPALSO', null );
   close c4;
 end if;

 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
 htp.tablerowopen;
 htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="TOP" ALIGN="LEFT">' );

 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formradio( 'P4', '1', 'CHECKED' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( LNG2.PFM_TXT_121, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( '&nbsp;' );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio( 'P4', '2' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"'  );
   htp.tabledata( LNG2.PFM_TXT_122, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND  || '>' );
   dispday;
   dispmonth;
   dispyear;
   htp.p( '</TD>' );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND  || '>' );
   disptime;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio( 'P4', '3' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"'  );
   htp.tabledata( LNG2.PFM_TXT_123, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND  || '>' );
   htp.formselectopen( 'P5' );
   htp.formselectoption( LNG2.PFM_TXT_126 );
   htp.formselectoption( LNG2.PFM_TXT_127 );
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND  || '>' );
   disptime;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio( 'P4', '4' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"'  );
   htp.tabledata( LNG2.PFM_TXT_124, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND  || '>' );
   htp.formselectopen( 'P6' );
   htp.formselectoption( LNG.PHG_TXT_489 );
   htp.formselectoption( LNG.PHG_TXT_490 );
   htp.formselectoption( LNG.PHG_TXT_491 );
   htp.formselectoption( LNG.PHG_TXT_492 );
   htp.formselectoption( LNG.PHG_TXT_493 );
   htp.formselectoption( LNG.PHG_TXT_494 );
   htp.formselectoption( LNG.PHG_TXT_495 );
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND  || '>' );
   disptime;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio( 'P4', '5' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"'  );
   htp.tabledata( LNG2.PFM_TXT_125, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND  || '>' );
   htp.formselectopen( 'P7' );
   for j in 1..31 loop
    htp.formselectoption( to_char(j) );
   end loop;
   htp.formselectoption( LNG2.PFM_TXT_129 );
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND  || '>' );
   disptime;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"'  );
   htp.tabledata( LNG2.PFM_TXT_153, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND  || '>' );
   htp.formselectopen( 'P8' );
    htp.formselectoption( LNG.SLD_TXT_021, 'SELECTED', cattributes=>'VALUE=""' );
    htp.formselectoption( LNG2.PFM_TXT_160,cattributes=>'VALUE="TRUE"' );
    for c7rec in c7 loop
     htp.formselectoption( c7rec.role_name, cattributes=>'VALUE="' || to_char(c7rec.role_id) || '"' );
    end loop;
    htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"'  );
  htp.tablerowclose;
 htp.tableclose;

 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.formsubmit( null, LNG2.PFM_TXT_133 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
 exception when others then
  glbx.error_details( 'OLTP', 'RUN_REPORT',null,owner_id,errmsg=>sqlerrm);
end run_report;

procedure submit_report( surl in varchar2, repid in integer, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in varchar2, p3 in integer, p4 in integer, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2 default LNG.SLD_TXT_021,
                         parm_dd in GLBX.MYARRAY, parm_mm in GLBX.MYARRAY, parm_yy in GLBX.MYARRAY, parm_hh24 in GLBX.MYARRAY, parm_mi in GLBX.MYARRAY, repalso in GLBX.MYARRAY, ptype in GLBX.MYARRAY )
 as

 cursor c2(repid integer, assoc integer ) is
  select do_not_run_if_zero_stmt
  from report_associated
  where report_id = repid and
        associated_id = assoc;

 cursor c3( repid integer, oldrepid integer ) is
  select *
  from report_parameters
  where report_id = repid and
        parameter_name not in (select parameter_name from report_parameters where report_id = oldrepid)
  order by order_by;

 cursor c4(repdefn integer) is select * from report_definition where report_id = repdefn;

 cursor c6(ltype varchar2, acid integer) is
  select contact_mobile,billing_email,contact_email
  from customer_contact
  where (ltype = 'OWNER' and aid = acid) or
        (ltype = 'PROFILE' and aid = acid)
 union all
  select contact contact_mobile, contact_email billing_email,contact_email
  from manufacturer
  where ltype = 'MANUFACTURER' and manufacturer_id = acid
 union all
  select mobile_phone contact_mobile, contact_email billing_email,contact_email
  from photographer
  where ltype = 'PHOTOGRAPHER' and pid = acid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c6rec		c6%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 subtime	varchar2(100);
 subdate	date;
 r1		varchar2(100);
 r2		varchar2(100);
 r3		varchar2(100);
 newid		integer;
 foundrec	boolean;
 range_exists	boolean;
 multisql_exists boolean;
 f0		GLBX.MYARRAY;
 f1		rp;
 ctr		integer;
-- rfrom		integer;
-- rto		integer;
-- rval		integer;
 rfrom		number;
 rto		number;
 rval		number;
 vprecision     integer;
 lastid		integer;
 k		integer;
 chk		varchar2(100);
 stp		varchar2(100);
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

 begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, call_type=>'S', progcalled=>'OLTP.DISPLAY_REPORTS', ignore_cookie_check=>TRUE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 GBL_SURL := surl;
 GBL_LTYPE := ltype;
 GBL_STYPE := stype;

 stp := 'Step A';
 c1rec := glbx.get_aid( owner_id, 'S', ltype );
 -- Populate the global variable containing the report
 identify_user(c1rec.aid);
 DEFSECURITY := p8;

 r1 := p4;

 stp := 'Step B';
 if p4 = 1
  then
   subdate := sysdate;
 elsif p4 = 2
  then
   subdate := NULL;
   r3 := parm_dd(1) || '-' || parm_mm(1) || '-' || parm_yy(1) || ' ' || parm_hh24(1) || ':' || lpad(parm_mi(1),2,'0');
 elsif p4 = 3
  then
   r2 := p5;
   r3 := parm_hh24(2) || ':' || lpad(parm_mi(2),2,'0');
   subdate := NULL;
 elsif p4 = 4
  then
   r2 := p6;
   r3 := parm_hh24(3) || ':' || lpad(parm_mi(3),2,'0');
   subdate := NULL;
 elsif p4 = 5
  then
   r2 := p7;
   r3 := parm_hh24(4) || ':' || lpad(parm_mi(4),2,'0');
   subdate := NULL;
 end if;

 stp := 'Step C';
 range_exists := FALSE;
 multisql_exists := FALSE;
 vprecision := 0;
 for j in ptype.first..ptype.last loop
  if ptype(j) = 'RFROM'
   then
    begin rfrom := to_number(p1(j)); exception when others then rfrom := NULL; end;
  elsif ptype(j) = 'RTO'
   then
    begin rto := to_number(p1(j)); exception when others then rto := NULL; end;
    if instr(p1(j),'.') > 0
     then
      vprecision := length(p1(j)) - instr(p1(j),'.'); -- see if number is non-integer;
    end if;
    range_exists := TRUE;
  elsif ptype(j) = 'MULTISQL'
    then
      multisql_exists := TRUE;
  elsif ptype(j) = 'MULTISQL-RANGE'
    then
      k := j;
      multisql_exists := TRUE;
      range_exists := TRUE;
  end if;
 end loop;

 stp := 'Step D';
 if range_exists and not multisql_exists
  then
   if rfrom > rto then rfrom := rto; end if;
   if rfrom is null and rto is null then rfrom :=0; rto := 0; end if;
   if rfrom is null then rfrom := rto; end if;
   if rto is null then rto := rfrom; end if;
   if rto > (rfrom + 100) then rto := rfrom + 100; end if; -- In case the range is too big, too many reports are run
   rval := rfrom;
 elsif range_exists and multisql_exists
  then
   rval := nvl(k,1);
 end if;

  if rfrom is not null then dapi.GLOBAL_START_NUMBER := rfrom; end if;
  if rto is not null then dapi.GLOBAL_END_NUMBER := rto; end if;

loop

  stp := 'Step E';
  select s_report_queue_id.nextval into newid from dual;
  insert into report_queue(report_queue_id,report_id,sessid,aid,submit_time,run_every_1,run_every_2,run_every_3,priority,notification,autoexpire,status)
   values
    (newid,repid,owner_id,c1rec.aid,sysdate,r1,r2,r3,'A',p3,p2,LNG2.PFM_TXT_140);
  for j in p0.first..p0.last loop
   stp := 'Step F:' || p0(j) || '-' || ptype(j);
   begin
    if p0(j) is not null
     then
      if ptype(j) = 'RFROM'
       then
        insert into report_queue_parameters(report_queue_id,report_id,parameter_name,parameter_type,parameter_value) values
         (newid,repid,p0(j),ptype(j),to_char(rval));
      elsif ptype(j) = 'RTO'
       then
        null; -- Ignore this option
      elsif ptype(j) = 'MULTISQL-RANGE'
       then
        insert into report_queue_parameters(report_queue_id,report_id,parameter_name,parameter_type,parameter_value) values
         (newid,repid,p0(j),ptype(j),p1(rval));
      else
        insert into report_queue_parameters(report_queue_id,report_id,parameter_name,parameter_type,parameter_value) values
         (newid,repid,p0(j),ptype(j),p1(j));
      end if;
    end if;
   exception
    when others then
        insert into report_queue_parameters(report_queue_id,report_id,parameter_name,parameter_type,parameter_value) values
         (newid,repid,p0(j),ptype(j),null);
   end;
  end loop;

  stp := 'Step G';
  if multisql_exists and not range_exists
   then
    delete from report_multi_parameters;
    for j in p1.first..p1.last loop
     insert into report_multi_parameters values( substr(p1(j),1,1000) );
    end loop;
  end if;

  stp := 'Step H';
  foundrec := FALSE;
  ctr := 0;
  for j in repalso.first..repalso.last loop
   if repalso(j) is not null
    then
     if range_exists or multisql_exists
      then
       c2rec.do_not_run_if_zero_stmt := NULL;
       open c2(repid, repalso(j) );
       fetch c2 into c2rec;
       close c2;
       chk := check_run_report( c2rec.do_not_run_if_zero_stmt, p0, p1, rval );
       if not (nvl(chk,'0') = '0')
        then
         insert into report_queue_also_run(report_queue_id,report_id,associated_id) values (newid,repid,repalso(j));
       end if;
      else
       insert into report_queue_also_run(report_queue_id,report_id,associated_id) values (newid,repid,repalso(j));
     end if;
     for c3rec in c3( repalso(j), repid ) loop
      foundrec := TRUE;
      ctr := ctr + 1;
      f0(ctr) := repalso(j);
      f1(ctr) := c3rec;
     end loop;
   end if;
  end loop;

  commit;

  -- Check if more parameters need to be added
  stp := 'Step I';
  if foundrec
   then
    prompt_extra_parms( surl, c1rec.aid, ltype, stype, newid, repid, f0, f1 );
    return;
  end if;

  stp := 'Step J';
  if p4 = 1
   then
    run_the_report( newid, ltype, c1rec.aid );
  end if;

  if not range_exists then exit; end if;
  stp := 'Step K';
  if range_exists
   then
    if nvl(vprecision, 0) > 0
     then
      rval := rval + power(0.1, vprecision);
    else
      rval := rval + 1;
    end if;
    if multisql_exists
     then
      if rval > p1.last then exit; end if;
     else
      if rval > rto then exit; end if;
    end if;
  end if;

 end loop;

 if p3 = '4'  -- Email Whole Report
  then
     open c4(repid);
     fetch c4 into c4rec;
     close c4;
     open c6(ltype,c1rec.aid);
     fetch c6 into c6rec;
     close c6;
     gcode(1) := NULL;
     gparam(1) := NULL;
     --glbx.dbg('In sending');
     if nvl(c6rec.billing_email,c6rec.contact_email) is not null
      then
       if GBL_REP is null
        then
         glbx.send( gcode, gparam, 'report_' || to_char(repid) || '.html', p_to=>nvl(c6rec.billing_email,c6rec.contact_email), p_subj=>c4rec.report_name, p_from=>glbx.extract_master_parameter('MAIL_FROM'),is_report=>TRUE,ltype=>ltype,own_id=>owner_id, is_attachment=>TRUE);
        else
         --glbx.dbg( 'Sent:' || GBL_REP || '.zip' );
         glbx.send( gcode, gparam, GBL_REP || '.zip', p_to=>nvl(c6rec.billing_email,c6rec.contact_email), p_subj=>c4rec.report_name, p_from=>glbx.extract_master_parameter('MAIL_FROM'),is_report=>TRUE,ltype=>ltype,own_id=>owner_id, is_attachment=>TRUE);
       end if;
     end if;
 end if;

 stp := 'Step L';
 view_report(surl);

 exception when others then
  glbx.error_details( 'OLTP', 'SUBMIT_REPORT',null,owner_id,errmsg=>sqlerrm, extdet=>stp);
end submit_report;

procedure prompt_extra_parms( surl in varchar2, owner_id in integer, ltype in varchar2, stype in integer, rq_id in integer, repid in integer, p0 in GLBX.MYARRAY, p1 in rp )
as

 cursor c1(repid integer) is select report_name from report_definition where report_id = repid;

 c1rec		c1%ROWTYPE;
 crec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 lastid		integer;
 xltype		varchar2(100);
 pvalue		varchar2(4000);

begin
 xltype := ltype;
 crec := glbx.get_aid( owner_id, 'C', xltype );
 pfx := glbx.get_thm( crec.theme_name );
 glbx.main_title( surl, 'Extra Parameters',glbx.backimg(surl,crec.aid,pfx.text_back,crec.background_img,ltype),helpid=>'T03',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.formopen( 'oltp.extra_submit_report' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'REPID', repid );
 htp.formhidden( 'RQ_ID', rq_id );
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
 lastid := NULL;
 for j in p1.first..p1.last loop
  htp.tablerowopen;
  if lastid is null or lastid <> p0(j)
   then
    open c1(p0(j));
    fetch c1 into c1rec;
    close c1;
    htp.tabledata( htf.bold(c1rec.report_name),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
   else
    htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
  end if;
  lastid := p0(j);
   htp.tabledata( htf.bold( p1(j).parameter_name ),cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.formhidden( 'P2', p0(j) );
   if p1(j).parameter_type = LNG3.ADM_TXT_871
    then
     htp.tabledata( htf.formtext( 'P1', 20, 1000, p1(j).parameter_value),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.formhidden( 'P0', p1(j).parameter_name );
   elsif p1(j).parameter_type = LNG3.ADM_TXT_922
    then
     begin
      execute immediate 'select ' || p1(j).parameter_value || ' from dual' into pvalue;
     exception
      when others then pvalue := NULL;
     end;
     htp.tabledata( htf.formtext( 'P1', 20, 1000, pvalue),cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.formhidden( 'P0', p1(j).parameter_name );
   elsif p1(j).parameter_type = LNG4.AHC_TXT_109
    then
     htp.tabledata( htf.formtext( 'P1', 20, 1000, p1(j).parameter_value) || ' (' || initcap( LNG4.AHC_TXT_109 ) || ')',cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.formhidden( 'P0', p1(j).parameter_name );
     htp.tabledata( htf.formtext( 'P1', 20, 1000, p1(j).parameter_value) || ' (' || initcap( LNG4.AHC_TXT_110 ) || ')',cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.formhidden( 'P0', p1(j).parameter_name );
   elsif p1(j).parameter_type = LNG3.ADM_TXT_872
    then
     htp.formhidden( 'P0', p1(j).parameter_name );
     htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
     htp.formselectopen( 'P1' );
     lov_sql( owner_id, p1(j).parameter_value );
     htp.formselectclose;
     htp.p( '</TD>' );
   end if;
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG2.PFM_TXT_133 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

 exception when others then
  glbx.error_details( 'OLTP', 'PROMPT_EXTRA_PARMS',null,owner_id,errmsg=>sqlerrm);
end prompt_extra_parms;

procedure extra_submit_report( surl in varchar2, repid in integer, rq_id integer, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 cursor c2(rq_id integer) is select run_every_1 from report_queue where report_queue_id = rq_id;

 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'OLTP.EXTRA_SUBMIT_REPORT', ignore_cookie_check=>TRUE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 GBL_SURL := surl;
 GBL_LTYPE := ltype;
 GBL_STYPE := stype;
 for j in p0.first..p0.last loop
    insert into report_queue_parameters(report_queue_id,report_id,parameter_name,parameter_type,parameter_value) values
     (rq_id,p2(j),p0(j),null,p1(j));
 end loop;

 open c2(rq_id);
 fetch c2 into c2rec;
 close c2;

 if c2rec.run_every_1 = 1
  then
   run_the_report( rq_id, ltype, owner_id );
 end if;

 view_report(surl);

 exception when others then
  glbx.error_details( 'OLTP', 'EXTRA_SUBMIT_REPORT',null,owner_id,errmsg=>sqlerrm);
end extra_submit_report;

procedure view_report( surl in varchar2, repid in integer default null, sort_on in integer default 1, msg in varchar2 default null, action in varchar2 default null, search_term in varchar2 default null )
as

 cursor c1(acid integer, sort_on integer) is
  select /*+ ALL_ROWS */ rq.report_id,rq.report_queue_id,rq.submit_time,rq.run_time,rq.status,rq.aid,rd.report_name, usc.title,rq.run_every_1,rq.run_every_2,rq.run_every_3
  from report_queue rq, report_definition rd, umo_scene usc
  where rq.aid = acid and
        rq.report_id = rd.report_id and
        usc.umo_scene_id = rd.umo_scene_id
  order by decode(sort_on, 1,to_char(9999999999 - to_number(to_char(rq.submit_time,'YYYYSSSSS'))), 2,rd.report_name, 3,usc.title );

 cursor c2(acid integer, sort_on integer, repid integer, rtype varchar2, search_term varchar2) is
  select /*+ ALL_ROWS */ *
  from umo um
  where umo_type = 'REPORT' and
        aid = acid and
        ((search_term is null) or (search_term is not null and dbms_lob.instr(um.doc_html,search_term) > 0)) and
        nvl(um.extras.quality,LNG.ORD_TXT_201) = rtype and
        ((repid is null or (rtype = LNG2.FNM_TXT_021 and umo_scene_id = repid)) or
         ((repid is not null) and (umo_scene_id = (select umo_scene_id from report_definition where report_id = repid)))
        )
  order by decode(sort_on,1,to_char( ((to_number(to_char(date_created,'YYYYMMDD')))*100000 + (to_number(to_char(date_created,'SSSSS'))))), 2,um.extras.photo_name, 3,um.extras.title ) desc, um.umo_id desc;

 cursor c3(acid integer, sort_on integer, rtype varchar2, search_term varchar2) is
  select /*+ ALL_ROWS */ ca.username,um.umo_id,um.extras,um.date_created,um.expire_date,um.doc_html
  from umo um, customer_roles r, customer_account ca
  where umo_type = 'REPORT' and
        um.aid <> acid  and
        ((search_term is null) or (search_term is not null and dbms_lob.instr(um.doc_html,search_term) > 0)) and
        nvl(um.extras.quality,LNG.ORD_TXT_201) = rtype and
        ca.aid = um.aid and
        umo_scene_id = nvl(repid,umo_scene_id) and
        r.aid = acid and
        um.extras.enabled_phg = to_char(r.role_id)
 order by decode(sort_on,1,to_char(9999999999 - to_number(to_char(um.date_created,'YYYYSSSSS'))), 2,um.extras.photo_name, 3,um.extras.title );

 cursor c4(acid integer, sort_on integer, rtype varchar2, search_term varchar2) is
  select /*+ ALL_ROWS */ ca.username,um.umo_id,um.extras,um.date_created,um.expire_date,um.doc_html
  from umo um, customer_account ca
  where umo_type = 'REPORT' and
        um.aid <> acid  and
        ((search_term is null) or (search_term is not null and dbms_lob.instr(um.doc_html,search_term) > 0)) and
        nvl(um.extras.quality,LNG.ORD_TXT_201) = rtype and
        umo_scene_id = nvl(repid,umo_scene_id) and
        ca.aid = um.aid and
        um.extras.enabled_phg = 'TRUE'
 order by decode(sort_on,1,to_char(9999999999 - to_number(to_char(um.date_created,'YYYYSSSSS'))), 2,um.extras.photo_name, 3,um.extras.title );

 cursor c5(acid integer, sort_on integer, search_term varchar2) is
  select /*+ ALL_ROWS */ um.extras.title title, um.extras.orderby_scene orderby_scene, um.umo_scene_id
  from umo um
  where umo_type = 'REPORT' and
        aid = acid and
        ((search_term is null) or (search_term is not null and dbms_lob.instr(um.doc_html,search_term) > 0)) and
        nvl(um.extras.quality,LNG.ORD_TXT_201) = LNG2.FNM_TXT_021 and
        ((repid is null) or
         ((repid is not null) and (umo_scene_id = (select umo_scene_id from report_definition where report_id = repid)))
        )
  union
  select /*+ ALL_ROWS */ um.extras.title title, um.extras.orderby_scene orderby_scene, um.umo_scene_id
  from umo um, customer_roles r, customer_account ca
  where umo_type = 'REPORT' and
        um.aid <> acid  and
        ((search_term is null) or (search_term is not null and dbms_lob.instr(um.doc_html,search_term) > 0)) and
        nvl(um.extras.quality,LNG.ORD_TXT_201) = LNG2.FNM_TXT_021 and
        ca.aid = um.aid and
        r.aid = acid and
        um.extras.enabled_phg = to_char(r.role_id)
  union
  select /*+ ALL_ROWS */ um.extras.title title, um.extras.orderby_scene orderby_scene, um.umo_scene_id
  from umo um, customer_account ca
  where umo_type = 'REPORT' and
        um.aid <> acid  and
        ((search_term is null) or (search_term is not null and dbms_lob.instr(um.doc_html,search_term) > 0)) and
        nvl(um.extras.quality,LNG.ORD_TXT_201) = LNG2.FNM_TXT_021 and
        ca.aid = um.aid and
        um.extras.enabled_phg = 'TRUE'
  order by 2;

 crec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 rtype		varchar2(100);
 mp		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'OLTP.VIEW_REPORT', ignore_cookie_check=>TRUE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 GBL_SURL := surl;
 GBL_LTYPE := ltype;
 GBL_STYPE := stype;

 crec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( crec.theme_name );

 if action = 'ARCHIVE_LIST'
  then
   glbx.main_title( surl, LNG4.AHC_TXT_406,glbx.backimg(surl,crec.aid,pfx.text_back,crec.background_img,ltype),helpid=>'T04',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
   htp.nl;
   htp.p( '<CENTER>' );
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
   for c5rec in c5(owner_id, sort_on, search_term) loop
    htp.tablerowopen;
     htp.tabledata( htf.anchor( 'oltp.view_report?surl=' || surl || '&repid=' || c5rec.umo_scene_id || '&action=ARCHIVE', c5rec.title ) );
    htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.p( '</CENTER>' );
   htp.htmlclose;
   return;
 end if;
 glbx.main_title( surl, LNG2.PFM_TXT_138,glbx.backimg(surl,crec.aid,pfx.text_back,crec.background_img,ltype),helpid=>'T04',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 if action = 'ARCHIVE'
  then
   rtype := LNG2.FNM_TXT_021;
  else
   rtype := LNG.ORD_TXT_201;
 end if;
 htp.nl;
  htp.formopen( 'oltp.rep_options_but' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'P0', null );

 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 rules="NONE" frame="HSIDES,VSIDES" border=0' );
  htp.tablerowopen;
   htp.tabledata(htf.formimage( 'run_report', DECS.IMAGE_LOCATION || 'adminc/oltp_run_report.gif',cattributes=>'BORDER="0"'),cattributes=>' valign="MIDDLE" align="CENTER"');
   htp.tabledata(htf.formimage( 'purge', DECS.IMAGE_LOCATION || 'adminc/oltp_purge.gif',cattributes=>'BORDER="0"'),cattributes=>' valign="MIDDLE" align="CENTER"');
   htp.tabledata(htf.formimage( 'sort_date', DECS.IMAGE_LOCATION || 'adminc/oltp_sort_date.gif',cattributes=>'BORDER="0"'),cattributes=>' valign="MIDDLE" align="CENTER"');
   htp.tabledata(htf.formimage( 'sort_name', DECS.IMAGE_LOCATION || 'adminc/oltp_sort_name.gif',cattributes=>'BORDER="0"'),cattributes=>' valign="MIDDLE" align="CENTER"');
   htp.tabledata(htf.formimage( 'sort_category', DECS.IMAGE_LOCATION || 'adminc/oltp_sort_category.gif',cattributes=>'BORDER="0"'),cattributes=>' valign="MIDDLE" align="CENTER"');
   htp.tabledata(htf.formimage( 'display_all', DECS.IMAGE_LOCATION || 'adminc/oltp_display_all.gif',cattributes=>'BORDER="0"'),cattributes=>' valign="MIDDLE" align="CENTER"');
   if action is null
    then
      htp.tabledata(htf.formimage( 'archive', DECS.IMAGE_LOCATION || 'adminc/oltp_archive.gif',cattributes=>'BORDER="0"'),cattributes=>' valign="MIDDLE" align="CENTER"');
    else
      htp.tabledata(htf.formimage( 'revert', DECS.IMAGE_LOCATION || 'adminc/oltp_revert.gif',cattributes=>'BORDER="0"'),cattributes=>' valign="MIDDLE" align="CENTER"');
   end if;
   htp.tabledata(htf.formimage( 'vdelete', DECS.IMAGE_LOCATION || 'adminc/oltp_delete.gif',cattributes=>'BORDER="0"'),cattributes=>' valign="MIDDLE" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Reports'),cattributes=>' valign="MIDDLE" align="RIGHT" colspan="6" style="text-align: center;"' );
   htp.tabledata( htf.formtext( 'SEARCH_TERM', 10, 1000 ),cattributes=>' valign="MIDDLE" align="RIGHT" style="text-align: right;"' );
   htp.tabledata(htf.formimage( 'search', DECS.IMAGE_LOCATION || 'adminc/oltp_search.gif',cattributes=>'BORDER="0"'),cattributes=>' valign="MIDDLE" align="CENTER"');
  htp.tablerowclose;
 htp.tableclose;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 rules="NONE" frame="HSIDES,VSIDES" border=1' );
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG.PHG_TXT_082 ), cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG.CST_TXT_042 ), cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG3.ADM_TXT_856), cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG.ORD_TXT_188 ), cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG.PHG_TXT_025 ), cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold( LNG.PHG_TXT_352 ), cattributes=>GLBX.QUERY_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;

  for c1rec in c1( owner_id, sort_on ) loop
   htp.tablerowopen;
    htp.tabledata( htf.formcheckbox( 'P0','R' || c1rec.report_queue_id), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
    htp.tabledata( c1rec.status, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
    htp.tabledata( c1rec.title, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( c1rec.report_name, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    if c1rec.status = LNG2.PFM_TXT_140
     then
      if c1rec.run_every_1 = '2'
       then
        htp.tabledata( c1rec.run_every_2 || ' ' || c1rec.run_every_3, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
      elsif c1rec.run_every_1 = '3'
       then
        htp.tabledata( c1rec.run_every_2 || ' ' || c1rec.run_every_3, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
      elsif c1rec.run_every_1 = '4'
       then
        htp.tabledata( c1rec.run_every_2 || ' ' || c1rec.run_every_3, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
      elsif c1rec.run_every_1 = '5'
       then
        htp.tabledata( c1rec.run_every_2 || ' ' || c1rec.run_every_3, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
      end if;
      --htp.tabledata( nvl(to_char(c1rec.run_time,LNG.TSMASK),'&nbsp;'), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
     else
      htp.tabledata( to_char(c1rec.run_time,LNG.TSMASK), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
    end if;
    htp.tabledata( '&nbsp;', cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="RIGHT"' );
      htp.tabledata( htf.anchor('javascript: window.open(''' || 'oltp.rep_utilities?surl=' || glbx.rndsurl(surl) || '&typ=A&rid=' || c1rec.report_queue_id ||
                    ''',''' || replace(LNG.PHG_TXT_352 || 'XXXA',' ','_') ||
                    ''',''height=600,width=600,scrollbars=yes,resizable=yes'');void('''');',
                    LNG.PHG_TXT_352 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"');
   htp.tablerowclose;
  end loop;

  mp := glbx.extract_master_parameter('REPORTS_DATABASE');
  for c2rec in c2( owner_id, sort_on, repid, rtype, search_term ) loop
   if nvl(c2rec.expire_date,sysdate+100) < sysdate
    then
     -- Autoexpire Report
     empty_file(c2rec,mp);
     delete from umo where umo_id = c2rec.umo_id;
     commit;
    else
     htp.tablerowopen;
      htp.tabledata( htf.formcheckbox( 'P0',c2rec.umo_id), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
      htp.tabledata( htf.anchor2('oltp.view_a_report?surl=' || glbx.rndsurl(surl) || '&rid=' || c2rec.umo_id, LNG2.PFM_TXT_139,ctarget=>'REPORT_WINDOW'), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
      htp.tabledata( c2rec.extras.title, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( c2rec.extras.photo_name, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( to_char(c2rec.date_created,LNG.TSMASK), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
      htp.tabledata( nvl(c2rec.extras.orderby_nmb,dbms_lob.getlength( c2rec.doc_html)), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="RIGHT"' );
      htp.tabledata( htf.anchor('javascript: window.open(''' || 'oltp.rep_utilities?surl=' || glbx.rndsurl(surl) || '&typ=B&rid=' || c2rec.umo_id ||
                    ''',''' || replace(LNG.PHG_TXT_352 || 'XXXA',' ','_') ||
                    ''',''height=600,width=600,scrollbars=yes,resizable=yes'');void('''');',
                    LNG.PHG_TXT_352 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"');
     htp.tablerowclose;
   end if;
  end loop;

  -- Shared Global Reports
  for c3rec in c3( owner_id, sort_on, rtype, search_term ) loop
   if nvl(c3rec.expire_date,sysdate+100) < sysdate
    then
     -- Autoexpire Report, not allowed to see
     null;
    else
     htp.tablerowopen;
      htp.tabledata( htf.formcheckbox( 'P0',c3rec.umo_id), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
      htp.tabledata( htf.anchor2('oltp.view_a_report?surl=' || glbx.rndsurl(surl) || '&rid=' || c3rec.umo_id, c3rec.username,ctarget=>'REPORT_WINDOW'), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
      htp.tabledata( c3rec.extras.title, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( c3rec.extras.photo_name, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( to_char(c3rec.date_created,LNG.TSMASK), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
      htp.tabledata( nvl(c3rec.extras.orderby_nmb,dbms_lob.getlength( c3rec.doc_html)), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="RIGHT"' );
      htp.tabledata( htf.anchor('javascript: window.open(''' || 'oltp.rep_utilities?surl=' || glbx.rndsurl(surl) || '&typ=B&rid=' || c3rec.umo_id ||
                    ''',''' || replace(LNG.PHG_TXT_352 || 'XXXA',' ','_') ||
                    ''',''height=600,width=600,scrollbars=yes,resizable=yes'');void('''');',
                    LNG.PHG_TXT_352 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"');
     htp.tablerowclose;
   end if;
  end loop;

  for c4rec in c4( owner_id, sort_on, rtype, search_term ) loop
   if nvl(c4rec.expire_date,sysdate+100) < sysdate
    then
     -- Autoexpire Report, not allowed to see
     null;
    else
     htp.tablerowopen;
      htp.tabledata( htf.formcheckbox( 'P0',c4rec.umo_id), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
      htp.tabledata( htf.anchor2('oltp.view_a_report?surl=' || glbx.rndsurl(surl) || '&rid=' || c4rec.umo_id, c4rec.username,ctarget=>'REPORT_WINDOW'), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
      htp.tabledata( c4rec.extras.title, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( c4rec.extras.photo_name, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( to_char(c4rec.date_created,LNG.TSMASK), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"' );
      htp.tabledata( nvl(c4rec.extras.orderby_nmb,dbms_lob.getlength( c4rec.doc_html)), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="RIGHT"' );
      htp.tabledata( htf.anchor('javascript: window.open(''' || 'oltp.rep_utilities?surl=' || glbx.rndsurl(surl) || '&typ=B&rid=' || c4rec.umo_id||
                    ''',''' || replace(LNG.PHG_TXT_352 || 'XXXA',' ','_') ||
                    ''',''height=600,width=600,scrollbars=yes,resizable=yes'');void('''');',
                    LNG.PHG_TXT_352 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="CENTER"');
     htp.tablerowclose;
   end if;
  end loop;
 htp.tableclose;

 htp.formclose;
 htp.p( '</CENTER>' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.htmlclose;

 exception when others then
  glbx.error_details( 'OLTP', 'VIEW_REPORT',null,owner_id,errmsg=>sqlerrm);
end view_report;

procedure rep_options_but( surl in varchar2, p0 in GLBX.MYARRAY, search_term in varchar2 default null,
  run_report in varchar2 default null, purge in varchar2 default null, sort_date in varchar2 default null, sort_name in varchar2 default null, sort_category in varchar2 default null,
  display_all in varchar2 default null, archive in varchar2 default null, revert in varchar2 default null, vdelete in varchar2 default null, search in varchar2 default null)
as
 action varchar2(100);
begin
 if run_report is not null then action := LNG3.ADM_TXT_624;
 elsif purge is not null then action := LNG2.PFM_TXT_142;
 elsif sort_date is not null then action := LNG2.PFM_TXT_143;
 elsif sort_name is not null then action := LNG2.PFM_TXT_147;
 elsif sort_category is not null then action := LNG2.PFM_TXT_148;
 elsif display_all is not null then action := LNG4.AHC_TXT_111;
 elsif archive is not null then action := LNG2.FNM_TXT_021;
 elsif revert is not null then action := LNG4.AHC_TXT_405;
 elsif vdelete is not null then action := LNG.SLD_TXT_004;
 elsif search is not null then action := LNG.GLB_TXT_092;
 end if;
 rep_options(surl, action, p0, search_term );
end rep_options_but;

procedure rep_options( surl in varchar2, action in varchar2, p0 in GLBX.MYARRAY, search_term in varchar2 default null )
as

 cursor c1( acid integer ) is select report_id, count('x') tot from umo where aid = acid and umo_type = 'REPORT' group by report_id having count('x') > 1;
 cursor c2( owner_id integer, repid integer) is select * from umo where aid = owner_id and umo_type = 'REPORT' and report_id = repid and date_created < (select max(date_created) from umo where aid=owner_id and umo_type = 'REPORT' and report_id = repid);
 cursor c3( v_umo integer) is select * from umo where umo_id = v_umo;

 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 mp		varchar2(100);
 is_first	boolean;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'OLTP.VIEW_REPORT', ignore_cookie_check=>TRUE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 GBL_SURL := surl;
 GBL_LTYPE := ltype;
 GBL_STYPE := stype;

 mp := glbx.extract_master_parameter('REPORTS_DATABASE');
 if action = LNG2.PFM_TXT_142
  then
   for c1rec in c1( owner_id ) loop
    for c2rec in c2(owner_id, c1rec.report_id) loop
     empty_file(c2rec,mp);
     delete from umo where umo_id = c2rec.umo_id;
    end loop;
    /*
    delete from umo
     where
      aid = owner_id and
      umo_type = 'REPORT' and
      report_id = c1rec.report_id and
      date_created < (select max(date_created) from umo where aid=owner_id and umo_type = 'REPORT' and report_id = c1rec.report_id);
    */
   end loop;
 elsif action = LNG2.PFM_TXT_143
  then
   view_report( surl, sort_on=>1, search_term=>search_term );
   return;
 elsif action = LNG2.PFM_TXT_147
  then
   view_report( surl, sort_on=>2, search_term=>search_term );
   return;
 elsif action = LNG2.PFM_TXT_148
  then
   view_report( surl, sort_on=>3, search_term=>search_term );
   return;
 elsif action = LNG3.ADM_TXT_624
  then
   display_reports( surl, to_char(sysdate,'SSSSS') );
   return;
 elsif action = LNG4.AHC_TXT_111
  then

   htp.htmlopen;
   htp.p( '<style TYPE="text/css">P { page-break-after: auto }</style>' );
   is_first := FALSE;
   for j in p0.first..p0.last loop
    if p0(j) is not null and substr(p0(j),1,1) <> 'R'
     then
      if is_first then htp.p('<p STYLE="page-break-after: always"></p>'); end if;
      view_a_report( surl, p0(j), 'T' );
      is_first := TRUE;
    end if;
   end loop;
   htp.htmlclose;
   return;
 elsif action = LNG.SLD_TXT_004
  then
   for j in p0.first..p0.last loop
    if p0(j) is not null and substr(p0(j),1,1) <> 'R'
     then
      open c3(p0(j));
      fetch c3 into c3rec;
      close c3;
      empty_file(c3rec, mp);
      delete from umo
       where
        aid = owner_id and
        umo_type = 'REPORT' and
        umo_id = p0(j);
    elsif p0(j) is not null and substr(p0(j),1,1) = 'R'
     then
      -- Stop running report
     delete from report_queue_also_run where report_queue_id = substr(p0(j),2);
     delete from report_queue_parameters where report_queue_id = substr(p0(j),2);
     delete from report_queue where report_queue_id = substr(p0(j),2) and aid = owner_id;
    end if;
   end loop;

 elsif action = LNG2.FNM_TXT_021
  then
   for j in p0.first..p0.last loop
    if p0(j) is not null and substr(p0(j),1,1) <> 'R'
     then
      update umo um
       set
        um.extras.quality = LNG2.FNM_TXT_021
       where
        aid = owner_id and
        umo_type = 'REPORT' and
        umo_id = p0(j);
    end if;
   end loop;
 elsif action = LNG4.AHC_TXT_405
  then
   for j in p0.first..p0.last loop
    if p0(j) is not null and substr(p0(j),1,1) <> 'R'
     then
      update umo um
       set
        um.extras.quality = LNG.ORD_TXT_201
       where
        aid = owner_id and
        umo_type = 'REPORT' and
        umo_id = p0(j);
    end if;
   end loop;
 end if;
 commit;
 if action = LNG2.PFM_TXT_142
  then
   view_report( surl, msg=>LNG2.PFM_TXT_146, search_term=>search_term );
 elsif action = LNG4.AHC_TXT_111
  then
   null;
 elsif action = LNG.SLD_TXT_004
  then
   view_report( surl, msg=>LNG4.AHC_TXT_112, search_term=>search_term );
 elsif action = LNG2.FNM_TXT_021
  then
   view_report( surl, action=>'ARCHIVE_LIST', search_term=>search_term );
 else
  view_report( surl, msg=>NULL, search_term=>search_term );
 end if;
 exception when others then
  glbx.error_details( 'OLTP', 'REP_OPTIONS',null,owner_id,errmsg=>sqlerrm);
end rep_options;

procedure view_a_report( surl in varchar2, rid in integer, mass_view in char default 'F'  )
as

 cursor c1(acid integer, v_umo integer ) is
  select doc_html, document_original_loc, ftp_location, object_class
  from umo um
  where aid = acid and
        umo_id = v_umo;

 cursor c2(acid integer, v_umo integer ) is
  select /*+ ALL_ROWS */ doc_html, document_original_loc, ftp_location, object_class
  from umo um, customer_account ca
  where umo_type = 'REPORT' and
        um.aid <> acid  and
        ca.aid = um.aid and
        um.extras.enabled_phg = 'TRUE' and
        umo_id = v_umo;

 cursor c3(acid integer, v_umo integer ) is
  select /*+ ALL_ROWS */ doc_html, document_original_loc, ftp_location, object_class
  from umo um, customer_roles r, customer_account ca
  where umo_type = 'REPORT' and
        um.aid <> acid  and
        ca.aid = um.aid and
        r.aid = acid and
        um.extras.enabled_phg = to_char(r.role_id) and
        umo_id = v_umo;

 fl		UTL_FILE.FILE_TYPE;
 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 v_buffer	varchar2(32767);
 v_count	integer;
 v_int		integer;

begin
 if mass_view = 'F'
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'OLTP.VIEW_A_REPORT', ignore_cookie_check=>TRUE );
  else
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'OLTP.VIEW_A_REPORT',reset=>FALSE, ignore_cookie_check=>TRUE );
 end if;
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 GBL_SURL := surl;
 GBL_LTYPE := ltype;
 GBL_STYPE := stype;

 open c1(owner_id,rid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   open c2(owner_id,rid);
   fetch c2 into c1rec;
   if c2%NOTFOUND
    then
     close c2;
     open c3(owner_id,rid);
     fetch c3 into c1rec;
     if c3%NOTFOUND
      then
       close c3;
       htp.htmlopen;
       htp.header( 1,LNG2.PFM_TXT_144,'CENTER' );
       htp.htmlclose;
       return;
     else
      close c3;
     end if;
    else
     close c2;
   end if;
  else
   close c1;
 end if;

 if glbx.extract_master_parameter('REPORTS_DATABASE') = 'TRUE'
  then
    if dbms_lob.getlength( c1rec.doc_html ) = 0
     then
      htp.htmlopen;
      htp.header( 1,LNG2.PFM_TXT_144,'CENTER' );
      htp.htmlclose;
      return;
    end if;

    v_count := 0;
    v_int := 32767; --255
    begin
     loop
      dbms_lob.read(c1rec.doc_html,v_int,(v_count*32767)+1,v_buffer);
      v_count := v_count + 1;
      htp.prn( v_buffer );
     end loop;
    exception
     when no_data_found then null;
    end;

  else
   if nvl(c1rec.object_class, 'XXX') = 'HTTP'
    then
     -- owa_util.redirect_url('http' || (case when nvl(upper(owa_util.get_cgi_env('HTTPS')), 'OFF') = 'ON' then 's' end) || '://' || owa_util.get_cgi_env('SERVER_NAME')|| ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || '/' || c1rec.ftp_location);
     owa_util.redirect_url(glbx.extract_master_parameter('PICTION_HOME_PAGE') || '/' || c1rec.ftp_location);
   else
     v_buffer := null;
     fl := utl_file.fopen( nvl(c1rec.document_original_loc,glbx.extract_master_parameter('MAIL_OUTPUT_DIR')), 'report_' || rid || '.html', 'r', max_linesize=>32767 );
     v_int := 1;
     loop
      v_int := v_int + 1;
      if v_int > 100000 then exit; end if;
      begin
       utl_file.get_line(fl,v_buffer);
       htp.p( v_buffer );
      exception when others then exit;
      end;
     end loop;
     utl_file.fclose(fl);
   end if;

 end if;

 exception when others then
  glbx.error_details( 'OLTP', 'VIEW_A_REPORT',null,owner_id,errmsg=>sqlerrm);
end view_a_report;

procedure webservice_run_report( surl in varchar2, name in varchar2, p1 in glbx.myarray, p2 in glbx.myarray )
as

 cursor c1( name varchar2 ) is select * from report_definition where upper(report_name) = upper(name);

 cursor c2( sess_id integer ) is select aid, login_type from login_session where sessid = sess_id;

 cursor c3( newid integer ) is select activity_result from report_queue_log where activity_type = 'START' and report_queue_id = newid;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 newid		integer;
 v_umo		integer;

 begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'OLTP.DISPLAY_SCREEN', reset=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 open c1(name);
 fetch c1 into c1rec;
 close c1;
 if c1rec.report_id is null
  then
   htp.p( '<ERROR>' || 'Report Not Found : ' || name || '</ERROR>' );
   return;
 end if;

 c2rec.aid := NULL;
 c2rec.login_type := NULL;
 open c2(owner_id);
 fetch c2 into c2rec;
 close c2;

 select s_report_queue_id.nextval into newid from dual;

 insert into report_queue(report_queue_id,report_id,sessid,aid,submit_time,run_every_1,run_every_2,run_every_3,priority,notification,autoexpire,status)
   values
 (newid,c1rec.report_id, owner_id, c2rec.aid, sysdate, '1', null, null, 'A', '1', '30', LNG2.PFM_TXT_140);
 if p1.count > 0
  then
   for j in p1.first..p1.last loop
   insert into report_queue_parameters(report_queue_id,report_id,parameter_name,parameter_type,parameter_value)
    values
     ( newid, c1rec.report_id, upper(p1(j)), 'C', p2(j) );
   end loop;
 end if;
 commit;

 run_the_report( newid, c2rec.login_type, c2rec.aid );
 open c3(newid);
 fetch c3 into c3rec;
 close c3;
 view_a_report( surl, to_number(c3rec.activity_result), 'T' );

exception
 when others then htp.p( '<ERROR>' || sqlerrm || '</ERROR>' );
end webservice_run_report;

procedure check_reports( timegap in integer )
as

 cursor c1 is
  select *
  from report_queue
  where status = LNG2.PFM_TXT_140;

 cursor c2(sess_id integer) is select aid,login_type from login_session where sessid = sess_id;

 c2rec	c2%ROWTYPE;
 newid	integer;
 ddate	date;
 sss	integer;
 ssd	integer;

begin
 -- Run Immediate Jobs first
 for c1rec in c1 loop

  c2rec.aid := NULL;
  c2rec.login_type := NULL;
  open c2(c1rec.sessid);
  fetch c2 into c2rec;
  close c2;

  if c1rec.run_every_1 = '2'
   then
    run_the_report( c1rec.report_queue_id,c2rec.login_type,c2rec.aid );

  elsif c1rec.run_every_1 = '3'
   then
    -- if right time then create new job
    ddate := to_date(c1rec.run_every_3,'HH24:MI');
    sss := to_number(to_char(ddate,'HH24')) * 60;
    sss := sss + to_number(to_char(ddate,'MI'));
    ssd := to_number(to_char(sysdate,'HH24')) * 60;
    ssd := ssd + to_number(to_char(sysdate,'MI'));
    if ((c1rec.run_every_2 = LNG2.PFM_TXT_126) or (c1rec.run_every_2 = LNG2.PFM_TXT_127 and to_number(to_char(sysdate,'D')) between 2 and 6)) and
       (sss >= ssd and sss <= (ssd + timegap))
     then
      select s_report_queue_id.nextval into newid from dual;
      insert into report_queue(report_queue_id,report_id,sessid,aid,submit_time,run_every_1,run_every_2,run_every_3,priority,notification,autoexpire,status)
       values
       (newid,c1rec.report_id,c1rec.sessid,c1rec.aid,sysdate,'1',null,null,c1rec.priority,c1rec.notification,c1rec.autoexpire,c1rec.status);

      insert into report_queue_parameters(report_queue_id,report_id,parameter_name,parameter_type,parameter_value)
         select newid,report_id,parameter_name,parameter_type,parameter_value
         from report_queue_parameters
         where report_queue_id = c1rec.report_queue_id;
     run_the_report( newid,c2rec.login_type,c2rec.aid );
   end if;

  elsif c1rec.run_every_1 = '4'
   then
    -- if right time then create new job
    ddate := to_date(c1rec.run_every_3,'HH24:MI');
    sss := to_number(to_char(ddate,'HH24')) * 60;
    sss := sss + to_number(to_char(ddate,'MI'));
    ssd := to_number(to_char(sysdate,'HH24')) * 60;
    ssd := ssd + to_number(to_char(sysdate,'MI'));
    if (upper(c1rec.run_every_2) = to_char(sysdate,'DAY')) and
       (sss >= ssd and sss <= (ssd + timegap))
     then
      select s_report_queue_id.nextval into newid from dual;
      insert into report_queue(report_queue_id,report_id,sessid,aid,submit_time,run_every_1,run_every_2,run_every_3,priority,notification,autoexpire,status)
       values
       (newid,c1rec.report_id,c1rec.sessid,c1rec.aid,sysdate,'1',null,null,c1rec.priority,c1rec.notification,c1rec.autoexpire,c1rec.status);

      insert into report_queue_parameters(report_queue_id,report_id,parameter_name,parameter_type,parameter_value)
         select newid,report_id,parameter_name,parameter_type,parameter_value
         from report_queue_parameters
         where report_queue_id = c1rec.report_queue_id;
      run_the_report( newid,c2rec.login_type,c2rec.aid );

   end if;

  elsif c1rec.run_every_1 = '5'
   then
    -- if right time then create new job
    ddate := to_date(c1rec.run_every_3,'HH24:MI');
    sss := to_number(to_char(ddate,'HH24')) * 60;
    sss := sss + to_number(to_char(ddate,'MI'));
    ssd := to_number(to_char(sysdate,'HH24')) * 60;
    ssd := ssd + to_number(to_char(sysdate,'MI'));
    if ((upper(c1rec.run_every_2) = to_char(sysdate,'DD')) or ((c1rec.run_every_2 = LNG2.PFM_TXT_129) and (to_char(sysdate,'DD') = to_char(last_day(sysdate),'DD') ))) and
       (sss >= ssd and sss <= (ssd + timegap))
     then
      select s_report_queue_id.nextval into newid from dual;
      insert into report_queue(report_queue_id,report_id,sessid,aid,submit_time,run_every_1,run_every_2,run_every_3,priority,notification,autoexpire,status)
       values
       (newid,c1rec.report_id,c1rec.sessid,c1rec.aid,sysdate,'1',null,null,c1rec.priority,c1rec.notification,c1rec.autoexpire,c1rec.status);

      insert into report_queue_parameters(report_queue_id,report_id,parameter_name,parameter_type,parameter_value)
         select newid,report_id,parameter_name,parameter_type,parameter_value
         from report_queue_parameters
         where report_queue_id = c1rec.report_queue_id;
     run_the_report( newid,c2rec.login_type,c2rec.aid );
    end if;

  end if;
 end loop;
 exception when others then
  glbx.error_details( 'OLTP', 'CHECK_REPORTS',null,null,errmsg=>sqlerrm);
end check_reports;

procedure rep_utilities( surl in varchar2, typ in varchar2, rid in integer )
as

 cursor c1( rid integer ) is
  select 'FALSE'
       , report_name
	   , rd.umo_scene_id
	   , usc.title
	   , rd.report_id
	   , null
	   , rq.submit_time
	   , rq.aid
       , null
       , null
  from report_queue rq, report_definition rd, umo_scene usc
  where rq.report_id = rd.report_id and
        usc.umo_scene_id = rd.umo_scene_id and
        rq.report_queue_id = rid;

cursor c2( v_umo integer) is
 select um.extras.enabled_phg enabled_phg
      , um.extras.photo_name photo_name
	  , umo_scene_id
	  , um.extras.title title
	  , report_id
	  , expire_date
	  , date_created
	  , um.aid
      , um.ftp_location
      , um.object_class
 from umo um
 where umo_id = v_umo and
       umo_type = 'REPORT';

cursor c3( rid integer ) is select parameter_name, parameter_value from report_queue_parameters where report_queue_id = rid;

cursor c4( usc integer ) is select umo_scene_id,title from umo_scene where category = (select category from umo_scene where umo_scene_id = usc) order by order_by;

cursor c6(ltype varchar2, acid integer) is
  select contact_mobile,billing_email,contact_email
  from customer_contact
  where (ltype = 'OWNER' and aid = acid) or
        (ltype = 'PROFILE' and aid = acid);

cursor c7 is select role_id, role_name, role_type from piction_roles where role_type in ('REPORT','SECURITY ROLE') order by role_name;

 crec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c6rec		c6%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'OLTP.VIEW_REPORT', ignore_cookie_check=>TRUE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 GBL_SURL := surl;
 GBL_LTYPE := ltype;
 GBL_STYPE := stype;

 crec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( crec.theme_name );

 glbx.main_title( surl, LNG2.PFM_TXT_155,glbx.backimg(surl,crec.aid,pfx.text_back,crec.background_img,ltype),helpid=>'T05',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 if typ = 'A'
  then
   open c1( rid );
   fetch c1 into c2rec;
   close c1;
  else
   open c2( rid );
   fetch c2 into c2rec;
   close c2;
   if c2rec.aid = owner_id
    then
     null;
   elsif not ((c2rec.aid <> owner_id) and (c2rec.enabled_phg = 'TRUE')) -- Accessing a report not allowed to
    then
     return;
   end if;
 end if;

 if c2rec.aid <> owner_id
  then
   glbx.header_msg( LNG2.PFM_TXT_156 );
  else
   glbx.header_msg( c2rec.photo_name );
 end if;

 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
 -- Download
 if typ = 'B'
  then
   htp.tablerowopen;
    htp.tabledata( LNG2.PBK_TXT_128, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    if c2rec.photo_name like '% CSV%'
     then
      htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
       htp.formopen( 'oltp.process_reputl' );
       htp.formhidden( 'SURL', surl );
       htp.formhidden( 'RID', rid );
       htp.formhidden( 'ACT', '10' );
       htp.formhidden( 'TYP', typ );
       htp.formsubmit( null, 'Excel (CSV)' );
       htp.formclose;
      htp.p( '</TD>' );
     elsif c2rec.object_class = 'HTTP'
      then
       null;
     else
      htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
       htp.formopen( 'oltp.process_reputl' );
       htp.formhidden( 'SURL', surl );
       htp.formhidden( 'RID', rid );
       htp.formhidden( 'ACT', '1' );
       htp.formhidden( 'TYP', typ );
       htp.formsubmit( null, 'Word' );
       htp.formclose;
      htp.p( '</TD>' );
    end if;
    htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
     --htp.formopen( 'oltp.process_reputl' );
     --htp.formhidden( 'SURL', surl );
     --htp.formhidden( 'RID', rid );
     --htp.formhidden( 'ACT', '10' );
     --htp.formhidden( 'TYP', typ );
     --htp.formsubmit( null, 'Save to File' );
     --htp.formclose;
     if c2rec.photo_name like '% CSV%'
      then
       htp.anchor( 'oltp.process_reputl?surl=' || surl || '&rid=' || rid || '&act=10&typ=' || replace(typ,' ','+'), 'Save to File' );
     elsif c2rec.object_class = 'HTTP'
      then
       htp.anchor( 'http' || (case when nvl(upper(owa_util.get_cgi_env('HTTPS')), 'OFF') = 'ON' then 's' end) || '://' || owa_util.get_cgi_env('SERVER_NAME')|| ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || '/' || c2rec.ftp_location, 'Download File', cattributes=>'download target="_blank"' );
       htp.p( '</TD>' );
       htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
      else
       htp.anchor( 'oltp.process_reputl?surl=' || surl || '&rid=' || rid || '&act=1&typ=' || replace(typ,' ','+'), 'Save to File' );
     end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
 end if;

 -- Email
 if typ = 'B'
  then
   htp.tablerowopen;
    htp.tabledata( LNG2.PFM_TXT_150, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.formopen( 'oltp.process_reputl' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'RID', rid );
    htp.formhidden( 'ACT', '2' );
    htp.formhidden( 'TYP', typ );
    open c6( ltype, owner_id );
    fetch c6 into c6rec;
    close c6;
    htp.tabledata( htf.formtext( 'P1', 20, 100, nvl(c6rec.billing_email,c6rec.contact_email) ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.formsubmit( null, LNG2.PFM_TXT_158 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.formclose;
   htp.tablerowclose;
 end if;

 -- Delete
 if c2rec.aid = owner_id
  then
   htp.tablerowopen;
    htp.tabledata( LNG.SLD_TXT_004, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.formopen( 'oltp.process_reputl' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'RID', rid );
    htp.formhidden( 'TYP', typ );
    htp.formhidden( 'ACT', '3' );
    htp.tabledata( '&nbsp;', cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.formsubmit( null, LNG2.PFM_TXT_158 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.formclose;
   htp.tablerowclose;
 end if;

 -- Security
 if c2rec.aid = owner_id and typ = 'B'
  then
   htp.tablerowopen;
    htp.tabledata( LNG2.PFM_TXT_153, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.formopen( 'oltp.process_reputl' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'RID', rid );
    htp.formhidden( 'ACT', '4' );
    htp.formhidden( 'TYP', typ );
    htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formselectopen( 'P1' );
    if c2rec.enabled_phg is NULL
     then
      htp.formselectoption( LNG.SLD_TXT_021, 'SELECTED', cattributes=>'VALUE=""' );
      htp.formselectoption( LNG2.PFM_TXT_160,cattributes=>'VALUE="TRUE"' );
     elsif c2rec.enabled_phg = 'TRUE'
      then
       htp.formselectoption( LNG.SLD_TXT_021,cattributes=>'VALUE=""' );
       htp.formselectoption( LNG2.PFM_TXT_160,'SELECTED', cattributes=>'VALUE="TRUE"' );
     else
       htp.formselectoption( LNG.SLD_TXT_021,cattributes=>'VALUE=""' );
       htp.formselectoption( LNG2.PFM_TXT_160, cattributes=>'VALUE="TRUE"' );
    end if;
    for c7rec in c7 loop
     if c2rec.enabled_phg = to_char(c7rec.role_id)
      then
       htp.formselectoption( c7rec.role_name,'SELECTED', cattributes=>'VALUE="' || to_char(c7rec.role_id) || '"' );
      else
       htp.formselectoption( c7rec.role_name, cattributes=>'VALUE="' || to_char(c7rec.role_id) || '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formsubmit( null, LNG2.PFM_TXT_158 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.formclose;
   htp.tablerowclose;
 end if;

 -- Job Run Stats
 if typ = 'B'
  then
   htp.tablerowopen;
    htp.tabledata( LNG2.PFM_TXT_151, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.formopen( 'oltp.process_reputl', ctarget=>'STATISTICS_WINDOW' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'RID', rid );
    htp.formhidden( 'ACT', '5' );
    htp.formhidden( 'TYP', typ );
    htp.tabledata( '&nbsp;', cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.formsubmit( null, LNG2.PFM_TXT_158 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.formclose;
   htp.tablerowclose;
 end if;

 -- Expire
 if c2rec.aid = owner_id and typ = 'B'
  then
   htp.tablerowopen;
    htp.tabledata( LNG2.FNM_TXT_053, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.formopen( 'oltp.process_reputl' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'RID', rid );
    htp.formhidden( 'ACT', '6' );
    htp.formhidden( 'TYP', typ );
    htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formselectopen( 'P1' );
    htp.formselectoption( NULL );
    for j in 1..365 loop
     if trunc(sysdate + j) = trunc(c2rec.expire_date)
      then
       htp.formselectoption( to_char(sysdate+j,LNG.MASK), 'SELECTED' );
      else
       htp.formselectoption( to_char(sysdate+j,LNG.MASK));
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formsubmit( null, LNG2.PFM_TXT_158 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.formclose;
   htp.tablerowclose;
 end if;

 -- Copy
 if typ = 'B'
  then
   htp.tablerowopen;
    htp.tabledata( LNG2.PFM_TXT_154, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.formopen( 'oltp.process_reputl' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'RID', rid );
    htp.formhidden( 'ACT', '7' );
    htp.formhidden( 'TYP', typ );
    htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formselectopen( 'P1' );
    for c4rec in c4(c2rec.umo_scene_id) loop
     if c4rec.umo_scene_id = c2rec.umo_scene_id
      then
       htp.formselectoption( c4rec.title, 'SELECTED', cattributes=>'VALUE="' || c4rec.umo_scene_id || '"' );
      else
       htp.formselectoption( c4rec.title, cattributes=>'VALUE="' || c4rec.umo_scene_id || '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formsubmit( null, LNG2.PFM_TXT_158 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.formclose;
   htp.tablerowclose;
 end if;

 -- Move
 if c2rec.aid = owner_id and typ = 'B'
  then
   htp.tablerowopen;
    htp.tabledata( LNG2.PFM_TXT_152, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.formopen( 'oltp.process_reputl' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'RID', rid );
    htp.formhidden( 'ACT', '8' );
    htp.formhidden( 'TYP', typ );
    htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formselectopen( 'P1' );
    for c4rec in c4(c2rec.umo_scene_id) loop
     if c4rec.umo_scene_id = c2rec.umo_scene_id
      then
       htp.formselectoption( c4rec.title, 'SELECTED', cattributes=>'VALUE="' || c4rec.umo_scene_id || '"' );
      else
       htp.formselectoption( c4rec.title, cattributes=>'VALUE="' || c4rec.umo_scene_id || '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formsubmit( null, LNG2.PFM_TXT_158 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.formclose;
   htp.tablerowclose;
 end if;
 htp.tableclose;

 if typ = 'A'
  then
   htp.nl;
   htp.bold( LNG2.PFM_TXT_157 );
   htp.nl;
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
   for c3rec in c3(rid) loop
    htp.tablerowopen;
     htp.tabledata( c3rec.parameter_name, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( nvl(c3rec.parameter_value,'&nbsp;'), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( '&nbsp;', cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
   end loop;
    htp.tabledata( LNG4.AHC_TXT_288, cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.formopen( 'oltp.process_reputl' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'RID', rid );
    htp.formhidden( 'TYP', typ );
    htp.formhidden( 'ACT', '9' );
    htp.tabledata( '&nbsp;', cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.formsubmit( null, LNG2.PFM_TXT_158 ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.formclose;
   htp.tablerowclose;
   htp.tableclose;
 end if;

 htp.nl;
-- htp.formopen( 'oltp.view_report' );
-- htp.formhidden( 'SURL', surl );
-- htp.formsubmit( null, LNG2.PFM_TXT_138 );
-- htp.formclose;
 htp.bold( '<a href="javascript:self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;

 exception when others then
  glbx.error_details( 'OLTP', 'REP_UTILITIES',null,owner_id,errmsg=>sqlerrm);
end rep_utilities;

procedure process_reputl( surl in varchar2, rid in integer, act in integer, typ in varchar2, p1 in varchar2 default null )
as

 cursor c2(acid integer, v_umo integer ) is select rowid, aid,um.extras.enabled_phg enabled_phg,um.extras.photo_name photo_name,umo_id from umo um where umo_id = v_umo and umo_type = 'REPORT';
 cursor c3(v_umo integer) is select doc_html from umo where umo_id = v_umo for update;
 cursor c4(v_umo integer) is select * from umo where umo_id = v_umo;
 cursor c5a( rid integer ) is select activity_date from report_queue_log where activity_result = rid and activity_type = 'START';
 cursor c5b( rid integer ) is select activity_date from report_queue_log where activity_result = rid and activity_type = 'STOP';
 cursor c6(ltype varchar2, acid integer) is
  select contact_mobile,billing_email,contact_email
  from customer_contact
  where (ltype = 'OWNER' and aid = acid) or
        (ltype = 'PROFILE' and aid = acid)
 union all
  select contact contact_mobile, contact_email billing_email,contact_email
  from manufacturer
  where ltype = 'MANUFACTURER' and manufacturer_id = acid
 union all
  select mobile_phone contact_mobile, contact_email billing_email,contact_email
  from photographer
  where ltype = 'PHOTOGRAPHER' and pid = acid;
 cursor c7(v_umo integer) is select * from umo where umo_id = v_umo;

 f		UTL_FILE.FILE_TYPE;
 fl		UTL_FILE.FILE_TYPE;
 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5arec		c5a%ROWTYPE;
 c5brec		c5b%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;
 dst		clob;
 src		clob;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 newid		integer;
 fname		varchar2(1000);
 v_buffer	varchar2(32767);
 v_count	integer;
 v_int		integer;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'OLTP.VIEW_A_REPORT', ignore_cookie_check=>TRUE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 GBL_SURL := surl;
 GBL_LTYPE := ltype;
 GBL_STYPE := stype;

 if typ = 'A'
  then
   null;
  else
   open c2(owner_id,rid);
   fetch c2 into c2rec;
   if c2%NOTFOUND
    then
     close c2;
     return;
   end if;
   close c2;
   if c2rec.aid = owner_id
    then
     null;
   elsif c2rec.aid <> owner_id and c2rec.enabled_phg <> 'TRUE'
    then
     return; -- Illegal Access
   end if;
end if;

 if act in (1,10) -- Download
  then
   open c4(c2rec.umo_id);
   fetch c4 into c4rec;
   close c4;
   if act = 1
    then
     fname := nvl(glbx.extract_fname(c4rec.extras.photo_name,'FILENAME'),'report') || '.doc';
     htp.prn('Content-type: ' || 'application/msword' || NL_CHAR); -- bad/type
     htp.prn('Content-Disposition: attachment; filename="' || fname || '"' || NL_CHAR); -- '"' || instead of attachment file
     htp.prn('Content-Transfer-Encoding: binary' || NL_CHAR);
     htp.prn(NL_CHAR);
    else
     fname := nvl(glbx.extract_fname(c4rec.extras.photo_name,'FILENAME'),'report') || '.csv';
     htp.prn('Content-type: ' || 'bad/type' || chr(10));
     htp.prn('Content-Disposition: attachment; filename=' || 'report_' || rid || '.csv' || chr(10));
     htp.prn('Content-Transfer-Encoding: binary' || chr(10));
     htp.prn(chr(10));
   end if;

   if glbx.extract_master_parameter('REPORTS_DATABASE') = 'TRUE'
    then
      v_count := 0;
      v_int := 32767;
      begin
       loop
        dbms_lob.read(c4rec.doc_html,v_int,(v_count*32767)+1,v_buffer);
        v_count := v_count + 1;
        htp.prn( v_buffer );
       end loop;
      exception
       when others then null;
      end;
    else
     fl := utl_file.fopen( c4rec.document_original_loc, 'report_' || c4rec.umo_id || '.html', 'r', max_linesize=>32767 );
     loop
      begin
       utl_file.get_line(fl,v_buffer);
       if act <> 1 and nvl(length(v_buffer), 0) = 0
	    then
		 null;
	   else
	     htp.p( v_buffer );
	   end if;
      exception when others then exit;
      end;
     end loop;
     utl_file.fclose(fl);
   end if;
    -- view_report(surl);

 elsif act = 2 -- Email
  then
    open c6(ltype,owner_id);
    fetch c6 into c6rec;
    close c6;
    gcode(1) := NULL;
    gparam(1) := NULL;
    if glbx.extract_master_parameter('REPORTS_DATABASE') = 'TRUE'
     then
      glbx.send( gcode, gparam, to_char(rid), p_to=>nvl(p1,nvl(c6rec.billing_email,c6rec.contact_email)), p_subj=>c2rec.photo_name, p_from=>glbx.extract_master_parameter('MAIL_FROM'),is_report=>TRUE,ltype=>ltype,own_id=>owner_id);
     else
      glbx.send( gcode, gparam, 'report_' || rid || '.html', p_to=>nvl(p1,nvl(c6rec.billing_email,c6rec.contact_email)), p_subj=>c2rec.photo_name, p_from=>glbx.extract_master_parameter('MAIL_FROM'),is_report=>TRUE,ltype=>ltype,own_id=>owner_id, is_attachment=>TRUE);
    end if;
    view_report(surl);

 elsif act = 3 -- Delete
  then
   if typ = 'A'
    then
     delete from report_queue_also_run where report_queue_id = rid;
     delete from report_queue_parameters where report_queue_id = rid;
     delete from report_queue where report_queue_id = rid and aid = owner_id;
    elsif typ = 'B'
     then
      open c7(rid);
      fetch c7 into c7rec;
      close c7;
      empty_file(c7rec, glbx.extract_master_parameter('REPORTS_DATABASE'));
      delete from umo where umo_id = rid and aid = owner_id;
   end if;
   commit;
   view_report(surl);

 elsif act = 4 -- Security
  then
   update umo um set um.extras.enabled_phg = p1 where umo_id = rid;
   commit;
   rep_utilities(surl,typ,rid);

 elsif act = 5 -- Job Run Statistics
  then
   open c5a(rid);
   fetch c5a into c5arec;
   close c5a;
   open c5b(rid);
   fetch c5b into c5brec;
   close c5b;
   open c4(c2rec.umo_id);
   fetch c4 into c4rec;
   close c4;
   htp.htmlopen;
   htp.p( '<CENTER>' );
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG3.ADM_TXT_856 ) );
     htp.tabledata( c2rec.photo_name );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG3.ADM_TXT_847 ) );
     htp.tabledata( to_char(c5arec.activity_date,'DD-Mon-YYYY HH24:MI:SS') );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG3.ADM_TXT_263 ) );
     htp.tabledata( to_char(c5brec.activity_date,'DD-Mon-YYYY HH24:MI:SS') );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG3.ADM_TXT_260 ) );
     htp.tabledata( round((c5brec.activity_date - c5arec.activity_date) * 60 * 60 * 24,2) );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG.PHG_TXT_224 ) );
     htp.tabledata( dbms_lob.getlength( c4rec.doc_html ) );
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
    htp.nl;
    htp.p( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
    htp.nl;
   htp.htmlclose;

 elsif act = 6 -- Expiry Date
  then
   update umo set expire_date = to_date(p1,LNG.MASK) where umo_id = rid;
   commit;
   view_report(surl);

 elsif act = 7 -- Copy
  then
   select s_umo.nextval into newid from dual;
   insert into umo(umo_id,aid,umo_type,umo_owner,umo_scene_id,version,extras,doc_html,date_created,expire_date,report_id,document_original_loc)
    values
     (newid,owner_id,'REPORT','OWNER',to_number(p1),1,repeated_fields(null,null,null,null,null,null,null,nvl(DEFSECURITY,'FALSE'),'FALSE'),
      empty_clob(),sysdate,null,null,null);
   update umo um
    set
     um.extras.title = (select usc1.title from umo_scene usc1 where umo_scene_id = p1),
     (um.extras.orderby_nmb,um.extras.photo_name,um.report_id,expire_date,document_original_loc) =
     (select um1.extras.orderby_nmb,um1.extras.photo_name,um1.report_id,um1.expire_date,um1.document_original_loc from umo um1 where umo_id = rid)
    where umo_id = newid;
   commit;
   if glbx.extract_master_parameter('REPORTS_DATABASE') = 'TRUE'
    then
     open c3(newid);
     fetch c3 into dst;
     close c3;
     open c3(rid);
     fetch c3 into src;
     close c3;
     dbms_lob.copy( dst, src, dbms_lob.getlength( dst ));
     update umo um
      set
       doc_html = dst
     where
      umo_id = newid;
    else
      begin
       open c7(rid);
       fetch c7 into c7rec;
       close c7;
       f := utl_file.fopen( c7rec.document_original_loc, 'report_' || rid || '.html', 'r', 32767);
       fl := utl_file.fopen( c7rec.document_original_loc, 'report_' || newid || '.html', 'w', 32767);
       -- Copy the file
       loop
        begin
          utl_file.get_line( f, buffer=>v_buffer );
          utl_file.put_line( fl, buffer=>v_buffer );
        exception
         when others then exit;
        end;
       end loop;
       utl_file.fclose(fl);
       utl_file.fclose(f);
      exception
       when others then null;
      end;
    end if;
    commit;
    view_report(surl);

 elsif act = 8 -- Move
  then
   update umo um set um.umo_scene_id = p1, um.extras.title = (select title from umo_scene where umo_scene_id = p1) where umo_id = rid;
   commit;
   view_report(surl);

 elsif act = 9 -- Stop
  then
   update report_queue set status = 'STOPPED' where report_queue_id = rid;
   commit;
   view_report(surl);
 end if;

 exception when others then
  glbx.error_details( 'OLTP', 'PROCESS_REPUTL',null,owner_id,errmsg=>sqlerrm);
end process_reputl;

procedure olap( surl in varchar2, rnd in varchar2 default null )
as
begin
 htp.p( 'Still to be built' );
 exception when others then
  glbx.error_details( 'OLTP', 'OLAP',null,null,errmsg=>sqlerrm);
end olap;

function restrict_sqlstmt( acid in integer, sqlstmt in varchar2 )
 return varchar2
as

 cursor c1(acid integer) is
  select upper(nvl(table_owner,user) || '.'  || table_name) tname,where_clause
  from piction_roles pr, piction_roles_rules prr, customer_roles cr
  where cr.aid = acid and
        cr.role_id = prr.role_id and
        prr.role_id = pr.role_id and
        pr.role_type = 'TABLE' and
        prr.restriction_type = 'RESTRICT';

 retarr		GLBX.MYARRAY;
 alias		varchar2(100);
 tnm		varchar2(100);
 ret_stmt	varchar2(32767);

begin

--glbx.dbg(substr(sqlstmt,1,3500));
--glbx.dbg(substr(sqlstmt,3501,3500));
--glbx.dbg('x:' || length( sqlstmt ));

retarr := extract_from_clause( sqlstmt );
 if not retarr.exists(1)
  then
   if substr( sqlstmt, length( sqlstmt ), 1 ) = ';'
    then
     return( substr(sqlstmt,1, length( sqlstmt ) - 1 ) );
    else
    return( sqlstmt );
  end if;
 end if;
 ret_stmt := sqlstmt;
 for c1rec in c1(acid) loop
  if c1rec.where_clause is not null
   then
    for j in retarr.first..retarr.last loop
     alias := NULL;
     if substr(retarr(j),1,1) = '['
      then
       tnm := substr(retarr(j),instr(retarr(j),']')+1);
       alias := substr(retarr(j),2,instr(retarr(j),']')-2);
      else
       tnm := retarr(j);
     end if;
     if tnm = c1rec.tname
      then
       if alias is not null
        then
         ret_stmt := attach_where_clause( ret_stmt, attach_alias(tnm, c1rec.where_clause, alias) );
        else
         ret_stmt := attach_where_clause( ret_stmt, c1rec.where_clause );
       end if;
     end if;
    end loop;
  end if;
 end loop;
 -- Remove trailing semi-colon if it exists
 if substr( ret_stmt, length( ret_stmt ), 1 ) = ';'
  then
   return( substr(ret_stmt,1, length( ret_stmt ) - 1 ) );
  else
   return( ret_stmt );
 end if;

 exception when others then
  glbx.error_details( 'OLTP', 'RESTRICT_SQLSTMT',null,acid,errmsg=>sqlerrm);
end restrict_sqlstmt;

function attach_alias( table_name in varchar2, where_clause in varchar2, alias in varchar2 )
 return varchar2
as
 cursor c1(ownr varchar2, tname varchar2) is select column_name from all_tab_columns where owner = ownr and table_name = tname;

 retwhere	varchar2(5000);
 x		integer;

begin
 retwhere := where_clause;

 for c1rec in c1( upper(substr(table_name,1,instr(table_name,'.')-1)),upper(substr(table_name,instr(table_name,'.')+1)) ) loop
  x := instr( upper(retwhere), c1rec.column_name );
  if x > 0
   then
    retwhere := substr(retwhere,1,x-1) || ' ' || alias || '.' || substr(retwhere,x);
  end if;
 end loop;

 return( retwhere );
 exception when others then
  glbx.error_details( 'OLTP', 'ATTACH_ALIAS',null,null,errmsg=>sqlerrm);
end attach_alias;

function extract_from_clause( sqlstmt in varchar2 )
 return GLBX.MYARRAY
as

 retarr		GLBX.MYARRAY;
 from_stmt	varchar2(32767);
 tbl		varchar2(1000);
 ctr		integer;
 x		integer;
 y		integer;
 z		integer;

begin
 x := instr( upper(sqlstmt), ' FROM ' );
 if x = 0 then return( retarr ); end if; -- No FROM clause, illegal statement
 y := instr( upper(sqlstmt), ' WHERE ' );
 z := instr( upper(sqlstmt), ' GROUP ' );
 if y = 0 then y := z; end if;
 if z > 0 and z < y then y := z; end if;
 z := instr( upper(sqlstmt), ' ORDER ' );
 if y = 0 then y := z; end if;
 if z > 0 and z < y then y := z; end if;
 if y = 0 then y := length( sqlstmt ) + 1; end if; -- No Where, Group or Order Clause
 from_stmt := trim(upper(substr(sqlstmt,x+6,y-(x+6))));
 ctr := 1;
 loop
  x := instr(from_stmt,',',1,1);
  if x = 0 then exit; end if;
  tbl := substr(from_stmt,1,x-1);
  retarr(ctr) := trim(tbl);
  from_stmt := substr(from_stmt,x+1);
  ctr := ctr + 1;
 end loop;
 retarr(ctr) := trim(from_stmt);
 for j in retarr.first..retarr.last loop
  if instr(retarr(j),'.') = 0
   then
    retarr(j) := user || '.' || retarr(j); -- Attach current schema name to name just in case it is appended
  end if;
  x := instr(retarr(j),' '); -- Strip any Alias Names (need to review this as the alias names are needed
  if x > 0
   then
    retarr(j) := '[' || substr(retarr(j),x+1) || ']' || substr(retarr(j),1,x-1);
  end if;
 end loop;
 return( retarr );
 exception when others then
  glbx.error_details( 'OLTP', 'EXTRACT_FROM_CLAUSE',null,null,errmsg=>sqlerrm);
end extract_from_clause;

function attach_where_clause( sqlstmt in varchar2, where_clause in varchar2 )
 return varchar2
as

 x		integer;
 no_where	boolean;

begin

 no_where := FALSE;
 x := instr( upper(sqlstmt), ' WHERE ' );
 if x = 0 -- No Where Clause
  then
   no_where := TRUE;
   x := instr( upper(sqlstmt), ' GROUP ' ); -- Find a Group By Clause
   if x = 0
    then
     x := instr( upper(sqlstmt), ' ORDER ' ); -- No Group By, try an Order By
     if x = 0
      then
       x := length( sqlstmt ) + 1;
     end if;
   end if;
 else
  x := x + 6;
 end if;

 -- x now points to where we wish to stick the where_clause
 if no_where
  then
   return( substr(sqlstmt,1,x) || ' WHERE ' || where_clause || ' ' || substr(sqlstmt,x+1) );
  else
   return( substr(sqlstmt,1,x) || where_clause || ' and ' || substr(sqlstmt,x+1) );
 end if;
 exception when others then
  glbx.error_details( 'OLTP', 'ATTACH_WHERE_CLAUSE',null,null,errmsg=>sqlerrm);
end attach_where_clause;

function check_column_security( acid in integer, tname in varchar2, col_name in GLBX.MYARRAY, col_value in GLBX.MYARRAY )
 return varchar2
as

 cursor c1(acid integer, tname varchar2) is
  select prr.if_column, prr.if_expression, prr.if_value, prr.if_value_type, prr.if_action
  from piction_roles pr, piction_roles_rules prr, customer_roles cr
  where cr.aid = acid and
        cr.role_id = prr.role_id and
        prr.role_id = pr.role_id and
        pr.role_type = 'TABLE' and
        prr.restriction_type = 'COLUMN' and
        upper(nvl(prr.table_owner,user) || '.'  || prr.table_name) = tname;

begin
 for c1rec in c1(acid,tname) loop
  for j in col_name.first..col_name.last loop
   if col_name(j) = c1rec.if_column
    then
     if c1rec.if_expression = '='
      then
       if c1rec.if_value = col_value(j)
        then
         if c1rec.if_action = 'DISABLE EDIT' then return( 'B' ); elsif c1rec.if_action = 'DISABLE BROWSE' then return( 'N' ); else return( 'E' ); end if;
       end if;
     elsif c1rec.if_expression = '<'
      then
       if c1rec.if_value > col_value(j)
        then
         if c1rec.if_action = 'DISABLE EDIT' then return( 'B' ); elsif c1rec.if_action = 'DISABLE BROWSE' then return( 'N' ); else return( 'E' ); end if;
       end if;
     end if;
     elsif c1rec.if_expression = '>'
      then
       if c1rec.if_value < col_value(j)
        then
         if c1rec.if_action = 'DISABLE EDIT' then return( 'B' ); elsif c1rec.if_action = 'DISABLE BROWSE' then return( 'N' ); else return( 'E' ); end if;
       end if;
     elsif c1rec.if_expression = '<='
      then
       if c1rec.if_value >= col_value(j)
        then
         if c1rec.if_action = 'DISABLE EDIT' then return( 'B' ); elsif c1rec.if_action = 'DISABLE BROWSE' then return( 'N' ); else return( 'E' ); end if;
       end if;
     elsif c1rec.if_expression = '>='
      then
       if c1rec.if_value <= col_value(j)
        then
         if c1rec.if_action = 'DISABLE EDIT' then return( 'B' ); elsif c1rec.if_action = 'DISABLE BROWSE' then return( 'N' ); else return( 'E' ); end if;
       end if;
     elsif c1rec.if_expression = '<>'
      then
       if c1rec.if_value <> col_value(j)
        then
         if c1rec.if_action = 'DISABLE EDIT' then return( 'B' ); elsif c1rec.if_action = 'DISABLE BROWSE' then return( 'N' ); else return( 'E' ); end if;
       end if;
     elsif c1rec.if_expression = 'IS NULL'
      then
       if col_value(j) is null
        then
         if c1rec.if_action = 'DISABLE EDIT' then return( 'B' ); elsif c1rec.if_action = 'DISABLE BROWSE' then return( 'N' ); else return( 'E' ); end if;
       end if;
     elsif c1rec.if_expression = 'LIKE'
      then
       if col_value(j) like c1rec.if_value
        then
         if c1rec.if_action = 'DISABLE EDIT' then return( 'B' ); elsif c1rec.if_action = 'DISABLE BROWSE' then return( 'N' ); else return( 'E' ); end if;
       end if;
   end if;
  end loop;
 end loop;
 return( 'E' );
 exception when others then
  glbx.error_details( 'OLTP', 'CHECK_COLUMN_SECURITY',null,acid,errmsg=>sqlerrm);
end check_column_security;


procedure quick_delete( scr_name in varchar2 )
as

begin

delete from oltp_business_rule where screen_id = (select screen_id from oltp_overview where screen_name = scr_name);
delete from oltp_object where screen_id = (select screen_id from oltp_overview where screen_name = scr_name);
delete from oltp_overview where screen_name = scr_name;

 exception when others then
  glbx.error_details( 'OLTP', 'QUICK_DELETE',null,null,errmsg=>sqlerrm);
end quick_delete;

procedure quick_modify( scr_name in varchar2, action in varchar2, column_name in varchar2, action_column in varchar2, action_value in varchar2 )
as

 cursor c1( actcol varchar2 ) is select 'x' from user_tab_columns where table_name = 'OLTP_OBJECT' and column_name = actcol;
 cursor c2( scr_name varchar2 ) is select screen_id from oltp_overview where screen_name = scr_name;

 tmp	char(1);
 scid	integer;
 nmb	integer;

begin

 open c2( scr_name );
 fetch c2 into scid;
 if c2%NOTFOUND
  then
   close c2;
   dbms_output.put_line( 'Screen Not Found: ' || scr_name );
   return;
 end if;
 close c2;

 if action = 'DELETE'
  then
   delete from oltp_object
    where
     screen_id = scid and
     original_column = upper(column_name);
   commit;
   dbms_output.put_line( 'Column Deleted:' || upper(column_name) );
   return;
 end if;

 if action = 'UPDATE'
  then
   open c1( upper(action_column) );
   fetch c1 into tmp;
   if c1%FOUND
    then
     close c1;
    else
     close c1;
     dbms_output.put_line( 'Bad Action Column:' || action_column );
     return;
  end if;
 end if;

 if action = 'UPDATE'
  then
   execute immediate 'update oltp_object set ' || action_column || ' = :1 where screen_id = :2 and original_column = :3' using action_value,scid,upper(column_name);
   commit;
  elsif action = 'ATTRIBUTE'
   then
   select max(oltp_id) + 1 into nmb from oltp_object;
   insert into oltp_object (oltp_id,screen_id,primary_secondary,screen_order,object_type,data_type,data_length,display_length,
                         original_column,htmltable_name,display,mandatory,use_censor,javascript_validate,
                         convert_uppercase,default_value,display_text,help_text,
                         lov_list,lov_select,can_be_queried_on,can_be_resorted_on,
                         font_face,font_pitch,font_colour,font_align,font_valign,
                         attribute_type,attribute_prebuilt,is_primary_key,generate_pk,
                         umo_id,range_low,range_high,textbox_width,textbox_height)
    values
                         (nmb,scid,'PRIMARY',nmb,'ATTRIBUTE',null,null,null,
                          null,null,null,null,null,null,
                          null,null,null,null,
                          null,null,'F','F',
                          null,null,null,null,null,
                          action_column,action_value,'F',null,
                          null,null,null,null,null);
 end if;
 dbms_output.put_line( 'Action Performed' );
exception
 when others then
  dbms_output.put_line( 'Error Encountered:' || sqlerrm );
end quick_modify;

procedure quick_modify_screen( scr_name in varchar2, action_column in varchar2, action_value in varchar2 )
as

 cursor c1( actcol varchar2 ) is select 'x' from user_tab_columns where table_name = 'OLTP_OVERVIEW' and column_name = actcol;
 cursor c2( scr_name varchar2 ) is select screen_id from oltp_overview where screen_name = scr_name;

 tmp	char(1);
 scid	integer;

begin

 open c2( scr_name );
 fetch c2 into scid;
 if c2%NOTFOUND
  then
   close c2;
   dbms_output.put_line( 'Screen Not Found: ' || scr_name );
   return;
 end if;
 close c2;

 open c1( upper(action_column) );
 fetch c1 into tmp;
 if c1%FOUND
  then
   close c1;
  else
   close c1;
   dbms_output.put_line( 'Bad Action Column:' || action_column );
   return;
 end if;

 if upper(action_column) = 'MENU_ORDERBY'
  then
   execute immediate 'update oltp_overview set ' || action_column || ' = :1 where menu_call = :2' using action_value,scr_name;
  else
   execute immediate 'update oltp_overview set ' || action_column || ' = :1 where screen_id = :2' using action_value,scid;
 end if;
 commit;
 dbms_output.put_line( 'Action Performed' );
exception
 when others then
  dbms_output.put_line( 'Error Encountered:' || sqlerrm );
end quick_modify_screen;

procedure quick_create( ownr in varchar2, tbl_name in varchar2, scr_type in varchar2, scr_name in varchar2, grp_col in varchar2 default null, ordby in varchar2 default null, laf in varchar2 default null )
as

 cursor c1(ownr varchar2, tbl_name varchar2 ) is
  select column_name,data_type,data_length,nullable,data_default,low_value,high_value
  from all_tab_columns
  where owner = ownr and
        table_name = tbl_name and
        data_type in ('CHAR','VARCHAR2','NUMBER','DATE','FLOAT')
  order by column_id;


 cursor c1a(ownr varchar2, proc_name varchar2 ) is
  select argument_name column_name,data_type,data_length,'F' nullable,default_value data_default,null low_value,null high_value
  from all_arguments
  where owner = ownr and
        object_name = proc_name
  order by position;

 cursor c1b(ownr varchar2, proc_name varchar2 ) is
  select argument_name column_name,data_type,data_length,'F' nullable,default_value data_default,null low_value,null high_value
  from all_arguments
  where owner = ownr and
        object_name = proc_name and
        package_name = 'STRANGP'
  order by position;


 cursor c2 is select max(screen_id) from oltp_overview;

 nmb	integer;
 nmb2	integer;

begin

if scr_type = 'MENU'
 then
  delete from oltp_overview where menu_call = tbl_name;
 else
  delete from oltp_business_rule where screen_id = (select screen_id from oltp_overview where screen_name = scr_name);
  delete from oltp_object where screen_id = (select screen_id from oltp_overview where screen_name = scr_name);
  delete from oltp_overview where screen_name = scr_name;
end if;

open c2;
fetch c2 into nmb;
close c2;
nmb := nvl(nmb,0) + 1;

if scr_type = 'REPORT'
 then
  insert into oltp_overview (screen_id,screen_name,screen_type,primary_table,secondary_table,help_id,look_and_feel,business_feature,
                           display_datatype_icon,alternate_colours,on_query_totrows,confirm_delete,order_by,menu_display,menu_name,menu_call,menu_orderby,
                           screen_height,group_column,security_role,display_group_col_ctr) values
 (nmb,scr_name,upper(nvl(scr_type,'SINGLE')),upper(ownr || '.' || tbl_name),null,'K01',laf,'GENERIC',
  'T','T','T','T',ordby,'T',null,tbl_name,1,
  0,upper(grp_col),null,'T');
  commit;
  return;
elsif scr_type = 'MENU'
 then
  insert into oltp_overview (screen_id,screen_name,screen_type,primary_table,secondary_table,help_id,look_and_feel,business_feature,
                           display_datatype_icon,alternate_colours,on_query_totrows,confirm_delete,order_by,menu_display,menu_name,menu_call,menu_orderby,
                           screen_height,group_column,security_role,display_group_col_ctr) values
 (nmb,scr_name,'MENU',null,null,'K01',laf,'GENERIC',
  'T','T','T','T',ordby,'T',ownr,tbl_name,1,
  0,upper(grp_col),null,'T');
  commit;
  return;
 else
  insert into oltp_overview (screen_id,screen_name,screen_type,primary_table,secondary_table,help_id,look_and_feel,business_feature,
                           display_datatype_icon,alternate_colours,on_query_totrows,confirm_delete,order_by,menu_display,menu_name,menu_call,menu_orderby,
                           screen_height,group_column,security_role,display_group_col_ctr) values
 (nmb,scr_name,upper(nvl(scr_type,'SINGLE')),upper(ownr || '.' || tbl_name),null,'K01',laf,'GENERIC',
  'T','T','T','T',ordby,'T',null,null,1,
  0,upper(grp_col),null,'T');
end if;

if scr_type = 'PROCEDURE'
 then
  for c1rec in c1a(upper(ownr),upper(tbl_name)) loop
   select max(oltp_id) + 1 into nmb2 from oltp_object;
   nmb2 := nvl(nmb2,1);
   insert into oltp_object (oltp_id,screen_id,primary_secondary,screen_order,object_type,data_type,data_length,display_length,
                            original_column,htmltable_name,display,mandatory,use_censor,javascript_validate,
                            convert_uppercase,default_value,display_text,help_text,
                            lov_list,lov_select,can_be_queried_on,can_be_resorted_on,
                            font_face,font_pitch,font_colour,font_align,font_valign,
                            attribute_type,attribute_prebuilt,is_primary_key,generate_pk,
                            umo_id,range_low,range_high,textbox_width,textbox_height)
   values
                           (nmb2,nmb,'PRIMARY',nmb2,'COLUMN',decode(c1rec.data_type,'CHAR','VARCHAR','VARCHAR2','VARCHAR','FLOAT','NUMBER',c1rec.data_type),null,decode(c1rec.data_type,'VARCHAR',least(60,c1rec.data_length),'NUMBER',10,'DATE',20,c1rec.data_length),
                            c1rec.column_name,'GROUP1','T',decode(c1rec.nullable,'Y','F','T'),'F','F',
                            'F',c1rec.data_default,initcap(c1rec.column_name),initcap(c1rec.column_name),
                            null,null,'T','T',
                            null,null,null,null,null,
                            null,null,'T',null,
                            null,null,null,null,null);
  end loop;
elsif scr_type = 'PACKAGE'
 then
  for c1rec in c1b(upper(ownr),upper(tbl_name)) loop
   select max(oltp_id) + 1 into nmb2 from oltp_object;
   nmb2 := nvl(nmb2,1);
   insert into oltp_object (oltp_id,screen_id,primary_secondary,screen_order,object_type,data_type,data_length,display_length,
                            original_column,htmltable_name,display,mandatory,use_censor,javascript_validate,
                            convert_uppercase,default_value,display_text,help_text,
                            lov_list,lov_select,can_be_queried_on,can_be_resorted_on,
                            font_face,font_pitch,font_colour,font_align,font_valign,
                            attribute_type,attribute_prebuilt,is_primary_key,generate_pk,
                            umo_id,range_low,range_high,textbox_width,textbox_height)
   values
                           (nmb2,nmb,'PRIMARY',nmb2,'COLUMN',decode(c1rec.data_type,'CHAR','VARCHAR','VARCHAR2','VARCHAR','FLOAT','NUMBER',c1rec.data_type),null,decode(c1rec.data_type,'VARCHAR',least(60,c1rec.data_length),'NUMBER',10,'DATE',20,c1rec.data_length),
                            c1rec.column_name,'GROUP1','T',decode(c1rec.nullable,'Y','F','T'),'F','F',
                            'F',c1rec.data_default,initcap(c1rec.column_name),initcap(c1rec.column_name),
                            null,null,'T','T',
                            null,null,null,null,null,
                            null,null,'T',null,
                            null,null,null,null,null);
  end loop;
 else
  for c1rec in c1(upper(ownr),upper(tbl_name)) loop
   select max(oltp_id) + 1 into nmb2 from oltp_object;
   nmb2 := nvl(nmb2,1);
   insert into oltp_object (oltp_id,screen_id,primary_secondary,screen_order,object_type,data_type,data_length,display_length,
                            original_column,htmltable_name,display,mandatory,use_censor,javascript_validate,
                            convert_uppercase,default_value,display_text,help_text,
                            lov_list,lov_select,can_be_queried_on,can_be_resorted_on,
                            font_face,font_pitch,font_colour,font_align,font_valign,
                            attribute_type,attribute_prebuilt,is_primary_key,generate_pk,
                            umo_id,range_low,range_high,textbox_width,textbox_height)
   values
                           (nmb2,nmb,'PRIMARY',nmb2,'COLUMN',decode(c1rec.data_type,'CHAR','VARCHAR','VARCHAR2','VARCHAR','FLOAT','NUMBER',c1rec.data_type),null,decode(c1rec.data_type,'VARCHAR',least(60,c1rec.data_length),'NUMBER',10,'DATE',20,c1rec.data_length),
                            c1rec.column_name,'GROUP1','T',decode(c1rec.nullable,'Y','F','T'),'F','F',
                            'F',c1rec.data_default,initcap(c1rec.column_name),initcap(c1rec.column_name),
                            null,null,'T','T',
                            null,null,null,null,null,
                            null,null,'T',null,
                            null,null,null,null,null);
  end loop;
end if;

nmb2 := nvl(nmb2,1);
insert into oltp_object (oltp_id,screen_id,primary_secondary,screen_order,object_type,data_type,data_length,display_length,
                         original_column,htmltable_name,display,mandatory,use_censor,javascript_validate,
                         convert_uppercase,default_value,display_text,help_text,
                         lov_list,lov_select,can_be_queried_on,can_be_resorted_on,
                         font_face,font_pitch,font_colour,font_align,font_valign,
                         attribute_type,attribute_prebuilt,is_primary_key,generate_pk,
                         umo_id,range_low,range_high,textbox_width,textbox_height)
 values
                         (nmb2+1,nmb,'PRIMARY',nmb2+1,'ATTRIBUTE',null,null,null,
                          null,null,null,null,null,null,
                          null,null,null,null,
                          null,null,'F','F',
                          null,null,null,null,null,
                          'CONTROL BAR','TTTTTTTTT','F',null,
                          null,null,null,null,null);


insert into oltp_object (oltp_id,screen_id,primary_secondary,screen_order,object_type,data_type,data_length,display_length,
                         original_column,htmltable_name,display,mandatory,use_censor,javascript_validate,
                         convert_uppercase,default_value,display_text,help_text,
                         lov_list,lov_select,can_be_queried_on,can_be_resorted_on,
                         font_face,font_pitch,font_colour,font_align,font_valign,
                         attribute_type,attribute_prebuilt,is_primary_key,generate_pk,
                         umo_id,range_low,range_high,textbox_width,textbox_height)
 values
                         (nmb2+2,nmb,'PRIMARY',nmb2+2,'ATTRIBUTE',null,null,null,
                          null,null,null,null,null,null,
                          null,null,null,null,
                          null,null,'F','F',
                          null,null,null,null,null,
                          'CELL COLOUR','F0FFF0','F',null,
                          null,null,null,null,null);

commit;

exception
 when others
  then htp.p( 'QC:' || sqlerrm ); dbms_output.put_line( sqlerrm );
end quick_create;

procedure form_report( surl in varchar2, repid in integer, reploc in varchar2 )
as

fl	UTL_FILE.FILE_TYPE;
bufr	varchar2(32767);
vfdir	varchar2(1000);
vfname	varchar2(1000);

begin

 vfdir := glbx.extract_fname( reploc,'PWD');
 vfname := glbx.extract_fname(reploc,'FILENAME');

 begin
  fl := utl_file.fopen( vfdir, vfname, 'r', max_linesize=>32767 );
 exception
  when others then
   htp.htmlopen;
   htp.header(2, 'Unable to find Physical Report File', 'CENTER' );
   htp.htmlclose;
   return;
 end;

 loop

  begin
   utl_file.get_line(fl,bufr);
  exception
   when others then exit;
  end;
  -- bufr := bufr || chr(10);
  if instr(bufr,'<FORM DETAILS>') > 0
   then
    htp.formopen( 'oltp.accept_form' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'REPID', repid );
    --htp.formhidden( 'P1', repid );
    --htp.formsubmit( null,'SUB');
    --htp.formclose;
   else
    if instr(bufr,'</FORM DETAILS>') > 0
     then
      htp.formsubmit( null, 'Submit Form' );
      htp.formclose;
     else
      htp.p( bufr );
    end if;
  end if;
 end loop;

 utl_file.fclose(fl);


 exception when others then
  glbx.error_details( 'OLTP', 'FORM_REPORT',null,null,errmsg=>sqlerrm);
end form_report;

procedure accept_form( surl in varchar2, repid in varchar2, p1 in GLBX.MYARRAY )
as

cursor c1(repid integer) is select * from report_queue where report_queue_id = repid;
cursor c3(repid integer) is select * from report_definition where report_id = repid;
cursor c4(v_umo integer) is select doc_html, document_original_loc from umo where umo_id = v_umo for update;
cursor c5(usc integer) is select title from umo_scene where umo_scene_id = usc;

c1rec		c1%ROWTYPE;
c3rec		c3%ROWTYPE;
c4rec		c4%ROWTYPE;
fl		UTL_FILE.FILE_TYPE;
bufr		varchar2(32767);
vfdir		varchar2(1000);
vfname		varchar2(1000);
ltype		varchar2(100);
sts		varchar2(100);
ttl		varchar2(100);
oloc		varchar2(1000);
stype		integer;
owner_id	integer;
newid		integer;
newrep		integer;
ctr		integer;
m		integer;
n		integer;
x		integer;
v_count		integer;
v_int		integer;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'OLTP.DISPLAY_REPORTS' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 GBL_SURL := surl;
 GBL_LTYPE := ltype;
 GBL_STYPE := stype;

 open c3(repid);
 fetch c3 into c3rec;
 close c3;

 dbms_lob.createtemporary(Gout_clob, FALSE);
 ctr := 0;

 vfdir := glbx.extract_fname( c3rec.physical_location,'PWD');
 vfname := glbx.extract_fname( c3rec.physical_location,'FILENAME');

 fl := utl_file.fopen( vfdir, vfname, 'r', max_linesize=>32767 );

 loop

  begin
   utl_file.get_line(fl,bufr);
  exception
   when others then exit;
  end;

  if instr(bufr,'<FORM DETAILS>') > 0
   then
    null;
  elsif instr(bufr,'</FORM DETAILS>') > 0
   then
    null;
  elsif instr(bufr,'<INPUT TYPE="TEXT"') > 0
   then
    ctr := ctr + 1;
    if ctr > p1.last then ctr := p1.last; end if;
    m := instr(bufr,'<INPUT TYPE="TEXT"');
    n := instr(bufr,'>',m);
    bufr := substr(bufr,1,m-1) || htf.bold(p1(ctr)) || substr(bufr,n+1);
    clob_append( bufr );
  else
    clob_append( bufr );
  end if;

 end loop;

 utl_file.fclose(fl);

 if GBufr is not null
  then
   dbms_lob.writeappend(Gout_clob,length(GBufr),GBufr);
 end if;

 select s_report_queue_id.nextval into newid from dual;
 insert into report_queue(report_queue_id,report_id,sessid,aid,submit_time,run_every_1,run_every_2,run_every_3,priority,notification,autoexpire,status)
  values
   (newid,repid,owner_id,owner_id,sysdate,null,null,null,'A',null,null,LNG2.PFM_TXT_140);

 open c1(newid);
 fetch c1 into c1rec;
 close c1;

 if dbms_lob.getlength( Gout_clob ) = 0
  then
   update report_queue set status = LNG3.ADM_TXT_521 where report_queue_id = newid;
   commit;
   view_report(surl);
   return;
  else
   delete from report_queue where report_queue_id = newid;
 end if;

 open c5(c3rec.umo_scene_id);
 fetch c5 into ttl;
 close c5;
 select s_umo.nextval into newid from dual;
 if glbx.extract_master_parameter('REPORTS_DATABASE') = 'TRUE'
  then
   insert into umo(umo_id,aid,umo_type,umo_owner,umo_scene_id,version,
                   extras,doc_html,date_created,expire_date,report_id,document_original_loc)
    values
     (newid,c1rec.aid,'REPORT','OWNER',c3rec.umo_scene_id,1,repeated_fields(null,null,null,ttl,null,
      c3rec.report_name,null,nvl(DEFSECURITY,'FALSE'),'FALSE'),
      empty_clob(),sysdate,sysdate+c1rec.autoexpire,c1rec.report_id,c3rec.physical_location);
  else
   oloc := glbx.extract_master_parameter('MAIL_OUTPUT_DIR');
   insert into umo(umo_id,aid,umo_type,umo_owner,umo_scene_id,version,
                   extras,doc_html,date_created,expire_date,report_id,document_original_loc)
    values
     (newid,c1rec.aid,'REPORT','OWNER',c3rec.umo_scene_id,1,repeated_fields(null,null,null,ttl,null,
      c3rec.report_name,null,nvl(DEFSECURITY,'FALSE'),'FALSE'),
      empty_clob(),sysdate,sysdate+c1rec.autoexpire,c1rec.report_id,oloc);
 end if;
 commit;
 open c4( newid );
 fetch c4 into c4rec;
 close c4;

 if glbx.extract_master_parameter('REPORTS_DATABASE') = 'TRUE'
  then
   dbms_lob.copy(c4rec.doc_html,Gout_clob,dbms_lob.getlength( Gout_clob ));
   update umo set doc_html = c4rec.doc_html where umo_id = newid;
  else
   -- Write to File
    fl := utl_file.fopen( c4rec.document_original_loc, 'report_' || newid || '.html', 'w', max_linesize=>32767 );
    v_count := 0;
    v_int := 10000; --255
    LBufr := NULL;
    begin
     loop
      dbms_lob.read(Gout_clob,v_int,(v_count*10000)+1,bufr);
      v_count := v_count + 1;
      LBufr := lBufr || bufr;
      x := instr(lBufr,' ',-1);
      if x = 0
       then
        bufr := LBufr;
        LBufr := NULL;
       else
        bufr := substr(LBufr,1,x-1);
        LBufr := substr(LBufr,x);
      end if;
      utl_file.put_line( fl, buffer=>bufr );
     end loop;
    exception
     when no_data_found then null;
    end;
    if LBufr is not null then utl_file.put_line( fl, buffer=>Lbufr ); LBufr := NULL; end if;
    utl_file.fclose(fl);
    update umo um set um.extras.orderby_nmb = dbms_lob.getlength(Gout_clob) where umo_id = newid;
 end if;
 -- dbms_lob.freetemporary( Gout_clob );
 free_temporary_lob;

 insert into report_queue_log(report_queue_id,report_id,activity_type,activity_date,activity_result) values
  (repid,c1rec.report_id,'HTML',sysdate,to_char(newid));
 commit;
 view_report(surl);

 exception when others then
  glbx.error_details( 'OLTP', 'ACCEPT_FORM',null,null,errmsg=>sqlerrm);
  begin clob_append( sqlerrm ); exception when others then null; end;
  free_temporary_lob;
end accept_form;

function security_role( acid in integer )
 return varchar2
as

 cursor c1(acid integer) is select role_name from customer_roles cr, piction_roles pr where cr.aid = acid and cr.role_id = pr.role_id and role_type = 'SECURITY ROLE';

 c1rec  c1%ROWTYPE;

begin
 open c1(acid);
 fetch c1 into c1rec;
 close c1;
 return( c1rec.role_name );
exception
 when others then return( null );
end security_role;

procedure identify_user( acid in integer )
as
  cursor c1(acid integer) is
   select decode( role_name, 'ADELAIDE','ADL','BRISBANE','BNE','MELBOURNE','MEL','PERTH','PER','SYDNEY','SYD','TOWNSVILLE','TVL','CAIRNS','CNS','KIUNGA','KIU',substr(role_name,9)) rname
   from customer_roles cr, piction_roles pr
   where pr.role_id = cr.role_id and
         cr.aid = acid and
         pr.role_type = 'PARAMETER';
   c1rec c1%ROWTYPE;
 begin
  open c1(acid);
  fetch c1 into c1rec;
  close c1;
  USER_SITE := nvl(c1rec.rname,'SYD');
end identify_user;

function f_user_site
 return varchar2
as
begin
 return( USER_SITE );
end f_user_site;

procedure empty_file(umo_rec in umo%ROWTYPE, is_lob in varchar2)
as
 fl	UTL_FILE.FILE_TYPE;
begin
 if is_lob = 'TRUE' then return; end if;
 begin
  if umo_rec.object_class = 'HTTP' and upper(umo_rec.document_original_loc) like upper(glbx.extract_master_parameter('STRANG_RECEIVALS_DIR') || '\reports\%')
   then
    if utl_os.delete_file(umo_rec.document_original_loc) then null; end if;
  elsif umo_rec.object_class = 'HTTP' and upper(umo_rec.document_original_loc) not like upper(glbx.extract_master_parameter('STRANG_RECEIVALS_DIR')) || '%'
   then
    fl := utl_file.fopen( glbx.extract_fname(umo_rec.document_original_loc, 'PWD'), glbx.extract_fname(umo_rec.document_original_loc, 'FILE'), 'w', max_linesize=>32767 );
  else
    fl := utl_file.fopen( umo_rec.document_original_loc, 'report_' || umo_rec.umo_id || '.html', 'w', max_linesize=>32767 );
  end if;
 exception when others then return;
 end;
 -- Empty the File by writing an empty value
 utl_file.fclose(fl);

 exception when others then
  glbx.error_details( 'OLTP', 'EMPTY_FILE',null,null,errmsg=>sqlerrm,extdet=>'UMO_ID:' || umo_rec.umo_id);
end empty_file;

procedure free_temporary_lob
as
begin
 dbms_lob.freetemporary( Gout_clob );
exception
 when others
  then null; -- It might already have been freed.
end free_temporary_lob;

procedure zip( zip_filename in varchar2, file_to_add in varchar2 )
as
  display_output GLBX.MYARRAY;
  bl		 boolean;
 begin
 --glbx.dbg('Fromm:' || zip_filename );
 --glbx.dbg( 'To:' || file_to_add);
  if glbx.extract_master_parameter('REPORTS_DATABASE') = 'TRUE' then return; end if; -- only zips if files are stored outside the database
  bl := os_command.zip( zip_filename, FALSE, FALSE, file_to_add, display_output );
  dbms_lock.sleep(2);
exception when others then null;
end zip;

function ziprepname( rname in varchar2, dt in varchar2 )
 return varchar2
as
begin
 if GBL_REP is not null then return( GBL_REP ); end if;
 GBL_REP := replace(rname || '_' || dt,' ','_');
 -- glbx.dbg( 'F:' || GBL_REP );
 return( GBL_REP );
end ziprepname;

end oltp;
/


GRANT EXECUTE ON WEBSYS.OLTP TO STRANG;
