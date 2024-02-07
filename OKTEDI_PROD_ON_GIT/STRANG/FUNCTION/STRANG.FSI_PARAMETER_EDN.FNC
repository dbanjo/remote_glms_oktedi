CREATE OR REPLACE function STRANG.fsi_parameter_edn( parm_id in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2 )
 return varchar2
as

 -- P1 is SHIP_ID
 -- P2 is BOOKING_REF
 -- P3 is ECN

 cursor c1( p1 integer ) is select * from ships_airway where ship_id = p1;
 cursor c2( p1 integer, p2 varchar2, p3 varchar2 ) is
select * from movements where (movement_no,seal) in
(select m.movement_no,m.seal from movements m,detailrs dr where m.ship_id=p1 and
dr.ecn=p3 and m.movement_no = dr.movement_no and nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and m.seal is not null);

 cursor c2a( p1 integer, p2 varchar2, p3 varchar2 ) is
select * from movements where (movement_no,seal) in
(select m.movement_no,m.seal from movements m,detailrs dr where m.ship_id=p1 and
dr.ecn=p3 and m.movement_no = dr.movement_no and m.seal is null);

 cursor c2a1( p1 integer, p2 varchar2, p3 varchar2, ctrtyp varchar2 ) is select * from movements where (movement_no,seal) in
