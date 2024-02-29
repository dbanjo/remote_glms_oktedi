CREATE OR REPLACE procedure WEBSYS.generate_shipped_pos( surl in varchar2, vtoday in date, is_batch in varchar2 default 'FALSE' )
as
-- another test comment.
 cursor c1 is
  select p.po as "Purchase Order"
       , p.po_item_no as "PO Item No"
       , p.grn as "GRN"
       , p.grn_item as "GRN Item"
       , p.deliveryno as "Delivery No"
       , p.recno as "PO Rno"
       , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION', m.complete) "Packing Status"
       , m.urgency  as "Priority"
       , m.movement_type as "Movement Type"
       , m.movement_no as "Container"
       , m.seal as "Seal"
       , case when m.io = 'I' then 'INBOUND' else 'OUTBOUND' end as "Direction"
       , m.full_mt as "Full Or Empty"
-------------------------------------------------------------------------------------           
       , m.consignee as "Consignee"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.consignee_location) as "Consignee Location"
       , m.warehouse_destination as "Warehouse Destination"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.current_location)  as "Current Location"
       , m.customs_cleared_date as "Customs Cleared Date"
       , m.local_bol as "Local BOL"
       , m.bol as "Intl BOL"
 -------------------------------------------------------------------------------------        
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE')  as "Intl Voyage"
       , case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl Est Arrival Date"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local Est Arrival Date"
       , (select s3.convoyname from strang.convoy s3 where s3.convoy_id = m.convoy_id) as "Convoy Name"
       , (select s3.convoy_type from strang.convoy s3 where s3.convoy_id  = m.convoy_id) as "Convoy Type"
	   , (select s3.estdepart from strang.convoy s3 where s3.convoy_id  = m.convoy_id ) as "Convoy Depart Date"
 -------------------------------------------------------------------------------
       , dr.hawb_hawbno as "Hawb Intl"
       , dr.hawb_hawbno_2 as "Hawb Local"
       , to_Char(sysdate,'DD/MM/YY HH24:MI:SS') as "Post Date"  
       , case when m.urgency = 'VMR' THEN strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'VMR_INVENTORYNO') else null end "Material Number"
       , strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'DESCRIPTION') "Description"
   from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r
      , strang.customers c
  where p.deliveryno = dr.deliveryno and 
        p.deliveryno = r.deliveryno and 
        r.currdate >  sysdate - 720 and 
     --   substr(p.po,1,2) in ('47','43','45') and
        r.cust_customer_id in (1,9005960,576,596,575,9002717) and 
        dr.io = 'I' and 
        dr.movement_no = m.movement_no and
        nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
        nvl(m.complete,'S') NOT IN ('H','J','F') and
    --    nvl(m.complete,'S') NOT IN ('H','J','D') and
       -- nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
        m.io='I' and 
        m.movement_no <> 'OTMU1234567' and 
        m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'TABUBIL') and 
        nvl(r.supplier_customer_id,0) = c.customer_id and 
     --   NVL(m.complete, 'XXXX') != 'INCOMPLETE' and
        c.customer_type = 'SUPPLIER' and 
        exists (select 1
                  from strang.detailrs dr2
                 where dr.movement_no is not null
                   and dr2.deliveryno = dr.deliveryno
                   and dr2.itemno  = dr.itemno)            
union all  -- 2 
select p.po as "Purchase Order"
       , p.po_item_no as "PO Item No"
       , p.grn as "GRN"
       , p.grn_item as "GRN Item"
       , p.deliveryno as "Delivery No"
       , p.recno as "PO Rno"
       , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION', m.complete) packing_status
       , m.urgency  as "Priority"
       , m.movement_type as "Movement Type"
       , m.movement_no as "Container"
       , m.seal as "Seal"
       , case when m.io = 'I' then 'INBOUND' else 'OUTBOUND' end as "Direction"
       , m.full_mt as "Full Or Empty"
-------------------------------------------------------------------------------------           
       , m.consignee as "Consignee"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.consignee_location) as "Consignee Location"
       , m.warehouse_destination as "Warehouse Destination"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.current_location)  as "Current Location"
       , m.customs_cleared_date as "Customs Cleared Date"
       , m.local_bol as "Local BOL"
       , m.bol as "Intl BOL"
 -------------------------------------------------------------------------------------        
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE')  as "Intl Voyage"
       , case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl Est Arrival Date"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local Est Arrival Date"
       , (select s3.convoyname from strang.convoy s3 where s3.convoy_id = m.convoy_id) as "Convoy Name"
       , (select s3.convoy_type from strang.convoy s3 where s3.convoy_id  = m.convoy_id) as "Convoy Type"
	   , (select s3.estdepart from strang.convoy s3 where s3.convoy_id  = m.convoy_id ) as "Convoy Depart Date"
 -------------------------------------------------------------------------------
       , dr.hawb_hawbno as "Hawb Intl"
       , dr.hawb_hawbno_2 as "Hawb Local"
       , to_Char(sysdate,'DD/MM/YY HH24:MI:SS') as "Post Date"  
       , case when m.urgency = 'VMR' THEN strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'VMR_INVENTORYNO') else null end "Material Number"
       , strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'DESCRIPTION') "Description"
 from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
