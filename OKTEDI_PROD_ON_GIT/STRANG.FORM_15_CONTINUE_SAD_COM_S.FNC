CREATE OR REPLACE function STRANG.form_15_continue_sad_com_s(colin varchar2, entryno in number, entryitem in number, tariff in varchar2, rnumb in integer default null, vtot in number)
 return varchar2
as

 cursor c1(entryno number, entryitem number, tariff varchar2) is
  select /*+ ALL_ROWS */ distinct description
  from lov l1, detailrs dr, pos p
  where l1.cola = tariff and
        dr.entry_no = entryno and
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
   where entry_no = entryno and
         dr.deliveryno = p.deliveryno and
         p.inventoryno = l1.code and
  		 p.entry_item = entryitem and
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
         dr.entry_no = entryno;

 cursor c4( entryno number ) is
  select /*+ ALL_ROWS */ ctry_countrycode
  from pos p, detailrs dr
  where p.deliveryno = dr.deliveryno and
         dr.deliveryno = p.deliveryno and
         dr.entry_no = entryno;

 cursor c5( tariff varchar2 ) is
 select  /*+ ALL_ROWS */ *
 from lov
 where lov_name = 'TARIFF' and
       code = tariff;

 cursor c6(entryno number, entryitem number, tariff varchar2 ) is
  select /*+ ALL_ROWS */ sum(revton * s.freight) sm
  from detailrs dr, movements m, ships_airway s, pos p, lov l1
  where dr.entry_no = entryno and
        m.movement_no = dr.movement_no and
        dr.deliveryno = p.deliveryno and
  		p.entry_item = entryitem and
        p.inventoryno = l1.code and
        l1.lov_name = 'INVENT' and
        l1.cola = tariff and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        m.ship_id = s.ship_id;

 /*
 cursor c7( entryno number, entryitem number, tariff varchar2 ) is
  select sum(p.qty) qty
  from pos p, detailrs dr, lov l1, lov l2
  where p.deliveryno = dr.deliveryno and
         dr.deliveryno = p.deliveryno and
         p.inventoryno = l1.code and
         l1.lov_name = 'INVENT' and
         l2.lov_name = 'TARIFF' and
         l1.cola = l2.code and
         l2.code = tariff and
         dr.entry_no = entryno
 group by l2.cola;
 */

 cursor c7( entryno number, entryitem number, tariff varchar2 ) is
  select /*+ ALL_ROWS */ sum(p.qty) qty
  from pos p
  where p.entry_item = entryitem and
        p.deliveryno in
        (select distinct deliveryno
         from detailrs
         where entry_no = entryno);

 cursor c7i( entryno number, entryitem number, tariff varchar2 ) is
  select cola
  from strang.lov l
  where l.code = tariff and
        l.lov_name = 'TARIFF';

 cursor c7a( tariff varchar2 ) is
  select /*+ ALL_ROWS */ l2.cola
  from lov l2
  where l2.lov_name = 'TARIFF' and
        l2.code = tariff;

