CREATE OR REPLACE procedure WEBSYS.generate_shipped_pos( surl in varchar2, vtoday in date, is_batch in varchar2 default 'FALSE' )
as

 cursor c1 is
  select p.deliveryno as "Delivery No"
      ,  p.recno as "PO Rno"
      ,  p.po as "Purchase Order"
      ,  p.po_item_no as "PO Item No"
      ,  p.inventoryno as "Material No"
      ,  p.supinv as "Invoice"
      ,  p.sap_delno_qty as "Quantity"
      ,  p.sap_delno_unit as "Unit"
      ,  p.grn as "GRN"
      ,  p.off_site_receipt as "Receipted Date"
      ,  c.customer as "Vendor"
      ,  dr.logno as "Log No"
      ,  dr.itemno as "Delivery Item"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'WAREHOUSE_DESTINATION') as "Warehouse Destination"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CURRENT_LOCATION') as "Current Location"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'URGENCY') as "Priority"
      ,  nvl(p.shipping_text,(decode(dr.sa,'S','Pack for Sea Freight','A','Pack for Air Freight'))) as "Mode"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'MOVEMENT_NO') as "Container"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SEAL') as "Seal"
      ,  nvl(to_char(dr.hawb_hawbno),' ') as "HAWB" 
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIP ID') as "Intl Ship ID"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship/MAWB"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE') as "Intl Voyage"
      ,  case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'etd') else null end as "Intl ETD"
      ,  case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl ETA"
      ,  case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'depart') else null end as "Intl Port of Loading"
      ,  case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'arrive') else null end as "Intl Port of Discharge"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'BOL') as "Intl Bol"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CUSTOMS_CLEARED_DATE') as "Customs Cleared Date"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIP ID') as "Local Ship ID"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL BOL') as "Local Bol"
      ,  strang.f_getshipfields_mv(m.movement_no,m.seal,'L','ESTDEPART') as "Local ETD" 
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local ETA"
      ,  strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTLOAD')) as "Local Port of Loading"
      ,  strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTDISC')) as "Local Port of Discharge"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY') as "Scheduled Convoy"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY DATE') as "Scheduled Convoy Date"
      ,  nvl(strang.f_getLovColumn( 'UNCTNTAB', 'COLA', m.iso_container_type),m.iso_container_type) as "ISO Container Type"
      ,  m.owner  "Container Owner"
      ,  decode(m.iso_container_type,null,'BBULK','FCL') "Cargo"
      ,  strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'DESCRIPTION') as "Description"
      ,  round((nvl(m.vgm,(nvl(m.sumweight,0)+nvl(m.tare,0)))/1000),3) as "Gross Weight in Tonne"
      ,  nvl(m.sumvolume,0) as "Cargo Volume"
      ,  m.consignee||' '||strang.f_getlocdesc(m.consignee_location)||' '||strang.f_getlocdesc(m.warehouse_destination)||' '||m.warehouse_destination as "Consignee"
      ,  strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'HAZARDOUS') as "Hazardous Codes"
      ,  'TABUBIL' as "Controlling Office"
      ,  strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) as "packing Status" 
   from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
  where p.deliveryno = dr.deliveryno and 
        p.deliveryno = r.deliveryno and 
        r.currdate >  sysdate - 700 and 
     --   substr(p.po,1,2) in ('47','43','45') and
        r.cust_customer_id = 1 and 
        dr.io = 'I' and 
        dr.movement_no = m.movement_no and
        nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
        nvl(m.complete,'S') NOT IN ('H','J') and
    --    nvl(m.complete,'S') NOT IN ('H','J','D') and
       -- nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
        m.io='I' and 
        m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'TABUBIL') and 
        nvl(r.supplier_customer_id,0) = c.customer_id and 
        --r.currdate >  sysdate - 720 and 
        c.customer_type = 'SUPPLIER' and 
        exists (select 1
                  from strang.detailrs dr2
                 where dr.movement_no is not null
                   and dr2.deliveryno = dr.deliveryno
                   and dr2.itemno  = dr.itemno)            
union all
select  
 p.deliveryno as "Delivery No"
,p.recno as "PO Rno"
,p.po as "Purchase Order"
,p.po_item_no as "PO Item No"
,p.inventoryno as "Material No"
,p.supinv as "Invoice"
,p.sap_delno_qty as "Quantity"
,p.sap_delno_unit as "Unit"
,p.grn as "GRN"
,p.off_site_receipt as "Receipted Date"
,c.customer as "Vendor"
,dr.logno as "Log No"
,dr.itemno as "Delivery Item"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'WAREHOUSE_DESTINATION') as "Warehouse Destination"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CURRENT_LOCATION') as "Current Location"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'URGENCY') as "Priority"
,nvl(p.shipping_text,(decode(dr.sa,'S','Pack for Sea Freight','A','Pack for Air Freight'))) as "Mode"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'MOVEMENT_NO') as "Container"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SEAL') as Seal
,nvl(to_char(dr.hawb_hawbno),' ') as HAWB 
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIP ID') as "Intl Ship ID"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship/MAWB"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE') as "Intl Voyage"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'etd') else null end as "Intl ETD"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl ETA"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'depart') else null end as "Intl Port of Loading"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'arrive') else null end as "Intl Port of Discharge"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'BOL') as "Intl Bol"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CUSTOMS_CLEARED_DATE') as "Customs Cleared Date"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIP ID') as "Local Ship ID"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL BOL') as "Local Bol"
, strang.f_getshipfields_mv(m.movement_no,m.seal,'L','ESTDEPART') as "Local ETD" 
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local ETA"
, strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTLOAD')) as "Local Port of Loading"
, strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTDISC')) as "Local Port of Discharge"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY') as "Scheduled Convoy"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY DATE') as "Scheduled Convoy Date"
       , nvl(strang.f_getLovColumn( 'UNCTNTAB', 'COLA', m.iso_container_type),m.iso_container_type) as "ISO Container Type"
       , m.owner  "Container Owner"
       , decode(m.iso_container_type,null,'BBULK','FCL') "Cargo"
       , strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'DESCRIPTION') as "Description"
       , round((nvl(m.vgm,(nvl(m.sumweight,0)+nvl(m.tare,0)))/1000),3) as "Gross Weight in Tonne"
       , nvl(m.sumvolume,0) as "Cargo Volume"
       , m.consignee||' '||strang.f_getlocdesc(m.consignee_location)||' '||strang.f_getlocdesc(m.warehouse_destination)||' '||m.warehouse_destination as "Consignee"
       , strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'HAZARDOUS') as "Hazardous Codes"
       , 'KIUNGA' as "Controlling Office"
       , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) as "packing Status" 
 from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
