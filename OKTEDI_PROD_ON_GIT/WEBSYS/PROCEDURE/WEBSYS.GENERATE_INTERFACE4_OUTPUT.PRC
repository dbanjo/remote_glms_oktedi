CREATE OR REPLACE procedure WEBSYS.generate_interface4_output( surl in varchar2, vtoday in date, is_batch in varchar2 default 'FALSE' )
as

-- FILTERED OUT INCOMPLETE packing status

 cursor c1 is
 select ir.po as "Purchase Order"
      , ir.po_item_no as "PO Item No"
      , ir.grn as "GRN"
      , ir.grn_item as "GRN Item"
      , ir.deliveryno as "Delivery No"
      , ir.recno as "PO Rno"
      , ir.packing_status as "Packing Status"
      , ir.urgency as "Priority"
      , ir.movement_type as "Movement Type"
      , ir.movement_no as "Container"
      , ir.seal as "Seal"
      , case when ir.io = 'I' then 'INBOUND' else 'OUTBOUND' end as "Direction"
      , ir.full_mt as "Full Or Empty"
      , replace(ir.consignee, '"','') as "Consignee"
      , replace(strang.f_getlovColumn('LOCATIONS','DESCRIPTION', ir.consignee_location), '"', '') as "Consignee Location"
      , ir.warehouse_destination as "Warehouse Destination"
      , replace(strang.f_getlovColumn('LOCATIONS','DESCRIPTION', ir.current_location), '"','')  as "Current Location"
      , ir.customs_cleared_date as "Customs Cleared Date"
      , ir.local_bol as "Local BOL"
      , ir.bol as "Intl BOL"
      , replace(ir.shipname, '"','') as "Intl Ship Name"
      , ir.voy as "Intl Voyage"
      , ir.estarrive as "Intl Est Arrival Date"
      , replace(ir.shipname_local,'"','') as "Local Ship Name"
      , ir.voy_local as "Local Voyage"
      , ir.local_estarrive as "Local Est Arrival Date"
      , replace(ir.convoyname, '"', '') as "Convoy Name"
      , replace(ir.convoy_type, '"', '') as "Convoy Type"
      , ir.convoy_estdepart as "Convoy Depart Date"
      , ir.hawb_hawbno as "Hawb Intl"
      , ir.hawb_hawbno_2 as "Hawb Local"
      , to_Char(ir.post_date,'DD/MM/YY HH24:MI:SS') as "Post Date"
 from websys.interface4_records ir
where trunc(post_date) = trunc(sysdate - 1)  
 and NVL(ir.packing_status, 'XXXX') != 'INCOMPLETE'
order by 1, 3, 4, 6;
 
 cursor c2 is
   select count('x') tot
   from
   ( select ir.po as "Purchase Order"
          , ir.po_item_no as "PO Item No"
          , ir.grn as "GRN"
          , ir.grn_item as "GRN Item"
          , ir.deliveryno as "Delivery No"
      from websys.interface4_records ir
      where trunc(post_date) = trunc(sysdate - 1)
       and NVL(ir.packing_status, 'XXXX') != 'INCOMPLETE');

  cursor c3(vtoday date) is select to_char(sysdate) v1date from dual;

  c1rec       customer_account%ROWTYPE;
  c3rec       c3%ROWTYPE;
  f           utl_file.file_type;
  f2           utl_file.file_type;
  tot         integer;
  gcode       GLBX.MYARRAY;
  gparam      GLBX.MYARRAY;
  vste        varchar2(10);
  eml         varchar2(100);
  ltype       varchar2(100);
  stype       integer;
  owner_id    integer;
  sts         varchar2(100);
  ctr         integer;
  ctr1         integer;
 -- f_dir       CONSTANT varchar2(1000) := glbx.extract_master_parameter('MAIL_OUTPUT_DIR');
 f_dir      CONSTANT varchar2(1000) := glbx.extract_master_parameter('MAIL_TEMPLATE_DIR');
 -- f_file      CONSTANT varchar2(1000) := 'OST185_' || to_char(sysdate, 'dd_mon_yyyy_hh24mi') || '.csv';
 f_file      CONSTANT varchar2(1000) := 'INTERFACE4_EXTRACT_' || to_char(sysdate, 'dd_mon_yyyy_hh24mi') || '.txt';
 f_file2      CONSTANT varchar2(1000) := 'GENERATE_INTERFACE4_EXTRACT' || to_char(sysdate, 'dd_mon_yyyy_hh24mi') || '.csv';  -- email extract

function control_code( cd in varchar2, vste in varchar2 )
 return varchar2