where p.deliveryno = dr.deliveryno and 
p.deliveryno = r.deliveryno and 
--substr(p.po,1,2) in ('47','43','45') and
r.cust_customer_id in (1,9005960,576,596,575,9002717) and 
dr.io = 'I' and 
dr.movement_no = m.movement_no and
nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
nvl(m.complete,'S') NOT IN ('H','J','F') and
--nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
m.io='I' and 
m.movement_no <> 'OTMU1234567' and 
m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and 
nvl(r.supplier_customer_id,0) = c.customer_id and 
r.currdate >  sysdate - 720 and 
--NVL(m.complete, 'XXXX') != 'INCOMPLETE' and
c.customer_type = 'SUPPLIER' and 
 exists (select 1
             from  strang.detailrs dr2
            where  dr.movement_no is not null
             and   dr2.deliveryno = dr.deliveryno
             and   dr2.itemno  = dr.itemno) 
UNION ALL  -- 3
select p.po as "Purchase Order"
       , p.po_item_no as "PO Item No"
       , p.grn as "GRN"
       , p.grn_item as "GRN Item"
       , p.deliveryno as "Delivery No"
       , p.recno as "PO Rno"
       , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION', m.complete) packing_status
       , m.urgency  as "Priority"
       , m.movement_type as "Movement Type"
       , m.movement_no as "Container"
       , m.seal as "Seal"
       , case when m.io = 'I' then 'INBOUND' else 'OUTBOUND' end as "Direction"
       , m.full_mt as "Full Or Empty"
-------------------------------------------------------------------------------------           
       , m.consignee as "Consignee"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.consignee_location) as "Consignee Location"
       , m.warehouse_destination as "Warehouse Destination"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.current_location)  as "Current Location"
       , m.customs_cleared_date as "Customs Cleared Date"
       , m.local_bol as "Local BOL"
       , m.bol as "Intl BOL"     
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE')  as "Intl Voyage"
       , case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl Est Arrival Date"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local Est Arrival Date"
       , (select s3.convoyname from strang.convoy s3 where s3.convoy_id = m.convoy_id) as "Convoy Name"
       , (select s3.convoy_type from strang.convoy s3 where s3.convoy_id  = m.convoy_id) as "Convoy Type"
	   , (select s3.estdepart from strang.convoy s3 where s3.convoy_id  = m.convoy_id ) as "Convoy Depart Date"
       , dr.hawb_hawbno as "Hawb Intl"
       , dr.hawb_hawbno_2 as "Hawb Local"
       , to_Char(sysdate,'DD/MM/YY HH24:MI:SS') as "Post Date"  
       , case when m.urgency = 'VMR' THEN strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'VMR_INVENTORYNO') else null end "Material Number"
       , strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'DESCRIPTION') "Description"
 from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
where p.deliveryno = dr.deliveryno and 
--substr(p.po,1,2) in ('47','43','45') and
p.deliveryno = r.deliveryno and 
r.cust_customer_id in (1,9005960,576,596,575,9002717) and 
dr.io = 'I' and 
dr.movement_no = m.movement_no and
nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
nvl(m.complete,'S') NOT IN ('H','J','F') and
--nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
m.io='I' and 
m.movement_no <> 'OTMU1234567' and 
m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and 
--(dr.DELIVERYNO between 1000000 and 1999999 or
--dr.DELIVERYNO between 9000000 and 9999999 ) and
--p.grn_status in (1,8,9) and 
nvl(r.supplier_customer_id,0) = c.customer_id and 
r.currdate >  sysdate - 720 and 
--NVL(m.complete, 'XXXX') != 'INCOMPLETE' and
c.customer_type = 'SUPPLIER' and 
 exists (select 1
             from  strang.detailrs dr2
            where  dr.movement_no is not null
             and   dr2.deliveryno = dr.deliveryno
             and   dr2.itemno  = dr.itemno)     
