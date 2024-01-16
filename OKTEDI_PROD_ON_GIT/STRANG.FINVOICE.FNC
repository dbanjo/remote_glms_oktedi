CREATE OR REPLACE function STRANG.finvoice( parm_id in varchar2, parm1 in varchar2, parm2 in varchar2 )
 return varchar2
as

 -- Parm1 = INVOICE NO
 -- Parm2 = AUTODESCRIPTION

 cursor c1( invno varchar2 ) is select * from invoices where invoiceno = invno;

 cursor c2( lv varchar2, cd varchar2 ) is
  select /*+ ALL_ROWS */ description
  from lov
  where lov_name = lv and
        code = cd;

 cursor c3( invno varchar2 ) is
  select quantity,cgunit,cgdesc,cge_chargecode,cgrate,gstc_gstcode,round(gst,2) gst,round(ic.quantity * ic.cgrate,2) value, cola,
         decode(l.colb,'No GST',(round(ic.quantity * ic.cgrate,2)),
                       'Inc GST',(round(ic.quantity * ic.cgrate,2)) - gst,
                       'Add GST',(round(ic.quantity * ic.cgrate,2))) total_value
  from invcharges  ic, lov l
  where inv_invoiceno = invno and
        gstc_gstcode = l.code and
        l.lov_name = 'GSTCODES'
  order by ic.cge_chargecode;
 cursor c4( cname varchar2 ) is select * from customers where customer = cname and customer_type = 'CUSTOMER';
 cursor c5( invno varchar2 ) is
  select 'Container No.:' || htf.bold(movement_no) movement_no,
         'Date Dispatched: ' || to_char(dispatch_date,'DD Month YYYY') dispatch_date,
         'Revenue Tonne: ' || revton revton,
         'Gross Weight (Kg): ' || to_char(nvl(sumweight,0)+ nvl(tare,0),'999,999,999.999') sm,
         to_char(null) sv,
         to_char(null) hawbs, flight,
         movement_type
  from movements m
  where m.invoiceno = invno and
        movement_type = 'CARGO'
  union all
  select 'Consignment Note.:' || htf.bold(movement_no) movement_no,
         to_char(null) dispatch_date,
         'Revenue Tonne: ' || revton revton,
         'Weight (Kg):' || to_char(nvl(sumweight,0),'999,999,999.9') sm,
         'Volume (M3):' || to_char(nvl(sumvolume,0),'999,999,999.999') sv,
         to_char(null) hawbs, flight,
         movement_type
  from movements m
  where m.invoiceno = invno and
        movement_type = 'CONMOV'
  union all
  select 'MAWB.:' || htf.bold(movement_no) movement_no,
         'Date: ' || to_char(dispatch_date,'DD Month YYYY') dispatch_date,
         to_char(null) dispatch_date,
         ' ' sm,
         ' ' sv,
         'HAWBs: '|| fhawbs( movement_no ) hawbs, 'Flight: ' || flight,
         movement_type
  from movements m
  where m.invoiceno = invno and
        movement_type = 'AIRWAY'
  order by movement_type,movement_no;
 cursor c6( invno varchar2 ) is
  select sum(round(gst,2)) gst,sum(round(ic.quantity * ic.cgrate,2)) value,
         sum(decode(l.colb,'No GST',(round(ic.quantity * ic.cgrate,2)),
                       'Inc GST',(round(ic.quantity * ic.cgrate,2)),
                       'Add GST',(round(ic.quantity * ic.cgrate,2)) + round(gst,2))) total_value
  from invcharges  ic, lov l
  where inv_invoiceno = invno and
        gstc_gstcode = l.code and
        l.lov_name = 'GSTCODES';
 cursor c7( invno varchar2 ) is
 select distinct p.po
 from strang.pos p, strang.detailrs dr, strang.movements m
 where m.invoiceno = invno
 and m.movement_no = dr.movement_no
 and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
 and dr.deliveryno = p.deliveryno;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 tmp		varchar2(32767);
 poctr		number;
