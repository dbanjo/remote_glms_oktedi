CREATE OR REPLACE function WEBSYS.f_receival_link( row_id varchar2, deliveryno varchar2, surl varchar2 )
   return varchar
  as

   retvar varchar2(32767);

   begin

   retvar := null;

   retvar := htf.anchor2('STRANGP.receive?surl=' || surl || '&rid=' || replace(row_id, '+', '~') ||'&scid=12&call_name=OLTP.RUN_REPORT&parm=RECEIVALS&access_id=x&msg=&call_name=' ||'OLTP', htf.bold(to_char(deliveryno)),  ctarget=>'NEW_PAGE');
      return( retvar );

 end f_receival_link;
/