union ALL -- 4
select p.po as "Purchase Order"
       , p.po_item_no as "PO Item No"
       , p.grn as "GRN"
       , p.grn_item as "GRN Item"
       , p.deliveryno as "Delivery No"
       , p.recno as "PO Rno"
       , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION', m.complete) packing_status
       , m.urgency  as "Priority"
       , m.movement_type as "Movement Type"
       , m.movement_no as "Container"
       , m.seal as "Seal"
       , case when m.io = 'I' then 'INBOUND' else 'OUTBOUND' end as "Direction"
       , m.full_mt as "Full Or Empty"
-------------------------------------------------------------------------------------           
       , m.consignee as "Consignee"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.consignee_location) as "Consignee Location"
       , m.warehouse_destination as "Warehouse Destination"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.current_location)  as "Current Location"
       , m.customs_cleared_date as "Customs Cleared Date"
       , m.local_bol as "Local BOL"
       , m.bol as "Intl BOL"   
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE')  as "Intl Voyage"
       , case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl Est Arrival Date"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local Est Arrival Date"
       , (select s3.convoyname from strang.convoy s3 where s3.convoy_id = m.convoy_id) as "Convoy Name"
       , (select s3.convoy_type from strang.convoy s3 where s3.convoy_id  = m.convoy_id) as "Convoy Type"
	   , (select s3.estdepart from strang.convoy s3 where s3.convoy_id  = m.convoy_id ) as "Convoy Depart Date"
       , dr.hawb_hawbno as "Hawb Intl"
       , dr.hawb_hawbno_2 as "Hawb Local"
       , to_Char(sysdate,'DD/MM/YY HH24:MI:SS') as "Post Date"  
       , case when m.urgency = 'VMR' THEN strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'VMR_INVENTORYNO') else null end "Material Number"
       , strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'DESCRIPTION') "Description"
 from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
where p.deliveryno = dr.deliveryno and 
p.deliveryno = r.deliveryno and 
--substr(p.po,1,2) in ('47','43','45') and
r.cust_customer_id in (1,9005960,576,596,575,9002717) and 
dr.io = 'I' and 
dr.movement_no = m.movement_no and
nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
nvl(m.complete,'S') NOT IN ('H','J','F') and
--nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
m.io='I' and 
m.movement_no <> 'OTMU1234567' and 
m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'BRISBANE') and 
--(dr.DELIVERYNO between 1000000 and 1999999 or
--dr.DELIVERYNO between 9000000 and 9999999 ) and
--p.grn_status in (1,8,9) and 
nvl(r.supplier_customer_id,0) = c.customer_id and 
r.currdate >  sysdate - 720 and 
--NVL(m.complete, 'XXXX') != 'INCOMPLETE' and
c.customer_type = 'SUPPLIER' and 
 exists (select 1
             from  strang.detailrs dr2
            where  dr.movement_no is not null
             and   dr2.deliveryno = dr.deliveryno
             and   dr2.itemno  = dr.itemno)          
union ALL  -- 5
select p.po as "Purchase Order"
       , p.po_item_no as "PO Item No"
       , p.grn as "GRN"
       , p.grn_item as "GRN Item"
       , p.deliveryno as "Delivery No"
       , p.recno as "PO Rno"
       , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION', m.complete) packing_status
       , m.urgency  as "Priority"
       , m.movement_type as "Movement Type"
       , m.movement_no as "Container"
       , m.seal as "Seal"
       , case when m.io = 'I' then 'INBOUND' else 'OUTBOUND' end as "Direction"
       , m.full_mt as "Full Or Empty"
-------------------------------------------------------------------------------------           
       , m.consignee as "Consignee"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.consignee_location) as "Consignee Location"
       , m.warehouse_destination as "Warehouse Destination"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.current_location)  as "Current Location"
       , m.customs_cleared_date as "Customs Cleared Date"
       , m.local_bol as "Local BOL"
       , m.bol as "Intl BOL"
 -------------------------------------------------------------------------------------        
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE')  as "Intl Voyage"
       , case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl Est Arrival Date"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local Est Arrival Date"
       , (select s3.convoyname from strang.convoy s3 where s3.convoy_id = m.convoy_id) as "Convoy Name"
       , (select s3.convoy_type from strang.convoy s3 where s3.convoy_id  = m.convoy_id) as "Convoy Type"
	   , (select s3.estdepart from strang.convoy s3 where s3.convoy_id  = m.convoy_id ) as "Convoy Depart Date"
 -------------------------------------------------------------------------------
       , dr.hawb_hawbno as "Hawb Intl"
       , dr.hawb_hawbno_2 as "Hawb Local"
       , to_Char(sysdate,'DD/MM/YY HH24:MI:SS') as "Post Date"  
       , case when m.urgency = 'VMR' THEN strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'VMR_INVENTORYNO') else null end "Material Number"
       , strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'DESCRIPTION') "Description"
