CREATE OR REPLACE function STRANG.form_15_continue_manent(colin varchar2, entryno in number, tariff in varchar2, vrno in integer, rnumb in integer default null, vtot in integer)
 return varchar2
as

 cursor c1(entryno number, vrno integer) is
  select /*+ ALL_ROWS */ *
  from manent2
  where entry_no = entryno and
        rno = vrno;

 cursor c2(entryno number) is
  select /*+ ALL_ROWS */ *
  from manent1
  where entry_no = entryno;

 cursor c3(entryno number) is
  select /*+ ALL_ROWS */ *
  from manentry
  where entry_no = entryno;

/* 2 % levy calculation */
 cursor c17( entryno number, rfrom integer, rto integer ) is
  select duty, excise, vat, kinavalue, levy sm
  from
  (
   select rownum rnumb, duty, excise, vat, kinavalue, levy
   from
   (
    select /*+ ALL_ROWS */ duty, excise, vat, kinavalue, levy
    from manent2
    where entry_no = entryno
    order by tariff
    )
  )
  where rnumb >= rfrom and rnumb < rto;

cursor c21( entryno number ) is
 select /*+ ALL_ROWS */  count( 'x' ) tot
 from manent2
 where entry_no = entryno;

/*
 cursor c1(entryno number, tariff varchar2) is
  select distinct description
  from lov l1, detailrs dr, pos p
  where l1.cola = tariff and
        dr.entry_no = entryno and
        p.inventoryno = l1.code and
        dr.deliveryno = p.deliveryno and
        lov_name = 'INVENT';


 cursor c2(entryno number, tariff varchar2) is
  select *
  from ships_airway
  where ship_id in
   (select ship_id
   from movements m, detailrs dr, pos p, lov l1
   where entry_no = entryno and
         dr.deliveryno = p.deliveryno and
         p.inventoryno = l1.code and
         l1.lov_name = 'INVENT' and
         l1.cola = tariff and
         m.movement_no = dr.movement_no and
         nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
   );

 cursor c3( entryno number, tariff varchar2 ) is
  select nvl(sum(amount),0) sm
  from pos p, detailrs dr, lov l1
  where p.deliveryno = dr.deliveryno and
         dr.deliveryno = p.deliveryno and
         p.inventoryno = l1.code and
         l1.lov_name = 'INVENT' and
         l1.cola = tariff and
         dr.entry_no = entryno;

 cursor c4( entryno number ) is
  select ctry_countrycode
  from pos p, detailrs dr
  where p.deliveryno = dr.deliveryno and
         dr.deliveryno = p.deliveryno and
         dr.entry_no = entryno;

 cursor c5( tariff varchar2 ) is
 select  *
 from lov
 where lov_name = 'TARIFF' and
       code = tariff;

 cursor c6(entryno number, tariff varchar2 ) is
  select sum(revton * s.freight) sm
  from detailrs dr, movements m, ships_airway s, pos p, lov l1
  where dr.entry_no = entryno and
        m.movement_no = dr.movement_no and
        dr.deliveryno = p.deliveryno and
        p.inventoryno = l1.code and
        l1.lov_name = 'INVENT' and
        l1.cola = tariff and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        m.ship_id = s.ship_id;

 cursor c7( entryno number, tariff varchar2 ) is
  select sum(p.qty) qty
  from pos p, lov i
  where p.inventoryno = i.code and
        i.lov_name = 'INVENT' and
        i.cola = tariff and
        p.deliveryno in
        (select distinct deliveryno
         from detailrs
         where entry_no = entryno);

 cursor c7a( tariff varchar2 ) is
  select l2.cola
  from lov l2
  where l2.lov_name = 'TARIFF' and
        l2.code = tariff;

 cursor c8( entryno number ) is
  select *
  from ships_airway
  where ship_id in ( select ship_id
                     from movements m, detailrs dr
                     where entry_no = entryno and
                           m.movement_no = dr.movement_no and
                           nvl(m.seal,'|') = nvl(dr.camov_seal,'|'));

 cursor c9(entryno number) is
   select distinct c.customer, r.curr, d.exrate
   from receivals r, detailrs dr, customers c, duty d
   where dr.entry_no = entryno and
   	 d.entry_no = dr.entry_no and
         dr.deliveryno = r.deliveryno and
         nvl(r.supplier_customer_id,0) = c.customer_id and
         c.customer_type = 'SUPPLIER';


cursor c17( entryno number, rfrom integer, rto integer ) is
select tariff, description, colc
from
(
 select rownum rnumb, tariff, description, colc
 from
 (
  select distinct l1.cola tariff, l2.description, l2.colc
  from pos p, lov l1, lov l2
  where l1.lov_name = 'INVENT' and
        l2.lov_name = 'TARIFF' and
        l1.cola = l2.code and
        l1.code = p.inventoryno and
        p.deliveryno in
         (select distinct deliveryno
          from detailrs dr
         where dr.entry_no = entryno
        )
  )
)
where rnumb >= rfrom and rnumb < rto;

cursor c21( entryno number ) is
 select  count( distinct l1.cola ) tot
 from pos p, lov l1, detailrs dr
 where dr.entry_no = entryno and
       dr.deliveryno = p.deliveryno and
       p.inventoryno = l1.code and
       l1.lov_name = 'INVENT';
*/

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c21rec		c21%ROWTYPE;
 pagefrom	integer;
 pageto		integer;
 b1		number;
 b2		number;
 b3		number;
 b4		number;
 b5		number;
 temptot	number;
 exrate		varchar2(100);
 xb1		varchar2(100);
 xb2		varchar2(100);
 xb3		varchar2(100);
 xb4		varchar2(100);
 tmp 		varchar2(32767);
 tmp2 		varchar2(32767);
 tmp3 		varchar2(32767);


 function ispartshipment( entryno number )
  return boolean
 is

   cursor c1(entryno number) is select * from duty where entry_no = entryno;
   c1rec  c1%ROWTYPE;
 begin
  open c1(entryno);
  fetch c1 into c1rec;
  close c1;
  if nvl(c1rec.previous_entry_no,0) > 0
   then
    return( TRUE );
   else
    return( FALSE );
  end if;
 end ispartshipment;

 function tot( entryno number, tariff varchar2, ctype in varchar2 default 'CURR' )
  return number
 is

   cursor c1(entryno number) is select * from duty where entry_no = entryno;
   /*
   cursor c2(entryno number, tariff varchar2 ) is
    select sum(nvl(tamount,0))/count(dr.entry_no) tot
    from pos p, detailrs dr, lov l1
    where dr.deliveryno = p.deliveryno and
          dr.entry_no = entryno and
          l1.lov_name = 'INVENT' and
          l1.code = p.inventoryno and
          l1.cola = tariff;
   */
   cursor c2(entryno number, tariff varchar2 ) is
    select sum(nvl(tamount,0)) tot
    from pos p, lov l1
    where l1.lov_name = 'INVENT' and
          l1.code = p.inventoryno and
          l1.cola = tariff and
          p.deliveryno in
          (select distinct dr.deliveryno
           from detailrs dr
           where  dr.entry_no = entryno );

   c1rec c1%ROWTYPE;
   c2rec c2%ROWTYPE;

 begin
    open c1(entryno);
    fetch c1 into c1rec;
    close c1;
    open c2(entryno,tariff);
    fetch c2 into c2rec;
    close c2;
    if ctype = 'CURR'
     then
      return(round(c1rec.ratio_factor * c2rec.tot,2));
     else
      return(round(c2rec.tot,2));
    end if;
 end;

