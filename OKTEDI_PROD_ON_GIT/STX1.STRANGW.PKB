CREATE OR REPLACE package body STX1.strangw
as -- version 1.0  -- added by DBanjo
 /*   
 History:
 1.0.0 Beta Dev (MK)
 1.0.1 Beta Dev (MK) - added interface1, interface2 and interface 3 coding
 1.0.3 Changed update interface2 to reference recno. (Jul 2018)
 */

 version		constant	  varchar2(20) := '1.0.0E';
 err_found	    			  boolean;
 g_another_test               varchar2(100);
 g_request				      varchar2(100);
 g_name					      varchar2(100) := 'STRANG_POSPUSH_';
 g_digest_un				  varchar2(100) := 'GLMS_SERVICE';
 g_digest_pw				  varchar2(100) := 'Eo^d3LFj';
 -- Prod
 g_interface_2_url			  varchar2(1000) := 'https://glms.p1p.oktedi.com:52001/XISOAPAdapter/MessageServlet?senderParty=&senderService=GLMS&receiverParty=&receiverService=&interface=glmsGRofPurchaseOrder_SI_Async_OB&interfaceNamespace=http://www.stxgroup.com.au/glms';
 g_interface_4_url			  varchar2(1000) := 'https://glms.p1p.oktedi.com:52001/XISOAPAdapter/MessageServlet?senderParty=&senderService=GLMS&receiverParty=&receiverService=&interface=glmsShippingStatus_SI_Async_OB&interfaceNamespace=http://www.stxgroup.com.au/glms';
 interface_2_status	constant  integer := 7;

/* acc test
 g_name					    varchar2(100) := 'STRANG_POSPUSH_';
 g_digest_un				varchar2(100) := 'GLMS_SERVICE';
 g_digest_pw				varchar2(100) := 'rSiUMs81';
 -- g_interface_2_url	    varchar2(1000) := 'http://glms.p1d.oktedi.com:52000/XISOAPAdapter/MessageServlet?senderParty=&senderService=GLMS&receiverParty=&receiverService=&interface=glmsGRofPurchaseOrder_SI_Async_OB&interfaceNamespace=http://www.stxgroup.com.au/glms';
 -- Acc Test
 g_interface_2_url			varchar2(1000) := 'http://glms.p1r.oktedi.com:52000/XISOAPAdapter/MessageServlet?senderParty=&senderService=GLMS&receiverParty=&receiverService=&interface=glmsGRofPurchaseOrder_SI_Async_OB&interfaceNamespace=http://www.stxgroup.com.au/glms';
 g_interface_4_url			varchar2(1000) := 'http://glms.p1r.oktedi.com:52000/XISOAPAdapter/MessageServlet?senderParty=&senderService=GLMS&receiverParty=&receiverService=&interface=glmsShippingStatus_SI_Async_OB&interfaceNamespace=http://www.stxgroup.com.au/glms';
*/

/*
Username	GLMS_SERVICE
Password	Eo^d3LFj
Root URL	https://glms.p1p.oktedi.com:52001
Ping		https://glms.p1p.oktedi.com:52001/sap/public/ping

Interface2
https://glms.p1p.oktedi.com:52001/XISOAPAdapter/MessageServlet?senderParty=&senderService=GLMS&receiverParty=&receiverService=&interface=glmsGRofPurchaseOrder_SI_Async_OB&interfaceNamespace=http://www.stxgroup.com.au/glms

Interface4
https://glms.p1p.oktedi.com:52001/XISOAPAdapter/MessageServlet?senderParty=&senderService=GLMS&receiverParty=&receiverService=&interface=glmsShippingStatus_SI_Async_OB&interfaceNamespace=http://www.stxgroup.com.au/glms
*/

 procedure err( errm in varchar2, errcode in integer default null, sethdr in boolean default FALSE, show_mime in boolean default TRUE, b1 in boolean default FALSE )
 as
 begin
  if sethdr
   then
    htp.init;
    owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
    htp.prn('Status: ' || errcode || ' ' || errm || xtra.NL_CHAR);
    owa_util.http_header_close;
    htp.p( '<err><msg>' || xtra.xmlconv(errm) || '</msg><errcode>' || xtra.xmlconv(errcode) || '</errcode></err>' );
    return;
  end if;
  if show_mime
   then
    owa_util.mime_header('text/xml');
  end if;
  htp.p( '<err><msg>' || xtra.xmlconv(errm) || '</msg><errcode>' || xtra.xmlconv(errcode) || '</errcode></err>' );
 end err;

 procedure external_audit( vtype in varchar2, v in varchar2, v1 in varchar2 default null, v2 in varchar2 default null, v3 in varchar2 default null, v4 in varchar2 default null, v5 in varchar2 default null, v6 in varchar2 default null, v7 in varchar2 default null )
 as
  f	utl_file.file_type;
 begin
  if vtype = '1'
   then
    f := utl_file.fopen( 'c:\temp', 'prd_xe_interface1.csv', 'a', 4000 );
  elsif vtype = '2'
   then
    f := utl_file.fopen( 'c:\temp', 'prd_xe_interface2.csv', 'a', 4000 );
  elsif vtype = '3'
   then
    f := utl_file.fopen( 'c:\temp', 'prd_xe_interface3.csv', 'a', 4000 );
  elsif vtype = '4'
   then
    f := utl_file.fopen( 'c:\temp', 'prd_xe_interface4.csv', 'a', 4000 );
  elsif vtype = '5'
   then
    f := utl_file.fopen( 'c:\temp', 'prd_xe_interface5.csv', 'a', 4000 );
  elsif vtype = '6'
   then
    f := utl_file.fopen( 'c:\temp', 'prd_xe_interface6.csv', 'a', 4000 );
  elsif vtype = '7'
   then
    f := utl_file.fopen( 'c:\temp', 'prd_xe_interface7.csv', 'a', 4000 );
  elsif vtype = '8'
   then
    f := utl_file.fopen( 'c:\temp', 'prd_xe_interface8.csv', 'a', 4000 );
  elsif vtype = '9'
   then
    f := utl_file.fopen( 'c:\temp', 'prd_xe_interface9.csv', 'a', 4000 );
  elsif vtype = '10'
   then
    f := utl_file.fopen( 'c:\temp', 'prd_xe_interface10.csv', 'a', 4000 );     
  end if;

  utl_file.put_line( f, systimestamp || ',' || v || ',' || v1 || ',' || v2 || ',' || v3 || ',' || v4 || ',' || v5 || ',' || v6 || ',' || v7 );

  utl_file.fclose(f);

 exception
  when others then null;
 end external_audit;

 function rst(p_path in varchar2 default null, x out owa.vc_arr, y out owa.vc_arr)
  return boolean
 as

  n		varchar2(100);
  z		owa.vc_arr;
  b		integer;
  ajax_hdr	varchar2(100);
  ctr		integer;
  frec		boolean;
  decode_call	varchar2(100);
  ri		varchar2(1000);
  sn		varchar2(100);
  vkey		varchar2(1000);

 begin
  ctr := 0;

  if p_path is null
   then
    -- Mod OWA mod
    sn := owa_util.get_cgi_env('SCRIPT_NAME');
    ri := owa_util.get_cgi_env('REQUEST_URI');
    ri := trim(substr(ri,length(sn)+1));
    xtra.comma_delimited(ri,z,'/');
   else
    ri := p_path;
    xtra.comma_delimited(p_path,z,'/');
  end if;
  if z.count = 0
   then
    return( TRUE );
  end if;

  for j in z.first..z.last loop
   ctr := ctr + 1;
   b := instr(z(j),'=');
   if nvl(b,0) = 0
    then
     x(ctr) := z(j);
     y(ctr) := null;
     if substr(x(ctr),1,1) in ('?','&') then x(ctr) := trim(substr(x(ctr),2)); end if;
     goto BYPASS;
   end if;
   x(ctr) := trim(substr(z(j),1,b-1));
   if substr(x(ctr),1,1) in ('?','&') then x(ctr) := trim(substr(x(ctr),2)); end if;
   y(ctr) := trim(substr(z(j),b+1));
   <<BYPASS>>
   null;
  end loop;

  /*
  vkey := owa_util.get_cgi_env('HTTP_X_CLEVELANDART_API_KEY');
  if vkey is not null
   then
    ctr := ctr + 1;
    x(ctr) := 'key';
    y(ctr) := trim(vkey);
  end if;
  */

  return( TRUE );

 exception
  when others then
   err( 'Err in strangw:' || sqlerrm,1000);
   return( FALSE );
 end rst;

 procedure cleanup( fname in varchar2, iserr in boolean default TRUE )
 as
 begin
  if fname is null then return; end if;
  delete from apache_ows_content where name = fname;
  if iserr then err_found := TRUE; end if;
  commit;
 end cleanup;

 function process_push( varea in varchar2, vkey in varchar2, verbose in varchar2, vtrace in boolean, fname in varchar2)
  return boolean
 as

  cursor c1(fnm varchar2) is select * from apache_ows_content where name = fnm;

  c1rec 	c1%ROWTYPE;

 begin
  open c1(fname);
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    close c1;
    err( '[1030] BODY not found:' || fname || '-' || g_request,1110);
    return( FALSE );
   else
    close c1;
  end if;

  if dbms_lob.getlength(c1rec.blob_content) = 0
   then
    err( '[1040] BODY not found:' || fname || '-' || g_request,1120);
    return( FALSE );
  end if;
  return( TRUE );
 exception
  when others then
   err( '[1050] Err in process_push:' || sqlerrm, 404, TRUE);
   return( FALSE );
 end process_push;

 procedure process_ping( x in owa.vc_arr, y in owa.vc_arr )
 as

  cursor c1 is select count(*) from strang.containers ;
  cursor c2 is select count(*) from strang.receivals;
  cursor c3 is select count(*) from strang.lov;
  cursor c4 is select count(*) from strang.detailrs;
  cursor c5 is select count(*) mx, max(OFF_SITE_RECEIPT) md, min(OFF_SITE_RECEIPT) mn from strang.pos;
  cursor c6 is select count(*) from strang.ships_airway;
  cursor c7 is select count(*) from strang.movements;

  vtot 	integer;
  md	date;
  mdt	date;

 begin
    owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
    htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
    owa_util.http_header_close;
    htp.p( '<ping>' );
     vtot := null;
     open c1; fetch c1 into vtot; close c1;
     htp.p( '<containers>' || vtot || '</containers>' );

     vtot := null;
     open c2; fetch c2 into vtot; close c2;
     htp.p( '<receivals>' || vtot || '</receivals>' );

     vtot := null;
     open c3; fetch c3 into vtot; close c3;
     htp.p( '<lov>' || vtot || '</lov>' );

     vtot := null;
     open c4; fetch c4 into vtot; close c4;
     htp.p( '<detailrs>' || vtot || '</detailrs>' );

     vtot := null;
     open c5; fetch c5 into vtot, md, mdt; close c5;
     htp.p( '<pos maxreceipt="' || to_char(md,'dd-mon-yyyy hh24:mi:ss') || '" minreceipt="' || to_char(mdt,'dd-mon-yyyy hh24:mi:ss') || '">' || vtot || '</pos>' );

     vtot := null;
     open c6; fetch c6 into vtot; close c6;
     htp.p( '<ships_airway>' || vtot || '</ships_airway>' );

     vtot := null;
     open c7; fetch c7 into vtot; close c7;
     htp.p( '<movements>' || vtot || '</movements>' );

    htp.p( '</ping>' );
 exception
  when others then
   err( '[1070] Err in process_ping:' || sqlerrm, 404, TRUE);
 end process_ping;
procedure process_image( x in owa.vc_arr, y in owa.vc_arr )
 as
  l_blob  BLOB;
  v_seal  varchar2(50);
  v_container varchar2(100);
  f_name  varchar2(30);
  v_photo_location varchar2(50);
  v_dir varchar2(200);
  v_file varchar2(100);
  srcFile   BFILE ;
  fLen      NUMBER;
  dest      BLOB;
  
  BEGIN


  if x.exists(3) and x.exists(4) and x.exists(5) and x.exists(6) then 
     if upper(x(6)) = 'CHECK' then
        v_container := x(3);
        v_seal := x(4);
        v_photo_location := x(5);
        v_dir := websys.glbx.extract_master_parameter('STRANG_RECEIVALS_DIR')|| websys.decs.UNIX_OR_NT || v_container||'_'||v_seal || websys.decs.UNIX_OR_NT || v_photo_location;
        v_file := v_container||'_'||v_seal||'_'||v_photo_location||'.png';
        if websys.file_exists(v_dir, v_file) then
          owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
          htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
          owa_util.http_header_close;
          htp.p( '<container>');
          htp.p( '<movement_no>' || xtra.xmlconv(v_container) || '</movement_no>');      
          htp.p( '<seal>' || xtra.xmlconv(v_seal) || '</seal>' );
          htp.p( '<photo_type>' || xtra.xmlconv(v_photo_location)|| '</photo_type>' );
          htp.p( '<photo_present>Y</photo_present>' );
          htp.p( '</container>' );         
        else
          owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
          htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
          owa_util.http_header_close;
          htp.p( '<container>');
          htp.p( '<movement_no>' || xtra.xmlconv(v_container) || '</movement_no>');      
          htp.p( '<seal>' || xtra.xmlconv(v_seal) || '</seal>' );
          htp.p( '<photo_type>' || xtra.xmlconv(v_photo_location)|| '</photo_type>' );
          htp.p( '<photo_present>N</photo_present>' );
          htp.p( '</container>' );
        end if; 
        return;    
     else 
        return;
     end if;
  elsif x.exists(3) and x.exists(4) and x.exists(5) then 
     v_container := x(3);
     v_seal := x(4);
     v_photo_location := x(5);
  end if;
  
  DBMS_LOB.CREATETEMPORARY(dest, TRUE);
  
  v_dir := websys.glbx.extract_master_parameter('STRANG_RECEIVALS_DIR')|| websys.decs.UNIX_OR_NT || v_container||'_'||v_seal || websys.decs.UNIX_OR_NT || v_photo_location;
  v_file := v_container||'_'||v_seal||'_'||v_photo_location||'.png';
  
  if websys.file_exists(v_dir, v_file) then
     srcFile := BFILENAME('PRODDIR', v_container||'_'||v_seal || websys.decs.UNIX_OR_NT ||v_photo_location||websys.decs.UNIX_OR_NT||v_file );
     DBMS_LOB.OPEN(srcFile, dbms_lob.file_readonly);
     fLen := dbms_lob.getlength(srcFile);
     DBMS_LOB.LoadFromFile(dest, srcFile, fLen); 
     dbms_lob.close(srcFile);
     commit;
  else 
     raise_application_error(-20001,'No image file found');   
  end if;

  OWA_UTIL.mime_header('image/png', FALSE);
  HTP.p('Content-Length: ' || DBMS_LOB.getlength(dest));
  HTP.p('Content-Disposition: filename="' || v_file || '"');
  OWA_UTIL.http_header_close;
  WPG_DOCLOAD.download_file(dest);
  
  DBMS_LOB.FREETEMPORARY(dest);


 exception
  when others then
   err( '[1071] Err in process_image:' || sqlerrm, 404, TRUE);
 end process_image;
 
 procedure process_print_image( x in owa.vc_arr, y in owa.vc_arr )
 as
  l_blob      BLOB;
  v_seal      varchar2(50);
  v_container varchar2(100);
  f_name      varchar2(30);
  v_username  varchar2(50);
  v_filename  varchar2(100);
  v_dir       varchar2(200);
  v_file      varchar2(100);
  srcFile     BFILE ;
  fLen        NUMBER;
  dest        BLOB;
  
  BEGIN

  if x.exists(3) and x.exists(4) and x.exists(5) then 
     v_container := x(3);
     v_seal := x(4);
     v_username := x(5);
  end if;
  
  DBMS_LOB.CREATETEMPORARY(dest, TRUE);
  


  websys.CONTAINER_REPORT_PDF(v_container, v_seal, v_username, v_filename);
  
  v_file := websys.glbx.extract_fname(v_filename,'FILENAME');
  v_dir :=  websys.glbx.extract_fname(v_filename,'PWD');
  
  if websys.file_exists(v_dir, v_file) then
  
     srcFile := BFILENAME('TEST_DIR', v_file );
     
     DBMS_LOB.OPEN(srcFile, dbms_lob.file_readonly);
     fLen := dbms_lob.getlength(srcFile);
     DBMS_LOB.LoadFromFile(dest, srcFile, fLen); 
     dbms_lob.close(srcFile);
     commit;
  else 
     raise_application_error(-20001,'No image file found');   
  end if;

  OWA_UTIL.mime_header('image/pdf', FALSE);
  HTP.p('Content-Length: ' || DBMS_LOB.getlength(dest));
  HTP.p('Content-Disposition: filename="' || v_file || '"');
  OWA_UTIL.http_header_close;
  WPG_DOCLOAD.download_file(dest);
  
  DBMS_LOB.FREETEMPORARY(dest);

 exception
  when others then
   err( '[1071] Err in process_image:' || sqlerrm, 404, TRUE);
 end process_print_image;
 
procedure process_print_image_html( x in owa.vc_arr, y in owa.vc_arr )
 as
  l_blob      BLOB;
  v_seal      varchar2(50);
  v_container varchar2(100);
  f_name      varchar2(30);
  v_username  varchar2(50);
  v_filename  varchar2(100);
  v_dir       varchar2(200);
  v_file      varchar2(100);
  srcFile     BFILE ;
  fLen        NUMBER;
  dest        BLOB;
  parts       BLOB;
  j           integer;
  v_files     WEBSYS.GLBX.MYARRAY; --owa.vc_arr; 
  
  
  BEGIN

  if x.exists(3) and x.exists(4) and x.exists(5) then 
     v_container := x(3);
     v_seal := x(4);
     v_username := x(5);
  end if;
  
  DBMS_LOB.CREATETEMPORARY(dest, TRUE);
  
  websys.CONTAINER_REPORT_HTML(v_container, v_seal, v_username, v_filename);
  
  v_file := websys.glbx.extract_fname(v_filename,'FILENAME');
  v_dir :=  websys.glbx.extract_fname(v_filename,'PWD');
  
  
  if websys.file_exists(v_dir, v_file) then
     srcFile := BFILENAME('TEMP_DIR', v_file );
     
     DBMS_LOB.OPEN(srcFile, dbms_lob.file_readonly);
     fLen := dbms_lob.getlength(srcFile);
     DBMS_LOB.LoadFromFile(dest, srcFile, fLen); 
     dbms_lob.close(srcFile);
     commit;
  else 
     raise_application_error(-20001,'No image file found');   
  end if;

  --OWA_UTIL.mime_header('image/pdf', FALSE);
  OWA_UTIL.mime_header('text/html', FALSE);
  HTP.p('Content-Length: ' || DBMS_LOB.getlength(dest));
  HTP.p('Content-Disposition: filename="' || v_file || '"');
  OWA_UTIL.http_header_close;
  WPG_DOCLOAD.download_file(dest);
  
  DBMS_LOB.FREETEMPORARY(dest);
  
  
--------------------------------------------------------------------------------------


  

 exception
  when others then
   err( '[1071] Err in process_image:' || sqlerrm, 404, TRUE);
 end process_print_image_html;
 
 procedure process_status( x in owa.vc_arr, y in owa.vc_arr )
 as

  cursor c2(jname varchar2) is select * from user_scheduler_jobs where job_name like jname;

  c2rec	c2%ROWTYPE;

 begin
    owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
    htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
    owa_util.http_header_close;
    htp.p( '<status>' );
    open c2(g_name || '%' );
    fetch c2 into c2rec;
    close c2;
    if c2rec.job_name is null
     then
      htp.p( '<result>Job not running</result>' );
     else
      htp.p( '<name>' || c2rec.job_name || '</name>' );
      htp.p( '<start>' || to_char(c2rec.start_date,'dd-mon-yyyy hh24:mi:ss') || '</start>' );
      htp.p( '<result>' || c2rec.state || '</result>' );
    end if;
    htp.p( '</status>' );
 exception
  when others then
   err( '[1080] Err in process_status:' || sqlerrm, 404, TRUE);
 end process_status;
 
 procedure process_pos( x in owa.vc_arr, y in owa.vc_arr )
 as

  cursor c1(vpo varchar2) is select p.* from strang.pos p where po = vpo order by recno;
  cursor c1t(vpo varchar2) is select count('x') tot from strang.pos p where po = vpo;

  vpo 	varchar2(100);
  vtot	integer;

 begin
    if x.exists(3)
     then
      vpo := x(3);
      open c1t(vpo);
      fetch c1t into vtot;
      close c1t;
      if nvl(vtot,0) = 0
       then
        err( '[1010] Err in process_pos:' || 'PO not found [' || vpo || ']', 404, TRUE);
        return;
      end if;

     else
      err( '[1011] Err in process_pos:' || 'No PO provided', 404, TRUE);
      return;
    end if;

    owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
    htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
    owa_util.http_header_close;

    htp.p( '<pos id="' || vpo || '" tot="' || vtot || '">' );
    for c1rec in c1(vpo) loop
     htp.p( '<item rownumber="' || c1%ROWCOUNT || '">' );
      htp.p( '<recno>' || xtra.xmlconv(c1rec.recno) || '</recno>' );
      htp.p( '<inventoryno>' || xtra.xmlconv(c1rec.inventoryno) || '</inventoryno>' );
      htp.p( '<po>' || xtra.xmlconv(c1rec.po) || '</po>' );
      htp.p( '<supinv>' || xtra.xmlconv(c1rec.supinv) || '</supinv>' );
      htp.p( '<amount>' || xtra.xmlconv(c1rec.amount) || '</amount>' );
      htp.p( '<qty>' || xtra.xmlconv(c1rec.qty ) || '</qty>' );
      htp.p( '<unit_unitused>' || xtra.xmlconv(c1rec.unit_unitused) || '</unit_unitused>' );
      htp.p( '<ctry_countrycode >' || xtra.xmlconv(c1rec.ctry_countrycode  ) || '</ctry_countrycode>' );
      htp.p( '<gstc_gstcode>' || xtra.xmlconv(c1rec.gstc_gstcode) || '</gstc_gstcode>' );
      htp.p( '<gst>' || xtra.xmlconv(c1rec.gst) || '</gst>' );
      htp.p( '<tamount>' || xtra.xmlconv(c1rec.tamount) || '</tamount>' );
      htp.p( '<deliveryno>' || xtra.xmlconv(c1rec.deliveryno ) || '</deliveryno >' );
      htp.p( '<primary_rowid>' || xtra.xmlconv(to_char(c1rec.primary_rowid)) || '</primary_rowid>' );
      htp.p( '<site_owner>' || xtra.xmlconv(c1rec.site_owner) || '</site_owner>' );
      htp.p( '<date_modified>' || xtra.xmlconv(to_char(c1rec.date_modified,'dd-mon-yyyy hh24:mi:ss')) || '</date_modified>' );
      htp.p( '<po_item_no>' || xtra.xmlconv(c1rec.po_item_no ) || '</po_item_no>' );
      htp.p( '<po_warehouse>' || xtra.xmlconv(c1rec.po_warehouse   ) || '</po_warehouse>' );
      htp.p( '<po_waybill_type>' || xtra.xmlconv(c1rec.po_waybill_type) || '</po_waybill_type>' );
      htp.p( '<off_site_receipt>' || xtra.xmlconv(to_char(c1rec.off_site_receipt,'dd-mon-yyyy hh24:mi:ss')) || '</off_site_receipt>' );
      htp.p( '<excise_qty>' || xtra.xmlconv(c1rec.excise_qty ) || '</excise_qty>' );
      htp.p( '<excise_unit>' || xtra.xmlconv(c1rec.excise_unit) || '</excise_unit>' );
      htp.p( '<sap_delno>' || xtra.xmlconv(c1rec.sap_delno  ) || '</sap_delno>' );
      htp.p( '<sap_delno_item>' || xtra.xmlconv(c1rec.sap_delno_item ) || '</sap_delno_item>' );
      htp.p( '<grn>' || xtra.xmlconv(c1rec.grn  ) || '</grn>' );
      htp.p( '<grn_item>' || xtra.xmlconv(c1rec.grn_item  ) || '</grn_item>' );
      htp.p( '<entry_item>' || xtra.xmlconv(c1rec.entry_item ) || '</entry_item>' );
      htp.p( '<delivery_charge>' || xtra.xmlconv(c1rec.delivery_charge) || '</delivery_charge>' );
      htp.p( '<sap_delno_qty>' || xtra.xmlconv(c1rec.sap_delno_qty  ) || '</sap_delno_qty>' );
      htp.p( '<original_tamount>' || xtra.xmlconv(c1rec.original_tamount   ) || '</original_tamount>' );
      htp.p( '<original_delivery_charge>' || xtra.xmlconv(c1rec.original_delivery_charge) || '</original_delivery_charge>' );
      htp.p( '<state>' || xtra.xmlconv(c1rec.state ) || '</state>' );
      htp.p( '<ahecc>' || xtra.xmlconv(c1rec.ahecc ) || '</ahecc>' );
     htp.p( '</item>' );
    end loop;
   htp.p( '</pos>' );
 exception
  when others then
   err( '[1045] Err in process_pos:' || sqlerrm, 404, TRUE);
 end process_pos;
 procedure process_scan_metadata( x in owa.vc_arr, y in owa.vc_arr )
 as
 
   cursor c1 (vmetadata varchar2) is 
  select code, description, lov_name 
       , lag(lov_name) over (order by lov_name, code ) prev_lov_name
       , lead(lov_name) over (order by lov_name, code ) next_lov_name
  from (
  select code, description, 'LOCATIONS' as lov_name from strang.lov where lov_name = 'LOCATIONS' and cole = 'LOCATION'
  union all
  select code, description, 'WAREHOUSES' as lov_name  from strang.lov where lov_name = 'LOCATIONS' and cole = 'WAREHOUSE'
  union all
  SELECT ca.username as code
       , CASE WHEN c.approval IS NULL THEN 'N' ELSE 'Y' END description
       , 'USERS' lov_name
  FROM websys.customer_account ca
  INNER JOIN
  (SELECT cr.aid
     FROM websys.piction_roles pr, websys.customer_roles cr 
    WHERE pr.role_id =  10
      AND pr.ROLE_ID = cr.role_id
      ) b  ON (ca.aid = b.aid)
   LEFT JOIN 
   (SELECT cr.aid,  'Y' approval
     from websys.customer_roles cr,  websys.piction_roles pr
    where pr.role_name  =  'CONTAINER APPROVAL'
      and cr.role_id = pr.ROLE_ID 
      ) c  on (ca.aid = c.aid)
  where date_expires > sysdate
   union all
  SELECT ca.username as code
       , 'U' description
       , 'USERS' lov_name
  FROM websys.customer_account ca
  WHERE EXISTS
  (SELECT  1 
     FROM websys.customer_roles cr, websys.piction_roles pr,  websys.piction_roles pr2
    WHERE cr.role_id = pr.ROLE_ID 
      AND cr.aid = ca.aid 
      AND pr.role_name in ( 'MELBOURNE','PERTH','KIUNGA'))
  AND EXISTS   
  (SELECT 1
     FROM websys.customer_roles cr, websys.piction_roles pr2
    WHERE cr.role_id = pr2.ROLE_ID 
      AND pr2.role_name  = 'CONTAINER UNPACK'
      AND cr.aid = ca.aid ) 
  AND ca.date_expires > sysdate
  union all
    SELECT ca.username as code
       , 'P' description
       , 'USERS' lov_name
  FROM websys.customer_account ca
  INNER JOIN
  (SELECT cr.aid
     FROM websys.piction_roles pr, websys.customer_roles cr 
    WHERE pr.role_id in ( 17)
      AND pr.ROLE_ID = cr.role_id
      ) b  ON (ca.aid = b.aid and ca.date_expires > sysdate)
  union all
  select code, description, lov_name from strang.lov where lov_name = 'HAZARD_CLASS'
  union all
  select code, description, lov_name from strang.lov where lov_name = 'MOVEMENT_STATUS'
  union all
  select code, description, lov_name from strang.lov where lov_name = 'SMP_PACKTYPES'
  union all
  select code, description, lov_name from strang.lov where lov_name = 'URGENCY'
  union all
  select code, description, lov_name from strang.lov where lov_name = 'MOVEMENTS'
  union all
  select code, code as description, 'CARGO_TYPE' lov_name -- modified by DB advised by JMASSEY
  from strang.lov 
  where lov_name = 'CTRTYPE'
    and  code in
  ('GENERAL', 'HAZ', 'HASTINGS','DEEPCORE', 'STAR MART', 'PROJECT', 'PRIORITY')
  union all
  select code, description, 'ISO_CONTAINER_TYPE' lov_name from strang.lov where lov_name = 'UNCTNTAB'
  union all
  select to_char(customer_id), customer, customer_type from STRANG.CUSTOMERS where customer_type = 'CUSTOMER'
  union all
  select 'S' code, 'SEA' description, 'MOVEMENT_MODE' lov_name from dual
  union all
  select 'A' code, 'AIR' description, 'MOVEMENT_MODE' lov_name from dual) tmp
  where (vmetadata is null or UPPER(tmp.lov_name ) like upper(vmetadata)||'%' )
  order by 3,2, 1;

  cursor c2 (v_username varchar2) is 
  SELECT ca.username as code
       , CASE WHEN c.approval IS NULL THEN 'N' ELSE 'Y' END description
       , ca.password_owner password 
       , 'USERS' lov_name
  FROM websys.customer_account ca
  INNER JOIN
  (SELECT cr.aid,role_name
     FROM websys.piction_roles pr, websys.customer_roles cr 
    WHERE pr.role_id =  10
      AND pr.ROLE_ID = cr.role_id
      ) b  ON (ca.aid = b.aid)
   LEFT JOIN 
   (SELECT cr.aid,  'Y' approval
     from websys.customer_roles cr,  websys.piction_roles pr
    where pr.role_name  =  'CONTAINER APPROVAL'
      and cr.role_id = pr.ROLE_ID 
      ) c  on (ca.aid = c.aid)
  where date_expires > sysdate
  and ca.username = v_username
    union all
  SELECT ca.username as code
       , 'N' description
       ,  ca.password_owner password 
       , 'USERS' lov_name
  FROM websys.customer_account ca
  WHERE EXISTS
  (SELECT  1 
     FROM websys.customer_roles cr, websys.piction_roles pr,  websys.piction_roles pr2
    WHERE cr.role_id = pr.ROLE_ID 
      AND cr.aid = ca.aid 
      AND pr.role_name in ( 'MELBOURNE','PERTH','KIUNGA'))
  AND EXISTS   
  (SELECT 1
     FROM websys.customer_roles cr, websys.piction_roles pr2
    WHERE cr.role_id = pr2.ROLE_ID 
      AND pr2.role_name  = 'CONTAINER UNPACK'
      AND cr.aid = ca.aid ) 
  AND ca.date_expires > sysdate
  AND ca.username = v_username
  UNION ALL
  SELECT ca.username as code
       , 'N' description
       ,  ca.password_owner password 
       , 'USERS' lov_name
  FROM websys.customer_account ca
  INNER JOIN
  (SELECT cr.aid
     FROM websys.piction_roles pr, websys.customer_roles cr 
    WHERE pr.role_id in ( 17)
      AND pr.ROLE_ID = cr.role_id
      ) b  ON (ca.aid = b.aid and ca.date_expires > sysdate and ca.username = v_username);

  c1rec1 c1%rowtype;
  c2rec1 c2%rowtype;
  vtype  varchar2(100);
  v_username varchar2(100);
  v_password varchar2(100);
  v_pass varchar2(1);
  md	date;
  mdt	date;

 begin
 
    if x.exists(3) and x.exists(4) and x.exists(5) then
       vtype  := x(3);
       v_username := x(4);
       v_password := x(5);
       if UPPER(vtype) = 'USERS' then
          open c2(v_username); 
          fetch c2 into c2rec1;
          if c2%notfound then
             err( '[1022] Err in process_scan_metadata:' || ' Username ['||v_username||'] not found in GLMS', 404, TRUE);
             close c2;
             return;
          end if;
          close c2;
          
          if c2rec1.password = websys.glbx.encrypt( upper( v_password )) then
             v_pass := 'Y';
          else v_pass := 'N';
          end if;
          owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
          htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
          owa_util.http_header_close;
          htp.p( '<metadata_category>' );
          htp.p( '<category_name>' || xtra.xmlconv(vtype) || '</category_name>' );
          for c2rec in c2(v_username) loop
             htp.p( '<item>' );
             htp.p( '<username>' || xtra.xmlconv(v_username)|| '</username>' );
             htp.p( '<password_valid>' || xtra.xmlconv(v_pass)|| '</password_valid>' );      
             htp.p( '</item>');       
          end loop;
          htp.p( '</metadata_category>');
       end if;
       return;
    end if;
    
    if x.exists(3)
    then 
       vtype  := x(3);
       open c1(vtype); 
       fetch c1 into c1rec1;
       if c1%notfound then
             err( '[1022] Err in process_scan_metadata:' || ' LOV category : ['||vtype||'] not found in GLMS', 404, TRUE);
             close c1;
             return;
       end if;
       close c1;

 
       owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
       htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
       owa_util.http_header_close;
       htp.p( '<metadata_category>' );
       htp.p( '<category_name>' || xtra.xmlconv(vtype) || '</category_name>' );
       htp.p( '<items>' );
       for c1rec in c1(vtype) loop
           htp.p( '<item>' );
           htp.p( '<code>' || xtra.xmlconv(c1rec.code)|| '</code>' );
           htp.p( '<description>' || xtra.xmlconv(c1rec.description)|| '</description>' );    
           htp.p( '</item>');       
       end loop;
       htp.p( '</items>' );
       htp.p( '</metadata_category>');
       return;
    end if;
      
    owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
    htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
    owa_util.http_header_close;
    htp.p( '<metadata_categories>' );
    for c1rec in c1(vtype) loop
       if c1rec.lov_name <> nvl(c1rec.prev_lov_name, 9999999) then
          htp.p( '<category_name>' || xtra.xmlconv(c1rec.lov_name) || '</category_name>' );
       end if; 
    end loop;
    htp.p( '</metadata_categories>' );

 exception
  when others then
   err( '[1073] Err in process_scan_metadata:' || sqlerrm, 404, TRUE);
 end process_scan_metadata;

-- tracker app user login validation below
procedure process_user_metadata( x in owa.vc_arr, y in owa.vc_arr )
 as
 
   cursor c1 (vmetadata varchar2) is 
  select code, description, lov_name 
       , lag(lov_name) over (order by lov_name, code ) prev_lov_name
       , lead(lov_name) over (order by lov_name, code ) next_lov_name
  from (
  SELECT ca.username as code
       , CASE WHEN c.approval IS NULL THEN 'N' ELSE 'Y' END description
       , 'USERS' lov_name
  FROM websys.customer_account ca
  INNER JOIN
  (SELECT cr.aid
     FROM websys.piction_roles pr, websys.customer_roles cr 
    WHERE pr.role_id in (1,10,17,19,20,21,28,38)
      AND pr.ROLE_ID = cr.role_id
      ) b  ON (ca.aid = b.aid)
   INNER JOIN 
   (SELECT cr.aid,  'Y' approval
     from websys.customer_roles cr,  websys.piction_roles pr
    where pr.role_name  =  'TRACKER APP'
      and cr.role_id = pr.ROLE_ID 
      ) c  on (ca.aid = c.aid)
  where date_expires > sysdate
 ) tmp
  where (vmetadata is null or UPPER(tmp.lov_name ) like upper(vmetadata)||'%' )
  order by 3,2, 1;

  cursor c2 (v_username varchar2) is 
  SELECT ca.username as code
       , CASE WHEN c.approval IS NULL THEN 'N' ELSE 'Y' END description
       , ca.password_owner password 
       , 'USERS' lov_name
  FROM websys.customer_account ca
  INNER JOIN
  (SELECT cr.aid,role_name
     FROM websys.piction_roles pr, websys.customer_roles cr 
    WHERE pr.role_id in (1,10,17,19,20,21,28,38)
      AND pr.ROLE_ID = cr.role_id
      ) b  ON (ca.aid = b.aid)
   INNER JOIN 
   (SELECT cr.aid,  'Y' approval
     from websys.customer_roles cr,  websys.piction_roles pr
    where pr.role_name  =  'TRACKER APP'
      and cr.role_id = pr.ROLE_ID 
      ) c  on (ca.aid = c.aid)
  where date_expires > sysdate
  and UPPER(ca.username) = UPPER(v_username); 

  c1rec1 c1%rowtype;
  c2rec1 c2%rowtype;
  vtype  varchar2(100);
  v_username varchar2(100);
  v_password varchar2(100);
  v_pass varchar2(1);
  md	date;
  mdt	date;

 begin
 
    if x.exists(3) and x.exists(4) and x.exists(5) then
       vtype  := x(3);
       v_username := x(4);
       v_password := x(5);
       if UPPER(vtype) = 'USERS' then
          open c2(UPPER(v_username)); 
          fetch c2 into c2rec1;
          if c2%notfound then
             err( '[1022] Err in process_user_metadata:' || ' Username ['||v_username||'] not found in GLMS', 404, TRUE);
             close c2;
             return;
          end if;
          close c2;
          
          if c2rec1.password = websys.glbx.encrypt( upper( v_password )) then
             v_pass := 'Y';
          else v_pass := 'N';
          end if;
          owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
          htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
          owa_util.http_header_close;
          htp.p( '<metadata_category>' );
          htp.p( '<category_name>' || xtra.xmlconv(vtype) || '</category_name>' );
          for c2rec in c2(v_username) loop
             htp.p( '<item>' );
             htp.p( '<username>' || xtra.xmlconv(v_username)|| '</username>' );
             htp.p( '<password_valid>' || xtra.xmlconv(v_pass)|| '</password_valid>' );      
             htp.p( '</item>');       
          end loop;
          htp.p( '</metadata_category>');
       end if;
       return;
    end if;
    
    if x.exists(3)
    then 
       vtype  := x(3);
       open c1(vtype); 
       fetch c1 into c1rec1;
       if c1%notfound then
             err( '[1022] Err in process_user_metadata:' || ' LOV category : ['||vtype||'] not found in GLMS', 404, TRUE);
             close c1;
             return;
       end if;
       close c1;

       owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
       htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
       owa_util.http_header_close;
       htp.p( '<metadata_category>' );
       htp.p( '<category_name>' || xtra.xmlconv(vtype) || '</category_name>' );
       htp.p( '<items>' );
       for c1rec in c1(vtype) loop
           htp.p( '<item>' );
           htp.p( '<code>' || xtra.xmlconv(c1rec.code)|| '</code>' );
           htp.p( '<description>' || xtra.xmlconv(c1rec.description)|| '</description>' );    
           htp.p( '</item>');       
       end loop;
       htp.p( '</items>' );
       htp.p( '</metadata_category>');
       return;
    end if;
      
    owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
    htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
    owa_util.http_header_close;
    htp.p( '<metadata_categories>' );
    for c1rec in c1(vtype) loop
       if c1rec.lov_name <> nvl(c1rec.prev_lov_name, 9999999) then
          htp.p( '<category_name>' || xtra.xmlconv(c1rec.lov_name) || '</category_name>' );
       end if; 
    end loop;
    htp.p( '</metadata_categories>' );

 exception
  when others then
   err( '[1073] Err in process_user_metadata:' || sqlerrm, 404, TRUE);
 end process_user_metadata;

procedure process_track_entry( x in owa.vc_arr, y in owa.vc_arr )
 as
 
 v_select_clause varchar2(8000) := ('select /*+ ALL_ROWS */ '||
                                   ' distinct r.io, '||
                                         '  p.po, '||
                                         '  p.po_item_no,  '||
                                         '  p.inventoryno, '||
                                         '  p.supinv,      '||
                                         '  p.grn,         '||
                                         '  p.grn_item,    '||
                                         '  p.sap_delno,   '||
                                         '  p.sap_delno_item, '||
                                         '  p.sap_delno_qty||'' ''|| p.sap_delno_unit ||htf.nl|| ''Packaged In: ''||dr.qty||'' ''||dr.pktpe_packtype quantity, '||
                                         '  p.sap_delno_qty, '||
                                         '  p.sap_delno_unit, '||
                                         '  dr.qty, '||
                                         '  dr.pktpe_packtype, '||
                                         '  dr.logno, '||
                                         '  p.deliveryno, '||
                                         '  dr.itemno, '||
                                         '  dr.connote, '||
                                         '  dr.dispatch_date, '||
                                         '  r.currdate, '||
                                         '  dr.detaildesc, '||
                                         '  c1.customer supplier, '||
                                         '  decode(dr.sa,''S'',''Sea'',''A'',''Air'') mode_of_transport, '||
                                         '  decode(dr.sa,''S'',strang.f_getshipdetails(p.deliveryno,dr.itemno,''I''),''A'',strang.f_getAirdetails(p.deliveryno,dr.itemno,''I'')) vy, '||
                                         '  decode(dr.sa,''S'',stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,''I'',section=>''shipname''),''A'',stx1.f_getAirdetails_new(p.deliveryno,dr.itemno,''I'',section=>''Carrier'')) int_ship_carrier_name, '||
                                         '  decode(dr.sa,''S'',stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,''I'',section=>''voyage''),''A'',stx1.f_getairdetails_new(p.deliveryno,dr.itemno,''I'',section=>''flight'')) int_voy_flight_name, '||
                                         '  case when dr.sa = ''A'' then stx1.f_getairdetails_new(p.deliveryno,dr.itemno,''I'',section=>''depart'') else null end air_depart_location, '||
                                         '  case when dr.sa = ''A'' then stx1.f_getairdetails_new(p.deliveryno,dr.itemno,''I'',section=>''arrive'') else null end air_arrive_location, '||
                                         '  case when dr.sa = ''A'' then stx1.f_getairdetails_new(p.deliveryno,dr.itemno,''I'',section=>''dispatch_date'') else null end air_dispatch_date, '||
                                         '  case when dr.sa = ''S'' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,''I'',section=>''bol'') else null end intl_ship_bol, '||
                                         '  case when dr.sa = ''S'' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,''I'',section=>''line_no'') else null end intl_ship_line_no, '||
                                         '  case when dr.sa = ''S'' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,''I'',section=>''etd'') else null end intl_ship_etd, '||
                                         '  case when dr.sa = ''S'' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,''I'',section=>''eta'') else null end intl_ship_eta, '||   
                                         '  case when dr.sa = ''S'' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,''I'',section=>''depart'') else null end intl_ship_depart, '|| -- new
                                         '  case when dr.sa = ''S'' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,''I'',section=>''arrive'') else null end intl_ship_arrive, '|| -- new                    
                                         '  decode(dr.sa,''S'',strang.f_getshipdetails(p.deliveryno,dr.itemno,''L''),''A'',strang.f_getAirdetails(p.deliveryno,dr.itemno,''L'')) local_vy, '||
                                         '  decode(dr.sa,''S'',stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,''L'',section=>''shipname''),''A'',stx1.f_getairdetails_new(p.deliveryno,dr.itemno,''L'',section=>''Carrier'')) loc_ship_carrier_name, '||
                                         '  decode(dr.sa,''S'',stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,''L'',section=>''voyage''),''A'',stx1.f_getairdetails_new(p.deliveryno,dr.itemno,''L'',section=>''flight'')) loc_voy_flight_name, '||
                                         '  case when dr.sa = ''A'' then stx1.f_getairdetails_new(p.deliveryno,dr.itemno,''L'',section=>''depart'') else null end loc_air_depart_location, '||
                                         '  case when dr.sa = ''A'' then stx1.f_getairdetails_new(p.deliveryno,dr.itemno,''L'',section=>''arrive'') else null end loc_air_arrive_location, '||
                                         '  case when dr.sa = ''A'' then stx1.f_getairdetails_new(p.deliveryno,dr.itemno,''L'',section=>''dispatch_date'') else null end loc_air_dispatch_date, '||
                                         '  case when dr.sa = ''S'' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,''L'',section=>''local_bol'') else null end loc_ship_bol, '||
                                         '  case when dr.sa = ''S'' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,''L'',section=>''local_line_no'') else null end loc_ship_line_no, '||
                                         '  case when dr.sa = ''S'' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,''L'',section=>''etd'') else null end loc_ship_etd, '||
                                         '  case when dr.sa = ''S'' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,''L'',section=>''eta'') else null end loc_ship_eta,  '||
                                         '  case when dr.sa = ''S'' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,''L'',section=>''depart'') else null end loc_sea_depart, '|| -- new
                                         '  case when dr.sa = ''S'' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,''L'',section=>''arrive'') else null end loc_sea_arrive, '|| -- new     
                                         '  decode(dr.sa,''S'',stx1.f_getShipDates_new(p.deliveryno,dr.itemno,''I''),''A'',stx1.f_getAirDates_new(p.deliveryno,dr.itemno,''I'')) eta, '||
                                         '  decode(dr.sa,''S'',stx1.f_getShipDates_new(p.deliveryno,dr.itemno,''I'', section=>''ARRIVAL_DATE''),''A'',stx1.f_getAirDates_new(p.deliveryno,dr.itemno,''I'', section=>''DISPATCH_DATE'')) eta_date, '||
                                         '  decode(dr.sa,''S'',stx1.f_getShipDates_new(p.deliveryno,dr.itemno,''I'', section=>''DISCHARGE_PORT''),''A'',stx1.f_getAirDates_new(p.deliveryno,dr.itemno,''I'', section=>''ARRIVE'')) eta_port, '||
                                         '  decode(dr.sa,''S'',stx1.f_getShipDates_new(p.deliveryno,dr.itemno,''L''),''A'','''') leta, '||
                                         '  decode(dr.sa,''S'',stx1.f_getShipDates_new(p.deliveryno,dr.itemno,''L'',section=>''ARRIVAL_DATE''),''A'','''') leta_date, '|| 
                                         '  decode(dr.sa,''S'',stx1.f_getShipDates_new(p.deliveryno,dr.itemno,''L'',section=>''DISCHARGE_PORT''),''A'','''') leta_port, '|| 
                                         '  decode(dr.sa,''S'',stx1.f_getShipDates_new(p.deliveryno,dr.itemno,''C''),''A'',stx1.f_getAirDates_new(p.deliveryno,dr.itemno,''L'')) ceta, '||
                                         '  decode(dr.sa,''S'',stx1.f_getShipDates_new(p.deliveryno,dr.itemno,''C'',section=>''ARRIVAL_DATE''),''A'',stx1.f_getAirDates_new(p.deliveryno,dr.itemno,''L'',section=>''DISPATCH_DATE'')) ceta_date, '||
                                         '  decode(dr.sa,''S'',stx1.f_getShipDates_new(p.deliveryno,dr.itemno,''C'',section=>''DISCHARGE_PORT''),''A'',stx1.f_getAirDates_new(p.deliveryno,dr.itemno,''L'',section=>''ARRIVE'')) ceta_port, '||
                                         '  stx1.f_getShipDates_new(p.deliveryno,dr.itemno,''C'',section=>''CONVOY'') ceta_convoy, '|| 
                                         '  decode(dr.sa,''S'',stx1.f_getMvFields_new(p.deliveryno,dr.itemno,''CURRENT_LOCATION''),''A'',stx1.f_getAirDates_new(p.deliveryno,dr.itemno,''L1'')) current_location, '||
                                         '  strang.f_getMvFields(p.deliveryno,dr.itemno,''CARGO'') cargo, '||
                                         '  stx1.f_getMvFields_new(p.deliveryno,dr.itemno,''CARGO'',section=>''ALL'') all_movement_nos, '||  -- new
                                         '  stx1.f_getMvFields_new(p.deliveryno,dr.itemno,''CARGO'',section=>''MOVEMENT_NO'') movement_no, '||
                                         '  stx1.f_getMvFields_new(p.deliveryno,dr.itemno,''CARGO'',section=>''SEAL'') seal, '||
                                         '  stx1.f_getMvFields_new(p.deliveryno,dr.itemno,''CARGO'',section=>''MAWB_I'') mawb_i, '||
                                         '  stx1.f_getMvFields_new(p.deliveryno,dr.itemno,''CARGO'',section=>''HAWB_I'') hawb_i, '||
                                         '  stx1.f_getMvFields_new(p.deliveryno,dr.itemno,''CARGO'',section=>''MAWB_L'') mawb_l, '||
                                         '  stx1.f_getMvFields_new(p.deliveryno,dr.itemno,''CARGO'',section=>''HAWB_L'') hawb_l, '||
                                         '  stx1.f_getMvFields_new(p.deliveryno,dr.itemno,''PRIORITY'') priority, '||
                                         '  decode(dr.sa,''S'',strang.f_getMvFields(p.deliveryno,dr.itemno,''CONSIGNEE_DESTINATION''),''A'',stx1.f_getAirDates_new(p.deliveryno,dr.itemno,''L2'')) consignee_destination, '||
                                         '  stx1.f_getAirDates_new(p.deliveryno,dr.itemno,''L2'',section=>''DISPATCH_DATE'') air_consignment_date, '||  
                                         '  stx1.f_getAirDates_new(p.deliveryno,dr.itemno,''L2'',section=>''ARRIVE'') air_consignment_dest, '|| 
                                         '  decode(dr.sa,''S'',stx1.f_getMvFields_new(p.deliveryno,dr.itemno,''CONSIGNEE_DESTINATION'',section=>''CONSIGNEE'' ),''A'',null) consignee, '||
                                         '  decode(dr.sa,''S'',stx1.f_getMvFields_new(p.deliveryno,dr.itemno,''CONSIGNEE_DESTINATION'',section=>''CONSIGNEE_LOCATION'' ),''A'',null) consignee_location, '||
                                         '  decode(dr.sa,''S'',stx1.f_getMvFields_new(p.deliveryno,dr.itemno,''CONSIGNEE_DESTINATION'',section=>''CONSIGNEE_LOCATION_DESC'' ),''A'',null) consignee_location_desc, '||
                                         '  decode(dr.sa,''S'',stx1.f_getMvFields_new(p.deliveryno,dr.itemno,''CONSIGNEE_DESTINATION'',section=>''WAREHOUSE_LOCATION'' ),''A'',null) warehouse_location, '||
                                         '  decode(dr.sa,''S'',stx1.f_getMvFields_new(p.deliveryno,dr.itemno,''CONSIGNEE_DESTINATION'',section=>''WAREHOUSE_LOCATION_DESC'' ),''A'',null) warehouse_location_desc, '||   
                                         '  decode(dr.sa,''S'',null,''A'',stx1.f_getAirDates_new(p.deliveryno,dr.itemno,''L2'')) air_consignee_destination, '||
                                         '  strang.f_getMvFields(p.deliveryno,dr.itemno,''CUSTOMS'') customs, '||
                                         '  stx1.f_getMvFields_new(p.deliveryno,dr.itemno,''OWNER'') owner ');
  
 v_from_clause_21_31 varchar2(1000) := (' from strang.pos p, strang.detailrs dr, strang.customers c1, strang.receivals r ');
 
 v_from_clause_32 varchar2(1000) := ('from strang.pos p, strang.detailrs dr, strang.customers c1, strang.receivals r, strang.movements m ');
 
 -- v_from_clause_33 varchar2(1000) := ('from strang.pos p, strang.detailrs dr, strang.customers c1, strang.receivals r, strang.movements m, strang.convoy c ');
 
 v_from_empty_clause_31_33 varchar2(1000) := (' from strang.movements m, strang.ships_airway ss1, strang.ships_airway ss2, strang.convoy cn ');
 
 v_from_clause_33 varchar2(1000) := (' from strang.pos p, strang.detailrs dr, strang.customers c1, strang.receivals r, strang.movements m, strang.convoy c ');
 
 v_where_common_21_29 varchar2(1000) := 
 (' where p.deliveryno = dr.deliveryno and
    nvl(r.supplier_customer_id,0) = c1.customer_id and
    c1.customer_type = ''SUPPLIER'' and
    r.currdate >= sysdate-1000 and
    p.deliveryno = r.deliveryno and
    r.io = :v_io and ');
	
  v_where_common_30_31 varchar2(1000) := 
 (' where dr.movement_no is not null and
    p.deliveryno = dr.deliveryno and
    nvl(r.supplier_customer_id,0) = c1.customer_id and
    c1.customer_type = ''SUPPLIER'' and
    r.currdate >= sysdate-1000 and
    p.deliveryno = r.deliveryno and
    r.io = :v_io and ');	                                 

    v_where_common_32_33 varchar2(1000) := 
  (' where dr.movement_no = m.movement_no and
    nvl(dr.camov_seal,''|'') = nvl(m.seal,''|'') and 
    p.deliveryno = dr.deliveryno and
    nvl(r.supplier_customer_id,0) = c1.customer_id and
    c1.customer_type = ''SUPPLIER'' and
    r.currdate >= sysdate-1000 and
    p.deliveryno = r.deliveryno and
    r.io = :v_io and ');	  
    
--    v_where_empty_common_31 varchar2(1000) :=        
--     ('   where m.movement_no is not null and '||
--       '        m.io = ''O'' and '||
--       '        m.full_mt = ''EMPTY'' and '||
--       '        m.movement_type = ''CARGO'' and '||
--       '        ss1.ship_id = m.local_ship_id and '||
--       '        ss2.ship_id = m.ship_id and '||
--       '        cn.convoy_id (+) = m.convoy_id and ');	
    
--     v_where_empty_common_32_33 varchar2(1000) :=        
--     ('   where m.movement_no is not null and '||
--       '        m.io = ''O'' and '||
--       '        m.full_mt = ''EMPTY'' and '||
--       '        m.movement_type = ''CARGO'' and '||
--       '        ss1.ship_id = m.local_ship_id and '||
--       '        ss2.ship_id = m.ship_id and '||
--       '        cn.convoy_id  = m.convoy_id and ');	
  

         v_where_empty_common_31 varchar2(1000) :=        
      ('   where m.movement_no is not null and '||
       '        m.io = :v_io and '||
       '        m.full_mt = ''EMPTY'' and '||
       '        m.movement_type = ''CARGO'' and '||
       '        ss1.ship_id = m.local_ship_id and '||
       '        ss2.ship_id = m.ship_id and '||
       '        cn.convoy_id (+) = m.convoy_id and ');	
       
      v_where_empty_common_32_33 varchar2(1000) :=        
     ('   where m.movement_no is not null and '||
       '        m.io = :v_io and '||
       '        m.full_mt = ''EMPTY'' and '||
       '        m.movement_type = ''CARGO'' and '||
       '        ss1.ship_id = m.local_ship_id and '||
       '        ss2.ship_id = m.ship_id and '||
       '        cn.convoy_id  = m.convoy_id and ');	     
       
          
	
	v_empty_select_where_31_33 varchar2(8000) := 
	(' union all '||
     ' select distinct m.io, '||
                     ' null as po, '||
                     ' cast(null as number(5)) as po_item_no, '||
                     ' '''' as inventoryno, '||
                     ' '''' as supinv, '||
                     ' cast(null as number(10)) as grn, '||
                     ' cast(null as number(15)) as grn_item, '||
                     ' cast(null as number(8)) as sap_delno, '||
                     ' cast(null as number(15)) as sap_delno_item, '||
                     ' ''1 EMPTY Container'' quantity, '||
                     ' cast(null as number(15,3)) sap_delno_qty, '||
                     ' '''' sap_delno_unit, '||
                     ' cast(null as number(15)) qty, '||
                     ' '''' pktpe_packtype, '||
                     ' '''' as logno, '||
                     ' cast(null as number) deliveryno, '||
                     ' cast(null as number) itemno, '||
                     ' null as connote, '||
                     ' cast(null as timestamp(6)) as dispatch_date, '||
                     ' cast(null as date) as currdate, '||
                     ' null as detaildesc, '||
                     ' '''' as supplier, '||
                     ' ''Sea'' as mode_of_transport, '||
                     ' ss2.shipname ||'' ''|| ss2.voy || '' ''|| ''Bill ''||to_char(m.bol)|| '' ''||''M/Line ''||'' ''||''ETD: ''|| to_char(ss2.estdepart)||'' ''||''ETA: ''||to_char(ss2.estarrive) vy, '||
                     ' ss2.shipname as int_ship_carrier_name, '||
                     ' ss2.voy as int_voy_flight_name, '||
                     ' null as air_depart_location, '||
                     ' null as air_arrive_location, '||
                     ' null as air_dispatch_date, '||
                     ' to_char(m.bol) as intl_ship_bol, '||
                     ' null as intl_ship_line_no, '||
                     ' to_char(ss2.estdepart) as intl_ship_etd, '||
                     ' to_char(ss2.estarrive) intl_ship_eta, '||
                     ' to_char(strang.f_getlocdesc(ss2.portload)) as intl_ship_depart, '|| -- new
                     ' to_char(strang.f_getlocdesc(ss2.portdisc)) as intl_ship_arrive, '|| -- new
                     ' ss1.shipname ||'' ''|| ss1.voy || htf.nl || ''Bill ''||to_char(m.local_bol)||'' ''||''M/Line ''||'' ''||''ETD: ''|| to_char(ss1.estdepart)||htf.nl||''ETA: ''||to_char(ss1.estarrive) local_vy, '||
                     ' ss1.shipname as loc_ship_carrier_name, '||
                     ' ss2.voy as loc_voy_flight_name, '||
                     ' null as air_depart_location, '||
                     ' null as air_arrive_location, '||
                     ' null as air_dispatch_date, '||
                     ' to_char(m.local_bol) as loc_ship_bol, '||
                     ' null as loc_ship_line_no, '||
                     ' to_char(ss1.estdepart) as loc_ship_etd, '||
                     ' to_char(ss1.estarrive) loc_ship_eta, '||
                     ' to_char(strang.f_getlocdesc(ss1.portload)) as loc_ship_depart, '|| -- new
                     ' to_char(strang.f_getlocdesc(ss1.portdisc)) as loc_ship_arrive, '|| -- new
                     ' nvl(to_char(ss2.estarrive),'''')||htf.nl||nvl(strang.f_getlocdesc(ss2.portdisc),'' '') eta, '||
                     ' nvl(to_char(ss2.estarrive),'''') eta_date, '|| 
                     ' nvl(strang.f_getlocdesc(ss2.portdisc),'''') eta_port, '|| 
                     ' nvl(case when ss1.status <> ''INCOMPLETE'' '||
                     '          then nvl(to_char(ss1.estarrive),'' '')||htf.nl||nvl(strang.f_getlocdesc(ss1.portdisc),'' '') '||
                     '               else nvl(to_char(ss1.estarrive)|| htf.nl ||'' DRAFT ONLY - NOT CONFIRMED'','' '')||htf.nl||nvl(strang.f_getlocdesc(ss1.portdisc),'' '') '||
                     '       end,'' '') as leta, '||
                     
                     '  nvl(to_char(ss1.estarrive),'''') leta_date, '|| 
                     '  nvl(strang.f_getlocdesc(ss1.portdisc),'''') leta_port, '||                  
                     '  nvl(case when cn.status = ''PLANNING'' '||
                     '             then ''Convoy: ''||'' ''||cn.convoy_id||'' Scheduled ''||'' ''||nvl(to_char(cn.estdepart),'''')||'' ''||nvl(strang.f_getlocdesc(cn.portdisc),'' '') '||
                     '          when cn.status = ''FINAL'' '||
                     '             then ''Convoy: ''||'' ''||cn.convoy_id||'' Confirmed ''||'' ''||nvl(to_char(cn.estdepart),'''')||'' ''||nvl(strang.f_getlocdesc(cn.portdisc),'''') '||
                     '      end,'''') as ceta, '||   
                     '  nvl(to_char(cn.estdepart),'''') ceta_date, '|| 
                     '  nvl(strang.f_getlocdesc(cn.portdisc),'''') ceta_port, '|| 
                     '  nvl(to_char(cn.convoy_id),'''') ceta_convoy, '|| 
                     '  nvl(strang.f_getlocdesc(m.current_location),'''')  current_location, '||
                     '  ''Container ''||nvl(m.movement_no,'''') cargo, '||
                     '  m.movement_no all_movement_nos, '|| -- new
                     '  m.movement_no movement_no, '||
                     '  null seal, '||
                     '  null mawb_i, '||
                     '  null hawb_i, '||
                     '  null mawb_l, '||
                     '  null hawb_l, '||
                     '  m.urgency as priority, '|| 
                     '  nvl(to_char(m.consignee||'' ''||m.consignee_location||'' ''||strang.f_getlocdesc(m.consignee_location)||'' ''||m.warehouse_destination||'' ''||strang.f_getlocdesc(m.warehouse_destination) ),'''') consignee_destination, '||
                     '  '''' air_consignment_date, '||
                     '  '''' air_consignment_dest, '||
                     '  m.consignee consignee, '||
                     '  m.consignee_location consignee_location, '||
                     '  strang.f_getlocdesc(m.consignee_location) consignee_location_desc, '||
                     '  m.warehouse_destination warehouse_location, '||
                     '  strang.f_getlocdesc(m.warehouse_destination) warehouse_location_desc, '||
                     '  null air_consignee_destination, '||
                     '  nvl(to_char(m.customs_cleared_date),'''') customs, '||
                     '  to_char(m.owner) as owner ');
               
		                                 
	 v_PO_where_clause 	varchar2(1000) := (' trim(p.po) = :po_nmbr ');   
	 v_PO_itemno_where_clause varchar2(1000) := (' (trim(p.po) = :po_nmbr and p.po_item_no = :po_line) ');
	 v_GRN_and_item_where_clause varchar2(1000) := (' (:gr=p.grn and p.grn_item = :gritem) ');
	 v_GRN_where_clause varchar2(1000) := (' :gr=p.grn ');
	 v_SUPINV_where_clause varchar2(1000) := (' :supinv_val = p.supinv ');
	 v_inventory_where_clause varchar2(1000) := (' :invent = p.inventoryno ');
	 v_supname_where_clause varchar2(1000) := ('( upper(c1.customer) like upper( :sname ) || ''%'') ');
	 v_delno_where_clause varchar2(1000) := (' :dlr = dr.deliveryno ');
	 v_container_seal_where_clause varchar2(1000) := 
	  (' dr.movement_no is not null and
         ((:mvn = dr.movement_no) or (:mvn = dr.movement_no_2 and dr.sa = ''A'')) and
         nvl(:sl,''|'') = nvl(dr.camov_seal,''|'') ');
	 v_container_where_clause varchar2(1000) := 
	  (' dr.movement_no is not null and
       ((:mvn = dr.movement_no) or (:mvn = dr.movement_no_2 and dr.sa = ''A'')) ');
     v_empty_where_clause varchar2(1000) := 
	  (' (:mvn = m.movement_no ) ');
	 v_convoyId_where_clause varchar2(1000) := 
	  (' (:convoyid = m.convoy_id) ');
	 v_convoydate_where_clause varchar2(1000) := 
      (' c.convoy_id = m.convoy_id and
        websys.glbx.guess_date(:convoydate) = nvl(c.estdepart,c.estarrive) ');
	 
     v_convoydate_e_where_clause varchar2(1000) := 
      (' cn.convoy_id = m.convoy_id and
        websys.glbx.guess_date(:convoydate) = nvl(cn.estdepart,cn.estarrive) '); 

     v_orderBy_clause_c21_c30 varchar2(1000) := 
	  (' order by r.currdate desc, p.po, p.po_item_no, p.supinv,dr.logno,p.deliveryno');  
     v_orderBy_clause_c31_c33 varchar2(1000) := 
	  (' order by currdate desc, po, po_item_no, supinv,logno,deliveryno, local_vy, vy');  

  cursor c_po is
  select distinct po  --  42340
   from strang.pos p, strang.receivals r
  where r.deliveryno = p.deliveryno
    and nvl(r.currdate, trunc(sysdate))  > sysdate - 1000
   order by po desc;

  cursor c_invent is
  select distinct code --code  53,651
    from strang.lov l
   where lov_name = 'INVENT'
    and code like '10%'
     order by 1 desc;

 cursor c_movement is
  select distinct movement_no, movement_type --code  28K 
    from strang.movements m
     order by 1 desc;

 cursor c_delivery is
  select distinct deliveryno --code  55K
    from strang.receivals r
    where nvl(r.currdate, trunc(sysdate))  > sysdate - 900
     order by 1 desc;

 cursor c_supplier is
  select distinct customer supplier --code  55K
    from strang.customers c
    where customer_type = 'SUPPLIER'
 --   where nvl(r.currdate, trunc(sysdate))  > sysdate - 1000
     order by 1 asc;



  TYPE POCurTyp IS REF CURSOR;  -- define weak REF CURSOR type
  POCurTyp_cv   POCurTyp;  -- declare cursor variable
  POCurTyp_rv   stx1.trac_table%rowtype;
  vdirection   varchar2(1);
  vmovementno  varchar2(100);
  vseal        varchar2(100);
  vpo          varchar2(100);
  vinvent      varchar2(100); 
  vsupinv      varchar2(100); 
  vsupname     varchar2(100); 
  v_po_item    varchar2(100);
  vgrn         varchar2(100);
  vgrn_item    varchar2(100);
  vConvoyid    varchar2(100);
  vConvoyDate  varchar2(100);
  
  para2       varchar2(100); 
  vsmp        varchar2(100);
  vdel_smp    varchar2(100); --    integer;
  vdel        integer;
  vtot	      integer;
  vitemno     integer;
  vunitno     integer;
  vscan       integer;

 begin
    
    if x.exists(5)
    then 
--       vmov  := x(3);
--       vseal := x(4);
--       vdel_smp  := x(5);
       vdirection := upper(x(3));
       if vdirection not in ('I','O') then
          err( '[1022] Err in process_track_entry:' || 'Direction needs to be either "I" or "O"', 404, TRUE);
          return;
       end if;
      
       para2 := upper(x(4));
       
       if length(para2) = 0 then
          err( '[1022] Err in process_track_entry:' || 'Search parameter is missing', 404, TRUE);
          return;
       
       elsif para2 NOT IN ('DELIVERY', 'MOVEMENTNO','CONVOYID', 'CONVOYDATE', 'INVENTORY','PO', 'GRN','SUPINV','SUPNAME') then 
          err( '[1022] Err in process_track_entry:' || 'First search parameter - '||para2||' is wrong', 404, TRUE);
          return;       
       end if;
        
       owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
       htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
       owa_util.http_header_close;
          
         
       htp.p( '<po_items>' );
       BEGIN
            IF para2 = 'DELIVERY' THEN 
               vdel := x(5);
               OPEN POCurTyp_cv FOR v_select_clause||v_from_clause_21_31||v_where_common_21_29||v_delno_where_clause||v_orderBy_clause_c21_c30 USING vdirection, vdel;
            ELSIF para2 =  'PO' THEN
               vpo := x(5);
               IF x.exists(6) THEN 
                  v_po_item := upper(x(6));
                  OPEN POCurTyp_cv FOR v_select_clause||v_from_clause_21_31||v_where_common_21_29||v_PO_itemno_where_clause ||v_orderBy_clause_c21_c30 USING vdirection, vpo, v_po_item;
               ELSE 
                  OPEN POCurTyp_cv FOR v_select_clause||v_from_clause_21_31||v_where_common_21_29||v_PO_where_clause||v_orderBy_clause_c21_c30 USING vdirection, vpo;
               END IF;
            ELSIF para2 =  'GRN' THEN
               vgrn := x(5);
               IF x.exists(6) THEN 
                  vgrn_item := upper(x(6));
                  OPEN POCurTyp_cv FOR v_select_clause||v_from_clause_21_31||v_where_common_21_29||v_GRN_and_item_where_clause||v_orderBy_clause_c21_c30 USING vdirection, vgrn, vgrn_item;
               ELSE 
                  OPEN POCurTyp_cv FOR v_select_clause||v_from_clause_21_31||v_where_common_21_29||v_GRN_where_clause||v_orderBy_clause_c21_c30 USING vdirection, vgrn;
               END IF;
            ELSIF para2 =  'MOVEMENTNO' THEN
               vMovementno := x(5);
               IF x.exists(6) THEN 
                  vseal := upper(x(6));
                  OPEN POCurTyp_cv FOR v_select_clause||v_from_clause_21_31|| v_where_common_30_31 ||v_container_seal_where_clause||v_orderBy_clause_c21_c30 USING vdirection, vMovementno, vMovementno, vseal;
               ELSE 
                  OPEN POCurTyp_cv FOR v_select_clause||v_from_clause_21_31|| v_where_common_30_31||v_container_where_clause||
                                       v_empty_select_where_31_33||v_from_empty_clause_31_33||v_where_empty_common_31|| v_empty_where_clause||v_orderBy_clause_c31_c33 
                                   USING vdirection, vMovementno, vMovementno, vMovementno, vdirection;
               END IF;
            ELSIF para2 =  'CONVOYID' THEN
               vConvoyid:= x(5);  
               OPEN POCurTyp_cv FOR v_select_clause||v_from_clause_32||v_where_common_32_33|| v_convoyId_where_clause||
                                       v_empty_select_where_31_33||v_from_empty_clause_31_33||v_where_empty_common_32_33|| v_convoyId_where_clause||v_orderBy_clause_c31_c33 
                                   USING vdirection, vConvoyid, vdirection, vConvoyid; 
            ELSIF para2 =  'CONVOYDATE' THEN
               vConvoyDate := x(5);  
               OPEN POCurTyp_cv FOR v_select_clause||v_from_clause_33||v_where_common_32_33||v_convoydate_where_clause||
                                       v_empty_select_where_31_33||v_from_empty_clause_31_33||v_where_empty_common_32_33|| v_convoydate_e_where_clause||v_orderBy_clause_c31_c33 
                                   USING vdirection, vConvoyDate, vdirection, vConvoyDate;    
               
               
            ELSIF para2 =  'INVENTORY' THEN
               vinvent := x(5);
               OPEN POCurTyp_cv FOR v_select_clause||v_from_clause_21_31||v_where_common_21_29||v_inventory_where_clause||v_orderBy_clause_c21_c30 USING vdirection, vinvent;
            ELSIF para2 = 'SUPINV' THEN
               vsupinv := x(5);
               OPEN POCurTyp_cv FOR v_select_clause||v_from_clause_21_31||v_where_common_21_29||v_SUPINV_where_clause||v_orderBy_clause_c21_c30 USING vdirection, vsupinv;
            ELSIF para2 = 'SUPNAME' THEN
               vsupname := x(5);
               OPEN POCurTyp_cv FOR v_select_clause||v_from_clause_21_31||v_where_common_21_29||v_supname_where_clause||v_orderBy_clause_c21_c30 USING vdirection, vsupname;
            END IF; 
               LOOP
               FETCH POCurTyp_cv INTO POCurTyp_rv;
               EXIT WHEN POCurTyp_cv%notfound;
               htp.p( '<po_item>' );
               htp.p( '<direction>' || xtra.xmlconv(POCurTyp_rv.io) || '</direction>' );
               htp.p( '<a_po>' || xtra.xmlconv(POCurTyp_rv.po) || '</a_po>' );
               htp.p( '<a_po_itemno>' || xtra.xmlconv(POCurTyp_rv.po_item_no) || '</a_po_itemno>' );
           --    htp.p( '<a_supplier>' || xtra.xmlconv(POCurTyp_rv.supplier) || '</a_supplier>' );   -- amended by DB on 15/1/2023
               htp.p( '<a_supplier>' || POCurTyp_rv.supplier || '</a_supplier>' );
               htp.p( '<b_matno>' || xtra.xmlconv(POCurTyp_rv.inventoryno) || '</b_matno>' );
            --    htp.p( '<b_matdesc>' || xtra.xmlconv(f_getMaterial(POCurTyp_rv.inventoryno,true)) || '</b_matdesc>' ); -- amended by DB on 15/1/2023
               htp.p( '<b_matdesc>' || f_getMaterial(POCurTyp_rv.inventoryno,true) || '</b_matdesc>' ); 
               htp.p( '<c_grn>' || xtra.xmlconv(POCurTyp_rv.grn) || '</c_grn>' );
               htp.p( '<c_grn_item>' || xtra.xmlconv(POCurTyp_rv.grn_item) || '</c_grn_item>' );
         --      htp.p( '<c_qty_unit>' || xtra.xmlconv(POCurTyp_rv.quantity) || '</c_qty_unit>' );
               htp.p( '<c_sap_delno_qty>' || xtra.xmlconv(POCurTyp_rv.sap_delno_qty) || '</c_sap_delno_qty>' );
               htp.p( '<c_sap_delno_unit>' || xtra.xmlconv(POCurTyp_rv.sap_delno_unit) || '</c_sap_delno_unit>' );
               htp.p( '<c_dr_qty>' || xtra.xmlconv(POCurTyp_rv.qty) || '</c_dr_qty>' );
               htp.p( '<c_dr_pktpe_packtype>' || xtra.xmlconv(POCurTyp_rv.pktpe_packtype) || '</c_dr_pktpe_packtype>' );
             
               htp.p( '<supinv>' || xtra.xmlconv(POCurTyp_rv.supinv) || '</supinv>' );
               htp.p( '<e_log>' || xtra.xmlconv(POCurTyp_rv.logno) || '</e_log>' );
               htp.p( '<e_delno>' || xtra.xmlconv(POCurTyp_rv.deliveryno) || '</e_delno>' );
               htp.p( '<e_delnoItemno>' || xtra.xmlconv(POCurTyp_rv.itemno) || '</e_delnoItemno>' ); 
               htp.p( '<e_currdate>' || xtra.xmlconv(to_char(POCurTyp_rv.currdate,websys.LNGS.STR_DATE_02)) || '</e_currdate>' ); 
               htp.p( '<e_connote>' || xtra.xmlconv(POCurTyp_rv.connote) || '</e_connote>' ); 
               htp.p( '<e_despatchdate>' || xtra.xmlconv(to_char(POCurTyp_rv.dispatch_date,websys.LNGS.STR_DATE_02)) || '</e_despatchdate>' ); 
               htp.p( '<e_mode_of_transport>' || xtra.xmlconv(POCurTyp_rv.mode_of_transport) || '</e_mode_of_transport>' );    
              -- htp.p( '<intShipVoy>' || xtra.xmlconv(POCurTyp_rv.vy) || '</intShipVoy>' );
               htp.p( '<f_ship_carrier_name>' || POCurTyp_rv.int_ship_carrier_name || '</f_ship_carrier_name>' );   
               htp.p( '<f_voy_flight_name>' || POCurTyp_rv.int_voy_flight_name || '</f_voy_flight_name>' );   
--               htp.p( '<f_ship_carrier_name>' || xtra.xmlconv(POCurTyp_rv.int_ship_carrier_name) || '</f_ship_carrier_name>' );   
--               htp.p( '<f_voy_flight_name>' || xtra.xmlconv(POCurTyp_rv.int_voy_flight_name) || '</f_voy_flight_name>' );     
               htp.p( '<f_air_depart_location>' || xtra.xmlconv(POCurTyp_rv.air_depart_location) || '</f_air_depart_location>' ); 
               htp.p( '<f_air_arrive_location>' || xtra.xmlconv(POCurTyp_rv.air_arrive_location) || '</f_air_arrive_location>' );    
               htp.p( '<f_air_dispatch_date>' || xtra.xmlconv(POCurTyp_rv.air_dispatch_date) || '</f_air_dispatch_date>' );
               htp.p( '<f_intl_ship_bol>' || xtra.xmlconv(POCurTyp_rv.intl_ship_bol) || '</f_intl_ship_bol>' ); 
               htp.p( '<f_intl_ship_line_no>' || xtra.xmlconv(POCurTyp_rv.intl_ship_line_no) || '</f_intl_ship_line_no>' );   
               IF  UPPER(POCurTyp_rv.mode_of_transport) = 'AIR' and POCurTyp_rv.air_dispatch_date is not null  then      
                  htp.p( '<f_intl_ship_etd>' || xtra.xmlconv(POCurTyp_rv.air_dispatch_date) || '</f_intl_ship_etd>' );
                  htp.p( '<f_intl_ship_eta>' || xtra.xmlconv(POCurTyp_rv.air_dispatch_date) || '</f_intl_ship_eta>' );    
               ELSE
                  htp.p( '<f_intl_ship_etd>' || xtra.xmlconv(POCurTyp_rv.intl_ship_etd) || '</f_intl_ship_etd>' ); 
                  htp.p( '<f_intl_ship_eta>' || xtra.xmlconv(POCurTyp_rv.intl_ship_eta) || '</f_intl_ship_eta>' );   
               END IF;
            --   htp.p( '<f_intl_ship_eta>' || xtra.xmlconv(POCurTyp_rv.intl_ship_eta) || '</f_intl_ship_eta>' );    
               htp.p( '<f_intl_ship_depart>' || xtra.xmlconv(POCurTyp_rv.intl_ship_depart) || '</f_intl_ship_depart>' );   
               htp.p( '<f_intl_ship_arrive>' || xtra.xmlconv(POCurTyp_rv.intl_ship_arrive) || '</f_intl_ship_arrive>' );   
              --  htp.p( '<localShipVoy>' || xtra.xmlconv(POCurTyp_rv.local_vy) || '</localShipVoy>' );        
               htp.p( '<f_loc_ship_carrier_name>' || POCurTyp_rv.loc_ship_carrier_name || '</f_loc_ship_carrier_name>' ); 
               htp.p( '<f_loc_voy_flight_name>' || POCurTyp_rv.loc_voy_flight_name || '</f_loc_voy_flight_name>' ); 
--               htp.p( '<f_loc_ship_carrier_name>' || xtra.xmlconv(POCurTyp_rv.loc_ship_carrier_name) || '</f_loc_ship_carrier_name>' ); 
--               htp.p( '<f_loc_voy_flight_name>' || xtra.xmlconv(POCurTyp_rv.loc_voy_flight_name) || '</f_loc_voy_flight_name>' ); 
               htp.p( '<f_loc_air_depart_location>' || xtra.xmlconv(POCurTyp_rv.loc_air_depart_location) || '</f_loc_air_depart_location>' ); 
               htp.p( '<f_loc_air_arrive_location>' || xtra.xmlconv(POCurTyp_rv.loc_air_arrive_location) || '</f_loc_air_arrive_location>' ); 
               htp.p( '<f_loc_air_dispatch_date>' || xtra.xmlconv(POCurTyp_rv.loc_air_dispatch_date) || '</f_loc_air_dispatch_date>' );
               htp.p( '<f_loc_ship_bol>' || xtra.xmlconv(POCurTyp_rv.loc_ship_bol) || '</f_loc_ship_bol>' );           
               htp.p( '<f_loc_ship_line_no>' || xtra.xmlconv(POCurTyp_rv.loc_ship_line_no) || '</f_loc_ship_line_no>' ); 
               
               IF  UPPER(POCurTyp_rv.mode_of_transport) = 'AIR' and POCurTyp_rv.loc_air_dispatch_date is not null  then     
                  htp.p( '<f_loc_ship_etd>' || xtra.xmlconv(POCurTyp_rv.loc_air_dispatch_date) || '</f_loc_ship_etd>' );
                  htp.p( '<f_loc_ship_eta>' || xtra.xmlconv(POCurTyp_rv.loc_air_dispatch_date) || '</f_loc_ship_eta>' );
               ELSE
                  htp.p( '<f_loc_ship_etd>' || xtra.xmlconv(POCurTyp_rv.loc_ship_etd) || '</f_loc_ship_etd>' );
                  htp.p( '<f_loc_ship_eta>' || xtra.xmlconv(POCurTyp_rv.loc_ship_eta) || '</f_loc_ship_eta>' );
               END IF;
               htp.p( '<f_loc_ship_depart>' || xtra.xmlconv(POCurTyp_rv.loc_ship_depart) || '</f_loc_ship_depart>' );
               htp.p( '<f_loc_ship_arrive>' || xtra.xmlconv(POCurTyp_rv.loc_ship_arrive) || '</f_loc_ship_arrive>' );           
        --       htp.p( '<h_cargo>' || xtra.xmlconv(POCurTyp_rv.cargo) || '</h_cargo>' );
               htp.p( '<currentlocation>' || xtra.xmlconv(POCurTyp_rv.current_location) || '</currentlocation>' );
               if vMovementno is not null and vMovementno = POCurTyp_rv.mawb_l and UPPER(POCurTyp_rv.mode_of_transport) = 'AIR'  then 
                  htp.p( '<h_all_movement_nos>' || xtra.xmlconv(vMovementno) || '</h_all_movement_nos>' );
               else
                  htp.p( '<h_all_movement_nos>' || xtra.xmlconv(POCurTyp_rv.all_movement_nos) || '</h_all_movement_nos>' );
               end if;
               htp.p( '<h_movement_no>' || xtra.xmlconv(POCurTyp_rv.movement_no) || '</h_movement_no>' );
               htp.p( '<h_seal>' || xtra.xmlconv(POCurTyp_rv.seal) || '</h_seal>' );
               htp.p( '<h_intl_mawb>' || xtra.xmlconv(POCurTyp_rv.mawb_i) || '</h_intl_mawb>' );
               htp.p( '<h_intl_hawb>' || xtra.xmlconv(POCurTyp_rv.hawb_i) || '</h_intl_hawb>' );
               htp.p( '<h_local_mawb>' || xtra.xmlconv(POCurTyp_rv.mawb_l) || '</h_local_mawb>' );
               htp.p( '<h_local_hawb>' || xtra.xmlconv(POCurTyp_rv.hawb_l) || '</h_local_hawb>' );
               htp.p( '<h_owner>' || xtra.xmlconv(POCurTyp_rv.owner) || '</h_owner>' );
               htp.p( '<priority>' || xtra.xmlconv(POCurTyp_rv.priority) || '</priority>' );
               htp.p( '<eta_port>' || xtra.xmlconv(POCurTyp_rv.eta) || '</eta_port>' );
               htp.p( '<eta_destination>' || xtra.xmlconv(POCurTyp_rv.eta_port) || '</eta_destination>' );
               htp.p( '<eta_date>' || xtra.xmlconv(POCurTyp_rv.eta_date) || '</eta_date>' );
               
               htp.p( '<customClearedDt>' || xtra.xmlconv(POCurTyp_rv.customs) || '</customClearedDt>' );
               htp.p( '<leta_port>' || xtra.xmlconv(POCurTyp_rv.leta) || '</leta_port>' );
               htp.p( '<leta_destination>' || xtra.xmlconv(POCurTyp_rv.leta_port) || '</leta_destination>' );
               htp.p( '<leta_date>' || xtra.xmlconv(POCurTyp_rv.leta_date) || '</leta_date>' );
               
               htp.p( '<ceta_port>' || xtra.xmlconv(POCurTyp_rv.ceta) || '</ceta_port>' );
               htp.p( '<ceta_destination>' || xtra.xmlconv(POCurTyp_rv.ceta_port) || '</ceta_destination>' );
               htp.p( '<ceta_date>' || xtra.xmlconv(POCurTyp_rv.ceta_date) || '</ceta_date>' );
               htp.p( '<ceta_convoy>' || xtra.xmlconv(POCurTyp_rv.ceta_convoy) || '</ceta_convoy>' );
               
           --    htp.p( '<destination>' || xtra.xmlconv(POCurTyp_rv.consignee_destination) || '</destination>' );
               htp.p( '<j_consignee>' || xtra.xmlconv(POCurTyp_rv.consignee) || '</j_consignee>' );
               
           --    htp.p( '<j_air_consignment_date>' || xtra.xmlconv(POCurTyp_rv.air_consignment_date) || '</j_air_consignment_date>' );
               htp.p( '<j_air_warehouse_location>' || xtra.xmlconv(POCurTyp_rv.air_consignment_dest) || '</j_air_warehouse_location>' );
               
               htp.p( '<j_consignee_location>' || xtra.xmlconv(POCurTyp_rv.consignee_location) || '</j_consignee_location>' );
               htp.p( '<j_consignee_location_desc>' || xtra.xmlconv(POCurTyp_rv.consignee_location_desc) || '</j_consignee_location_desc>' );
               htp.p( '<j_warehouse_location>' || xtra.xmlconv(POCurTyp_rv.warehouse_location) || '</j_warehouse_location>' );
               htp.p( '<j_warehouse_location_desc>' || xtra.xmlconv(POCurTyp_rv.warehouse_location_desc) || '</j_warehouse_location_desc>' );
               htp.p( '<j_destination_location_desc>' || xtra.xmlconv(strang.f_getlocdesc_whouse(POCurTyp_rv.warehouse_location)) || '</j_destination_location_desc>' );

               htp.p( '<j_air_consignee_destination>' || xtra.xmlconv(POCurTyp_rv.air_consignee_destination) || '</j_air_consignee_destination>' );
               htp.p( '</po_item>' );
               
               END LOOP;
             
               CLOSE POCurTyp_cv;
          END;
          htp.p( '</po_items>' );
      ELSIF x.exists(4) THEN
         vdirection := upper(x(3));
         if vdirection not in ('I','O') then
            err( '[1022] Err in process_track_entry:' || 'Direction needs to be either "I" or "O"', 404, TRUE);
            return;
         end if;
      
         para2 := upper(x(4));
       
         IF length(para2) = 0 THEN
            err( '[1022] Err in process_track_entry:' || 'Search parameter is missing', 404, TRUE);
            RETURN;
         ELSIF para2 NOT IN ('DELIVERY','CONVOYID', 'CONVOYDATE', 'INVENTORY','PO', 'GRN','SUPINV','SUPNAME', 'MOVEMENTNO') then 
            err( '[1022] Err in process_track_entry:' || 'First search parameter is wrong', 404, TRUE);
            return;       
         END IF;
        
         owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
         htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
         owa_util.http_header_close;
          
         if para2 = 'PO' THEN
            htp.p( '<po_nos>' );
            for c_po_rec in c_po loop
                htp.p( '<po_number>' || xtra.xmlconv(c_po_rec.po) ||'</po_number>');
            end loop;
            htp.p( '</po_nos>' );
         elsif para2 = 'INVENTORY' then
            htp.p( '<all_inventory>' );
            for c_invent_rec in c_invent loop
                htp.p( '<inventory_no>' || xtra.xmlconv(c_invent_rec.code) ||'</inventory_no>');
            end loop;
            htp.p( '</all_inventory>' );
         elsif para2 = 'MOVEMENTNO' then
            htp.p( '<all_movement>' );
            for c_movement_rec in c_movement loop
                htp.p( '<movement>' );
                htp.p( '<movement_no>' || xtra.xmlconv(c_movement_rec.movement_no) ||'</movement_no>');
                htp.p( '<movement_type>' || xtra.xmlconv(c_movement_rec.movement_type) ||'</movement_type>');
                htp.p( '</movement>' );
               -- null;
            end loop;
            htp.p( '</all_movement>' );
         elsif para2 = 'SUPNAME' then
            htp.p( '<suppliers>' );
            for c_supplier_rec in c_supplier loop
              htp.p( '<supplier>' );
                htp.p( '<supplier_name>' || xtra.xmlconv(c_supplier_rec.supplier) ||'</supplier_name>');
              htp.p( '</supplier>' );
               -- null;
            end loop;
            htp.p( '</suppliers>' );
        elsif para2 = 'DELIVERY' then
            htp.p( '<all_deliveries>' );
            for c_delivery_rec in c_delivery loop
          --    htp.p( '<delivery>' );
             --    htp.p( '<po_number>'||c_po_rec.po||'</po_number>' );
                htp.p( '<delivery_no>' || xtra.xmlconv(c_delivery_rec.deliveryno) ||'</delivery_no>');
        --      htp.p( '</delivery>' );
               -- null;
            end loop;
            htp.p( '</all_deliveries>' ); 
         end if;

      END IF;
 exception
  when others then
   err( '[1065] Err in process_track_entry:' || sqlerrm, 404, TRUE);
 end process_track_entry;

procedure process_cargo( x in owa.vc_arr, y in owa.vc_arr )
 as
 
  --cursor c1(vmov varchar2) is select m.* from strang.movements m where movement_no = vmov order by deliverno, itemno;
  cursor c1( vmov varchar2, vseal varchar2) is
  select ss1.shipname as intl_ship_name, ss1.voy as intl_voy, ss1.estdepart as intl_estdepart, ss1.estarrive as intl_estarrive
        , strang.f_getlovColumn('LOCATIONS','DESCRIPTION',ss1.portload) as intl_portload
        , strang.f_getlovcolumn('LOCATIONS','DESCRIPTION',ss1.portdisc) as intl_portdisc, ss1.ship_airway as intl_ship_airway
        , ss1.ship_id as intl_ship_id, ss1.io as intl_io, ss1.li as intl_li
        , ss2.shipname as local_ship_name, ss2.voy as local_voy, ss2.estdepart as local_estdepart, ss2.estarrive as local_estarrive
        , strang.f_getlovColumn('LOCATIONS','DESCRIPTION',ss2.portload) as local_portload
        , strang.f_getlovcolumn('LOCATIONS','DESCRIPTION',ss2.portdisc) as local_portdisc, ss2.ship_airway as local_ship_airway
        , ss2.ship_id as local_ship_id2, ss2.io as local_io, ss2.li as local_li
        , strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION', m.complete) as completion_status
        , m.movement_type as movement_type2
        , strang.f_getlovcolumn('LOCATIONS','DESCRIPTION',m.departure) as departure2
        , strang.f_getlovcolumn('LOCATIONS','DESCRIPTION',m.arrival)  as arrival2
        , strang.f_getlovColumn('UNCTNTAB','DESCRIPTION',m.iso_container_type) as iso_container_type2
        , strang.f_getlovcolumn('LOCATIONS','DESCRIPTION',m.current_location) as  current_location2
        , strang.f_getlovcolumn('LOCATIONS','DESCRIPTION',m.consignee_location) as consignee_location2
        , (select count(*) from strang.detailrs_item di where di.movement_no = m.movement_no and nvl(di.seal,'|') = nvl(m.seal,'|')) tot
        , (select nvl(sum(di.weight),0) from strang.detailrs_item di where di.movement_no = m.movement_no and nvl(di.seal,'|') = nvl(m.seal,'|')) +
          nvl((select sum(NVL(sm.tare,0)) from strang.smp sm where sm.movement_no =  m.movement_no and nvl(sm.seal,'|') = nvl(m.seal,'|')),0) cum_weight
        , m.*
    from strang.movements m
  left outer join strang.ships_airway ss1 on ( ss1.ship_id = m.ship_id and ss1.li = 'I' and ss1.ship_id <> 1)
  left outer join strang.ships_airway ss2 on ( ss2.ship_id = m.local_ship_id and ss2.li = 'L' and ss2.ship_id <> 2)
   where m.movement_type = 'CARGO'
     and m.movement_no = vmov
     and m.io = 'I'
     and strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) not in ( 'ARCHIVED')
     and (vseal is null or UPPER(m.seal) like upper(vseal)||'%' )
     and (exists
            (select 'x' 
               from strang.detailrs_item di, strang.receivals r 
              where r.deliveryno = di.deliveryno
                and m.movement_no = di.movement_no
                and nvl(m.seal,'|') = nvl(di.seal,'|')
                and nvl(r.currdate, trunc(sysdate))  > to_date('1 Jan 2018','DD MON YYYY')
             )
          or not exists 
            (select 'x' 
                from strang.detailrs dr, strang.receivals r 
              where r.deliveryno = dr.deliveryno
                and m.movement_no = dr.movement_no
                and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
             )
           )
     order by movement_no, greatest( NVL(ss2.ship_id,ss1.ship_id),NVL(ss1.ship_id,ss2.ship_id)) desc;  
  
 cursor c1t(vmov varchar2, vseal varchar2) is 
   select count('x') tot   
    from (
  select ss1.ship_id, ss2.ship_id, m.*
    from strang.movements m
  left outer join strang.ships_airway ss1 on ( ss1.ship_id = m.ship_id and ss1.li = 'I' and ss1.ship_id <> 1)
  left outer join strang.ships_airway ss2 on ( ss2.ship_id = m.local_ship_id and ss2.li = 'L' and ss2.ship_id <> 2)
  where m.movement_type IN ( 'CARGO')
    and m.movement_no = vmov
    and m.io = 'I'
    and strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) not in ('ARCHIVED')
    and (vseal is null or (vseal is not null and  UPPER(m.seal) like upper(vseal)||'%' ))
    and (exists
            (select 'x' 
               from strang.detailrs_item di, strang.receivals r 
              where r.deliveryno = di.deliveryno
                and m.movement_no = di.movement_no
                and nvl(m.seal,'|') = nvl(di.seal,'|')
                and nvl(r.currdate, trunc(sysdate))  > to_date('1 Jan 2018','DD MON YYYY')
             )
          or not exists 
            (select 'x' 
                from strang.detailrs dr, strang.receivals r 
              where r.deliveryno = dr.deliveryno
                and m.movement_no = dr.movement_no
                and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
             )
           ));

  cursor c3 is
  select m.*, strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) as completion_status, count(*) over () cnt
    from strang.movements m
  left outer join strang.ships_airway ss1 on ( ss1.ship_id = m.ship_id and ss1.li = 'I' and ss1.ship_id <> 1)
  left outer join strang.ships_airway ss2 on ( ss2.ship_id = m.local_ship_id and ss2.li = 'L' and ss2.ship_id <> 2)
   where m.movement_type IN ( 'CARGO')
    and strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) not in ( 'ARCHIVED', 'READ-ONLY', 'SHIPPED')
          and ( exists
            (select 'x' 
               from strang.detailrs_item di, strang.receivals r 
              where r.deliveryno = di.deliveryno
                and r.deliveryno < 2000000
                and m.movement_no = di.movement_no
                and nvl(m.seal,'|') = nvl(di.seal,'|')
                and nvl(r.currdate, trunc(sysdate))  > to_date('1 Jan 2018','DD MON YYYY')))
     order by m.dispatch_date desc, greatest( NVL(ss2.ship_id,ss1.ship_id),NVL(ss1.ship_id,ss2.ship_id)) desc nulls last, m.movement_no ; 
      
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --grant execute on STRANG.f_get_party_name to stx1
 
 cursor c4a( vmov varchar2, vseal varchar2, vsmpno varchar2, vdeliveryno varchar2) is
  select m.movement_no, m.seal, m.full_mt, m.io, count(*) over () cnt, dr.deliveryno, dr.itemno
        , sm.urgency, STRANG.f_get_party_name(sm.client_id) smp_client
        , strang.f_getlovcolumn('SMP_PACKTYPES','DESCRIPTION',sm.smp_type) smp_type
        , strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',sm.complete) complete
        , sm.hazard_class
        , to_char(sm.containerised_date,'DD-Mon-RR HH24:MI:SS')  smp_scanned_date
        , di.smp_no, di.order_by unit_no, strang.f_getlovColumn('PACKTYPES','DESCRIPTION', di.PKTPE_PACKTYPE) as unit_pktpe_packtype
        , di.lngth, di.width, di.height, di.weight, ((di.width/100)*(di.height/100)*(di.lngth/100)) as unit_volume
        , to_char(di.packed_date,'DD-Mon-RR HH24:MI:SS') unit_packed_date
        , row_number() over (partition by m.movement_no, m.seal order by di.packed_date desc) unit_packed_date_rnk
        , dr.detaildesc
        , case when dr.sa = 'S' then 'SEA' when dr.sa = 'A' then 'AIR' else null end sa
        , strang.f_getlovColumn('PACKTYPES','DESCRIPTION', dr.pktpe_packtype) as pktpe_packtype
        , dr.partvolume, dr.partweight, dr.qty, dr.hazard
        , (select max(di1.order_by) from strang.detailrs_item di1 where di1.deliveryno = dr.deliveryno and di1.item_no = dr.itemno) max_unit
        , count(*) over ( partition by m.movement_no, m.seal, di.deliveryno, di.item_no) cum_unit
        , di.order_by ||' of '|| (select max(di1.order_by) from strang.detailrs_item di1 where di1.deliveryno = dr.deliveryno and di1.item_no = dr.itemno) unit_part
        , lag(di.item_no) over (partition by m.movement_no, m.seal, di.deliveryno  order by di.item_no, di.order_by) prev_itemno
        , lead(di.item_no) over (partition by m.movement_no, m.seal, di.deliveryno order by di.item_no, di.order_by) next_itemno
        , lag(dr.deliveryno) over (partition by m.movement_no, m.seal order by di.deliveryno) prev_deliveryno
        , lead(dr.deliveryno) over (partition by m.movement_no, m.seal order by di.deliveryno) next_deliveryno
        , lag(di.smp_no) over (partition by di.movement_no, di.seal order by di.smp_no, di.deliveryno, di.item_no, di.order_by nulls first) prev_smp_no
        , lead(di.smp_no) over (partition by di.movement_no, di.seal order by di.smp_no, di.deliveryno, di.item_no, di.order_by nulls first) next_smp_no
    from strang.movements m 
     inner join strang.detailrs_item di on (m.movement_no = di.movement_no and nvl(m.seal, '|') = nvl(di.seal,'|'))
     inner join strang.receivals r on (di.deliveryno = r.deliveryno)
     inner join strang.detailrs dr on (di.deliveryno = dr.deliveryno and di.item_no = dr.itemno)
     left join strang.smp sm on (di.smp_no = sm.smp_no and sm.movement_no = di.movement_no and nvl(sm.seal,'|') = nvl(di.seal,'|'))
   where m.movement_type IN ( 'CARGO')
     and m.io = 'I'
     and m.movement_no = vmov
     and (vseal is null or UPPER(m.seal) = UPPER(vseal))
  --  and ((dr.deliveryno = vdeliveryno) or (vdeliveryno is null and dr.deliveryno is not null))
     and ((upper(sm.smp_no) = upper(vsmpno) AND vsmpno is NOT null ) or (vsmpno is null and sm.smp_no is not null))
     and ((dr.deliveryno = vdeliveryno and vdeliveryno is not null) or (vdeliveryno is null and dr.deliveryno is not null))
  --  and (vdeliveryno is null or dr.deliveryno = vdeliveryno)
       and (( exists
            (select 'x' 
               from strang.detailrs_item di, strang.receivals r 
              where r.deliveryno = di.deliveryno
                and m.movement_no = di.movement_no
                and nvl(m.seal,'|') = nvl(di.seal,'|')
                and nvl(r.currdate, trunc(sysdate))  > to_date('1 Jan 2018','DD MON YYYY')))
           )                         
     order by m.movement_no, m.seal, di.smp_no, di.deliveryno, di.item_no, di.order_by;       
-----------------------------------------------------------------------------------------------------------------------------------------------------------
  cursor c4( vmov varchar2, vseal varchar2, vdeliveryno varchar2, vitemno varchar2, vunitno varchar2) is
  select m.movement_no, m.seal, m.full_mt, m.io, count(*) over () cnt, dr.deliveryno, dr.itemno
        , sm.urgency, sm.client_id, sm.smp_type, sm.complete, sm.hazard_class 
        , di.smp_no, di.order_by unit_no, strang.f_getlovColumn('PACKTYPES','DESCRIPTION', di.PKTPE_PACKTYPE) as unit_pktpe_packtype
        , di.lngth, di.width, di.height, di.weight, ((di.width/100)*(di.height/100)*(di.lngth/100)) as unit_volume
        , to_char(di.packed_date,'DD-Mon-RR HH24:MI:SS') packed_date
        , row_number() over (partition by m.movement_no, m.seal order by di.packed_date desc) unit_packed_date_rnk
        , dr.detaildesc
        , case when dr.sa = 'S' then 'SEA' when dr.sa = 'A' then 'AIR' else null end sa
        , strang.f_getlovColumn('PACKTYPES','DESCRIPTION', dr.pktpe_packtype) as pktpe_packtype
        , dr.partvolume, dr.partweight, dr.qty, dr.hazard
        , (select max(di1.order_by) from strang.detailrs_item di1 where di1.deliveryno = dr.deliveryno and di1.item_no = dr.itemno) max_unit
        , count(*) over ( partition by m.movement_no, m.seal, di.deliveryno, di.item_no) cum_unit
        , di.order_by ||' of '|| (select max(di1.order_by) from strang.detailrs_item di1 where di1.deliveryno = dr.deliveryno and di1.item_no = dr.itemno) unit_part
        , lag(dr.deliveryno) over (partition by m.movement_no, m.seal order by dr.deliveryno, dr.itemno) prev_deliveryno
        , lead(dr.deliveryno) over (partition by m.movement_no, m.seal order by dr.deliveryno, dr.itemno) next_deliveryno
        , lag(di.item_no) over (partition by m.movement_no, m.seal, di.deliveryno  order by di.item_no, di.order_by) prev_itemno
        , lead(di.item_no) over (partition by m.movement_no, m.seal, di.deliveryno order by di.item_no, di.order_by) next_itemno
    from strang.movements m 
     inner join strang.detailrs_item di on (m.movement_no = di.movement_no and nvl(m.seal, '|') = nvl(di.seal,'|'))
     inner join strang.receivals r on (di.deliveryno = r.deliveryno)
     left join strang.detailrs dr on (di.deliveryno = dr.deliveryno and di.item_no = dr.itemno)
     left join strang.smp sm on (di.smp_no = sm.smp_no and sm.movement_no = m.movement_no and nvl(sm.seal,'|') = nvl(m.seal,'|'))
   where m.movement_type in ( 'CARGO')
     and m.movement_no = vmov  
     and (vseal is null or UPPER(m.seal) = UPPER(vseal))
     and ((di.deliveryno = vdeliveryno and vdeliveryno is not null) or (vdeliveryno is null and di.deliveryno is not null))
     and ((di.item_no = vitemno and vitemno is not null) or (vitemno is null and di.item_no is not null))
     and ((di.order_by = vunitno and vunitno is not null) or (vunitno is null and di.order_by  is not null))      
     and ( exists
            (select 'x' 
               from strang.detailrs_item di, strang.receivals r 
              where r.deliveryno = di.deliveryno
                and m.movement_no = di.movement_no
                and nvl(m.seal,'|') = nvl(di.seal,'|')
                and nvl(r.currdate, trunc(sysdate))  > to_date('1 Jan 2018','DD MON YYYY')))                         
     order by m.movement_no, m.seal, dr.deliveryno, dr.itemno, di.order_by;  
  
  cursor c5(vscan_key number) is select m.movement_no, m.seal from strang.movements m where m.scan_key = vscan_key order by m.movement_no;
  

  c4rec1   c4%rowtype;
  c4arec1  c4a%rowtype;
  c5rec   c5%rowtype;
  vmov 	   varchar2(100);
  vsmp     varchar2(100);
  vseal	   varchar2(100);
  vdel_smp varchar2(100); --    integer;
  vdel     integer;
  vtot	   integer;
  vitemno  integer;
  vunitno  integer;
  vscan    integer;

 begin
    
    -- websys.glbx.dbg('I am at the beginning' );
    -- websys.glbx.dbg('Program is '||x(2) );
     --  websys.glbx.dbg('Parameter is '||x(3) );
       
           --  websys.glbx.dbg('smpno '||c5rec.smp_no);
        --  select * from websys.debug order by tm, ctr;
        
        --  select * from strang.smp
       
    if x.exists(5)
    then 
       vmov  := x(3);
       vseal := x(4);
       vdel_smp  := x(5);
      
       if upper(substr(vdel_smp,1,3)) = 'SMP' then
          vsmp := vdel_smp;
          if x.exists(6)
          then 
             begin vdel := to_number(x(6)); exception when others then vdel := null; end;
          end if;
       else
       
          begin vdel := to_number(vdel_smp); exception when others then vdel := null; end;
          
          if x.exists(6)
          then 
             begin vitemno := to_number(x(6)); exception when others then vitemno := null; end;
             if x.exists(7)
             then 
                begin vunitno := to_number(x(7)); exception when others then vunitno := null; end;
             end if;            
          end if;          
       end if;
       
       
           
       if vsmp is null then 
          if vdel is not null then
             open c4(vmov, vseal, vdel , vitemno, vunitno); -- vdel
             fetch c4 into c4rec1;
             if c4%notfound then
                err( '[1022] Err in process_cargo:' || ' DeliveryNo: ['||vdel||'] not found for Movement_no [' || vmov ||' '||vseal|| ']', 404, TRUE);
                close c4;
                return;
             end if;
             close c4;
          else 
             open c4(vmov, vseal, vdel , vitemno, vunitno); -- vdel
             fetch c4 into c4rec1;
             close c4;
          end if;
      
          owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
          htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
          owa_util.http_header_close;
          htp.p( '<container_items>' );
          htp.p( '<container>');
          htp.p( '<container_no>' || xtra.xmlconv(vmov) || '</container_no>' );
          htp.p( '<container_seal>' || xtra.xmlconv(vseal) || '</container_seal>' );
          if c4rec1.io = 'I' then 
             htp.p( '<cargo_direction>' || xtra.xmlconv('INBOUND DIRECTION') || '</cargo_direction>' );
          else
             htp.p( '<cargo_direction>' || xtra.xmlconv('OUTBOUND DIRECTION') || '</cargo_direction>' );
          end if;   
          htp.p( '<container_empty_full>' || xtra.xmlconv(c4rec1.full_mt) || '</container_empty_full>' );
          for c4rec in c4(vmov, vseal, vdel, vitemno, vunitno) loop
             if c4rec.deliveryno <> nvl(c4rec.prev_deliveryno, 9999999) then
                htp.p( '<delivery>' );
                htp.p( '<delivery_no>' || xtra.xmlconv(c4rec.deliveryno)|| '</delivery_no>' );  
                htp.p( '<delivery_items>');       
             end if;
                if c4rec.itemno <> nvl(c4rec.prev_itemno, 9999999) then
                   htp.p( '<delivery_item>'); 
                   htp.p( '<delivery_item_number>' || xtra.xmlconv(c4rec.itemno) || '</delivery_item_number>' );
                   htp.p( '<delivery_item_package>' || xtra.xmlconv(c4rec.pktpe_packtype) || '</delivery_item_package>' );
                   htp.p( '<delivery_item_description>' || xtra.xmlconv(c4rec.detaildesc) || '</delivery_item_description>' );
                   htp.p( '<delivery_item_volume>' || xtra.xmlconv(nvl(c4rec.partvolume,0)) || '</delivery_item_volume>' );
                   htp.p( '<delivery_item_weight>' || xtra.xmlconv(nvl(c4rec.partweight,0)) || '</delivery_item_weight>' );
                   htp.p( '<delivery_item_qty>' || xtra.xmlconv(c4rec.qty) || '</delivery_item_qty>' );
                   htp.p( '<delivery_item_mode_of_transport>' || xtra.xmlconv(c4rec.sa) || '</delivery_item_mode_of_transport>' );
                   htp.p( '<delivery_item_hazard>' || xtra.xmlconv(c4rec.hazard) || '</delivery_item_hazard>' );
                   htp.p( '<package_units>');   
                end if;
                   htp.p( '<package_unit>'); 
                   htp.p( '<record_no>' || c4%ROWCOUNT || '</record_no>' );  
                   htp.p( '<unit_no>'||c4rec.unit_no||'</unit_no>' );
                   htp.p( '<packed_date>'||c4rec.packed_date||'</packed_date>' );
                   htp.p( '<unit_packed_date_rnk>'||c4rec.unit_packed_date_rnk||'</unit_packed_date_rnk>' );
                   htp.p( '<unit_cum>'|| xtra.xmlconv(c4rec.cum_unit) || '</unit_cum>' ); 
                   htp.p( '<unit_max>'|| xtra.xmlconv(c4rec.max_unit) || '</unit_max>' );                     
                   htp.p( '<unit_part>'||c4rec.unit_part||'</unit_part>' );
                   htp.p( '<unit_smp>'||c4rec.smp_no||'</unit_smp>' );
                   htp.p( '<unit_packtype>'||c4rec.unit_pktpe_packtype||'</unit_packtype>' );
                   htp.p( '<unit_weight>'||c4rec.weight||'</unit_weight>' );
                   htp.p( '<unit_volume>'||c4rec.unit_volume||'</unit_volume>' );
                   htp.p( '</package_unit>');
                if c4rec.itemno <> nvl(c4rec.next_itemno, 9999999) then
                   htp.p( '</package_units>');   
                   htp.p( '</delivery_item>'); 
                end if;    
                    
             if c4rec.deliveryno <> nvl(c4rec.next_deliveryno, 9999999) then
                htp.p( '</delivery_items>');     
                htp.p( '</delivery>' );
             end if;
            
          end loop;
          htp.p( '</container>' );
          htp.p( '</container_items>' );
          return; 
       elsif   vsmp is not null then
          open c4a(vmov, vseal, vsmp, vdel);

          fetch c4a into c4arec1;
          if c4a%notfound then
             err( '[1022] Err in process_cargo:' || ' SMP No: ['||vsmp||'] not found for Movement_no [' || vmov ||' '||vseal|| ']', 404, TRUE);
             close c4a;
             return;
          end if;
          close c4a;     
          
          owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
          htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
          owa_util.http_header_close;
          htp.p( '<container_items>' );
          htp.p( '<container>');
          htp.p( '<container_no>' || xtra.xmlconv(vmov) || '</container_no>' );
          htp.p( '<container_seal>' || xtra.xmlconv(vseal) || '</container_seal>' );
          if c4arec1.io = 'I' then 
             htp.p( '<cargo_direction>' || xtra.xmlconv('INBOUND DIRECTION') || '</cargo_direction>' );
          else
             htp.p( '<cargo_direction>' || xtra.xmlconv('OUTBOUND DIRECTION') || '</cargo_direction>' );
          end if;   
          htp.p( '<container_empty_full>' || xtra.xmlconv(c4arec1.full_mt) || '</container_empty_full>' );
          htp.p( '<smp_items>'); --  || xtra.xmlconv(c4arec1.full_mt) || '</container_empty_full>' );
          for c4arec in c4a(vmov, vseal, vsmp,vdel) loop
             if nvl(c4arec.smp_no,'888888') <> nvl(c4arec.prev_smp_no, '9999999') then
                htp.p( '<smp_item>' );
                htp.p( '<smp_no>' || xtra.xmlconv(c4arec.smp_no)|| '</smp_no>' );  
                htp.p( '<smp_scanned_date>' || xtra.xmlconv(c4arec.smp_scanned_date)|| '</smp_scanned_date>' );  
                htp.p( '<smp_urgency>' || xtra.xmlconv(c4arec.urgency)|| '</smp_urgency>' );  
                htp.p( '<smp_client>' || xtra.xmlconv(c4arec.smp_client)|| '</smp_client>' ); 
                htp.p( '<smp_type>' || xtra.xmlconv(c4arec.smp_type)|| '</smp_type>' ); 
                htp.p( '<smp_completion_status>' || xtra.xmlconv(c4arec.complete)|| '</smp_completion_status>' ); 
                htp.p( '<smp_hazard_class>' || xtra.xmlconv(c4arec.hazard)|| '</smp_hazard_class>' ); 
                htp.p( '<delivery_items>');       
             end if;
                if c4arec.deliveryno <> nvl(c4arec.prev_deliveryno, 9999999) then
                   htp.p( '<delivery>' );
                   htp.p( '<delivery_no>' || xtra.xmlconv(c4arec.deliveryno)|| '</delivery_no>' );  
                   htp.p( '<delivery_items>');       
                end if;
                   if c4arec.itemno <> nvl(c4arec.prev_itemno, 9999999) then
                      htp.p( '<delivery_item>'); 
                      htp.p( '<delivery_item_number>' || xtra.xmlconv(c4arec.itemno) || '</delivery_item_number>' );
                      htp.p( '<delivery_item_package>' || xtra.xmlconv(c4arec.pktpe_packtype) || '</delivery_item_package>' );
                      htp.p( '<delivery_item_description>' || xtra.xmlconv(c4arec.detaildesc) || '</delivery_item_description>' );
                      htp.p( '<delivery_item_volume>' || xtra.xmlconv(c4arec.partvolume) || '</delivery_item_volume>' );
                      htp.p( '<delivery_item_weight>' || xtra.xmlconv(c4arec.partweight) || '</delivery_item_weight>' );
                      htp.p( '<delivery_item_qty>' || xtra.xmlconv(c4arec.qty) || '</delivery_item_qty>' );
                      htp.p( '<delivery_item_mode_of_transport>' || xtra.xmlconv(c4arec.sa) || '</delivery_item_mode_of_transport>' );
                      htp.p( '<delivery_item_hazard>' || xtra.xmlconv(c4arec.hazard) || '</delivery_item_hazard>' );
                      htp.p( '<package_units>');   
                   end if;
                      htp.p( '<package_unit>'); 
                      htp.p( '<record_no>' || c4a%ROWCOUNT || '</record_no>' );  
                      htp.p( '<unit_no>'||c4arec.unit_no||'</unit_no>' );
                      htp.p( '<packed_date>'||c4arec.unit_packed_date||'</packed_date>' );
                      htp.p( '<unit_packed_date_rnk>'||c4arec.unit_packed_date_rnk||'</unit_packed_date_rnk>' );
                      htp.p( '<unit_cum>'|| xtra.xmlconv(c4arec.cum_unit) || '</unit_cum>' ); 
                      htp.p( '<unit_max>'|| xtra.xmlconv(c4arec.max_unit) || '</unit_max>' );                   
                      htp.p( '<unit_part>'||c4arec.unit_part||'</unit_part>' );
                      htp.p( '<unit_smp>'||c4arec.smp_no||'</unit_smp>' );
                      htp.p( '<unit_packtype>'||c4arec.unit_pktpe_packtype||'</unit_packtype>' );
                      htp.p( '<unit_weight>'||c4arec.weight||'</unit_weight>' );
                      htp.p( '<unit_volume>'||c4arec.unit_volume||'</unit_volume>' );
                      htp.p( '</package_unit>');
                   if c4arec.itemno <> nvl(c4arec.next_itemno, 9999999) then
                      htp.p( '</package_units>');   
                      htp.p( '</delivery_item>'); 
                   end if;    
                    
                if c4arec.deliveryno <> nvl(c4arec.next_deliveryno, 9999999) then
                   htp.p( '</delivery_items>');     
                   htp.p( '</delivery>' );
                end if;
             if c4arec.smp_no <> nvl(c4arec.next_smp_no, 9999999) then   
                htp.p( '</smp_item>' );
             end if;
          end loop;
          htp.p( '</smp_items>');       
          htp.p( '</container_items>');
          htp.p( '</container>' );
          htp.p( '</container_items>' );
          return; 
                
       end if;
    end if;
    
    if x.exists(3) then     
       begin vscan := to_number(x(3)); exception when others then vscan:= null; end;        
       if vscan is not null then
          open c5(vscan);
          fetch c5 into c5rec;
          if c5%found then
             vmov := c5rec.movement_no;
             vseal := c5rec.seal;
             if x.exists(4) then 
                begin vdel := to_number(x(4)); exception when others then vdel := null; end;
                if x.exists(5) then 
                   begin vitemno := to_number(x(5)); exception when others then vitemno := null; end;
                   if x.exists(6) then 
                      begin vunitno := to_number(x(6)); exception when others then vunitno := null; end;
                   end if;            
                end if;          
                open c4(vmov, vseal, vdel , vitemno, vunitno); -- vdel
                fetch c4 into c4rec1;
                if c4%notfound then
                   err( '[1022] Err in process_cargo:' || ' DeliveryNo: ['||vdel||'] not found for Movement_no [' || vmov ||' '||vseal|| ']', 404, TRUE);
                   close c4;
                   return;
                end if;
                close c4;
      
                owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
                htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
                owa_util.http_header_close;
                htp.p( '<container_items>' );
                htp.p( '<container>');
                htp.p( '<container_no>' || xtra.xmlconv(vmov) || '</container_no>' );
                htp.p( '<container_seal>' || xtra.xmlconv(vseal) || '</container_seal>' );
                if c4rec1.io = 'I' then 
                   htp.p( '<cargo_direction>' || xtra.xmlconv('INBOUND DIRECTION') || '</cargo_direction>' );
                else
                   htp.p( '<cargo_direction>' || xtra.xmlconv('OUTBOUND DIRECTION') || '</cargo_direction>' );
                end if;   
                htp.p( '<container_empty_full>' || xtra.xmlconv(c4rec1.full_mt) || '</container_empty_full>' );
                for c4rec in c4(vmov, vseal, vdel, vitemno, vunitno) loop
                   if c4rec.deliveryno <> nvl(c4rec.prev_deliveryno, 9999999) then
                      htp.p( '<delivery>' );
                      htp.p( '<delivery_no>' || xtra.xmlconv(c4rec.deliveryno)|| '</delivery_no>' );  
                      htp.p( '<delivery_items>');       
                   end if;
                   if c4rec.itemno <> nvl(c4rec.prev_itemno, 9999999) then
                      htp.p( '<delivery_item>'); 
                      htp.p( '<delivery_item_number>' || xtra.xmlconv(c4rec.itemno) || '</delivery_item_number>' );
                      htp.p( '<delivery_item_package>' || xtra.xmlconv(c4rec.pktpe_packtype) || '</delivery_item_package>' );
                      htp.p( '<delivery_item_description>' || xtra.xmlconv(c4rec.detaildesc) || '</delivery_item_description>' );
                      htp.p( '<delivery_item_volume>' || xtra.xmlconv(nvl(c4rec.partvolume,0)) || '</delivery_item_volume>' );
                      htp.p( '<delivery_item_weight>' || xtra.xmlconv(nvl(c4rec.partweight,0)) || '</delivery_item_weight>' );
                      htp.p( '<delivery_item_qty>' || xtra.xmlconv(c4rec.qty) || '</delivery_item_qty>' );
                      htp.p( '<delivery_item_mode_of_transport>' || xtra.xmlconv(c4rec.sa) || '</delivery_item_mode_of_transport>' );
                      htp.p( '<delivery_item_hazard>' || xtra.xmlconv(c4rec.hazard) || '</delivery_item_hazard>' );
                      htp.p( '<package_units>');   
                   end if;
                   htp.p( '<package_unit>'); 
                   htp.p( '<record_no>' || c4%ROWCOUNT || '</record_no>' );  
                   htp.p( '<unit_no>'||c4rec.unit_no||'</unit_no>' ); 
                   htp.p( '<packed_date>'||c4rec.packed_date||'</packed_date>' );  
                   htp.p( '<unit_packed_date_rnk>'||c4rec.unit_packed_date_rnk||'</unit_packed_date_rnk>' );                     
                   htp.p( '<unit_cum>' || xtra.xmlconv(c4rec.cum_unit) || '</unit_cum>' ); 
                   htp.p( '<unit_max>' || xtra.xmlconv(c4rec.max_unit) || '</unit_max>' );                      
                   htp.p( '<unit_part>'||c4rec.unit_part||'</unit_part>' );
                   htp.p( '<unit_smp>'||c4rec.smp_no||'</unit_smp>' );
                   htp.p( '<unit_packtype>'||c4rec.unit_pktpe_packtype||'</unit_packtype>' );
                   htp.p( '<unit_weight>'||c4rec.weight||'</unit_weight>' );
                   htp.p( '<unit_volume>'||c4rec.unit_volume||'</unit_volume>' );
                   htp.p( '</package_unit>');
                   if c4rec.itemno <> nvl(c4rec.next_itemno, 9999999) then
                      htp.p( '</package_units>');   
                      htp.p( '</delivery_item>'); 
                   end if;    
                    
                   if c4rec.deliveryno <> nvl(c4rec.next_deliveryno, 9999999) then
                      htp.p( '</delivery_items>');     
                      htp.p( '</delivery>' );
                   end if;
            
                end loop;
                htp.p( '</container>' );
                htp.p( '</container_items>' );
                return; 
             end if;
          else 
             vmov := x(3);
             if x.exists(4) then
                vseal := x(4);
             end if;
          end if;
          close c5;
       else 
          vmov := x(3);
          if x.exists(4) then
             vseal := x(4);
          end if;
       end if;
         

--      open c1t(vmov, vseal);
--      fetch c1t into vtot;
--      close c1t;
--      if nvl(vtot,0) = 0
--        then
--        err( '[1020] Err in process_cargo:' || 'Movement_no not found [' || vmov ||' '||vseal|| ']', 404, TRUE);
--        return;
--      end if;
    elsif  ( x.exists(2) and x(2) = 'cargo') then
       owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
       htp.prn('Status: ' || '200' || ' /x' || 'OK' || xtra.NL_CHAR);
       owa_util.http_header_close;
       
       htp.p( '<containers>' );
       for c3rec in c3 loop
          htp.p( '<item>' );
          htp.p( '<record_no>' || xtra.xmlconv(c3%ROWCOUNT) || '</record_no>' );
          htp.p( '<movement_no>' || xtra.xmlconv(c3rec.movement_no) || '</movement_no>' );
          htp.p( '<seal>' || xtra.xmlconv(c3rec.seal) || '</seal>' );
          htp.p( '<dispatch_date>' || xtra.xmlconv(c3rec.dispatch_date) || '</dispatch_date>' );
          htp.p( '<iso_container_type>' || xtra.xmlconv(c3rec.iso_container_type) || '</iso_container_type>' );
          htp.p( '<packing_complete>' || xtra.xmlconv(c3rec.completion_status) || '</packing_complete>' ); 
          htp.p( '</item>' );
       end loop;
       htp.p( '</containers>' );
       return;
     else
      err( '[1021] Err in process_cargo:' || 'No Movement_no provided', 404, TRUE);
      return;
    end if;

    owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
    htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
    owa_util.http_header_close;
    
    htp.p( '<container>');
    htp.p( '<container_no>' || xtra.xmlconv(vmov) || '</container_no>');
    --htp.p( '<total_records>' || xtra.xmlconv(nvl(vtot,0)) || '</total_records>');
    htp.p( '<movements>');
    --htp.p( '<container number="' || vmov || '" tot="' || vtot || '">' );
    for c1rec in c1(vmov, vseal) loop
      htp.p( '<movement>');
    --  htp.p( '<record_no>' || xtra.xmlconv(c1%ROWCOUNT) || '</record_no>');
    --  htp.p( '<item rownumber="' || c1%ROWCOUNT ||'">' );
      htp.p( '<movement_no>' || xtra.xmlconv(c1rec.movement_no) || '</movement_no>');      
      htp.p( '<seal>' || xtra.xmlconv(c1rec.seal) || '</seal>' );
      htp.p( '<total_units>' || xtra.xmlconv(c1rec.tot)|| '</total_units>' );
      htp.p( '<scan_key>' || xtra.xmlconv(c1rec.scan_key)|| '</scan_key>' );
      htp.p( '<intl_ship_id>'|| xtra.xmlconv(c1rec.intl_ship_id) || '</intl_ship_id>');
      htp.p( '<intl_ship_name>'|| xtra.xmlconv(c1rec.intl_ship_name) || '</intl_ship_name>');
      htp.p( '<intl_ship_voyage>'|| xtra.xmlconv(c1rec.intl_voy) || '</intl_ship_voyage>');      
      htp.p( '<intl_departure_date>'|| xtra.xmlconv(c1rec.intl_estdepart) || '</intl_departure_date>');
      htp.p( '<intl_arrival_date>'|| xtra.xmlconv(c1rec.intl_estarrive) || '</intl_arrival_date>');     
      htp.p( '<intl_load_port>'|| xtra.xmlconv(c1rec.intl_portload) || '</intl_load_port>');
      htp.p( '<intl_destination_port>'|| xtra.xmlconv(c1rec.intl_portdisc) || '</intl_destination_port>');
      htp.p( '<local_ship_id>'|| xtra.xmlconv(c1rec.local_ship_id2) || '</local_ship_id>');
      htp.p( '<local_ship_name>'|| xtra.xmlconv(c1rec.local_ship_name) || '</local_ship_name>');
      htp.p( '<local_ship_voyage>'|| xtra.xmlconv(c1rec.local_voy) || '</local_ship_voyage>');    
      htp.p( '<local_departure_date>'|| xtra.xmlconv(c1rec.local_estdepart) || '</local_departure_date>');
      htp.p( '<local_arrival_date>'|| xtra.xmlconv(c1rec.local_estarrive) || '</local_arrival_date>');     
      htp.p( '<local_load_port>'|| xtra.xmlconv(c1rec.local_portload) || '</local_load_port>');
      htp.p( '<local_destination_port>'|| xtra.xmlconv(c1rec.local_portdisc) || '</local_destination_port>');       
      htp.p( '<dispatch_date>' || xtra.xmlconv(c1rec.dispatch_date) || '</dispatch_date>' );
      htp.p( '<volume>' || xtra.xmlconv(nvl(c1rec.sumvolume,0)) || '</volume>' );
      htp.p( '<weight>' || xtra.xmlconv(round(nvl(c1rec.sumweight,0),0)) || '</weight>' );
      htp.p( '<scanned_weight>' || xtra.xmlconv(round(nvl(c1rec.cum_weight,0),0)) || '</scanned_weight>' );
      htp.p( '<revton>' || xtra.xmlconv(nvl(c1rec.revton,0)) || '</revton>' );
      htp.p( '<tare>' || xtra.xmlconv(nvl(c1rec.tare,0)) || '</tare>' );
      htp.p( '<manifest_created>' || xtra.xmlconv(c1rec.manifest_created) || '</manifest_created>' );             
      if nvl(c1rec.intl_io, c1rec.local_io) = 'I' then 
         htp.p( '<cargo_direction>' || xtra.xmlconv('INBOUND DIRECTION') || '</cargo_direction>' );
      else
        htp.p( '<cargo_direction>' || xtra.xmlconv('OUTBOUND DIRECTION') || '</cargo_direction>' );
      end if;      
      htp.p( '<container_type>' || xtra.xmlconv(c1rec.container_type) || '</container_type>' );
      htp.p( '<packing_complete>' || xtra.xmlconv(c1rec.completion_status) || '</packing_complete>' ); 
      htp.p( '<movement_type>' || xtra.xmlconv(c1rec.movement_type2) || '</movement_type>' );     
      htp.p( '<cargo_departure>' || xtra.xmlconv(c1rec.departure2) || '</cargo_departure>' );
      htp.p( '<cargo_arrival>' || xtra.xmlconv(c1rec.arrival2) || '</cargo_arrival>' );
      htp.p( '<iso_container_type>' || xtra.xmlconv(c1rec.iso_container_type2) || '</iso_container_type>' );
      htp.p( '<packed_date>' || xtra.xmlconv(c1rec.packed_date) || '</packed_date>' );
      htp.p( '<packed_by>' || xtra.xmlconv(c1rec.packed_by) || '</packed_by>' );
      htp.p( '<pack_check_date>' || xtra.xmlconv(c1rec.pack_check_date) || '</pack_check_date>' );
      htp.p( '<pack_checked_by>' || xtra.xmlconv(c1rec.pack_checked_by) || '</pack_checked_by>' );  
      htp.p( '<photo_by>' || xtra.xmlconv(c1rec.photo_by) || '</photo_by>' );    
      IF UPPER(SUBSTR(NVL(c1rec.iso_container_type,'22G1'),3,1)) = 'P' THEN       
         htp.p( '<flatrack_ends>' || xtra.xmlconv(c1rec.flatrack_ends) || '</flatrack_ends>' );
         htp.p( '<pin_engaged>' || xtra.xmlconv(c1rec.pin_engaged) || '</pin_engaged>' );           
         htp.p( '<timber_trimmed>' || xtra.xmlconv(c1rec.timber_trimmed) || '</timber_trimmed>' );  
         htp.p( '<loose_items_checked>' || xtra.xmlconv(c1rec.loose_items_checked) || '</loose_items_checked>' );  
         htp.p( '<out_width_left_side>' || xtra.xmlconv(c1rec.out_width_left_side) || '</out_width_left_side>' );  
         htp.p( '<out_width_right_side>' || xtra.xmlconv(c1rec.out_width_right_side) || '</out_width_right_side>' );  
         htp.p( '<out_width_front_end>' || xtra.xmlconv(c1rec.out_width_front_end) || '</out_width_front_end>' );  
         htp.p( '<out_width_rear_end>' || xtra.xmlconv(c1rec.out_width_rear_end) || '</out_width_rear_end>' ); 
         htp.p( '<out_height>' || xtra.xmlconv(c1rec.out_height) || '</out_height>' ); 
      END IF;     
      htp.p( '<booking_ref>' || xtra.xmlconv(c1rec.booking_ref) || '</booking_ref>' );
      htp.p( '<date_modified>' || xtra.xmlconv(c1rec.date_modified) || '</date_modified>' );
      htp.p( '<full_empty>' || xtra.xmlconv(c1rec.full_mt) || '</full_empty>' );
      htp.p( '<current_location>' || xtra.xmlconv(c1rec.current_location2) || '</current_location>' );
      htp.p( '<delivery_date>' || xtra.xmlconv(c1rec.del_date) || '</delivery_date>' );
      htp.p( '<delivery_transport_company>' || xtra.xmlconv(c1rec.del_transport_company)|| '</delivery_transport_company>' );
      htp.p( '<international_bill_of_lading>' || xtra.xmlconv(c1rec.bol)|| '</international_bill_of_lading>' );
      htp.p( '<local_bill_of_lading>' || xtra.xmlconv(c1rec.local_bol)|| '</local_bill_of_lading>' );
      htp.p( '<international_house_bill>' || xtra.xmlconv(c1rec.hb)|| '</international_house_bill>' );
      htp.p( '<local_house_bill>' || xtra.xmlconv(c1rec.local_hb)|| '</local_house_bill>' );
      htp.p( '<delivery_truck_rego>' || xtra.xmlconv(c1rec.del_truck_rego)|| '</delivery_truck_rego>' );
      htp.p( '<container_park>' || xtra.xmlconv(c1rec.container_park)|| '</container_park>' );
      htp.p( '<customs_auth_no>' || xtra.xmlconv(c1rec.customs_auth_no)|| '</customs_auth_no>' );
      htp.p( '<snail_inspect>' || xtra.xmlconv(c1rec.snail_inspect)|| '</snail_inspect>' );
      htp.p( '<wharf_collect>' || xtra.xmlconv(c1rec.wharf_collect)|| '</wharf_collect>' );
      htp.p( '<aqis_depot>' || xtra.xmlconv(c1rec.aqis_depot)|| '</aqis_depot>' );
      htp.p( '<aqis_clearance>' || xtra.xmlconv(c1rec.snail_inspect)|| '</aqis_clearance>' );
      htp.p( '<offhired_date>' || xtra.xmlconv(c1rec.offhired_date)|| '</offhired_date>' );
      htp.p( '<container_owner>' || xtra.xmlconv(c1rec.owner)|| '</container_owner>' );
      htp.p( '<consignee>' || xtra.xmlconv(c1rec.consignee)|| '</consignee>' );
      htp.p( '<consignee_location>' || xtra.xmlconv(c1rec.consignee_location2)|| '</consignee_location>' );
      htp.p( '<cargo_priority>' || xtra.xmlconv(c1rec.urgency)|| '</cargo_priority>' );
      htp.p( '<customs_cleared_date>' || xtra.xmlconv(c1rec.customs_cleared_date)|| '</customs_cleared_date>' );
      htp.p( '<cargo_release_date>' || xtra.xmlconv(c1rec.release_date)|| '</cargo_release_date>' );
      htp.p( '<release_docket>' || xtra.xmlconv(c1rec.release_docket)|| '</release_docket>' );
      htp.p( '<convoy_id>' || xtra.xmlconv(c1rec.convoy_id)|| '</convoy_id>' );
     htp.p( '</movement>' );
    end loop;
   htp.p( '</movements>');
   htp.p( '</container>' );
 exception
  when others then
   err( '[1065] Err in process_cargo:' || sqlerrm, 404, TRUE);
 end process_cargo;

 procedure process_dlvry_cargo(x in owa.vc_arr, y in owa.vc_arr)
 as
 
  cursor c1(vdeliveryno varchar2) is
  select dr.deliveryno, dr.itemno, dr.detaildesc, r.currdate, r.io
        , case when dr.sa = 'S' then 'SEA' when dr.sa = 'A' then 'AIR' else null end sa
        , strang.f_getlovColumn('PACKTYPES','DESCRIPTION', dr.pktpe_packtype) as pktpe_packtype
        , dr.partvolume, dr.partweight, dr.qty, dr.hazard, dr.smp_no
        , dr.itemno ||' of '|| (select max(dr1.itemno) from strang.detailrs dr1 where dr1.deliveryno = dr.deliveryno) part
        , lag(dr.deliveryno) over (order by dr.deliveryno, dr.itemno) prev_deliveryno
        , lead(dr.deliveryno) over (order by dr.deliveryno, dr.itemno) next_deliveryno
   from strang.detailrs dr 
   inner join strang.receivals r on (dr.deliveryno = r.deliveryno)
   left join STRANG.MOVEMENTS m on (dr.movement_no = m.movement_no and nvl(dr.camov_seal,'|') = nvl(m.seal,'|'))
   where (dr.deliveryno = vdeliveryno)
     and ((dr.movement_no is null) or ( dr.movement_no is not null and m.complete in ('A','D','F','P','W','S')))
     and exists (select 'x' 
                   from strang.detailrs_item di
                  where dr.deliveryno = di.deliveryno
                    and dr.itemno = di.item_no)     
   order by dr.deliveryno, dr.itemno;  
  
 cursor c1t(vdeliveryno varchar2) is 
   select count('x') tot   
    from (
  select dr.deliveryno, dr.itemno
    from strang.detailrs dr 
   inner join strang.receivals r on (dr.deliveryno = r.deliveryno)
    where (dr.deliveryno = vdeliveryno)
     and dr.movement_no is null
     and dr.camov_seal is null);     
   
  cursor c3 is
  select dr.deliveryno, dr.itemno, dr.detaildesc,  r.currdate, r.io
        , case when dr.sa = 'S' then 'SEA' when dr.sa = 'A' then 'AIR' else null end sa
        , strang.f_getlovColumn('PACKTYPES','DESCRIPTION', dr.pktpe_packtype) as pktpe_packtype
        , dr.partvolume, dr.partweight, dr.qty, dr.hazard, dr.smp_no, case when dr.cl = 'C' then 'Containerised' else 'Loose' end item_type
        , dr.itemno ||' of '|| (select max(dr1.itemno) from strang.detailrs dr1 where dr1.deliveryno = dr.deliveryno) part   
        , lag(dr.deliveryno) over (order by dr.deliveryno, dr.itemno) prev_deliveryno
        , lead(dr.deliveryno) over (order by dr.deliveryno, dr.itemno) next_deliveryno
        , count(*) over () cnt
   from strang.detailrs dr 
   inner join strang.receivals r on (dr.deliveryno = r.deliveryno)
   where --dr.cl = 'C'
    exists (select 'x' 
                   from strang.detailrs_item di
                  where dr.deliveryno = di.deliveryno
                    and dr.itemno = di.item_no)   
    and exists (select 'x' 
                   from strang.detailrs_item di2
                  where dr.deliveryno = di2.deliveryno
                    and dr.itemno = di2.item_no
                    and di2.movement_no is null 
                    and di2.seal is null)     
--     and dr.movement_no is null
--     and dr.camov_seal is null       
   order by dr.deliveryno, dr.itemno;  
  
  cursor c4( vdeliveryno varchar2, vitemno varchar2, vunitno varchar2) is
  select count(*) over () cnt, dr.deliveryno, dr.itemno, dr.detaildesc,  r.currdate
        , case when dr.sa = 'S' then 'SEA' when dr.sa = 'A' then 'AIR' else null end sa
        , strang.f_getlovColumn('PACKTYPES','DESCRIPTION', dr.pktpe_packtype) as pktpe_packtype
        , dr.partvolume, dr.partweight, dr.qty, dr.hazard, case when dr.cl = 'C' then 'Containerised' else 'Loose' end item_type
        , di.smp_no, di.weight, di.order_by as unit_no, di.movement_no, di.seal
        , strang.f_getlovColumn('PACKTYPES','DESCRIPTION', di.pktpe_packtype) as unit_pktpe_packtype
        , ((di.width/100)*(di.height/100)*(di.lngth/100)) as unit_volume 
        , di.order_by ||' of '|| (select max(di1.order_by) from strang.detailrs_item di1 where di1.deliveryno = dr.deliveryno and di1.item_no = dr.itemno) unit_part
        , lag(di.item_no) over (partition by dr.movement_no, dr.camov_seal, di.deliveryno  order by di.item_no, di.order_by) prev_itemno
        , lead(di.item_no) over (partition by dr.movement_no, dr.camov_seal, di.deliveryno order by di.item_no, di.order_by) next_itemno
        , dr.itemno ||' of '|| (select max(dr1.itemno) from strang.detailrs dr1 where dr1.deliveryno = dr.deliveryno) part
        , lag(dr.deliveryno) over (order by dr.deliveryno, dr.itemno) prev_deliveryno
        , lead(dr.deliveryno) over (order by dr.deliveryno, dr.itemno) next_deliveryno
   from strang.detailrs dr 
   inner join strang.receivals r on (dr.deliveryno = r.deliveryno)
   inner join strang.detailrs_item di on (di.deliveryno = dr.deliveryno and di.item_no = dr.itemno)
   where  (dr.deliveryno = vdeliveryno)
     and (dr.itemno = vitemno)
 --    dr.deliveryno = 1251133
 --    and (dr.itemno = 1)
     and (di.order_by = vunitno or (vunitno is null and di.order_by is not null))
     and di.movement_no is null
     and di.seal is null       
     order by dr.deliveryno, dr.itemno, di.order_by;  
 
  c4rec1  c4%rowtype;
  vdel    integer;
  vitem   integer;
  vtot	  integer;
  vunitno integer;

 begin
 
    if x.exists(4)
    then 
       vdel  := x(3);
       vitem := x(4);
   --    vdel  := x(5);
        
   
       if vitem is null then
        GOTO list_items;
        end if;
    
       if x.exists(5)
       then 
          begin vunitno := to_number(x(5)); exception when others then vunitno := null; end;        
       end if;          
   
       websys.glbx.dbg(vdel|| ' '||vitem|| ' '||vunitno);
       open c4(vdel, vitem, vunitno);
       fetch c4 into c4rec1;
       if c4%notfound and vunitno is null then
          err( '[1022] Err in process_dlvry_cargo' || ' ItemNo: ['||vitem||'] for DeliveryNo: ['||vdel||'] not found', 404, TRUE);
          close c4;
          return;
       elsif c4%notfound and vunitno is not null then
          err( '[1022] Err in process_dlvry_cargo' || ' UnitNo: ['||vunitno||'], ItemNo: ['||vitem||'] for DeliveryNo: ['||vdel||'] not found', 404, TRUE);
          close c4;
          return;
       end if;
       close c4;
      
       owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
       htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
       owa_util.http_header_close;
       htp.p( '<delivery_item>' );
      -- htp.p( '<container number="' || xtra.xmlconv(vmov) || '" Seal="' || xtra.xmlconv(vseal) ||'" Empty_Full="' || xtra.xmlconv(c4rec1.full_mt) || '">' );
       for c4rec in c4(vdel, vitem, vunitno) loop
          if c4rec.deliveryno <> nvl(c4rec.prev_deliveryno, 9999999) then
             htp.p( '<delivery_no>' || xtra.xmlconv(c4rec.deliveryno)|| '</delivery_no>' );
             htp.p( '<delivery_date>' || xtra.xmlconv(c4rec.currdate) || '</delivery_date>' );             
             htp.p( '<delivery_item_number>' || xtra.xmlconv(c4rec.itemno) || '</delivery_item_number>' );
             htp.p( '<delivery_part>' || xtra.xmlconv(c4rec.part) || '</delivery_part>' );
             htp.p( '<delivery_item_package>' || xtra.xmlconv(c4rec.pktpe_packtype) || '</delivery_item_package>' );
             htp.p( '<delivery_item_description>' || xtra.xmlconv(c4rec.detaildesc) || '</delivery_item_description>' );
             htp.p( '<delivery_item_volume>' || xtra.xmlconv(c4rec.partvolume) || '</delivery_item_volume>' );
             htp.p( '<delivery_item_weight>' || xtra.xmlconv(c4rec.partweight) || '</delivery_item_weight>' );
             htp.p( '<delivery_item_qty>' || xtra.xmlconv(c4rec.qty) || '</delivery_item_qty>' );
             htp.p( '<delivery_item_mode_of_transport>' || xtra.xmlconv(c4rec.sa) || '</delivery_item_mode_of_transport>' );
             htp.p( '<delivery_item_type>' || xtra.xmlconv(c4rec.item_type) || '</delivery_item_type>' );
             htp.p( '<delivery_item_hazard>' || xtra.xmlconv(c4rec.hazard) || '</delivery_item_hazard>' );  
             htp.p( '<unit_items>' );
          end if;
          
             htp.p( '<unit_item>' );
             htp.p( '<unit_no>' || xtra.xmlconv(c4rec.unit_no)|| '</unit_no>' );  
             htp.p( '<unit_package>' || xtra.xmlconv(c4rec.unit_pktpe_packtype) || '</unit_package>' );
             htp.p( '<unit_movement_no>' || xtra.xmlconv(c4rec.movement_no) || '</unit_movement_no>' );
             htp.p( '<unit_seal>' || xtra.xmlconv(c4rec.seal) || '</unit_seal>' );
             htp.p( '<unit_smp_no>' || xtra.xmlconv(c4rec.smp_no) || '</unit_smp_no>' );
             htp.p( '<unit_weight>' || xtra.xmlconv(c4rec.weight) || '</unit_weight>' ); 
             htp.p( '<unit_volume>' || xtra.xmlconv(c4rec.unit_volume) || '</unit_volume>' );      
             htp.p( '<unit_part>' || xtra.xmlconv(c4rec.unit_part) || '</unit_part>' );   
             htp.p( '</unit_item>' );
          
                   
       end loop;
       htp.p( '</unit_items>' );
       htp.p( '</delivery_item>' );
       return;    
    end if;
    
     <<list_items>>
    if x.exists(3)
     then
      vdel := x(3);
--      if x.exists(4) then
--        vitem := x(4);
--      end if;
      open c1t(vdel);
      fetch c1t into vtot;
      close c1t;
      if nvl(vtot,0) = 0
        then
        err( '[1020] Err in process_dlvry_cargo:' || 'deliveryno not found [' || vdel|| ']', 404, TRUE);
        return;
      end if;
    elsif  ( x.exists(2) and x(2) = 'dlvry_cargo') then
       owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
       htp.prn('Status: ' || '200' || ' /x' || 'OK' || xtra.NL_CHAR);
       owa_util.http_header_close;
       
       htp.p( '<deliveries>' );
       for c3rec in c3 loop
          if c3rec.deliveryno <> nvl(c3rec.prev_deliveryno, 9999999) then
             htp.p( '<delivery>' );
             htp.p( '<delivery_no>' || xtra.xmlconv(c3rec.deliveryno)|| '</delivery_no>' );
             htp.p( '<delivery_date>' || xtra.xmlconv(c3rec.currdate) || '</delivery_date>' );
             if c3rec.io = 'I' then 
                htp.p( '<delivery_direction>' || xtra.xmlconv('INBOUND DIRECTION') || '</delivery_direction>' );
             else
                htp.p( '<delivery_direction>' || xtra.xmlconv('OUTBOUND DIRECTION') || '</delivery_direction>' );
             end if;   
             htp.p( '<items>' );
          end if;
          htp.p( '<item>');
          htp.p( '<record_no>' || xtra.xmlconv(c3%ROWCOUNT) || '</record_no>' );
          htp.p( '<delivery_part>' || xtra.xmlconv(c3rec.part) || '</delivery_part>' );
          htp.p( '<delivery_item_no>' || xtra.xmlconv(c3rec.itemno) || '</delivery_item_no>' );
          htp.p( '<delivery_smp_no>' || xtra.xmlconv(c3rec.smp_no) || '</delivery_smp_no>' );
          htp.p( '<delivery_item_mode>' || xtra.xmlconv(c3rec.sa) || '</delivery_item_mode>' );
          htp.p( '<delivery_item_type>' || xtra.xmlconv(c3rec.item_type) || '</delivery_item_type>' );
          htp.p( '<delivery_item_description>' || xtra.xmlconv(c3rec.detaildesc) || '</delivery_item_description>' );
          htp.p( '</item>' );
          if c3rec.deliveryno <> nvl(c3rec.next_deliveryno, 9999999) then
              htp.p( '</items>' );
              htp.p( '</delivery>' );
          end if;
          
       end loop;
       htp.p( '</deliveries>' );
       return;
     else
      err( '[1021] Err in process_dlvry_cargo:' || 'No Delivery No provided', 404, TRUE);
      return;
    end if;
    
    owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
    htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
    owa_util.http_header_close;

    htp.p( '<delivery>');   
    htp.p( '<delivery_no>' || xtra.xmlconv(vdel) || '</delivery_no>' );
    htp.p( '<delivery_total>' || xtra.xmlconv(vtot) || '</delivery_total>' );
    for c1rec in c1(vdel) loop
       if c1rec.deliveryno <> nvl(c1rec.prev_deliveryno, 9999999) then
          if c1rec.io = 'I' then 
             htp.p( '<delivery_direction>' || xtra.xmlconv('INBOUND DIRECTION') || '</delivery_direction>' );
          else
             htp.p( '<delivery_direction>' || xtra.xmlconv('OUTBOUND DIRECTION') || '</delivery_direction>' );
          end if;   
          htp.p( '<delivery_date>' || xtra.xmlconv(c1rec.currdate) || '</delivery_date>' );
          htp.p( '<delivery_items>'); 
       end if;      
       htp.p( '<delivery_item>'); 
       htp.p( '<record_no>' || xtra.xmlconv(c1%ROWCOUNT) || '</record_no>' ); 
       htp.p( '<delivery_item_number>' || xtra.xmlconv(c1rec.itemno) || '</delivery_item_number>' );
       htp.p( '<delivery_part>' || xtra.xmlconv(c1rec.part) || '</delivery_part>' );
       htp.p( '<delivery_item_package>' || xtra.xmlconv(c1rec.pktpe_packtype) || '</delivery_item_package>' );
       htp.p( '<delivery_item_description>' || xtra.xmlconv(c1rec.detaildesc) || '</delivery_item_description>' );
       htp.p( '<delivery_item_volume>' || xtra.xmlconv(c1rec.partvolume) || '</delivery_item_volume>' );
       htp.p( '<delivery_item_weight>' || xtra.xmlconv(c1rec.partweight) || '</delivery_item_weight>' );
       htp.p( '<delivery_item_qty>' || xtra.xmlconv(c1rec.qty) || '</delivery_item_qty>' );
       htp.p( '<delivery_item_smp_no>' || xtra.xmlconv(c1rec.smp_no) || '</delivery_item_smp_no>' );
       htp.p( '<delivery_item_mode_of_transport>' || xtra.xmlconv(c1rec.sa) || '</delivery_item_mode_of_transport>' );
       htp.p( '<delivery_item_hazard>' || xtra.xmlconv(c1rec.hazard) || '</delivery_item_hazard>' );
       htp.p( '</delivery_item>'); 
    end loop;
    htp.p( '</delivery_items>' );
    htp.p( '</delivery>' );
 exception
  when others then
   err( '[1065] Err in process_dlvry_cargo:' || sqlerrm, 404, TRUE);
 end process_dlvry_cargo;

 procedure process_smp_cargo(x in owa.vc_arr, y in owa.vc_arr)
 as
 
  cursor c1(vsmpno varchar2) is
  select sm.smp_no, sm.description smp_description, sm.movement_no, sm.seal, sm.currdate smp_currdate, sm.remarks smp_remarks, STRANG.f_get_party_name (sm.client_id) smp_client 
        , sm.sumweight, sm.sumvolume, sm.tare, sm.grossweight, sm.scan_key, sm.smp_length_in_cmtrs, sm.smp_width_in_cmtrs, sm.smp_height_in_cmtrs
        , sm.packed_date, sm.packed_by
        , case when sm.sa = 'S' then 'SEA' when sm.sa = 'A' then 'AIR' else null end smp_sa
        , case when sm.io = 'I' then 'INBOUND' when dr.sa = 'O' then 'OUTBOUND' else null end smp_direction
        , strang.f_getlovColumn('SMP_PACKTYPES','DESCRIPTION',sm.smp_type) as smp_type 
        , strang.f_getlovColumn('HAZARD_CLASS','DESCRIPTION',sm.hazard_class) as sm_hazard
        , strang.f_getlovColumn('URGENCY','DESCRIPTION',sm.urgency) as urgency
        , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION',sm.complete) as completion_status
        , ltrim(strang.f_getlovColumn('LOCATIONS','CODE',sm.location_in_warehouse)||' '||strang.f_getlovColumn('LOCATIONS','DESCRIPTION',sm.location_in_warehouse)) as location_in_warehouse
        , sm.receiving_warehouse -- added by DB 24/1/22
        , strang.f_getlovColumn('LOCATIONS','DESCRIPTION',sm.current_location) as current_location
        , dr.deliveryno, dr.itemno, dr.detaildesc, r.currdate, r.io, dr.hazard
        , case when dr.sa = 'S' then 'SEA' when dr.sa = 'A' then 'AIR' else null end sa
        , strang.f_getlovColumn('PACKTYPES','DESCRIPTION', dr.pktpe_packtype) as pktpe_packtype
        , dr.partvolume, dr.partweight, dr.qty, di.order_by as unit_no, di.smp_no unit_smp_no
        , dr.itemno ||' of '|| (select max(dr1.itemno) from strang.detailrs dr1 where dr1.deliveryno = dr.deliveryno) part
        , di.weight, strang.f_getlovColumn('PACKTYPES','DESCRIPTION', di.pktpe_packtype) as unit_pktpe_packtype
        , to_char(di.packed_date,'DD-Mon-RR HH24:MI:SS') unit_packed_date
        , row_number() over (partition by sm.smp_no order by di.packed_date desc) unit_packed_date_rnk
        , ((di.width/100)*(di.height/100)*(di.lngth/100)) as unit_volume  
        , di.order_by ||' of '|| (select max(di1.order_by) from strang.detailrs_item di1 where di1.deliveryno = dr.deliveryno and di1.item_no = dr.itemno) unit_part
        , (select max(di1.order_by) from strang.detailrs_item di1 where di1.deliveryno = dr.deliveryno and di1.item_no = dr.itemno) max_unit
        , count(*) over ( partition by sm.smp_no, di.deliveryno, di.item_no) cum_unit
        , count(distinct di.deliveryno||di.item_no||di.order_by ) over ( partition by sm.smp_no) units_per_smp
        , lag(di.item_no) over (partition by sm.smp_no, di.deliveryno  order by di.item_no, di.order_by) prev_itemno
        , lead(di.item_no) over (partition by sm.smp_no, di.deliveryno order by di.item_no, di.order_by) next_itemno
        , lag(di.deliveryno) over (partition by sm.smp_no order by di.deliveryno, di.item_no, di.order_by) prev_deliveryno
        , lead(di.deliveryno) over (partition by sm.smp_no order by di.deliveryno, di.item_no, di.order_by) next_deliveryno  
      --  , lag(sm.smp_no) over (order by dr.smp_no) prev_smp_no 
     --   , lead(sm.smp_no) over (order by dr.smp_no) next_smp_no         
        , lag(sm.smp_no) over (order by sm.smp_no, di.deliveryno, di.item_no, di.order_by) prev_smp_no
        , lead(sm.smp_no) over (order by sm.smp_no, di.deliveryno, di.item_no, di.order_by ) next_smp_no          
   from strang.smp sm 
   left join strang.detailrs_item di on (sm.smp_no = di.smp_no)
   left join strang.detailrs dr on (dr.deliveryno = di.deliveryno and di.item_no = dr.itemno)
   left join strang.receivals r on (dr.deliveryno = r.deliveryno)
 --  where (sm.smp_no = 'SMP125')
   where (sm.smp_no like '%'||vsmpno||'%' and length(vsmpno) > 5)
     and (( sm.complete in ('A','D','F','P','W','S')))
   order by di.smp_no, di.deliveryno, di.item_no, di.order_by;    
  
 cursor c1t(vsmpno varchar2) is 
   select sum(case when smp_no is null then null 
                   when deliveryno is null then 0 else 1 end) tot   
    from (
  select di.deliveryno, sm.smp_no
   from strang.smp sm 
   left join strang.detailrs_item di on (sm.smp_no = di.smp_no)
   left join strang.detailrs dr on (dr.deliveryno = di.deliveryno and di.item_no = dr.itemno)
   left join strang.receivals r on (dr.deliveryno = r.deliveryno)
  -- where (sm.smp_no =  vsmpno)
   where (sm.smp_no like '%'||vsmpno||'%' and length(vsmpno) > 3)
    -- and sm.sa = 'S'
     and (( sm.complete in ('A','D','F','P','W','S'))));     
   
 cursor c1t1(vsmpno varchar2) is 
   select sum(case when smp_no is null then null 
                   when deliveryno is null then 0 else 1 end) tot   
    from (
  select di.deliveryno, sm.smp_no
   from strang.smp sm 
   left join strang.detailrs_item di on (sm.smp_no = di.smp_no)
   left join strang.detailrs dr on (dr.deliveryno = di.deliveryno and di.item_no = dr.itemno)
   left join strang.receivals r on (dr.deliveryno = r.deliveryno)
   where (sm.smp_no =  vsmpno)
    -- and sm.sa = 'S'
     and (( sm.complete in ('A','D','F','P','W','S'))));    


  cursor c3 is
  select distinct sm.smp_no, sm.description smp_description, sm.movement_no, sm.seal, sm.currdate smp_currdate, sm.remarks smp_remarks, STRANG.f_get_party_name(sm.client_id) smp_client 
        , sm.sumweight, sm.sumvolume, sm.tare, sm.grossweight, sm.scan_key, sm.smp_length_in_cmtrs, sm.smp_width_in_cmtrs, sm.smp_height_in_cmtrs
        , sm.packed_date, sm.packed_by
        , case when sm.sa = 'S' then 'SEA' when dr.sa = 'A' then 'AIR' else null end smp_sa
        , case when sm.io = 'I' then 'INBOUND' when dr.sa = 'O' then 'OUTBOUND' else null end smp_direction
        , strang.f_getlovColumn('SMP_PACKTYPES','DESCRIPTION',sm.smp_type) as smp_type 
        , strang.f_getlovColumn('HAZARD_CLASS','DESCRIPTION',sm.hazard_class) as hazard
        , strang.f_getlovColumn('URGENCY','DESCRIPTION',sm.urgency) as urgency
        , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION',sm.complete) as completion_status
        , strang.f_getlovColumn('LOCATIONS','DESCRIPTION',sm.location_in_warehouse) as location_in_warehouse
        , strang.f_getlovColumn('LOCATIONS','DESCRIPTION',sm.current_location) as current_location 
        , strang.f_getlovColumn('PACKTYPES','DESCRIPTION', dr.pktpe_packtype) as pktpe_packtype
        , dr.partvolume, dr.partweight, dr.qty 
        , dr.deliveryno, dr.detaildesc,  dr.itemno
        , di.order_by unit_no
        , to_char(di.packed_date,'DD-Mon-RR HH24:MI:SS') unit_packed_date
        , row_number() over (partition by sm.smp_no order by di.packed_date desc) unit_packed_date_rnk
        , di.weight, strang.f_getlovColumn('PACKTYPES','DESCRIPTION', di.pktpe_packtype) as unit_pktpe_packtype
        , ((di.width/100)*(di.height/100)*(di.lngth/100)) as unit_volume    
        , count(distinct di.deliveryno||di.item_no||di.order_by ) over ( partition by sm.smp_no) units_per_smp
---------------------------------------------------------------------------------
        , lag(di.item_no) over (partition by di.smp_no, di.deliveryno  order by di.item_no, di.order_by) prev_itemno
        , lead(di.item_no) over (partition by di.smp_no, di.deliveryno order by di.item_no, di.order_by) next_itemno
        , lag(dr.deliveryno) over (partition by dr.smp_no order by dr.deliveryno, dr.itemno) prev_deliveryno
        , lead(dr.deliveryno) over (partition by dr.smp_no order by dr.deliveryno, dr.itemno) next_deliveryno   
        , lag(sm.smp_no) over (order by sm.smp_no, r.deliveryno) prev_smp_no
        , lead(sm.smp_no) over (order by sm.smp_no, r.deliveryno) next_smp_no
----------------------------------------------------------------------------------
        , count(*) over () cnt
   from strang.smp sm 
   left join strang.detailrs_item di on (sm.smp_no = di.smp_no)
   left join strang.detailrs dr on (dr.deliveryno = di.deliveryno and di.item_no = dr.itemno)
   left join strang.receivals r on (dr.deliveryno = r.deliveryno)
  where (( sm.complete in ('A','D','F','P','W','S')))
   -- and sm.sa = 'S'
   order by sm.smp_no, dr.deliveryno, dr.itemno, di.order_by;    

  cursor c4(vsmpno varchar2, vdeliveryno varchar2, vitemno varchar2, vunitno varchar2 ) is
  select sm.smp_no, sm.description smp_description, sm.movement_no, sm.seal, sm.currdate smp_currdate, sm.remarks smp_remarks, STRANG.f_get_party_name (sm.client_id) smp_client 
        , sm.sumweight, sm.sumvolume, sm.tare, sm.grossweight, sm.scan_key, sm.smp_length_in_cmtrs, sm.smp_width_in_cmtrs, sm.smp_height_in_cmtrs
        , sm.packed_date, sm.packed_by
        , case when sm.sa = 'S' then 'SEA' when dr.sa = 'A' then 'AIR' else null end smp_sa
        , case when sm.io = 'I' then 'INBOUND' when dr.sa = 'O' then 'OUTBOUND' else null end smp_direction
        , strang.f_getlovColumn('SMP_PACKTYPES','DESCRIPTION',sm.smp_type) as smp_type 
        , strang.f_getlovColumn('HAZARD_CLASS','DESCRIPTION',sm.hazard_class) as sm_hazard
        , strang.f_getlovColumn('URGENCY','DESCRIPTION',sm.urgency) as urgency
        , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION',sm.complete) as completion_status
        , ltrim(strang.f_getlovColumn('LOCATIONS','CODE',sm.location_in_warehouse)||' '||strang.f_getlovColumn('LOCATIONS','DESCRIPTION',sm.location_in_warehouse)) as location_in_warehouse
        , strang.f_getlovColumn('LOCATIONS','DESCRIPTION',sm.current_location) as current_location
        , dr.deliveryno, dr.itemno, dr.detaildesc, r.currdate, r.io, dr.hazard
        , case when dr.sa = 'S' then 'SEA' when dr.sa = 'A' then 'AIR' else null end sa
        , strang.f_getlovColumn('PACKTYPES','DESCRIPTION', dr.pktpe_packtype) as pktpe_packtype
        , dr.partvolume, dr.partweight, dr.qty, di.order_by as unit_no, di.smp_no unit_smp_no
        , dr.itemno ||' of '|| (select max(dr1.itemno) from strang.detailrs dr1 where dr1.deliveryno = dr.deliveryno) part
        , case when dr.cl = 'C' then 'Containerised' else 'Loose' end item_type
        , di.weight, strang.f_getlovColumn('PACKTYPES','DESCRIPTION', di.pktpe_packtype) as unit_pktpe_packtype
        , ((di.width/100)*(di.height/100)*(di.lngth/100)) as unit_volume  
        , di.order_by ||' of '|| (select max(di1.order_by) from strang.detailrs_item di1 where di1.deliveryno = dr.deliveryno and di1.item_no = dr.itemno) unit_part
        , to_char(di.packed_date,'DD-Mon-RR HH24:MI:SS') unit_packed_date
        , row_number() over (partition by sm.smp_no order by di.packed_date desc) unit_packed_date_rnk
        , (select max(di1.order_by) from strang.detailrs_item di1 where di1.deliveryno = dr.deliveryno and di1.item_no = dr.itemno) max_unit
        , count(*) over ( partition by sm.smp_no, di.deliveryno, di.item_no) cum_unit
        , lag(di.item_no) over (partition by sm.movement_no, sm.seal, sm.smp_no, di.deliveryno  order by di.item_no, di.order_by) prev_itemno
        , lead(di.item_no) over (partition by sm.movement_no, sm.seal, sm.smp_no, di.deliveryno order by di.item_no, di.order_by) next_itemno
        , lag(dr.deliveryno) over (partition by sm.movement_no, sm.seal, sm.smp_no order by di.deliveryno, di.item_no) prev_deliveryno
        , lead(dr.deliveryno) over (partition by sm.movement_no, sm.seal, sm.smp_no order by di.deliveryno, di.item_no) next_deliveryno  
        , lag(sm.smp_no) over (partition by sm.movement_no, sm.seal order by sm.smp_no) prev_smp_no
        , lead(sm.smp_no) over (partition by sm.movement_no, sm.seal order by sm.smp_no) next_smp_no      
   from strang.smp sm 
   left join strang.detailrs_item di on (sm.smp_no = di.smp_no)
   left join strang.detailrs dr on (dr.deliveryno = di.deliveryno and di.item_no = dr.itemno)
   left join strang.receivals r on (dr.deliveryno = r.deliveryno)
   where sm.smp_no = vsmpno
    and (dr.deliveryno = vdeliveryno)
    and (dr.itemno = vitemno or (vitemno is null and dr.itemno is not null))
    and (di.order_by = vunitno or (vunitno is null and di.order_by is not null))
    and (( sm.complete in ('A','D','F','P','W','S')))
   order by sm.movement_no, sm.seal, sm.smp_no, di.deliveryno, di.item_no, di.order_by;  
 
  cursor c5(vscan_key number) is select sm.smp_no from strang.smp sm where sm.scan_key = vscan_key order by sm.smp_no;

  c4rec1  c4%rowtype;
  c1rec   c1%rowtype;
  c5rec   c5%rowtype;
  vsmp    varchar2(50);
  vscan   integer;
  vdel    integer;
  vitem   integer;
  vtot	  integer;
  vunitno integer;

 begin

    if x.exists(4)
    then 
       begin vscan := to_number(x(3)); exception when others then vscan:= null; end;        
       if vscan is not null then
          open c5(vscan);
          fetch c5 into c5rec;
          if c5%found then
             vsmp := c5rec.smp_no;
          else 
             vsmp := x(3);
          commit;
          end if;
          close c5;
       else 
          vsmp := x(3);
       end if;
       
--      open c1t1(vsmp);
--      fetch c1t1 into vtot;
--      close c1t1;
--      ---- start here
--      if vtot = 0
--        then
--        err( '[1020] Err in process_smp_cargo:' || 'SMP Units not Found! [' || vsmp|| ']', 404, TRUE);
--        return;
--      elsif vtot is null then
--        err( '[1020] Err in process_smp_cargo:' || 'SMP not Found! [' || vsmp|| ']', 404, TRUE);
--        return; 
--      end if;
       
       
     --  vsmp  := x(3);
       vdel  := x(4);   
       begin vdel := to_number(x(4)); exception when others then vdel := null; end;      

       if vdel is null then
        --  websys.glbx.dbg(vdel);
          GOTO list_items;
       end if;
       
       if x.exists(5)
       then 
          begin vitem := to_number(x(5)); exception when others then vitem := null; end;        
       end if;   
    
       if x.exists(6)
       then 
          begin vunitno := to_number(x(6)); exception when others then vunitno := null; end;        
       end if;          
   
   
       open c4(vsmp, vdel, vitem, vunitno);
       fetch c4 into c4rec1;
       if c4%notfound and vunitno is null then
          err( '[1022] Err in process_smp_cargo' || ' ItemNo: ['||vitem||'] for DeliveryNo: ['||vdel||'] for SMPNo: ['||vsmp||'] not found', 404, TRUE);
          close c4;
          return;
       elsif c4%notfound and vunitno is not null then
          err( '[1022] Err in process_smp_cargo' || ' UnitNo: ['||vunitno||'] for ItemNo: ['||vitem||'] for DeliveryNo: ['||vdel||'] for SMPNo: ['||vsmp||']  not found', 404, TRUE);
          close c4;
          return;
       end if;
       close c4;
      
       owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
       htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
       owa_util.http_header_close;
       htp.p( '<smp_item>' );
       htp.p( '<smp_no>' || xtra.xmlconv(vsmp)|| '</smp_no>' );
       htp.p( '<smp_scan_key>' || xtra.xmlconv(c4rec1.scan_key)|| '</smp_scan_key>' );
       htp.p( '<delivery_items>' );
       for c4rec in c4(vsmp, vdel, vitem, vunitno) loop
              
          if c4rec.deliveryno <> nvl(c4rec.prev_deliveryno, 9999999) then
             htp.p( '<delivery_no>' || xtra.xmlconv(c4rec.deliveryno)|| '</delivery_no>' );
             htp.p( '<delivery_date>' || xtra.xmlconv(c4rec.currdate) || '</delivery_date>' );  
             htp.p( '<delivery_item>' );
          end if;   
             
             if c4rec.itemno <> nvl(c4rec.prev_itemno, 9999999) then           
                htp.p( '<delivery_item_number>' || xtra.xmlconv(c4rec.itemno) || '</delivery_item_number>' );
                htp.p( '<delivery_part>' || xtra.xmlconv(c4rec.part) || '</delivery_part>' ); 
                htp.p( '<delivery_item_package>' || xtra.xmlconv(c4rec.pktpe_packtype) || '</delivery_item_package>' );
                htp.p( '<delivery_item_description>' || xtra.xmlconv(c4rec.detaildesc) || '</delivery_item_description>' );
                htp.p( '<delivery_item_volume>' || xtra.xmlconv(c4rec.partvolume) || '</delivery_item_volume>' );
                htp.p( '<delivery_item_weight>' || xtra.xmlconv(c4rec.partweight) || '</delivery_item_weight>' );
                htp.p( '<delivery_item_qty>' || xtra.xmlconv(c4rec.qty) || '</delivery_item_qty>' );
                htp.p( '<delivery_item_mode_of_transport>' || xtra.xmlconv(c4rec.sa) || '</delivery_item_mode_of_transport>' );
                htp.p( '<delivery_item_type>' || xtra.xmlconv(c4rec.item_type) || '</delivery_item_type>' );
                htp.p( '<delivery_item_hazard>' || xtra.xmlconv(c4rec.hazard) || '</delivery_item_hazard>' );  
                htp.p( '<unit_items>' );
             end if;
          
             htp.p( '<unit_item>' );
             htp.p( '<unit_no>' || xtra.xmlconv(c4rec.unit_no)|| '</unit_no>' );  
             htp.p( '<packed_date>' || c4rec.unit_packed_date|| '</packed_date>' ); 
             htp.p( '<unit_packed_date_rnk>' || c4rec.unit_packed_date_rnk|| '</unit_packed_date_rnk>' );   
             htp.p( '<unit_package>' || xtra.xmlconv(c4rec.unit_pktpe_packtype) || '</unit_package>' );
             htp.p( '<unit_smp_no>' || xtra.xmlconv(c4rec.unit_smp_no) || '</unit_smp_no>' );
             htp.p( '<unit_weight>' || xtra.xmlconv(c4rec.weight) || '</unit_weight>' ); 
             htp.p( '<unit_volume>' || xtra.xmlconv(c4rec.unit_volume) || '</unit_volume>' );  
             htp.p( '<unit_cum>' || xtra.xmlconv(c4rec.cum_unit) || '</unit_cum>' ); 
             htp.p( '<unit_max>' || xtra.xmlconv(c4rec.max_unit) || '</unit_max>' );     
             htp.p( '<unit_part>' || xtra.xmlconv(c4rec.unit_part) || '</unit_part>' );   
             htp.p( '</unit_item>' );
             
             if c4rec.itemno <> nvl(c4rec.next_itemno, 9999999) then      
                htp.p( '</unit_items>' );
             end if;
          if c4rec.deliveryno <> nvl(c4rec.next_deliveryno, 9999999) then
             htp.p( '</delivery_item>' );
          end if;         
             
       end loop;
       htp.p( '</delivery_items>' );
       htp.p( '</smp_item>' );
       return;    
    end if;
    
     <<list_items>>
    if x.exists(3) then
     
      begin vscan := to_number(x(3)); exception when others then vscan:= null; end;        
      if vscan is not null then
         open c5(vscan);
         fetch c5 into c5rec;
         if c5%found then
            vsmp := c5rec.smp_no;
         else 
            vsmp := x(3);
         end if;
         close c5;
      else 
         vsmp := x(3);
      end if;
      
      open c1t(vsmp);
      fetch c1t into vtot;
      close c1t;
      ---- start here
      if vtot is null
        then
        err( '[1020] Err in process_smp_cargo:' || 'SMP not Found! [' || vsmp|| ']', 404, TRUE);
        return;
      end if;
    elsif  ( x.exists(2) and x(2) = 'smp_cargo') then
       owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
       htp.prn('Status: ' || '200' || ' /x' || 'OK' || xtra.NL_CHAR);
       owa_util.http_header_close;
       
       htp.p( '<smp_items>' );
       for c3rec in c3 loop
          if c3rec.smp_no <> nvl(c3rec.prev_smp_no, '9999999') then
             htp.p( '<smp_item>' );
             htp.p( '<smp_no>' || xtra.xmlconv(c3rec.smp_no)|| '</smp_no>' );
             htp.p( '<smp_scan_key>' || xtra.xmlconv(c3rec.scan_key)|| '</smp_scan_key>' );
             htp.p( '<smp_total_units>' || xtra.xmlconv(c3rec.units_per_smp)|| '</smp_total_units>' );
             
--             htp.p( '<smp_create_date>' || xtra.xmlconv(c3rec.smp_currdate) || '</smp_create_date>' );
             htp.p( '<smp_direction>' || xtra.xmlconv(c3rec.smp_direction) || '</smp_direction>' );
             htp.p( '<smp_movement_mode>' || xtra.xmlconv(c3rec.smp_sa) || '</smp_movement_mode>' );
             htp.p( '<smp_package_description>' || xtra.xmlconv(c3rec.smp_type) || '</smp_package_description>' );
             htp.p( '<smp_hazard>' || xtra.xmlconv(c3rec.hazard) || '</smp_hazard>' );
             htp.p( '<smp_urgency>'|| xtra.xmlconv(c3rec.urgency) || '</smp_urgency>' );
-----------------------------------------------------------------------------------------------------------------------------             
             htp.p( '<smp_length>'|| xtra.xmlconv(c3rec.smp_length_in_cmtrs) || '</smp_length>' );
             htp.p( '<smp_width>'|| xtra.xmlconv(c3rec.smp_width_in_cmtrs) || '</smp_width>' );
             htp.p( '<smp_height>'|| xtra.xmlconv(c3rec.smp_height_in_cmtrs) || '</smp_height>' );
-----------------------------------------------------------------------------------------------------------------------------
             htp.p( '<smp_packed_date>'|| xtra.xmlconv(c3rec.packed_date) || '</smp_packed_date>' );
             htp.p( '<smp_packed_by>'|| xtra.xmlconv(c3rec.packed_by) || '</smp_packed_by>' );
             htp.p( '<smp_completion_status>'|| xtra.xmlconv(c3rec.completion_status) || '</smp_completion_status>' );             
--             htp.p( '<smp_description>'|| xtra.xmlconv(c3rec.smp_description) || '</smp_description>' );
             htp.p( '<smp_movement_no>'|| xtra.xmlconv(c3rec.movement_no) || '</smp_movement_no>' );
             htp.p( '<smp_seal>'|| xtra.xmlconv(c3rec.seal) || '</smp_seal>' );
             htp.p( '<smp_client>'|| xtra.xmlconv(c3rec.smp_client ) || '</smp_client>' );
          end if;
          
          if c3rec.smp_no <> nvl(c3rec.next_smp_no, '9999999') then
              htp.p( '</smp_item>' );
          end if;
          
       end loop;
       htp.p( '</smp_items>' );
       return;
     else
      err( '[1021] Err in process_smp_cargo:' || 'No SMP No provided', 404, TRUE);
      return;
    end if;
    
    owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
    htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
    owa_util.http_header_close;
    if vsmp is not null and not x.exists(4) then
    --   open c1(vsmp);  -- UNCOMMENT
    --   fetch c1 into c1rec; -- UNCOMMENT
    --   close c1;  -- UNCOMMENT
       htp.p( '<smp_items>' ); -- REMOVE LATER
       for c1rec in c1(vsmp) loop
       
       if c1rec.smp_no <> nvl(c1rec.prev_smp_no, '9999999') then      
       htp.p( '<smp_item>');   
       htp.p( '<smp_no>' || xtra.xmlconv(c1rec.smp_no) || '</smp_no>' );
       htp.p( '<smp_scan_key>' || xtra.xmlconv(c1rec.scan_key)|| '</smp_scan_key>' );
       htp.p( '<smp_total_units>' || xtra.xmlconv(c1rec.units_per_smp)|| '</smp_total_units>' );
       htp.p( '<smp_create_date>' || xtra.xmlconv(c1rec.smp_currdate) || '</smp_create_date>' );
       htp.p( '<smp_direction>' || xtra.xmlconv(c1rec.smp_direction) || '</smp_direction>' );
       htp.p( '<smp_movement_mode>' || xtra.xmlconv(c1rec.smp_sa) || '</smp_movement_mode>' );
       htp.p( '<smp_package_description>' || xtra.xmlconv(c1rec.smp_type) || '</smp_package_description>' );
       htp.p( '<smp_hazard>' || xtra.xmlconv(c1rec.sm_hazard) || '</smp_hazard>' );
       htp.p( '<smp_urgency>'|| xtra.xmlconv(c1rec.urgency) || '</smp_urgency>' );
       htp.p( '<smp_length>'|| xtra.xmlconv(c1rec.smp_length_in_cmtrs) || '</smp_length>' );
       htp.p( '<smp_width>'|| xtra.xmlconv(c1rec.smp_width_in_cmtrs) || '</smp_width>' );
       htp.p( '<smp_height>'|| xtra.xmlconv(c1rec.smp_height_in_cmtrs) || '</smp_height>' );
-----------------------------------------------------------------------------------------------------------------------------
       htp.p( '<smp_packed_date>'|| xtra.xmlconv(c1rec.packed_date) || '</smp_packed_date>' );
       htp.p( '<smp_packed_by>'|| xtra.xmlconv(c1rec.packed_by) || '</smp_packed_by>' );            
       htp.p( '<smp_completion_status>'|| xtra.xmlconv(c1rec.completion_status) || '</smp_completion_status>' ); 
       htp.p( '<smp_current_location>'|| xtra.xmlconv(c1rec.current_location) || '</smp_current_location>' );    
       htp.p( '<smp_location_in_warehouse>'|| xtra.xmlconv(c1rec.location_in_warehouse) || '</smp_location_in_warehouse>' ); 
       htp.p( '<smp_receiving_warehouse>'|| xtra.xmlconv(c1rec.receiving_warehouse) || '</smp_receiving_warehouse>' );                 
       --      htp.p( '<smp_description>'|| xtra.xmlconv(c1rec.smp_description) || '</smp_description>' );
       htp.p( '<smp_movement_no>'|| xtra.xmlconv(c1rec.movement_no) || '</smp_movement_no>' );
       htp.p( '<smp_seal>'|| xtra.xmlconv(c1rec.seal) || '</smp_seal>' );
       htp.p( '<smp_client>'|| xtra.xmlconv(c1rec.smp_client ) || '</smp_client>' ); 
       htp.p( '<smp_sumweight>'|| xtra.xmlconv(c1rec.sumweight ) || '</smp_sumweight>' );
       htp.p( '<smp_sumvolume>'|| xtra.xmlconv(c1rec.sumvolume ) || '</smp_sumvolume>' );
       htp.p( '<smp_tare>'|| xtra.xmlconv(c1rec.tare ) || '</smp_tare>' );
       htp.p( '<smp_grossweight>'|| xtra.xmlconv(c1rec.grossweight) || '</smp_grossweight>' );     
    --   htp.p( '</smp_item>' );   -- UNCOMMENT LATER
       end if;
       
       if c1rec.smp_no <> nvl(c1rec.next_smp_no, '9999999') then
          htp.p( '</smp_item>' );
       end if;
          
       end loop;
       
       htp.p( '</smp_items>' );     
    else 
       htp.p( '<smp_item>');   
       htp.p( '<smp_no>' || xtra.xmlconv(vsmp) || '</smp_no>' );       
       htp.p( '<smp_total_units>' || xtra.xmlconv(vtot) || '</smp_total_units>' );
       for c1rec in c1(vsmp) loop
          if c1rec.smp_no <> nvl(c1rec.prev_smp_no, '9999999') then
             htp.p( '<smp_scan_key>' || xtra.xmlconv(c1rec.scan_key)|| '</smp_scan_key>' );
             htp.p( '<smp_create_date>' || xtra.xmlconv(c1rec.smp_currdate) || '</smp_create_date>' );
             htp.p( '<smp_direction>' || xtra.xmlconv(c1rec.smp_direction) || '</smp_direction>' );
             htp.p( '<smp_movement_mode>' || xtra.xmlconv(c1rec.smp_sa) || '</smp_movement_mode>' );
             htp.p( '<smp_package_description>' || xtra.xmlconv(c1rec.smp_type) || '</smp_package_description>' );
             htp.p( '<smp_hazard>' || xtra.xmlconv(c1rec.sm_hazard) || '</smp_hazard>' );
             htp.p( '<smp_urgency>'|| xtra.xmlconv(c1rec.urgency) || '</smp_urgency>' );    
             htp.p( '<smp_length>'|| xtra.xmlconv(c1rec.smp_length_in_cmtrs) || '</smp_length>' );
             htp.p( '<smp_width>'|| xtra.xmlconv(c1rec.smp_width_in_cmtrs) || '</smp_width>' );
             htp.p( '<smp_height>'|| xtra.xmlconv(c1rec.smp_height_in_cmtrs) || '</smp_height>' );
-----------------------------------------------------------------------------------------------------------------------------
             htp.p( '<smp_packed_date>'|| xtra.xmlconv(c1rec.packed_date) || '</smp_packed_date>' );
             htp.p( '<smp_packed_by>'|| xtra.xmlconv(c1rec.packed_by) || '</smp_packed_by>' );        
             htp.p( '<smp_completion_status>'|| xtra.xmlconv(c1rec.completion_status) || '</smp_completion_status>' ); 
             htp.p( '<smp_current_location>'|| xtra.xmlconv(c1rec.current_location) || '</smp_current_location>' );    
             htp.p( '<smp_location_in_warehouse>'|| xtra.xmlconv(c1rec.location_in_warehouse) || '</smp_location_in_warehouse>' );              
       --      htp.p( '<smp_description>'|| xtra.xmlconv(c1rec.smp_description) || '</smp_description>' );
             htp.p( '<smp_movement_no>'|| xtra.xmlconv(c1rec.movement_no) || '</smp_movement_no>' );
             htp.p( '<smp_seal>'|| xtra.xmlconv(c1rec.seal) || '</smp_seal>' );
             htp.p( '<smp_client>'|| xtra.xmlconv(c1rec.smp_client ) || '</smp_client>' ); 
             htp.p( '<smp_sumweight>'|| xtra.xmlconv(c1rec.sumweight ) || '</smp_sumweight>' );
             htp.p( '<smp_sumvolume>'|| xtra.xmlconv(c1rec.sumvolume ) || '</smp_sumvolume>' );
             htp.p( '<smp_tare>'|| xtra.xmlconv(c1rec.tare ) || '</smp_tare>' );
             htp.p( '<smp_grossweight>'|| xtra.xmlconv(c1rec.grossweight) || '</smp_grossweight>' );                           
             htp.p( '<deliveries>'); 
          end if;
          if c1rec.deliveryno <> nvl(c1rec.prev_deliveryno, 9999999) then
             htp.p( '<delivery>' );
             htp.p( '<delivery_no>' || xtra.xmlconv(c1rec.deliveryno)|| '</delivery_no>' );
             htp.p( '<delivery_date>' || xtra.xmlconv(c1rec.currdate) || '</delivery_date>' ); 
             htp.p( '<delivery_items>' );
          end if;   
          if c1rec.itemno <> nvl(c1rec.prev_itemno, 9999999) then
             htp.p( '<delivery_item>' ); 
             htp.p( '<delivery_item_number>' || xtra.xmlconv(c1rec.itemno) || '</delivery_item_number>' );
             htp.p( '<delivery_part>' || xtra.xmlconv(c1rec.part) || '</delivery_part>' );
--       htp.p( '<delivery_item_package>' || xtra.xmlconv(c1rec.pktpe_packtype) || '</delivery_item_package>' );
--       htp.p( '<delivery_item_description>' || xtra.xmlconv(c1rec.detaildesc) || '</delivery_item_description>' );
--       htp.p( '<delivery_item_volume>' || xtra.xmlconv(c1rec.partvolume) || '</delivery_item_volume>' );
--       htp.p( '<delivery_item_weight>' || xtra.xmlconv(c1rec.partweight) || '</delivery_item_weight>' );
--       htp.p( '<delivery_item_qty>' || xtra.xmlconv(c1rec.qty) || '</delivery_item_qty>' );
             htp.p( '<delivery_item_smp_no>' || xtra.xmlconv(c1rec.smp_no) || '</delivery_item_smp_no>' );
             htp.p( '<delivery_item_mode_of_transport>' || xtra.xmlconv(c1rec.sa) || '</delivery_item_mode_of_transport>' );
             htp.p( '<delivery_item_hazard>' || xtra.xmlconv(c1rec.hazard) || '</delivery_item_hazard>' );
             htp.p( '<package_units>');   
         end if;   
         if   c1rec.unit_no is not null then       
            htp.p( '<package_unit>'); 
            htp.p( '<record_no>' || xtra.xmlconv(c1%ROWCOUNT) || '</record_no>' );  
            htp.p( '<unit_no>'||c1rec.unit_no||'</unit_no>' );
            htp.p( '<unit_packed_date>' || to_char(c1rec.unit_packed_date)|| '</unit_packed_date>' );  
            htp.p( '<unit_packed_date_rnk>' || c1rec.unit_packed_date_rnk|| '</unit_packed_date_rnk>' );  
            htp.p( '<unit_cum>' || xtra.xmlconv(c1rec.cum_unit) || '</unit_cum>' ); 
            htp.p( '<unit_max>' || xtra.xmlconv(c1rec.max_unit) || '</unit_max>' );     
            htp.p( '<unit_part>'||c1rec.unit_part||'</unit_part>' );
            htp.p( '<unit_smp>'||c1rec.unit_smp_no||'</unit_smp>' );
            htp.p( '<unit_packtype>'||c1rec.unit_pktpe_packtype||'</unit_packtype>' );
            htp.p( '<unit_weight>'||c1rec.weight||'</unit_weight>' );
            htp.p( '<unit_volume>'||c1rec.unit_volume||'</unit_volume>' );
            htp.p( '</package_unit>');
         end if;
         if c1rec.itemno <> nvl(c1rec.next_itemno, 9999999) then
            htp.p( '</package_units>');   
            htp.p( '</delivery_item>'); 
         end if; 
         if c1rec.deliveryno <> nvl(c1rec.next_deliveryno, 9999999) then
            htp.p( '</delivery_items>' );
            htp.p( '</delivery>' );
         end if;
       end loop;
       htp.p( '</deliveries>' );
       htp.p( '</smp_item>' );
    end if;
    
 exception
  when others then
   err( '[1065] Err in process_smp_cargo:' || sqlerrm, 404, TRUE);
 end process_smp_cargo;

 procedure process_pos_soap( x in owa.vc_arr, y in owa.vc_arr, vhdr in varchar2 )
 as

  cursor c1(vpo varchar2) is select p.* from strang.pos p where po = vpo order by recno;
  cursor c1t(vpo varchar2) is select count('x') tot from strang.pos p where po = vpo;
  cursor c3(vname varchar2, vinv varchar2) is select description from strang.lov where lov_name = vname and code = vinv;

  c3rec		c3%ROWTYPE;
  vpo 		varchar2(100);
  vtot		integer;

 begin
    if x.exists(3)
     then
      vpo := x(3);
      open c1t(vpo);
      fetch c1t into vtot;
      close c1t;
      if nvl(vtot,0) = 0
       then
        err( '[1010] Err in process_pos:' || 'PO not found [' || vpo || ']', 404, TRUE);
        return;
      end if;

     else
      err( '[1011] Err in process_pos:' || 'No PO provided', 404, TRUE);
      return;
    end if;

    owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
    htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
    owa_util.http_header_close;

    if vhdr in ('pos_soap','possoap')
     then
      htp.p( '<soap:Envelope xmlns:soap="http://schemas.xmlxtra.org/soap/envelope/" soap:encodingStyle="http://schemas.xmlxtra.org/soap/encoding">' );
      htp.p( '<soap:Body>' );
    end if;

    htp.p( '<ns1:glmsPoOpenItems_MT xmlns:ns1="http://www.stxgroup.com.au/glms">' );
    for c1rec in c1(vpo) loop
     htp.p( '<item>' );
      htp.p( '<PO_NUMBER>' || xtra.xmlconv(c1rec.PO) || '</PO_NUMBER>');
      htp.p( '<PO_ITEM>' || xtra.xmlconv(c1rec.PO_ITEM_NO) || '</PO_ITEM>');
      htp.p( '<COMP_CODE>' || xtra.xmlconv('') || '</COMP_CODE>');
      htp.p( '<DOC_TYPE>' || xtra.xmlconv('') || '</DOC_TYPE>');
      htp.p( '<CREAT_DATE_HDR>' || xtra.xmlconv('') || '</CREAT_DATE_HDR>');
      htp.p( '<CREATED_BY>' || xtra.xmlconv('') || '</CREATED_BY>');
      htp.p( '<VENDOR>' || xtra.xmlconv('') || '</VENDOR>');		-- strang.receivals.supplier_customer_id and strang.customers.customer_id where strang.customers.customer_type = 'SUPPLIER'
      htp.p( '<PURCH_ORG>' || xtra.xmlconv('') || '</PURCH_ORG>');
      htp.p( '<PUR_GROUP>' || xtra.xmlconv('') || '</PUR_GROUP>');
      htp.p( '<CURRENCY_ISO>' || xtra.xmlconv('') || '</CURRENCY_ISO>'); -- strang.receivals.curr
      htp.p( '<EXCH_RATE>' || xtra.xmlconv('') || '</EXCH_RATE>');	 -- strang.receivals.exrate
      htp.p( '<DOC_DATE>' || xtra.xmlconv('') || '</DOC_DATE>');
      htp.p( '<SALES_PERS>' || xtra.xmlconv('') || '</SALES_PERS>');
      htp.p( '<TELEPHONE>' || xtra.xmlconv('') || '</TELEPHONE>');	-- strang.customers.phone
      htp.p( '<GR_MESSAGE>' || xtra.xmlconv('') || '</GR_MESSAGE>');
      htp.p( '<COLLECT_NO>' || xtra.xmlconv('') || '</COLLECT_NO>');
      htp.p( '<OUR_REF>' || xtra.xmlconv('') || '</OUR_REF>');
      htp.p( '<DELETE_IND>' || xtra.xmlconv('') || '</DELETE_IND>');
      c3rec := null;
      open c3('INVENT',c1rec.INVENTORYNO);
      fetch c3 into c3rec;
      close c3;
      htp.p( '<SHORT_TEXT>' || xtra.xmlconv(c3rec.description) || '</SHORT_TEXT>');
      htp.p( '<MATERIAL>' || xtra.xmlconv(c1rec.INVENTORYNO) || '</MATERIAL>');
      htp.p( '<PLANT>' || xtra.xmlconv('') || '</PLANT>');
      htp.p( '<STGE_LOC>' || xtra.xmlconv('') || '</STGE_LOC>');
      htp.p( '<TRACKINGNO>' || xtra.xmlconv('') || '</TRACKINGNO>');
      htp.p( '<MATL_GROUP>' || xtra.xmlconv('') || '</MATL_GROUP>');
      htp.p( '<VEND_MAT>' || xtra.xmlconv('') || '</VEND_MAT>');
      htp.p( '<QUANTITY>' || xtra.xmlconv('') || '</QUANTITY>');
      htp.p( '<PO_UNIT>' || xtra.xmlconv('') || '</PO_UNIT>');
      htp.p( '<PO_UNIT_ISO>' || xtra.xmlconv(c1rec.UNIT_UNITUSED) || '</PO_UNIT_ISO>');
      htp.p( '<ORDERPR_UN>' || xtra.xmlconv('') || '</ORDERPR_UN>');
      htp.p( '<ORDERPR_UN_ISO>' || xtra.xmlconv('') || '</ORDERPR_UN_ISO>');
      htp.p( '<CONV_NUM1>' || xtra.xmlconv('') || '</CONV_NUM1>');
      htp.p( '<CONV_DEN1>' || xtra.xmlconv('') || '</CONV_DEN1>');
      htp.p( '<NET_PRICE>' || xtra.xmlconv('') || '</NET_PRICE>');
      htp.p( '<PRICE_UNIT>' || xtra.xmlconv('') || '</PRICE_UNIT>');
      htp.p( '<TAX_CODE>' || xtra.xmlconv('') || '</TAX_CODE>');
      htp.p( '<QUAL_INSP>' || xtra.xmlconv('') || '</QUAL_INSP>');
      htp.p( '<OVER_DLV_TOL>' || xtra.xmlconv('') || '</OVER_DLV_TOL>');
      htp.p( '<UNLIMITED_DLV>' || xtra.xmlconv('') || '</UNLIMITED_DLV>');
      htp.p( '<UNDER_DLV_TOL>' || xtra.xmlconv('') || '</UNDER_DLV_TOL>');
      htp.p( '<VAL_TYPE>' || xtra.xmlconv('') || '</VAL_TYPE>');
      htp.p( '<NO_MORE_GR>' || xtra.xmlconv('') || '</NO_MORE_GR>');
      htp.p( '<ITEM_CAT>' || xtra.xmlconv('') || '</ITEM_CAT>');
      htp.p( '<ACCTASSCAT>' || xtra.xmlconv('') || '</ACCTASSCAT>');
      htp.p( '<FREE_ITEM>' || xtra.xmlconv('') || '</FREE_ITEM>');
      htp.p( '<SHIPPING>' || xtra.xmlconv('') || '</SHIPPING>');
      htp.p( '<NET_WEIGHT>' || xtra.xmlconv('') || '</NET_WEIGHT>');
      htp.p( '<WEIGHTUNIT_ISO>' || xtra.xmlconv('') || '</WEIGHTUNIT_ISO>');
      htp.p( '<VOLUME>' || xtra.xmlconv('') || '</VOLUME>');
      htp.p( '<VOLUMEUNIT_ISO>' || xtra.xmlconv('') || '</VOLUMEUNIT_ISO>');
      htp.p( '<INCOTERMS1>' || xtra.xmlconv('') || '</INCOTERMS1>');
      htp.p( '<INCOTERMS2>' || xtra.xmlconv('') || '</INCOTERMS2>');
      htp.p( '<SUPP_VENDOR>' || xtra.xmlconv('') || '</SUPP_VENDOR>');
      htp.p( '<SC_VENDOR>' || xtra.xmlconv('') || '</SC_VENDOR>');
      htp.p( '<MINREMLIFE>' || xtra.xmlconv('') || '</MINREMLIFE>');
      htp.p( '<PREQ_NO>' || xtra.xmlconv('') || '</PREQ_NO>');
      htp.p( '<PREQ_ITEM>' || xtra.xmlconv('') || '</PREQ_ITEM>');
      htp.p( '<RET_ITEM>' || xtra.xmlconv('') || '</RET_ITEM>');
      htp.p( '<PREQ_NAME>' || xtra.xmlconv('') || '</PREQ_NAME>');
      htp.p( '<PERIOD_IND_EXPIRATION_DATE>' || xtra.xmlconv('') || '</PERIOD_IND_EXPIRATION_DATE>');
      htp.p( '<PCKG_NO>' || xtra.xmlconv('') || '</PCKG_NO>');
      htp.p( '<SHIPTYPE>' || xtra.xmlconv('') || '</SHIPTYPE>');
      htp.p( '<ORDERID>' || xtra.xmlconv('') || '</ORDERID>');
      htp.p( '<GR_RCPT>' || xtra.xmlconv('') || '</GR_RCPT>');
      htp.p( '<UNLOAD_PT>' || xtra.xmlconv('') || '</UNLOAD_PT>');
      htp.p( '<WBS_ELEMENT>' || xtra.xmlconv('') || '</WBS_ELEMENT>');
      htp.p( '<PO_PR_QNT>' || xtra.xmlconv('') || '</PO_PR_QNT>');
      htp.p( '<IV_QTY_PO>' || xtra.xmlconv('') || '</IV_QTY_PO>');
      htp.p( '<SHIPPING_TEXT>' || xtra.xmlconv('') || '</SHIPPING_TEXT>');
      htp.p( '<VEND_NAME>' || xtra.xmlconv('') || '</VEND_NAME>');
      htp.p( '<OPENQTY>' || xtra.xmlconv('') || '</OPENQTY>');
      htp.p( '<DELIVERY_DATE>' || xtra.xmlconv('') || '</DELIVERY_DATE>');
      htp.p( '<MANUAL_GR>' || xtra.xmlconv('') || '</MANUAL_GR>');
     htp.p( '</item>' );
    end loop;
   htp.p( '</ns1:glmsPoOpenItems_MT>' );
   if vhdr in ('pos_soap','possoap')
    then
     htp.p( '</soap:Body>' );
     htp.p( '</soap:Envelope>' );
   end if;

 exception
  when others then
   err( '[1090] Err in process_pos_soap:' || sqlerrm, 404, TRUE);
 end process_pos_soap;

 procedure process_interface1( x in owa.vc_arr, y in owa.vc_arr, fname in varchar )
 as

  cursor c1(fnm varchar2) is select * from apache_ows_content where name = fnm;
  cursor c2(jname varchar2) is select * from user_scheduler_jobs where job_name like jname;


  c1rec 	c1%ROWTYPE;
  c2rec		c2%ROWTYPE;
  clb           clob;
  p 		DBMS_XMLPARSER.parser;
  dest_offset   integer;
  src_offset    integer;
  lang_context  integer;
  warning       varchar2(1000);
  doc 		dbms_xmldom.DOMDocument;
  n 		dbms_xmldom.DOMNode;
  nl 		dbms_xmldom.DOMNodeList;
  e 		dbms_xmldom.DOMElement;
  n_child 	dbms_xmldom.DOMNode;
  tag		varchar2(1000);
  len1 		number;
  ctr		integer;
  jname		varchar2(100);

 begin
   open c1( fname );
   fetch c1 into c1rec;
   close c1;
   if c1rec.mime_type <> 'text/xml'
    then
     cleanup(fname,TRUE);
     err( '[1046] File is not XML (mimetype not text/xml)', 404, TRUE);
     return;
   end if;

   dbms_lob.createtemporary( clb, FALSE );
   p := DBMS_XMLPARSER.newParser;
   DBMS_XMLPARSER.setValidationMode(p, FALSE);

   dest_offset := 1;
   src_offset := 1;
   lang_context := 0;
   dbms_lob.converttoclob( clb, c1rec.blob_content, dbms_lob.getlength( c1rec.blob_content ), dest_offset, src_offset, 0, lang_context, warning );

   DBMS_XMLPARSER.parseClob(p, clb );
   doc := DBMS_XMLPARSER.getDocument(p);

   if x.exists(3)
    then
     if x(3) in ('validate','validate_full')
      then
       htp.init;
       owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
       htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
       owa_util.http_header_close;

       htp.p( '<validation>' );
        htp.p( '<size>' || dbms_lob.getlength(clb) || '</size>');
        nl := dbms_xmldom.getElementsByTagName(doc, '*');
        len1 := dbms_xmldom.getLength(nl);
        ctr := 0;
        htp.p( '<len1>' || len1 || '</len1>');
        for j in 0..len1-1 loop
         n := dbms_xmldom.item(nl, j);
         e := dbms_xmldom.makeElement(n);
         n_child:= dbms_xmldom.getFirstChild(n);
         tag := dbms_xmldom.getTagName(e);
         if tag = 'item'
          then
           ctr := ctr + 1;
           if x(3) in ('validate_full')
            then
             if ctr > 1 then htp.p( '</item>' ); end if;
             htp.p( '<item rownumber="' || ctr || '">' );
           end if;
         end if;
         if x(3) in ('validate_full') and tag <> 'item'
          then
           htp.p( '<column name="' || tag || '" length="' || length(dbms_xmldom.getNodeValue(n_child)) || '"/>' );
         end if;
        end loop;
        if x(3) in ('validate_full') then htp.p( '</item>' ); end if;
        htp.p( '<items>' || ctr || '</items>');
       htp.p( '</validation>' );

       begin dbms_lob.freetemporary(clb); exception when others then null; end;
       cleanup(fname,FALSE);
       return;
     end if;

   end if;

   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   htp.init;
   owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
   htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);

   select g_name || to_char(s_object.nextval) into jname from dual;
   update apache_ows_content set name = jname where name = fname;
   commit;

   open c2(g_name || '%' );
   fetch c2 into c2rec;
   close c2;

   if c2rec.job_name is null
    then
     dbms_scheduler.create_job(job_name=>g_name || to_char(sysdate,'dd'), job_type=>'STORED_PROCEDURE', job_action=>'strangw.batch_pos', start_date=>null, repeat_interval=>null, number_of_arguments=>1, enabled=>FALSE,  comments=>'Strang batch POS Push' );
     dbms_scheduler.set_job_argument_value(job_name=>g_name || to_char(sysdate,'dd'), argument_position =>1, argument_value=>trim(xtra.encrypt_pk('StrangKey', filler_only=>TRUE)) );
     dbms_scheduler.enable(name=>g_name || to_char(sysdate,'dd'));
     commit;
   elsif c2rec.state in ('DISABLED')
    then
     dbms_scheduler.enable(c2rec.job_name);
     commit;
   end if;
   htp.p( '<result>XML File pushed</result>');

 exception
  when others then
   err( '[1060] Err in process_pos:' || sqlerrm, 404, TRUE);
   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
 end process_interface1;

 function push_to_strang(vld in integer)
  return boolean
 as

  cursor c1(vld integer) is select distinct row_id from csv_load where load_id = vld;
  cursor c2(vld integer, vrow integer) is select value,value2 from csv_load where load_id = vld and row_id = vrow;

  lrec	strang.po_pool%ROWTYPE;
  vdt	varchar2(1000);
  ctr	integer;

  /*

  exec if strangw.push_to_strang(6277625) then dbms_output.put_line('T'); end if;

  */

 begin
   ctr := 0;
   -- as requested by Sallie 27-feb-2018, do not delete all first (not delete all - spec changed).
   for c1rec in c1(vld) loop
    lrec := null;
    for c2rec in c2(vld,c1rec.row_id) loop
     case c2rec.value2
       when 'PO_NUMBER'		then lrec.PO_NUMBER		 := c2rec.value;
       when 'PO_ITEM'
	    then
		 if xtra.guess_number(c2rec.value) is null
		  then
		   lrec.PO_ITEM		 := c2rec.value;
		  else
		   lrec.PO_ITEM		 := to_char(xtra.guess_number(c2rec.value));
		 end if;
       when 'TIMESTAMP'  	then
	                          begin
				    lrec.date_created := systimestamp;
				  exception when others
				   then null;
				  end;
       when 'ACCTASSCAT'	then lrec.ACCTASSCAT		 := c2rec.value;
       when 'CITY'		then lrec.CITY			 := c2rec.value;
       when 'COLLECT_NO'	then lrec.COLLECT_NO		 := c2rec.value;
       when 'COMP_CODE'		then lrec.COMP_CODE		 := c2rec.value;
       when 'CONV_DEN1'		then lrec.CONV_DEN1		 := c2rec.value;
       when 'CONV_NUM1'		then lrec.CONV_NUM1		 := c2rec.value;
       --when 'COUNTRY'		then lrec.COUNTRY		 := c2rec.value;
       when 'COUNTRYISO'	then lrec.COUNTRYISO		 := c2rec.value;
       when 'CREATED_BY'	then lrec.CREATED_BY		 := c2rec.value;
       when 'CREAT_DATE_HDR'	then lrec.CREATE_DATE_HDR        := c2rec.value;
       when 'CREATE_DATE_HDR'	then lrec.CREATE_DATE_HDR        := c2rec.value;
       when 'CRITICAL'		then lrec.CRITICAL		 := c2rec.value;
       when 'CURRENCY_ISO'	then lrec.CURRENCY_ISO		 := c2rec.value;
       when 'DELETE_IND'	then lrec.DELETE_IND		 := c2rec.value;
       when 'DELIVERY_DATE'	then lrec.DELIVERY_DATE		 := c2rec.value;
       when 'DISTRICT'		then lrec.DISTRICT		 := c2rec.value;
       when 'DOC_DATE'		then lrec.DOC_DATE		 := c2rec.value;
       when 'DOC_TYPE'		then lrec.DOC_TYPE		 := c2rec.value;
       when 'EXCH_RATE'		then lrec.EXCH_RATE		 := c2rec.value;
       when 'FORMOFADDR'	then lrec.FORMOFADDR		 := c2rec.value;
       when 'FREE_ITEM'		then lrec.FREE_ITEM		 := c2rec.value;
       when 'GR_MESSAGE'	then lrec.GR_MESSAGE		 := c2rec.value;
       when 'GR_RCPT'		then lrec.GR_RCPT		 := c2rec.value;
       when 'INCOTERMS1'	then lrec.INCOTERMS1		 := c2rec.value;
       when 'INCOTERMS2'	then lrec.INCOTERMS2		 := c2rec.value;
       when 'ITEM_CAT'		then lrec.ITEM_CAT		 := c2rec.value;
       when 'IV_QTY_PO'		then lrec.IV_QTY_PO		 := c2rec.value;
       when 'MANUAL_GR'		then lrec.MANUAL_GR		 := c2rec.value;
       when 'MATERIAL'
	    then
		 if xtra.guess_number(c2rec.value) is null
		  then
		   lrec.MATERIAL		 := c2rec.value;
		  else
		   lrec.MATERIAL		 := to_char(xtra.guess_number(c2rec.value));
		 end if;
       when 'MATL_GROUP'	then lrec.MATL_GROUP		 := c2rec.value;
       when 'MINREMLIFE'	then lrec.MINREMLIFE		 := c2rec.value;
       when 'NET_PRICE'		then lrec.NET_PRICE		 := c2rec.value;
       when 'NET_WEIGHT'	then lrec.NET_WEIGHT		 := c2rec.value;
       when 'NO_MORE_GR'	then lrec.NO_MORE_GR		 := c2rec.value;
       when 'OPENQTY'		then lrec.OPENQTY		 := c2rec.value;
       when 'ORDERID'		then lrec.ORDERID		 := c2rec.value;
       when 'ORDERPR_UN'	then lrec.ORDERPR_UN		 := c2rec.value;
       when 'ORDERPR_UN_ISO'	then lrec.ORDERPR_UN_ISO	 := c2rec.value;
       when 'OUR_REF'		then lrec.OUR_REF		 := c2rec.value;
       when 'OVER_DLV_TOL'	then lrec.OVER_DLV_TOL		 := c2rec.value;
       when 'PCKG_NO'	   	then lrec.PCKG_NO		 := c2rec.value;
       when 'PERIOD_IND_EXPIRATION_DATE'
                                then lrec.PERIOD_IND_EXPIRATION_DATE := c2rec.value;
       when 'PLANT'		then lrec.PLANT			 := c2rec.value;
       when 'POSTL_CODE'	then lrec.POSTL_CODE		 := c2rec.value;
       when 'PO_PR_QNT'		then lrec.PO_PR_QNT		 := c2rec.value;
       when 'PO_UNIT'	   	then lrec.PO_UNIT		 := c2rec.value;
       when 'PO_UNIT_ISO'	then lrec.PO_UNIT_ISO		 := c2rec.value;
       when 'PREQ_ITEM'		then lrec.PREQ_ITEM		 := c2rec.value;
       when 'PREQ_NAME'		then lrec.PREQ_NAME		 := c2rec.value;
       when 'PREQ_NO'	   	then lrec.PREQ_NO		 := c2rec.value;
       when 'PRICE_UNIT'	then lrec.PRICE_UNIT		 := c2rec.value;
       when 'PURCH_ORG'		then lrec.PURCH_ORG		 := c2rec.value;
       when 'PUR_GROUP'		then lrec.PUR_GROUP		 := c2rec.value;
       when 'QUAL_INSP'		then lrec.QUAL_INSP		 := c2rec.value;
       when 'QUANTITY'		then lrec.QUANTITY		 := c2rec.value;
       when 'REGION'		then lrec.REGION		 := c2rec.value;
       when 'RET_ITEM'		then lrec.RET_ITEM		 := c2rec.value;
       when 'SALES_PERS'	then lrec.SALES_PERS		 := c2rec.value;
       when 'SC_VENDOR'		then lrec.SC_VENDOR		 := c2rec.value;
       when 'SHIPPING'		then lrec.SHIPPING		 := c2rec.value;
       when 'SHIPPING_TEXT'
	    then
		 lrec.SHIPPING_TEXT		 := replace(c2rec.value,'%20',' ');
       when 'SHIPTYPE'	   	then lrec.SHIPTYPE		 := c2rec.value;
       when 'SHORT_TEXT'	then lrec.SHORT_TEXT		 := c2rec.value;
       when 'STGE_LOC'	   	then lrec.STGE_LOC		 := c2rec.value;
       when 'STREET'		then lrec.STREET		 := c2rec.value;
       when 'SUPP_VENDOR'	then lrec.SUPP_VENDOR		 := c2rec.value;
       when 'TAX_CODE'	   	then lrec.TAX_CODE		 := c2rec.value;
       when 'TELEPHONE'		then lrec.TELEPHONE		 := c2rec.value;
       when 'TRACKINGNO'	then lrec.TRACKINGNO		 := c2rec.value;
       when 'UNDER_DLV_TOL'	then lrec.UNDER_DLV_TOL		 := c2rec.value;
       when 'UNLIMITED_DLV'	then lrec.UNLIMITED_DLV		 := c2rec.value;
       when 'UNLOAD_PT'		then lrec.UNLOAD_PT		 := c2rec.value;
       when 'VAL_TYPE'		then lrec.VAL_TYPE		 := c2rec.value;
       when 'VENDOR'
	    then
		 if xtra.guess_number(c2rec.value) is null
		  then
		   lrec.VENDOR		 := c2rec.value;
		  else
		   lrec.VENDOR	 := to_char(xtra.guess_number(c2rec.value));
		 end if;
       when 'VENDOR_TELEPHONE'	then lrec.VENDOR_TELEPHONE	 := c2rec.value;
       when 'VEND_MAT'		then lrec.VEND_MAT		 := c2rec.value;
       when 'VEND_NAME'		then lrec.VEND_NAME		 := c2rec.value;
       when 'VOLUME'		then lrec.VOLUME		 := c2rec.value;
       when 'VOLUMEUNIT_ISO'	then lrec.VOLUMEUNIT_ISO	 := c2rec.value;
       when 'WBS_ELEMENT'	then lrec.WBS_ELEMENT		 := c2rec.value;
       when 'WEIGHTUNIT_ISO'	then lrec.WEIGHTUNIT_ISO	 := c2rec.value;
      else
       null;
     end case;
    end loop;
    delete from strang.po_pool where PO_NUMBER = lrec.PO_NUMBER and PO_ITEM = lrec.PO_ITEM;
    -- How do we handle deletions from lookup table.  The interface1 pushes through deleted po records and these are shown when delete_ind is set to ?L?
    if nvl(lrec.DELETE_IND,'|') = 'L'
     then
      null;
     else
      insert into strang.po_pool values lrec;
    end if;
   end loop;
   commit;
   return( TRUE );
 exception
  when others then
   external_audit( '1', 'Failed strangw.push_to_strang', ctr, vld, sqlerrm );
   return( FALSE );
 end push_to_strang;

 function push_cust_strang(vld in integer)
  return boolean
 as

  cursor c1(vld integer) is select distinct row_id from csv_load where load_id = vld;
  cursor c2(vld integer, vrow integer, vcol varchar2) is select value from csv_load where load_id = vld and row_id = vrow and value2 = vcol;
  cursor c3(vcst integer) is select * from strang.customers where customer_id = vcst;

  crec	strang.customers%ROWTYPE;
  nrec	strang.customers%ROWTYPE;
  vdt	varchar2(1000);
  ctr	integer;
  vtxt	varchar2(4000);
  vfld	varchar2(100);
  vrw	integer;

  /*

  exec if strangw.push_cust_strang(6277625) then dbms_output.put_line('T'); end if;

  */

 begin
  -- push the data from csv_load to strang.lov
  /*
strang.customers
VENDOR=0004000413 - x ref if already in customer table
VEND_NAME=THE DENTAL CLINIC
add ADDRESS (xml attrib too be calculated)

xVENDOR customers.customer_id Vendor Account Number CHAR 10
xVEND_NAME customers.customer Name 1 CHAR 35
xSTREET customers.street House number and street CHAR 35
xDISTRICT customers.suburb District CHAR 35
xCITY customers.city City CHAR 35
xREGION customers.state Region (State, Province, County) CHAR 3
xPOSTL_CODE customers.postcode Postal Code CHAR 10
xCOUNTRYISO customers.country Country ISO code CHAR 2
xVENDOR_TELEPHONE customers.phone First telephone number CHAR16
*/

   ctr := 0;
   for c1rec in c1(vld) loop
    vrw := c1rec.row_id;
    crec := null;
    vfld := 'SUPPLIER';
    crec.customer_type := 'SUPPLIER';
    ctr := ctr + 1;
    vtxt := null;
    vfld := 'VENDOR';
    open c2(vld,c1rec.row_id,'VENDOR');
    fetch c2 into vtxt;
    close c2;
    crec.customer_id := substr(vtxt,1,10);

    vtxt := null;
    vfld := 'VEND_NAME';
    open c2(vld,c1rec.row_id,'VEND_NAME');
    fetch c2 into vtxt;
    close c2;
    crec.customer := substr(vtxt,1,35);

    vtxt := null;
    vfld := 'STREET';
    open c2(vld,c1rec.row_id,'STREET');
    fetch c2 into vtxt;
    close c2;
    crec.street := substr(vtxt,1,30);

    vtxt := null;
    vfld := 'DISTRICT';
    open c2(vld,c1rec.row_id,'DISTRICT');
    fetch c2 into vtxt;
    close c2;
    crec.suburb := substr(vtxt,1,30);

    vtxt := null;
    vfld := 'CITY';
    open c2(vld,c1rec.row_id,'CITY');
    fetch c2 into vtxt;
    close c2;
    crec.city := substr(vtxt,1,25);

    vtxt := null;
    vfld := 'REGION';
    open c2(vld,c1rec.row_id,'REGION');
    fetch c2 into vtxt;
    close c2;
    crec.state := substr(vtxt,1,3);

    vtxt := null;
    vfld := 'POSTL_CODE';
    open c2(vld,c1rec.row_id,'POSTL_CODE');
    fetch c2 into vtxt;
    close c2;
    crec.postcode := substr(vtxt,1,10);

    vtxt := null;
    vfld := 'COUNTRYISO';
    open c2(vld,c1rec.row_id,'COUNTRYISO');
    fetch c2 into vtxt;
    close c2;
    crec.country := substr(vtxt,1,2);

    vtxt := null;
    vfld := 'VENDOR_TELEPHONE';
    open c2(vld,c1rec.row_id,'VENDOR_TELEPHONE');
    fetch c2 into vtxt;
    close c2;
    crec.phone := substr(vtxt,1,16);

    if crec.customer_id is not null and crec.customer is not null
     then
      vfld := 'open c3';
      open c3(crec.customer_id);
      fetch c3 into nrec;
      if c3%FOUND
       then
        close c3;
        vfld := 'nrec';
        nrec.customer := crec.customer;
        nrec.street := crec.street;
        nrec.suburb := crec.suburb;
        nrec.city := crec.city;
        nrec.state := crec.state;
        nrec.postcode := crec.postcode;
        nrec.country := crec.country;
        nrec.phone := crec.phone;
        update strang.customers set row = nrec where customer_id = nrec.customer_id;
       else
        close c3;
        -- Customer doesn't exist
        if crec.customer_id is not null
          then
          vfld := 'insert2';
          insert into strang.customers values crec;
         else
          external_audit( '1', 'Unable to insert customer as ID is null', ctr, vld, crec.customer_id, crec.customer );
        end if;
      end if;
    end if;

   end loop;

   commit;
   return( TRUE );
 exception
  when others then
   external_audit( '1', 'Failed strangw.push_cust_strang', ctr, vld, crec.customer_id, crec.customer, sqlerrm, vrw, vfld );
   return( FALSE );
 end push_cust_strang;

 function push_material_strang(vld in integer)
  return boolean
 as

  cursor c1(vld integer) is select distinct row_id from csv_load where load_id = vld;
  cursor c2(vld integer, vrow integer, vcol varchar2) is select value from csv_load where load_id = vld and row_id = vrow and value2 = vcol;
  cursor c4(lname varchar2, vcd varchar2 ) is select 'x' exst from strang.lov where lov_name = lname and code = vcd;

  lrec	strang.lov%ROWTYPE;
  nrec	c4%ROWTYPE;
  vdt	varchar2(1000);
  ctr	integer;
  vtxt	varchar2(4000);

  /*
  exec if strangw.push_material_strang(6277625) then dbms_output.put_line('T'); end if;
  */

 begin
  -- push the data from csv_load to strang.lov
  /*
c. populate lov table
MATERIAL=000000000010000127 - exist in lov lov_name = inventory (if not exist should)
MATL_GROUP=colb

It inserts the following into lov where lov_name=?INVENT?, if there is no record where po_pool.material = lov.code.

MATERIAL lov.code where lov_name='INVENT' Material Number CHAR 18
SHORT_TEXT lov.description where lov_name='INVENT' and code = po_pool.material Short Text CHAR 40
MATL_GROUP lov.cold where lov_name-'INVENT'  and code = po_pool.material Material Group CHAR 9

*/
   ctr := 0;
   for c1rec in c1(vld) loop
    lrec := null;
    lrec.lov_name := 'INVENT';
    lrec.cole := vld;

    vtxt := null;
    open c2(vld,c1rec.row_id,'MATERIAL');
    fetch c2 into vtxt;
    close c2;
    lrec.code := substr(vtxt,1,18);
    
    if rtrim(ltrim(vtxt)) is null then
       continue;
    end if;

    vtxt := null;
    open c2(vld,c1rec.row_id,'SHORT_TEXT');
    fetch c2 into vtxt;
    close c2;
    lrec.description := substr(vtxt,1,40);

    vtxt := null;
    open c2(vld,c1rec.row_id,'MATL_GROUP');
    fetch c2 into vtxt;
    close c2;
    lrec.cold := substr(vtxt,1,9);

    open c4( 'INVENT', lrec.code );
    fetch c4 into nrec;
    if c4%NOTFOUND
     then
      close c4;
      insert into strang.lov values lrec;
     else
      close c4;
    end if;
   end loop;
   commit;
   return( TRUE );
 exception
  when others then
   external_audit( '1', 'Failed strangw.push_material_strang', ctr, vld, lrec.cola, lrec.colb, sqlerrm );
   return( FALSE );
 end push_material_strang;

 procedure batch_pos( vkey in varchar2 )
 as

  cursor c1(vname varchar2) is select * from apache_ows_content where name like vname order by last_updated,name;

  c1rec  	c1%ROWTYPE;
  crec		csv_load%ROWTYPE;
  clb           clob;
  p 		DBMS_XMLPARSER.parser;
  dest_offset   integer;
  src_offset    integer;
  lang_context  integer;
  warning       varchar2(1000);
  doc 		dbms_xmldom.DOMDocument;
  n 		dbms_xmldom.DOMNode;
  nl 		dbms_xmldom.DOMNodeList;
  e 		dbms_xmldom.DOMElement;
  n_child 	dbms_xmldom.DOMNode;
  tag		varchar2(1000);
  len1 		number;
  ctr		integer;
  cctr		integer;
  vld		integer;
  sz		integer;

 begin
  if trim(xtra.encrypt_pk('StrangKey', filler_only=>TRUE)) = vkey
   then
    null;
   else
    --xtra.dbg( 'Invalid Key for strang.batch_pos');
    return;
  end if;

  <<RESTART>>
  c1rec := null;
  open c1(g_name || '%');
  fetch c1 into c1rec;
  close c1;
  dbms_application_info.set_client_info( substr(to_char(systimestamp,'dd-mon-yyyy hh24:mi:ss.ff3') || '[A]' || c1rec.name || '[' || dbms_lob.getlength( c1rec.blob_content ) || ']',1,64) );
  if c1rec.name is null
   then
    return;
  end if;

   dbms_lob.createtemporary( clb, FALSE );
   p := DBMS_XMLPARSER.newParser;
   DBMS_XMLPARSER.setValidationMode(p, FALSE);

   dest_offset := 1;
   src_offset := 1;
   lang_context := 0;
   dbms_lob.converttoclob( clb, c1rec.blob_content, dbms_lob.getlength( c1rec.blob_content ), dest_offset, src_offset, 0, lang_context, warning );

   sz := dbms_lob.getlength(clb);
   DBMS_XMLPARSER.parseClob(p, clb );
   doc := DBMS_XMLPARSER.getDocument(p);
   nl := dbms_xmldom.getElementsByTagName(doc, '*');
   len1 := dbms_xmldom.getLength(nl);

   select s_dir_results.nextval into vld from dual;
   crec.load_id := vld;
   ctr := 0;
   cctr := 0;

   for j in 0..len1-1 loop
    n := dbms_xmldom.item(nl, j);
    e := dbms_xmldom.makeElement(n);
    n_child:= dbms_xmldom.getFirstChild(n);
    tag := dbms_xmldom.getTagName(e);
    if tag = 'item'
     then
      commit;
      -- if ctr > 1 then htp.p( '</item>' ); end if;
      cctr := cctr + 1;
      crec.col_id := cctr;
      crec.row_id := ctr;
      crec.value2 := 'TIMESTAMP';
      crec.value := systimestamp;
      insert into csv_load values crec;
      ctr := ctr + 1;
      cctr := 0;
    elsif tag <> 'item'
     then
      -- htp.p( '<column name="' || tag || '" length="' || length(dbms_xmldom.getNodeValue(n_child)) || '"/>' );
      crec.value2 := tag;
      crec.value := dbms_xmldom.getNodeValue(n_child);
    end if;

    -- Process data
    cctr := cctr + 1;
    crec.col_id := cctr;
    crec.row_id := ctr;
    insert into csv_load values crec;
    -- End Process
   end loop;

   begin dbms_lob.freetemporary(clb); exception when others then null; end;

   --
   -- With XE need to cull
   --
  commit;
  delete from csv_load where load_id < (crec.load_id - 100);
  commit;

  dbms_application_info.set_client_info( substr(to_char(systimestamp,'dd-mon-yyyy hh24:mi:ss.ff3') || c1rec.name || '[DBPos]',1,64) );
  delete from apache_ows_content where name = c1rec.name;
  commit;
  dbms_application_info.set_client_info( substr(to_char(systimestamp,'dd-mon-yyyy hh24:mi:ss.ff3') || c1rec.name || '[p1][' || vld || ']',1,64) );
  if push_to_strang(vld) then null; end if;
  dbms_application_info.set_client_info( substr(to_char(systimestamp,'dd-mon-yyyy hh24:mi:ss.ff3') || c1rec.name || '[p2][' || vld || ']',1,64) );
  if push_cust_strang(vld) then null; end if;
  dbms_application_info.set_client_info( substr(to_char(systimestamp,'dd-mon-yyyy hh24:mi:ss.ff3') || c1rec.name || '[p3][' || vld || ']',1,64) );
  if push_material_strang(vld) then null; end if;
  dbms_application_info.set_client_info( substr(to_char(systimestamp,'dd-mon-yyyy hh24:mi:ss.ff3') || c1rec.name || '[p4][' || vld || ']',1,64) );
  external_audit( '1', 'Received', ctr, sz );
  -- Check if there are any more items on the queue to process
  goto RESTART;

 exception
  when others then
   external_audit( '1', 'Failed strangw.batch_pos:' || c1rec.name, ctr, sz, sqlerrm );
 end batch_pos;

/*
Interface1:

d.
MANUAL_GR=
(critical)
PO_UNIT=Purchase Order Unit of Measure
add to pos grn_item type integer
*/

 procedure transaction_interface3(pk1 in number, pk2 in number, val1 in number, val2 in number, ctr in integer, sz in integer)
 as
 begin
/*
when interface3 updates a po records' grn and grn_item fields, can you update grn_status:='9' and set grn_status to read-=only.

 if grn is not null and grn_item is not null then
   grn_status := '9';
 end if;

When the grn details are returned in interface3, the system upates pos.grn_status to 9 and update pos.off_site_receipt to sysdate.
*/
  commit;
  update strang.pos
   set
    grn = val1,
    grn_item = val2
  where
   deliveryno = pk1 and
   recno = pk2;
  if sql%rowcount = 0
   then
    external_audit( '3', 'Failed to find', pk1, pk2, val1, val2, ctr, sz);
   else
    if val1 is not null and val2 is not null
     then
      update strang.pos set grn_status = 9, off_site_receipt = sysdate where deliveryno = pk1 and recno = pk2;
    end if;
    commit;
    external_audit( '3', 'Processed Successfully', pk1, pk2, val1, val2, ctr, sz);
  end if;

  /*
    <DELIVERYNO>511211</DELIVERYNO> receivals.deliveryno pk1
    <RECNO>00030</RECNO> pos.recno pk2
     <GRN>
     <GRNITEMNO>
  */
 exception
  when others then
   external_audit( '3', 'Failed:' || pk1, pk2, val1, val2, ctr, sz, sqlerrm );
 end transaction_interface3;

 procedure process_interface3( x in owa.vc_arr, y in owa.vc_arr, fname in varchar )
 as

  cursor c1(fnm varchar2) is select * from apache_ows_content where name = fnm;
  cursor c2(jname varchar2) is select * from user_scheduler_jobs where job_name like jname;


  c1rec 	c1%ROWTYPE;
  c2rec		c2%ROWTYPE;
  clb           clob;
  p 		DBMS_XMLPARSER.parser;
  dest_offset   integer;
  src_offset    integer;
  lang_context  integer;
  warning       varchar2(1000);
  doc 		dbms_xmldom.DOMDocument;
  n 		dbms_xmldom.DOMNode;
  nl 		dbms_xmldom.DOMNodeList;
  e 		dbms_xmldom.DOMElement;
  n_child 	dbms_xmldom.DOMNode;
  tag		varchar2(1000);
  len1 		number;
  ctr		integer;
  jname		varchar2(100);
  verr		varchar2(4000);
  pk1		varchar2(100);
  pk2		varchar2(100);
  val1		varchar2(100);
  val2		varchar2(100);
  sz		integer;

 begin
   open c1( fname );
   fetch c1 into c1rec;
   close c1;
   if c1rec.mime_type <> 'text/xml'
    then
     cleanup(fname,TRUE);
     err( '[1046] File is not XML (mimetype not text/xml)', 404, TRUE);
     return;
   end if;

   dbms_lob.createtemporary( clb, FALSE );
   p := DBMS_XMLPARSER.newParser;
   DBMS_XMLPARSER.setValidationMode(p, FALSE);

   dest_offset := 1;
   src_offset := 1;
   lang_context := 0;
   dbms_lob.converttoclob( clb, c1rec.blob_content, dbms_lob.getlength( c1rec.blob_content ), dest_offset, src_offset, 0, lang_context, warning );
   sz := dbms_lob.getlength(clb);

   DBMS_XMLPARSER.parseClob(p, clb );
   doc := DBMS_XMLPARSER.getDocument(p);

   htp.init;
   owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
   htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
   owa_util.http_header_close;

    nl := dbms_xmldom.getElementsByTagName(doc, '*');
    len1 := dbms_xmldom.getLength(nl);
    ctr := 0;

    for j in 0..len1-1 loop
     n := dbms_xmldom.item(nl, j);
     e := dbms_xmldom.makeElement(n);
     n_child:= dbms_xmldom.getFirstChild(n);
     tag := upper(trim(dbms_xmldom.getTagName(e)));
     if tag = 'item'
      then
       ctr := ctr + 1;
      else
       case tag
        when 'DELIVERYNO' then pk1  := xtra.guess_number(dbms_xmldom.getNodeValue(n_child));
        when 'RECNO'      then pk2  := xtra.guess_number(dbms_xmldom.getNodeValue(n_child));
        when 'GRN'        then val1 := xtra.guess_number(dbms_xmldom.getNodeValue(n_child));
        when 'GRNITEMNO'
         then
          val2 := xtra.guess_number(dbms_xmldom.getNodeValue(n_child));
          transaction_interface3(pk1,pk2,val1,val2,ctr,sz);
          pk1 := null;
          pk2 := null;
          val1 := null;
          val2 := null;
        else null;
       end case;

     end if;
    end loop;

   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
   htp.p( '<result>XML File pushed</result>');

 exception
  when others then
   verr := sqlerrm;
   err( '[1100] Err in process_grn:' || verr, 404, TRUE);
   external_audit( '3', 'Failed:' || c1rec.name, ctr, sz, sqlerrm );
   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
 end process_interface3;

 /*











 */
 procedure transaction_interface5a(pk1 in varchar2, pk2 in varchar2, val1 in number, val2 in number, val3 in number, val4 in varchar2 default null, ctr in integer, sz in integer, msg in out varchar2)
 as
 
 e_Complex_part_shipment EXCEPTION;
 e_Delivery_item_unavailable EXCEPTION;
 cursor c1 (pk1 varchar2, pk2 varchar2, val1 number, val2 number) is
              select count(*) tot, sum(case when di.movement_no = pk1 and nvl(di.seal,'|') = nvl(pk2,'|') then 1 else 0 end) packed_tot
                from strang.detailrs_item di 
               where di.deliveryno = val1 
                 and di.item_no = val2
                 and exists (select 'x' 
                               from strang.detailrs dr
                              where di.deliveryno = dr.deliveryno
                                and di.item_no = dr.itemno
                                and dr.sa = 'S');
 
 cursor c2( mv varchar2, sl varchar2, dlvy number, itm number) is
  select deliveryno, item_no, order_by, di.movement_no, di.seal
   from strang.detailrs_item di
  where di.deliveryno = dlvy
   and  di.item_no = itm
  -- and  di.order_by = v_order_by
   and (di.movement_no is not null and  di.movement_no <> mv)
   and exists (select 'x'
                  from strang.detailrs_item di1
                 where di1.movement_no = mv
                   and nvl(di1.seal,'|') = nvl(sl,'|')
                   and di1.deliveryno = di.deliveryno
              --     and di1.order_by = di.order_by 
                   and di1.item_no = di.item_no);
                   
 cursor c3( mv varchar2, sl varchar2) is
  select deliveryno, item_no, order_by, di.movement_no, di.seal
   from strang.detailrs_item di
   where movement_no is not null
    and  movement_no <> mv
    and exists (select 'x'
                  from strang.detailrs_item di1
                 where di1.movement_no = mv
                   and nvl(di1.seal,'|') = nvl(sl,'|')
                   and di1.deliveryno = di.deliveryno
                   and di1.item_no = di.item_no);      
                   
  cursor c4( dlvy number) is
    select count(distinct movement_no) cnt
     from  strang.detailrs_item dr
    where  deliveryno = dlvy;

 cursor c5( mv varchar2, sl varchar2, dlvy number, itm number) is
  select deliveryno, item_no, order_by, di.movement_no, di.seal
   from strang.detailrs_item di
  where di.deliveryno = dlvy
   and  di.item_no =  itm
   and (di.movement_no = mv and nvl(di.SEAL, '|') = nvl(sl, '|') )
   and exists (select 'x'
                  from strang.detailrs_item di1
                 where di1.movement_no <> mv
                   and di1.deliveryno = di.deliveryno) 
   and exists (select 1
                from strang.detailrs_item di2
                where di2.movement_no <> mv
                  and di2.deliveryno = di.deliveryno
                  and exists (select 1
                                from strang.detailrs_item di3
                               where  di3.movement_no = di2.movement_no
                                 and  nvl(di3.seal,'xxx') = nvl(di2.seal,'xxx')
                                 and  di3.deliveryno = di2.deliveryno
                                 and  exists (select 1
                                               from strang.detailrs_item di4
                                               where di4.deliveryno = di3.deliveryno 
                                                 and di4.movement_no <> di.movement_no
                                                 and  di4.movement_no <> mv )));                   
                                                                                                 
 c1rec c1%rowtype;
 c2rec c2%rowtype;
 c3rec c3%rowtype;
 c4rec c4%rowtype;
 c5rec c5%rowtype;
 
 begin
 
/*
When the movement_no, Seal, deliveryno and item details are returned in interface5, the system updates the Detailrs table with movement_no and seal number for the corresponding deliveryno and itemno.
*/

 open c1(pk1, pk2, val1, val2);
 fetch c1 into c1rec;
   
  if c1%found and c1rec.tot <> 0 then    
     update strang.detailrs_item di
       set movement_no = pk1,
           seal = pk2,
           modified_by = val4,
           modified_date  = sysdate,
           packed_date = sysdate,
           packed_by = val4
     where di.deliveryno = val1 
       and di.item_no = val2
       and di.order_by = val3
       and di.smp_no is null
       and exists (select 'x'
                     from strang.movements m
                    where m.movement_no = pk1
                      and nvl(m.seal,'|') = nvl(pk2,'|')
                      and m.movement_type = 'CARGO'
                      and nvl(m.full_mt, 'FULL') <> 'EMPTY'
                      and strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) not in ( 'ARCHIVED', 'READ-ONLY', 'SHIPPED'));
  
     if sql%rowcount <> 0
     then
        external_audit( '5', 'transaction_interface5a (Delivery Unit Added to Container): Processed Successfully', pk1, pk2, val1, val2, val3, ctr, sz);
     else 
        external_audit( '5', 'transaction_interface5a (Delivery Unit Added to Container): Failed to find delivery unit', pk1, pk2, val1, val2, val3, ctr, sz);
        msg := 'Error: Delivery no: '||val1||' Item: '||val2|| ' Unit: '||val3|| ' not found.';
        raise e_Delivery_item_unavailable;
        return; -- David start here
     end if;  
  else
      external_audit( '5', 'transaction_interface5a (Delivery Unit Added to Container): Failed to find delivery unit', pk1, pk2, val1, val2, val3, ctr, sz);
      close c1;
      msg := 'Error: Delivery no: '||val1||' Item: '||val2|| ' Unit: '||val3|| ' not found.';
      raise e_Delivery_item_unavailable;
      return; -- David start here 
  end if;
  close c1;
  
  -- Added by David Banjo 3/12/2021
   open c3 (pk1, nvl(pk2,'|'));
   fetch c3 into c3rec;
   if c3%found then 
      close c3;
      rollback;
      external_audit('5', 'transaction_interface5a ( Delivery Unit Added to Container): Delivery item already assigned to '||c3rec.movement_no, pk1, pk2, val1, ctr, sz);
      msg := 'Delivery item '||c3rec.deliveryno||'-'||c3rec.item_no||' already assigned to '||c3rec.movement_no;
      return;
   end if;
   close c3;  
  
  commit;
  
  open c2 (pk1, nvl(pk2,'|'), val1, val2);
  fetch c2 into c2rec;
  if c2%found then 
     close c2;
          
     update strang.detailrs_item di
       set movement_no = null,
           seal = null,
           modified_by = val4,
           modified_date  = sysdate,
           packed_date = null,
           packed_by = null
     where di.deliveryno = val1 
       and di.item_no = val2
       and di.order_by = val3
       and di.smp_no is null;
       commit;

     external_audit( '5', 'transaction_interface5a (Delivery Unit Added to Container): delivery unit already assigned to '||c2rec.movement_no, pk1, pk2, val1, val2, val3, ctr, sz);
     msg := 'delivery unit already assigned to '||c2rec.movement_no;
     return;
  end if;
  close c2;
  commit;
  
  open c1(pk1, pk2, val1, val2);
  fetch c1 into c1rec;
  
  if c1%found and c1rec.tot = c1rec.packed_tot then
     update strang.detailrs dr
       set movement_no = pk1,
           camov_seal = pk2,
           modified_by = val4,
           date_modified = sysdate
     where dr.deliveryno = val1 
       and dr.itemno = val2
       and exists (select 'x'
                     from strang.movements m
                    where m.movement_no = pk1
                      and nvl(m.seal,'|') = nvl(pk2,'|')
                      and m.movement_type = 'CARGO'
                      and nvl(m.full_mt, 'FULL') <> 'EMPTY'
                      and strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) not in ( 'ARCHIVED', 'READ-ONLY', 'SHIPPED'));
   End if; 
   close c1;
   commit;
  
   open c4(val1);
   fetch c4 into c4rec;
   close c4;
   
   if c4rec.cnt > 1 then
     
      open c5( pk1, pk2, val1, val2);
      fetch c5 into c5rec;
      if c5%found then 
       -- close c5; 
        msg := 'Warning: Delivery no: '||val1||' Item: '||val2|| ' added to '||pk1||' results in a complex Part Shipment!';
        --raise e_Complex_part_shipment;
        err( '[1044] '||msg, 505, TRUE);
        msg := null;
       -- return;
      end if;
      close c5;

   end if;






  /*
    <CONTAINER_NO>OTMU2507062</CONTAINER_NO> movements.movement_no pk1
    <CONTAINER_SEAL>OTMU2507062</CONTAINER_SEAL> movements.seal pk2
    <DELIVERYNO>00030</DELIVERYNO> detailrs.deliveryno val1
    <ITEMNO>1</ITEMNO> detailrs.itemno val2
  */
 exception
  when others then
   external_audit( '5', 'Transaction interface5a (Delivery Unit Added to Container) Failed :' || pk1, pk2, val1, val2, val3, ctr, sz, sqlerrm );
 end transaction_interface5a;
 procedure transaction_interface5b(pk1 in varchar2, pk2 in varchar2, val1 in number, val2 in number, val3 in varchar2, val4 in varchar2 default null,  ctr in integer, sz in integer, msg in out varchar2)
 as
 
  cursor c1 (pk1 varchar2, pk2 varchar2) is select movement_no, seal, complete 
                                 from strang.movements m
                                where m.movement_no = pk1
                                  and nvl(m.seal,'|') = nvl(pk2,'|')
                                  and nvl(m.complete,'F') not in ('F');
 
  c1rec c1%rowtype;
 
 
 begin
/*
When the movement_no, Seal, deliveryno and item details are returned in interface5, the system updates the Detailrs table with movement_no and seal number for the corresponding deliveryno and itemno.
*/
  open c1(pk1,pk2);
  fetch c1 into c1rec;
  
  if c1%found then
     close c1;
     external_audit( '5', 'transaction_interface5b (Delivery Unit Removed from Container): Failed - Movement no: '||pk1||' Seal: '||pk2||' is not INCOMPLETE!', pk1,  pk2, val1, val2, val3, ctr, sz);
     msg := 'Error: Movement no: '||pk1||' Seal: '||pk2||' is not INCOMPLETE!';
     return;
  end if;
  close c1;


  update strang.detailrs dr
   set movement_no = null,
       camov_seal = null,
       modified_by = val4,
       date_modified = sysdate
  where dr.deliveryno = val1 
    and dr.itemno = val2
    and dr.smp_no is null
    and exists (select 'x'
                from strang.movements m
               where m.movement_no = pk1
                 and nvl(m.seal,'|') = nvl(pk2,'|')
                 and m.movement_type = 'CARGO'
                 and nvl(m.full_mt, 'FULL') <> 'EMPTY'
                 and strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) not in ( 'ARCHIVED', 'READ-ONLY', 'SHIPPED'));
                 
   update strang.detailrs_item di
   set movement_no = null,
       seal = null,
       modified_by = val4,
       modified_date = sysdate,
       packed_date = null,
       packed_by = null
  where di.deliveryno = val1 
    and di.item_no = val2
    and di.order_by = val3
    and di.smp_no is null
    and exists (select 'x'
                from strang.movements m
               where m.movement_no = pk1
                 and nvl(m.seal,'|') = nvl(pk2,'|')
                 and m.movement_type = 'CARGO'
                 and nvl(m.full_mt,'FULL') <> 'EMPTY'
                 and strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) not in ( 'ARCHIVED', 'READ-ONLY', 'SHIPPED'));              
                   
  if sql%rowcount = 0
   then
    external_audit( '5', 'transaction_interface5b (Delivery Unit Removed from Container): Failed to find delivery unit', pk1, pk2, val1, val2, val3, ctr, sz);
   else
    external_audit( '5', 'transaction_interface5b (Delivery Unit Removed from Container): Processed Successfully', pk1, pk2, val1, val2, val3, ctr, sz);
  end if;
  commit;

  /*
    <CONTAINER_NO>OTMU2507062</CONTAINER_NO> movements.movement_no pk1
    <CONTAINER_SEAL>OTMU2507062</CONTAINER_SEAL> movements.seal pk2
    <DELIVERYNO>00030</DELIVERYNO> detailrs.deliveryno val1
    <ITEMNO>1</ITEMNO> detailrs.itemno val2
  */
  
 exception
  when others then
   external_audit( '5', 'transaction_interface5b (Delivery Unit Removed from Container) Failed:' || pk1, pk2, val1, val2, val3, ctr, sz, sqlerrm );
 end transaction_interface5b;
 
 procedure process_interface5( x in owa.vc_arr, y in owa.vc_arr, fname in varchar )
 as

  cursor c1(fnm varchar2) is select * from apache_ows_content where name = fnm;
  cursor c2(jname varchar2) is select * from user_scheduler_jobs where job_name like jname;
  
  cursor c3( vmovid varchar2, vseal varchar2) is select m.rowid as rid, movement_no, seal, container_type, movement_type, io from strang.movements m where m.movement_no = vmovid and nvl(m.seal,'|') = nvl(vseal,'|') ;

  c1rec 	c1%ROWTYPE; 
  c2rec		c2%ROWTYPE;
  c3rec		c3%ROWTYPE;
  clb           clob;
  p 		DBMS_XMLPARSER.parser;
  dest_offset   integer;
  src_offset    integer;
  lang_context  integer;
  warning       varchar2(1000);
  doc 		dbms_xmldom.DOMDocument;
  n 		dbms_xmldom.DOMNode;
  nl 		dbms_xmldom.DOMNodeList;
  e 		dbms_xmldom.DOMElement;
  n_child 	dbms_xmldom.DOMNode;
  tag		varchar2(1000);
  len1 		number;
  ctr		integer;
  vaction   varchar2(100);
  jname		varchar2(100);
  verr		varchar2(4000);
  pk1		varchar2(100);
  pk2		varchar2(100);
  val1		number;
  val2		number;
  val3		number;
  val4		varchar2(100);
  sz		integer;
  msg       varchar2(200);

 begin
 
   open c1( fname );
   fetch c1 into c1rec;
   close c1;
   if c1rec.mime_type <> 'text/xml'
    then
     cleanup(fname,TRUE);
     err( '[1046] File is not XML (mimetype not text/xml)', 404, TRUE);
     return;
   end if;

   dbms_lob.createtemporary( clb, FALSE );
   p := DBMS_XMLPARSER.newParser;
   DBMS_XMLPARSER.setValidationMode(p, FALSE);

   dest_offset := 1;
   src_offset := 1;
   lang_context := 0;
   dbms_lob.converttoclob( clb, c1rec.blob_content, dbms_lob.getlength( c1rec.blob_content ), dest_offset, src_offset, 0, lang_context, warning );
 
   sz := dbms_lob.getlength(clb);

   DBMS_XMLPARSER.parseClob(p, clb );
   doc := DBMS_XMLPARSER.getDocument(p);

   htp.init;
   owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
   htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
   owa_util.http_header_close;

    nl := dbms_xmldom.getElementsByTagName(doc, '*');
    len1 := dbms_xmldom.getLength(nl);
    ctr := 0;

    for j in 0..len1-1 loop
     n := dbms_xmldom.item(nl, j);
     e := dbms_xmldom.makeElement(n);
     n_child:= dbms_xmldom.getFirstChild(n);
     tag := upper(trim(dbms_xmldom.getTagName(e)));
     
     if tag in ('ADD_ITEMS', 'REMOVE_ITEMS')
      then
       ctr := ctr + 1;
       dbms_output.put_line('ctr = '||ctr);
       vaction := tag;
      else
       case tag
        when 'CONTAINER_NO' then pk1  := dbms_xmldom.getNodeValue(n_child);
        when 'CONTAINER_SEAL' then pk2  := dbms_xmldom.getNodeValue(n_child);
        when 'UPDATED_BY' then val4  := dbms_xmldom.getNodeValue(n_child);
        when 'DELIVERY_NO'  then  val1:= null; val1 := xtra.guess_number(dbms_xmldom.getNodeValue(n_child));
     -- Modified by David Banjo 15/3/2021
        when 'ITEM_NO' then val2 := null; val2 :=  xtra.guess_number(dbms_xmldom.getNodeValue(n_child));
        -- val2 := xtra.guess_number(dbms_xmldom.getNodeValue(n_child));
        when 'UNIT_NO' then val3 := null; val3 := xtra.guess_number(dbms_xmldom.getNodeValue(n_child));

          if vaction = 'ADD_ITEMS' then
             transaction_interface5a (pk1, pk2, val1, val2, val3, val4, ctr, sz, msg);
             if msg is not null then
                err( '[1046] '||msg, 404, TRUE);
                return;
             end if;
          elsif vaction = 'REMOVE_ITEMS' then
             transaction_interface5b (pk1, pk2, val1, val2, val3, val4, ctr, sz, msg);
             if msg is not null then
                err( '[1046] '||msg, 404, TRUE);
                return;
             end if;
          end if;
          
          val3 := null;
        else null;
       end case;

     end if;
    end loop;
    
    open c3(pk1, pk2 );
    fetch c3 into c3rec;
    
    if c3%found then
     websys.strangp.recalc_weight(  c3rec.movement_no, c3rec.container_type, c3rec.seal, c3rec.movement_type, c3rec.rid );
    end if;
    
    close c3;
    
   delete from strang.hawbs
   where
    mawb = pk1 and
     hawb not in
    (select hawb_hawbno from strang.detailrs where movement_no = pk1);

   commit;

   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
   
   if msg is null then
      htp.p( '<result>XML File pushed</result>');
   else
      htp.p( '<result>'||msg||'</result>');
   end if;
   
  -- htp.p( '<result>XML File pushed</result>');

 exception
  when others then
   verr := sqlerrm;
   err( '[1100] Err in process_dnupd:'||' pk1 '|| pk1||' pk2 '|| pk2||' val1 '|| val1||' val2 '|| val2||' val3 '|| val3||' '||' val4 '|| val4||' '|| verr, 404, TRUE);
   external_audit( '5', 'process_interface5 (Process Delivery Unit in Containers) Failed:' || c1rec.name, ctr, sz, sqlerrm );
   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
 end process_interface5;
 -----------------------------------------------------------------------------------------------------------------------------------------------------------
 procedure transaction_interface6a(pk1 in varchar2, val1 in number, val2 in number, val3 in number, val4 in varchar2 default null, ctr in integer, sz in integer, msg in out varchar2)
 as
 
 cursor c1 (pk1 varchar2, val1 number, val2 number) is
              select count(*) tot, sum(case when nvl(di.smp_no,'##') = pk1 then 1 else 0 end) packed_tot
                from strang.detailrs_item di 
               where di.deliveryno = val1 
                 and di.item_no = val2;
                               
                 
 cursor c2 (pk1 varchar2 ) is select smp_no, movement_no, seal, sa from strang.smp where smp_no = pk1;
 cursor c3 (v1 varchar2, v2 varchar2) is select deliveryno, itemno, sa from strang.detailrs where deliveryno = v1 and itemno = v2;  
 cursor c4 (v1 varchar2, v2 varchar2, v3 varchar2) is select deliveryno, item_no, order_by, smp_no from strang.detailrs_item where deliveryno = v1 and item_no = v2 and order_by = v3;    
              
 c1rec c1%rowtype;
 c1arec c1%rowtype;
 c2rec c2%rowtype;
 c3rec c3%rowtype;
 c4rec c4%rowtype;

 begin
 
/*
When the movement_no, Seal, deliveryno and item details are returned in interface5, the system updates the Detailrs table with movement_no and seal number for the corresponding deliveryno and itemno.
*/

 open c2(pk1);
 fetch c2 into c2rec;
 close c2;

 open c3(val1, val2);
 fetch c3 into c3rec;
 close c3;
 
 if c2rec.sa <> c3rec.sa and c2rec.sa = 'S' then
     external_audit( '6', 'transaction_interface6a (Add Delivery Unit to SMP): Failed - Delivery no: '||val1||' Item: '||val2|| ' delivery Mode is AIR', pk1, val1, val2, val3, ctr, sz);
     msg := 'Error: Deliveryno: '||val1||' Itemno: '||val2|| ' Delivery Mode is AIR but '||c2rec.smp_no||' relates to SEA freight';
     return;
 elsif c2rec.sa <> c3rec.sa and c2rec.sa = 'A' then
     external_audit( '6', 'transaction_interface6a (Add Delivery Unit to SMP): Failed - Delivery no: '||val1||' Item: '||val2|| ' delivery Mode is SEA', pk1, val1, val2, val3, ctr, sz);
     msg := 'Error: Deliveryno: '||val1||' Itemno: '||val2|| ' Delivery Mode is SEA but '||c2rec.smp_no||' relates to AIR freight';
     return;
 end if;

 open c4(val1, val2, val3);
 fetch c4 into c4rec;
 close c4;
 
 if c4rec.smp_no is not null then
     external_audit( '6', 'transaction_interface6a (Add Delivery Unit to SMP): Failed - Delivery no: '||val1||' Item: '||val2||' Unit: '||val3||' is already in '||c4rec.smp_no, pk1, val1, val2, val3, ctr, sz);
     msg := 'Error: Deliveryno: '||val1||' Itemno: '||val2||' Unit: '||val3||' is already in '||c4rec.smp_no;
     return;
 end if;



 open c1(pk1, val1, val2);
 fetch c1 into c1rec;
  
  if c1%found and c1rec.tot <> 0 then   
     update strang.detailrs_item di
       set smp_no = pk1,
           modified_by = val4,
           modified_date = sysdate,
           packed_by = val4,
           packed_date = sysdate,
           movement_no = c2rec.movement_no,
           seal = c2rec.seal
     where di.deliveryno = val1 
       and di.item_no = val2
       and di.order_by = val3
       and exists (select 'x'
                     from strang.smp sm
                    where sm.smp_no = pk1
                   --   and sm.sa = 'S'
                      and strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',sm.complete) not in ( 'ARCHIVED', 'READ-ONLY', 'SHIPPED'));
  
     if sql%rowcount <> 0 then
        external_audit( '6', 'transaction_interface6a (Add Delivery Unit to SMP): Processed Successfully', pk1, val1, val2, val3, ctr, sz);
     else
        external_audit( '6', 'transaction_interface6a (Add Delivery Unit to SMP): Failed to find delivery item package unit ', pk1, val1, val2, val3, ctr, sz);
        msg := 'Error: Delivery no: '||val1||' Item: '||val2|| ' Unit: '||val3||' Can not be found!';
        return;
     end if;  
  else
      external_audit( '6', 'transaction_interface6a (Add Delivery Unit to SMP): Failed to find delivery item package unit ', pk1, val1, val2, val3, ctr, sz);
      msg := 'Error: Delivery no: '||val1||' Item: '||val2|| ' Unit: '||val3||' Can not be found!';
      return;
  end if;
  
  close c1;
  commit;

  open c1(pk1, val1, val2);
  fetch c1 into c1arec;
  
 if c1%found and c1arec.tot = c1arec.packed_tot then
 ---- if c1%found then
    update strang.detailrs dr
       set smp_no = pk1,
           movement_no = c2rec.movement_no,
           camov_seal = c2rec.seal,
           modified_by = val4,
           date_modified = sysdate
     where dr.deliveryno = val1 
       and dr.itemno = val2
       and not exists (select 1
                         from strang.detailrs_item di
                        where di.deliveryno = dr.deliveryno
                          and di.item_no = dr.itemno
                          and di.smp_no is null) 
       and exists (select 'x'
                     from strang.smp sm
                    where sm.smp_no = pk1
                      and nvl(sm.sa,'S') in ( 'S', 'A')
                      and strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',sm.complete) not in ( 'ARCHIVED', 'READ-ONLY', 'SHIPPED'));
  End if; 
 
 -- close c1;
  
  commit;

  
 exception
  when others then
   external_audit( '6', 'transaction_interface6a (Add Delivery Unit to SMP) Failed:' || pk1, val1, val2, val3, ctr, sz, sqlerrm );
 end transaction_interface6a;
 procedure transaction_interface6b(pk1 in varchar2, val1 in number, val2 in number, val3 in number, val4 in varchar2 default null, ctr in integer, sz in integer, msg in out varchar2)
 as
 
   cursor c1 (pk1 varchar2 ) is select smp_no, movement_no, seal, sa, complete 
                                 from strang.smp 
                                where smp_no = pk1
                                  and nvl(complete,'F') not in ('F');
 
   c1rec c1%rowtype;
 
 begin
/*
When the movement_no, Seal, deliveryno and item details are returned in interface5, the system updates the Detailrs table with movement_no and seal number for the corresponding deliveryno and itemno.
*/

  open c1(pk1);
  fetch c1 into c1rec;
  
  if c1%found then
     close c1;
     external_audit( '6', 'transaction_interface6b (Remove Delivery Unit from SMP): Failed - SMP no: '||pk1||' is not INCOMPLETE!', pk1, val1, val2, val3, ctr, sz);
     msg := 'Error: SMP no: '||pk1||' is not INCOMPLETE!';
     return;
  end if;
  close c1;

  update strang.detailrs dr
     set smp_no = null,
         movement_no = null,
         camov_seal = null,
         modified_by = val4,
         date_modified = sysdate
  where dr.deliveryno = val1 
    and dr.itemno = val2
    and exists (select 'x'
                from strang.smp sm
               where sm.smp_no = pk1
                 and strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',sm.complete) not in ( 'ARCHIVED', 'READ-ONLY', 'SHIPPED'));
                 
   update strang.detailrs_item di
   set smp_no = null,
       movement_no = null,
       seal = null,
       modified_by = val4,
       modified_date = sysdate,
       packed_by = null,
       packed_date = null
  where di.deliveryno = val1 
    and di.item_no = val2
    and di.order_by = val3
    and exists (select 'x'
                from strang.smp sm
               where sm.smp_no = pk1
                 and strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',sm.complete) not in ( 'ARCHIVED', 'READ-ONLY', 'SHIPPED'));              
                   
  if sql%rowcount = 0
   then
    external_audit( '6', 'transaction_interface6b (Remove Delivery Unit from SMP): Failed to find delivery package unit', pk1, val1, val2, val3, ctr, sz);
   else
    external_audit( '6', 'transaction_interface6b (Remove Delivery Unit from SMP): Processed Successfully', pk1, val1, val2, val3, ctr, sz);
  end if;
  commit;
  
 exception
  when others then
   external_audit( '6', 'transaction_interface6b (Remove Delivery Unit from SMP): Failed:' || pk1, val1, val2, val3, ctr, sz, sqlerrm );
 end transaction_interface6b;
 
 procedure process_interface6( x in owa.vc_arr, y in owa.vc_arr, fname in varchar )
 as
 
  cursor c1(fnm varchar2) is select * from stx1.apache_ows_content where name = fnm;
  cursor c2(jname varchar2) is select * from user_scheduler_jobs where job_name like jname;
  cursor c3(vsmpno varchar2 ) is select sm.rowid rid from strang.smp sm where sm.smp_no = vsmpno;


  c1rec 	c1%ROWTYPE;
  c2rec		c2%ROWTYPE;
  c3rec		c3%ROWTYPE;
  clb           clob;
  p 		DBMS_XMLPARSER.parser;
  dest_offset   integer;
  src_offset    integer;
  lang_context  integer;
  warning       varchar2(1000);
  doc 		dbms_xmldom.DOMDocument;
  n 		dbms_xmldom.DOMNode;
  nl 		dbms_xmldom.DOMNodeList;
  e 		dbms_xmldom.DOMElement;
  n_child 	dbms_xmldom.DOMNode;
  tag		varchar2(1000);
  len1 		number;
  ctr		integer;
  vaction   varchar2(100);
  jname		varchar2(100);
  verr		varchar2(4000);
  pk1		varchar2(100);
  pk2		varchar2(100);
  val1		number;
  val2		number;
  val3		number;
  val4      varchar2(100);
  sz		integer;
  msg       varchar2(200);

 begin
 
   open c1( fname );
   fetch c1 into c1rec;
   close c1;
   if c1rec.mime_type <> 'text/xml'
    then
     cleanup(fname,TRUE);
     err( '[1046] File is not XML (mimetype not text/xml)', 404, TRUE);
     return;
   end if;

   dbms_lob.createtemporary( clb, FALSE );
   p := DBMS_XMLPARSER.newParser;
   DBMS_XMLPARSER.setValidationMode(p, FALSE);

   dest_offset := 1;
   src_offset := 1;
   lang_context := 0;
   dbms_lob.converttoclob( clb, c1rec.blob_content, dbms_lob.getlength( c1rec.blob_content ), dest_offset, src_offset, 0, lang_context, warning );
 
   sz := dbms_lob.getlength(clb);

   DBMS_XMLPARSER.parseClob(p, clb );
   doc := DBMS_XMLPARSER.getDocument(p);

   htp.init;
   owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
   htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
   owa_util.http_header_close;

    nl := dbms_xmldom.getElementsByTagName(doc, '*');
    len1 := dbms_xmldom.getLength(nl);
    ctr := 0;


    for j in 0..len1-1 loop
     n := dbms_xmldom.item(nl, j);
     e := dbms_xmldom.makeElement(n);
     n_child:= dbms_xmldom.getFirstChild(n);
     tag := upper(trim(dbms_xmldom.getTagName(e)));
     
     if tag in ('SMP_ADD_ITEMS', 'SMP_REMOVE_ITEMS')
      then
       ctr := ctr + 1;
       dbms_output.put_line('ctr = '||ctr);
       vaction := tag;
     else
       case tag
        when 'SMP_NO' then pk1  := dbms_xmldom.getNodeValue(n_child);
        when 'UPDATED_BY' then val4  := dbms_xmldom.getNodeValue(n_child);
        when 'DELIVERY_NO'  then  val1:= null; val1 := xtra.guess_number(dbms_xmldom.getNodeValue(n_child));
     -- Modified by David Banjo 15/3/2021
        when 'ITEM_NO' then val2 := null; val2 :=  xtra.guess_number(dbms_xmldom.getNodeValue(n_child));
     -- val2 := xtra.guess_number(dbms_xmldom.getNodeValue(n_child));
        when 'UNIT_NO' then val3 := null; val3 := xtra.guess_number(dbms_xmldom.getNodeValue(n_child));
        
        
          if vaction = 'SMP_ADD_ITEMS' then
             transaction_interface6a (pk1, val1, val2, val3, val4, ctr, sz, msg);
             if msg is not null then
                err( '[1046] '||msg, 404, TRUE);
                return;
             end if;                     
          elsif vaction = 'SMP_REMOVE_ITEMS' then
             transaction_interface6b (pk1, val1, val2, val3, val4, ctr, sz, msg);
             if msg is not null then
                err( '[1046] '||msg, 404, TRUE);
                return;
             end if;  
             
          end if;
          
          val3 := null;
        else null;
       end case;

     end if;
    end loop;
    
   open c3( pk1 );
   fetch c3 into c3rec;
   if c3%found then
       websys.strangp.recalc_weight_smp( c3rec.rid, null);
   end if;
   close c3;
   
   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
  
   if msg is null then
      htp.p( '<result>XML File pushed</result>');
   else
      htp.p( '<result>'||msg||'</result>');
   end if;
  
  -- htp.p( '<result>XML File pushed</result>');

 exception
  when others then
   verr := sqlerrm;
   err( '[1100] Err in process_dnupd_smp:'||' pk1 '|| pk1||' val1 '|| val1||' val2 '|| val2||' val3 '|| val3||' val4 '|| val4||' '|| verr, 404, TRUE);
   external_audit( '6', 'transaction_interface6 (Process Delivery Units in SMP) Failed:' || c1rec.name, ctr, sz, sqlerrm );
   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
 end process_interface6;
 procedure transaction_interface7a(pk1 in varchar2, pk2 in varchar2, val1 in varchar2, val2 in varchar2, ctr in integer, sz in integer, msg in out varchar2)
 as
 
  cursor c1( mv varchar2, sl varchar2) is
  select deliveryno, item_no, order_by, di.movement_no, di.seal
   from strang.detailrs_item di
   where movement_no is not null
    and  movement_no <> mv
    and exists (select 'x'
                  from strang.detailrs_item di1
                 where di1.movement_no = mv
                   and nvl(di1.seal,'|') = nvl(sl,'|')
                   and di1.deliveryno = di.deliveryno
                   and di1.item_no = di.item_no);
                   
  cursor c2 (val1 varchar2) is
   select sm.movement_no, sm.seal
    from  strang.smp sm
    where sm.smp_no = val1;              
                   
 cursor c3( mv varchar2, sl varchar2) is
  select 'x'
   from strang.movements m
   where m.current_location = 'BNE'
     and m.MOVEMENT_TYPE = 'CARGO'
     and  m.movement_no = mv
     and  m.seal = sl
    and  strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) in ( 'INCOMPLETE'); 
    
                                        
 c1rec c1%rowtype;
 c2rec c2%rowtype;
 c3rec c3%rowtype;

 begin
  
    open c2(val1);
    fetch c2 into c2rec;
    if c2%found then 
       if c2rec.movement_no is not null then
          close c2;
          external_audit('7', 'transaction_interface7a - SMP No '||val2||' already assigned to '||c2rec.movement_no||' ('||c2rec.seal||')', pk1, pk2, val1, ctr, sz);
          msg := 'SMP No '||val2||' already assigned to '||c2rec.movement_no||' ('||c2rec.seal||')';
          return;
       end if; 
    end if;
    close c2;
    
    open c3(pk1, pk2);
    fetch c3 into c3rec;
    if c3%notfound then
       close c3;
       external_audit('7', 'transaction_interface7a (Add SMP to Container): Wrong movement status ', pk1, pk2, val1, ctr, sz);
       msg := 'Container '||pk1||'-'||pk2||' is not INCOMPLETE or not in Brisbane';
       return;
    end if;
    close c3;
    
 
    update strang.smp sm
       set movement_no = pk1
         , seal = pk2  
         , date_modified = sysdate
         , modified_date = sysdate
         , modified_by = val2
         , containerised_date = sysdate
     where smp_no = val1   
       and exists (select 'x'
                     from strang.smp sm1
                    where sm1.smp_no = val1
                      and sm.smp_no = sm1.smp_no
                      and sm1.sa = 'S'
                      and strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',sm1.complete) not in ( 'ARCHIVED', 'READ-ONLY', 'SHIPPED'));
     if sql%rowcount <> 0
     then
        external_audit( '7', 'transaction_interface7a (Add SMP to Container): SMP Processed Successfully', pk1, pk2, val1, ctr, sz);
     else
        external_audit( '7', 'transaction_interface7a (Add SMP to Container): Failed to find SMP', pk1, pk2, val1, ctr, sz);
        return;
     end if; 
      
     
     open c1 (pk1, nvl(pk2,'|'));
     fetch c1 into c1rec;
     if c1%found then 
        close c1;
        rollback;
        external_audit('7', 'transaction_interface7a ( SMP removed from Container): an SMP delivery unit already assigned to '||c1rec.movement_no, pk1, pk2, val1, ctr, sz);
        msg := 'Delivery item '||c1rec.deliveryno||'-'||c1rec.item_no||' already assigned to '||c1rec.movement_no;
        return;
     end if;
     close c1;
     

     commit;
     
     update strang.detailrs_item di
       set movement_no = pk1,
           seal = pk2,
           modified_date = sysdate,
           modified_by = val2
     where di.smp_no = val1 
       and exists (select 'x'
                     from strang.smp sm
                    where sm.smp_no = val1
                      and di.smp_no = sm.smp_no
                      and sm.sa = 'S'
                      and strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',sm.complete) not in ( 'ARCHIVED', 'READ-ONLY', 'SHIPPED'));
  
      commit;
      
      update strang.detailrs dr
         set movement_no = pk1,
             camov_seal = pk2,
             date_modified = sysdate
       where (dr.smp_no = val1)                  
       and exists (select 'x'
                     from strang.smp sm
                    where sm.smp_no = val1
                      and dr.smp_no = sm.smp_no
                      and sm.sa = 'S'
                      and strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',sm.complete) not in ( 'ARCHIVED', 'READ-ONLY', 'SHIPPED'));
  
  commit;
  
 exception
  when others then
   external_audit( '7', 'transaction_interface7a (Add SMP to Container): Failed:' || pk1, pk2, val1, ctr, sz, sqlerrm );
 end transaction_interface7a;
 procedure transaction_interface7b(pk1 in varchar2, pk2 in varchar2, val1 in varchar2, val2 in varchar2, ctr in integer, sz in integer, msg in out varchar2)
 as
 
  cursor c1( mv varchar2, sl varchar2) is
  select 'x'
   from strang.movements m
   where m.current_location = 'BNE'
     and m.MOVEMENT_TYPE = 'CARGO'
     and  m.movement_no = mv
     and  m.seal = sl
    and  strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) in ( 'INCOMPLETE');
    
  c1rec c1%rowtype;
 
 
 
 begin
 
    open c1(pk1, pk2);
    fetch c1 into c1rec;
    if c1%notfound then
       close c1;
       external_audit('7', 'transaction_interface7b (Remove SMP from Container): Wrong movement status ', pk1, pk2, val1, ctr, sz);
       msg := 'Container '||pk1||'-'||pk2||' is not INCOMPLETE';
       return;
    end if;
    close c1;
 
 
    update strang.smp sm
       set movement_no = null
         , seal = null 
         , date_modified = sysdate
         , containerised_date = null
         , modified_date = sysdate
         , modified_by = val2
     where smp_no = val1   
       and exists (select 'x'
                     from strang.smp sm1
                    where sm1.smp_no = val1
                      and sm.smp_no = sm1.smp_no
                      and UPPER(sm1.sa) in ( 'S' , 'A')
                      and strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',sm1.complete) not in ( 'ARCHIVED', 'READ-ONLY', 'SHIPPED'));
     if sql%rowcount <> 0
     then
        external_audit( '7', 'transaction_interface7b (Remove SMP from Container): SMP Processed Successfully', pk1, pk2, val1, ctr, sz);
     else
        external_audit( '7', 'transaction_interface7b (Remove SMP from Container):  Failed to find SMP', pk1, pk2, val1, ctr, sz);
        return;
     end if; 
    
     commit;
     
     update strang.detailrs_item di
       set movement_no = null,
           seal = null,
           modified_date = sysdate,
           modified_by = val2
     where di.smp_no = val1 
       and exists (select 'x'
                     from strang.smp sm
                    where sm.smp_no = val1
                      and di.smp_no = sm.smp_no
                      and sm.sa = 'S'
                      and strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',sm.complete) not in ( 'ARCHIVED', 'READ-ONLY', 'SHIPPED'));
      commit;

      update strang.detailrs dr
         set movement_no = null,
             camov_seal = null,
             date_modified = sysdate
       where (dr.smp_no = val1) 
--              or (exists (select 'x'
--                            from strang.detailrs_item di
--                           where dr.deliveryno = di.deliveryno
--                             and dr.itemno = di.item_no
--                             and di.smp_no = val1)))                    
         and exists (select 'x'
                     from strang.smp sm
                    where sm.smp_no = val1
                      and dr.smp_no = sm.smp_no
                      and sm.sa = 'S'
                      and strang.f_getlovcolumn('MOVEMENT_STATUS','DESCRIPTION',sm.complete) not in ( 'ARCHIVED', 'READ-ONLY', 'SHIPPED'));
  
  commit; 
  
 exception
  when others then
   external_audit( '7', 'transaction_interface7b (Remove SMP from Container): Failed:' || pk1, pk2, val1, ctr, sz, sqlerrm );
 end transaction_interface7b;
 
 procedure process_interface7( x in owa.vc_arr, y in owa.vc_arr, fname in varchar )
 as
 
  cursor c1(fnm varchar2) is select * from apache_ows_content where name = fnm;
  cursor c2(jname varchar2) is select * from user_scheduler_jobs where job_name like jname;
  cursor c3( vmovid varchar2, vseal varchar2) is select m.rowid as rid, movement_no, seal, container_type, movement_type, io from strang.movements m where m.movement_no = vmovid and nvl(m.seal,'|') = nvl(vseal,'|') ;

  c1rec 	    c1%ROWTYPE;
  c2rec		    c2%ROWTYPE;
  c3rec		    c3%ROWTYPE;
  clb           clob;
  p 		    DBMS_XMLPARSER.parser;
  dest_offset   integer;
  src_offset    integer;
  lang_context  integer;
  warning       varchar2(1000);
  doc 		    dbms_xmldom.DOMDocument;
  n 		    dbms_xmldom.DOMNode;
  nl 		    dbms_xmldom.DOMNodeList;
  e 		    dbms_xmldom.DOMElement;
  n_child 	    dbms_xmldom.DOMNode;
  tag		    varchar2(1000);
  len1 		    number;
  ctr		    integer;
  vaction       varchar2(100);
  jname		    varchar2(100);
  verr		    varchar2(4000);
  pk1		    varchar2(100);
  pk2		    varchar2(100);
  val1		    varchar2(100);
  val2		    varchar2(100);
  sz		    integer;
  msg           varchar2(200);

 begin
 
   open c1( fname );
   fetch c1 into c1rec;
   close c1;
   if c1rec.mime_type <> 'text/xml'
    then
     cleanup(fname,TRUE);
     err( '[1046] File is not XML (mimetype not text/xml)', 404, TRUE);
     return;
   end if;

   dbms_lob.createtemporary( clb, FALSE );
   p := DBMS_XMLPARSER.newParser;
   DBMS_XMLPARSER.setValidationMode(p, FALSE);

   dest_offset := 1;
   src_offset := 1;
   lang_context := 0;
   dbms_lob.converttoclob( clb, c1rec.blob_content, dbms_lob.getlength( c1rec.blob_content ), dest_offset, src_offset, 0, lang_context, warning );
 
   sz := dbms_lob.getlength(clb);

   DBMS_XMLPARSER.parseClob(p, clb );
   doc := DBMS_XMLPARSER.getDocument(p);

   htp.init;
   owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
   htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
   owa_util.http_header_close;

    nl := dbms_xmldom.getElementsByTagName(doc, '*');
    len1 := dbms_xmldom.getLength(nl);
    ctr := 0;

    for j in 0..len1-1 loop
     n := dbms_xmldom.item(nl, j);
     e := dbms_xmldom.makeElement(n);
     n_child:= dbms_xmldom.getFirstChild(n);
     tag := upper(trim(dbms_xmldom.getTagName(e)));
     
     if tag in ('ADD_SMP', 'REMOVE_SMP')
      then
       ctr := ctr + 1;
       dbms_output.put_line('ctr = '||ctr);
       vaction := tag;
      else
       case tag
        when 'CONTAINER_NO' then pk1  := dbms_xmldom.getNodeValue(n_child);
        when 'CONTAINER_SEAL' then pk2  := dbms_xmldom.getNodeValue(n_child);
        when 'UPDATED_BY' then val2  := dbms_xmldom.getNodeValue(n_child);
        when 'SMP_NO' then val1  := dbms_xmldom.getNodeValue(n_child);

          if vaction = 'ADD_SMP' then
             transaction_interface7a (pk1, pk2, val1, val2, ctr, sz, msg);
             if msg is not null then
                err( '[1046] '||msg, 404, TRUE);
                return;
             end if;
          elsif vaction = 'REMOVE_SMP' then
             transaction_interface7b (pk1, pk2, val1, val2, ctr, sz, msg);
             if msg is not null then
                err( '[1046] '||msg, 404, TRUE);
                return;
             end if;
          end if;
          
          val1 := null;
        else null;
       end case;

     end if;
    end loop;

    open c3(pk1, pk2 );
    fetch c3 into c3rec;
    
    if c3%found then
      websys.strangp.recalc_weight(  c3rec.movement_no, c3rec.container_type, c3rec.seal, c3rec.movement_type, c3rec.rid );
    end if;
    
    close c3;
  
   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
   htp.p( '<result>XML File pushed</result>');

 exception
  when others then
   verr := sqlerrm;
   err( '[1100] Err in process_smpupd_cargo:'||' pk1 '|| pk1||' pk2 '|| pk2||' val1 '|| val1||' '|| verr, 404, TRUE);
   external_audit( '7', 'transaction_interface7 (Process SMP in Container): Failed:' || c1rec.name, ctr, sz, sqlerrm );
   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
 end process_interface7;
 
 procedure transaction_interface8a(pk1 in varchar2, pk2 in varchar2, val1 in owa.vc_arr, val2 in owa.vc_arr, ctr in integer, sz in integer, msg in out varchar2)
 as
 
 e_Move_Type_Null EXCEPTION;
 e_Movement_Exists EXCEPTION;
 cursor c1( mvid varchar2, sl varchar2, mtype varchar2) is select 'x' from strang.movements where movement_no = mvid and movement_type = mtype and nvl(seal,'|') = nvl(sl,'|');
 
 c1rec c1%ROWTYPE;
 vMovement_type varchar2(100) := 'CARGO';
 vContainer_type varchar2(100);
 vIso_container_type varchar2(100);
-- vMovement_mode varchar2(100);
 vMovement_status varchar2(100) := 'F';
 vtare varchar2(100);
 vUrgency varchar2(100);
 vCurrent_location varchar2(100):= 'BNE';
 vDeparture_location varchar2(100):= 'BNE';
 vArrival_location varchar2(100):= 'MOT';
 vWarehouse_location varchar2(100);
 vScan_key integer;
 vSeal varchar2(100);

 begin
  
   for j in val1.first..val1.last loop
     case val1(j)
--        when 'MOVEMENT_TYPE' then 
--            vMovement_type := val2(j);
        when 'CARGO_TYPE' then 
            vContainer_type := val2(j); 
        when 'ISO_CONTAINER_TYPE' then 
            vIso_container_type := val2(j); 
--        when 'MOVEMENT_MODE' then 
--            vMovement_mode := val2(j); 
--        when 'MOVEMENT_STATUS' then 
--            vMovement_status := val2(j); 
--        when 'CURRENT_LOCATION' then 
--            vCurrent_location := val2(j);
--        when 'DEPARTURE_LOCATION' then 
--            vDeparture_location := val2(j); 
--        when 'ARRIVAL_LOCATION' then 
--            vArrival_location := val2(j);    
--        when 'WAREHOUSE_LOCATION' then 
--            vWarehouse_location := val2(j);         
        when 'TARE' then 
            vTare := val2(j);  
--        when 'URGENCY' then 
--            vUrgency := val2(j);  
        when 'SCAN_KEY' then     
            begin vScan_key := to_number(val2(j)); exception when others then vScan_key := null; end; 
        else null;  
     end case;         
   end loop;
 
   if vMovement_type is null
   then
      external_audit( '8', 'transaction_interface8a (Add Movement)  Unable to create Movement as Movement_type is null', pk1, pk2, null, null );
      msg := 'Error: Unable to create Movement as Movement_type is null';
      raise e_Move_Type_Null;
      return;
   else     
     open c1( pk1, pk2, vMovement_type);
     fetch c1 into c1rec;
     if c1%found then 
        external_audit( '8', 'transaction_interface8a (Add Movement)  Unable to create Movement as movement already exists', pk1, pk2, null, null );
        msg := 'Error: Unable to create Movement as movement already exists';
        close c1;
     --   raise e_Movement_Exists;
        return;
     end if;
     close c1;
     
   --  if vMovement_type = 'CARGO' and substr(vIso_container_type, 3,1) = 'P' and pk2 is null then
     if vMovement_type = 'CARGO' and pk2 is null then
        vseal := 'TBC';
     end if;
     
     
 
     insert into strang.movements(movement_type 
                              ,movement_no
                              ,seal
                              ,ship_id
                              ,complete
                              ,container_type
                              ,iso_container_type
                              ,tare
                              ,departure
                              ,arrival
                              ,full_mt
                              ,io
                              ,local_ship_id
                              ,urgency
                              ,owner 
                              ,current_location 
                              ,warehouse_destination
                              ,sumvolume
                              ,sumweight
                              ,revton
                              ,scan_key
                              ,date_modified
                              ,date_created ) values
                             ( vMovement_type
                              ,decode(vmovement_type,'AIRWAY',trim(pk1),replace(pk1,' ',''))
                              ,NVL(trim(pk2),vseal)
                              ,decode(vmovement_type,'AIRWAY',0,5)  -- default Intl outbound ship
                              ,nvl(vMovement_status,'F')
                              ,vContainer_type
                              ,vIso_container_type
                              ,vTare  -- obtain from previous one
                              ,nvl(vDeparture_location,decode(vMovement_type,'AIRWAY','CNE','BNE')) 
                              ,nvl(vArrival_location,'MOT')
                              ,'FULL'
                              ,'I'
                              ,decode(vMovement_type,'AIRWAY',2,2) 
                              ,NVL(vUrgency,'STANDARD')
                              ,strang.f_GetDefaultCtrOwner(decode(vMovement_type,'AIRWAY',pk1,replace(pk1,' ','')),vMovement_type,null)
                              ,vCurrent_location
                              ,vWarehouse_location
                              ,0
                              ,0
                              ,0
                              ,vScan_key
                              ,sysdate
                              ,sysdate);
   end if;
   
                             
   if sql%rowcount <> 0
     then
      external_audit( '8', 'transaction_interface8a (Movement Creation): Movement Processed Successfully', pk1, pk2, val1(1), ctr, sz);
   else
      external_audit( '8', 'transaction_interface8a (Movement Creation): Failed to Create Movement', pk1, pk2, val1(1), ctr, sz);
      msg := 'Error: Failed to Create Movement';
      return;
   end if; 
      
   commit;
  
 exception
  when e_Move_Type_Null THEN null;
  when e_Movement_Exists then  null;
  when others then
     external_audit( '8', 'transaction_interface8a (Movement Creation) Failed:' || pk1, pk2, val1(1)||':'||val2(1),val1(2)||':'||val2(2), ctr, sz, sqlerrm );
     msg := sqlerrm;
 end transaction_interface8a;
 procedure transaction_interface8b(pk1 in varchar2, pk2 in varchar2, ctr in integer, sz in integer, msg in out varchar2)
 as
 
 e_No_Movement EXCEPTION;
 e_Movement_has_items EXCEPTION;
 cursor c1( mvid varchar2, sl varchar2) is select 'x' from strang.movements where movement_no = mvid and nvl(seal,'|') = nvl(sl,'|');
 
 cursor c2(mvid varchar2, sl varchar2) is
  select count('x') tot
  from ( select deliveryno
           from strang.detailrs
          where movement_no = mvid
            and nvl(camov_seal, '|') = nvl(sl, '|')
         union all
         select deliveryno
           from strang.detailrs_item
          where movement_no = 	mvid
            and nvl(seal, '|') = nvl(sl, '|')) tmp;
 
 c1rec c1%ROWTYPE;
 c2rec c2%ROWTYPE;
 
 
 begin
 
 open c1( pk1, pk2);
 fetch c1 into c1rec;
 if c1%notfound then 
    external_audit( '8', 'transaction_interface8b (Remove Movement)  Movement does not exist', pk1, pk2, ctr, sz );
    close c1;
    msg := 'Error: Movement does not exist';
    raise e_No_Movement;
    return;
 end if;
 
open c2( pk1, pk2);
 fetch c2 into c2rec;
 if c2rec.tot <> 0 then 
    external_audit( '8', 'transaction_interface8b (Remove Movement)  Movement has attached items', pk1, pk2, ctr, sz );
    close c2;
    msg := 'Error: Movement has attached items';
    raise e_Movement_has_items;
    return;
 end if;
 
 
 
 delete from strang.movements 
  where movement_no = pk1
    and nvl(seal,'|')  = nvl(pk2,'|');
 
 if sql%rowcount <> 0
 then
    external_audit( '8', 'transaction_interface8b (Remove Movement): Movement Processed Successfully', pk1, pk2, ctr, sz);
 end if;
      
 commit; 
  
 exception
  when e_No_Movement then  null;
  when e_Movement_has_items then null;
  when others then
   external_audit( '8', 'transaction_interface8b (Remove Movement) Failed:' || pk1, pk2, ctr, sz, sqlerrm );
   msg := sqlerrm;
 end transaction_interface8b;
 -----------------------------------------------------------------------------------
 procedure transaction_interface8c(pk1 in varchar2, pk2 in varchar2, val1 in owa.vc_arr, val2 in owa.vc_arr, ctr in integer, sz in integer, msg in out varchar2)
 as
 e_Move_Type_Null EXCEPTION;
 e_No_Movement_Exists EXCEPTION;
 e_hazardous_cargo_no_tare EXCEPTION;
 e_hazardous_cargo_over_weight EXCEPTION;
 cursor c1(mvid varchar2, sl varchar2) is select movement_no, seal, complete, iso_container_type from strang.movements where movement_no = mvid and nvl(seal,'|') = nvl(sl,'|');
 cursor c2(mvid varchar2, sl varchar2) is select (select count(*) 
                                                    from strang.detailrs dr
                                                   where dr.movement_No = m.movement_no
                                                     and nvl(dr.camov_seal,'|') = nvl(m.seal,'|')
                                                     and dr.HAZARD is not null) haz_cnt
                                                , nvl(m.tare, 0) tare
                                                , nvl(m.sumweight,0) sumweight
                                                , (nvl(m.tare, 0) + nvl(m.sumweight,0)) grossweight   
                                            from strang.movements m
                                           where m.movement_no = mvid 
                                             and nvl(m.seal,'|') = nvl(sl,'|');
                                             
 c1rec c1%ROWTYPE;
 c2rec c2%ROWTYPE;
 vMovement_type varchar2(100);
 vContainer_type varchar2(100);
 vIso_container_type varchar2(100);
 -- vMovement_mode varchar2(100);
 vMovement_status varchar2(100);
 vtare varchar2(100);
 vUrgency varchar2(100);
 vCurrent_location varchar2(100);
 vUpdated_by varchar2(100);
 vDeparture_location varchar2(100);
 vArrival_location varchar2(100);
 vWarehouse_location varchar2(100);
 vScan_key integer;
 vPhotoBy varchar2(100);
 vPackedBy varchar2(100);
 vPackCheckedBy varchar2(100):= 'DEFAULT';
 vFlatRackEnds varchar2(100);
 vEndPinsEngaged varchar2(100);
 vTimberTrimmed varchar2(100);
 vLooseItemsChecked varchar2(100);
 vOutWidthLeftSide varchar2(100);
 vOutWidthRightSide varchar2(100);
 vOutWidthFrontEnd varchar2(100);
 vOutWidthRearEnd varchar2(100);
 vOutWidthHeight varchar2(100);
 vUnpack_exceptions_flag varchar2(1);
 vUnpack_exceptions_approved_by varchar2(100);
 vUnpack_completed_by varchar2(100);




 begin
 
   for j in val1.first..val1.last loop
     case val1(j)
        when 'MOVEMENT_TYPE' then 
            vMovement_type := val2(j);
        when 'CARGO_TYPE' then 
            vContainer_type := val2(j); 
        when 'ISO_CONTAINER_TYPE' then 
            vIso_container_type := val2(j); 
--        when 'MOVEMENT_MODE' then 
--            vMovement_mode := val2(j); 
        when 'MOVEMENT_STATUS' then 
            vMovement_status := val2(j); 
        when 'CURRENT_LOCATION' then 
            vCurrent_location := val2(j);
        when 'DEPARTURE_LOCATION' then 
            vDeparture_location := val2(j); 
        when 'ARRIVAL_LOCATION' then 
            vArrival_location := val2(j);    
        when 'WAREHOUSE_LOCATION' then 
            vWarehouse_location := val2(j);
        when 'UPDATED_BY' then 
            vUpdated_by := val2(j);             
        when 'TARE' then 
            vTare := val2(j);  
        when 'URGENCY' then 
            vUrgency := val2(j);  
        when 'PHOTO_BY' then 
            vPhotoBy := val2(j);      
        when 'PACKED_BY' then 
            vPackedBy := val2(j);        
        when 'PACK_CHECKED_BY' then 
            vPackCheckedBy := val2(j);       
        when 'FLATRACK_ENDS' then 
            vFlatRackEnds := val2(j); 
        when 'END_PINS_ENGAGED' then 
            vEndPinsEngaged := val2(j); 
        when 'TIMBER_TRIMMED' then 
            vTimberTrimmed := val2(j);    
        when 'LOOSE_ITEMS_CHECKED' then 
            vLooseItemsChecked := val2(j);    
        when 'OUT_WIDTH_LEFT_SIDE' then 
            vOutWidthLeftSide := val2(j);                                
        when 'OUT_WIDTH_RIGHT_SIDE' then 
            vOutWidthRightSide := val2(j);            
        when 'OUT_WIDTH_FRONT_END' then 
            vOutWidthFrontEnd := val2(j);             
        when 'OUT_WIDTH_REAR_END' then 
            vOutWidthRearEnd := val2(j);             
        when 'OUT_HEIGHT' then 
            vOutWidthHeight := val2(j);      
        when 'SCAN_KEY' then     
            begin vScan_key := to_number(val2(j)); exception when others then vScan_key := null; end; 
        when 'UNPACK_EXCEPTIONS' then 
            vUnpack_exceptions_flag := val2(j);   
        when 'UNPACK_EXCEPTIONS_APPROVED' then 
            vUnpack_exceptions_approved_by := val2(j);   
        when 'UNPACK_COMPLETED' then 
            vUnpack_completed_by := val2(j);   
        else null;  
     end case;         
   end loop;
     
   open c1( pk1, pk2);
   fetch c1 into c1rec;
   if c1%notfound then 
      external_audit( '8', 'transaction_interface8c (Amend Movement)  Unable to Amend Movement as movement_no does not exist', pk1, pk2, null, null );
      close c1;
      raise e_No_Movement_Exists;
      msg := 'Error: Unable to Amend Movement as movement_no does not exist';
      return;
   end if;
   close c1;
   
    if vPackCheckedBy is not null and vPackCheckedBy <> 'DEFAULT' then 
      open c2( pk1, pk2);
      fetch c2 into c2rec;
      close c2;
      
      if c2rec.haz_cnt > 0 and c2rec.grossweight >= 20000 then
        external_audit( '8', 'transaction_interface8c (Amend Movement)  Approval error: Container over 20 tonnes and contains hazardous cargo', pk1, pk2, null, null );
        raise e_hazardous_cargo_over_weight;
        msg := 'Error: Container with Hazardous cargo over 20 tonnes';
        return;
      elsif c2rec.tare = 0 and c2rec.haz_cnt > 0  then
        external_audit( '8', 'transaction_interface8c (Amend Movement)  Exception: Tare weight of Container should not be 0!', pk1, pk2, null, null );
        raise e_hazardous_cargo_no_tare;
        msg := 'Error: Tare weight of Container containing hazardous cargo can not to be 0!';
        return;
      end if;
   end if;      

   
   if vUnpack_exceptions_flag is not null or vUnpack_exceptions_approved_by is not null or vUnpack_completed_by is not null then
        update strang.movements m
           set unpack_exceptions_flag = nvl(vUnpack_exceptions_flag, unpack_exceptions_flag)
             , unpack_exceptions_approved_by = nvl(vUnpack_exceptions_approved_by, unpack_exceptions_approved_by)
             , unpack_exceptions_approved_dt = case when vUnpack_exceptions_approved_by is not null then sysdate else unpack_exceptions_approved_dt end
             , unpack_completed_by = nvl(vUnpack_completed_by, unpack_completed_by)
             , unpack_completed_date = case when vUnpack_completed_by is not null then sysdate else unpack_completed_date end
        where m.movement_no = pk1
        and nvl(m.seal,'|') = nvl(pk2,'|'); 
        
       if sql%rowcount <> 0
       then
         external_audit( '8', 'transaction_interface8c (Movement Amendment): Unpack Movement Processed Successfully', pk1, pk2, val1(1)||':'||val2(1), ctr, sz);
      else
         external_audit( '8', 'transaction_interface8c (Movement Amendment): Failed to Amend unpack Movement', pk1, pk2, val1(1), ctr, sz);
         msg := 'Error: Failed to Amend Movement';
      end if; 
       
      commit;
   else 
   
     update strang.movements m
        set movement_type = nvl(vMovement_type,movement_type)
         , complete = case when m.COMPLETE NOT in ('F','P') then m.complete 
                       else nvl(vMovement_status,complete) end
         , container_type = nvl(vContainer_type,container_type)
         , iso_container_type = nvl(vIso_container_type,iso_container_type)
         , tare = nvl(vTare, tare)
         , departure = nvl(nvl(vDeparture_location,decode(vMovement_type,'AIRWAY','CNE','BNE')), departure)
         , arrival = nvl(vArrival_location, arrival)
         , urgency = nvl(vUrgency, urgency)
         , current_location = nvl(vCurrent_location, current_location)
         , warehouse_destination = nvl(vWarehouse_location, warehouse_destination)
         , scan_key = nvl(vScan_key, scan_key)
         , date_modified = sysdate
         , modified_by = vUpdated_by
         , packed_date = case when m.complete = 'F' and vMovement_status = 'P' then sysdate 
                              when m.complete = 'P' and vMovement_status = 'F' then null else packed_date end
         , packed_by = case when m.complete = 'F' and vMovement_status = 'P' then vPackedBy 
                            when m.complete = 'P' and vMovement_status = 'F' then null else packed_by end
--     , packed_date = case when m.complete = 'F' and vMovement_status = 'P' then sysdate 
--                          when m.complete = 'P' and vMovement_status = 'F' then null else packed_date end
--     , packed_by = case when m.complete = 'F' and vMovement_status = 'P' then vPackedBy 
--                          when m.complete = 'P' and vMovement_status = 'F' then null else packed_by end                                            
         , pack_checked_by = CASE WHEN vPackCheckedBy = 'DEFAULT' then pack_checked_by
                                  WHEN vPackCheckedBy IS NULL OR ASCII(vPackCheckedBy) = 32  THEN NULL 
                                  WHEN vPackCheckedBy IS NOT NULL THEN vPackCheckedBy END
         , pack_check_date = CASE when vPackCheckedBy = 'DEFAULT' then pack_check_date
                                  WHEN vPackCheckedBy IS NULL OR ASCII(vPackCheckedBy) = 32 THEN NULL
                                  WHEN vPackCheckedBy IS NOT NULL THEN sysdate END                       
--     , ship_id = case when vPackCheckedBy = 'DEFAULT' then ship_id
--                      WHEN vPackCheckedBy IS NULL THEN 5
--                      WHEN vPackCheckedBy IS NOT NULL THEN 6 END
         , photo_by = nvl(vPhotoBy,photo_by)
         , flatrack_ends = nvl(vFlatRackEnds, flatrack_ends)
         , pin_engaged = nvl(vEndPinsEngaged, pin_engaged)
         , timber_trimmed = nvl(vTimberTrimmed, timber_trimmed)
         , loose_items_checked = nvl(vLooseItemsChecked, loose_items_checked)            
         , out_width_left_side = nvl(vOutWidthLeftSide, out_width_left_side)
         , out_width_right_side = nvl(vOutWidthRightSide, out_width_right_side)
         , out_width_front_end = nvl(vOutWidthFrontEnd, out_width_front_end)
         , out_width_rear_end = nvl(vOutWidthRearEnd, out_width_rear_end)
         , out_height =  nvl(vOutWidthHeight, out_height)                                               
      where m.movement_no = pk1
        and nvl(m.seal,'|') = nvl(pk2,'|'); 
                                  
   if sql%rowcount <> 0
     then
      external_audit( '8', 'transaction_interface8c (Movement Amendment): Movement Processed Successfully', pk1, pk2, val1(1)||':'||val2(1), ctr, sz);
   else
      external_audit( '8', 'transaction_interface8c (Movement Amendment): Failed to Amend Movement', pk1, pk2, val1(1), ctr, sz);
      msg := 'Error: Failed to Amend Movement';
      return;
   end if; 
   
   if c1rec.complete in ('F', 'P') and substr(c1rec.iso_container_type,3,1) = 'P' then
   
      update strang.movements m
      set overdimensional = SUBSTR(rtrim(case when flatrack_ends = 'UP' then 'ENDS UP; '
                               when  flatrack_ends = 'DOWN' then 'ENDS DOWN; ' else '' end ||  
        (case when nvl(out_width_left_side,0) <> 0 then
        'O/W '||to_char(out_width_left_side)|| 'CM LEFT; ' end)||
        (case when nvl(out_width_right_side,0) <> 0 then
        'O/W '||to_char(out_width_right_side)|| 'CM RIGHT; ' end)||
        (case when nvl(out_width_front_end,0) <> 0 then
        'O/L '||to_char(out_width_front_end)|| 'CM FRONT; ' end )||
        (case when nvl(out_width_rear_end,0) <> 0 then
        'O/L '||to_char(out_width_rear_end)|| 'CM REAR; ' end )||
        (case when nvl(out_height,0) <> 0 then
        'O/H '||to_char(out_height)|| 'CM; ' end ),'; '),1,80)                              
      where m.movement_no = pk1
      and nvl(m.seal,'|') = nvl(pk2,'|'); 
   
       end if;
   
  -- alter table strang.movements modify overdimensional varchar2(80);
   commit;
  end if;
   
 exception
  when e_Move_Type_Null THEN null;
  when e_No_Movement_Exists  then  null;
  when e_hazardous_cargo_over_weight then err( '[1301] Err in process_movement: '|| pk1||' '|| pk2||' Hazardous Container over 20 tonnes!', 404, TRUE);
  when e_hazardous_cargo_no_tare then err( '[1300] Err in process_movement: '|| pk1||' '|| pk2||' Tare Weight can not be 0!', 404, TRUE);
  when others then
   external_audit( '8', 'transaction_interface8c (Movement Amendment) Failed:' || pk1, pk2, val1(1)||':'||val2(1),val1(2)||':'||val2(2), ctr, sz, sqlerrm );
   msg := sqlerrm;
 end transaction_interface8c;
 procedure process_interface8( x in owa.vc_arr, y in owa.vc_arr, fname in varchar )
 as

  cursor c1(fnm varchar2) is select * from apache_ows_content where name = fnm;
  cursor c2(jname varchar2) is select * from user_scheduler_jobs where job_name like jname;
  cursor c3( vmovid varchar2, vseal varchar2) is select m.rowid as rid, movement_no, seal, container_type, movement_type, io from strang.movements m where m.movement_no = vmovid and nvl(m.seal,'|') = nvl(vseal,'|') ;
  

  c1rec 	    c1%ROWTYPE;
  c2rec		    c2%ROWTYPE;
  c3rec		    c3%ROWTYPE;
  clb           clob;
  p 		    DBMS_XMLPARSER.parser;
  dest_offset   integer;
  src_offset    integer;
  lang_context  integer;
  warning       varchar2(1000);
  doc 		    dbms_xmldom.DOMDocument;
  n 		    dbms_xmldom.DOMNode;
  nl 		    dbms_xmldom.DOMNodeList;
  e 		    dbms_xmldom.DOMElement;
  n_child 	    dbms_xmldom.DOMNode;
  tag		    varchar2(1000);
  len1 		    number;
  ctr		    integer;
  vaction       varchar2(100);
  jname		    varchar2(100);
  verr		    varchar2(4000);
  pk1		    varchar2(100);
  pk2		    varchar2(100);
  msg           varchar2(1000);
  val1		    owa.vc_arr;
  val2          owa.vc_arr;
  sz		    integer;
  c             integer := 0;

 begin
 
   open c1( fname );
   fetch c1 into c1rec;
   close c1;
   if c1rec.mime_type <> 'text/xml'
    then
     cleanup(fname,TRUE);
     err( '[1046] File is not XML (mimetype not text/xml)', 404, TRUE);
     return;
   end if;

   dbms_lob.createtemporary( clb, FALSE );
   p := DBMS_XMLPARSER.newParser;
   DBMS_XMLPARSER.setValidationMode(p, FALSE);

   dest_offset := 1;
   src_offset := 1;
   lang_context := 0;
   dbms_lob.converttoclob( clb, c1rec.blob_content, dbms_lob.getlength( c1rec.blob_content ), dest_offset, src_offset, 0, lang_context, warning );
 
   sz := dbms_lob.getlength(clb);

   DBMS_XMLPARSER.parseClob(p, clb );
   doc := DBMS_XMLPARSER.getDocument(p);

   htp.init;
   owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
   htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
   owa_util.http_header_close;

    nl := dbms_xmldom.getElementsByTagName(doc, '*');
    len1 := dbms_xmldom.getLength(nl);
    ctr := 0;

    for j in 0..len1-1 loop
     n := dbms_xmldom.item(nl, j);
     e := dbms_xmldom.makeElement(n);
     n_child:= dbms_xmldom.getFirstChild(n);
     tag := upper(trim(dbms_xmldom.getTagName(e)));
      
       
     if tag in ('ADD_MOVEMENT', 'DELETE_MOVEMENT','AMEND_MOVEMENT')
      then
       ctr := ctr + 1;
       dbms_output.put_line('ctr = '||ctr);
       vaction := tag;
      else
       case tag
        when 'MOVEMENT_NO' then pk1  := dbms_xmldom.getNodeValue(n_child);
        when 'SEAL' then pk2  := dbms_xmldom.getNodeValue(n_child);
        when 'MOVEMENT_TYPE' then 
            c:= c+1;
            val1(c) := 'MOVEMENT_TYPE';
            val2(c) := dbms_xmldom.getNodeValue(n_child);
        when 'CARGO_TYPE' then 
            c:= c+1;
            val1(c) := 'CARGO_TYPE';
            val2(c) := dbms_xmldom.getNodeValue(n_child); 
        when 'ISO_CONTAINER_TYPE' then 
            c:= c+1;
            val1(c) := 'ISO_CONTAINER_TYPE';
            val2(c) := dbms_xmldom.getNodeValue(n_child);       
--        when 'MOVEMENT_MODE' then 
--            c:= c+1;
--            val1(c) := 'MOVEMENT_MODE';
--            val2(c) := dbms_xmldom.getNodeValue(n_child);        
        when 'MOVEMENT_STATUS' then 
            c:= c+1;
            val1(c) := 'MOVEMENT_STATUS';
            val2(c) := dbms_xmldom.getNodeValue(n_child);       
        when 'CURRENT_LOCATION' then 
            c:= c+1;
            val1(c) := 'CURRENT_LOCATION';
            val2(c) := dbms_xmldom.getNodeValue(n_child);
        when 'DEPARTURE_LOCATION' then 
            c:= c+1;
            val1(c) := 'DEPARTURE_LOCATION';
            val2(c) := dbms_xmldom.getNodeValue(n_child);
        when 'ARRIVAL_LOCATION' then 
            c:= c+1;
            val1(c) := 'ARRIVAL_LOCATION';
            val2(c) := dbms_xmldom.getNodeValue(n_child);            
        when 'WAREHOUSE_LOCATION' then 
            c:= c+1;
            val1(c) := 'WAREHOUSE_LOCATION';
            val2(c) := dbms_xmldom.getNodeValue(n_child);    
        when 'TARE' then 
            c:= c+1;
            val1(c) := 'TARE';
            val2(c) := dbms_xmldom.getNodeValue(n_child);    
        when 'URGENCY' then 
            c:= c+1;
            val1(c) := 'URGENCY';
            val2(c) := dbms_xmldom.getNodeValue(n_child);    
        when 'PHOTO_BY' then 
            c:= c+1;
            val1(c) := 'PHOTO_BY';
            val2(c) := dbms_xmldom.getNodeValue(n_child);  
        when 'PACKED_BY' then 
            c:= c+1;
            val1(c) := 'PACKED_BY';
            val2(c) := dbms_xmldom.getNodeValue(n_child);  
        when 'PACK_CHECKED_BY' then 
            c:= c+1;
            val1(c) := 'PACK_CHECKED_BY';
            val2(c) := dbms_xmldom.getNodeValue(n_child);  
        when 'FLATRACK_ENDS' then 
            c:= c+1;
            val1(c) := 'FLATRACK_ENDS';
            val2(c) := dbms_xmldom.getNodeValue(n_child);       
        when 'END_PINS_ENGAGED' then 
            c:= c+1;
            val1(c) := 'END_PINS_ENGAGED';
            val2(c) := dbms_xmldom.getNodeValue(n_child); 
        when 'TIMBER_TRIMMED' then 
            c:= c+1;
            val1(c) := 'TIMBER_TRIMMED';
            val2(c) := dbms_xmldom.getNodeValue(n_child); 
        when 'LOOSE_ITEMS_CHECKED' then 
            c:= c+1;
            val1(c) := 'LOOSE_ITEMS_CHECKED';
            val2(c) := dbms_xmldom.getNodeValue(n_child);  
        when 'OUT_WIDTH_LEFT_SIDE' then 
            c:= c+1;
            val1(c) := 'OUT_WIDTH_LEFT_SIDE';
            val2(c) := dbms_xmldom.getNodeValue(n_child);  
        when 'OUT_WIDTH_RIGHT_SIDE' then 
            c:= c+1;
            val1(c) := 'OUT_WIDTH_RIGHT_SIDE';
            val2(c) := dbms_xmldom.getNodeValue(n_child);      
        when 'OUT_WIDTH_FRONT_END' then 
            c:= c+1;
            val1(c) := 'OUT_WIDTH_FRONT_END';
            val2(c) := dbms_xmldom.getNodeValue(n_child); 
        when 'OUT_WIDTH_REAR_END' then 
            c:= c+1;
            val1(c) := 'OUT_WIDTH_REAR_END';
            val2(c) := dbms_xmldom.getNodeValue(n_child);
        when 'OUT_HEIGHT' then 
            c:= c+1;
            val1(c) := 'OUT_HEIGHT';
            val2(c) := dbms_xmldom.getNodeValue(n_child);                                
        when 'SCAN_KEY' then 
            c:= c+1;
            val1(c) := 'SCAN_KEY';
            val2(c) := dbms_xmldom.getNodeValue(n_child);  
        when 'UPDATED_BY' then 
            c:= c+1;
            val1(c) := 'UPDATED_BY';
            val2(c) := dbms_xmldom.getNodeValue(n_child);     
        when 'UNPACK_EXCEPTIONS' then 
            c:= c+1;
            val1(c) := 'UNPACK_EXCEPTIONS';
            val2(c) := dbms_xmldom.getNodeValue(n_child);
        when 'UNPACK_EXCEPTIONS_APPROVED' then 
            c:= c+1;
            val1(c) := 'UNPACK_EXCEPTIONS_APPROVED';
            val2(c) := dbms_xmldom.getNodeValue(n_child);   
        when 'UNPACK_COMPLETED' then 
            c:= c+1;
            val1(c) := 'UNPACK_COMPLETED';
            val2(c) := dbms_xmldom.getNodeValue(n_child);                 
        else null;    
       end case;

     end if;
    end loop;
    
    if vaction = 'ADD_MOVEMENT' then
       transaction_interface8a (pk1, pk2, val1, val2, ctr, sz, msg);
    elsif vaction = 'DELETE_MOVEMENT' then
       transaction_interface8b (pk1, pk2, ctr, sz, msg);
    elsif vaction = 'AMEND_MOVEMENT' then
       transaction_interface8c (pk1, pk2, val1, val2, ctr, sz, msg);
    end if;
    
    open c3(pk1, pk2 );
    fetch c3 into c3rec;
    if c3%found then
     websys.strangp.recalc_weight(  c3rec.movement_no, c3rec.container_type, c3rec.seal, c3rec.movement_type, c3rec.rid );
    end if;
    
    close c3;
    
    

   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
   if msg is null then
      htp.p( '<result>XML File pushed</result>');
   else
      htp.p( '<result>'||msg||'</result>');
   end if;

 exception
  when others then
   verr := sqlerrm;
   err( '[1300] Err in process_movement:'||' pk1 '|| pk1||' pk2 '|| pk2||' '|| verr, 404, TRUE);
   external_audit( '8', 'transaction_interface8 (Process Cargo/Air Movement): Failed:' || c1rec.name, ctr, sz, sqlerrm );
   msg:= sqlerrm;
   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
 end process_interface8;
 --##############################################################################################################################
 procedure transaction_interface9a(pk1 in varchar2, val1 in owa.vc_arr, val2 in owa.vc_arr, ctr in integer, sz in integer, msg in out varchar2)
 as
 
 -- e_Move_Type_Null EXCEPTION;
 e_smp_Exists EXCEPTION;
 cursor c1(vsmp_no varchar2) is select 'x' from strang.smp where smp_no = vsmp_no;
-- 
-- select *
-- from strang.smp
-- where smp_no IN ('SMP579','SMP124')
 

 c1rec c1%ROWTYPE;
 vsmp_type varchar2(100) := 'GENERIC';
 vsmp_mode varchar2(100);
 vsmp_status varchar2(100) := 'F';
 --vtare varchar2(100);
 vUrgency varchar2(100):= 'STANDARD';
 vhazard  varchar2(100) := NULL;
 vClient integer := 1;
 vCurrent_location varchar2(100) := 'BNE' ;
 vWarehouse_location varchar2(100);
 vUpdated_by varchar2(100);
 vScan_key integer;
 vtare number;

 begin
  
   for j in val1.first..val1.last loop
     case val1(j)
--        when 'SMP_PACKTYPES' then 
--            vsmp_type := val2(j);
        when 'HAZARD_CLASS' then 
            vhazard := val2(j); 
--        when 'CUSTOMER' then 
--            begin vClient := to_number(val2(j)); exception when others then vClient := null; end; 
        when 'SMP_MODE' then 
            vsmp_mode := val2(j); 
--        when 'SMP_STATUS' then 
--            vsmp_status := val2(j); 
--        when 'CURRENT_LOCATION' then 
--            vCurrent_location := val2(j);
        when 'UPDATED_BY' then 
            vUpdated_by := val2(j);        
--        when 'WAREHOUSE_LOCATION' then 
--            vWarehouse_location := val2(j);         
        when 'TARE' then 
            vTare := val2(j);  
--        when 'URGENCY' then 
--            vUrgency := val2(j);  
        when 'SCAN_KEY' then     
            begin vScan_key := to_number(val2(j)); exception when others then vScan_key := null; end; 
        else null;  
     end case;         
   end loop;
    
   open c1( pk1);
   fetch c1 into c1rec;
   if c1%found then 
      external_audit( '9', 'transaction_interface9a (Add SMP)  Unable to create SMP as SMP_NO already exists', pk1, null, null );
      close c1;
      msg := 'Error: Unable to create SMP as SMP_NO already exists';
      raise e_smp_Exists;
      return;
   end if;
   close c1;
  
  if vtare is null then
     begin select sum(to_number(cold)) into vtare from strang.lov where lov_name = 'SMP_PACKTYPES' and code = vsmp_type; exception when others then vtare := NULL; end;
  end if;
  

 
  insert into strang.smp(smp_id,smp_no,smp_type,urgency,client_id,current_location,complete,sa,hazard_class,location_in_warehouse,currdate,io,tare, grossweight,scan_key, created_by  ) values
  (strang.s_smp_id.nextval,pk1,vsmp_type,vUrgency,vClient,vCurrent_location,vsmp_status,vsmp_mode,vhazard,vWarehouse_location,sysdate,'I',vtare, vtare,vScan_key, vUpdated_by);
                        
   if sql%rowcount <> 0
     then
      external_audit( '9', 'transaction_interface9a (SMP Creation): SMP Processed Successfully', pk1,val1(1)||':'||val2(1), ctr, sz);
   else
      external_audit( '9', 'transaction_interface9a (SMP Creation): Failed to Create SMP', pk1,val1(1)||':'||val2(1), ctr, sz);
      msg := 'Error: Failed to Create SMP';
      err( msg, 404, TRUE);
      return;
   end if; 
      
   commit;
  
 exception
  when e_smp_Exists then err( '[1048] Unable to create SMP as SMP_NO already exists', 404, TRUE);
  when others then
     external_audit( '9', 'transaction_interface9a (SMP Creation) Failed:' || pk1, val1(1)||':'||val2(1),val1(2)||':'||val2(2), ctr, sz, sqlerrm );
     msg := sqlerrm;
 end transaction_interface9a;
 procedure transaction_interface9b(pk1 in varchar2, ctr in integer, sz in integer, msg in out varchar2)
 as
 
 e_No_SMP EXCEPTION;
 e_SMP_has_items EXCEPTION;
 cursor c1(vsmp_no varchar2) is select 'x' from strang.smp where smp_no = vsmp_no;
 
 cursor c2(vsmp_no varchar2) is
  select count('x') tot
  from (select deliveryno
          from strang.detailrs
         where smp_no = vsmp_no
        union all
        select deliveryno
          from strang.detailrs_item
         where smp_no = vsmp_no) tmp;
 
 c1rec c1%ROWTYPE;
 c2rec c2%ROWTYPE;
 
 
 begin
 
 open c1( pk1);
 fetch c1 into c1rec;
 if c1%notfound then 
    external_audit( '9', 'transaction_interface9b (Delete SMP)  SMP does not exist', pk1, ctr, sz );
    close c1;
    msg := 'Error: SMP does not exist';
    raise e_No_SMP;
    return;
 end if;
 
open c2( pk1);
 fetch c2 into c2rec;
 if c2rec.tot <> 0 then 
    external_audit( '9', 'transaction_interface9b (Delete SMP)  SMP has attached items', pk1, ctr, sz );
    close c2;
    msg := 'Error: SMP has attached items';
    raise e_SMP_has_items;
    return;
 end if;
 
 delete from strang.smp 
  where smp_no = pk1;
 
 if sql%rowcount <> 0
 then
    external_audit( '9', 'transaction_interface9b (Delete SMP): SMP Processed Successfully', pk1, ctr, sz);
 end if;
      
 commit; 
  
 exception
  when e_No_SMP then err( '[1048] Unable to delete SMP as SMP_NO is null', 404, TRUE);
  when e_SMP_has_items then err( '[1048] Unable to delete SMP as SMP has attached items', 404, TRUE);
  when others then
   external_audit( '9', 'transaction_interface9b (Delete SMP) Failed:' || pk1, ctr, sz, sqlerrm );
   msg := sqlerrm;
 end transaction_interface9b;
-- -----------------------------------------------------------------------------------
 procedure transaction_interface9c(pk1 in varchar2, val1 in owa.vc_arr, val2 in owa.vc_arr, ctr in integer, sz in integer, msg in out varchar2)
 as
 e_No_SMP_Exists EXCEPTION;
 cursor c1(vsmp_no varchar2) is select sm.rowid rid, sm.* from strang.smp sm where smp_no = vsmp_no;
 
 cursor c2(vsmp_no varchar2) is
   select *
   from 
   (select (select max(di1.order_by) from strang.detailrs_item di1 where di1.deliveryno = dr.deliveryno and di1.item_no = dr.itemno) max_unit
        , count(*) over ( partition by dr.deliveryno, dr.itemno) cnt
        , to_char(di.lngth)||'cm X '||to_char(di.width)||'cm X '||to_char(di.height)||'cm'  as unit_dimms  
        , di.deliveryno
        , di.item_no 
   from strang.smp sm 
   left join strang.detailrs_item di on (sm.smp_no = di.smp_no)
   left join strang.detailrs dr on (dr.deliveryno = di.deliveryno and di.item_no = dr.itemno)
   left join strang.receivals r on (dr.deliveryno = r.deliveryno)
   where (( sm.complete in ('A','D','F','P','W','S')))
    and  sm.smp_no = vsmp_no
   ) tmp
  where tmp.max_unit <> cnt;

 cursor c3(vsmp_no varchar2) is
   select complete, movement_no, seal from strang.smp where smp_no = vsmp_no and movement_no is not null;
 
 
 c1rec c1%ROWTYPE;
 c2rec c2%ROWTYPE;
 c3rec c3%ROWTYPE;
 vsmp_type varchar2(100);
 vsmp_mode varchar2(100);
 vsmp_status varchar2(100);
 vtare varchar2(100);
 vUrgency varchar2(100);
 vhazard  varchar2(100);
 vClient integer;
 vCurrent_location varchar2(100);
 vWarehouse_location varchar2(100);
 vUpdated_by varchar2(100);
 vScan_key integer;
 vsmp_length varchar2(100) :=0 ;
 vsmp_width varchar2(100) := 0;
 vsmp_height varchar2(100) := 0;
 vweight   number;
 vvolume   number(15,3);
 vrevton   number(15,3);
 vchgwgt   number;
 

 begin
 
   for j in val1.first..val1.last loop
     case val1(j)
--        when 'SMP_PACKTYPES' then 
--            vsmp_type := val2(j);
        when 'HAZARD_CLASS' then 
            vhazard := val2(j); 
--        when 'CUSTOMER' then 
--            begin vClient := to_number(val2(j)); exception when others then vClient := null; end; 
--        when 'SMP_MODE' then 
--            vsmp_mode := val2(j); 
        when 'SMP_STATUS' then 
            vsmp_status := val2(j); 
        when 'CURRENT_LOCATION' then 
            vCurrent_location := val2(j); 
--        when 'WAREHOUSE_LOCATION' then 
--            vWarehouse_location := val2(j);         
--        when 'TARE' then 
--            vTare := val2(j);  
--        when 'URGENCY' then 
--            vUrgency := val2(j);             
        when 'SMP_LENGTH' then 
            vsmp_length := val2(j);           
        when 'SMP_WIDTH' then 
            vsmp_width := val2(j);  
        when 'SMP_HEIGHT' then 
            vsmp_height := val2(j);                      
        when 'UPDATED_BY' then 
            vUpdated_by := val2(j);  
--        when 'SCAN_KEY' then     
--            begin vScan_key := to_number(val2(j)); exception when others then vScan_key := null; end; 
        else null;  
     end case;         
   end loop;

   open c1( pk1);
   fetch c1 into c1rec;
   if c1%notfound then 
      external_audit( '9', '9c (Amend SMP)  Unable to amend SMP as smp_no does not exist', pk1, null, null );
      close c1;
      --raise e_No_SMP_Exists;
      msg := 'Error: Unable to amend SMP as smp_no does not exist';
      err( msg, 404, TRUE);
      return;
   end if;
   close c1;
   
   if vsmp_status <> 'F' then
     open c2( pk1);
     fetch c2 into c2rec;
     if c2%found and c1rec.complete = 'F' then 
        external_audit( '9', '9c (Amend SMP)  Unable to complete SMP - missing units', pk1, null, null );
        close c2;
        msg := 'Error: Unable to complete '||c1rec.smp_no||'. Deliveryno: '||c2rec.deliveryno||'-'||c2rec.item_no||' contains missing units';
        err( msg, 404, TRUE);
        return;
     end if;
     close c2;
   end if; 
        
    
   vvolume := nvl(((vsmp_length/100) * (vsmp_width/100) * (vsmp_height/100)),0.000);
   
   websys.strangp.recalc_weight_smp( c1rec.rid, null);
   
   update strang.smp sm
   set  --smp_type= nvl(vsmp_type,smp_type) 
--      , urgency = nvl(vUrgency,urgency) 
  --   , client_id = nvl(vClient,client_id)
      current_location = nvl(vCurrent_location,current_location)
     , complete = nvl(vsmp_status,complete) 
  --   , sa = nvl(vsmp_mode,sa) 
     , hazard_class = nvl(vhazard,hazard_class) 
 --    , location_in_warehouse = nvl(vWarehouse_location,location_in_warehouse)
     , modified_date = sysdate
     , tare = nvl(vtare,tare)  -- DONE
     , smp_length_in_cmtrs = nvl(vsmp_length, smp_length_in_cmtrs)
     , smp_width_in_cmtrs = nvl(vsmp_width, smp_width_in_cmtrs)
     , smp_height_in_cmtrs = nvl(vsmp_height, smp_height_in_cmtrs)
     , modified_by = vUpdated_by
     , smp_volume_in_mtrs = vvolume  -- added by David Banjo
     , revton = strang.revenue_tonne(nvl(sumweight,0.0) + nvl(tare,0.0),vvolume)
     , chargeweight = strang.chargeable_weight(nvl(sumweight,0.0) + nvl(tare,0.0),vvolume)
     , packed_date = case when sm.complete = 'F' and vsmp_status = 'P' then sysdate 
                          when sm.complete = 'P' and vsmp_status = 'F' then null else packed_date end
     , packed_by = case when sm.complete = 'F' and vsmp_status = 'P' then vUpdated_by
                        when sm.complete = 'P' and vsmp_status = 'F' then null else packed_by end       
   where smp_no = pk1;
                                 
   if sql%rowcount <> 0
     then
      external_audit( '9', 'transaction_interface9c (Amend SMP): SMP Processed Successfully', pk1, val1(1)||':'||val2(1), ctr, sz);
   else
      external_audit( '9', 'transaction_interface9c (Amend SMP): Failed to Amend SMP', pk1, val1(1)||':'||val2(1), ctr, sz);
      msg := 'Error: Failed to Amend SMP';
      err( msg, 404, TRUE);
      return;
   end if; 
      
   commit;
  
 exception
  when e_No_SMP_Exists  then  null;
  when others then
   external_audit( '9', 'transaction_interface9c (Amend SMP) Failed:' || pk1, val1(1)||':'||val2(1),val1(2)||':'||val2(2), ctr, sz, sqlerrm );
   msg := sqlerrm;
 end transaction_interface9c;
 procedure process_interface9( x in owa.vc_arr, y in owa.vc_arr, fname in varchar )
 as

  cursor c1(fnm varchar2) is select * from apache_ows_content where name = fnm;
  cursor c2(jname varchar2) is select * from user_scheduler_jobs where job_name like jname;
  cursor c3( smp varchar2 ) is select rowid rid from strang.smp where upper(smp) = upper(smp_no);
  

  c1rec 	    c1%ROWTYPE;
  c2rec		    c2%ROWTYPE;
  c3rec		    c3%ROWTYPE;
  clb           clob;
  p 		    DBMS_XMLPARSER.parser;
  dest_offset   integer;
  src_offset    integer;
  lang_context  integer;
  warning       varchar2(1000);
  doc 		    dbms_xmldom.DOMDocument;
  n 		    dbms_xmldom.DOMNode;
  nl 		    dbms_xmldom.DOMNodeList;
  e 		    dbms_xmldom.DOMElement;
  n_child 	    dbms_xmldom.DOMNode;
  tag		    varchar2(1000);
  len1 		    number;
  ctr		    integer;
  vaction       varchar2(100);
  jname		    varchar2(100);
  verr		    varchar2(4000);
  pk1		    varchar2(100);
  msg           varchar2(200);
  val1		    owa.vc_arr;
  val2          owa.vc_arr;
  sz		    integer;
  c             integer := 0;


 begin
 
   open c1( fname );
   fetch c1 into c1rec;
   close c1;
   if c1rec.mime_type <> 'text/xml'
    then
     cleanup(fname,TRUE);
     err( '[1046] File is not XML (mimetype not text/xml)', 404, TRUE);
     return;
   end if;

   dbms_lob.createtemporary( clb, FALSE );
   p := DBMS_XMLPARSER.newParser;
   DBMS_XMLPARSER.setValidationMode(p, FALSE);

   dest_offset := 1;
   src_offset := 1;
   lang_context := 0;
   dbms_lob.converttoclob( clb, c1rec.blob_content, dbms_lob.getlength( c1rec.blob_content ), dest_offset, src_offset, 0, lang_context, warning );
 
   sz := dbms_lob.getlength(clb);

   DBMS_XMLPARSER.parseClob(p, clb );
   doc := DBMS_XMLPARSER.getDocument(p);

   htp.init;
   owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
   htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
   owa_util.http_header_close;

    nl := dbms_xmldom.getElementsByTagName(doc, '*');
    len1 := dbms_xmldom.getLength(nl);
    ctr := 0;

    for j in 0..len1-1 loop
     n := dbms_xmldom.item(nl, j);
     e := dbms_xmldom.makeElement(n);
     n_child:= dbms_xmldom.getFirstChild(n);
     tag := upper(trim(dbms_xmldom.getTagName(e)));
      
       
     if tag in ('ADD_SMP', 'DELETE_SMP','AMEND_SMP')
      then
       ctr := ctr + 1;
       dbms_output.put_line('ctr = '||ctr);
       vaction := tag;
      else
       case tag
        when 'SMP_NO' then pk1  := dbms_xmldom.getNodeValue(n_child);
        when 'SMP_PACKTYPES' then 
            c:= c+1;
            val1(c) := 'SMP_PACKTYPES';
            val2(c) := dbms_xmldom.getNodeValue(n_child);
        when 'HAZARD_CLASS' then 
            c:= c+1;
            val1(c) := 'HAZARD_CLASS';
            val2(c) := dbms_xmldom.getNodeValue(n_child); 
        when 'CUSTOMER' then 
            c:= c+1;
            val1(c) := 'CUSTOMER';
            val2(c) := dbms_xmldom.getNodeValue(n_child);       
        when 'SMP_MODE' then 
            c:= c+1;
            val1(c) := 'SMP_MODE';
            val2(c) := dbms_xmldom.getNodeValue(n_child);        
        when 'SMP_STATUS' then 
            c:= c+1;
            val1(c) := 'SMP_STATUS';
            val2(c) := dbms_xmldom.getNodeValue(n_child);       
        when 'CURRENT_LOCATION' then 
            c:= c+1;
            val1(c) := 'CURRENT_LOCATION';
            val2(c) := dbms_xmldom.getNodeValue(n_child);           
        when 'WAREHOUSE_LOCATION' then 
            c:= c+1;
            val1(c) := 'WAREHOUSE_LOCATION';
            val2(c) := dbms_xmldom.getNodeValue(n_child);    
        when 'TARE' then 
            c:= c+1;
            val1(c) := 'TARE';
            val2(c) := dbms_xmldom.getNodeValue(n_child);    
        when 'URGENCY' then 
            c:= c+1;
            val1(c) := 'URGENCY'; --
            val2(c) := dbms_xmldom.getNodeValue(n_child);    
        when 'SCAN_KEY' then 
            c:= c+1;
            val1(c) := 'SCAN_KEY'; --
            val2(c) := dbms_xmldom.getNodeValue(n_child);
        when 'SMP_LENGTH' then 
            c:= c+1;
            val1(c) := 'SMP_LENGTH'; --
            val2(c) := dbms_xmldom.getNodeValue(n_child);    
        when 'SMP_WIDTH' then 
            c:= c+1;
            val1(c) := 'SMP_WIDTH'; --
            val2(c) := dbms_xmldom.getNodeValue(n_child);      
        when 'SMP_HEIGHT' then 
            c:= c+1;
            val1(c) := 'SMP_HEIGHT'; --
            val2(c) := dbms_xmldom.getNodeValue(n_child);      
        when 'UPDATED_BY' then 
            c:= c+1;
            val1(c) := 'UPDATED_BY';
            val2(c) := dbms_xmldom.getNodeValue(n_child);    
        else null;
       end case;

     end if;
    end loop;
    
    if vaction = 'ADD_SMP' then
       transaction_interface9a (pk1,val1, val2, ctr, sz, msg);
    elsif vaction = 'DELETE_SMP' then
       transaction_interface9b (pk1, ctr, sz, msg);
    elsif vaction = 'AMEND_SMP' then
       transaction_interface9c (pk1, val1, val2, ctr, sz, msg);
    end if;

    if vaction = 'AMEND_SMP' then
      open c3(pk1);
      fetch c3 into c3rec;
      if c3%found then
        websys.strangp.recalc_weight_smp( c3rec.rid, null );
      end if;
      close c3;
    end if;


   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
   if msg is null then
      htp.p( '<result>XML File pushed</result>');
   else
      htp.p( '<result>'||msg||'</result>');
   end if;

 exception
  when others then
   verr := sqlerrm;
   err( '[1360] Err in process_SMP (Maintenance):'||' pk1 '|| pk1||' '|| verr, 404, TRUE);
   external_audit( '9', 'transaction_interface9 (Process Cargo/Air SMP): Failed:' || c1rec.name, ctr, sz, sqlerrm );
   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
 end process_interface9;
 
procedure process_interface10( x in owa.vc_arr, y in owa.vc_arr, fname in varchar )
 as

  cursor c1(fnm varchar2) is select * from apache_ows_content where name = fnm;
  cursor c2(jname varchar2) is select * from user_scheduler_jobs where job_name like jname;
  
  cursor c3(vmov varchar2, vseal varchar2) is
    select m.*
      from strang.movements m
     where m.movement_no = vmov
       and nvl(m.seal,'|') = nvl(vseal,'|');

  c1rec 	    c1%ROWTYPE;
  c2rec		    c2%ROWTYPE;
  c3rec		    c3%ROWTYPE;
  
  e_wrong_mime_type EXCEPTION;
  PRAGMA exception_init( e_wrong_mime_type , -20001 );

  l_bfile  BFILE;
  l_blob   BLOB;
  v_dir         varchar2(150);
  v_file        varchar2(1000);
  v_ext         varchar2(50);
  l_dest_offset INTEGER := 1;
  l_src_offset  INTEGER := 1;
  vPicLocation varchar2(50);
  vmov varchar2(100);
  vseal varchar2(100);
  msg varchar2(200);
  verr varchar2(200);
  v_flag integer;
  
BEGIN
  
     if x.exists(3) and x.exists(4)
     then
      vmov := x(3);
      vseal := x(4);
      open c3(vmov, vseal);
      fetch c3 into c3rec;
      if c3%notfound then
         err( '[1010] Err in process_movement_photo:' || 'Movement_no/Seal not found [' || vmov || ']/['|| vseal ||']', 404, TRUE);
         close c3;
         return;
      end if;
      close c3;
     else
      err( '[1011] Err in process_movement_photo:' || 'No Movement_no/Seal provided', 404, TRUE);
      return;
    end if;
    
    if x.exists(5) then
       vPicLocation := upper(x(5));
       if upper(vPicLocation) not in ('INSIDE', 'FRONT') then
          external_audit( '10', 'transaction_interface10 (Process Movement Photos: Failed:' || vmov, vseal, null, 'Photo of Container: Only Inside and Front allowed' );
          msg := 'Photo of Container: Only Inside and Front allowed';
          raise_application_error(-20001,'Photo of Container: Only Inside and Front allowed');
       end if;
    else
      vPicLocation := 'INSIDE';
    end if;


   open c1(fname );
   fetch c1 into c1rec;
   close c1;
  
   v_ext := regexp_substr(regexp_substr(c1rec.mime_type, '[^./]+$', 1, 1, 'i'),'[^.-]+$', 1, 1, 'i');
  
  if v_ext <> 'png' then
    external_audit( '10', 'transaction_interface10 (Process Movement Photos: Failed:' || vmov, vseal, null, 'mime type not png' );
    msg := 'mime type not png';
    raise_application_error(-20001,'Mime type is not png');
  end if;

  open c1( fname );
  fetch c1 into c1rec;
  if c1%FOUND
   then
   -- 'c:\temp'
    v_dir := websys.glbx.extract_master_parameter('STRANG_RECEIVALS_DIR')|| websys.decs.UNIX_OR_NT || c3rec.movement_no||'_'||nvl(c3rec.seal,'none') || websys.decs.UNIX_OR_NT || vPicLocation ;
	v_file := c3rec.movement_no||'_'||nvl(c3rec.seal,'none')||'_'||vPicLocation||'.'||v_ext; ---glbx.extract_fname(c3rec.name, 'FILE');
    if websys.utl_os.mkdir(v_dir) then null; end if;
      websys.utl_blob.blobtofile(c1rec.blob_content, v_dir || websys.decs.UNIX_OR_NT || v_file, FALSE);
	  if websys.file_exists(v_dir, v_file)
	   then
	    msg := msg || 'File saved: ' || v_file || '<br>';
	    external_audit( '10', 'transaction_interface10: Movement Photo Processed Successfully', vmov, vseal, 0, 0);
      else
        external_audit( '10', 'transaction_interface10: Failed to Process Movement Photo', vmov, vseal, 0, 0);
	    msg := msg || 'File NOT saved: ' || v_file || '<br>';
	  end if;
	-- end if;
  end if;
  close c1;
 --delete from apache_ows_content where name = fname; commit;
-- end loop;

   if c3rec.attached_photo is null and vPicLocation = 'FRONT' then
      v_flag := 1;
   elsif c3rec.attached_photo is null and vPicLocation = 'INSIDE' then
      v_flag := 2;
   elsif c3rec.attached_photo = 3 then 
      v_flag := 3;
   elsif c3rec.attached_photo = 2 and vPicLocation = 'INSIDE' then
      v_flag := 2;
   elsif c3rec.attached_photo = 1 and vPicLocation = 'INSIDE' then
      v_flag := 3;
   elsif c3rec.attached_photo = 1 and vPicLocation = 'FRONT' then
      v_flag := 1;
   elsif c3rec.attached_photo = 2 and vPicLocation = 'FRONT' then
      v_flag := 3;
   end if;
   
   update strang.movements m
    set attached_photo = v_flag
    where m.movement_no = vmov
    and nvl(m.seal,'|') = nvl(vseal,'|');  
 

   COMMIT;
   cleanup(fname,FALSE); 
   if msg is null then
      htp.p( '<result>XML File pushed</result>');
   else
      htp.p( '<result>'||msg||'</result>');
   end if;

 exception
  when others then   verr := sqlerrm;
   err( '[1360] Err in process_Movement_Photos:'||' Movement_no '|| vmov||'  Seal '||vseal||' ' || verr, 404, TRUE);
   external_audit( '10', 'transaction_interface10 (Process Movement Photos: Failed:' || vmov, vseal, null, sqlerrm );
  -- begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
END process_interface10;
 
procedure process_unpack_container ( x in owa.vc_arr, y in owa.vc_arr )
 as
 
 cursor c1( vmov varchar2, vseal varchar2) is
 select movement_no, seal, unpack_exceptions_flag, unpack_exceptions_approved_by, unpack_completed_by, smp_no, unpacked_flag, unpacked_missing_flag, unpacked_extra_flag, cnt,  sum(cnt) over ( partition by movement_no, seal, smp_no) total -- cnt_unpacked, cnt_missing, total
        , lag(tmp.smp_no) over (partition by movement_no, seal  order by smp_no nulls first) prev_smp_no
        , lead(tmp.smp_no) over (partition by movement_no, seal  order by smp_no nulls first) next_smp_no
        , lag(tmp.unpacked_flag) over (partition by movement_no, seal, smp_no order by unpacked_flag nulls first) prev_unpacked_flag
        , lead(tmp.unpacked_flag) over (partition by movement_no, seal, smp_no order by unpacked_flag nulls first) next_unpacked_flag
        , lag(tmp.unpacked_missing_flag) over (partition by movement_no, seal, smp_no order by unpacked_flag nulls first, unpacked_missing_flag nulls first ) prev_unpacked_missing_flag
        , lead(tmp.unpacked_missing_flag) over (partition by movement_no, seal, smp_no order by unpacked_flag nulls first, unpacked_missing_flag nulls first ) next_unpacked_missing_flag
        , lag(tmp.unpacked_extra_flag) over (partition by movement_no, seal, smp_no order by unpacked_flag nulls first, unpacked_missing_flag nulls first, unpacked_extra_flag nulls first ) prev_unpacked_extra_flag
        , lead(tmp.unpacked_extra_flag) over (partition by movement_no, seal, smp_no order by unpacked_flag nulls first, unpacked_missing_flag nulls first, unpacked_extra_flag nulls first  ) next_unpacked_extra_flag
   from (SELECT  t.movement_no, t.seal, t.unpack_exceptions_flag, t.unpack_exceptions_approved_by, t.unpack_completed_by, nvl(t.smp_no,'NOSMP') smp_no, t.unpacked_flag 
                ,case when t.unpacked_flag = 'Y' then null when t.unpacked_extra_flag = 'Y' then null else t.unpacked_missing_flag end unpacked_missing_flag
                ,case when t.unpacked_flag = 'Y' then null when t.unpacked_missing_flag = 'Y' then null else t.unpacked_extra_flag end as unpacked_extra_flag
                ,count(distinct t.deliveryno||t.item_no||t.order_by) cnt 
          FROM ( SELECT m.movement_no, m.seal, m.unpack_exceptions_flag, m.unpack_exceptions_approved_by, m.unpack_completed_by, sm.smp_no, di.deliveryno, di.ITEM_NO, di.ORDER_BY, di.unpacked_flag
                      , case when di.unpacked_flag = 'Y' then null else di.unpacked_missing_flag end unpacked_missing_flag
                      , null unpacked_extra_flag
         --      , count(distinct di.deliveryno||di.item_no||di.order_by) cnt  --, max(count(*) over (partition by m.movement_no, m.seal,di.smp_no)) total    
                   FROM strang.movements m 
                 INNER JOIN strang.detailrs_item di on (m.movement_no = di.movement_no and nvl(m.seal, '|') = nvl(di.seal,'|'))
                  LEFT JOIN strang.smp sm on (di.smp_no = sm.smp_no and sm.movement_no = m.movement_no and nvl(sm.seal,'|') = nvl(m.seal,'|'))
                      WHERE m.movement_type in ( 'CARGO')
                        AND m.IO = 'I'
                        AND m.scan_key is not null
                        AND m.current_location in ( 'TAB', 'KUI', 'MOT')
                        AND m.departure = 'BNE'
                        AND m.movement_no = vmov  
                        AND ( vseal IS NULL OR UPPER(m.seal) = UPPER(vseal)) 
                        AND ( EXISTS (SELECT 'x' 
                                        FROM strang.detailrs_item di, strang.receivals r 
                                       WHERE r.deliveryno = di.deliveryno
                                         AND m.movement_no = di.movement_no
                                         AND nvl(m.seal,'|') = nvl(di.seal,'|')
                                         AND nvl(r.currdate, trunc(sysdate))  > TO_DATE('1 Jan 2018','DD MON YYYY')))
                 UNION ALL       
                 SELECT m.movement_no, m.seal, m.unpack_exceptions_flag, m.unpack_exceptions_approved_by, m.unpack_completed_by, ue.actual_smp, di.deliveryno, di.ITEM_NO, di.ORDER_BY, di.unpacked_flag
                      , CASE WHEN di.unpacked_flag = 'Y' THEN NULL WHEN di.unpacked_extra_flag = 'Y' THEN NULL ELSE di.unpacked_missing_flag END
                      , CASE WHEN di.unpacked_flag = 'Y' THEN NULL WHEN di.unpacked_missing_flag = 'Y' THEN NULL 
                                ELSE di.unpacked_extra_flag END unpacked_extra_flag
                   FROM strang.movements m 
                 INNER JOIN strang.unpack_extras ue on (m.movement_no = ue.actual_container and nvl(m.seal, '|') = nvl(ue.actual_seal,'|')) -- and (ue. actual_smp is null or sm.smp_no = ue.actual_smp)) 
                 INNER JOIN strang.detailrs_item di on (di.deliveryno = ue.deliveryno and di.item_no = ue.item_no and di.order_by = ue.order_by) 
                  WHERE m.movement_type in ( 'CARGO')
                    AND m.IO = 'I'
                    AND m.scan_key is not null
                    AND m.current_location in ( 'TAB', 'KUI', 'MOT')
                    AND m.departure = 'BNE'
                    AND m.movement_no = vmov  --'OTMU2509152'  
                 --   AND ('01648' is null or UPPER(m.seal) = UPPER('01648')) 
                    AND (vseal is null or UPPER(m.seal) = UPPER(vseal)) 
                    AND ( EXISTS
                           (SELECT 'x' 
                              FROM strang.detailrs_item di, strang.receivals r 
                             WHERE r.deliveryno = di.deliveryno
                               AND m.movement_no = di.movement_no
                               AND nvl(m.seal,'|') = nvl(di.seal,'|')
                               AND nvl(r.currdate, trunc(sysdate))  > to_date('1 Jan 2018','DD MON YYYY')))) t
        GROUP BY t.movement_no, t.seal, t.unpack_exceptions_flag, t.unpack_exceptions_approved_by, t.unpack_completed_by, t.smp_no, t.unpacked_flag, 
                 CASE WHEN t.unpacked_flag = 'Y' THEN NULL WHEN t.unpacked_extra_flag = 'Y' THEN NULL ELSE t.unpacked_missing_flag END,
                 CASE WHEN t.unpacked_flag = 'Y' THEN NULL 
                      WHEN t.unpacked_missing_flag = 'Y' THEN NULL 
                        ELSE t.unpacked_extra_flag END ) tmp
   ORDER BY tmp.movement_no, tmp.seal, tmp.smp_no nulls first, tmp.unpacked_flag nulls last, tmp.unpacked_missing_flag nulls last, tmp.unpacked_extra_flag nulls last; 
 
 
-- select movement_no, seal, smp_no, unpacked_flag, cnt, total
--        , lag(tmp.smp_no) over (partition by movement_no, seal  order by smp_no nulls first) prev_smp_no
--        , lead(tmp.smp_no) over (partition by movement_no, seal  order by smp_no nulls first) next_smp_no
--        , lag(tmp.unpacked_flag) over (partition by movement_no, seal, smp_no order by unpacked_flag nulls first) prev_unpacked_flag
--        , lead(tmp.unpacked_flag) over (partition by movement_no, seal, smp_no order by unpacked_flag nulls first) next_unpacked_flag
-- from ( select m.movement_no, m.seal, sm.smp_no, di.unpacked_flag,
--         count(distinct di.deliveryno||di.item_no||di.order_by) over (partition by m.movement_no, m.seal,di.smp_no, di.unpacked_flag) cnt,
--         count(distinct di.deliveryno||di.item_no||di.order_by) over (partition by m.movement_no, m.seal,di.smp_no) total,
--         row_number() over ( partition by m.movement_no, m.seal,di.smp_no, di.unpacked_flag order by di.smp_no, di.unpacked_flag,di.unpacked_date desc, di.packed_date desc) rnk
--    from strang.movements m 
--   inner join strang.detailrs_item di on (m.movement_no = di.movement_no and nvl(m.seal, '|') = nvl(di.seal,'|'))
--    left join strang.smp sm on (di.smp_no = sm.smp_no and sm.movement_no = m.movement_no and nvl(sm.seal,'|') = nvl(m.seal,'|'))
--   where m.movement_type in ( 'CARGO')
--     and m.IO = 'I'
--     and m.scan_key is not null
--     and m.current_location in ( 'TAB', 'KUI', 'MOT')
--     and m.departure = 'BNE'
--     and m.movement_no = vmov  
--     and (vseal is null or UPPER(m.seal) = UPPER(vseal)) 
--  --   and m.movement_no = 'OTMU2509152'  
--   --  and ('01648' is null or UPPER(m.seal) = UPPER('01648')) 
--     and ( exists
--            (select 'x' 
--               from strang.detailrs_item di, strang.receivals r 
--              where r.deliveryno = di.deliveryno
--                and m.movement_no = di.movement_no
--                and nvl(m.seal,'|') = nvl(di.seal,'|')
--                and nvl(r.currdate, trunc(sysdate))  > to_date('1 Jan 2018','DD MON YYYY'))))tmp  
-- where tmp.rnk = 1                       
-- order by tmp.movement_no, tmp.seal, tmp.smp_no nulls first, tmp.unpacked_flag nulls first;  
 
   cursor c2( vmov varchar2, vseal varchar2, vsmp varchar2, vdeliveryno varchar2, vitemno varchar2, vunitno varchar2) is 
   select tmp.movement_no, tmp.seal, tmp.smp_no, count(*) over () cnt, tmp.deliveryno, tmp.itemno itemno
        , tmp.order_by unit_no
        , to_char(tmp.packed_date,'DD-Mon-RR HH24:MI:SS') packed_date
        , row_number() over (partition by tmp.movement_no, tmp.seal, smp_no order by tmp.packed_date desc) unit_packed_date_rnk
       -- , case when di.unpacked_date is not null then  row_number() over (partition by m.movement_no, m.seal order by di.unpacked_date desc ) else null end unit_unpacked_date_rnk
     --   , dense_rank() over (partition by tmp.movement_no, tmp.seal, tmp.smp_no order by tmp.unpacked_date desc nulls last) unit_unpacked_date_rnk
        , case when tmp.unpacked_date is null then null
               else row_number() over (partition by tmp.movement_no, tmp.seal, tmp.smp_no order by tmp.unpacked_date desc nulls last) end unit_unpacked_date_rnk
        , (select max(di1.order_by) from strang.detailrs_item di1 where di1.deliveryno = tmp.deliveryno and di1.item_no = tmp.itemno) max_unit
        , tmp.order_by ||' of '|| (select max(di1.order_by) from strang.detailrs_item di1 where di1.deliveryno = tmp.deliveryno and di1.item_no = tmp.itemno) unit_part
        , tmp.unpacked_flag
        , to_char(tmp.unpacked_date,'DD-Mon-RR HH24:MI:SS') unpacked_date 
     --   , tmp.unpacked_date 
        , tmp.unpacked_by
        , tmp.unpacked_missing_flag
      --  , tmp.unpacked_missing_date 
        , to_char(tmp.unpacked_missing_date,'DD-Mon-RR HH24:MI:SS') unpacked_missing_date 
        , tmp.unpacked_missing_by
        , tmp.unpacked_extra_flag
      --  , tmp.unpacked_extra_date 
        , to_char(tmp.unpacked_extra_date,'DD-Mon-RR HH24:MI:SS') unpacked_extra_date  
        , tmp.unpacked_extra_by
        , lag(tmp.deliveryno) over (partition by tmp.movement_no, tmp.seal, tmp.smp_no order by tmp.deliveryno, tmp.itemno) prev_deliveryno
        , lead(tmp.deliveryno) over (partition by tmp.movement_no, tmp.seal, tmp.smp_no order by tmp.deliveryno, tmp.itemno) next_deliveryno
        , lag(tmp.itemno) over (partition by tmp.movement_no, tmp.seal, tmp.smp_no, tmp.deliveryno  order by tmp.itemno, tmp.order_by) prev_itemno
        , lead(tmp.itemno) over (partition by tmp.movement_no, tmp.seal, tmp.smp_no, tmp.deliveryno order by tmp.itemno, tmp.order_by) next_itemno
  from  (SELECT m.movement_no, m.seal, sm.smp_no, dr.deliveryno, dr.itemno, di.order_by, di.packed_date
              , di.unpacked_flag, di.unpacked_date, di.unpacked_by,  di.unpacked_missing_flag, di.unpacked_missing_date, di.unpacked_missing_by
              , null unpacked_extra_flag, null unpacked_extra_date, null unpacked_extra_by    
          FROM strang.movements m 
          INNER JOIN strang.detailrs_item di on (m.movement_no = di.movement_no and nvl(m.seal, '|') = nvl(di.seal,'|'))
          INNER JOIN strang.receivals r on (di.deliveryno = r.deliveryno)
          LEFT JOIN strang.detailrs dr on (di.deliveryno = dr.deliveryno and di.item_no = dr.itemno)
          LEFT JOIN strang.smp sm on (di.smp_no = sm.smp_no and sm.movement_no = m.movement_no and nvl(sm.seal,'|') = nvl(m.seal,'|'))
          WHERE m.movement_type in ('CARGO')
          --      and m.movement_no = 'OTMU2509152'   
          and m.movement_no = vmov  
          and (vseal is null or UPPER(m.seal) = UPPER(vseal))
          --  and ('01648' is null or UPPER(m.seal) = UPPER('01648'))
          and m.departure = 'BNE'
          and m.io = 'I'
          and (vsmp is null or NVL(UPPER(di.smp_no),'NOSMP') = NVL(UPPER(vsmp), 'NOSMP'))
          and m.scan_key is not null
          and m.current_location in ('TAB', 'KUI', 'MOT')
---------------------------------------------------------------------------------------------------------------------------
          AND ((di.deliveryno = vdeliveryno and vdeliveryno is not null) or (vdeliveryno is null and di.deliveryno is not null))
          AND ((di.item_no = vitemno and vitemno is not null) or (vitemno is null and di.item_no is not null))
          AND ((di.order_by = vunitno and vunitno is not null) or (vunitno is null and di.order_by  is not null)) 
---------------------------------------------------------------------------------------------------------------------------
          AND ( EXISTS
                  (SELECT 'x' 
                     FROM strang.detailrs_item di, strang.receivals r 
                    WHERE r.deliveryno = di.deliveryno
                      AND m.movement_no = di.movement_no
                      AND NVL(m.seal,'|') = NVL(di.seal,'|')
                      AND NVL(r.currdate, TRUNC(SYSDATE))  > TO_DATE('1 Jan 2018','DD MON YYYY')))   
          UNION ALL            
          SELECT m.movement_no, m.seal, ue.actual_smp, di.deliveryno, di.item_no, di.order_by unit_no, di.packed_date
               , null unpacked_flag, null unpacked_date, null unpacked_by,  null unpacked_missing_flag, null unpacked_missing_date, null unpacked_missing_by
               , di.unpacked_extra_flag, di.unpacked_extra_date,di.unpacked_extra_by   
            FROM strang.movements m 
           INNER JOIN strang.unpack_extras ue on (m.movement_no = ue.actual_container and nvl(m.seal, '|') = nvl(ue.actual_seal,'|')) 
           INNER JOIN strang.detailrs_item di on (di.deliveryno = ue.deliveryno and di.item_no = ue.item_no and di.order_by = ue.order_by) 
           WHERE m.movement_type in ( 'CARGO')
             AND m.IO = 'I'
             AND m.scan_key is not null
             AND m.current_location in ( 'TAB', 'KUI', 'MOT')
             AND m.departure = 'BNE'
             AND m.movement_no = vmov  
             AND (vseal is null or UPPER(m.seal) = UPPER(vseal))
             -- AND m.movement_no = 'OTMU2509152'  
             -- AND ('01648' is null or UPPER(m.seal) = UPPER('01648')) 
            -- and (ue. actual_smp is null or sm.smp_no = ue.actual_smp)) 
             and (vsmp is null or NVL(UPPER(ue.actual_smp),'NOSMP') = NVL(UPPER(vsmp), 'NOSMP') )
             AND ((di.deliveryno = vdeliveryno and vdeliveryno is not null) or (vdeliveryno is null and di.deliveryno is not null))
             AND ((di.item_no = vitemno and vitemno is not null) or (vitemno is null and di.item_no is not null))
             AND ((di.order_by = vunitno and vunitno is not null) or (vunitno is null and di.order_by  is not null))  
             -- AND ((di.deliveryno = vdeliveryno and vdeliveryno is not null) or (vdeliveryno is null and di.deliveryno is not null))
             -- AND ((di.item_no = vitemno and vitemno is not null) or (vitemno is null and di.item_no is not null))
             -- AND ((di.order_by = vunitno and vunitno is not null) or (vunitno is null and di.order_by  is not null))  
             AND ( EXISTS
                    (SELECT 'x' 
                       FROM strang.detailrs_item di
                          , strang.receivals r 
                      WHERE r.deliveryno = di.deliveryno
                        AND m.movement_no = di.movement_no
                        AND nvl(m.seal,'|') = nvl(di.seal,'|')
                        AND nvl(r.currdate, trunc(sysdate))  > to_date('1 Jan 2018','DD MON YYYY')))) tmp                                           
    ORDER BY tmp.movement_no, tmp.seal, tmp.smp_no, tmp.deliveryno, tmp.itemno, tmp.order_by;  



--  cursor c2( vmov varchar2, vseal varchar2, vsmp varchar2, vdeliveryno varchar2, vitemno varchar2, vunitno varchar2) is
--  select m.movement_no, m.seal, sm.smp_no, count(*) over () cnt, dr.deliveryno, dr.itemno
--        , di.order_by unit_no
--        , to_char(di.packed_date,'DD-Mon-RR HH24:MI:SS') packed_date
--        , row_number() over (partition by m.movement_no, m.seal order by di.packed_date desc) unit_packed_date_rnk
--       -- , case when di.unpacked_date is not null then  row_number() over (partition by m.movement_no, m.seal order by di.unpacked_date desc ) else null end unit_unpacked_date_rnk
--        , dense_rank() over (partition by m.movement_no, m.seal order by di.unpacked_date desc nulls last) unit_unpacked_date_rnk
--        , (select max(di1.order_by) from strang.detailrs_item di1 where di1.deliveryno = dr.deliveryno and di1.item_no = dr.itemno) max_unit
--        , di.order_by ||' of '|| (select max(di1.order_by) from strang.detailrs_item di1 where di1.deliveryno = dr.deliveryno and di1.item_no = dr.itemno) unit_part
--        , di.unpacked_flag
--        , di.unpacked_date 
--        , lag(dr.deliveryno) over (partition by m.movement_no, m.seal order by dr.deliveryno, dr.itemno) prev_deliveryno
--        , lead(dr.deliveryno) over (partition by m.movement_no, m.seal order by dr.deliveryno, dr.itemno) next_deliveryno
--        , lag(di.item_no) over (partition by m.movement_no, m.seal, di.deliveryno  order by di.item_no, di.order_by) prev_itemno
--        , lead(di.item_no) over (partition by m.movement_no, m.seal, di.deliveryno order by di.item_no, di.order_by) next_itemno
--    from strang.movements m 
--     inner join strang.detailrs_item di on (m.movement_no = di.movement_no and nvl(m.seal, '|') = nvl(di.seal,'|'))
--     inner join strang.receivals r on (di.deliveryno = r.deliveryno)
--     left join strang.detailrs dr on (di.deliveryno = dr.deliveryno and di.item_no = dr.itemno)
--     left join strang.smp sm on (di.smp_no = sm.smp_no and sm.movement_no = m.movement_no and nvl(sm.seal,'|') = nvl(m.seal,'|'))
--   where m.movement_type in ('CARGO')
--     and m.movement_no = vmov  
--     and (vseal is null or UPPER(m.seal) = UPPER(vseal))
--    -- and ('01648' is null or UPPER(m.seal) = UPPER('01648'))
--     and m.departure = 'BNE'
--     and m.io = 'I'
--     and (vsmp is null or NVL(UPPER(di.smp_no),'NOSMP') = NVL(UPPER(vsmp), 'NOSMP') )
--     --and ('NOSMP' is null or NVL(UPPER(di.smp_no),'NOSMP') = NVL(UPPER('NOSMP'), 'NOSMP') )
--     --and ( NVL(UPPER(m.seal),'NOSMP') = NVL(UPPER(vsmp), 'NOSMP') )
--    -- and (null is null or UPPER(m.seal) = UPPER(null))
--   --  and sm.smp_no = 'SMP10228'  -- vseal 
--     and m.scan_key is not null
--     and m.current_location in ('TAB', 'KUI', 'MOT')
-----------------------------------------------------------------------------------------------------------------------------
--     and ((di.deliveryno = vdeliveryno and vdeliveryno is not null) or (vdeliveryno is null and di.deliveryno is not null))
--     and ((di.item_no = vitemno and vitemno is not null) or (vitemno is null and di.item_no is not null))
--     and ((di.order_by = vunitno and vunitno is not null) or (vunitno is null and di.order_by  is not null))     
-----------------------------------------------------------------------------------------------------------------------------
--     and ( exists
--            (select 'x' 
--               from strang.detailrs_item di, strang.receivals r 
--              where r.deliveryno = di.deliveryno
--                and m.movement_no = di.movement_no
--                and nvl(m.seal,'|') = nvl(di.seal,'|')
--                and nvl(r.currdate, trunc(sysdate))  > to_date('1 Jan 2018','DD MON YYYY')))                         
--     order by m.movement_no, m.seal, dr.deliveryno, dr.itemno, di.order_by;  
  

  cursor c3(vscan_key number) is select m.movement_no, m.seal, m.unpack_exceptions_flag, m.unpack_exceptions_approved_by, m.unpack_completed_by 
                                   from strang.movements m where m.scan_key = vscan_key order by m.movement_no;


  c1rec    c1%rowtype;
  c2rec    c2%rowtype;
  c3rec    c3%rowtype;
  vmov 	   varchar2(100);
  vsmp     varchar2(100);
  vseal	   varchar2(100);
  vdel     integer;
  vtot	   integer;
  vitemno  integer;
  vunitno  integer;
  vscan    integer;

 begin

    if x.exists(5)
    then 
       vmov  := x(3);
       vseal := x(4);
       vsmp  := x(5);
      
       
       if x.exists(6) then 
          begin vdel := to_number(x(6)); exception when others then vdel := null; end;
       end if;
     
       if x.exists(7) then 
          begin vitemno := to_number(x(7)); exception when others then vitemno := null; end;
       end if;
       
       if x.exists(8) then 
          begin vunitno := to_number(x(8)); exception when others then vunitno := null; end;
       end if;
       
      
       owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
       htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
       owa_util.http_header_close;
    
       htp.p( '<container>');
       htp.p( '<container_no>' || xtra.xmlconv(vmov) || '</container_no>');
       htp.p( '<seal>' || xtra.xmlconv(vseal) || '</seal>');
   --    htp.p( '<scan_key>' || xtra.xmlconv(vseal) || '</scan_key>');
       htp.p( '<smp>' || xtra.xmlconv(nvl(vsmp,'NOSMP')) || '</smp>');
       htp.p( '<deliveries>');
   
       for c2rec in c2(vmov, vseal, vsmp, vdel, vitemno, vunitno) loop
          if c2rec.deliveryno <> nvl(c2rec.prev_deliveryno, 9999999) then
             htp.p( '<delivery>' );
             htp.p( '<delivery_no>' || xtra.xmlconv(c2rec.deliveryno)|| '</delivery_no>' );  
             htp.p( '<delivery_items>');       
          end if;
          if c2rec.itemno <> nvl(c2rec.prev_itemno, 9999999) then
             htp.p( '<delivery_item>'); 
             htp.p( '<delivery_item_number>' || xtra.xmlconv(c2rec.itemno) || '</delivery_item_number>' );
             htp.p( '<package_units>');   
          end if;
            htp.p( '<package_unit>'); 
            htp.p( '<record_no>' || c2%ROWCOUNT || '</record_no>' );  
            htp.p( '<unit_no>'||c2rec.unit_no||'</unit_no>' );
            htp.p( '<packed_date>'||c2rec.packed_date||'</packed_date>' );
            htp.p( '<unit_packed_date_rnk>'||c2rec.unit_packed_date_rnk||'</unit_packed_date_rnk>' );                   
            htp.p( '<unit_part>'||c2rec.unit_part||'</unit_part>' );
            htp.p( '<unpacked_flag>'||c2rec.unpacked_flag||'</unpacked_flag>');
            htp.p( '<unpacked_date>'||c2rec.unpacked_date||'</unpacked_date>');
            htp.p( '<unpacked_by>'||c2rec.unpacked_by||'</unpacked_by>');
            htp.p( '<unit_unpacked_date_rnk>'||c2rec.unit_unpacked_date_rnk||'</unit_unpacked_date_rnk>' );
            htp.p( '<unpacked_missing_flag>'||c2rec.unpacked_missing_flag||'</unpacked_missing_flag>');
            htp.p( '<unpacked_missing_date>'||c2rec.unpacked_missing_date||'</unpacked_missing_date>');
            htp.p( '<unpacked_missing_by>'||c2rec.unpacked_missing_by||'</unpacked_missing_by>');
            htp.p( '<unpacked_extra_flag>'||c2rec.unpacked_extra_flag||'</unpacked_extra_flag>');
            htp.p( '<unpacked_extra_date>'||c2rec.unpacked_extra_date||'</unpacked_extra_date>');
            htp.p( '<unpacked_extra_by>'||c2rec.unpacked_extra_by||'</unpacked_extra_by>');
            htp.p( '</package_unit>');
            if c2rec.itemno <> nvl(c2rec.next_itemno, 9999999) then
               htp.p( '</package_units>');   
               htp.p( '</delivery_item>'); 
            end if;    
                    
            if c2rec.deliveryno <> nvl(c2rec.next_deliveryno, 9999999) then
               htp.p( '</delivery_items>');     
               htp.p( '</delivery>' );
            end if;
            
       end loop;
       htp.p( '</deliveries>');
       htp.p( '</container>' );
       return;
    end if;
   
   if x.exists(3) then     
       begin vscan := to_number(x(3)); exception when others then vscan:= null; end;        
       if vscan is not null then
          open c3(vscan);
          fetch c3 into c3rec;
          if c3%notfound then
             close c3;
             err( '[1022] Err in process_unpack_container:' || ' Scan key: ['||vscan||'] not found', 404, TRUE);
             return;
          else
             vmov := c3rec.movement_no;
             vseal := c3rec.seal;
          end if;
       end if;
       owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
       htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
       owa_util.http_header_close;   
          
       htp.p( '<container>');
       htp.p( '<container_no>' || xtra.xmlconv(vmov) || '</container_no>');
       htp.p( '<seal>' || xtra.xmlconv(vseal) || '</seal>');
       htp.p( '<unpack_exceptions_flag>' || xtra.xmlconv(c3rec.unpack_exceptions_flag) || '</unpack_exceptions_flag>');
       htp.p( '<unpack_exceptions_approved_by>' || xtra.xmlconv(c3rec.unpack_exceptions_approved_by) || '</unpack_exceptions_approved_by>');
       htp.p( '<unpack_completed_by>' || xtra.xmlconv(c3rec.unpack_completed_by) || '</unpack_completed_by>');
       htp.p( '<package_groups>');
   
       for c1rec in c1(vmov, vseal) loop
          if NVL(c1rec.smp_no, 'XXXX') <> nvl(c1rec.prev_smp_no, 'XXXX') then
             htp.p( '<package_group>');    
             htp.p( '<smp_no>' || xtra.xmlconv(c1rec.smp_no) || '</smp_no>');
             htp.p( '<unit_total>' || xtra.xmlconv(c1rec.total) || '</unit_total>'); 
          end if;
          ------------------------------------------------------------------------------------------------------------------
          if (NVL(c1rec.unpacked_flag, 'XXXX') <> nvl(c1rec.prev_unpacked_flag, 9999999)) and c1rec.unpacked_flag = 'Y'  then
              htp.p( '<unpacked_group>');  
              htp.p( '<unpacked_flag>' || xtra.xmlconv(c1rec.unpacked_flag) || '</unpacked_flag>');
              htp.p( '<unit_count>' || xtra.xmlconv(c1rec.cnt) || '</unit_count>');   
              htp.p( '</unpacked_group>');  
          end if;
--          htp.p( '<unpacked_flag>' || xtra.xmlconv(c1rec.unpacked_flag) || '</unpacked_flag>');
--          htp.p( '<unit_count>' || xtra.xmlconv(c1rec.cnt) || '</unit_count>');
--          if NVL(c1rec.unpacked_flag, 'XXXX') <> nvl(c1rec.next_unpacked_flag, 9999999) then
--               htp.p( '</unpacked_group>');     
--          end if;
          ------------------------------------------------------------------------------------------   
          ------------------------------------------------------------------------------------------
          if (NVL(c1rec.unpacked_missing_flag, 'XXXX') <> nvl(c1rec.prev_unpacked_missing_flag, 9999999)) AND c1rec.unpacked_missing_flag = 'Y' then
              htp.p( '<unpacked_missing_group>');
              htp.p( '<unpacked_missing_flag>' || xtra.xmlconv(c1rec.unpacked_missing_flag) || '</unpacked_missing_flag>');
              htp.p( '<unit_missing_count>' || xtra.xmlconv(c1rec.cnt) || '</unit_missing_count>');   
              htp.p( '</unpacked_missing_group>');   
          end if;
--          htp.p( '<unpacked_missing_flag>' || xtra.xmlconv(c1rec.unpacked_missing_flag) || '</unpacked_missing_flag>');
--          htp.p( '<unit_missing_count>' || xtra.xmlconv(c1rec.cnt) || '</unit_missing_count>');
--          if NVL(c1rec.unpacked_missing_flag, 'XXXX') <> nvl(c1rec.next_unpacked_missing_flag, 9999999) then
--               htp.p( '</unpacked_missing_group>');     
--          end if;
          ------------------------------------------------------------------------------------------   
          if (NVL(c1rec.unpacked_extra_flag, 'XXXX') <> nvl(c1rec.prev_unpacked_extra_flag, 9999999)) and c1rec.unpacked_extra_flag = 'Y' then
              htp.p( '<unpacked_extra_group>');     
              htp.p( '<unpacked_extra_flag>' || xtra.xmlconv(c1rec.unpacked_extra_flag) || '</unpacked_extra_flag>');
              htp.p( '<unit_extra_count>' || xtra.xmlconv(c1rec.cnt) || '</unit_extra_count>');
              htp.p( '</unpacked_extra_group>');   
          end if;
--          htp.p( '<unpacked_extra_flag>' || xtra.xmlconv(c1rec.unpacked_extra_flag) || '</unpacked_extra_flag>');
--          htp.p( '<unit_extra_count>' || xtra.xmlconv(c1rec.cnt) || '</unit_extra_count>');
--          if NVL(c1rec.unpacked_extra_flag, 'XXXX') <> nvl(c1rec.next_unpacked_extra_flag, 9999999) then
--               htp.p( '</unpacked_extra_group>');     
--          end if;
       ------------------------------------------------------------------------------------------
          if c1rec.unpacked_extra_flag is null and c1rec.unpacked_missing_flag is null and c1rec.unpacked_flag is null then
              htp.p( '<unpacked_unflaged_group>');     
           --   htp.p( '<unpacked_unflaged_flag>' || xtra.xmlconv('') || '</unpacked_unflaged_flag>');
              htp.p( '<unit_unflaged_count>' || xtra.xmlconv(c1rec.cnt) || '</unit_unflaged_count>');
              htp.p( '</unpacked_unflaged_group>');   
          end if;

          if nvl(c1rec.smp_no,'XXXX') <> nvl(c1rec.next_smp_no, 'XXXX') then
             htp.p( '</package_group>');   
          end if;   
       end loop;
       htp.p('</package_groups>');
       htp.p('</container>');
         
     end if; 

 exception
  when others then
   err( '[1089] Err in process_unpack_container:' || sqlerrm, 404, TRUE);
 end process_unpack_container; 
 
 
 procedure transaction_interface11a(pk1 in varchar2, pk2 in varchar2, val1 in varchar2, val2 in number, val3 in number, val4 in number default null, val5 in varchar2 default null,  ctr in integer, sz in integer, msg in out varchar2)
 as
 
 e_Delivery_item_unavailable EXCEPTION;
 cursor c1 (pk1 varchar2, pk2 varchar2, val1 varchar2, val2 number, val3 number, val4 number) is
              select * 
                from strang.detailrs_item di 
               where di.movement_no  = pk1
                 and nvl(di.seal,'xxxx')  = nvl(pk2,'xxxx')
                 and nvl(di.smp_no,'NOSMP') = nvl(val1,'NOSMP')
                 and di.deliveryno = val2
                 and di.item_no = val3
                 and di.order_by = val4;
                 
 
  cursor c2 (pk1 varchar2, pk2 varchar2) is
             select count(*) cnt from
             ( select di.* 
                from strang.detailrs_item di 
               where di.movement_no  = pk1
                 and nvl(di.seal,'xxxx')  = nvl(pk2,'xxxx')
                 and (di.UNPACKED_EXTRA_FLAG is not null or di.UNPACKED_MISSING_FLAG is not null)
              union all
              select di2.* 
                from strang.detailrs_item di2,  
                     strang.unpack_extras ue
               where di2.deliveryno = ue.deliveryno
                 and di2.item_no = ue.item_no
                 and di2.order_by = ue.order_by
                 and pk1 = ue.actual_container
                 and nvl(pk2,'xxxx') = nvl(ue.actual_seal,'xxxx')
                 and (di2.UNPACKED_EXTRA_FLAG is not null or di2.UNPACKED_MISSING_FLAG is not null)) tmp;

  
  c1rec c1%rowtype;
  c2rec c2%rowtype;
           		                                 			                                   

 begin
 
/*
When the movement_no, Seal, deliveryno and item details are returned in interface5, the system updates the Detailrs table with movement_no and seal number for the corresponding deliveryno and itemno.
*/

 open c1(pk1, pk2, val1, val2, val3, val4);
 fetch c1 into c1rec;
   
  if c1%found then   
  
     DELETE FROM strang.unpack_extras 
          WHERE deliveryno =  val2
            AND item_no = val3
            AND order_by = val4;
  
  
     update strang.detailrs_item di
       set unpacked_flag = 'Y'
          ,unpacked_date = sysdate
          ,unpacked_by = val5
          ,modified_by = val5
          ,modified_date = sysdate
          ,unpacked_missing_flag = null
          ,unpacked_missing_date = null
          ,unpacked_missing_by = null
          ,unpacked_extra_flag = null
          ,unpacked_extra_date = null
          ,unpacked_extra_by = null
     where di.movement_no = pk1
       and di.seal = pk2
       and nvl(di.smp_no,'NOSMP') = NVL(val1,'NOSMP')
       and di.deliveryno = val2 
       and di.item_no = val3
       and di.order_by = val4;


     if sql%rowcount <> 0
     then
        external_audit( '11', 'transaction_interface11a (Delivery Unit unpacked from Container): Processed Successfully', pk1, pk2, val1||'-'||val2, val3||'-'||val4, val5, ctr, sz);
     else 
        external_audit( '11', 'transaction_interface11a (Delivery Unit unpacked from Container): Failed to find delivery unit', pk1, pk2, val1||'-'||val2, val3||'-'||val4, val5, ctr, sz);
        msg := 'Error: Delivery no: '||val2||' Item: '||val3|| ' Unit: '||val4|| ' not found.';
        raise e_Delivery_item_unavailable;
        return; -- David start here
     end if;  
  else
      external_audit( '11', 'transaction_interface11a (Delivery Unit unpacked from Container): Failed to find delivery unit', pk1, pk2, val1||'-'||val2, val3||'-'||val4, val5, ctr, sz);
      close c1;
      msg := 'Error: Delivery no: '||val2||' Item: '||val3|| ' Unit: '||val4|| ' not found.';
      raise e_Delivery_item_unavailable;
      return; -- David start here 
  end if;
  close c1;
  
  -- Added by David Banjo 3/12/2021
  
   commit;
  
  open c2(pk1, pk2);
  fetch c2 into c2rec;
  close c2;
  if c2rec.cnt = 0 then
    
     update strang.movements m
        set UNPACK_EXCEPTIONS_FLAG = null
      where m.movement_no = pk1
        and nvl(m.seal,'|') = nvl(pk2,'|')
        and UNPACK_EXCEPTIONS_FLAG IS NOT NULL;
  else
     update strang.movements m
        set UNPACK_EXCEPTIONS_FLAG = 'Y'
      where nvl(UNPACK_EXCEPTIONS_FLAG,'X') <> 'Y'
        and m.movement_no = pk1
        and nvl(m.seal,'|') = nvl(pk2,'|');
  
  end if;
  
  commit;

 exception
  when e_Delivery_item_unavailable then err( '[1035] Error: Delivery no: '||val2||' Item: '||val3|| ' Unit: '||val4||' not found.', 404, TRUE);
  when others then
   external_audit( '11', 'Transaction interface11a (Delivery Unit unpacked from Container) Failed :' || pk1, pk2,  val1||'-'||val2, val3||'-'||val4, val5, ctr, sz, sqlerrm );
 end transaction_interface11a;
 procedure transaction_interface11b(pk1 in varchar2, pk2 in varchar2, val1 in varchar2, val2 in number, val3 in number, val4 in number default null, val5 in varchar2 default null, ctr in integer, sz in integer, msg in out varchar2)
 as
 
   e_Delivery_item_unavailable EXCEPTION;
   cursor c1 (pk1 varchar2, pk2 varchar2, val1 varchar2, val2 number, val3 number, val4 number) is
              select di.* 
                from strang.detailrs_item di 
               where di.movement_no  = pk1
                 and nvl(di.seal,'xxxx')  = nvl(pk2,'xxxx')
                 and nvl(di.smp_no,'NOSMP') = nvl(val1,'NOSMP')
                 and di.deliveryno = val2
                 and di.item_no = val3
                 and di.order_by = val4
              union all
              select di2.* 
                from strang.detailrs_item di2,  
                     strang.unpack_extras ue
               where di2.deliveryno = val2
                 and di2.item_no = val3
                 and di2.order_by = val4
                 and di2.deliveryno = ue.deliveryno
                 and di2.item_no = ue.item_no
                 and di2.order_by = ue.order_by
                 and pk1 = ue.actual_container
                 and nvl(pk2,'xxxx') = nvl(ue.actual_seal,'xxxx');

   cursor c2 (pk1 varchar2, pk2 varchar2) is
             select count(*) cnt from
             ( select di.* 
                from strang.detailrs_item di 
               where di.movement_no  = pk1
                 and nvl(di.seal,'xxxx')  = nvl(pk2,'xxxx')
                 and (di.UNPACKED_EXTRA_FLAG is not null or di.UNPACKED_MISSING_FLAG is not null)
              union all
              select di2.* 
                from strang.detailrs_item di2,  
                     strang.unpack_extras ue
               where di2.deliveryno = ue.deliveryno
                 and di2.item_no = ue.item_no
                 and di2.order_by = ue.order_by
                 and pk1 = ue.actual_container
                 and nvl(pk2,'xxxx') = nvl(ue.actual_seal,'xxxx')
                 and (di2.UNPACKED_EXTRA_FLAG is not null or di2.UNPACKED_MISSING_FLAG is not null)) tmp;

  
  c1rec c1%rowtype;
  c2rec c2%rowtype;
 
 
 begin
/*
When the movement_no, Seal, deliveryno and item details are returned in interface5, the system updates the Detailrs table with movement_no and seal number for the corresponding deliveryno and itemno.
*/
  
  open c1(pk1, pk2, val1, val2, val3, val4);
  fetch c1 into c1rec;
   
  if c1%found then   
  
     DELETE FROM strang.unpack_extras 
          WHERE deliveryno =  val2
            AND item_no = val3
            AND order_by = val4;
            
     update strang.movements m
        set unpack_exceptions_approved_by = null
          , unpack_exceptions_approved_dt = null
          , unpack_completed_by = null
          , unpack_completed_date = null
      where m.movement_no = pk1
       and  nvl(m.seal,'|') = nvl(pk2,'|');
  
     update strang.detailrs_item di
       set unpacked_flag = null
     --    , unpacked_date = null
         , unpacked_by = null
         , modified_by = val5
         , modified_date = sysdate
         , unpacked_missing_flag = null
         , unpacked_missing_date = null
         , unpacked_missing_by = null
         , unpacked_extra_flag = null
         , unpacked_extra_date = null
         , unpacked_extra_by = null
--     where di.movement_no = pk1
--       and di.seal = pk2
--       and nvl(di.smp_no,'NOSMP') = nvl(val1,'NOSMP')
     where di.deliveryno = val2 
       and di.item_no = val3
       and di.order_by = val4;


     if sql%rowcount <> 0
     then
        external_audit( '11', 'transaction_interface11b (Unpacked Delivery Unit reversal): Processed Successfully', pk1, pk2, val1||'-'||val2, val3||'-'||val4, val5, ctr, sz);
     else 
        external_audit( '11', 'transaction_interface11b (Unpacked Delivery Unit reversal): Failed to find delivery unit', pk1, pk2, val1||'-'||val2, val3||'-'||val4, val5, ctr, sz);
        msg := 'Error: Delivery no: '||val2||' Item: '||val3|| ' Unit: '||val4|| ' not found.';
        raise e_Delivery_item_unavailable;
        return; -- David start here
     end if;  
  else
      external_audit( '11', 'transaction_interface11b (Unpacked Delivery Unit reversal): Failed to find delivery unit', pk1, pk2, val1||'-'||val2, val3||'-'||val4, val5, ctr, sz);
      close c1;
      msg := 'Error: Delivery no: '||val2||' Item: '||val3|| ' Unit: '||val4|| ' not found.';
      raise e_Delivery_item_unavailable;
      return; -- David start here 
  end if;
  close c1;
  
  -- Added by David Banjo 3/12/2021
  commit;
  
  open c2(pk1, pk2);
  fetch c2 into c2rec;
  close c2;
  if c2rec.cnt = 0 then
    
     update strang.movements m
        set UNPACK_EXCEPTIONS_FLAG = null
      where m.movement_no = pk1
        and nvl(m.seal,'|') = nvl(pk2,'|')
        and UNPACK_EXCEPTIONS_FLAG IS NOT NULL;
  else
     update strang.movements m
        set UNPACK_EXCEPTIONS_FLAG = 'Y'
      where nvl(UNPACK_EXCEPTIONS_FLAG,'X') <> 'Y'
        and m.movement_no = pk1
        and nvl(m.seal,'|') = nvl(pk2,'|');
  
  end if;
  commit;
  
  /*
    <CONTAINER_NO>OTMU2507062</CONTAINER_NO> movements.movement_no pk1
    <CONTAINER_SEAL>OTMU2507062</CONTAINER_SEAL> movements.seal pk2
    <DELIVERYNO>00030</DELIVERYNO> detailrs.deliveryno val1
    <ITEMNO>1</ITEMNO> detailrs.itemno val2
  */
  
 exception
  when e_Delivery_item_unavailable then err( '[1036] Error: Delivery no: '||val2||' Item: '||val3|| ' Unit: '||val4||' not found.', 404, TRUE);
  when others then
   external_audit( '11', 'transaction_interface11b (Unpacked Delivery Unit reversal) Failed:' || pk1, pk2, val1, val2||'-'||val3, val4||'-'||val5, ctr, sz, sqlerrm );
 end transaction_interface11b;
 
 procedure transaction_interface11c(pk1 in varchar2, pk2 in varchar2, val1 in varchar2, val2 in number, val3 in number, val4 in number default null, val5 in varchar2 default null, ctr in integer, sz in integer, msg in out varchar2)
 as
 
   e_Delivery_item_unavailable EXCEPTION;
   cursor c1 (pk1 varchar2, pk2 varchar2, val1 varchar2, val2 number, val3 number, val4 number) is
              select * 
                from strang.detailrs_item di 
               where di.movement_no  = pk1
                 and nvl(di.seal,'xxxx')  = nvl(pk2,'xxxx')
                 and nvl(di.smp_no,'NOSMP') = nvl(val1,'NOSMP')
                 and di.deliveryno = val2
                 and di.item_no = val3
                 and di.order_by = val4;
                 
   cursor c2 (pk1 varchar2, pk2 varchar2) is
             select count(*) cnt from
             ( select di.* 
                from strang.detailrs_item di 
               where di.movement_no  = pk1
                 and nvl(di.seal,'xxxx')  = nvl(pk2,'xxxx')
                 and (di.UNPACKED_EXTRA_FLAG is not null or di.UNPACKED_MISSING_FLAG is not null)
              union all
              select di2.* 
                from strang.detailrs_item di2,  
                     strang.unpack_extras ue
               where di2.deliveryno = ue.deliveryno
                 and di2.item_no = ue.item_no
                 and di2.order_by = ue.order_by
                 and pk1 = ue.actual_container
                 and nvl(pk2,'xxxx') = nvl(ue.actual_seal,'xxxx')
                 and (di2.UNPACKED_EXTRA_FLAG is not null or di2.UNPACKED_MISSING_FLAG is not null)) tmp;

  
  c1rec c1%rowtype;
  c2rec c2%rowtype;
  
 
 begin
/*
When the movement_no, Seal, deliveryno and item details are returned in interface5, the system updates the Detailrs table with movement_no and seal number for the corresponding deliveryno and itemno.
*/
  
  open c1(pk1, pk2, val1, val2, val3, val4);
  fetch c1 into c1rec;
   
  if c1%found then   
   
     DELETE FROM strang.unpack_extras 
          WHERE deliveryno =  val2
            AND item_no = val3
            AND order_by = val4;
 

     update strang.movements m
        set unpack_exceptions_approved_by = null
          , unpack_exceptions_approved_dt = null
          , unpack_completed_by = null
          , unpack_completed_date = null
      where m.movement_no = pk1
       and  nvl(m.seal,'|') = nvl(pk2,'|');
  
     update strang.detailrs_item di
       set unpacked_missing_flag = 'Y'
         , unpacked_missing_date = sysdate
         , unpacked_missing_by = val5
         , modified_by = val5
         , modified_date = sysdate
         , unpacked_extra_flag = null
         , unpacked_extra_date = null
         , unpacked_extra_by = null
         , unpacked_flag = null
      --   , unpacked_date = null
      --   , unpacked_by = null
     where di.movement_no = pk1
       and di.seal = pk2
       and nvl(di.smp_no,'NOSMP') = nvl(val1,'NOSMP')
       and di.deliveryno = val2 
       and di.item_no = val3
       and di.order_by = val4;


     if sql%rowcount <> 0
     then
        external_audit( '11', 'transaction_interface11c (Unpacked Delivery Unit missing): Processed Successfully', pk1, pk2, val1||'-'||val2, val3||'-'||val4, val5, ctr, sz);
     else 
        external_audit( '11', 'transaction_interface11c (Unpacked Delivery Unit missing): Failed to find delivery unit', pk1, pk2, val1||'-'||val2, val3||'-'||val4, val5, ctr, sz);
        msg := 'Error: Delivery no: '||val2||' Item: '||val3|| ' Unit: '||val4|| ' not found.';
        raise e_Delivery_item_unavailable;
        return; -- David start here
     end if;  
  else
      external_audit( '11', 'transaction_interface11c (Unpacked Delivery Unit missing): Failed to find delivery unit', pk1, pk2, val1||'-'||val2, val3||'-'||val4, val5, ctr, sz);
      close c1;
      msg := 'Error: Delivery no: '||val2||' Item: '||val3|| ' Unit: '||val4|| ' not found.';
      raise e_Delivery_item_unavailable;
      return; -- David start here 
  end if;
  close c1;
  
  commit;
  
  open c2(pk1, pk2);
  fetch c2 into c2rec;
  close c2;
  if c2rec.cnt = 0 then
    
     update strang.movements m
        set UNPACK_EXCEPTIONS_FLAG = null
      where m.movement_no = pk1
        and nvl(m.seal,'|') = nvl(pk2,'|')
        and UNPACK_EXCEPTIONS_FLAG IS NOT NULL;
  else
     update strang.movements m
        set UNPACK_EXCEPTIONS_FLAG = 'Y'
      where nvl(UNPACK_EXCEPTIONS_FLAG,'X') <> 'Y'
        and m.movement_no = pk1
        and nvl(m.seal,'|') = nvl(pk2,'|');
  
  end if;
  
  commit;
  
  

 exception
  when e_Delivery_item_unavailable then err( '[1037] Error: Delivery no: '||val2||' Item: '||val3|| ' Unit: '||val4||' not found.', 404, TRUE);
  when others then
   external_audit( '11', 'transaction_interface11c (Unpacked Delivery Unit missing) Failed:' || pk1, pk2, val1, val2||'-'||val3, val4||'-'||val5, ctr, sz, sqlerrm );
 end transaction_interface11c;
 
 procedure transaction_interface11d(pk1 in varchar2, pk2 in varchar2, val1 in varchar2, val2 in number, val3 in number, val4 in number default null, val5 in varchar2 default null, ctr in integer, sz in integer, msg in out varchar2)
 as
 
   e_Delivery_item_unavailable EXCEPTION;
   e_Delivery_item_wrong_SMP EXCEPTION;
   cursor c1 (pk1 varchar2, pk2 varchar2, val1 varchar2, val2 number, val3 number, val4 number) is
              select * 
                from strang.detailrs_item di 
               where di.deliveryno = val2
                 and di.item_no = val3
                 and di.order_by = val4
                 and not exists (select 1
                                  from strang.detailrs_item di2
                                 where di2.deliveryno = di.deliveryno
                                   and di2.ITEM_NO  = di.item_no
                                   and di2.order_by = di.order_by
                                   and di2.movement_no  = pk1
                                   and nvl(di2.seal,'xxxx')  = nvl(pk2,'xxxx')
                                   and nvl(di2.smp_no,'NOSMP') = nvl(val1,'NOSMP'));
                                   
  cursor c2 (pk1 varchar2, pk2 varchar2) is
             select count(*) cnt from
             ( select di.* 
                from strang.detailrs_item di 
               where di.movement_no  = pk1
                 and nvl(di.seal,'xxxx')  = nvl(pk2,'xxxx')
                 and (di.UNPACKED_EXTRA_FLAG is not null or di.UNPACKED_MISSING_FLAG is not null)
              union all
              select di2.* 
                from strang.detailrs_item di2,  
                     strang.unpack_extras ue
               where di2.deliveryno = ue.deliveryno
                 and di2.item_no = ue.item_no
                 and di2.order_by = ue.order_by
                 and pk1 = ue.actual_container
                 and nvl(pk2,'xxxx') = nvl(ue.actual_seal,'xxxx')
                 and (di2.UNPACKED_EXTRA_FLAG is not null or di2.UNPACKED_MISSING_FLAG is not null)) tmp;
                 
     cursor c3 (pk1 varchar2, pk2 varchar2, val2 number, val3 number, val4 number) is
              select * 
                from strang.detailrs_item di 
               where di.deliveryno = val2
                 and di.item_no = val3
                 and di.order_by = val4
                 and exists (select 1
                                  from strang.detailrs_item di2
                                 where di2.deliveryno = di.deliveryno
                                   and di2.ITEM_NO  = di.item_no
                                   and di2.order_by = di.order_by
                                   and di2.movement_no  = pk1
                                   and nvl(di2.seal,'xxxx')  = nvl(pk2,'xxxx'));

  
  c1rec c1%rowtype;
  c2rec c2%rowtype; 
  c3rec c3%rowtype;   
  v_smp varchar2(50);                             
                                   
 
 begin
/*
When the movement_no, Seal, deliveryno and item details are returned in interface5, the system updates the Detailrs table with movement_no and seal number for the corresponding deliveryno and itemno.
*/
  
  open c1(pk1, pk2, val1, val2, val3, val4);
  fetch c1 into c1rec;
   
  if c1%found then   
     
    open c3(pk1, pk2, val2, val3, val4);
    fetch c3 into c3rec;
    if c3%found then  
       close c3;
       close c1;
       external_audit( '11', 'transaction_interface11d (Unpacked Delivery Unit extra): Wrong SMP :'||nvl(c3rec.smp_no, 'NOSMP'), pk1, pk2, val1||'-'||val2, val3||'-'||val4, val5, ctr, sz);
        if c3rec.smp_no is null then
           msg := 'Error: Please scan Delivery no: '||val2||' Item: '||val3|| ' Unit: '||val4|| ' outside the SMPs';
           v_smp := null;
        else
           msg := 'Error: Please scan in Delivery no: '||val2||' Item: '||val3|| ' Unit: '||val4|| ' under '||c3rec.smp_no;
           v_smp := c3rec.smp_no ;
        end if;
        raise e_Delivery_item_unavailable;
        return; -- David start here
    
    
    end if;
    close c3;
    
  
    update strang.movements m
        set unpack_exceptions_approved_by = null
          , unpack_exceptions_approved_dt = null
          , unpack_completed_by = null
          , unpack_completed_date = null
      where m.movement_no = pk1
       and  nvl(m.seal,'|') = nvl(pk2,'|');
  
    DELETE FROM strang.unpack_extras 
          WHERE deliveryno =  val2
            AND item_no = val3
            AND order_by = val4;
            
    INSERT INTO strang.unpack_extras VALUES 
      (val2, val3, val4, c1rec.movement_no, c1rec.seal, c1rec.smp_no, sysdate, val5, pk1, pk2, val1);
           
  
     update strang.detailrs_item di
       set unpacked_extra_flag = 'Y'
         , unpacked_extra_date = sysdate
         , unpacked_extra_by = val5
         , modified_by = val5
         , modified_date = sysdate
         , unpacked_missing_flag = null
         , unpacked_missing_date = null
         , unpacked_missing_by = null
         , unpacked_flag = null
         , unpacked_date = null
         , unpacked_by = null
     where di.deliveryno = val2 
       and di.item_no = val3
       and di.order_by = val4;


     if sql%rowcount <> 0
     then
        external_audit( '11', 'transaction_interface11d (Unpacked Delivery Unit extra): Processed Successfully', pk1, pk2, val1||'-'||val2, val3||'-'||val4, val5, ctr, sz);
     else 
        external_audit( '11', 'transaction_interface11d (Unpacked Delivery Unit extra): Failed to find delivery unit', pk1, pk2, val1||'-'||val2, val3||'-'||val4, val5, ctr, sz);
        close c1;
        msg := 'Error: Delivery no: '||val2||' Item: '||val3|| ' Unit: '||val4|| ' not found.';
        raise e_Delivery_item_unavailable;
        return; -- David start here
     end if;  
  else
      external_audit( '11', 'transaction_interface11d (Unpacked Delivery Unit extra): Failed to find delivery unit', pk1, pk2, val1||'-'||val2, val3||'-'||val4, val5, ctr, sz);
      close c1;
      msg := 'Error: Delivery no: '||val2||' Item: '||val3|| ' Unit: '||val4|| ' not found.';
      raise e_Delivery_item_unavailable;
      return; -- David start here 
  end if;
  close c1;
  
  commit;
  
  open c2(pk1, pk2);
  fetch c2 into c2rec;
  close c2;
  if c2rec.cnt = 0 then
    
     update strang.movements m
        set UNPACK_EXCEPTIONS_FLAG = null
      where m.movement_no = pk1
        and nvl(m.seal,'|') = nvl(pk2,'|')
        and UNPACK_EXCEPTIONS_FLAG IS NOT NULL;
  else
     update strang.movements m
        set UNPACK_EXCEPTIONS_FLAG = 'Y'
      where nvl(UNPACK_EXCEPTIONS_FLAG,'X') <> 'Y'
        and m.movement_no = pk1
        and nvl(m.seal,'|') = nvl(pk2,'|');
  
  end if;
  
  commit;
  
  
  
  
  

 exception
  when e_Delivery_item_unavailable then err( '[1038] Error: Delivery no: '||val2||' Item: '||val3|| ' Unit: '||val4||' not found.', 404, TRUE);
  when e_Delivery_item_wrong_SMP then err( '[1039] Error: Scan Delivery no: '||val2||' Item: '||val3|| ' Unit: '||val4|| case when v_smp is null then ' outside SMPs' else ' in '||v_smp end, 404, TRUE);
  when others then
   external_audit( '11', 'transaction_interface11d (Unpacked Delivery Unit extra) Failed:' || pk1, pk2, val1, val2||'-'||val3, val4||'-'||val5, ctr, sz, sqlerrm );
 end transaction_interface11d;
 
 procedure process_interface11( x in owa.vc_arr, y in owa.vc_arr, fname in varchar )
 as

  cursor c1(fnm varchar2) is select * from apache_ows_content where name = fnm;
  cursor c2(jname varchar2) is select * from user_scheduler_jobs where job_name like jname;
  
  c1rec 	c1%ROWTYPE; 
  c2rec		c2%ROWTYPE;
  clb           clob;
  p 		DBMS_XMLPARSER.parser;
  dest_offset   integer;
  src_offset    integer;
  lang_context  integer;
  warning       varchar2(1000);
  doc 		dbms_xmldom.DOMDocument;
  n 		dbms_xmldom.DOMNode;
  nl 		dbms_xmldom.DOMNodeList;
  e 		dbms_xmldom.DOMElement;
  n_child 	dbms_xmldom.DOMNode;
  tag		varchar2(1000);
  len1 		number;
  ctr		integer;
  vaction   varchar2(100);
  jname		varchar2(100);
  verr		varchar2(4000);
  pk1		varchar2(100);
  pk2		varchar2(100);
  val1		varchar2(100);
  val2		number;
  val3		number;
  val4		number;
  val5		varchar2(100);
  sz		integer;
  msg       varchar2(200);

 begin
 
   open c1( fname );
   fetch c1 into c1rec;
   close c1;
   if c1rec.mime_type <> 'text/xml'
    then
     cleanup(fname,TRUE);
     err( '[1046] File is not XML (mimetype not text/xml)', 404, TRUE);
     return;
   end if;

   dbms_lob.createtemporary( clb, FALSE );
   p := DBMS_XMLPARSER.newParser;
   DBMS_XMLPARSER.setValidationMode(p, FALSE);

   dest_offset := 1;
   src_offset := 1;
   lang_context := 0;
   dbms_lob.converttoclob( clb, c1rec.blob_content, dbms_lob.getlength( c1rec.blob_content ), dest_offset, src_offset, 0, lang_context, warning );
 
   sz := dbms_lob.getlength(clb);

   DBMS_XMLPARSER.parseClob(p, clb );
   doc := DBMS_XMLPARSER.getDocument(p);

   htp.init;
   owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
   htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
   owa_util.http_header_close;

    nl := dbms_xmldom.getElementsByTagName(doc, '*');
    len1 := dbms_xmldom.getLength(nl);
    ctr := 0;

    for j in 0..len1-1 loop
     n := dbms_xmldom.item(nl, j);
     e := dbms_xmldom.makeElement(n);
     n_child:= dbms_xmldom.getFirstChild(n);
     tag := upper(trim(dbms_xmldom.getTagName(e)));
     
     if tag in ('FLAG_UNPACKED', 'UNFLAG_UNPACKED','UNPACKED_MISSING','UNPACKED_EXTRA' )
      then
       ctr := ctr + 1;
       dbms_output.put_line('ctr = '||ctr);
       vaction := tag;
      else
       case tag
        when 'CONTAINER_NO' then pk1  := dbms_xmldom.getNodeValue(n_child);
        when 'CONTAINER_SEAL' then pk2  := dbms_xmldom.getNodeValue(n_child);
        when 'SMP_NO' then val1  := dbms_xmldom.getNodeValue(n_child);
        when 'UPDATED_BY' then val5  := dbms_xmldom.getNodeValue(n_child);
        when 'DELIVERY_NO'  then  val2:= null; val2 := xtra.guess_number(dbms_xmldom.getNodeValue(n_child));
     -- Modified by David Banjo 15/3/2021
        when 'ITEM_NO' then val3 := null; val3 :=  xtra.guess_number(dbms_xmldom.getNodeValue(n_child));
        -- val2 := xtra.guess_number(dbms_xmldom.getNodeValue(n_child));
        when 'UNIT_NO' then val4 := null; val4 := xtra.guess_number(dbms_xmldom.getNodeValue(n_child));

          if vaction = 'FLAG_UNPACKED' then
             transaction_interface11a (pk1, pk2, val1, val2, val3, val4, val5, ctr, sz, msg);
             if msg is not null then
                err( '[1035] '||msg, 404, TRUE);
                return;
             end if;
          elsif vaction = 'UNFLAG_UNPACKED' then
             transaction_interface11b (pk1, pk2, val1, val2, val3, val4, val5, ctr, sz, msg);
             if msg is not null then
                err( '[1036] '||msg, 404, TRUE);
                return;
             end if;
          elsif vaction = 'UNPACKED_MISSING' then
             transaction_interface11c (pk1, pk2, val1, val2, val3, val4, val5, ctr, sz, msg);
             if msg is not null then
                err( '[1037] '||msg, 404, TRUE);
                return;
             end if;
          elsif vaction = 'UNPACKED_EXTRA' then
             transaction_interface11d (pk1, pk2, val1, val2, val3, val4, val5, ctr, sz, msg);
             if msg is not null then
                err( '[1038] '||msg, 404, TRUE);
                return;
             end if;
             
          end if;
          
          val4 := null;
        else null;
       end case;

     end if;
    end loop;
   

   commit;

   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
   
   if msg is null then
      htp.p( '<result>XML File pushed</result>');
   else
      htp.p( '<result>'||msg||'</result>');
   end if;
   
   
   --htp.p( '<result>XML File pushed</result>');

 exception
  when others then
   verr := sqlerrm;
   err( '[1100] Err in process_interface11:'||' pk1 '|| pk1||' pk2 '|| pk2||' val1 '|| val1||' val2 '|| val2||' val3 '|| val3||' '||' val4 '|| val4||' '|| verr, 404, TRUE);
   external_audit( '11', 'process_interface11 (Process Unpack Delivery Unit from Container) Failed:' || c1rec.name, ctr, sz, sqlerrm );
   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
 end process_interface11;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
 procedure transaction_interface12a(pk1 in varchar2, pk2 in varchar2, val1 in varchar2, val2 varchar2, ctr in integer, sz in integer, msg in out varchar2)
 as
 
 e_smp_unavailable EXCEPTION;
 cursor c1 (pk1 varchar2, pk2 varchar2, val1 varchar2) is
              select * 
                from strang.smp sm
               where sm.movement_no  = pk1
                 and nvl(sm.seal,'xxxx')  = nvl(pk2,'xxxx')
                 and nvl(sm.smp_no,'NOSMP') = nvl(val1,'NOSMP');
           		                                 			                                    
 c1rec c1%rowtype;

 begin
 
 open c1(pk1, pk2, val1);
 fetch c1 into c1rec;
   
  if c1%found then   
     update strang.smp sm
       set unpacked_flag = 'Y'
          ,unpacked_date = sysdate
          ,unpacked_by = val2
          ,modified_by = val2
          ,modified_date = sysdate
     where sm.movement_no = pk1
       and sm.seal = pk2
       and nvl(sm.smp_no,'NOSMP') = val1;

     if sql%rowcount <> 0
     then
        external_audit( '12', 'transaction_interface12a (SMP unpacked from Container): Processed Successfully', pk1, pk2, val1, val2, ctr, sz);
     else 
        external_audit( '12', 'transaction_interface12a (SMP unpacked from Container): Failed to find SMP', pk1, pk2, val1, val2, ctr, sz);
        msg := 'Error: SMP no: '||val1||' not found.';
        raise e_smp_unavailable;
        return; -- David start here
     end if;  
     
    update strang.detailrs_item di
       set unpacked_flag = 'Y'
          ,unpacked_date = sysdate
          ,unpacked_by = val2
          ,modified_by = val2
          ,modified_date = sysdate
     where di.movement_no = pk1
       and di.seal = pk2
       and nvl(di.smp_no,'NOSMP') = val1;

  else
      external_audit( '12', 'transaction_interface12a (SMP unpacked from Container): Processed Successfully', pk1, pk2, val1, val2, ctr, sz);
      close c1;
      msg := 'Error: SMP no: '||val1||' not found.';
      raise e_smp_unavailable;
      return; -- David start here 
  end if;
  close c1;
  
  -- Added by David Banjo 3/12/2021
  
   commit;
  

 exception
  when e_smp_unavailable then err( '[1049] Error: SMP no: '||val1||' not found.', 404, TRUE);
  when others then
   external_audit( '12', 'Transaction interface12a (SMP unpacked from Container) Failed :' || pk1, pk2,  val1, val2, ctr, sz, sqlerrm );
 end transaction_interface12a;
 procedure transaction_interface12b(pk1 in varchar2, pk2 in varchar2, val1 in varchar2, val2 in varchar2, ctr in integer, sz in integer, msg in out varchar2)
 as
 
   e_smp_unavailable EXCEPTION;
   cursor c1 (pk1 varchar2, pk2 varchar2, val1 varchar2) is
              select * 
                from strang.smp sm
               where sm.movement_no  = pk1
                 and nvl(sm.seal,'xxxx')  = nvl(pk2,'xxxx')
                 and nvl(sm.smp_no,'NOSMP') = nvl(val1,'NOSMP');
 
   c1rec c1%rowtype;
 
 
 begin
/*
When the movement_no, Seal, deliveryno and item details are returned in interface5, the system updates the Detailrs table with movement_no and seal number for the corresponding deliveryno and itemno.
*/
  
  open c1(pk1, pk2, val1);
  fetch c1 into c1rec;
   
  if c1%found then   
  
     update strang.smp sm
       set unpacked_flag = null
         , unpacked_date = null
         , unpacked_by = null
         , modified_by = val2
         , modified_date = sysdate
     where sm.movement_no = pk1
       and sm.seal = pk2
       and nvl(sm.smp_no,'NOSMP') = val1;

     if sql%rowcount <> 0
     then
        external_audit( '12', 'transaction_interface12b (Unpacked SMP reversal): Processed Successfully', pk1, pk2, val1, val2, ctr, sz);
     else 
        external_audit( '12', 'transaction_interface12b (Unpacked SMP reversal): Failed to find SMP', pk1, pk2, val1, val2, ctr, sz);
        msg := 'Error: SMP no: '||val1||' not found.';
        raise e_smp_unavailable;
        return; -- David start here
     end if;  
     
     update strang.detailrs_item di
       set unpacked_flag = NULL
          ,unpacked_date = NULL
          ,unpacked_by = NULL
          ,modified_by = val2
          ,modified_date = sysdate
     where di.movement_no = pk1
       and di.seal = pk2
       and nvl(di.smp_no,'NOSMP') = val1;
     
     
     
  else
     
     update strang.detailrs_item di
       set unpacked_flag = NULL
     --     ,unpacked_date = NULL
     --     ,unpacked_by = NULL
          ,modified_by = val2
          ,modified_date = sysdate
     where di.movement_no = pk1
       and di.seal = pk2
       and nvl(di.smp_no,'NOSMP') = 'NOSMP';
       
     if sql%rowcount <> 0
     then
        external_audit( '12', 'transaction_interface12b (Unpacked NOSMP reversal): Processed Successfully', pk1, pk2, val1, val2, ctr, sz);
     else 
        external_audit( '12', 'transaction_interface12b (Unpacked NOSMP reversal): Failed to find SMP', pk1, pk2, val1, val2, ctr, sz);
        msg := 'Error: No items outside SMP found.';
        raise e_smp_unavailable;
        return; -- David start here
     end if;  
  
--      external_audit( '12', 'transaction_interface12b (Unpacked SMP reversal): Failed to find SMP', pk1, pk2, val1, val2, ctr, sz);
--      close c1;
--      msg := 'Error: SMP no: '||val1||' not found.';
--      raise e_smp_unavailable;
--      return; -- David start here 
  end if;
  
  close c1;
  
  -- Added by David Banjo 3/12/2021
  commit;

 exception
  when e_smp_unavailable then err( '[1049] Error: SMP no: '||val1||' not found.', 404, TRUE);
  when others then
   external_audit( '12', 'transaction_interface12b (Unpacked SMP reversal) Failed:' || pk1, pk2, val1, val2, ctr, sz, sqlerrm );
 end transaction_interface12b;
 
 procedure process_interface12( x in owa.vc_arr, y in owa.vc_arr, fname in varchar )
 as

  cursor c1(fnm varchar2) is select * from apache_ows_content where name = fnm;
  cursor c2(jname varchar2) is select * from user_scheduler_jobs where job_name like jname;
  
  c1rec 	    c1%ROWTYPE; 
  c2rec		    c2%ROWTYPE;
  clb           clob;
  p 		    DBMS_XMLPARSER.parser;
  dest_offset   integer;
  src_offset    integer;
  lang_context  integer;
  warning       varchar2(1000);
  doc 		    dbms_xmldom.DOMDocument;
  n 		    dbms_xmldom.DOMNode;
  nl 		    dbms_xmldom.DOMNodeList;
  e 		    dbms_xmldom.DOMElement;
  n_child 	    dbms_xmldom.DOMNode;
  tag		    varchar2(1000);
  len1 		    number;
  ctr		    integer;
  vaction       varchar2(100);
  jname		    varchar2(100);
  verr		    varchar2(4000);
  pk1		    varchar2(100);
  pk2		    varchar2(100);
  val1		    varchar2(100);
  val2		    varchar2(100);
  sz		    integer;
  msg           varchar2(200);

 begin
 
   open c1( fname );
   fetch c1 into c1rec;
   close c1;
   if c1rec.mime_type <> 'text/xml'
    then
     cleanup(fname,TRUE);
     err( '[1046] File is not XML (mimetype not text/xml)', 404, TRUE);
     return;
   end if;

   dbms_lob.createtemporary( clb, FALSE );
   p := DBMS_XMLPARSER.newParser;
   DBMS_XMLPARSER.setValidationMode(p, FALSE);

   dest_offset := 1;
   src_offset := 1;
   lang_context := 0;
   dbms_lob.converttoclob( clb, c1rec.blob_content, dbms_lob.getlength( c1rec.blob_content ), dest_offset, src_offset, 0, lang_context, warning );
 
   sz := dbms_lob.getlength(clb);

   DBMS_XMLPARSER.parseClob(p, clb );
   doc := DBMS_XMLPARSER.getDocument(p);

   htp.init;
   owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
   htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
   owa_util.http_header_close;

    nl := dbms_xmldom.getElementsByTagName(doc, '*');
    len1 := dbms_xmldom.getLength(nl);
    ctr := 0;

    for j in 0..len1-1 loop
     n := dbms_xmldom.item(nl, j);
     e := dbms_xmldom.makeElement(n);
     n_child:= dbms_xmldom.getFirstChild(n);
     tag := upper(trim(dbms_xmldom.getTagName(e)));
     
     if tag in ('FLAG_UNPACKED_SMP', 'UNFLAG_UNPACKED_SMP')
      then
       ctr := ctr + 1;
       dbms_output.put_line('ctr = '||ctr);
       vaction := tag;
      else
       case tag
        when 'CONTAINER_NO' then pk1  := dbms_xmldom.getNodeValue(n_child);
        when 'CONTAINER_SEAL' then pk2  := dbms_xmldom.getNodeValue(n_child);
        when 'UPDATED_BY' then val2  := dbms_xmldom.getNodeValue(n_child);
        when 'SMP_NO' then val1 := null; val1  := dbms_xmldom.getNodeValue(n_child);

          if vaction = 'FLAG_UNPACKED_SMP' then
             transaction_interface12a (pk1, pk2, val1, val2, ctr, sz, msg);
             if msg is not null then
                err( '[1044] '||msg, 404, TRUE);
                return;
             end if;
          elsif vaction = 'UNFLAG_UNPACKED_SMP' then
             transaction_interface12b (pk1, pk2, val1, val2, ctr, sz, msg);
             if msg is not null then
                err( '[1044] '||msg, 404, TRUE);
                return;
             end if;
             
          end if;
          
        else null;
       end case;

     end if;
    end loop;
   

   commit;

   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
   
   if msg is null then
      htp.p( '<result>XML File pushed</result>');
   else
      htp.p( '<result>'||msg||'</result>');
   end if;
   

 exception
  when others then
   verr := sqlerrm;
   err( '[1100] Err in process_interface12:'||' pk1 '|| pk1||' pk2 '|| pk2||' val1 '|| val1||' val2 '|| val2||' '|| verr, 404, TRUE);
   external_audit( '12', 'process_interface12 (Process Unpack SMP from Container) Failed:' || c1rec.name, ctr, sz, sqlerrm );
   begin dbms_lob.freetemporary(clb); exception when others then null; end;
   cleanup(fname,FALSE);
 end process_interface12;


 procedure main( p_path in varchar2 default null, MODOWA$CONTENT_BODY in varchar2 default null, MODOWA$REST_PATH in varchar2 default null)
 as
  x		owa.vc_arr;
  y		owa.vc_arr;
  varea		varchar2(100);
  vkey		varchar2(100);
  verbose	varchar2(100);
  vtrace	boolean;
 begin

  g_request := owa_util.get_cgi_env('REQUEST_METHOD');

  if MODOWA$REST_PATH like '/trace%'
   then
    owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
    htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
    owa_util.http_header_close;
    htp.p( '<trace>' );
     htp.p( '<cb>' || MODOWA$CONTENT_BODY || '</cb>');
     htp.p( '<pp>' || p_path || '</pp>' );
     htp.p( '<request>' || g_request || '</request>' );
     htp.p( '<path>' || MODOWA$REST_PATH || '</path>' );
     htp.p( '<script>' || owa_util.get_cgi_env('SCRIPT_NAME') || '</script>' );
     htp.p( '<uri>' ||  owa_util.get_cgi_env('REQUEST_URI') || '</uri>' );
  end if;

  err_found := FALSE;
  if not(rst(MODOWA$REST_PATH,x,y)) then cleanup(MODOWA$CONTENT_BODY); return; end if;
  vtrace := nvl(vtrace,FALSE);

  if MODOWA$REST_PATH like '/trace%'
   then
    htp.p( '<parse>' );
     htp.p( '<xtot>' || x.count || '</xtot>' );
     htp.p( '<ytot>' || y.count || '</ytot>' );
     if x.count > 0
      then
       htp.p( '<xy>' );
       for j in x.first..x.last loop
        htp.p( '<r id="' || j || '">' );
         htp.p( '<xval>' || x(j) || '</xval>' );
         htp.p( '<yval>' || x(j) || '</yval>' );
        htp.p( '</r>' );
       end loop;
       htp.p( '</xy>' );
     end if;
    htp.p( '</parse>' );
    htp.p( '</trace>' );
  end if;

  --
  -- GET
  --
  if g_request in ('GET')
   then
    if x.exists(2)
     then

      if x(2) = 'ping'
       then
        process_ping(x,y);
        return;
      end if;
      if x(2) = 'pos'
       then
        process_pos(x,y);
        return;
      end if;
      if x(2) in ('poss','pos_soap','possoap','postrad')
       then
        process_pos_soap(x,y,x(2));
        return;
      end if;
      if x(2) = 'status'
       then
        process_status(x,y);
        return;
      end if;
      if x(2) = 'track_entry'
       then
        process_track_entry(x,y);
        return;
      end if;
      if x(2) = 'cargo'
       then
        process_cargo(x,y);
        return;
      end if;
      if x(2) = 'dlvry_cargo'
       then
        process_dlvry_cargo(x,y);
        return;
      end if;
      if x(2) = 'smp_cargo'
       then
       process_smp_cargo(x,y);
        return;
      end if;
      if x(2) = 'scan_metadata'
       then
       process_scan_metadata(x,y);
        return;
      end if;
      if x(2) = 'user_metadata'
       then
       process_user_metadata(x,y);
        return;
      end if;
      
      if x(2) = 'images'
       then
       process_image(x,y);
        return;
      end if;
      
      if x(2) = 'print_container_docs'
       then
       process_print_image(x,y);
        return;
      end if;
      
     if x(2) = 'print_container_html_docs'
       then
       process_print_image_html(x,y);
        return;
      end if; 
      
     if x(2) = 'unpack'
       then
       process_unpack_container(x,y);
        return;
      end if;
      
      
      
    end if;
  end if;

  --
  -- POST
  --
  if g_request in ('POST','PUT')
   then
    if not process_push(varea,vkey,verbose,vtrace,MODOWA$CONTENT_BODY) then cleanup(MODOWA$CONTENT_BODY); return; end if;

    if x.exists(2)
     then

      if x(2) in ('pospush','interface1')
       then
        process_interface1(x,y,MODOWA$CONTENT_BODY);
        return;
      end if;

      if x(2) in ('grnupd','interface3')
       then
        process_interface3(x,y,MODOWA$CONTENT_BODY);
        return;
      end if;
      
      if x(2) in ('dnupd_cargo','interface5')
       then
        process_interface5(x,y,MODOWA$CONTENT_BODY);
        return;
      end if;
      
      if x(2) in ('dnupd_smp','interface6')
       then
        process_interface6(x,y,MODOWA$CONTENT_BODY);
        return;
      end if;
      
      if x(2) in ('smpupd_cargo','interface7')
       then
        process_interface7(x,y,MODOWA$CONTENT_BODY);
        return;
      end if;

      if x(2) in ('maintain_movement','interface8')
       then
        process_interface8(x,y,MODOWA$CONTENT_BODY);
        return;
      end if;
      
      if x(2) in ('maintain_smp','interface9')
       then
        process_interface9(x,y,MODOWA$CONTENT_BODY);
        return;
      end if;
      
      if x(2) in ('maintain_images','interface10')
       then
        process_interface10(x,y,MODOWA$CONTENT_BODY);
        return;
      end if;
     
     if x(2) in ('dnupd_unpack','interface11')
      then
         process_interface11(x,y,MODOWA$CONTENT_BODY);
         return;
      end if;
      
      if x(2) in ('smpupd_unpack','interface12')
      then
         process_interface12(x,y,MODOWA$CONTENT_BODY);
         return;
      end if; 
      
      
      

    end if;
    htp.init;
    owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
    htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
    return;
  end if;

  --
  -- DELETE
  --
  if g_request in ('DEL','DELETE')
   then
    null;
    owa_util.mime_header('text/xml',CCHARSET=>'UTF-8', bclose_header=>FALSE);
    htp.prn('Status: ' || '200' || ' ' || 'OK' || xtra.NL_CHAR);
    return;
  end if;

 end main;

 function interface2(vpk1 in varchar2, vpk2 in varchar2, ud1 in varchar2 default null, ud2 in varchar2 default null, ud3 in varchar2 default null, ud4 in varchar2 default null, ud5 in varchar2 default null, vtest in char default 'F', vtestinfo in varchar2 default null)
  return boolean
 as

  cursor c2(vpk1 varchar2, istest in char, vtestinfo in varchar2, vstatus integer) is
   select to_char(deliveryno) deliveryno, to_char(sysdate,'YYYYMMDD') currdate, recno, po, po_item_no, supinv, to_char(sap_delno_qty) sap_delno_qty, unit_unitused, sap_delno_unit
   from strang.pos
   where istest = 'F' and
         deliveryno = to_number(vpk1) and
         OFF_SITE_RECEIPT is null and
         grn_status = to_char(vstatus)
  union all
   select vpk1 deliveryno, to_char(sysdate,'YYYYMMDD') currdate, to_number(vtestinfo) recno, vpk2 po, 123 po_item_no, 'SuppInv555' supinv, '1' sap_delno_qty, 'EA' unit_unitused, 'KG' sap_delno_unit
   from dual
   where istest = 'T'
   order by 3;

  bfr		varchar2(32767);
  varr		owa.vc_arr;
  arecno	owa.vc_arr;
  vrecno	integer;
  nrecno	integer;
  req    	utl_http.req;
  resp   	utl_http.resp;
  rw     	varchar2(32767);
  ctr		integer;
  sz		integer;
  x		integer;
  rctr		integer;
  url		varchar2(2000);
  name          varchar2(256);
  value         varchar2(1024);
  frec		boolean;
  stp		varchar2(1000);

  /*

   exec if strangw.interface2('511211','4500001434',vtest=>'T',vtestinfo=>'00012') then dbms_output.put_line('T'); end if;
   exec  DBMS_SCHEDULER.SET_ATTRIBUTE (name=>'BATCH_INTERFACE_2',attribute=>'repeat_interval', value=>'FREQ=MINUTELY; INTERVAL=2');

  */

 begin
   stp := 'a';
   x := 0;
   vrecno := 0;

   varr(1) := '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding"><soap:Body>';
   varr(2) := '<ns0:glmsGRofPurchaseOrder_MT xmlns:ns0="http://www.stxgroup.com.au/glms">';

   rctr := 2;
   frec := FALSE;
   for c2rec in c2(nvl(vpk1,'511211'),vtest,nvl(vtestinfo,'00010'),interface_2_status ) loop
     frec := TRUE;
     rctr := rctr + 1;
     varr(rctr) := '<glmsGRofPurchaseOrder_line>';
     rctr := rctr + 1;
     varr(rctr) := '<DELIVERYNO>' || xtra.xmlconv(c2rec.deliveryno) || '</DELIVERYNO>';
     rctr := rctr + 1;
     varr(rctr) := '<CURRDATE>' || xtra.xmlconv(c2rec.currdate) || '</CURRDATE>';
     rctr := rctr + 1;
     varr(rctr) := '<RECNO>' || xtra.xmlconv( to_char(c2rec.recno) ) || '</RECNO>';
     rctr := rctr + 1;
	 vrecno := vrecno + 1;
	 arecno(vrecno) := to_char(c2rec.recno);
     varr(rctr) := '<PO>' || xtra.xmlconv(c2rec.po) || '</PO>';
     rctr := rctr + 1;
     varr(rctr) := '<PO_ITEM_NO>' || xtra.xmlconv(c2rec.po_item_no) || '</PO_ITEM_NO>';
     rctr := rctr + 1;
     varr(rctr) := '<SUPINV>' || xtra.xmlconv(c2rec.supinv) || '</SUPINV>';
     rctr := rctr + 1;
     varr(rctr) := '<QTY>' || xtra.xmlconv(c2rec.sap_delno_qty) || '</QTY>';
--     varr(rctr) := '<QTY>' || xtra.xmlconv(c2rec.qty) || '</QTY>';
     rctr := rctr + 1;
     -- changed from as requested by Sallie: '<UNIT_UNITUSED>' || xtra.xmlconv(c2rec.unit_unitused) || '</UNIT_UNITUSED>'
--     varr(rctr) := '<SAP_DELNO_UNIT>' || xtra.xmlconv(c2rec.sap_delno_unit) || '</SAP_DELNO_UNIT>';
     varr(rctr) := '<UNIT_UNITUSED>' || xtra.xmlconv(c2rec.sap_delno_unit) || '</UNIT_UNITUSED>';
    rctr := rctr + 1;
    varr(rctr) := '</glmsGRofPurchaseOrder_line>';
   end loop;
   rctr := rctr + 1;
   varr(rctr) := '</ns0:glmsGRofPurchaseOrder_MT>';
   rctr := rctr + 1;
   varr(rctr) := '</soap:Body></soap:Envelope>';

   url := g_interface_2_url;
   stp := 'b';

   if not frec
    then
     external_audit( '2', 'Call Response', vpk1, vpk2, 'Nothing to push');
     return( FALSE );
   end if;
/*
For testing you can use PO no 4500001434 and its item no 00010, 00020 and 00030. (in sample file)
I have created 1000 quantity against each item in PO.
So if you goods receipt 1 quantity at a time you can use same PO again till 1000 items are received.
Please vary Delivery no and recno as well as supplier invoice number in you sample data.

  <glmsGRofPurchaseOrder_line>
    <DELIVERYNO>511211</DELIVERYNO>
    <CURRDATE>20180221</CURRDATE>
    <RECNO>00010</RECNO>
    <PO>4500001434</PO>
    <PO_ITEM_NO>00010</PO_ITEM_NO>
    <SUPINV>SuppInv555</SUPINV>
    <QTY>1</QTY>
    <UNIT_UNITUSED>EA</UNIT_UNITUSED>
  </glmsGRofPurchaseOrder_line>
    <glmsGRofPurchaseOrder_line>
    <DELIVERYNO>511211</DELIVERYNO>
    <CURRDATE>20180221</CURRDATE>
    <RECNO>00020</RECNO>
    <PO>4500001434</PO>
    <PO_ITEM_NO>00020</PO_ITEM_NO>
    <SUPINV>SuppInv555</SUPINV>
    <QTY>1</QTY>
    <UNIT_UNITUSED>EA</UNIT_UNITUSED>
  </glmsGRofPurchaseOrder_line>
    <glmsGRofPurchaseOrder_line>
    <DELIVERYNO>511211</DELIVERYNO>
    <CURRDATE>20180221</CURRDATE>
    <RECNO>00030</RECNO>
    <PO>4500001434</PO>
    <PO_ITEM_NO>00030</PO_ITEM_NO>
    <SUPINV>SuppInv555</SUPINV>
    <QTY>1</QTY>
    <UNIT_UNITUSED>EA</UNIT_UNITUSED>
  </glmsGRofPurchaseOrder_line>
*/
   stp := 'c';

/*
   if substr(upper(url),1,8) = 'HTTPS://'
    then
     UTL_HTTP.SET_WALLET ( 'file:' || 'c:\wallet', 'wolvie26' );
   end if;
*/

   if substr(upper(url),1,8) = 'HTTPS://'
    then
     -- adapt for XE
	 --UTL_HTTP.SET_WALLET ( 'file:' || 'c:\wallet', 'wolvie26' );
	 --dbms_output.put_line('x=' || replace(url,'https://','http://127.0.0.1:81/') );
	 req := UTL_HTTP.BEGIN_REQUEST(replace(url,'https://','http://127.0.0.1:81/'), method=>'POST');
	else
	 req := UTL_HTTP.BEGIN_REQUEST(url, method=>'POST');
   end if;

   stp := 'd';
   --req := UTL_HTTP.BEGIN_REQUEST(url, method=>'POST');
   sz := 0;
   stp := 'e';
   for j in varr.first..varr.last loop
     sz := sz + lengthb( varr(j) );
   end loop;
   stp := 'f';

   UTL_HTTP.SET_AUTHENTICATION(req, g_digest_un, g_digest_pw);
   stp := 'g';
   UTL_HTTP.SET_HEADER(req, name=> 'Content-Type', value=> 'text/xml');
   stp := 'h';
   UTL_HTTP.SET_HEADER(req, name=> 'Content-Length', value=> sz);

    stp := 'i';
  for j in varr.first..varr.last loop
     -- trace what is sent
     --external_audit( '2', 'Sent XML', vpk1, vpk2, varr(j));
     UTL_HTTP.WRITE_RAW( req, utl_raw.cast_to_raw(varr(j)) );
   end loop;

   begin
    resp := utl_http.get_response(req);
   exception
    when others then return( FALSE );
   end;
   stp := 'j';

   for i in 1..utl_http.get_header_count(resp) loop
    utl_http.get_header(resp, i, name, value);
   end loop;
   stp := 'k';

   ctr := 0;
   loop
    begin
     rw := null;
     utl_http.read_line(resp, rw, TRUE);
     if rw is null then exit; end if;
     ctr := ctr + 1;
     external_audit( '2', 'Call Response', vpk1, vpk2, rw);
     --dbms_output.put_line( rw );
    exception
     when others then exit;
    end;
   end loop;
  utl_http.end_response(resp);

  --
  -- update and change status
  -- When the Interface2 push occurs, the system updates the pos.grn_status to 8 of the records that are pushed.
   stp := 'l';
  if arecno.count > 0
   then
    for k in arecno.first..arecno.last loop
	 if arecno.exists(k)
	  then
	   nrecno := arecno(k);
       update strang.pos
        set
         OFF_SITE_RECEIPT = sysdate,
         grn_status = to_char(8)
        where
         deliveryno = to_number(vpk1) and
		 recno = nrecno;
		commit;
	    external_audit( '2', 'Processed', vpk1, nrecno, 'Update strang.pos');
	 end if;
	end loop;
   end if;


 --  and  grn_status = to_char(7) and
 --  OFF_SITE_RECEIPT is null
  /*
   Disabled as requested by Sallie

  update strang.receivals
   set
    STATUS = to_char(9) -- as specified by Sallie
  where
   deliveryno = to_number(vpk1);
  */
  commit;
  external_audit( '2', 'Processed', vpk1, vpk2, rw);
  return( TRUE );

 exception
  when others then
   external_audit( '2', 'Error', sqlerrm, vpk1,'interface2',stp);
   rollback;
   return( FALSE );
 end interface2;

 procedure batch_interface_2( v_command in varchar2 )
 as

  -- exec strangw.batch_interface_2('RUN');

  cursor c1(jname varchar2) is select * from user_scheduler_jobs where job_name = jname;
  cursor c2(vstatus integer) is
    select deliveryno
    from strang.pos
    where grn_status = to_char(vstatus) and
          off_site_receipt is null
    order by deliveryno;
    -- and DELIVERYNO >=4006032 AND DELIVERYNO <= 4006036

  c1rec		c1%ROWTYPE;
  jname		varchar2(100) := 'BATCH_INTERFACE_2';
  repint	varchar2(100) := 'FREQ=HOURLY; INTERVAL=1';
 begin

  if v_command = 'START'
   then
    dbms_scheduler.create_job(job_name=>jname, job_type=>'STORED_PROCEDURE', job_action => 'strangw.batch_interface_2', start_date=>null, repeat_interval=>repint, number_of_arguments=>1, enabled=>FALSE,  comments=>'Strang Batch Interface 2 Check');
    dbms_scheduler.set_job_argument_value(job_name=>jname, argument_position=>1, argument_value=>'RUN' );
    dbms_scheduler.enable(name=>jname);
    commit;
    batch_interface_2( 'STATUS' );
    return;
  end if;

  if v_command = 'STOP'
   then
    begin dbms_scheduler.drop_job(jname,TRUE); exception when others then null; end;
    batch_interface_2( 'STATUS' );
    return;
  end if;

  if v_command in ('STATUS','STATUS_HTML')
   then
    open c1(jname);
    fetch c1 into c1rec;
    close c1;
    if c1rec.job_name is null
     then
      if v_command = 'STATUS'
       then
        dbms_output.put_line( 'Job:' || jname || ' not found' );
       else
        htp.p( 'Job:' || jname || ' not found' );
      end if;
     else
      if v_command = 'STATUS'
       then
        dbms_output.put_line( 'Job:' || jname || ' ' || c1rec.state || ' - ' || to_char(c1rec.next_run_date,'dd-mon-yyyy hh24:mi') );
       else
        htp.p( 'Job:' || jname || ' ' || c1rec.state || ' - ' || to_char(c1rec.next_run_date,'dd-mon-yyyy hh24:mi') );
      end if;
    end if;
    return;
  end if;

  if v_command = 'RUN'
   then
   -- 0 initial, 1 manual grn, 234, critical parts, 8 ready for grn, 9 grn receipted
   -- Status is 8 as indicated by Sallie
   -- Currently, when pos.grn_status is 8, the system will pick up these records to push in Interface2.  Please change this to when pos.grn_status is 7.
    for c2rec in c2(interface_2_status) loop
     if interface2( c2rec.deliveryno, null ) then null; end if;
    end loop
    commit;
    return;
  end if;

 exception
  when others then
   external_audit( '2', 'Error batch_interface_2', sqlerrm);
   rollback;
 end batch_interface_2;

 function interface4(ud1 in varchar2 default null, ud2 in varchar2 default null, ud3 in varchar2 default null, ud4 in varchar2 default null, ud5 in varchar2 default null, vtest in char default 'F', vtestinfo in varchar2 default null)
  return boolean
 as
 
 
   cursor c1 is 
    select distinct m.* , d.hawb_hawbno, d.hawb_hawbno_2,
          p.po, p.po_item_no, p.grn, p.grn_item,
          s.shipname, 
          s.voy, 
          case when m.ship_id = 1 then null else s.estarrive end as estarrive,
          p.deliveryno, 
          p.recno,
          strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION', m.complete) packing_status,
         (select s2.shipname from strang.ships_airway s2 where s2.ship_id = m.local_ship_id) shipname_local, 
		 (select s2.voy from strang.ships_airway s2 where s2.ship_id = m.local_ship_id) voy_local, 
		 (select case when s2.ship_id = 2 then null else s2.estarrive end from strang.ships_airway s2 where s2.ship_id = m.local_ship_id) local_estarrive,
		 (select s3.convoyname from strang.convoy s3 where s3.convoy_id = m.convoy_id) convoy_name,
		 (select s3.convoy_type from strang.convoy s3 where s3.convoy_id  = m.convoy_id) convoy_voy,
		 (select s3.estdepart from strang.convoy s3 where s3.convoy_id  = m.convoy_id ) convoy_estarrive 
   from  strang.movements m, strang.ships_airway s, strang.detailrs d, strang.pos p, strang.receivals r
   where  m.ship_id = s.ship_id and
          m.movement_no = d.movement_no and
          m.movement_no <> 'OTMU1234567' and 
          nvl(d.camov_seal,'|') = nvl(m.seal,'|') and
          d.deliveryno = p.deliveryno and
          d.deliveryno = r.deliveryno and
          r.cust_customer_id = 1 and
	      nvl(m.complete,'|') <> 'J' and 
	      m.interface4_date is null and 
	      exists ( select 'x' 
	                 from stx1.interface4_marker i
	                where m.movement_no = i.movement_no
	                  and nvl(m.seal,'|') = nvl(i.seal,'|')
	                  and p.deliveryno >= i.deliveryno
	                  and p.recno > i.recno
	                  and p.po >= i.po )
	     order by p.po, p.deliveryno, p.recno;

  cursor c2 is
   select distinct m.*,
          d.hawb_hawbno,
          d.hawb_hawbno_2,
          p.po,
          p.po_item_no,
          p.grn,
          p.grn_item,
          s.shipname, 
          s.voy, 
          case when m.ship_id = 1 then null else s.estarrive end as estarrive,
        --  s.estarrive,
          p.deliveryno,
          p.recno,
          strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION', m.complete) packing_status,
          (select s2.shipname from strang.ships_airway s2 where s2.ship_id = m.local_ship_id) shipname_local,
		  (select s2.voy from strang.ships_airway s2 where s2.ship_id = m.local_ship_id) voy_local,
		  (select case when s2.ship_id = 2 then null else s2.estarrive end from strang.ships_airway s2 where s2.ship_id = m.local_ship_id) local_estarrive,
          (select s3.convoyname from strang.convoy s3 where s3.convoy_id = m.convoy_id) convoy_name,
		  (select s3.convoy_type from strang.convoy s3 where s3.convoy_id  = m.convoy_id) convoy_voy,
		  (select s3.estdepart from strang.convoy s3 where s3.convoy_id  = m.convoy_id ) convoy_estarrive
   from strang.movements m, strang.ships_airway s, strang.detailrs d, strang.pos p, strang.receivals r
   where m.ship_id = s.ship_id and
         m.movement_no = d.movement_no and
         m.movement_no <> 'OTMU1234567' and 
         nvl(d.camov_seal,'|') = nvl(m.seal,'|') and
         d.deliveryno = p.deliveryno and
         d.deliveryno = r.deliveryno and
         r.cust_customer_id = 1 and
	 nvl(m.complete,'|') <> 'J' and
	 m.interface4_date is null and 
	 not exists (select 'x' 
	               from stx1.interface4_marker i
	              where m.movement_no = i.movement_no
	                and nvl(m.seal,'|') = nvl(i.seal,'|'))
	order by m.movement_no, m.seal, p.po, p.deliveryno, p.recno;

  bfr		varchar2(32767);
  varr		owa.vc_arr;
  xarr		owa.vc_arr;
  sarr		owa.vc_arr;
  parr		owa.vc_arr;
  req    	utl_http.req;
  resp   	utl_http.resp;
  rw     	varchar2(32767);
  ctr		integer;
  sz		integer;
  x		    integer;
  k		    integer;
  rctr		integer;
  url		varchar2(2000);
  name      varchar2(256);
  vmn		varchar2(100);
  vsl		varchar2(100);
  vps		varchar2(100);
  value     varchar2(1024);
  limit_reached  boolean := FALSE;
  frec		boolean;

  /*
   exec if strangw.interface4(vtest=>'T',ud1=>'5') then dbms_output.put_line('T'); end if;
   exec if strangw.interface4(ud1=>'1') then dbms_output.put_line('T'); end if;
  */

 begin

   varr(1) := '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding"><soap:Body>';
   varr(2) := '<ns0:glmsShippingStatus_MT xmlns:ns0="http://www.stxgroup.com.au/glms">>';

/*

Sallie said for each repeat here to repeat the whole record.

pos.po
pos.po_item_no
pos.grn
pos.grn_item

movements.status
movements.urgency
movements.movement_type (cargo = containers, conmov = break bulk , air)
movements.movement_no
movements.seal
movements.io (inbound to site,outbound from site)
movements.full_mt
movements.consignee
movements.consignee_location
movements.warehouse_location
movements.current_location
movements.customs_cleared_date
movements.local_bol (local ship)
movements.bol (international ship)

ships_airway.shipname (international ship/mawb)
ships_airway.voy (international ship/mawb)
ships_airway.estarrive (international ship/mawb)
ships_airway.shipname (local ship/mawb)
ships_airway.voy (local ship/mawb)
ships_airway.estarrive (local ship/mawb)
ships_airway.shipname (convoy)
ships_airway.voy (convoy)
ships_airway.estarrive (convoy)

detailrs.hawb_hawbno (international mawb)
details.hawb_hawbno_2 (local mawb)

*/

   x := 2;
   rctr := 0;
   k := 0;
   frec := FALSE;
   
   for c1rec in c1 loop
      if limit_reached then exit; end if;
      rctr := rctr + 1;
      frec := TRUE;
    
      x := x + 1; varr(x) := '<glmsShippingStatus_line>';
      x := x + 1; varr(x) := '<POS_PO>' || xtra.xmlconv( c1rec.po ) || '</POS_PO>';
      x := x + 1; varr(x) := '<POS_PO_ITEM_NO>' || xtra.xmlconv( c1rec.po_item_no ) || '</POS_PO_ITEM_NO>';
      x := x + 1; varr(x) := '<POS_GRN>' || xtra.xmlconv( c1rec.grn ) || '</POS_GRN>';
      x := x + 1; varr(x) := '<POS_GRN_ITEM>' || xtra.xmlconv( c1rec.grn_item ) || '</POS_GRN_ITEM>';
      x := x + 1; varr(x) := '<POS_DELIVERYNO>' || xtra.xmlconv( c1rec.deliveryno ) || '</POS_DELIVERYNO>';
      x := x + 1; varr(x) := '<POS_RECNO>' || xtra.xmlconv( c1rec.recno ) || '</POS_RECNO>';

      x := x + 1; varr(x) := '<MOVEMENTS_STATUS>' || xtra.xmlconv( c1rec.packing_status) || '</MOVEMENTS_STATUS>';
      x := x + 1; varr(x) := '<MOVEMENTS_URGENCY>' || xtra.xmlconv( c1rec.urgency ) || '</MOVEMENTS_URGENCY>';
      x := x + 1; varr(x) := '<MOVEMENTS_MOVEMENT_TYPE>' || xtra.xmlconv( c1rec.movement_type ) || '</MOVEMENTS_MOVEMENT_TYPE>';
      x := x + 1; varr(x) := '<MOVEMENTS_MOVEMENT_NO>' || xtra.xmlconv( c1rec.movement_no ) || '</MOVEMENTS_MOVEMENT_NO>';
      x := x + 1; varr(x) := '<MOVEMENTS_SEAL>' || xtra.xmlconv( c1rec.seal ) || '</MOVEMENTS_SEAL>';
      x := x + 1; varr(x) := '<MOVEMENTS_IO>' || xtra.xmlconv( c1rec.io ) || '</MOVEMENTS_IO>';
      x := x + 1; varr(x) := '<MOVEMENTS_FULL_MT>' || xtra.xmlconv( c1rec.full_mt ) || '</MOVEMENTS_FULL_MT>';
      x := x + 1; varr(x) := '<MOVEMENTS_CONSIGNEE>' || xtra.xmlconv( c1rec.consignee ) || '</MOVEMENTS_CONSIGNEE>';
      x := x + 1; varr(x) := '<MOVEMENTS_CONSIGNEE_LOCATION>' || xtra.xmlconv( c1rec.consignee_location ) || '</MOVEMENTS_CONSIGNEE_LOCATION>';
      x := x + 1; varr(x) := '<MOVEMENTS_WAREHOUSE_DESTINATION>' || xtra.xmlconv( c1rec.warehouse_destination ) || '</MOVEMENTS_WAREHOUSE_DESTINATION>';
      x := x + 1; varr(x) := '<MOVEMENTS_CURRENT_LOCATION>' || xtra.xmlconv( c1rec.current_location ) || '</MOVEMENTS_CURRENT_LOCATION>';
      x := x + 1; varr(x) := '<MOVEMENTS_CUSTOMS_CLEARED_DATE>' || xtra.xmlconv( to_char(c1rec.customs_cleared_date,'YYYYMMDD') ) || '</MOVEMENTS_CUSTOMS_CLEARED_DATE>';
      x := x + 1; varr(x) := '<MOVEMENTS_LOCAL_BOL>' || xtra.xmlconv( c1rec.local_bol ) || '</MOVEMENTS_LOCAL_BOL>';
      x := x + 1; varr(x) := '<MOVEMENTS_BOL>' || xtra.xmlconv( c1rec.bol ) || '</MOVEMENTS_BOL>';

      x := x + 1; varr(x) := '<SHIPS_AIRWAY_SHIPNAME>' || xtra.xmlconv( c1rec.shipname ) || '</SHIPS_AIRWAY_SHIPNAME>';
      x := x + 1; varr(x) := '<SHIPS_AIRWAY_VOY>' || xtra.xmlconv( c1rec.voy ) || '</SHIPS_AIRWAY_VOY>';
      x := x + 1; varr(x) := '<SHIPS_AIRWAY_ESTARRIVE>' || xtra.xmlconv( to_char(c1rec.estarrive,'YYYYMMDD') ) || '</SHIPS_AIRWAY_ESTARRIVE>';
      x := x + 1; varr(x) := '<SHIPS_AIRWAY_SHIPNAME_LOCAL>' || xtra.xmlconv( c1rec.shipname_local ) || '</SHIPS_AIRWAY_SHIPNAME_LOCAL>';
      x := x + 1; varr(x) := '<SHIPS_AIRWAY_VOY_LOCAL>' || xtra.xmlconv( c1rec.voy_local ) || '</SHIPS_AIRWAY_VOY_LOCAL>';
      x := x + 1; varr(x) := '<SHIPS_AIRWAY_LOCAL_ESTARRIVE>' || xtra.xmlconv( to_char(c1rec.local_estarrive,'YYYYMMDD') ) || '</SHIPS_AIRWAY_LOCAL_ESTARRIVE>';
      x := x + 1; varr(x) := '<SHIPS_AIRWAY_CONVOY_NAME>' || xtra.xmlconv( c1rec.convoy_name ) || '</SHIPS_AIRWAY_CONVOY_NAME>';
      x := x + 1; varr(x) := '<SHIPS_AIRWAY_CONVOY_VOY>' || xtra.xmlconv( c1rec.convoy_voy ) || '</SHIPS_AIRWAY_CONVOY_VOY>';
      x := x + 1; varr(x) := '<SHIPS_AIRWAY_CONVOY_ESTARRIVE>' || xtra.xmlconv( to_char(c1rec.convoy_estarrive,'YYYYMMDD') ) || '</SHIPS_AIRWAY_CONVOY_ESTARRIVE>';

      x := x + 1; varr(x) := '<DETAILRS_HAWB_HAWBNO>' || xtra.xmlconv( c1rec.hawb_hawbno ) || '</DETAILRS_HAWB_HAWBNO>';
      x := x + 1; varr(x) := '<DETAILRS_HAWB_HAWBNO_2>' || xtra.xmlconv( c1rec.hawb_hawbno_2 ) || '</DETAILRS_HAWB_HAWBNO_2>';

      x := x + 1; varr(x) := '</glmsShippingStatus_line>';
      if  (k = 0) then
         k := k + 1;
         xarr(k) := c1rec.movement_no;
         sarr(k) := c1rec.seal;
         parr(k) := c1rec.po;
      elsif (xarr(k) = c1rec.movement_no and nvl(sarr(k),'|') = nvl(c1rec.seal,'|') and parr(k) = c1rec.po) then
         null;
      else
         k := k + 1;
         xarr(k) := c1rec.movement_no;
         sarr(k) := c1rec.seal;
         parr(k) := c1rec.po;
      end if;
      -- START HERE POPULATING NEW TABLE
      INSERT INTO websys.interface4_records 
      ( po, po_item_no, grn, grn_item, deliveryno, recno,
       packing_status, urgency, movement_type, movement_no, seal,
       io, full_mt, consignee, consignee_location, warehouse_destination,
       current_location, customs_cleared_date, local_bol, bol,
       shipname, voy, estarrive,shipname_local, voy_local, local_estarrive,
       convoyname, convoy_type, convoy_estdepart, hawb_hawbno, hawb_hawbno_2, post_date
      )
      VALUES (c1rec.po, c1rec.po_item_no, c1rec.grn, c1rec.grn_item, c1rec.deliveryno, c1rec.recno, c1rec.packing_status,
              c1rec.urgency, c1rec.movement_type, c1rec.movement_no, c1rec.seal, c1rec.io, c1rec.full_mt, c1rec.consignee,
              c1rec.consignee_location, c1rec.warehouse_destination, c1rec.current_location, c1rec.customs_cleared_date,
              c1rec.local_bol, c1rec.bol, c1rec.shipname, c1rec.voy, c1rec.estarrive, c1rec.shipname_local, c1rec.voy_local,
              c1rec.local_estarrive, c1rec.convoy_name, c1rec.convoy_voy, c1rec.convoy_estarrive, c1rec.hawb_hawbno, 
              c1rec.hawb_hawbno_2, sysdate );
      COMMIT;

      if rctr > to_number(ud1) then 
         DELETE FROM stx1.interface4_marker;
         insert into stx1.interface4_marker (movement_no, seal, po, deliveryno, recno)
         values (c1rec.movement_no, c1rec.seal, c1rec.po, c1rec.deliveryno, c1rec.recno);
         COMMIT;
         limit_reached := TRUE;
         exit; 
      end if;
      
      
   end loop;

   
   for c2rec in c2 loop
      if limit_reached then exit; end if;
      rctr := rctr + 1;
      frec := TRUE;
    
      x := x + 1; varr(x) := '<glmsShippingStatus_line>';
      x := x + 1; varr(x) := '<POS_PO>' || xtra.xmlconv( c2rec.po ) || '</POS_PO>';
      x := x + 1; varr(x) := '<POS_PO_ITEM_NO>' || xtra.xmlconv( c2rec.po_item_no ) || '</POS_PO_ITEM_NO>';
      x := x + 1; varr(x) := '<POS_GRN>' || xtra.xmlconv( c2rec.grn ) || '</POS_GRN>';
      x := x + 1; varr(x) := '<POS_GRN_ITEM>' || xtra.xmlconv( c2rec.grn_item ) || '</POS_GRN_ITEM>';
      x := x + 1; varr(x) := '<POS_DELIVERYNO>' || xtra.xmlconv( c2rec.deliveryno ) || '</POS_DELIVERYNO>';
      x := x + 1; varr(x) := '<POS_RECNO>' || xtra.xmlconv( c2rec.recno ) || '</POS_RECNO>';

      x := x + 1; varr(x) := '<MOVEMENTS_STATUS>' || xtra.xmlconv( c2rec.packing_status) || '</MOVEMENTS_STATUS>';
      x := x + 1; varr(x) := '<MOVEMENTS_URGENCY>' || xtra.xmlconv( c2rec.urgency ) || '</MOVEMENTS_URGENCY>';
      x := x + 1; varr(x) := '<MOVEMENTS_MOVEMENT_TYPE>' || xtra.xmlconv( c2rec.movement_type ) || '</MOVEMENTS_MOVEMENT_TYPE>';
      x := x + 1; varr(x) := '<MOVEMENTS_MOVEMENT_NO>' || xtra.xmlconv( c2rec.movement_no ) || '</MOVEMENTS_MOVEMENT_NO>';
      x := x + 1; varr(x) := '<MOVEMENTS_SEAL>' || xtra.xmlconv( c2rec.seal ) || '</MOVEMENTS_SEAL>';
      x := x + 1; varr(x) := '<MOVEMENTS_IO>' || xtra.xmlconv( c2rec.io ) || '</MOVEMENTS_IO>';
      x := x + 1; varr(x) := '<MOVEMENTS_FULL_MT>' || xtra.xmlconv( c2rec.full_mt ) || '</MOVEMENTS_FULL_MT>';
      x := x + 1; varr(x) := '<MOVEMENTS_CONSIGNEE>' || xtra.xmlconv( c2rec.consignee ) || '</MOVEMENTS_CONSIGNEE>';
      x := x + 1; varr(x) := '<MOVEMENTS_CONSIGNEE_LOCATION>' || xtra.xmlconv( c2rec.consignee_location ) || '</MOVEMENTS_CONSIGNEE_LOCATION>';
      x := x + 1; varr(x) := '<MOVEMENTS_WAREHOUSE_DESTINATION>' || xtra.xmlconv( c2rec.warehouse_destination ) || '</MOVEMENTS_WAREHOUSE_DESTINATION>';
      x := x + 1; varr(x) := '<MOVEMENTS_CURRENT_LOCATION>' || xtra.xmlconv( c2rec.current_location ) || '</MOVEMENTS_CURRENT_LOCATION>';
      x := x + 1; varr(x) := '<MOVEMENTS_CUSTOMS_CLEARED_DATE>' || xtra.xmlconv( to_char(c2rec.customs_cleared_date,'YYYYMMDD') ) || '</MOVEMENTS_CUSTOMS_CLEARED_DATE>';
      x := x + 1; varr(x) := '<MOVEMENTS_LOCAL_BOL>' || xtra.xmlconv( c2rec.local_bol ) || '</MOVEMENTS_LOCAL_BOL>';
      x := x + 1; varr(x) := '<MOVEMENTS_BOL>' || xtra.xmlconv( c2rec.bol ) || '</MOVEMENTS_BOL>';

      x := x + 1; varr(x) := '<SHIPS_AIRWAY_SHIPNAME>' || xtra.xmlconv( c2rec.shipname ) || '</SHIPS_AIRWAY_SHIPNAME>';
      x := x + 1; varr(x) := '<SHIPS_AIRWAY_VOY>' || xtra.xmlconv( c2rec.voy ) || '</SHIPS_AIRWAY_VOY>';
      x := x + 1; varr(x) := '<SHIPS_AIRWAY_ESTARRIVE>' || xtra.xmlconv( to_char(c2rec.estarrive,'YYYYMMDD') ) || '</SHIPS_AIRWAY_ESTARRIVE>';
      x := x + 1; varr(x) := '<SHIPS_AIRWAY_SHIPNAME_LOCAL>' || xtra.xmlconv( c2rec.shipname_local ) || '</SHIPS_AIRWAY_SHIPNAME_LOCAL>';
      x := x + 1; varr(x) := '<SHIPS_AIRWAY_VOY_LOCAL>' || xtra.xmlconv( c2rec.voy_local ) || '</SHIPS_AIRWAY_VOY_LOCAL>';
      x := x + 1; varr(x) := '<SHIPS_AIRWAY_LOCAL_ESTARRIVE>' || xtra.xmlconv( to_char(c2rec.local_estarrive,'YYYYMMDD') ) || '</SHIPS_AIRWAY_LOCAL_ESTARRIVE>';
      x := x + 1; varr(x) := '<SHIPS_AIRWAY_CONVOY_NAME>' || xtra.xmlconv( c2rec.convoy_name ) || '</SHIPS_AIRWAY_CONVOY_NAME>';
      x := x + 1; varr(x) := '<SHIPS_AIRWAY_CONVOY_VOY>' || xtra.xmlconv( c2rec.convoy_voy ) || '</SHIPS_AIRWAY_CONVOY_VOY>';
      x := x + 1; varr(x) := '<SHIPS_AIRWAY_CONVOY_ESTARRIVE>' || xtra.xmlconv( to_char(c2rec.convoy_estarrive,'YYYYMMDD') ) || '</SHIPS_AIRWAY_CONVOY_ESTARRIVE>';

      x := x + 1; varr(x) := '<DETAILRS_HAWB_HAWBNO>' || xtra.xmlconv( c2rec.hawb_hawbno ) || '</DETAILRS_HAWB_HAWBNO>';
      x := x + 1; varr(x) := '<DETAILRS_HAWB_HAWBNO_2>' || xtra.xmlconv( c2rec.hawb_hawbno_2 ) || '</DETAILRS_HAWB_HAWBNO_2>';

      x := x + 1; varr(x) := '</glmsShippingStatus_line>';
      if  (k = 0) then
         k := k + 1;
         xarr(k) := c2rec.movement_no;
         sarr(k) := c2rec.seal;
         parr(k) := c2rec.po;
      elsif (xarr(k) = c2rec.movement_no and nvl(sarr(k),'|') = nvl(c2rec.seal,'|') and parr(k) = c2rec.po) then
         null;
      else
         k := k + 1;
         xarr(k) := c2rec.movement_no;
         sarr(k) := c2rec.seal;
         parr(k) := c2rec.po;
      end if;
      
     -- START HERE POPULATING NEW TABLE
      INSERT INTO websys.interface4_records 
      ( po, po_item_no, grn, grn_item, deliveryno, recno,
       packing_status, urgency, movement_type, movement_no, seal,
       io, full_mt, consignee, consignee_location, warehouse_destination,
       current_location, customs_cleared_date, local_bol, bol,
       shipname, voy, estarrive,shipname_local, voy_local, local_estarrive,
       convoyname, convoy_type, convoy_estdepart, hawb_hawbno, hawb_hawbno_2, post_date
      )
      VALUES (c2rec.po, c2rec.po_item_no, c2rec.grn, c2rec.grn_item, c2rec.deliveryno, c2rec.recno, c2rec.packing_status,
              c2rec.urgency, c2rec.movement_type, c2rec.movement_no, c2rec.seal, c2rec.io, c2rec.full_mt, c2rec.consignee,
              c2rec.consignee_location, c2rec.warehouse_destination, c2rec.current_location, c2rec.customs_cleared_date,
              c2rec.local_bol, c2rec.bol, c2rec.shipname, c2rec.voy, c2rec.estarrive, c2rec.shipname_local, c2rec.voy_local,
              c2rec.local_estarrive, c2rec.convoy_name, c2rec.convoy_voy, c2rec.convoy_estarrive, c2rec.hawb_hawbno, 
              c2rec.hawb_hawbno_2, sysdate );
      COMMIT;
      
    
      if rctr > to_number(ud1) then 
         DELETE FROM stx1.interface4_marker;
         insert into stx1.interface4_marker  (movement_no, seal, po, deliveryno, recno)
         values (c2rec.movement_no, c2rec.seal, c2rec.po, c2rec.deliveryno, c2rec.recno);
         COMMIT;
         limit_reached := TRUE;
         exit; 
      end if;
   
   end loop;
   
   x := x + 1; varr(x) := '</ns0:glmsShippingStatus_MT>';
   x := x + 1; varr(x) := '</soap:Body></soap:Envelope>';

   if NOT limit_reached then 
      DELETE FROM stx1.interface4_marker;
   end if;

   if vtest = 'T'
    then
     for j in 1..x loop
      dbms_output.put_line(varr(j));
     end loop;
     return(TRUE);
   end if;

   if not frec then return( TRUE ); end if; -- nothing to do

   url := g_interface_4_url; 
   
/*
   if substr(upper(url),1,8) = 'HTTPS://'
    then
     UTL_HTTP.SET_WALLET ( 'file:' || 'c:\wallet', 'wolvie26' );
   end if;
 */
 
   if substr(upper(url),1,8) = 'HTTPS://'
    then
     -- adapt for XE
	 --UTL_HTTP.SET_WALLET ( 'file:' || 'c:\wallet', 'wolvie26' );
	 --dbms_output.put_line('x=' || replace(url,'https://','http://127.0.0.1:81/') );
	 req := UTL_HTTP.BEGIN_REQUEST(replace(url,'https://','http://127.0.0.1:81/'), method=>'POST');
	else
	 req := UTL_HTTP.BEGIN_REQUEST(url, method=>'POST');
   end if;

   --req := UTL_HTTP.BEGIN_REQUEST(url, method=>'POST');
   sz := 0;
   for j in varr.first..varr.last loop
     sz := sz + lengthb( varr(j) );
   end loop;
   
   UTL_HTTP.SET_AUTHENTICATION(req, g_digest_un, g_digest_pw);
   UTL_HTTP.SET_HEADER(req, name=> 'Content-Type', value=> 'text/xml');
   UTL_HTTP.SET_HEADER(req, name=> 'Content-Length', value=> sz);

   for j in varr.first..varr.last loop
    UTL_HTTP.WRITE_RAW( req, utl_raw.cast_to_raw(varr(j)) );
   end loop;

   begin
    resp := utl_http.get_response(req);
   exception
    when others then return( FALSE );
   end;

   for i in 1..utl_http.get_header_count(resp) loop
    utl_http.get_header(resp, i, name, value);
   end loop;

   ctr := 0;
   loop
    begin
     rw := null;
     utl_http.read_line(resp, rw, TRUE);
     if rw is null then exit; end if;
     ctr := ctr + 1;
     external_audit( '4', 'Call Response', rw);
     --dbms_output.put_line( rw );
    exception
     when others then exit;
    end;
   end loop;
  utl_http.end_response(resp);

  -- update and change status
  if xarr.count > 0
   then
    for j in xarr.first..xarr.last loop
     vmn := xarr(j);
     vsl := sarr(j);
     vps := parr(j);
     external_audit( '4', '. Pushed Movement No and Seal and Pos', vmn, vsl, vps);
     update strang.movements m set interface4_date = sysdate 
     where nvl(m.complete,'|') <> 'J' 
     and movement_no = vmn 
     and nvl(seal,'|') = nvl(vsl,'|')
     and not exists (select 'x'
                       from stx1.interface4_marker i
                      where m.movement_no = i.MOVEMENT_NO
                        and nvl(m.seal,'|') = nvl(i.seal,'|'));
                        
    end loop;
  end if;
  commit;
  external_audit( '4', 'Processed', rw);
  return( TRUE );

 exception
  when others then
   external_audit( '4', 'Error', sqlerrm);
   rollback;
   return( FALSE );
 end interface4;

 procedure batch_interface_4( v_command in varchar2 )
 as

  /*

   exec strangw.batch_interface_4('START');
   exec strangw.batch_interface_4('RUN');
   exec  DBMS_SCHEDULER.SET_ATTRIBUTE (name=>'BATCH_INTERFACE_4',attribute=>'repeat_interval', value=>'FREQ=MINUTELY; INTERVAL=5');
  */

  cursor c1(jname varchar2) is select * from user_scheduler_jobs where job_name = jname;

  c1rec		c1%ROWTYPE;
  jname		varchar2(100) := 'BATCH_INTERFACE_4';
  repint	varchar2(100) := 'FREQ=HOURLY; INTERVAL=1';
 begin

  if v_command = 'START'
   then
    dbms_scheduler.create_job(job_name=>jname, job_type=>'STORED_PROCEDURE', job_action => 'strangw.batch_interface_4', start_date=>null, repeat_interval=>repint, number_of_arguments=>1, enabled=>FALSE,  comments=>'Strang Batch Interface 2 Check');
    dbms_scheduler.set_job_argument_value(job_name=>jname, argument_position=>1, argument_value=>'RUN' );
    dbms_scheduler.enable(name=>jname);
    commit;
    batch_interface_4( 'STATUS' );
    return;
  end if;

  if v_command = 'STOP'
   then
    begin dbms_scheduler.drop_job(jname,TRUE); exception when others then null; end;
    batch_interface_4( 'STATUS' );
    return;
  end if;

  if v_command in ('STATUS','STATUS_HTML')
   then
    open c1(jname);
    fetch c1 into c1rec;
    close c1;
    if c1rec.job_name is null
     then
      if v_command = 'STATUS'
       then
        dbms_output.put_line( 'Job:' || jname || ' not found' );
       else
        htp.p( 'Job:' || jname || ' not found' );
      end if;
     else
      if v_command = 'STATUS'
       then
        dbms_output.put_line( 'Job:' || jname || ' ' || c1rec.state || ' - ' || to_char(c1rec.next_run_date,'dd-mon-yyyy hh24:mi') );
       else
        htp.p( 'Job:' || jname || ' ' || c1rec.state || ' - ' || to_char(c1rec.next_run_date,'dd-mon-yyyy hh24:mi') );
      end if;
    end if;
    return;
  end if;

  if v_command = 'RUN'
   then
    if interface4(ud1=>'1000') then null; end if; -- limit interface4 run, by MK April 09th 2019 to avoid memory blow out
    return;
  end if;

 exception
  when others then
   external_audit( '4', 'Error batch_interface_4', sqlerrm);
   rollback;
 end batch_interface_4;

/*

 GET:
 http://strang-svr.piction.com/sws/trace
 http://strang-svr.piction.com/sws/ping
 http://strang-svr.piction.com/sws/pos/4500033241
 http://strang-svr.piction.com/sws/poss/4500033241
 http://strang-svr.piction.com/sws/possoap/4500033241
 http://strang-svr.piction.com/sws/status
 curl http://strang-svr.piction.com/sws/pos/4500033241

 POST:
 curl -X POST -d @T:\piction\customer\source\strang\testpush.xml http://strang-svr.piction.com/sws/pospush --header "Content-Type:text/xml"
 curl -X POST -d @T:\piction\customer\source\strang\testpush.xml http://strang-svr.piction.com/sws/pospush/validate --header "Content-Type:text/xml"
 curl -X POST -d @T:\piction\customer\source\strang\testpush.xml http://strang-svr.piction.com/sws/pospush/validate_full --header "Content-Type:text/xml"

https://glms.stxgroup.com.au:4430/pls/piction/ping
https://glms.stxgroup.com.au:4430/sws/status
https://glms.stxgroup.com.au:4430/sws/trace

 curl -X POST -d @:p\piction\customer\source\strang\testpush.xml https://glms.stxgroup.com.au:4430/sws/pospush --header "Content-Type:text/xml"
 curl -X POST -d @t:\piction\customer\source\strang\testpush.xml https://glms.stxgroup.com.au:4430/swstmp1/pospush --header "Content-Type:text/xml"

*/

end strangw;

/
