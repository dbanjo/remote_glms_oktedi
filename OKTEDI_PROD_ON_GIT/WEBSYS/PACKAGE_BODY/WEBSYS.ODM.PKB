CREATE OR REPLACE package body WEBSYS.odm
as

procedure run_probe( ts in date, crec in odm_definition%ROWTYPE );
procedure retrieve_html( st in varchar2, pieces in out nocopy utl_http.html_pieces, result out varchar2 );
procedure strip_status( ts in date, crec in odm_definition%ROWTYPE, pieces in utl_http.html_pieces, status in out varchar2 );
procedure strip_xml( ts in date, crec in odm_definition%ROWTYPE, pieces in utl_http.html_pieces );
procedure strip_html( ts in date, crec in odm_definition%ROWTYPE, pieces in utl_http.html_pieces, status in out varchar2 );
procedure parsedoc(ts in date, crec in odm_definition%ROWTYPE, doc in sys.xmldom.DOMDocument);
procedure check_failures( ts in date, crec in odm_definition%ROWTYPE, result in varchar2 );
procedure cull_records( crec in odm_definition%ROWTYPE, dc in date );

procedure xml_status( is_soap in boolean default FALSE )
as
 cursor c2 is select * from v$instance;

 c2rec	c2%ROWTYPE;

begin

open c2;
fetch c2 into c2rec;
close c2;

 if is_soap
  then
   htp.p( '<STATUS>' );
  else
   htp.p( '<DOWNTIME_DATA>' );
   htp.p( '<?xml version="1.0" encoding="UTF-8"?>' );
 end if;

 htp.p( '<NAME>' );
  htp.p( glbx.extract_master_parameter('NODE_NAME') );
 htp.p( '</NAME>' );

 htp.p( '<INSTANCE_NAME>' );
  htp.p( c2rec.instance_name );
 htp.p( '</INSTANCE_NAME>' );

 htp.p( '<HOST_NAME>' );
  htp.p( c2rec.host_name );
 htp.p( '</HOST_NAME>' );

 htp.p( '<ORACLE_VERSION>' );
  htp.p( c2rec.version );
 htp.p( '</ORACLE_VERSION>' );

 htp.p( '<PICTION_VERSION>' );
  htp.p( glbx.current_version );
 htp.p( '</PICTION_VERSION>' );

 htp.p( '<DATABASE_UP_SINCE>' );
  htp.p( to_char(c2rec.startup_time,'Day DD-Month-YYYY HH24:MI:SS')  );
 htp.p( '</DATABASE_UP_SINCE>' );

 if is_soap
  then
   htp.p( '</STATUS>' );
  else
   htp.p( '</DOWNTIME_DATA>' );
 end if;
end xml_status;

procedure status
as

 cursor c2 is select * from v$instance;
 cursor c3 is select count('x') tot from customer_account;
 cursor c4 is select count('x') tot from photographer;
 cursor c5 is select count('x') tot from umo;
 cursor c6 is select count('x') tot from login_session;

 c2rec	c2%ROWTYPE;
 c3rec	c3%ROWTYPE;
 c4rec	c4%ROWTYPE;
 c5rec	c5%ROWTYPE;
 c6rec	c6%ROWTYPE;

begin

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

