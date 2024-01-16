CREATE OR REPLACE function STRANG.form_15_continue_sad(colin varchar2, entryno in number, tariff in varchar2, rnumb in integer default null, vtot in number)
 return varchar2
as

 cursor c1(entryno number, tariff varchar2) is
  select /*+ ALL_ROWS */ distinct description
  from lov l1, detailrs dr, pos p
  where l1.cola = tariff and
        dr.entry_no = entryno and
        p.inventoryno = l1.code and
        dr.deliveryno = p.deliveryno and
        lov_name = 'INVENT';


 cursor c2(entryno number, tariff varchar2) is
  select /*+ ALL_ROWS */ *
  from ships_airway
  where ship_id in
   (select ship_id
   from movements m, detailrs dr, pos p, lov l1
   where entry_no = entryno and
         dr.deliveryno = p.deliveryno and
         p.inventoryno = l1.code and
         l1.lov_name = 'INVENT' and
         l1.cola = tariff and
         m.movement_no = dr.movement_no and
         nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
   );

 cursor c3( entryno number, tariff varchar2 ) is
  select /*+ ALL_ROWS */ nvl(sum(amount),0) sm
  from pos p, detailrs dr, lov l1
  where p.deliveryno = dr.deliveryno and
         dr.deliveryno = p.deliveryno and
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

 cursor c6(entryno number, tariff varchar2 ) is
  select /*+ ALL_ROWS */ sum(revton * s.freight) sm
  from detailrs dr, movements m, ships_airway s, pos p, lov l1
  where dr.entry_no = entryno and
        m.movement_no = dr.movement_no and
        dr.deliveryno = p.deliveryno and
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
         dr.entry_no = entryno
 group by l2.cola;
 */

 cursor c7( entryno number, tariff varchar2 ) is
  select /*+ ALL_ROWS */ sum(p.qty) qty
  from pos p, lov i
  where p.inventoryno = i.code and
        i.lov_name = 'INVENT' and
        i.cola = tariff and
        p.deliveryno in
        (select distinct deliveryno
         from detailrs
         where entry_no = entryno);

 cursor c7a( tariff varchar2 ) is
  select /*+ ALL_ROWS */ l2.cola
  from lov l2
  where l2.lov_name = 'TARIFF' and
        l2.code = tariff;

 cursor c7b( entryno number ) is
  select /*+ ALL_ROWS */ sum(dr.partweight) weight
  from detailrs dr
  where dr.entry_no = entryno;

 cursor c7c( tariff varchar2 ) is
  select /*+ ALL_ROWS */ l2.description,l2.colc, l2.colg, l2.colh
  from lov l2
  where l2.lov_name = 'TARIFF' and
        l2.code = tariff;

 cursor c7d( entryno number, tariff varchar2 ) is
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

 cursor c10(entryno number) is
   select /*+ ALL_ROWS */ distinct c.customer, c.levy_rate, c.vat, c.rate, c.customer_id, d.exrate
   from receivals r, detailrs dr, customers c, duty d
   where dr.entry_no = entryno and
         d.entry_no = dr.entry_no and
         dr.deliveryno = r.deliveryno and
         nvl(r.cust_customer_id,0) = c.customer_id and
         c.customer_type = 'CUSTOMER';


