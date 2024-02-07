CREATE OR REPLACE package body WEBSYS.soap
as

 TYPE service_type IS RECORD
  (
    name		varchar2(100),
    dns			varchar2(1000)
  );

 TYPE services IS TABLE OF service_type INDEX BY BINARY_INTEGER;

 G_SERVICES	services;
 G_lmrq		integer;
 G_pid		integer;
 G_aid		integer;
 G_Key		varchar2(1000);

 procedure soap_header( ctype in varchar2 default null);
 procedure soap_footer;
 procedure initialise_services;
 procedure soap_service_open( service in varchar2 );
 procedure soap_service_close( service in varchar2 );
 procedure soap_result_open( service in varchar2 );
 procedure soap_result_close( service in varchar2 );
 procedure open_xml( service in varchar2, nme in varchar2, blb in blob );
 procedure parsedoc(service in varchar2, doc in sys.xmldom.DOMDocument) ;
 procedure soap_error( service in varchar2, errmsg in varchar2 );
 procedure unload_account( service in varchar2, surl in varchar2 );
 procedure unload_table( tname in varchar2, wclause in varchar2 );
 procedure print_service( service in varchar2, parm1 in ump.parameters, parm2 in ump.parameters );
 procedure sql_stmt( service in varchar2, parm1 in ump.parameters, parm2 in ump.parameters );
 procedure update_metadata( surl in varchar2, v_umo in integer, p1 in glbx.myarray, p2 in glbx.myarray );

 function findservice( service in varchar2 ) return varchar2;

 procedure main( file in varchar2 default null )
 as

  cursor c1(file in varchar2) is select * from apache_ows_content where name = file;

  cursor c2 is
   select *
   from apache_ows_content
   where last_updated = (select max(last_updated) from apache_ows_content) and
         upper(trim(mime_type)) = 'TEXT/XML';

  crec		apache_ows_content%ROWTYPE;
  service	varchar2(100);

 begin
--  htp.p( '<HTML>' );
--  htp.p( '+' || file || '+' );
--  htp.p( '</HTML>' );
-- glbx.dbg( 'FILE:' || file || '+' );
-- return;
  service := 'Piction';
  initialise_services;

  begin
  if file is null
   then
    open c2;
    fetch c2 into crec;
    close c2;
   else
    open c1(file);
    fetch c1 into crec;
    close c1;
  end if;
  exception
   when others then
    crec := null;
  end;

  if crec.name is null
   then
    -- return invalid SOAP message
    soap_error( service, 'Unable to find XML File' );
    return;
  end if;

  open_xml(service, crec.name, crec.blob_content);
  delete from apache_ows_content where name = crec.name;
  commit;

 end main;

 procedure soap_error( service in varchar2, errmsg in varchar2 )
 as
 begin
    soap_header;
    soap_service_open( service );
     htp.p( '<MESSAGE>' || errmsg || '</MESSAGE>' );
    soap_service_close( service );
    soap_footer;
 end soap_error;

 procedure soap_header( ctype in varchar2 default null)
 as
 begin
  if ctype is null
   then
    owa_util.mime_header('text/xml');
   else
    owa_util.mime_header( 'Multipart/Related; boundary=MIME_boundary; type=text/xml; start="' || ctype || '"', bclose_header=>FALSE);
    owa_util.http_header_close;
    htp.prn( '--MIME_boundary' );
    owa_util.mime_header('text/xml',bclose_header=>FALSE);
    htp.p( utl_tcp.CRLF );
    htp.prn('Content-ID: ' || ctype || utl_tcp.CRLF);
    owa_util.http_header_close;
  end if;

  htp.p( '<?xml version = ''1.0'' encoding = ''utf-8''?>' );
  htp.p( '<soap:Envelope  xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  xmlns:xsd="http://www.w3.org/2001/XMLSchema">' );
  htp.p( '<soap:Body>' );
 end soap_header;

 procedure soap_service_open( service in varchar2 )
 as
  xmlns	varchar2(1000);
 begin
  xmlns := findservice(service);
  htp.p( '<' || service || 'Response' ||  ' xmlns="' || xmlns || '">' );
 end soap_service_open;

 procedure soap_service_close( service in varchar2 )
 as
 begin
  htp.p( '</' || service || 'Response' || '>' );
 end soap_service_close;

 procedure soap_result_open( service in varchar2 )
 as
 begin
  htp.p( '<' || service || 'Result' || '>' );
 end soap_result_open;

 procedure soap_result_close( service in varchar2 )
 as
 begin
  htp.p( '</' || service || 'Result' || '>' );
 end soap_result_close;

 procedure soap_footer
 as
 begin
  htp.p( '</soap:Body>' );
  htp.p( '</soap:Envelope>' );
 end soap_footer;

 procedure initialise_services
 as
  stype		service_type;
  loc		varchar2(1000);
 begin
  loc := glbx.extract_master_parameter('MERCHANT_RETURNTO_URL') || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'soap.main';
  stype.name := 'undefined';
  stype.dns := loc;
  G_SERVICES(1) := stype;
  stype.name := 'Piction';
  stype.dns := loc;
  G_SERVICES(2) := stype;
  stype.name := 'Webservice';
  stype.dns := loc;
  G_SERVICES(3) := stype;
  stype.name := 'Portlet';
  stype.dns := loc;
  G_SERVICES(4) := stype;
  stype.name := 'Image';
  stype.dns := loc;
  G_SERVICES(5) := stype;
  stype.name := 'Report';
  stype.dns := loc;
  G_SERVICES(6) := stype;
  stype.name := 'Login';
  stype.dns := loc;
  G_SERVICES(7) := stype;
  stype.name := 'Customer_Built';
  stype.dns := loc;
  G_SERVICES(8) := stype;
  stype.name := 'Test_Alive';
  stype.dns := loc;
  G_SERVICES(9) := stype;
  stype.name := 'Status';
  stype.dns := loc;
  G_SERVICES(10) := stype;
  stype.name := 'Account';
  stype.dns := loc;
  G_SERVICES(11) := stype;
  stype.name := 'Print_Service';
  stype.dns := loc;
  G_SERVICES(12) := stype;
  stype.name := 'SQL_Request';
  stype.dns := loc;
  G_SERVICES(13) := stype;
  stype.name := 'Royalties';
  stype.dns := loc;
  G_SERVICES(14) := stype;
  stype.name := 'Metadata_Update';
  stype.dns := loc;
  G_SERVICES(15) := stype;
 end initialise_services;

 function findservice( service in varchar2 )
  return varchar2
 as
 begin
  for j in G_SERVICES.FIRST..G_SERVICES.LAST loop
   if nvl(service,'undefined') = G_SERVICES(j).name then return( G_SERVICES(j).dns ); end if;
  end loop;
  return( NULL );
 end findservice;

procedure open_xml( service in varchar2, nme in varchar2, blb in blob )
as

 p 		sys.xmlparser.parser;
 doc 		sys.xmldom.DOMDocument;
 clb		clob;
 r_buffer	raw(32767);
 v_buffer	varchar2(32767);
 c_imgchunk 	integer;
 v_imgchunk 	integer;
 v_count 	integer;

