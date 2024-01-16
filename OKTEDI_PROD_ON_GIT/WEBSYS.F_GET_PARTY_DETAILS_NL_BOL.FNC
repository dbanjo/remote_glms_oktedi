CREATE OR REPLACE FUNCTION WEBSYS.f_get_party_details_nl_BOL (fld in varchar2 ,vLBOL in varchar2, vShpid in number)
   RETURN varchar2
as
-- Get record from customers table
 cursor c1(vCust number) is
  select *
  from strang.customers
  where customer_id = vCust;

-- Get record from customers table for party
 cursor c2(vParty number) is
  select *
  from strang.customers
  where customer_id = vParty;

--
 cursor c3(vShipid number, vLocalBol varchar2) is
  select distinct c.customer_id, c.customer
  from strang.customers c, strang.receivals r, strang.detailrs dr, strang.movements m
  where c.customer_id = r.cust_customer_id
  and r.deliveryno = dr.deliveryno
  and dr.movement_no = m.movement_no
  and nvl(dr.camov_seal,'|') = nvl(m.seal,'|')
  and m.local_ship_id = vShipid
  and m.local_bol = vLocalBol
  order by 1;

 cursor c3a(vShipid number, vLocalBol varchar2) is
  select distinct c1.customer_id c_id, c.customer_id, c.customer
  from strang.customers c,strang.customers c1, strang.receivals r, strang.detailrs dr, strang.movements m
  where c.customer_id = r.supplier_customer_id
  and c1.customer_id = r.cust_customer_id
  and r.deliveryno = dr.deliveryno
  and dr.movement_no = m.movement_no
  and nvl(dr.camov_seal,'|') = nvl(m.seal,'|')
  and m.local_ship_id = vShipid
  and m.local_bol = vLocalBol
  order by 1;

 cursor c4(vShipid number, vLocalBol varchar2) is
  select count(distinct c.customer_id) tot
  from strang.customers c, strang.receivals r, strang.detailrs dr, strang.movements m
  where c.customer_id = r.cust_customer_id
  and r.deliveryno = dr.deliveryno
  and dr.movement_no = m.movement_no
  and nvl(dr.camov_seal,'|') = nvl(m.seal,'|')
  and m.local_ship_id = vShipid
  and m.local_bol = vLocalBol;

 cursor c4a(vShipid number, vLocalBol varchar2) is
  select count(distinct c.customer_id) tot
  from strang.customers c, strang.receivals r, strang.detailrs dr, strang.movements m
  where c.customer_id = r.supplier_customer_id
  and r.deliveryno = dr.deliveryno
  and dr.movement_no = m.movement_no
  and nvl(dr.camov_seal,'|') = nvl(m.seal,'|')
  and m.local_ship_id = vShipid
  and m.local_bol = vLocalBol;


 c1rec    c1%ROWTYPE;
 c2rec    c2%ROWTYPE;
 c3rec    c3%ROWTYPE;
 c3arec   c3a%ROWTYPE;
 c4rec    c4%ROWTYPE;
 c4arec   c4a%ROWTYPE;
 retvar	  varchar2(1000);
 isOTML   boolean;
 ctr	  integer;
 supctr   integer;

begin
  isOTML := FALSE;
  ctr := 0;
  supctr := 0;
  open c3(vShpid,vLBol);  -- customers
   fetch c3 into c3rec;
  close c3;
  open c4(vShpid,vLBol);  -- number of customers
   fetch c4 into c4rec;
  close c4;
  ctr := c4rec.tot;
  if ctr = 1 then
    if c3rec.customer_id = 1 then
      if fld = 'CONSIGNEE' then
       retvar:= 'OTML - Tabubil';
      end if;
    else
      if fld = 'SHIPPER' then
       open c1(c3rec.customer_id);
        fetch c1 into c1rec;
       close c1;
       if c1rec.shipper_id is not null then
        open c2(c1rec.shipper_id);
         fetch c2 into c2rec;
        close c2;
        retvar:= to_char(c2rec.customer||htf.nl||c2rec.street||', '||c2rec.suburb||', '||c2rec.state||' '||c2rec.postcode||' '||c2rec.country);
       else
        retvar:= to_char(c1rec.customer||htf.nl||c1rec.street||', '||c1rec.suburb||', '||c1rec.state||' '||c1rec.postcode||' '||c1rec.country);
       end if;
      elsif
       fld = 'CONSIGNEE' then
       open c1(c3rec.customer_id);
        fetch c1 into c1rec;
       close c1;
       if c1rec.consigned_to_id is not null then
        open c2(c1rec.consigned_to_id);
         fetch c2 into c2rec;
        close c2;
        retvar:= to_char(c2rec.customer||htf.nl||c2rec.street||', '||c2rec.suburb||', '||c2rec.state||' '||c2rec.postcode||' '||c2rec.country);
       else
        retvar:= to_char(c1rec.customer||htf.nl||c1rec.street||', '||c1rec.suburb||', '||c1rec.state||' '||c1rec.postcode||' '||c1rec.country);
       end if;
      end if;
      return(nvl(retvar,' '));
   end if;
  end if;
  -- when customer counter ctr > 1
  if fld = 'SHIPPER' then
   for c3rec in c3(vShpid, vLBOL) loop
     if c3rec.customer_id = 1 then
       retvar:= 'OTML - Port Moresby';
       return(nvl(retvar,' '));
     else
      open c1(c3rec.customer_id);
       fetch c1 into c1rec;
      close c1;
      if c1rec.shipper_id is not null then
        open c2(c1rec.shipper_id);
         fetch c2 into c2rec;
        close c2;
        retvar:= retvar||'/ '||to_char(c2rec.customer||htf.nl||c2rec.street||', '||c2rec.suburb||', '||c2rec.state||' '||c2rec.postcode||' '||c2rec.country);
      else
        retvar:= retvar||'/ '||to_char(c1rec.customer||htf.nl||c1rec.street||', '||c1rec.suburb||', '||c1rec.state||' '||c1rec.postcode||' '||c1rec.country);
      end if;
     end if;
   end loop;
  elsif
   fld = 'CONSIGNEE' then
   for c3arec in c3a(vShpid, vLBOL) loop
     if c3arec.c_id = 1 then
       retvar:= retvar ||'/ '|| 'OTML - Tabubil';
     else
      open c1(c3arec.customer_id);
       fetch c1 into c1rec;
      close c1;
        retvar:= retvar||'/ '||to_char(c1rec.customer);
      end if;
   end loop;
 end if;
if fld = 'SHIPPER' then
  retvar := 'OTML - Port Moresby'
end if;

return(nvl(retvar,' '));
end f_get_party_details_nl_bol;
/