cursor c17( entryno number, rfrom integer, rto integer ) is
select tariff, description, colc
from
(
 select rownum rnumb, tariff, description, colc
 from
 (
  select /*+ ALL_ROWS */ distinct l1.cola tariff, l2.description, l2.colc
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
select tariff, description, colc
from
(
 select rownum rnumb, tariff, description, colc
 from
 (
  select /*+ ALL_ROWS */ distinct l1.cola tariff, l2.description, l2.colc
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
);


cursor c21( entryno number ) is
 select /*+ ALL_ROWS */  count( distinct l1.cola ) tot
 from pos p, lov l1, detailrs dr
 where dr.entry_no = entryno and
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

 function tot( entryno number, tariff varchar2, ctype in varchar2 default 'CURR' )
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
   cursor c2(entryno number, tariff varchar2 ) is
    select sum(nvl(tamount,0)) tot
    from pos p, lov l1
    where l1.lov_name = 'INVENT' and
          l1.code = p.inventoryno and
          l1.cola = tariff and
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
    open c2(entryno,tariff);
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
elsif colin in ('CPB', 'CPB_1', 'CPB_2')
 then
  if tariff is not null
   then
     tmp2 := f15_parameter_range_sad( 'AT', entryno, null);
     tmp3 := rnumb;
    else
     tmp2 := null;
     tmp3 := null;
  end if;

  case colin
  when 'CPB_1' then tmp := trim(tmp2);
  when 'CPB_2' then tmp := trim(tmp3);
  else tmp := null;
  end case;

elsif colin in ('CPC', 'CPC_1', 'CPC_2', 'CPC_1_1', 'CPC_1_2')
 then
  if tariff is not null
   then
    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(entryno,tariff);
    fetch c2 into c2rec;
    close c2;
    tmp2 := tariff;
    tmp3 := f15_parameter_range_sad( 'AWW', entryno, null);
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

elsif colin = 'CPD'
 then
 if tariff is not null
  then
   tmp := f15_parameter_range_sad( 'AWWW', entryno, null);
 else
   tmp := null;
 end if;

elsif colin in ('CPE', 'CPE_1', 'CPE_2', 'CPE_3')
 then
  if tariff is not null
   then
    open c7(entryno,tariff);
    fetch c7 into c7rec;
    close c7;
    open c7b(entryno);
    fetch c7b into c7brec;
    close c7b;
    if c7brec.weight is null
     then
      tmp2 := null;
    else
      tmp2 := c7brec.weight;
    end if;
    open c4(entryno);
    fetch c4 into c4rec;
    close c4;
   else
    tmp2 := null;
    c4rec.ctry_countrycode := null;
  end if;

  case colin
  when 'CPE_1' then tmp := trim(tmp2);
  when 'CPE_2' then tmp := trim(c4rec.ctry_countrycode);
  else tmp := null;
  end case;

elsif colin in ('CPG', 'CPG_1', 'CPG_2', 'CPG_3', 'CPG_4')
 then
  if tariff is not null
   then
    tmp2 := f15_parameter_range_sad( 'AWWWW', entryno, null);
    open c7(entryno,tariff);
    fetch c7 into c7rec;
    close c7;
    open c7b(entryno);
    fetch c7b into c7brec;
    close c7b;
    if c7brec.weight is null
     then
      tmp3 := null;
    else
      tmp3 := c7brec.weight;
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
    for c1rec in c1(entryno,tariff) loop
     tmp2 := tmp2 || ', ' || c1rec.description;
    end loop;
    tmp2 := substr(tmp2,length(', ')+1);
    tmp3 := f15_parameter_range_sad( 'AU', entryno, null);
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
    open c7(entryno,tariff);
    fetch c7 into c7rec;
    close c7;
     tmp := c7rec.qty;
   else
    tmp := NULL;
  end if;

elsif colin = 'CPY_1'
 then
  if tariff is not null
   then
    open c7(entryno,tariff);
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
    open c7d(entryno,tariff);
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
    tmp := tot(entryno,tariff,'FOREIGN');
--    tmp := to_char(tot(entryno,tariff,'FOREIGN'),'999999990.99');
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

elsif colin = 'CPTT'
 then
 if tariff is not null
 then
   tmp2 := to_char(tot(entryno,tariff),'999999990.99');
 else
   tmp2 := NULL;
 end if;

 tmp := tmp2;
 return(tmp2);
-- end of commonality for first and subsequent pages, items 31 through to 46

-- beginning of section 47 for first page
-- BEGINNING OF END CALUCATIONS FOR CONTINUATION PAGE

elsif colin in ('CP1_1', 'CP1_1_1', 'CP1_1_2', 'CP1_1_3')
 then
  strang_global.pgtotalduty := 0;
  strang_global.pgtotalexcise := 0;
  strang_global.pgtotalgst := 0;
  strang_global.pgtotallevy := 0;
  strang_global.pgglobaltotal := 0;

  if mod(rnumb,3) = 0
   then

    if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
     then
      open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
      fetch c5 into c5rec;
      close c5;
      open c2(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
      fetch c2 into c2rec;
      close c2;
      tmp2 := to_char(to_number(c5rec.description),'990.99') || '%';
    else
      tmp2 := null;
    end if;

    if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
     then
      open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
      fetch c5 into c5rec;
      close c5;
      tmp3 := to_char(round(tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff) * (nvl(to_number(c5rec.description),0)/100),2),'999999990.99');
      strang_global.pgtotalduty := nvl(round(tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff) * (nvl(to_number(c5rec.description),0)/100),2),0);
    else
      tmp3 := NULL;
    end if;

    if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
     then
      if tmp3 is not null
       then
        tmp9 := '1';
      else
        tmp9 := null;
      end if;
    else
      tmp9 := null;
    end if;

  else
    tmp2:= NULL;
    tmp3:=NULL;
  end if;

  case colin
  when 'CP1_1_1' then tmp := trim(tmp2);
  when 'CP1_1_1' then tmp := trim(tmp3);
  when 'CP1_1_1' then tmp := trim(tmp9);
  else tmp := null;
  end case;

elsif colin in ('CP2_1', 'CP2_1_1', 'CP2_1_2', 'CP2_1_3')
  then
   if mod(rnumb,3) = 0
    then

     if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
      then
       open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
       fetch c5 into c5rec;
       close c5;
       open c2(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
       fetch c2 into c2rec;
       close c2;
       tmp2 := to_char(to_number(c5rec.description),'990.99') || '%';
     else
       tmp2 := '&nbsp;';
     end if;

     if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
      then
       open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
       fetch c5 into c5rec;
       close c5;
       tmp3 := to_char(round(tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff) * (nvl(to_number(c5rec.description),0)/100),2),'999999990.99');
       strang_global.pgtotalduty := nvl(strang_global.pgtotalduty,0) + nvl(round(tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff) * (nvl(to_number(c5rec.description),0)/100),2),0);
     else
       tmp3 := NULL;
     end if;

     if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
      then
       if tmp3 is not null
        then
         tmp9 := '1';
       else
        tmp9 := null;
       end if;
     else
       tmp9 := null;
     end if;

  else
    tmp2:= NULL;
    tmp3:= NULL;
  end if;

  case colin
  when 'CP2_1_1' then tmp := trim(tmp2);
  when 'CP2_1_1' then tmp := trim(tmp3);
  when 'CP2_1_1' then tmp := trim(tmp9);
  else tmp := null;
  end case;

elsif colin = 'CP1_2'
  then
if mod(rnumb,3) = 0
 then
  if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
   then
    open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
    fetch c2 into c2rec;
    close c2;
    if to_number(nvl(c5rec.colc,'0') ) > 0
     then
      tmp2 := to_char(to_number(c5rec.colc),'990.99') || '%';
     else
      tmp2 := '&nbsp;';
    end if;
      else
    tmp2 := '&nbsp;';
   end if;

    if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
     then
      open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
      fetch c5 into c5rec;
      close c5;
      temptot := tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
      tmp3 := to_char(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                   (nvl(to_number(c5rec.colc),0)/100),2),'999999990.99');
      strang_global.pgtotalexcise :=  nvl(round((temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                   (nvl(to_number(c5rec.colc),0)/100),2),0);
     else
      tmp3 := NULL;
    end if;
          if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;

  tmp := '<tr style=''height:13.45pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Excise</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 align=right style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>';
  else
    tmp2:= '&nbsp;';
    tmp3:= NULL;
  end if;

elsif colin = 'CP2_2'
  then
if mod(rnumb,3) = 0
 then

  if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
   then
    open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
    fetch c2 into c2rec;
    close c2;
    if to_number(nvl(c5rec.colc,'0') ) > 0
     then
      tmp2 := to_char(to_number(c5rec.colc),'990.99') || '%';
     else
      tmp2 := '&nbsp;';
    end if;
      else
    tmp2 := '&nbsp;';
   end if;

    if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
     then
      open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
      fetch c5 into c5rec;
      close c5;
      temptot := tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
      tmp3 := to_char(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                   (nvl(to_number(c5rec.colc),0)/100),2),'999999990.99');
      strang_global.pgtotalexcise := nvl(strang_global.pgtotalexcise,0) + nvl(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                   (nvl(to_number(c5rec.colc),0)/100),2),0);
     else
      tmp3 := NULL;
    end if;
          if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;

  tmp :='  <td width=35 colspan=2 style=''width:26.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Excise</span></p>
  </td>
  <td width=101 colspan=7 style=''width:75.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=31 colspan=3 align=right style=''width:22.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
 </tr>
  ';