begin
-- convert from blob to clob
dbms_lob.createtemporary(clb,TRUE);
c_imgchunk := 32767;
v_imgchunk := 32767;
v_count := 0;
begin
 loop
   dbms_lob.read(blb,v_imgchunk,(v_count*c_imgchunk)+1,r_buffer);
   v_count := v_count + 1;
   v_buffer := utl_raw.cast_to_varchar2( r_buffer );
   if v_buffer is null then exit; end if;
   dbms_lob.writeappend(clb,length(v_buffer), v_buffer);
 end loop;
exception when others then null;
end;

p := sys.xmlparser.newParser;
sys.xmlparser.setValidationMode(p, FALSE);
sys.xmlparser.parseClob(p, clb );
doc := sys.xmlparser.getDocument(p);
parsedoc(service, doc);
dbms_lob.freetemporary(clb);
exception
 when others then
    soap_error( service, sqlerrm );
    --delete from apache_ows_content where name = nme;
    commit;
    return;
end open_xml;

procedure parsedoc(service in varchar2, doc in sys.xmldom.DOMDocument)
is

cursor c1( enc varchar2 ) is select manprint_id from lab_manual_print where upper(webservice_pk) = enc;
cursor c2( uname varchar2 ) is select pid, aid from customer_account where username = uname;

