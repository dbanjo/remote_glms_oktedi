CREATE OR REPLACE function STRANG.f15_parameter_range_sad_com( parm_id in varchar2, parm1 in varchar2, parm2 in varchar2 )
 return varchar2
as

 -- Parm1 = ENTRY_NO
 -- Parm2 = CUSTOMER
 
 cursor c1( parm1 number ) is 
  select /*+ ALL_ROWS */ * 
  from ships_airway 
  where ship_id in ( select ship_id 
                     from movements m, detailrs dr 
                     where entry_no_com = parm1 and 
                           m.movement_no = dr.movement_no and
                           nvl(m.seal,'|') = nvl(dr.camov_seal,'|'));
 
  cursor c1a( parm1 number ) is 
   select flight 
   from movements m, detailrs dr 
   where entry_no_com = parm1 and 
         m.movement_no = dr.movement_no and
         nvl(m.seal,'|') = nvl(dr.camov_seal,'|');

 cursor c2( lv varchar2, cd varchar2 ) is 
  select /*+ ALL_ROWS */ *
  from lov 
  where lov_name = lv and 
        code = cd;
 
 cursor c2a( lv varchar2, cd varchar2 ) is 
  select /*+ ALL_ROWS */ *
  from lov 
  where lov_name = lv and 
        cola = cd;
 
 cursor c2b( cd varchar2 ) is 
  select /*+ ALL_ROWS */ *
  from lov l 
  where l.lov_name = 'CONTROLS' and 
        l.cola = WEBSYS.OLTP.F_USER_SITE and
        code = cd;

 cursor c2c( v_port varchar2 ) is 
 select l2.code
  from lov l1, lov l2, ships_airway
  where l1.lov_name = 'LOCATIONS' and
        l2.lov_name = 'COUNTRIES' and
        l1.colb = l2.description and
        l1.code = v_port; 
 /*
 cursor c3( parm1 number, parm2 varchar2 ) is
  select sum(p.tamount)/count(dr.entry_no) sm 
  from pos p, customers c, detailrs dr, receivals r
  where dr.entry_no = parm1 and 
        c.customer = parm2 and
        dr.deliveryno = r.deliveryno and
        p.deliveryno = r.deliveryno and
        nvl(r.cust_customer_id,0) = c.customer_id and
        customer_type = 'CUSTOMER';
 */
 -- SS says this is the right way to do this.
 
 cursor c3( parm1 number, parm2 varchar2 ) is
  select /*+ ALL_ROWS */ sum(nvl(p.tamount,0)+nvl(p.delivery_charge,0)) sm 
  from pos p
  where p.deliveryno in
   (select distinct dr.deliveryno 
    from detailrs dr
    where entry_no_com = parm1
   );

/*
 cursor c4( parm1 number, parm2 varchar2 ) is
 select l.description || ' ' || dr.detaildesc shipmark,sum(qty) qty
 from detailrs dr, lov l 
 where movement_no in 
       (select dr.movement_no 
        from customers c, detailrs dr, receivals r, movements m
        where dr.entry_no_com = parm1 and 
          c.customer = parm2 and
          m.movement_no = dr.movement_no and
          nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
          dr.deliveryno = r.deliveryno and
          nvl(r.cust_customer_id,0) = c.customer_id and
          customer_type = 'CUSTOMER') and
       lov_name = 'PACKTYPES' and
       l.code = dr.pktpe_packtype
 group by l.description || ' ' || dr.detaildesc;
 */
 
 /*
 This will only get the first country of origin code in po order
 */
 
  cursor c4a( entryno number ) is
   select /*+ ALL_ROWS */ ctry_countrycode
   from pos p, detailrs dr
   where p.deliveryno = dr.deliveryno and
          dr.deliveryno = p.deliveryno and
          dr.entry_no_com = entryno;

 
 cursor c5(cid integer) is select * from customers where customer_id = cid;

 
 cursor c6(parm1 number, parm2 varchar2 ) is
  select /*+ ALL_ROWS */ sum(revton * c.freight * d.exrate) sm
  from customers c, detailrs dr, receivals r, movements m, ships_airway s, duty d
  where dr.entry_no_com = parm1 and 
        d.entry_no = dr.entry_no_com and
        c.customer = parm2 and
        m.ship_id = s.ship_id and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        nvl(r.cust_customer_id,0) = c.customer_id and
        customer_type = 'CUSTOMER';

 cursor c7(entryno number) is   -- SUPPLIER
  select /*+ ALL_ROWS */ distinct c.customer, c.street, c.suburb, c.state, c.postcode, c.country, r.curr, d.exrate, c.p2acode
  from receivals r, detailrs dr, customers c, duty d
  where dr.entry_no_com = entryno and
        d.entry_no = dr.entry_no_com and
        dr.deliveryno = r.deliveryno and
        nvl(r.supplier_customer_id_com,0) = c.customer_id and
        c.customer_type = 'SUPPLIER';

 cursor c7a(entryno number) is   -- FIRST SUPPLIER
  select /*+ ALL_ROWS */ distinct c.customer, c.street, c.suburb, c.state, c.postcode, c.country, c.p2acode
  from receivals r, detailrs dr, customers c
  where dr.entry_no = entryno and
        dr.deliveryno = r.deliveryno and
        nvl(r.supplier_customer_id,0) = c.customer_id and
        c.customer_type = 'SUPPLIER';

cursor c7b(entryno number) is   -- COUNT SUPPLIER
select count(distinct supplier_customer_id) suppcount
from receivals r, detailrs dr
where r.deliveryno = dr.deliveryno and
dr.entry_no_com = entryno;
       
 cursor c8(custname varchar2) is
  select /*+ ALL_ROWS */ *
  from customers 
  where customer = custname and
        customer_type = 'CUSTOMER';

 cursor c9(entryno number) is 
  select /*+ ALL_ROWS */ *
  from duty
  where entry_no = entryno;

 cursor c10(custid integer) is
  select /*+ ALL_ROWS */ *
  from customers
  where customer_id = custid;
  
 cursor c11a(entryno number) is
  select count('x') cnt
  from duty d
  where previous_entry_no = entryno;
  
 cursor c11b(entryno number) is
  select min(line_no) mn, max(line_no) mx
  from detailrs dr
  where entry_no_com = entryno;
  
 cursor c11(shpid integer, entryno number, parm2 varchar2) is
  select /*+ ALL_ROWS */ dr.entry_no_com, min(line_no) mn, max(line_no) mx
  from detailrs dr, receivals r, movements m
  where m.ship_id = shpid and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        dr.deliveryno in
         (select dr2.deliveryno from detailrs dr2 where dr2.entry_no_com = entryno)
  group by dr.entry_no_com;

 cursor c11c(shpid integer, entryno number, parm2 varchar2) is
  select /*+ ALL_ROWS */ dr.entry_no_com, line_no, dr.deliveryno, dr.itemno
  from detailrs dr, receivals r, movements m
  where m.ship_id = shpid and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        dr.deliveryno in
         (select dr2.deliveryno from detailrs dr2 where dr2.entry_no_com = entryno)
  order by dr.entry_no_com,line_no;

 cursor c11d(shpid integer, entryno number, parm2 varchar2) is
  select count(line_no) no_of_line_nos
  from detailrs dr, receivals r, movements m
  where m.ship_id = shpid and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        dr.deliveryno in
         (select dr2.deliveryno from detailrs dr2 where dr2.entry_no_com = entryno);
  
 cursor c12( entryno number ) is 
   select /*+ ALL_ROWS */ nvl(m.bol,m.movement_no) bol
    from detailrs dr, movements m
    where dr.entry_no_com = entryno and
          m.movement_no = dr.movement_no and
          nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
          m.movement_type in ('CARGO','CONMOV')
   UNION
   select /*+ ALL_ROWS */ nvl(to_char(dr.hawb_hawbno),m.movement_no) bol
    from detailrs dr, movements m
    where dr.entry_no_com = entryno and
          m.movement_no = dr.movement_no and
          nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
          m.movement_type in ('AIRWAY') and
          rownum <= 1;
          