begin

open c3(entryno);
fetch c3 into c3rec;
close c3;

if colin = 'AX'
 then
 if mod(rnumb,10) = 1
  then
   -- Start of New Page. Calculate Header
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 5
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 5) / 10) + 2;
   end if;
   pagefrom := trunc(rnumb/10) + 2;
   if pagefrom > 2 then tmp := '<span style=''font-size:1.0pt;mso-bidi-font-size:10.0pt;font-family:Arial; mso-fareast-font-family:"Times New Roman";mso-bidi-font-family:"Times New Roman"; mso-ansi-language:EN-US;mso-fareast-language:EN-US;mso-bidi-language:AR-SA''><br clear=all style=''mso-special-character:line-break;page-break-before:always''></span>';
   end if;

   tmp := tmp ||
'<div align=center>
<h1 style=''margin-right:-49.5pt;tab-stops:decimal 432.35pt right 531.6pt''><span
lang=EN-US style=''font-size:10.0pt;font-family:Arial;mso-ansi-language:EN-US''><span
style="mso-spacerun: yes">   </span>PAPUA NEW GUINEA CUSTOMS ENTRY - FORM 15  &nbsp;&nbsp;&nbsp;&nbsp;' || htf.bold(entryno) || ' &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Continuation<span
style=''mso-tab-count:1''>                        </span></span><span lang=EN-US
style=''font-size:8.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;mso-ansi-language:
EN-US''><span style="mso-spacerun: yes"> </span></span><span lang=EN-US
style=''font-size:10.0pt;font-family:Arial;mso-ansi-language:EN-US''><span
style="mso-spacerun: yes">  </span><o:p></o:p></span></h1>