nl 			sys.xmldom.DOMNodeList;
len1 			number;
len2 			number;
n 			sys.xmldom.DOMNode;
e 			sys.xmldom.DOMElement;
n_child 		sys.xmldom.DOMNode;
n2 			sys.xmldom.DOMNode;
nnm 			sys.xmldom.DOMNamedNodeMap;
tag			varchar2(1000);
val			varchar2(1000);
str			varchar2(4000);
ctr			integer;
pid			integer;
v_umo			integer;
name			varchar2(1000);
username		varchar2(1000);
password		varchar2(1000);
retval			varchar2(1000);
program			varchar2(1000);
bl			boolean;
test_print_service 	boolean;
print_serviceresponse   boolean;
attrname 		varchar2(100);
attrval 		varchar2(100);
srv			varchar2(1000);
parm1 			ump.parameters;
parm2 			ump.parameters;
gparm1 			glbx.myarray;
gparm2 			glbx.myarray;
parmstr			varchar2(32767);
message			varchar2(32767);
pctr			integer;
sts			varchar2(1000);
surl			varchar2(100);
report_name		varchar2(1000);
session_id		integer;
stype			integer;
ltype			varchar2(100);
owner_id		integer;
encrypted_key		varchar2(100);


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
   parmstr := null;
   test_print_service := FALSE;
   print_serviceresponse := FALSE;

   -- loop through elements
   for j in 0..len1-1 loop
    n := sys.xmldom.item(nl, j);
    e := sys.xmldom.makeElement(n);
    n_child:= sys.xmldom.getFirstChild(n);
    tag := sys.xmldom.getTagName(e);
    val := null;

    if getval(n_child) is not null
     then
      val := trim(getval(n_child));
    end if;

    if upper(tag) = upper('SOAP-ENV:Envelope')
     then
      ctr := 0;

     elsif upper(tag) = upper('SOAP-ENV:Body')
      then
       ctr := ctr + 1;
       if ctr >= 9999999 then return; end if;

     elsif upper(tag) = 'PRINT_SERVICERESPONSE'
      then
       print_serviceresponse := TRUE;

     elsif upper(tag) = 'MESSAGE'
      then
       message := trim(val);

     elsif upper(tag) = 'LAB_PRINT'
      then
       message := trim(val);

     elsif upper(tag) = 'WEBSERVICE'
      then
       srv := nvl(initcap(trim(val)),service);
       srv := replace(srv,chr(13),null);
       srv := replace(srv,chr(11),null);
       srv := replace(srv,chr(10),null);
       pctr := 0;
       pctr := pctr + 1;
       parm1(pctr) := 'CALL';
       parm2(pctr) := 'WEBSERVICE';

     elsif upper(tag) = 'PID'
      then
       begin pid := to_number(trim(val) );
       exception
        when others then
         soap_error( service, 'Invalid Command Centre Id:' || val );
         return;
       end;

     elsif upper(tag) = 'NAME'
      then
       name := trim(val);
       if name is null then
         soap_error( service, 'Name Tag must have a value' );
         return;
       end if;

     elsif upper(tag) = 'USERNAME'
      then
       username := trim(val);
       if username is null then
         soap_error( service, 'Username Tag must have a value' );
         return;
       end if;

     elsif upper(tag) = 'PASSWORD'
      then
       password := trim(val);
       if password is null then
         soap_error( service, 'Username Tag must have a value' );
         return;
       end if;

     elsif upper(tag) = 'PROGRAM'
      then
       program := trim(val);
       if program is null then
         soap_error( service, 'Program must have a value' );
         return;
       end if;

     elsif upper(tag) = 'SURL'
      then
       surl := trim(val);
       if surl is null then
         soap_error( service, 'SURL must have a value' );
         return;
       end if;

     elsif upper(tag) = 'REPORT_NAME'
      then
       report_name := trim(val);
       if report_name is null then
         soap_error( service, 'REPORT_NAME must have a value' );
         return;
       end if;

     elsif upper(tag) = 'TEST_PRINT_SERVICE'
      then
       if trim(val) is null then test_print_service := FALSE; elsif upper(trim(val)) in ('TEST','TRUE','YES') then test_print_service := TRUE; end if;

     elsif upper(tag) in  ('ENCRYPTED_KEY','ENCRYPTED_KEY_SQL')
      then
       if trim(val) is null then
         soap_error( service, 'ENCRYPTED_KEY must have a value' );
         return;
       end if;
       encrypted_key := trim(decrypt_key( trim(val), 128, glbx.extract_master_parameter('PRINTING_KEY') ));

       if encrypted_key is null
        then
         soap_error( service, 'ENCRYPTED_KEY is invalid' );
         return;
       end if;

       if upper(tag) = 'ENCRYPTED_KEY'
        then
         open c1(upper(encrypted_key));
         fetch c1 into G_lmrq;
         if c1%NOTFOUND
          then
           close c1;
           soap_error( service, 'Local Print Request:' || encrypted_key || ' not found.' );
           return;
         end if;
         close c1;

         username := upper(trim(glbx.extract_master_parameter('PRINTING_USERNAME')));
         open c2( upper(username) );
         fetch c2 into G_pid, G_aid;
         if c2%NOTFOUND
          then
           close c2;
           soap_error( service, 'Local Print Request:' || encrypted_key || ' Command Centre not found:' || username );
           return;
         end if;
         close c2;

         if test_print_service
          then
           soap_error( service, 'ENCRYPTED_KEY matches to Local Print Request:' || G_lmrq );
           return;
         end if;
        else
         G_Key := encrypted_key;
       end if;

     elsif upper(tag) = 'V_UMO'
      then
       begin v_umo := to_number(trim(val) );
       exception
        when others then
         soap_error( service, 'Invalid V_UMO value:' || val );
         return;
       end;

     elsif upper(tag) = 'PARAMETER'
      then
      --htp.p( tag || '-' || val );
      --htp.nl;
      pctr := pctr + 1;
      parm1(pctr) := null;
      parm2(pctr) := val;
      gparm1(pctr) := null;
      gparm2(pctr) := val;
      -- Extract the name attribute
      nnm := sys.xmldom.getAttributes(n);

      if (sys.xmldom.isNull(nnm) = FALSE) then
        len2 := sys.xmldom.getLength(nnm);
        -- loop through attributes
        for i in 0..len2-1 loop
           n2 := sys.xmldom.item(nnm, i);
           attrval := null;
           attrname := trim(upper(sys.xmldom.getNodeName(n2)));
           attrval := trim(upper(sys.xmldom.getNodeValue(n2)));
           if attrname = 'NAME'
            then
             parm1(pctr) := attrval;
             gparm1(pctr) := attrval;
           end if;
        end loop;
      end if;
      begin parmstr := parmstr || ',' || parm1(pctr) || '=>''' || parm2(pctr) || ''''; exception when others then null; end;
     end if;
   end loop;

   if print_serviceresponse
    then
     -- message contains the result
     G_MESSAGE := message;
     return;
   end if;
   if srv = 'Image'
    then
     soap_header( ctype=>'<webserviceimage' || v_umo || '>');
    else
     soap_header;
   end if;

   soap_service_open( srv );

    if srv = 'Webservice'
     then
      ump.webservice(parm1, parm2);

    elsif srv = 'Portlet'
     then
      if pid is not null and name is not null
       then
         glbx.portlet( pid=>pid, name=>name, p1=>gparm1, p2=>gparm2 );
      elsif pid is not null and name is not null
       then
         glbx.portlet( username=>username, name=>name, p1=>gparm1, p2=>gparm2 );
       else
        htp.init;
        soap_error( service, 'Unable to call Portlet. Parameters are not all supplied.' );
        return;
      end if;

    elsif srv = 'Image'
     then
      --ump.show_public_image( v_umo=>v_umo, call=>'XML' );
      --ump.show_public_image( v_umo=>v_umo, call=>'MIME' );
      htp.p( '<imagethumbnail href="cid:webserviceimage' || v_umo || '"/>' );

    elsif srv = 'Report'
     then
      if surl is null
       then
        htp.init;
        soap_error( service, 'Unable to Run Report. SURL not supplied.' );
        return;
      end if;
      if report_name is null
       then
        htp.init;
        soap_error( service, 'Unable to Run Report. Report_Name not supplied.' );
        return;
      end if;
      oltp.webservice_run_report(surl=>surl, name=>report_name, p1=>gparm1, p2=>gparm2);

    elsif srv = 'Metadata_Update'
     then
      if surl is null
       then
        htp.init;
        soap_error( service, 'Unable to Run Report. SURL not supplied.' );
        return;
      end if;
      if v_umo is null
       then
        htp.init;
        soap_error( service, 'Unable to Run Report. UMO_ID not supplied.' );
        return;
      end if;
      --
      update_metadata(surl=>surl, v_umo=>v_umo, p1=>gparm1, p2=>gparm2);

    elsif srv = 'Login'
     then
      if username is not null
       then
        glbx.logon_user( upper(username), upper(password), sts, session_id, stype, null, null, 'F', null, surl );
        if sts in ('CUSTOMER','OWNER','PROFILE','PROFILEG','VIRTUAL','PHOTOGRAPHER','MANUFACTURER')
         then
          htp.p( '<SURL>' || surl || '</SURL>' );
          htp.p( '<STYPE>' || to_char(stype) || '</STYPE>' );
          htp.p( '<SESSION_ID>' || to_char(session_id) || '</SESSION_ID>' );
         else
          htp.init;
          soap_error( service, sts );
          return;
        end if;
       else
        htp.init;
        soap_error( service, 'Unable to Login. Username not supplied.' );
        return;
      end if;

    elsif srv = 'Customer_Built'
     then
      if program is null
       then
        htp.init;
        soap_error( service, 'Program Name not Supplied.' );
        return;
       else
        begin
         execute immediate 'begin :1 := ' || program || '(' || substr(parmstr,2) || '); end;'
          using  in out retval;
        exception
         when others then
          htp.init;
          soap_error( service, 'begin :1 := ' || program || '(' || substr(parmstr,2) || '); end;' || sqlerrm );
          return;
        end;
      end if;
      htp.p( retval );

    elsif srv = 'Test_Alive'
     then
      odm.xml_status( is_soap=>TRUE );

    elsif srv = 'Status'
     then
      odm.status;

    elsif srv = 'Account'
     then
      if surl is null
       then
        htp.init;
        soap_error( service, 'Unable to Detail Account. SURL not supplied.' );
        return;
      end if;
      unload_account( service, surl );

    elsif srv = 'Print_Service'
     then
      print_service(service, parm1, parm2);
      return;

    elsif srv = 'Sql_Request'
     then
      sql_stmt(service, parm1, parm2);

    end if;

   soap_service_close( srv );
   soap_footer;

   if srv = 'Image'
    then
      ump.show_public_image( v_umo=>v_umo, call=> '<webserviceimage' || v_umo || '>' );
   end if;
exception
 when others then htp.p( 'General Error in parsedoc:' || sqlerrm );
end parsedoc;

procedure testscreen
as
begin
 htp.htmlopen;
 htp.bold( 'Piction - SOAP: Web Service Test' );
 htp.nl;
 htp.nl;
 htp.italic( 'Paste in the XML Soap Call in the Box below' );
 htp.nl;
 htp.nl;
 htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'soap.accepttest', cattributes=>'enctype="multipart/form-data"' );
  htp.formtextarea( 'P1', 10, 80 );
 htp.nl;
 htp.formsubmit( null, 'Run Service' );
 htp.formclose;
 htp.htmlclose;
end testscreen;

procedure accepttest( p1 in varchar2 )
as
 cursor c1(fl varchar2) is select blob_content from apache_ows_content where name = fl for update;

 vl  	varchar2(1000);
 blb	blob;
 rw	raw(32767);

begin
 select to_char(sysdate,'SSSS') into vl from dual;
 vl := 'test' || vl;

 delete from apache_ows_content where name = vl;
 insert into apache_ows_content(name,blob_content) values (vl,empty_blob());
 commit;
 open c1(vl);
 fetch c1 into blb;
 close c1;
 rw := utl_raw.cast_to_raw(p1);
 dbms_lob.writeappend(blb,utl_raw.length(rw),rw);
 update apache_ows_content set blob_content = blb where name = vl;
 commit;

 main( vl );
exception
 when others then htp.p( 'General Error in accepttest:' || sqlerrm );
end accepttest;

function testprogram( p1 in varchar2, p2 in varchar2 )
 return varchar2
as
 retval	varchar2(32767);
begin
 retval := '<PARAMETERS>';
 retval := retval || '<P1>' || p1 || '</P1>';
 retval := retval || '<P2>' || p2 || '</P2>';
 retval := retval || '</PARAMETERS>';
 return( retval );
exception
 when others then return( '<ERROR>' || sqlerrm || '</ERROR>' );
end testprogram;

procedure unload_account( service in varchar2, surl in varchar2 )
as

 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 acid		integer;
 sts		varchar2(100);
 pfx		theme%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 purchord	purchase_order%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'SOAP.UNLOAD_ACCOUNT', reset=>FALSE );
 if sts is not null
  then
   soap_error( service, 'Invalid SURL supplied' );
   return;
 end if;
 glbx.get_all_order_details(owner_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );

 -- Unload CUSTOMER_ACCOUNT
 htp.p( '<CUSTOMER_ACCOUNT>' );
  htp.p('<PID>' || xmlconv(cusrec.PID) || '</PID>');
  htp.p('<AID>' || xmlconv(cusrec.AID) || '</AID>');
  htp.p('<PHOTOGRAPHER_ACCOUNT_ID>' || xmlconv(cusrec.PHOTOGRAPHER_ACCOUNT_ID) || '</PHOTOGRAPHER_ACCOUNT_ID>');
  htp.p('<PUBLIC_ACCOUNT>' || xmlconv(cusrec.PUBLIC_ACCOUNT) || '</PUBLIC_ACCOUNT>');
  htp.p('<CUSTOMER_DISABLED>' || xmlconv(cusrec.CUSTOMER_DISABLED) || '</CUSTOMER_DISABLED>');
  htp.p('<BACKGROUND_IMG>' || xmlconv(cusrec.BACKGROUND_IMG) || '</BACKGROUND_IMG>');
  htp.p('<PLAN_ID>' || xmlconv(cusrec.PLAN_ID) || '</PLAN_ID>');
  htp.p('<PLAN_EVENT>' || xmlconv(cusrec.PLAN_EVENT) || '</PLAN_EVENT>');
  htp.p('<IS_BETA_TESTER>' || xmlconv(cusrec.IS_BETA_TESTER) || '</IS_BETA_TESTER>');
  htp.p('<SITE_TYPE>' || xmlconv(cusrec.SITE_TYPE) || '</SITE_TYPE>');
  htp.p('<EVENT_LOGON_USES_CODE>' || xmlconv(cusrec.EVENT_LOGON_USES_CODE) || '</EVENT_LOGON_USES_CODE>');
  htp.p('<EVENT_LOGON_PASSWORD_STYLE>' || xmlconv(cusrec.EVENT_LOGON_PASSWORD_STYLE) || '</EVENT_LOGON_PASSWORD_STYLE>');
  htp.p('<ACCOUNT_NAME>' || xmlconv(cusrec.ACCOUNT_NAME) || '</ACCOUNT_NAME>');
  htp.p('<DATE_HELD>' || xmlconv(cusrec.DATE_HELD) || '</DATE_HELD>');
  htp.p('<USERNAME>' || xmlconv(cusrec.USERNAME) || '</USERNAME>');
  htp.p('<PASSWORD>' || xmlconv(cusrec.PASSWORD) || '</PASSWORD>');
  htp.p('<PASSWORD_OWNER>' || xmlconv(cusrec.PASSWORD_OWNER) || '</PASSWORD_OWNER>');
  htp.p('<SCENE_NAME>' || xmlconv(cusrec.SCENE_NAME) || '</SCENE_NAME>');
  htp.p('<THEME_NAME>' || xmlconv(cusrec.THEME_NAME) || '</THEME_NAME>');
  htp.p('<THEME_TYPE>' || xmlconv(cusrec.THEME_TYPE) || '</THEME_TYPE>');
  htp.p('<ZOOM_FACTOR>' || xmlconv(cusrec.ZOOM_FACTOR) || '</ZOOM_FACTOR>');
  htp.p('<HOME_PAGE_OPTIONS>' || xmlconv(cusrec.HOME_PAGE_OPTIONS) || '</HOME_PAGE_OPTIONS>');
  htp.p('<HOME_PAGE_CATEGORY>' || xmlconv(cusrec.HOME_PAGE_CATEGORY) || '</HOME_PAGE_CATEGORY>');
  htp.p('<HOME_PAGE_LINK>' || xmlconv(cusrec.HOME_PAGE_LINK) || '</HOME_PAGE_LINK>');
  htp.p('<HOME_PAGE_OVERRIDE>' || xmlconv(cusrec.HOME_PAGE_OVERRIDE) || '</HOME_PAGE_OVERRIDE>');
  htp.p('<LINK_NAME>' || xmlconv(cusrec.LINK_NAME) || '</LINK_NAME>');
  htp.p('<FAILED_LOGINS>' || xmlconv(cusrec.FAILED_LOGINS) || '</FAILED_LOGINS>');
  htp.p('<DATE_CREATED>' || xmlconv(cusrec.DATE_CREATED) || '</DATE_CREATED>');
  htp.p('<DATE_EXPIRES>' || xmlconv(cusrec.DATE_EXPIRES) || '</DATE_EXPIRES>');
  htp.p('<DATE_TO_DELETE>' || xmlconv(cusrec.DATE_TO_DELETE) || '</DATE_TO_DELETE>');
  htp.p('<REDIRECT_SITE_ID>' || xmlconv(cusrec.REDIRECT_SITE_ID) || '</REDIRECT_SITE_ID>');
  htp.p('<PROFILE_ID>' || xmlconv(cusrec.PROFILE_ID) || '</PROFILE_ID>');
  htp.p('<CUSTOMER_MESSAGE>' || xmlconv(cusrec.CUSTOMER_MESSAGE) || '</CUSTOMER_MESSAGE>');
  htp.p('<HOME_PAGE_STYLE>' || xmlconv(cusrec.HOME_PAGE_STYLE) || '</HOME_PAGE_STYLE>');
  htp.p('<ON_LOGIN>' || xmlconv(cusrec.ON_LOGIN) || '</ON_LOGIN>');
  htp.p('<CAN_EDIT_META_DATA_VALUES>' || xmlconv(cusrec.CAN_EDIT_META_DATA_VALUES) || '</CAN_EDIT_META_DATA_VALUES>');
  htp.p('<IS_DOWNLOADED>' || xmlconv(cusrec.IS_DOWNLOADED) || '</IS_DOWNLOADED>');
  htp.p('<DATE_DOWNLOADED>' || xmlconv(cusrec.DATE_DOWNLOADED) || '</DATE_DOWNLOADED>');
  htp.p('<ENABLE_NOVELTIES>' || xmlconv(cusrec.ENABLE_NOVELTIES) || '</ENABLE_NOVELTIES>');
  htp.p('<CUSOBJ>' || xmlconv(cusrec.CUSOBJ) || '</CUSOBJ>');
  htp.p('<NOVELTY_FEATURES>' || xmlconv(cusrec.NOVELTY_FEATURES) || '</NOVELTY_FEATURES>');
  htp.p('<TOGGLE_DEFAULT>' || xmlconv(cusrec.TOGGLE_DEFAULT) || '</TOGGLE_DEFAULT>');
  htp.p('<TOGGLE_TAG>' || xmlconv(cusrec.TOGGLE_TAG) || '</TOGGLE_TAG>');
  htp.p('<TOGGLE_CONDITION>' || xmlconv(cusrec.TOGGLE_CONDITION) || '</TOGGLE_CONDITION>');
  htp.p('<TOGGLE_VALUE>' || xmlconv(cusrec.TOGGLE_VALUE) || '</TOGGLE_VALUE>');
  htp.p('<ENABLE_GREETINGCARDS>' || xmlconv(cusrec.ENABLE_GREETINGCARDS) || '</ENABLE_GREETINGCARDS>');
  htp.p('<RECEIVE_IMAGES_VIA_EMAIL>' || xmlconv(cusrec.receive_images_via_email) || '</RECEIVE_IMAGES_VIA_EMAIL>');
  htp.p('<RECEIVE_IMAGE_ACCOUNT>' || xmlconv(cusrec.receive_image_account) || '</RECEIVE_IMAGE_ACCOUNT>');
  htp.p('<RECEIVE_IMAGE_UMO_SCENE>' || xmlconv(cusrec.receive_image_umo_scene) || '</RECEIVE_IMAGE_UMO_SCENE>');
  htp.p('<RECEIVE_IMAGE_OPTIONS>' || xmlconv(cusrec.receive_image_options) || '</RECEIVE_IMAGE_OPTIONS>');
 htp.p( '</CUSTOMER_ACCOUNT>' );

 unload_table( 'PURCHASE_ORDER', 'where poid=' || purchord.poid );
 unload_table( 'ORDER_STYLE', 'where oid=' || voidrec.oid );
 unload_table( 'THEME', 'where theme_name=''' || pfx.theme_name || '''' );
 unload_table( 'THEME_TYPES', 'where theme_type=''' || theme_rec.theme_type || '''' );
exception when others then null;
end unload_account;

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

 function xmlname( vl in varchar2 )
  return varchar2
 as
  rv varchar2(32767);
 begin
  if vl is null then return( 'NULL' ); end if;
  rv := trim(vl);
  if substr(rv,1,1) in ('-','_') then rv := substr(rv,2); end if;
  rv := replace( rv, '-', '_' );
  rv := replace( rv, ' ', '_' );
  rv := replace( rv, '"', '' );
  rv := replace( rv, '#', '' );
  rv := replace( rv, '!', '' );
  rv := replace( rv, '%', '' );
  rv := replace( rv, '&', '_' );
  rv := replace( rv, '''', '' );
  rv := replace( rv, '+', '' );
  rv := replace( rv, '*', '' );
  rv := replace( rv, '$', '' );
  rv := replace( rv, '@', '' );
  rv := replace( rv, chr(9), '' );
  rv := replace( rv, chr(10), '' );
  rv := replace( rv, chr(13), '' );
  return( rv );
 end xmlname;

