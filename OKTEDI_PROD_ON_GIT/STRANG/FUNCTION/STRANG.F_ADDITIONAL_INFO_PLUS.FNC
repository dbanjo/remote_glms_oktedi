CREATE OR REPLACE function STRANG.f_additional_info_plus( mvt in varchar2, sl in varchar2, break_on in varchar2 default 'F' )
 return varchar2
as
 cursor c2(mvt varchar2, sl varchar2) is
  select distinct dr.hazard
  from strang.movements m, strang.detailrs dr
  where m.movement_no=mvt and
   nvl(m.seal,'|') = nvl(sl,'|') and
   m.movement_no = dr.movement_no and
   nvl(dr.camov_seal,'|') = nvl(m.seal,'|');

 c2rec  c2%ROWTYPE;
 tmp	varchar2(300);


begin
 tmp:= '';
for c2rec in c2(mvt,sl) loop
  tmp :=  tmp || c2rec.hazard;
end loop;
if length(tmp) <= 101 then
 return( '' );
else
 return (substr( tmp, 101,length(tmp)));
end if;
end f_additional_info_plus;
/


GRANT EXECUTE ON STRANG.F_ADDITIONAL_INFO_PLUS TO WEBSYS;