from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
where p.deliveryno = dr.deliveryno and 
p.deliveryno = r.deliveryno and 
--substr(p.po,1,2) in ('47','43','45') and
r.cust_customer_id in (1,9005960,576,596,575,9002717) and 
dr.io = 'I' and 
dr.movement_no = m.movement_no and
nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
nvl(m.complete,'S') NOT IN ('H','J','F') and
 m.movement_no <> 'OTMU1234567' and 
--nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
m.io='I' and (
m.current_location is null or
m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc not in ( 'BRISBANE', 'MOTUKEA', 'KIUNGA','TABUBIL')) ) and 
--(dr.DELIVERYNO between 1000000 and 1999999 or
--dr.DELIVERYNO between 9000000 and 9999999 ) and
--p.grn_status in (1,8,9) and 
nvl(r.supplier_customer_id,0) = c.customer_id and 
r.currdate >  sysdate - 720 and 
--NVL(m.complete, 'XXXX') != 'INCOMPLETE' and
c.customer_type = 'SUPPLIER' and 
 exists (select 1
             from  strang.detailrs dr2
            where  dr.movement_no is not null
             and   dr2.deliveryno = dr.deliveryno
             and   dr2.itemno  = dr.itemno)
 order by 1, 3, 4, 6;
 

 cursor c2 is
   select count('x') tot
   from
   (     select p.po as "Purchase Order"
       , p.po_item_no as "PO Item No"
       , p.grn as "GRN"
       , p.grn_item as "GRN Item"
       , p.deliveryno as "Delivery No"
       , p.recno as "PO Rno"
       , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION', m.complete) "Packing Status"
       , m.urgency  as "Priority"
       , m.movement_type as "Movement Type"
       , m.movement_no as "Container"
       , m.seal as "Seal"
       , case when m.io = 'I' then 'INBOUND' else 'OUTBOUND' end as "Direction"
       , m.full_mt as "Full Or Empty"
-------------------------------------------------------------------------------------           
       , m.consignee as "Consignee"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.consignee_location) as "Consignee Location"
       , m.warehouse_destination as "Warehouse Destination"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.current_location)  as "Current Location"
       , m.customs_cleared_date as "Customs Cleared Date"
       , m.local_bol as "Local BOL"
       , m.bol as "Intl BOL"
 -------------------------------------------------------------------------------------        
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE')  as "Intl Voyage"
       , case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl Est Arrival Date"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local Est Arrival Date"
       , (select s3.convoyname from strang.convoy s3 where s3.convoy_id = m.convoy_id) as "Convoy Name"
       , (select s3.convoy_type from strang.convoy s3 where s3.convoy_id  = m.convoy_id) as "Convoy Type"
	   , (select s3.estdepart from strang.convoy s3 where s3.convoy_id  = m.convoy_id ) as "Convoy Depart Date"
 -------------------------------------------------------------------------------
       , dr.hawb_hawbno as "Hawb Intl"
       , dr.hawb_hawbno_2 as "Hawb Local"
       , to_Char(sysdate,'DD/MM/YY HH24:MI:SS') as "Post Date"  
   from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r
      , strang.customers c
  where p.deliveryno = dr.deliveryno and 
        p.deliveryno = r.deliveryno and 
        r.currdate >  sysdate - 720 and 
     --   substr(p.po,1,2) in ('47','43','45') and
        r.cust_customer_id in (1,9005960,576,596,575,9002717) and 
        dr.io = 'I' and 
        dr.movement_no = m.movement_no and
        nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
        nvl(m.complete,'S') NOT IN ('H','J','F') and
    --    nvl(m.complete,'S') NOT IN ('H','J','D') and
       -- nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
        m.io='I' and 
        m.movement_no <> 'OTMU1234567' and 
        m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'TABUBIL') and 
        nvl(r.supplier_customer_id,0) = c.customer_id and 
     --   NVL(m.complete, 'XXXX') != 'INCOMPLETE' and
        c.customer_type = 'SUPPLIER' and 
        exists (select 1
                  from strang.detailrs dr2
                 where dr.movement_no is not null
                   and dr2.deliveryno = dr.deliveryno
                   and dr2.itemno  = dr.itemno)            
union all  -- 2 
select p.po as "Purchase Order"
       , p.po_item_no as "PO Item No"
       , p.grn as "GRN"
       , p.grn_item as "GRN Item"
       , p.deliveryno as "Delivery No"
       , p.recno as "PO Rno"
       , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION', m.complete) packing_status
       , m.urgency  as "Priority"
       , m.movement_type as "Movement Type"
       , m.movement_no as "Container"
       , m.seal as "Seal"
       , case when m.io = 'I' then 'INBOUND' else 'OUTBOUND' end as "Direction"
       , m.full_mt as "Full Or Empty"