<table border=1 cellspacing=0 cellpadding=0 style=''border-collapse:collapse;
 border:none;mso-border-alt:solid windowtext .5pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt''>
 <tr style=''height:8.4pt''>
  <td rowspan="2" width=214 valign=top style=''width:128.25pt;border:solid windowtext .5pt;
  border-bottom:none;border-right:none;padding:0cm 5.4pt 0cm 5.4pt;height:8.4pt''>
  <p class=MsoNormal><sub><span style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;
  font-family:Arial;mso-bidi-font-family:"Arial";color:black''>1.
  Importer/Exporter
  <BR></sub></span>
  <sub><span style=''font-size:9pt;mso-bidi-font-size:10.0pt;
  font-family:Arial;mso-bidi-font-family:"Arial";color:black''>
  <B>' || c3rec.exporter || '<o:p></o:p></span></sub></p>
  </td>
  <td width=214 colspan=1 valign=top style=''width:128.25pt;border-top:solid windowtext .5pt;
  border-left:solid windowtext .5pt;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:8.4pt''>
  <p class=MsoNormal><sub><span style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;
  font-family:Arial;mso-bidi-font-family:"Arial";color:black''>1.
  A.Code</sub></span>
  <sub><span style=''font-size:9pt;mso-bidi-font-size:10.0pt;
  font-family:Arial;mso-bidi-font-family:"Arial";color:black''><B><BR><o:p></o:p></span></sub></p>
  </td>
  <td width=239 colspan=3 valign=top style=''width:143.3pt;border-top:solid windowtext .5pt;
  border-left:none;border-bottom:solid windowtext .5pt:none;border-right:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:8.4pt''>
  <p class=MsoNormal><sub><span style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;
  font-family:Arial;mso-bidi-font-family:"Arial";color:black''>22.
  Manifest reg. No</sub></span>
  <sub><span style=''font-size:9pt;mso-bidi-font-size:10.0pt;
  font-family:Arial;mso-bidi-font-family:"Arial";color:black''><B>&nbsp;&nbsp;&nbsp;' || c3rec.MANIFEST_LINES || '<o:p></o:p></span></sub></p>
  </td>
  <td width=231 colspan=3 valign=top style=''width:138.85pt;border-top:solid windowtext .5pt;
  border-left:none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:8.4pt''>
  <p class=MsoNormal><sub><span style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;
  font-family:Arial;mso-bidi-font-family:"Arial";color:black''>5.
  Declaration Registration<o:p></o:p></span></sub></p>
  </td>
 </tr>';
 else
   tmp := NULL;
 end if;

elsif colin = 'AX1'
 then
 if mod(rnumb,10) = 1
  then
   -- Start of New Page. Calculate Header
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 5
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 5) / 10) + 2;
   end if;
   pagefrom := trunc(rnumb/10) + 2;

   tmp := tmp || NULL;
 else
   tmp := NULL;
 end if;

elsif colin = 'AX2'
 then
 if mod(rnumb,10) = 1
  then
   -- Start of New Page. Calculate Header
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 5
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 5) / 10) + 2;
   end if;
   pagefrom := trunc(rnumb/10) + 2;

   tmp := tmp ||
