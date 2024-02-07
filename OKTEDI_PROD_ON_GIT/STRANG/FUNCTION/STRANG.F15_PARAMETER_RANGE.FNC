CREATE OR REPLACE function STRANG.f15_parameter_range( parm_id in varchar2, parm1 in number, parm2 in varchar2 )
 return varchar2
as

 -- Parm1 = ENTRY_NO
 -- Parm2 = CUSTOMER

 cursor c1( parm1 number ) is
  select /*+ ALL_ROWS */ *
  from ships_airway
  where ship_id in ( select ship_id
                     from movements m, detailrs dr
                     where entry_no = parm1 and
                           m.movement_no = dr.movement_no and
                           nvl(m.seal,'|') = nvl(dr.camov_seal,'|'));


 cursor c2( lv varchar2, cd varchar2 ) is
  select /*+ ALL_ROWS */ *
  from lov
  where lov_name = lv and
        code = cd;

 cursor c2a( lv varchar2, cd varchar2 ) is
  select /*+ ALL_ROWS */ *
  from lov
  where lov_name = lv and
        cola = cd;

 cursor c2b( cd varchar2 ) is
  select /*+ ALL_ROWS */ *
  from lov l
  where l.lov_name = 'CONTROLS' and
        l.cola = WEBSYS.OLTP.F_USER_SITE and
        code = cd;

 /*
 cursor c3( parm1 number, parm2 varchar2 ) is
  select sum(p.tamount)/count(dr.entry_no) sm
  from pos p, customers c, detailrs dr, receivals r
  where dr.entry_no = parm1 and
        c.customer = parm2 and
        dr.deliveryno = r.deliveryno and
        p.deliveryno = r.deliveryno and
        nvl(r.cust_customer_id,0) = c.customer_id and
        customer_type = 'CUSTOMER';
 */
 -- SS says this is the right way to do this.

 cursor c3( parm1 number, parm2 varchar2 ) is
  select /*+ ALL_ROWS */ sum(p.tamount) sm
  from pos p
  where p.deliveryno in
   (select distinct dr.deliveryno
    from detailrs dr
    where entry_no = parm1
   );

/*
 cursor c4( parm1 number, parm2 varchar2 ) is
 select l.description || ' ' || dr.detaildesc shipmark,sum(qty) qty
 from detailrs dr, lov l
 where movement_no in
       (select dr.movement_no
        from customers c, detailrs dr, receivals r, movements m
        where dr.entry_no = parm1 and
          c.customer = parm2 and
          m.movement_no = dr.movement_no and
          nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
          dr.deliveryno = r.deliveryno and
          nvl(r.cust_customer_id,0) = c.customer_id and
          customer_type = 'CUSTOMER') and
       lov_name = 'PACKTYPES' and
       l.code = dr.pktpe_packtype
 group by l.description || ' ' || dr.detaildesc;
 */

 /*
 This will only get the first country of origin code in po order
 */

  cursor c4a( entryno number ) is
   select /*+ ALL_ROWS */ ctry_countrycode
   from pos p, detailrs dr
   where p.deliveryno = dr.deliveryno and
          dr.deliveryno = p.deliveryno and
          dr.entry_no = entryno;


 cursor c5(cid integer) is select * from customers where customer_id = cid;

 cursor c6(parm1 number, parm2 varchar2 ) is
  select /*+ ALL_ROWS */ sum(revton * c.freight * d.exrate) sm
  from customers c, detailrs dr, receivals r, movements m, ships_airway s, duty d
  where dr.entry_no = parm1 and
        d.entry_no = dr.entry_no and
        c.customer = parm2 and
        m.ship_id = s.ship_id and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        nvl(r.cust_customer_id,0) = c.customer_id and
        customer_type = 'CUSTOMER';

 cursor c7(entryno number) is
  select /*+ ALL_ROWS */ distinct c.customer, c.street, c.suburb, c.state, c.postcode, c.country, r.curr, d.exrate
  from receivals r, detailrs dr, customers c, duty d
  where dr.entry_no = entryno and
        d.entry_no = dr.entry_no and
        dr.deliveryno = r.deliveryno and
        nvl(r.supplier_customer_id,0) = c.customer_id and
        c.customer_type = 'SUPPLIER';

 cursor c8(custname varchar2) is
  select /*+ ALL_ROWS */ *
  from customers
  where customer = custname and
        customer_type = 'CUSTOMER';

 cursor c9(entryno number) is
  select /*+ ALL_ROWS */ *
  from duty
  where entry_no = entryno;

 cursor c10(custid integer) is
  select /*+ ALL_ROWS */ *
  from customers
  where customer_id = custid;

 cursor c11a(entryno number) is
  select count('x') cnt
  from duty d
  where previous_entry_no = entryno;

 cursor c11b(entryno number) is
  select min(line_no) mn, max(line_no) mx
  from detailrs dr
  where entry_no = entryno;

 cursor c11(shpid integer, entryno number, parm2 varchar2) is
  select /*+ ALL_ROWS */ dr.entry_no, min(line_no) mn, max(line_no) mx
  from detailrs dr, receivals r, movements m
  where m.ship_id = shpid and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        dr.deliveryno in
         (select dr2.deliveryno from detailrs dr2 where dr2.entry_no = entryno)
  group by dr.entry_no;

 cursor c11c(shpid integer, entryno number, parm2 varchar2) is
  select /*+ ALL_ROWS */ dr.entry_no, line_no, dr.deliveryno, dr.itemno
  from detailrs dr, receivals r, movements m
  where m.ship_id = shpid and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        dr.deliveryno in
         (select dr2.deliveryno from detailrs dr2 where dr2.entry_no = entryno)
  order by dr.entry_no,line_no;

 cursor c11d(shpid integer, entryno number, parm2 varchar2) is
  select count(line_no) no_of_line_nos
  from detailrs dr, receivals r, movements m
  where m.ship_id = shpid and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        dr.deliveryno in
         (select dr2.deliveryno from detailrs dr2 where dr2.entry_no = entryno);

 cursor c12( entryno number ) is
   select /*+ ALL_ROWS */ nvl(m.bol,m.movement_no) bol
    from detailrs dr, movements m
    where dr.entry_no = entryno and
          m.movement_no = dr.movement_no and
          nvl(m.seal,'|') = nvl(dr.camov_seal,'|');