cursor c13( entryno number ) is
 select /*+ ALL_ROWS */ l1.description, pktpe_packtype, sum(qty) tot
 from detailrs dr, lov l1
 where entry_no_com = entryno and
       l1.lov_name = 'PACKTYPES' and
       l1.code = dr.pktpe_packtype
 group by l1.description, pktpe_packtype;

cursor c13a( entryno number ) is
 select /*+ ALL_ROWS */ sum(qty) tot
 from detailrs dr
 where entry_no_com = entryno;
 
cursor c13b(shpid integer, entryno number) is
 select /*+ ALL_ROWS */ dr.entry_no_com, l1.description, pktpe_packtype, sum(qty) tot
 from detailrs dr, lov l1, receivals r, movements m
  where m.ship_id = shpid and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        dr.deliveryno in
         (select dr2.deliveryno from detailrs dr2 where dr2.entry_no_com = entryno) and
        l1.lov_name = 'PACKTYPES' and
        l1.code = dr.pktpe_packtype
 group by dr.entry_no_com, l1.description, pktpe_packtype;

cursor c13c( entryno number ) is
 select /*+ ALL_ROWS */ pktpe_packtype, sum(qty) tot
 from detailrs dr
 where entry_no_com = entryno
 group by pktpe_packtype;


cursor c13c1( entryno number ) is
 select distinct detaildesc
 from detailrs dr
 where entry_no_com = entryno;


cursor c13d( entryno number ) is
 select distinct l1.colb
 from detailrs dr, lov l1
 where entry_no_com = entryno and
       l1.lov_name = 'PACKTYPES' and
       l1.code = dr.pktpe_packtype;

 
cursor c14( entryno number ) is
 select /*+ ALL_ROWS */ distinct po
 from detailrs dr, pos p
 where entry_no_com = entryno and
       p.deliveryno = dr.deliveryno
 order by po;

cursor c14b(shpid integer, entryno number, parm2 varchar2) is
 select /*+ ALL_ROWS */ distinct po
 from detailrs dr, receivals r, movements m, pos p 
  where m.ship_id = shpid and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        dr.deliveryno in
         (select dr2.deliveryno from detailrs dr2 where dr2.entry_no_com = entryno) and
        p.deliveryno = dr.deliveryno
 order by po;

cursor c15( entryno number, pktpe varchar2 ) is
 select /*+ ALL_ROWS */ detaildesc
 from detailrs
 where entry_no_com = entryno and
       pktpe_packtype = pktpe
 group by detaildesc;

cursor c15b( entryno number ) is
 select distinct detaildesc
 from detailrs
 where entry_no_com = entryno
 group by detaildesc;

 
cursor c16( entryno number ) is
 select /*+ ALL_ROWS */ distinct movement_no
 from detailrs dr
 where entry_no_com = entryno 
 order by movement_no;

cursor c16a( entryno number ) is
 select /*+ ALL_ROWS */ distinct movement_no,camov_seal
 from detailrs dr
 where entry_no_com = entryno 
 order by movement_no;

cursor c16aa( entryno number ) is
 select count( dr.movement_no ) cgo
 from detailrs dr
 where entry_no_com = entryno and
 camov_seal is not null;


cursor c16b(v_movement varchar2, v_seal varchar2 ) is
select count(distinct r.cust_customer_id) as no_cust
from receivals r, detailrs dr
where
r.deliveryno = dr.deliveryno and
dr.movement_no = v_movement and
nvl(dr.camov_seal,'|') = v_seal;

cursor c16c( entryno number ) is
 select /*+ ALL_ROWS */ count(distinct m.movement_no) xctr, l.cola
 from detailrs dr, movements m,lov l
 where entry_no_com = entryno and
 dr.movement_no = m.movement_no and
 nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
 m.movement_type = 'CARGO' and
 l.lov_name = 'UNCTNTAB' and
 l.code = m.iso_container_type
 group by l.cola;

cursor c16d( entryno number ) is
 select /*+ ALL_ROWS */ count(distinct dr.qty) xbb
 from detailrs dr, movements m
 where entry_no_com = entryno and
 dr.movement_no = m.movement_no and
 nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
 m.movement_type = 'CONMOV';

-- tariff, rate, excise 
cursor c17( entryno number ) is
 select /*+ ALL_ROWS */ distinct p.entry_item entryitem, l1.cola tariff, l2.description, l2.colc, l2.colg, l2.colh
 from pos p, lov l1, lov l2,
 (select entry_no
  from strang.duty
  where entry_no = entryno and
       nvl(previous_entry_no,0) = 0 ) z2
 where l1.lov_name = 'INVENT' and
       l2.lov_name = 'TARIFF' and
       l1.cola = l2.code and
       l1.code = p.inventoryno and
       p.deliveryno in
       (select distinct deliveryno
        from detailrs dr
        where dr.entry_no_com = entryno)
		order by entryitem;

cursor c17x( entryno number ) is
 select /*+ ALL_ROWS */ distinct p1.entry_item entryitem, l1.cola tariff, l2.description, l2.colc, l2.colg, l2.colh
 from pos p1, lov l1, lov l2
 where l1.lov_name = 'INVENT' and
       l2.lov_name = 'TARIFF' and
       l1.cola = l2.code and
       l1.code = p1.inventoryno and
       p1.deliveryno in
       (select distinct deliveryno
        from detailrs dr
        where dr.entry_no_com = entryno
       ) and
      (p1.entry_item,l1.cola,l1.code) not in
      (select x1.entry_item,x1.cola, x1.code
       from
       (
        select /*+ ALL_ROWS */ distinct p2.entry_item, z1.cola, z1.code
        from strang.detailrs dr, strang.pos p2, strang.lov z1
        where entry_no_com = entryno and
              p2.deliveryno = dr.deliveryno and
              p2.inventoryno = z1.code and
              z1.lov_name = 'INVENT'
        order by p2.entry_item, z1.cola
       ) x1
      where rownum < 5
      )        order by p1.entry_item, l1.cola;

cursor c18( entryno number ) is
 select /*+ ALL_ROWS */ min(line_no) line_no, m.movement_no, ship_id
 from detailrs dr, movements m
 where entry_no_com = entryno and
       dr.movement_no = m.movement_no and
       nvl(m.seal,'|') = nvl(dr.camov_seal,'|')       
 group by m.movement_no,ship_id;
 
cursor c19( shipid integer ) is
 select /*+ ALL_ROWS */ * 
 from ships_airway 
 where ship_id = shipid;
 
 
 cursor c20(entryno number, tariff varchar2) is
  select /*+ ALL_ROWS */ distinct description
  from lov l1, detailrs dr, pos p
  where l1.cola = tariff and
        dr.entry_no_com = entryno and
        p.inventoryno = l1.code and
        dr.deliveryno = p.deliveryno and
        lov_name = 'INVENT';
 
 cursor c20a( tariff varchar2) is
  select /*+ ALL_ROWS */ *
  from lov l
  where l.code = tariff and
        l.lov_name = 'TARIFF';