-------------------------------------------------------------------------------------           
       , m.consignee as "Consignee"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.consignee_location) as "Consignee Location"
       , m.warehouse_destination as "Warehouse Destination"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.current_location)  as "Current Location"
       , m.customs_cleared_date as "Customs Cleared Date"
       , m.local_bol as "Local BOL"
       , m.bol as "Intl BOL"
 -------------------------------------------------------------------------------------        
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE')  as "Intl Voyage"
       , case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl Est Arrival Date"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local Est Arrival Date"
       , (select s3.convoyname from strang.convoy s3 where s3.convoy_id = m.convoy_id) as "Convoy Name"
       , (select s3.convoy_type from strang.convoy s3 where s3.convoy_id  = m.convoy_id) as "Convoy Type"
	   , (select s3.estdepart from strang.convoy s3 where s3.convoy_id  = m.convoy_id ) as "Convoy Depart Date"
 -------------------------------------------------------------------------------
       , dr.hawb_hawbno as "Hawb Intl"
       , dr.hawb_hawbno_2 as "Hawb Local"
       , to_Char(sysdate,'DD/MM/YY HH24:MI:SS') as "Post Date"  
 from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
where p.deliveryno = dr.deliveryno and 
p.deliveryno = r.deliveryno and 
--substr(p.po,1,2) in ('47','43','45') and
r.cust_customer_id in (1,9005960,576,596,575,9002717) and 
dr.io = 'I' and 
dr.movement_no = m.movement_no and
nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
nvl(m.complete,'S') NOT IN ('H','J','F') and
--nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
m.io='I' and 
m.movement_no <> 'OTMU1234567' and 
m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and 
nvl(r.supplier_customer_id,0) = c.customer_id and 
r.currdate >  sysdate - 720 and 
--NVL(m.complete, 'XXXX') != 'INCOMPLETE' and
c.customer_type = 'SUPPLIER' and 
 exists (select 1
             from  strang.detailrs dr2
            where  dr.movement_no is not null
             and   dr2.deliveryno = dr.deliveryno
             and   dr2.itemno  = dr.itemno) 
UNION ALL  -- 3
select p.po as "Purchase Order"
       , p.po_item_no as "PO Item No"
       , p.grn as "GRN"
       , p.grn_item as "GRN Item"
       , p.deliveryno as "Delivery No"
       , p.recno as "PO Rno"
       , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION', m.complete) packing_status
       , m.urgency  as "Priority"
       , m.movement_type as "Movement Type"
       , m.movement_no as "Container"
       , m.seal as "Seal"
       , case when m.io = 'I' then 'INBOUND' else 'OUTBOUND' end as "Direction"
       , m.full_mt as "Full Or Empty"
-------------------------------------------------------------------------------------           
       , m.consignee as "Consignee"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.consignee_location) as "Consignee Location"
       , m.warehouse_destination as "Warehouse Destination"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.current_location)  as "Current Location"
       , m.customs_cleared_date as "Customs Cleared Date"
       , m.local_bol as "Local BOL"
       , m.bol as "Intl BOL"     
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE')  as "Intl Voyage"
       , case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl Est Arrival Date"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local Est Arrival Date"
       , (select s3.convoyname from strang.convoy s3 where s3.convoy_id = m.convoy_id) as "Convoy Name"
       , (select s3.convoy_type from strang.convoy s3 where s3.convoy_id  = m.convoy_id) as "Convoy Type"
	   , (select s3.estdepart from strang.convoy s3 where s3.convoy_id  = m.convoy_id ) as "Convoy Depart Date"
       , dr.hawb_hawbno as "Hawb Intl"
       , dr.hawb_hawbno_2 as "Hawb Local"
       , to_Char(sysdate,'DD/MM/YY HH24:MI:SS') as "Post Date"  
 from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
where p.deliveryno = dr.deliveryno and 
--substr(p.po,1,2) in ('47','43','45') and
p.deliveryno = r.deliveryno and 
r.cust_customer_id in (1,9005960,576,596,575,9002717) and 
dr.io = 'I' and 
dr.movement_no = m.movement_no and
nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
nvl(m.complete,'S') NOT IN ('H','J','F') and
--nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
m.io='I' and 
m.movement_no <> 'OTMU1234567' and 
m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and 
--(dr.DELIVERYNO between 1000000 and 1999999 or
--dr.DELIVERYNO between 9000000 and 9999999 ) and
--p.grn_status in (1,8,9) and 
nvl(r.supplier_customer_id,0) = c.customer_id and 
r.currdate >  sysdate - 720 and 
-- NVL(m.complete, 'XXXX') != 'INCOMPLETE' and
c.customer_type = 'SUPPLIER' and 
 exists (select 1
             from  strang.detailrs dr2
            where  dr.movement_no is not null
             and   dr2.deliveryno = dr.deliveryno
             and   dr2.itemno  = dr.itemno)     