cursor c13( entryno number ) is
 select /*+ ALL_ROWS */ l1.description, pktpe_packtype, sum(qty) tot
 from detailrs dr, lov l1
 where entry_no = entryno and
       l1.lov_name = 'PACKTYPES' and
       l1.code = dr.pktpe_packtype
 group by l1.description, pktpe_packtype;

cursor c13a( entryno number ) is
 select /*+ ALL_ROWS */ sum(qty) tot
 from detailrs dr
 where entry_no = entryno;

cursor c13b(shpid integer, entryno number) is
 select /*+ ALL_ROWS */ dr.entry_no, l1.description, pktpe_packtype, sum(qty) tot
 from detailrs dr, lov l1, receivals r, movements m
  where m.ship_id = shpid and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        dr.deliveryno in
         (select dr2.deliveryno from detailrs dr2 where dr2.entry_no = entryno) and
        l1.lov_name = 'PACKTYPES' and
        l1.code = dr.pktpe_packtype
 group by dr.entry_no, l1.description, pktpe_packtype;

cursor c14( entryno number ) is
 select /*+ ALL_ROWS */ distinct po
 from detailrs dr, pos p
 where entry_no = entryno and
       p.deliveryno = dr.deliveryno
 order by po;

cursor c14b(shpid integer, entryno number, parm2 varchar2) is
 select /*+ ALL_ROWS */ distinct po
 from detailrs dr, receivals r, movements m, pos p
  where m.ship_id = shpid and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        dr.deliveryno in
         (select dr2.deliveryno from detailrs dr2 where dr2.entry_no = entryno) and
        p.deliveryno = dr.deliveryno
 order by po;

cursor c15( entryno number, pktpe varchar2 ) is
 select /*+ ALL_ROWS */ detaildesc
 from detailrs
 where entry_no = entryno and
       pktpe_packtype = pktpe
 group by detaildesc;

cursor c15b( entryno number ) is
 select distinct detaildesc
 from detailrs
 where entry_no = entryno
 group by detaildesc;


cursor c16( entryno number ) is
 select /*+ ALL_ROWS */ distinct movement_no
 from detailrs dr
 where entry_no = entryno
 order by movement_no;

-- tariff, rate, excise
cursor c17( entryno number ) is
 select /*+ ALL_ROWS */ distinct l1.cola tariff, l2.description, l2.colc
 from pos p, lov l1, lov l2,
 (select entry_no
  from strang.duty
  where entry_no = entryno and
       nvl(previous_entry_no,0) = 0 ) z2
 where l1.lov_name = 'INVENT' and
       l2.lov_name = 'TARIFF' and
       l1.cola = l2.code and
       l1.code = p.inventoryno and
       p.deliveryno in
       (select distinct deliveryno
        from detailrs dr
        where dr.entry_no = entryno);

cursor c17x( entryno number ) is
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
       ) and
      (l1.cola,l1.code) not in
      (select x1.cola, x1.code
       from
       (
        select /*+ ALL_ROWS */ distinct z1.cola, z1.code
        from strang.detailrs dr, strang.pos p, strang.lov z1
        where entry_no = entryno and
              p.deliveryno = dr.deliveryno and
              p.inventoryno = z1.code and
              z1.lov_name = 'INVENT'
        order by z1.cola
       ) x1
      where rownum < 5
      );

