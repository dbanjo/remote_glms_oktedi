CREATE OR REPLACE function STRANG.f15_parameter_range_manent( parm_id in varchar2, parm1 in varchar2, parm2 in varchar2 )
 return varchar2
as

 -- Parm1 = ENTRY_NO
 -- Parm2 = CUSTOMER

 cursor c1( parm1 number ) is
  select *
  from manentry
  where entry_no = parm1;

 cursor c3( parm1 number ) is
  select /*+ ALL_ROWS */ sum(value) sm
  from manent2
  where entry_no = parm1;

 cursor c11b(entryno number) is
  select min(rno) mn, max(rno) mx
  from manent2 dr
  where entry_no = entryno;

cursor c13( entryno number ) is
 select /*+ ALL_ROWS */ *
 from manent1
 where entry_no = entryno ;

cursor c17( entryno number ) is
 select *
 from manent2
  where entry_no = entryno
 order by tariff;

cursor c17x( entryno number ) is
 select /*+ ALL_ROWS */ tariff, rate, excise
 from manent2
 where entry_no = entryno and
       rownum < 5;

cursor c21( entryno number ) is
 select /*+ ALL_ROWS */  count( 'x' ) tot
 from manent2
 where entry_no = entryno;


 cursor c2b( cd varchar2 ) is
  select /*+ ALL_ROWS */ *
  from lov l
  where l.lov_name = 'CONTROLS' and
        l.cola = WEBSYS.OLTP.F_USER_SITE and
        code = cd;

 c1rec		c1%ROWTYPE;
 c2rec		c2b%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c13rec		c13%ROWTYPE;
 c11brec	c11b%ROWTYPE;
 c21rec		c21%ROWTYPE;
 ttl		number;
 exr		number;
 tmp		varchar2(32767);
 tmp2		varchar2(32767);

