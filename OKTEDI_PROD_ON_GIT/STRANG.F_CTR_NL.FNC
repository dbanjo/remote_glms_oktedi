CREATE OR REPLACE function STRANG.f_ctr_nl( shp_id in integer, ctr in varchar2, typ in varchar2 )
 return varchar2
as
 cursor c1 is
  select p.po, min(recno)
  from movements m, detailrs dr, pos p
  where m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = p.deliveryno and
        m.local_ship_id = shp_id and
        m.container_type = ctr
  group by p.po
  order by 2;

  cursor c2 is
  select p.inventoryno, min(recno)
  from movements m, detailrs dr, pos p
  where m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = p.deliveryno and
        m.local_ship_id = shp_id and
        m.container_type = ctr
  group by p.inventoryno
  order by 2;

 c1rec  c1%ROWTYPE;
 c2rec  c2%ROWTYPE;
 retvar	varchar2(4000);

begin
 retvar := NULL;
 if typ = 'PO'
 then
  for c1rec in c1 loop
   retvar := retvar || htf.nl || c1rec.po;
  end loop;
 else
  for c2rec in c2 loop
   retvar := retvar || htf.nl || c2rec.inventoryno;
  end loop;
 end if;
 return( substr( retvar,length(htf.nl)+1) );
end f_ctr_nl;
/


GRANT EXECUTE ON STRANG.F_CTR_NL TO WEBSYS;
