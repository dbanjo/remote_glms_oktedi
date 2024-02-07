CREATE OR REPLACE function STRANG.f15_ratio_manent( typ in varchar2, entryno in number )
 return varchar2
as

 cursor c1( entryno number ) is
  select *
  from manentry
  where entry_no = entryno;

 c1rec		c1%ROWTYPE;
 ttl		number;

 begin
 open c1(entryno);
 fetch c1 into c1rec;
 close c1;

 if typ = 'RA'
  then
   return( to_char(entryno) );

 elsif typ = 'RB'
  then
   return( c1rec.shortdesc );

 elsif typ = 'RC'
  then
   return( to_char(sysdate,'DD-Mon-YYYY') );

 elsif typ = 'RD'
  then
   return( c1rec.importer );

 elsif typ = 'RE'
  then
   return( to_char(c1rec.invoice_total,'999,999,990.99') );

 elsif typ = 'RF'
  then
   return( c1rec.currency_code );

 elsif typ = 'RG'
  then
   return( (c1rec.exchange_rate) );

 elsif typ = 'RH'
  then
   return( to_char(c1rec.invoice_total * c1rec.ratio_factor,'999,999,990.99') );

 elsif typ = 'RI'
  then
   return( to_char(c1rec.freight,'999,999,990.99') );

 elsif typ = 'RJ'
  then
   return( to_char(c1rec.freight / c1rec.exchange_rate,'999,999,990.99') );

 elsif typ = 'RK'
  then
   return( to_char(c1rec.insurance,'999,999,990.99') );

 elsif typ = 'RL'
  then
   return( to_char(c1rec.insurance / c1rec.exchange_rate,'999,999,990.99') );

 elsif typ = 'RM'
  then
   return( to_char(c1rec.other_costs,'999,999,990.99') );

 elsif typ = 'RN'
  then
   return( to_char(c1rec.other_costs / c1rec.exchange_rate,'999,999,990.99') );

 elsif typ = 'RO'
  then
   ttl := ((c1rec.invoice_total * c1rec.ratio_factor) +
           (c1rec.freight / c1rec.exchange_rate) +
           (c1rec.insurance / c1rec.exchange_rate ) +
           (c1rec.other_costs / c1rec.exchange_rate ));

   return( to_char(ttl,'999,999,990.99') );

 elsif typ = 'RP'
  then
   return( to_char(c1rec.invoice_total,'999,999,990.99') );

 elsif typ = 'RQ'
  then
   return( to_char(c1rec.ratio_factor,'999.99999999') );
 end if;

end f15_ratio_manent;
/


GRANT EXECUTE ON STRANG.F15_RATIO_MANENT TO WEBSYS;