where p.deliveryno = dr.deliveryno and 
p.deliveryno = r.deliveryno and 
--substr(p.po,1,2) in ('47','43','45') and
r.cust_customer_id = 1 and 
dr.io = 'I' and 
dr.movement_no = m.movement_no and
nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
nvl(m.complete,'S') NOT IN ('H','J') and
--nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
m.io='I' and 
m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and 
nvl(r.supplier_customer_id,0) = c.customer_id and 
r.currdate >  sysdate - 720 and 
c.customer_type = 'SUPPLIER' and 
 exists (select 1
             from  strang.detailrs dr2
            where  dr.movement_no is not null
             and   dr2.deliveryno = dr.deliveryno
             and   dr2.itemno  = dr.itemno) 
UNION ALL
select  
 p.deliveryno as "Delivery No"
,p.recno as "PO Rno"
,p.po as "Purchase Order"
,p.po_item_no as "PO Item No"
,p.inventoryno as "Material No"
,p.supinv as "Invoice"
,p.sap_delno_qty as "Quantity"
,p.sap_delno_unit as "Unit"
,p.grn as "GRN"
,p.off_site_receipt as "Receipted Date"
,c.customer as "Vendor"
,dr.logno as "Log No"
,dr.itemno as "Delivery Item"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'WAREHOUSE_DESTINATION') as "Warehouse Destination"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CURRENT_LOCATION') as "Current Location"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'URGENCY') as "Priority"
,nvl(p.shipping_text,(decode(dr.sa,'S','Pack for Sea Freight','A','Pack for Air Freight'))) as "Mode"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'MOVEMENT_NO') as "Container"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SEAL') as Seal
,nvl(to_char(dr.hawb_hawbno),' ') as HAWB 
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIP ID') as "Intl Ship ID"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship/MAWB"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE') as "Intl Voyage"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'etd') else null end as "Intl ETD"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl ETA"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'depart') else null end as "Intl Port of Loading"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'arrive') else null end as "Intl Port of Discharge"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'BOL') as "Intl Bol"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CUSTOMS_CLEARED_DATE') as "Customs Cleared Date"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIP ID') as "Local Ship ID"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL BOL') as "Local Bol"
, strang.f_getshipfields_mv(m.movement_no,m.seal,'L','ESTDEPART') as "Local ETD" 
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local ETA"
, strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTLOAD')) as "Local Port of Loading"
, strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTDISC')) as "Local Port of Discharge"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY') as "Scheduled Convoy"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY DATE') as "Scheduled Convoy Date"
       , nvl(strang.f_getLovColumn( 'UNCTNTAB', 'COLA', m.iso_container_type),m.iso_container_type) as "ISO Container Type"
       , m.owner  "Container Owner"
       , decode(m.iso_container_type,null,'BBULK','FCL') "Cargo"
       , strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'DESCRIPTION') as "Description"
       , round((nvl(m.vgm,(nvl(m.sumweight,0)+nvl(m.tare,0)))/1000),3) as "Gross Weight in Tonne"
       , nvl(m.sumvolume,0) as "Cargo Volume"
       , m.consignee||' '||strang.f_getlocdesc(m.consignee_location)||' '||strang.f_getlocdesc(m.warehouse_destination)||' '||m.warehouse_destination as "Consignee"
       , strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'HAZARDOUS') as "Hazardous Codes"
       , 'MOTUKEA' as "Controlling Office"
       , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) as "packing Status" 
 from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
where p.deliveryno = dr.deliveryno and 
--substr(p.po,1,2) in ('47','43','45') and
p.deliveryno = r.deliveryno and 
r.cust_customer_id = 1 and 
dr.io = 'I' and 
dr.movement_no = m.movement_no and
nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
nvl(m.complete,'S') NOT IN ('H','J') and
--nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
m.io='I' and 
m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and 
--(dr.DELIVERYNO between 1000000 and 1999999 or
--dr.DELIVERYNO between 9000000 and 9999999 ) and
--p.grn_status in (1,8,9) and 
nvl(r.supplier_customer_id,0) = c.customer_id and 
r.currdate >  sysdate - 720 and 
c.customer_type = 'SUPPLIER' and 
 exists (select 1
             from  strang.detailrs dr2
            where  dr.movement_no is not null
             and   dr2.deliveryno = dr.deliveryno
             and   dr2.itemno  = dr.itemno)     
union ALL
select  
 p.deliveryno as "Delivery No"
,p.recno as "PO Rno"
,p.po as "Purchase Order"
,p.po_item_no as "PO Item No"
,p.inventoryno as "Material No"
,p.supinv as "Invoice"
,p.sap_delno_qty as "Quantity"
,p.sap_delno_unit as "Unit"
,p.grn as "GRN"
,p.off_site_receipt as "Receipted Date"
,c.customer as "Vendor"
,dr.logno as "Log No"
,dr.itemno as "Delivery Item"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'WAREHOUSE_DESTINATION') as "Warehouse Destination"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CURRENT_LOCATION') as "Current Location"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'URGENCY') as "Priority"
,nvl(p.shipping_text,(decode(dr.sa,'S','Pack for Sea Freight','A','Pack for Air Freight'))) as "Mode"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'MOVEMENT_NO') as "Container"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SEAL') as Seal
,nvl(to_char(dr.hawb_hawbno),' ') as HAWB 
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIP ID') as "Intl Ship ID"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship/MAWB"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE') as "Intl Voyage"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'etd') else null end as "Intl ETD"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl ETA"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'depart') else null end as "Intl Port of Loading"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'arrive') else null end as "Intl Port of Discharge"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'BOL') as "Intl Bol"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CUSTOMS_CLEARED_DATE') as "Customs Cleared Date"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIP ID') as "Local Ship ID"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL BOL') as "Local Bol"
, strang.f_getshipfields_mv(m.movement_no,m.seal,'L','ESTDEPART') as "Local ETD" 
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local ETA"
, strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTLOAD')) as "Local Port of Loading"
, strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTDISC')) as "Local Port of Discharge"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY') as "Scheduled Convoy"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY DATE') as "Scheduled Convoy Date"
       , nvl(strang.f_getLovColumn( 'UNCTNTAB', 'COLA', m.iso_container_type),m.iso_container_type) as "ISO Container Type"
       , m.owner  "Container Owner"
       , decode(m.iso_container_type,null,'BBULK','FCL') "Cargo"
       , strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'DESCRIPTION') as "Description"
       , round((nvl(m.vgm,(nvl(m.sumweight,0)+nvl(m.tare,0)))/1000),3) as "Gross Weight in Tonne"
       , nvl(m.sumvolume,0) as "Cargo Volume"
       , m.consignee||' '||strang.f_getlocdesc(m.consignee_location)||' '||strang.f_getlocdesc(m.warehouse_destination)||' '||m.warehouse_destination as "Consignee"
       , strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'HAZARDOUS') as "Hazardous Codes"
       , 'BRISBANE' as "Controlling Office"
       , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) as "packing Status" 
 from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
