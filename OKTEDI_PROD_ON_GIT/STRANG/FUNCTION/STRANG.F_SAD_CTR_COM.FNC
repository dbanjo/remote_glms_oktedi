CREATE OR REPLACE function STRANG.f_sad_ctr_com( parm_id in varchar2, parm1 in varchar2, parm2 in varchar2 )
 return varchar2
as

 -- Parm1 = CONTAINER
 -- Parm2 = SEAL

cursor c1( parm1 varchar2, parm2 varchar2) is
  select min(entry_no) from strang.detailrs
  where movement_no = parm1 and camov_seal = parm2;

cursor c2( parm1 varchar2, parm2 varchar2) is
  select max(entry_no) from strang.detailrs
  where movement_no = parm1 and camov_seal = parm2;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;

begin
  open c1(parm1, parm2);
   fetch c1 into c1rec;
   close c1;
  open c2(parm1, parm2);
   fetch c2 into c2rec;
   close c2;


 return( null );

end f_sad_ctr_com;
/


GRANT EXECUTE ON STRANG.F_SAD_CTR_COM TO WEBSYS;
