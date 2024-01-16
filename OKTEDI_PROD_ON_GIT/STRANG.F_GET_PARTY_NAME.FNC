CREATE OR REPLACE FUNCTION STRANG.f_get_party_name (party_id in number)
   RETURN varchar2
as

 cursor c1(party_id number) is
  select customer
  from strang.customers
  where customer_id = party_id;

 c1rec  c1%ROWTYPE;
 retvar	varchar2(50);


begin
 open c1(party_id);
 fetch c1 into c1rec;
 close c1;
 if c1rec.customer is null
 then
  retvar := ' ';
 else
  retvar:= to_char(c1rec.customer);
 end if;
 return(retvar);
end f_get_party_name;
/


GRANT EXECUTE ON STRANG.F_GET_PARTY_NAME TO STX1;

GRANT EXECUTE ON STRANG.F_GET_PARTY_NAME TO WEBSYS;