else
  tmp2:= NULL;
  tmp3:= NULL;
end if;



elsif colin = 'CP1_3'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c2 into c2rec;
     close c2;
     if nvl(to_number(c2rec.vat),0) > 0
      then
       tmp2 := to_char(to_number(c2rec.vat),'990.99') || '%';
     end if;
    else
     tmp2 := '&nbsp;';
    end if;

     if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
      then
       open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
       fetch c5 into c5rec;
       close c5;
       open c2(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
       fetch c2 into c2rec;
       close c2;
       temptot := tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
       tmp3 := to_char(
         round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c2rec.vat),0)/100),2)
                      ,'999999990.99');
         strang_global.pgtotalgst:= nvl(round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c2rec.vat),0)/100),2),0);
       else
        tmp3 := NULL;
      end if;
          if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;


  tmp :=' <tr style=''height:12.2pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>GST</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 align=right style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
  ';
 else
    tmp2:= NULL;
    tmp3:= NULL;
 end if;


elsif colin = 'CP2_3'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c2 into c2rec;
     close c2;
     if nvl(to_number(c2rec.vat),0) > 0
      then
       tmp2 := to_char(to_number(c2rec.vat),'990.99') || '%';
     end if;
    else
     tmp2 := '&nbsp;';
    end if;

     if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
      then
       open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
       fetch c5 into c5rec;
       close c5;
       open c2(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
       fetch c2 into c2rec;
       close c2;
       temptot := tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
       tmp3 := to_char(
         round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c2rec.vat),0)/100),2)
                      ,'999999990.99');
       strang_global.pgtotalgst :=   nvl(strang_global.pgtotalgst,0) + nvl(round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c2rec.vat),0)/100),2),0);
       else
        tmp3 := NULL;
      end if;
          if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;


  tmp :='  <td width=35 colspan=2 style=''width:26.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>GST</span></p>
  </td>
  <td width=101 colspan=7 style=''width:75.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=31 colspan=3 align=right style=''width:22.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
 </tr>
';
    else
      tmp2:= NULL;
      tmp3:= NULL;
    end if;

elsif colin = 'CP1_4'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c2 into c2rec;
     close c2;
     if nvl(to_number(c2rec.levy_rate),0) > 0
      then
       tmp2 := to_char(to_number(c2rec.levy_rate),'990.99') || '%';
     end if;
    else
     tmp2 := '&nbsp;';
    end if;

   if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c2 into c2rec;
     close c2;
     temptot := tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);

     tmp3 := to_char((nvl(to_number(c2rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2))),'999999990.99');
     strang_global.pgtotallevy := nvl((nvl(to_number(c2rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2))),0);
     else
      tmp3 := NULL;
    end if;
          if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;

  tmp :=' <tr style=''height:12.2pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''> - </span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 align=right style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
  ';
  else
    tmp2:= NULL;
    tmp3:= NULL;
  end if;