where p.deliveryno = dr.deliveryno and 
p.deliveryno = r.deliveryno and 
--substr(p.po,1,2) in ('47','43','45') and
r.cust_customer_id = 1 and 
dr.io = 'I' and 
dr.movement_no = m.movement_no and
nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
nvl(m.complete,'S') NOT IN ('H','J') and
--nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
m.io='I' and 
m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'BRISBANE') and 
--(dr.DELIVERYNO between 1000000 and 1999999 or
--dr.DELIVERYNO between 9000000 and 9999999 ) and
--p.grn_status in (1,8,9) and 
nvl(r.supplier_customer_id,0) = c.customer_id and 
r.currdate >  sysdate - 720 and 
c.customer_type = 'SUPPLIER' and 
 exists (select 1
             from  strang.detailrs dr2
            where  dr.movement_no is not null
             and   dr2.deliveryno = dr.deliveryno
             and   dr2.itemno  = dr.itemno)          
union ALL
select  
 p.deliveryno as "Delivery No"
,p.recno as "PO Rno"
,p.po as "Purchase Order"
,p.po_item_no as "PO Item No"
,p.inventoryno as "Material No"
,p.supinv as "Invoice"
,p.sap_delno_qty as "Quantity"
,p.sap_delno_unit as "Unit"
,p.grn as "GRN"
,p.off_site_receipt as "Receipted Date"
,c.customer as "Vendor"
,dr.logno as "Log No"
,dr.itemno as "Delivery Item"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'WAREHOUSE_DESTINATION') as "Warehouse Destination"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CURRENT_LOCATION') as "Current Location"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'URGENCY') as "Priority"
,nvl(p.shipping_text,(decode(dr.sa,'S','Pack for Sea Freight','A','Pack for Air Freight'))) as "Mode"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'MOVEMENT_NO') as "Container"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SEAL') as Seal
,nvl(to_char(dr.hawb_hawbno),' ') as HAWB 
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIP ID') as "Intl Ship ID"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship/MAWB"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE') as "Intl Voyage"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'etd') else null end as "Intl ETD"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl ETA"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'depart') else null end as "Intl Port of Loading"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'arrive') else null end as "Intl Port of Discharge"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'BOL') as "Intl Bol"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CUSTOMS_CLEARED_DATE') as "Customs Cleared Date"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIP ID') as "Local Ship ID"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL BOL') as "Local Bol"
, strang.f_getshipfields_mv(m.movement_no,m.seal,'L','ESTDEPART') as "Local ETD" 
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local ETA"
,strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTLOAD')) as "Local Port of Loading"
,strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTDISC')) as "Local Port of Discharge"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY') as "Scheduled Convoy"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY DATE') as "Scheduled Convoy Date"
,nvl(strang.f_getLovColumn( 'UNCTNTAB', 'COLA', m.iso_container_type),m.iso_container_type) as "ISO Container Type"
,m.owner  "Container Owner"
,decode(m.iso_container_type,null,'BBULK','FCL') "Cargo"
,strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'DESCRIPTION') as "Description"
,round((nvl(m.vgm,(nvl(m.sumweight,0)+nvl(m.tare,0)))/1000),3) as "Gross Weight in Tonne"
,nvl(m.sumvolume,0) as "Cargo Volume"
,m.consignee||' '||strang.f_getlocdesc(m.consignee_location)||' '||strang.f_getlocdesc(m.warehouse_destination)||' '||m.warehouse_destination as "Consignee"
,strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'HAZARDOUS') as "Hazardous Codes"
,NVL( (SELECT COLC from strang.lov where lov_name='LOCATIONS' and code = m.current_location) , 'UNKNOWN') as "Controlling Office"
,strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) as "packing Status" 
from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
where p.deliveryno = dr.deliveryno and 
p.deliveryno = r.deliveryno and 
--substr(p.po,1,2) in ('47','43','45') and
r.cust_customer_id = 1 and 
dr.io = 'I' and 
dr.movement_no = m.movement_no and
nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
nvl(m.complete,'S') NOT IN ('H','J') and
--nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
m.io='I' and (
m.current_location is null or
m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc not in ( 'BRISBANE', 'MOTUKEA', 'KIUNGA','TABUBIL')) ) and 
--(dr.DELIVERYNO between 1000000 and 1999999 or
--dr.DELIVERYNO between 9000000 and 9999999 ) and
--p.grn_status in (1,8,9) and 
nvl(r.supplier_customer_id,0) = c.customer_id and 
r.currdate >  sysdate - 700 and 
c.customer_type = 'SUPPLIER' and 
 exists (select 1
             from  strang.detailrs dr2
            where  dr.movement_no is not null
             and   dr2.deliveryno = dr.deliveryno
             and   dr2.itemno  = dr.itemno)
 order by 1, 3, 4, 6;
 
 
