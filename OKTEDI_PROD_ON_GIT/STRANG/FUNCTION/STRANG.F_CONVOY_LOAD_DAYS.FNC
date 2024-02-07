CREATE OR REPLACE function STRANG.f_convoy_load_days( vMWeek varchar2, vMYear varchar2, vDayno number, vConvoyType varchar2, vIO varchar2 )
   return varchar
  as

    cursor c1a(Convoyid number,vrno number) is
     select operator,truck_tanker,truck_id,trailer_id,fuel_type,fuel_litres
     from strang.convoy_details_vw
     where convoy_id = convoyid
     and rno2 = vrno;

    cursor c3(VWeek varchar2, vYear varchar2, vDy number, vConvoyType varchar2, vIO varchar2) is
     select convoy_id,status, estdepart
     from strang.convoy
--     where to_char(estdepart+1,'IW')= VWeek
--     and to_char(estdepart,'YYYY')= vYear
--     and to_char(estdepart,'D') = vDy
     where to_char(websys.strangp.week_of_year(estdepart)) = VWeek
     and to_char(websys.strangp.trunc_to_week_start( estdepart), 'FMYYYY')= vYear
     and websys.strangp.day_of_week(estdepart) = vDy
     and convoy_type = vConvoyType
     and NVL(io,'I') = vIO
     and masterplan = 'YES';
    
     
     cursor c4(VWeek varchar2, vYear varchar2, vConvoyType varchar2) is
     select max(cnt) vMax
     from (
     select trunc(c.estdepart) estdepart, count(distinct cd.truck_id) cnt
     from strang.convoy c, strang.convoy_details cd
     where to_char(c.estdepart,'IW')= VWeek
     and to_char(c.estdepart,'YYYY')= vYear
     and c.convoy_id = cd.convoy_id
     and convoy_type = vConvoyType
     and c.masterplan = 'YES'
     group by trunc(c.estdepart));
     
    
    cursor c1(Convoyid number, vrno number) is
     select cn.movement_no1 movement_no, cn.seal1 seal, cn.full_mt1 full_mt, cn.iso_container_type1 iso_container_type, cn.weight1 weight, cn.tare1 tare,
     cn.container_type1 container_type, cn.hazard1 hazard, cn.overdimensional1 overdimensional, cn.warehouse_destination1 warehouse_destination,
     cn.urgency1 urgency, cn.lookup1 lookup, cn.set_point1 set_point, cn.consignee1 consignee, cn.consignee_location1 consignee_location,cn.vessel1 vessel,
     cn.trailer_id
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.truck_tanker = 'TRUCK'
    union
     select cn.movement_no2 movement_no, cn.seal2 seal, cn.full_mt2 full_mt, cn.iso_container_type2 iso_container_type, cn.weight2 weight, cn.tare2 tare,
     cn.container_type2 container_type, cn.hazard2 hazard, cn.overdimensional2 overdimensional, cn.warehouse_destination2 warehouse_destination,
     cn.urgency2 urgency, cn.lookup2 lookup, cn.set_point2 set_point, cn.consignee2 consignee, cn.consignee_location2 consignee_location,cn.vessel2 vessel,
     cn.trailer_id
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.truck_tanker = 'TRUCK'
    union
     select cn.movement_no3 movement_no, cn.seal3 seal, cn.full_mt3 full_mt, cn.iso_container_type3 iso_container_type, cn.weight3 weight, cn.tare3 tare,
     cn.container_type3 container_type, cn.hazard3 hazard, cn.overdimensional3 overdimensional, cn.warehouse_destination3 warehouse_destination,
     cn.urgency3 urgency, cn.lookup3 lookup, cn.set_point3 set_point, cn.consignee3 consignee, cn.consignee_location3 consignee_location,cn.vessel3 vessel,
     cn.trailer_id
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.truck_tanker = 'TRUCK'
    union
     select cn.movement_no4 movement_no, cn.seal4 seal, cn.full_mt4 full_mt, cn.iso_container_type4 iso_container_type, cn.weight4 weight, cn.tare4 tare,
     cn.container_type4 container_type, cn.hazard4 hazard, cn.overdimensional4 overdimensional, cn.warehouse_destination4 warehouse_destination,
     cn.urgency4 urgency, cn.lookup4 lookup, cn.set_point4 set_point, cn.consignee4 consignee, cn.consignee_location4 consignee_location,cn.vessel4 vessel,
     cn.trailer_id
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.truck_tanker = 'TRUCK'
    union
     select cn.movement_no5 movement_no, cn.seal5 seal, cn.full_mt5 full_mt, cn.iso_container_type5 iso_container_type, cn.weight5 weight, cn.tare5 tare,
     cn.container_type5 container_type, cn.hazard5 hazard, cn.overdimensional5 overdimensional, cn.warehouse_destination5 warehouse_destination,
     cn.urgency5 urgency, cn.lookup5 lookup, cn.set_point5 set_point, cn.consignee5 consignee, cn.consignee_location5 consignee_location,cn.vessel5 vessel,
     cn.trailer_id
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.truck_tanker = 'TRUCK'
    union
     select cn.movement_no6 movement_no, cn.seal6 seal, cn.full_mt6 full_mt, cn.iso_container_type6 iso_container_type, cn.weight6 weight, cn.tare6 tare,
     cn.container_type6 container_type, cn.hazard6 hazard, cn.overdimensional6 overdimensional, cn.warehouse_destination6 warehouse_destination,
     cn.urgency6 urgency, cn.lookup6 lookup, cn.set_point6 set_point, cn.consignee6 consignee, cn.consignee_location6 consignee_location,cn.vessel6 vessel,
     cn.trailer_id
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.truck_tanker = 'TRUCK'
   order by 1  ;

    cursor c2(Convoyid number, vrno number) is
     select sum(nvl(cn.weight1,0)) truckweight
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight2,0)) truckweight
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight3,0)) truckweight
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight4,0)) truckweight
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight5,0)) truckweight
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight6,0)) truckweight
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.truck_tanker = 'TRUCK'
   ;

   c1arec	C1a%ROWTYPE;
   c2rec	C2%ROWTYPE;
   c3rec	C3%ROWTYPE;
   c4rec	C4%ROWTYPE;

   retvar varchar2(32767);

   begin

   retvar := null;

