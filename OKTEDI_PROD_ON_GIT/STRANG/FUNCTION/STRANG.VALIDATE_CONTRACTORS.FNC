CREATE OR REPLACE function STRANG.validate_contractors( rfrom in varchar2, rto in varchar2 )
 return integer
is
tot integer;
begin
 select max(r.cust_customer_id) - min(r.cust_customer_id) into tot
  from strang.receivals r, strang.detailrs dr
  where r.deliveryno = dr.deliveryno
  and dr.entry_no >= to_number(rfrom)
  and dr.entry_no <= to_number(rto);

if tot >= 1 then return( 0 ); end if;
return( 1 );

end validate_contractors;
/


GRANT EXECUTE ON STRANG.VALIDATE_CONTRACTORS TO WEBSYS;
