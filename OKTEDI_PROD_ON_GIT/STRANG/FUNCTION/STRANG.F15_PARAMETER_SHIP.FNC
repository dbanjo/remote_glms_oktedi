CREATE OR REPLACE function STRANG.f15_parameter_ship( parm_id in varchar2, parm1 in varchar2, parm2 in varchar2 )
 return varchar2
as

 -- Parm1 = SHIP_ID
 -- Parm2 = CUSTOMER

 cursor c1( parm1 integer ) is
  select *
  from ships_airway
  where ship_id = parm1;

 cursor sf( parm1 integer, parm2 varchar2 ) is
  select /*+ ALL_ROWS */ sum(value)
  from hawbs
  where mawb in
   (select dr.movement_no
    from customers c, detailrs dr, receivals r, movements m
    where m.ship_id = parm1 and
          c.customer = parm2 and
          m.movement_no = dr.movement_no and
          nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
          dr.deliveryno = r.deliveryno and
          nvl(r.cust_customer_id,0) = c.customer_id and
          customer_type = 'CUSTOMER');

 cursor aw( parm1 integer, parm2 varchar2 ) is
  select /*+ ALL_ROWS */ portload departure_airport, portdisc destination_airport, shipname carrier, estdepart flight_date, voy flight
  from customers c, detailrs dr, receivals r, movements m, ships_airway s
  where m.ship_id = parm1 and
        c.customer = parm2 and
        m.ship_id = s.ship_id and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        nvl(r.cust_customer_id,0) = c.customer_id and
        customer_type = 'CUSTOMER';

 cursor c2( lv varchar2, cd varchar2 ) is
  select /*+ ALL_ROWS */ description
  from lov
  where lov_name = lv and
        code = cd;

 cursor c3( parm1 integer, parm2 varchar2 ) is
  select /*+ ALL_ROWS */ sum(p.amount) sm
  from pos p, customers c, detailrs dr, receivals r, movements m, ships_airway s
  where m.ship_id = parm1 and
        c.customer = parm2 and
        m.ship_id = s.ship_id and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        p.deliveryno = r.deliveryno and
        nvl(r.cust_customer_id,0) = c.customer_id and
        customer_type = 'CUSTOMER';

 cursor c4( parm1 integer, parm2 varchar2 ) is
 select /*+ ALL_ROWS */ l.description || ' ' || dr.detaildesc shipmark,sum(qty) qty
 from detailrs dr, lov l
 where movement_no in
       (select dr.movement_no
        from customers c, detailrs dr, receivals r, movements m
        where m.ship_id = parm1 and
          c.customer = parm2 and
          m.movement_no = dr.movement_no and
          nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
          dr.deliveryno = r.deliveryno and
          nvl(r.cust_customer_id,0) = c.customer_id and
          customer_type = 'CUSTOMER') and
       lov_name = 'PACKTYPES' and
       l.code = dr.pktpe_packtype
 group by l.description || ' ' || dr.detaildesc;

 cursor c5(vcust varchar2) is select * from customers where customer = vcust;

 cursor c5a(cid integer) is select * from customers where customer_id = cid;

 cursor c6(parm1 integer, parm2 varchar2 ) is
  select /*+ ALL_ROWS */ sum(revton * c.freight * l2.description) sm
  from customers c, detailrs dr, receivals r, movements m, ships_airway s, lov l2
  where m.ship_id = parm1 and
        c.customer = parm2 and
        l2.lov_name = 'UNRATTAB' and
        l2.code = r.curr and
        l2.cola <= s.estarrive and
        nvl(l2.colb,sysdate+365) >= s.estarrive and
        m.ship_id = s.ship_id and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        nvl(r.cust_customer_id,0) = c.customer_id and
        customer_type = 'CUSTOMER';

 cursor c6a(parm1 integer, parm2 varchar2 ) is
  select /*+ ALL_ROWS */ l2.description exrate
  from customers c, detailrs dr, receivals r, movements m, ships_airway s, lov l2
  where m.ship_id = parm1 and
        c.customer = parm2 and
        l2.lov_name = 'UNRATTAB' and
        l2.code = r.curr and
        l2.cola <= s.estarrive and
        nvl(l2.colb,sysdate+365) >= s.estarrive and
        m.ship_id = s.ship_id and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        nvl(r.cust_customer_id,0) = c.customer_id and
        customer_type = 'CUSTOMER';


 v1		integer;
 awrec		aw%ROWTYPE;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c5arec		c5a%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c6arec		c6a%ROWTYPE;
 tmp		varchar2(32767);

