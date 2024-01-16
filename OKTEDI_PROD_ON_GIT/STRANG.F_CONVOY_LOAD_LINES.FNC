CREATE OR REPLACE function STRANG.f_convoy_load_lines( vMWeek varchar2,vMYear varchar2, vConvoyType varchar2, vIO varchar2  )
   return varchar
  as
  
   cursor c1(VWeek varchar2, vYear varchar2, vConvoyType varchar2, vIO varchar2) is
   select max(cnt) vMax
     from (select trunc(c.estdepart) estdepart,c.convoy_id, count(*) cnt
             from strang.convoy c, strang.convoy_details cd
--            where to_char(c.estdepart+1,'IW')= VWeek
--              and to_char(c.estdepart,'YYYY')= vYear
            where to_char(websys.strangp.week_of_year(estdepart)) = VWeek
              and to_char(websys.strangp.trunc_to_week_start( estdepart), 'FMYYYY')= vYear
              and c.convoy_id = cd.convoy_id
              and nvl(c.io, 'I') = vIO
              and convoy_type = vConvoyType
              and c.masterplan = 'YES'
            group by trunc(c.estdepart),c.convoy_id);
  
   c1rec	c1%ROWTYPE;
   retvar varchar2(32767);
   ln	varchar2(1000);
   vln  integer;
   j    integer;

   begin

-- EXECUTE IMMEDIATE 'alter session set nls_territory = "CANADA"';
   retvar := null;
   ln := null;
   
   open c1(vMWeek , vMYear,vConvoyType, vIO);
   fetch c1 into c1rec;
   close c1;
   

/*
  open c3(vMWeek,vDayno);
  fetch c3 into c3rec;
  if c3%NOTFOUND
  then
   close c3;
   return( '&nbsp;');
  end if;
  close c3;
*/
vln:= strang.f_convoy_load_vLn(vMWeek,vMYear,1,vConvoyType, vIO)+3;
if c1rec.vMax > 0 then
   retvar:= 'DATE'||htf.nl||'CONVOY ID'||htf.nl||'STATUS'||htf.nl||htf.nl||'LOAD 1';
   for j in 1..vln loop
   ln:= ln||htf.nl;
   end loop;
   retvar:= retvar||ln;
end if;

if c1rec.vMax > 0 and c1rec.vMax >= 2 then
   ln := null;
   vln:= strang.f_convoy_load_vLn(vMWeek,vMYear,2,vConvoyType, vIO)+3;
   retvar:= retvar || 'LOAD 2';
   for j in 1..vln loop
     ln:= ln||htf.nl;
   end loop;
   retvar:= retvar||ln;
end if;

if c1rec.vMax > 0 and c1rec.vMax >= 3 then
   ln := null;
   vln:= strang.f_convoy_load_vLn(vMWeek,vMYear,3,vConvoyType, vIO)+3;
   retvar:= retvar || 'LOAD 3';
   for j in 1..vln loop
   ln:= ln||htf.nl;
   end loop;
   retvar:= retvar||ln;
end if;

if c1rec.vMax > 0 and c1rec.vMax >= 4 then
   ln := null;
   vln:= strang.f_convoy_load_vLn(vMWeek,vMYear,4, vConvoyType, vIO)+3;
   retvar:= retvar || 'LOAD 4';
   for j in 1..vln loop
      ln:= ln||htf.nl;
   end loop;
   retvar:= retvar||ln;
end if;

if c1rec.vMax > 0 and c1rec.vMax >= 5 then
   ln := null;
   vln:= strang.f_convoy_load_vLn(vMWeek,vMYear,5, vConvoyType, vIO)+3;
   retvar:= retvar || 'LOAD 5';
   for j in 1..vln loop
      ln:= ln||htf.nl;
   end loop;
   retvar:= retvar||ln;
end if;

if c1rec.vMax > 0 and c1rec.vMax >= 6 then
   ln := null;
   vln:= strang.f_convoy_load_vLn(vMWeek,vMYear,6, vConvoyType, vIO)+3;
   retvar:= retvar || 'LOAD 6';
   for j in 1..vln loop
      ln:= ln||htf.nl;
   end loop;
   retvar:= retvar||ln;
end if;