'<tr style=''height:8.4pt''>
  <td valign=top style=''width:143.3pt;border:none;
  border-top:solid windowtext .5pt;border-right:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;
  height:8.4pt''>
  <p class=MsoNormal><sub><span style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;
  font-family:Arial;mso-bidi-font-family:"Arial";color:black''>&nbsp;
  <o:p></o:p></span></sub></p>
  </td>
  <td width=239 colspan=3 valign=top style=''width:143.3pt;border:none;
  border-top:solid windowtext .5pt;border-right:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:8.4pt''>
  <p class=MsoNormal><sub><span style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;
  font-family:Arial;mso-bidi-font-family:"Arial";color:black''>29. BL/AWB No.</sub></span>
  <sub><span style=''font-size:9pt;mso-bidi-font-size:10.0pt;
  font-family:Arial;mso-bidi-font-family:"Arial";color:black''>
  <B>&nbsp;&nbsp;&nbsp;&nbsp; ' || c3rec.bill_of_lading ||
  '<o:p></o:p></span></sub></p>
  </td>
  <td width=231 colspan=3 valign=top style=''width:138.85pt;border:none;
  border-right:solid windowtext .5pt;border-top:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:8.4pt''>
  <p class=MsoNormal><sub><span style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;
  font-family:Arial;mso-bidi-font-family:"Arial";color:black''>8.</sub></span>
  <sub><span style=''font-size:9pt;mso-bidi-font-size:10.0pt;
  font-family:Arial;mso-bidi-font-family:"Arial";color:black''>
  <B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; PAGE ' || to_char(pagefrom) || ' of ' || to_char(pageto) ||'</B><o:p></o:p></span></sub></p>
  </td>
 </tr>
 <tr style=''height:2.1pt''>
  <td width=381 colspan=2 rowspan=6 style=''width:228.5pt;border:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.1pt''>
  <p class=MsoNormal align=center style=''text-align:center''><span lang=EN-US
  style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  color:purple;mso-ansi-language:EN-US''>8. Goods Description<o:p></o:p></span></p>
  </td>
  <td width=63 rowspan=6 style=''width:38.0pt;border:solid windowtext .5pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.1pt''>
  <p class=MsoNormal align=center style=''text-align:center''><span lang=EN-US
  style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  color:purple;mso-ansi-language:EN-US''>29. Origin<o:p></o:p></span></p>
  </td>
  <td width=118 rowspan=6 style=''width:70.85pt;border:solid windowtext .5pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.1pt''>
  <p class=MsoNormal align=center style=''text-align:center''><span lang=EN-US
  style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  color:purple;mso-ansi-language:EN-US''>30. Commodity Code<o:p></o:p></span></p>
  </td>
  <td width=158 rowspan=6 style=''width:94.6pt;border:solid windowtext .5pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.1pt''>
  <p class=MsoNormal align=center style=''text-align:center''><span lang=EN-US
  style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  color:purple;mso-ansi-language:EN-US''>31. Quantities<o:p></o:p></span></p>
  </td>
  <td width=204 colspan=3 valign=top style=''width:122.3pt;border:solid windowtext .5pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.1pt''>
  <p class=MsoNormal style=''margin-left:16.7pt''><span lang=EN-US
  style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  color:purple;mso-ansi-language:EN-US''>32 A. Value in Frgn Currency<o:p></o:p></span></p>
  </td>
 </tr>';
 else
   tmp := NULL;
 end if;

elsif colin = 'AY'
 then
 if mod(rnumb,10) = 1
  then
   -- Start of New Page. Calculate Header
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 5
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 5) / 10) + 2;
   end if;
   pagefrom := trunc(rnumb/10) + 2;
   tmp :=
   '
 <tr style=''height:2.1pt''>
  <td width=204 colspan=3 valign=top style=''width:122.3pt;border-top:none;
  border-left:none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.1pt''>
  <p class=MsoNormal style=''margin-left:25.7pt''><span lang=EN-US
  style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  color:purple;mso-ansi-language:EN-US''>B. Value in Kina<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style=''height:2.1pt''>
  <td width=204 colspan=3 valign=top style=''width:122.3pt;border-top:none;
  border-left:none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.1pt''>
  <p class=MsoNormal style=''margin-left:25.7pt''><span lang=EN-US
  style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  color:purple;mso-ansi-language:EN-US''>C. Customs Duty<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style=''height:2.1pt''>
  <td width=204 colspan=3 valign=top style=''width:122.3pt;border-top:none;
  border-left:none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.1pt''>
  <p class=MsoNormal style=''margin-left:25.7pt''><span lang=EN-US
  style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  color:purple;mso-ansi-language:EN-US''>D. Excise Duty<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style=''height:2.1pt''>
  <td width=204 colspan=3 valign=top style=''width:122.3pt;border-top:none;
  border-left:none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.1pt''>
  <p class=MsoNormal style=''margin-left:25.7pt''><span lang=EN-US
  style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  color:purple;mso-ansi-language:EN-US''>E. VAT<o:p></o:p></span></p>
  </td>
 </tr>
  <tr style=''height:2.1pt''>
  <td width=204 colspan=3 valign=top style=''width:122.3pt;border-top:none;
  border-left:none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.1pt''>
  <p class=MsoNormal style=''margin-left:25.7pt''><span lang=EN-US
  style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  color:purple;mso-ansi-language:EN-US''>F. Mining Levy<o:p></o:p></span></p>
  </td>
 </tr>';

 else
   tmp := NULL;
 end if;

