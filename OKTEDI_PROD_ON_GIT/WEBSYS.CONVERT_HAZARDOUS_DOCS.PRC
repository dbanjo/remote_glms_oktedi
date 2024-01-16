CREATE OR REPLACE procedure WEBSYS.convert_hazardous_docs (v_umo integer) as

cursor cu(vumo integer) is select * from umo where umo_id = vumo;

cursor c1(v_ship integer, v_container varchar2) is
select /*+ ALL_ROWS */ deliveryno
from (select c1.customer, c.customer, dr.deliveryno,dr.itemno
      from strang.detailrs dr,strang.receivals r, strang.movements m, strang.lov l,strang.customers c,strang.customers c1
      where r.deliveryno = dr.deliveryno and
            l.code = dr.pktpe_packtype and
            l.lov_name = 'PACKTYPES' and
	        dr.hazard is not null and
            c.customer_type = 'SUPPLIER' and
            c1.customer_type = 'CUSTOMER' and
            dr.movement_no = m.movement_no and
            dr.camov_seal = m.seal and
            m.ship_id = v_ship and
            m.movement_no = v_container and
            nvl(r.supplier_customer_id,0) = c.customer_id and
            nvl(r.cust_customer_id,0) = c1.customer_id
            order by c1.customer, c.customer, dr.deliveryno,dr.itemno);
            
cursor c2(v_container varchar2, v_seal varchar2) is 
select /*+ ALL_ROWS */ deliveryno
from (select c1.customer, c.customer, dr.deliveryno,dr.itemno
      from strang.detailrs dr,strang.receivals r, strang.movements m, strang.lov l,strang.customers c,strang.customers c1
      where r.deliveryno = dr.deliveryno and
      l.code = dr.pktpe_packtype and
      l.lov_name = 'PACKTYPES' and
	  dr.hazard is not null and
      c.customer_type = 'SUPPLIER' and
      c1.customer_type = 'CUSTOMER' and
      dr.movement_no = m.movement_no and
      dr.camov_seal = m.seal and
	  m.movement_type = 'CARGO' and
      nvl(m.seal,'|') =  NVL(v_seal,'|') and
      m.movement_no = v_container and
      nvl(r.supplier_customer_id,0) = c.customer_id and
      nvl(r.cust_customer_id,0) = c1.customer_id
order by c1.customer, c.customer, dr.deliveryno,dr.itemno);          
            

---- CONTAINER REPORTS.Intl Container Hazardous Report
--cursor c1(v_ship integer, v_container varchar2) is
-- select /*+ ALL_ROWS */ dr.deliveryno
-- from   strang.detailrs dr,strang.receivals r, strang.movements m, strang.lov l,strang.customers c,strang.customers c1
-- where  r.deliveryno = dr.deliveryno and
--        l.code = dr.pktpe_packtype and
--        l.lov_name = 'PACKTYPES' and
--        c.customer_type = 'SUPPLIER' and
--        c1.customer_type = 'CUSTOMER' and
--        dr.movement_no = m.movement_no and
--        dr.camov_seal = m.seal and
--        m.ship_id = v_ship and
--        m.movement_no = v_container and
--        nvl(r.supplier_customer_id,0) = c.customer_id and
--        nvl(r.cust_customer_id,0) = c1.customer_id
-- order  by c.customer, dr.deliveryno,dr.itemno
-- ;
 
