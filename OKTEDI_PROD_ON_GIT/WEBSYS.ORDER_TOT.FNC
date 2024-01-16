CREATE OR REPLACE function WEBSYS.order_tot(purchid in integer, calc_type in varchar2 ) return varchar2
as
 cursor c1(purchid integer) is
  select sum((round(price*((100-decode(is_discounted,'T',nvl(b2c_lab_discount,0),'Y',nvl(b2c_lab_discount,0),0))/100),2)*qty)) tot
  from shopping_basket
  where poid = purchid;
 cursor c2(purchid integer) is select lab_charge_perc from purchase_order po, photographer p where p.pid = po.pid and po.poid = purchid;
 tot	number;
 perc   number;
 grnd   number;
begin
 if calc_type = 'ORDER_TOTAL'
  then
   return( to_char(glbx.grand_total_payment(purchid),LNG.MONEY_FORMAT ));
 elsif calc_type = 'COMMISSION'
  then
   open c1(purchid);
   fetch c1 into tot;
   close c1;
   open c2(purchid);
   fetch c2 into perc;
   close c2;
   grnd := glbx.grand_total_payment(purchid);
   return( to_char(round((grnd * (1 - (nvl(perc,0)/100))),2) - tot,LNG.MONEY_FORMAT));
 elsif calc_type = 'LAB_CHARGES'
  then
   open c1(purchid);
   fetch c1 into tot;
   close c1;
   return( to_char(tot,LNG.MONEY_FORMAT));
 end if;
 return( NULL );
exception
 when others then return( NULL );
end;

/
