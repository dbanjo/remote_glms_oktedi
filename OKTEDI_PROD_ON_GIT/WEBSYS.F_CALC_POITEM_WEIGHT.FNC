CREATE OR REPLACE function WEBSYS.f_calc_poitem_weight ( p_mov in varchar2, p_del in number, p_itemno in varchar2, p_recno in number )
 return number
as
 ----
-- cursor c1(vmov varchar2, vdel number, vitemno number, vpo varchar2, vrecno number) is  
 cursor c1(vmov varchar2, vdel number, vitemno number,  vrecno number) is 
 select round(tmp.partweight*(tmp.amount/case when tmp.tot_amt = 0 then 1 else tmp.tot_amt end),4) weight
 from (select dr.partweight, sum(p.amount) over (partition by p.deliveryno) tot_amt, p.amount, p.recno
         from strang.pos p, strang.detailrs dr
        where dr.deliveryno =vdel and
              dr.movement_no = vmov and
              p.deliveryno = dr.deliveryno and 
              dr.itemno = vitemno) tmp
 where tmp.recno = vrecno;
   
 c1rec  c1%ROWTYPE;
 tmp	varchar2(1000);
 
 
begin
 tmp:= '';
 open c1( p_mov, p_del, p_itemno, p_recno);
 fetch c1 into c1rec;
 close c1;
 
  return ( c1rec.weight );
end f_calc_poitem_weight;
/
