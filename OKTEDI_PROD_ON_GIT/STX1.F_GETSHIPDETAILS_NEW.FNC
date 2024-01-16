CREATE OR REPLACE FUNCTION STX1."F_GETSHIPDETAILS_NEW" ( delno in number, itm in number, typ in varchar2, Scope in varchar2 DEFAULT NULL, SECTION in varchar2 default NULL  )
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
    select s.ship_id,s.shipname,s.voy,m.local_bol,dr.local_line_no,s.estdepart,s.estarrive, l1.description depart,l2.description arrive
    from strang.ships_airway s, strang.movements m, strang.detailrs dr,strang.lov l1, strang.lov l2 
    where s.ship_id = m.local_ship_id
    and m.movement_no = dr.movement_no
    and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
    and s.portload = l1.code
    and l1.lov_name = 'LOCATIONS'
    and s.portdisc = l2.code 
    and l2.lov_name  = 'LOCATIONS' 
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
           if (c1rec.ship_id in (1,2)) or (c1rec.ship_id is null) then
             close c1;
             ret_value :=  null ;
           elsif section = 'shipname' then
             close c1;
             return (c1rec.shipname );
           elsif section = 'voyage' then
             close c1;
             return (c1rec.voy);
           elsif section = 'bol' then
             close c1;
             return (c1rec.bol);
           elsif section = 'line_no' then
             close c1;
             return (c1rec.line_no); 
           elsif section = 'etd' then
             close c1;
             return (c1rec.estdepart); 
           elsif section = 'eta' then
             close c1;
             return (c1rec.estarrive); 
           elsif section = 'depart' then
             close c1;
             return (c1rec.depart); 
           elsif section = 'arrive' then
             close c1;
             return (c1rec.arrive); 
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
            return( null );
        end if;
   else
    open c2(delno,itm);
    fetch c2 into c2rec;
    if c2%FOUND
    then
       if c2rec.ship_id in (1,2)  or (c2rec.ship_id is null) then
          close c2;
          return( null );
       elsif section = 'shipname' then
          close c2;
          return (c2rec.shipname );
       elsif section = 'voyage' then
          close c2;
          return (c2rec.voy);
       elsif section = 'local_bol' then
          close c2;
          return (c2rec.local_bol);
       elsif section = 'local_line_no' then
          close c2;
          return (c2rec.local_line_no); 
       elsif section = 'etd' then
          close c2;
          return (c2rec.estdepart); 
       elsif section = 'eta' then
          close c2;
          return (c2rec.estarrive); 
       elsif section = 'depart' then
             close c2;
             return (c2rec.depart); 
       elsif section = 'arrive' then
             close c2;
             return (c2rec.arrive);    
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
 end F_GETSHIPDETAILS_NEW;
/


GRANT EXECUTE ON STX1.F_GETSHIPDETAILS_NEW TO WEBSYS;
