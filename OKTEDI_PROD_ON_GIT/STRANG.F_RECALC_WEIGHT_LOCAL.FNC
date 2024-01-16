CREATE OR REPLACE function STRANG.f_recalc_weight_local( vship_id integer, action in varchar2 )
 return varchar2
as
 cursor c1( vship_id integer ) is select * from strang.movements where local_ship_id = vship_id;
begin
 if upper(action) = 'Y'
  then
   for c1rec in c1(vship_id) loop
    websys.strangp.recalc_weight( c1rec.movement_no, sl=>c1rec.seal );
   end loop;
 end if;
 return( NULL );
end f_recalc_weight_local;
/


GRANT EXECUTE ON STRANG.F_RECALC_WEIGHT_LOCAL TO WEBSYS;
