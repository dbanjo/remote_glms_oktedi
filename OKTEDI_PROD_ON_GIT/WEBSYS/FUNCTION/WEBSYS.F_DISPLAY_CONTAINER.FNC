CREATE OR REPLACE function WEBSYS.f_display_container( vShipid varchar2, vBol varchar2, vCtr varchar2, action in varchar2 )
 return varchar2
as

 cursor c1(vShipid varchar2, vBol varchar2, vCtr varchar2) is
  select m.movement_no,min(dr.line_no) mn,max(dr.line_no) mx
  from strang.detailrs dr, strang.movements m
  where dr.movement_no = m.movement_no and
        nvl(camov_seal,'x') = nvl(seal,'x') and
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

 c1rec  c1%ROWTYPE;
 retvar	varchar2(32767);
 lrec   varchar2(100);


begin
 if action = 'NUMBERS'
  then
   for c1rec in c1(vShipid, vBol, vCtr ) loop
      retvar := retvar || htf.nl || c1rec.movement_no || '(' || c1rec.mn || '-' || c1rec.mx || ')';
   end loop;
   return(substr(retvar,length(htf.nl)+1 ));
 elsif action = 'DESCRIPTION'
  then
   for c2rec in c2(vShipid, vBol, vCtr ) loop
    retvar := retvar || ', ' || c2rec.detaildesc;
   end loop;
   return( nvl(substr(retvar,3),'&nbsp') );
 end if;
end f_display_container;
/
