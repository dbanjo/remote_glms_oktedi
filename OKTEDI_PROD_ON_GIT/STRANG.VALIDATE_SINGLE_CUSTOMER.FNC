CREATE OR REPLACE function STRANG.validate_single_customer( vcust_id in varchar2, rfrom in varchar2, rto in varchar2, typ in varchar2 )
 return integer
as

 cursor c1( entryno number ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.customers c1, strang.receivals r, strang.detailrs dr
  where r.deliveryno = dr.deliveryno and
        nvl(r.cust_customer_id,'0') = c1.customer_id and
        c1.customer <> vcust_id and
        dr.entry_no = entryno;

 nmbf	integer;
 nmbt	integer;
 tot	integer;
 tot1	integer;
 tot2	integer;
 j	integer;
 k      number;
begin

  /*
  OLD 1 10
  new 1.0001 1.0010

  */
  begin nmbf := to_number(substr(rfrom,instr(rfrom,'.')+1)); exception when others then return( 0 ); end;
  begin nmbt := to_number(substr(rto,instr(rto,'.')+1)); exception when others then return( 0 ); end;

   if nmbf is null then nmbf := nmbt; end if;
   if nmbt is null then nmbt := nmbf; end if;
   if nmbt is null and nmbf is null then return( 0 ); end if;
  k:= to_number(rfrom);
  for j in nmbf..nmbt loop
  --dbms_output.put_line(j);
  tot := 0;
  open c1(k);
  fetch c1 into tot;
  close c1;
  if tot > 0 then return( 0 ); end if;


  k := k + 0.0000001;
 end loop;

return( 1 );

end validate_single_customer;
/


GRANT EXECUTE ON STRANG.VALIDATE_SINGLE_CUSTOMER TO WEBSYS;
