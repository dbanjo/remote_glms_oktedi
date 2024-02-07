CREATE OR REPLACE function STRANG.f15_worksheet_manent( parm_id in varchar2, parm1 in varchar2, parm2 in varchar2 default null )
 return varchar2
as

 -- Parm1 = ENTRY_NO

 cursor c1( parm1 number ) is
  select *
  from manentry
  where entry_no = parm1;

 cursor c3( parm1 number ) is
  select vat_rate
  from manent2
  where entry_no = parm1;

 cursor c7( entryno number ) is
 select /*+ ALL_ROWS */ sum(kinavalue) kvalue, sum(duty) duty, sum(excise) excise, sum(vat) vat,sum(oldduty) old_duty
 from manent2
 where entry_no = entryno;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c7rec		c7%ROWTYPE;

begin
 open c1(parm1);
 fetch c1 into c1rec;
 close c1;

 if parm_id = 'D1'
  then
   return( to_char(sysdate,'DD Month YYYY') );

 elsif parm_id = 'D2'
  then
   return( parm1 );

 elsif parm_id = 'D3'
  then
   return( c1rec.importer );

elsif parm_id = 'D4'
  then
   return( c1rec.date_of_arrival_departure );

elsif parm_id = 'D5'
  then
   return( c1rec.shortdesc );

elsif parm_id = 'DA'
  then
   return( c1rec.importer);

elsif parm_id = 'DC'
  then
   return( c1rec.bill_of_lading );

elsif parm_id = 'DD'
  then
   return( c1rec.port_of_loading );

elsif parm_id = 'DE'
  then
   return( c1rec.ship_name );

elsif parm_id = 'DF'
  then
   return( c1rec.voyage );

elsif parm_id = 'DG'
  then
   return( c1rec.date_of_arrival_departure );

elsif parm_id = 'DH'
  then
   return( c1rec.port_of_discharge );

elsif parm_id = 'DI'
  then
   return( c1rec.country_name );

elsif parm_id = 'DK'
  then
   return( c1rec.port_of_loading );

elsif parm_id = 'DL'
  then
   return( c1rec.exporter );

elsif parm_id = 'DM'
  then
   return( to_char(c1rec.invoice_total,'999,999,990.99') );

elsif parm_id = 'DN'
  then
   return( to_char(c1rec.freight,'999,999,990.99') );

elsif parm_id = 'DO'
  then
   return( to_char(c1rec.insurance,'999,999,990.99') );

elsif parm_id = 'DP'
  then
   return( to_char(c1rec.other_costs,'999,999,990.99') );

elsif parm_id = 'DQ'
  then
   return( c1rec.currency_code );

elsif parm_id = 'DR'
  then
   return( c1rec.exchange_rate );

elsif parm_id = 'DS'
  then
   return( c1rec.ratio_factor );

elsif parm_id = 'DT'
  then
   open c3(parm1);
   fetch c3 into c3rec;
   close c3;
   return( c3rec.vat_rate );

elsif parm_id = 'VAL1'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   return( to_char(c7rec.old_duty,'999,999,990.99') );

elsif parm_id = 'VAL2'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   return( to_char(c7rec.kvalue * (1.5/100),'999,999,990.99') );

elsif parm_id = 'VAL3'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   return( to_char(c7rec.duty + c7rec.excise + c7rec.vat,'999,999,990.99') );

elsif parm_id = 'VAL4'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   return( to_char((c7rec.kvalue * (1.5/100)) + c7rec.old_duty,'999,999,990.99') );

elsif parm_id = 'VAL5'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   if (c7rec.duty + c7rec.excise + c7rec.vat) < ((c7rec.kvalue * (1.5/100)) + c7rec.old_duty)
    then
     return( 'The Current Method is ' || to_char(((c7rec.kvalue * (1.5/100)) + c7rec.old_duty) - (c7rec.duty + c7rec.excise + c7rec.vat),'999,999,990.99') || ' Lower than the Previous Method.' );
   elsif (c7rec.duty + c7rec.excise + c7rec.vat) = ((c7rec.kvalue * (1.5/100)) + c7rec.old_duty)
    then
     return( 'There is no difference between the Current and Previous Method.' );
    else
     return( 'The Current Method is ' || to_char((c7rec.duty + c7rec.excise + c7rec.vat) - ((c7rec.kvalue * (1.5/100)) + c7rec.old_duty),'999,999,990.99') || ' Greater than the Previous Method.' );
   end if;

elsif parm_id = 'VAL6'
  then
   return( c1rec.shortdesc);

end if;

end f15_worksheet_manent;
/


GRANT EXECUTE ON STRANG.F15_WORKSHEET_MANENT TO WEBSYS;
