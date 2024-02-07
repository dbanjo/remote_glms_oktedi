CREATE OR REPLACE function STRANG.f_kiunga_report_figures( parm in varchar2 )
 return varchar2
as

-------------------------------------------------------------------------------  CLEARED CONTAINERS
 cursor c3(v1 integer) is
select count(distinct m.movement_no) ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and
  m.convoy_id is null and
  m.movement_type = 'CARGO';


 cursor c3_1(v1 integer) is
select sum( nvl(m.vgm,(nvl(m.sumweight,0)+nvl(tare,0))))/1000 wt_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and
  m.convoy_id is null and
  m.movement_type = 'CARGO';

 cursor c3_2(v1 integer) is
select sum( nvl(m.sumvolume,0)) vol_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and
  m.convoy_id is null and
  m.movement_type = 'CARGO';

cursor c4 is
select distinct c.customer, c.customer_id
  from strang.receivals r, strang.customers c, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = c.customer_id and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and
  m.convoy_id is null and
  m.movement_type = 'CARGO'
  order by c.customer;
-- ----------------------------------------------------------------------------------------------------------  CLEARED BREAK BULK
cursor c3a(v1 integer) is
select count(distinct m.movement_no) ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and
  m.convoy_id is null and
  m.movement_type = 'CONMOV';

 cursor c3a_1(v1 integer) is
select sum( nvl(m.vgm,nvl(m.sumweight,0)))/1000 wt_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and
  m.convoy_id is null and
  m.movement_type = 'CONMOV';

cursor c3a_2(v1 integer) is
select sum( nvl(m.sumvolume,0)) vol_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and
  m.convoy_id is null and
  m.movement_type = 'CONMOV';


cursor c4a is
select distinct c.customer, c.customer_id
  from strang.receivals r, strang.customers c, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = c.customer_id and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and
  m.convoy_id is null and
  m.movement_type = 'CONMOV'
  order by c.customer;
-- ---------------------------------------------------   PRIORITY CONTAINERS TO BE CLEARED
-- ---------------------------------------------------
-- ---------------------------------------------------   PRIORITY CONTAINERS CLEARED
 cursor c7(v1 integer, v2 varchar2, v3 varchar2) is
select count(distinct m.movement_no) ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and
  m.movement_type = 'CARGO' and
  m.urgency = v2 and
  m.convoy_id is null and
  m.container_type = v3;

 cursor c7_1(v1 integer, v2 varchar2, v3 varchar2) is
select sum( nvl(m.vgm,(nvl(m.sumweight,0)+nvl(tare,0))))/1000 wt_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and
  m.movement_type = 'CARGO' and
  m.convoy_id is null and
  m.urgency = v2 and
  m.container_type = v3;

 cursor c7_2(v1 integer, v2 varchar2, v3 varchar2) is
select sum( nvl(m.sumvolume,0)) vol_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and
  m.movement_type = 'CARGO' and
  m.convoy_id is null and
  m.urgency = v2 and
  m.container_type = v3;

cursor c8 is
select distinct c.customer, c.customer_id, m.urgency, m.container_type
  from strang.receivals r, strang.customers c, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = c.customer_id and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and
  m.movement_type = 'CARGO' and
  m.convoy_id is null and
  m.urgency <> 'STANDARD'
  order by c.customer;
-- ------------------------------------------------------------------------------------- PRIORITY BREAK BULK CLEARED
cursor c7a(v1 integer, v2 varchar2) is
select count(distinct m.movement_no) ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and
  m.convoy_id is null and
  m.movement_type = 'CONMOV' and
  m.urgency = v2;

 cursor c7a_1(v1 integer, v2 varchar2) is
select sum( nvl(m.vgm,nvl(m.sumweight,0)))/1000 wt_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and
  m.convoy_id is null and
  m.movement_type = 'CONMOV' and
  m.urgency = v2;

 cursor c7a_2(v1 integer, v2 varchar2) is
select sum( nvl(m.sumvolume,0)) vol_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and
  m.convoy_id is null and
  m.movement_type = 'CONMOV' and
  m.urgency = v2;

cursor c8a is
select distinct c.customer, c.customer_id, m.urgency
  from strang.receivals r, strang.customers c, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = c.customer_id and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and
  m.movement_type = 'CONMOV' and
  m.convoy_id is null and
  m.urgency <> 'STANDARD'
  order by c.customer;
-- ---------------------------------------------------  CONTAINERS DISCHARGE INFORMATION FOR TRANSFERRED CONTAINERS (TRANSFER DATE - DISCHARGE DATE)
 cursor c9 is
