CREATE OR REPLACE function STRANG.f_count_bbctr( shipid in number,ecn in varchar2, typ in varchar2 )
   return varchar2
  as
   cursor c1(vshipid number, vecn varchar2)  is
    select count (dr.qty) tot
    from strang.detailrs dr, strang.ships_airway s, strang.movements m
    where s.ship_id = m.ship_id
    and s.ship_id = vshipid
    and m.movement_no = dr.movement_no
    and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
    and m.movement_type in ('CONMOV','AIRWAY')
    and vecn = dr.ecn;

   cursor c2(vshipid number, vecn varchar2)  is
    select count (distinct m.movement_no) tot
    from strang.detailrs dr, strang.ships_airway s, strang.movements m
    where s.ship_id = m.ship_id
    and s.ship_id = vshipid
    and m.movement_no = dr.movement_no
    and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
    and m.movement_type = 'CARGO'
    and vecn = dr.ecn;


   c1rec  c1%ROWTYPE;
   c2rec  c2%ROWTYPE;

   begin
   if typ = 'BB' then
    open c1(shipid,ecn);
    fetch c1 into c1rec;
    if c1%NOTFOUND
     then
      close c1;
      return( to_char('0') );
     else
      close c1;
       return( nvl(to_char(c1rec.tot),'&nbsp;'));
    end if;
   elsif typ = 'CTR' then
    open c2(shipid,ecn);
    fetch c2 into c2rec;
    if c2%NOTFOUND
     then
      close c2;
      return( to_char('0') );
     else
      close c2;
       return( nvl(to_char(c2rec.tot),'&nbsp;'));
    end if;
     else
     return( null );
   end if;

 end f_count_bbctr;
/


GRANT EXECUTE ON STRANG.F_COUNT_BBCTR TO WEBSYS;
