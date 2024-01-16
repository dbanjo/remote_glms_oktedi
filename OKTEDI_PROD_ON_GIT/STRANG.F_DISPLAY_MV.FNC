CREATE OR REPLACE function STRANG.f_display_mv( iInvoiceNo Varchar2 )
 return varchar2
as

 cursor c1(iInvoiceNo Varchar2) is
  select m.movement_no
  from strang.movements m
  where m.invoiceno = iInvoiceNo and
        m.movement_type <> 'AIRWAY'
  order by m.movement_no;


 c1rec  c1%ROWTYPE;
 retvar	varchar2(32767);


begin
   for c1rec in c1( iInvoiceNo ) loop
    retvar := retvar || htf.nl || c1rec.movement_no;
   end loop;
   return( substr(retvar,length(htf.nl)+1) );
end f_display_mv;
/


GRANT EXECUTE ON STRANG.F_DISPLAY_MV TO WEBSYS;