if c1rec.vMax > 0 and c1rec.vMax >= 7 then
   ln := null;
   vln:= strang.f_convoy_load_vLn(vMWeek,vMYear,7, vConvoyType, vIO)+3;
   retvar:= retvar || 'LOAD 7';
   for j in 1..vln loop
      ln:= ln||htf.nl;
   end loop;
   retvar:= retvar||ln;
end if;

if c1rec.vMax > 0 and c1rec.vMax >= 8 then
   ln := null;
   vln:= strang.f_convoy_load_vLn(vMWeek,vMYear,8, vConvoyType, vIO)+3;
   retvar:= retvar || 'LOAD 8';
   for j in 1..vln loop
      ln:= ln||htf.nl;
   end loop;
   retvar:= retvar||ln;
end if;

if c1rec.vMax > 0 and c1rec.vMax >= 9 then
   ln := null;
   vln:= strang.f_convoy_load_vLn(vMWeek,vMYear,9, vConvoyType, vIO)+3;
   retvar:= retvar || 'LOAD 9';
   for j in 1..vln loop
      ln:= ln||htf.nl;
   end loop;
   retvar:= retvar||ln;
end if;

if c1rec.vMax > 0 and c1rec.vMax >= 10 then
   ln := null;
   vln:= strang.f_convoy_load_vLn(vMWeek,vMYear,10, vConvoyType, vIO)+3;
   retvar:= retvar || 'LOAD 10';
   for j in 1..vln loop
      ln:= ln||htf.nl;
   end loop;
   retvar:= retvar||ln;
end if;

if c1rec.vMax > 0 and c1rec.vMax >= 11 then
   ln := null;
   vln:= strang.f_convoy_load_vLn(vMWeek,vMYear,11, vConvoyType, vIO)+3;
   retvar:= retvar || 'LOAD 11';
   for j in 1..vln loop
   ln:= ln||htf.nl;
   end loop;
   retvar:= retvar||ln;
end if;

if c1rec.vMax > 0 and c1rec.vMax >= 12 then
   ln := null;
   vln:= strang.f_convoy_load_vLn(vMWeek,vMYear,12, vConvoyType, vIO)+3;
   retvar:= retvar || 'LOAD 12';
   for j in 1..vln loop
      ln:= ln||htf.nl;
   end loop;
   retvar:= retvar||ln;
end if;

if c1rec.vMax > 0 and c1rec.vMax >= 13 then
ln := null;
vln:= strang.f_convoy_load_vLn(vMWeek,vMYear,13, vConvoyType, vIO)+3;
retvar:= retvar || 'LOAD 13';
for j in 1..vln loop
ln:= ln||htf.nl;
end loop;
retvar:= retvar||ln;
end if;

if c1rec.vMax > 0 and c1rec.vMax >= 14 then
ln := null;
vln:= strang.f_convoy_load_vLn(vMWeek,vMYear,14, vConvoyType, vIO)+3;
retvar:= retvar || 'LOAD 14';
for j in 1..vln loop
ln:= ln||htf.nl;
end loop;
retvar:= retvar||ln;
end if;

if c1rec.vMax > 0 and c1rec.vMax >= 15 then
ln := null;
vln:= strang.f_convoy_load_vLn(vMWeek,vMYear,15, vConvoyType, vIO)+3;
retvar:= retvar || 'LOAD 15';
for j in 1..vln loop
ln:= ln||htf.nl;
end loop;
retvar:= retvar||ln;
end if;

if c1rec.vMax > 0 and c1rec.vMax >= 16 then
ln := null;
vln:= strang.f_convoy_load_vLn(vMWeek,vMYear,16, vConvoyType, vIO)+3;
retvar:= retvar || 'LOAD 16';
for j in 1..vln loop
ln:= ln||htf.nl;
end loop;
retvar:= retvar||ln;
end if;

--EXECUTE IMMEDIATE 'alter session set nls_territory = "AUSTRALIA"';
--EXECUTE IMMEDIATE 'alter session set nls_date_format = "DD-MON-YY"';


return ( retvar );

 end f_convoy_load_lines;
/


GRANT EXECUTE ON STRANG.F_CONVOY_LOAD_LINES TO WEBSYS;
