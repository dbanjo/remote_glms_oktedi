CREATE OR REPLACE FUNCTION STRANG."F_GETSHIPDETAILS" ( delno in number, itm in number, typ in varchar2, Scope in varchar DEFAULT NULL  )
   return varchar2
  as
   cursor c1(vdelno number, vitm number)  is
    select s.ship_id,s.shipname,s.voy,m.bol,dr.line_no,s.estdepart,s.estarrive, l1.description depart,l2.description arrive
    from strang.ships_airway s, strang.movements m, strang.detailrs dr,strang.lov l1, strang.lov l2 
    where s.ship_id = m.ship_id
    and m.movement_no = dr.movement_no
    and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
    and s.portload = l1.code
    and l1.lov_name = 'LOCATIONS'
    and s.portdisc = l2.code 
    and l2.lov_name  = 'LOCATIONS' 
    and delno=dr.deliveryno
    and vitm = dr.itemno;

   cursor c2(vdelno number,vitm number)  is
    select s.ship_id,s.shipname,s.voy,m.local_bol,dr.local_line_no,s.estdepart,s.estarrive
    from strang.ships_airway s, strang.movements m, strang.detailrs dr
    where s.ship_id = m.local_ship_id
    and m.movement_no = dr.movement_no
    and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
    and delno=dr.deliveryno
    and vitm = dr.itemno;


   ret_value varchar2(1000);
   c1rec  c1%ROWTYPE;
   c2rec  c2%ROWTYPE;

   begin
   
   
   if typ = 'I' then 
      open c1(delno,itm);
      fetch c1 into c1rec;
        if c1%FOUND
        then
           if (c1rec.ship_id in (1,2,3,4)) or (c1rec.ship_id is null) then
             close c1;
             ret_value :=  null ;
           elsif (c1rec.ship_id in (5)) then
             close c1;
             ret_value := (c1rec.shipname || '&nbsp;&nbsp;' || c1rec.voy );
           elsif scope = 'M' then
              close c1;
              ret_value := (c1rec.shipname || '&nbsp;&nbsp;' || c1rec.voy || htf.nl || 'Bill '||to_char(c1rec.bol));
           elsif scope = 'D' then
              close c1;
              ret_value :=  ( c1rec.depart ||  htf.nl ||'ETD: '|| to_char(c1rec.estdepart) );
           elsif scope = 'A' then
              close c1;
              ret_value :=  ( c1rec.arrive ||  htf.nl ||'ETA: '|| to_char(c1rec.estarrive) );
           else
              close c1;
              ret_value := ( c1rec.shipname || '&nbsp;&nbsp;' || c1rec.voy || htf.nl || 'Bill '||to_char(c1rec.bol)|| htf.nl|| 'M/Line '||to_char(c1rec.line_no)|| htf.nl||'ETD: '|| to_char(c1rec.estdepart)||htf.nl||'ETA: '||to_char(c1rec.estarrive));
           end if;
           return (ret_value);
        else 
            close c1;
            return( 'Received, Receipted and Scheduled for Movement to Site' );
        end if;
   else
    open c2(delno,itm);
    fetch c2 into c2rec;
    if c2%FOUND
    then
       if c2rec.ship_id in (1,2,3,4)  or (c2rec.ship_id is null) then
          close c2;
          return( null );
       elsif c2rec.ship_id in (5) then
          close c2;
          return( c2rec.shipname || '&nbsp;&nbsp;' || c2rec.voy );
       else
          close c2;
          return( c2rec.shipname || '&nbsp;&nbsp;' || c2rec.voy || htf.nl || 'Bill '||to_char(c2rec.local_bol)|| htf.nl|| 'M/Line '||to_char(c2rec.local_line_no)|| htf.nl||'ETD: '|| to_char(c2rec.estdepart)||htf.nl||'ETA: '||to_char(c2rec.estarrive));
       end if;
    else
       close c2;
       return( null );
    end if;
   end if;
 end f_getShipDetails;
/


GRANT EXECUTE ON STRANG.F_GETSHIPDETAILS TO STX1;

GRANT EXECUTE ON STRANG.F_GETSHIPDETAILS TO WEBSYS;
