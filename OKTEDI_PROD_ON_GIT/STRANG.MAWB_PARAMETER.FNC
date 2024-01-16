CREATE OR REPLACE function STRANG.mawb_parameter( parm_id in varchar2, parm in varchar2 )
 return varchar2
as

 -- HAWB = PARM

 cursor sf( v_mawb varchar2 ) is select sum(cola) from lov where lov_name = 'HAWBS' and code = v_mawb;
 cursor aw( v_mawb varchar2 ) is select * from movements where movement_no = v_mawb and movement_type = 'AIRWAY';
 cursor c1( v_mawb varchar2 ) is select * from ships_airway where ship_id = (select ship_id from movements where movement_no = v_mawb and movement_type = 'AIRWAY');
 cursor c2( lv varchar2, cd varchar2 ) is select description from lov where lov_name = lv and code = cd and cola = WEBSYS.OLTP.F_USER_SITE;
 cursor c3( lv varchar2, cd varchar2 ) is select description from lov where lov_name = lv and code = cd;

 cursor c4( mawb varchar2 ) is
  select /*+ ALL_ROWS */ customer,street,suburb,state,postcode,country
  from customers c,receivals r, detailrs dr
  where dr.movement_no = mawb and
        dr.deliveryno = r.deliveryno and
        nvl(r.cust_customer_id,0) = c.customer_id and
        c.customer_type = 'CUSTOMER';
 cursor c5( nme varchar2, ctype varchar2 ) is
  select /*+ ALL_ROWS */ customer,street,suburb,state,postcode,country
  from customers c
  where c.customer = nme and
        c.customer_type = ctype;
 cursor c6( mawb varchar2 ) is
  select /*+ ALL_ROWS */ curr
  from  receivals r, detailrs dr
  where dr.movement_no = mawb and
        dr.deliveryno = r.deliveryno;
 cursor c7( mwb varchar2 ) is select sum(value) sm from hawbs where mawb = mwb;
 cursor c8( mwb varchar2 ) is
  select /*+ ALL_ROWS */ sum(qty) sm,sum(partweight) pw,sum(partvolume) pv, sum(round(chargeable_weight(partweight,partvolume))) cw, sum(round(partvolume * 1000/4)) cwcairns

  from detailrs dr, hawbs h
  where dr.movement_no = mwb and
        h.mawb = mwb and
        dr.movement_no = h.mawb and
        dr.hawb_hawbno = h.hawb
  order by deliveryno;
 cursor c9( mawb varchar2 ) is
  select /*+ ALL_ROWS */ rate
  from movements m, charges c
  where movement_no = mawb and
        c.chargecode = m.chargecode;

 v1		integer;
 awrec		aw%ROWTYPE;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c9rec		c9%ROWTYPE;
 tmp		varchar2(32767);

