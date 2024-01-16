CREATE OR REPLACE function STRANG.f_display_convoy_count( vConvoyid number, typ varchar2 )
   return varchar
  as

    cursor c1(Convoyid number) is
     select count(cn.movement_no1) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no1 is not null
     and cn.iso_container_type1 is not null
     and cn.full_mt1 = 'FULL'
    union all
     select count(cn.movement_no2) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no2 is not null
     and cn.iso_container_type2 is not null
     and cn.full_mt2 = 'FULL'
    union all
     select count(cn.movement_no3) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no3 is not null
     and cn.iso_container_type3 is not null
     and cn.full_mt3 = 'FULL'
    union all
     select count(cn.movement_no4) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no4 is not null
     and cn.iso_container_type4 is not null
     and cn.full_mt4 = 'FULL'
    union all
     select count(cn.movement_no5) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no5 is not null
     and cn.iso_container_type5 is not null
     and cn.full_mt5 = 'FULL'
    union all
     select count(cn.movement_no6) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no6 is not null
     and cn.iso_container_type6 is not null
     and cn.full_mt6 = 'FULL'
   ;

    cursor c2(Convoyid number) is
     select count(cn.movement_no1) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no1 is not null
     and cn.iso_container_type1 is null
    union all
     select count(cn.movement_no2) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no2 is not null
     and cn.iso_container_type2 is null
    union all
     select count(cn.movement_no3) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no3 is not null
     and cn.iso_container_type3 is null
    union all
     select count(cn.movement_no4) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no4 is not null
     and cn.iso_container_type4 is null
    union all
     select count(cn.movement_no5) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no5 is not null
     and cn.iso_container_type5 is null
    union all
     select count(cn.movement_no6) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no6 is not null
     and cn.iso_container_type6 is null
   ;
       cursor c3(Convoyid number) is
        select *
        from strang.convoy cn
        where cn.convoy_id = Convoyid
      ;
       cursor c4(Convoyid number) is
        select count(*) totdrivers
        from strang.convoy_details cn
        where cn.convoy_id = Convoyid
      ;
    cursor c5(Convoyid number) is
     select count(cn.movement_no1) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no1 is not null
     and cn.iso_container_type1 is not null
    union all
     select count(cn.movement_no2) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no2 is not null
     and cn.iso_container_type2 is not null
    union all
     select count(cn.movement_no3) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no3 is not null
     and cn.iso_container_type3 is not null
    union all
     select count(cn.movement_no4) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no4 is not null
     and cn.iso_container_type4 is not null
    union all
     select count(cn.movement_no5) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no5 is not null
     and cn.iso_container_type5 is not null
    union all
     select count(cn.movement_no6) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no6 is not null
     and cn.iso_container_type6 is not null
   ;
   
    cursor c6(Convoyid number) is
     select count(cn.movement_no1) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no1 is not null
     and cn.iso_container_type1 is not null
     and cn.full_mt1 = 'EMPTY'
    union all
     select count(cn.movement_no2) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no2 is not null
     and cn.iso_container_type2 is not null
     and cn.full_mt2 = 'EMPTY'
    union all
     select count(cn.movement_no3) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no3 is not null
     and cn.iso_container_type3 is not null
     and cn.full_mt3 = 'EMPTY'
    union all
     select count(cn.movement_no4) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no4 is not null
     and cn.iso_container_type4 is not null
     and cn.full_mt4 = 'EMPTY'
    union all
     select count(cn.movement_no5) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no5 is not null
     and cn.iso_container_type5 is not null
     and cn.full_mt5 = 'EMPTY'
    union all
     select count(cn.movement_no6) ctr
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.truck_tanker = 'TRUCK'
     and cn.movement_no6 is not null
     and cn.iso_container_type6 is not null
     and cn.full_mt6 = 'EMPTY'
   ;

   c1rec	C1%ROWTYPE;
   c2rec	C2%ROWTYPE;
   c3rec	C3%ROWTYPE;
   c4rec	C4%ROWTYPE;
   retvar varchar2(32767);
   countr	number;
   begin
   countr := 0;
   if typ = 'DR_COUNT' then
    open c3(vConvoyid);
    fetch c3 into c3rec;
    if c3%FOUND then
       if C3REC.ESCORT1_DRIVER is not null then countr:=countr + 1; end if;
       if C3REC.ESCORT2_DRIVER is not null then countr:=countr + 1; end if;
       if C3REC.SUPPORT_TRUCK_OPERATOR1 is not null then countr:=countr + 1; end if;
       if C3REC.SUPPORT_TRUCK_OPERATOR2 is not null then countr:=countr + 1; end if;
       if C3REC.EQUIPMENT_OPERATOR_1 is not null then countr:=countr + 1; end if;
       if C3REC.EQUIPMENT_OPERATOR_2 is not null then countr:=countr + 1; end if;
       if C3REC.EQUIPMENT_OPERATOR_3 is not null then countr:=countr + 1; end if;
    end if;
    close c3;
    open c4(vConvoyid);
    fetch c4 into c4rec;
    if c4%FOUND then
     countr := countr + c4rec.totdrivers;
    end if;
    close c4;
   end if;

   if typ = 'FCL_COUNT' then
    for c1rec in c1( vConvoyid ) loop
     countr := countr + c1rec.ctr;
    end loop;
   end if;
   
   if typ = 'EMPTY_COUNT' then
    for c6rec in c6( vConvoyid ) loop
     countr := countr + c6rec.ctr;
    end loop;
   end if;
   
   if typ = 'CONTAINER_COUNT' then
    for c5rec in c5( vConvoyid ) loop
     countr := countr + c5rec.ctr;
    end loop;
   end if;
   
   if typ = 'BB_COUNT' then
    for c2rec in c2( vConvoyid ) loop
     countr := countr + c2rec.ctr;
    end loop;
   end if;
   
   return( to_char(countr));
 end f_display_convoy_count;
/


GRANT EXECUTE ON STRANG.F_DISPLAY_CONVOY_COUNT TO WEBSYS;