(select m.movement_no,m.seal from movements m,detailrs dr where m.ship_id=p1 and
dr.ecn=p3 and m.movement_no = dr.movement_no and nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and container_type = ctrtyp);

  cursor c2a2( p1 integer, p2 varchar2, p3 varchar2, ctrtyp varchar2 ) is
   select distinct detaildesc
   from strang.detailrs dr, strang.movements m
   where dr.movement_no = m.movement_no and
         nvl(camov_seal,'x') = nvl(seal,'x') and
         dr.ecn = p3 and
         m.ship_id = p1 and
         nvl(m.container_type,'BREAK BULK') = nvl(ctrtyp,'BREAK BULK');

 cursor c2a3( p1 integer, p2 varchar2, p3 varchar2 ) is
   select distinct ecn
   from strang.detailrs dr, strang.movements m
   where dr.movement_no = m.movement_no and
         nvl(camov_seal,'x') = nvl(seal,'x') and
         m.ship_id = p1 and
         dr.ecn is not null and
         dr.ecn = p3 ;

 cursor c2a4( p1 integer, p2 varchar2, p3 varchar2 ) is
   select count(*) haz_counter
   from strang.detailrs dr, strang.movements m
   where dr.movement_no = m.movement_no and
         nvl(camov_seal,'x') = nvl(seal,'x') and
         dr.hazard is not null and
         m.ship_id = p1 and
         dr.ecn = p3;

  cursor c2a5( p1 integer, p2 varchar2, p3 varchar2 ) is
   select distinct dr.hazard, dr.movement_no
   from strang.detailrs dr, strang.movements m
   where dr.movement_no = m.movement_no and
         nvl(camov_seal,'x') = nvl(seal,'x') and
         m.ship_id = p1 and
         dr.hazard is not null and
         dr.ecn = p3;

  cursor c2a6( p1 integer, p2 varchar2, p3 varchar2 ) is
   select distinct m.movement_no, m.move_description
   from strang.movements m, strang.detailrs dr
   where m.ship_id = p1 and
         m.move_description is not null and
         dr.ecn = p3;



 cursor c3( p1 integer, p2 varchar2, p3 varchar2 ) is select count('x') tot, sum(sumvolume) sumvolume, sum(sumweight) sumweight from movements
 where (movement_no,seal) in
 (select m.movement_no,m.seal from movements m,detailrs dr where m.ship_id=p1 and
 dr.ecn=p3 and m.movement_no = dr.movement_no and nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and (m.seal is not null));

 cursor c3a( p1 integer, p2 varchar2, p3 varchar2 ) is select count('x') tot, sum(sumvolume) sumvolume, sum(sumweight) sumweight from movements
 where (movement_no,seal) in
 (select m.movement_no,m.seal from movements m,detailrs dr where m.ship_id=p1 and
 dr.ecn=p3 and m.movement_no = dr.movement_no and nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and (m.seal is null));

 cursor c4( lv varchar2, cd varchar2 ) is select description from lov where lov_name = lv and code = cd;

 cursor c5( cid integer ) is select * from customers where customer_id = cid;

 cursor c6( p1 integer, p2 varchar2, p3 varchar2 ) is select distinct container_type  from movements
 where (movement_no,seal) in
 (select m.movement_no,m.seal from movements m,detailrs dr where m.ship_id=p1 and
 dr.ecn=p3 and m.movement_no = dr.movement_no and nvl(m.seal,'|') = nvl(dr.camov_seal,'|'));

 cursor c7( p3 varchar2 ) is
  select distinct customer,street,suburb,state,postcode,city,country,shipper_id,notify_party_id,consigned_to_id
  from detailrs dr, receivals r, customers c
  where dr.deliveryno = r.deliveryno and
        dr.ecn = p3 and
        nvl(r.cust_customer_id,0) = c.customer_id and
        c.customer_type = 'CUSTOMER';

 cursor c8( id varchar2 ) is
  select *
  from customers
  where customer_id = nvl(id,0);

 cursor c9( p1 integer, p2 varchar2, p3 varchar2 ) is
  select distinct detaildesc,container_type
  from movements m, detailrs dr
  where m.ship_id = p1 and
        m.movement_no = dr.movement_no and
        m.seal = dr.camov_seal and
        m.seal is not null and
        dr.ecn = p3;

 cursor c9a( p1 integer, p2 varchar2, p3 varchar2 ) is
  select distinct detaildesc,container_type
  from movements m, detailrs dr
  where m.ship_id = p1 and
        m.movement_no = dr.movement_no and
        m.seal is null and
        dr.ecn = p3;

 cursor c10( p1 integer, p2 varchar2, p3 varchar2, mv in varchar2, sl in varchar2 ) is
  select min(line_no) mn, max(line_no) mx
  from movements m, detailrs dr
  where m.ship_id = p1 and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|' ) and
        m.movement_no = mv and
        nvl(m.seal,'|') = nvl(sl,'|') and
        dr.ecn=p3;

  cursor c11( mtyp  varchar2 ) is  select colc from lov where lov_name='CTRTYPE' and code = mtyp ;

  cursor c12(p1 varchar2, p2 varchar2, p3 varchar2 ) is
  select /*+ ALL_ROWS */
  decode(nvl(container_type,'BREAK BULK'),'BREAK BULK','BREAK BULK',count(distinct m.movement_no) || ' CONTAINER/S ' || container_type) container_type,
         'M/L NOS ' || min(dr.line_no) || decode( max(dr.line_no) - min(dr.line_no),0,null, '-' || max(dr.line_no)) || ' ' ml,
         l1.code code,
         l1.colc colc,
         m.movement_type,
         nvl(m.container_type,'BREAK BULK') ctrtyp,
         sum(partweight) sumweight,
         sum(partvolume) sumvolume
  from strang.lov l1, strang.detailrs dr, strang.movements m
  where m.ship_id = to_number(p1) and
  dr.ecn = p3 and
        nvl(dr.camov_seal,'x') = nvl(m.seal,'x') and
        dr.movement_no = m.movement_no and
        l1.lov_name = 'CTRTYPE' and
        l1.code = nvl(m.container_type,'BREAK BULK')
  group by container_type,l1.colc,l1.code, m.movement_type
  order by l1.code;


  cursor c12a(p1 varchar2, p2 varchar2, p3 varchar2 ) is
  select /*+ ALL_ROWS */ m.movement_type,m.movement_no, m.movement_no|| htf.nl || m.seal || htf.nl || htf.nl container
  from strang.movements m
  where (movement_no,seal) in
 (select m.movement_no,m.seal
  from movements m,detailrs dr
  where m.ship_id=to_number(p1) and
  dr.ecn=p3 and
  m.movement_no = dr.movement_no and
  nvl(m.seal,'|') = nvl(dr.camov_seal,'|'))
  order by m.movement_type, m.movement_no;

  cursor c12b(p1 varchar2, p2 varchar2, p3 varchar2 ) is
  select /*+ ALL_ROWS */ m.movement_type,m.movement_no, to_char(m.sumweight,'999,999,999')|| htf.nl || to_char(nvl(m.tare,0),'999,999') || htf.nl || htf.nl sumwt
  from strang.movements m
  where (movement_no,seal) in
 (select m.movement_no,m.seal
 from movements m,detailrs dr
 where m.ship_id=to_number(p1) and
  dr.ecn=p3
   and m.movement_no = dr.movement_no and
   nvl(m.seal,'|') = nvl(dr.camov_seal,'|'))
  order by m.movement_type, m.movement_no;

  cursor c12c(p1 varchar2, p2 varchar2, p3 varchar2 ) is
  select /*+ ALL_ROWS */ m.movement_type,m.movement_no, to_char(m.sumvolume,'999,999,999.999')|| htf.nl || ' ' || htf.nl || htf.nl sumvol
  from strang.movements m
  where (movement_no,seal) in
 (select m.movement_no,m.seal
 from movements m,detailrs dr
 where m.ship_id=to_number(p1) and
  dr.ecn=p3 and
  m.movement_no = dr.movement_no and
  nvl(m.seal,'|') = nvl(dr.camov_seal,'|'))
  order by m.movement_type, m.movement_no;

 c1rec	c1%ROWTYPE;
 c2rec	c2%ROWTYPE;
 c2arec	c2%ROWTYPE;