union ALL -- 4
select p.po as "Purchase Order"
       , p.po_item_no as "PO Item No"
       , p.grn as "GRN"
       , p.grn_item as "GRN Item"
       , p.deliveryno as "Delivery No"
       , p.recno as "PO Rno"
       , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION', m.complete) packing_status
       , m.urgency  as "Priority"
       , m.movement_type as "Movement Type"
       , m.movement_no as "Container"
       , m.seal as "Seal"
       , case when m.io = 'I' then 'INBOUND' else 'OUTBOUND' end as "Direction"
       , m.full_mt as "Full Or Empty"
-------------------------------------------------------------------------------------           
       , m.consignee as "Consignee"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.consignee_location) as "Consignee Location"
       , m.warehouse_destination as "Warehouse Destination"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.current_location)  as "Current Location"
       , m.customs_cleared_date as "Customs Cleared Date"
       , m.local_bol as "Local BOL"
       , m.bol as "Intl BOL"   
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE')  as "Intl Voyage"
       , case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl Est Arrival Date"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local Est Arrival Date"
       , (select s3.convoyname from strang.convoy s3 where s3.convoy_id = m.convoy_id) as "Convoy Name"
       , (select s3.convoy_type from strang.convoy s3 where s3.convoy_id  = m.convoy_id) as "Convoy Type"
	   , (select s3.estdepart from strang.convoy s3 where s3.convoy_id  = m.convoy_id ) as "Convoy Depart Date"
       , dr.hawb_hawbno as "Hawb Intl"
       , dr.hawb_hawbno_2 as "Hawb Local"
       , to_Char(sysdate,'DD/MM/YY HH24:MI:SS') as "Post Date"  
 from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
where p.deliveryno = dr.deliveryno and 
p.deliveryno = r.deliveryno and 
--substr(p.po,1,2) in ('47','43','45') and
r.cust_customer_id in (1,9005960,576,596,575,9002717) and 
dr.io = 'I' and 
dr.movement_no = m.movement_no and
nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
nvl(m.complete,'S') NOT IN ('H','J','F') and
--nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
m.io='I' and 
m.movement_no <> 'OTMU1234567' and 
m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'BRISBANE') and 
--(dr.DELIVERYNO between 1000000 and 1999999 or
--dr.DELIVERYNO between 9000000 and 9999999 ) and
--p.grn_status in (1,8,9) and 
nvl(r.supplier_customer_id,0) = c.customer_id and 
r.currdate >  sysdate - 720 and 
--NVL(m.complete, 'XXXX') != 'INCOMPLETE' and
c.customer_type = 'SUPPLIER' and 
 exists (select 1
             from  strang.detailrs dr2
            where  dr.movement_no is not null
             and   dr2.deliveryno = dr.deliveryno
             and   dr2.itemno  = dr.itemno)          
union ALL  -- 5
select p.po as "Purchase Order"
       , p.po_item_no as "PO Item No"
       , p.grn as "GRN"
       , p.grn_item as "GRN Item"
       , p.deliveryno as "Delivery No"
       , p.recno as "PO Rno"
       , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION', m.complete) packing_status
       , m.urgency  as "Priority"
       , m.movement_type as "Movement Type"
       , m.movement_no as "Container"
       , m.seal as "Seal"
       , case when m.io = 'I' then 'INBOUND' else 'OUTBOUND' end as "Direction"
       , m.full_mt as "Full Or Empty"
-------------------------------------------------------------------------------------           
       , m.consignee as "Consignee"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.consignee_location) as "Consignee Location"
       , m.warehouse_destination as "Warehouse Destination"
       , strang.f_getlovColumn('LOCATIONS','DESCRIPTION', m.current_location)  as "Current Location"
       , m.customs_cleared_date as "Customs Cleared Date"
       , m.local_bol as "Local BOL"
       , m.bol as "Intl BOL"
 -------------------------------------------------------------------------------------        
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE')  as "Intl Voyage"
       , case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl Est Arrival Date"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship Name"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
       , strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local Est Arrival Date"
       , (select s3.convoyname from strang.convoy s3 where s3.convoy_id = m.convoy_id) as "Convoy Name"
       , (select s3.convoy_type from strang.convoy s3 where s3.convoy_id  = m.convoy_id) as "Convoy Type"
	   , (select s3.estdepart from strang.convoy s3 where s3.convoy_id  = m.convoy_id ) as "Convoy Depart Date"
 -------------------------------------------------------------------------------
       , dr.hawb_hawbno as "Hawb Intl"
       , dr.hawb_hawbno_2 as "Hawb Local"
       , to_Char(sysdate,'DD/MM/YY HH24:MI:SS') as "Post Date"  
