CREATE OR REPLACE function STRANG.hawb_parameter( parm_id in varchar2, parm in varchar2, parm2 in varchar2 )
 return varchar2
as

 -- HAWB = PARM

 cursor sf( v_mawb varchar2 ) is select sum(cola) from lov where lov_name = 'HAWBS' and code = v_mawb;
 cursor aw( v_mawb varchar2 ) is select * from movements where movement_no = v_mawb and movement_type = 'AIRWAY';
 cursor c1( v_mawb varchar2 ) is select * from ships_airway where ship_id = (select ship_id from movements where movement_no = v_mawb and movement_type = 'AIRWAY');
 cursor c2( lv varchar2, cd varchar2 ) is select description from lov where lov_name = lv and code = cd and cola = WEBSYS.OLTP.F_USER_SITE;
 cursor c2a( lv varchar2, cd varchar2 ) is select description from lov where lov_name = lv and code = cd;

 cursor c3( mawbno varchar2, hawbno varchar2 ) is select * from hawbs where mawb = mawbno and hawb = hawbno;
 cursor c4( mawb varchar2, hawb varchar2 ) is
  select /*+ ALL_ROWS */ customer,street,suburb,state,postcode,country
  from customers c,receivals r, detailrs dr
  where dr.movement_no = mawb and
        dr.hawb_hawbno = hawb and
        dr.deliveryno = r.deliveryno and
        nvl(r.cust_customer_id,0) = c.customer_id and
        c.customer_type = 'CUSTOMER';
 cursor c5( mawb varchar2, hawb varchar2 ) is
  select /*+ ALL_ROWS */ customer,street,suburb,state,postcode,country
  from customers c,receivals r, detailrs dr
  where dr.movement_no = mawb and
        dr.deliveryno = r.deliveryno and
        dr.hawb_hawbno = parm2 and
        nvl(r.supplier_customer_id,0) = c.customer_id and
        c.customer_type = 'SUPPLIER' and
        hawb_hawbno = hawb;

 cursor c5a( nme varchar2, ctype varchar2 ) is
  select /*+ ALL_ROWS */ customer,street,suburb,state,postcode,country
  from customers c
  where c.customer = nme and
        c.customer_type = ctype;


 cursor c6( mawb varchar2, hawb varchar2 ) is
  select /*+ ALL_ROWS */ curr
  from  receivals r, detailrs dr
  where dr.movement_no = mawb and
        dr.deliveryno = r.deliveryno and
        hawb_hawbno = hawb;
 cursor c7( mawb varchar2, hawb varchar2 ) is
  select /*+ ALL_ROWS */ qty,partweight,partvolume,round(chargeable_weight(partweight,partvolume)) cw, round(partvolume * 1000/4) cwcairns
  from detailrs
  where movement_no = mawb and
        hawb_hawbno = hawb
  order by deliveryno;
 cursor c8( mawb varchar2, hawb varchar2 ) is
  select /*+ ALL_ROWS */ sum(qty) sm,sum(partweight) pw,sum(partvolume) pv, sum(round(chargeable_weight(partweight,partvolume))) cw, sum(round(partvolume * 1000/4)) cwcairns
  from detailrs
  where movement_no = mawb and
        hawb_hawbno = hawb
  order by deliveryno;
 cursor c9( mawb varchar2, hawb varchar2 ) is
  select /*+ ALL_ROWS */ rate
  from movements m, charges c
  where movement_no = mawb and
        c.chargecode = m.chargecode;
 cursor c10( mawb varchar2, hawb varchar2 ) is
  select /*+ ALL_ROWS */ distinct detaildesc,logno
  from detailrs dr, pos p
  where dr.movement_no = mawb and
        dr.deliveryno = p.deliveryno and
        hawb_hawbno = hawb;
 cursor c10a( mawb varchar2, hawb varchar2 ) is
  select /*+ ALL_ROWS */ distinct po
  from detailrs dr, pos p
  where dr.movement_no = mawb and
        dr.deliveryno = p.deliveryno and
        hawb_hawbno = hawb;
 cursor c11( mawb varchar2, hawb varchar2 ) is
  select *
  from   detailrs dr
  where  dr.movement_no = mawb
         and dr.hawb_hawbno = hawb
 ;


 v1		integer;
 awrec		aw%ROWTYPE;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c5arec		c5a%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c9rec		c9%ROWTYPE;
 c10rec		c10%ROWTYPE;
 c11rec		c11%ROWTYPE;
 tmp		varchar2(32767);
 tmp1		varchar2(32767);

