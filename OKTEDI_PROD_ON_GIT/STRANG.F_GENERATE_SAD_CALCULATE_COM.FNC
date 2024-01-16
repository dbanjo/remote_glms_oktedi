CREATE OR REPLACE function STRANG.f_generate_sad_calculate_com(colin varchar2, entryno in number, entryitem in number, tariff in varchar2, rnumb in integer default null, vtot in number)
 return varchar2
as

 cursor c1(entryno number, entryitem number, tariff varchar2) is
  select /*+ ALL_ROWS */ distinct description
  from lov l1, detailrs dr, pos p
  where l1.cola = tariff and
        dr.entry_no_com = entryno and
		p.entry_item = entryitem and
        p.inventoryno = l1.code and
        dr.deliveryno = p.deliveryno and
        lov_name = 'INVENT';


 cursor c2(entryno number, entryitem number, tariff varchar2) is
  select /*+ ALL_ROWS */ *
  from ships_airway
  where ship_id in
   (select ship_id
   from movements m, detailrs dr, pos p, lov l1
   where entry_no_com = entryno and
         dr.deliveryno = p.deliveryno and
		 p.entry_item = entryitem and
         p.inventoryno = l1.code and
         l1.lov_name = 'INVENT' and
         l1.cola = tariff and
         m.movement_no = dr.movement_no and
         nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
   );

 cursor c3( entryno number, entryitem number, tariff varchar2 ) is
  select /*+ ALL_ROWS */ nvl(sum(amount),0) sm
  from pos p, detailrs dr, lov l1
  where p.deliveryno = dr.deliveryno and
         dr.deliveryno = p.deliveryno and
		 p.entry_item = entryitem and
         p.inventoryno = l1.code and
         l1.lov_name = 'INVENT' and
         l1.cola = tariff and
         dr.entry_no_com = entryno;

 cursor c4( entryno number ) is
  select /*+ ALL_ROWS */ ctry_countrycode
  from pos p, detailrs dr
  where p.deliveryno = dr.deliveryno and
         dr.deliveryno = p.deliveryno and
         dr.entry_no_com = entryno;

 cursor c5( tariff varchar2 ) is
 select  /*+ ALL_ROWS */ *
 from lov
 where lov_name = 'TARIFF' and
       code = tariff;

 cursor c6(entryno number, entryitem number, tariff varchar2 ) is
  select /*+ ALL_ROWS */ sum(revton * s.freight) sm
  from detailrs dr, movements m, ships_airway s, pos p, lov l1
  where dr.entry_no_com = entryno and
        m.movement_no = dr.movement_no and
        dr.deliveryno = p.deliveryno and
		p.entry_item = entryitem and
        p.inventoryno = l1.code and
        l1.lov_name = 'INVENT' and
        l1.cola = tariff and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        m.ship_id = s.ship_id;

 /*
 cursor c7( entryno number, tariff varchar2 ) is
  select sum(p.qty) qty
  from pos p, detailrs dr, lov l1, lov l2
  where p.deliveryno = dr.deliveryno and
         dr.deliveryno = p.deliveryno and
         p.inventoryno = l1.code and
         l1.lov_name = 'INVENT' and
         l2.lov_name = 'TARIFF' and
         l1.cola = l2.code and
         l2.code = tariff and
         dr.entry_no_com = entryno
 group by l2.cola;
 */

 cursor c7( entryno number, entryitem number, tariff varchar2 ) is
  select /*+ ALL_ROWS */ sum(p.qty) qty
  from pos p, lov i
  where p.inventoryno = i.code and
		p.entry_item = entryitem and
        i.lov_name = 'INVENT' and
        i.cola = tariff and
        p.deliveryno in
        (select distinct deliveryno
         from detailrs
         where entry_no_com = entryno);

 cursor c7a( tariff varchar2 ) is
  select /*+ ALL_ROWS */ l2.cola
  from lov l2
  where l2.lov_name = 'TARIFF' and
        l2.code = tariff;

