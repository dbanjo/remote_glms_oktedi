CREATE OR REPLACE function STRANG.f_getShipDates( delno in number,itm in number, typ in varchar2 )
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
      return(nvl(to_char(c1rec.portdisc),'&nbsp;'));
     end if;
      close c1;
       return( nvl(to_char(c1rec.estarrive),'&nbsp;')||htf.nl||nvl(to_char(c1rec.portdisc),'&nbsp;'));
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
       return(nvl(to_char(c2rec.portdisc),'&nbsp;'));
      end if;
       close c2;
       if c2rec.status <> 'INCOMPLETE'
       then
        return( nvl(to_char(c2rec.estarrive),'&nbsp;')||htf.nl||nvl(to_char(c2rec.portdisc),'&nbsp;'));
       else
        return( nvl(to_char(c2rec.estarrive)|| htf.nl ||' DRAFT ONLY - NOT CONFIRMED','&nbsp;')||htf.nl||nvl(to_char(c2rec.portdisc),'&nbsp;'));
       end if;
     else
       close c2;
       return( null );
     end if;
   else
    open c3(delno,itm);
    fetch c3 into c3rec;
    if c3%FOUND
     then
      if c3rec.status = 'PLANNING'  then
       close c3;
       return( 'Convoy: '||htf.nl||c3rec.convoy_id||' Scheduled '||htf.nl||nvl(to_char(c3rec.estdepart),'&nbsp;')||htf.nl||nvl(to_char(c3rec.portdisc),'&nbsp;') );
      elsif c3rec.status = 'FINAL' then
       close c3;
       return( 'Convoy: '||htf.nl||c3rec.convoy_id||' Confirmed '||htf.nl||nvl(to_char(c3rec.estdepart),'&nbsp;')||htf.nl||nvl(to_char(c3rec.portdisc),'&nbsp;') );
      else
       close c3;
       return( null );
      end if;
     else
     return( null );
     end if;
   end if;



 end f_getShipDates;
/


GRANT EXECUTE ON STRANG.F_GETSHIPDATES TO STX1;

GRANT EXECUTE ON STRANG.F_GETSHIPDATES TO WEBSYS;