select c.customer, s.shipname||' '||s.voy ship, count(distinct m.movement_no) ttl, trunc(sysdate-trunc(nvl(m.local_ship_discharge_date,sysdate))) tdays
  from strang.receivals r, strang.detailrs dr, strang.movements m, strang.customers c, strang.ships_airway s
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA') and
  m.local_ship_id  = s.ship_id and
  m.movement_type = 'CARGO' and
  m.convoy_id is null and
   m.local_ship_discharge_date is not null and
   r.cust_customer_id = c.customer_id
  group by trunc(sysdate-trunc(nvl(m.local_ship_discharge_date,sysdate))), c.customer, s.shipname||' '||s.voy
  order by c.customer, tdays desc;

-- =====================================================
 c3rec     c3%ROWTYPE;
 c3_1rec   c3_1%ROWTYPE;
 c3_2rec   c3_2%ROWTYPE;
 c4rec     c4%ROWTYPE;
 c3arec    c3a%ROWTYPE;
 c3a_1rec  c3a_1%ROWTYPE;
 c3a_2rec  c3a_2%ROWTYPE;
 c4arec    c4a%ROWTYPE;
 c7rec     c7%ROWTYPE;
 c7_1rec   c7_1%ROWTYPE;
 c7_2rec   c7_2%ROWTYPE;
 c8rec     c8%ROWTYPE;
 c7arec    c7a%ROWTYPE;
 c7a_1rec  c7a_1%ROWTYPE;
 c7a_2rec  c7a_2%ROWTYPE;
 c8arec    c8a%ROWTYPE;
 c9rec    c9%ROWTYPE;
 tot	number;
 totw	number;
 totv	number;
 totdays	number;
 retvar	varchar2(32000);
 ctr	number;

