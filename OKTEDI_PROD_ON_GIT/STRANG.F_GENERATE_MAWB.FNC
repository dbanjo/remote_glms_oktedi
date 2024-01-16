CREATE OR REPLACE function STRANG.f_generate_mawb( mawb varchar2, action in varchar2 default 'LINE_NO' )
 return varchar2
as
 cursor c1(mawb varchar2) is select ship_id from strang.ships_airway where shipname = 'MAWB' and voy = mawb and ship_airway = 'A';
 c1rec	c1%ROWTYPE;
begin
 open c1(mawb);
 fetch c1 into c1rec;
 close c1;
 websys.strangp.generate_ships_manifest( c1rec.ship_id, action ,'AIRWAY', vste=>WEBSYS.OLTP.USER_SITE );

 return( NULL );
end f_generate_mawb;
/


GRANT EXECUTE ON STRANG.F_GENERATE_MAWB TO WEBSYS;
