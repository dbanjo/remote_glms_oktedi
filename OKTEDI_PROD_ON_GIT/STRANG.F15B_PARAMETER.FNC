CREATE OR REPLACE function STRANG.f15b_parameter( parm_id in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2 )
 return varchar2
as

 cursor c1(p1 varchar2, p2 varchar2 ) is
  select * from header where ship=p1 and voy=p2;
 cursor c2(p1 varchar2, p2 varchar2, p3 varchar2 ) is
  select * from detailr where delivery_no = (select delivery_no from smdets where ship=p1 and voy=p2 and internal_no=p3 and line_no=1);
 cursor c3(p1 varchar2, p2 varchar2, p3 varchar2 ) is
  select * from duty where delivery_no =
   (select delivery_no from smdets where ship=p1 and voy=p2 and internal_no=p3 and line_no=1);
 cursor c4(p1 varchar2, p2 varchar2, p3 varchar2 ) is
  select * from receival where delivery_no =
   (select delivery_no from smdets where ship=p1 and voy=p2 and internal_no=p3 and line_no=1);
 cursor c5(p1 varchar2, p2 varchar2, p3 varchar2 ) is
  select *  from smdets where ship=p1 and voy=p2 and internal_no=p3 and line_no=1;
 cursor c6(p1 varchar2, p2 varchar2, p3 varchar2 ) is
 select t2.internal_no,t2.supplier,t1.sm
from
(
select internal_no,sum(revenue_tonne(part_weight,part_volume)) sm
from smdets
where ship=p1 and voy=p2 and internal_no=p3
group by internal_no) t1, smdets t2
where ship=p1 and voy=p2 and t1.internal_no = t2.internal_no and t2.internal_no=p3
group by t2.internal_no,t2.supplier,t1.sm;

 v1		integer;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;

begin
 -- Missing D4 (Date Entered),DB (Manifest), DH(Location), DN(Freight), DQ(Currency), DR(Exchange Rate)
 if parm_id = 'D1'
  then
   return( to_char( sysdate,'DD.MM.YYYY') );
 elsif parm_id = 'D2'
  then
   return( p3 );
 elsif parm_id = 'D3'
  then
   open c4(p1,p2,p3);
   fetch c4 into c4rec;
   close c4;
   return( c4rec.cust_id );
 elsif parm_id = 'D4'
  then
   open c1(p1,p2);
   fetch c1 into c1rec;
   close c1;
   return( to_char(c1rec.arrival_dte,'DD.MM.YYYY') );
 elsif parm_id = 'D5'
  then
   open c2(p1,p2,p3);
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'DA'
  then
   open c4(p1,p2,p3);
   fetch c4 into c4rec;
   close c4;
   return( c4rec.cust_id );
 elsif parm_id = 'DB'
  then
   return( 'DB' );
 elsif parm_id = 'DC'
  then
   open c5(p1,p2,p3);
   fetch c5 into c5rec;
   close c5;
   return( c5rec.bol );
 elsif parm_id = 'DD'
  then
   open c1(p1,p2);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.port_of_discharge );
 elsif parm_id = 'DE'
  then
   return( p1 );
 elsif parm_id = 'DF'
  then
   return( p2 );
 elsif parm_id = 'DG'
  then
   open c1(p1,p2);
   fetch c1 into c1rec;
   close c1;
   return( to_char(c1rec.arrival_dte,'DD.MM.YYYY') );
 elsif parm_id = 'DH'
  then
   open c1(p1,p2);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.discharge_location );
 elsif parm_id = 'DI'
  then
   open c1(p1,p2);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.pfrom );
 elsif parm_id = 'DK'
  then
   open c1(p1,p2);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.port_of_loading );
 elsif parm_id = 'DL'
  then
   open c4(p1,p2,p3);
   fetch c4 into c4rec;
   close c4;
   return( c4rec.supplier );
 elsif parm_id = 'DM'
  then
   open c3(p1,p2,p3);
   fetch c3 into c3rec;
   close c3;
   return( to_char((c3rec.insurance * 1000),'999,999,999.99') );
 elsif parm_id = 'DN'
  then
   open c1(p1,p2);
   fetch c1 into c1rec;
   close c1;
   open c6(p1,p2,p3);
   fetch c6 into c6rec;
   close c6;
   return( to_char(c6rec.sm * c1rec.freight * c1rec.rate,'999,999,999.99') );
 elsif parm_id = 'DO'
  then
   open c3(p1,p2,p3);
   fetch c3 into c3rec;
   close c3;
   return( to_char(round(c3rec.insurance,2),'999,999,999.99') );
 elsif parm_id = 'DP'
  then
   open c3(p1,p2,p3);
   fetch c3 into c3rec;
   close c3;
   return( to_char(round(c3rec.other_costs,2),'999,999,999.99') );
 elsif parm_id = 'DQ'
  then
   -- Will be store in receivable table
   return( 'DQ' );
 elsif parm_id = 'DR'
  then
   open c1(p1,p2);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.rate );
 elsif parm_id = 'DS'
  then
   open c3(p1,p2,p3);
   fetch c3 into c3rec;
   close c3;
   return( to_char(c3rec.ratio_factor) );
 elsif parm_id = 'DT'
  then
   open c1(p1,p2);
   fetch c1 into c1rec;
   close c1;
   return( to_char(c1rec.vat,'999,999.99'));
 elsif parm_id = 'DU'
  then
   open c1(p1,p2);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.pcomment );
 end if;
end f15b_parameter;

/


GRANT EXECUTE ON STRANG.F15B_PARAMETER TO WEBSYS;