from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
where p.deliveryno = dr.deliveryno and 
p.deliveryno = r.deliveryno and 
--substr(p.po,1,2) in ('47','43','45') and
r.cust_customer_id in (1,9005960,576,596,575,9002717) and 
dr.io = 'I' and 
dr.movement_no = m.movement_no and
nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
nvl(m.complete,'S') NOT IN ('H','J','F') and
 m.movement_no <> 'OTMU1234567' and 
--nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
m.io='I' and (
m.current_location is null or
m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc not in ( 'BRISBANE', 'MOTUKEA', 'KIUNGA','TABUBIL')) ) and 
--(dr.DELIVERYNO between 1000000 and 1999999 or
--dr.DELIVERYNO between 9000000 and 9999999 ) and
--p.grn_status in (1,8,9) and 
nvl(r.supplier_customer_id,0) = c.customer_id and 
r.currdate >  sysdate - 720 and 
--NVL(m.complete, 'XXXX') != 'INCOMPLETE' and
c.customer_type = 'SUPPLIER' and 
 exists (select 1
             from  strang.detailrs dr2
            where  dr.movement_no is not null
             and   dr2.deliveryno = dr.deliveryno
             and   dr2.itemno  = dr.itemno)
);

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
 f_file      CONSTANT varchar2(1000) := 'GENERATE_SHIPPED_POS_' || to_char(sysdate, 'dd_mon_yyyy_hh24mi') || '.txt';
 f_file2      CONSTANT varchar2(1000) := 'GENERATE_SHIPPED_POS_EXTRACT' || to_char(sysdate, 'dd_mon_yyyy_hh24mi') || '.csv';  -- email extract

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
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.GENERATE_SHIPPED_POS' );
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
                               
  utl_file.put_line(f, buffer=>'"Purchase Order","PO Item No","GRN","GRN Item","Delivery No","PO Rno","Packing Status","Priority","Movement Type","Container",'||
                               '"Seal","Direction","Full Or Empty","Consignee","Consignee Location","Warehouse Destination","Current Location","Customs Cleared Date",'||
                               '"Local BOL","Intl BOL","Intl Ship Name","Intl Voyage","Intl Est Arrival Date","Local Ship Name","Local Voyage","Local Est Arrival Date",'||
                               '"Convoy Name","Convoy Type","Convoy Depart Date","Hawb Intl","Hawb Local","Post Date","Material Number","Description"');     
--32
 ctr := 0;
 for c1rec in c1 loop
  
  utl_file.put_line(f, buffer=>'"'||c1rec."Purchase Order"||'","'||c1rec."PO Item No"||'","'||c1rec."GRN" ||'","'|| c1rec."GRN Item" || '","' || c1rec."Delivery No"||'","'
                        || c1rec."PO Rno"||'","'||c1rec."Packing Status"||'","'||c1rec."Priority"||'","'||c1rec."Movement Type"||'","'||c1rec."Container"||'","'||c1rec."Seal"||'","'||c1rec."Direction"|| '","'
                        || c1rec."Full Or Empty" ||'","'||c1rec."Consignee"||'","'||c1rec."Consignee Location"||'","'||c1rec."Warehouse Destination"||'","'||c1rec."Current Location"||'","'||c1rec."Customs Cleared Date"||'","'
                        || c1rec."Local BOL"||'","'|| c1rec."Intl BOL"||'","'||c1rec."Intl Ship Name"||'","'||c1rec."Intl Voyage"||'","'||c1rec."Intl Est Arrival Date"||'","'||c1rec."Local Ship Name"||'","'
                        || c1rec."Local Voyage"||'","'||c1rec."Local Est Arrival Date"||'","'
                        || c1rec."Convoy Name"||'","'||c1rec."Convoy Type"||'","'||c1rec."Convoy Depart Date"||'","'
                        || c1rec."Hawb Intl"||'","'||c1rec."Hawb Local"||'","'||c1rec."Post Date"||'","'||c1rec."Material Number"||'","'||c1rec."Description"||'"');

                        
                        
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

  utl_file.put_line(f2, buffer=>'"Purchase Order","PO Item No","GRN","GRN Item","Delivery No","PO Rno","Packing Status","Priority","Movement Type","Container",'||
                               '"Seal","Direction","Full Or Empty","Consignee","Consignee Location","Warehouse Destination","Current Location","Customs Cleared Date",'||
                               '"Local BOL","Intl BOL","Intl Ship Name","Intl Voyage","Intl Est Arrival Date","Local Ship Name","Local Voyage","Local Est Arrival Date",'||
                               '"Convoy Name","Convoy Type","Convoy Depart Date","Hawb Intl","Hawb Local","Post Date","Material Number","Description"');     
  

  ctr1 := 0;
  for c1rec in c1 loop