begin
 retvar := NULL;
 tot:=0;
 totw:=0;
 totv:=0;
 totdays := 0;
 ctr  := 1;
 if parm = 'A2' then
  for c4rec in c4 loop
   open c3(c4rec.customer_id);
    fetch c3 into c3rec;
   close c3;
   open c3_1(c4rec.customer_id);
    fetch c3_1 into c3_1rec;
   close c3_1;
   open c3_2(c4rec.customer_id);
    fetch c3_2 into c3_2rec;
   close c3_2;
   if ctr = 1 then
   retvar := '<tr><td>' || c4rec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c3rec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c3_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c3_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
   '</td></tr>';
   else
   retvar := retvar || '<tr><td>' || c4rec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c3rec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c3_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c3_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
   '</td></tr>';
   end if;
   tot:= tot + nvl(c3rec.ttl,0);
   totw:= totw + nvl(c3_1rec.wt_ttl,0);
   totv:= totv + nvl(c3_2rec.vol_ttl,0);
   ctr := ctr + 1;
   end loop;
   retvar := retvar || '<tr><td><B>' ||  'TOTAL' ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'|| to_char( nvl(tot,0),'999,999,999') ||
   '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'||to_char(nvl(totw,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'|| to_char(nvl(totv,0),'999,999.999')||' CBM'||
   '</B></td></tr>';
 elsif
   parm = 'B2' then
  for c4arec in c4a loop
   open c3a(c4arec.customer_id);
    fetch c3a into c3arec;
   close c3a;
   open c3a_1(c4arec.customer_id);
    fetch c3a_1 into c3a_1rec;
   close c3a_1;
   open c3a_2(c4arec.customer_id);
    fetch c3a_2 into c3a_2rec;
   close c3a_2;
   if ctr = 1 then
   retvar := '<tr><td>' || c4arec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c3arec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c3a_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c3a_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
   '</td></tr>';
   else
   retvar := retvar || '<tr><td>' || c4arec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c3arec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c3a_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c3a_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
   '</td></tr>';
   end if;
   tot:= tot + nvl(c3arec.ttl,0);
   totw:= totw + nvl(c3a_1rec.wt_ttl,0);
   totv:= totv + nvl(c3a_2rec.vol_ttl,0);
   ctr := ctr + 1;
   end loop;
   retvar := retvar || '<tr><td><B>' ||  'TOTAL' ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'|| to_char( nvl(tot,0),'999,999,999') ||
   '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'||to_char(nvl(totw,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'|| to_char(nvl(totv,0),'999,999.999')||' CBM'||
   '</B></td></tr>';
 elsif
   parm = 'A4' then
  for c8rec in c8 loop
   open c7(c8rec.customer_id,c8rec.urgency,c8rec.container_type );
   fetch c7 into c7rec;
  close c7;
   open c7_1(c8rec.customer_id,c8rec.urgency,c8rec.container_type );
   fetch c7_1 into c7_1rec;
  close c7_1;
   open c7_2(c8rec.customer_id,c8rec.urgency,c8rec.container_type );
   fetch c7_2 into c7_2rec;
  close c7_2;
   if ctr = 1 then
    retvar := '<tr><td>' || c8rec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| c8rec.container_type||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>' ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| c8rec.urgency||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c7rec.ttl,0),'999,999,999')||
      '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c7_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c7_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
    '</td></tr>';
   else
    retvar := retvar || '<tr><td>' || c8rec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| c8rec.container_type||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>' ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| c8rec.urgency||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c7rec.ttl,0),'999,999,999')||
      '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c7_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c7_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
    '</td></tr>';
   end if;
    tot:= tot + nvl(c7rec.ttl,0);
    totw:= totw + nvl(c7_1rec.wt_ttl,0);
    totv:= totv + nvl(c7_2rec.vol_ttl,0);
    ctr := ctr + 1;
   end loop;
   retvar := retvar || '<tr><td><B>' ||  'TOTAL' ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;></td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;></td><td align=right padding:0cm 3.5pt 0cm 3.5pt;></td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td><B>'|| to_char( nvl(tot,0),'999,999,999') ||
   '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'||to_char(nvl(totw,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'|| to_char(nvl(totv,0),'999,999.999')||' CBM'||
   '</B></td></tr>';
 elsif
   parm = 'B4' then
  for c8arec in c8a loop
   open c7a(c8arec.customer_id,c8arec.urgency);
   fetch c7a into c7arec;
  close c7a;
   open c7a_1(c8arec.customer_id,c8arec.urgency );
   fetch c7a_1 into c7a_1rec;
  close c7a_1;
   open c7a_2(c8arec.customer_id,c8arec.urgency );
   fetch c7a_2 into c7a_2rec;
  close c7a_2;
   if ctr = 1 then
     retvar := '<tr><td>' || c8arec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>' ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| c8arec.urgency||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c7arec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c7a_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c7a_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
     '</td></tr>';
    else
     retvar := retvar || '<tr><td>' || c8arec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>' ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| c8arec.urgency||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c7arec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c7a_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c7a_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
     '</td></tr>';
    end if;
    tot:= tot + nvl(c7arec.ttl,0);
    totw:= totw + nvl(c7a_1rec.wt_ttl,0);
    totv:= totv + nvl(c7a_2rec.vol_ttl,0);
    ctr := ctr + 1;
   end loop;
   retvar := retvar || '<tr><td><B>' ||  'TOTAL' ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;></td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;></td><td align=right padding:0cm 3.5pt 0cm 3.5pt;></td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td><B>'|| to_char( nvl(tot,0),'999,999,999') ||
   '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'||to_char(nvl(totw,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'|| to_char(nvl(totv,0),'999,999.999')||' CBM'||
   '</B></td></tr>';
 elsif
   parm = 'A5' then
    for c9rec in c9 loop
     if ctr = 1 then
      retvar := '<tr><td>' || c9rec.customer ||'</td>'||'<td>' || c9rec.ship ||'</td><td>' || to_char(c9rec.tdays) ||' Days'||'</td><td><B>' || to_char(c9rec.ttl) ||' Containers'||'</B></td></tr>';
     else
      retvar := retvar||'<tr><td>' || c9rec.customer ||'</td>'||'<td>' || c9rec.ship ||'</td><td>' || to_char(c9rec.tdays) ||' Days'||'</td><td><B>' || to_char(c9rec.ttl) ||' Containers'||'</B></td></tr>';
    end if;
     tot:= tot + nvl(c9rec.ttl,0);
     totdays := totdays + nvl(c9rec.tdays,0);
     ctr := ctr + 1;
    end loop;
    retvar :=  retvar||'<tr><td><B>'||  'TOTAL' ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'|| to_char( nvl(totdays,0),'999,999,999') ||' Days ' ||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'||to_char(nvl(tot,0),'999,999,999')||' Containers '||
    '</B></td></tr>';
 else
     retvar := 'NO RECORDS FOUND';
 end if;
 return( retvar );
end f_kiunga_report_figures;
/


GRANT EXECUTE ON STRANG.F_KIUNGA_REPORT_FIGURES TO WEBSYS;
