CREATE OR REPLACE function STRANG.form_15_continue(colin varchar2, entryno in number, tariff in varchar2, rnumb in integer default null, vtot in integer)
 return varchar2
as

 cursor c1(entryno number, tariff varchar2) is
  select /*+ ALL_ROWS */ distinct description
  from lov l1, detailrs dr, pos p
  where l1.cola = tariff and
        dr.entry_no = entryno and
        p.inventoryno = l1.code and
        dr.deliveryno = p.deliveryno and
        lov_name = 'INVENT';


 cursor c2(entryno number, tariff varchar2) is
  select /*+ ALL_ROWS */ *
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
  select /*+ ALL_ROWS */ nvl(sum(amount),0) sm
  from pos p, detailrs dr, lov l1
  where p.deliveryno = dr.deliveryno and
         dr.deliveryno = p.deliveryno and
         p.inventoryno = l1.code and
         l1.lov_name = 'INVENT' and
         l1.cola = tariff and
         dr.entry_no = entryno;

 cursor c4( entryno number ) is
  select /*+ ALL_ROWS */ ctry_countrycode
  from pos p, detailrs dr
  where p.deliveryno = dr.deliveryno and
         dr.deliveryno = p.deliveryno and
         dr.entry_no = entryno;

 cursor c5( tariff varchar2 ) is
 select  /*+ ALL_ROWS */ *
 from lov
 where lov_name = 'TARIFF' and
       code = tariff;

 cursor c6(entryno number, tariff varchar2 ) is
  select /*+ ALL_ROWS */ sum(revton * s.freight) sm
  from detailrs dr, movements m, ships_airway s, pos p, lov l1
  where dr.entry_no = entryno and
        m.movement_no = dr.movement_no and
        dr.deliveryno = p.deliveryno and
        p.inventoryno = l1.code and
        l1.lov_name = 'INVENT' and
        l1.cola = tariff and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        m.ship_id = s.ship_id;

 /*
 cursor c7( entryno number, tariff varchar2 ) is
  select sum(p.qty) qty
  from pos p, detailrs dr, lov l1, lov l2
  where p.deliveryno = dr.deliveryno and
         dr.deliveryno = p.deliveryno and
         p.inventoryno = l1.code and
         l1.lov_name = 'INVENT' and
         l2.lov_name = 'TARIFF' and
         l1.cola = l2.code and
         l2.code = tariff and
         dr.entry_no = entryno
 group by l2.cola;
 */

 cursor c7( entryno number, tariff varchar2 ) is
  select /*+ ALL_ROWS */ sum(p.qty) qty
  from pos p, lov i
  where p.inventoryno = i.code and
        i.lov_name = 'INVENT' and
        i.cola = tariff and
        p.deliveryno in
        (select distinct deliveryno
         from detailrs
         where entry_no = entryno);

 cursor c7a( tariff varchar2 ) is
  select /*+ ALL_ROWS */ l2.cola
  from lov l2
  where l2.lov_name = 'TARIFF' and
        l2.code = tariff;

 cursor c7b( entryno number ) is
  select /*+ ALL_ROWS */ sum(dr.partweight) weight
  from detailrs dr
  where dr.entry_no = entryno;


 cursor c8( entryno number ) is
  select /*+ ALL_ROWS */ *
  from ships_airway
  where ship_id in ( select ship_id
                     from movements m, detailrs dr
                     where entry_no = entryno and
                           m.movement_no = dr.movement_no and
                           nvl(m.seal,'|') = nvl(dr.camov_seal,'|'));

 cursor c9(entryno number) is
   select /*+ ALL_ROWS */ distinct c.customer, r.curr, d.exrate
   from receivals r, detailrs dr, customers c, duty d
   where dr.entry_no = entryno and
   	 d.entry_no = dr.entry_no and
         dr.deliveryno = r.deliveryno and
         nvl(r.supplier_customer_id,0) = c.customer_id and
         c.customer_type = 'SUPPLIER';

 cursor c10(entryno number) is
   select /*+ ALL_ROWS */ distinct c.customer, c.levy_rate, c.vat, c.rate, c.customer_id, d.exrate
   from receivals r, detailrs dr, customers c, duty d
   where dr.entry_no = entryno and
         dr.deliveryno = r.deliveryno and
         nvl(r.cust_customer_id,0) = c.customer_id and
         c.customer_type = 'CUSTOMER';