elsif colin = 'CP2_4'
  then
if mod(rnumb,3) = 0
 then

   if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c2 into c2rec;
     close c2;
     if nvl(to_number(c2rec.levy_rate),0) > 0
      then
       tmp2 := to_char(to_number(c2rec.levy_rate),'990.99') || '%';
     end if;
    else
     tmp2 := '&nbsp;';
    end if;

   if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c2 into c2rec;
     close c2;
     temptot := tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);

     tmp3 := to_char((nvl(to_number(c2rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2))),'999999990.99');
     strang_global.pgtotallevy := nvl(strang_global.pgtotallevy,0) + nvl((nvl(to_number(c2rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2))),0);
     else
      tmp3 := NULL;
    end if;
          if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;

  tmp :='  <td width=35 colspan=2 style=''width:26.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''> - </span></p>
  </td>
  <td width=101 colspan=7 style=''width:75.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=31 colspan=3 align=right style=''width:22.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
 </tr>
';
  else
    tmp2:= NULL;
    tmp3:= NULL;
  end if;

elsif colin = 'CP1_5'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c2 into c2rec;
     close c2;

     tmp4 := round(tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff) * (nvl(to_number(c5rec.description),0)/100),2);
     temptot := tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
     tmp5 := round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                  (nvl(to_number(c5rec.colc),0)/100),2);
     tmp6 :=
          round(
                (temptot +
                 temptot * (nvl(to_number(c5rec.description),0)/100) +
                 (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
                ) *
               (nvl(to_number(c2rec.vat),0)/100),2);
     tmp7 := (nvl(to_number(c2rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2)));
     tmp8 := to_char(tmp4 + tmp5 + tmp6 + tmp7,'999999990.99');
     strang_global.pgglobaltotal := nvl((tmp4 + tmp5 + tmp6 + tmp7),0);
    else
      tmp8 := NULL;
    end if;

  tmp := tmp8;
 else
    tmp8 := NULL;
 end if;

elsif colin = 'CP2_5'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c2 into c2rec;
     close c2;

     tmp4 := round(tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff) * (nvl(to_number(c5rec.description),0)/100),2);
     temptot := tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
     tmp5 := round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                  (nvl(to_number(c5rec.colc),0)/100),2);
     tmp6 :=
          round(
                (temptot +
                 temptot * (nvl(to_number(c5rec.description),0)/100) +
                 (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
                ) *
               (nvl(to_number(c2rec.vat),0)/100),2);
     tmp7 := (nvl(to_number(c2rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2)));
     tmp8 := to_char(tmp4 + tmp5 + tmp6 + tmp7,'999999990.99');
     strang_global.pgglobaltotal := nvl(strang_global.pgglobaltotal,0) + nvl((tmp4 + tmp5 + tmp6 + tmp7),0);
    else
      tmp8 := NULL;
    end if;


  tmp :='  <td width=166 colspan=12 align=right style=''width:124.75pt;align:right;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><B><span style=''font-size:8.0pt;font-family:Arial''>TOTAL
  SECOND ITEM :  </span></B></p>
  </td>
  <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp8 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.55pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
 </tr>
 ';
 else
   tmp8:= NULL;
 end if;

elsif colin = 'CPTITLE'
  then
if mod(rnumb,3) = 0
  then
    tmp :=' <tr style=''height:8.4pt''>
   <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
   none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Type</span></p>
   </td>
   <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
   border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Tax base</span></p>
   </td>
   <td width=28 style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
   solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
   padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>%</span></p>
   </td>
   <td width=86 colspan=4 style=''width:64.15pt;border-top:none;border-left:none;
   border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Amount</span></p>
   </td>
   <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
   border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>MP</span></p>
   </td>
   <td width=166 colspan=12 style=''width:124.75pt;border-top:none;border-left:
   none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Type</span></p>
   </td>
   <td width=107 colspan=5 style=''width:80.2pt;border-top:none;border-left:none;
   border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Amount</span></p>
   </td>
   <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
   solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
   padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>MP</span></p>
   </td>
  </tr>
 ';
 else tmp:=null;
 end if;


elsif colin = 'CP3_1'
  then
if mod(rnumb,3) = 0
 then
  if strang_global.GLOBAL_VARS(rnumb).tariff is not null
   then
    open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
    fetch c2 into c2rec;
    close c2;
    tmp2 := to_char(to_number(c5rec.description),'990.99') || '%';
  else
    tmp2 := '&nbsp;';
  end if;

   if strang_global.GLOBAL_VARS(rnumb).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c5 into c5rec;
     close c5;
     tmp3 := to_char(round(tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff) * (nvl(to_number(c5rec.description),0)/100),2),'999999990.99');
     strang_global.pgtotalduty := nvl(strang_global.pgtotalduty,0) + nvl(round(tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff) * (nvl(to_number(c5rec.description),0)/100),2),0);
   else
     tmp3 := NULL;
   end if;
          if strang_global.GLOBAL_VARS(rnumb).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;

  tmp :=' <tr style=''height:13.45pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Duty</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 align=right style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
