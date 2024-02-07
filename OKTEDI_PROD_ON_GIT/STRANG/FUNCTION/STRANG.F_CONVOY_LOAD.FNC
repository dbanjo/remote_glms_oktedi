CREATE OR REPLACE function STRANG.f_convoy_load( vConvoyID number, vLoad number, xLns integer)
   return varchar
  as

    cursor c1a(Convoyid number,vrno number) is
     select operator,truck_tanker,truck_id,trailer_id,fuel_type,fuel_litres
     from strang.convoy_details_vw
     where convoy_id = convoyid
     and rno2 = vrno;

    cursor c1(Convoyid number, vrno number) is
     select cn.movement_no1 movement_no, cn.seal1 seal, cn.full_mt1 full_mt, cn.iso_container_type1 iso_container_type, cn.weight1 weight, cn.tare1 tare,
     cn.container_type1 container_type, cn.hazard1 hazard, cn.overdimensional1 overdimensional, cn.warehouse_destination1 warehouse_destination,
     cn.urgency1 urgency, cn.lookup1 lookup, cn.set_point1 set_point, cn.consignee1 consignee, cn.consignee_location1 consignee_location,cn.vessel1 vessel,
     cn.trailer_id
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.movement_no1 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select cn.movement_no2 movement_no, cn.seal2 seal, cn.full_mt2 full_mt, cn.iso_container_type2 iso_container_type, cn.weight2 weight, cn.tare2 tare,
     cn.container_type2 container_type, cn.hazard2 hazard, cn.overdimensional2 overdimensional, cn.warehouse_destination2 warehouse_destination,
     cn.urgency2 urgency, cn.lookup2 lookup, cn.set_point2 set_point, cn.consignee2 consignee, cn.consignee_location2 consignee_location,cn.vessel2 vessel,
     cn.trailer_id
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.movement_no2 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select cn.movement_no3 movement_no, cn.seal3 seal, cn.full_mt3 full_mt, cn.iso_container_type3 iso_container_type, cn.weight3 weight, cn.tare3 tare,
     cn.container_type3 container_type, cn.hazard3 hazard, cn.overdimensional3 overdimensional, cn.warehouse_destination3 warehouse_destination,
     cn.urgency3 urgency, cn.lookup3 lookup, cn.set_point3 set_point, cn.consignee3 consignee, cn.consignee_location3 consignee_location,cn.vessel3 vessel,
     cn.trailer_id
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.movement_no3 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select cn.movement_no4 movement_no, cn.seal4 seal, cn.full_mt4 full_mt, cn.iso_container_type4 iso_container_type, cn.weight4 weight, cn.tare4 tare,
     cn.container_type4 container_type, cn.hazard4 hazard, cn.overdimensional4 overdimensional, cn.warehouse_destination4 warehouse_destination,
     cn.urgency4 urgency, cn.lookup4 lookup, cn.set_point4 set_point, cn.consignee4 consignee, cn.consignee_location4 consignee_location,cn.vessel4 vessel,
     cn.trailer_id
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.movement_no4 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select cn.movement_no5 movement_no, cn.seal5 seal, cn.full_mt5 full_mt, cn.iso_container_type5 iso_container_type, cn.weight5 weight, cn.tare5 tare,
     cn.container_type5 container_type, cn.hazard5 hazard, cn.overdimensional5 overdimensional, cn.warehouse_destination5 warehouse_destination,
     cn.urgency5 urgency, cn.lookup5 lookup, cn.set_point5 set_point, cn.consignee5 consignee, cn.consignee_location5 consignee_location,cn.vessel5 vessel,
     cn.trailer_id
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.movement_no5 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select cn.movement_no6 movement_no, cn.seal6 seal, cn.full_mt6 full_mt, cn.iso_container_type6 iso_container_type, cn.weight6 weight, cn.tare6 tare,
     cn.container_type6 container_type, cn.hazard6 hazard, cn.overdimensional6 overdimensional, cn.warehouse_destination6 warehouse_destination,
     cn.urgency6 urgency, cn.lookup6 lookup, cn.set_point6 set_point, cn.consignee6 consignee, cn.consignee_location6 consignee_location,cn.vessel6 vessel,
     cn.trailer_id
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.movement_no6 is not null
     and cn.truck_tanker = 'TRUCK'
   order by 1  ;

    cursor c2(Convoyid number, vrno number) is
     select sum(nvl(cn.weight1,0)) truckweight
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.movement_no1 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight2,0)) truckweight
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.movement_no2 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight3,0)) truckweight
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.movement_no3 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight4,0)) truckweight
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.movement_no4 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight5,0)) truckweight
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.movement_no5 is not null
     and cn.truck_tanker = 'TRUCK'
    union
     select sum(nvl(cn.weight6,0)) truckweight
     from strang.convoy_details_vw cn
     where cn.convoy_id = Convoyid
     and cn.rno2 = vrno
     and cn.movement_no6 is not null
     and cn.truck_tanker = 'TRUCK'
   ;
   
   cursor c3 (mv varchar2, sl varchar2) is
    select count(*) cnt
     from strang.detailrs dr
     where dr.movement_no = mv
       and nvl(dr.camov_seal,'|') = nvl(sl,'|')
       and dr.hazard is not null;
     

   c1arec	C1a%ROWTYPE;
   c2rec	C2%ROWTYPE;
   c3rec	C3%ROWTYPE;

   retvar varchar2(32767);
   retvar1	varchar2(1500);
   countr	number;
   emptytrailer boolean;
   mv		varchar2(100);
   trkweight	number;
   trailerdesc  varchar2(100);
   adlnfd      integer;
   begin

   retvar := null;
   retvar1 := null;
   adLnFd := 0;
   trkweight := 0;
   mv := null;
   emptytrailer := TRUE;
   countr:=0;

      open c1a(vConvoyid,vload);
      fetch c1a into c1arec;
      if c1a%NOTFOUND
       then
        close c1a;
        return('&nbsp;');
      end if;
      close c1a;
    if c1arec.truck_tanker = 'TANKER' then
      retvar:= '<B>'||strang.f_getLovColumn( 'OPERATORS', 'DESCRIPTION', c1arec.operator)||'</B>'||htf.nl||'<FONT COLOR="BLUE">'||to_char(c1arec.truck_id)||htf.nl||to_char(c1arec.trailer_id)||htf.nl||c1arec.fuel_type
      ||htf.nl||nvl(to_char(c1arec.fuel_litres),'Capacity '||strang.f_getLovColumn( 'TRAILERS', 'COLC', c1arec.trailer_id))||'<FONT COLOR="BLACK">';
      countr := 2;
    else
        for c1rec in c1( vConvoyid, vLoad ) loop
          
         open c3(c1rec.movement_no ,c1rec.seal);   
         fetch c3 into c3rec;
         close c3;
         
         if countr = 0 then
          countr := countr + 1;
          
           if c1rec.seal is null and c1rec.iso_container_type is null then
             mv:='BBULK '||c1rec.movement_no;
           else
             if c3rec.cnt <> 0 then
                mv:=c1rec.iso_container_type||' - '||'<FONT COLOR="RED">'||c1rec.movement_no||'*'||'<FONT COLOR="BLACK">'||' - '||c1rec.weight||'T ';
             else 
                mv:=c1rec.iso_container_type||' - '||c1rec.movement_no||' - '||c1rec.weight||'T '; --||substr(c1rec.container_type,1,10);
             end if;
           end if;
           if nvl(c1rec.weight,0) > 23.4 then
            retvar := '<FONT COLOR="PURPLE">'|| mv ||'<FONT COLOR="BLACK">';
           else
            retvar := mv;
           end if;
         else
         countr := countr + 1;
           if c1rec.seal is null and c1rec.iso_container_type is null then
             mv:='BBULK '||c1rec.movement_no;
           else
             if c3rec.cnt <> 0 then
                mv:=c1rec.iso_container_type||' - '||'<FONT COLOR="RED">'||c1rec.movement_no||'*'||'<FONT COLOR="BLACK">'||' - '||c1rec.weight||'T ';
             else
                mv:=c1rec.iso_container_type||' - '||c1rec.movement_no||' - '||c1rec.weight||'T ';--||substr(c1rec.container_type,1,10);
             end if;
           end if;
           if nvl(c1rec.weight,0) > 23.4 then
            retvar := retvar||htf.nl||'<FONT COLOR="PURPLE">'|| mv ||'<FONT COLOR="BLACK">';
           else
            retvar := retvar||htf.nl|| mv ;
           end if;
         end if;
        end loop;
      retvar:= '<B>'||strang.f_getLovColumn( 'OPERATORS', 'DESCRIPTION', c1arec.operator)||'</B>'||htf.nl||to_char(c1arec.truck_id)||htf.nl||to_char(c1arec.trailer_id)||htf.nl||retvar;
    end if;
    if countr=0 then countr:=1; end if;
    adlnfd:= xLns - countr;
    if adlnfd > 0 then
      for j in 1..adlnfd loop
        retvar1:= retvar1||htf.nl;
      end loop;
      retvar:= retvar||retvar1;
    end if;
    return( retvar );
 --   return ( retvar||'****'||to_char(countr)||'***'||to_char(adlnfd) );

 end f_convoy_load;
/


GRANT EXECUTE ON STRANG.F_CONVOY_LOAD TO WEBSYS;
