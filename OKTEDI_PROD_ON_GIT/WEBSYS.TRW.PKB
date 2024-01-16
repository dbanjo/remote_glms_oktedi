CREATE OR REPLACE package body WEBSYS.trw
as

 function cleanup_url( url in varchar2 ) return varchar2;
 function extract_site( prnt varchar2, pg clob, ptr integer, linktype varchar2, endmark in varchar2 ) return varchar2;
 function filter_site( vid in integer, st in varchar2, depth in out integer ) return varchar2;
 function iswebpage( prnt in varchar2 ) return varchar2;
 function remove_dot_dot( url in varchar2 ) return varchar2;
 function setinitial( prnt in varchar2 ) return varchar2;
 procedure retrieve_html( id in integer, depth in out integer, st in varchar2, contenttype in varchar2, pieces in out nocopy utl_http.html_pieces, result out varchar2 );
 procedure initialise( acid in integer, st in varchar2, depth in integer, v_umo out integer, parent_site in integer, result out varchar2 );
 procedure add_to_database( v_umo in integer, pieces in utl_http.html_pieces, pg out clob, contenttype in varchar2, init in boolean, result out varchar2 );
 procedure log_result( vid in integer, v_umo integer, st varchar2, res varchar2 );
 procedure extract_site_html( id in integer, acid in integer, st in varchar2, depth in integer, parent_site in integer, contenttype in varchar2 default 'DATA', image_alt_tag in varchar2 default null );
 procedure extract_site_odbc( crec in web_trawl_driver%ROWTYPE );
 procedure strip_xml( v_umo in integer, crec in web_trawl_driver%ROWTYPE, dr in varchar2, fn in varchar2 );
 procedure parsedoc(v_umo in integer, crec in web_trawl_driver%ROWTYPE, doc in sys.xmldom.DOMDocument) ;
 procedure odbc_init( v_umo out integer, stmt in varchar2, crec in web_trawl_driver%ROWTYPE );

 function extract_site( prnt varchar2, pg clob, ptr integer, linktype varchar2, endmark in varchar2 )
  return varchar2
 as
  str varchar2(4000);
  x   integer;
  y   integer;
  z   integer;
  m   integer;
 begin

  if linktype = 'ALT'
   then
    str := dbms_lob.substr( pg, 1000, ptr );
    -- ALT Tags are data and not links
    m := 5;
    x := instr( upper(str), 'ALT=' );
    if x = 0 then x := instr( upper(str), 'ALT =' ); m:=6; end if;
    if x = 0 then return( null ); end if;
    x := x + m;
    if z < x then return( null ); end if;
    y := instr( upper(str), '"', x + 1 );
    return(substr( str, x, (y-x) ));

  elsif linktype = 'TITLE'
   then
    str := dbms_lob.substr( pg, 1000, ptr );
    -- Title Tags are data and not links
    m := 7;
    x := instr( str, 'TITLE=' );
    if x = 0 then x := instr( upper(str), 'TITLE =' ); m:=8; end if;
    if x = 0 then return( null ); end if;
    x := x + 6;
    if z < x then return( null ); end if;
    y := instr( upper(str), ' ', x + 1 );
    return(substr( str, x, (y-x) ));
  end if;

  -- Links canbe no longer than 1000 characters.
  str := replace(dbms_lob.substr( pg, 1000, ptr ),' ','') || ' '; -- space added to last character as space is now a token terminator
  -- Cut down to 1000 chars to improve performance
  -- Remove " as some sites might not conform to standard HTML
  str := upper(str);
  z := instr(str,endmark);
  str := replace(str,'"',' ');
  -- token separator is now a space
  str := replace(str,'>',' ');
  str := replace(str,'<',' ');
  str := replace(str,'= ','='); -- so further calculations are valid

  if str is null then return( null ); end if;
  -- The end marker ensures the URL extracted belongs within the tag

  if linktype = 'FRAME'
   then
    x := instr( str, 'SRC=' );
    if x = 0 then return( null ); end if;
    x := x + 4;
    if z < x then return( null ); end if;
    y := instr( upper(str), ' ', x + 1 );
    str := substr( str, x, (y-x) );

  elsif linktype = 'ANCHOR'
   then
    x := instr( str, 'HREF=' );
    if x = 0 then return( null ); end if;
    x := x + 5;
    if z < x then return( null ); end if;
    y := instr( upper(str), ' ', x + 1 );
    str := substr( str, x, (y-x) );

  elsif linktype = 'URL'
   then
    x := instr( str, 'URL=' );
    if x = 0 then return( null ); end if;
    x := x + 4;
    if z < x then return( null ); end if;
    y := instr( upper(str), ' ', x + 1 );
    str := substr( str, x, (y-x) );

  elsif linktype = 'SRC'
   then
    x := instr( str, 'SRC=' );
    if x = 0 then return( null ); end if;
    x := x + 4;
    if z < x then return( null ); end if;
    y := instr( upper(str), ' ', x + 1 );
    str := substr( str, x, (y-x) );

  end if;

  if upper(substr(str,1,7)) = 'MAILTO:'
   then
    return( null );

  elsif upper(substr(str,1,4)) = 'FTP:'
   then
    return( null );

  elsif upper(substr(str,1,5)) = 'HTTP:'
   then
    return( cleanup_url(str) );

  elsif upper(substr(str,1,11)) = 'JAVASCRIPT:'
   then
    -- handle javascript calls
    -- search for URL in Javascript? xx.xx.location = ''
    -- cannot progress further
    return( null );

  elsif substr(str,1,1) = '/'
   then
    -- Reset it back to the home page
    return( setinitial(prnt || '/') || str );

   else
    return( cleanup_url(iswebpage(prnt) || '/' || str) );

  end if;

  return( null );
 exception
  when others then dbms_output.put_line( 'ES:' || sqlerrm ); return( str );
 end extract_site;

 function iswebpage( prnt in varchar2 )
  return varchar2
 as
  tmp	varchar2(4000);
  x	integer;
 begin

  x := instr( prnt, '.', -1, 1 );
  if x = 0 then return( prnt ); end if;
  tmp := upper(substr( prnt, x + 1 ));
  if tmp in ('HTML','HTM','ASP','EXE','CGI')
   then
    x := instr( prnt, '/', -1, 1 );
    return( substr( prnt, 1, x - 1 ) );
   else
    return( prnt );
  end if;

 end iswebpage;

 function setinitial( prnt in varchar2 )
  return varchar2
 as
  tmp	varchar2(4000);
  x	integer;
 begin
  if upper(substr(prnt,1,7)) = 'HTTP://'
   then
    x := instr( prnt, '/', 1, 3 );
  elsif upper(substr(prnt,1,6)) = 'FTP://'
   then
    x := instr( prnt, '/', 1, 3 );
  else
   return( prnt );
  end if;
  return( substr(prnt, 1, x-1 ) );
 end setinitial;

 -- http://mars.piction.com/products/government/../../index.html
 -- http://mars.piction.com/index.html
 -- http://mars.piction.com/products/lab/lab_index.html/../../index.html
 -- http://mars.piction.com/products/../index.html
 function remove_dot_dot( url in varchar2 )
  return varchar2
 as
  vurl	varchar2(4000);
  x	integer;
  y	integer;
 begin
  vurl := url;
  for j in 1..100 loop
   x := instr(vurl,'/../');
   if x = 0 then exit; end if;
   y := instr(vurl,'/', -1*(length(vurl)-x),2);
   vurl := substr(vurl,1,y-1) || substr(vurl,x+3);
  end loop;
  return( vurl );
 exception
  when others then dbms_output.put_line( 'RDD:' || sqlerrm ); return( url );
 end remove_dot_dot;

 function cleanup_url( url in varchar2 )
  return varchar2
 as
  vurl	varchar2(4000);
 begin
  vurl := remove_dot_dot( url );
  if substr( vurl, length(vurl), 1 ) = '/'
   then
    return( substr( vurl, 1, length(vurl) - 1 ) );
   else
    return( vurl );
  end if;
 end cleanup_url;

 function filter_site( vid in integer, st in varchar2, depth in out integer )
  return varchar2
 as
  cursor c1(vid integer) is select * from web_trawl_filter where id = vid order by order_by;
 begin
  if st is null then return( 'Rejected: Null Site' ); end if;

  for c1rec in c1(vid) loop

   if c1rec.rule_type = 'EXTERNAL_SITE'
    then
     if trim(upper(st)) not like upper(c1rec.rule_value) || '%'
      then
       depth := to_number(c1rec.newval);
       return( null );
     end if;
   end if;

   if c1rec.rule_type = 'ACCEPT_MATCH'
    then
     if trim(upper(st)) like upper(c1rec.rule_value) || '%'
      then
       return( null );
     end if;
   end if;

   if c1rec.rule_type = 'REJECT_NOMATCH'
    then
     if trim(upper(st)) not like upper(c1rec.rule_value) || '%'
      then
       return( 'Rejected:' || c1rec.rule_name );
     end if;
   end if;

  end loop;
  return( NULL );

 end filter_site;

 procedure retrieve_html( id in integer, depth in out integer, st in varchar2, contenttype in varchar2, pieces in out nocopy utl_http.html_pieces, result out varchar2 )
 as

   cursor c1(st varchar2) is
    select umo_id, um.sort_priority sp, doc_length, date_created
    from umo um
    where umo_type = 'HTML' and
          attribute6 = st;

   c1rec	c1%ROWTYPE;
   ml 		integer;
   pg		clob;
   result2	varchar2(1000);

 begin

  result := NULL;
  c1rec.date_created := NULL;

  open c1(upper(st));
  fetch c1 into c1rec;
  if c1%FOUND
   then
    close c1;
    result := 'Site Already Exists';
    if c1rec.sp < depth
     then
      update umo um
       set
        um.sort_priority = depth,
        date_updated = sysdate
      where
       umo_id = c1rec.umo_id;
      result := 'Site Exists with Higher Depth';
    end if;
    update umo um
      set
       um.extras.orderby_nmb = nvl(um.extras.orderby_nmb,0) + 1,
       date_updated = sysdate
     where
      umo_id = c1rec.umo_id;
    commit;
   else
    close c1;
  end if;

  result2 := filter_site( id, upper(st), depth );
  if result2 is not null then result := result2; return; end if;

  if (contenttype = 'DATA') and
     (sysdate - nvl(c1rec.date_created,sysdate) > 1 or
      result is null)                                 -- If the site does not exist, or when last accessed is > than 1 day then try again
   then

     pieces := utl_http.request_pieces( st );

     if pieces.count = 0
      then
       result := 'Empty HTML Page Retrieved';
       return;
    end if;

    ml := 0;
    for j in pieces.first..pieces.last loop
     ml := ml + length(pieces(j));
    end loop;

    if c1rec.date_created is not null and
       c1rec.umo_id is not null and
       ml > 0 and
       nvl(c1rec.doc_length,0) <> ml
     then
       add_to_database( c1rec.umo_id, pieces, pg, contenttype, FALSE, result2 );
       result := nvl(result2,'Page differs in size from last entry.');
       return;
    end if;
 end if;

 exception
  when utl_http.INIT_FAILED then result := 'Initialization of the HTTP-callout subsystem fails';
  when utl_http.REQUEST_FAILED then result := 'The HTTP call fails';
  when others then result := 'RH:' || sqlerrm;
 end retrieve_html;

 procedure initialise( acid in integer, st in varchar2, depth in integer, v_umo out integer, parent_site in integer, result out varchar2 )
 as
 begin
  -- umo.document_original_loc = site name
  -- umo.attribute6 = site name in upper case
  -- um.extras.orderby_nmb = frequency
  -- um.sort_priority = level (depth)
  -- um.doc_html = page code

  ump.init( acid=>acid, utype=>'HTML', v_umo=>v_umo );
  update umo um
   set
    parent_id = parent_site,
    sort_priority = depth,
    um.extras.orderby_nmb = 1,
    document_original_loc = st,
    attribute6 = upper(st),
    doc_html = empty_clob(),
    date_created = sysdate
  where umo_id = v_umo;
  commit;

 exception
  when others then result := 'I:' || sqlerrm;
 end initialise;

 procedure add_to_database( v_umo in integer, pieces in utl_http.html_pieces, pg out clob, contenttype in varchar2, init in boolean, result out varchar2 )
 as

  cursor c1( v_umo integer ) is select doc_html,document_original_loc from umo where umo_id = v_umo for update;

 ld		varchar2(32767);
 st		varchar2(4000);
 begin

  if pieces.count = 0 then return; end if;
  open c1( v_umo );
  fetch c1 into pg,st;
  close c1;

  ld := null;
  for j in pieces.first..pieces.last loop
   if length(ld) + length(pieces(j)) > 32767
    then
     dbms_lob.writeappend( pg, length(ld), ld );
     ld := null;
   end if;
   ld := ld || pieces(j);
  end loop;
  dbms_lob.writeappend( pg, length(ld), ld );
  update umo
   set
    doc_length = dbms_lob.getlength( doc_html )
  where
   umo_id = v_umo;
  commit;

 exception
  when others then result := 'ATD:'|| sqlerrm;
 end add_to_database;

 procedure log_result( vid in integer, v_umo integer, st varchar2, res varchar2 )
 as
 begin
  insert into web_trawl_log(id,umo_id,date_created,site_name,result) values (vid, v_umo, sysdate, st, res );
 end log_result;

 procedure extract_site_html( id in integer, acid in integer, st in varchar2, depth in integer, parent_site in integer, contenttype in varchar2 default 'DATA', image_alt_tag in varchar2 default null )
 as

  v_umo		integer;
  vdepth	integer;
  pg		clob;
  result	varchar2(4000);
  pieces	utl_http.html_pieces;
  dbg		varchar2(100);

   procedure nested_search( searchfor in varchar2, srctype in varchar2, endmark in varchar2, contenttype in varchar2 default 'DATA' )
   as
    ctr		integer;
    loc		integer;
   begin
    ctr := 1;
    for j in 1..100 loop
     loc := dbms_lob.instr(pg, searchfor, 1, ctr );
     if nvl(loc,0) = 0 then exit; end if;
      if contenttype = 'DATA'
       then
        extract_site_html( id, acid, extract_site(st, pg, loc, srctype, endmark), vdepth - 1, v_umo, contenttype, null );
       elsif contenttype = 'IMAGE'
        then
        extract_site_html( id, acid, extract_site(st, pg, loc, srctype, endmark), vdepth - 1, v_umo, contenttype, extract_site(st, pg, loc, 'ALT', '>') );
       elsif contenttype = 'LIST'
        then
        extract_site_html( id, acid, extract_site(st, pg, loc, srctype, endmark), vdepth - 1, v_umo, contenttype, extract_site(st, pg, loc, 'TITLE', '>') );
      end if;
     ctr := ctr + 1;
    end loop;
   end nested_search;

 begin
 dbg := '1';
  if depth = 0 then return; end if;
  if st is null then return; end if;
  result := null;
  --
 dbg := '2';
  vdepth := depth;

 dbg := '3';
  retrieve_html( id, vdepth, st, contenttype, pieces, result );
  if result is not null then log_result( id, v_umo, st, result ); return; end if;

 dbg := '5';
  if contenttype = 'IMAGE'
   then
    if image_alt_tag is not null
     then
      pieces(1) := image_alt_tag;
     else
      pieces(1) := 'No ALT Tag for this Binary Image';
    end if;
  end if;

  initialise( acid, st, vdepth, v_umo, parent_site, result );
  if result is not null then log_result( id, v_umo, st, result ); return; end if;
  add_to_database( v_umo, pieces, pg, contenttype, TRUE, result );
  if result is not null then log_result( id, v_umo, st, result ); return; end if;

  if contenttype = 'IMAGE' then return; end if;

  -- Cleanup to avoid memory leak
 dbg := '6';
  pieces.delete;

 dbg := '7';
  log_result( id, v_umo, st, 'New Site Added' );
  nested_search( '<A ', 'ANCHOR','</A>' );
  nested_search( '<a ', 'ANCHOR','</A>' );
  nested_search( '<FRAME ', 'FRAME','>' );
  nested_search( '<frame ', 'FRAME','>' );
  nested_search( '<IFRAME ', 'FRAME','</IFRAME>' );
  nested_search( '<iframe ', 'FRAME','</IFRAME>' );
  nested_search( '<META ', 'URL','>' );
  nested_search( '<meta ', 'URL','>' );
  nested_search( '<IMG ', 'SRC','>','IMAGE' );
  nested_search( '<img ', 'SRC','>','IMAGE' );
  nested_search( '<UL ', 'SRC','>','LIST' );
  nested_search( '<ul ', 'SRC','>','LIST' );

 exception
  when others then dbms_output.put_line( 'ESTH:' || dbg || '-' || sqlerrm );
 end extract_site_html;

 procedure start_trawl( crec in web_trawl_driver%ROWTYPE )
 as
 begin
  -- Loop through driver table
  delete from web_trawl_log;
    -- Cleanup old data
    if crec.complete_refr = 'T'
     then
      if crec.trawl_type = 'H'
       then
        --delete from umo where aid = crec.aid and umo_type = 'HTML';
        commit;
      elsif crec.trawl_type = 'O'
       then
        delete from umo_index where umo_id in (select umo_id from umo where aid = crec.aid and umo_type = 'ODBC');
        delete from umo_attribute where umo_id in (select umo_id from umo where aid = crec.aid and umo_type = 'ODBC');
        delete from umo where aid = crec.aid and umo_type = 'ODBC';
        commit;
      end if;
    end if;

    -- Run the trawl
    if crec.trawl_type = 'H'
     then
      --extract_site_html( id=>crec.id, acid=>crec.aid, st=>crec.primary_site, depth=>crec.depth, parent_site=>null, contenttype=>'DATA', image_alt_tag=>null );
      null;
     elsif crec.trawl_type = 'O'
      then
      extract_site_odbc( crec );
    end if;

 end start_trawl;

 procedure odbc_init( v_umo out integer, stmt in varchar2, crec in web_trawl_driver%ROWTYPE )
 as
  cursor c1(stmt varchar2) is select umo_id from umo where document_original_loc = stmt and umo_type = 'ODBC';

 begin
  open c1(stmt);
  fetch c1 into v_umo;
  if c1%FOUND
   then
    close c1;
    update umo um
     set
      um.extras.orderby_nmb = um.extras.orderby_nmb + 1,
      date_updated = sysdate
     where umo_id = v_umo;
    delete from umo_index where umo_id = v_umo;
    delete from umo_attribute where umo_id = v_umo;
    commit;
    return;
  end if;
  close c1;

  ump.init( acid=>crec.aid, utype=>'ODBC', v_umo=>v_umo );
  update umo um
   set
    sort_priority = crec.depth,
    um.extras.orderby_nmb = 1,
    document_original_loc = stmt,
    doc_html = empty_clob(),
    date_created = sysdate
  where umo_id = v_umo;
  commit;

 end odbc_init;

 procedure extract_site_odbc( crec in web_trawl_driver%ROWTYPE )
 as

  fl			utl_file.file_type;
  retvar		varchar2(1000);
  retvar2		varchar2(1000);
  display_output 	GLBX.MYARRAY;
  bl			boolean;
  bfr			varchar2(32767);
  sqlstmt		varchar2(32767);
  sqlstmt2		varchar2(32767);
  separator		char(1);
  ctr			integer;
  v_umo			integer;

 begin

  select 't_' || trim(to_char(s_filename.nextval)) || '.' || 'sql' into retvar from dual;
  select 't_' || trim(to_char(s_filename.nextval)) || '.' || 'dat' into retvar2 from dual;
  separator := ',';

  sqlstmt := 'select ' || '''<REC>';
  sqlstmt2 := null;
  if crec.odbc_col1 is not null and crec.odbc_attr1 is not null
   then
    sqlstmt := sqlstmt || '<A' || to_char(crec.odbc_attr1) || '>'',' || crec.odbc_col1 || ',''</A' || to_char(crec.odbc_attr1) || '>';
    sqlstmt2 := sqlstmt2 || ',' || crec.odbc_col1;
  end if;
  if crec.odbc_col2 is not null and crec.odbc_attr2 is not null
   then
    sqlstmt := sqlstmt || '<A' || to_char(crec.odbc_attr2) || '>'',' || crec.odbc_col2 || ',''</A' || to_char(crec.odbc_attr2) || '>';
    sqlstmt2 := sqlstmt2 || ',' || crec.odbc_col2;
  end if;
  if crec.odbc_col3 is not null and crec.odbc_attr3 is not null
   then
    sqlstmt := sqlstmt || '<A' || to_char(crec.odbc_attr3) || '>'',' || crec.odbc_col3 || ',''</A' || to_char(crec.odbc_attr3) || '>';
    sqlstmt2 := sqlstmt2 || ',' || crec.odbc_col3;
  end if;
  if crec.odbc_col4 is not null and crec.odbc_attr4 is not null
   then
    sqlstmt := sqlstmt || '<A' || to_char(crec.odbc_attr4) || '>'',' || crec.odbc_col4 || ',''</A' || to_char(crec.odbc_attr4) || '>';
    sqlstmt2 := sqlstmt2 || ',' || crec.odbc_col4;
  end if;
  if crec.odbc_col5 is not null and crec.odbc_attr5 is not null
   then
    sqlstmt := sqlstmt || '<A' || to_char(crec.odbc_attr5) || '>'',' || crec.odbc_col5 || ',''</A' || to_char(crec.odbc_attr5) || '>';
    sqlstmt2 := sqlstmt2 || ',' || crec.odbc_col5;
  end if;
  if crec.odbc_col6 is not null and crec.odbc_attr6 is not null
   then
    sqlstmt := sqlstmt || '<A' || to_char(crec.odbc_attr6) || '>'',' || crec.odbc_col6 || ',''</A' || to_char(crec.odbc_attr6) || '>';
    sqlstmt2 := sqlstmt2 || ',' || crec.odbc_col6;
  end if;
  sqlstmt := sqlstmt || '</REC>''';
  if substr(crec.odbc_stmt,length(crec.odbc_stmt),1) = ';'
   then
    sqlstmt := sqlstmt || ' ' || crec.odbc_stmt;
    sqlstmt2 := sqlstmt2 || ' ' || crec.odbc_stmt;
   else
    sqlstmt := sqlstmt || ' ' || crec.odbc_stmt || ';';
    sqlstmt2 := sqlstmt2 || ' ' || crec.odbc_stmt || ';';
  end if;
  sqlstmt2 := 'select ' || substr(sqlstmt2,2);

  odbc_init( v_umo, sqlstmt2, crec );

  fl := utl_file.fopen( glbx.extract_master_parameter( 'WORK_DIRECTORY' ), retvar, 'w', 32767 );
   utl_file.put_line(fl, 'set heading off' );
   utl_file.put_line(fl, 'set pagesize 0' );
   utl_file.put_line(fl, 'set feedback off' );
   utl_file.put_line(fl, 'set term off' );
   utl_file.put_line(fl, 'set define off' );
   utl_file.put_line(fl, 'set linesize 2500' );
   utl_file.put_line(fl, 'spool ' || glbx.extract_master_parameter( 'WORK_DIRECTORY' ) || DECS.UNIX_OR_NT || retvar2 );
   utl_file.put_line(fl, 'prompt <?xml version="1.0" encoding="UTF-8"?>' );
   utl_file.put_line(fl, 'prompt <ROWSET>' );
   utl_file.put_line(fl, sqlstmt );
   utl_file.put_line(fl, 'prompt </ROWSET>' );
   utl_file.put_line(fl, 'spool off' );
   utl_file.put_line(fl, 'exit' );
  utl_file.fclose( fl );

  bl := os_command.sqlplus_odbc( null, ' ' || crec.odbc_un || '/' || crec.odbc_pw || '@odbc:' || crec.odbc_driver || ' @' || glbx.extract_master_parameter( 'WORK_DIRECTORY' ) || DECS.UNIX_OR_NT || retvar, display_output );

  -- Load into database
  ctr := 0;
  strip_xml(v_umo, crec, glbx.extract_master_parameter( 'WORK_DIRECTORY' ), retvar2 );
  -- delete the files
  bl := os_command.delete_file( glbx.extract_master_parameter( 'WORK_DIRECTORY' ) || DECS.UNIX_OR_NT || retvar, display_output, TRUE );
  bl := os_command.delete_file( glbx.extract_master_parameter( 'WORK_DIRECTORY' ) || DECS.UNIX_OR_NT || retvar2, display_output, TRUE );

 end extract_site_odbc;

