CREATE OR REPLACE function STX1.f_getShipDates_NEW( delno in number,itm in number, typ in varchar2, section in varchar2 default null  )
   return varchar2
  as
  
   cursor c1(vdelno number, vitm number)  is
    select s.ship_id,s.shipname,s.voy,m.bol,dr.line_no,s.estdepart,s.estarrive, l.description portdisc
    from strang.ships_airway s, strang.movements m, strang.detailrs dr, strang.lov l
    where s.ship_id = m.ship_id
    and l.lov_name = 'LOCATIONS'
    and l.code  = s.portdisc
    and m.movement_no = dr.movement_no
    and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
    and delno=dr.deliveryno
    and vitm = dr.itemno;
    
   cursor c2(vdelno number,vitm number)  is
    select s.ship_id,s.shipname,s.voy,m.local_bol,dr.local_line_no,s.estdepart,s.estarrive,s.status,l.description portdisc
    from strang.ships_airway s, strang.movements m, strang.detailrs dr, strang.lov l
    where s.ship_id = m.local_ship_id
    and l.lov_name = 'LOCATIONS'
    and l.code  = s.portdisc
    and m.movement_no = dr.movement_no
    and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
    and delno=dr.deliveryno
    and vitm = dr.itemno;

   cursor c3(vdelno number,vitm number)  is
    select cn.convoy_id,cn.status,cn.estdepart, l.description portdisc
    from strang.convoy cn, strang.movements m, strang.detailrs dr, strang.lov l
    where cn.convoy_id = m.convoy_id
    and l.lov_name = 'LOCATIONS'
    and l.code  = cn.portdisc
    and m.movement_no = dr.movement_no
    and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
    and delno=dr.deliveryno
    and vitm = dr.itemno;
   


   c1rec  c1%ROWTYPE;
   c2rec  c2%ROWTYPE;
   c3rec  c3%ROWTYPE;

   begin
   if typ = 'I' then
    open c1(delno,itm);
    fetch c1 into c1rec;
    if c1%FOUND
     then
     if (c1rec.ship_id in (1,2)) or (c1rec.ship_id is null) then
      close c1;
      return( null );
     end if;
     if (c1rec.ship_id in (5)) or (c1rec.ship_id is null) then
      close c1;
      return(nvl(to_char(c1rec.portdisc),''));
     end if;
     close c1;
     if section = 'ARRIVAL_DATE' then
        return to_char(c1rec.estarrive);
     elsif  section = 'DISCHARGE_PORT' then
        return to_char(c1rec.portdisc);
     else
        return( nvl(to_char(c1rec.estarrive),'')||' '||nvl(to_char(c1rec.portdisc),''));
     end if;
   --    return( nvl(to_char(c1rec.estarrive),'')||' '||nvl(to_char(c1rec.portdisc),''));
     else
       close c1;
       return( null );
    end if;
   elsif typ = 'L' then
    open c2(delno,itm);
    fetch c2 into c2rec;
    if c2%FOUND
     then
      if c2rec.ship_id in (1,2)  or (c2rec.ship_id is null) then
       close c2;
       return( null );
      end if;
      if c2rec.ship_id in (5)  or (c2rec.ship_id is null) then
       close c2;
       return(nvl(to_char(c2rec.portdisc),''));
      end if;
       close c2;
       if section = 'ARRIVAL_DATE' then
          return to_char(c2rec.estarrive);
       elsif  section = 'DISCHARGE_PORT' then
          return to_char(c2rec.portdisc);
       else
         -- return( null );
          return( nvl(to_char(c2rec.estarrive),'')||' '||nvl(to_char(c2rec.portdisc),''));
       end if;
       
--       if c2rec.status <> 'INCOMPLETE'
--       then
--        return( nvl(to_char(c2rec.estarrive),'')||' '||nvl(to_char(c2rec.portdisc),''));
--       else
--        return( nvl(to_char(c2rec.estarrive)||' '||' DRAFT ONLY - NOT CONFIRMED','')||' '||nvl(to_char(c2rec.portdisc),''));
--       end if;
     else
       close c2;
       return( null );
     end if;
   else
    open c3(delno,itm);
    fetch c3 into c3rec;
    if c3%FOUND
     then
     close c3;
     if section = 'ARRIVAL_DATE' then
        return to_char(c3rec.estdepart);
     elsif  section = 'DISCHARGE_PORT' then
        return to_char(c3rec.portdisc);
     elsif  section = 'CONVOY' then
        return to_char(c3rec.convoy_id);
     else 
        return( null );
     end if;
--      if c3rec.status = 'PLANNING'  then
--       close c3;
--       return( 'Convoy: '||c3rec.convoy_id||' Scheduled: '||nvl(to_char(c3rec.estdepart),'')||' '||nvl(to_char(c3rec.portdisc),'') );
--      elsif c3rec.status = 'FINAL' then
--       close c3;
--       return( 'Convoy: '||c3rec.convoy_id||' Confirmed: '||nvl(to_char(c3rec.estdepart),'')||' '||nvl(to_char(c3rec.portdisc),'') );
--      else
--       close c3;
--       return( null );
--      end if;
     else
     return( null );
     end if;
   end if;

 end f_getShipDates_NEW;
/