cursor c17( entryno number, rfrom integer, rto integer ) is
select tariff, description, colc
from
(
 select rownum rnumb, tariff, description, colc
 from
 (
  select /*+ ALL_ROWS */ distinct l1.cola tariff, l2.description, l2.colc
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

cursor c18( entryno number ) is
select tariff, description, colc
from
(
 select rownum rnumb, tariff, description, colc
 from
 (
  select /*+ ALL_ROWS */ distinct l1.cola tariff, l2.description, l2.colc
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
);


cursor c21( entryno number ) is
 select /*+ ALL_ROWS */  count( distinct l1.cola ) tot
 from pos p, lov l1, detailrs dr
 where dr.entry_no = entryno and
       dr.deliveryno = p.deliveryno and
       p.inventoryno = l1.code and
       l1.lov_name = 'INVENT';

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c7arec		c7a%ROWTYPE;
 c7brec		c7b%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c9rec		c9%ROWTYPE;
 c10rec		c10%ROWTYPE;
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
 xb5		varchar2(100);
 tmp 		varchar2(32767);
 tmp2 		varchar2(32767);
 tmp3		varchar2(32767);
 tmp4 		number;
 tmp5		number;
 tmp6 		number;
 tmp7		number;
 tmp8		varchar2(32767);
 tmp9 		varchar2(32767);
 tmp10		varchar2(32767);
 ttl		number;

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
if colin = 'AX'
 then
  if rnumb = 1 then strang_global.GLOBAL_VARS.delete; end if;
  strang_global.GLOBAL_VARS(rnumb).rnumb := rnumb;
  strang_global.GLOBAL_VARS(rnumb).entryno := entryno;
  strang_global.GLOBAL_VARS(rnumb).tariff := tariff;
end if;

if colin = 'AX'
 then
 if mod(rnumb,3) = 1
  then
   -- Start of New Page. Calculate Header
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc((rnumb - 2) / 3) + 2;

   if pagefrom > 2
     then
     tmp := '<span style=''font-size:1.0pt;mso-bidi-font-size:10.0pt;font-family:Arial; mso-fareast-font-family:"Times New Roman";mso-bidi-font-family:"Times New Roman"; mso-ansi-language:EN-US;mso-fareast-language:EN-US;mso-bidi-language:AR-SA''><br clear=all style=''mso-special-character:line-break;page-break-before:always''></span>';
   end if;

   tmp := tmp ||
'<div align=center>
<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=625
 style=''width:469.05pt;border-collapse:collapse;border:none''>
 <tr style=''height:7.7pt''>
  <td width=334 colspan=13 rowspan=2 style=''width:250.25pt;border-top:solid windowtext 1.0pt;
  border-left:solid windowtext 1.0pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:7.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>PAPUA
  NEW GUINEA CUSTOMS </span></b></p>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>CUSTOMS
  DECLARATION  (continuation page)</span></b></p>
  </td>
  <td width=129 colspan=7 style=''width:96.4pt;border:solid windowtext 1.0pt;
  border-left:none;background:#CCCCCC;padding:0cm 5.35pt 0cm 5.35pt;height:
  7.7pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
  <td width=163 colspan=10 style=''width:122.4pt;border:solid windowtext 1.0pt;
  border-left:none;background:#CCCCCC;padding:0cm 5.35pt 0cm 5.35pt;height:
  7.7pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>A OFFICE
  OF DECLARATION</span></p>
  </td>
 </tr>
 <tr style=''height:9.65pt''>
  <td width=129 colspan=7 style=''width:96.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:9.65pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>1.  
  DECLARATION</span></p>
  </td>
  <td width=71 colspan=6 style=''width:53.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:9.65pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Office
  code </span></p>
  </td>
  <td width=92 colspan=4 style=''width:68.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:9.65pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
 </tr>
';
 else
   tmp := NULL;
 end if;

elsif colin = 'AX1'
 then
 if mod(rnumb,3) = 1
  then
   -- Start of New Page. Calculate Header
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc((rnumb - 2) / 3) + 2;
   tmp2 := f15_parameter_range( 'A5', entryno, null);
   tmp3 := f15_parameter_range( 'AHH', entryno, null);

   tmp := tmp ||
' <tr style=''height:10.5pt''>
  <td width=66 rowspan=4 style=''width:49.15pt;border:solid windowtext 1.0pt;
  border-bottom:none;padding:0cm 5.35pt 0cm 5.35pt;height:10.5pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
  <td width=183 colspan=7 style=''width:137.05pt;border:solid windowtext 1.0pt;
  border-left:none;background:white;padding:0cm 5.35pt 0cm 5.35pt;height:10.5pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>8.
  Importer                           TC N°:</span></p>
  </td>
  <td width=85 colspan=5 style=''width:64.05pt;border:solid windowtext 1.0pt;
  border-left:none;background:white;padding:0cm 5.35pt 0cm 5.35pt;height:10.5pt''>
  <p class=MsoNormal><B><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></p>
  </td>
  <td width=129 colspan=7 style=''width:96.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:10.5pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''><B>IM4 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'|| tmp3 ||'</B></span></p>
  </td>
  <td width=71 colspan=6 style=''width:53.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:10.5pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>OfficeName</span></p>
  </td>
  <td width=92 colspan=4 style=''width:68.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:10.5pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''> </span></p>
  </td>
 </tr>';
 else
   tmp := NULL;
 end if;


elsif colin = 'AX2'
 then
 if mod(rnumb,3) = 1
  then
   -- Start of New Page. Calculate Header
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc((rnumb - 2) / 3) + 2;
   open c10(entryno);
   fetch c10 into c10rec;
   close c10;
   tmp2 := f15_parameter_range( 'A6', entryno, c10rec.customer);
   tmp3 := f15_parameter_range( 'A6X', entryno,c10rec.customer);

 tmp := tmp ||
  '<tr style=''height:12.15pt''>
  <td width=268 colspan=12 style=''width:201.1pt;border:none;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.15pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>
  '|| tmp2 ||'</span></b></p>
  </td>
  <td width=129 colspan=7 style=''width:96.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.15pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>  </span></b></p>
  </td>
  <td width=71 colspan=6 style=''width:53.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.15pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Manifest
  n°       </span></p>
  </td>
  <td width=92 colspan=4 style=''width:68.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.15pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
 </tr>
 <tr style=''height:12.6pt''>
  <td width=268 colspan=12 style=''width:201.1pt;border:none;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.6pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>
  '|| tmp3 ||'</span></b></p>
  </td>
  <td width=70 colspan=3 style=''width:52.85pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.6pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>3.  Pages</span></p>
  </td>
  <td width=58 colspan=4 style=''width:43.55pt;border:solid windowtext 1.0pt;
  border-left:none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:
  12.6pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>4.</span></p>
  </td>
  <td width=71 colspan=6 style=''width:53.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.6pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Registration</span></p>
  </td>
  <td width=92 colspan=4 style=''width:68.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.6pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
 </tr>
';
 else
   tmp := NULL;
 end if;


elsif colin = 'AY'
 then
 if mod(rnumb,3) = 1
  then
   -- Start of New Page. Calculate Header
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc(rnumb / 3) + 2;
   open c10(entryno);
   fetch c10 into c10rec;
   close c10;
   tmp2 := f15_parameter_range( 'A6XX', entryno, c10rec.customer);

   tmp := tmp ||
  ' <tr style=''height:14.25pt''>
  <td width=268 colspan=12 style=''width:201.1pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:14.25pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>
  '|| tmp2 ||'</span></b></p>
  </td>
  <td width=70 colspan=3 style=''width:52.85pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:14.25pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>' || to_char(pagefrom) || ' of ' || to_char(pageto) ||'
  </span></b></p>
  </td>
  <td width=58 colspan=4 style=''width:43.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#E0E0E0;padding:0cm 5.35pt 0cm 5.35pt;height:14.25pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
  <td width=71 colspan=6 style=''width:53.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:14.25pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Date</span></p>
  </td>
  <td width=92 colspan=4 style=''width:68.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:14.25pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>
  </span></p>
  </td>
 </tr>
';
 else
   tmp := NULL;
 end if;


-- continuation page items 31 through to 46


elsif colin = 'CPA'
 then
 tmp :=
 '
 <tr style=''height:8.4pt''>
  <td width=66 style=''width:49.15pt;border:solid windowtext 1.0pt;border-bottom:
  none;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>31.</span></p>
  </td>
  <td width=268 colspan=12 style=''width:201.1pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''> </span></p>
  </td>
  <td width=70 colspan=3 style=''width:52.85pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>32.  Item  </span></p>
  </td>
  <td width=221 colspan=14 style=''width:165.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>33.
  Commodity code</span></p>
  </td>
 </tr>
';

elsif colin = 'CPB'
 then
   if tariff is not null
    then
      tmp2 := 'MANIFEST LINE/S: '||f15_parameter_range( 'AT', entryno, null);
     else
      tmp2 := '&nbsp;';
   end if;
   if tariff is not null
    then
      tmp3 := rnumb;
     else
      tmp3 := '&nbsp;';
   end if;

tmp :=
'
 <tr style=''height:16.8pt''>
  <td width=66 rowspan=8 style=''width:49.15pt;border:solid windowtext 1.0pt;
  border-bottom:none;border-top:none;padding:0cm 5.35pt 0cm 5.35pt;height:16.8pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Packages
  and Description of goods</span></p>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>         </span></p>
  </td>
  <td width=104 colspan=3 style=''width:78.15pt;border:none;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.8pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Marks
  &amp; nos. on packages </span></p>
  </td>
  <td width=164 colspan=9 style=''width:122.95pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:none;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:16.8pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=34 colspan=2 style=''width:25.75pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:16.8pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=36 style=''width:27.1pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
  padding:0cm 5.35pt 0cm 5.35pt;height:16.8pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>N°.</span></p>
  </td>
';


elsif colin = 'CPC'
 then
 if tariff is not null
  then
   open c5(tariff);
   fetch c5 into c5rec;
   close c5;
   open c2(entryno,tariff);
   fetch c2 into c2rec;
   close c2;
   tmp2 := tariff;
  else
   tmp2 := '&nbsp;';
  end if;
  if tariff is not null
   then
     tmp3 := f15_parameter_range( 'AWW', entryno, null);
    else
     tmp3 := '&nbsp;';
    end if;

tmp :=
  '
  <td width=221 colspan=14 style=''width:165.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:16.8pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
 </tr>
 <tr style=''height:2.1pt''>
  <td width=104 colspan=3 style=''width:78.15pt;border:solid windowtext 1.0pt;border-bottom:none;border-top:none;
  border-left:none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:
  2.1pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
  <td width=234 colspan=12 style=''width:175.8pt;border:solid windowtext 1.0pt;border-bottom:none;
  border-left:none;padding:0cm 5.35pt 0cm 5.35pt;height:2.1pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=73 colspan=7 style=''width:54.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:2.1pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>34.
  Cty.Origin</span></p>
  </td>
  <td width=97 colspan=4 style=''width:73.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:2.1pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>35. Gr.
  mass kg</span></p>
  </td>';

elsif colin = 'CPD'
 then
 if tariff is not null
  then
   tmp2 := f15_parameter_range( 'AWWW', entryno, null);
 else
   tmp2 := '&nbsp;';
 end if;

tmp:='
  <td width=51 colspan=3 style=''width:38.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:2.1pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>36.Pref</span></p>
  </td>
 </tr>
 <tr style=''height:6.7pt''>
  <td width=104 colspan=3 style=''width:78.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''> No/kind
  of pkgs </span></p>
  </td>
  <td width=234 colspan=12 style=''width:175.8pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=13 style=''width:10.1pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
  padding:0cm 2.8pt 0cm 2.8pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>a</span></p>
  </td>';

elsif colin = 'CPE'
 then
 if tariff is not null
  then
   open c7(entryno,tariff);
   fetch c7 into c7rec;
   close c7;
   open c7b(entryno);
   fetch c7b into c7brec;
   close c7b;
   if c7brec.weight is null
    then
     tmp2 := '&nbsp;';
   else
     tmp2 := c7brec.weight || ' kg';
   end if;
  else
   tmp2 := '&nbsp;';
 end if;

  if tariff is not null
   then
    open c4(entryno);
    fetch c4 into c4rec;
    close c4;
  else
   c4rec.ctry_countrycode := ' ';
  end if;


tmp :=
 '
  <td width=35 colspan=2 style=''width:25.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 2.8pt 0cm 2.8pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=25 colspan=4 style=''width:18.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 2.8pt 0cm 2.8pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| c4rec.ctry_countrycode ||'</span></b></p>
  </td>
  <td width=97 colspan=4 style=''width:73.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 2.8pt 0cm 2.8pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=51 colspan=3 style=''width:38.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 2.8pt 0cm 2.8pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
 </tr>';


elsif colin = 'CPF'
 then

tmp :=
'
 <tr style=''height:6.7pt''>
  <td width=339 colspan=15 style=''width:253.95pt;border-top:none;border-left:
  none;border-bottom:none;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Container
  N°(s) </span></p>
  </td>
  <td width=73 colspan=7 style=''width:54.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>37.Procedure</span></p>
  </td>
  <td width=97 colspan=4 style=''width:73.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>38. Net
  mass kg</span></p>
  </td>
  <td width=51 colspan=3 style=''width:38.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#CCCCCC;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>39.  </span></p>
  </td>
 </tr>
';


elsif colin = 'CPG'
 then
  if tariff is not null
   then
    tmp2 := f15_parameter_range( 'AWWWW', entryno, null);
   else
    tmp2 := '&nbsp;';
  end if;
 if tariff is not null
  then
   open c7(entryno,tariff);
   fetch c7 into c7rec;
   close c7;
   open c7b(entryno);
   fetch c7b into c7brec;
   close c7b;
   if c7brec.weight is null
    then
     tmp3 := '&nbsp;';
   else
     tmp3 := c7brec.weight || ' kg';
   end if;
  else
   tmp3 := '&nbsp;';
 end if;
    if tariff is not null
   then
    tmp9 := '4000';
   else
    tmp9 := '&nbsp;';
  end if;
  if tariff is not null
   then
    tmp10 := '169';
   else
    tmp10 := '&nbsp;';
  end if;


tmp :=
 '
 <tr style=''height:6.7pt''>
  <td width=339 colspan=15 style=''width:253.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=43 colspan=2 style=''width:32.35pt;border-top:solid windowtext 1.0pt;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
  <td width=30 colspan=5 style=''width:22.6pt;border-top:solid windowtext 1.0pt;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp10 ||'</span></b></p>
  </td>
  <td width=97 colspan=4 style=''width:73.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=51 colspan=3 style=''width:38.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#999999;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
 </tr>';

elsif colin = 'CPH'
 then

  if tariff is not null
   then
   for c1rec in c1(entryno,tariff) loop
    tmp2 := tmp2 || ', ' || c1rec.description;
   end loop;
   tmp2 := substr(tmp2,length(', ')+1);
--    tmp2 := f15_parameter_range( 'AWWWWW', entryno, null);
   else
    tmp2 := '&nbsp;';
  end if;
  if tariff is not null
   then
    tmp3 := f15_parameter_range( 'AU', entryno, null);
   else
    tmp3 := '&nbsp;';
  end if;

tmp :=
 '
 <tr style=''height:6.7pt''>
  <td width=339 colspan=15 style=''width:253.95pt;border-top:none;border-left:
  none;border-bottom:none;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Description
  of the goods:</span></p>
  </td>
  <td width=221 colspan=14 style=''width:165.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>40. Bill of
  Lading /Airway Bill No./Previous Docs</span></p>
  </td>
 </tr>
 <tr style=''height:11.2pt''>
  <td width=339 colspan=15 rowspan=2 style=''width:253.95pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:11.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=221 colspan=14 style=''width:165.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:11.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
 </tr>';

elsif colin = 'CPS'
 then
tmp :='';


elsif colin = 'CPT'
 then
tmp :='
 <tr style=''height:8.4pt''>
  <td width=63 colspan=6 style=''width:47.35pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>41.Tariff
  Qty</span></p>
  </td>
  <td width=56 colspan=3 style=''width:42.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>41.Sup.
  Qty</span></p>
  </td>
  <td width=77 colspan=3 style=''width:57.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>42.Item
  FCY Price</span></p>
  </td>
  <td width=26 colspan=2 style=''width:19.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>43.</span></p>
  </td>
 </tr>
';

elsif colin = 'CPU'
 then
tmp :=' <tr style=''height:12.3pt''>
  <td width=66 style=''width:49.15pt;border-top:solid windowtext 1.0pt;border-left:solid windowtext 1.0pt;
  border-bottom:none;border-right:solid windowtext 1.0pt;padding:0cm 5.35pt 0cm 5.35pt;
  height:12.3pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>44.</span></p>
  </td>
  <td width=103 colspan=2 style=''width:77.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Licence n°
  :</span></p>
  </td>
  <td width=78 colspan=4 style=''width:58.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:none;
  padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=36 colspan=2 style=''width:26.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:none;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>/DV:</span></p>
  </td>
';

elsif colin = 'CPV'
 then
tmp :='  <td width=37 colspan=2 style=''width:27.75pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:none;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=48 colspan=3 style=''width:35.65pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:none;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>/DQ: </span></p>
  </td>
';

elsif colin = 'CPW'
 then
tmp :='';



elsif colin = 'CPX'
 then
tmp :='
  <td width=38 colspan=2 style=''width:28.5pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
';

elsif colin = 'CPY'
 then
  if tariff is not null
   then
    open c7(entryno,tariff);
    fetch c7 into c7rec;
    close c7;
    open c7a(tariff);
    fetch c7a into c7arec;
    close c7a;
    if c7arec.cola is null
     then
      tmp2 := '&nbsp;';
    else
      tmp2 := c7rec.qty || ' ' || c7arec.cola;
    end if;
   else
    tmp2 := '&nbsp;';
  end if;

  if tariff is not null
   then
    tmp3 := to_char(tot(entryno,tariff,'FOREIGN'),'999999990.99');
  else
    tmp3 := NULL;
  end if;


tmp :='
  <td width=63 colspan=6 style=''width:47.35pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=56 colspan=3 style=''width:42.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''> </span></b></p>
  </td>
  <td width=77 colspan=3 style=''width:57.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=26 colspan=2 style=''width:19.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#999999;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
 </tr>
';

elsif colin = 'CPZ'
 then
tmp :=' <tr style=''height:6.7pt''>
  <td width=66 rowspan=2 style=''width:49.15pt;border:none;border-left:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Add. info</span></p>
  </td>
  <td width=103 colspan=2 style=''width:77.2pt;border:solid windowtext 1.0pt;
  border-top:none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Attach
  doc:</span></p>
  </td>
  <td width=236 colspan=13 style=''width:176.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>Invoices, BOL, F53</span></b></p>
  </td>
  <td width=196 colspan=12 style=''width:146.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>46. Value
  for Duty PGK</span></p>
  </td>
  <td width=26 colspan=2 style=''width:19.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>45.</span></p>
  </td>
 </tr>
';


elsif colin = 'CPSS'
 then
tmp := '';

elsif colin = 'CPTT'
 then
 if tariff is not null
 then
   tmp2 := to_char(tot(entryno,tariff),'999999990.99');
 else
   tmp2 := NULL;
 end if;

tmp := '<tr style=''height:6.7pt''>
  <td width=103 colspan=2 style=''width:77.2pt;border:solid windowtext 1.0pt;
  border-top:none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Additional
  info</span></p>
  </td>
  <td width=236 colspan=13 style=''width:176.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=196 colspan=12 style=''width:146.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=26 colspan=2 style=''width:19.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#999999;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
 </tr>
 ';

-- end of commonality for first and subsequent pages, items 31 through to 46

-- beginning of section 47 for first page

elsif colin = 'CPUU'
 then
 if mod(rnumb,3) = 0
  then
tmp := ' <tr style=''height:8.5pt''>
  <td rowspan=12 valign=top style=''border:solid windowtext 1.0pt;border-right:
  none;padding:0cm 5.35pt 0cm 5.35pt;height:8.5pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>47.</span></p>
  </td>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.5pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Type</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border:solid windowtext 1.0pt;
  border-left:none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:
  8.5pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Tax base</span></p>
  </td>
    <td width=28 style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
    solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
    padding:0cm 3.5pt 0cm 3.5pt;height:8.5pt''>
    <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>%</span></p>
    </td>
    <td width=86 colspan=4 style=''width:64.15pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.5pt''>
    <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Amount</span></p>
    </td>
    <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.5pt''>
    <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>MP</span></p>
    </td>
    <td width=35 colspan=2 style=''width:26.3pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.5pt''>
    <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Type</span></p>
    </td>
  ';
  end if;

elsif colin = 'CPVV'
 then
 if mod(rnumb,3) = 0
  then
tmp := '
  <td width=101 colspan=7 style=''width:75.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.5pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Tax base</span></p>
  </td>
  <td width=31 colspan=3 style=''width:22.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.5pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>%</span></p>
  </td>
  <td width=107 colspan=5 style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.5pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Amount</span></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
  padding:0cm 3.5pt 0cm 3.5pt;height:8.5pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>MP</span></p>
  </td>
 </tr>
  ';
end if;
-- BEGINNING OF END CALUCATIONS FOR CONTINUATION PAGE

elsif colin = 'CP1_1'
 then
 strang_global.pgtotalduty := 0;
 strang_global.pgtotalexcise := 0;
 strang_global.pgtotalgst := 0;
 strang_global.pgtotallevy := 0;
 strang_global.pgglobaltotal := 0;

if mod(rnumb,3) = 0
 then

  if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
   then
    open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
    fetch c2 into c2rec;
    close c2;
    tmp2 := to_char(to_number(c5rec.description),'990.99') || '%';
  else
    tmp2 := '&nbsp;';
  end if;

   if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c5 into c5rec;
     close c5;
     tmp3 := to_char(round(tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff) * (nvl(to_number(c5rec.description),0)/100),2),'999999990.99');
     strang_global.pgtotalduty := nvl(round(tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff) * (nvl(to_number(c5rec.description),0)/100),2),0);
    else
     tmp3 := NULL;
   end if;

          if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;


tmp := ' <tr style=''height:13.45pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Duty</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 align=right style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>';
  else
    tmp2:= NULL;
    tmp3:=NULL;
  end if;

elsif colin = 'CP2_1'
  then
   if mod(rnumb,3) = 0
    then

  if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
   then
    open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
    fetch c2 into c2rec;
    close c2;
    tmp2 := to_char(to_number(c5rec.description),'990.99') || '%';
  else
    tmp2 := '&nbsp;';
  end if;

   if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c5 into c5rec;
     close c5;
     tmp3 := to_char(round(tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff) * (nvl(to_number(c5rec.description),0)/100),2),'999999990.99');
     strang_global.pgtotalduty := nvl(strang_global.pgtotalduty,0) + nvl(round(tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff) * (nvl(to_number(c5rec.description),0)/100),2),0);
    else
     tmp3 := NULL;
   end if;

          if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;


  tmp :='<td width=35 colspan=2 style=''width:26.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Duty</span></p>
  </td>
  <td width=101 colspan=7 style=''width:75.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=31 colspan=3 align=right style=''width:22.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
 </tr>';
  else
    tmp2:= NULL;
    tmp3:= NULL;
  end if;


 -- return( 'X:' || ascii( substr(tmp,522,1) ) || '-' || ascii( substr(tmp,523,1)) || '-' || ascii( substr(tmp,524,1) ) );