';
end if;

elsif colin = 'CPGT_1'
  then
 if mod(rnumb,3) = 0
  then
   -- Last Element on the Page, produce the summary page total
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc(rnumb/3) + 1;


   open c8(entryno);
   fetch c8 into c8rec;
   close c8;

   b1 := 0;

   for c18rec in c18(entryno) loop
      temptot := tot(entryno,c18rec.tariff);
      b1 := nvl(b1,0) + temptot * (nvl(to_number(c18rec.description),0)/100);
   end loop;

   xb1 := to_char(b1,'99999999.99'); -- Total C - Customs Duty
   xb1 := to_char(strang_global.pgtotalduty,'99999999.99');  -- page only total

    tmp :='  <td width=166 colspan=12 style=''width:124.75pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
    <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Duty</span></p>
    </td>
    <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
    <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| xb1 ||'</span></b></p>
    </td>
    <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
    solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
    height:13.45pt''>
    <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
    </td>
   </tr>
  ';
  end if;

elsif colin = 'CP3_2'
  then
if mod(rnumb,3) = 0
 then
  if strang_global.GLOBAL_VARS(rnumb).tariff is not null
   then
    open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
    fetch c2 into c2rec;
    close c2;
    if to_number(nvl(c5rec.colc,'0') ) > 0
     then
      tmp2 := to_char(to_number(c5rec.colc),'990.99') || '%';
     else
      tmp2 := '&nbsp;';
    end if;
      else
    tmp2 := '&nbsp;';
   end if;

    if strang_global.GLOBAL_VARS(rnumb).tariff is not null
     then
      open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
      fetch c5 into c5rec;
      close c5;
      temptot := tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
      tmp3 := to_char(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                   (nvl(to_number(c5rec.colc),0)/100),2),'999999990.99');
      strang_global.pgtotalexcise := nvl(strang_global.pgtotalexcise,0) +  nvl(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                   (nvl(to_number(c5rec.colc),0)/100),2),0);
     else
      tmp3 := NULL;
    end if;
          if strang_global.GLOBAL_VARS(rnumb).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;

  tmp :=' <tr style=''height:13.45pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Excise</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 align=right style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
  ';
end if;

elsif colin = 'CPGT_2'
  then
 if mod(rnumb,3) = 0
  then
   -- Last Element on the Page, produce the summary page total
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc(rnumb/3) + 1;


   open c8(entryno);
   fetch c8 into c8rec;
   close c8;
   temptot := 0;
   b1 := 0;
   b2 := 0;
   b3 := 0;
   b5 := 0;
   for c18rec in c18(entryno) loop --(FEB06 check)
      temptot := tot(entryno,c18rec.tariff);
      b2 := nvl(b2,0) + ((temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) * (nvl(to_number(c18rec.colc),0)/100));
   end loop;

   xb2 := to_char(b2,'99999999.99'); -- Total D - Excise Duty
   xb2 := to_char(strang_global.pgtotalexcise,'99999999.99'); -- Total D - Excise Duty  page only


  tmp :='  <td width=166 colspan=12 style=''width:124.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Excise</span></p>
  </td>
  <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| xb2 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
  </tr>
  ';
 end if;


elsif colin = 'CP3_3'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c2 into c2rec;
     close c2;
     if nvl(to_number(c2rec.vat),0) > 0
      then
       tmp2 := to_char(to_number(c2rec.vat),'990.99') || '%';
     end if;
    else
     tmp2 := '&nbsp;';
    end if;

     if strang_global.GLOBAL_VARS(rnumb).tariff is not null
      then
       open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
       fetch c5 into c5rec;
       close c5;
       open c2(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
       fetch c2 into c2rec;
       close c2;
       temptot := tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
       tmp3 := to_char(
         round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c2rec.vat),0)/100),2)
                      ,'999999990.99');
       strang_global.pgtotalgst := nvl(strang_global.pgtotalgst,0) + nvl(round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c2rec.vat),0)/100),2),0);
       else
        tmp3 := NULL;
      end if;
          if strang_global.GLOBAL_VARS(rnumb).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;

  tmp :=' <tr style=''height:12.2pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>GST</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 align=right style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
 ';
 end if;


