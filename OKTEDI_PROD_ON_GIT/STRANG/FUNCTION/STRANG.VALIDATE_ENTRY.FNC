CREATE OR REPLACE function STRANG.validate_entry( vcust_id in varchar2, rfrom in varchar2, rto in varchar2, typ in varchar2 )
 return integer
as

 cursor c1( entryno number ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.pos p, strang.customers c1, strang.receivals r, strang.detailrs dr
  where dr.deliveryno = p.deliveryno and
        r.deliveryno = dr.deliveryno and
        nvl(r.cust_customer_id,'0') = c1.customer_id and
        c1.customer = vcust_id and
        dr.entry_no = entryno and
        p.inventoryno is null;

 cursor c2( entryno number ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.pos p, strang.customers c1, strang.receivals r, strang.detailrs dr
  where dr.deliveryno = p.deliveryno and
        r.deliveryno = dr.deliveryno and
        nvl(r.cust_customer_id,'0') = c1.customer_id and
        c1.customer = vcust_id and
        dr.entry_no = entryno and
       (p.inventoryno is not null and not exists (select 'x' from strang.lov i where i.lov_name = 'INVENT' and i.code = p.inventoryno));

 cursor c2a( entryno number ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.pos p, strang.customers c1, strang.receivals r, strang.detailrs dr
  where dr.deliveryno = p.deliveryno and
        r.deliveryno = dr.deliveryno and
        nvl(r.cust_customer_id,'0') = c1.customer_id and
        c1.customer = vcust_id and
        dr.entry_no = entryno;

 cursor c2b( entryno number ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.pos p, strang.customers c1, strang.receivals r, strang.detailrs dr, strang.lov l2
  where dr.deliveryno = p.deliveryno and
        r.deliveryno = dr.deliveryno and
        nvl(r.cust_customer_id,'0') = c1.customer_id and
        c1.customer = vcust_id and
        dr.entry_no = entryno and
        l2.lov_name = 'INVENT' and
        p.inventoryno = l2.code;

 cursor c3( entryno number ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.pos p, strang.lov l, strang.customers c1, strang.receivals r, strang.detailrs dr
  where dr.deliveryno = p.deliveryno and
        p.inventoryno = l.code and
        l.lov_name = 'INVENT' and
        r.deliveryno = dr.deliveryno and
        nvl(r.cust_customer_id,'0') = c1.customer_id and
        c1.customer = vcust_id and
        dr.entry_no = entryno and
        l.cola is null;

 cursor c4( entryno number ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.pos p, strang.lov l, strang.customers c1, strang.receivals r, strang.detailrs dr
  where dr.deliveryno = p.deliveryno and
        p.inventoryno = l.code and
        r.deliveryno = dr.deliveryno and
        nvl(r.cust_customer_id,'0') = c1.customer_id and
        c1.customer = vcust_id and
        l.lov_name = 'INVENT' and
        dr.entry_no = entryno and
        (l.cola is not null and not exists (select 'x' from strang.lov t where t.lov_name = 'TARIFF' and t.code = l.cola));


 cursor c5( entryno number ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.pos p, strang.customers c1, strang.receivals r, strang.lov l, strang.lov l2, strang.detailrs dr
  where dr.deliveryno = p.deliveryno and
        l.lov_name = 'INVENT' and
        l.cola = l2.code and
        r.deliveryno = dr.deliveryno and
        nvl(r.cust_customer_id,'0') = c1.customer_id and
        c1.customer = vcust_id and
        p.inventoryno = l.code and
        dr.entry_no = entryno and
        l2.lov_name = 'TARIFF' and
        nvl(l2.cola,'|') <> nvl(p.unit_unitused,'|');

cursor c6( entryno number ) is
  select /*+ ALL_ROWS */ count('x') tot
 from strang.receivals r, strang.detailrs dr, strang.movements m, strang.ships_airway s, strang.customers c
 where
   dr.entry_no = entryno and
   s.ship_id = m.ship_id and
   r.deliveryno = dr.deliveryno and
   r.cust_customer_id = c.customer_id and
   c.customs_agent is not null and
   dr.movement_no = m.movement_no and
   nvl(dr.camov_seal,'|') = nvl(seal,'|') and
   not exists(select 'x' from strang.lov l
              where l.lov_name = 'UNRATTAB' and
                    l.code = r.curr and
                    nvl(to_date(websys.glbx.guess_date(l.cola),'DD-MON-YYYY'),s.estarrive) <= s.estarrive and
		    nvl(to_date(websys.glbx.guess_date(l.colb),'DD-MON-YYYY'),s.estarrive) >= s.estarrive);

 cursor c7( entryno number ) is
  select /*+ ALL_ROWS */ count('x') tot
  from strang.detailrs dr
  where dr.entry_no = entryno and
        dr.line_no is null;


 nmbf	integer;
 nmbt	integer;
 tot	integer;
 tot1	integer;
 tot2	integer;
 j	integer;
 k      number;
begin

 if typ = 'RANGE'
  then
  /*
  OLD 1 10
  new 1.0001 1.0010

  */
  begin nmbf := to_number(substr(rfrom,instr(rfrom,'.')+1)); exception when others then return( 0 ); end;
  begin nmbt := to_number(substr(rto,instr(rto,'.')+1)); exception when others then return( 0 ); end;

  /*
   begin nmbf := to_number(rfrom); exception when others then return( 0 ); end;
   begin nmbt := to_number(rto); exception when others then return( 0 ); end;
  */

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
--  if tot > 0 then return( 0 ); end if; -- removed by DB 17/7/2023
  if tot > 0 then return( -1 ); end if; -- RANGE: Check to ensure that inventory is not null
  tot := 0;
  open c2a(k);
  fetch c2a into tot1;
  close c2a;
  open c2b(k);
  fetch c2b into tot2;
  close c2b;
  tot := tot1 - tot2;
  if tot > 0 then return( -2 ); end if;  -- RANGE: Check to ensure that inventoryno is in lookup

  tot := 0;
  open c3(k);
  fetch c3 into tot;
  close c3;
  if tot > 0 then return( -3 ); end if; -- RANGE: Check to ensure inventory code has tariff value

  tot := 0;
  open c4(k);
  fetch c4 into tot;
  close c4;
  if tot > 0 then return( -4 ); end if; -- RANGE: Check to ensure tariff value is in lookup

  tot := 0;
  open c5(k);
  fetch c5 into tot;
  close c5;
  if tot > 0 then return( -5 ); end if; -- RANGE: Check that po.unit_unitused is valid for the tariff

  tot := 0;
  open c6(k);
  fetch c6 into tot;
  close c6;
  if tot > 0 then return( -6 ); end if; -- RANGE: Check that there is valid exchange rate for the Est. Date of Arrival

  tot := 0;
  open c7(k);
  fetch c7 into tot;
  close c7;
  if tot > 0 then return( -7 ); end if; -- RANGE: Check that line no exists


  k := k + 0.0000001;
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
    if tot > 0 then return( -1 ); end if; -- MULTIPLE: Check to ensure that inventory is not null

    tot := 0;
    open c2(j);
    fetch c2 into tot;
    close c2;
    if tot > 0 then return( -2 ); end if; -- MULTIPLE: Check to ensure that inventoryno is in lookup

    tot := 0;
    open c3(j);
    fetch c3 into tot;
    close c3;
    if tot > 0 then return( -3 ); end if;  -- MULTIPLE: Check to ensure inventory code has tariff value

    tot := 0;
    open c4(j);
    fetch c4 into tot;
    close c4;
    if tot > 0 then return( -4 ); end if; -- MULTIPLE: Check to ensure tariff value is in lookup

    tot := 0;
    open c5(j);
    fetch c5 into tot;
    close c5;
    if tot > 0 then return( -5 ); end if; -- MULTIPLE: Check that po.unit_unitused is valid for the tariff

    tot := 0;
    open c6(j);
    fetch c6 into tot;
    close c6;
    if tot > 0 then return( -6 ); end if; -- MULTIPLE: Check that there is valid exchange rate for the Est. Date of Arrival

    tot := 0;
    open c7(j);
    fetch c7 into tot;
    close c7;
    if tot > 0 then return( -7 ); end if; -- MULTIPLE: Check that line no exists


   end if;

 end loop;

 end if;
return( 1 );

end validate_entry;
/


GRANT EXECUTE ON STRANG.VALIDATE_ENTRY TO WEBSYS;