elsif colin = 'CP1_2'
  then
if mod(rnumb,3) = 0
 then
  if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
   then
    open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
    fetch c2 into c2rec;
    close c2;
    if to_number(nvl(c5rec.colc,'0') ) > 0
     then
      tmp2 := to_char(to_number(c5rec.colc),'990.99') || '%';
     else
      tmp2 := '&nbsp;';
    end if;
      else
    tmp2 := '&nbsp;';
   end if;

    if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
     then
      open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
      fetch c5 into c5rec;
      close c5;
      temptot := tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
      tmp3 := to_char(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                   (nvl(to_number(c5rec.colc),0)/100),2),'999999990.99');
      strang_global.pgtotalexcise :=  nvl(round((temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                   (nvl(to_number(c5rec.colc),0)/100),2),0);
     else
      tmp3 := NULL;
    end if;
          if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;

  tmp := '<tr style=''height:13.45pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Excise</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 align=right style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>';
  else
    tmp2:= '&nbsp;';
    tmp3:= NULL;
  end if;

elsif colin = 'CP2_2'
  then
if mod(rnumb,3) = 0
 then

  if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
   then
    open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
    fetch c2 into c2rec;
    close c2;
    if to_number(nvl(c5rec.colc,'0') ) > 0
     then
      tmp2 := to_char(to_number(c5rec.colc),'990.99') || '%';
     else
      tmp2 := '&nbsp;';
    end if;
      else
    tmp2 := '&nbsp;';
   end if;

    if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
     then
      open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
      fetch c5 into c5rec;
      close c5;
      temptot := tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
      tmp3 := to_char(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                   (nvl(to_number(c5rec.colc),0)/100),2),'999999990.99');
      strang_global.pgtotalexcise := nvl(strang_global.pgtotalexcise,0) + nvl(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                   (nvl(to_number(c5rec.colc),0)/100),2),0);
     else
      tmp3 := NULL;
    end if;
          if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;

  tmp :='  <td width=35 colspan=2 style=''width:26.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Excise</span></p>
  </td>
  <td width=101 colspan=7 style=''width:75.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=31 colspan=3 align=right style=''width:22.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
 </tr>
  ';
