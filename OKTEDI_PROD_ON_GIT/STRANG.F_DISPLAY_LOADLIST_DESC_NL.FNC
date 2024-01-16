CREATE OR REPLACE function STRANG.f_display_loadlist_desc_nl( vShipid integer, vCtr varchar2, vSeal varchar2, vCtrtype varchar2 )
 return varchar2
as


 cursor c1(vShipid varchar2, vCtr varchar2, vSeal varchar2) is
  select distinct detaildesc
  from strang.detailrs dr, strang.movements m
  where dr.movement_no = m.movement_no and
        m.local_ship_id = vShipid and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        m.movement_no = vCtr and
        nvl(m.seal,'|') = nvl(vSeal,'|');


 cursor c2(vCtrtype varchar2) is
 select distinct l.colc ctype
 from strang.lov l
 where l.lov_name = 'UNCTNTAB' and
 l.code = vCtrtype;

 c1rec  c1%ROWTYPE;
 c2rec  c2%ROWTYPE;
 retvar	varchar2(32767);


begin
 open c1(vShipid, vCtr, vSeal );
 fetch c1 into c1rec;
 if c1%NOTFOUND
 then
  close c1;
  return('EMPTY');
 end if;
 close c1;
 for c1rec in c1(vShipid, vCtr, vSeal ) loop
  retvar := retvar || ', ' || c1rec.detaildesc;
 end loop;
 if length(retvar) < 250 then
   return( 'STC '||substr(nvl(substr(retvar,3),'&nbsp'),1,4000) );
  else
  if vCtrType is not null then
   open c2(vCtrtype );
   fetch c2 into c2rec;
   if c2%NOTFOUND
    then
    close c2;
    return('STC ASSORTED GENERAL MINING SUPPLIES');
   end if;
    retvar := c2rec.ctype;
    close c2;
    return(retvar);
   end if;
  end if;

end f_display_loadlist_desc_nl;
/


GRANT EXECUTE ON STRANG.F_DISPLAY_LOADLIST_DESC_NL TO WEBSYS;