cursor c18( entryno number ) is
 select /*+ ALL_ROWS */ min(line_no) line_no, m.movement_no, ship_id
 from detailrs dr, movements m
 where entry_no = entryno and
       dr.movement_no = m.movement_no and
       nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
 group by m.movement_no,ship_id;

cursor c19( shipid integer ) is
 select /*+ ALL_ROWS */ *
 from ships_airway
 where ship_id = shipid;


 cursor c20(entryno number, tariff varchar2) is
  select /*+ ALL_ROWS */ distinct description
  from lov l1, detailrs dr, pos p
  where l1.cola = tariff and
        dr.entry_no = entryno and
        p.inventoryno = l1.code and
        dr.deliveryno = p.deliveryno and
        lov_name = 'INVENT';


cursor c21( entryno number ) is
 select /*+ ALL_ROWS */  count( distinct l1.cola ) tot
 from pos p, lov l1, detailrs dr
 where dr.entry_no = entryno and
       dr.deliveryno = p.deliveryno and
       p.inventoryno = l1.code and
       l1.lov_name = 'INVENT';


 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4arec		c4a%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c9rec		c9%ROWTYPE;
 c10rec		c10%ROWTYPE;
 c11rec		c11%ROWTYPE;
 c11arec	c11a%ROWTYPE;
 c11brec	c11b%ROWTYPE;
 c11crec	c11c%ROWTYPE;
 c11drec	c11d%ROWTYPE;
 c12rec		c12%ROWTYPE;
 c13arec	c13a%ROWTYPE;
 c15brec	c15b%ROWTYPE;
 c18rec		c18%ROWTYPE;
 c19rec		c19%ROWTYPE;
 c20rec		c20%ROWTYPE;
 c21rec		c21%ROWTYPE;
 ttl		number;
 exr		number;
 temptot	number;
 ctr		number;
 tmp		varchar2(32767);
 tmp2		varchar2(32767);
 tmp9		varchar2(32767);
 tmpx		varchar2(32767);
 tmpxcounter    number;
 tmpxprevlineno number;
 tmpxcharprevlineno varchar2(100);
 ctrno          number;
 ctr_code       varchar2(100);
 v_err		varchar2(1000);


 function tot( entryno number, tariff varchar2 )
  return number
 is

   cursor c1(entryno number) is select * from duty where entry_no = entryno;
   cursor c2(entryno number, tariff varchar2 ) is
    select sum(nvl(tamount,0)) tot
    from pos p, lov l1
    where l1.lov_name = 'INVENT' and
          l1.code = p.inventoryno and
          l1.cola = tariff and
          p.deliveryno in
          (select distinct deliveryno
           from detailrs dr
           where dr.entry_no = entryno);

   c1rec c1%ROWTYPE;
   c2rec c2%ROWTYPE;

 begin
    open c1(entryno);
    fetch c1 into c1rec;
    close c1;
    open c2(entryno,tariff);
    fetch c2 into c2rec;
    close c2;
    return(round(c1rec.ratio_factor * c2rec.tot,2));
 end;