-- BELOW COULD BE USED FOR NETT MASS IF REQUIRED
 cursor c7bb( entryno number ) is
  select /*+ ALL_ROWS */ sum(dr.partweight) weight
  from detailrs dr
  where dr.entry_no = entryno;

 cursor c7b( entryno number ) is
 select sum(nvl(m.sumweight,0)+nvl(m.tare,0)) weight
  from movements m
  where
  (m.movement_no,m.seal) in
  (select distinct m1.movement_no,m1.seal
  from
  detailrs dr, movements m1
  where
  dr.entry_no = entryno and
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
        i.lov_name = 'INVENT' and
        i.cola = tariff and
        p.deliveryno in
        (select distinct deliveryno
         from detailrs
         where entry_no = entryno);

 cursor c8( entryno number ) is
  select /*+ ALL_ROWS */ *
  from ships_airway
  where ship_id in ( select ship_id
                     from movements m, detailrs dr
                     where entry_no = entryno and
                           m.movement_no = dr.movement_no and
                           nvl(m.seal,'|') = nvl(dr.camov_seal,'|'));

 cursor c9(entryno number) is
   select /*+ ALL_ROWS */ distinct c.customer, r.curr, d.exrate
   from receivals r, detailrs dr, customers c, duty d
   where dr.entry_no = entryno and
         d.entry_no = dr.entry_no and
         dr.deliveryno = r.deliveryno and
         nvl(r.supplier_customer_id,0) = c.customer_id and
         c.customer_type = 'SUPPLIER';

 cursor c9a(entryno number, entryitem number) is
   select /*+ ALL_ROWS */ distinct p.entry_item, c.customer supplier
   from receivals r, detailrs dr, customers c, pos p
   where dr.entry_no = entryno and
         dr.deliveryno = r.deliveryno and
         dr.deliveryno = p.deliveryno and
         p.entry_item = entryitem and
         nvl(r.supplier_customer_id,0) = c.customer_id and
         c.customer_type = 'SUPPLIER';


 cursor c10(entryno number) is
   select /*+ ALL_ROWS */ distinct c.customer, c.levy_rate, c.vat, c.rate, c.customer_id, d.exrate
   from receivals r, detailrs dr, customers c, duty d
   where dr.entry_no = entryno and
         d.entry_no = dr.entry_no and
         dr.deliveryno = r.deliveryno and
         nvl(r.cust_customer_id,0) = c.customer_id and
         c.customer_type = 'CUSTOMER';

cursor c14( entryno number, entryitem number ) is
 select /*+ ALL_ROWS */ distinct po
 from detailrs dr, pos p
 where entry_no = entryno and
       p.deliveryno = dr.deliveryno and
       p.entry_item = entryitem
 order by po;



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
         where dr.entry_no = entryno
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
         where dr.entry_no = entryno
        )
  )
) order by entryitem;


cursor c21( entryno number ) is
 select /*+ ALL_ROWS */  max( p.entry_item ) tot
 from pos p, detailrs dr
 where dr.entry_no = entryno and
       dr.deliveryno = p.deliveryno;

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c7irec		c7i%ROWTYPE;
 c7arec		c7a%ROWTYPE;
 c7brec		c7b%ROWTYPE;
 c7bbrec	c7bb%ROWTYPE;
 c7crec		c7c%ROWTYPE;
 c7drec		c7d%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c9rec		c9%ROWTYPE;
 c9arec		c9a%ROWTYPE;
 c10rec		c10%ROWTYPE;
 c14rec		c14%ROWTYPE;
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
          dr.entry_no = entryno and
          l1.lov_name = 'INVENT' and
          l1.code = p.inventoryno and
          l1.cola = tariff;
   */
   cursor c2(entryno number, entryitem number, tariff varchar2 ) is
    select sum(nvl(tamount,0)) tot
    from pos p
    where p.entry_item = entryitem and
          p.deliveryno in
          (select distinct dr.deliveryno
           from detailrs dr
           where  dr.entry_no = entryno );

   c1rec c1%ROWTYPE;
   c2rec c2%ROWTYPE;

 begin
    open c1(entryno);
    fetch c1 into c1rec;
    close c1;
    open c2(entryno,entryitem,tariff);
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
if colin = 'AX'
 then
   tmp := NULL;
elsif colin = 'AWW'
 then
   open c9a(entryno,entryitem);
   fetch c9a into c9arec;
   close c9a;
   return c9arec.supplier;
elsif colin = 'AWW_SAD'
 then
       for c14rec in c14( entryno,entryitem ) loop
         tmp := tmp || c14rec.po || ',';
        end loop;
        tmp := substr(tmp,1,length(tmp)-1) ;
      return( substr(tmp,1,50) );