-- EXECUTE IMMEDIATE 'alter session set nls_territory = CANADA';
  open c3(vMWeek,vMYear,vDayno, vConvoyType, vIO);
  fetch c3 into c3rec;
  if c3%NOTFOUND
  then
   close c3;
--   EXECUTE IMMEDIATE 'alter session set nls_territory = "AUSTRALIA"';
--   EXECUTE IMMEDIATE 'alter session set nls_date_format = "DD-MON-YY"';
   return( '&nbsp;');
  end if;
  close c3;
  
  

retvar := c3rec.estdepart||htf.nl||c3rec.convoy_id || htf.nl|| c3rec.status|| htf.nl|| htf.nl ||
case when strang.f_convoy_load(c3rec.convoy_id,1,strang.f_convoy_load_vLn(vMWeek,vMYear,1,vConvoyType, vIO)) = '&nbsp;' then '&nbsp;' else strang.f_convoy_load(c3rec.convoy_id,1,strang.f_convoy_load_vLn(vMWeek,vMYear,1,vConvoyType, vIO))||htf.nl end||
case when strang.f_convoy_load(c3rec.convoy_id,2,strang.f_convoy_load_vLn(vMWeek,vMYear,2,vConvoyType, vIO)) = '&nbsp;' then '&nbsp;' else strang.f_convoy_load(c3rec.convoy_id,2,strang.f_convoy_load_vLn(vMWeek,vMYear,2,vConvoyType, vIO))||htf.nl end||
case when strang.f_convoy_load(c3rec.convoy_id,3,strang.f_convoy_load_vLn(vMWeek,vMYear,3,vConvoyType, vIO)) = '&nbsp;' then '&nbsp;' else strang.f_convoy_load(c3rec.convoy_id,3,strang.f_convoy_load_vLn(vMWeek,vMYear,3,vConvoyType, vIO))||htf.nl end||
case when strang.f_convoy_load(c3rec.convoy_id,4,strang.f_convoy_load_vLn(vMWeek,vMYear,4,vConvoyType, vIO)) = '&nbsp;' then '&nbsp;' else strang.f_convoy_load(c3rec.convoy_id,4,strang.f_convoy_load_vLn(vMWeek,vMYear,4,vConvoyType, vIO))||htf.nl end||
case when strang.f_convoy_load(c3rec.convoy_id,5,strang.f_convoy_load_vLn(vMWeek,vMYear,5,vConvoyType, vIO)) = '&nbsp;' then '&nbsp;' else strang.f_convoy_load(c3rec.convoy_id,5,strang.f_convoy_load_vLn(vMWeek,vMYear,5,vConvoyType, vIO))||htf.nl end||
case when strang.f_convoy_load(c3rec.convoy_id,6,strang.f_convoy_load_vLn(vMWeek,vMYear,6,vConvoyType, vIO)) = '&nbsp;' then '&nbsp;' else strang.f_convoy_load(c3rec.convoy_id,6,strang.f_convoy_load_vLn(vMWeek,vMYear,6,vConvoyType, vIO))||htf.nl end||
case when strang.f_convoy_load(c3rec.convoy_id,7,strang.f_convoy_load_vLn(vMWeek,vMYear,7,vConvoyType, vIO)) = '&nbsp;' then '&nbsp;' else strang.f_convoy_load(c3rec.convoy_id,7,strang.f_convoy_load_vLn(vMWeek,vMYear,7,vConvoyType, vIO))||htf.nl end||
case when strang.f_convoy_load(c3rec.convoy_id,8,strang.f_convoy_load_vLn(vMWeek,vMYear,8,vConvoyType, vIO)) = '&nbsp;' then '&nbsp;' else strang.f_convoy_load(c3rec.convoy_id,8,strang.f_convoy_load_vLn(vMWeek,vMYear,8,vConvoyType, vIO))||htf.nl end||
case when strang.f_convoy_load(c3rec.convoy_id,9,strang.f_convoy_load_vLn(vMWeek,vMYear,9,vConvoyType, vIO)) = '&nbsp;' then '&nbsp;' else strang.f_convoy_load(c3rec.convoy_id,9,strang.f_convoy_load_vLn(vMWeek,vMYear,9,vConvoyType, vIO))||htf.nl end||
case when strang.f_convoy_load(c3rec.convoy_id,10,strang.f_convoy_load_vLn(vMWeek,vMYear,10,vConvoyType, vIO)) = '&nbsp;' then '&nbsp;' else  strang.f_convoy_load(c3rec.convoy_id,10,strang.f_convoy_load_vLn(vMWeek,vMYear,10,vConvoyType, vIO)) ||htf.nl end ||
case when strang.f_convoy_load(c3rec.convoy_id,11,strang.f_convoy_load_vLn(vMWeek,vMYear,11,vConvoyType, vIO)) = '&nbsp;' then '&nbsp;' else  strang.f_convoy_load(c3rec.convoy_id,11,strang.f_convoy_load_vLn(vMWeek,vMYear,11,vConvoyType, vIO)) ||htf.nl end ||
case when strang.f_convoy_load(c3rec.convoy_id,12,strang.f_convoy_load_vLn(vMWeek,vMYear,12,vConvoyType, vIO)) = '&nbsp;' then '&nbsp;' else  strang.f_convoy_load(c3rec.convoy_id,12,strang.f_convoy_load_vLn(vMWeek,vMYear,12,vConvoyType, vIO)) ||htf.nl end ||
case when strang.f_convoy_load(c3rec.convoy_id,13,strang.f_convoy_load_vLn(vMWeek,vMYear,13,vConvoyType, vIO)) = '&nbsp;' then '&nbsp;' else  strang.f_convoy_load(c3rec.convoy_id,13,strang.f_convoy_load_vLn(vMWeek,vMYear,13,vConvoyType, vIO)) ||htf.nl end ||
case when strang.f_convoy_load(c3rec.convoy_id,14,strang.f_convoy_load_vLn(vMWeek,vMYear,14,vConvoyType, vIO)) = '&nbsp;' then '&nbsp;' else  strang.f_convoy_load(c3rec.convoy_id,14,strang.f_convoy_load_vLn(vMWeek,vMYear,14,vConvoyType, vIO)) ||htf.nl end ||
case when strang.f_convoy_load(c3rec.convoy_id,15,strang.f_convoy_load_vLn(vMWeek,vMYear,15,vConvoyType, vIO)) = '&nbsp;' then '&nbsp;' else  strang.f_convoy_load(c3rec.convoy_id,15,strang.f_convoy_load_vLn(vMWeek,vMYear,15,vConvoyType, vIO)) ||htf.nl end ||
case when strang.f_convoy_load(c3rec.convoy_id,16,strang.f_convoy_load_vLn(vMWeek,vMYear,16,vConvoyType, vIO)) = '&nbsp;' then '&nbsp;' else  strang.f_convoy_load(c3rec.convoy_id,16,strang.f_convoy_load_vLn(vMWeek,vMYear,16,vConvoyType, vIO)) end;

--EXECUTE IMMEDIATE 'alter session set nls_territory = "AUSTRALIA"';
--EXECUTE IMMEDIATE 'alter session set nls_date_format = "DD-MON-YY"';
return ( retvar );

 end f_convoy_load_days;
/


GRANT EXECUTE ON STRANG.F_CONVOY_LOAD_DAYS TO WEBSYS;
