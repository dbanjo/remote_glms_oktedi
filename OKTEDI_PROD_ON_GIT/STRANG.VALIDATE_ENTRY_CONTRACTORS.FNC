CREATE OR REPLACE function STRANG.validate_entry_contractors( rfrom in varchar2, rto in varchar2, typ in varchar2 )
 return integer
as

 cursor c1( entryno integer ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.pos p, strang.customers c1, strang.receivals r, strang.detailrs dr
  where dr.deliveryno = p.deliveryno and
        r.deliveryno = dr.deliveryno and
        nvl(r.cust_customer_id,'0') = c1.customer_id and
        c1.customer_type = 'CUSTOMER' and
        dr.entry_no = entryno and
        p.inventoryno is null;

 cursor c2( entryno integer ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.pos p, strang.customers c1, strang.receivals r, strang.detailrs dr
  where dr.deliveryno = p.deliveryno and
        r.deliveryno = dr.deliveryno and
        nvl(r.cust_customer_id,'0') = c1.customer_id and
        c1.customer_type = 'CUSTOMER' and
        dr.entry_no = entryno and
        p.inventoryno not in (select l.code from strang.lov l where l.lov_name = 'INVENT');

 cursor c2a( entryno integer ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.pos p, strang.customers c1, strang.receivals r, strang.detailrs dr
  where dr.deliveryno = p.deliveryno and
        r.deliveryno = dr.deliveryno and
        nvl(r.cust_customer_id,'0') = c1.customer_id and
        c1.customer_type = 'CUSTOMER' and
        dr.entry_no = entryno;

 cursor c2b( entryno integer ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.pos p, strang.customers c1, strang.receivals r, strang.detailrs dr, strang.lov l2
  where dr.deliveryno = p.deliveryno and
        r.deliveryno = dr.deliveryno and
        nvl(r.cust_customer_id,'0') = c1.customer_id and
        c1.customer_type = 'CUSTOMER' and
        dr.entry_no = entryno and
        l2.lov_name = 'INVENT' and
        p.inventoryno = l2.code;

 cursor c3( entryno integer ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.pos p, strang.lov l, strang.customers c1, strang.receivals r, strang.detailrs dr
  where dr.deliveryno = p.deliveryno and
        p.inventoryno = l.code and
        l.lov_name = 'INVENT' and
        r.deliveryno = dr.deliveryno and
        nvl(r.cust_customer_id,'0') = c1.customer_id and
        c1.customer_type = 'CUSTOMER' and
        dr.entry_no = entryno and
        l.cola is null;

 cursor c4( entryno integer ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.pos p, strang.lov l, strang.customers c1, strang.receivals r, strang.detailrs dr
  where dr.deliveryno = p.deliveryno and
        p.inventoryno = l.code and
        r.deliveryno = dr.deliveryno and
        nvl(r.cust_customer_id,'0') = c1.customer_id and
        c1.customer_type = 'CUSTOMER' and
        l.lov_name = 'INVENT' and
        dr.entry_no = entryno and
        l.cola not in (select l2.code from strang.lov l2 where l2.lov_name = 'TARIFF');


 cursor c5( entryno integer ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.pos p, strang.customers c1, strang.receivals r, strang.lov l, strang.lov l2, strang.detailrs dr
  where dr.deliveryno = p.deliveryno and
        l.lov_name = 'INVENT' and
        l.cola = l2.code and
        r.deliveryno = dr.deliveryno and
        nvl(r.cust_customer_id,'0') = c1.customer_id and
        c1.customer_type = 'CUSTOMER' and
        p.inventoryno = l.code and
        dr.entry_no = entryno and
        l2.lov_name = 'TARIFF' and
        nvl(l2.cola,'|') <> nvl(p.unit_unitused,'|');

 nmbf	integer;
 nmbt	integer;
 tot	integer;
 tot1	integer;
 tot2	integer;
 j	integer;

begin

 if typ = 'RANGE'
  then
   begin nmbf := to_number(rfrom); exception when others then return( 0 ); end;
   begin nmbt := to_number(rto); exception when others then return( 0 ); end;
   if nmbf is null then nmbf := nmbt; end if;
   if nmbt is null then nmbt := nmbf; end if;
   if nmbt is null and nmbf is null then return( 0 ); end if;
  for j in nmbf..nmbt loop
  --dbms_output.put_line(j);
  tot := 0;
  open c1(j);
  fetch c1 into tot;
  close c1;
  if tot > 0 then return( 0 ); end if;

  tot := 0;
  open c2a(j);
  fetch c2a into tot1;
  close c2a;
  open c2b(j);
  fetch c2b into tot2;
  close c2b;
  tot := tot1 - tot2;
  if tot >= 1 then return( 0 ); end if;

  tot := 0;
  open c3(j);
  fetch c3 into tot;
  close c3;
  if tot > 0 then return( 0 ); end if;

  tot := 0;
  open c4(j);
  fetch c4 into tot;
  close c4;
  if tot > 0 then return( 0 ); end if;

  tot := 0;
  open c5(j);
  fetch c5 into tot;
  close c5;
  if tot > 0 then return( 0 ); end if;

 end loop;
 elsif typ = 'MULTIPLE'
  then
   for crec in (select parameter_value from websys.report_multi_parameters ) loop
   begin j := to_number(crec.parameter_value); exception when others then j := NULL; end;

   if j is not null
    then
    tot := 0;
    open c1(j);
    fetch c1 into tot;
    close c1;
    if tot > 0 then return( 0 ); end if;

    tot := 0;
    open c2(j);
    fetch c2 into tot;
    close c2;
    if tot > 0 then return( 0 ); end if;

    tot := 0;
    open c3(j);
    fetch c3 into tot;
    close c3;
    if tot > 0 then return( 0 ); end if;

    tot := 0;
    open c4(j);
    fetch c4 into tot;
    close c4;
    if tot > 0 then return( 0 ); end if;

    tot := 0;
    open c5(j);
    fetch c5 into tot;
    close c5;
    if tot > 0 then return( 0 ); end if;
   end if;
 end loop;

 end if;
return( 1 );

end validate_entry_contractors;
/


GRANT EXECUTE ON STRANG.VALIDATE_ENTRY_CONTRACTORS TO WEBSYS;