elsif colin in ('CPC', 'CPC_1', 'CPC_2', 'CPC_1_1', 'CPC_1_2')
 then
  if tariff is not null
   then
    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(entryno,entryitem,tariff);
    fetch c2 into c2rec;
    close c2;
    tmp2 := tariff;
    tmp3 := f15_parameter_range_sad_com( 'AWW', entryno, null);
  else
    tmp2 := null;
    tmp3 := null;
  end if;

  case colin
  when 'CPC_1' then tmp := trim(replace(tmp2,'.'));
  when 'CPC_2' then tmp := trim(tmp3);
  when 'CPC_1_1' then tmp := nvl(c5rec.cole,'000');
  when 'CPC_1_2' then tmp := nvl(c5rec.colf,'0000');
  else tmp := null;
  end case;

elsif colin in ('CPG', 'CPG_1', 'CPG_2', 'CPG_3', 'CPG_4')
 then
  if tariff is not null
   then
    tmp2 := f15_parameter_range_sad_com( 'AWWWW', entryno, null);
    open c7(entryno,entryitem,tariff);
    fetch c7 into c7rec;
    close c7;
    open c7bb(entryno);
    fetch c7bb into c7bbrec;
    close c7bb;
    open c21(entryno);
    fetch c21 into c21rec;
    close c21;
    if c7bbrec.weight is null
     then
      tmp3 := null;
    else
      if entryitem < c21rec.tot then
        tmp3 := trunc((c7bbrec.weight/nvl(c21rec.tot,1)));
      else
        tmp3 := c7bbrec.weight - ((trunc(c7bbrec.weight/c21rec.tot))*(c21rec.tot - 1));
      end if;
    --  tmp3 := round((c7brec.weight/nvl(c21rec.tot,1)));
    end if;
    tmp9 := '4000';
    tmp10 := '169';
   else
    tmp2 := null;
    tmp3 := null;
    tmp9 := null;
    tmp10 := null;
  end if;

  case colin
  when 'CPG_1' then tmp := trim(tmp2);
  when 'CPG_2' then tmp := trim(tmp9);
  when 'CPG_3' then tmp := trim(tmp10);
  when 'CPG_4' then tmp := trim(tmp3);
  else tmp := null;
  end case;

elsif colin in ('CPH', 'CPH_1', 'CPH_2')
 then

  if tariff is not null
   then
    for c1rec in c1(entryno,entryitem,tariff) loop
     tmp2 := tmp2 || ', ' || c1rec.description;
    end loop;
    tmp2 := substr(tmp2,length(', ')+1);
    tmp3 := f15_parameter_range_sad_com( 'AU', entryno, null);
   else
    tmp2 := null;
    tmp3 := null;
  end if;

  case colin
  when 'CPH_1' then tmp := trim(tmp2);
  when 'CPH_2' then tmp := trim(tmp3);
  else tmp := null;
  end case;

elsif colin = 'CPY'
 then
  if tariff is not null
   then
    open c7(entryno,entryitem,tariff);
    fetch c7 into c7rec;
    close c7;
    open c21(entryno);
    fetch c21 into c21rec;
    close c21;
    open c7i(entryno,entryitem,tariff);
    fetch c7i into c7irec;
    close c7i;
    case upper(c7irec.cola)
    when 'KG' then tmp := to_char(form_15_continue_sad_com( 'CPG_4',entryno,entryitem,tariff,1,c21rec.tot ),'9999990.999' );
    when 'TONNE' then tmp := to_char((to_number(form_15_continue_sad_com( 'CPG_4',entryno,entryitem,tariff,1,c21rec.tot ))/1000),'9999990.999' );
    when 'TONNES' then tmp := to_char((to_number(form_15_continue_sad_com( 'CPG_4',entryno,entryitem,tariff,1,c21rec.tot ))/1000),'9999990.999' );
    when 'TON' then tmp := to_char((to_number(form_15_continue_sad_com( 'CPG_4',entryno,entryitem,tariff,1,c21rec.tot ))/1000),'9999990.999' );
    when 'T' then tmp := to_char((to_number(form_15_continue_sad_com( 'CPG_4',entryno,entryitem,tariff,1,c21rec.tot ))/1000),'9999990.999' );
    else tmp := c7rec.qty;
    end case;
   else
    tmp := NULL;
  end if;

