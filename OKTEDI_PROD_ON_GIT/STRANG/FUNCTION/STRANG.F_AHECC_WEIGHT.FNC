CREATE OR REPLACE function STRANG.f_ahecc_weight(delno integer)
 return varchar2
as

 cursor c1(vdeliveryno integer) is
  select count(*) ct
  from strang.pos p
  where p.deliveryno = vdeliveryno;

 cursor c2(vdeliveryno integer) is
  select sum(dr.partweight) vsum
  from strang.detailrs dr
  where dr.deliveryno = vdeliveryno;


 c1rec  c1%ROWTYPE;
 c2rec  c2%ROWTYPE;
 tcount    number;
 tweight   number;
 iweight   number;

begin
 open c1( delno );
 fetch c1 into c1rec;
 if c1%NOTFOUND
 then
  close c1;
  return ( '0' ) ;
 end if;
 open c2( delno );
 fetch c2 into c2rec;
 if c2%NOTFOUND
 then
  close c2;
  return ( '0' ) ;
 end if;
 tcount := c1rec.ct;
 tweight := c2rec.vsum;
 close c1;
 close c2;
 iweight := tweight/tcount;
 if iweight < 1 then
  return (TO_CHAR(iweight,'999,999,999.999'));
 else
  return (TO_CHAR(iweight,'999,999,999'));
 end if;
end f_ahecc_weight;
/


GRANT EXECUTE ON STRANG.F_AHECC_WEIGHT TO WEBSYS;