else
  tmp2:= NULL;
  tmp3:= NULL;
end if;



elsif colin = 'CP1_3'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c5 into c5rec;
     close c5;
     open c10(strang_global.GLOBAL_VARS(rnumb-2).entryno);
     fetch c10 into c10rec;
     close c10;
     if nvl(to_number(c10rec.vat),0) > 0
      then
       tmp2 := to_char(to_number(c10rec.vat),'990.99') || '%';
     end if;
    else
     tmp2 := '&nbsp;';
    end if;

     if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
      then
       open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
       fetch c5 into c5rec;
       close c5;
       open c10(strang_global.GLOBAL_VARS(rnumb-2).entryno);
       fetch c10 into c10rec;
       close c10;
       temptot := tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
       tmp3 := to_char(
         round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c10rec.vat),0)/100),2)
                      ,'999999990.99');
         strang_global.pgtotalgst:= nvl(round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c10rec.vat),0)/100),2),0);
       else
        tmp3 := NULL;
      end if;
          if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;


  tmp :=' <tr style=''height:12.2pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>GST</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 align=right style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
  ';
 else
    tmp2:= NULL;
    tmp3:= NULL;
 end if;


elsif colin = 'CP2_3'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c5 into c5rec;
     close c5;
     open c10(strang_global.GLOBAL_VARS(rnumb-1).entryno);
     fetch c10 into c10rec;
     close c10;
     if nvl(to_number(c10rec.vat),0) > 0
      then
       tmp2 := to_char(to_number(c10rec.vat),'990.99') || '%';
     end if;
    else
     tmp2 := '&nbsp;';
    end if;

     if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
      then
       open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
       fetch c5 into c5rec;
       close c5;
       open c10(strang_global.GLOBAL_VARS(rnumb-1).entryno);
       fetch c10 into c10rec;
       close c10;
       temptot := tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
       tmp3 := to_char(
         round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c10rec.vat),0)/100),2)
                      ,'999999990.99');
       strang_global.pgtotalgst :=   nvl(strang_global.pgtotalgst,0) + nvl(round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c10rec.vat),0)/100),2),0);
       else
        tmp3 := NULL;
      end if;
          if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;


  tmp :='  <td width=35 colspan=2 style=''width:26.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>GSTxxx2</span></p>
  </td>
  <td width=101 colspan=7 style=''width:75.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=31 colspan=3 align=right style=''width:22.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
 </tr>
';
    else
      tmp2:= NULL;
      tmp3:= NULL;
    end if;

elsif colin = 'CP1_4'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c5 into c5rec;
     close c5;
     open c10(strang_global.GLOBAL_VARS(rnumb).entryno);
     fetch c10 into c10rec;
     close c10;
     if nvl(to_number(c10rec.levy_rate),0) > 0
      then
       tmp2 := to_char(to_number(c10rec.levy_rate),'990.99') || '%';
     end if;
    else
     tmp2 := '&nbsp;';
    end if;

   if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c5 into c5rec;
     close c5;
     open c10(strang_global.GLOBAL_VARS(rnumb).entryno);
     fetch c10 into c10rec;
     close c10;
     temptot := tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);

     tmp3 := to_char((nvl(to_number(c10rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2))),'999999990.99');
     strang_global.pgtotallevy := nvl((nvl(to_number(c10rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2))),0);
     else
      tmp3 := NULL;
    end if;
          if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;

  tmp :=' <tr style=''height:12.2pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''> - </span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 align=right style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
  ';
  else
    tmp2:= NULL;
    tmp3:= NULL;
  end if;

elsif colin = 'CP2_4'
  then
if mod(rnumb,3) = 0
 then

   if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c5 into c5rec;
     close c5;
     open c10(strang_global.GLOBAL_VARS(rnumb).entryno);
     fetch c10 into c10rec;
     close c10;
     if nvl(to_number(c10rec.levy_rate),0) > 0
      then
       tmp2 := to_char(to_number(c10rec.levy_rate),'990.99') || '%';
     end if;
    else
     tmp2 := '&nbsp;';
    end if;

   if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c5 into c5rec;
     close c5;
     open c10(strang_global.GLOBAL_VARS(rnumb).entryno);
     fetch c10 into c10rec;
     close c10;
     temptot := tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);

     tmp3 := to_char((nvl(to_number(c10rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2))),'999999990.99');
     strang_global.pgtotallevy := nvl(strang_global.pgtotallevy,0) + nvl((nvl(to_number(c10rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2))),0);
     else
      tmp3 := NULL;
    end if;
          if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;

  tmp :='  <td width=35 colspan=2 style=''width:26.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''> - </span></p>
  </td>
  <td width=101 colspan=7 style=''width:75.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=31 colspan=3 align=right style=''width:22.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
 </tr>
';
  else
    tmp2:= NULL;
    tmp3:= NULL;
  end if;

elsif colin = 'CP1_5'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c5 into c5rec;
     close c5;
     open c10(strang_global.GLOBAL_VARS(rnumb).entryno);
     fetch c10 into c10rec;
     close c10;

     tmp4 := round(tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff) * (nvl(to_number(c5rec.description),0)/100),2);
     temptot := tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
     tmp5 := round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                  (nvl(to_number(c5rec.colc),0)/100),2);
     tmp6 :=
          round(
                (temptot +
                 temptot * (nvl(to_number(c5rec.description),0)/100) +
                 (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
                ) *
               (nvl(to_number(c10rec.vat),0)/100),2);
     tmp7 := (nvl(to_number(c10rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2)));
     tmp8 := to_char(tmp4 + tmp5 + tmp6 + tmp7,'999999990.99');
     strang_global.pgglobaltotal := nvl((tmp4 + tmp5 + tmp6 + tmp7),0);
    else
      tmp8 := NULL;
    end if;

  tmp :='

 <tr style=''height:13.55pt''>
  <td width=155 colspan=5 align=right style=''width:116.3pt;border:solid windowtext 1.0pt;
  border-top:none;padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><B><span style=''font-size:8.0pt;font-family:Arial''>TOTAL
  FIRST ITEM  : </span></B></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp8 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  ';
 else
    tmp8 := NULL;
 end if;

elsif colin = 'CP2_5'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c5 into c5rec;
     close c5;
     open c10(strang_global.GLOBAL_VARS(rnumb).entryno);
     fetch c10 into c10rec;
     close c10;

     tmp4 := round(tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff) * (nvl(to_number(c5rec.description),0)/100),2);
     temptot := tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
     tmp5 := round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                  (nvl(to_number(c5rec.colc),0)/100),2);
     tmp6 :=
          round(
                (temptot +
                 temptot * (nvl(to_number(c5rec.description),0)/100) +
                 (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
                ) *
               (nvl(to_number(c10rec.vat),0)/100),2);
     tmp7 := (nvl(to_number(c10rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2)));
     tmp8 := to_char(tmp4 + tmp5 + tmp6 + tmp7,'999999990.99');
     strang_global.pgglobaltotal := nvl(strang_global.pgglobaltotal,0) + nvl((tmp4 + tmp5 + tmp6 + tmp7),0);
    else
      tmp8 := NULL;
    end if;


  tmp :='  <td width=166 colspan=12 align=right style=''width:124.75pt;align:right;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><B><span style=''font-size:8.0pt;font-family:Arial''>TOTAL
  SECOND ITEM :  </span></B></p>
  </td>
  <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp8 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.55pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
 </tr>
 ';
 else
   tmp8:= NULL;
 end if;

elsif colin = 'CPTITLE'
  then
if mod(rnumb,3) = 0
  then
    tmp :=' <tr style=''height:8.4pt''>
   <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
   none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Type</span></p>
   </td>
   <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
   border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Tax base</span></p>
   </td>
   <td width=28 style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
   solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
   padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>%</span></p>
   </td>
   <td width=86 colspan=4 style=''width:64.15pt;border-top:none;border-left:none;
   border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Amount</span></p>
   </td>
   <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
   border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>MP</span></p>
   </td>
   <td width=166 colspan=12 style=''width:124.75pt;border-top:none;border-left:
   none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Type</span></p>
   </td>
   <td width=107 colspan=5 style=''width:80.2pt;border-top:none;border-left:none;
   border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Amount</span></p>
   </td>
   <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
   solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
   padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>MP</span></p>
   </td>
  </tr>
 ';
 else tmp:=null;
 end if;


elsif colin = 'CP3_1'
  then
if mod(rnumb,3) = 0
 then
  if strang_global.GLOBAL_VARS(rnumb).tariff is not null
   then
    open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
    fetch c2 into c2rec;
    close c2;
    tmp2 := to_char(to_number(c5rec.description),'990.99') || '%';
  else
    tmp2 := '&nbsp;';
  end if;

   if strang_global.GLOBAL_VARS(rnumb).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c5 into c5rec;
     close c5;
     tmp3 := to_char(round(tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff) * (nvl(to_number(c5rec.description),0)/100),2),'999999990.99');
     strang_global.pgtotalduty := nvl(strang_global.pgtotalduty,0) + nvl(round(tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff) * (nvl(to_number(c5rec.description),0)/100),2),0);
   else
     tmp3 := NULL;
   end if;
          if strang_global.GLOBAL_VARS(rnumb).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;

  tmp :=' <tr style=''height:13.45pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Duty</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 align=right style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
';
end if;