cursor c21( entryno number ) is
 select /*+ ALL_ROWS */  max( p.entry_item ) tot
 from pos p, detailrs dr
 where dr.entry_no_com = entryno and
       dr.deliveryno = p.deliveryno; 
 
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c1arec		c1a%ROWTYPE;
 c2crec		c2c%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4arec		c4a%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c7arec		c7a%ROWTYPE;
 c7brec		c7b%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c9rec		c9%ROWTYPE;
 c10rec		c10%ROWTYPE;
 c11rec		c11%ROWTYPE;
 c11arec	c11a%ROWTYPE;
 c11brec	c11b%ROWTYPE;
 c11crec	c11c%ROWTYPE;
 c11drec	c11d%ROWTYPE;
 c12rec		c12%ROWTYPE;
 c13arec	c13a%ROWTYPE;
 c13crec	c13c%ROWTYPE;
 c13c1rec	c13c1%ROWTYPE;
 c13drec	c13d%ROWTYPE;
 c15brec	c15b%ROWTYPE;
 c16arec	c16a%ROWTYPE;
 c16aarec	c16aa%ROWTYPE;
 c16brec	c16b%ROWTYPE;
 c16crec	c16c%ROWTYPE;
 c16drec	c16d%ROWTYPE;
 c18rec		c18%ROWTYPE;
 c19rec		c19%ROWTYPE;
 c20rec		c20%ROWTYPE;
 c20arec	c20a%ROWTYPE;
 c21rec		c21%ROWTYPE;
 ttl		number;
 exr		number;
 temptot	number;
 ctr		number;
 num13		number;
 num14		number;
 tmp		varchar2(32767);
 tmp1		varchar2(32767);
 tmp2		varchar2(32767);
 tmp3		varchar2(32767);
 tmp4		varchar2(32767);
 tmp9		varchar2(32767);
 tmpx		varchar2(32767);
 mxlen          number;
 tmpxcounter    number;
 tmpxprevlineno number;
 tmpxcharprevlineno varchar2(100);
 bbtmp		integer;
 ctrno          number;
 ctr_code       varchar2(100);
 v_var      owa.vc_arr;

 
 function tot( entryno number, entryitem number, tariff varchar2 )
  return number
 is

   cursor c1(entryno number) is select * from duty where entry_no = entryno;
   cursor c2(entryno number,entryitem number,  tariff varchar2 ) is 
    select sum(nvl(tamount,0)+nvl(delivery_charge,0)) tot 
    from pos p
    where p.entry_item = entryitem and
          p.deliveryno in
          (select distinct deliveryno
           from detailrs dr
           where dr.entry_no_com = entryno);
          
   c1rec c1%ROWTYPE;
   c2rec c2%ROWTYPE;
   
 begin
    open c1(entryno);
    fetch c1 into c1rec;
    close c1;
    open c2(entryno,entryitem,tariff);
    fetch c2 into c2rec;
    close c2;
    return(round(c1rec.ratio_factor * c2rec.tot,2));
 end;


begin
 if parm_id = 'A00'
  then
  -- Calculate total items
  open c21(parm1);
   fetch c21 into c21rec;
   close c21;
    return( to_char(c21rec.tot) );
   end if;
   
 if parm_id = 'A000'
  then
  -- Calculate total packages
  open c13a(parm1);
   fetch c13a into c13arec;
   close c13a;
    return( to_char(c13arec.tot) );
   end if;   

 if parm_id = '000A'
  then
  -- Get first country of origin code
  open c4a(parm1);
   fetch c4a into c4arec;
   close c4a;
    return( c4arec.ctry_countrycode );
   end if;   
  
 if parm_id = 'A0'
  then
   -- Calculate total Page Numbers
   open c21(parm1);
   fetch c21 into c21rec;
   close c21;
   if c21rec.tot < 2
    then
     return( '1' );
   else
    c21rec.tot := trunc((c21rec.tot - 2) / 3) + 2;
    return( to_char(c21rec.tot) );
   end if;
   
 elsif parm_id = 'A1'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   WEBSYS.strangp.generate_ships_manifest( c1rec.ship_id ,'T_EXCISE', 'SHIP', parm1, WEBSYS.OLTP.USER_SITE );
   return( NULL );
    -- recalculate duty table values

 elsif parm_id = 'A2'
  then
   -- customers
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.cpc );
 elsif parm_id = 'A3'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   open c2('LOCATIONS',c1rec.portdisc);
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'A3_SAD'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   WEBSYS.strangp.generate_ships_manifest( c1rec.ship_id ,'T_EXCISE', 'SHIP', parm1, WEBSYS.OLTP.USER_SITE );
    -- recalculate duty table values
   return( c1rec.sad_cuo_code );
 elsif parm_id = 'A3_SAD_1'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.sad_cuo_bord );
 elsif parm_id = 'A4_SAD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     return( substr(c8rec.sad_typ_dec,1,2) );
 elsif parm_id = 'A5_SAD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     return( c8rec.sad_typ_proc );
 elsif parm_id = 'A6_SAD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     return( c8rec.sad_financial );
 elsif parm_id = 'A7_SAD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     return( c8rec.sad_cty_1dlp );
 elsif parm_id = 'A8_SAD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     return( c8rec.sad_tra_cty );
 elsif parm_id = 'A9_SAD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     return( c8rec.sad_cty_expcod );
 elsif parm_id = 'A10_SAD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     return( c8rec.sad_cty_destcod );
 elsif parm_id = 'A11_SAD'
   then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;   
   open c2('UNLOCTAB',c1rec.sad_054_lop_cod);
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'A12_SAD'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
     return( c1rec.sad_054_lop_cod );
 elsif parm_id = 'A13_SAD'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
     return( c1rec.sad_057_loc_goods );
 elsif parm_id = 'A14_SAD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     if c8rec.sad_whs_cod is not null
       then
       return( c8rec.sad_whs_cod || '/' );
     else
       return( null );
     end if;  
 elsif parm_id = 'A15_SAD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     return( c8rec.sad_whs_time );
 elsif parm_id = 'A16_SAD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     if c8rec.bank_ref_no = 'ENTRY_NO' 
     then
       return( parm1 );
     else
       return( c8rec.bank_ref_no );
     end if;
 elsif parm_id = 'A17_SAD'
 then
   if length( parm1 ) <= 11
   then
     return( parm1 );
   else
     return( substr(parm1,length(parm1)-6,7) );
   end if;  
 elsif parm_id = 'A18_SAD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     return( c8rec.sad_tot_fees );

 elsif parm_id = 'A19_SAD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     return( c8rec.method_of_payment );

 elsif parm_id = 'A20_SAD'
  then
   tmp:= NULL;
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     tmp:= snvl2(c8rec.attachments_invoices, tmp || c8rec.attachments_invoices || ', ', tmp, 0 );
     tmp:= snvl2(c8rec.attachments_packing, tmp || c8rec.attachments_packing || ', ', tmp, 0 );
     tmp:= snvl2(c8rec.attachments_packing, tmp || c8rec.attachments_order || ', ', tmp, 0 );
     tmp:= snvl2(c8rec.attachments_packing, tmp || c8rec.attachments_licence || ', ', tmp, 0 );
     tmp:= snvl2(c8rec.attachments_packing, tmp || c8rec.attachments_freight || ', ', tmp, 0 );
     tmp:= snvl2(c8rec.attachments_packing, tmp || c8rec.attachments_other || ', ', tmp, 1 );   
     return( tmp );
   
 elsif parm_id = 'A21_SAD'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   tmp:=1;  -- 20150312
   if c9rec.duty > 0
   then
     tmp:=tmp+1;  -- 20150312
   end if;  
   if c9rec.excise > 0
   then
     tmp:=tmp+1;
   end if;  
   if c9rec.vat > 0
   then
     tmp:=tmp+1;
   end if;  
   if c9rec.levy > 0
   then
     tmp:=tmp+1;
   end if;  
     return( tmp );
  
   
