CREATE OR REPLACE function STRANG.f_generate_manifest( vship_id integer, action in varchar2 default 'LINE_NO', entryno in number default null )
 return varchar2
as
 cursor c1(entryno number) is select ship_id from strang.movements m,strang.detailrs dr where entry_no = entryno and dr.movement_no = m.movement_no and nvl(camov_seal,'|') = nvl(seal,'|');
 cursor c2(vship_id integer) is select status from strang.ships_airway where ship_id = vship_id;

 c1rec  c1%ROWTYPE;
 c2rec  c2%ROWTYPE;

begin

-- Do Not Generate if the status is FINAL
open c2(vship_id);
fetch c2 into c2rec;
close c2;
if c2rec.status in ('FINAL','CUSTOMS COMPLETE', 'SAILED', 'ARCHIVE' ) then return( NULL ); end if;
if action = 'LOCAL_LINE_NO' then
  websys.strangp.generate_ships_manifest( vship_id, action, entryno=>entryno, vste=>WEBSYS.OLTP.USER_SITE );
return( NULL );
end if;
if entryno is null
 then
  websys.strangp.generate_ships_manifest( vship_id, action, entryno=>entryno, vste=>WEBSYS.OLTP.USER_SITE );
 else
  open c1(entryno);
  fetch c1 into c1rec;
  close c1;
  websys.strangp.generate_ships_manifest( c1rec.ship_id, action, entryno=>entryno, vste=>WEBSYS.OLTP.USER_SITE );
end if;

 return( NULL );
end f_generate_manifest;
/


GRANT EXECUTE ON STRANG.F_GENERATE_MANIFEST TO WEBSYS;
