CREATE OR REPLACE function STRANG.f_display_matdesc( vShipid varchar2, vCtr varchar2, vSeal )
 return varchar2
as

 cursor c1(vShipid varchar2, vCtr varchar2) is
  select sum(qty) ttl, l.description packs
  from strang.detailrs dr, strang.movements m, lov l
  where dr.movement_no = m.movement_no and
        nvl(camov_seal,'x') = nvl(seal,'x') and
        m.convoy_id = vShipid and
        m.movement_no = vCtr and
        nvl(m.seal,'|') = nvl(vSeal,'|') and
        nvl(m.container_type,'BREAK BULK') = nvl(vCtr,'BREAK BULK') and
        l.lov_name = 'PACKTYPES' and
        l.code = dr.pktpe_packtype
        group by l.description;


 cursor c2(vShipid varchar2, vCtr varchar2) is
  select distinct detaildesc
  from strang.detailrs dr, strang.movements m
  where dr.movement_no = m.movement_no and
        nvl(camov_seal,'x') = nvl(seal,'x') and
        m.ship_id = vShipid and
        nvl(m.container_type,'BREAK BULK') = nvl(vCtr,'BREAK BULK');


 c1rec  c1%ROWTYPE;
 c2rec  c2%ROWTYPE;
 retvar	varchar2(32767);
 xr	number;
 pl	number;

begin
/*
   xr := 1;
   p1 := 0;
   retvar := 'STC ';
   for c1rec in c1(vShipid, vCtr ) loop
    pl := length(c1rec.packs);
    if xr = 1 then
      if substr(c1rec.packs,pl-4,4) = ' STC' then
        retvar := retvar || ' ' || c1rec.ttl ||' '||substr(c1rec.packs,1,pl-4);
      else
        retvar := retvar || ' ' || c1rec.ttl ||' '||c1rec.packs;
      end if;
    else
      if substr(c1rec.packs,pl-4,4) = ' STC' then
        retvar := retvar || ', ' || c1rec.ttl ||' '||substr(c1rec.packs,1,pl-4);
      else
        retvar := retvar || ', ' || c1rec.ttl ||' '||c1rec.packs;
      end if;
    end if;
    xr := 2;
   end loop;
*/
   xr := 1;
   pl := 0;
   for c2rec in c2(vShipid, vCtr ) loop
    if xr = 1 then
      pl := length(c2rec.detaildesc);
      retvar := retvar || ' ' || c2rec.detaildesc;
    else
      pl := pl + length(c2rec.detaildesc);
      if pl < 196 then
        retvar := retvar || ', ' || c2rec.detaildesc;
      else
        retvar := retvar||' ETC.';
        exit;
      end if;
    end if;
    xr := 2;
   end loop;
      return(retvar);
--   return(substr(nvl(retvar,'-'),1,4000) );
end f_display_matdesc;
/


GRANT EXECUTE ON STRANG.F_DISPLAY_MATDESC TO WEBSYS;