c2a1rec	c2a1%ROWTYPE;
c2a2rec	c2a2%ROWTYPE;
c2a3rec	c2a3%ROWTYPE;
c2a4rec	c2a4%ROWTYPE;
c2a5rec	c2a5%ROWTYPE;
c2a6rec	c2a6%ROWTYPE;
 c3rec	c3%ROWTYPE;
 c3arec	c3%ROWTYPE;
 c4rec	c4%ROWTYPE;
 c4brec	c4%ROWTYPE;
 c4crec	c4%ROWTYPE;
 c5rec	c5%ROWTYPE;
 c7rec	c7%ROWTYPE;
 c8rec	c8%ROWTYPE;
 c9rec	c9%ROWTYPE;
 c9arec	c9a%ROWTYPE;
 c10rec	c10%ROWTYPE;
 c11rec	c11%ROWTYPE;
 c12rec	c12%ROWTYPE;
 c12arec	c12a%ROWTYPE;
 c12brec	c12b%ROWTYPE;
 c12crec	c12c%ROWTYPE;


 ctr	integer;
 lf	varchar2(20);
 tmp	varchar2(32767);
 tmp2	varchar2(32767);
 xctr   integer;
begin
 if parm_id = 'A1' -- Shipper
  then
   -- SHIPPER
   open c7(p3);
   fetch c7 into c7rec;
   close c7;
   open c8( c7rec.shipper_id );
   fetch c8 into c8rec;
   close c8;
   return( c8rec.customer || htf.nl || c8rec.street || htf.nl || c8rec.suburb || ' ' || c8rec.state || ' ' || c8rec.postcode || htf.nl || c8rec.city || ' ' || c8rec.country );
 elsif parm_id = 'A2' -- Booking Ref No
  then
   return( p2||' / '||p3 );
 elsif parm_id = 'A3' --Consigned to
  then
   open c7(p3);
   fetch c7 into c7rec;
   close c7;
   open c8( c7rec.consigned_to_id );
   fetch c8 into c8rec;
   close c8;
   return( c8rec.customer || htf.nl || c8rec.street || htf.nl || c8rec.suburb || ' ' || c8rec.state || ' ' || c8rec.postcode || htf.nl || c8rec.city || ' ' || c8rec.country );
 elsif parm_id = 'A4' -- Notify Party
  then
   open c7(p3);
   fetch c7 into c7rec;
   close c7;
   open c8( c7rec.notify_party_id );
   fetch c8 into c8rec;
   close c8;
   return( c8rec.customer || htf.nl || c8rec.street || htf.nl || c8rec.suburb || ' ' || c8rec.state || ' ' || c8rec.postcode || htf.nl || c8rec.city || ' ' || c8rec.country );
 elsif parm_id = 'A5' -- Vessel and Voyage No
  then
   open c1( to_number(p1));
   fetch c1 into c1rec;
   close c1;
   return( c1rec.shipname || ' ' || c1rec.voy );
 elsif parm_id = 'A6' -- Port of Loading
  then
   open c1( to_number(p1));
   fetch c1 into c1rec;
   close c1;
   open c4( 'LOCATIONS', c1rec.portload );
   fetch c4 into c4rec;
   close c4;
   return( c4rec.description );
 elsif parm_id = 'A7' -- Port of Discharge
  then
   open c1( to_number(p1));
   fetch c1 into c1rec;
   close c1;
   open c4( 'LOCATIONS', c1rec.portdisc );
   fetch c4 into c4rec;
   close c4;
   return( c4rec.description );
 elsif parm_id = 'A8' -- Final Des
  then
   open c1( to_number(p1));
   fetch c1 into c1rec;
   close c1;
   open c4( 'LOCATIONS', c1rec.finaldest );
   fetch c4 into c4rec;
   close c4;
   return( c4rec.description );
 elsif parm_id = 'A9' -- No of original
  then
   open c4( 'CONTROLS', 'BOLCOPIES' );
   fetch c4 into c4rec;
   close c4;
   return( c4rec.description );