-- 
-- 
--  select /*+ ALL_ROWS */
--         distinct
--         p.rowid,
--         p.deliveryno as "Delivery No", 
--         p.recno as "PO Rno", 
--         p.po as "Purchase Order",
--         p.po_item_no as "PO Item No",
--         p.inventoryno as "Material No",
--         p.supinv as "Invoice",
--         p.sap_delno_qty as "Quantity",
--         p.sap_delno_unit as "Unit",
--         p.grn as "GRN",
--         p.off_site_receipt as "Receipted Date",
--         c.customer as "Vendor",
--         dr.logno as "Log No",
--         dr.itemno as "Delivery Item",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'WAREHOUSE_DESTINATION') as "Warehouse Destination",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CURRENT_LOCATION') as "Current Location",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'URGENCY') as "Priority",
--         nvl(p.shipping_text,(decode(dr.sa,'S','Pack for Sea Freight','A','Pack for Air Freight'))) as "Mode",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'MOVEMENT_NO') as "Container",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SEAL') as "Seal",
--         nvl(to_char(dr.hawb_hawbno),' ') as "HAWB",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIP ID') as "Intl Ship ID",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship/MAWB",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE') as "Intl Voyage",
--         to_char(dr.line_no) as "Intl Line No",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL ESTARRIVE') as "Intl ETA",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'BOL') as "Intl Bol",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CUSTOMS_CLEARED_DATE') as "Customs Cleared Date",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIP ID') as "Local Ship ID",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage",
--         to_char(dr.local_line_no) as "Local Line No",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL BOL') as "Local Bol",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local ETA",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY') as "Scheduled Convoy",
--         strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY DATE') as "Scheduled Convoy Date"  
--    from strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
--    where p.deliveryno = dr.deliveryno and
--    p.deliveryno = r.deliveryno and 
--    r.cust_customer_id = 1 and 
--    dr.io = 'I' and 
--    p.grn_status in (1,8,9) and 
--    nvl(r.supplier_customer_id,0) = c.customer_id and 
--    r.currdate >  sysdate - 180 and 
--    c.customer_type = 'SUPPLIER' and 
--    not exists 
--    ( select  p1.deliveryno 
--        from strang.pos p1, strang.detailrs dr, strang.receivals r, strang.movements m, strang.lov l1, strang.lov l2 
--       where p1.deliveryno = r.deliveryno and 
--            p1.deliveryno = dr.deliveryno and 
--            p1.deliveryno = p.deliveryno and
--            r.cust_customer_id = 1 and
--            dr.io = 'I' and
--            dr.movement_no = m.movement_no and
--            nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and 
--            m.warehouse_destination = l1.code and
--            l1.lov_name = 'LOCATIONS' and
--            m.current_location = l2.code and
--            l2.lov_name = 'LOCATIONS' and
--            l1.colc = l2.colc )      
--      order by p.deliveryno, p.po, p.po_item_no, p.supinv, dr.logno   
-- ;

 cursor c2 is
   select count('x') tot
   from
   (     select p.deliveryno as "Delivery No"
      ,  p.recno as "PO Rno"
      ,  p.po as "Purchase Order"
      ,  p.po_item_no as "PO Item No"
      ,  p.inventoryno as "Material No"
      ,  p.supinv as "Invoice"
      ,  p.sap_delno_qty as "Quantity"
      ,  p.sap_delno_unit as "Unit"
      ,  p.grn as "GRN"
      ,  p.off_site_receipt as "Receipted Date"
      ,  c.customer as "Vendor"
      ,  dr.logno as "Log No"
      ,  dr.itemno as "Delivery Item"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'WAREHOUSE_DESTINATION') as "Warehouse Destination"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CURRENT_LOCATION') as "Current Location"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'URGENCY') as "Priority"
      ,  nvl(p.shipping_text,(decode(dr.sa,'S','Pack for Sea Freight','A','Pack for Air Freight'))) as "Mode"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'MOVEMENT_NO') as "Container"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SEAL') as "Seal"
      ,  nvl(to_char(dr.hawb_hawbno),' ') as "HAWB" 
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIP ID') as "Intl Ship ID"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship/MAWB"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE') as "Intl Voyage"
      ,  case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'etd') else null end as "Intl ETD"
      ,  case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl ETA"
      ,  case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'depart') else null end as "Intl Port of Loading"
      ,  case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'arrive') else null end as "Intl Port of Discharge"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'BOL') as "Intl Bol"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CUSTOMS_CLEARED_DATE') as "Customs Cleared Date"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIP ID') as "Local Ship ID"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL BOL') as "Local Bol"
      ,  strang.f_getshipfields_mv(m.movement_no,m.seal,'L','ESTDEPART') as "Local ETD" 
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local ETA"
      ,  strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTLOAD')) as "Local Port of Loading"
      ,  strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTDISC')) as "Local Port of Discharge"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY') as "Scheduled Convoy"
      ,  strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY DATE') as "Scheduled Convoy Date"
      ,  nvl(strang.f_getLovColumn( 'UNCTNTAB', 'COLA', m.iso_container_type),m.iso_container_type) as "ISO Container Type"
      ,  m.owner  "Container Owner"
      ,  decode(m.iso_container_type,null,'BBULK','FCL') "Cargo"
      ,  strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'DESCRIPTION') as "Description"
      ,  round((nvl(m.vgm,(nvl(m.sumweight,0)+nvl(m.tare,0)))/1000),3) as "Gross Weight in Tonne"
      ,  nvl(m.sumvolume,0) as "Cargo Volume"
      ,  m.consignee||' '||strang.f_getlocdesc(m.consignee_location)||' '||strang.f_getlocdesc(m.warehouse_destination)||' '||m.warehouse_destination as "Consignee"
      ,  strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'HAZARDOUS') as "Hazardous Codes"
      ,  'TABUBIL' as "Controlling Office"
      ,  strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) as "packing Status" 
   from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
  where p.deliveryno = dr.deliveryno and 
        p.deliveryno = r.deliveryno and 
        r.currdate >  sysdate - 700 and 
     --   substr(p.po,1,2) in ('47','43','45') and
        r.cust_customer_id = 1 and 
        dr.io = 'I' and 
        dr.movement_no = m.movement_no and
        nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
        nvl(m.complete,'S') NOT IN ('H','J') and
    --    nvl(m.complete,'S') NOT IN ('H','J','D') and
       -- nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
        m.io='I' and 
        m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'TABUBIL') and 
        nvl(r.supplier_customer_id,0) = c.customer_id and 
        r.currdate >  sysdate - 720 and 
        c.customer_type = 'SUPPLIER' and 
        exists (select 1
                  from strang.detailrs dr2
                 where dr.movement_no is not null
                   and dr2.deliveryno = dr.deliveryno
                   and dr2.itemno  = dr.itemno)            
union all
select  
 p.deliveryno as "Delivery No"
,p.recno as "PO Rno"
,p.po as "Purchase Order"
,p.po_item_no as "PO Item No"
,p.inventoryno as "Material No"
,p.supinv as "Invoice"
,p.sap_delno_qty as "Quantity"
,p.sap_delno_unit as "Unit"
,p.grn as "GRN"
,p.off_site_receipt as "Receipted Date"
,c.customer as "Vendor"
,dr.logno as "Log No"
,dr.itemno as "Delivery Item"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'WAREHOUSE_DESTINATION') as "Warehouse Destination"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CURRENT_LOCATION') as "Current Location"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'URGENCY') as "Priority"
,nvl(p.shipping_text,(decode(dr.sa,'S','Pack for Sea Freight','A','Pack for Air Freight'))) as "Mode"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'MOVEMENT_NO') as "Container"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SEAL') as Seal
,nvl(to_char(dr.hawb_hawbno),' ') as HAWB 
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIP ID') as "Intl Ship ID"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship/MAWB"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE') as "Intl Voyage"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'etd') else null end as "Intl ETD"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl ETA"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'depart') else null end as "Intl Port of Loading"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'arrive') else null end as "Intl Port of Discharge"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'BOL') as "Intl Bol"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CUSTOMS_CLEARED_DATE') as "Customs Cleared Date"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIP ID') as "Local Ship ID"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL BOL') as "Local Bol"
, strang.f_getshipfields_mv(m.movement_no,m.seal,'L','ESTDEPART') as "Local ETD" 
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local ETA"
, strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTLOAD')) as "Local Port of Loading"
, strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTDISC')) as "Local Port of Discharge"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY') as "Scheduled Convoy"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY DATE') as "Scheduled Convoy Date"
       , nvl(strang.f_getLovColumn( 'UNCTNTAB', 'COLA', m.iso_container_type),m.iso_container_type) as "ISO Container Type"
       , m.owner  "Container Owner"
       , decode(m.iso_container_type,null,'BBULK','FCL') "Cargo"
       , strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'DESCRIPTION') as "Description"
       , round((nvl(m.vgm,(nvl(m.sumweight,0)+nvl(m.tare,0)))/1000),3) as "Gross Weight in Tonne"
       , nvl(m.sumvolume,0) as "Cargo Volume"
       , m.consignee||' '||strang.f_getlocdesc(m.consignee_location)||' '||strang.f_getlocdesc(m.warehouse_destination)||' '||m.warehouse_destination as "Consignee"
       , strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'HAZARDOUS') as "Hazardous Codes"
       , 'KIUNGA' as "Controlling Office"
       , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) as "packing Status" 
 from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