begin

 if parm_id = 'S1'
  then
   return( 'SUBMASTER' );
   --dr.hawb_hawbno
 elsif parm_id = 'S2'
  then
   return( parm );
   --dr.movement_no

 elsif parm_id = 'S3A'
  then
   -- AGENT
   open c2('CONTROLS','MAWB_AGENT' );
   fetch c2 into c2rec;
   close c2;
   open c5( c2rec.description,'AGENT' );
   fetch c5 into c5rec;
   close c5;
   return( c5rec.customer );
   --c1.customer
 elsif parm_id = 'S3B'
  then
   -- AGENT
   open c2('CONTROLS','MAWB_AGENT' );
   fetch c2 into c2rec;
   close c2;
   open c5( c2rec.description,'AGENT' );
   fetch c5 into c5rec;
   close c5;
   return( c5rec.street || ', ' || c5rec.suburb );
   --c1.street, c1.suburb
 elsif parm_id = 'S3C'
  then
   -- AGENT
   open c2('CONTROLS','MAWB_AGENT' );
   fetch c2 into c2rec;
   close c2;
   open c5( c2rec.description,'AGENT' );
   fetch c5 into c5rec;
   close c5;
   return( c5rec.state || ' ' || c5rec.postcode || '&nbsp;&nbsp; ' || c5rec.country );
   --
 elsif parm_id = 'S3D'
  then
   -- CUSTOMER
   open c2('CONTROLS','MAWB_RECEIVER' );
   fetch c2 into c2rec;
   close c2;
 --return( 'As agents for OK-TEDI MINING LTD.');
   return( 'As agents for ' || c2rec.description );
   --

 elsif parm_id = 'S4A'
  then
   -- AGENT
   /*
   open c2('CONTROLS','MAWB_RECEIVER' );
   fetch c2 into c2rec;
   close c2;
   open c5( c2rec.description, 'AGENT' );
   fetch c5 into c5rec;
   close c5;
   return( c5rec.customer );
   --c1.customer
   */
   return( NULL );
 elsif parm_id = 'S4B'
  then
   -- AGENT
   open c2('CONTROLS','MAWB_RECEIVER' );
   fetch c2 into c2rec;
   close c2;
   open c5( c2rec.description, 'AGENT' );
   fetch c5 into c5rec;
   close c5;
   return( c5rec.customer || htf.nl || c5rec.street || htf.nl || c5rec.suburb || ', ' || c5rec.state || htf.nl || c5rec.country || htf.nl || 'As agents for ' || c2rec.description  );
   --c1.street, c1.suburb
 elsif parm_id = 'S4C'
  then
   -- AGENT
   /*
   open c2('CONTROLS','MAWB_RECEIVER' );
   fetch c2 into c2rec;
   close c2;
   open c5( c2rec.description, 'AGENT' );
   fetch c5 into c5rec;
   close c5;
   */
   return( NULL );
   --
 elsif parm_id = 'S4D'
  then
   -- AGENT ATTENTION

   open c2('CONTROLS','MAWB_RECEIVER_ATTENTION' );
   fetch c2 into c2rec;
   close c2;

   return( 'ATTENTION: '|| c2rec.description );
   --

 elsif parm_id = 'S5'
  then
   -- Agent
   open c2('CONTROLS','MAWB_AGENT' );
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );



 elsif parm_id = 'S6'
  then
   open aw(parm);
   fetch aw into awrec;
   close aw;
   open c3('LOCATIONS',awrec.departure );
   fetch c3 into c2rec;
   close c3;
   return( c2rec.description );
 elsif parm_id = 'S7'
  then
   open aw(parm);
   fetch aw into awrec;
   close aw;
   return( awrec.arrival );
 elsif parm_id = 'S8'
  then
   open aw(parm);
   fetch aw into awrec;
   close aw;
   return( awrec.carrier );
 elsif parm_id = 'S9'
  then
   open c6(parm);
   fetch c6 into c6rec;
   close c6;
   return( c6rec.curr );
 elsif parm_id = 'SA'
  then
   open c2('CONTROLS','HAWB_WT_VAL_PPD' );
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'SB'
  then
   open c2('CONTROLS','HAWB_OTHER_PPD' );
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'SC'
  then
   open c2('CONTROLS','HAWB_DECLARED_VALUE' );
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'SD'
  then
   open c7( parm );
   fetch c7 into c7rec;
   close c7;
   return( ltrim(to_char(c7rec.sm,'$999,999,999.99')) );
 elsif parm_id = 'SE'
  then
   open aw(parm);
   fetch aw into awrec;
   close aw;
   open c3('LOCATIONS',awrec.arrival );
   fetch c3 into c2rec;
   close c3;
   return( c2rec.description );
 elsif parm_id = 'SF'
  then
   open aw(parm);
   fetch aw into awrec;
   close aw;
   return( awrec.flight );
 elsif parm_id = 'SG'
  then
   open aw(parm);
   fetch aw into awrec;
   close aw;
   return( ' ' );
   -- return( to_char(awrec.dispatch_date,'DD-Mon-YY') );
 elsif parm_id = 'SH'
  then
   open c8( parm);
   fetch c8 into c8rec;
   close c8;
   return( tmp || htf.bold(c8rec.sm) );
 elsif parm_id = 'SI'
  then
   open c8( parm);
   fetch c8 into c8rec;
   close c8;
   return( tmp || htf.bold(c8rec.pw) );
 elsif parm_id = 'SJ'
  then
   open c2('CONTROLS','HAWB_UNIT' );
   fetch c2 into c2rec;
   close c2;
   return( nvl(c2rec.description,'Kg') );
 elsif parm_id = 'SK'
  then
   open c8( parm);
   fetch c8 into c8rec;
   close c8;
   return( tmp || htf.bold(c8rec.cw) );
  elsif parm_id = 'SKCAIRNS'
  then
   open c8( parm);
   fetch c8 into c8rec;
   close c8;
   return( tmp || htf.bold(c8rec.cwcairns) );
 elsif parm_id = 'SL'
  then
   return( 'PREPAID' );
 elsif parm_id = 'SM'
  then
   open c2('CONTROLS','HAWB_TOTAL' );
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'SN'
  then
   return( 'Consolidation as per attached manifest' );
 elsif parm_id = 'SO'
  then
   open c8( parm);
   fetch c8 into c8rec;
   close c8;
   return( 'CBM ' || c8rec.pv);
 elsif parm_id = 'SP'
  then
   open c2('CONTROLS','HAWB_PREPAID' );
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'SQ'
  then
   --open c2('CONTROLS','HAWB_OTHER_CHARGES' );
   --fetch c2 into c2rec;
   --close c2;
   return( NULL );
 elsif parm_id = 'SR'
  then
   open c2('CONTROLS','HAWB_TOTAL_PREPAID' );
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'SS'
  then
   open c2('CONTROLS','MAWB_BRANCH_LOCATION' );
   fetch c2 into c2rec;
   close c2;
   tmp := to_char(sysdate,'DD Month YYYY') || ' &nbsp;&nbsp;&nbsp;' || c2rec.description;
   open c2('CONTROLS','MAWB_AGENT' );
   fetch c2 into c2rec;
   close c2;
   tmp := tmp || ' &nbsp;&nbsp;&nbsp;' || c2rec.description;
   return( tmp );
 elsif parm_id = 'ST'
  then
   return( htf.bold(parm) );
 elsif parm_id = 'SU'
  then
   -- iata
   open c2('CONTROLS','IATANO' );
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'SV'
  then
   -- handling
   open c2('CONTROLS','MAWB_HANDLING_INFORMATION' );
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 end if;
end mawb_parameter;
/


GRANT EXECUTE ON STRANG.MAWB_PARAMETER TO WEBSYS;
