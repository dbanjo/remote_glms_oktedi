CREATE OR REPLACE function STRANG.f15_worksheet_extra( entryno in number, typ in varchar2 )
 return varchar2
as

 cursor c1( parm1 number ) is
  select /*+ ALL_ROWS */ *
  from ships_airway
  where ship_id in ( select ship_id
                     from movements m, detailrs dr
                     where entry_no = parm1 and
                           m.movement_no = dr.movement_no and
                           nvl(m.seal,'|') = nvl(dr.camov_seal,'|'));

 cursor c9(entryno number) is
  select /*+ ALL_ROWS */ *
  from duty
  where entry_no = entryno;

 cursor c10(custid number) is
  select /*+ ALL_ROWS */ *
  from customers
  where customer_id = custid;

cursor c13( entryno number ) is
 select /*+ ALL_ROWS */ l1.description, pktpe_packtype,sum(qty) tot
 from detailrs dr, lov l1
 where entry_no = entryno and
       l1.lov_name = 'PACKTYPES' and
       l1.code = dr.pktpe_packtype
 group by l1.description, pktpe_packtype;

cursor c14( entryno number ) is
 select /*+ ALL_ROWS */ distinct po
 from detailrs dr, pos p
 where entry_no = entryno and
       p.deliveryno = dr.deliveryno
 order by po;

cursor c15( entryno number, pktpe varchar2 ) is
 select /*+ ALL_ROWS */ detaildesc
 from detailrs
 where entry_no = entryno and
       pktpe_packtype = pktpe
 group by detaildesc;

cursor c16( entryno number ) is
 select /*+ ALL_ROWS */ distinct movement_no
 from detailrs dr
 where entry_no = entryno
 order by movement_no;

cursor c18( entryno number ) is
 select /*+ ALL_ROWS */ min(line_no) line_no, m.movement_no, ship_id
 from detailrs dr, movements m
 where entry_no = entryno and
       dr.movement_no = m.movement_no and
       nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
 group by m.movement_no,ship_id;

cursor c19( shipid integer ) is
 select /*+ ALL_ROWS */ *
 from ships_airway
 where ship_id = shipid;

 c1rec		c1%ROWTYPE;
 c9rec		c9%ROWTYPE;
 c10rec		c10%ROWTYPE;
 c18rec		c18%ROWTYPE;
 c19rec		c19%ROWTYPE;
 ttl		number;
 tmp		varchar2(32767);
 tmp2		varchar2(32767);

 begin

 if typ = 'DESCRIPTION'
  then
   open c9( entryno );
   fetch c9 into c9rec;
   close c9;
   /*
   for c13rec in c13( entryno ) loop
    tmp2 := c13rec.description || ':';
    for c15rec in c15( entryno, c13rec.pktpe_packtype ) loop
     if length(tmp2) > 100
      then
       tmp := tmp || htf.nl || tmp2;
       tmp2 := NULL;
      else
       tmp2 := tmp2 || c15rec.detaildesc || ',';
     end if;
    end loop;
    tmp := tmp || substr(tmp2,1,length(tmp2)-1) || htf.nl;
    tmp2 := NULL;
   end loop;
   */

   tmp := htf.tableopen;
   for c13rec in c13( entryno ) loop
    tmp := tmp || htf.tablerowopen || htf.tabledata(c13rec.tot, cattributes=>'valign="TOP" style="font-size:8.0pt; font-family:Arial"');
    for c15rec in c15( entryno, c13rec.pktpe_packtype ) loop
     tmp2 := tmp2 || c15rec.detaildesc || ',';
    end loop;
    tmp := tmp || htf.tabledata(c13rec.description || ':' || substr(tmp2,1,length(tmp2)-1), cattributes=>'valign="TOP" style="font-size:8.0pt; font-family:Arial"') || htf.tablerowclose;
    tmp2 := NULL;
   end loop;
   tmp := tmp || htf.tableclose;

   -- PO
   for c14rec in c14( entryno ) loop
    tmp := tmp || c14rec.po || ',';
   end loop;

   -- Movements
   for c16rec in c16( entryno ) loop
    tmp := tmp || c16rec.movement_no || ',';
   end loop;

   open c1(entryno);
   fetch c1 into c1rec;
   close c1;

   tmp := substr(tmp,1,length(tmp)-1) || htf.nl || htf.nl || c1rec.pcomment;
   return( tmp );

 elsif typ = 'DESCRIPTIONX'
  then
   open c9( entryno );
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is not null
    then
     open c18(c9rec.previous_entry_no);
     fetch c18 into c18rec;
     close c18;
     open c19(c18rec.ship_id);
     fetch c19 into c19rec;
     close c19;
     tmp := htf.nl ||
     'I HEREBY DECLARE THAT THE VALUE FOR THE ABOVE MENTIONED GOODS HAD BEEN ENTERED FOR DUTY PAYMENT ON THE MANIFEST FOR THE ' ||
     c19rec.shipname || ' ' || c19rec.voy || ', LINE NUMBER ' || c18rec.line_no || '.<BR>WARRANT NO: _____________________ ' ||
     ' PART SHIPMENT OF CONTAINER NO ' || c18rec.movement_no || '.' || htf.nl;
     open c1(entryno);
     fetch c1 into c1rec;
     close c1;
     open c10(c1rec.customs_agent);
     fetch c10 into c10rec;
     close c10;
     tmp := tmp || c10rec.customer || ' ' || c10rec.street;
   end if;
   return( tmp );

elsif typ = 'PCKGS'
 then
   return( NULL );
   for c13rec in c13( entryno ) loop
    tmp := tmp || htf.nl || htf.nl || c13rec.tot;
   end loop;
   return( substr( tmp, (length(htf.nl)*2)+1) );

end if;

end f15_worksheet_extra;
/


GRANT EXECUTE ON STRANG.F15_WORKSHEET_EXTRA TO WEBSYS;
