CREATE OR REPLACE PROCEDURE WEBSYS."LOAD_FILES" (surl in varchar2, rid in varchar2, recctr integer, vtyp varchar2 default 'RECEIPT', msg in varchar2 default null) as

 cursor c2(vrid rowid) is
  select dl.rowid
       , dl.deliveryno
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

 cursor c3 is
  select mo.name, mv.name_default
  from   main_object mo, main_value mv
  where  mo.mid = mv.mid
         and mo.theme_type = 'STRANG_RECEIVALS_FOLDERS'
  ;

 INVALID_RID exception;
 PRAGMA EXCEPTION_INIT(INVALID_RID, -1410);

 c1rec        customer_account%ROWTYPE;
 c2rec        c2%ROWTYPE;
 pfx          THEME%ROWTYPE;
 ltype        varchar2(100);
 stype        integer;
 owner_id     integer;
 sts          varchar2(100);
 vaccess      varchar2(20);
 vste         varchar2(10);
 seclevel     varchar2(100);

 v_url        varchar2(1000);
 file_types   CONSTANT varchar2(1000) := '.pdf,image/x-png,image/gif,image/jpeg,.csv, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/vnd.ms-excel';

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.LOAD_FILES' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 -- vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 -- vaccess := data_access( owner_id, 'LOAD_FILES', null );
 seclevel := oltp.security_role( owner_id );

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

 htp.htmlopen;

 htp.headopen;
 htp.p('<link rel="stylesheet" type="text/css" href="/images/str/style.css" />');
 htp.headclose;

 htp.bodyopen;
  htp.p('<CENTER>');
  htp.header(1,'Load Files', 'CENTER' );
  v_url := htf.anchor( 'javascript: window.open(''' || '/' || glbx.extract_master_parameter('APACHE_RECEIVALS_DIR') || '/' || c2rec.deliveryno || '/'  || ''',''' || 'vtyp' || ''',''height=800,width=600,scrollbars=yes,resizable=yes'');void('''');', c2rec.deliveryno );
  htp.header(2,'Delivery Number:  ' ||v_url, 'CENTER' );
  htp.nl;

  if msg is not null
   then
    htp.header(1, msg, cattributes=>'style="color: red;"');
  end if;
  htp.formopen('load_files_accept', 'POST', null, 'multipart/form-data');
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'RID', rid );
  htp.formhidden( 'RECCTR', recctr );
  htp.formhidden( 'VTYP', vtyp );
  htp.tableopen;
   for c3rec in c3 loop
   v_url := htf.anchor( 'javascript: window.open(''' || '/' || glbx.extract_master_parameter('APACHE_RECEIVALS_DIR') || '/' || c2rec.deliveryno || '/'  || c3rec.name || '/' || ''',''' || 'vtyp' || ''',''height=800,width=600,scrollbars=yes,resizable=yes'');void('''');', 'Listing' );
   htp.tablerowopen;
    if c3%ROWCOUNT = 1
	 then
	  htp.tabledata(htf.formfile('infile', file_types, 'multiple'));
	else
      htp.tabledata('&nbsp;');
	end if;
	htp.tabledata(htf.formsubmit('action', 'Load into ' || c3rec.name_default));
	htp.tabledata(v_url);
   htp.tablerowclose;
   end loop;
  htp.tableclose;

  htp.formclose;
  htp.bold('<a href="" onClick="self.close()">[Close Window]</a>');
  htp.p('</CENTER>');

 htp.bodyclose;
 htp.htmlclose;
end load_files;
/
