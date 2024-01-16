CREATE OR REPLACE function STRANG.f_convoy_load_vLn(  vMWeek varchar2, vMYear varchar2, vMRno number, vConvoyType varchar2, vIO varchar2 )
   return integer
  as

    cursor c3(VWeek varchar2, vYear varchar2, vRno number, vIO varchar2) is
     select cn.convoy_id,cd.rno2 rno, cd.TRUCK_TANKER
     from strang.convoy cn, strang.convoy_details_vw cd
   --  where to_char(cn.estdepart+1,'IW')= VWeek
   --  and to_char(cn.estdepart,'YYYY')= vYear
     where to_char(websys.strangp.week_of_year(estdepart)) = VWeek
     and to_char(websys.strangp.trunc_to_week_start( estdepart), 'FMYYYY')= vYear
     and cn.masterplan = 'YES'
     and NVL(cn.io,'I') = vIO
     and cn.CONVOY_TYPE = vConvoyType
     and cd.convoy_id = cn.convoy_id
     and cd.rno2 = vRno;

    cursor c4(vConvoyid number, vRno varchar2) is
     select case when cd.seal1 is null and cd.iso_container_type1 is null and cd.movement_no1 is not null then cd.movement_no1||'1' else cd.movement_no1 end movement_no
     from strang.convoy_details_vw cd
     where cd.convoy_id = vConvoyid
     and cd.rno2 = vrno
     and cd.truck_tanker in ('TRUCK', 'TANKER')
    union 
     select case when cd.seal2 is null and cd.iso_container_type2 is null and cd.movement_no2 is not null  then cd.movement_no2||'2' else cd.movement_no2 end movement_no
     from strang.convoy_details_vw cd
     where cd.convoy_id = vConvoyid
     and cd.rno2 = vrno
     and cd.truck_tanker in ('TRUCK', 'TANKER')
    union
     select case when cd.seal3 is null and cd.iso_container_type3 is null and cd.movement_no3 is not null  then cd.movement_no3||'3' else cd.movement_no3 end movement_no 
     from strang.convoy_details_vw cd
     where cd.convoy_id = vConvoyid
     and cd.rno2 = vrno
     and cd.truck_tanker in ('TRUCK', 'TANKER')
    union
     select case when cd.seal4 is null and cd.iso_container_type4 is null and cd.movement_no4 is not null  then cd.movement_no4||'4' else cd.movement_no4 end movement_no
     from strang.convoy_details_vw cd
     where cd.convoy_id = vConvoyid
     and cd.rno2 = vrno
     and cd.truck_tanker in ('TRUCK', 'TANKER')
    union
     select case when cd.seal5 is null and cd.iso_container_type5 is null and cd.movement_no5 is not null  then cd.movement_no5||'5' else cd.movement_no5 end movement_no 
     from strang.convoy_details_vw cd
     where cd.convoy_id = vConvoyid
     and cd.rno2 = vrno
     and cd.truck_tanker in ('TRUCK', 'TANKER')
    union
     select case when cd.seal6 is null and cd.iso_container_type6 is null and cd.movement_no6 is not null  then cd.movement_no6||'6' else cd.movement_no6 end movement_no
     from strang.convoy_details_vw cd
     where cd.convoy_id = vConvoyid
     and cd.rno2 = vrno
     and cd.truck_tanker in ('TRUCK', 'TANKER');
     

   countr integer;
   mxRws  integer;

   begin

   countr:= 0;
   mxRws:=0;
-- EXECUTE IMMEDIATE 'alter session set nls_territory = "CANADA"';
 
for c3rec in c3( vMWeek, vMYear, vMRno, vIO ) loop
  if c3rec.truck_tanker = 'TANKER' then
     countr := 3;
  else
     countr := 0;
  end if;
  
  for c4rec in c4(c3rec.convoy_id,c3rec.rno) loop
    if c3rec.truck_tanker <> 'TANKER' then
       countr := countr + 1;
    end if;
  end loop;
  if countr > mxRws then
   mxRws:= countr;
  end if;
end loop;

--EXECUTE IMMEDIATE 'alter session set nls_territory = "AUSTRALIA"';
--EXECUTE IMMEDIATE 'alter session set nls_date_format = "DD-MON-YY"';
return( mxRws );

end f_convoy_load_vLn;
/


GRANT EXECUTE ON STRANG.F_CONVOY_LOAD_VLN TO WEBSYS;