where p.deliveryno = dr.deliveryno and 
p.deliveryno = r.deliveryno and 
--substr(p.po,1,2) in ('47','43','45') and
r.cust_customer_id = 1 and 
dr.io = 'I' and 
dr.movement_no = m.movement_no and
nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
nvl(m.complete,'S') NOT IN ('H','J') and
--nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
m.io='I' and 
m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and 
nvl(r.supplier_customer_id,0) = c.customer_id and 
r.currdate >  sysdate - 720 and 
c.customer_type = 'SUPPLIER' and 
 exists (select 1
             from  strang.detailrs dr2
            where  dr.movement_no is not null
             and   dr2.deliveryno = dr.deliveryno
             and   dr2.itemno  = dr.itemno) 
UNION ALL
select  
 p.deliveryno as "Delivery No"
,p.recno as "PO Rno"
,p.po as "Purchase Order"
,p.po_item_no as "PO Item No"
,p.inventoryno as "Material No"
,p.supinv as "Invoice"
,p.sap_delno_qty as "Quantity"
,p.sap_delno_unit as "Unit"
,p.grn as "GRN"
,p.off_site_receipt as "Receipted Date"
,c.customer as "Vendor"
,dr.logno as "Log No"
,dr.itemno as "Delivery Item"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'WAREHOUSE_DESTINATION') as "Warehouse Destination"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CURRENT_LOCATION') as "Current Location"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'URGENCY') as "Priority"
,nvl(p.shipping_text,(decode(dr.sa,'S','Pack for Sea Freight','A','Pack for Air Freight'))) as "Mode"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'MOVEMENT_NO') as "Container"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SEAL') as Seal
,nvl(to_char(dr.hawb_hawbno),' ') as HAWB 
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIP ID') as "Intl Ship ID"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship/MAWB"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE') as "Intl Voyage"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'etd') else null end as "Intl ETD"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl ETA"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'depart') else null end as "Intl Port of Loading"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'arrive') else null end as "Intl Port of Discharge"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'BOL') as "Intl Bol"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CUSTOMS_CLEARED_DATE') as "Customs Cleared Date"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIP ID') as "Local Ship ID"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL BOL') as "Local Bol"
, strang.f_getshipfields_mv(m.movement_no,m.seal,'L','ESTDEPART') as "Local ETD" 
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local ETA"
, strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTLOAD')) as "Local Port of Loading"
, strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTDISC')) as "Local Port of Discharge"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY') as "Scheduled Convoy"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY DATE') as "Scheduled Convoy Date"
       , nvl(strang.f_getLovColumn( 'UNCTNTAB', 'COLA', m.iso_container_type),m.iso_container_type) as "ISO Container Type"
       , m.owner  "Container Owner"
       , decode(m.iso_container_type,null,'BBULK','FCL') "Cargo"
       , strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'DESCRIPTION') as "Description"
       , round((nvl(m.vgm,(nvl(m.sumweight,0)+nvl(m.tare,0)))/1000),3) as "Gross Weight in Tonne"
       , nvl(m.sumvolume,0) as "Cargo Volume"
       , m.consignee||' '||strang.f_getlocdesc(m.consignee_location)||' '||strang.f_getlocdesc(m.warehouse_destination)||' '||m.warehouse_destination as "Consignee"
       , strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'HAZARDOUS') as "Hazardous Codes"
       , 'MOTUKEA' as "Controlling Office"
       , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) as "packing Status" 
 from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
where p.deliveryno = dr.deliveryno and 
--substr(p.po,1,2) in ('47','43','45') and
p.deliveryno = r.deliveryno and 
r.cust_customer_id = 1 and 
dr.io = 'I' and 
dr.movement_no = m.movement_no and
nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
nvl(m.complete,'S') NOT IN ('H','J') and
--nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
m.io='I' and 
m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and 
--(dr.DELIVERYNO between 1000000 and 1999999 or
--dr.DELIVERYNO between 9000000 and 9999999 ) and
--p.grn_status in (1,8,9) and 
nvl(r.supplier_customer_id,0) = c.customer_id and 
r.currdate >  sysdate - 720 and 
c.customer_type = 'SUPPLIER' and 
 exists (select 1
             from  strang.detailrs dr2
            where  dr.movement_no is not null
             and   dr2.deliveryno = dr.deliveryno
             and   dr2.itemno  = dr.itemno)     
union ALL
select  
 p.deliveryno as "Delivery No"
,p.recno as "PO Rno"
,p.po as "Purchase Order"
,p.po_item_no as "PO Item No"
,p.inventoryno as "Material No"
,p.supinv as "Invoice"
,p.sap_delno_qty as "Quantity"
,p.sap_delno_unit as "Unit"
,p.grn as "GRN"
,p.off_site_receipt as "Receipted Date"
,c.customer as "Vendor"
,dr.logno as "Log No"
,dr.itemno as "Delivery Item"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'WAREHOUSE_DESTINATION') as "Warehouse Destination"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CURRENT_LOCATION') as "Current Location"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'URGENCY') as "Priority"
,nvl(p.shipping_text,(decode(dr.sa,'S','Pack for Sea Freight','A','Pack for Air Freight'))) as "Mode"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'MOVEMENT_NO') as "Container"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SEAL') as Seal
,nvl(to_char(dr.hawb_hawbno),' ') as HAWB 
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIP ID') as "Intl Ship ID"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship/MAWB"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE') as "Intl Voyage"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'etd') else null end as "Intl ETD"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl ETA"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'depart') else null end as "Intl Port of Loading"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'arrive') else null end as "Intl Port of Discharge"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'BOL') as "Intl Bol"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CUSTOMS_CLEARED_DATE') as "Customs Cleared Date"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIP ID') as "Local Ship ID"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL BOL') as "Local Bol"
, strang.f_getshipfields_mv(m.movement_no,m.seal,'L','ESTDEPART') as "Local ETD" 
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local ETA"
, strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTLOAD')) as "Local Port of Loading"
, strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTDISC')) as "Local Port of Discharge"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY') as "Scheduled Convoy"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY DATE') as "Scheduled Convoy Date"
       , nvl(strang.f_getLovColumn( 'UNCTNTAB', 'COLA', m.iso_container_type),m.iso_container_type) as "ISO Container Type"
       , m.owner  "Container Owner"
       , decode(m.iso_container_type,null,'BBULK','FCL') "Cargo"
       , replace(strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'DESCRIPTION'),'"','') as "Description"
       , round((nvl(m.vgm,(nvl(m.sumweight,0)+nvl(m.tare,0)))/1000),3) as "Gross Weight in Tonne"
       , nvl(m.sumvolume,0) as "Cargo Volume"
       , m.consignee||' '||strang.f_getlocdesc(m.consignee_location)||' '||strang.f_getlocdesc(m.warehouse_destination)||' '||m.warehouse_destination as "Consignee"
       , strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'HAZARDOUS') as "Hazardous Codes"
       , 'BRISBANE' as "Controlling Office"
       , strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) as "packing Status" 
 from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