elsif colin = 'A'
 then
  open c1(entryno,vrno);
  fetch c1 into c1rec;
  close c1;
  tmp2 := c1rec.description1 || htf.nl || c1rec.description2 || htf.nl || c1rec.description3;
 tmp :=
 '<tr style=''height:10pt''>
  <td width=381 colspan=2 rowspan=6 valign=top style=''width:228.5pt;border:
  solid windowtext .5pt;border-top:none;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:10pt''>
  <p class=MsoNormal><span
  lang=EN-US style=''font-size:8.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  mso-ansi-language:EN-US''>' || tmp2 || '<o:p></o:p></span></p>
  </td>';

elsif colin = 'B'
 then
  open c1(entryno,vrno);
  fetch c1 into c1rec;
  close c1;
tmp :=
 '<td width=63 rowspan=6 valign=top style=''width:38.0pt;border-top:none;
  border-left:none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:10pt''>
  <p class=MsoNormal><span
  lang=EN-US style=''font-size:8.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  mso-ansi-language:EN-US''>' || c1rec.origin || '<o:p></o:p></span></p>
  </td>';

elsif colin = 'C'
 then
 if tariff is not null
  then
    open c1(entryno,vrno);
    fetch c1 into c1rec;
    close c1;
     tmp2 := c1rec.tariff || htf.nl || 'DUTY ' || to_char(to_number(c1rec.rate),'990.99') || '%';
     if to_number(nvl(c1rec.excise_rate,'0') ) > 0
      then
       tmp2 := tmp2 || htf.nl || 'EXCISE ' || to_char(to_number(c1rec.excise_rate),'990.99') || '%';
      else
       tmp2 := tmp2 || htf.nl;
     end if;
     tmp2 := tmp2 || htf.nl || '
     ';
     if nvl(to_number(c1rec.vat_rate),0) > 0
      then
       tmp2 := tmp2 || 'VAT ' || to_char(to_number(c1rec.vat_rate),'990.99') || '%';
     end if;
   else
    tmp2 := NULL;
 end if;
tmp :=
 '<td width=118 rowspan=6 valign=top style=''width:70.85pt;border-top:none;
  border-left:none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:10pt''>
  <p class=MsoNormal><span
  lang=EN-US style=''font-size:8.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  mso-ansi-language:EN-US''>' || tmp2 || '<o:p></o:p></span></p>
  </td>';

elsif colin = 'D'
 then
 if tariff is not null
  then
   open c1(entryno,vrno);
   fetch c1 into c1rec;
   close c1;
    if c1rec.unit is null
     then
      tmp2 := 'Net Weight(Kg)' || htf.nl || htf.nl || htf.line || 'Suppl. Qty/Ucm';
     elsif c1rec.unit in ('TONNE','METRES','METRE','TON')
      then
      tmp2 := 'Net Weight(Kg)' || htf.nl || c1rec.quantity || ' ' || c1rec.unit || htf.nl || htf.line || 'Suppl. Qty/Ucm';
     else
      tmp2 := 'Net Weight(Kg)' || htf.nl || htf.nl || htf.line || 'Suppl. Qty/Ucm' || htf.nl || c1rec.quantity || ' ' || c1rec.unit;
    end if;
  else
   tmp2 := '&nbsp;';
 end if;
tmp :=
 '<td width=158 rowspan=6 valign=top style=''width:94.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:10pt''>
  <p class=MsoNormal><span
  lang=EN-US style=''font-size:8.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  mso-ansi-language:EN-US''>' || tmp2 || '<o:p></o:p></span></p>
  </td>';