htp.htmlopen;
htp.tableopen( cattributes=>'cellpadding="2" cellspacing="2" border="1"' );

 htp.tablerowopen;
  htp.tabledata( 'Name' );
  htp.tabledata( htf.bold(glbx.extract_master_parameter('NODE_NAME')) );
 htp.tablerowclose;

 htp.tablerowopen;
  htp.tabledata( 'Instance Name' );
  htp.tabledata( htf.bold(c2rec.instance_name) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( 'Host Name' );
  htp.tabledata( htf.bold(c2rec.host_name) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( 'Oracle Version' );
  htp.tabledata( htf.bold(c2rec.version) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( 'Piction Version' );
  htp.tabledata( htf.bold(glbx.current_version) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( 'Total Customers' );
  htp.tabledata( htf.bold(c3rec.tot) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( 'Total Photographers' );
  htp.tabledata( htf.bold(c4rec.tot) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( 'Total Images' );
  htp.tabledata( htf.bold(c5rec.tot) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( 'Total Logins' );
  htp.tabledata( htf.bold(c6rec.tot) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( 'Database Up Since' );
  htp.tabledata( htf.bold(to_char(c2rec.startup_time,'Day DD-Month-YYYY HH24:MI:SS') ) );
 htp.tablerowclose;
htp.tableclose;
htp.htmlclose;
exception
 when others then htp.p( sqlerrm ); htp.htmlclose;
end status;

function check_sites
 return boolean
as

 cursor c1( ts date ) is select * from odm_definition where (last_check is null) or ( (probe_every/(60*24)) + last_check < ts );

 ts 	date;

begin
 ts := sysdate;

 for c1rec in c1( ts ) loop
  run_probe( ts, c1rec );
 end loop;

 commit;
 return( TRUE );

exception
 when others then return( FALSE );
end check_sites;

procedure run_probe( ts in date, crec in odm_definition%ROWTYPE )
as
 pieces 	utl_http.html_pieces;
 result		varchar2(4000);
 nmb		integer;
 sectimeb 	date;
 sectime 	number;
begin

 if crec.odm_type = 'STATUS'
  then
    sectimeb := sysdate;
    retrieve_html( crec.http_call || '/' || 'status', pieces, result );
    sectime := sysdate - sectimeb;
    if result is null then strip_status( ts, crec, pieces, result ); end if;

 elsif crec.odm_type = 'XML'
  then
    sectimeb := sysdate;
    retrieve_html( crec.http_call || '/' || 'odm.xml_status', pieces, result );
    sectime := sysdate - sectimeb;
    if result is null then strip_xml( ts, crec, pieces ); end if;

 elsif crec.odm_type = 'WEB_PAGE'
  then
    sectimeb := sysdate;
    retrieve_html( crec.http_call, pieces, result );
    sectime := sysdate - sectimeb;
    if result is null then strip_html( ts, crec, pieces, result ); end if;

 end if;

 nmb := 0;
 if pieces.count > 0
  then
   for j in pieces.first..pieces.last loop
    nmb := nmb + length( pieces(j) );
   end loop;
 end if;

 sectime := sectime * (60*60*24);
 if result is null
  then
   insert into odm_log(id, date_created, result, number_bytes, calltime_sec, result_code ) values (crec.id, ts, result, nmb, sectime, 'T' );
  else
   insert into odm_log(id, date_created, result, number_bytes, calltime_sec, result_code ) values (crec.id, ts, result, nmb, sectime, 'F' );
   check_failures( ts, crec, result );
 end if;

 update odm_definition
  set
   last_check = ts
 where
  id = crec.id;

exception
 when others then
   result := sqlerrm;
   insert into odm_log(id, date_created, result, number_bytes, result_code )
    values
     (crec.id, ts, result, nmb, 'F' );
end run_probe;

procedure retrieve_html( st in varchar2, pieces in out nocopy utl_http.html_pieces, result out varchar2 )
as
begin

  result := NULL;
  pieces := utl_http.request_pieces( st );

  if pieces.count = 0
   then
    result := 'Empty HTML Page Retrieved';
  end if;

 exception
  when utl_http.INIT_FAILED then result := 'Initialization of the HTTP-callout subsystem fails';
  when utl_http.REQUEST_FAILED then result := 'The HTTP call fails';
  when others then result := sqlerrm;
end retrieve_html;

procedure strip_status( ts in date, crec in odm_definition%ROWTYPE, pieces in utl_http.html_pieces, status in out varchar2 )
as

 bfr	varchar2(32767);
 x	integer;
begin

if pieces.count = 0 then return; end if;
bfr := null;
for j in pieces.first..pieces.last loop
 bfr := bfr || pieces(j);
end loop;

x := instr(bfr,'<TD>Host Name</TD>');
if x = 0
 then
 status := 'Could not find Host Name in Status';
end if;

end strip_status;

procedure strip_xml( ts in date, crec in odm_definition%ROWTYPE, pieces in utl_http.html_pieces )
as
 p 	sys.xmlparser.parser;
 doc 	sys.xmldom.DOMDocument;
 bfr	varchar2(32767);
begin

if pieces.count = 0 then return; end if;
bfr := null;
for j in pieces.first..pieces.last loop
 bfr := bfr || pieces(j);
end loop;

p := sys.xmlparser.newParser;
sys.xmlparser.setValidationMode(p, FALSE);
sys.xmlparser.parseBuffer(p, bfr );
doc := sys.xmlparser.getDocument(p);
parsedoc(ts, crec, doc);

end strip_xml;

procedure parsedoc(ts in date, crec in odm_definition%ROWTYPE, doc in sys.xmldom.DOMDocument)
is

nl 		sys.xmldom.DOMNodeList;
len1 		number;
n 		sys.xmldom.DOMNode;
e 		sys.xmldom.DOMElement;
n_child 	sys.xmldom.DOMNode;
lasttag		varchar2(1000);
tag		varchar2(1000);
val		varchar2(1000);

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
   lasttag := NULL;

   -- loop through elements
   for j in 0..len1-1 loop
    n := sys.xmldom.item(nl, j);
    e := sys.xmldom.makeElement(n);
    n_child:= sys.xmldom.getFirstChild(n);
    tag := sys.xmldom.getTagName(e);

    if getval(n_child) is not null
     then
      val := getval(n_child);
    end if;

    insert into odm_xml_parms(id, date_created, parm_name, parm_value ) values (crec.id, ts, tag, val );
   end loop;

exception
 when others then null;
end parsedoc;

procedure strip_html( ts in date, crec in odm_definition%ROWTYPE, pieces in utl_http.html_pieces, status in out varchar2 )
as

 bfr	varchar2(32767);
 x	integer;
begin

if crec.keyword_check is null then return; end if;
if pieces.count = 0 then return; end if;
bfr := null;
for j in pieces.first..pieces.last loop
 bfr := bfr || upper(pieces(j));
end loop;

x := instr(bfr,upper(crec.keyword_check));
if x = 0
 then
  status := 'Keyword not found in HTML:' || crec.keyword_check;
end if;

end strip_html;

procedure check_failures( ts in date, crec in odm_definition%ROWTYPE, result in varchar2 )
as

 cursor c1( oid integer ) is select * from odm_log where id = oid order by date_created desc;

 ctr    	integer;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin
 -- We have one failure, lets check how many in a row there have been
 ctr := 0;
 for c1rec in c1(crec.id) loop
  if c1rec.result_code = 'T' then exit; end if;
  ctr := ctr + 1;
 end loop;

 if ctr = 0 then return; end if;

 gcode(1) := 'ODM_NAME';
 gparam(1) := crec.odm_name;
 gcode(2) := 'HTTP_CALL';
 gparam(2) := crec.http_call;
 gcode(3) := 'CURRENT_TIME';
 gparam(3) := to_char(sysdate,LNG.TSMASK);
 gcode(4) := 'SIGNATURE';
 gparam(4) := glbx.extract_master_parameter('MAIL SIGNATURE');
 gcode(5) := 'PROBE_EVERY';
 gparam(5) := crec.probe_every;
 gcode(6) := 'RESULT';
 gparam(6) := result;
 gcode(7) := 'TYPE';
 gparam(7) := crec.odm_type;
 if nvl(crec.escalate_1,0) = ctr and crec.notify_1 is not null
  then
    glbx.send( gcode, gparam, 'downtime_notification.tmp', p_to=>crec.notify_1,p_subj=>'Downtime Escalation Level 1:' || crec.odm_name ,p_from=>glbx.extract_master_parameter('MAIL_FROM'));

 elsif nvl(crec.escalate_2,0) = ctr and crec.notify_2 is not null
  then
    glbx.send( gcode, gparam, 'downtime_notification.tmp', p_to=>crec.notify_2,p_subj=>'Downtime Escalation Level 2:' || crec.odm_name ,p_from=>glbx.extract_master_parameter('MAIL_FROM'));

 elsif nvl(crec.escalate_3,0) = ctr and crec.notify_3 is not null
  then
    glbx.send( gcode, gparam, 'downtime_notification.tmp', p_to=>crec.notify_3,p_subj=>'Downtime Escalation Level 3:' || crec.odm_name ,p_from=>glbx.extract_master_parameter('MAIL_FROM'));

 end if;

end check_failures;

function cull_log_file
 return boolean
as

 cursor c1 is select * from odm_definition;
 cursor c2(oid integer) is select max( date_created ) dc from odm_culled_log where id = oid;
 cursor c3(oid integer) is select min( date_created ) dc from odm_log where id = oid;

 c2rec  c2%ROWTYPE;

begin

 for c1rec in c1 loop
  open c2(c1rec.id);
  fetch c2 into c2rec;
  close c2;
  if c2rec.dc is null
   then
    open c3(c1rec.id);
    fetch c3 into c2rec.dc;
    close c3;
  end if;

  if c2rec.dc is not null
   then
    cull_records( c1rec, c2rec.dc );
  end if;
 end loop;
 return( TRUE );

exception
 when others then return( FALSE );
end cull_log_file;

procedure cull_records( crec in odm_definition%ROWTYPE, dc in date )
as
 cursor c1(oid integer, cd date) is select * from odm_log where id = oid and date_created > dc order by date_created asc;
 laststs	char(1);
 dfrom		date;
 res		varchar2(4000);
begin
 laststs := 'T'; -- its simpler than handling the null condition.
 dfrom := dc;
 for c1rec in c1(crec.id, dc) loop

  if laststs = 'T' and c1rec.result_code = 'T'
   then
    dfrom := c1rec.date_created;
    laststs := 'T';

  elsif laststs = 'T' and c1rec.result_code = 'F'
   then
    res := nvl(res,c1rec.result);
    laststs := 'F';

  elsif laststs = 'F' and c1rec.result_code = 'T'
   then
    -- output downtime message
    insert into odm_culled_log(id,date_created,downtime_from,downtime_to,reason) values
     (crec.id,c1rec.date_created,dfrom,c1rec.date_created,res);
    laststs := 'T';

  elsif laststs = 'F' and c1rec.result_code = 'F'
   then
    res := nvl(res,c1rec.result);
    laststs := 'F';
  end if;

 end loop;
 commit;

end cull_records;

end odm;

/