begin
 if parm_id = 'A00'
  then
  -- Calculate total items
  open c21(parm1);
   fetch c21 into c21rec;
   close c21;
    return( to_char(c21rec.tot) );
   end if;

 if parm_id = 'A000'
  then
  -- Calculate total packages
  open c13a(parm1);
   fetch c13a into c13arec;
   close c13a;
    return( to_char(c13arec.tot) );
   end if;

 if parm_id = '000A'
  then
  -- Get first country of origin code
  open c4a(parm1);
   fetch c4a into c4arec;
   close c4a;
    return( c4arec.ctry_countrycode );
   end if;

 if parm_id = 'A0'
  then
   -- Calculate total Page Numbers
   open c21(parm1);
   fetch c21 into c21rec;
   close c21;
   if c21rec.tot < 2
    then
     return( '1' );
   else
    c21rec.tot := trunc((c21rec.tot - 2) / 3) + 2;
    return( to_char(c21rec.tot) );
   end if;

 elsif parm_id = 'A1'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   websys.strangp.generate_ships_manifest( c1rec.ship_id ,'EXCISE', 'SHIP', parm1, WEBSYS.OLTP.USER_SITE );
   return( NULL );
    -- recalculate duty table values
 elsif parm_id = 'A2'
  then
   -- from customers
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.cpc );
 elsif parm_id = 'A3'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.sad_cuo_code );
 elsif parm_id = 'A4'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   return( c7rec.customer );
 elsif parm_id = 'A4X'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   return( c7rec.street || ', ' || c7rec.suburb );
 elsif parm_id = 'A4XX'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   return( c7rec.state || ' ' || c7rec.postcode || ' ' ||  c7rec.country );
 elsif parm_id = 'A5'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.p2acode );
 elsif parm_id = 'A6'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.customer );
 elsif parm_id = 'A6X'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.street || ' ' || c8rec.suburb || ' ' ||  c8rec.state || ' ' || c8rec.postcode );

 elsif parm_id = 'A6XX'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.country );

 elsif parm_id = 'A7'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   open c2a('COUNTRIES',c7rec.curr);
   fetch c2a into c2rec;
   close c2a;
   return( c2rec.code );

 elsif parm_id = 'A7X'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   open c2a('COUNTRIES',c7rec.curr);
   fetch c2a into c2rec;
   close c2a;
   return( c2rec.description );


 elsif parm_id = 'A8'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.terms_of_delivery );
 elsif parm_id = 'A9'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   return( round(nvl(c9rec.exrate,1),4) );
 elsif parm_id = 'AA'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     return( c9rec.ratio_factor );
    else
     return( '&nbsp;' );
   end if;
 elsif parm_id = 'AB'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   open c2('LOCATIONS',c1rec.portload);
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'AC'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   open c10(c8rec.customs_agent);
   fetch c10 into c10rec;
   close c10;
   return( c10rec.customer );
 elsif parm_id = 'AD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.account_number );
 elsif parm_id = 'AE'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     open c3(parm1,parm2);
     fetch c3 into c3rec;
     close c3;
     return( to_char(c3rec.sm,'99999999.99') );
    else
     return( '&nbsp;' );
   end if;

 elsif parm_id = 'AF'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   open c2a('COUNTRIES',c7rec.curr);
   fetch c2a into c2rec;
   close c2a;
   return( c2rec.cola );

 elsif parm_id = 'AG'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     return( to_char(c9rec.correct_freight * nvl(c9rec.exrate,1),'99999999.99') );
    else
     return( '&nbsp;' );
   end if;

 elsif parm_id = 'AH'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.licence_no );

 elsif parm_id = 'AHH'
  then
 --  return( to_char(sysdate,'YYYY')  || ' / ' ||  to_char(parm1,'9999999.9999999') );
  return( to_char(sysdate,'YYYY')  || ' / ' ||  strang.ent.get_entry_no(parm1,'X') );


 elsif parm_id = 'AI'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     return( to_char(c9rec.insurance * nvl(c9rec.exrate,1),'99999999.99') );
    else
     return( '&nbsp;' );
   end if;

 elsif parm_id = 'AJ'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     return( to_char(c9rec.other_costs * nvl(c9rec.exrate,1),'99999999.99') );
    else
     return( '&nbsp;' );
   end if;

 elsif parm_id = 'AK'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   if c1rec.ship_airway = 'S'
    then
     return( 'SEA&nbsp;&nbsp;&nbsp;&nbsp;1' );
   elsif c1rec.ship_airway = 'A'
    then
     return ('AIR&nbsp;&nbsp;&nbsp;&nbsp;2');
   else
    return( NULL );
   end if;
 elsif parm_id = 'AL'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( to_char(c1rec.estarrive,'DD.MM.YYYY') );
 elsif parm_id = 'AM'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_invoices,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AN'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_packing,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AO'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_order,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AP'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_licence,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AQ'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_freight,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AR'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_other,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;

 elsif parm_id = 'AS'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.shipname || ' ' || c1rec.voy );

 elsif parm_id = 'AT'
  then
   open c11a(parm1);
   fetch c11a into c11arec;
   close c11a;
   if c11arec.cnt = 0
    then
     open c11b(parm1);
     fetch c11b into c11brec;
     close c11b;
      if c11brec.mn = c11brec.mx
       then
        return( c11brec.mn );
       else
        open c1(parm1);
         fetch c1 into c1rec;
        close c1;
        open c11d(c1rec.ship_id, parm1, parm2);
         fetch c11d into c11drec;
        close c11d;
        if ( c11drec.no_of_line_nos - ( c11brec.mx - c11brec.mn + 1 ) ) = 0
        then
         return( c11brec.mn || ' - ' || c11brec.mx );
        else
         open c1(parm1);
          fetch c1 into c1rec;
         close c1;
         tmpx := '' ;
         tmpxcounter := 0 ;
         tmpxprevlineno := 0;
         tmpxcharprevlineno := NULL;
         for c11crec in c11c(c1rec.ship_id, parm1, parm2) loop
          if tmpxcounter = 0
           then
            tmpx := tmpx || ', ' || c11crec.line_no;
          else
            if (tmpxprevlineno = to_number(c11crec.line_no,'99999') - 1)
              then
               if (substr(tmpx,(length(tmpx)-length(tmpxcharprevlineno)),1) = ' ')
                  then
                   tmpx := tmpx ||'-'|| c11crec.line_no;
               else
                   if substr(tmpx,(length(tmpx)-length(tmpxcharprevlineno)),1) = '-'
                     then
                     tmpx := substr(tmpx,1,(length(tmpx)-length(tmpxcharprevlineno))) || c11crec.line_no;
                   else
                     tmpx := tmpx || ', ' || c11crec.line_no;
                   end if;
               end if;
            else
              tmpx := tmpx || ', ' || c11crec.line_no;
            end if;
          end if;
          tmpxcounter := tmpxcounter + 1;
          tmpxprevlineno := to_number(c11crec.line_no,'99999');
          tmpxcharprevlineno := c11crec.line_no;
         end loop;
        return( substr(tmpx,2) );
       end if;
      end if;
    else
     open c1(parm1);
     fetch c1 into c1rec;
     close c1;
     for c11rec in c11(c1rec.ship_id, parm1, parm2) loop
      if c11rec.mn = c11rec.mx
       then
        tmp := tmp || ',' || c11rec.mn;
       else
        tmp := tmp || ',' ||  c11rec.mn || ' - ' || c11rec.mx;
      end if;
     end loop;
     return( substr(tmp,2) );
   end if;

 elsif parm_id = 'AU'
  then
   open c12(parm1);
   fetch c12 into c12rec;
   close c12;
   return( c12rec.bol );

 elsif parm_id = 'AV'
  then
   /*
   for c13rec in c13( parm1 ) loop
    tmp := tmp || htf.nl || c13rec.tot;
   end loop;
   return( substr( tmp, (length(htf.nl)*1)+1) );
   */
   return( NULL );



 elsif parm_id = 'AWW'
  then
     -- PO
     for c14rec in c14( parm1 ) loop
      tmp := tmp || c14rec.po || ',';
     end loop;
     tmp := substr(tmp,1,length(tmp)-1) ;
   return( substr(tmp,1,50) );


 elsif parm_id = 'AWWW'
  then
     for c13rec in c13( parm1 ) loop
      tmp9 := c13rec.description ;
      if substr(tmp9,length(tmp9)-2,length(tmp9)) in ('STC','STB')
        then
          tmp9 :=   substr( tmp9,1,length(tmp9)-4) ;
      end if;
      tmp := tmp || c13rec.tot || ' ' || tmp9 || ',';
     end loop;
   tmp := substr(tmp,1,length(tmp)-1);
   return( substr(tmp,1,50) );


 elsif parm_id = 'AWWWW'
 /* then
   -- Movements
   for c16rec in c16( parm1 ) loop
    ctr := ctr + 1;
    tmp := tmp || c16rec.movement_no || ', ';
    if ctr >= 3
      then exit ;
    end if;
   end loop;
 */
 then
   ctrno := 0;
   for c16rec in c16( parm1 ) loop
   if ctrno = 0
   then
     ctr_code := substr(trim(c16rec.movement_no) , 1, 4);
     tmp := '<b><u>' || ctr_code || ':</u></b>';
     ctrno := ctrno + 1;
   end if;
   if substr(trim(c16rec.movement_no) , 1, 4) <> ctr_code
    then
     ctr_code := substr(trim(c16rec.movement_no) , 1, 4);
     tmp := tmp || '<b><u>' || ctr_code || ':</b></u> ';
   end if;
   tmp := tmp || trim(substr(trim(c16rec.movement_no), 5)) || ' ';
  end loop;

   tmp := substr(tmp,1,length(tmp)-1);

   return( tmp );

 elsif parm_id = 'AWWWWW'
  then
