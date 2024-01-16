CREATE OR REPLACE function WEBSYS.f_generate_manifest( vship_id integer, action in varchar2 default 'LINE_NO', entryno in integer default null )
 return varchar2
as
 cursor c1(entryno integer) is select ship_id from strang.movements m,strang.detailrs dr where entry_no = entryno and dr.movement_no = m.movement_no and nvl(camov_seal,'|') = nvl(seal,'|');
 cursor c2(vship_id integer) is select status from strang.ships_airway where ship_id = vship_id;

 c1rec  c1%ROWTYPE;
 c2rec  c2%ROWTYPE;

begin

-- Do Not Generate if the status is
open c2(vship_id);
fetch c2 into c2rec;
close c2;
if c2rec.status = 'FINAL' then return( NULL ); end if;

if entryno is null
 then
  strangp.generate_ships_manifest( vship_id, action, entryno=>entryno );
 else
  open c1(entryno);
  fetch c1 into c1rec;
  close c1;
  strangp.generate_ships_manifest( c1rec.ship_id, action, entryno=>entryno );
end if;

 return( NULL );
end f_generate_manifest;

/
