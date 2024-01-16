CREATE OR REPLACE PROCEDURE WEBSYS."LOAD_FILES_ACCEPT" (surl in varchar2, rid in varchar2, recctr integer, vtyp varchar2, infile owa.vc_arr, action varchar2) as

cursor c2(vrid rowid) is
 select dl.deliveryno
       , dl.itemno
	   , c1.customer CLIENT
 	   , c2.customer SUPPLIER
 	   , p.po PO_NO
 	   , p.supinv INVOICE
 from   strang.receivals r, strang.customers c1, strang.customers c2, strang.detailrs dl, strang.pos p
 where  dl.deliveryno = r.deliveryno
        and p.deliveryno = dl.deliveryno
 	    and c1.customer_id = r.cust_customer_id
 	    and c2.customer_id = r.supplier_customer_id
 	    and dl.rowid=vrid
 ;

cursor c3(v_file varchar2) is select * from apache_ows_content where name = v_file;

INVALID_RID exception;
PRAGMA EXCEPTION_INIT(INVALID_RID, -1410);

c1rec         customer_account%ROWTYPE;
c2rec         c2%ROWTYPE;
c3rec         c3%ROWTYPE;
status        number;
deliveryno    number := 123456;
v_dir         varchar2(64);
v_file        varchar2(1000);

pfx           THEME%ROWTYPE;
ltype         varchar2(100);
stype         integer;
owner_id      integer;
sts           varchar2(100);
vaccess       varchar2(20);
vste          varchar2(10);
seclevel      varchar2(100);

msg           varchar2(1000);

begin

 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.DETAIL_ITEMS' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 -- vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 -- vaccess := data_access( owner_id, 'DETAIL_ITEMS', null );
 seclevel := oltp.security_role( owner_id );

 case upper(action)
 when 'CANCEL'
  then
   strangp.receive(surl, rid, scid=>null, call_name=>null, parm=>'DETAILRS', access_id=>'x', msg=>'Label Printing Cancelled', vrecctr=>recctr );
   return;
 when 'BACK'
  then
   strangp.receive(surl, rid, scid=>null, call_name=>null, parm=>'DETAILRS', access_id=>'x', msg=>NULL, vrecctr=>recctr );
   return;
 else null;
 end case;

 begin
 open c2(replace(rid, '~', '+'));
 fetch c2 into c2rec;
 close c2;
 exception
  when INVALID_RID then
   htp.htmlopen;
    htp.header(2,'Detail Item not found, ROWID: ' || replace(rid, '~', '+'), 'CENTER' );
    htp.header(3,'Hit the back button and retry', 'CENTER' );
    htp.header(3,'If problem persists, please contact the administrator', 'CENTER' );
   htp.htmlclose;
   return;
 end;
 if infile.count < 1
  then
   load_files(surl, rid, recctr, vtyp, 'No Files Selected');
 end if;

 if upper (action) not like 'LOAD INTO%'
  then
   load_files(surl, rid, recctr, vtyp, 'Invalid action: ' || action);
 end if;

 for j in infile.first..infile.last loop
  open c3(infile(j));
  fetch c3 into c3rec;
  if c3%FOUND
   then
    v_dir := glbx.extract_master_parameter('STRANG_RECEIVALS_DIR') || decs.UNIX_OR_NT || c2rec.deliveryno || decs.UNIX_OR_NT || trim(replace(upper(action), 'LOAD INTO', ''));
	v_file :=  glbx.extract_fname(c3rec.name, 'FILE');
    if utl_os.mkdir(v_dir) then null; end if;
    utl_blob.blobtofile(c3rec.blob_content, v_dir || decs.UNIX_OR_NT || v_file, FALSE);
	if file_exists(v_dir, v_file)
	 then
	  msg := msg || 'File saved: ' || v_file || '<br>';
    else
	  msg := msg || 'File NOT saved: ' || v_file || '<br>';
	end if;
  end if;
  close c3;
  delete from apache_ows_content where name = infile(j); commit;
 end loop;
 load_files(surl, rid, recctr, vtyp, msg);
exception when others then
 htp.bold('Error: ' || sqlerrm);
end load_files_accept;
/