procedure unload_table( tname in varchar2, wclause in varchar2 )
as

  cursor_name	integer;
  dummy 	integer;
  col_count	integer;
  desc_t	dbms_sql.desc_tab;
  common_nmb	number;
  common_vc2	varchar2(4000);
  common_dte	date;
  common_blob	blob;
  common_clob	clob;
  tmpval	varchar2(4000);
  vl2		varchar2(4000);
  x		integer;

begin

  /*
 	Char - 96
  	VC2  - 1
        Nmb  - 2
        Date - 12
        Type - 109
        Blob - 113
        Clob - 112
  */

   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, 'select * from ' || tname || ' ' || wclause, dbms_sql.native );
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
    elsif desc_t(j).col_type = 113
     then
      dbms_sql.define_column(cursor_name,j,common_blob);
    elsif desc_t(j).col_type = 112
     then
      dbms_sql.define_column(cursor_name,j,common_clob);
    end if;
   end loop;
   dummy := dbms_sql.execute( cursor_name );

   htp.p( '<' || tname || '>' );
   loop
     dummy := dbms_sql.fetch_rows(cursor_name);
     if dummy = 0 then exit; end if;

     for j in 1..col_count loop
      tmpval := NULL;
      common_vc2 := NULL;
      common_nmb := NULL;
      common_dte := NULL;
      common_blob := NULL;
      common_clob := NULL;
      vl2 := NULL;

      if desc_t(j).col_type in (1,96)
       then
        dbms_sql.column_value_char(cursor_name,j,common_vc2);
        tmpval := rtrim( common_vc2 );

       elsif desc_t(j).col_type = 2
        then
         dbms_sql.column_value(cursor_name,j,common_nmb);
         tmpval := to_char( common_nmb );
         vl2 := vl2 || 'TYPE="NUMBER"';

       elsif desc_t(j).col_type = 12
        then
         dbms_sql.column_value(cursor_name,j,common_dte);
         tmpval := to_char( common_dte,LNG.TSMASK );
         vl2 := vl2 || 'TYPE="DATE"';

      end if;
      htp.p( '<' || upper(desc_t(j).col_name) || '>' || xmlconv(tmpval) || '</' || upper(desc_t(j).col_name) || '>' );
     end loop;

   end loop;
   htp.p( '</' || tname || '>' );
   dbms_sql.close_cursor( cursor_name );

