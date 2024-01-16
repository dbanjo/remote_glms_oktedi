CREATE OR REPLACE function STX1.f_getAirDetails_NEW( delno in number, itm in number, typ in varchar2, section in varchar2 default null)
   return varchar2
  as
   cursor c1(vdelno number, vitm number)  is
    select s.ship_id, m.carrier, m.flight,m.dispatch_date, l1.description depart, l2.description arrive
    from strang.ships_airway s, strang.movements m, strang.detailrs dr, strang.lov l1, strang.lov l2
    where s.ship_id = m.ship_id
    and m.movement_no = dr.movement_no
    and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
    and nvl(s.li,'I') = 'I'
    and delno=dr.deliveryno
    and vitm = dr.itemno
    and m.departure = l1.code
    and l1.lov_name = 'LOCATIONS'
    and m.arrival = l2.code
    and l2.lov_name = 'LOCATIONS';

   cursor c2(vdelno number,vitm number)  is
    select s.ship_id, m.carrier, m.flight,m.dispatch_date, l1.description depart, l2.description arrive
    from strang.ships_airway s, strang.movements m, strang.detailrs dr, strang.lov l1, strang.lov l2
    where s.ship_id = m.ship_id
   -- and m.movement_no = dr.movement_no
  --  and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
    and m.movement_no = dr.movement_no_2
    and nvl(m.seal,'|') = nvl(dr.camov_seal_2,'|')
    and nvl(s.li,'I') = 'L'
    and delno=dr.deliveryno
    and vitm = dr.itemno
    and m.departure = l1.code
    and l1.lov_name = 'LOCATIONS'
    and m.arrival = l2.code
    and l2.lov_name = 'LOCATIONS'
    union
    select s.ship_id, m.carrier, m.flight,m.dispatch_date, l1.description depart, l2.description arrive
    from strang.ships_airway s, strang.movements m, strang.detailrs dr, strang.lov l1, strang.lov l2
    where s.ship_id = m.ship_id
   -- and m.movement_no = dr.movement_no
  --  and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
    and m.movement_no = dr.movement_no
    and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
    and nvl(s.li,'I') = 'L'
    and delno=dr.deliveryno
    and vitm = dr.itemno
    and m.departure = l1.code
    and l1.lov_name = 'LOCATIONS'
    and m.arrival = l2.code
    and l2.lov_name = 'LOCATIONS'
    ;

   cursor c3(vdelno number,vitm number)  is
    select domestic_carrier, domestic_flight_date, hawb_warehouse_dest
    from strang.detailrs dr, strang.hawbs h
    where
    dr.movement_no = h.mawb
    and dr.hawb_hawbno = h.hawb
    and delno=dr.deliveryno
    and vitm = dr.itemno;


   c1rec  c1%ROWTYPE;
   c2rec  c2%ROWTYPE;
   c3rec  c3%ROWTYPE;

   begin
   if typ = 'I'  then
    open c1(delno,itm);
    fetch c1 into c1rec;
    if c1%FOUND
     then
     if (c1rec.ship_id in (3)) or (c1rec.ship_id is null) then
      close c1;
      return( null );
     elsif section = 'Carrier' then
      close c1;
      return (c1rec.carrier);
     elsif section = 'flight' then
      close c1;
      return (c1rec.flight);
     elsif section = 'depart' then
      close c1;
      return (c1rec.depart);
     elsif section = 'arrive' then
      close c1;
      return (c1rec.arrive); 
     elsif section = 'dispatch_date' then
      close c1;
      return (c1rec.dispatch_date); 
     end if;
     
     if (c1rec.ship_id in (3)) or (c1rec.ship_id is null) then
      close c1;
      return( null );
     end if;
      close c1;
       return( c1rec.carrier || '&nbsp;&nbsp;' || c1rec.flight || htf.nl || 'From: '||to_char(c1rec.depart)|| htf.nl|| 'To: '||to_char(c1rec.arrive)|| htf.nl||'Flight Date: '|| to_char(c1rec.dispatch_date));
     else
       close c1;
       return( null );
    end if;
--   elsif typ = 'L' then
--    open c3(delno,itm);
--    fetch c3 into c3rec;
--    if c3%FOUND
--     then
--      close c3;
--       return( 'Domestic'||htf.nl|| 'Carrier: '||c3rec.domestic_carrier || '&nbsp;&nbsp;' || htf.nl || 'Domestic'||htf.nl||'Flight Date: '||to_char(c3rec.domestic_flight_date));
--     else
--       close c3;
--       return( null );
--    end if;
--   elsif typ = 'I' and section is not null  then
--    open c1(delno,itm);
--    fetch c1 into c1rec;
--    if c1%FOUND
      
    
    
   else
    open c2(delno,itm);
    fetch c2 into c2rec;
    if c2%FOUND
     then
     if (c2rec.ship_id in (0)) or (c2rec.ship_id is null) then
      close c2;
      return( null );
     elsif section = 'Carrier' then
      close c2;
      return (c2rec.carrier);
     elsif section = 'flight' then
      close c2;
      return (c2rec.flight);
     elsif section = 'depart' then
      close c2;
      return (c2rec.depart);
     elsif section = 'arrive' then
      close c2;
      return (c2rec.arrive); 
     elsif section = 'dispatch_date' then
      close c2;
      return (c2rec.dispatch_date); 
     end if;
       close c2;
       return( c2rec.carrier || '&nbsp;&nbsp;' || c2rec.flight || htf.nl || 'From: '||to_char(c2rec.depart)|| htf.nl|| 'To: '||to_char(c2rec.arrive)|| htf.nl||'Flight Date: '|| to_char(c2rec.dispatch_date));
     else
       close c2;
       return( null );
     end if;
   end if;
 end f_getAirDetails_NEW;
/
