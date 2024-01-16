CREATE OR REPLACE function STRANG.f_ahecc(vahecc varchar2,vstate varchar2,vtamount number,vdelivery_charge number,vcontainer varchar2,vseal varchar2)
 return varchar2
as

 cursor c1(vcontainer varchar2, vSeal varchar2, vState varchar2) is
  select count(*) vcount
  from strang.pos p, strang.detailrs dr
  where dr.deliveryno = p.deliveryno and
        nvl(camov_seal,'x') = nvl(vseal,'x') and
        dr.movement_no = vcontainer and
        p.state = vState and
        (nvl(p.tamount,0)+nvl(p.delivery_charge,0)) < 2000;

 cursor c2(vcontainer varchar2, vSeal varchar2, vState varchar2) is
  select sum(p.tamount+p.delivery_charge) vsum
  from strang.pos p, strang.detailrs dr
  where dr.deliveryno = p.deliveryno and
        nvl(camov_seal,'x') = nvl(vseal,'x') and
        dr.movement_no = vcontainer and
        p.state = vState and
        (p.tamount+p.delivery_charge) < 2000;


 c1rec  c1%ROWTYPE;
 c2rec  c2%ROWTYPE;
-- retvar	varchar2(32767);
-- lrec   varchar2(100);
-- xctr   integer;

begin
 if vstate is null
 then
   return ( null );
 end if;

 if (nvl(vtamount,0)+nvl(vdelivery_charge,0) >= 5000)
 then
   if vahecc = '98090002'
   then
      return ( null );
   else
     return ( vahecc );
   end if;
 end if;
 open c1( vcontainer, vSeal, vState );
 fetch c1 into c1rec;
 if c1%NOTFOUND
 then
  close c1;
  return ( vahecc ) ;
 elsif
  c1rec.vcount < 4
 then
  close c1;
   if vahecc = '98090002'
   then
      return ( null );
   else
     return ( vahecc );
   end if;
 else
  close c1;
  return ( '98090002' );
 end if;
 close c1;
 return ( vahecc );
end f_ahecc;
/


GRANT EXECUTE ON STRANG.F_AHECC TO WEBSYS;