end unload_table;

function decrypt_key( input_string_hex in varchar2, maxlength in integer default 128, ky in varchar2 )
 return varchar2
as

   raw_key             	raw(128) := utl_raw.cast_to_raw(substr(DECS.GENERAL_ENCRYPT_KEY || 'AABBCCDD',1,8));
   encrypted_raw        raw(2048);
   decrypted_raw        raw(2048);

 begin

   raw_key := utl_raw.cast_to_raw(substr( rpad(ky, 8, ' '),1,8));
   encrypted_raw := hextoraw( substr(input_string_hex,1,maxlength) );
   dbms_obfuscation_toolkit.desdecrypt(input => encrypted_raw, key => raw_key, decrypted_data => decrypted_raw);

   return( utl_raw.cast_to_varchar2(decrypted_raw) );

exception
 when others
  then
   return( NULL );
end decrypt_key;

procedure print_service( service in varchar2, parm1 in ump.parameters, parm2 in ump.parameters )
as

 cursor c1(vpoid integer) is select * from purchase_order where poid = vpoid;
 cursor c2(sbask integer) is select * from shopping_basket where shopping_id = sbask;

 purch		purchase_order%ROWTYPE;
 sbask		shopping_basket%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 umorec		umo%ROWTYPE;
 lmprq 		integer;
 sess		integer;