--     return( to_char(c9rec.other_costs * nvl(c7rec.exrate,1),'99999999.99') );
     
 elsif parm_id = 'A4'
  then
   open c7b(parm1);
   fetch c7b into c7brec;
   close c7b;
   if c7brec.suppcount > 1 then
    return( 'VARIOUS SUPPLIERS AS PER INVOICES:' );
   else
    return( null );
   end if; 
 elsif parm_id = 'A4X'
  then
   open c7a(parm1);
   fetch c7a into c7arec;
   close c7a;
   return( c7arec.customer );  -- 20150312
 elsif parm_id = 'A4X1'  -- 20150312
  then
   open c7a(parm1);
   fetch c7a into c7arec;
   close c7a;
   return( c7arec.street||', '||c7arec.suburb );
 elsif parm_id = 'A4XX'
  then
   open c7a(parm1);
   fetch c7a into c7arec;
   close c7a;
   return( c7arec.state || ' ' || c7arec.postcode );  -- 20150312
 elsif parm_id = 'A4XX1'
  then
   open c7a(parm1);
   fetch c7a into c7arec;
   close c7a;
   return( c7arec.country ); -- 20150312
 elsif parm_id = 'A5'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     return( c8rec.p2acode );
 elsif parm_id = 'A6'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.customer );
 elsif parm_id = 'A6X'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.street || ' ' || c8rec.suburb || ' ' ||  c8rec.state || ' ' || c8rec.postcode );

 elsif parm_id = 'A6XX'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.country );

 elsif parm_id = 'A7'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   open c2a('COUNTRIES',c7rec.curr);
   fetch c2a into c2rec;
   close c2a;
   return( c2rec.code );

 elsif parm_id = 'A7X'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   open c2a('COUNTRIES',c7rec.curr);
   fetch c2a into c2rec;
   close c2a;
   return( c2rec.description );


 elsif parm_id = 'A8'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     return( c8rec.terms_of_delivery );
 elsif parm_id = 'A9'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   return( round(nvl(c9rec.exrate,1),4) );
 elsif parm_id = 'AA'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     return( c9rec.ratio_factor );
    else
     return( '0.00000' );
   end if;
 elsif parm_id = 'AB'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   open c2('LOCATIONS',c1rec.portload);
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
   
 elsif parm_id = 'AB_1'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   open c2c(c1rec.portload);
   fetch c2c into c2crec;
   close c2c;
   return( c2crec.code );
   
 elsif parm_id = 'AB_2'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   open c2c(c1rec.portdisc);
   fetch c2c into c2crec;
   close c2c;
   return( c2crec.code );
   
 elsif parm_id = 'AB_3'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.shipcountry );

 elsif parm_id = 'AC'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   open c10(c8rec.customs_agent);
   fetch c10 into c10rec;
   close c10;
   return( c10rec.customer );
 elsif parm_id = 'AD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.account_number );
 elsif parm_id = 'AE'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     open c3(parm1,parm2);
     fetch c3 into c3rec;
     close c3;
     return( to_char(c3rec.sm,'99999999.99') );
    else
     return( '0.00' );
   end if;
 elsif parm_id in ('AE_1','AE_2')
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     if parm_id = 'AE_1'
       then
       return( to_char(c9rec.guarrantee_amount,'99999999.99'));
     end if;
       return(to_char(c9rec.guarrantee_date,'dd.mm.yyyy'));     
    else
     return( NULL );
   end if;
   
 elsif parm_id = 'AF'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   open c2a('COUNTRIES',c7rec.curr);
   fetch c2a into c2rec;
   close c2a;
   return( c2rec.cola );
   
 elsif parm_id = 'AG'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     return( to_char(round(nvl(c9rec.correct_freight,0) * nvl(c9rec.exrate,1),2),'99999999.99') );
    else
     return( '0.00' );
   end if;

 elsif parm_id = 'AGI'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     return( to_char(round(nvl(c9rec.internal_freight,0) * nvl(c9rec.exrate,1),2),'99999999.99') );
    else
     return( '0.00' );
   end if;


   
 elsif parm_id = 'AH' 
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.licence_no );

 elsif parm_id = 'AHH' 
  then
   return( to_char(sysdate,'YYYY')  || ' / ' ||  parm1 );

   
 elsif parm_id = 'AI'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     return( to_char(round(c9rec.insurance * nvl(c9rec.exrate,1),2),'99999999.99') );
    else
     return( '0.00' );
   end if;
   
 elsif parm_id = 'AJ'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     return( to_char(round(c9rec.other_costs * nvl(c9rec.exrate,1),2),'99999999.99') );
    else
     return( '0.00' );
   end if;

 elsif parm_id = 'AJD'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     return( to_char(round(c9rec.deductions * nvl(c9rec.exrate,1),2),'99999999.99') );
    else
     return( '0.00' );
   end if;

   
 elsif parm_id = 'AK'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   if c1rec.ship_airway = 'S'
    then
     return( 'SEA&nbsp;&nbsp;&nbsp;&nbsp;1' );
   elsif c1rec.ship_airway = 'A'
    then
     return ('AIR&nbsp;&nbsp;&nbsp;&nbsp;2');
   else
    return( NULL );
   end if;
 elsif parm_id = 'AL'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( to_char(c1rec.estarrive,'DD.MM.YYYY') );
 elsif parm_id = 'AM'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_invoices,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AN'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_packing,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AO'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_order,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AP'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_licence,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AQ'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_freight,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AR'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_other,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
   
 elsif parm_id = 'AS'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   if c1rec.ship_airway = 'A' then
     open c1a(parm1);
       fetch c1a into c1arec;
     close c1a;
     return( nvl(c1arec.flight,(c1rec.shipname || ' ' || c1rec.voy)) );
   elsif substr(c1rec.voy,length(nvl(c1rec.voy,'A')),1) = 'B' then
     return( c1rec.shipname || ' ' || substr(c1rec.voy,1,length(c1rec.voy)-1) || 'N');
   else
      return( c1rec.shipname || ' ' || c1rec.voy );
   end if;
 elsif parm_id = 'AS_REG'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.manifest_reg );

   
 elsif parm_id = 'AT_SAD' -- 20150311
  then
   open c11a(parm1);
   fetch c11a into c11arec;
   close c11a;
   if c11arec.cnt = 0
    then
     open c11b(parm1);
     fetch c11b into c11brec;
     close c11b;
      if c11brec.mn = c11brec.mx
       then
        return( c11brec.mn );
       else
        open c1(parm1);
         fetch c1 into c1rec;
        close c1;
        open c11d(c1rec.ship_id, parm1, parm2);
         fetch c11d into c11drec;
        close c11d;
        if ( c11drec.no_of_line_nos - ( c11brec.mx - c11brec.mn + 1 ) ) = 0
        then
         return( c11brec.mn || ' - ' || c11brec.mx );
        else
         open c1(parm1);
          fetch c1 into c1rec;
         close c1;
         tmpx := '' ;
         tmpxcounter := 0 ;
         tmpxprevlineno := 0;
         tmpxcharprevlineno := NULL;
         for c11crec in c11c(c1rec.ship_id, parm1, parm2) loop
          if tmpxcounter = 0
           then
            tmpx := tmpx || ', ' || c11crec.line_no;
          else
            if (tmpxprevlineno = to_number(c11crec.line_no,'99999') - 1)
              then
               if (substr(tmpx,(length(tmpx)-length(tmpxcharprevlineno)),1) = ' ')
                  then
                   tmpx := tmpx ||'-'|| c11crec.line_no;
               else
                   if substr(tmpx,(length(tmpx)-length(tmpxcharprevlineno)),1) = '-'
                     then
                     tmpx := substr(tmpx,1,(length(tmpx)-length(tmpxcharprevlineno))) || c11crec.line_no;
                   else
                     tmpx := tmpx || ', ' || c11crec.line_no;
                   end if;
               end if;
            else
              tmpx := tmpx || ', ' || c11crec.line_no;
            end if;
          end if; 
          tmpxcounter := tmpxcounter + 1;  
          tmpxprevlineno := to_number(c11crec.line_no,'99999');
          tmpxcharprevlineno := c11crec.line_no;
         end loop;
        return( substr(tmpx,2) );
       end if;  
      end if;
    else
     open c1(parm1);
     fetch c1 into c1rec;
     close c1;
     for c11rec in c11(c1rec.ship_id, parm1, parm2) loop
      if c11rec.mn = c11rec.mx
       then
        tmp := tmp || ',' || c11rec.mn;
       else
        tmp := tmp || ',' ||  c11rec.mn || ' - ' || c11rec.mx;
      end if;
     end loop;
     return( substr(tmp,2) );
   end if;
   
 elsif parm_id = 'AU'
  then
   open c12(parm1);
   fetch c12 into c12rec;
   close c12;
   return( c12rec.bol );
   
 elsif parm_id = 'AV'
  then
   /*
   for c13rec in c13( parm1 ) loop
    tmp := tmp || htf.nl || c13rec.tot;
   end loop;
   return( substr( tmp, (length(htf.nl)*1)+1) );
   */
   return( NULL );
   


 elsif parm_id = 'AWW'
  then
     -- PO
     for c14rec in c14( parm1 ) loop
      tmp := tmp || c14rec.po || ',';
     end loop;
     tmp := substr(tmp,1,length(tmp)-1) ;
   return( substr(tmp,1,50) );


 elsif parm_id = 'AWWW'
  then
     for c13rec in c13( parm1 ) loop
      tmp9 := c13rec.description ;
      if substr(tmp9,length(tmp9)-2,length(tmp9)) in ('STC','STB')
        then
          tmp9 :=   substr( tmp9,1,length(tmp9)-4) ;
      end if;  
      tmp := tmp || c13rec.tot || ' ' || tmp9 || ',';
     end loop;
   tmp := substr(tmp,1,length(tmp)-1);
   return( substr(tmp,1,50) );

 elsif parm_id = 'AWWW_1'
  then
   open c13a(parm1);
   fetch c13a into c13arec;
   close c13a;
   return( c13arec.tot );

 elsif parm_id = 'AWWW_2'
  then
     bbtmp := 0;
     for c13drec in c13d( parm1 ) loop
      bbtmp := bbtmp + 1;
      if bbtmp > 1 then
      tmp := 'OT';
      else
        tmp := nvl(c13drec.colb,'OT') ;
      end if;  
