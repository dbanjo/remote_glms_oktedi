CREATE OR REPLACE function STRANG.f_invoice_values_per_voyage( shp_id in integer )
 return varchar2
as
 cursor c1( cust_id integer, currency varchar2, shp_id integer ) is
select sum(p.tamount) po_total
from strang.pos p
where p.deliveryno in
  (select r.deliveryno
  from strang.receivals r, strang.customers c, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  m.local_ship_id = shp_id and
  r.cust_customer_id = c.customer_id and
  c.customer_id = cust_id and
  r.curr = currency);


cursor c2( shp_id integer ) is
select distinct c.customer, c.customer_id, r.curr
  from strang.receivals r, strang.customers c, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  m.local_ship_id = shp_id and
  r.cust_customer_id = c.customer_id
  order by c.customer_id asc;


 c1rec  c1%ROWTYPE;
 c2rec  c2%ROWTYPE;
 tot	number;
 retvar	varchar2(4000);

begin
 retvar := NULL;
 tot:=0;
 for c2rec in c2(shp_id) loop
  open c1(c2rec.customer_id, c2rec.curr, shp_id);
  fetch c1 into c1rec;
 close c1;
  retvar := retvar || htf.nl || c2rec.customer || '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'||c2rec.curr||'&nbsp;&nbsp;'|| nvl(to_char(c1rec.po_total,'$999,999,999.99'),'$0.00');
  tot:= tot + nvl(c1rec.po_total,0);
  end loop;
--  Not using tot because more than one currency
--  retvar := retvar || htf.nl ||  htf.nl ||  'TOTAL' ||'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'|| nvl(to_char( tot,'$999,999,999.99'),'$0.00') || htf.nl;
 return( substr( retvar,length(htf.nl)+1) );
end f_invoice_values_per_voyage;
/


GRANT EXECUTE ON STRANG.F_INVOICE_VALUES_PER_VOYAGE TO WEBSYS;