elsif colin = 'CPGT_1'
  then
 if mod(rnumb,3) = 0
  then
   -- Last Element on the Page, produce the summary page total
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc(rnumb/3) + 1;


   open c8(entryno);
   fetch c8 into c8rec;
   close c8;

   b1 := 0;

   for c18rec in c18(entryno) loop
      temptot := tot(entryno,c18rec.tariff);
      b1 := nvl(b1,0) + temptot * (nvl(to_number(c18rec.description),0)/100);
   end loop;

   xb1 := to_char(b1,'99999999.99'); -- Total C - Customs Duty
   xb1 := to_char(strang_global.pgtotalduty,'99999999.99');  -- page only total

    tmp :='  <td width=166 colspan=12 style=''width:124.75pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
    <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Duty</span></p>
    </td>
    <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
    <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| xb1 ||'</span></b></p>
    </td>
    <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
    solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
    height:13.45pt''>
    <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
    </td>
   </tr>
  ';
  end if;

elsif colin = 'CP3_2'
  then
if mod(rnumb,3) = 0
 then
  if strang_global.GLOBAL_VARS(rnumb).tariff is not null
   then
    open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
    fetch c2 into c2rec;
    close c2;
    if to_number(nvl(c5rec.colc,'0') ) > 0
     then
      tmp2 := to_char(to_number(c5rec.colc),'990.99') || '%';
     else
      tmp2 := '&nbsp;';
    end if;
      else
    tmp2 := '&nbsp;';
   end if;

    if strang_global.GLOBAL_VARS(rnumb).tariff is not null
     then
      open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
      fetch c5 into c5rec;
      close c5;
      temptot := tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
      tmp3 := to_char(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                   (nvl(to_number(c5rec.colc),0)/100),2),'999999990.99');
      strang_global.pgtotalexcise := nvl(strang_global.pgtotalexcise,0) +  nvl(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                   (nvl(to_number(c5rec.colc),0)/100),2),0);
     else
      tmp3 := NULL;
    end if;
          if strang_global.GLOBAL_VARS(rnumb).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;

  tmp :=' <tr style=''height:13.45pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Excise</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 align=right style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
  ';
end if;

elsif colin = 'CPGT_2'
  then
 if mod(rnumb,3) = 0
  then
   -- Last Element on the Page, produce the summary page total
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc(rnumb/3) + 1;


   open c8(entryno);
   fetch c8 into c8rec;
   close c8;
   temptot := 0;
   b1 := 0;
   b2 := 0;
   b3 := 0;
   b5 := 0;
   for c18rec in c18(entryno) loop --(FEB06 check)
      temptot := tot(entryno,c18rec.tariff);
      b2 := nvl(b2,0) + ((temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) * (nvl(to_number(c18rec.colc),0)/100));
   end loop;

   xb2 := to_char(b2,'99999999.99'); -- Total D - Excise Duty
   xb2 := to_char(strang_global.pgtotalexcise,'99999999.99'); -- Total D - Excise Duty  page only


  tmp :='  <td width=166 colspan=12 style=''width:124.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Excise</span></p>
  </td>
  <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| xb2 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
  </tr>
  ';
 end if;


elsif colin = 'CP3_3'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c5 into c5rec;
     close c5;
     open c10(strang_global.GLOBAL_VARS(rnumb).entryno);
     fetch c10 into c10rec;
     close c10;
     if nvl(to_number(c10rec.vat),0) > 0
      then
       tmp2 := to_char(to_number(c10rec.vat),'990.99') || '%';
     end if;
    else
     tmp2 := '&nbsp;';
    end if;

     if strang_global.GLOBAL_VARS(rnumb).tariff is not null
      then
       open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
       fetch c5 into c5rec;
       close c5;
       open c10(strang_global.GLOBAL_VARS(rnumb).entryno);
       fetch c10 into c10rec;
       close c10;
       temptot := tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
       tmp3 := to_char(
         round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c10rec.vat),0)/100),2)
                      ,'999999990.99');
       strang_global.pgtotalgst := nvl(strang_global.pgtotalgst,0) + nvl(round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c10rec.vat),0)/100),2),0);
       else
        tmp3 := NULL;
      end if;
          if strang_global.GLOBAL_VARS(rnumb).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;

  tmp :=' <tr style=''height:12.2pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>GST</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 align=right style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
 ';
 end if;