elsif parm_id = 'AA' -- Quantity and Desc (now container / bb numbers )
  then
       tmp:='';
--       tmp:=tmp||htf.nl;
          for c12arec in c12a(to_number(p1),p2,p3) loop
            tmp:=tmp||c12arec.container;
       end loop;
   return( tmp );

 elsif parm_id = 'AB' -- Quantity and Desc
  then
       tmp:='';
       tmp:=tmp||htf.nl;
       tmp2:='';
          for c12rec in c12(to_number(p1),p2,p3) loop
            tmp:=tmp||c12rec.container_type||' ';
            if (c12rec.colc is null)
            then
               for c2a2rec in c2a2(to_number(p1),p2,p3,nvl(c12rec.code,'BREAK BULK')) loop
	        tmp := tmp || ', ' || c2a2rec.detaildesc;
	       end loop;
	        tmp := tmp || htf.nl|| htf.nl;
    --          tmp:= tmp ||' ' || strang.f_display_container(p1,p1,c12rec.CTRTYP,'DESCRIPTION')|| htf.nl;
            else
              tmp:= tmp ||' '||c12rec.colc || htf.nl|| htf.nl;
            end if;
	     end loop;
	     if substr(tmp,length(tmp)-1,2)=', ' then
	       tmp:=substr(tmp,1,length(tmp)-2);
	     end if;
	     tmp:= tmp || htf.nl || htf.nl;
	     tmp2:= tmp2||', '|| p3;
--               for c2a3rec in c2a3(to_number(p1),p2,p3) loop
--	        tmp2 := tmp2 || ', ' || c2a3rec.ecn;
--	       end loop;
	       tmp2:=trim(leading ',' from tmp2);
	       tmp2:=trim(leading ' ' from tmp2);
 	     tmp:= tmp || tmp2 || htf.nl || htf.nl;
/* 	     tmp2:='';
               for c2a5rec in c2a5(to_number(p1),p2,p3) loop
	        tmp2 := tmp2 || ', ' || c2a5rec.movement_no || ' ('|| c2a5rec.hazard || ')';
	       end loop;
	       if tmp2 is not null
	       then
	         tmp2:=trim(leading ',' from tmp2);
	         tmp2:=trim(leading ' ' from tmp2);
	         tmp2:='HAZARDOUS CARGO: '|| tmp2;
       	         tmp:= tmp || tmp2 || htf.nl || htf.nl;
 	         tmp2:='';
	       end if;

               for c2a6rec in c2a6(to_number(p1),p2,p3) loop
	        tmp2 := tmp2 || ', ' || c2a6rec.movement_no || ' ('|| c2a6rec.move_description || ')';
	       end loop;
	       if tmp2 is not null
	       then
	         tmp2:=trim(leading ',' from tmp2);
	         tmp2:=trim(leading ' ' from tmp2);
	         tmp2:='COMMENTS: '|| tmp2;
       	         tmp:= tmp || tmp2 || htf.nl || htf.nl;
	       end if;
*/



   return( tmp );

 elsif parm_id = 'AC' -- Gross Weight
  then
       tmp:='';
       tmp:=tmp||htf.nl;
          for c12brec in c12b(to_number(p1),p2,p3) loop
            tmp:=tmp||c12brec.sumwt;
       end loop;
   return( tmp );

