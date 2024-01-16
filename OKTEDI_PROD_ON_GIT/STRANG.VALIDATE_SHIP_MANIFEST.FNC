CREATE OR REPLACE function STRANG.validate_ship_manifest( vship_id in varchar2, vli in varchar2, typ in varchar2 )
 return integer
as

 cursor c1( shipid number ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.movements m
  where shipid = m.ship_id
  and m.bol is null;

 cursor c1a( shipid number ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.movements m
  where shipid = m.local_ship_id
  and m.local_bol is null;

 cursor c2( shipid number ) is
  select /*+ ALL_ROWS */ count('x') tot
  from  strang.detailrs dr, strang.movements m
  where shipid = m.ship_id
        and dr.movement_no = m.movement_no
        and nvl(dr.camov_seal,'|') = nvl(m.seal,'|')
        and dr.line_no is null;

 cursor c2a( shipid number ) is
  select /*+ ALL_ROWS */ count('x') tot
  from  strang.detailrs dr, strang.movements m
  where shipid = m.local_ship_id
        and dr.movement_no = m.movement_no
        and nvl(dr.camov_seal,'|') = nvl(m.seal,'|')
        and dr.local_line_no is null;

cursor c3( shipid number ) is
 select s.status
 from strang.ships_airway s
 where shipid = s.ship_id;

 c3rec  c3%ROWTYPE;
 tot	integer;

begin
open c3(vship_id);
fetch c3 into c3rec;
close c3;
if c3rec.status not in ('INCOMPLETE','COMPLETE')
then
  if vli = 'I'
   then
   if typ = 'BOL' then
    tot := 0;
    open c1(vship_id);
    fetch c1 into tot;
    close c1;
    if tot > 0 then return( 0 ); end if;
   else
    tot := 0;
    open c2(vship_id);
    fetch c2 into tot;
    close c2;
    if tot > 0 then return( 0 ); end if;
   end if;
  else
   if typ = 'BOL' then
    tot := 0;
    open c1a(vship_id);
    fetch c1a into tot;
    close c1a;
    if tot > 0 then return( 0 ); end if;
   else
    tot := 0;
    open c2a(vship_id);
    fetch c2a into tot;
    close c2a;
    if tot > 0 then return( 0 ); end if;
   end if;
  end if;
 return( 1 );
else
 return( 1 );
end if;
end validate_ship_manifest;
/


GRANT EXECUTE ON STRANG.VALIDATE_SHIP_MANIFEST TO WEBSYS;