-- CONTAINER REPORTS.Intl Container Invoice Check
--cursor c2 (v_ship integer, v_container varchar2, v_consolidate varchar2) is
-- select distinct deliveryno from
-- (
--   select /*+ ALL_ROWS */ c.customer, r.deliveryno, p.recno
--   from   strang.pos p,strang.receivals r, strang.customers c, strang.lov i, strang.lov t,strang.customers c1, strang.detailrs dr, strang.movements m, strang.ships_airway s
--   where  dr.movement_no = m.movement_no and
--          nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
--          m.ship_id = s.ship_id and
--          dr.deliveryno = p.deliveryno and
--          nvl(r.supplier_customer_id,0) = c.customer_id and
--          i.lov_name = 'INVENT' and
--          t.lov_name = 'TARIFF' and
--          c.customer_type = 'SUPPLIER' and
--          nvl(r.cust_customer_id,0) = c1.customer_id and
--          p.deliveryno = r.deliveryno and
--          nvl(p.inventoryno,'NOT ALLOCATED') = i.code and
--          nvl(i.cola,'NOT ALLOCATED') = t.code and
--          nvl(length(v_consolidate),0) = 0 and
--          m.ship_id = v_ship and
--          m.movement_no = v_container
--    union
--   select /*+ ALL_ROWS */ c.customer, r.deliveryno, p.recno
--   from   strang.pos p,strang.receivals r, strang.customers c,strang.customers c1, strang.detailrs dr, strang.movements m, strang.ships_airway s
--   where  dr.movement_no = m.movement_no and
--          nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
--          m.ship_id = s.ship_id and
--          dr.deliveryno = p.deliveryno and
--          nvl(r.supplier_customer_id,0) = c.customer_id and
--          c.customer_type = 'SUPPLIER' and
--          nvl(r.cust_customer_id,0) = c1.customer_id and
--          p.deliveryno = r.deliveryno and
--          p.inventoryno is not null and
--          p.inventoryno not in (select code from strang.lov where lov_name = 'INVENT')and
--          nvl(length(v_consolidate),0) = 0 and
--          m.ship_id = v_ship and
--          m.movement_no = v_container
--    union
--   select /*+ ALL_ROWS */ c.customer, r.deliveryno, p.recno
--   from   strang.pos p,strang.receivals r, strang.customers c,strang.customers c1, strang.detailrs dr, strang.movements m, strang.lov i, strang.ships_airway s
--   where  dr.movement_no = m.movement_no and
--          nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
--          m.ship_id = s.ship_id and
--          dr.deliveryno = p.deliveryno and
--          nvl(r.supplier_customer_id,0) = c.customer_id and
--          c.customer_type = 'SUPPLIER' and
--          nvl(r.cust_customer_id,0) = c1.customer_id and
--          p.deliveryno = r.deliveryno and
--          i.lov_name = 'INVENT' and
--          p.inventoryno = i.code and
--          i.cola not in (select code from strang.lov where lov_name='TARIFF')and
--          nvl(length(v_consolidate),0) = 0 and
--          m.ship_id = v_ship and
--          m.movement_no = v_container
--   order by 1, 2, 3
-- )
-- ;
--cursor c2a(v_ship integer, v_container varchar2) is
-- select colb consolidate
-- from   strang.lov l,strang.movements m
-- where  m.movement_no = v_container
--        and m.ship_id = v_ship
--        and l.lov_name = 'CTRTYPE'
--        and l.code = m.container_type
-- ;

-- SHIPPING REPORTS.Intl Summary Ship Manifest
--cursor c3(v_ship integer) is
--select distinct deliveryno
--from
--(
--  select dr.deliveryno, bol, container_type
--  from   strang.lov l1, strang.detailrs dr, strang.movements m, strang.receivals r
--  where  m.ship_id = v_ship and
--         nvl(dr.camov_seal (+),'x') = nvl(m.seal,'x') and
--         dr.movement_no (+) = m.movement_no and
--         dr.deliveryno = r.deliveryno (+) and
--         l1.lov_name = 'CTRTYPE' and
--         ((l1.code = m.container_type) or (l1.code = 'BREAK BULK' and m.container_type is null  and dr.movement_no = m.movement_no and nvl(dr.camov_seal,'x') = nvl(m.seal,'x'))) and
--  	     m.movement_no is not null
--  order  by bol, container_type
-- )
--;