begin
 if parm1.count = 0
  then
   soap_error( service, 'No Parameters Supplied' );
   return;
 end if;

 select s_purchase_order.nextval into purch.poid from dual;
 select s_shopping_basket.nextval into sbask.shopping_id from dual;
 sbask.poid := purch.poid;
 insert into purchase_order(poid,status,date_created) values (purch.poid, 'REMOTE_PRINT_REQUEST', sysdate );
 insert into shopping_basket(poid,shopping_id) values (purch.poid, sbask.shopping_id);
 umorec.extras := repeated_fields(null,null,null,null,null,null,null,'TRUE','TRUE' );
 umorec.umo_id := 0;

 for j in parm1.first..parm1.last loop
  begin
  if substr(upper(parm1(j)),1, 6) = 'PURCH_' and substr(upper(parm1(j)), 7 ) not in ('PID','POID','STATUS','DATE_CREATED','SESSID')
   then
    execute immediate 'update purchase_order set ' || substr(upper(parm1(j)), 7 ) || ' = ''' || parm2(j) || ''' where poid = ' || purch.poid;
  end if;
  if substr(upper(parm1(j)),1, 6) = 'SBASK_' and substr(upper(parm1(j)), 7 ) not in ('SHOPPING_ID','POID','PHID')
   then
    execute immediate 'update shopping_basket set ' || substr(upper(parm1(j)), 7 ) || ' = ''' || parm2(j) || ''' where shopping_id = ' || sbask.shopping_id;
  end if;
  if upper(parm1(j)) = 'UMO_TYPE' then umorec.umo_type := parm2(j); end if;
  if upper(parm1(j)) = 'FILM_COLOUR' then umorec.extra_film_colour := parm2(j); end if;
  if upper(parm1(j)) = 'ROLL_ID' then umorec.extra_roll_id := parm2(j); end if;
  if upper(parm1(j)) = 'FILM_SIZE' then umorec.extra_film_size := parm2(j); end if;
  if upper(parm1(j)) = 'ORIGINAL_LOC' then umorec.photo_original_loc := parm2(j); end if;
  if upper(parm1(j)) = 'FILM_NAME' then umorec.extras.film_name := parm2(j); end if;
  exception
   when others then null;
  end;
 end loop;

 select s_login_session.nextval into sess from dual;
 update purchase_order set pid = G_pid, sessid = sess where poid = purch.poid;
 open c1(purch.poid);
 fetch c1 into purch;
 close c1;
 open c2(sbask.shopping_id);
 fetch c2 into sbask;
 close c2;
 insert into login_session(sessid,aid,date_created,login_type) values (sess,G_aid,sysdate,'CUSTOMER');
 commit;

 lab.run_print( surl=>null, purchord=>purch, sbrec=>sbask, umorec=>umorec, lmi=>G_lmrq, forcerun=>FALSE );
 htp.p( '<LAB_PRINT>' || purch.poid || '</LAB_PRINT>' );

end print_service;

function generate_webservice(purchord in purchase_order%ROWTYPE, sbrec in shopping_basket%ROWTYPE, umorec in umo%ROWTYPE )
 return varchar2
as

 env	varchar2(32767);

begin
 env := null;
 env := env || '<parameter xsi:type="xsd:string" name="UMO_TYPE">' || xmlconv( umorec.umo_type) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="FILM_COLOUR">' || xmlconv( umorec.extra_film_colour) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="ROLL_ID">' || xmlconv( umorec.extra_roll_id) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="FILM_SIZE">' || xmlconv( umorec.extra_film_size) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="ORIGINAL_LOC">' || xmlconv( umorec.photo_original_loc) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="FILM_NAME">' || xmlconv( umorec.extras.film_name) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_CONTACT_NAME">' || xmlconv( purchord.CONTACT_NAME) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_CONTACT_PHONE">' || xmlconv( purchord.CONTACT_PHONE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_SENDTO_NAME">' || xmlconv( purchord.SENDTO_NAME ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_SENDTO_STREET">' || xmlconv( purchord.SENDTO_STREET ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_SENDTO_SUBURB">' || xmlconv( purchord.SENDTO_SUBURB ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_SENDTO_CITY">' || xmlconv( purchord.SENDTO_CITY ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_SENDTO_POSTCODE">' || xmlconv( purchord.SENDTO_POSTCODE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_SENDTO_COUNTRY">' || xmlconv( purchord.SENDTO_COUNTRY) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_HOME_COUNTRY">' || xmlconv( purchord.HOME_COUNTRY) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_LOCAL_INTERNATION">' || xmlconv( purchord.LOCAL_INTERNATION ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_LAST_STEP">' || xmlconv( purchord.LAST_STEP ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_PAID_METHOD">' || xmlconv( purchord.PAID_METHOD ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_DATE_PURCHASED">' || xmlconv( purchord.DATE_PURCHASED) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_DATE_FULFILLED">' || xmlconv( purchord.DATE_FULFILLED) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_CONTACT_EMAIL">' || xmlconv( purchord.CONTACT_EMAIL ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_CONTACT_PASSWORD">' || xmlconv( purchord.CONTACT_PASSWORD) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_EVENT_CONFIRMED">' || xmlconv( purchord.EVENT_CONFIRMED ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_EVENT_ISSUE">' || xmlconv( purchord.EVENT_ISSUE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_EVENT_SHIPPED">' || xmlconv( purchord.EVENT_SHIPPED ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_PAYMENT_RECEIVED">' || xmlconv( purchord.PAYMENT_RECEIVED) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_IS_B2C">' || xmlconv( purchord.IS_B2C) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_PRINTED_OUT">' || xmlconv( purchord.PRINTED_OUT ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_DELIVERY_COST">' || xmlconv( purchord.DELIVERY_COST ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_MANUAL_SHIPPING">' || xmlconv( purchord.MANUAL_SHIPPING ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_DO_NOT_SPLIT_ORDER">' || xmlconv( purchord.DO_NOT_SPLIT_ORDER) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_SPECIAL_DISCOUNT">' || xmlconv( purchord.SPECIAL_DISCOUNT) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_PHOTOGRAPHER_DISCOUNT">' || xmlconv( purchord.PHOTOGRAPHER_DISCOUNT ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_OTHER_COST">' || xmlconv( purchord.OTHER_COST) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_MANUAL_SHIPPING_CHARGE">' || xmlconv( purchord.MANUAL_SHIPPING_CHARGE) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_AUTHORISED_BY">' || xmlconv( purchord.AUTHORISED_BY ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_AUTHORISED_DATE">' || xmlconv( purchord.AUTHORISED_DATE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_MFCTR_OTHER_COST">' || xmlconv( purchord.MFCTR_OTHER_COST) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_MFCTR_OTHER_COST_DESC">' || xmlconv( purchord.MFCTR_OTHER_COST_DESC ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_MFCTR_STND_SHIPPING">' || xmlconv( purchord.MFCTR_STND_SHIPPING ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_M_RESPONSE_CODE">' || xmlconv( purchord.M_RESPONSE_CODE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_M_RESPONSE_TEXT">' || xmlconv( purchord.M_RESPONSE_TEXT ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_M_SETTLEMENT_DATE">' || xmlconv( purchord.M_SETTLEMENT_DATE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_M_RRN">' || xmlconv( purchord.M_RRN ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_STATUS">' || xmlconv( purchord.STATUS) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_SHIPPING_MESSAGE">' || xmlconv( purchord.SHIPPING_MESSAGE) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_DELIVERY_TIME">' || xmlconv( purchord.DELIVERY_TIME ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_CUSTOMER_COMMENT">' || xmlconv( purchord.CUSTOMER_COMMENT) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_ORDER_COMMENT">' || xmlconv( purchord.ORDER_COMMENT ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_MERCHANT_REFERENCE">' || xmlconv( purchord.MERCHANT_REFERENCE) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_PROJECT_CODE">' || xmlconv( purchord.PROJECT_CODE) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_OID">' || xmlconv( purchord.OID ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_DELIVERY_TYPE">' || xmlconv( purchord.DELIVERY_TYPE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_APPLY_DISCOUNT_AT">' || xmlconv( purchord.APPLY_DISCOUNT_AT ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_CHEQUE_RECEIPT_NUMBER">' || xmlconv( purchord.CHEQUE_RECEIPT_NUMBER ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_CUSTOMER_COLUMN1">' || xmlconv( purchord.CUSTOMER_COLUMN1) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_CUSTOMER_COLUMN2">' || xmlconv( purchord.CUSTOMER_COLUMN2) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_CUSTOMER_COLUMN3">' || xmlconv( purchord.CUSTOMER_COLUMN3) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_CUSTOMER_COLUMN4">' || xmlconv( purchord.CUSTOMER_COLUMN4) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_CUSTOMER_COLUMN5">' || xmlconv( purchord.CUSTOMER_COLUMN5) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_CUSTOMER_COLUMN6">' || xmlconv( purchord.CUSTOMER_COLUMN6)  || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_REFUND_TOTAL">' || xmlconv( purchord.REFUND_TOTAL) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_REFUND_DATE">' || xmlconv( purchord.REFUND_DATE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_GST_INCL">' || xmlconv( purchord.GST_INCL) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_BILLING_GPO_BOX">' || xmlconv( purchord.BILLING_GPO_BOX ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_BILLING_NAME">' || xmlconv( purchord.BILLING_NAME) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_BILLING_STREET">' || xmlconv( purchord.BILLING_STREET) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_BILLING_SUBURB">' || xmlconv( purchord.BILLING_SUBURB) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_BILLING_CITY">' || xmlconv( purchord.BILLING_CITY) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_BILLING_POSTCODE">' || xmlconv( purchord.BILLING_POSTCODE) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_BILLING_COUNTRY">' || xmlconv( purchord.BILLING_COUNTRY ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_BILLING_EMAIL">' || xmlconv( purchord.BILLING_EMAIL ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_BILLING_FAX">' || xmlconv( purchord.BILLING_FAX ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_BILLING_PHONE">' || xmlconv( purchord.BILLING_PHONE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_BILLING_STATE">' || xmlconv( purchord.BILLING_STATE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_SENDTO_STATE">' || xmlconv( purchord.SENDTO_STATE) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_SENDTO_BRANCH">' || xmlconv( purchord.SENDTO_BRANCH ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_SENDTO_DEPARTMENT">' || xmlconv( purchord.SENDTO_DEPARTMENT ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_BILLING_BRANCH">' || xmlconv( purchord.BILLING_BRANCH) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_BILLING_DEPARTMENT">' || xmlconv( purchord.BILLING_DEPARTMENT) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_MANUAL_SHIP">' || xmlconv( purchord.MANUAL_SHIP ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_INITIAL_GRAND_TOTAL">' || xmlconv( purchord.INITIAL_GRAND_TOTAL ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_POSTAGE_WITHOUT_MANUAL">' || xmlconv( purchord.POSTAGE_WITHOUT_MANUAL) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_SENDTO_FIRSTNAME">' || xmlconv( purchord.SENDTO_FIRSTNAME) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_SENDTO_LASTNAME">' || xmlconv( purchord.SENDTO_LASTNAME ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_BILLING_FIRSTNAME">' || xmlconv( purchord.BILLING_FIRSTNAME ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="PURCH_BILLING_LASTNAME">' || xmlconv( purchord.BILLING_LASTNAME) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_PHID">' || xmlconv( sbrec.PHID ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_PPI">' || xmlconv( sbrec.PPI) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_FILM_TYPE">' || xmlconv( sbrec.FILM_TYPE) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_QTY">' || xmlconv( sbrec.QTY) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_PHOTO_SIZE">' || xmlconv( sbrec.PHOTO_SIZE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_PHOTO_COST">' || xmlconv( sbrec.PHOTO_COST ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_FRAME_STYLE">' || xmlconv( sbrec.FRAME_STYLE) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_FRAME_COST">' || xmlconv( sbrec.FRAME_COST ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_ALTERATION">' || xmlconv( sbrec.ALTERATION ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_ALTERATION_COST">' || xmlconv( sbrec.ALTERATION_COST) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_PHG_CODE">' || xmlconv( sbrec.PHG_CODE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_LAB_ID">' || xmlconv( sbrec.LAB_ID ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_MANUFCTR_CODE">' || xmlconv( sbrec.MANUFCTR_CODE) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_XREF_MFCTR_CODE">' || xmlconv( sbrec.XREF_MFCTR_CODE) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_IS_DISCOUNTED">' || xmlconv( sbrec.IS_DISCOUNTED) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_NAME">' || xmlconv( sbrec.NAME ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_PRICE">' || xmlconv( sbrec.PRICE) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_TAX">' || xmlconv( sbrec.TAX) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_COMMISSION">' || xmlconv( sbrec.COMMISSION ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_B2C_LAB_DISCOUNT">' || xmlconv( sbrec.B2C_LAB_DISCOUNT ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_LAB_CHARGE_PERC">' || xmlconv( sbrec.LAB_CHARGE_PERC) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_FILM_NAME">' || xmlconv( sbrec.FILM_NAME) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_ISGALLERY">' || xmlconv( sbrec.ISGALLERY) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_MUST_DOWNLOAD">' || xmlconv( sbrec.MUST_DOWNLOAD) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_STATUS_ID">' || xmlconv( sbrec.STATUS_ID) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_STATUS_PRIORITY">' || xmlconv( sbrec.STATUS_PRIORITY) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_STATUS_WORKFLOW">' || xmlconv( sbrec.STATUS_WORKFLOW) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_STATUS_MFCTR">' || xmlconv( sbrec.STATUS_MFCTR ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_WORK_STATE">' || xmlconv( sbrec.WORK_STATE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_ITEM_DISCOUNTED">' || xmlconv( sbrec.ITEM_DISCOUNTED) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_ITEM_DISC_CHARGE">' || xmlconv( sbrec.ITEM_DISC_CHARGE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_DELIVERY_TIME_LOCAL">' || xmlconv( sbrec.DELIVERY_TIME_LOCAL) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_DELIVERY_TIME_INT">' || xmlconv( sbrec.DELIVERY_TIME_INT) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_SURCHARGE_LOCAL">' || xmlconv( sbrec.SURCHARGE_LOCAL) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_SURCHARGE_INT">' || xmlconv( sbrec.SURCHARGE_INT) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_PRODUCTION_TIME">' || xmlconv( sbrec.PRODUCTION_TIME) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_STATUS">' || xmlconv( sbrec.STATUS ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_DELIVERY_DESC">' || xmlconv( sbrec.DELIVERY_DESC) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_PRODUCT_DESC">' || xmlconv( sbrec.PRODUCT_DESC ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_STATUS_COMMENT">' || xmlconv( sbrec.STATUS_COMMENT ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_PPM_ID">' || xmlconv( sbrec.PPM_ID ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_PPM_ID_LIMIT">' || xmlconv( sbrec.PPM_ID_LIMIT ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_UMO_WIDTH">' || xmlconv( sbrec.UMO_WIDTH) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_UMO_HEIGHT">' || xmlconv( sbrec.UMO_HEIGHT ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_UMO_FILM_NAME">' || xmlconv( sbrec.UMO_FILM_NAME) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_UMO_PHOTO_NAME">' || xmlconv( sbrec.UMO_PHOTO_NAME ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_UMO_TYPE">' || xmlconv( sbrec.UMO_TYPE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_CONTENTLENGTH">' || xmlconv( sbrec.CONTENTLENGTH) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_PPM_TITLE">' || xmlconv( sbrec.PPM_TITLE)  || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_FTP_LOCATION">' || xmlconv( sbrec.FTP_LOCATION ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_FTP_VIRTUAL_DIR">' || xmlconv( sbrec.FTP_VIRTUAL_DIR) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_INVOICE_NUMBER">' || xmlconv( sbrec.INVOICE_NUMBER ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_INVOICE_DATE">' || xmlconv( sbrec.INVOICE_DATE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_TAX_CODE">' || xmlconv( sbrec.TAX_CODE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_INVOICE_EXTRACTED">' || xmlconv( sbrec.INVOICE_EXTRACTED) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_PRODUCT_CLASS">' || xmlconv( sbrec.PRODUCT_CLASS) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_OVERRIDE_WFLOW_ORDER">' || xmlconv( sbrec.OVERRIDE_WFLOW_ORDER ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_ESTIMATED_DUE_DATE">' || xmlconv( sbrec.ESTIMATED_DUE_DATE ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_PRIORITY_OF_ITEM">' || xmlconv( sbrec.PRIORITY_OF_ITEM ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_THREAD_ID">' || xmlconv( sbrec.THREAD_ID)  || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_STATUS_AT_STEP">' || xmlconv( sbrec.STATUS_AT_STEP ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_SPECIAL_SHIPPING">' || xmlconv( sbrec.SPECIAL_SHIPPING ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_ROYALTY_API">' || xmlconv( sbrec.ROYALTY_API) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_ROYALTY_API_PK">' || xmlconv( sbrec.ROYALTY_API_PK ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_PRINTED_OUT">' || xmlconv( sbrec.PRINTED_OUT) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_USER_FEE_CODE">' || xmlconv( sbrec.USER_FEE_CODE) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_ORIGINAL_PHOTO_COST">' || xmlconv( sbrec.ORIGINAL_PHOTO_COST) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_LINEITEM_SPB">' || xmlconv( sbrec.LINEITEM_SPB ) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_PACKAGED_PRODUCT_ID">' || xmlconv( sbrec.PACKAGED_PRODUCT_ID) || '</parameter>';
 env := env || '<parameter xsi:type="xsd:string" name="SBASK_ITEM_DISPATCHED">' || xmlconv( sbrec.ITEM_DISPATCHED) || '</parameter>';
 return( env );
exception
 when others then return( env );
end generate_webservice;

procedure sql_stmt( service in varchar2, parm1 in ump.parameters, parm2 in ump.parameters )
as
 err	varchar2(4000);
 ty	varchar2(100);
begin
 if parm1.count = 0
  then
   soap_error( service, 'No Parameters Supplied' );
   return;
 end if;

 if G_Key = 'PICTION' then null; else soap_error( service, 'Invalid Encryption Key' ); return; end if;
 for j in parm1.first..parm1.last loop
  if parm1(j) = 'CALL'
   then
    ty := parm2(j);
  end if;
  if parm1(j) = 'SQL' and ty = 'DML'
   then
    begin
     execute immediate parm2(j);
    exception
     when others then err := sqlerrm;
    end;
  end if;
  if parm1(j) = 'SQL' and ty = 'DDL'
   then
    begin
     execute immediate parm2(j);
    exception
     when others then err := sqlerrm;
    end;
  end if;
  if parm1(j) = 'SQL' and ty = 'DCL'
   then
    begin
     execute immediate parm2(j) into err;
    exception
     when others then err := sqlerrm;
    end;
  end if;
 end loop;

 htp.p( '<RETURN_MESSAGE>' || err || '</RETURN_MESSAGE>' );

end sql_stmt;

procedure update_metadata( surl in varchar2, v_umo in integer, p1 in glbx.myarray, p2 in glbx.myarray )
as

 cursor c1(v_umo integer) is select * from umo where umo_id = v_umo;

 cursor c4( bftr varchar2, ut varchar2, tg varchar2 ) is
  select attribute_id
  from umo_attributes
  where sub_category = tg and
        business_feature = 'LandcareResearch' and
        umo_type = ut
union all
  select attribute_id
  from umo_attributes
  where sub_category = tg and
        umo_type = ut;

 umorec		umo%ROWTYPE;
 bl		boolean;
 v_attrib	integer;
 val		varchar2(4000);

begin
if not dapi.initialise_setup(surl, 'UPDATE_METADATA', reset=>FALSE )
 then
  htp.p( '<ERROR>' || dapi.GLOBAL_ERROR || '</ERROR>' );
  return;
end if;

open c1(v_umo);
fetch c1 into umorec;
close c1;
if umorec.umo_id is null
 then
  htp.p( '<ERROR>V_UMO:' || v_umo || ' not found</ERROR>' );
  return;
end if;

if DAPI.GLOBAL_CUSTOMER_ACCOUNT.aid <> umorec.aid
 then
  htp.p( '<ERROR>Access not allowed on this image :' || v_umo || ' </ERROR>' );
  return;
end if;

if p1.count = 0 then htp.p( '<ERROR>No Metadata Tags Specified</ERROR>' ); return; end if;

 for j in p1.first..p1.last loop
  v_attrib := null;
  open c4(DAPI.GLOBAL_CUSTOMER_ACCOUNT.theme_type,umorec.umo_type,upper(p1(j)));
  fetch c4 into v_attrib;
  close c4;
  if v_attrib is null
   then
    htp.p( '<ERROR>Could not find tag for: ' || p1(j) || '</ERROR>' );
   else
    bl := ump.umo_modify_entry( v_umo=>umorec.umo_id, attribid=>v_attrib, key_val=>p2(j), acid=>umorec.aid, position=>1, actual_api=>null, extract_numbers=>'F');
    if bl
     then
      htp.p( '<SUCCESS>Tag Updated: ' || p1(j) || '</SUCCESS>' );
     else
      htp.p( '<ERROR>Unable to update tag: ' || p1(j) || '</ERROR>' );
    end if;
  end if;
 end loop;

exception
 when others then
  htp.p( '<ERROR>General Error in update_metadata:' || sqlerrm || ' </ERROR>' );
end update_metadata;

end soap;

/
