CREATE OR REPLACE function STX1.f_getAirDates_NEW( delno in number,itm in number, typ in varchar2, section in varchar2 default null )
   return varchar2
  as
   cursor c1(vdelno number, vitm number)  is
    select s.ship_id, m.dispatch_date, l.description arr, l2.description warehouse_location, s.li
    from strang.ships_airway s, strang.movements m, strang.detailrs dr, strang.lov l, strang.lov l2
    where s.ship_id = m.ship_id
    and m.movement_no = dr.movement_no
    and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
    and m.arrival = l.code
    and m.warehouse_destination = l2.code (+)
    and l2.lov_name (+) = 'LOCATIONS'
    and l.lov_name = 'LOCATIONS'
    and delno=dr.deliveryno
    and vitm = dr.itemno;


   cursor c2(vdelno number,vitm number)  is
    select s.ship_id, m.dispatch_date, l.description arr, dr.io, l2.description warehouse_location, s.li
    from strang.ships_airway s, strang.movements m, strang.detailrs dr, strang.lov l, strang.lov l2
    where s.ship_id = m.ship_id
    and m.movement_no = dr.movement_no_2
    and nvl(m.seal,'|') = nvl(dr.camov_seal_2,'|')
    and m.arrival = l.code
    and m.warehouse_destination  = l2.code (+)
    and l2.lov_name (+) = 'LOCATIONS'
    and m.io = 'I'
    and l.lov_name = 'LOCATIONS'
    and delno=dr.deliveryno
    and vitm = dr.itemno;

   cursor c3(vdelno number,vitm number)  is
    select domestic_carrier, domestic_flight_date, hawb_warehouse_dest, dr.io
    from strang.detailrs dr, strang.hawbs h
    where
    dr.movement_no = h.mawb
    and dr.hawb_hawbno = h.hawb
    and delno=dr.deliveryno
    and vitm = dr.itemno;
    
--   cursor c4(vDelno number, vItem number, vli varchar2 )  is 
--   select m.movement_no,  ss.ship_id, ss.li
--    from  strang.movements m, strang.detailrs dr, strang.ships_airway ss
--    where (( m.movement_no = dr.movement_no
--    and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')) OR
--    ( m.movement_no = dr.movement_no_2
--    and nvl(m.seal,'|') = nvl(dr.camov_seal_2,'|'))) 
--    and ss.ship_id = m.ship_id
--    and vDelno = dr.deliveryno
--    and vItem = dr.itemno
--    and ss.li = vli;
    
   c1rec  c1%ROWTYPE;
   c2rec  c2%ROWTYPE;
   c3rec  c3%ROWTYPE;
  -- c4rec_int  c4%ROWTYPE;
 --  c4rec_local  c4%ROWTYPE;


 begin
   
   
   if typ = 'I' then
      open c1(delno,itm);
      fetch c1 into c1rec;
      if c1%FOUND then
         if (c1rec.ship_id in (3)) or (c1rec.ship_id is null) then
            close c1;
            return( null );
         else
            close c1;
            if nvl(to_char(c1rec.arr),'NONE') = 'TABUBIL' then
               return( '');
            else
               if section = 'DISPATCH_DATE' then
                  return to_char(c1rec.dispatch_date);
               elsif  section = 'ARRIVE' then
                  return to_char(c1rec.arr);
               else
                  return( nvl(to_char(c1rec.dispatch_date),'')||' '||nvl(to_char(c1rec.arr),''));
               end if;
            end if;
         end if;
      else
         close c1;
         return( null );
      end if;
   elsif typ = 'L'  then
      open c2(delno,itm);
      fetch c2 into c2rec;
      if c2%FOUND then
         close c2;
         if section = 'DISPATCH_DATE' then
            return to_char(c2rec.dispatch_date);
         elsif  section = 'ARRIVE' then
            return to_char(c2rec.arr);
         else
            return( nvl(to_char(c2rec.dispatch_date),'')||' '||nvl(to_char(c2rec.arr),''));
         end if;
        --  return( nvl(to_char(c2rec.dispatch_date),'&nbsp;')||htf.nl||nvl(to_char(c2rec.arr),'&nbsp;'));
      else
         close c2;
         open c1(delno,itm);
         fetch c1 into c1rec;
         if c1%FOUND then
            close c1;
            if nvl(to_char(c1rec.arr),'NONE') = 'TABUBIL' then  
              if section = 'DISPATCH_DATE' then
                return to_char(c1rec.dispatch_date);
              elsif  section = 'ARRIVE' then
                return to_char(c1rec.arr);
              else
                return( nvl(to_char(c1rec.dispatch_date),'')||' '||nvl(to_char(c1rec.arr),''));
             --   return (null); 
              end if;
              -- return( nvl(to_char(c1rec.dispatch_date),'&nbsp;')||htf.nl||nvl(to_char(c1rec.arr),'&nbsp;'));
               -- return( nvl(to_char(c3rec.domestic_flight_date),'&nbsp;')||htf.nl||nvl(to_char(c3rec.hawb_warehouse_dest),'&nbsp;'));
            else
               close c1;
               return(null);
            end if;
         else
            return( null );
         end if;
      end if;
    elsif typ = 'L1'  then
       open c2(delno,itm);
       fetch c2 into c2rec;
       if c2%FOUND then
          close c2;
          if nvl(c2rec.dispatch_date,sysdate+1) <= sysdate then
             return( 'TABUBIL' );
          else
            return( null );
          end if;
       else
         close c2;
         open c1(delno,itm);
         fetch c1 into c1rec;
         if c1%FOUND then
            close c1;
            if nvl(c1rec.dispatch_date,sysdate+1) <= sysdate and nvl(to_char(c1rec.arr),'NONE') = 'TABUBIL' then
               return( 'TABUBIL' );
            else
               return( c1rec.arr );
            end if;  
         else
            return( null );
         end if;
       end if;
    elsif typ = 'L2' then
       open c2(delno,itm);
       fetch c2 into c2rec;
       if c2%FOUND then
          close c2;
          return( nvl(to_char(c2rec.warehouse_location),''));
       else
          close c2;
          open c1(delno,itm);
          fetch c1 into c1rec;
          if c1%FOUND then    
             return ( nvl(to_char(c1rec.warehouse_location),''));
             close c1;
          else 
             close c1;
             return( null);
          end if; 
       end if;
   else
      open c1(delno,itm);
      fetch c1 into c1rec;
      if c1%FOUND then
         if c1rec.ship_id in (0)  or (c1rec.ship_id is null) then
            close c1;
            return( null );
         else 
            close c1;
            if section = 'DISPATCH_DATE' then
               return to_char(c1rec.dispatch_date);
            elsif  section = 'ARRIVE' then
               return to_char(c1rec.arr);
            else
               return( nvl(to_char(c1rec.dispatch_date),'')||' '||nvl(to_char(c1rec.arr),''));
            --   return (null); 
            end if;
            
            
          --  return( nvl(to_char(c1rec.dispatch_date),'')||htf.nl||nvl(to_char(c1rec.arr),''));
         end if;
      else
         close c1;
         return( null );
      end if;
   end if;
exception 
  WHEN others then
    return null;  
 end f_getAirDates_new;
/