elsif colin = 'E'
 then
   open c1(entryno,vrno);
   fetch c1 into c1rec;
   close c1;
  if tariff is not null
   then
    tmp2 := to_char(c1rec.value,'999999990.99');
   else
    tmp2 := NULL;
  end if;
tmp :=
 '<td width=32 colspan=2 style=''width:19.4pt;border:none;border-bottom:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:10pt''>
  <p class=MsoNormal><span lang=EN-US style=''font-size:6.5pt;mso-bidi-font-size:
  10.0pt;font-family:Arial;color:purple;mso-ansi-language:EN-US''>A<o:p></o:p></span></p>
  </td>
  <td width=172 style=''width:102.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:10pt''>
  <p class=MsoNormal align=right style=''text-align:right''><span
  lang=EN-US style=''font-size:9.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  mso-ansi-language:EN-US''>' || tmp2 || '<o:p></o:p></span></p>
  </td>
 </tr>';

  if tariff is not null
   then
   open c1(entryno,vrno);
   fetch c1 into c1rec;
   close c1;
    tmp2 := to_char(c1rec.kinavalue,'999999990.99');
   else
    tmp2 := NULL;
  end if;
tmp := tmp ||
 ' <tr style=''height:10pt''>
  <td width=32 colspan=2 style=''width:19.4pt;border:none;border-bottom:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:10pt''>
  <p class=MsoNormal><span lang=EN-US style=''font-size:6.5pt;mso-bidi-font-size:
  10.0pt;font-family:Arial;color:purple;mso-ansi-language:EN-US''>B<o:p></o:p></span></p>
  </td>
  <td width=172 style=''width:102.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:10pt''>
  <p class=MsoNormal align=right style=''text-align:right''><span
  lang=EN-US style=''font-size:9.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  mso-ansi-language:EN-US''>' || tmp2 || '<o:p></o:p></span></p>
  </td>
 </tr>';

elsif colin = 'F'
 then
  if tariff is not null
   then
    open c1(entryno,vrno);
    fetch c1 into c1rec;
    close c1;
    tmp2 := to_char(round(c1rec.duty,2),'999999990.99');
   else
    tmp2 := NULL;
  end if;
tmp :=
 ' <tr style=''height:10pt''>
  <td width=32 colspan=2 style=''width:19.4pt;border:none;border-bottom:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:10pt''>
  <p class=MsoNormal><span lang=EN-US style=''font-size:6.5pt;mso-bidi-font-size:
  10.0pt;font-family:Arial;color:purple;mso-ansi-language:EN-US''>C<o:p></o:p></span></p>
  </td>
  <td width=172 style=''width:102.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:10pt''>
  <p class=MsoNormal align=right style=''text-align:right''><span
  lang=EN-US style=''font-size:9.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  mso-ansi-language:EN-US''>' || tmp2 || '<o:p></o:p></span></p>
  </td>
 </tr>';

elsif colin = 'G'
 then

  if tariff is not null
   then
    open c1(entryno,vrno);
    fetch c1 into c1rec;
    close c1;
    tmp2 := to_char(round( c1rec.excise,2),'999999990.99');
   else
    tmp2 := NULL;
  end if;
tmp :=
 ' <tr style=''height:10pt''>
  <td width=32 colspan=2 style=''width:19.4pt;border:none;border-bottom:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:10pt''>
  <p class=MsoNormal><span lang=EN-US style=''font-size:6.5pt;mso-bidi-font-size:
  10.0pt;font-family:Arial;color:purple;mso-ansi-language:EN-US''>D<o:p></o:p></span></p>
  </td>
  <td width=172 style=''width:102.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:10pt''>
  <p class=MsoNormal align=right style=''text-align:right''><span
  lang=EN-US style=''font-size:9.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  mso-ansi-language:EN-US''>' || tmp2 || '<o:p></o:p></span></p>
  </td>
 </tr>';

elsif colin = 'H'
 then
  if tariff is not null
   then
    open c1(entryno,vrno);
    fetch c1 into c1rec;
    close c1;
    tmp2 := to_char( round(c1rec.vat, 2), '999999990.99');
    tmp3 := to_char( round(c1rec.levy, 2), '999999990.99');