as

 cursor c1( cd varchar2, vste varchar2 ) is select description from strang.lov where lov_name = 'CONTROLS' and code = cd and cola = vste;

 c1rec	c1%ROWTYPE;

begin
 open c1( cd, vste );
 fetch c1 into c1rec;
 close c1;
 return( c1rec.description );
exception
 when others
  then return( NULL );
end control_code;


begin
 if nvl(is_batch, 'FALSE') = 'TRUE'
  then
   sts := null;
   vste := 'SYD';
 else
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.GENERATE_INTERFACE4_OUTPUT' );
   c1rec := glbx.get_aid( owner_id, 'C', ltype );
   vste := invoice_parser.customer_state(c1rec.aid);
 end if;

 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 eml := control_code( 'OST185_EMAIL_ADDRESS', vste );
 eml := nvl( eml, glbx.extract_master_parameter('MAIL_FROM') );

 open c2;
 fetch c2 into tot;
 close c2;
 open c3(vtoday);
 fetch c3 into c3rec;
 close c3;
 -- f := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), 'OST185_' || to_char(sysdate, 'dd_mon_yyyy_hh24mi') || '.csv', 'w', 32767);
 f := utl_file.fopen( f_dir, f_file, 'w', 32767);
                         
                                
  utl_file.put_line(f, buffer=>'"Purchase Order","PO Item No","GRN","GRN Item","Delivery No","PO Rno","Packing Status","Priority","Movement Type","Container","Seal","Direction","Full Or Empty","'||
                               'Consignee","Consignee Location","Warehouse Destination","Current Location","Customs Cleared Date","Local BOL","Intl BOL","Intl Ship Name","Intl Voyage","Intl Est Arrival Date","'||
                               'Local Ship Name","Local Voyage","Local Est Arrival Date","Convoy Name","Convoy Type","'||
                               'Convoy Depart Date","Hawb Intl","Hawb Local","Post Date"');             

 ctr := 0;
 for c1rec in c1 loop
  
  utl_file.put_line(f, buffer=>'"'||c1rec."Purchase Order"||'","'||c1rec."PO Item No"||'","'||c1rec."GRN" ||'","'|| c1rec."GRN Item" || '","' || c1rec."Delivery No"||'","'
                        || c1rec."PO Rno"||'","'||c1rec."Packing Status"||'","'||c1rec."Priority"||'","'||c1rec."Movement Type"||'","'||c1rec."Container"||'","'||c1rec."Seal"|| '","'
                        || c1rec."Direction" ||'","'||c1rec."Full Or Empty"||'","'||c1rec."Consignee"||'","'||c1rec."Consignee Location"||'","'||c1rec."Warehouse Destination"||'","'||c1rec."Current Location"||'","'
                        || c1rec."Customs Cleared Date"||'","'|| c1rec."Local BOL"||'","'||c1rec."Intl BOL"||'","'||c1rec."Intl Ship Name"||'","'||c1rec."Intl Voyage"||'","'||c1rec."Intl Est Arrival Date"||'","'||c1rec."Local Ship Name"||'","'
                        || c1rec."Local Voyage"||'","'||c1rec."Local Est Arrival Date"||'","'||c1rec."Convoy Name"||'","'||c1rec."Convoy Type"||'","'
                        || c1rec."Convoy Depart Date"||'","'||c1rec."Hawb Intl"||'","'||c1rec."Hawb Local"||'","'
                        || c1rec."Post Date"||'"'
                        );
                      
                        
                        
