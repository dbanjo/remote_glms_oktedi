CREATE OR REPLACE function STRANG.f_additional_info( mvt in varchar2, sl in varchar2, break_on in varchar2 default 'F' )
 return varchar2
as
 cursor c2(mvt varchar2, sl varchar2) is
  select distinct dr.hazard
  from strang.movements m, strang.detailrs dr
  where m.movement_no=mvt and
   nvl(m.seal,'|') = nvl(sl,'|') and
   m.movement_no = dr.movement_no and
   nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
   dr.hazard is not null;

 c2rec  c2%ROWTYPE;
 tmp	varchar2(1000);


begin
 tmp:= '';
for c2rec in c2(mvt,sl) loop
  tmp :=  tmp || c2rec.hazard;
end loop;
  return ( tmp );
end f_additional_info;
/


GRANT EXECUTE ON STRANG.F_ADDITIONAL_INFO TO WEBSYS;