where p.deliveryno = dr.deliveryno and 
p.deliveryno = r.deliveryno and 
--substr(p.po,1,2) in ('47','43','45') and
r.cust_customer_id = 1 and 
dr.io = 'I' and 
dr.movement_no = m.movement_no and
nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
nvl(m.complete,'S') NOT IN ('H','J') and
--nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
m.io='I' and 
m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'BRISBANE') and 
--(dr.DELIVERYNO between 1000000 and 1999999 or
--dr.DELIVERYNO between 9000000 and 9999999 ) and
--p.grn_status in (1,8,9) and 
nvl(r.supplier_customer_id,0) = c.customer_id and 
r.currdate >  sysdate - 720 and 
c.customer_type = 'SUPPLIER' and 
 exists (select 1
             from  strang.detailrs dr2
            where  dr.movement_no is not null
             and   dr2.deliveryno = dr.deliveryno
             and   dr2.itemno  = dr.itemno)          
union ALL
select  
 p.deliveryno as "Delivery No"
,p.recno as "PO Rno"
,p.po as "Purchase Order"
,p.po_item_no as "PO Item No"
,p.inventoryno as "Material No"
,p.supinv as "Invoice"
,p.sap_delno_qty as "Quantity"
,p.sap_delno_unit as "Unit"
,p.grn as "GRN"
,p.off_site_receipt as "Receipted Date"
,c.customer as "Vendor"
,dr.logno as "Log No"
,dr.itemno as "Delivery Item"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'WAREHOUSE_DESTINATION') as "Warehouse Destination"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CURRENT_LOCATION') as "Current Location"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'URGENCY') as "Priority"
,nvl(p.shipping_text,(decode(dr.sa,'S','Pack for Sea Freight','A','Pack for Air Freight'))) as "Mode"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'MOVEMENT_NO') as "Container"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SEAL') as Seal
,nvl(to_char(dr.hawb_hawbno),' ') as HAWB 
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIP ID') as "Intl Ship ID"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL SHIPNAME') as "Intl Ship/MAWB"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'INTL VOYAGE') as "Intl Voyage"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'etd') else null end as "Intl ETD"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'eta') else null end as "Intl ETA"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'depart') else null end as "Intl Port of Loading"
, case when dr.sa = 'S' then stx1.f_getshipdetails_new(p.deliveryno,dr.itemno,'I',section=>'arrive') else null end as "Intl Port of Discharge"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'BOL') as "Intl Bol"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'CUSTOMS_CLEARED_DATE') as "Customs Cleared Date"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIP ID') as "Local Ship ID"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL SHIPNAME') as "Local Ship"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL VOYAGE') as "Local Voyage"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL BOL') as "Local Bol"
, strang.f_getshipfields_mv(m.movement_no,m.seal,'L','ESTDEPART') as "Local ETD" 
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'LOCAL ESTARRIVE') as "Local ETA"
,strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTLOAD')) as "Local Port of Loading"
,strang.f_getlocdesc(strang.f_getshipfields_mv(m.movement_no,m.seal,'L','PORTDISC')) as "Local Port of Discharge"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY') as "Scheduled Convoy"
,strang.f_get_info_for_po(p.deliveryno,dr.itemno,'SCHEDULED CONVOY DATE') as "Scheduled Convoy Date"
,nvl(strang.f_getLovColumn( 'UNCTNTAB', 'COLA', m.iso_container_type),m.iso_container_type) as "ISO Container Type"
,m.owner  "Container Owner"
,decode(m.iso_container_type,null,'BBULK','FCL') "Cargo"
,strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'DESCRIPTION') as "Description"
,round((nvl(m.vgm,(nvl(m.sumweight,0)+nvl(m.tare,0)))/1000),3) as "Gross Weight in Tonne"
,nvl(m.sumvolume,0) as "Cargo Volume"
,m.consignee||' '||strang.f_getlocdesc(m.consignee_location)||' '||strang.f_getlocdesc(m.warehouse_destination)||' '||m.warehouse_destination as "Consignee"
,strang.f_get_info(m.movement_no,nvl(m.seal,'|'),'HAZARDOUS') as "Hazardous Codes"
,NVL( (SELECT COLC from strang.lov where lov_name='LOCATIONS' and code = m.current_location) , 'UNKNOWN') as "Controlling Office"
,strang.f_getlovColumn('MOVEMENT_STATUS','DESCRIPTION',m.complete) as "packing Status" 
from strang.movements m, strang.pos p, strang.detailrs dr, strang.receivals r, strang.customers c 
where p.deliveryno = dr.deliveryno and 
p.deliveryno = r.deliveryno and 
--substr(p.po,1,2) in ('47','43','45') and
r.cust_customer_id = 1 and 
dr.io = 'I' and 
dr.movement_no = m.movement_no and
nvl(dr.camov_seal, '|') = nvl(m.seal,'|') and
nvl(m.complete,'S') NOT IN ('H','J') and
--nvl(MOVEMENT_TYPE, 'XXX') NOT IN ('AIRWAY', 'CONMOV') and
m.io='I' and (
m.current_location is null or
m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc not in ( 'BRISBANE', 'MOTUKEA', 'KIUNGA','TABUBIL')) ) and 
--(dr.DELIVERYNO between 1000000 and 1999999 or
--dr.DELIVERYNO between 9000000 and 9999999 ) and
--p.grn_status in (1,8,9) and 
nvl(r.supplier_customer_id,0) = c.customer_id and 
r.currdate >  sysdate - 700 and 
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

 -- Output Header
 --utl_file.put_line(f, buffer=>'H,' || to_char(sysdate,'DD.MM.YYYY') || ',' || tot );