/*    tmp3 := '0';
      tmp3 := to_char(((round(c1rec.kinavalue,2) + round(c1rec.duty,2) + round( c1rec.excise,2))*0.02),'999999990.99');

2% LEVY CALCULATION ABOVE IN TMP3
INCLUDE BELOW LINE IF NOT GOING TO USE LEVY
    tmp3 := NULL;
*/
    else
     tmp2 := NULL;
     tmp3 := NULL;
   end if;

tmp :=
 ' <tr style=''height:10pt''>
  <td width=32 colspan=2 style=''width:19.4pt;border:none;border-bottom:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:10pt''>
  <p class=MsoNormal><span lang=EN-US style=''font-size:6.5pt;mso-bidi-font-size:
  10.0pt;font-family:Arial;color:purple;mso-ansi-language:EN-US''>E<o:p></o:p></span></p>
  </td>
  <td width=172 style=''width:102.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:10pt''>
  <p class=MsoNormal align=right style=''text-align:right''><span
  lang=EN-US style=''font-size:9.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  mso-ansi-language:EN-US''>' || tmp2 || '<o:p></o:p></span></p>
  </td>
 </tr>
  <tr style=''height:10pt''>
  <td width=32 colspan=2 style=''width:19.4pt;border:none;border-bottom:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:10pt''>
  <p class=MsoNormal><span lang=EN-US style=''font-size:6.5pt;mso-bidi-font-size:
  10.0pt;font-family:Arial;color:purple;mso-ansi-language:EN-US''>F<o:p></o:p></span></p>
  </td>
  <td width=172 style=''width:102.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:10pt''>
  <p class=MsoNormal align=right style=''text-align:right''><span
  lang=EN-US style=''font-size:9.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  mso-ansi-language:EN-US''>' || tmp3 || '<o:p></o:p></span></p>
  </td>
 </tr>';

elsif colin = 'I'
 then
if mod(rnumb,10) = 0
then
tmp :=
 '';
end if;

elsif colin = 'IX'
 then
if mod(rnumb,10) = 0
then
tmp :=
'';
 end if;

elsif colin = 'J'
 then
if mod(rnumb,10) = 0
then
    tmp :=
 '';
end if;

elsif colin = 'K'
 then
if mod(rnumb,10) = 0
then
    tmp :=
'';
 end if;

elsif colin = 'KX'
 then
if mod(rnumb,10) = 0
then
    tmp := tmp ||
'';
 end if;

elsif colin = 'KY'
 then
 if mod(rnumb,10) = 0
  then
   -- Last Element on the Page, produce the summary page total
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 5
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 5) / 10) + 2;
   end if;
   pagefrom := trunc(rnumb/10) + 1;

   exrate := to_char(c3rec.exchange_rate,'999,999.9999');
 /*

   b1 := 0;
   b2 := 0;
   b1 := 0;

   for c17rec in c17(entryno,((pagefrom -1)*10) - 5,((pagefrom -1)*10) + 5) loop
      temptot := tot(entryno,c17rec.tariff);
      b1 := nvl(b1,0) + temptot * (nvl(to_number(c17rec.description),0)/100);
      b2 := nvl(b2,0) + ((temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100));
      b3 := nvl(b3,0) +
       (temptot +
          temptot * (nvl(to_number(c17rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;

   b4 := b1 + b2 + b3;
   xb1 := to_char(b1,'99999999.99'); -- Total B - Customs Duty
   xb2 := to_char(b2,'99999999.99'); -- Total C - Excise Duty
   xb3 := to_char(b3,'99999999.99'); -- Total D - Vat
   --xb4 := to_char(b4,'99999999.99'); -- Total B+C+D
 */

  tmp :=
  '<tr style=''height:10pt''>
  <td width=562 colspan=4 rowspan=1 valign=top style=''width:337.35pt;
  border-top:none;border-left:solid windowtext .5pt;border-bottom:none;
  border-right:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:10pt''>
  <p class=MsoNormal><span lang=EN-US style=''font-size:6.5pt;mso-bidi-font-size:
  10.0pt;font-family:Arial;color:black;mso-ansi-language:EN-US''>EXCHANGE RATE : ' || exrate || '<BR>33. I/We
  hereby declare that the information and particular herein are true and
  correct<o:p></o:p></span></p>
  </td>
  <td COLSPAN="4" width=362 style=''width:94.6pt;border-top:none;border-left:none;
  border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:10pt''>
  <p class=MsoNormal style=''tab-stops:14.7pt''><span lang=EN-US
  style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  color:purple;mso-ansi-language:EN-US''>34. <span style=''mso-tab-count:1''>  </span>TOTAL
  CUSTOMS, EXCISE, VAT & LEVY DUTY<o:p></o:p></span></p>
  </td>
 </tr>';
 end if;