elsif colin = 'CPGT_3'
  then
 if mod(rnumb,3) = 0
  then
   -- Last Element on the Page, produce the summary page total
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc(rnumb/3) + 1;


     open c10(entryno);
     fetch c10 into c10rec;
     close c10;

   b3 := 0;
   for c18rec in c18(entryno) loop --(FEB06 check)
      temptot := tot(entryno,c18rec.tariff);
      b3 := nvl(b3,0) +
       (temptot +
          temptot * (nvl(to_number(c18rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) * (nvl(to_number(c18rec.colc),0)/100)
         ) *
        (nvl(to_number(c10rec.vat),0)/100);
   end loop;

   xb3 := to_char(b3,'99999999.99'); -- Total E - Vat
   xb3 := to_char(strang_global.pgtotalgst,'99999999.99'); -- Total E - Vat (GST) page only

  tmp :='  <td width=166 colspan=12 style=''width:124.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>GST</span></p>
  </td>
  <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| xb3 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
 </tr>
 ';
 end if;


elsif colin = 'CP3_4'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c5 into c5rec;
     close c5;
     open c10(strang_global.GLOBAL_VARS(rnumb).entryno);
     fetch c10 into c10rec;
     close c10;
     if nvl(to_number(c10rec.levy_rate),0) > 0
      then
       tmp2 := to_char(to_number(c10rec.levy_rate),'990.99') || '%';
     end if;
    else
     tmp2 := '&nbsp;';
    end if;

   if strang_global.GLOBAL_VARS(rnumb).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c5 into c5rec;
     close c5;
     open c10(strang_global.GLOBAL_VARS(rnumb).entryno);
     fetch c10 into c10rec;
     close c10;
     temptot := tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);

     tmp3 := to_char((nvl(to_number(c10rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2))),'999999990.99');
     strang_global.pgtotallevy := nvl(strang_global.pgtotallevy,0) +  nvl(((nvl(to_number(c10rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2)))),0);
     else
      tmp3 := NULL;
    end if;
          if strang_global.GLOBAL_VARS(rnumb).tariff is not null
           then
           if tmp3 is not null
            then
           tmp9 := '1';
          else
            tmp9 := '&nbsp;';
          end if;
          else
            tmp9 := '&nbsp;';
          end if;

  tmp :=' <tr style=''height:12.2pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''> - </span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 align=right style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp9 ||'</span></b></p>
  </td>
  ';
  end if;


elsif colin = 'CPGT_4'
  then
 if mod(rnumb,3) = 0
  then
   -- Last Element on the Page, produce the summary page total
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc(rnumb/3) + 1;


     open c10(entryno);
     fetch c10 into c10rec;
     close c10;

   b5 := 0;
/* 2 % LEVY CALCULATION
*/
   for c18rec in c18(entryno) loop --(FEB06 check)
      temptot := tot(entryno,c18rec.tariff);
      b5 := nvl(b5,0) +
		((nvl(to_number(c10rec.levy_rate),0)/100)
		*(temptot +
		(round(temptot * (nvl(to_number(c18rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) *
                (nvl(to_number(c18rec.colc),0)/100),2))));
   end loop;

   xb5 := to_char(b5,'99999999.99'); -- Total F - Levy
   xb5 := to_char(strang_global.pgtotallevy,'99999999.99'); -- Total F - Levy (page only)


  tmp :='  <td width=166 colspan=12 style=''width:124.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''> - </span></p>
  </td>
  <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| xb5 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
  </tr>
  ';
 end if;


elsif colin = 'CP3_5'
  then
if mod(rnumb,3) = 0
  then
   if strang_global.GLOBAL_VARS(rnumb).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c5 into c5rec;
     close c5;
     open c10(strang_global.GLOBAL_VARS(rnumb).entryno);
     fetch c10 into c10rec;
     close c10;

     tmp4 := round(tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff) * (nvl(to_number(c5rec.description),0)/100),2);
     temptot := tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
     tmp5 := round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                  (nvl(to_number(c5rec.colc),0)/100),2);
     tmp6 :=
          round(
                (temptot +
                 temptot * (nvl(to_number(c5rec.description),0)/100) +
                 (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
                ) *
               (nvl(to_number(c10rec.vat),0)/100),2);
     tmp7 := (nvl(to_number(c10rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2)));
     tmp8 := to_char(tmp4 + tmp5 + tmp6 + tmp7,'999999990.99');
     strang_global.pgglobaltotal := nvl(strang_global.pgglobaltotal,0) + nvl((tmp4 + tmp5 + tmp6 + tmp7),0);
    else
      tmp8 := NULL;
    end if;

  tmp :=' <tr style=''height:13.55pt''>
  <td width=155 colspan=5 align=right style=''width:116.3pt;border:solid windowtext 1.0pt;
  border-top:none;padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><B><span style=''font-size:8.0pt;font-family:Arial''>TOTAL
  THIRD ITEM  : </span></B></p>
  </td>
  <td width=86 colspan=4 align=right style=''width:64.15pt;align=right;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp8 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  ';
 end if;
elsif colin = 'CPGT_5'
  then
 if mod(rnumb,3) = 0
  then
   -- Last Element on the Page, produce the summary page total

   ttl := 0;
     open c10(entryno);
     fetch c10 into c10rec;
     close c10;
   temptot := 0;
   b1 := 0;
   b2 := 0;
   b3 := 0;
   b5 := 0;
   for c18rec in c18(entryno) loop
      temptot := tot(entryno,c18rec.tariff);
      b1 := nvl(b1,0) + temptot * (nvl(to_number(c18rec.description),0)/100);
      b2 := nvl(b2,0) + ((temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) * (nvl(to_number(c18rec.colc),0)/100));
      b3 := nvl(b3,0) +
       (temptot +
          temptot * (nvl(to_number(c18rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) * (nvl(to_number(c18rec.colc),0)/100)
         ) *
        (nvl(to_number(c10rec.vat),0)/100);
      b5 := nvl(b5,0) +
		((nvl(to_number(c10rec.levy_rate),0)/100)
		*(temptot +
		(round(temptot * (nvl(to_number(c18rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) *
                (nvl(to_number(c18rec.colc),0)/100),2))));
   end loop;
   b4 := round(b1 + b2 + b3 + b5,2);
   b4 := round(strang_global.pgglobaltotal,2); -- page total only

   tmp :='  <td width=166 colspan=12 align=right style=''width:124.75pt;border-top:none;border-left:
   none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
   <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''><B>GLOBAL
   TOTAL : </B></span></p>
   </td>
   <td width=107 colspan=5 align=right style=''width:80.2pt;border-top:none;border-left:none;
   border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
   <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| to_char(b4,'99999999.99') ||'</span></b></p>
   </td>
   <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
   solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
   height:13.55pt''>
   <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
   </td>
   </tr>
   </table>';
    strang_global.pgtotalduty := 0;
    strang_global.pgtotalexcise := 0;
    strang_global.pgtotalgst := 0;
    strang_global.pgtotallevy := 0;
    strang_global.pgglobaltotal := 0;
  if pagefrom = pageto
    then
      NULL;
  else
    tmp := tmp || '<br clear=all style=''mso-special-character:line-break;page-break-before:always''>';
  end if;
 end if;

-- end of continuation page



-- beginning of commonality for first page, items 31 through to 46

elsif colin = 'A'
 then
 tmp :=
 ' <tr style=''height:8.1pt''>
  <td width=68 style=''width:51.05pt;border-top:none;border-left:solid windowtext 1.0pt;
  border-bottom:none;border-right:solid windowtext 1.0pt;padding:0cm 5.35pt 0cm 5.35pt;
  height:8.1pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>31.</span></p>
  </td>
  <td width=318 colspan=18 style=''width:238.7pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:8.1pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''> </span></p>
  </td>
  <td width=63 colspan=5 style=''width:47.25pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.1pt''>
  <p class=MsoNormal style=''margin-top:0cm;margin-right:-6.2pt;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>32.  Item  </span></p>
  </td>
  <td width=268 colspan=21 style=''width:200.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.1pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>33.
  Commodity code</span></p>
  </td>
 </tr>
';

elsif colin = 'B'
 then
   tmp2 := 'MANIFEST LINE/S: '||f15_parameter_range( 'AT', entryno, null);
   if tariff is not null
    then
      tmp3 := rnumb;
     else
      tmp3 := '&nbsp;';
   end if;

tmp :=
' <tr style=''height:16.25pt''>
  <td width=68 rowspan=6 style=''width:51.05pt;border-top:none;border-left:solid windowtext 1.0pt;
  border-bottom:none;border-right:solid windowtext 1.0pt;padding:0cm 5.35pt 0cm 5.35pt;
  height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Packages
  and Description of goods</span></p>
  </td>
  <td width=108 colspan=4 style=''width:81.35pt;border:none;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><a name=CommCode><span style=''font-size:8.0pt;font-family:Arial;
  letter-spacing:-.3pt''>Marks &amp; No. of packages </span></a></p>
  </td>
  <td width=210 colspan=14 style=''width:157.35pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:none;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;text-indent:
  1.75pt;line-height:9.0pt''>&nbsp;<b><span style=''font-size:8.0pt;font-family:
  Arial;letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=40 colspan=2 style=''width:29.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''> <b>'|| tmp3 ||'</b></span></p>
  </td>
  <td width=23 colspan=3 style=''width:17.5pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-top:0cm;margin-right:-6.2pt;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>N°.</span></p>
  </td>
';


elsif colin = 'C'
 then
 if tariff is not null
  then
   open c5(tariff);
   fetch c5 into c5rec;
   close c5;
   open c2(entryno,tariff);
   fetch c2 into c2rec;
   close c2;
   tmp2 := tariff;
  else
   tmp2 := '&nbsp;';
  end if;
  tmp3 := f15_parameter_range( 'AWW', entryno, null);

tmp :=
  '  <td width=268 colspan=21 style=''width:200.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;<b><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:
  -.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
 </tr>
 <tr style=''height:2.05pt''>
  <td width=108 colspan=4 style=''width:81.35pt;border-top:none;border-left:
  none;border-bottom:none;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:2.05pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;</p>
  </td>
  <td width=273 colspan=19 style=''width:204.55pt;border-top:none;border-left:
  none;border-bottom:none;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:2.05pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;<b><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:
  -.3pt''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=82 colspan=9 style=''width:61.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:2.05pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>34.
  Cty.Or code </span></p>
  </td>
  <td width=117 colspan=10 style=''width:87.8pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:2.05pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>35.
  Gr. mass kg</span></p>
  </td>';

elsif colin = 'D'
 then
   tmp2 := f15_parameter_range( 'AWWW', entryno, null);

tmp:='  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:2.05pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>36.
  Pref.</span></p>
  </td>
 </tr>
 <tr style=''height:6.5pt''>
  <td width=108 colspan=4 style=''width:81.35pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><span style=''font-size:8.0pt;
  font-family:Arial;letter-spacing:-.3pt''> No/kind of pkgs </span></p>
  </td>
  <td width=273 colspan=19 style=''width:204.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<b><span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=13 style=''width:10.1pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
  padding:0cm 2.8pt 0cm 2.8pt;height:6.5pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><span style=''font-size:8.0pt;
  font-family:Arial;letter-spacing:-.3pt''>a</span></p>
  </td>';

elsif colin = 'E'
 then
 if tariff is not null
  then
   open c7(entryno,tariff);
   fetch c7 into c7rec;
   close c7;
   open c7b(entryno);
   fetch c7b into c7brec;
   close c7b;
   if c7brec.weight is null
    then
     tmp2 := '&nbsp;';
   else
     tmp2 := c7brec.weight || ' kg';
   end if;
  else
   tmp2 := '&nbsp;';
 end if;

  if tariff is not null
   then
    open c4(entryno);
    fetch c4 into c4rec;
    close c4;
  else
   c4rec.ctry_countrycode := ' ';
  end if;


tmp :=
 '<td width=68 colspan=8 style=''width:51.35pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 2.8pt 0cm 2.8pt;height:6.5pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><span style=''font-size:8.0pt;
  font-family:Arial;letter-spacing:-.3pt''> <b>'|| c4rec.ctry_countrycode ||'</b></span></p>
  </td>
  <td width=117 colspan=10 style=''width:87.8pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 2.8pt 0cm 2.8pt;height:6.5pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<b><span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 2.8pt 0cm 2.8pt;height:6.5pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;</p>
  </td>
 </tr>';


elsif colin = 'F'
 then

tmp :=
' <tr style=''height:6.5pt''>
  <td width=108 colspan=4 style=''width:81.35pt;border-top:none;border-left:
  none;border-bottom:none;border-right:none;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Container
  N°(s) </span></p>
  </td>
  <td width=273 colspan=19 style=''width:204.55pt;border-top:none;border-left:
  none;border-bottom:none;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;</p>
  </td>
  <td width=82 colspan=9 style=''width:61.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>37.
  Procedure</span></p>
  </td>
  <td width=117 colspan=10 style=''width:87.8pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>38.
  Net mass kg</span></p>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>39.
  </span></p>
  </td>
 </tr>';


elsif colin = 'G'
 then
  tmp2 := f15_parameter_range( 'AWWWW', entryno, null);
 if tariff is not null
  then
   open c7(entryno,tariff);
   fetch c7 into c7rec;
   close c7;
   open c7b(entryno);
   fetch c7b into c7brec;
   close c7b;
   if c7brec.weight is null
    then
     tmp3 := '&nbsp;';
   else
     tmp3 := c7brec.weight || ' kg';
   end if;
  else
   tmp3 := '&nbsp;';
 end if;

tmp :=
 '
 <tr style=''height:6.5pt''>
  <td width=381 colspan=23 style=''width:285.9pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><a name=ContainerNum4><b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></a><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''> </span></p>
  </td>
  <td width=43 colspan=5 style=''width:32.1pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;<b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>4000</span></b></p>
  </td>
  <td width=39 colspan=4 style=''width:29.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;<b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>169</span></b></p>
  </td>
  <td width=117 colspan=10 style=''width:87.8pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;<b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;</p>
  </td>
 </tr>';

elsif colin = 'H'
 then

  tmp2 := f15_parameter_range( 'AWWWWW', entryno, tariff);

  if tariff is not null
   then
    tmp3 := f15_parameter_range( 'AU', entryno, null);
   else
    tmp3 := '&nbsp;';
  end if;


tmp :=
 ' <tr style=''height:6.5pt''>
  <td width=381 colspan=23 style=''width:285.9pt;border-top:none;border-left:
  none;border-bottom:none;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Description
  of the goods:</span></p>
  </td>
  <td width=268 colspan=21 style=''width:200.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>40.
  Bill of Lading /Airway Bill No. / Previous doc.</span></p>
  </td>
 </tr>
 <tr style=''height:13.55pt''>
  <td width=68 rowspan=2 style=''width:51.05pt;border:solid windowtext 1.0pt;
  border-top:none;padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><b><span style=''font-size:9.0pt;
  font-family:Arial;letter-spacing:-.3pt''>                    </span></b></p>
  </td>
  <td width=381 colspan=23 rowspan=2 style=''width:285.9pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<b><span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=268 colspan=21 style=''width:200.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<b><span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp3 ||'</span></b></p>
  </td>
 </tr>';

elsif colin = 'S'
 then
tmp :='';


elsif colin = 'T'
 then
tmp :='
  <tr style=''height:6.5pt''>
  <td width=82 colspan=9 style=''width:61.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>41.a
  Tariff Qty</span></p>
  </td>
  <td width=65 colspan=5 style=''width:48.75pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>41.b
  Supp. Qty</span></p>
  </td>
  <td width=76 colspan=6 style=''width:56.65pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>42.
  Item price FCY</span></p>
  </td>
  <td width=45 style=''width:33.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>43.</span></p>
  </td>
 </tr>';

elsif colin = 'U'
 then
tmp :='
 <tr style=''height:11.9pt''>
  <td width=68 style=''width:51.05pt;border-top:none;border-left:solid windowtext 1.0pt;
  border-bottom:none;border-right:solid windowtext 1.0pt;padding:0cm 5.35pt 0cm 5.35pt;
  height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>44.</span></p>
  </td>
  <td width=107 colspan=3 style=''width:80.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Licence
  n° :</span></p>
  </td>
  <td width=102 colspan=7 style=''width:76.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:none;
  padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;</p>
  </td>
  <td width=36 colspan=3 style=''width:26.85pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:none;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>/DV:</span></p>
  </td>';

elsif colin = 'V'
 then
tmp :='
  <td width=52 colspan=4 style=''width:39.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:none;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;</p>
  </td>
  <td width=49 colspan=2 style=''width:36.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:none;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>/DQ:
  </span></p>
  </td>
';

elsif colin = 'X'
 then
tmp :='  <td width=35 colspan=4 style=''width:26.05pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;</p>
  </td>
';

elsif colin = 'Y'
 then
  if tariff is not null
   then
    open c7(entryno,tariff);
    fetch c7 into c7rec;
    close c7;
    open c7a(tariff);
    fetch c7a into c7arec;
    close c7a;
    if c7arec.cola is null
     then
      tmp2 := '&nbsp;';
    else
      tmp2 := c7rec.qty || ' ' || c7arec.cola;
    end if;
   else
    tmp2 := '&nbsp;';
  end if;

  if tariff is not null
   then
    tmp3 := to_char(tot(entryno,tariff,'FOREIGN'),'999999990.99');
  else
    tmp3 := NULL;
  end if;


tmp :='  <td width=82 colspan=9 style=''width:61.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;<b><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:
  -.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=65 colspan=5 style=''width:48.75pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;<b><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:
  -.3pt''> </span></b></p>
  </td>
  <td width=76 colspan=6 style=''width:56.65pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal align=right style=''margin-bottom:0cm;margin-bottom:.0001pt;
  text-align:right;line-height:9.0pt''><span style=''font-size:8.0pt;font-family:
  Arial;letter-spacing:-.3pt''> <b>'|| tmp3 ||'</b></span></p>
  </td>
  <td width=45 style=''width:33.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;</p>
  </td>
 </tr>

';

elsif colin = 'Z'
 then
tmp :=' <tr style=''height:7.05pt''>
  <td width=68 rowspan=3 style=''width:51.05pt;border:solid windowtext 1.0pt;
  border-top:none;padding:0cm 5.35pt 0cm 5.35pt;height:7.05pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Additional
  Information</span></p>
  </td>
  <td width=107 colspan=3 style=''width:80.55pt;border:none;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:7.05pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Attach
  doc. codes:</span></p>
  </td>
  <td width=274 colspan=20 rowspan=2 style=''width:205.35pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:7.05pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''><B>Invoices, BOL, F53</B></span></p>
  </td>
  <td width=268 colspan=21 style=''width:200.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:7.05pt''>
  <h2>&nbsp;</h2>
  </td>
 </tr>
';


elsif colin = 'SS'
 then
tmp := ' <tr style=''height:6.5pt''>
  <td width=107 colspan=3 style=''width:80.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;</p>
  </td>
  <td width=199 colspan=19 style=''width:149.25pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial''>46. Value for Duty PGK</span></p>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#CCCCCC;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>45.
  </span></p>
  </td>
 </tr>';

elsif colin = 'TT'
 then
 if tariff is not null
 then
   tmp2 := to_char(tot(entryno,tariff),'999999990.99');
 else
   tmp2 := NULL;
 end if;

tmp := '
 <tr style=''height:6.5pt''>
  <td width=107 colspan=3 style=''width:80.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><span style=''font-size:8.0pt;
  font-family:Arial;letter-spacing:-.3pt''>Additional info:</span></p>
  </td>
  <td width=274 colspan=20 style=''width:205.35pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=199 colspan=19 style=''width:149.25pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal align=center style=''margin-right:8.8pt;text-align:center;
  line-height:9.0pt''><b><span style=''font-size:8.0pt;font-family:Arial;
  letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-right:8.8pt;line-height:9.0pt''>&nbsp;</p>
  </td>
 </tr>
';

-- end of commonality for first and subsequent pages, items 31 through to 46

-- beginning of section 47 for first page

elsif colin = 'UU'
 then
tmp := ' <tr style=''height:16.25pt''>
  <td width=68 style=''width:51.05pt;border-top:none;border-left:solid windowtext 1.0pt;
  border-bottom:none;border-right:solid windowtext 1.0pt;padding:0cm 5.35pt 0cm 5.35pt;
  height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>47.</span></p>
  </td>
  <td width=54 style=''width:40.5pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
  padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal align=center style=''margin-bottom:0cm;margin-bottom:.0001pt;
  text-align:center;line-height:9.0pt''><span style=''font-size:8.0pt;font-family:
  Arial;letter-spacing:-.3pt''>Type</span></p>
  </td>
  <td width=85 colspan=6 style=''width:63.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal align=center style=''margin-bottom:0cm;margin-bottom:.0001pt;
  text-align:center;line-height:9.0pt''><span style=''font-size:8.0pt;font-family:
  Arial;letter-spacing:-.3pt''>Tax base</span></p>
  </td>';

elsif colin = 'VV'
 then
tmp := '<td width=50 colspan=2 style=''width:37.6pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal align=center style=''margin-bottom:0cm;margin-bottom:.0001pt;
  text-align:center;line-height:9.0pt''><span style=''font-size:8.0pt;font-family:
  Arial;letter-spacing:-.3pt''>Rate</span></p>
  </td>
  <td width=95 colspan=7 style=''width:71.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal align=center style=''margin-bottom:0cm;margin-bottom:.0001pt;
  text-align:center;line-height:9.0pt''><span style=''font-size:8.0pt;font-family:
  Arial;letter-spacing:-.3pt''>Amount</span></p>
  </td>
  <td width=34 colspan=2 style=''width:25.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>MP</span></p>
  </td>
  <td width=114 colspan=12 style=''width:85.3pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>48.
  Account No.</span></p>
  </td>';

elsif colin = 'WW'
 then
tmp := '<td width=31 colspan=2 style=''width:23.35pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>MP</span></p>
  </td>
  <td width=99 colspan=9 style=''width:73.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>48.
  Account No.</span></p>
  </td>
  <td width=87 colspan=3 style=''width:65.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>49.
  Warehouse  / days susp. </span></p>
  </td>
 </tr>
';

elsif colin = 'XX'
 then
 if tariff is not null
  then
   open c5(tariff);
   fetch c5 into c5rec;
   close c5;
   open c2(entryno,tariff);
   fetch c2 into c2rec;
   close c2;
   tmp2 := to_char(to_number(c5rec.description),'990.99') || '%';
 else
   tmp2 := '&nbsp;';
 end if;

  if tariff is not null
   then
    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
    tmp3 := to_char(round(tot(entryno,tariff) * (nvl(to_number(c5rec.description),0)/100),2),'999999990.99');
   else
    tmp3 := NULL;
  end if;

tmp := ' <tr style=''height:19.3pt''>
  <td width=68 rowspan=4 style=''width:51.05pt;border-top:none;border-left:solid windowtext 1.0pt;
  border-bottom:none;border-right:solid windowtext 1.0pt;padding:0cm 5.35pt 0cm 5.35pt;
  height:19.3pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><b><span style=''font-size:9.0pt;
  font-family:Arial;letter-spacing:-.3pt''>      </span></b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Calculation of
  Taxes</span></p>
  </td>
  <td width=54 style=''width:40.5pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
  padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>Duty</span></p>
  </td>
  <td width=85 colspan=6 style=''width:63.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal align=right style=''text-align:right;line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=50 colspan=2 align=right style=''width:37.6pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal align=center style=''text-align:center;line-height:9.0pt''><b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=95 colspan=7 align=right style=''width:71.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal align=right style=''text-align:right;line-height:9.0pt''><b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp3 ||'</span></b></p>
  </td>';

elsif colin = 'YY'
 then
     if tariff is not null
    then
     tmp9 := '1';
    else
     tmp9 := '&nbsp;';
   end if;

tmp := '
  <td width=34 colspan=2 style=''width:25.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<b><span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp9 ||'</span></b></p>
  </td>
  <td width=114 colspan=12 style=''width:85.3pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=130 colspan=11 style=''width:97.3pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><span style=''font-size:8.0pt;
  font-family:Arial;letter-spacing:-.3pt''>&nbsp;</span></p>
  </td>
  <td width=18 style=''width:13.85pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><span style=''font-size:8.0pt;
  font-family:Arial;letter-spacing:-.3pt''>/</span></p>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><span style=''font-size:8.0pt;
  font-family:Arial;letter-spacing:-.3pt''>&nbsp;</span></p>
  </td>
 </tr>
';

elsif colin = 'ZZ'
 then
 if tariff is not null
  then
   open c5(tariff);
   fetch c5 into c5rec;
   close c5;
   open c2(entryno,tariff);
   fetch c2 into c2rec;
   close c2;
   if to_number(nvl(c5rec.colc,'0') ) > 0
    then
     tmp2 := to_char(to_number(c5rec.colc),'990.99') || '%';
    else
     tmp2 := '&nbsp;';
   end if;
     else
   tmp2 := '&nbsp;';
  end if;

    if tariff is not null
     then
      open c5(tariff);
      fetch c5 into c5rec;
      close c5;
      temptot := tot(entryno,tariff);
      tmp3 := to_char(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                   (nvl(to_number(c5rec.colc),0)/100),2),'999999990.99');
     else
      tmp3 := NULL;
    end if;

   if tariff is not null
    then
     tmp9 := '1';
    else
     tmp9 := '&nbsp;';
   end if;

tmp := ' <tr style=''height:17.45pt''>
  <td width=54 style=''width:40.5pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
  padding:0cm 5.35pt 0cm 5.35pt;height:17.45pt''>
  <h5 style=''margin-bottom:6.0pt''>&nbsp;<span style=''font-size:8.0pt;
  font-family:Arial;font-weight:normal''>Excise</span></h5>
  </td>
  <td width=85 colspan=6 style=''width:63.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:17.45pt''>
  <p class=MsoNormal align=right style=''text-align:right;line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=50 colspan=2 align=right style=''width:37.6pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:17.45pt''>
  <p class=MsoNormal align=center style=''text-align:center;line-height:9.0pt''>&nbsp;<b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=95 colspan=7 align=right style=''width:71.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:17.45pt''>
  <p class=MsoNormal align=right style=''text-align:right;line-height:9.0pt''>&nbsp;<b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=34 colspan=2 style=''width:25.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:17.45pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<b><span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp9 ||'</span></b></p>
  </td>
  <td width=331 colspan=26 style=''width:248.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:17.45pt''>
  <h1 style=''margin-bottom:6.0pt''><span style=''letter-spacing:0pt''>B.
  ACCOUNTING DETAILS</span></h1>
  </td>
 </tr>
';

elsif colin = 'SSS'
 then

  if tariff is not null
   then
    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
    open c10(entryno);
    fetch c10 into c10rec;
    close c10;
    if nvl(to_number(c10rec.vat),0) > 0
     then
      tmp2 := to_char(to_number(c10rec.vat),'990.99') || '%';
    end if;
   else
    tmp2 := '&nbsp;';
   end if;

     if tariff is not null
      then
       open c5(tariff);
       fetch c5 into c5rec;
       close c5;
       open c10(entryno);
       fetch c10 into c10rec;
       close c10;
       temptot := tot(entryno,tariff);
       tmp3 := to_char(
         round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c10rec.vat),0)/100),2)
                      ,'999999990.99');
       else
        tmp3 := NULL;
      end if;


tmp := ' <tr style=''height:14.95pt''>
  <td width=54 style=''width:40.5pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
  padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <h5 style=''margin-bottom:6.0pt''>&nbsp;<span style=''font-size:8.0pt;
  font-family:Arial;font-weight:normal''>GST</span></h5>
  </td>
  <td width=85 colspan=6 style=''width:63.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <p class=MsoNormal align=right style=''text-align:right;line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=50 colspan=2 align=right style=''width:37.6pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <p class=MsoNormal align=center style=''text-align:center;line-height:9.0pt''>&nbsp;<b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=95 colspan=7 align=right style=''width:71.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <p class=MsoNormal align=right style=''text-align:right;line-height:9.0pt''>&nbsp;<b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp3 ||'</span></b></p>
  </td>
';

elsif colin = 'TTT'
 then
    if tariff is not null
     then
      tmp9 := '1';
     else
      tmp9 := '&nbsp;';
    end if;

tmp := '  <td width=34 colspan=2 style=''width:25.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<b><span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp9 ||'</span></b></p>
  </td>
  <td width=90 colspan=8 style=''width:67.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Mode of paymt
  :</span></p>
  </td>
  <td width=127 colspan=12 style=''width:95.45pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <h1 style=''margin-bottom:6.0pt''>&nbsp;</h1>
  </td>
  <td width=44 colspan=4 style=''width:33.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <h1 style=''margin-bottom:6.0pt''>&nbsp;</h1>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <h1 style=''margin-bottom:6.0pt''>&nbsp;</h1>
  </td>
 </tr>
';

elsif colin = 'UUU'
 then

  if tariff is not null
   then
    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
     open c10(entryno);
     fetch c10 into c10rec;
     close c10;
    if nvl(to_number(c10rec.levy_rate),0) > 0
     then
      tmp2 := to_char(to_number(c10rec.levy_rate),'990.99') || '%';
    end if;
   else
    tmp2 := '&nbsp;';
   end if;

  if tariff is not null
   then
    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
     open c10(entryno);
     fetch c10 into c10rec;
     close c10;
    temptot := tot(entryno,tariff);

    tmp3 := to_char((nvl(to_number(c10rec.levy_rate),0)/100)
    		*(temptot +
		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                (nvl(to_number(c5rec.colc),0)/100),2))),'999999990.99');
    else
     tmp3 := NULL;
   end if;

