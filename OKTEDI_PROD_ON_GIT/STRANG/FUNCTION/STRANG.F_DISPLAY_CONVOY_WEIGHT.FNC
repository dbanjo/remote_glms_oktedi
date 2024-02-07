CREATE OR REPLACE function STRANG.f_display_convoy_weight( vConvoyid number )
   return varchar
  as

    cursor c1(Convoyid number) is
     select sum(nvl(cn.weight1,0)) truckweight
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.movement_no1 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight2,0)) truckweight
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.movement_no2 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight3,0)) truckweight
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.movement_no3 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight4,0)) truckweight
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.movement_no4 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight5,0)) truckweight
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.movement_no5 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight6,0)) truckweight
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.movement_no6 is not null
     and cn.truck_tanker = 'TRUCK'
   ;

   c1rec	C1%ROWTYPE;
   retvar varchar2(100);
   convoyweight	number;
   begin
   convoyweight := 0;
   for c1rec in c1( vConvoyid ) loop
    convoyweight:=convoyweight+nvl(c1rec.truckweight,0);
   end loop;
   return(to_char(convoyweight,'999999.999'));
 end f_display_convoy_weight;
/


GRANT EXECUTE ON STRANG.F_DISPLAY_CONVOY_WEIGHT TO WEBSYS;