--      tmp9 := c13drec.colb ;
--      tmp := tmp || tmp9 || ',';
     end loop;
--   tmp := substr(tmp,1,length(tmp)-1);
   return(tmp);


 elsif parm_id = 'AWWW_3'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   return( c9rec.previous_entry_no );

 elsif parm_id = 'AWWW_1X'
  then
   tmp:='';
   tmp9:='';
   for c16crec in c16c( parm1 ) loop
    if nvl(c16crec.xctr,0) > 0 then
      tmp9 := c16crec.xctr||' X '|| upper(c16crec.cola) ;
      tmp := tmp || tmp9 || ',';
    end if;
   end loop;
   for c16drec in c16d( parm1 ) loop
    if nvl(c16drec.xbb,0) > 0 then
      tmp9 := c16drec.xbb||' X '|| 'BREAK BULK' ;
      tmp := tmp || tmp9 || ',';
    end if;
   end loop;
   tmp := substr(tmp,1,length(tmp)-1)||' STC:';
   return(tmp);


 elsif parm_id = 'AWWW_SAD'
  then
     tmp:=null;
     tmp1:=null;
     tmpxcounter:=0;
     tmp9:=null;
     mxlen:=35;
     for c13crec in c13c( parm1 ) loop
       tmp:= tmp|| c13crec.tot ||' '|| c13crec.pktpe_packtype || ',';
     end loop;
     tmp := substr(tmp,1,length(tmp)-1)|| ' STC ';
     for c13c1rec in c13c1( parm1 ) loop
      tmp := tmp || c13c1rec.detaildesc ||',' ;
      mxlen := 35 - length(tmp);
      if mxlen < 5
      then
        exit;
      end if;  
     end loop;
   -- return( substr(tmp,1,length(tmp)-1)),1,35) );
return( substr(tmp,1,35) );
 elsif parm_id = 'AWWWW'
 /* then
   -- Movements
   for c16rec in c16( parm1 ) loop
    ctr := ctr + 1;
    tmp := tmp || c16rec.movement_no || ', ';
    if ctr >= 3
      then exit ;
    end if;  
   end loop;
 */
 then
   ctrno := 0;
   for c16rec in c16( parm1 ) loop
   if ctrno = 0
   then
     ctr_code := substr(trim(c16rec.movement_no) , 1, 4);
     tmp := '<b><u>' || ctr_code || ':</u></b>';
     ctrno := ctrno + 1;
   end if;
   if substr(trim(c16rec.movement_no) , 1, 4) <> ctr_code
    then
     ctr_code := substr(trim(c16rec.movement_no) , 1, 4);
     tmp := tmp || '<b><u>' || ctr_code || ':</b></u> ';
   end if;
   tmp := tmp || trim(substr(trim(c16rec.movement_no), 5)) || ' ';
  end loop;

   tmp := substr(tmp,1,length(tmp)-1);
   
   return( tmp );

 elsif parm_id in ('SAD_AWWWW_1', 'SAD_AWWWW_2', 'SAD_AWWWW_3', 'SAD_AWWWW_4')
  then
   ctr := to_number(substr(parm_id, -1));
   tmp := null;
   for c16rec in c16( parm1 ) loop
    if c16%ROWCOUNT = ctr
	 then
	  if length(c16rec.movement_no) <> 11 then
	    tmp := c16rec.movement_no;
	  else
	    tmp := substr(c16rec.movement_no,1,4)||' '|| substr(c16rec.movement_no,5,6)||'-'|| substr(c16rec.movement_no,11,1);
	  end if;
	  exit;
	end if;
   end loop;
     return(tmp);

 elsif parm_id = 'SAD_AWWWW_5'
  then
   tmp := 'false';
   open c16aa(parm1);
    fetch c16aa into c16aarec;
   close c16aa;
   if nvl(c16aarec.cgo,0) >= 1
        then
     tmp:='true';
   end if;
   return(tmp);
   
 elsif parm_id = 'SAD_AWWWW_6'
  then
   tmp := 1;
   open c1(parm1);
    fetch c1 into c1rec;
   close c1;
   if c1rec.ship_airway = 'A'
    then
    tmp := 4; 
   end if; 
   return( tmp );
  
 elsif parm_id = 'SAD_AWWWW_7'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     return( c8rec.terms_of_payment );

 elsif parm_id = 'SAD_AWWWW_8'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     return( c8rec.bank_code );
  
 elsif parm_id = 'SAD_AWWWW_9'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     return( c8rec.branch );
  
  
 elsif parm_id in ('SAD_AWWWWW_1', 'SAD_AWWWWW_2', 'SAD_AWWWWW_3')
  then
  
   open c9( parm1 );
   fetch c9 into c9rec;
   close c9;
