CREATE OR REPLACE function WEBSYS.f_fob_country_list ( p_container in varchar2, p_seal in varchar2 default null, tariff_category in varchar2, tariff_group varchar2 )
return varchar2
as

cursor c1(vmov varchar2, vseal varchar2, vtariff_category varchar2, vtariff_group varchar2 ) is
 select  ctry_countrycode, count(*) cnt
 from 
 (select /*+ ALL_ROWS */ distinct r.deliveryno, p.recno, p.po, p.po_item_no
     , p.supinv, p.qty p_qty
	 , f_calc_poitem_weight (dr.movement_no, dr.deliveryno, dr.itemno, p.recno) partweight
	 , rtrim(t.COLA,'-') unit_unitused
	 , p.inventoryno invent, i.description, i.coli||' '||t.description||'%' tariff 
	 , p.ahecc 
	 , p.tariff_category
	 , p.tariff_group
	 , p.ctry_countrycode
	 , p.state
     , nvl(p.amount,0) amount, nvl(p.gst,0) gst
	 , (nvl(p.tamount,0)+nvl(p.delivery_charge,0)) tam_dc, r.curr, c.customer
  from strang.pos p,strang.receivals r, strang.customers c, strang.lov i, strang.lov t,
       strang.customers c1, strang.detailrs dr, strang.movements m, strang.ships_airway s
 where dr.movement_no = m.movement_no and
       nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
       m.ship_id = s.ship_id and
       dr.deliveryno = p.deliveryno and
       nvl(r.supplier_customer_id,0) = c.customer_id and
       i.lov_name = 'INVENT' and
       t.lov_name = 'AU_TARIFF' and
       c.customer_type = 'SUPPLIER' and
       nvl(r.cust_customer_id,0) = c1.customer_id and
       p.deliveryno = r.deliveryno and
       nvl(p.inventoryno,'NOT ALLOCATED') = i.code and
       nvl(i.coli,'NOT ALLOCATED') = t.code and
       p.tariff_category = vtariff_category and 
       p.tariff_group = vtariff_group and
       m.movement_no = vmov and
	   nvl(m.seal,'|') = nvl(vseal, '|')
 union
 select /*+ ALL_ROWS */ distinct r.deliveryno, p.recno, p.po, p.po_item_no
     , p.supinv, p.qty p_qty
     , f_calc_poitem_weight (dr.movement_no, dr.deliveryno, dr.itemno, p.recno) partweight
	 , null
	 , p.inventoryno invent, 'NOT ALLOCATED' description, 'NOT ALLOCATED' tariff
	 , p.ahecc 
	 , p.tariff_category
	 , p.tariff_group
	 , p.ctry_countrycode
     , p.state	 
     , nvl(p.amount,0) amount, nvl(p.gst,0) gst
	 , (nvl(p.tamount,0)+nvl(p.delivery_charge,0)) tam_dc, r.curr, c.customer
from strang.pos p,strang.receivals r, strang.customers c,
strang.customers c1, strang.detailrs dr, strang.movements m, strang.ships_airway s
where dr.movement_no = m.movement_no and
      nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
      m.ship_id = s.ship_id and
      dr.deliveryno = p.deliveryno and
      nvl(r.supplier_customer_id,0) = c.customer_id and
      c.customer_type = 'SUPPLIER' and
      nvl(r.cust_customer_id,0) = c1.customer_id and
      p.deliveryno = r.deliveryno and
      p.inventoryno is not null and
      nvl(p.inventoryno,'xxxx') not in (select code from strang.lov where lov_name = 'INVENT')and
      p.tariff_category = vtariff_category and 
      p.tariff_group = vtariff_group and
      m.movement_no = vmov and
	  nvl(m.seal,'|') = nvl(vseal, '|')
union
select /*+ ALL_ROWS */ distinct r.deliveryno, p.recno, p.po, p.po_item_no
     , p.supinv, p.qty p_qty
	 , f_calc_poitem_weight (dr.movement_no, dr.deliveryno, dr.itemno, p.recno) partweight
	 , null
	 , p.inventoryno invent, i.description, 'NOT ALLOCATED' tariff
	 , p.ahecc 
	 , p.tariff_category
	 , p.tariff_group
	 , p.ctry_countrycode,
	   p.state,
       nvl(p.amount,0) amount, nvl(p.gst,0) gst,  (nvl(p.tamount,0)+nvl(p.delivery_charge,0)) tam_dc, r.curr, c.customer
     from strang.pos p,strang.receivals r, strang.customers c,
strang.customers c1, strang.detailrs dr, strang.movements m, strang.lov i, strang.ships_airway s
where dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  m.ship_id = s.ship_id and
  dr.deliveryno = p.deliveryno and
  nvl(r.supplier_customer_id,0) = c.customer_id and
  c.customer_type = 'SUPPLIER' and
  nvl(r.cust_customer_id,0) = c1.customer_id and
  p.deliveryno = r.deliveryno and
  i.lov_name = 'INVENT' and
  p.inventoryno = i.code and
  nvl(i.coli,'xxxxx') not in (select code from strang.lov where lov_name='AU_TARIFF')and
  p.tariff_category = vtariff_category and 
  p.tariff_group = vtariff_group and
  m.movement_no = vmov and
  nvl(m.seal,'|') = nvl(vseal, '|')) tmp
  group by ctry_countrycode
  order by cnt desc;
  
  vcountry varchar2(1000);
  vcounter integer := 0;
  c1rec	c1%ROWTYPE;
 begin

    for c1rec in c1( p_container, p_seal, tariff_category, tariff_group ) loop
      vcounter := vcounter + 1;
     if (vcountry is null) then
       vcountry := c1rec.ctry_countrycode;
      else
       vcountry := vcountry ||' '||c1rec.ctry_countrycode;
     end if;
     
      if vcounter = 4 then 
         return vcountry; 
         exit;
      end if;
    end loop;
    
    return vcountry ;
 exception
  when others then htp.p( sqlerrm );
 end f_fob_country_list;
/
