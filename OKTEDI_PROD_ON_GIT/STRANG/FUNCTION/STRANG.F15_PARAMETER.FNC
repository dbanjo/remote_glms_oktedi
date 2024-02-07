CREATE OR REPLACE function STRANG.f15_parameter( parm_id in varchar2, parm1 in varchar2, parm2 in varchar2 )
 return varchar2
as

 cursor c1( parm1 integer ) is
  select *
  from ships_airway
  where ship_id = parm1;
 cursor sf( parm1 integer, parm2 varchar2 ) is
  select sum(value)
  from hawbs
  where mawb in (select movement_no from movements where ship_id = parm1 and bol = parm2 );
 cursor aw( parm1 integer, parm2 varchar2 ) is
  select portload departure_airport, portdisc destination_airport, shipname carrier, estdepart flight_date, voy flight
  from movements m, ships_airway s
  where m.ship_id = s.ship_id and
        s.ship_id = parm1 and
        m.bol = parm2;
 cursor c2( lv varchar2, cd varchar2 ) is select description from lov where lov_name = lv and code = cd;
 cursor c3( parm1 integer, parm2 varchar2 ) is
  select sum(amount) sm
  from pos
  where deliveryno in
  (select deliveryno from detailrs where movement_no in (select movement_no from movements where ship_id=parm1 and bol=parm2));
 cursor c4( parm1 integer, parm2 varchar2 ) is
 select l.description || ' ' || d.detaildesc shipmark,sum(qty) qty
 from detailrs d, lov l
 where movement_no in (select movement_no from movements where ship_id=parm1 and bol=parm2) and
       lov_name = 'PACKTYPES' and
       l.code = d.pktpe_packtype
 group by l.description || ' ' || d.detaildesc;
 cursor c5(cid integer) is select * from customers where customer_id = cid;
 cursor c6(parm1 integer, parm2 varchar2 ) is
  select sum(revton * s.freight * s.rate) sm
  from movements m, ships_airway s
  where m.ship_id=parm1 and
        bol=parm2 and
        m.ship_id = s.ship_id;

 v1		integer;
 awrec		aw%ROWTYPE;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 tmp		varchar2(32767);

begin
 if parm_id = 'A1'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.cpc );
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
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.p2acode );
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
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.terms_of_delivery );
 elsif parm_id = 'A9'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.rate );
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
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.account_number );
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
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.licence_no || ' ' );
 elsif parm_id = 'AI'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   open c3(parm1,parm2);
   fetch c3 into c3rec;
   close c3;
   return( to_char( c3rec.sm * (c1rec.insurance / 100),'99999999.99') );
 elsif parm_id = 'AJ'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   open c3(parm1,parm2);
   fetch c3 into c3rec;
   close c3;
   return( to_char( c3rec.sm * (c1rec.other_costs / 100),'99999999.99') );
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
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   if upper(substr(c1rec.attachments_invoices,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AN'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   if upper(substr(c1rec.attachments_packing,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AO'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   if upper(substr(c1rec.attachments_order,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AP'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   if upper(substr(c1rec.attachments_licence,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AQ'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   if upper(substr(c1rec.attachments_freight,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AR'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   if upper(substr(c1rec.attachments_other,1,1)) = 'Y'
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
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   open c5(c1rec.customs_agent);
   fetch c5 into c5rec;
   close c5;
   return( c5rec.customer);
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
end f15_parameter;
/