tmp := ' <tr style=''height:7.9pt''>
  <td width=54 style=''width:40.5pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
  padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <h5 style=''margin-bottom:6.0pt''>&nbsp;<span style=''font-size:8.0pt;
  font-family:Arial;font-weight:normal''> - </span></h5>
  </td>
  <td width=85 colspan=6 style=''width:63.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <p class=MsoNormal align=right style=''text-align:right;line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=50 colspan=2 align=right style=''width:37.6pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <p class=MsoNormal align=center style=''text-align:center;line-height:9.0pt''>&nbsp;<b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=95 colspan=7 align=right style=''width:71.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <p class=MsoNormal align=right style=''text-align:right;line-height:9.0pt''>&nbsp;<b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp3 ||'</span></b></p>
  </td>';

elsif colin = 'VVV'
 then
     if tariff is not null
      then
       tmp9 := '1';
      else
       tmp9 := '&nbsp;';
     end if;

tmp := '
  <td width=34 colspan=2 style=''width:25.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<b><span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp9 ||'</span></b></p>
  </td>
  <td width=90 colspan=8 style=''width:67.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Assessment N°.
  :</span></p>
  </td>
  <td width=127 colspan=12 style=''width:95.45pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=44 colspan=4 style=''width:33.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><span style=''font-size:8.0pt;
  font-family:Arial;letter-spacing:-.3pt''>Date :</span></p>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;</p>
  </td>
 </tr>
