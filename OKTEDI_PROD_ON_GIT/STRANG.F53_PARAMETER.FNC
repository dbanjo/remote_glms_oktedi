CREATE OR REPLACE function STRANG.f53_parameter( parm_id in varchar2, parm1 in varchar2 )
 return varchar2
as

 -- Parm1 = ENTRY_NO

 cursor c1( parm1 number ) is
  select /*+ ALL_ROWS */ *
  from ships_airway
  where ship_id in
   (select ship_id
   from movements m, detailrs dr
   where entry_no = parm1 and
         m.movement_no = dr.movement_no and
         nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
   );

 cursor c2( lv varchar2, cd varchar2 ) is /*+ ALL_ROWS */ select description from lov where lov_name = lv and code = cd;

 cursor c3( parm1 number ) is
  select /*+ ALL_ROWS */ nvl(sum(amount),0) sm
  from pos p, detailrs dr
  where p.deliveryno = dr.deliveryno and
        dr.entry_no = parm1;

 cursor c4( parm1 number) is
 select /*+ ALL_ROWS */ l.description || ' ' || d.detaildesc shipmark,sum(qty) qty
 from detailrs d, lov l
 where entry_no = parm1 and
       lov_name = 'PACKTYPES' and
       l.code = d.pktpe_packtype
 group by l.description || ' ' || d.detaildesc;

 cursor c5(cid integer, ctype varchar2) is
  select /*+ ALL_ROWS */ *
  from customers
  where customer_id = cid and
        customer_type = ctype;

 cursor c6(parm1 number ) is
  select /*+ ALL_ROWS */ sum(revton * d.correct_freight * d.exrate) sm
  from detailrs dr, movements m, ships_airway s, duty d
  where dr.entry_no = parm1 and
        d.entry_no = dr.entry_no and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        m.ship_id = s.ship_id;

 cursor c7(parm1 number) is
  select /*+ ALL_ROWS */ *
  from receivals r
  where r.deliveryno in (select deliveryno from detailrs where entry_no = parm1);

 cursor c8(entryno number) is
  select *
  from duty
  where entry_no = entryno;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c8rec		c8%ROWTYPE;
 tmp		varchar2(32767);
 v1		number;
 v2		number;
 v3		number;
 v4		number;

begin

 open c1(parm1);
 fetch c1 into c1rec;
 close c1;
 if parm_id = 'P1'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   open c5(nvl(c7rec.supplier_customer_id,0),'SUPPLIER');
   fetch c5 into c5rec;
   close c5;
   return( c5rec.customer );
 elsif parm_id = 'P2'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   open c5(nvl(c7rec.cust_customer_id,0),'CUSTOMER');
   fetch c5 into c5rec;
   close c5;
   return( c5rec.customer );
 elsif parm_id = 'P3'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   open c5(nvl(c7rec.cust_customer_id,0),'CUSTOMER');
   fetch c5 into c5rec;
   close c5;
   return( c5rec.street || htf.nl || c5rec.suburb || ' ' || c5rec.state);
 elsif parm_id = 'PA'
  then
   open c2( 'CONTROLS','FORM 53 7A' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( NULL );
    else
     return( 'X' );
   end if;
 elsif parm_id = 'PB'
  then
   open c2( 'CONTROLS','FORM 53 7A' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( 'X' );
    else
     return( NULL );
   end if;
 elsif parm_id = 'PC'
  then
   open c2( 'CONTROLS','FORM 53 7B' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( NULL );
    else
     return( 'X' );
   end if;
 elsif parm_id = 'PD'
  then
   open c2( 'CONTROLS','FORM 53 7B' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( 'X' );
    else
     return( NULL );
   end if;
 elsif parm_id = 'PE'
  then
   open c2( 'CONTROLS','FORM 53 7C' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( NULL );
    else
     return( 'X' );
   end if;
 elsif parm_id = 'PF'
  then
   open c2( 'CONTROLS','FORM 53 7C' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( 'X' );
    else
     return( NULL );
   end if;
 elsif parm_id = 'PG'
  then
   open c2( 'CONTROLS','FORM 53 8A' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( NULL );
    else
     return( 'X' );
   end if;
 elsif parm_id = 'PH'
  then
   open c2( 'CONTROLS','FORM 53 8A' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( 'X' );
    else
     return( NULL );
   end if;
 elsif parm_id = 'PI'
  then
   open c2( 'CONTROLS','FORM 53 8B' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( NULL );
    else
     return( 'X' );
   end if;
 elsif parm_id = 'PJ'
  then
   open c2( 'CONTROLS','FORM 53 8B' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( 'X' );
    else
     return( NULL );
   end if;
 elsif parm_id = 'PK'
  then
   open c2( 'CONTROLS','FORM 53 9A' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( NULL );
    else
     return( 'X' );
   end if;
 elsif parm_id = 'PL'
  then
   open c2( 'CONTROLS','FORM 53 9A' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( 'X' );
    else
     return( NULL );
   end if;
 elsif parm_id = 'PM'
  then
   open c2( 'CONTROLS','FORM 53 9B' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( NULL );
    else
     return( 'X' );
   end if;
 elsif parm_id = 'PN'
  then
   open c2( 'CONTROLS','FORM 53 9B' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( 'X' );
    else
     return( NULL );
   end if;
 elsif parm_id = 'PO'
  then
   open c2( 'CONTROLS','AIRSUBURB' );
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'PP'
  then
   return( to_char(sysdate,'DD.MM.YYYY') );

 elsif parm_id = 'Q1'
  then
   -- c1rec.rate * rec.exrate xxx
   open c8(parm1);
   fetch c8 into c8rec;
   close c8;
   return( to_char( nvl(c8rec.exrate,1),'999990.9999') );

 elsif parm_id = 'QA'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   return( c7rec.curr );

 elsif parm_id = 'Q2'
  then
   -- duty.invoice_total * r.exrate * s.rate xxx
   open c8(parm1);
   fetch c8 into c8rec;
   close c8;
   return( to_char(round(nvl(c8rec.total_invoice,0) * nvl(c8rec.exrate,1),2),'999999990.99') );
 elsif parm_id = 'Q3'
  then
   --- duty.invoice_total xxx
   open c8(parm1);
   fetch c8 into c8rec;
   close c8;
   return( to_char(round(nvl(c8rec.total_invoice,0),2),'999999990.99') );

 elsif parm_id = 'Q4'
  then
   --- duty.correct_freight xxx
   open c8(parm1);
   fetch c8 into c8rec;
   close c8;
   return( to_char(round(nvl(c8rec.correct_freight,0),2),'999999990.99') );

 elsif parm_id = 'Q5'
  then
   -- duty.insruance xxx
   open c8(parm1);
   fetch c8 into c8rec;
   close c8;
   return( to_char(round(nvl(c8rec.insurance,0),2),'999999990.99') );

 elsif parm_id = 'Q6'
  then
   -- duty.other_costs
   open c8(parm1);
   fetch c8 into c8rec;
   close c8;
   return( to_char(round(nvl(c8rec.other_costs,0),2),'999999990.99') );

 elsif parm_id = 'Q7'
  then
   -- duty.total_inv + duty.corr_freight + duty.insur + duty.other_c
   open c8(parm1);
   fetch c8 into c8rec;
   close c8;
   return( to_char(nvl(c8rec.total_invoice,0) + nvl(c8rec.correct_freight,0) + nvl(c8rec.insurance,0) + nvl(c8rec.other_costs,0),'999999990.99') );

 end if;
exception
 when others then return( sqlerrm );
end f53_parameter;
/


GRANT EXECUTE ON STRANG.F53_PARAMETER TO WEBSYS;