elsif colin = 'KZ'
 then
 if mod(rnumb,10) = 0
  then
   -- Last Element on the Page, produce the summary page total
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 5
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 5) / 10) + 2;
   end if;
   pagefrom := trunc(rnumb/10) + 1;


   b1 := 0;
   b2 := 0;
   b3 := 0;
   b4 := 0;
   b5 := 0;
   for c17rec in c17(entryno,((pagefrom -1)*10) - 5,((pagefrom -1)*10) + 5) loop
      b1 := nvl(b1,0) + c17rec.duty;
      b2 := nvl(b2,0) + c17rec.excise;
      b3 := nvl(b3,0) + c17rec.vat;
      b4 := nvl(b4,0) + c17rec.sm;
   end loop;

   --xb1 := to_char(b1,'99999999.99'); -- Total B - Customs Duty
   --xb2 := to_char(b2,'99999999.99'); -- Total C - Excise Duty
   --xb3 := to_char(b3,'99999999.99'); -- Total D - Vat
   xb4 := to_char(b1+b2+b3+b4,'99999999.99'); -- Total C+D+E

tmp := tmp ||
' <tr style=''height:10pt''>
  <td width=562 colspan=4 valign=top style=''width:337.35pt;border-top:none;
  border-left:solid windowtext .5pt;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:10pt''>
  <p class=MsoNormal><span lang=EN-US style=''font-size:6.5pt;mso-bidi-font-size:
  10.0pt;font-family:Arial;color:black;mso-ansi-language:EN-US''>Signature</span><span
  lang=EN-US style=''font-size:9.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  color:black;mso-ansi-language:EN-US''>
  ' || strang.f15_parameter_range_manent( 'SIG', entryno, WEBSYS.OLTP.F_USER_SITE) || '
  <p class=MsoNormal><span lang=EN-US style=''font-size:6.5pt;mso-bidi-font-size:
    10.0pt;font-family:Arial;color:black;mso-ansi-language:EN-US''>Name ' || c3rec.agent ||
    '  Position ' || c3rec.position || '</span><span
    lang=EN-US style=''font-size:9.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;
    color:black;mso-ansi-language:EN-US''><span style="mso-spacerun: yes">
  </span><o:p></o:p></span></p>

  </td>
  <td width=158 style=''width:94.6pt;border-top:none;border-left:none;
  border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:10pt''>
  <p class=MsoNormal style=''margin-left:14.7pt''><span lang=EN-US
  style=''font-size:6.5pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  color:purple;mso-ansi-language:EN-US''>Total C+D+E+F (This page)<o:p></o:p></span></p>
  </td>
  <td width=204 colspan=3 style=''width:122.3pt;border-top:none;border-left:
  none;border-bottom:solid windowtext .5pt;border-right:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:10pt''>
  <p class=MsoNormal align=right style=''text-align:right''><span
  lang=EN-US style=''font-size:9.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;
  mso-ansi-language:EN-US''>' || xb4 || '<o:p></o:p></span></p>
  </td>
 </tr>

</table>';
end if;

elsif colin = 'L'
 then
  -- Calculate Total Number of Rows for rownum rounded up to the nearest 10
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   c21rec.tot := ((trunc((c21rec.tot - 5) / 10) + 1) * 10) + 1;
   return( to_char(c21rec.tot) );

elsif colin = 'M'
 then
  -- Calculate Total Number of Rows
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   c21rec.tot := c21rec.tot - 4;
   return( to_char(c21rec.tot) );

elsif colin = 'N'
 then
  -- Calculate Total Number of Rows
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   return( to_char(c21rec.tot) );

end if;


return( tmp );
exception
 when others then return( sqlerrm );
end form_15_continue_manent;
/


GRANT EXECUTE ON STRANG.FORM_15_CONTINUE_MANENT TO WEBSYS;
