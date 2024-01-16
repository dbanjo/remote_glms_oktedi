CREATE OR REPLACE function WEBSYS.f_cwdeclaration( parm_id varchar2, parm1 in varchar2, parm2 in varchar2 )
 return varchar2
as

 -- Parm1 = CONTAINER NO
 -- Parm2 = SHIP_ID

 cursor c1( ctrno varchar2, ship_id varchar2 ) is select * from strang.movements m where m.movement_no = ctrno and m.ship_id = ship_id and movement_type= 'CARGO';

 cursor c2( ctrno varchar2, seal varchar2 ) is
  select c.customer_id, c.customer
  from strang.receivals r, strang.detailrs dr, strang.customers c, strang.movements m
  where dr.movement_no = ctrno and
  	m.movement_no = dr.movement_no and
  	nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  	nvl(dr.camov_seal,'|') = nvl(seal,'|') and
  	m.movement_type = 'CARGO' and
        dr.deliveryno = r.deliveryno and
        r.cust_customer_id = c.customer_id and
        c.customer_type = 'CUSTOMER';

 cursor c3( ctrno varchar2, seal varchar2 ) is
  select c.customer_id, c.customer, c.street || ', ' || c.suburb || ' ' || c.city || ' ' ||c.postcode address
  from strang.receivals r, strang.detailrs dr, strang.customers c, strang.movements m
  where dr.movement_no = ctrno and
  	m.movement_no = dr.movement_no and
  	nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  	nvl(dr.camov_seal,'|') = nvl(seal,'|') and
  	m.movement_type = 'CARGO' and
        dr.deliveryno = r.deliveryno and
        r.supplier_customer_id = c.customer_id and
        c.customer_type = 'SUPPLIER';



 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;

begin
 open c1(parm1,parm2);
 fetch c1 into c1rec;
 close c1;
 if parm_id = 'SENDER'
  then
   open c2(c1rec.movement_no,c1rec.seal );
   fetch c2 into c2rec;
   close c2;
   open c3(c1rec.movement_no,c1rec.seal );
   fetch c3 into c3rec;
   close c3;
   if c2rec.customer_id = 1
    then
    return ('OK-TEDI MINING LTD,' );
   else
    return (c3rec.customer || ',');
   end if;
 elsif parm_id = 'ADDRESS'
  then
   open c2(c1rec.movement_no,c1rec.seal );
   fetch c2 into c2rec;
   close c2;
   open c3(c1rec.movement_no,c1rec.seal );
   fetch c3 into c3rec;
   close c3;
   if c2rec.customer_id = 1
    then
    return ('936 Nudgee Road, Northgate 4013' );
   else
    return (c3rec.address);
   end if;
 elsif parm_id = 'RECEIVER'
  then
   open c2(c1rec.movement_no,c1rec.seal );
   fetch c2 into c2rec;
   close c2;
    return (c2rec.customer);
 elsif parm_id = 'STATUS_FULL'
  then
   if c1rec.sumweight > 0
    then
    return('X');
   else
    return(' ');
   end if ;
 elsif parm_id = 'STATUS_EMPTY'
  then
   if c1rec.sumweight = 0
    then
    return('X');
   else
    return(' ');
   end if ;
 elsif parm_id = 'CARGOTYPE_GENERAL'
  then
   return( '1' );
 elsif parm_id = 'CARGOTYPE_HAZARD'
  then
   return( '1' );
 elsif parm_id = 'CARGOTYPE_REEFER'
  then
   return( '1' );
 elsif parm_id = 'TYPE_20FT'
  then
   return( '1' );
 elsif parm_id = 'TYPE_40FT'
  then
   return( '1' );
 elsif parm_id = 'ISO_CODE'
  then
   return( '1' );
 elsif parm_id = 'WEIGHT_TARE'
  then
   return( '1' );
 elsif parm_id = 'WEIGHT_NET'
  then
   return( '1' );
 elsif parm_id = 'WEIGHT_GROSS'
  then
   return( '1' );
 elsif parm_id = 'M1'
  then
   return( '1' );
 end if;
end f_cwdeclaration;
/