';

elsif colin = 'WWW'
 then

  if tariff is not null
   then
    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
     open c10(entryno);
     fetch c10 into c10rec;
     close c10;

    tmp4 := round(tot(entryno,tariff) * (nvl(to_number(c5rec.description),0)/100),2);
    temptot := tot(entryno,tariff);
    tmp5 := round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2);
    tmp6 :=
         round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c10rec.vat),0)/100),2);
    tmp7 := (nvl(to_number(c10rec.levy_rate),0)/100)
    		*(temptot +
		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                (nvl(to_number(c5rec.colc),0)/100),2)));
    tmp8 := to_char(tmp4 + tmp5 + tmp6 + tmp7,'999999990.99');
   else
     tmp8 := NULL;
   end if;


tmp := ' <tr style=''height:13.55pt''>
  <td width=68 style=''width:51.05pt;border:none;border-left:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=284 colspan=16 align=right style=''width:213.2pt;border:solid windowtext 1.0pt;
  border-top:none;padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal align=right style=''margin-top:6.0pt;margin-right:0cm;
  margin-bottom:0cm;margin-left:0cm;margin-bottom:.0001pt;text-align:right;
  line-height:9.0pt''><a name=Text4><b><span style=''font-size:8.0pt;font-family:
  Arial;letter-spacing:-.3pt''>TOTAL (Item 1)  : '|| tmp8 ||'</span></b></a></p>
  </td>
  <td width=34 colspan=2 align=right style=''width:25.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''font-size:8.0pt;font-family:Arial;margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><B></B></p>
  </td>
';

elsif colin = 'XXX'
 then

tmp := '  <td width=90 colspan=8 style=''width:67.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Receipt Number</span></p>
  </td>
  <td width=127 colspan=12 style=''width:95.45pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=44 colspan=4 style=''width:33.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Date :</span></p>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;</p>
  </td>
 </tr>
';

elsif colin = 'YYY'
 then
tmp := ' <tr style=''height:13.55pt''>
  <td width=68 style=''width:51.05pt;border:solid windowtext 1.0pt;border-right:
  none;background:#E5E5E5;padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=113 colspan=6 style=''width:84.4pt;border:solid windowtext 1.0pt;
  border-top:none;background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <h1 style=''margin-top:6.0pt''><span style=''letter-spacing:0pt''>     Value
  Details</span></h1>
  </td>
  <td width=145 colspan=8 style=''width:108.85pt;border:solid windowtext 1.0pt;
  border-left:none;background:#E5E5E5;padding:0cm 5.35pt 0cm 5.35pt;height:
  13.55pt''>
  <p class=MsoNormal align=center style=''margin-top:6.0pt;margin-right:0cm;
  margin-bottom:0cm;margin-left:0cm;margin-bottom:.0001pt;text-align:center;
  line-height:9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:
  -.3pt''>Amount</span></p>
  </td>
  <td width=61 colspan=4 style=''width:45.45pt;border:solid windowtext 1.0pt;
  border-left:none;background:#E5E5E5;padding:0cm 5.35pt 0cm 5.35pt;height:
  13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Currency</span></p>
  </td>
  <td width=90 colspan=8 style=''width:67.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Guarantee&nbsp;:</span></p>
  </td>
';

elsif colin = 'ZZZ'
 then
tmp := '  <td width=127 colspan=12 style=''width:95.45pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=44 colspan=4 style=''width:33.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Date :</span></p>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;</p>
  </td>
 </tr>
';
-- end of section 47 for first page


elsif colin = 'L'
 then
  -- Calculate Total Number of Rows for rownum rounded up to the nearest 10..this is a very odd calculation!!
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   c21rec.tot := ((trunc((c21rec.tot - 2) / 3) + 1) * 3) + 1;
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
   c21rec.tot := c21rec.tot - 1;
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
end form_15_continue;
/


GRANT EXECUTE ON STRANG.FORM_15_CONTINUE TO WEBSYS;