begin

 open c3(parm,parm2);
 fetch c3 into c3rec;
 close c3;

 if parm_id = 'S1'
  then
   return( PARM2 );
   --dr.hawb_hawbno
 elsif parm_id = 'S2'
  then
   return( c3rec.mawb );
   --dr.movement_no



/*
 elsif parm_id = 'S3A'
  then
   -- SUPPLIER
   open c5( c3rec.mawb, parm2 );
   fetch c5 into c5rec;
   close c5;
   return( c5rec.customer );
   --c1.customer
 elsif parm_id = 'S3B'
  then
   -- SUPPLIER
   open c5( c3rec.mawb, parm2 );
   fetch c5 into c5rec;
   close c5;
   return( c5rec.street || htf.nl || c5rec.suburb );
   --c1.street, c1.suburb
 elsif parm_id = 'S3C'
  then
   -- SUPPLIER
   open c5( c3rec.mawb, parm2 );
   fetch c5 into c5rec;
   close c5;
   return( c5rec.state || htf.nl || c5rec.postcode || ' ' || c5rec.country );
   --
*/



 elsif parm_id = 'S3A'
  then
   -- AGENT
   open c2('CONTROLS','MAWB_AGENT' );
   fetch c2 into c2rec;
   close c2;
   open c5a( c2rec.description,'AGENT' );
   fetch c5a into c5arec;
   close c5a;
   return( c5arec.customer );
   --c1.customer
 elsif parm_id = 'S3B'
  then
   -- AGENT
   open c2('CONTROLS','MAWB_AGENT' );
   fetch c2 into c2rec;
   close c2;
   open c5a( c2rec.description,'AGENT' );
   fetch c5a into c5arec;
   close c5a;
   return( c5arec.street || ', ' || c5arec.suburb );
   --c1.street, c1.suburb
 elsif parm_id = 'S3C'
  then
   -- AGENT
   open c2('CONTROLS','MAWB_AGENT' );
   fetch c2 into c2rec;
   close c2;
   open c5a( c2rec.description,'AGENT' );
   fetch c5a into c5arec;
   close c5a;
   return( c5arec.state || ' ' || c5arec.postcode || ' &nbsp;&nbsp;' || c5arec.country );
   --



 elsif parm_id = 'S3D'
  then
   -- CUSTOMER
   open c2('CONTROLS','MAWB_AGENT' );
   fetch c2 into c2rec;
   close c2;
   open c4( c3rec.mawb, parm2 );
   fetch c4 into c4rec;
   close c4;
 --return( 'As agents for OK-TEDI MINING LTD.');
   return( 'As agents for ' || c4rec.customer );
   --



 elsif parm_id = 'S3E'
  then
  -- SUPPLIER
  open c5( c3rec.mawb, parm2 );
  fetch c5 into c5rec;
  close c5;
  return( 'SUPPLIER: ' || c5rec.customer );







 elsif parm_id = 'S4A'
  then
   -- CUSTOMER
   return( NULL );
   --c1.customer
 elsif parm_id = 'S4B'
  then
   -- CUSTOMER
   open c4( c3rec.mawb, parm2 );
   fetch c4 into c4rec;
   close c4;
   return( c4rec.customer || htf.nl || c4rec.street || ' ' || c4rec.suburb || htf.nl || c4rec.state || ' ' || c4rec.postcode || ' &nbsp;&nbsp;' || c4rec.country );
   --c1.street, c1.suburb
 elsif parm_id = 'S4C'
  then
   -- CUSTOMER
   return( NULL );
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
   open aw(c3rec.mawb);
   fetch aw into awrec;
   close aw;
   open c2a('LOCATIONS',awrec.departure );
   fetch c2a into c2rec;
   close c2a;
   return( c2rec.description );
 elsif parm_id = 'S7'
  then
   open aw(c3rec.mawb);
   fetch aw into awrec;
   close aw;
   return( awrec.arrival );
 elsif parm_id = 'S8'
  then
   open aw(c3rec.mawb);
   fetch aw into awrec;
   close aw;
   return( awrec.carrier );
 elsif parm_id = 'S9'
  then
   open c6(c3rec.mawb, parm2);
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
   return( ltrim(to_char(c3rec.value,'$999,999,999.99')) );
 elsif parm_id = 'SE'
  then
   open aw(c3rec.mawb);
   fetch aw into awrec;
   close aw;
   open c2a('LOCATIONS',awrec.arrival );
   fetch c2a into c2rec;
   close c2a;
   return( c2rec.description );
 elsif parm_id = 'SF'
  then
   open aw(c3rec.mawb);
   fetch aw into awrec;
   close aw;
   return( awrec.flight );
 elsif parm_id = 'SG'
  then
   open aw(c3rec.mawb);
   fetch aw into awrec;
   close aw;
   return( ' ' );
   -- return( to_char(awrec.dispatch_date,'DD-Mon-YY') );
 elsif parm_id = 'SH'
  then
   tmp := NULL;
   for c7rec in c7(c3rec.mawb, parm2) loop
    tmp := tmp || c7rec.qty || htf.nl;
   end loop;
   open c8( c3rec.mawb, parm2);
   fetch c8 into c8rec;
   close c8;
   return( tmp || '______' || htf.nl || htf.bold(c8rec.sm) );
 elsif parm_id = 'SI'
  then
   tmp := NULL;
   for c7rec in c7(c3rec.mawb, parm2) loop
    tmp := tmp || c7rec.partweight || htf.nl;
   end loop;
   open c8( c3rec.mawb, parm2);
   fetch c8 into c8rec;
   close c8;
   return( tmp || '______' || htf.nl || htf.bold(c8rec.pw) );
 elsif parm_id = 'SJ'
  then
   open c2('CONTROLS','HAWB_UNIT' );
   fetch c2 into c2rec;
   close c2;
   return( nvl(c2rec.description,'Kg') );
 elsif parm_id = 'SK'
  then
   tmp := NULL;
   for c7rec in c7(c3rec.mawb, parm2) loop
    tmp := tmp || c7rec.cw || htf.nl;
   end loop;
   open c8( c3rec.mawb, parm2);
   fetch c8 into c8rec;
   close c8;
   return( tmp || '______' || htf.nl || htf.bold(c8rec.cw) );
 elsif parm_id = 'SKCAIRNS'
  then
   tmp := NULL;
   for c7rec in c7(c3rec.mawb, parm2) loop
    tmp := tmp || c7rec.cwcairns || htf.nl;
   end loop;
   open c8( c3rec.mawb, parm2);
   fetch c8 into c8rec;
   close c8;
   return( tmp || '______' || htf.nl || htf.bold(c8rec.cwcairns) );
 elsif parm_id = 'SL'
  then
   open c9( c3rec.mawb, parm2);
   fetch c9 into c9rec;
   close c9;
   return( round(c9rec.rate,2) );
 elsif parm_id = 'SM'
  then
   open c2('CONTROLS','HAWB_TOTAL' );
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'SN'
  then
   tmp := NULL;
   for c10rec in c10(c3rec.mawb, parm2) loop
    tmp := tmp || htf.nl || c10rec.detaildesc;
   end loop;
   tmp1 := NULL;
   for c10arec in c10a(c3rec.mawb, parm2) loop
       tmp1 := tmp1 || ', ' || c10arec.po;
   end loop;
   return( substr(tmp,5) || htf.nl || 'O/No. '||substr(tmp1,3) );
 elsif parm_id = 'SO'
  then
   open c8( c3rec.mawb, parm2);
   fetch c8 into c8rec;
   close c8;
   open c10(c3rec.mawb, parm2);
   fetch c10 into c10rec;
   close c10;
   return( 'D.R.L ' || c10rec.logno || htf.nl || 'CBM ' || c8rec.pv);
 elsif parm_id = 'SP'
  then
   open c2('CONTROLS','HAWB_PREPAID' );
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'SQ'
  then
   open c2('CONTROLS','HAWB_OTHER_CHARGES' );
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'SR'
  then
   open c2('CONTROLS','HAWB_TOTAL_PREPAID' );
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'SS'
  then
   open c2('CONTROLS','HAWB_BRANCH_LOCATION' );
   fetch c2 into c2rec;
   close c2;
   tmp := to_char(sysdate,'DD Month YYYY') || ' &nbsp;&nbsp;&nbsp;' || c2rec.description;
   open c2('CONTROLS','HAWB_AGENT' );
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
   -- return( null );
   tmp := null;
   open c11(parm, parm2);
   fetch c11 into c11rec;
   close c11;
   if c11rec.hazard is not null or c11rec.warehouse in ('HAZ')
    then
	 tmp := '<CENTER><B>DANGEROUS GOODS AS PER ASSOCIATED SHIPPERS DECLARATION</B></CENTER>';
   end if;
   return( tmp );
 end if;
end hawb_parameter;
/


GRANT EXECUTE ON STRANG.HAWB_PARAMETER TO WEBSYS;
