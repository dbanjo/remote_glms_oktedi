CREATE OR REPLACE function STRANG.awb_parameter( parm_id in varchar2, parm in varchar2 )
 return varchar2
as

 cursor sf( v_mawb varchar2 ) is select sum(cola) from lov where lov_name = 'HAWBS' and code = v_mawb;
 cursor aw( v_mawb varchar2 ) is select * from movements where movement_no = v_mawb and movement_type = 'AIRWAY';
 cursor c1( v_mawb varchar2 ) is select * from ships_airway where ship_id = (select ship_id from movements where movement_no = v_mawb and movement_type = 'AIRWAY');
 cursor c2( lv varchar2, cd varchar2 ) is select description from lov where lov_name = lv and code = cd and cola = WEBSYS.OLTP.F_USER_SITE;

 v1		integer;
 awrec		aw%ROWTYPE;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 tmp		varchar2(32767);

begin

 if parm_id = 'S1'
  then
   return( 'Submaster' );
 elsif parm_id = 'S2'
  then
   return( parm );
 elsif parm_id = 'S3'
  then
   open c2('CONTROLS','COMPANYNAME' );
   fetch c2 into c2rec;
   close c2;
   tmp := c2rec.description || htf.nl;
   open c2('CONTROLS','AGENTS FOR' );
   fetch c2 into c2rec;
   close c2;
   tmp := tmp || c2rec.description || htf.nl;
   open c2('CONTROLS','STREET' );
   fetch c2 into c2rec;
   close c2;
   tmp := tmp || c2rec.description || ' ';
   open c2('CONTROLS','SUBURB' );
   fetch c2 into c2rec;
   close c2;
   tmp := tmp || c2rec.description || ' ';
   open c2('CONTROLS','STATE' );
   fetch c2 into c2rec;
   close c2;
   tmp := tmp || c2rec.description || htf.nl;
   return( tmp );
 elsif parm_id = 'S4'
  then
   return( 'S4' );
 elsif parm_id = 'S5'
  then
   open c2('CONTROLS','COMPANYNAME' );
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'S6'
  then
   open aw( parm );
   fetch aw into awrec;
   close aw;
   return( awrec.departure );
 elsif parm_id = 'S7'
  then
   return( 'S7' );
 elsif parm_id = 'S8'
  then
   open c1( parm );
   fetch c1 into c1rec;
   close c1;
   return( c1rec.shipname || ' ' || c1rec.voy );
 elsif parm_id = 'S9'
  then
   return( 'AUD' );
 elsif parm_id = 'SA'
  then
   return( 'SA' );
 elsif parm_id = 'SB'
  then
   return( 'SB' );
 elsif parm_id = 'SC'
  then
   return( 'SC' );
 elsif parm_id = 'SD'
  then
   return( 'SD' );
 elsif parm_id = 'SE'
  then
   return( 'SE' );
 elsif parm_id = 'SF'
  then
   open sf( parm );
   fetch sf into v1;
   close sf;
   return( to_char(v1,'$999,999,999.99') );
 elsif parm_id = 'SG'
  then
   open c1( parm );
   fetch c1 into c1rec;
   close c1;
   return( 'Sg' );
 elsif parm_id = 'SH'
  then
   open c1( parm );
   fetch c1 into c1rec;
   close c1;
   return( 'Sh' );
 elsif parm_id = 'SI'
  then
   open c1( parm );
   fetch c1 into c1rec;
   close c1;
   return( c1rec.portdisc );
 elsif parm_id = 'SJ'
  then
   return( 'SJ' );
 elsif parm_id = 'SK'
  then
   return( 'SK' );
 elsif parm_id = 'SL'
  then
   return( 'SL' );
 elsif parm_id = 'SM'
  then
   return( 'SM' );
 elsif parm_id = 'SN'
  then
   return( 'SN' );
 elsif parm_id = 'SO'
  then
   return( 'SO' );
 elsif parm_id = 'SP'
  then
   return( 'SP' );
 elsif parm_id = 'SQ'
  then
   return( 'SQ' );
 elsif parm_id = 'SR'
  then
   return( 'SR' );
 elsif parm_id = 'SS'
  then
   return( 'SS' );
 elsif parm_id = 'ST'
  then
   return( 'ST' );
 end if;
end awb_parameter;
/


GRANT EXECUTE ON STRANG.AWB_PARAMETER TO WEBSYS;
