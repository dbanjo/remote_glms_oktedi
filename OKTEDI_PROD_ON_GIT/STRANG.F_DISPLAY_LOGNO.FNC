CREATE OR REPLACE function STRANG.f_display_logno( iDeliveryno Integer )
 return varchar2
as

 cursor c1(iDeliveryno Integer) is
  select distinct dr.logno
  from strang.detailrs dr
  where dr.deliveryno = iDeliveryno
  order by dr.logno;


 c1rec  c1%ROWTYPE;
 retvar	varchar2(32767);


begin
   for c1rec in c1( iDeliveryno ) loop
    retvar := retvar || htf.nl || c1rec.logno;
   end loop;
   return( substr(retvar,length(htf.nl)+1) );
end f_display_logno;
/


GRANT EXECUTE ON STRANG.F_DISPLAY_LOGNO TO WEBSYS;
