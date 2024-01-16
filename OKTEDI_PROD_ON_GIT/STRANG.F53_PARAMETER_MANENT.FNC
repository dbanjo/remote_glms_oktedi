CREATE OR REPLACE function STRANG.f53_parameter_manent( parm_id in varchar2, parm1 in varchar2 )
 return varchar2
as

 -- Parm1 = ENTRY_NO

 cursor c1( parm1 integer ) is
  select *
  from manentry
  where entry_no = parm1;

 cursor c2( lv varchar2, cd varchar2 ) is /*+ ALL_ROWS */ select description from lov where lov_name = lv and code = cd;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;

begin

 open c1(parm1);
 fetch c1 into c1rec;
 close c1;
 if parm_id = 'P1'
  then
   return( c1rec.exporter );

 elsif parm_id = 'P2'
  then
   return( c1rec.importer );

 elsif parm_id = 'P3'
  then
   return( c1rec.importer_address || htf.nl || c1rec.importer_address1);

 elsif parm_id = 'PA'
  then
   open c2( 'CONTROLS','FORM 53 7A' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( NULL );
    else
     return( 'X' );
   end if;

 elsif parm_id = 'PB'
  then
   open c2( 'CONTROLS','FORM 53 7A' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( 'X' );
    else
     return( NULL );
   end if;

 elsif parm_id = 'PC'
  then
   open c2( 'CONTROLS','FORM 53 7B' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( NULL );
    else
     return( 'X' );
   end if;

 elsif parm_id = 'PD'
  then
   open c2( 'CONTROLS','FORM 53 7B' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( 'X' );
    else
     return( NULL );
   end if;

 elsif parm_id = 'PE'
  then
   open c2( 'CONTROLS','FORM 53 7C' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( NULL );
    else
     return( 'X' );
   end if;

 elsif parm_id = 'PF'
  then
   open c2( 'CONTROLS','FORM 53 7C' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( 'X' );
    else
     return( NULL );
   end if;

 elsif parm_id = 'PG'
  then
   open c2( 'CONTROLS','FORM 53 8A' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( NULL );
    else
     return( 'X' );
   end if;

 elsif parm_id = 'PH'
  then
   open c2( 'CONTROLS','FORM 53 8A' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( 'X' );
    else
     return( NULL );
   end if;

 elsif parm_id = 'PI'
  then
   open c2( 'CONTROLS','FORM 53 8B' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( NULL );
    else
     return( 'X' );
   end if;

 elsif parm_id = 'PJ'
  then
   open c2( 'CONTROLS','FORM 53 8B' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( 'X' );
    else
     return( NULL );
   end if;

 elsif parm_id = 'PK'
  then
   open c2( 'CONTROLS','FORM 53 9A' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( NULL );
    else
     return( 'X' );
   end if;

 elsif parm_id = 'PL'
  then
   open c2( 'CONTROLS','FORM 53 9A' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( 'X' );
    else
     return( NULL );
   end if;

 elsif parm_id = 'PM'
  then
   open c2( 'CONTROLS','FORM 53 9B' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( NULL );
    else
     return( 'X' );
   end if;

 elsif parm_id = 'PN'
  then
   open c2( 'CONTROLS','FORM 53 9B' );
   fetch c2 into c2rec;
   close c2;
   if upper(substr(c2rec.description,1,1)) = 'N'
    then
     return( 'X' );
    else
     return( NULL );
   end if;

 elsif parm_id = 'PO'
  then
   open c2( 'CONTROLS','AIRSUBURB' );
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );

 elsif parm_id = 'PP'
  then
   return( to_char(sysdate,'DD.MM.YYYY') );

 elsif parm_id = 'Q1'
  then
   return( c1rec.exchange_rate );

 elsif parm_id = 'QA'
  then
   return( c1rec.currency_code );

 elsif parm_id = 'Q2'
  then
   return( to_char(nvl(c1rec.invoice_total,0),'999,999,990.99') );

 elsif parm_id = 'Q3'
  then
   return( to_char(nvl(c1rec.invoice_total/c1rec.exchange_rate,0),'999,999,990.99') );

 elsif parm_id = 'Q4'
  then
   return( to_char(nvl(c1rec.freight/c1rec.exchange_rate,0),'999,999,990.99') );

 elsif parm_id = 'Q5'
  then
   return( to_char(nvl(c1rec.insurance/c1rec.exchange_rate,0),'999,999,990.99') );

 elsif parm_id = 'Q6'
  then
   return( to_char(nvl(c1rec.other_costs/c1rec.exchange_rate,0),'999,999,990.99') );

 elsif parm_id = 'Q7'
  then
   return( to_char(nvl(c1rec.invoice_total * c1rec.ratio_factor,0),'999,999,990.99') );

 end if;
exception
 when others then return( sqlerrm );
end f53_parameter_manent;
/


GRANT EXECUTE ON STRANG.F53_PARAMETER_MANENT TO WEBSYS;