/*   open c9( parm1 );    This commented out section will return the detailr description rather than the inventory description which is currently used MAR 06
   fetch c9 into c9rec;
   close c9;
   open c11a(parm1);
   fetch c11a into c11arec;
   close c11a;
   if c11arec.cnt = 0 -- no partshipments
    then
    for c15brec in c15b( parm1 ) loop
      tmp := tmp || c15brec.detaildesc || ',';
    end loop;
    if length(tmp) < 60
      then
      tmp := tmp || htf.nl;
    else
      tmp:= substr(tmp,1,60) || htf.nl || substr(tmp,61,120);
    end if;
   else
     open c1(parm1);
     fetch c1 into c1rec;
     close c1;
      for c15brec in c15b( parm1 ) loop
       tmp := tmp || c15brec.detaildesc || ',';
      end loop;
      if length(tmp) > 60
      then
        tmp := substr(tmp,1,60);
      end if;
   end if;

   tmp := substr(tmp,1,length(tmp)-1);

   open c1(parm1);
   fetch c1 into c1rec;
   close c1;

   if c9rec.previous_entry_no is not null
    then
     open c18(c9rec.previous_entry_no);
     fetch c18 into c18rec;
     close c18;
     open c19(c18rec.ship_id);
     fetch c19 into c19rec;
     close c19;
     tmp := tmp || htf.nl ||
     'DUTY PAYMENT MADE ON THE MANIFEST FOR THE ' ||
     c19rec.shipname || ' ' || c19rec.voy || ', LINE NUMBER ' || c18rec.line_no || '.<BR>WARRANT NO: _____ ' ||
     ' PART SHIPMENT OF CONTAINER NO ' || c18rec.movement_no || '.';
   end if;
*/

   open c9( parm1 );
   fetch c9 into c9rec;
   close c9;
   open c11a(parm1);
   fetch c11a into c11arec;
   close c11a;
   if c11arec.cnt = 0 -- no partshipments
    then
     for c20rec in c20(parm1,parm2) loop
       tmp := tmp || ', ' || c20rec.description;
     end loop;
    if length(tmp) > 60
     then
      tmp:= substr(tmp,1,60) || htf.nl || substr(tmp,61,120);
    end if;

   else
     open c1(parm1);
     fetch c1 into c1rec;
     close c1;
     for c20rec in c20(parm1,parm2) loop
      tmp := tmp || ', ' || c20rec.description;
     end loop;
     if length(tmp) > 60
      then
        tmp := substr(tmp,1,60);
     end if;
    end if;
