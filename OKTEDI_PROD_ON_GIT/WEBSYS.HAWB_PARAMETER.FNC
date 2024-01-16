CREATE OR REPLACE function WEBSYS.hawb_parameter( parm_id in varchar2, parm in varchar2 )
 return varchar2
as

 -- HAWB = PARM

 cursor sf( v_mawb varchar2 ) is select sum(cola) from lov where lov_name = 'HAWBS' and code = v_mawb;
 cursor aw( v_mawb varchar2 ) is select * from movements where movement_no = v_mawb and movement_type = 'AIRWAY';
 cursor c1( v_mawb varchar2 ) is select * from ships_airway where ship_id = (select ship_id from movements where movement_no = v_mawb and movement_type = 'AIRWAY');
 cursor c2( lv varchar2, cd varchar2 ) is select description from lov where lov_name = lv and code = cd;

 cursor c3( hawbno integer ) is select * from hawbs where hawb = hawbno;
 cursor c4( mawb varchar2 ) is
  select /*+ ALL_ROWS */ customer,street,suburb,state,postcode,country
  from customers c,receivals r, detailrs dr
  where dr.movement_no = mawb and
        dr.deliveryno = r.deliveryno and
        nvl(r.cust_customer_id,0) = c.customer_id and
        c.customer_type = 'CUSTOMER';
 cursor c5( mawb varchar2 ) is
  select /*+ ALL_ROWS */ customer,street,suburb,state,postcode,country
  from customers c,receivals r, detailrs dr
  where dr.movement_no = mawb and
        dr.deliveryno = r.deliveryno and
        nvl(r.supplier_customer_id,0) = c.customer_id and
        c.customer_type = 'SUPPLIER';

 v1		integer;
 awrec		aw%ROWTYPE;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 tmp		varchar2(32767);

begin

 open c3(parm);
 fetch c3 into c3rec;
 close c3;

 if parm_id = 'S1'
  then
   return( PARM );
   --dr.hawb_hawbno
 elsif parm_id = 'S2'
  then
   return( c3rec.mawb );
   --dr.movement_no
 elsif parm_id = 'S3A'
  then
   -- SUPPLIER
   open c5( c3rec.mawb );
   fetch c5 into c5rec;
   close c5;
   return( c5rec.customer );
   --c1.customer
 elsif parm_id = 'S3B'
  then
   -- SUPPLIER
   open c5( c3rec.mawb );
   fetch c5 into c5rec;
   close c5;
   return( c5rec.street || ', ' || c5rec.suburb );
   --c1.street, c1.suburb
 elsif parm_id = 'S3C'
  then
   -- SUPPLIER
   open c5( c3rec.mawb );
   fetch c5 into c5rec;
   close c5;
   return( c5rec.state || ', ' || c5rec.postcode || ', ' || c5rec.country );
   --
 elsif parm_id = 'S4A'
  then
   -- CUSTOMER
   open c4( c3rec.mawb );
   fetch c4 into c4rec;
   close c4;
   return( c4rec.customer );
   --c1.customer
 elsif parm_id = 'S4B'
  then
   -- CUSTOMER
   open c4( c3rec.mawb );
   fetch c4 into c4rec;
   close c4;
   return( c4rec.street || ', ' || c4rec.suburb );
   --c1.street, c1.suburb
 elsif parm_id = 'S4C'
  then
   -- CUSTOMER
   open c4( c3rec.mawb );
   fetch c4 into c4rec;
   close c4;
   return( c4rec.state || ', ' || c4rec.postcode || ', ' || c4rec.country );
 elsif parm_id = 'S4D'
  then
   -- CUSTOMER
   return( NULL );
   --
 elsif parm_id = 'S5'
  then
   -- Agent
   open c2('CONTROLS','HAWB_AGENT' );
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
end hawb_parameter;

/