--   open c20a( parm2 );
--   fetch c20a into c20arec;
--   close c20a;
--   tmp2:=c20arec.cold;
   open c11a(parm1);
   fetch c11a into c11arec;
   close c11a;
   if c11arec.cnt = 0 -- no partshipments
    then
     for c20rec in c20(parm1,parm2) loop
     tmp := tmp ||', ' || c20rec.description;
     end loop;
     if tmp2 is not null
     then
       tmp := tmp ||', ' || tmp2;
     end if;
   else
     open c1(parm1);
     fetch c1 into c1rec;
     close c1;
     for c20rec in c20(parm1,parm2) loop
      tmp := tmp || ', ' || c20rec.description;
     end loop;
   end if;

  if substr(tmp,1,2) = ', ' then
     tmp:= substr(tmp,3,length(tmp)+1);
   else
     tmp := substr(tmp,1,length(tmp));
   end if;
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
      
   if c9rec.previous_entry_no is not null
    then
     open c18(c9rec.previous_entry_no);
     fetch c18 into c18rec;
     close c18;
     open c19(c18rec.ship_id);
     fetch c19 into c19rec;
     close c19;
     tmp := 'DUTY PAYMENT MADE ON THE MANIFEST FOR THE ' ||
     c19rec.shipname || ' ' || c19rec.voy || ', LINE NUMBER ' || c18rec.line_no || '.' ||
     ' PART SHIPMENT OF CONTAINER NO ' || c18rec.movement_no || '.';
   end if;
 
   tmp2 := tmp;
   if length(tmp) > 44
    then
     ctr := instr(substr(tmp, 1, 44) ,' ', -1);
     if ctr = 0 then ctr := 44; end if;
     tmp2 := substr(tmp, 1, ctr);
   end if;	
   open c20a( parm2 );
    fetch c20a into c20arec;
      tmp:= c20arec.cold;
   close c20a;
    
       tmp4 := tmp;
       if length(tmp) > 44
        then
    	 ctr := instr(substr(tmp, 1, 44) ,' ', -1);
         if ctr = 0 then ctr := 44; end if;
         tmp4 := substr(tmp, 1, ctr);
    	 tmp3 := substr(tmp, length(tmp4));
    	 if length(tmp) > 88
    	  then
    	   ctr := instr(substr(tmp, length(tmp4), 44) ,' ', -1);
           if ctr = 0 then ctr := 44; end if;
           tmp3 := substr(tmp, length(tmp4), ctr);
    	   tmp4 := substr(tmp, length(tmp4) + length(tmp3), 44);
    	 end if;
       end if;	
   case parm_id
   when 'SAD_AWWWWW_1' then return(tmp2);  -- inventory description
   when 'SAD_AWWWWW_2' then return(tmp3);  -- second line of tariff description
   when 'SAD_AWWWWW_3' then return(tmp4);  -- first line of tariff description
   else return(null);
   end case;
   
 elsif parm_id = 'AWWWWW'
  then
/*   open c9( parm1 );    This commented out section will return the detailr description rather than the inventory description which is currently used MAR 06
   fetch c9 into c9rec;
   close c9;
   open c11a(parm1);
   fetch c11a into c11arec;
   close c11a;
   if c11arec.cnt = 0 -- no partshipments
    then
    for c15brec in c15b( parm1 ) loop
      tmp := tmp || c15brec.detaildesc || ',';
    end loop;
    if length(tmp) < 60
      then
      tmp := tmp || htf.nl;
    else  
      tmp:= substr(tmp,1,60) || htf.nl || substr(tmp,61,120);
    end if;
   else
     open c1(parm1);
     fetch c1 into c1rec;
     close c1;
      for c15brec in c15b( parm1 ) loop
       tmp := tmp || c15brec.detaildesc || ',';
      end loop;
      if length(tmp) > 60
      then
        tmp := substr(tmp,1,60);
      end if;
   end if;
      
   tmp := substr(tmp,1,length(tmp)-1);

   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
      
   if c9rec.previous_entry_no is not null
    then
     open c18(c9rec.previous_entry_no);
     fetch c18 into c18rec;
     close c18;
     open c19(c18rec.ship_id);
     fetch c19 into c19rec;
     close c19;
     tmp := tmp || htf.nl ||
     'DUTY PAYMENT MADE ON THE MANIFEST FOR THE ' ||
     c19rec.shipname || ' ' || c19rec.voy || ', LINE NUMBER ' || c18rec.line_no || '.<BR>WARRANT NO: _____ ' ||
     ' PART SHIPMENT OF CONTAINER NO ' || c18rec.movement_no || '.';
   end if;
*/

   open c9( parm1 );
   fetch c9 into c9rec;
   close c9;
   open c11a(parm1);
   fetch c11a into c11arec;
   close c11a;
   if c11arec.cnt = 0 -- no partshipments
    then
     for c20rec in c20(parm1,parm2) loop
       tmp := tmp || ', ' || c20rec.description;
     end loop;
    if length(tmp) > 60
     then
      tmp:= substr(tmp,1,60) || htf.nl || substr(tmp,61,120);
    end if;

   else
     open c1(parm1);
     fetch c1 into c1rec;
     close c1;
     for c20rec in c20(parm1,parm2) loop
      tmp := tmp || ', ' || c20rec.description;
     end loop;
     if length(tmp) > 60
      then
        tmp := substr(tmp,1,60);
     end if;
    end if;
--         tmp2 := substr(tmp2,length(', ')+1);
   if substr(tmp,1,2) = ', ' then
     tmp:= substr(tmp,3,length(tmp)+1);
   else
     tmp := substr(tmp,1,length(tmp));
   end if;
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
      
   if c9rec.previous_entry_no is not null
    then
     open c18(c9rec.previous_entry_no);
     fetch c18 into c18rec;
     close c18;
     open c19(c18rec.ship_id);
     fetch c19 into c19rec;
     close c19;
--     tmp := tmp || htf.nl ||
     tmp := 'DUTY PAYMENT MADE ON THE MANIFEST FOR THE ' ||
     c19rec.shipname || ' ' || c19rec.voy || ', LINE NUMBER ' || c18rec.line_no || '.<BR>WARRANT NO: _____ ' ||
     ' PART SHIPMENT OF CONTAINER NO ' || c18rec.movement_no || '.';
   end if;
   return(tmp);