procedure strip_xml( v_umo in integer, crec in web_trawl_driver%ROWTYPE, dr in varchar2, fn in varchar2 )
as

 p 		sys.xmlparser.parser;
 doc 		sys.xmldom.DOMDocument;
 bfr		varchar2(32767);
 inclob		clob;
 bfl		bfile;

begin

execute immediate 'create or replace directory ' || GLBX.GLOBAL_DIR || ' as ''' || dr || '''';
dbms_lob.createtemporary(inclob,TRUE);
dbms_lock.sleep(10); -- Sleep a bit whilst the file is written
bfl := BFILENAME(GLBX.GLOBAL_DIR, fn );
for j in 1..5 loop
 begin
  dbms_lob.fileopen(bfl, dbms_lob.file_readonly);
  exit;
 exception
  when others then
   dbms_lock.sleep(1);
 end;
end loop;
dbms_lob.loadfromfile(inclob,bfl,dbms_lob.getlength(bfl));
dbms_lob.fileclose(bfl);
p := sys.xmlparser.newParser;
sys.xmlparser.setValidationMode(p, FALSE);
sys.xmlparser.parseClob(p, inclob );
doc := sys.xmlparser.getDocument(p);
parsedoc(v_umo, crec, doc);
dbms_lob.freetemporary(inclob);
end strip_xml;

procedure parsedoc(v_umo in integer, crec in web_trawl_driver%ROWTYPE, doc in sys.xmldom.DOMDocument)
is

nl 		sys.xmldom.DOMNodeList;
len1 		number;
n 		sys.xmldom.DOMNode;
e 		sys.xmldom.DOMElement;
n_child 	sys.xmldom.DOMNode;
tag		varchar2(1000);
val		varchar2(1000);
str		varchar2(4000);
ctr		integer;
bl		boolean;

function getval( n_child in sys.xmldom.DOMNode )
 return varchar2
as
begin
  if not sys.xmldom.IsNull(n_child)
   then
    return( sys.xmldom.getNodeValue(n_child) );
   else
    return( NULL );
  end if;
end getval;

begin

   nl := sys.xmldom.getElementsByTagName(doc, '*');
   len1 := sys.xmldom.getLength(nl);

   -- loop through elements
   for j in 0..len1-1 loop
    n := sys.xmldom.item(nl, j);
    e := sys.xmldom.makeElement(n);
    n_child:= sys.xmldom.getFirstChild(n);
    tag := sys.xmldom.getTagName(e);

    if getval(n_child) is not null
     then
      val := trim(getval(n_child));
    end if;

    if tag = 'ROWSET'
     then
      ctr := 0;
     elsif tag = 'REC'
      then
       ctr := ctr + 1;
       if ctr >= nvl(crec.depth,9999999) then return; end if;
     else
      bl := ump.umo_modify_entry( v_umo, attribid=>to_number(substr(tag,2)), key_val=>val, acid=>crec.aid, position=>ctr, actual_api=>null, extract_numbers=>'F');
    end if;

   end loop;

   if tag <> 'ROWSET' and tag <> 'REC'
    then
      bl := ump.umo_modify_entry( v_umo, attribid=>to_number(substr(tag,2)), key_val=>val, acid=>crec.aid, position=>ctr, actual_api=>null, extract_numbers=>'F');
   end if;

exception
 when others then glbx.dbg( sqlerrm );
end parsedoc;

procedure test
 as
  cursor c1 is select * from web_trawl_driver;
  c1rec  c1%ROWTYPE;
 begin
  -- xxx add timing, so it can be automatically refreshed
  -- xxx add more test odbc data sources
  for c1rec in c1 loop
   start_trawl( c1rec );
  end loop;
 exception
  when others then dbms_output.put_line( 'TT:' || sqlerrm );
 end test;

/*
 insert into web_trawl_driver(id,aid,name,refresh_every,primary_site,depth,complete_refr,trawl_type) values
    (1,2373,'Mars Home',null,'http://mars.piction.com',5,'T','H');
 insert into web_trawl_filter(id,order_by,rule_name,rule_type,rule_value,newval) values
  (1,1,'External Site Limit','EXTERNAL_SITE','http://mars.piction.com','1');
 insert into web_trawl_filter(id,order_by,rule_name,rule_type,rule_value) values
  (1,2,'External Site','REJECT_NOMATCH','http://mars.piction.com');

 insert into web_trawl_driver(id,aid,name,refresh_every,primary_site,depth,complete_refr,trawl_type,
  odbc_un,odbc_pw,odbc_driver,odbc_col1,odbc_attr1,odbc_col2,odbc_attr2,odbc_col3,odbc_attr3,
  odbc_stmt) values
    (2,2373,'ODBC Test1',null,null,500,'T','O',
     'x','x','Powerhouse','name',2064,'enumerates',2065,'value',2066,
     'from enumerators');

*/

/*

DROP INDEX I_WEB_TRAWL_DRIVER;

-- create context indexes
CREATE INDEX I_WEB_TRAWL_DRIVER ON umo(doc_html) INDEXTYPE IS CTXSYS.CONTEXT
 PARAMETERS ('filter ctxsys.null_filter section group ctxsys.html_section_group STORAGE PICTION_STORAGE');

delete from ctx_themes;
declare
 cursor c1 is select * from umo where umo_type = 'HTML';
begin
 for c1rec in c1 loop
  CTX_DOC.THEMES('I_WEB_TRAWL_DRIVER',to_char(c1rec.umo_id),'ctx_themes',c1rec.umo_id,full_themes => FALSE);
 end loop;
end;

-- context index
-- index on attribute6
-- histogram stats on umo_type

*/

end trw;

/