begin
 poctr:=0;
 open c1(parm1);
 fetch c1 into c1rec;
 close c1;
 if parm_id = 'IA'
  then
   update invoices set completed = 'COMPLETE' where invoiceno = c1rec.invoiceno;
   commit;
   open c2('CONTROLS','INVOICE_CUSTOMER' );
   fetch c2 into c2rec;
   close c2;
   open c4(c2rec.description);
   fetch c4 into c4rec;
   close c4;
   return( c4rec.customer || htf.nl || c4rec.street || ', ' || c4rec.suburb || htf.nl || c4rec.state || ' ' || c4rec.postcode || htf.nl || c4rec.country );
 elsif parm_id = 'IB'
  then
   return( parm1 );
 elsif parm_id = 'IC'
  then
   open c2('CONTROLS','INVOICE_ACCOUNT' );
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'ID'
  then
   return( to_char(c1rec.invdate,'DD Month YYYY') );
 elsif parm_id = 'IE'
  then
   return( c1rec.ctrk_contract );
 elsif parm_id = 'IF'
  then
   return( '1' );
 elsif parm_id = 'IH'
  then
   for c3rec in c3(c1rec.invoiceno) loop
    tmp := tmp || htf.nl|| htf.nl || htf.nl || c3rec.cge_chargecode;
   end loop;
   return( substr( tmp,length( htf.nl || htf.nl ) + 1 ));
 elsif parm_id = 'IJ'
  then
   for c3rec in c3(c1rec.invoiceno) loop
    tmp := tmp || htf.nl|| htf.nl || c3rec.cgdesc || htf.nl ||
           to_char(c3rec.quantity,'999999999.999') ||
           ' ' || c3rec.cgunit || ' @ ' ||
           to_char(c3rec.cgrate,'999999999.9999') || ' &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' ||
           'GST (' || c3rec.gstc_gstcode || ') @' || c3rec.cola || '% = ' || to_char(nvl(c3rec.gst,0),'$999,999,999.99');
   end loop;
   return( substr( tmp,length( htf.nl ) + 1 ));
 elsif parm_id = 'IJ1'
  then
   if substr(c1rec.invoiceno,1,1) = 'S'
    then
     return( 'Ex Sydney' );
   elsif substr(c1rec.invoiceno,1,1) = 'B'
    then
     return( 'Ex Brisbane' );
   elsif substr(c1rec.invoiceno,1,1) = 'T'
    then
     return( 'Ex Townsville' );
   elsif substr(c1rec.invoiceno,1,1) = 'N'
    then
     return( 'Ex Newcastle' );
   elsif substr(c1rec.invoiceno,1,1) = 'M'
    then
     return( 'Ex Melbourne' );
   elsif substr(c1rec.invoiceno,1,1) = 'P'
    then
     return( 'Ex Perth' );
   elsif substr(c1rec.invoiceno,1,1) = 'A'
    then
     return( 'Ex Adelaide' );
   else
    return( 'Ex ______________________' );
   end if;
 elsif parm_id = 'IJ2'
  then
   tmp := replace(c1rec.invdesc,chr(10),htf.nl);
   if parm2 = 'N'
    then
     return( tmp );
   end if;
   tmp := tmp || htf.nl;
   for c5rec in c5( c1rec.invoiceno ) loop
    tmp := tmp || c5rec.movement_no || ' ' ||  c5rec.flight ||  ' ' || c5rec.dispatch_date || ' ' ||
                  c5rec.revton || ' ' || c5rec.sm || ' ' ||
                  c5rec.sv || htf.nl || c5rec.hawbs || htf.nl;
   end loop;
   return( substr(tmp,1,(length(tmp) - length(htf.nl))) );
 elsif parm_id = 'IPO'
  then
   poctr:= 1;
   tmp := '';
   for c7rec in c7( c1rec.invoiceno ) loop
  --  tmp := tmp || c7rec.po|| ' '; -- Veronika modified to make cut and paste easier.
--    tmp := tmp || c7rec.po|| ' ';
--    poctr:=poctr+1;
--    if poctr >= 4 then
--      tmp := tmp || htf.nl;
--      poctr := 1;
--    end if;
     
    if poctr = 1 then
       tmp := nvl(c7rec.po,'');
       poctr:=poctr+1;
    else 
       tmp := tmp||htf.nl||nvl(c7rec.po,'');
       poctr:=poctr+1;
    end if;
    
      

   end loop;
   RETURN (TMP);
--   return( substr(tmp,1,length(tmp) - length(htf.nl)) );
 elsif parm_id = 'IK'
  then
   for c3rec in c3(c1rec.invoiceno) loop
    tmp := tmp || htf.nl|| htf.nl || htf.nl || to_char(c3rec.total_value,'$999,999,999.99');
   end loop;
   return( substr( tmp,length( htf.nl || htf.nl ) + 1 ));
 elsif parm_id = 'IL'
  then
   open c6(c1rec.invoiceno);
   fetch c6 into c6rec;
   close c6;
   return( to_char( nvl(c6rec.value,0),'$999,999,999.99' ));
 elsif parm_id = 'IM'
  then
   open c6(c1rec.invoiceno);
   fetch c6 into c6rec;
   close c6;
   return( to_char( nvl(c6rec.gst,0),'$999,999,999.99' ));
 elsif parm_id = 'IN'
  then
   open c6(c1rec.invoiceno);
   fetch c6 into c6rec;
   close c6;
   return( to_char( nvl(c6rec.total_value,0),'$999,999,999.99' ));
 elsif parm_id = 'UPDATE'
  then
   update invoices set completed = 'COMPLETE' where invoiceno = c1rec.invoiceno;
   commit;
 end if;
end finvoice;
/


GRANT EXECUTE ON STRANG.FINVOICE TO WEBSYS;