elsif colin = 'CPY_1'
 then
  if tariff is not null
   then
    open c7(entryno,entryitem,tariff);
    fetch c7 into c7rec;
    close c7;
     tmp := c7rec.qty;
   else
    tmp := NULL;
  end if;

elsif colin = 'CPY_1_1'
 then
  if tariff is not null
   then
    open c7d(entryno,entryitem,tariff);
    fetch c7d into c7drec;
    close c7d;
     tmp := c7drec.excise_qty;
   else
    tmp := NULL;
  end if;


elsif colin = 'CPY_3'
 then
  if tariff is not null
   then
    tmp := tot(entryno,entryitem,tariff,'FOREIGN');
--    tmp := to_char(tot(entryno,entryitem,tariff,'FOREIGN'),'999999990.99');
   else
    tmp := NULL;
  end if;

elsif colin = 'CPY_3a'
 then
  tmp:=0;
  if tariff is not null
   then
    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
    tmp:=0;
    if c5rec.colc > 0  -- excise %
      then
       tmp := 1;
    end if;
    if c5rec.colh > 0  -- excise charge/unit
      then
       tmp := 2;
    end if;
    tmp2:= nvl(c5rec.colg,'HIGHER');
    if (c5rec.colc > 0) and (c5rec.colh > 0) and (tmp2 = 'BOTH')
      then
       tmp := 3;
    end if;
    if (c5rec.colc > 0) and (c5rec.colh > 0) and (tmp2 = 'LOWER')
      then
       tmp := 4;
    end if;
    if (c5rec.colc > 0) and (c5rec.colh > 0) and (tmp2 = 'HIGHER')
      then
       tmp := 5;
    end if;
   end if;


elsif colin = 'CPY_2'
 then
  if tariff is not null
   then
    tmp := 1;
    open c7c(tariff);
    fetch c7c into c7crec;
    close c7c;
    open c10(entryno);
    fetch c10 into c10rec;
    close c10;
    open c8(entryno);
    fetch c8 into c8rec;
    close c8;
--    if to_number(nvl(c7crec.description,'0')) > 0
--     then
--      tmp := tmp + 1;
--    end if;
    if to_number(nvl(c7crec.colc,'0')) > 0
     then
      tmp := tmp + 1;
    end if;
      if nvl(c10rec.vat,-1) >= 0
      then
       tmp := tmp + 1;
      end if;
      if nvl(c10rec.levy_rate,-1) >= 0
      then
       tmp := tmp + 1;
      end if;
    end if;

-- end of commonality for first and subsequent pages, items 31 through to 46

-- beginning of section 47 for first page
-- BEGINNING OF END CALUCATIONS FOR CONTINUATION PAGE


-- end of continuation page

-- beginning of commonality for first page, items 31 through to 46

elsif colin = 'TT'
 then
 if tariff is not null
 then
   tmp2 := to_char(nvl(tot(entryno,entryitem,tariff),88888),'999999990.99');
 else
   tmp2 := NULL;
 end if;

 tmp := tmp2;

elsif colin = 'TT_IXD'
 then
 tmp := NULL;
 if tariff is not null
 then
 open c7c(tariff);
  fetch c7c into c7crec;
  close c7c;
  if to_number(c7crec.colc) > 0
  then
   tmp := to_char(tot(entryno,entryitem,tariff),'999999990.99');
  end if;
 end if;

elsif colin = 'TT_IXD_2'
 then
 tmp := NULL;
 if tariff is not null
 then
  open c7d(entryno,entryitem,tariff);
   fetch c7d into c7drec;
  close c7d;
  if to_number(c7drec.excise_qty) > 0
  then
   tmp := to_char(c7drec.excise_qty,'999999990.999');
  end if;
 end if;

-- end of commonality for first and subsequent pages, items 31 through to 46

-- beginning of section 47 for first page