--  utl_file.put_line(f2, buffer=>c1rec."Delivery No"||','||c1rec."PO Rno" ||','|| c1rec."Purchase Order" || ',' || c1rec."PO Item No" || ',' || c1rec."Material No" || ','
--                        || c1rec."Invoice" || ',' || c1rec."Quantity" || ',' || c1rec."Unit" || ','||c1rec."GRN"||','||c1rec."Receipted Date"||',"'||c1rec."Vendor"|| '",'
--                        ||  c1rec."Log No" || ',' || c1rec."Delivery Item" || ',' || c1rec."Warehouse Destination" || ',' || c1rec."Current Location" || ',' || c1rec."Priority" || ',' || c1rec."Mode" || ','
--                        || c1rec."Container" || ',' || c1rec."Seal" || ',' || c1rec."HAWB"||','||c1rec."Intl Ship ID"||',' ||c1rec."Intl Ship/MAWB" || ',' || c1rec."Intl Voyage" || ',' || c1rec."Intl Line No" || ',' || c1rec."Intl ETA"||','
--                        || c1rec."Intl Bol" || ',' || c1rec."Customs Cleared Date" || ','||c1rec."Local Ship ID"||',' || c1rec."Local Ship" || ','||c1rec."Local Voyage" ||',' || c1rec."Local Line No" || ',' || c1rec."Local Bol" || ',' || c1rec."Local ETA"||','
--                        || c1rec."Scheduled Convoy" || ',' || c1rec."Scheduled Convoy Date" 
--                        );

  utl_file.put_line(f2, buffer=>'"'||c1rec."Purchase Order"||'","'||c1rec."PO Item No"||'","'||c1rec."GRN" ||'","'|| c1rec."GRN Item" || '","' || c1rec."Delivery No"||'","'
                        || c1rec."PO Rno"||'","'||c1rec."Packing Status"||'","'||c1rec."Priority"||'","'||c1rec."Movement Type"||'","'||c1rec."Container"||'","'||c1rec."Seal"||'","'||c1rec."Direction"|| '","'
                        || c1rec."Full Or Empty" ||'","'||c1rec."Consignee"||'","'||c1rec."Consignee Location"||'","'||c1rec."Warehouse Destination"||'","'||c1rec."Current Location"||'","'||c1rec."Customs Cleared Date"||'","'
                        || c1rec."Local BOL"||'","'|| c1rec."Intl BOL"||'","'||c1rec."Intl Ship Name"||'","'||c1rec."Intl Voyage"||'","'||c1rec."Intl Est Arrival Date"||'","'||c1rec."Local Ship Name"||'","'
                        || c1rec."Local Voyage"||'","'||c1rec."Local Est Arrival Date"||'","'
                        || c1rec."Convoy Name"||'","'||c1rec."Convoy Type"||'","'||c1rec."Convoy Depart Date"||'","'
                        ||c1rec."Hawb Intl"||'","'||c1rec."Hawb Local"||'","'||c1rec."Post Date"||'","'||c1rec."Material Number"||'","'||c1rec."Description"||'"');
  
              
   
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
   glbx.send( gcode, gparam, f_file2, p_to=>eml, p_subj=>'GENERATE_SHIPPED_POS_EXTRACT_' || c3rec.v1date || '_' || to_char(sysdate, 'hh24mi'), p_from=>glbx.extract_master_parameter('MAIL_FROM'),is_attachment=>TRUE);
   ftp_ost_185(f_dir || '\' || f_file, 'SFTP');
 else
   begin
    -- utl_file.fremove(glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), 'OST185_' || to_char(sysdate, 'dd_mon_yyyy_hh24mi') || '.csv');
    utl_file.fremove(f_dir, f_file);
   exception when others then null;
   end;
 end if;

exception when others then
 glbx.error_details( 'STRANGP', 'GENERATE_SHIPPED_POS',null,null,errmsg=>sqlerrm);
end generate_shipped_pos;
/