begin
 open c1(parm1);
 fetch c1 into c1rec;
 close c1;

 if parm_id = 'A0'
  then
   -- Calculate total Page Numbers
   open c21(parm1);
   fetch c21 into c21rec;
   close c21;
   if c21rec.tot < 5
    then
     return( '1' );
   else
    c21rec.tot := trunc((c21rec.tot - 5) / 10) + 2;
    return( to_char(c21rec.tot) );
   end if;

 elsif parm_id = 'A1'
  then
   return( c1rec.one_a_code );

 elsif parm_id = 'A2'
  then
   -- Ships_airway
   return( c1rec.cpc );

 elsif parm_id = 'A3'
  then
   return( c1rec.port_of_discharge );

 elsif parm_id = 'A4'
  then
   return( c1rec.exporter );

 elsif parm_id = 'A5'
  then
   return( c1rec.two_a_code || ' ' || c1rec.account_number );

 elsif parm_id = 'A6'
  then
   return( c1rec.importer);

 elsif parm_id = 'A6X'
  then
   return( c1rec.importer_address || htf.nl || c1rec.importer_address1 );

 elsif parm_id = 'A7'
  then
   return( c1rec.country_name || ' ' || c1rec.country_code );

 elsif parm_id = 'A8'
  then
   return( c1rec.Terms_of_delivery );

 elsif parm_id = 'A9'
  then
   return( c1rec.exchange_rate );

 elsif parm_id = 'AA'
  then
   return( to_char(c1rec.ratio_factor,'999.99999999') );

 elsif parm_id = 'AB'
  then
   return( c1rec.Port_of_loading );

 elsif parm_id = 'AC'
  then
   return( c1rec.declarer || htf.nl || c1rec.declarer_address || htf.nl || c1rec.declarer_address1 );

 elsif parm_id = 'AD'
  then
   return( c1rec.three_a_code || ' &nbsp;&nbsp;&nbsp;&nbsp; ' || c1rec.entry_no);

 /*
 elsif parm_id = 'AE'
  then
   open c3(parm1);
   fetch c3 into c3rec;
   close c3;
   return( to_char(c3rec.sm,'99999999.99') );
 */
 elsif parm_id = 'AE'
  then
  return( to_char(c1rec.invoice_total,'99999999.99') );


 elsif parm_id = 'AF'
  then
   return( c1rec.currency_code);

 elsif parm_id = 'AG'
  then
   return( to_char(c1rec.freight,'99999999.99') );

 elsif parm_id = 'AH'
  then
   return( c1rec.three_b_reference );

 elsif parm_id = 'AI'
  then
   return( to_char(c1rec.insurance,'99999999.99') );

 elsif parm_id = 'AJ'
  then
   return( to_char(c1rec.Other_costs,'99999999.99') );

 elsif parm_id = 'AK'
  then
   return( c1rec.mode_of_transport || ' &nbsp;&nbsp;&nbsp; ' || c1rec.code );

 elsif parm_id = 'AL'
  then
   return( c1rec.Date_of_arrival_departure );

 elsif parm_id = 'AM'
  then
   return( c1rec.attachments_invoices );

 elsif parm_id = 'AN'
  then
   return( c1rec.attachments_packing );

 elsif parm_id = 'AO'
  then
   return( c1rec.attachments_order );

 elsif parm_id = 'AP'
  then
   return( c1rec.attachments_licence );

 elsif parm_id = 'AQ'
  then
   return( c1rec.attachments_freight );

 elsif parm_id = 'AR'
  then
   return( c1rec.attachments_other );

 elsif parm_id = 'AS'
  then
   return( c1rec.ship_name || ' ' || c1rec.voyage );

 elsif parm_id = 'AT'
  then
    open c11b(parm1);
    fetch c11b into c11brec;
    close c11b;
    if c11brec.mn = c11brec.mx
     then
      return( c11brec.mn );
     else
      return( c11brec.mn || ' - ' || c11brec.mx );
    end if;

 elsif parm_id = 'AU'
  then
   return( c1rec.bill_of_lading );

 elsif parm_id = 'AV'
  then
   return( NULL );

 elsif parm_id = 'AW'
  then
   open c13(parm1);
   fetch c13 into c13rec;
   close c13;
   tmp := htf.tableopen;
     tmp := tmp || htf.tablerowopen || htf.tabledata(c13rec.pack1, cattributes=>'width=50 valign="TOP" style="font-size:7.0pt; font-family:Arial"');
     tmp := tmp || htf.tabledata(c13rec.description1, cattributes=>'valign="TOP" style="font-size:7.0pt; font-family:Arial"') || htf.tablerowclose;
     tmp := tmp || htf.tablerowopen || htf.tabledata(c13rec.pack2, cattributes=>'width=50 valign="TOP" style="font-size:7.0pt; font-family:Arial"');
     tmp := tmp || htf.tabledata(c13rec.description2, cattributes=>'valign="TOP" style="font-size:7.0pt; font-family:Arial"') || htf.tablerowclose;
     tmp := tmp || htf.tablerowopen || htf.tabledata(c13rec.pack3, cattributes=>'width=50 valign="TOP" style="font-size:7.0pt; font-family:Arial"');
     tmp := tmp || htf.tabledata(c13rec.description3, cattributes=>'valign="TOP" style="font-size:7.0pt; font-family:Arial"') || htf.tablerowclose;
     tmp := tmp || htf.tablerowopen || htf.tabledata(c13rec.pack4, cattributes=>'width=50 valign="TOP" style="font-size:7.0pt; font-family:Arial"');
     tmp := tmp || htf.tabledata(c13rec.description4, cattributes=>'valign="TOP" style="font-size:7.0pt; font-family:Arial"') || htf.tablerowclose;
     tmp := tmp || htf.tablerowopen || htf.tabledata(c13rec.pack5, cattributes=>'width=50 valign="TOP" style="font-size:7.0pt; font-family:Arial"');
     tmp := tmp || htf.tabledata(c13rec.description5, cattributes=>'valign="TOP" style="font-size:7.0pt; font-family:Arial"') || htf.tablerowclose;
     tmp := tmp || htf.tablerowopen || htf.tabledata(c13rec.pack6, cattributes=>'width=50 valign="TOP" style="font-size:7.0pt; font-family:Arial"');
     tmp := tmp || htf.tabledata(c13rec.description6, cattributes=>'valign="TOP" style="font-size:7.0pt; font-family:Arial"') || htf.tablerowclose;
     tmp := tmp || htf.tablerowopen || htf.tabledata(c13rec.pack7, cattributes=>'width=50 valign="TOP" style="font-size:7.0pt; font-family:Arial"');
     tmp := tmp || htf.tabledata(c13rec.description7, cattributes=>'valign="TOP" style="font-size:7.0pt; font-family:Arial"') || htf.tablerowclose;
     tmp := tmp || htf.tablerowopen || htf.tabledata(c13rec.pack8, cattributes=>'width=50 valign="TOP" style="font-size:7.0pt; font-family:Arial"');
     tmp := tmp || htf.tabledata(c13rec.description8, cattributes=>'valign="TOP" style="font-size:7.0pt; font-family:Arial"') || htf.tablerowclose;
     tmp := tmp || htf.tablerowopen || htf.tabledata(c13rec.pack9, cattributes=>'width=50 valign="TOP" style="font-size:7.0pt; font-family:Arial"');
     tmp := tmp || htf.tabledata(c13rec.description9, cattributes=>'valign="TOP" style="font-size:7.0pt; font-family:Arial"') || htf.tablerowclose;
     tmp := tmp || htf.tablerowopen || htf.tabledata(c13rec.pack10, cattributes=>'width=50 valign="TOP" style="font-size:7.0pt; font-family:Arial"');
     tmp := tmp || htf.tabledata(c13rec.description10, cattributes=>'valign="TOP" style="font-size:7.0pt; font-family:Arial"') || htf.tablerowclose;
   tmp := tmp || htf.tableclose;

   return( tmp );

 elsif parm_id = 'AX'
  then
   return( c1rec.agent );

 elsif parm_id = 'AY'
  then
   return( c1rec.position );

 elsif parm_id = 'AZ'
  then
   return( c1rec.warehouse_name );

 elsif parm_id = 'AZ1'
  then
   return( c1rec.warehouse_number );

 elsif parm_id = 'B1'
  then
   ttl := 0;
   for c17rec in c17(parm1) loop
     ttl := ttl + nvl(c17rec.duty,0);
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

 elsif parm_id = 'B2'
  then
   ttl := 0;
   for c17rec in c17(parm1) loop
     --ttl := ttl + nvl(c17rec.excise,0);
     if c17%ROWCOUNT > 4 then exit; end if;
     ttl := ttl + nvl(c17rec.duty,0) + nvl(c17rec.excise,0) + nvl(c17rec.vat,0) + nvl(c17rec.levy,0);
  /*
     ttl := ttl + nvl(c17rec.duty,0) + nvl(c17rec.excise,0) + nvl(c17rec.vat,0) + nvl( (nvl(c17rec.kinavalue,0) + nvl(c17rec.duty,0) + nvl(c17rec.excise,0))*0.02,0);
  */
  end loop;
   return( to_char(round(ttl,2),'999999990.99') );

 elsif parm_id = 'B3'
  then
   ttl := 0;
   for c17rec in c17(parm1) loop
     --ttl := ttl + nvl(c17rec.excise,0);
     if c17%ROWCOUNT > 4 then exit; end if;
     ttl := ttl + nvl(c17rec.duty,0) + nvl(c17rec.excise,0) + nvl(c17rec.vat,0) + nvl(c17rec.levy,0);
  /*
     ttl := ttl + nvl(c17rec.duty,0) + nvl(c17rec.excise,0) + nvl(c17rec.vat,0) + nvl( (nvl(c17rec.kinavalue,0) + nvl(c17rec.duty,0) + nvl(c17rec.excise,0))*0.02,0);
   */
   end loop;
   exr := ttl;
   ttl := 0;
   for c17rec in c17(parm1) loop
  ttl := ttl + nvl(c17rec.duty,0) + nvl(c17rec.excise,0) + nvl(c17rec.vat,0) + nvl(c17rec.levy,0);
   /*
     ttl := ttl + nvl(c17rec.duty,0) + nvl(c17rec.excise,0) + nvl(c17rec.vat,0) + nvl( (nvl(c17rec.kinavalue,0) + nvl(c17rec.duty,0) + nvl(c17rec.excise,0))*0.02,0);
   */
   end loop;
   return( to_char(round(ttl-exr,2),'999999990.99') );

 elsif parm_id = 'B4'
  then
   ttl := 0;
   for c17rec in c17(parm1) loop
     ttl := ttl + nvl(c17rec.duty,0) + nvl(c17rec.excise,0) + nvl(c17rec.vat,0) + nvl(c17rec.levy,0);
   /*
     ttl := ttl + nvl(c17rec.duty,0) + nvl(c17rec.excise,0) + nvl(c17rec.vat,0) + nvl( (nvl(c17rec.kinavalue,0) + nvl(c17rec.duty,0) + nvl(c17rec.excise,0))*0.02,0);
   */
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

 elsif parm_id = 'REPORT_A'
  then
   -- Calculate total Page Numbers to determine if the continuation report should be run
   if parm1 is null then return( 'RUN' ); end if;
   open c21(parm1);
   fetch c21 into c21rec;
   close c21;
   if c21rec.tot < 5
    then
     return( '0' );
   else
     return( 'RUN' );
   end if;

 elsif parm_id = 'REPORT_B'
  then
   -- Calculate total Page Numbers to determine if the continuation report should be run
   return( 'RUN' );

 elsif parm_id = 'SIG'
  then
   -- Calculate total Page Numbers to determine if the continuation report should be run
   open c2b('FORM 15 SIGNATURE');
   fetch c2b into c2rec;
   if c2b%NOTFOUND
    then
     close c2b;
     return( '__________________________________________' );
    else
     close c2b;
     return( '<IMG SRC="file:///c:/signature/' || c2rec.description || '" BORDER=0 WIDTH="80" HEIGHT="60">' );
   end if;

 end if;
exception
 when others then return( NULL );
end f15_parameter_range_manent;
/


GRANT EXECUTE ON STRANG.F15_PARAMETER_RANGE_MANENT TO WEBSYS;