-- ****** TURNED OFF 20180530 *********  update strang.pos set off_site_receipt = sysdate where rowid = c1rec.rowid;
--  update strang.pos set po_waybill_type = c1rec.po_waybill_type where rowid = c1rec.rowid;
--  update strang.pos set qty = c1rec.partweight where unit_unitused in ('BAGS','BAG') and rowid = c1rec.rowid;
--  update strang.pos set unit_unitused = 'KG' where unit_unitused in ('BAGS','BAG') and rowid = c1rec.rowid;

  ctr := ctr + 1;
 end loop;
 -- Output Header
 utl_file.put_line(f, buffer=>'F,' || to_char(sysdate,'DD.MM.YYYY') || ',' || tot  );
 utl_file.fclose( f );
 
 
 ------ CREATE EXTRACT ---------------------------------------------------------
  f2 := utl_file.fopen( f_dir, f_file2, 'w', 32767);  -- 
  utl_file.put_line(f2, buffer=>'H,' || to_char(sysdate,'DD.MM.YYYY') || ',' || tot );
                                          
  utl_file.put_line(f2, buffer=>'"Purchase Order","PO Item No","GRN","GRN Item","Delivery No","PO Rno","Packing Status","Priority","Movement Type","Container","Seal","Direction","Full Or Empty","'||
                               'Consignee","Consignee Location","Warehouse Destination","Current Location","Customs Cleared Date","Local BOL","Intl BOL","Intl Ship Name","Intl Voyage","Intl Est Arrival Date","'||
                               'Local Ship Name","Local Voyage","Local Est Arrival Date","Convoy Name","Convoy Type","'||
                               'Convoy Depart Date","Hawb Intl","Hawb Local","Post Date"');                                    
                                   

  ctr1 := 0;
  for c1rec in c1 loop
  
  
   utl_file.put_line(f2, buffer=>'"'||c1rec."Purchase Order"||'","'||c1rec."PO Item No"||'","'||c1rec."GRN" ||'","'|| c1rec."GRN Item" || '","' || c1rec."Delivery No"||'","'
                        || c1rec."PO Rno"||'","'||c1rec."Packing Status"||'","'||c1rec."Priority"||'","'||c1rec."Movement Type"||'","'||c1rec."Container"||'","'||c1rec."Seal"|| '","'
                        || c1rec."Direction" ||'","'||c1rec."Full Or Empty"||'","'||c1rec."Consignee"||'","'||c1rec."Consignee Location"||'","'||c1rec."Warehouse Destination"||'","'||c1rec."Current Location"||'","'
                        || c1rec."Customs Cleared Date"||'","'|| c1rec."Local BOL"||'","'||c1rec."Intl BOL"||'","'||c1rec."Intl Ship Name"||'","'||c1rec."Intl Voyage"||'","'||c1rec."Intl Est Arrival Date"||'","'||c1rec."Local Ship Name"||'","'
                        || c1rec."Local Voyage"||'","'||c1rec."Local Est Arrival Date"||'","'||c1rec."Convoy Name"||'","'||c1rec."Convoy Type"||'","'
                        || c1rec."Convoy Depart Date"||'","'||c1rec."Hawb Intl"||'","'||c1rec."Hawb Local"||'","'
                        || c1rec."Post Date"||'"'
                        );         
   
-- ****** TURNED OFF 20180530 *********  update strang.pos set off_site_receipt = sysdate where rowid = c1rec.rowid;
--  update strang.pos set po_waybill_type = c1rec.po_waybill_type where rowid = c1rec.rowid;
--  update strang.pos set qty = c1rec.partweight where unit_unitused in ('BAGS','BAG') and rowid = c1rec.rowid;
--  update strang.pos set unit_unitused = 'KG' where unit_unitused in ('BAGS','BAG') and rowid = c1rec.rowid;

    ctr1 := ctr1 + 1;
    if ctr1 > 11 then
       exit;
    end if;
   
   end loop;
   utl_file.put_line(f2, buffer=>'F,' || to_char(sysdate,'DD.MM.YYYY') || ',' || tot  );
   utl_file.fclose( f2 );


-------------------------------------------------------------------------------
 gcode(1) := 'XXXX'; -- Dummy Parameter
 gparam(1) := 'XXXX';

 if ctr > 0
  then
   -- glbx.send( gcode, gparam, 'OST185_' || to_char(sysdate, 'dd_mon_yyyy_hh24mi') || '.csv', p_to=>eml, p_subj=>'OST185_' || c3rec.v1date || '_' || to_char(sysdate, 'hh24mi'), p_from=>glbx.extract_master_parameter('MAIL_FROM'),is_attachment=>TRUE);
  -- glbx.send( gcode, gparam, f_file, p_to=>eml, p_subj=>'OST185_' || c3rec.v1date || '_' || to_char(sysdate, 'hh24mi'), p_from=>glbx.extract_master_parameter('MAIL_FROM'),is_attachment=>TRUE 
   glbx.send( gcode, gparam, f_file2, p_to=>eml, p_subj=>'GENERATE_INTERFACE4_EXTRACT_' || c3rec.v1date || '_' || to_char(sysdate, 'hh24mi'), p_from=>glbx.extract_master_parameter('MAIL_FROM'),is_attachment=>TRUE);
   ftp_ost_185(f_dir || '\' || f_file, 'SFTP');
 else
   begin
    -- utl_file.fremove(glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), 'OST185_' || to_char(sysdate, 'dd_mon_yyyy_hh24mi') || '.csv');
    utl_file.fremove(f_dir, f_file);
   exception when others then null;
   end;
 end if;

exception when others then
 glbx.error_details( 'STRANGP', 'GENERATE_INTERFACE4_OUTPUT',null,null,errmsg=>sqlerrm);
end generate_interface4_output;
/