-- New block of Code Added by David Banjo 20/5/2021
-- BREAKBULK REPORTS.Intl Breakbulk Manifest
--cursor c4(v_ship integer, v_consignment varchar2) is
-- select /*+ ALL_ROWS */ dr.deliveryno
-- from   strang.detailrs dr,strang.receivals r, strang.movements m, strang.lov l,strang.customers c,strang.customers c1
--where r.deliveryno = dr.deliveryno and
--      l.code = dr.pktpe_packtype and
--      l.lov_name = 'PACKTYPES' and
--      c.customer_type = 'SUPPLIER' and
--      c1.customer_type = 'CUSTOMER' and
--      dr.movement_no = m.movement_no  and
--      nvl(dr.camov_seal,'!') = nvl(m.seal,'!') and
--      m.ship_id = v_ship and
--      m.movement_no = v_consignment and
--      nvl(r.supplier_customer_id,0) = c.customer_id and
--      nvl(r.cust_customer_id,0) = c1.customer_id
--order by c.customer, dr.deliveryno,dr.itemno
-- ;

cursor cp is select * from report_api_parms;

umorec        umo%ROWTYPE;
d_umorec      umo%ROWTYPE;
d_umo         integer;
ship_id       integer;
container_no  varchar2(1000);
consignment_no varchar2(1000);
consolidate   varchar2(1000);
seal_no       varchar2(1000);
del_array     owa.vc_arr;
v_file        varchar2(1000);
v_url         varchar2(1000);
v_len         integer;

-- Start inline procedures
function create_pdf(v_array owa.vc_arr, v_umorec umo%ROWTYPE, vfile out varchar2, vurl out varchar2, len out integer) return integer is

c_pdf_tk      CONSTANT varchar2(100) := 'C:\Program Files (x86)\PDFtk Server\bin';
c_html_pdf    CONSTANT varchar2(100) := 'C:\Program Files\wkhtmltopdf\bin';
p_images      CONSTANT varchar2(100) := '\';
c_cmd_1       CONSTANT varchar2(1000) := 'wkhtmltopdf.exe -O Landscape -T 5mm -B 5mm -q "<source>" "<target>"';
c_cmd_2       CONSTANT varchar2(1000) := 'pdftk.exe';
c_max_pages   CONSTANT integer := 100; -- Break into chunks if too many invoices

dir_list      ump.directory_list_arr;
orig_report   varchar2(1000);
f             utl_file.file_type;
v_cmd         varchar2(32767);
work_file     varchar2(1000);
work_dir      varchar2(1000);
pdf_array     owa.vc_arr;
outp_array    owa.vc_arr;
ctr           integer;
n_umo         integer;
pdf_trgt_1    varchar2(1000);
pdf_trgt_2    varchar2(1000);
pdf_file      varchar2(1000);

begin

 orig_report := v_umorec.document_original_loc || decs.UNIX_OR_NT || 'report_' || umorec.umo_id || '.html';
 pdf_trgt_1 := v_umorec.document_original_loc || decs.UNIX_OR_NT || 'report_' || umorec.umo_id || '.pdf';
 work_dir := nvl(glbx.extract_master_parameter('WORK_DIRECTORY'), 'c:\temp');
 work_file := 'batch_' || v_umorec.umo_id || '.bat';
 -- pdf_ok := FALSE;
 pdf_array.delete;
 outp_array.delete;
 ctr := 0;
 f := utl_file.fopen(work_dir, work_file, 'w', 32700);
 -- f := glbx.fopen(work_dir, work_file, 'w', 32700);
 utl_file.put_line(f, '@echo off', TRUE);
 utl_file.put_line(f, 'set PATH=%PATH%;' || c_pdf_tk || ';' ||p_images||';'|| c_html_pdf, TRUE);
 v_cmd := replace(replace(c_cmd_1, '<source>', orig_report), '<target>', pdf_trgt_1);
 utl_file.put_line(f, v_cmd, TRUE);
 v_cmd := null;
 for j in v_array.first..v_array.last loop
  pdf_file := glbx.extract_master_parameter('STRANG_RECEIVALS_DIR') || decs.UNIX_OR_NT || v_array(j) || decs.UNIX_OR_NT || 'MO41' || decs.UNIX_OR_NT ||  v_array(j) || '_MO41.pdf';
  if file_exists(pdf_file, null)
   then
    ctr := ctr + 1;
    pdf_array(ctr) := pdf_file;
  end if;