/*
 elsif parm_id = 'AW'
  then
   open c9( parm1 );
   fetch c9 into c9rec;
   close c9;
   open c11a(parm1);
   fetch c11a into c11arec;
   close c11a;
   if c11arec.cnt = 0 -- no partshipments
    then
     tmp := htf.tableopen;
     for c13rec in c13( parm1 ) loop
      tmp := tmp || htf.tablerowopen || htf.tabledata(c13rec.tot, cattributes=>'width=50 valign="TOP" style="font-size:7.0pt; font-family:Arial"');
      for c15rec in c15( parm1, c13rec.pktpe_packtype ) loop
       tmp2 := tmp2 || c15rec.detaildesc || ',';
      end loop;
      
      tmp := tmp || htf.tabledata(c13rec.description || ':' || substr(tmp2,1,length(tmp2)-1), cattributes=>'valign="TOP" style="font-size:7.0pt; font-family:Arial"') || htf.tablerowclose;
      tmp2 := NULL;
     end loop;
     tmp := tmp || htf.tableclose;
     -- PO
     for c14rec in c14( parm1 ) loop
      tmp := tmp || c14rec.po || ',';
     end loop;
   else
     open c1(parm1);
     fetch c1 into c1rec;
     close c1;
     tmp := htf.tableopen;
     for c13brec in c13b(c1rec.ship_id, parm1) loop
      tmp := tmp || htf.tablerowopen || htf.tabledata(c13brec.tot, cattributes=>'width=50 valign="TOP" style="font-size:7.0pt; font-family:Arial"');
      for c15rec in c15( c13brec.entry_no_com, c13brec.pktpe_packtype ) loop
       tmp2 := tmp2 || c15rec.detaildesc || ',';
      end loop;
      tmp := tmp || htf.tabledata(c13brec.description || ':' || substr(tmp2,1,length(tmp2)-1), cattributes=>'valign="TOP" style="font-size:7.0pt; font-family:Arial"') || htf.tablerowclose;
      tmp2 := NULL;
     end loop;
     tmp := tmp || htf.tableclose;
     -- PO
     for c14brec in c14b(c1rec.ship_id, parm1, parm2) loop
      tmp := tmp || c14brec.po || ',';
     end loop;
   end if;
   
   -- Movements
   for c16rec in c16( parm1 ) loop
    tmp := tmp || c16rec.movement_no || ',';
   end loop;
   
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   
   tmp := substr(tmp,1,length(tmp)-1) || htf.nl || htf.nl || c1rec.pcomment;
   
   if c9rec.previous_entry_no is not null
    then
     open c18(c9rec.previous_entry_no);
     fetch c18 into c18rec;
     close c18;
     open c19(c18rec.ship_id);
     fetch c19 into c19rec;
     close c19;
     tmp := tmp || htf.nl ||
     'I HEREBY DECLARE THAT THE VALUE FOR THE ABOVE MENTIONED GOODS HAD BEEN ENTERED FOR DUTY PAYMENT ON THE MANIFEST FOR THE ' ||
     c19rec.shipname || ' ' || c19rec.voy || ', LINE NUMBER ' || c18rec.line_no || '.<BR>WARRANT NO: _____________________ ' ||
     ' PART SHIPMENT OF CONTAINER NO ' || c18rec.movement_no || '.' || htf.nl;
     open c1(parm1);
     fetch c1 into c1rec;
     close c1;
     open c10(c1rec.customs_agent);
     fetch c10 into c10rec;
     close c10;
     tmp := tmp || c10rec.customer || ' ' || c10rec.street;
   end if;
   return( tmp );
*/


   
 elsif parm_id = 'AX'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   open c10(c8rec.customs_agent);
   fetch c10 into c10rec;
   close c10;
   return( c10rec.customer );
 elsif parm_id = 'AY'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.position );
   
 elsif parm_id = 'B1-OLD'
  then
   -- in new form calculation is simplified
   return( NULL );
   ttl := 0;
   for c17rec in c17(parm1) loop
     ttl := ttl + tot(parm1,c17rec.entryitem,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100);
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );
 elsif parm_id = 'B2-OLD'
  then
   ttl := 0;
   for c17rec in c17(parm1) loop
     temptot := tot(parm1,c17rec.entryitem,c17rec.tariff);
     ttl := ttl + ((temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100));
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );
 elsif parm_id = 'B3-OLD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   ttl := 0;
   for c17rec in c17(parm1) loop
    temptot := tot(parm1,c17rec.entryitem,c17rec.tariff);
    ttl := ttl + 
       (temptot +
          temptot * (nvl(to_number(c17rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

  elsif parm_id = 'B2'
  then
   -- Total First Page
   ttl := 0;
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   for c17rec in c17(parm1) loop
     if c17%ROWCOUNT > 4 then exit; end if;
     ttl := ttl + tot(parm1,c17rec.entryitem,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100);
   end loop;
   for c17rec in c17(parm1) loop
     if c17%ROWCOUNT > 4 then exit; end if;
     ttl := ttl + ((tot(parm1,c17rec.entryitem,c17rec.tariff) + tot(parm1,c17rec.entryitem,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100));
   end loop;
   for c17rec in c17(parm1) loop
    if c17%ROWCOUNT > 4 then exit; end if;
    temptot := tot(parm1,c17rec.entryitem,c17rec.tariff);
    ttl := ttl + 
       (temptot +
          temptot * (nvl(to_number(c17rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;
/* 2 % LEVY CALCULATION 
*/
   for c17rec in c17(parm1) loop
    if c17%ROWCOUNT > 4 then exit; end if;
    temptot := tot(parm1,c17rec.entryitem,c17rec.tariff);

    ttl := ttl + 
       round(((nvl(to_number(c1rec.levy_rate),0)/100)*(temptot +
		(round(temptot * (nvl(to_number(c17rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * 
                (nvl(to_number(c17rec.colc),0)/100),2)))),2);        
   end loop;
   
   
   
   return( to_char(round(ttl,2),'999999990.99') );

  elsif parm_id = 'B3'
  then
   -- Total Other Pages
   ttl := 0;
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   for c17rec in c17(parm1) loop
     if c17%ROWCOUNT > 4 then 
      ttl := ttl + tot(parm1,c17rec.entryitem,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100);
     end if;
   end loop;
   for c17rec in c17(parm1) loop
     if c17%ROWCOUNT > 4 then 
       ttl := ttl + ((tot(parm1,c17rec.entryitem,c17rec.tariff) + tot(parm1,c17rec.entryitem,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100));
      end if;
   end loop;
   for c17rec in c17(parm1) loop
    if c17%ROWCOUNT > 4 then 
     temptot := tot(parm1,c17rec.entryitem,c17rec.tariff);
     ttl := ttl + 
       (temptot +
          temptot * (nvl(to_number(c17rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
     end if;
   end loop;

/* 2 % LEVY CALCULATION
*/
   for c17rec in c17(parm1) loop
    if c17%ROWCOUNT > 4 then 
     temptot := tot(parm1,c17rec.entryitem,c17rec.tariff);
     ttl := ttl + 
       round(((nvl(to_number(c8rec.levy_rate),0)/100)*(temptot +
		(round(temptot * (nvl(to_number(c17rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * 
                (nvl(to_number(c17rec.colc),0)/100),2)))),2);
     end if;
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

elsif parm_id = 'B4'
  then
   -- Total All Pages
   ttl := 0;
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   for c17rec in c17(parm1) loop
     ttl := ttl + tot(parm1,c17rec.entryitem,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100);
   end loop;
   for c17rec in c17(parm1) loop
     ttl := ttl + ((tot(parm1,c17rec.entryitem,c17rec.tariff) + tot(parm1,c17rec.entryitem,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100));
   end loop;
   for c17rec in c17(parm1) loop
    temptot := tot(parm1,c17rec.entryitem,c17rec.tariff);
    ttl := ttl + 
       (temptot +
          temptot * (nvl(to_number(c17rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;
/* 2 % LEVY CALCULATION
*/
   for c17rec in c17(parm1) loop
    temptot := tot(parm1,c17rec.entryitem,c17rec.tariff);
     ttl := ttl + 
       round(((nvl(to_number(c8rec.levy_rate),0)/100)*(temptot +
		(round(temptot * (nvl(to_number(c17rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * 
                (nvl(to_number(c17rec.colc),0)/100),2)))),2);
   end loop;
   
   return( to_char(round(ttl,2),'999999990.99') );

elsif parm_id = 'B4_SAD'  -- includes entry fee
  then
   -- Total All Pages
   ttl := 0;
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
-- DUTY
   for c17rec in c17(parm1) loop
     ttl := ttl + tot(parm1,c17rec.entryitem,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100);
   end loop;
-- EXCISE BY RATE
----   for c17rec in c17(parm1) loop
----     ttl := ttl + ((tot(parm1,c17rec.entryitem,c17rec.tariff) + tot(parm1,c17rec.entryitem,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100));
----   end loop;
-- EXCISE BY RATE AND QUANTITY IE COLH X POS.EXCISE_QTY
   for c17rec in c17(parm1) loop
    tmp:=0;   
    if c17rec.colc > 0  -- excise %
      then
       tmp := 1;
    end if;   
    if c17rec.colh > 0  -- excise charge/unit
      then
       tmp := 2;
    end if;   
    tmp2:= nvl(c17rec.colg,'HIGHER');
    if (c17rec.colc > 0) and (c17rec.colh > 0) and (tmp2 = 'BOTH')
      then
       tmp := 3;
    end if;   
    if (c17rec.colc > 0) and (c17rec.colh > 0) and (tmp2 = 'LOWER')
      then
       tmp := 4;
    end if;   
    if (c17rec.colc > 0) and (c17rec.colh > 0) and (tmp2 = 'HIGHER')
      then
       tmp := 5;
    end if;   
 if tmp > 0
 then
   num13:= to_number(f_generate_sad_calculate_com( 'ZZ_2',parm1,c17rec.entryitem,c17rec.tariff,1,1 )); -- excise rate tax amount
   num14:= to_number(f_generate_sad_calculate_com( 'ZZ_2_2',parm1,c17rec.entryitem,c17rec.tariff,1,1 )); -- excise by unit tax amount
   if tmp = 4
   then
    if num13 < num14
    then
     tmp := 1;
    else
     tmp := 2;
    end if; 
   end if;
   if tmp = 5
   then
    if num13 > num14
    then
     tmp := 1;
    else
     tmp := 2;
    end if; 
   end if;
   case 
    when tmp = 1 then
     ttl := ttl + num13;
    when tmp = 2 then 
     ttl := ttl + num14;
    when tmp = 3 then
     ttl := ttl + num13 + num14;
   end case;
 end if;
 end loop;

-- VAT/GST
   temptot:=0;
   for c17rec in c17(parm1) loop
    temptot := temptot+tot(parm1,c17rec.entryitem,c17rec.tariff);
   end loop;
   ttl := ttl + ((temptot+ttl)*(nvl(to_number(c8rec.vat),0)/100));
   return( to_char(round(temptot,2),'999999990.99') ); -- 20130430


/*   for c17rec in c17(parm1) loop
    
    temptot := tot(parm1,c17rec.entryitem,c17rec.tariff);
    ttl := ttl + 
       (temptot +
          temptot * (nvl(to_number(c17rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;
   return( to_char(round(ttl,2),'999999990.99') ); -- 20130430
*/
/* 2 % LEVY CALCULATION
*/
   for c17rec in c17(parm1) loop
    temptot := tot(parm1,c17rec.entryitem,c17rec.tariff);
     ttl := ttl + 
       round(((nvl(to_number(c8rec.levy_rate),0)/100)*(temptot +
		(round(temptot * (nvl(to_number(c17rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * 
                (nvl(to_number(c17rec.colc),0)/100),2)))),2);
   end loop;
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if c8rec.sad_tot_fees is not null
    then
     ttl := ttl + c8rec.sad_tot_fees;
    end if;
   
   return( to_char(round(ttl,2),'999999990.99') );


 elsif parm_id = 'XB1'
  then
   ttl := 0;
   for c17xrec in c17x(parm1) loop
     ttl := ttl + tot(parm1,c17xrec.entryitem,c17xrec.tariff) * (nvl(to_number(c17xrec.description),0)/100);
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

 elsif parm_id = 'XB2'
  then
   ttl := 0;
   for c17xrec in c17x(parm1) loop
     temptot := tot(parm1,c17xrec.entryitem,c17xrec.tariff);
     ttl := ttl + ((temptot + temptot * (nvl(to_number(c17xrec.description),0)/100)) * (nvl(to_number(c17xrec.colc),0)/100));
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

 elsif parm_id = 'XB3'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   ttl := 0;
   for c17xrec in c17x(parm1) loop
    temptot := tot(parm1,c17xrec.entryitem,c17xrec.tariff);
    ttl := ttl + 
       (temptot +
          temptot * (nvl(to_number(c17xrec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17xrec.description),0)/100)) * (nvl(to_number(c17xrec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

 elsif parm_id = 'XB4'
  then
   ttl := 0;
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   for c17xrec in c17x(parm1) loop
     ttl := ttl + tot(parm1,c17xrec.entryitem,c17xrec.tariff) * (nvl(to_number(c17xrec.description),0)/100);
   end loop;
   for c17xrec in c17x(parm1) loop
     ttl := ttl + ((tot(parm1,c17xrec.entryitem,c17xrec.tariff) + tot(parm1,c17xrec.entryitem,c17xrec.tariff) * (nvl(to_number(c17xrec.description),0)/100)) * (nvl(to_number(c17xrec.colc),0)/100));
   end loop;
   for c17xrec in c17x(parm1) loop
    temptot := tot(parm1,c17xrec.entryitem,c17xrec.tariff);
    ttl := ttl + 
       (temptot +
          temptot * (nvl(to_number(c17xrec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17xrec.description),0)/100)) * (nvl(to_number(c17xrec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

 elsif parm_id = 'REPORT_A'
  then
   -- Calculate total Page Numbers to determine if the continuation report should be run
   if parm1 is null then return( 'RUN' ); end if;
   open c21(parm1);
   fetch c21 into c21rec;
   close c21;
   if c21rec.tot < 2
    then
     return( '0' );
   else
     return( 'RUN' );
   end if;

 elsif parm_id = 'REPORT_B'
  then
   -- Calculate total Page Numbers to determine if the continuation report should be run
   if parm1 is null then return( 'RUN' ); end if;
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is not null
    then
     return( '0' );
   else
     return( 'RUN' );
   end if;
   
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
 
 return( null );
 
end f15_parameter_range_sad_com;
/


GRANT EXECUTE ON STRANG.F15_PARAMETER_RANGE_SAD_COM TO WEBSYS;
