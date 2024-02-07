CREATE OR REPLACE FUNCTION STRANG.f_get_party_details_nl_bol (fld in varchar2 ,vLocalBol in varchar2, vLocalShipID in number)
   RETURN varchar2
as

 cursor c1(vCust number) is
  select *
  from strang.customers
  where customer_id = vCust;

 cursor c2(vParty number) is
  select *
  from strang.customers
  where customer_id = vParty;

 cursor c3(vbol varchar2,vshipid number) is
  select distinct r.cust_customer_id custid
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno
  and m.movement_no = dr.movement_no
  and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
  and m.local_ship_id = vshipid
  and m.local_bol = vbol
  order by 1;

 c1rec  c1%ROWTYPE;
 c2rec  c2%ROWTYPE;
 c3rec  c3%ROWTYPE;
 retvar	varchar2(300);
 custid number;

begin
retvar := null;
if fld = 'CONSIGNEE' then
   for c3rec in c3(vLocalBol,vLocalShipID) loop
    if c3rec.custid = 1
    then
     retvar := 'OTML - Tabubil'||htf.nl;
    else
     open c1(c3rec.custid);
      fetch c1 into c1rec;
     close c1;
     if c1rec.consigned_to_id is not null then
      open c2(c1rec.consigned_to_id);
       fetch c2 into c2rec;
      close c2;
     else
      open c2(c3rec.custid);
       fetch c2 into c2rec;
      close c2;
     end if;
     if retvar is null then
      retvar:= to_char(c2rec.customer||htf.nl);
     else
      retvar := retvar||htf.nl||to_char(c2rec.customer||htf.nl);
     end if;
    end if;
   end loop;
elsif fld = 'SHIPPER' then
     retvar:= 'OTML - Port Moresby'||htf.nl;
end if;
return(nvl(retvar,' '));
end f_get_party_details_nl_bol;
/


GRANT EXECUTE ON STRANG.F_GET_PARTY_DETAILS_NL_BOL TO WEBSYS;
