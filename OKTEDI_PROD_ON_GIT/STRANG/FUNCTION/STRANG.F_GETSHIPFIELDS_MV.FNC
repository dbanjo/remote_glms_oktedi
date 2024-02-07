CREATE OR REPLACE function STRANG.f_getShipFields_mv( mv in varchar2, sl in varchar2, typ in varchar2, fld in varchar2 )
   return varchar2
  as
   cursor c1(vMv varchar2, vSl varchar2)  is
    select s.ship_id,s.shipname,s.voy,s.estdepart,s.estarrive
    from strang.ships_airway s, strang.movements m
    where s.ship_id = m.ship_id
    and m.movement_no = vMv
    and nvl(m.seal,'|') = nvl(vSl,'|')
    and s.ship_id > 10;

   cursor c2(vMv varchar2, vSl varchar2)  is
    select s.ship_id,s.shipname,s.voy,s.estdepart,s.estarrive, s.portload, s.portdisc
    from strang.ships_airway s, strang.movements m
    where s.ship_id = m.local_ship_id
    and m.movement_no = vMv
    and nvl(m.seal,'|') = nvl(vSl,'|')
    and s.ship_id > 10;

   c1rec  c1%ROWTYPE;
   c2rec  c2%ROWTYPE;

   begin
   if typ = 'I' then
    open c1(mv,sl);
    fetch c1 into c1rec;
    if c1%FOUND
     then
     if (c1rec.ship_id in (1,2)) or (c1rec.ship_id is null) then
      close c1;
      return( null );
     end if;
      close c1;
       if fld = 'SHIPNAME' then
         return(nvl(c1rec.shipname,' '));
       elsif fld = 'VOY' then
         return(nvl(c1rec.voy,' '));
       elsif fld = 'ESTARRIVE' then
         return( nvl(to_char(c1rec.estarrive),' '));
       elsif fld = 'SHIP_ID' then
         return(nvl(to_char(c1rec.ship_id),' '));
       else
         return(' ');
       end if;
     else
       close c1;
       return( null );
    end if;
   elsif typ = 'L' then
    open c2(mv,sl);
    fetch c2 into c2rec;
    if c2%FOUND
     then
      if c2rec.ship_id in (1,2)  or (c2rec.ship_id is null) then
       close c2;
       return( null );
      end if;
       close c2;
       if fld = 'SHIPNAME' then
         return(nvl(c2rec.shipname,' '));
       elsif fld = 'VOY' then
         return(nvl(c2rec.voy,' '));
       elsif fld = 'SHIP_ID' then
         return(nvl(to_char(c2rec.ship_id),' '));
       elsif fld = 'ESTARRIVE' and c2rec.ship_id <> 9001655 then
         return( nvl(to_char(c2rec.estarrive),' '));
       elsif fld = 'ESTDEPART' and c2rec.ship_id <> 9001655 then
         return( nvl(to_char(c2rec.estdepart),' '));
       elsif fld = 'PORTLOAD' then
         return( nvl(to_char(c2rec.portload),' '));
       elsif fld = 'PORTDISC' then
         return( nvl(to_char(c2rec.portdisc),' '));
       else
         return(' ');
       end if;
     else
       close c2;
       return( null );
     end if;
   else
     return( null );
   end if;



 end f_getShipFields_mv;
/


GRANT EXECUTE ON STRANG.F_GETSHIPFIELDS_MV TO WEBSYS;
