CREATE OR REPLACE function STRANG.f_display_trucks( vConvoyid number, vRno number, typ in varchar2 )
   return varchar
  as

    cursor c1(Convoyid number, vrno number) is
     select decode(cn.movement_no1,null,null,1) sorder, cn.movement_no1 movement_no, cn.seal1 seal, cn.full_mt1 full_mt, cn.iso_container_type1 iso_container_type, cn.weight1 weight, cn.tare1 tare,
     cn.container_type1 container_type, cn.hazard1 hazard, cn.overdimensional1 overdimensional, cn.warehouse_destination1 warehouse_destination,
     cn.urgency1 urgency, cn.lookup1 lookup, cn.set_point1 set_point, cn.consignee1 consignee, cn.consignee_location1 consignee_location,cn.vessel1 vessel,
     cn.trailer_id
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.rno = vrno
     and cn.movement_no1 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select decode(cn.movement_no2,null,null,2) sorder, cn.movement_no2 movement_no, cn.seal2 seal, cn.full_mt2 full_mt, cn.iso_container_type2 iso_container_type, cn.weight2 weight, cn.tare2 tare,
     cn.container_type2 container_type, cn.hazard2 hazard, cn.overdimensional2 overdimensional, cn.warehouse_destination2 warehouse_destination,
     cn.urgency2 urgency, cn.lookup2 lookup, cn.set_point2 set_point, cn.consignee2 consignee, cn.consignee_location2 consignee_location,cn.vessel2 vessel,
     cn.trailer_id
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.rno = vrno
     and cn.movement_no2 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select decode(cn.movement_no3,null,null,3) sorder, cn.movement_no3 movement_no, cn.seal3 seal, cn.full_mt3 full_mt, cn.iso_container_type3 iso_container_type, cn.weight3 weight, cn.tare3 tare,
     cn.container_type3 container_type, cn.hazard3 hazard, cn.overdimensional3 overdimensional, cn.warehouse_destination3 warehouse_destination,
     cn.urgency3 urgency, cn.lookup3 lookup, cn.set_point3 set_point, cn.consignee3 consignee, cn.consignee_location3 consignee_location,cn.vessel3 vessel,
     cn.trailer_id
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.rno = vrno
     and cn.movement_no3 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select decode(cn.movement_no4,null,null,4) sorder, cn.movement_no4 movement_no, cn.seal4 seal, cn.full_mt4 full_mt, cn.iso_container_type4 iso_container_type, cn.weight4 weight, cn.tare4 tare,
     cn.container_type4 container_type, cn.hazard4 hazard, cn.overdimensional4 overdimensional, cn.warehouse_destination4 warehouse_destination,
     cn.urgency4 urgency, cn.lookup4 lookup, cn.set_point4 set_point, cn.consignee4 consignee, cn.consignee_location4 consignee_location,cn.vessel4 vessel,
     cn.trailer_id
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.rno = vrno
     and cn.movement_no4 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select decode(cn.movement_no5,null,null,5) sorder, cn.movement_no5 movement_no, cn.seal5 seal, cn.full_mt5 full_mt, cn.iso_container_type5 iso_container_type, cn.weight5 weight, cn.tare5 tare,
     cn.container_type5 container_type, cn.hazard5 hazard, cn.overdimensional5 overdimensional, cn.warehouse_destination5 warehouse_destination,
     cn.urgency5 urgency, cn.lookup5 lookup, cn.set_point5 set_point, cn.consignee5 consignee, cn.consignee_location5 consignee_location,cn.vessel5 vessel,
     cn.trailer_id
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.rno = vrno
     and cn.movement_no5 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select decode(cn.movement_no6,null,null,6) sorder, cn.movement_no6 movement_no, cn.seal6 seal, cn.full_mt6 full_mt, cn.iso_container_type6 iso_container_type, cn.weight6 weight, cn.tare6 tare,
     cn.container_type6 container_type, cn.hazard6 hazard, cn.overdimensional6 overdimensional, cn.warehouse_destination6 warehouse_destination,
     cn.urgency6 urgency, cn.lookup6 lookup, cn.set_point6 set_point, cn.consignee6 consignee, cn.consignee_location6 consignee_location,cn.vessel6 vessel,
     cn.trailer_id
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.rno = vrno
     and cn.movement_no6 is not null
     and cn.truck_tanker = 'TRUCK'
   order by 1  ;

    cursor c2(Convoyid number, vrno number) is
     select sum(nvl(cn.weight1,0)) truckweight
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.rno = vrno
     and cn.movement_no1 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight2,0)) truckweight
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.rno = vrno
     and cn.movement_no2 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight3,0)) truckweight
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.rno = vrno
     and cn.movement_no3 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight4,0)) truckweight
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.rno = vrno
     and cn.movement_no4 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight5,0)) truckweight
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.rno = vrno
     and cn.movement_no5 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight6,0)) truckweight
     from strang.convoy_details cn
     where cn.convoy_id = Convoyid
     and cn.rno = vrno
     and cn.movement_no6 is not null
     and cn.truck_tanker = 'TRUCK'
   ;

    cursor c3(icode varchar2) is
    select substr(l.description,8) isodesc
    from strang.lov l
    where icode = l.code
    and l.lov_name = 'UNCTNTAB';



   c2rec	C2%ROWTYPE;
   c3rec	C3%ROWTYPE;

   retvar varchar2(32767);
   countr	number;
   emptytrailer boolean;
   mv		varchar2(40);
   trkweight	number;
   trailerdesc  varchar2(100);
   begin
   trkweight := 0;
   mv := null;
   emptytrailer := TRUE;
    for c1rec in c1( vConvoyid, vRno ) loop
     if c1rec.movement_no is not null then
       emptytrailer := FALSE;
     end if;
     trailerdesc := strang.f_getLovColumn('TRAILERS','DESCRIPTION',c1rec.trailer_id);
    end loop;
   countr := 0;

   if typ = 'CTRNO' then
    if emptytrailer then
      return( '&nbsp;' );
    end if;
    for c1rec in c1( vConvoyid, vRno ) loop
     if countr = 0 then
      countr := countr + 1;
       if c1rec.iso_container_type is null then
         mv:='BREAK BULK '||c1rec.movement_no;
         if mv = 'BREAK BULK BREAK BULK' then
           mv := 'BREAK BULK';
         end if;
       else
         mv:=c1rec.movement_no;
       end if;
       if nvl(c1rec.weight,0) > 23.4 then
        retvar := '<FONT COLOR="PURPLE">'|| mv ||'<FONT COLOR="BLACK">';
       else
        retvar := mv;
       end if;
     else
     countr := countr + 1;
       if c1rec.seal is null and c1rec.iso_container_type is null then
         mv:='BREAK BULK '||c1rec.movement_no;
         if mv = 'BREAK BULK BREAK BULK' then
           mv := 'BREAK BULK';
         end if;
       else
         mv:=c1rec.movement_no;
       end if;
       if nvl(c1rec.weight,0) > 23.4 then
        retvar := retvar||htf.nl||'<FONT COLOR="PURPLE">'|| mv ||'<FONT COLOR="BLACK">';
       else
        retvar := retvar||htf.nl|| mv ;
       end if;
     end if;
    end loop;
   end if;
   if typ = 'ISO_CODE' then
    if emptytrailer then
      return( '&nbsp;' );
    end if;
    for c1rec in c1( vConvoyid, vRno ) loop
     if countr = 0 then
        retvar := c1rec.iso_container_type;
        countr := countr + 1;
     else
        retvar := retvar||htf.nl||c1rec.iso_container_type;
        countr := countr + 1;
     end if;
    end loop;
   end if;
   if typ = 'ISO' then
    if emptytrailer then
      return( '&nbsp;' );
    end if;
    for c1rec in c1( vConvoyid, vRno ) loop
     if countr = 0 then
      open c3(c1rec.iso_container_type);
      fetch c3 into c3rec;
      if C3%FOUND then
        retvar := c3rec.isodesc;
      else
        retvar := c1rec.iso_container_type;
      end if;
      close c3;
      countr := countr + 1;
     else
      open c3(c1rec.iso_container_type);
      fetch c3 into c3rec;
      if C3%FOUND then
        retvar := retvar||htf.nl||c3rec.isodesc;
      else
        retvar := retvar||htf.nl||c1rec.iso_container_type;
      end if;
      close c3;
     countr := countr + 1;
     end if;
    end loop;
   end if;
   if typ = 'WEIGHT' then
    if emptytrailer then
      retvar := '0.000';
    else
     for c1rec in c1( vConvoyid, vRno ) loop
      if countr = 0 then
      retvar := to_char(c1rec.weight,'999999.999');
      countr := countr + 1;
      else
      retvar := retvar||htf.nl||to_char(c1rec.weight,'999999.999');
      countr := countr + 1;
      end if;
     end loop;
    end if;
   end if;

   if typ = 'TRWEIGHT' then
    trkweight:=0;
    if emptytrailer then
     return( '0.000' );
    else
     for c2rec in c2( vConvoyid, vRno ) loop
       trkweight:=trkweight+nvl(c2rec.truckweight,0);
     end loop;
     return(nvl(to_char(trkweight,'999999.999'),'0'));
    end if;

   end if;
   if typ = 'MATERIAL' then
    if emptytrailer then
      return( 'EMPTY TRAILER  '||trailerdesc );
    end if;
    for c1rec in c1( vConvoyid, vRno ) loop
       if countr = 0 then
        if c1rec.iso_container_type is not null and c1rec.full_mt = 'EMPTY' then
         retvar:='EMPTY '|| upper(strang.f_getLovColumn('UNCTNTAB','DESCRIPTION',c1rec.iso_container_type));
        else
         retvar:= c1rec.container_type;
        end if;
        countr := countr + 1;
       else
        if c1rec.iso_container_type is not null and c1rec.full_mt = 'EMPTY' then
         retvar:=retvar||htf.nl||'EMPTY '|| upper(strang.f_getLovColumn('UNCTNTAB','DESCRIPTION',c1rec.iso_container_type));
        else
         retvar := retvar||htf.nl||c1rec.container_type;
        end if;
        countr := countr + 1;
       end if;
       if c1rec.hazard is not null
       then
         retvar:= retvar ||'<FONT COLOR="RED"> '||c1rec.hazard||'<FONT COLOR="BLACK"> ';
       end if;
       if c1rec.overdimensional is not null
       then
        retvar := retvar ||'<FONT COLOR = "GREEN"> '||c1rec.overdimensional||'<FONT COLOR = "BLACK">';
       end if;
       if c1rec.set_point is not null then
        retvar := retvar ||'<FONT COLOR = "BLUE"> '||c1rec.set_point||'<FONT COLOR = "BLACK">';
       end if;
    end loop;
   end if;
   if typ = 'VESSEL' then
    for c1rec in c1( vConvoyid, vRno ) loop
     if countr = 0 then
     retvar := c1rec.vessel;
     countr := countr + 1;
     else
     retvar := retvar||htf.nl||c1rec.vessel;
     countr := countr + 1;
     end if;
    end loop;
   end if;
   if typ = 'DESTINATION' then
    if emptytrailer then
      return( '&nbsp;' );
    end if;
    for c1rec in c1( vConvoyid, vRno ) loop
     if countr = 0 then
     retvar := nvl(c1rec.warehouse_destination,c1rec.consignee)||' '||c1rec.consignee_location;
     countr := countr + 1;
     else
     retvar := retvar||htf.nl||nvl(c1rec.warehouse_destination,c1rec.consignee)||' '||c1rec.consignee_location;
     countr := countr + 1;
     end if;
     if nvl(c1rec.urgency,'STANDARD') <> 'STANDARD'
     then
      retvar := retvar ||'<FONT COLOR = "RED"> '||c1rec.urgency||'<FONT COLOR = "BLACK">';
     end if;
    end loop;
   end if;
   return( retvar );
 end f_display_trucks;
/


GRANT EXECUTE ON STRANG.F_DISPLAY_TRUCKS TO WEBSYS;
