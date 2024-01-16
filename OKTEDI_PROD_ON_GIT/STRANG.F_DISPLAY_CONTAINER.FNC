CREATE OR REPLACE function STRANG.f_display_container( vShipid varchar2, vBol varchar2, vCtr varchar2, action in varchar2 )
 return varchar2
as

 cursor c1(vShipid varchar2, vBol varchar2, vCtr varchar2) is
  select m.movement_no,min(dr.line_no) mn,max(dr.line_no) mx
  from strang.detailrs dr, strang.movements m
  where dr.movement_no(+) = m.movement_no and
        nvl(camov_seal(+),'x') = nvl(seal,'x') and
        m.ship_id = vShipid and
        m.bol = vBol and
        nvl(m.container_type,'BREAK BULK') = nvl(vCtr,'BREAK BULK')
  group by m.movement_no;

 cursor c2(vShipid varchar2, vBol varchar2, vCtr varchar2) is
  select distinct detaildesc
  from strang.detailrs dr, strang.movements m
  where dr.movement_no = m.movement_no and
        nvl(camov_seal,'x') = nvl(seal,'x') and
        m.ship_id = vShipid and
        m.bol = vBol and
        nvl(m.container_type,'BREAK BULK') = nvl(vCtr,'BREAK BULK');

 cursor c3(vCtrno varchar2,vShipid varchar2) is
 select distinct l.code warehouse
 from strang.lov l, strang.movements m
 where m.movement_no = vCtrno and
  m.ship_id = vShipid and
  l.lov_name = 'LOCATIONS'
 and l.code = m.warehouse_destination;

 cursor c4(vCtrno varchar2, vShipid varchar2) is
 select distinct l.cola ctype, m.iso_container_type
 from strang.lov l, strang.movements m
 where m.movement_no = vCtrno and
  m.ship_id = vShipid and
  l.lov_name = 'UNCTNTAB'
 and l.code = m.iso_container_type;

--
 cursor c1a(vShipid varchar2, vBol varchar2, vCtr varchar2) is
  select m.movement_no,min(dr.local_line_no) mn,max(dr.local_line_no) mx
  from strang.detailrs dr, strang.movements m
  where dr.movement_no (+)= m.movement_no and
        nvl(camov_seal(+),'x') = nvl(seal,'x') and
        m.local_ship_id = vShipid and
        m.local_bol = vBol and
        nvl(m.container_type,'BREAK BULK') = nvl(vCtr,'BREAK BULK')
  group by m.movement_no;

 cursor c2a(vShipid varchar2, vBol varchar2, vCtr varchar2) is
  select distinct detaildesc
  from strang.detailrs dr, strang.movements m
  where dr.movement_no = m.movement_no and
        nvl(camov_seal,'x') = nvl(seal,'x') and
        m.local_ship_id = vShipid and
        m.local_bol = vBol and
        nvl(m.container_type,'BREAK BULK') = nvl(vCtr,'BREAK BULK');

 cursor c3a(vCtrno varchar2,vShipid varchar2) is
 select distinct l.code warehouse
 from strang.lov l, strang.movements m
 where m.movement_no = vCtrno and
  m.local_ship_id = vShipid and
  l.lov_name = 'LOCATIONS'
 and l.code = m.warehouse_destination;

 cursor c4a(vCtrno varchar2, vShipid varchar2) is
 select distinct l.cola ctype, m.iso_container_type
 from strang.lov l, strang.movements m
 where m.movement_no = vCtrno and
  m.local_ship_id = vShipid and
  l.lov_name = 'UNCTNTAB'
 and l.code = m.iso_container_type;

 c1rec  c1%ROWTYPE;
 c3rec  c3%ROWTYPE;
 c1arec  c1%ROWTYPE;
 c3arec  c3%ROWTYPE;
 retvar	varchar2(32767);
 lrec   varchar2(100);
 xctr   integer;