--  utl_file.put_line(f, buffer=>'Delivery No,PO Rno,Purchase Order,PO Item No,Material No,Invoice,Quantity,Unit,GRN,Receipted Date,'||
--                                'Vendor,Log No,Delivery Item,Warehouse Destination,Current Location,Priority,Mode,Container,Seal,HAWB,'||
--                                'Intl Ship ID,Intl Ship/MAWB,Intl Voyage,Intl Line No,Intl ETA,Intl Bol,Customs Cleared Date,Local Ship ID,'||
--                                'Local Ship,Local Voyage,Local Line No,Local Bol,Local ETA,Scheduled Convoy,Scheduled Convoy Date');
                                
                                
  utl_file.put_line(f, buffer=>'"Delivery No","PO Rno","Purchase Order","PO Item No","Material No","Invoice","Quantity","Unit","GRN","Receipted Date","Vendor","Log No","Delivery Item","'||
                               'Warehouse Destination","Current Location","Priority","Mode","Container","Seal","HAWB","Intl Ship ID","Intl Ship/MAWB"," Intl Voyage","'||
                               'Intl ETD","Intl ETA","Intl Port of Loading","Intl Port of Discharge","Intl Bol","Customs Cleared Date","Local Ship ID","Local Ship","'||
                               'Local Voyage","Local Bol","Local ETD","Local ETA","Local Port of Loading","Local Port of Discharge","Scheduled Convoy","Scheduled Convoy Date","'||
                               'ISO Container Type","Container Owner","Cargo","Description","Gross Weight in Tonne","Cargo Volume"," Consignee"," Hazardous Codes","'||
                               'Controlling Office","packing Status"');             

 ctr := 0;
 for c1rec in c1 loop