--  if (c3rec.sumweight is null and c3arec.sumweight is null) then return( htf.nl ); end if;
--  if (c3rec.sumweight is not null and c3arec.sumweight is null) then return( htf.nl || to_char(c3rec.sumweight/1000,'999,999,990.000') || 'T' ); end if;
--  if (c3rec.sumweight is null and c3arec.sumweight is not null) then return( htf.nl || to_char(c3arec.sumweight/1000,'999,999,990.000') || 'T' ); end if;
--  return(  htf.nl || to_char(c3rec.sumweight/1000,'999,999,990.000') || 'T' || htf.nl || htf.nl || htf.nl || to_char(c3arec.sumweight/1000,'999,999,990.000') || 'T' );
--  return(  htf.nl || to_char((nvl(c3rec.sumweight,0)+nvl(c3arec.sumweight,0))/1000,'999,999,990.000') || 'T' );

 elsif parm_id = 'AD' -- Cubic Measure
  then
       tmp:='';
       tmp:=tmp||htf.nl;
          for c12crec in c12c(to_number(p1),p2,p3) loop
            tmp:=tmp||c12crec.sumvol;
       end loop;
   return( tmp );

  --if (c3rec.sumvolume is null and c3arec.sumvolume is null) then return( htf.nl ); end if;
  --if (c3rec.sumvolume is not null and c3arec.sumvolume is null) then return( htf.nl || to_char(c3rec.sumvolume,'999,999,990.000') || 'M3' ); end if;
  --if (c3rec.sumvolume is null and c3arec.sumvolume is not null) then return( htf.nl || to_char(c3arec.sumvolume,'999,999,990.000') || 'M3' ); end if;
--  return(  htf.nl || to_char((nvl(c3rec.sumvolume,0)+nvl(c3arec.sumvolume,0)),'999,999,990.000') || 'M3' || htf.nl );


 elsif parm_id = 'AF' -- Container Numbers
  then
   return( 'AS ABOVE' );

 elsif parm_id = 'AG' -- For the Carrier
  then
   open c4( 'CONTROLS', 'ON BEHALF' );
   fetch c4 into c4rec;
   close c4;
   return( c4rec.description );

 elsif parm_id = 'AH' -- Place of Acceptance
  then
   return( 'N/A' );

 elsif parm_id = 'AI' -- Place of Delivery
  then
   return( 'N/A' );

 elsif parm_id = 'AJ' -- Freight and Charges
  then
   open c4( 'CONTROLS', 'PAYABLE' );
   fetch c4 into c4rec;
   close c4;
   open c4( 'CONTROLS', 'PAYABLE_DESC' );
   fetch c4 into c4brec;
   close c4;
   open c4( 'CONTROLS', 'PAYABLE_DESC2' );
   fetch c4 into c4crec;
   close c4;
   if c1rec.freight is null
    then
     return( c4rec.description );
    else
     return( c4brec.description || ' ' || c1rec.freight || ' ' || c4crec.description );
   end if;
 elsif parm_id = 'AK' -- Total No
  then
   open c3( to_number(p1),p2,p3);
   fetch c3 into c3rec;
   close c3;
   open c3a( to_number(p1),p2,p3);
   fetch c3a into c3arec;
   close c3a;
   if c3arec.tot = 0
    then
     return( upper(conv_nmb_to_word(c3rec.tot)) || ' CONTAINERS' );
   elsif c3rec.tot = 0
    then
     return( 'BREAK-BULK ONLY' );
    else
     return( upper(conv_nmb_to_word(c3rec.tot)) || ' CONTAINERS + B/BULK' );
   end if;
 elsif parm_id = 'AL' -- Signed at
  then
--   open c4( 'CONTROLS', 'CITY' );
--   fetch c4 into c4rec;
--   close c4;
   open c1( to_number(p1));
   fetch c1 into c1rec;
   close c1;
   open c5( c1rec.customer_id);
   fetch c5 into c5rec;
   close c5;
   return( c5rec.city );
 elsif parm_id = 'ETD' -- Date
  then
   open c1( to_number(p1));
   fetch c1 into c1rec;
   close c1;
   if c1rec.estdepart is not null
   then
     return( to_char(c1rec.estdepart,'DD/MM/YYYY') );
   else
     return('TBA');
   end if;
 elsif parm_id = 'HAZ' -- hazardous
  then
   open c2a4( to_number(p1),p2,p3);
   fetch c2a4 into c2a4rec;
   close c2a4;
   if nvl(c2a4rec.haz_counter,0) > 0
   then
    return( 'YES');
   else
    return( 'NO' );
   end if;
 elsif parm_id = 'BR' -- Date
  then
   return( to_char('BR') );
 elsif parm_id = 'CMT' -- Date
  then
   return( to_char('CMT') );
 elsif parm_id = 'AM' -- Date
  then
   return( to_char('AM') );
 end if;
end fsi_parameter_edn;
/


GRANT EXECUTE ON STRANG.FSI_PARAMETER_EDN TO WEBSYS;