elsif colin = 'CPGT_3'
  then
 if mod(rnumb,3) = 0
  then
   -- Last Element on the Page, produce the summary page total
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc(rnumb/3) + 1;


   open c8(entryno);
   fetch c8 into c8rec;
   close c8;

   b3 := 0;
   for c18rec in c18(entryno) loop --(FEB06 check)
      temptot := tot(entryno,c18rec.tariff);
      b3 := nvl(b3,0) +
       (temptot +
          temptot * (nvl(to_number(c18rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) * (nvl(to_number(c18rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;

   xb3 := to_char(b3,'99999999.99'); -- Total E - Vat
   xb3 := to_char(strang_global.pgtotalgst,'99999999.99'); -- Total E - Vat (GST) page only

  tmp :='  <td width=166 colspan=12 style=''width:124.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>GST</span></p>
  </td>
  <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| xb3 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
 </tr>
 ';
 end if;


elsif colin = 'CP3_4'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c2 into c2rec;
     close c2;
     if nvl(to_number(c2rec.levy_rate),0) > 0
      then
       tmp2 := to_char(to_number(c2rec.levy_rate),'990.99') || '%';
     end if;
    else
     tmp2 := '&nbsp;';
    end if;

   if strang_global.GLOBAL_VARS(rnumb).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c2 into c2rec;
     close c2;
     temptot := tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);

     tmp3 := to_char((nvl(to_number(c2rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2))),'999999990.99');
     strang_global.pgtotallevy := nvl(strang_global.pgtotallevy,0) +  nvl(((nvl(to_number(c2rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2)))),0);
     else
      tmp3 := NULL;
    end if;
          if strang_global.GLOBAL_VARS(rnumb).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;

  tmp :=' <tr style=''height:12.2pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''> - </span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 align=right style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
  ';
  end if;


elsif colin = 'CPGT_4'
  then
 if mod(rnumb,3) = 0
  then
   -- Last Element on the Page, produce the summary page total
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc(rnumb/3) + 1;


   open c8(entryno);
   fetch c8 into c8rec;
   close c8;

   b5 := 0;
/* 2 % LEVY CALCULATION
*/
   for c18rec in c18(entryno) loop --(FEB06 check)
      temptot := tot(entryno,c18rec.tariff);
      b5 := nvl(b5,0) +
		((nvl(to_number(c8rec.levy_rate),0)/100)
		*(temptot +
		(round(temptot * (nvl(to_number(c18rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) *
                (nvl(to_number(c18rec.colc),0)/100),2))));
   end loop;

   xb5 := to_char(b5,'99999999.99'); -- Total F - Levy
   xb5 := to_char(strang_global.pgtotallevy,'99999999.99'); -- Total F - Levy (page only)


  tmp :='  <td width=166 colspan=12 style=''width:124.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''> - </span></p>
  </td>
  <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| xb5 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
  </tr>
  ';
 end if;


elsif colin = 'CP3_5'
  then
if mod(rnumb,3) = 0
  then
   if strang_global.GLOBAL_VARS(rnumb).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c2 into c2rec;
     close c2;

     tmp4 := round(tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff) * (nvl(to_number(c5rec.description),0)/100),2);
     temptot := tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
     tmp5 := round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                  (nvl(to_number(c5rec.colc),0)/100),2);
     tmp6 :=
          round(
                (temptot +
                 temptot * (nvl(to_number(c5rec.description),0)/100) +
                 (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
                ) *
               (nvl(to_number(c2rec.vat),0)/100),2);
     tmp7 := (nvl(to_number(c2rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2)));
     tmp8 := to_char(tmp4 + tmp5 + tmp6 + tmp7,'999999990.99');
     strang_global.pgglobaltotal := nvl(strang_global.pgglobaltotal,0) + nvl((tmp4 + tmp5 + tmp6 + tmp7),0);
    else
      tmp8 := NULL;
    end if;

  tmp :=' <tr style=''height:13.55pt''>
  <td width=155 colspan=5 align=right style=''width:116.3pt;border:solid windowtext 1.0pt;
  border-top:none;padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><B><span style=''font-size:8.0pt;font-family:Arial''>TOTAL
  THIRD ITEM  : </span></B></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;align=right;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp8 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  ';
 end if;
elsif colin = 'CPGT_5'
  then
 if mod(rnumb,3) = 0
  then
   -- Last Element on the Page, produce the summary page total

   ttl := 0;
   open c8(entryno);
   fetch c8 into c8rec;
   close c8;
   temptot := 0;
   b1 := 0;
   b2 := 0;
   b3 := 0;
   b5 := 0;
   for c18rec in c18(entryno) loop
      temptot := tot(entryno,c18rec.tariff);
      b1 := nvl(b1,0) + temptot * (nvl(to_number(c18rec.description),0)/100);
      b2 := nvl(b2,0) + ((temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) * (nvl(to_number(c18rec.colc),0)/100));
      b3 := nvl(b3,0) +
       (temptot +
          temptot * (nvl(to_number(c18rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) * (nvl(to_number(c18rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
      b5 := nvl(b5,0) +
		((nvl(to_number(c8rec.levy_rate),0)/100)
		*(temptot +
		(round(temptot * (nvl(to_number(c18rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) *
                (nvl(to_number(c18rec.colc),0)/100),2))));
   end loop;
   b4 := round(b1 + b2 + b3 + b5,2);
   b4 := round(strang_global.pgglobaltotal,2); -- page total only

   tmp :='  <td width=166 colspan=12 align=right style=''width:124.75pt;border-top:none;border-left:
   none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
   <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''><B>GLOBAL
   TOTAL : </B></span></p>
   </td>
   <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
   border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
   <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| to_char(b4,'99999999.99') ||'</span></b></p>
   </td>
   <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
   solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
   height:13.55pt''>
   <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
   </td>
   </tr>
   </table>';
    strang_global.pgtotalduty := 0;
    strang_global.pgtotalexcise := 0;
    strang_global.pgtotalgst := 0;
    strang_global.pgtotallevy := 0;
    strang_global.pgglobaltotal := 0;
  if pagefrom = pageto
    then
      NULL;
  else
    tmp := tmp || '<br clear=all style=''mso-special-character:line-break;page-break-before:always''>';
  end if;
 end if;

-- end of continuation page



-- beginning of commonality for first page, items 31 through to 46

elsif colin in ('B', 'B_1', 'B_2')
 then
   tmp2 := f15_parameter_range_sad( 'AT', entryno, null);
   if tariff is not null
    then
      tmp3 := rnumb;
     else
      tmp3 := null;
   end if;

   case colin
   when 'B_1' then tmp := trim(tmp2);
   when 'B_2' then tmp := trim(tmp3);
   else tmp := null;
   end case;

elsif colin in ('C', 'C_1', 'C_2')
 then
 if tariff is not null
  then
   open c5(tariff);
   fetch c5 into c5rec;
   close c5;
   open c2(entryno,tariff);
   fetch c2 into c2rec;
   close c2;
   tmp2 := replace(tariff, '.', '');
  else
   tmp2 := null;
  end if;
  tmp3 := f15_parameter_range_sad( 'AWW', entryno, null);

   case colin
   when 'C_1' then tmp := trim(tmp2);
   when 'C_2' then tmp := trim(tmp3);
   else tmp := null;
   end case;

elsif colin = 'D'
 then
   tmp := f15_parameter_range_sad( 'AWWW', entryno, null);

elsif colin in ('E', 'E_1', 'E_2')
 then
  if tariff is not null
   then
    open c4(entryno);
    fetch c4 into c4rec;
    close c4;
    open c7(entryno,tariff);
    fetch c7 into c7rec;
    close c7;
    open c7b(entryno);
    fetch c7b into c7brec;
    close c7b;
    if c7brec.weight is null
     then
      tmp2 := null;
    else
      tmp2 := c7brec.weight;
    end if;
  else
    tmp2 := null;
    c4rec.ctry_countrycode := null;
  end if;

  case colin
  when 'E_1' then tmp := trim(tmp2);
  when 'E_2' then tmp := trim(c4rec.ctry_countrycode);
  else tmp := null;
  end case;

elsif colin in ('G', 'G_1', 'G_2')
 then
  tmp2 := f15_parameter_range_sad('AWWWW', entryno, null);
  if tariff is not null
   then
    open c7(entryno,tariff);
    fetch c7 into c7rec;
    close c7;
    open c7b(entryno);
    fetch c7b into c7brec;
    close c7b;
    if c7brec.weight is null
     then
      tmp3 := null;
    else
      tmp3 := c7brec.weight;
    end if;
  else
    tmp3 := null;
 end if;

 case colin
 when 'G_1' then tmp := trim(tmp2);
 when 'G_2' then tmp := trim(tmp3);
 else tmp := null;
 end case;

elsif colin in ('H', 'H_1', 'H_2')
 then

  tmp2 := f15_parameter_range_sad( 'AWWWWW', entryno, tariff);

  if tariff is not null
   then
    tmp3 := f15_parameter_range_sad( 'AU', entryno, null);
   else
    tmp3 := null;
  end if;

 case colin
 when 'H_1' then tmp := trim(tmp2);
 when 'H_2' then tmp := trim(tmp3);
 else tmp := null;
 end case;

elsif colin in ('Y', 'Y_1', 'Y_2', 'Y_3')
 then
  if tariff is not null
   then
    open c7(entryno,tariff);
    fetch c7 into c7rec;
    close c7;
    open c7a(tariff);
    fetch c7a into c7arec;
    close c7a;
    if c7arec.cola is null
     then
      tmp2 := null;
	  tmp4 := null;
    else
      tmp2 := c7rec.qty;
	  tmp4 := c7arec.cola;
    end if;
    tmp3 := to_char(tot(entryno,tariff,'FOREIGN'),'999999990.99');
   else
    tmp2 := null;
	tmp4 := null;
    tmp3 := NULL;
  end if;

 case colin
 when 'Y_1' then tmp := trim(tmp2);
 when 'Y_2' then tmp := trim(tmp4);
 when 'Y_3' then tmp := trim(tmp3);
 else tmp := null;
 end case;

elsif colin = 'TT'
 then
 if tariff is not null
 then
   tmp2 := to_char(nvl(tot(entryno,tariff),88888),'999999990.99');
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
   tmp := to_char(tot(entryno,tariff),'999999990.99');
  end if;
 end if;

elsif colin = 'TT_IXD_2'
 then
 tmp := NULL;
 if tariff is not null
 then
  open c7d(entryno,tariff);
   fetch c7d into c7drec;
  close c7d;
  if to_number(c7drec.excise_qty) > 0
  then
   tmp := to_char(c7drec.excise_qty,'999999990.999');
  end if;
 end if;


elsif colin = 'TT_GST'
 then
 tmp:= NULL;
 if tariff is not null
 then
  open c10(entryno);
  fetch c10 into c10rec;
  close c10;
  open c8(entryno);
  fetch c8 into c8rec;
  close c8;
  if c10rec.customer_id >=2
  then
   if to_number(c10rec.vat) > 0
   then
    tmp := to_char(tot(entryno,tariff),'999999990.99');
   end if;
  else
   if to_number(c8rec.vat) > 0
   then
    tmp := to_char(tot(entryno,tariff),'999999990.99');
   end if;
  end if;
 end if;

elsif colin = 'TT_LVY'
 then
 tmp:= NULL;
 if tariff is not null
 then
  open c10(entryno);
  fetch c10 into c10rec;
  close c10;
  open c8(entryno);
  fetch c8 into c8rec;
  close c8;
  if c10rec.customer_id >=2
  then
   if to_number(c10rec.levy_rate) > 0
   then
    tmp := to_char(tot(entryno,tariff),'999999990.99');
   end if;
  else
   if to_number(c8rec.levy_rate) > 0
   then
    tmp := to_char(tot(entryno,tariff),'999999990.99');
   end if;
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
   open c2(entryno,tariff);
   fetch c2 into c2rec;
   close c2;
   tmp2 := to_char(to_number(c5rec.description),'990.999');
   tmp3 := to_char(round(tot(entryno,tariff) * (nvl(to_number(c5rec.description),0)/100),2),'999999990.99');
   tmp9 := '1';
 end if;
 case colin
 when 'XX_1' then tmp := trim(tmp2);
 when 'XX_2' then tmp := trim(tmp3);
 when 'XX_3' then tmp := trim(tmp9);
 else tmp := null;
 end case;

elsif colin = 'YY'
 then
  if tariff is not null
   then
    tmp9 := '1';
   else
    tmp9 := null;
  end if;

  tmp := tmp9;

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
    open c2(entryno,tariff);
    fetch c2 into c2rec;
    close c2;
    if to_number(nvl(c5rec.colc,'0') ) > 0
     then
      tmp2 := to_char(to_number(c5rec.colc),'990.999');
      temptot := tot(entryno,tariff);
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
  open c7d(entryno,tariff);
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
    open c2(entryno,tariff);
    fetch c2 into c2rec;
    close c2;
    if nvl(to_number(v_vat),0) > 0
     then
      tmp2 := to_char(to_number(v_vat),'990.99');
      temptot := tot(entryno,tariff);
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
      temptot := tot(entryno,tariff);
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
 when 'TTT' then tmp := 232323 ; --to_char(tot(entryno,tariff),'999999990.99');
 when 'TTT_1' then tmp := trim(tmp2);
 when 'TTT_2' then tmp := trim(tmp3);
 else tmp := null;
 end case;

elsif colin in ('UUU', 'UUU_1', 'UUU_2')
 then

  if tariff is not null
   then
    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(entryno,tariff);
    fetch c2 into c2rec;
    close c2;
    if nvl(to_number(c2rec.levy_rate),0) > 0
     then
      tmp2 := to_char(to_number(c2rec.levy_rate),'990.99') || '%';
    end if;
    temptot := tot(entryno,tariff);

    tmp3 := to_char((nvl(to_number(c2rec.levy_rate),0)/100)
    		*(temptot +
		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                (nvl(to_number(c5rec.colc),0)/100),2))),'999999990.99');
  else
    tmp2 := null;
    tmp3 := null;
  end if;

 case colin
 when 'UUU_1' then tmp := trim(tmp2);
 when 'UUU_2' then tmp := trim(tmp3);
 else tmp := null;
 end case;

elsif colin = 'VVV'
 then
     if tariff is not null
      then
       tmp := '1';
      else
       tmp := null;
     end if;

elsif colin = 'WWW'
 then

  if tariff is not null
   then
    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(entryno,tariff);
    fetch c2 into c2rec;
    close c2;

    tmp4 := round(tot(entryno,tariff) * (nvl(to_number(c5rec.description),0)/100),2);
    temptot := tot(entryno,tariff);
    tmp5 := round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2);
    tmp6 :=
         round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c2rec.vat),0)/100),2);
    tmp7 := (nvl(to_number(c2rec.levy_rate),0)/100)
    		*(temptot +
		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                (nvl(to_number(c5rec.colc),0)/100),2)));
    tmp8 := to_char(tmp4 + tmp5 + tmp6 + tmp7,'999999990.99');
  else
    tmp8 := null;
  end if;

  tmp := tmp8;

-- end of section 47 for first page

elsif colin = 'L'
 then
  -- Calculate Total Number of Rows for rownum rounded up to the nearest 10..this is a very odd calculation!!
   c21rec.tot := vtot;
   c21rec.tot := ((trunc((c21rec.tot - 2) / 3) + 1) * 3) + 1;
   return( to_char(c21rec.tot) );

elsif colin = 'M'
 then
   c21rec.tot := vtot;
   c21rec.tot := c21rec.tot - 1;
   return( to_char(c21rec.tot) );

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
end form_15_continue_sad;
/