elsif colin in ('XX', 'XX_1', 'XX_2', 'XX_3')
 then
 tmp := null;
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
   tmp2 := to_char(to_number(c5rec.description),'990.999');
   tmp3 := to_char(round(tot(entryno,entryitem,tariff) * (nvl(to_number(c5rec.description),0)/100),2),'999999990.99');
   tmp9 := '1';
 end if;
 case colin
 when 'XX_1' then tmp := trim(tmp2);
 when 'XX_2' then tmp := trim(tmp3);
 when 'XX_3' then tmp := trim(tmp9);
 else tmp := null;
 end case;

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

elsif colin = 'ZZ_1_2'
 then
 tmp := NULL;
 if tariff is not null
 then
  open c7c(tariff);
   fetch c7c into c7crec;
  close c7c;
  if to_number(c7crec.colh) > 0
  then
   tmp := to_char(to_number(c7crec.colh),'999999990.999');
  end if;
 end if;


elsif colin = 'ZZ_2_2'
 then
 tmp := NULL;
 if tariff is not null
 then
  open c7d(entryno,entryitem,tariff);
   fetch c7d into c7drec;
  close c7d;
  open c7c(tariff);
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


elsif colin in ('SSS', 'SSS_1', 'SSS_2', 'SSS_3')
 then
    tmp := null;
    tmp2 := null;
    tmp3 := null;
    tmp9 := null;
  if tariff is not null
   then
    open c10(entryno);
    fetch c10 into c10rec;
    close c10;
    v_vat := c10rec.vat ;

    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(entryno,entryitem,tariff);
    fetch c2 into c2rec;
    close c2;
    if nvl(to_number(v_vat),0) > 0
     then
      tmp2 := to_char(to_number(v_vat),'990.99');
      temptot := tot(entryno,entryitem,tariff);
      tmp3 := to_char(
        round(
             (temptot +
             temptot * (nvl(to_number(c5rec.description),0)/100) +
             vtot                                                          -- v_excise
             ) *
             (nvl(to_number(v_vat),0)/100),2)
                   ,'999999990.99');
      tmp9 := '1';
     else
      tmp2:= '0.00';
      tmp3:= '0.00';
      tmp9:='0';
    end if;
   end if;

 case colin
 when 'SSS_1' then tmp := trim(tmp2);
 when 'SSS_2' then tmp := trim(tmp3);
 when 'SSS_3' then tmp := trim(tmp9);
 else tmp := null;
 end case;

elsif colin in ('TTT', 'TTT_1', 'TTT_2')
 then
    tmp := null;
    tmp2 := null;
    tmp3 := null;
    tmp9 := null;
  if tariff is not null
   then
    open c10(entryno);
    fetch c10 into c10rec;
    close c10;
    v_levy := c10rec.levy_rate ;
    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
    if nvl(to_number(v_levy),0) > 0
     then
      tmp2 := to_char(to_number(v_levy),'990.99');
      temptot := tot(entryno,entryitem,tariff);
      tmp3 := to_char(
        round(
             (temptot +
             temptot * (nvl(to_number(c5rec.description),0)/100) +
             vtot                                                         -- v_excise
             ) *
             (nvl(to_number(v_levy),0)/100),2)
                   ,'999999990.99');
      tmp9 := '1';
    end if;
   end if;

 case colin
 when 'TTT' then tmp := 232323 ; --to_char(tot(entryno,entryitem,tariff),'999999990.99');
 when 'TTT_1' then tmp := trim(tmp2);
 when 'TTT_2' then tmp := trim(tmp3);
 else tmp := null;
 end case;

-- end of section 47 for first page


elsif colin = 'N'
 then
  -- Calculate Total Number of Rows
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   return( to_char(c21rec.tot) );

end if;

return( tmp );
exception
 when others then return( sqlerrm );
end form_15_continue_sad_com_s;
/


GRANT EXECUTE ON STRANG.FORM_15_CONTINUE_SAD_COM_S TO WEBSYS;