begin
 if parm_id = 'A1'
  then
   open c5(parm2);
   fetch c5 into c5rec;
   close c5;
   return( c5rec.cpc );
 elsif parm_id = 'A2'
  then
   -- Ships_airway
   return( 'A2' );
 elsif parm_id = 'A3'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.portdisc );
 elsif parm_id = 'A4'
  then
   return( 'A4' );
 elsif parm_id = 'A5'
  then
   open c5(parm2);
   fetch c5 into c5rec;
   close c5;
   return( c5rec.p2acode );
 elsif parm_id = 'A6'
  then
   open aw( parm1, parm2 );
   fetch aw into awrec;
   close aw;
   return( awrec.departure_airport );
 elsif parm_id = 'A7'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.port_from );
 elsif parm_id = 'A8'
  then
   open c5(parm2);
   fetch c5 into c5rec;
   close c5;
   return( c5rec.terms_of_delivery );
 elsif parm_id = 'A9'    -- ********************* exrate
  then
   open c6a(parm1,parm2);
   fetch c6a into c6arec;
   close c6a;
   return( c6arec.exrate );
 elsif parm_id = 'AA'
  then
   return( 'AA' );
 elsif parm_id = 'AB'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.portload );
 elsif parm_id = 'AC'
  then
   return( 'AC' );
 elsif parm_id = 'AD'
  then
   open c5(parm2);
   fetch c5 into c5rec;
   close c5;
   return( c5rec.account_number );
 elsif parm_id = 'AE'
  then
   open c3(parm1,parm2);
   fetch c3 into c3rec;
   close c3;
   return( to_char(c3rec.sm,'99999999.99') );
 elsif parm_id = 'AF'
  then
   open sf( parm1, parm2 );
   fetch sf into v1;
   close sf;
   return( 'AUD' );
 elsif parm_id = 'AG'
  then
   open c6(parm1,parm2);
   fetch c6 into c6rec;
   close c6;
   return( c6rec.sm );
 elsif parm_id = 'AH' -- B.Reference
  then
   open c5(parm2);
   fetch c5 into c5rec;
   close c5;
   return( c5rec.licence_no || ' ' );
 elsif parm_id = 'AI'
  then
   open c5(parm2);
   fetch c5 into c5rec;
   close c5;
   open c3(parm1,parm2);
   fetch c3 into c3rec;
   close c3;
   return( to_char( c3rec.sm * (c5rec.insurance / 100),'99999999.99') );
 elsif parm_id = 'AJ'
  then
   open c5(parm2);
   fetch c5 into c5rec;
   close c5;
   open c3(parm1,parm2);
   fetch c3 into c3rec;
   close c3;
   return( to_char( c3rec.sm * (c5rec.other_costs / 100),'99999999.99') );
 elsif parm_id = 'AK'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   if c1rec.ship_airway = 'S'
    then
     return( 'SEA' );
   elsif c1rec.ship_airway = 'A'
    then
     return ('AIR');
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
   open c5(parm2);
   fetch c5 into c5rec;
   close c5;
   if upper(substr(c5rec.attachments_invoices,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AN'
  then
   open c5(parm2);
   fetch c5 into c5rec;
   close c5;
   if upper(substr(c5rec.attachments_packing,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AO'
  then
   open c5(parm2);
   fetch c5 into c5rec;
   close c5;
   if upper(substr(c5rec.attachments_order,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AP'
  then
   open c5(parm2);
   fetch c5 into c5rec;
   close c5;
   if upper(substr(c5rec.attachments_licence,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AQ'
  then
   open c5(parm2);
   fetch c5 into c5rec;
   close c5;
   if upper(substr(c5rec.attachments_freight,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AR'
  then
   open c5(parm2);
   fetch c5 into c5rec;
   close c5;
   if upper(substr(c5rec.attachments_other,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AS'
  then
   for c4rec in c4(parm1,parm2) loop
    tmp := tmp || to_number(c4rec.qty) || htf.nl;
   end loop;
   return( tmp );
 elsif parm_id = 'AT'
  then
   for c4rec in c4(parm1,parm2) loop
    tmp := tmp || c4rec.shipmark || htf.nl;
   end loop;
   return( tmp );
 elsif parm_id = 'AU'
  then
   open c5(parm2);
   fetch c5 into c5rec;
   close c5;
   open c5a(c5rec.customs_agent);
   fetch c5a into c5arec;
   close c5a;
   return( c5arec.customer);
 elsif parm_id = 'AV'
  then
   return( 'CUSTOMS AGENT' );
 elsif parm_id = 'AW'
  then
   return( 'AW' );
 elsif parm_id = 'AX'
  then
   return( 'AX' );
 elsif parm_id = 'AY'
  then
   return( 'AY' );
 elsif parm_id = 'AZ'
  then
   return( 'AZ' );
 elsif parm_id = 'B9'
  then
   open aw( parm1, parm2 );
   fetch aw into awrec;
   close aw;
   return( awrec.carrier || ' V' || awrec.flight );
 elsif parm_id = 'BA'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.pcomment );
 elsif parm_id = 'BB'
  then
   open c6(parm1,parm2);
   fetch c6 into c6rec;
   close c6;
   return( c6rec.sm );
 elsif parm_id = 'BC'
  then
   return( parm2 );
 elsif parm_id = 'BD'
  then
   return( 'BD' );
 end if;
end f15_parameter_ship;
/