-- BELOW COULD BE USED FOR NETT MASS IF REQUIRED
  cursor c7bb( entryno number ) is
  select /*+ ALL_ROWS */ sum(dr.partweight) weight
  from detailrs dr
  where dr.entry_no_com = entryno;

 cursor c7b( entryno number ) is
 select sum(nvl(m.sumweight,0)+nvl(m.tare,0)) weight
  from movements m
  where
  (m.movement_no,m.seal) in
  (select distinct m1.movement_no,m1.seal
  from
  detailrs dr, movements m1
  where
  dr.entry_no_com = entryno and
  dr.movement_no = m1.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m1.seal,'|'));


 cursor c7c( tariff varchar2 ) is
  select /*+ ALL_ROWS */ l2.description,l2.colc, l2.colg, l2.colh
  from lov l2
  where l2.lov_name = 'TARIFF' and
        l2.code = tariff;

 cursor c7d( entryno number, entryitem number, tariff varchar2 ) is
  select /*+ ALL_ROWS */ sum(p.excise_qty) excise_qty
  from pos p, lov i
  where p.inventoryno = i.code and
		p.entry_item = entryitem and
        i.lov_name = 'INVENT' and
        i.cola = tariff and
        p.deliveryno in
        (select distinct deliveryno
         from detailrs
         where entry_no_com = entryno);

 cursor c8( entryno number ) is
  select /*+ ALL_ROWS */ *
  from ships_airway
  where ship_id in ( select ship_id
                     from movements m, detailrs dr
                     where entry_no_com = entryno and
                           m.movement_no = dr.movement_no and
                           nvl(m.seal,'|') = nvl(dr.camov_seal,'|'));

 cursor c9(entryno number) is
   select /*+ ALL_ROWS */ distinct c.customer, r.curr, d.exrate
   from receivals r, detailrs dr, customers c, duty d
   where dr.entry_no_com = entryno and
         d.entry_no = dr.entry_no_com and
         dr.deliveryno = r.deliveryno and
         nvl(r.supplier_customer_id_com,0) = c.customer_id and
         c.customer_type = 'SUPPLIER';

 cursor c10(entryno number) is
   select /*+ ALL_ROWS */ distinct c.customer, c.levy_rate, c.vat, c.rate, c.customer_id, d.exrate
   from receivals r, detailrs dr, customers c, duty d
   where dr.entry_no_com = entryno and
         d.entry_no = dr.entry_no_com and
         dr.deliveryno = r.deliveryno and
         nvl(r.cust_customer_id,0) = c.customer_id and
         c.customer_type = 'CUSTOMER';


cursor c17( entryno number, rfrom integer, rto integer ) is
select entryitem, tariff, description, colc
from
(
 select rownum rnumb, entryitem, tariff, description, colc
 from
 (
  select /*+ ALL_ROWS */ distinct p.entry_item entryitem, l1.cola tariff, l2.description, l2.colc
  from pos p, lov l1, lov l2
  where l1.lov_name = 'INVENT' and
        l2.lov_name = 'TARIFF' and
        l1.cola = l2.code and
        l1.code = p.inventoryno and
        p.deliveryno in
         (select distinct deliveryno
          from detailrs dr
         where dr.entry_no_com = entryno
        )
  )
)
where rnumb >= rfrom and rnumb < rto;

cursor c18( entryno number ) is
select entryitem, tariff, description, colc
from
(
 select rownum rnumb, entryitem, tariff, description, colc
 from
 (
  select /*+ ALL_ROWS */ distinct p.entry_item entryitem, l1.cola tariff, l2.description, l2.colc
  from pos p, lov l1, lov l2
  where l1.lov_name = 'INVENT' and
        l2.lov_name = 'TARIFF' and
        l1.cola = l2.code and
        l1.code = p.inventoryno and
        p.deliveryno in
         (select distinct deliveryno
          from detailrs dr
         where dr.entry_no_com = entryno
        )
  )
);