begin
 if action = 'NUMBERS'
  then
   for c1rec in c1(vShipid, vBol, vCtr ) loop
      if upper(vCtr) in ( 'EMPTIES', 'EMPTY')  then
         retvar := retvar || htf.nl || c1rec.movement_no; 
      else
         retvar := retvar || htf.nl || c1rec.movement_no || htf.nl || '(' || c1rec.mn || '-' || c1rec.mx || ')' ;
      end if;
      
      xctr:=0;
      for c3rec in c3(c1rec.movement_no,vShipid) loop
          xctr := xctr + 1;
          if xctr > 1 then
            retvar := retvar || htf.nl;
          end if;
      end loop;
   end loop;
   return(substr(substr(retvar,length(htf.nl)+1 ),1,4000));
 elsif action = 'DESCRIPTION'
  then
   for c2rec in c2(vShipid, vBol, vCtr ) loop
    retvar := retvar || ', ' || c2rec.detaildesc;
   end loop;
   return( substr(nvl(substr(retvar,3),'&nbsp'),1,4000) );
 elsif action = 'WAREHOUSE'
  then
   for c1rec in c1(vShipid, vBol, vCtr ) loop
     for c3rec in c3(c1rec.movement_no,vShipid) loop
      retvar := retvar || htf.nl || c3rec.warehouse ; --|| htf.nl;
     end loop;
     
     if upper(vCtr) in ( 'EMPTIES', 'EMPTY') then
        retvar := retvar;
     else  
        retvar := retvar || htf.nl ;
     end if;    
     
     --- retvar := retvar || htf.nl ;
   end loop;
   return (substr(replace(substr(retvar,length(htf.nl)+1 ),' ','_'),1,4000));
 elsif action = 'TYPE'
  then
   for c1rec in c1(vShipid, vBol, vCtr ) loop
     for c4rec in c4(c1rec.movement_no,vShipid) loop
      retvar := retvar || htf.nl || c4rec.ctype ; --|| htf.nl;
     end loop;
   if upper(vCtr) in ( 'EMPTIES', 'EMPTY') then
     retvar := retvar;
   else  
      retvar := retvar || htf.nl ;
   end if;
   end loop;
   return (substr(replace(substr(retvar,length(htf.nl)+1 ),' ','_'),1,4000));

--   ---------------------------------
/*
 if action = 'NUMBERS'
  then
   for c1rec in c1(vShipid, vBol, vCtr ) loop
      if upper(vCtr) in ( 'EMPTIES', 'EMPTY')  then
         retvar := retvar || htf.nl || c1rec.movement_no; 
      else
         retvar := retvar || htf.nl || c1rec.movement_no || htf.nl || '(' || c1rec.mn || '-' || c1rec.mx || ')' ;
      end if;
      
      xctr:=0;
      for c3rec in c3(c1rec.movement_no,vShipid) loop
          xctr := xctr + 1;
          if xctr > 1 then
            retvar := retvar || htf.nl;
          end if;
      end loop;
   end loop;
   return(substr(substr(retvar,length(htf.nl)+1 ),1,4000));

*/

 elsif action = 'L_NUMBERS'
  then
  
   for c1arec in c1a(vShipid, vBol, vCtr ) loop
     if upper(vCtr) in ( 'EMPTIES', 'EMPTY')  then
        retvar := retvar || htf.nl || c1arec.movement_no; 
     else
        retvar := retvar || htf.nl || c1arec.movement_no || htf.nl || '(' || c1arec.mn || '-' || c1arec.mx || ')' ;
     end if;
      xctr:=0;
      for c3arec in c3a(c1arec.movement_no,vShipid) loop
          xctr := xctr + 1;
          if xctr > 1 then
            retvar := retvar || htf.nl;
          end if;
      end loop;
   end loop;
   return(substr(substr(retvar,length(htf.nl)+1 ),1,4000));
   
   
 elsif action = 'L_DESCRIPTION'
  then
   for c2arec in c2a(vShipid, vBol, vCtr ) loop
    retvar := retvar || ', ' || c2arec.detaildesc;
   end loop;
   return( substr(nvl(substr(retvar,3),'&nbsp'),1,4000) );
 elsif action = 'L_WAREHOUSE'
  then
   for c1arec in c1a(vShipid, vBol, vCtr ) loop
     for c3arec in c3a(c1arec.movement_no,vShipid) loop
      retvar := retvar || htf.nl || c3arec.warehouse ; --|| htf.nl;
     end loop;
   retvar := retvar || htf.nl ;
   end loop;
   return (substr(replace(substr(retvar,length(htf.nl)+1 ),' ','_'),1,4000));
 elsif action = 'L_TYPE'
  then
   for c1arec in c1a(vShipid, vBol, vCtr ) loop
     for c4arec in c4a(c1arec.movement_no,vShipid) loop
      retvar := retvar || htf.nl || c4arec.ctype ; --|| htf.nl;
     end loop;
     
     if upper(vCtr) in ( 'EMPTIES', 'EMPTY') then
        retvar := retvar;
     else  
        retvar := retvar || htf.nl ;
     end if;
     
   end loop;
   return (substr(replace(substr(retvar,length(htf.nl)+1 ),' ','_'),1,4000));
 else
   return( null );
  
 end if;
end f_display_container;
/


GRANT EXECUTE ON STRANG.F_DISPLAY_CONTAINER TO WEBSYS;
