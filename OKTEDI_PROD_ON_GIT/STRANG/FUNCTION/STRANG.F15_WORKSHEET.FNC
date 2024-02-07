CREATE OR REPLACE function STRANG.f15_worksheet( parm_id in varchar2, parm1 in varchar2, parm2 in varchar2 default null )
 return varchar2
as

 -- Parm1 = ENTRY_NO

 cursor c1( parm1 number ) is
  select /*+ ALL_ROWS */ *
  from ships_airway
  where ship_id in ( select ship_id
                     from movements m, detailrs dr
                     where entry_no = parm1 and
                           m.movement_no = dr.movement_no and
                           nvl(m.seal,'|') = nvl(dr.camov_seal,'|'));

 cursor c2( lv varchar2, cd varchar2 ) is
  select /*+ ALL_ROWS */ description
  from lov
  where lov_name = lv and
        code = cd;

 cursor c3( parm1 number ) is
  select /*+ ALL_ROWS */ *
  from movements m
  where (movement_no,nvl(m.seal,'|')) in
   (select movement_no,nvl(dr.camov_seal,'|')
    from detailrs dr
    where entry_no = parm1
   );

 cursor c4( parm1 number ) is
  select /*+ ALL_ROWS */ *
  from detailrs
  where entry_no = parm1;

 cursor c5( parm1 number ) is
  select c.customer, d.exrate, r.currdate, r.curr, c.freight, c.insurance, c.other_costs, c.vat, c.levy_rate
  from receivals r, customers c, detailrs dr, duty d
  where r.deliveryno = dr.deliveryno and
        nvl(r.cust_customer_id,0) = c.customer_id and
        c.customer_type = 'CUSTOMER' and
        dr.entry_no = d.entry_no and
        dr.entry_no = parm1;

 cursor c5a( parm1 number ) is
  select c.customer, d.exrate, r.currdate
  from receivals r, customers c, detailrs dr, duty d
  where r.deliveryno = dr.deliveryno and
        nvl(r.supplier_customer_id,0) = c.customer_id and
        c.customer_type = 'SUPPLIER' and
        dr.entry_no = d.entry_no and
        dr.entry_no = parm1;

 cursor c6( parm1 number ) is
  select /*+ ALL_ROWS */ *
  from duty
  where entry_no = parm1;

 cursor c7( entryno number ) is
 select /*+ ALL_ROWS */ sum(kvalue) kvalue, sum(duty) duty, sum(excise) excise, sum(vat) vat,sum(old_duty) old_duty
 from
 (
    select /*+ ALL_ROWS */
     distinct
       f1.tot * nvl(d.ratio_factor,1) kvalue,
       f1.tot * nvl(d.ratio_factor,1) * (nvl(to_number(t.description),0)/100) duty,
       ((f1.tot * nvl(d.ratio_factor,1)) + (f1.tot * nvl(d.ratio_factor,1) * (nvl(to_number(t.description),0)/100))) * (nvl(to_number(t.colc),0)/100) excise,
       (((f1.tot * nvl(d.ratio_factor,1)) +
        (f1.tot * nvl(d.ratio_factor,1) * (nvl(to_number(t.description),0)/100)) +
        ((f1.tot * nvl(d.ratio_factor,1)) + (f1.tot * nvl(d.ratio_factor,1) * (nvl(to_number(t.description),0)/100))) * (nvl(to_number(t.colc),0)/100)
       ) * nvl(s.vat,0)) / 100 vat,
       (t.colb * f1.tot * nvl(d.ratio_factor,1)) / 100 old_duty
from strang.lov i, strang.pos p, strang.detailrs dr, strang.duty d, strang.lov t, strang.movements m,
     strang.ships_airway s,
(
    select /*+ ALL_ROWS */ l1.cola trf, sum(nvl(tamount,0)) tot
    from strang.pos p, strang.lov l1
    where l1.lov_name = 'INVENT' and
          l1.code = p.inventoryno and
          p.deliveryno in
          (select distinct dr.deliveryno
           from strang.detailrs dr
           where  dr.entry_no = entryno )
    group by l1.cola
) f1
where i.code = p.inventoryno and
      i.lov_name = 'INVENT' and
      t.lov_name = 'TARIFF' and
      m.ship_id = s.ship_id and
      m.movement_no = dr.movement_no and
      nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
      p.deliveryno = dr.deliveryno and
      t.code = i.cola and
      d.entry_no = dr.entry_no and
      dr.entry_no = entryno and
      f1.trf = i.cola
group by i.description, f1.tot, dr.line_no, t.code, d.duty, p.ctry_countrycode, p.unit_unitused,t.colb,d.ratio_factor, t.description,t.colc, s.vat
);

 cursor c8( parm1 number ) is
  select /*+ ALL_ROWS */ sum(p.tamount) tamount
  from pos p
  where p.deliveryno in
   (select distinct dr.deliveryno
    from detailrs dr
    where entry_no = parm1
   );