--  utl_file.put_line(f, buffer=>c1rec."Delivery No"||','||c1rec."PO Rno"||','||c1rec."Purchase Order" ||','|| c1rec."PO Item No" || ',' || c1rec."Material No" || ','
--                        || c1rec."Invoice" || ',' || c1rec."Quantity" || ',' || c1rec."Unit" || ','||c1rec."GRN"||','||c1rec."Receipted Date"||',"'||c1rec."Vendor"|| '",'
--                        ||  c1rec."Log No" || ',' || c1rec."Delivery Item" || ',' || c1rec."Warehouse Destination" ||','|| c1rec."Current Location"||','|| c1rec."Priority" || ',' || c1rec."Mode" || ','
--                        || c1rec."Container" || ',' || c1rec."Seal" || ',' || c1rec."HAWB" ||','||c1rec."Intl Ship ID"||',' || c1rec."Intl Ship/MAWB" || ',' || c1rec."Intl Voyage" || ',' || c1rec."Intl Line No" || ',' || c1rec."Intl ETA"||','
--                        || c1rec."Intl Bol" || ',' || c1rec."Customs Cleared Date" || ','||c1rec."Local Ship ID"|| ',' || c1rec."Local Ship" || ','||c1rec."Local Voyage" ||',' || c1rec."Local Line No" || ',' || c1rec."Local Bol" || ',' || c1rec."Local ETA"||','
--                        || c1rec."Scheduled Convoy" || ',' || c1rec."Scheduled Convoy Date" 
--                        );
  
  utl_file.put_line(f, buffer=>'"'||c1rec."Delivery No"||'","'||c1rec."PO Rno"||'","'||c1rec."Purchase Order" ||'","'|| c1rec."PO Item No" || '","' || c1rec."Material No"||'","'
                        || c1rec."Invoice"||'","'||c1rec."Quantity"||'","'||c1rec."Unit"||'","'||c1rec."GRN"||'","'||c1rec."Receipted Date"||'","'||c1rec."Vendor"|| '","'
                        || c1rec."Log No" ||'","'||c1rec."Delivery Item"||'","'||c1rec."Warehouse Destination"||'","'||c1rec."Current Location"||'","'||c1rec."Priority"||'","'||c1rec."Mode"||'","'
                        || c1rec."Container"||'","'|| c1rec."Seal"||'","'||c1rec."HAWB"||'","'||c1rec."Intl Ship ID"||'","'||c1rec."Intl Ship/MAWB"||'","'||c1rec."Intl Voyage"||'","'||c1rec."Intl ETD"||'","'||c1rec."Intl ETA"||'","'
                        || c1rec."Intl Port of Loading"||'","'||c1rec."Intl Port of Discharge"||'","'||c1rec."Intl Bol"||'","'||c1rec."Customs Cleared Date"||'","'||c1rec."Local Ship ID"||'","'||c1rec."Local Ship"||'","'
                        || c1rec."Local Voyage"||'","'||c1rec."Local Bol"||'","'||c1rec."Local ETD"||'","'||c1rec."Local ETA"||'","'||c1rec."Local Port of Loading"||'","'||c1rec."Local Port of Discharge"||'","'
                        || c1rec."Scheduled Convoy" || '","' || c1rec."Scheduled Convoy Date"|| '","' ||c1rec."ISO Container Type"||'","'||c1rec."Container Owner"|| '","' ||c1rec."Cargo"|| '","' 
                        || c1rec."Description"||'","'||c1rec."Gross Weight in Tonne"||'","'||c1rec."Cargo Volume"||'","'||c1rec."Consignee"||'","'||c1rec."Hazardous Codes"||'","' 
                        || c1rec."Controlling Office"||'","'||c1rec."packing Status"||'"'
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
--  utl_file.put_line(f2, buffer=>'Delivery No,PO Rno,Purchase Order,PO Item No,Material No,Invoice,Quantity,Unit,GRN,Receipted Date,'||
--                                'Vendor,Log No,Delivery Item,Warehouse Destination,Current Location,Priority,Mode,Container,Seal,HAWB,'||
--                                'Intl Ship ID,Intl Ship/MAWB,Intl Voyage,Intl Line No,Intl ETA,Intl Bol,Customs Cleared Date,Local Ship ID,'||
--                                'Local Ship,Local Voyage,Local Line No,Local Bol,Local ETA,Scheduled Convoy,Scheduled Convoy Date');

--  utl_file.put_line(f2, buffer=>'Delivery No,PO Rno,Purchase Order,PO Item No, Material No, Invoice, Quantity, Unit, GRN, Receipted Date, Vendor, Log No, Delivery Item,'||
--                               'Warehouse Destination,Current Location, Priority,Mode,Container,Seal,HAWB,Intl Ship ID, Intl Ship/MAWB, Intl Voyage, '||
--                               'Intl ETD, Intl ETA,Intl Port of Loading,Intl Port of Discharge,Intl Bol,Customs Cleared Date,Local Ship ID,Local Ship, '||
--                               'Local Voyage,Local Bol,Local ETD,Local ETA,Local Port of Loading,Local Port of Discharge,Scheduled Convoy,Scheduled Convoy Date, '||
--                               'ISO Container Type,Container Owner,Cargo,Description,Gross Weight in Tonne,Cargo Volume, Consignee, Hazardous Codes, '||
--                               'Controlling Office, packing Status');        

   utl_file.put_line(f2, buffer=>'"Delivery No","PO Rno","Purchase Order","PO Item No","Material No","Invoice","Quantity","Unit","GRN","Receipted Date","Vendor","Log No","Delivery Item","'||
                               'Warehouse Destination","Current Location","Priority","Mode","Container","Seal","HAWB","Intl Ship ID","Intl Ship/MAWB"," Intl Voyage","'||
                               'Intl ETD"," Intl ETA","Intl Port of Loading","Intl Port of Discharge","Intl Bol","Customs Cleared Date","Local Ship ID","Local Ship","'||
                               'Local Voyage","Local Bol","Local ETD","Local ETA","Local Port of Loading","Local Port of Discharge","Scheduled Convoy","Scheduled Convoy Date","'||
                               'ISO Container Type","Container Owner","Cargo","Description","Gross Weight in Tonne","Cargo Volume"," Consignee"," Hazardous Codes","'||
                               'Controlling Office","packing Status"');     

  ctr1 := 0;
  for c1rec in c1 loop
--  utl_file.put_line(f2, buffer=>c1rec."Delivery No"||','||c1rec."PO Rno" ||','|| c1rec."Purchase Order" || ',' || c1rec."PO Item No" || ',' || c1rec."Material No" || ','
--                        || c1rec."Invoice" || ',' || c1rec."Quantity" || ',' || c1rec."Unit" || ','||c1rec."GRN"||','||c1rec."Receipted Date"||',"'||c1rec."Vendor"|| '",'
--                        ||  c1rec."Log No" || ',' || c1rec."Delivery Item" || ',' || c1rec."Warehouse Destination" || ',' || c1rec."Current Location" || ',' || c1rec."Priority" || ',' || c1rec."Mode" || ','
--                        || c1rec."Container" || ',' || c1rec."Seal" || ',' || c1rec."HAWB"||','||c1rec."Intl Ship ID"||',' ||c1rec."Intl Ship/MAWB" || ',' || c1rec."Intl Voyage" || ',' || c1rec."Intl Line No" || ',' || c1rec."Intl ETA"||','
--                        || c1rec."Intl Bol" || ',' || c1rec."Customs Cleared Date" || ','||c1rec."Local Ship ID"||',' || c1rec."Local Ship" || ','||c1rec."Local Voyage" ||',' || c1rec."Local Line No" || ',' || c1rec."Local Bol" || ',' || c1rec."Local ETA"||','
--                        || c1rec."Scheduled Convoy" || ',' || c1rec."Scheduled Convoy Date" 
--                        );
                        
-- utl_file.put_line(f2, buffer=>c1rec."Delivery No"||'|'||c1rec."PO Rno"||'|'||c1rec."Purchase Order" ||'|'|| c1rec."PO Item No" || '|' || c1rec."Material No" || '|'
--                        || c1rec."Invoice" || '|' || c1rec."Quantity" || '|' || c1rec."Unit" || '|'||c1rec."GRN"||'|'||c1rec."Receipted Date"||'|"'||c1rec."Vendor"|| '"|'
--                        ||  c1rec."Log No" || '|' || c1rec."Delivery Item" || '|' || c1rec."Warehouse Destination" ||'|'|| c1rec."Current Location"||'|'|| c1rec."Priority" || '|' || c1rec."Mode" || '|'
--                        || c1rec."Container" || '|' || c1rec."Seal" || '|' || c1rec."HAWB" ||'|'||c1rec."Intl Ship ID"||'|' || c1rec."Intl Ship/MAWB" || '|' || c1rec."Intl Voyage" ||'|'|| c1rec."Intl ETD"||'|'|| c1rec."Intl ETA"||'|'
--                        || c1rec."Intl Port of Loading"||'|'||c1rec."Intl Port of Discharge"||'|'||c1rec."Intl Bol"||'|'||c1rec."Customs Cleared Date"||'|'||c1rec."Local Ship ID"||'|'||c1rec."Local Ship"||'|'
--                        || c1rec."Local Voyage"||'|'||c1rec."Local Bol"||'|'||c1rec."Local ETD"||'|'||c1rec."Local ETA"||'|'||c1rec."Local Port of Loading"||'|'||c1rec."Local Port of Discharge"||'|'
--                        || c1rec."Scheduled Convoy" ||'|' || c1rec."Scheduled Convoy Date"|| '|' ||c1rec."ISO Container Type"|| '|"' ||c1rec."Container Owner"|| '"|' 
--                        ||c1rec."Cargo"||'|"'|| c1rec."Description" || '"|' ||c1rec."Gross Weight in Tonne" || '|' ||c1rec."Cargo Volume" ||'|"' ||c1rec."Consignee" || '"|"' ||c1rec."Hazardous Codes" || '"|' 
--                        || c1rec."Controlling Office" ||'|'||c1rec."packing Status"
--                        );    
   utl_file.put_line(f2, buffer=>'"'||c1rec."Delivery No"||'","'||c1rec."PO Rno"||'","'||c1rec."Purchase Order" ||'","'|| c1rec."PO Item No" || '","' || c1rec."Material No"||'","'
                        || c1rec."Invoice"||'","'||c1rec."Quantity"||'","'||c1rec."Unit"||'","'||c1rec."GRN"||'","'||c1rec."Receipted Date"||'","'||c1rec."Vendor"|| '","'
                        || c1rec."Log No" ||'","'||c1rec."Delivery Item"||'","'||c1rec."Warehouse Destination"||'","'||c1rec."Current Location"||'","'||c1rec."Priority"||'","'||c1rec."Mode"||'","'
                        || c1rec."Container"||'","'|| c1rec."Seal"||'","'||c1rec."HAWB"||'","'||c1rec."Intl Ship ID"||'","'||c1rec."Intl Ship/MAWB"||'","'||c1rec."Intl Voyage"||'","'||c1rec."Intl ETD"||'","'||c1rec."Intl ETA"||'","'
                        || c1rec."Intl Port of Loading"||'","'||c1rec."Intl Port of Discharge"||'","'||c1rec."Intl Bol"||'","'||c1rec."Customs Cleared Date"||'","'||c1rec."Local Ship ID"||'","'||c1rec."Local Ship"||'","'
                        || c1rec."Local Voyage"||'","'||c1rec."Local Bol"||'","'||c1rec."Local ETD"||'","'||c1rec."Local ETA"||'","'||c1rec."Local Port of Loading"||'","'||c1rec."Local Port of Discharge"||'","'
                        || c1rec."Scheduled Convoy" || '","' || c1rec."Scheduled Convoy Date"|| '","' ||c1rec."ISO Container Type"||'","'||c1rec."Container Owner"|| '","' ||c1rec."Cargo"|| '","' 
                        || c1rec."Description"||'","'||c1rec."Gross Weight in Tonne"||'","'||c1rec."Cargo Volume"||'","'||c1rec."Consignee"||'","'||c1rec."Hazardous Codes"||'","' 
                        || c1rec."Controlling Office"||'","'||c1rec."packing Status"||'"'
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