--  pdf_file := glbx.extract_master_parameter('STRANG_RECEIVALS_DIR') || decs.UNIX_OR_NT || v_array(j) || decs.UNIX_OR_NT || 'MSDS' || decs.UNIX_OR_NT ||  v_array(j) || '_MSDS.pdf';
--  if file_exists(pdf_file, null)
--   then
--    ctr := ctr + 1;
--    pdf_array(ctr) := pdf_file;
--  end if;
  
  
 end loop;

 if pdf_array.count > 0
  then
   select s_umo.nextval into n_umo from dual;
   -- glbx.dbg('umo: ' || n_umo);
   pdf_trgt_2 := glbx.extract_master_parameter('STRANG_RECEIVALS_DIR') || decs.UNIX_OR_NT  || 'reports' || decs.UNIX_OR_NT || 'report_' || n_umo || '.pdf';

   v_cmd := c_cmd_2 || ' "' || pdf_trgt_1 || '" ';
   utl_file.put(f, v_cmd);
   if pdf_array.count > c_max_pages
    then
	 ctr := 0;
	 for j in pdf_array.first..pdf_array.last loop
      utl_file.put(f, '"' || pdf_array(j) || '" ');
      if mod(j, c_max_pages) = 0
       then
        ctr := ctr + 1;
        outp_array(ctr) := glbx.extract_master_parameter('STRANG_RECEIVALS_DIR') || decs.UNIX_OR_NT  || 'reports' || decs.UNIX_OR_NT || 'report_' || n_umo || '_chunk_' || ctr || '.pdf';
        utl_file.put_line(f, ' output "' || outp_array(ctr) || '"', TRUE);
        if j <> pdf_array.last
         then
          v_cmd := c_cmd_2 || ' ';
          utl_file.put(f, v_cmd);
        end if;
      end if;
     end loop;
     ctr := ctr + 1;
     outp_array(ctr) := glbx.extract_master_parameter('STRANG_RECEIVALS_DIR') || decs.UNIX_OR_NT  || 'reports' || decs.UNIX_OR_NT || 'report_' || n_umo || '_chunk_' || ctr || '.pdf';
     utl_file.put_line(f, ' output "' || outp_array(ctr) || '"', TRUE);
     if outp_array.count > 0
      then
       v_cmd := c_cmd_2;
       utl_file.put(f, v_cmd);
       for j in outp_array.first..outp_array.last loop
        utl_file.put(f, ' "' || outp_array(j) || '"');
       end loop;
     end if;
   else
    for j in pdf_array.first..pdf_array.last loop
     utl_file.put(f, '"' || pdf_array(j) || '" ');
    end loop;
   end if;
   utl_file.put_line(f, ' output "' || pdf_trgt_2 || '"', TRUE);
   utl_file.put_line(f, 'del "' || pdf_trgt_1 || '"', TRUE);  -- put back
   if outp_array.count > 0
    then
     for j in outp_array.first..outp_array.last loop
      utl_file.put_line(f, 'del "' || outp_array(j) || '"'); -- put back
     end loop;
   end if;
   utl_file.put_line(f, 'exit', TRUE);

   utl_file.fclose(f);
   begin utl_os.OsCmdDirectWait(work_dir || decs.UNIX_OR_NT || work_file); exception when others then null; end;
   if utl_os.delete_file(work_dir || decs.UNIX_OR_NT || work_file) then null;  end if; --put back

   if os_command.directory_listing(pdf_trgt_2, dir_list)
    then
     if dir_list.count > 0
      then
       for j in dir_list.first..dir_list.last loop
        if upper(dir_list(j).fullpath) = upper(pdf_trgt_2)
         then
          len := dir_list(j).filesize;
          vfile := pdf_trgt_2;
          vurl := glbx.extract_master_parameter('APACHE_RECEIVALS_DIR') || '/reports/' || glbx.extract_fname(vfile, 'FILE');
          exit;
        end if;
       end loop;
     end if;
   else
     len := 0;
   end if;

 else
   -- glbx.dbg('No attachments: ' || v_umorec.extras.photo_name);
   len := 0;
   n_umo := null;
 end if;

 return(n_umo);