cursor c9( entryno number ) is
 select /*+ ALL_ROWS */ sum(revenue_tonne(partweight,partvolume)) sumf
 from detailrs
 where entry_no = entryno;

cursor c10(entryno number, tariff varchar2) is
  select /*+ ALL_ROWS */ distinct description
  from lov l1, detailrs dr, pos p
  where l1.cola = tariff and
        dr.entry_no = entryno and
        p.inventoryno = l1.code and
        dr.deliveryno = p.deliveryno and
        lov_name = 'INVENT';

cursor c11(entryno number) is
  select /*+ ALL_ROWS */ min(line_no) mn, max(line_no) mx
  from detailrs
  where entry_no = entryno;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c5arec		c5a%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c9rec		c9%ROWTYPE;
 c11rec		c11%ROWTYPE;
 tmp		varchar2(32767);

begin
 open c1(parm1);
 fetch c1 into c1rec;
 close c1;
 open c3(parm1);
 fetch c3 into c3rec;
 close c3;
 open c4(parm1);
 fetch c4 into c4rec;
 close c4;
 open c5(parm1);
 fetch c5 into c5rec;
 close c5;
 open c5a(parm1);
 fetch c5a into c5arec;
 close c5a;
 open c6(parm1);
 fetch c6 into c6rec;
 close c6;

 if parm_id = 'D1'
  then
   return( to_char(sysdate,'DD Month YYYY') );
 elsif parm_id = 'D2'
  then
   return( parm1 );
 elsif parm_id = 'D3'
  then
   return( c5rec.customer );
 elsif parm_id = 'D4'
  then
   return( to_char(c1rec.estarrive,'DD-MON-YYYY') );
 elsif parm_id = 'D5'
  then
   for c4rec in c4(parm1) loop
    tmp := tmp || ', ' || c4rec.detaildesc;
   end loop;
   return( substr( tmp, 3) );
 elsif parm_id = 'DA'
  then
   return( c5arec.customer );
 elsif parm_id = 'DB'
  then
   open c11(parm1);
   fetch c11 into c11rec;
   close c11;
   if c11rec.mn = c11rec.mx
    then
     return( c11rec.mn );
    else
     return( c11rec.mn || ' - ' || c11rec.mx );
   end if;
 elsif parm_id = 'DC'
  then
   return( c3rec.bol );
 elsif parm_id = 'DD'
  then
   open c2('LOCATIONS',c1rec.portdisc);
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'DE'
  then
   return( c1rec.shipname );
 elsif parm_id = 'DF'
  then
   return( c1rec.voy );
 elsif parm_id = 'DG'
  then
   return( to_char(c1rec.estarrive,'DD-MON-YYYY') );
 elsif parm_id = 'DH'
  then
   open c2('LOCATIONS',c1rec.portdisc);
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'DI'
  then
   open c2('COUNTRIES',c1rec.shipcountry);
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'DK'
  then
   open c2('LOCATIONS',c1rec.portload);
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'DL'
  then
   -- Exporters Name
   return( c5arec.customer );
 elsif parm_id = 'DM'
  then
   open c8(parm1);
   fetch c8 into c8rec;
   close c8;
   return( to_char(c8rec.tamount,'999,999,990.99') );
 elsif parm_id = 'DN'
  then
   return( to_char(c6rec.correct_freight  * nvl(c5arec.exrate,1),'99999999.99') );
 elsif parm_id = 'DO'
  then
   open c8(parm1);
   fetch c8 into c8rec;
   close c8;
   return( to_char((c5rec.insurance/100) * c8rec.tamount,'999,999,990.99') );
 elsif parm_id = 'DP'
  then
   open c8(parm1);
   fetch c8 into c8rec;
   close c8;
   return( to_char((c5rec.other_costs/100) * c8rec.tamount,'999,999,990.99') );
 elsif parm_id = 'DQ'
  then
   return( c5rec.curr );
 elsif parm_id = 'DR'
  then
   return( round(c5rec.exrate,4) );
 elsif parm_id = 'DS'
  then
   open c6(parm1);
   fetch c6 into c6rec;
   close c6;
   return( c6rec.ratio_factor );
 elsif parm_id = 'DT'
  then
   return( c5rec.vat );
 elsif parm_id = 'DU'
  then
   return( 'DU' );

 elsif parm_id = 'VAL1'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   return( to_char(c7rec.old_duty,'999,999,990.99') );

 elsif parm_id = 'VAL2'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   return( to_char(c7rec.kvalue * (1.5/100),'999,999,990.99') );

 elsif parm_id = 'VAL3'
  then
   return( to_char(c6rec.duty + c6rec.excise + c6rec.vat, '999,999,990.99'));
   /*
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   return( to_char(c7rec.duty + c7rec.excise + c7rec.vat,'999,999,990.99') );
   */

 elsif parm_id = 'VAL4'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   return( to_char((c7rec.kvalue * (1.5/100)) + c7rec.old_duty,'999,999,990.99') );

 elsif parm_id = 'VAL5'
  then
   if c6rec.pvariance > 0
    then
     return( 'The Current Method is ' || to_char(c6rec.pvariance,'999,999,990.99') || ' Greater than the Previous Method.' );
   elsif c6rec.pvariance = 0
    then
     return( 'There is no difference between the Current and Previous Method.' );
    else
     return( 'The Current Method is ' || to_char(abs(c6rec.pvariance),'999,999,990.99') || ' Lower than the Previous Method.' );
   end if;
   /*
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   if (c7rec.duty + c7rec.excise + c7rec.vat) < ((c7rec.kvalue * (1.5/100)) + c7rec.old_duty)
    then
     return( 'The Current Method is ' || to_char(((c7rec.kvalue * (1.5/100)) + c7rec.old_duty) - (c7rec.duty + c7rec.excise + c7rec.vat),'999,999,990.99') || ' Lower than the Previous Method.' );
   elsif (c7rec.duty + c7rec.excise + c7rec.vat) = ((c7rec.kvalue * (1.5/100)) + c7rec.old_duty)
    then
     return( 'There is no difference between the Current and Previous Method.' );
    else
     return( 'The Current Method is ' || to_char((c7rec.duty + c7rec.excise + c7rec.vat) - ((c7rec.kvalue * (1.5/100)) + c7rec.old_duty),'999,999,990.99') || ' Greater than the Previous Method.' );
   end if;
   */

 elsif parm_id = 'VAL6'
  then
   for c10rec in c10(parm1,parm2) loop
    tmp := tmp || ', ' || c10rec.description;
   end loop;
   return( substr(tmp,length(', ')+1));

 end if;

end f15_worksheet;
/


GRANT EXECUTE ON STRANG.F15_WORKSHEET TO WEBSYS;
