CREATE OR REPLACE function WEBSYS.f_get_item_qty_diff( mv in varchar2, sl in varchar2 )
 return varchar2
as
 cursor c1 (mv varchar2, sl varchar2 ) is
 select tmp1.deliveryno, tmp1.itemno, tmp1.PART_WEIGHT_1, tmp2.PART_WEIGHT_2
  from 
  (select distinct dr.deliveryno, dr.itemno
       , sum(dr.partweight) over (partition by dr.deliveryno, dr.itemno) part_weight_1
  from strang.detailrs dr
  where dr.movement_no = mv and 
        nvl(dr.camov_seal,'|') = nvl(sl,'|')) tmp1
  ,( select distinct di.deliveryno, di.item_no
       , sum(di.weight) over (partition by di.deliveryno, di.item_no) part_weight_2
       , row_number() over (partition by di.deliveryno, di.item_no order by order_by) rnk
  from strang.detailrs_item di
  where di.movement_no = mv and 
        nvl(di.seal,'|') = nvl(sl,'|')) tmp2  
 where tmp1.deliveryno = tmp2.deliveryno
 and   tmp1.itemno = tmp2.item_no
 and    nvl(tmp1.part_weight_1,0) <> nvl(tmp2.part_weight_2,0)
 and  tmp2.rnk = 1
 order by tmp1.deliveryno, tmp1.deliveryno;
        

 c1rec  c1%ROWTYPE;
 retvar	varchar2(4000);

begin
  retvar := NULL;
  for c1rec in c1 (mv, sl) loop
   if c1%rowcount = 1 
    then retvar := 'Difference between Weight Declaration and Container Manifest, check the following:'||htf.nl;
   end if;
   retvar := retvar || htf.nl || c1rec.deliveryno ||'-'||c1rec.itemno;
  end loop;
  return(retvar);
end f_get_item_qty_diff;
/
