CREATE OR REPLACE procedure WEBSYS.ingest_convoy_excel_file (msg in varchar2 default null)
as  
v_instance    varchar2(1000);
begin
 begin select upper(instance_name) || ' on ' || host_name into v_instance from v$instance; exception when others then null; end;
 htp.htmlopen;
 htp.headopen;
 htp.p('<link rel="stylesheet" type="text/css" href="/images/str/style.css" />');
 htp.headclose;
 htp.bodyopen;
  htp.p('<CENTER>');
  htp.header(1,'Upload Convoy Plan', 'CENTER' );
  htp.nl;
  htp.header(2,'Instance details: ' || v_instance, 'CENTER' );
  htp.nl;
  if msg is not null
   then
    htp.header(1, msg, cattributes=>'style="color: red;"');
  end if;
  htp.nl;
  htp.formopen('accept_ingest_convoy_file', 'POST', cattributes=>'enctype="multipart/form-data"');
  htp.p('<input type="file" id="infile" name="infile" accept=".xlsx">');
  htp.formsubmit('action','Load Excel file');
  htp.formclose;
  htp.p('</CENTER>');
 htp.bodyclose;
 htp.htmlclose;
end ingest_convoy_excel_file;
/