--         tmp2 := substr(tmp2,length(', ')+1);
   if substr(tmp,1,2) = ', ' then
     tmp:= substr(tmp,3,length(tmp)+1);
   else
     tmp := substr(tmp,1,length(tmp));
   end if;
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;

   if c9rec.previous_entry_no is not null
    then
     open c18(c9rec.previous_entry_no);
     fetch c18 into c18rec;
     close c18;
     open c19(c18rec.ship_id);
     fetch c19 into c19rec;
     close c19;
--     tmp := tmp || htf.nl ||
     tmp := 'DUTY PAYMENT MADE ON THE MANIFEST FOR THE ' ||
     c19rec.shipname || ' ' || c19rec.voy || ', LINE NUMBER ' || c18rec.line_no || '.<BR>WARRANT NO: _____ ' ||
     ' PART SHIPMENT OF CONTAINER NO ' || c18rec.movement_no || '.';
   end if;
   return(tmp);


/*
 elsif parm_id = 'AW'
  then
   open c9( parm1 );
   fetch c9 into c9rec;
   close c9;
   open c11a(parm1);
   fetch c11a into c11arec;
   close c11a;
   if c11arec.cnt = 0 -- no partshipments
    then
     tmp := htf.tableopen;
     for c13rec in c13( parm1 ) loop
      tmp := tmp || htf.tablerowopen || htf.tabledata(c13rec.tot, cattributes=>'width=50 valign="TOP" style="font-size:7.0pt; font-family:Arial"');
      for c15rec in c15( parm1, c13rec.pktpe_packtype ) loop
       tmp2 := tmp2 || c15rec.detaildesc || ',';
      end loop;

      tmp := tmp || htf.tabledata(c13rec.description || ':' || substr(tmp2,1,length(tmp2)-1), cattributes=>'valign="TOP" style="font-size:7.0pt; font-family:Arial"') || htf.tablerowclose;
      tmp2 := NULL;
     end loop;
     tmp := tmp || htf.tableclose;
     -- PO
     for c14rec in c14( parm1 ) loop
      tmp := tmp || c14rec.po || ',';
     end loop;
   else
     open c1(parm1);
     fetch c1 into c1rec;
     close c1;
     tmp := htf.tableopen;
     for c13brec in c13b(c1rec.ship_id, parm1) loop
      tmp := tmp || htf.tablerowopen || htf.tabledata(c13brec.tot, cattributes=>'width=50 valign="TOP" style="font-size:7.0pt; font-family:Arial"');
      for c15rec in c15( c13brec.entry_no, c13brec.pktpe_packtype ) loop
       tmp2 := tmp2 || c15rec.detaildesc || ',';
      end loop;
      tmp := tmp || htf.tabledata(c13brec.description || ':' || substr(tmp2,1,length(tmp2)-1), cattributes=>'valign="TOP" style="font-size:7.0pt; font-family:Arial"') || htf.tablerowclose;
      tmp2 := NULL;
     end loop;
     tmp := tmp || htf.tableclose;
     -- PO
     for c14brec in c14b(c1rec.ship_id, parm1, parm2) loop
      tmp := tmp || c14brec.po || ',';
     end loop;
   end if;

   -- Movements
   for c16rec in c16( parm1 ) loop
    tmp := tmp || c16rec.movement_no || ',';
   end loop;

   open c1(parm1);
   fetch c1 into c1rec;
   close c1;

   tmp := substr(tmp,1,length(tmp)-1) || htf.nl || htf.nl || c1rec.pcomment;

   if c9rec.previous_entry_no is not null
    then
     open c18(c9rec.previous_entry_no);
     fetch c18 into c18rec;
     close c18;
     open c19(c18rec.ship_id);
     fetch c19 into c19rec;
     close c19;
     tmp := tmp || htf.nl ||
     'I HEREBY DECLARE THAT THE VALUE FOR THE ABOVE MENTIONED GOODS HAD BEEN ENTERED FOR DUTY PAYMENT ON THE MANIFEST FOR THE ' ||
     c19rec.shipname || ' ' || c19rec.voy || ', LINE NUMBER ' || c18rec.line_no || '.<BR>WARRANT NO: _____________________ ' ||
     ' PART SHIPMENT OF CONTAINER NO ' || c18rec.movement_no || '.' || htf.nl;
     open c1(parm1);
     fetch c1 into c1rec;
     close c1;
     open c10(c1rec.customs_agent);
     fetch c10 into c10rec;
     close c10;
     tmp := tmp || c10rec.customer || ' ' || c10rec.street;
   end if;
   return( tmp );
*/



 elsif parm_id = 'AX'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   open c10(c8rec.customs_agent);
   fetch c10 into c10rec;
   close c10;
   return( c10rec.customer );
 elsif parm_id = 'AY'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   --open c10(c1rec.customs_agent);
   --fetch c10 into c10rec;
   --close c10;
   return( c8rec.position );

 elsif parm_id = 'B1-OLD'
  then
   -- in new form calculation is simplified
   return( NULL );
   ttl := 0;
   for c17rec in c17(parm1) loop
     ttl := ttl + tot(parm1,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100);
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );
 elsif parm_id = 'B2-OLD'
  then
   ttl := 0;
   for c17rec in c17(parm1) loop
     temptot := tot(parm1,c17rec.tariff);
     ttl := ttl + ((temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100));
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );
 elsif parm_id = 'B3-OLD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   ttl := 0;
   for c17rec in c17(parm1) loop
    temptot := tot(parm1,c17rec.tariff);
    ttl := ttl +
       (temptot +
          temptot * (nvl(to_number(c17rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

  elsif parm_id = 'B2'
  then
   -- Total First Page
   ttl := 0;
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   for c17rec in c17(parm1) loop
     if c17%ROWCOUNT > 4 then exit; end if;
     ttl := ttl + tot(parm1,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100);
   end loop;
   for c17rec in c17(parm1) loop
     if c17%ROWCOUNT > 4 then exit; end if;
     ttl := ttl + ((tot(parm1,c17rec.tariff) + tot(parm1,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100));
   end loop;
   for c17rec in c17(parm1) loop
    if c17%ROWCOUNT > 4 then exit; end if;
    temptot := tot(parm1,c17rec.tariff);
    ttl := ttl +
       (temptot +
          temptot * (nvl(to_number(c17rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;
/* 2 % LEVY CALCULATION
*/
   for c17rec in c17(parm1) loop
    if c17%ROWCOUNT > 4 then exit; end if;
    temptot := tot(parm1,c17rec.tariff);

    ttl := ttl +
       round(((nvl(to_number(c8rec.levy_rate),0)/100)*(temptot +
		(round(temptot * (nvl(to_number(c17rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) *
                (nvl(to_number(c17rec.colc),0)/100),2)))),2);
   end loop;



   return( to_char(round(ttl,2),'999999990.99') );

  elsif parm_id = 'B3'
  then
   -- Total Other Pages
   ttl := 0;
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   for c17rec in c17(parm1) loop
     if c17%ROWCOUNT > 4 then
      ttl := ttl + tot(parm1,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100);
     end if;
   end loop;
   for c17rec in c17(parm1) loop
     if c17%ROWCOUNT > 4 then
       ttl := ttl + ((tot(parm1,c17rec.tariff) + tot(parm1,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100));
      end if;
   end loop;
   for c17rec in c17(parm1) loop
    if c17%ROWCOUNT > 4 then
     temptot := tot(parm1,c17rec.tariff);
     ttl := ttl +
       (temptot +
          temptot * (nvl(to_number(c17rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
     end if;
   end loop;

/* 2 % LEVY CALCULATION
*/
   for c17rec in c17(parm1) loop
    if c17%ROWCOUNT > 4 then
     temptot := tot(parm1,c17rec.tariff);
     ttl := ttl +
       round(((nvl(to_number(c1rec.levy_rate),0)/100)*(temptot +
		(round(temptot * (nvl(to_number(c17rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) *
                (nvl(to_number(c17rec.colc),0)/100),2)))),2);
     end if;
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

elsif parm_id = 'TOT_FEES'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( to_char(round(nvl(c8rec.sad_tot_fees,0)),'999999990.99') );

------
elsif parm_id = 'B4'
  then
   -- Total All Pages
   ttl := 0;
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   for c17rec in c17(parm1) loop
     ttl := ttl + tot(parm1,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100);
   end loop;
   for c17rec in c17(parm1) loop
     ttl := ttl + ((tot(parm1,c17rec.tariff) + tot(parm1,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100));
   end loop;
   for c17rec in c17(parm1) loop
    temptot := tot(parm1,c17rec.tariff);
    ttl := ttl +
       (temptot +
          temptot * (nvl(to_number(c17rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;
/* 2 % LEVY CALCULATION
*/
   for c17rec in c17(parm1) loop
    temptot := tot(parm1,c17rec.tariff);
     ttl := ttl +
       round(((nvl(to_number(c8rec.levy_rate),0)/100)*(temptot +
		(round(temptot * (nvl(to_number(c17rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) *
                (nvl(to_number(c17rec.colc),0)/100),2)))),2);
   end loop;
   -- Add Total Fees 20150402
   ttl := ttl + nvl(c8rec.sad_tot_fees,0);
   return( to_char(round(ttl,2),'999999990.99') );

 elsif parm_id = 'XB1'
  then
   ttl := 0;
   for c17xrec in c17x(parm1) loop
     ttl := ttl + tot(parm1,c17xrec.tariff) * (nvl(to_number(c17xrec.description),0)/100);
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

 elsif parm_id = 'XB2'
  then
   ttl := 0;
   for c17xrec in c17x(parm1) loop
     temptot := tot(parm1,c17xrec.tariff);
     ttl := ttl + ((temptot + temptot * (nvl(to_number(c17xrec.description),0)/100)) * (nvl(to_number(c17xrec.colc),0)/100));
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

 elsif parm_id = 'XB3'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   ttl := 0;
   for c17xrec in c17x(parm1) loop
    temptot := tot(parm1,c17xrec.tariff);
    ttl := ttl +
       (temptot +
          temptot * (nvl(to_number(c17xrec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17xrec.description),0)/100)) * (nvl(to_number(c17xrec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

 elsif parm_id = 'XB4'
  then
   ttl := 0;
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   for c17xrec in c17x(parm1) loop
     ttl := ttl + tot(parm1,c17xrec.tariff) * (nvl(to_number(c17xrec.description),0)/100);
   end loop;
   for c17xrec in c17x(parm1) loop
     ttl := ttl + ((tot(parm1,c17xrec.tariff) + tot(parm1,c17xrec.tariff) * (nvl(to_number(c17xrec.description),0)/100)) * (nvl(to_number(c17xrec.colc),0)/100));
   end loop;
   for c17xrec in c17x(parm1) loop
    temptot := tot(parm1,c17xrec.tariff);
    ttl := ttl +
       (temptot +
          temptot * (nvl(to_number(c17xrec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17xrec.description),0)/100)) * (nvl(to_number(c17xrec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

 elsif parm_id = 'REPORT_A'
  then
   -- Calculate total Page Numbers to determine if the continuation report should be run
   if parm1 is null then return( 'RUN' ); end if;
   open c21(parm1);
   fetch c21 into c21rec;
   close c21;
   if c21rec.tot < 2
    then
     return( '0' );
   else
     return( 'RUN' );
   end if;

 elsif parm_id = 'REPORT_B'
  then
   -- Calculate total Page Numbers to determine if the continuation report should be run
   if parm1 is null then return( 'RUN' ); end if;
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is not null
    then
     return( '0' );
   else
     return( 'RUN' );
   end if;

 elsif parm_id = 'SIG'
  then
   -- Calculate total Page Numbers to determine if the continuation report should be run
   open c2b('FORM 15 SIGNATURE');
   fetch c2b into c2rec;
   if c2b%NOTFOUND
    then
     close c2b;
     return( '__________________________________________' );
    else
     close c2b;
     return( '<IMG SRC="file:///c:/signature/' || c2rec.description || '" BORDER=0 WIDTH="80" HEIGHT="60">' );
   end if;

 elsif parm_id = 'SAD'
  then
    if upper(parm2) in ( 'YES', 'Y' , 'TRUE' , 'T' )
     then
      generate_sad(parm1, v_err);
    end if;
 elsif parm_id = 'SAD_COM'
  then
    if upper(parm2) in ( 'YES', 'Y' , 'TRUE' , 'T' )
     then
      generate_sad_com(parm1, v_err);
    end if;
 end if;

 return( null );

end f15_parameter_range;
/


GRANT EXECUTE ON STRANG.F15_PARAMETER_RANGE TO WEBSYS;
