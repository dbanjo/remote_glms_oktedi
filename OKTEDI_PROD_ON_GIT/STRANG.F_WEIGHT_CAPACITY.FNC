CREATE OR REPLACE function STRANG.f_weight_capacity( vship_id integer )
  return varchar2
 as

  cursor c1( vshpid integer ) is
  select count(*) tot
  from strang.movements where local_ship_id= vShpid;

  cursor c1a( vshpid integer ) is
  select (sum(nvl(sumweight,0)) + sum(nvl(tare,0)))/1000 loadedweight
  from strang.movements where local_ship_id= vShpid;

  cursor c1b( vshpid integer ) is
  select movement_no, seal
  from strang.movements where local_ship_id= vShpid;

  cursor c2( vshpid integer ) is
  select count(*) tot
  from strang.movements where ship_id= vShpid;

  cursor c2a( vshpid integer ) is
  select (sum(nvl(sumweight,0)) + sum(nvl(tare,0)))/1000 loadedweight
  from strang.movements where ship_id= vShpid;

  cursor c2b( vshpid integer ) is
  select movement_no, seal
  from strang.movements where ship_id= vShpid;

  cursor c3( vshpid integer ) is
  select li from strang.ships_airway where ship_id = vshpid;

c1rec	C1%ROWTYPE;
c1arec	C1A%ROWTYPE;
c2rec	C2%ROWTYPE;
c2arec	C2A%ROWTYPE;
c3rec	C3%ROWTYPE;
vli     varchar2(1);

 begin
   open c3( vship_id );
   fetch c3 into c3rec;
   if C3%FOUND then
     vli := c3rec.li;
   else
     close c3;
     return( null );
   end if;
   close c3;
  if vli = 'L'
   then
   open c1( vship_id );
   fetch c1 into c1rec;
   if nvl(c1rec.tot,0) = 0 then
    close c1;
    return('0');
   end if;
   close c1;
   for c1brec in c1b(vship_id) loop
     websys.strangp.recalc_weight( c1brec.movement_no, sl=>c1brec.seal );
   end loop;
   open c1a( vship_id );
   fetch c1a into c1arec;
   if C1A%FOUND then
    close c1a;
    return( to_char(c1arec.loadedweight) );
   else
    close c1a;
    return( '0' );
   end if;
  else
   open c2( vship_id );
   fetch c2 into c2rec;
   if nvl(c2rec.tot,0) = 0 then
    close c2;
    return('0');
   end if;
   close c2;
   for c2brec in c2b(vship_id) loop
     websys.strangp.recalc_weight( c2brec.movement_no, sl=>c2brec.seal );
   end loop;
   open c2a( vship_id );
   fetch c2a into c2arec;
   if C2A%FOUND then
   close c2a;
    return( to_char(c2arec.loadedweight) );
   else
     close c2a;
     return( '0.000' );
   end if;
  end if;
end f_weight_capacity;
/


GRANT EXECUTE ON STRANG.F_WEIGHT_CAPACITY TO WEBSYS;