cursor c21( entryno number ) is
 select /*+ ALL_ROWS */  max( p.entry_item ) tot
 from pos p, lov l1, detailrs dr
 where dr.entry_no_com = entryno and
       dr.deliveryno = p.deliveryno and
       p.inventoryno = l1.code and
       l1.lov_name = 'INVENT';

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c7arec		c7a%ROWTYPE;
 c7brec		c7b%ROWTYPE;
 c7bbrec	c7bb%ROWTYPE;
 c7crec		c7c%ROWTYPE;
 c7drec		c7d%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c9rec		c9%ROWTYPE;
 c10rec		c10%ROWTYPE;
 c21rec		c21%ROWTYPE;
 pagefrom	integer;
 pageto		integer;
 b1		number;
 b2		number;
 b3		number;
 b4		number;
 b5		number;
 temptot	number;
 exrate		varchar2(100);
 xb1		varchar2(100);
 xb2		varchar2(100);
 xb3		varchar2(100);
 xb4		varchar2(100);
 xb5		varchar2(100);
 tmp 		varchar2(32767);
 tmp2 		varchar2(32767);
 tmp3		varchar2(32767);
 tmp4 		number;
 tmp5		number;
 tmp6 		number;
 tmp7		number;
 tmp8		varchar2(32767);
 tmp9 		varchar2(32767);
 tmp10		varchar2(32767);
 ttl		number;
 v_vat          number;
 v_levy		number;
 function ispartshipment( entryno number )
  return boolean
 is

   cursor c1(entryno number) is select * from duty where entry_no = entryno;
   c1rec  c1%ROWTYPE;
 begin
  open c1(entryno);
  fetch c1 into c1rec;
  close c1;
  if nvl(c1rec.previous_entry_no,0) > 0
   then
    return( TRUE );
   else
    return( FALSE );
  end if;
 end ispartshipment;

 function tot( entryno number, entryitem number, tariff varchar2, ctype in varchar2 default 'CURR' )
  return number
 is

   cursor c1(entryno number) is select * from duty where entry_no = entryno;
   /*
   cursor c2(entryno number, tariff varchar2 ) is
    select sum(nvl(tamount,0))/count(dr.entry_no) tot
    from pos p, detailrs dr, lov l1
    where dr.deliveryno = p.deliveryno and
          dr.entry_no_com = entryno and
          l1.lov_name = 'INVENT' and
          l1.code = p.inventoryno and
          l1.cola = tariff;
   */
   cursor c2(entryno number, entryitem number, tariff varchar2 ) is
    select sum(nvl(tamount,0)) tot
    from pos p, lov l1
    where l1.lov_name = 'INVENT' and
          l1.code = p.inventoryno and
          l1.cola = tariff and
		  p.entry_item = entryitem and
          p.deliveryno in
          (select distinct dr.deliveryno
           from detailrs dr
           where  dr.entry_no_com = entryno );

   c1rec c1%ROWTYPE;
   c2rec c2%ROWTYPE;

 begin
    open c1(entryno);
    fetch c1 into c1rec;
    close c1;
    open c2(entryno, entryitem, tariff);
    fetch c2 into c2rec;
    close c2;
    if ctype = 'CURR'
     then
      return(round(c1rec.ratio_factor * c2rec.tot,2));
     else
      return(round(c2rec.tot,2));
    end if;
 end;

begin
if colin = 'ZZ_2_2'
 then
 tmp := NULL;
 if tariff is not null
 then
  open c7d(entryno,entryitem, tariff);
   fetch c7d into c7drec;
  close c7d;
  open c7c( tariff );
   fetch c7c into c7crec;
  close c7c;
  if to_number(c7crec.colh) > 0
  then
   if c7drec.excise_qty is null or c7drec.excise_qty = 0 then
     tmp:= 1;
   else
     tmp:= c7drec.excise_qty;
   end if;
   tmp := to_char((to_number(c7crec.colh)*tmp),'999999990.99');
  end if;
 end if;
elsif colin in ('ZZ', 'ZZ_1', 'ZZ_2', 'ZZ_3')
 then
  tmp:=NULL;
  tmp2 := null;
  tmp3 := null;
  tmp9 := null;
  if tariff is not null
   then
    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(entryno,entryitem,tariff);
    fetch c2 into c2rec;
    close c2;
    if to_number(nvl(c5rec.colc,'0') ) > 0
     then
      tmp2 := to_char(to_number(c5rec.colc),'990.999');
      temptot := tot(entryno,entryitem,tariff);
      tmp3 := to_char(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2),'999999990.99');
      tmp9 := '1';
    end if;
  end if;

 case colin
 when 'ZZ_1' then tmp := trim(tmp2);
 when 'ZZ_2' then tmp := trim(tmp3);
 when 'ZZ_3' then tmp := trim(tmp9);
 else tmp := null;
 end case;

end if;

return( tmp );

exception
  when others then return( sqlerrm );
end f_generate_sad_calculate_com;
/


GRANT EXECUTE ON STRANG.F_GENERATE_SAD_CALCULATE_COM TO WEBSYS;