exception when others
 then
  len := 0;
  begin utl_file.fclose(f); exception when others then null; end;
  glbx.dbg('Error creating file: ' || sqlerrm);
  return(null);
end create_pdf;
-- End inline procedures

begin
 for cp_rec in cp loop
  case upper(cp_rec.parm1)
  when 'SHIP_ID' then ship_id := glbx.guess_number(cp_rec.parm2);
  when 'CONTAINER NO' then container_no := cp_rec.parm2;
  when 'CONSIGNMENT NOTE' then consignment_no := cp_rec.parm2; -- added by David Banjo 20/5/2021
  when 'CONSOLIDATE' then consolidate := cp_rec.parm2;
  when 'SEAL NO' then seal_no := cp_rec.parm2;
  else null;
  end case;
 end loop;
 if v_umo is not null then
  open cu(v_umo);
  fetch cu into umorec;
  if cu%NOTFOUND
   then
    close cu;
    return;
  end if;
  close cu;
  del_array.delete;
  case  
  when upper(umorec.extras.photo_name) like 'INTL CONTAINER HAZARDOUS%:%'
   then
    open c1(ship_id, container_no);
    fetch c1 BULK COLLECT into del_array;
    close c1;
  when upper(umorec.extras.photo_name) like 'CONTAINER (EXCL. SHIP) HAZARDOUS%:%'
   then
    open c2(container_no, seal_no);
    fetch c2 BULK COLLECT into del_array;
    close c2;
--  when upper(umorec.extras.photo_name) like 'INTL CONTAINER MANIFEST%:%'
--   then
--    open c1(ship_id, container_no);
--    fetch c1 BULK COLLECT into del_array;
--    close c1;
--  when upper(umorec.extras.photo_name) like 'INTL CONTAINER INVOICE CHECK%:%'
--   then
--    open c2a(ship_id, container_no);
--    fetch c2a into consolidate;
--    close c2a;
--    open c2(ship_id, container_no, consolidate);
--    fetch c2 BULK COLLECT into del_array;
--    close c2;
--  when upper(umorec.extras.photo_name) like 'INTL SUMMARY SHIP MANIFEST%:%'
--   then
--    open c3(ship_id);
--    fetch c3 BULK COLLECT into del_array;
--    close c3;
-- when upper(umorec.extras.photo_name) like 'INTL BREAK BULK MANIFEST%:%'
--   then
--    open c4(ship_id, consignment_no);
--    fetch c4 BULK COLLECT into del_array;
--    close c4;
  else null;
  end case;
 else
  return;
 end if;
 -- glbx.dbg('Report = ' || umorec.extras.photo_name);

 if del_array.count > 0
  then
   d_umo := create_pdf(del_array, umorec, v_file, v_url, v_len);
 end if;
 if d_umo is not null
  then
   insert into umo(umo_id
                  ,aid
                  ,umo_type
                  ,umo_owner
                  ,umo_scene_id
                  ,version
                  ,extras
                  ,doc_html
                  ,date_created
                  ,expire_date
                  ,report_id
                  ,object_class
                  ,ftp_location
                  ,document_original_loc)
    values        (d_umo
                  ,umorec.aid
                  ,'REPORT'
                  ,'OWNER'
                  ,umorec.umo_scene_id
                  ,1
                  ,repeated_fields(v_len,null,null,umorec.extras.title,null,umorec.extras.photo_name || ' + Documents',null,umorec.extras.enabled_phg,'FALSE')
                  ,empty_clob()
                  ,umorec.date_created-(1/86400)
                  ,umorec.expire_date-(1/86400)
                  ,umorec.report_id
                  ,'HTTP'
                  ,v_url
                  ,v_file);
   commit;
 end if;

exception when others
 then
  glbx.dbg('convert_hazardous_docs error: ' || sqlerrm);
end convert_hazardous_docs;
/
