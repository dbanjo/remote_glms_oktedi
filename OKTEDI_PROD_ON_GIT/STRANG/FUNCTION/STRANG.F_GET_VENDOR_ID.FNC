CREATE OR REPLACE FUNCTION STRANG.f_get_vendor_id (sup_id in number)
   RETURN varchar2
as

 cursor c1(sup_id number) is
  select sap_vendor_id
  from strang.customers
  where customer_id = sup_id;

 c1rec  c1%ROWTYPE;
 retvar	varchar2(10);


begin
 open c1(sup_id);
 fetch c1 into c1rec;
 close c1;
 if c1rec.sap_vendor_id is null
 then
  retvar := ' ';
 else
  retvar:= to_char(c1rec.sap_vendor_id);
 end if;
 return(retvar);
end f_get_vendor_id;
/


GRANT EXECUTE ON STRANG.F_GET_VENDOR_ID TO WEBSYS;
