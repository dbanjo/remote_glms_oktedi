CREATE OR REPLACE function STRANG.f15_ratio( typ in varchar2, entryno in number )
 return varchar2
as

 cursor c1( entryno number ) is
  select /*+ ALL_ROWS */ *
  from ships_airway
  where ship_id in ( select ship_id
                     from movements m, detailrs dr
                     where entry_no = entryno and
                           m.movement_no = dr.movement_no and
                           nvl(m.seal,'|') = nvl(dr.camov_seal,'|'));

 cursor c1a( entryno number ) is
  select /*+ ALL_ROWS */ *
  from customers
  where customer_id in (select r.cust_customer_id from receivals r, detailrs dr where r.deliveryno = dr.deliveryno and entry_no = entryno);

 cursor c2( lv varchar2, cd varchar2 ) is
  select /*+ ALL_ROWS */ description
  from lov
  where lov_name = lv and
        code = cd;

 cursor c3( entryno number ) is
  select /*+ ALL_ROWS */ *
  from receivals
  where deliveryno in (select deliveryno from detailrs where entry_no = entryno);

 cursor c4( entryno number ) is
  select /*+ ALL_ROWS */ *
  from detailrs
  where entry_no = entryno;

 cursor c5( entryno number ) is
  select /*+ ALL_ROWS */ *
  from pos
  where deliveryno in (select deliveryno from detailrs where entry_no = entryno);

 cursor c7( entryno number ) is
  select /*+ ALL_ROWS */ sum(revenue_tonne(partweight,partvolume)) sumf
  from detailrs
  where entry_no = entryno;

 /*
 cursor c8( entryno number ) is
  select sum(tamount) / count(dr.entry_no) tamount
  from detailrs dr, pos p
  where dr.entry_no = entryno and
        dr.deliveryno = p.deliveryno;
 */

 cursor c8( parm1 number ) is
  select /*+ ALL_ROWS */ sum(p.tamount) tamount
  from pos p
  where p.deliveryno in
   (select distinct dr.deliveryno
    from detailrs dr
    where entry_no = parm1
   );

 cursor c9(entryno number) is
  select /*+ ALL_ROWS */ *
  from duty
  where entry_no = entryno;


 c1rec		c1%ROWTYPE;
 c1arec		c1a%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c9rec		c9%ROWTYPE;
 ttl		number;
 tmp		varchar2(32767);
 tmp2		varchar2(32767);

 begin
 if typ = 'RA'
  then
   return( to_char(entryno) );
 elsif typ = 'RB'
  then
   for c4rec in c4(entryno) loop
    tmp := tmp || ', ' || c4rec.detaildesc;
   end loop;
   return( substr( tmp, 3) );
 elsif typ = 'RC'
  then
   return( to_char(sysdate,'DD-Mon-YYYY') );
 elsif typ = 'RD'
  then
   open c2('CONTROLS','CUSTOMS_CUSTOMER');
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif typ = 'RE'
  then
   open c8(entryno);
   fetch c8 into c8rec;
   close c8;
   return( to_char(c8rec.tamount,'999,999,990.99') );
 elsif typ = 'RF'
  then
   open c3(entryno);
   fetch c3 into c3rec;
   close c3;
   return( c3rec.curr );
 elsif typ = 'RG'
  then
   open c9(entryno);
   fetch c9 into c9rec;
   close c9;
   return( round(c9rec.exrate,4) );
 elsif typ = 'RH'
  then
   open c9(entryno);
   fetch c9 into c9rec;
   close c9;
   open c8(entryno);
   fetch c8 into c8rec;
   close c8;
   return( to_char(c8rec.tamount/(c9rec.exrate),'999,999,990.99') );
 elsif typ = 'RI'
  then
   open c9(entryno);
   fetch c9 into c9rec;
   close c9;
   open c1a(entryno);
   fetch c1a into c1arec;
   close c1a;
   open c7(entryno);
   fetch c7 into c7rec;
   close c7;
   return( to_char(c1arec.freight * c7rec.sumf * (c9rec.exrate ),'999,999,990.99') );
 elsif typ = 'RJ'
  then
   open c3(entryno);
   fetch c3 into c3rec;
   close c3;
   open c1a(entryno);
   fetch c1a into c1arec;
   close c1a;
   open c7(entryno);
   fetch c7 into c7rec;
   close c7;
   return( to_char((c1arec.freight * c7rec.sumf),'999,999,990.99') );
 elsif typ = 'RK'
  then
   open c8(entryno);
   fetch c8 into c8rec;
   close c8;
   open c1a(entryno);
   fetch c1a into c1arec;
   close c1a;
   return( to_char(((c1arec.insurance/100) * c8rec.tamount),'999,999,990.99') );
 elsif typ = 'RL'
  then
   open c9(entryno);
   fetch c9 into c9rec;
   close c9;
   open c8(entryno);
   fetch c8 into c8rec;
   close c8;
   open c1a(entryno);
   fetch c1a into c1arec;
   close c1a;
   return( to_char(((c1arec.insurance/100) * c8rec.tamount) / (c9rec.exrate),'999,999,990.99') );
 elsif typ = 'RM'
  then
   open c1a(entryno);
   fetch c1a into c1arec;
   close c1a;
   open c8(entryno);
   fetch c8 into c8rec;
   close c8;
   return( to_char((c1arec.other_costs/100) * c8rec.tamount,'999,999,990.99') );
 elsif typ = 'RN'
  then
   open c9(entryno);
   fetch c9 into c9rec;
   close c9;
   open c1a(entryno);
   fetch c1a into c1arec;
   close c1a;
   open c8(entryno);
   fetch c8 into c8rec;
   close c8;
   return( to_char(((c1arec.other_costs/100) * c8rec.tamount) / (c9rec.exrate ),'999,999,990.99') );
 elsif typ = 'RO'
  then
   open c9(entryno);
   fetch c9 into c9rec;
   close c9;
   open c1a(entryno);
   fetch c1a into c1arec;
   close c1a;
   open c8(entryno);
   fetch c8 into c8rec;
   close c8;
   open c7(entryno);
   fetch c7 into c7rec;
   close c7;
   ttl := (((c1arec.other_costs/100) * c8rec.tamount) / (c9rec.exrate)) +
          (((c1arec.insurance/100) * c8rec.tamount) / (c9rec.exrate)) +
          ((c1arec.freight * c7rec.sumf)) +
          (c8rec.tamount/(c9rec.exrate));
   return( to_char(ttl,'999,999,990.99') );
 elsif typ = 'RP'
  then
   open c1a(entryno);
   fetch c1a into c1arec;
   close c1a;
   open c8(entryno);
   fetch c8 into c8rec;
   close c8;
   open c9(entryno);
   fetch c9 into c9rec;
   close c9;
   open c7(entryno);
   fetch c7 into c7rec;
   close c7;
   ttl := ((((c1arec.other_costs/100) * c8rec.tamount) / (c9rec.exrate)) +
           (((c1arec.insurance/100) * c8rec.tamount) / (c9rec.exrate)) +
           ((c1arec.freight * c7rec.sumf)) +
           (c8rec.tamount/(c9rec.exrate))) / c9rec.ratio_factor;
   return( to_char(ttl,'999,999,990.99') );
 elsif typ = 'RQ'
  then
   open c9(entryno);
   fetch c9 into c9rec;
   close c9;
   return( c9rec.ratio_factor );
 end if;

end f15_ratio;
/


GRANT EXECUTE ON STRANG.F15_RATIO TO WEBSYS;
