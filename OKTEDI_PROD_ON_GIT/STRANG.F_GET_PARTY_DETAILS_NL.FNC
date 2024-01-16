CREATE OR REPLACE FUNCTION STRANG.f_get_party_details_nl (fld in varchar2 ,vCustid in number)
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


 c1rec  c1%ROWTYPE;
 c2rec  c2%ROWTYPE;
 retvar	varchar2(300);


begin
 if vCustid <> 1 then
  if fld = 'SHIPPER' then
    open c1(vCustid);
     fetch c1 into c1rec;
    close c1;
    if c1rec.shipper_id is not null then
     open c2(c1rec.shipper_id);
     fetch c2 into c2rec;
     close c2;
     retvar:= to_char(c2rec.customer||htf.nl||c2rec.street||', '||c2rec.suburb||', '||c2rec.state||' '||c2rec.postcode||' '||c2rec.country);
    end if;
  elsif
   fld = 'CONSIGNEE' then
   open c1(vCustid);
   fetch c1 into c1rec;
   close c1;
   if c1rec.consigned_to_id is not null then
    open c2(c1rec.consigned_to_id);
    fetch c2 into c2rec;
    close c2;
    retvar:= to_char(c2rec.customer||htf.nl||c2rec.street||', '||c2rec.suburb||', '||c2rec.state||' '||c2rec.postcode||' '||c2rec.country);
   end if;
 end if;
else
  if fld = 'SHIPPER' then
     retvar:= 'OTML - Port Moresby';
  elsif
   fld = 'CONSIGNEE' then
    retvar:= 'OTML - Tabubil';
  end if;
end if;
return(nvl(retvar,' '));
end f_get_party_details_nl;
/


GRANT EXECUTE ON STRANG.F_GET_PARTY_DETAILS_NL TO WEBSYS;
