CREATE OR REPLACE function STRANG.f_part_shipments( mvt in varchar2, sl in varchar2, delno in number, itm in number )
 return varchar2
as
 cursor c2(mvt varchar2, sl varchar2, delno varchar2, itm varchar2) is
  select dr.itemno, dr.movement_no, dr.camov_seal, dr.deliveryno
  from strang.detailrs dr
  where dr.deliveryno = delno
   and dr.ITEMNO <> itm
   and not exists (select 'x'
                    from  strang.detailrs dr2
                    where dr.deliveryno = dr2.deliveryno
                     and  dr.itemno = dr2.itemno
                     and  dr2.movement_no = mvt
                     and  nvl(dr2.camov_seal,'|')  = nvl(sl,'|'))
  order by dr.itemno;


 c2rec  c2%ROWTYPE;
 tmp	varchar2(3000);


begin
 tmp:= '';
for c2rec in c2(mvt,sl, delno, itm) loop
  if c2%rowcount = 1 then
  -- tmp := tmp||'Y';
     tmp :=  tmp ||'Item '|| c2rec.itemno||' '||case when c2rec.movement_no is null then 'Unassigned' else c2rec.movement_no||' ('||nvl(c2rec.camov_seal,'')||')' end;
  else
     if length(tmp) > 1000 then
        tmp := tmp||' and more....' ;
        exit;
     else
        tmp :=  tmp||htf.nl||'Item '|| c2rec.itemno||' '||case when c2rec.movement_no is null then 'Unassigned' else c2rec.movement_no||' ('||nvl(c2rec.camov_seal,'')||')' end;
     end if;
  --- tmp := tmp||'X';
  end if;
end loop;
  return ( tmp );
end f_part_shipments;
/


GRANT EXECUTE ON STRANG.F_PART_SHIPMENTS TO WEBSYS;
